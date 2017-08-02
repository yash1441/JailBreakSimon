#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#define PLUGIN_VERSION "3.0"

Handle g_hMsg = INVALID_HANDLE;
Handle g_fward_onBecome = INVALID_HANDLE;
Handle g_fward_onRemove = INVALID_HANDLE;
Handle g_hTagEnabled = INVALID_HANDLE;
Handle g_hBeaconEnabled = INVALID_HANDLE;
Handle timer = INVALID_HANDLE;

bool g_bTagEnabled;
bool g_bBeaconEnabled;
bool Bdone = true;
int ga_iwhiteColor[4] = {255, 255, 255, 255};

int Simon = -1;
int g_BeamSprite;
int g_HaloSprite;

public Plugin myinfo =
{
	name = "Jailbreak Simon",
	author = "Simon",
	description = "Jailbreak Warden with more features!",
	version = PLUGIN_VERSION,
	url = "yash1441@yahoo.com"
};

public void OnPluginStart()
{
	CreateConVar("jb_version", PLUGIN_VERSION, "Jailbreak Simon Version", FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	g_hMsg = CreateConVar("jb_simon_msg", "0", "0 - normal chat messages, 1 - hint & centre text messages", 0, true, 0.0, true, 1.0);
	g_hTagEnabled = CreateConVar("jb_tag_enabled", "1", "Allow \"Simon\" to be added to the server tags?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBeaconEnabled = CreateConVar("jb_beacon_enabled", "1", "Enable or Disable beacon on Simon", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);
	
	AddCommandListener(BlockKill, "kill");
	AddCommandListener(HookPlayerChat, "say");
	
	RegConsoleCmd("nomic", Cmd_NoMic);
	RegConsoleCmd("sm_simon", Cmd_ToggleSimon);
	RegConsoleCmd("sm_s", Cmd_ToggleSimon);
	RegAdminCmd("sm_remove", Cmd_RemoveSimon, ADMFLAG_GENERIC);
	
	g_fward_onBecome = CreateGlobalForward("simon_OnSimonCreated", ET_Ignore, Param_Cell);
	g_fward_onRemove = CreateGlobalForward("simon_OnSimonRemoved", ET_Ignore, Param_Cell);
	
	AutoExecConfig(true, "simon");
}

public OnConfigsExecuted()
{
	g_bTagEnabled = GetConVarBool(g_hTagEnabled);
	g_bBeaconEnabled = GetConVarBool(g_hBeaconEnabled);
	if (g_bTagEnabled)
	{
		Handle hTags = FindConVar("sv_tags");
		char sTags[128];
		GetConVarString(hTags, sTags, sizeof(sTags));
		StrCat(sTags, sizeof(sTags), ", Jailbreak, Simon, JS");
		SetConVarString(hTags, sTags, false, false);
	}
}

public OnMapStart()
{
    g_BeamSprite = PrecacheModel("materials/sprites/white.vmt");
    g_HaloSprite = PrecacheModel("materials/sprites/halo01.vtf");
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("simon_exist", Native_ExistSimon);
	CreateNative("simon_issimon", Native_IsSimon);
	CreateNative("simon_set", Native_SetSimon);
	CreateNative("simon_remove", Native_RemoveSimon);

	RegPluginLibrary("simon");
   
	return APLRes_Success;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	Simon = -1;
	if (g_bBeaconEnabled)
	{
		if (!Bdone)
		{
			KillTimer(timer, false);
			Bdone = true;
		}
	}
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
   
	if(client == Simon)
	{
		PrintToChatAll(" \x04[JS] \x05The Simon (%N) is dead.", client);
		if(GetConVarBool(g_hMsg))
		{
			PrintCenterTextAll(" \x04[JS] \x05The Simon (%N) is dead.", client);
			PrintHintTextToAll(" \x04[JS] \x05The Simon (%N) is dead.", client);
		}
		Simon = -1;
		SetEntityRenderColor(client, 255, 255, 255, 255);
		if (g_bBeaconEnabled)
		{
			KillTimer(timer, false);
			Bdone = true;
		}
	}
}

public Action BlockKill(client, const char[] command, int args)
{
	
	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
	if(client == Simon)
	{
		PrintToChatAll(" \x04[JS] \x05The Simon (%N) disconnected.", client);
		if(GetConVarBool(g_hMsg))
		{
			PrintCenterTextAll(" \x04[JS] \x05The Simon (%N) disconnected.", client);
			PrintHintTextToAll(" \x04[JS] \x05The Simon (%N) disconnected.", client);
		}
		if (g_bBeaconEnabled)
		{
			KillTimer(timer, false);
			Bdone = true;
		}
		Simon = -1;
	}
}

public Action HookPlayerChat(int client, const char[] command, int args)
{
	if(Simon == client && client != 0)
	{
		char szText[256];
		GetCmdArg(1, szText, sizeof(szText));
	   
		if(szText[0] == '/' || szText[0] == '@' || IsChatTrigger())
			return Plugin_Handled;
	   
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
		{
			PrintToChatAll("[Simon] %N : %s", client, szText);
			return Plugin_Handled;
		}
	}
   
	return Plugin_Continue;
}

public Action Cmd_NoMic(int client, int args)
{
	ReplyToCommand(0, "%N used !nomic", client);
	if (GetClientTeam(client) == 3)
	{
		if (IsPlayerAlive(client))
			ForcePlayerSuicide(client);
		CS_SwitchTeam(client, 2);
	}
	return Plugin_Continue;
}

public Action Cmd_ToggleSimon(int client, int args)
{
	ReplyToCommand(0, "%N used !simon", client);
	if (Simon == -1)
	{
		if (GetClientTeam(client) == 3)
		{
			if (IsPlayerAlive(client))
			{
				SetTheSimon(client);
			}
				

			else
				PrintToChat(client, " \x04[JS] \x05You must be alive to be the Simon.");

		}
		else
			PrintToChat(client, " \x04[JS] \x05Only CTs can be the Simon.");
	}
	else
	{
		if (Simon == client)
		{
			PrintToChatAll(" \x04[JS] \x05%N retired as Simon.", client);
			if(GetConVarBool(g_hMsg))
			{
				PrintCenterTextAll(" \x04[JS] \x05%N retired as Simon.", client);
				PrintHintTextToAll(" \x04[JS] \x05%N retired as Simon.", client);
			}
			Simon = -1;
			SetEntityRenderColor(client, 255, 255, 255, 255);
			if (g_bBeaconEnabled)
			{
				KillTimer(timer, false);
				Bdone = true;
			}
		}
		else
			PrintToChat(client, " \x04[JS] \x05Current Simon : %N", Simon);
	}
}

public void SetTheSimon(int client)
{
	PrintToChatAll(" \x04[JS] \x05%N has become Simon.", client);
   
	if(GetConVarBool(g_hMsg))
	{
		PrintCenterTextAll(" \x04[JS] \x05%N has become Simon.", client);
		PrintHintTextToAll(" \x04[JS] \x05%N has become Simon.", client);
	}
	Simon = client;
	SetClientListeningFlags(client, VOICE_NORMAL);
	SetEntityRenderColor(client, 0, 0, 255, 255);
	if (g_bBeaconEnabled)
	{
		timer = CreateTimer(1.0, Beacon, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		Bdone = false;
	}
	Forward_OnSimonCreation(client);
	ClientCommand(client, "sm_menu");
}

public Action Beacon(Handle hTimer, any client)
{
	float a_fOrigin[3];
	GetClientAbsOrigin(client, a_fOrigin);
	a_fOrigin[2] += 10;
	TE_SetupBeamRingPoint(a_fOrigin, 10.0, 400.0, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, ga_iwhiteColor, 10, 0);

	TE_SendToAll();

	GetClientEyePosition(client, a_fOrigin);
	return Plugin_Continue;
}

public Action Cmd_RemoveSimon(int client, int args)
{
	ReplyToCommand(0, "%N used !remove", client);
	if(Simon != -1)
		RemoveTheSimon(client);
		
	else
		PrintToChatAll(" \x04[JS] \x05There is no Simon present.");
		
	return Plugin_Handled;
}

public RemoveTheSimon(client)
{
	PrintToChatAll(" \x04[JS] \x05%N fired %N.", client, Simon);
	if(GetConVarBool(g_hMsg))
	{
		PrintCenterTextAll(" \x04[JS] \x05%N fired %N.", client, Simon);
		PrintHintTextToAll(" \x04[JS] \x05%N fired %N.", client, Simon);
	}
	Simon = -1;
	SetEntityRenderColor(client, 255, 255, 255, 255);
	if (g_bBeaconEnabled)
	{
		KillTimer(timer, false);
		Bdone = true;
	}
	Forward_OnSimonRemoved(client);
}

public Native_ExistSimon(Handle plugin, int numParams)
{
	if(Simon != -1)
		return true;
   
	return false;
}
 
public Native_IsSimon(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
   
	if(!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
   
	if(client == Simon)
		return true;
   
	return false;
}
 
public Native_SetSimon(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
   
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
   
	if(Simon == -1)
	{
		SetTheSimon(client);
	}
}
 
public Native_RemoveSimon(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
   
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
   
	if(client == Simon)
	{
		RemoveTheSimon(client);
	}
}
 
public Forward_OnSimonCreation(int client)
{
	Call_StartForward(g_fward_onBecome);
	Call_PushCell(client);
	Call_Finish();
}
 
public Forward_OnSimonRemoved(int client)
{
	Call_StartForward(g_fward_onRemove);
	Call_PushCell(client);
	Call_Finish();
}

