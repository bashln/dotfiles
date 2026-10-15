-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
o.window("[sS]potify", { workspace = "5" })

-- Bitwarden passkey popup (browser extension) should float, not split the screen.
-- Omarchy's default only covers the Chrome extension id (nngceck...); Edge ships
-- its own id (jbkfoe...), so its passkey window tiles. Hyprland's class match is
-- a full match, hence the leading/trailing ".*". Float is applied directly: a
-- "+floating-window" tag set from a user rule is too late, as Omarchy's
-- tag -> float rule already ran.
o.window(".*jbkfoedolllekgbhcbcoahefnbanhhlh.*", {
  no_screen_share = true,
  float = true,
  center = true,
  size = { 875, 600 },
})
