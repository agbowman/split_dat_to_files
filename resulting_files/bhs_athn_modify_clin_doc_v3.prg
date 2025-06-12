CREATE PROGRAM bhs_athn_modify_clin_doc_v3
 FREE RECORD req969531
 RECORD req969531(
   1 ensure_type = i2
   1 ppr_cd = f8
   1 reference_number = vc
   1 event_id = f8
   1 author_id = f8
   1 user_id = f8
   1 action_dt_tm = dq8
   1 action_tz = i4
   1 service_dt_tm = dq8
   1 service_tz = i4
   1 version = i4
   1 patient_id = f8
   1 encntr_id = f8
   1 title = vc
   1 signers[*]
     2 provider_id = f8
     2 free_text_provider = vc
     2 pool_id = f8
   1 reviewers[*]
     2 provider_id = f8
     2 free_text_provider = vc
     2 pool_id = f8
   1 document_sections[*]
     2 event_id = f8
     2 content = gvc
     2 format_cd = f8
     2 title = vc
     2 reference_number = vc
 )
 FREE RECORD rep969531
 RECORD rep969531(
   1 document_sections[*]
     2 event_id = f8
     2 reference_number = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 status_cd = f8
   1 clinsig_update_dt_tm = dq8
   1 version = i4
 )
 FREE RECORD oreply
 RECORD oreply(
   1 status = vc
   1 rb_list[*]
     2 event_id = f8
     2 parent_event_id = f8
 )
 DECLARE t_line = vc
 DECLARE t_file = vc
 DECLARE t_blob = vc
 DECLARE action_dt_tm = dq8
 DECLARE col_seq = i4
 DECLARE child_event_id = f8
 DECLARE performed_prsnl_id = f8
 DECLARE c_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",24,"C"))
 DECLARE inprogress_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"INPROGRESS"))
 SET date_line = substring(1,10, $7)
 SET time_line = substring(12,8, $7)
 SET action_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",0)
 IF (( $10=1))
  SET t_blob =  $12
 ELSE
  IF (( $9 !=  $10))
   EXECUTE bhs_athn_add_doc_segment "mine",  $11,  $9,
    $12, "", ""
   SET oreply->status = "S"
   GO TO exit_script
  ENDIF
  IF (( $9= $10))
   SELECT INTO "nl:"
    FROM bhs_athn_doc_segment ds
    PLAN (ds
     WHERE (ds.uuid= $11))
    ORDER BY ds.segment_seq
    HEAD ds.segment_seq
     t_blob = concat(t_blob,trim(ds.segment_text,3))
    WITH nocounter, separator = " ", format,
     time = 20
   ;end select
   SET t_blob = concat(t_blob,trim( $12,3))
  ENDIF
 ENDIF
 FREE RECORD i_request
 RECORD i_request(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD i_reply
 RECORD i_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET i_request->prsnl_id =  $5
 CALL echorecord(i_request)
 EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
 IF ((i_reply->status_data.status != "S"))
  CALL echo("IMPERSONATE USER FAILED...EXITING!")
  GO TO exit_script
 ENDIF
 FREE RECORD req_decode_str
 RECORD req_decode_str(
   1 blob = vc
   1 url_source_ind = i2
 ) WITH protect
 FREE RECORD rep_decode_str
 RECORD rep_decode_str(
   1 blob = vc
 ) WITH protect
 IF (textlen(trim(t_blob,3)) > 0)
  SET req_decode_str->blob = t_blob
  SET req_decode_str->url_source_ind = 1
  EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST","REQ_DECODE_STR"), replace("REPLY",
   "REP_DECODE_STR")
  SET t_blob = rep_decode_str->blob
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE (epr.encntr_id= $3)
    AND (epr.prsnl_person_id= $5)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= sysdate
    AND epr.end_effective_dt_tm >= sysdate)
  DETAIL
   req969531->ppr_cd = epr.encntr_prsnl_r_cd
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.parent_event_id= $4)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.valid_from_dt_tm < sysdate)
  ORDER BY ce.collating_seq, ce.updt_cnt
  HEAD ce.event_id
   IF (c_cd=ce.event_reltn_cd
    AND inprogress_cd=ce.result_status_cd)
    child_event_id = ce.event_id
   ENDIF
   performed_prsnl_id = ce.performed_prsnl_id
  FOOT REPORT
   col_seq = (ce.updt_cnt+ 1)
  WITH nocounter, time = 30
 ;end select
 SET req969531->ensure_type = evaluate( $14,1,1,2)
 SET req969531->patient_id =  $2
 SET req969531->encntr_id =  $3
 SET req969531->event_id =  $4
 SET req969531->author_id = performed_prsnl_id
 SET req969531->user_id =  $5
 SET req969531->title = trim(replace(replace(replace(replace(replace(replace(replace(replace(replace(
            $6,"&amp;","&",0),"&lt;","<",0),"&gt;",">",0),"&apos;","'",0),"&quot;",'"',0),"&rsquo;",
      "'",0),"&lsquo;","'",0),"&hellip;","",0),"<br>","",0),3)
 SET req969531->version = col_seq
 SET req969531->action_dt_tm = action_dt_tm
 SET req969531->action_tz = 126
 SET req969531->service_dt_tm = action_dt_tm
 SET req969531->service_tz = 126
 SET stat = alterlist(req969531->document_sections,1)
 SET req969531->document_sections[1].event_id = child_event_id
 SET req969531->document_sections[1].content = t_blob
 SET req969531->document_sections[1].format_cd = uar_get_code_by("MEANING",23, $13)
 SET req969531->document_sections[1].title = trim(replace(replace(replace(replace(replace(replace(
        replace(replace(replace( $6,"&amp;","&",0),"&lt;","<",0),"&gt;",">",0),"&apos;","'",0),
       "&quot;",'"',0),"&rsquo;","'",0),"&lsquo;","'",0),"&hellip;","",0),"<br>","",0),3)
 SET stat = tdbexecute(600005,3202004,969531,"REC",req969531,
  "REC",rep969531)
 CALL echorecord(rep969531)
 IF ((rep969531->status_data.status="S"))
  SET oreply->status = "S"
  SET stat = alterlist(oreply->rb_list,1)
  SET oreply->rb_list[1].parent_event_id =  $4
  SET oreply->rb_list[1].event_id = rep969531->document_sections[1].event_id
 ELSE
  SET oreply->status = "F"
 ENDIF
#exit_script
 IF (( $9 !=  $10))
  SET oreply->status = concat("Successfully Sent Part ",trim(cnvtstring( $9))," of ",trim(cnvtstring(
      $10)))
 ENDIF
 SET _memory_reply_string = cnvtrectojson(oreply)
END GO
