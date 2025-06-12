CREATE PROGRAM aps_get_facilities:dba
 RECORD reply(
   1 location[10]
     2 location_cd = f8
     2 location_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET meaning_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET count = 0
 SET code_set = 222
 SET cdf_meaning = "FACILITY"
 EXECUTE cpm_get_cd_for_cdf
 SET meaning_cd = code_value
 SELECT INTO "nl:"
  l.location_cd
  FROM location l
  WHERE l.location_type_cd=meaning_cd
   AND l.active_ind=1
   AND l.organization_id > 0.0
   AND l.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   IF (l.location_cd > 0)
    count = (count+ 1)
    IF (mod(count,10)=1
     AND count != 1)
     stat = alter(reply->location,(count+ 10))
    ENDIF
    reply->location[count].location_cd = l.location_cd
   ENDIF
  FOOT REPORT
   stat = alter(reply->location,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET stat = alter(reply->location,1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LOCATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
