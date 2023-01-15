//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//|
//  Code is from http://www.orchardforex.com 
//  title of You tube video is "Biginners guide : Write your own RSI expert advisor for MT4
///version 4 - stoploss at zero 
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int      inpBarcounterExit         =  576;// how many bars to exit trade 5min=576 (48 hrs recomended)
input bool     tradecontinuously  = true; // trade contiuously? or one trade only?
input double   inpATRMultipleStop      =  1.5;//ATR multiplier for stop loss
input double   inpATRMultiple      =  1.5;//ATR multiplier for take profit
input double   inpOrderSize      =  0.1;  //Order size
input string   inpTradeComments  =  "TTM Squeeze-v4";  //Trade comment
input double   inpMagicNumber    =  00000001; //Magic number
 int static inpRSIPeriods=1;
 
 bool static completed=false;
         int SignalGoLong=0;
         int SignalGoShort=0;
        int static ticket=0; 
        int static squeeze=0;
        int static squeezeFired=0;
        double spread;
        int barcounter =0;
        int static inAtrade =0;
        int static BarsTillClose;

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
   
   
   
// for one trade at a time

if ((completed==true) && (tradecontinuously==false)) return;


 /// below is for continuous trading

  OrderSelect (ticket,SELECT_BY_TICKET);
  
if ((completed==true) && (tradecontinuously==true)&& (OrderCloseTime()==0)) {
 
     barcounter=barcounter+1;
     
     BarsTillClose= inpBarcounterExit-barcounter;
     
     Alert ("In a trade for: "+barcounter+ "/NL"+ "bars till close= "+BarsTillClose);}


   if ((barcounter>inpBarcounterExit) && (inAtrade==1))
      { 
      Alert ("closing order");
       double askprice= MarketInfo(OrderSymbol(),MODE_ASK);
       OrderSelect (ticket,SELECT_BY_TICKET);
       OrderClose(OrderTicket(),OrderLots(),askprice,10,Red);}
       
    if ((barcounter>inpBarcounterExit)&&(inAtrade==2))
    {
      Alert ("closing order");
      double bidprice= MarketInfo(OrderSymbol(),MODE_BID); 
      OrderSelect (ticket,SELECT_BY_TICKET);
      OrderClose(OrderTicket(),OrderLots(),bidprice,10,Red);}


if (ticket!=0) 

{OrderSelect (ticket,SELECT_BY_TICKET);

if ((completed==true) && (tradecontinuously==true) && (OrderCloseTime()==0)) return;
else 
{completed=false;
ticket=0;
inAtrade=0;
barcounter=0;
SignalGoLong=0;
SignalGoShort=0;
squeezeFired =0;
squeeze=0;
}}




   
   
   
   
   
// Variables
       
        int static direction=0;
        double static inpStopLoss=0;
        double static inpTakeProfit =0;
        int static SignalGoLong=0;
        int static SignalGoShort=0;

//// confirmation


double MA8= iMA(Symbol(),Period(),8,0,MODE_EMA, PRICE_CLOSE,1);

double MA21= iMA(Symbol(),Period(),21,0,MODE_EMA, PRICE_CLOSE,1);

double MA34= iMA(Symbol(),Period(),34,0,MODE_EMA, PRICE_CLOSE,1);

double MA55= iMA(Symbol(),Period(),55,0,MODE_EMA, PRICE_CLOSE,1);

double MA89= iMA(Symbol(),Period(),89,0,MODE_EMA, PRICE_CLOSE,1);

double MA89BF=iMA(Symbol(),Period(),89,0,MODE_EMA, PRICE_CLOSE,3);

double priceLevel = iClose(Symbol(),Period(),1);

if (
   (priceLevel>MA21) &&
    (MA89>MA89BF)&&
   (MA8>MA21) && (MA8>MA34)&& (MA8>MA55)&& (MA8>MA89)&&
   (MA21>MA34) && (MA21>MA55) && (MA8>MA89) &&
   (MA34>MA55) && (MA34>MA89) &&
   (MA55>MA89))SignalGoLong=1;
   else
   SignalGoLong=0; 
   
  if (
   (priceLevel<MA21) &&
   (MA89<MA89BF) &&
   (MA8<MA21) && (MA8<MA34)&& (MA8<MA55) && (MA8<MA89) &&
   (MA21<MA34) && (MA21<MA55) && (MA21<MA89) &&
   (MA34<MA55) && (MA34<MA89) &&
   (MA55<MA89))SignalGoShort=1;
   else
   SignalGoShort=0;  
   
   
   
   

// Keltner Band Calc

         double KeltnerMovingAverage = iMA(Symbol(),Period(),20,0,MODE_EMA,PRICE_TYPICAL,1);
         double ATR                  = iATR(Symbol(),Period(),20,1);
         double KeltnerBandShift     = ATR*1.5;
         double KeltnerUpperBand     = KeltnerMovingAverage+KeltnerBandShift;
         double KeltnerLowerBand     = KeltnerMovingAverage-KeltnerBandShift;

////// Is the squeeze on?
         double GetUpperBB          =  iBands(Symbol(),Period(),20,2,0,PRICE_TYPICAL, MODE_UPPER,1);
         double GetLowerBB          =  iBands(Symbol(),Period(),20,2,0,PRICE_TYPICAL, MODE_LOWER,1);
                
         if ((GetLowerBB<KeltnerLowerBand)&& (GetUpperBB<KeltnerUpperBand))squeeze=squeeze+1;
         
           Comment ("---------in the squeeze---------- for"+squeeze+" bars"+"/n" );
         if ((SignalGoLong==1)&& (priceLevel<MA21)) Comment ("Moving average alligned for long trade- aiting for price to rise over 21MA");
         if ((SignalGoShort==1) && (priceLevel>MA21))  Comment ("Moving averages alligned for a short trade- waiting for price to fall below 21MA");
         if ((priceLevel>MA21)&& (SignalGoLong==1))Comment ("In the squeeze for "+squeeze+ "bars-- "+ "All conditions met-waiting for squeeze to fire- to enter Long!");
         if ((priceLevel<MA21)&& (SignalGoShort==1))Comment ("In the squeeze for "+squeeze+ "bars-- "+"All conditions met-waiting for squeeze to fire- to enter Short!"); 
         if  ((SignalGoLong==0) &&(SignalGoShort==0)) Comment ("Moving averages not alligned");
   
  
//////  is the squeeze filing?

         if ((squeeze>0)&&(GetLowerBB>KeltnerLowerBand)&& (GetUpperBB>KeltnerUpperBand))
         {
         squeezeFired =1;
         squeeze=0;
         direction=0;
         Comment ("+++++Squeeze Firing!!!! ++++++");
         

////// Get direction

         if (iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE,MODE_MAIN,1)>iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE,MODE_MAIN,2)) direction= direction+1;
         else direction=direction-1;
         
         if (iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE,MODE_MAIN,2)>iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE,MODE_MAIN,3)) direction=direction+1;
         else direction=direction-1;
}
//////   Trade entry

              
      if ((ticket==0) &&(squeezeFired==1)&&( direction==2 ) && (SignalGoLong==1))  {
      inpStopLoss= ATR*inpATRMultipleStop;
      inpTakeProfit =ATR*inpATRMultiple;
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      
      if (ticket>0) inAtrade=1;}
      
      if ((ticket==0)&&(squeezeFired==1)&&(direction==-2)&&(SignalGoShort=1)) {

          
      inpStopLoss= ATR*inpATRMultipleStop;
      inpTakeProfit =ATR*inpATRMultiple;
      ticket  =  orderOpen (ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
       
      if (ticket>0)inAtrade=2;}
      
    
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
         
         takeProfitPrice = NormalizeDouble(openPrice+takeProfit,Digits());
         completed=true;
      }else if (orderType==ORDER_TYPE_SELL){
         openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
          stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
         completed=true;
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      