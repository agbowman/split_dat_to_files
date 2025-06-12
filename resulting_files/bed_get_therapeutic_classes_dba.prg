CREATE PROGRAM bed_get_therapeutic_classes:dba
 FREE SET reply
 RECORD reply(
   1 therapeutic_classes[*]
     2 id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM mltm_drug_categories m
  ORDER BY m.category_name
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(reply->therapeutic_classes,tcnt), reply->therapeutic_classes[
   tcnt].id = m.multum_category_id,
   reply->therapeutic_classes[tcnt].name = m.category_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
