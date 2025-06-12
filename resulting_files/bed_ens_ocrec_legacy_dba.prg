CREATE PROGRAM bed_ens_ocrec_legacy:dba
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
 UPDATE  FROM br_oc_work b,
   (dummyt d  WITH seq = value(cnt))
  SET b.match_orderable_cd = request->orderables[d.seq].match_code_value, b.match_ind = request->
   orderables[d.seq].match_type_flag, b.match_value = request->orderables[d.seq].match_value,
   b.status_ind =
   IF ((request->orderables[d.seq].match_type_flag=0)) 2
   ELSE 1
   ENDIF
   , b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt
   + 1)
  PLAN (d)
   JOIN (b
   WHERE (b.oc_id=request->orderables[d.seq].legacy_id))
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
