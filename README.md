# Profiler for World of Warcraft
A profiler for WoW addons that tries to go deeper.

## For users
Find out which addons...
- Are increasing your startup times the most.
- Have the heaviest CPU-cost while the game is running.

## For developers
Shows the total CPU used and times called for all found functions in the global namespace and groups them by addon structure.

There is not much that can be done to track locals automatically, but addon authors can easily improve functionality by exposing local tables globally like so:

    if Profiler then _G.PublicTable = privateTable end


As an experimental feature, the Profiler can try to find out callers to functions. This is currently done with plain brute force by hooking the function, throwing an error and parsing the debugstack. As you might expect this is far too heavyweight to do automatically. The recommended approach is to do the following in your source:

    local cache = profilingmonitor or function(f) return f end
    local CreateFrame = cache(_G.CreateFrame)

There will be support for figuring out _where_ in a function the time is spent in the future that will work much like debugging prints - there is no reasonable way to do this automatically.

## Follow the development
Each [release](https://github.com/dualcoding/wow-profiler/releases) documents what has changed since the last one.

 [Milestones](https://github.com/dualcoding/wow-profiler/milestones) acts as a rough roadmap for future development. Have a look what is [currently](https://github.com/dualcoding/wow-profiler/milestones/current) in development or what is likely to be worked on [next](https://github.com/dualcoding/wow-profiler/milestones/next).

## Suggestions
Feel free to open issues and pull request, and let me know what you think!

# 3.3.5a 
just added frame:EnableMouse(true) and changed SetColorTexture to SetTexture. 
