CREATE PROGRAM cr_del_report_watermarks:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE currentdatetime = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 SET watermark_cnt = size(request->watermarks,5)
 SET qual_cnt = 0
 IF (watermark_cnt > 0)
  UPDATE  FROM cr_report_watermark crw,
    (dummyt d  WITH seq = value(watermark_cnt))
   SET crw.active_ind = 0, crw.updt_dt_tm = cnvtdatetime(currentdatetime), crw.updt_id = reqinfo->
    updt_id,
    crw.updt_task = reqinfo->updt_task, crw.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (crw
    WHERE (crw.report_watermark_id=request->watermarks[d.seq].id))
   WITH nocounter
  ;end update
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET reqinfo->commit_ind = 1
END GO
