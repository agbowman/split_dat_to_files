CREATE PROGRAM bed_ens_rel_sr:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET parent_type_cd = 0.0
 SET active_code_value = 0.0
 SET inactive_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("ACTIVE", "INACTIVE")
  DETAIL
   IF (cv.cdf_meaning="ACTIVE")
    active_code_value = cv.code_value
   ELSE
    inactive_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the ACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SET rel_cnt = size(request->relations,5)
 SET sect_type_cd = 0.0
 SET subsect_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("SUBSECTION", "SECTION")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "SECTION":
     sect_type_cd = cv.code_value
    OF "SUBSECTION":
     subsect_type_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 FOR (x = 1 TO rel_cnt)
   IF ((request->relations[x].action_flag=1))
    SET active_ind = 0
    SET hold_resource_group_type_cd = 0.0
    SET hold_root_service_resource_cd = 0.0
    SELECT INTO "NL:"
     FROM resource_group r
     WHERE (r.parent_service_resource_cd=request->relations[x].parent_code_value)
      AND (r.child_service_resource_cd=request->relations[x].child_code_value)
     DETAIL
      active_ind = r.active_ind, hold_resource_group_type_cd = r.resource_group_type_cd,
      hold_root_service_resource_cd = r.root_service_resource_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET parent_type_cd = 0.0
     SELECT INTO "NL:"
      FROM code_value cv
      WHERE (cv.code_value=request->relations[x].parent_code_value)
      DETAIL
       IF (cv.cdf_meaning="SECTION")
        parent_type_cd = sect_type_cd
       ELSE
        parent_type_cd = subsect_type_cd
       ENDIF
      WITH nocounter
     ;end select
     SET max_sequence = 0
     SELECT INTO "nl:"
      FROM resource_group rg
      PLAN (rg
       WHERE (rg.parent_service_resource_cd=request->relations[x].parent_code_value)
        AND rg.resource_group_type_cd=parent_type_cd
        AND rg.root_service_resource_cd=0)
      DETAIL
       IF (max_sequence < rg.sequence)
        max_sequence = rg.sequence
       ENDIF
      WITH nocounter
     ;end select
     INSERT  FROM resource_group r
      SET r.seq = 1, r.parent_service_resource_cd = request->relations[x].parent_code_value, r
       .child_service_resource_cd = request->relations[x].child_code_value,
       r.resource_group_type_cd = parent_type_cd, r.root_service_resource_cd = 0.0, r.sequence = (
       max_sequence+ 1),
       r.active_ind = 1, r.active_status_cd = active_code_value, r.active_status_dt_tm = cnvtdatetime
       (curdate,curtime3),
       r.active_status_prsnl_id = 0, r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r
       .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
       r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
       reqinfo->updt_task,
       r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_text = concat("Error adding resource_group for parent: ",cnvtstring(request->
        relations[x].parent_code_value)," child: ",cnvtstring(request->relations[x].child_code_value)
       )
     ENDIF
     INSERT  FROM sr_resource_group_hist s
      SET s.sr_resource_group_hist_id = seq(location_resource_seq,nextval), s
       .parent_service_resource_cd = request->relations[x].parent_code_value, s
       .child_service_resource_cd = request->relations[x].child_code_value,
       s.resource_group_type_cd = parent_type_cd, s.root_service_resource_cd = 0.0, s.active_ind = 1,
       s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00.00"), s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx,
       s.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_text = concat("Error adding sr_resource_group_hist for parent: ",cnvtstring(request->
        relations[x].parent_code_value)," child: ",cnvtstring(request->relations[x].child_code_value)
       )
     ENDIF
    ELSEIF (active_ind=0)
     UPDATE  FROM resource_group r
      SET r.active_ind = 1, r.active_status_cd = active_code_value, r.end_effective_dt_tm =
       cnvtdatetime("31-dec-2100 00:00:00.00"),
       r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
       reqinfo->updt_task,
       r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r.updt_cnt+ 1)
      WHERE (r.parent_service_resource_cd=request->relations[x].parent_code_value)
       AND (r.child_service_resource_cd=request->relations[x].child_code_value)
      WITH nocounter
     ;end update
     INSERT  FROM sr_resource_group_hist s
      SET s.sr_resource_group_hist_id = seq(location_resource_seq,nextval), s
       .parent_service_resource_cd = request->relations[x].parent_code_value, s
       .child_service_resource_cd = request->relations[x].child_code_value,
       s.resource_group_type_cd = hold_resource_group_type_cd, s.root_service_resource_cd =
       hold_root_service_resource_cd, s.active_ind = 1,
       s.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.end_effective_dt_tm = cnvtdatetime(
        "31-dec-2100 00:00:00.00"), s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx,
       s.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_text = concat("Error adding sr_resource_group_hist for parent: ",cnvtstring(request->
        relations[x].parent_code_value)," child: ",cnvtstring(request->relations[x].child_code_value)
       )
     ENDIF
    ENDIF
   ELSEIF ((request->relations[x].action_flag=3))
    UPDATE  FROM resource_group r
     SET r.active_ind = 0, r.active_status_cd = inactive_code_value, r.end_effective_dt_tm =
      cnvtdatetime(curdate,curtime3),
      r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
      reqinfo->updt_task,
      r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r.updt_cnt+ 1)
     WHERE (r.parent_service_resource_cd=request->relations[x].parent_code_value)
      AND (r.child_service_resource_cd=request->relations[x].child_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error inactivating resource_group for parent: ",cnvtstring(request->
       relations[x].parent_code_value)," child: ",cnvtstring(request->relations[x].child_code_value))
     GO TO exit_script
    ENDIF
    UPDATE  FROM sr_resource_group_hist s
     SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), s.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
      updt_applctx,
      s.updt_cnt = (s.updt_cnt+ 1)
     WHERE (s.parent_service_resource_cd=request->relations[x].parent_code_value)
      AND (s.child_service_resource_cd=request->relations[x].child_code_value)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_SR","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
