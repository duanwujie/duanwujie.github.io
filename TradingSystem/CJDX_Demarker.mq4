//+------------------------------------------------------------------+
//|                                             cjdx.mq4             |
//|                                                                  |
//|                                     dhacklove@163.com            |
//+------------------------------------------------------------------+
#property copyright "duanwujie"
#property link      "917357635@qq.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 11


/*
   VAR1:=(2*CLOSE+HIGH+LOW)/4;
   VAR2:=EMA(EMA(EMA(VAR1,4),4),4);
   J: (VAR2-REF(VAR2,1))/REF(VAR2,1)*100, COLORSTICK;
   D: MA(J,3);
   K: MA(J,1);
*/


input  int    ExtChoice            = 0;  //0:Demark,1:Stochastic,2:RSI,3:RVI
input  int    ExtDeMarker          = 25; //Based use DeMarker

input  int    ExtStochasticK       = 21; //The stochastice parameter
input  int    ExtStochasticD       = 3;  //The stochastice parameter
input  int    ExtStochasticJ       = 3;  //The stochastice parameter

input  int    ExtRSI               = 14; //The Rsi parameter


input  int    ExtXPeroid           = 16; //The Smoothed Peroid
input  int    ExtAdjust            = 100;//The Height value
input  int    ExtAfterSeconds      = 300;//Th interval seconds per warning.
input  int    ExtMaxMailAterTimes  = 5;  //Times of email warning
input  bool   EnableMailWaring     = true;//True to enable email warning
input  int    ExtEmaShift          = 0;




#property indicator_color1 clrWhite 
#property indicator_color2 clrYellow
#property indicator_color3 clrOrangeRed
#property indicator_color4 clrLime  
#property indicator_color5 clrOrangeRed
#property indicator_color6 clrLime  
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1


#property indicator_level1 0


#define BUY_DIRECTION 1
#define SELL_DIRECTION -1

double M0[];
double M1[];
double M2[];
double M3[];
double M4[];

double M5[];
double M6[];
double M7[];
double M8[];

double M9[];
double M10[];

datetime LastWaringDate;
bool     Noticed = false;
int      CurrentNoticedTimes = 0;
uint     LastTickCount  = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   string baseName = "";
   if(ExtChoice == 0)
      baseName = "Demarker";
   else if(ExtChoice == 1)
      baseName = "Stochastic";
  else if(ExtChoice == 1)
      baseName = "RSI";
   
   string indicatorName=baseName+" CJDX("+IntegerToString(ExtXPeroid)+")";
   IndicatorShortName(indicatorName);

   SetIndexBuffer(0,M5);
   SetIndexBuffer(1,M6);
   SetIndexBuffer(2,M7);
   SetIndexBuffer(3,M8);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   
   
   SetIndexBuffer(4,M9);
   SetIndexBuffer(5,M10);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   

   
   
   SetIndexBuffer(6,M0);
   SetIndexBuffer(7,M1);
   SetIndexBuffer(8,M2);
   SetIndexBuffer(9,M3);
   SetIndexBuffer(10,M4);
  
   SetIndexStyle(6,DRAW_NONE);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexStyle(8,DRAW_NONE);
   SetIndexStyle(9,DRAW_NONE);
   SetIndexStyle(10,DRAW_NONE);
   
   SetLevelValue(0,0);

   
   
   
      
   LastWaringDate = TimeCurrent();
   Noticed  = false;
   LastTickCount = 0;
   
   /*
   
   ObjectCreate("Line1",OBJ_HLINE,WindowsTotal()-1,0,Level1);
   ObjectCreate("Line2",OBJ_HLINE,WindowsTotal()-1,0,Level2);
   ObjectCreate("Line3",OBJ_HLINE,WindowsTotal()-1,0,Level3);
   ObjectCreate("Line4",OBJ_HLINE,WindowsTotal()-1,0,Level4);
   ObjectCreate("Line5",OBJ_HLINE,WindowsTotal()-1,0,Level5);
   
   ObjectSet("Line1",OBJPROP_COLOR,clrWhite);
   ObjectSet("Line2",OBJPROP_COLOR,clrRed);
   ObjectSet("Line3",OBJPROP_COLOR,clrRed);
   ObjectSet("Line4",OBJPROP_COLOR,clrLime);
   ObjectSet("Line5",OBJPROP_COLOR,clrLime);
   */

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   //static int old_bars;
   //if(old_bars == Bars) return(0);
   
   //int counted_bars = IndicatorCounted();
   //if(counted_bars>0) counted_bars--;
   double max_level = 0;
   double min_level = 0;
   
   int   counted_bars=IndicatorCounted();

   
   
   int limit = Bars - counted_bars;
      
    //M0[i]=(2*close[i] + high[i] + low[i])/4;
   
   if(ExtChoice == 0){
      limit = limit - ExtDeMarker;
      for(int i=0; i < limit; i++)
         M0[i] =iDeMarker(NULL,0,ExtDeMarker,i);
   }
   else if (ExtChoice == 1){
      limit = limit - ExtStochasticK;
      for(int i=0; i < limit; i++)
         M0[i] =iStochastic(NULL,0,ExtStochasticK,ExtStochasticD,ExtStochasticJ,MODE_SMA,0,MODE_MAIN,i);
   }
   else if (ExtChoice == 2){
      limit = limit - ExtRSI;
      for(int i=0; i < limit; i++)
         M0[i] =iRSI(NULL,0,ExtRSI,PRICE_CLOSE,i);
   }
   
   for(int i=0; i < limit; i++)
   {

      M1[i]=iMAOnArray(M0,0,ExtXPeroid,ExtEmaShift,MODE_EMA,i); 
   }
   
   for(int i=0; i < limit; i++)
   {
      M2[i]=iMAOnArray(M1,0,ExtXPeroid,ExtEmaShift,MODE_EMA,i); 
   }
   
   for(int i=0; i < limit; i++)
   {
      M3[i]=iMAOnArray(M2,0,ExtXPeroid,ExtEmaShift,MODE_EMA,i); 
   }
   
   
   for(int i=0;i<limit-1;i++)
   {
      M4[i] = ExtAdjust*M3[i]/M3[i+1]  - ExtAdjust;
      if(M4[i]>max_level)
      {
         max_level = M4[i];
      }
      if(M4[i]<min_level)
      {
         min_level = M4[i];
      }
   }
   
   
   for(int j=0;j<limit;j++)
   {
      M5[j] = iMAOnArray(M4,0,3,0,MODE_SMA,j);
      M6[j] = iMAOnArray(M4,0,1,0,MODE_SMA,j);
      if(M6[j]>0)
      {
         M9[j] = M6[j];
      }else
      {
         M10[j] = M6[j];
      }
   }

      
      
   for(int i=0;i<limit-1;i++)
   {
   

      M8[i] = EMPTY_VALUE;
      M7[i] = EMPTY_VALUE;
      if(Cross(M6[i+1],M5[i+1],M6[i],M5[i])>0)
      {
         if(M6[i]<0)
         {
            M7[i] = M6[i];
            if(EnableMailWaring)
            {
               if(i==0 || i == 1)
                  iWaring(0,BUY_DIRECTION,-ND(M6[i]*100/min_level,2));
            }
         }
          
      }
      
      if(Cross(M6[i+1],M5[i+1],M6[i],M5[i])<0)
      {
         if(M6[i]>0)
         {
            M8[i] = M6[i];
            if(EnableMailWaring){
               if(i==0 || i == 1)
                  iWaring(0,SELL_DIRECTION,ND(M6[i]*100/max_level,2));
            }
         }
      }
   }
   
   
   

   
   
   //old_bars = Bars;   
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+


int Cross(double iMaFastPrevious,double iMaSlowPrevious,double iMaFastCurrent,double iMaSlowCurrent)
{
   if (iMaFastPrevious<iMaSlowPrevious && iMaFastCurrent>iMaSlowCurrent )
      return 1;
   if (iMaFastPrevious>iMaSlowPrevious && iMaFastCurrent<iMaSlowCurrent )
      return -1;
    return 0;
}
//


double ND(double value,int digits)
{
   return NormalizeDouble(value,digits);
}

void iWaring(int shift,int direction,double percent)
{
   datetime current_time = iTime(NULL,PERIOD_CURRENT,shift);
   
   if(LastWaringDate < current_time)
   {
      Noticed = false;
      LastWaringDate = current_time;
      CurrentNoticedTimes  = 0;
   }
   if(!Noticed)
   {
      if(Event(ExtAfterSeconds))
      {
         CurrentNoticedTimes++;
         iSendEmail(direction,percent);
      }
      if(CurrentNoticedTimes == ExtMaxMailAterTimes)
      {
         Noticed = true;
      }
   }
}



int Event(uint seconds)
{

  uint currentTickCount = GetTickCount();
  
  if(currentTickCount - LastTickCount > seconds*1000)
  {
      LastTickCount = currentTickCount;
      return 1;
  }
  return false;
}
string PTT()
{
   int period =Period();
   if(period == PERIOD_H4)
      return "H4";
   if(period == PERIOD_H1)
      return "H1";
   if(period == PERIOD_M30)
      return "M20";
   if(period == PERIOD_M15)
      return "M15";
   if(period == PERIOD_M5)
      return "M4";
   if(period == PERIOD_D1)
      return "D1";
   if(period == PERIOD_W1)
      return "W1";
   return "Other";
}
void iSendEmail(int direction,double percent)
{

   double resistance = 0;
   double support = 0;
   if(direction < 0)
   {
      string msg = "CJDX SELL Signal occor at[" + DoubleToStr(percent,2)+"%] with price [" + DoubleToStr(Ask,4)+ "]\n";
      string subject = "SellSignal-"+Symbol()+"-"+PTT();
      SendMail(subject,msg);
   }
   if(direction > 0)
   {
      string msg = "CJDX BUY Signal occor at["  + DoubleToStr(percent,2)+"%] with price [" + DoubleToStr(Bid,4)+ "]\n";
      string subject = "BuySignal-"+Symbol()+"-"+PTT();
      SendMail(subject,msg);
   }
}