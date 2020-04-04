# hmMaterials.tcl

# 删除原有卡片\载荷\工况
hm_blockerrormessages 1
*createmark materials 1 all
catch {*deletemark materials 1}
*createmark properties 1 all
catch {*deletemark properties 1}
hm_blockerrormessages 0

# 当前文件路径
set filepath [file dirname [info script]]

# materials
*collectorcreate materials "steel" "" 11
*createmark materials 1  "steel"
*dictionaryload materials 1 [format "%s/sets/optistruct" $filepath] "MAT1"
*attributeupdatedouble materials 1 1 1 1 0 206000
*attributeupdatedouble materials 1 3 1 1 0 0.3
*attributeupdatedouble materials 1 4 1 1 0 7.85e-009

# properties
*collectorcreate properties "steel_solid" "steel" 11
*createmark properties 1  "steel_solid"
*dictionaryload properties 1 [format "%s/sets/optistruct" $filepath] "PSOLID"
*attributeupdateint properties 1 3240 1 2 0 1
*attributeupdateint properties 1 1000 1 2 0 1
*attributeupdatestring properties 1 126 1 0 0 "FULL"
*attributeupdatestring properties 1 127 1 0 0 "SMECH" 
*attributeupdateint properties 1 7266 1 2 0 0


# properties
*collectorcreate properties "steel_shell_1mm" "steel" 11
*createmark properties 1  "steel_shell_1mm"
*dictionaryload properties 1 [format "%s/sets/optistruct" $filepath] "PSHELL"
*attributeupdatedouble properties 1 95 1 0 0 4.44




# *collectorcreate properties "steel_shell_3mm" "steel" 11
# *createmark properties 2  "steel_shell_3mm"
# *dictionaryload properties 2 "E:/Software/HyperWorks/templates/feoutput/optistruct/optistruct" "PSHELL"
# *attributeupdateint properties 4 3240 1 2 0 1
# *attributeupdatedouble properties 4 95 1 0 0 1
# *attributeupdateint properties 4 884 1 2 0 0
# *attributeupdatedouble properties 4 114 1 0 0 1
# *attributeupdateint properties 4 885 1 2 0 0
# *attributeupdatedouble properties 4 116 1 0 0 0.833333
# *attributeupdatedouble properties 4 96 1 2 0 0
# *attributeupdatedouble properties 4 119 1 0 0 0
# *attributeupdatedouble properties 4 120 1 0 0 0
# *attributeupdateint properties 4 897 1 2 0 1
# *attributeupdateentity properties 4 831 1 0 0 materials 0
# *attributeupdatedouble properties 4 2403 1 0 0 0
# *attributeupdateint properties 4 7253 1 2 0 0


