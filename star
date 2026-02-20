local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Star Fishing by vanzzmmt",
   LoadingTitle = "Star Fishing",
   LoadingSubtitle = "vanzzmmt",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StarFishingAuto",
      FileName = "Config"
   }
})

local Main = Window:CreateTab("Fishing", 4483362458)
local SellTab = Window:CreateTab("Sell & Favorite", 4483362458)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = Players.LocalPlayer
local Backpack = Client:FindFirstChildWhichIsA("Backpack")

local AutoFish = false
local AutoSell = false
local FavLegendary = true
local FavMythic = false

local ItemCount = 0
local SellWhenCount = 100

local function GetRoot(c) return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHumanoid(c) return c and c:FindFirstChild("Humanoid") end

Main:CreateToggle({
   Name = "Auto Fish",
   CurrentValue = false,
   Callback = function(v)
      AutoFish = v
      shared.afy = v
   end
})

SellTab:CreateToggle({
   Name = "Enable Auto Sell",
   CurrentValue = false,
   Callback = function(v)
      AutoSell = v
   end
})

SellTab:CreateSlider({
   Name = "Sell When Count",
   Range = {10, 500},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(v)
      SellWhenCount = v
   end
})

SellTab:CreateToggle({
   Name = "Auto Favorite Legendary",
   CurrentValue = true,
   Callback = function(v)
      FavLegendary = v
   end
})

SellTab:CreateToggle({
   Name = "Auto Favorite Mythic",
   CurrentValue = false,
   Callback = function(v)
      FavMythic = v
   end
})

local function Cast()
   local Character = Client.Character
   local Humanoid = GetHumanoid(Character)
   local Root = GetRoot(Character)
   if not Root then return end

   local Rod = Character:FindFirstChild("Rod")
   if not Rod then
      Rod = Backpack:FindFirstChild("Rod")
      if Rod then Rod.Parent = Character else return end
   end

   local pos = Root:GetPivot().Position + Vector3.new(0,5,0)
   local look = Root:GetPivot().LookVector

   ReplicatedStorage.Events.Global.Cast:FireServer(
      Humanoid,
      pos,
      look,
      Rod.Model.Nodes.RodTip.Attachment
   )

   ReplicatedStorage.Events.Global.WithdrawBobber:FireServer(Humanoid)
end

ReplicatedStorage.Events.Global.ClientRecieveItems.OnClientEvent:Connect(function(...)
   local Data = {...}
   local Info = Data[4] or {}
   local Timing = Data[6] or {}

   for i,v in Info do
      local id = v.id
      local rarity = v.rarity or v.Rarity

      if id then
         task.wait(Timing[i] or 2)
         ReplicatedStorage.Events.Global.ClientItemConfirm:FireServer(id)

         ItemCount += 1

         -- AUTO FAVORITE (FIXED)
         if (rarity == "Legendary" and FavLegendary) or (rarity == "Mythic" and FavMythic) then
            pcall(function()
               ReplicatedStorage.Events.Global.ClientToggleFavorite:FireServer(id)
            end)
         end
      end
   end
end)

task.spawn(function()
   while task.wait() do
      if AutoFish and GetRoot(Client.Character) then
         Cast()
      end

      if AutoSell and ItemCount >= SellWhenCount then
         pcall(function()
            ReplicatedStorage.Dialogue.Events.Global.ClientChoosesDialogueOption:FireServer({
               id = "sell-all",
               text = "Sell <font color='#26ff47'>all</font> of my stars.",
               npc = "Star Merchant"
            })
         end)
         ItemCount = 0
      end
   end
end)

SellTab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      Rayfield:Destroy()
   end
})
