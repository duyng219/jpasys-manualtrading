//+------------------------------------------------------------------+
//|                                          ManualTestingTrader.mq5 |
//|                                                            duyng |
//|                                      https://github.com/duyng219 |
//+------------------------------------------------------------------+
#property copyright "duyng"
#property link      "https://github.com/duyng219"
#property version   "1.00"

//+----------------------------------------------------------+
//| EA Enumerations / Bảng liệt kê EA                        |
//+----------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <Controls/Button.mqh>
#include <Controls/Label.mqh>
#include "../duyng.dev_JpaSystemMain/Include/Core/RiskManager.mqh"
#include "../duyng.dev_JpaSystemMain/Include/Indicator/Indicators.mqh"
#include "../duyng.dev_JpaSystemMain/Include/Core/PositionManager.mqh"

CTrade trade;
CButton btnBuy;
CButton btnSell;
CButton btnClose;
CLabel lblAccountInfo;

CRM riskManager;
CPM positionManager;
CiATR    ATR;

//+----------------------------------------------------------+
//| Input & Global Variables | Biến đầu vào và biến toàn cục |
//+----------------------------------------------------------+
sinput group                    "INPUT" // Các biến đầu vào
input ulong                     MagicNumber            = 1001;
input double                    Capital                = 10000;
input double                    RewardRisk             = 0;       // (Auto Set TP If > 0)
input int                       SLPoints               = 0;

sinput group                    "RISK MANAGEMENT"
sinput string                   strMM;                                                // :::::   MONEY MANAGEMENT   :::::  
input ENUM_MONEY_MANAGEMENT     MoneyManagement         = MM_EQUITY_RISK_PERCENT;
input double                    MinLotPerEquitySteps    = 500;
input double                    FixedVolume             = 0.05;
input double                    RiskPercent             = 1;

sinput group                    "ATR SETTINGS"
input int                       ATRPeriod              = 14;
input double                    ATRFactor              = 2.0;

sinput group                    "TRAILING STOP" // Dừng lỗ theo sau
input bool                      trailSwingHighLow      = false;
input bool                      trailImbalance         = false;
input double                    trailEMA               = 0; // (Enable If > 0)
input double                    trailDonchianChannel   = 0;
input double                    trailPoints            = 0;
input double                    trailATR               = 1.7;

sinput group                    "BACKTESTING" // Kiểm tra
input ENUM_TIMEFRAMES           HighTF                 = PERIOD_D1;
input ENUM_TIMEFRAMES           LowTF                  = PERIOD_M15;
input int                       EMAPeriod1             = 0; //(Enable If > 0)
input int                       EMAPeriod2             = 0; //(Enable If > 0)
input bool                      plotBolligerBands      = false;
input bool                      plotIchimoku           = false;
input bool                      plotMACD               = false;
input bool                      plotRSI                = false;
input bool                      plotStoch              = false;
input bool                      plotADX                = false;

sinput group                    "PROPFIRM"
input bool                      CloseAllPostions       = false;
input double                    MaxDrawdownD1          = -4.5;
input double                    ProfitTarget           = 10.0;

/*
Khối lượng giao dịch
Tổng số trade đang mở
Drawdown ngày

5. Mục tiêu và hạn chế
Mục tiêu lợi nhuận (Profit Target): Mức lợi nhuận mà bạn đặt ra cho một ngày, tuần, hoặc tháng.
Giới hạn thua lỗ (Loss Limit): Mức thua lỗ tối đa mà bạn chấp nhận cho một ngày, tuần, hoặc tháng.
Giới hạn rút vốn (Drawdown Limit): Mức giảm vốn tối đa mà bạn chấp nhận.

*/

#define BTN_BUY_NAME "Btn Buy"
#define BTN_BUY_STOP_NAME "Btn Buy Stop"
#define BTN_BUY_LIMIT_NAME "Btn Buy Limit"
#define BTN_CANCEL_BUY_NAME "Btn Cancel Buy"
#define BTN_CLOSE_BUY_NAME "Btn Close Buy"

#define BTN_SELL_NAME "Btn Sell"
#define BTN_SELL_STOP_NAME "Btn Sell Stop"
#define BTN_SELL_LIMIT_NAME "Btn Sell Limit"
#define BTN_CANCEL_SELL_NAME "Btn Cancel Sell"
#define BTN_CLOSE_SELL_NAME "Btn Close Sell"

 // Lấy kích thước biểu đồ
int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
// Top menu buttons
double btn_height = chart_height * 0.05;  // 5% chiều cao biểu đồ
double btn_width = chart_width * 0.15;   // 25% chiều rộng biểu đồ

int OnInit()
{
   // lblAccountInfo.Create(0,"lblAccountInfo",0,100,100,280,130);

   createText("1", string(_Period), 20,20,clrLinen,13,"Arial");


//   btnBuy.Create(0,BTN_BUY_NAME,0,int(chart_width*0.05),int(chart_height*0.1),int(btn_width),int(btn_height));
   btnBuy.Create(0,BTN_BUY_NAME,0,100,100,280,130);
   btnBuy.Text("BUY");
   btnBuy.Color(clrWhite);
   btnBuy.ColorBackground(C'2, 119, 118');
   btnBuy.ColorBorder(C'2, 119, 118');
   btnBuy.FontSize(11);

   // btnBuy.Create(0,BTN_BUY_STOP_NAME,0,100,130,280,160);
   // btnBuy.Text("Buy Stop");
   // btnBuy.Color(clrWhite);
   // btnBuy.ColorBackground(clrGreen);

   // btnBuy.Create(0,BTN_BUY_LIMIT_NAME,0,100,160,280,190);
   // btnBuy.Text("Buy Limit");
   // btnBuy.Color(clrWhite);
   // btnBuy.ColorBackground(clrGreen);

   // btnBuy.Create(0,BTN_CANCEL_BUY_NAME,0,100,190,280,220);
   // btnBuy.Text("Cancel Buy");
   // btnBuy.Color(clrWhite);
   // btnBuy.ColorBackground(clrGreen);

   // btnBuy.Create(0,BTN_CLOSE_BUY_NAME,0,100,220,280,250);
   // btnBuy.Text("Close Buy");
   // btnBuy.Color(clrWhite);
   // btnBuy.ColorBackground(C'2, 119, 118');
   // btnBuy.ColorBorder(C'2, 119, 118');

   //------
   btnSell.Create(0,BTN_SELL_NAME,0,280,100,460,130);
   btnSell.Text("SELL");
   btnSell.Color(clrWhite);
   btnSell.ColorBackground(clrDarkRed);
   btnSell.ColorBorder(clrDarkRed);
   btnSell.FontSize(11);

   // btnSell.Create(0,BTN_SELL_STOP_NAME,0,280,130,460,160);
   // btnSell.Text("Sell Stop");
   // btnSell.Color(clrWhite);
   // btnSell.ColorBackground(clrRed);

   // btnSell.Create(0,BTN_SELL_LIMIT_NAME,0,280,160,460,190);
   // btnSell.Text("Sell Limit");
   // btnSell.Color(clrWhite);
   // btnSell.ColorBackground(clrRed);

   // btnSell.Create(0,BTN_CANCEL_SELL_NAME,0,280,190,460,220);
   // btnSell.Text("Cancel Sell");
   // btnSell.Color(clrWhite);
   // btnSell.ColorBackground(clrRed);

   // btnSell.Create(0,BTN_CLOSE_SELL_NAME,0,280,220,460,250);
   // btnSell.Text("Close Sell");
   // btnSell.Color(clrWhite);
   // btnSell.ColorBackground(clrRed);

   //btnSell.Create(0,BTN_SELL_NAME,0,280,130,460,160);
   
   // btnClose.Create(0,BTN_CLOSE_NAME,0,100,160,280,190);
   // btnClose.Text("Close");
   // btnClose.Color(clrWhite);
   // btnClose.ColorBackground(clrBlack);

   // btnBuy.Create(0,BTN_TEST_NAME,0,280,190,460,220);
   // btnBuy.Text("Tets");
   // btnBuy.Color(clrWhite);
   // btnBuy.ColorBackground(clrGreen);
   
   ChartRedraw();

   int ATRHandle = ATR.Init(_Symbol,PERIOD_CURRENT,ATRPeriod);
   
   if(ATRHandle == -1){
      return(INIT_FAILED);}
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   btnBuy.Destroy(reason);
}

void OnTick()
{  
   // ATR
   ATR.RefreshMain();
   double atr1 = ATR.main[1]; 
   double atr2 = ATR.main[2];
   double ATRValue = atr1 * ATRFactor;

   


   // Các logic khác của bạn...
   if(btnBuy.Pressed())
   {
      string entrySignal = "BUY";
      double stoplossATR = positionManager.CalculateStopLossByATR(_Symbol,entrySignal,ATRValue,ATRFactor);
      double volume = riskManager.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(stoplossATR-SYMBOL_ASK),FixedVolume,ORDER_TYPE_BUY);
      if(volume > 0)
      {
         trade.Buy(volume,_Symbol,0,stoplossATR,SymbolInfoDouble(_Symbol,SYMBOL_ASK)+100*_Point);
         Print(__FUNCTION__," > Đã mua ... ");
      }
      btnBuy.Pressed(false);
   }
   
   if(btnSell.Pressed())
   {
      string entrySignal = "SELL";
      double stoplossATR = positionManager.CalculateStopLossByATR(_Symbol,entrySignal,ATRValue,ATRFactor);
      Print("stoplossATR: ", stoplossATR);
      Print("SYMBOL_BID: ", SYMBOL_BID);
      double volume = riskManager.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(stoplossATR-SYMBOL_BID),FixedVolume,ORDER_TYPE_SELL);
      if(volume > 0)
      {
         trade.Sell(volume,_Symbol,0,stoplossATR,SymbolInfoDouble(_Symbol,SYMBOL_BID)-100*_Point);
         Print(__FUNCTION__," > Đã Sell ...");
      }
      
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

bool createText(string pObjName, string pText, int pX, int pY, int pFontsize, color pClrText, string pFont)
{
   ResetLastError();
   if(!ObjectCreate(0,pObjName,OBJ_LABEL,0,0,0))
   {
      Print(__FUNCTION__,"Error creating object ", GetLastError());
      return(false);
   }
   else{
      ObjectSetInteger(0,pObjName,OBJPROP_XDISTANCE,pX);
      ObjectSetInteger(0,pObjName,OBJPROP_YDISTANCE,pY);
      ObjectSetInteger(0,pObjName,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetString(0,pObjName,OBJPROP_TEXT,pText);
      ObjectSetInteger(0,pObjName,OBJPROP_COLOR,pClrText);
      ObjectSetInteger(0,pObjName,OBJPROP_FONTSIZE,pFontsize);
      // ObjectSetInteger(0,pObjName,OBJPROP_FONT,pFont);


      // ObjectSetInteger(0,pObjName,OBJPROP_XSIZE,100);
      // ObjectSetInteger(0,pObjName,OBJPROP_YSIZE,20);
      return(true);
   }
}
