return {
    s('main', fmt(
        [[
            fn main() {{
                {}
            }}
        ]], i(0)
    )),

    s('println', fmt(
        [[
            println!('{}');
        ]], i(0)
    )),

    s('for', fmt([[
        for {} in {} {{
            {}
        }}
    ]], { i(1), i(2), i(0) }
    )),

    s('struct', fmt([[
        struct {} {{
            {}
        }}
    ]], { i(1), i(0) }
    )),

    s('fn', fmt([[
        fn {}({}){} {{
            {}
        }}
    ]], { i(1), i(2), i(3), i(4) }
    )),

    s('match', fmt([[
        match {}{{
            {} => {{ {} }},
            {} => {{ {} }}
        }}
    ]], { i(1), i(2), i(3), i(4), i(5) }
    )),

    s('closure', fmt([[
        |{}| {}{{
           {}
        }}
    ]], { i(1), i(2), i(3) })),

    s('derive', fmt([[
        #[derive({})]
    ]], i(0)
    )),
}
