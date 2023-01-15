//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//| UPDATED WITH MOVING AVERAGE EXIT

//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//The Levels
input double               inpadxVal            =  40;  // input ADX value to enter trade

input int               inpMAperiod    =  200;  // Long moving average

input   bool            longOnly = false; // only long trades?
input   bool            shortOnly= false; // only short trades?
input   int             inpK           = 14; // Stochastic K value (14 default)
input   int             inpD           = 3;  //  Stochastic D value (3 default)
input   int             inpSlow       = 3;  // Stochastic K smoothing (1 default)
input double             inpStochasticUpperBand = 80;  /// stochastic trending upper band
input double             inpStochasticLowerBand =  20; //   stochastic trending lower band
double             inpStochasticHighQuad = 55;  /// stochastic upper quadrant
double             inpStochasticLowQuad =  45; ///  stochastic lower quadrant


input   int              inplookback =     2; // lookback period for Stochastic exit

int                    inpRSIPeriods  =  14;               //RSI Periods

input int                    inpMAshort        = 125;  // Short MA (for alignment of MA direction)
input int                  inpMedMA          =     100;//   Med Ma (for alignment of MA direction)




ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price
// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit

input double               inpTakeProfit  =  0.0;     //Take Profit in currency value
input double               inpStopLoss   =  0.0;     //Stop Loss in currecny value

///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.5;  //Order size
input int inptrendstrength  = 5 ; // Enter strength of trend 5 and above
input string   inpTradeComments  =  "Stocastic cross over";  //Trade comment
input double   inpMagicNumber    =  212123; //Magic number

static int lastTicket = -1;
static double previousDirection =0;
static bool closeLong=false;
static bool closeShort=false;
static bool tradeLongOpen=false;
static bool tradeShortOpen=false;      

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
   
   //// define variables for long ma, short ma, adx and direction  
     double LongMA = iMA(Symbol(),Period(),inpMAperiod,0,MODE_EMA, PRICE_MEDIAN,0);
     double ShortMA= iMA(Symbol(),Period(),inpMAshort,0,MODE_EMA, PRICE_MEDIAN,0);
     double MedMA= iMA(Symbol(),Period(),inpMedMA,0,MODE_EMA, PRICE_MEDIAN,0);
     
     double ADX=iADX(Symbol(),Period(),5,PRICE_MEDIAN,0,0);
     
     ///double direction= iMA(Symbol(),Period(),inpMAperiod,0,MODE_SMMA, PRICE_MEDIAN,0)-iMA (Symbol(),Period(),inpMAperiod,0,MODE_SMMA, PRICE_MEDIAN,1);
     
     
     /// positive= uptrend, negative = down trend
   
   ////// open   trades -----------------------------------------
   
   static bool longCross=false;
   static bool shortCross=false;
    
     double open= iOpen (Symbol(),Period(),0);
     double close = iClose (Symbol(),Period(),1);
     
     static int direction =0;  
     static int  ticket =0;
   
    if (!newBar()) return;  //only trade on new bar
    
  //   closeLong=false;
   //  closeShort=false;
   
if ((lastTicket!=-1) && (ticket==lastTicket))  {
 
OrderSelect (ticket,SELECT_BY_TICKET);
if (OrderCloseTime()!=0) 
{
   Comment ("trade is closed -");
   Comment ("reset all values");


   lastTicket=-1;
   ticket=0;
   tradeLongOpen=false;
   tradeShortOpen= false;
   closeLong=false;
   closeShort=false;   
   
  } }
      
 ////
      
double LongMABF = iMA(Symbol(),Period(),200,0,MODE_EMA, PRICE_MEDIAN,1);   
  
      
direction=0;
      
 if (Ask>LongMABF) direction =1;
 if ((Bid<LongMABF)) direction =-1;

double StoMain= iStochastic(Symbol(),Period(),inpK,inpD,inpSlow,MODE_SMA,0, MODE_MAIN,1); 
double StoMainB4= iStochastic(Symbol(),Period(),inpK,inpD,inpSlow,MODE_SMA,0, MODE_MAIN,2); 
     
   
Comment ("direction=" ,direction, "\n",
"Stochastics= ", StoMain ,"\n",
 "Stochasstics before= ",StoMainB4,"\n", 
 "Short cross=", shortCross,"\n",
 "long corss= ", longCross,"\n",
 "minimum stop = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));
 
///// clear overbought and oversold flags if in middle of range

if ((StoMain>inpStochasticLowerBand) && (StoMain<inpStochasticUpperBand)) {
longCross=false;
shortCross=false;}

// trade enter conditions  -

 if ((direction==-1) && (StoMain<inpStochasticLowerBand) )
 {shortCross= true;
 
 Comment ("\n","\n","\n","\n","\n","\n","\n","+++++++++++++++++++ long trade possible, waiting cross MA ");}
 
 if ((direction==1) &&  (StoMain>inpStochasticUpperBand))
 
 {longCross=true;
 Comment ("------------ short trade possible, waiting cross MA");
  } 
 
   
   
    //closing open trades
   
 // if ((tradeShortOpen==true) && (close>ShortMA)&&  (ticket==lastTicket)&&(longOnly==false))
   //  closeShort=true;
    
//   if ((tradeLongOpen==true)&& (close<ShortMA) &&(ticket==lastTicket)&&(shortOnly==false)) 
 //  closeLong=true;
   
        
   if ( (longCross==true) && (direction==1) &&(ticket!=lastTicket) && (ADX >inpadxVal) && (shortOnly==false))
     {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      lastTicket = ticket;
      previousDirection= direction;
      tradeLongOpen=true;
      tradeShortOpen=false;
      
     }
   else
      if ( (shortCross==true) && (direction==-1)&& (ticket!=lastTicket)&&(ADX>inpadxVal)&& (longOnly==false))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         lastTicket= ticket;
         previousDirection=direction;
         tradeLongOpen=false;
         tradeShortOpen=true;
         
        }
    
       
   double  closeBuyPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
   double closeSellPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
    
         
  if ((closeLong==true) && (ticket==lastTicket)&&(tradeLongOpen==true))
     {  OrderClose (lastTicket,inpOrderSize,closeBuyPrice,30,Red);
      lastTicket=-1;
      ticket=0;
   tradeLongOpen=false;
   tradeShortOpen= false;
   closeLong=false;
   closeShort=false; 
      }

   if ((closeShort==true) &&  (ticket==lastTicket)&& (tradeLongOpen==false))
      {OrderClose (lastTicket,inpOrderSize,closeSellPrice,30,Blue);
   lastTicket=-1;
   ticket=0;
   tradeLongOpen=false;
   tradeShortOpen= false;
   closeLong=false;
   closeShort=false; 
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
      
      int digits = Digits();
   double spread= MarketInfo(Symbol(),MODE_SPREAD);
   if (digits==4)spread=spread/100;
   if (digits==5) spread=spread/100;
   if (digits==2) spread=spread/10;
       
      
      
      
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
      
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss-spread,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
      }else if (orderType==ORDER_TYPE_SELL){
         openPrice = NormalizeDouble (SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss+spread,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
      return (ticket);
}
      