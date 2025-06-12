CREATE PROGRAM cps_get_org_alias_pool_r_sub:dba
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM org_alias_pool_reltn o,
   code_value cv
  PLAN (o
   WHERE o.active_ind=1
    AND  $1
    AND  $2
    AND  $3
    AND  $4
    AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (cv
   WHERE cv.code_value=o.alias_entity_alias_type_cd
    AND cv.active_ind=1)
  DETAIL
   count += 1
   IF (mod(count,100)=1)
    stat = alterlist(reply->qual,(count+ 100))
   ENDIF
   reply->qual[count].organization_id = o.organization_id, reply->qual[count].alias_entity_name = o
   .alias_entity_name, reply->qual[count].alias_entity_alias_type_cd = o.alias_entity_alias_type_cd,
   reply->qual[count].alias_pool_cd = o.alias_pool_cd, reply->qual[count].beg_effective_dt_tm = o
   .beg_effective_dt_tm, reply->qual[count].end_effective_dt_tm = o.end_effective_dt_tm,
   reply->qual[count].alias_entity_alias_type_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->qual,count)
END GO
