CREATE PROGRAM dcp_get_label_info:dba
 RECORD reply(
   1 dta_cnt = i4
   1 label_template_id = f8
   1 doc_set_ref_id = f8
   1 doc_set_name = vc
   1 dynamic_label_info[*]
     2 dta_name = vc
     2 task_assay_cd = f8
   1 encounter_specific_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE dynstat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dynamic_label_template dlt,
   doc_set_ref dsr
  PLAN (dlt
   WHERE (dlt.label_template_id=request->label_id))
   JOIN (dsr
   WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
  DETAIL
   reply->label_template_id = dlt.label_template_id, reply->doc_set_ref_id = dsr.doc_set_ref_id,
   reply->doc_set_name = dsr.doc_set_name,
   reply->encounter_specific_ind = dlt.encounter_specific_ind
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  WHERE (dta.label_template_id=request->label_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1)
    stat = alterlist(reply->dynamic_label_info,(count1+ 9))
   ENDIF
   reply->dynamic_label_info[count1].dta_name = dta.description, reply->dynamic_label_info[count1].
   task_assay_cd = dta.task_assay_cd
  WITH nocounter
 ;end select
 SET dynstat = alterlist(reply->dynamic_label_info,count1)
 SET reply->dta_cnt = count1
END GO
