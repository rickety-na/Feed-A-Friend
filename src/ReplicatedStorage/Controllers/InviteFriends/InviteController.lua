local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage.Rojo.Packages
local Knit = require(Packages.Knit)

local InviteController = Knit.CreateController { 
    Name = "InviteController",
    Client = {}
}

function InviteController:ShowFriends()
    print("Helloworld")
    local button = Knit.Player:WaitForChild("PlayerGui"):WaitForChild("MainUI").MidLeft.Invite
    button.MouseButton1Click:Connect(function()

        local data = {
            senderUserID = Knit.Player.UserId
        }
        
        local launchData = HttpService:JSONEncode(data)

        local inviteOptions = Instance.new("ExperienceInviteOptions")
        inviteOptions.PromptMessage = self.Configurations.FriendPromptMessage
        inviteOptions.LaunchData = launchData

        local function canSendGameInvite(sendingPlayer)
			local success, canSend = pcall(function()
				return SocialService:CanSendGameInviteAsync(sendingPlayer)
			end)
			return success and canSend
		end

		local canInvite = canSendGameInvite(Knit.Player)
        
		if canInvite then
			local success, errorMessage = pcall(function()
				SocialService:PromptGameInvite(Knit.Player, inviteOptions)
			end)
		end
    end)
end

function InviteController:KnitInit()
    print("InviteController KnitInit called")
    self.Configurations = require(script.Parent.InviteConfiguration)
end

function InviteController:KnitStart()
    print("InviteController KnitStart called")
    self:ShowFriends()
end



return InviteController