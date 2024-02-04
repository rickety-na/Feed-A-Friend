local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Rojo.Packages
local Knit = require(Packages.Knit)
local ProfileService = require(ServerScriptService.DataStore.Libs.ProfileService)

local InviteService = Knit.CreateController { 
    Name = "InviteService",
    Client = {}
}

function InviteService:SendFriendReward(invited, profile, data)
    if not profile.invited then
        profile.invited = true
        profile.friendWhoInvited = data.senderUserID

        local ProfileStore = ProfileService.GetProfileStore(
        "InviterFriendData", {
            FriendsInvited = {}
        })

        local inviterProfile = ProfileStore:LoadProfileAsync("Player_" .. data.senderUserID)
        table.insert(invited.userId, inviterProfile.FriendsInvited)

        if #inviterProfile.FriendsInvited == 1 then
            print("Give reward to inviter [1]")
        elseif #inviterProfile.FriendsInvited == 2 then
            print("Give reward to inviter [2]")
        elseif #inviterProfile.FriendsInvited == 3 then
            print("Give reward to inviter [3]")
        elseif #inviterProfile.FriendsInvited == 4 then
            print("Give reward to inviter [4]")
        end

        print("Give something to user who joined!")
    end
end

function InviteService:CheckIfPlayerGotInvited(player, data)

    local ProfileStore = ProfileService.GetProfileStore(
    "InvitedFriendsData", {
        invited = false,
        userIdWhoInvited = ""
    })
    
    local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId)
        profile:ListenToRelease(function()
            player:Kick()
        end)
        if player:IsDescendantOf(Players) == true then
            if not profile.invited then
                self:SendFriendReward(player, profile, data)
            end
        else
            profile:Release()
        end
    else
        player:Kick()
    end

end

function InviteService:_FriendsJoining()
    local trove = require(Knit.Util.Trove.new())

    local function onPlayerAdded(player)

        local launchData
    
        for _ = 1, self.Configurations.RetryAttempLimit do
            task.wait(self.Configurations.RetryAttempDelay)
            local joinData = player:GetJoinData()
            if joinData.LaunchData ~= "" then
                launchData = joinData.LaunchData
                break
            end
        end
    
        if launchData then
            local data = HttpService:JSONDecode(launchData)
            if data.senderUserID == nil then print("Wasnt invited by friend") return end
            self:CheckIfPlayerGotInvited(player, data)
        else
            warn("No launch data received!")
        end
    end

    trove:Add(Players.OnPlayerAdded:Connect(onPlayerAdded))
end

function InviteService:KnitInit()
    self.Configurations = require(script.Parent.InviteConfiguration)
    self:_FriendsJoining()
end

function InviteService:KnitStart()
	
end

return InviteService