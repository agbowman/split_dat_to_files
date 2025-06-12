CREATE PROGRAM dcp_readme_update_diagnoses2:dba
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
 DECLARE error_msg = c255 WITH protect, noconstant(fillstring(255," "))
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning script dcp_readme_update_diagnoses2"
 UPDATE  FROM code_value cv
  SET cv.definition = "HEMATO", cv.updt_cnt = (updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->
   updt_task
  WHERE cv.code_set=28984
   AND cv.cdf_meaning="COAGULOP"
   AND cv.cki="CKI.CODEVALUE!3014805"
   AND cv.active_ind=1
  WITH nocounter
 ;end update
 IF (error(error_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating first code_value load: ",error_msg)
  GO TO script_end
 ENDIF
 COMMIT
 UPDATE  FROM code_value cv
  SET cv.definition = "METAB/ENDO", cv.updt_cnt = (updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->
   updt_task
  WHERE cv.code_set=28984
   AND cv.cdf_meaning="ADDISON"
   AND cv.cki="CKI.CODEVALUE!3014844"
   AND cv.active_ind=1
  WITH nocounter
 ;end update
 IF (error(error_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating first code_value load: ",error_msg)
  GO TO script_end
 ENDIF
 COMMIT
 UPDATE  FROM code_value cv
  SET cv.description = "Exenteration, pelvic - female", cv.updt_cnt = (updt_cnt+ 1), cv.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->
   updt_task
  WHERE cv.code_set=28984
   AND cv.cdf_meaning="S-PELVEXEN"
   AND cv.cki="CKI.CODEVALUE!3014725"
   AND cv.active_ind=1
  WITH nocounter
 ;end update
 IF (error(error_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating first code_value load: ",error_msg)
  GO TO script_end
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Successful completion of script dcp_readme_update_diagnoses"
#script_end
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
