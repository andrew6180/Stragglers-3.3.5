local OUR_NAME, profiler = ...

local known = {}
function profiler.newGlobals()
    -- traverse global namespace looking for unknown names
    local new = {}
    for key,value in pairs(_G) do
        if type(key)=="string" and not known[key] then
            known[key] = value
            if type(value)=="function" or type(value)=="table" then
                new[key] = value
            end
        end
    end
    return new
end


profiler.namespaces = {
    [0] = {name="Root", title="Root", cpu=0, mem=0, value=profiler.namespaces}
}
function profiler.registerNamespace(name, namespace, parent, seen)
    if not seen then
        -- break cycles and avoid misattribution
        seen = {
            [_G] = true,
            [profiler.namespaces] = true,
        }
    end

    local this = {}

    for key,value in pairs(namespace) do
        if type(value)=="function" and type(key)=="string" then
            this[key] = value
            this[#this+1] = {name=key, title=key, fun=value, cpu=0, type="function"}
        end

        if type(value)=="table" and type(key)=="string" and not seen[value] then
            seen[value] = true
            local child = profiler.registerNamespace(key, value, this, seen)
            if child then
                this[key] = child
                this[#this+1] = {name=key, title=key, namespace=child, type="table", cpu=0}
                if rawget(value, 0) and type(rawget(value,0))=="userdata" then
                    this[#this].subtype = "frame"
                end
            end
            seen[value] = nil
        end
    end

    if #this>0 then
        if not parent then
            parent = profiler.namespaces
            parent[#parent+1] = {name=name, title=name, namespace=this, type="addon", cpu=0, mem=0}
            parent[name] = this
        end
        this[-1] = parent
        this[0] = {name=name,title=name,namespace=this,type="table"}
        return this
    else
        return nil
    end
end
