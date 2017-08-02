#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <lastrequest>
#include <simon>
#include <smartjaildoors>
#include <emitsoundany>
#include <basecomm>

#define PLUGIN_VERSION "7.0"

#define DEFAULT_FLAGS 	FCVAR_NOTIFY

Handle g_hMenu = INVALID_HANDLE;
bool g_bMenu;
bool showMenu;
bool FD[MAXPLAYERS+1] = {false,...};
bool FD2All;
int Second;
bool IsRunning = false;
Handle CD = INVALID_HANDLE;
Handle FreedayOver = INVALID_HANDLE;
Handle g_hFreedayTime = INVALID_HANDLE;
int g_fFreedayTime;
bool Rebel[MAXPLAYERS+1] = {false,...};

public Plugin myinfo =
{
	name = "Jailbreak Menu",
	author = "Simon",
	description = "Jailbreak Simon Add-on",
	version = PLUGIN_VERSION,
	url = "yash1441@yahoo.com"
};

public OnPluginStart()
{
	CreateConVar("jb_menu_version", PLUGIN_VERSION, "Jailbreak Menu Version", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_hMenu = CreateConVar("jb_menu_enabled", "1", "0 - disable, 1 - enable", DEFAULT_FLAGS, true, 0.0, true, 1.0);
	g_hFreedayTime = CreateConVar("jb_freeday_time", "3.0", "Duration of a Freeday in float in minutes.", DEFAULT_FLAGS);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Player_Spawn);
	
	RegConsoleCmd("sm_menu", Cmd_Menu);
	RegAdminCmd("sm_amenu", Cmd_Amenu, ADMFLAG_GENERIC);
	
	RegConsoleCmd("sm_cells", ToggleCells);
	RegConsoleCmd("sm_fd", Freeday);
	RegConsoleCmd("sm_freeday", Freeday);
	RegConsoleCmd("sm_divide", TeamManagement);
	RegConsoleCmd("sm_givehp", GiveHealth);
	RegConsoleCmd("sm_countdown", StartCountdown);
	RegConsoleCmd("sm_rebels", CheckRebels);
	
	g_bMenu = GetConVarBool(g_hMenu);
	g_fFreedayTime = GetConVarInt(g_hFreedayTime);
	HookConVarChange(g_hMenu, OnConVarChanged);
	HookConVarChange(g_hFreedayTime, OnConVarChanged);
}

public void OnMapStart()
{
	AddFileToDownloadsTable("sound/Simon/0.mp3");
	AddFileToDownloadsTable("sound/Simon/1.mp3");
	AddFileToDownloadsTable("sound/Simon/2.mp3");
	AddFileToDownloadsTable("sound/Simon/3.mp3");
	AddFileToDownloadsTable("sound/Simon/4.mp3");
	AddFileToDownloadsTable("sound/Simon/5.mp3");
	AddFileToDownloadsTable("sound/Simon/6.mp3");
	AddFileToDownloadsTable("sound/Simon/7.mp3");
	AddFileToDownloadsTable("sound/Simon/8.mp3");
	AddFileToDownloadsTable("sound/Simon/9.mp3");
	AddFileToDownloadsTable("sound/Simon/10.mp3");
	PrecacheSoundAny("Simon/0.mp3");
	PrecacheSoundAny("Simon/1.mp3");
	PrecacheSoundAny("Simon/2.mp3");
	PrecacheSoundAny("Simon/3.mp3");
	PrecacheSoundAny("Simon/4.mp3");
	PrecacheSoundAny("Simon/5.mp3");
	PrecacheSoundAny("Simon/6.mp3");
	PrecacheSoundAny("Simon/7.mp3");
	PrecacheSoundAny("Simon/8.mp3");
	PrecacheSoundAny("Simon/9.mp3");
	PrecacheSoundAny("Simon/10.mp3");
}

public void OnConVarChanged(Handle convar, const char[] oldValue, const char[] intValue)
{
	if (convar == g_hMenu)
	{
		g_bMenu = GetConVarBool(g_hMenu);
	}
	else if (convar == g_hFreedayTime)
	{
		g_fFreedayTime = StringToInt(intValue);
	}
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	showMenu = true;
	IsRunning = false;
	FD2All = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		Rebel[i] = false;
		FD[i] = false;
	}
}

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if (FreedayOver != INVALID_HANDLE)
		CloseHandle(FreedayOver);
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	FD[client] = false;
	Rebel[client] = false;
}

public Player_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client))
		return;
	if (GetClientTeam(client) == 3)
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action ToggleCells(int client, int args)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client) || FD2All)
		return Plugin_Handled;

	SJD_ToggleExDoors();

	PrintToChatAll(" \x04[JS] \x05%N toggled the cell doors.", client);
	return Plugin_Handled;
}

public Action Cmd_Menu(int client, int args)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client) || g_bMenu == false || showMenu == false)
		return Plugin_Handled;
	
	DID(client);
	return Plugin_Handled;
}

public Action Cmd_Amenu(int client, int args)
{
	if (!IsValidClient(client) || g_bMenu == false)
		return Plugin_Handled;
	
	DIDAdmin(client);
	return Plugin_Handled;
}

public Action Freeday(int client, int args)
{
	if (!IsPlayerAlive(client) || !IsValidClient(client) || FD2All)
		return Plugin_Handled;
	
	FreedayMenu(client);
	return Plugin_Handled;
}

public Action TeamManagement(int client, int args)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client) || FD2All)
		return Plugin_Handled;
	
	TeamMenu(client);
	return Plugin_Handled;
}

public Action GiveHealth(int client, int args)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client))
		return Plugin_Handled;
	
	GiveHP(client);
	return Plugin_Handled;
}

public Action GiveHP(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			SetEntityHealth(i, 100);
		}
	}
	PrintToChatAll(" \x04[JS] \x05%N gave 100 HP to Prisoners.", client);
}

public Action StartCountdown(int client, int args)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client))
		return Plugin_Handled;

	if(args < 1)
	{
		Countdown(client, 10);
	}
	else
	{
		char Temp[64];
		GetCmdArg(1, Temp, sizeof(Temp));
		Countdown(client, StringToInt(Temp, 10));
	}
	return Plugin_Handled;
}

public Action CheckRebels(int client, int args)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client))
		return Plugin_Handled;
	else
		Rebels(client);
	return Plugin_Handled;
}

public Action Countdown(int client, int duration)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client))
		return Plugin_Handled;
	if (IsRunning)
	{
		PrintToChat(client, " \x04[JS] \x05Wait for the on-going Countdown to finish.")
		return Plugin_Handled;
	}
	if (duration < 0 || duration > 100)
	{
		PrintToChat(client, " \x04[JS] \x05Duration of the Countdown can only be from 0 till 100.")
		return Plugin_Handled;
	}
	Second = duration;
	PrintToChatAll(" \x04[JS] \x05%N initiated a Countdown of \x01%i \x05seconds.", client, Second);
	IsRunning = true;
	CD = CreateTimer(1.0, Timer_CountDown, _, TIMER_REPEAT);
	return Plugin_Handled;
}

/// MENU STUFF ///
public Action DIDAdmin(int clientId) 
{
	Handle menu = CreateMenu(DIDAmenuHandler);
	SetMenuTitle(menu, "Jailbreak Simon - ADMIN");
	AddMenuItem(menu, "cells", "Open Cells");
	AddMenuItem(menu, "freeday", "Freeday");
	if (FD2All)
		AddMenuItem(menu, "box", "Box", ITEMDRAW_DISABLED);
	else if (!FD2All)
		AddMenuItem(menu, "box", "Box");
	AddMenuItem(menu, "special", "Give Special Day", ITEMDRAW_DISABLED);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, clientId, 15);
}

public int DIDAmenuHandler(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select) 
	{
		if (!IsValidClient(client) || g_bMenu == false)
			return;
			
		char info[11];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info,"cells") == 0) 
		{
			ClientCommand(client, "sm_cells");
			DIDAdmin(client);
		}
		if (strcmp(info,"box") == 0) 
		{
			ClientCommand(client, "sm_box");
		}
		if (strcmp(info,"freeday") == 0) 
		{
			FreedayMenu(client);
		}
		/*if (strcmp(info,"special") == 0) 
		{
			SpecialDay(client);
		}*/
	}
}

public Action DID(int clientId) 
{
	Handle menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Jailbreak Simon");
	
	if (!simon_exist())
		AddMenuItem(menu, "simon", "Become Simon");
	if (simon_issimon(clientId))
		AddMenuItem(menu, "retire", "Retire");
	if (!simon_issimon(clientId) && simon_exist())
		AddMenuItem(menu, "disable", "Become Simon / Retire", ITEMDRAW_DISABLED);
	
	AddMenuItem(menu, "cells", "Open Cells");
	if (FD2All)
		AddMenuItem(menu, "freeday", "Freeday", ITEMDRAW_DISABLED);
	else if (!FD2All)
		AddMenuItem(menu, "freeday", "Freeday");

	if (FD2All)
		AddMenuItem(menu, "team", "Team Management", ITEMDRAW_DISABLED);
	else if (!FD2All)
		AddMenuItem(menu, "team", "Team Management");

	if (FD2All)
		AddMenuItem(menu, "box", "Box", ITEMDRAW_DISABLED);
	else if (!FD2All)
		AddMenuItem(menu, "box", "Box");

	AddMenuItem(menu, "countdown", "Countdown");
	AddMenuItem(menu, "hp", "Give 100 HP to Prisoners");

	if (FD2All)
		AddMenuItem(menu, "mute", "Turn Prisoner Mic On/Off", ITEMDRAW_DISABLED);
	else if (!FD2All)
		AddMenuItem(menu, "mute", "Turn Prisoner Mic On/Off");
	
	AddMenuItem(menu, "rebels", "Check Active Rebels");
	//AddMenuItem(menu, "music", "Music");
	AddMenuItem(menu, "special", "Give Special Day", ITEMDRAW_DISABLED);

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, clientId, 15);
}

public int DIDMenuHandler(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select)
	{
		if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client) || g_bMenu == false || showMenu == false)
			return;
			
		char info[11];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info,"simon") == 0) 
		{
			simon_set(client);
			DID(client);
		}
		if (strcmp(info,"retire") == 0) 
		{
			simon_remove(client);
			DID(client);
		}
		if (strcmp(info,"cells") == 0) 
		{
			ClientCommand(client, "sm_cells");
			DID(client);
		}
		if (strcmp(info,"freeday") == 0) 
		{
			FreedayMenu(client);
		}
		if (strcmp(info,"team") == 0) 
		{
			TeamMenu(client);
		}
		if (strcmp(info,"box") == 0) 
		{
			ClientCommand(client, "sm_box");
		}
		if (strcmp(info,"countdown") == 0) 
		{
			Countdown(client, 10);
		}
		if (strcmp(info,"hp") == 0) 
		{
			GiveHP(client);
		}
		if (strcmp(info,"mute") == 0) 
		{
			MutePeople(client);
		}
		if (strcmp(info,"rebels") == 0)
		{
			Rebels(client);
		}
		/*if (strcmp(info,"music") == 0) 
		{
			Music(client);
		}*/
		/*if (strcmp(info,"special") == 0) 
		{
			SpecialDay(client);
		}*/
	}
}

public Action Rebels(int client)
{
	if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client))
		return Plugin_Handled;
	Handle menu = CreateMenu(RebelHandler);
	SetMenuTitle(menu, "Active Rebels:");
	
	char temp2[8];
	char temp[128];
	int count = 0;
	for (int i = 1; i < MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && Rebel[i]) 
		{
			Format(temp, 128, "%N", i);
			Format(temp2, 8, "%i", i);
			AddMenuItem(menu, temp2, temp);
			
			count++;
		}
	}
	if(count == 0)
	{
		AddMenuItem(menu, "none", "No Active Rebel", ITEMDRAW_DISABLED);
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public int RebelHandler(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if (!IsPlayerAlive(client) || !IsValidClient(client) || !showMenu)
			return;
		else
			ClientCommand(client, "sm_menu");
	}
}

public Action MutePeople(client)
{
	Handle menu = CreateMenu(MuteHandler);
	SetMenuTitle(menu, "Toggle Prisoner Mic For:");
	char temp2[8];
	char temp[128];
	for (int i = 1; i < MaxClients; i++)
	if(IsValidClient(i) && GetClientTeam(i) == 2) 
	{
		Format(temp, 128, "%N", i);
		Format(temp2, 8, "%i", i);
		AddMenuItem(menu, temp2, temp);
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int MuteHandler(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select)
	{
		if (!IsPlayerAlive(client) || !IsValidClient(client) || !showMenu || FD2All)
			return;
		
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		int i = StringToInt(info);
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2) 
		{
			if (BaseComm_IsClientMuted(i))
			{
				BaseComm_SetClientMute(client, false);
				PrintToChatAll(" \x04[JS] \x05%N turned \x01ON\x05 mic for \x01%N", client, i);
			}
			else if(!BaseComm_IsClientMuted(i))
			{
				BaseComm_SetClientMute(client, true);
				PrintToChatAll(" \x04[JS] \x05%N turned \x01OFF\x05 mic for \x01%N", client, i);
			}
			ClientCommand(client, "sm_menu");
		}
		else 
		{
			PrintToChat(client, " \x04[JS] \x05Can't turn on/off mic for that player.");
			FDMenu2(client);
		}
		
	}
}

public Action TeamMenu(int client)
{
	Handle menu = CreateMenu(TeamHandler);
	SetMenuTitle(menu, "Divide Team :");
	AddMenuItem(menu, "two", "In 2 Teams");
	AddMenuItem(menu, "three", "In 3 Teams");
	AddMenuItem(menu, "four", "In 4 Teams");
	AddMenuItem(menu, "remove", "Remove Divisions");
	DisplayMenu(menu, client, 15);
}

public int TeamHandler(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if (GetClientTeam(client) != 3 || !IsPlayerAlive(client) || !IsValidClient(client) || showMenu == false || FD2All == true)
			return;
		
		char info[11];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info,"two") == 0) 
		{
			DivideTeams(client, 2);
		}
		if (strcmp(info,"three") == 0) 
		{
			DivideTeams(client, 3);
		}
		if (strcmp(info,"four") == 0) 
		{
			DivideTeams(client, 4);
		}
		if (strcmp(info,"remove") == 0) 
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
					SetEntityRenderColor(i, 255, 255, 255, 255);
			}
			PrintToChatAll(" \x04[JS] \x05%N removed the divisions.", client);
		}
	}
}

public Action FreedayMenu(int client)
{
	Handle menu = CreateMenu(FreedayHandler);
	SetMenuTitle(menu, "Give Freeday To :");
	AddMenuItem(menu, "all", "Everyone");
	AddMenuItem(menu, "specific", "Specific People");
	DisplayMenu(menu, client, 15);
}

public int FreedayHandler(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if (!IsPlayerAlive(client) || !IsValidClient(client) || !showMenu || FD2All)
			return;
		
		char info[11];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info,"all") == 0) 
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
				{
					BaseComm_SetClientMute(i, false);
					SetEntityRenderColor(i, 0, 255, 0, 255);
					FD[i] = true;
				}
			}
			FD2All = true;
			PrintToChatAll(" \x04[JS] \x05%N gave Freeday to ALL.", client);
			SJD_OpenDoors();
			FreedayOver = CreateTimer(g_fFreedayTime * 60.0, Timer_Freeday, 0, TIMER_FLAG_NO_MAPCHANGE);
		}
		if (strcmp(info,"specific") == 0) 
		{
			//PrintToChatAll(" \x04[JS] \x05%N gave Freeday to NOBODY.", client);
			FD2All = false;
			FDMenu2(client);
		}
	}
}

public void FDMenu2(int client)
{
	Handle menu = CreateMenu(FDMenu2Handler);
	SetMenuTitle(menu, "Give Freeday To:");
	
	char temp2[8];
	char temp[128];
	int count = 0;
	for (int i = 1; i < MaxClients; i++)
	if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && !FD[i]) 
		{
			Format(temp, 128, "%N", i);
			Format(temp2, 8, "%i", i);
			AddMenuItem(menu, temp2, temp);
			
			count++;
		}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	if(count == 0)
	{
		PrintToChat(client, " \x04[JS] \x05No player available for Freeday.");
		ClientCommand(client, "sm_menu");
	}
}

public int FDMenu2Handler(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select) 
	{
		if (!IsPlayerAlive(client) || !IsValidClient(client) || !showMenu || FD2All)
			return;
		
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		int i = StringToInt(info);
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && !FD[i]) 
		{
			FD[i] = true;
			SetEntityRenderColor(i, 0, 255, 0, 255);
			PrintToChatAll(" \x04[JS] \x05%N gave Freeday to \x01%N", client, i);
			ClientCommand(client, "sm_menu");
			FreedayOver = CreateTimer(g_fFreedayTime * 60.0, Timer_Freeday, i, TIMER_FLAG_NO_MAPCHANGE);
		}
		else 
		{
			PrintToChat(client, " \x04[JS] \x05Can't give that player a Freeday.");
			FDMenu2(client);
		}
		
	}
}
/// MENU STUFF ///

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (attacker <= 0 || attacker > MaxClients || victim <= 0 || victim > MaxClients)
		return Plugin_Continue;
	if (IsValidClient(victim) && GetClientTeam(victim) == 3 && GetClientTeam(attacker) == 2)
	{
		SetEntityRenderColor(attacker, 255, 0, 0, 255);
		Rebel[attacker] = true;
	}
	return Plugin_Continue;
}

public void OnAvailableLR(int Announced)
{
	showMenu = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && BaseComm_IsClientMuted(i))
		{
			BaseComm_SetClientMute(i, false);
			SetEntityRenderColor(i, 255, 255, 255, 255);
		}
	}
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}

stock int GetPlayerCount()
{
	int iPlayers;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			iPlayers++;
		}
	}
	return iPlayers;
}

public void DivideTeams(int client, int myth)
{
	if (GetPlayerCount() % myth != 0)
	{
		PrintToChat(client, " \x04[JS] \x05Can't divide players into %i teams.", myth);
		return;
	}
	
	int color[4]; //RGBA
	color[0] = 255; //R
	color[1] = 0; //G
	color[2] = 0; //B
	color[3] = 255; //A
	
	// Sky Blue, Yellow, Orange, Pink - Colors
	int limit = GetPlayerCount() / myth;
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			if (count >= limit && count < (2 * limit))
			{
				color[0] = 0; 
				color[1] = 255;
				color[2] = 255;
				color[3] = 255;
				SetEntityRenderColor(i, color[0], color[1], color[2], color[3]);
				PrintToChat(client, " \x04[JS] \x05%N is in \x01Blue Team.", i); // Sky Blue
			}
			else if (count >= (2 * limit) && count < (3 * limit))
			{
				color[0] = 255; 
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
				SetEntityRenderColor(i, color[0], color[1], color[2], color[3]);
				PrintToChat(client, " \x04[JS] \x05%N is in \x01Yellow Team.", i); // Yellow
			}
			else if (count >= (3 * limit))
			{
				color[0] = 255; 
				color[1] = 128;
				color[2] = 0;
				color[3] = 255;
				SetEntityRenderColor(i, color[0], color[1], color[2], color[3]);
				PrintToChat(client, " \x04[JS] \x05%N is in \x01Orange Team.", i); // Orange
			}
			else if (count < limit)
			{
				color[0] = 255; 
				color[1] = 0;
				color[2] = 255;
				color[3] = 255;
				SetEntityRenderColor(i, color[0], color[1], color[2], color[3]);
				PrintToChat(client, " \x04[JS] \x05%N is in \x01Pink Team.", i); // Pink
			}
			count++;
		}
		
	}
	PrintToChatAll(" \x04[JS] \x05%N divided Prisoners into \x01%i \x05Teams.", client, myth);
}

public Action Timer_Freeday(Handle timer, any client)
{
	if (IsValidClient(client))
	{
		PrintToChatAll(" \x04[JS] \x05Freeday is over for \x01%N\x05.", client);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		FD[client] = false;
	}
	else
	{
		PrintToChatAll(" \x04[JS] \x05Freeday is over.", client);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				SetEntityRenderColor(i, 255, 255, 255, 255);
			}
		}
		FD2All = false;
	}
	EmitSoundToAllAny("Simon/0.mp3");
}

public Action Timer_CountDown(Handle timer)
{
	PrintCenterTextAll("<font size=\"32\"><font color='#B3FF00'>%i</font></font>", Second);
	switch (Second)
	{
		case 0:
		{
			EmitSoundToAllAny("Simon/0.mp3");
			PrintCenterTextAll("<font size=\"32\"><font color='#FF0000'>Go </font><font color='#00FF00'>Go </font><font color='#0000FF'>Go</font></font>");
			IsRunning = false;
			KillTimer(CD);
		}
		case 1:
		{
			EmitSoundToAllAny("Simon/1.mp3");
		}
		case 2:
		{
			EmitSoundToAllAny("Simon/2.mp3");
		}
		case 3:
		{
			EmitSoundToAllAny("Simon/3.mp3");
		}
		case 4:
		{
			EmitSoundToAllAny("Simon/4.mp3");
		}
		case 5:
		{
			EmitSoundToAllAny("Simon/5.mp3");
		}
		case 6:
		{
			EmitSoundToAllAny("Simon/6.mp3");
		}
		case 7:
		{
			EmitSoundToAllAny("Simon/7.mp3");
		}
		case 8:
		{
			EmitSoundToAllAny("Simon/8.mp3");
		}
		case 9:
		{
			EmitSoundToAllAny("Simon/9.mp3");
		}
		case 10:
		{
			EmitSoundToAllAny("Simon/10.mp3");
		}
	}
	--Second;
} 

/*
- FreedayMenu(any client)DONE
- TeamMenu(any client)DONE
- Countdown(any client)DONE
- GiveHP(any client)DONE
- MutePeople(any client)DONE
- Music(any client)DONE
*/