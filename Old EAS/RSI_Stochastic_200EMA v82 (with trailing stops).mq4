//+------------------------------------------------------------------+
//|                              MACD divergence strategy tester.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com

//things to fix
//  picking up wrong criteria for divergence -change code to look only for higher tops and lower bottoms
//add higher time frame momentum confirmation
// add macd cross as signal to enter trade
// version 36 uses only 200 EMA for trend direction

//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input double      inpStopSteps= 100;// Input one unit of steps for following stop (five steps)
input double      inpStopPoints= 400;// Input points for stoploss

input int         inplookback =     20;// Enter number of bars to scan
input double      inpMultiplier        = 1.2;// input multiplier to increase risk reward

input          double    ATRFactor=             2.5;// enter ATR Factor for trend component
input          double   inpPips=0.0005;// enter pips to add to each consecutive trade
input double   enterStop         =  10; // Enter Stop in pips to add to peak
input double   inpOrderSize      =  0.3;  //Order size


input int   inpMarketTurnCounter = 4;// enter maximum bars after signal to enter

input bool     tradecontinuously  = true; // trade contiuously? or one trade only?
int               entfastema = 12; // fast ema of MACD
int               entslowema = 26;//  slow ema of MACD
int               entsignal  = 9;//   signal of MACD
 
input string   inpTradeComments  =  "RSI STOCHASTIC 200 V80 - trailing stops";  //Trade comment

int      inpasxCrosstrigger=  36; // Enter maximum ADX trigger for trade (pretty useless)double   timeFrameConfimr  =  3; // enter period for higher time frame confirm (3= three times)
input int      inpMaxOrders = 6;// enter maximim number of orders to trade
input double   inpMagicNumber    =  12; //Magic number
double spread;
double stopvalue;
 int shoulder;

int static trades=0;
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


ApplyTrailingStop(Symbol(),inpMagicNumber);

static bool completed=false;
static int Docket=0;
static int marketTurnCounter=inpMarketTurnCounter;
  static int XmarketTurnCounter=inpMarketTurnCounter; 
  static bool shortFound=false;
  static bool longFound=false;  

 if (!newBar()) return;  //only trade on new bar
 
// for one trade at a time

if (Docket>0) completed=true;

if ((completed==true) && (tradecontinuously==false)) return;


 ///below is for continuous trading
if ((completed==true) && (tradecontinuously==true)) {

OrderSelect (Docket,SELECT_BY_TICKET);
if (OrderCloseTime()==0) 
{ Alert ("New trades suspended,waiting for trade to close");

return;}
else
{ completed=false;
trades=0;
shoulder=0;
Docket=0;
 marketTurnCounter=inpMarketTurnCounter;
 XmarketTurnCounter=inpMarketTurnCounter; 
  shortFound=false;
  longFound=false; }}





 
 double volume;
 int ticket=0;
 double takeProfitPrice;
 double stopLossPrice;
  static bool   tradeLong=false;
 
  double abit;
  double openPrice;
  int shoulder;
  int Hbar1;
  int Hbar2;
  int Lbar1;
  int Lbar2;
  
  static bool divergence = false;
  static int higherLow = 0; 
  static int lowerLow = 0;
  static int higherHigh = 0; 
  static int lowerHigh = 0;
  double multiplier= inpMultiplier;
  
  /// call functions to get direction of trade
         
 Comment (" \n Spread =  "+MarketInfo(Symbol(),MODE_SPREAD)+ "Minimum stop = "+  MarketInfo(Symbol(),MODE_SPREAD));
 
      //if (trades == entMaxtrades) completed=true; 
  
  
  //if found short previously, marketTurnCounter= value wating for MACD cross


for (int z=10;z<inplookback;z++)

{

if (shortFound) {

marketTurnCounter=marketTurnCounter+1;
Docket= CheckShortTrade (higherHigh,lowerLow,multiplier, marketTurnCounter);}

             if (Docket >0){
             //Comment ("open price ="+openPrice+"stopLossPrice "+stopLossPrice+"take Profit "+takeProfitPrice);
             trades=trades+1;
              
            tradeLong= false;
            marketTurnCounter=inpMarketTurnCounter;
            longFound=false;
            shortFound=false;
            }
  
  //// iF FOUNG LONG SIGNAL PREVIOUSLY - LOOK FOR ENTRY 
    
    
if (longFound) {

XmarketTurnCounter=XmarketTurnCounter+1;
Docket= CheckLongTrade (higherHigh,lowerLow,multiplier,XmarketTurnCounter);}


                                    if (Docket>0) {
                                    Comment ("open price ="+openPrice+"stopLossPrice "+stopLossPrice+"take Profit "+takeProfitPrice);
                                    trades=trades+1;
                                   
                                    tradeLong=true;
                                    XmarketTurnCounter=inpMarketTurnCounter;
                                    longFound=false;
                                    shortFound=false;
                                    }


 //-------------------------LOOK FOR A SHORT SIGNAL------------------------------------------/
     
  
  //bar1 = FindPeak (MODE_HIGH, shoulder,0);
  //bar2 = FindPeak(MODE_HIGH, shoulder, bar1+1);
 bool HnotDiverging=true;
 Hbar1= FindFirstHigh (z);
 Hbar2= FindSecondHigh (Hbar1, z);
  
  ObjectDelete (0,"upper");
  ObjectCreate (0,"upper",OBJ_TREND,0,iTime (Symbol(),Period(),Hbar2),iClose(Symbol(),Period(),Hbar2), iTime (Symbol(),Period(),Hbar1),iClose(Symbol(),Period(),Hbar1));
  ObjectSetInteger(0,"upper",OBJPROP_COLOR,clrBlue);
  ObjectSetInteger(0, "upper",OBJPROP_WIDTH,3);
  ObjectSetInteger(0, "upper",OBJPROP_RAY_RIGHT, true);
  
  static bool notrade=true;
  double PriceA =iClose (Symbol(),Period(),Hbar1);
  double PriceB=iClose (Symbol(),Period(),Hbar2);
  if (PriceA>=PriceB) {
   higherHigh = Hbar1; 
   lowerHigh = Hbar2;
   HnotDiverging=false;}
  else
  {  higherHigh = Hbar2; 
   lowerHigh = Hbar1;
   HnotDiverging=true;}
  
 
 
 
 
 //===============LOOK FOR LONG SIGNAL ==============
 
 bool LnotDiverging=true; 
  
  
  //bar1 = FindPeak (MODE_LOW  , shoulder,0);
  //bar2 = FindPeak(MODE_LOW, shoulder, bar1+1);
  
  
  Lbar1= FindFirstLow (z);
  Lbar2= FindSecondLow (Lbar1,z);
  
  ObjectDelete (0,"lower");
  ObjectCreate (0,"lower",OBJ_TREND,0,iTime (Symbol(),Period(),Lbar2),iClose(Symbol(),Period(),Lbar2),iTime (Symbol(),Period(),Lbar1), iClose(Symbol(),Period(),Lbar1));
  ObjectSetInteger(0,"lower",OBJPROP_COLOR,clrBlue);
  ObjectSetInteger(0, "lower",OBJPROP_WIDTH,3);
  ObjectSetInteger(0, "lower",OBJPROP_RAY_RIGHT, true);
 
  double Price1 =iClose (Symbol(),Period(),Lbar1);
  double Price2=iClose (Symbol(),Period(),Lbar2);
  if (Price1<Price2) {
  higherLow = Lbar2; 
  lowerLow = Lbar1;
  LnotDiverging=false;}
  else
  {higherLow = Lbar1; 
  lowerLow = Lbar2;
  LnotDiverging=true;}

         
if ((XmarketTurnCounter>=inpMarketTurnCounter) && (GetLongSignal (Lbar1, Lbar2, lowerLow,higherLow,LnotDiverging,ATRFactor)))

      { XmarketTurnCounter= 0;
         longFound=true;
      
      }
if ((marketTurnCounter>=inpMarketTurnCounter)  && (GetShortSignal (Hbar1, Hbar2, higherHigh,lowerHigh,HnotDiverging,ATRFactor)))
      { marketTurnCounter= 0; 
       shortFound=true;
       
   }
   
 Comment ("higher High= " +higherHigh+  "  higher low= "+ higherLow+ "  \nl lower low= "+ lowerLow+ "higher low= "+higherLow);  
 
 //if found short previously, marketTurnCounter= value wating for MACD cross

if (shortFound) {

marketTurnCounter=marketTurnCounter+1;
Docket= CheckShortTrade (higherHigh,lowerLow,multiplier, marketTurnCounter);}

             if (Docket >0){
             //Comment ("open price ="+openPrice+"stopLossPrice "+stopLossPrice+"take Profit "+takeProfitPrice);
             trades=trades+1;
               
            tradeLong= false;
            marketTurnCounter=inpMarketTurnCounter;
            shortFound=false;
            longFound=false;
            }
  
  //// iF FOUNG LONG SIGNAL PREVIOUSLY - LOOK FOR ENTRY 
    
    
if (longFound) {

XmarketTurnCounter=XmarketTurnCounter+1;
Docket= CheckLongTrade (higherHigh,lowerLow,multiplier,XmarketTurnCounter);}


                                    if (Docket>0) {
                                    Comment ("open price ="+openPrice+"stopLossPrice "+stopLossPrice+"take Profit "+takeProfitPrice);
                                    trades=trades+1;
                                    
                                    tradeLong=true;
                                    XmarketTurnCounter=inpMarketTurnCounter;
                                    shortFound=false;
                                    longFound-false;
                                    }



 
 
 }
   }
 
 
 //+------------------------------------------------------------------+  
 
 
   //if found short previously, marketTurnCounter= value wating for stochSTIC cross
  
 int CheckShortTrade (double higherHigh, double lowerLow,double multiplier, int marketTurnCounter) 
 
 {
 
            double ATR                  = iATR(Symbol(),Period(),20,1);
            double abit;
            int digits = Digits();
            spread= MarketInfo(Symbol(),MODE_SPREAD);
            double points=MarketInfo(Symbol(),MODE_POINT);
            if (digits==4)  abit=enterStop/1000;
            if (digits==5) abit=enterStop/10000;
            if (digits==3) abit=enterStop/100;
               
        int Docket=0;    
        
 
        double stomain=iStochastic(Symbol(),Period(),3,3,14,MODE_SMA,0,MODE_MAIN,1);
        double stosig=iStochastic(Symbol(),Period(),3,3,14,MODE_SMA,0,MODE_SIGNAL,1);
        
 /////-------------------------------------------------------------------------------------------------------------------------------------
 if (   (stomain>stosig)&& (marketTurnCounter< inpMarketTurnCounter)&& OpenOrders() <inpMaxOrders ) 
  
 {
     
      marketTurnCounter=marketTurnCounter+1;
    
       multiplier=inpMultiplier; 
       double swinghigh= iHigh(Symbol(),Period(),higherHigh);
       double stoploss = NormalizeDouble ( stopvalue+abit+(ATR*points),Digits());
      double swinglow=iClose (Symbol(),Period(),lowerLow);
     double  volume = NormalizeDouble(inpOrderSize,Digits());
  
       RefreshRates(); 
      spread= MarketInfo(Symbol(),MODE_SPREAD);
      double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
      double stopvalue;
      if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
         else stopvalue = spread*Point;
  
      double openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
       double stopLossPrice =  NormalizeDouble(swinghigh+stoploss,Digits());
       double takeProfit= NormalizeDouble ((stopLossPrice-openPrice)*multiplier,Digits());
      double takeProfitPrice =  NormalizeDouble(Ask-takeProfit,Digits());
      RefreshRates();
      int Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
      Alert ("sell- SL_   "+stopLossPrice+"TP-  "+takeProfitPrice);
 
 /// order 1
  
         int count = 0;
            while ((Docket == -1) && (count < 10))
         {
            RefreshRates();
           int Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);

             count++;
        
          }
          
 /// Order 2
          RefreshRates();
          takeProfitPrice =  NormalizeDouble(Ask-takeProfit-inpPips,Digits());
          Docket=-1;
          
     count = 0;
            while ((Docket == -1) && (count < 10))
         {
            RefreshRates();
           int Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);

             count++;
        
          }
 
 ///Order 3
         RefreshRates();
         
        takeProfitPrice =  NormalizeDouble(Ask-takeProfit-inpPips-inpPips,Digits());
          Docket=-1;
          
     count = 0;
            while ((Docket == -1) && (count < 10))
         {
            RefreshRates();
           int Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);

             count++;
        
          }
   
 ///Order 4
           RefreshRates();  
          takeProfitPrice =  NormalizeDouble(Ask-takeProfit-inpPips-inpPips-inpPips,Digits());
          Docket=-1;
          
     count = 0;
            while ((Docket == -1) && (count < 10))
         {
            RefreshRates();
           Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);

             count++;
        
          }
   
         if (Docket<0) Alert ("Order Send Error:" + GetLastError()+ "Symbol "+ Symbol()+ " timeframe: "+Period()+ inpTradeComments);
        
         
   
   
  }
 return (Docket);
 }
 
  
 
 
 //+------------------------------------------------------------------+  
 
 
 //// iF FOUNG LONG SIGNAL PREVIOUSLY - LOOK FOR ENTRY 
 
  
        
 
 int CheckLongTrade ( double higherHigh, double lowerLow,double multiplier, int XmarketTurnCounter)
 
 {
 
             double ATR                  = iATR(Symbol(),Period(),20,1);
            int Docket; 
            double abit;
            int digits = Digits();
            spread= MarketInfo(Symbol(),MODE_SPREAD);
            double points=MarketInfo(Symbol(),MODE_POINT);
            if (digits==4)  abit=enterStop/1000;
            if (digits==5) abit=enterStop/10000;
            if (digits==3) abit=enterStop/100;
               
             
        
        double stomain=iStochastic(Symbol(),Period(),3,3,14,MODE_SMA,0,MODE_MAIN,1);
        double stosig=iStochastic(Symbol(),Period(),3,3,14,MODE_SMA,0,MODE_SIGNAL,1);
       
 
 
 
          if ( (stomain>stosig) && (XmarketTurnCounter< inpMarketTurnCounter)&& (OpenOrders()<inpMaxOrders)) 
                 {
                       
                         
                        
                        double swingLow= iLow(Symbol(),Period(),lowerLow);
                        double stoploss = NormalizeDouble (stopvalue+abit+(ATR*Point),Digits());
                       
                       double multiplier=inpMultiplier; 
                       double volume = NormalizeDouble(inpOrderSize,Digits());
                       RefreshRates(); 
                            //--- get minimum stop level
                       double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
                       
                       if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
                       else stopvalue = spread*Point;
                       
                        double openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
                        double stopLossPrice =  NormalizeDouble(swingLow-stoploss,Digits());
                        double takeProfit= NormalizeDouble ((openPrice-stopLossPrice)*multiplier,Digits());
                        double takeProfitPrice =  NormalizeDouble(Bid+takeProfit,Digits());
                        RefreshRates();
                        Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                        
                        Alert ("Buy - SL -  "+stopLossPrice+"   TP- "+takeProfitPrice);
                        
 ///oRDER 1
                        int count = 0;
                                        while ((Docket == -1) && (count < 10))
                            {
                                    RefreshRates();
                                     Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                        
                                    count++;
                              }
                        
                        
        /////   oRDER2           
        RefreshRates();
        Docket=-1;
         takeProfitPrice =  NormalizeDouble(Bid+takeProfit+inpPips,Digits());           
             
                        
                          count = 0;
                                        while ((Docket == -1) && (count < 10))
                            {
                                    RefreshRates();
                                     Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                        
                                    count++;
                              }
                         
                        
                        
                                         
        /////   oRDER3          
        RefreshRates();
        Docket=-1;
         takeProfitPrice =  NormalizeDouble(Bid+takeProfit+inpPips+inpPips,Digits());             
             
                        
                          count = 0;
                                        while ((Docket == -1) && (count < 10))
                            {
                                    RefreshRates();
                                     Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                        
                                    count++;
                              }
                        
                                  
                                    
                                    if (Docket<0) Alert ("Order Send Error:" + GetLastError()+ "Symbol "+ Symbol()+ " timeframe: "+Period()+ inpTradeComments);
                                    
                      
                      
                            
        /////   oRDER4           
        RefreshRates();
        Docket=-1;
         takeProfitPrice =  NormalizeDouble(Bid+takeProfit+inpPips+inpPips+inpPips,Digits());           
             
                        
                          count = 0;
                                        while ((Docket == -1) && (count < 10))
                            {
                                    RefreshRates();
                                     Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                        
                                    count++;
                              }
                        
                                              
                      
                      
                      
                      
                       }
                       return (Docket);}
 
 
 
 
 //+------------------------------------------------------------------+  
 
 double GetShortStopValue()
 {
            double abit;
            int digits = Digits();
            spread= MarketInfo(Symbol(),MODE_SPREAD);
            if (digits==4)  abit=enterStop/1000;
            if (digits==5) abit=enterStop/10000;
            if (digits==3) abit=enterStop/100;
               
               
                //--- get minimum stop level
           double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
           
           if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
           else stopvalue = spread*Point;
           
           
           Alert ("stop value = "+stopvalue);
           
            Comment ("found long, wating for MACD cross");
 return (stopvalue);
 }
 //+------------------------------------------------------------------+  
 
 
 
 
 double GetLongStopValue ()
 {
  double abit;
  int digits = Digits();
   if (digits==4)  abit=enterStop/1000;
   if (digits==5) abit=enterStop/10000;
   if (digits==3) abit=enterStop/100;
      
      
       //--- get minimum stop level
  spread= MarketInfo(Symbol(),MODE_SPREAD);
  double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
  double stopvalue;
  if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
  else stopvalue = spread*Point;
  
  return (stopvalue);
 }
 
 
 
 
 
   int FindFirstHigh (int shoulder)
      {
      int highbar;
      highbar=1;
      for (int f=1;f<shoulder;f++)
      {
        if (iClose (Symbol(),Period(),highbar)<iClose (Symbol(),Period(), f+1)) highbar=f+1;
  
       }
    return (highbar);
   }
 
int FindSecondHigh (int firsthigh, int shoulder)
  {
   int highFound;
   highFound= shoulder;

   for (int t=shoulder;t<firsthigh;t--)
         {
  
         if ( (iClose(Symbol(),Period(),highFound))<(iClose(Symbol(),Period(),t-1))) highFound=t-1; 
  
         }
      
     return (highFound);
   }   
    

   int FindFirstLow (int shoulder)
      {
      int lowbar;
      lowbar=1;
   
   for (int f=1;f<shoulder;f++)
      {
  
      if (iClose (Symbol(),Period(),lowbar)>iClose (Symbol(),Period(), f+1)) lowbar=f+1;
  
       }
    return (lowbar);
   }
 
int FindSecondLow (int firstlow, int shoulder)

{

int lowFound;

lowFound= shoulder;

   for (int t=shoulder;t<firstlow;t--)
         {
  
         if ( (iClose(Symbol(),Period(),lowFound))>(iClose(Symbol(),Period(),t-1))) lowFound=t-1; 
  
         }
      
 return (lowFound);
}   

   









//+------------------------------------------------------------------+    
///// SEARCH FOR short SIGNAL

bool GetShortSignal (int Hbar1, int Hbar2, int higherHigh,int lowerHigh,bool HnotDiverging,double ATRFactor) 

{

if (higherHigh!=1) return (false);
 
  bool Hdivergence=false;
  
  
  
  double RSILow= iRSI(Symbol(),Period(),14,PRICE_CLOSE,lowerHigh);
  double RSIHigh= iRSI(Symbol(),Period(),14,PRICE_CLOSE,higherHigh); 
  
  if ((RSILow>RSIHigh) && (shortTrade())) Hdivergence=true; 
  
return (Hdivergence);
}




//+------------------------------------------------------------------+  

//looking  long signals



bool GetLongSignal (int Lbar1, int Lbar2, int lowerLow,int higherLow,bool LnotDiverging,double ATRFactor) 

{

if (lowerLow!=1) return (false);

 
 bool divergence;
 
  double RSILower= iRSI(Symbol(),Period(),14,PRICE_CLOSE,lowerLow);
  double RSIHigher= iRSI(Symbol(),Period(),14,PRICE_CLOSE,higherLow); 
    
  if ((RSILower>RSIHigher) && (longTrade()))divergence=true; 

return (divergence);

}



















//+------------------------------------------------------------------+    



int OpenOrders ()

  
  {
   int totalTrades=0;
 int count=OrdersTotal();
      
      for (int i=count-1;i>=0;i--)
      
      {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderSymbol()==Symbol())
            if (OrderMagicNumber()==inpMagicNumber)
                totalTrades++;
      }
      
      return (totalTrades);
      }

void ApplyTrailingStop(string symbol, int magicNumber)

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
      
      double BuyProfitRange= OrderTakeProfit()-OrderOpenPrice();
      double SellProfitRange= OrderOpenPrice()- OrderTakeProfit();
      
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
                  
                  if (Ask > Buyband50)
                      if (Ask < Buyband60)
                     
                        {                       
                        Buy50Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step50, digits);
                     
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask > Buyband60)
                     if (Ask< Buyband70)
                        {
                        Buy60Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step60, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask > Buyband70)
                    if (Ask< Buyband80)
                        {
                        Buy70Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step70, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask > Buyband80)
                    if (Ask<Buyband90)  
                        {                       
                        Buy80Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-step80, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Ask >  Buyband90)                       
                        {
                        Buy90Stop=true;
                        buyStopLoss = NormalizeDouble(Ask-StopSteps, digits);
                        
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
              
                  }            
                  
                  
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                  if (Bid < Sellband50)
                     if (Bid> Sellband60)
                        
                        {
                        Sell50Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step50, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }
                  if (Bid < Sellband60)
                     if (Bid> Sellband70)
                        {
                        Sell60Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step60, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid < Sellband70)
                    if (Bid> Sellband80)
                        {
                        Sell70Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step70, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid < Sellband80)
                    if (Bid> Sellband90)
                        {
                        Sell80Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+step80, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  if (Bid <Sellband90)
                        {
                        Sell90Stop=true;
                        sellStopLoss = NormalizeDouble(Bid+StopSteps, digits);
                        
                        if (sellStopLoss<OrderStopLoss())
                                     OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                  }            
             
                    
                    
                    
                    
 ////////////////////FOLLOWING STOPS==========================================
 
      
      if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                  
                        buyStopLoss = NormalizeDouble(Ask-trailingStop, digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                                   
                    
                    
                
         if (OrderSymbol()==symbol)
            if (OrderMagicNumber()==magicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                        sellStopLoss = NormalizeDouble(Bid+trailingStop, digits);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }                
                    
                    
                    
                    
                    
                    
                    
                          
      }
      }











  
  bool shortTrade ()
  {
  bool shorty;
  shorty=false;
  bool SignalGoShort=false;
  
  
  double Shorttop= iMA(Symbol(),PERIOD_H1,600,0,MODE_EMA,PRICE_HIGH,1);
  double Shortbottom=iMA(Symbol(),PERIOD_H1,150,0,MODE_EMA,PRICE_HIGH,1);
  
  double twohundrMA=iMA(Symbol(),Period(),200,0,MODE_EMA,PRICE_CLOSE,1);
  
    
  if   (Bid<twohundrMA)
      shorty= true;
      
  return (shorty);
  }
  
  
  bool longTrade ()
  
  {
  bool longie;
  longie=false;
 
  double twohundrMA=iMA(Symbol(),Period(),200,0,MODE_EMA,PRICE_CLOSE,1);
  
  
  
  double Longtop= iMA(Symbol(),PERIOD_H1,600,0,MODE_EMA,PRICE_LOW,1);
  double Longbottom=iMA(Symbol(),PERIOD_H1,150,0,MODE_EMA,PRICE_LOW,1);
  
      
  if (Ask>twohundrMA)longie= true;
  
   
 return(longie); 
  }
  
  
  //+------------------------------------------------------------------+
  
  
  
  
  
  
  //+------------------------------------------------------------------+
   
  int FindPeak (int mode, int count, int startBar){
  
   if (mode!= MODE_HIGH && mode!=MODE_LOW) return (-1);
  
   int currentBar = startBar;
   int foundBar= FindNextPeak (mode,count*2+1, currentBar-count);
   while (foundBar!=currentBar) {
      currentBar  = FindNextPeak (mode,count, currentBar+1);
      foundBar    = FindNextPeak (mode,count*2+1, currentBar-count);
      }
      return (currentBar);
}
   
int FindNextPeak (int mode, int count, int startBar){

   if (startBar<0) {
      count+=startBar;
      startBar=0;
      }
      return( ( mode==MODE_HIGH)?
         iHighest(Symbol(),Period(),(ENUM_SERIESMODE)mode,count,startBar):
         iLowest(Symbol(),Period(),(ENUM_SERIESMODE)mode, count,startBar)
         );
         
            
  }
//+------------------------------------------------------------------+



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
      
      ticket = OrderSend (Symbol(), orderType,inpOrderSize, openPrice,10,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      





  
//+------------------------------------------------------------------+
