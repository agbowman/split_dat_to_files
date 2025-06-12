CREATE PROGRAM cdi_get_all_cover_page_tmps:dba
 RECORD reply(
   1 templates[*]
     2 cover_page_template_id = f8
     2 cover_page_name_key = vc
     2 cover_page_name = vc
     2 cover_page_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_cover_page_template cp,
   long_text_reference lt
  PLAN (cp
   WHERE cp.cdi_cover_page_template_id > 0)
   JOIN (lt
   WHERE cp.long_text_id=lt.long_text_id)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->templates,(count+ 10))
   ENDIF
   reply->templates[count].cover_page_template_id = cp.cdi_cover_page_template_id, reply->templates[
   count].cover_page_name_key = cp.template_name_key, reply->templates[count].cover_page_name = cp
   .template_name,
   reply->templates[count].cover_page_text = lt.long_text
  FOOT REPORT
   stat = alterlist(reply->templates,count)
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
END GO
