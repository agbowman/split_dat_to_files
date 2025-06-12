CREATE PROGRAM cps_get_form_num:dba
 RECORD reply(
   1 description = vc
   1 dcp_forms_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  FROM dcp_forms_ref d
  PLAN (d
   WHERE (d.description=request->form_name))
  DETAIL
   reply->description = d.description, reply->dcp_forms_ref_id = d.dcp_forms_ref_id
  WITH nocounter
 ;end select
END GO
