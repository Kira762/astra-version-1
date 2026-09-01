return function()
    local globals = _G :: any
    globals.__ASTRA_RUNNER_LEAK_COUNT = 0
    globals.__ASTRA_RUNNER_AFTER_ALL = "pending"

    beforeEach(function()
        globals.__ASTRA_RUNNER_LEAK_COUNT += 1
    end)

    afterAll(function()
        globals.__ASTRA_RUNNER_AFTER_ALL = "done"
    end)

    describe("runner lifecycle source", function()
        local beforeAllState = "defined"

        beforeAll(function()
            beforeAllState = "ran"
        end)

        expect(beforeAllState).to.equal("defined")

        it("runs hooks at execution time", function()
            expect(beforeAllState).to.equal("ran")
            expect(globals.__ASTRA_RUNNER_LEAK_COUNT).to.equal(1)
            expect(globals.__ASTRA_RUNNER_AFTER_ALL).to.equal("pending")
        end)
    end)
end
