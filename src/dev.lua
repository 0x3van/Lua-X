local function main()
    local args = {...}
    local script = args[1]
    local argv = {}
    for i = 2, #args do
        argv[#argv + 1] = args[i]
    end
    local env = {}
    local f = assert(loadfile(script, "t", env))
    f()
    local dev = env.dev
    dev.main(argv)
end


main()
