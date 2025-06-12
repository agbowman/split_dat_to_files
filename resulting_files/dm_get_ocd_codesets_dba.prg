CREATE PROGRAM dm_get_ocd_codesets:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 feature_number = i4
   1 count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET onumber = request->ocd_number
 SET reply->count = 0
 SELECT DISTINCT INTO "nl:"
  d.code_set, d.feature_number
  FROM dm_afd_code_value_set d
  WHERE d.alpha_feature_nbr=onumber
  DETAIL
   reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
   count].code_set = d.code_set,
   reply->qual[reply->count].feature_number = d.feature_number
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
