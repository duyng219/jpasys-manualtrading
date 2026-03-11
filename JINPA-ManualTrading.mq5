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

#include <IncludeCore/Indicator/Indicators.mqh>
#include <IncludeCore/Core/BarManager.mqh>
#include <IncludeCore/Core/PositionManager.mqh>
#include <IncludeCore/Core/RiskManager.mqh>
#include <IncludeCore/Core/TradeExecutor.mqh>

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
sinput group                                   "INPUT"
input int                                          slPoints                           = 0; // Điểm dừng lỗ 5Bar+Points (nếu = 0, sử dụng ATR)
input ulong                                     MagicNumber                = 0001; // Số Magic (Magic Number)
input ushort                                    POExpirationMinutes     = 360; // Time hết hạn cho lệnh chờ (Pending Order Expiration Minutes)
input double                                   MaxDrawdownDaily       = 0; // Max Drawdown trong ngày (nếu = 0 tắt chức năng, -5 = 5%)

sinput group                                "RISK MANAGEMENT"
sinput string                                strMM; 
input ENUM_MONEY_MANAGEMENT         MoneyManagement         = MM_EQUITY_RISK_PERCENT; // Quản lý rủi ro (Options)
input double                                MinLotPerEquitySteps    = 500; // Bước lô tối thiểu theo vốn (Min Lot Per Equity Steps)
input double                                FixedVolume             = 0.01; // Khối lượng cố định (Fixed Volume)
input double                                RiskPercent             = 0.2; // Phần trăm rủi ro (1 = 1% Balance)

sinput group                                "MOVING AVERAGE SETTINGS"
input int                                       MAPeriod                = 21; // Chu kỳ MA (Period)
input ENUM_MA_METHOD         MAMethod                = MODE_EMA; // Phương pháp MA (Method)
input int                                       MAShift                 = 0; // Dịch chuyển MA (Shift)
input ENUM_APPLIED_PRICE       MAPrice                 = PRICE_CLOSE; // Giá áp dụng MA (Price)

sinput group                                "ATR SETTINGS"
input int                                       ATRPeriod               = 14; // Chu kỳ ATR (Period)
input double                                ATRFactor               = 1; // Hệ số ATR (Factor)
input double                                ATRFactorPO             = 1; // Hệ số ATR cho lệnh chờ (Factor Pending Order)

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

// Biến toàn cục để theo dõi Equity cao nhất & thấp nhất trong ngày & tháng
double      maxEquityToday = 0.0;
double      minEquityToday = 0.0;
datetime    lastResetDaily = 0; // Thời điểm reset khi qua ngày

double      maxEquityMonth = 0.0;
double      minEquityMonth = 0.0;
int         lastResetMonth = 0;

// Lấy kích thước biểu đồ
int         chart_width     = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
int         chart_height    = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

// Các hằng số cho vị trí và kích thước nút (tính theo phần trăm biểu đồ)
double                        BtnHeightPercent        = 0.035; // Chiều cao nút (% chiều cao biểu đồ)
double                        BtnWidthBuyPercent      = 0.08; // Chiều rộng nút Buy (% chiều rộng biểu đồ)
double                        BtnWidthSellPercent     = 0.08; // Chiều rộng nút Sell (% chiều rộng biểu đồ)
double                        BtnBuyStartPercent      = 0.03; // Vị trí X nút Buy (% chiều rộng biểu đồ)
double                        BtnSellStartPercent     = 0.10; // Vị trí X nút Sell (% chiều rộng biểu đồ)
double                        BtnStartYPercent        = 0.10; // Vị trí Y nút (% chiều cao biểu đồ)

// Màu nút BUY
color       BtnBuyTextColor         = clrWhite;
color       BtnBuyBackColor         = C'33,72,72'; // Màu nền nút Buy
color       BtnBuyBorderColor       = clrBlack; // Màu viền nút Buy
color       BtnBuyCancelBackColor   = C'242, 220, 162'; // Màu nền nút Cancel Buy

// Màu nút SELL
color       BtnSellTextColor        = clrWhite; // Màu chữ nút SellZ
color       BtnSellBackColor        = C'112,43,43'; // Màu nền nút Sell
color       BtnSellBorderColor      = clrBlack; // Màu viền nút Sell
color       BtnSellCancelBackColor  = C'242, 220, 162'; // Màu nền nút Cancel Sell

// Hàm tạo tất cả các button
void CreateAllButtons()
{
    // Tính toán kích thước và vị trí từ input
    double btn_height_px = chart_height * BtnHeightPercent;
    double btn_width_buy_px = chart_width * BtnWidthBuyPercent;
    double btn_width_sell_px = chart_width * BtnWidthSellPercent;
    double btn_buy_x_start = chart_width * BtnBuyStartPercent;
    double btn_sell_x_start = chart_width * BtnSellStartPercent;
    double btn_y_start = chart_height * BtnStartYPercent;
    
    // chart_id   : ID của chart (0 là chart hiện tại)
    // name       : Tên của đối tượng (BTN_BUY_NAME là hằng ký hiệu nút)
    // sub_window : Chỉ định subwindow (0 là subwindow chính)
    // x1, y1     : Tọa độ góc trên/trái
    // x2, y2     : Tọa độ góc dưới/phải
    
    //BUTTON BUY
    btnBuy.Create(0, BTN_BUY_NAME, 0, int(btn_buy_x_start), int(btn_y_start), int(btn_buy_x_start + btn_width_buy_px), int(btn_y_start + btn_height_px));
    btnBuy.Text("Buy");
    btnBuy.Color(BtnBuyTextColor);
    btnBuy.ColorBackground(BtnBuyBackColor);
    btnBuy.ColorBorder(BtnBuyBorderColor);
    btnBuy.FontSize(11);

    double btn_y_offset = btn_height_px;
    btnBuyStop.Create(0, BTN_BUY_STOP_NAME, 0, int(btn_buy_x_start), int(btn_y_start + btn_y_offset), int(btn_buy_x_start + btn_width_buy_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnBuyStop.Text("Buy Stop");
    btnBuyStop.Color(BtnBuyTextColor);
    btnBuyStop.ColorBackground(BtnBuyBackColor);
    btnBuyStop.ColorBorder(BtnBuyBorderColor);
    btnBuyStop.FontSize(9);

    btn_y_offset *= 2;
    btnBuyLimit.Create(0, BTN_BUY_LIMIT_NAME, 0, int(btn_buy_x_start), int(btn_y_start + btn_y_offset), int(btn_buy_x_start + btn_width_buy_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnBuyLimit.Text("Buy Limit");
    btnBuyLimit.Color(BtnBuyTextColor);
    btnBuyLimit.ColorBackground(BtnBuyBackColor);
    btnBuyLimit.ColorBorder(BtnBuyBorderColor);
    btnBuyLimit.FontSize(9);

    btn_y_offset = btn_height_px * 2.85;
    btnCancelBuy.Create(0, BTN_CANCEL_BUY_NAME, 0, int(btn_buy_x_start), int(btn_y_start + btn_y_offset), int(btn_buy_x_start + btn_width_buy_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnCancelBuy.Text("Cancel Buy Order");
    btnCancelBuy.Color(BtnBuyBorderColor);
    btnCancelBuy.ColorBackground(BtnBuyCancelBackColor);
    btnCancelBuy.ColorBorder(BtnBuyBorderColor);
    btnCancelBuy.FontSize(7);
    ObjectSetString(0, BTN_CANCEL_BUY_NAME, OBJPROP_TOOLTIP, "Cancel Pending Order");

    btn_y_offset = btn_height_px * 3.75;
    btnCloseBuy.Create(0, BTN_CLOSE_BUY_NAME, 0, int(btn_buy_x_start), int(btn_y_start + btn_y_offset), int(btn_buy_x_start + btn_width_buy_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnCloseBuy.Text("Close Buy");
    btnCloseBuy.Color(BtnBuyBorderColor);
    btnCloseBuy.ColorBackground(clrWhite);
    btnCloseBuy.ColorBorder(BtnBuyBorderColor);
    btnCloseBuy.FontSize(9);
    ObjectSetString(0, BTN_CLOSE_BUY_NAME, OBJPROP_TOOLTIP, "Close Buy First");

    //BUTTON SELL
    btnSell.Create(0, BTN_SELL_NAME, 0, int(btn_sell_x_start), int(btn_y_start), int(btn_sell_x_start + btn_width_sell_px), int(btn_y_start + btn_height_px));
    btnSell.Text("Sell");
    btnSell.Color(BtnSellTextColor);
    btnSell.ColorBackground(BtnSellBackColor);
    btnSell.ColorBorder(BtnSellBorderColor);
    btnSell.FontSize(11);

    btn_y_offset = btn_height_px;
    btnSellStop.Create(0, BTN_SELL_STOP_NAME, 0, int(btn_sell_x_start), int(btn_y_start + btn_y_offset), int(btn_sell_x_start + btn_width_sell_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnSellStop.Text("Sell Stop");
    btnSellStop.Color(BtnSellTextColor);
    btnSellStop.ColorBackground(BtnSellBackColor);
    btnSellStop.ColorBorder(BtnSellBorderColor);
    btnSellStop.FontSize(9);

    btn_y_offset *= 2;
    btnSellLimit.Create(0, BTN_SELL_LIMIT_NAME, 0, int(btn_sell_x_start), int(btn_y_start + btn_y_offset), int(btn_sell_x_start + btn_width_sell_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnSellLimit.Text("Sell Limit");
    btnSellLimit.Color(BtnSellTextColor);
    btnSellLimit.ColorBackground(BtnSellBackColor);
    btnSellLimit.ColorBorder(BtnSellBorderColor);
    btnSellLimit.FontSize(9);

    btn_y_offset = btn_height_px * 2.85;
    btnCancelSell.Create(0, BTN_CANCEL_SELL_NAME, 0, int(btn_sell_x_start), int(btn_y_start + btn_y_offset), int(btn_sell_x_start + btn_width_sell_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnCancelSell.Text("Cancel Sell Order");
    btnCancelSell.Color(BtnSellBorderColor);
    btnCancelSell.ColorBackground(BtnSellCancelBackColor);
    btnCancelSell.ColorBorder(BtnSellBorderColor);
    btnCancelSell.FontSize(7);
    ObjectSetString(0, BTN_CANCEL_SELL_NAME, OBJPROP_TOOLTIP, "Cancel Pending Order");

    btn_y_offset = btn_height_px * 3.75;
    btnCloseSell.Create(0, BTN_CLOSE_SELL_NAME, 0, int(btn_sell_x_start), int(btn_y_start + btn_y_offset), int(btn_sell_x_start + btn_width_sell_px), int(btn_y_start + btn_y_offset + btn_height_px));
    btnCloseSell.Text("Close Sell");
    btnCloseSell.Color(BtnSellBorderColor);
    btnCloseSell.ColorBackground(clrWhite);
    btnCloseSell.ColorBorder(BtnSellBorderColor);
    btnCloseSell.FontSize(9);
    ObjectSetString(0, BTN_CLOSE_SELL_NAME, OBJPROP_TOOLTIP, "Close Sell First");

    ChartRedraw();
}

int OnInit()
{  
    //SET VARIABLES
    Trade.SetMagicNumber(MagicNumber);

    // Kiểm tra trading allowed
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
    {
        Alert("❌ Trading bị tắt trong Terminal!");
        return(INIT_FAILED);
    }
    
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
    {
        Alert("❌ EA không được phép giao dịch! Bật AutoTrading!");
        return(INIT_FAILED);
    }
    
    // Kiểm tra symbol
    if(!SymbolSelect(_Symbol, true))
    {
        Alert("❌ Không thể chọn symbol: ", _Symbol);
        return(INIT_FAILED);
    }

    //     // Cấu hình Trade object
    // trade.SetExpertMagicNumber(MagicNumber);
    // trade.SetDeviationInPoints(50);
    // trade.SetTypeFilling(ORDER_FILLING_IOC); // QUAN TRỌNG cho crypto
    // trade.SetAsyncMode(false);
    
    // In thông tin symbol
    Print("Min Volume: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
          " | Max Volume: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
          " | Volume Step: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));

    createText("1", string(_Period), 20,20,clrLinen,13,"Arial");

    // Tạo tất cả các button
    CreateAllButtons();

    // Delay để đảm bảo symbol được load xong
    Sleep(100);

    int MAHandle = MA.Init(_Symbol,_Period,MAPeriod,MAShift,MAMethod,MAPrice);
    if(MAHandle == -1){
        Alert("MA indicator failed");
        return(INIT_FAILED);}

    int ATRHandle = ATR.Init(_Symbol,_Period,ATRPeriod);   
    if(ATRHandle == -1){
        Alert("ATR indicator failed");
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
    ObjectDelete(0, "Text6");

    // Xóa đoạn text Comment
    Comment("");
}


void OnTick()
{ 
    // ✅ Kiểm tra và tạo lại buttons nếu bị mất (đặt ở đầu OnTick)
    static int tickCount = 0;
    tickCount++;
    if(tickCount % 100 == 0) // Kiểm tra mỗi 100 tick
    {
        if(ObjectFind(0, BTN_BUY_NAME) < 0)
        {
            Print("Buttons bị mất. Tạo lại...");
            CreateAllButtons();
        }
    }
    
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

    // Cập nhật giá trị Max Drawdown
    UpdateMaxDrawdownDaily();   // Cập nhật Drawdown trong ngày
    UpdateMaxDrawdownMonthly(); // Cập nhật Drawdown trong tháng

    // Lấy giá trị Drawdown hiện tại
    double dailyDD   = GetCurrentDrawdownDaily();
    double monthlyDD = GetCurrentDrawdownMonthly();

    // Nếu Drawdown trong ngày vượt quá -5%, không cho mở lệnh mới
    if (MaxDrawdownDaily > 0)
    {
        if(dailyDD >= MaxDrawdownDaily)
        {
            string message = "Max Drawdown to " + DoubleToString(dailyDD, 2) + "%, Stop trading on EA!";
            // SendTelegramMessage(message); // Gửi thông báo Telegram
            Comment(message);
            return; 
        }
    } // Nếu chưa đạt Max Drawdown, tiếp tục giao dịch....

    //Stoploss trung bình giá cao nhất của 5 cây nến gần nhất
    double averageHigh          = CalculateAverageHigh();
    double stopLossAverageHigh  = averageHigh + (slPoints*_Point);

    //Stoploss trung bình giá thấp nhất của 5 cây nến gần nhất
    double averageLow           = CalculateAverageLow();
    double stopLossAverageLow   = averageLow - (slPoints*_Point);

    //Lấy thông tin tài khoản
    Comment("EA Manual Trading; Magic Number: ", MagicNumber);

    string strRiskPercent       = "Risk: " + DoubleToString(RiskPercent, 2) + "%";
    string strAccountBalance    = "Account Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "$";
    string strBalanceAndRisk    = "Account Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "$ | Risk: " + DoubleToString(RiskPercent, 2) + "%";
    string strSpread            = "Spread: " + IntegerToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 2) + " points";
    string strMaxDDDaily        = "Max Drawdown Daily: " + DoubleToString(dailyDD, 2) + "%";
    string strMaxDDMonthly      = "Max Drawdown Monthly: " + DoubleToString(monthlyDD, 2) + "%";
    string strOpenBuy           = "Open Buy: " + IntegerToString(CountOpenBuy());
    string strOpenSell          = "Open Sell: " + IntegerToString(CountOpenSell());

    // Tạo các label hiển thị thông tin góc phải trên
    createText("Text1", strBalanceAndRisk,      int(chart_width * 0.01), int(chart_height * 0.05), 8, C'193,191,184', "Arial");
    createText("Text2", strMaxDDDaily,          int(chart_width * 0.01), int(chart_height * 0.08), 8, C'193,191,184', "Arial");
    createText("Text3", strMaxDDMonthly,        int(chart_width * 0.01), int(chart_height * 0.11), 8, C'193,191,184', "Arial");
    createText("Text4", strSpread,              int(chart_width * 0.01), int(chart_height * 0.14), 8, C'193,191,184', "Arial");
    createText("Text5", strOpenBuy,             int(chart_width * 0.01), int(chart_height * 0.17), 8, C'193,191,184', "Arial");
    createText("Text6", strOpenSell,            int(chart_width * 0.01), int(chart_height * 0.20), 8, C'193,191,184', "Arial");
    
    //Set tooltip cho các button
    string strBuy = "Buy giá: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK),5);
    ObjectSetString(0,BTN_BUY_NAME,OBJPROP_TOOLTIP,strBuy);
    ObjectSetString(0,BTN_BUY_STOP_NAME,OBJPROP_TOOLTIP,"Buy Stop");
    ObjectSetString(0,BTN_BUY_LIMIT_NAME,OBJPROP_TOOLTIP,"Buy Limit");

    string strSell = "Sell giá: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID),5);
    ObjectSetString(0,BTN_SELL_NAME,OBJPROP_TOOLTIP,strSell);
    ObjectSetString(0,BTN_SELL_STOP_NAME,OBJPROP_TOOLTIP,"Sell Stop");
    ObjectSetString(0,BTN_SELL_LIMIT_NAME,OBJPROP_TOOLTIP,"Sell Limit");
    

    // double stopLossATR      = PM.CalculateStopLossByATR(_Symbol, "BUY", ATRValuePO, ATRFactorPO);


    if(btnBuy.Pressed())
    {
        if(slPoints > 0)
        {
            double stopLoss = MathMax(stopLossAverageLow, askPrice - stopLossAverageLow);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLoss),FixedVolume,ORDER_TYPE_BUY);
            if(volume > 0)
            {
                trade.Buy(volume, _Symbol, askPrice, stopLoss, 0);
            }
        } else
        {
            double stopLossATR = PM.CalculateStopLossByATR(_Symbol, "BUY", ATRValue, ATRFactor);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(askPrice - stopLossATR),FixedVolume,ORDER_TYPE_BUY);
            if(volume > 0)
            {
                trade.Buy(volume, _Symbol, askPrice, stopLossATR, 0);
            }
        }
        
        btnBuy.Pressed(false);
    }

    if(btnSell.Pressed())
    {
        if(slPoints > 0)
        {
            double stopLoss = MathMin(stopLossAverageHigh, bidPrice + stopLossAverageHigh);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(bidPrice - stopLoss),FixedVolume,ORDER_TYPE_SELL);
            if(volume > 0)
            {
                trade.Sell(volume, _Symbol, bidPrice, stopLoss, 0);
            }
        } else
        {
            double stopLossATR = PM.CalculateStopLossByATR(_Symbol, "SELL", ATRValue, ATRFactor);
            double volume = RM.MoneyManagement(_Symbol,MoneyManagement,MinLotPerEquitySteps,RiskPercent,MathAbs(bidPrice - stopLossATR),FixedVolume,ORDER_TYPE_SELL);
            if(volume > 0)
            {
                trade.Sell(volume, _Symbol, bidPrice, stopLossATR, 0);
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

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    // Xử lý sự kiện click button
    btnBuy.OnEvent(id, lparam, dparam, sparam);
    btnBuyStop.OnEvent(id, lparam, dparam, sparam);
    btnBuyLimit.OnEvent(id, lparam, dparam, sparam);
    btnCancelBuy.OnEvent(id, lparam, dparam, sparam);
    btnCloseBuy.OnEvent(id, lparam, dparam, sparam);
    
    btnSell.OnEvent(id, lparam, dparam, sparam);
    btnSellStop.OnEvent(id, lparam, dparam, sparam);
    btnSellLimit.OnEvent(id, lparam, dparam, sparam);
    btnCancelSell.OnEvent(id, lparam, dparam, sparam);
    btnCloseSell.OnEvent(id, lparam, dparam, sparam);

    // ✅ THÊM: Xử lý khi chart thay đổi (template change)
    if(id == CHARTEVENT_CHART_CHANGE)
    {
        // Kiểm tra xem button có tồn tại không
        if(ObjectFind(0, BTN_BUY_NAME) < 0)
        {
            Print("Template đã thay đổi. Tạo lại buttons...");
            CreateAllButtons();
        }
    }

    // Xử lý sự kiện xóa đối tượng (khi template thay đổi, buttons có thể bị xóa)
    if(id == CHARTEVENT_OBJECT_DELETE)
    {
        // Kiểm tra xem button nào bị xóa và tạo lại nó
        if(sparam == BTN_BUY_NAME || sparam == BTN_BUY_STOP_NAME || 
           sparam == BTN_BUY_LIMIT_NAME || sparam == BTN_CANCEL_BUY_NAME || 
           sparam == BTN_CLOSE_BUY_NAME || sparam == BTN_SELL_NAME || 
           sparam == BTN_SELL_STOP_NAME || sparam == BTN_SELL_LIMIT_NAME || 
           sparam == BTN_CANCEL_SELL_NAME || sparam == BTN_CLOSE_SELL_NAME)
        {
            Print("Button bị xóa: ", sparam, ". Tạo lại tất cả các buttons...");
            CreateAllButtons();
        }
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
    // double high4 = Bar.High(4);
    // double high5 = Bar.High(5);
    // Print("High 1: ", high1, " | High 2: ", high2, " | High 3: ", high3, " | High 4: ", high4, " | High 5: ", high5);
    // Tính trung bình giá cao nhất
    double averageHigh = (high1 + high2 + high3) / 3.0;

    return averageHigh;
}

double CalculateAverageLow()
{
    // Lấy giá thấp nhất của 5 cây nến gần nhất
    double low1 = Bar.Low(1);
    double low2 = Bar.Low(2);
    double low3 = Bar.Low(3);
    // double low4 = Bar.Low(4);
    // double low5 = Bar.Low(5);
    // Print("Low 1: ", low1, " | Low 2: ", low2, " | Low 3: ", low3, " | Low 4: ", low4, " | Low 5: ", low5);
    // Tính trung bình giá cao nhất
    double averageLow = (low1 + low2 + low3) / 3.0;

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

// Hàm cập nhật giá trị Max Drawdown ngày
void UpdateMaxDrawdownDaily()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    datetime now = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(now, timeStruct);

    // Nếu là ngày mới, reset giá trị maxEquity và minEquity
    if (lastResetDaily == 0 || (timeStruct.hour == 0 && timeStruct.min == 0)) 
    {
        maxEquityToday = currentEquity;
        minEquityToday = currentEquity;
        lastResetDaily = now;
    }

    // Cập nhật max và min equity trong ngày
    if (currentEquity > maxEquityToday)
        maxEquityToday = currentEquity;
    if (currentEquity < minEquityToday)
        minEquityToday = currentEquity;
}
// Hàm cập nhật giá trị Max Drawdown tháng
void UpdateMaxDrawdownMonthly()
{
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    datetime now = TimeCurrent();
    MqlDateTime timeStruct;
    TimeToStruct(now, timeStruct);

    // Nếu sang tháng mới, reset giá trị maxEquity và minEquity
    if (lastResetMonth == 0 || timeStruct.mon != lastResetMonth) 
    {
        maxEquityMonth = currentEquity;
        minEquityMonth = currentEquity;
        lastResetMonth = timeStruct.mon;
    }

    // Cập nhật max và min equity trong tháng
    if (currentEquity > maxEquityMonth)
        maxEquityMonth = currentEquity;
    if (currentEquity < minEquityMonth)
        minEquityMonth = currentEquity;
}

// Hàm trả về giá trị Max Drawdown trong ngày
double GetCurrentDrawdownDaily()
{
    if (maxEquityToday == 0) return 0.0; // Tránh chia cho 0

    double drawdownPercent = ((minEquityToday - maxEquityToday) / maxEquityToday) * 100.0;
    return drawdownPercent; // Trả về giá trị MDD hiện tại (%)
}
// Hàm trả về giá trị Max Drawdown trong tháng
double GetCurrentDrawdownMonthly()
{
    if (maxEquityMonth == 0) return 0.0; // Tránh chia cho 0

    double drawdownPercent = ((minEquityMonth - maxEquityMonth) / maxEquityMonth) * 100.0;
    return drawdownPercent; // Trả về giá trị MDD hiện tại của tháng (%)
}

// Hàm kiểm tra xem Drawdown có vượt quá mức cho phép không
// bool IsMaxDrawdownExceeded()
// {
//     double dailyDD = GetCurrentDrawdownDaily();
//     double monthlyDD = GetCurrentDrawdownMonthly();

//     if (dailyDD <= maxDailyDrawdown || monthlyDD <= maxMonthlyDrawdown) 
//     {
//         Print("Drawdown vượt mức giới hạn! Dừng giao dịch.");
//         return true;
//     }
//     return false;
// }

// Hàm gửi tin nhắn Telegram
// void SendTelegramMessage(string message) 
// {
//     string botToken = "7826196467:AAGmlJcO4_EREt9NU30bWM4W1lQlDWoUOZM";   // Thay bằng token từ BotFather
//     string chatID   = "1349135415";     // Thay bằng Chat ID của bạn

//     string url = "https://api.telegram.org/bot" + botToken + "/sendMessage";
//     string data = "chat_id=" + chatID + "&text=" + message;
    
//     char requestData[];
//     StringToCharArray(data, requestData); // Chuyển `string` thành `char[]` đúng chuẩn
    
//     char result[];
//     string result_headers;
//     ResetLastError();
    
//     // 🛠 Headers cần thiết cho HTTP POST request
//     string headers = "Content-Type: application/x-www-form-urlencoded\r\n";

//     int res = WebRequest("POST", url, headers, 5000, requestData, result, result_headers);

//     if(res == -1)
//     {
//         Print("Telegram gửi lỗi: ", GetLastError());
//     }
//     else
//     {
//         Print("..Tin nhắn Telegram đã gửi thành công!");
//     }
// }