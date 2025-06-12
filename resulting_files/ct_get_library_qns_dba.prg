CREATE PROGRAM ct_get_library_qns:dba
 RECORD reply(
   1 qual[*]
     2 eql_id = f8
     2 eql_label = c30
     2 eql_question = vc
     2 format_label = c30
     2 answer_domain = c30
     2 answer_format_id = f8
     2 val_reqd_flag = i2
     2 dt_reqd_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  eql.elig_quest_library_id
  FROM elig_quest_library eql,
   answer_format af,
   answer_domain ad,
   long_text_reference ltr
  PLAN (eql
   WHERE (request->eql_cat_cd=eql.eql_cat_cd))
   JOIN (af
   WHERE af.answer_format_id=eql.answer_format_id)
   JOIN (ad
   WHERE ad.answer_domain_id=af.answer_domain_id)
   JOIN (ltr
   WHERE ltr.long_text_id=eql.long_text_id)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].eql_id = eql
   .elig_quest_library_id,
   reply->qual[count].eql_label = eql.eql_label, reply->qual[count].eql_question = ltr.long_text,
   reply->qual[count].format_label = af.format_label,
   reply->qual[count].answer_domain = ad.answer_domain_label, reply->qual[count].answer_format_id =
   af.answer_format_id, reply->qual[count].val_reqd_flag = eql.value_required_flag,
   reply->qual[count].dt_reqd_flag = eql.date_required_flag
  WITH nocounter
 ;end select
#exit_script
 IF (curqual=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "April 02, 2004"
END GO
