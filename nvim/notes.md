### 配置文件

- init.lua(vim)

- syntax/${syntax}.lua(vim)
- plugin/*.lua(vim)
- ftplugin/${filetype}.lua(vim)

- after/syntax/${syntax}.lua(vim)
- after/plugin/*.lua(vim)
- after/ftplugin/${filetype}.lua(vim)

### 查看某个配置最后的修改记录

```vim
" 通过 `nvim -V1` 启动 Neovim 后可以输出更详细的信息
:verbose set mouse?
```

### 自定义高亮解析

1. syntax

    ```vim
    " 查看当前文件的 syntax 状态
    :syntax

    " 设置当前文件的 syntax 类型
    :set syntax=markdown

    " 自定义特定文本的 syntax 高亮组 例: 将 `TODO:` 文本设置为 `Todo` 高亮组
    :syntax match Todo /TODO:/
    ```

    - 在打开文件时 Neovim 会根据 `syntax` 类型自动匹配加载 `after/syntax/${syntax}.vim` 配置文件

        ```vim
        " after/syntax/markdown.vim
        syntax match Todo /TODO:/
        ```

        ```lua
        vim.cmd.syntax 'match Todo /TODO:/'
        ```
2. matchadd

    ```lua
    local id = vim.fn.matchadd('Todo', 'TODO:')
    pcall(vim.fn.matchdelete, id)
    ```

3. extmark
3. treesitter

    ```query
    ; after/queries/markdown_inline/highlights.scm
    ; extends

    ((inline) @comment.todo
      (#lua-match? @comment.todo "^%s*TODO:")
      (#set! priority 120))
    ```
