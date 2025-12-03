ui, th, th.git = ui or {}, th or {}, th.git or {}

th.git.modified       = ui.Style():fg('yellow')
th.git.modified_sign  = '~'

th.git.added          = ui.Style():fg('green')
th.git.added_sign     = '+'

th.git.deleted        = ui.Style():fg('red')
th.git.deleted_sign   = '-'

th.git.untracked      = ui.Style():fg('magenta')
th.git.untracked_sign = '?'

-- ya pkg add yazi-rs/plugins:git
require('git'):setup()
