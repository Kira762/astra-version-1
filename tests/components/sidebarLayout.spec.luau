local helpers = (_G :: any).__ASTRA_TEST_HELPERS

return function()
    local Window = helpers.requireComponent("window")
    local layouts = helpers.requireUtility("layouts")
    local variables = helpers.requireUtility("variables")

    describe("component sidebar layout", function()
        local window

        local function makeWindow(properties)
            properties = properties or {}
            properties.name = properties.name or "Sidebar Window"
            properties.configuration = { autoSave = false, autoLoad = false }

            window = Window.new(properties)
            window.hidden = false
            return window
        end

                local function makeSidebar(properties)
            properties = properties or {}
            properties.sidebarLayout = true
            return makeWindow(properties)
        end

        afterEach(function()
            if window and not window.unloaded then
                window:Unload()
            end
            window = nil
        end)

        it("defaults to the top layout unless the sidebar is asked for", function()
            expect(makeWindow().layout).to.equal(layouts.top)
            window:Unload()

            expect(makeWindow({ sidebarLayout = false }).layout).to.equal(layouts.top)
            window:Unload()

            expect(makeSidebar().layout).to.equal(layouts.sidebar)
        end)

        it("builds a rail instead of a strip, and the card beside it", function()
            makeSidebar()

            expect(window.sidebar).never.to.equal(nil)
            expect(window.tabList.Parent).to.equal(window.sidebar)
            expect(window.tabListLayout.FillDirection).to.equal(Enum.FillDirection.Vertical)

                        local rail = window.sidebar.Size.X.Offset
            expect(rail).to.equal(layouts.sidebar.railWidth)
            expect(window.elements.Size.X.Offset).to.equal(-rail)
            expect(window.elements.Size.X.Scale).to.equal(1)

                        expect(window.sidebar.Size.Y.Offset).to.equal(-layouts.sidebar.chromeHeight)
            expect(window.elements.Size.Y.Offset).to.equal(-layouts.sidebar.chromeHeight)
        end)

        it("makes the content a card, and leaves it plain under top tabs", function()
            makeSidebar()
            expect(window.elementsStroke).never.to.equal(nil)
                        expect(window.elementsCorner.TopLeftRadius).to.equal(window.theme.CornerRoundness)
            expect(window.elementsCorner.BottomRightRadius).to.equal(window.theme.CornerRoundness)
            expect(window.elementsCorner.TopRightRadius).to.equal(UDim.new(0, 0))
            expect(window.elementsCorner.BottomLeftRadius).to.equal(UDim.new(0, 0))
            window:Unload()

            makeWindow()
            expect(window.elementsStroke).to.equal(nil)
            expect(window.elementsCorner).to.equal(nil)
            expect(window.sidebar).to.equal(nil)
            expect(window.tabListLayout.FillDirection).to.equal(Enum.FillDirection.Horizontal)
        end)

        it("keeps the fade over the card rather than the whole window", function()
            makeSidebar()
            expect(window.bottomFade.Size.X.Offset).to.equal(-layouts.sidebar.railWidth)

                        expect(window.bottomFadeCorner.BottomRightRadius).to.equal(window.theme.CornerRoundness)
            expect(window.bottomFadeCorner.BottomLeftRadius).to.equal(UDim.new(0, 0))
            window:Unload()

            makeWindow()
            expect(window.bottomFade.Size.X.Offset).to.equal(0)
            expect(window.bottomFade.Size.X.Scale).to.equal(1)

                        expect(window.bottomFadeCorner.CornerRadius).to.equal(window.theme.CornerRoundness)
        end)

        it("slides the pages the way the selector runs", function()
            makeSidebar()
            expect(window.elementsLayout.FillDirection).to.equal(Enum.FillDirection.Vertical)
            window:Unload()

            makeWindow()
            expect(window.elementsLayout.FillDirection).to.equal(Enum.FillDirection.Horizontal)
        end)

        it("lifts the selected row on a wide, shallow glow", function()
            makeSidebar()
            local tab = window:CreateTab({ name = "Main" })

            expect(tab.topbarItemShadow.BlurRadius).to.equal(UDim.new(0, 20))
            expect(tab.topbarItemShadow.Offset).to.equal(UDim2.new(0, 0, 0, -15))
            expect(tab.topbarItemShadow.Spread).to.equal(UDim2.new(0, 10, 0, -30))
        end)

        it("builds rows rather than pills, sharing the parts the pill uses", function()
            makeSidebar()
            local tab = window:CreateTab({ name = "Main", icon = 0 })

                        expect(tab.topbarItem.Size.X.Scale).to.equal(1)
            expect(tab.topbarItem.Size.Y.Offset).to.equal(layouts.sidebar.rowHeight)

                        expect(tab.topbarItemInteract).never.to.equal(nil)
            expect(tab.topbarItemStroke).never.to.equal(nil)
            expect(tab.topbarItemGradient).never.to.equal(nil)
            expect(tab.topbarItemStrokeGradient).never.to.equal(nil)
            expect(tab.topbarItemTitle).never.to.equal(nil)

                        expect(tab.topbarItemShadow).never.to.equal(nil)
        end)

        it("selects a row with its own transparencies, not the pill's", function()
            makeSidebar()
            local tab = window:CreateTab({ name = "Main" })

            tab:_applyVisual("selected", nil)
            expect(tab.topbarItem.BackgroundTransparency).to.equal(0.4)
            expect(tab.topbarItemStroke.Transparency).to.equal(0.5)
            expect(tab.topbarItemShadow.Transparency).to.equal(0.8)
            expect(tab.topbarItemTitle.TextTransparency).to.equal(0)

                        tab:_applyVisual("unselected", nil)
            expect(tab.topbarItem.BackgroundTransparency).to.equal(1)
            expect(tab.topbarItemStroke.Transparency).to.equal(1)
            expect(tab.topbarItemShadow.Transparency).to.equal(1)
            expect(tab.topbarItemTitle.TextTransparency).to.equal(0.5)

            tab:_applyVisual("hidden", nil)
            expect(tab.topbarItemTitle.TextTransparency).to.equal(1)
        end)

        it("drops the row labels and gives the card the width back when the window is narrow", function()
            makeSidebar()
            local tab = window:CreateTab({ name = "Main", icon = 0 })
            local layout = layouts.sidebar

            window.size = UDim2.fromOffset(layout.railCollapseBelow - 1, 400)
            window:_applyRailWidth()

            expect(window.sidebar.Size.X.Offset).to.equal(layout.railCollapsedWidth)
            expect(window.elements.Size.X.Offset).to.equal(-layout.railCollapsedWidth)
            expect(window.bottomFade.Size.X.Offset).to.equal(-layout.railCollapsedWidth)
            expect(tab.topbarItemTitle.Visible).to.equal(false)
            expect(tab.topbarItemLayout.HorizontalAlignment).to.equal(Enum.HorizontalAlignment.Center)
            expect(window.profileLabels.Visible).to.equal(false)

                        window.size = UDim2.fromOffset(layout.railCollapseBelow + 100, 400)
            window:_applyRailWidth()

            expect(window.sidebar.Size.X.Offset).to.equal(layout.railWidth)
            expect(tab.topbarItemTitle.Visible).to.equal(true)
            expect(tab.topbarItemLayout.HorizontalAlignment).to.equal(Enum.HorizontalAlignment.Left)
            expect(window.profileLabels.Visible).to.equal(true)
        end)

        it("stands an initial in for a tab with no icon once the rail collapses", function()
            makeSidebar()
            local layout = layouts.sidebar
            local named = window:CreateTab({ name = "Combat" })
            local iconed = window:CreateTab({ name = "Home", icon = 0 })

                        expect(named.topbarItemInitial).never.to.equal(nil)
            expect(named.topbarItemInitial.Visible).to.equal(false)
            expect(named.topbarItemInitial.Text).to.equal("C")
                        expect(iconed.topbarItemInitial).to.equal(nil)

            window.size = UDim2.fromOffset(layout.railCollapseBelow - 1, 400)
            window:_applyRailWidth()

                        expect(named.topbarItemTitle.Visible).to.equal(false)
            expect(named.topbarItemInitial.Visible).to.equal(true)

            window.size = UDim2.fromOffset(layout.railCollapseBelow + 100, 400)
            window:_applyRailWidth()
            expect(named.topbarItemInitial.Visible).to.equal(false)
            expect(named.topbarItemTitle.Visible).to.equal(true)
        end)

        it("builds no stand-in for the top layout, which never collapses", function()
            makeWindow()
            local tab = window:CreateTab({ name = "Combat" })
            expect(tab.topbarItemInitial).to.equal(nil)
        end)

        it("takes a whole character for the initial, not half a multi-byte one", function()
            makeSidebar()
            local tab = window:CreateTab({ name = "Ñandú" })
            expect(tab.topbarItemInitial.Text).to.equal("Ñ")

            local emoji = window:CreateTab({ name = "🔥 Hot" })
            expect(emoji.topbarItemInitial.Text).to.equal("🔥")
        end)

        it("fades the initial with the rest of the row", function()
            makeSidebar()
            local tab = window:CreateTab({ name = "Combat" })

            tab:_applyVisual("selected", nil)
            expect(tab.topbarItemInitial.TextTransparency).to.equal(0)
            tab:_applyVisual("unselected", nil)
            expect(tab.topbarItemInitial.TextTransparency).to.equal(0.5)
            tab:_applyVisual("hidden", nil)
            expect(tab.topbarItemInitial.TextTransparency).to.equal(1)
        end)

        it("shows the signed-in player at the base of the rail", function()
            makeSidebar()

            expect(window.profile).never.to.equal(nil)
            expect(window.profileName.Text).to.equal(variables.localPlayer.DisplayName)
            expect(window.profile.Size.Y.Offset).to.equal(layouts.sidebar.footerHeight)

                        expect(window.tabList.Size.Y.Offset).to.equal(-layouts.sidebar.footerHeight)
        end)

        it("leaves the name on its own until a profile line is set", function()
            makeSidebar()
            expect(window.profileSubtitle.Visible).to.equal(false)
            expect(window.profileSubtitle.Text).to.equal("")

            window:SetProfile("Premium")
            expect(window.profileSubtitle.Visible).to.equal(true)
            expect(window.profileSubtitle.Text).to.equal("Premium")

            window:SetProfile("")
            expect(window.profileSubtitle.Visible).to.equal(false)

            window:SetProfile("Tier 3")
            expect(window.profileSubtitle.Text).to.equal("Tier 3")
            window:SetProfile(nil)
            expect(window.profileSubtitle.Visible).to.equal(false)
        end)

        it("takes the profile line straight from the window properties", function()
            makeSidebar({ profile = "Premium" })
            expect(window.profileSubtitle.Visible).to.equal(true)
            expect(window.profileSubtitle.Text).to.equal("Premium")
        end)

        it("gives the rows the whole rail when the profile is turned off", function()
            makeSidebar()
            local sidebarModule = helpers.requireComponent("sidebar")

                        sidebarModule.setProfileEnabled(window, false)
            expect(window.settings.showProfile).to.equal(false)
            expect(window.profile.Visible).to.equal(true)
            expect(window.profileName.TextTransparency).to.equal(1)

            sidebarModule.reflowProfile(window)             expect(window.profile.Visible).to.equal(false)
            expect(window.tabList.Size.Y.Offset).to.equal(0)
            expect(window.tabList.Size.Y.Scale).to.equal(1)

            sidebarModule.setProfileEnabled(window, true)
            expect(window.profile.Visible).to.equal(true)
            expect(window.profileName.TextTransparency).to.equal(0)
            expect(window.tabList.Size.Y.Offset).to.equal(-layouts.sidebar.footerHeight)
        end)

        it("saves the profile switch alongside the other settings", function()
            makeSidebar()
            expect(window.settings.showProfile).to.equal(true)

            local persistence = helpers.requireUtility("persistenceSettings")
            window.settings.showProfile = false
            expect(persistence.saveSettings(window)).to.equal(true)

            window.settings.showProfile = true
            expect(persistence.loadSettings(window)).to.equal(true)
            expect(window.settings.showProfile).to.equal(false)

                        window.settings.showProfile = true
            expect(persistence.saveSettings(window)).to.equal(true)
        end)

        it("leaves the rail alone while the search field is open", function()
            makeSidebar()
            window:CreateTab({ name = "Main" })
            local search = helpers.requireComponent("search")

            search.open(window)
            expect(window._searching).to.equal(true)
                        expect(window.tabList.Visible).to.equal(true)

            search.close(window, { showTabs = true })
            expect(window._searching).to.equal(false)
            expect(window.tabList.Visible).to.equal(true)
        end)

        it("sizes the search field to the card, and keeps it there as the rail collapses", function()
            makeSidebar()
            local layout = layouts.sidebar

            expect(window.searchPill.Size.X.Offset).to.equal(-(layout.railWidth + 30))

            window.size = UDim2.fromOffset(layout.railCollapseBelow - 1, 400)
            window:_applyRailWidth()
            expect(window.searchPill.Size.X.Offset).to.equal(-(layout.railCollapsedWidth + 30))
        end)

        it("hides the rail with the rest of the content, never on its own", function()
            makeSidebar()

            window:_setContentVisible(false)
            expect(window.sidebar.Visible).to.equal(false)
            expect(window.elements.Visible).to.equal(false)
            expect(window.tabList.Visible).to.equal(false)

            window:_setContentVisible(true)
            expect(window.sidebar.Visible).to.equal(true)
            expect(window.elements.Visible).to.equal(true)
            expect(window.tabList.Visible).to.equal(true)
        end)

        it("fades the card and the profile with the window's other surfaces", function()
            makeSidebar()

            window:_fadeSurfaces(true, nil)
            expect(window.elements.BackgroundTransparency).to.equal(layouts.sidebar.cardTransparency)
            expect(window.elementsStroke.Transparency).to.equal(0)
            expect(window.bottomFade.BackgroundTransparency).to.equal(0)
            expect(window.profileName.TextTransparency).to.equal(0)
            expect(window.profileAvatar.ImageTransparency).to.equal(0)

            window:_fadeSurfaces(false, nil)
            expect(window.elements.BackgroundTransparency).to.equal(1)
            expect(window.elementsStroke.Transparency).to.equal(1)
            expect(window.profileName.TextTransparency).to.equal(1)
            expect(window.profileAvatar.ImageTransparency).to.equal(1)
        end)

        it("minimises to the topbar, whichever layout it is", function()
            makeWindow()
            expect(window.topbar.Size.Y.Offset).to.equal(layouts.top.topbarHeight)
            window:Unload()

            makeSidebar()
            expect(window.topbar.Size.Y.Offset).to.equal(layouts.sidebar.topbarHeight)
        end)

        describe("rail sections", function()
            local function paddingOf(section)
                return section.padding.PaddingTop.Offset
            end

            it("heads the rail with no space above, and takes a gap once something is", function()
                makeSidebar()

                local first = window:CreateSection({ name = "General" })
                expect(first.main.Parent).to.equal(window.tabList)
                expect(paddingOf(first)).to.equal(0)

                                local second = window:CreateSection({ name = "Modes" })
                expect(paddingOf(second)).to.equal(6)

                window:CreateTab({ name = "Home" })
                local third = window:CreateSection({ name = "Reference" })
                expect(paddingOf(third)).to.equal(6)
            end)

            it("clears the row under it, whatever sits above", function()
                makeSidebar()
                expect(window:CreateSection({ name = "General" }).padding.PaddingBottom.Offset).to.equal(3)
                window:CreateTab({ name = "Home" })
                expect(window:CreateSection({ name = "Modes" }).padding.PaddingBottom.Offset).to.equal(3)
            end)

            it("ignores the settings tab, which never takes a row", function()
                makeSidebar()
                                                expect(#window.tabs > 0).to.equal(true)
                expect(paddingOf(window:CreateSection({ name = "General" }))).to.equal(0)
            end)

            it("sizes to its content rather than a fixed height", function()
                makeSidebar()
                local section = window:CreateSection({ name = "General" })
                expect(section.main.AutomaticSize).to.equal(Enum.AutomaticSize.Y)
                expect(section.main.Size.Y.Offset).to.equal(0)
                expect(section.main.Size.X.Scale).to.equal(1)
                expect(section.main.Size.X.Offset).to.equal(-40)
            end)

            it("builds an icon only when one is asked for", function()
                makeSidebar()
                expect(window:CreateSection({ name = "Plain" }).iconLabel).never.to.be.ok()
                expect(window:CreateSection({ name = "Iconned", icon = 93364949241311 }).iconLabel).to.be.ok()
            end)

            it("builds nothing on the top strip, and hands back an inert handle", function()
                makeWindow()
                local section = window:CreateSection({ name = "General" })
                expect(section.inert).to.equal(true)
                expect(section.main).never.to.be.ok()
                                section:_setShown(true, false)
                section:_setVisible(true)
                section:Remove()
            end)

            it("drops itself from the window on Remove, and stays safe to call after", function()
                makeSidebar()
                local section = window:CreateSection({ name = "General" })
                expect(#window.tabSections).to.equal(1)
                section:Remove()
                expect(#window.tabSections).to.equal(0)

                                section:Remove()
                section:_setShown(true, false)
                section:_setVisible(true)
            end)

            it("fades with the rows it labels", function()
                makeSidebar()
                local section = window:CreateSection({ name = "General" })

                window:_setTabSectionsVisible(true)
                window:_setTabSectionsShown(true, false)
                expect(section.main.Visible).to.equal(true)
                expect(section.title.TextTransparency).to.equal(0.6)

                window:_setTabSectionsShown(false, false)
                expect(section.title.TextTransparency).to.equal(1)
                                expect(section.main.Visible).to.equal(true)

                window:_setTabSectionsVisible(false)
                expect(section.main.Visible).to.equal(false)
            end)
        end)
    end)
end
