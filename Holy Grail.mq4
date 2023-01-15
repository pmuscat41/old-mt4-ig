//+------------------------------------------------------------------+
//|                                                   Holy Grail.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <MasterFile.mqh>


input int      inpMaxBarsPullback=   3; // Enter maximum bars at pullback
input string   inpTradeComments  =  "Camarilla trend entry v1";  //Trade comment
input double   inpMagicNumber    =  123; //Magic number


bool WaitingForLong, WaitingForShort;
double StopLoss,TradeEnterPrice, LongPullback;
 int AdxCross,AdxCrossB4,Counter;
   bool longnow,longb4,tradeLong;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

ObjectDelete(0,"V1");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

 if (WaitingForLong==true)
   
  { DrawStopLoss(StopLoss);
   DrawEntryPrice(TradeEnterPrice);
   
   int static bar=0;
   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result =      (currentTime!=priorTime); //Time has changed
   priorTime               =        currentTime; //reset for next time
   
   if (result==false) bar=bar+1;
   
   if (bar>inpMaxBarsPullback) 
      {
         WaitingForLong=false;
         AdxCross=-1;
         LongPullback=false;
       Counter=0;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
         
      }
   }
   
 if (!newBar()) return;  //only trade on new bar
 
   double ADX = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);  
   double EMA= iMA(Symbol(),Period(),30,0,MODE_EMA,PRICE_MEDIAN,1);      
  
  AdxCross = FindADXCrossUP (inpMaxBarsPullback*2); // check candle when ADX crosses
  if (AdxCross>0) DrawVerticalLine (AdxCross); // Draw line at ADX cross
  if (AdxCross>0) tradeLong=CheckifLong(AdxCross);
  if (AdxCross<0) ObjectDelete(0,"V1");
   
   if (tradeLong==true && iLow(Symbol(),Period(),1)< EMA)
      {LongPullback=true; AdxCrossB4=AdxCross; Counter=0;
      return;}
 
   if (LongPullback==true) Counter=Counter+1;
   
   if (Counter>= inpMaxBarsPullback) 
      {LongPullback=false;
       Counter=0;
       WaitingForLong=false;
       tradeLong=false;
       AdxCross=-1;
       ObjectDelete(0,"V1");}
   
   if (LongPullback==true && iClose(Symbol(),Period(),1)>EMA)
      {
         //price pulled back and now above EMA again
         WaitingForLong= true;
         GetSwingLow (Counter);
         StopLoss= GetSwingLow(Counter);
         TradeEnterPrice = iHigh (Symbol(),Period(),Counter);return;
      }
 

  
  
  
  
  
  
  
  
   
}
//+------------------------------------------------------------------+

int FindADXCrossUP (int Lookback)


{
   
   for (int i=1;i<Lookback;i++)
   
   {
      double ADXnow = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, i);
      double ADXb4 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, i+1);
        
      if (ADXb4<30 && ADXnow>30) return (i);
               
   
   }
   return (0);
   
   
}


int DrawVerticalLine (int shft)

{
   datetime linestart;
   datetime lineend;
   
             linestart= iTime(Symbol(),Period(),shft);
             lineend = iTime(Symbol(),Period(),shft);
            ObjectDelete(0,"V1");
            ObjectCreate ("V1",OBJ_TREND,0,
            linestart,iClose(Symbol(),Period(),shft)/2, 
            lineend,iClose(Symbol(),Period(),shft)*2);
            ObjectSetInteger(0,"V1",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "V1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "V1",OBJPROP_RAY_RIGHT, false);
     
            return(shft);
} 

bool CheckifLong (int Shift)

{       double nowplusdi = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_PLUSDI, Shift);
        double nowminusdi = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MINUSDI, Shift);  
            if (nowplusdi> nowminusdi) 
               { 
               Comment ("Looking for long trades");
               return(true);
               }else
                  { Comment ("Looking for short trades");
                  return (false);};
            
            
}                 

double GetSwingLow (int Counter)

   {
   double currentLow;
   
   double MaxLow= iLow(Symbol(),Period(),1);
   
   for (int i=1; i<=Counter+1;i++)
      {
          currentLow= iLow (Symbol(),Period(),i);
          if (currentLow<=MaxLow)MaxLow=currentLow; 
      
      }
   
   return (MaxLow);
   
   }
   
   
void   DrawStopLoss(double StopLoss)
   
   {
   
   datetime linestart;
   datetime lineend;
   
             linestart= iTime(Symbol(),Period(),3);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"SL");
            ObjectCreate ("SL",OBJ_TREND,0,
            linestart,StopLoss, 
            lineend,StopLoss);
            ObjectSetInteger(0,"SL",OBJPROP_COLOR,clrLawnGreen);
            ObjectSetInteger(0, "SL",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "SL",OBJPROP_RAY_RIGHT, false);
     
            return;
   }
   
   
 void DrawEntryPrice(double TradeEnterPrice)
   
   {
   
     datetime linestart;
   datetime lineend;
   
             linestart= iTime(Symbol(),Period(),3);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"EP");
            ObjectCreate ("EP",OBJ_TREND,0,
            linestart,TradeEnterPrice, 
            lineend,TradeEnterPrice);
            ObjectSetInteger(0,"EP",OBJPROP_COLOR,clrLawnGreen);
            ObjectSetInteger(0, "EP",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "EP",OBJPROP_RAY_RIGHT, false);
     
            return;
   
   }