CREATE PROGRAM bed_get_datamart_event_data:dba
 FREE SET reply
 RECORD reply(
   1 assay_code_value = f8
   1 assay_display = vc
   1 powerforms[*]
     2 id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM discrete_task_assay d
  PLAN (d
   WHERE (d.event_cd=request->event_code_value)
    AND d.active_ind=1)
  DETAIL
   reply->assay_code_value = d.task_assay_cd, reply->assay_display = d.mnemonic
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM code_value_event_r c,
    discrete_task_assay d
   PLAN (c
    WHERE (c.event_cd=request->event_code_value))
    JOIN (d
    WHERE d.task_assay_cd=c.parent_cd
     AND d.active_ind=1)
   DETAIL
    reply->assay_code_value = d.task_assay_cd, reply->assay_display = d.mnemonic
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load_powerform_ind=1))
  SELECT INTO "nl:"
   FROM dcp_forms_ref f,
    dcp_forms_def d,
    dcp_section_ref s,
    dcp_input_ref i,
    name_value_prefs n
   PLAN (f
    WHERE f.active_ind=1)
    JOIN (d
    WHERE d.dcp_form_instance_id=f.dcp_form_instance_id
     AND d.active_ind=1)
    JOIN (s
    WHERE s.dcp_section_ref_id=d.dcp_section_ref_id
     AND s.active_ind=1)
    JOIN (i
    WHERE i.dcp_section_instance_id=s.dcp_section_instance_id
     AND i.active_ind=1)
    JOIN (n
    WHERE n.parent_entity_id=i.dcp_input_ref_id
     AND n.parent_entity_name="DCP_INPUT_REF"
     AND trim(n.pvc_name)="discrete_task_assay"
     AND ((n.merge_id+ 0)=reply->assay_code_value)
     AND ((n.active_ind+ 0)=1))
   ORDER BY f.description
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->powerforms,cnt), reply->powerforms[cnt].id = f
    .dcp_forms_ref_id,
    reply->powerforms[cnt].name = f.description
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
