
macro(add_make_deploy TGT IP)
	set(DEPLOY_PATH /ni-rt/system/FRC_UserProgram.out)
	add_custom_command(OUTPUT deploy_stamp
		COMMAND wput -u "${TGT}" ftp://anonymous@${IP}${DEPLOY_PATH}
		DEPENDS ${TGT}
	VERBATIM)
	set_source_files_properties(deploy_stamp PROPERTIES SYMBOLIC true)
	add_custom_target(deploy DEPENDS deploy_stamp)
endmacro(add_make_deploy)
