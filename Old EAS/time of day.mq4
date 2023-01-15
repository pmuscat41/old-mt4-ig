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
input int inpStopPoints= 1800;// Enter trailing stop in points for order opening (1800-4800);
input double   inpOrderSize_      =  0.05;  //Order size for order opening

double  inpOrderSize = inpOrderSize_;
 
input int BuyCandleCounter=30;// Number of candles before Buy and Sell opened 

input int     inpMaxOrders=40;//maxinum orders
input string inpbreak2=" _____________________________________________________";//

input double inpBreakEvenStart =700;// points to start break even stop
input double inpLockinPips= 200;//input points to lock in 

input double inpTrailing1start1 = 800; // enter points to start trailing #1
input double inpTrailing1StopSize1 = 400; // enter points for trailing stop #1
input double inpTrailingStopStep1 = 100; // enter points for steps for trailing stop #1


input double inpTrailing1start2 = 800; // enter points to start trailing #2
input double inpTrailing1StopSize2 = 400; // enter points for trailing stop #2
input double inpTrailingStopStep2 = 100; // enter points for steps for trailing stop #2

input bool inpTS0=false;// use Trailing Stop 0
input bool inpTS1=false;//use Trailing Stop 1
input bool inpTS2=false;//use Trailing Stop 2

input string   inpTradeComments  =  "Time of Day";  //Trade comment
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
      
      double trailingStop=SymbolInfoDouble(Symbol(), SYMBOL_POINT)*inpStopPoints;
      
      
      double BuyProfitRange= inpTakeProfit*Point;
      double SellProfitRange= inpTakeProfit*Point;
      
      
      
      double Buyband50= OrderOpenPrice()+(BuyProfitRange*0.5);
      double SellBand50= OrderOpenPrice()-(SellProfitRange*0.5);
      
      double BreakevenBuyStop= OrderOpenPrice()+(inpBreakEvenStart*Point);
      double BreakevenSellStop= OrderOpenPrice()-(inpBreakEvenStart*Point);
      
      
      double BuyTrail1Start1 = OrderOpenPrice()+(inpTrailing1start1*Point);
      double BuyTrail1= inpTrailing1StopSize1*Point;
      
      
      double BuyTrail1Start2 = OrderOpenPrice()+(inpTrailing1start2*Point);
      double BuyTrail2= inpTrailing1StopSize2*Point;
      
      
      
      
      
      double SellTrail1Start1 = OrderOpenPrice()-(inpTrailing1start1*Point);
      double SellTrail1= inpTrailing1StopSize1*Point;
      
      
      double SellTrail1Start2 = OrderOpenPrice()-(inpTrailing1start2*Point);
      double SellTrail2= inpTrailing1StopSize2*Point;
      
      double lockpips= inpLockinPips*digits;
      
      
            
      ///  DYNAMIC STOPS =====================================================
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                  if (Ask >BreakevenBuyStop)
                     if (inpTS0==true)
                      
                     
                        {                       
                        buyStopLoss = NormalizeDouble(Ask-lockpips, digits);
                          if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                        
                  if (Ask > BuyTrail1Start1)
                        if (inpTS1==true)
                        {
                       
                        buyStopLoss = NormalizeDouble(Ask-BuyTrail1, digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  
                        
                  if (Ask > BuyTrail1Start2)
                     if (inpTS2==true)
                        {
                       
                        buyStopLoss = NormalizeDouble(Ask-BuyTrail2, digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                 
                 
              
                  }            
                  
                  
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                  if (Bid < BreakevenSellStop)
                     if (inpTS0==true)
                    
                        
                        {
                        
                        sellStopLoss = NormalizeDouble(Bid-lockpips, digits);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }
                  if (Bid < SellTrail1Start1)
                     if (inpTS1==true)
                        {
                        
                        sellStopLoss = NormalizeDouble(Bid-SellTrail1, digits);
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid < SellTrail1Start2)
                     if (inpTS2==true)
                        {
                        sellStopLoss = NormalizeDouble(Ask-SellTrail2, digits);
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
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
