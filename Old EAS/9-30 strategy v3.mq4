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
input double            inpSMA=9; // input short moving average
input double            inpLMA=30; // input long moving average
input double            inpMAdistance=0.001;// distance in pips between moving averages
input double            inpAdx= 20; // ADX trigger- only trade above
input double               pips=  0.001;// pips to add to swing high/low stop
input double            inpMultiplier = 2;// input multiplier for take profit
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
input string   inpTradeComments  =  "9-30 Strategy";  //Trade comment
input double   inpMagicNumber    =  01; //Magic number

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

   
double stoMain15=iStochastic(Symbol(), Period(), 14,3,1,0,1,MODE_MAIN,0);
double stoSignal15= iStochastic(Symbol(), Period(), 14,3,1,0,1,MODE_SIGNAL,0);

double stoMainDay=iStochastic(Symbol(),PERIOD_D1, 14,3,1,0,1,MODE_MAIN,0);
double stoSignalDay= iStochastic(Symbol(), PERIOD_D1, 14,3,1,0,1,MODE_SIGNAL,0);

double ADX= iADX(Symbol(),Period(),14,PRICE_CLOSE,MODE_MAIN,1);

int static counter=0;
int static ticket=0;
int static lastTicket=-1;
static double high;
static double low;
double stop;
static double entrylong=0;
static double entryshort=0;




// moving averages

double MA9= iMA (Symbol(),Period(),inpSMA,0,MODE_EMA,PRICE_CLOSE,0);
double MA30= iMA (Symbol(),Period(),inpLMA,0,MODE_LWMA,PRICE_CLOSE,0);
  
    
  
  
  
/////debugging loop ------------------------------------------------------------------------------------------------------

  
// reset after trade closes

     
    
     
 
      
      //manage pending orders
         if ((lastTicket!=-1) && (ticket==lastTicket))
            {
            OrderSelect (ticket,SELECT_BY_TICKET);
            if (OrderType()== OP_BUYSTOP)
             if (iClose(Symbol(),Period(),1)<MA30) 
            
            {
            OrderDelete(ticket,clrYellow);   
            if (GetLastError()==0)   
            { lastTicket=-1;
            ticket=0;}
            }}
      
      
      
      
         if ((lastTicket!=-1) && (ticket==lastTicket))
         
         {
         OrderSelect (ticket,SELECT_BY_TICKET);
          if (OrderType()== OP_SELLSTOP)
             if (iClose(Symbol(),Period(),1)>MA30) 
         {
         OrderDelete(ticket,clrYellow);
         if (GetLastError()==0)
           {lastTicket=-1;
            ticket=0;}}}
     
      
      
      
      
    
      ///manage the close
      
   
      
    if ((lastTicket!=-1) && (ticket==lastTicket)) 
    {
      OrderSelect (ticket,SELECT_BY_TICKET);
      
      if (OrderCloseTime()==0) 
         if (OrderType()==ORDER_TYPE_BUY)
            if (Bid <MA30)
               {
               
               OrderClose(ticket,OrderLots(),Bid,0,clrAntiqueWhite);
               if (GetLastError()==0)
               
               
            {   lastTicket=-1;
            ticket=0;
            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;
            longtrigger=false;
            shorttrigger=false;
            }}}
               
      
      
    if ((lastTicket!=-1) && (ticket==lastTicket))
    {
      OrderSelect (ticket,SELECT_BY_TICKET);
      if (OrderCloseTime()==0) 
         if (OrderType()==ORDER_TYPE_SELL);
            if (Ask>MA30)
               {
               OrderClose(ticket,OrderLots(),Ask,0,clrAntiqueWhite);
              if (GetLastError()==0)
               
             {  lastTicket=-1;
            ticket=0;
            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;
            longtrigger=false;
            shorttrigger=false;
            }}}
               
      
         
        
         




// clear signals


//if ((stoMain15 > 30) && (stoMain15<70))

  //        { 
    //        longSignal2=false;
      //      shortSignal2=false;
        //    longSignal3=false;
          //  shortSignal3=false;
         //   longtrigger=false;
          //  shorttrigger=false;}
            
            longSignal1=false;
            shortSignal1=false;
            longSignal2=false;
            shortSignal2=false;
            longSignal3=false;
            shortSignal3=false;


// get long and short signals


if (MA9>MA30 ) longSignal1=true;
   else longSignal1=false;
       
if  (MA9<MA30) shortSignal1=true;
   else shortSignal1=false;
         
//if  (longSignal1==true)
  ///    if (MA9-MA30>inpMAdistance)        
     // longSignal2=true;
       //  else longSignal2=false;
        
//if (shortSignal1==true)
  // if (MA30-MA9>inpMAdistance)        
    //  shortSignal2=true;
      //   else shortSignal2=false;
         
if (longSignal1== true)
      //if (longSignal2==true);
         if (iClose(Symbol(),Period(),1)<MA9)
            if (iClose(Symbol(),Period(),1)>MA30)
             {  longSignal3=true;
                  entrylong=iHigh(Symbol(),Period(),1);
              }
    
        
if (shortSignal1== true)
     // if (shortSignal2==true);
         if (iClose(Symbol(),Period(),1)>MA9)
            if (iClose(Symbol(),Period(),1)<MA30)
             {  shortSignal3=true;
                entryshort=iLow(Symbol(),Period(),1); 
              }


/// enter trade
      
if (longSignal1==true)
   //if (longSignal2==true)
      if (longSignal3==true)
            if (lastTicket==-1)
                 if (ADX>inpAdx)
              {
              
               ticket   =  orderOpen(OP_BUYSTOP,entrylong,0,0);          
               lastTicket=ticket;
                
               }
               
if (shortSignal1==true)
  // if (shortSignal2==true)
      if (shortSignal3==true)
            if (lastTicket==-1)
               if (ADX>inpAdx)
            {
            Alert("short entrty");
            ticket   =  orderOpen(OP_SELLSTOP,entryshort,0,0); 
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
      ticket = OrderSend (Symbol(), orderType,volume, openPrice,0,0, 0,inpTradeComments, inpMagicNumber,0);
      
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
      