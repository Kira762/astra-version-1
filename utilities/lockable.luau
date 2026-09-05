local function a1<T>(a2: T): T
    local a3 = a2 :: any

        function a3:Lock(a4: string?)
        self.window:_setElementLocked(self, true, a4)
    end

    function a3:Unlock()
        self.window:_setElementLocked(self, false)
    end

    function a3:IsLocked(): boolean
        return self.locked == true
    end

    return a2
end

return a1
