//+------------------------------------------------------------------+
//|                                     connors 15M ADX breakout.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include  <MasterFile.mqh>

input double   TakeProfit       = 0.005;// enter take profit
input double   inSL              = 0.005;// inp stoploss
input double   inpTarget         = 0.3;// enter factor to multiply average daily range for take profit
input double   inpOrderSize      =  0.3;  //Order size for each order
input double   inpMagicNumber    =  123; //Magic number
input string   inpTradeComments  =  "Mconnors 15M ADX breakout";  //Trade comment

int static ticket=0;
double SignalBarHigh;
double SignalBarLow;

bool shortsignal,tradelong;

bool longsignal;

 
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
 
 
 
 double BuyStop= SignalBarLow-inSL;
 double SellStop= SignalBarHigh+inSL;
 double BuyProfit= SignalBarHigh+TakeProfit;
 double SellProfit= SignalBarLow-TakeProfit;
 
 //if (tradelong==false && Ask >SellStop ) 
   
   //   {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Ask,15,Red);
     //    if (Closedeal==true) ticket=0;}
      
    //  if ( tradelong==false   && Ask <SellProfit)
      //   {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Ask,15,Red);if (Closedeal==true) ticket=0;}
 
 
 //  if (tradelong==true && Bid<BuyStop) 
   //   {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Bid,15,Blue); if (Closedeal==true) ticket=0;}
      
      
 if (tradelong==true && Bid > BuyProfit)  
      {RefreshRates();bool Closedeal=OrderClose(ticket,inpOrderSize,Bid,15,Blue);if (Closedeal==true) ticket=0;}
 
 
  
 
 return;
 
 }


 if (!newBar()) return;  //only trade on new bar

if (Time[1]==iTime(Symbol(),PERIOD_M15,0))
// then bar [1] is the first bar  

   {
   
   SignalBarHigh= iHigh(Symbol(),PERIOD_M15,1);
   SignalBarLow=iLow(Symbol(),PERIOD_M15,1);
     
   
   }

// TakeProfit= (GetAveragePeriodRange6(PERIOD_D1)*inpTarget);

int ADX =iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN,1 );
double  b4plusdi = iADX(Symbol(),Period (), 14, PRICE_CLOSE, MODE_PLUSDI, 2);
double  nowplusdi = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_PLUSDI, 1);
double  b4minusdi = iADX(Symbol(), Period (), 14, PRICE_CLOSE, MODE_MINUSDI, 2);
double  nowminusdi = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MINUSDI, 1); 
   

if (nowplusdi>nowminusdi) longsignal=true; else longsignal=false;


if (nowplusdi<nowminusdi) shortsignal=true; else shortsignal=false;

if (longsignal==true && ticket==0&& ADX>30&& Ask>SignalBarHigh) 

   {ticket=orderOpen(ORDER_TYPE_BUY,0,0,inpOrderSize,inpTradeComments,inpMagicNumber);tradelong=true;

}

if (shortsignal==true && ticket==0&& ADX>30&& Bid< SignalBarLow)

 {ticket= orderOpen(ORDER_TYPE_SELL,0,0,inpOrderSize,inpTradeComments,inpMagicNumber);tradelong=false;

}
return;
     
    


   
  }
//+------------------------------------------------------------------+


 
   
   