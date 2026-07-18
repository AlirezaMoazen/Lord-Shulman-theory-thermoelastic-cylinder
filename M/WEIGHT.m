function [A,B]=WEIGHT(n)
      for i=1:n
        x(i)=0.5*[1-cos((i-1)*pi/(n-1))]; %x1(i,1)=x(i); 
      end
      for i=1:n
         for j=1:n
              Pi=1;Pj=1;
            for m=1:n 
               if m~=i  
                  Pi=(x(i)-x(m))*Pi;
               end
               if m~=j  
                  Pj=(x(j)-x(m))*Pj;
               end   
            end
            if i~=j 
               A(i,j)=Pi/((x(i)-x(j))*Pj);
            end   
         end  
         for m=1:n  
             if m~=i
                A(i,i)=A(i,i)-A(i,m);
             end
         end   
      end
      for i=1:n
         for j=1:n
             B(i,j)=0;
         end  
      end      
      for i=1:n
         for j=1:n
            if i~=j
               B(i,j)=2*(A(i,i)*A(i,j)-(A(i,j)/(x(i)-x(j))));
            end   
         end      
         for m=1:n
            if i~=m
               B(i,i)=B(i,i)-B(i,m);
            end   
         end    
      end
%...............................................................