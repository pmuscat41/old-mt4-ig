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
input double inpTakeProfit= 500;// Enter take profit in points for order opening
input int inpStopPoints= 1000;// Enter trailing stop in points for order opening;
input double   inpOrderSize_      =  0.05;  //Order size for order opening

double  inpOrderSize = inpOrderSize_;
 
input int BuyCandleCounter=30;// Number of candles before Buy and Sell opened 
input string  inpbreak1 = "------------ stop management ---------------------";//
input bool   inpFollowingStop = True;//  Apply following stop ? (true/false)
input bool   inpDynamicTrailing = True;// Apply dynamic trailing stop? (true/false)
input bool    inpDynamicProfits = True;// Apply Dynamic following profit? 
input double inpStopSteps = 100;//Enter steps for trailing stop in points
input int     inpMaxOrders=40;//maxinum orders
input string inpbreak2=" _____________________________________________________";//
input string   inpTradeComments  =  "Hedging EA v14";  //Trade comment
input double   inpMagicNumber    =  21212577837352; //Magic number 



double stploss;
double takeProfit;
int ticket;
int countdown=BuyCandleCounter;

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

   
      stploss= SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopPoints;
      takeProfit=SymbolInfoDouble(Symbol(),SYMBOL_POINT)*inpTakeProfit;
     
     countdown++;
     
     int trades=0;
     
        int tot=OrdersTotal();
      
      for (int j=tot-1;j>=0;j--)
      
      {
      OrderSelect(j,SELECT_BY_POS,MODE_TRADES);
      if (OrderSymbol()==Symbol())
         if (OrderMagicNumber()==inpMagicNumber) trades++;
      
      
     }
     
     if (countdown>=BuyCandleCounter)
      if (trades<inpMaxOrders)
     
      {
       ticket   =  orderOpen(ORDER_TYPE_BUY, stploss,takeProfit);
       ticket  =  orderOpen(ORDER_TYPE_SELL, stploss,takeProfit);
       countdown=0;       
      }
   
   
   
   /// manage trade
   
  
    
      // only apply trailing stop if better than opening price
      // only apply trailing stop if better than current trailing stop
      
      /// get trailing stop in points (int)
      // need stoploss = double
      ApplyTrailingStop (Symbol(),inpMagicNumber,takeProfit, stploss);
        
             
   
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


void ApplyTrailingStop(string symbol, int magicNumber, double TP, double SL)

   {
   
      static int digits= (int) SymbolInfoInteger (symbol,SYMBOL_DIGITS);
      /// Trailing from close price
      
      
      double buyStopLoss;
      double sellStopLoss;
      
       
      
     
     double BuyProfitRange;
     double SellProfitRange;
     double progress;
     bool Buy50Stop, Buy60Stop, Buy70Stop,Buy80Stop, Buy90Stop;
     bool Sell50Stop, Sell60Stop,Sell70Stop,Sell80Stop,Sell90Stop;
     
        int count=OrdersTotal();
      
      for (int i=count-1;i>=0;i--)
      
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      
      static bool Buy50Stop=false;
      static bool Buy60Stop=false;
      static bool Buy70Stop=false;
      static bool Buy80Stop=false;
      static bool Buy90Stop=false;
      
      static bool Sell50Stop=false;
      static bool Sell60Stop=false;
      static bool Sell70Stop=false;
      static bool Sell80Stop=false;
      static bool Sell90Stop=false;     
      
      double StopSteps=SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopSteps;
      double trailingStop=SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopPoints;
      
      double step90=StopSteps;
      double step80=StopSteps*2;
      double step70=StopSteps*3;
      double step60=StopSteps*4;
      double step50=StopSteps*5;
      
      double BuyProfitRange= inpTakeProfit*Point;
      double SellProfitRange= inpTakeProfit*Point;
      
      double Buyband50= OrderOpenPrice()+(BuyProfitRange*0.5);
      double Buyband60=OrderOpenPrice()+(BuyProfitRange*0.6);
      double Buyband70=OrderOpenPrice()+(BuyProfitRange*0.7);
      double Buyband80=OrderOpenPrice()+(BuyProfitRange*0.8);
      double Buyband90=OrderOpenPrice()+(BuyProfitRange*0.9);
      
      
      double Sellband50= OrderOpenPrice()-(SellProfitRange*.5);
      double Sellband60=OrderOpenPrice()-(SellProfitRange*.6);
      double Sellband70=OrderOpenPrice()-(SellProfitRange*.7);
      double Sellband80=OrderOpenPrice()-(SellProfitRange*.8);
      double Sellband90= OrderOpenPrice()-(SellProfitRange*.9);    
      
            
      ///  DYNAMIC STOPS =====================================================
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                  if (Bid > Buyband50)
                      if (Bid < Buyband60)
                     
                        {                       
                        Buy50Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step50, digits);
                        Debug("Buystop50 true - sellprBuyProfitRante is ",BuyProfitRange);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid > Buyband60)
                     if (Bid< Buyband70)
                        {
                        Buy60Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step60, digits);
                        Debug("Buystop60 true - sellprBuyProfitRante is ",BuyProfitRange);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid > Buyband70)
                    if (Bid< Buyband80)
                        {
                        Buy70Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step70, digits);
                        Debug("Buystop70 true - sellprBuyProfitRante is ",BuyProfitRange);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid > Buyband80)
                    if (Bid<Buyband90)  
                        {                       
                        Buy80Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-step80, digits);
                        Debug("Buystop80 true - sellprBuyProfitRante is ",BuyProfitRange);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid >  Buyband90)                       
                        {
                        Buy90Stop=true;
                        buyStopLoss = NormalizeDouble(Bid-StopSteps, digits);
                        Debug("Buystop90 true - sellprBuyProfitRante is ",BuyProfitRange);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
              
                  }            
                  
                  
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                  if (Ask < Sellband50)
                     if (Ask> Sellband60)
                        
                        {
                        Sell50Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step50, digits);
                        Debug("sellstop50 true - sellprofit range is ",SellProfitRange);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }
                  if (Ask < Sellband60)
                     if (Ask> Sellband70)
                        {
                        Sell60Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step60, digits);
                        Debug("sellstop60 true - sellprofit range is ",SellProfitRange);
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask < Sellband70)
                    if (Ask> Sellband80)
                        {
                        Sell70Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step70, digits);
                        Debug("sellstop70 true - sellprofit range is ",SellProfitRange);
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask < Sellband80)
                    if (Ask> Sellband90)
                        {
                        Sell80Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+step80, digits);
                        Debug("sellstop80 true - sellprofit range is ",SellProfitRange);
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask <Sellband90)
                        {
                        Sell90Stop=true;
                        sellStopLoss = NormalizeDouble(Ask+StopSteps, digits);
                        Debug("sellstop90 true - sellprofit range is ",SellProfitRange);
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  }            
             
                    
                    
                    
                    
 ////////////////////FOLLOWING STOPS==========================================
 
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if (inpFollowingStop==true)
               
                { 
                  
                        buyStopLoss = NormalizeDouble(Bid-trailingStop, digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                                   
                    
                    
                
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
                  if (inpFollowingStop==true)
               
                { 
                        sellStopLoss = NormalizeDouble(Ask+trailingStop, digits);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }                
                    
                    
///// Dynamic Profit

double TPP;
                         
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
                  if ( inpDynamicProfits ==true)
               
                { 
                  
                         TPP = NormalizeDouble(Bid+TP, digits);
                        if (TPP<OrderTakeProfit())
                           OrderModify(OrderTicket(), OrderOpenPrice(),OrderStopLoss(),TPP,OrderExpiration());
                        }
                                   
                    
                    
                
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
                  if (inpDynamicProfits==true)
               
                { 
                        TPP = NormalizeDouble(Ask-TP, digits);
                        if (TP>OrderTakeProfit())
                          OrderModify(OrderTicket(), OrderOpenPrice(),OrderStopLoss(),TPP,OrderExpiration());
                        
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
int orderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit)
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
