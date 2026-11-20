-- VERA · banner de consola (servidor). Copia idéntica en todos los recursos VERA.
--
-- Al arrancar, todos los recursos VERA iniciados se apuntan y uno solo imprime
-- un único bloque con la versión y el estado de cada uno, y avisa de parches y
-- actualizaciones según el archivo público de versiones. Solo sale en la consola
-- del servidor; los jugadores nunca lo ven.
--
-- Convar (en server.cfg):  setr vera:banner "completo"   -- completo | compacto | apagado
--
-- Un recurso puede añadir avisos de instalación antes de que se imprima:
--   VERABanner.warn('Falta vera-qbox-ui · notificaciones de ox_lib')
--   VERABanner.error('No se encuentra la tabla player_vehicles')

if not IsDuplicityVersion() then return end

local BANNER_VERSION = 2
local VERSIONS_URL = 'https://raw.githubusercontent.com/marcos1789/vera-versions/main/versions.json'
local SETTLE_MS = 3000      -- espera sin nuevos recursos VERA antes de imprimir
local HTTP_TIMEOUT_MS = 6000

local RESOURCE = GetCurrentResourceName()
local warnings, errors = {}, {}
local printed = false

VERABanner = {
    warn = function(text)
        warnings[#warnings + 1] = tostring(text)
    end,
    error = function(text)
        errors[#errors + 1] = tostring(text)
    end
}

local function mode()
    local value = GetConvar('vera:banner', 'completo'):lower()
    if value == 'apagado' or value == 'off' or value == 'false' then return 'apagado' end
    if value == 'compacto' or value == 'compact' then return 'compacto' end
    return 'completo'
end

local function info()
    return {
        name = RESOURCE,
        version = GetResourceMetadata(RESOURCE, 'version', 0) or '?',
        warnings = warnings,
        errors = errors,
        banner = BANNER_VERSION
    }
end

-- Comparación de versiones numéricas: -1, 0 o 1.
local function compare(left, right)
    local a, b = {}, {}
    for n in tostring(left):gmatch('%d+') do
        a[#a + 1] = tonumber(n)
    end
    for n in tostring(right):gmatch('%d+') do
        b[#b + 1] = tonumber(n)
    end
    for i = 1, math.max(#a, #b) do
        local x, y = a[i] or 0, b[i] or 0
        if x ~= y then return x < y and -1 or 1 end
    end
    return 0
end

local function samePatchLine(left, right)
    local a, b = {}, {}
    for n in tostring(left):gmatch('%d+') do
        a[#a + 1] = n
    end
    for n in tostring(right):gmatch('%d+') do
        b[#b + 1] = n
    end
    return a[1] == b[1] and a[2] == b[2]
end

-- Estado de un recurso: color, símbolo, texto y si va a la lista de novedades.
local function status(entry, remote)
    if #entry.errors > 0 then return '^1', '✖', entry.errors[1] end
    local latest = remote and remote.version
    if latest and compare(entry.version, latest) < 0 then
        if remote.security then return '^1', '◆', ('Parche de seguridad %s · recomendado'):format(latest), true end
        if samePatchLine(entry.version, latest) then return '^3', '▲', ('Parche %s disponible'):format(latest), true end
        return '^3', '▲', ('Actualización %s disponible'):format(latest), true
    end
    if #entry.warnings > 0 then return '^3', '⚠', entry.warnings[1] end
    return '^2', '✔', latest and 'Al día' or 'Correcto'
end

local function clean(text)
    return (tostring(text or ''):gsub('%^%d', ''):gsub('~[%a_]~', ''))
end

local function pad(text, width)
    text = tostring(text)
    local length = utf8 and utf8.len(text) or #text
    return text .. string.rep(' ', math.max(1, width - (length or #text)))
end

local LOGO = {
    '██╗   ██╗███████╗██████╗  █████╗ ',
    '██║   ██║██╔════╝██╔══██╗██╔══██╗',
    '╚██╗ ██╔╝█████╗  ██████╔╝███████║',
    ' ╚████╔╝ ██╔══╝  ██╔══██╗██╔══██║',
    '  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝'
}
local RULE = '──────────────────────────────────────────────────────────────'

local function render(entries, versions)
    local remote = versions and versions.resources or {}
    table.sort(entries, function(a, b)
        return a.name < b.name
    end)

    local ok, updates, issues, news = 0, 0, 0, {}
    local rows = {}
    for _, entry in ipairs(entries) do
        local color, icon, text, isNews = status(entry, remote[entry.name])
        if isNews then
            updates = updates + 1
        elseif color == '^2' then
            ok = ok + 1
        else
            issues = issues + 1
        end
        if isNews then
            local r = remote[entry.name]
            news[#news + 1] = { color = color, icon = icon, name = entry.name, version = r.version, notes = r.notes }
        end
        rows[#rows + 1] = ('^5│^7  %s%s%s%s %s'):format(pad(entry.name, 24), pad(entry.version, 10), color, icon, text)
    end

    local server = clean(GetConvar('sv_projectName', GetConvar('sv_hostname', 'Servidor')))
    local qbox = GetResourceMetadata('qbx_core', 'version', 0)
    local summary = ('^2%d al día^7 · ^3%d %s^7 · %s%d %s'):format(ok, updates,
        updates == 1 and 'actualización' or 'actualizaciones', issues > 0 and '^1' or '^7', issues, issues == 1 and 'aviso' or 'avisos')
    local side = {
        '^7VERA^7 · Recursos para Qbox',
        ('^7Servidor ^7%s%s'):format(server, qbox and (' · Qbox ' .. qbox) or ''),
        ('^7Arranque ^7%s'):format(os.date('%d/%m/%Y %H:%M')),
        '^7Estado   ' .. summary,
        ''
    }

    local lines = { '', '^5┌' .. RULE }
    for i, logo in ipairs(LOGO) do
        lines[#lines + 1] = ('^5│  %s   %s'):format(logo, side[i])
    end
    lines[#lines + 1] = '^5├' .. RULE
    lines[#lines + 1] = '^5│^7  ' .. pad('RECURSO', 24) .. pad('VERSIÓN', 10) .. 'ESTADO'
    for _, row in ipairs(rows) do
        lines[#lines + 1] = row
    end
    if #news > 0 then
        lines[#lines + 1] = '^5├' .. RULE
        for _, item in ipairs(news) do
            lines[#lines + 1] = ('^5│  %s%s %s %s^7  %s'):format(item.color, item.icon, item.name, item.version, clean(item.notes or ''))
        end
        lines[#lines + 1] = ('^5│^7     Descarga en ^6%s^7 · Novedades en ^6%s'):format(
            clean(versions.download or 'keymaster.fivem.net'), clean(versions.changelog or ''))
    end
    lines[#lines + 1] = '^5└' .. RULE .. '^7'
    lines[#lines + 1] = ''
    return lines, ok, updates, issues, news
end

local function compactLine(entries, versions)
    local _, ok, updates, issues, news = render(entries, versions)
    local parts = {}
    for _, item in ipairs(news) do
        parts[#parts + 1] = ('%s %s'):format(item.name, item.version)
    end
    local tail = #parts > 0 and (' · ^3' .. table.concat(parts, ', ')) or ''
    return ('^5VERA^7 · %d recursos · ^2%d al día^7 · ^3%d actualizaciones^7 · %d avisos%s^7'):format(#entries, ok, updates, issues, tail)
end

local function fetchVersions(callback)
    local done = false
    PerformHttpRequest(VERSIONS_URL, function(code, body)
        if done then return end
        done = true
        local ok, data = pcall(json.decode, body or '')
        callback(code == 200 and ok and type(data) == 'table' and data or nil)
    end, 'GET', '', { ['Cache-Control'] = 'no-cache' })
    SetTimeout(HTTP_TIMEOUT_MS, function()
        if done then return end
        done = true
        callback(nil)
    end)
end

local function print(lines)
    for _, line in ipairs(lines) do
        Citizen.Trace(line .. '^7\n')
    end
end

local function publish(entries)
    local current = mode()
    if current == 'apagado' then return end
    fetchVersions(function(versions)
        if current == 'compacto' then
            print({ compactLine(entries, versions) })
        else
            print((render(entries, versions)))
        end
    end)
end

-- Coordination between VERA resources ----------------------------------------
-- Every VERA resource answers 'vera:banner:collect' with its own real name, so
-- names given with `provide` (for example qbx_radialmenu) never count as VERA
-- resources. The resource with the lowest name prints the banner.
local lastStart = 0
AddEventHandler('onServerResourceStart', function()
    lastStart = GetGameTimer()
end)

local collected
AddEventHandler('vera:banner:collect', function(requester)
    if type(requester) == 'string' then
        TriggerEvent('vera:banner:report', requester, info())
    end
end)
AddEventHandler('vera:banner:report', function(requester, entry)
    if requester == RESOURCE and collected and type(entry) == 'table' then
        collected[#collected + 1] = entry
    end
end)

local function collect()
    collected = {}
    TriggerEvent('vera:banner:collect', RESOURCE)
    local entries = collected
    collected = nil
    return entries
end

-- The printer tells everyone which resources were in the banner. A resource
-- that was already running when the banner went out stays quiet; one started
-- later asks for the list and prints its own line.
local inBanner = false
AddEventHandler('vera:banner:printed', function(names)
    if type(names) ~= 'table' or printed then
        return
    end
    printed = names
    inBanner = names[RESOURCE] == true
end)
AddEventHandler('vera:banner:query', function(requester)
    if type(requester) == 'string' and requester ~= RESOURCE and printed and printed[RESOURCE] then
        TriggerEvent('vera:banner:answer', requester, printed)
    end
end)
AddEventHandler('vera:banner:answer', function(requester, names)
    if requester == RESOURCE and type(names) == 'table' and not printed then
        printed = names
    end
end)

local function oneLine(entry)
    fetchVersions(function(versions)
        local remote = versions and versions.resources and versions.resources[RESOURCE]
        local color, icon, text = status(entry, remote)
        print({ ('^5VERA^7 · %s %s · %s%s %s'):format(RESOURCE, entry.version, color, icon, text) })
    end)
end

local function isPrinter(entries)
    for _, entry in ipairs(entries) do
        if entry.name < RESOURCE then
            return false
        end
    end
    return true
end

-- GetGameTimer only matters as a difference between two readings.
CreateThread(function()
    lastStart = GetGameTimer()
    while GetGameTimer() - lastStart < SETTLE_MS do
        Wait(250)
    end
    if inBanner then
        return
    end
    TriggerEvent('vera:banner:query', RESOURCE)
    if printed then
        -- Started or restarted after the banner was printed: one line for this resource.
        if mode() ~= 'apagado' then
            oneLine(info())
        end
        return
    end
    local entries = collect()
    if not isPrinter(entries) then
        return
    end
    local names = {}
    for _, entry in ipairs(entries) do
        names[entry.name] = true
    end
    TriggerEvent('vera:banner:printed', names)
    publish(entries)
end)
