#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <hosties>
#include <lastrequest>

#pragma semicolon 1

#define PLUGIN_VERSION "2.1"

Handle gH_Enabled = INVALID_HANDLE;

bool gB_Enabled;
bool gB_Boxing;

int gI_LastUsed[MAXPLAYERS+1];

Handle gH_Cvars[7] = {INVALID_HANDLE, ...};

public Plugin myinfo = 
{
	name = "Jailbreak Box",
	author = "Simon",
	description = "Jailbreak Simon Add-on",
	version = PLUGIN_VERSION,
	url = "yash1441@yahoo.com"
};

public void OnPluginStart()
{
	CreateConVar("jb_box_version", PLUGIN_VERSION, "Jailbreak Box version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	gH_Enabled = CreateConVar("jb_box_enabled", "1", "Enable or Disable this plugin.", 0, true, 0.0, true, 1.0);
	gB_Enabled = true;
	HookConVarChange(gH_Enabled, OnConvarChanged);
	
	HookEvent("round_end", Round_End);
	
	RegConsoleCmd("sm_box", Command_Box, "Toggle Jailbreak Box status, available for admins/CTs.");
	
	AutoExecConfig(true, "jailbreakbox");
	
	gH_Cvars[0] = FindConVar("ff_damage_reduction_bullets");
	gH_Cvars[1] = FindConVar("ff_damage_reduction_grenade");
	gH_Cvars[2] = FindConVar("ff_damage_reduction_grenade_self");
	gH_Cvars[3] = FindConVar("ff_damage_reduction_other");
	gH_Cvars[4] = FindConVar("mp_friendlyfire");
	gH_Cvars[5] = FindConVar("mp_autokick");
	gH_Cvars[6] = FindConVar("mp_tkpunish");
}

public void OnAvailableLR(int Announced)
{
	if(gB_Boxing)
	{
		gB_Boxing = false;
		
		for(new i; i <= MaxClients; i++)
		{
			if(IsValidClient(i))
			{
				PrintToConsole(i, "[JS] Jailbreak Box has automatically disabled due to an LR.");
			}
		}
	}
	
	if(gB_Enabled)
	{
		Disable();
	}
}

public void OnConvarChanged(Handle cvar, const char[] oldVal, const char[] newVal)
{
	if(cvar == gH_Enabled)
	{
		gB_Enabled = GetConVarBool(gH_Enabled);
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	gI_LastUsed[client] = 0;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(gB_Enabled && gB_Boxing)
	{
		if(IsValidClient(attacker) && IsValidClient(victim, true))
		{
			if(attacker != victim && GetClientTeam(attacker) == 3 && GetClientTeam(victim) == 3)
			{
				damage = 0.0;
				
				return Plugin_Changed;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action Round_End(Handle event, const char[] name, bool dB)
{
	gB_Boxing = false;
	
	if(gB_Enabled)
	{
		Disable();
	}
	
	return Plugin_Continue;
}

public Action Command_Box(int client, int args)
{
	if(!IsValidClient(client))
	{
		return Plugin_Handled;
	}
	
	if(!HasAccess(client))
	{
		ReplyToCommand(client, " \x04[JS]\x05 This command is available for \x01admins \x05and \x01alive prison guards\x05.");
		
		return Plugin_Handled;
	}
	
	int  Time = GetTime();
	
	if(Time - gI_LastUsed[client] < 15)
	{
		ReplyToCommand(client, " \x04[JS]\x05 You can't spam this command, time left - \x01[%d/15]\x05.", Time - gI_LastUsed[client]);
		
		return Plugin_Handled;
	}
	
	gI_LastUsed[client] = Time;
	
	Handle menu = CreateMenu(MenuHandler_Box, MENU_ACTIONS_ALL);
	SetMenuTitle(menu, "Jailbreak Box:");
	
	AddMenuItem(menu, "on", "Enable");
	AddMenuItem(menu, "off", "Disable");
	
	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, client, 20);
	
	return Plugin_Handled;
}

public int MenuHandler_Box(Handle menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(!HasAccess(param1))
			{
				PrintToChat(param1, " \x04[JS]\x05 This command is available for \x01admins \x05and \x01alive prison guards\x05.");
				
				return 0;
			}
			
			char info[8];
			GetMenuItem(menu, param2, info, 8);
			
			bool enabled = StrEqual(info, "on");
			
			enabled? Enable():Disable();
			
			PrintToChatAll(" \x04[JS]\x05 Jailbreak Box has been \x01%sabled\x05.", enabled? "en":"dis");
		}
		
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
	
	return 0;
}

public void Enable()
{
	for(new i; i < sizeof(gH_Cvars); i++)
	{
		if(gH_Cvars[i] != INVALID_HANDLE)
		{
			SetConVarBool(gH_Cvars[i], (i <= 4)? true:false);
		}
	}
}

public void Disable()
{
	for(new i; i < sizeof(gH_Cvars); i++)
	{
		if(gH_Cvars[i] != INVALID_HANDLE)
		{
			SetConVarBool(gH_Cvars[i], (i <= 4)? false:true);
		}
	}
}

stock bool HasAccess(int client)
{
	if(CheckCommandAccess(client, "jailbreakbox", ADMFLAG_SLAY))
	{
		return true;
	}
	
	if(GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client))
	{
		return true;
	}
	
	return false;
}

stock bool IsValidClient(int client, bool alive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	
	return false;
}
