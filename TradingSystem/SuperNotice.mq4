//+------------------------------------------------------------------+
//|                                                  SuperNotice.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window



input  int    ExtAfterSeconds      = 1;//Th interval seconds per warning.
input  int    ExtMaxMailAterTimes  = 5;  //Times of email warning
input  bool   EnableMailWaring     = true;//True to enable email warning


#define BUY_DIRECTION 1
#define SELL_DIRECTION -1


datetime LastWaringDate;
bool     Noticed = false;
int      CurrentNoticedTimes = 0;
uint     LastTickCount  = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   LastWaringDate = TimeCurrent();
   Noticed  = false;
   LastTickCount = 0;
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
   double t1 = iCustom(NULL,PERIOD_CURRENT,"toptrend",4,0);
   double t2 = iCustom(NULL,PERIOD_CURRENT,"toptrend",5,0);
   
   
   double c1 = iCustom(NULL,PERIOD_CURRENT,"cjdx",0,0);
   double c2 = iCustom(NULL,PERIOD_CURRENT,"cjdx",1,0);
   double p1 = iCustom(NULL,PERIOD_CURRENT,"cjdx",0,1);
   double p2 = iCustom(NULL,PERIOD_CURRENT,"cjdx",1,1);
   

   int trend = 0;
         

   if(t1 < Bid && t2 > (EMPTY_VALUE-1))
   {      
      trend = 1;
      if(Cross(p2,p1,c2,c1)>0)
      {
         iWaring(0,BUY_DIRECTION,t1);//Notice
      }

   }
   if(t2 > Bid && t1 > (EMPTY_VALUE-1))
   {
      trend = -1;
      if(Cross(p2,p1,c2,c1)<0)
      {
         iWaring(0,SELL_DIRECTION,t2);//Notice
      }
   }
   
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
      string msg = "Toptrend+CJDX [SELL] \nStopLoss = " + DoubleToStr(percent,4) +"\nOpenPrice = " + DoubleToStr(Bid,4)+ "\n";
      string subject = "SellSignal-"+Symbol()+"-"+PTT();
      SendMail(subject,msg);
   }
   if(direction > 0)
   {
      string msg = "Toptrend+CJDX [BUY] \nStopLoss = " + DoubleToStr(percent,4) +"\nOpenPrice = " + DoubleToStr(Ask,4)+ "\n";
      string subject = "BuySignal-"+Symbol()+"-"+PTT();
      SendMail(subject,msg);
   }
}