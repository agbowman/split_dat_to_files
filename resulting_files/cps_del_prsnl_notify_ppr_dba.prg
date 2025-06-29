CREATE PROGRAM cps_del_prsnl_notify_ppr:dba
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
 FOR (i = 1 TO request->prsnl_qual)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   DELETE  FROM prsnl_notify_ppr pnp,
     (dummyt d  WITH seq = value(request->prsnl[i].ppr_qual))
    SET pnp.seq = 1
    PLAN (d
     WHERE d.seq > 0)
     JOIN (pnp
     WHERE (pnp.prsnl_notify_id=request->prsnl[i].prsnl_notify_id)
      AND (pnp.ppr_cd=request->prsnl[i].ppr[d.seq].ppr_cd)
      AND (pnp.ppr_flag=request->prsnl[i].ppr[d.seq].ppr_flag))
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_NOTIFY_PPR"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (ierrcode < 1)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
 SET cps_script_ver = "001 12/08/03 SF3151"
END GO
