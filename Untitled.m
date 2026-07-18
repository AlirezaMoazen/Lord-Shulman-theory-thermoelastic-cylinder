clc,clear;

N=9;
M=17;
NM=N*M;

C_T(1:M,:)=0;
  for i=1:M
      C_T(i,i)=1;
  end


C_T((NM-M):NM,:)=0;
  for i=(NM-M):NM
      C_T(i,i)=1;
  end


  for i=1:(N-2)
      C_T((i*M+1),:)=0;
  end
  for i=1:(N-2)
      C_T((i*M+1),(i*M+1))=1;
  end
  
  for i=2:(N-1)
      C_T((i*M),:)=0;
  end
  for i=2:(N-1)
      C_T((i*M),(i*M))=1;
  end
C_T


% C_T(1:N,:)=0;
%   for i=1:N
%       C_T(i,i)=1;
%   end
% 
% 
% C_T((NM-N):NM,:)=0;
%   for i=(NM-N):NM
%       C_T(i,i)=1;
%   end
% 
% 
%   for i=1:(M-2)
%       C_T((i*N+1),:)=0;
%   end
%   for i=1:(M-2)
%       C_T((i*N+1),(i*N+1))=1;
%   end
%   
%   for i=2:(M-1)
%       C_T((i*N),:)=0;
%   end
%   for i=2:(M-1)
%       C_T((i*N),(i*N))=1;
%   end
% C_T