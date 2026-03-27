return {
    s('code', fmt(
        [[
            ```{}
            {}
            ```
        ]], { i(1, 'code'), i(0) }
    )),

    s('link', fmt('[{}]({})', { i(2), i(1) })),

    s('title', fmt(
        [[
            ---
            title: {}
            date: {}
            description: {}

            categories:
                - {}

            image: {}
            ---

            {}
        ]], { i(1, 'title'), i(2, os.date('%Y-%m-%d')), i(3), i(4), i(5), i(0) }
    )),
}
