CREATE PROGRAM dcp_add_catalog_event_sets:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 FOR (x = 1 TO request->event_set_cnt)
  INSERT  FROM catalog_event_sets ces
   SET ces.catalog_cd = request->catalog_cd, ces.event_set_name = request->qual[x].event_set_name,
    ces.sequence = x,
    ces.updt_dt_tm = cnvtdatetime(curdate,curtime3), ces.updt_id = reqinfo->updt_id, ces.updt_task =
    reqinfo->updt_task,
    ces.updt_applctx = reqinfo->updt_applctx, ces.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   ROLLBACK
  ELSE
   SET reply->status_data.status = "S"
   COMMIT
  ENDIF
 ENDFOR
END GO
