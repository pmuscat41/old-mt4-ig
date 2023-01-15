//+------------------------------------------------------------------+
//|                                                   Holy Grail.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |


//  Great working version -short&  long trades -excellent trailing stop- variable parameters -great results
/// trade lot size selection based on risk percentage
///v11- good working example- traded a lot
///v12 - adding trailing stops'
//v16- updated orderentry price; changed execution of trailing &  dynamic stops & changed lot size in masterfile.... buy multipl 
/// v16- fixrd -buy errors and short position does not exit if pullback fails - compare master file and grail file with earlier versions
///v17- corrected position status print outs
/// v17-corrected min pull back of ADX



//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Paul Muscat"
#property link      "https://www.mql5.com"
#property version   "17.00"
#property strict
#include <MasterFile.mqh>
#include <MasterFile 2.mqh>

enum ENUM_CONDITION {  ENUM_CONDITION_NO_CONDITION,
                       ENUM_CONDITION_LONG_ABOVE_ADX,
                       ENUM_CONDITION_SHORT_ABOVE_ADX,
                       ENUM_CONDITION_BELOW_ADX,
                       ENUM_CONDITION_LONG_PULL_BACK,
                       ENUM_CONDITION_SHORT_PULL_BACK,      
                       ENUM_CONDITION_WAITING_FOR_LONG_ENTRY,
                       ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET,
                       ENUM_CONDITION_IN_A_LONG_TRAILING_STOPS,    
                       ENUM_CONDITION_IN_A_SHORT_HEADING_FOR_TARGET,     
                       ENUM_CONDITION_WAITING_FOR_SHORT_ENTRY,  
                       ENUM_CONDITION_FIRST_PULLBACK_COMPLETED      
                        };
string static textMessage="UNDEFINED CONDITION";

input double      inpPercentToRisk     = 2;// Enter percentage of account to risk on stoploss (1-2.5%)
input double      inpMinRiskReward     =0.0000001;// Enter min Risk / Reward ratio (0.0000001= not applicable(
input double      inpTPfactor           = 2;// input take profit factor as multiple of stoploss
input double      inpMinADXPullback     =28;// Minimum value of ADX on pull back
input double      inMA                  =20;//input moving average value for EMA
input double      inpCashMin      = 1000;//Enter minimum cash balance to trade 

input bool        inpdynamicstop        =true;// Activate dynamic stops? 
 bool        inpTrailStop         =true; // Activate trailing stop? 
input bool        inpsecondtrade        = true;//Activate second trade targeting high/low (true/false)

input double      inpADXtrigger        =30;// Enter ADX trigger to trade (30 default)

input string      inpTradeComments     =  "Holy Grail v17";  //Trade comment
input int      inpMagicNumber       =  123; //Magic number



ENUM_CONDITION static PreviousCondition=ENUM_CONDITION_NO_CONDITION;
ENUM_CONDITION static CurrentCondition;

  
double  StopLoss,StopLossShort,TradeEnterPrice,TradeEnterPriceShort;

 int static AdxCrossB4,Counter,CrossBar;
   bool static longnow,longb4,tradeLong;
int static AdxCross;

  int static Lookback=500;
datetime static PullbackCandleTime;
double static TriggerBar,TriggerBarShort;
double static TargetHigh,TargetLow;
int static TradeOne;   
int static TradeTwo;
bool static FirstTrade=false;

int static counter=0;
bool static er;

double static RiskReward=1;
double static RiskRewardShort=1;
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


printMessage ();

   double static ADX = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);  
   double static EMA= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_CLOSE,1);  
     double static ADXnow = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
      double static ADXb4 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 2);


// check for closed orders
if (TradeOne>0)

{

   OrderSelect(TradeOne,SELECT_BY_TICKET,MODE_TRADES);
      if (OrderCloseTime()!=0)
      
   
            {FirstTrade=false;
            TradeOne=0;
               CurrentCondition=ENUM_CONDITION_NO_CONDITION;
               PreviousCondition=ENUM_CONDITION_NO_CONDITION;
               ObjectDelete(0,"SL");
               ObjectDelete(0,"EP");
               ObjectDelete(0,"LL");
               printMessage();}
}




if (CurrentCondition==ENUM_CONDITION_WAITING_FOR_LONG_ENTRY)
{
waitingForLongEntry (); return; }



if (CurrentCondition==ENUM_CONDITION_WAITING_FOR_SHORT_ENTRY)
{
waitingForShortEntry (); return; }


// trailing stops

if ((CurrentCondition==ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET)&&
   (inpdynamicstop==false))

{inAlongTradeHeadingForTarget ();return;}


if ((CurrentCondition==ENUM_CONDITION_IN_A_SHORT_HEADING_FOR_TARGET)&&
(inpdynamicstop==false))
{inAshortTradeHeadingForTarget ();return;}

// dynamic stops

if (inpdynamicstop==true && CurrentCondition==ENUM_CONDITION_IN_A_SHORT_HEADING_FOR_TARGET){DynamicTrailingStop(inpMagicNumber,TradeOne);

return;}


if (inpdynamicstop==true && CurrentCondition==ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET){DynamicTrailingStop(inpMagicNumber,TradeOne);

return;}



 
 ////----------------------------------------------------------------------------------------------------- MAIN PROGRAM PART
 
 
      
// CHANGING CONDITIONS

CurrentCondition= GetCondition(PreviousCondition);
PreviousCondition=CurrentCondition;

printMessage();

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


if (CurrentCondition==ENUM_CONDITION_SHORT_PULL_BACK && FirstTrade==true)
   {
      TriggerBarShort= FindTriggerBar();
      StopLossShort= GetSwingHigh(TriggerBarShort);
       TradeEnterPriceShort = iLow (Symbol(),Period(),TriggerBarShort+1);
       DrawStopLoss(StopLossShort);
       DrawEntryPrice(TradeEnterPriceShort);
       AdxCross=FindADXCrossUP (400);
       TargetLow=  FindPreviousLow(AdxCross);
       DrawTargetLow (AdxCross,TargetLow);
       CurrentCondition=ENUM_CONDITION_WAITING_FOR_SHORT_ENTRY;
   }


printMessage();
  
  
  
  
  
  
  
   
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
            
            ObjectSetInteger(0, "V1",OBJPROP_WIDTH,4);
            ObjectSetInteger(0, "V1",OBJPROP_RAY_RIGHT, false);
     
     
   if (CurrentCondition==ENUM_CONDITION_LONG_ABOVE_ADX)ObjectSetInteger(0,"V1",OBJPROP_COLOR,clrGreen);
   
   if (CurrentCondition==ENUM_CONDITION_SHORT_ABOVE_ADX)ObjectSetInteger(0,"V1",OBJPROP_COLOR,clrRed);
   
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



double GetSwingHigh (int TriggerBarx)

   {
   double currentHigh;
   
   double MaxHigh= iHigh(Symbol(),Period(),1);
   
   for (int p=1; p<=TriggerBarx+1;p++)
      {
          currentHigh= iHigh (Symbol(),Period(),p);
          if (currentHigh>MaxHigh)MaxHigh=currentHigh; 
      
      }
   
   return (MaxHigh);
   
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
   double EMA= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_CLOSE,1);    



  if (ADX>inpADXtrigger && ADXprior<inpADXtrigger)
  
  {
  
      AdxCross = FindADXCrossUP (400);
      DrawVerticalLine (AdxCross);
  
  
  
  
  if (CheckifLong(AdxCross)==true) 
  { FirstTrade=true;
  return (ENUM_CONDITION_LONG_ABOVE_ADX);}
  
  
  if (CheckifShort(AdxCross)==true) 
  {  FirstTrade=true;  
  return (ENUM_CONDITION_SHORT_ABOVE_ADX);}
  }
  
  if (ADX<inpADXtrigger) 
  {  ObjectDelete(0,"V1");
  
  return (ENUM_CONDITION_BELOW_ADX);}

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
       


  if (OldCondition==ENUM_CONDITION_LONG_ABOVE_ADX && ADX>inpADXtrigger && iLow(Symbol(),Period(),1)>EMA) 
  { return (ENUM_CONDITION_LONG_ABOVE_ADX);}
  
  
  if (OldCondition==ENUM_CONDITION_SHORT_ABOVE_ADX && ADX>inpADXtrigger && iHigh(Symbol(),Period(),1)<EMA) 
  { return (ENUM_CONDITION_SHORT_ABOVE_ADX);}
  


  
return (OldCondition);  
  
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
   double newBary;
      for (int j=2;j<cross+1;j++)
         
            {
            newBary= iHigh (Symbol(),Period(),j);
            if (newBary>HighBar)HighBar=newBary;
            
            }
      
         return (HighBar);
   }
 
    
double FindPreviousLow (int cross)
   
   {
   double LowBar=iLow (Symbol(),Period(),1);
   double newBarx;
      for (int k=2;k<cross+1;k++)
         
            {
            newBarx= iLow (Symbol(),Period(),k);
            if (newBarx<LowBar)LowBar=newBarx;
            
            }
      
         return (LowBar);
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
   
   
   void DrawTargetLow (double AdxCross, double TargetLowx)
   
   
    {
   
     datetime linestart;
   datetime lineend;
   
             linestart= iTime(Symbol(),Period(),AdxCross);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"LL");
            ObjectCreate ("LL",OBJ_TREND,0,
            linestart,TargetLowx, 
            lineend,TargetLowx);
            ObjectSetInteger(0,"LL",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "LL",OBJPROP_WIDTH,2);
            ObjectSetInteger(0, "LL",OBJPROP_RAY_RIGHT, true);
     
            return;
   
   
   
   
   
   }
   
   
   
   
   
   
   
   
   
void inAlongTradeHeadingForTarget ()


{
counter=counter+1;
Comment ("managing trade for "+ counter+ " bars");

double   MAStop= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_MEDIAN,1);
double   Mstop =NormalizeDouble(MAStop,Digits);

    OrderSelect(TradeOne,SELECT_BY_TICKET,MODE_TRADES);
      
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
    TradeOne=0;
    
         CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
         PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       printMessage();
       counter=0;
       return;}
return;   
 

}






void waitingForLongEntry ()


  {
  
  
 double static ADX2 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
   
   
   if (ADX2<inpADXtrigger)
      {
         CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
         PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
       printMessage();
       FirstTrade=false;
       return;
      }
      
   if (iLow(Symbol(),Period(),1)<StopLoss)
      {
      StopLoss=iLow(Symbol(),Period(),1);
      DrawStopLoss(StopLoss);
      }   
   
  
   
   //// trade entry
   
   if (
         (iClose(Symbol(),Period(),1)>TradeEnterPrice) && 
         (AccountFreeMargin()>inpCashMin))
      {
      
      TradeEnterPrice=iClose(Symbol(),Period(),1);
      double tp= TargetHigh-TradeEnterPrice;
      double stpl= TradeEnterPrice-StopLoss;
      
      //if (stpl<MarketInfo(Symbol(),MODE_STOPLEVEL)) stpl=MarketInfo(Symbol(),MODE_STOPLEVEL); 
      
        if (TradeEnterPrice-StopLoss!=0)  RiskReward= (TargetHigh-TradeEnterPrice) / (TradeEnterPrice-StopLoss);
            Comment ("\nl Risk Reward on trade = " +NormalizeDouble(RiskReward,1));
       if (RiskReward<inpMinRiskReward)
            {
                CurrentCondition=ENUM_CONDITION_NO_CONDITION;
                  PreviousCondition=ENUM_CONDITION_NO_CONDITION;
                  ObjectDelete(0,"SL");
                   ObjectDelete(0,"EP");
                   ObjectDelete(0,"HL");
                   printMessage();
                    return;
                  }
      
      
      double LotsToTrade = CalculateLotsize (stpl,inpPercentToRisk,inpCashMin);
      
      double Lots;
      
      if (inpsecondtrade==true)   Lots= NormalizeDouble(LotsToTrade/2,2);
      else Lots= NormalizeDouble(LotsToTrade,2);
      PrintFormat ("Lots= "+Lots+" stoploss= "+stpl+" tp=  "+tp*inpTPfactor);
      
      TradeOne= orderOpen(ORDER_TYPE_BUY,stpl,tp*inpTPfactor,Lots,inpTradeComments,inpMagicNumber);
      
      if (inpsecondtrade==true) TradeTwo= orderOpen(ORDER_TYPE_BUY,stpl,tp,Lots,inpTradeComments,inpMagicNumber);
      if (TradeOne>0) 
      
            {CurrentCondition=ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET;
            printMessage();
            clearLines();}
      
       else 
      
            {Comment("Error "+GetLastError()+"trade lots =  "+ Lots+ "  tp=  "+ tp*inpTPfactor+" SL= "+stpl);
            CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
            PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
            FirstTrade=false;
            clearLines();
            printMessage();
              }
      return;
      }
   
   
   
   return;
   }
 
 
 
 
 
 
 
 

void waitingForShortEntry ()


  {
  
  
 double  ADX3 = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
   
   
   if (ADX3<inpADXtrigger)
      {
         CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
         PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"LL");
       FirstTrade=false;
       printMessage();
       return;
      }
      
   if (iHigh(Symbol(),Period(),1)>StopLossShort)
      {
      StopLossShort=iHigh(Symbol(),Period(),1);
      DrawStopLoss(StopLossShort);
      }   
   
  
   
   //// trade entry
   
   if ((iClose(Symbol(),Period(),1)<TradeEnterPriceShort)&&(AccountFreeMargin()>inpCashMin))
      {
      
      double tpShort= TradeEnterPriceShort-TargetLow;
      double stplShort= StopLossShort- TradeEnterPriceShort;
      
      TradeEnterPrice= iClose(Symbol(),Period(),1);
      
      
      
      
      
      
      //if (stpl<MarketInfo(Symbol(),MODE_STOPLEVEL)>stpl) stpl=MarketInfo(Symbol(),MODE_STOPLEVEL);
      
       if (StopLossShort-TradeEnterPriceShort!=0)  RiskRewardShort= (TradeEnterPriceShort-TargetLow) / (StopLossShort-TradeEnterPriceShort);
   Comment ("\nl Risk Reward on trade = " +NormalizeDouble(RiskRewardShort,1));
   if (RiskRewardShort<inpMinRiskReward)
      {
     CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
       PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
     ObjectDelete(0,"SL");
     ObjectDelete(0,"EP");
     ObjectDelete(0,"LL");
     printMessage();
     FirstTrade=false;
     return;
    }
      
      
      double LotsToTrade = CalculateLotsize (stplShort,inpPercentToRisk,inpCashMin);
      double Lots;
      
      if (inpsecondtrade==true) Lots= NormalizeDouble(LotsToTrade/2,2);
      else Lots= NormalizeDouble(LotsToTrade,2);
      
      PrintFormat ("Lots= "+Lots+" stoploss= "+stplShort+ " take prof= "+tpShort*inpTPfactor);
      
      TradeOne= orderOpen(ORDER_TYPE_SELL,stplShort,tpShort*inpTPfactor,Lots,inpTradeComments,inpMagicNumber);
      
      if (inpsecondtrade==true)  TradeTwo= orderOpen(ORDER_TYPE_SELL,stplShort,tpShort,Lots,inpTradeComments,inpMagicNumber);
      
      if (TradeOne>0) 
      
         {CurrentCondition=ENUM_CONDITION_IN_A_SHORT_HEADING_FOR_TARGET;
         clearLines();
         printMessage();
         }
      
       else 
      
      {Print("Error "+GetLastError()+" tp=  "+ tpShort*inpTPfactor+" SL= "+stplShort);
      CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
      PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
      FirstTrade=false;
      clearLines();
      printMessage();
      }
      return;
      }
   
   
   
   return;
   }
 
 
 
 
   
   
void inAshortTradeHeadingForTarget ()


{
int counterx;
counterx=counterx+1;
Comment ("managing trade for "+ counterx+ " bars");

double   MAStopx= iMA(Symbol(),Period(),inMA,0,MODE_EMA,PRICE_MEDIAN,1);
double   Mstopx =NormalizeDouble(MAStopx,Digits);

    OrderSelect(TradeOne,SELECT_BY_TICKET,MODE_TRADES);
      
        double previousStopx= OrderStopLoss();
        
Comment ("\nl MAstop = "+MAStopx+"  Mstop=  "+Mstopx+"  OrderStopLoss= "+previousStopx+ "TrailingStop= " +inpTrailStop);
        
         if (iClose(Symbol(),Period(),1)<TargetLow)
            if (inpTrailStop==true)
             if (previousStopx>MAStopx)
        
        { //OrderClose(TradeOne,OrderLots(),Ask,10,clrRed);
        er=OrderModify(TradeOne,OrderOpenPrice(),Mstopx,OrderTakeProfit(),0,clrRed);
            if (er!=true) Comment ("Error = "+GetLastError()); else Comment ("Order modified");
         }



OrderSelect(TradeOne,SELECT_BY_TICKET,MODE_TRADES);
if (OrderCloseTime()==0)
      return;else
   
    {FirstTrade=false;
    TradeOne=0;
         CurrentCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
         PreviousCondition=ENUM_CONDITION_FIRST_PULLBACK_COMPLETED;
       ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"LL");
       counter=0;
       printMessage();
       return;}
return;   
 

}


void printMessage ()

{

if (CurrentCondition==ENUM_CONDITION_BELOW_ADX)textMessage ="Currently Below ADX level";
if (CurrentCondition==ENUM_CONDITION_LONG_ABOVE_ADX) textMessage="Long setup and above ADX,waiting for pullback";
if (CurrentCondition==ENUM_CONDITION_LONG_PULL_BACK)textMessage="Long setup, above ADX and in a pullback";
if (CurrentCondition==ENUM_CONDITION_SHORT_ABOVE_ADX) textMessage="Short setup , above ADX, waiting for pullback";  
if (CurrentCondition==ENUM_CONDITION_SHORT_PULL_BACK)textMessage="Short setup,above ADX and in a pullback";
if (CurrentCondition==ENUM_CONDITION_NO_CONDITION)textMessage="UNDEFINED CONDITION";
if (CurrentCondition==ENUM_CONDITION_FIRST_PULLBACK_COMPLETED)textMessage="FIRST PULLBACK COMPLETED/FAILED- NO TRADE TILL ADX CROSSES AGAIN!";
  
if (CurrentCondition==ENUM_CONDITION_WAITING_FOR_LONG_ENTRY) textMessage="Waiting for long entry";
if (CurrentCondition==ENUM_CONDITION_IN_A_LONG_HEADING_FOR_TARGET) textMessage= "In a long position heading for firt target";
if (CurrentCondition==ENUM_CONDITION_IN_A_LONG_TRAILING_STOPS)textMessage="in a long postion - trailing stops";    
if (CurrentCondition== ENUM_CONDITION_IN_A_SHORT_HEADING_FOR_TARGET) textMessage="in a short position heading for first target";     
if (CurrentCondition== ENUM_CONDITION_WAITING_FOR_SHORT_ENTRY) textMessage="Waiting for short entry";
 



 double  ADX_ = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MAIN, 1);
     
    Comment (textMessage);
    Comment("/n current ADX is= "+ADX_+ "must stay above "+inpADXtrigger+ "  to trade");
 return;
 }
 
 
 void clearLines ()

  {
        ObjectDelete(0,"SL");
       ObjectDelete(0,"EP");
       ObjectDelete(0,"HL");
  
  return;
  }