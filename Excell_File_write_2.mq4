
void OnTick()
  {
   
   static double LastHigh;
   static double LastLow;
   
   if ((LastHigh!=High[1]) && (LastLow!=Low[1]))
   
   {
   
      string   mySpreadsheet="Spreadsheet1.csv";
      
      int mySpreadsheetHandle= FileOpen(mySpreadsheet,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
      FileSeek(mySpreadsheetHandle,0,SEEK_END);
      FileWrite(mySpreadsheetHandle,"Time Stamp",Time[1],"High ",High[1],"Low ",Low[1]);
      FileClose(mySpreadsheetHandle);
      
      LastHigh=High[1];
      LastLow=Low[1];
      
      }
      
      Comment  
               ( 
                  "Last High " , High[1],"\n",
                  "Last Low ", Low [1]);
                  
                  
      
      
   
   
   
   
  }
//+------------------------------------------------------------------+
