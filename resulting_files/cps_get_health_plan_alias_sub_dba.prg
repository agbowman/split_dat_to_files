CREATE PROGRAM cps_get_health_plan_alias_sub:dba
 SET mycount = 0
 SELECT INTO "nl:"
  FROM health_plan_alias h
  WHERE h.active_ind=1
   AND  $1
   AND  $2
   AND  $3
   AND  $4
   AND h.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND h.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   mycount += 1
   IF (mod(mycount,100)=1)
    stat = alterlist(reply->health_plan_alias,(mycount+ 100))
   ENDIF
   reply->health_plan_alias[mycount].health_plan_alias_id = h.health_plan_alias_id, reply->
   health_plan_alias[mycount].health_plan_id = h.health_plan_id, reply->health_plan_alias[mycount].
   alias = h.alias,
   reply->health_plan_alias[mycount].alias_pool_cd = h.alias_pool_cd, reply->health_plan_alias[
   mycount].beg_effective_dt_tm = h.beg_effective_dt_tm, reply->health_plan_alias[mycount].
   end_effective_dt_tm = h.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (mycount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->health_plan_alias,mycount)
 SET reply->health_plan_alias_qual = mycount
END GO
