return {
    s('sh', fmt(
        [[
            #!/bin/{}

            {}
        ]], { i(1, 'bash'), i(0) }
    )),
}
