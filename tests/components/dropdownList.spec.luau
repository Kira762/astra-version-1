local helpers = (_G :: any).__RAYFIELD_TEST_HELPERS

return function()
    local Window = helpers.requireComponent("window")
    local windowSizing = helpers.requireUtility("windowSizing")

    describe("component dropdown list", function()
        local window

                local optionHeight = 38
        local optionGap = 5
        local rowStride = optionHeight + optionGap

        local function makeWindow()
            window = Window.new({
                name = "Dropdown Window",
                configuration = { autoSave = false, autoLoad = false },
            })
            window.hidden = false
            return window
        end

                        local windowChromeHeight = windowSizing.profile("top").chromeHeight

        local function makePage(height)
            window.size = UDim2.fromOffset(400, height + windowChromeHeight)
            local tab = window:CreateTab({ name = "Main" })
            tab.tabPage.AbsolutePosition = Vector2.new(0, 0)
            tab.tabPage.AbsoluteWindowSize = Vector2.new(400, height)
            return tab
        end

        local function options(count)
            local names = {}
            for index = 1, count do
                table.insert(names, "Option " .. index)
            end
            return names
        end

        afterEach(function()
            if window and not window.unloaded then
                window:Unload()
            end
            window = nil
        end)

        it("keeps its borders outside the frame that clips its contents", function()
            makeWindow()
            local tab = makePage(400)
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta" },
                value = "Alpha",
                forgetState = true,
            })

                                                expect(drop.main.ClipsDescendants or false).to.equal(false)

                        expect(drop.panel.ClipsDescendants).to.equal(true)
            expect(drop.panelStroke).to.be.ok()
        end)

        it("lifts the header stroke on hover the way every other element does", function()
            makeWindow()
            local tab = makePage(400)
            local drop = tab:CreateDropdown({ name = "Choice", options = { "Alpha" }, forgetState = true })

            window.theme.ElementStrokeTransparency = 0.4
            window.theme.ElementStrokeHoverTransparency = 0.05
            window.theme.ElementStroke = Color3.fromRGB(35, 35, 35)
            window.theme.ElementStrokeHover = Color3.fromRGB(80, 80, 80)
            drop.stroke.Transparency = 0.4
            drop.stroke.Color = window.theme.ElementStroke

                                    drop.main.MouseEnter:Fire()
            expect(drop.stroke.Transparency).to.equal(0.05)
            expect(drop.stroke.Color).to.equal(window.theme.ElementStrokeHover)
            expect(drop.hoverOverlay.BackgroundTransparency).to.equal(0.97)

            drop.main.MouseLeave:Fire()
            expect(drop.stroke.Transparency).to.equal(0.4)
            expect(drop.stroke.Color).to.equal(window.theme.ElementStroke)
        end)

        it("leaves the stroke where it is while the card is open", function()
            makeWindow()
            local tab = makePage(400)
            local drop = tab:CreateDropdown({ name = "Choice", options = { "Alpha" }, forgetState = true })

            window.theme.ElementStrokeTransparency = 0.4
            window.theme.ElementStrokeHoverTransparency = 0.05
            drop.stroke.Transparency = 0.4

            drop:_open()
            drop.main.MouseEnter:Fire()
            expect(drop.stroke.Transparency).to.equal(0.4)
        end)

        it("opens to four rows when the page has room for them", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(2), forgetState = true })

            local two = drop:_openHeight()

            drop:Refresh(options(4))
            local four = drop:_openHeight()
            expect(four - two).to.equal(rowStride * 2)

                        drop:Refresh(options(9))
            expect(drop:_openHeight()).to.equal(four)
        end)

        it("never opens taller than the page it sits on", function()
            makeWindow()
                                    local shortPage = windowSizing.pageHeight(windowSizing.profile("top").minSize.Y, "top")
            local tab = makePage(shortPage)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(9), forgetState = true })

            drop:_open()
            local squeezed = drop:_openHeight()
            expect(squeezed <= shortPage).to.equal(true)
            expect(drop.main.Size.Y.Offset <= shortPage).to.equal(true)

                        expect(squeezed > 41).to.equal(true)

                        local roomy = makePage(500)
            local other = roomy:CreateDropdown({ name = "Choice", options = options(9), forgetState = true })
            expect(other:_openHeight() > squeezed).to.equal(true)
        end)

        it("counts the search bar and the actions row against the page", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(9), forgetState = true })
            local multi = tab:CreateDropdown({
                name = "Many",
                options = options(9),
                multiSelect = true,
                forgetState = true,
            })

                        expect(multi:_openHeight() > drop:_openHeight()).to.equal(true)

                        local closed = drop:_openHeight()
            drop._searchOpen = true
            expect(drop:_openHeight() - closed).to.equal(8)
            drop._searchOpen = false
            expect(drop:_openHeight()).to.equal(closed)
        end)

        it("falls back to the smallest page there can be before anything is laid out", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(9), forgetState = true })

            local measured = drop:_openHeight()

                                    local sized = window.size
            window.size = nil
            local unmeasured = drop:_openHeight()
            window.size = sized

            expect(unmeasured < measured).to.equal(true)
            expect(unmeasured < windowSizing.profile("top").minSize.Y).to.equal(true)
        end)

        it("scrolls the options that dont fit rather than dropping them", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(9), forgetState = true })

                        expect(#drop._optionFrames).to.equal(9)
            expect(drop.list.ClipsDescendants).to.equal(true)
            expect(drop.list.AutomaticCanvasSize).to.equal(Enum.AutomaticSize.Y)
            expect(drop.list.ScrollingDirection).to.equal(Enum.ScrollingDirection.Y)

                        expect(drop.list.ZIndex >= drop.panel.ZIndex).to.equal(true)

            drop:_open()
            drop.list.AbsoluteWindowSize = Vector2.new(300, 4 * rowStride)
            drop.list.AbsoluteCanvasSize = Vector2.new(300, 9 * rowStride)
            drop.list.CanvasPosition = Vector2.new(0, 0)
            drop:_syncScrollHint()
            expect(drop.list.ScrollBarImageTransparency < 1).to.equal(true)

                        drop.list.CanvasPosition = Vector2.new(0, 5 * rowStride)
            drop:_syncScrollHint()
            expect(drop.list.ScrollBarImageTransparency).to.equal(1)

                        drop.list.AbsoluteCanvasSize = Vector2.new(300, 2 * rowStride)
            drop.list.CanvasPosition = Vector2.new(0, 0)
            drop:_syncScrollHint()
            expect(drop.list.ScrollBarImageTransparency).to.equal(1)
        end)

        it("filters the list without losing the rows it hides", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon" },
                forgetState = true,
            })

            drop:_open()
            local all = drop:_openHeight()

            drop:_applyFilter("a")
            expect(drop._optionFrames[2].frame.Visible).to.equal(true)             expect(drop._optionFrames[5].frame.Visible).to.equal(false) 
            drop:_applyFilter("alp")
            expect(drop:_openHeight() < all).to.equal(true)
            expect(drop.emptyLabel.Visible).to.equal(false)

                        drop:_applyFilter("zzz")
            expect(drop.emptyLabel.Visible).to.equal(true)

            drop:_applyFilter("")
            expect(drop.emptyLabel.Visible).to.equal(false)
            expect(drop:_openHeight()).to.equal(all)
        end)

        it("re-selects a pending option once it arrives, through Refresh or Add", function()
            makeWindow()
            local tab = makePage(500)
            local handed
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha" },
                value = "Gamma",                 forgetState = true,
                callback = function(value)
                    handed = value
                end,
            })

            expect(#drop.value).to.equal(0)

            drop:Add("Gamma")
            expect(drop.value[1]).to.equal("Gamma")
            expect(handed).to.equal("Gamma")

                        drop:Refresh({ "Alpha", "Beta" })
            expect(#drop.value).to.equal(0)
            drop:Refresh({ "Alpha", "Gamma" })
            expect(drop.value[1]).to.equal("Gamma")
            expect(#drop._optionFrames).to.equal(2)
        end)

        it("re-points a reused row at its new option, not the one it was built for", function()
            makeWindow()
            local tab = makePage(500)
            local picked
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta", "Gamma" },
                forgetState = true,
                callback = function(value)
                    picked = value
                end,
            })

            local firstRow = drop._optionFrames[1].frame
            drop:Refresh({ "Delta", "Epsilon", "Zeta" })

                        expect(drop._optionFrames[1].frame).to.equal(firstRow)
            expect(#drop._optionFrames).to.equal(3)

                        expect(drop._optionFrames[1].name).to.equal("Delta")
            expect(drop._optionFrames[1].title.Text).to.equal("Delta")
            expect(drop._optionFrames[3].name).to.equal("Zeta")

                        drop:_open()
            drop._optionFrames[1].interact.MouseButton1Click:Fire()
            expect(drop.value[1]).to.equal("Delta")
            expect(picked).to.equal("Delta")
        end)

        it("keeps the rows in the order the options were given", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta" },
                forgetState = true,
            })

            drop:Refresh({ "One", "Two", "Three", "Four" })
            for index, name in { "One", "Two", "Three", "Four" } do
                expect(drop._optionFrames[index].name).to.equal(name)
                expect(drop._optionFrames[index].frame.LayoutOrder).to.equal(index)
            end
        end)

        it("drops the rows it no longer needs and builds the ones it does", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(6), forgetState = true })

            local kept = drop._optionFrames[1].frame
            local surplus = drop._optionFrames[6].frame

            drop:Refresh(options(2))
            expect(#drop._optionFrames).to.equal(2)
            expect(drop._optionFrames[1].frame).to.equal(kept)             expect(surplus.Parent).to.equal(nil) 
            drop:Refresh(options(5))
            expect(#drop._optionFrames).to.equal(5)
            expect(drop._optionFrames[1].frame).to.equal(kept)
            expect(drop._optionFrames[5].name).to.equal("Option 5")
        end)

        it("still fires the callback only when the visible selection moved", function()
            makeWindow()
            local tab = makePage(500)
            local fired = 0
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta" },
                value = "Alpha",
                forgetState = true,
                callback = function()
                    fired += 1
                end,
            })
            fired = 0

                        drop:Refresh({ "Alpha", "Gamma" })
            expect(fired).to.equal(0)
            expect(drop.value[1]).to.equal("Alpha")

                        drop:Refresh({ "Gamma", "Delta" })
            expect(fired).to.equal(1)
            expect(#drop.value).to.equal(0)
        end)

        it("leaves no dead connections behind on the rows it drops", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(10), forgetState = true })

            local before = #drop.connections
            drop:Refresh(options(3))
                        expect(#drop.connections < before).to.equal(true)

            drop:Refresh(options(10))
            drop:Refresh(options(10))             local settled = #drop.connections
            drop:Refresh(options(10))
            expect(#drop.connections).to.equal(settled)
        end)

        it("prunes only the removed option from what it still wants", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta" },
                multiSelect = true,
                forgetState = true,
            })

            drop:Set({ "Alpha", "Beta", "Gamma" })             drop:Remove("Alpha")

            expect(table.find(drop._desiredValue, "Alpha")).to.equal(nil)
            expect(table.find(drop._desiredValue, "Gamma")).to.be.ok()
            expect(#drop.value).to.equal(1)
            expect(drop.value[1]).to.equal("Beta")

                        drop:Add("Gamma")
            expect(#drop.value).to.equal(2)
        end)

        it("tears an option's connections down with its row", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(6), forgetState = true })

            local before = #drop.connections
            for _ = 1, 3 do
                drop:Refresh(options(6))
            end

                        expect(#drop.connections).to.equal(before)
            expect(#drop._optionFrames).to.equal(6)
        end)

        it("selects and clears only what the search is showing", function()
            makeWindow()
            local tab = makePage(500)
            local drop = tab:CreateDropdown({
                name = "Choice",
                options = { "Alpha", "Beta", "Gamma" },
                multiSelect = true,
                forgetState = true,
            })

            drop:Set({ "Beta" })
            drop:_applyFilter("al") 
            local selectAll, clear
            for _, child in drop.actions:GetChildren() do
                if child.Text == "Select all" then
                    selectAll = child
                elseif child.Text == "Clear" then
                    clear = child
                end
            end

            selectAll.MouseButton1Click:Fire()
            expect(#drop.value).to.equal(2)
            expect(table.find(drop.value, "Beta")).to.be.ok()

            clear.MouseButton1Click:Fire()
            expect(#drop.value).to.equal(1)
            expect(drop.value[1]).to.equal("Beta")

                        local single = tab:CreateDropdown({ name = "One", options = { "A", "B" }, forgetState = true })
            expect(single.actions).to.equal(nil)
        end)

        it("scrolls an opened card back inside the page it opened past", function()
            makeWindow()
            local tab = makePage(300)
            local drop = tab:CreateDropdown({ name = "Choice", options = options(6), forgetState = true })

            local page = tab.tabPage
            page.CanvasPosition = Vector2.new(0, 0)

                        drop.main.AbsolutePosition = Vector2.new(0, 260)
            drop:_bringIntoView()
            expect(page.CanvasPosition.Y > 0).to.equal(true)

                        expect(page.CanvasPosition.Y + 300 >= 260 + drop:_openHeight()).to.equal(true)

                        expect(page.CanvasPosition.Y <= 260).to.equal(true)

                        page.CanvasPosition = Vector2.new(0, 0)
            drop.main.AbsolutePosition = Vector2.new(0, 10)
            drop:_bringIntoView()
            expect(page.CanvasPosition.Y).to.equal(0)
        end)

        describe("row order", function()
                                    local function ordersOf(drop)
                local out = {}
                for _, data in drop._optionFrames do
                    table.insert(out, string.format("%s=%d", data.name, data.frame.LayoutOrder))
                end
                return table.concat(out, " ")
            end

            it("keeps LayoutOrder in step with the options after a removal", function()
                makeWindow()
                local tab = makePage(300)
                local drop = tab:CreateDropdown({
                    name = "Choice",
                    options = { "A", "B", "C", "D" },
                    forgetState = true,
                })

                drop:Remove("B")
                drop:Remove("C")
                drop:Add("E")

                expect(table.concat(drop.options, ",")).to.equal("A,D,E")
                                expect(ordersOf(drop)).to.equal("A=1 D=2 E=3")
            end)

            it("still numbers rows from one after shrinking off the end", function()
                makeWindow()
                local tab = makePage(300)
                local drop = tab:CreateDropdown({
                    name = "Choice",
                    options = { "A", "B", "C" },
                    forgetState = true,
                })

                drop:Refresh({ "A" })
                drop:Add("Z")
                expect(ordersOf(drop)).to.equal("A=1 Z=2")
            end)
        end)
    end)
end
