CREATE PROGRAM bhs_athn_add_wkf_text_v4
 FREE RECORD req969575
 RECORD req969575(
   1 patient_id = f8
   1 encntr_id = f8
   1 prsnl_id = f8
 )
 FREE RECORD rep969575
 RECORD rep969575(
   1 workflow_id = f8
   1 start_dt_tm = dq8
   1 service_dt_tm = dq8
   1 service_tz = i4
   1 workflow_components[*]
     2 workflow_component_id = f8
     2 component_concept = vc
     2 component_entity_name = vc
     2 component_entity_id = f8
     2 component_concept_cki = vc
   1 workflow_outputs[*]
     2 workflow_output_id = f8
     2 output_type_cd = f8
     2 output_entity_name = vc
     2 output_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD req969579
 RECORD req969579(
   1 concept = vc
   1 workflow_id = f8
 )
 FREE RECORD rep969579
 RECORD rep969579(
   1 xhtml = gvc
   1 entity_version = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 entity_id = f8
 )
 FREE RECORD req969577
 RECORD req969577(
   1 patient_id = f8
   1 encntr_id = f8
   1 prsnl_id = f8
   1 workflow_id = f8
   1 service_dt_tm = dq8
   1 service_tz = i4
   1 ppr_cd = f8
   1 components[*]
     2 component_concept = vc
     2 content = vc
     2 event_id = f8
     2 version_number = i4
     2 component_concept_cki = vc
     2 content_blob = gvc
     2 content_encoding = vc
 )
 FREE RECORD rep969577
 RECORD rep969577(
   1 components[*]
     2 component_concept = vc
     2 event_id = f8
     2 version_number = i4
     2 component_concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
       3 conceptname = vc
 )
 RECORD e_request(
   1 blob = vc
   1 url_source_ind = i2
 )
 RECORD e_reply(
   1 blob = vc
 )
 RECORD t_request(
   1 param = vc
 )
 RECORD t_reply(
   1 param = vc
 )
 RECORD out_rec(
   1 status = vc
   1 event_id = vc
   1 workflow_id = vc
   1 ce_blob = vc
 )
 DECLARE person_id = f8
 DECLARE ppr_cd = f8
 DECLARE workflow_id = f8
 DECLARE exists_ind = i2
 DECLARE event_id = f8
 DECLARE wkf_version = f8
 DECLARE html_string = vc
 DECLARE guid_string = vc
 DECLARE t_line = vc
 DECLARE t_blob = vc
 DECLARE message_seq = i4 WITH protect, constant( $7)
 DECLARE message_total = i4 WITH protect, constant( $8)
 DECLARE message_uuid = vc WITH protect, constant( $9)
 IF (message_total=1)
  SET t_blob =  $6
 ELSEIF (message_seq=message_total)
  SELECT INTO "nl:"
   FROM bhs_athn_doc_segment ds
   PLAN (ds
    WHERE ds.uuid=message_uuid)
   ORDER BY ds.segment_seq
   HEAD ds.segment_seq
    t_blob = concat(t_blob,trim(ds.segment_text,3))
   WITH nocounter, separator = " ", format,
    time = 10
  ;end select
  SET t_blob = concat(t_blob, $6)
 ELSE
  EXECUTE bhs_athn_add_doc_segment "mine", message_uuid, message_seq,
   $6, "", ""
  GO TO exit_script
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
 SET i_request->prsnl_id =  $3
 CALL echorecord(i_request)
 EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
 IF ((i_reply->status_data.status != "S"))
  CALL echo("IMPERSONATE USER FAILED...EXITING!")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   person_id = e.person_id
  WITH nocounter, time = 10, maxrec = 1
 ;end select
 SET req969575->patient_id = person_id
 SET req969575->encntr_id =  $2
 SET req969575->prsnl_id =  $3
 SET stat = tdbexecute(600005,3202004,969575,"REC",req969575,
  "REC",rep969575)
 IF ((rep969575->status_data.status="S"))
  SET workflow_id = rep969575->workflow_id
  IF (size(rep969575->workflow_components,5) > 0)
   FOR (i = 0 TO size(rep969575->workflow_components,5))
     IF ((rep969575->workflow_components[i].component_concept= $4))
      SET req969579->workflow_id = rep969575->workflow_id
      SET req969579->concept =  $4
      SET stat = tdbexecute(600005,3202004,969579,"REC",req969579,
       "REC",rep969579)
      IF ((rep969579->status_data.status="S"))
       SET exists_ind = 1
       SET event_id = rep969579->entity_id
       SET wkf_version = rep969579->entity_version
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET e_request->blob = t_blob
 SET e_request->url_source_ind = 1
 EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
 SET t_blob = e_reply->blob
 SET html_string = concat(
  '<!DOCTYPE html PUBLIC "-// W3C//DTD XHTML 1.0 Strict// EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
  '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:dd="DynamicDocumentation"><head><title></title></head><body>',
  '<div class="ddfreetext ddremovable" contenteditable="true" dd:btnfloatingstyle="top-right" ',
  'id="_', $5,
  '">',t_blob,"</div></body></html>")
 SET t_request->param = html_string
 EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST",t_request), replace("REPLY",t_reply)
 SET html_string = replace(replace(replace(replace(replace(replace(t_reply->param,"Â "," "),
      "â€¨","<br>"),"â€¦","&hellip;"),"Â",""),"½","&frac12;"),"â€™","&rsquo;")
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr
  PLAN (epr
   WHERE (epr.encntr_id= $2)
    AND (epr.prsnl_person_id= $3)
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= sysdate
    AND epr.end_effective_dt_tm >= sysdate)
  DETAIL
   ppr_cd = epr.encntr_prsnl_r_cd
  WITH nocounter, time = 30, maxrec = 1
 ;end select
 SET req969577->service_tz = 126
 SET req969577->workflow_id = workflow_id
 SET req969577->patient_id = person_id
 SET req969577->ppr_cd = ppr_cd
 SET req969577->encntr_id =  $2
 SET req969577->prsnl_id =  $3
 SET stat = alterlist(req969577->components,1)
 IF (exists_ind=1)
  SET req969577->components[1].event_id = event_id
  SET req969577->components[1].version_number = cnvtint(wkf_version)
 ENDIF
 SET req969577->components[1].component_concept =  $4
 SET req969577->components[1].content_blob = html_string
 SET req969577->components[1].content_encoding = "UTF-8"
 SET stat = tdbexecute(600005,3202004,969577,"REC",req969577,
  "REC",rep969577)
 SET out_rec->status = rep969577->status_data.status
 SET out_rec->event_id = cnvtstring(event_id)
 SET out_rec->workflow_id = cnvtstring(workflow_id)
 SET out_rec->ce_blob = html_string
#exit_script
 SET _memory_reply_string = cnvtrectojson(out_rec)
END GO
