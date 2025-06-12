CREATE PROGRAM ccl_get_audit_summary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD audit_request(
   1 program_name = vc
   1 source_app = vc
   1 request_source = f8
   1 status = vc
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
 )
 SET json = request->blob_in
 SET jrec_ret = cnvtjsontorec(json,0,0,1)
 RECORD audit_reply(
   1 total_count = f8
   1 total_sec = f8
   1 avg_seconds = f8
   1 last_executed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (jrec_ret=0)
  SET audit_reply->status_data.status = "F"
  SET audit_reply->status_data.subeventstatus[1].operationname = "cnvtjsontorec"
  SET audit_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET audit_reply->status_data.subeventstatus[1].targetobjectname = "audit_request"
  SET audit_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Convert JSON to REC failed with status 0"
  GO TO exitscript
 ENDIF
 DECLARE req_num_parser = vc
 IF ((audit_request->request_source=3050003))
  SET req_num_parser = "(c.request_nbr = 3050002 and c.object_type = 'QUERY')"
 ELSEIF ((audit_request->request_source=0))
  SET req_num_parser = "(1 = 1)"
 ELSE
  SET req_num_parser = concat("(c.request_nbr = ",cnvtstring(audit_request->request_source),
   " and c.object_type != 'QUERY')")
 ENDIF
 SELECT INTO "NL:"
  c.object_name, c.status, elapsed_seconds = datetimediff(c.end_dt_tm,c.begin_dt_tm,5),
  c.begin_dt_tm, c.end_dt_tm, c.application_nbr,
  c.updt_dt_tm, c.updt_id
  FROM ccl_report_audit c,
   person p,
   dprotect dp,
   application a
  PLAN (c
   WHERE c.updt_dt_tm BETWEEN cnvtdatetime(audit_request->begin_dt_tm) AND cnvtdatetime(audit_request
    ->end_dt_tm)
    AND cnvtupper(c.status)=patstring(cnvtupper(audit_request->status))
    AND cnvtupper(c.object_name)=patstring(cnvtupper(audit_request->program_name))
    AND parser(req_num_parser))
   JOIN (p
   WHERE p.person_id=c.updt_id)
   JOIN (a
   WHERE c.application_nbr=a.application_number)
   JOIN (dp
   WHERE "P"=dp.object
    AND c.object_name=dp.object_name)
  ORDER BY c.updt_dt_tm
  FOOT REPORT
   audit_reply->last_executed = c.begin_dt_tm, audit_reply->total_count = count(c.object_name),
   audit_reply->total_sec = sum(elapsed_seconds),
   audit_reply->avg_seconds = (sum(elapsed_seconds)/ count(c.object_name))
  WITH nocounter
 ;end select
 DECLARE err_msg = vc
 IF (error(err_msg,0) > 0)
  SET audit_reply->status_data.status = "F"
  SET audit_reply->status_data.subeventstatus[1].operationname = "select statement"
  SET audit_reply->status_data.subeventstatus[1].operationstatus = "F"
  SET audit_reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  GO TO exitscript
 ENDIF
#exitscript
 SET _memory_reply_string = cnvtrectojson(audit_reply,2,1)
END GO
