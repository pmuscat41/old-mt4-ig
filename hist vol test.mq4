//+------------------------------------------------------------------+
//|                                                hist vol test.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  LimeGreen

extern int hist_vol_period=100;



double roc[];
double hv[];




int init()
{
   IndicatorBuffers(2);
   SetIndexBuffer(0,hv);SetIndexLabel(0,"Historical Volatility");
   SetIndexBuffer(1,roc);SetIndexLabel(1,"RoC");

   
   IndicatorShortName("");
   
   return(0);
}


int start()
{
   int counted_bars=IndicatorCounted();
     if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=Bars-counted_bars;
           
           
  
   
   for(int i=limit; i>=0; i--)
   {   
      roc[i]  = 0;
      if (Close[i+1]!=0) roc[i] = MathLog(Close[i]/Close[i+1]);


      
               
      hv[i]=0.0;  
      for(int loop = 0;loop<hist_vol_period;loop++)
         hv[i]= hv[i] + roc[i+loop];
         
      
      
      double mean=hv[i]/hist_vol_period;
      
      double sum = 0.0;
      
      for (int a = 0; a < hist_vol_period; a++)
         sum += MathPow((roc[i+a] - mean), 2);
         
         
      hv[i]= MathSqrt(sum/(hist_vol_period-1))*MathSqrt(252)*100;
      
      
      
         
   }         
   
   
   return(0);
} 


 