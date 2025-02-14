//+------------------------------------------------------------------+
//|                                             Simple Dashboard.mq5 |
//|                                                            duyng |
//|                                      https://github.com/duyng219 |
//+------------------------------------------------------------------+
#property copyright "duyng"
#property link      "https://github.com/duyng219"
#property version   "1.00"

#include "InformativeDashBoard.mqh"
CInformativeDashBoard dashboard;

input int x1_ = 20;
input int y1_ = 40;
input int x2_ = 500;
input int y2_ = 350;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{   
    dashboard.CreateDashboard("Simple Dashboard", x1_, y1_, x2_, y2_);
    dashboard.Run();
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    dashboard.Destroy(reason);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   dashboard.RefreshValues();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    dashboard.ChartEvent(id, lparam, dparam, sparam);
}

