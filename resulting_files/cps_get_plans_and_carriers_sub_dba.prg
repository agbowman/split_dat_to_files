CREATE PROGRAM cps_get_plans_and_carriers_sub:dba
 SET org_type_cd_value = 0.0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=278
   AND (c.cdf_meaning=request->org_type[inx0].meaning)
  DETAIL
   org_type_cd_value = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM health_plan p,
   org_plan_reltn r,
   org_type_reltn t,
   organization o
  PLAN (p
   WHERE  $1
    AND  $2
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (r
   WHERE r.health_plan_id=p.health_plan_id
    AND r.org_plan_reltn_cd=carrier_cd_value
    AND r.active_ind=1
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (t
   WHERE t.organization_id=r.organization_id
    AND t.org_type_cd=org_type_cd_value
    AND t.active_ind=1
    AND t.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND t.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE o.organization_id=t.organization_id
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1
    AND kount != 1)
    stat = alter(reply->health_plan,(kount+ 99))
   ENDIF
   reply->health_plan[kount].baby_coverage_cd = p.baby_coverage_cd, reply->health_plan[kount].
   comb_baby_bill_cd = p.comb_baby_bill_cd, reply->health_plan[kount].beg_effective_dt_tm = p
   .beg_effective_dt_tm,
   reply->health_plan[kount].end_effective_dt_tm = p.end_effective_dt_tm, reply->health_plan[kount].
   financial_class_cd = p.financial_class_cd, reply->health_plan[kount].ft_entity_id = p.ft_entity_id,
   reply->health_plan[kount].ft_entity_name = p.ft_entity_name, reply->health_plan[kount].group_name
    = p.group_name, reply->health_plan[kount].group_nbr = p.group_nbr,
   reply->health_plan[kount].health_plan_id = p.health_plan_id, reply->health_plan[kount].
   carrier_plan_reltn_id = r.org_plan_reltn_id, reply->health_plan[kount].plan_class_cd = p
   .plan_class_cd,
   reply->health_plan[kount].plan_desc = p.plan_desc, reply->health_plan[kount].plan_name = p
   .plan_name, reply->health_plan[kount].plan_type_cd = p.plan_type_cd,
   reply->health_plan[kount].policy_nbr = p.policy_nbr, reply->health_plan[kount].data_status_cd = p
   .data_status_cd, reply->health_plan[kount].federal_tax_id_nbr = o.federal_tax_id_nbr,
   reply->health_plan[kount].org_ft_entity_id = o.ft_entity_id, reply->health_plan[kount].
   org_ft_entity_name = o.ft_entity_name, reply->health_plan[kount].organization_id = o
   .organization_id,
   reply->health_plan[kount].org_class_cd = o.org_class_cd, reply->health_plan[kount].org_status_cd
    = o.org_status_cd, reply->health_plan[kount].org_name = o.org_name,
   reply->health_plan[kount].org_type_cd = t.org_type_cd
  WITH nocounter
 ;end select
END GO
