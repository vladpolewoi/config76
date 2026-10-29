-- Hyprland 0.57+ reads only this file; hyprland.conf (hyprlang) is no longer loaded.
-- API stubs: /usr/share/hypr/stubs/hl.meta.lua   Wiki: https://wiki.hypr.land/configuring/

local home = os.getenv("HOME")
local scripts = home .. "/config76/arch/scripts"

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    -- waybar waits for the unlock so it never draws over hyprlock
    hl.exec_cmd("sleep 1 && hyprlock; waybar")
    hl.exec_cmd(scripts .. "/slideshow.sh")
    hl.exec_cmd("swaync")
    hl.exec_cmd("python3 " .. home .. "/code/redline76/arch/redline76d.py")
    hl.exec_cmd(scripts .. "/graph76-desk.sh --preload")
end)

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

hl.config({
    general = {
        border_size = 4,
        gaps_in     = 6,
        gaps_out    = 12,
        col = {
            active_border   = { colors = { "rgb(c099ff)", "rgb(82aaff)", "rgb(4fd6be)" }, angle = 60 },
            inactive_border = "rgba(1e2030cc)",
        },
    },

    decoration = {
        rounding         = 6,
        rounding_power   = 2.0,
        inactive_opacity = 0.8,

        shadow = {
            enabled        = true,
            range          = 100,
            render_power   = 4, -- 0.57 caps this at 4
            color          = 0x33000000,
            color_inactive = 0x22000000,
        },

        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            noise             = 0.02,
            contrast          = 1.0,
            brightness        = 0.90,
            vibrancy          = 0.20,
            vibrancy_darkness = 0.15,
            xray              = false,
            ignore_opacity    = true,
            new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:alt_shift_toggle,caps:escape",
    },

    dwindle = {
        preserve_split = true,
    },
})

-- graph76 Desk popup (Super+T): Chrome --app window parked on special:tasks, floating, centred
hl.window_rule({
    name  = "graph76-desk",
    match = { class = "^(chrome-localhost__-Default)$" },

    workspace = "special:tasks silent",
    float     = true,
    size      = { "monitor_w*0.7", "monitor_h*0.7" },
    center    = true,
})

-- Waybar frosted glass: blur the bar layer, skip the transparent gaps (pill fill alpha ~0.26-0.34)
hl.layer_rule({
    name  = "waybar-glass",
    match = { namespace = "waybar" },

    blur         = true,
    ignore_alpha = 0.1,
    blur_popups  = true,
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

-- Keymaps =-=-=-=-=-=

local function run(cmd)
    return hl.dsp.exec_cmd(cmd)
end

-- Open terminal
hl.bind("SUPER + Return", run("kitty"))

-- Open App Luncher
hl.bind("SUPER + Space", run(scripts .. "/app-launcher.sh"))

-- Lock screen
hl.bind("CTRL + ALT + Q", run("hyprlock"))

-- Explorer
hl.bind("SUPER + E", run("nemo"))

-- Wallpaper
hl.bind("SUPER + backslash", run(scripts .. "/pick-wallpaper.sh"))

-- Window
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())

local dirs = { H = "left", L = "right", K = "up", J = "down" }
for key, dir in pairs(dirs) do
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ direction = dir }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Workspaces: 7 8 9 0 -> 1 2 3 4
local wsKeys = { "7", "8", "9", "0" }
for i, key in ipairs(wsKeys) do
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind("SUPER + CTRL + H", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ workspace = "r+1" }))

hl.bind("SUPER + ALT + H", hl.dsp.window.resize({ x = -50, y = 0,   relative = true }))
hl.bind("SUPER + ALT + L", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }))
hl.bind("SUPER + ALT + K", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind("SUPER + ALT + J", hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))

-- Toggle split direction
hl.bind("SUPER + V", hl.dsp.layout("togglesplit"))

-- Volume
local osd = scripts .. "/volume-osd.sh"
hl.bind("XF86AudioRaiseVolume", run("pamixer -i 1 && " .. osd))
hl.bind("XF86AudioLowerVolume", run("pamixer -d 1 && " .. osd))
hl.bind("XF86AudioMute",        run("pamixer -t && " .. osd))

hl.bind("SUPER + B", run(scripts .. "/pick-bluetooth.sh"))

-- Screenshots
-- hl.bind("CTRL + SHIFT + F", run("bash " .. scripts .. "/screenshot-full.sh"))
hl.bind("CTRL + SHIFT + F", run("bash " .. scripts .. "/screenshot-clip.sh"))     -- region -> clipboard, no window
hl.bind("CTRL + SHIFT + S", run("bash " .. scripts .. "/screenshot-edit.sh"))     -- region -> swappy editor
hl.bind("CTRL + SHIFT + P", run("bash " .. scripts .. "/mark.sh phone"))          -- iPhone screen -> numbered pins -> clipboard
hl.bind("CTRL + SHIFT + M", run("bash " .. scripts .. "/mark.sh region"))         -- region       -> numbered pins -> clipboard
hl.bind("CTRL + SHIFT + D", run("bash " .. scripts .. "/mark.sh drop"))           -- newest ~/Downloads image (LocalSend)

-- Screen Recording
hl.bind("SUPER + SHIFT + R", run("bash " .. scripts .. "/screen-record.sh"))

-- Voice Dictation - F8 to toggle
hl.bind("F8", run("bash " .. scripts .. "/dictation.sh"))

-- Refresh hyprland
hl.bind("CTRL + SHIFT + R", run("bash " .. home .. "/config76/arch/refresh.sh"))

-- Notification Center
hl.bind("SUPER + N", run("swaync-client -t"))

-- Projects
hl.bind("SUPER + P", run("bash " .. home .. "/.local/scripts/launch-project.sh"))

-- graph76 Desk popup
hl.bind("SUPER + T", run(scripts .. "/graph76-desk.sh"))
