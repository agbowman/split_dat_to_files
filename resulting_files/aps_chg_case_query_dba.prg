CREATE PROGRAM aps_chg_case_query:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "T"
 SELECT INTO "nl:"
  acq.case_query_id
  FROM ap_case_query acq
  WHERE (request->case_query_id=acq.case_query_id)
  WITH forupdate(acq)
 ;end select
 IF (curqual != 0)
  IF ((request->status_flag=2))
   UPDATE  FROM ap_case_query acq
    SET acq.status_flag = request->status_flag, acq.query_start_dt_tm = cnvtdatetime(curdate,curtime3
      ), acq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     acq.updt_id = reqinfo->updt_id, acq.updt_cnt = (acq.updt_cnt+ 1), acq.updt_task = reqinfo->
     updt_task,
     acq.updt_applctx = reqinfo->updt_applctx
    WHERE (acq.case_query_id=request->case_query_id)
    WITH nocounter
   ;end update
   IF (curqual != 0)
    SET failed = "F"
   ENDIF
  ELSE
   UPDATE  FROM ap_case_query acq
    SET acq.status_flag = request->status_flag, acq.updt_dt_tm = cnvtdatetime(curdate,curtime3), acq
     .updt_id = reqinfo->updt_id,
     acq.updt_cnt = (acq.updt_cnt+ 1), acq.updt_task = reqinfo->updt_task, acq.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (acq.case_query_id=request->case_query_id)
    WITH nocounter
   ;end update
   IF (curqual != 0)
    SET failed = "F"
   ENDIF
  ENDIF
 ENDIF
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "Lock or Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_QUERY"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
