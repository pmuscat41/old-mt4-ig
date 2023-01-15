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

input double   inpOrderSize_      =  0.05;  //Order size for first buy - doubles each time
input double   inpTotalOrders    =  4; //Set total orders to open
input string   inpTradeComments  =  "Connors PowerZones Strategy";  //Trade comment
input double   inpMagicNumber    = 00000  ; //Magic number
double inpOrderSize = inpOrderSize_;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


Alert ("            ");
Alert ("   ---------------------------------------------------------------------------------         ");
Alert ("            ");




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
   static double direction= 1;
   static int lastTicket = -1;
   static int previousDirection =0;
   static int totalTicket=0;
   static bool OrderOk =true;
   static int closeLots=0;
   static bool twoDaysDown = false;

//perform calculations and analyze here
//Bar 0 is currently open, bar 1 is the most recent closed bar and bar 2 is bar before the
   double rsi     =  iRSI(Symbol(),Period(),inpRSIPeriods, inpRSIPrice,1);
   double rsiYest     =  iRSI(Symbol(),Period(),inpRSIPeriods, inpRSIPrice,2);


   double TwoHunMa = iMA(Symbol(),Period(),200,0,MODE_SMMA, PRICE_CLOSE,0);

   if(Close [1]> TwoHunMa)
     {direction = 1;}
   else
     { direction = -1;}

  

   if(!newBar())
      return;  //only trade on new bar


//get the diraction of the last bar. this will just give a positive number
//for up and negative number for down.

//double direction    = iClose (Symbol(),Period(),1)-iOpen (Symbol(),Period(),1);


// if rsi crossed midpoint then clear any old flags
   if(rsi>50)
     {
      oversold  =  false;
     }
   else
      if(rsi<50)
        {
         overbought  = false;
        }
// next check if the flag should be set
// note not just assigning the comparrison to the value.This keeps any flags already set intact,


Alert ("Rsi today "+ rsi+"  "+ "Rsi yest"+rsiYest);
Alert (inpOversoldLevel);
 
 
 /// first order
 
  if ((rsi>inpOverboughtLevel) &&(totalTicket==0))
     
         {overbought  = true;
         Alert ("");
         Alert ("overbought = true");
         Alert ("overbought = true");
         Alert ("");}       


      if ((rsi<inpOversoldLevel) &&(totalTicket==0))
     
         {oversold  = true;
         Alert ("");
         Alert ("oversold = true");
         Alert ("oversold = true");
         Alert ("");}       


//subsequent orders

if ((rsi>inpOverboughtLevel2) &&(totalTicket>0))
     
         {overbought  = true;
         Alert ("");
         Alert ("overbought = true");
         Alert ("overbought = true");
         Alert ("");}       


      if ((rsi<inpOversoldLevel2) &&(totalTicket>0))
     
         {oversold  = true;
         Alert ("");
         Alert ("oversold = true");
         Alert ("oversold = true");
         Alert ("");}       




//Now if there is a flag set and the bar moved in the righ direction make a trade
// trading rules are
// buy if
//          last bar was a down bar//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



   static int  ticket =0;
      
   Alert ("total ticket= "+ totalTicket+ "inpTotal orders=  "+ inpTotalOrders+"   oversold = "+ oversold + "  direction= " + direction + "  lastticket= " +lastTicket +" ticket="+ ticket+ " orderok?= "+ OrderOk);
      
      if(oversold && (direction>0) && (totalTicket<inpTotalOrders)  && (OrderOk==true))
       {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      oversold =  false; //Reset
      lastTicket = ticket;
      previousDirection= direction;
      totalTicket ++;
    
     }
   else
      if(overbought &&(direction<0) && (totalTicket<inpTotalOrders) && (OrderOk==true))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         overbought = false;
         lastTicket= ticket;
         previousDirection=direction;
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
     
      OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
      lastTicket=-1;
      OrderOk=true;
      totalTicket=0;
      inpOrderSize = inpOrderSize_;
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
     
     OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
    lastTicket=-1;
     OrderOk=true;
     totalTicket=0;
     inpOrderSize = inpOrderSize_;
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

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
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
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;

// caclulate the open price, take profit and stoploss price based on the order type
//
   if(orderType==ORDER_TYPE_BUY)
     {
      openPrice    = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), Digits());

      //Ternary operator, because it makes things look neat
      //   if stopLoss==0.0){

      //stopLosssPrice = 0.0}
      //   else {
      //    stopLossPrice = NormalizedDouble (openPrice - stopLoss, Digist());
      //

      stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
      takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
     }
   else
      if(orderType==ORDER_TYPE_SELL)
        {
         openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());

        }
      else
        {
         // this function works with buy or sell
         return (-1);
        }

   ticket = OrderSend(Symbol(), orderType,inpOrderSize, openPrice,0,stopLossPrice, takeProfitPrice,inpTradeComments, inpMagicNumber);
   return (ticket);
  }
  
  
  
  
//+------------------------------------------------------------------+
