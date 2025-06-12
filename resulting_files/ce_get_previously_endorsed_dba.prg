CREATE PROGRAM ce_get_previously_endorsed:dba
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE req_idx = i4 WITH protect, noconstant(0)
 DECLARE req_size = i4 WITH protect, noconstant(0)
 DECLARE endorse = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ENDORSE"))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i4 WITH protect, noconstant(0)
 SET req_size = size(request->event_id_set,5)
 IF (req_size=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ce_event_prsnl cep
  WHERE expand(req_idx,1,req_size,cep.event_id,request->event_id_set[req_idx].event_id)
   AND cep.action_type_cd=endorse
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->result_set,(cnt+ 9))
   ENDIF
   reply->result_set[cnt].event_id = cep.event_id
  FOOT REPORT
   stat = alterlist(reply->result_set,cnt)
  WITH nocounter, expand = 1
 ;end select
 DECLARE failed = i4 WITH protect, noconstant(0)
 DECLARE size = i4 WITH protect, noconstant(0)
 SET error_code = error(error_msg,0)
 WHILE (error_code != 0)
   SET size += 1
   SET stat = alterlist(reply->status_data.subeventstatus,size)
   SET reply->status_data.subeventstatus[size].operationname = "SELECT"
   SET reply->status_data.subeventstatus[size].operationstatus = "F"
   SET reply->status_data.subeventstatus[size].targetobjectname = "CE_EVENT_PRSNL"
   SET reply->status_data.subeventstatus[size].targetobjectvalue = error_msg
   SET failed = 1
   SET error_code = error(error_msg,0)
 ENDWHILE
 IF (failed=1)
  GO TO exit_script
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CE_EVENT_PRSNL"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No results were retrieved."
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
