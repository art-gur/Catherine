catherine.schema = catherine.schema or { }

function catherine.schema.Initialization( )
	Schema = Schema or {
		Name = "Example Schema",
		Author = "L7D",
		UniqueID = GM.FolderName,
		FolderName = GM.FolderName,
		Title = "Example",
		Desc = "A schema.",
		IntroTitle = "A Schema",
		IntroDesc = "Welcome..."
	}
	catherine.util.IncludeInDir( "schema/libs" )
	catherine.util.IncludeInDir( "schema/derma" )
	catherine.plugin.LoadAll( Schema.FolderName )
	catherine.plugin.LoadAll( catherine.FolderName )
	
	catherine.util.Include( "schema/sh_schema.lua" )
	catherine.faction.Include( Schema.FolderName .. "/gamemode/schema" )
	catherine.item.Include( Schema.FolderName .. "/gamemode/schema" )
	
	hook.Run( "SchemaInitialized" )
end

function catherine.schema.GetUniqueID( )
	if ( !Schema ) then return "catherine" end
	return Schema.UniqueID or "catherine"
end

hook.NyanHookRun = hook.NyanHookRun or hook.Call

function hook.Call( name, gm, ... )
	if ( name == "PlayerSpawn" ) then
		local arg = { ... }
		local pl = arg[ 1 ]
		if ( IsValid( pl ) and !pl:IsCharacterLoaded( ) ) then return end
	end
	if ( catherine.plugin ) then
		for k, v in pairs( catherine.plugin.GetAlls( ) ) do
			if ( !v[ name ] ) then continue end
			local func = v[ name ]( v, ... )
			if ( func == nil ) then continue end
			return func
		end
	end
	if ( Schema and Schema[ name ] ) then
		local func = Schema[ name ]( Schema, ... )
		if ( func == nil ) then return end
		return func
	end
	return hook.NyanHookRun( name, gm, ... )
end