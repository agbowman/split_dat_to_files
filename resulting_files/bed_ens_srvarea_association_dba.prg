CREATE PROGRAM bed_ens_srvarea_association:dba
 FREE SET reply
 RECORD reply(
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
 SET failed = "N"
 SET srvarea_cd = 0.0
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="SRVAREA"
  DETAIL
   srvarea_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
  DETAIL
   inactive_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(request->srvareas,5))
   FOR (z = 1 TO size(request->srvareas[x].units,5))
     IF ((request->srvareas[x].units[z].action_flag=1))
      SET update_ind = 0
      SELECT INTO "nl:"
       FROM location_group lg
       PLAN (lg
        WHERE (lg.parent_loc_cd=request->srvareas[x].code_value)
         AND (lg.child_loc_cd=request->srvareas[x].units[z].code_value)
         AND lg.active_ind=0)
       DETAIL
        update_ind = 1
       WITH nocounter
      ;end select
      IF (update_ind=1)
       SET ierrcode = 0
       UPDATE  FROM location_group lg
        SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg
         WHERE (lg.parent_loc_cd=request->srvareas[x].code_value)
          AND (lg.child_loc_cd=request->srvareas[x].units[z].code_value))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ELSE
       SET unit_seq = 0
       SELECT INTO "nl:"
        FROM location_group lg
        PLAN (lg
         WHERE (lg.parent_loc_cd=request->srvareas[x].code_value)
          AND lg.location_group_type_cd=srvarea_cd)
        ORDER BY lg.sequence
        DETAIL
         unit_seq = lg.sequence
        WITH nocounter
       ;end select
       SET unit_seq = (unit_seq+ 2)
       SET ierrcode = 0
       INSERT  FROM location_group lg
        SET lg.parent_loc_cd = request->srvareas[x].code_value, lg.child_loc_cd = request->srvareas[x
         ].units[z].code_value, lg.location_group_type_cd = srvarea_cd,
         lg.sequence = unit_seq, lg.root_loc_cd = 0, lg.view_type_cd = 0,
         lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100"), lg.active_status_prsnl_id = reqinfo->updt_id,
         lg.active_ind = 1, lg.active_status_cd = active_cd, lg.active_status_dt_tm = cnvtdatetime(
          curdate,curtime3),
         lg.updt_id = reqinfo->updt_id, lg.updt_cnt = 0, lg.updt_dt_tm = cnvtdatetime(curdate,
          curtime3),
         lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
        PLAN (lg)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = "Y"
        GO TO exit_script
       ENDIF
      ENDIF
     ELSEIF ((request->srvareas[x].units[z].action_flag=3))
      SET ierrcode = 0
      UPDATE  FROM location_group lg
       SET lg.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), lg.end_effective_dt_tm =
        cnvtdatetime(curdate,curtime3), lg.active_status_prsnl_id = reqinfo->updt_id,
        lg.active_ind = 0, lg.active_status_cd = inactive_cd, lg.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_id = reqinfo->updt_id, lg.updt_cnt = (lg.updt_cnt+ 1), lg.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lg.updt_task = reqinfo->updt_task, lg.updt_applctx = reqinfo->updt_applctx
       PLAN (lg
        WHERE (lg.parent_loc_cd=request->srvareas[x].code_value)
         AND (lg.child_loc_cd=request->srvareas[x].units[z].code_value))
       WITH nocounter
      ;end update
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = "Y"
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
