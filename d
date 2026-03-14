local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Epstein',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    World = Window:AddTab('World'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Services = {
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    TeleportService = game:GetService("TeleportService"),
    StarterGui = game:GetService("StarterGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    SoundService = game:GetService("SoundService")
}

local Terrain = Services.Workspace.Terrain
local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- State table
local State = {
    -- Original
    Original = {},
    -- Current effects
    Current = {
        Skybox = nil,
        Atmosphere = nil,
        Bloom = nil,
        Blur = nil,
        ColorCorrection = nil,
        DOF = nil,
        SunRays = nil,
        Clouds = nil,
        WeatherPart = nil,
        WeatherParticle = nil,
        Highlight = nil,
        BackgroundSound = nil,
        MotionBlur = nil
    },
    -- ESP
    ESP = {
        Enabled = false,
        BoxEnabled = false,
        TracerEnabled = false,
        SkeletonEnabled = false,
        ShowName = false,
        ShowDistance = false,
        ShowHealth = false,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TracerColor = Color3.fromRGB(255, 255, 255),
        SkeletonColor = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        MaxDistance = 1000,
        BoxThickness = 1,
        TracerThickness = 1,
        SkeletonThickness = 1,
        TextSize = 13,
        Players = {},
        RenderConnection = nil
    },
    -- Death Counter
    DeathCounter = {
        Enabled = false,
        SoundEnabled = true,
        Volume = 10,
        NotifyEnabled = true,
        SoundID = "rbxassetid://6476791205",
        Connections = {}
    },
    -- Move Detection
    MoveDetection = {
        Enabled = false,
        NotifyEnabled = true,
        Selection = "All Moves",
        Connections = {}
    },
    -- Staff Detection
    StaffDetection = {
        Enabled = false,
        CheckGroup = true,
        CheckIDs = true,
        CheckFriends = true,
        Anticheat = true,
        Avoid = "AutoRejoin",
        RejoinDelay = 3,
        GroupID = 12013007,
        ValidRoles = {
            ["Tester"] = true,
            ["Moderator"] = true,
            ["Contributor"] = true,
            ["Developer"] = true,
            ["Owner"] = true
        },
        SpecialIDs = {
            422755031,198131804,681405668,3414432341,339633571,
            430966809,2039323684,117723419,1015595932,263944298,
            112905203,2284964418,1266437961,3120648134,1148139861,
            1633233654,3350014406,971193650,661273560,66105529,
            77342385,167343092,2055306963,141984224,438917845,
            1391134999,1796550069,255671730,3162123826,1059541187,
            1259898795,31070091,1041867508,994994173,1446694201,
            77525605,1001242712,2533866869,4983064295
        }
    },
    -- Background Noise
    BackgroundNoise = {
        Sounds = {
            ["windy winter"] = "rbxassetid://6046340391",
            ["light rain"] = "rbxassetid://18862087062",
            ["thunderstorm"] = "rbxassetid://4305545740",
            ["night"] = "rbxassetid://179507208",
            ["day"] = "rbxassetid://6189453706"
        }
    },
    -- Aspect Ratio
    AspectRatio = {
        Multiplier = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
        LastTweenValue = 0,
        TweenFunction = nil,
        Connection = nil
    },
    -- Motion Blur
    MotionBlur = {
        Intensity = 2750,
        LastLookVector = nil,
        SmoothedBlurSize = 0,
        Connection = nil
    },
    -- Local Material
    LocalMaterial = {
        Active = false,
        MaterialType = Enum.Material.Neon,
        Color = Color3.fromRGB(249, 217, 255),
        Transparency = 0.2,
        CharacterAddedConnection = nil,
        DescriptionChangedConnection = nil
    },
    -- Particle Aura
    ParticleAura = {
        Enabled = false,
        CurrentType = "angel",
        Particles = {},
        Connection = nil,
        Types = {
            ["starlight"] = "rbxassetid://134645216613107",
            ["heavenly"] = "rbxassetid://139300897520961",
            ["ribbon"] = "rbxassetid://132069507632161",
            ["sakura"] = "rbxassetid://81755778619404",
            ["angel"] = "rbxassetid://97658130917593",
            ["wind"] = "rbxassetid://80694081850877",
            ["flow"] = "rbxassetid://119913533725648",
            ["star"] = "rbxassetid://73754563740680"
        },
        LoadedModels = {}
    },
    -- Time
    TimeConnection = nil,
    -- Materials
    OriginalMaterials = {},
    -- Weather
    WeatherConnection = nil
}

-- Store
local function StoreOriginals()
    local L = Services.Lighting
    State.Original = {
        Ambient = L.Ambient,
        OutdoorAmbient = L.OutdoorAmbient,
        Brightness = L.Brightness,
        ClockTime = L.ClockTime,
        FogColor = L.FogColor,
        FogStart = L.FogStart,
        FogEnd = L.FogEnd,
        GeographicLatitude = L.GeographicLatitude,
        Exposure = L.ExposureCompensation,
        GlobalShadows = L.GlobalShadows,
        Technology = L.Technology,
        WaterColor = Terrain.WaterColor,
        WaterReflectance = Terrain.WaterReflectance,
        WaterTransparency = Terrain.WaterTransparency,
        WaterWaveSize = Terrain.WaterWaveSize,
        WaterWaveSpeed = Terrain.WaterWaveSpeed
    }
end
StoreOriginals()
-- Skyboxes data
local Skyboxes = {
    ["Default"] = nil,
    ["Galaxy"] = {
        SkyboxBk = "rbxassetid://159454299",
        SkyboxDn = "rbxassetid://159454296",
        SkyboxFt = "rbxassetid://159454293",
        SkyboxLf = "rbxassetid://159454286",
        SkyboxRt = "rbxassetid://159454300",
        SkyboxUp = "rbxassetid://159454288"
    },
    ["Nebula"] = {
        SkyboxBk = "rbxassetid://5260806240",
        SkyboxDn = "rbxassetid://5260806240",
        SkyboxFt = "rbxassetid://5260806240",
        SkyboxLf = "rbxassetid://5260806240",
        SkyboxRt = "rbxassetid://5260806240",
        SkyboxUp = "rbxassetid://5260806240"
    },
    ["Sunset"] = {
        SkyboxBk = "rbxassetid://150939022",
        SkyboxDn = "rbxassetid://150939006",
        SkyboxFt = "rbxassetid://150939014",
        SkyboxLf = "rbxassetid://150939027",
        SkyboxRt = "rbxassetid://150939033",
        SkyboxUp = "rbxassetid://150939038"
    },
    ["Midnight"] = {
        SkyboxBk = "rbxassetid://12862059227",
        SkyboxDn = "rbxassetid://12862059227",
        SkyboxFt = "rbxassetid://12862059227",
        SkyboxLf = "rbxassetid://12862059227",
        SkyboxRt = "rbxassetid://12862059227",
        SkyboxUp = "rbxassetid://12862059227"
    },
    ["Purple Nebula"] = {
        SkyboxBk = "rbxassetid://5705557367",
        SkyboxDn = "rbxassetid://5705557367",
        SkyboxFt = "rbxassetid://5705557367",
        SkyboxLf = "rbxassetid://5705557367",
        SkyboxRt = "rbxassetid://5705557367",
        SkyboxUp = "rbxassetid://5705557367"
    },
    ["Space"] = {
        SkyboxBk = "rbxassetid://166509999",
        SkyboxDn = "rbxassetid://166510057",
        SkyboxFt = "rbxassetid://166510116",
        SkyboxLf = "rbxassetid://166510092",
        SkyboxRt = "rbxassetid://166510131",
        SkyboxUp = "rbxassetid://166510012"
    },
    ["Clouds"] = {
        SkyboxBk = "rbxassetid://877169251",
        SkyboxDn = "rbxassetid://877169199",
        SkyboxFt = "rbxassetid://877169064",
        SkyboxLf = "rbxassetid://877169153",
        SkyboxRt = "rbxassetid://877169296",
        SkyboxUp = "rbxassetid://877169338"
    },
    ["Doom"] = {
        SkyboxBk = "rbxassetid://415688378",
        SkyboxDn = "rbxassetid://415688378",
        SkyboxFt = "rbxassetid://415688378",
        SkyboxLf = "rbxassetid://415688378",
        SkyboxRt = "rbxassetid://415688378",
        SkyboxUp = "rbxassetid://415688378"
    },
    ["Red Night"] = {
        SkyboxBk = "rbxassetid://401664839",
        SkyboxDn = "rbxassetid://401664839",
        SkyboxFt = "rbxassetid://401664839",
        SkyboxLf = "rbxassetid://401664839",
        SkyboxRt = "rbxassetid://401664839",
        SkyboxUp = "rbxassetid://401664839"
    },
    ["Anime"] = {
        SkyboxBk = "rbxassetid://15924818857",
        SkyboxDn = "rbxassetid://15924818857",
        SkyboxFt = "rbxassetid://15924818857",
        SkyboxLf = "rbxassetid://15924818857",
        SkyboxRt = "rbxassetid://15924818857",
        SkyboxUp = "rbxassetid://15924818857"
    },
    ["Morning"] = {
        SkyboxBk = "rbxassetid://9544505500",
        SkyboxDn = "rbxassetid://9544547905",
        SkyboxFt = "rbxassetid://9544504852",
        SkyboxLf = "rbxassetid://9544547694",
        SkyboxRt = "rbxassetid://9544547542",
        SkyboxUp = "rbxassetid://9544547398"
    },
    ["Rain"] = {
        SkyboxBk = "rbxassetid://121654329755016",
        SkyboxDn = "rbxassetid://121654329755016",
        SkyboxFt = "rbxassetid://121654329755016",
        SkyboxLf = "rbxassetid://121654329755016",
        SkyboxRt = "rbxassetid://121654329755016",
        SkyboxUp = "rbxassetid://121654329755016"
    },
    ["Snow"] = {
        SkyboxBk = "rbxassetid://110010584259758",
        SkyboxDn = "rbxassetid://110010584259758",
        SkyboxFt = "rbxassetid://110010584259758",
        SkyboxLf = "rbxassetid://110010584259758",
        SkyboxRt = "rbxassetid://110010584259758",
        SkyboxUp = "rbxassetid://110010584259758"
    },
    ["Storm"] = {
        SkyboxBk = "rbxassetid://94816009531038",
        SkyboxDn = "rbxassetid://94816009531038",
        SkyboxFt = "rbxassetid://94816009531038",
        SkyboxLf = "rbxassetid://94816009531038",
        SkyboxRt = "rbxassetid://94816009531038",
        SkyboxUp = "rbxassetid://94816009531038"
    }
}

-- New Skybox Data
local NewSkyboxData = {
    ["black storm"] = {
        SkyboxLf = "rbxassetid://15502507918",
        SkyboxUp = "rbxassetid://15502511911",
        SkyboxRt = "rbxassetid://15502509398",
        SkyboxFt = "rbxassetid://15502510289",
        SkyboxDn = "rbxassetid://15502508460",
        SkyboxBk = "rbxassetid://15502511288"
    },
    ["blue space"] = {
        SkyboxLf = "rbxassetid://15536114370",
        SkyboxUp = "rbxassetid://15536117282",
        SkyboxRt = "rbxassetid://15536118762",
        SkyboxFt = "rbxassetid://15536116141",
        SkyboxDn = "rbxassetid://15536112543",
        SkyboxBk = "rbxassetid://15536110634"
    },
    ["realistic"] = {
        SkyboxUp = "rbxassetid://653719321",
        SkyboxDn = "rbxassetid://653718790",
        SkyboxLf = "rbxassetid://653719190",
        SkyboxFt = "rbxassetid://653719067",
        SkyboxRt = "rbxassetid://653718931",
        SkyboxBk = "rbxassetid://653719502"
    },
    ["stormy"] = {
        SkyboxUp = "http://www.roblox.com/asset/?id=18703232671",
        SkyboxBk = "http://www.roblox.com/asset/?id=18703245834",
        SkyboxLf = "http://www.roblox.com/asset/?id=18703237556",
        SkyboxDn = "http://www.roblox.com/asset/?id=18703243349",
        SkyboxFt = "http://www.roblox.com/asset/?id=18703240532",
        SkyboxRt = "http://www.roblox.com/asset/?id=18703235430"
    },
    ["pink"] = {
        SkyboxUp = "rbxassetid://12216108877",
        SkyboxLf = "rbxassetid://12216110170",
        SkyboxRt = "rbxassetid://12216110471",
        SkyboxFt = "rbxassetid://12216109489",
        SkyboxBk = "rbxassetid://12216109205",
        SkyboxDn = "rbxassetid://12216109875"
    }
}

-- Shader
local ShaderPresets = {
    ["Default"] = {
        Ambient = State.Original.Ambient,
        OutdoorAmbient = State.Original.OutdoorAmbient,
        Brightness = State.Original.Brightness,
        ClockTime = State.Original.ClockTime,
        ExposureCompensation = State.Original.Exposure,
        GlobalShadows = State.Original.GlobalShadows,
        ColorShiftBottom = Services.Lighting.ColorShift_Bottom,
        ColorShiftTop = Services.Lighting.ColorShift_Top,
        EnvironmentDiffuseScale = Services.Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Services.Lighting.EnvironmentSpecularScale,
        FogColor = State.Original.FogColor,
        FogStart = State.Original.FogStart,
        FogEnd = State.Original.FogEnd
    },
    ["Morning"] = {
        Ambient = Color3.fromRGB(120, 130, 150),
        OutdoorAmbient = Color3.fromRGB(140, 150, 170),
        Brightness = 2,
        ClockTime = 7,
        ExposureCompensation = 0.2,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(255, 200, 150),
        ColorShiftTop = Color3.fromRGB(255, 220, 180),
        EnvironmentDiffuseScale = 0.5,
        EnvironmentSpecularScale = 0.5,
        FogColor = Color3.fromRGB(200, 210, 230),
        FogStart = 50,
        FogEnd = 500
    },
    ["Midday"] = {
        Ambient = Color3.fromRGB(200, 200, 220),
        OutdoorAmbient = Color3.fromRGB(255, 255, 255),
        Brightness = 3,
        ClockTime = 12,
        ExposureCompensation = 0,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(255, 255, 255),
        ColorShiftTop = Color3.fromRGB(255, 255, 255),
        EnvironmentDiffuseScale = 1,
        EnvironmentSpecularScale = 1,
        FogColor = Color3.fromRGB(192, 192, 192),
        FogStart = 100,
        FogEnd = 1000
    },
    ["Afternoon"] = {
        Ambient = Color3.fromRGB(180, 160, 140),
        OutdoorAmbient = Color3.fromRGB(220, 200, 180),
        Brightness = 2.5,
        ClockTime = 16,
        ExposureCompensation = -0.2,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(255, 180, 120),
        ColorShiftTop = Color3.fromRGB(255, 200, 150),
        EnvironmentDiffuseScale = 0.7,
        EnvironmentSpecularScale = 0.7,
        FogColor = Color3.fromRGB(220, 200, 180),
        FogStart = 80,
        FogEnd = 800
    },
    ["Evening"] = {
        Ambient = Color3.fromRGB(100, 80, 100),
        OutdoorAmbient = Color3.fromRGB(150, 120, 140),
        Brightness = 1.5,
        ClockTime = 18,
        ExposureCompensation = -0.5,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(255, 100, 80),
        ColorShiftTop = Color3.fromRGB(255, 150, 100),
        EnvironmentDiffuseScale = 0.4,
        EnvironmentSpecularScale = 0.4,
        FogColor = Color3.fromRGB(150, 120, 140),
        FogStart = 50,
        FogEnd = 600
    },
    ["Night"] = {
        Ambient = Color3.fromRGB(40, 40, 60),
        OutdoorAmbient = Color3.fromRGB(60, 60, 80),
        Brightness = 0.8,
        ClockTime = 22,
        ExposureCompensation = -1,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(50, 50, 80),
        ColorShiftTop = Color3.fromRGB(60, 60, 100),
        EnvironmentDiffuseScale = 0.2,
        EnvironmentSpecularScale = 0.2,
        FogColor = Color3.fromRGB(50, 50, 70),
        FogStart = 30,
        FogEnd = 400
    },
    ["Midnight"] = {
        Ambient = Color3.fromRGB(20, 20, 30),
        OutdoorAmbient = Color3.fromRGB(30, 30, 40),
        Brightness = 0.5,
        ClockTime = 0,
        ExposureCompensation = -1.5,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(30, 30, 50),
        ColorShiftTop = Color3.fromRGB(40, 40, 60),
        EnvironmentDiffuseScale = 0.1,
        EnvironmentSpecularScale = 0.1,
        FogColor = Color3.fromRGB(30, 30, 40),
        FogStart = 20,
        FogEnd = 300
    },
    ["Rain"] = {
        Ambient = Color3.fromRGB(80, 80, 90),
        OutdoorAmbient = Color3.fromRGB(100, 100, 110),
        Brightness = 1.2,
        ClockTime = 12,
        ExposureCompensation = -0.8,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(120, 120, 130),
        ColorShiftTop = Color3.fromRGB(130, 130, 140),
        EnvironmentDiffuseScale = 0.3,
        EnvironmentSpecularScale = 0.3,
        FogColor = Color3.fromRGB(150, 150, 160),
        FogStart = 20,
        FogEnd = 300
    },
    ["Snow"] = {
        Ambient = Color3.fromRGB(200, 210, 220),
        OutdoorAmbient = Color3.fromRGB(230, 240, 250),
        Brightness = 2.2,
        ClockTime = 12,
        ExposureCompensation = 0.3,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(240, 250, 255),
        ColorShiftTop = Color3.fromRGB(250, 255, 255),
        EnvironmentDiffuseScale = 0.8,
        EnvironmentSpecularScale = 0.8,
        FogColor = Color3.fromRGB(220, 230, 240),
        FogStart = 50,
        FogEnd = 600
    },
    ["Storm"] = {
        Ambient = Color3.fromRGB(30, 30, 35),
        OutdoorAmbient = Color3.fromRGB(40, 40, 45),
        Brightness = 0.6,
        ClockTime = 15,
        ExposureCompensation = -1.2,
        GlobalShadows = true,
        ColorShiftBottom = Color3.fromRGB(50, 50, 55),
        ColorShiftTop = Color3.fromRGB(60, 60, 65),
        EnvironmentDiffuseScale = 0.2,
        EnvironmentSpecularScale = 0.2,
        FogColor = Color3.fromRGB(40, 40, 45),
        FogStart = 10,
        FogEnd = 200
    }
}

-- Moves
local Moves = {
    ["11365563255"] = "Table Flip",
    ["13927612951"] = "Omni Directional Punch",
    ["12983333733"] = "Serious Punch",
    ["13633430816"] = "Consecutive Punches",
    ["14004235777"] = "Serious Table Flip",
    ["14023889058"] = "Death Counter"
}

-- Weather
local WeatherTypes = {
    ["rain"] = {
        Speed = NumberRange.new(60, 60),
        LockedToPart = true,
        Rate = 600,
        Texture = "rbxassetid://1822883048",
        EmissionDirection = Enum.NormalId.Bottom,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.25, 0.784),
            NumberSequenceKeypoint.new(0.75, 0.784),
            NumberSequenceKeypoint.new(1, 1)
        },
        Lifetime = NumberRange.new(0.8, 0.8),
        LightEmission = 0.05,
        LightInfluence = 0.9,
        Orientation = Enum.ParticleOrientation.FacingCameraWorldUp,
        Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 10),
            NumberSequenceKeypoint.new(1, 10)
        }
    },
    ["snow"] = {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.737),
            NumberSequenceKeypoint.new(0.973, 0.769),
            NumberSequenceKeypoint.new(1, 1)
        },
        Texture = "http://www.roblox.com/asset/?id=99851851",
        SpreadAngle = Vector2.new(50, 50),
        Speed = NumberRange.new(30, 30),
        LightEmission = 0.5,
        Rate = 1000,
        EmissionDirection = Enum.NormalId.Bottom,
        Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.33),
            NumberSequenceKeypoint.new(0.551, 0.402),
            NumberSequenceKeypoint.new(1, 0.33)
        }
    },
    ["light rain"] = {
        LockedToPart = true,
        Rate = 500,
        Squash = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 3),
            NumberSequenceKeypoint.new(1, 3)
        },
        LightInfluence = 0.3,
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.435, 0),
            NumberSequenceKeypoint.new(1, 0)
        },
        Texture = "rbxasset://textures/particles/sparkles_main.dds",
        Speed = NumberRange.new(30, 50),
        Lifetime = NumberRange.new(9, 9),
        LightEmission = 0.5,
        Brightness = 2,
        EmissionDirection = Enum.NormalId.Bottom,
        Orientation = Enum.ParticleOrientation.FacingCameraWorldUp,
        Size = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 0.2)
        }
    }
}
-- Helper
local function Notify(title, text)
    pcall(function()
        Services.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 10
        })
    end)
end

local function CleanRole(role)
    role = role:gsub("[%z\1-\31\127-\255]", "")
    role = role:gsub("[^%a%s]", "")
    return role:match("^%s*(.-)%s*$")
end

local function RejoinGame()
    task.delay(State.StaffDetection.RejoinDelay, function()
        Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

-- Sky
local function GetSkyObject()
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("Sky") then
            return v
        end
    end
    return nil
end

local function SaveOriginalSkybox()
    local sky = GetSkyObject()
    if sky and not State.Original.Skybox then
        State.Original.Skybox = {
            SkyboxBk = sky.SkyboxBk,
            SkyboxDn = sky.SkyboxDn,
            SkyboxFt = sky.SkyboxFt,
            SkyboxLf = sky.SkyboxLf,
            SkyboxRt = sky.SkyboxRt,
            SkyboxUp = sky.SkyboxUp,
            SunTextureId = sky.SunTextureId,
            MoonTextureId = sky.MoonTextureId
        }
    end
end

local function ApplySkybox(skyData)
    -- custom skybox
    if State.Current.Skybox then
        State.Current.Skybox:Destroy()
        State.Current.Skybox = nil
    end
    
    -- WorldVisuals_Sky
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("Sky") and v.Name == "WorldVisuals_Sky" then
            v:Destroy()
        end
    end
    
    if not skyData then return end
    
    -- Sky object
    State.Current.Skybox = Instance.new("Sky")
    State.Current.Skybox.Name = "WorldVisuals_Sky"
    State.Current.Skybox.SkyboxBk = skyData.SkyboxBk
    State.Current.Skybox.SkyboxDn = skyData.SkyboxDn
    State.Current.Skybox.SkyboxFt = skyData.SkyboxFt
    State.Current.Skybox.SkyboxLf = skyData.SkyboxLf
    State.Current.Skybox.SkyboxRt = skyData.SkyboxRt
    State.Current.Skybox.SkyboxUp = skyData.SkyboxUp
    State.Current.Skybox.Parent = Services.Lighting
end

local function ApplyNewSkybox(skyboxName)
    SaveOriginalSkybox()
    local sky = GetSkyObject()
    if not sky then
        Library:Notify("No Sky object found in Lighting!", 3)
        return
    end
    
    local data = NewSkyboxData[skyboxName]
    if not data then return end
    
    sky.SkyboxBk = data.SkyboxBk
    sky.SkyboxDn = data.SkyboxDn
    sky.SkyboxFt = data.SkyboxFt
    sky.SkyboxLf = data.SkyboxLf
    sky.SkyboxRt = data.SkyboxRt
    sky.SkyboxUp = data.SkyboxUp
end

local function ResetSkybox()
    if State.Original.Skybox then
        local sky = GetSkyObject()
        if sky then
            sky.SkyboxBk = State.Original.Skybox.SkyboxBk
            sky.SkyboxDn = State.Original.Skybox.SkyboxDn
            sky.SkyboxFt = State.Original.Skybox.SkyboxFt
            sky.SkyboxLf = State.Original.Skybox.SkyboxLf
            sky.SkyboxRt = State.Original.Skybox.SkyboxRt
            sky.SkyboxUp = State.Original.Skybox.SkyboxUp
            sky.SunTextureId = State.Original.Skybox.SunTextureId
            sky.MoonTextureId = State.Original.Skybox.MoonTextureId
        end
    end
    
    if State.Current.Skybox then
        State.Current.Skybox:Destroy()
        State.Current.Skybox = nil
    end
end

local function RemoveSkybox()
    if State.Current.Skybox then
        State.Current.Skybox:Destroy()
        State.Current.Skybox = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("Sky") and v.Name == "WorldVisuals_Sky" then
            v:Destroy()
        end
    end
end

-- World Visuals 
local function ApplyShaderPreset(preset)
    local L = Services.Lighting
    L.Ambient = preset.Ambient
    L.OutdoorAmbient = preset.OutdoorAmbient
    L.Brightness = preset.Brightness
    L.ClockTime = preset.ClockTime
    L.ExposureCompensation = preset.ExposureCompensation
    L.GlobalShadows = preset.GlobalShadows
    L.ColorShift_Bottom = preset.ColorShiftBottom
    L.ColorShift_Top = preset.ColorShiftTop
    L.EnvironmentDiffuseScale = preset.EnvironmentDiffuseScale
    L.EnvironmentSpecularScale = preset.EnvironmentSpecularScale
    L.FogColor = preset.FogColor
    L.FogStart = preset.FogStart
    L.FogEnd = preset.FogEnd
end

local function ResetShader()
    local L = Services.Lighting
    L.Ambient = State.Original.Ambient
    L.OutdoorAmbient = State.Original.OutdoorAmbient
    L.Brightness = State.Original.Brightness
    L.ClockTime = State.Original.ClockTime
    L.ExposureCompensation = State.Original.Exposure
    L.GlobalShadows = State.Original.GlobalShadows
    L.FogColor = State.Original.FogColor
    L.FogStart = State.Original.FogStart
    L.FogEnd = State.Original.FogEnd
end

local function ApplyAmbience()
    local L = Services.Lighting
    L.Ambient = Options.AmbientColor.Value
    L.OutdoorAmbient = Options.OutdoorColor.Value
    L.Brightness = Options.Brightness.Value
    L.ExposureCompensation = Options.Exposure.Value
    if not Toggles.TimeFreeze.Value then
        L.ClockTime = Options.TimeOfDay.Value
    end
end

local function ResetAmbience()
    local L = Services.Lighting
    L.Ambient = State.Original.Ambient
    L.OutdoorAmbient = State.Original.OutdoorAmbient
    L.Brightness = State.Original.Brightness
    L.ClockTime = State.Original.ClockTime
    L.ExposureCompensation = State.Original.Exposure
end

local function ApplyFog()
    local L = Services.Lighting
    L.FogColor = Options.FogColor.Value
    L.FogStart = Options.FogStart.Value
    L.FogEnd = Options.FogEnd.Value
end

local function ResetFog()
    local L = Services.Lighting
    L.FogColor = State.Original.FogColor
    L.FogStart = State.Original.FogStart
    L.FogEnd = State.Original.FogEnd
end

local function ApplyAtmosphere()
    if State.Current.Atmosphere then
        State.Current.Atmosphere:Destroy()
    end
    State.Current.Atmosphere = Instance.new("Atmosphere")
    State.Current.Atmosphere.Name = "WorldVisuals_Atmosphere"
    State.Current.Atmosphere.Density = Options.Density.Value
    State.Current.Atmosphere.Offset = Options.Offset.Value
    State.Current.Atmosphere.Color = Options.AtmosphereColor.Value
    State.Current.Atmosphere.Decay = Options.DecayColor.Value
    State.Current.Atmosphere.Glare = Options.Glare.Value
    State.Current.Atmosphere.Haze = Options.Haze.Value
    State.Current.Atmosphere.Parent = Services.Lighting
end

local function RemoveAtmosphere()
    if State.Current.Atmosphere then
        State.Current.Atmosphere:Destroy()
        State.Current.Atmosphere = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("Atmosphere") and v.Name == "WorldVisuals_Atmosphere" then
            v:Destroy()
        end
    end
end

local function ApplyBloom()
    if State.Current.Bloom then
        State.Current.Bloom:Destroy()
    end
    State.Current.Bloom = Instance.new("BloomEffect")
    State.Current.Bloom.Name = "WorldVisuals_Bloom"
    State.Current.Bloom.Intensity = Options.BloomIntensity.Value
    State.Current.Bloom.Size = Options.BloomSize.Value
    State.Current.Bloom.Threshold = Options.BloomThreshold.Value
    State.Current.Bloom.Parent = Services.Lighting
end

local function RemoveBloom()
    if State.Current.Bloom then
        State.Current.Bloom:Destroy()
        State.Current.Bloom = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("BloomEffect") and v.Name == "WorldVisuals_Bloom" then
            v:Destroy()
        end
    end
end

local function ApplyBlur()
    if State.Current.Blur then
        State.Current.Blur:Destroy()
    end
    State.Current.Blur = Instance.new("BlurEffect")
    State.Current.Blur.Name = "WorldVisuals_Blur"
    State.Current.Blur.Size = Options.BlurSize.Value
    State.Current.Blur.Parent = Services.Lighting
end

local function RemoveBlur()
    if State.Current.Blur then
        State.Current.Blur:Destroy()
        State.Current.Blur = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("BlurEffect") and v.Name == "WorldVisuals_Blur" then
            v:Destroy()
        end
    end
end

local function ApplyColorCorrection()
    if State.Current.ColorCorrection then
        State.Current.ColorCorrection:Destroy()
    end
    State.Current.ColorCorrection = Instance.new("ColorCorrectionEffect")
    State.Current.ColorCorrection.Name = "WorldVisuals_CC"
    State.Current.ColorCorrection.Saturation = Options.Saturation.Value
    State.Current.ColorCorrection.Contrast = Options.Contrast.Value
    State.Current.ColorCorrection.TintColor = Options.TintColor.Value
    State.Current.ColorCorrection.Brightness = Options.CCBrightness.Value
    State.Current.ColorCorrection.Parent = Services.Lighting
end

local function RemoveColorCorrection()
    if State.Current.ColorCorrection then
        State.Current.ColorCorrection:Destroy()
        State.Current.ColorCorrection = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("ColorCorrectionEffect") and v.Name == "WorldVisuals_CC" then
            v:Destroy()
        end
    end
end

local function ApplyDOF()
    if State.Current.DOF then
        State.Current.DOF:Destroy()
    end
    State.Current.DOF = Instance.new("DepthOfFieldEffect")
    State.Current.DOF.Name = "WorldVisuals_DOF"
    State.Current.DOF.FocusDistance = Options.DOFFocus.Value
    State.Current.DOF.InFocusRadius = Options.DOFInFocus.Value
    State.Current.DOF.NearIntensity = Options.DOFNearBlur.Value
    State.Current.DOF.FarIntensity = Options.DOFFarBlur.Value
    State.Current.DOF.Parent = Services.Lighting
end

local function RemoveDOF()
    if State.Current.DOF then
        State.Current.DOF:Destroy()
        State.Current.DOF = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("DepthOfFieldEffect") and v.Name == "WorldVisuals_DOF" then
            v:Destroy()
        end
    end
end

local function ApplySunRays()
    if State.Current.SunRays then
        State.Current.SunRays:Destroy()
    end
    State.Current.SunRays = Instance.new("SunRaysEffect")
    State.Current.SunRays.Name = "WorldVisuals_SunRays"
    State.Current.SunRays.Intensity = Options.SunRaysIntensity.Value
    State.Current.SunRays.Spread = Options.SunRaysSpread.Value
    State.Current.SunRays.Parent = Services.Lighting
end

local function RemoveSunRays()
    if State.Current.SunRays then
        State.Current.SunRays:Destroy()
        State.Current.SunRays = nil
    end
    for _, v in pairs(Services.Lighting:GetChildren()) do
        if v:IsA("SunRaysEffect") and v.Name == "WorldVisuals_SunRays" then
            v:Destroy()
        end
    end
end

local function ApplyClouds()
    if State.Current.Clouds then
        State.Current.Clouds:Destroy()
    end
    State.Current.Clouds = Instance.new("Clouds")
    State.Current.Clouds.Name = "WorldVisuals_Clouds"
    State.Current.Clouds.Cover = Options.CloudCover.Value
    State.Current.Clouds.Density = Options.CloudDensity.Value
    State.Current.Clouds.Color = Options.CloudColor.Value
    State.Current.Clouds.Parent = Terrain
end

local function RemoveClouds()
    if State.Current.Clouds then
        State.Current.Clouds:Destroy()
        State.Current.Clouds = nil
    end
    for _, v in pairs(Terrain:GetChildren()) do
        if v:IsA("Clouds") and v.Name == "WorldVisuals_Clouds" then
            v:Destroy()
        end
    end
end

local function ApplyFullbright()
    if Toggles.Fullbright.Value then
        Services.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Services.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Services.Lighting.Brightness = 10
        Services.Lighting.GlobalShadows = false
    else
        if Toggles.AmbienceEnabled.Value then
            ApplyAmbience()
        else
            Services.Lighting.Ambient = State.Original.Ambient
            Services.Lighting.OutdoorAmbient = State.Original.OutdoorAmbient
            Services.Lighting.Brightness = State.Original.Brightness
        end
        if Toggles.ShadowEnabled.Value then
            Services.Lighting.GlobalShadows = Toggles.GlobalShadows.Value
        else
            Services.Lighting.GlobalShadows = State.Original.GlobalShadows
        end
    end
end

local function SimplifyTerrain()
    if Toggles.SimplifyTerrain.Value then
        State.OriginalMaterials = {}
        for _, part in pairs(Services.Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Material ~= Enum.Material.Air then
                State.OriginalMaterials[part] = part.Material
                part.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        for part, mat in pairs(State.OriginalMaterials) do
            if part and part.Parent then
                part.Material = mat
            end
        end
        State.OriginalMaterials = {}
    end
end

local function ApplyReflectance()
    if Toggles.ReflectanceEnabled.Value then
        for _, part in pairs(Services.Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Reflectance = Options.Reflectance.Value
            end
        end
    else
        for _, part in pairs(Services.Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Reflectance = 0
            end
        end
    end
end
-- Weather 
local function UpdateWeatherPosition()
    if State.Current.WeatherPart and Camera then
        State.Current.WeatherPart.CFrame = CFrame.new(Camera.CFrame.Position + Vector3.new(0, 20, 0))
    end
end

local function StartWeather()
    if State.Current.WeatherPart then
        State.Current.WeatherPart:Destroy()
    end
    if State.WeatherConnection then
        State.WeatherConnection:Disconnect()
    end
    
    State.Current.WeatherPart = Instance.new("Part")
    State.Current.WeatherPart.Size = Vector3.new(40, 40, 85)
    State.Current.WeatherPart.CanCollide = false
    State.Current.WeatherPart.Massless = true
    State.Current.WeatherPart.CastShadow = false
    State.Current.WeatherPart.Transparency = 1
    State.Current.WeatherPart.Anchored = true
    State.Current.WeatherPart.Name = "WeatherPart"
    State.Current.WeatherPart.Parent = Services.Workspace
    
    local weatherType = Options.WeatherType.Value
    local data = WeatherTypes[weatherType]
    local color = ColorSequence.new(Options.WeatherColor.Value)
    
    State.Current.WeatherParticle = Instance.new("ParticleEmitter")
    for prop, value in pairs(data) do
        State.Current.WeatherParticle[prop] = value
    end
    State.Current.WeatherParticle.Color = color
    State.Current.WeatherParticle.Parent = State.Current.WeatherPart
    
    local rateMultiplier = Options.WeatherRate.Value / 100
    State.Current.WeatherParticle.Rate = State.Current.WeatherParticle.Rate * rateMultiplier
    
    State.WeatherConnection = Services.RunService.Heartbeat:Connect(UpdateWeatherPosition)
    UpdateWeatherPosition()
end

local function StopWeather()
    if State.Current.WeatherPart then
        State.Current.WeatherPart:Destroy()
        State.Current.WeatherPart = nil
    end
    State.Current.WeatherParticle = nil
    if State.WeatherConnection then
        State.WeatherConnection:Disconnect()
        State.WeatherConnection = nil
    end
end

-- ESP 
local function CreateESP(player)
    if player == LocalPlayer then return end
    if State.ESP.Players[player] then return end

    local box = Drawing.new("Quad")
    box.Visible = false
    box.Thickness = State.ESP.BoxThickness
    box.Filled = false
    box.Color = State.ESP.BoxColor

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = State.ESP.TracerThickness
    tracer.Color = State.ESP.TracerColor

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size = State.ESP.TextSize
    nameText.Color = State.ESP.TextColor
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.new(0, 0, 0)

    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Size = State.ESP.TextSize
    distanceText.Color = State.ESP.TextColor
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.new(0, 0, 0)

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Size = State.ESP.TextSize
    healthText.Color = Color3.fromRGB(0, 255, 0)
    healthText.Center = true
    healthText.Outline = true
    healthText.OutlineColor = Color3.new(0, 0, 0)

    local skeleton = {}
    local bones = {
        {"Head","UpperTorso"},
        {"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},
        {"LeftUpperArm","LeftLowerArm"},
        {"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},
        {"RightUpperArm","RightLowerArm"},
        {"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},
        {"LeftUpperLeg","LeftLowerLeg"},
        {"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},
        {"RightUpperLeg","RightLowerLeg"},
        {"RightLowerLeg","RightFoot"}
    }

    for i = 1, #bones do
        skeleton[i] = Drawing.new("Line")
        skeleton[i].Thickness = State.ESP.SkeletonThickness
        skeleton[i].Visible = false
        skeleton[i].Color = State.ESP.SkeletonColor
    end

    State.ESP.Players[player] = {
        box = box,
        tracer = tracer,
        skeleton = skeleton,
        nameText = nameText,
        distanceText = distanceText,
        healthText = healthText,
        bones = bones
    }
end

local function RemoveESP(player)
    if not State.ESP.Players[player] then return end
    
    local data = State.ESP.Players[player]
    data.box:Remove()
    data.tracer:Remove()
    data.nameText:Remove()
    data.distanceText:Remove()
    data.healthText:Remove()
    
    for _, bone in pairs(data.skeleton) do
        bone:Remove()
    end
    
    State.ESP.Players[player] = nil
end

local function UpdateESP()
    if not State.ESP.Enabled then return end
    
    for player, data in pairs(State.ESP.Players) do
        if not player or not player.Parent then
            RemoveESP(player)
            continue
        end
        
        local character = player.Character
        if not character then
            data.box.Visible = false
            data.tracer.Visible = false
            data.nameText.Visible = false
            data.distanceText.Visible = false
            data.healthText.Visible = false
            for _, bone in pairs(data.skeleton) do
                bone.Visible = false
            end
            continue
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not hrp or not head then
            data.box.Visible = false
            data.tracer.Visible = false
            data.nameText.Visible = false
            data.distanceText.Visible = false
            data.healthText.Visible = false
            for _, bone in pairs(data.skeleton) do
                bone.Visible = false
            end
            continue
        end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > State.ESP.MaxDistance then
            data.box.Visible = false
            data.tracer.Visible = false
            data.nameText.Visible = false
            data.distanceText.Visible = false
            data.healthText.Visible = false
            for _, bone in pairs(data.skeleton) do
                bone.Visible = false
            end
            continue
        end
        
        local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        
        if visible then
            local boxSize = Vector2.new(40 * (1 / (pos.Z / 50)), 60 * (1 / (pos.Z / 50)))
            boxSize = Vector2.new(math.clamp(boxSize.X, 20, 100), math.clamp(boxSize.Y, 30, 150))
            
            -- Box ESP
            if State.ESP.BoxEnabled then
                data.box.PointA = Vector2.new(pos.X - boxSize.X/2, pos.Y - boxSize.Y/2)
                data.box.PointB = Vector2.new(pos.X + boxSize.X/2, pos.Y - boxSize.Y/2)
                data.box.PointC = Vector2.new(pos.X + boxSize.X/2, pos.Y + boxSize.Y/2)
                data.box.PointD = Vector2.new(pos.X - boxSize.X/2, pos.Y + boxSize.Y/2)
                data.box.Color = State.ESP.BoxColor
                data.box.Thickness = State.ESP.BoxThickness
                data.box.Visible = true
            else
                data.box.Visible = false
            end
            
            -- Tracer ESP
            if State.ESP.TracerEnabled then
                local tracerOrigin = Options.ESPTracerOrigin and Options.ESPTracerOrigin.Value or "Bottom"
                local originPos
                if tracerOrigin == "Bottom" then
                    originPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                elseif tracerOrigin == "Top" then
                    originPos = Vector2.new(Camera.ViewportSize.X/2, 0)
                elseif tracerOrigin == "Center" then
                    originPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                elseif tracerOrigin == "Mouse" then
                    local mouse = Services.UserInputService:GetMouseLocation()
                    originPos = Vector2.new(mouse.X, mouse.Y)
                end
                
                data.tracer.From = originPos
                data.tracer.To = Vector2.new(pos.X, pos.Y + boxSize.Y/2)
                data.tracer.Color = State.ESP.TracerColor
                data.tracer.Thickness = State.ESP.TracerThickness
                data.tracer.Visible = true
            else
                data.tracer.Visible = false
            end
            
            -- Skeleton ESP
            if State.ESP.SkeletonEnabled then
                for i, boneData in pairs(data.bones) do
                    local part0 = character:FindFirstChild(boneData[1])
                    local part1 = character:FindFirstChild(boneData[2])
                    
                    if part0 and part1 then
                        local p0, v0 = Camera:WorldToViewportPoint(part0.Position)
                        local p1, v1 = Camera:WorldToViewportPoint(part1.Position)
                        
                        if v0 and v1 then
                            data.skeleton[i].From = Vector2.new(p0.X, p0.Y)
                            data.skeleton[i].To = Vector2.new(p1.X, p1.Y)
                            data.skeleton[i].Color = State.ESP.SkeletonColor
                            data.skeleton[i].Thickness = State.ESP.SkeletonThickness
                            data.skeleton[i].Visible = true
                        else
                            data.skeleton[i].Visible = false
                        end
                    else
                        data.skeleton[i].Visible = false
                    end
                end
            else
                for _, bone in pairs(data.skeleton) do
                    bone.Visible = false
                end
            end
            
            -- Name ESP
            if State.ESP.ShowName then
                data.nameText.Text = player.Name
                data.nameText.Position = Vector2.new(headPos.X, headPos.Y - 20)
                data.nameText.Color = State.ESP.TextColor
                data.nameText.Size = State.ESP.TextSize
                data.nameText.Visible = true
            else
                data.nameText.Visible = false
            end
            
            -- Distance ESP
            if State.ESP.ShowDistance then
                data.distanceText.Text = math.floor(distance) .. "m"
                data.distanceText.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + 5)
                data.distanceText.Color = State.ESP.TextColor
                data.distanceText.Size = State.ESP.TextSize
                data.distanceText.Visible = true
            else
                data.distanceText.Visible = false
            end
            
            -- Health ESP
            if State.ESP.ShowHealth and humanoid then
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                data.healthText.Text = health .. "/" .. maxHealth
                data.healthText.Position = Vector2.new(pos.X, pos.Y + boxSize.Y/2 + (State.ESP.ShowDistance and 20 or 5))
                data.healthText.Color = Color3.fromRGB(255 - (health/maxHealth)*255, (health/maxHealth)*255, 0)
                data.healthText.Size = State.ESP.TextSize
                data.healthText.Visible = true
            else
                data.healthText.Visible = false
            end
        else
            data.box.Visible = false
            data.tracer.Visible = false
            data.nameText.Visible = false
            data.distanceText.Visible = false
            data.healthText.Visible = false
            for _, bone in pairs(data.skeleton) do
                bone.Visible = false
            end
        end
    end
end

local function StartESP()
    if State.ESP.RenderConnection then return end
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    State.ESP.RenderConnection = Services.RunService.RenderStepped:Connect(UpdateESP)
end

local function StopESP()
    if State.ESP.RenderConnection then
        State.ESP.RenderConnection:Disconnect()
        State.ESP.RenderConnection = nil
    end
    
    for player, _ in pairs(State.ESP.Players) do
        RemoveESP(player)
    end
    State.ESP.Players = {}
end
-- Death Counter 
local function DetectDeathCounter(player)
    if not State.DeathCounter.Enabled then return end
    
    local function onCharacterAdded(char)
        local connection
        connection = char.ChildAdded:Connect(function(obj)
            if not State.DeathCounter.Enabled then return end
            
            if obj:IsA("Accessory") and obj.Name == "Counter" then
                if State.DeathCounter.NotifyEnabled then
                    Library:Notify(player.Name .. " used Death Counter!", 3)
                end
                
                if State.DeathCounter.SoundEnabled then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local sound = Instance.new("Sound")
                        sound.SoundId = State.DeathCounter.SoundID
                        sound.Volume = State.DeathCounter.Volume
                        sound.Parent = hrp
                        sound:Play()
                        game:GetService("Debris"):AddItem(sound, 5)
                    end
                end
            end
        end)
        
        table.insert(State.DeathCounter.Connections, connection)
        
        char.Destroying:Connect(function()
            if connection then
                connection:Disconnect()
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    local connection = player.CharacterAdded:Connect(onCharacterAdded)
    table.insert(State.DeathCounter.Connections, connection)
end

local function StartDeathCounterDetection()
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            DetectDeathCounter(player)
        end
    end
    
    local connection = Services.Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            DetectDeathCounter(player)
        end
    end)
    table.insert(State.DeathCounter.Connections, connection)
end

local function StopDeathCounterDetection()
    for _, connection in pairs(State.DeathCounter.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    State.DeathCounter.Connections = {}
end

-- Move Detection 
local function DetectMoves(player)
    if not State.MoveDetection.Enabled then return end
    
    local function onCharacterAdded(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        local connection
        connection = humanoid.AnimationPlayed:Connect(function(anim)
            if not State.MoveDetection.Enabled then return end
            
            local id = anim.Animation.AnimationId
            id = id:match("%d+")
            
            if Moves[id] then
                local moveName = Moves[id]
                
                local shouldDetect = false
                if State.MoveDetection.Selection == "All Moves" then
                    shouldDetect = true
                elseif State.MoveDetection.Selection == moveName then
                    shouldDetect = true
                end
                
                if shouldDetect then
                    if State.MoveDetection.NotifyEnabled then
                        Library:Notify(player.Name .. " used " .. moveName .. "!", 3)
                    end
                end
            end
        end)
        
        table.insert(State.MoveDetection.Connections, connection)
        
        char.Destroying:Connect(function()
            if connection then
                connection:Disconnect()
            end
        end)
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    local connection = player.CharacterAdded:Connect(onCharacterAdded)
    table.insert(State.MoveDetection.Connections, connection)
end

local function StartMoveDetection()
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            DetectMoves(player)
        end
    end
    
    local connection = Services.Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            DetectMoves(player)
        end
    end)
    table.insert(State.MoveDetection.Connections, connection)
end

local function StopMoveDetection()
    for _, connection in pairs(State.MoveDetection.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    State.MoveDetection.Connections = {}
end

-- Staff Detection 
local function CheckPlayer(plr)
    if plr == LocalPlayer then return end
    local name = plr.DisplayName

    if State.StaffDetection.CheckGroup and plr:IsInGroup(State.StaffDetection.GroupID) then
        local role = CleanRole(plr:GetRoleInGroup(State.StaffDetection.GroupID))
        if State.StaffDetection.ValidRoles[role] then
            Notify("Staff Detected", name .. " | " .. role)
        end
    end

    if State.StaffDetection.CheckIDs then
        for _, id in ipairs(State.StaffDetection.SpecialIDs) do
            if plr.UserId == id then
                Notify("Special User Joined", name)
                break
            end
        end
    end

    if State.StaffDetection.CheckFriends then
        local found = {}
        for _, id in ipairs(State.StaffDetection.SpecialIDs) do
            local ok, isFriend = pcall(function()
                return plr:IsFriendsWith(id)
            end)
            if ok and isFriend then
                local n = "Unknown"
                pcall(function()
                    n = Services.Players:GetNameFromUserIdAsync(id)
                end)
                table.insert(found, n)
            end
        end
        if #found > 0 then
            Notify("Friend Alert", name .. " -> " .. table.concat(found, ", "))
        end
    end
end

local function StartStaffDetection()
    for _, p in ipairs(Services.Players:GetPlayers()) do
        task.spawn(CheckPlayer, p)
    end

    Services.Players.PlayerAdded:Connect(function(p)
        task.wait(1)
        CheckPlayer(p)
    end)

    if State.StaffDetection.Anticheat then
        Services.ReplicatedStorage.Replication.OnClientEvent:Connect(function(data)
            if typeof(data) == "table" then
                local e = rawget(data, "Effect")
                if e and tostring(e):lower() == "hicheck" then
                    Notify("Anticheat Flagged", "A1")

                    if State.StaffDetection.Avoid == "AutoLeave" then
                        LocalPlayer:Kick(" ")
                    elseif State.StaffDetection.Avoid == "AutoRejoin" then
                        RejoinGame()
                    end
                end
            end
        end)
    end
end
-- Background Noise
local function StartBackgroundNoise()
    if State.Current.BackgroundSound then
        State.Current.BackgroundSound:Destroy()
    end
    
    local soundType = Options.BackgroundNoiseSound.Value
    local soundId = State.BackgroundNoise.Sounds[soundType]
    
    if not soundId then return end
    
    State.Current.BackgroundSound = Instance.new("Sound")
    State.Current.BackgroundSound.SoundId = soundId
    State.Current.BackgroundSound.Volume = Options.BackgroundNoiseVolume.Value / 65
    State.Current.BackgroundSound.Looped = true
    State.Current.BackgroundSound.Name = "BackgroundNoise"
    State.Current.BackgroundSound.Parent = Services.SoundService
    State.Current.BackgroundSound:Play()
end

local function StopBackgroundNoise()
    if State.Current.BackgroundSound then
        State.Current.BackgroundSound:Destroy()
        State.Current.BackgroundSound = nil
    end
end

-- Aspect Ratio 
local function TweenAspectRatio(newValue, force)
    if State.AspectRatio.TweenFunction then
        for i = 1, #State.AspectRatio do
            if State.AspectRatio[i] == State.AspectRatio.TweenFunction then
                table.remove(State.AspectRatio, i)
                break
            end
        end
    end

    local elapsedTime = 0
    local oldLastTweenValue = State.AspectRatio.LastTweenValue

    local newTweenFunction = function(dt)
        elapsedTime = elapsedTime + dt
        local alpha = math.clamp(elapsedTime / 0.16, 0, 1)
        -- Simple 
        alpha = 1 - (1 - alpha) * (1 - alpha)
        State.AspectRatio.LastTweenValue = oldLastTweenValue + (newValue - oldLastTweenValue) * alpha
        State.AspectRatio.Multiplier = CFrame.new(0, 0, 0, 1, 0, 0, 0, State.AspectRatio.LastTweenValue, 0, 0, 0, 1)
        if force then
            Camera.CFrame = Camera.CFrame * State.AspectRatio.Multiplier
        end
    end

    State.AspectRatio.TweenFunction = newTweenFunction
    State.AspectRatio.Multiplier = CFrame.new(0, 0, 0, 1, 0, 0, 0, State.AspectRatio.LastTweenValue, 0, 0, 0, 1)

    table.insert(State.AspectRatio, newTweenFunction)

    task.delay(0.16, function()
        for i = 1, #State.AspectRatio do
            if State.AspectRatio[i] == newTweenFunction then
                table.remove(State.AspectRatio, i)
                State.AspectRatio.Multiplier = CFrame.new(0, 0, 0, 1, 0, 0, 0, newValue, 0, 0, 0, 1)
                break
            end
        end
    end)
end

local function DoAspectRatio()
    Camera.CFrame = Camera.CFrame * State.AspectRatio.Multiplier
end

local function StartAspectRatio()
    State.AspectRatio.LastTweenValue = 1
    State.AspectRatio.Multiplier = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    TweenAspectRatio(Options.AspectRatioValue.Value)
    State.AspectRatio.Connection = Services.RunService.RenderStepped:Connect(DoAspectRatio)
end

local function StopAspectRatio()
    if State.AspectRatio.Connection then
        State.AspectRatio.Connection:Disconnect()
        State.AspectRatio.Connection = nil
    end
    TweenAspectRatio(1, true)
end

-- Motion Blur
local function DoMotionBlur(dt)
    if not State.MotionBlur.LastLookVector then
        State.MotionBlur.LastLookVector = Camera.CFrame.LookVector
        return
    end

    local lookVector = Camera.CFrame.LookVector
    local newBlurSize = (lookVector - State.MotionBlur.LastLookVector).Magnitude * State.MotionBlur.Intensity * dt

    State.MotionBlur.SmoothedBlurSize = (State.MotionBlur.SmoothedBlurSize + (newBlurSize - State.MotionBlur.SmoothedBlurSize)) * dt * 900

    if State.Current.MotionBlur then
        State.Current.MotionBlur.Size = math.clamp(State.MotionBlur.SmoothedBlurSize, 0, 56)
    end
    State.MotionBlur.LastLookVector = lookVector
end

local function StartMotionBlur()
    if State.Current.MotionBlur then
        State.Current.MotionBlur:Destroy()
    end
    State.Current.MotionBlur = Instance.new("BlurEffect")
    State.Current.MotionBlur.Name = "MotionBlur"
    State.Current.MotionBlur.Size = 0
    State.Current.MotionBlur.Parent = Services.Lighting
    State.MotionBlur.LastLookVector = nil
    State.MotionBlur.SmoothedBlurSize = 0
    State.MotionBlur.Connection = Services.RunService.RenderStepped:Connect(DoMotionBlur)
end

local function StopMotionBlur()
    if State.MotionBlur.Connection then
        State.MotionBlur.Connection:Disconnect()
        State.MotionBlur.Connection = nil
    end
    if State.Current.MotionBlur then
        State.Current.MotionBlur:Destroy()
        State.Current.MotionBlur = nil
    end
    State.MotionBlur.LastLookVector = nil
end

-- Local Material
local function ApplyLocalMaterial()
    if not LocalPlayer.Character then return end
    if not LocalPlayer:HasAppearanceLoaded() then
        LocalPlayer.CharacterAppearanceLoaded:Wait()
    end

    local character = LocalPlayer.Character
    local material = State.LocalMaterial.MaterialType
    local color = State.LocalMaterial.Color
    local transparency = math.clamp(State.LocalMaterial.Transparency, 0, 0.9999999)

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if part.Parent:IsA("Accessory") then
                -- Accessory
                if part:FindFirstChildOfClass("SpecialMesh") or part:IsA("MeshPart") then
                    part.Material = material
                    part.Color = color
                    part.Transparency = transparency
                    if part:IsA("MeshPart") then
                        part.TextureID = ""
                    end
                end
            else
                -- Body 
                part.Material = material
                part.Color = color
                if part.Transparency ~= 1 then
                    part.Transparency = transparency
                end
            end
        end
    end

    -- Hide 
    local shirt = character:FindFirstChild("Shirt")
    if shirt then
        shirt.ShirtTemplate = ""
    end
    local pants = character:FindFirstChild("Pants")
    if pants then
        pants.PantsTemplate = ""
    end
    local tshirt = character:FindFirstChild("Shirt Graphic")
    if tshirt then
        tshirt.Graphic = ""
    end
end

local function RemoveLocalMaterial()
    Library:Notify("Reset material requires respawn or manual reset", 3)
end

-- Particle Aura 
local function LoadParticleModel(auraType)
    if State.ParticleAura.LoadedModels[auraType] then
        return State.ParticleAura.LoadedModels[auraType]
    end
    local assetId = State.ParticleAura.Types[auraType]
    if not assetId then return nil end
    local success, result = pcall(function()
        local objects = game:GetObjects(assetId)
        if objects and objects[1] then
            return objects[1]
        end
    end)
    if success and result then
        State.ParticleAura.LoadedModels[auraType] = result
        return result
    end
    return nil
end

local function ApplyParticleAura()
    for i = 1, #State.ParticleAura.Particles do
        if State.ParticleAura.Particles[i] then
            State.ParticleAura.Particles[i]:Destroy()
        end
    end
    State.ParticleAura.Particles = {}
    
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local particleModel = LoadParticleModel(State.ParticleAura.CurrentType)
    if not particleModel then
        Library:Notify("Failed to load particle aura!", 3)
        return
    end
    
    local cloned = particleModel:Clone()
    local colorValue = Options.ParticleAuraColor.Value
    local colorSequence = ColorSequence.new(colorValue)
    
    for _, part in pairs(cloned:GetChildren()) do
        if part:IsA("BasePart") then
            local characterPart = LocalPlayer.Character:FindFirstChild(part.Name)
            if characterPart then
                for _, child in pairs(part:GetChildren()) do
                    child.Name = "ParticleAura_" .. child.Name
                    child.Parent = characterPart
                    table.insert(State.ParticleAura.Particles, child)
                    if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                        child.Color = colorSequence
                    elseif child:IsA("PointLight") then
                        child.Color = colorValue
                    end
                    for _, desc in pairs(child:GetDescendants()) do
                        if desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") then
                            desc.Color = colorSequence
                        elseif desc:IsA("PointLight") then
                            desc.Color = colorValue
                        end
                    end
                end
            end
        end
    end
    cloned:Destroy()
end

local function ClearParticleAura()
    for i = 1, #State.ParticleAura.Particles do
        if State.ParticleAura.Particles[i] and State.ParticleAura.Particles[i].Parent then
            State.ParticleAura.Particles[i]:Destroy()
        end
    end
    State.ParticleAura.Particles = {}
end
-- ==================== UI ====================
-- CALL UI elements 

-- WORLD
local WeatherGroup = Tabs.World:AddLeftGroupbox('Weather')

WeatherGroup:AddToggle('WeatherEnabled', {
    Text = 'Enable Weather',
    Default = false,
    Tooltip = 'Add weather particle effects'
})

local WeatherDepbox = WeatherGroup:AddDependencyBox()

WeatherDepbox:AddDropdown('WeatherType', {
    Values = { 'light rain', 'rain', 'snow' },
    Default = 2,
    Multi = false,
    Text = 'Weather Type',
    Tooltip = 'Select weather effect'
})

WeatherDepbox:AddLabel('Weather Color'):AddColorPicker('WeatherColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Weather Color',
    Transparency = 0,
})

WeatherDepbox:AddSlider('WeatherRate', {
    Text = 'Particle Rate',
    Default = 100,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Suffix = '%'
})

WeatherDepbox:SetupDependencies({
    { Toggles.WeatherEnabled, true }
})

-- New Skybox 
local NewSkyboxGroup = Tabs.World:AddRightGroupbox('Skybox Changer (New)')

NewSkyboxGroup:AddToggle('NewSkyboxEnabled', {
    Text = 'Enable New Skybox',
    Default = false,
    Tooltip = 'Change skybox using new system'
})

local NewSkyboxDepbox = NewSkyboxGroup:AddDependencyBox()

NewSkyboxDepbox:AddDropdown('NewSkyboxSelection', {
    Values = { 'black storm', 'blue space', 'realistic', 'stormy', 'pink' },
    Default = 1,
    Multi = false,
    Text = 'Skybox Style',
    Tooltip = 'Select skybox theme'
})

NewSkyboxDepbox:SetupDependencies({
    { Toggles.NewSkyboxEnabled, true }
})

-- Skybox 
local SkyboxGroup = Tabs.World:AddLeftGroupbox('Skybox (Original)')

SkyboxGroup:AddToggle('SkyboxEnabled', {
    Text = 'Enable Skybox Changer',
    Default = false,
    Tooltip = 'Enable custom skybox visuals'
})

SkyboxGroup:AddDropdown('SkyboxDropdown', {
    Values = { 'Default', 'Galaxy', 'Nebula', 'Sunset', 'Midnight', 'Purple Nebula', 'Space', 'Clouds', 'Doom', 'Red Night', 'Anime', 'Morning', 'Rain', 'Snow', 'Storm' },
    Default = 1,
    Multi = false,
    Text = 'Skybox Style',
    Tooltip = 'Select skybox preset'
})

SkyboxGroup:AddToggle('SunTextureEnabled', {
    Text = 'Custom Sun Texture',
    Default = false,
    Tooltip = 'Change sun texture'
})

SkyboxGroup:AddInput('SunTextureID', {
    Default = '',
    Numeric = true,
    Finished = true,
    Text = 'Sun Texture ID',
    Tooltip = 'Enter rbxassetid for sun',
    Placeholder = 'rbxassetid://...'
})

SkyboxGroup:AddToggle('MoonTextureEnabled', {
    Text = 'Custom Moon Texture',
    Default = false,
    Tooltip = 'Change moon texture'
})

SkyboxGroup:AddInput('MoonTextureID', {
    Default = '',
    Numeric = true,
    Finished = true,
    Text = 'Moon Texture ID',
    Tooltip = 'Enter rbxassetid for moon',
    Placeholder = 'rbxassetid://...'
})

SkyboxGroup:AddDropdown('ShaderPreset', {
    Values = { 'Default', 'Morning', 'Midday', 'Afternoon', 'Evening', 'Night', 'Midnight', 'Rain', 'Snow', 'Storm' },
    Default = 1,
    Multi = false,
    Text = 'Shader Preset',
    Tooltip = 'Apply complete lighting preset'
})

local AmbienceGroup = Tabs.World:AddRightGroupbox('Ambience & Lighting')

AmbienceGroup:AddToggle('AmbienceEnabled', {
    Text = 'Custom Ambience',
    Default = false,
    Tooltip = 'Enable custom lighting ambience'
})

AmbienceGroup:AddLabel('Ambient Color'):AddColorPicker('AmbientColor', {
    Default = Color3.fromRGB(70, 70, 90),
    Title = 'Ambient',
    Transparency = 0,
})

AmbienceGroup:AddLabel('Outdoor Color'):AddColorPicker('OutdoorColor', {
    Default = Color3.fromRGB(100, 100, 120),
    Title = 'Outdoor',
    Transparency = 0,
})

AmbienceGroup:AddSlider('Brightness', {
    Text = 'Brightness',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
})

AmbienceGroup:AddSlider('Exposure', {
    Text = 'Exposure Compensation',
    Default = 0,
    Min = -3,
    Max = 3,
    Rounding = 1,
    Compact = false,
})

AmbienceGroup:AddToggle('TimeFreeze', {
    Text = 'Freeze Time',
    Default = false,
    Tooltip = 'Freeze time of day'
})

AmbienceGroup:AddSlider('TimeOfDay', {
    Text = 'Time of Day',
    Default = 12,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Compact = false,
})

AmbienceGroup:AddDropdown('TimePreset', {
    Values = { 'Custom', 'Dawn', 'Noon', 'Sunset', 'Midnight', 'Night' },
    Default = 1,
    Multi = false,
    Text = 'Time Preset',
    Tooltip = 'Quick time presets'
})

local FogGroup = Tabs.World:AddLeftGroupbox('Fog & Decay')

FogGroup:AddToggle('FogEnabled', {
    Text = 'Custom Fog',
    Default = false,
    Tooltip = 'Enable custom fog settings'
})

FogGroup:AddLabel('Fog Color'):AddColorPicker('FogColor', {
    Default = Color3.fromRGB(192, 192, 192),
    Title = 'Fog Color',
    Transparency = 0,
})

FogGroup:AddSlider('FogStart', {
    Text = 'Fog Start',
    Default = 0,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Compact = false,
})

FogGroup:AddSlider('FogEnd', {
    Text = 'Fog End',
    Default = 1000,
    Min = 100,
    Max = 10000,
    Rounding = 0,
    Compact = false,
})

local AtmosphereGroup = Tabs.World:AddRightGroupbox('Atmosphere & Decay')

AtmosphereGroup:AddToggle('AtmosphereEnabled', {
    Text = 'Custom Atmosphere',
    Default = false,
    Tooltip = 'Enable atmosphere decay effects'
})

AtmosphereGroup:AddLabel('Decay Color'):AddColorPicker('DecayColor', {
    Default = Color3.fromRGB(100, 100, 120),
    Title = 'Decay',
    Transparency = 0,
})

AtmosphereGroup:AddLabel('Atmosphere Color'):AddColorPicker('AtmosphereColor', {
    Default = Color3.fromRGB(199, 170, 107),
    Title = 'Atmosphere',
    Transparency = 0,
})

AtmosphereGroup:AddSlider('Density', {
    Text = 'Atmosphere Density',
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

AtmosphereGroup:AddSlider('Offset', {
    Text = 'Decay Offset',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

AtmosphereGroup:AddSlider('Glare', {
    Text = 'Sun Glare',
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Compact = false,
})

AtmosphereGroup:AddSlider('Haze', {
    Text = 'Haze',
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Compact = false,
})

local EffectsGroup = Tabs.World:AddLeftGroupbox('Post Processing')

EffectsGroup:AddToggle('BloomEnabled', {
    Text = 'Enable Bloom',
    Default = false,
    Tooltip = 'Add bloom effect'
})

EffectsGroup:AddSlider('BloomIntensity', {
    Text = 'Bloom Intensity',
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Compact = false,
})

EffectsGroup:AddSlider('BloomSize', {
    Text = 'Bloom Size',
    Default = 24,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

EffectsGroup:AddSlider('BloomThreshold', {
    Text = 'Bloom Threshold',
    Default = 0.8,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

EffectsGroup:AddToggle('BlurEnabled', {
    Text = 'Enable Blur',
    Default = false,
    Tooltip = 'Add blur effect'
})

EffectsGroup:AddSlider('BlurSize', {
    Text = 'Blur Size',
    Default = 5,
    Min = 0,
    Max = 56,
    Rounding = 0,
    Compact = false,
})

EffectsGroup:AddToggle('ColorCorrectionEnabled', {
    Text = 'Color Correction',
    Default = false,
    Tooltip = 'Enable color correction'
})

EffectsGroup:AddSlider('Saturation', {
    Text = 'Saturation',
    Default = 0,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

EffectsGroup:AddSlider('Contrast', {
    Text = 'Contrast',
    Default = 0,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

EffectsGroup:AddSlider('CCBrightness', {
    Text = 'CC Brightness',
    Default = 0,
    Min = -1,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

EffectsGroup:AddSlider('Tint', {
    Text = 'Tint Amount',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

EffectsGroup:AddLabel('Tint Color'):AddColorPicker('TintColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Tint Color',
    Transparency = 0,
})

local SunGroup = Tabs.World:AddRightGroupbox('Sun & Shadow Settings')

SunGroup:AddToggle('SunEnabled', {
    Text = 'Custom Sun Position',
    Default = false,
    Tooltip = 'Enable custom sun settings'
})

SunGroup:AddSlider('GeographicLatitude', {
    Text = 'Sun Latitude',
    Default = 41.733,
    Min = -90,
    Max = 90,
    Rounding = 2,
    Compact = false,
})

SunGroup:AddSlider('SunAzimuth', {
    Text = 'Sun Azimuth',
    Default = 0,
    Min = -180,
    Max = 180,
    Rounding = 0,
    Compact = false,
})

SunGroup:AddToggle('ShadowEnabled', {
    Text = 'Custom Shadows',
    Default = false,
    Tooltip = 'Enable custom shadow settings'
})

SunGroup:AddToggle('GlobalShadows', {
    Text = 'Global Shadows',
    Default = true,
    Tooltip = 'Enable/disable global shadows'
})

SunGroup:AddDropdown('ShadowTechnology', {
    Values = { 'Legacy', 'Voxel', 'ShadowMap', 'Future' },
    Default = 3,
    Multi = false,
    Text = 'Shadow Technology',
    Tooltip = 'Change shadow rendering tech'
})

local EnvironmentGroup = Tabs.World:AddLeftGroupbox('Environment')

EnvironmentGroup:AddToggle('RemoveClouds', {
    Text = 'Remove Clouds',
    Default = false,
    Tooltip = 'Remove all clouds from sky'
})

EnvironmentGroup:AddToggle('SimplifyTerrain', {
    Text = 'Simplify Terrain',
    Default = false,
    Tooltip = 'Remove terrain details for FPS boost'
})

EnvironmentGroup:AddToggle('Fullbright', {
    Text = 'Fullbright',
    Default = false,
    Tooltip = 'Maximum brightness everywhere'
})

EnvironmentGroup:AddToggle('NoFog', {
    Text = 'No Default Fog',
    Default = false,
    Tooltip = 'Remove game default fog'
})

EnvironmentGroup:AddToggle('ReflectanceEnabled', {
    Text = 'Global Reflectance',
    Default = false,
    Tooltip = 'Set reflectance for all parts'
})

EnvironmentGroup:AddSlider('Reflectance', {
    Text = 'Reflectance Value',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

local AdvancedGroup = Tabs.World:AddRightGroupbox('Advanced')

AdvancedGroup:AddDropdown('LightingTech', {
    Values = { 'Legacy', 'Compatibility', 'Voxel', 'ShadowMap', 'Future' },
    Default = 5,
    Multi = false,
    Text = 'Lighting Technology',
    Tooltip = 'Change lighting rendering technology'
})

AdvancedGroup:AddToggle('SunRaysEnabled', {
    Text = 'Sun Rays',
    Default = false,
    Tooltip = 'Enable sun rays effect'
})

AdvancedGroup:AddSlider('SunRaysIntensity', {
    Text = 'Sun Rays Intensity',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

AdvancedGroup:AddSlider('SunRaysSpread', {
    Text = 'Sun Rays Spread',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

AdvancedGroup:AddToggle('DOFEnabled', {
    Text = 'Depth of Field',
    Default = false,
    Tooltip = 'Enable DOF effect'
})

AdvancedGroup:AddSlider('DOFFocus', {
    Text = 'Focus Distance',
    Default = 50,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

AdvancedGroup:AddSlider('DOFInFocus', {
    Text = 'In-Focus Radius',
    Default = 20,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

AdvancedGroup:AddSlider('DOFNearBlur', {
    Text = 'Near Blur',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

AdvancedGroup:AddSlider('DOFFarBlur', {
    Text = 'Far Blur',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

local CloudsGroup = Tabs.World:AddLeftGroupbox('Clouds')

CloudsGroup:AddToggle('CloudsEnabled', {
    Text = 'Custom Clouds',
    Default = false,
    Tooltip = 'Enable custom clouds'
})

CloudsGroup:AddSlider('CloudCover', {
    Text = 'Cloud Cover',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

CloudsGroup:AddSlider('CloudDensity', {
    Text = 'Cloud Density',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

CloudsGroup:AddLabel('Cloud Color'):AddColorPicker('CloudColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Cloud Color',
    Transparency = 0,
})

local WaterGroup = Tabs.World:AddRightGroupbox('Water')

WaterGroup:AddSlider('WaterWaveSpeed', {
    Text = 'Wave Speed',
    Default = 10,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

WaterGroup:AddSlider('WaterWaveSize', {
    Text = 'Wave Size',
    Default = 0.15,
    Min = 0,
    Max = 40,
    Rounding = 2,
    Compact = false,
})

WaterGroup:AddSlider('WaterTransparency', {
    Text = 'Transparency',
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

WaterGroup:AddSlider('WaterReflectance', {
    Text = 'Reflectance',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

-- Reset
SkyboxGroup:AddButton({
    Text = 'Reset All Visuals',
    Func = function()
        Toggles.SkyboxEnabled:SetValue(false)
        Toggles.NewSkyboxEnabled:SetValue(false)
        Toggles.SunTextureEnabled:SetValue(false)
        Toggles.MoonTextureEnabled:SetValue(false)
        Toggles.AmbienceEnabled:SetValue(false)
        Toggles.TimeFreeze:SetValue(false)
        Toggles.FogEnabled:SetValue(false)
        Toggles.AtmosphereEnabled:SetValue(false)
        Toggles.BloomEnabled:SetValue(false)
        Toggles.BlurEnabled:SetValue(false)
        Toggles.ColorCorrectionEnabled:SetValue(false)
        Toggles.SunEnabled:SetValue(false)
        Toggles.ShadowEnabled:SetValue(false)
        Toggles.DOFEnabled:SetValue(false)
        Toggles.SunRaysEnabled:SetValue(false)
        Toggles.CloudsEnabled:SetValue(false)
        Toggles.Fullbright:SetValue(false)
        Toggles.RemoveClouds:SetValue(false)
        Toggles.SimplifyTerrain:SetValue(false)
        Toggles.NoFog:SetValue(false)
        Toggles.ReflectanceEnabled:SetValue(false)
        Toggles.WeatherEnabled:SetValue(false)
        
        RemoveSkybox()
        ResetSkybox()
        ResetAmbience()
        ResetFog()
        RemoveAtmosphere()
        RemoveBloom()
        RemoveBlur()
        RemoveColorCorrection()
        RemoveDOF()
        RemoveSunRays()
        RemoveClouds()
        StopWeather()
        
        Services.Lighting.GeographicLatitude = State.Original.GeographicLatitude
        Services.Lighting.GlobalShadows = State.Original.GlobalShadows
        Services.Lighting.Technology = State.Original.Technology
        Services.Lighting.ExposureCompensation = State.Original.Exposure
        
        Terrain.WaterColor = State.Original.WaterColor
        Terrain.WaterReflectance = State.Original.WaterReflectance
        Terrain.WaterTransparency = State.Original.WaterTransparency
        Terrain.WaterWaveSize = State.Original.WaterWaveSize
        Terrain.WaterWaveSpeed = State.Original.WaterWaveSpeed
        
        if Toggles.SimplifyTerrain.Value then
            SimplifyTerrain()
            Toggles.SimplifyTerrain:SetValue(false)
        end
        
        Library:Notify('All visuals have been reset!', 3)
    end,
    DoubleClick = false,
    Tooltip = 'Reset all visual settings to default'
})
-- ==================== MISC TAB ====================

-- ESP 
local ESPGroup = Tabs.Misc:AddLeftGroupbox('ESP System')

ESPGroup:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Tooltip = 'Toggle ESP system on/off'
})

ESPGroup:AddToggle('ESPBoxEnabled', {
    Text = 'Box ESP',
    Default = true,
    Tooltip = 'Show boxes around players'
})

ESPGroup:AddToggle('ESPTracerEnabled', {
    Text = 'Tracer ESP',
    Default = false,
    Tooltip = 'Show lines to players'
})

ESPGroup:AddToggle('ESPSkeletonEnabled', {
    Text = 'Skeleton ESP',
    Default = false,
    Tooltip = 'Show player skeletons'
})

ESPGroup:AddToggle('ESPShowName', {
    Text = 'Show Names',
    Default = true,
    Tooltip = 'Display player names'
})

ESPGroup:AddToggle('ESPShowDistance', {
    Text = 'Show Distance',
    Default = true,
    Tooltip = 'Display distance to players'
})

ESPGroup:AddToggle('ESPShowHealth', {
    Text = 'Show Health',
    Default = false,
    Tooltip = 'Display player health'
})

ESPGroup:AddLabel('Box Color'):AddColorPicker('ESPBoxColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Box Color',
    Transparency = 0,
})

ESPGroup:AddLabel('Tracer Color'):AddColorPicker('ESPTracerColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Tracer Color',
    Transparency = 0,
})

ESPGroup:AddLabel('Skeleton Color'):AddColorPicker('ESPSkeletonColor', {
    Default = Color3.fromRGB(0, 255, 255),
    Title = 'Skeleton Color',
    Transparency = 0,
})

ESPGroup:AddLabel('Text Color'):AddColorPicker('ESPTextColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Text Color',
    Transparency = 0,
})

-- ESP Settings 
local ESPSettingsGroup = Tabs.Misc:AddRightGroupbox('ESP Settings')

ESPSettingsGroup:AddSlider('ESPMaxDistance', {
    Text = 'Max Distance',
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Compact = false,
})

ESPSettingsGroup:AddSlider('ESPBoxThickness', {
    Text = 'Box Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
})

ESPSettingsGroup:AddSlider('ESPTracerThickness', {
    Text = 'Tracer Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
})

ESPSettingsGroup:AddSlider('ESPSkeletonThickness', {
    Text = 'Skeleton Thickness',
    Default = 1,
    Min = 1,
    Max = 3,
    Rounding = 0,
    Compact = false,
})

ESPSettingsGroup:AddSlider('ESPTextSize', {
    Text = 'Text Size',
    Default = 13,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Compact = false,
})

ESPSettingsGroup:AddDropdown('ESPTracerOrigin', {
    Values = { 'Bottom', 'Top', 'Center', 'Mouse' },
    Default = 1,
    Multi = false,
    Text = 'Tracer Origin',
    Tooltip = 'Where tracers originate from'
})

-- Death Counter 
local DeathCounterGroup = Tabs.Misc:AddLeftGroupbox('Death Counter Detection')

DeathCounterGroup:AddToggle('DeathCounterEnabled', {
    Text = 'Enable Detection',
    Default = false,
    Tooltip = 'Detect when players use Death Counter'
})

DeathCounterGroup:AddToggle('DeathCounterNotify', {
    Text = 'Show Notifications',
    Default = true,
    Tooltip = 'Notify when Death Counter is used'
})

DeathCounterGroup:AddToggle('DeathCounterSound', {
    Text = 'Play Sound',
    Default = true,
    Tooltip = 'Play sound when Death Counter is detected'
})

DeathCounterGroup:AddSlider('DeathCounterVolume', {
    Text = 'Sound Volume',
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

-- Move Detection 
local MoveDetectionGroup = Tabs.Misc:AddRightGroupbox('Move Detection')

MoveDetectionGroup:AddToggle('MoveDetectionEnabled', {
    Text = 'Enable Detection',
    Default = false,
    Tooltip = 'Detect when players use special moves'
})

MoveDetectionGroup:AddToggle('MoveDetectionNotify', {
    Text = 'Show Notifications',
    Default = true,
    Tooltip = 'Notify when moves are detected'
})

MoveDetectionGroup:AddDropdown('MoveDetectionSelection', {
    Values = { 'All Moves', 'Table Flip', 'Omni Directional Punch', 'Serious Punch', 'Consecutive Punches', 'Death Counter' },
    Default = 1,
    Multi = false,
    Text = 'Detect Specific Move',
    Tooltip = 'Select which move to detect (All Moves detects everything)'
})

-- Staff Detection 
local StaffDetectionGroup = Tabs.Misc:AddLeftGroupbox('Staff Detection')

StaffDetectionGroup:AddToggle('StaffDetectionEnabled', {
    Text = 'Enable Staff Detection',
    Default = false,
    Tooltip = 'Detect staff members and special users'
})

StaffDetectionGroup:AddToggle('StaffCheckGroup', {
    Text = 'Check Group',
    Default = true,
    Tooltip = 'Check if player is in staff group'
})

StaffDetectionGroup:AddToggle('StaffCheckIDs', {
    Text = 'Check Special IDs',
    Default = true,
    Tooltip = 'Check for special user IDs'
})

StaffDetectionGroup:AddToggle('StaffCheckFriends', {
    Text = 'Check Friends',
    Default = true,
    Tooltip = 'Check if player is friends with special IDs'
})

StaffDetectionGroup:AddToggle('StaffAnticheat', {
    Text = 'Anticheat Protection',
    Default = true,
    Tooltip = 'Detect anticheat flags'
})

StaffDetectionGroup:AddDropdown('StaffAvoidAction', {
    Values = { 'None', 'AutoLeave', 'AutoRejoin' },
    Default = 3,
    Multi = false,
    Text = 'Avoid Action',
    Tooltip = 'Action to take when staff detected'
})

-- Background Noise
local BackgroundNoiseGroup = Tabs.Misc:AddRightGroupbox('Background Noise')

BackgroundNoiseGroup:AddToggle('BackgroundNoiseEnabled', {
    Text = 'Enable Background Noise',
    Default = false,
    Tooltip = 'Play ambient background sounds'
})

local BackgroundNoiseDepbox = BackgroundNoiseGroup:AddDependencyBox()

BackgroundNoiseDepbox:AddDropdown('BackgroundNoiseSound', {
    Values = { 'windy winter', 'light rain', 'thunderstorm', 'night', 'day' },
    Default = 4,
    Multi = false,
    Text = 'Sound Type',
    Tooltip = 'Select ambient sound'
})

BackgroundNoiseDepbox:AddSlider('BackgroundNoiseVolume', {
    Text = 'Volume',
    Default = 25,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Suffix = '%'
})

BackgroundNoiseDepbox:SetupDependencies({
    { Toggles.BackgroundNoiseEnabled, true }
})

-- Aspect Ratio 
local AspectRatioGroup = Tabs.Misc:AddLeftGroupbox('Aspect Ratio')

AspectRatioGroup:AddToggle('AspectRatioEnabled', {
    Text = 'Enable Aspect Ratio',
    Default = false,
    Tooltip = 'Modify camera FOV/aspect ratio'
})

local AspectRatioDepbox = AspectRatioGroup:AddDependencyBox()

AspectRatioDepbox:AddSlider('AspectRatioValue', {
    Text = 'Aspect Ratio',
    Default = 1,
    Min = 0.5,
    Max = 2,
    Rounding = 2,
    Compact = false,
})

AspectRatioDepbox:SetupDependencies({
    { Toggles.AspectRatioEnabled, true }
})

-- Motion Blur 
local MotionBlurGroup = Tabs.Misc:AddRightGroupbox('Motion Blur')

MotionBlurGroup:AddToggle('MotionBlurEnabled', {
    Text = 'Enable Motion Blur',
    Default = false,
    Tooltip = 'Camera movement based blur effect'
})

local MotionBlurDepbox = MotionBlurGroup:AddDependencyBox()

MotionBlurDepbox:AddSlider('MotionBlurIntensity', {
    Text = 'Intensity',
    Default = 25,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Suffix = '%'
})

MotionBlurDepbox:SetupDependencies({
    { Toggles.MotionBlurEnabled, true }
})

-- Character Highlight 
local CharacterHighlightGroup = Tabs.Misc:AddLeftGroupbox('Character Highlight')

CharacterHighlightGroup:AddToggle('CharacterHighlightEnabled', {
    Text = 'Enable Highlight',
    Default = false,
    Tooltip = 'Add a glow effect to your character'
})

local HighlightDepbox = CharacterHighlightGroup:AddDependencyBox()

HighlightDepbox:AddLabel('Fill Color'):AddColorPicker('CharacterHighlightFillColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Fill Color',
    Transparency = 0.1,
})

HighlightDepbox:AddSlider('CharacterHighlightFillTransparency', {
    Text = 'Fill Transparency',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

HighlightDepbox:AddLabel('Outline Color'):AddColorPicker('CharacterHighlightOutlineColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'Outline Color',
    Transparency = 0.1,
})

HighlightDepbox:AddSlider('CharacterHighlightOutlineTransparency', {
    Text = 'Outline Transparency',
    Default = 0.1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})

HighlightDepbox:AddDropdown('CharacterHighlightDepthMode', {
    Values = { 'AlwaysOnTop', 'Occluded' },
    Default = 1,
    Multi = false,
    Text = 'Depth Mode',
    Tooltip = 'AlwaysOnTop = visible through walls, Occluded = hidden behind walls'
})

HighlightDepbox:SetupDependencies({
    { Toggles.CharacterHighlightEnabled, true }
})

-- Local Material 
local LocalMaterialGroup = Tabs.Misc:AddRightGroupbox('Local Material')

LocalMaterialGroup:AddToggle('LocalMaterialEnabled', {
    Text = 'Enable Material',
    Default = false,
    Tooltip = 'Change local character material'
})

local LocalMaterialDepbox = LocalMaterialGroup:AddDependencyBox()

LocalMaterialDepbox:AddDropdown('LocalMaterialType', {
    Values = { 'forcefield', 'neon' },
    Default = 2,
    Multi = false,
    Text = 'Material Type',
    Tooltip = 'Select material type'
})

LocalMaterialDepbox:AddLabel('Material Color'):AddColorPicker('LocalMaterialColor', {
    Default = Color3.fromRGB(249, 217, 255),
    Title = 'Material Color',
    Transparency = 0.2,
})

LocalMaterialDepbox:AddSlider('LocalMaterialTransparency', {
    Text = 'Transparency',
    Default = 0.2,
    Min = 0,
    Max = 0.99,
    Rounding = 2,
    Compact = false,
})

LocalMaterialDepbox:SetupDependencies({
    { Toggles.LocalMaterialEnabled, true }
})

-- Particle Aura 
local ParticleAuraGroup = Tabs.Misc:AddLeftGroupbox('Particle Aura')

ParticleAuraGroup:AddToggle('ParticleAuraEnabled', {
    Text = 'Enable Particle Aura',
    Default = false,
    Tooltip = 'Add particle effects to your character'
})

local ParticleDepbox = ParticleAuraGroup:AddDependencyBox()

ParticleDepbox:AddLabel('Aura Color'):AddColorPicker('ParticleAuraColor', {
    Default = Color3.fromRGB(133, 220, 255),
    Title = 'Aura Color',
    Transparency = 0.2,
})

ParticleDepbox:AddDropdown('ParticleAuraType', {
    Values = { 'starlight', 'heavenly', 'ribbon', 'sakura', 'angel', 'wind', 'flow', 'star' },
    Default = 5,
    Multi = false,
    Text = 'Particle Type',
    Tooltip = 'Select particle effect style'
})

ParticleDepbox:SetupDependencies({
    { Toggles.ParticleAuraEnabled, true }
})
-- ==================== CONNECTIONS ====================

-- ESP
Toggles.ESPEnabled:OnChanged(function()
    State.ESP.Enabled = Toggles.ESPEnabled.Value
    if State.ESP.Enabled then
        StartESP()
        Library:Notify('ESP Enabled!', 2)
    else
        StopESP()
        Library:Notify('ESP Disabled!', 2)
    end
end)

Toggles.ESPBoxEnabled:OnChanged(function()
    State.ESP.BoxEnabled = Toggles.ESPBoxEnabled.Value
end)

Toggles.ESPTracerEnabled:OnChanged(function()
    State.ESP.TracerEnabled = Toggles.ESPTracerEnabled.Value
end)

Toggles.ESPSkeletonEnabled:OnChanged(function()
    State.ESP.SkeletonEnabled = Toggles.ESPSkeletonEnabled.Value
end)

Toggles.ESPShowName:OnChanged(function()
    State.ESP.ShowName = Toggles.ESPShowName.Value
end)

Toggles.ESPShowDistance:OnChanged(function()
    State.ESP.ShowDistance = Toggles.ESPShowDistance.Value
end)

Toggles.ESPShowHealth:OnChanged(function()
    State.ESP.ShowHealth = Toggles.ESPShowHealth.Value
end)

Options.ESPBoxColor:OnChanged(function()
    State.ESP.BoxColor = Options.ESPBoxColor.Value
end)

Options.ESPTracerColor:OnChanged(function()
    State.ESP.TracerColor = Options.ESPTracerColor.Value
end)

Options.ESPSkeletonColor:OnChanged(function()
    State.ESP.SkeletonColor = Options.ESPSkeletonColor.Value
end)

Options.ESPTextColor:OnChanged(function()
    State.ESP.TextColor = Options.ESPTextColor.Value
end)

Options.ESPMaxDistance:OnChanged(function()
    State.ESP.MaxDistance = Options.ESPMaxDistance.Value
end)

Options.ESPBoxThickness:OnChanged(function()
    State.ESP.BoxThickness = Options.ESPBoxThickness.Value
end)

Options.ESPTracerThickness:OnChanged(function()
    State.ESP.TracerThickness = Options.ESPTracerThickness.Value
end)

Options.ESPSkeletonThickness:OnChanged(function()
    State.ESP.SkeletonThickness = Options.ESPSkeletonThickness.Value
end)

Options.ESPTextSize:OnChanged(function()
    State.ESP.TextSize = Options.ESPTextSize.Value
end)

-- Death Counter
Toggles.DeathCounterEnabled:OnChanged(function()
    State.DeathCounter.Enabled = Toggles.DeathCounterEnabled.Value
    if State.DeathCounter.Enabled then
        StartDeathCounterDetection()
        Library:Notify('Death Counter Detection Enabled!', 2)
    else
        StopDeathCounterDetection()
        Library:Notify('Death Counter Detection Disabled!', 2)
    end
end)

Toggles.DeathCounterNotify:OnChanged(function()
    State.DeathCounter.NotifyEnabled = Toggles.DeathCounterNotify.Value
end)

Toggles.DeathCounterSound:OnChanged(function()
    State.DeathCounter.SoundEnabled = Toggles.DeathCounterSound.Value
end)

Options.DeathCounterVolume:OnChanged(function()
    State.DeathCounter.Volume = Options.DeathCounterVolume.Value
end)

--Detection
Toggles.MoveDetectionEnabled:OnChanged(function()
    State.MoveDetection.Enabled = Toggles.MoveDetectionEnabled.Value
    if State.MoveDetection.Enabled then
        StartMoveDetection()
        Library:Notify('Move Detection Enabled!', 2)
    else
        StopMoveDetection()
        Library:Notify('Move Detection Disabled!', 2)
    end
end)

Toggles.MoveDetectionNotify:OnChanged(function()
    State.MoveDetection.NotifyEnabled = Toggles.MoveDetectionNotify.Value
end)

Options.MoveDetectionSelection:OnChanged(function()
    State.MoveDetection.Selection = Options.MoveDetectionSelection.Value
end)

-- Staff
Toggles.StaffDetectionEnabled:OnChanged(function()
    State.StaffDetection.Enabled = Toggles.StaffDetectionEnabled.Value
    if State.StaffDetection.Enabled then
        StartStaffDetection()
        Library:Notify('Staff Detection Enabled!', 2)
    end
end)

Toggles.StaffCheckGroup:OnChanged(function()
    State.StaffDetection.CheckGroup = Toggles.StaffCheckGroup.Value
end)

Toggles.StaffCheckIDs:OnChanged(function()
    State.StaffDetection.CheckIDs = Toggles.StaffCheckIDs.Value
end)

Toggles.StaffCheckFriends:OnChanged(function()
    State.StaffDetection.CheckFriends = Toggles.StaffCheckFriends.Value
end)

Toggles.StaffAnticheat:OnChanged(function()
    State.StaffDetection.Anticheat = Toggles.StaffAnticheat.Value
end)

Options.StaffAvoidAction:OnChanged(function()
    State.StaffDetection.Avoid = Options.StaffAvoidAction.Value
end)

-- Background
Toggles.BackgroundNoiseEnabled:OnChanged(function()
    if Toggles.BackgroundNoiseEnabled.Value then
        StartBackgroundNoise()
        Library:Notify('Background Noise Enabled!', 2)
    else
        StopBackgroundNoise()
        Library:Notify('Background Noise Disabled!', 2)
    end
end)

Options.BackgroundNoiseSound:OnChanged(function()
    if Toggles.BackgroundNoiseEnabled.Value then
        StopBackgroundNoise()
        task.wait(0.1)
        StartBackgroundNoise()
    end
end)

Options.BackgroundNoiseVolume:OnChanged(function()
    if State.Current.BackgroundSound then
        State.Current.BackgroundSound.Volume = Options.BackgroundNoiseVolume.Value / 65
    end
end)

-- Aspect
Toggles.AspectRatioEnabled:OnChanged(function()
    if Toggles.AspectRatioEnabled.Value then
        StartAspectRatio()
        Library:Notify('Aspect Ratio Enabled!', 2)
    else
        StopAspectRatio()
        Library:Notify('Aspect Ratio Disabled!', 2)
    end
end)

Options.AspectRatioValue:OnChanged(function()
    if Toggles.AspectRatioEnabled.Value then
        TweenAspectRatio(Options.AspectRatioValue.Value)
    end
end)

-- Motion Blur
Toggles.MotionBlurEnabled:OnChanged(function()
    if Toggles.MotionBlurEnabled.Value then
        StartMotionBlur()
        Library:Notify('Motion Blur Enabled!', 2)
    else
        StopMotionBlur()
        Library:Notify('Motion Blur Disabled!', 2)
    end
end)

Options.MotionBlurIntensity:OnChanged(function()
    State.MotionBlur.Intensity = Options.MotionBlurIntensity.Value * 110
end)

-- Highlight 
local CharacterHighlightInstance = nil
local CharacterHighlightConnection = nil

local function ApplyCharacterHighlight()
    if not CharacterHighlightInstance or not LocalPlayer.Character then return end
    CharacterHighlightInstance.FillColor = Options.CharacterHighlightFillColor.Value
    CharacterHighlightInstance.FillTransparency = Options.CharacterHighlightFillTransparency.Value
    CharacterHighlightInstance.OutlineColor = Options.CharacterHighlightOutlineColor.Value
    CharacterHighlightInstance.OutlineTransparency = Options.CharacterHighlightOutlineTransparency.Value
    local depthMode = Options.CharacterHighlightDepthMode.Value
    if depthMode == "AlwaysOnTop" then
        CharacterHighlightInstance.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        CharacterHighlightInstance.DepthMode = Enum.HighlightDepthMode.Occluded
    end
    CharacterHighlightInstance.Adornee = LocalPlayer.Character
    CharacterHighlightInstance.Parent = game:GetService("CoreGui")
end

local function CreateCharacterHighlight()
    if CharacterHighlightInstance then
        CharacterHighlightInstance:Destroy()
        CharacterHighlightInstance = nil
    end
    CharacterHighlightInstance = Instance.new("Highlight")
    CharacterHighlightInstance.Name = "MiscVisuals_Highlight"
    CharacterHighlightInstance.Enabled = true
    ApplyCharacterHighlight()
end

local function RemoveCharacterHighlight()
    if CharacterHighlightInstance then
        CharacterHighlightInstance:Destroy()
        CharacterHighlightInstance = nil
    end
    if CharacterHighlightConnection then
        CharacterHighlightConnection:Disconnect()
        CharacterHighlightConnection = nil
    end
end

Toggles.CharacterHighlightEnabled:OnChanged(function()
    if Toggles.CharacterHighlightEnabled.Value then
        CreateCharacterHighlight()
        if CharacterHighlightConnection then
            CharacterHighlightConnection:Disconnect()
        end
        CharacterHighlightConnection = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.1)
            ApplyCharacterHighlight()
        end)
        Library:Notify('Character Highlight Enabled!', 2)
    else
        RemoveCharacterHighlight()
        Library:Notify('Character Highlight Disabled!', 2)
    end
end)

Options.CharacterHighlightFillColor:OnChanged(function()
    if CharacterHighlightInstance then
        CharacterHighlightInstance.FillColor = Options.CharacterHighlightFillColor.Value
    end
end)

Options.CharacterHighlightFillTransparency:OnChanged(function()
    if CharacterHighlightInstance then
        CharacterHighlightInstance.FillTransparency = Options.CharacterHighlightFillTransparency.Value
    end
end)

Options.CharacterHighlightOutlineColor:OnChanged(function()
    if CharacterHighlightInstance then
        CharacterHighlightInstance.OutlineColor = Options.CharacterHighlightOutlineColor.Value
    end
end)

Options.CharacterHighlightOutlineTransparency:OnChanged(function()
    if CharacterHighlightInstance then
        CharacterHighlightInstance.OutlineTransparency = Options.CharacterHighlightOutlineTransparency.Value
    end
end)

Options.CharacterHighlightDepthMode:OnChanged(function()
    if CharacterHighlightInstance then
        local depthMode = Options.CharacterHighlightDepthMode.Value
        if depthMode == "AlwaysOnTop" then
            CharacterHighlightInstance.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        else
            CharacterHighlightInstance.DepthMode = Enum.HighlightDepthMode.Occluded
        end
    end
end)

-- Material 
Toggles.LocalMaterialEnabled:OnChanged(function()
    State.LocalMaterial.Active = Toggles.LocalMaterialEnabled.Value
    if State.LocalMaterial.Active then
        ApplyLocalMaterial()
        State.LocalMaterial.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.2)
            ApplyLocalMaterial()
        end)
        Library:Notify('Local Material Enabled!', 2)
    else
        if State.LocalMaterial.CharacterAddedConnection then
            State.LocalMaterial.CharacterAddedConnection:Disconnect()
            State.LocalMaterial.CharacterAddedConnection = nil
        end
        RemoveLocalMaterial()
        Library:Notify('Local Material Disabled!', 2)
    end
end)

Options.LocalMaterialType:OnChanged(function()
    State.LocalMaterial.MaterialType = Options.LocalMaterialType.Value == "neon" and Enum.Material.Neon or Enum.Material.ForceField
    if State.LocalMaterial.Active then
        ApplyLocalMaterial()
    end
end)

Options.LocalMaterialColor:OnChanged(function()
    State.LocalMaterial.Color = Options.LocalMaterialColor.Value
    if State.LocalMaterial.Active then
        ApplyLocalMaterial()
    end
end)

Options.LocalMaterialTransparency:OnChanged(function()
    State.LocalMaterial.Transparency = Options.LocalMaterialTransparency.Value
    if State.LocalMaterial.Active then
        ApplyLocalMaterial()
    end
end)

-- Particle aura 
Toggles.ParticleAuraEnabled:OnChanged(function()
    if Toggles.ParticleAuraEnabled.Value then
        ApplyParticleAura()
        State.ParticleAura.Connection = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.2)
            ApplyParticleAura()
        end)
        Library:Notify('Particle Aura Enabled!', 2)
    else
        ClearParticleAura()
        if State.ParticleAura.Connection then
            State.ParticleAura.Connection:Disconnect()
            State.ParticleAura.Connection = nil
        end
        Library:Notify('Particle Aura Disabled!', 2)
    end
end)

Options.ParticleAuraType:OnChanged(function()
    State.ParticleAura.CurrentType = Options.ParticleAuraType.Value
    if Toggles.ParticleAuraEnabled.Value then
        ApplyParticleAura()
    end
end)

Options.ParticleAuraColor:OnChanged(function()
    local colorValue = Options.ParticleAuraColor.Value
    local colorSequence = ColorSequence.new(colorValue)
    for _, particle in pairs(State.ParticleAura.Particles) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Beam") or particle:IsA("Trail") then
            particle.Color = colorSequence
        elseif particle:IsA("PointLight") then
            particle.Color = colorValue
        end
        for _, desc in pairs(particle:GetDescendants()) do
            if desc:IsA("ParticleEmitter") or desc:IsA("Beam") or desc:IsA("Trail") then
                desc.Color = colorSequence
            elseif desc:IsA("PointLight") then
                desc.Color = colorValue
            end
        end
    end
end)

-- Weather
Toggles.WeatherEnabled:OnChanged(function()
    if Toggles.WeatherEnabled.Value then
        StartWeather()
        Library:Notify('Weather Enabled!', 2)
    else
        StopWeather()
        Library:Notify('Weather Disabled!', 2)
    end
end)

Options.WeatherType:OnChanged(function()
    if Toggles.WeatherEnabled.Value then
        StopWeather()
        task.wait(0.1)
        StartWeather()
    end
end)

Options.WeatherColor:OnChanged(function()
    if State.Current.WeatherParticle then
        State.Current.WeatherParticle.Color = ColorSequence.new(Options.WeatherColor.Value)
    end
end)

Options.WeatherRate:OnChanged(function()
    if State.Current.WeatherParticle then
        local weatherType = Options.WeatherType.Value
        local baseRate = WeatherTypes[weatherType].Rate
        State.Current.WeatherParticle.Rate = baseRate * (Options.WeatherRate.Value / 100)
    end
end)

-- Skybox v2
Toggles.NewSkyboxEnabled:OnChanged(function()
    if Toggles.NewSkyboxEnabled.Value then
        local selected = Options.NewSkyboxSelection.Value
        ApplyNewSkybox(selected)
        Library:Notify('New Skybox Enabled!', 2)
    else
        ResetSkybox()
        Library:Notify('New Skybox Disabled!', 2)
    end
end)

Options.NewSkyboxSelection:OnChanged(function()
    if Toggles.NewSkyboxEnabled.Value then
        ApplyNewSkybox(Options.NewSkyboxSelection.Value)
    end
end)

-- World
Toggles.SkyboxEnabled:OnChanged(function()
    if Toggles.SkyboxEnabled.Value then
        local selected = Options.SkyboxDropdown.Value
        if selected ~= "Default" and Skyboxes[selected] then
            ApplySkybox(Skyboxes[selected])
        end
    else
        RemoveSkybox()
    end
end)

Toggles.AmbienceEnabled:OnChanged(function()
    if Toggles.AmbienceEnabled.Value then
        ApplyAmbience()
    else
        ResetAmbience()
    end
end)

Toggles.TimeFreeze:OnChanged(function()
    if Toggles.TimeFreeze.Value then
        State.TimeConnection = Services.RunService.Heartbeat:Connect(function()
            Services.Lighting.ClockTime = Options.TimeOfDay.Value
        end)
    else
        if State.TimeConnection then
            State.TimeConnection:Disconnect()
            State.TimeConnection = nil
        end
    end
end)

Toggles.FogEnabled:OnChanged(function()
    if Toggles.FogEnabled.Value then
        ApplyFog()
    else
        ResetFog()
    end
end)

Toggles.AtmosphereEnabled:OnChanged(function()
    if Toggles.AtmosphereEnabled.Value then
        ApplyAtmosphere()
    else
        RemoveAtmosphere()
    end
end)

Toggles.BloomEnabled:OnChanged(function()
    if Toggles.BloomEnabled.Value then
        ApplyBloom()
    else
        RemoveBloom()
    end
end)

Toggles.BlurEnabled:OnChanged(function()
    if Toggles.BlurEnabled.Value then
        ApplyBlur()
    else
        RemoveBlur()
    end
end)

Toggles.ColorCorrectionEnabled:OnChanged(function()
    if Toggles.ColorCorrectionEnabled.Value then
        ApplyColorCorrection()
    else
        RemoveColorCorrection()
    end
end)

Toggles.DOFEnabled:OnChanged(function()
    if Toggles.DOFEnabled.Value then
        ApplyDOF()
    else
        RemoveDOF()
    end
end)

Toggles.SunRaysEnabled:OnChanged(function()
    if Toggles.SunRaysEnabled.Value then
        ApplySunRays()
    else
        RemoveSunRays()
    end
end)

Toggles.CloudsEnabled:OnChanged(function()
    if Toggles.CloudsEnabled.Value then
        ApplyClouds()
    else
        RemoveClouds()
    end
end)

Toggles.Fullbright:OnChanged(function()
    ApplyFullbright()
end)

Toggles.SimplifyTerrain:OnChanged(function()
    SimplifyTerrain()
end)

Toggles.NoFog:OnChanged(function()
    if Toggles.NoFog.Value then
        Services.Lighting.FogStart = 0
        Services.Lighting.FogEnd = 999999
    else
        if Toggles.FogEnabled.Value then
            ApplyFog()
        else
            ResetFog()
        end
    end
end)

Toggles.ReflectanceEnabled:OnChanged(function()
    ApplyReflectance()
end)

Options.SkyboxDropdown:OnChanged(function()
    if Toggles.SkyboxEnabled.Value then
        local selected = Options.SkyboxDropdown.Value
        if selected ~= "Default" and Skyboxes[selected] then
            ApplySkybox(Skyboxes[selected])
        else
            RemoveSkybox()
        end
    end
end)

Options.ShaderPreset:OnChanged(function()
    local preset = Options.ShaderPreset.Value
    if ShaderPresets[preset] then
        ApplyShaderPreset(ShaderPresets[preset])
        Library:Notify('Applied ' .. preset .. ' shader preset!', 3)
    else
        ResetShader()
    end
end)

Options.TimePreset:OnChanged(function()
    local preset = Options.TimePreset.Value
    if preset == "Dawn" then
        Options.TimeOfDay:SetValue(6)
    elseif preset == "Noon" then
        Options.TimeOfDay:SetValue(12)
    elseif preset == "Sunset" then
        Options.TimeOfDay:SetValue(18)
    elseif preset == "Midnight" then
        Options.TimeOfDay:SetValue(0)
    elseif preset == "Night" then
        Options.TimeOfDay:SetValue(21)
    end
    if Toggles.AmbienceEnabled.Value then
        ApplyAmbience()
    end
end)

Options.AmbientColor:OnChanged(function()
    if Toggles.AmbienceEnabled.Value then
        Services.Lighting.Ambient = Options.AmbientColor.Value
    end
end)

Options.OutdoorColor:OnChanged(function()
    if Toggles.AmbienceEnabled.Value then
        Services.Lighting.OutdoorAmbient = Options.OutdoorColor.Value
    end
end)

Options.Brightness:OnChanged(function()
    if Toggles.AmbienceEnabled.Value then
        Services.Lighting.Brightness = Options.Brightness.Value
    end
end)

Options.Exposure:OnChanged(function()
    if Toggles.AmbienceEnabled.Value then
        Services.Lighting.ExposureCompensation = Options.Exposure.Value
    end
end)

Options.TimeOfDay:OnChanged(function()
    if Toggles.AmbienceEnabled.Value and not Toggles.TimeFreeze.Value then
        Services.Lighting.ClockTime = Options.TimeOfDay.Value
    end
end)

Options.FogColor:OnChanged(function()
    if Toggles.FogEnabled.Value then
        Services.Lighting.FogColor = Options.FogColor.Value
    end
end)

Options.FogStart:OnChanged(function()
    if Toggles.FogEnabled.Value then
        Services.Lighting.FogStart = Options.FogStart.Value
    end
end)

Options.FogEnd:OnChanged(function()
    if Toggles.FogEnabled.Value then
        Services.Lighting.FogEnd = Options.FogEnd.Value
    end
end)

Options.Density:OnChanged(function()
    if State.Current.Atmosphere then
        State.Current.Atmosphere.Density = Options.Density.Value
    end
end)

Options.Offset:OnChanged(function()
    if State.Current.Atmosphere then
        State.Current.Atmosphere.Offset = Options.Offset.Value
    end
end)

Options.DecayColor:OnChanged(function()
    if State.Current.Atmosphere then
        State.Current.Atmosphere.Decay = Options.DecayColor.Value
    end
end)

Options.AtmosphereColor:OnChanged(function()
    if State.Current.Atmosphere then
        State.Current.Atmosphere.Color = Options.AtmosphereColor.Value
    end
end)

Options.Glare:OnChanged(function()
    if State.Current.Atmosphere then
        State.Current.Atmosphere.Glare = Options.Glare.Value
    end
end)

Options.Haze:OnChanged(function()
    if State.Current.Atmosphere then
        State.Current.Atmosphere.Haze = Options.Haze.Value
    end
end)

Options.BloomIntensity:OnChanged(function()
    if State.Current.Bloom then
        State.Current.Bloom.Intensity = Options.BloomIntensity.Value
    end
end)

Options.BloomSize:OnChanged(function()
    if State.Current.Bloom then
        State.Current.Bloom.Size = Options.BloomSize.Value
    end
end)

Options.BloomThreshold:OnChanged(function()
    if State.Current.Bloom then
        State.Current.Bloom.Threshold = Options.BloomThreshold.Value
    end
end)

Options.BlurSize:OnChanged(function()
    if State.Current.Blur then
        State.Current.Blur.Size = Options.BlurSize.Value
    end
end)

Options.Saturation:OnChanged(function()
    if State.Current.ColorCorrection then
        State.Current.ColorCorrection.Saturation = Options.Saturation.Value
    end
end)

Options.Contrast:OnChanged(function()
    if State.Current.ColorCorrection then
        State.Current.ColorCorrection.Contrast = Options.Contrast.Value
    end
end)

Options.CCBrightness:OnChanged(function()
    if State.Current.ColorCorrection then
        State.Current.ColorCorrection.Brightness = Options.CCBrightness.Value
    end
end)

Options.TintColor:OnChanged(function()
    if State.Current.ColorCorrection then
        State.Current.ColorCorrection.TintColor = Options.TintColor.Value
    end
end)

Options.Tint:OnChanged(function()
    if State.Current.ColorCorrection then
        local tint = Options.Tint.Value
        local color = Options.TintColor.Value
        State.Current.ColorCorrection.TintColor = Color3.new(
            1 - (1 - color.R) * tint,
            1 - (1 - color.G) * tint,
            1 - (1 - color.B) * tint
        )
    end
end)

Options.GeographicLatitude:OnChanged(function()
    if Toggles.SunEnabled.Value then
        Services.Lighting.GeographicLatitude = Options.GeographicLatitude.Value
    end
end)

Options.ShadowTechnology:OnChanged(function()
    if Toggles.ShadowEnabled.Value then
        local tech = Options.ShadowTechnology.Value
        if tech == "Legacy" then
            Services.Lighting.Technology = Enum.Technology.Legacy
        elseif tech == "Voxel" then
            Services.Lighting.Technology = Enum.Technology.Voxel
        elseif tech == "ShadowMap" then
            Services.Lighting.Technology = Enum.Technology.ShadowMap
        elseif tech == "Future" then
            Services.Lighting.Technology = Enum.Technology.Future
        end
    end
end)

Options.LightingTech:OnChanged(function()
    local tech = Options.LightingTech.Value
    if tech == "Legacy" then
        Services.Lighting.Technology = Enum.Technology.Legacy
    elseif tech == "Compatibility" then
        Services.Lighting.Technology = Enum.Technology.Compatibility
    elseif tech == "Voxel" then
        Services.Lighting.Technology = Enum.Technology.Voxel
    elseif tech == "ShadowMap" then
        Services.Lighting.Technology = Enum.Technology.ShadowMap
    elseif tech == "Future" then
        Services.Lighting.Technology = Enum.Technology.Future
    end
end)

Options.DOFFocus:OnChanged(function()
    if State.Current.DOF then
        State.Current.DOF.FocusDistance = Options.DOFFocus.Value
    end
end)

Options.DOFInFocus:OnChanged(function()
    if State.Current.DOF then
        State.Current.DOF.InFocusRadius = Options.DOFInFocus.Value
    end
end)

Options.DOFNearBlur:OnChanged(function()
    if State.Current.DOF then
        State.Current.DOF.NearIntensity = Options.DOFNearBlur.Value
    end
end)

Options.DOFFarBlur:OnChanged(function()
    if State.Current.DOF then
        State.Current.DOF.FarIntensity = Options.DOFFarBlur.Value
    end
end)

Options.SunRaysIntensity:OnChanged(function()
    if State.Current.SunRays then
        State.Current.SunRays.Intensity = Options.SunRaysIntensity.Value
    end
end)

Options.SunRaysSpread:OnChanged(function()
    if State.Current.SunRays then
        State.Current.SunRays.Spread = Options.SunRaysSpread.Value
    end
end)

Options.CloudCover:OnChanged(function()
    if State.Current.Clouds then
        State.Current.Clouds.Cover = Options.CloudCover.Value
    end
end)

Options.CloudDensity:OnChanged(function()
    if State.Current.Clouds then
        State.Current.Clouds.Density = Options.CloudDensity.Value
    end
end)

Options.CloudColor:OnChanged(function()
    if State.Current.Clouds then
        State.Current.Clouds.Color = Options.CloudColor.Value
    end
end)

Options.WaterWaveSpeed:OnChanged(function()
    Terrain.WaterWaveSpeed = Options.WaterWaveSpeed.Value
end)

Options.WaterWaveSize:OnChanged(function()
    Terrain.WaterWaveSize = Options.WaterWaveSize.Value
end)

Options.WaterTransparency:OnChanged(function()
    Terrain.WaterTransparency = Options.WaterTransparency.Value
end)

Options.WaterReflectance:OnChanged(function()
    Terrain.WaterReflectance = Options.WaterReflectance.Value
end)

Options.Reflectance:OnChanged(function()
    if Toggles.ReflectanceEnabled.Value then
        ApplyReflectance()
    end
end)
-- ==================== ui ====================

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('Epstein | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    if State.TimeConnection then
        State.TimeConnection:Disconnect()
    end
    
    -- cleaner
    StopESP()
    
    -- cleaner
    StopDeathCounterDetection()
    
    -- cleaner
    StopMoveDetection()
    
    -- cleaner
    RemoveCharacterHighlight()
    
    -- cleaner
    ClearParticleAura()
    if State.ParticleAura.Connection then
        State.ParticleAura.Connection:Disconnect()
    end
    
    -- cleaner
    StopWeather()
    
    -- cleaner
    StopBackgroundNoise()
    
    -- cleaner
    StopAspectRatio()
    
    -- cleaner
    StopMotionBlur()
    
    -- cleaner
    if State.LocalMaterial.CharacterAddedConnection then
        State.LocalMaterial.CharacterAddedConnection:Disconnect()
    end
    
    print('Epstein Unloaded!')
    Library.Unloaded = true
end)

-- menu
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton({
    Text = 'Unload',
    Func = function()
        Library:Unload()
    end,
    DoubleClick = true,
    Tooltip = 'Double click to unload script'
})

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { 
    Default = 'End', 
    NoUI = true, 
    Text = 'Menu keybind' 
})

Library.ToggleKeybind = Options.MenuKeybind

-- Theme & Save Manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('EpsteinScript')
SaveManager:SetFolder('EpsteinScript')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Library:Notify('Epstein loaded successfully!', 5)
Library:Notify('Press End to toggle menu', 5)
Library:Notify('Check Misc tab for', 5)
