### 配置文件

- init.lua(vim)

- syntax/${syntax}.lua(vim)
- plugin/*.lua(vim)
- ftplugin/${filetype}.lua(vim)

- after/syntax/${syntax}.lua(vim)
- after/plugin/*.lua(vim)
- after/ftplugin/${filetype}.lua(vim)

### 查某个组合键输出的键值

```vim
:echo getcharstr()
```

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

### 内置快捷键

```help
q:  " 打开历史命令窗口
```

-- multicursor (v0.13)

```help
Q                     " 在当前光标处新增(删除)多光标

zq{motion}            " 根据 {motion} 行为添加多光标
                      "     zq* 在所有当前光标下单词前添加光标
                      "     zqn 在所有查找对象前添加光标

{Visual}zq{motion}    " 与 zq 功能相同, 匹配对象限定在 {Visual} 范围内

{Visual}Q             " 在 {Visual} 范围内的每一行, 真实光标所在的列添加光标

q=                    " 所有多光标进入 'follow' 模式, 跟随真实光标的 {motion}

gQ                    " 恢复上一次的所有多光标

g CTRL-A              " 在多光标模式下可以在每个光标下生成递增的序号

{count}]C             " 向后跳转到第 {count} 个光标

{count}[C             " 向前跳转到第 {count} 个光标
```

