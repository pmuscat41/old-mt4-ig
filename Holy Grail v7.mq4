//+------------------------------------------------------------------+
//|                                                   Holy Grail.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |


//  Great working version -only long trades -excellent trailing stop- variable parameters -great results

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
                       ENUM_CONDITION_SHORT_PULL_BACK,      
                       ENUM_CONDITION_WAITING_FOR_LONG_ENTRY,
                       ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET,
                       ENUM_CONDITION_IN_A_LONG_TRAILING_STOPS,                 
                        };
string static textMessage="UNDEFINED CONDITION";


input double   inpMinRiskReward=0.5;// Enter min Risk / Reward
input double  inpTPfactor = 2;// input factor to multply Swing High for TP
input double  inpMinADXPullback=3;// Minimum drop in ADX on pull back
input double  inMA=30;//input moving average for pullback
input       double  inpCashMin= 1000;//Enter minimum cash balance to trade 
input bool     inpTrailStop=true;// Trail stop (true/false) 
input double   inpOrderSize= 0.1;// Enter Order Size
input double   inpADXtrigger =30;// Enter ADX trigger to trade (30 default)
input int      inpMaxBarsPullback=   3; // Enter maximum bars at pullback
input string   inpTradeComments  =  "Holy Grail v7";  //Trade comment
input double   inpMagicNumber    =  123; //Magic number

ENUM_CONDITION static PreviousCondition=ENUM_CONDITION_NO_CONDITION;
ENUM_CONDITION static CurrentCondition;

  
double static StopLoss,TradeEnterPrice;

 int static AdxCrossB4,Counter,CrossBar;
   bool static longnow,longb4,tradeLong;
int static AdxCross;

  int static Lookback=500;
datetime static PullbackCandleTime;
double static TriggerBar;
double static TargetHigh;
int static TradeOne;   
int static TradeTwo;
bool static FirstTrade=false;
int static counter=0;
bool static er;

double static RiskReward=1;
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



if (!newBar()) return;  //only trade on new bar


 
   double static ADX = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);  
   double static EMA= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_HIGH,1);  
     double static ADXnow = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
      double static ADXb4 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 2);


if (CurrentCondition==ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET)
{inAlongTradeHeadingForTarget ();return;}

if (CurrentCondition==ENUM_CONDITION_WAITING_FOR_LONG_ENTRY)
{
waitingForLongEntry (); return; }

 
 ////----------------------------------------------------------------------------------------------------- MAIN PROGRAM PART
 
 
      

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
       CurrentCondition=ENUM_CONDITION_WAITING_FOR_LONG_ENTRY;
   }


if (CurrentCondition==ENUM_CONDITION_BELOW_ADX)textMessage ="Currently Below ADX level";
if (CurrentCondition==ENUM_CONDITION_LONG_ABOVE_ADX) textMessage="Long setup and above ADX,waiting for pullback";
if (CurrentCondition==ENUM_CONDITION_LONG_PULL_BACK)textMessage="Long setup, above ADX and in a pullback";
if (CurrentCondition==ENUM_CONDITION_SHORT_ABOVE_ADX) textMessage="Short setup , above ADX, waiting for pullback";  
if (CurrentCondition==ENUM_CONDITION_SHORT_PULL_BACK)textMessage="Short setup,above ADX and in a pullback";
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
   double EMA= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_MEDIAN,1);    


  if (OldCondition==ENUM_CONDITION_LONG_ABOVE_ADX && ADX>inpADXtrigger && iLow(Symbol(),Period(),1)>EMA) 
  { return (ENUM_CONDITION_LONG_ABOVE_ADX);}
  
  
  if (OldCondition==ENUM_CONDITION_SHORT_ABOVE_ADX && ADX>inpADXtrigger && iHigh(Symbol(),Period(),1)<EMA) 
  { return (ENUM_CONDITION_SHORT_ABOVE_ADX);}
  

  if (
      OldCondition==ENUM_CONDITION_LONG_ABOVE_ADX &&
       iLow(Symbol(),Period(),1)< EMA && 
       ADX>inpMinADXPullback)
       {PullbackCandleTime= Time [1];
       return(ENUM_CONDITION_LONG_PULL_BACK);}
       

  if (
      OldCondition==ENUM_CONDITION_SHORT_ABOVE_ADX &&
       iHigh(Symbol(),Period(),1)> EMA && 
       ADX>inpMinADXPullback)
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
   
void DrawTargetHigh (double AdxCross, double TargetHighx)
   
   
    {
   
     datetime linestart;
   datetime lineend;
   
             linestart= iTime(Symbol(),Period(),AdxCross);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"HL");
            ObjectCreate ("HL",OBJ_TREND,0,
            linestart,TargetHighx, 
            lineend,TargetHighx);
            ObjectSetInteger(0,"HL",OBJPROP_COLOR,clrForestGreen);
            ObjectSetInteger(0, "HL",OBJPROP_WIDTH,2);
            ObjectSetInteger(0, "HL",OBJPROP_RAY_RIGHT, true);
     
            return;
   
   
   
   
   
   }
   
void inAlongTradeHeadingForTarget ()


{
counter=counter+1;
Comment ("managing trade for "+ counter+ " bars");

double   MAStop= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_MEDIAN,1);
double   Mstop =NormalizeDouble(MAStop,Digits);

    OrderSelect(TradeOne,SELECT_BY_TICKET);
      
        double previousStop= OrderStopLoss();
        
Comment ("\nl MAstop = "+MAStop+"  Mstop=  "+Mstop+"  OrderStopLoss= "+previousStop+ "TrailingStop= " +inpTrailStop);
        
         if (iClose(Symbol(),Period(),1)>TargetHigh)
            if (inpTrailStop==true)
             if (previousStop<MAStop)
        
        { //OrderClose(TradeOne,OrderLots(),Ask,10,clrRed);
        er=OrderModify(TradeOne,OrderOpenPrice(),Mstop,OrderTakeProfit(),0,clrRed);
            if (er!=true) Comment ("Error = "+GetLastError()); else Comment ("Order modified");
         }



OrderSelect(TradeOne,SELECT_BY_TICKET,MODE_TRADES);
if (OrderCloseTime()==0)
      return;else
   
    {FirstTrade=false;
         CurrentCondition=ENUM_CONDITION_NO_CONDITION;
         PreviousCondition=ENUM_CONDITION_NO_CONDITION;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       counter=0;
       return;}
return;   
 

}


void waitingForLongEntry ()


  {
  
  
 double static ADX2 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
   
   
   if (ADX2<inpADXtrigger)
      {
         CurrentCondition=ENUM_CONDITION_NO_CONDITION;
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
   
   if (TradeEnterPrice-StopLoss!=0)  RiskReward= (TargetHigh-TradeEnterPrice) / (TradeEnterPrice-StopLoss);
   Comment ("\nl Risk Reward on trade = " +NormalizeDouble(RiskReward,1));
   if (RiskReward<inpMinRiskReward)
      {
      CurrentCondition=ENUM_CONDITION_NO_CONDITION;
         PreviousCondition=ENUM_CONDITION_NO_CONDITION;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       return;
      }
   
   //// trade entry
   
   if (iClose(Symbol(),Period(),1)>TradeEnterPrice && AccountFreeMargin()>inpCashMin)
      {
      
      double tp= TargetHigh-TradeEnterPrice;
      double stpl= TradeEnterPrice-StopLoss;
      
    
      TradeOne= orderOpen(ORDER_TYPE_BUY,stpl,tp*inpTPfactor,inpOrderSize,inpTradeComments,inpMagicNumber);
           
      if (TradeOne>0) CurrentCondition=ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET; else 
      
      {Comment("Error "+GetLastError()+" tp=  "+ tp+" SL= "+stpl);
      CurrentCondition=ENUM_CONDITION_WAITING_FOR_LONG_ENTRY;
      }
      return;
      }
   
   
   
   return;
   }
 