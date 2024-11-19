local ArrayField = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/ArrayField/main/Source.lua'))()

local Window = ArrayField:CreateWindow({
   Name = "Greenville Tweak Hub",
   LoadingTitle = "Greenville Tweak Hub",
   LoadingSubtitle = "by MCompetitive",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = true,
      Invite = "e3KPkzqcvt",
      RememberJoins = true
   },
   KeySystem = true, -- Set this to true to use the key system
   KeySettings = {
      Title = "Greenville Tweak Hub",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"dev"}
   }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local VehicleTab = Window:CreateTab("Vehicle", 4483362458)

local accountName = "MCompetitive"
local isArabWheelerActive = false

local TextInput = PlayerTab:CreateInput({
    Name = "Account Name",
    PlaceholderText = accountName,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        accountName = Text
    end,
})

local ToggleButton = PlayerTab:CreateToggle({
    Name = "Arab Wheeler",
    CurrentValue = false,
    Flag = "ArabWheelerToggle",
    Callback = function(Value)
        isArabWheelerActive = Value
        if isArabWheelerActive then
            local success, errorMsg = pcall(function()
                local carName = accountName .. "-Car"
                local sessionVehicles = game.Workspace:WaitForChild("SessionVehicles")
                local car = sessionVehicles:WaitForChild(carName)
                local wheelModel = car:WaitForChild("Wheels")
                local wheels = {
                    FL = wheelModel:WaitForChild("FL"),
                    FR = wheelModel:WaitForChild("FR"),
                    RL = wheelModel:WaitForChild("RL"),
                    RR = wheelModel:WaitForChild("RR")
                }
                local isOnTwoWheels = false
                local isRotationLocked = false
                local tiltAngle = 20
                local bodyGyro = nil
                local speed = 0
                local maxSpeed = 500
                local driftFactor = 0.5

                local function tiltCar(onTwoWheels)
                    if onTwoWheels then
                        if not bodyGyro then
                            bodyGyro = Instance.new("BodyGyro")
                            bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                            bodyGyro.P = 3000
                            bodyGyro.CFrame = car.PrimaryPart.CFrame * CFrame.Angles(0, 0, math.rad(tiltAngle))
                            bodyGyro.Parent = car.PrimaryPart
                        end
                    else
                        if bodyGyro then
                            bodyGyro:Destroy()
                            bodyGyro = nil
                        end
                    end
                end

                local function lockRotation(lock)
                    isRotationLocked = lock
                end

                local UserInputService = game:GetService("UserInputService")
                UserInputService.InputBegan:Connect(function(input, isProcessed)
                    if isProcessed or not isArabWheelerActive then return end
                    if input.KeyCode == Enum.KeyCode.J then
                        isArabWheelerActive = false
                        isOnTwoWheels = false
                        isRotationLocked = false
                        tiltCar(isOnTwoWheels)
                    elseif input.KeyCode == Enum.KeyCode.V then
                        isOnTwoWheels = not isOnTwoWheels
                        tiltCar(isOnTwoWheels)
                    elseif input.KeyCode == Enum.KeyCode.G then
                        lockRotation(not isRotationLocked)
                    end
                end)

                local RunService = game:GetService("RunService")
                RunService.RenderStepped:Connect(function()
                    if isArabWheelerActive and isOnTwoWheels and not isRotationLocked then
                        local player = game.Players.LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local humanoid = character:FindFirstChild("Humanoid")

                        if humanoid then
                            local steeringInput = humanoid.MoveDirection.X
                            speed = math.min(speed + 0.5, maxSpeed)
                            local steeringAdjustment = steeringInput * (speed / maxSpeed) * driftFactor
                            if bodyGyro then
                                bodyGyro.CFrame = car.PrimaryPart.CFrame * CFrame.Angles(0, 0, math.rad(tiltAngle))
                                car.PrimaryPart.CFrame = car.PrimaryPart.CFrame * CFrame.new(steeringAdjustment, 0, 0)
                            end
                        end
                    else
                        speed = math.max(speed - 1, 0)
                    end
                end)
            end)

            if success then
                ArrayField:Notify({
                    Title = "Success",
                    Content = "Successfully attached to your car.",
                    Duration = 5,
                    Image = 4483362458,
                    Actions = {
                        Ignore = {
                            Name = "Okay!",
                            Callback = function()
                                print("The user tapped Okay!")
                            end
                        }
                    }
                })
            else
                ArrayField:Notify({
                    Title = "Error",
                    Content = "An error has been detected. (R52)",
                    Duration = 5,
                    Image = 4483362458,
                    Actions = {
                        Ignore = {
                            Name = "Okay!",
                            Callback = function()
                                print("The user tapped Okay!")
                            end
                        }
                    }
                })
            end
        end
    end,
})
