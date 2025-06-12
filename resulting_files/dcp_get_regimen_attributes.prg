CREATE PROGRAM dcp_get_regimen_attributes
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 attributelist[*]
     2 regimen_cat_attribute_id = f8
     2 display = vc
     2 mean = vc
     2 input_type_flag = i2
     2 code_set = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE attributeidx = i4 WITH noconstant(0), protect
 SELECT INTO "nl:"
  FROM regimen_cat_attribute rca
  WHERE rca.active_ind=1
   AND rca.regimen_cat_attribute_id > 0.0
  ORDER BY rca.attribute_display
  HEAD REPORT
   attributeidx = 0, stat = alterlist(reply->attributelist,10)
  DETAIL
   attributeidx = (attributeidx+ 1)
   IF (attributeidx > size(reply->attributelist,5))
    stat = alterlist(reply->attributelist,(attributeidx+ 10))
   ENDIF
   reply->attributelist[attributeidx].regimen_cat_attribute_id = rca.regimen_cat_attribute_id, reply
   ->attributelist[attributeidx].display = rca.attribute_display, reply->attributelist[attributeidx].
   mean = rca.attribute_mean,
   reply->attributelist[attributeidx].input_type_flag = rca.input_type_flag, reply->attributelist[
   attributeidx].code_set = rca.code_set
  FOOT REPORT
   stat = alterlist(reply->attributelist,attributeidx)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
