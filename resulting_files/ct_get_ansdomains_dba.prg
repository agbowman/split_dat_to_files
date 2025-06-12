CREATE PROGRAM ct_get_ansdomains:dba
 RECORD reply(
   1 qual[*]
     2 answer_domain_id = f8
     2 answer_domain_label = c30
     2 answer_domain_descn = vc
     2 answer_domain_type = c30
     2 updt_flag = i2
     2 cat_item[*]
       3 category_item_id = f8
       3 category_item_text = vc
     2 format[*]
       3 answer_format_id = f8
       3 format_label = c30
       3 format_descn = vc
   1 status_data
     2 status = c1
     2 reason_for_failure = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET countf = 0
 SET countcat = 0
 SET yesupdate = 1
 SET noupdate = 0
 SET i = 0
 SELECT INTO "nl:"
  ad.answer_domain_id
  FROM answer_domain ad,
   answer_format af,
   code_value cv,
   dummyt d1,
   dummyt d2
  PLAN (ad
   WHERE ad.answer_domain_id != 0.0)
   JOIN (d1)
   JOIN (af
   WHERE ad.answer_domain_id=af.answer_domain_id)
   JOIN (d2)
   JOIN (cv
   WHERE cv.code_value=ad.answer_domain_type_cd)
  ORDER BY ad.answer_domain_id, af.format_label
  HEAD ad.answer_domain_id
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].answer_domain_id
    = ad.answer_domain_id,
   reply->qual[count1].answer_domain_label = ad.answer_domain_label, reply->qual[count1].
   answer_domain_descn = ad.answer_domain_descn, reply->qual[count1].answer_domain_type = cv
   .cdf_meaning,
   reply->qual[count1].updt_flag = yesupdate, countf = 0
  DETAIL
   IF (af.answer_format_id != null)
    countf = (countf+ 1), stat = alterlist(reply->qual[count1].format,countf), reply->qual[count1].
    format[countf].format_label = af.format_label,
    reply->qual[count1].format[countf].answer_format_id = af.answer_format_id, reply->qual[count1].
    format[countf].format_descn = af.format_descn
   ENDIF
  WITH outerjoin = d1, dontcare = af
 ;end select
 FOR (i = 1 TO count1)
   IF (substring(1,10,reply->qual[i].answer_domain_type)="CATEGORICA")
    SET reply->qual[i].answer_domain_type = "CATEGORICAL"
    SET countcat = 0
    SELECT INTO "nl:"
     ci.category_item_id
     FROM category_item ci
     WHERE (ci.answer_domain_id=reply->qual[i].answer_domain_id)
     DETAIL
      countcat = (countcat+ 1), stat = alterlist(reply->qual[i].cat_item,countcat), reply->qual[i].
      cat_item[countcat].category_item_id = ci.category_item_id,
      reply->qual[i].cat_item[countcat].category_item_text = ci.category_item_text
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
