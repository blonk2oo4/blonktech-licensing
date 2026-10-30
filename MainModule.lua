local HttpService = game:GetService("HttpService")

local FIREBASE_URL =
    "https://blonktech-licence-keys-default-rtdb.firebaseio.com"

local PRODUCT_ID = "Missile System"

local function CheckLicense()

    local url = FIREBASE_URL
        .. "/"
        .. HttpService:UrlEncode(PRODUCT_ID)
        .. ".json"

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if not success then
        warn("[License] Firebase request failed:", response)
        return false
    end

    local decoded, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not decoded or type(data) ~= "table" then
        return false
    end

    local creatorId = tostring(game.CreatorId)

    -- Individual-owned experience
    if game.CreatorType == Enum.CreatorType.User then
        local userData = data[creatorId]

        return type(userData) == "table"
            and userData.License == true
    end

    -- Group-owned experience
    if game.CreatorType == Enum.CreatorType.Group then
        for _, userData in pairs(data) do
            if type(userData) == "table"
                and userData.License == true
                and type(userData.Groups) == "table"
                and userData.Groups[creatorId] == true then

                return true
            end
        end
    end

    return false
end

return CheckLicense()
