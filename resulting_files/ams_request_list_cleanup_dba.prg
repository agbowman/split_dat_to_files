CREATE PROGRAM ams_request_list_cleanup:dba
 PROMPT
  "Enter the Request list name" = ""
  WITH req
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD req_list
 RECORD req_list(
   1 qual[*]
     2 request_list_id = f8
 )
 SELECT INTO "nl:"
  FROM sch_object s,
   sch_entry se
  WHERE (s.mnemonic_key= $REQ)
   AND s.object_type_meaning="QUEUE"
   AND s.active_ind=1
   AND s.sch_object_id=se.queue_id
   AND se.entry_state_meaning="PENDING"
   AND se.earliest_dt_tm < cnvtdatetime((curdate - 60),curtime3)
   AND se.active_ind=1
  ORDER BY se.sch_entry_id
  HEAD REPORT
   cnts = 0, stat = alterlist(req_list->qual,100)
  HEAD se.sch_entry_id
   cnts = (cnts+ 1)
   IF (mod(cnts,10)=1
    AND cnts > 100)
    stat = alterlist(req_list->qual,(cnts+ 9))
   ENDIF
   req_list->qual[cnts].request_list_id = se.sch_entry_id
  FOOT REPORT
   stat = alterlist(req_list->qual,cnts)
  WITH nocounter
 ;end select
 SET request_cnt = value(size(req_list->qual,5))
 IF (request_cnt > 0)
  UPDATE  FROM sch_entry se,
    (dummyt d  WITH seq = value(request_cnt))
   SET se.version_dt_tm = cnvtdatetime(curdate,curtime3), se.updt_id = reqinfo->updt_id, se.updt_cnt
     = (se.updt_cnt+ 1),
    se.updt_task = reqinfo->updt_task, se.updt_dt_tm = cnvtdatetime(curdate,curtime3), se
    .updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (se
    WHERE (se.sch_entry_id=req_list->qual[d.seq].request_list_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
