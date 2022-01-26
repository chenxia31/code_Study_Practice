function [Mc,msg]=A1854084(Ma,Mb,flag)
[MaRow,MaCol]=size(Ma);
[MbRow,MbCol]=size(Mb);
if MaCol~=MbRow
    msg='cannot Be MUltlied';
    Mc=-1;
else 
    msg='Ok';
    switch flag
        case 1
            Mc=Ma*Mb;
        case 2
           
                for i=1:MaRow
                    for j=1:MbCol
                        Mc(i,j)=0;
                         for k=1:MaCol
                        Mc(i,j)=Ma(i,k)*Mb(k,j)+Mc(i,j);
                         end
                    end
                end
                     
         case 3
             for i=1:MaRow
                 for j=1:MbCol
                     Mc(i,j)=0;
                     Mc(i,j)=Mc(i,j)+Ma(i,:)*Mb(:,j);
            
                 end
             end
    end
end
end

        