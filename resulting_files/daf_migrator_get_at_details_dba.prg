CREATE PROGRAM daf_migrator_get_at_details:dba
 IF (validate(request->obj_list,"Z")="Z")
  FREE RECORD request
  RECORD request(
    1 target_env_id = f8
    1 obj_list[*]
      2 script_name = vc
      2 script_group = i2
    1 source_env_id = f8
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 obj_list[*]
     2 script_name = vc
     2 script_group = i2
     2 compile_user = vc
     2 source_name = vc
     2 compile_date = dq8
     2 staged_user = vc
     2 staged_date = dq8
     2 staged_compile_date = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = vc WITH public
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET stat = alterlist(reply->obj_list,size(request->obj_list,5))
 FOR (i = 1 TO size(request->obj_list,5))
   SET reply->obj_list[i].script_name = request->obj_list[i].script_name
   SET reply->obj_list[i].script_group = request->obj_list[i].script_group
   SELECT INTO "nl:"
    dacsi.user_name, dacsi.source_name, dacsi.compile_dt_tm
    FROM dm_adm_csm_script_info dacsi
    WHERE (dacsi.environment_id=request->source_env_id)
     AND dacsi.script_name=cnvtupper(reply->obj_list[i].script_name)
     AND (dacsi.script_group=reply->obj_list[i].script_group)
    DETAIL
     reply->obj_list[i].compile_user = dacsi.user_name, reply->obj_list[i].source_name = dacsi
     .source_name, reply->obj_list[i].compile_date = cnvtdatetime(dacsi.compile_dt_tm)
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to write ccl objects:",errmsg)
    GO TO exit_script
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  dsms.commit_dt_tm, dsms.commit_compile_dt_tm, p.username
  FROM dm_script_migration_stage dsms,
   prsnl p,
   (dummyt d  WITH seq = value(size(reply->obj_list,5)))
  PLAN (d)
   JOIN (dsms
   WHERE cnvtupper(dsms.script_name)=cnvtupper(reply->obj_list[d.seq].script_name)
    AND (dsms.script_group_nbr=reply->obj_list[d.seq].script_group)
    AND (dsms.target_environment_id=request->target_env_id)
    AND dsms.active_ind=1)
   JOIN (p
   WHERE p.person_id=dsms.commit_updt_id)
  DETAIL
   reply->obj_list[d.seq].staged_date = cnvtdatetime(dsms.commit_dt_tm), reply->obj_list[d.seq].
   staged_compile_date = cnvtdatetime(dsms.commit_compile_dt_tm), reply->obj_list[d.seq].staged_user
    = p.username
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to write ccl objects:",errmsg)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "Retrieved all data successfully"
#exit_script
END GO
