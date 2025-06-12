CREATE PROGRAM bsc_upd_discipline_event_sets:dba
 SET modify = predeclare
 RECORD reply(
   1 discipline_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE disciplinecnt = i2 WITH protect, noconstant(0)
 DECLARE deletequal = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 IF ((request->discipline_cd <= 0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "Delete error - Invalid Discipline"
  GO TO exit_script
 ENDIF
 DELETE  FROM dscpln_event_r der
  WHERE (der.discipline_cd=request->discipline_cd)
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,1)
 SET deletequal = curqual
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat("Delete error - ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "No records deleted"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
 ENDIF
 DECLARE eventcnt = i4 WITH protect, noconstant(0)
 FOR (eventcnt = 1 TO size(request->qual,5))
   INSERT  FROM dscpln_event_r der
    SET der.dscpln_event_id = seq(reference_seq,nextval), der.discipline_cd = request->discipline_cd,
     der.event_set_cd = request->qual[eventcnt].event_set_cd,
     der.updt_id = reqinfo->updt_id, der.updt_task = reqinfo->updt_task, der.updt_applctx = reqinfo->
     updt_applctx,
     der.updt_cnt = 0, der.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
 ENDFOR
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat("ID In - ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0
  AND deletequal=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "Zero qual in Insert"
 ELSE
  SET reply->discipline_cd = request->discipline_cd
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 SET last_mod = "002"
 SET mod_date = "10/25/2011"
 SET modify = nopredeclare
END GO
