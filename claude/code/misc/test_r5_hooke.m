%% test_r5_hooke.m — validate R5 Hooke-law eps_zz recovery
%  Checks: (1) recovered per-layer 2*mu for the UD base case matches the
%  reference 2*mu computed from the material model; (2) Hooke eps_zz is close
%  to the old last-snapshot eps_zz (sanity); (3) no NaN; eps_rr/eps_tt unchanged.
clearvars; clc;
pdir = 'param_studies';
cases = {'BASE_R4','A_GPL_X','D3_W_001','D3_W_015','K_RO_030'};  % UD, pattern, low-W x2, thick

% reference 2*mu for the UD base material (W=4%, em3=0.898) — catalog lines 19-34
E_GPL=1.01e12; rho_GPL=1062.5; nu_GPL=0.186; E_m=3.0e9; nu_m=0.34; rho_m=1200;
a_GPL=2.5e-6; b_GPL=1.5e-6; t_GPL=1.5e-9; Wg=0.04; em3=0.8980;
Vg=Wg/(Wg+(rho_GPL/rho_m)*(1-Wg));
xiL=2*a_GPL/t_GPL; xiT=2*b_GPL/t_GPL;
etL=(E_GPL/E_m-1)/(E_GPL/E_m+xiL); etT=(E_GPL/E_m-1)/(E_GPL/E_m+xiT);
Es=(3/8*(1+xiL*etL*Vg)/(1-etL*Vg)+5/8*(1+xiT*etT*Vg)/(1-etT*Vg))*E_m;
nus=Vg*nu_GPL+(1-Vg)*nu_m; Pf=em3^2; E_ref=Es*Pf; nu_ref=nus;
mu_ref=E_ref/(2*(1+nu_ref));
fprintf('reference 2*mu (UD, W=4%%, em3=0.898) = %.4e Pa\n\n', 2*mu_ref);

for k=1:numel(cases)
    f=fullfile(pdir,[cases{k} '.mat']);
    if ~exist(f,'file'), fprintf('%-10s  MISSING\n',cases{k}); continue; end
    d=load(f); NL=d.NL; Nr=d.N_r; Nz=d.N_z;
    ett=d.U_all(:)./d.r_all(:);
    err=zeros(numel(d.U_all),1);
    for e=1:NL, Ar=dqA(d.r_nodes{e}); idx=(e-1)*Nr+(1:Nr); err(idx)=Ar*d.U_all(idx).'; end
    Srr=d.S_rr(:); Stt=d.S_tt(:); Szz=d.S_zz(:);
    % Hooke eps_zz + recovered 2*mu
    ezzH=nan(numel(err),1); twomus=zeros(NL,1);
    for e=1:NL
        idx=(e-1)*Nr+(1:Nr);
        ei=err(idx);ei=ei(:); ti=ett(idx);ti=ti(:);
        sr=Srr(idx);sr=sr(:); st=Stt(idx);st=st(:); sz=Szz(idx);sz=sz(:);
        de=ei-ti; ds=sr-st; twomus(e)=(de.'*ds)/(de.'*de);
        ezzH(idx)=0.5*(ei+ti)-0.5*((sr+st-2*sz)/twomus(e));
    end
    % old snapshot eps_zz
    ezzS=nan(numel(err),1);
    try
        xs=d.snaps{end}; Az=dqA(d.z_nodes); iz0=round(Nz/2); Nn=NL*Nr*Nz;
        for e=1:NL, for ir=1:Nr
            base=2*Nn+(e-1)*Nr*Nz+(ir-1)*Nz; wcol=xs(base+(1:Nz));
            ezzS((e-1)*Nr+ir)=Az(iz0,:)*wcol(:);
        end, end
    catch, end
    rel=max(abs(ezzH-ezzS))/(max(abs(ezzS))+eps);
    fprintf(['%-10s  2mu=[%.3e..%.3e]  ezzH=[%+.3e..%+.3e]  ezzS=[%+.3e..%+.3e]  ' ...
             'maxreldiff=%.2e  nanH=%d\n'], cases{k}, min(twomus),max(twomus), ...
             min(ezzH),max(ezzH), min(ezzS),max(ezzS), rel, sum(isnan(ezzH)));
end

function A=dqA(x)
    x=x(:);N=numel(x);A=zeros(N);
    for i=1:N,for j=1:N, if i~=j
        num=1;den=1; for kk=1:N, if kk~=i&&kk~=j, num=num*(x(i)-x(kk)); den=den*(x(j)-x(kk)); end, end
        A(i,j)=num/(den*(x(j)-x(i)));
    end, end, end
    for i=1:N, A(i,i)=-sum(A(i,:)); end
end
