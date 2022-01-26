library(readxl)
library(stringr)
Midterm_assignment <- read_excel("Midterm_assignment.xlsx")
Midterm_assignment=Midterm_assignment[,-5]#type无用，为了后续处理方便删除type
unique(Midterm_assignment$lane_id)#观察有多少车道

##part01
#1.1读取数据，分*_Lane01\*_Lane02\*_lane03\*07.0-EB-Lane04\*07.6-EB-Lane04\*08.0-EB-Rmp-Lane04
data_lane01=Midterm_assignment[endsWith(Midterm_assignment$lane_id,'Lane01'),]
data_lane02=Midterm_assignment[endsWith(Midterm_assignment$lane_id,'Lane02'),]
data_lane03=Midterm_assignment[endsWith(Midterm_assignment$lane_id,'Lane03'),]
data_Ramp1=Midterm_assignment[endsWith(Midterm_assignment$lane_id,'07.0-EB-Lane04'),]
data_Ramp2=Midterm_assignment[endsWith(Midterm_assignment$lane_id,'07.6-EB-Lane04'),]
data_Ramp3=Midterm_assignment[endsWith(Midterm_assignment$lane_id,'08.0-EB-Rmp-Lane04'),]
data_standard=function(data){
  standard1_data=(data-min(data))/(max(data)-min(data))
  
  sigma_data=sum(abs(data-mean(data)))/length(data)
  standard2_data=(data-mean(data))/sigma_data
  
  result=vector()
  result[1]=mean(data)
  result[2]=sd(data)
  result[3]=mean(standard1_data)
  result[4]=sd(standard1_data)
  result[5]=mean(standard2_data)
  result[6]=sd(standard2_data)
  return(result)
}
#计算均值
data_standard(data_lane01$speed)
data_standard(data_lane02$speed)
data_standard(data_lane03$speed)
data_standard(data_Ramp1$speed)
data_standard(data_Ramp2$speed)
data_standard(data_Ramp3$speed)

#1.2 异常值的处理（对不同车道实行阈值法）

#生成完整的没有缺失数据的数据框
data_date=rep(unique(Midterm_assignment$date),each=721*18)

temp_time=unique(Midterm_assignment$timestamp)
temptime=temp_time[c(1:100,721,101:720)]
data_time=rep(temptime,times=5,each=18)

temp_lane=unique(Midterm_assignment$lane_id)
temp_lane=temp_lane[c(1,2,3,4,5,6,7,17,8,9,10,11,12,13,14,15,16,18)]#调整顺序
data_lane=rep(temp_lane,times=721*5)

data_detector=str_sub(data_lane,1,15)
data_speed=rep(-1,times=5*721*18)
data_volume=rep(-1,times=5*721*18)
data_occupancy=rep(-1,times=5*721*18)

New_Midterm_data=data.frame(date=data_date,timestamp=data_time,detector_id=data_detector,
                            lane_id=data_lane,speed=data_speed,volume=data_volume,occupancy=data_occupancy)

for(n in 1:(5*721*18)){
  #将现有的数据加到新建的数据框中
  logic=(Midterm_assignment$date==data_date[n]&Midterm_assignment$timestamp==data_time[n]&Midterm_assignment$lane_id==data_lane[n])
  if(sum(logic)==1){
    New_Midterm_data[n,c(5,6,7)]=apply(Midterm_assignment[logic,c(5,6,7)],2,sum)/sum(logic)
  }
  print(n)
}

judge1=function(data){
  #五分位数和三标准差法判断范围过大，采用单独的判断、联合判断和有效车长来进行判断，只有第一种可以区分三个参数中唯一出错的
  s_ab=(data$speed<0|data$speed>112)
  v_ab=(data$volume<0|data$volume>51)
  o_ab=(data$occupancy<0|data$occupancy>95)
  
  temp1=data$speed==0
  temp2=data$volume==0
  temp3=data$occupancy==0
  temp=temp1+temp2+temp3

  add_01=(((temp==3)|(temp==0)|data$occupancy>95|(data$volume<5&data$occupancy==0))|((s_ab+v_ab+o_ab)!=0))==0
  
  avel=data$speed*data$occupancy/(6*data$volume)
  add_02=(avel<1.5|avel>22)&((data$volume<5&data$occupancy==0)==0)&((s_ab+v_ab+o_ab+add_01)==0)

  s_ab=s_ab+add_01+add_02
  v_ab=v_ab+add_01+add_02
  o_ab=o_ab+add_01+add_02
 
  data['s_ab']=as.integer(s_ab!=0)
  data['v_ab']=as.integer(v_ab!=0)
  data['o_ab']=as.integer(o_ab!=0)
  data['error']=s_ab+v_ab+o_ab
 
  return(data)
}
New_Midterm_data=judge1(New_Midterm_data)
New_Midterm_data=New_Midterm_data[c(1,2,3,4,5,8,6,9,7,10,11)]#调整参数
write.csv(New_Midterm_data,file='New_Midterm_data.csv')

#1.3缺失值的填补
data_find=function(data,n){
  #用来寻找异常值或者缺失值时空最接近点上正常的数
  
  #首先确定n是否为第一位或者最后以为
  if(n==1){
    n=n+1
  }
  if(n==length(data)){
    n=n-1
  }
  #初始化前值和后值，以及初始下标和标记位
  foredata=data[n-1]
  nextdata=data[n+1]
  fore_n=n
  next_n=n
  temp_fore=0
  temp_next=0
  #函数主体循环，说明
  while(foredata==-1){
    fore_n=fore_n -1
    #说明前面没有正确的值
    if(length(fore_n)==0){
      temp_fore=1
      break
    }
    foredata=data[fore_n]
    if(length(foredata)==0){
      foredata=0.01
    }
  }
  while(nextdata==-1){
    next_n=next_n+1
    if(nextdata>length(data)){
      temp_next=1
      break
    }
    nextdata=data[next_n]
    if(length(nextdata)==0){
      nextdata=0.01
    }
  }
  if((temp_fore!=1)&(temp_next!=1)){
    result=(foredata+nextdata)/2
  }else{
    if((temp_fore==1)&(temp_next!=1)){
      result=nextdata
    }else{
      if((temp_fore!=1)&(temp_next==1)){
        result=foredata
      }
    }
  }
  return(result)
}

data_correct=function(data){
  #不同进行修正
  index_speed=which(data$s_ab==1)
  index_volume=which(data$v_ab==1)
  index_occupancy=which(data$o_ab==1)
  for(index in index_speed)
  data$speed[index]=data_find(data$speed,index)
  for(index in index_volume)
    data$volume[index]=data_find(data$volume,index)
  for(index in index_occupancy)
    data$occupancy[index]=data_find(data$occupancy,index)
  return(data)
}

data_lane01=data_correct(New_Midterm_data[endsWith(New_Midterm_data$lane_id,'Lane01'),])
data_lane02=data_correct(New_Midterm_data[endsWith(New_Midterm_data$lane_id,'Lane02'),])
data_lane03=data_correct(New_Midterm_data[endsWith(New_Midterm_data$lane_id,'Lane03'),])
data_Ramp1=data_correct(New_Midterm_data[endsWith(New_Midterm_data$lane_id,'07.0-EB-Lane04'),])
data_Ramp2=data_correct(New_Midterm_data[endsWith(New_Midterm_data$lane_id,'07.6-EB-Lane04'),])
data_Ramp3=data_correct(New_Midterm_data[endsWith(New_Midterm_data$lane_id,'08.0-EB-Rmp-Lane04'),])

data_after_correct=rbind(data_lane01,data_lane02,data_lane03,data_Ramp1,data_Ramp2,data_Ramp3)
data_error=data_after_correct[data_after_correct$error!=0,]
write.csv(data_error,file='Midterm_data_error.csv')
Corrext_midterm_assignment=data_after_correct[,c(1,2,3,4,5,7,9)]
write.csv(Corrext_midterm_assignment,file='Midterm_data_correct.csv')


