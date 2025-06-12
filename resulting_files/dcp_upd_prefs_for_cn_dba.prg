CREATE PROGRAM dcp_upd_prefs_for_cn:dba
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
 IF (validate(readme_data->readme_id,0) <= 0)
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "Result date", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = 0,
   nvp.updt_applctx = 0, nvp.updt_task = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE nvp.pvc_name="pvNotes.ResultDate"
   AND pvc_value=" "
  WITH nocounter
 ;end update
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "Result title", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = 0,
   nvp.updt_applctx = 0, nvp.updt_task = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE nvp.pvc_name="pvNotes.ResultTitle"
   AND pvc_value=" "
  WITH nocounter
 ;end update
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "Performed by", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = 0,
   nvp.updt_applctx = 0, nvp.updt_task = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE nvp.pvc_name="pvNotes.PerformedBy"
   AND pvc_value=" "
  WITH nocounter
 ;end update
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "Result type", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = 0,
   nvp.updt_applctx = 0, nvp.updt_task = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE nvp.pvc_name="pvNotes.ResultType"
   AND pvc_value=" "
  WITH nocounter
 ;end update
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "Verified by", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = 0,
   nvp.updt_applctx = 0, nvp.updt_task = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE nvp.pvc_name="pvNotes.VerifiedBy"
   AND pvc_value=" "
  WITH nocounter
 ;end update
 UPDATE  FROM name_value_prefs nvp
  SET nvp.pvc_value = "Cosigned by", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_id = 0,
   nvp.updt_applctx = 0, nvp.updt_task = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE nvp.pvc_name="pvNotes.CosignedBy"
   AND pvc_value=" "
  WITH nocounter
 ;end update
 IF (validate(readme_data->readme_id,0) <= 0)
  SET readme_data->status = "F"
 ENDIF
 GO TO exit_script
#exit_script
 SELECT INTO "nl:"
  FROM name_value_prefs nvp
  WHERE nvp.pvc_name IN ("pvNotes.CosignedBy", "pvNotes.VerifiedBy", "pvNotes.ResultType",
  "pvNotes.PerformedBy", "pvNotes.ResultTitle",
  "pvNotes.ResultDate")
   AND pvc_value=" "
  WITH counter
 ;end select
 IF (curqual=0)
  SET readme_data->message = build("Readme:dcp_upd_prefs_for_cn completed successfully")
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = build("Readme:dcp_upd_prefs_for_cn did not completed successfully")
  SET readme_data->status = "F"
 ENDIF
 EXECUTE dm_readme_status
END GO
