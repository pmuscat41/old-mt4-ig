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
enum ENUM_CONDITION {  ENUM_CONDITION_NO_CONDITION,
                       ENUM_CONDITION_LONG_ABOVE_ADX,
                       ENUM_CONDITION_SHORT_ABOVE_ADX,
                       ENUM_CONDITION_BELOW_ADX,
                       ENUM_CONDITION_LONG_PULL_BACK,
                       ENUM_CONDITION_SHORT_PULL_BACK                       
                        };
string textMessage="UNDEFINED CONDITION";  
input double   inpOrderSize= 0.1;// Enter Order Size
input double   inpMinRiskReward=0.5;// Enter min Risk / Reward
input double   inpADXtrigger =20;// Enter ADX trigger to trade (30 default)

input string   inpTradeComments  =  "Holy Grail v3";  //Trade comment
input double   inpMagicNumber    =  123; //Magic number

ENUM_CONDITION PreviousCondition=ENUM_CONDITION_NO_CONDITION;
ENUM_CONDITION CurrentCondition;


bool WaitingForLong=false;
bool WaitingForShort=false;
bool inALongtrade=false;
double StopLoss,TradeEnterPrice;
bool LongPullback=false;
 int AdxCrossB4,Counter,CrossBar;
   bool longnow,longb4,tradeLong;
int AdxCross;

  int static Lookback=500;
datetime PullbackCandleTime;
double TriggerBar;
double TargetHigh;
int TradeOne;   
int TradeTwo;
bool FirstTrade=false;
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


if (inALongtrade==true)

{

OrderSelect(TradeOne,SELECT_BY_TICKET,MODE_TRADES);

if (OrderCloseTime()==0)return;
   
    WaitingForLong=false;
    inALongtrade=false;
    FirstTrade=false;
         PreviousCondition=ENUM_CONDITION_NO_CONDITION;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       return;
   
 

}






 if (WaitingForLong==true)
   
  {
  
   
   double ADX2 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
   
   if (ADX2<inpADXtrigger)
      {
         WaitingForLong==false;
         PreviousCondition=ENUM_CONDITION_NO_CONDITION;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       return;
      }
      
   if (iLow(Symbol(),Period(),1)<StopLoss)
      {
      StopLoss=iLow(Symbol(),Period(),1);
      DrawStopLoss(StopLoss);
      }   
   
   double RiskReward= (TargetHigh-TradeEnterPrice) / (TradeEnterPrice-StopLoss);
   Comment ("\nl Risk Reward on trade = " +NormalizeDouble(RiskReward,1));
   if (RiskReward<inpMinRiskReward)
      {
      WaitingForLong=false;
         PreviousCondition=ENUM_CONDITION_NO_CONDITION;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       return;
      }
   
   //// trade entry
   
   if (iClose(Symbol(),Period(),1)>TradeEnterPrice)
      {
      WaitingForLong==false;
      double tp= TargetHigh-TradeEnterPrice;
      double stpl= TradeEnterPrice-StopLoss;
      TradeOne= orderOpen(ORDER_TYPE_BUY,stpl,tp,inpOrderSize,inpTradeComments,inpMagicNumber);
      if (TradeOne>0) inALongtrade=true; else Comment("Error "+GetLastError()+" tp=  "+ tp+" SL= "+stpl);
      return;
      }
   
   
   
   return;
   }
   
 if (!newBar()) return;  //only trade on new bar
 
   double ADX = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);  
   double EMA= iMA(Symbol(),Period(),30,0,MODE_EMA,PRICE_MEDIAN,1);  
     double ADXnow = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
      double ADXb4 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 2);
      

CurrentCondition= GetCondition(PreviousCondition);
PreviousCondition=CurrentCondition;

if (CurrentCondition==ENUM_CONDITION_LONG_ABOVE_ADX)
   {   
      AdxCross = FindADXCrossUP (400);
      DrawVerticalLine (AdxCross);
   }


if (CurrentCondition==ENUM_CONDITION_SHORT_ABOVE_ADX)
   {   
      AdxCross = FindADXCrossUP (400);
      DrawVerticalLine (AdxCross);
   }

if (CurrentCondition==ENUM_CONDITION_LONG_PULL_BACK && FirstTrade==true)
   {
      TriggerBar= FindTriggerBar();
      StopLoss= GetSwingLow(TriggerBar);
      TradeEnterPrice = iHigh (Symbol(),Period(),TriggerBar+1);
       DrawStopLoss(StopLoss);
       DrawEntryPrice(TradeEnterPrice);
       AdxCross=FindADXCrossUP (400);
       TargetHigh=  FindPreviousHigh(AdxCross);
       DrawTargetHigh (AdxCross,TargetHigh);
       WaitingForLong=true;
   }


if (CurrentCondition==ENUM_CONDITION_BELOW_ADX)textMessage ="Currently Below ADX level";
if (CurrentCondition==ENUM_CONDITION_LONG_ABOVE_ADX) textMessage="Long position and above ADX,waiting for pullback";
if (CurrentCondition==ENUM_CONDITION_LONG_PULL_BACK)textMessage="Long position, above ADX and in a pullback";
if (CurrentCondition==ENUM_CONDITION_SHORT_ABOVE_ADX) textMessage="Short position, above ADX, waiting for pullback";  
if (CurrentCondition==ENUM_CONDITION_SHORT_PULL_BACK)textMessage="Short position,above ADX and in a pullback";
if (CurrentCondition==ENUM_CONDITION_NO_CONDITION)textMessage="UNDEFINED CONDITION";
     
    Comment (textMessage);  
       

  
  
  
  
  
  
  
  
   
}
//+------------------------------------------------------------------+

int FindADXCrossUP (int Lookback)


{
   
   for (int i=1;i<Lookback;i++)
   
   {
      double ADXnow = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, i);
      double ADXb4 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, i+1);
        
      if (ADXb4<inpADXtrigger && ADXnow>inpADXtrigger) return (i);
               
   
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
            ObjectSetInteger(0,"V1",OBJPROP_COLOR,clrLightGray);
            ObjectSetInteger(0, "V1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "V1",OBJPROP_RAY_RIGHT, false);
     
            return(shft);
} 

bool CheckifLong (int candle)

{       double nowplusdi = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_PLUSDI,candle);
        double nowminusdi = iADX(Symbol(), Period() ,14, PRICE_CLOSE, MODE_MINUSDI,candle);  
            if (nowplusdi> nowminusdi) return(true); else return (false);
            
            
}                 

bool CheckifShort (int candle)

{       double nowplusdi = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_PLUSDI,candle);
        double nowminusdi = iADX(Symbol(), Period() ,14, PRICE_CLOSE, MODE_MINUSDI,candle);  
            if (nowplusdi< nowminusdi) return(true); else return (false);
            
            
}                 



double GetSwingLow (int TriggerBar)

   {
   double currentLow;
   
   double MaxLow= iLow(Symbol(),Period(),1);
   
   for (int i=1; i<=TriggerBar+1;i++)
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
            ObjectSetInteger(0,"SL",OBJPROP_COLOR,clrDeepPink);
            ObjectSetInteger(0, "SL",OBJPROP_WIDTH,2);
            ObjectSetInteger(0, "SL",OBJPROP_RAY_RIGHT, true);
     
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
            ObjectSetInteger(0,"EP",OBJPROP_COLOR,clrSilver);
            ObjectSetInteger(0, "EP",OBJPROP_WIDTH,2);
            ObjectSetInteger(0, "EP",OBJPROP_RAY_RIGHT, true);
     
            return;
   
   }
   
ENUM_CONDITION GetCondition(ENUM_CONDITION OldCondition)
{

   
   double ADXprior = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 2);
   double ADX = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
   double EMA= iMA(Symbol(),Period(),30,0,MODE_EMA,PRICE_MEDIAN,1);    


  if (OldCondition==ENUM_CONDITION_LONG_ABOVE_ADX && ADX>inpADXtrigger && iLow(Symbol(),Period(),1)>EMA) 
  { return (ENUM_CONDITION_LONG_ABOVE_ADX);}
  
  
  if (OldCondition==ENUM_CONDITION_SHORT_ABOVE_ADX && ADX>inpADXtrigger && iHigh(Symbol(),Period(),1)<EMA) 
  { return (ENUM_CONDITION_SHORT_ABOVE_ADX);}
  

  if (
      OldCondition==ENUM_CONDITION_LONG_ABOVE_ADX &&
       iLow(Symbol(),Period(),1)< EMA && 
       ADX>inpADXtrigger)
       {PullbackCandleTime= Time [1];
       return(ENUM_CONDITION_LONG_PULL_BACK);}
       

  if (
      OldCondition==ENUM_CONDITION_SHORT_ABOVE_ADX &&
       iHigh(Symbol(),Period(),1)> EMA && 
       ADX>inpADXtrigger)
       {PullbackCandleTime=Time [1];
       return(ENUM_CONDITION_SHORT_PULL_BACK);}
       

  if (ADX>inpADXtrigger)
  
  {
  
      AdxCross = FindADXCrossUP (400);
      DrawVerticalLine (AdxCross);
  
  
  
  
  if (CheckifLong(AdxCross)==true) 
  { return (ENUM_CONDITION_LONG_ABOVE_ADX);}
  
  
  if (CheckifShort(AdxCross)==true) 
  {  return (ENUM_CONDITION_SHORT_ABOVE_ADX);}
  }
  
  if (ADX<inpADXtrigger) 
  {  ObjectDelete(0,"V1");
  FirstTrade=true;
  return (ENUM_CONDITION_BELOW_ADX);}
  
  
return (ENUM_CONDITION_NO_CONDITION);  
  
  }
  
double FindTriggerBar()

   {
   
   for (int i=1;i<30;i++)
   
      {
         if (PullbackCandleTime==Time[i]) return (i-1);
      
      }
     return (0); 
   
   }
   
double FindPreviousHigh (int cross)
   
   {
   double HighBar=iHigh (Symbol(),Period(),1);
   double newBar;
      for (int j=2;j<cross+1;j++)
         
            {
            newBar= iHigh (Symbol(),Period(),j);
            if (newBar>HighBar)HighBar=newBar;
            
            }
      
         return (HighBar);
   }
   
void DrawTargetHigh (double AdxCross, double TargetHigh)
   
   
    {
   
     datetime linestart;
   datetime lineend;
   
             linestart= iTime(Symbol(),Period(),AdxCross);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"HL");
            ObjectCreate ("HL",OBJ_TREND,0,
            linestart,TargetHigh, 
            lineend,TargetHigh);
            ObjectSetInteger(0,"HL",OBJPROP_COLOR,clrForestGreen);
            ObjectSetInteger(0, "HL",OBJPROP_WIDTH,2);
            ObjectSetInteger(0, "HL",OBJPROP_RAY_RIGHT, true);
     
            return;
   
   
   
   
   
   }