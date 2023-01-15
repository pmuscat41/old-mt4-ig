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
input double   inpOldSellStopLoss = 500;// Enter stop loss for old order in pips
input double   inpOldSellTakeProfit= 170;// Enter take profit for old order in pips

input double   inpOldBuyStopLoss = 500;// Enter stop loss for old order in pips
input double   inpOldSBuyTakeProfit= 170;// Enter take profit for old order in pips

input double   inpInitialLots = 0.5;// Enter inital lots to trade
input double   inpHedgeLots = 1;// Enter lots for hedge
input string   inpTradeComments  =  "winwin";  //Trade comment
input double   inpMagicNumber    =  0000; //Magic number 

int ticket;

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
       ticket   =  orderOpen(ORDER_TYPE_BUY, 0,0,inpInitialLots);
       ticket  =  orderOpen(ORDER_TYPE_SELL, 0,0,inpInitialLots);    
      }
   
   
    ManageTrade(inpFirstTakeProfit);
        
             
   
   //New Order on newbar
  

  

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


void ManageTrade (double TP)

   {
   
   bool OK;
   bool ticket;
   bool Order;
   double OrderTP;
   double OrderSL;
   double   buyStopLoss;
   double   buyTakeProfit;
   double TPR;
   double sellStopLoss;
   double SellTakeProfit;
   double SL1;
   double TP1;
   static int digits= (int) SymbolInfoInteger (Symbol(),SYMBOL_DIGITS);
      
    
        int count=OrdersTotal();
      
      for (int i=count-1;i>=0;i--)
      
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
    
      double openprice= OrderOpenPrice();
      
      static int digits= (int) SymbolInfoInteger (Symbol(),SYMBOL_DIGITS);
      
      TPR= TP*Point*10;
      double BuyClosePrice=NormalizeDouble(openprice+TPR,Digits);
      double SellClosePrice=NormalizeDouble(openprice-TPR,Digits);
      Alert ("TP=  "+ TPR+ "Buy / Sell close price=   "+BuyClosePrice+" /  "+SellClosePrice);
      
            
      ///  CLOSE TRADE =====================================================
      
      if (OrderSymbol()==Symbol())
            if (OrderMagicNumber()==inpMagicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                  if (Bid >=BuyClosePrice)
                   //  if (MarketInfo(Symbol(),MODE_SPREAD)<inpMaxSpread)
                        
                      
                     
                        {                       
                        Order= OrderClose (OrderTicket(),OrderLots(),Bid,10,Red);
                        if (Order== true)
                        
                           { 
                             
                             
                             
                                OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
                           
                           sellStopLoss = NormalizeDouble(Bid+inpOldBuyStopLoss*Point, Digits);
                           SellTakeProfit= NormalizeDouble(Bid-inpOldSBuyTakeProfit*Point,Digits);
                           OK= OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,SellTakeProfit,OrderExpiration());
                           Alert ( "error = "+ GetLastError()+" sellStopLoss= " + sellStopLoss+ " SellTakeProfit= "+ SellTakeProfit);
                          
                           
                              if (OK==true)
                                         
                                 {SL1=inpHedgeStopLoss*Point*10;
                                   TP1=inpHedgeTakeProfit*Point*10;
                                 ticket   =  orderOpen (ORDER_TYPE_BUY,SL1,TP1,inpHedgeLots);} 
                           
                              
                           }
                        
                        }}
                     
              
                          
      
      
      
      
      
      if (OrderSymbol()==Symbol())
            if (OrderMagicNumber()==inpMagicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                  
                  if (Ask <=SellClosePrice)
                     //if (MarketInfo(Symbol(),MODE_SPREAD)<inpMaxSpread)
                        
                      
                     
                        {                       
                        Order= OrderClose (OrderTicket(),OrderLots(),Ask,10,Blue);
                        if (Order== true)
                        
                           { 
                             
                           
                           OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
                           
                           buyStopLoss = NormalizeDouble(Ask-inpOldSellStopLoss*Point, Digits);
                           buyTakeProfit= NormalizeDouble(Ask+inpOldSellTakeProfit*Point,Digits);
                           OK= OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,buyTakeProfit,OrderExpiration());
                          Alert ( "error = "+ GetLastError()+" buyStopLoss= " + buyStopLoss+ " buyTakeProfit= "+ buyTakeProfit);
                           
                        
                           
                              if (OK==true)
                                         
                                 {SL1=inpHedgeStopLoss*Point*10;
                                   TP1=inpHedgeTakeProfit*Point*10;
                                 
                                 ticket   =  orderOpen (ORDER_TYPE_SELL,SL1,TP1,inpHedgeLots);} 
                           
                           }
               }
                     
              
                  }            
      
      
      
      
      
      
      
      
      
      
      
             
                    
                          
      }
      
      }
      


void Debug (string text,double value)

{
Comment (" Debug: "+ text +"  "+value);

for (int i=10;i<10000000;i++)
      
      {
Sleep(60000000);
return;
}}





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
