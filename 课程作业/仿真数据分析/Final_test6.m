%%
%首先输入变量
total_pred=zeros(48,6);%记录验证集的预测变量
total_pred_train=zeros(120,6);%记录训练集的预测变量
meap=zeros(1,6);
%%
%线性回归，针对2，6路段
target1=[2,6];
for i=1:length(target1)
    x=[speedloop(:,target1(i)),speedFR(:,target1(i))];
    y=speedReal(:,target1(i));
    x_train=x(1:120,:);
    y_train=y(1:120,:);
    x_test=x(121:168,:);
    y_test=y(121:168,:);
    [b]=regress(y_train,x_train);
    y_pred_train=x_train*b;
    total_pred_train(:,target1(i))=y_pred_train;
    y_pred=x_test*b;
    total_pred(:,target1(i))=y_pred;
    figure
    plot(1:48,y_test,'-*',1:48,y_pred,'o');
    legend('test','pred')
    title(target1(i))
    meap(target1(i)) = mean(abs((y_test - y_pred)./y_test))*100;
end
%%
%BP神经网络，针对路段1，3，4，5
target2=[1,3,4,5];
for i=1:length(target2)
    x=[speedloop(:,target2(i)),speedFR(:,target2(i))];
    y=speedReal(:,target2(i));
    x_train=x(1:120,:)';
    y_train=y(1:120,:)';
    x_test=x(121:168,:)';
    y_test=y(121:168,:)';
    numFeatures = 2;
    numResponses = 1;
    numHiddenUnits = 1000;

    layers = [ ...
        sequenceInputLayer(numFeatures)
        lstmLayer(numHiddenUnits)
        fullyConnectedLayer(numResponses)
        regressionLayer];
        options = trainingOptions('adam', ...
        'MaxEpochs',1000, ...
        'GradientThreshold',1, ...
        'InitialLearnRate',0.005, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125, ...
        'LearnRateDropFactor',0.2, ...
        'Verbose',0, ...
        'Plots','training-progress');
    net = trainNetwork(x_train,y_train,layers,options);
    net = predictAndUpdateState(net,x_train);
    [net,Y_pred] = predictAndUpdateState(net,x_test);
    total_pred(:,target2(i))=Y_pred';
    [net,Y_pred_train] = predictAndUpdateState(net,x_train);
    total_pred_train(:,target2(i))=Y_pred_train';
    figure
    plot(1:48,y_test,'-*',1:48,Y_pred,'o');
    legend('test','pred')
    title(target2(i))
    meap(target2(i))=mean(abs((y_test - Y_pred)./y_test))*100;
end
%%
dis=[507,687,490,600,267,417];
MEAP=sum(dis.*meap)/sum(dis)


