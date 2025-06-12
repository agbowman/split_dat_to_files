CREATE PROGRAM aps_add_login_order_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET nbr_to_insert = cnvtint(size(request->qual,5))
 IF (nbr_to_insert > 0)
  INSERT  FROM ap_login_order_list l,
    (dummyt d  WITH seq = value(nbr_to_insert))
   SET l.encntr_id = request->encntr_id, l.accession_id = request->qual[d.seq].accession_id, l
    .order_id = request->qual[d.seq].order_id,
    l.updt_dt_tm = cnvtdatetime(curdate,curtime), l.updt_id = reqinfo->updt_id, l.updt_task = reqinfo
    ->updt_task,
    l.updt_applctx = reqinfo->updt_applctx, l.updt_cnt = 0
   PLAN (d)
    JOIN (l
    WHERE (l.order_id=request->qual[d.seq].order_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_to_insert)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_LOGIN_ORDER_LIST"
   SET failed = "T"
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
