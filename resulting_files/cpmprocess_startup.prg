CREATE PROGRAM cpmprocess_startup
 RECORD reply(
   1 parent_list[*]
     2 request_number = i4
     2 prolog_script = vc
     2 epilog_script = vc
     2 write_to_que_ind = i2
     2 outbound_list[*]
       3 destination_step_id = i4
       3 request_number = i4
       3 format_script = vc
       3 service_name = vc
       3 forward_override_ind = i2
       3 reprocess_reply_ind = i2
     2 process_class = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET reqcnt = 0
 SET seqcnt = 0
 SELECT INTO "nl:"
  r.request_number, r.prolog_script, r.epilog_script,
  r.write_to_que_ind, p.target_request_number, p.format_script,
  p.service, p.destination_step_id, p.forward_override_ind,
  p.reprocess_reply_ind
  FROM request r,
   request_processing p
  WHERE r.request_number=p.request_number
   AND p.active_ind=1
   AND r.active_ind=1
  ORDER BY r.request_number, p.sequence
  HEAD REPORT
   reqcnt = 0, seqcnt = 0
  HEAD r.request_number
   reqcnt = (reqcnt+ 1), seqcnt = 0, stat = alterlist(reply->parent_list,reqcnt),
   reply->parent_list[reqcnt].request_number = r.request_number, reply->parent_list[reqcnt].
   prolog_script = r.prolog_script, reply->parent_list[reqcnt].epilog_script = r.epilog_script,
   reply->parent_list[reqcnt].write_to_que_ind = r.write_to_que_ind, reply->parent_list[reqcnt].
   process_class = r.processclass
  DETAIL
   seqcnt = (seqcnt+ 1), stat = alterlist(reply->parent_list[reqcnt].outbound_list,seqcnt), reply->
   parent_list[reqcnt].outbound_list[seqcnt].request_number = p.target_request_number,
   reply->parent_list[reqcnt].outbound_list[seqcnt].format_script = p.format_script, reply->
   parent_list[reqcnt].outbound_list[seqcnt].destination_step_id = p.destination_step_id, reply->
   parent_list[reqcnt].outbound_list[seqcnt].service_name = p.service,
   reply->parent_list[reqcnt].outbound_list[seqcnt].forward_override_ind = p.forward_override_ind,
   reply->parent_list[reqcnt].outbound_list[seqcnt].reprocess_reply_ind = p.reprocess_reply_ind
  FOOT  r.request_number
   IF (seqcnt=0)
    reqcnt = (reqcnt - 1)
   ENDIF
  WITH nocounter, check
 ;end select
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  CALL echo(errcode)
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
 CALL echo(build("Number of Requests Loaded: ",cnvtstring(reqcnt)))
 FOR (x = 1 TO reqcnt)
   CALL echo(build("Request In: ",reply->parent_list[x].request_number))
   CALL echo(build("Journal Ind:",reply->parent_list[x].write_to_que_ind))
   CALL echo(build("Process Class:",reply->parent_list[x].process_class))
   SET y = size(reply->parent_list[x].outbound_list,5)
   FOR (sub = 1 TO y)
     CALL echo(build("Format request: ",reply->parent_list[x].outbound_list[sub].request_number,
       " Destination Step id: ",reply->parent_list[x].outbound_list[sub].destination_step_id,
       " Format Script: ",
       reply->parent_list[x].outbound_list[sub].format_script," Process Reply: ",reply->parent_list[x
       ].outbound_list[sub].reprocess_reply_ind))
   ENDFOR
   CALL echo(" ")
 ENDFOR
END GO
