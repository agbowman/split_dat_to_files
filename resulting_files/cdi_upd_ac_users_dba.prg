CREATE PROGRAM cdi_upd_ac_users:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 delete_rows[*]
     2 cdi_ac_user_id = f8
 )
 DECLARE user_rows = i4 WITH noconstant(value(size(request->users,5))), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE err_msg = vc WITH noconstant(" "), protect
 DECLARE rows_to_update_count = i4 WITH noconstant(0), public
 DECLARE rows_to_delete_count = i4 WITH noconstant(0), protect
 DECLARE rows_to_insert_count = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 IF (user_rows > 0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_USER"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Lock rows for update/delete."
  SET stat = alterlist(temp->delete_rows,user_rows)
  SELECT INTO "NL:"
   u.updt_cnt
   FROM cdi_ac_user u
   WHERE expand(num,1,user_rows,u.cdi_ac_user_id,request->users[num].cdi_ac_user_id)
   DETAIL
    i = locateval(num,1,user_rows,u.cdi_ac_user_id,request->users[num].cdi_ac_user_id)
    IF (i > 0)
     IF ((request->users[i].cdi_ac_user_id > 0)
      AND (request->users[i].updt_cnt=u.updt_cnt))
      IF ((request->users[i].deleted_ind=0))
       rows_to_update_count = (rows_to_update_count+ 1)
      ELSE
       rows_to_delete_count = (rows_to_delete_count+ 1), temp->delete_rows[rows_to_delete_count].
       cdi_ac_user_id = u.cdi_ac_user_id
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, forupdate(u)
  ;end select
  SET stat = alterlist(temp->delete_rows,rows_to_delete_count)
  IF (rows_to_delete_count > 0)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_USER"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Delete ",rows_to_delete_count,
    " rows.")
   DELETE  FROM cdi_ac_user u
    WHERE expand(num,1,rows_to_delete_count,u.cdi_ac_user_id,temp->delete_rows[num].cdi_ac_user_id)
   ;end delete
   IF (rows_to_delete_count != curqual)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (rows_to_update_count > 0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_USER"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Update ",rows_to_update_count,
    " rows.")
   UPDATE  FROM cdi_ac_user u,
     (dummyt d  WITH seq = user_rows)
    SET u.ac_username = request->users[d.seq].ac_username, u.mill_username = request->users[d.seq].
     mill_username, u.auditing_ind = request->users[d.seq].auditing_ind,
     u.organization_id = request->users[d.seq].organization_id, u.updt_cnt = (u.updt_cnt+ 1), u
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     u.updt_task = reqinfo->updt_task, u.updt_id = reqinfo->updt_id, u.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d
     WHERE (request->users[d.seq].deleted_ind=0))
     JOIN (u
     WHERE (u.cdi_ac_user_id=request->users[d.seq].cdi_ac_user_id)
      AND (u.updt_cnt=request->users[d.seq].updt_cnt))
    WITH nocounter
   ;end update
   IF (rows_to_update_count != curqual)
    GO TO exit_script
   ENDIF
  ENDIF
  SET rows_to_insert_count = ((user_rows - rows_to_delete_count) - rows_to_update_count)
  IF (rows_to_insert_count > 0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_USER"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Insert ",rows_to_insert_count,
    " rows.")
   INSERT  FROM cdi_ac_user u,
     (dummyt d  WITH seq = user_rows)
    SET u.cdi_ac_user_id = seq(cdi_seq,nextval), u.ac_username = request->users[d.seq].ac_username, u
     .mill_username = request->users[d.seq].mill_username,
     u.auditing_ind = request->users[d.seq].auditing_ind, u.organization_id = request->users[d.seq].
     organization_id, u.updt_cnt = 0,
     u.updt_dt_tm = cnvtdatetime(curdate,curtime3), u.updt_task = reqinfo->updt_task, u.updt_id =
     reqinfo->updt_id,
     u.updt_applctx = reqinfo->updt_applctx
    PLAN (d
     WHERE (request->users[d.seq].cdi_ac_user_id=0.0)
      AND (request->users[d.seq].deleted_ind=0))
     JOIN (u)
    WITH nocounter
   ;end insert
   IF (rows_to_insert_count != curqual)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = " "
 SET reply->status_data.subeventstatus[1].targetobjectname = " "
 SET reply->status_data.subeventstatus[1].targetobjectvalue = " "
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
