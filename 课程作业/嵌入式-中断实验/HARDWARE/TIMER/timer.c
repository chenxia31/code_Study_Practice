#include "timer.h"
#include "led.h"
#include "dac.h"
int Sine12bit[288] = {2049,2076,2103,2130,2157,2184,2211,2238,2265,2292,2318,2345,2371,2397,2423,2449,2475,2500,2525,2550,2575,2600,2624,2648,2671,2695,2718,2741,2763,2785,2807,2828,2849,2870,2890,2910,2929,2948,2966,2985,3002,3019,3036,3052,3068,3083,3098,3112,3126,3139,3152,3164,3176,3187,3198,3208,3217,3226,3234,3242,3249,3256,3262,3268,3272,3277,3280,3284,3286,3288,3289,3290,3290,3290,3289,3287,3285,3282,3279,3275,3270,3265,3259,3253,3246,3238,3230,3222,3213,3203,3193,3182,3170,3158,3146,3133,3119,3105,3091,3076,3060,3044,3028,3011,2993,2976,2957,2939,2919,2900,2880,2859,2839,2817,2796,2774,2752,2729,2706,2683,2660,2636,2612,2587,2563,2538,2513,2487,2462,2436,2410,2384,2358,2331,2305,2278,2251,2225,2198,2171,2144,2116,2089,2062,2035,2008,1981,1953,1926,1899,1872,1846,1819,1792,1766,1739,1713,1687,1661,1635,1610,1584,1559,1534,1510,1485,1461,1437,1414,1391,1368,1345,1323,1301,1280,1258,1238,1217,1197,1178,1158,1140,1121,1104,1086,1069,1053,1037,1021,1006,992,978,964,951,939,927,915,904,894,884,875,867,859,851,844,838,832,827,822,818,815,812,810,808,807,807,807,808,809,811,813,817,820,825,829,835,841,848,855,863,871,880,889,899,910,921,933,945,958,971,985,999,1014,1029,1045,1061,1078,1095,1112,1131,1149,1168,1187,1207,1227,1248,1269,1290,1312,1334,1356,1379,1402,1426,1449,1473,1497,1522,1547,1572,1597,1622,1648,1674,1700,1726,1752,1779,1805,1832,1859,1886,1913,1940,1967,1994,2021,2049};	 
int j=0;
//////////////////////////////////////////////////////////////////////////////////	 
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK战舰STM32开发板
//定时器 驱动代码	   
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//修改日期:2012/9/3
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2009-2019
//All rights reserved									  
//////////////////////////////////////////////////////////////////////////////////   	 

//通用定时器3中断初始化
//这里时钟选择为APB1的2倍，而APB1为36M
//arr：自动重装值。
//psc：时钟预分频数
//这里使用的是定时器3!
void TIM3_Int_Init(u16 arr,u16 psc)
{
    TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
	NVIC_InitTypeDef NVIC_InitStructure;

	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE); //时钟使能
	
	//定时器TIM3初始化
	TIM_TimeBaseStructure.TIM_Period = arr; //设置在下一个更新事件装入活动的自动重装载寄存器周期的值	
	TIM_TimeBaseStructure.TIM_Prescaler =psc; //设置用来作为TIMx时钟频率除数的预分频值
	TIM_TimeBaseStructure.TIM_ClockDivision = TIM_CKD_DIV1; //设置时钟分割:TDTS = Tck_tim
	TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;  //TIM向上计数模式
	TIM_TimeBaseInit(TIM3, &TIM_TimeBaseStructure); //根据指定的参数初始化TIMx的时间基数单位
 
	TIM_ITConfig(TIM3,TIM_IT_Update,ENABLE ); //使能指定的TIM3中断,允许更新中断

	//中断优先级NVIC设置
	NVIC_InitStructure.NVIC_IRQChannel = TIM3_IRQn;  //TIM3中断
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;  //先占优先级0级
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 3;  //从优先级3级
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE; //IRQ通道被使能
	NVIC_Init(&NVIC_InitStructure);  //初始化NVIC寄存器


	TIM_Cmd(TIM3, ENABLE);  //使能TIMx					 
}
//定时器3中断服务程序
void TIM3_IRQHandler(void)   //TIM3中断
{
	if (TIM_GetITStatus(TIM3, TIM_IT_Update) != RESET)  //检查TIM3更新中断发生与否
		{
		TIM_ClearITPendingBit(TIM3, TIM_IT_Update  );  //清除TIMx更新中断标志 
		LED0=!LED0;
		}
}

void TIM4_Int_Init(u16 arr,u16 psc)
{
    TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
	NVIC_InitTypeDef NVIC_InitStructure;

	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE); //时钟使能
	
	//定时器TIM4初始化
	TIM_TimeBaseStructure.TIM_Period = arr; //设置在下一个更新事件装入活动的自动重装载寄存器周期的值	
	TIM_TimeBaseStructure.TIM_Prescaler =psc; //设置用来作为TIMx时钟频率除数的预分频值
	TIM_TimeBaseStructure.TIM_ClockDivision = TIM_CKD_DIV1; //设置时钟分割:TDTS = Tck_tim
	TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;  //TIM向上计数模式
	TIM_TimeBaseInit(TIM4, &TIM_TimeBaseStructure); //根据指定的参数初始化TIMx的时间基数单位
 
	TIM_ITConfig(TIM4,TIM_IT_Update,ENABLE ); //使能指定的TIM3中断,允许更新中断

	//中断优先级NVIC设置
	NVIC_InitStructure.NVIC_IRQChannel = TIM4_IRQn;  //TIM3中断
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;  //先占优先级0级
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 3;  //从优先级3级
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE; //IRQ通道被使能
	NVIC_Init(&NVIC_InitStructure);  //初始化NVIC寄存器


	TIM_Cmd(TIM4, ENABLE);  //使能TIMx					 
}
//定时器4中断服务程序
void TIM4_IRQHandler(void)   //TIM4中断
{
	if (TIM_GetITStatus(TIM4, TIM_IT_Update) != RESET)  //检查TIM3更新中断发生与否
		{
		TIM_ClearITPendingBit(TIM4, TIM_IT_Update  );  //清除TIMx更新中断标志 
		DAC->DHR12R1=Sine12bit[j];
			j++;
			if(j==288)j=0;
		}
}















