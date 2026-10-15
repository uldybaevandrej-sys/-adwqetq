-- language: Lua, file: rbe.lua, target: Roblox, runtime: executor
--[[ roblox ezzzz - obsidian v4.2 - peek + hvH + smart silent + new AA/fakelag ]]

if getgenv().__RBE_LOADED then
    pcall(function() getgenv().__RBE_UI:Destroy() end)
end
getgenv().__RBE_LOADED = true
getgenv().__RBE_HITMARKER = nil

local Players      = game:GetService("Players")
local RS           = game:GetService("ReplicatedStorage")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LP           = Players.LocalPlayer
local WS           = workspace
local CAM          = WS.CurrentCamera

local setreadonly       = setreadonly or function() end
local getnamecallmethod = getnamecallmethod or function() return "" end
local newcclosure       = newcclosure or function(f) return f end
local gethui            = gethui or function() return game:GetService("CoreGui") end
local unpack            = unpack or table.unpack

local clamp, floor, rad, sin, cos, pi = math.clamp, math.floor, math.rad, math.sin, math.cos, math.pi
local abs, rand = math.abs, math.random
local min, max = math.min, math.max

local CFG_FOLDER = "RobloxEzzzz"
local CFG_FILE   = CFG_FOLDER .. "/config.json"

local DEFAULT = {
    no_spread=false, no_recoil=false, rapid_fire=false,
    gun_cd=0.001, melee_cd=0.001, auto_weapon=false, infinite_jump=false,
    rage=false, rage_void=false, rage_hide=0.25, rage_attack=0.1,
    rage_auto_equip=true, rage_reacquire=0.2, rage_hitbox="Head",
    silent=false, trigger=false, silent_chance=100, trigger_delay=0,
    fov=170, max_dist=300, wallcheck=true, target_part="Head",
    silent_prediction=0.0,
    silent_multipoint=true, silent_multi_samples=4,
    silent_priority="fov",
    silent_switch_delay=0.05,
    silent_head_bias=true,
    aim=false, aim_smooth=0.1,
    fov_circle_enabled=false, fov_circle_radius=170,
    esp=false, esp_box=true, esp_name=true, esp_hp=true, esp_skeleton=false,
    esp_chams=false, esp_distance=true, esp_max_dist=1500, esp_team=false,
    esp_col_r=168, esp_col_g=85, esp_col_b=247,
    esp_snapline=false, esp_facing=false, esp_hitmarker=true,
    aa=false, aa_underground=false, aa_pitch=0, aa_yaw=0, aa_jitter=20, aa_speed=10,
    aa_mode="Offset", aa_fakelag=0, aa_fakelag_mode="choke",
    walk=false, walk_mult=2, slide=false, slide_mult=10,
    jump=false, jump_mult=2, flight=false, flight_speed=100,
    noclip=false, bypass_noclip=false, strafe_speed=50,
    third_person=false, third_person_dist=8,
    peek_enabled=false, peek_mode="duck",
    peek_key=Enum.KeyCode.E, peek_auto=false,
    peek_duration=0.35, peek_hold_time=0.15,
    peek_crouch_speed=6, peek_strafe_dist=8,
    peek_shoot_on_peak=true, peek_release_after=true,
    hvh_enabled=false, hvh_autodetect=true,
    hvh_baim_on_aa=true, hvh_counter_aa=true,
    hvh_auto_body=true, hvh_anti_backtrack=true,
    hvh_detect_threshold=3,
    weather_snow=false, weather_rain=false, weather_leaves=false, weather_fireflies=false,
    weather_density=200, weather_speed=15,
    fog_enabled=false, fog_start=50, fog_end=500,
    fog_color_r=128, fog_color_g=128, fog_color_b=128,
    bloom_enabled=false, bloom_intensity=1, bloom_size=24, bloom_threshold=0.9,
    cc_enabled=false, cc_brightness=0, cc_contrast=0, cc_saturation=0,
    dof_enabled=false, dof_far=200, dof_focus=50, dof_near=20,
    fov_value=70, time_of_day=14.5,
    spoof_device=false, device_idx=1,
    spoof_name=false, spoof_username=false, display_name="", username="",
    spoof_elo=0, spoof_streak=0, spoof_level=0,
    anim="Default",
    ui_accent_r=168, ui_accent_g=85, ui_accent_b=247,
    ui_w=800, ui_h=540, ui_particles=true, ui_blur=true,
    spotify_discord_id="", spotify_enabled=false,
    watermark_enabled=true, watermark_x=16, watermark_y=16,
    watermark_scale=1.0, watermark_opacity=1.0, watermark_locked=false,
    keybinds_enabled=true, keybinds_x=16, keybinds_y=60,
    keybinds_scale=1.0, keybinds_opacity=1.0, keybinds_locked=false,
    drag_magnetic=true, drag_snap_grid=0, drag_shadow=true, drag_magnet_dist=40,
    win_x=0.5, win_y=0.5, win_locked=false,
    hitsound_enabled=false, hitsound_type="tick",
    hitsound_volume=0.7, hitsound_pitch=1.0, hitsound_only_kill=false,
    uisound_enabled=true, uisound_volume=0.35,
    deathsound_enabled=true, deathsound_volume=0.8,
}

local function ensureFolder()
    if not isfolder then return false end
    if not isfolder(CFG_FOLDER) then pcall(makefolder, CFG_FOLDER) end
    return isfolder(CFG_FOLDER)
end
local function loadConfig()
    if not (isfile and readfile) or not ensureFolder() then return nil end
    if not isfile(CFG_FILE) then return nil end
    local ok, raw = pcall(readfile, CFG_FILE)
    if not ok or type(raw) ~= "string" or raw == "" then return nil end
    local ok2, dec = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or type(dec) ~= "table" then return nil end
    return dec
end
local function saveConfig(tbl)
    if not (writefile and ensureFolder()) then return end
    local ok, enc = pcall(function() return HttpService:JSONEncode(tbl) end)
    if not ok then return end
    pcall(writefile, CFG_FILE, enc)
end

local Save = {}
for k, v in pairs(DEFAULT) do Save[k] = v end
do
    local loaded = loadConfig()
    if loaded then
        for k, v in pairs(loaded) do
            if DEFAULT[k] ~= nil then Save[k] = v end
        end
    end
end
local function persist() saveConfig(Save) end

local SOUND_IDS = {
    hitsound_tick  = "rbxassetid://6042053626",
    hitsound_pop   = "rbxassetid://4612375233",
    hitsound_glass = "rbxassetid://9125402735",
    hitsound_click = "rbxassetid://5028857084",
    hitsound_bell  = "rbxassetid://13746669928",
    hitsound_fah   = "rbxassetid://6539572502",
    hitsound_cod   = "rbxassetid://5810753250",
    hitsound_csgo  = "rbxassetid://4627613623",
    notification   = "rbxassetid://9068077052",
    death          = "rbxassetid://17620645740",
}
local HITSOUND_LIST = {"tick","pop","glass","click","bell","fah","cod","csgo"}

local hitPool = {}
for i = 1, 8 do
    local s = Instance.new("Sound")
    s.Name = "rbe_hit_" .. i
    s.Volume = Save.hitsound_volume or 0.7
    s.PlaybackSpeed = Save.hitsound_pitch or 1
    s.SoundId = SOUND_IDS["hitsound_" .. (Save.hitsound_type or "tick")] or SOUND_IDS.hitsound_tick
    s.Parent = SoundService
    hitPool[i] = s
end
local hitIdx = 1

local uiPool = {}
for i = 1, 4 do
    local s = Instance.new("Sound")
    s.Name = "rbe_ui_" .. i
    s.Volume = Save.uisound_volume or 0.35
    s.SoundId = SOUND_IDS.notification
    s.Parent = SoundService
    uiPool[i] = s
end
local uiIdx = 1

local deathSound = Instance.new("Sound")
deathSound.Name = "rbe_death"
deathSound.Volume = Save.deathsound_volume or 0.8
deathSound.SoundId = SOUND_IDS.death
deathSound.Parent = SoundService

local lastHitSound = 0
local lastUISound = 0

local function playHitsound(isKill)
    if not Save.hitsound_enabled then return end
    if Save.hitsound_only_kill and not isKill then return end
    local now = os.clock()
    if now - lastHitSound < 0.02 then return end
    lastHitSound = now
    local s = hitPool[hitIdx]
    hitIdx = (hitIdx % #hitPool) + 1
    s.SoundId = SOUND_IDS["hitsound_" .. (Save.hitsound_type or "tick")] or SOUND_IDS.hitsound_tick
    s.Volume = isKill and min(1, (Save.hitsound_volume or 0.7) * 1.4) or (Save.hitsound_volume or 0.7)
    s.PlaybackSpeed = (Save.hitsound_pitch or 1) * (isKill and 1.15 or 1)
    pcall(function() s:Play() end)
    if Save.esp_hitmarker and getgenv().__RBE_HITMARKER then
        pcall(getgenv().__RBE_HITMARKER)
    end
end

local function playUISound(pMin, pMax)
    if not Save.uisound_enabled then return end
    local now = os.clock()
    if now - lastUISound < 0.015 then return end
    lastUISound = now
    pMin = pMin or 0.9
    pMax = pMax or 1.15
    local s = uiPool[uiIdx]
    uiIdx = (uiIdx % #uiPool) + 1
    s.Volume = Save.uisound_volume or 0.35
    s.PlaybackSpeed = pMin + math.random() * (pMax - pMin)
    pcall(function() s:Play() end)
end

local function playDeathSound()
    if not Save.deathsound_enabled then return end
    deathSound.Volume = Save.deathsound_volume or 0.8
    pcall(function() deathSound:Play() end)
end

local function hookLocalDeath(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.Died:Connect(function() playDeathSound() end)
end
if LP.Character then hookLocalDeath(LP.Character) end
LP.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    hookLocalDeath(c)
end)

local function findChild(root, ...)
    if not root then return nil end
    local node = root
    for _, name in ipairs({...}) do
        if node then
            local ok, c = pcall(function() return node:FindFirstChild(name) end)
            if ok then node = c else node = nil end
        end
    end
    return node
end
local function safeRequire(inst)
    if not inst then return nil end
    local ok, res = pcall(require, inst)
    return ok and res or nil
end

local M = {}
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local ps = LP:WaitForChild("PlayerScripts", 30)
    if not ps then return end
    local ctrl  = ps:WaitForChild("Controllers", 30)
    local mods  = ps:WaitForChild("Modules", 30)
    local rmods = RS:WaitForChild("Modules", 30)
    if ctrl then
        M.FighterController    = safeRequire(ctrl:FindFirstChild("FighterController"))
        M.PlayerDataController = safeRequire(ctrl:FindFirstChild("PlayerDataController"))
        M.CameraController     = safeRequire(ctrl:FindFirstChild("CameraController"))
        M.MechanicsController  = safeRequire(ctrl:FindFirstChild("MechanicsController"))
    end
    if rmods then
        M.EnumLibrary     = safeRequire(rmods:FindFirstChild("EnumLibrary"))
        M.CosmeticLibrary = safeRequire(rmods:FindFirstChild("CosmeticLibrary"))
        M.ItemLibrary     = safeRequire(rmods:FindFirstChild("ItemLibrary"))
        M.Utility         = safeRequire(rmods:FindFirstChild("Utility"))
        M.OutOfBounds     = safeRequire(rmods:FindFirstChild("OutOfBoundsMachine"))
        M.GameplayUtil    = safeRequire(rmods:FindFirstChild("GameplayUtility"))
    end
    if mods then
        M.Gun   = safeRequire(findChild(mods, "ItemTypes", "Gun"))
        M.Melee = safeRequire(findChild(mods, "ItemTypes", "Melee"))
    end
end)

task.spawn(function()
    local t = os.clock()
    while not (M.FighterController and M.PlayerDataController and M.ItemLibrary) and os.clock() - t < 40 do
        task.wait(0.25)
    end
end)

local State = {
    server_cf = nil, server_cf_sync = true, camera_frozen = false,
    LocalChar = LP.Character, target = nil, target_part = nil,
    is_reloading = false, last_shot_t = 0,
    peek_active = false, peek_start = 0, peek_phase = "idle",
    peek_orig_speed = nil, peek_released = true,
    fakelag_active = false, fakelag_accum = 0, fakelag_frozen = false,
    fakelag_start = 0, fakelag_hold_cf = nil, fakelag_last_unfreeze = 0,
    hvh_suspects = {}, hvh_last_check = 0,
    hvh_flag = false,
    silent_last_switch = 0, silent_last_target = nil,
}
if LP.Character then State.LocalChar = LP.Character end
LP.CharacterAdded:Connect(function(c) State.LocalChar = c end)

if M.CameraController and type(M.CameraController.Update) == "function" then
    local orig = M.CameraController.Update
    M.CameraController.Update = function(self, ...)
        if State.camera_frozen then return end
        return orig(self, ...)
    end
end

local AART = {
    enabled = Save.aa, mode = Save.aa_mode or "Offset",
    pitch_angle = Save.aa_pitch, yaw_angle = Save.aa_yaw,
    jitter = Save.aa_jitter, speed = Save.aa_speed,
    underground = Save.aa_underground,
    spinPhase = 0, jitterVal = 0, jitterLast = 0, lastTick = tick(),
}

local function aartRand(mn, mx)
    local seed = (os.clock() * 1e9 + tick() * 1e6 + rand(1, 1e9))
    seed = abs(sin(seed) * 1e14)
    local rng = Random.new(seed % 2 ^ 31)
    return rng:NextNumber(mn, mx)
end

local function computeAAOffset()
    if not AART.enabled then return 0, 0 end
    local now = tick()
    local dt = max(now - AART.lastTick, 0.001)
    AART.lastTick = now
    local pitch, yaw = 0, 0
    local mode = AART.mode
    if mode == "Offset" then
        pitch = rad(AART.pitch_angle)
        yaw = rad(AART.yaw_angle)
    elseif mode == "Random" then
        pitch = rad(aartRand(-89, 89))
        yaw = rad(aartRand(-180, 180))
    elseif mode == "Spin" then
        AART.spinPhase = (AART.spinPhase + rad(AART.speed) * dt * 6) % (pi * 2)
        yaw = AART.spinPhase
    elseif mode == "Jitter" then
        if now - AART.jitterLast >= 1 / max(AART.speed, 1) then
            AART.jitterLast = now
            AART.jitterVal = rad(aartRand(-AART.jitter, AART.jitter))
        end
        yaw = AART.jitterVal
        pitch = rad(aartRand(-15, 15)) * 0.5
    elseif mode == "Backwards" then
        yaw = pi
    end
    return pitch, yaw
end

local AA = AART

do
    local real, realLin, realAng
    pcall(function()
        RunService:BindToRenderStep("rbe_scf_" .. tostring(rand(1, 1e6)), 0, function()
            local root = State.LocalChar and State.LocalChar.PrimaryPart
            if root and root.Parent and real then
                root.AssemblyLinearVelocity = realLin or Vector3.zero
                root.AssemblyAngularVelocity = realAng or Vector3.zero
                root.CFrame = real
            end
        end)
    end)
    RunService.PostSimulation:Connect(function()
        local root = State.LocalChar and State.LocalChar.PrimaryPart
        if not (root and root.Parent) then return end
        real = root.CFrame
        realLin = root.AssemblyLinearVelocity
        realAng = root.AssemblyAngularVelocity

        local fl_ms = Save.aa_fakelag or 0
        local fl_active = Save.rage and AART.enabled and fl_ms > 0
        if fl_active then
            local now = tick()
            if not State.fakelag_frozen then
                if now - (State.fakelag_last_unfreeze or 0) >= (fl_ms / 1000) then
                    State.fakelag_frozen = true
                    State.fakelag_start = now
                    State.fakelag_hold_cf = State.server_cf or real
                end
            else
                if now - State.fakelag_start >= (fl_ms / 1000) then
                    State.fakelag_frozen = false
                    State.fakelag_last_unfreeze = now
                    if State.server_cf_sync then
                        State.server_cf = real
                    end
                end
            end
        else
            State.fakelag_frozen = false
        end

        if State.fakelag_frozen and State.fakelag_hold_cf then
            State.server_cf = State.fakelag_hold_cf
        elseif State.server_cf_sync then
            State.server_cf = real
        end

        local sendCF = State.server_cf or real
        if AART.enabled then
            local ax, ay = computeAAOffset()
            sendCF = sendCF * CFrame.Angles(ax, ay, 0)
        end
        root.CFrame = sendCF
    end)
end

RunService.Heartbeat:Connect(function()
    if AART.enabled and AART.underground then
        local root = State.LocalChar and State.LocalChar.PrimaryPart
        if root and root.Parent then
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = {State.LocalChar}
            local r = WS:Raycast(root.Position, Vector3.new(0, -500, 0), rp)
            if r then root.CFrame = CFrame.new(root.Position.X, r.Position.Y - 2, root.Position.Z) end
        end
    end
end)

if M.Gun and type(M.Gun.StartReloading) == "function" then
    local orig = M.Gun.StartReloading
    M.Gun.StartReloading = function(self, ...)
        State.is_reloading = true
        local dur = (self and self.Info and self.Info.ReloadLength) or 2
        task.delay(dur + 0.1, function() State.is_reloading = false end)
        return orig(self, ...)
    end
end

local Hitsound = { prevHp = {} }
local hitsoundConns = {}
local function hookPlayerHitsound(plr)
    if plr == LP then return end
    local function hookChar(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        Hitsound.prevHp[plr] = hum.Health
        local conn = hum.HealthChanged:Connect(function(newHp)
            local prev = Hitsound.prevHp[plr] or newHp
            Hitsound.prevHp[plr] = newHp
            if newHp < prev and (os.clock() - State.last_shot_t) < 0.5 then
                playHitsound(newHp <= 0)
            end
        end)
        table.insert(hitsoundConns, conn)
    end
    if plr.Character then hookChar(plr.Character) end
    table.insert(hitsoundConns, plr.CharacterAdded:Connect(hookChar))
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayerHitsound(p) end
Players.PlayerAdded:Connect(hookPlayerHitsound)
Players.PlayerRemoving:Connect(function(p) Hitsound.prevHp[p] = nil end)

local RF = {
    no_spread = Save.no_spread, no_recoil = Save.no_recoil,
    rapid_fire = Save.rapid_fire, gun_cd = Save.gun_cd, melee_cd = Save.melee_cd,
    auto_weapon = Save.auto_weapon, infinite_jump = Save.infinite_jump,
    savedGun = {}, savedMelee = {},
}
local WEAPON_EXCLUDE = {Sniper=true, Crossbow=true, Bow=true, RPG=true}

local function syncWeaponMods()
    if not (M.ItemLibrary and M.ItemLibrary.Items) then return end
    for name, data in pairs(M.ItemLibrary.Items) do
        if type(data) == "table" and not WEAPON_EXCLUDE[name] then
            RF.savedGun[name] = RF.savedGun[name] or {}
            RF.savedMelee[name] = RF.savedMelee[name] or {}
            for _, prop in ipairs({"ShootSpread","ShootAccuracy","QuickShotSpread","AimSpreadMultiplier"}) do
                if type(data[prop]) == "number" then
                    if RF.no_spread then
                        RF.savedGun[name][prop] = RF.savedGun[name][prop] or data[prop]
                        data[prop] = 0
                    elseif RF.savedGun[name][prop] then
                        data[prop] = RF.savedGun[name][prop]
                        RF.savedGun[name][prop] = nil
                    end
                end
            end
            if data.ShootSpreadConsistent ~= nil then
                if RF.no_spread then
                    if RF.savedGun[name].ShootSpreadConsistent == nil then
                        RF.savedGun[name].ShootSpreadConsistent = data.ShootSpreadConsistent
                    end
                    data.ShootSpreadConsistent = true
                elseif RF.savedGun[name].ShootSpreadConsistent ~= nil then
                    data.ShootSpreadConsistent = RF.savedGun[name].ShootSpreadConsistent
                    RF.savedGun[name].ShootSpreadConsistent = nil
                end
            end
            if type(data.ShootRecoil) == "number" then
                if RF.no_recoil then
                    RF.savedGun[name].ShootRecoil = RF.savedGun[name].ShootRecoil or data.ShootRecoil
                    data.ShootRecoil = 0
                elseif RF.savedGun[name].ShootRecoil then
                    data.ShootRecoil = RF.savedGun[name].ShootRecoil
                    RF.savedGun[name].ShootRecoil = nil
                end
            end
            for _, prop in ipairs({"ShootCooldown","ShootBurstCooldown"}) do
                if type(data[prop]) == "number" then
                    if RF.rapid_fire then
                        RF.savedGun[name][prop] = RF.savedGun[name][prop] or data[prop]
                        data[prop] = RF.gun_cd
                    elseif RF.savedGun[name][prop] then
                        data[prop] = RF.savedGun[name][prop]
                        RF.savedGun[name][prop] = nil
                    end
                end
            end
            for _, prop in ipairs({"AttackCooldown","SwingCooldown","MeleeCooldown","Cooldown","RecoveryTime","ResetTime"}) do
                if type(data[prop]) == "number" then
                    if RF.rapid_fire then
                        RF.savedMelee[name][prop] = RF.savedMelee[name][prop] or data[prop]
                        data[prop] = RF.melee_cd
                    elseif RF.savedMelee[name][prop] then
                        data[prop] = RF.savedMelee[name][prop]
                        RF.savedMelee[name][prop] = nil
                    end
                end
            end
            if type(data.InputSpammingEnabled) == "table" then
                if RF.auto_weapon then
                    if RF.savedGun[name].Spamming == nil then
                        RF.savedGun[name].Spamming = {
                            StartShooting  = data.InputSpammingEnabled.StartShooting,
                            StartReloading = data.InputSpammingEnabled.StartReloading,
                        }
                    end
                    data.InputSpammingEnabled.StartShooting  = 0
                    data.InputSpammingEnabled.StartReloading = 0
                elseif RF.savedGun[name].Spamming ~= nil then
                    data.InputSpammingEnabled.StartShooting  = RF.savedGun[name].Spamming.StartShooting
                    data.InputSpammingEnabled.StartReloading = RF.savedGun[name].Spamming.StartReloading
                    RF.savedGun[name].Spamming = nil
                end
            end
            if data.MaxDoubleJumps ~= nil then
                if RF.infinite_jump then
                    if RF.savedGun[name].MaxDoubleJumps == nil then
                        RF.savedGun[name].MaxDoubleJumps = data.MaxDoubleJumps
                    end
                    data.MaxDoubleJumps = 676767
                elseif RF.savedGun[name].MaxDoubleJumps ~= nil then
                    data.MaxDoubleJumps = RF.savedGun[name].MaxDoubleJumps
                    RF.savedGun[name].MaxDoubleJumps = nil
                end
            end
        end
    end
end

local function restoreWeaponMods()
    if not (M.ItemLibrary and M.ItemLibrary.Items) then return end
    for name, saved in pairs(RF.savedGun) do
        local d = M.ItemLibrary.Items[name]
        if d then
            for k, v in pairs(saved) do
                if k == "Spamming" and d.InputSpammingEnabled then
                    d.InputSpammingEnabled.StartShooting  = v.StartShooting
                    d.InputSpammingEnabled.StartReloading = v.StartReloading
                else d[k] = v end
            end
        end
    end
    for name, saved in pairs(RF.savedMelee) do
        local d = M.ItemLibrary.Items[name]
        if d then for k, v in pairs(saved) do d[k] = v end end
    end
    RF.savedGun, RF.savedMelee = {}, {}
end

task.spawn(function()
    while not M.ItemLibrary do task.wait(0.5) end
    task.wait(1)
    syncWeaponMods()
    while true do
        task.wait(0.5)
        syncWeaponMods()
    end
end)

pcall(function()
    local oob = findChild(RS, "Remotes", "Replication", "Fighter", "OutOfBounds")
    if oob and type(hookmetamethod) == "function" then
        local mt = getrawmetatable(game)
        local idx = mt and mt.__namecall
        if idx then
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if self == oob and getnamecallmethod() == "FireServer" then return nil end
                return idx(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
    if M.OutOfBounds then
        pcall(function() M.OutOfBounds.IsOutOfBounds = function() return false end end)
        pcall(function() M.OutOfBounds.Update = function() end end)
    end
    if M.GameplayUtil then
        pcall(function() M.GameplayUtil.GetOOBWarnDelay = function() return 9999 end end)
        pcall(function() M.GameplayUtil.GetOOBKillDelay  = function() return 9999 end end)
        pcall(function() M.GameplayUtil.IsWithinOOBPart  = function() end end)
    end
end)

local function isTM(p)
    if not p then return false end
    local a = LP:GetAttribute("TeamID")
    local b = p:GetAttribute("TeamID")
    return a ~= nil and b ~= nil and a == b
end
local function getCharParts(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("HumanoidRootPart"), p.Character:FindFirstChildOfClass("Humanoid")
end
local function getMultiParts(char)
    if not char then return {} end
    local parts = {}
    local names = {"Head","UpperTorso","LowerTorso","HumanoidRootPart","Torso",
                   "LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg",
                   "HitboxHead","HitboxBody"}
    for _, n in ipairs(names) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then
            table.insert(parts, p)
        end
    end
    return parts
end

local ESP = {
    enabled = Save.esp, box = Save.esp_box, name = Save.esp_name, hp = Save.esp_hp,
    skeleton = Save.esp_skeleton, chams = Save.esp_chams, distance = Save.esp_distance,
    maxDistance = Save.esp_max_dist, teamCheck = not Save.esp_team,
    boxColor = Color3.fromRGB(Save.esp_col_r, Save.esp_col_g, Save.esp_col_b),
    hpLow  = Color3.fromRGB(255, 60, 90),
    hpMid  = Color3.fromRGB(255, 200, 90),
    hpHigh = Color3.fromRGB(120, 230, 140),
    nameColor = Color3.fromRGB(255, 255, 255),
}
local espObjects = {}
local espAllDrawings = {}

local function mkDraw(cls, props)
    local d = Drawing.new(cls)
    for k, v in pairs(props or {}) do d[k] = v end
    table.insert(espAllDrawings, d)
    return d
end
local function getSkeletonPairs(char)
    local prs = {}
    if not char then return prs end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Motor6D") and d.Part0 and d.Part1 then
            table.insert(prs, {d.Part0, d.Part1})
        end
    end
    if #prs == 0 then
        local names = {
            {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
            {"Torso","Left Leg"},{"Torso","Right Leg"},
            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
            {"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
            {"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
        }
        for _, n in ipairs(names) do
            local a, b = char:FindFirstChild(n[1]), char:FindFirstChild(n[2])
            if a and b then table.insert(prs, {a, b}) end
        end
    end
    return prs
end
local function espMake(p)
    if espObjects[p] then return end
    local o = {
        box = mkDraw("Square", {Color = ESP.boxColor, Thickness = 1.5, Filled = false, Visible = false}),
        text = mkDraw("Text", {Size = 12, Color = ESP.nameColor, Outline = true, Visible = false}),
        dist = mkDraw("Text", {Size = 10, Color = Color3.fromRGB(200, 200, 200), Outline = true, Visible = false}),
        hpBg = mkDraw("Square", {Color = Color3.fromRGB(0, 0, 0), Filled = true, Visible = false}),
        hpFill = mkDraw("Square", {Color = ESP.hpHigh, Filled = true, Visible = false}),
        snapline = mkDraw("Line", {Color = ESP.boxColor, Thickness = 1.2, Visible = false}),
        facing = mkDraw("Line", {Color = Color3.fromRGB(255, 220, 80), Thickness = 2, Visible = false}),
        skeleton = {}, bonePairs = {},
    }
    for i = 1, 20 do
        o.skeleton[i] = mkDraw("Line", {Color = ESP.boxColor, Thickness = 1.4, Visible = false})
    end
    local hl = Instance.new("Highlight")
    hl.Name = "rbe_cham_" .. p.Name
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = ESP.boxColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.Enabled = false
    hl.Parent = game:GetService("CoreGui")
    o.highlight = hl
    espObjects[p] = o
end
local function espHide(o)
    if not o then return end
    o.box.Visible = false
    o.text.Visible = false
    o.dist.Visible = false
    o.hpBg.Visible = false
    o.hpFill.Visible = false
    o.snapline.Visible = false
    o.facing.Visible = false
    if o.highlight then o.highlight.Enabled = false end
    for _, l in ipairs(o.skeleton) do l.Visible = false end
end
local function espDestroy(p)
    local o = espObjects[p]
    if not o then return end
    for _, k in ipairs({"box","text","dist","hpBg","hpFill","snapline","facing"}) do
        pcall(function() o[k]:Remove() end)
    end
    for _, l in ipairs(o.skeleton) do pcall(function() l:Remove() end) end
    if o.highlight then o.highlight:Destroy() end
    espObjects[p] = nil
end
local function drawSkeleton(o, char)
    if not ESP.skeleton or not char then
        for _, l in ipairs(o.skeleton) do l.Visible = false end
        return
    end
    if not o.bonePairs or #o.bonePairs == 0 then o.bonePairs = getSkeletonPairs(char) end
    for i, pr in ipairs(o.bonePairs) do
        local line = o.skeleton[i]
        if line then
            local a, b = pr[1], pr[2]
            if a and b and a.Parent and b.Parent then
                local pa, oa = CAM:WorldToViewportPoint(a.Position)
                local pb, ob = CAM:WorldToViewportPoint(b.Position)
                if oa and ob and pa.Z > 0 and pb.Z > 0 then
                    line.From, line.To = Vector2.new(pa.X, pa.Y), Vector2.new(pb.X, pb.Y)
                    line.Visible = true
                else line.Visible = false end
            else line.Visible = false end
        end
    end
    for i = #o.bonePairs + 1, #o.skeleton do o.skeleton[i].Visible = false end
end

local espAccum = 0
RunService.RenderStepped:Connect(function(dt)
    if not ESP.enabled then
        for _, o in pairs(espObjects) do espHide(o) end
        return
    end
    espAccum = espAccum + dt
    if espAccum < 0.03 then return end
    espAccum = 0
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local skip = false
            if ESP.teamCheck and isTM(p) then skip = true end
            if skip then
                if espObjects[p] then espHide(espObjects[p]) end
            else
                if not espObjects[p] then espMake(p) end
                local o = espObjects[p]
                local char = p.Character
                local root, hum = getCharParts(p)
                if char and root and hum and hum.Health > 0 then
                    local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
                    if ESP.maxDistance > 0 and dist > ESP.maxDistance then
                        espHide(o)
                    else
                        if o.highlight then
                            o.highlight.Adornee = ESP.chams and char or nil
                            o.highlight.Enabled = ESP.chams
                            o.highlight.FillColor = ESP.boxColor
                        end
                        local top, tOn = CAM:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local bot, bOn = CAM:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        if tOn and bOn then
                            local h = abs(top.Y - bot.Y) * 0.75
                            local w = h * 0.55
                            local x = top.X - w * 0.5
                            local y = top.Y
                            if ESP.box then
                                o.box.Size = Vector2.new(w, h)
                                o.box.Position = Vector2.new(x, y)
                                o.box.Color = ESP.boxColor
                                o.box.Visible = true
                            else o.box.Visible = false end
                            if ESP.name then
                                o.text.Text = p.Name
                                o.text.Position = Vector2.new(x, y - 14)
                                o.text.Visible = true
                            else o.text.Visible = false end
                            if ESP.distance then
                                o.dist.Text = tostring(floor(dist))
                                o.dist.Position = Vector2.new(x, y + h + 2)
                                o.dist.Visible = true
                            else o.dist.Visible = false end
                            if ESP.hp then
                                local ratio = clamp(hum.Health / max(hum.MaxHealth, 1), 0, 1)
                                o.hpBg.Size = Vector2.new(3, h)
                                o.hpBg.Position = Vector2.new(x - 6, y)
                                o.hpBg.Visible = true
                                o.hpFill.Size = Vector2.new(3, h * ratio)
                                o.hpFill.Position = Vector2.new(x - 6, y + h * (1 - ratio))
                                o.hpFill.Color = ratio > 0.5 and ESP.hpHigh or (ratio > 0.25 and ESP.hpMid or ESP.hpLow)
                                o.hpFill.Visible = true
                            else o.hpBg.Visible, o.hpFill.Visible = false, false end
                            drawSkeleton(o, char)
                            if Save.esp_snapline then
                                local head = char:FindFirstChild("Head")
                                local hp, hon = CAM:WorldToViewportPoint(head and head.Position or root.Position)
                                if hon and hp.Z > 0 then
                                    o.snapline.From = Vector2.new(CAM.ViewportSize.X * 0.5, CAM.ViewportSize.Y)
                                    o.snapline.To = Vector2.new(hp.X, hp.Y)
                                    o.snapline.Color = ESP.boxColor
                                    o.snapline.Visible = true
                                else o.snapline.Visible = false end
                            else o.snapline.Visible = false end
                            if Save.esp_facing then
                                local look = root.CFrame.LookVector
                                local fA = root.Position + look * 1.5
                                local fB = root.Position + look * 3
                                local pa, oa = CAM:WorldToViewportPoint(fA)
                                local pb, ob = CAM:WorldToViewportPoint(fB)
                                if oa and ob and pa.Z > 0 and pb.Z > 0 then
                                    o.facing.From = Vector2.new(pa.X, pa.Y)
                                    o.facing.To = Vector2.new(pb.X, pb.Y)
                                    o.facing.Color = Color3.fromRGB(255, 220, 80)
                                    o.facing.Visible = true
                                else o.facing.Visible = false end
                            else o.facing.Visible = false end
                        else espHide(o) end
                    end
                else espHide(o) end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then espDestroy(p) end
end)

local Aim = {
    enabled = Save.aim, teamCheck = true, part = Save.target_part,
    fovRadius = Save.fov, smoothness = Save.aim_smooth,
    wallcheck = Save.wallcheck,
}
local rayP_aim = RaycastParams.new()
rayP_aim.FilterType = Enum.RaycastFilterType.Exclude
rayP_aim.IgnoreWater = true
rayP_aim.FilterDescendantsInstances = State.LocalChar and {State.LocalChar} or {}
LP.CharacterAdded:Connect(function(c) rayP_aim.FilterDescendantsInstances = {c} end)

local function wallBlocked(from, to, char)
    if not Aim.wallcheck then return false end
    local r = WS:Raycast(from, to - from, rayP_aim)
    if not r then return false end
    return not r.Instance:IsDescendantOf(char)
end

local function pickAimTarget()
    local best, bestD = nil, Aim.fovRadius
    local center = CAM.ViewportSize * 0.5
    local origin = CAM.CFrame.Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local isTeam = Aim.teamCheck and isTM(p)
            if not isTeam then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = p.Character:FindFirstChild(Aim.part) or p.Character:FindFirstChild("Head")
                    if part and part:IsA("BasePart") then
                        if not wallBlocked(origin, part.Position, p.Character) then
                            local sp, on = CAM:WorldToViewportPoint(part.Position)
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d < bestD then bestD = d; best = p end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local fovCircle = Drawing.new("Circle")
fovCircle.NumSides = 80
fovCircle.Thickness = 1.4
fovCircle.Color = ESP.boxColor
fovCircle.Filled = false
fovCircle.Visible = false
table.insert(espAllDrawings, fovCircle)

RunService.RenderStepped:Connect(function()
    if Save.fov_circle_enabled then
        fovCircle.Position = CAM.ViewportSize * 0.5
        fovCircle.Radius = Save.fov_circle_radius
        fovCircle.Color = ESP.boxColor
        fovCircle.Visible = true
    else fovCircle.Visible = false end
    if Aim.enabled then
        local target = pickAimTarget()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Aim.part) or target.Character:FindFirstChild("Head")
            if part then
                local alpha = clamp(1 - Aim.smoothness, 0.05, 1)
                CAM.CFrame = CAM.CFrame:Lerp(CFrame.lookAt(CAM.CFrame.Position, part.Position), alpha)
            end
        end
    end
end)

local T = {
    radius = Save.fov, max_distance = Save.max_dist,
    weight = 0.7, forget = 0.4,
    include = {Head = true, UpperTorso = true},
    wallcheck = Save.wallcheck,
}
local rayP = RaycastParams.new()
rayP.FilterType = Enum.RaycastFilterType.Exclude
rayP.IgnoreWater = true
rayP.FilterDescendantsInstances = State.LocalChar and {State.LocalChar} or {}
LP.CharacterAdded:Connect(function(c) rayP.FilterDescendantsInstances = {c} end)

local function wallCheck(char, part)
    if not T.wallcheck then return true end
    local r = WS:Raycast(CAM.CFrame.Position, part.Position - CAM.CFrame.Position, rayP)
    return (not r) or r.Instance:IsDescendantOf(char)
end

local function scoreCandidate(part, scr, origin, char)
    local wd = (part.Position - origin).Magnitude
    local center = CAM.ViewportSize * 0.5
    local sd = (Vector2.new(scr.X, scr.Y) - center).Magnitude ^ 2
    if sd > T.radius * T.radius then return nil end
    local score = sd * T.weight + wd * (1 - T.weight)
    if Save.silent_head_bias then
        local name = part.Name
        if name == "Head" or name == "HitboxHead" then
            score = score * 0.55
        elseif name == "UpperTorso" or name == "Torso" then
            score = score * 0.85
        end
    end
    local prio = Save.silent_priority or "fov"
    if prio == "dist" then
        score = wd
    elseif prio == "hp" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then score = score * (hum.Health / max(hum.MaxHealth, 1)) end
    elseif prio == "threat" then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and State.LocalChar and State.LocalChar.PrimaryPart then
            local myPos = State.LocalChar.PrimaryPart.Position
            local toMe = (myPos - root.Position).Unit
            local vel = root.AssemblyLinearVelocity
            local closing = vel:Dot(toMe)
            score = score * (1 - clamp(closing / 100, -1, 1) * 0.4)
        end
    end
    return score, sd
end

local function findTarget()
    local origin = CAM.CFrame.Position
    local best, bestP, bestScore = nil, nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not isTM(p) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if (root.Position - origin).Magnitude <= T.max_distance + 6 then
                    local parts
                    if Save.silent_multipoint then
                        parts = getMultiParts(p.Character)
                    else
                        parts = {}
                        for pn in pairs(T.include) do
                            local pp = p.Character:FindFirstChild(pn)
                            if pp then table.insert(parts, pp) end
                        end
                    end
                    local lp, ls = nil, math.huge
                    local samples = Save.silent_multi_samples or 4
                    local sampled = 0
                    for _, part in ipairs(parts) do
                        if sampled >= samples then break end
                        if part:IsA("BasePart") then
                            local scr, vis = CAM:WorldToViewportPoint(part.Position)
                            if vis or scr.Z > 0 then
                                local score = scoreCandidate(part, scr, origin, p.Character)
                                if score and score < ls then ls = score; lp = part end
                                sampled = sampled + 1
                            end
                        end
                    end
                    if lp and ls < bestScore and wallCheck(p.Character, lp) then
                        bestScore = ls; best = p; bestP = lp
                    end
                end
            end
        end
    end
    return best, bestP
end

local function findHvHTarget()
    local origin = CAM.CFrame.Position
    local best, bestP, bestScore = nil, nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not isTM(p) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if (root.Position - origin).Magnitude <= T.max_distance + 6 then
                    local targetPart
                    if Save.hvh_baim_on_aa then
                        targetPart = p.Character:FindFirstChild("UpperTorso")
                                  or p.Character:FindFirstChild("LowerTorso")
                                  or p.Character:FindFirstChild("HumanoidRootPart")
                                  or p.Character:FindFirstChild("Torso")
                    end
                    if not targetPart then
                        targetPart = p.Character:FindFirstChild("Head")
                                 or p.Character:FindFirstChild("UpperTorso")
                                 or root
                    end
                    if targetPart and targetPart:IsA("BasePart") then
                        local scr, vis = CAM:WorldToViewportPoint(targetPart.Position)
                        if vis or scr.Z > 0 then
                            local wd = (targetPart.Position - origin).Magnitude
                            local center = CAM.ViewportSize * 0.5
                            local sd = (Vector2.new(scr.X, scr.Y) - center).Magnitude ^ 2
                            if sd <= T.radius * T.radius then
                                local score = sd * T.weight + wd * (1 - T.weight)
                                if score < bestScore then
                                    bestScore = score; best = p; bestP = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestP
end

local function findRageTarget()
    local origin = CAM.CFrame.Position
    local best, bestP, bestScore = nil, nil, math.huge
    local hitbox = Save.rage_hitbox or "Head"
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not isTM(p) then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if (root.Position - origin).Magnitude <= T.max_distance + 200 then
                    local part = p.Character:FindFirstChild(hitbox)
                             or p.Character:FindFirstChild("Head")
                             or p.Character:FindFirstChild("UpperTorso")
                             or root
                    if part and part:IsA("BasePart") then
                        local wd = (part.Position - origin).Magnitude
                        if wd < bestScore then
                            bestScore = wd; best = p; bestP = part
                        end
                    end
                end
            end
        end
    end
    return best, bestP
end

local Mode = {
    silent = Save.silent, silent_chance = Save.silent_chance,
    trigger = Save.trigger, trigger_delay = Save.trigger_delay,
    rage = Save.rage, rage_void = Save.rage_void,
    rage_hide = Save.rage_hide, rage_attack = Save.rage_attack,
}

task.spawn(function()
    local cp, cpart, lost = nil, nil, 0
    local nextS = 0
    local pendingTarget, pendingPart, pendingSince = nil, nil, 0
    while true do
        RunService.RenderStepped:Wait()
        local now = os.clock()
        if not (Mode.silent or Mode.rage or Mode.trigger) then
            cp, cpart = nil, nil
            State.target, State.target_part = nil, nil
            pendingTarget, pendingPart = nil, nil
        else
            if now >= nextS then
                nextS = now + 0.02
                local bp, bpart
                if Mode.rage then
                    bp, bpart = findRageTarget()
                elseif Save.hvh_enabled and State.hvh_flag and Save.hvh_auto_body then
                    bp, bpart = findHvHTarget()
                else
                    bp, bpart = findTarget()
                end
                if bp then
                    if cp and cp ~= bp then
                        if not pendingTarget or pendingTarget ~= bp then
                            pendingTarget = bp; pendingPart = bpart; pendingSince = now
                        elseif now - pendingSince >= (Save.silent_switch_delay or 0.05) then
                            cp, cpart = pendingTarget, pendingPart
                            State.target, State.target_part = cp, cpart
                            pendingTarget, pendingPart = nil, nil
                            lost = 0
                        end
                    else
                        cp, cpart = bp, bpart
                        State.target, State.target_part = cp, cpart
                        pendingTarget, pendingPart = nil, nil
                        lost = 0
                    end
                else
                    if cp then
                        if lost == 0 then
                            lost = now
                        else
                            local grace = (Mode.rage and (Save.rage_reacquire or 0.2)) or T.forget
                            if now - lost >= grace then
                                cp, cpart = nil, nil
                                State.target, State.target_part = nil, nil
                                lost = 0
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function encodeCF(cf)
    if M.Utility and type(M.Utility.EncodeCFrame) == "function" then
        local ok, r = pcall(M.Utility.EncodeCFrame, M.Utility, cf)
        if ok then return r end
    end
    return cf
end

local shotOff = encodeCF(CFrame.new(0.43, 0.25, 0.42))
local k0, k1, k2, k3 = utf8.char(0), utf8.char(1), utf8.char(2), utf8.char(3)

local function predictPosition(part)
    local vel = part.AssemblyLinearVelocity
    local ping = LP:GetNetworkPing() or 0
    local lead = Save.silent_prediction or 0
    if lead > 0 and vel.Magnitude > 1 then
        return part.Position + vel * (ping + lead)
    end
    return part.Position
end

local function buildPayload(origin, targetPos, part)
    local aim = encodeCF(CFrame.new(origin, targetPos))
    return {[k0] = aim, [k1] = aim, [k2] = part, [k3] = shotOff}
end

if M.Gun and type(M.Gun.StartShooting) == "function" then
    local orig = M.Gun.StartShooting
    M.Gun.StartShooting = function(self, ...)
        State.last_shot_t = os.clock()
        local results = table.pack(orig(self, ...))
        if not (results[1] == true and results[2] == "StartShooting") then
            return unpack(results, 1, results.n)
        end
        if not (Save.silent or Mode.rage) then return unpack(results, 1, results.n) end
        if not self.ClientFighter or not self.ClientFighter.IsLocalPlayer then
            return unpack(results, 1, results.n)
        end
        if not State.target_part then return unpack(results, 1, results.n) end
        local root = State.LocalChar and State.LocalChar.PrimaryPart
        if not root then return unpack(results, 1, results.n) end
        local aimPos = predictPosition(State.target_part)
        if Mode.rage then
            local from = (State.server_cf or root.CFrame).Position
            results[3] = buildPayload(from, aimPos, State.target_part)
            return unpack(results, 1, results.n)
        end
        if rand(1, 100) > Mode.silent_chance then
            return unpack(results, 1, results.n)
        end
        results[3] = buildPayload(root.Position, aimPos, State.target_part)
        return unpack(results, 1, results.n)
    end
end

task.spawn(function()
    local last = 0
    RunService.Heartbeat:Connect(function()
        if Mode.trigger and State.target_part and not State.is_reloading and M.MechanicsController then
            local now = os.clock()
            if now - last >= Mode.trigger_delay / 1000 then
                last = now
                pcall(function() M.MechanicsController:EquippedItemInput("StartShooting") end)
            end
        end
    end)
end)

local RageState = {
    void_phase = false, last_switch = 0,
    active = false, last_action = 0,
    shoot_pending = false, shoot_ready_at = 0,
    last_valid_target_t = 0,
}

local function hasAmmo(item)
    if not item or type(item.Get) ~= "function" then return false end
    local ok1, a = pcall(function() return item:Get("Ammo") end)
    local ok2, r = pcall(function() return item:Get("AmmoReserve") end)
    return (ok1 and a or 0) > 0 or (ok2 and r or 0) > 0
end
local function equipBest()
    if not M.FighterController then return end
    local f = M.FighterController:GetFighter(LP)
    if not f or not f.Items then return end
    local slot
    if hasAmmo(f.Items[1]) then slot = 1 elseif hasAmmo(f.Items[2]) then slot = 2 end
    if slot and f.Items[slot] and not f.Items[slot].IsEquipped then
        pcall(function() f:EquipItem(slot) end)
    end
end
local function getShootCd()
    if not M.FighterController then return 0.02 end
    local f = M.FighterController:GetFighter(LP)
    local info = f and f.EquippedItem and f.EquippedItem.Info
    if info and type(info.ShootCooldown) == "number" then
        return max(0.001, info.ShootCooldown)
    end
    return 0.02
end
local function editServerCF(force)
    local root = State.LocalChar and State.LocalChar.PrimaryPart
    if not root or not root.Parent then return end
    local tgt = State.target_part
    if not tgt then return end
    local tcf = tgt.CFrame * CFrame.new(0, 0, 2)
    if not Mode.rage_void then
        State.server_cf = tcf
        return
    end
    if force then RageState.void_phase = true
    else
        local now = tick()
        local dur = RageState.void_phase and Mode.rage_hide or Mode.rage_attack
        if now - RageState.last_switch >= dur then
            RageState.void_phase = not RageState.void_phase
            RageState.last_switch = now
        end
    end
    if RageState.void_phase then
        local pos = tcf.Position
        local far = Vector3.new(rand(-10000, 10000), -999999999, rand(-10000, 10000))
        State.server_cf = CFrame.new(far) * (tcf - pos)
    else State.server_cf = tcf end
end

RunService.RenderStepped:Connect(function()
    if not Mode.rage then
        if RageState.active then
            RageState.active = false
            RageState.shoot_pending = false
            State.server_cf_sync = true
            if M.MechanicsController then
                pcall(function() M.MechanicsController:EquippedItemInput("FinishShooting") end)
            end
        end
    else
        local root = State.LocalChar and State.LocalChar.PrimaryPart
        if root then
            if Save.rage_auto_equip then equipBest() end
            local tgt = State.target_part
            local has_target = tgt and tgt.Parent and tgt:IsA("BasePart")
            if has_target then RageState.last_valid_target_t = os.clock() end
            local grace = Save.rage_reacquire or 0.2
            local recently_had_target = (os.clock() - RageState.last_valid_target_t) < grace
            if not has_target and not recently_had_target then
                RageState.shoot_pending = false
                RageState.shoot_ready_at = 0
                if M.MechanicsController then
                    pcall(function() M.MechanicsController:EquippedItemInput("FinishShooting") end)
                end
                if Mode.rage_void then
                    State.server_cf_sync = false
                    editServerCF(true)
                else State.server_cf_sync = true end
            elseif State.is_reloading then
                RageState.shoot_pending = false
            else
                State.server_cf_sync = false
                editServerCF()
                RageState.active = true
                local now = os.clock()
                if not RageState.void_phase then
                    if not RageState.shoot_pending then
                        if now - RageState.last_action >= getShootCd() then
                            RageState.shoot_ready_at = now + max(0.02, LP:GetNetworkPing())
                            RageState.shoot_pending = true
                        end
                    elseif now >= RageState.shoot_ready_at then
                        RageState.last_action = now
                        RageState.shoot_pending = false
                        if M.MechanicsController then
                            pcall(function() M.MechanicsController:EquippedItemInput("StartShooting") end)
                        end
                    end
                end
            end
        end
    end
end)

local Peek = {
    enabled = Save.peek_enabled, mode = Save.peek_mode,
    duration = Save.peek_duration, hold = Save.peek_hold_time,
}
local function getHumanoid()
    local char = State.LocalChar
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end
local function setWalkSpeed(v)
    local hum = getHumanoid()
    if hum then
        if State.peek_orig_speed == nil then State.peek_orig_speed = hum.WalkSpeed end
        hum.WalkSpeed = v
    end
end
local function restoreSpeed()
    local hum = getHumanoid()
    if hum and State.peek_orig_speed ~= nil then hum.WalkSpeed = State.peek_orig_speed end
end
local function startPeek(mode)
    if State.peek_active then return end
    State.peek_active = true
    State.peek_start = os.clock()
    State.peek_phase = "out"
    State.peek_released = false
    Peek.mode = mode or Save.peek_mode
end
local function stopPeek()
    if not State.peek_active then return end
    State.peek_active = false
    State.peek_phase = "idle"
    restoreSpeed()
end

RunService.Heartbeat:Connect(function(dt)
    if not Peek.enabled then
        if State.peek_active then stopPeek() end
        return
    end
    if not State.peek_active then
        if Save.peek_auto and State.target_part then
            local has_target = State.target_part.Parent ~= nil
            if has_target and not State.is_reloading then
                startPeek(Save.peek_mode)
            end
        end
        return
    end
    local now = os.clock()
    local elapsed = now - State.peek_start
    local hum, root = getHumanoid()
    if not hum or not root then stopPeek(); return end
    if Peek.mode == "duck" then
        if elapsed < Peek.duration then
            setWalkSpeed(Save.peek_crouch_speed or 6)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        elseif elapsed < Peek.duration + Peek.hold then
            setWalkSpeed(Save.peek_crouch_speed or 6)
        else stopPeek() end
    elseif Peek.mode == "jump" then
        if elapsed < 0.05 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        elseif elapsed < Peek.duration then
            if Save.peek_shoot_on_peak and State.target_part and not State.is_reloading then
                if M.MechanicsController then
                    pcall(function() M.MechanicsController:EquippedItemInput("StartShooting") end)
                end
            end
        else stopPeek() end
    elseif Peek.mode == "strafe" then
        local cam = WS.CurrentCamera
        if cam then
            local right = cam.CFrame.RightVector
            local flat = Vector3.new(right.X, 0, right.Z)
            if flat.Magnitude > 0 then flat = flat.Unit end
            local dir = (floor(elapsed / Peek.duration) % 2 == 0) and 1 or -1
            root.CFrame = root.CFrame + flat * dir * (Save.peek_strafe_dist or 8) * dt
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * Vector3.new(0, 1, 0)
        end
        if Save.peek_shoot_on_peak and State.target_part and not State.is_reloading then
            if M.MechanicsController then
                pcall(function() M.MechanicsController:EquippedItemInput("StartShooting") end)
            end
        end
        if elapsed > Peek.duration * 3 then stopPeek() end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not Peek.enabled then return end
    if input.KeyCode == Save.peek_key then startPeek(Save.peek_mode) end
end)
UIS.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if not Peek.enabled then return end
    if input.KeyCode == Save.peek_key then
        if Peek.mode == "duck" or Peek.mode == "strafe" then stopPeek() end
    end
end)

local HvH = { enabled = Save.hvh_enabled, autodetect = Save.hvh_autodetect, suspects = {}, lastCheck = 0 }
local function analyzePlayer(p)
    if not p or p == LP then return 0 end
    local score = 0
    local char = p.Character
    if not char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return 0 end
    local head = char:FindFirstChild("Head")
    if head and State.LocalChar and State.LocalChar.PrimaryPart then
        local myPos = State.LocalChar.PrimaryPart.Position
        local toMe = (myPos - head.Position).Unit
        local look = head.CFrame.LookVector
        local dot = look:Dot(toMe)
        local prev = Hitsound.prevHp[p] or hum.Health
        if dot < -0.2 and (prev - hum.Health) > 5 then score = score + 2 end
    end
    if root.AssemblyLinearVelocity.Magnitude > 500 then score = score + 1 end
    local now = tick()
    if not HvH.suspects[p] then
        HvH.suspects[p] = {lastCF = root.CFrame, lastTime = now, rotAccum = 0, spinScore = 0}
    else
        local s = HvH.suspects[p]
        local dt = now - s.lastTime
        if dt > 0 and dt < 1 then
            local diff = (root.CFrame * s.lastCF:Inverse()).Y
            local rotRate = abs(math.deg(diff)) / dt
            if rotRate > 720 then
                s.spinScore = min(3, s.spinScore + 1)
                score = score + 1
            else s.spinScore = max(0, s.spinScore - 0.5) end
        end
        s.lastCF = root.CFrame
        s.lastTime = now
    end
    return score
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Save.hvh_enabled and Save.hvh_autodetect then
            local totalSuspicion = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP then
                    local s = analyzePlayer(p)
                    if s >= (Save.hvh_detect_threshold or 3) then
                        if not HvH.suspects[p] or not HvH.suspects[p].flagged then
                            HvH.suspects[p] = HvH.suspects[p] or {}
                            HvH.suspects[p].flagged = true
                        end
                        totalSuspicion = totalSuspicion + 1
                    end
                end
            end
            State.hvh_flag = totalSuspicion > 0
        else
            State.hvh_flag = false
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if Save.hvh_enabled and Save.hvh_counter_aa and State.hvh_flag then
            AART.jitter = 40
            AART.speed = 30
            if AART.mode ~= "Jitter" and AART.mode ~= "Spin" then
                AART.mode = "Jitter"
            end
        end
    end
end)

local Move = {
    walk = Save.walk, walkMult = Save.walk_mult, slide = Save.slide, slideMult = Save.slide_mult,
    jump = Save.jump, jumpMult = Save.jump_mult, flight = Save.flight, flightSpeed = Save.flight_speed,
    noclip = Save.noclip, bypassNoclip = Save.bypass_noclip, bypassSpeed = Save.strafe_speed,
}
local MoveState = {
    walkHooked = false, jumpHooked = false, flight = nil,
    noclipChar = nil, noclipParts = {}, noclipConns = nil, noclipActive = false,
}
local function attemptWalkHook()
    if MoveState.walkHooked then return end
    local mech = M.MechanicsController
    if type(mech) ~= "table" then return end
    local mt = getmetatable(mech)
    local idx = mt and rawget(mt, "__index")
    if type(idx) ~= "table" then return end
    local getter = rawget(idx, "_GetWalkSpeed")
    if type(getter) ~= "function" then return end
    local ui, ov
    for i, v in pairs(debug.getupvalues(getter)) do
        if type(v) == "table" and rawget(v, "BASE_WALKSPEED") ~= nil then ui, ov = i, v; break end
    end
    if ui == nil then return end
    debug.setupvalue(getter, ui, setmetatable({}, {
        __index = function(_, k)
            if k ~= "BASE_WALKSPEED" then return nil end
            local base = rawget(ov, "BASE_WALKSPEED")
            if Move.slide then return base * Move.slideMult end
            if Move.walk then return base * Move.walkMult end
            return base
        end,
    }))
    MoveState.walkHooked = true
end
local function replaceConsts(target)
    for i, v in pairs(debug.getupvalues(target)) do
        if type(v) == "table" then
            local orig = rawget(v, "BASE_JUMPPOWER")
            if orig ~= nil then
                local idx = i
                debug.setupvalue(target, idx, setmetatable({}, {
                    __index = function(_, k)
                        if k == "BASE_JUMPPOWER" then
                            local jp = rawget(v, "BASE_JUMPPOWER")
                            if Move.jump then return jp * Move.jumpMult end
                            return jp
                        end
                        return rawget(v, k)
                    end,
                }))
                MoveState.jumpHooked = true
                return
            end
        end
    end
end
local function attemptJumpHook()
    if MoveState.jumpHooked then return end
    local mech = M.MechanicsController
    if type(mech) ~= "table" then return end
    local mt = getmetatable(mech)
    local idx = mt and rawget(mt, "__index")
    if type(idx) ~= "table" then return end
    local hf = rawget(idx, "_HookFighter")
    if type(hf) == "function" then replaceConsts(hf) end
end
local function updateNoclip(active)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local alive = char and hum and hum.Health > 0
    if not alive then
        if MoveState.noclipConns then
            for _, c in ipairs(MoveState.noclipConns) do pcall(function() c:Disconnect() end) end
        end
        MoveState.noclipConns, MoveState.noclipChar = nil, nil
        table.clear(MoveState.noclipParts)
    elseif MoveState.noclipChar ~= char then
        if MoveState.noclipConns then
            for _, c in ipairs(MoveState.noclipConns) do pcall(function() c:Disconnect() end) end
        end
        MoveState.noclipChar = char
        table.clear(MoveState.noclipParts)
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") and d.CanCollide then MoveState.noclipParts[d] = true end
        end
        MoveState.noclipConns = {
            char.DescendantAdded:Connect(function(d)
                if d:IsA("BasePart") and d.CanCollide then MoveState.noclipParts[d] = true end
            end),
            char.DescendantRemoving:Connect(function(d)
                if d:IsA("BasePart") then MoveState.noclipParts[d] = nil end
            end),
        }
    end
    if MoveState.noclipActive and not active then
        for p in pairs(MoveState.noclipParts) do pcall(function() p.CanCollide = true end) end
    end
    MoveState.noclipActive = active == true and alive
    if MoveState.noclipActive then
        for p in pairs(MoveState.noclipParts) do pcall(function() p.CanCollide = false end) end
    end
end
local function updateFlight(active)
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not active or not root or not hum or hum.Health <= 0 then
        if MoveState.flight then
            pcall(function() MoveState.flight.V:Destroy() end)
            pcall(function() MoveState.flight.A:Destroy() end)
            MoveState.flight = nil
        end
        return
    end
    local cam = WS.CurrentCamera
    if not cam then return end
    local dir = Vector3.zero
    local cf = cam.CFrame
    if UIS.KeyboardEnabled then
        local look = cf.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0 then flat = flat.Unit end
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + flat end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - flat end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0, 1, 0)
        end
    end
    if dir.Magnitude > 0 then dir = dir.Unit end
    local vel = dir * Move.flightSpeed
    if MoveState.flight and MoveState.flight.R ~= root then
        pcall(function() MoveState.flight.V:Destroy() end)
        pcall(function() MoveState.flight.A:Destroy() end)
        MoveState.flight = nil
    end
    if not MoveState.flight then
        local a = Instance.new("Attachment"); a.Parent = root
        local v = Instance.new("LinearVelocity")
        v.RelativeTo = Enum.ActuatorRelativeTo.World
        v.MaxForce = math.huge
        v.VectorVelocity = vel
        v.Attachment0 = a
        v.Parent = root
        MoveState.flight = {R = root, A = a, V = v}
    else MoveState.flight.V.VectorVelocity = vel end
end
local function updateBypassNoclip(dt, active)
    if not active then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    if not UIS:IsKeyDown(Enum.KeyCode.Space) then return end
    local cam = WS.CurrentCamera
    if not cam then return end
    local look = cam.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude > 0 then flat = flat.Unit end
    local right = cam.CFrame.RightVector
    local flatR = Vector3.new(right.X, 0, right.Z)
    if flatR.Magnitude > 0 then flatR = flatR.Unit end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + flat end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - flat end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + flatR end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - flatR end
    if dir.Magnitude > 0 then dir = dir.Unit end
    root.CFrame = root.CFrame + dir * (Move.bypassSpeed / 100) * dt * 60
    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * Vector3.new(0, 1, 0)
end
local infJumpConn
local function updateInfJump(active)
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    if not active then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

RunService.PreSimulation:Connect(function(dt)
    if Move.walk or Move.slide then attemptWalkHook() end
    if Move.jump then attemptJumpHook() end
    updateNoclip(Move.noclip)
    updateFlight(Move.flight)
    updateBypassNoclip(dt, Move.bypassNoclip)
end)
updateInfJump(Save.infinite_jump)

local function applyThirdPerson()
    if Save.third_person then
        pcall(function()
            LP.CameraMode = Enum.CameraMode.Classic
            local d = Save.third_person_dist or 8
            LP.CameraMaxZoomDistance = d
            LP.CameraMinZoomDistance = d
        end)
    else
        pcall(function()
            LP.CameraMaxZoomDistance = 128
            LP.CameraMinZoomDistance = 0.5
        end)
    end
end
LP.CharacterAdded:Connect(function() task.wait(0.5); applyThirdPerson() end)
task.spawn(function() while true do task.wait(1); pcall(applyThirdPerson) end end)

local Skin = {fake_owned = {}, favorites = {}}
task.spawn(function()
    while not M.CosmeticLibrary do task.wait(0.5) end
    local function wrapOwn(fname)
        if type(M.CosmeticLibrary[fname]) ~= "function" then return end
        local orig = M.CosmeticLibrary[fname]
        M.CosmeticLibrary[fname] = function(self, inv, name, ...)
            if type(name) == "string" and Skin.fake_owned[name] then return true end
            return orig(self, inv, name, ...)
        end
    end
    for _, fname in ipairs({"OwnsCosmeticNormally","OwnsCosmeticUniversally","OwnsCosmeticForSomething","OwnsCosmeticForWeapon","OwnsCosmetic"}) do
        wrapOwn(fname)
    end
end)
task.spawn(function()
    while not M.PlayerDataController do task.wait(0.5) end
    if type(M.PlayerDataController.Get) ~= "function" then return end
    local orig = M.PlayerDataController.Get
    M.PlayerDataController.Get = function(self, key, ...)
        if key == "CosmeticInventory" then
            local merged = {}
            local inv = orig(self, key, ...)
            if type(inv) == "table" then
                for k, v in pairs(inv) do merged[k] = v end
            end
            for k, v in pairs(Skin.fake_owned) do merged[k] = v end
            return merged
        end
        if key == "FavoritedCosmetics" then return Skin.favorites end
        return orig(self, key, ...)
    end
end)
local function skinUnlockAll()
    if not (M.CosmeticLibrary and M.CosmeticLibrary.Cosmetics) then return 0 end
    local n = 0
    for name in pairs(M.CosmeticLibrary.Cosmetics) do
        if type(name) == "string" and not name:find("MISSING_") then
            Skin.fake_owned[name] = true
            n = n + 1
        end
    end
    return n
end
local function skinUnlockCategory(t)
    if not (M.CosmeticLibrary and M.CosmeticLibrary.Cosmetics) then return 0 end
    local count = 0
    for name, data in pairs(M.CosmeticLibrary.Cosmetics) do
        if type(name) == "string" and type(data) == "table"
        and not name:find("MISSING_") and data.Type == t then
            Skin.fake_owned[name] = true
            count = count + 1
        end
    end
    return count
end
local function skinUnlockRarity(r)
    if not (M.CosmeticLibrary and M.CosmeticLibrary.Cosmetics) then return 0 end
    local count = 0
    for name, data in pairs(M.CosmeticLibrary.Cosmetics) do
        if type(name) == "string" and type(data) == "table"
        and not name:find("MISSING_") and data.Rarity == r then
            Skin.fake_owned[name] = true
            count = count + 1
        end
    end
    return count
end

local Spoof = {
    device = ({"Desktop","Mobile","Console","VR"})[Save.device_idx or 1] or "Desktop",
    spoof_device = Save.spoof_device, display_name = Save.display_name,
    username = Save.username, spoof_name = Save.spoof_name,
    spoof_username = Save.spoof_username,
    elo = Save.spoof_elo, streak = Save.spoof_streak, level = Save.spoof_level,
}
local SetControls = findChild(RS, "Remotes", "Replication", "Fighter", "SetControls")
task.spawn(function()
    local last = ""
    while true do
        task.wait(0.5)
        if Spoof.spoof_device and SetControls then
            local d = ({Desktop="MouseKeyboard", Mobile="Touch", Console="Gamepad", VR="VR"})[Spoof.device] or "MouseKeyboard"
            if d ~= last then last = d; pcall(function() SetControls:FireServer(d) end) end
        else last = "" end
    end
end)
task.spawn(function()
    while true do
        RunService.RenderStepped:Wait()
        if Spoof.spoof_name or Spoof.spoof_username then
            local char = LP.Character
            if char then
                for _, d in ipairs(char:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        if Spoof.spoof_name and Spoof.display_name ~= "" and d.Text == LP.DisplayName then
                            d.Text = Spoof.display_name
                        elseif Spoof.spoof_username and Spoof.username ~= "" and d.Text == LP.Name then
                            d.Text = Spoof.username
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Spoof.elo > 0 then pcall(function() LP:SetAttribute("DisplayELO", Spoof.elo) end) end
        if Spoof.streak > 0 then pcall(function() LP:SetAttribute("StatisticDuelsWinStreak", Spoof.streak) end) end
        if Spoof.level > 0 then pcall(function() LP:SetAttribute("Level", Spoof.level) end) end
    end
end)

local AnimSets = {
    Default = {idle="rbxassetid://507766388", walk="rbxassetid://10921541949", run="rbxassetid://10899968825", jump="rbxassetid://507765000", fall="rbxassetid://507767968", climb="rbxassetid://507765644"},
    Zombie  = {idle="rbxassetid://10921344533", walk="rbxassetid://10921355261", run="rbxassetid://616163682", jump="rbxassetid://10921351278", fall="rbxassetid://10921350320", climb="rbxassetid://10921343576"},
    Ninja   = {idle="rbxassetid://10921155160", walk="rbxassetid://10921162768", run="rbxassetid://10921157929", jump="rbxassetid://10921160088", fall="rbxassetid://10921159222", climb="rbxassetid://10921154678"},
    Vampire = {idle="rbxassetid://10921315373", walk="rbxassetid://10921326949", run="rbxassetid://10921320299", jump="rbxassetid://10921322186", fall="rbxassetid://10921321317", climb="rbxassetid://10921314188"},
    Knight  = {idle="rbxassetid://10921117521", walk="rbxassetid://10921127095", run="rbxassetid://10921121197", jump="rbxassetid://10921123517", fall="rbxassetid://10921122579", climb="rbxassetid://10921116196"},
    Pirate  = {idle="rbxassetid://750781874", walk="rbxassetid://750785693", run="rbxassetid://750783738", jump="rbxassetid://750782230", fall="rbxassetid://750780242", climb="rbxassetid://750779899"},
}
local animList = {"Default","Zombie","Ninja","Vampire","Knight","Pirate"}
local currentAnim = Save.anim or "Default"
local lastAnim = nil
RunService.Heartbeat:Connect(function()
    local c = LP.Character
    local a = c and c:FindFirstChild("Animate")
    if a then
        local set = AnimSets[currentAnim]
        if set ~= lastAnim then
            lastAnim = set
            local function s(folder, name, id)
                local f = a:FindFirstChild(folder)
                local x = f and f:FindFirstChild(name)
                if x and x:IsA("Animation") and x.AnimationId ~= id then x.AnimationId = id end
            end
            s("idle","Animation1",set.idle)
            s("idle","Animation2",set.idle)
            s("walk","WalkAnim",set.walk)
            s("run","RunAnim",set.run)
            s("jump","JumpAnim",set.jump)
            s("fall","FallAnim",set.fall)
            s("climb","ClimbAnim",set.climb)
        end
    end
end)

local World = {
    weatherPart = nil, weatherEmitter = nil, weatherType = nil,
    atmosphere = nil, bloom = nil, cc = nil, dof = nil,
    originalFogEnd = Lighting.FogEnd,
    originalFogStart = Lighting.FogStart,
    originalFogColor = Lighting.FogColor,
    savedAtmosphere = nil,
}
local WEATHER_TEXTURES = {
    snow = "rbxassetid://6035047409", rain = "rbxassetid://241876428",
    leaves = "rbxassetid://6024549781", fireflies = "rbxassetid://6273552278",
}
local function cleanupWeather()
    if World.weatherPart then pcall(function() World.weatherPart:Destroy() end) end
    World.weatherPart = nil
    World.weatherEmitter = nil
    World.weatherType = nil
end
local function makeWeather(kind)
    cleanupWeather()
    if not kind or kind == "none" then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(500, 500, 500)
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.CastShadow = false
    part.Name = "RBE_Weather"
    part.Parent = WS
    local pe = Instance.new("ParticleEmitter")
    pe.Texture = WEATHER_TEXTURES[kind] or WEATHER_TEXTURES.snow
    pe.Rate = Save.weather_density or 200
    pe.Lifetime = NumberRange.new(3, 6)
    pe.SpreadAngle = Vector2.new(30, 30)
    pe.Rotation = NumberRange.new(0, 360)
    pe.RotSpeed = NumberRange.new(-30, 30)
    pe.LightEmission = 0.4
    pe.Enabled = true
    if kind == "snow" then
        pe.Speed = NumberRange.new(Save.weather_speed or 15, (Save.weather_speed or 15) + 10)
        pe.Acceleration = Vector3.new(0, -10, 0)
        pe.Size = NumberSequence.new(1.2)
        pe.Color = ColorSequence.new(Color3.new(1, 1, 1))
    elseif kind == "rain" then
        pe.Speed = NumberRange.new(Save.weather_speed or 15, (Save.weather_speed or 15) + 20)
        pe.Acceleration = Vector3.new(0, -80, 0)
        pe.Size = NumberSequence.new(0.3)
        pe.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
        pe.SpreadAngle = Vector2.new(5, 5)
    elseif kind == "leaves" then
        pe.Speed = NumberRange.new(Save.weather_speed or 15, (Save.weather_speed or 15) + 8)
        pe.Acceleration = Vector3.new(0, -5, 0)
        pe.Size = NumberSequence.new(0.8)
        pe.Color = ColorSequence.new(Color3.fromRGB(180, 100, 40))
    elseif kind == "fireflies" then
        pe.Speed = NumberRange.new(1, 5)
        pe.Acceleration = Vector3.new(0, 1, 0)
        pe.Size = NumberSequence.new(0.5)
        pe.Color = ColorSequence.new(Color3.fromRGB(255, 240, 120))
        pe.LightEmission = 1
    end
    pe.Parent = part
    World.weatherPart = part
    World.weatherEmitter = pe
    World.weatherType = kind
    task.spawn(function()
        while World.weatherPart and World.weatherPart.Parent do
            if CAM then World.weatherPart.CFrame = CAM.CFrame * CFrame.new(0, 30, 0) end
            RunService.RenderStepped:Wait()
        end
    end)
end
local function syncWorld()
    if Save.fog_enabled then
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then
            if not World.savedAtmosphere then World.savedAtmosphere = atm end
            atm.Parent = nil
        end
        Lighting.FogEnd = Save.fog_end
        Lighting.FogStart = Save.fog_start
        Lighting.FogColor = Color3.fromRGB(Save.fog_color_r, Save.fog_color_g, Save.fog_color_b)
    else
        Lighting.FogEnd = World.originalFogEnd
        Lighting.FogStart = World.originalFogStart
        Lighting.FogColor = World.originalFogColor
        if World.savedAtmosphere and not World.savedAtmosphere.Parent then
            World.savedAtmosphere.Parent = Lighting
            World.savedAtmosphere = nil
        end
    end
    Lighting.ClockTime = Save.time_of_day
    if Save.bloom_enabled then
        if not World.bloom then World.bloom = Instance.new("BloomEffect"); World.bloom.Parent = Lighting end
        World.bloom.Intensity = Save.bloom_intensity
        World.bloom.Size = Save.bloom_size
        World.bloom.Threshold = Save.bloom_threshold
    elseif World.bloom then
        pcall(function() World.bloom:Destroy() end)
        World.bloom = nil
    end
    if Save.cc_enabled then
        if not World.cc then World.cc = Instance.new("ColorCorrectionEffect"); World.cc.Parent = Lighting end
        World.cc.Brightness = Save.cc_brightness
        World.cc.Contrast = Save.cc_contrast
        World.cc.Saturation = Save.cc_saturation
    elseif World.cc then
        pcall(function() World.cc:Destroy() end)
        World.cc = nil
    end
    if Save.dof_enabled then
        if not World.dof then World.dof = Instance.new("DepthOfFieldEffect"); World.dof.Parent = Lighting end
        World.dof.FarIntensity = Save.dof_far / 100
        World.dof.FocusDistance = Save.dof_focus
        World.dof.NearIntensity = Save.dof_near / 100
    elseif World.dof then
        pcall(function() World.dof:Destroy() end)
        World.dof = nil
    end
    if CAM then CAM.FieldOfView = Save.fov_value end
end
local function setWeatherFromSave()
    local kind = nil
    if Save.weather_snow then kind = "snow"
    elseif Save.weather_rain then kind = "rain"
    elseif Save.weather_leaves then kind = "leaves"
    elseif Save.weather_fireflies then kind = "fireflies" end
    if kind ~= World.weatherType then makeWeather(kind)
    elseif World.weatherEmitter then World.weatherEmitter.Rate = Save.weather_density end
end

local Spotify = { active = false, currentTrack = nil, progress = 0, duration = 0, lastFetch = 0 }
local function fetchSpotify()
    if not Save.spotify_enabled then return end
    if Save.spotify_discord_id == "" then return end
    local now = os.clock()
    if now - Spotify.lastFetch < 1 then return end
    Spotify.lastFetch = now
    task.spawn(function()
        local ok, resp = pcall(function()
            return game:HttpGet("https://api.lanyard.rest/v1/users/" .. Save.spotify_discord_id)
        end)
        if ok and resp then
            local ok2, data = pcall(function() return HttpService:JSONDecode(resp) end)
            if ok2 and data and data.success then
                local sp = data.data and data.data.spotify
                if sp then
                    Spotify.active = true
                    Spotify.currentTrack = { song = sp.song or "Unknown", artist = sp.artist or "Unknown" }
                    if sp.timestamps then
                        local nowMs = os.time() * 1000
                        local startMs = sp.timestamps.start or nowMs
                        local endMs = sp.timestamps["end"] or (startMs + 180000)
                        Spotify.duration = (endMs - startMs) / 1000
                        Spotify.progress = clamp((nowMs - startMs) / 1000, 0, Spotify.duration)
                    end
                else Spotify.active = false end
            else Spotify.active = false end
        else Spotify.active = false end
    end)
end

-- ═══════ UI BASE ═══════
local UIAPI = {}

local function initUI()
    local O = {
        bg=Color3.fromRGB(8,8,12), bgTop=Color3.fromRGB(12,12,18), bgTab=Color3.fromRGB(10,10,15),
        surface=Color3.fromRGB(16,16,24), surface2=Color3.fromRGB(21,21,30), surface3=Color3.fromRGB(28,28,40),
        surfaceHi=Color3.fromRGB(38,38,52), border=Color3.fromRGB(28,28,40), borderHi=Color3.fromRGB(44,44,60),
        divider=Color3.fromRGB(22,22,32), text=Color3.fromRGB(220,220,235), textHi=Color3.fromRGB(248,248,255),
        textLo=Color3.fromRGB(150,150,175), textDim=Color3.fromRGB(90,90,115),
        good=Color3.fromRGB(72,210,132), bad=Color3.fromRGB(240,82,108), warn=Color3.fromRGB(245,188,96),
    }
    O.accent     = Color3.fromRGB(Save.ui_accent_r, Save.ui_accent_g, Save.ui_accent_b)
    O.accentSoft = Color3.fromRGB(min(255, Save.ui_accent_r + 50), min(255, Save.ui_accent_g + 50), min(255, Save.ui_accent_b + 50))
    O.accentDeep = Color3.fromRGB(max(0, Save.ui_accent_r - 70), max(0, Save.ui_accent_g - 70), max(0, Save.ui_accent_b - 70))

    local function New(class, props)
        local inst = Instance.new(class)
        for k, v in pairs(props or {}) do if k ~= "Parent" then inst[k] = v end end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end
    local function Corner(p, r) return New("UICorner", {CornerRadius = UDim.new(0, r or 3), Parent = p}) end
    local function Stroke(p, c, t, a)
        return New("UIStroke", {Color = c or O.border, Thickness = t or 1,
            Transparency = a or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p})
    end
    local function Pad(p, t, r, b, l)
        return New("UIPadding", {PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0),
            PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0), Parent = p})
    end
    local function Grad(p, c1, c2, rot)
        if typeof(c1) ~= "Color3" then c1 = O.accent end
        if typeof(c2) ~= "Color3" then c2 = O.accentSoft end
        local seq = ColorSequence.new({ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) })
        return New("UIGradient", {Color = seq, Rotation = rot or 0, Parent = p})
    end
    local function Tween(i, t, props, style, dir)
        local tw = TweenService:Create(i,
            TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
        tw:Play()
        return tw
    end

    local blurFx = Lighting:FindFirstChild("__RBE_Blur")
    if not blurFx then blurFx = New("BlurEffect", {Name = "__RBE_Blur", Size = 0, Parent = Lighting}) end

    local Screen = New("ScreenGui", {
        Name = "RBE_UI", ResetOnSpawn = false, IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 99999,
    })
    pcall(function() Screen.Parent = gethui() end)
    if not Screen.Parent then Screen.Parent = game:GetService("CoreGui") end
    getgenv().__RBE_UI = Screen

    task.spawn(function()
        while Screen and Screen.Parent do
            task.wait(0.5)
            pcall(setWeatherFromSave); pcall(syncWorld)
        end
    end)
    task.spawn(function()
        while Screen and Screen.Parent do task.wait(1); pcall(fetchSpotify) end
    end)

    local FloatLayer = New("Frame", {Name="FloatLayer", Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, ZIndex=9998, Parent=Screen})
    local openPopups = {}
    local function closeAllPopups(except)
        for popup, closeFn in pairs(openPopups) do
            if popup ~= except then closeFn() end
        end
    end
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not input.Position then return end
        local mx, my = input.Position.X, input.Position.Y
        for popup, closeFn in pairs(openPopups) do
            local p, sz = popup.AbsolutePosition, popup.AbsoluteSize
            local inside = mx >= p.X and mx <= p.X + sz.X and my >= p.Y and my <= p.Y + sz.Y
            if not inside then closeFn() end
        end
    end)

    local function makeDraggable(frame, dragArea, locked, onMove, onEnd)
        local dragging = false
        local dragStart, startPos
        local shadow
        dragArea.MouseButton1Down:Connect(function()
            if locked and locked() then return end
            dragging = true
            local mp = UIS:GetMouseLocation()
            dragStart = Vector2.new(mp.X, mp.Y)
            local ap = frame.AbsolutePosition
            startPos = Vector2.new(ap.X, ap.Y)
            if Save.drag_shadow then
                shadow = New("Frame", {Size = UDim2.new(1, 12, 1, 12),
                    Position = UDim2.new(0, -6, 0, -6),
                    BackgroundColor3 = O.accent, BackgroundTransparency = 0.75,
                    BorderSizePixel = 0, ZIndex = max(1, frame.ZIndex - 1), Parent = frame.Parent})
                Corner(shadow, 8)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                local mp = UIS:GetMouseLocation()
                local nx = startPos.X + (mp.X - dragStart.X)
                local ny = startPos.Y + (mp.Y - dragStart.Y)
                local vs = CAM.ViewportSize
                local fs = frame.AbsoluteSize
                if Save.drag_snap_grid and Save.drag_snap_grid > 0 then
                    local g = Save.drag_snap_grid
                    nx = floor(nx / g + 0.5) * g
                    ny = floor(ny / g + 0.5) * g
                end
                if Save.drag_magnetic then
                    local d = Save.drag_magnet_dist or 40
                    if abs(nx) < d then nx = 0 end
                    if abs(nx - (vs.X - fs.X)) < d then nx = vs.X - fs.X end
                    if abs(ny) < d then ny = 0 end
                    if abs(ny - (vs.Y - fs.Y)) < d then ny = vs.Y - fs.Y end
                end
                nx = clamp(nx, -fs.X + 40, vs.X - 40)
                ny = clamp(ny, 0, vs.Y - 20)
                frame.Position = UDim2.fromOffset(nx, ny)
                if shadow then shadow.Position = UDim2.new(0, -6, 0, -6) end
                if onMove then pcall(onMove, nx, ny) end
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch) and dragging then
                dragging = false
                if shadow then
                    local s = shadow; shadow = nil
                    Tween(s, 0.28, {BackgroundTransparency = 1})
                    task.delay(0.3, function() pcall(function() s:Destroy() end) end)
                end
                if onEnd then pcall(onEnd) end
            end
        end)
    end

    local NotifHolder = New("Frame", {Size=UDim2.new(0,280,1,-80),
        Position=UDim2.new(1,-296,0,40), BackgroundTransparency=1, ZIndex=8000, Parent=Screen})
    New("UIListLayout", {Padding=UDim.new(0,6),
        VerticalAlignment=Enum.VerticalAlignment.Top,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        SortOrder=Enum.SortOrder.LayoutOrder, Parent=NotifHolder})

    local function notify(title, body, kind)
        kind = kind or "info"
        playUISound(0.9, 1.15)
        local col = O.accent
        if kind == "success" then col = O.good end
        if kind == "error" then col = O.bad end
        if kind == "warn" then col = O.warn end
        local card = New("Frame", {Size=UDim2.fromOffset(260,54),
            Position=UDim2.new(1,300,0,0), BackgroundColor3=O.surface,
            BorderSizePixel=0, ClipsDescendants=true, ZIndex=8001, Parent=NotifHolder})
        Corner(card, 4)
        Stroke(card, col, 1, 0.5)
        New("Frame", {Size=UDim2.new(0,2,1,0), BackgroundColor3=col,
            BorderSizePixel=0, ZIndex=8002, Parent=card})
        New("TextLabel", {Size=UDim2.new(1,-22,0,16), Position=UDim2.fromOffset(14,8),
            BackgroundTransparency=1, Text=string.upper(title), TextColor3=O.textHi,
            Font=Enum.Font.GothamBold, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8003, Parent=card})
        New("TextLabel", {Size=UDim2.new(1,-22,0,14), Position=UDim2.fromOffset(14,24),
            BackgroundTransparency=1, Text=body or "", TextColor3=O.textLo,
            Font=Enum.Font.Gotham, TextSize=9, TextTruncate=Enum.TextTruncate.AtEnd,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8003, Parent=card})
        local prog = New("Frame", {Size=UDim2.new(1,0,0,1),
            Position=UDim2.new(0,0,1,-1), BackgroundColor3=col,
            BorderSizePixel=0, ZIndex=8003, Parent=card})
        Tween(card, 0.42, {Position=UDim2.new(0,0,0,0)}, Enum.EasingStyle.Quint)
        Tween(prog, 4, {Size=UDim2.new(0,0,0,1)}, Enum.EasingStyle.Linear)
        task.delay(4.15, function()
            Tween(card, 0.28, {Position=UDim2.new(1,300,0,0)}, Enum.EasingStyle.Quint)
            task.wait(0.32)
            card:Destroy()
        end)
    end

    local hitmarker = New("Frame", {Name = "Hitmarker", Size = UDim2.fromOffset(24, 24),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1, Visible = false, ZIndex = 8500, Parent = Screen})
    New("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255,80,80),
        BorderSizePixel = 0, Rotation = 45, ZIndex = 8501, Parent = hitmarker})
    New("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255,80,80),
        BorderSizePixel = 0, Rotation = -45, ZIndex = 8501, Parent = hitmarker})

    local function flashHitmarker()
        hitmarker.Visible = true
        hitmarker.Size = UDim2.fromOffset(28, 28)
        Tween(hitmarker, 0.08, {Size = UDim2.fromOffset(22, 22)})
        task.delay(0.14, function() hitmarker.Visible = false end)
    end
    getgenv().__RBE_HITMARKER = flashHitmarker

    local watermark = New("Frame", {Name = "Watermark",
        Size = UDim2.fromOffset(440 * (Save.watermark_scale or 1), 24 * (Save.watermark_scale or 1)),
        Position = UDim2.fromOffset(Save.watermark_x or 16, Save.watermark_y or 16),
        BackgroundColor3 = Color3.fromRGB(10, 10, 14),
        BackgroundTransparency = 1 - (Save.watermark_opacity or 1) * 0.35,
        BorderSizePixel = 0, Visible = Save.watermark_enabled ~= false,
        ZIndex = 5000, Parent = Screen})
    Corner(watermark, 4)
    Stroke(watermark, O.accent, 1, 0.4)
    Grad(watermark, Color3.fromRGB(20, 20, 28), Color3.fromRGB(10, 10, 14), 90)
    local wmBar = New("Frame", {Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = O.accent, BorderSizePixel = 0, ZIndex = 5001, Parent = watermark})
    Corner(wmBar, 4); Grad(wmBar, O.accent, O.accentSoft, 90)
    New("TextLabel", {Size = UDim2.fromOffset(28, 24), Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1, Text = "[R]", TextColor3 = O.accent,
        Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5001, Parent = watermark})
    New("TextLabel", {Size = UDim2.fromOffset(56, 24), Position = UDim2.fromOffset(36, 0),
        BackgroundTransparency = 1, Text = "ezzzz", TextColor3 = O.textHi,
        Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5001, Parent = watermark})
    New("Frame", {Size = UDim2.fromOffset(1, 14), Position = UDim2.fromOffset(96, 5),
        BackgroundColor3 = O.borderHi, BorderSizePixel = 0, ZIndex = 5001, Parent = watermark})
    local wmMain = New("TextLabel", {Size = UDim2.new(1, -120, 1, 0), Position = UDim2.fromOffset(104, 0),
        BackgroundTransparency = 1, Text = "loading...", TextColor3 = O.textLo,
        Font = Enum.Font.Code, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5001, Parent = watermark})
    local wmHvH = New("TextLabel", {Size = UDim2.fromOffset(56, 24), Position = UDim2.new(1, -62, 0, 0),
        BackgroundTransparency = 1, Text = "", TextColor3 = O.textDim,
        Font = Enum.Font.Code, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 5001, Parent = watermark})
    local fpsHistory = {}
    for i = 1, 60 do fpsHistory[i] = 0 end
    local fpsHistIdx = 1
    task.spawn(function()
        while watermark.Parent do
            local dt = RunService.RenderStepped:Wait()
            if watermark.Visible then
                local fps = floor(1 / max(dt, 1e-4))
                local ping = floor((LP:GetNetworkPing() or 0) * 1000)
                local enemies, cheaters = 0, 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local h = p.Character:FindFirstChildOfClass("Humanoid")
                        if h and h.Health > 0 then enemies = enemies + 1 end
                        if HvH.suspects[p] and HvH.suspects[p].flagged then cheaters = cheaters + 1 end
                    end
                end
                fpsHistory[fpsHistIdx] = fps
                fpsHistIdx = (fpsHistIdx % #fpsHistory) + 1
                local graph = ""
                for i = 1, #fpsHistory do
                    local idx = ((fpsHistIdx - 1 + i - 1) % #fpsHistory) + 1
                    local f = fpsHistory[idx]
                    if f == 0 then graph = graph .. " "
                    elseif f < 30 then graph = graph .. "_"
                    elseif f < 60 then graph = graph .. "-"
                    elseif f < 120 then graph = graph .. "="
                    else graph = graph .. "#" end
                end
                local tm = os.date("%H:%M:%S")
                local modeStr = "off"
                if Save.silent then modeStr = "silent" end
                if Save.rage then modeStr = "rage" end
                if Save.aa then modeStr = "aa" end
                wmMain.Text = string.format("  %s  |  %dfps  |  %dms  |  E:%d  |  %s  |  %s",
                    tm, fps, ping, enemies, modeStr, graph)
                if cheaters > 0 then
                    wmHvH.Text = "CH:" .. cheaters
                    wmHvH.TextColor3 = O.bad
                else
                    wmHvH.Text = "hvh"
                    wmHvH.TextColor3 = O.textDim
                end
            end
            task.wait(0.1)
        end
    end)
    do
        local wmDragBtn = New("TextButton", {Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, Text = "", ZIndex = 5002, Parent = watermark})
        makeDraggable(watermark, wmDragBtn,
            function() return Save.watermark_locked end,
            function(x, y) Save.watermark_x = x; Save.watermark_y = y end,
            function() persist() end)
    end

    local keybindPanel = New("Frame", {Name = "Keybinds",
        Size = UDim2.fromOffset(180 * (Save.keybinds_scale or 1), 100),
        Position = UDim2.fromOffset(Save.keybinds_x or 16, Save.keybinds_y or 60),
        BackgroundColor3 = Color3.fromRGB(12, 12, 16),
        BackgroundTransparency = 1 - (Save.keybinds_opacity or 1),
        BorderSizePixel = 0, Visible = Save.keybinds_enabled ~= false,
        ZIndex = 5000, Parent = Screen})
    Corner(keybindPanel, 4)
    Stroke(keybindPanel, Color3.fromRGB(40, 40, 55), 1, 0.3)
    New("TextLabel", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
        Text = "keybinds", TextColor3 = Color3.fromRGB(200, 200, 220),
        Font = Enum.Font.Code, TextSize = floor(11 * (Save.keybinds_scale or 1)),
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5001, Parent = keybindPanel})
    local kbs = {
        {name = "Peek", key = "E"},
        {name = "Anti-aim", key = "on"},
        {name = "Rage", key = "on"},
    }
    local yOff = 20
    for _, kb in ipairs(kbs) do
        local row = New("Frame", {Size = UDim2.new(1, -8, 0, 16),
            Position = UDim2.fromOffset(4, yOff), BackgroundTransparency = 1,
            ZIndex = 5001, Parent = keybindPanel})
        New("TextLabel", {Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1,
            Text = kb.name, TextColor3 = Color3.fromRGB(180, 180, 200),
            Font = Enum.Font.Code, TextSize = floor(10 * (Save.keybinds_scale or 1)),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5002, Parent = row})
        New("TextLabel", {Size = UDim2.new(0.3, 0, 1, 0), BackgroundTransparency = 1,
            Text = kb.key, TextColor3 = Color3.fromRGB(100, 220, 140),
            Font = Enum.Font.Code, TextSize = floor(10 * (Save.keybinds_scale or 1)),
            TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 5002, Parent = row})
        yOff = yOff + 18
    end
    keybindPanel.Size = UDim2.fromOffset(180 * (Save.keybinds_scale or 1), yOff + 6)
    do
        local kbDragBtn = New("TextButton", {Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1, Text = "", ZIndex = 5003, Parent = keybindPanel})
        makeDraggable(keybindPanel, kbDragBtn,
            function() return Save.keybinds_locked end,
            function(x, y) Save.keybinds_x = x; Save.keybinds_y = y end,
            function() persist() end)
    end

    local spWidget = New("Frame", {Size = UDim2.fromOffset(340, 60),
        Position = UDim2.new(0.5, -170, 1, -80), BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0, Visible = false, ZIndex = 7000, Parent = Screen})
    Corner(spWidget, 6); Stroke(spWidget, Color3.fromRGB(40, 40, 40), 1, 0)
    New("Frame", {Size=UDim2.fromOffset(48,48), Position=UDim2.fromOffset(6,6),
        BackgroundColor3=Color3.fromRGB(35,35,35), BorderSizePixel=0, ZIndex=7001, Parent=spWidget})
    local spSong = New("TextLabel", {Size=UDim2.fromOffset(240,16), Position=UDim2.fromOffset(64,8),
        BackgroundTransparency=1, Text="Not playing", TextColor3=Color3.fromRGB(255,255,255),
        Font=Enum.Font.GothamBold, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=7001, Parent=spWidget})
    local spArtist = New("TextLabel", {Size=UDim2.fromOffset(240,14), Position=UDim2.fromOffset(64,24),
        BackgroundTransparency=1, Text="", TextColor3=Color3.fromRGB(150,150,150),
        Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=7001, Parent=spWidget})
    local spTime = New("TextLabel", {Size=UDim2.fromOffset(100,12), Position=UDim2.fromOffset(64,40),
        BackgroundTransparency=1, Text="0:00", TextColor3=Color3.fromRGB(120,120,120),
        Font=Enum.Font.Gotham, TextSize=9, ZIndex=7001, Parent=spWidget})
    local spTotal = New("TextLabel", {Size=UDim2.fromOffset(60,12), Position=UDim2.new(1,-68,0,40),
        BackgroundTransparency=1, Text="0:00", TextColor3=Color3.fromRGB(120,120,120),
        Font=Enum.Font.Gotham, TextSize=9, TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=7001, Parent=spWidget})
    local spBarBg = New("Frame", {Size=UDim2.fromOffset(200,3), Position=UDim2.fromOffset(64,52),
        BackgroundColor3=Color3.fromRGB(60,60,60), BorderSizePixel=0, ZIndex=7001, Parent=spWidget})
    Corner(spBarBg, 2)
    local spBarFill = New("Frame", {Size=UDim2.fromScale(0,1),
        BackgroundColor3=Color3.fromRGB(30,215,96), BorderSizePixel=0, ZIndex=7002, Parent=spBarBg})
    Corner(spBarFill, 2)
    task.spawn(function()
        while spWidget.Parent do
            RunService.RenderStepped:Wait()
            spWidget.Visible = Save.spotify_enabled
            if Spotify.active and Spotify.currentTrack then
                spSong.Text = Spotify.currentTrack.song
                spArtist.Text = Spotify.currentTrack.artist
                local function fmt(s) s = floor(max(s, 0)); return string.format("%d:%02d", floor(s / 60), s % 60) end
                spTime.Text = fmt(Spotify.progress)
                spTotal.Text = fmt(Spotify.duration)
                spBarFill.Size = UDim2.fromScale(clamp(Spotify.duration > 0 and Spotify.progress / Spotify.duration or 0, 0, 1), 1)
            else
                spSong.Text = "Not playing"; spArtist.Text = ""
                spBarFill.Size = UDim2.fromScale(0, 1)
            end
            task.wait(0.25)
        end
    end)
    do
        local spDrag = New("TextButton", {Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1, Text = "", ZIndex = 7010, Parent = spWidget})
        makeDraggable(spWidget, spDrag, nil, nil, nil)
    end

    local initW = max(760, Save.ui_w or 800)
    local initH = max(440, Save.ui_h or 540)
    local TOP_H, TAB_H, BOT_H = 30, 32, 22

    local W = New("Frame", {Name = "Window", Size = UDim2.fromOffset(initW, initH),
        Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = O.bg, BorderSizePixel = 0, Active = true,
        ClipsDescendants = true, ZIndex = 5, Parent = Screen})
    Corner(W, 6); Stroke(W, O.borderHi, 1, 0.35); Grad(W, O.bgTop, O.bg, 90)

    local topLine = New("Frame", {Size=UDim2.new(1,0,0,1), BackgroundColor3=O.accent,
        BorderSizePixel=0, ZIndex=7, Parent=W})
    Grad(topLine, O.accentDeep, O.accentSoft, 0)
    task.spawn(function()
        local t = 0
        while topLine.Parent do
            t = t + 0.03
            topLine.BackgroundTransparency = 0.15 + 0.4 * abs(sin(t))
            RunService.RenderStepped:Wait()
        end
    end)

    local topBar = New("Frame", {Size=UDim2.new(1,0,0,TOP_H), Position=UDim2.fromOffset(0,1),
        BackgroundColor3=O.bgTop, BorderSizePixel=0, ZIndex=6, Parent=W})
    New("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=O.divider, BorderSizePixel=0, ZIndex=7, Parent=topBar})
    local logo = New("Frame", {Size=UDim2.fromOffset(16,16), Position=UDim2.fromOffset(10,7),
        BackgroundColor3=O.accent, BorderSizePixel=0, ZIndex=8, Parent=topBar})
    Corner(logo, 3); Grad(logo, O.accentSoft, O.accent, 45)
    New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="R",
        TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBlack, TextSize=10, ZIndex=9, Parent=logo})
    New("TextLabel", {Size=UDim2.fromOffset(200,TOP_H), Position=UDim2.fromOffset(32,0),
        BackgroundTransparency=1, Text="roblox ezzzz", TextColor3=O.textHi,
        Font=Enum.Font.GothamBold, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8, Parent=topBar})
    New("TextLabel", {Size=UDim2.fromOffset(280,TOP_H), Position=UDim2.new(1,-320,0,0),
        BackgroundTransparency=1, Text=LP.DisplayName .. "  |  " .. LP.Name,
        TextColor3=O.textLo, Font=Enum.Font.Gotham, TextSize=9,
        TextTruncate=Enum.TextTruncate.AtEnd,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=8, Parent=topBar})

    local function ctrlBtn(txt, xOff, col, cb)
        local b = New("TextButton", {Size=UDim2.fromOffset(16,16),
            Position=UDim2.new(1,xOff,0,7), BackgroundColor3=O.surface2,
            BorderSizePixel=0, Text=txt, TextColor3=O.textLo,
            Font=Enum.Font.GothamBold, TextSize=10,
            AutoButtonColor=false, ZIndex=8, Parent=topBar})
        Corner(b, 3)
        b.MouseEnter:Connect(function()
            Tween(b, 0.14, {BackgroundColor3=col, TextColor3=Color3.new(1,1,1)}, Enum.EasingStyle.Back)
        end)
        b.MouseLeave:Connect(function()
            Tween(b, 0.14, {BackgroundColor3=O.surface2, TextColor3=O.textLo})
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end
    ctrlBtn("-", -24, O.warn, function() W.Visible = false end)
    ctrlBtn("X", -44, O.bad, function()
        persist()
        pcall(restoreWeaponMods)
        cleanupWeather()
        if World.bloom then pcall(function() World.bloom:Destroy() end) end
        if World.cc then pcall(function() World.cc:Destroy() end) end
        if World.dof then pcall(function() World.dof:Destroy() end) end
        if World.atmosphere then pcall(function() World.atmosphere:Destroy() end) end
        if World.savedAtmosphere and not World.savedAtmosphere.Parent then
            World.savedAtmosphere.Parent = Lighting
        end
        for _, d in ipairs(espAllDrawings) do pcall(function() d:Remove() end) end
        for p, _ in pairs(espObjects) do espDestroy(p) end
        if infJumpConn then infJumpConn:Disconnect() end
        for _, c in ipairs(hitsoundConns) do pcall(function() c:Disconnect() end) end
        for _, snd in ipairs(hitPool) do pcall(function() snd:Destroy() end) end
        for _, snd in ipairs(uiPool) do pcall(function() snd:Destroy() end) end
        pcall(function() deathSound:Destroy() end)
        getgenv().__RBE_LOADED = nil
        getgenv().__RBE_HITMARKER = nil
        pcall(function() blurFx.Size = 0 end)
        pcall(function()
            Lighting.FogEnd = World.originalFogEnd
            Lighting.FogStart = World.originalFogStart
            Lighting.FogColor = World.originalFogColor
        end)
        Screen:Destroy()
    end)

    local tabBar = New("Frame", {Size=UDim2.new(1,0,0,TAB_H),
        Position=UDim2.fromOffset(0,TOP_H+1), BackgroundColor3=O.bgTab,
        BorderSizePixel=0, ZIndex=6, Parent=W})
    New("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=O.divider, BorderSizePixel=0, ZIndex=7, Parent=tabBar})
    local tabRow = New("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        ZIndex=7, Parent=tabBar})
    New("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabRow})
    local tabUnderline = New("Frame", {Size=UDim2.new(0,0,0,2),
        Position=UDim2.new(0,0,1,-2), BackgroundColor3=O.accent,
        BorderSizePixel=0, ZIndex=8, Parent=tabBar})
    Corner(tabUnderline, 2); Grad(tabUnderline, O.accentDeep, O.accentSoft, 0)

    local content = New("Frame", {Size=UDim2.new(1,0,1,-(TOP_H+TAB_H+BOT_H+2)),
        Position=UDim2.fromOffset(0,TOP_H+TAB_H+1), BackgroundTransparency=1,
        ZIndex=6, Parent=W})

    local bottomBar = New("Frame", {Size=UDim2.new(1,0,0,BOT_H),
        Position=UDim2.new(0,0,1,-BOT_H), BackgroundColor3=O.bgTop,
        BorderSizePixel=0, ZIndex=6, Parent=W})
    New("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,0),
        BackgroundColor3=O.divider, BorderSizePixel=0, ZIndex=7, Parent=bottomBar})
    local statusL = New("TextLabel", {Size=UDim2.new(0.5,0,1,0), Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, Text="ready", TextColor3=O.textDim,
        Font=Enum.Font.Gotham, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8, Parent=bottomBar})
    local statusR = New("TextLabel", {Size=UDim2.new(0.5,-10,1,0), Position=UDim2.new(0.5,0,0,0),
        BackgroundTransparency=1, Text="obsidian v4.2", TextColor3=O.textDim,
        Font=Enum.Font.GothamMedium, TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=8, Parent=bottomBar})
    task.spawn(function()
        while Screen.Parent do
            local dt = RunService.RenderStepped:Wait()
            local fps = floor(1 / max(dt, 1e-4))
            local ping = floor((LP:GetNetworkPing() or 0) * 1000)
            statusR.Text = string.format("obsidian v4.2 | %d fps | %d ms", fps, ping)
            task.wait(0.4)
        end
    end)

    local Tabs, ActiveTab = {}, nil
    local tabBtns = {}
    local function updateUnderline()
        if not ActiveTab then return end
        local b = tabBtns[ActiveTab]
        if not b then return end
        local tabAbs, btnAbs = tabBar.AbsolutePosition, b.btn.AbsolutePosition
        if tabAbs.X == 0 and tabAbs.Y == 0 then return end
        Tween(tabUnderline, 0.32, {Position = UDim2.fromOffset(btnAbs.X - tabAbs.X, TAB_H - 2),
            Size = UDim2.new(0, b.btn.AbsoluteSize.X, 0, 2)}, Enum.EasingStyle.Quart)
    end
    local function updateUnderlineInstant()
        if not ActiveTab then return end
        local b = tabBtns[ActiveTab]
        if not b then return end
        local tabAbs, btnAbs = tabBar.AbsolutePosition, b.btn.AbsolutePosition
        if tabAbs.X == 0 and tabAbs.Y == 0 then return end
        tabUnderline.Position = UDim2.fromOffset(btnAbs.X - tabAbs.X, TAB_H - 2)
        tabUnderline.Size = UDim2.new(0, b.btn.AbsoluteSize.X, 0, 2)
    end
    local function switchTab(name)
        if ActiveTab ~= name then
            ActiveTab = name
            for n, t in pairs(Tabs) do t.wrapper.Visible = (n == name) end
            for n, b in pairs(tabBtns) do Tween(b.label, 0.2, {TextColor3=(n==name) and O.textHi or O.textDim}) end
            updateUnderline()
            statusL.Text = name .. " | loaded"
        end
    end
    local function newTab(name)
        if Tabs[name] then return Tabs[name] end
        local btn = New("TextButton", {Size=UDim2.fromOffset(66,TAB_H-4),
            BackgroundTransparency=1, Text="", AutoButtonColor=false, ZIndex=8, Parent=tabRow})
        local label = New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Text=name, TextColor3=O.textDim, Font=Enum.Font.GothamMedium,
            TextSize=11, ZIndex=9, Parent=btn})
        btn.MouseEnter:Connect(function()
            if ActiveTab ~= name then Tween(label, 0.15, {TextColor3=O.textLo}) end
        end)
        btn.MouseLeave:Connect(function()
            if ActiveTab ~= name then Tween(label, 0.15, {TextColor3=O.textDim}) end
        end)
        btn.MouseButton1Click:Connect(function() switchTab(name); playUISound(1.0, 1.2) end)
        tabBtns[name] = {btn=btn, label=label}
        local wrapper = New("Frame", {Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1, Visible=false, ZIndex=5, Parent=content})
        local lCol = New("ScrollingFrame", {Size=UDim2.new(0.5,-1,1,0),
            BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3,
            ScrollBarImageColor3=O.borderHi, CanvasSize=UDim2.new(0,0,0,3000), ZIndex=6, Parent=wrapper})
        local lList = New("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=lCol})
        Pad(lCol, 8, 0, 8, 8)
        lList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            lCol.CanvasSize = UDim2.new(0,0,0,lList.AbsoluteContentSize.Y + 16)
        end)
        New("Frame", {Size=UDim2.new(0,1,1,0), Position=UDim2.new(0.5,-0.5,0,0),
            BackgroundColor3=O.divider, BorderSizePixel=0, ZIndex=7, Parent=wrapper})
        local rCol = New("ScrollingFrame", {Size=UDim2.new(0.5,-1,1,0),
            Position=UDim2.new(0.5,0,0,0), BackgroundTransparency=1, BorderSizePixel=0,
            ScrollBarThickness=3, ScrollBarImageColor3=O.borderHi,
            CanvasSize=UDim2.new(0,0,0,3000), ZIndex=6, Parent=wrapper})
        local rList = New("UIListLayout", {Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder, Parent=rCol})
        Pad(rCol, 8, 8, 8, 0)
        rList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rCol.CanvasSize = UDim2.new(0,0,0,rList.AbsoluteContentSize.Y + 16)
        end)
        Tabs[name] = {wrapper=wrapper, left=lCol, right=rCol}
        if not ActiveTab then
            ActiveTab = name
            wrapper.Visible = true
            label.TextColor3 = O.textHi
        end
        return Tabs[name]
    end

    local function section(parent, title)
        local wrap = New("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,
            AutomaticSize=Enum.AutomaticSize.Y, ZIndex=7, Parent=parent})
        New("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=wrap})
        New("Frame", {Size=UDim2.new(1,0,0,1), BackgroundColor3=O.divider,
            BorderSizePixel=0, LayoutOrder=1, ZIndex=8, Parent=wrap})
        local head = New("Frame", {Size=UDim2.new(1,0,0,16),
            BackgroundTransparency=1, LayoutOrder=2, ZIndex=8, Parent=wrap})
        New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Text=title, TextColor3=O.textLo, Font=Enum.Font.GothamMedium,
            TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=9, Parent=head})
        Pad(head, 0, 0, 0, 2)
        local body = New("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1,
            AutomaticSize=Enum.AutomaticSize.Y, LayoutOrder=3, ZIndex=8, Parent=wrap})
        New("UIListLayout", {Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.LayoutOrder, Parent=body})
        return {frame=wrap, body=body}
    end

    local function checkbox(parent, label, initial, cb)
        local row = New("Frame", {Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, ZIndex=9, Parent=parent})
        local box = New("TextButton", {Size=UDim2.fromOffset(12,12), Position=UDim2.fromOffset(2,5),
            BackgroundColor3=initial and O.accent or O.surface2,
            BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=11, Parent=row})
        Corner(box, 2)
        local boxStroke = Stroke(box, initial and O.accent or O.borderHi, 1, 0)
        local check = New("Frame", {Size = initial and UDim2.fromOffset(4,4) or UDim2.fromOffset(0,0),
            Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0, ZIndex=12, Parent=box})
        Corner(check, 1)
        local lbl = New("TextLabel", {Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(22,0),
            BackgroundTransparency=1, Text=label, TextColor3=O.text,
            Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=11, Parent=row})
        local state = initial and true or false
        local function refresh()
            Tween(box, 0.24, {BackgroundColor3=state and O.accent or O.surface2})
            Tween(boxStroke, 0.24, {Color=state and O.accent or O.borderHi})
            Tween(check, 0.24, {Size=state and UDim2.fromOffset(4,4) or UDim2.fromOffset(0,0)}, Enum.EasingStyle.Back)
            Tween(lbl, 0.24, {TextColor3=state and O.textHi or O.text})
        end
        box.MouseButton1Click:Connect(function()
            state = not state; refresh(); playUISound(0.85, 1.25)
            if cb then pcall(cb, state) end
        end)
        return {set=function(v) state=v and true or false; refresh() end, get=function() return state end}
    end

    local function slider(parent, label, mn, mx, default, cb)
        local wrap = New("Frame", {Size=UDim2.new(1,0,0,28), BackgroundTransparency=1, ZIndex=9, Parent=parent})
        New("TextLabel", {Size=UDim2.new(0.6,0,0,12), Position=UDim2.fromOffset(2,2),
            BackgroundTransparency=1, Text=label, TextColor3=O.textLo,
            Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=11, Parent=wrap})
        local val = New("TextLabel", {Size=UDim2.new(0.4,-4,0,12), Position=UDim2.new(0.6,0,0,2),
            BackgroundTransparency=1, Text=tostring(default), TextColor3=O.accent,
            Font=Enum.Font.GothamMedium, TextSize=10, TextXAlignment=Enum.TextXAlignment.Right,
            ZIndex=11, Parent=wrap})
        local bar = New("Frame", {Size=UDim2.new(1,-4,0,3), Position=UDim2.new(0,2,0,20),
            BackgroundColor3=O.surface2, BorderSizePixel=0, ZIndex=11, Parent=wrap})
        Corner(bar, 2)
        local fill = New("Frame", {Size=UDim2.fromScale((default-mn)/max(mx-mn,1e-6),1),
            BackgroundColor3=O.accent, BorderSizePixel=0, ZIndex=12, Parent=bar})
        Corner(fill, 2); Grad(fill, O.accentDeep, O.accentSoft, 0)
        local thumb = New("Frame", {Size=UDim2.fromOffset(9,9),
            AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(fill.Size.X.Scale,0,0.5,0),
            BackgroundColor3=O.accent, BorderSizePixel=0, ZIndex=13, Parent=bar})
        Corner(thumb, 99)
        local clickArea = New("TextButton", {Size=UDim2.new(1,0,1,12),
            Position=UDim2.new(0,0,0,-4), BackgroundTransparency=1, Text="", ZIndex=14, Parent=bar})
        local dragging = false
        local function applyFromX(x)
            local p = clamp((x - bar.AbsolutePosition.X) / max(bar.AbsoluteSize.X, 1), 0, 1)
            local v = mn + (mx - mn) * p
            local st = (mx - mn < 1) and 0.001 or ((mx - mn < 100) and 0.01 or 1)
            v = floor(v / st + 0.5) * st
            fill.Size = UDim2.fromScale((v-mn)/(mx-mn),1)
            thumb.Position = UDim2.new(fill.Size.X.Scale,0,0.5,0)
            val.Text = tostring(v)
            if cb then pcall(cb, v) end
        end
        clickArea.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; applyFromX(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then applyFromX(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        return {get=function() return default end}
    end

    local function button(parent, text, cb, accent)
        local b = New("TextButton", {Size=UDim2.new(1,0,0,24),
            BackgroundColor3=accent and O.accent or O.surface2,
            BorderSizePixel=0, Text=text, TextColor3=accent and Color3.new(1,1,1) or O.text,
            Font=Enum.Font.GothamMedium, TextSize=10, AutoButtonColor=false, ZIndex=11, Parent=parent})
        Corner(b, 3)
        if accent then Grad(b, O.accent, O.accentDeep, 0) end
        b.MouseEnter:Connect(function()
            Tween(b, 0.15, accent and {BackgroundColor3=O.accentSoft} or {BackgroundColor3=O.surfaceHi})
        end)
        b.MouseLeave:Connect(function()
            Tween(b, 0.2, accent and {BackgroundColor3=O.accent} or {BackgroundColor3=O.surface2})
        end)
        b.MouseButton1Click:Connect(function()
            playUISound(0.95, 1.15)
            if cb then pcall(cb) end
        end)
        return b
    end

    local function input(parent, placeholder, default, cb)
        local wrap = New("Frame", {Size=UDim2.new(1,0,0,22),
            BackgroundColor3=O.surface2, BorderSizePixel=0, ZIndex=10, Parent=parent})
        Corner(wrap, 3)
        local stroke = Stroke(wrap, O.borderHi, 1, 0.4)
        local t = New("TextBox", {Size=UDim2.new(1,-14,1,0), Position=UDim2.fromOffset(7,0),
            BackgroundTransparency=1, PlaceholderText=placeholder, Text=default or "",
            TextColor3=O.text, PlaceholderColor3=O.textDim,
            Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
            ClearTextOnFocus=false, ZIndex=11, Parent=wrap})
        t.Focused:Connect(function() Tween(stroke, 0.15, {Color=O.accent, Transparency=0}) end)
        t.FocusLost:Connect(function()
            Tween(stroke, 0.15, {Color=O.borderHi, Transparency=0.4})
            if cb then pcall(cb, t.Text) end
        end)
        return t
    end

    local function dropdown(parent, label, items, default, cb)
        local row = New("Frame", {Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, ZIndex=9, Parent=parent})
        New("TextLabel", {Size=UDim2.new(0.5,0,1,0), Position=UDim2.fromOffset(2,0),
            BackgroundTransparency=1, Text=label, TextColor3=O.text,
            Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=11, Parent=row})
        local vB = New("TextButton", {Size=UDim2.new(0.4,-4,0,18),
            Position=UDim2.new(0.5,0,0.5,-9), BackgroundColor3=O.surface2,
            BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=11, Parent=row})
        Corner(vB, 3); Stroke(vB, O.borderHi, 1, 0.4)
        local vText = New("TextLabel", {Size=UDim2.new(1,-16,1,0), Position=UDim2.fromOffset(6,0),
            BackgroundTransparency=1, Text=tostring(default or items[1] or ""), TextColor3=O.accent,
            Font=Enum.Font.GothamMedium, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=12, Parent=vB})
        local popup = New("Frame", {Size=UDim2.fromOffset(160,0), BackgroundColor3=O.surface,
            BorderSizePixel=0, Visible=false, AutomaticSize=Enum.AutomaticSize.Y,
            ClipsDescendants=false, ZIndex=9999, Parent=FloatLayer})
        Corner(popup, 4); Stroke(popup, O.borderHi, 1, 0.2); Pad(popup, 4, 4, 4, 4)
        New("UIListLayout", {Padding=UDim.new(0,1), Parent=popup})
        local closeFn
        local itemRows = {}
        local cur = default or items[1]
        local function setSelected(newItem)
            cur = newItem
            vText.Text = tostring(newItem)
            for item, r in pairs(itemRows) do
                if item == newItem then r.check.Visible = true; r.label.TextColor3 = O.accent
                else r.check.Visible = false; r.label.TextColor3 = O.text end
            end
        end
        for _, item in ipairs(items) do
            local ob = New("TextButton", {Size=UDim2.new(1,0,0,20), BackgroundColor3=O.surface,
                BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=10000, Parent=popup})
            Corner(ob, 3)
            local obLabel = New("TextLabel", {Size=UDim2.new(1,-22,1,0), Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1, Text=tostring(item), TextColor3=O.text,
                Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=10001, Parent=ob})
            local obCheck = New("TextLabel", {Size=UDim2.fromOffset(16,20), Position=UDim2.new(1,-18,0,0),
                BackgroundTransparency=1, Text="v", TextColor3=O.accent, Font=Enum.Font.GothamBold,
                TextSize=11, ZIndex=10001, Parent=ob, Visible=(item == cur)})
            itemRows[item] = {row=ob, label=obLabel, check=obCheck}
            if item == cur then obLabel.TextColor3 = O.accent end
            ob.MouseButton1Click:Connect(function()
                setSelected(item); playUISound(1.0, 1.2)
                if cb then pcall(cb, item) end
                if closeFn then closeFn() end
            end)
        end
        local function open()
            closeAllPopups()
            local p, s = vB.AbsolutePosition, vB.AbsoluteSize
            popup.Position = UDim2.fromOffset(p.X, p.Y + s.Y + 2)
            popup.Size = UDim2.fromOffset(max(s.X, 140), 0)
            popup.Visible = true
            openPopups[popup] = closeFn
        end
        closeFn = function() popup.Visible = false; openPopups[popup] = nil end
        vB.MouseButton1Click:Connect(function() if popup.Visible then closeFn() else open() end end)
        return {get=function() return cur end, set=function(v) setSelected(v); if cb then pcall(cb,v) end end}
    end

    local function colorSwatch(parent, label, initR, initG, initB, cb)
        local PALETTE = {
            Color3.fromRGB(168,85,247), Color3.fromRGB(255,45,120), Color3.fromRGB(255,90,90),
            Color3.fromRGB(255,150,60), Color3.fromRGB(245,188,96), Color3.fromRGB(240,220,100),
            Color3.fromRGB(130,220,130), Color3.fromRGB(72,210,132), Color3.fromRGB(80,200,240),
            Color3.fromRGB(90,130,255), Color3.fromRGB(150,90,255), Color3.fromRGB(230,230,240),
            Color3.fromRGB(120,120,140), Color3.fromRGB(30,30,40),
        }
        local row = New("Frame", {Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, ZIndex=9, Parent=parent})
        New("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.fromOffset(2,0),
            BackgroundTransparency=1, Text=label, TextColor3=O.text,
            Font=Enum.Font.Gotham, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=11, Parent=row})
        local sw = New("TextButton", {Size=UDim2.fromOffset(38,14), Position=UDim2.new(1,-40,0.5,-7),
            BackgroundColor3=Color3.fromRGB(initR,initG,initB), BorderSizePixel=0, Text="",
            AutoButtonColor=false, ZIndex=11, Parent=row})
        Corner(sw, 3)
        local popup = New("Frame", {Size=UDim2.fromOffset(220,250), BackgroundColor3=O.surface,
            BorderSizePixel=0, Visible=false, ZIndex=9999, Parent=FloatLayer})
        Corner(popup, 4); Stroke(popup, O.borderHi, 1, 0.2); Pad(popup, 8, 8, 8, 8)
        New("UIListLayout", {Padding=UDim.new(0,6), Parent=popup})
        local palWrap = New("Frame", {Size=UDim2.new(1,0,0,44),
            BackgroundTransparency=1, LayoutOrder=1, ZIndex=10, Parent=popup})
        New("UIGridLayout", {CellSize=UDim2.fromOffset(22,22), CellPadding=UDim2.fromOffset(2,2),
            SortOrder=Enum.SortOrder.LayoutOrder, Parent=palWrap})
        local curR, curG, curB = initR, initG, initB
        local tempR, tempG, tempB = initR, initG, initB
        for _, col in ipairs(PALETTE) do
            local pb = New("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundColor3=col,
                BorderSizePixel=0, Text="", AutoButtonColor=false, ZIndex=11, Parent=palWrap})
            Corner(pb, 2)
            pb.MouseButton1Click:Connect(function()
                tempR = floor(col.R * 255); tempG = floor(col.G * 255); tempB = floor(col.B * 255)
                sw.BackgroundColor3 = Color3.fromRGB(tempR, tempG, tempB)
            end)
        end
        local hexLbl = New("TextLabel", {Size=UDim2.new(1,0,0,16), BackgroundTransparency=1,
            Text=string.format("#%02X%02X%02X", initR, initG, initB),
            TextColor3=O.textHi, Font=Enum.Font.GothamBold, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=2, ZIndex=11, Parent=popup})
        local function updateHex()
            hexLbl.Text = string.format("#%02X%02X%02X", tempR, tempG, tempB)
            sw.BackgroundColor3 = Color3.fromRGB(tempR, tempG, tempB)
        end
        slider(popup, "R", 0, 255, initR, function(v) tempR=floor(v); updateHex() end)
        slider(popup, "G", 0, 255, initG, function(v) tempG=floor(v); updateHex() end)
        slider(popup, "B", 0, 255, initB, function(v) tempB=floor(v); updateHex() end)
        local confirmBtn = New("TextButton", {Size=UDim2.new(1,0,0,26), BackgroundColor3=O.accent,
            BorderSizePixel=0, Text="Confirm color selection", TextColor3=Color3.new(1,1,1),
            Font=Enum.Font.GothamBold, TextSize=9, AutoButtonColor=false,
            ZIndex=11, Parent=popup, LayoutOrder=10})
        Corner(confirmBtn, 3)
        confirmBtn.MouseButton1Click:Connect(function()
            curR, curG, curB = tempR, tempG, tempB
            sw.BackgroundColor3 = Color3.fromRGB(curR, curG, curB)
            playUISound(1.05, 1.25)
            if cb then pcall(cb, curR, curG, curB) end
            local close = openPopups[popup]
            if close then close() end
        end)
        local closeFn
        closeFn = function() popup.Visible = false; openPopups[popup] = nil end
        sw.MouseButton1Click:Connect(function()
            if popup.Visible then closeFn()
            else
                closeAllPopups()
                local p, s = sw.AbsolutePosition, sw.AbsoluteSize
                local x = p.X - 170
                if x < 4 then x = 4 end
                popup.Position = UDim2.fromOffset(x, p.Y + s.Y + 2)
                tempR, tempG, tempB = curR, curG, curB
                popup.Visible = true
                openPopups[popup] = closeFn
            end
        end)
        return {get=function() return curR, curG, curB end}
    end

    local function hint(parent, text, color)
        return New("TextLabel", {Size=UDim2.new(1,-4,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            Position=UDim2.fromOffset(2,0), BackgroundTransparency=1, Text=text,
            TextColor3=color or O.textDim, Font=Enum.Font.Gotham, TextSize=9,
            TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=10, Parent=parent})
    end

    local particleFrame = New("Frame", {Name="Particles", Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1, ZIndex=1, Parent=Screen})
    for i = 1, 42 do
        local sz = rand(1, 3)
        local isAccent = (i % 3 == 0)
        local dot = New("Frame", {Size=UDim2.fromOffset(sz,sz), Position=UDim2.fromScale(rand(), rand()),
            BackgroundColor3=isAccent and O.accentSoft or O.accent,
            BackgroundTransparency=rand(55,90)/100, BorderSizePixel=0, ZIndex=1,
            Visible=Save.ui_particles, Parent=particleFrame})
        Corner(dot, 99)
        task.spawn(function()
            while dot.Parent do
                local dur = rand(80, 220) / 10
                Tween(dot, dur, {Position=UDim2.fromScale(rand(),rand()),
                    BackgroundTransparency=rand(50,95)/100}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(dur + rand(0, 3))
            end
        end)
    end

    UIAPI.O = O
    UIAPI.New = New
    UIAPI.Corner = Corner
    UIAPI.Stroke = Stroke
    UIAPI.Pad = Pad
    UIAPI.Grad = Grad
    UIAPI.Tween = Tween
    UIAPI.Screen = Screen
    UIAPI.blurFx = blurFx
    UIAPI.W = W
    UIAPI.watermark = watermark
    UIAPI.keybindPanel = keybindPanel
    UIAPI.spWidget = spWidget
    UIAPI.particleFrame = particleFrame
    UIAPI.newTab = newTab
    UIAPI.section = section
    UIAPI.checkbox = checkbox
    UIAPI.slider = slider
    UIAPI.button = button
    UIAPI.input = input
    UIAPI.dropdown = dropdown
    UIAPI.colorSwatch = colorSwatch
    UIAPI.hint = hint
    UIAPI.notify = notify
    UIAPI.closeAllPopups = closeAllPopups
    UIAPI.makeDraggable = makeDraggable
    UIAPI.updateUnderline = updateUnderline
    UIAPI.updateUnderlineInstant = updateUnderlineInstant
    UIAPI.TOP_H = TOP_H
    UIAPI.TAB_H = TAB_H
    UIAPI.BOT_H = BOT_H
    UIAPI.initW = initW
    UIAPI.initH = initH
    UIAPI.Screen = Screen
    UIAPI.flashHitmarker = flashHitmarker

    return W
end

local W = initUI()

-- ═══════════ SETUP TABS & WINDOW (isolated scope — fixes register overflow) ═══════════
local function setupTabsAndWindow()
    local U = UIAPI

    local function tabAim()
        local TAB = U.newTab("aim")
        local s = U.section(TAB.left, "silent aim")
        U.checkbox(s.body, "enabled", Save.silent, function(v) Mode.silent = v; Save.silent = v; persist() end)
        U.checkbox(s.body, "triggerbot", Save.trigger, function(v) Mode.trigger = v; Save.trigger = v; persist() end)
        U.slider(s.body, "hit chance %", 1, 100, Save.silent_chance, function(v) Mode.silent_chance = v; Save.silent_chance = v; persist() end)
        U.slider(s.body, "trigger delay ms", 0, 200, Save.trigger_delay, function(v) Mode.trigger_delay = v; Save.trigger_delay = v; persist() end)
        U.slider(s.body, "velocity lead", 0, 0.5, Save.silent_prediction or 0, function(v) Save.silent_prediction = v; persist() end)
        U.slider(s.body, "fov radius", 30, 500, Save.fov, function(v) T.radius = v; Save.fov = v; persist() end)
        U.slider(s.body, "max distance", 50, 1000, Save.max_dist, function(v) T.max_distance = v; Save.max_dist = v; persist() end)
        U.checkbox(s.body, "wallcheck", Save.wallcheck, function(v) T.wallcheck = v; Aim.wallcheck = v; Save.wallcheck = v; persist() end)
        local s2 = U.section(TAB.right, "smart targeting")
        U.checkbox(s2.body, "multipoint", Save.silent_multipoint, function(v) Save.silent_multipoint = v; persist() end)
        U.slider(s2.body, "multi samples", 1, 8, Save.silent_multi_samples, function(v) Save.silent_multi_samples = floor(v); persist() end)
        U.checkbox(s2.body, "head bias", Save.silent_head_bias, function(v) Save.silent_head_bias = v; persist() end)
        U.dropdown(s2.body, "priority", {"fov","dist","hp","threat"}, Save.silent_priority or "fov", function(v) Save.silent_priority = v; persist() end)
        U.slider(s2.body, "switch delay s", 0.01, 0.5, Save.silent_switch_delay or 0.05, function(v) Save.silent_switch_delay = v; persist() end)
        U.hint(s2.body, "priority picks how target is scored. threat = velocity toward you", U.O.textDim)
        local s3 = U.section(TAB.right, "camera aim")
        U.checkbox(s3.body, "enabled", Save.aim, function(v) Aim.enabled = v; Save.aim = v; persist() end)
        U.slider(s3.body, "smoothness", 0.01, 1, Save.aim_smooth, function(v) Aim.smoothness = v; Save.aim_smooth = v; persist() end)
        U.checkbox(s3.body, "show fov circle", Save.fov_circle_enabled, function(v) Save.fov_circle_enabled = v; persist() end)
    end

    local function tabVis()
        local TAB = U.newTab("visuals")
        local s = U.section(TAB.left, "player esp")
        U.checkbox(s.body, "enabled", Save.esp, function(v) ESP.enabled = v; Save.esp = v; persist() end)
        U.checkbox(s.body, "box", Save.esp_box, function(v) ESP.box = v; Save.esp_box = v; persist() end)
        U.checkbox(s.body, "name", Save.esp_name, function(v) ESP.name = v; Save.esp_name = v; persist() end)
        U.checkbox(s.body, "health bar", Save.esp_hp, function(v) ESP.hp = v; Save.esp_hp = v; persist() end)
        U.checkbox(s.body, "skeleton", Save.esp_skeleton, function(v)
            ESP.skeleton = v; Save.esp_skeleton = v; persist()
            for _, o in pairs(espObjects) do o.bonePairs = {} end
        end)
        U.checkbox(s.body, "chams", Save.esp_chams, function(v) ESP.chams = v; Save.esp_chams = v; persist() end)
        U.checkbox(s.body, "distance", Save.esp_distance, function(v) ESP.distance = v; Save.esp_distance = v; persist() end)
        U.checkbox(s.body, "team check", not Save.esp_team, function(v) ESP.teamCheck = v; Save.esp_team = not v; persist() end)
        U.slider(s.body, "max distance", 100, 5000, Save.esp_max_dist, function(v) ESP.maxDistance = v; Save.esp_max_dist = v; persist() end)
        local s2 = U.section(TAB.left, "extras")
        U.checkbox(s2.body, "snapline", Save.esp_snapline, function(v) Save.esp_snapline = v; persist() end)
        U.checkbox(s2.body, "facing indicator", Save.esp_facing, function(v) Save.esp_facing = v; persist() end)
        U.checkbox(s2.body, "hitmarker (screen)", Save.esp_hitmarker, function(v) Save.esp_hitmarker = v; persist() end)
        local s3 = U.section(TAB.right, "colors")
        U.colorSwatch(s3.body, "box color", Save.esp_col_r, Save.esp_col_g, Save.esp_col_b, function(r, g, b)
            Save.esp_col_r, Save.esp_col_g, Save.esp_col_b = r, g, b
            ESP.boxColor = Color3.fromRGB(r, g, b)
            fovCircle.Color = ESP.boxColor
            persist()
        end)
        local s4 = U.section(TAB.right, "third person")
        U.checkbox(s4.body, "enabled", Save.third_person, function(v)
            Save.third_person = v; persist(); applyThirdPerson()
        end)
        U.slider(s4.body, "distance", 4, 20, Save.third_person_dist or 8, function(v)
            Save.third_person_dist = v; persist(); applyThirdPerson()
        end)
    end

    local function tabMove()
        local TAB = U.newTab("movement")
        local s = U.section(TAB.left, "jump")
        U.checkbox(s.body, "infinite double jump", Save.infinite_jump, function(v)
            RF.infinite_jump = v; Save.infinite_jump = v; persist()
            updateInfJump(v); syncWeaponMods()
        end)
        U.checkbox(s.body, "jump power", Save.jump, function(v) Move.jump = v; Save.jump = v; persist() end)
        U.slider(s.body, "jump multiplier", 0.1, 10, Save.jump_mult, function(v) Move.jumpMult = v; Save.jump_mult = v; persist() end)
        local s2 = U.section(TAB.left, "speed")
        U.checkbox(s2.body, "walk speed", Save.walk, function(v) Move.walk = v; Save.walk = v; persist() end)
        U.slider(s2.body, "walk mult", 1, 10, Save.walk_mult, function(v) Move.walkMult = v; Save.walk_mult = v; persist() end)
        U.checkbox(s2.body, "slide boost", Save.slide, function(v) Move.slide = v; Save.slide = v; persist() end)
        U.slider(s2.body, "slide mult", 1, 10, Save.slide_mult, function(v) Move.slideMult = v; Save.slide_mult = v; persist() end)
        local s3 = U.section(TAB.left, "bypass noclip")
        U.checkbox(s3.body, "enabled", Save.bypass_noclip, function(v) Move.bypassNoclip = v; Save.bypass_noclip = v; persist() end)
        U.slider(s3.body, "phase speed", 1, 200, Save.strafe_speed, function(v) Move.bypassSpeed = v; Save.strafe_speed = v; persist() end)
        U.hint(s3.body, "HOLD [SPACE] to phase through walls - 10% ban risk", U.O.warn)
        local s4 = U.section(TAB.right, "flight")
        U.checkbox(s4.body, "enabled", Save.flight, function(v) Move.flight = v; Save.flight = v; persist() end)
        U.slider(s4.body, "flight speed", 25, 500, Save.flight_speed, function(v) Move.flightSpeed = v; Save.flight_speed = v; persist() end)
        local s5 = U.section(TAB.right, "noclip")
        U.checkbox(s5.body, "noclip", Save.noclip, function(v) Move.noclip = v; Save.noclip = v; persist() end)
    end

    local function tabPeek()
        local TAB = U.newTab("peek")
        local s = U.section(TAB.left, "peek system")
        U.checkbox(s.body, "enabled", Save.peek_enabled, function(v) Peek.enabled = v; Save.peek_enabled = v; persist() end)
        U.dropdown(s.body, "mode", {"duck","jump","strafe"}, Save.peek_mode or "duck", function(v)
            Peek.mode = v; Save.peek_mode = v; persist()
        end)
        U.hint(s.body, "duck = crouch shoot / jump = jump peek / strafe = A-D-A", U.O.textDim)
        U.slider(s.body, "duration s", 0.1, 1.0, Save.peek_duration, function(v)
            Peek.duration = v; Save.peek_duration = v; persist()
        end)
        U.slider(s.body, "hold s", 0.05, 0.5, Save.peek_hold_time, function(v)
            Peek.hold = v; Save.peek_hold_time = v; persist()
        end)
        U.checkbox(s.body, "auto peek", Save.peek_auto, function(v) Save.peek_auto = v; persist() end)
        U.hint(s.body, "auto = peek when target visible", U.O.textDim)
        local s2 = U.section(TAB.right, "settings")
        U.slider(s2.body, "crouch speed", 2, 16, Save.peek_crouch_speed or 6, function(v) Save.peek_crouch_speed = v; persist() end)
        U.slider(s2.body, "strafe dist", 2, 30, Save.peek_strafe_dist or 8, function(v) Save.peek_strafe_dist = v; persist() end)
        U.checkbox(s2.body, "shoot on peak", Save.peek_shoot_on_peak, function(v) Save.peek_shoot_on_peak = v; persist() end)
        U.hint(s2.body, "manual trigger: hold E (or set key in config)", U.O.textDim)
    end

    local function tabRage()
        local TAB = U.newTab("rage")
        local s = U.section(TAB.left, "ragebot")
        U.checkbox(s.body, "enabled", Save.rage, function(v) Mode.rage = v; Save.rage = v; persist() end)
        U.checkbox(s.body, "void spam", Save.rage_void, function(v) Mode.rage_void = v; Save.rage_void = v; persist() end)
        U.checkbox(s.body, "auto equip best gun", Save.rage_auto_equip ~= false, function(v) Save.rage_auto_equip = v; persist() end)
        U.slider(s.body, "hide duration", 0.05, 2, Save.rage_hide, function(v) Mode.rage_hide = v; Save.rage_hide = v; persist() end)
        U.slider(s.body, "attack duration", 0.05, 2, Save.rage_attack, function(v) Mode.rage_attack = v; Save.rage_attack = v; persist() end)
        U.slider(s.body, "reacquire grace", 0.05, 1, Save.rage_reacquire or 0.2, function(v) Save.rage_reacquire = v; persist() end)
        U.dropdown(s.body, "hitbox", {"Head","UpperTorso","HumanoidRootPart"}, Save.rage_hitbox or "Head",
            function(v) Save.rage_hitbox = v; persist() end)
        local s2 = U.section(TAB.right, "anti-aim")
        U.checkbox(s2.body, "enabled", Save.aa, function(v) AART.enabled = v; Save.aa = v; persist() end)
        U.checkbox(s2.body, "underground", Save.aa_underground, function(v) AART.underground = v; Save.aa_underground = v; persist() end)
        U.dropdown(s2.body, "mode", {"Offset","Random","Spin","Jitter","Backwards"}, Save.aa_mode or "Offset",
            function(v) AART.mode = v; Save.aa_mode = v; persist() end)
        U.slider(s2.body, "pitch", -89, 89, Save.aa_pitch, function(v) AART.pitch_angle = v; Save.aa_pitch = v; persist() end)
        U.slider(s2.body, "yaw", -180, 180, Save.aa_yaw, function(v) AART.yaw_angle = v; Save.aa_yaw = v; persist() end)
        U.slider(s2.body, "jitter", 0, 180, Save.aa_jitter, function(v) AART.jitter = v; Save.aa_jitter = v; persist() end)
        U.slider(s2.body, "spin speed", 1, 100, Save.aa_speed, function(v) AART.speed = v; Save.aa_speed = v; persist() end)
        local s3 = U.section(TAB.right, "fakelag")
        U.slider(s3.body, "fakelag ms [RAGE ONLY]", 0, 300, Save.aa_fakelag or 0, function(v)
            Save.aa_fakelag = v; persist()
        end)
        U.hint(s3.body, "!! HIGH BAN RISK !! works only when RAGE enabled. sends stale CFrame to server.", U.O.bad)
        U.checkbox(s3.body, "underground during fl", Save.aa_underground, function(v)
            AART.underground = v; Save.aa_underground = v; persist()
        end)
    end

    local function tabHvH()
        local TAB = U.newTab("hvH")
        local s = U.section(TAB.left, "hvh system")
        U.checkbox(s.body, "enabled", Save.hvh_enabled, function(v) HvH.enabled = v; Save.hvh_enabled = v; persist() end)
        U.checkbox(s.body, "auto detect cheaters", Save.hvh_autodetect, function(v) Save.hvh_autodetect = v; persist() end)
        U.slider(s.body, "detect threshold", 1, 10, Save.hvh_detect_threshold or 3, function(v)
            Save.hvh_detect_threshold = floor(v); persist()
        end)
        U.hint(s.body, "score = suspicious rotation + spinbot + velocity", U.O.textDim)
        local s2 = U.section(TAB.right, "response")
        U.checkbox(s2.body, "counter anti-aim", Save.hvh_counter_aa, function(v) Save.hvh_counter_aa = v; persist() end)
        U.hint(s2.body, "forces strongest AA when cheater detected", U.O.textDim)
        U.checkbox(s2.body, "auto body aim", Save.hvh_auto_body, function(v) Save.hvh_auto_body = v; persist() end)
        U.hint(s2.body, "aims torso when suspect active", U.O.textDim)
        U.checkbox(s2.body, "baim on aa", Save.hvh_baim_on_aa, function(v) Save.hvh_baim_on_aa = v; persist() end)
    end

    local function tabWorld()
        local TAB = U.newTab("world")
        local s = U.section(TAB.left, "weather")
        U.checkbox(s.body, "snow", Save.weather_snow, function(v)
            Save.weather_snow = v
            if v then Save.weather_rain = false; Save.weather_leaves = false; Save.weather_fireflies = false end
            persist()
        end)
        U.checkbox(s.body, "rain", Save.weather_rain, function(v)
            Save.weather_rain = v
            if v then Save.weather_snow = false; Save.weather_leaves = false; Save.weather_fireflies = false end
            persist()
        end)
        U.checkbox(s.body, "leaves", Save.weather_leaves, function(v)
            Save.weather_leaves = v
            if v then Save.weather_snow = false; Save.weather_rain = false; Save.weather_fireflies = false end
            persist()
        end)
        U.checkbox(s.body, "fireflies", Save.weather_fireflies, function(v)
            Save.weather_fireflies = v
            if v then Save.weather_snow = false; Save.weather_rain = false; Save.weather_leaves = false end
            persist()
        end)
        U.slider(s.body, "density", 20, 800, Save.weather_density, function(v) Save.weather_density = v; persist() end)
        U.slider(s.body, "speed", 1, 80, Save.weather_speed, function(v) Save.weather_speed = v; persist() end)
        local s2 = U.section(TAB.left, "fog")
        U.checkbox(s2.body, "enabled", Save.fog_enabled, function(v) Save.fog_enabled = v; persist() end)
        U.slider(s2.body, "fog start", 0, 500, Save.fog_start, function(v) Save.fog_start = v; persist() end)
        U.slider(s2.body, "fog end", 50, 5000, Save.fog_end, function(v) Save.fog_end = v; persist() end)
        U.colorSwatch(s2.body, "fog color", Save.fog_color_r, Save.fog_color_g, Save.fog_color_b, function(r, g, b)
            Save.fog_color_r, Save.fog_color_g, Save.fog_color_b = r, g, b
            persist()
        end)
        local s3 = U.section(TAB.right, "post-processing")
        U.checkbox(s3.body, "bloom", Save.bloom_enabled, function(v) Save.bloom_enabled = v; persist() end)
        U.slider(s3.body, "intensity", 0, 5, Save.bloom_intensity, function(v) Save.bloom_intensity = v; persist() end)
        U.slider(s3.body, "size", 1, 56, Save.bloom_size, function(v) Save.bloom_size = v; persist() end)
        U.checkbox(s3.body, "color correction", Save.cc_enabled, function(v) Save.cc_enabled = v; persist() end)
        U.slider(s3.body, "brightness", -1, 1, Save.cc_brightness, function(v) Save.cc_brightness = v; persist() end)
        U.slider(s3.body, "contrast", -1, 1, Save.cc_contrast, function(v) Save.cc_contrast = v; persist() end)
        U.slider(s3.body, "saturation", -1, 1, Save.cc_saturation, function(v) Save.cc_saturation = v; persist() end)
        U.checkbox(s3.body, "depth of field", Save.dof_enabled, function(v) Save.dof_enabled = v; persist() end)
        U.slider(s3.body, "focus distance", 0, 500, Save.dof_focus, function(v) Save.dof_focus = v; persist() end)
        local s4 = U.section(TAB.right, "camera & time")
        U.slider(s4.body, "field of view", 40, 120, Save.fov_value, function(v) Save.fov_value = v; persist() end)
        U.slider(s4.body, "time of day", 0, 24, Save.time_of_day, function(v) Save.time_of_day = v; persist() end)
    end

    local function tabSound()
        local TAB = U.newTab("sounds")
        local s = U.section(TAB.left, "hitsounds")
        U.checkbox(s.body, "enabled", Save.hitsound_enabled, function(v) Save.hitsound_enabled = v; persist() end)
        U.dropdown(s.body, "sound type", HITSOUND_LIST, Save.hitsound_type or "tick", function(v)
            Save.hitsound_type = v; persist()
            for _, snd in ipairs(hitPool) do
                snd.SoundId = SOUND_IDS["hitsound_" .. v] or SOUND_IDS.hitsound_tick
            end
        end)
        U.slider(s.body, "volume", 0.1, 1, Save.hitsound_volume, function(v) Save.hitsound_volume = v; persist() end)
        U.slider(s.body, "pitch", 0.5, 2, Save.hitsound_pitch, function(v) Save.hitsound_pitch = v; persist() end)
        U.checkbox(s.body, "only on kill", Save.hitsound_only_kill, function(v) Save.hitsound_only_kill = v; persist() end)
        local s1a = U.section(TAB.left, "ui sounds")
        U.checkbox(s1a.body, "notifications & toggles", Save.uisound_enabled, function(v) Save.uisound_enabled = v; persist() end)
        U.slider(s1a.body, "volume", 0.05, 1, Save.uisound_volume, function(v) Save.uisound_volume = v; persist() end)
        local s1b = U.section(TAB.right, "death sound")
        U.checkbox(s1b.body, "enabled", Save.deathsound_enabled, function(v) Save.deathsound_enabled = v; persist() end)
        U.slider(s1b.body, "volume", 0.1, 1, Save.deathsound_volume, function(v) Save.deathsound_volume = v; persist() end)
        local s2 = U.section(TAB.right, "preview")
        U.button(s2.body, "test hit sound", function()
            local old = Save.hitsound_enabled
            Save.hitsound_enabled = true
            playHitsound(false)
            Save.hitsound_enabled = old
        end, true)
        U.button(s2.body, "test notification", function() playUISound() end, true)
        U.button(s2.body, "test death sound", function()
            local old = Save.deathsound_enabled
            Save.deathsound_enabled = true
            playDeathSound()
            Save.deathsound_enabled = old
        end, true)
    end

    local function tabSkins()
        local TAB = U.newTab("skins")
        local s = U.section(TAB.left, "quick unlock")
        U.button(s.body, "unlock all cosmetics", function()
            local n = skinUnlockAll()
            U.notify("unlocked", n .. " cosmetics", "success")
        end, true)
        U.button(s.body, "clear fake inventory", function()
            table.clear(Skin.fake_owned)
            U.notify("cleared", "fake inventory wiped", "warn")
        end)
        local s2 = U.section(TAB.left, "by category")
        local cat = "Skin"
        U.dropdown(s2.body, "type", {"Skin","Wrap","Charm","Finisher","Emote"}, "Skin", function(v) cat = v end)
        U.button(s2.body, "unlock type", function()
            local n = skinUnlockCategory(cat)
            U.notify("unlocked", n .. " of " .. cat, "success")
        end, true)
        local s3 = U.section(TAB.right, "by rarity")
        local rar = "Common"
        U.dropdown(s3.body, "rarity", {"Common","Rare","Legendary","Mythical","Unique","Unobtainable"}, "Common", function(v) rar = v end)
        U.button(s3.body, "unlock rarity", function()
            local n = skinUnlockRarity(rar)
            U.notify("unlocked", n .. " of " .. rar, "success")
        end, true)
        local s4 = U.section(TAB.right, "specific")
        local spec = ""
        U.input(s4.body, "cosmetic name", "", function(v) spec = v end)
        U.button(s4.body, "unlock specific", function()
            if spec ~= "" and M.CosmeticLibrary and M.CosmeticLibrary.Cosmetics
            and M.CosmeticLibrary.Cosmetics[spec] then
                Skin.fake_owned[spec] = true
                U.notify("unlocked", spec, "success")
            else U.notify("not found", spec, "error") end
        end, true)
    end

    local function tabOverlay()
        local TAB = U.newTab("overlay")
        local s = U.section(TAB.left, "drag system")
        U.checkbox(s.body, "magnetic edges", Save.drag_magnetic, function(v) Save.drag_magnetic = v; persist() end)
        U.slider(s.body, "magnet distance", 5, 200, Save.drag_magnet_dist or 40, function(v) Save.drag_magnet_dist = v; persist() end)
        U.slider(s.body, "snap grid px (0=off)", 0, 50, Save.drag_snap_grid or 0, function(v) Save.drag_snap_grid = v; persist() end)
        U.checkbox(s.body, "drag shadow glow", Save.drag_shadow, function(v) Save.drag_shadow = v; persist() end)
        local s2 = U.section(TAB.left, "watermark")
        U.checkbox(s2.body, "visible", Save.watermark_enabled ~= false, function(v)
            Save.watermark_enabled = v; persist(); U.watermark.Visible = v
        end)
        U.checkbox(s2.body, "locked", Save.watermark_locked, function(v) Save.watermark_locked = v; persist() end)
        U.slider(s2.body, "scale", 0.5, 3, Save.watermark_scale or 1, function(v)
            Save.watermark_scale = v
            U.watermark.Size = UDim2.fromOffset(440 * v, 24 * v)
            persist()
        end)
        U.slider(s2.body, "opacity", 0.1, 1, Save.watermark_opacity or 1, function(v)
            Save.watermark_opacity = v
            U.watermark.BackgroundTransparency = 1 - v * 0.35
            persist()
        end)
        local s3 = U.section(TAB.right, "keybinds panel")
        U.checkbox(s3.body, "visible", Save.keybinds_enabled ~= false, function(v)
            Save.keybinds_enabled = v; persist(); U.keybindPanel.Visible = v
        end)
        U.checkbox(s3.body, "locked", Save.keybinds_locked, function(v) Save.keybinds_locked = v; persist() end)
        local s4 = U.section(TAB.right, "main window")
        U.checkbox(s4.body, "locked", Save.win_locked, function(v) Save.win_locked = v; persist() end)
        U.button(s4.body, "center window", function()
            U.W.AnchorPoint = Vector2.new(0.5, 0.5)
            U.W.Position = UDim2.fromScale(0.5, 0.5)
        end)
    end

    local function tabMisc()
        local TAB = U.newTab("misc")
        local s = U.section(TAB.left, "weapon mods")
        U.checkbox(s.body, "no spread", Save.no_spread, function(v) RF.no_spread = v; Save.no_spread = v; persist(); syncWeaponMods() end)
        U.checkbox(s.body, "no recoil", Save.no_recoil, function(v) RF.no_recoil = v; Save.no_recoil = v; persist(); syncWeaponMods() end)
        U.checkbox(s.body, "rapid fire", Save.rapid_fire, function(v) RF.rapid_fire = v; Save.rapid_fire = v; persist(); syncWeaponMods() end)
        U.checkbox(s.body, "anti input spam", Save.auto_weapon, function(v) RF.auto_weapon = v; Save.auto_weapon = v; persist(); syncWeaponMods() end)
        U.slider(s.body, "gun cooldown", 0.001, 0.5, Save.gun_cd, function(v) RF.gun_cd = v; Save.gun_cd = v; persist(); syncWeaponMods() end)
        U.slider(s.body, "melee cooldown", 0.001, 0.5, Save.melee_cd, function(v) RF.melee_cd = v; Save.melee_cd = v; persist(); syncWeaponMods() end)
        local s2 = U.section(TAB.left, "spoofer")
        U.checkbox(s2.body, "spoof device", Save.spoof_device, function(v) Spoof.spoof_device = v; Save.spoof_device = v; persist() end)
        U.slider(s2.body, "device idx", 1, 4, Save.device_idx or 1, function(v)
            local idx = floor(v)
            Spoof.device = ({"Desktop","Mobile","Console","VR"})[idx] or "Desktop"
            Save.device_idx = idx; persist()
        end)
        U.checkbox(s2.body, "spoof display name", Save.spoof_name, function(v) Spoof.spoof_name = v; Save.spoof_name = v; persist() end)
        U.input(s2.body, "display name", Save.display_name, function(v) Spoof.display_name = v; Save.display_name = v; persist() end)
        U.checkbox(s2.body, "spoof username", Save.spoof_username, function(v) Spoof.spoof_username = v; Save.spoof_username = v; persist() end)
        U.input(s2.body, "username", Save.username, function(v) Spoof.username = v; Save.username = v; persist() end)
        local s3 = U.section(TAB.right, "leaderboard spoof")
        U.slider(s3.body, "spoof ELO", 0, 99999, Save.spoof_elo, function(v) Spoof.elo = floor(v); Save.spoof_elo = Spoof.elo; persist() end)
        U.slider(s3.body, "spoof streak", 0, 999, Save.spoof_streak, function(v) Spoof.streak = floor(v); Save.spoof_streak = Spoof.streak; persist() end)
        U.slider(s3.body, "spoof level", 0, 1000, Save.spoof_level, function(v) Spoof.level = floor(v); Save.spoof_level = Spoof.level; persist() end)
        local s4 = U.section(TAB.right, "animations")
        local animBtn
        animBtn = U.button(s4.body, "cycle: " .. currentAnim, function()
            local idx = table.find(animList, currentAnim) or 1
            currentAnim = animList[(idx % #animList) + 1]
            Save.anim = currentAnim; persist()
            lastAnim = nil
            animBtn.Text = "cycle: " .. currentAnim
            U.notify("animation", currentAnim, "info")
        end, true)
    end

    local function tabCfg()
        local TAB = U.newTab("config")
        local s = U.section(TAB.left, "config")
        U.button(s.body, "save now", function() persist(); U.notify("saved", CFG_FILE, "success") end, true)
        U.button(s.body, "reset all", function()
            for k, v in pairs(DEFAULT) do Save[k] = v end
            persist()
            U.notify("reset", "rejoin to apply defaults", "warn")
        end)
        local s2 = U.section(TAB.left, "interface")
        U.checkbox(s2.body, "background particles", Save.ui_particles, function(v)
            Save.ui_particles = v; persist()
            for _, c in ipairs(U.particleFrame:GetChildren()) do
                if c:IsA("Frame") then U.Tween(c, 0.3, {BackgroundTransparency = v and 0.75 or 1}) end
            end
        end)
        U.checkbox(s2.body, "blur on open", Save.ui_blur, function(v) Save.ui_blur = v; persist() end)
        local s5 = U.section(TAB.left, "spotify")
        U.checkbox(s5.body, "enabled", Save.spotify_enabled, function(v)
            Save.spotify_enabled = v; persist(); U.spWidget.Visible = v
        end)
        U.input(s5.body, "discord user id", Save.spotify_discord_id or "", function(v)
            Save.spotify_discord_id = v; persist()
            Spotify.lastFetch = 0
        end)
        local s3 = U.section(TAB.right, "menu accent")
        U.colorSwatch(s3.body, "menu color", Save.ui_accent_r, Save.ui_accent_g, Save.ui_accent_b, function(r, g, b)
            Save.ui_accent_r, Save.ui_accent_g, Save.ui_accent_b = r, g, b
            U.O.accent = Color3.fromRGB(r, g, b)
            U.O.accentSoft = Color3.fromRGB(min(255, r+50), min(255, g+50), min(255, b+50))
            U.O.accentDeep = Color3.fromRGB(max(0, r-70), max(0, g-70), max(0, b-70))
            persist()
        end)
        local s4 = U.section(TAB.right, "session")
        U.button(s4.body, "unload script", function()
            persist()
            pcall(restoreWeaponMods)
            cleanupWeather()
            if World.bloom then pcall(function() World.bloom:Destroy() end) end
            if World.cc then pcall(function() World.cc:Destroy() end) end
            if World.dof then pcall(function() World.dof:Destroy() end) end
            if World.atmosphere then pcall(function() World.atmosphere:Destroy() end) end
            if World.savedAtmosphere and not World.savedAtmosphere.Parent then
                World.savedAtmosphere.Parent = Lighting
            end
            for _, d in ipairs(espAllDrawings) do pcall(function() d:Remove() end) end
            for p, _ in pairs(espObjects) do espDestroy(p) end
            if infJumpConn then infJumpConn:Disconnect() end
            for _, c in ipairs(hitsoundConns) do pcall(function() c:Disconnect() end) end
            for _, snd in ipairs(hitPool) do pcall(function() snd:Destroy() end) end
            for _, snd in ipairs(uiPool) do pcall(function() snd:Destroy() end) end
            pcall(function() deathSound:Destroy() end)
            getgenv().__RBE_LOADED = nil
            getgenv().__RBE_HITMARKER = nil
            pcall(function() U.blurFx.Size = 0 end)
            pcall(function()
                Lighting.FogEnd = World.originalFogEnd
                Lighting.FogStart = World.originalFogStart
                Lighting.FogColor = World.originalFogColor
            end)
            U.Screen:Destroy()
        end)
    end

    local function tabAbout()
        local TAB = U.newTab("about")
        local s = U.section(TAB.left, "roblox ezzzz")
        U.hint(s.body, [[obsidian edition v4.2

- NEW: rekod AA (spin uses real dt)
- NEW: fakelag works with RAGE only
- NEW: hitmarker + snapline + facing
- peek system (duck / jump / strafe)
- smart silent aim multipoint + priority
- hvH detection + auto baim
- ragebot v2 with grace reacquire
- esp / skeleton / chams
- advanced watermark with fps graph
- spotify widget
- hitsounds + UI + death sounds

RightShift - toggle window]])
    end

    tabAim()
    tabVis()
    tabMove()
    tabPeek()
    tabRage()
    tabHvH()
    tabWorld()
    tabSound()
    tabSkins()
    tabOverlay()
    tabMisc()
    tabCfg()
    tabAbout()

    -- Window drag
    local winDragging = false
    local winStart, winStartPixel
    local winDragBar = U.New("TextButton", {Size=UDim2.new(1,-80,0,U.TOP_H),
        Position=UDim2.fromOffset(0,1), BackgroundTransparency=1,
        Text="", ZIndex=20, Parent=U.W})
    winDragBar.MouseButton1Down:Connect(function()
        if Save.win_locked then return end
        winDragging = true
        winStart = UIS:GetMouseLocation()
        local ap = U.W.AbsolutePosition
        winStartPixel = Vector2.new(ap.X, ap.Y)
        U.W.AnchorPoint = Vector2.new(0,0)
        U.W.Position = UDim2.fromOffset(ap.X, ap.Y)
    end)
    UIS.InputChanged:Connect(function(i)
        if winDragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = UIS:GetMouseLocation() - winStart
            local nx = winStartPixel.X + d.X
            local ny = winStartPixel.Y + d.Y
            local vs = CAM.ViewportSize
            local fs = U.W.AbsoluteSize
            nx = clamp(nx, -fs.X + 100, vs.X - 100)
            ny = clamp(ny, 0, vs.Y - 40)
            U.W.Position = UDim2.fromOffset(nx, ny)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch) and winDragging then
            winDragging = false
        end
    end)

    -- Resize
    do
        local handle = U.New("TextButton", {Size=UDim2.fromOffset(14,14),
            Position=UDim2.new(1,-1,1,-1), AnchorPoint=Vector2.new(1,1),
            BackgroundTransparency=1, Text="", ZIndex=30, Parent=U.W})
        U.New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Text="//", TextColor3=U.O.textDim, Font=Enum.Font.GothamBold,
            TextSize=8, ZIndex=31, Parent=handle})
        local resizing = false
        local startSize, startMouse
        handle.MouseButton1Down:Connect(function()
            resizing = true
            local ap = U.W.AbsolutePosition
            U.W.AnchorPoint = Vector2.new(0,0)
            U.W.Position = UDim2.fromOffset(ap.X, ap.Y)
            startSize = Vector2.new(U.W.AbsoluteSize.X, U.W.AbsoluteSize.Y)
            startMouse = UIS:GetMouseLocation()
        end)
        UIS.InputChanged:Connect(function(i)
            if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                local d = UIS:GetMouseLocation() - startMouse
                U.W.Size = UDim2.fromOffset(
                    clamp(startSize.X + d.X, 760, 1600),
                    clamp(startSize.Y + d.Y, 440, 1000))
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if (i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch) and resizing then
                resizing = false
                Save.ui_w = U.W.AbsoluteSize.X
                Save.ui_h = U.W.AbsoluteSize.Y
                persist()
            end
        end)
    end

    U.W:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if U.W.Visible then
            task.defer(function() RunService.RenderStepped:Wait(); U.updateUnderlineInstant() end)
        end
    end)
    U.W:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if U.W.Visible then
            task.defer(function() RunService.RenderStepped:Wait(); U.updateUnderlineInstant() end)
        end
    end)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            U.W.Visible = not U.W.Visible
            if U.W.Visible then
                U.W.AnchorPoint = Vector2.new(0.5, 0.5)
                U.W.Position = UDim2.fromScale(0.5, 0.5)
                local tgt = UDim2.fromOffset(Save.ui_w or U.initW, Save.ui_h or U.initH)
                U.W.Size = UDim2.fromOffset(U.W.AbsoluteSize.X * 0.92, U.W.AbsoluteSize.Y * 0.92)
                U.W.BackgroundTransparency = 0.2
                U.Tween(U.W, 0.32, {Size=tgt, BackgroundTransparency=0}, Enum.EasingStyle.Back)
                if Save.ui_blur then U.Tween(U.blurFx, 0.28, {Size=6}) end
                task.defer(function()
                    task.wait(0.05)
                    RunService.RenderStepped:Wait()
                    U.updateUnderlineInstant()
                end)
                task.delay(0.35, function()
                    if U.W.Visible then U.updateUnderlineInstant() end
                end)
            else
                U.closeAllPopups()
                if Save.ui_blur then U.Tween(U.blurFx, 0.28, {Size=0}) end
            end
        end
    end)
end

setupTabsAndWindow()

UIAPI.W.BackgroundTransparency = 1
UIAPI.Tween(UIAPI.W, 0.45, {BackgroundTransparency=0}, Enum.EasingStyle.Back)
if Save.ui_blur then UIAPI.Tween(UIAPI.blurFx, 0.42, {Size=6}) end

task.defer(function()
    task.wait(0.15)
    RunService.RenderStepped:Wait()
    UIAPI.updateUnderlineInstant()
end)
task.delay(0.6, function() UIAPI.updateUnderlineInstant() end)

task.delay(0.55, function()
    UIAPI.notify("roblox ezzzz", "obsidian v4.2 - new AA/fakelag", "success")
end)

print("[rbe] obsidian v4.2 loaded | " .. CFG_FILE)
