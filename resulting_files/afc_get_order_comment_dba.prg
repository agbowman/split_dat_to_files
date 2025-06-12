CREATE PROGRAM afc_get_order_comment:dba
 RECORD reply(
   1 comment_qual = i2
   1 comment[*]
     2 long_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->comment,count1)
 SET ord_comment = 0.0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=14
   AND cv.cdf_meaning="ORD COMMENT"
  DETAIL
   ord_comment = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  o.order_id, l.long_text
  FROM order_comment o,
   long_text l
  PLAN (o
   WHERE (o.order_id=request->order_id)
    AND o.comment_type_cd=ord_comment)
   JOIN (l
   WHERE l.long_text_id=o.long_text_id)
  ORDER BY o.order_id
  HEAD o.order_id
   count1 = (count1+ 1), stat = alterlist(reply->comment,count1), reply->comment[count1].long_text =
   trim(l.long_text)
  DETAIL
   count1 = count1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->comment,count1)
 SET reply->comment_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
