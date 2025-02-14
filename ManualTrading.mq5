//+------------------------------------------------------------------+
//|                                                ManualTrading.mq5 |
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

#include <Include.duyng/Indicator/Indicators.mqh>
#include <Include.duyng/Core/BarManager.mqh>
#include <Include.duyng/Core/PositionManager.mqh>
#include <Include.duyng/Core/RiskManager.mqh>


CTrade trade;
CButton btnBuy;
CButton btnBuyStop;
CButton btnBuyLimit;
CButton btnCancelBuy;
CButton btnCloseBuy;

CButton btnSell;
CButton btnSellStop;
CButton btnSellLimit;
CButton btnCancelSell;
CButton btnCloseSell;

CPM PM;
CRM RM;
CBar Bar;
CiATR ATR;
CiMA MA;

//+----------------------------------------------------------+
//| Input & Global Variables | Biến đầu vào và biến toàn cục |
//+----------------------------------------------------------+
sinput group                        "INPUT"
input int                           slPoints    = 150;

sinput group                        "RISK MANAGEMENT"
sinput string                       strMM;                  // :::::   MONEY MANAGEMENT   :::::  
input ENUM_MONEY_MANAGEMENT         MoneyManagement         = MM_EQUITY_RISK_PERCENT;
input double                        MinLotPerEquitySteps    = 500;
input double                        FixedVolume             = 0.05;
input double                        RiskPercent             = 1;

sinput group                        "MOVING AVERAGE SETTINGS"
input int                           MAPeriod    = 21;
input ENUM_MA_METHOD                MAMethod    = MODE_EMA;
input int                           MAShift     = 0;
input ENUM_APPLIED_PRICE            MAPrice     = PRICE_CLOSE;

sinput group                        "ATR SETTINGS"
input int                           ATRPeriod   = 14;
input double                        ATRFactor   = 1.5;

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
    createText("1", string(_Period), 20,20,clrLinen,13,"Arial");

    // chart_id   : ID của chart (0 là chart hiện tại)
    // name       : Tên của đối tượng (BTN_BUY_NAME là hằng ký hiệu nút)
    // sub_window : Chỉ định subwindow (0 là subwindow chính)
    // x1, y1     : Tọa độ góc trên/trái
    // x2, y2     : Tọa độ góc dưới/phải
    
    //BUTTON BUY
    btnBuy.Create(0,BTN_BUY_NAME,0,60,100,260,150);
    btnBuy.Text("BUY");
    btnBuy.Color(clrWhite);
    btnBuy.ColorBackground(C'2, 119, 118');
    btnBuy.ColorBorder(C'4, 82, 81');
    btnBuy.FontSize(11);
    ObjectSetString(0,BTN_BUY_NAME,OBJPROP_TOOLTIP,"Click to buy");

    btnBuyStop.Create(0,BTN_BUY_STOP_NAME,0,60,150,260,190);
    btnBuyStop.Text("BUY STOP");
    btnBuyStop.Color(clrWhite);
    btnBuyStop.ColorBackground(C'2, 119, 118');
    btnBuyStop.ColorBorder(C'4, 82, 81');
    btnBuyStop.FontSize(9);

    btnBuyLimit.Create(0,BTN_BUY_LIMIT_NAME,0,60,190,260,230);
    btnBuyLimit.Text("BUY LIMIT");
    btnBuyLimit.Color(clrWhite);
    btnBuyLimit.ColorBackground(C'2, 119, 118');
    btnBuyLimit.ColorBorder(C'4, 82, 81');
    btnBuyLimit.FontSize(9);

    btnCancelBuy.Create(0,BTN_CANCEL_BUY_NAME,0,60,250,260,280);
    btnCancelBuy.Text("CANCEL BUY ORDER");
    btnCancelBuy.Color(C'2, 119, 118');
    btnCancelBuy.ColorBackground(C'242, 220, 162');
    btnCancelBuy.ColorBorder(C'4, 82, 81');
    btnCancelBuy.FontSize(7);

    btnCloseBuy.Create(0,BTN_CLOSE_BUY_NAME,0,60,280,260,310);
    btnCloseBuy.Text("CLOSE BUY");
    btnCloseBuy.Color(C'2, 119, 118');
    btnCloseBuy.ColorBackground(clrWhite);
    btnCloseBuy.ColorBorder(C'4, 82, 81');
    btnCloseBuy.FontSize(9);


     //BUTTON SELL
    btnSell.Create(0,BTN_SELL_NAME,0,260,100,460,150);
    btnSell.Text("SELL");
    btnSell.Color(clrWhite);
    btnSell.ColorBackground(clrDarkRed);
    btnSell.ColorBorder(C'74, 4, 8');
    btnSell.FontSize(11);
    ObjectSetString(0,BTN_SELL_NAME,OBJPROP_TOOLTIP,"Click to sell");

    btnSellStop.Create(0,BTN_SELL_STOP_NAME,0,260,150,460,190);
    btnSellStop.Text("SELL STOP");
    btnSellStop.Color(clrWhite);
    btnSellStop.ColorBackground(clrDarkRed);
    btnSellStop.ColorBorder(C'74, 4, 8');
    btnSellStop.FontSize(9);

    btnSellLimit.Create(0,BTN_SELL_LIMIT_NAME,0,260,190,460,230);
    btnSellLimit.Text("SELL LIMIT");
    btnSellLimit.Color(clrWhite);
    btnSellLimit.ColorBackground(clrDarkRed);
    btnSellLimit.ColorBorder(C'74, 4, 8');
    btnSellLimit.FontSize(9);

    btnCancelSell.Create(0,BTN_CANCEL_SELL_NAME,0,260,250,460,280);
    btnCancelSell.Text("CANCEL SELL ORDER");
    btnCancelSell.Color(clrDarkRed);
    btnCancelSell.ColorBackground(C'242, 220, 162');
    btnCancelSell.ColorBorder(C'74, 4, 8');
    btnCancelSell.FontSize(7);

    btnCloseSell.Create(0,BTN_CLOSE_SELL_NAME,0,260,280,460,310);
    btnCloseSell.Text("CLOSE SELL");
    btnCloseSell.Color(clrDarkRed);
    btnCloseSell.ColorBackground(clrWhite);
    btnCloseSell.ColorBorder(C'74, 4, 8');
    btnCloseSell.FontSize(9);



    ChartRedraw();

    int MAHandle = MA.Init(_Symbol,PERIOD_CURRENT,MAPeriod,MAShift,MAMethod,MAPrice);
    if(MAHandle == -1){
        return(INIT_FAILED);}

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
    Comment("EA #1111111");
    createText("Text1", "Risk Per Trade: 1%", 40, 40, 8, clrWhite, "Arial");
    createText("Text2", "Account Balance: 5000$", 40, 65, 8, clrWhite, "Arial");
    createText("Text3", "Spread: 00", 40, 90, 8, clrWhite, "Arial");
    createText("Text4", "Open BUY: 0", 40, 115, 8, clrWhite, "Arial");
    createText("Text5", "Open SELL: 0", 40, 140, 8, clrWhite, "Arial");
    //Price
    Bar.Refresh(_Symbol,PERIOD_CURRENT,6);
    double close1 = Bar.Close(1);    
    double close2 = Bar.Close(2);
    double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    double averageHigh = CalculateAverageHigh();
    double stopLossAverageHigh = averageHigh + (slPoints*_Point);

    // Print("Average High of last 5 bars: ", averageHigh);

    double averageLow = CalculateAverageLow();
    double stopLossAverageLow = averageLow - (slPoints*_Point);
    // Print("average Low of last 5 bars: ", averageLow);

    //Moving Average
    MA.RefreshMain();
    double ma1 = MA.main[1];

    //ATR
    ATR.RefreshMain();
    double atr1 = ATR.main[1]; 
    double ATRValue = atr1 * ATRFactor;

    
    if(btnBuy.Pressed())
    {
        if(slPoints > 0)
        {
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLossAverageLow),FixedVolume,ORDER_TYPE_BUY);
            if(volume > 0)
            {
                trade.Buy(volume, _Symbol, 0, stopLossAverageLow, 0);
                Print(__FUNCTION__," > Đã mua ... ");
            }
        } else
        {
            double stopLossATR = PM.CalculateStopLossByATR(_Symbol, "BUY", ATRValue, ATRFactor);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLossATR),FixedVolume,ORDER_TYPE_BUY);
            if(volume > 0)
            {
                trade.Buy(volume, _Symbol, 0, stopLossATR, 0);
                Print(__FUNCTION__," > Đã mua ... ");
            }
        }
        btnBuy.Pressed(false);
    }

    if(btnSell.Pressed())
    {
        if(slPoints > 0)
        {
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(bidPrice - stopLossAverageHigh),FixedVolume,ORDER_TYPE_SELL);
            if(volume > 0)
            {
                trade.Sell(volume, _Symbol, 0, stopLossAverageHigh, 0);
                Print(__FUNCTION__," > Đã bán ... ");
            }
        } else
        {
            double stopLossATR = PM.CalculateStopLossByATR(_Symbol, "SELL", ATRValue, ATRFactor);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLossATR),FixedVolume,ORDER_TYPE_SELL);
            if(volume > 0)
            {
                trade.Sell(volume, _Symbol, 0, stopLossATR, 0);
                Print(__FUNCTION__," > Đã mua ... ");
            }
        }
        btnSell.Pressed(false);
    }

    if(btnCloseBuy.Pressed())
    {
        Print(__FUNCTION__, " > close first buy position btn was pressed...");
        for(int i = 0; i < PositionsTotal(); i++)
        {
            if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
                ulong posTicket = PositionGetTicket(i);
                trade.PositionClose(posTicket);
                break; // Thoát khỏi vòng lặp sau khi đóng lệnh đầu tiên
            }
        }
        btnCloseBuy.Pressed(false);
    }

    if(btnCloseSell.Pressed())
    {
        Print(__FUNCTION__, " > close first sell position btn was pressed...");
        for(int i = 0; i < PositionsTotal(); i++)
        {
            if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
                ulong posTicket = PositionGetTicket(i);
                trade.PositionClose(posTicket);
                break; // Thoát khỏi vòng lặp sau khi đóng lệnh đầu tiên
            }
        }
        btnCloseSell.Pressed(false);
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
      ObjectSetInteger(0,pObjName,OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    //   ObjectSetInteger(0,pObjName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(0,pObjName,OBJPROP_TEXT,pText);
      ObjectSetInteger(0,pObjName,OBJPROP_COLOR,pClrText);
      ObjectSetInteger(0,pObjName,OBJPROP_FONTSIZE,pFontsize);
      // ObjectSetInteger(0,pObjName,OBJPROP_FONT,pFont);


      // ObjectSetInteger(0,pObjName,OBJPROP_XSIZE,100);
      // ObjectSetInteger(0,pObjName,OBJPROP_YSIZE,20);
      return(true);
   }
}

double CalculateAverageHigh()
{
    // Lấy giá cao nhất của 5 cây nến gần nhất
    double high1 = Bar.High(1);
    double high2 = Bar.High(2);
    double high3 = Bar.High(3);
    double high4 = Bar.High(4);
    double high5 = Bar.High(5);
    // Print("High 1: ", high1, " | High 2: ", high2, " | High 3: ", high3, " | High 4: ", high4, " | High 5: ", high5);

    // Tính trung bình giá cao nhất
    double averageHigh = (high1 + high2 + high3 + high4 + high5) / 5.0;

    return averageHigh;
}

double CalculateAverageLow()
{
    // Lấy giá thấp nhất của 5 cây nến gần nhất
    double low1 = Bar.Low(1);
    double low2 = Bar.Low(2);
    double low3 = Bar.Low(3);
    double low4 = Bar.Low(4);
    double low5 = Bar.Low(5);
    // Print("Low 1: ", low1, " | Low 2: ", low2, " | Low 3: ", low3, " | Low 4: ", low4, " | Low 5: ", low5);

    // Tính trung bình giá cao nhất
    double averageLow = (low1 + low2 + low3 + low4 + low5) / 5.0;

    return averageLow;
}


void CloseFirstBuyPosition()
{
    Print(__FUNCTION__, " > close first buy position btn was pressed...");
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            ulong posTicket = PositionGetTicket(i);
            trade.PositionClose(posTicket);
            break; // Thoát khỏi vòng lặp sau khi đóng lệnh đầu tiên
        }
    }
}