CREATE PROGRAM cv_get_form:dba
 SET input_form_cd = 0
 RECORD reply(
   1 input_form_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  frm.input_form_cd
  FROM input_form_reference frm
  WHERE (frm.description=request->description)
   AND (frm.active_ind=request->active_ind)
  DETAIL
   reply->input_form_cd = frm.input_form_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_GET_FORM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
