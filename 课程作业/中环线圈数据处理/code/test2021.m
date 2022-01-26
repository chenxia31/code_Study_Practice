c=data_imagesc(y,NH37,NH38,NH39,NH40,NH41);
colormap jet
 imagesc(c);
 set(gca, 'XTick',0:36:288); 
 set(gca, 'XTicklabel',{'0:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','24:00'});
 set(gca,'YTick',[1,437,913,1481,2013]);
 set(gca,'YTicklabel',{'NHNX37','NHNX38','NHNX39','NHNX40','NHNX41'});