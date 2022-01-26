function [rate,Error_correct,data_bug]=data_check(data)
%独立判断法（设置流量范围【0，3060】，速度范围【0，80*1.4】，占有率范围【0，95】
logic=zeros(size(data,1),3);
logic(:,1)=(data{:,4}>17);
logic(:,2)=(data{:,5}>112);
logic(:,3)=(data{:,6}>95);
Index=(sum(logic,2)>0);
Error1=data(Index,:);  %提取错误数据
%绘制小时有效性
%%
%联合判断法,如果流量、速度、占有率中出现0值，其他必为0值，否则出错
logic=zeros(size(data,1),3);
logic(:,1)=(data{:,4}>0);
logic(:,2)=(data{:,5}>0);
logic(:,3)=(data{:,6}>0);
logic=sum(logic,2);
Index=(((logic==3)+(logic==0))+(data{:,6}>95))==0;
Error2=data(Index,:);  %提取错误数据
%绘制小时有效性
%%
%有效车长判断 
aveL=10*data{:,5}.*data{:,6}./data{:,4}/180;
Index=((aveL>12)+(aveL<3))==1;
Error3=data(Index,:);  %提取错误数据
%%
%错误汇总
Error=[Error1;Error2;Error3];
Error=unique(Error);
rate=1-size(Error,1)/size(data,1);
%%
%纠正
[temp,bug_Index]=ismember(Error,data);
data_bug=data;
for i=1:length(bug_Index)
    if(bug_Index(i)>1&&bug_Index(i)<4320)
    data_bug{bug_Index(i),4:6}=1/2*((data{bug_Index(i)-1,4:6}+data{bug_Index(i)+1,4:6}));
    else
       if(bug_Index(i)==1)
           data_bug{bug_Index(i),4:6}=data{bug_Index(i)+1,4:6};
       else 
           if(bug_Index(i)==4320)
            data_bug{bug_Index(i),4:6}=data{bug_Index(i)-1,4:6};
           end
       end
    end    
end
Error_correct=data_bug{bug_Index,4:6};
