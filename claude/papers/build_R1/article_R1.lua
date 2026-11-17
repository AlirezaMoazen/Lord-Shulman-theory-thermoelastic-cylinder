-- article.lua : automatic numbering for equations, figures and tables (Word SEQ / REF fields)
-- Source syntax (markdown):
--   ::: {#eq-name .eq}            display equation  -> 3-column borderless table, number at the far right
--   $$ ... $$
--   :::
--   ::: {#fig-name .fig}          figure: image paragraph, then caption paragraph
--   ![](path){width=100%}
--
--   Caption text.
--   :::
--   ::: {#tbl-name .tbl}          table: caption paragraph, then the table
--   Caption text.
--
--   | ... |
--   :::
--   ::: {#tbl-name .tblA}         appendix table (numbered A.1, A.2, ...)
--   {{eq-name}}, {{fig-name}}, {{tbl-name}} inside text become REF fields that show only the number.

local counters = { eq = 0, fig = 0, tbl = 0, tblA = 0 }
local labels = {}
local kinds = {}
local bm = 1000

local function esc(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function bmname(id) return '_Ref_' .. id:gsub('[^%w]', '_') end

local function run_text(s)
  return pandoc.RawInline('openxml', '<w:r><w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>')
end

local function seq_field(kind, id, num)
  bm = bm + 1
  local seqname = (kind == 'eq') and 'Equation' or (kind == 'fig') and 'Figure' or (kind == 'tbl') and 'Table' or 'TableA'
  local prefix = (kind == 'tblA') and '<w:r><w:t>A.</w:t></w:r>' or ''
  return pandoc.RawInline('openxml',
    '<w:bookmarkStart w:id="' .. bm .. '" w:name="' .. bmname(id) .. '"/>' .. prefix ..
    '<w:fldSimple w:instr=" SEQ ' .. seqname .. ' \\* ARABIC "><w:r><w:t>' .. num .. '</w:t></w:r></w:fldSimple>' ..
    '<w:bookmarkEnd w:id="' .. bm .. '"/>')
end

local function ref_field(id)
  local num = labels[id] or '??'
  local shown = num
  if kinds[id] == 'tblA' then shown = 'A.' .. num end
  return pandoc.RawInline('openxml',
    '<w:fldSimple w:instr=" REF ' .. bmname(id) .. ' \\h "><w:r><w:t>' .. shown .. '</w:t></w:r></w:fldSimple>')
end

-- pass 1: number everything in document order
local function number_pass(doc)
  doc.blocks:walk {
    Div = function(d)
      local id = d.identifier
      if id == '' then return nil end
      if d.classes:includes('eq') then counters.eq = counters.eq + 1; labels[id] = tostring(counters.eq); kinds[id] = 'eq'
      elseif d.classes:includes('fig') then counters.fig = counters.fig + 1; labels[id] = tostring(counters.fig); kinds[id] = 'fig'
      elseif d.classes:includes('tbl') then counters.tbl = counters.tbl + 1; labels[id] = tostring(counters.tbl); kinds[id] = 'tbl'
      elseif d.classes:includes('tblA') then counters.tblA = counters.tblA + 1; labels[id] = tostring(counters.tblA); kinds[id] = 'tblA'
      end
      return nil
    end
  }
end

local function eq_table(mathinl, id)
  local colspecs = { { pandoc.AlignDefault, 0.04 }, { pandoc.AlignCenter, 0.84 }, { pandoc.AlignRight, 0.12 } }
  local numinl = { run_text('('), seq_field('eq', id, labels[id]), run_text(')') }
  local cells = {
    pandoc.Cell({}, pandoc.AlignDefault, 1, 1),
    pandoc.Cell({ pandoc.Plain { mathinl } }, pandoc.AlignCenter, 1, 1),
    pandoc.Cell({ pandoc.Plain(numinl) }, pandoc.AlignRight, 1, 1),
  }
  local body = pandoc.TableBody({ pandoc.Row(cells) }, {}, 0)
  local tbl = pandoc.Table(pandoc.Caption({}), colspecs, pandoc.TableHead({}), { body }, pandoc.TableFoot({}))
  return pandoc.Div({ tbl }, pandoc.Attr('', {}, { ['custom-style'] = 'EqTable' }))
end

local function first_math(blocks)
  local found
  for _, b in ipairs(blocks) do
    if b.t == 'Para' or b.t == 'Plain' then
      for _, i in ipairs(b.content) do
        if i.t == 'Math' then found = i; break end
      end
    end
    if found then break end
  end
  return found
end

local function caption_para(label, kind, id, textblock, style)
  local inl = { pandoc.Str(label), pandoc.Space(), seq_field(kind, id, labels[id]) }
  inl[#inl + 1] = pandoc.Str('.')
  inl[#inl + 1] = pandoc.Space()
  for _, i in ipairs(textblock.content) do inl[#inl + 1] = i end
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr('', {}, { ['custom-style'] = style }))
end

local function div_filter(d)
  local id = d.identifier
  if d.classes:includes('eq') then
    local m = first_math(d.content)
    if not m then return nil end
    local mi = pandoc.Math('DisplayMath', m.text)
    -- inline math in a cell: use DisplayMath so Word keeps display size
    return eq_table(mi, id)
  elseif d.classes:includes('fig') then
    local img, cap
    for _, b in ipairs(d.content) do
      if (b.t == 'Para' or b.t == 'Plain') and not img and #b.content >= 1 and b.content[1].t == 'Image' then img = b
      elseif b.t == 'Para' and not cap then cap = b end
    end
    if not img or not cap then return nil end
    local im = img.content[1]
    im.caption = pandoc.Inlines { pandoc.Str('Figure ' .. labels[id]) }
    im.title = ''
    img = pandoc.Para { im }
    local imgdiv = pandoc.Div({ img }, pandoc.Attr('', {}, { ['custom-style'] = 'Captioned Figure' }))
    return { imgdiv, caption_para('Fig.', 'fig', id, cap, 'Image Caption') }
  elseif d.classes:includes('tbl') or d.classes:includes('tblA') then
    local kind = d.classes:includes('tbl') and 'tbl' or 'tblA'
    local cap, tbl
    for _, b in ipairs(d.content) do
      if b.t == 'Para' and not cap then cap = b
      elseif b.t == 'Table' and not tbl then tbl = b end
    end
    if not cap or not tbl then return nil end
    return { caption_para('Table', kind, id, cap, 'Table Caption'), tbl }
  end
  return nil
end

local function str_filter(s)
  if not s.text:find('{{', 1, true) then return nil end
  local out = {}
  local rest = s.text
  while true do
    local a, b, id = rest:find('{{([%w%-_]+)}}')
    if not a then break end
    if a > 1 then out[#out + 1] = pandoc.Str(rest:sub(1, a - 1)) end
    out[#out + 1] = ref_field(id)
    rest = rest:sub(b + 1)
  end
  if #rest > 0 then out[#out + 1] = pandoc.Str(rest) end
  return out
end

function Pandoc(doc)
  number_pass(doc)
  local blocks = doc.blocks:walk { Div = div_filter }
  blocks = pandoc.Blocks(blocks):walk { Str = str_filter }
  return pandoc.Pandoc(blocks, doc.meta)
end
