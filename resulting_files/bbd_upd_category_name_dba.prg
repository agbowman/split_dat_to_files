CREATE PROGRAM bbd_upd_category_name:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE (c.code_value=request->code_value)
  WITH counter, forupdate(c)
 ;end select
 UPDATE  FROM code_value c
  SET c.display = request->display, c.display_key = trim(cnvtupper(cnvtalphanum(request->display))),
   c.active_ind = request->active_ind,
   c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->
   updt_id,
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
  WHERE c.code_set=16069
   AND (c.code_value=request->code_value)
  WITH nocounter
 ;end update
 IF (curqual=1)
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
END GO
