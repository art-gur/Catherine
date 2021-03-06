/*Base.uniqueID = "clothing_base"
Base.name = "Clothing Base"
Base.desc = "cloth base"
Base.category = "Clothing"
Base.modelmale = "models/humans/group01/male_01.mdl"
Base.modelfemale = "models/humans/group01/female_01.mdl"
Base.cost = 0
Base.weight = 0
Base.itemData = {
	equipped = false
}
--[[
Base.func = { }
Base.func.equip = {
	text = "Equip this item",
	viewIsEntity = true,
	viewIsMenu = true,
	ismenuRightclickFunc = true,
	func = function( pl, tab, data )
		if ( !pl:HasItem( tab.uniqueID ) ) then
			catherine.item.GiveToCharacter( pl, tab.uniqueID )
		end
		local newData = data or { }
		newData.equipped = true
    if ( catherine.character.GetGlobalVar( pl, "_gender" ) == "male" ) then
      pl:SetModel( Base.modelmale )
    else
      pl:SetModel( Base.modelfemale )
    end
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, itemData = newData } )
	end,
	showFunc = function( pl, tab, key )
		if ( pl:IsEquipped( tab.uniqueID ) ) then
			return false
		end
		return true
	end
}
Base.func.unequip = {
	text = "Unequip this weapon",
	viewIsMenu = true,
	func = function( pl, tab, key )
		if ( IsValid( pl ) ) then
		  pl:SetModel( catherine.character.GetCharacterVar( pl, "permaModel" ) )
		end
		local newData = { }
		newData.equipped = false
		catherine.inventory.Update( pl, "updateData", { uniqueID = tab.uniqueID, itemData = newData } )
	end,
	showFunc = function( pl, tab, key )
		if ( pl:IsEquipped( tab.uniqueID ) ) then
			return true
		end
		return false
	end
}
--]]
if ( SERVER ) then
	hook.Add( "PlayerSpawnedInCharacter", "clothing_base_PlayerSpawnedInCharacter", function( pl )
		local permaModel = catherine.character.GetCharacterVar( pl, "permaModel", nil )
		if ( permaModel == nil ) then
			catherine.character.SetCharacterVar( pl, "permaModel", pl:GetModel( ) )
		end
	end )
end
*/