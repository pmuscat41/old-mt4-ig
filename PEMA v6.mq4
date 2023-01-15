//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//|
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "6.00"
#property strict


//The Levels


 int                  inpRSIPeriods  =  14;               //RSI Periods

 ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit
input double            inpSlowSpread= 50;//enter spread between slow and medium MA in pips

input int                        inpADXPeriod=5;// input ADX Period
input int                        inpADXTrigger=30;// input ADX trigger
 int                  inpLookback =50;// input lookbback in bars to see if trending
 int                  inplongTrendStrength=45;// input number of bullish bars to enter 
 int                  inpShortTrendStrength=-45;// input number of bearish bars to enter (-ve) 
input double               inpTakeProfit  =  0.0;     //Take Profit in currency value
input double               inpStopLoss   =  0.0;     //Stop Loss in currecny value

///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.1;  //Order size
input string   inpTradeComments  =  "PEMA V6";  //Trade comment
input double   inpMagicNumber    =  212121; //Magic number

static int lastTicket = -1;
static double previousDirection =0;
static bool closeLong=false;
static bool closeShort=false;
static bool tradeLongOpen=false;

double open,close,high,low,closeB4,lowB4,highB4;



          double SlowSpread,FastSpread,SSpread, FSpread;
          int digits = Digits();
      
    

     
      double PMAslow, PMAmed, PMAfast;
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
   


    
        
    
     
    
     /// positive= uptrend, negative = down trend
   
   ////// open   trades -----------------------------------------
   
      
    if (!newBar()) return;  //only trade on new bar
    
       
          if (digits==4)  SlowSpread = inpSlowSpread/1000;
          if (digits==5) SlowSpread =inpSlowSpread/10000;
           if (digits==3) SlowSpread=inpSlowSpread/100;
   
       open= iOpen (Symbol(),Period(),1);
       close = iClose (Symbol(),Period(),1);
       high = iHigh (Symbol(),Period(),1);
      low= iLow (Symbol(),Period(), 1);
      closeB4= iClose (Symbol(),Period(),2);
      lowB4= iLow (Symbol(),Period(),2); 
      highB4=iHigh (Symbol(),Period(),2);
     
       PMAslow = iMA(Symbol(),Period(),55,0,MODE_EMA, PRICE_TYPICAL,1);
       PMAmed= iMA(Symbol(),Period(),34,0,MODE_EMA, PRICE_TYPICAL,1);;
       PMAfast = iMA(Symbol(),Period(),21,0,MODE_EMA, PRICE_TYPICAL,1);
     
     
     double PMAslowB4 = iMA(Symbol(),Period(),55,0,MODE_EMA, PRICE_TYPICAL,2);
     double PMAmedB4= iMA(Symbol(),Period(),34,0,MODE_EMA, PRICE_TYPICAL,2);
     double PMAfastB4 = iMA(Symbol(),Period(),21,0,MODE_EMA, PRICE_TYPICAL,2);
     
     bool stackedLong,stackedShort,golong,goshort;
     
     stackedLong=false;
     stackedShort=false;
     golong=false;
      goshort=false; 
    
    
     if (PMAfast>PMAmed)
      if (PMAmed>PMAslow)
         stackedLong=true;
         
     if (PMAfast<PMAmed)
        if (PMAmed<PMAslow) 
         stackedShort=true;
         
     if (PMAmed>PMAmedB4)
      if (PMAslow>PMAslowB4)
         golong=true;
         
     if (PMAmed<PMAmedB4)
      if (PMAslow<PMAslowB4)
         goshort=true;
     
     CheckMarket ();
     
     double ADX=iADX(Symbol(),Period(),inpADXPeriod,PRICE_MEDIAN,0,0);
    
    
    
    
    
    
    closeLong=false;
     closeShort=false;
     
     
   if (stackedLong==true)  SSpread= PMAmed -PMAslow ;
   
    
   static int  ticket =-1;
   
   if (stackedLong==true)
      if (golong==true)
         if (ticket<0)
            if (longSignal()==true)
               if (ADX>inpADXTrigger)
                   if (SSpread>SlowSpread)
               
     {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      lastTicket = ticket;
     
      tradeLongOpen=true;
     }
   
   
   
   
   if (stackedShort==true)  SSpread= PMAslow-PMAmed;
   
      
   Alert ("Spread between Slow and Medium = "+ SSpread);
   
      if (stackedShort==true)
         if (goshort==true)
            if (ticket<0)
               if (shortSignal()==true)
                  if (ADX>inpADXTrigger)
                     if  ( SSpread > SlowSpread)
                  
      
      
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         lastTicket= ticket;
        
         tradeLongOpen=false;
        }
    
    
 /////// order close criteria check to see if we should close an order
 ///// 
 
 double SellClosePoint = PMAmed;
 double BuyClosePoint = PMAmed;
 double lastCloseAsk = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
 double lastCloseBid=  NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
  
    if (lastCloseBid>SellClosePoint)
       closeShort=true;
    
    if (lastCloseAsk<BuyClosePoint) 
     closeLong=true;
    
   Alert ( " Trendstrength = "+ CheckMarket() +"  Long Close signal  "+closeLong+  "  previous direction   "+previousDirection+ "ticket ="+ticket+" Lastticket = "+ lastTicket);
   Alert ("Trendstrength= "+ CheckMarket()+ "Short Close signal  "+closeShort+ " previous direction   "+previousDirection+ "ticket ="+ticket+" Lastticket = "+ lastTicket);
 
   double  closeBuyPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
   double closeSellPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
    
         
  if ((closeLong==true) && (ticket==lastTicket)&&(tradeLongOpen==true))
     {  
     
     OrderClose (lastTicket,inpOrderSize,Bid,10,Red);
      lastTicket=-1;
      ticket=-1;}

   if ((closeShort==true) && (ticket==lastTicket)&& (tradeLongOpen==false))
      {
      
      OrderClose (lastTicket,inpOrderSize,Ask,10,Blue);
     lastTicket=-1;
     ticket=-1;}
          
    
   return ;

     
     
     
   
   
  }   
//+------------------------------------------------------------------+



ENUM_INIT_RETCODE checkInput(){

   if (inpRSIPeriods<=0)   return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

}



// true or false has bar changed

int CheckMarket ()

{

int trendStrength=0;


for (int i=1;i<inpLookback;i++)

      {  
      
     double open= iOpen (Symbol(),Period(),i);
     double close = iClose (Symbol(),Period(),i);
      
         if (close >PMAmed)
            trendStrength=trendStrength+1;
      
      
         if (close<PMAmed)
            trendStrength=trendStrength-1;
      
      }
return (trendStrength);


}

bool longSignal()


      {        
     if  ((lowB4<PMAfast) &&    (close>PMAfast))
         return (true);
         else
            return(false);
      }

bool shortSignal()

      {
      
       if  ((highB4>PMAfast) && (close<PMAfast))
         return (true);
            else
               return(false);
      
      }



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
      