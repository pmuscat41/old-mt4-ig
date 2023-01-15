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
 int     inpRSIPeriods  =  14;               //RSI Periods
       ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
input       double factor= 2.1;// enter ATR factor to multiply the ATR stop
input       double inpADXLimit=30;// Enter maximum ADX to trade
input       double inpADXMin=10;// Enter minimum ADX to trade
input       double  inpCashMin= 1000;//Enter minimum cash balance to trade
input double  inpOrderSize      =  0.1;  //Order size
input string  inpTradeComments  =  "Outside Day v5";  //Trade comment
input double  inpMagicNumber    =  212121; //Magic number

double stoplossPrice;
double orderSize;
int  static ticket =0;
 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  
double IV= GetIV ();
  
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
     

double IV= GetIV ();
Alert("Implied Volatility= "+IV);

                 
   double KeltnerMovingAverage = iMA(Symbol(),Period(),20,0,MODE_EMA,PRICE_TYPICAL,1);
         double ATR                  = iATR(Symbol(),Period(),20,1);
         double ATR100                  = iATR(Symbol(),Period(),100,1);
         
         double orderSizeAdjust= ATR100/ATR;
         orderSize= orderSizeAdjust*inpOrderSize;
         
         int adx =iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN,1 );
         
         double KeltnerBandShift     = ATR*factor;
         double Stop     = KeltnerBandShift;
         






// reset after stoploss

if (ticket>0) 
   {  OrderSelect (ticket, SELECT_BY_TICKET);
      if (OrderCloseTime()!=0) ticket=0;}



// Trade Exit


if (ticket>0)

   {
      OrderSelect (ticket,SELECT_BY_TICKET);
     
          
       if ((OrderType()== ORDER_TYPE_BUY)&& (OrderProfit()>0) && (DayOfWeek ()!=SUNDAY))
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
            
            
        if ((OrderType()==ORDER_TYPE_SELL) && (OrderProfit()>0)&& (DayOfWeek()!=SUNDAY))
            
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
            
                 
       if ((OrderType()== ORDER_TYPE_BUY)&& (iClose(Symbol(),Period(),1)<(OrderOpenPrice()-Stop)) && (DayOfWeek ()!=SUNDAY))
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
            
            
        if ((OrderType()==ORDER_TYPE_SELL) && (iClose(Symbol(),Period(),1)>(OrderOpenPrice())+Stop)&& (DayOfWeek()!=SUNDAY))
            
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
      
      if   (ticket==0 && 
            High[2]>High[3] && 
            Low[2]<Low[3] && 
            Close[2]<Low[3]&&
            Close[1]<Close[2]&&
            adx<inpADXLimit&&
            AccountFreeMargin()>inpCashMin &&
            adx>inpADXMin)
      
        {
      ticket   =  orderOpen(ORDER_TYPE_BUY, 0,0);
      
      }else
      if (ticket==0 &&
          Low[2]<Low[3] &&
          High[2]>High[3] &&
          Close[2]>High[3] &&
          Close[1]>Close[2]&&
          adx<inpADXLimit&&
          AccountFreeMargin()>inpCashMin&&
          adx>inpADXMin) {
      ticket  =  orderOpen (ORDER_TYPE_SELL, 0,0);
      
      }
      
 
   
   
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
      
      ticket = OrderSend (Symbol(), orderType,orderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}


double GetIV (){

      double Price1=iClose(Symbol(),Period(),1);
      double Price2= iClose(Symbol(),Period(),2);
      double Price3= iClose(Symbol(),Period(),3);
      double Price4= iClose(Symbol(),Period(),4);
      
      
      double log1=MathLog (Price1);
      double log2=MathLog (Price2);
      double log3=MathLog (Price3);
      double log4=MathLog (Price4);
          
      
      double Dif1= log1-log2;
      double Dif2= log2=log3;
      double Dif3=log3-log4;
      
      double mean=(Dif1+Dif2+Dif3)/3;
      
      double m1=(Dif1-mean)*(Dif1-mean);
      double m2=(Dif2-mean)*(Dif2-mean);
      double m3=(Dif3-mean)*(Dif3-mean);
      
      double variance=(m1+m2+m3)/3;
      double standardDeviation = MathSqrt(variance);
      double HIV= standardDeviation*MathSqrt(260)*10;
      return (HIV);
  }    
      
      
      
      
      
      
                 