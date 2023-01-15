//+------------------------------------------------------------------+
//|                                                pairs trading.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// Modified to  check for open orders with 1- same magic number or 2- Comment = "Pairs Trading";
// Modified to include a "trade-now" function- if set to yes- immediately opens trades if none open
// possible improvements- change program to close all trades with magic no/comments- to allow multiple buy/sells

#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <MasterFile.mqh>
#include <MasterFile 2.mqh>


input string                   Sec_name=   "Pair";//Security name 
input string                   Sec_a=      "NZDUSD";// Security A
input string                   Sec_b=      "AUDUSD";//  Security B

input bool buySpread=                     False;// Buy Spread immediately
input bool sellSpread=                    False;//Sell Spread immediately
input ENUM_TIMEFRAMES timeFrame=          PERIOD_D1;//  timeframe to trade;
input double hedge_Ratio=                 1.07;// Hedge ratio
input double order_size=                  1.07;// hedge ratio (2 decimal place)
input double OrderScaling=                0.2;// fraction of a lot to trade
input int lookback=                       5;//  lookback for calculating moving average and standard deviation
input double band_Factor=                 0.5;// Enter band_Factor for deviations to enter trades

input string      inpTradeComments     =  "Pairs Trading v12";  //Trade comment
input int      inpMagicNumber       =  123; //Magic number

int counter;


datetime linestart;
datetime lineend;
static double f;


enum ENUM_CONDITION {  WAITING,INALONG,INASHORT};

ENUM_CONDITION Status=WAITING;


// Array
double spread_;
double SecA_;
double SecB_;
static int      sec_a_price=0;
static int      sec_b_price=1;
static int      spread=2;
static int      ma=3;
static int      std_dev=4;
static int      upper_b=5;
static int      lower_b=6;

static double   df[7,5000];

static  bool InLongTrade=false;
static  bool InShortTrade=false;
static  bool TradeOn=false;
static int ord1,ord2;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
 
 for (int p=0;p<lookback;p++)
   {
   df[sec_a_price,p]=iClose(Sec_a,timeFrame,1+lookback-p);
   df[sec_b_price,p]=iClose(Sec_b,timeFrame,1+lookback-p);
   df[spread,p]= iClose(Sec_a,timeFrame,1+lookback-p)-(iClose(Sec_b,timeFrame,1+lookback-p)*hedge_Ratio);   

   }
f=1;
if (Sec_a==Symbol()) f=1;
if (Sec_b==Symbol()) f=hedge_Ratio;

Update_Df (lookback);

PrintLevels (lookback);
counter=lookback;

 
if (buySpread== true)LongEntry();
if (sellSpread==true)ShortEntry();
 
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



PrintLevels (counter);

SecA_=iClose(Sec_a,timeFrame,0);
SecB_=iClose(Sec_b,timeFrame,0);
spread_= iClose(Sec_a,timeFrame,0)-(iClose(Sec_b,timeFrame,0)*hedge_Ratio);   





////////////////////////////////////////////////////////////////
if (!newBar()) return;  //only trade on new bar
counter++;
// update DataFile
 Update_Df (counter);
// enter code to enter trades
PrintLevels (counter);



 
if ((spread_ < df[lower_b,counter]) && (Status==WAITING))
   {
      LongEntry();
   }

if ((spread_>df[upper_b,counter]) && (Status==WAITING))
   {
      ShortEntry();
   }
 
if (Status==INASHORT)   CheckShortExit ();
if (Status==INALONG)   CheckLongExit ();




Print("condition= "+Status);

  
  }
  
  
  
//+------------------------------------------------------------------+






void LongEntry ()
{
Print("Long Entry called");
ord1=-1;
ord2=-1;



ord1= orderExecute (ORDER_TYPE_BUY,Sec_a,0,0,OrderScaling,inpTradeComments,inpMagicNumber);

ord2= orderExecute (ORDER_TYPE_SELL,Sec_b,0,0,order_size*OrderScaling,inpTradeComments,inpMagicNumber);

if (ord1>0 || ord2>0) {Status=INALONG;return;}

}



void ShortEntry ()
{
ord1=-1;
ord2=-1;
Print("Short Entry called");


ord1= orderExecute (ORDER_TYPE_BUY,Sec_b,0,0,order_size*OrderScaling,inpTradeComments,inpMagicNumber);
ord2= orderExecute (ORDER_TYPE_SELL,Sec_a,0,0,OrderScaling,inpTradeComments,inpMagicNumber);

if (ord2>0 || ord1>0) {Status=INASHORT;return;}
}





void CheckShortExit ()
{int cntr=0;

//Print("Check Short Exit called");
if (spread_ < df[ma,counter])
   {

      Print ("==========================short exit signal========================");
      CloseAllDeals();
   
   }
}

void CheckLongExit ()
{
//Print("Check Long Exit called");

if (spread_> df[ma,counter])
   {

   Print ("---------------Long exit signal===========================");
   CloseAllDeals();
   }
}





// fill values of df

void Update_Df (int c)
{
double StdDev;
double rolling;
double MA;
double variance;
double Sd;

// update prices and spread
df[sec_a_price,c]=iClose(Sec_a,timeFrame,1);
df[sec_b_price,c]=iClose(Sec_b,timeFrame,1);
df[spread,c]= iClose(Sec_a,timeFrame,1)- (( iClose(Sec_b,timeFrame,1)*hedge_Ratio));

// calculate ma

rolling=0;
for (int m=0;m<lookback;m++)

{

rolling= rolling+ df[spread,c-m];

}

 MA=rolling/lookback;

df[ma,c]=MA;


// calculate std dev

//step1 - variances
variance=0;

for (int v=0; v<lookback; v++)

{
variance= variance+((df[spread,c-v]-MA)*(df[spread,c-v]-MA));


}

Sd= (variance/lookback);
StdDev=MathSqrt( Sd);
df[std_dev,c]=StdDev;


// calculate upper bb

df[upper_b,c]=MA+ (StdDev*band_Factor);

// calculate lower bb


df[lower_b,c]=MA-(StdDev*band_Factor);


return;
}


  //simple function to open a new order 
   
   int orderExecute (ENUM_ORDER_TYPE orderType, string SMBL ,double stopLoss, double takeProfit,double  inpOrderSize,string  inpTradeComments,int  inpMagicNumber )
   
   
   {
      
      int   ticket=-1;
      double openPrice;
      double stopLossPrice;
      double takeProfitPrice;
      
      // caclulate the open price, take profit and stoploss price based on the order type
      //
      
    double newlevel;
    double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
    double freezeLevel = MarketInfo(Symbol(), MODE_FREEZELEVEL);
    
  


 int count = 0;
            while ((ticket == -1) && (count < 10))
      
 {  
      Print ("retrying to enter- Ask = "+Ask+ "  Bid= " +Bid);
      
      if (orderType==ORDER_TYPE_BUY){
      
      
      
      
         
         RefreshRates();
         openPrice    = NormalizeDouble(SymbolInfoDouble(SMBL, SYMBOL_ASK), Digits());
      
         //Ternary operator, because it makes things look neat
         //   if stopLoss==0.0){
     
         //stopLosssPrice = 0.0} 
         //   else {
         //    stopLossPrice = NormalizedDouble (openPrice - stopLoss, Digist());
         //
      
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice-stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice+takeProfit,Digits());
      }else if (orderType==ORDER_TYPE_SELL){
         RefreshRates(); 
         openPrice = NormalizeDouble (SymbolInfoDouble(SMBL, SYMBOL_BID), Digits());
         stopLossPrice = (stopLoss==0.0)? 0.0: NormalizeDouble(openPrice+stopLoss,Digits());
         takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit,Digits());
      
      }else{ 
      // this function works with buy or sell
         return (-1);
      }
      
      ticket = OrderSend (SMBL, orderType,inpOrderSize, openPrice,10,0, 0,inpTradeComments, inpMagicNumber);
      
      Print ("Order Placed -=-order type= "+orderType+ "Lots =   " + inpOrderSize+ "Open P =   "+ openPrice + "    SL = "+  stopLossPrice + "   TP =  " + takeProfitPrice+ 
      "Error!!=  "+GetLastError()+  "      Stoplevel ="+StopLevel*_Point+ "  Stoplos= "+ stopLoss+ " freeze level="+freezeLevel+ "  new sl= "+newlevel);
      
      Print ("Bid Price=  "+ Bid +"Ask Price= "+Ask);
      
      count++; 
      
  }    
      
      return (ticket);
      
      
}
      


void PrintLevels(int cnt)

{

double MAline= spread_-df[ma,cnt];
double MAP=iClose(Symbol(),Period(),0)-MAline*f;




//  Pair Moving Average Price


             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"TL");
            ObjectCreate ("TL",OBJ_TREND,0,
            linestart,MAP, 
            lineend,MAP);
            ObjectSetInteger(0,"TL",OBJPROP_COLOR,clrAntiqueWhite);
            ObjectSetInteger(0, "TL",OBJPROP_WIDTH,1);
            ObjectSetInteger(0, "TL",OBJPROP_STYLE,STYLE_DASH);
            ObjectSetInteger(0, "TL",OBJPROP_RAY_RIGHT, true);
     
     
     
      if(ObjectFind("TLT") != 0)
      {
     ObjectCreate("TLT", OBJ_TEXT, 0,iTime(Symbol(),Period(),25), MAP);
     ObjectSetText("TLT", " Moving Average of Pair ", 8, "Arial", clrAntiqueWhite);
      }
            
  
 

// Upper Band 


double UBline= spread_-df[spread,cnt];
double UBP=iClose(Symbol(),Period(),0)+UBline*f;
   
             
             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"SL");
            ObjectCreate ("SL",OBJ_TREND,0,
            linestart,UBP, 
            lineend,UBP);
            ObjectSetInteger(0,"SL",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "SL",OBJPROP_WIDTH,1);
            ObjectSetInteger(0, "SL",OBJPROP_STYLE,STYLE_DASH);
            ObjectSetInteger(0, "SL",OBJPROP_RAY_RIGHT, true);
 
 
      if(ObjectFind("SLT") != 0)
      {
      ObjectCreate("SLT", OBJ_TEXT, 0,iTime(Symbol(),Period(),35), UBP);
      ObjectSetText("SLT", "Upper Band- enter Sell ", 8, "Arial", clrRed);
      }


// Lower Band 


double LBline= spread_-df[lower_b,cnt];
double LBP=iClose(Symbol(),Period(),0)-LBline*f;
   
   
              linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"TP");
            ObjectCreate ("TP",OBJ_TREND,0,
            linestart,LBP, 
            lineend,LBP);
            ObjectSetInteger(0,"TP",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "TP",OBJPROP_WIDTH,1);
            ObjectSetInteger(0, "TP",OBJPROP_STYLE,STYLE_DASH);
            ObjectSetInteger(0, "TP",OBJPROP_RAY_RIGHT, true);        
  
  
      if(ObjectFind("TPT") != 0)
      {
     ObjectCreate("TPT", OBJ_TEXT, 0,iTime(Symbol(),Period(),35), LBP);
     ObjectSetText("TPT", "Lower Band- enter buy", 8, "Arial", clrGreen);
      }
            
  

//Print ("counter= " + cnt+ " f=" +f+ " Values---  "+ MAline+"  "+UBline+"  "+ LBline+ " spread aray= " + df[spread,cnt]+ "  Ma array" +df[ma,cnt]);














} 

void CheckEntry ()

{


 
 if ((spread_< df[lower_b,counter]) && (Status==WAITING))
   {
      LongEntry();
   }

if ((spread_>df[upper_b,counter]) && (Status==WAITING))
   {
      ShortEntry();
   }
 


}

void CheckPositions()

{
// function to check if there are open positions for this ea.
      for(int i=(OrdersTotal()-1); i>=0; i--)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)

          {
            Print("false result in the loop - loop=" + i + "Order lots=  " + OrderLots());
            return;
           }

         else
                      
         {  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
               if (OrderMagicNumber()== inpMagicNumber )
              {
                        if (OrderType()==ORDER_TYPE_BUY && OrderSymbol()==Sec_a)             
                     {
                           ord1=OrderTicket ();
                           Status=INALONG;                               
                     }
               
               
               if (OrderType()==ORDER_TYPE_SELL && OrderSymbol()==Sec_a)
                     {
                        ord2=OrderTicket();
                        Status=INASHORT;
                     
                     }
               
               if (OrderType()==ORDER_TYPE_BUY && OrderSymbol()==Sec_b)             
                     {
                           ord1=OrderTicket ();
                           Status=INALONG;                     
                     }
               
               if (OrderType()==ORDER_TYPE_SELL && OrderSymbol()==Sec_b)
                     {
                        ord2=OrderTicket();
                        Status=INASHORT;
                     
                     }
               
               
               Alert ("Search for open trades complete- Status is =" + Status+ "Order Nos are "+ ord1+" and "+ord2); 
               
               
               }
         
         
         
         
          }
      
      }



}


void CloseAllDeals()
  
  
  {   int ticket2;
      Print("close order");
      for(int i=(OrdersTotal()-1); i>=0; i--)

        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
            
             {
               Print("false result in the loop - loop=" + i + "Order lots=  " + OrderLots());
               return;
             }

         else
           {
            double askprice= MarketInfo(OrderSymbol(),MODE_ASK);
            double bidprice= MarketInfo(OrderSymbol(),MODE_BID);
            if(OrderMagicNumber()== inpMagicNumber)
               if (OrderType()==ORDER_TYPE_SELL)
                 {
                   ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
                     int count = 0;
                        while((ticket2 == -1) && (count < 10))
                             {
                              RefreshRates();
                              ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
                               count++;
                             }
                 
                 
                   }


               if(OrderMagicNumber()== inpMagicNumber)
                  if (OrderType()==ORDER_TYPE_BUY)
                     {
                           ticket2= OrderClose(OrderTicket(),OrderLots(),bidprice,3,Red);
                           int count = 0;
                               while((ticket2 == -1) && (count < 10))
                             {
                              RefreshRates();
                              ticket2= OrderClose(OrderTicket(),OrderLots(),askprice,3,Red);
                               count++;
                             }
                 
                 
                       }








            if(ticket2>0)

                    { Status=WAITING;
                     ord1=0;
                      ord2=0;
                      }
           
        }
     }
}