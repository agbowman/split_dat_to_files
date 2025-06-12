CREATE PROGRAM ct_upd_verf_excl_clients:dba
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
 DECLARE addcount = i4 WITH protect, noconstant(0)
 SET addcount = cnvtint(size(request->add_qual,5))
 DECLARE curupdtcnt = i4 WITH protect, noconstant(0)
 DECLARE updcount = i4 WITH protect, noconstant(0)
 SET updcount = cnvtint(size(request->upd_qual,5))
 DECLARE fail_flag = i2 WITH private, noconstant(0)
 DECLARE insert_error = i2 WITH private, noconstant(2)
 DECLARE update_error = i2 WITH private, noconstant(3)
 DECLARE lock_error = i2 WITH private, noconstant(4)
 IF (addcount > 0)
  INSERT  FROM ct_excluded_clients ec,
    (dummyt d  WITH seq = value(addcount))
   SET ec.organization_id = request->add_qual[d.seq].organization_id, ec.active_ind = 1, ec.updt_cnt
     = 0,
    ec.updt_dt_tm = cnvtdatetime(curdate,curtime3), ec.updt_id = reqinfo->updt_id, ec.updt_applctx =
    reqinfo->updt_applctx,
    ec.updt_task = reqinfo->updt_task, ec.active_status_cd = reqdata->active_status_cd, ec
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    ec.active_status_prsnl_id = reqinfo->updt_id
   PLAN (d)
    JOIN (ec)
   WITH counter
  ;end insert
  CALL echo(build("add curqual is: ",curqual))
  IF (curqual=0)
   SET fail_flag = insert_error
   GO TO check_error
  ENDIF
 ENDIF
 CALL echo(build("UpdCount is: ",updcount))
 IF (updcount > 0)
  SELECT INTO "nl:"
   ec.*
   FROM ct_excluded_clients ec,
    (dummyt d  WITH seq = value(updcount))
   PLAN (d)
    JOIN (ec
    WHERE (ec.organization_id=request->upd_qual[d.seq].organization_id))
   DETAIL
    curupdtcnt = (curupdtcnt+ 1)
   WITH counter, forupdate(ec)
  ;end select
  CALL echo(build("update for non active is: ",curqual))
  IF (curupdtcnt != updcount)
   SET fail_flag = lock_error
   GO TO check_error
  ENDIF
 ENDIF
 CALL echo(build("CurUpdtCnt is: ",curupdtcnt))
 IF (curupdtcnt > 0)
  UPDATE  FROM ct_excluded_clients ec,
    (dummyt d  WITH seq = value(updcount))
   SET ec.active_ind = request->upd_qual[d.seq].active_ind, ec.updt_cnt = (ec.updt_cnt+ 1), ec
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ec.updt_id = reqinfo->updt_id, ec.updt_applctx = reqinfo->updt_applctx, ec.updt_task = reqinfo->
    updt_task,
    ec.active_status_cd =
    IF ((request->upd_qual[d.seq].active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , ec.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ec.active_status_prsnl_id = reqinfo->
    updt_id
   PLAN (d)
    JOIN (ec
    WHERE (ec.organization_id=request->upd_qual[d.seq].organization_id))
   WITH counter
  ;end update
  CALL echo(build("Curqual for update is: ",curqual))
  IF (curqual=0)
   SET fail_flag = update_error
   GO TO check_error
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
