local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Star Fishing Auto",
   LoadingTitle = "Auto Fish GUI",
   LoadingSubtitle = "script by vanzzmmt",
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
   Flag = "AutoFishToggle",
   Callback = function(Value)
      shared.afy = Value

      if Value then
         local Players = game:GetService("Players")
         local ReplicatedStorage = game:GetService("ReplicatedStorage")
         local Client = Players.LocalPlayer
         local Connections = {}

         local SellRarity = {
            Common = true,
            Uncommon = true,
            Rare = true,
            Epic = true
         }

         local function GetRoot(c) return c and c:FindFirstChild("HumanoidRootPart") end
         local function GetHumanoid(c) return c and c:FindFirstChild("Humanoid") end

         local function Cast()
            local Character = Client.Character
            local Humanoid = GetHumanoid(Character)
            local Root = GetRoot(Character)
            if not Root then return end

            local Rod = Character:FindFirstChild("Rod")
            if not Rod then return end

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
         table.insert(Connections, Recv.OnClientEvent:Connect(function(...)
            local Data = {...}
            local Info = Data[4] or {}
            local Timing = Data[6] or {}

            for i, v in Info do
               local id = v.id
               local rarity = v.rarity or v.Rarity

               if id then
                  task.wait(Timing[i] or 2)
                  ReplicatedStorage.Events.Global.ClientItemConfirm:FireServer(id)

                  if SellRarity[rarity] then
                     task.delay(0.4, function()
                        pcall(function()
                           ReplicatedStorage.Events.Global.SellItem:FireServer(id)
                        end)
                     end)
                  end
               end
            end
         end))

         task.spawn(function()
            while shared.afy and task.wait() do
               if GetRoot(Client.Character) then
                  Cast()
               end
            end
         end)

         game:BindToClose(function()
            for _,c in Connections do c:Disconnect() end
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
