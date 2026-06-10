; extends

; Match inline text whose content starts with TODO:
; This covers normal paragraphs, list item content, and heading content because
; markdown markers like '#', '-', and '1.' belong to the outer markdown parser.
((inline) @comment.todo
  (#lua-match? @comment.todo "^%s*TODO:")
  (#set! priority 120))
