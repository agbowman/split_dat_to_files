CREATE PROGRAM dcp_get_nomen_categories:dba
 RECORD reply(
   1 cnt = i4
   1 qual[10]
     2 category_id = f8
     2 category_name = vc
     2 custom_category_ind = i2
     2 default_ind = i2
     2 source_vocabulary_cd = f8
     2 principle_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM dcp_nomencategory c
  WHERE (c.category_type_cd=request->category_type_cd)
  ORDER BY c.sequence
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].category_id = c.category_id, reply->qual[cnt].category_name = trim(c
    .category_name), reply->qual[cnt].custom_category_ind = c.custom_category_ind,
   reply->qual[cnt].default_ind = c.default_ind, reply->qual[cnt].source_vocabulary_cd = c
   .source_vocabulary_cd, reply->qual[cnt].principle_type_cd = c.principle_type_cd
  WITH nocounter
 ;end select
 SET reply->cnt = cnt
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DCP_NOMENCATEGORY"
 ENDIF
 SET stat = alter(reply->qual,cnt)
END GO
