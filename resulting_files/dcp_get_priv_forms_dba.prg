CREATE PROGRAM dcp_get_priv_forms:dba
 RECORD reply(
   1 forms_cnt = i2
   1 forms_list[*]
     2 dcp_forms_ref_id = f8
     2 dcp_form_instance_id = f8
     2 description = vc
     2 definition = vc
     2 flags = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id > 0)
  ORDER BY dfr.description
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->forms_list,5))
    stat = alterlist(reply->forms_list,(count1+ 20))
   ENDIF
   reply->forms_list[count1].dcp_forms_ref_id = dfr.dcp_forms_ref_id, reply->forms_list[count1].
   dcp_form_instance_id = dfr.dcp_form_instance_id, reply->forms_list[count1].description = dfr
   .description,
   reply->forms_list[count1].definition = dfr.definition, reply->forms_list[count1].active_ind = dfr
   .active_ind, reply->forms_list[count1].flags = dfr.flags
  FOOT REPORT
   reply->forms_cnt = count1, stat = alterlist(reply->forms_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
