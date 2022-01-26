/**
* @par Copyright (C): 2010-2019, Shenzhen Yahboom Tech
* @file         app_linewalking.c	
* @author       liusen
* @version      V1.0
* @date         2017.07.17
* @brief        巡线模式运动
* @details      
* @par History  见如下说明
*                 
* version:		liusen_20170717
*/
#include "app_linewalking.h"
#include "bsp_linewalking.h"
#include "sys.h"
#include "app_motor.h"
#include "delay.h"

int Status=0;
/**
* Function       app_LineWalking
* @author        liusen
* @date          2017.07.20    
* @brief         巡线模式运动
* @param[in]     void
* @param[out]    void
* @retval        void
* @par History   无
*/

extern int adc_value;
void app_LineWalking(void)
{
	int LineL1 = 1, LineL2 = 1, LineR1 = 1, LineR2 = 1;

	bsp_GetLineWalking(&LineL1, &LineL2, &LineR1, &LineR2);	//获取黑线检测状态	

	if( (LineL1 == LOW || LineL2 == LOW) && LineR2 == LOW&& (adc_value<1500 || adc_value>1700)) //右大弯
    {
      	Car_SpinRight(3600, 3600);
		    delay_ms(266);
	  Status=1;
	
    } 
			else if ( LineL1 == LOW && (LineR1 == LOW || LineR2 == LOW)&& (adc_value<1500 || adc_value>1700)) //左大弯
		{ 
					Car_SpinLeft(3600, 3600);
			    delay_ms(266);
			Status=1;

			}  
					else if( LineL1 == LOW&& (adc_value<1500 || adc_value>1700) ) //左最外侧检测
								{  
									Car_SpinLeft(3000, 3000);
									delay_ms(20);
									Status=1;
								}
								else if ( LineR2 == LOW&& (adc_value<1500 || adc_value>1700)) //右最外侧检测
												{  
													Car_SpinRight(3000,3000);
													delay_ms(20);
													Status=1;
													}
												else if (LineL2 == LOW && LineR1 == HIGH && (adc_value<1500 || adc_value>1700)) //中间黑线上的传感器微调车左转
															{   
																Car_Left(3000); 
																Status=0;
																}
																else if (LineL2 == HIGH && LineR1 == LOW && (adc_value<1500 || adc_value>1700)) //中间黑线上的传感器微调车右转
																					{   
																							Car_Right(3000);  
																							Status=0;
																						}
																				else if(LineL2 == LOW && LineR1 == LOW) // 都是黑色, 加速前进
																						{  
																								Car_Run(3000);
																							  Status=0;
																							
																							}	
																								else{
																								//	if (flag==0)
																											//{
																									//Car_Back(1000);
																													//}
                                                     }
}
