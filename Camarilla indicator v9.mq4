//+------------------------------------------------------------------+
//|                                       Camarilla indicator v1.mq4 |
//|                                      Copyright 2022, Paul Muscat |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//// v 4,5,6 and 7 each work and include one extra day
//// v 7 working great
///v 8 fixed lenght of current day lines
///v9



#property copyright "Copyright 2022, Paul Muscat"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
extern color StandardFontColor = White;
extern int StandardFontSize = 8;

double High_3,Low_3,Close_3,Range_3,High_2,Low_2, Close_2, Range_2, High_1,Low_1,Close_1,Range_1,High_0,Low_0,Close_0,Range_0;
double High_4,Low_4,Close_4,Range_4;
double High_5,Low_5,Close_5,Range_5;

double High_6,Low_6,Close_6,Range_6;


double H5_6,H4_6,H3_6, H2_6, H1_6, L1_6,L2_6, L3_6,L4_6, L5_6;
double H5_5,H4_5,H3_5, H2_5, H1_5, L1_5,L2_5, L3_5,L4_5, L5_5;
double H5_4,H4_4,H3_4, H2_4, H1_4, L1_4,L2_4, L3_4,L4_4, L5_4;
double H5_3,H4_3,H3_3, H2_3, H1_3, L1_3,L2_3, L3_3,L4_3, L5_3, H5_2, H4_2, H3_2, H2_2, H1_2, L1_2,L2_2, L3_2, L4_2, L5_2;

double H5_1, H4_1,H3_1, H2_1, H1_1, L1_1, L2_1, L3_1,L4_1, L5_1, H5_0,
     H4_0,  H3_0, H2_0, H1_0, L1_0, L2_0, L3_0, L4_0, L5_0;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
if(Period() > 1440)
      {     
         Print("Error - Chart period is greater than 1 day.");
           
      }
  

GetDayData();
CalculatePivots (); 
DeleteObjects();
CreateAndDrawObjects();
PrintInfo ();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {


DeleteObjects();
 

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

      

 if (!newBar()) return;  //only trade on new bar



//---- exit if period is greater than daily charts
if(Period() > 1440)
      {     
         Print("Error - Chart period is greater than 1 day.");
         //return; // then exit   
      }
  

GetDayData();
CalculatePivots (); 
DeleteObjects();
CreateAndDrawObjects();
PrintInfo();

  
  
 } 
//+------------------------------------------------------------------+





bool newBar(){

   datetime          currentTime =  iTime(Symbol(),Period(),0);// get openong time of bar
   static datetime   priorTime =   currentTime; // initialized to prevent trading on first bar
   bool              result =      (currentTime!=priorTime); //Time has changed
   priorTime               =        currentTime; //reset for next time
   return(result);
   }

void DeleteObjects()
{

ObjectDelete (0,"H5_6");
ObjectDelete (0,"H5_6 label");

ObjectDelete (0,"H4_6");
ObjectDelete (0,"H4_6 label");
 

ObjectDelete (0,"H3_6");
ObjectDelete (0,"H3_6 label");

ObjectDelete (0,"L3_6");
ObjectDelete (0,"L3_6 label");


ObjectDelete (0,"L4_6");
ObjectDelete (0,"L4_6 label");



ObjectDelete (0,"L5_6");
ObjectDelete (0,"L5_6 label");
////////

ObjectDelete (0,"H5_5");
ObjectDelete (0,"H5_5 label");

ObjectDelete (0,"H4_5");
ObjectDelete (0,"H4_5 label");
 

ObjectDelete (0,"H3_5");
ObjectDelete (0,"H3_5 label");

ObjectDelete (0,"L3_5");
ObjectDelete (0,"L3_5 label");


ObjectDelete (0,"L4_5");
ObjectDelete (0,"L4_5 label");



ObjectDelete (0,"L5_5");
ObjectDelete (0,"L5_5 label");
////////


ObjectDelete (0,"H5_4");
ObjectDelete (0,"H5_4 label");

ObjectDelete (0,"H4_4");
ObjectDelete (0,"H4_4 label");
 

ObjectDelete (0,"H3_4");
ObjectDelete (0,"H3_4 label");

ObjectDelete (0,"L3_4");
ObjectDelete (0,"L3_4 label");


ObjectDelete (0,"L4_4");
ObjectDelete (0,"L4_4 label");



ObjectDelete (0,"L5_4");
ObjectDelete (0,"L5_4 label");
 
    
 ObjectDelete (0,"H5_3");
ObjectDelete (0,"H5_3 label");

ObjectDelete (0,"H4_3");
ObjectDelete (0,"H4_3 label");
 

ObjectDelete (0,"H3_3");
ObjectDelete (0,"H3_3 label");

ObjectDelete (0,"L3_3");
ObjectDelete (0,"L3_3 label");


ObjectDelete (0,"L4_3");
ObjectDelete (0,"L4_3 label");



ObjectDelete (0,"L5_3");
ObjectDelete (0,"L5_3 label");
 
ObjectDelete (0,"H5_2");
ObjectDelete (0,"H5_2 label");

ObjectDelete (0,"H4_2");
ObjectDelete (0,"H4_2 label");
 

ObjectDelete (0,"H3_2");
ObjectDelete (0,"H3_2 label");

ObjectDelete (0,"L3_2");
ObjectDelete (0,"L3_2 label");


ObjectDelete (0,"L4_2");
ObjectDelete (0,"L4_2 label");



ObjectDelete (0,"L5_2");
ObjectDelete (0,"L5_2 label");



////////


ObjectDelete (0,"H5_1");
ObjectDelete (0,"H5_1 label");

ObjectDelete (0,"H4_1");
ObjectDelete (0,"H4_1 label");
 

ObjectDelete (0,"H3_1");
ObjectDelete (0,"H3_1 label");

ObjectDelete (0,"L3_1");
ObjectDelete (0,"L3_1 label");


ObjectDelete (0,"L4_1");
ObjectDelete (0,"L4_1 label");



ObjectDelete (0,"L5_1");
ObjectDelete (0,"L5_1 label");


}

void GetDayData ()

{



/// day 6



if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,6)) !=0)

{
 High_6=iHigh(Symbol(),PERIOD_D1, 6);
 Low_6=iLow(Symbol(),PERIOD_D1,6);
 Close_6=iClose (Symbol(),PERIOD_D1,6);
 Range_6=High_6-Low_6; }

else


{
 High_6=iHigh(Symbol(),PERIOD_D1, 7);
 Low_6=iLow(Symbol(),PERIOD_D1,7);
 Close_6=iClose (Symbol(),PERIOD_D1,7);
 Range_6=High_6-Low_6; }



/////


/// day 5



if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,5)) !=0)

{
 High_5=iHigh(Symbol(),PERIOD_D1, 5);
 Low_5=iLow(Symbol(),PERIOD_D1,5);
 Close_5=iClose (Symbol(),PERIOD_D1,5);
 Range_5=High_5-Low_5; }

else


{
 High_5=iHigh(Symbol(),PERIOD_D1, 6);
 Low_5=iLow(Symbol(),PERIOD_D1,6);
 Close_5=iClose (Symbol(),PERIOD_D1,6);
 Range_5=High_5-Low_5; }



/////


if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,4)) !=0)

{
 High_4=iHigh(Symbol(),PERIOD_D1, 4);
 Low_4=iLow(Symbol(),PERIOD_D1,4);
 Close_4=iClose (Symbol(),PERIOD_D1,4);
 Range_4=High_4-Low_4; }

else


{
 High_4=iHigh(Symbol(),PERIOD_D1, 5);
 Low_4=iLow(Symbol(),PERIOD_D1,5);
 Close_4=iClose (Symbol(),PERIOD_D1,5);
 Range_4=High_4-Low_4; }




if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,3)) !=0)

{
 High_3=iHigh(Symbol(),PERIOD_D1, 3);
 Low_3=iLow(Symbol(),PERIOD_D1,3);
 Close_3=iClose (Symbol(),PERIOD_D1,3);
 Range_3=High_3-Low_3; }

else


{
 High_3=iHigh(Symbol(),PERIOD_D1, 4);
 Low_3=iLow(Symbol(),PERIOD_D1,4);
 Close_3=iClose (Symbol(),PERIOD_D1,4);
 Range_3=High_3-Low_3; }




if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,2)) !=0)
 {
  High_2=iHigh(Symbol(),PERIOD_D1, 2);
  Low_2=iLow(Symbol(),PERIOD_D1,2);
  Close_2=iClose (Symbol(),PERIOD_D1,2);
  Range_2=High_2-Low_2;
  } 
else

 {
  High_2=iHigh(Symbol(),PERIOD_D1, 3);
  Low_2=iLow(Symbol(),PERIOD_D1,3);
  Close_2=iClose (Symbol(),PERIOD_D1,3);
  Range_2=High_2-Low_2;
  } 


if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,1)) !=0)
{
  High_1=iHigh(Symbol(),PERIOD_D1, 1);
  Low_1=iLow(Symbol(),PERIOD_D1,1);
  Close_1=iClose (Symbol(),PERIOD_D1,1);
  Range_1=High_1-Low_1; 
}

else

{
  High_1=iHigh(Symbol(),PERIOD_D1, 2);
  Low_1=iLow(Symbol(),PERIOD_D1,2);
  Close_1=iClose (Symbol(),PERIOD_D1,2);
  Range_1=High_1-Low_1; 
}



if (TimeDayOfWeek (iTime (Symbol(),PERIOD_D1,1)) !=0)

  { High_0=iHigh(Symbol(),PERIOD_D1, 0);
  Low_0=iLow(Symbol(),PERIOD_D1,0);
  Close_0=iClose (Symbol(),PERIOD_D1,0);
  Range_0=High_0-Low_0;}
  
  else
  
   
  { High_0=iHigh(Symbol(),PERIOD_D1, 1);
  Low_0=iLow(Symbol(),PERIOD_D1,1);
  Close_0=iClose (Symbol(),PERIOD_D1,1);
  Range_0=High_0-Low_0;}






}

void CalculatePivots()

{



// Calculate Pivots for day 6
    H5_6= (High_6/Low_6)*Close_6;
     H4_6= Close_6+(Range_6*1.1/2);
     H3_6= Close_6+(Range_6*1.1/4);
     H2_6= Close_6+(Range_6*1.1/6);
     H1_6= Close_6+(Range_6*1.1/12);

     L1_6= Close_6-(Range_6*1.1/12);
     L2_6= Close_6-(Range_6*1.1/6);
     L3_6= Close_6-(Range_6*1.1/4);
     L4_6= Close_6-(Range_6*1.1/2);
     L5_6= Close_6-(H5_6-Close_6);


// Calculate Pivots for day 5
    H5_5= (High_5/Low_5)*Close_5;
     H4_5= Close_5+(Range_5*1.1/2);
     H3_5= Close_5+(Range_5*1.1/4);
     H2_5= Close_5+(Range_5*1.1/6);
     H1_5= Close_5+(Range_5*1.1/12);

     L1_5= Close_5-(Range_5*1.1/12);
     L2_5= Close_5-(Range_5*1.1/6);
     L3_5= Close_5-(Range_5*1.1/4);
     L4_5= Close_5-(Range_5*1.1/2);
     L5_5= Close_5-(H5_5-Close_5);



// Calculate Pivots for day 4
    H5_4= (High_4/Low_4)*Close_4;
     H4_4= Close_4+(Range_4*1.1/2);
     H3_4= Close_4+(Range_4*1.1/4);
     H2_4= Close_4+(Range_4*1.1/6);
     H1_4= Close_4+(Range_4*1.1/12);

     L1_4= Close_4-(Range_4*1.1/12);
     L2_4= Close_4-(Range_4*1.1/6);
     L3_4= Close_4-(Range_4*1.1/4);
     L4_4= Close_4-(Range_4*1.1/2);
     L5_4= Close_4-(H5_4-Close_4);


// Calculate Pivots for day 3
    H5_3= (High_3/Low_3)*Close_3;
     H4_3= Close_3+(Range_3*1.1/2);
     H3_3= Close_3+(Range_3*1.1/4);
     H2_3= Close_3+(Range_3*1.1/6);
     H1_3= Close_3+(Range_3*1.1/12);

     L1_3= Close_3-(Range_3*1.1/12);
     L2_3= Close_3-(Range_3*1.1/6);
     L3_3= Close_3-(Range_3*1.1/4);
     L4_3= Close_3-(Range_3*1.1/2);
     L5_3= Close_3-(H5_3-Close_3);

   
   

//Pivots for day 2
     H5_2= (High_2/Low_2)*Close_2;
     H4_2= Close_2+(Range_2*1.1/2);
     H3_2= Close_2+(Range_2*1.1/4);
     H2_2= Close_2+(Range_2*1.1/6);
     H1_2= Close_2+(Range_2*1.1/12);

     L1_2= Close_2-(Range_2*1.1/12);
     L2_2= Close_2-(Range_2*1.1/6);
     L3_2= Close_2-(Range_2*1.1/4);
     L4_2= Close_2-(Range_2*1.1/2);
     L5_2= Close_2-(H5_2-Close_2);


//Pivots for day 1
     
     H5_1= (High_1/Low_1)*Close_1;
     H4_1= Close_1+(Range_1*1.1/2);
     H3_1= Close_1+(Range_1*1.1/4);
     H2_1= Close_1+(Range_1*1.1/6);
     H1_1= Close_1+(Range_1*1.1/12);

     L1_1= Close_1-(Range_1*1.1/12);
     L2_1= Close_1-(Range_1*1.1/6);
     L3_1= Close_1-(Range_1*1.1/4);
     L4_1= Close_1-(Range_1*1.1/2);
     L5_1= Close_1- (H5_1-Close_1);


//Pivots for day 0
  
     H5_0= (High_0/Low_0)*Close_0;
     H4_0= Close_0+(Range_0*1.1/2);
     H3_0= Close_0+(Range_0*1.1/4);
     H2_0= Close_0+(Range_0*1.1/6);
     H1_0= Close_0+(Range_0*1.1/12);

     L1_0= Close_0-(Range_0*1.1/12);
     L2_0= Close_0-(Range_0*1.1/6);
     L3_0= Close_0-(Range_0*1.1/4);
     L4_0= Close_0-(Range_0*1.1/2);
     L5_0= Close_0= (H5_0-Close_0);
 }

void PrintInfo ()

 {  
Comment ("H5_1 = ", NormalizeDouble(H5_1,Digits),
         "\nH4_1= " ,NormalizeDouble(H4_1,Digits),
         "\nH3_1= " ,NormalizeDouble(H3_1,Digits),
         "\nL3_1= " ,NormalizeDouble(L3_1,Digits),
         "\nL4_1= " ,NormalizeDouble (L4_1, Digits),
         "\nL5_1= " ,NormalizeDouble(L5_1,Digits));
}







void CreateAndDrawObjects()

{


  ///  Draw lines Day 6  
datetime linestart;
datetime lineend;
   
      if(ObjectFind("H5_6") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,5);
             lineend = iTime(Symbol(),PERIOD_D1,4);
             
            ObjectCreate ("H5_6",OBJ_TREND,0,
            linestart,H5_6, 
            lineend,H5_6);
            ObjectSetInteger(0,"H5_6",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_6",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_6",OBJPROP_RAY_RIGHT,false);
      
         }
         
      if(ObjectFind("H5_6 label") != 0)
      {
      ObjectCreate("H5_6 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,5), H5_6);
      ObjectSetText("H5_6 label", " H5_6", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_6") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,5);
             lineend = iTime(Symbol(),PERIOD_D1,4);
            ObjectCreate ("H4_6",OBJ_TREND,0,
            linestart,H4_6, 
            lineend,H4_6);
            ObjectSetInteger(0,"H4_6",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_6",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_6",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_6 label") != 0)
      {
      ObjectCreate("H4_6 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,5), H4_6);
      ObjectSetText("H4_6 label", " H4_6", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_6") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,5);
             lineend = iTime(Symbol(),PERIOD_D1,4);
            ObjectCreate ("H3_6",OBJ_TREND,0,
            linestart,H3_6, 
            lineend,H3_6);
            ObjectSetInteger(0,"H3_6",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_6",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_6",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_6 label") != 0)
      {
      ObjectCreate("H3_6 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,5), H3_6);
      ObjectSetText("H3_6 label", " H3_6", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_6") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,5);
             lineend = iTime(Symbol(),PERIOD_D1,4);
            ObjectCreate ("L3_6",OBJ_TREND,0,
            linestart,L3_6, 
            lineend,L3_6);
            ObjectSetInteger(0,"L3_6",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_6",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_6",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_6 label") != 0)
      {
      ObjectCreate("L3_6 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,5), L3_6);
      ObjectSetText("L3_6 label", " L3_6", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_6") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,5);
             lineend = iTime(Symbol(),PERIOD_D1,4);
            ObjectCreate ("L4_6",OBJ_TREND,0,
            linestart,L4_6, 
            lineend,L4_6);
            ObjectSetInteger(0,"L4_6",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_6",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_6",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_6 label") != 0)
      {
      ObjectCreate("L4_6 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,5), L4_6);
      ObjectSetText("L4_6 label", " L4_6", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_6") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,5);
             lineend = iTime(Symbol(),PERIOD_D1,4);
            ObjectCreate ("L5_6",OBJ_TREND,0,
            linestart,L5_6, 
            lineend,L5_6);
            ObjectSetInteger(0,"L5_6",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_6",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_6",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_6 label") != 0)
      {
      ObjectCreate("L5_6 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,5), L5_6);
      ObjectSetText("L5_6 label", " L5_6", StandardFontSize, "Arial", StandardFontColor);
      }










  ///  Draw lines Day 5  
 
   
      if(ObjectFind("H5_5") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,4);
             lineend = iTime(Symbol(),PERIOD_D1,3);
             
            ObjectCreate ("H5_5",OBJ_TREND,0,
            linestart,H5_5, 
            lineend,H5_5);
            ObjectSetInteger(0,"H5_5",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_5",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_5",OBJPROP_RAY_RIGHT,false);
      
         }
         
      if(ObjectFind("H5_5 label") != 0)
      {
      ObjectCreate("H5_5 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,4), H5_5);
      ObjectSetText("H5_5 label", " H5_5", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_5") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,4);
             lineend = iTime(Symbol(),PERIOD_D1,3);
            ObjectCreate ("H4_5",OBJ_TREND,0,
            linestart,H4_5, 
            lineend,H4_5);
            ObjectSetInteger(0,"H4_5",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_5",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_5",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_5 label") != 0)
      {
      ObjectCreate("H4_5 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,4), H4_5);
      ObjectSetText("H4_5 label", " H4_5", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_5") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,4);
             lineend = iTime(Symbol(),PERIOD_D1,3);
            ObjectCreate ("H3_5",OBJ_TREND,0,
            linestart,H3_5, 
            lineend,H3_5);
            ObjectSetInteger(0,"H3_5",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_5",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_5",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_5 label") != 0)
      {
      ObjectCreate("H3_5 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,4), H3_5);
      ObjectSetText("H3_5 label", " H3_5", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_5") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,4);
             lineend = iTime(Symbol(),PERIOD_D1,3);
            ObjectCreate ("L3_5",OBJ_TREND,0,
            linestart,L3_5, 
            lineend,L3_5);
            ObjectSetInteger(0,"L3_5",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_5",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_5",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_5 label") != 0)
      {
      ObjectCreate("L3_5 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,4), L3_5);
      ObjectSetText("L3_5 label", " L3_5", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_5") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,4);
             lineend = iTime(Symbol(),PERIOD_D1,3);
            ObjectCreate ("L4_5",OBJ_TREND,0,
            linestart,L4_5, 
            lineend,L4_5);
            ObjectSetInteger(0,"L4_5",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_5",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_5",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_5 label") != 0)
      {
      ObjectCreate("L4_5 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,4), L4_5);
      ObjectSetText("L4_5 label", " L4_5", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_5") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,4);
             lineend = iTime(Symbol(),PERIOD_D1,3);
            ObjectCreate ("L5_5",OBJ_TREND,0,
            linestart,L5_5, 
            lineend,L5_5);
            ObjectSetInteger(0,"L5_5",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_5",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_5",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_5 label") != 0)
      {
      ObjectCreate("L5_5 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,4), L5_5);
      ObjectSetText("L5_5 label", " L5_5", StandardFontSize, "Arial", StandardFontColor);
      }






  ///  Draw lines Day 4  

   
      if(ObjectFind("H5_4") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,3);
             lineend = iTime(Symbol(),PERIOD_D1,2);
             
            ObjectCreate ("H5_4",OBJ_TREND,0,
            linestart,H5_4, 
            lineend,H5_4);
            ObjectSetInteger(0,"H5_4",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_4",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_4",OBJPROP_RAY_RIGHT,false);
      
         }
         
      if(ObjectFind("H5_4 label") != 0)
      {
      ObjectCreate("H5_4 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,3), H5_4);
      ObjectSetText("H5_4 label", " H5_4", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_4") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,3);
             lineend = iTime(Symbol(),PERIOD_D1,2);
            ObjectCreate ("H4_4",OBJ_TREND,0,
            linestart,H4_4, 
            lineend,H4_4);
            ObjectSetInteger(0,"H4_4",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_4",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_4",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_4 label") != 0)
      {
      ObjectCreate("H4_4 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,3), H4_4);
      ObjectSetText("H4_4 label", " H4_4", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_4") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,3);
             lineend = iTime(Symbol(),PERIOD_D1,2);
            ObjectCreate ("H3_4",OBJ_TREND,0,
            linestart,H3_4, 
            lineend,H3_4);
            ObjectSetInteger(0,"H3_4",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_4",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_4",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_4 label") != 0)
      {
      ObjectCreate("H3_4 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,3), H3_4);
      ObjectSetText("H3_4 label", " H3_4", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_4") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,3);
             lineend = iTime(Symbol(),PERIOD_D1,2);
            ObjectCreate ("L3_4",OBJ_TREND,0,
            linestart,L3_4, 
            lineend,L3_4);
            ObjectSetInteger(0,"L3_4",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_4",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_4",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_4 label") != 0)
      {
      ObjectCreate("L3_4 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,3), L3_4);
      ObjectSetText("L3_4 label", " L3_4", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_4") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,3);
             lineend = iTime(Symbol(),PERIOD_D1,2);
            ObjectCreate ("L4_4",OBJ_TREND,0,
            linestart,L4_4, 
            lineend,L4_4);
            ObjectSetInteger(0,"L4_4",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_4",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_4",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_4 label") != 0)
      {
      ObjectCreate("L4_4 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,3), L4_4);
      ObjectSetText("L4_4 label", " L4_4", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_4") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,3);
             lineend = iTime(Symbol(),PERIOD_D1,2);
            ObjectCreate ("L5_4",OBJ_TREND,0,
            linestart,L5_4, 
            lineend,L5_4);
            ObjectSetInteger(0,"L5_4",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_4",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_4",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_4 label") != 0)
      {
      ObjectCreate("L5_4 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,3), L5_4);
      ObjectSetText("L5_4 label", " L5_4", StandardFontSize, "Arial", StandardFontColor);
      }










   ///  Draw lines Day 3 (DAY BEFORE YESTERDAY)
 
   
      if(ObjectFind("H5_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
             
            ObjectCreate ("H5_3",OBJ_TREND,0,
            linestart,H5_3, 
            lineend,H5_3);
            ObjectSetInteger(0,"H5_3",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_3",OBJPROP_RAY_RIGHT, false);
      
         }
         
      if(ObjectFind("H5_3 label") != 0)
      {
      ObjectCreate("H5_3 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,2), H5_3);
      ObjectSetText("H5_3 label", " H5_3", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("H4_3",OBJ_TREND,0,
            linestart,H4_3, 
            lineend,H4_3);
            ObjectSetInteger(0,"H4_3",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_3 label") != 0)
      {
      ObjectCreate("H4_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), H4_3);
      ObjectSetText("H4_3 label", " H4_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("H3_3",OBJ_TREND,0,
            linestart,H3_3, 
            lineend,H3_3);
            ObjectSetInteger(0,"H3_3",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_3 label") != 0)
      {
      ObjectCreate("H3_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), H3_3);
      ObjectSetText("H3_3 label", " H3_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("L3_3",OBJ_TREND,0,
            linestart,L3_3, 
            lineend,L3_3);
            ObjectSetInteger(0,"L3_3",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_3 label") != 0)
      {
      ObjectCreate("L3_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), L3_3);
      ObjectSetText("L3_3 label", " L3_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("L4_3",OBJ_TREND,0,
            linestart,L4_3, 
            lineend,L4_3);
            ObjectSetInteger(0,"L4_3",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_3 label") != 0)
      {
      ObjectCreate("L4_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), L4_3);
      ObjectSetText("L4_3 label", " L4_3", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_3") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,2);
             lineend = iTime(Symbol(),PERIOD_D1,1);
            ObjectCreate ("L5_3",OBJ_TREND,0,
            linestart,L5_3, 
            lineend,L5_3);
            ObjectSetInteger(0,"L5_3",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_3",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_3",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_3 label") != 0)
      {
      ObjectCreate("L5_3 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,2), L5_3);
      ObjectSetText("L5_3 label", " L5_3", StandardFontSize, "Arial", StandardFontColor);
      }






   ///  Draw lines Day 2 (YESTERDAY)
 
   
Comment ("H5_2 = ", H5_2,"\nH4_2= " ,H4_2);

      if(ObjectFind("H5_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
             
            ObjectCreate ("H5_2",OBJ_TREND,0,
            linestart,H5_2, 
            lineend,H5_2);
            ObjectSetInteger(0,"H5_2",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_2",OBJPROP_RAY_RIGHT, false);
      
         }
         
      if(ObjectFind("H5_2 label") != 0)
      {
      ObjectCreate("H5_2 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,1), H5_2);
      ObjectSetText("H5_2 label", " H5_2", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("H4_2",OBJ_TREND,0,
            linestart,H4_2, 
            lineend,H4_2);
            ObjectSetInteger(0,"H4_2",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_2 label") != 0)
      {
      ObjectCreate("H4_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), H4_2);
      ObjectSetText("H4_2 label", " H4_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("H3_2",OBJ_TREND,0,
            linestart,H3_2, 
            lineend,H3_2);
            ObjectSetInteger(0,"H3_2",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_2 label") != 0)
      {
      ObjectCreate("H3_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), H3_2);
      ObjectSetText("H3_2 label", " H3_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("L3_2",OBJ_TREND,0,
            linestart,L3_2, 
            lineend,L3_2);
            ObjectSetInteger(0,"L3_2",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_2 label") != 0)
      {
      ObjectCreate("L3_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), L3_2);
      ObjectSetText("L3_2 label", " L3_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("L4_2",OBJ_TREND,0,
            linestart,L4_2, 
            lineend,L4_2);
            ObjectSetInteger(0,"L4_2",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_2 label") != 0)
      {
      ObjectCreate("L4_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), L4_2);
      ObjectSetText("L4_2 label", " L4_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_2") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,1);
             lineend = iTime(Symbol(),PERIOD_D1,0);
            ObjectCreate ("L5_2",OBJ_TREND,0,
            linestart,L5_2, 
            lineend,L5_2);
            ObjectSetInteger(0,"L5_2",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_2",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_2",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_2 label") != 0)
      {
      ObjectCreate("L5_2 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,1), L5_2);
      ObjectSetText("L5_2 label", " L5_2", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
  
  
  
   ///  Draw lines Day 1 (TODAY)

        

      if(ObjectFind("H5_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime (Symbol(),Period(),0);
             
            ObjectCreate ("H5_1",OBJ_TREND,0,
            linestart,H5_1, 
            lineend,H5_1);
            ObjectSetInteger(0,"H5_1",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "H5_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H5_1",OBJPROP_RAY_RIGHT, false);
      
         }
         
      if(ObjectFind("H5_1 label") != 0)
      {
      ObjectCreate("H5_1 label", OBJ_TEXT, 0,iTime(Symbol(),PERIOD_D1,0), H5_1);
      ObjectSetText("H5_1 label", " H5_1", StandardFontSize, "Arial", StandardFontColor);
      }
      
  
      if(ObjectFind("H4_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime (Symbol(),Period(),0);
            ObjectCreate ("H4_1",OBJ_TREND,0,
            linestart,H4_1, 
            lineend,H4_1);
            ObjectSetInteger(0,"H4_1",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "H4_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H4_1",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H4_1 label") != 0)
      {
      ObjectCreate("H4_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), H4_1);
      ObjectSetText("H4_1 label", " H4_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
    if(ObjectFind("H3_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime (Symbol(),Period(),0);
            ObjectCreate ("H3_1",OBJ_TREND,0,
            linestart,H3_1, 
            lineend,H3_1);
            ObjectSetInteger(0,"H3_1",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "H3_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "H3_1",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("H3_1 label") != 0)
      {
      ObjectCreate("H3_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), H3_1);
      ObjectSetText("H3_1 label", " H3_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L3_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime (Symbol(),Period(),0);
            ObjectCreate ("L3_1",OBJ_TREND,0,
            linestart,L3_1, 
            lineend,L3_1);
            ObjectSetInteger(0,"L3_1",OBJPROP_COLOR,clrGreen);
            ObjectSetInteger(0, "L3_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L3_1",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L3_1 label") != 0)
      {
      ObjectCreate("L3_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), L3_1);
      ObjectSetText("L3_1 label", " L3_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
   if(ObjectFind("L4_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime (Symbol(),Period(),0);
            ObjectCreate ("L4_1",OBJ_TREND,0,
            linestart,L4_1, 
            lineend,L4_1);
            ObjectSetInteger(0,"L4_1",OBJPROP_COLOR,clrRed);
            ObjectSetInteger(0, "L4_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L4_1",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L4_1 label") != 0)
      {
      ObjectCreate("L4_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), L4_1);
      ObjectSetText("L4_1 label", " L4_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
   if(ObjectFind("L5_1") != 0)
         {
      
             linestart= iTime(Symbol(),PERIOD_D1,0);
             lineend = iTime (Symbol(),Period(),0);
            ObjectCreate ("L5_1",OBJ_TREND,0,
            linestart,L5_1, 
            lineend,L5_1);
            ObjectSetInteger(0,"L5_1",OBJPROP_COLOR,clrBlue);
            ObjectSetInteger(0, "L5_1",OBJPROP_WIDTH,3);
            ObjectSetInteger(0, "L5_1",OBJPROP_RAY_RIGHT, false);
      
         }
     
      if(ObjectFind("L5_1 label") != 0)
      {
      ObjectCreate("L5_1 label", OBJ_TEXT, 0, iTime(Symbol(),PERIOD_D1,0), L5_1);
      ObjectSetText("L5_1 label", " L5_1", StandardFontSize, "Arial", StandardFontColor);
      }
  
  
  
  }
  
  
  
  