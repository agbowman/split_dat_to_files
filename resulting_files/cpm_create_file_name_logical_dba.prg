CREATE PROGRAM cpm_create_file_name_logical:dba
 PROMPT
  "Report mnemonic:" = "",
  "Report extension:" = "",
  "Directory logical:" = ""
 CALL echo("<==================== Entering CPM_CREATE_FILE_NAME_LOGICAL Script ====================>"
  )
 FREE RECORD cpm_cfnl_params
 RECORD cpm_cfnl_params(
   1 mnemonic = vc
   1 extension = vc
   1 logical = vc
 )
 SET cpm_cfnl_params->mnemonic = ""
 SET cpm_cfnl_params->extension = ""
 SET cpm_cfnl_params->logical = ""
 SET cpm_cfnl_params->mnemonic = trim( $1)
 SET cpm_cfnl_params->extension = trim( $2)
 SET cpm_cfnl_params->logical = trim( $3)
 CALL echorecord(cpm_cfnl_params)
 EXECUTE cpm_create_file_name value(cpm_cfnl_params->mnemonic), value(cpm_cfnl_params->extension)
 SET cpm_cfn_info->status_data.status = "F"
 IF (0 < size(cpm_cfn_info->file_name))
  IF (0 < size(cpm_cfnl_params->logical))
   SET logical value(cpm_cfnl_params->logical) value(trim(logical("cer_print")))
   IF (cursys="AXP")
    IF (size(cpm_cfn_info->file_name) <= 32)
     SET cpm_cfn_info->file_name_logical = concat(cpm_cfnl_params->logical,":",cpm_cfn_info->
      file_name)
    ENDIF
   ELSEIF (cursys="AIX")
    SET cpm_cfn_info->file_name_logical = concat(cpm_cfnl_params->logical,"/",cpm_cfn_info->file_name
     )
   ENDIF
  ENDIF
 ENDIF
 IF (0 < size(cpm_cfn_info->file_name_logical)
  AND 0 < size(cpm_cfn_info->file_name))
  SET cpm_cfn_info->status_data.status = "S"
 ENDIF
 FREE RECORD cpm_cfnl_params
 CALL echorecord(cpm_cfn_info)
 CALL echo("<==================== Exiting CPM_CREATE_FILE_NAME_LOGICAL Script ====================>")
END GO
