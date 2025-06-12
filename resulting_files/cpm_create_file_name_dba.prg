CREATE PROGRAM cpm_create_file_name:dba
 PROMPT
  "Report mnemonic:" = "",
  "Report extension:" = ""
 CALL echo("<==================== Entering CPM_CREATE_FILE_NAME Script ====================>")
 FREE RECORD cpm_cfn_params
 RECORD cpm_cfn_params(
   1 mnemonic = vc
   1 extension = vc
 )
 DECLARE _bseqmode = i2 WITH noconstant(1)
 DECLARE _errormessage = vc WITH noconstant("")
 DECLARE _errorcode = i2 WITH noconstant(0)
 SET cpm_cfn_info->file_name = ""
 SET cpm_cfn_info->file_name_path = ""
 SET cpm_cfn_info->file_name_full_path = ""
 SET cpm_cfn_info->file_name_logical = ""
 SET cpm_cfn_info->status_data.status = "F"
 SET cpm_cfn_params->mnemonic = trim( $1,3)
 SET cpm_cfn_params->extension = trim( $2,3)
 IF (size(cpm_cfn_params->mnemonic)=0)
  SET cpm_cfn_params->mnemonic = "tmp"
 ENDIF
 IF (size(cpm_cfn_params->extension)=0)
  SET cpm_cfn_params->extension = "dat"
 ENDIF
 CALL echorecord(cpm_cfn_params)
 IF ((34 < (size(cpm_cfn_params->mnemonic)+ size(cpm_cfn_params->extension))))
  GO TO exit_script
 ENDIF
 SET cpm_cfn_info->file_name = cpm_cfn_params->mnemonic
 SET cpm_cfn_info->file_name = concat(cpm_cfn_info->file_name,"_")
 CASE (validate(currdbaccess,- (1)))
  OF 0:
   SET _bseqmode = 0
   CALL echo("CURRDBACCESS=0; No DB connection")
  OF 1:
   SET _bseqmode = 1
  OF 2:
   SET _bseqmode = 0
   CALL echo("CURRDBACCESS=2; DB read/write mode; select sequence not supported")
  OF 3:
   SET _bseqmode = 0
   CALL echo("CURRDBACCESS=3; DB read-only mode")
  ELSE
   SET _bseqmode = 1
 ENDCASE
 IF (_bseqmode=1)
  SELECT INTO "nl:"
   nextseqnum = seq(aar_report_seq,nextval)
   FROM dual
   DETAIL
    cpm_cfn_info->file_name = concat(cpm_cfn_info->file_name,trim(format(nextseqnum,
       "############################"),3))
   WITH nocounter
  ;end select
  SET _errorcode = error(_errormessage,1)
  IF (_errorcode != 0)
   SET _bseqmode = 0
  ENDIF
 ENDIF
 IF (_bseqmode=0)
  DECLARE _timestr = vc
  SET _timestr = substring(3,6,format(curtime3,"HHMMSSCC;3;M"))
  IF (curenv != 0)
   SET cpm_cfn_info->file_name = concat(cpm_cfn_info->file_name,substring(4,7,curprcname),"_",
    _timestr)
  ELSE
   SET cpm_cfn_info->file_name = concat(cpm_cfn_info->file_name,build(curprcname))
  ENDIF
 ENDIF
 SET cpm_cfn_info->file_name = concat(cpm_cfn_info->file_name,".")
 SET cpm_cfn_info->file_name = concat(cpm_cfn_info->file_name,cpm_cfn_params->extension)
 SET cpm_cfn_info->file_name = cnvtlower(cpm_cfn_info->file_name)
 SET cpm_cfn_info->file_name_path = concat(cpm_cfn_path,cpm_cfn_info->file_name)
 SET cpm_cfn_info->file_name_full_path = concat(cpm_cfn_full_path,cpm_cfn_info->file_name)
 IF (size(cpm_cfn_info->file_name) <= 64)
  SET cpm_cfn_info->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD cpm_cfn_params
 CALL echorecord(cpm_cfn_info)
 CALL echo("<==================== Exiting CPM_CREATE_FILE_NAME Script ====================>")
END GO
