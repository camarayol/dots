-- Rime Lua 扩展 https://github.com/hchunhui/librime-lua
-- 文档 https://github.com/hchunhui/librime-lua/wiki/Scripting

-- processors:

-- 以词定字，可在 default.yaml → key_binder 下配置快捷键，默认为左右中括号 [ ]
select_character = require("select_character")

-- translators:

-- 日期时间，可在方案中配置触发关键字。
date_translator = require("date_translator")

-- 农历，可在方案中配置触发关键字。
lunar = require("lunar")

-- Unicode，U 开头
unicode = require("unicode")

-- 数字、人民币大写，R 开头
number_translator = require("number_translator")

-- filters:

-- v 模式 symbols 优先（全拼）
v_filter = require("v_filter")

-- 自动大写英文词汇
autocap_filter = require("autocap_filter")

-- 降低部分英语单词在候选项的位置，可在方案中配置要降低的模式和单词
reduce_english_filter = require("reduce_english_filter")

-- 辅码，https://github.com/mirtlecn/rime-radical-pinyin/blob/master/search.lua.md
search = require("search")

-- 置顶候选项
pin_cand_filter = require("pin_cand_filter")

-- 长词优先（全拼）
long_word_filter = require("long_word_filter")

-- 默认未启用：

-- 中英混输词条自动空格
-- 在 engine/filters 增加 - lua_filter@cn_en_spacer
cn_en_spacer = require("cn_en_spacer")

-- 英文词条上屏自动添加空格
-- 在 engine/filters 的倒数第二个位置，增加 - lua_filter@en_spacer
en_spacer = require("en_spacer")

-- 暴力 GC
-- 详情 https://github.com/hchunhui/librime-lua/issues/307
-- 这样也不会导致卡顿，那就每次都调用一下吧，内存稳稳的
function force_gc()
    -- collectgarbage()
    collectgarbage("step")
end

-- 临时用的
function debug_checker(input, env)
    for cand in input:iter() do
        yield(ShadowCandidate(
            cand,
            cand.type,
            cand.text,
            env.engine.context.input .. " - " .. env.engine.context:get_preedit().text .. " - " .. cand.preedit
        ))
    end
end
