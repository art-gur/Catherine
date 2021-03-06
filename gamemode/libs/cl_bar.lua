catherine.bar = catherine.bar or { }
catherine.bar.Lists = { }

function catherine.bar.Add( target, targetMax, text, color, uniqueID )
	catherine.bar.Lists[ #catherine.bar.Lists + 1 ] = {
		target = target,
		targetMax = targetMax,
		text = text,
		color = color,
		uniqueID = uniqueID,
		ani = 0,
		y = -7 + ( #catherine.bar.Lists + 1 ) * 12,
		alpha = 0
	}
end

function catherine.bar.Draw( )
	if ( !LocalPlayer( ):Alive( ) or !LocalPlayer( ):IsCharacterLoaded( ) or catherine.option.Get( "CONVAR_BAR" ) == "0" ) then return end
	local count = 0
	for k, v in pairs( catherine.bar.Lists ) do
		if ( !v.target or !v.targetMax ) then continue end
		local percent = ( math.min( v.target( ) / v.targetMax( ), 1 ) )
		if ( percent == 0 ) then
			v.alpha = Lerp( 0.03, v.alpha, 0 )
		else
			count = count + 1
			v.alpha = Lerp( 0.03, v.alpha, 255 )
		end
		v.ani = Lerp( 0.03, v.ani, ( ScrW( ) * 0.3 ) * percent )
		v.y = Lerp( 0.03, v.y, -7 + count * 12 )
		draw.RoundedBox( 0, 5, v.y, ScrW( ) * 0.3, 7, Color( 230, 230, 230, v.alpha - 20 ) )
		draw.RoundedBox( 0, 5, v.y, v.ani, 7, Color( v.color.r, v.color.g, v.color.b, v.alpha ) )
	end
end

do
	catherine.bar.Add( function( )
		return LocalPlayer( ):Health( )
	end, function( )
		return LocalPlayer( ):GetMaxHealth( )
	end, "", Color( 255, 0, 150 ), "health" )

	catherine.bar.Add( function( )
		return LocalPlayer( ):Armor( )
	end, function( )
		return 255
	end, "", Color( 255, 255, 150 ), "armor" )
end