CREATE PROGRAM drc_get_age_weight_units:dba
 FREE SET reply
 RECORD reply(
   1 age_units[5]
     2 item_cd = f8
     2 item_disp = c40
     2 item_desc = c60
     2 item_mean = c12
   1 weight_units[4]
     2 item_cd = f8
     2 item_disp = c40
     2 item_desc = c60
     2 item_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SET reply->age_units[1].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!3712")
 SET reply->age_units[2].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!8423")
 SET reply->age_units[3].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!7993")
 SET reply->age_units[4].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!7994")
 SET reply->age_units[5].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!2743")
 SET reply->weight_units[1].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!2751")
 SET reply->weight_units[2].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!6123")
 SET reply->weight_units[3].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!2746")
 SET reply->weight_units[4].item_cd = uar_get_code_by_cki("CKI.CODEVALUE!2745")
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
