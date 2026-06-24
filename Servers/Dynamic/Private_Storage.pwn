#define MAX_STORAGE 50
#define MAX_STORAGE_INT 7000

enum stinfo
{
	stOwner[MAX_PLAYER_NAME],
	stPrice,
	stComponent,
	stMaterial,
	stMoney,
	Float:stPosX,
	Float:stPosY,
	Float:stPosZ,
	Text3D:stLabel,
	stPickup,
};

new stData[MAX_STORAGE][stinfo],
	Iterator: Storage<MAX_STORAGE>;

Storage_Refresh(stid)
{
	if(stid != -1)
    {
        if(IsValidDynamic3DTextLabel(stData[stid][stLabel]))
            DestroyDynamic3DTextLabel(stData[stid][stLabel]);

        if(IsValidDynamicPickup(stData[stid][stPickup]))
            DestroyDynamicPickup(stData[stid][stPickup]);

		new tstr[558];
		if(stData[stid][stPosX] != 0 && stData[stid][stPosY] != 0 && stData[stid][stPosZ] != 0 && strcmp(stData[stid][stOwner], "-"))
		{
            format(tstr, sizeof tstr,"{ffffff}ID: %d\n{ffff00}%s\n{00ffff}`/smenu`\n{00ffff}Private storage", stid, stData[stid][stOwner]);

			stData[stid][stPickup] = CreateDynamicPickup(1277, 23, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]+0.2, -1, -1, -1, 5.0);
			stData[stid][stLabel] = CreateDynamic3DTextLabel(tstr, COLOR_GREEN, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]+0.5, 4.5);
		}
		else if(stData[stid][stPosX] != 0 && stData[stid][stPosY] != 0 && stData[stid][stPosZ] != 0)
		{
	        format(tstr, sizeof tstr,"{00ffff}ID: %d\n{ffffff}Price: {ffff00}%s\n{ffff00}`/buystorage`", stid, FormatMoney(stData[stid][stPrice]));

			stData[stid][stPickup] = CreateDynamicPickup(1277, 23, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]+0.2, -1, -1, -1, 5.0);
			stData[stid][stLabel] = CreateDynamic3DTextLabel(tstr, COLOR_GREEN, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]+0.5, 4.5);
   		}
   		
	}
    return 1;
}

function LoadStorage()
{
    static stid;

	new rows = cache_num_rows(), owner[MAX_PLAYER_NAME];
 	if(rows)
  	{
		for(new i; i < rows; i++)
		{
			cache_get_value_name_int(i, "id", stid);
			cache_get_value_name(i, "owner", owner);
			format(stData[stid][stOwner], MAX_PLAYER_NAME, owner);
			cache_get_value_name_int(i, "price", stData[stid][stPrice]);
			cache_get_value_name_int(i, "component", stData[stid][stComponent]);
			cache_get_value_name_int(i, "material", stData[stid][stMaterial]);
            cache_get_value_name_int(i, "money", stData[stid][stMoney]);
			cache_get_value_name_float(i, "posx", stData[stid][stPosX]);
			cache_get_value_name_float(i, "posy", stData[stid][stPosY]);
			cache_get_value_name_float(i, "posz", stData[stid][stPosZ]);
			Storage_Refresh(stid);
			Iter_Add(Storage, stid);
		}
		printf("Storage Load %d.", rows);
	}
}

IsStorageOwner(playerid, stid)
{
    if(!strcmp(stData[stid][stOwner], pData[playerid][pName], true))
        return 1;

    return 0;
}


Storage_Save(stid)
{
	new cQuery[512];
	format(cQuery, sizeof(cQuery), "UPDATE storage SET owner='%s', price='%d', component='%d', materail='%d', money='%d', posx='%f', posy='%f', posz='%f' WHERE ID='%d'",
	stData[stid][stOwner],
	stData[stid][stPrice],
	stData[stid][stComponent],
	stData[stid][stMaterial],
	stData[stid][stMoney],
	stData[stid][stPosX],
	stData[stid][stPosY],
	stData[stid][stPosZ],
	stid);
	return mysql_tquery(g_SQL, cQuery);
}

CMD:createstorage(playerid, params[])
{
	if(pData[playerid][pAdmin] < 10)
		return PermissionError(playerid);

	new query[512];
	new stid = Iter_Free(Storage);

	new price;
	if(sscanf(params, "d", price))
		return Usage(playerid, "/createstorage [price]");

	if((stid < 0 || stid >= MAX_STORAGE))
        return Error(playerid, "You have already input in this server.");

	format(stData[stid][stOwner], 128, "-");
	GetPlayerPos(playerid, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]);
	

	stData[stid][stPrice] = price;

	Iter_Add(Storage, stid);

	Storage_Refresh(stid);
	Storage_Save(stid);
	mysql_format(g_SQL, query, sizeof(query), "INSERT INTO storage SET ID='%d', owner='%s', price='%d'", stid, stData[stid][stOwner], stData[stid][stPrice]);
	mysql_tquery(g_SQL, query, "OnStorageCreated", "i", stid);
	return 1;
}

function OnStorageCreated(stid)
{
	Storage_Save(stid);
	return 1;
}

CMD:smenu(playerid, params[])
{
    foreach(new stid : Storage)
	{
        if(IsPlayerInRangeOfPoint(playerid, 4.0, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]))
        {
            if(!IsStorageOwner(playerid, stid))
                return Error(playerid, "Anda bukan pemilik storage ini");

            ShowStorageMenu(playerid, stid);
        }
    }
    return 1;
}

ShowStorageMenu(playerid, stid)
{
    pData[playerid][pMenuType] = 0;
    pData[playerid][pInSt] = stid;

    new str[256], vstr[64];
    format(vstr, sizeof vstr,"Storage");
    format(str, sizeof str,"Component\t(%d/%d)\nMaterial\t(%d/%d)\nMoney\t({00ff00}%s{ffffff})",
        stData[stid][stComponent],
        MAX_STORAGE_INT,
        stData[stid][stMaterial],
        MAX_STORAGE_INT,
        FormatMoney(stData[stid][stMoney]));
    ShowPlayerDialog(playerid, ST_MENU, DIALOG_STYLE_LIST, vstr, str, "Select", "Cancel");
    return 1;
}

CMD:buystorage(playerid, params[])
{
	foreach(new stid : Storage)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.5, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]))
		{
			if(stData[stid][stPrice] > GetPlayerMoney(playerid))
				return Error(playerid, "Not enough money, you can't afford this storage.");

			if(strcmp(stData[stid][stOwner], "-"))
				return Error(playerid, "Someone already owns this storage.");


			GivePlayerMoneyEx(playerid, -stData[stid][stPrice]);
			Server_AddMoney(stData[stid][stPrice]);
	    	stData[stid][stOwner] = pData[playerid][pID];
			GetPlayerName(playerid, stData[stid][stOwner], MAX_PLAYER_NAME);

			Storage_Refresh(stid);
			Storage_Save(stid);
			new query[512];
			mysql_format(g_SQL, query, sizeof(query), "INSERT INTO storage SET ID='%d', owner='%s'", stid, stData[stid][stOwner]);
			mysql_tquery(g_SQL, query, "OnStorageCreated", "i", stid);
		}
	}
	return 1;
}


CMD:editstorage(playerid, params[])
{
    static
        stid,
        type[24],
        string[128];

    if(pData[playerid][pAdmin] < 10)
        return PermissionError(playerid);

    if(sscanf(params, "ds[24]S()[128]", stid, type, string))
    {
        Usage(playerid, "/editstorage [id] [name]");
        SendClientMessage(playerid, COLOR_YELLOW, "[NAMES]:{FFFFFF} location, price, delete");
        return 1;
    }
    if((stid < 0 || stid >= MAX_STORAGE))
        return Error(playerid, "You have specified an invagsid ID.");
	if(!Iter_Contains(Storage, stid)) return Error(playerid, "The doors you specified ID of doesn't exist.");

    if(!strcmp(type, "location", true))
    {
		GetPlayerPos(playerid, stData[stid][stPosX], stData[stid][stPosY], stData[stid][stPosZ]);
        Storage_Save(stid);
		Storage_Refresh(stid);

        SendAdminMessage(COLOR_RED, "%s has adjusted the location of storage ID: %d.", pData[playerid][pAdminname], stid);
    }
    else if(!strcmp(type, "price", true))
    {
        new stok;

        if(sscanf(string, "d", stok))
            return Usage(playerid, "/editstorage [id] [type] [Price]");

        stData[stid][stPrice] = stok;
        Storage_Save(stid);
		Storage_Refresh(stid);

        SendAdminMessage(COLOR_RED, "%s has set storage ID: %d price to %d.", pData[playerid][pAdminname], stid, stok);
    }
    else if(!strcmp(type, "owner", true))
    {
        new owners[MAX_PLAYER_NAME];

        if(sscanf(string, "s[24]", owners))
            return Usage(playerid, "/editstorage [id] [owner] [player name] (use '-' to no owner)");

        format(stData[stid][stOwner], MAX_PLAYER_NAME, owners);

        Storage_Save(stid);
		Storage_Refresh(stid);
        SendAdminMessage(COLOR_RED, "%s has adjusted the owner of Workshop ID: %d to %s", pData[playerid][pAdminname], stid, owners);
    }
    else if(!strcmp(type, "delete", true))
    {
		new query[128];
		DestroyDynamic3DTextLabel(stData[stid][stLabel]);
		DestroyDynamicPickup(stData[stid][stPickup]);
		stData[stid][stPosX] = 0;
		stData[stid][stPosY] = 0;
		stData[stid][stPosY] = 0;
		stData[stid][stPrice] = 0;
		stData[stid][stComponent] = 0;
		stData[stid][stMaterial] = 0;
		stData[stid][stMoney] = 0;
		stData[stid][stLabel] = Text3D: INVALID_3DTEXT_ID;
		stData[stid][stPickup] = -1;
		Iter_Remove(Storage, stid);
		mysql_format(g_SQL, query, sizeof(query), "DELETE FROM storage WHERE ID=%d", stid);
		mysql_tquery(g_SQL, query);
        SendAdminMessage(COLOR_RED, "%s has delete storage ID: %d.", pData[playerid][pAdminname], stid);
    }
    return 1;
}

	if(dialogid == ST_MENU)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					ShowPlayerDialog(playerid, ST_COMPONENT, DIALOG_STYLE_LIST, "Storage Component", "Withdraw\nDeposit", "Select","Cancel");
				}
				case 1:
				{
					ShowPlayerDialog(playerid, ST_MATERIAL, DIALOG_STYLE_LIST, "Storage Material", "Withdraw\nDeposit", "Select","Cancel");
				}
				case 2:
				{
					ShowPlayerDialog(playerid, ST_MONEY, DIALOG_STYLE_LIST, "Storage Money", "Withdraw\nDeposit", "Select","Cancel");
				}
			}
		}
	}
	if(dialogid == ST_COMPONENT)
	{
		if(response)
		{
			new str[256], stid = pData[playerid][pInSt];
			switch(listitem)
			{
				case 0:
				{
					pData[playerid][pMenuType] = 1;
					format(str, sizeof str,"Component: %d\n\nPlease Input amount to Withdraw", stData[stid][stComponent]);
				}
				case 1:
				{
					pData[playerid][pMenuType] = 2;
					format(str, sizeof str,"Component: %d\n\nPlease Input amount to Deposit", stData[stid][stComponent]);
				}
			}
			ShowPlayerDialog(playerid, ST_COMPONENT2, DIALOG_STYLE_INPUT, "Component Menu", str, "Input","Cancel");
		}
	}
	if(dialogid == ST_COMPONENT2)
	{
		if(response)
		{
			new amount = strval(inputtext), stid = pData[playerid][pInSt];
			if(pData[playerid][pMenuType] == 1)
			{
				if(amount < 1)
					return Error(playerid, "Minimum amount is 1");

				if(stData[stid][stComponent] < amount) return Error(playerid, "Not Enough Workshop Component");

				if((pData[playerid][pComponent] + amount) >= 501)
					return Error(playerid, "You've reached maximum of Component");

				pData[playerid][pComponent] += amount;
				stData[stid][stComponent] -= amount;
				Storage_Save(stid);
				Info(playerid, "Anda berhasil mengambil Component Sebesar %d", amount);
			}
			else if(pData[playerid][pMenuType] == 2)
			{
				if(amount < 1)
					return Error(playerid, "Minimum amount is 1");

				if(pData[playerid][pComponent] < amount) return Error(playerid, "Not Enough Component");

				if((stData[stid][stComponent] + amount) >= MAX_STORAGE_INT)
					return Error(playerid, "You've reached maximum of Component");

				pData[playerid][pComponent] -= amount;
				stData[stid][stComponent] += amount;
				Storage_Save(stid);
				Info(playerid, "Anda menaruh Component sebesar %d", amount);
			}
		}
	}
	if(dialogid == ST_MATERIAL)
	{
		if(response)
		{
			new str[256], stid = pData[playerid][pInSt];
			switch(listitem)
			{
				case 0:
				{
					pData[playerid][pMenuType] = 1;
					format(str, sizeof str,"Material: %d\n\nPlease Input amount to Withdraw", stData[stid][stMaterial]);
				}
				case 1:
				{
					pData[playerid][pMenuType] = 2;
					format(str, sizeof str,"Material: %d\n\nPlease Input amount to Deposit", stData[stid][stMaterial]);
				}
			}
			ShowPlayerDialog(playerid, ST_MATERIAL2, DIALOG_STYLE_INPUT, "Material Menu", str, "Input","Cancel");
		}
	}
	if(dialogid == ST_MATERIAL2)
	{
		if(response)
		{
			new amount = strval(inputtext), stid = pData[playerid][pInSt];
			if(pData[playerid][pMenuType] == 1)
			{
				if(amount < 1)
					return Error(playerid, "Minimum amount is 1");

				if(stData[stid][stMaterial] < amount) return Error(playerid, "Not Enough Material");

				if((pData[playerid][pMaterial] + amount) >= 500)
					return Error(playerid, "You've reached maximum of Material");

				pData[playerid][pMaterial] += amount;
				stData[stid][stMaterial] -= amount;
				Storage_Save(stid);
				Info(playerid, "Anda berhasil mengambil material sebesar %d", amount);
			}
			else if(pData[playerid][pMenuType] == 2)
			{
				if(amount < 1)
					return Error(playerid, "Minimum amount is 1");

				if(pData[playerid][pMaterial] < amount) return Error(playerid, "Not Enough Material");

				if((stData[stid][stMaterial] + amount) >= MAX_STORAGE_INT)
					return Error(playerid, "You've reached maximum of Material");

				pData[playerid][pMaterial] -= amount;
				stData[stid][stMaterial] += amount;
				Storage_Save(stid);
				Info(playerid, "Anda berhasil menaruh material sebesar %d", amount);
			}
		}
	}
	if(dialogid == ST_MONEY)
	{
		if(response)
		{
			new str[264], stid = pData[playerid][pInSt];
			switch(listitem)
			{
				case 0:
				{/*
					if(!IsStorageOwner(playerid, stid))
						return Error(playerid, "Only Workshop Owner who can use this");*/

					format(str, sizeof str, "Money:\n{7fff00}%s\n\n{ffffff}Input Amount to Withdraw", FormatMoney(stData[stid][stMoney]));
					ShowPlayerDialog(playerid, ST_WITHDRAWMONEY, DIALOG_STYLE_INPUT, "Withdraw Money",str,"Withdraw","Cancel");
				}
				case 1:
				{
					format(str, sizeof str, "Money:\n{7fff00}%s\n\n{ffffff}Input Amount to Deposit", FormatMoney(stData[stid][stMoney]));
					ShowPlayerDialog(playerid, ST_DEPOSITMONEY, DIALOG_STYLE_INPUT, "Deposit Money",str,"Deposit","Cancel");
				}
			}
		}
	}
	if(dialogid == ST_WITHDRAWMONEY)
	{
		if(response)
		{
			new amount = strval(inputtext), stid = pData[playerid][pInSt];

			if(amount < 1)
				return Error(playerid, "Minimum amount is $1");

			if(stData[stid][stMoney] < amount)
				return Error(playerid, "Not Enough Money");

			GivePlayerMoneyEx(playerid, amount);
			stData[stid][stMoney] -= amount;
			Storage_Save(stid);
		}
	}
	if(dialogid == ST_DEPOSITMONEY)
	{
		if(response)
		{
			new amount = strval(inputtext), stid = pData[playerid][pInSt];

			if(amount < 1)
				return Error(playerid, "Minimum amount is $1");

			if(pData[playerid][pMoney] < amount)
				return Error(playerid, "Not Enough Money");

			GivePlayerMoneyEx(playerid, -amount);
			stData[stid][stMoney] += amount;
			Storage_Save(stid);
		}
	}