CREATE PROGRAM bed_ens_pal_task_groups:dba
 FREE SET reply
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET fail = "N"
 SET 25451_cd = 0.0
 SET tcnt = 0
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 DECLARE active = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE")
  DETAIL
   active = cv.code_value
  WITH nocounter
 ;end select
 SET 25451_cd = request->task_group.code_value
 IF ((request->action_flag=1))
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=25451
     AND (cv.display=request->task_group.display)
     AND cv.active_ind=0)
   DETAIL
    25451_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=1)
   SET ierrcode = 0
   UPDATE  FROM code_value cv
    SET cv.active_ind = 1, cv.active_type_cd = active, cv.collation_seq = request->task_group.
     collation_seq,
     cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv.inactive_dt_tm = null, cv
     .begin_effective_dt_tm = cnvtdatetime(curdate,curtime),
     cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.updt_dt_tm = cnvtdatetime(curdate,
      curtime), cv.updt_cnt = (cv.updt_cnt+ 1),
     cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
     updt_applctx
    PLAN (cv
     WHERE cv.code_value=25451_cd)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET fail = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ELSE
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 25451
   SET request_cv->cd_value_list[1].cdf_meaning = ""
   SET request_cv->cd_value_list[1].display = request->task_group.display
   SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->task_group.display)
    )
   SET request_cv->cd_value_list[1].description = request->task_group.display
   SET request_cv->cd_value_list[1].collation_seq = request->task_group.collation_seq
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET 25451_cd = reply_cv->qual[1].code_value
   ELSE
    SET fail = "Y"
    GO TO exit_script
   ENDIF
  ENDIF
 ELSEIF ((request->action_flag=2))
  SET request_cv->cd_value_list[1].action_flag = 2
  SET request_cv->cd_value_list[1].code_value = request->task_group.code_value
  SET request_cv->cd_value_list[1].code_set = 25451
  SET request_cv->cd_value_list[1].cdf_meaning = ""
  SET request_cv->cd_value_list[1].display = request->task_group.display
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->task_group.display))
  SET request_cv->cd_value_list[1].description = request->task_group.display
  SET request_cv->cd_value_list[1].collation_seq = request->task_group.collation_seq
  SET request_cv->cd_value_list[1].active_ind = 1
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 25451_cd = reply_cv->qual[1].code_value
  ELSE
   SET fail = "Y"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action_flag=3))
  SET request_cv->cd_value_list[1].action_flag = 3
  SET request_cv->cd_value_list[1].code_value = request->task_group.code_value
  SET request_cv->cd_value_list[1].code_set = 25451
  SET request_cv->cd_value_list[1].cdf_meaning = ""
  SET request_cv->cd_value_list[1].display = request->task_group.display
  SET request_cv->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->task_group.display))
  SET request_cv->cd_value_list[1].description = request->task_group.display
  SET request_cv->cd_value_list[1].collation_seq = request->task_group.collation_seq
  SET request_cv->cd_value_list[1].active_ind = 0
  SET trace = recpersist
  EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
  IF ((reply_cv->status_data.status="S")
   AND (reply_cv->qual[1].code_value > 0))
   SET 25451_cd = reply_cv->qual[1].code_value
  ELSE
   SET fail = "Y"
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM code_value_group c
   WHERE c.parent_code_value=25451_cd
    AND c.code_set=6026
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET fail = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
  SET ierrcode = 0
  DELETE  FROM pip_prefs p
   WHERE p.pref_name="TASK_GROUP"
    AND (p.merge_id=request->task_group.code_value)
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET fail = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = size(request->task_types,5)
 IF (tcnt=0
  AND 25451_cd=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO tcnt)
   IF ((request->task_types[x].action_flag=1))
    SET ierrcode = 0
    INSERT  FROM code_value_group c
     SET c.parent_code_value = 25451_cd, c.child_code_value = request->task_types[x].code_value, c
      .collation_seq = null,
      c.code_set = 6026, c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
      c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
     PLAN (c)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET fail = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ELSEIF ((request->task_types[x].action_flag=3))
    SET ierrcode = 0
    DELETE  FROM code_value_group c
     WHERE c.parent_code_value=25451_cd
      AND (c.child_code_value=request->task_types[x].code_value)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET fail = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (fail="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
