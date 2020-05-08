local OUR_NAME, profiler = ...


-- Add some Blizzard functions that we are probably exlusive users of to our namespace
profiler.Blizzard = profiler.Blizzard or {}
profiler.Blizzard["UpdateAddOnCPUUsage"] = UpdateAddOnCPUUsage
profiler.Blizzard["UpdateAddOnMemoryUsage"] = UpdateAddOnMemoryUsage
profiler.Blizzard["GetFunctionCPUUsage"] = GetFunctionCPUUsage

local cache = nil or function(f) return f end
local UpdateAddOnCPUUsage    = cache(_G.UpdateAddOnCPUUsage)
local UpdateAddOnMemoryUsage = cache(_G.UpdateAddOnMemoryUsage)
local GetFunctionCPUUsage    = cache(_G.GetFunctionCPUUsage)


function profiler.freezeStartup()
    -- update the cpu value first
    profiler.updateTimes(profiler.namespaces)
    for name,addon in pairs(profiler.namespaces) do
        profiler.updateTimes(addon)
    end

    local ns = profiler.namespaces
    local stack = {}
    repeat
        for i=1,#ns do
            local x = ns[i]
            x.startup = x.cpu
            x.startupp = x.cpup
            stack[#stack+1] = x.namespace
        end
        ns = table.remove(stack)
    until not ns
end


function profiler.updateTimes(namespace, sortby)
    if namespace==profiler.namespaces then
        UpdateAddOnCPUUsage()
        UpdateAddOnMemoryUsage()
    end
    local totalCPU = 0
    local totalCPUp = 0
    local totalMem = 0
    if type(namespace)=="function" then
        local cpu, ncalls = GetFunctionCPUUsage(namespace, false)
        local cpup = GetFunctionCPUUsage(namespace, true)
        return cpu, cpup
    end
    for i=1,#namespace do
        local x = namespace[i]
        if x.type=="addon" then
            x.cpu = GetAddOnCPUUsage(x.name)
            local mem = GetAddOnMemoryUsage(x.name)
            local now = debugprofilestop()
            local dt = now - (x.updated or 0)
            x.memlast = x.mem
            x.mem = mem
            x.memdiff = (mem - x.memlast)/(dt/1000)
        elseif x.type=="function" then
            x.cpu, x.ncalls = GetFunctionCPUUsage(x.fun, false)
            x.cpup = GetFunctionCPUUsage(x.fun, true)
        elseif x.type=="table" then
            x.cpu, x.cpup = profiler.updateTimes(x.namespace, sortby)
        end
        local oldtime = x.updated or debugprofilestop()
        local oldupdatecpu = x.updatecpu or 0
        local oldupdatecpup = x.updatecpup or 0
        x.updated = debugprofilestop()
        x.updatecpu = x.cpu - (x.startup or 0)
        x.updatecpup = (x.cpup or x.cpu) - (x.startupp or x.startup or 0)
        x.updatecpudiff = (x.updatecpu - oldupdatecpu)/(x.updated-oldtime)
        x.updatecpupdiff = (x.updatecpup - oldupdatecpup)/(x.updated-oldtime)

        totalCPU = totalCPU + x.cpu
        totalCPUp = totalCPUp + (x.cpup or x.cpu)
        totalMem = totalMem + (x.mem or 0)
    end

    sortby = sortby or "startup"

    table.sort(namespace, function(a,b)
        if a[sortby]==b[sortby] then
            return a.name<b.name
        else
            if sortby=="name" then return a.name<b.name end
            return (a[sortby] or 0) > (b[sortby] or 0)
        end
    end)

    return totalCPU, totalCPUp, totalMem
end
