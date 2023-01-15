//+------------------------------------------------------------------+
//|                                              |
//|                                                Copyright 2021PJM |
//|                                             https://www.mql5.com
//|
//  Code is from http://www.orchardforex.com
//  title of You tube video is "Biginners guide : Write your own RSI expert advisor for MT4
///// Connors TPS system

//DEVELOPMENTS-

//still need to add error handling- check close and open trades for errors 
// add a section to enter a trade on init- but add a flag so it only enters the first time!!!! that 
/// way you can enter trades on the close and benefit from gap- up.
///
/// do some scanning for stock also as well as commodities
///
/// remember order is reverses so rank securites worst to best (at the end)
//+------------------------------------------------------------------+
#property copyright "Copyright 2021PJM"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/// RSI levels are from 0 -100, select levels for overbought and oversold
//  and the inputs to RSI

int                  inpRSIPeriods  =  4;               //RSI Periods

input ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price

//The Levels

double               inpOversoldLevel  =  30.0;          // Oversold Level
double               inpOverboughtLevel=  70.0;          // Overbought Level


double               inpOversoldLevel2  =  25.0;          // Oversold Level 2
double               inpOverboughtLevel2=  75.0;          // Overbought Level 2

// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit

double               inpTakeProfit  =  0.00;     //Take Profit in currency value
double               inpStopLoss   =  0.00;     //Stop Loss in currecny value

///Standard inputs - you should have this in every EA

input double   inpOrderSize_      =  0.1;  //Order size
input double   inpTotalOrders    =  4; //Set total orders to open
input string   inpTradeComments  =  "Connors PowerZones Strategy v3";  //Trade comment
input double   inpMagicNumber    = 00000  ; //Magic number
double inpOrderSize = inpOrderSize_;

static bool checkDay= true;
static bool checkHour=true;
static int hourCounter=0;
static int fifMinuteCounter=0;
static int ticket2=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {




   ENUM_INIT_RETCODE result =  INIT_SUCCEEDED ;

   result =  checkInput();
   if(result!=INIT_SUCCEEDED)
      return(result);  //exit if inputs are bad

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

   static bool oversold =  false;
   static bool overbought= false;
   static bool oversold2= false;
   static bool overbough2= false;
   static double direction= 1;
   static int lastTicket = -1;
   static int previousDirection =0;
   static int totalTicket=0;
   static bool OrderOk =true;
   static int closeLots=0;
   static bool twoDaysDown = false;
   static bool firstTrade=false;

//perform calculations and analyze here
//Bar 0 is currently open, bar 1 is the most recent closed bar and bar 2 is bar before the
  
  
////////////////////////////////////////////New Bar
   if (checkDay==true)
      if(!newBar())
      return;  //only trade on new bar

   checkDay=false;
 
 if (checkHour==true)
   if (!HourBar()) return;
 
 hourCounter++;
 
 if (hourCounter<10) return;
 checkHour=false;
 
 if (!fifMminuteBar()) return;
   
  fifMinuteCounter++;
 
 if ( fifMinuteCounter <2) return;
 
 
 
//Reset values to check for day/hour and minute to trade
fifMinuteCounter==0;
hourCounter=0;
checkDay=true;
checkHour=true;

 
 
 //-------------------------------------------------------------------------------------------------------------------------------------
 double rsi     =  iRSI(Symbol(),Period(),inpRSIPeriods, inpRSIPrice,1);
   double rsiYest     =  iRSI(Symbol(),Period(),inpRSIPeriods, inpRSIPrice,2);


   double TwoHunMa = iMA(Symbol(),Period(),200,0,MODE_SMMA, PRICE_CLOSE,1);

   if(iClose(Symbol(),PERIOD_D1,1)> TwoHunMa)
     {direction = 1;}
   else
     { direction = -1;}









//get the diraction of the last bar. this will just give a positive number
//for up and negative number for down.

//double direction    = iClose (Symbol(),Period(),1)-iOpen (Symbol(),Period(),1);



overbought=false;
oversold=false;
overbough2=false;
oversold2=false;
 
 /// first order
 
  if ((rsi>inpOverboughtLevel) &&(totalTicket==0))
     
         {overbought  = true;
         }       


      if ((rsi<inpOversoldLevel) &&(totalTicket==0))
     
         {oversold  = true;
         }       


//subsequent orders

if ((rsi>inpOverboughtLevel2) &&(totalTicket>0))
     
         {overbough2  = true;
         }       


      if ((rsi<inpOversoldLevel2) &&(totalTicket>0))
     
         {oversold2  = true;
         }       



Comment ("/nl Rsi last bar is= "+ rsi+"  "+ "       Rsi bar before last bar= "+rsiYest);
Comment ("\nl open current positions = "+ totalTicket+ "   Maximum positions = "+inpTotalOrders);
Comment ("\n first position opened at 30/70, second position opened at 35,75"); 
 
   static int  ticket =0;
   
   
///// -------------------- first entry
   
      if((totalTicket==0) &&(oversold) && (direction>0) && (totalTicket<inpTotalOrders)  && (OrderOk==true))
       {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      lastTicket = ticket;
      previousDirection= direction;
      firstTrade=true;
      totalTicket ++;
    
     }
   else
      if((totalTicket==0)&&(overbought) &&(direction<0) && (totalTicket<inpTotalOrders) && (OrderOk==true))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         lastTicket= ticket;
         previousDirection=direction;
         firstTrade=true;
         totalTicket ++;
        
        }
   
//// -----------------subsequent entries

      if((totalTicket>0)&&(oversold2) && (direction>0) && (totalTicket<inpTotalOrders)  && (OrderOk==true)&& (firstTrade==true))
       {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      lastTicket = ticket;
      previousDirection= direction;
      firstTrade=false;
      totalTicket ++;
    
     }
   else
      if((totalTicket>0)&&(overbough2) &&(direction<0) && (totalTicket<inpTotalOrders) && (OrderOk==true)&& (firstTrade==true))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         lastTicket= ticket;
         previousDirection=direction;
         firstTrade=false;
         totalTicket ++;
        
        }   
   
   

   
   
   
   
   
   
   
   
    if((rsi >55) && (previousDirection >0) && (lastTicket>0))
     
     {
     
     Alert("");
     Alert("close order");
       
       
     for (int i=(OrdersTotal()-1);i>=0;i--)
     
    {
    
     if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
       Alert ("false result in the loop - loop=" + i + "    total Ticket= " + totalTicket + "Order lots=  " + OrderLots());
      
      return;}
   
      else {
      double bidprice= MarketInfo(OrderSymbol(),MODE_BID);
    if (OrderMagicNumber()== inpMagicNumber)
      if (OrderSymbol()==Symbol())
         
         { ticket2= OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
         
          int count = 0;
            while ((ticket2 == -1) && (count < 10))
         {
            RefreshRates();
             ticket2=  OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
             count++;
        
          }
         
         
         if (ticket2>0)
         {        
         
          lastTicket=-1;
          OrderOk=true;
          firstTrade=false;
          totalTicket=0;
          inpOrderSize = inpOrderSize_;}
         }  
     }}}

 if((rsi <45) && (previousDirection <0) && (lastTicket>0))
      
   {
   Alert("");
    Alert("close order");
    Alert("close order");
    Alert("close order");
    Alert("close order");
    
   for (int i=(OrdersTotal()-1);i>=0;i--)
   
  { if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
     
       
{
   Alert ("false result in the loop - loop=" + i + "    total Ticket= " + totalTicket + "Order lots=  " + OrderLots());
      
    return;}
   
     else {
    double askprice= MarketInfo(OrderSymbol(),MODE_ASK);
    if (OrderMagicNumber()== inpMagicNumber)
     if (OrderSymbol()==Symbol())
      { ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
      
       int count = 0;
            while ((ticket2 == -1) && (count < 10))
         {
            RefreshRates();
             ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
             count++;
        
          }
     
     if (ticket2>0)
           
     { lastTicket=-1;
      OrderOk=true;
      firstTrade=false;
      totalTicket=0;
      inpOrderSize = inpOrderSize_;}
      }   
    }}}
   
   
   return ;


  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_INIT_RETCODE checkInput()
  {

   if(inpRSIPeriods<=0)
      return(INIT_PARAMETERS_INCORRECT);

   return (INIT_SUCCEEDED);

  }

// true or false has bar changed

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newBar()
  {

   datetime          currentTime =  iTime(Symbol(),PERIOD_D1,0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result = (currentTime!=priorTime);      //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
  }


bool HourBar()
  {

   datetime          currentTime =  iTime(Symbol(),PERIOD_H1,0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result = (currentTime!=priorTime);      //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
  }

bool fifMminuteBar()
  {

   datetime          currentTime =  iTime(Symbol(),PERIOD_M15,0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result = (currentTime!=priorTime);      //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
  }










//simple function to open a new order

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int orderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit)
  {

   int   ticket;
   int ticket2;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;

// caclulate the open price, take profit and stoploss price based on the order type
//
   if(orderType==ORDER_TYPE_BUY)
     {
      openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());

      stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
      takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
      
      
   ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);




 int count = 0;
            while ((ticket == -1) && (count < 10))
         {
            RefreshRates();
             openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());
           ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);

             count++;
        
          }
   


      
      
      
      
      
      
      
     }
   else
      if(orderType==ORDER_TYPE_SELL)
        {
         openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
         
         
           
      
   ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);




 int count = 0;
            while ((ticket == -1) && (count < 10))
         {
            RefreshRates();
              openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
           ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);

             count++;
        
          }
   


         
         
         
         
         
         
         

        }
      else
        {
         // this function works with buy or sell
         return (-1);
        }








   return (ticket);
  }
  
  
  
  
//+------------------------------------------------------------------+
