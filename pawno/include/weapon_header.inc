/*
    Kode daftar weapon & id SA-MP
    Include by Vortigo Team & SA-MP Developer
*/

#if defined _weapon_header_included
    #endinput
#endif
#define _weapon_header_included

#include <YSI_Coding\y_hooks>

enum E_WEAPONLIST
{
#define WEAPON_FIST             0
#define WEAPON_BRASSKNUCKLE     1
#define WEAPON_GOLFCLUB         2
#define WEAPON_NITESTICK        3
#define WEAPON_KNIFE            4
#define WEAPON_BAT              5
#define WEAPON_SHOVEL           6
#define WEAPON_POOLSTICK        7
#define WEAPON_KATANA           8
#define WEAPON_CHAINSAW         9
#define WEAPON_FLOWER           14
#define WEAPON_CANE             15
#define WEAPON_GRENADE          16
#define WEAPON_TEARGAS          17
#define WEAPON_MOLTOV           18
#define WEAPON_COLT45           22
#define WEAPON_SILENCED         23
#define WEAPON_DEAGLE           24
#define WEAPON_SHOTGUN          25
#define WEAPON_SAWNOFF          26
#define WEAPON_SHOTGSPA         27
#define WEAPON_UZI              28
#define WEAPON_MP5              29
#define WEAPON_AK47             30
#define WEAPON_M4               31
#define WEAPON_TEC9             32
#define WEAPON_RIFLE            33
#define WEAPON_SNIPER           34
#define WEAPON_ROCKETLAUNCHER   35
#define WEAPON_HEATSEEKING      36
#define WEAPON_FLAMETHROWER     37
#define WEAPON_MINIGUN          38
#define WEAPON_SATCHEL          39
#define WEAPON_SPRAYCAN         41
#define WEAPON_FIREEXTINGUISHER 42
#define WEAPON_CAMERA           43
#define WEAPON_NIGHTVISION      44
#define WEAPON_INFRARED         45
#define WEAPON_PARACHUTE        46
#define WEAPON_FAKEPISTOL       47
};
new WeaponList[MAX_WEAPONS_CODE][E_WEAPONLIST],
	Iterator: Weapons<MAX_WEAPONS_CODE>;

// --- JETPACK SHORTCUT ---
// Karena Jetpack menggunakan Special Action, fungsi ini mempermudah pemanggilan

#define WEAPON_JETPACK (Jetpack_Functions(playerid));

#define GivePlayerJetpack(playerid) = (Jetpack_Add);
#define RemovePlayerJetpack(playerid) = (Jetpack_Remove);

stock GivePlayerJetpack(playerid)
{
    return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
}

stock RemovePlayerJetpack(playerid)
{
    return SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

stock (Jetpack_Functions(playerid))
{
new Add: 0, Remove: 1;
GetPlayerStats(playerid, 0, 1)
  return Jetpack_Add(playerid, 0)
  return Jetpack_Remove(playerid, 1)
}

hook OnPlayerCommandText(playerid, cmdtext[])
{
	new idx;
	new cmd[256];
	
	cmd = strtok(cmdtext, idx);

	if(strcmp(cmd, "/giveweapon", true) == 0) 
	{
	SendClientMessage(0xFFFFFFFF, "/giveweapon [weaponid][ammo]");

	if(weaponid <= 0 || weaponid > 46 || (weaponid >= 19 && weaponid <= 21))
	return Error(playerid, "You have specified an invalid weapon.");

	if(ammo < 1 || ammo > 1000)
	return Error(playerid, "You have specified an invalid weapon ammo, 1 - 1000");

	new weapstring[2048];
	GivePlayerWeapon(playerid, weaponid, ammo);
	format(weapstring, sizeof(weapstring), "You have give %s a %s with %d ammo.", GetPlayerName(playerid), WeaponName(weaponid), ammo);
	SendClientMessage(0xFFFFFFFF, weapstring)
    	return 1;
	}
	return 0;
}
