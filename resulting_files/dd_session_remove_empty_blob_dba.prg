CREATE PROGRAM dd_session_remove_empty_blob:dba
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
 DECLARE icount = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE flag = i2 WITH protect, noconstant(0)
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Fail to execute dd_session_remove_empty_blob"
 FREE RECORD extract
 RECORD extract(
   1 extract_list[*]
     2 extract_session_data_id = f8
 )
 WHILE (flag != 1)
   SET stat = alterlist(extract->extract_list,0)
   SELECT INTO "nl:"
    FROM dd_session_data sd
    WHERE sd.dd_session_data_id != 0.0
     AND sd.session_data_key="DATA_EXTRACT_XML"
     AND  NOT (sd.long_blob_id IN (
    (SELECT
     long_blob_id
     FROM long_blob
     WHERE long_blob_id=sd.long_blob_id)))
    HEAD REPORT
     icount = 0
    HEAD sd.dd_session_data_id
     icount = (icount+ 1)
     IF (mod(icount,10)=1)
      stat = alterlist(extract->extract_list,(icount+ 9))
     ENDIF
     extract->extract_list[icount].extract_session_data_id = sd.dd_session_data_id
    FOOT REPORT
     IF (icount > 0)
      stat = alterlist(extract->extract_list,icount)
     ENDIF
    WITH maxqual(ex,200)
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - Failed to create list of extract_id's to be deleted:",
     error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
   IF (size(extract->extract_list,5)=0)
    SET flag = 1
   ELSE
    DELETE  FROM dd_session_data sd
     WHERE expand(num,1,size(extract->extract_list,5),sd.dd_session_data_id,extract->extract_list[num
      ].extract_session_data_id)
     WITH expand = 1
    ;end delete
    SET err_code = error(error_msg,1)
    IF (err_code > 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error - Failed to delete rows from dd_session_data table:",
      error_msg)
     ROLLBACK
     GO TO exit_script
    ENDIF
    COMMIT
   ENDIF
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Successful execution of dd_session_remove_empty_blob"
#exit_script
 FREE RECORD extract
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
