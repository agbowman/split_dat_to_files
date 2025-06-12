CREATE PROGRAM dcp_readme_update_diagnoses:dba
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
 SET readme_data->message = "Beginning script dcp_readme_update_diagnoses"
 UPDATE  FROM code_value cv
  SET cv.active_ind = 0, cv.inactive_dt_tm = cnvtdatetime(curdate,curtime), cv.data_status_cd =
   reqdata->inactive_status_cd,
   cv.data_status_dt_tm = cnvtdatetime(curdate,curtime), cv.data_status_prsnl_id = reqinfo->updt_id,
   cv.end_effective_dt_tm = cnvtdatetime(curdate,curtime),
   cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo->updt_id, cv.updt_applctx =
   reqinfo->updt_applctx,
   cv.updt_task = reqinfo->updt_task
  WHERE cv.code_set=28984
   AND cv.cdf_meaning IN ("RHYTHMDIS", "S-ANULO", "S-BIVALVE", "S-CVCONGEN", "SELF-OD",
  "S-TRIVALVE", "S-VALVE", "S-VALVREDO")
   AND cv.active_ind=1
  WITH noncounter
 ;end update
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating first code_value load: ",error_msg)
  GO TO script_end
 ENDIF
 COMMIT
 UPDATE  FROM code_value cv
  SET cv.cdf_meaning = "CARDARR", cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo
   ->updt_id,
   cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->updt_task
  WHERE cv.code_set=29242
   AND cv.cdf_meaning IN ("CARDARREST")
   AND cv.active_ind=1
  WITH noncounter
 ;end update
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating CARDARR: ",error_msg)
  GO TO script_end
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.cdf_meaning = "HYPERT", cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo
   ->updt_id,
   cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->updt_task
  WHERE cv.code_set=29242
   AND cv.cdf_meaning IN ("HYPERTENS")
   AND cv.active_ind=1
  WITH noncounter
 ;end update
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating HYPERT: ",error_msg)
  GO TO script_end
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.cdf_meaning = "RHYTHM", cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id = reqinfo
   ->updt_id,
   cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->updt_task
  WHERE cv.code_set=29242
   AND cv.cdf_meaning IN ("RHYTHM-DIS")
   AND cv.active_ind=1
  WITH noncounter
 ;end update
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating RHYTHM: ",error_msg)
  GO TO script_end
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.cdf_meaning = "SEPTICUT", cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_id =
   reqinfo->updt_id,
   cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = reqinfo->updt_task
  WHERE cv.code_set=29242
   AND cv.cdf_meaning IN ("SEPSIS-UTI")
   AND cv.active_ind=1
  WITH noncounter
 ;end update
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating SEPTICUT: ",error_msg)
  GO TO script_end
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM code_value_group cvg
  WHERE cvg.code_set=29242
  WITH nocounter
 ;end delete
 IF (error(error_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error updating second code_value load: ",error_msg)
  GO TO script_end
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message = "Successful completion of script dcp_readme_update_diagnoses"
#script_end
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
