local helpers = (_G :: any).__ASTRA_TEST_HELPERS

return function()
    local Window = helpers.requireComponent("window")
    local locale = helpers.requireUtility("locale")

    describe("component text", function()
        local window

        local function makeWindow()
            window = Window.new({
                name = "Text Window",
                configuration = { autoSave = false, autoLoad = false },
            })
            return window
        end

        afterEach(function()
            if window and not window.unloaded then
                window:Unload()
            end
            window = nil

                        locale.strings["zz-test"] = nil
            locale.setActive("en")
        end)

        it("puts a title over a body on a card", function()
            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })

            local text = tab:CreateText({
                name = "Heading",
                text = "A body long enough to wrap onto a second line when the window is narrow.",
            })
            expect(text.__type).to.equal("Text")
            expect(text.title.Text).to.equal("Heading")
            expect(text.body.Text:find("A body", 1, true)).to.be.ok()
            expect(text.titleRow.Visible).to.equal(true)
            expect(text.body.Visible).to.equal(true)

                        expect(text.main.AutomaticSize).to.equal(Enum.AutomaticSize.Y)
            expect(text.stroke).to.be.ok()

            expect(table.find(tab.elements, text)).to.be.ok()

            local withIcon = tab:CreateText({ name = "Titled", icon = 123 })
            expect(withIcon.iconLabel).to.be.ok()
        end)

        it("takes either half on its own without reserving room for the other", function()
            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })

            local titleOnly = tab:CreateText({ name = "Just a heading" })
            expect(titleOnly.titleRow.Visible).to.equal(true)
            expect(titleOnly.body.Visible).to.equal(false)

                                                local bodyOnly = tab:CreateText({ text = "Just a body" })
            expect(bodyOnly.titleRow.Visible).to.equal(false)
            expect(bodyOnly.body.Visible).to.equal(true)

            local padding
            for _, child in bodyOnly.main:GetChildren() do
                if child.ClassName == "UIPadding" then
                    padding = child
                end
            end
            expect(padding.PaddingTop).to.equal(padding.PaddingBottom)

                        local iconOnly = tab:CreateText({ text = "Body", icon = 123 })
            expect(iconOnly.titleRow.Visible).to.equal(true)
        end)

        it("swaps either half after the fact", function()
            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })

            local text = tab:CreateText({ name = "Heading", text = "Body" })

            text:Set("New body")
            expect(text.body.Text).to.equal("New body")
            expect(text.title.Text).to.equal("Heading")

            text:SetTitle("New heading")
            expect(text.title.Text).to.equal("New heading")
            expect(text.body.Text).to.equal("New body")

                        text:Set("")
            expect(text.body.Visible).to.equal(false)
            text:SetTitle("")
            expect(text.titleRow.Visible).to.equal(false)

                        local bodyOnly = tab:CreateText({ text = "Body" })
            bodyOnly:SetTitle("Grown a heading")
            expect(bodyOnly.titleRow.Visible).to.equal(true)
            expect(bodyOnly.title.Text).to.equal("Grown a heading")
        end)

        it("keeps copy set after the fact through a language change", function()
            local w = makeWindow()
            w:RegisterTranslations({
                ["zz-test"] = {
                    ["Built with this"] = "Bwt",
                    ["Set after the fact"] = "Satf",
                    ["New heading"] = "Nh",
                },
            })

            local tab = w:CreateTab({ name = "Main" })
            local text = tab:CreateText({ name = "Original heading", text = "Built with this" })
            expect(text.body.Text).to.equal("Built with this")

            text:Set("Set after the fact")
            text:SetTitle("New heading")

                                                w:SetLocale("zz-test")
            expect(text.body.Text).to.equal("Satf")
            expect(text.title.Text).to.equal("Nh")

                        text:Set("Built with this")
            expect(text.body.Text).to.equal("Bwt")

            w:SetLocale("en")
            expect(text.body.Text).to.equal("Built with this")
        end)

        it("reveals and hides with the rest of the page", function()
            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })
            local text = tab:CreateText({ name = "Heading", text = "Body", icon = 1 })

            text:_setShown(false, false)
            expect(text.main.BackgroundTransparency).to.equal(1)
            expect(text.title.TextTransparency).to.equal(1)
            expect(text.body.TextTransparency).to.equal(1)
            expect(text.iconLabel.ImageTransparency).to.equal(1)

            text:_setShown(true, false)
            expect(text.title.TextTransparency).to.equal(0)
            expect(text.body.TextTransparency < 1).to.equal(true)
            expect(text.iconLabel.ImageTransparency).to.equal(0)
        end)

        it("restyles on a theme change", function()
            local w = makeWindow()
            local frost = helpers.requireTheme("frost")
            local tab = w:CreateTab({ name = "Main" })
            local text = tab:CreateText({ name = "Heading", text = "Body" })

            expect(text.title.TextColor3).never.to.equal(frost.TitlingColor)

            w:ChangeTheme("frost")
            expect(text.title.TextColor3).to.equal(frost.TitlingColor)
            expect(text.body.TextColor3).to.equal(frost.ContentColor)
            expect(text.stroke.Color).to.equal(frost.ElementStroke)
        end)

        it("holds no value, so nothing about it is saved", function()
            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })
            local text = tab:CreateText({ name = "Heading", text = "Body" })

            expect(text.flag).to.equal(nil)
            expect(text.value).to.equal(nil)
            for _, control in w.controls do
                expect(control).never.to.equal(text)
            end
        end)

        it("reorders like every other element", function()
            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })
            tab:CreateButton({ name = "First" })
            local text = tab:CreateText({ text = "Second" })

            text:MoveToTop()
            expect(tab.elements[1]).to.equal(text)

            text:MoveToBottom()
            expect(tab.elements[#tab.elements]).to.equal(text)
        end)

        it("goes home when its tab is removed, connections and all", function()
            local w = makeWindow()
            local connectionsBefore = #w.connections

            local tab = w:CreateTab({ name = "Doomed" })
            local text = tab:CreateText({ name = "Heading", text = "Body" })
            local instancesBefore = #w.instances

            tab:Remove()
            expect(#w.instances < instancesBefore).to.equal(true)
            expect(#w.connections).to.equal(connectionsBefore)
            expect(text.connections).to.equal(nil)
        end)

        it("builds in a column but not in a row", function()
            local logModule = helpers.requireUtility("log")
            local originalWarn = logModule.warn
            local warned = false
            logModule.warn = function(...)
                warned = warned or tostring((...)):find("a row only holds compact elements", 1, true) ~= nil
            end

            local w = makeWindow()
            local tab = w:CreateTab({ name = "Main" })

            local column = tab:CreateGroup({ direction = "column" })
            expect(column:CreateText({ name = "Column Text" }).__type).to.equal("Text")

            local row = tab:CreateGroup({ direction = "row" })
            expect(row:CreateText({ name = "Nope" })).to.equal(nil)
            expect(warned).to.equal(true)

            logModule.warn = originalWarn
        end)
    end)
end
