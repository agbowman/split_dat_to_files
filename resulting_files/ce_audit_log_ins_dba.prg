CREATE PROGRAM ce_audit_log_ins:dba
 SUBROUTINE checkerrors(operation)
   DECLARE errormsg = c255 WITH noconstant("")
   DECLARE errorcode = i4 WITH noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    SET reply->status_data.subeventstatus[1].operationname = substring(1,25,trim(operation))
    SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 num_inserted = i4
   1 rep_list[*]
     2 event_id = f8
     2 ce_audit_log_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD audit_log
 RECORD audit_log(
   1 qual[*]
     2 ce_audit_log_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE pos = i4
 DECLARE lastpos = i4
 DECLARE num = i4
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE request_size = i4 WITH constant(size(request->log_list,5))
 DECLARE nstart = i2 WITH noconstant(1)
 DECLARE nsize = i2 WITH constant(40)
 DECLARE operation_status_processing = f8 WITH constant(uar_get_code_by("MEANING",4002019,
   "PROCESSING"))
 IF (operation_status_processing <= 0.0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(audit_log->qual,request_size)
 SET ntotal = (ceil((cnvtreal(request_size)/ nsize)) * nsize)
 SET stat = alterlist(request->log_list,ntotal)
 FOR (idx = (request_size+ 1) TO ntotal)
   SET request->log_list[idx].event_id = request->log_list[request_size].event_id
 ENDFOR
 FOR (x = 1 TO request_size)
   SELECT INTO "nl:"
    y = seq(ocf_seq,nextval)
    FROM dual
    DETAIL
     audit_log->qual[x].ce_audit_log_id = y
    WITH nocounter
   ;end select
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  ce.person_id
  FROM clinical_event ce,
   (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (ce
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.event_id,request->log_list[idx].event_id)
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00"))
  HEAD REPORT
   lastpos = 1
  HEAD ce.event_id
   pos = locateval(num,lastpos,request_size,ce.event_id,request->log_list[num].event_id)
   WHILE (pos)
     IF ((request->log_list[pos].person_id <= 0.0))
      request->log_list[pos].person_id = ce.person_id
     ENDIF
     lastpos = (pos+ 1)
     IF (pos <= request_size)
      pos = locateval(num,lastpos,request_size,ce.event_id,request->log_list[num].event_id)
     ELSE
      pos = 0
     ENDIF
   ENDWHILE
   lastpos = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(request->log_list,request_size)
 SET stat = alterlist(reply->rep_list,request_size)
 INSERT  FROM ce_audit_log t,
   (dummyt d  WITH seq = value(request_size))
  SET t.ce_audit_log_id = audit_log->qual[d.seq].ce_audit_log_id, t.event_id = request->log_list[d
   .seq].event_id, t.person_id = request->log_list[d.seq].person_id,
   t.operation_type_cd = request->log_list[d.seq].operation_type_cd, t.operation_dt_tm = cnvtdatetime
   (request->log_list[d.seq].operation_dt_tm), t.operation_prsnl_id = request->log_list[d.seq].
   operation_prsnl_id,
   t.error_msg_txt = request->log_list[d.seq].error_msg_txt, t.operation_status_cd =
   operation_status_processing, t.updt_dt_tm = cnvtdatetime(sysdate),
   t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
   updt_applctx,
   reply->rep_list[d.seq].ce_audit_log_id = audit_log->qual[d.seq].ce_audit_log_id, reply->rep_list[d
   .seq].event_id = request->log_list[d.seq].event_id
  PLAN (d)
   JOIN (t)
  WITH rdbarrayinsert = 100, counter
 ;end insert
 SET reply->num_inserted = curqual
 CALL checkerrors("CE_AUDIT_LOG insert")
 IF (value(reply->num_inserted)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 COMMIT
END GO
