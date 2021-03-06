function GM:GetGameDescription( )
	return "CAT - ".. ( Schema and Schema.Name or "Unknown" )
end

function GM:PlayerSpray( pl )
	return !hook.Run( "PlayerCanSpray", pl )
end

function GM:PlayerSpawn( pl )
	if ( IsValid( pl.dummy ) ) then
		pl.dummy:Remove( )
	end
	pl:SetNoDraw( false )
	pl:Freeze( false )
	pl:ConCommand( "-duck" )
	pl:SetColor( Color( 255, 255, 255, 255 ) )
	pl:SetupHands( )
	player_manager.SetPlayerClass( pl, "catherine_player" )
	if ( pl:IsCharacterLoaded( ) ) then
		hook.Run( "PlayerSpawnedInCharacter", pl )
	end
end

function GM:PlayerSpawnedInCharacter( pl )
	hook.Run( "PostWeaponGive", pl )
end

function GM:PlayerSetHandsModel( pl, ent )
	local model = player_manager.TranslateToPlayerModelName( pl:GetModel( ) )
	local info = player_manager.TranslatePlayerHands( model )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end
end

function GM:PlayerDisconnected( pl )
	if ( IsValid( pl.dummy ) ) then
		pl.dummy:Remove( )
	end
end

function GM:KeyPress( pl, key )
	if ( key == IN_RELOAD ) then
		timer.Create("Catherine.timer.weapontoggle." .. pl:SteamID( ), 1, 1, function()
			if ( !IsValid( pl ) ) then return end
			pl:ToggleWeaponRaised( )
		end )
	elseif ( key == IN_USE ) then
		local tr = { }
		tr.start = pl:GetShootPos( )
		tr.endpos = tr.start + pl:GetAimVector() * 60
		tr.filter = pl
		local ent = util.TraceLine( tr ).Entity
		if ( IsValid( ent ) and ent:IsDoor( ) ) then
			local function IsChildDoor( )
				local currDoorIndex = ent:EntIndex( )
				local prevEnt, nextEnt = Entity( currDoorIndex - 1 ), Entity( currDoorIndex + 1 )
				if ( IsValid( prevEnt ) and prevEnt:IsDoor( ) or IsValid( nextEnt ) and nextEnt:IsDoor( ) ) then
					return true
				end
				return false
			end
			if ( pl.canUseDoor == nil ) then pl.canUseDoor = true end
			if ( !pl.doorSpamCount ) then pl.doorSpamCount = 0 end
			if ( pl.lookingDoorEntity == nil ) then pl.lookingDoorEntity = ent end
			pl.doorSpamCount = pl.doorSpamCount + 1
			
			if ( ( pl.lookingDoorEntity == ent or IsChildDoor ) and pl.doorSpamCount >= 10 ) then
				pl.lookingDoorEntity = nil
				pl.doorSpamCount = 0
				pl.canUseDoor = false
				catherine.util.Notify( pl, "Do not door-spam!" )
				timer.Create( "Catherine.timer.doorSpamDelay", 1, 1, function( )
					pl.canUseDoor = true
				end )
				timer.Remove( "Catherine.timer.doorSpamInit" )
			elseif ( pl.lookingDoorEntity != ent ) then
				pl.lookingDoorEntity = ent
				pl.doorSpamCount = 1
			end
			timer.Remove( "Catherine.timer.doorSpamInit" )
			timer.Create( "Catherine.timer.doorSpamInit", 1, 1, function( )
				pl.canUseDoor = true
				pl.doorSpamCount = 0
			end )
		end
	end
end
function GM:PlayerUse( pl, ent )
	if ( ent:IsDoor( ) ) then
		return pl.canUseDoor
	end
	return true
end

function GM:PostWeaponGive( pl )
	pl:Give( "catherine_fist" )
	pl:Give( "catherine_key" )
end

function GM:PlayerSay( pl, text )
	catherine.chat.Work( pl, text )
end

function GM:KeyRelease( pl, key )
	if ( key == IN_RELOAD ) then 
		timer.Remove( "Catherine.timer.weapontoggle." .. pl:SteamID( ) )
	end
end

function GM:PlayerInitialSpawn( pl )
	timer.Simple( 1, function( )
		pl:SetNoDraw( true )
	end )

	timer.Create( "Catherine.timer.waitPlayer." .. pl:SteamID( ), 1, 0, function( )
		if ( IsValid( pl ) and pl:IsPlayer( ) ) then
			timer.Remove( "Catherine.timer.waitPlayer." .. pl:SteamID( ) )
			timer.Simple( 2, function( )
				catherine.player.Initialize( pl )
				pl:SetNoDraw( true )
			end )
		end
	end )
end

function GM:PlayerNoClip( pl, bool )
	if ( pl:IsAdmin( ) ) then
		if ( pl:GetMoveType( ) == MOVETYPE_WALK ) then
			pl:SetNoDraw( true )
			pl:DrawShadow( false )
			pl:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			catherine.network.SetNetVar( pl, "nocliping", true )
		else
			pl:SetNoDraw( false )
			pl:DrawShadow( true )
			pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			catherine.network.SetNetVar( pl, "nocliping", false )
		end
	end
	return pl:IsAdmin( )
end

function GM:PlayerGiveSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnSWEP( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnEffect( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnNPC( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnObject( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnProp( pl )
	return pl:HasFlag( "e" )
end

function GM:PlayerSpawnRagdoll( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnVehicle( pl )
	return pl:IsAdmin( )
end

function GM:PlayerSpawnSENT( pl )
	return pl:IsAdmin( )
end

function GM:PlayerHurt( pl )
	pl.autoHealthrecoverStart = true
	pl:EmitSound( "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 1, 6 ).. ".wav" )
	return true
end

function GM:PlayerDeathSound( pl )
	pl:EmitSound( "vo/npc/" .. pl:GetGender( ) .. "01/pain0" .. math.random( 7, 9 ) .. ".wav" )
	return true
end

function GM:DoPlayerDeath( pl )
	pl:SetNoDraw( true )
	pl:Freeze( true )
end

function GM:PlayerDeath( pl )
	// Spaen fake death body.
	pl.dummy = ents.Create( "prop_ragdoll" )
	pl.dummy:SetAngles( pl:GetAngles( ) )
	pl.dummy:SetModel( pl:GetModel( ) )
	pl.dummy:SetPos( pl:GetPos( ) )
	pl.dummy:Spawn( )
	pl.dummy:Activate( )
	pl.dummy:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	pl.dummy.player = self
	catherine.network.SetNetVar( pl.dummy, "player", pl )
	catherine.network.SetNetVar( pl.dummy, "ragdollID", pl.dummy:EntIndex( ) )
	pl.dummy:CallOnRemove( "RecoverPlayer", function( )
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
		if ( !IsValid( pl.dummy ) ) then return end
		pl.dummy:Remove( )
	end )
	
	timer.Create( "catherine.timer.Respawn_" .. pl:SteamID( ), catherine.configs.spawnTime, 1, function( )
		if ( !IsValid( pl ) ) then return end
		pl:Spawn( )
	end )
		
	pl.autoHealthrecoverStart = false
	catherine.util.ProgressBar( pl, "You are now respawning.", catherine.configs.spawnTime )
	catherine.network.SetNetVar( pl, "nextSpawnTime", CurTime( ) + catherine.configs.spawnTime )
	catherine.network.SetNetVar( pl, "deathTime", CurTime( ) )
end

function GM:Tick( )
	// Health auto recover system.
	for k, v in pairs( player.GetAll( ) ) do
		if ( !v:IsCharacterLoaded( ) ) then continue end
		if ( !v.autoHealthrecoverStart ) then continue end
		if ( !v.autoHealthrecoverCur ) then v.autoHealthrecoverCur = CurTime( ) + 3 end
		if ( math.Round( v:Health( ) ) >= v:GetMaxHealth( ) ) then v.autoHealthrecoverStart = false hook.Run( "HealthFullRecovered", v ) end
		if ( v.autoHealthrecoverCur <= CurTime( ) ) then
			v:SetHealth( math.Clamp( v:Health( ) + 1, 0, v:GetMaxHealth( ) ) )
			v.autoHealthrecoverCur = CurTime( ) + 3
			hook.Run( "HealthRecovering", v )
		end
	end
end

function GM:Initialize( )
	hook.Run( "GamemodeInitialized" )
end

function GM:PlayerShouldTakeDamage( )
	return true
end

function GM:GetFallDamage( pl, spd )
	local custom = hook.Run( "GetCustomFallDamage", pl, spd )
	return custom or ( spd - 580 ) * 0.8
end

function GM:InitPostEntity( )
	hook.Run( "DataLoad" )
end

function GM:ShutDown( )
	hook.Run( "DataSave" )
end

function GM:PlayerCantSpray( pl ) end