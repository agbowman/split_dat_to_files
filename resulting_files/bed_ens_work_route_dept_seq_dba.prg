CREATE PROGRAM bed_ens_work_route_dept_seq:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 activity_type_code_value = f8
    1 departments[*]
      2 action_flag = i2
      2 code_value = f8
      2 sequence = i4
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET key1 = fillstring(50," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE (cv.code_value=request->activity_type_code_value)
  DETAIL
   IF (((cv.cdf_meaning="GLB") OR (cv.cdf_meaning="HLX")) )
    key1 = "RT_LAB_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="RADIOLOGY")
    key1 = "RT_RAD_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="AP")
    key1 = "RT_AP_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="BB")
    key1 = "RT_BB_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="MICROBIOLOGY")
    key1 = "RT_MB_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="HLA")
    key1 = "RT_HLA_DEPT_SEQ"
   ENDIF
  WITH nocounter
 ;end select
 IF (key1=" ")
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SET dcnt = size(request->departments,5)
 FOR (d = 1 TO dcnt)
   IF ((request->departments[d].action_flag=1))
    SET row_exists = 0
    SELECT INTO "NL:"
     FROM br_name_value bnv
     WHERE bnv.br_nv_key1=key1
      AND bnv.br_name=cnvtstring(request->departments[d].code_value)
     DETAIL
      row_exists = 1
     WITH nocounter
    ;end select
    IF (row_exists=1)
     UPDATE  FROM br_name_value bnv
      SET bnv.br_value = cnvtstring(request->departments[d].sequence), bnv.updt_cnt = (bnv.updt_cnt+
       1), bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx
      WHERE bnv.br_nv_key1=key1
       AND bnv.br_name=cnvtstring(request->departments[d].code_value)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = "Unable to update into br_name_value"
      GO TO exit_script
     ENDIF
    ELSE
     INSERT  FROM br_name_value bnv
      SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = key1, bnv.br_name =
       cnvtstring(request->departments[d].code_value),
       bnv.br_value = cnvtstring(request->departments[d].sequence), bnv.updt_cnt = 0, bnv.updt_dt_tm
        = cnvtdatetime(curdate,curtime3),
       bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
       ->updt_applctx,
       bnv.default_selected_ind = 0, bnv.start_version_nbr = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = "Unable to insert into br_name_value"
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->departments[d].action_flag=2))
    UPDATE  FROM br_name_value bnv
     SET bnv.br_value = cnvtstring(request->departments[d].sequence), bnv.updt_cnt = (bnv.updt_cnt+ 1
      ), bnv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo
      ->updt_applctx
     WHERE bnv.br_nv_key1=key1
      AND bnv.br_name=cnvtstring(request->departments[d].code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = "Unable to update into br_name_value"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_WORK_ROUTE_DEPT_SEQ","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
