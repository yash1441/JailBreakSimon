#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Simon"
#define PLUGIN_VERSION "2.1"

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

bool Freekilled[MAXPLAYERS + 1] =  { false, ... };

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "Jailbreak Freekill Report",
	author = PLUGIN_AUTHOR,
	description = "Jailbreak Simon Add-on",
	version = PLUGIN_VERSION,
	url = "yash1441@yahoo.com"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	CreateConVar("jb_freekill_version", PLUGIN_VERSION, "Jailbreak Freekill Report Version", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	
	RegConsoleCmd("sm_fk", Freekill);
	RegConsoleCmd("sm_freekill", Freekill);
	
	HookEvent("round_start", RoundStart);
}

public Action RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	LoopClients(i)
	{
		Freekilled[i] = false;
	}
	return Plugin_Continue;
}

public Action Freekill(int client, int args)
{
	if (GetClientTeam(client) != CS_TEAM_T || IsPlayerAlive(client) || Freekilled[client])
		return Plugin_Handled;
	
	Handle menu = CreateMenu(FreekillHandler);
	SetMenuTitle(menu, "Report Guard:");
	
	char temp2[8];
	char temp[128];
	int count = 0;
	LoopClients(i)
	{
		if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT) 
		{
			Format(temp, 128, "%N", i);
			Format(temp2, 8, "%i", i);
			AddMenuItem(menu, temp2, temp);
			
			count++;
		}
	}
	if(count == 0)
	{
		AddMenuItem(menu, "none", "N.A.", ITEMDRAW_DISABLED);
	}
	DisplayMenu(menu, client, 15);
	return Plugin_Handled;
}

public int FreekillHandler(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if (GetClientTeam(client) != CS_TEAM_T || IsPlayerAlive(client))
			return;
			
		char info[11];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		int  other = StringToInt(info);
		AskOther(client, other);
	}
}

public void AskOther(int client, int guard)
{
	Freekilled[client] = true;
	Handle menu = CreateMenu(FreekillerHandler);
	SetMenuTitle(menu, "Freekilled?");
	char clientid[64];
	FormatEx(clientid, sizeof(clientid), "%i", client);
	AddMenuItem(menu, clientid, "Yes");
	AddMenuItem(menu, "no", "No");
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, guard, MENU_TIME_FOREVER);
}

public int FreekillerHandler(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		if (GetClientTeam(client) != CS_TEAM_CT || !IsPlayerAlive(client))
			return;
			
		char info[11];
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info,"no") != 0) 
		{
			int  id = StringToInt(info);
			CS_RespawnPlayer(id);
			PrintToChatAll(" \x04[JS] \x05%N \x01has been respawned by \x05%N\x01.", id, client);
		}
	}
}