ui, th, th.git        = ui or {}, th or {}, th.git or {}

th.git.modified       = ui.Style():fg('#e5c07b')
th.git.modified_sign  = '~'

th.git.added          = ui.Style():fg('#98c379')
th.git.added_sign     = '+'

th.git.deleted        = ui.Style():fg('#e06c75')
th.git.deleted_sign   = '-'

th.git.untracked      = ui.Style():fg('#c678dd')
th.git.untracked_sign = '?'

th.git.ignored_sign   = ''

-- ya pkg add yazi-rs/plugins:git
require('git'):setup()
