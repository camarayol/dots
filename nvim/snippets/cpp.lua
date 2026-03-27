return {
    s('cout', fmt(
        'std::cout << {} << std::endl;', i(0, 'Hello World')
    )),

    s('main', fmt(
        [[
            int main(int argc, char *argv[]) {{
                {}
                return 0;
            }}
        ]], { i(0) }
    )),

    s('ifndef', fmt(
        [[
            #ifndef {def}
            #define {def}

            {}

            #endif // {def}
        ]], { def = i(1, '__XXX_H__'), i(0) }, { repeat_duplicates = true }
    )),

    s('for', fmt(
        [[
            for ({}) {{
                {}
            }}
        ]], { i(1), i(0) }
    )),
}
