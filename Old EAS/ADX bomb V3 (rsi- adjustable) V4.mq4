//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//|
//  Code is from http://www.orchardforex.com 
//  title of You tube video is "Biginners guide : Write your own RSI expert advisor for MT4
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int     inpRSIPeriods  =  30;               //RSI Periods
input int     inpADXTrigger= 20;// ADX trigger
input int     inpADXPeriod= 14;// ADX period
input double  inpOrderSize      =  0.01;  //Order size
input string  inpTradeComments  =  "ADX Bomb";  //Trade comment
input double  inpMagicNumber    =  212121; //Magic number
input double inpStoploss= 0.000;// input stoploss
input double  inpADXExit =  25;// ADX value to exit



int  static ticket =0;
 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  ENUM_INIT_RETCODE result =  INIT_SUCCEEDED ;
  
  result =  checkInput();
  if (result!=INIT_SUCCEEDED) return(result);  //exit if inputs are bad 

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
void OnTick()  {


   if (!newBar()) return;  //only trade on new bar
     
   
double ADXnow=iADX (Symbol(),Period(),inpADXPeriod,PRICE_CLOSE,MODE_MAIN,1);
double ADXB4= iADX (Symbol(),Period(),inpADXPeriod,PRICE_CLOSE,MODE_MAIN,2);
double fiftyma= iMA (NULL,NULL,NULL,59,MODE_SMA,PRICE_CLOSE,1);


// Trade Exit

if (ticket>0)

   {
   OrderSelect (ticket,SELECT_BY_TICKET);
       
       if ((OrderType()== ORDER_TYPE_BUY)&& (ADXnow<inpADXExit))
            {
             RefreshRates();
            OrderClose(ticket,OrderLots(),Bid,10);
            if (GetLastError()==-1)
            {
               while (GetLastError()!=-1)
               {RefreshRates();
                OrderClose(ticket,OrderLots(),Bid,10);}}
                       
                  ticket=0;
            }
        if ((OrderType()==ORDER_TYPE_SELL) && (ADXnow<inpADXExit))
            {
              RefreshRates();
              OrderClose(ticket,OrderLots(),Ask,10);
               if (GetLastError()==-1)
            {
               while (GetLastError()!=-1)
               {RefreshRates();
                OrderClose(ticket,OrderLots(),Ask,10);}}  
              
              
             ticket=0;  
            }
     }       
                     
                        




//  Trade entry
      
      if ((ADXnow>inpADXTrigger)&& (ticket==0)&&(iRSI(NULL,NULL,inpRSIPeriods,PRICE_CLOSE,1) >70))  {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStoploss,0);
      
      }else
      if ((ADXnow>inpADXTrigger)&&(ticket==0)&&(iRSI(NULL,NULL,inpRSIPeriods,PRICE_CLOSE,1) <30)) {
      ticket  =  orderOpen (ORDER_TYPE_SELL, inpStoploss,0);
      
      }
      
 
    
      return ;
   
   
  }   
//+------------------------------------------------------------------+

ENUM_INIT_RETCODE checkInput(){

   if (inpRSIPeriods<=0)   return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

}

// true or false has bar changed

bool newBar(){

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result =      (currentTime!=priorTime); //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
   }
   
   //simple function to open a new order 
   
   int orderOpen (ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit){
      
      int   ticket;
      double openPrice;
      double stopLossPrice;
      double takeProfitPrice;
      
      // caclulate the open price, take profit and stoploss price based on the order type
      //
      if (orderType==ORDER_TYPE_BUY){
         openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
      
         //Ternary operator, because it makes things look neat
         //   if stopLoss==0.0){
     
         //stopLosssPrice = 0.0} 
         //   else {
         //    stopLossPrice = NormalizedDouble (openPrice - stopLoss, Digist());
         //
      
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
      }else if (orderType==ORDER_TYPE_SELL){
         openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      