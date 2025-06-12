CREATE PROGRAM bbt_chg_transfusion_reqs:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 updt_cnt = i4
     2 trans_req_updtcnt = i4
     2 relationship_id = f8
     2 antid_updt_cnt = i4
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt[500] = 0
 SET failed = "F"
 SET count1 = 0
 SET nbr_to_chg = size(request->qual,5)
 SET failures = 0
 SET cur_updt_cnt = 0
 SET cur_rh_cd = 0.0
 SET x = 1
 SET next_code = 0.0
 SET found = 0
 SET new_pathnet_seq = 0.0
#start_loop
 FOR (x = x TO nbr_to_chg)
   SET failed = "F"
   IF ((request->qual[x].cv_updt_ind=1))
    SELECT INTO "nl:"
     c.*
     FROM code_value c
     WHERE (c.code_value=request->qual[x].code_value)
      AND (c.code_set=request->code_set)
     DETAIL
      cur_updt_cnt = c.updt_cnt
     WITH nocounter, forupdate(c)
    ;end select
    IF (curqual=0)
     GO TO next_row
    ENDIF
    IF ((cur_updt_cnt != request->qual[x].updt_cnt))
     SET failed = "T"
     GO TO next_row
    ENDIF
    UPDATE  FROM code_value c
     SET c.display = request->qual[x].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->
         qual[x].display))), c.description = request->qual[x].description,
      c.definition = request->qual[x].definition, c.active_type_cd = request->qual[x].active_type_cd,
      c.active_ind = request->qual[x].active_ind,
      c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt
      + 1),
      c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (c.code_value=request->qual[x].code_value)
      AND (c.code_set=request->code_set)
     WITH nocounter
    ;end update
    IF (curqual=0)
     GO TO next_row
    ENDIF
   ENDIF
   SET failed = "F"
   IF ((request->qual[x].trans_updt_ind=1))
    SELECT INTO "nl:"
     t.*
     FROM transfusion_requirements t
     WHERE (t.requirement_cd=request->qual[x].code_value)
     DETAIL
      cur_updt_cnt = t.updt_cnt
     WITH nocounter, forupdate(t)
    ;end select
    IF (curqual=0)
     GO TO next_row
    ENDIF
    IF ((request->qual[x].trans_req_updtcnt != cur_updt_cnt))
     SET failed = "T"
     GO TO next_row
    ENDIF
    UPDATE  FROM transfusion_requirements t
     SET t.description = request->qual[x].trans_req_desc, t.chart_name = request->qual[x].
      trans_req_desc, t.anti_d_ind =
      IF ((request->qual[x].updt_anti_d_ind=1)) request->qual[x].anti_d_ind
      ELSE t.anti_d_ind
      ENDIF
      ,
      t.active_ind = request->qual[x].active_ind, t.significance_ind = request->qual[x].
      significance_ind, t.active_status_cd =
      IF ((request->qual[x].active_ind=1)) reqdata->active_status_cd
      ELSE reqdata->inactive_status_cd
      ENDIF
      ,
      t.updt_cnt = (t.updt_cnt+ 1), t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id =
      reqinfo->updt_id,
      t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
     WHERE (t.requirement_cd=request->qual[x].code_value)
      AND (t.updt_cnt=request->qual[x].trans_req_updtcnt)
     WITH nocounter
    ;end update
    IF (curqual=0)
     GO TO next_row
    ENDIF
   ENDIF
   IF ((request->qual[x].updt_anti_d_ind=1))
    SELECT INTO "nl:"
     t.*
     FROM trans_req_r t
     PLAN (t
      WHERE (t.relationship_id=request->qual[x].relationship_id)
       AND (request->qual[x].relationship_id > 0))
     DETAIL
      cur_updt_cnt = t.updt_cnt, cur_rh_cd = t.special_testing_cd
     WITH nocounter, forupdate(t)
    ;end select
    IF (curqual=0)
     SET found = 0
    ELSE
     SET found = 1
    ENDIF
    IF (found=0
     AND (request->qual[x].anti_d_ind=0))
     GO TO next_row
    ENDIF
    IF (found=1
     AND (request->qual[x].antid_updt_cnt != cur_updt_cnt))
     SET failed = "T"
     GO TO next_row
    ENDIF
    IF (found=0
     AND (request->qual[x].anti_d_ind=1)
     AND (request->qual[x].relationship_id=0))
     DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
     SET new_pathnet_seq = 0
     SELECT INTO "nl:"
      seqn = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_pathnet_seq = seqn
      WITH format, nocounter
     ;end select
     INSERT  FROM trans_req_r t
      SET t.relationship_id = new_pathnet_seq, t.requirement_cd = request->qual[x].code_value, t
       .special_testing_cd = request->qual[x].rh_cd,
       t.warn_ind = request->qual[x].warn_ind, t.allow_override_ind = request->qual[x].override_ind,
       t.active_ind = 1,
       t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t.active_status_cd = reqdata->
       active_status_cd, t.active_status_prsnl_id = reqinfo->updt_id,
       t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id, t.updt_task =
       reqinfo->updt_task,
       t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      GO TO next_row
     ENDIF
    ENDIF
    IF (found=1
     AND (request->qual[x].anti_d_ind=0))
     UPDATE  FROM trans_req_r t
      SET t.active_ind = 0, t.active_status_cd = reqdata->active_status_cd, t.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
       updt_applctx,
       t.updt_cnt = (t.updt_cnt+ 1)
      WHERE (t.relationship_id=request->qual[x].relationship_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO next_row
     ENDIF
    ENDIF
    IF (found=1
     AND (request->qual[x].rh_cd > 0)
     AND (request->qual[x].rh_cd != cur_rh_cd))
     UPDATE  FROM trans_req_r t
      SET t.active_ind = 0, t.active_status_cd = reqdata->active_status_cd, t.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
       updt_applctx,
       t.updt_cnt = (t.updt_cnt+ 1)
      WHERE (t.relationship_id=request->qual[x].relationship_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO next_row
     ENDIF
     DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
     SET new_pathnet_seq = 0
     SELECT INTO "nl:"
      seqn = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_pathnet_seq = seqn
      WITH format, nocounter
     ;end select
     INSERT  FROM trans_req_r t
      SET t.relationship_id = new_pathnet_seq, t.requirement_cd = request->qual[x].code_value, t
       .special_testing_cd = request->qual[x].rh_cd,
       t.warn_ind = request->qual[x].warn_ind, t.allow_override_ind = request->qual[x].override_ind,
       t.active_ind = 1,
       t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t.active_status_cd = reqdata->
       active_status_cd, t.active_status_prsnl_id = reqinfo->updt_id,
       t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id, t.updt_task =
       reqinfo->updt_task,
       t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = "T"
      GO TO next_row
     ENDIF
    ENDIF
    IF (found=1
     AND (request->qual[x].rh_cd > 0)
     AND (request->qual[x].rh_cd=cur_rh_cd)
     AND (request->qual[x].anti_d_ind=1))
     UPDATE  FROM trans_req_r t
      SET t.active_ind = 1, t.warn_ind = request->qual[x].warn_ind, t.allow_override_ind = request->
       qual[x].override_ind,
       t.active_status_cd = reqdata->active_status_cd, t.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       t.updt_id = reqinfo->updt_id,
       t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = (t
       .updt_cnt+ 1)
      WHERE (t.relationship_id=request->qual[x].relationship_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = "T"
      GO TO next_row
     ENDIF
    ENDIF
   ENDIF
   SET count1 = (count1+ 1)
   SET stat = alterlist(reply->qual,count1)
   SET reply->qual[count1].code_value = request->qual[x].code_value
   IF ((request->qual[x].cv_updt_ind=1))
    SET reply->qual[count1].updt_cnt = (request->qual[x].updt_cnt+ 1)
   ELSE
    SET reply->qual[count1].updt_cnt = request->qual[x].updt_cnt
   ENDIF
   IF ((request->qual[x].trans_updt_ind=1))
    SET reply->qual[count1].trans_req_updtcnt = (request->qual[x].trans_req_updtcnt+ 1)
   ELSE
    SET reply->qual[count1].trans_req_updtcnt = request->qual[x].trans_req_updtcnt
   ENDIF
   IF (found=1)
    SET reply->qual[count1].antid_updt_cnt = (request->qual[x].antid_updt_cnt+ 1)
    SET reply->qual[count1].relationship_id = request->qual[x].relationship_id
   ELSE
    SET reply->qual[count1].antid_updt_cnt = request->qual[x].antid_updt_cnt
    SET reply->qual[count1].relationship_id = new_pathnet_seq
   ENDIF
   SET reply->qual[count1].status = "S"
   COMMIT
 ENDFOR
 GO TO exit_script
#next_row
 SET count1 = (count1+ 1)
 SET stat = alterlist(reply->qual,count1)
 SET reply->qual[count1].code_value = request->qual[x].code_value
 SET reply->qual[count1].updt_cnt = request->qual[x].updt_cnt
 SET reply->qual[count1].trans_req_updtcnt = request->qual[x].trans_req_updtcnt
 SET reply->qual[count1].antid_updt_cnt = request->qual[x].antid_updt_cnt
 SET reply->qual[count1].relationship_id = request->qual[x].relationship_id
 SET reply->qual[count1].status = "F"
 SET failures = (failures+ 1)
 SET stat = alterlist(reply->status_data.subeventstatus,failures)
 IF (failed="F")
  SET reply->status_data.subeventstatus[failures].operationstatus = "F"
 ELSE
  SET reply->status_data.subeventstatus[failures].operationstatus = "C"
 ENDIF
 SET reply->status_data.subeventstatus[failures].targetobjectvalue = cnvtstring(request->qual[x].
  code_value,32,2)
 ROLLBACK
 SET x = (x+ 1)
 GO TO start_loop
#exit_script
 IF (failures=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
