local PANEL = { }

function PANEL:Init( )
	catherine.vgui.inventory = self
	
	self.inventory = nil
	self.invWeightAni = 0
	self.invWeight = 0
	self.invMaxWeight = 0
	
	self:SetMenuSize( ScrW( ) * 0.6, ScrH( ) * 0.8 )
	self:SetMenuName( "Inventory" )

	self.Lists = vgui.Create( "DPanelList", self )
	self.Lists:SetPos( 110, 35 )
	self.Lists:SetSize( self.w - 120, self.h - 45 )
	self.Lists:SetSpacing( 5 )
	self.Lists:EnableHorizontal( false )
	self.Lists:EnableVerticalScrollbar( true )	
	self.Lists.Paint = function( pnl, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 235, 235, 235, 255 ) )
	end
	
	self.weight = vgui.Create( "catherine.vgui.weight", self )
	self.weight:SetPos( 10, self.h - 100 )
	self.weight:SetSize( 90, 90 )
	self.weight:SetCircleSize( 40 )

	self:InitializeInventory( )
end

function PANEL:MenuPaint( w, h )

end

function PANEL:InitializeInventory( )
	local inventory = catherine.inventory.Get( )
	local tab = { }
	
	for k, v in pairs( inventory ) do
		local itemTable = catherine.item.FindByID( k )
		if ( !itemTable ) then continue end
		local category = itemTable.category
		tab[ category ] = tab[ category ] or { }
		tab[ category ][ v.uniqueID ] = v
	end
	
	self.inventory = tab
	self.weight:SetWeight( catherine.inventory.GetWeights( ) )
	self:BuildInventory( )
end

function PANEL:BuildInventory( )
	if ( !self.inventory ) then return end
	self.Lists:Clear( )
	local delta = 0
	for k, v in pairs( self.inventory ) do
		local form = vgui.Create( "DForm" )
		form:SetSize( self.Lists:GetWide( ), 64 )
		form:SetName( k )
		form:SetAlpha( 0 )
		form:AlphaTo( 255, 0.5, delta )
		form.Paint = function( pnl, w, h )
			draw.RoundedBox( 0, 0, 0, w, 20, Color( 225, 225, 225, 255 ) )
			draw.RoundedBox( 0, 0, 20, w, 1, Color( 50, 50, 50, 90 ) )
		end
		form.Header:SetFont( "catherine_normal15" )
		form.Header:SetTextColor( Color( 90, 90, 90, 255 ) )
		delta = delta + 0.1

		local lists = vgui.Create( "DPanelList", form )
		lists:SetSize( form:GetWide( ), form:GetTall( ) )
		lists:SetSpacing( 3 )
		lists:EnableHorizontal( true )
		lists:EnableVerticalScrollbar( false )	
		
		form:AddItem( lists )
		
		for k1, v1 in pairs( v ) do
			local w, h = 64, 64
			local itemTable = catherine.item.FindByID( v1.uniqueID )
			local itemDesc = itemTable.GetDesc and itemTable:GetDesc( self.player, itemTable, self.player:GetInvItemData( itemTable.uniqueID ), true ) or nil
			local spawnIcon = vgui.Create( "SpawnIcon" )
			spawnIcon:SetSize( w, h )
			spawnIcon:SetModel( itemTable.model )
			spawnIcon:SetToolTip( "Name : " .. itemTable.name .. "\nDescription : " .. itemTable.desc .. ( itemDesc and "\n" .. itemDesc or "" ) )
			spawnIcon.DoClick = function( )
				catherine.item.OpenMenuUse( v1.uniqueID )
			end
			spawnIcon.DoRightClick = function( )

			end
			spawnIcon.PaintOver = function( pnl, w, h )
				if ( catherine.inventory.IsEquipped( v1.uniqueID ) ) then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( Material( "icon16/accept.png" ) )
					surface.DrawTexturedRect( 5, 5, 16, 16 )
				end
				if ( itemTable.DrawInformation ) then
					itemTable:DrawInformation( self.player, itemTable, w, h, self.player:GetInvItemData( itemTable.uniqueID ) )
				end
				if ( v1.int > 1 ) then
					draw.SimpleText( v1.int, "catherine_normal20", 5, h - 25, Color( 50, 50, 50, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT )
				end
			end
			lists:AddItem( spawnIcon )
		end
		self.Lists:AddItem( form )
	end
end

vgui.Register( "catherine.vgui.inventory", PANEL, "catherine.vgui.menuBase" )

hook.Add( "AddMenuItem", "catherine.vgui.inventory", function( tab )
	tab[ "Inventory" ] = function( menuPnl, itemPnl )
		return vgui.Create( "catherine.vgui.inventory", menuPnl )
	end
end )