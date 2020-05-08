local OUR_NAME, profiler = ...

profiler.callers = {}
function profilingmonitor(fun, secure)
    local cached = profiler.callers[fun]
    if not cached then
        cached = {
            [0] = {name="callers"},
        }
        profiler.callers[fun] = cached
    end

    local function errhandler(...)
        local s
        if secure then
            s = debugstack(7,1,0)
        else
            s = debugstack(6,1,0)
        end
        local file, lineno, callername = s:match("Interface\\AddOns\\(.-).lua:(%d-):.-function `(.-)'")
        if not callername then
            file, lineno, callername =   s:match("Interface\\(.-).lua:(%d-):.-function `(.-)'")
            if not callername then
                file, lineno, callername = s:match("Interface\\(.-).lua:(%d):.-function <(.-)>")
            end
        end
        if not callername then --TODO: fixme
            callername = "unknown"
            --print() print(debugstack(6, 1, 0)) print()
        end
        local callerinfo = cached[callername]
        if not callerinfo then
            callerinfo = {name=callername, title=callername, type="caller", ncalls=0, cpu=0}
            cached[#cached+1] = callerinfo
            cached[callername] = callerinfo
        end
        callerinfo.ncalls = callerinfo.ncalls + 1
    end
    if not secure then
        return function(...)
            xpcall(function() error("finding callsites the ugly way") end, errhandler)
            -- do prestuff
            local res = fun(...)
            -- do poststuff
            return res
        end
    else
        return function(...)
            xpcall(function() error("finding callsites the ugly way") end, errhandler)
        end
    end
end


profiler.hooks = {}
function profiler.hook(t, name)
    local func = t[name]
    local hookfunc
    if issecurevariable(t, name) then
        hookfunc = profilingmonitor(func, true)
        hooksecurefunc(t, name, hookfunc)
    else
        hookfunc = profilingmonitor(func)
        t[name] = hookfunc
    end
    profiler.hooks[hookfunc] = func
end
