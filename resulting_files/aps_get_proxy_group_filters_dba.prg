CREATE PROGRAM aps_get_proxy_group_filters:dba
 RECORD reply(
   1 qual[*]
     2 group_disp = c40
     2 group_cdf_meaning = c12
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
  cdf.cdf_meaning, cdf.display
  FROM common_data_foundation cdf
  PLAN (cdf
   WHERE cdf.code_set=357
    AND cdf.cdf_meaning IN ("APCORRGRP", "CYTORPTGRP", "CYTOTECH", "HISTOTECH", "PATHOLOGIST",
   "PATHRESIDENT", "PATHUSER"))
  HEAD REPORT
   fltr_cnt = 0
  DETAIL
   fltr_cnt = (fltr_cnt+ 1)
   IF (mod(fltr_cnt,10)=1)
    stat = alterlist(reply->qual,(fltr_cnt+ 9))
   ENDIF
   reply->qual[fltr_cnt].group_disp = cdf.display, reply->qual[fltr_cnt].group_cdf_meaning = cdf
   .cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->qual,fltr_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "COMMON_DATA_FOUNDATION"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
