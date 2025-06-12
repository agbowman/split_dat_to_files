CREATE PROGRAM cco_update_tiss_desc:dba
 IF (validate(readme_data,"0")="0")
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
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Failure - Data update failed."
 DECLARE success_count = i4 WITH public, noconstant(0)
 DECLARE updt_cnt = i4 WITH public, noconstant(0)
 DECLARE found_rec = c4 WITH public, noconstant("N")
 DECLARE description = c200 WITH public, noconstant("")
 DECLARE errmsg = c132 WITH public, noconstant("")
 DECLARE errcode = i4 WITH public, noconstant(0)
#script_start
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663592"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663592 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "Ballon Tamponda/Varices")
  GO TO skip_update_1
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Balloon Tamponade/Varices", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cv.updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663592")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663592"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663592 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Balloon Tamponade/Varices")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663592 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_1
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663633"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663633 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "Hper/Hypothermia Blanket")
  GO TO skip_update_2
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Hyper/Hypothermia Blanket", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   cv.updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663633")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663633"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663633 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Hyper/Hypothermia Blanket")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663633 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_2
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663637"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663637 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "Induce Hypothermia (<32 C)")
  GO TO skip_update_3
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Induced Hypothermia", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
   .updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663637")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663637"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663637 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Induced Hypothermia")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663637 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_3
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663638"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663638 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "Inhapation Therapy")
  GO TO skip_update_4
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Inhalation Therapy", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
   .updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663638")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663638"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663638 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Inhalation Therapy")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663638 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_4
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663653"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663653 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "SWAN GANZ or Pulmonary Arterial Line")
  GO TO skip_update_5
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Pulmonary Arterial Line", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
   .updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663653")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663653"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663653 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Pulmonary Arterial Line")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663653 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_5
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663658"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663658 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "Perioneal Dialysis")
  GO TO skip_update_6
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Peritoneal Dialysis", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
   .updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663658")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663658"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663658 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Peritoneal Dialysis")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663658 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_6
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663666"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description, updt_cnt = (cv.updt_cnt+ 1)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message = "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663666 not found"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 IF (description != "Oxygean via Mask/Cannula")
  GO TO skip_update_7
 ENDIF
 UPDATE  FROM code_value cv
  SET cv.description = "Oxygen via Mask/Cannula", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
   .updt_cnt = updt_cnt,
   cv.updt_task = reqinfo->updt_task, cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"
    )
  WHERE cv.cki IN ("CKI.CODEVALUE!3663666")
   AND cv.code_set=29747
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cki="CKI.CODEVALUE!3663666"
   AND cv.code_set=29747
   AND cv.active_ind=1
  DETAIL
   found_rec = "Y", description = cv.description
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data_status = "F"
  SET readme_data->message = concat("FAIL - cco_update_tiss_desc: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (found_rec != "Y")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663666 not found on second pass"
  GO TO exit_script
 ENDIF
 IF (description != "Oxygen via Mask/Cannula")
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: CKI.CODEVALUE!3663666 description mismatch after update"
  GO TO exit_script
 ENDIF
 SET found_rec = "N"
 SET success_count = (success_count+ 1)
#skip_update_7
 IF (success_count > 0
  AND success_count < 7)
  SET readme_data_status = "F"
  SET readme_data->message =
  "FAIL - cco_update_tiss_desc: only SOME codes could be updated (rolling back)"
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 IF (success_count=7)
  SET readme_data->message = "Success - Data inserted successfully."
 ELSE
  SET readme_data->message = "Success - No changes made."
 ENDIF
 GO TO script_end
#exit_script
 ROLLBACK
#script_end
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
