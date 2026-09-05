type OrderedElement = {
    main: GuiObject,
    descriptor: { main: GuiObject }?,
}

local function a1(element: OrderedElement, a2: number)
    element.main.LayoutOrder = a2
    if element.descriptor then
        element.descriptor.main.LayoutOrder = a2 + 1
    end
end

return a1
