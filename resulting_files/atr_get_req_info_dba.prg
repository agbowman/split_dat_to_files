CREATE PROGRAM atr_get_req_info:dba
 RECORD reply(
   1 request_number = i4
   1 description = vc
   1 request_module = c30
   1 requestclass = i4
   1 discern_interest_level = i4
   1 active_ind = i2
   1 active_dt_tm = dq8
   1 inactive_dt_tm = dq8
   1 text = vc
   1 write_to_que_ind = i2
   1 cpm_send_ind = i2
   1 prolog_script = c30
   1 epilog_script = c30
   1 cachetime = i4
   1 cachegrace = i4
   1 cachestale = i4
   1 cachetrim = vc
   1 updt_cnt = i4
   1 processclass = i4
   1 binding_override = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  r.*, nullind_r_active_dt_tm = nullind(r.active_dt_tm), nullind_r_inactive_dt_tm = nullind(r
   .inactive_dt_tm)
  FROM request r
  WHERE (r.request_number=request->request_number)
  DETAIL
   reply->request_number = r.request_number, reply->description = r.description, reply->
   request_module = r.request_name,
   reply->requestclass = r.requestclass, reply->text = r.text, reply->write_to_que_ind = r
   .write_to_que_ind,
   reply->cpm_send_ind = 0, reply->prolog_script = r.prolog_script, reply->epilog_script = r
   .epilog_script,
   reply->processclass = r.processclass, reply->active_ind = r.active_ind
   IF (nullind_r_active_dt_tm=0)
    reply->active_dt_tm = r.active_dt_tm
   ENDIF
   IF (nullind_r_inactive_dt_tm=0)
    reply->inactive_dt_tm = r.inactive_dt_tm
   ENDIF
   reply->cachetime = r.cachetime, reply->cachegrace = r.cachegrace, reply->cachestale = r.cachestale,
   reply->cachetrim = r.cachetrim, reply->updt_cnt = r.updt_cnt, reply->binding_override = r
   .binding_override
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
