CREATE PROGRAM cr_get_powerform_by_desc:dba
 FREE RECORD reply
 RECORD reply(
   1 powerforms[*]
     2 form_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT DISTINCT
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  WHERE dfr.description=trim(request->form_description)
  HEAD REPORT
   refcnt = 0
  DETAIL
   refcnt = (refcnt+ 1)
   IF (mod(refcnt,10)=1)
    stat = alterlist(reply->powerforms,(refcnt+ 9))
   ENDIF
   reply->powerforms[refcnt].form_ref_id = dfr.dcp_forms_ref_id
  FOOT REPORT
   stat = alterlist(reply->powerforms,refcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "cr_get_powerform_by_desc"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No form ref ids related to the description. Exiting script."
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
