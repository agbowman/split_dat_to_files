CREATE PROGRAM cmn_restore_stw_datapoints:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting cmn_restore_stw_datapoints script"
 RECORD pex_stw_request(
   1 display = vc
   1 identifier = vc
   1 code_value = f8
 ) WITH protect
 RECORD faultyrows(
   1 error_cnt = i4
   1 qual[*]
     2 br_display = vc
     2 br_identifier = vc
     2 code_value = f8
     2 new_disp_key = vc
     2 dup_disp_key_cnt = i4
     2 error_ind = i4
 ) WITH protect
 FREE RECORD crat_reply
 RECORD crat_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE crsd_errmsg = vc WITH protect, noconstant(" ")
 SELECT INTO "NL:"
  bc.category_name, bc.category_mean, cv.code_value
  FROM code_value cv,
   br_datamart_category bc
  WHERE cv.code_set=16529
   AND cv.active_ind=0
   AND cv.cdf_meaning="CLINNOTETEMP"
   AND cnvtlower(cv.definition)=patstring("smart_template_wizard__driver_*")
   AND bc.category_mean=trim(cnvtupper(substring(31,69,cv.definition)))
   AND bc.layout_flag=2
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(faultyrows->qual,cnt), faultyrows->qual[cnt].br_display = bc
   .category_name,
   faultyrows->qual[cnt].br_identifier = bc.category_mean, faultyrows->qual[cnt].code_value = cv
   .code_value, faultyrows->qual[cnt].new_disp_key = cnvtupper(cnvtalphanum(trim(substring(1,40,bc
       .category_name))))
  WITH nocounter
 ;end select
 IF (error(crsd_errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error identifying out of sync smart template data points: ",
   crsd_errmsg)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO size(faultyrows->qual,5))
   SELECT INTO "NL:"
    dupcnt = count(*)
    FROM code_value cv
    WHERE cv.code_set=16529
     AND cdf_meaning="CLINNOTETEMP"
     AND (display_key=faultyrows->qual[cnt].new_disp_key)
     AND (code_value != faultyrows->qual[cnt].code_value)
    DETAIL
     faultyrows->qual[cnt].dup_disp_key_cnt = dupcnt
    WITH nocounter
   ;end select
   IF (error(crsd_errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error checking for duplicate display_key information: ",
     crsd_errmsg)
    GO TO exit_script
   ENDIF
   IF ((faultyrows->qual[cnt].dup_disp_key_cnt=0))
    SET pex_stw_request->display = faultyrows->qual[cnt].br_display
    SET pex_stw_request->identifier = faultyrows->qual[cnt].br_identifier
    SET pex_stw_request->code_value = faultyrows->qual[cnt].code_value
    SET stat = initrec(crat_reply)
    EXECUTE cmn_readme_autoinsert_template  WITH replace("CRAT_REQUEST",pex_stw_request)
    IF ((crat_reply->status_data.status != "S"))
     SET faultyrows->qual[cnt].error_ind = 1
     SET faultyrows->error_cnt = (faultyrows->error_cnt+ 1)
     CALL echo(crat_reply->status_data.subeventstatus[1].targetobjectvalue)
     ROLLBACK
    ELSEIF (error(crsd_errmsg,0) > 0)
     SET faultyrows->qual[cnt].error_ind = 1
     SET faultyrows->error_cnt = (faultyrows->error_cnt+ 1)
     CALL echo(crsd_errmsg)
     ROLLBACK
    ELSE
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 IF ((faultyrows->error_cnt=0))
  SET readme_data->status = "S"
  SET readme_data->message = "All smart template data points restored successfully."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error(s) occurred when restoring smart template data points on ",
   trim(cnvtstring(faultyrows->error_cnt))," out of ",trim(cnvtstring(size(faultyrows->qual,5))))
  GO TO exit_script
 ENDIF
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(faultyrows)
 ENDIF
 CALL echorecord(readme_data)
 FREE RECORD faultyrows
 FREE RECORD pex_stw_request
 EXECUTE dm_readme_status
END GO
