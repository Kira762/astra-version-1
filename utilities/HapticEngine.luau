local a1 = require(script.Parent.Parent.core.state)

local a2 = {}

a2.enabled = false
type HapticTypes = {
    click: Enum.HapticEffectType?,
    notify: Enum.HapticEffectType?,
}

local a3: HapticTypes = {}
local a4, a5 = pcall(function()
    Instance.new("HapticEffect"):Destroy()     return {
        click = Enum.HapticEffectType.UIHover,         notify = Enum.HapticEffectType.UIClick,     }
end)
if a4 then
    a3 = a5
end

local a6: { [Enum.HapticEffectType]: Instance } = {}
local a7: Instance? = nil

function a2.setContainer(a8: Instance?)
    a7 = a8
end

function a2.releaseContainer(a9: Instance?)
    if a9 == nil or a7 == a9 then
        a7 = nil
    end
end

local function a10(): Instance
    if a7 and a7.Parent then
        return a7
    end
    return a1.guiContainer
end

local function a11(a12: Enum.HapticEffectType): Instance?
    local a13 = a6[a12]
        if a13 and a13.Parent then
        return a13
    end
    local ok, a14 = pcall(Instance.new, "HapticEffect")
    if not ok then
        return nil
    end
    local a15 = a14 :: any
    a15.Type = a12
    local a16 = pcall(function()
        a14.Parent = a10()
    end)
    if not a16 then
        a14:Destroy()
        return nil
    end
    a6[a12] = a14
    return a14
end

local function a17(a18: Enum.HapticEffectType?)
    if not a18 or not a2.enabled then
        return
    end
    local a19 = a11(a18)
    if a19 then
        local a20 = a19 :: any
        pcall(a20.Play, a19)
    end
end

function a2.click()
    a17(a3.click)
end

function a2.notify()
    a17(a3.notify)
end

function a2.setEnabled(a21: boolean?)
    a2.enabled = a21 and true or false
    if not a2.enabled then
        a2.teardown()
    end
end

function a2.teardown()
    for a22, a23 in a6 do
        pcall(a23.Destroy, a23)
        a6[a22] = nil
    end
end

return a2
