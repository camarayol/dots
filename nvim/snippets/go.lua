return {
    s('main', fmt(
        [[
            package main

            func main() {{
                {}
            }}
        ]], i(0)
    )),

    s('func', fmt(
        [[
            func {}({}) ({}) {{
                {}
            }}
        ]], { i(1, 'func'), i(2, 'params'), i(3, 'rets'), i(0) }
    )),

    s('ife', fmt(
        [[
            if err != nil {{
                {}
            }}
        ]], i(0)
    )),

    s('db', fmt([[`db:'{}'`]], i(0))),

    s('json', fmt([[`json:'{}'`]], i(0))),

    s('date', t([['2006-01-02 15:04:05']])),
}
