CREATE PROGRAM aps_get_proxy_ind_filters:dba
 RECORD reply(
   1 qual[*]
     2 prsnl_group_id = f8
     2 prsnl_group_name = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cv.cdf_meaning, pg.prsnl_group_type_cd, pg.prsnl_group_id,
  pg.prsnl_group_name
  FROM code_value cv,
   prsnl_group pg
  PLAN (cv
   WHERE cv.code_set=357
    AND cv.cdf_meaning IN ("APCORRGRP", "CYTORPTGRP", "CYTOTECH", "HISTOTECH", "PATHOLOGIST",
   "PATHRESIDENT", "PATHUSER")
    AND cv.active_ind=1)
   JOIN (pg
   WHERE pg.prsnl_group_type_cd=cv.code_value
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   fltr_cnt = 0
  DETAIL
   fltr_cnt = (fltr_cnt+ 1)
   IF (mod(fltr_cnt,10)=1)
    stat = alterlist(reply->qual,(fltr_cnt+ 9))
   ENDIF
   reply->qual[fltr_cnt].prsnl_group_id = pg.prsnl_group_id, reply->qual[fltr_cnt].prsnl_group_name
    = pg.prsnl_group_name
  FOOT REPORT
   stat = alterlist(reply->qual,fltr_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL_GROUP"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
