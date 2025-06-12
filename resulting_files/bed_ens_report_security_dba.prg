CREATE PROGRAM bed_ens_report_security:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET hold_ind_str = " "
 SET sec_row_exists = "N"
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="REPORTPARAM"
    AND bnv.br_name="USERLEVELSECIND")
  DETAIL
   hold_ind_str = trim(bnv.br_value), sec_row_exists = "Y"
  WITH nocounter
 ;end select
 IF (sec_row_exists="Y")
  IF ((((request->user_level_security_ind=0)
   AND hold_ind_str != "0") OR ((request->user_level_security_ind=1)
   AND hold_ind_str != "1")) )
   SET ierrcode = 0
   UPDATE  FROM br_name_value bnv
    SET bnv.br_value = trim(cnvtstring(request->user_level_security_ind)), bnv.updt_dt_tm =
     cnvtdatetime(curdate,curtime), bnv.updt_cnt = (bnv.updt_cnt+ 1),
     bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
     updt_applctx
    WHERE bnv.br_nv_key1="REPORTPARAM"
     AND bnv.br_name="USERLEVELSECIND"
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error updating into br_name_value table")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  SET ierrcode = 0
  INSERT  FROM br_name_value bnv
   SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "REPORTPARAM", bnv.br_name
     = "USERLEVELSECIND",
    bnv.br_value = trim(cnvtstring(request->user_level_security_ind)), bnv.updt_dt_tm = cnvtdatetime(
     curdate,curtime), bnv.updt_cnt = 0,
    bnv.updt_id = reqinfo->updt_id, bnv.updt_task = reqinfo->updt_task, bnv.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error inserting into br_name_value table")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET usercnt = size(request->users,5)
 FOR (u = 1 TO usercnt)
  SET reportcnt = size(request->users[u].reports,5)
  IF ((request->append_mode_ind=0))
   SET ierrcode = 0
   DELETE  FROM br_name_value bnv
    WHERE bnv.br_nv_key1="REPORTSECURITY"
     AND bnv.br_name=cnvtstring(request->users[u].person_id)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error deleting from br_name_value table")
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   IF (reportcnt > 0)
    SET ierrcode = 0
    INSERT  FROM br_name_value bnv,
      (dummyt d  WITH seq = reportcnt)
     SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "REPORTSECURITY", bnv
      .br_name = cnvtstring(request->users[u].person_id),
      bnv.br_value = request->users[u].reports[d.seq].script_name, bnv.updt_cnt = 0, bnv.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
      reqinfo->updt_task
     PLAN (d)
      JOIN (bnv)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = concat(
      "Error inserting into br_name_value table")
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   FOR (r = 1 TO reportcnt)
     SET already_exists_ind = 0
     SELECT INTO "nl:"
      FROM br_name_value bnv
      WHERE bnv.br_nv_key1="REPORTSECURITY"
       AND bnv.br_name=cnvtstring(request->users[u].person_id)
       AND (bnv.br_value=request->users[u].reports[r].script_name)
      DETAIL
       already_exists_ind = 1
      WITH nocounter
     ;end select
     IF (already_exists_ind=0)
      SET ierrcode = 0
      INSERT  FROM br_name_value bnv
       SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "REPORTSECURITY", bnv
        .br_name = cnvtstring(request->users[u].person_id),
        bnv.br_value = request->users[u].reports[r].script_name, bnv.updt_cnt = 0, bnv.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        bnv.updt_id = reqinfo->updt_id, bnv.updt_applctx = reqinfo->updt_applctx, bnv.updt_task =
        reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = concat(
        "Error inserting into br_name_value table")
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
