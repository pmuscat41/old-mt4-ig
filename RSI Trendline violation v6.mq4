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
#include <MasterFile 2.mqh>

enum ENUM_PM_TRADE_DIRECTION {
      PM_TRADE_LONG,
      PM_TRADE_SHORT
      };
      
enum ENUM_EXIT_STRATEGY {
         EXIT_RSI,
         EXIT_MOVING_AVERAGE,
         EXIT_TRAILING_STOP,
         EXIT_STOPLOSS,
         EXIT_DYNAMIC_STOP
         };
         
input double                     inpATRtrail= 3;//Input ART for trail stop         
input double                     inpPercentToRisk= 1;// Enter percentate to risk
input ENUM_PM_TRADE_DIRECTION   InpDirection=PM_TRADE_SHORT;// Trade long or Trade short?
input ENUM_EXIT_STRATEGY             InpExitStrategy = EXIT_RSI;//Enter exit strategy

input double      inpStopSteps= 100;// Input one unit of steps for following stop (five steps)
input int                        InpCandlesToCancel = 100;// Enter number of candles to deactivate EA

input int                        InputMagicNumber=202020; // Magic number
input string                      InpTradeComment= "Trendline Violation v6"; //Trade Comment

bool static ManageTrade=false;
double TakeProfitShort,StopLossShort,TPS,SLS;
double TakeProfitLong,StopLossLong,TPL,SLL;
string InpTrendLevelName="TL";
double                     InpVolume;
CTrendLevel*TrendLevel;

double RiskReward;
string dirstr;

int counter = InpCandlesToCancel;

datetime linestart;
datetime lineend;

   


double priceLeve= ((iHigh(Symbol(),Period(),1)-iLow(Symbol(),Period(),1))+iHigh (Symbol(),Period(),1));

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"TL");
            ObjectCreate ("TL",OBJ_TREND,0,
            linestart,priceLeve, 
            lineend,priceLeve);
            ObjectSetInteger(0,"TL",OBJPROP_COLOR,clrAntiqueWhite);
            ObjectSetInteger(0, "TL",OBJPROP_WIDTH,1);
            ObjectSetInteger(0, "TL",OBJPROP_STYLE,STYLE_DASH);
            ObjectSetInteger(0, "TL",OBJPROP_RAY_RIGHT, true);
     
     
     
      if(ObjectFind("TLT") != 0)
      {
     ObjectCreate("TLT", OBJ_TEXT, 0,iTime(Symbol(),Period(),5), priceLeve);
     ObjectSetText("TLT", " Entry Price", 8, "Arial", clrAntiqueWhite);
      }
            
  
  

// Stoploss 
  
   
             priceLeve= ((iHigh(Symbol(),Period(),1)-iLow(Symbol(),Period(),1))+iHigh (Symbol(),Period(),1));
             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"SL");
            ObjectCreate ("SL",OBJ_TREND,0,
            linestart,priceLeve, 
            lineend,priceLeve);
            ObjectSetInteger(0,"SL",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "SL",OBJPROP_WIDTH,1);
            ObjectSetInteger(0, "SL",OBJPROP_STYLE,STYLE_DASH);
            ObjectSetInteger(0, "SL",OBJPROP_RAY_RIGHT, true);
 
 
      if(ObjectFind("SLT") != 0)
      {
      ObjectCreate("SLT", OBJ_TEXT, 0,iTime(Symbol(),Period(),5), priceLeve);
      ObjectSetText("SLT", " Stop Loss", 8, "Arial", clrRed);
      }


// Take Profit 
  
   
             priceLeve= ((iHigh(Symbol(),Period(),1)-iLow(Symbol(),Period(),1))+iHigh (Symbol(),Period(),1));
             linestart= iTime(Symbol(),Period(),15);
             lineend = iTime(Symbol(),Period(),0);
            ObjectDelete(0,"TP");
            ObjectCreate ("TP",OBJ_TREND,0,
            linestart,priceLeve, 
            lineend,priceLeve);
            ObjectSetInteger(0,"TP",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "TP",OBJPROP_WIDTH,1);
            ObjectSetInteger(0, "TP",OBJPROP_STYLE,STYLE_DASH);
            ObjectSetInteger(0, "TP",OBJPROP_RAY_RIGHT, true);        
  
  
      if(ObjectFind("TPT") != 0)
      {
     ObjectCreate("TPT", OBJ_TEXT, 0,iTime(Symbol(),Period(),5), priceLeve);
     ObjectSetText("TPT", " Take Profit", 8, "Arial", clrGreen);
      }
            
  
  
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
int static ticket =0;

/// manage trade


if (ManageTrade==true) 
{
Comment ("Actively managing the trade");
Comment ("\nl Exit strategy ="+InpExitStrategy );
OrderSelect(ticket,SELECT_BY_TICKET);

Comment ("\nl Profit / Loss"+OrderProfit());
Comment ("Pips to target: "+MathAbs (Close[0] - OrderTakeProfit()));


if (InpExitStrategy==EXIT_RSI) RSIExit(10,90);

if (InpExitStrategy==EXIT_TRAILING_STOP)ApplyTrailingStop(InputMagicNumber,inpStopSteps);

if (InpExitStrategy==EXIT_STOPLOSS)return;

if (InpExitStrategy==EXIT_DYNAMIC_STOP)DynamicTrailingStop (InputMagicNumber,ticket);



return;}

    double TakeProf=ObjectGetValueByShift("TP",1);
    double StopLoss = ObjectGetValueByShift ("SL",1);
    double EntryPrice= ObjectGetValueByShift ("TL",1);
    double TPPoints;
    double SLPoints;
    
    if (InpDirection==PM_TRADE_LONG)
    {
     TPPoints=TakeProf-EntryPrice;
     SLPoints=EntryPrice-StopLoss; 
    }
    
    
    if (InpDirection==PM_TRADE_SHORT)
    {
     TPPoints=EntryPrice-TakeProf;
     SLPoints=StopLoss-EntryPrice; 
    }
    
    
    
    double riskReward;
    if (SLPoints!=0) riskReward= TPPoints/SLPoints;
    double TPNorm= NormalizeDouble(TPPoints,Digits);
    double SLNorm=NormalizeDouble(SLPoints,Digits);
    double riskNorm=NormalizeDouble(riskReward,1);
    double riskAmount= ((inpPercentToRisk/100)*AccountBalance()+ " USD");
    double lots =CalculateLotsize(SLPoints,inpPercentToRisk,1000);
    
    InpVolume=NormalizeDouble(lots,2);
    
    
   Comment ("Waiting for " +dirstr + " trade.  Order will cancell in " +counter+ "  candles. ");
   
   Comment ("\nl Take profit = "+TPNorm+ "       Stoploss = "+SLNorm+ "      Risk: Reward = 1:"+ riskNorm+ 
            "        risk amount= "+riskAmount+ "\nl       Lots to trade = "+ lots); 
    


ObjectMove (0,"TLT",0,iTime(Symbol(),Period(),0), ObjectGetValueByShift ("TL",1));
ObjectMove (0,"SLT",0,iTime(Symbol(),Period(),0), ObjectGetValueByShift ("SL",1));
ObjectMove(0,"TPT",0,iTime(Symbol(),Period(),0), ObjectGetValueByShift("TP",1));


/// New Bar Function

if (!newBar()) return;

   
    
   counter=counter-1;
   
   if (counter==0) ExpertRemove();
   
   if (InpDirection==PM_TRADE_LONG) dirstr="long"; else dirstr="short";
   
   Comment ("Waiting for " +dirstr + " trade.  Order will cancell in " +counter+ "  candles. " );
   
   Comment ("\nl Take profit = "+TPNorm+ "       Stoploss = "+SLNorm+ "      Risk: Reward = 1:"+ riskNorm+ 
            "        risk amount= "+riskAmount+ "\nl       Lots to trade = "+ lots); 
   
     
   ENUM_OFX_TREND_BREAK brk= TrendLevel.GetBreak(1);// Did the closed bar break
    
      
      
   switch (brk){
   
   case OFX_TREND_BREAK_NONE:
   
   Print ("No Break");
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

void RSIExit(double upper,double lower){

double rsiexit= iRSI(Symbol(),Period(),4,PRICE_CLOSE,0);


    if (InpDirection==PM_TRADE_LONG)
      if (rsiexit<lower) CloseTradeLong (InputMagicNumber);
      
    if (InpDirection==PM_TRADE_SHORT)
      if (rsiexit>upper) CloseTradeShort (InputMagicNumber);

}  
  
  

  
  
//+------------------------------------------------------------------+
