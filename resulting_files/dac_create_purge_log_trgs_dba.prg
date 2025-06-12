CREATE PROGRAM dac_create_purge_log_trgs:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dac_create_purge_log_trgs..."
 DECLARE replacesql(fname=vc,token=vc,tmpname=vc) = null
 DECLARE dcplt_filename = vc WITH protect, noconstant("")
 DECLARE dcplt_token = vc WITH protect, noconstant("")
 DECLARE dcplt_tempfilename = vc WITH protect, noconstant("")
 SET dcplt_filename = "cer_install:dac_create_purge_log_trgs.sql"
 SET dcplt_token = "${sql.dateTimeOffsetCalc}"
 SET dcplt_tempfilename = concat("temp_file_",cnvtstring(cnvtdatetime(curdate,curtime3)),".sql")
 CALL replacesql(dcplt_filename,dcplt_token,dcplt_tempfilename)
 EXECUTE dm_readme_include_sql dcplt_tempfilename
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "TRG_PURGE_JOB_MOD", "TRIGGER"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk "TRG_PURGE_JOB_TOKEN_MOD", "TRIGGER"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 SUBROUTINE replacesql(fname,token,tmpname)
   DECLARE dcplt_offset = i4 WITH protect, noconstant(0)
   DECLARE file_name_logical = vc
   DECLARE str = vc
   DECLARE position = i4 WITH protect, noconstant(0)
   DECLARE thistr = vc WITH protect, noconstant(" ")
   DECLARE suffix = vc WITH protect, noconstant("")
   DECLARE err_msg = vc WITH protect, noconstant("")
   IF (curutc=1)
    SET dcplt_offset = (curutcdiff/ 3600)
   ENDIF
   FREE DEFINE rtl2
   SET logical file_name_logical value(fname)
   DEFINE rtl2 "file_name_logical"
   SELECT INTO value(tmpname)
    FROM rtl2t t
    DETAIL
     position = 0, str = t.line, position = findstring(token,str,1,0)
     IF (position > 0)
      thistr = concat(substring(1,(position - 1),str)), suffix = substring((position+ size(token,1)),
       (size(str,1) - ((position+ size(token,1)) - 1)),str), thistr = concat(thistr,trim(cnvtstring(
         dcplt_offset),7),suffix),
      thistr, row + 1
     ELSE
      str, row + 1
     ENDIF
    WITH nocounter
   ;end select
   IF (error(err_msg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to build sql file: ",err_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Triggers and context created"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
