CREATE PROGRAM cpm_get_request_processing:dba
 RECORD reply(
   1 parent_list[*]
     2 request_number = i4
     2 cpmsend_ind = i4
     2 process_script = vc
     2 outbound_list[*]
       3 sequence = i4
       3 request_number = i4
       3 format_script = vc
       3 service = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->parent_list,10)
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET reqcnt = 0
 SET seqcnt = 0
 SELECT INTO "nl:"
  r.request_number, r.cpmsend_ind, r.process_script,
  p.sequence, p.target_request_number, p.format_script,
  p.service
  FROM request r,
   request_processing p
  WHERE r.request_number=p.request_number
   AND r.cpmsend_ind > 0
  ORDER BY r.request_number, p.sequence
  HEAD REPORT
   reqcnt = 0, seqcnt = 0
  HEAD r.request_number
   IF (reqcnt > 0)
    stat = alterlist(reply->parent_list[reqcnt].outbound_list,seqcnt)
   ENDIF
   seqcnt = 0, reqcnt = (reqcnt+ 1), stat = alterlist(reply->parent_list[reqcnt].outbound_list,10)
   IF (mod(reqcnt,10)=0)
    stat = alterlist(reply->parent_list,(reqcnt+ 10))
   ENDIF
   reply->parent_list[reqcnt].request_number = r.request_number, reply->parent_list[reqcnt].
   cpmsend_ind = r.cpmsend_ind, reply->parent_list[reqcnt].process_script = r.process_script
  DETAIL
   seqcnt = (seqcnt+ 1)
   IF (mod(seqcnt,10)=0)
    stat = alterlist(reply->parent_list[reqcnt].outbound_list,(seqcnt+ 10))
   ENDIF
   reply->parent_list[reqcnt].outbound_list[seqcnt].sequence = p.sequence, reply->parent_list[reqcnt]
   .outbound_list[seqcnt].request_number = p.target_request_number, reply->parent_list[reqcnt].
   outbound_list[seqcnt].format_script = p.format_script,
   reply->parent_list[reqcnt].outbound_list[seqcnt].service = p.service
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->parent_list,reqcnt)
 IF (reqcnt > 0)
  SET stat = alterlist(reply->parent_list[reqcnt].outbound_list,seqcnt)
 ENDIF
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  SET failed = "T"
 ELSE
  SET failed = "F"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request_processing"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(concat("CPM_GET_REQUEST_PROCESSING status: ",reply->status_data.status))
END GO
