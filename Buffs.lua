local addonName, vars = ...
local L = vars.L
local addon = RaidBuffStatus
local report = addon.report
local raid = addon.raid
RBS_svnrev["Buffs.lua"] = select(3,string.find("$Revision: 509 $", ".* (.*) .*"))

local profile
function addon:UpdateProfileBuffs()
	profile = addon.db.profile
end

local BSmeta = {}
local BS = setmetatable({}, BSmeta)
local BSI = setmetatable({}, BSmeta)
BSmeta.__index = function(self, key)
	local name, _, icon
	if type(key) == "number" then
		name, _, icon = GetSpellInfo(key)
	else
		geterrorhandler()(("Unknown spell key %q"):format(key))
	end
	if name then
		BS[key] = name
		BS[name] = name
		BSI[key] = icon
		BSI[name] = icon
	else
		BS[key] = false
		BSI[key] = false
		geterrorhandler()(("Unknown spell info key %q"):format(key))
	end
	return self[key]
end

local function SpellName(spellID)
	local name = GetSpellInfo(spellID)
	return name
end

local ITmeta = {}
local ITN = setmetatable({}, ITmeta)
local ITT = setmetatable({}, ITmeta)
ITN.unknown = L["Please relog or reload UI to update the item cache."]
ITT.unknown = "Interface\\Icons\\INV_Misc_QuestionMark"
ITmeta.__index = function(self, key)
	local name, _, icon
	if type(key) == "number" then
		name, _, _, _, _, _, _, _, _, icon = GetItemInfo(key)
		if not name then
			GameTooltip:SetHyperlink("item:"..key..":0:0:0:0:0:0:0")  -- force server to send item info
			GameTooltip:ClearLines();
			name, _, _, _, _, _, _, _, _, icon = GetItemInfo(key)  -- info might not be in the cache yet but worth trying again
		end
	else
		geterrorhandler()(("Unknown item key %q"):format(key))
	end
	if name then
		ITN[key] = name
		ITN[name] = name
		ITT[key] = icon
		ITT[name] = icon
		return self[key]
	end
	return self.unknown
end

local tbcflasks = {
	SpellName(17626), -- Flask of the Titans
	SpellName(17627), -- [Flask of] Distilled Wisdom
	SpellName(17628), -- [Flask of] Supreme Power
	SpellName(17629), -- [Flask of] Chromatic Resistance
	SpellName(28518), -- Flask of Fortification
	SpellName(28519), -- Flask of Mighty Restoration
	SpellName(28520), -- Flask of Relentless Assault
	SpellName(28521), -- Flask of Blinding Light
	SpellName(28540), -- Flask of Pure Death
	SpellName(33053), -- Mr. Pinchy's Blessing
	SpellName(42735), -- [Flask of] Chromatic Wonder
	SpellName(40567), -- Unstable Flask of the Bandit
	SpellName(40568), -- Unstable Flask of the Elder
	SpellName(40572), -- Unstable Flask of the Beast
	SpellName(40573), -- Unstable Flask of the Physician
	SpellName(40575), -- Unstable Flask of the Soldier
	SpellName(40576), -- Unstable Flask of the Sorcerer
	SpellName(41608), -- Relentless Assault of Shattrath
	SpellName(41609), -- Fortification of Shattrath
	SpellName(41610), -- Mighty Restoration of Shattrath
	SpellName(41611), -- Supreme Power of Shattrath
	SpellName(46837), -- Pure Death of Shattrath
	SpellName(46839), -- Blinding Light of Shattrath
	SpellName(67019), -- Flask of the North (WotLK 3.2)
	SpellName(62380), -- Lesser Flask of Resistance  -- pathetic flask
}

local wotlkflasks = {
	SpellName(53755), -- Flask of the Frost Wyrm
	SpellName(53758), -- Flask of Stoneblood
	SpellName(54212), -- Flask of Pure Mojo
	SpellName(53760), -- Flask of Endless Rage
	SpellName(79639), -- Enhanced Agility  - Cata but not as good as other flasks.  Like Flask of the North.
	SpellName(79640), -- Enhanced Intellect  - Cata but not as good as other flasks.  Like Flask of the North.
	SpellName(79638), -- Enhanced Strength  - Cata but not as good as other flasks.  Like Flask of the North.

}

local cataflasks = {
	SpellName(79469), -- Flask of Steelskin
	SpellName(79470), -- Flask of the Draconic Mind
	SpellName(79471), -- Flask of the Winds
	SpellName(79472), -- Flask of Titanic Strength
	SpellName(94160), -- Flask of Flowing Water
}

local tbcbelixirs = {
	SpellName(11390),-- Arcane Elixir
	SpellName(17538),-- Elixir of the Mongoose
	SpellName(17539),-- Greater Arcane Elixir
	SpellName(28490),-- Major Strength
	SpellName(28491),-- Healing Power
	SpellName(28493),-- Major Frost Power
	SpellName(54494),-- Major Agility
	SpellName(28501),-- Major Firepower
	SpellName(28503),-- Major Shadow Power
	SpellName(38954),-- Fel Strength Elixir
	SpellName(33720),-- Onslaught Elixir
	SpellName(54452),-- Adept's Elixir
	SpellName(33726),-- Elixir of Mastery
	SpellName(26276),-- Elixir of Greater Firepower
	SpellName(45373),-- Bloodberry - only works on Sunwell Plateau
	SpellName(48100),-- Intellect - from scroll (not TBC but less good than WotLK elixirs)
	SpellName(58449),-- Strength - from scroll (not TBC but less good than WotLK elixirs)
	SpellName(48104),-- Spirit - from scroll (not TBC but less good than WotLK elixirs)
	SpellName(58451),-- Agility - from scroll (not TBC but less good than WotLK elixirs)
	
}
local tbcgelixirs = {
	SpellName(11348),-- Greater Armor/Elixir of Superior Defense
	SpellName(11396),-- Greater Intellect
	SpellName(24363),-- Mana Regeneration/Mageblood Potion
	SpellName(28502),-- Major Armor/Elixir of Major Defense
	SpellName(28509),-- Greater Mana Regeneration/Elixir of Major Mageblood
	SpellName(28514),-- Empowerment
	SpellName(29626),-- Earthen Elixir
	SpellName(39625),-- Elixir of Major Fortitude
	SpellName(39627),-- Elixir of Draenic Wisdom
	SpellName(39628),-- Elixir of Ironskin
	SpellName(58453),-- Armor - from scroll (not TBC but less good than WotLK elixirs)
	SpellName(48102),-- Stamina - from scroll (not TBC but less good than WotLK elixirs)
}

local wotlkbelixirs = {
	SpellName(28497), -- Mighty Agility
	SpellName(53748), -- Mighty Strength
	SpellName(53749), -- Guru's Elixir
	SpellName(33721), -- Spellpower Elixir
	SpellName(53746), -- Wrath Elixir
	SpellName(60345), -- Armor Piercing
	SpellName(60340), -- Accuracy
	SpellName(60344), -- Expertise
	SpellName(60341), -- Deadly Strikes
	SpellName(60346), -- Lightning Speed
}
local wotlkgelixirs = {
	SpellName(60347), -- Mighty Thoughts
	SpellName(53751), -- Mighty Fortitude
	SpellName(53747), -- Elixir of Spirit
	SpellName(60343), -- Mighty Defense
	SpellName(53763), -- Elixir of Protection
	SpellName(53764), -- Mighty Mageblood
}

local catabelixirs = {
	SpellName(79477), -- Elixir of the Cobra
	SpellName(79481), -- Elixir of Impossible Accuracy
	SpellName(79632), -- Elixir of Mighty Speed
	SpellName(79635), -- Elixir of the Master
	SpellName(79468), -- Ghost Elixir
	SpellName(79474), -- Elixir of the Naga
}

local catagelixirs = {
	SpellName(79480), -- Elixir of Deep Earth
	SpellName(79631), -- Prismatic Elixir
}

--local wotlkgoodtbcflasks = {}
--local wotlkgoodtbcbelixirs = {}
--local wotlkgoodtbcgelixirs = {}

--table.insert(wotlkgoodtbcflasks,SpellName(17627)) -- [Flask of] Distilled Wisdom

--table.insert(wotlkgoodtbcbelixirs,SpellName(33721)) -- Spellpower Elixir
--table.insert(wotlkgoodtbcbelixirs,SpellName(28491))-- Healing Power
--table.insert(wotlkgoodtbcbelixirs,SpellName(54494))-- Major Agility
--table.insert(wotlkgoodtbcbelixirs,SpellName(28503))-- Major Shadow Power

--table.insert(wotlkgoodtbcgelixirs,SpellName(39627))-- Elixir of Draenic Wisdom

--RaidBuffStatus.wotlkgoodtbcflixirs = {}
--for _,v in ipairs (wotlkgoodtbcflasks) do
--	table.insert(RaidBuffStatus.wotlkgoodtbcflixirs,v)
--end
--for _,v in ipairs (wotlkgoodtbcbelixirs) do
--	table.insert(RaidBuffStatus.wotlkgoodtbcflixirs,v)
--end
--for _,v in ipairs (wotlkgoodtbcgelixirs) do
--	table.insert(RaidBuffStatus.wotlkgoodtbcflixirs,v)
--end

--for _,v in ipairs (wotlkgelixirs) do
--	table.insert(wotlkgoodtbcgelixirs,v)
--end
--for _,v in ipairs (wotlkbelixirs) do
--	table.insert(wotlkgoodtbcbelixirs,v)
--end
--for _,v in ipairs (wotlkflasks) do
--	table.insert(wotlkgoodtbcflasks,v)
--end

--for _,v in ipairs (catagelixirs) do
--	table.insert(wotlkgoodtbcgelixirs,v)
--end
--for _,v in ipairs (catabelixirs) do
--	table.insert(wotlkgoodtbcbelixirs,v)
--end
--for _,v in ipairs (cataflasks) do
--	table.insert(wotlkgoodtbcflasks,v)
--end


local oldflasks = {}
local oldbelixirs = {}
local oldgelixirs = {}
for _,v in ipairs (tbcflasks) do
	table.insert(oldflasks,v)
end
for _,v in ipairs (wotlkflasks) do
	table.insert(oldflasks,v)
end
for _,v in ipairs (tbcbelixirs) do
	table.insert(oldbelixirs,v)
end
for _,v in ipairs (wotlkbelixirs) do
	table.insert(oldbelixirs,v)
end
for _,v in ipairs (tbcgelixirs) do
	table.insert(oldgelixirs,v)
end
for _,v in ipairs (wotlkgelixirs) do
	table.insert(oldgelixirs,v)
end


local lessoldflasks = {}
local lessoldbelixirs = {}
local lessoldgelixirs = {}

for _,v in ipairs (wotlkflasks) do
	table.insert(lessoldflasks,v)
end
for _,v in ipairs (cataflasks) do
	table.insert(lessoldflasks,v)
end
for _,v in ipairs (wotlkbelixirs) do
	table.insert(lessoldbelixirs,v)
end
for _,v in ipairs (catabelixirs) do
	table.insert(lessoldbelixirs,v)
end
for _,v in ipairs (wotlkgelixirs) do
	table.insert(lessoldgelixirs,v)
end
for _,v in ipairs (catagelixirs) do
	table.insert(lessoldgelixirs,v)
end



local foods = {
	SpellName(35272), -- Well Fed
	SpellName(44106), -- "Well Fed" from Brewfest
}

local allfoods = {
	SpellName(35272), -- Well Fed
	SpellName(44106), -- "Well Fed" from Brewfest
	SpellName(43730), -- Electrified
	SpellName(43722), -- Enlightened
	SpellName(25661), -- Increased Stamina
	SpellName(25804), -- Rumsey Rum Black Label
}

local fortitude = {
	SpellName(21562), -- Prayer of Fortitude
	SpellName(6307), -- Blood Pact
}

local wild = {
	SpellName(1126), -- Mark of the Wild
	SpellName(20217), -- Blessing of Kings
}

local intellect = {
	SpellName(1459), -- Arcane Intellect
	SpellName(61316), -- Dalaran Brilliance
}

local spirit = {
	SpellName(14752), -- Divine Spirit
	SpellName(27681), -- Prayer of Spirit
}

local shadow = {
	SpellName(27683), -- Prayer of Shadow Protection
}

local auras = {
	SpellName(32223), -- Crusader Aura
	SpellName(465), -- Devotion Aura
	SpellName(7294), -- Retribution Aura
	SpellName(19746), -- Concentration Aura
	SpellName(19726), -- Resistance Aura
}

local aspects = {
	SpellName(13165), -- Aspect of the Hawk
	SpellName(20043), -- Aspect of the Wild
	SpellName(5118), -- Aspect of the Cheetah
	SpellName(13159), -- Aspect of the Pack
	SpellName(82661),  -- Aspect of the Fox	
}

local badaspects = {
	SpellName(5118), -- Aspect of the Cheetah
	SpellName(13159), -- Aspect of the Pack
}

local magearmors = {
	SpellName(6117), -- Mage Armor
	SpellName(7302), -- Frost Armor
	SpellName(30482), -- Molten Armor
}

local dkpresences = {
	SpellName(48266), -- Blood Presence
	SpellName(48263), -- Frost Presence
	SpellName(48265), -- Unholy Presence
}

local seals = {
	SpellName(20165), -- Seal of Insight
	SpellName(20164), -- Seal of Justice
	SpellName(31801), -- Seal of Truth
	SpellName(20154), -- Seal of Righteousness	
}

local blessingofforgottenkings = {
	BS[69378], -- Blessing of Forgotten Kings
	BS[20217], -- Blessing of Kings
}


--local allblessings = {}
--table.insert(allblessings, blessingofkings)
--table.insert(allblessings, blessingofmight)

--local nametoblessinglist = {}
--nametoblessinglist[BS[20217]] = blessingofkings -- Blessing of Kings
--nametoblessinglist[BS[19740]] = blessingofmight -- Blessing of Might
--RaidBuffStatus.nametoblessinglist = nametoblessinglist

local scrollofagility = {
	BS[8115], -- Agility
}
scrollofagility.name = BS[8115] -- Agility
scrollofagility.shortname = L["Agil"]

local scrollofstrength = {
	BS[8118], -- Strength
}
scrollofstrength.name = BS[8118] -- Strength
scrollofstrength.shortname = L["Str"]

local scrollofintellect = {
	BS[8096], -- Intellect
}
scrollofintellect.name = BS[8096] -- Intellect
scrollofintellect.shortname = L["Int"]

local scrollofprotection = {
	BS[42206], -- Protection
}
scrollofprotection.name = BS[42206] -- Protection
scrollofprotection.shortname = L["Prot"]

local scrollofspirit = {
	BS[8112], -- Spirit
}
scrollofspirit.name = BS[8112] -- Spirit
scrollofspirit.shortname = L["Spi"]

--local flaskzones = {
--	gruul = {
--		zones = {
--			L["Gruul's Lair"],
--		},
--		flasks = {
--			SpellName(40567), -- 40567 Unstable Flask of the Bandit
--			SpellName(40568), -- 40568 Unstable Flask of the Elder
--			SpellName(40572), -- 40572 Unstable Flask of the Beast
--			SpellName(40573), -- 40573 Unstable Flask of the Physician
--			SpellName(40575), -- 40575 Unstable Flask of the Soldier
--			SpellName(40576), -- 40576 Unstable Flask of the Sorcerer
--		},
--	},
--	shattrath = {
--		zones = {
--			L["Tempest Keep"],
--			L["Serpentshrine Cavern"],
--			L["Black Temple"],
--			L["Sunwell Plateau"],
--			L["Hyjal Summit"],
--		},
--		flasks = {
--			SpellName(41608), -- 41608 Relentless Assault of Shattrath
--			SpellName(41609), -- 41609 Fortification of Shattrath
--			SpellName(41610), -- 41610 Mighty Restoration of Shattrath
--			SpellName(41611), -- 41611 Sureme Power of Shattrath
--			SpellName(46837), -- 46837 Pure Death of Shattrath
--			SpellName(46839), -- 46839 Blinding Light of Shattrath
--		},
--	},
--}

local roguewepbuffs = {
	-- L["( Poison ?[IVX]*)"], -- Anesthetic Poison, Deadly Poison [IVX]*, Crippling Poison [IVX]*, Wound Poison [IVX]*, Instant Poison [IVX]*, Mind-numbing Poison [IVX]*
	BS[8680],  -- Instant
	BS[2818],  -- Deadly
	BS[3409],  -- Crippling
	BS[13218], -- Wound 
	BS[5760],  -- Mind-numbing
}

local shamanwepbuffs = {
	L["(Flametongue)"], -- Shaman self buff
	L["(Earthliving)"], -- Resto Shaman self buff
	L["(Frostbrand)"], -- Shaman self buff
	L["(Rockbiter)"], -- Shaman self buff
	L["(Windfury)"], -- Shaman self buff
}

function addon:ValidateSpellIDs()
  for checkname, info in pairs(addon.BF) do
    local buffinfo = info.buffinfo
    if buffinfo then
      for _, info in ipairs(buffinfo) do
        if not info[1] or not allclasses[info[1]] or 
	   (info[3] and type(info[3]) ~= "number") then
	  geterrorhandler()("bad buffinfo entry in check: "..checkname)
	end
	local spell = BS[info[2]] -- this throws error if spellid is bad
      end
    end
  end
end

local BF = {
--	pvp = {											-- button name
--		order = 1000,
--		list = "pvplist",								-- list name
--		check = "checkpvp",								-- check name
--		default = false,									-- default state enabled
--		defaultbuff = false,								-- default state report as buff missing
--		defaultwarning = true,								-- default state report as warning
--		defaultdash = false,								-- default state show on dash
--		defaultdashcombat = false,							-- default state show on dash when in combat
--		defaultboss = false,
--		defaulttrash = false,
--		checkzonedout = true,								-- check when unit is not in this zone
--		selfbuff = true,								-- is it a buff the player themselves can fix
--		timer = true,									-- rbs will count how many minutes this buff has been missing/active
--		chat = L["PVP On"],								-- chat report
--		pre = nil,
--		main = function(self, name, class, unit, raid, report)				-- called in main loop
--			if UnitIsPVP(unit.unitid) then
--				table.insert(report.pvplist, name)
--			end
--		end,
--		post = nil,									-- called after main loop
--		icon = "Interface\\Icons\\INV_BannerPVP_02",					-- icon
--		update = function(self)								-- icon text
--			RaidBuffStatus:DefaultButtonUpdate(self, report.pvplist, RaidBuffStatus.db.profile.checkpvp, true, report.pvplist)
--		end,
--		click = function(self, button, down)						-- button click
--			RaidBuffStatus:ButtonClick(self, button, down, "pvp")
--		end,
--		tip = function(self)								-- tool tip
--			RaidBuffStatus:Tooltip(self, L["PVP is On"], report.pvplist, raid.BuffTimers.pvptimerlist)
--		end,
--		whispertobuff = nil,
--		singlebuff = nil,
--		partybuff = nil,
--		raidbuff = nil,
--		other = true,
--	},

	crusader = {
		order = 990,
		list = "crusaderlist",
		check = "checkcrusader",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		class = { PALADIN = true, },
		chat = BS[32223], -- Crusader Aura
		pre = function(self, raid, report)
			report.whoescrusader = {}
		end,
		main = function(self, name, class, unit, raid, report)
			if class == "PALADIN" then
				report.checking.crusader = true
				if unit.hasbuff[BS[32223]] then -- Crusader Aura
					for i=1,40 do
						local name, _, _, _, _, _, caster = UnitBuff("player",i)
						if name == BS[32223] then
							report.whoescrusader[RaidBuffStatus:UnitNameRealm(caster)] = true
							break
						end
					end
--					local _, _, _, _, _, _, _, caster = UnitBuff(unit.unitid, BS[32223]) -- Crusader Aura
--					if caster then
--						report.whoescrusader[RaidBuffStatus:UnitNameRealm(caster)] = true
--					end
				end
			end
		end,
		post = function(self, raid, report)
			for name, _ in pairs(report.whoescrusader) do
				table.insert(report.crusaderlist, name)
			end
		end,
		icon = BSI[32223], -- Crusader Aura
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.crusaderlist, RaidBuffStatus.db.profile.checkcrusader, report.checking.crusader or false, report.crusaderlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "crusader", RaidBuffStatus:SelectPalaAura())
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Paladin has Crusader Aura"], report.crusaderlist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		raidwidebuff = true,
	},

--	shadows = {
--		order = 980,
--		list = "shadowslist",
--		check = "checkshadows",
--		default = false,
--		defaultbuff = false,
--		defaultwarning = true,
--		defaultdash = false,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = true,
--		checkzonedout = false,
--		selfbuff = true,
--		timer = false,
--		chat = L["Shadow Resistance Aura AND Shadow Protection"],
--		main = function(self, name, class, unit, raid, report)
--			if raid.ClassNumbers.PRIEST > 0 then
--				if class == "PALADIN" then
--					report.checking.shadows = true
--					if unit.hasbuff[BS[19891]] then -- Resistance Aura
--						table.insert(report.shadowslist, name)
--					end
--				end
--			end
--		end,
--		post = nil,
--		icon = BSI[27683], -- Shadow Protection
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.shadowslist, RaidBuffStatus.db.profile.checkshadows, report.checking.shadows or false, nil)
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "shadows", RaidBuffStatus:SelectPalaAura())
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Paladin has Shadow Resistance Aura AND Shadow Protection"], report.shadowslist)
--		end,
--		whispertobuff = nil,
--		singlebuff = nil,
--		partybuff = nil,
--		raidbuff = nil,
--	},
	health = {
		order = 970,
		list = "healthlist",
		check = "checkhealth",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = true,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		class = { WARRIOR = true, ROGUE = true, PRIEST = true, DRUID = true, PALADIN = true, HUNTER = true, MAGE = true, WARLOCK = true, SHAMAN = true, DEATHKNIGHT = true, },
		chat = L["Health less than 80%"],
		main = function(self, name, class, unit, raid, report)
			if not unit.isdead then
				if UnitHealth(unit.unitid)/UnitHealthMax(unit.unitid) < 0.8 then
					table.insert(report.healthlist, name)
				end
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_131",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.healthlist, RaidBuffStatus.db.profile.checkhealth, true, report.healthlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "health")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Player has health less than 80%"], report.healthlist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		other = true,
	},

	mana = {
		order = 960,
		list = "manalist",
		check = "checkmana",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = true,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		class = { PRIEST = true, DRUID = true, PALADIN = true, MAGE = true, WARLOCK = true, SHAMAN = true, },
		chat = L["Mana less than 80%"],
		main = function(self, name, class, unit, raid, report)
			if unit.isdead then
				return
			end
			if class == "WARRIOR" or class == "ROGUE" or class == "DEATHKNIGHT" or class == "HUNTER" then
				return
			end
			if class == "DRUID" then
--				if raid.classes.DRUID[name].spec == L["Feral Combat"] then
				if UnitPower(unit.unitid)/UnitPowerMax(unit.unitid) < 0.79 then
					table.insert(report.manalist, name)
				end
				return
--				end
			end
			if UnitPower(unit.unitid)/UnitPowerMax(unit.unitid) < 0.8 then
				table.insert(report.manalist, name)
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_137",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.manalist, RaidBuffStatus.db.profile.checkmana, true, report.manalist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "mana")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Player has mana less than 80%"], report.manalist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		other = true,
	},
	zone = {
		order = 950,
		list = "zonelist",
		check = "checkzone",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = true, -- actually has no effect
		selfbuff = false,
		timer = false,
		core = true,
		chat = L["Different Zone"],
		main = nil, -- done by main code
		post = nil,
		icon = "Interface\\Icons\\INV_Misc_QuestionMark",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.zonelist, RaidBuffStatus.db.profile.checkzone, raid.israid, nil)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "zone")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Player is in a different zone"], nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, report.zonelist)
		end,
		whispertobuff = function(reportl, prefix)
			if not raid.leader or #reportl < 1 then
				return
			end
			if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
				RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.zone.chat .. ">: " .. L["MANY!"], raid.leader)
			else
				RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.zone.chat .. ">: " .. table.concat(reportl, ", "), raid.leader)
			end
		end,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		other = true,
	},

	offline = {
		order = 940,
		list = "offlinelist",
		check = "checkoffline",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = true,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = true, -- actualy has no effect
		selfbuff = false,
		timer = true,
		core = true,
		chat = L["Offline"],
		main = nil, -- done by main code
		post = nil,
		icon = "Interface\\Icons\\INV_Gizmo_FelStabilizer",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.offlinelist, RaidBuffStatus.db.profile.checkoffline, true, nil)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "offline")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Player is Offline"], report.offlinelist, raid.BuffTimers.offlinetimerlist)
		end,
		whispertobuff = function(reportl, prefix)
			if not raid.leader or #reportl < 1 then
				return
			end
			if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
				RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.offline.chat .. ">: " .. L["MANY!"], raid.leader)
			else
				RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.offline.chat .. ">: " .. table.concat(reportl, ", "), raid.leader)
			end
		end,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		other = true,
	},

	afk = {
		order = 930,
		list = "afklist",
		check = "checkafk",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = true,
		selfbuff = true,
		timer = true,
		chat = L["AFK"],
		main = function(self, name, class, unit, raid, report)
			if UnitIsAFK(unit.unitid) then
				table.insert(report.afklist, name)
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\Trade_Fishing",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.afklist, RaidBuffStatus.db.profile.checkafk, true, report.afklist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "afk")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Player is AFK"], report.afklist, raid.BuffTimers.afktimerlist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		other = true,
	},

	dead = {
		order = 920,
		list = "deadlist",
		check = "checkdead",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = true,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = true,
		selfbuff = false,
		timer = true,
		class = { PRIEST = true, DRUID = true, PALADIN = true, SHAMAN = true, },
		chat = L["Dead"],
		main = function(self, name, class, unit, raid, report)
			if unit.isdead then
				table.insert(report.deadlist, name)
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\Spell_Holy_SenseUndead",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.deadlist, RaidBuffStatus.db.profile.checkdead, true, RaidBuffStatus.BF.dead:buffers())
		end,
		click = function(self, button, down)
--			local rezspell = RaidBuffStatus:SelectRezSpell()
			RaidBuffStatus:ButtonClick(self, button, down, "dead", rezspell, nil, nil, true)
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Player is Dead"], report.deadlist, raid.BuffTimers.deadtimerlist, RaidBuffStatus.BF.dead:buffers())
		end,
		singlebuff = true,
		partybuff = false,
		raidbuff = false,
		whispertobuff = function(reportl, prefix)
			local therezers = RaidBuffStatus.BF.dead:buffers()
			for _,name in ipairs(therezers) do
				if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
					RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.dead.chat .. ">: " .. L["MANY!"], name)
				else
					RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.dead.chat .. ">: " .. table.concat(reportl, ", "), name)
				end
			end
		end,
		buffers = function()
			local therezers = {}
			for name,_ in pairs(raid.classes.DRUID) do
				table.insert(therezers, name)
			end
			for name,_ in pairs(raid.classes.PALADIN) do
				table.insert(therezers, name)
			end
			for name,_ in pairs(raid.classes.SHAMAN) do
				table.insert(therezers, name)
			end
			for name,_ in pairs(raid.classes.PRIEST) do
				table.insert(therezers, name)
			end
			return therezers
		end,
		other = true,
	},
	durability = {
		order = 910,
		list = "durabilitylist",
		check = "checkdurability",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = true,
		selfbuff = true,
		timer = false,
		chat = L["Low durability"],
		main = function(self, name, class, unit, raid, report)
			if not raid.israid or raid.isbattle then
				return
			end
			report.checking.durabilty = true
			local broken = RaidBuffStatus.broken[name]
			if broken ~= nil and broken ~= "0" then
				table.insert(report.durabilitylist, name .. "(0)")
			else
				local dura = RaidBuffStatus.durability[name]
				if dura ~= nil and dura < 36 then
					table.insert(report.durabilitylist, name .. "(" .. dura .. ")")
				end
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Chest_Cloth_61",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.durabilitylist, RaidBuffStatus.db.profile.checkdurability, report.checking.durabilty or false, report.durabilitylist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "durability")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Low durability (35% or less)"], report.durabilitylist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		other = true,
	},

	cheetahpack = {
		order = 900,
		list = "cheetahpacklist",
		check = "checkcheetahpack",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { HUNTER = true, },
		chat = L["Aspect Cheetah/Pack On"],
		main = function(self, name, class, unit, raid, report)
			if class == "HUNTER" then
				report.checking.cheetahpack = true
				for _, v in ipairs(badaspects) do
					if unit.hasbuff[v] then
						local caster = unit.hasbuff[v].caster
						if not caster or #caster == 0 then
						   caster = name -- caster is nil when out of range
						end
						if RaidBuffStatus.db.profile.ShowGroupNumber then
					 		caster = caster .. "(" .. unit.group .. ")" 
						end
						-- only report each caster once
						report.cheetahpacklist[caster] = caster
					end
				end
			end
		end,
		post = function(self, raid, report)
		        local l = report.cheetahpacklist
			local gotone = true
			while gotone do
			  gotone = false
		          for k,v in pairs(l) do -- convert to numeric list for sorting
			    if type(k) ~= "number" then
			      l[k] = nil
			      table.insert(l,v) 
			      gotone = true
			      break
			    end
			  end
			end
			RaidBuffStatus:SortNameBySuffix(l)
		end,
		icon = BSI[5118], -- Aspect of the Cheetah
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.cheetahpacklist, RaidBuffStatus.db.profile.checkcheetahpack, report.checking.cheetahpack or false, report.cheetahpacklist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "cheetahpack")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Aspect of the Cheetah or Pack is on"], report.cheetahpacklist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
	},

	oldflixir = {
		order = 895,
		list = "oldflixirlist",
		check = "checkoldflixir",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = false,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		chat = L["Flasked or Elixired but slacking"],
		main = function(self, name, class, unit, raid, report)
			local blist = oldbelixirs
			local glist = oldgelixirs
			local flist = oldflasks
			if RaidBuffStatus.db.profile.WotLKFlasksElixirs then
				blist = tbcbelixirs
				glist = tbcgelixirs
				flist = tbcflasks
			end
			for _, v in ipairs(flist) do
				if unit.hasbuff[v] then
					table.insert(report.oldflixirlist, name .. "(" .. v .. ")")
					return
				end
			end
			for _, v in ipairs(blist) do
				if unit.hasbuff[v] then
					table.insert(report.oldflixirlist, name .. "(" .. v .. ")")
					break
				end
			end
			for _, v in ipairs(glist) do
				if unit.hasbuff[v] then
					table.insert(report.oldflixirlist, name .. "(" .. v .. ")")
					return
				end
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_91",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.oldflixirlist, RaidBuffStatus.db.profile.checkoldflixir, true, report.oldflixirlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "oldflixir")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Flasked or Elixired but slacking"], report.oldflixirlist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
		consumable = true,
	},

	slackingfood = {
		order = 894,
		list = "slackingfoodlist",
		check = "checkslackingfood",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = false,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		chat = L["Well Fed but slacking"],
		main = function(self, name, class, unit, raid, report)
			local hasfood = false
			local slacking = false
			for _, v in ipairs(allfoods) do
				if unit.hasbuff[v] then
					hasfood = true
					break
				end
			end
			if hasfood then
			        local foodz = unit.hasbuff["foodz"]
			        foodz = foodz and foodz:lower()
				slacking = true
				if foodz and (
			   	   foodz:find(L["Stamina increased by 90"]:lower()) or 
				   (RaidBuffStatus.db.profile.foodquality >= 1 and 
				            (foodz:find(L["Stamina increased by 60"]:lower()) or 
					     select(11,UnitBuff(unit.unitid, foods[1])) == 66623))) then -- bountiful feast
						slacking = false
				end
			end
			if slacking then
				table.insert(report.slackingfoodlist, name)
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Misc_Food_67",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.slackingfoodlist, RaidBuffStatus.db.profile.checkslackingfood, true, report.slackingfoodlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "slackingfood")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Well Fed but slacking"], report.slackingfoodlist)
		end,
		partybuff = nil,
		consumable = true,
	},

	righteousfury = {
		order = 890,
		list = "righteousfurylist",
		check = "checkrighteousfury",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		core = true,
		class = { PALADIN = true, },
		chat = BS[25780], -- Righteous Fury
		main = function(self, name, class, unit, raid, report)
			if class == "PALADIN" then
				if raid.classes.PALADIN[name].spec == L["Protection"] then
					report.checking.righteousfury = true
					if not unit.hasbuff[BS[25780]] then -- Righteous Fury
						table.insert(report.righteousfurylist, name)
					end
				end
			end
		end,
		post = nil,
		icon = BSI[25780], -- Righteous Fury
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.righteousfurylist, RaidBuffStatus.db.profile.checkrighteousfury, report.checking.righteousfury or false, report.righteousfurylist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "righteousfury", BS[25780]) -- Righteous Fury
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Protection Paladin with no Righteous Fury"], report.righteousfurylist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
	},


--	vigilancebuff = {
--		order = 876,
--		list = "vigilancebufflist",
--		check = "checkvigilancebuff",
--		default = true,
--		defaultbuff = true,
--		defaultwarning = false,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = false,
--		checkzonedout = false,
--		selfbuff = false,
--		timer = false,
--		class = { WARRIOR = true, },
--		chat = function(report, raid, prefix, channel)
--			prefix = prefix or ""
--			if report.checking.vigilancebuff then
--				if #report.peoplegotvigilance < #raid.VigilanceTalent then
--					RaidBuffStatus:Say(prefix .. "<" .. L["Missing Vigilance"] .. ">: " .. L["Got"] .. " " .. #report.peoplegotvigilance .. " " .. L["expecting"] .. " " .. #raid.VigilanceTalent, nil, nil, channel)
--					RaidBuffStatus:Say(L["Slackers: "] .. table.concat(report.vigilanceslackers, ", "))
--				end
--			end
--		end,
--		pre = function(self, raid, report)
--			report.peoplegotvigilance = {}
--			report.havevigilance = {}
--			report.vigilanceslackers = {}
--		end,
--		main = function(self, name, class, unit, raid, report)
--			if # raid.VigilanceTalent < 1 then
--				return
--			end
--			report.checking.vigilancebuff = true
--			if unit.hasbuff[BS[50725]] then  -- Vigilance
--				table.insert(report.peoplegotvigilance , name)
--				report.havevigilance[name] = unit.hasbuff[BS[50725]].caster  -- Vigilance
--			end
--		end,
--		post = function(self, raid, report)
--			local missing = #raid.VigilanceTalent - #report.peoplegotvigilance
--			if missing > 0 then
--				report.vigilancebufflist = {}
--				for _, name in ipairs(raid.VigilanceTalent) do
--					local found = false
--					for _, caster in pairs(report.havevigilance) do
--						if caster == name then
--							found = true
--							break
--						end
--					end
--					if not found then
--						table.insert(report.vigilancebufflist, "raid")
--						table.insert(report.vigilanceslackers, name)
--					end
--				end
--			end
--		end,
--		icon = BSI[50725],  -- Vigilance
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.vigilancebufflist, RaidBuffStatus.db.profile.checkvigilancebuff, report.checking.vigilancebuff or false)
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "vigilancebuff")
--		end,
--		tip = function(self)
--			if not report.peoplegotvigilance then  -- fixes error when tip being called from option window when not in a party/raid
--				RaidBuffStatus:Tooltip(self, L["Missing Vigilance"])
--			else
--				RaidBuffStatus:Tooltip(self, L["Missing Vigilance"], {L["Got"] .. " " .. #report.peoplegotvigilance, " " .. L["expecting"] .. " " .. #raid.VigilanceTalent}, nil, raid.VigilanceTalent, report.vigilanceslackers, nil, nil, nil, nil, nil, report.havevigilance)
--			end
--		end,
--		singlebuff = true,
--		partybuff = false,
--		raidbuff = false,
--		whispertobuff = function(reportl, prefix)
--			for _,name in pairs(report.vigilanceslackers) do
--				RaidBuffStatus:Say(prefix .. "<" .. L["Missing Vigilance"] .. "> " .. L["Got"] .. " " .. #report.peoplegotvigilance .. " " .. L["expecting"] .. " " .. #raid.VigilanceTalent, name)
--			end
--		end,
--		buffers = function()
--			return raid.VigilanceTalent
--		end,
--		singletarget = true,
--	},


--	earthshield = {
--		order = 875,
--		list = "earthshieldlist",
--		check = "checkearthshield",
--		default = true,
--		defaultbuff = true,
--		defaultwarning = false,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = false,
--		checkzonedout = false,
--		selfbuff = false,
--		timer = false,
--		class = { SHAMAN = true, },
----		chat = BS[974],  -- Earth Shield
--		chat = function(report, raid, prefix, channel)
--			prefix = prefix or ""
--			if report.checking.earthshield then
--				if # report.earthshieldlist > 0 then
--					RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[974] .. ">: " .. table.concat(report.tanksneedingearthshield, ", "), nil, nil, channel)  -- Earth Shield
--					RaidBuffStatus:Say(L["Slackers: "] .. table.concat(report.earthshieldslackers, ", "))
--				end
--			end
--		end,
--		pre = function(self, raid, report)
--			report.tanksneedingearthshield = {}
--			report.tanksgotearthshield = {}
--			report.shamanwithearthshield = {}
--			report.haveearthshield = {}
--			report.earthshieldslackers = {}
--		end,
--		main = function(self, name, class, unit, raid, report)
--			if raid.ClassNumbers.SHAMAN < 1 then
--				return
--			end
--			if class == "SHAMAN" then
--				if raid.classes.SHAMAN[name].specialisations.earthshield then
--					table.insert(report.shamanwithearthshield, name)
--				end
--			elseif unit.istank then
--				if class == "PALADIN" or class == "DRUID" or class == "WARRIOR" or class == "DEATHKNIGHT" then  -- only melee tanks need earthshield
--					report.checking.earthshield = true
--					if unit.hasbuff[BS[974]] then  -- Earth Shield
--						table.insert(report.tanksgotearthshield, name)
--						report.haveearthshield[name] = unit.hasbuff[BS[974]].caster  -- Earth Shield
--					else
--						table.insert(report.tanksneedingearthshield, name)
--					end
--				end
--			end
--		end,
--		post = function(self, raid, report)
--			local numberneeded = #report.tanksneedingearthshield
--			local numberavailable = #report.shamanwithearthshield - #report.tanksgotearthshield
--			if #report.tanksneedingearthshield > 0 and #report.shamanwithearthshield > 0 then
--				report.checking.earthshield = true
--			end
--			if numberneeded > 0 and numberavailable > 0 then
--				report.earthshieldlist = report.tanksneedingearthshield
--				for _, name in ipairs(report.shamanwithearthshield) do
--					local found = false
--					for _, caster in pairs(report.haveearthshield) do
--						if caster == name then
--							found = true
--							break
--						end
--					end
--					if not found then
--						table.insert(report.earthshieldslackers, name)
--					end
--				end
--			end
--		end,
--		icon = BSI[974],  -- Earth Shield
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.earthshieldlist, RaidBuffStatus.db.profile.checkearthshield, report.checking.earthshield or false, RaidBuffStatus.BF.earthshield:buffers())
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "earthshield", BS[974], nil, nil, true)  -- Earth Shield
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Tank missing Earth Shield"], report.earthshieldlist, nil, RaidBuffStatus.BF.earthshield:buffers(), report.earthshieldslackers, nil, nil, nil, nil, nil, report.haveearthshield)
--		end,
--		singlebuff = true,
--		partybuff = false,
--		raidbuff = false,
--		whispertobuff = function(reportl, prefix)
--			for _,name in pairs(report.earthshieldslackers) do
--				RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[974] .. ">: " .. table.concat(reportl, ", "), name)  -- Earth Shield
--			end
--		end,
--		buffers = function()
--			local theshamans = {}
--			for name,rcn in pairs(raid.classes.SHAMAN) do
--				if rcn.specialisations.earthshield then
--					table.insert(theshamans, name)
--				end
--			end
--			return theshamans
--		end,
--		singletarget = true,
--	},

--	focusmagic = {
--		order = 874,
--		list = "focusmagiclist",
--		check = "checkfocusmagic",
--		default = true,
--		defaultbuff = true,
--		defaultwarning = false,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = false,
--		checkzonedout = false,
--		selfbuff = false,
--		timer = false,
--		class = { MAGE = true, },
--		chat = function(report, raid, prefix, channel)
--			prefix = prefix or ""
--			if report.checking.focusmagic then
--				if # report.focusmagiclist > 0 then
--					RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[54646] .. ">: " .. #report.focusmagiclist, nil, nil, channel)  -- Focus Magic
--					RaidBuffStatus:Say(L["Slackers: "] .. table.concat(report.focusmagicslackers, ", "))
--				end
--			end
--		end,
--		pre = function(self, raid, report)
--			report.peoplegotfocusmagic = {}
--			report.havefocusmagic = {}
--			report.magewithfocusmagic = {}
--			report.focusmagicslackers = {}
--		end,
--		main = function(self, name, class, unit, raid, report)
--			if raid.ClassNumbers.MAGE < 1 then
--				return
--			end
--			if class == "MAGE" then
--				if raid.classes.MAGE[name].specialisations.focusmagic then
--					report.checking.focusmagic = true
--					table.insert(report.magewithfocusmagic, name)
--				end
--			end
--			if unit.hasbuff[BS[54646]] then  -- Focus Magic
--				table.insert(report.peoplegotfocusmagic, name)
--				report.havefocusmagic[name] = unit.hasbuff[BS[54646]].caster  -- Focus Magic
--			end  -- todo make it not allow non-magics to have it
--		end,
--		post = function(self, raid, report)
--			local missing = #report.magewithfocusmagic - #report.peoplegotfocusmagic
--			if missing > 0 then
--				report.focusmagiclist = {}
--				for _, name in ipairs(report.magewithfocusmagic) do
--					local found = false
--					for _, caster in pairs(report.havefocusmagic) do
--						if caster == name then
--							found = true
--							break
--						end
--					end
--					if not found then
--						table.insert(report.focusmagiclist, "raid")
--						table.insert(report.focusmagicslackers, name)
--					end
--				end
--			end
--		end,
--		icon = BSI[54646], -- Focus Magic
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.focusmagiclist, RaidBuffStatus.db.profile.checkfocusmagic, report.checking.focusmagic or false, RaidBuffStatus.BF.focusmagic:buffers())
--		end,
----		click = function(self, button, down)
----			RaidBuffStatus:ButtonClick(self, button, down, "focusmagic", BS[54646], nil, nil, true) -- Focus Magic
----		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[54646] .. ": " .. #report.focusmagiclist, nil, nil, RaidBuffStatus.BF.focusmagic:buffers(), report.focusmagicslackers, nil, nil, nil, nil, nil, report.havefocusmagic)
--		end,
--		singlebuff = true,
--		partybuff = false,
--		raidbuff = false,
--		whispertobuff = function(reportl, prefix)
--			prefix = prefix or ""
--			local themages = report.focusmagicslackers
--			for _,name in pairs(themages) do
--				if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
--					RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[54646] .. ">: " .. L["MANY!"], name)
--				else
--					RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[54646] .. ">: " .. table.concat(reportl, ", "), name)
--				end
--			end
--		end,
--		buffers = function()
--			local themages = {}
--			for name,rcn in pairs(raid.classes.MAGE) do
--				if rcn.specialisations.focusmagic then
--					table.insert(themages, name)
--				end
--			end
--			return themages
--		end,
--		singletarget = true,
--	},

	darkintent = {
		order = 865,
		list = "darkintentlist",
		check = "checkdarkintent",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = false,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		class = { WARLOCK = true, },
		chat = function(report, raid, prefix, channel)
			prefix = prefix or ""
			if report.checking.darkintent then
				local thelocks = RaidBuffStatus.BF.darkintent.buffers()
				if #report.peoplegotdarkintent < #thelocks then
					RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[80398] .. ">: " .. L["Got"] .. " " .. #report.peoplegotdarkintent .. " " .. L["expecting"] .. " " .. #thelocks, nil, nil, channel) -- Dark Intent
					RaidBuffStatus:Say(L["Slackers: "] .. table.concat(report.darkintentslackers, ", "))
				end
			end
		end,
		pre = function(self, raid, report)
			report.peoplegotdarkintent = {}
			report.havedarkintent = {}
			report.darkintentslackers = {}
		end,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.WARLOCK < 1 or #RaidBuffStatus.BF.darkintent.buffers() < 1 then
				return
			end
			report.checking.darkintent = true
			local hasbuff = unit.hasbuff[BS[80398]]  -- Dark Intent
			if hasbuff then
				if hasbuff.casterlist then
					for i, caster in ipairs(hasbuff.casterlist) do
						if caster ~= name then  -- don't count the Warlock's buff on themselves
							table.insert(report.peoplegotdarkintent, name)
							report.havedarkintent[name .. "-" .. i] = caster
						end
					end
				elseif hasbuff.caster then
					if hasbuff.caster ~= name then  -- don't count the Warlock's buff on themselves
						table.insert(report.peoplegotdarkintent, name)
						report.havedarkintent[name] = hasbuff.caster
					end
				end
			end
		end,
		post = function(self, raid, report)
			local thelocks = RaidBuffStatus.BF.darkintent.buffers()
			local missing = #thelocks - #report.peoplegotdarkintent
			if missing > 0 then
				report.darkintentlist = {}
				for _, name in ipairs(thelocks) do
					local found = false
					for _, caster in pairs(report.havedarkintent) do
						if caster == name then
							found = true
							break
						end
					end
					if not found then
						table.insert(report.darkintentlist, "raid")
						table.insert(report.darkintentslackers, name)
					end
				end
			end
		end,
		icon = BSI[80398],  -- Dark Intent
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.darkintentlist, RaidBuffStatus.db.profile.checkdarkintent, report.checking.darkintent or false)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "darkintent")
		end,
		tip = function(self)
			if not report.peoplegotdarkintent then  -- fixes error when tip being called from option window when not in a party/raid
				RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[80398]) -- Dark Intent
			else
				RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[80398], {L["Got"] .. " " .. #report.peoplegotdarkintent, " " .. L["expecting"] .. " " .. #RaidBuffStatus.BF.darkintent.buffers()}, nil, RaidBuffStatus.BF.darkintent.buffers(), report.darkintentslackers, nil, nil, nil, nil, nil, report.havedarkintent)  -- Dark Intent
			end
		end,
		singlebuff = true,
		partybuff = false,
		raidbuff = false,
		whispertobuff = function(reportl, prefix)
			thelocks = RaidBuffStatus.BF.darkintent.buffers()
			for _,name in pairs(report.darkintentslackers) do
				RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. BS[80398] .. "> " .. L["Got"] .. " " .. #report.peoplegotdarkintent .. " " .. L["expecting"] .. " " .. #thelocks, name)  -- Dark Intent
			end
		end,
		buffers = function()
			local thelocks = {}
			for name,_ in pairs(raid.classes.WARLOCK) do
				table.insert(thelocks, name) -- should I check zone? maybe not
			end
			return thelocks
		end,
		singletarget = true,
	},
	
	
	soulstone = {
		order = 860,
		list = "nosoulstonelist",
		check = "checksoulstone",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = true,
		defaultdashcombat = true,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = true,
		selfbuff = false,
		timer = false,
		class = { WARLOCK = true, },
		chat = function(report, raid, prefix, channel)
			prefix = prefix or ""
			if report.checking.soulstone then
				if # report.soulstonelist < 1 and RaidBuffStatus.BF.soulstone:lockwithnocd() then
					RaidBuffStatus:Say(prefix .. "<" .. L["No Soulstone detected"] .. ">", nil, nil, channel)
				end
			end
		end,
		pre = function(self, raid, report)
			report.soulstonelist = {}
			report.havesoulstonelist = {}
		end,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.WARLOCK > 0 then
				report.checking.soulstone = true
				if unit.hasbuff[BS[20707]] then -- Soulstone Resurrection
					table.insert(report.soulstonelist, name)
					report.havesoulstonelist[name] = unit.hasbuff[BS[20707]].caster -- Soulstone Resurrection
				end
			end
		end,
		post = function(self, raid, report)
			if # report.soulstonelist < 1 and RaidBuffStatus.BF.soulstone:lockwithnocd() then
				table.insert(report.nosoulstonelist, "raid")
			end
		end,
		icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
		update = function(self)
			if RaidBuffStatus.db.profile.checksoulstone then
				if report.checking.soulstone then
					self:SetAlpha(1)
					if # report.soulstonelist > 0 or not RaidBuffStatus.BF.soulstone:lockwithnocd() then
						self.count:SetText("0")
					else
						self.count:SetText("1")
					end
				else
					self:SetAlpha(0.15)
					self.count:SetText("")
				end
			else
				self:SetAlpha(0.5)
				self.count:SetText("X")
			end
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "soulstone")
		end,
		tip = function(self)
			if not report.soulstonelist then  -- fixes error when tip being called from option window when not in a party/raid
				RaidBuffStatus:Tooltip(self, L["Someone has a Soulstone or not"])
			else
				if #report.soulstonelist < 1 then
					RaidBuffStatus:Tooltip(self, L["Someone has a Soulstone or not"], {L["No Soulstone detected"]}, nil, RaidBuffStatus.BF.soulstone:buffers())
				else
					RaidBuffStatus:Tooltip(self, L["Someone has a Soulstone or not"], nil, nil, RaidBuffStatus.BF.soulstone:buffers(), nil, nil, nil, nil, nil, nil, report.havesoulstonelist)
				end
			end
		end,
		partybuff = nil,
		whispertobuff = function(reportl, prefix)
			local lock = RaidBuffStatus.BF.soulstone:lockwithnocd()
			if lock then
				RaidBuffStatus:Say(prefix .. "<" .. L["No Soulstone detected"] .. ">", lock)
			end
		end,
		buffers = function()
			local thelocks = {}
			local thetime = time()
			for name,_ in pairs(raid.classes.WARLOCK) do
				if RaidBuffStatus:GetLockSoulStone(name) then
--					RaidBuffStatus:Debug(name .. " is on ss cd")
					local thedifference = RaidBuffStatus:GetLockSoulStone(name) - thetime
					if thedifference > 0 then
						name = name .. "(" ..  math.floor(thedifference / 60) .. "m" .. (thedifference % 60) .. "s)"
					end
				end
				table.insert(thelocks, name)
			end
			return thelocks
		end,
		lockwithnocd = function()
			for name,_ in pairs(raid.classes.WARLOCK) do
				if not RaidBuffStatus:GetLockSoulStone(name) or (RaidBuffStatus:GetLockSoulStone(name) and time() > RaidBuffStatus:GetLockSoulStone(name)) then
					return name
				end
			end
			return nil
		end,
		singletarget = true,
	},

--	healthstone = {
--		order = 850,
--		list = "healthstonelist",
--		check = "checkhealthstone",
--		default = true,
--		defaultbuff = false,
--		defaultwarning = true,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = false,
--		defaulttrash = false,
--		checkzonedout = false,
--		selfbuff = false,
--		timer = false,
--		chat = ITN[5512], -- Healthstone
--		pre = function(self, raid, report)
--			if raid.ClassNumbers.WARLOCK < 1 or not raid.israid or raid.isbattle then
--				return
--			end
--			if not RaidBuffStatus.itemcheck.healthstone then
--				RaidBuffStatus.itemcheck.healthstone = {}
--				RaidBuffStatus.itemcheck.healthstone.results = {}
--				RaidBuffStatus.itemcheck.healthstone.list = "healthstonelist"
--				RaidBuffStatus.itemcheck.healthstone.check = "healthstone"
--				RaidBuffStatus.itemcheck.healthstone.next = 0
--				RaidBuffStatus.itemcheck.healthstone.item = "5512" -- Healthstone
--				RaidBuffStatus.itemcheck.healthstone.min = 1
--				RaidBuffStatus.itemcheck.healthstone.frequency = 60 * 3
--				RaidBuffStatus.itemcheck.healthstone.frequencymissing = 30
----				RaidBuffStatus:Debug("RaidBuffStatus.itemcheck.healthstone.item = " .. RaidBuffStatus.itemcheck.healthstone.item)
--			end
--			report.healthstonelistunknown = {}
--			report.healthstonelistgotone = {}
--		end,
--		main = function(self, name, class, unit, raid, report)
--			if raid.ClassNumbers.WARLOCK < 1 or not raid.israid or raid.isbattle then
--				return
--			end
--			report.checking.healthstone = true
--			local stones = RaidBuffStatus.itemcheck.healthstone.results[name]
--			if stones == nil then
--				table.insert(report.healthstonelistunknown, name)
--			elseif stones < RaidBuffStatus.itemcheck.healthstone.min then
--				table.insert(report.healthstonelist, name)
--			else
--				table.insert(report.healthstonelistgotone, name)
--			end
--		end,
--		icon = BSI[34130], -- Healthstone
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.healthstonelist, RaidBuffStatus.db.profile.checkhealthstone, report.checking.healthstone or false, RaidBuffStatus.BF.healthstone:buffers())
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "healthstone")
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Missing "] .. ITN[5512], report.healthstonelist, nil, RaidBuffStatus.BF.healthstone:buffers(), nil, nil, nil, report.healthstonelistunknown, nil, nil, report.healthstonelistgotone) -- Healthstone
--		end,
--		partybuff = nil,
--		whispertobuff = function(reportl, prefix)
--			if RaidBuffStatus.soulwelllastseen > GetTime() then -- whisper the slackers instead of the locks as a soul well is up
--				if #reportl > 0 then
--					for _, v in ipairs(reportl) do
--						local name = v
--						if v:find("%(") then
--							name = string.sub(v, 1, v:find("%(") - 1)
--						end
--						RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. ITN[5512] .. ">: " .. v, name) -- Healthstone
--					end
--				end
--			else
--				local thelocks = RaidBuffStatus.BF.healthstone:buffers()
--				for _,name in pairs(thelocks) do
--					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
--						RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. ITN[5512] .. ">: " .. L["MANY!"], name) -- Healthstone
--					else
--						RaidBuffStatus:Say(prefix .. "<" .. L["Missing "] .. ITN[5512] .. ">: " .. table.concat(reportl, ", "), name) -- Healthstone
--					end
--				end
--			end
--		end,
--		buffers = function()
--			local thelocks = {}
--			for name,rcn in pairs(raid.classes.WARLOCK) do
--				table.insert(thelocks, name)
--			end
--			return thelocks
--		end,
--		consumable = true,
--	},

--	flaskofbattle = {
--		order = 840,
--		list = "flaskofbattlelist",
--		check = "checkflaskofbattle",
--		default = true,
--		defaultbuff = false,
--		defaultwarning = true,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = false,
--		defaulttrash = false,
--		checkzonedout = false,
--		selfbuff = false,
--		timer = false,
--		chat = nil,
--		pre = function(self, raid, report)
--			if not raid.israid then
--				return
--			end
--			if not RaidBuffStatus.itemcheck.flaskofbattle then
--				RaidBuffStatus.itemcheck.flaskofbattle = {}
--				RaidBuffStatus.itemcheck.flaskofbattle.results = {}
--				RaidBuffStatus.itemcheck.flaskofbattle.list = "flaskofbattlelist"
--				RaidBuffStatus.itemcheck.flaskofbattle.check = "flaskofbattle"
--				RaidBuffStatus.itemcheck.flaskofbattle.next = 0
--				RaidBuffStatus.itemcheck.flaskofbattle.item = "65455" -- Flask of Battle
--				RaidBuffStatus.itemcheck.flaskofbattle.min = 0
--				RaidBuffStatus.itemcheck.flaskofbattle.frequency = 60 * 3
--				RaidBuffStatus.itemcheck.flaskofbattle.frequencymissing = 60 * 3
--			end
--			report.flaskofbattlelistunknown = {}
--			report.flaskofbattlelistgotone = {}
--		end,
--		main = function(self, name, class, unit, raid, report)
--			if not raid.israid then
--				return
--			end
--			report.checking.flaskofbattle = true
--			local flasks = RaidBuffStatus.itemcheck.flaskofbattle.results[name]
--			if flasks == nil then
--				table.insert(report.flaskofbattlelistunknown, name)
--			elseif flasks >= 1 then
--				report.flaskofbattlelistgotone[name] = flasks
--			end
--		end,
--		icon = ITT[65455], -- Flask of Battle
--		iconfix = function(self) -- to handle when server is slow to get the icon
--			if RaidBuffStatus.BF.flaskofbattle.icon == "Interface\\Icons\\INV_Misc_QuestionMark" then
--				RaidBuffStatus.BF.flaskofbattle.icon = ITT[65455] -- Flask of Battle
--				if RaidBuffStatus.BF.flaskofbattle.icon == "Interface\\Icons\\INV_Misc_QuestionMark" then
--					return true
--				end
--			end
--			return false
--		end,
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.flaskofbattlelist, RaidBuffStatus.db.profile.checkflaskofbattle, report.checking.flaskofbattle or false)
--			if self.count:GetText() ~= "X" then
--				self.count:SetText("")
--			end
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "flaskofbattle")
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, ITN[65455] .. L[" in their bags"], nil, nil, nil, nil, nil, nil, report.flaskofbattlelistunknown, nil, nil, nil, nil, report.flaskofbattlelistgotone) -- Flask of Battle
--		end,
--		partybuff = nil,
--		whispertobuff = nil,
--		buffers = nil,
--		consumable = true,
--	},

--	lockshards = {
--		order = 830,
--		list = "lockshardslist",
--		check = "checklockshards",
--		default = true,
--		defaultbuff = false,
--		defaultwarning = true,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = true,
--		checkzonedout = false,
--		selfbuff = false,
--		timer = false,
--		chat = ITN[6265], -- Soul Shard
--		pre = function(self, raid, report)
--			if raid.ClassNumbers.WARLOCK < 1 or not oRA or not raid.israid or raid.isbattle then
--				return
--			end
--			if not RaidBuffStatus.itemcheck.lockshards then
--				RaidBuffStatus.itemcheck.lockshards = {}
--				RaidBuffStatus.itemcheck.lockshards.results = {}
--				RaidBuffStatus.itemcheck.lockshards.list = "lockshardslist"
--				RaidBuffStatus.itemcheck.lockshards.check = "lockshards"
--				RaidBuffStatus.itemcheck.lockshards.next = 0
--				RaidBuffStatus.itemcheck.lockshards.item = "6265" -- Soul Shard
--				RaidBuffStatus.itemcheck.lockshards.min = 1
--				RaidBuffStatus.itemcheck.lockshards.frequency = 60 * 10
--				RaidBuffStatus.itemcheck.lockshards.frequencymissing = 60 * 3
	--		end
	--		report.lockshardslistunknown = {}
	--		report.lockshardslistcount = {}
	--	end,
	--	main = function(self, name, class, unit, raid, report)
	--		if class ~= "WARLOCK" or not oRA or not raid.israid or raid.isbattle then
	--			return
	--		end
	--		report.checking.lockshards = true
	--		local items = RaidBuffStatus.itemcheck.lockshards.results[name]
	--		if items == nil then
	--			table.insert(report.lockshardslistunknown, name)
	--		else
	--			if items < RaidBuffStatus.itemcheck.lockshards.min then
	--				table.insert(report.lockshardslist, name)
	--			end
	--			table.insert(report.lockshardslistcount, name .. "[" .. items .. "]")
	--		end
	--	end,
	--	icon = ITT[6265], -- Soul Shard
	--	update = function(self)
	--		RaidBuffStatus:DefaultButtonUpdate(self, report.lockshardslist, RaidBuffStatus.db.profile.checklockshards, report.checking.lockshards or false, report.lockshardslist)
	--	end,
	--	click = function(self, button, down)
	--		RaidBuffStatus:ButtonClick(self, button, down, "lockshards")
	--	end,
	--	tip = function(self)
	--		RaidBuffStatus:Tooltip(self, L["Missing "] .. ITN[6265], report.lockshardslist, nil, nil, nil, nil, report.lockshardslistcount, report.lockshardslistunknown) -- Soul Shard
	--	end,
	--	partybuff = nil,
	--},

	food = {
		order = 500,
		list = "foodlist",
		check = "checkfood",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		core = true,
		class = { WARRIOR = true, ROGUE = true, PRIEST = true, DRUID = true, PALADIN = true, HUNTER = true, MAGE = true, WARLOCK = true, SHAMAN = true, DEATHKNIGHT = true, },
		chat = BS[35272], -- Well Fed
		main = function(self, name, class, unit, raid, report)
			local missingbuff = true
			local foodz = unit.hasbuff["foodz"]
			foodz = foodz and foodz:lower()
			if RaidBuffStatus.db.profile.foodquality == 0 then
				if foodz and foodz:find(L["Stamina increased by 90"]:lower()) then
					missingbuff = false
				end
			elseif RaidBuffStatus.db.profile.foodquality == 1 then
				if foodz and 
				  ( foodz:find(L["Stamina increased by 60"]:lower()) or 
				    foodz:find(L["Stamina increased by 90"]:lower()) or
				    select(11,UnitBuff(unit.unitid, foods[1])) == 66623) then -- bountiful feast
						missingbuff = false
				end
			else
				for _, v in ipairs(foods) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
			end
			if missingbuff then
				table.insert(report.foodlist, name)
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Misc_Food_74",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.foodlist, RaidBuffStatus.db.profile.checkfood, true, report.foodlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "food")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Not Well Fed"], report.foodlist)
		end,
		partybuff = nil,
		consumable = true,
	},
	
	flask = {
		order = 490,
		list = "flasklist",
		check = "checkflaskir",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		core = true,
		class = { WARRIOR = true, ROGUE = true, PRIEST = true, DRUID = true, PALADIN = true, HUNTER = true, MAGE = true, WARLOCK = true, SHAMAN = true, DEATHKNIGHT = true, },
		chat = L["Flask or two Elixirs"],
		pre = function(self, raid, report)
			report.belixirlist = {}
			report.gelixirlist = {}
		end,
		main = function(self, name, class, unit, raid, report)
			report.checking.flaskir = true
			local cflasks = cataflasks
			local cbelixirs = catabelixirs
			local cgelixirs = catagelixirs
			if RaidBuffStatus.db.profile.WotLKFlasksElixirs then
				cflasks = lessoldflasks
				cbelixirs = lessoldbelixirs
				cgelixirs = lessoldgelixirs
			end
			local missingbuff = true
			for _, v in ipairs(cflasks) do
				if unit.hasbuff[v] then
					missingbuff = false
					break
				end
			end
			if missingbuff then
				local numbbelixir = 0
				local numbgelixir = 0
				for _, v in ipairs(cbelixirs) do
					if unit.hasbuff[v] then
						numbbelixir = 1
						break
					end
				end
				for _, v in ipairs(cgelixirs) do
					if unit.hasbuff[v] then
						numbgelixir = 1
						break
					end
				end
				local totalelixir = numbbelixir + numbgelixir
				if totalelixir == 0 then
					table.insert(report.flasklist, name) -- no flask or elixir
				elseif totalelixir == 1 then
					if numbbelixir == 0 then
						table.insert(report.belixirlist, name)
					else
						table.insert(report.gelixirlist, name)
					end
				end
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_119",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.flasklist, RaidBuffStatus.db.profile.checkflaskir, true, report.flasklist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "flask")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing a Flask or two Elixirs"], report.flasklist)
		end,
		partybuff = nil,
		consumable = true,
	},
	belixir = {
		order = 480,
		list = "belixirlist",
		check = "checkflaskir",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		core = true,
		class = { WARRIOR = true, ROGUE = true, PRIEST = true, DRUID = true, PALADIN = true, HUNTER = true, MAGE = true, WARLOCK = true, SHAMAN = true, DEATHKNIGHT = true, },
		chat = L["Battle Elixir"],
		pre = nil,
		main = nil,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_111",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.belixirlist, RaidBuffStatus.db.profile.checkflaskir, true, report.belixirlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "flask")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing a Battle Elixir"], report.belixirlist)
		end,
		partybuff = nil,
		consumable = true,
	},
	
	gelixir = {
		order = 470,
		list = "gelixirlist",
		check = "checkflaskir",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		core = true,
		class = { WARRIOR = true, ROGUE = true, PRIEST = true, DRUID = true, PALADIN = true, HUNTER = true, MAGE = true, WARLOCK = true, SHAMAN = true, DEATHKNIGHT = true, },
		chat = L["Guardian Elixir"],
		pre = nil,
		main = nil,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_158",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.gelixirlist, RaidBuffStatus.db.profile.checkflaskir, true, report.gelixirlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "flask")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing a Guardian Elixir"], report.gelixirlist)
		end,
		partybuff = nil,
		consumable = true,
	},

--	flaskzone = {
--		order = 465,
--		list = "flaskzonelist",
--		check = "checkflaskzone",
--		default = false,
--		defaultbuff = false,
--		defaultwarning = true,
--		defaultdash = false,
--		defaultdashcombat = false,
--		defaultboss = false,
--		defaulttrash = false,
--		checkzonedout = false,
--		selfbuff = true,
--		timer = false,
--		chat = L["Wrong flask for this zone"],
--		pre = nil,
--		main = nil,
--		post = nil,
--		icon = "Interface\\Icons\\INV_Potion_35",
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.flaskzonelist, RaidBuffStatus.db.profile.flaskzone, report.checking.flaskir or false, report.flaskzonelist)
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "flaskzone")
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Wrong flask for this zone"], report.flaskzonelist)
--		end,
--		partybuff = nil,
--	},
	
	wepbuff = {
		order = 464,
		list = "wepbufflist",
		check = "checkwepbuff",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		class = { ROGUE = true, SHAMAN = true, },
		chat = L["Weapon buff"],
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			local bufflist = false
			local dualw = false
			if class == "SHAMAN" then
				bufflist = shamanwepbuffs
				if raid.classes.SHAMAN[name].specialisations.dualwield then
					dualw = true
				end
			elseif class == "ROGUE" then
				bufflist = roguewepbuffs
				dualw = true
			else
				return
			end
			if _G.InspectFrame and _G.InspectFrame:IsShown() then
				return -- can't inspect at same time as UI
			end
			if not CanInspect(unit.unitid) then
				return
			end
			report.checking.wepbuff = true
			local missingbuffmh = true
			local missingbuffoh = true
			local notified
			RBSToolScanner:Reset()
			RBSToolScanner:SetInventoryItem(unit.unitid, 16)
			if RBSToolScanner:NumLines() < 1 then
				if not UnitIsUnit(unit.unitid, "player") then
				   local lastcheck = RaidBuffStatus.lastweapcheck[unit.guid] or 0
				   local failed = lastcheck and lastcheck < 0
				   if failed then lastcheck = -lastcheck end
				   if GetTime() < lastcheck + 5*60 then
					RaidBuffStatus:Debug("skipping weapcheck for:" .. unit.unitid)
					if failed then
					  table.insert(report.wepbufflist, name)
				        end	
				        return
				   else
					RaidBuffStatus:Debug("having to call notifyinspect for:" .. unit.unitid)
					NotifyInspect(unit.unitid)
					notified = unit.unitid
					RaidBuffStatus.lastweapcheck[unit.guid] = GetTime()
				   end
				else
					RaidBuffStatus:Debug("skipping call notifyinspect for:" .. unit.unitid)
				end
				RBSToolScanner:ClearLines()
				RBSToolScanner:SetInventoryItem(unit.unitid, 16)
			end
			for _,buff in ipairs(bufflist) do
				if RBSToolScanner:Find(buff) then
					missingbuffmh = false
					break
				end
			end
			if dualw then
				RBSToolScanner:Reset()
				RBSToolScanner:SetInventoryItem(unit.unitid, 17)
				if RBSToolScanner:NumLines() > 1 then
					for _,buff in ipairs(bufflist) do
						if RBSToolScanner:Find(buff) then
							missingbuffoh = false
							break
						end
					end
				else
					missingbuffoh = false -- nothing equipped
				end
			end
			if missingbuffmh or (dualw and missingbuffoh) then
				table.insert(report.wepbufflist, name)
			        RaidBuffStatus.lastweapcheck[unit.guid] = -GetTime()
			end
			if notified then
			  ClearInspectPlayer(notified)
			end
		end,
		post = nil,
		icon = "Interface\\Icons\\INV_Potion_101",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.wepbufflist, RaidBuffStatus.db.profile.checkwepbuff, report.checking.wepbuff or false, report.wepbufflist)
		end,
		click = function(self, button, down)
			local class = select(2, UnitClass("player"))
			local guid = UnitGUID("player")        
			local buffspell = nil
			local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
			local itemslot = nil
			local bagitem = nil
			if not hasMainHandEnchant or mainHandExpiration < 15*60*1000 then
				itemslot = GetInventorySlotInfo("MainHandSlot")
			elseif not hasOffHandEnchant or offHandExpiration < 15*60*1000 then
				itemslot = GetInventorySlotInfo("SecondaryHandSlot")
			end
			if class == "SHAMAN" then
--				if GT:GUIDHasTalent(guid, BS[974]) then -- Earth Shield
--					buffspell = BS[51730] -- earthliving weapon
--				elseif GT:GUIDHasTalent(guid, BS[16166]) then -- Elemental Mastery
--					buffspell = BS[8024] -- flametongue weapon
--			elseif GT:GUIDHasTalent(guid, BS[17364]) then -- Storm Strike
--				if GT:GUIDHasTalent(guid, BS[60103]) and itemslot == GetInventorySlotInfo("SecondaryHandSlot") then -- Lava Lash
--					buffspell = BS[8024] -- flametongue weapon for off hand    
--				else    
--					buffspell = BS[8232] -- windfury weapon  for main hand
--				end
--			else -- dunno
				buffspell = nil     
--			end
			elseif class == "ROGUE" then
				local deadlypoison = { 43233, 43232, 22054, 22053, 20844, 8985, 8984, 2893, 2892 }
				local instantpoison = { 43231, 43230, 21927, 8928, 8927, 8926, 6950, 6949, 6947 }  
				local woundpoison = { 43235, 43234, 22055, 10922, 10921, 10920, 10918 }  
				local anestheticpoison = { 43237, 21835 }  
				local cripplingpoison = { 3775 }      
				local mindnumbingpoison = { 5237 }         
				local poisontype
--				local MHspeed, OHspeed = UnitAttackSpeed("player")
				MHspeed = MHspeed or 100
				OHspeed = OHspeed or 50
				local MHpoison, OHpoison
				if (MHspeed > OHspeed) then -- could possibly have an option to customize poison types (eg for pvp)
					MHpoison = instantpoison
					OHpoison = deadlypoison 
				else
					MHpoison = deadlypoison
					OHpoison = instantpoison
				end
				if itemslot == GetInventorySlotInfo("MainHandSlot") then -- main-hand poison
					poisontype = MHpoison
				else -- off-hand poison
					poisontype = OHpoison
				end
				for _,sid in ipairs(poisontype) do
					local _, _, _, _, reqLevel = GetItemInfo(sid)          
					if (IsUsableItem(sid) and reqLevel <= UnitLevel("player")) then
						bagitem = ITN[sid]
						break
					end
				end
			end
			RaidBuffStatus:ButtonClick(self, button, down, "wepbuff", buffspell, nil, nil, nil, bagitem, itemslot)
			end,
			tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing a temporary weapon buff"], report.wepbufflist)
		end,
		partybuff = nil,
		consumable = true,
	},

	intellect = {
		order = 450,
		list = "intellectlist",
		check = "checkintellect",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		core = true,
		class = { MAGE = true, },
		chat = BS[1459], -- Arcane Intellect
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.MAGE > 0 then
				report.checking.intellect = true
				if class ~= "ROGUE" and class ~= "WARRIOR" and class ~= "DEATHKNIGHT" and class ~= "HUNTER" then
					local missingbuff = true
					for _, v in ipairs(intellect) do
						if unit.hasbuff[v] then
							missingbuff = false
							break
						end
					end
					if missingbuff then
						if RaidBuffStatus.db.profile.ShowGroupNumber then
							table.insert(report.intellectlist, name .. "(" .. unit.group .. ")" )
						else
							table.insert(report.intellectlist, name)
						end
					end
				end
			end
		end,
		post = function(self, raid, report)
			RaidBuffStatus:SortNameBySuffix(report.intellectlist)
		end,
		icon = BSI[1459], -- Arcane Intellect
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.intellectlist, RaidBuffStatus.db.profile.checkintellect, report.checking.intellect or false, RaidBuffStatus.BF.intellect:buffers())
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "intellect", BS[1459]) -- Arcane Intellect
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[1459], report.intellectlist, nil, RaidBuffStatus.BF.intellect:buffers())
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			for name,_ in pairs(raid.classes.MAGE) do
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.intellect.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.intellect.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			local themages = {}
			for name,_ in pairs(raid.classes.MAGE) do
				table.insert(themages, name)
			end
			return themages
		end,
	},

	wild = {
		order = 440,
		list = "wildlist",
		check = "checkwild",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		core = true,
		class = { DRUID = true, },
		chat = BS[1126], -- Mark of the Wild
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.DRUID > 0 then
				report.checking.wild = true
				local missingbuff = true
				for _, v in ipairs(wild) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
				if missingbuff then
					if RaidBuffStatus.db.profile.ShowGroupNumber then
						table.insert(report.wildlist, name .. "(" .. unit.group .. ")" )
					else
						table.insert(report.wildlist, name)
					end
				end
			end
		end,
		post = function(self, raid, report)
			RaidBuffStatus:SortNameBySuffix(report.wildlist)
		end,
		icon = BSI[1126], -- Mark of the Wild
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.wildlist, RaidBuffStatus.db.profile.checkwild, report.checking.wild or false, RaidBuffStatus.BF.wild:buffers())
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "wild", BS[1126]) -- Mark of the Wild
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[1126], report.wildlist, nil, RaidBuffStatus.BF.wild:buffers())
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			local thedruids = RaidBuffStatus.BF.wild:buffers()
			for _,name in ipairs(thedruids) do
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.wild.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.wild.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			local thedruids = {}
			for name,rcn in pairs(raid.classes.DRUID) do
			     table.insert(thedruids, name)
			end
			return thedruids
		end,
	},
	

	fortitude = {
		order = 430,
		list = "fortitudelist",
		check = "checkfortitude",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		core = true,
		class = { PRIEST = true, },
		chat = BS[21562], -- Prayer of Fortitude
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.PRIEST > 0 then
				report.checking.fortitude = true
				local missingbuff = true
				for _, v in ipairs(fortitude) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
				if missingbuff then
					if RaidBuffStatus.db.profile.ShowGroupNumber then
						table.insert(report.fortitudelist, name .. "(" .. unit.group .. ")" )
					else
						table.insert(report.fortitudelist, name)
					end
				end
			end
		end,
		post = function(self, raid, report)
			RaidBuffStatus:SortNameBySuffix(report.fortitudelist)
		end,
		icon = BSI[21562], -- Prayer of Fortitude
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.fortitudelist, RaidBuffStatus.db.profile.checkfortitude, report.checking.fortitude or false, RaidBuffStatus.BF.fortitude:buffers())
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "fortitude", BS[21562]) -- Prayer of Fortitude 
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[21562], report.fortitudelist, nil, RaidBuffStatus.BF.fortitude:buffers()) -- Prayer of Fortitude
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			local thepriests = RaidBuffStatus.BF.fortitude:buffers()
			for _,name in ipairs(thepriests) do
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.fortitude.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.fortitude.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			local thepriests = {}
			local maxpoints = 0
			for name,rcn in pairs(raid.classes.PRIEST) do
  			        table.insert(thepriests, name)
  		        end
			return thepriests
		end,
	},

	runescrollfortitude = {
		order = 425,
		list = "runescrollfortitudelist",
		check = "checkrunescrollfortitude",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		chat = BS[69377], -- Fortitude
		iconfix = function(self) -- to handle when server is slow to get the icon
			if RaidBuffStatus.BF.runescrollfortitude.icon == "Interface\\Icons\\INV_Misc_QuestionMark" then
				RaidBuffStatus.BF.runescrollfortitude.icon = ITT[49632] -- Runescroll of Fortitude
				if RaidBuffStatus.BF.runescrollfortitude.icon == "Interface\\Icons\\INV_Misc_QuestionMark" then
					return true
				end
			end
			return false
		end,
		pre = function(self, raid, report)
			if raid.ClassNumbers.PRIEST > 0 or not raid.israid or raid.isbattle then
				return
			end
			if not RaidBuffStatus.itemcheck.runescrollfortitude then
				RaidBuffStatus.itemcheck.runescrollfortitude = {}
				RaidBuffStatus.itemcheck.runescrollfortitude.results = {}
				RaidBuffStatus.itemcheck.runescrollfortitude.list = "runescrollfortitudelist"
				RaidBuffStatus.itemcheck.runescrollfortitude.check = "runescrollfortitude"
				RaidBuffStatus.itemcheck.runescrollfortitude.next = 0
				RaidBuffStatus.itemcheck.runescrollfortitude.item = "49632" -- Runescroll of Fortitude
				RaidBuffStatus.itemcheck.runescrollfortitude.min = 0
				RaidBuffStatus.itemcheck.runescrollfortitude.frequency = 60 * 5
				RaidBuffStatus.itemcheck.runescrollfortitude.frequencymissing = 60 * 5
			end
		end,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.PRIEST > 0 then
				return
			end
			report.checking.runescrollfortitude = true
			if not unit.hasbuff[BS[69377]] and  -- Fortitude
			   not unit.hasbuff[BS[79105]] and  -- Power Word: Fortitude
			   not unit.hasbuff[BS[90364]] and  -- Qiraji Fortitude
			   not unit.hasbuff[BS[469]]   and  -- Commanding Shout
			   not unit.hasbuff[BS[6307]]  then -- Blood Pact
				table.insert(report.runescrollfortitudelist, name)
			end
		end,
		post = nil,
		icon = ITT[49632], -- Runescroll of Fortitude
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.runescrollfortitudelist, RaidBuffStatus.db.profile.checkrunescrollfortitude, report.checking.runescrollfortitude or false, RaidBuffStatus.BF.runescrollfortitude:buffers())
		end,
		click = function(self, button, down)
			local scroll = ITN[62251] -- Runescroll of Fortitude II 
			if not RaidBuffStatus:GotReagent(scroll) then -- use the best available
			  scroll = ITN[49632] -- Runescroll of Fortitude
			end
			RaidBuffStatus:ButtonClick(self, button, down, "runescrollfortitude", nil, nil, nil, nil, scroll)
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. ITN[49632], report.runescrollfortitudelist, nil, RaidBuffStatus.BF.runescrollfortitude:buffers()) -- Runescroll of Fortitude
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			local thebuffers = RaidBuffStatus.BF.runescrollfortitude:buffers()
			if not thebuffers then
				return
			end
			for _,name in ipairs(thebuffers) do
				name = string.sub(name, 1, name:find("%(") - 1)
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.runescrollfortitude.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.runescrollfortitude.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			if not RaidBuffStatus.itemcheck.runescrollfortitude then
				return
			end
			local thebuffers = {}
				for _,rc in pairs(raid.classes) do
					for name,_ in pairs(rc) do
						local items = RaidBuffStatus.itemcheck.runescrollfortitude.results[name] or 0
						if items > 0 then
							table.insert(thebuffers, name .. "(" .. items .. ")")
						end
					end
				end
			return thebuffers
		end,
		consumable = true,
	},

	shadow = {
		order = 420,
		list = "shadowlist",
		check = "checkshadow",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		core = true,
		class = { PRIEST = true, },
		chat = BS[27683], -- Shadow Protection
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.PRIEST > 0 then
				report.checking.shadow = true
				local missingbuff = true
				for _, v in ipairs(shadow) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
				if missingbuff then
					if RaidBuffStatus.db.profile.ShowGroupNumber then
						table.insert(report.shadowlist, name .. "(" .. unit.group .. ")" )
					else
						table.insert(report.shadowlist, name)
					end
				end
			end
		end,
		post = function(self, raid, report)
			RaidBuffStatus:SortNameBySuffix(report.shadowlist)
		end,
		icon = BSI[27683], -- Shadow Protection
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.shadowlist, RaidBuffStatus.db.profile.checkshadow, report.checking.shadow or false, RaidBuffStatus.BF.shadow:buffers())
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "shadow", BS[27683]) -- Shadow Protection 
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[27683], report.shadowlist, nil, RaidBuffStatus.BF.shadow:buffers())
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			for name,_ in pairs(raid.classes.PRIEST) do
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.shadow.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.shadow.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			local thepriests = {}
			for name,_ in pairs(raid.classes.PRIEST) do
				table.insert(thepriests, name)
			end
			return thepriests
		end,
	},

	levitate = {
		order = 425,
		list = "levitatelist",
		check = "checklevitate",
		default = false,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = false,
		defaultdashcombat = false,
		defaultboss = false,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		core = true,
		class = { PRIEST = true, },
		chat = BS[1706], -- Levitate
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.PRIEST > 0 then
				report.checking.levitate = true
				if not unit.hasbuff[BS[1706]] then
					if RaidBuffStatus.db.profile.ShowGroupNumber then
						table.insert(report.levitatelist, name .. "(" .. unit.group .. ")" )
					else
						table.insert(report.levitatelist, name)
					end
				end
			end
		end,
		post = function(self, raid, report)
			RaidBuffStatus:SortNameBySuffix(report.levitatelist)
		end,
		icon = BSI[1706], -- Levitate
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.levitatelist, RaidBuffStatus.db.profile.checklevitate, report.checking.levitate or false, RaidBuffStatus.BF.levitate:buffers())
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "levitate", BS[1706], nil, nil, true) -- Levitate
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[1706], report.levitatelist, nil, RaidBuffStatus.BF.levitate:buffers())
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			for name,_ in pairs(raid.classes.PRIEST) do
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.levitate.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.levitate.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			local thepriests = {}
			for name,_ in pairs(raid.classes.PRIEST) do
				table.insert(thepriests, name)
			end
			return thepriests
		end,
		singletarget = true,
	},

--	noaura = {
--		order = 410,
--		list = "noauralist",
--		check = "checknoaura",
--		default = true,
--		defaultbuff = true,
--		defaultwarning = false,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = true,
--		checkzonedout = false,
--		selfbuff = true,
--		timer = false,
--		class = { PALADIN = true, },
--		chat = L["Paladin Aura"],
--		pre = nil,
--		main = function(self, name, class, unit, raid, report)
--			if class == "PALADIN" then
--				report.checking.noaura = true
--				local missingbuff = true
--				for _, v in ipairs(auras) do
--					if unit.hasbuff[v] then
--						if raid.ClassNumbers.PALADIN <= 2 then
--							local _, _, _, _, _, _, _, caster = UnitBuff(unit.unitid, v)
--							if caster then
----								RaidBuffStatus:Debug(name .. " has " .. v .. " from " .. caster)
--								if RaidBuffStatus:UnitNameRealm(caster) == name then
--									missingbuff = false
--									break
--								end
--							end
--						else
--							missingbuff = false  -- when many palas auras will start getting overwritten
--							break
--						end
--					end
--				end
--				if missingbuff then
--					table.insert(report.noauralist, name)
--				end
--			end
--		end,
--		post = nil,
--		icon = BSI[465], -- Devotion Aura
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.noauralist, RaidBuffStatus.db.profile.checknoaura, report.checking.noaura or false, report.noauralist)
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "noaura", RaidBuffStatus:SelectPalaAura())
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Paladin has no Aura at all"], report.noauralist)
--		end,
--		partybuff = nil,
--		raidwidebuff = true,
--	},

	noaspect = {
		order = 400,
		list = "noaspectlist",
		check = "checknoaspect",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { HUNTER = true, },
		chat = L["Hunter Aspect"],
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if class == "HUNTER" then
				report.checking.noaspect = true
				local missingbuff = true
				for _, v in ipairs(aspects) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
				if missingbuff then
					table.insert(report.noaspectlist, name)
				end
			end
		end,
		post = nil,
		icon = BSI[13165], -- Aspect of the Hawk
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.noaspectlist, RaidBuffStatus.db.profile.checknoaspect, report.checking.noaspect or false, report.noaspectlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "noaspect")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Hunter has no aspect at all"], report.noaspectlist)
		end,
		partybuff = nil,
	},

	trueshotaura = {
		order = 395,
		list = "trueshotauralist",
		check = "checktrueshotaura",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		class = { HUNTER = true, },
		chat = BS[19506], -- Trueshot Aura
		main = function(self, name, class, unit, raid, report)
			if class == "HUNTER" then
--				if GT:GUIDHasTalent(raid.classes.HUNTER[name].guid, BS[19506]) then -- Trueshot Aura
--					report.checking.trueshotaura = true
--					if not unit.hasbuff[BS[19506]] and (raid.maxabominationsmightpoints >= 2 and not unit.hasbuff[BS[53137]]) and (raid.maxunleashedragepoints >= 3 and not unit.hasbuff[BS[30802]]) then -- Trueshot Aura + Abomination's Might + Unleashed Rage
--						table.insert(report.trueshotauralist, name)
--					end
--				end
			end
		end,
		post = nil,
		icon = BSI[19506], -- Trueshot Aura
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.trueshotauralist, RaidBuffStatus.db.profile.checktrueshotaura, report.checking.trueshotaura or false, report.trueshotauralist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "trueshotaura", BS[19506]) -- Trueshot Aura
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[19506], report.trueshotauralist)
		end,
		partybuff = nil,
		raidwidebuff = true,
	},

	dkpresence = {
		order = 394,
		list = "dkpresencelist",
		check = "checkdkpresence",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { DEATHKNIGHT = true, },
		chat = L["Death Knight Presence"],
		main = function(self, name, class, unit, raid, report)
			if class ~= "DEATHKNIGHT" then
				return
			end
			report.checking.dkpresence = true
			local missingbuff = true
			for _, v in ipairs(dkpresences) do
				if unit.hasbuff[v] then
					missingbuff = false
					break
				end
			end
			if missingbuff then
				table.insert(report.dkpresencelist, name)
			end
		end,
		post = nil,
		icon = BSI[48266], -- Blood presence
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.dkpresencelist, RaidBuffStatus.db.profile.dkpresence, report.checking.dkpresence or false, report.dkpresencelist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "dkpresence")
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Death Knight Presence"], report.dkpresencelist)
		end,
		partybuff = nil,
	},


	innerfire = {
		order = 390,
		list = "innerfirelist",
		check = "checkinnerfire",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { PRIEST = true, },
		chat = BS[588] .. "/" .. BS[73413], -- Inner Fire/Inner Will
		main = function(self, name, class, unit, raid, report)
			if class == "PRIEST" then
				report.checking.innerfire = true
				if not unit.hasbuff[BS[588]] and not unit.hasbuff[BS[73413]] then -- Inner Fire and Inner Will
					table.insert(report.innerfirelist, name)
				end
			end
		end,
		post = nil,
		icon = BSI[588], -- Inner Fire
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.innerfirelist, RaidBuffStatus.db.profile.checkinnerfire, report.checking.innerfire or false, report.innerfirelist)
		end,
		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "innerfire", RaidBuffStatus:SelectPriestInner()) -- Inner Fire
			RaidBuffStatus:ButtonClick(self, button, down, "innerfire", BS[588]) -- Inner Fire
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[588] .. "/" .. BS[73413], report.innerfirelist) -- Inner Fire/Inner Will
		end,
		partybuff = nil,
	},

	shadowform = {
		order = 387,
		list = "shadowformlist",
		check = "checkshadowform",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { PRIEST = true, },
		chat = BS[15473], -- Shadowform
		main = function(self, name, class, unit, raid, report)
			if class == "PRIEST" then
				if raid.classes.PRIEST[name].specialisations.shadowform then -- Shadowform
					report.checking.shadowform = true
					if not unit.hasbuff[BS[15473]] then -- Shadowform
						table.insert(report.shadowformlist, name)
					end
				end
			end
		end,
		post = nil,
		icon = BSI[15473], -- Shadowform
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.shadowformlist, RaidBuffStatus.db.profile.checkshadowform, report.checking.shadowform or false, report.shadowformlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "shadowform", BS[15473]) -- Shadowform
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[15473], report.shadowformlist)
		end,
		partybuff = nil,
	},

--	vampiricembrace = {
--		order = 386,
--		list = "vampiricembracelist",
--		check = "checkvampiricembrace",
--		default = true,
--		defaultbuff = true,
--		defaultwarning = false,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = true,
--		checkzonedout = false,
--		selfbuff = true,
--		selfonlybuff = true,
--		timer = false,
--		class = { PRIEST = true, },
--		chat = BS[15286], -- Vampiric Embrace
--		main = function(self, name, class, unit, raid, report)
--			if class == "PRIEST" then
--				if raid.classes.PRIEST[name].specialisations.vampiricembrace then -- Vampiric Embrace
--					report.checking.vampiricembrace = true
--					if not unit.hasbuff[BS[15286]] then -- Vampiric Embrace
--						table.insert(report.vampiricembracelist, name)
--					end
--				end
--			end
--		end,
--		post = nil,
--		icon = BSI[15286], -- Vampiric Embrace
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.vampiricembracelist, RaidBuffStatus.db.profile.vampiricembraceform, report.checking.vampiricembrace or false, report.vampiricembracelist)
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "vampiricembrace", BS[15286]) -- Vampiric Embrace
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[15286], report.vampiricembracelist) -- Vampiric Embrace
--		end,
--		partybuff = nil,
--	},

--	boneshield = {
--		order = 385,
--		list = "boneshieldlist",
--		check = "checkboneshield",
--		default = true,
--		defaultbuff = true,
--		defaultwarning = false,
--		defaultdash = true,
--		defaultdashcombat = false,
--		defaultboss = true,
--		defaulttrash = true,
--		checkzonedout = false,
--		selfbuff = true,
--		selfonlybuff = true,
--		timer = false,
--		class = { DEATHKNIGHT = true, },
--		chat = BS[49222], -- Bone Shield
--		main = function(self, name, class, unit, raid, report)
--			if class == "DEATHKNIGHT" then
--				if raid.classes.DEATHKNIGHT[name].specialisations.boneshield then
--					report.checking.boneshield = true
--					if not unit.hasbuff[BS[49222]] then -- Bone Shield
--						table.insert(report.boneshieldlist, name)
--					end
--				end
--			end
--		end,
--		post = nil,
--		icon = BSI[49222], -- Bone Shield
--		update = function(self)
--			RaidBuffStatus:DefaultButtonUpdate(self, report.boneshieldlist, RaidBuffStatus.db.profile.checkboneshield, report.checking.boneshield or false, report.boneshieldlist)
--		end,
--		click = function(self, button, down)
--			RaidBuffStatus:ButtonClick(self, button, down, "boneshield", BS[49222]) -- Bone Shield
--		end,
--		tip = function(self)
--			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[49222], report.boneshieldlist) -- Bone Shield
--		end,
--		partybuff = nil,
--	},

	felarmor = {
		order = 380,
		list = "felarmorlist",
		check = "checkfelarmor",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { WARLOCK = true, },
		chat = BS[28176], -- Fel Armor
		main = function(self, name, class, unit, raid, report)
			if class == "WARLOCK" then
				report.checking.felarmor = true
				if not unit.hasbuff[BS[28176]] then -- Fel Armor
					table.insert(report.felarmorlist, name)
				end
			end
		end,
		post = nil,
		icon = BSI[28176], -- Fel Armor
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.felarmorlist, RaidBuffStatus.db.profile.checkfelarmor, report.checking.felarmor or false, report.felarmorlist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "felarmor", BS[28176]) -- Fel Armor
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[28176], report.felarmorlist)
		end,
		partybuff = nil,
	},

	soullink = {
		order = 375,
		list = "soullinklist",
		check = "checksoullink",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { WARLOCK = true, },
		chat = BS[19028], -- Soul Link
		main = function(self, name, class, unit, raid, report)
			if class ~= "WARLOCK" then
				return
			end
			report.checking.soullink = true
			if not unit.hasbuff[BS[19028]] then -- Soul Link
				table.insert(report.soullinklist, name)
			end
		end,
		post = nil,
		icon = BSI[19028], -- Soul Link
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.soullinklist, RaidBuffStatus.db.profile.checksoullink, report.checking.soullink or false, report.soullinklist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "soullink", BS[19028]) -- Soul Link
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[19028], report.soullinklist) -- Soul Link
		end,
		partybuff = nil,
	},
	magearmor = {
		order = 370,
		list = "magearmorlist",
		check = "checkmagearmor",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { MAGE = true, },
		chat = BS[6117], -- Mage Armor
		pre = nil,
		main = function(self, name, class, unit, raid, report)
			if class == "MAGE" then
				report.checking.magearmor = true
				local missingbuff = true
				for _, v in ipairs(magearmors) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
				if missingbuff then
					table.insert(report.magearmorlist, name)
				end
			end
		end,
		post = nil,
		icon = BSI[30482], -- Molten Armor
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.magearmorlist, RaidBuffStatus.db.profile.checkmagearmor, report.checking.magearmor or false, report.magearmorlist)
		end,
		click = function(self, button, down)
--			local name = UnitName("player")
--				if name and raid.classes.MAGE[name] and
--		                           GT:GUIDHasTalent(raid.classes.MAGE[name].guid, BS[63934]) then -- Arcane Barrage
--					   RaidBuffStatus:ButtonClick(self, button, down, "magearmor", BS[6117]) -- Mage Armor
--		                        else
				RaidBuffStatus:ButtonClick(self, button, down, "magearmor", BS[34913]) -- Molten Armor
--		                        end
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Mage is missing a Mage Armor"], report.magearmorlist)
		end,
		partybuff = nil,
	},

	shamanshield = {
		order = 355,
		list = "shamanshieldlist",
		check = "checkshamanshield",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		timer = false,
		class = { SHAMAN = true, },
		chat = BS[52127] .. "/" .. BS[324], -- Water Shield/Lightning Shield
		main = function(self, name, class, unit, raid, report)
			if class ~= "SHAMAN" then
				return
			end
			report.checking.shamanshield = true

			local missing = true
			if unit.hasbuff[BS[52127]] then -- Water Shield
				missing = false
			else
--				if GT:GUIDHasTalent(raid.classes.SHAMAN[name].guid, BS[51525]) or   -- Static Shock talent
--				   GT:GUIDHasTalent(raid.classes.SHAMAN[name].guid, BS[88766]) then -- Fulmination talent
--				   if unit.hasbuff[BS[324]] then -- Lightning Shield
--						missing = false
--					end
--				end
			end
			if missing then
				table.insert(report.shamanshieldlist, name)
			end
		end,
		post = nil,
		icon = BSI[52127], -- Water Shield 
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.shamanshieldlist, RaidBuffStatus.db.profile.checkshamanshield, report.checking.shamanshield or false, report.shamanshieldlist)
		end,
		click = function(self, button, down)
			local name = UnitName("player")
--			if name and raid.classes.SHAMAN[name] and 
--			   ( GT:GUIDHasTalent(raid.classes.SHAMAN[name].guid, BS[51525]) or -- Static Shock talent
--			     GT:GUIDHasTalent(raid.classes.SHAMAN[name].guid, BS[88766])) then -- Fulmination talent
--				RaidBuffStatus:ButtonClick(self, button, down, "shamanshield", BS[324]) -- Lightning Shield
--			else
--				RaidBuffStatus:ButtonClick(self, button, down, "shamanshield", BS[52127]) -- Water Shield 
--			end
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[52127] .. "/" .. BS[324], report.shamanshieldlist) -- Water Shield/Lightning Shield
		end,
		partybuff = nil,
		singletarget = true,
	},
	seal = {
		order = 352,
		list = "seallist",
		check = "checkseal",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { PALADIN = true, },
		chat = L["Seal"],
		main = function(self, name, class, unit, raid, report)
			if class == "PALADIN" then
				report.checking.seal = true
				local missingbuff = true
				for _, v in ipairs(seals) do
					if unit.hasbuff[v] then
						missingbuff = false
						break
					end
				end
				if missingbuff then
					table.insert(report.seallist, name)
				end
			end
		end,
		post = nil,
		icon = BSI[20165], -- Seal of Insight
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.seallist, RaidBuffStatus.db.profile.checkseal, report.checking.seal or false, report.seallist)
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "seal", RaidBuffStatus:SelectSeal())
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Paladin missing Seal"], report.seallist)
		end,
		whispertobuff = nil,
		singlebuff = nil,
		partybuff = nil,
		raidbuff = nil,
	},

	missingblessing = {
		order = 350,
		list = "missingblessinglist",
		check = "checkmissingblessing",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		core = true,
		class = { PALADIN = true, },
		chat = function(report, raid, prefix, channel)
			prefix = prefix or ""
			local tosay
			if RaidBuffStatus.db.profile.ShowMany and #report.missingblessinglist >= RaidBuffStatus.db.profile.HowMany then
				tosay = L["MANY!"]
			else
				tosay = table.concat(report.missingblessinglist, ", ")
			end
			if report.kingsneeded then
				RaidBuffStatus:Say(prefix .. "<" .. L["Paladin blessing"] .. ">: " .. tosay, nil, nil, channel)
			else
				RaidBuffStatus:Say(prefix .. "<" .. BS[19740] .. ">: " .. tosay, nil, nil, channel) -- Blessing of Might
			end
			if #report.slackingpaladins > 0 then
				RaidBuffStatus:Say("<" .. L["Slacking Paladins"] .. ">: " .. table.concat(report.slackingpaladins, ", ", nil, nil, channel))
			end
		end,
		pre = function(self, raid, report)
			if raid.ClassNumbers.PALADIN < 1 then
				return
			end
			report.slackingpaladins = {}
			report.castkings = ""
			report.castmight = ""
			report.pallyblessingsmessagelist = {}
			report.kingsneeded = true
			report.kingsmissing = false
			report.mightmissing = false
			report.usedrumskings = RaidBuffStatus:UseDrumsKings(raid)
			if raid.ClassNumbers.DRUID > 0 then
				report.kingsneeded = false
				report.pallyblessingsmessagelist[L["Blessing of Kings is not needed because you are grouped with a Druid."]] = true
			end
			if report.usedrumskings then
				report.pallyblessingsmessagelist[L["Blessing of Kings, with this raid configuration, is better provided by Drums of the Forgotten Kings thus allowing Blessing of Might to be used."]] = true
			end
			-- if a druid then might
			-- if no druid and a pala then kings or might and forgotten kings
			-- if 2 pala and no druid then might and kings
		end,
		main = function(self, name, class, unit, raid, report)
			if raid.ClassNumbers.PALADIN < 1 then
				return
			end
			report.checking.missingblessing = true
			local kingsmissing = false
			local mightmissing = false
			if not unit.hasbuff[BS[20217]] then -- Blessing of Kings
				if report.kingsneeded then
					kingsmissing = true
				end
			else
				report.castkings = unit.hasbuff[BS[20217]].caster -- Blessing of Kings
			end
			if not unit.hasbuff[BS[19740]] then  -- Blessing of Might
				mightmissing = true
			else
				report.castmight = unit.hasbuff[BS[19740]].caster  -- Blessing of Might
			end
			local missinglist = {}
			if (raid.ClassNumbers.PALADIN == 1 and kingsmissing and mightmissing) or (raid.ClassNumbers.PALADIN == 1 and not report.kingsneeded and mightmissing) or (raid.ClassNumbers.PALADIN > 1 and (kingsmissing or mightmissing)) then
				if RaidBuffStatus.db.profile.ShortMissingBlessing then
					if kingsmissing then
						table.insert(missinglist, L["BoK"])
						report.kingsmissing = true
					end
					if mightmissing then
						table.insert(missinglist, L["BoM"])
						report.mightmissing = true
					end
				else
					if kingsmissing then
						table.insert(missinglist, BS[20217]) -- Blessing of Kings
						report.kingsmissing = true
					end
					if mightmissing then
						table.insert(missinglist, BS[19740])  -- Blessing of Might
						report.mightmissing = true
					end
				end
				table.insert(report.missingblessinglist, name .. "(" .. table.concat(missinglist, ", ") .. ")")
			end
		end,
		post = function(self, raid, report)
			if report.kingsmissing or report.mightmissing then
				for name,rcn in pairs(raid.classes.PALADIN) do
					if report.kingsneeded and not report.kingsmissing and name == report.castkings then
					-- not a slacker
					elseif not report.mightmissing and name == report.castmight then
					-- not a slacker
					else
						table.insert(report.slackingpaladins, name)
					end
				end
			end
		end,
		icon = BSI[79102], -- Blessing of Might
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.missingblessinglist, RaidBuffStatus.db.profile.checkmissingblessing, report.checking.missingblessing or false, report.slackingpaladins)
		end,
		click = function(self, button, down)
			local spell
			if report.kingsmissing then
				spell = BS[20217] -- Blessing of Kings
			elseif report.mightmissing then
				spell = BS[19740]  -- Blessing of Might
			end
			RaidBuffStatus:ButtonClick(self, button, down, "missingblessing", spell)
		end,
		tip = function(self)
			if not report.slackingpaladins then  -- fixes error when tip being called from option window when not in a party/raid and when no paladins
				RaidBuffStatus:Tooltip(self, L["Player is missing at least one Paladin blessing"])
			else
				RaidBuffStatus:Tooltip(self, L["Player is missing at least one Paladin blessing"], report.missingblessinglist, nil, RaidBuffStatus.BF.missingblessing:buffers(), report.slackingpaladins, report.pallyblessingsmessagelist, nil, nil, report.castkings, report.castmight)
			end
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			local b
			if #report.slackingpaladins > 0 then
				b = report.slackingpaladins
			else
				b = RaidBuffStatus.BF.missingblessing:buffers()
			end
			for _,name in ipairs(b) do
				if RaidBuffStatus:InMyZone(name) then
					local tosay
					if RaidBuffStatus.db.profile.ShowMany and #report.missingblessinglist >= RaidBuffStatus.db.profile.HowMany then
						tosay = L["MANY!"]
					else
						tosay = table.concat(report.missingblessinglist, ", ")
					end
					if report.kingsneeded then
						RaidBuffStatus:Say(prefix .. "<" .. L["Paladin blessing"] .. ">: " .. tosay, name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. BS[19740] .. ">: " .. tosay, name) -- Blessing of Might
					end
				end
			end
		end,
		buffers = function()
			local b = {}
			for name,rcn in pairs(raid.classes.PALADIN) do
				table.insert(b, name)
			end
			return b
		end,
	},

	drumskings = {
		order = 345,
		list = "drumskingslist",
		check = "checkdrumskings",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		chat = BS[69378], -- Blessing of Forgotten Kings
		iconfix = function(self)  -- to handle when server is slow to get the icon
			if RaidBuffStatus.BF.drumskings.icon == "Interface\\Icons\\INV_Misc_QuestionMark" then
				RaidBuffStatus.BF.drumskings.icon = ITT[49633] -- Drums of Forgotten Kings
				if RaidBuffStatus.BF.drumskings.icon == "Interface\\Icons\\INV_Misc_QuestionMark" then
					return true
				end
			end
			return false
		end,
		pre = function(self, raid, report)
			if not RaidBuffStatus:UseDrumsKings(raid) or raid.isbattle then
				return
			end
			if not RaidBuffStatus.itemcheck.drumskings then
				RaidBuffStatus.itemcheck.drumskings = {}
				RaidBuffStatus.itemcheck.drumskings.results = {}
				RaidBuffStatus.itemcheck.drumskings.list = "drumskingslist"
				RaidBuffStatus.itemcheck.drumskings.check = "drumskings"
				RaidBuffStatus.itemcheck.drumskings.next = 0
				RaidBuffStatus.itemcheck.drumskings.item = "49633" -- Drums of Forgotten Kings
				RaidBuffStatus.itemcheck.drumskings.min = 0
				RaidBuffStatus.itemcheck.drumskings.frequency = 60 * 5
				RaidBuffStatus.itemcheck.drumskings.frequencymissing = 60 * 5
			end
		end,
		main = function(self, name, class, unit, raid, report)
			if not RaidBuffStatus:UseDrumsKings(raid) then
				return
			end
			report.checking.drumskings = true
			local missingbuff = true
			for _, v in ipairs(blessingofforgottenkings) do
				if unit.hasbuff[v] then
					missingbuff = false
					break
				end
			end
			if missingbuff then
				table.insert(report.drumskingslist, name)
			end
		end,
		post = nil,
		icon = ITT[49633], -- Drums of Forgotten Kings
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.drumskingslist, RaidBuffStatus.db.profile.checkdrumskings, report.checking.drumskings or false, RaidBuffStatus.BF.drumskings:buffers())
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "drumskings", nil, nil, nil, nil, ITN[49633]) -- Drums of Forgotten Kings
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[69378] .. "/" .. BS[20217], report.drumskingslist, nil, RaidBuffStatus.BF.drumskings:buffers()) -- Blessing of Forgotten Kings, Blessing of Kings
		end,
		singlebuff = false,
		partybuff = false,
		raidbuff = true,
		raidwidebuff = true,
		whispertobuff = function(reportl, prefix)
			local thebuffers = RaidBuffStatus.BF.drumskings:buffers()
			if not thebuffers then
				return
			end
			for _,name in ipairs(thebuffers) do
				name = string.sub(name, 1, name:find("%(") - 1)
				if RaidBuffStatus:InMyZone(name) then
					if RaidBuffStatus.db.profile.WhisperMany and #reportl >= RaidBuffStatus.db.profile.HowMany then
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.drumskings.chat .. ">: " .. L["MANY!"], name)
					else
						RaidBuffStatus:Say(prefix .. "<" .. RaidBuffStatus.BF.drumskings.chat .. ">: " .. table.concat(reportl, ", "), name)
					end
					if RaidBuffStatus.db.profile.whisperonlyone then
						return
					end
				end
			end
		end,
		buffers = function()
			if not RaidBuffStatus.itemcheck.drumskings then
				return
			end
			local thebuffers = {}
				for _,rc in pairs(raid.classes) do
					for name,_ in pairs(rc) do
						local items = RaidBuffStatus.itemcheck.drumskings.results[name] or 0
						if items > 0 then
							table.insert(thebuffers, name .. "(" .. items .. ")")
						end
					end
				end
			return thebuffers
		end,
		consumable = true,
	},

	checkpet = {
		order = 330,
		list = "petlist",
		check = "checkpet",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = true,
		selfonlybuff = true,
		timer = false,
		class = { WARLOCK = true, HUNTER = true, DEATHKNIGHT = true, MAGE = true, },
		chat = BS[883], -- Call Pet
		main = function(self, name, class, unit, raid, report)
			local needspet = false
			local haspet = false
			if class == "HUNTER" then
				needspet = true
			elseif class == "WARLOCK" then
				needspet = true			
			elseif class == "DEATHKNIGHT" then
--				if GT:GUIDHasTalent(raid.classes.DEATHKNIGHT[name].guid, BS[52143]) then -- Master of Ghouls talent
--					needspet = true
--				else
				needspet = false
--		end
			elseif class == "MAGE" then
--				if GT:GUIDHasTalent(raid.classes.MAGE[name].guid, BS[31687]) then -- summon water elemental talent
--					needspet = true
--				else
					needspet = false
--		end			
			else
				needspet = false
			end
			 
			if needspet and UnitIsVisible(unit.unitid) then
				if UnitIsUnit(unit.unitid, "player") then 
					haspet = SecureCmdOptionParse("[target=pet,dead] false; [mounted] true ; [nopet] false; true")
					haspet = (haspet == "true")
				else -- non-player
					if UnitExists(unit.unitid.."pet") then -- pet visible
						haspet = true
					elseif GetUnitSpeed(unit.unitid) > 10 or  -- mounted and moving, so cannot check (pets dont exist when mounted)
						UnitInVehicle(unit.unitid) then -- in vehicle (actually multi-passenger mnt), same thing
						haspet = true	
					elseif not IsOutdoors() then -- cannot be mounted in my zone, pet is missing
						haspet = false 
					else -- outside not moving, check for a mounted buff
						haspet = RaidBuffStatus:UnitIsMounted(unit.unitid)
					end
				end
				report.checking.pet = true
				if not haspet then 
					table.insert(report.petlist, name)
				end
			end
			-- print(name.." needs:"..(needspet == true and "true" or "false").." has:"..(haspet == true and "true" or "false"))
		end,
		post = nil,
		icon = BSI[883], -- Call Pet
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, report.petlist, RaidBuffStatus.db.profile.checkpet, report.checking.pet or false, report.petlist)
		end,
		click = function(self, button, down)
			local class = select(2, UnitClass("player"))
			local summonspell = nil
			if class == "HUNTER" then
			  --  SecureCmdOptionParse("[target=pet,dead] Revive Pet; [nopet] Call Pet; Mend Pet")
				summonspell = SecureCmdOptionParse("[target=pet,dead] 982; [nopet] 883; 48990")
				summonspell = tonumber(summonspell)
				summonspell = BS[summonspell] 
			elseif class == "WARLOCK" then
				local guid = UnitGUID("player")
				local glyphs = RaidBuffStatus:PlayerActiveGlyphs()
				if GT:GUIDHasTalent(guid, BS[30146]) then -- Summon Felguard
					summonspell = BS[30146] -- Summon Felguard
				elseif GT:GUIDHasTalent(guid, BS[47220]) then -- Empowered Imp
					summonspell = BS[688] -- Summon Imp
				elseif glyphs[70947] then -- Glyph of Lash of Pain
					summonspell = BS[712] -- Summon Succubus	      
				elseif glyphs[56248] then -- Glyph of Imp
					summonspell = BS[688] -- Summon Imp
	      		else -- shrug?
					summonspell = BS[691] -- Summon Felhunter
				end	        
			elseif class == "DEATHKNIGHT" then
				summonspell = BS[46584] -- Raise Dead
			elseif class == "MAGE" then
				summonspell = BS[31687] -- summon water elemental
			end
			RaidBuffStatus:ButtonClick(self, button, down, "checkpet", summonspell) 
		end,
		tip = function(self)
			RaidBuffStatus:Tooltip(self, L["Missing "] .. BS[883], report.petlist) -- Call Pet
		end,
		partybuff = nil,
	},

	abouttorunout = {
		order = 100,
		list = "none",
		check = "checkabouttorunout",
		default = false,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		chat = nil,
		pre = function(self, raid, report)
			if RaidBuffStatus.db.profile.abouttorunout > 0 and RaidBuffStatus.db.profile.checkabouttorunout then
				report.checking.abouttorunout = true
			end
		end,
		main = nil,
		post = nil,
		icon = "Interface\\Icons\\Ability_Mage_Timewarp",
		update = function(self)
			RaidBuffStatus:DefaultButtonUpdate(self, {}, RaidBuffStatus.db.profile.checkabouttorunout, report.checking.abouttorunout or false)
			if self.count:GetText() ~= "X" then
				self.count:SetText("")
			end
		end,
		click = function(self, button, down)
			RaidBuffStatus:ButtonClick(self, button, down, "abouttorunout")
		end,
		tip = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["Min remaining buff duration"],1,1,1)
			GameTooltip:AddLine((L["%s minutes"]):format(RaidBuffStatus.db.profile.abouttorunout),nil,nil,nil)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Minimum remaining buff duration in minutes. Buffs with less than this will be considered as missing.  This option only takes affect when the corresponding 'buff' button is enabled on the dashboard."],nil,nil,nil, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["To set this option go to the addon configuration.  This button is automatically enabled when the Boss button is pressed and automatically disabled when the Trash button is pressed.  To permanently disable, choose 0 seconds as the min remaining buff duration."],nil,nil,nil,1)
			GameTooltip:Show()
		end,
		partybuff = nil,
		other = true,
	},

	tanklist = {
		order = 20,
		list = "none",
		check = "checktanklist",
		default = true,
		defaultbuff = false,
		defaultwarning = true,
		defaultdash = false,
		defaultdashcombat = false,
		defaultboss = false,
		defaulttrash = true,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		chat = nil,
		pre = nil,
		main = nil,
		post = nil,
		icon = "Interface\\Icons\\Ability_Defend",
		update = function(self)
			self.count:SetText("")
			if #raid.TankList > 0 then
				self:SetAlpha("1")
			else
				self:SetAlpha("0.15")
			end
		end,
		click = nil,
		tip = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["RBS Tank List"],1,1,1)
			for _,v in ipairs(raid.TankList) do
				local class = "WARRIOR"
				local unit = RaidBuffStatus:GetUnitFromName(v)
				if unit then
					class = unit.class
				end
				GameTooltip:AddLine(v,RAID_CLASS_COLORS[class].r,RAID_CLASS_COLORS[class].g,RAID_CLASS_COLORS[class].b,nil)
			end
			GameTooltip:Show()
		end,
		partybuff = nil,
		other = true,
	},
	help20090704 = {
		order = 10,
		list = "none",
		check = "checkhelp20090704",
		default = true,
		defaultbuff = true,
		defaultwarning = false,
		defaultdash = true,
		defaultdashcombat = false,
		defaultboss = true,
		defaulttrash = false,
		checkzonedout = false,
		selfbuff = false,
		timer = false,
		chat = nil,
		pre = nil,
		main = nil,
		post = nil,
		icon = "Interface\\Icons\\Mail_GMIcon",
		update = function(self)
			self.count:SetText("")
		end,
		click = nil,
		tip = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["RBS Dashboard Help"],1,1,1)
			GameTooltip:AddLine(L["Click buffs to disable and enable."],nil,nil,nil)
			GameTooltip:AddLine(L["Shift-Click buffs to report on only that buff."],nil,nil,nil)
			GameTooltip:AddLine(L["Ctrl-Click buffs to whisper those who need to buff."],nil,nil,nil)
			GameTooltip:AddLine(L["Alt-Click on a self buff will renew that buff."],nil,nil,nil)
			GameTooltip:AddLine(L["Alt-Click on a party buff will cast on someone missing that buff."],nil,nil,nil)
			GameTooltip:AddLine(" ",nil,nil,nil)
			GameTooltip:AddLine(L["Remove this button from this dashboard in the buff options window."],nil,nil,nil)
			GameTooltip:AddLine(" ",nil,nil,nil)
			GameTooltip:AddLine(L["The above default button actions can be reconfigured."],nil,nil,nil)
			GameTooltip:AddLine(L["Press Escape -> Interface -> AddOns -> RaidBuffStatus for more options."],nil,nil,nil)
			GameTooltip:AddLine(" ",nil,nil,nil)
			GameTooltip:AddLine(L["Ctrl-Click Boss or Trash to whisper all those who need to buff."],nil,nil,nil)
			GameTooltip:Show()
		end,
		partybuff = nil,
		other = true,
	},
}

RaidBuffStatus.BF = BF
