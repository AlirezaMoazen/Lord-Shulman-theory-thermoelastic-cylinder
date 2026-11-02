function cfg = case_library(name)
%CASE_LIBRARY  Named input cases. Add a new case by adding a branch below.
%
%   cfg = case_library('reference')   thesis reference (LS, UD/UD, S-S, 7 layers)
%   cfg = case_library('fourier')     classical coupled theory, same data
%   cfg = case_library('gpl_X_por_V') GPL pattern X with porosity pattern V
%   cfg = case_library('quick')       coarse and short, for a fast self-check
switch lower(name)
    case 'reference'
        cfg = default_input();
    case 'fourier'
        cfg = default_input(struct('theory','FOURIER'));
    case 'gpl_x_por_v'
        cfg = default_input(struct('GPL_pattern','X','porosity_pattern','V'));
    case 'quick'
        cfg = default_input(struct('NL',3,'N_r',7,'N_z',7, ...
                                   'total_time',60,'dt',1,'verbose',false));
    otherwise
        error('case_library:unknownCase', 'Unknown case "%s".', name);
end
end
