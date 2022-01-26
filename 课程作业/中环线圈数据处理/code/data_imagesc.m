function Q=data_imagesc(y,data1,data2,data3,data4,data5)
Q=[((data2-data1)*[1:1:(y(2)-y(1))]/(y(2)-y(1))+data1) ((data3-data2)*[1:1:(y(3)-y(2))]/(y(3)-y(2))+data2) ((data4-data3)*[1:1:(y(4)-y(3))]/(y(4)-y(3))+data3) ((data5-data4)*[1:1:(y(5)-y(4))]/(y(5)-y(4))+data4)];
Q=Q';