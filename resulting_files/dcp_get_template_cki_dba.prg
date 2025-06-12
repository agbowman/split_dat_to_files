CREATE PROGRAM dcp_get_template_cki:dba
 RECORD reply(
   1 cki = vc
   1 template_id = f8
   1 template_name = vc
   1 smart_template_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->template_id != 0.0))
   WHERE (nt.template_id=request->template_id)
  ELSEIF ((request->cki != ""))
   WHERE (nt.cki=request->cki)
  ELSEIF ((request->smart_template_cd != 0.0))
   WHERE (nt.smart_template_cd=request->smart_template_cd)
  ELSE
  ENDIF
  INTO "nl:"
  FROM clinical_note_template nt
  DETAIL
   reply->cki = nt.cki, reply->template_id = nt.template_id, reply->template_name = nt.template_name,
   reply->smart_template_cd = nt.smart_template_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
