CREATE PROGRAM bed_ens_ordsent_sequence:dba
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
 SET cnt = size(request->sentences,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM ord_cat_sent_r o,
   (dummyt d  WITH seq = value(cnt))
  SET o.display_seq = request->sentences[d.seq].sequence, o.updt_id = reqinfo->updt_id, o.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt
   + 1)
  PLAN (d)
   JOIN (o
   WHERE (o.order_sentence_id=request->sentences[d.seq].id))
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
