function output=zhishupingjun(input,a)
output=input;
for i=2:size(input,1)
    output(i,:)=a*input(i,:)+(1-a)*output(i-1,:);
end