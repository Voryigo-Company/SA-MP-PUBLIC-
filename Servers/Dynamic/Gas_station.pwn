#define MAX_GSTATION 50

enum gsinfo
{
	gsOwner[MAX_PLAYER_NAME],
	gsOwnerID,
	gsName[128],
	gsPrice,
	gsStock,
	gsRestock,
	gsMoney,
	Float:gsPosX,
	Float:gsPosY,
	Float:gsPosZ,
	Text3D:gsLabel,
	gsPickup,
};

new gsData[MAX_GSTATION][gsinfo],
	Iterator:GStation<MAX_GSTATION>;

GStation_Refresh(gsid)
{
	if(gsid != -1)
    {
        if(IsValidDynamic3DTextLabel(gsData[gsid][gsLabel]))
            DestroyDynamic3DTextLabel(gsData[gsid][gsLabel]);

        if(IsValidDynamicPickup(gsData[gsid][gsPickup]))
            DestroyDynamicPickup(gsData[gsid][gsPickup]);

		new tstr[558];
		if(gsData[gsid][gsPosX] != 0 && gsData[gsid][gsPosY] != 0 && gsData[gsid][gsPosZ] != 0 && strcmp(gsData[gsid][gsOwner], "-"))
		{
            format(tstr, sizeof tstr,"[GAS STATION ID: %d]\n%s\n"SBLUE_E"%s\n"WHITE_E"Gas Stock: "YELLOW_E"%d\nPrice: "LG_E"%s/Liters\n"WHITE_E"Type "RED_E"/fill"WHITE_E"To Refill", gsid, gsData[gsid][gsName], gsData[gsid][gsOwner], gsData[gsid][gsStock], FormatMoney(GStationPrice));

			gsData[gsid][gsPickup] = CreateDynamicPickup(1650, 23, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]+0.2, -1, -1, -1, 5.0);
			gsData[gsid][gsLabel] = CreateDynamic3DTextLabel(tstr, COLOR_GREEN, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]+0.5, 4.5);
		}
		else if(gsData[gsid][gsPosX] != 0 && gsData[gsid][gsPosY] != 0 && gsData[gsid][gsPosZ] != 0)
		{
	        format(tstr, sizeof tstr,"[GAS STATION ID: %d]\nFor Sale: "LG_E"%s\n"WHITE_E"Gas Stock: "YELLOW_E"%d\nPrice: "LG_E"%s/Liters\n"WHITE_E"Type "RED_E"/fill"WHITE_E"To Refill\n"SBLUE_E"`/buygstation`", gsid, FormatMoney(gsData[gsid][gsPrice]), gsData[gsid][gsStock], FormatMoney(GStationPrice));

			gsData[gsid][gsPickup] = CreateDynamicPickup(1650, 23, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]+0.2, -1, -1, -1, 5.0);
			gsData[gsid][gsLabel] = CreateDynamic3DTextLabel(tstr, COLOR_GREEN, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]+0.5, 4.5);
   		}
   		
	}
    return 1;
}

function LoadGStation()
{
    static gsid;

	new rows = cache_num_rows(), owner[MAX_PLAYER_NAME], name[128];
 	if(rows)
  	{
		for(new i; i < rows; i++)
		{
			cache_get_value_name_int(i, "id", gsid);
			cache_get_value_name(i, "owner", owner);
			format(gsData[gsid][gsOwner], MAX_PLAYER_NAME, owner);
			cache_get_value_name(i, "ownerid", gsData[gsid][gsOwnerID]);
			cache_get_value_name(i, "name", name);
			format(gsData[gsid][gsName], 128, name);
			cache_get_value_name_int(i, "price", gsData[gsid][gsPrice]);
			cache_get_value_name_int(i, "stock", gsData[gsid][gsStock]);
			cache_get_value_name_int(i, "restock", gsData[gsid][gsRestock]);
            cache_get_value_name_int(i, "money", gsData[gsid][gsMoney]);
			cache_get_value_name_float(i, "posx", gsData[gsid][gsPosX]);
			cache_get_value_name_float(i, "posy", gsData[gsid][gsPosY]);
			cache_get_value_name_float(i, "posz", gsData[gsid][gsPosZ]);
			GStation_Refresh(gsid);
			Iter_Add(GStation, gsid);
		}
		printf("[Gas Station]: %d Loaded.", rows);
	}
}

IsGStationOwner(playerid, gsid)
{
    if(!strcmp(gsData[gsid][gsOwner], pData[playerid][pName], true))
        return 1;

    return 0;
}

ReturnPlayerGStationID(playerid, hslot)
{
	new tmpcount;
	if(hslot < 1 && hslot > LIMIT_PER_PLAYER) return -1;
	foreach(new gsid : GStation)
	{
	    if(!strcmp(pData[playerid][pName], gsData[gsid][gsOwner], true) || (gsData[gsid][gsOwnerID] == pData[playerid][pID]))
	    {
     		tmpcount++;
       		if(tmpcount == hslot)
       		{
        		return gsid;
  			}
	    }
	}
	return -1;
}

GStation_Save(gsid)
{
	new cQuery[512];
	format(cQuery, sizeof(cQuery), "UPDATE gstation SET owner='%s', ownerid='%d', name='%s', price='%d', stock='%d', restock='%d', money='%d', posx='%f', posy='%f', posz='%f' WHERE ID='%d'",
	gsData[gsid][gsOwner],
	gsData[gsid][gsOwnerID],
	gsData[gsid][gsName],
	gsData[gsid][gsPrice],
	gsData[gsid][gsStock],
	gsData[gsid][gsRestock],
	gsData[gsid][gsMoney],
	gsData[gsid][gsPosX],
	gsData[gsid][gsPosY],
	gsData[gsid][gsPosZ],
	gsid);
	return mysql_tquery(g_SQL, cQuery);
}

GStation_Reset(gsid)
{
  gsData[gsid][gsMoney] = 0;
  gsData[gsid][gsStock] = 0;
  gsData[gsid][gsRestock] = 0;
  gsData[gsid][gsOwnerID] = 0;
  format(gsData[gsid][gsOwner], MAX_PLAYER_NAME, "-");
  format(gsData[gsid][gsName], 128, "-");
  GStation_Refresh(gsid);
}

CMD:creategs(playerid, params[])
{
	if(pData[playerid][pAdmin] < 6)
		return PermissionError(playerid);

	new cQuery[512];
	new gsid = Iter_Free(GStation), address[128];

	new price;
	if(sscanf(params, "d", price))
		return Usage(playerid, "/creategs [price]");

	if((gsid < 0 || gsid >= MAX_GSTATION))
        return Error(playerid, "You have already input in this server.");

	format(gsData[gsid][gsOwner], 128, "-");
	gsData[gsid][gsOwnerID] = 0;
	GetPlayerPos(playerid, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]);
	address = GetLocation(gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]);
	format(gsData[gsid][gsName], 128, address);
	gsData[gsid][gsPrice] = price;

	Iter_Add(GStation, gsid);

	GStation_Refresh(gsid);
	GStation_Save(gsid);
	mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO gstation SET ID='%d', owner='%s', ownerid='%d', price='%d', name='%s', posx='%f', posy='%f', posz='%f'", gsid, gsData[gsid][gsOwner], gsData[gsid][gsOwnerID], gsData[gsid][gsPrice], gsData[gsid][gsName], gsData[gsid][gsName], gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]);
	mysql_tquery(g_SQL, cQuery, "OnGstationCreated", "i", gsid);
	return 1;
}

function OnGstationCreated(playerid, gsid)
{
	GStation_Save(gsid);
	Servers(playerid, "Pom Bensin [%d] berhasil di buat!", gsid);
	new str[150];
	format(str,sizeof(str),"[Gas Station]: %s membuat business id %d!", GetRPName(playerid), gsid);
	LogServer("Admin", str);
	return 1;
}

CMD:gsmenu(playerid, params[])
{
    foreach(new gsid : GStation)
	{
        if(IsPlayerInRangeOfPoint(playerid, 4.0, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]))
        {
            if(!IsGStationOwner(playerid, gsid))
                return Error(playerid, "Anda bukan pemilik pom bensin ini");

            ShowGStationMenu(playerid, gsid);
        }
    }
    return 1;
}

ShowGStationMenu(playerid, gsid)
{
    pData[playerid][pMenuGS] = 0;
    pData[playerid][pInGS] = gsid;

    ShowPlayerDialog(playerid, GS_MENU, DIALOG_STYLE_LIST, "Gs Menu","Gs Info\nChange Name\nGs Vault\nRequest Restock","Next","Close");
    return 1;
}

CMD:buygstation(playerid, params[])
{
	foreach(new gsid : GStation)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.5, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]))
		{
			if(gsData[gsid][gsPrice] > GetPlayerMoney(playerid))
				return Error(playerid, "Not enough money, you can't afford this gas station.");

			if(strcmp(gsData[gsid][gsOwner], "-"))
				return Error(playerid, "Someone already owns this gas station.");


			GivePlayerMoneyEx(playerid, -gsData[gsid][gsPrice]);
			Server_AddMoney(gsData[gsid][gsPrice]);
	    	gsData[gsid][gsOwner] = pData[playerid][pID];
			GetPlayerName(playerid, gsData[gsid][gsOwner], MAX_PLAYER_NAME);

			GStation_Refresh(gsid);
			GStation_Save(gsid);
			new cQuery[512];
			mysql_format(g_SQL, cQuery, sizeof(cQuery), "INSERT INTO gstation SET ID='%d', owner='%s'", gsid, gsData[gsid][gsOwner]);
			mysql_tquery(g_SQL, cQuery, "OnGstationCreated", "i", gsid);
		}
	}
	return 1;
}

CMD:editgs(playerid, params[])
{
    static
        gsid,
        type[24],
        string[128];

    if(pData[playerid][pAdmin] < 4)
        return PermissionError(playerid);

    if(sscanf(params, "ds[24]S()[128]", gsid, type, string))
    {
        Usage(playerid, "/editgs [id] [name]");
        SendClientMessage(playerid, COLOR_YELLOW, "[NAMES]:{FFFFFF} location, price, reset, stock, owner, delete");
        return 1;
    }
    if((gsid < 0 || gsid >= MAX_GSTATION))
        return Error(playerid, "You have specified an invagsid ID.");
	if(!Iter_Contains(GStation, gsid)) return Error(playerid, "The gas station you specified ID of doesn't exist.");

    if(!strcmp(type, "location", true))
    {
		GetPlayerPos(playerid, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]);
        Storage_Save(gsid);
		Storage_Refresh(gsid);

        SendAdminMessage(COLOR_RED, "%s has adjusted the location of gas statio  ID: %d.", pData[playerid][pAdminname], gsid);
    }
    else if(!strcmp(type, "price", true))
    {
        new price;

        if(sscanf(string, "d", price))
            return Usage(playerid, "/editgs [id] [Price] [Amount]");

        gsData[gsid][gsPrice] = price;
		
		new cQuery[128];
		mysql_format(g_SQL, cQuery, sizeof(cQuery), "UPDATE gstation SET price='%d' WHERE ID='%d'", gsData[gsid][gsPrice], gsid);
		mysql_tquery(g_SQL, cQuery);

		GStation_Refresh(gsid);
        SendAdminMessage(COLOR_RED, "%s has adjusted the price of gstation ID: %d to %d.", pData[playerid][pAdminname], gsid, price);
    }
    else if(!strcmp(type, "reset", true))
    {
        GStation_Reset(gsid);
		GStation_Save(gsid);
		GStation_Refresh(gsid);
        SendAdminMessage(COLOR_RED, "%s has reset gas station ID: %d.", pData[playerid][pAdminname], gsid);
    }
    else if(!strcmp(type, "stock", true))
    {
        new stok;

        if(sscanf(string, "d", stok))
            return Usage(playerid, "/editgs [id] [type] [stock - 10000]");

        if(stok < 1 || stok > 10000)
            return Error(playerid, "You must specify at least 1 - 5.");

        gsData[gsid][gsStock] = stok;
        GStation_Save(gsid);
		GStation_Refresh(gsid);

        SendAdminMessage(COLOR_RED, "%s has set gs ID: %d stock to %d.", pData[playerid][pAdminname], gsid, stok);
    }
    else if(!strcmp(type, "owner", true))
    {
        new owners[MAX_PLAYER_NAME];

        if(sscanf(string, "s[24]", owners))
            return Usage(playerid, "/editgs [id] [owner] [player name] (use '-' to no owner)");

        format(gsData[gsid][gsOwner], MAX_PLAYER_NAME, owners);

        GStation_Save(gsid);
		GStation_Refresh(gsid);
        SendAdminMessage(COLOR_RED, "%s has adjusted the owner of GStation ID: %d to %s", pData[playerid][pAdminname], gsid, owners);
    }
    else if(!strcmp(type, "delete", true))
    {
    GStation_Reset(gsid);
    
		DestroyDynamic3DTextLabel(gsData[gsid][gsLabel]);
		DestroyDynamicPickup(gsData[gsid][gsPickup]);
		gsData[gsid][gsPosX] = 0;
		gsData[gsid][gsPosY] = 0;
		gsData[gsid][gsPosZ] = 0;
		gsData[gsid][gsPrice] = 0;
		gsData[gsid][gsStock] = 0;
		gsData[gsid][gsRestock] = 0;
		gsData[gsid][gsMoney] = 0;
		gsData[gsid][gsLabel] = Text3D: INVALID_3DTEXT_ID;
		gsData[gsid][gsPickup] = -1;
		Iter_Remove(GStation, gsid);
		new cQuery[128];
		mysql_format(g_SQL, cQuery, sizeof(cQuery), "DELETE FROM gstation WHERE ID=%d", gsid);
		mysql_tquery(g_SQL, cQuery);
        SendAdminMessage(COLOR_RED, "%s has delete gstation ID: %d.", pData[playerid][pAdminname], gsid);
    }
    return 1;
}

CMD:fill(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return Error(playerid, "You must driver a vehicle engine.");
	
	new vehid = GetPlayerVehicleID(playerid);
	if(!IsEngineVehicle(vehid))
            return Error(playerid, "You are not in engine vehicle.");
	
	if(GetEngineStatus(vehid))
					return Error(playerid, "Turn off vehicle engine.");
			
	if(GetVehicleFuel(vehid) >= 999.0)
		return Error(playerid, "This vehicle gas is full.");
	
	if(pData[playerid][pFill] != -1)
		return Error(playerid, "You already filling vehicle. please wait!");
		
	foreach(new gsid : GStation)
	{
		if(IsPlayerInRangeOfPoint(playerid, 4.0, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]))
		{
			if(gsData[gsid][gsStock] < 1)
				return Error(playerid, "This Gas station is out of stock!");
			
			pData[playerid][pFill] = gsid;
			pData[playerid][pFillStatus] = 1;
			pData[playerid][pFillTime] = SetTimerEx("Filling", 500, true, "i", playerid);
		}
	}
	return 1;
}

function Filling(playerid)
{
	if(pData[playerid][pFillStatus] != 1) return 0;
	foreach(new gsid : GStation)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 4.0, gsData[gsid][gsPosX], gsData[gsid][gsPosY], gsData[gsid][gsPosZ]) && !IsPlayerInAnyVehicle(playerid) || GetVehicleFuel(GetPlayerVehicleID(playerid)) >= 999.0 || GetPlayerMoney(playerid) < GStationPrice)
		{
			StopFilling(playerid);
			return 1;
		}
		else
		{
			if(GetEngineStatus(GetPlayerVehicleID(playerid)))
					return StopFilling(playerid);
			new old = GetVehicleFuel(GetPlayerVehicleID(playerid));
			SetVehicleFuel(GetPlayerVehicleID(playerid), old + 200);
			pData[playerid][pFillPrice] += GStationPrice;
			gsData[pData[playerid][pFill]][gsStock] -= 10;
			if(GetVehicleFuel(GetPlayerVehicleID(playerid)) >= 999.0)
			{
				SetVehicleFuel(GetPlayerVehicleID(playerid), 1000);
			}
			return 1;
		}
	}
	return 1;
}

StopFilling(playerid)
{
	new gsid = pData[playerid][pFill];
	GivePlayerMoneyEx(playerid, -pData[playerid][pFillPrice]);
	GStation_Refresh(gsid);
	Info(playerid,"Tangki kendaraan anda sudah terisi seharga "RED_E"%s.", FormatMoney(pData[playerid][pFillPrice]));
	
	new cQuery[512];
	mysql_format(g_SQL, cQuery, sizeof(cQuery), "UPDATE gstation SET stock='%d', money='%d' WHERE ID='%d'", gsData[gsid][gsStock], gsData[gsid][gsMoney], gsid);
	mysql_tquery(g_SQL, cQuery);

	KillTimer(pData[playerid][pFillTime]);
	pData[playerid][pFillStatus] = 0;
	pData[playerid][pFillPrice] = 0;
	pData[playerid][pFill] = -1;
	return 1;
}