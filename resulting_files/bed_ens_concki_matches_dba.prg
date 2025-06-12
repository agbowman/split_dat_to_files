CREATE PROGRAM bed_ens_concki_matches:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 SET cnt = size(request->orderables,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM order_catalog o,
   (dummyt d  WITH seq = value(cnt))
  SET o.concept_cki = request->orderables[d.seq].concept_cki, o.updt_id = reqinfo->updt_id, o
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt
   + 1)
  PLAN (d)
   JOIN (o
   WHERE (o.catalog_cd=request->orderables[d.seq].code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(cnt))
  SET c.concept_cki = request->orderables[d.seq].concept_cki, c.updt_id = reqinfo->updt_id, c
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt
   + 1)
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->orderables[d.seq].code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
