--[[
	Copyright (C) 2006-2008 Nymbia

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local L = LibStub('AceLocale-3.0'):GetLocale("SpellBinder")
local SpellBinder = LibStub("AceAddon-3.0"):NewAddon("SpellBinder", "AceConsole-3.0")
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local BOOKTYPE_PET = BOOKTYPE_PET
local options = {
	type = 'group',
	name = L["SpellBinder"],
	args = {}
}
do
	local function open()
		SpellBinder:BuildTable()
		LibStub("AceConfigDialog-3.0"):Open("SpellBinder")
	end
	function SpellBinder:OnInitialize()
		LibStub("AceConfig-3.0"):RegisterOptionsTable("SpellBinder", options, nil)
		self:RegisterChatCommand("sb", open)
		self:RegisterChatCommand("spellbinder", open)
	end
end
do
	local function clearBind(bindnum, bindstr)
		local key = select(bindnum, GetBindingKey(bindstr))
		if not key then
			return
		end
		SetBinding(key)
	end
	local buildspell, builditem, buildmacro
	do
		local function spellBindGet(info)
			local spellname = info.arg
			local bindnum = tonumber(info[#info]:match('%d'))
			return select(bindnum, GetBindingKey('SPELL '..spellname))
		end
		local function spellBindSet(info, v)
			local spellname = info.arg
			local bindnum = tonumber(info[#info]:match('%d'))
			local bindstr = 'SPELL '..spellname
			local bind1, bind2 = GetBindingKey(bindstr)
			clearBind(2, bindstr)
			clearBind(1, bindstr)
			if bind1 == "" then
				bind1 = nil
			end
			if bind2 == "" then
				bind2 = nil
			end
			if bind1 == v then
				if bindnum == 2 then
					bind1 = v
					bind2 = nil
				end
			elseif bind2 == v then
				if bindnum == 1 then
					bind1 = v
					bind2 = nil
				end
			else
				if bindnum == 1 then
					bind1 = v
				else
					bind2 = v
				end
			end
			if bind1 then
				SetBindingSpell(bind1, spellname)
			end
			if bind2 then
				SetBindingSpell(bind2, spellname)
			end
			SaveBindings(2)
		end
		local function spellBindConfirm(info, v)
			if not v then
				return false
			end
			local spellname = info.arg
			local oldaction = GetBindingAction(v)
			if oldaction == "" or oldaction == "SPELL "..spellname then
				return false
			end
			return (L["%s is bound to %s.  Overwrite?"]):format(v, oldaction)
		end
		local function spellBindClear(info)
			local spellname = info.arg
			local bindstr = 'SPELL '..spellname
			clearBind(2, bindstr)
			clearBind(1, bindstr)
			SaveBindings(2)
		end
		function buildschool(tab)
			local tabname, tabicon, offset, num, _, _ = GetSpellTabInfo(tab)
			local new = {
				name = tabname,
				icon = tabicon,
				type = 'group',
				order = tab,
				childGroups = 'select',
				args = {},
			}
			for spellnum = offset + 1, offset + num do
				--local realspellnum = GetKnownSlotFromHighestRankSlot(spellnum)
				local spellname, spellSubName = GetSpellBookItemName(spellnum, BOOKTYPE_SPELL)
                local _, _, _, _, _, _, realspellnum = GetSpellInfo(spellname)
				if not IsPassiveSpell(realspellnum) then
					local spellicon = GetSpellTexture(realspellnum)
					local bind1, bind2 = GetBindingKey("SPELL "..spellname)
					new.args[tostring(spellnum)] = {
						name = spellname,
						icon = spellicon,
						type = 'group',
						order = spellnum,
						set = spellBindSet,
						get = spellBindGet,
						confirm = spellBindConfirm,
						args = {
							bind1 = {
								name = L["Binding 1"],
								type = 'keybinding',
								arg = spellname,
								order = 1,
							},
							bind2 = {
								name = L["Binding 2"],
								type = 'keybinding',
								arg = spellname,
								order = 2,
							},
							unbind = {
								name = L["Clear Bindings"],
								type = 'execute',
								arg = spellname,
								func = spellBindClear,
								confirm = false,
								order = 3,
								width = 'double',
							},
						},
					}
				end
			end
			return new
		end
	end
	do
		local function macroBindGet(info)
			local macroname = info.arg
			local bindnum = tonumber(info[#info]:match('%d'))
			return select(bindnum, GetBindingKey('MACRO '..macroname))
		end
		local function macroBindSet(info, v)
			local macroname = info.arg
			local bindnum = tonumber(info[#info]:match('%d'))
			local bindstr = 'MACRO '..macroname
			local bind1, bind2 = GetBindingKey(bindstr)
			clearBind(2, bindstr)
			clearBind(1, bindstr)
			if bind1 == "" then
				bind1 = nil
			end
			if bind2 == "" then
				bind2 = nil
			end
			if bind1 == v then
				if bindnum == 2 then
					bind1 = v
					bind2 = nil
				end
			elseif bind2 == v then
				if bindnum == 1 then
					bind1 = v
					bind2 = nil
				end
			else
				if bindnum == 1 then
					bind1 = v
				else
					bind2 = v
				end
			end
			if bind1 then
				SetBindingMacro(bind1, macroname)
			end
			if bind2 then
				SetBindingMacro(bind2, macroname)
			end
			SaveBindings(2)
		end
		local function macroBindConfirm(info, v)
			if not v then
				return false
			end
			local macroname = info.arg
			local oldaction = GetBindingAction(v)
			if oldaction == "" or oldaction == "MACRO "..macroname then
				return false
			end
			return (L["%s is bound to %s.  Overwrite?"]):format(v, oldaction)
		end
		local function macroBindClear(info)
			local macroname = info.arg
			local bindstr = 'MACRO '..macroname
			clearBind(2, bindstr)
			clearBind(1, bindstr)
			SaveBindings(2)
		end
		local function makeMacroItem(i)
			local macroname, macroicon = GetMacroInfo(i)
			local bind1, bind2 = GetBindingKey("MACRO "..macroname)
			return {
				name = macroname,
				icon = macroicon,
				type = 'group',
				order = i,
				set = macroBindSet,
				get = macroBindGet,
				confirm = macroBindConfirm,
				args = {
					bind1 = {
						name = L["Binding 1"],
						type = 'keybinding',
						arg = macroname,
						order = 1,
					},
					bind2 = {
						name = L["Binding 2"],
						type = 'keybinding',
						arg = macroname,
						order = 2,
					},
					unbind = {
						name = L["Clear Bindings"],
						type = 'execute',
						arg = macroname,
						func = macroBindClear,
						confirm = false,
						order = 3,
						width = 'double',
					},
				},
			}
		end
		function buildmacro()
			local new = {
				name = MACRO,
				type = 'group',
				order = -1,
				childGroups = 'select',
				args = {},
			}
			local numglobal, numchar = GetNumMacros()
			for i = 1, numglobal do
				new.args[tostring(i)] = makeMacroItem(i)
			end
			for i = 37, numchar+36 do
				new.args[tostring(i)] = makeMacroItem(i)
			end
			return new
		end
	end
	do
		local itemname
		local function itemBindGet(info)
			if not itemname then
				return
			end
			local bindnum = tonumber(info[#info]:match('%d'))
			return select(bindnum, GetBindingKey('ITEM '..itemname))
		end
		local function itemBindSet(info, v)
			local bindnum = tonumber(info[#info]:match('%d'))
			local bindstr = 'ITEM '..itemname
			local bind1, bind2 = GetBindingKey(bindstr)
			clearBind(2, bindstr)
			clearBind(1, bindstr)
			if bind1 == "" then
				bind1 = nil
			end
			if bind2 == "" then
				bind2 = nil
			end
			if bind1 == v then
				if bindnum == 2 then
					bind1 = v
					bind2 = nil
				end
			elseif bind2 == v then
				if bindnum == 1 then
					bind1 = v
					bind2 = nil
				end
			else
				if bindnum == 1 then
					bind1 = v
				else
					bind2 = v
				end
			end
			if bind1 then
				SetBindingItem(bind1, itemname)
			end
			if bind2 then
				SetBindingItem(bind2, itemname)
			end
			SaveBindings(2)
		end
		local function itemBindConfirm(info, v)
			if not v then
				return false
			end
			local oldaction = GetBindingAction(v)
			if oldaction == "" or oldaction == "ITEM "..itemname then
				return false
			end
			return (L["%s is bound to %s.  Overwrite?"]):format(v, oldaction)
		end
		local function itemBindClear(info)
			if not itemname then
				return
			end
			local bindstr = 'ITEM '..itemname
			clearBind(2, bindstr)
			clearBind(1, bindstr)
			SaveBindings(2)
		end
		local function getItem()
			return itemname
		end
		local function setItem(info, item)
			if GetItemCount(item) > 0 then
				itemname = GetItemInfo(item)
			else
				itemname = nil
			end
		end
		function builditem()
			return {
				name = ITEMS,
				type = 'group',
				order = i,
				set = itemBindSet,
				get = itemBindGet,
				confirm = itemBindConfirm,
				args = {
					set = {
						name = "",
						type = 'input',
						order = 1,
						width = 'double',
						get = getItem,
						set = setItem,
					},
					bind1 = {
						name = L["Binding 1"],
						type = 'keybinding',
						arg = macroname,
						order = 2,
					},
					bind2 = {
						name = L["Binding 2"],
						type = 'keybinding',
						arg = macroname,
						order = 3,
					},
					unbind = {
						name = L["Clear Bindings"],
						type = 'execute',
						arg = macroname,
						func = macroBindClear,
						confirm = false,
						order = 4,
						width = 'double',
					},
				},
			}
		end
	end
	function SpellBinder:BuildTable()
		currentitem = nil
		options.args = {
			school1 = buildschool(1),
			school2 = buildschool(2),
			school3 = buildschool(3),
			school4 = buildschool(4),
			item = builditem(),
			macro = buildmacro(),
		}
		--[[if HasPetSpells() then
			options.args.pet = buildpet()
		end]]
	end
end
