//+------------------------------------------------------------------+
//|                                         Interactive Panel EA.mq5 |
//|                                                            duyng |
//|                                      https://github.com/duyng219 |
//+------------------------------------------------------------------+
#property copyright "duyng"
#property link "https://github.com/duyng219"
#property version "1.00"

#include "InteractivePanel.mqh"
CInteractivePanel panel;

input int x1_ = 20;
input int y1_ = 40;
input int x2_ = 720;
input int y2_ = 550;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    panel.CreatePanel("Interactive Panel", x1_,y1_,x2_,y2_);
    panel.Run();
    Print("Chart ID: ", ChartID());
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    panel.Destroy(reason);
}

void OnTick()
{
    panel.RefreshOnTick();
    panel.ReinforceMenus();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    panel.ChartEvent(id, lparam, dparam, sparam);
}
