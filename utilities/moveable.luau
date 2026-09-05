local function a1<T>(a2: T): T
    local a3 = a2 :: any

    function a3:MoveTo(a4: number)
        self.tab:_moveElement(self, a4)
    end

    function a3:MoveToTop()
        self.tab:_moveElement(self, 1)
    end

    function a3:MoveToBottom()
        self.tab:_moveElement(self, #self.tab.elements)
    end

    function a3:MoveUp()
        local a5 = table.find(self.tab.elements, self)
        if a5 then
            self.tab:_moveElement(self, a5 - 1)
        end
    end

    function a3:MoveDown()
        local a6 = table.find(self.tab.elements, self)
        if a6 then
            self.tab:_moveElement(self, a6 + 1)
        end
    end

    return a2
end

return a1
