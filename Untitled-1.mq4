// Lấy kích thước biểu đồ
int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
// Top menu buttons
double btn_height = chart_height * 0.05;  // 5% chiều cao biểu đồ
double btn_width = chart_width * 0.15;   // 15% chiều rộng biểu đồ

// int OnInit() 
// {  
// Hàm khởi tạo Các Button trên biểu đồ bằng Pixel
//     //SET VARIABLES
//     Trade.SetMagicNumber(MagicNumber);

//     createText("1", string(_Period), 20,20,clrLinen,13,"Arial");

//     // chart_id   : ID của chart (0 là chart hiện tại)
//     // name       : Tên của đối tượng (BTN_BUY_NAME là hằng ký hiệu nút)
//     // sub_window : Chỉ định subwindow (0 là subwindow chính)
//     // x1, y1     : Tọa độ góc trên/trái
//     // x2, y2     : Tọa độ góc dưới/phải
    
//     //BUTTON BUY
//     btnBuy.Create(0,BTN_BUY_NAME,0,60,100,260,150);
//     btnBuy.Text("BUY");
//     btnBuy.Color(clrWhite);
//     btnBuy.ColorBackground(C'2, 119, 118');
//     btnBuy.ColorBorder(C'4, 82, 81');
//     btnBuy.FontSize(11);

//     btnBuyStop.Create(0,BTN_BUY_STOP_NAME,0,60,150,260,190);
//     btnBuyStop.Text("BUY STOP");
//     btnBuyStop.Color(clrWhite);
//     btnBuyStop.ColorBackground(C'2, 119, 118');
//     btnBuyStop.ColorBorder(C'4, 82, 81');
//     btnBuyStop.FontSize(9);

    

//     btnBuyLimit.Create(0,BTN_BUY_LIMIT_NAME,0,60,190,260,230);
//     btnBuyLimit.Text("BUY LIMIT");
//     btnBuyLimit.Color(clrWhite);
//     btnBuyLimit.ColorBackground(C'2, 119, 118');
//     btnBuyLimit.ColorBorder(C'4, 82, 81');
//     btnBuyLimit.FontSize(9);


//     btnCancelBuy.Create(0,BTN_CANCEL_BUY_NAME,0,60,250,260,280);
//     btnCancelBuy.Text("CANCEL BUY ORDER");
//     btnCancelBuy.Color(C'2, 119, 118');
//     btnCancelBuy.ColorBackground(C'242, 220, 162');
//     btnCancelBuy.ColorBorder(C'4, 82, 81');
//     btnCancelBuy.FontSize(7);
//     ObjectSetString(0,BTN_CANCEL_BUY_NAME,OBJPROP_TOOLTIP,"Cancel Pending Order");

//     btnCloseBuy.Create(0,BTN_CLOSE_BUY_NAME,0,60,280,260,310);
//     btnCloseBuy.Text("CLOSE BUY");
//     btnCloseBuy.Color(C'2, 119, 118');
//     btnCloseBuy.ColorBackground(clrWhite);
//     btnCloseBuy.ColorBorder(C'4, 82, 81');
//     btnCloseBuy.FontSize(9);
//     ObjectSetString(0,BTN_CLOSE_BUY_NAME,OBJPROP_TOOLTIP,"Close Buy First");

//      //BUTTON SELL
//     btnSell.Create(0,BTN_SELL_NAME,0,260,100,460,150);
//     btnSell.Text("SELL");
//     btnSell.Color(clrWhite);
//     btnSell.ColorBackground(clrDarkRed);
//     btnSell.ColorBorder(C'74, 4, 8');
//     btnSell.FontSize(11);

//     btnSellStop.Create(0,BTN_SELL_STOP_NAME,0,260,150,460,190);
//     btnSellStop.Text("SELL STOP");
//     btnSellStop.Color(clrWhite);
//     btnSellStop.ColorBackground(clrDarkRed);
//     btnSellStop.ColorBorder(C'74, 4, 8');
//     btnSellStop.FontSize(9);

//     btnSellLimit.Create(0,BTN_SELL_LIMIT_NAME,0,260,190,460,230);
//     btnSellLimit.Text("SELL LIMIT");
//     btnSellLimit.Color(clrWhite);
//     btnSellLimit.ColorBackground(clrDarkRed);
//     btnSellLimit.ColorBorder(C'74, 4, 8');
//     btnSellLimit.FontSize(9);

//     btnCancelSell.Create(0,BTN_CANCEL_SELL_NAME,0,260,250,460,280);
//     btnCancelSell.Text("CANCEL SELL ORDER");
//     btnCancelSell.Color(clrDarkRed);
//     btnCancelSell.ColorBackground(C'242, 220, 162');
//     btnCancelSell.ColorBorder(C'74, 4, 8');
//     btnCancelSell.FontSize(7);
//     ObjectSetString(0,BTN_CANCEL_SELL_NAME,OBJPROP_TOOLTIP,"Cancel Pending Order");

//     btnCloseSell.Create(0,BTN_CLOSE_SELL_NAME,0,260,280,460,310);
//     btnCloseSell.Text("CLOSE SELL");
//     btnCloseSell.Color(clrDarkRed);
//     btnCloseSell.ColorBackground(clrWhite);
//     btnCloseSell.ColorBorder(C'74, 4, 8');
//     btnCloseSell.FontSize(9);
//     ObjectSetString(0,BTN_CLOSE_SELL_NAME,OBJPROP_TOOLTIP,"Close Sell First");

//     ChartRedraw();

//     int MAHandle = MA.Init(_Symbol,PERIOD_CURRENT,MAPeriod,MAShift,MAMethod,MAPrice);
//     if(MAHandle == -1){
//         return(INIT_FAILED);}

//     // Gán chỉ báo vào biểu đồ
//     //ChartIndicatorAdd(0, 0, MAHandle);

//     int ATRHandle = ATR.Init(_Symbol,PERIOD_CURRENT,ATRPeriod);   
//     if(ATRHandle == -1){
//         return(INIT_FAILED);}

//     return(INIT_SUCCEEDED);
// }