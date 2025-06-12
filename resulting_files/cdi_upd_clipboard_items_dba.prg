CREATE PROGRAM cdi_upd_clipboard_items:dba
 RECORD reply(
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 UPDATE  FROM cdi_clipboard c
  SET c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
  WHERE (c.cdi_clipboard_id=request->cdi_clipboard_id)
   AND (c.updt_cnt=request->updt_cnt)
  WITH nocounter
 ;end update
 IF (curqual=1)
  SET reply->updt_cnt = (request->updt_cnt+ 1)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
