CREATE PROGRAM bed_get_bb_bill_items:dba
 FREE SET reply
 RECORD reply(
   1 products[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET bb_ext_contr_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="BBPRODUCT"
   AND cv.active_ind=1
  DETAIL
   bb_ext_contr_cd = cv.code_value
  WITH nocounter
 ;end select
 SET bb_act_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="BB PRODUCT"
   AND cv.active_ind=1
  DETAIL
   bb_act_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM bill_item bi
  WHERE bi.ext_parent_contributor_cd=bb_ext_contr_cd
   AND bi.ext_owner_cd=bb_act_type_cd
   AND bi.ext_parent_reference_id > 0
   AND bi.active_ind=1
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->products,rcnt), reply->products[rcnt].code_value = bi
   .ext_parent_reference_id,
   reply->products[rcnt].display = bi.ext_short_desc, reply->products[rcnt].description = bi
   .ext_description
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
