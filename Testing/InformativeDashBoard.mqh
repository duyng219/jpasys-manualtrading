//+------------------------------------------------------------------+
//|                                         InformativeDashBoard.mqh |
//|                                                            duyng |
//|                                      https://github.com/duyng219 |
//+------------------------------------------------------------------+
#property copyright "duyng"
#property link      "https://github.com/duyng219"
#property version   "1.00"
#include <Controls/Dialog.mqh>
#include <Controls/Defines.mqh>
#include <Controls/Label.mqh>

class CInformativeDashBoard: public CAppDialog
{
    protected:
        virtual bool OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam); // Very important function inherited from CAppDialog
        CLabel account_name;
        CLabel daily_pl;
        CLabel percent_dd;
        CLabel pos_orders;
        CLabel spread;

        CLabel account_name_value;
        CLabel daily_pl_value;
        CLabel percent_dd_value;
        CLabel pos_orders_value;
        CLabel spread_value;
        

        bool CreateLabel(CLabel &label, int x, int y, int width, string label_name, string text);
    public:
        CInformativeDashBoard();
        ~CInformativeDashBoard();

        bool CreateDashboard(string name, int x1, int y1, int x2, int y2);

        virtual bool Run()
        {
            return CAppDialog::Run();
        }
        void RefreshValues(void);
};
EVENT_MAP_BEGIN(CInformativeDashBoard)

EVENT_MAP_END(CAppDialog)

CInformativeDashBoard::CInformativeDashBoard(void)
{
    m_chart_id = 0;
    m_subwin = 0;
}

bool CInformativeDashBoard::CreateDashboard(string name, int x1, int y1, int x2, int y2)
{
    if(!Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
    {
        Print("Failed to create dashboard Error: ", GetLastError());
        return false;
    }
    int width = 10;

    //Label name
    account_name.Color(clrGreen);
    CreateLabel(account_name,20,20,width,"ac_name","AC Name :");
    CreateLabel(daily_pl,20,60,width,"daily_pl","Daily PL: ");
    CreateLabel(percent_dd,20,100,width,"percent_dd","% Drawdown: ");
    CreateLabel(pos_orders,20,140,width,"pos_order","Pos & Orders: ");
    CreateLabel(spread,20,180,width,"spread","Spread: ");

    //Label value
    string ac_name_value = AccountInfoString(ACCOUNT_NAME);
    
    CreateLabel(account_name_value,200,20,width,"ac_name_value",ac_name_value);
    CreateLabel(daily_pl_value,200,60,width,"daily_pl_value","100");
    CreateLabel(percent_dd_value,200,100,width,"percent_dd_value","100");
    CreateLabel(pos_orders_value,200,140,width,"pos_order_value","Pos & Orders: ");
    CreateLabel(spread_value,200,180,width,"spread_value","100");

    ChartRedraw(m_chart_id);

    return true;
}

CInformativeDashBoard::~CInformativeDashBoard()
{
}

bool CInformativeDashBoard::CreateLabel(CLabel &label, int x, int y, int width, string label_name, string text)
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
    // label.Font("Arial");
    // label.FontSize(12);
    return true;
}

void CInformativeDashBoard::RefreshValues(void)
{
    daily_pl_value.Text(DoubleToString(DailyPL(),3));
    double daily_pl_var = DailyPL();
    if (daily_pl_var > 0)   
    {
        daily_pl_value.Color(clrGreen);
    } 
    else
    {
        daily_pl_value.Color(clrRed);
    }
    

    double dd_percent = (AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE)) / AccountInfoDouble(ACCOUNT_BALANCE);
    percent_dd_value.Text(DoubleToString(dd_percent*100,3));
    pos_orders_value.Text(string(OrdersTotal()+PositionsTotal()));

    int market_spreads = (int)SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
    spread_value.Text(string(market_spreads));
    
}

double DailyPL()
{
    double dayprof = 0.0;
    datetime end = TimeCurrent();
    string sdate = TimeToString(TimeCurrent(), TIME_DATE);
    datetime start = StringToTime(sdate);

    HistorySelect(start,end);
    int TotalDeals = HistoryDealsTotal();

    for (int i = 0; i < TotalDeals; i++)
    {
        ulong Ticket = HistoryDealGetTicket(i);

        if(HistoryDealGetInteger(Ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
            double LatestProfit = HistoryDealGetDouble(Ticket, DEAL_PROFIT);
            dayprof += LatestProfit;
        }
    }

    return dayprof;
    
}

