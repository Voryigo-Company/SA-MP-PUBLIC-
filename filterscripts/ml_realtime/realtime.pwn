#include <a_samp>

new PlayerText:TextTime[MAX_PLAYERS];
new PlayerText:TextDate[MAX_PLAYERS];
forward UpdateRealTime(playerid);
forward UpdateRealDate(playerid);

CreateTextDraw(playerid)
{
	TextTime[playerid] = CreatePlayerTextDraw(playerid, 547.000000, 28.000000, "00:00:00");
    PlayerTextDrawFont(playerid, TextTime[playerid], 1);
    PlayerTextDrawLetterSize(playerid, TextTime[playerid], 0.400000, 2.000000);
    PlayerTextDrawTextSize(playerid, TextTime[playerid], 400.000000, 1.399999);
    PlayerTextDrawSetOutline(playerid, TextTime[playerid], 1);
    PlayerTextDrawSetShadow(playerid, TextTime[playerid], 0);
    PlayerTextDrawAlignment(playerid, TextTime[playerid], 1);
    PlayerTextDrawColor(playerid, TextTime[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, TextTime[playerid], 255);
    PlayerTextDrawBoxColor(playerid, TextTime[playerid], 50);
    PlayerTextDrawUseBox(playerid, TextTime[playerid], 0);
    PlayerTextDrawSetProportional(playerid, TextTime[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, TextTime[playerid], 0);
    PlayerTextDrawShow(playerid, TextTime[playerid]);
    //date
    TextDate[playerid] = CreatePlayerTextDraw(playerid, 71.000000, 430.000000, "23 Juni 2026");
    PlayerTextDrawFont(playerid, TextDate[playerid], 1);
    PlayerTextDrawLetterSize(playerid, TextDate[playerid], 0.308332, 1.349998);
    PlayerTextDrawTextSize(playerid, TextDate[playerid], 404.500000, 114.500000);
    PlayerTextDrawSetOutline(playerid, TextDate[playerid], 1);
    PlayerTextDrawSetShadow(playerid, TextDate[playerid], 0);
    PlayerTextDrawAlignment(playerid, TextDate[playerid], 2);
    PlayerTextDrawColor(playerid, TextDate[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, TextDate[playerid], 255);
    PlayerTextDrawBoxColor(playerid, TextDate[playerid], 50);
    PlayerTextDrawSetProportional(playerid, TextDate[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, TextDate[playerid], 0);
}

public UpdateRealTime(playerid)
{
    new jam, menit, detik;
    gettime(jam, menit, detik); // Mengambil waktu server

    new string[16];
    format(string, sizeof(string), "%02d:%02d:%02d", jam, menit, detik);
    
    // Perbarui teks textdraw dan tampilkan ulang
    PlayerTextDrawSetString(playerid, TextTime[playerid], string);
    ReturnTime();
    return 1;
}

public UpdateRealDate(playerid)
{
    new date, month, years;
    getdate(date, month, years); // Mengambil waktu server

    new string[16];
    format(string, sizeof(string), "%02d:%s:%04d", date, month, years);
    
    // Perbarui teks textdraw dan tampilkan ulang
    PlayerTextDrawSetString(playerid, TextDate[playerid], string);
    return 1;
}

GetMonth(bulan)
{
    new month[12];

    switch (bulan) {
        case 1: month = "January";
        case 2: month = "February";
        case 3: month = "March";
        case 4: month = "April";
        case 5: month = "May";
        case 6: month = "June";
        case 7: month = "July";
        case 8: month = "August";
        case 9: month = "September";
        case 10: month = "October";
        case 11: month = "November";
        case 12: month = "December";
    }
    return month;
}

ReturnTime()
{
    static
        date[6],
        string[72];

    getdate(date[2], date[1], date[0]);
    gettime(date[3], date[4], date[5]);

    format(string, sizeof(string), "%02d %s %d, %02d:%02d:%02d", date[0],GetMonth(date[1]), date[2], date[3], date[4], date[5]);
    return string;
}

public OnPlayerConnect(playerid)
{
    CreateTextDraw(playerid);
    SetTimerEx("UpdateRealTime", 1000, true, "i", playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    PlayerTextDrawDestroy(playerid, TextTime[playerid]);
    PlayerTextDrawDestroy(playerid, TextDate[playerid]);
    return 1;
}

public OnFilterScriptInit()
{
  print("[ Filterscripts ]: real_time Loaded.");
  print("From [filterscripts/real_time.amx] Location");
  return 1;
}

public OnFilterScriptExit()
{
  print("[ Filterscripts ]: real_time Unloaded.");
  return 1;
}
