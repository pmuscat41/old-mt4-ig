//+------------------------------------------------------------------+
//|                                     connors 15M ADX breakout.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

/// v8 - great working version
///v 9 - trailing stop percentage
///v9 -  not working!!!!

#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include  <MasterFile.mqh>
#include  <MasterFile 2.mqh>

enum ENUM_TRADE_EXIT {
        TARGET_FIXED_STOP,
        TARGET_DYNANIC_STOP,    
        NO_TARGET_TRAILING_STOP};
        
        

input double   inHourtoTrade     = 8;// enter the hour to start trading
input ENUM_TRADE_EXIT     inpTradeExit     = TARGET_DYNANIC_STOP;// enter trade exit strategy
input double   inSL              = 0.005;// inp stoploss to add to trigger bar
input double   inpTarget         = 0.3;// enter factor to multiply average daily range for take profit
input double   inpTrailFrom=    50;// Enter profit at which to start trailing

input double   inpOrderSize      =  0.3;  //Order size for each order
input int   inpMagicNumber    =  123; //Magic number
input string   inpTradeComments  =  "Connors 15M ADX breakout v10";  //Trade comment

int static ticket=0;
double SignalBarHigh;
double SignalBarLow;

bool shortsignal,tradelong;

bool longsignal;
static bool SetTPSL=false;



 double TakeProfit;
 double TriggerLow;
 double TriggerHigh;
 double BuyProfit;
 double SellProfit;

 
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
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
 
 if (ticket>0)
 
 {
 /// manage trade 
 
 
 OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
 

 
 if (OrderCloseTime()!=0) {ticket=0;SetTPSL=false;};
 
  
 if (inpTradeExit==NO_TARGET_TRAILING_STOP && tradelong==true) {TrailingStop(inpMagicNumber,ticket,OrderOpenPrice()-TriggerLow);return;}
 if (inpTradeExit==NO_TARGET_TRAILING_STOP && tradelong==false) {TrailingStop(inpMagicNumber,ticket,TriggerHigh-OrderOpenPrice() );return;}
 
 if (inpTradeExit==TARGET_DYNANIC_STOP && OrderProfit()>inpTrailFrom) DynamicTrailingStop (inpMagicNumber,ticket);
  
 if (OrderCloseTime()!=0) {ticket=0;SetTPSL=false;}
 
 return;
 
 }


 if (!newBar()) return;  //only trade on new bar
 
 
 datetime openbar= Time[1];
 
 int openhour= TimeHour (openbar);
 int openminute= TimeMinute(openbar);
 
 int sessionhour= inHourtoTrade;
 int sessionminute= 0;


if (openhour==sessionhour && openminute==sessionminute)
// then bar [1] is the first bar  

   {
   
   SignalBarHigh= iHigh(Symbol(),PERIOD_M15,1);
   SignalBarLow=iLow(Symbol(),PERIOD_M15,1);
   
     
  TakeProfit= (GetAveragePeriodRange6(PERIOD_D1)*inpTarget);
  TriggerLow= SignalBarLow-inSL;
  TriggerHigh= SignalBarHigh+inSL;
  BuyProfit= TriggerHigh+TakeProfit;
  SellProfit= TriggerLow-TakeProfit;
  ObjectDelete (0,"trigger");
  ObjectCreate (0,"trigger",OBJ_TRIANGLE,0,Time[1],TriggerHigh);
  ObjectSetInteger(0,"trigger",OBJPROP_COLOR,clrBeige);
  ObjectSetInteger(0,"trigger",OBJPROP_WIDTH,9);
  
int ADX =iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN,1 );
double  nowplusdi = iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_PLUSDI, 0);
double  nowminusdi = iADX(Symbol(), PERIOD_D1 , 14, PRICE_CLOSE, MODE_MINUSDI, 0); 

Comment ("Daily ADX= "+ADX+ " longsignal = "+longsignal+ "        shortsignal= "+shortsignal);
Print("StopLevel = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));

if (nowplusdi>nowminusdi) longsignal=true; else longsignal=false;

if (nowplusdi<nowminusdi) shortsignal=true; else shortsignal=false;

if (longsignal==true && ticket<=0&& ADX>30) 

   { 
   // 4- BUY STOP
   
   
   
   DrawTPBand ("BTP_",TriggerHigh+TakeProfit);
   DrawTPBand("BSL_",TriggerLow);
   DrawTPBand("Bent",TriggerHigh);
   ticket=PendingOrderOpen(OP_BUYSTOP,inpOrderSize,inpTradeComments,inpMagicNumber, TriggerHigh,TriggerHigh-TriggerLow,TakeProfit,10800);tradelong=true;
   
   
   

 int count = 0;
            while ((ticket == -1) && (count < 10))
         {  Sleep (1000);
            RefreshRates();
              ticket=PendingOrderOpen(OP_BUYSTOP,inpOrderSize,inpTradeComments,inpMagicNumber, TriggerHigh,TriggerHigh-TriggerLow,TakeProfit,10800);tradelong=true;
   
             count++;
        
          }
   
   
   
   
   

}

if (shortsignal==true && ticket<=0&& ADX>30)

 {
 // 5= SELL STOP
   DrawTPBand ("STP_",TriggerLow-TakeProfit);
   DrawTPBand("sSL",TriggerHigh);
   DrawTPBand("Sent",TriggerLow);
 ticket= PendingOrderOpen(OP_SELLSTOP,inpOrderSize,inpTradeComments,inpMagicNumber, TriggerLow,TriggerHigh-TriggerLow,TakeProfit,0);tradelong=false;
 
 int count = 0;
            while ((ticket == -1) && (count < 10))
         {  Sleep (1000);
            RefreshRates();
              ticket= PendingOrderOpen(OP_SELLSTOP,inpOrderSize,inpTradeComments,inpMagicNumber, TriggerLow,TriggerHigh-TriggerLow,TakeProfit,0);tradelong=false;
 
             count++;
        
          }
   
   



}
return;
     
    }


   
  }
  
  
  
  
void SetTPandTP(double SL,double TP)

{

OrderModify(ticket,OrderOpenPrice(),NormalizeDouble (SL,Digits),NormalizeDouble (TP,Digits),0,0);
Print (" ___________________________________ SL = "+SL+"   TP=   "+ TP);
SetTPSL= false;
return;

}
//+------------------------------------------------------------------+


 
   
   