//+------------------------------------------------------------------+
//|                                                 biginner rsi.mq4 |
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

int                  inpRSIPeriods  =  2;               //RSI Periods

input ENUM_APPLIED_PRICE   inpRSIPrice    =    PRICE_CLOSE;   // Applied Price

//The Levels

double               inpOversoldLevel  =  25.0;          // Oversold Level
double               inpOverboughtLevel=  75.0;          // Overbought Level

// Take Profit and stop loss as exit criteria for each trade
// A simple way to exit

double               inpTakeProfit  =  0.00;     //Take Profit in currency value
double               inpStopLoss   =  0.00;     //Stop Loss in currecny value

///Standard inputs - you should have this in every EA

input double   inpOrderSize_      =  0.05;  //Order size for first buy - doubles each time
input double   inpTotalOrders    =  4; //Set total orders to open
input string   inpTradeComments  =  "Connors TPS Strategy RSI 2 V2 ";  //Trade comment
input double   inpMagicNumber    = 0; //Magic number
double inpOrderSize = inpOrderSize_;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


Print ("            ");
Print ("   ---------------------------------------------------------------------------------         ");
Print ("            ");




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
  static bool PreviousPriceshort=true;
   static bool PreviousPricelong=true;
   static bool oversold =  false;
   static bool overbought= false;
   static double direction= 1;
   static int lastTicket = -1;
   static int previousDirection =0;
   static int totalTicket=0;
   static bool OrderOk =true;
   static int closeLots=0;
   static bool twoDaysDown = false;
   int ticket2;

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


Comment ("Rsi today "+ rsi+"  "+ "Rsi yest"+rsiYest);
Comment (inpOversoldLevel);
 
  if ((rsi>inpOverboughtLevel) && (rsiYest>inpOverboughtLevel))
     
         {overbought  = true;
         Print ("");
         Print ("overbought = true");
         Print ("overbought = true");
         Print ("");}       


      if ((rsi<inpOversoldLevel) && (rsiYest<inpOversoldLevel))
     
         {oversold  = true;
         Print ("");
         Print ("oversold = true");
         Print ("oversold = true");
         Print ("");}       




//Now if there is a flag set and the bar moved in the righ direction make a trade
// trading rules are
// buy if
//          last bar was a down bar//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



   static int  ticket =0;
      
   Print ("total ticket= "+ totalTicket+ "inpTotal orders=  "+ inpTotalOrders+"   oversold = "+ oversold + "  direction= " + direction + "  lastticket= " +lastTicket +" ticket="+ ticket+ " orderok?= "+ OrderOk);
      
  
  
  if (ticket>0)
  {OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
  
   PreviousPricelong = iClose (Symbol(),Period(),1) < OrderOpenPrice();
   PreviousPriceshort= iClose (Symbol(),Period(),1) > OrderOpenPrice();
   }   
      if((oversold) && (direction>0) && (totalTicket<inpTotalOrders)  && (OrderOk==true) && (PreviousPricelong))
       {
      ticket   =  orderOpen(ORDER_TYPE_BUY, inpStopLoss,inpTakeProfit);
      
      if (ticket>0)
      {
      oversold =  false; //Reset
      lastTicket = ticket;
      previousDirection= direction;
      totalTicket ++;
      inpOrderSize =inpOrderSize+inpOrderSize;
      }
     }
   else
      if(overbought &&(direction<0) && (totalTicket<inpTotalOrders) && (OrderOk==true) &&(PreviousPriceshort))
        {
         ticket  =  orderOpen(ORDER_TYPE_SELL, inpStopLoss,inpTakeProfit);
         
         if (ticket>0)
         {
         overbought = false;
         lastTicket= ticket;
         previousDirection=direction;
         totalTicket ++;
         inpOrderSize =inpOrderSize+inpOrderSize;
        }
        }
   
   
    if((rsi >70) && (previousDirection >0) && (lastTicket>0))
     
     {
     
     Print("");
     Print("close order");
       
       
     for (int i=(OrdersTotal()-1);i>=0;i--)
     
    {
    
     if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
       Print ("false result in the loop - loop=" + i + "    total Ticket= " + totalTicket + "Order lots=  " + OrderLots());
      
      return;}
   
      else {
      double bidprice= MarketInfo(OrderSymbol(),MODE_BID);
      if (OrderMagicNumber()== inpMagicNumber)
     
      {ticket2= OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
      
         int count = 0;
            while ((ticket2 == -1) && (count < 10))
         {
            RefreshRates();
             ticket2= OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
             count++;
        
          }
         
      
      
      if (ticket2>0)
      
     { PreviousPricelong=true;
      PreviousPriceshort=true;
      ticket=0;
      lastTicket=-1;
      OrderOk=true;
      totalTicket=0;
      inpOrderSize = inpOrderSize_;}
     }}}}

 if((rsi <30) && (previousDirection <0) && (lastTicket>0))
      
   {
   Print("");
    Print("close order");
    Print("close order");
    Print("close order");
    Print("close order");
    
   for (int i=(OrdersTotal()-1);i>=0;i--)
   
  { if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
     
       
{
   Print ("false result in the loop - loop=" + i + "    total Ticket= " + totalTicket + "Order lots=  " + OrderLots());
      
    return;}
   
     else {
    double askprice= MarketInfo(OrderSymbol(),MODE_ASK);
    if (OrderMagicNumber()== inpMagicNumber)
     
     {ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
     
     
       int count = 0;
            while ((ticket2 == -1) && (count < 10))
         {
            RefreshRates();
             ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
             count++;
        
          }}
     
     if (ticket2>0)
     
     
     
     
     
     
      {PreviousPricelong=true;
      PreviousPriceshort=true;
      ticket=0;
    lastTicket=-1;
     OrderOk=true;
     totalTicket=0;
     inpOrderSize = inpOrderSize_;
    }}}}
   
   
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
