//THIS TRADING BOT IS BASED ON René Balke MQL5 TURTOTIAL
//https://www.youtube.com/watch?v=nlj9gUuf7Wg&list=LL&index=3

#include <trade/trade.mqh> 

input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;
input int AtrPeriods = 14;
input double TriggerFactor = 2.5;
input double Lots = 0.1;
input int TpPoints = 800;
input int SlPoints = 500;
input string commentWhenExc = "Atr Excecuted";
input int TslTriggerPoints = 350;
input int TslPoints = 100;  


input int Magic = 2;


int handleAtr;    
int barsTotal;
CTrade trade;


int OnInit(){
  
   trade.SetExpertMagicNumber(Magic);
   handleAtr = iATR(NULL,Timeframe,AtrPeriods);
   barsTotal = iBars(NULL,Timeframe);
   
   
   return(INIT_SUCCEEDED);
  }

void OnTick(){

   for(int i=0; i<PositionsTotal();i++){
                      
      ulong posTicket = PositionGetTicket(i);
  
      if(PositionGetSymbol(POSITION_SYMBOL) != _Symbol) continue;     
      if(PositionGetInteger(POSITION_MAGIC) != Magic) continue;
      
      
      double posPriceOpen = PositionGetDouble(POSITION_PRICE_OPEN);
      double posSl = PositionGetDouble(POSITION_SL);
      double posTp = PositionGetDouble(POSITION_TP);     
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
         
         if(bid > posPriceOpen + TslTriggerPoints * _Point){
            double sl = posPriceOpen + TslPoints*_Point;
            sl = NormalizeDouble(sl,_Digits);  
            if(sl > posSl){      
               trade.PositionModify(posTicket,sl,posTp);
            }           
         }
      }else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
         if(ask < posPriceOpen - TslTriggerPoints * _Point){
            double sl = posPriceOpen - TslPoints * _Point;
            sl = NormalizeDouble(sl,_Digits);
            if(sl < posSl || posSl == 0){
               trade.PositionModify(posTicket,sl,posTp);
            }
         }
      
      
      }
      
   }
   
   int bars = iBars(NULL,Timeframe);
   
   if(barsTotal != bars){
      barsTotal = bars;
   
      double atr[];

      CopyBuffer(handleAtr,0,1,1,atr);
      
      double open= iOpen(NULL,Timeframe,1);

      double close = iClose(NULL,Timeframe,1);
      
      if(open < close && close - open > atr[0]*TriggerFactor){
         Print("Buy reee");    
         executeBuy();  
                 
       } else if(open > close && open - close > atr[0]*TriggerFactor){
         Print("Sell reee");  
         executeSell();         
       } 
     }        
 }
  
  
void executeBuy(){
            
   double entry = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   entry = NormalizeDouble(entry,_Digits);
   
   double tp = entry + TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   double sl = entry - SlPoints*_Point;
   sl = NormalizeDouble(sl,_Digits);

   trade.Buy(Lots,NULL,entry,sl,tp,commentWhenExc);  
      
}

void executeSell(){

   double entry = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   entry = NormalizeDouble(entry,_Digits);
   
   double tp = entry - TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   double sl = entry + SlPoints*_Point;
   sl = NormalizeDouble(sl,_Digits);
                    
   trade.Sell(Lots,NULL,entry,sl,tp,commentWhenExc);
   
}
