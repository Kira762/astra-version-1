local a1 = require(script.Parent.services)
local a2 = {}

local a3 = a1.getService("RunService"):IsStudio()
local a4 = not a3
    and typeof(writefile) == "function"
    and typeof(readfile) == "function"
    and typeof(isfile) == "function"
    and typeof(isfolder) == "function"
    and typeof(makefolder) == "function"
    and typeof(listfiles) == "function"
    and typeof(delfile) == "function"
    and typeof(delfolder) == "function"

if a4 then
        function a2.writefile(a5: string, a6: string)
        writefile(a5, a6)
    end

    function a2.readfile(a7: string): string
        return readfile(a7)
    end

            if typeof(appendfile) == "function" then
        function a2.appendfile(a8: string, a9: string)
            appendfile(a8, a9)
        end
    end

    function a2.isfile(a10: string): boolean
        return isfile(a10)
    end

    function a2.delfile(a11: string)
        delfile(a11)
    end

    function a2.listfiles(a12: string): { string }
        return listfiles(a12)
    end

    function a2.makefolder(a13: string)
        makefolder(a13)
    end

    function a2.isfolder(a14: string): boolean
        return isfolder(a14)
    end

    function a2.delfolder(a15: string)
        delfolder(a15)
    end
elseif a3 then
            local a16 = Instance.new("Folder")
    a16.Name = "Filesystem"
    a16.Parent = a1.getService("ReplicatedStorage")

    local function a17(a18: string): { string }
        local a19 = {}
        for a20 in string.gmatch(a18, "[^/]+") do
            table.insert(a19, a20)
        end
        return a19
    end

    local function a21(a22: { string }, a23: boolean): Instance?
        local a24: Instance = a16
        for i = 1, #a22 - 1 do
            local a25 = a24:FindFirstChild(a22[i])
            if not a25 then
                if not a23 then
                    return nil
                end
                local a26 = Instance.new("Folder")
                a26.Name = a22[i]
                a26.Parent = a24
                a25 = a26
            end
            a24 = a25 :: Instance
        end
        return a24
    end

    local function a27(a28: Instance?): StringValue?
        if a28 and a28:IsA("StringValue") then
            return a28
        end
        return nil
    end

    function a2.writefile(a29: string, a30: string)
        local a31 = a17(a29)
        assert(#a31 > 0, "Invalid path")

        local a32 = a21(a31, true)
        assert(a32, "Invalid path")
        local a33 = a31[#a31]

        local a34 = a32:FindFirstChild(a33)
        local a35 = a27(a34)
        if a35 then
            a35.Value = a30
        else
            if a34 then
                a34:Destroy()
            end
            local a36 = Instance.new("StringValue")
            a36.Name = a33
            a36.Value = a30
            a36.Parent = a32
        end
    end

    function a2.readfile(a37: string): string
        local a38 = a17(a37)
        assert(#a38 > 0, "Invalid path")

        local a39 = a21(a38, false)
        assert(a39, "File not found: " .. a37)

        local a40 = a39:FindFirstChild(a38[#a38])
        local a41 = a27(a40)
        assert(a41, "File not found: " .. a37)

        return a41.Value
    end

    function a2.isfile(a42: string): boolean
        local a43 = a17(a42)
        if #a43 == 0 then
            return false
        end

        local a44 = a21(a43, false)
        if not a44 then
            return false
        end

        return a27(a44:FindFirstChild(a43[#a43])) ~= nil
    end

    function a2.listfiles(a45: string): { string }
        local a46 = a17(a45)
        local a47: Instance = a16

        for _, a48 in a46 do
            local a49 = a47:FindFirstChild(a48)
            if not a49 or not a49:IsA("Folder") then
                error("Folder not found: " .. a45)
            end
            a47 = a49
        end

        local a50: { string } = {}
        for _, a51 in a47:GetChildren() do
            table.insert(a50, a45 .. "/" .. a51.Name)
        end
        return a50
    end

    function a2.delfile(a52: string)
        local a53 = a17(a52)
        assert(#a53 > 0, "Invalid path")

        local a54 = a21(a53, false)
        assert(a54, "File not found: " .. a52)

        local a55 = a54:FindFirstChild(a53[#a53])
        local a56 = a27(a55)
        assert(a56, "File not found: " .. a52)

        a56:Destroy()
    end

    function a2.makefolder(a57: string)
        local a58 = a17(a57)
        if #a58 == 0 then
            return
        end

        local a59: Instance = a16
        for _, a60 in a58 do
            local a61 = a59:FindFirstChild(a60)
            if not a61 then
                local a62 = Instance.new("Folder")
                a62.Name = a60
                a62.Parent = a59
                a61 = a62
            end
            a59 = a61 :: Instance
        end
    end

    function a2.isfolder(a63: string): boolean
        local a64 = a17(a63)
        if #a64 == 0 then
            return false
        end

        local a65: Instance = a16
        for _, a66 in a64 do
            local a67 = a65:FindFirstChild(a66)
            if not a67 or not a67:IsA("Folder") then
                return false
            end
            a65 = a67
        end
        return true
    end

    function a2.delfolder(a68: string)
        local a69 = a17(a68)
        assert(#a69 > 0, "Invalid path")

        local a70 = a21(a69, false)
        assert(a70, "Folder not found: " .. a68)

        local a71 = a70:FindFirstChild(a69[#a69])
        assert(a71 and a71:IsA("Folder"), "Folder not found: " .. a68)

        a71:Destroy()
    end
end

if a2.writefile and not a2.appendfile then
    function a2.appendfile(a72: string, a73: string)
        local a74 = if a2.isfile(a72) then a2.readfile(a72) else nil
        a2.writefile(a72, if a74 then a74 .. a73 else a73)
    end
end

function a2.ensureFolder(a75: string)
    if not a2.isfolder(a75) then
        a2.makefolder(a75)
    end
end

function a2.ensureDir(a76: string)
    local a77 = ""
    for a78 in string.gmatch(a76, "[^/]+") do
        a77 = if a77 == "" then a78 else a77 .. "/" .. a78
        if not a2.isfolder(a77) then
            a2.makefolder(a77)
        end
    end
end

return a2
