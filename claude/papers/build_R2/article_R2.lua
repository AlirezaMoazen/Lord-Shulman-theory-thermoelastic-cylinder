-- article_R2.lua : automatic numbering for equations, figures, tables AND citations (Word SEQ / REF fields)
-- R2 = article_R1.lua (frozen) + automatic citation numbers (author instruction of 2026-11-23, Prom8 item 19:
--      "make the numbers of the references automatic like the figures and the formulas").
-- Source syntax (markdown) is that of R1:
--   ::: {#eq-name .eq}            display equation  -> 3-column borderless table, number at the far right
--   ::: {#fig-name .fig}          figure: image paragraph, then caption paragraph
--   ::: {#tbl-name .tbl}          table: caption paragraph, then the table
--   {{eq-name}}, {{fig-name}}, {{tbl-name}} inside text become REF fields that show only the number.
-- New in R2:
--   * the numbered list that follows the heading "References" is the reference list. Each item gets a bookmark
--     (_Ref_bib<n>, n = position in the list). The list numbers themselves are Word list numbers (automatic).
--   * every citation written as [n], [n, m, ...] or [n-m] (hyphen or en dash) in the text (digits, commas, hyphens, en dashes and
--     spaces only) becomes brackets with one REF field per number (REF _Ref_bib<n> \n \h, i.e. the paragraph number of
--     the list item without the trailing period). After a reference is inserted, moved or deleted in the list, Ctrl+A
--     and F9 renumber every citation. A range [a-b] keeps its two end numbers as fields.
--   * the filter does not touch the reference list itself, equations or any text that is not of the form above.

local counters = { eq = 0, fig = 0, tbl = 0, tblA = 0 }
local labels = {}
local kinds = {}
local bm = 1000
local nrefs = 0

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

-- citation number -> REF field to the bookmark of that reference-list item
local function bib_field(n)
  return pandoc.RawInline('openxml',
    '<w:fldSimple w:instr=" REF _Ref_bib' .. n .. ' \\n \\h "><w:r><w:t>' .. n .. '</w:t></w:r></w:fldSimple>')
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

-- ---------------------------------------------------------------------------------------------
-- references: bookmark every item of the list that follows the heading "References"
-- ---------------------------------------------------------------------------------------------
local function is_ref_heading(b)
  return b.t == 'Header' and b.level == 2 and pandoc.utils.stringify(b.content) == 'References'
end

local function bookmark_reference_list(blocks)
  local in_refs = false
  local list_index = nil
  for i, b in ipairs(blocks) do
    if is_ref_heading(b) then in_refs = true
    elseif in_refs and b.t == 'Header' then in_refs = false
    elseif in_refs and b.t == 'OrderedList' and not list_index then
      list_index = i
      local newitems = {}
      for n, item in ipairs(b.content) do
        local first = item[1]
        local blocksout = {}
        for k, blk in ipairs(item) do blocksout[k] = blk end
        if first and (first.t == 'Para' or first.t == 'Plain') then
          bm = bm + 1
          local startbm = pandoc.RawInline('openxml', '<w:bookmarkStart w:id="' .. bm .. '" w:name="_Ref_bib' .. n .. '"/>')
          local endbm = pandoc.RawInline('openxml', '<w:bookmarkEnd w:id="' .. bm .. '"/>')
          local inl = pandoc.Inlines { startbm }
          for _, x in ipairs(first.content) do inl:insert(x) end
          inl:insert(endbm)
          blocksout[1] = (first.t == 'Para') and pandoc.Para(inl) or pandoc.Plain(inl)
        end
        newitems[n] = blocksout
      end
      nrefs = #newitems
      blocks[i] = pandoc.OrderedList(newitems, b.listAttributes)
    end
  end
  return list_index
end

-- ---------------------------------------------------------------------------------------------
-- citations: [n], [n, m], [n-m], [n, m-k] ... -> brackets with REF fields
-- ---------------------------------------------------------------------------------------------
local function parse_citation(inlines, i)
  local first = inlines[i]
  if first.t ~= 'Str' or not first.text:match('^%[%d') then return nil end
  local s = ''
  local last = nil
  for k = i, math.min(i + 40, #inlines) do
    local el = inlines[k]
    if el.t == 'Str' then
      s = s .. el.text
      if el.text:find(']', 1, true) then last = k; break end
    elseif el.t == 'Space' or el.t == 'SoftBreak' then
      s = s .. ' '
    else
      return nil
    end
  end
  if not last then return nil end
  local core, trailing = s:match('^(%[[^%]]*%])(.*)$')
  if not core then return nil end
  local core2 = core:gsub('\226\128\147', '-')            -- en dash (UTF-8) -> hyphen
  if not core2:match('^%[[%d,%s%-]+%]$') then return nil end
  local parts = {}
  for part in core2:sub(2, -2):gmatch('[^,]+') do
    local p = part:gsub('%s+', '')
    local a, b = p:match('^(%d+)%-(%d+)$')
    if a then
      a, b = tonumber(a), tonumber(b)
      if a < 1 or b > nrefs or a >= b then return nil end
      parts[#parts + 1] = { a, b }
    elseif p:match('^%d+$') then
      local n = tonumber(p)
      if n < 1 or n > nrefs then return nil end
      parts[#parts + 1] = { n }
    else
      return nil
    end
  end
  if #parts == 0 then return nil end
  local out = { pandoc.Str('[') }
  for idx, p in ipairs(parts) do
    if idx > 1 then out[#out + 1] = pandoc.Str(','); out[#out + 1] = pandoc.Space() end
    out[#out + 1] = bib_field(p[1])
    if p[2] then out[#out + 1] = pandoc.Str('\226\128\147'); out[#out + 1] = bib_field(p[2]) end
  end
  out[#out + 1] = pandoc.Str(']')
  if trailing ~= '' then out[#out + 1] = pandoc.Str(trailing) end
  return out, last
end

local ncite = 0
local function cite_filter(inlines0)
  -- pandoc joins an abbreviation and the next word with a no-break space into ONE token ("al.<nbsp>[49]"):
  -- split such a token before the bracket so that the citation is a token of its own
  local inlines = pandoc.Inlines {}
  for _, el in ipairs(inlines0) do
    if el.t == 'Str' then
      local pre, rest = el.text:match('^(.-\194\160)(%[%d.*)$')
      if pre then
        inlines:insert(pandoc.Str(pre)); inlines:insert(pandoc.Str(rest))
      else
        inlines:insert(el)
      end
    else
      inlines:insert(el)
    end
  end
  local out = pandoc.Inlines {}
  local i = 1
  local changed = (#inlines ~= #inlines0)
  while i <= #inlines do
    local rep, last = parse_citation(inlines, i)
    if rep then
      for _, r in ipairs(rep) do out:insert(r) end
      i = last + 1
      changed = true
      ncite = ncite + 1
    else
      out:insert(inlines[i])
      i = i + 1
    end
  end
  if changed then return out end
  return nil
end

function Pandoc(doc)
  number_pass(doc)
  local blocks = pandoc.Blocks(doc.blocks)
  local list_index = bookmark_reference_list(blocks)
  blocks = blocks:walk { Div = div_filter }
  -- citations in every block except the reference list itself (found again after the Div pass by its content)
  local out = pandoc.Blocks {}
  local in_refs = false
  for _, b in ipairs(blocks) do
    if is_ref_heading(b) then in_refs = true; out:insert(b)
    elseif in_refs and b.t == 'Header' then in_refs = false; out:insert(b)
    elseif in_refs and b.t == 'OrderedList' then out:insert(b)
    else
      out:insert(pandoc.Blocks({ b }):walk { Inlines = cite_filter }[1])
    end
  end
  blocks = pandoc.Blocks(out):walk { Str = str_filter }
  io.stderr:write('article_R2.lua: ' .. nrefs .. ' references bookmarked, ' .. ncite .. ' citations converted to fields\n')
  return pandoc.Pandoc(blocks, doc.meta)
end
