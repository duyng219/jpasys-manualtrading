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
#include <Include.duyng/Core/TradeExecutor.mqh>



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
CTradeExecutor Trade;
CBar Bar;
CiATR ATR;
CiMA MA;

//+----------------------------------------------------------+
//| Input & Global Variables | Biến đầu vào và biến toàn cục |
//+----------------------------------------------------------+
sinput group                        "INPUT"
input int                           slPoints                = 150; // Điểm dừng lỗ 5Bar+Points (nếu = 0, sử dụng ATR)
input ulong                         MagicNumber             = 1010; // Số Magic (Magic Number)
input ushort                        POExpirationMinutes     = 60; // Time hết hạn cho lệnh chờ (Pending Order Expiration Minutes)
input double                        MaxDrawdownDaily        = -5; // Max Drawdown trong ngày (%)

sinput group                        "RISK MANAGEMENT"
sinput string                       strMM; 
input ENUM_MONEY_MANAGEMENT         MoneyManagement         = MM_EQUITY_RISK_PERCENT; // Quản lý rủi ro (Options)
input double                        MinLotPerEquitySteps    = 500; // Bước lô tối thiểu theo vốn (Min Lot Per Equity Steps)
input double                        FixedVolume             = 0.01; // Khối lượng cố định (Fixed Volume)
input double                        RiskPercent             = 1; // Phần trăm rủi ro (1 = 1% Balance)

sinput group                        "MOVING AVERAGE SETTINGS"
input int                           MAPeriod                = 21; // Chu kỳ MA (Period)
input ENUM_MA_METHOD                MAMethod                = MODE_EMA; // Phương pháp MA (Method)
input int                           MAShift                 = 0; // Dịch chuyển MA (Shift)
input ENUM_APPLIED_PRICE            MAPrice                 = PRICE_CLOSE; // Giá áp dụng MA (Price)

sinput group                        "ATR SETTINGS"
input int                           ATRPeriod               = 14; // Chu kỳ ATR (Period)
input double                        ATRFactor               = 1.5; // Hệ số ATR (Factor)
input double                        ATRFactorPO             = 1.2; // Hệ số ATR cho lệnh chờ (Factor Pending Order)

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

// Biến toàn cục để theo dõi Equity cao nhất & thấp nhất trong ngày
double maxEquityToday = 0.0;
double minEquityToday = 0.0;
datetime lastResetTime = 0; // Thời điểm reset khi qua ngày

// Lấy kích thước biểu đồ
int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
// Top menu buttons
double btn_height = chart_height * 0.05;  // 5% chiều cao biểu đồ
double btn_width = chart_width * 0.15;   // 25% chiều rộng biểu đồ



int OnInit()
{  
    //SET VARIABLES
    Trade.SetMagicNumber(MagicNumber);

    createText("1", string(_Period), 20,20,clrLinen,13,"Arial");

    // chart_id   : ID của chart (0 là chart hiện tại)
    // name       : Tên của đối tượng (BTN_BUY_NAME là hằng ký hiệu nút)
    // sub_window : Chỉ định subwindow (0 là subwindow chính)
    // x1, y1     : Tọa độ góc trên/trái
    // x2, y2     : Tọa độ góc dưới/phải
    
    //BUTTON BUY
    btnBuy.Create(0, BTN_BUY_NAME, 0, int(chart_width * 0.02), int(chart_height * 0.10), int(chart_width * 0.15), int(chart_height * 0.15));
    btnBuy.Text("BUY");
    btnBuy.Color(clrWhite);
    btnBuy.ColorBackground(C'2, 119, 118');
    btnBuy.ColorBorder(C'4, 82, 81');
    btnBuy.FontSize(11);

    btnBuyStop.Create(0, BTN_BUY_STOP_NAME, 0, int(chart_width * 0.02), int(chart_height * 0.15), int(chart_width * 0.15), int(chart_height * 0.20));
    btnBuyStop.Text("BUY STOP");
    btnBuyStop.Color(clrWhite);
    btnBuyStop.ColorBackground(C'2, 119, 118');
    btnBuyStop.ColorBorder(C'4, 82, 81');
    btnBuyStop.FontSize(9);

    btnBuyLimit.Create(0, BTN_BUY_LIMIT_NAME, 0, int(chart_width * 0.02), int(chart_height * 0.20), int(chart_width * 0.15), int(chart_height * 0.25));
    btnBuyLimit.Text("BUY LIMIT");
    btnBuyLimit.Color(clrWhite);
    btnBuyLimit.ColorBackground(C'2, 119, 118');
    btnBuyLimit.ColorBorder(C'4, 82, 81');
    btnBuyLimit.FontSize(9);

    btnCancelBuy.Create(0, BTN_CANCEL_BUY_NAME, 0, int(chart_width * 0.02), int(chart_height * 0.25), int(chart_width * 0.15), int(chart_height * 0.30));
    btnCancelBuy.Text("CANCEL BUY ORDER");
    btnCancelBuy.Color(C'2, 119, 118');
    btnCancelBuy.ColorBackground(C'242, 220, 162');
    btnCancelBuy.ColorBorder(C'4, 82, 81');
    btnCancelBuy.FontSize(7);
    ObjectSetString(0, BTN_CANCEL_BUY_NAME, OBJPROP_TOOLTIP, "Cancel Pending Order");

    btnCloseBuy.Create(0, BTN_CLOSE_BUY_NAME, 0, int(chart_width * 0.02), int(chart_height * 0.30), int(chart_width * 0.15), int(chart_height * 0.35));
    btnCloseBuy.Text("CLOSE BUY");
    btnCloseBuy.Color(C'2, 119, 118');
    btnCloseBuy.ColorBackground(clrWhite);
    btnCloseBuy.ColorBorder(C'4, 82, 81');
    btnCloseBuy.FontSize(9);
    ObjectSetString(0, BTN_CLOSE_BUY_NAME, OBJPROP_TOOLTIP, "Close Buy First");

    //BUTTON SELL
    btnSell.Create(0, BTN_SELL_NAME, 0, int(chart_width * 0.15), int(chart_height * 0.10), int(chart_width * 0.30), int(chart_height * 0.15));
    btnSell.Text("SELL");
    btnSell.Color(clrWhite);
    btnSell.ColorBackground(clrDarkRed);
    btnSell.ColorBorder(C'74, 4, 8');
    btnSell.FontSize(11);

    btnSellStop.Create(0, BTN_SELL_STOP_NAME, 0, int(chart_width * 0.15), int(chart_height * 0.15), int(chart_width * 0.30), int(chart_height * 0.20));
    btnSellStop.Text("SELL STOP");
    btnSellStop.Color(clrWhite);
    btnSellStop.ColorBackground(clrDarkRed);
    btnSellStop.ColorBorder(C'74, 4, 8');
    btnSellStop.FontSize(9);

    btnSellLimit.Create(0, BTN_SELL_LIMIT_NAME, 0, int(chart_width * 0.15), int(chart_height * 0.20), int(chart_width * 0.30), int(chart_height * 0.25));
    btnSellLimit.Text("SELL LIMIT");
    btnSellLimit.Color(clrWhite);
    btnSellLimit.ColorBackground(clrDarkRed);
    btnSellLimit.ColorBorder(C'74, 4, 8');
    btnSellLimit.FontSize(9);

    btnCancelSell.Create(0, BTN_CANCEL_SELL_NAME, 0, int(chart_width * 0.15), int(chart_height * 0.25), int(chart_width * 0.30), int(chart_height * 0.30));
    btnCancelSell.Text("CANCEL SELL ORDER");
    btnCancelSell.Color(clrDarkRed);
    btnCancelSell.ColorBackground(C'242, 220, 162');
    btnCancelSell.ColorBorder(C'74, 4, 8');
    btnCancelSell.FontSize(7);
    ObjectSetString(0, BTN_CANCEL_SELL_NAME, OBJPROP_TOOLTIP, "Cancel Pending Order");

    btnCloseSell.Create(0, BTN_CLOSE_SELL_NAME, 0, int(chart_width * 0.15), int(chart_height * 0.30), int(chart_width * 0.30), int(chart_height * 0.35));
    btnCloseSell.Text("CLOSE SELL");
    btnCloseSell.Color(clrDarkRed);
    btnCloseSell.ColorBackground(clrWhite);
    btnCloseSell.ColorBorder(C'74, 4, 8');
    btnCloseSell.FontSize(9);
    ObjectSetString(0, BTN_CLOSE_SELL_NAME, OBJPROP_TOOLTIP, "Close Sell First");

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
    btnBuyStop.Destroy(reason);
    btnBuyLimit.Destroy(reason);
    btnCancelBuy.Destroy(reason);
    btnCloseBuy.Destroy(reason);
    btnSell.Destroy(reason);
    btnSellStop.Destroy(reason);
    btnSellLimit.Destroy(reason);
    btnCancelSell.Destroy(reason);
    btnCloseSell.Destroy(reason);

    // Xóa các đối tượng đồ họa
    ObjectDelete(0, "Text1");
    ObjectDelete(0, "Text2");
    ObjectDelete(0, "Text3");
    ObjectDelete(0, "Text4");
    ObjectDelete(0, "Text5");

    // Xóa đoạn text Comment
    Comment("");
}

void OnTick()
{ 
    //Init Indicators
    //Moving Average
    MA.RefreshMain();
    double ma1 = MA.main[1];

    //ATR
    ATR.RefreshMain();
    double atr0 = ATR.main[0];
    double atr1 = ATR.main[1]; 
    double ATRValue = atr1 * ATRFactor;
    double ATRValuePO = atr0 * ATRFactorPO;

    //Price
    Bar.Refresh(_Symbol,PERIOD_CURRENT,6);
    double close1 = Bar.Close(1);    
    double close2 = Bar.Close(2);
    double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    // Cập nhật giá trị Drawdown
    UpdateMaxDrawdown(); 
    double currentMDD = GetCurrentDrawdown(); // Lấy giá trị Drawdown hiện tại
    // Nếu Drawdown trong ngày vượt quá -5%, không cho mở lệnh
    if (currentMDD <= MaxDrawdownDaily) 
    {
        string message = "Max Drawdown to " + DoubleToString(currentMDD, 2) + "%, Stop trading on EA!";
        // SendTelegramMessage(message); // Gửi thông báo Telegram
        Comment(message);
        return; 
    }
    // Nếu chưa đạt Max Drawdown, tiếp tục giao dịch....

    //Stoploss trung bình giá cao nhất của 5 cây nến gần nhất
    double averageHigh = CalculateAverageHigh();
    double stopLossAverageHigh = averageHigh + (slPoints*_Point);


    //Stoploss trung bình giá thấp nhất của 5 cây nến gần nhất
    double averageLow = CalculateAverageLow();
    double stopLossAverageLow = averageLow - (slPoints*_Point);

    //Lấy thông tin tài khoản
    Comment("EA Manual Trading; Magic Number: ", MagicNumber);


    string strRiskPercent       = "Risk: " + DoubleToString(RiskPercent, 2) + "%";
    string strAccountBalance    = "Account Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "$";
    string strBalanceAndRisk    = "Account Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "$ | Risk: " + DoubleToString(RiskPercent, 2) + "%";
    string strSpread            = "Spread: " + IntegerToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 2);
    string strMaxDrawdown       = "Max Drawdown: " + DoubleToString(currentMDD, 2) + "%";
    string strOpenBuy           = "Open Buy: " + IntegerToString(CountOpenBuy());
    string strOpenSell          = "Open Sell: " + IntegerToString(CountOpenSell());
    
    //Tạo các label hiển thị thông tin góc phải trên
    createText("Text1", strBalanceAndRisk, 40, 40, 8, clrWhite, "Arial");
    createText("Text2", strMaxDrawdown, 40, 65, 8, clrWhite, "Arial");
    createText("Text3", strSpread, 40, 90, 8, clrWhite, "Arial");
    createText("Text4", strOpenBuy, 40, 115, 8, clrWhite, "Arial");
    createText("Text5", strOpenSell, 40, 140, 8, clrWhite, "Arial");

    
    //Set tooltip cho các button
    string strBuy = "Buy giá: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK),5);
    ObjectSetString(0,BTN_BUY_NAME,OBJPROP_TOOLTIP,strBuy);
    ObjectSetString(0,BTN_BUY_STOP_NAME,OBJPROP_TOOLTIP,"Buy Stop");
    ObjectSetString(0,BTN_BUY_LIMIT_NAME,OBJPROP_TOOLTIP,"Buy Limit");

    string strSell = "Sell giá: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID),5);
    ObjectSetString(0,BTN_SELL_NAME,OBJPROP_TOOLTIP,strSell);
    ObjectSetString(0,BTN_SELL_STOP_NAME,OBJPROP_TOOLTIP,"Sell Stop");
    ObjectSetString(0,BTN_SELL_LIMIT_NAME,OBJPROP_TOOLTIP,"Sell Limit");
    
    if(btnBuy.Pressed())
    {
        if(slPoints > 0)
        {
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLossAverageLow),FixedVolume,ORDER_TYPE_BUY);
            if(volume > 0)
            {
                Trade.Buy(_Symbol, volume, stopLossAverageLow, 0);
            }
        } else
        {
            double stopLossATR = PM.CalculateStopLossByATR(_Symbol, "BUY", ATRValue, ATRFactor);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLossATR),FixedVolume,ORDER_TYPE_BUY);
            if(volume > 0)
            {
                Trade.Buy(_Symbol,volume, stopLossATR, 0);
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
                Trade.Sell(_Symbol, volume, stopLossAverageHigh, 0);
            }
        } else
        {
            double stopLossATR = PM.CalculateStopLossByATR(_Symbol, "SELL", ATRValue, ATRFactor);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(bidPrice - stopLossATR),FixedVolume,ORDER_TYPE_SELL);
            if(volume > 0)
            {
                Trade.Sell(_Symbol, volume, stopLossATR, 0);
            }
        }
        btnSell.Pressed(false);
    }

    if(btnBuyStop.Pressed())
    {
        // double entryPrice = Ask + atr * 1.2;  // Đặt Buy Stop cách giá Ask hiện tại một khoảng 1.2 lần ATR
        // double entryPrice = Bid - atr * 1.2;  // Đặt Sell Stop cách giá Bid hiện tại một khoảng 1.2 lần ATR
        double POPrice          =  askPrice + atr0 * ATRFactorPO;
        double stopLossATR      = PM.CalculateStopLossByATR(_Symbol, "BUY", ATRValuePO, ATRFactorPO);
        double volume           = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(POPrice - stopLossATR),FixedVolume,ORDER_TYPE_BUY);
        datetime expiration     = Trade.GetExpirationTime(POExpirationMinutes);

        if(volume > 0)
        {
            Trade.BuyStop(_Symbol, volume, POPrice, stopLossATR,0, expiration);
        }
        btnBuyStop.Pressed(false);
    }

    if(btnSellStop.Pressed())
    {
        double POPrice          =  bidPrice - atr0 * ATRFactorPO;
        double stopLossATR      = PM.CalculateStopLossByATR(_Symbol, "SELL", ATRValuePO, ATRFactorPO);
        double volume           = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(POPrice - stopLossATR),FixedVolume,ORDER_TYPE_SELL);
        datetime expiration     = Trade.GetExpirationTime(POExpirationMinutes);

        if(volume > 0)
        {
            Trade.SellStop(_Symbol, volume, POPrice, stopLossATR,0, expiration);
        }
        btnSellStop.Pressed(false);
    }

    if(btnBuyLimit.Pressed())
    {
        double POPrice          =  askPrice - atr0 * ATRFactorPO;
        double stopLossATR      = PM.CalculateStopLossByATR(_Symbol, "BUY", ATRValuePO, ATRFactorPO);
        stopLossATR -= 100 * _Point;
        double volume           = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(POPrice - stopLossATR),FixedVolume,ORDER_TYPE_BUY);
        datetime expiration     = Trade.GetExpirationTime(POExpirationMinutes);

        if(volume > 0)
        {
            Trade.BuyLimit(_Symbol, volume, POPrice, stopLossATR, 0, expiration);
        }
        btnBuyLimit.Pressed(false);
    }

    if(btnSellLimit.Pressed())
    {
        double POPrice          =  bidPrice + atr0 * ATRFactorPO;
        double stopLossATR      = PM.CalculateStopLossByATR(_Symbol, "SELL", ATRValuePO, ATRFactorPO);
        stopLossATR += 100 * _Point;
        double volume           = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(POPrice - stopLossATR),FixedVolume,ORDER_TYPE_SELL);
        datetime expiration     = Trade.GetExpirationTime(POExpirationMinutes);

        if(volume > 0)
        {
            Trade.SellLimit(_Symbol, volume, POPrice, stopLossATR, 0, expiration);
        }
        btnSellLimit.Pressed(false);
    }

    if(btnCancelBuy.Pressed())
    {
        ulong ticket = Trade.GetPendingTicket(_Symbol,MagicNumber);
        if(ticket > 0) Trade.Delete(ticket);

        btnCancelBuy.Pressed(false);
    }

    if(btnCancelSell.Pressed())
    {
        ulong ticket = Trade.GetPendingTicket(_Symbol,MagicNumber);
        if(ticket > 0) Trade.Delete(ticket);

        btnCancelSell.Pressed(false);
    }

    if(btnCloseBuy.Pressed())
    {
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
    PM.TrailingStopLossByATR(_Symbol,MagicNumber ,ATRValue, ATRFactor);
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
      // ObjectSetInteger(0,pObjName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
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

int CountOpenBuy()
{
    int count = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
            count++;
        }
    }
    return count;
}

int CountOpenSell()
{
    int count = 0;
    for(int i = 0; i < PositionsTotal(); i++)
    {
        if(PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
            count++;
        }
    }
    return count;
}

// Hàm cập nhật giá trị Max Drawdown
void UpdateMaxDrawdown()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    datetime now = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(now, timeStruct);

    // Nếu là ngày mới, reset giá trị maxEquity và minEquity
    if (lastResetTime == 0 || (timeStruct.hour == 0 && timeStruct.min == 0)) 
    {
        maxEquityToday = currentEquity;
        minEquityToday = currentEquity;
        lastResetTime = now;
    }

    // Cập nhật max và min equity trong ngày
    if (currentEquity > maxEquityToday)
        maxEquityToday = currentEquity;
    if (currentEquity < minEquityToday)
        minEquityToday = currentEquity;
}

// Hàm trả về giá trị Max Drawdown hiện tại (%)
double GetCurrentDrawdown()
{
    if (maxEquityToday == 0) return 0.0; // Tránh chia cho 0

    double drawdownPercent = ((minEquityToday - maxEquityToday) / maxEquityToday) * 100.0;
    return drawdownPercent; // Trả về giá trị MDD hiện tại (%)
}

// Hàm gửi tin nhắn Telegram
// void SendTelegramMessage(string message) 
// {
//     string botToken = "7826196467:AAGmlJcO4_EREt9NU30bWM4W1lQlDWoUOZM";   // 🔹 Thay bằng token từ BotFather
//     string chatID   = "1349135415";     // 🔹 Thay bằng Chat ID của bạn

//     string url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
//     string data = "chat_id=" + chatID + "&text=" + message;
    
//     char requestData[];
//     StringToCharArray(data, requestData); // ✅ Chuyển `string` thành `char[]` đúng chuẩn
    
//     char result[];
//     string result_headers;
//     ResetLastError();
    
//     // 🛠 Headers cần thiết cho HTTP POST request
//     string headers = "Content-Type: application/x-www-form-urlencoded\r\n";

//     int res = WebRequest("POST", url, headers, 5000, requestData, result, result_headers);

//     if(res == -1)
//     {
//         Print("❌ Telegram gửi lỗi: ", GetLastError());
//     }
//     else
//     {
//         Print("..Tin nhắn Telegram đã gửi thành công!");
//     }
// }