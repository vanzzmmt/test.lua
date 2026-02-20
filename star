local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Star Fishing by vanzzmmt",
   LoadingTitle = "Auto Fish GUI",
   LoadingSubtitle = "vanzzmmt",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StarFishingAuto",
      FileName = "Config"
   }
})

local Tab = Window:CreateTab("Main", 4483362458)

local Toggle = Tab:CreateToggle({
   Name = "Auto Fish + Auto Sell",
   CurrentValue = false,
   Callback = function(Value)
      shared.afy = Value

      if Value then
         local Players = game:GetService("Players")
         local ReplicatedStorage = game:GetService("ReplicatedStorage")
         local Client = Players.LocalPlayer
         local Backpack = Client:FindFirstChildWhichIsA("Backpack")

         local LastSell = 0
         local SellDelay = 10

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

         local Recv = ReplicatedStorage.Events.Global.ClientRecieveItems
         Recv.OnClientEvent:Connect(function(...)
            local Data = {...}
            local Info = Data[4] or {}
            local Timing = Data[6] or {}

            for i, v in Info do
               local id = v.id
               if id then
                  task.wait(Timing[i] or 2)
                  ReplicatedStorage.Events.Global.ClientItemConfirm:FireServer(id)
               end
            end
         end)

         task.spawn(function()
            while shared.afy and task.wait() do
               if GetRoot(Client.Character) then
                  Cast()
               end

               if tick() - LastSell > SellDelay then
                  pcall(function()
                     ReplicatedStorage.Dialogue.Events.Global.ClientChoosesDialogueOption:FireServer({
                        id = "sell-all",
                        text = "Sell <font color='#26ff47'>all</font> of my stars.",
                        npc = "Star Merchant"
                     })
                  end)
                  LastSell = tick()
               end
            end
         end)
      end
   end
})

Tab:CreateButton({
   Name = "Destroy GUI",
   Callback = function()
      Rayfield:Destroy()
   end,
})
