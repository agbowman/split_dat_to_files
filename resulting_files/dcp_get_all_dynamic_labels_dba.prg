CREATE PROGRAM dcp_get_all_dynamic_labels:dba
 RECORD reply(
   1 dta_cnt = i4
   1 dynamic_label_template_id[*]
     2 dynamic_label_name = vc
     2 dynamic_label_id = f8
     2 doc_set_ref_id = f8
     2 encounter_specific_ind = i2
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
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dynamic_label_template dlt,
   doc_set_ref dsr
  PLAN (dlt)
   JOIN (dsr
   WHERE dsr.doc_set_ref_id=dlt.doc_set_ref_id)
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->dynamic_label_template_id,10)
  DETAIL
   IF (dlt.label_template_id != 0)
    count1 = (count1+ 1)
    IF (mod(count1,10)=1
     AND count1 != 1)
     stat = alterlist(reply->dynamic_label_template_id,(count1+ 9))
    ENDIF
    reply->dynamic_label_template_id[count1].dynamic_label_name = dsr.doc_set_name, reply->
    dynamic_label_template_id[count1].dynamic_label_id = dlt.label_template_id, reply->
    dynamic_label_template_id[count1].doc_set_ref_id = dsr.doc_set_ref_id,
    reply->dynamic_label_template_id[count1].encounter_specific_ind = dlt.encounter_specific_ind
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->dynamic_label_template_id,count1), reply->dta_cnt = count1
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
