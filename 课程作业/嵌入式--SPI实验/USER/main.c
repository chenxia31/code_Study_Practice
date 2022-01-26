#include "led.h"
#include "delay.h"
#include "key.h"
#include "sys.h"
#include "lcd.h"
#include "usart.h"	 
#include "beep.h"
#include "flash.h"
#include "string.h"
char c[200];

 int main(void)
 {		
 	char ADDR[200];
	u8 write[200];
	char judge[200];
	u8 datatemp[200];
	u8 begin=0;
	u8 end=0;
	u8 count=1;
	u8 t,i;
	u8 len=0;	
	u8 x=0,y=0;
	u8 m=0;
	u16 times=0;
	delay_init();	    	 
	NVIC_Configuration(); 	 
	uart_init(9600);	 
 	LED_Init();			     
	KEY_Init();          
	BEEP_Init();
	SPI_Flash_Init();
	LCD_Init();
	LCD_ShowString(20,20,200,16,16,"Welcome to Embedded System");
	LCD_ShowString(40,40,200,16,12,"     created by xyx ,hzy and xcl");
	LCD_ShowString(40,50,200,16,12,"     2020 10 29");
 	while(1)
	{
		if(USART_RX_STA&0x8000)
		{		   
			len=USART_RX_STA&0x3fff;//????????????
			printf("\r\n输入的指令是:\r\n\r\n");
			for(t=0;t<len;t++)
			{
			     c[t]=USART_RX_BUF[t];
				USART_SendData(USART1, USART_RX_BUF[t]);//???1????
				while(USART_GetFlagStatus(USART1,USART_FLAG_TC)!=SET);//??????
			}
			LCD_ShowString(40,70,200,16,16,"Your order is:");
			printf("\r\n\r\n");//????
			USART_RX_STA=0;
			USART_ClearFlag(USART1, USART_FLAG_RXNE);
			x=0;
             if(!(strcmp(c,"LED1=ON")))                 
               {
								 LCD_ShowString(40,90,200,16,16,"                         ");
                   LED1=0;           
                   LCD_ShowString(40,90,200,16,12,"LED1 ON");								 
                   memset(c,0,200);
                                                                                                    //???????
               }
             if(!(strcmp(c,"LED0=ON")))
               {
								 LCD_ShowString(40,90,200,16,16,"                             ");
                   LED0=0;  
                   LCD_ShowString(40,90,200,16,12,"LED0 ON");									 
				              x=1;                                                                   
                memset(c,0,200);  
               }
             if(!(strcmp(c,"BEEP=ON")))
                {
									LCD_ShowString(40,90,200,16,16,"                          ");
                  BEEP=1;  
                   LCD_ShowString(40,90,200,16,12,"BEEP ON,please be quiet");									
                  memset(c,0,200);
                }                                                                 
             if(!(strcmp(c,"LED1=OFF")))
                 {
									 LCD_ShowString(40,90,200,16,16,"                              ");
                   LED1=1;
									  LCD_ShowString(40,90,200,16,12,"LED1 OFF");
                  memset(c,0,200);
                 }                                                                        
             if(!(strcmp(c,"LED0=OFF")))
                {
									LCD_ShowString(40,90,200,16,16,"                           ");
                   LED0=1;
									 LCD_ShowString(40,90,200,16,12,"LED0 OFF");
				             x=1;
                  memset(c,0,200);
                 }
             if(!(strcmp(c,"BEEP=OFF")))
                 {
									 LCD_ShowString(40,90,200,16,16,"                        ");
                   BEEP=0;                                 
                    LCD_ShowString(40,90,200,16,12,"BEEP OFF");									 
                   memset(c,0,200);
                 }         
             if(!(strcmp(c,"ALLLED=ON")))
                  {
										LCD_ShowString(40,90,200,16,16,"                     ");
                   LED0=0;
                   LED1=0;
										 LCD_ShowString(40,90,200,16,12,"All LED ON");
				           x=1;
                   memset(c,0,200);
                  }
             if(!(strcmp(c,"ALLLED=OFF")))									    
                  {
										LCD_ShowString(40,90,200,16,16,"                      ");
                   LED0=1;
                   LED1=1;
										 LCD_ShowString(40,90,200,16,12,"All LED OFF");
				           x=1;
                   memset(c,0,200);
                 }
				    if(len>=12)
				        {
										 LCD_ShowString(40,120,200,16,16,"Write and Read order is");
				          printf("\r\n\r\n");
				     	    for(t=0;t<len;t++)
		         	       {
					             m=(u8)c[t];
				               if(m=='=')
					               { 
					                 begin=t;
					               }
					             if(m==',')
					               {
					                  end=t;
						                t=len;
					               }
		        	       }
					                for(i=begin+1;i<end;i++)
					                   {
					                     ADDR[i-begin-1]=c[i];
					                   }
					                for(i=end+1;i<len;i++)
					                   {
					                     write[i-end-1]=c[i];
					                   }  
						              for(i=len-3;i<len-1;i++)
							               {
								              judge[i-len+3]=c[i];
							               }
					       if(!strcmp(judge,"纸"))
					         {
									
										   LCD_ShowString(40,140,200,16,16,"                        ");
                      LCD_ShowString(40,150,200,16,16,"                       ");
                        LCD_ShowString(40,170,200,16,16,"                         ");
                           LCD_ShowString(40,180,200,16,16,"                       ");
                               LCD_ShowString(40,200,200,16,16,"                      ");		
										  LCD_ShowString(40,140,200,16,12,"Start Read W25Q64");
									    LCD_ShowString(40,150,200,16,12,"Chinese Characters may be errors!");
										 i=0;
										while(i<=len-end-1)
										{
											if((u8)write[i]>='0'&&(u8)write[i]<='9')
											{
												y=y*count+((u8)write[i]-'0');
												count=count*10;
                      }
											i++;
										}
					          //LCD_Fill(0,170,239,319,WHITE);//清除半屏   
                   								
				            SPI_Flash_Read(datatemp,(u32)ADDR,y);
										LCD_ShowString(40,170,200,16,12,"W25Q64 Read Finished!");	//提示传送完成
										LCD_ShowString(40,180,200,16,12,"That is:");
										LCD_ShowString(40,200,200,16,12,datatemp);
						         printf("ADDR=%s,读取数据为:%s\n",ADDR,datatemp);
					         }
					      else{
									  //LCD_Fill(0,170,239,319,WHITE);//清除半屏
									  LCD_ShowString(40,140,200,16,16,"                        ");
                      LCD_ShowString(40,150,200,16,16,"                       ");
                        LCD_ShowString(40,170,200,16,16,"                         ");
                           LCD_ShowString(40,180,200,16,16,"                       ");
                               LCD_ShowString(40,160,200,16,16,"                      ");		
                    printf("\r\nFLASH擦除中...\r\n");								
 			              LCD_ShowString(40,140,200,16,12,"Start Erase and Write W25Q64");
									    LCD_ShowString(40,150,200,16,12,"Chinese Characters may be errors!");
									    SPI_Flash_Erase_Chip();
					          SPI_Flash_Write((u8*)write,(u32)ADDR,len-end-1);	
									  LCD_ShowString(40,170,200,16,12,"W25Q64 Write Finished!");	//提示传送完成
									  LCD_ShowString(40,180,200,16,12,"That is:");
									  LCD_ShowString(40,200,200,16,12,write);
				       	     printf("FLASH擦除成功");
					           printf("\r\n\r\n");	
			               printf("ADDR=%s写入成功%d字节\n",ADDR,len-end-1);
					           printf("\r\n\r\n");
					          }
					           memset(c,0,200);
					          }
							}
		    else{
			times++;
			if(times==10)
			 {
			  printf("hello world\r\n我们是同济大学\r\n1852184谢远翔\r\n1850932何志扬\r\n1854084徐晨龙\r\n\r\n");
			 }
			
			if(times%5000==0)
			{
				printf("\r\n请问有什么问题吗？\r\n");
			} 
			if(times%30==0&&x==0)LED0=!LED0;//??LED,????????.
			delay_ms(10);   
		}
	}	 
 }
