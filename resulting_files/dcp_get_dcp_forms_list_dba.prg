CREATE PROGRAM dcp_get_dcp_forms_list:dba
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
 RECORD temp_rec(
   1 forms_cnt = i4
   1 forms_list[*]
     2 dcp_forms_ref_id = f8
     2 dcp_form_instance_id = f8
     2 description = vc
     2 definition = vc
     2 flags = i4
     2 active_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE active_ind = i2 WITH noconstant(1)
 IF ((request->load_inactive_forms=1))
  SET active_ind = 0
 ENDIF
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id > 0
    AND dfr.active_ind >= active_ind
    AND cnvtupper(dfr.description)=value(concat(cnvtupper(request->desc_prefix),"*")))
  ORDER BY dfr.dcp_forms_ref_id, dfr.end_effective_dt_tm DESC
  HEAD REPORT
   count = 0
  HEAD dfr.dcp_forms_ref_id
   count = (count+ 1)
   IF (count > size(temp_rec->forms_list,5))
    stat = alterlist(temp_rec->forms_list,(count+ 20))
   ENDIF
   temp_rec->forms_list[count].active_ind = dfr.active_ind, temp_rec->forms_list[count].
   dcp_forms_ref_id = dfr.dcp_forms_ref_id, temp_rec->forms_list[count].dcp_form_instance_id = dfr
   .dcp_form_instance_id,
   temp_rec->forms_list[count].description = dfr.description, temp_rec->forms_list[count].definition
    = dfr.definition, temp_rec->forms_list[count].flags = dfr.flags
  DETAIL
   donothing = 0
  FOOT  dfr.dcp_forms_ref_id
   donothing = 0
  FOOT REPORT
   temp_rec->forms_cnt = count, stat = alterlist(temp_rec->forms_list,count)
  WITH nocounter
 ;end select
 IF ((temp_rec->forms_cnt > 0))
  SET stat = alterlist(reply->forms_list,temp_rec->forms_cnt)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = temp_rec->forms_cnt)
   PLAN (d)
   ORDER BY cnvtupper(temp_rec->forms_list[d.seq].description)
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), reply->forms_list[count].active_ind = temp_rec->forms_list[d.seq].active_ind,
    reply->forms_list[count].dcp_forms_ref_id = temp_rec->forms_list[d.seq].dcp_forms_ref_id,
    reply->forms_list[count].dcp_form_instance_id = temp_rec->forms_list[d.seq].dcp_form_instance_id,
    reply->forms_list[count].description = temp_rec->forms_list[d.seq].description, reply->
    forms_list[count].definition = temp_rec->forms_list[d.seq].definition,
    reply->forms_list[count].flags = temp_rec->forms_list[d.seq].flags
   FOOT REPORT
    reply->forms_cnt = count, stat = alterlist(reply->forms_list,count)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->forms_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echorecord(temp_rec)
  CALL echorecord(reply)
 ELSE
  FREE RECORD temp_rec
 ENDIF
END GO
