--!nonstrict
-- iPhone Mirror control panel for Noctalia V5

local snapshot = { running = false, state = "stopped", error = nil }

local function resolveColor(stateName)
  if stateName == "running" then
    return "primary"
  elseif stateName == "starting" or stateName == "stopping" then
    return "warning"
  elseif stateName == "error" then
    return "error"
  else
    return "on_surface_variant"
  end
end

local function resolveStateText(stateName)
  if stateName == "running" then
    return noctalia.tr("widget.state.running")
  elseif stateName == "starting" then
    return noctalia.tr("widget.state.starting")
  elseif stateName == "stopping" then
    return noctalia.tr("widget.state.stopping")
  elseif stateName == "disconnected" then
    return noctalia.tr("widget.state.disconnected")
  elseif stateName == "error" then
    return noctalia.tr("widget.state.error")
  else
    return noctalia.tr("widget.state.stopped")
  end
end

local function render()
  local stateName = snapshot.state or "stopped"
  local isRunning = snapshot.running == true
  local stateColor = resolveColor(stateName)
  local stateText = resolveStateText(stateName)
  local currentError = snapshot.error

  local header = ui.row({ gap = 12, align = "center", padding = 4 }, {
    ui.glyph({ name = "device-mobile", size = 28, color = stateColor }),
    ui.column({ gap = 2, flexGrow = 1 }, {
      ui.label({ text = noctalia.tr("panel.title"), fontSize = 16, fontWeight = "bold" }),
      ui.label({ text = stateText, fontSize = 12, color = stateColor, fontWeight = "medium" }),
    }),
  })

  local descText = isRunning and noctalia.tr("panel.desc_running") or noctalia.tr("panel.desc_stopped")
  local description = ui.label({
    text = descText,
    fontSize = 12,
    color = "on_surface_variant",
    wrap = true,
  })

  local items = {
    header,
    ui.separator({ orientation = "horizontal" }),
    description,
  }

  if currentError and currentError ~= "" then
    table.insert(items, ui.row({
      gap = 8,
      align = "center",
      padding = 8,
      radius = 6,
      fill = "error/0.15",
    }, {
      ui.glyph({ name = "alert-circle", size = 18, color = "error" }),
      ui.label({ text = currentError, fontSize = 11, color = "error", wrap = true, flexGrow = 1 }),
    }))
  end

  local mainActionLabel = isRunning and noctalia.tr("panel.action.focus") or noctalia.tr("panel.action.start")
  local mainActionGlyph = isRunning and "external-link" or "player-play"

  table.insert(items, ui.button({
    text = mainActionLabel,
    glyph = mainActionGlyph,
    variant = "primary",
    controlSize = "md",
    enabled = stateName ~= "stopping",
    onClick = function()
      noctalia.state.set("iphone-mirror.request", { action = "start" })
      panel.close()
    end,
  }))

  if isRunning or stateName == "starting" then
    table.insert(items, ui.button({
      text = noctalia.tr("panel.action.stop"),
      glyph = "player-stop",
      variant = "destructive",
      controlSize = "md",
      enabled = stateName ~= "stopping",
      onClick = function()
        noctalia.state.set("iphone-mirror.request", { action = "stop" })
        panel.close()
      end,
    }))
  end

  panel.render(ui.column({ gap = 12, padding = 16 }, items))
end

function onKey(chord, pressed)
  if chord == "escape" and pressed then
    panel.close()
  end
end

function onOpen(_context)
  local latest = noctalia.state.get("iphone-mirror.state")
  if type(latest) == "table" then
    snapshot = latest
  end
  noctalia.state.set("iphone-mirror.request", { action = "refresh" })
  render()
end

noctalia.state.watch("iphone-mirror.state", function(value)
  if type(value) == "table" then
    snapshot = value
    render()
  end
end)

local initial = noctalia.state.get("iphone-mirror.state")
if type(initial) == "table" then
  snapshot = initial
end
render()
