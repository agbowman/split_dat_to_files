CREATE PROGRAM dcp_ens_assign_role_r
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE rsize = i4 WITH constant(size(request->qual,5)), public
 IF (rsize < 1)
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rsize)),
   assign_clinrole_r acr
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_flag != 2))
   JOIN (acr
   WHERE (acr.assignment_type_cd=request->qual[d.seq].assignment_type_cd)
    AND (acr.clin_role_type_cd=request->qual[d.seq].clin_role_type_cd))
  DETAIL
   request->qual[d.seq].action_flag = 1
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ASSIGN_CLINROLE_R"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM assign_clinrole_r acr,
   (dummyt d  WITH seq = value(rsize))
  SET acr.assign_cr_reltn_id = seq(dcp_assignment_seq,nextval), acr.assignment_type_cd = request->
   qual[d.seq].assignment_type_cd, acr.clin_role_type_cd = request->qual[d.seq].clin_role_type_cd,
   acr.updt_applctx = reqinfo->updt_applctx, acr.updt_cnt = 0, acr.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   acr.updt_id = reqinfo->updt_id, acr.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_flag=0))
   JOIN (acr
   WHERE 1=1)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "ASSIGN_CLINROLE_R"
  GO TO exit_script
 ENDIF
 DELETE  FROM assign_clinrole_r acr,
   (dummyt d  WITH seq = value(rsize))
  SET acr.seq = acr.seq
  PLAN (d
   WHERE d.seq > 0
    AND (request->qual[d.seq].action_flag=2))
   JOIN (acr
   WHERE (acr.assignment_type_cd=request->qual[d.seq].assignment_type_cd)
    AND (acr.clin_role_type_cd=request->qual[d.seq].clin_role_type_cd))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = delete_error
  SET table_name = "ASSIGN_CLINROLE_R"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
#exit_script
 IF (failed != false)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=delete_error)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=exe_error)
   SET reply->status_data.subeventstatus[1].operationname = "EXECUTION"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ENDIF
 SET script_ver = "000 03/31/05 SF3151"
END GO
