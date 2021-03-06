catherine.notify = catherine.notify or { }
catherine.notify.Lists = { }

function catherine.notify.Add( message, time, sound, icon )
	surface.PlaySound( sound or "buttons/button24.wav" )
	catherine.notify.Lists[ #catherine.notify.Lists + 1 ] = {
		message = message,
		endTime = CurTime( ) + time,
		icon = icon,
		x = ScrW( ) / 2 - ( ScrW( ) * 0.4 ) / 2,
		y = ( ScrH( ) - 10 ) - ( ( #catherine.notify.Lists + 1 ) * 25 ),
		w = ScrW( ) * 0.4,
		h = 20,
		alpha = 0
	}
end

function catherine.notify.Draw( )
	if ( #catherine.notify.Lists == 0 ) then return end
	for k, v in pairs( catherine.notify.Lists ) do
		if ( v.endTime <= CurTime( ) ) then
			v.alpha = Lerp( 0.05, v.alpha, 0 )
			if ( math.Round( v.alpha ) <= 0 ) then
				table.remove( catherine.notify.Lists, k )
			end
		else
			v.alpha = Lerp( 0.05, v.alpha, 255 )
		end
		v.y = Lerp( 0.05, v.y, ( ScrH( ) - 10 ) - ( ( k ) * 25 ) )
		draw.RoundedBox( 0, v.x, v.y, v.w, v.h, Color( 235, 235, 235, v.alpha ) )
		draw.SimpleText( v.message, "catherine_normal15", v.x + v.w / 2, v.y + v.h / 2, Color( 50, 50, 50, v.alpha ), 1, 1 )
	end
end