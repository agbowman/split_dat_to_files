CREATE PROGRAM cr_rdm_update_hitsp_codevalue:dba
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
 SET readme_data->message = "Readme failed: starting script cr_rdm_update_hitspc32_codevalue..."
 DECLARE rdm_errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM code_value cv
  SET cv.display = "CCD", cv.display_key = "CCD", cv.definition =
   "A CCD document constrained using HITSP specifications",
   cv.description = "A CCD document constrained using HITSP specifications", cv.updt_task = reqinfo->
   updt_task, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->
   updt_applctx
  WHERE cv.display="HITSP C32"
   AND cv.cdf_meaning="HITSPC32"
   AND cv.code_set=4002390
   AND cv.active_ind=1
  WITH nocounter
 ;end update
 IF (error(rdm_errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to update the code values for HITSPC32",rdm_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  ROLLBACK
  SET readme_data->status = "S"
  SET readme_data->message = build(rdm_errmsg,
   "The code values have already been updated for HITSPC32")
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Success: The readme has updated all the desired fields"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
