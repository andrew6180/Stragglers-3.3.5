-- Static UI data

local OUR_NAME, profiler = ...

if not profiler.ui then
    profiler.ui = {}
end

local ui = profiler.ui
if not ui.data then
    ui.data = {}
end



ui.data.colors = {
    --               R       G      B      A
    window       = {1.00,  0.00,  0.00,  0.00},
    windowborder = {0.00,  0.00,  0.00,  1.00},
    titlebar     = {0.05,  0.05,  0.05,  1.00},
    header       = {0.80,  0.80,  0.80,  1.00},
    footer       = {0.80,  0.80,  0.80,  1.00},
    workspace    = {1.00,  1.00,  1.00,  0.90},
    rowbg        = {1.00,  1.00,  1.00,  1.00},
    namebg       = {0.90,  0.90,  0.90,  1.00},
    cpubg        = {0.90,  0.90,  0.90,  1.00},
    ncallsbg     = {0.90,  0.90,  0.90,  1.00},
    startupbg    = {0.90,  0.90,  0.90,  1.00},
}

ui.data.fonts = {
    title    = "GameFontNormalSmall",
    subtitle = "GameFontDisableSmall",
    text     = "QuestFontNormalSmall",
    value    = "QuestFontNormalSmall",
}

ui.data.size = {
    window = {400, 500},
    titlebar = 20,
    header = 20,
    footer = 20,
    row = 15,
    cpu = 70,
    ncalls = 60,
    startup = 60,
}
