-- UI code for the Profiler window

local OUR_NAME, profiler = ...
local ui = profiler.ui


-- Data

local colors = ui.data.colors
local fonts  = ui.data.fonts
local size   = ui.data.size


-- UI helper functions

local edgecolor = ui.utility.edgecolor
local bgcolor   = ui.utility.bgcolor

local box       = ui.utility.box



local CreateFrame = profilingmonitor(_G.CreateFrame)
profiler.Blizzard.CreateFrame = _G.CreateFrame

--
-- UI
--

ui.Window = CreateFrame("Frame", "ProfilerWindow", UIParent)
local Window = ui.Window

local elapsed = 0
local function updateTimer(self, dT)
    elapsed = elapsed + dT
    if elapsed < 1 then return
    else
        profiler.updateTimes(ui.Window.data, Window.sortby, Window.includeSubroutines)
        ui.Window:update()
        elapsed = 0
    end
end

function Window:init()
    -- Set up the window position, size and textures
    local window = ui.Window
    window:SetSize(unpack(size.window)); window:SetPoint("center");
    bgcolor(window, colors.window, colors.windowborder)
    window:SetMovable(true)
    window:EnableMouse(true)

    local titlebar
    titlebar = box(window, colors.titlebar)
    titlebar:SetPoint("topleft")
    titlebar:SetPoint("topright")
    titlebar:SetHeight(size.titlebar)
    do
        local title
        title = titlebar:CreateFontString(nil, "medium", fonts.title)
        title:SetPoint("left", 2, 0)
        title:SetText("Profiler")
        do
            local scriptProfile = GetCVar("scriptProfile")
            if scriptProfile~="1" then
                title:SetText("!!! You must set CVar 'scriptProfile' to 1 before profiling will work !!!")
            end
        end

        local subtitle
        subtitle = titlebar:CreateFontString(nil, "medium", fonts.subtitle)
        subtitle:SetPoint("left", title, "right", 2, 0)
        subtitle:SetText("Root")

        titlebar:EnableMouse(true)
        -- handlers
        titlebar:SetScript("OnMouseDown", function(self, button)
            if button=="LeftButton" then window:StartMoving()
            else
                if not window.minimized then
                    window.header:Hide()
                    window.workspace:Hide()
                    window.footer:Hide()
                    window.borderright:SetVertexColor(1, 1, 1, 0)
                    window.bordertop:SetVertexColor(1, 1, 1, 0)
                    window.borderbottom:SetVertexColor(1, 1, 1, 0)
                    window.borderleft:SetVertexColor(1, 1, 1, 0)
                    window.minimized = true
                else
                    window.header:Show()
                    window.workspace:Show()
                    window.footer:Show()
                    window.borderright:SetVertexColor(1, 1, 1, 1)
                    window.bordertop:SetVertexColor(1, 1, 1, 1)
                    window.borderbottom:SetVertexColor(1, 1, 1, 1)
                    window.borderleft:SetVertexColor(1, 1, 1, 1)
                    window.minimized = false
                end
            end
        end)
        titlebar:SetScript("OnMouseUp", function(self, button)
            if button=="LeftButton" then window:StopMovingOrSizing() end
        end)

        titlebar.title = title
        titlebar.subtitle = subtitle
    end
    window.titlebar = titlebar

    local header
    header = CreateFrame("Frame", nil, window)
    header:SetPoint("topleft", titlebar, "bottomleft")
    header:SetPoint("topright", titlebar, "bottomright")
    header:SetHeight(size.header)
    bgcolor(header, colors.header)
    do
        local name
        name = CreateFrame("Frame", nil, header)
        name:SetPoint("left")
        name:SetSize(200, size.header)
        name.text = name:CreateFontString(nil, "MEDIUM", fonts.text)
        name.text:SetText("Name")
        name.text:SetPoint("left", 2, 0)
        header.name = name
        name:EnableMouse(true)
        name:SetScript("OnMouseDown", function(...) window.sortby="name" end)

        local cpu
        cpu = CreateFrame("Frame", nil, header)
        cpu:SetPoint("right")
        cpu:SetSize(size.cpu, size.header)
        cpu.text = cpu:CreateFontString(nil, "MEDIUM", fonts.text)
        cpu.text:SetPoint("right", -2, 0)
        local cpumodes = {
            {text="updates",    show="updatecpu",      includeSubroutines=false},
            {text="updates+",   show="updatecpup",     includeSubroutines=true },
            {text="updates/s",  show="updatecpudiff",  includeSubroutines=false},
            {text="update+/s",  show="updatecpupdiff", includeSubroutines=true },
        }
        local currentmode = 1
        local function setmode(n)
            local newmode = cpumodes[n]

            cpu.text:SetText(newmode.text)
            if window.sortby==cpumodes[currentmode].show then
                window.sortby = newmode.show
            end
            cpu.show = newmode.show
            window.includeSubroutines = newmode.includeSubroutines
            currentmode = n
        end
        setmode(currentmode)
        cpu:EnableMouse(true)
        cpu:SetScript("OnMouseDown", function(self, button)
            if button=="LeftButton" then
                window.sortby = cpumodes[currentmode].show
            else
                setmode((currentmode % #cpumodes) + 1)
            end
        end)
        header.cpu = cpu

        local startup
        startup = CreateFrame("Frame", nil, header)
        startup:SetPoint("right", header.cpu, "left")
        startup:SetSize(size.startup, size.header)
        startup.text = startup:CreateFontString(nil, "MEDIUM", fonts.text)
        startup.text:SetPoint("right", -2, 0)
        local startupmodes = {
            {text="startup",       show="startup",       includeSubroutines=false},
            {text="startup+",      show="startupp",      includeSubroutines=true },
        }
        local currentmode = 1
        local function setmode(n)
            local newmode = startupmodes[n]

            startup.text:SetText(newmode.text)
            if window.sortby==startupmodes[currentmode].show then
                window.sortby = newmode.show
            end
            startup.show = newmode.show
            window.includeSubroutines = newmode.includeSubroutines
            currentmode = n
        end
        setmode(currentmode)
        startup:EnableMouse(true)
        startup:SetScript("OnMouseDown", function(self, button)
            if button=="LeftButton" then
                window.sortby = startupmodes[currentmode].show
            else
                setmode((currentmode % #startupmodes) + 1)
            end
        end)
        header.startup = startup

        local ncalls
        ncalls = CreateFrame("Frame", nil, header)
        ncalls:SetPoint("right", header.startup, "left")
        ncalls:SetSize(size.ncalls, size.header)
        ncalls.text = ncalls:CreateFontString(nil, "MEDIUM", fonts.text)
        ncalls.text:SetText("mem/s")
        ncalls.text:SetPoint("right", -2, 0)
        header.ncalls = ncalls
        ncalls:EnableMouse(true)
        ncalls:SetScript("OnMouseDown", function(self, button)
            if button=="LeftButton" then
                if window.data==profiler.namespaces then
                    window.sortby="memdiff"
                else
                    window.sortby="ncalls"
                end
            end
        end)
    end
    window.header = header

    local footer
    footer = CreateFrame("Frame", nil, window)
    footer:SetHeight(size.footer)
    footer:SetPoint("bottomleft")
    footer:SetPoint("bottomright")
    bgcolor(footer, colors.footer)
    window.footer = footer

    local workspace
    workspace = CreateFrame("Frame", nil, window)
    workspace:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    workspace:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT")
    bgcolor(workspace, colors.workspace)
    window.workspace = workspace

    local rows = {}
    do
        local maxRows = math.floor(workspace:GetHeight()/size.row)
        for i=1, maxRows do
            local offset = (i-1)*size.row

            local row
            row = CreateFrame("Frame", nil, workspace)
            row:SetHeight(size.row)
            row:SetPoint("TOPLEFT", workspace, "TOPLEFT", 0, -offset)
            row:SetPoint("TOPRIGHT", workspace, "TOPRIGHT", 0, -offset)
            bgcolor(row, colors.rowbg)

            local columns = {}
            do
                local name
                name = CreateFrame("Frame", nil, row)
                bgcolor(name, colors.namebg)
                name:SetHeight(size.row)
                name:SetPoint("LEFT")
                name.text = name:CreateFontString(nil, "MEDIUM", fonts.text)
                name.text:SetPoint("LEFT", 2, 0)
                name.text:SetText("None")
                columns.name = name

                local cpu
                cpu = CreateFrame("Frame", nil, row)
                bgcolor(cpu, colors.cpubg)
                cpu:SetSize(size.cpu, size.row)
                cpu:SetPoint("RIGHT")
                cpu.text = cpu:CreateFontString(nil, "MEDIUM", fonts.value)
                cpu.text:SetPoint("RIGHT", -2, 0)
                cpu.text:SetText("0.0")
                columns.cpu = cpu

                local startup
                startup = CreateFrame("Frame", nil, row)
                bgcolor(startup, colors.startupbg)
                startup:SetSize(size.startup, size.row)
                startup:SetPoint("right", cpu, "left")
                startup.text = startup:CreateFontString(nil, "MEDIUM", fonts.value)
                startup.text:SetPoint("right", -2, 0)
                startup.text:SetText("0")
                columns.startup = startup

                local ncalls
                ncalls = CreateFrame("Frame", nil, row)
                bgcolor(ncalls, colors.ncallsbg)
                ncalls:SetSize(size.ncalls, size.row)
                ncalls:SetPoint("RIGHT", startup, "LEFT")
                ncalls.text = ncalls:CreateFontString(nil, "MEDIUM", fonts.value)
                ncalls.text:SetPoint("RIGHT", -2, 0)
                ncalls.text:SetText("0")
                columns.ncalls = ncalls

                name:SetPoint("right", ncalls, "left")
            end
            row.columns = columns

            row.id = nil
            rows[#rows+1] = row
            row:EnableMouse(true)
            row:SetScript("OnMouseUp", function(self, button)
                if button=="LeftButton" then
                    local d = window.data[self.id] or window.data
                    if profiler.hooks[d] then d = profiler.hooks[d] end
                    if type(d)=="function" then
                        window.previousdata = window.data
                        window.data = profiler.callers[d] or window.data
                    elseif d.type=="caller" then
                        -- do nothing
                    else
                        window.data = d or window.data
                    end
                    rows.scrolling = 0
                elseif button=="RightButton" then
                    window.data = window.data[-1] or window.previousdata or window.data
                    window.previousdata = nil
                    rows.scrolling = 0
                end
                window.titlebar.subtitle:SetText(window.data[0].name)
                window:update()
            end)
        end
    end

    window:SetScript("OnUpdate", updateTimer)
    window:EnableMouseWheel(true)
    window:SetScript("OnMouseWheel", function(self, delta)
        if #window.data < #window.rows then return end
        rows.scrolling = rows.scrolling - delta
        if rows.scrolling > #window.data - #rows then
            rows.scrolling = #window.data - #rows
        elseif rows.scrolling < 0 then
            rows.scrolling = 0
        end
        window:update()
    end)
    rows.scrolling = 0

    window.rows = rows
    window.data = profiler.namespaces
    profiler.updateTimes(window.data, window.sortby, window.includeSubroutines)
    window:update()
end

function Window:update()
    local window = self
    local rows = window.rows
    local scrolling = rows.scrolling
    local data = window.data

    if data==profiler.namespaces then window.header.ncalls.text:SetText("mem/s")
    else                              window.header.ncalls.text:SetText("ncalls")
    end

    for i=1,#rows do
        local row = rows[i]
        local info = data[i+scrolling]
        if info then
            -- We have a row that contains data, fill out columns depending on what is available:
            row.id = info.name
            row.columns.name.text:SetText(info.title or info.name)

            if info.startup then
                local startup = window.header.startup.show=="startupp" and info.startupp or info.startup
                row.columns.startup.text:SetText(string.format("%6.0fms", startup))
                local grad = math.max(1.0-startup/1000, 0.0)
                row.columns.startup.texture:SetVertexColor(1.0, grad, grad)
            end

            if info.mem then
                row.columns.ncalls.text:SetText(string.format("%+6.2f kb/s", info.memdiff))
            elseif info.ncalls then
                row.columns.ncalls.text:SetText(info.ncalls)
            else
                row.columns.ncalls.text:SetText("")
            end

            if info.cpu then
                if window.header.cpu.show=="updatecpudiff" or window.header.cpu.show=="updatecpupdiff" then
                    local cpudiff = window.header.cpu.show=="updatecpudiff" and info.updatecpudiff or info.updatecpupdiff
                    row.columns.cpu.text:SetText(string.format("%2.4fµs", cpudiff*1000))
                elseif window.header.cpu.show=="updatecpu" then
                    row.columns.cpu.text:SetText(string.format("%6.0fms", info.updatecpu or 0))
                elseif window.header.cpu.show=="updatecpup" then
                    row.columns.cpu.text:SetText(string.format("%6.0fms", info.updatecpup or 0))
                else
                    error("unknown mode for column cpu: "..window.header.cpu.show)
                end
            end

            -- Color text by type:
            if info.type=="table" then
                row.columns.name.text:SetTextColor(0.5, 0.0, 0.0)
                if info.subtype=="frame" then
                    row.columns.name.text:SetTextColor(.0, .0, .5)
                end
            elseif info.type=="addon" then
                row.columns.name.text:SetTextColor(0.0, 0.5, 0.0)
            else
                row.columns.name.text:SetTextColor(0.0, 0.0, 0.0)
            end

        else
            -- The row has no data to show, clear it:
            row.id = nil
            for name,f in pairs(row.columns) do
                -- clear all texts
                f.text:SetText("")
                f.texture:SetVertexColor(unpack(colors.rowbg))
            end
        end
    end
end
