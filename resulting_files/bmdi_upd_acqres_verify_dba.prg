CREATE PROGRAM bmdi_upd_acqres_verify:dba
 RECORD reply(
   1 result_list[*]
     2 result_id = f8
     2 event_id = f8
     2 statusinsert = i2
     2 ierrnum = i2
     2 serrmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE n = i4 WITH noconstant(0)
 DECLARE req_size = i4 WITH noconstant(size(request->result_list,5))
 CALL echo(build("req_size = ",req_size))
 SET stat = alterlist(reply->result_list,req_size)
 DECLARE totqual = i4 WITH noconstant(0)
 UPDATE  FROM bmdi_acquired_results bar,
   (dummyt d  WITH seq = value(req_size))
  SET bar.verified_ind = 1, bar.verified_dt_tm = cnvtdatetime(request->verified_dt_tm), bar.event_id
    = request->result_list[d.seq].event_id,
   bar.updt_dt_tm = cnvtdatetime(curdate,curtime3), bar.updt_cnt = (bar.updt_cnt+ 1), bar.updt_id =
   reqinfo->updt_id,
   bar.updt_task = reqinfo->updt_task, bar.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (bar
   WHERE (bar.result_id=request->result_list[d.seq].result_id))
  WITH status(reply->result_list[d.seq].statusinsert,reply->result_list[d.seq].ierrnum,reply->
   result_list[d.seq].serrmsg)
 ;end update
 CALL echo(build("curqual_dummyt = ",curqual))
 IF (curqual=req_size)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->result_list,(req_size - curqual))
 ENDIF
 IF (curqual < req_size)
  SET stat = alterlist(reply->result_list,(req_size - curqual))
  DECLARE q = i4 WITH noconstant(0)
  DECLARE n = i4 WITH noconstant(0)
  FOR (n = 1 TO req_size)
    IF ((reply->result_list[n].statusinsert=0))
     SET q = (q+ 1)
     SET reply->result_list[q].result_id = request->result_list[n].result_id
     SET reply->result_list[q].event_id = request->result_list[n].event_id
     SET reply->result_list[q].statusinsert = request->result_list[n].statusinsert
     SET reply->result_list[q].ierrnum = request->result_list[n].ierrnum
     SET reply->result_list[q].serrmsg = request->result_list[n].serrmsg
    ENDIF
  ENDFOR
  IF (curqual >= 1)
   SET reply->status_data.status = "S"
   SET ierrcode = error(serrmsg,1)
   SET failure = "P"
   GO TO get_data_partialsuccess
  ELSEIF (curqual=0)
   SET reply->status_data.status = "F"
   SET ierrcode = error(serrmsg,1)
   SET failure = "T"
   GO TO get_data_failure
  ENDIF
 ENDIF
#get_data_partialsuccess
 IF (failure="P")
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "P"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_upd_acqres_verify"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Update Partial Success!"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[2].operationstatus = "P"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_upd_acqres_verify"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
#get_data_failure
 IF (failure="T")
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_upd_acqres_verify"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Update failed!"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_upd_acqres_verify"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
 IF (failure="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  SET stat = alterlist(reply->result_list,0)
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 CALL echorecord(reply)
END GO
