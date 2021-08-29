

hm_answernext yes
*deletemodel



*feinputpreserveincludefiles
*createstringarray 11 "OptiStruct " " " "ANSA " "PATRAN " "EXPAND_IDS_FOR_FORMULA_SETS " \
  "ASSIGNPROP_BYHMCOMMENTS" "LOADCOLS_DISPLAY_SKIP " "VECTORCOLS_DISPLAY_SKIP " \
  "SYSTCOLS_DISPLAY_SKIP " "CONTACTSURF_DISPLAY_SKIP " "IMPORT_MATERIAL_METADATA"
*feinputwithdata2 "\#optistruct\\optistruct" "D:/software/Anaconda3/Lib/site-packages/pyadams-0.1-py3.8.egg/pyadams/tests/file_bdf_transient_modal/test.fem" 0 0 0 0 0 1 11 1 0


hm_answernext yes
*deletemodel

proc create_materials_MAT1 {mat_name value_E value_NU value_RHO} {
	
	catch {
		hm_createmark materials 1 "by name only" "$mat_name"
		*deletemark materials 1
	}

	set altair_dir [hm_info -appinfo ALTAIR_HOME]
	set optistruct_path [format "%s/templates/feoutput/optistruct/optistruct" $altair_dir]

	*collectorcreate materials "$mat_name" "" 11
	hm_createmark materials 1 "by name only" "$mat_name"
	set mat_id [hm_getmark materials 1]
	
	*dictionaryload materials 1 $optistruct_path "MAT1"


	*attributeupdatedouble materials $mat_id 1 1 1 0 $value_E
	*attributeupdatedouble materials $mat_id 3 1 1 0 $value_NU
	*attributeupdatedouble materials $mat_id 4 1 1 0 $value_RHO
	
	return $mat_id
}

set mat_id1 [create_materials_MAT1 "steel_1" 206000 0.3 7.85e-009]
set mat_id2 [create_materials_MAT1 "steel_2" 206000 0.3 7.85e-009]


