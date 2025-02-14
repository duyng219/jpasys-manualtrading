//+------------------------------------------------------------------+
//|                                             InteractivePanel.mqh |
//|                                                            duyng |
//|                                      https://github.com/duyng219 |
//+------------------------------------------------------------------+
#property copyright "duyng"
#property link "https://github.com/duyng219"
#property version "1.00"

#include <Controls/Dialog.mqh>
#include <Controls/Defines.mqh>
#include <Controls/Button.mqh>
#include <Controls/Label.mqh>
#include <Controls/ComboBox.mqh>

#include <Trade/Trade.mqh>          // Thư viện để thực hiện giao dịch (CTrade)
#include <Trade/PositionInfo.mqh>   // Thư viện để lấy thông tin vị thế (CPositionInfo)

CTrade trade;                       // Đối tượng CTrade để thực hiện các lệnh giao dịch
CPositionInfo m_position;           // Đối tượng CPositionInfo để truy cập thông tin các lệnh đang mở

class CInteractivePanel: public CAppDialog
{
    protected:
        virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

        //--- Top menu buttons

        CButton trade_action;
        CButton trade_management;
        CButton risk_management;

        enum active_menu_selected_enum
        {
            TRADE_ACTION,
            TRADE_MANAGEMENT,
            RISK_MANAGEMENT
        }active_menu_selected;

        struct trade_action_menu_struct
        {
            //--- Trade action menu objects
            //--- for buy
            CLabel sl_label;
            CLabel tp_label;
            CLabel magic_label;
            CLabel trade_action_label;

            CEdit sl_buy_edit;
            CEdit tp_buy_edit;
            CEdit magic_buy_edit;
            CButton buy_button;

            //--- for sell
            CEdit sl_sell_edit;
            CEdit tp_sell_edit;
            CEdit magic_sell_edit;
            CButton sell_button;

            void HideAll()
            {
                 //--- for buy
                sl_label.Hide();
                tp_label.Hide();
                magic_label.Hide();
                trade_action_label.Hide();

                sl_buy_edit.Hide();
                tp_buy_edit.Hide();
                magic_buy_edit.Hide();
                buy_button.Hide();

                //--- for sell
                sl_sell_edit.Hide();
                tp_sell_edit.Hide();
                magic_sell_edit.Hide();
                sell_button.Hide();

                ChartRedraw();
            }

            void ShowAll()
            {
                 //--- for buy
                sl_label.Show();
                tp_label.Show();
                magic_label.Show();
                trade_action_label.Show();

                sl_buy_edit.Show();
                tp_buy_edit.Show();
                magic_buy_edit.Show();
                buy_button.Show();

                //--- for sell
                sl_sell_edit.Show();
                tp_sell_edit.Show();
                magic_sell_edit.Show();
                sell_button.Show();

                ChartRedraw();
            }
        } trade_action_menu;
        
        //--- Trade management menu section
        struct trade_management_menu_struct
        {
            CLabel trade_protection_label;
            CComboBox trade_protection_dropdown;

            CLabel trailing_stop_label;
            CEdit trailing_stop_edit;

            CLabel trailing_step_label;
            CEdit trailing_step_edit;

            CLabel break_even_label;
            CEdit break_even_stop_edit;

            CLabel magic_number_label;
            CEdit magic_number_edit;
            CButton close_pos_button;

            CLabel close_all_label;
            CButton close_all_button;

            void HideAll()
            {
                trade_protection_label.Hide();
                trade_protection_dropdown.Hide();

                trailing_stop_label.Hide();
                trailing_stop_edit.Hide();

                trailing_step_label.Hide();
                trailing_step_edit.Hide();

                break_even_label.Hide();
                break_even_stop_edit.Hide();

                magic_number_label.Hide();
                magic_number_edit.Hide();
                close_pos_button.Hide();

                close_all_label.Hide();
                close_all_button.Hide();

                ChartRedraw();
            }
            void ShowAll()
            {
                trade_protection_label.Show();
                trade_protection_dropdown.Show();

                trailing_stop_label.Show();
                trailing_stop_edit.Show();

                trailing_step_label.Show();
                trailing_step_edit.Show();

                break_even_label.Show();
                break_even_stop_edit.Show();

                magic_number_label.Show();
                magic_number_edit.Show();
                close_pos_button.Show();

                close_all_label.Show();
                close_all_button.Show();

                ChartRedraw();
            }

        }trade_management_menu;
        
        struct risk_management_menu_struct
        {
            CLabel lot_size_label;
            CComboBox lot_size_dropdown;
            CEdit manual_lot_edit;

            CLabel max_posotions_label;
            CEdit max_posotions_edit;

            CLabel max_dd_label;
            CEdit max_dd_edit;

            void HideAll()
            {
                lot_size_label.Hide();
                lot_size_dropdown.Hide();
                manual_lot_edit.Hide();

                max_posotions_label.Hide();
                max_posotions_edit.Hide();

                max_dd_label.Hide();
                max_dd_edit.Hide();

                ChartRedraw();
            }
            void ShowAll()
            {
                lot_size_label.Show();
                lot_size_dropdown.Show();

                max_posotions_label.Show();
                max_posotions_edit.Show();

                max_dd_label.Show();
                max_dd_edit.Show();

                ChartRedraw();
            }
        }risk_management_menu;
        

        bool CreateButton(CButton &button, int x, int y, int height, int width, string name, string text);
        bool CreateLabel(CLabel &label, int x, int y, int width, string label_name, string text);
        bool CreateEdit(CEdit &edit, int x, int y, int width, int height, string name, string placeholder);
        bool CreateComboBox(CComboBox &dropdown, int x, int y, int width, int height, string name);

        //--- Button actions
        void TradeActionMenuOnClick()
        {
            trade_management_menu.HideAll();
            risk_management_menu.HideAll();
            trade_action_menu.ShowAll();

            active_menu_selected = TRADE_ACTION;

            trade_action.Color(clrWhite);
            trade_action.ColorBackground(clrDodgerBlue);

            trade_management.Color(clrBlack);
            trade_management.ColorBackground(clrLightGray);

            risk_management.Color(clrBlack);
            risk_management.ColorBackground(clrLightGray);
        }

        void TradeManageMenuOnClick()
        {
            trade_action_menu.HideAll();
            risk_management_menu.HideAll();
            trade_management_menu.ShowAll();

            active_menu_selected = TRADE_MANAGEMENT;

            // current active stage is assigned // Giai đoạn hoạt động hiện tại được chỉ định
            trade_management.Color(clrWhite);
            trade_management.ColorBackground(clrDodgerBlue);

            // the rest menus are rest to original state in color // Các menu còn lại là phần còn lại của trạng thái ban đầu
            trade_action.Color(clrBlack);
            trade_action.ColorBackground(clrLightGray);

            risk_management.Color(clrBlack);
            risk_management.ColorBackground(clrLightGray);
        }

        void RiskManagementMenuOnClick()
        {
            trade_action_menu.HideAll();
            trade_management_menu.HideAll();
            risk_management_menu.ShowAll();
            LotsizeDropDownOnChange();

            active_menu_selected = RISK_MANAGEMENT;

            risk_management.Color(clrWhite);
            risk_management.ColorBackground(clrDodgerBlue);

            trade_management.Color(clrBlack);
            trade_management.ColorBackground(clrLightGray);

            trade_action.Color(clrBlack);
            trade_action.ColorBackground(clrLightGray);
        }

        void BuyOnClick() 
        {
            double ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
            double stoploss = StringToDouble(trade_action_menu.sl_buy_edit.Text());
            if(stoploss > 0)
                stoploss = ask - stoploss * Point();
            else
                stoploss = 0;
            
            double takeprofit = StringToDouble(trade_action_menu.tp_buy_edit.Text());
            if(takeprofit > 0)
                takeprofit = ask + takeprofit * Point();
            else
                takeprofit = 0;

            trade.SetExpertMagicNumber(int(trade_action_menu.magic_buy_edit.Text()));

            double volume = 0;
            switch ((int)risk_management_menu.lot_size_dropdown.Value())
            {
            case 1: // based on balance
                volume = AccountInfoDouble(ACCOUNT_BALANCE)/10000.0;
                break;
            case 2: // based on equity
                volume = AccountInfoDouble(ACCOUNT_EQUITY)/10000.0;
                break;
            case 3: // deploy manual lot
                volume = (double)risk_management_menu.manual_lot_edit.Text();
                break;
            default:
                break;
            }
            int maxPositions = (int)risk_management_menu.max_posotions_edit.Text();
            if(PositionsTotal() < maxPositions)
                trade.Buy(NormalizeDouble(volume,2),Symbol(),ask,stoploss,takeprofit);
            else
                Print("Maximum number of positions reached");
        }

        void SellOnClick() 
        {
            double bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);
            double stoploss = StringToDouble(trade_action_menu.sl_buy_edit.Text());
            if(stoploss > 0)
                stoploss = bid + stoploss * Point();
            else
                stoploss = 0;
    
            double takeprofit = StringToDouble(trade_action_menu.tp_buy_edit.Text());
            if(takeprofit > 0)
                takeprofit = bid - takeprofit * Point();
            else
                takeprofit = 0;

            trade.SetExpertMagicNumber(int(trade_action_menu.magic_sell_edit.Text()));

            double volume = 0;
            switch ((int)risk_management_menu.lot_size_dropdown.Value())
            {
            case 1: // based on balance
                volume = AccountInfoDouble(ACCOUNT_BALANCE)/10000.0;
                break;
            case 2: // based on equity
                volume = AccountInfoDouble(ACCOUNT_EQUITY)/10000.0;
                break;
            case 3: // deploy manual lot
                volume = (double)risk_management_menu.manual_lot_edit.Text();
                break;
            default:
                break;
            }
            int maxPositions = (int)risk_management_menu.max_posotions_edit.Text();
            if(PositionsTotal() < maxPositions)
                trade.Sell(NormalizeDouble(volume,2),Symbol(),bid,stoploss,takeprofit);
            else
                Print("Maximum number of positions reached");
        }

        void TradeProtectionDropDownChange()
        {
            switch (int(trade_management_menu.trade_protection_dropdown.Value()))
            {
            case 1: //Trailing stop option is selected
                
                trade_management_menu.break_even_label.Color(clrLightGray);
                trade_management_menu.break_even_stop_edit.Color(clrLightGray);

                trade_management_menu.trailing_step_edit.Color(clrBlack);
                trade_management_menu.trailing_step_label.Color(clrBlack);
                trade_management_menu.trailing_stop_label.Color(clrBlack);
                trade_management_menu.trailing_stop_edit.Color(clrBlack);

                break;
            
            case 2: //Break Even option is selected

                trade_management_menu.break_even_label.Color(clrBlack);
                trade_management_menu.break_even_stop_edit.Color(clrBlack);

                trade_management_menu.trailing_step_edit.Color(clrLightGray);
                trade_management_menu.trailing_step_label.Color(clrLightGray);
                trade_management_menu.trailing_stop_label.Color(clrLightGray);
                trade_management_menu.trailing_stop_edit.Color(clrLightGray);

                break;
            default:
                break;
            }
        }


        // Hàm BreakEven: Dịch chuyển Stop Loss về giá mở lệnh khi giá di chuyển một khoảng nhất định (breakeven_step)
        void BreakEven(double breakeven_step)
        {
            MqlTick ticks;                              // Khai báo biến ticks để lưu thông tin giá hiện tại
            SymbolInfoTick(Symbol(), ticks);            // Lấy thông tin giá hiện tại của symbol

            // Duyệt qua tất cả các lệnh đang mở (từ lệnh cuối cùng đến lệnh đầu tiên)
            for (int i = PositionsTotal() - 1; i >= 0; i--) // Vì chỉ số trong mảng hoặc danh sách của MQL5 bắt đầu từ 0, nên chỉ số của vị thế cuối cùng sẽ là PositionsTotal() - 1. Nếu có 5 lệnh mở, thì chỉ số các lệnh sẽ là: 0, 1, 2, 3, 4. Lệnh cuối cùng (chỉ số lớn nhất) là 4, tương ứng với PositionsTotal() - 1.
            {
                if (m_position.SelectByIndex(i))        // Chọn vị thế theo chỉ số 'i'
                {
                    if (m_position.Symbol() == Symbol()) // Kiểm tra xem vị thế có thuộc symbol hiện tại không
                    {
                        switch (m_position.PositionType()) // Kiểm tra loại vị thế: Buy hay Sell
                        {
                            case POSITION_TYPE_BUY:    // Nếu là lệnh Buy
                                // Kiểm tra giá Bid đã vượt qua mức hòa vốn chưa (giá mở + breakeven_step)
                                if (ticks.bid > m_position.PriceOpen() + breakeven_step * Point())
                                {
                                    // Nếu Stop Loss hiện tại nhỏ hơn giá mở (chưa được đặt tại hòa vốn)
                                    if (m_position.StopLoss() < m_position.PriceOpen())
                                    {
                                        // Dịch chuyển Stop Loss về giá mở lệnh (hòa vốn)
                                        trade.PositionModify(m_position.Ticket(), m_position.PriceOpen(), m_position.TakeProfit());
                                    }
                                }
                                break;

                            case POSITION_TYPE_SELL:   // Nếu là lệnh Sell
                                // Kiểm tra giá Ask đã giảm xuống mức hòa vốn chưa (giá mở - breakeven_step)
                                if (ticks.ask < m_position.PriceOpen() - breakeven_step * Point())
                                {
                                    // Nếu Stop Loss hiện tại lớn hơn giá mở (chưa được đặt tại hòa vốn)
                                    if (m_position.StopLoss() > m_position.PriceOpen())
                                    {
                                        // Dịch chuyển Stop Loss về giá mở lệnh (hòa vốn)
                                        trade.PositionModify(m_position.Ticket(), m_position.PriceOpen(), m_position.TakeProfit());
                                    }
                                }
                                break;
                        }
                    }
                }
            }
        }

        // Hàm TrailingStop: Dịch chuyển Stop Loss theo hướng có lợi khi giá di chuyển thêm một bước nhất định (trail_step)
        void TrailingStop(double trail_step, double trail_stop)
        {
            MqlTick ticks;                              // Khai báo biến ticks để lưu thông tin giá hiện tại
            SymbolInfoTick(Symbol(), ticks);            // Lấy thông tin giá hiện tại của symbol

            // Duyệt qua tất cả các lệnh đang mở (từ lệnh cuối cùng đến lệnh đầu tiên)
            for (int i = PositionsTotal() - 1; i >= 0; i--)
            {
                if (m_position.SelectByIndex(i))        // Chọn vị thế theo chỉ số 'i'
                {
                    if (m_position.Symbol() == Symbol()) // Kiểm tra xem vị thế có thuộc symbol hiện tại không
                    {
                        switch (m_position.PositionType()) // Kiểm tra loại vị thế: Buy hay Sell
                        {
                            case POSITION_TYPE_BUY:    // Nếu là lệnh Buy
                                // Kiểm tra giá đã di chuyển thêm ít nhất trail_step so với Stop Loss hiện tại
                                if (ticks.bid - m_position.StopLoss() > trail_step * Point())
                                {
                                    // Dịch chuyển Stop Loss lên trên một khoảng trail_stop
                                    trade.PositionModify(m_position.Ticket(),
                                                        m_position.StopLoss() + trail_stop * Point(),
                                                        m_position.TakeProfit());
                                }
                                break;

                            case POSITION_TYPE_SELL:   // Nếu là lệnh Sell
                                // Kiểm tra giá đã di chuyển thêm ít nhất trail_step so với Stop Loss hiện tại
                                if (m_position.StopLoss() - ticks.ask > trail_step * Point())
                                {
                                    // Dịch chuyển Stop Loss xuống dưới một khoảng trail_stop
                                    trade.PositionModify(m_position.Ticket(),
                                                        m_position.StopLoss() - trail_stop * Point(),
                                                        m_position.TakeProfit());
                                }
                                break;
                        }
                    }
                }
            }
        }

        void CloseByMagic()
        {
            for (int i = PositionsTotal()-1; i >= 0; i--)
            {
                if(m_position.SelectByIndex(i))
                    if(m_position.Magic() == (int)trade_management_menu.magic_number_edit.Text() && m_position.Symbol() == Symbol())
                        trade.PositionClose(m_position.Ticket());
            }
        }

        void LotsizeDropDownOnChange()
        {
            if(risk_management_menu.lot_size_dropdown.Value()==3)
            {
                risk_management_menu.manual_lot_edit.Show();
            }
            else
            {
                risk_management_menu.manual_lot_edit.Hide();
            }
        }

    public:
        CInteractivePanel();
        ~CInteractivePanel();

        bool CreatePanel(string name, int x1, int y1, int x2, int y2);

        virtual bool Run()
        {
            return CAppDialog::Run();
        }

        void RefreshOnTick();

        void ReinforceMenus()
        {
            if(m_minimized)
                return;
            
            switch (active_menu_selected)
            {
                case TRADE_ACTION:
                    if(trade_management_menu.close_all_button.IsVisible() || risk_management_menu.lot_size_dropdown.IsVisible())
                    {
                        TradeActionMenuOnClick();
                    }
                    break;
                case TRADE_MANAGEMENT:
                    if(trade_action_menu.buy_button.IsVisible() || risk_management_menu.lot_size_dropdown.IsVisible())
                    {
                        TradeManageMenuOnClick();
                    }
                    break;
                case RISK_MANAGEMENT:
                    if(trade_action_menu.buy_button.IsVisible() || trade_management_menu.close_all_button.IsVisible())
                    {
                        RiskManagementMenuOnClick();
                    }
                    break;
                default:
                    break;
            }
        }
};

EVENT_MAP_BEGIN(CInteractivePanel)

ON_EVENT(ON_CLICK, trade_action_menu.buy_button, BuyOnClick)
ON_EVENT(ON_CLICK, trade_action_menu.sell_button, SellOnClick)

ON_EVENT(ON_CLICK, trade_action, TradeActionMenuOnClick)
ON_EVENT(ON_CLICK, trade_management, TradeManageMenuOnClick)
ON_EVENT(ON_CLICK, risk_management, RiskManagementMenuOnClick)

ON_EVENT(ON_CHANGE, trade_management_menu.trade_protection_dropdown, TradeProtectionDropDownChange)

ON_EVENT(ON_CLICK, trade_management_menu.close_all_button,CloseByMagic)

ON_EVENT(ON_CHANGE, risk_management_menu.lot_size_dropdown, LotsizeDropDownOnChange)

EVENT_MAP_END(CAppDialog)

CInteractivePanel::CInteractivePanel()
{
    m_chart_id = 0; // m_chart_id: Đại diện cho ID của biểu đồ mà panel sẽ được gắn vào. Giá trị mặc định 0 nghĩa là chưa liên kết với bất kỳ biểu đồ nào.
    m_subwin = 0;   // m_subwin: Đại diện cho ID của cửa sổ phụ (subwindow) trong biểu đồ mà panel sẽ được tạo. Giá trị mặc định 0 nghĩa là cửa sổ chính (main chart window) được sử dụng.
}
CInteractivePanel::~CInteractivePanel()
{
}


bool CInteractivePanel::CreatePanel(string name, int x1, int y1, int x2, int y2)
{
    // Tạo panel
    if (!Create(m_chart_id, name, m_subwin, x1, y1, x2, y2))
    {
        Print("Failed to create dashboard Error: ", GetLastError());
        return false;
    }

    // Tính toán kích thước panel
    int panel_width = x2 - x1;  // Chiều rộng panel
    int panel_height = y2 - y1; // Chiều cao panel

    // Top menu buttons
    int btn_height = int(panel_height * 0.1); // 10% chiều cao panel
    int btn_width = int(panel_width * 0.29); // 25% chiều rộng panel

    // CreateButton(trade_action, int(x1 + panel_width * 0.01), int(y1 + panel_height * 0.01),
    //              btn_height, btn_width, "trade_action_menu", "Trade Action");
    //	•	Toàn bộ biểu đồ (không cộng y1): Sử dụng panel_height * tỷ lệ.
	//  •	Bên trong panel (tính từ y1): Sử dụng y1 + panel_height * tỷ lệ.
    CreateButton(trade_action, int(x1 + panel_width * 0.01), int(panel_height * 0.05),
                 btn_height, btn_width, "trade_action_menu", "Trade Action");
    trade_action.ColorBackground(clrDodgerBlue);
    trade_action.Color(clrWhite);

    CreateButton(trade_management, int(x1 + panel_width * 0.31), int(panel_height * 0.05),
                 btn_height, int(panel_width * 0.31), "trade_management_menu", "Trade Management");
    trade_management.ColorBackground(clrLightGray);
    trade_management.Color(clrBlack);

    CreateButton(risk_management, int(x1 + panel_width * 0.63), int(panel_height * 0.05),
                 btn_height, btn_width, "risk_management_menu", "Risk Management");
    risk_management.ColorBackground(clrLightGray);
    risk_management.Color(clrBlack);

    // TRADE ACTION MENU OBJECTS
    int label_width = int(panel_width * 0.1); // 10% chiều rộng label in panel
    int y = int(y1 + panel_height * 0.2);

    CreateLabel(trade_action_menu.sl_label, int(x1 + panel_width * 0.01), y, label_width, "trade_action_menu.sl_label", "SL [Points]");
    CreateLabel(trade_action_menu.tp_label, int(x1 + panel_width * 0.2), y, label_width, "trade_action_menu.tp_label", "TP [Points]");
    CreateLabel(trade_action_menu.magic_label, int(x1 + panel_width * 0.4), y, label_width, "trade_action_menu.magic_label", "Magic Number");
    CreateLabel(trade_action_menu.trade_action_label, int(x1 + panel_width * 0.7), y, label_width, "trade_action_menu.trade_action_label", "Trade Action");

    //for buy
    y = int(y1 + panel_height * 0.3);
    int edit_width = int(panel_width * 0.2); // 20% chiều rộng panel
    int edit_height = int(panel_height * 0.1); // 10% chiều cao panel

    CreateEdit(trade_action_menu.sl_buy_edit,int(x1 + panel_width * 0.01),y,edit_width,edit_height,"buy_sl_edit","0.0");
    CreateEdit(trade_action_menu.tp_buy_edit,int(x1 + panel_width * 0.2),y,edit_width,edit_height,"buy_tp_edit","0.0");
    CreateEdit(trade_action_menu.magic_buy_edit,int(x1 + panel_width * 0.4),y,edit_width,edit_height,"magic_no_sell_edit","0.0");
    CreateButton(trade_action_menu.buy_button,int(x1 + panel_width * 0.7),y,edit_height,int(edit_width-0.2),"buy_btn","Buy At Ask");
    trade_action_menu.buy_button.ColorBackground(clrRed);
    trade_action_menu.buy_button.Color(clrWhite);

    //for sell
    y = int(y1 + panel_height * 0.45);

    CreateEdit(trade_action_menu.sl_sell_edit,int(x1 + panel_width * 0.01),y,edit_width,edit_height,"sell_sl_edit","0.0");
    CreateEdit(trade_action_menu.tp_sell_edit,int(x1 + panel_width * 0.2),y,edit_width,edit_height,"sell_tp_edit","0.0");
    CreateEdit(trade_action_menu.magic_sell_edit,int(x1 + panel_width * 0.4),y,edit_width,edit_height,"magic_no_buy_edit","0.0");
    CreateButton(trade_action_menu.sell_button,int(x1 + panel_width * 0.7),y,edit_height,int(edit_width-0.2),"sell_btn","Sell At Bid");
    trade_action_menu.sell_button.ColorBackground(clrDodgerBlue);
    trade_action_menu.sell_button.Color(clrWhite);

    //TRADE MANAGEMENT MENU OBJECTS
    // TradeManageMenuOnClick();
    //TradeActionMenuOnClick();
    RiskManagementMenuOnClick();

    int x_tm = int(x1 + panel_width * 0.05);
    int y_tm = int(y1 + panel_height);
    //Label
    CreateLabel(trade_management_menu.trade_protection_label, x_tm, int(y_tm * 0.20), label_width, "trade_protection_label", "Trade Protection");
    CreateLabel(trade_management_menu.trailing_step_label, x_tm, int(y_tm * 0.30), label_width, "trailing_step_label", "Trailing Step[Pts]");
    CreateLabel(trade_management_menu.trailing_stop_label, x_tm, int(y_tm * 0.40), label_width, "trailing_stop_label", "Trailing Stop[Pts]");
    CreateLabel(trade_management_menu.break_even_label, x_tm, int(y_tm * 0.50), label_width, "break_even_label", "Break Even");
    CreateLabel(trade_management_menu.magic_number_label, x_tm, int(y_tm * 0.60), label_width, "magic_number_label", "Magic Number");
    CreateLabel(trade_management_menu.close_all_label, x_tm, int(y_tm * 0.70), label_width, "close_all_label", "Bulk Action");
    
    //Value
    CreateComboBox(trade_management_menu.trade_protection_dropdown,int(x1 + panel_width * 0.4), int(y_tm * 0.19), 190, 40,"trade_protecion_dd");
    trade_management_menu.trade_protection_dropdown.AddItem("Trailing Stop",1);
    trade_management_menu.trade_protection_dropdown.AddItem("Break Even",2);
    
    CreateEdit(trade_management_menu.trailing_step_edit,int(x1 + panel_width * 0.4),int(y_tm * 0.30), 190, 40, "trailing-step input","10");
    CreateEdit(trade_management_menu.trailing_stop_edit,int(x1 + panel_width * 0.4),int(y_tm * 0.40), 190, 40, "trailing-stop input","5");
    CreateEdit(trade_management_menu.break_even_stop_edit,int(x1 + panel_width * 0.4),int(y_tm * 0.50), 190, 40, "break-even-stop input","20");
    CreateEdit(trade_management_menu.magic_number_edit,int(x1 + panel_width * 0.4),int(y_tm * 0.60), 190, 40, "magic_number-edit","0");

    CreateButton(trade_management_menu.close_all_button,int(x1 + panel_width * 0.4), int(y_tm * 0.70),40,190,"close-all-btn", "Close All");
    trade_management_menu.close_all_button.Color(clrWhite);
    trade_management_menu.close_all_button.ColorBackground(clrRed);

    // RISK MANAGEMENT MENU OBJECT
    int x_rm = int(x1 + panel_width * 0.05);
    int y_rm = int(y1 + panel_height);
    //Label
    CreateLabel(risk_management_menu.lot_size_label, x_rm, int(y_rm * 0.20), label_width, "lot_size_label", "Lot Size");
    CreateLabel(risk_management_menu.max_posotions_label, x_rm, int(y_rm * 0.30), label_width, "risk_management_label", "Max Positions");
    CreateLabel(risk_management_menu.max_dd_label, x_rm, int(y_rm * 0.40), label_width, "max_dd_label", "Max Drawdown");
    
     //Value
    CreateComboBox(risk_management_menu.lot_size_dropdown,int(x1 + panel_width * 0.4), int(y_rm * 0.19), 190, 40,"lot_size_dd");
    risk_management_menu.lot_size_dropdown.AddItem("Based on Balance", 1);
    risk_management_menu.lot_size_dropdown.AddItem("Based on Equity", 2);
    risk_management_menu.lot_size_dropdown.AddItem("Manual Lot", 3);
    CreateEdit(risk_management_menu.manual_lot_edit,int(x1 + panel_width * 0.75),int(y_rm * 0.19), 90, 40, "manual_lot_edit","0.01");
    risk_management_menu.manual_lot_edit.Hide();

    CreateEdit(risk_management_menu.max_posotions_edit,int(x1 + panel_width * 0.4),int(y_rm * 0.30), 190, 40, "max_pos_edit","10");
    CreateEdit(risk_management_menu.max_dd_edit,int(x1 + panel_width * 0.4),int(y_rm * 0.40), 190, 40, "max_dd_edit","25");

    return true;
}


bool CInteractivePanel::CreateButton(CButton &button, int x, int y, int height, int width, string name, string text)
{
    if (!button.Create(m_chart_id,name,m_subwin,x,y,x+width,y+height))
    {
        Print("Failed to create button Error: ", GetLastError());
        return false;
    }
    if (!Add(button))
    {
        Print("Failed to add button Error: ", GetLastError());
        return false;
    }
    if (!button.Text(text))
    {
        Print("Failed to add text Error: ", GetLastError());
        return false;
    }
    button.FontSize(9);
    
    return true;
}

bool CInteractivePanel::CreateLabel(CLabel &label, int x, int y, int width, string label_name, string text)
{
    if(!label.Create(m_chart_id, m_name + label_name, m_subwin, x, y, x, y + width))
    {
        Print("Failed to create label Error: ", GetLastError());
        return false;
    }

    if(!Add(label))
    {
        Print("Failed to add label Error: ", GetLastError());
        return false;
    }

    if(!label.Text(text))
    {
        Print("Failed to set text Error: ", GetLastError());
        return false;
    }
    // label.Text(text);
    // label.Color(clrBlue);
    label.Font("Arial");
    label.FontSize(9);
    return true;
}

bool CInteractivePanel::CreateEdit(CEdit &edit, int x, int y, int width, int height, string name, string placeholder)
{
    if(!edit.Create(m_chart_id,name,m_subwin,x,y,x+width,y+height))
        return false;
    if(!Add(edit))
        return false;
    if(!edit.Text(placeholder))
        return false;
    
    return true;
}

bool CInteractivePanel::CreateComboBox(CComboBox &dropdown, int x, int y, int width, int height, string name)
{
    if(!dropdown.Create(m_chart_id,name,m_subwin,x,y,x+width,y+height))
        return false;
    if(!Add(dropdown))
        return false;
    
    return true;
}

void CInteractivePanel::RefreshOnTick(void)
{
    double max_dd = (double)risk_management_menu.max_dd_edit.Text();
    double balance = AccountInfoDouble(ACCOUNT_BALANCE) ;
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);

    double max_dd_in_money = balance * (max_dd / 100);

    if(equity < balance) // the account is currently in lossed
    {
        if(MathAbs(balance - equity) < max_dd_in_money)
            Print("Max Drawdown has been reached");
    }

    switch ((int)trade_management_menu.trade_protection_dropdown.Value())
    {
        case 1: // Trailing Stop
        {
            double trail_step = StringToDouble(trade_management_menu.trailing_step_edit.Text());
            double trail_stop = StringToDouble(trade_management_menu.trailing_stop_edit.Text());

            TrailingStop(trail_step,trail_stop);
            break;
        }

        case 2: // Break Even
        {
            double breakeven_step = StringToDouble(trade_management_menu.break_even_stop_edit.Text());

            BreakEven(breakeven_step);
            break;
        }
        default:
        break;
    }
}