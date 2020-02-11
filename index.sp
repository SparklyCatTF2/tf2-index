#include <sourcemod>
#include <tf2idb>

public OnPluginStart()
{
	RegConsoleCmd("sm_index", IndexOfWearable)
}

public Action IndexOfWearable(int client, int args)
{
	if(args == 0)
	{
		PrintToChat(client, "[SM] Command usage: sm_index <wearable name>. An example: sm_index the b.m.o.c");
		return Plugin_Handled;
	}
	if(client == 0)
	{
		return Plugin_Handled;
	}

	char name[86];
	GetCmdArgString(name, sizeof(name));
	ReplaceString(name, sizeof(name), "%", "", false);

	if(strlen(name) < 3)
	{
		PrintToChat(client, "[SM] You must include at least 3 letters in the wearable name.");
		return Plugin_Handled;
	}
	
	Handle arguments = CreateArray(86);
	PushArrayString(arguments, name);

	char query[128];
	Format(query, sizeof(query), "SELECT id, name FROM tf2idb_item WHERE class='tf_wearable' AND name LIKE '%%' || ? || '%%'");
	Handle hQuery = TF2IDB_CustomQuery(query, arguments, sizeof(name));
	int size = SQL_GetRowCount(hQuery);
	if(size < 1)
	{
		CloseHandle(hQuery);
		Handle hMenu = new Menu(MenuCallback);
		SetMenuTitle(hMenu, "Recursion.TF >> Index Search");
		AddMenuItem(hMenu, "0", "------------------------------", ITEMDRAW_DISABLED);
		AddMenuItem(hMenu, "1", "No results found.", ITEMDRAW_DISABLED);
		AddMenuItem(hMenu, "2", "------------------------------", ITEMDRAW_DISABLED);

		DisplayMenu(hMenu, client, 60);
		return Plugin_Handled;
	}
	else
	{
		char buf[84];
		int index;

		Handle hMenu = new Menu(MenuCallback);
		SetMenuTitle(hMenu, "Recursion.TF >> Index Search");
		AddMenuItem(hMenu, "0", "------------------------------", ITEMDRAW_DISABLED);
		//AddMenuItem(hMenu, "0", "No results found.");
		while(SQL_FetchRow(hQuery))
		{
			index = SQL_FetchInt(hQuery, 0);
			SQL_FetchString(hQuery, 1, buf, sizeof(buf));
			Format(buf, sizeof(buf), "%i | %s", index, buf);
			AddMenuItem(hMenu, "0", buf, ITEMDRAW_DISABLED);
		}
		AddMenuItem(hMenu, "0", "------------------------------", ITEMDRAW_DISABLED);
		DisplayMenu(hMenu, client, 60);
		CloseHandle(hQuery);

		return Plugin_Handled;
	}
}

public MenuCallback(Handle menu, MenuAction action, int client, int itemNum)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
