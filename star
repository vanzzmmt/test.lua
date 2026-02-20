local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Star Fishing Auto",
   LoadingTitle = "Auto Fish GUI",
   LoadingSubtitle = "scrip by vanzzmmt",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StarFishingAuto",
      FileName = "Config"
   }
})

local Tab = Window:CreateTab("Main", 4483362458)

local Settings = {
   Common = true,
   Uncommon = true,
   Rare = true,
   Epic = true,
   Legendary = false,
   Mythic = false
}

local Running = false
local LastSell = 0
local SellDelay = 10
local PendingSell = false

-- toggles rarity
for rarity,_ in Settings do
   Tab:CreateToggle({
      Name = "Sell "..rarity,
      CurrentValue = Settings[rarity],
      Callback = function(v)
         Settings[rarity] = v
      end
   })
end

Tab:CreateToggle({
   Name = "Start Auto Fish",
   CurrentValue = false,
   Callback = function(Value)
      Running = Value
      shared.afy = Value

      if not Value then return end

      local Players = game:GetService("Players")
      local ReplicatedStorage = game:GetService("ReplicatedStorage")
      local Client = Players.LocalPlayer
      local Backpack = Client:FindFirstChildWhichIsA("Backpack")

      local function GetRoot(c) return c and c:FindFirstChild("HumanoidRootPart") end
      local function GetHumanoid(c) return c and c:FindFirstChild("Humanoid") end

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

      -- detect fish rarity
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

               if Settings[rarity] then
                  PendingSell = true
               end
            end
         end
      end)

      task.spawn(function()
         while Running and task.wait() do
            if GetRoot(Client.Character) then
               Cast()
            end

            if PendingSell and tick() - LastSell > SellDelay then
               pcall(function()
                  ReplicatedStorage.Dialogue.Events.Global.ClientChoosesDialogueOption:FireServer({
                     id = "sell-all",
                     text = "Sell <font color='#26ff47'>all</font> of my stars.",
                     npc = "Star Merchant"
                  })
               end)
               PendingSell = false
               LastSell = tick()
            end
         end
      end)
   end
})

Tab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      Rayfield:Destroy()
   end
})
