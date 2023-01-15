//+------------------------------------------------------------------+
//|                             RSI Stochastic 200 .mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com

//   RSI stochastics 200 ema - with lot size optimization -
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input double         lotsWinning = 0.1;// Enter lots after a win trade
input double         lotsLosses = 0.01;// Ebter lots after a losing trade
input int         inplookback =     20;// Enter number of bars to scan
input double      inpMultiplier        = 1.2;// input multiplier to increase risk reward

input          double    ATRFactor=             2.5;// enter ATR Factor for trend component
input          double   inpPips=0.0005;// enter pips to add to each consecutive trade
input double   enterStop         =  10; // Enter Stop in pips to add to peak



input int   inpMarketTurnCounter = 4;// enter maximum bars after signal to enter

input bool     tradecontinuously  = true; // trade contiuously? or one trade only?
int               entfastema = 12; // fast ema of MACD
int               entslowema = 26;//  slow ema of MACD
int               entsignal  = 9;//   signal of MACD
 
input string   inpTradeComments  =  "RSI STOCHASTIC 200 V60- loss adjuster";  //Trade comment

int      inpasxCrosstrigger=  36; // Enter maximum ADX trigger for trade (pretty useless)double   timeFrameConfimr  =  3; // enter period for higher time frame confirm (3= three times)

double   inpMagicNumber    = Ask  ; //Magic number
double spread;
double stopvalue;
 int shoulder;

int static trades=0;

double static LongLots =lotsLosses ;
double static ShortLots= lotsLosses;
static bool completed=false;




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

static int Docket=0;
static int marketTurnCounter=inpMarketTurnCounter;
  static int XmarketTurnCounter=inpMarketTurnCounter; 
  static bool shortFound=false;
  static bool longFound=false;  
  
  
  

 if (!newBar()) return;  //only trade on new bar
 
// for one trade at a time

//if ((completed==true) && (tradecontinuously==false)) return;


 ///below is for continuous trading

if (completed==true) {

OrderSelect (Docket,SELECT_BY_TICKET);

 if  (OrderCloseTime()==0) return;
else
{ Alert ("search for new trades");
LongLots = GetLongLotSize (Docket);
ShortLots= GetShortLotSize(Docket);
completed=false;
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
 if (   (stomain>stosig)&& (marketTurnCounter< inpMarketTurnCounter)&& (completed!=true)) 
  
 {
     
      marketTurnCounter=marketTurnCounter+1;
    
       multiplier=inpMultiplier; 
       double swinghigh= iHigh(Symbol(),Period(),higherHigh);
       double stoploss = NormalizeDouble ( stopvalue+abit+(ATR*points),Digits());
      double swinglow=iClose (Symbol(),Period(),lowerLow);
     double  volume = NormalizeDouble(ShortLots,Digits());
  
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
     if (Docket>0) completed=true;
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
       
 
 
 
          if ( (stomain>stosig) && (XmarketTurnCounter< inpMarketTurnCounter)  &&  (completed!=true) ) 
                 {
                       
                         
                        
                        double swingLow= iLow(Symbol(),Period(),lowerLow);
                        double stoploss = NormalizeDouble (stopvalue+abit+(ATR*Point),Digits());
                       
                       double multiplier=inpMultiplier; 
                       double volume = NormalizeDouble(  LongLots,Digits());
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
                        if (Docket>0) completed=true;
                      
                       }
                       return (Docket);}
 
 
 
 
 //+------------------------------------------------------------------+  
 
 double GetLongLotSize (int ticket)
 
 {
 
double Lots;
OrderSelect (ticket,SELECT_BY_TICKET);

 if ((OrderType()==ORDER_TYPE_BUY) && (OrderProfit()>0)) Lots = lotsWinning;
 if ((OrderType()==ORDER_TYPE_BUY) && (OrderProfit()<0)) Lots = lotsLosses;
return(Lots);
 }
 
 double GetShortLotSize (int ticket)
 
 {
 
 double Lots;
OrderSelect (ticket,SELECT_BY_TICKET);
 if ((OrderType()==ORDER_TYPE_SELL) && (OrderProfit()>0)) Lots = lotsWinning;
 if ((OrderType()==ORDER_TYPE_SELL) && (OrderProfit()<0)) Lots = lotsLosses;
return(Lots);
 
 }
 
 
 
 
 
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
  
  if (RSILow>RSIHigh) Hdivergence=true; 
  
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
    
  if (RSILower>RSIHigher) divergence=true; 

return (divergence);

}



















//+------------------------------------------------------------------+    
  
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
      
  return (true);
  }
  
  
  bool longTrade ()
  
  {
  bool longie;
  longie=false;
 
  double twohundrMA=iMA(Symbol(),Period(),200,0,MODE_EMA,PRICE_CLOSE,1);
  
  
  
  double Longtop= iMA(Symbol(),PERIOD_H1,600,0,MODE_EMA,PRICE_LOW,1);
  double Longbottom=iMA(Symbol(),PERIOD_H1,150,0,MODE_EMA,PRICE_LOW,1);
  
      
  if (Ask>twohundrMA)longie= true;
  
   
 return(true); 
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
   
   int orderOpen (ENUM_ORDER_TYPE orderType,double LotSize ,double stopLoss, double takeProfit){
      
      int   ticket;
      double openPrice;
      double stopLossPrice;
      double takeProfitPrice;
      
      double lots= NormalizeDouble(LotSize, Digits());
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
      
      ticket = OrderSend (Symbol(), orderType,lots, openPrice,10,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      





  
//+------------------------------------------------------------------+
