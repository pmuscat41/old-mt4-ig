//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com 
//| UPDATED WITH MOVING AVERAGE EXIT

//+------------------------------------------------------------------+
#property copyright "Copyright 2022PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//The Levels

input double            inpMultiplier = 3;// input multiplier for take profit
input double               pips=  0.0005;// pips to add to swing high/low stop
input   bool            longOnly = false; // only long trades?
input   bool            shortOnly= false; // only short trades?
input   int             inpK           = 14; // Stochastic K value (14 default)
input   int             inpD           = 3;  //  Stochastic D value (3 default)
input   int             inpSlow       = 3;  // Stochastic K smoothing (1 default)
input double             inpStochasticUpperBand = 80;  /// stochastic trending upper band
input double             inpStochasticLowerBand =  20; //   stochastic trending lower band



ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price



///Standard inputs - you should have this in every EA

input double   inpOrderSize      =  0.5;  //Order size
input string   inpTradeComments  =  "Best Stochastic strategy 15m- Mean Revision";  //Trade comment
input double   inpMagicNumber    =  1; //Magic number

static int lastTicket = -1;
double inpRSIPeriods=2;



bool static longSignal1=false;
bool static shortSignal1=false;
bool static longSignal2=false;
bool static shortSignal2=false;
bool static longSignal3=false;
bool static shortSignal3=false;
bool static longtrigger=false;
bool static shorttrigger=false;

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

   
double stoMain15=iStochastic(Symbol(), PERIOD_M15, inpK,inpD,inpSlow,0,1,MODE_MAIN,0);
double stoSignal15= iStochastic(Symbol(), PERIOD_M15, inpK,inpD,inpSlow,0,1,MODE_SIGNAL,0);



int static counter=0;
int static ticket=0;
int static lastTicket=-1;
static double high;
static double low;
double stop;
static double entrylong=0;
static double entryshort=0;




  
    
  
  
  
/////debugging loop ------------------------------------------------------------------------------------------------------

  
// reset after trade closes

    if ((lastTicket!=-1) && (ticket==lastTicket)) 
    
     {
 
      OrderSelect (ticket,SELECT_BY_TICKET);
      if (OrderCloseTime()!=0) 
         {
            lastTicket=-1;
            ticket=0;
            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;
            longtrigger=false;
            shorttrigger=false;
            counter=0;}
               
        if (OrderType()== OP_BUYSTOP || OP_SELLSTOP) counter++;
        if (counter==5) OrderDelete(ticket,Yellow);   
            }


// clear signals

            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;
            longtrigger=false;
            shorttrigger=false;



// get long and short signals

double ma200=iMA(Symbol(),PERIOD_D1,200,0,MODE_SMA,PRICE_CLOSE,0);
double RSI= iRSI(Symbol(),PERIOD_D1,4,PRICE_CLOSE,0);

if (Ask>ma200) longSignal1=true;
   else longSignal1=false;
       
if  (Bid<ma200) shortSignal1=true;
   else shortSignal1=false;
         
if (RSI<30) longSignal2=true;
    else longSignal2=false;

if (RSI>70) shortSignal2=true;
    else shortSignal2=false;
         
  
   
/// find swinglow pattern
if (
    (iLow(Symbol(),PERIOD_M15,2)<iLow(Symbol(),PERIOD_M15,3)) &&
    (iLow(Symbol(),PERIOD_M15,2)<iLow(Symbol(),PERIOD_M15,1))
   )
      {
      longtrigger=true;
      low=iLow(Symbol(),PERIOD_M15,2);
      entrylong=iHigh(Symbol(),PERIOD_M15,1);
      }

//find swing high patten
if (
   (iHigh(Symbol(),PERIOD_M15,2)>iHigh(Symbol(),PERIOD_M15,3)) &&
   (iHigh(Symbol(),PERIOD_M15,2)>iHigh(Symbol(),PERIOD_M15,1))
   )
      {
      shorttrigger=true;
      high=iHigh(Symbol(),PERIOD_M15,2);
      entryshort=iLow(Symbol(),PERIOD_M15,1);
      }

Comment ( "\r\n Above 200 MA? " + longSignal1 + " RSI Oversold?"+  longSignal2 +  "turningpoint? " + longtrigger + "order price=  "+entrylong+
            "\r\n Below 200MA?  " + shortSignal1 + " RSI Overbought?" + shortSignal2+ "  turningpoint? " + shorttrigger+"Order price=  "+entryshort);
             

/// enter trade
      
if (longSignal1==true)
   if (longSignal2==true)
         if (longtrigger==true)
            if (lastTicket==-1)
                 
              {
              
              stop= entrylong-low-pips;
              ticket   =  orderOpen(OP_BUYSTOP,entrylong,stop,stop*inpMultiplier);          
               lastTicket=ticket;
                
               }
               
if (shortSignal1==true)
   if (shortSignal2==true)
         if (shorttrigger==true)
            if (lastTicket==-1)
               
            {
            Alert("short entrty");
           stop= high-entryshort+pips;
            ticket   =  orderOpen(OP_SELLSTOP,entryshort,stop,stop*inpMultiplier); 
            lastTicket=ticket;
             
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
   
   int orderOpen (ENUM_ORDER_TYPE orderType, double orderPrice, double stopLoss, double takeProfit){
      
      int   ticket;
      double openPrice;
      double stopLossPrice;
      double takeProfitPrice;
      
      int digits = Digits();
   double spread= MarketInfo(Symbol(),MODE_SPREAD);
   if (digits==4)spread=spread/100;
   if (digits==5) spread=spread/100;
   if (digits==2) spread=spread/10;
       
      
/////debugging loop ------------------------------------------------------------------------------------------------------

      
       
       Comment ("\n\r order price passed to function = "+orderPrice+  " Stoploss = "+stopLoss+ " take profit=  "+takeProfit);
       
       
      
      // caclulate the open price, take profit and stoploss price based on the order type
      //
      if (orderType==OP_BUYSTOP){
         openPrice    = NormalizeDouble(orderPrice, Digits());      
         stopLossPrice = NormalizeDouble(openPrice-stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(openPrice+takeProfit,Digits());
    

        
      } else if (orderType==OP_SELLSTOP){
         openPrice = NormalizeDouble (orderPrice, Digits());
         stopLossPrice =  NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = NormalizeDouble(openPrice-takeProfit,Digits());
         
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      double volume=NormalizeDouble(inpOrderSize,Digits());
      ticket = OrderSend (Symbol(), orderType,volume, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber,0);
      
      if (orderType==OP_BUYSTOP)
      {
            Comment (  "\r\n Long trades- 1 Day long? " + longSignal1 + "  Main<20 and cross? "+  longSignal2 + " crosses up 20? "+ longSignal3 + "   turningpoint? " + longtrigger +
                    "\r\n\r\n\r\n\r\n long entry - entry pice= "+openPrice+ " stop = " + stopLossPrice+ "  take profit = " + takeProfitPrice+
                    "\r\n\ Error="+GetLastError());
                    
/////debugging loop ------------------------------------------------------------------------------------------------------
                    
                
      }
      if (orderType== OP_SELLSTOP)
      {
    
         Comment ( "\r\n Short trades - 1Day short?  " + shortSignal1 + "   Main>80 and cross?" + shortSignal2+ "  crosses down 80?" + shortSignal3+ "  turningpoint? " + shorttrigger+
              "\r\n\r\n\r\n\r\n short entry - entry pice= "+openPrice+ " stop = " + stopLossPrice+ "  take profit = " + takeProfitPrice+
              "\r\n Error=  "+GetLastError());
             

    
      }  
      
      
      
      return (ticket);
}
      