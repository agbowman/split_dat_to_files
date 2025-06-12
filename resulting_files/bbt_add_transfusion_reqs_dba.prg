CREATE PROGRAM bbt_add_transfusion_reqs:dba
 RECORD reply(
   1 qual[1]
     2 code_value = f8
     2 display = c40
     2 antid_updt_cnt = i4
     2 relationship_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failures = 0
 SET nbr_to_add = size(request->qual,5)
 SET y = 1
 SET count1 = 0
 SET next_code = 0.0
 SET auth_data_status_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   auth_data_status_cd = cv.code_value
  WITH nocounter
 ;end select
#start_loop
 FOR (y = y TO nbr_to_add)
   EXECUTE cpm_next_code
   INSERT  FROM code_value c
    SET c.code_value = next_code, c.code_set = request->code_set, c.cdf_meaning =
     IF ((request->qual[y].cdf_meaning > " ")) request->qual[y].cdf_meaning
     ELSE null
     ENDIF
     ,
     c.display = request->qual[y].display, c.display_key = trim(cnvtupper(cnvtalphanum(request->qual[
        y].display))), c.description = request->qual[y].description,
     c.definition = request->qual[y].definition, c.collation_seq = request->qual[y].collation_seq, c
     .active_type_cd = 0.0,
     c.active_ind = request->qual[y].active_ind, c.active_dt_tm =
     IF ((request->qual[y].active_ind=1)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     , c.inactive_dt_tm =
     IF ((request->qual[y].active_ind=0)) cnvtdatetime(curdate,curtime3)
     ELSE null
     ENDIF
     ,
     c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_cnt = 0,
     c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c
     .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     c.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), c.data_status_cd = auth_data_status_cd, c
     .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     c.data_status_prsnl_id = reqinfo->updt_id, c.active_status_prsnl_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failures = (failures+ 1)
    IF (failures > 1)
     SET stat = alter(reply->status_data.subeventstatus,failures)
    ENDIF
    SET reply->status_data.subeventstatus[failures].operationstatus = "F"
    SET reply->status_data.subeventstatus[failures].targetobjectvalue = request->qual[y].display
    SET reply->qual[count1].code_value = 0.0
    SET reply->qual[count1].display = request->qual[y].display
    ROLLBACK
    SET y = (y+ 1)
    GO TO start_loop
   ELSE
    SET count1 = (count1+ 1)
    SET stat = alter(reply->qual,count1)
    SET reply->qual[count1].code_value = next_code
    SET reply->qual[count1].display = request->qual[y].display
   ENDIF
   INSERT  FROM transfusion_requirements t
    SET t.codeset = request->code_set, t.requirement_cd = next_code, t.description = trim(request->
      qual[y].trans_req_desc),
     t.chart_name = trim(request->qual[y].trans_req_desc), t.anti_d_ind = request->qual[y].anti_d_ind,
     t.active_ind = request->qual[y].active_ind,
     t.active_status_cd = reqdata->active_status_cd, t.active_status_prsnl_id = reqinfo->updt_id, t
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id, t.updt_task =
     reqinfo->updt_task,
     t.updt_applctx = reqinfo->updt_applctx, t.significance_ind = request->qual[y].significance_ind,
     t.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failures = (failures+ 1)
    IF (failures > 1)
     SET stat = alter(reply->status_data.subeventstatus,failures)
    ENDIF
    SET reply->status_data.subeventstatus[failures].operationstatus = "F"
    SET reply->status_data.subeventstatus[failures].targetobjectvalue = request->qual[y].display
    SET reply->qual[count1].code_value = 0.0
    SET reply->qual[count1].display = request->qual[y].display
    ROLLBACK
    SET y = (y+ 1)
    GO TO start_loop
   ENDIF
   IF ((request->qual[y].anti_d_ind=1))
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
     SET t.relationship_id = new_pathnet_seq, t.requirement_cd = next_code, t.special_testing_cd =
      request->qual[y].rh_cd,
      t.warn_ind = request->qual[y].warn_ind, t.allow_override_ind = request->qual[y].override_ind, t
      .active_ind = request->qual[y].active_ind,
      t.active_status_cd = reqdata->active_status_cd, t.active_status_prsnl_id = reqinfo->updt_id, t
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_id = reqinfo->updt_id, t.updt_task =
      reqinfo->updt_task,
      t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failures = (failures+ 1)
     IF (failures > 1)
      SET stat = alter(reply->status_data.subeventstatus,failures)
     ENDIF
     SET reply->status_data.subeventstatus[failures].operationstatus = "F"
     SET reply->status_data.subeventstatus[failures].targetobjectvalue = request->qual[y].display
     SET reply->qual[count1].code_value = 0.0
     SET reply->qual[count1].display = request->qual[y].display
     ROLLBACK
     SET y = (y+ 1)
     GO TO start_loop
    ELSE
     SET reply->qual[count1].antid_updt_cnt = 0
     SET reply->qual[count1].relationship_id = new_pathnet_seq
     COMMIT
    ENDIF
   ELSE
    COMMIT
   ENDIF
 ENDFOR
#exit_script
 IF (failures > 0)
  SET reply->status_data.status = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
