-- Helper functions to make UI code less verbose

local OUR_NAME, profiler = ...

if not profiler.ui then
    profiler.ui = {}
end
local ui = profiler.ui

if not ui.utility then
    ui.utility = {}
end


-- Colors and texture

function ui.utility.edgecolor(frame, color)
    -- ...yeah. Switch to file edge textures at some point.
    local left = frame:CreateTexture(nil)
    left:SetPoint("topleft", -1, 1)
    left:SetPoint("bottomleft", -1, -1)
    left:SetWidth(1)
    left:SetTexture(unpack(color))
    frame.borderleft = left

    local top = frame:CreateTexture(nil)
    top:SetPoint("topleft", -1, 1)
    top:SetPoint("topright", 1, 1)
    top:SetHeight(1)
    top:SetTexture(unpack(color))
    frame.bordertop = top

    local right = frame:CreateTexture(nil)
    right:SetPoint("topright", 1, 1)
    right:SetPoint("bottomright", 1, -1)
    right:SetWidth(1)
    right:SetTexture(unpack(color))
    frame.borderright = right

    local bottom = frame:CreateTexture(nil)
    bottom:SetPoint("bottomleft",  -1, -1)
    bottom:SetPoint("bottomright",  1, -1)
    bottom:SetHeight(1)
    bottom:SetTexture(unpack(color))
    frame.borderbottom = bottom
end
local edgecolor = ui.utility.edgecolor

function ui.utility.bgcolor(frame, bg, edge)
    local texture = frame:CreateTexture(nil, "MEDIUM")
    texture:SetAllPoints(true)
    texture:SetTexture(unpack(bg))
    frame.texture = texture
    if edge then edgecolor(frame, edge) end
    return texture
end
local bgcolor = ui.utility.bgcolor


-- Elements

function ui.utility.box(parent, bg, name)
    local frame = CreateFrame("Frame", name, parent)
    if bg then bgcolor(frame, bg) end
    return frame
end
