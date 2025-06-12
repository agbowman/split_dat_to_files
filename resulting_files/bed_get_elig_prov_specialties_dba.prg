CREATE PROGRAM bed_get_elig_prov_specialties:dba
 FREE SET reply
 RECORD reply(
   1 specialties[*]
     2 id = f8
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
 SET scnt = 0
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="ELIGPROVSPECIALTY"
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->specialties,scnt), reply->specialties[scnt].id = b
   .br_name_value_id,
   reply->specialties[scnt].description = b.br_value
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
