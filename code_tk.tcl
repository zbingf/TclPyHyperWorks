
package require Tk

# ------------tk
# 字体
# -font {MS 11}


# 选择
set choice [tk_messageBox -type yesnocancel -default yes -message "是否删除" -icon question ]
if {$choice != yes} {return;}


# 提示
tk_messageBox -message "Run End!!!"	

# 