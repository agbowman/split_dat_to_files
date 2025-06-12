CREATE PROGRAM cpm_add_request_event:dba
 SET program_modification = "Feb 09, 2000"
 CALL echo(program_modification)
 SET version_number = "000"
 CALL echo(version_number)
 DECLARE num_requests = i4
 SET num_requests = 0
 SET num_requests = value(size(request_event_r->request_list,5))
 CALL echo(build("Requests:",num_requests))
 INSERT  FROM request_event re,
   (dummyt d  WITH seq = value(num_requests))
  SET re.request_number = request_event_r->request_list[d.seq].request_number, re.event_type =
   request_event_r->request_list[d.seq].event_type, re.event_data = request_event_r->request_list[d
   .seq].event_data,
   re.event_dt_tm = cnvtdatetime(curdate,curtime3), re.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   re.updt_cnt = 0,
   re.updt_id = reqinfo->updt_id, re.updt_applctx = reqinfo->updt_applctx, re.updt_task = reqinfo->
   updt_task
  PLAN (d
   WHERE d.seq >= 0)
   JOIN (re)
  WITH nocounter
 ;end insert
 COMMIT
 IF (curqual=num_requests
  AND num_requests > 0)
  SET reply->status_data.status = "S"
  CALL echo(build("Rows Inserted:",curqual))
 ELSE
  SET reply->status_data.status = "F"
  CALL echo("Insert Failed")
 ENDIF
END GO
