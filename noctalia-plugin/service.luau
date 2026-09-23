--!nonstrict
-- iPhone Mirror headless background service for Noctalia

local lastError = nil

local function getMirrorCmd()
  if noctalia.commandExists("iphone-mirror") then
    return "iphone-mirror"
  end
  local localBin = noctalia.expandPath("~/.local/bin/iphone-mirror")
  if noctalia.fileExists(localBin) then
    return localBin
  end
  return "iphone-mirror"
end

local function parseStatus(text)
  local decoded = noctalia.json.decode(text)
  if type(decoded) == "table" and type(decoded.running) == "boolean" and type(decoded.state) == "string" then
    return decoded
  end
  return nil
end

local function publishStatus(data)
  noctalia.state.set("iphone-mirror.state", data)
  if data.state == "error" and data.error and data.error ~= "" then
    if data.error ~= lastError then
      lastError = data.error
      noctalia.notifyError("iPhone Mirror", data.error)
    end
  else
    lastError = nil
  end
end

local function queryStatus()
  local cmd = getMirrorCmd()
  noctalia.runAsync({ cmd, "status" }, function(result)
    if result.exitCode == 0 and result.stdout and result.stdout ~= "" then
      local parsed = parseStatus(result.stdout)
      if parsed then
        publishStatus(parsed)
        return
      end
    end
    local errMsg = noctalia.string.trim(result.stderr)
    if errMsg == "" then
      errMsg = "Could not read iPhone Mirror status."
    end
    publishStatus({
      running = false,
      state = "error",
      error = errMsg,
      pid = 0,
    })
  end)
end

local function runAction(action)
  local cmd = getMirrorCmd()
  noctalia.runAsync({ cmd, action }, function(result)
    if result.exitCode ~= 0 then
      local err = noctalia.string.trim(result.stderr)
      if err == "" then
        err = "Action " .. action .. " failed."
      end
      noctalia.notifyError("iPhone Mirror", err)
    end
    queryStatus()
  end)
end

noctalia.setUpdateInterval(1000)

function update()
  queryStatus()
end

noctalia.state.watch("iphone-mirror.request", function(req)
  if type(req) ~= "table" or type(req.action) ~= "string" then
    return
  end
  if req.action == "refresh" then
    queryStatus()
  elseif req.action == "start" or req.action == "stop" or req.action == "restart" then
    runAction(req.action)
  end
end)

queryStatus()
