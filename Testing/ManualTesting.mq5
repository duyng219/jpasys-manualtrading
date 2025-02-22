//+------------------------------------------------------------------+
//|                                          ManualTestingTrader.mq5 |
//|                                                            duyng |
//|                                      https://github.com/duyng219 |
//+------------------------------------------------------------------+
#property copyright "duyng"
#property link      "https://github.com/duyng219"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <Controls/Button.mqh>

CTrade trade;
CButton btnBuy;
CButton btnSell;
CButton btnClose;

#define BTN_BUY_NAME "Btn Buy"
#define BTN_SELL_NAME "Btn Sell"
#define BTN_CLOSE_NAME "Btn Close"

 // Lấy kích thước biểu đồ
int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
// Top menu buttons
double btn_height = chart_height * 0.05;  // 5% chiều cao biểu đồ
double btn_width = chart_width * 0.15;   // 25% chiều rộng biểu đồ



int OnInit()
{
//   btnBuy.Create(0,BTN_BUY_NAME,0,int(chart_width*0.05),int(chart_height*0.1),int(btn_width),int(btn_height));
   btnBuy.Create(0,BTN_BUY_NAME,0,100,100,280,130);
   btnBuy.Text("Buy");
   btnBuy.Color(clrWhite);
   btnBuy.ColorBackground(clrGreen);
   
   btnSell.Create(0,BTN_SELL_NAME,0,100,130,280,160);
   btnSell.Text("Sell");
   btnSell.Color(clrWhite);
   btnSell.ColorBackground(clrRed);
   
   btnClose.Create(0,BTN_CLOSE_NAME,0,100,160,280,190);
   btnClose.Text("Close");
   btnClose.Color(clrWhite);
   btnClose.ColorBackground(clrBlack);
   
   ChartRedraw();
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   btnBuy.Destroy(reason);
}

void OnTick()
{
   if(btnBuy.Pressed())
   {
      Print(__FUNCTION__," > buy btn was pressed...");
      trade.Buy(0.01,_Symbol,0,0,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+100*_Point);
      btnBuy.Pressed(false);
   }
   
   if(btnSell.Pressed())
   {
      Print(__FUNCTION__," > sell btn was pressed...");
      trade.Sell(0.01,_Symbol,0,0,SymbolInfoDouble(_Symbol,SYMBOL_BID)-100*_Point);
      btnSell.Pressed(false);
   }
   
   if(btnClose.Pressed())
   {
      Print(__FUNCTION__," > close btn was pressed...");
      for(int i=PositionsTotal()-1; i>=0; i--)
      {
         ulong posTicket = PositionGetTicket(i);
         trade.PositionClose(posTicket);
      }
      
      btnClose.Pressed(false);
   }
}