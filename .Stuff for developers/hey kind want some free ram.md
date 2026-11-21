# VMT Camos, Camo Overlays and Customize Tabs

This document covers three related systems:

1. **VMT camos**: a camo attachment can point at a `.vmt` instead of a bare texture.
2. **Overlay camos**: a camo VMT is drawn as a real material over the weapon, so every VMT parameter works.
3. **Camo options and customize tabs**: players can tweak overlay camos (colour, sliders, toggles) in a **CAMO** tab. That tab is built on a general framework you can reuse for your own tabs.

All three sit on top of the existing camo system. Camos that only set `ATT.CustomCamoTexture` to a VTF behave exactly as before.

---

## 1. VMT camos

### Usage

```lua
ATT.CustomCamoMaterial = "models/weapons/mycamos/tigerstripe"
```

Both of these also work:

```lua
ATT.CustomCamoMaterial = "materials/models/weapons/mycamos/tigerstripe.vmt"
ATT.CustomCamoTexture  = "models/weapons/mycamos/tigerstripe.vmt"
```

A leading `materials/` and a trailing `.vmt` are stripped. A `CustomCamoTexture` ending in `.vmt` is moved to `CustomCamoMaterial`.

### What is read from the VMT

The camo still goes into the gun material's `$detail` slot, the same as a texture camo. Only these values are read:

| VMT parameter | Fills attachment field | Used by |
|---|---|---|
| `$basetexture` | `CustomCamoTexture` | both camo proxies |
| `$arc9_camoscale` | `CustomCamoScale` | both camo proxies |
| `$arc9_camorotate` | `CustomCamoRotate` | `Arc9CustomCamoAdvanced` only |
| `$arc9_camoblendmode` | `CustomCamoBlendMode` | `Arc9CustomCamoAdvanced` only |
| `$arc9_camoblendfactor` | `CustomBlendFactor` | `Arc9CustomCamoAdvanced` only (see Known issues) |
| `$arc9_camophongmult` | `CustomCamoPhongMult` | `Arc9CustomCamoAdvanced` only |

**Lua always wins.** A VMT value is only used when the attachment leaves that field unset. If a VMT camo should take its scale from the VMT, don't write `ATT.CustomCamoScale = 1`.

Every other VMT parameter (`$selfillum`, `$additive`, `$phong`, proxies, ...) is **ignored** in this mode, because a `$detail` texture has no shader settings of its own. For an emissive look, use `$detail` blend mode 5 (`"$arc9_camoblendmode" "5"`). To use the full VMT, see Overlay camos below.

### Example

```
"VertexLitGeneric"
{
    "$basetexture"          "camo/anti-furry/boykisserdigital"
    "$arc9_camoscale"       "8"
    "$arc9_camorotate"      "45"
    "$arc9_camoblendmode"   "4"
    "$arc9_camoblendfactor" "1"
}
```

### Icon

If the attachment has no `ATT.Icon`, an icon is made from the VMT's `$basetexture`.

### Errors

If the VMT can't be loaded or has no valid `$basetexture`, a line starting with `[ARC9] Camo material ...` is printed to console. The camo then shows the error texture.

---

## 2. Overlay camos

An overlay camo draws its VMT as a real material in a second pass over the weapon. **Every VMT parameter works**, including `$selfillum`, `$translucent`/`$alpha`, `$additive`, phong, envmaps, `$basetexturetransform` and **material proxies** (scrolling, animated textures, ...).

### Enabling

Use either of these:

```
"$arc9_camooverlay" "1"
```

```lua
ATT.CustomCamoMaterial = "camo/mycamo"
ATT.CustomCamoOverlay = true
```

When the attachment loads, `CustomCamoOverlay` is replaced with the material path, and `CustomCamoTexture` is cleared. The normal `$detail` camo is therefore off while an overlay camo is equipped, so the two don't stack.

### What it covers

The overlay is drawn only on materials that use the `CustomCamo` or `Arc9CustomCamoAdvanced` proxy: the parts that normally take camo. Scope glass, stickers, RT scope screens and other parts are left alone. It covers:

- the viewmodel, through a bonemerged copy of the viewmodel, since the engine draws the viewmodel itself
- attachment models
- the world model

It is skipped in shadow/depth passes, on models drawn in ARC9's translucent pass, and at the lowest level of detail.

### Authoring notes

- **The VMT controls how it blends with the gun.** Without `$translucent`, `$alpha` or `$additive`, the camo replaces the gun's look on every camo-able part.
- `$arc9_camo*` values are **not used** in overlay mode. Set scale and rotation in the VMT, for example with `$basetexturetransform`.
- The overlay is drawn with depth writes off, on top of the already drawn surface.
- Each weapon carrying an overlay camo is drawn twice.

### Example

```
"VertexLitGeneric"
{
    "$basetexture"      "camo/anti-furry/boykisserdigital"
    "$arc9_camooverlay" "1"
    "$translucent"      "1"
    "$alpha"            "0.75"
    "$selfillum"        "1"

    "Proxies"
    {
        "TextureScroll"
        {
            "texturescrollvar"   "$basetexturetransform"
            "texturescrollrate"  "0.25"
            "texturescrollangle" "45"
        }
    }
}
```

---

## 3. Camo options (player customisation)

Overlay camos can expose settings that players change in a **CAMO** tab in the customize menu. The tab appears next to PERSONALIZE while such a camo is equipped.

Each option writes to **one VMT variable** on the camo material. Anything the shader reads directly (`$color2`, `$alpha`, `$selfillumtint`, ...) works as is. To drive a **proxy**, give the proxy a variable instead of a fixed number (see Driving proxies below).

### Declaring options

```lua
ATT.CustomCamoOptions = {
    { type = "color",  name = "Tint",         param = "$color2" },
    { type = "color",  name = "Glow Colour",  param = "$selfillumtint" },
    { type = "slider", name = "Opacity",      param = "$alpha", min = 0, max = 1, decimals = 2 },
    { type = "bool",   name = "Scrolling",    param = "$arc9_scrollon" },
    { type = "slider", name = "Scroll Speed", param = "$arc9_scrollrate", min = 0, max = 2, decimals = 2 },
}
```

| Field | Meaning |
|---|---|
| `type` | `"slider"` (default), `"color"` or `"bool"` |
| `name` | label shown in the menu; can be a localisation phrase |
| `param` | VMT variable to write (required) |
| `min`, `max`, `decimals` | slider range and precision (defaults `0`, `1`, `2`) |
| `default` | used only when the VMT doesn't define `param` |

How each type writes its value:

- **slider** writes a float.
- **color** writes a vector (0-1 per channel); the UI uses 0-255 and hex.
- **bool** writes `1` or `0`.

**Defaults:** without `ATT.CustomCamoOptions`, an overlay camo gets *Tint* (`$color2`) and *Opacity* (`$alpha`). If the VMT defines `$arc9_scrollrate`, it also gets *Scroll Speed* (0-2). `ATT.CustomCamoOptions = false` turns options off, and the tab is not shown.

The initial value of each option is read from the VMT. **Reset** restores those values.

### Driving proxies

Source proxy arguments accept a `$variable` in place of a number. To let players set the scroll speed:

```
"$arc9_scrollrate" "0.25"

"Proxies"
{
    "TextureScroll"
    {
        "texturescrollvar"  "$basetexturetransform"
        "texturescrollrate" "$arc9_scrollrate"
    }
}
```

To add an on/off toggle, multiply by a `bool` variable before passing the result on. Proxies run in order:

```
"$arc9_scrollrate"  "0.25"
"$arc9_scrollon"    "1"
"$arc9_scrollfinal" "0.25"

"Proxies"
{
    "Multiply"
    {
        "srcVar1"   "$arc9_scrollrate"
        "srcVar2"   "$arc9_scrollon"
        "resultVar" "$arc9_scrollfinal"
    }
    "TextureScroll"
    {
        "texturescrollvar"  "$basetexturetransform"
        "texturescrollrate" "$arc9_scrollfinal"
    }
}
```

Don't expose a variable that a proxy **writes** every frame, such as `$basetexturetransform`. The proxy would overwrite the player's value.

### Scope and storage

- Settings are **client-side only**. Other players see the VMT's defaults.
- Settings belong to the **camo material**, not the weapon. Changing a camo's tint changes it on every gun using that camo.
- Values are saved to `garrysmod/data/arc9_camo_options.json`, keyed by material path.
- Options exist only for overlay camos. `$detail` camos have no per-camo material to write to.

---

## 4. Customize tab framework

The CAMO tab is one registration in a general system. Any addon can add tabs to the ARC9 customize menu.

### Registering a tab

```lua
ARC9.RegisterCustomizeTab("my_tab", {
    title = "My Tab",
    order = 200,
    height = 50,
    condition = function(wep) return wep:GetValue("SomeFlag") end,
    options = function(wep) return spec end,
})
```

| Field | Meaning |
|---|---|
| `title` | tab button text; a localisation phrase or plain text |
| `order` | sort order among registered tabs (default `100`, ties sorted by id) |
| `condition` | `function(wep) -> bool`; the tab is shown only while it returns true. Omit to always show |
| `height` | how much the bottom panel grows while the tab is open (default `50`, same as Trivia) |
| `build` | `function(wep, panel)`; fill the panel yourself |
| `options` | `function(wep) -> spec`; build a standard options panel (see Options panel). Used when there is no `build` |

Registered tabs appear after CUSTOMIZE/PERSONALIZE. The tab list is rechecked when the menu opens and after every attachment change, so tabs appear and disappear live. An open registered tab is rebuilt after attachment changes. If `condition`, `build` or `options` throws an error, it is printed to console and the menu keeps working.

Register tabs from a client file. Put the registration in a file that loads after `arc9/client/cl_0_customize_tabs.lua`; any other `arc9/client/` file or any client file in another addon does.

### Options panel

`ARC9.CreateOptionsPanel(parent, spec)` builds the labelled-row layout used by the CAMO tab. It works inside any panel, not only customize tabs.

```lua
{
    title   = "Header text",
    note    = "Small hint, top right",
    onReset = function() end,
    options = {
        { type = "slider", name = "Speed", min = 0, max = 2, decimals = 2,
          get = function() return value end,
          set = function(value, final) end },
        { type = "color", name = "Tint", get = ..., set = ... },
        { type = "bool",  name = "Glow", get = ..., set = ... },
    },
}
```

- `title` can be a function returning text.
- `onReset` adds a Reset button. After it runs, every control re-reads its value with `get()`.
- `set(value, final)`: `final` is `false` for live previews (a colour being dragged in the picker) and `true` when the value is committed. Save only on `final`.
- Colour values are `Color` tables. Bool values are `true`/`false`.

### Adding a control type

```lua
ARC9.RegisterOptionControl("mytype", function(row, opt, x, w, h)
    local ctrl = vgui.Create("ARC9ComboBox", row)
    ctrl:SetPos(x, 0)

    function ctrl:ARC9Refresh()
    end

    return ctrl
end)
```

The function builds the control inside `row`. `x` and `w` are the control column's position and width, and `h` is the row height. The control should call `opt.set(value, final)` when changed and define `ARC9Refresh()` so Reset can update it. Every options panel can use the new type immediately via `type = "mytype"`.

Built-in types:

| Type | Control | Notes |
|---|---|---|
| `slider` | `ARC9NumSlider` | value box on the right is editable |
| `color` | `ARC9ColorButton` | picker with hex input, live preview, hex readout next to the button |
| `bool` | `ARC9Checkbox` | |

---

## 5. API reference

### Camo options (`arc9/client/cl_camo_options.lua`)

| Function | Description |
|---|---|
| `ARC9.RegisterCamoOptions(atttbl)` | registers an overlay camo's options (called automatically on attachment load) |
| `ARC9.GetCamoOptions(matpath)` | the normalised option list, or `nil` |
| `ARC9.GetCamoOptionValue(matpath, param)` | saved value, or the VMT default |
| `ARC9.GetCamoOptionDefault(matpath, param)` | the VMT's original value |
| `ARC9.SetCamoOptionValue(matpath, param, value, nosave)` | applies the value to the material and saves unless `nosave` |
| `ARC9.ResetCamoOptions(matpath)` | clears saved values and restores defaults |
| `ARC9.ApplyCamoOptions(matpath)` | re-applies all values to the material |
| `ARC9.SaveCamoOptions()` | writes the save file (debounced 0.5 s) |
| `ARC9.GetWeaponCamoOptions(wep)` | `matpath, options` for the weapon's equipped overlay camo, or `nil` |

### Customize tabs (`arc9/client/cl_0_customize_tabs.lua`)

| Function | Description |
|---|---|
| `ARC9.RegisterCustomizeTab(id, def)` | adds or replaces a tab |
| `ARC9.GetCustomizeTabs()` | registered tabs, sorted |
| `ARC9.RegisterOptionControl(type, create)` | adds or replaces an option control type |
| `ARC9.CreateOptionsPanel(parent, spec)` | builds an options panel and returns its scroll panel |

### Weapon methods (`weapons/arc9_base/cl_customize_ui_tabs.lua`, `cl_customize_ui.lua`)

| Method | Description |
|---|---|
| `SWEP:SyncCustomizeTabs()` | adds/removes registered tabs in `self.CustomizeButtons`. Returns `changed, activeTabRemoved` |
| `SWEP:RefreshCustomizeTabs()` | syncs and rebuilds the tab bar while the menu is open (called from `PostModify`) |
| `SWEP:OpenRegisteredTab(id, keepsize)` | opens a registered tab |
| `SWEP:BuildCustomizeTabButtons()` | (re)creates the tab buttons from `self.CustomizeButtons` |

### Material helpers (`arc9/client/cl_matproxy.lua`)

| Name | Description |
|---|---|
| `ARC9.CamoProxyMaterials` | set of material names that use a camo proxy, filled as those materials load |
| `ARC9.NormalizeMaterialName(name)` | lowercases a material name, converts `\` to `/`, and strips `materials/` and `.vmt` |

### `ARC9ColorButton` additions (`arc9/client/cl_vgui_elements.lua`)

| Member | Description |
|---|---|
| `button:OnColorChanging(color)` | optional; called live while the picker is open |
| `button:OnColorPicked(color)` | optional; called when the picker closes. When defined, the button does **not** write its convars |

The picker also accepts 3-digit hex (`#F80`) and is kept on-screen. Buttons without these callbacks behave as before.

### Localisation keys

| Key | English |
|---|---|
| `customize.panel.camo` | `CAMO` |
| `customize.options.reset` | `Reset` |
| `customize.camo.note` | `Only you see these changes.` |

---

## 6. Troubleshooting

**Check how an attachment resolved:**

```
lua_run_cl PrintTable(ARC9.Attachments.<shortname>)
```

| Result | Meaning |
|---|---|
| `CustomCamoTexture` still ends in `.vmt` | the new code isn't running (another ARC9 copy, such as the Workshop version, is loaded) |
| `CustomCamoTexture` is the `$basetexture` name | the VMT camo resolved |
| `CustomCamoOverlay` is the material path | the overlay camo resolved |

**Other problems:**

| Symptom | Likely cause |
|---|---|
| Error texture on the gun | VMT missing or no valid `$basetexture`; check console for `[ARC9] Camo material` |
| No change on a weapon | the weapon's VMTs use neither camo proxy, so it can't take camo |
| VMT `$arc9_camo*` value ignored | the attachment sets the same field in Lua |
| Overlay missing on one part | that part's material doesn't use a camo proxy |
| Flickering/striping on the overlay | z-fighting between the overlay and the gun surface |
| No CAMO tab | camo isn't an overlay camo, or `ATT.CustomCamoOptions = false` |
| Proxy-driven option does nothing | the proxy takes a fixed number instead of the `$variable` |
| `attempt to call method ... (a nil value)` after updating | new Lua files were added; restart the game (auto-refresh doesn't load new files) |

After editing a VMT, run `mat_reloadmaterial <name>` or restart the map. After editing attachment Lua, run `arc9_reloadatts` or restart the map.

---

## Known issues

- The basic `CustomCamo` proxy reads `ent.CustomCamoBlend`, but models are given `CustomBlendFactor`. As a result, blend factor never reaches weapons that use the basic proxy. This bug predates the VMT changes.
- Overlay camos cover all camo-able parts with one camo. Per-part advanced camo slots (`IsAdvancedCamo1`, ...) don't apply to overlays.
- Camo options are not networked.
