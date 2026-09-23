--!nonstrict
-- iPhone Mirror bar widget for Noctalia V5

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
  local glyphName = noctalia.getConfig("glyph") or "device-mobile"
  local showStatus = noctalia.getConfig("show_status_text") == true
  local stateName = snapshot.state or "stopped"
  local stateColor = resolveColor(stateName)
  local stateText = resolveStateText(stateName)

  barWidget.setTooltip("iPhone Mirror\n" .. stateText)

  local icon = ui.glyph({ name = glyphName, color = stateColor })

  if barWidget.isVertical() then
    barWidget.render(ui.column({ align = "center" }, { icon }))
    return
  end

  local children = { icon }
  if showStatus then
    table.insert(children, ui.label({ text = stateText, color = stateColor, fontWeight = "medium" }))
  end
  barWidget.render(ui.row({ gap = 6, align = "center" }, children))
end

function update()
  render()
end

function onClick()
  noctalia.togglePanel("quantumfire/iphone-mirror:panel")
end

function onRightClick()
  if snapshot.running then
    noctalia.state.set("iphone-mirror.request", { action = "stop" })
  else
    noctalia.state.set("iphone-mirror.request", { action = "start" })
  end
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
