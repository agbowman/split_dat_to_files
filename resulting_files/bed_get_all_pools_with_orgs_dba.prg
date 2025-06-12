CREATE PROGRAM bed_get_all_pools_with_orgs:dba
 FREE SET reply
 RECORD reply(
   1 alias_pools[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE apcnt = i4
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET apcnt = 0
 SELECT DISTINCT INTO "nl:"
  FROM org_alias_pool_reltn oapr,
   code_value cv
  PLAN (oapr
   WHERE oapr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=oapr.alias_pool_cd
    AND cv.code_set=263
    AND cv.active_ind=1)
  ORDER BY cv.display
  DETAIL
   apcnt = (apcnt+ 1), stat = alterlist(reply->alias_pools,apcnt), reply->alias_pools[apcnt].
   code_value = cv.code_value,
   reply->alias_pools[apcnt].display = cv.display, reply->alias_pools[apcnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_POOL_BY_ORG  >> ERROR MESSAGE: ",
   error_msg)
 ELSEIF (apcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
