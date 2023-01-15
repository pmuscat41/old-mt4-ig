//+------------------------------------------------------------------+
//|                                   RSI Trendline violation v1.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Paul/class/trendlevel.mqh>
#include <MasterFile.mqh>


enum ENUM_PM_TRADE_DIRECTION {
      PM_TRADE_LONG,
      PM_TRADE_SHORT
      };

input ENUM_PM_TRADE_DIRECTION   InpDirection=PM_TRADE_SHORT;// Trade long or Trade short?
input int                        InpCandlesToCancel = 100;// Enter number of candles to deactivate EA
input double                     InpVolume= 0.1; // Trade Volume
input int                        InputMagicNumber=202020; // Magic number
input string                      InpTradeComment= "Trendline Violation v2"; //Trade Comment

bool static ManageTrade=false;
double TakeProfitShort,StopLossShort,TPS,SLS;
double TakeProfitLong,StopLossLong,TPL,SLL;
string InpTrendLevelName="TL";

CTrendLevel*TrendLevel;
int counter=0;
double RiskReward;
string dirstr;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

counter = InpCandlesToCancel;

  
// Trendline  
  
datetime linestart;
datetime lineend;
double priceLeve;
   
             priceLeve= ((iHigh(Symbol(),Period(),1)-iLow(Symbol(),Period(),1))+iHigh (Symbol(),Period(),1));
             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"TL");
            ObjectCreate ("TL",OBJ_TREND,0,
            linestart,priceLeve, 
            lineend,priceLeve);
            ObjectSetInteger(0,"TL",OBJPROP_COLOR,clrAntiqueWhite);
            ObjectSetInteger(0, "TL",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "TL",OBJPROP_RAY_RIGHT, true);
     
            
  
  

// Stoploss 
  
   
             priceLeve= ((iHigh(Symbol(),Period(),1)-iLow(Symbol(),Period(),1))+iHigh (Symbol(),Period(),1));
             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"SL");
            ObjectCreate ("SL",OBJ_TREND,0,
            linestart,priceLeve, 
            lineend,priceLeve);
            ObjectSetInteger(0,"SL",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "SL",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "SL",OBJPROP_RAY_RIGHT, true);
     


// Take Profit 
  
   
             priceLeve= ((iHigh(Symbol(),Period(),1)-iLow(Symbol(),Period(),1))+iHigh (Symbol(),Period(),1));
             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"TP");
            ObjectCreate ("TP",OBJ_TREND,0,
            linestart,priceLeve, 
            lineend,priceLeve);
            ObjectSetInteger(0,"TP",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "TP",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "TP",OBJPROP_RAY_RIGHT, true);        
  
  
  
  
  TrendLevel = new CTrendLevel(InpTrendLevelName);
  
  
  
  
  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
  delete TrendLevel;
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

double   price= 0.0;
int ticket =0;

/// manage trade

if (ManageTrade==true) return;

/// New Bar Function

if (!newBar()) return;

   
    
   counter=counter-1;
   
   if (counter==0) ExpertRemove();
   
   if (SLL>0) RiskReward= TPL/SLL;
   if (InpDirection==PM_TRADE_LONG) dirstr="long"; else dirstr="short";
   
   Comment ("Waiting for " +dirstr + " trade.  Order will cancell in " +counter+ "  candles. " );
   
    TakeProfitLong=ObjectGetValueByShift("TP",1);
      StopLossLong = ObjectGetValueByShift ("SL",1);
      TPL= NormalizeDouble(TakeProfitLong,Digits);
      SLL= NormalizeDouble(StopLossLong,Digits);
   
     
   ENUM_OFX_TREND_BREAK brk= TrendLevel.GetBreak(1);// Did the closed bar break
    
      
      
   switch (brk){
   
   case OFX_TREND_BREAK_NONE:
   
   Print ("Trend break- first condition met");
      break;
   
   case OFX_TREND_BREAK_ABOVE:
   
      if (InpDirection==PM_TRADE_LONG)
      {
      
   Print ("Trend break- LONG");
      TakeProfitLong=ObjectGetValueByShift("TP",1);
      StopLossLong = ObjectGetValueByShift ("SL",1);
      TPL= NormalizeDouble(TakeProfitLong,Digits);
      SLL= NormalizeDouble(StopLossLong,Digits);
      price    =  SymbolInfoDouble(Symbol(),SYMBOL_ASK);
       ticket   =  OrderSend(Symbol(),ORDER_TYPE_BUY, InpVolume, price,0,SLL,TPL,InpTradeComment,InputMagicNumber);
    
      if (ticket>0)
      {
      Print ("\nl In a long trade -  Order Volume= "+InpVolume+"  Order price=  "+price+"  Stoploss= "+SLL+"   Take profit= "+TPL);
      ManageTrade= true;
      }}
      break;
   
   case OFX_TREND_BREAK_BELOW:
      
      if (InpDirection ==PM_TRADE_SHORT)
      
      {
      Alert ("Trend break- SHORT");
      TakeProfitShort = ObjectGetValueByShift("TP",1);
      StopLossShort = ObjectGetValueByShift ("SL",1);
      TPS= NormalizeDouble(TakeProfitShort,Digits);
      SLS= NormalizeDouble(StopLossShort,Digits);
      price    =  SymbolInfoDouble(Symbol(), SYMBOL_BID);
      ticket   =  OrderSend (Symbol(),ORDER_TYPE_SELL,InpVolume, price,0,SLS,TPS,InpTradeComment, InputMagicNumber);
      
      if (ticket>0) {
      Print ("\nl In a short trade -  Order Volume= "+InpVolume+"  Order price=  "+price+"  Stoploss= "+SLS+"   Take profit= "+TPS);
      ManageTrade=true;
      }
      break;
      
      }

  }}


   
  
//+------------------------------------------------------------------+
