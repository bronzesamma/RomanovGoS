--- Engine ---
local function Ready(spell)
	return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0 
end
local function EnemiesAround(pos, range, team)
	local Count = 0
	for i = 1, Game.HeroCount() do
		local m = Game.Hero(i)
		if m and m.team == 200 and not m.dead and m.pos:DistanceTo(pos, m.pos) < 125 then
			Count = Count + 1
		end
	end
	return Count
end
--- Engine ---

class "Ashe"

function Ashe:__init()
	print("Romanov Ashe v1.0 loaded")
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Ashe:LoadSpells()
	Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width, icon = "https://vignette2.wikia.nocookie.net/leagueoflegends/images/1/1d/Ranger%27s_Focus.png" }
	W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width, icon = "https://vignette1.wikia.nocookie.net/leagueoflegends/images/5/5d/Volley.png" }
	R = { range = myHero:GetSpellData(_R).range, delay = myHero:GetSpellData(_R).delay, speed = myHero:GetSpellData(_R).speed, width = myHero:GetSpellData(_R).width, icon = "https://vignette3.wikia.nocookie.net/leagueoflegends/images/2/28/Enchanted_Crystal_Arrow.png" }
end

function Ashe:LoadMenu()
	--- Menu ---
	self.Menu = MenuElement({type = MENU, id = "Menu", name = "Romanov Ashe v1.0", leftIcon = "https://raw.githubusercontent.com/bronzesamma/RomanovGoS/master/Icons/Ashe.png"})
	--- Combo ---
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	self.Menu.Combo:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	self.Menu.Combo:MenuElement({id = "R", name = "[R] + AA + [W] + AA = Kill", value = true, leftIcon = R.icon})
	--- Harass ---
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "Key", name = "Toggle: Key", key = string.byte("S"), toggle = true})
	self.Menu.Harass:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	--- Clear ---
	self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
	self.Menu.Clear:MenuElement({id = "Key", name = "Toggle: Key", key = string.byte("A"), toggle = true})
	self.Menu.Clear:MenuElement({id = "Q", name = "Use [Q]", value = true, leftIcon = Q.icon})
	self.Menu.Clear:MenuElement({id = "W", name = "Use [W]", value = true, leftIcon = W.icon})
	--- Misc ---
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
	self.Menu.Misc:MenuElement({id = "Rkey", name = "Semi-Manual [R] Key", key = string.byte("T")})
	self.Menu.Misc:MenuElement({id = "Raoe", name = "Auto Use [R] AoE", value = true})
	self.Menu.Misc:MenuElement({id = "Rene", name = "Enemies to [R] AoE", value = 3, min = 1, max = 5})
	self.Menu.Misc:MenuElement({id = "Wks", name = "Killsecure [W]", value = true, leftIcon = W.icon})
	self.Menu.Misc:MenuElement({id = "Rks", name = "Killsecure [R]", value = true, leftIcon = R.icon})
	--- Draw ---
	self.Menu:MenuElement({type = MENU, id = "Draw", name = "Draw Settings"})
	self.Menu.Draw:MenuElement({id = "W", name = "Draw [W] Range", value = true, leftIcon = W.icon})
	self.Menu.Draw:MenuElement({id = "HT", name = "Harass Toggle", value = true})
	self.Menu.Draw:MenuElement({id = "CT", name = "Clear Toggle", value = true})
end

function Ashe:Tick()
	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		self:Combo()
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
		self:Clear()
	elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
		self:Harass()		
	end	
		self:Misc()
end

function Ashe:Combo()
	local target = _G.SDK and _G.SDK.TargetSelector:GetTarget(1500, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if target then
		if self.Menu.Combo.R:Value() and Ready(_R) then
			local Rdmg = CalcMagicalDamage(myHero, target, (200 * myHero:GetSpellData(_R).level + myHero.ap))
			local Wdmg = CalcPhysicalDamage(myHero, target, (5 + 15 * myHero:GetSpellData(_W).level + myHero.totalDamage))
			local AAdmg = CalcPhysicalDamage(myHero, target, myHero.totalDamage)
			if Rdmg + Wdmg + AAdmg * 2 > target.health then
				Control.CastSpell(HK_R,target:GetPrediction(R.speed, R.delay))
			end
		end
		if self.Menu.Combo.W:Value() and Ready(_W)and myHero.pos:DistanceTo(target.pos) < 1200 then
			Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
		end
		if self.Menu.Combo.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(target.pos) < myHero.range then
			Control.CastSpell(HK_Q)
		end
	end
end

function Ashe:Harass()
	if self.Menu.Harass.Key:Value() then
		local target = _G.SDK and _G.SDK.TargetSelector:GetTarget(1200, _G.SDK.DAMAGE_TYPE_PHYSICAL)
		if target then
			if self.Menu.Harass.W:Value() and Ready(_W)and myHero.pos:DistanceTo(target.pos) < 1200 then
				Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay ))
			end
		end
	end
end

function Ashe:Clear()
	if self.Menu.Clear.Key:Value() then
		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			if  minion.team ~= myHero.team then
				if  self.Menu.Clear.Q:Value() and Ready(_Q) and myHero.pos:DistanceTo(minion.pos) < myHero.range then
					Control.CastSpell(HK_Q)
				end
				if  self.Menu.Clear.W:Value() and Ready(_W) and myHero.pos:DistanceTo(minion.pos) < W.range then
					Control.CastSpell(HK_W,minion:GetPrediction(W.speed, W.delay))
				end
			end
		end
	end
end

function Ashe:Misc()
	local target = _G.SDK and _G.SDK.TargetSelector:GetTarget(2000, _G.SDK.DAMAGE_TYPE_PHYSICAL)
	if target then
		if self.Menu.Misc.Rks:Value() and Ready(_R) then
			local Rdmg = CalcMagicalDamage(myHero, target, (200 * myHero:GetSpellData(_R).level + myHero.ap))
			if Rdmg > target.health then
				Control.CastSpell(HK_R,target:GetPrediction(R.speed,R.delay))
			end
		end
		if self.Menu.Misc.Wks:Value() and Ready(_W) and myHero.pos:DistanceTo(target.pos) < 1200 then
			local Wdmg = CalcPhysicalDamage(myHero, target, (5 + 15 * myHero:GetSpellData(_W).level + myHero.totalDamage))
			if Wdmg > target.health and target:GetCollision(W.width,W.speed,W.delay) == 0 then
				Control.CastSpell(HK_W,target:GetPrediction(W.speed, W.delay))
			end
		end
		if self.Menu.Misc.Rkey:Value() and Ready(_R) then
			Control.CastSpell(HK_R,target:GetPrediction(R.speed,R.delay))
		end
		if self.Menu.Misc.Raoe:Value() and Ready(_R) and self.Menu.Misc.Rene:Value() <=  EnemiesAround(target.pos,125,200) then
			Control.CastSpell(HK_R,target:GetPrediction(R.speed,R.delay))
		end
	end
end

function Ashe:Draw()
	if self.Menu.Draw.W:Value() and Ready(_W) then Draw.Circle(myHero.pos, 1200, 3,  Draw.Color(255,255, 162, 000)) end
	if self.Menu.Draw.HT:Value() then
		local textPos = myHero.pos:To2D()
		if self.Menu.Harass.Key:Value() then
			Draw.Text("Harass: On", 20, textPos.x - 40, textPos.y + 60, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("Harass: Off", 20, textPos.x - 40, textPos.y + 60, Draw.Color(255, 255, 000, 000)) 
		end
	end
	if self.Menu.Draw.CT:Value() then
		local textPos = myHero.pos:To2D()
		if self.Menu.Clear.Key:Value() then
			Draw.Text("Clear: On", 20, textPos.x - 33, textPos.y + 80, Draw.Color(255, 000, 255, 000)) 
		else
			Draw.Text("Clear: Off", 20, textPos.x - 33, textPos.y + 80, Draw.Color(255, 225, 000, 000)) 
		end
	end
end

function OnLoad()
	if myHero.charName ~= "Ashe" then return end
	Ashe()
end
