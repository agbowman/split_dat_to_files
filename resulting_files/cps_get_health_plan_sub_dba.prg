CREATE PROGRAM cps_get_health_plan_sub:dba
 SET kount = 0
 SELECT INTO "nl:"
  *
  FROM health_plan p
  WHERE  $1
   AND  $2
   AND active_ind=1
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alter(reply->health_plan,(kount+ 100))
   ENDIF
   reply->health_plan[kount].health_plan_id = p.health_plan_id, reply->health_plan[kount].plan_name
    = p.plan_name, reply->health_plan[kount].plan_desc = p.plan_desc,
   reply->health_plan[kount].financial_class_cd = p.financial_class_cd, reply->health_plan[kount].
   ft_entity_name = p.ft_entity_name, reply->health_plan[kount].ft_entity_id = p.ft_entity_id,
   reply->health_plan[kount].baby_coverage_cd = p.baby_coverage_cd, reply->health_plan[kount].
   comb_baby_bill_cd = p.comb_baby_bill_cd, reply->health_plan[kount].plan_type_cd = p.plan_type_cd,
   reply->health_plan[kount].plan_class_cd = p.plan_class_cd, reply->health_plan[kount].
   beg_effective_dt_tm = p.beg_effective_dt_tm, reply->health_plan[kount].end_effective_dt_tm = p
   .end_effective_dt_tm,
   reply->health_plan[kount].updt_cnt = p.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual < 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->health_plan,kount)
 SET reply->health_plan_qual = kount
 CALL echo("status:",0)
 CALL echo(reply->status_data.status)
 CALL echo("kount:",0)
 CALL echo(kount)
END GO
