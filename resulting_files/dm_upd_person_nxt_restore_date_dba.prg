CREATE PROGRAM dm_upd_person_nxt_restore_date:dba
 SELECT INTO "nl:"
  FROM person p
  WHERE (p.person_id=request->person_id)
   AND ((p.next_restore_dt_tm=null) OR (p.next_restore_dt_tm > cnvtdatetime(request->
   next_restore_dt_tm)))
  WITH nocounter
 ;end select
 IF (curqual)
  SET stat = error(reply->err_msg,1)
  SET reply->err_num = 0
  UPDATE  FROM person p
   SET p.next_restore_dt_tm = cnvtdatetime(request->next_restore_dt_tm)
   WHERE (p.person_id=request->person_id)
   WITH nocounter
  ;end update
  SET reply->err_num = error(reply->err_msg,0)
  IF (reply->err_num)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
  ELSE
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
