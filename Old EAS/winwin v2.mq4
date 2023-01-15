//+------------------------------------------------------------------+
//|                                                 Hedging EA.mq4 |
//|                                                Copyright 2021PJM |
//|            
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/// RSI levels are from 0 -100, select levels for overbought and oversold
//  and the inputs to RSI

int                  inpRSIPeriods  =  2;               //RSI Periods

input ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price





input double   inpFirstTakeProfit = 500;// Enter first take profit in pips
input double   inpHedgeTakeProfit = 500;// Enter Hedge take profit in pips
input double   inpHedgeStopLoss = 170;// Enter Hedge stop loss in pips
input double   inpMaxSpread = 500;// Enter maximum spread to trade in pips

input double   inpInitialLots = 0.5;// Enter inital lots to trade
input double   inpHedgeLots = 1;// Enter lots for hedge
input string   inpTradeComments  =  "WinWin v2";  //Trade comment
input double   inpMagicNumber    =  0000; //Magic number 

int ticket;
int BuyOrder;
int SellOrder;
int Hedge;
int Order;
bool static HedgeOn=false;
double static UpperLimit=999999;
double static LowerLimit=0.00000;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {



      
       


   ENUM_INIT_RETCODE result =  INIT_SUCCEEDED ;

   result =  checkInput();
   if(result!=INIT_SUCCEEDED)
      return(result);  //exit if inputs are bad

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
  
  
  

   if(!newBar())
      return;  //only trade on new bar

static int digits= (int) SymbolInfoInteger (Symbol(),SYMBOL_DIGITS);
    
    
     //FirstTakeProfit=SymbolInfoDouble(Symbol(),SYMBOL_POINT)*inpFirstTakeProfit;
     
      
     
     int trades=0;
     
        int tot=OrdersTotal();
      
      for (int j=tot-1;j>=0;j--)
      
      {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
      if (OrderSymbol()==Symbol())
         if (OrderMagicNumber()==inpMagicNumber) trades++;
      
      
     }
     
     //if (MarketInfo(Symbol(),MODE_SPREAD)<inpMaxSpread)
      if (trades==0)
     
      {
       BuyOrder   =  orderOpen(ORDER_TYPE_BUY, 0,0,inpInitialLots);
       SellOrder  =  orderOpen(ORDER_TYPE_SELL, 0,0,inpInitialLots);    
      }
   
   
    //ManageTrade(inpFirstTakeProfit);
    
      if (HedgeOn==false)
      
      {OrderSelect (BuyOrder,SELECT_BY_TICKET,MODE_TRADES);
      if (Bid >OrderOpenPrice()+inpFirstTakeProfit*Point)
      
               {Order= OrderClose (OrderTicket(),OrderLots(),Bid,10,Red);
                Hedge =  orderOpen (ORDER_TYPE_BUY,0,0,inpHedgeLots);
                     UpperLimit= Bid+inpHedgeTakeProfit*Point;
                     LowerLimit= Bid-inpHedgeStopLoss*Point;
                     HedgeOn=true;}
       }              
                              
   
   if (HedgeOn==false)
   {
    OrderSelect (SellOrder,SELECT_BY_TICKET,MODE_TRADES);
      
   if (Ask <OrderOpenPrice()-inpFirstTakeProfit*Point)
         if (HedgeOn==false)
               
                  { Order= OrderClose (OrderTicket(),OrderLots(),Bid,10,Red);
                    Hedge =  orderOpen (ORDER_TYPE_SELL,0,0,inpHedgeLots);
                     UpperLimit= Ask+inpHedgeStopLoss*Point;
                     LowerLimit= Ask-inpHedgeTakeProfit*Point;
                     HedgeOn=true;}
    }    
  
  //Close All trades 
  
  if (Ask>UpperLimit) CloseAll();
  if (Bid<LowerLimit) CloseAll();
   

  

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE checkInput()
  {

   if(inpRSIPeriods<=0)
      return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

  }

// true or false has bar changed

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CloseAll()

{
        int count=OrdersTotal();
      
      for (int i=count-1;i>=0;i--)
      
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      Order= OrderClose (OrderTicket(),OrderLots(),Bid,10,Red);
      }
      
      
double static UpperLimit=999999;
double static LowerLimit=0.00000;
HedgeOn=false;
      
}







bool newBar()
  {

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result = (currentTime!=priorTime);      //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
  }




//simple function to open a new order

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int orderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit,double inpOrderSize)
  {

   int   ticket;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;

// caclulate the open price, take profit and stoploss price based on the order type
//
   if(orderType==ORDER_TYPE_BUY)
     {
      openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());

      //Ternary operator, because it makes things look neat
      //   if stopLoss==0.0){

      //stopLosssPrice = 0.0}
      //   else {
      //    stopLossPrice = NormalizedDouble (openPrice - stopLoss, Digist());
      //

      stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
      takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
     }
   else
      if(orderType==ORDER_TYPE_SELL)
        {
         openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());

        }
      else
        {
         // this function works with buy or sell
         return (-1);
        }

   ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
   return (ticket);
  }
  
  
  
  
//+------------------------------------------------------------------+
