function out = run_solver_case(cfg)
%RUN_SOLVER_CASE  Run LSTE_solver_R11 with a cfg struct without disturbing the caller.
%   The solver is a script whose first line is `clearvars -except cfg`. Invoked
%   from the command line that wipes the caller's workspace; invoked from INSIDE
%   this function it only wipes this function's local workspace, so a driver can
%   loop over configurations safely.
%
%   out = run_solver_case(cfg) runs the solver and returns the saved result
%   struct (the contents of cfg.out_name).

LSTE_solver_R11;                 %#ok<NODEF>  cfg is picked up from this workspace
close all; drawnow;
out = load(out_name);            %#ok<NODEF>  out_name is set by the solver
end
