local persistenceWrite = require(script.Parent.filesystem)

local a2 = {}

local a3 = ".saving"

function a2.tempPathFor(a4: string): string
    return a4 .. a3
end

function a2.write(a5: string, a6: string, a7: string)
    local a8 = a2.tempPathFor(a6)

    persistenceWrite.ensureDir(a5)
    persistenceWrite.writefile(a8, a7)

    if persistenceWrite.readfile(a8) ~= a7 then
        error("parked copy did not write cleanly")
    end

    persistenceWrite.writefile(a6, a7)
    pcall(persistenceWrite.delfile, a8)
end

return a2
