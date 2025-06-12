CREATE PROGRAM bbt_chg_valid_app_states:dba
 RECORD reply(
   1 qual[1]
     2 state_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET number_to_chg = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET failed = "F"
 SET count1 = 0
 SET count2 = 0
 SET cur_active_ind = 0
 SET cur_active_dt_tm = cnvtdatetime(curdate,curtime3)
 SET cur_inactive_dt_tm = cnvtdatetime(curdate,curtime3)
 SET partial_update = "F"
 FOR (x = 1 TO number_to_chg)
  SELECT INTO "nl:"
   v.state_cd
   FROM valid_state v
   WHERE (v.process_cd=request->process_cd)
    AND (v.category_cd=request->category_cd)
    AND (v.state_cd=request->qual[x].state_cd)
   DETAIL
    cur_active_ind = v.active_ind, cur_updt_cnt = v.updt_cnt, cur_active_dt_tm = v.active_dt_tm,
    cur_inactive_dt_tm = v.inactive_dt_tm
   WITH nocounter, forupdate(v)
  ;end select
  IF (curqual=0)
   INSERT  FROM valid_state v
    SET v.process_cd = request->process_cd, v.category_cd = request->category_cd, v.state_cd =
     request->qual[x].state_cd,
     v.active_ind = 1, v.active_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     v.updt_id = reqinfo->updt_id, v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->
     updt_applctx,
     v.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    SET count1 = (count1+ 1)
    IF (count1 > 1)
     SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "CHG"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "Valid State"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Insert failed"
   ELSE
    SET partial_update = "T"
    SET count2 = (count2+ 1)
    IF (count2 > 1)
     SET stat = alter(reply->qual,(count2+ 1))
    ENDIF
    SET reply->qual[count2].state_cd = request->qual[x].state_cd
    SET reply->qual[count2].updt_cnt = 0
   ENDIF
  ELSE
   IF ((request->qual[x].updt_cnt != cur_updt_cnt))
    SET failed = "T"
    SET count1 = (count1+ 1)
    IF (count1 > 1)
     SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "CHG"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "Valid State"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Update count mismatch"
   ELSE
    UPDATE  FROM valid_state v
     SET v.active_ind =
      IF (cur_active_ind=1) 0
      ELSE 1
      ENDIF
      , v.active_dt_tm =
      IF (cur_active_ind=0) cnvtdatetime(curdate,curtime3)
      ELSE cnvtdatetime(cur_active_dt_tm)
      ENDIF
      , v.inactive_dt_tm =
      IF (cur_active_ind=1) cnvtdatetime(curdate,curtime3)
      ELSE cnvtdatetime(cur_inactive_dt_tm)
      ENDIF
      ,
      v.updt_cnt = (v.updt_cnt+ 1), v.updt_dt_tm = cnvtdatetime(curdate,curtime3), v.updt_id =
      reqinfo->updt_id,
      v.updt_task = reqinfo->updt_task, v.updt_applctx = reqinfo->updt_applctx
     WHERE (v.process_cd=request->process_cd)
      AND (v.category_cd=request->category_cd)
      AND (v.state_cd=request->qual[x].state_cd)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET count1 = (count1+ 1)
     IF (count1 > 1)
      SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
     ENDIF
     SET reply->status_data.subeventstatus[count1].operationname = "CHG"
     SET reply->status_data.subeventstatus[count1].operationstatus = "F"
     SET reply->status_data.subeventstatus[count1].targetobjectname = "Valid State"
     SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Update failed"
    ELSE
     SET partial_update = "T"
     SET count2 = (count2+ 1)
     IF (count2 > 1)
      SET stat = alter(reply->qual,(count2+ 1))
     ENDIF
     SET reply->qual[count2].state_cd = request->qual[x].state_cd
     SET reply->qual[count2].updt_cnt = (request->qual[x].updt_cnt+ 1)
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 SET stat = alter(reply->qual,count2)
 IF (failed="T"
  AND partial_update="F")
  SET reqinfo->commit_ind = 0
 ELSEIF (failed="T"
  AND partial_update="T")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "P"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
