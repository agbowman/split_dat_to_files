CREATE PROGRAM dcp_chk_section_form:dba
 RECORD reply(
   1 form_cnt = i4
   1 forms[*]
     2 dcp_forms_ref_id = f8
     2 description = vc
     2 definition = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET cnt = 0
 SET stat = 0
 SELECT INTO "nl;"
  FROM dcp_forms_def dfd,
   dcp_forms_ref dfr
  PLAN (dfd
   WHERE (dfd.dcp_section_ref_id=request->dcp_section_ref_id))
   JOIN (dfr
   WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
    AND dfr.active_ind=1)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->forms,cnt), reply->forms[cnt].dcp_forms_ref_id = dfr
   .dcp_forms_ref_id,
   reply->forms[cnt].description = dfr.description, reply->forms[cnt].definition = dfr.definition
  WITH nocounter
 ;end select
 SET reply->form_cnt = cnt
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("status:",reply->status_data.status))
 CALL echo(build("count:",reply->form_cnt))
END GO
