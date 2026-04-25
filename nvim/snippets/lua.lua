return {
    s('spec', fmt(
        [[
            return {{
                src = '{}',
                depends = {{ {} }},
                config = function()
                    {}
                end
            }}
        ]], { i(1), i(2), i(0) }
    )),
}
