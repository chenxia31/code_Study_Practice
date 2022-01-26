function output=yidongpingjun(input,a)
output=input;
for i=2:(size(input,1)-a+2)
        output(i,:)=mean(input(i-1:i+a-2,:));
end