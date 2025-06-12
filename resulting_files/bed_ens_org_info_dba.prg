CREATE PROGRAM bed_ens_org_info:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET organization_infos_cnt = size(request->organization_infos,5)
 IF (organization_infos_cnt=0)
  GO TO exit_script
 ENDIF
 CALL echorecord(request)
 SET active_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
  DETAIL
   active_code = cv.code_value
  WITH nocounter
 ;end select
 SET current_user_id = 0.0
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE p.username=cnvtupper(curuser)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   current_user_id = p.person_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO organization_infos_cnt)
   CALL echo(organization_infos_cnt)
   SET sub_type_code_values_cnt = size(request->organization_infos[x].sub_type_code_values,5)
   CALL echo(sub_type_code_values_cnt)
   FOR (y = 1 TO sub_type_code_values_cnt)
     INSERT  FROM org_info oi,
       (dummyt d  WITH value(sub_type_code_values_cnt))
      SET oi.org_info_id = seq(organization_seq,nextval), oi.info_type_cd = request->info_type_cd, oi
       .organization_id = request->organization_infos[x].organization_id,
       oi.value_cd = request->organization_infos[x].sub_type_code_values[y].sub_type_code_value, oi
       .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), oi.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"),
       oi.active_ind = 1, oi.active_status_cd = active_code, oi.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       oi.active_status_prsnl_id = current_user_id, oi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       oi.updt_applctx = 0,
       oi.updt_id = reqinfo->updt_id, oi.updt_cnt = 0, oi.updt_task = reqinfo->updt_task
      PLAN (d
       WHERE (request->organization_infos[x].sub_type_code_values[y].action_flag=1))
       JOIN (oi)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error inserting into org_info")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
     UPDATE  FROM org_info oi,
       (dummyt d  WITH value(sub_type_code_values_cnt))
      SET oi.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), oi.updt_id = reqinfo->updt_id, oi
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       oi.updt_task = reqinfo->updt_task, oi.updt_applctx = reqinfo->updt_applctx, oi.updt_cnt = (oi
       .updt_cnt+ 1)
      PLAN (d
       WHERE (request->organization_infos[x].sub_type_code_values[y].action_flag=3))
       JOIN (oi
       WHERE (oi.organization_id=request->organization_infos[x].organization_id)
        AND (oi.info_type_cd=request->info_type_cd)
        AND (oi.value_cd=request->organization_infos[x].sub_type_code_values[y].sub_type_code_value))
      WITH nocounter
     ;end update
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error updating into org_info")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
   ENDFOR
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
