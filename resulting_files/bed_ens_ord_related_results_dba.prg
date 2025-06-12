CREATE PROGRAM bed_ens_ord_related_results:dba
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
 SET ocnt = size(request->orderables,5)
 IF (ocnt > 0)
  DELETE  FROM catalog_event_sets c,
    (dummyt d  WITH seq = ocnt)
   SET c.seq = 1
   PLAN (d)
    JOIN (c
    WHERE (c.catalog_cd=request->orderables[d.seq].code_value))
   WITH nocounter
  ;end delete
  INSERT  FROM catalog_event_sets c,
    (dummyt d  WITH seq = ocnt),
    (dummyt d2  WITH seq = 1)
   SET c.catalog_cd = request->orderables[d.seq].code_value, c.event_set_name = request->orderables[d
    .seq].event_sets[d2.seq].event_set_name, c.sequence = request->orderables[d.seq].event_sets[d2
    .seq].sequence,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id, c.updt_task =
    reqinfo->updt_task,
    c.updt_cnt = 0, c.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE maxrec(d2,size(request->orderables[d.seq].event_sets,5)))
    JOIN (d2)
    JOIN (c)
   WITH nocounter
  ;end insert
 ENDIF
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
