//+------------------------------------------------------------------+
//|                              MACD divergence strategy tester.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com

// use on 4 hours only
// uses weekly range to calculate pivots
// trades first and subsquent impulses



//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input  double              inpSLfactor= 0.25;// enter factor of current period range to act as stoploss
input double               inpPercentile     = 10; // input percentile to check proximity of price to pivot
double  inpMaxStoploss    =0.0005;// input maximum stop value
input double   inpMaxSpread         = 400;// input maximum spread in points to trade
input double    ATRFactor=             2.5;// enter ATR Factor for Keltner Channel for trade location
int    inplookback          = 5;  // lookback period?
 double      enterStop         =  2; // Enter Stop in pips to add to peak
input double   inpOrderSize      =  0.3;  //Order size for each order
input double   enterTP           =  2; // Enter take profit as multiple of stoploss
int   entMaxtrades        =  6;// Enter the maximum number of trades to enter at one time (each with increasing stoploss

input bool     tradecontinuously  = true; // trade contiuously- Yes- default
 int               entfastema = 12; // fast ema of MACD
 int               entslowema = 26;//  slow ema of MACD
int               entsignal  = 9;//   signal of MACD
 
input string   inpTradeComments  =  "Camarilla trend entry v1";  //Trade comment

input int      inpasxCrosstrigger=  36; // Enter maximum ADX trigger on daily chart for trade 
input double   inpMagicNumber    =  123; //Magic number
double spread;
double stopvalue;
  static bool waitingForLong=false;
  static bool waitingForShort=false;
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


  // if you are in a long trade check if prices below stoploss price -  if so open a second sell trade with double the lot size
  
  // if you are in a sell trade check if price above stoploss price - of so open a second buy trade with double the lot size
  
  // if you have an open buy and sell trade monitor the profit on each and if the total profit is 0 close both trades

 static bool completed=false;
static int Docket=0;
static int countdown=0;
int multiplier;

 if (!newBar()) return;  //only trade on new bar
 
// for one trade at a time
if ((completed==true) && (tradecontinuously==false)) return;


 /// below is for continuous trading
if ((completed==true) && (tradecontinuously==true)) 

      {
 
         OrderSelect (Docket,SELECT_BY_TICKET);
            if (OrderCloseTime()==0) 
               { Alert ("New trades suspended,waiting for trade to close");
               return;}
                           else
                              {  completed=false;
                                 trades=0;
                                 countdown=0;
                                 waitingForLong=false;
                                 waitingForShort=false;

      }                          }





/// variables
int  ADXcrossesPeriod=14;

double b4plusdi; 
double  nowplusdi; 
double  b4minusdi ;
double  nowminusdi ;
   


 double volume;
  bool priceExtreme;
  int adxtrigger =iADX(Symbol(), PERIOD_D1, 14, PRICE_CLOSE, MODE_MAIN,1 );
 int ticket=0;
 double takeProfitPrice;
 double stopLossPrice;
  static bool   tradeLong=false;
  static bool notDiverging=false;
  double abit;
  double openPrice;
  int shoulder;
  int bar1;
  int bar2;
  int xbar1;
  int xbar2;
  static bool divergence = false;
  double sixHundred = iMA(Symbol(),Period(),600,0,MODE_EMA, PRICE_CLOSE,1);
  double oneFifty = iMA(Symbol(),Period(),150,0,MODE_EMA, PRICE_CLOSE,1);
  double fiftyma= iMA (Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,1);
  double fiftymab4= iMA(Symbol(),Period(),50,0,MODE_SMA,PRICE_CLOSE,2);
  double twohundrMA=iMA(Symbol(),PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,1);
  static bool goLong=false;
  static bool goShort=False;
  static int higherLow = 0; 
  static int lowerLow = 0;
  static int higherHigh = 0; 
  static int lowerHigh = 0;
  static bool pass=true;
  static bool shortpass=true;


////  trailing stops


UpdateStops (Docket);


///  trailing stops above

  
 goLong=false;
 goShort=false;
 
 
  if 
  ( GolongCondit()==true )
   
   
   goLong= true;
   else goLong=false;
   
  
  if 
  ( GoshortCondit()==true)
   
   
   goShort= true;
   else goShort=false;
  
  
  
  
 
  
       
       
 Comment (" Spread =  "+MarketInfo(Symbol(),MODE_SPREAD)+ "  Minimum stop = "+  MarketInfo(Symbol(),MODE_SPREAD));
      
       
       
      if (trades == entMaxtrades) return; 
  
  
  
  
  if ((waitingForShort== true) && (countdown<10)) 
  
  {
  
          countdown=countdown+1;
 
          Alert ("Divergence found - waiting for adx cross to enter Long");
  
           //Comment ("found short, wating for MACD cross");
  
  
          int digits = Digits();
          if (digits==4)  abit=enterStop/1000;
          if (digits==5) abit=enterStop/10000;
           if (digits==3) abit=enterStop/100;
      
      
       //--- get minimum stop level and spread to decide to trade
       
         spread= MarketInfo(Symbol(),MODE_SPREAD);
         double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
         double stopvalue;
         if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
         else stopvalue = spread*Point;
    
           double swinghigh= iHigh(Symbol(),Period(),higherHigh+countdown);
  
           //if ((swinghigh+stopvalue-Bid) >inpMaxStoploss) pass=true;
           // else pass=false;
  pass=false;
  
        b4plusdi = iADX(Symbol(),Period (), ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, 2);
        nowplusdi = iADX(Symbol(), Period(), ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, 1);
        b4minusdi = iADX(Symbol(), Period (), ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, 2);
        nowminusdi = iADX(Symbol(), Period() , ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, 1);  
       
    
            if (
              
              (b4plusdi > b4minusdi) && (nowplusdi < nowminusdi)&&
              
                (stopvalue< inpMaxSpread)&&
                  (pass==false)) 
           
           
           
                         {  
                               double swinghigh= iHigh(Symbol(),Period(),higherHigh+countdown);
                               double stoploss = NormalizeDouble ( stopvalue+abit,Digits());
                               volume = NormalizeDouble(inpOrderSize,Digits());
                               RefreshRates(); 
                               spread= MarketInfo(Symbol(),MODE_SPREAD);
                               double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
                               double stopvalue;
                               if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
                                   else stopvalue = spread*Point;
                               
                               
                               double stp1= GetAveragePeriodRange()*inpSLfactor;
  
                              openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
                              stopLossPrice =  NormalizeDouble(swinghigh+stp1,Digits());
                              double takeProfit= NormalizeDouble ((stopLossPrice-openPrice)*enterTP,Digits());
                              takeProfitPrice =  NormalizeDouble(Ask-takeProfit,Digits());
                              RefreshRates();
                              Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                              Alert ("sell- SL_   "+stopLossPrice+"TP-  "+takeProfitPrice);
                      
  
                              int count = 0;
                               while ((Docket == -1) && (count < 10))
                                           {
                                              RefreshRates();
                                             Docket= OrderSend (Symbol(),ORDER_TYPE_SELL,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                                              count++;
        
                                            }
  
  
  
  
                                  if (Docket >0)
                                             {
                                                Comment ("open price ="+openPrice+"stopLossPrice "+stopLossPrice+"take Profit "+takeProfitPrice);
                                                trades=trades+1;
                                                completed=true;
                                                tradeLong= false;
                                             }
   
   
     
                                 if (Docket<0) Alert ("Order Send Error:" + GetLastError()+ "Symbol "+ Symbol()+ " timeframe: "+Period()+ inpTradeComments);
                                 return;
                             }
       }
  
  
  if ((waitingForLong==true) && (countdown<10))
  
  {
  
            Alert ("Divergence found - waiting for MACD cross to enter Short");
            countdown=countdown+1;
   
            int digits = Digits();
            spread= MarketInfo(Symbol(),MODE_SPREAD);
            if (digits==4)  abit=enterStop/1000;
            if (digits==5) abit=enterStop/10000;
            if (digits==3) abit=enterStop/100;
      
      
            //--- get minimum stop level
            double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
  
             if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
                     else stopvalue = spread*Point;
  
  
            double swingLow= iLow(Symbol(),Period(),lowerLow+countdown);
  
           // if (Ask-swingLow-stopvalue>inpMaxStoploss) shortpass=true; 
                  //else shortpass=false;
            shortpass=false;
  
            Comment ("found long, wating for MACD cross");
   
   
            b4plusdi = iADX(Symbol(),Period (), ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, 2);
            nowplusdi = iADX(Symbol(), Period(), ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, 1);
            b4minusdi = iADX(Symbol(), Period (), ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, 2);
            nowminusdi = iADX(Symbol(), Period() , ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, 1); 
   
   
                  if (
                      (b4plusdi < b4minusdi) && (nowplusdi > nowminusdi)&&
                      (stopvalue<inpMaxSpread)&&
                      (shortpass==false)) 
                           
                             {
  
      
                                    swingLow= iLow(Symbol(),Period(),lowerLow+countdown);
                                    
                                    double stp= GetAveragePeriodRange()*inpSLfactor;
                                    
                                    double stoploss = NormalizeDouble (stp,Digits());
                                    volume = NormalizeDouble(inpOrderSize,Digits());
                                    RefreshRates(); 
   
                                    //--- get minimum stop level
                                   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);       
                                    if (minstoplevel>spread) stopvalue =minstoplevel*Point; 
                                        else stopvalue = spread*Point;
  
                                    openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
                                     stopLossPrice =  NormalizeDouble(swingLow-stp,Digits());
                                    double takeProfit= NormalizeDouble ((openPrice-stopLossPrice)*enterTP,Digits());
                                    takeProfitPrice =  NormalizeDouble(Bid+takeProfit,Digits());
                                    RefreshRates();
                                    Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
   
                                    Alert ("Buy - SL -  "+stopLossPrice+"   TP- "+takeProfitPrice);
   
                                     int count = 0;
                                     while ((Docket == -1) && (count < 10))
                                            {
                                                 RefreshRates();
                                                   Docket = OrderSend (Symbol(),ORDER_TYPE_BUY,volume,openPrice,10,stopLossPrice,takeProfitPrice,inpTradeComments,inpMagicNumber,0,0);
                                                    count++;
                                             }
      
   
                                                   if (Docket>0) 
                                                     {
                                                         Comment ("open price ="+openPrice+"stopLossPrice "+stopLossPrice+"take Profit "+takeProfitPrice);
                                                         trades=trades+1;
                                                         completed=true;
                                                         tradeLong=true;
                                                       }
   
                                                   if (Docket<0) Alert ("Order Send Error:" + GetLastError()+ "Symbol "+ Symbol()+ " timeframe: "+Period()+ inpTradeComments);
     
         
                                                   return;
                                     } 
              }
 
 
  
  
  
      if (countdown==10) 
                   {countdown=0;
                    waitingForLong=false;
                    waitingForShort=false;
                    completed=false;} 
  
    ////search for new trades
  
  shoulder=0;
  
   for (int t=2;t<inplookback;t++)
         
         
         
         {
  
                     shoulder=shoulder+1;
  
                   /// search for trade   
  
                    
  
  
                       bar1 = FindPeak (MODE_HIGH, shoulder,0);
                       bar2 = FindPeak(MODE_HIGH, shoulder, bar1+1);
                      
                      //near keltner
                      
 
                        double KeltnerMovingAverage = iMA(Symbol(),Period(),20,0,MODE_EMA,PRICE_TYPICAL,1);
                 
                         double ATR                  = iATR(Symbol(),Period(),20,1);
                        double KeltnerBandShift     = ATR*ATRFactor;
                        double KeltnerUpperBand     = KeltnerMovingAverage+KeltnerBandShift;
                        double KeltnerLowerBand     = KeltnerMovingAverage-KeltnerBandShift; 
                
 
                         ObjectDelete (0,"upper");
                         ObjectCreate (0,"upper",OBJ_TREND,0,iTime (Symbol(),Period(),bar2),iHigh(Symbol(),Period(),bar2), iTime (Symbol(),Period(),bar1),iHigh(Symbol(),Period(),bar1));
                         ObjectSetInteger(0,"upper",OBJPROP_COLOR,clrBlue);
                         ObjectSetInteger(0, "upper",OBJPROP_WIDTH,3);
                         ObjectSetInteger(0, "upper",OBJPROP_RAY_RIGHT, true);
                    
                          static bool notrade=true;
                          double PriceA =iHigh (Symbol(),Period(),bar1);
                          double PriceB=iHigh (Symbol(),Period(),bar2);
                          if (PriceA>=PriceB)
                                  {
                                    higherHigh = bar1; 
                                    lowerHigh = bar2;
                                    notDiverging=false;}
                                             else
                                              {  higherHigh = bar2; 
                                                lowerHigh = bar1;
                                                notDiverging=true;
                                                }
 



         
                         /// Looking at the highs for trades -SHORT
                         
                         priceExtreme=false;
                         
                                      double rsilow= iRSI(Symbol(),Period(),14,PRICE_CLOSE,lowerLow);
                                      double rsihigh= iRSI(Symbol(),Period(),14,PRICE_CLOSE,higherLow); 
                        
                        
                          
                          notrade=false;
                          
                           
                           double PriceHigh =iHigh (Symbol(),Period(),higherHigh);
                          if (PriceHigh>KeltnerUpperBand) priceExtreme= true;
                          
                          if ( (goShort==true) &&  (adxtrigger>inpasxCrosstrigger) && (priceExtreme==true)) 
                                    {
                                    divergence=true;
                                     waitingForShort=true;
                                     countdown=0;
                                     break;
                                    }
                          
                            
                             // if ((MACDLow<MACDHigh) && (goShort==true)) divergence=false;
                              
                     
                       
                                      // now look at low points for long trades
                                      
                                      priceExtreme=false;
                                      
                                      xbar1 = FindPeak (MODE_LOW  , shoulder,0);
                                      xbar2 = FindPeak(MODE_LOW, shoulder, xbar1+1);
                                      
                                      ObjectDelete (0,"lower");
                                      ObjectCreate (0,"lower",OBJ_TREND,0,iTime (Symbol(),Period(),xbar2),iLow(Symbol(),Period(),xbar2),iTime (Symbol(),Period(),xbar1), iLow(Symbol(),Period(),xbar1));
                                      ObjectSetInteger(0,"lower",OBJPROP_COLOR,clrBlue);
                                      ObjectSetInteger(0, "lower",OBJPROP_WIDTH,3);
                                      ObjectSetInteger(0, "lower",OBJPROP_RAY_RIGHT, true);
                                     
                                      double Price1 =iLow (Symbol(),Period(),xbar1);
                                      double Price2=iLow (Symbol(),Period(),xbar2);
                                      if (Price1<Price2)
                                           {
                                             higherLow = xbar2; 
                                             lowerLow = xbar1;
                                             notDiverging=false;
                                           }
                                      else
                                           {higherLow = xbar1; 
                                             lowerLow = xbar2;
                                             notDiverging=true;}
                                    
                       //// lOOK FOR rsi DIVERGENCE
                       
                                     
                                      double RSIlower= iRSI(Symbol(),Period(),14,PRICE_CLOSE,lowerLow);
                                      double RSIhigher= iRSI(Symbol(),Period(),14,PRICE_CLOSE,higherLow); 
                                      
                                      double PriceLow =iLow (Symbol(),Period(),lowerLow);
                                      if (PriceLow<KeltnerLowerBand) priceExtreme= true;
                                      
                                          
                                            notrade=false;
                                            
                           if ( (goLong==true)&& (adxtrigger>inpasxCrosstrigger) && (priceExtreme==true))
                           
                                      {divergence=true; 
                                       countdown=0; 
                                       waitingForLong=true;
                                       break;} 
         
                               //if ((MACDLower<MACDHigher) && (goLong==true)){   
                               // divergence=false;}
            
            
   
          }}
   
   ////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
   
   
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
      


bool GolongCondit ()

{

double High1= iHigh(Symbol(),PERIOD_W1,1);
double Low1= iLow(Symbol(),PERIOD_W1,1);
double Close1= iClose(Symbol(),PERIOD_W1,1);
double Pivot1= (High1+Low1+Close1)/3;

double High2= iHigh(Symbol(),PERIOD_W1,2);
double Low2= iLow(Symbol(),PERIOD_W1,2);
double Close2= iClose(Symbol(),PERIOD_W1,2);
double Pivot2= (High2+Low2+Close2)/3;

double High3= iHigh(Symbol(),PERIOD_W1,3);
double Low3= iLow(Symbol(),PERIOD_W1,3);
double Close3= iClose(Symbol(),PERIOD_W1,3);
double Pivot3= (High3+Low3+Close3)/3;

double Range1= High1-Low1;
double tenpercentile= Range1/inpPercentile;
double uppertarget = Ask+tenpercentile;
double lowertarget = Ask-tenpercentile;
bool proximity;

if (Ask<uppertarget)
   if (Ask> lowertarget)
      proximity=true;
         else proximity=false;


double twohundrMA=iMA(Symbol(),PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,1);

bool longtrend;

longtrend= false;

//if (Pivot3<Pivot2)
  // if (Pivot1>Pivot2)
    //  if (Ask  >twohundrMA)
      //   longtrend=true;
         
if (Pivot3>Pivot2)
   if (Pivot1>Pivot2)
   if (Ask>twohundrMA)
        longtrend=true;

if ((proximity== true)&& (longtrend==true))
      return(true);
         else return(false);

}

bool GoshortCondit ()


{


double High1= iHigh(Symbol(),PERIOD_D1,1);
double Low1= iLow(Symbol(),PERIOD_D1,1);
double Close1= iClose(Symbol(),PERIOD_D1,1);
double Pivot1= (High1+Low1+Close1)/3;

double High2= iHigh(Symbol(),PERIOD_D1,2);
double Low2= iLow(Symbol(),PERIOD_D1,2);
double Close2= iClose(Symbol(),PERIOD_D1,2);
double Pivot2= (High2+Low2+Close2)/3;

double High3= iHigh(Symbol(),PERIOD_D1,3);
double Low3= iLow(Symbol(),PERIOD_D1,3);
double Close3= iClose(Symbol(),PERIOD_D1,3);
double Pivot3= (High3+Low3+Close3)/3;

double Range1= High1-Low1;
double tenpercentile= Range1/inpPercentile;
double uppertarget = iHigh(Symbol(),Period(),1)+tenpercentile;
double lowertarget = iLow(Symbol(),Period(),1)-tenpercentile;
bool proximity;

if ((Pivot1<uppertarget)&& (Pivot1> lowertarget))
      proximity=true;
         else proximity=false;

Alert ("Proximity = "+proximity);
double twohundrMA=iMA(Symbol(),PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,1);

bool shorttrend;

shorttrend= false;

//if (Pivot3>Pivot2)
  // if (Pivot1<Pivot2)
    //  if (Bid < twohundrMA)
      //   shorttrend=true;
      
if (Pivot3<Pivot2)
   if (Pivot1<Pivot2)
      if (Bid<twohundrMA);
      shorttrend=true;

if ((proximity==true)&& (shorttrend==true))
      return (true);
         else return (false);
      
}




 void UpdateStops(int Ticket)
 
 {                   
                    
 ////////////////////FOLLOWING STOPS==========================================
 
      double newstoploss;
      OrderSelect(SELECT_BY_TICKET,Ticket);
      
      
     
            if (OrderMagicNumber()==inpMagicNumber)
               if (OrderType()==ORDER_TYPE_BUY)
               
                { 
                        newstoploss= iIchimoku(Symbol(),Period(), 9,26,52,MODE_KIJUNSEN,1);
                        
                        
                        double buyStopLoss = NormalizeDouble(newstoploss, Digits);
                        if (buyStopLoss>OrderStopLoss())
                           OrderModify(OrderTicket(), OrderOpenPrice(),buyStopLoss,OrderTakeProfit(),OrderExpiration());
                        }
                                   
                    
                    
        
            if (OrderMagicNumber()==inpMagicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
               
                { 
                
                         newstoploss= iIchimoku(Symbol(),Period(), 9,26,52,MODE_KIJUNSEN,1);
                       
                        
                        double sellStopLoss = NormalizeDouble(newstoploss, Digits);
                        if (sellStopLoss<OrderStopLoss())
                          OrderModify(OrderTicket(), OrderOpenPrice(),sellStopLoss,OrderTakeProfit(),OrderExpiration());
                        
                        }                
                    
  }                  
                    

double GetAveragePeriodRange ()

{

double d1=iHigh(Symbol(),Period(),1)-iLow (Symbol(),Period(),1);
double d2=iHigh(Symbol(),Period(),2)-iLow (Symbol(),Period(),2);
double d3=iHigh(Symbol(),Period(),3)-iLow (Symbol(),Period(),3);
double d4=iHigh(Symbol(),Period(),4)-iLow (Symbol(),Period(),4);
double d5=iHigh(Symbol(),Period(),5)-iLow (Symbol(),Period(),5);
double d6=iHigh(Symbol(),Period(),6)-iLow (Symbol(),Period(),6);


double d7=iHigh(Symbol(),Period(),7)-iLow (Symbol(),Period(),7);
double d8=iHigh(Symbol(),Period(),8)-iLow (Symbol(),Period(),8);
double d9=iHigh(Symbol(),Period(),9)-iLow (Symbol(),Period(),9);
double d10=iHigh(Symbol(),Period(),10)-iLow (Symbol(),Period(),10);
double d11=iHigh(Symbol(),Period(),11)-iLow (Symbol(),Period(),11);
double d12=iHigh(Symbol(),Period(),12)-iLow (Symbol(),Period(),12);

double Average= (d1+d2+d3+d4+d5+d6+d7+d8+d9+d10+d11+d12)/12;
return (Average);


}


  
//+------------------------------------------------------------------+
