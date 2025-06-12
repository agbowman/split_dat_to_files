CREATE PROGRAM bhs_athn_get_wkf_text_v2
 FREE RECORD req969575
 RECORD req969575(
   1 patient_id = f8
   1 encntr_id = f8
   1 prsnl_id = f8
 )
 FREE RECORD req969579
 RECORD req969579(
   1 concept = vc
   1 workflow_id = f8
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
 FREE RECORD out_rec
 RECORD out_rec(
   1 event_id = vc
   1 text = gvc
   1 error_msg = vc
 )
 DECLARE application_id = i4 WITH protect, constant(600005)
 DECLARE task_id = i4 WITH protect, constant(3202004)
 DECLARE person_id = f8
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
 SET stat = tdbexecute(application_id,task_id,969575,"REC",req969575,
  "REC",rep969575)
 IF ((rep969575->status_data.status="S")
  AND size(rep969575->workflow_components,5) > 0)
  SET req969579->workflow_id = rep969575->workflow_id
  SET req969579->concept =  $4
  SET stat = tdbexecute(application_id,task_id,969579,"REC",req969579,
   "REC",rep969579)
  IF ((rep969579->status_data.status="F"))
   SET out_rec->error_msg = rep969579->status_data.subeventstatus[1].targetobjectvalue
   GO TO exit_script
  ENDIF
  SET out_rec->event_id = cnvtstring(rep969579->entity_id)
  SET out_rec->text = rep969579->xhtml
 ENDIF
#exit_script
 SET _memory_reply_string = cnvtrectojson(out_rec)
END GO
