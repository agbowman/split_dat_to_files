CREATE PROGRAM ccl_upd_rpt_audit:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE _statusflag = c1
 DECLARE _errmsg = c132
 DECLARE prsnl_id = f8
 SET reply->status_data.status = "F"
 SET _statusflag = "F"
 SET _errmsg = fillstring(132," ")
 IF ((request->person_id > 0))
  SET prsnl_id = request->person_id
 ELSE
  SET prsnl_id = reqinfo->updt_id
 ENDIF
 UPDATE  FROM ccl_report_audit c
  SET c.object_type = request->report_type, c.records_cnt = request->records_cnt, c.status = request
   ->status,
   c.active_ind = 0, c.end_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   c.updt_id = prsnl_id, c.updt_cnt = 1
  WHERE (c.report_event_id=request->report_audit_id)
  WITH nocounter
 ;end update
 IF (curqual=1)
  SET _statusflag = "S"
 ELSE
  SET _errcode = error(_errmsg,1)
 ENDIF
#exit_script
 SET _commit_ind = reqinfo->commit_ind
 IF (_statusflag="S")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_upd_rpt_audit"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = _errmsg
 ENDIF
 SET reqinfo->commit_ind = _commit_ind
END GO
