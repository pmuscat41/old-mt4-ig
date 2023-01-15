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

input double   inpTarget         = 0.3;// enter factor to multiply average daily range for take profit
input double   inpOrderSize      =  0.3;  //Order size for each order
input double   inpMagicNumber    =  123; //Magic number
input string   inpTradeComments  =  "Mconnors 15M ADX breakout";  //Trade comment

int static ticket=0;
double SignalBarHigh;
double SignalBarLow;
double TakeProfi;

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
 
 
 OrderSelect(ticket,SELECT_BY_TICKET);
 
 if (OrderType()== ORDER_TYPE_SELL)
   if (Ask > SignalBarHigh) 
      bool Closedeal=OrderClose(ticket,OrderLots(),Ask,3,Red);else
      
      if (OrderType()== ORDER_TYPE_SELL)
         if (Ask <OrderOpenPrice()-TakeProfit)
         bool Closedeal=OrderClose(ticket,OrderLots(),Ask,3,Red);
 
 
 if (OrderType()== ORDER_TYPE_BUY)
   if (Bid < SignalBarLow) 
      bool Closedeal=OrderClose(ticket,OrderLots(),Bid,3,Blue); else
      
      
 if (OrderType()== ORDER_TYPE_BUY)
   if (Bid > OrderOpenPrice()+TakeProfit) ) 
      bool Closedeal=OrderClose(ticket,OrderLots(),Bid,3,Blue);
 
 
 
 
if (Time[0]==iTime(Symbol(),PERIOD_M15,0))

// then bar [0] is the first bar close all trades 
   {
         bool closeConfirm=-1;
    while (closeConfirm ==-1)
        
    {     OrderSelect(ticket,SELECT_BY_TICKET);
         
         if (OrderType()==ORDER_TYPE_BUY)
             
         { closeConfirm=OrderClose(ticket,OrderLots(),Bid,3,Red);}else 
         
         if (OrderType()==ORDER_TYPE_SELL)
           
         { closeConfirm=OrderClose(ticket,OrderLots(),Ask,3,Red);}
   }
   
   
 
   
   }


 
 
 
 
 
   ticket=0;
 
 }


 if (!newBar15m()) return;  //only trade on new bar

if (Time[1]==iTime(Symbol(),PERIOD_M15,0))
// then bar [1] is the first bar  

   {
   
   SignalBarHigh= iHigh(Symbol(),PERIOD_M15,1);
   SignalBarLow=iLow(Symbol(),PERIOD_M15,1);
     
   
   }


 TakeProfit= (GetAveragePeriodRange6(PERIOD_D1)*inpTarget);

int ADX =iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN,1 );
double  b4plusdi = iADX(Symbol(),Period (), 14, PRICE_CLOSE, MODE_PLUSDI, 2);
double  nowplusdi = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_PLUSDI, 1);
double  b4minusdi = iADX(Symbol(), Period (), 14, PRICE_CLOSE, MODE_MINUSDI, 2);
double  nowminusdi = iADX(Symbol(), Period() , 14, PRICE_CLOSE, MODE_MINUSDI, 1); 
   
bool longsignal;

if (nowplusdi>nowminusdi) longsignal=true; else longsignal=false;

bool shortsignal;

if (nowplusdi<nowminusdi) shortsignal=true; else shortsignal=false;

if (longsignal==true && ticket==0&& ADX>30&& Ask>SignalBarHigh) ticket=orderOpen(ORDER_TYPE_BUY,0,0,inpOrderSize,inpTradeComments,inpMagicNumber);
if (shortsignal==true && ticket==0&& ADX>30&& Bid< SignalBarLow) ticket= orderOpen(ORDER_TYPE_SELL,0,0,inpOrderSize,inpTradeComments,inpMagicNumber);


return;
     
    


   
  }
//+------------------------------------------------------------------+


 
   
   