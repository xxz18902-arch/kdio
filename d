local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    ImageUrl = "https://www.reuters.com/resizer/v2/https%3A%2F%2Farchive-images.prod.global.a201836.reutersmedia.net%2F2019%2F07%2F26%2F2019-07-26T111512Z_33918_MRPRC15C07E7560_RTRMADP_0_PEOPLE-JEFFREY-EPSTEIN.JPG?auth=c723fe00aa6b517c2acda19e8e85fa3b665eb19ad4717f17308c0a5199762cf8&width=1200&quality=80",
    FileName = "el_matador_bg.png",
    IntroDuration = 8,
    FadeInDuration = 0.8,
    FadeOutDuration = 0.8,
    PrimaryColor = Color3.fromRGB(154, 213, 222),
    SecondaryColor = Color3.fromRGB(255, 50, 100),
    AccentColor = Color3.fromRGB(255, 215, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    GlitchColor = Color3.fromRGB(255, 0, 85),
    TitleText = "El Matador",
    SubtitleText = "The Pedo.",
    LoadingText = "INITIALIZING",
}

local function downloadImage()
    if not isfile(CONFIG.FileName) then
        local response = request({
            Url = CONFIG.ImageUrl,
            Method = "GET"
        })
        if response.StatusCode == 200 then
            writefile(CONFIG.FileName, response.Body)
        else
            return false
        end
    end
    return true
end

local ElMatadorIntro = {}
ElMatadorIntro.__index = ElMatadorIntro

function ElMatadorIntro.new()
    local self = setmetatable({}, ElMatadorIntro)
    self.connections = {}
    self.isActive = false
    self.glitching = false
    return self
end

function ElMatadorIntro:createScreenGui()
    local guiParent = gethui and gethui() or CoreGui
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ElMatadorIntro"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.screenGui.DisplayOrder = 999999
    self.screenGui.Parent = guiParent
    
    self.bgFrame = Instance.new("Frame")
    self.bgFrame.Size = UDim2.new(1, 0, 1, 0)
    self.bgFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    self.bgFrame.BorderSizePixel = 0
    self.bgFrame.Parent = self.screenGui
    
    self.rgbRed = Instance.new("ImageLabel")
    self.rgbRed.Size = UDim2.new(1, 0, 1, 0)
    self.rgbRed.BackgroundTransparency = 1
    self.rgbRed.ImageColor3 = Color3.fromRGB(255, 0, 0)
    self.rgbRed.ImageTransparency = 1
    self.rgbRed.ScaleType = Enum.ScaleType.Crop
    self.rgbRed.ZIndex = 1
    self.rgbRed.Parent = self.bgFrame
    
    self.rgbBlue = Instance.new("ImageLabel")
    self.rgbBlue.Size = UDim2.new(1, 0, 1, 0)
    self.rgbBlue.BackgroundTransparency = 1
    self.rgbBlue.ImageColor3 = Color3.fromRGB(0, 0, 255)
    self.rgbBlue.ImageTransparency = 1
    self.rgbBlue.ScaleType = Enum.ScaleType.Crop
    self.rgbBlue.ZIndex = 1
    self.rgbBlue.Parent = self.bgFrame
    
    self.mainImage = Instance.new("ImageLabel")
    self.mainImage.Size = UDim2.new(1, 0, 1, 0)
    self.mainImage.BackgroundTransparency = 1
    self.mainImage.ImageTransparency = 1
    self.mainImage.ScaleType = Enum.ScaleType.Crop
    self.mainImage.ZIndex = 2
    self.mainImage.Parent = self.bgFrame
    
    self.scanlines = Instance.new("ImageLabel")
    self.scanlines.Size = UDim2.new(1, 0, 1, 0)
    self.scanlines.BackgroundTransparency = 1
    self.scanlines.Image = "rbxassetid://7188070838"
    self.scanlines.ImageColor3 = Color3.fromRGB(0, 0, 0)
    self.scanlines.ImageTransparency = 0.95
    self.scanlines.ScaleType = Enum.ScaleType.Tile
    self.scanlines.TileSize = UDim2.new(0, 1, 0, 4)
    self.scanlines.ZIndex = 10
    self.scanlines.Parent = self.bgFrame
    
    self.vignette = Instance.new("ImageLabel")
    self.vignette.Size = UDim2.new(1, 0, 1, 0)
    self.vignette.BackgroundTransparency = 1
    self.vignette.Image = "rbxassetid://7188070839"
    self.vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
    self.vignette.ImageTransparency = 0.3
    self.vignette.ZIndex = 9
    self.vignette.Parent = self.bgFrame
    
    self.overlay = Instance.new("Frame")
    self.overlay.Size = UDim2.new(1, 0, 1, 0)
    self.overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.overlay.BackgroundTransparency = 0.4
    self.overlay.ZIndex = 3
    self.overlay.Parent = self.bgFrame
    
    self.gradientOverlay = Instance.new("Frame")
    self.gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    self.gradientOverlay.BackgroundTransparency = 1
    self.gradientOverlay.ZIndex = 4
    self.gradientOverlay.Parent = self.bgFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, CONFIG.PrimaryColor)
    })
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    gradient.Parent = self.gradientOverlay
    
    self.container = Instance.new("Frame")
    self.container.Size = UDim2.new(0, 600, 0, 400)
    self.container.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.container.BackgroundTransparency = 1
    self.container.ZIndex = 20
    self.container.Parent = self.bgFrame
    
    self.titleContainer = Instance.new("Frame")
    self.titleContainer.Size = UDim2.new(0, 500, 0, 100)
    self.titleContainer.Position = UDim2.new(0.5, -250, 0.3, 0)
    self.titleContainer.BackgroundTransparency = 1
    self.titleContainer.ZIndex = 21
    self.titleContainer.Parent = self.container
    
    self.titleGlitch1 = Instance.new("TextLabel")
    self.titleGlitch1.Size = UDim2.new(1, 0, 1, 0)
    self.titleGlitch1.BackgroundTransparency = 1
    self.titleGlitch1.Text = CONFIG.TitleText
    self.titleGlitch1.TextColor3 = CONFIG.GlitchColor
    self.titleGlitch1.TextSize = 72
    self.titleGlitch1.Font = Enum.Font.GothamBlack
    self.titleGlitch1.TextTransparency = 1
    self.titleGlitch1.ZIndex = 22
    self.titleGlitch1.Parent = self.titleContainer
    
    self.titleGlitch2 = Instance.new("TextLabel")
    self.titleGlitch2.Size = UDim2.new(1, 0, 1, 0)
    self.titleGlitch2.BackgroundTransparency = 1
    self.titleGlitch2.Text = CONFIG.TitleText
    self.titleGlitch2.TextColor3 = CONFIG.PrimaryColor
    self.titleGlitch2.TextSize = 72
    self.titleGlitch2.Font = Enum.Font.GothamBlack
    self.titleGlitch2.TextTransparency = 1
    self.titleGlitch2.ZIndex = 23
    self.titleGlitch2.Parent = self.titleContainer
    
    self.titleText = Instance.new("TextLabel")
    self.titleText.Size = UDim2.new(1, 0, 1, 0)
    self.titleText.BackgroundTransparency = 1
    self.titleText.Text = CONFIG.TitleText
    self.titleText.TextColor3 = CONFIG.TextColor
    self.titleText.TextSize = 72
    self.titleText.Font = Enum.Font.GothamBlack
    self.titleText.TextTransparency = 1
    self.titleText.ZIndex = 24
    self.titleText.Parent = self.titleContainer
    
    local textGradient = Instance.new("UIGradient")
    textGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.PrimaryColor),
        ColorSequenceKeypoint.new(0.5, CONFIG.TextColor),
        ColorSequenceKeypoint.new(1, CONFIG.SecondaryColor)
    })
    textGradient.Rotation = 45
    textGradient.Parent = self.titleText
    
    self.subtitle = Instance.new("TextLabel")
    self.subtitle.Size = UDim2.new(0, 400, 0, 40)
    self.subtitle.Position = UDim2.new(0.5, -200, 0.3, 80)
    self.subtitle.BackgroundTransparency = 1
    self.subtitle.Text = "「 " .. CONFIG.SubtitleText .. " 」"
    self.subtitle.TextColor3 = CONFIG.AccentColor
    self.subtitle.TextSize = 24
    self.subtitle.Font = Enum.Font.GothamBold
    self.subtitle.TextTransparency = 1
    self.subtitle.ZIndex = 21
    self.subtitle.Parent = self.container
    
    self.loadingContainer = Instance.new("Frame")
    self.loadingContainer.Size = UDim2.new(0, 400, 0, 100)
    self.loadingContainer.Position = UDim2.new(0.5, -200, 0.7, 0)
    self.loadingContainer.BackgroundTransparency = 1
    self.loadingContainer.ZIndex = 21
    self.loadingContainer.Parent = self.container
    
    self.loadingText = Instance.new("TextLabel")
    self.loadingText.Size = UDim2.new(1, 0, 0, 30)
    self.loadingText.BackgroundTransparency = 1
    self.loadingText.Text = CONFIG.LoadingText
    self.loadingText.TextColor3 = CONFIG.PrimaryColor
    self.loadingText.TextSize = 18
    self.loadingText.Font = Enum.Font.GothamSemibold
    self.loadingText.TextTransparency = 1
    self.loadingText.ZIndex = 22
    self.loadingText.Parent = self.loadingContainer
    
    self.loadingDots = Instance.new("TextLabel")
    self.loadingDots.Size = UDim2.new(0, 50, 0, 30)
    self.loadingDots.Position = UDim2.new(1, -60, 0, 0)
    self.loadingDots.BackgroundTransparency = 1
    self.loadingDots.Text = ""
    self.loadingDots.TextColor3 = CONFIG.PrimaryColor
    self.loadingDots.TextSize = 18
    self.loadingDots.Font = Enum.Font.GothamSemibold
    self.loadingDots.TextTransparency = 1
    self.loadingDots.ZIndex = 22
    self.loadingDots.Parent = self.loadingContainer
    
    self.progressBg = Instance.new("Frame")
    self.progressBg.Size = UDim2.new(0, 300, 0, 4)
    self.progressBg.Position = UDim2.new(0.5, -150, 0, 50)
    self.progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.progressBg.BackgroundTransparency = 1
    self.progressBg.BorderSizePixel = 0
    self.progressBg.ZIndex = 22
    self.progressBg.Parent = self.loadingContainer
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 2)
    bgCorner.Parent = self.progressBg
    
    self.progressFill = Instance.new("Frame")
    self.progressFill.Size = UDim2.new(0, 0, 0, 4)
    self.progressFill.BackgroundColor3 = CONFIG.PrimaryColor
    self.progressFill.BackgroundTransparency = 1
    self.progressFill.BorderSizePixel = 0
    self.progressFill.ZIndex = 23
    self.progressFill.Parent = self.progressBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = self.progressFill
    
    self.progressGlow = Instance.new("Frame")
    self.progressGlow.Size = UDim2.new(1, 4, 1, 4)
    self.progressGlow.Position = UDim2.new(0, -2, 0, -2)
    self.progressGlow.BackgroundColor3 = CONFIG.PrimaryColor
    self.progressGlow.BackgroundTransparency = 1
    self.progressGlow.ZIndex = 21
    self.progressGlow.Parent = self.progressFill
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 4)
    glowCorner.Parent = self.progressGlow
    
    self.percentText = Instance.new("TextLabel")
    self.percentText.Size = UDim2.new(1, 0, 0, 20)
    self.percentText.Position = UDim2.new(0, 0, 0, 60)
    self.percentText.BackgroundTransparency = 1
    self.percentText.Text = "0%"
    self.percentText.TextColor3 = CONFIG.AccentColor
    self.percentText.TextSize = 14
    self.percentText.Font = Enum.Font.GothamMedium
    self.percentText.TextTransparency = 1
    self.percentText.ZIndex = 22
    self.percentText.Parent = self.loadingContainer
    
    self.decorLine1 = Instance.new("Frame")
    self.decorLine1.Size = UDim2.new(0, 0, 0, 2)
    self.decorLine1.Position = UDim2.new(0.5, 0, 0.55, 0)
    self.decorLine1.BackgroundColor3 = CONFIG.PrimaryColor
    self.decorLine1.BackgroundTransparency = 1
    self.decorLine1.BorderSizePixel = 0
    self.decorLine1.ZIndex = 20
    self.decorLine1.Parent = self.container
    
    self.decorLine2 = Instance.new("Frame")
    self.decorLine2.Size = UDim2.new(0, 0, 0, 1)
    self.decorLine2.Position = UDim2.new(0.5, 0, 0.85, 0)
    self.decorLine2.BackgroundColor3 = CONFIG.SecondaryColor
    self.decorLine2.BackgroundTransparency = 1
    self.decorLine2.BorderSizePixel = 0
    self.decorLine2.ZIndex = 20
    self.decorLine2.Parent = self.container
    
    self.isActive = true
end

function ElMatadorIntro:glitchEffect()
    if self.glitching then return end
    self.glitching = true
    
    spawn(function()
        for i = 1, 10 do
            if not self.isActive then break end
            local offsetX = math.random(-10, 10)
            local offsetY = math.random(-5, 5)
            self.rgbRed.Position = UDim2.new(0, offsetX, 0, offsetY)
            self.rgbBlue.Position = UDim2.new(0, -offsetX, 0, -offsetY)
            self.titleGlitch1.TextTransparency = math.random(0, 0.5)
            self.titleGlitch1.Position = UDim2.new(0, math.random(-5, 5), 0, math.random(-3, 3))
            wait(math.random(1, 3) / 60)
        end
        self.rgbRed.Position = UDim2.new(0, 0, 0, 0)
        self.rgbBlue.Position = UDim2.new(0, 0, 0, 0)
        self.titleGlitch1.TextTransparency = 1
        self.titleGlitch1.Position = UDim2.new(0, 0, 0, 0)
        self.glitching = false
    end)
end

function ElMatadorIntro:animateDots()
    local dots = {"", ".", "..", "..."}
    local index = 1
    spawn(function()
        while self.isActive do
            if self.loadingDots then
                self.loadingDots.Text = dots[index]
            end
            index = (index % #dots) + 1
            wait(0.4)
        end
    end)
end

function ElMatadorIntro:tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(duration, style, dir), props):Play()
end

function ElMatadorIntro:playIntro()
    self:tween(self.mainImage, {ImageTransparency = 0}, CONFIG.FadeInDuration)
    self:tween(self.rgbRed, {ImageTransparency = 0.8}, CONFIG.FadeInDuration)
    self:tween(self.rgbBlue, {ImageTransparency = 0.8}, CONFIG.FadeInDuration)
    wait(0.3)
    self:glitchEffect()
    self:tween(self.titleGlitch1, {TextTransparency = 0.7}, 0.1)
    self:tween(self.titleGlitch2, {TextTransparency = 0.5}, 0.2)
    self:tween(self.titleText, {TextTransparency = 0}, 0.5, Enum.EasingStyle.Back)
    wait(0.2)
    self:tween(self.subtitle, {TextTransparency = 0}, 0.6, Enum.EasingStyle.Quart)
    self:tween(self.decorLine1, {BackgroundTransparency = 0}, 0.5)
    self:tween(self.decorLine1, {Size = UDim2.new(0, 200, 0, 2), Position = UDim2.new(0.5, -100, 0.55, 0)}, 1, Enum.EasingStyle.Back)
    wait(0.3)
    self:tween(self.loadingText, {TextTransparency = 0}, 0.4)
    self:tween(self.loadingDots, {TextTransparency = 0}, 0.4)
    self:tween(self.progressBg, {BackgroundTransparency = 0.3}, 0.4)
    self:tween(self.progressFill, {BackgroundTransparency = 0}, 0.4)
    self:tween(self.progressGlow, {BackgroundTransparency = 0.8}, 0.4)
    self:tween(self.percentText, {TextTransparency = 0}, 0.4)
    spawn(function()
        wait(0.5)
        local startTime = tick()
        local duration = CONFIG.IntroDuration - 2
        while tick() - startTime < duration and self.isActive do
            local alpha = (tick() - startTime) / duration
            alpha = 1 - math.pow(1 - alpha, 3)
            local percent = math.floor(alpha * 100)
            if self.progressFill then
                self.progressFill.Size = UDim2.new(alpha, 0, 0, 4)
            end
            if self.percentText then
                self.percentText.Text = percent .. "%"
            end
            if math.random(1, 20) == 1 then
                self:glitchEffect()
            end
            RunService.RenderStepped:Wait()
        end
        if self.isActive then
            if self.progressFill then
                self.progressFill.Size = UDim2.new(1, 0, 0, 4)
            end
            if self.percentText then
                self.percentText.Text = "100%"
            end
        end
    end)
    wait(0.5)
    self:tween(self.decorLine2, {BackgroundTransparency = 0.5}, 0.5)
    self:tween(self.decorLine2, {Size = UDim2.new(0, 150, 0, 1), Position = UDim2.new(0.5, -75, 0.85, 0)}, 0.8, Enum.EasingStyle.Back)
    wait(CONFIG.IntroDuration)
    self:fadeOut()
end

function ElMatadorIntro:fadeOut()
    local duration = CONFIG.FadeOutDuration
    self:tween(self.mainImage, {ImageTransparency = 1}, duration)
    self:tween(self.rgbRed, {ImageTransparency = 1}, duration)
    self:tween(self.rgbBlue, {ImageTransparency = 1}, duration)
    self:tween(self.overlay, {BackgroundTransparency = 1}, duration)
    self:tween(self.titleText, {TextTransparency = 1}, duration)
    self:tween(self.titleGlitch1, {TextTransparency = 1}, duration)
    self:tween(self.titleGlitch2, {TextTransparency = 1}, duration)
    self:tween(self.subtitle, {TextTransparency = 1}, duration)
    self:tween(self.loadingText, {TextTransparency = 1}, duration)
    self:tween(self.loadingDots, {TextTransparency = 1}, duration)
    self:tween(self.progressBg, {BackgroundTransparency = 1}, duration)
    self:tween(self.progressFill, {BackgroundTransparency = 1}, duration)
    self:tween(self.progressGlow, {BackgroundTransparency = 1}, duration)
    self:tween(self.percentText, {TextTransparency = 1}, duration)
    self:tween(self.decorLine1, {BackgroundTransparency = 1}, duration)
    self:tween(self.decorLine2, {BackgroundTransparency = 1}, duration)
    self:tween(self.vignette, {ImageTransparency = 1}, duration)
    self:tween(self.scanlines, {ImageTransparency = 1}, duration)
    wait(duration)
end

function ElMatadorIntro:start(callback)
    downloadImage()
    self:createScreenGui()
    local assetId = getcustomasset(CONFIG.FileName)
    self.mainImage.Image = assetId
    self.rgbRed.Image = assetId
    self.rgbBlue.Image = assetId
    self:animateDots()
    self:playIntro()
    self:destroy()
    if callback then callback() end
end

function ElMatadorIntro:destroy()
    self.isActive = false
    for _, conn in ipairs(self.connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

-- ============================================
-- HERE PUT YOUR SCRIPT
-- ============================================
local function main()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local intro = ElMatadorIntro.new()
    intro:start(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/xxz18902-arch/kdio/refs/heads/main/v2"))()
        print("[El Matador] Intro complete!")
        
        -- Example: Load your UI or script here
        -- loadstring(game:HttpGet("your_script_url"))()
        
        -- Or paste your script directly:
        --[[
        local Library = loadstring(game:HttpGet("..."))()
        local Window = Library:CreateWindow("El Matador")
        -- etc...
        --]]
    end)
end

main()
