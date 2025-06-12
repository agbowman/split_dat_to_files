CREATE PROGRAM cps_get_org_plan_reltn_sub:dba
 SET kount = 0
 SELECT INTO "nl:"
  p.*
  FROM org_plan_reltn p,
   organization o
  PLAN (p
   WHERE  $1
    AND  $2
    AND  $3
    AND p.active_ind=1)
   JOIN (o
   WHERE p.organization_id=o.organization_id)
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alter(reply->org_plan_reltn,(kount+ 100))
   ENDIF
   reply->org_plan_reltn[kount].org_plan_reltn_id = p.org_plan_reltn_id, reply->org_plan_reltn[kount]
   .health_plan_id = p.health_plan_id, reply->org_plan_reltn[kount].organization_id = p
   .organization_id,
   reply->org_plan_reltn[kount].org_plan_reltn_cd = p.org_plan_reltn_cd, reply->org_plan_reltn[kount]
   .group_nbr = p.group_nbr, reply->org_plan_reltn[kount].group_name = p.group_name,
   reply->org_plan_reltn[kount].policy_nbr = p.policy_nbr, reply->org_plan_reltn[kount].contract_code
    = p.contract_code, reply->org_plan_reltn[kount].beg_effective_dt_tm = p.beg_effective_dt_tm,
   reply->org_plan_reltn[kount].end_effective_dt_tm = p.end_effective_dt_tm, reply->org_plan_reltn[
   kount].org_name = o.org_name, reply->org_plan_reltn[kount].org_name_key = o.org_name_key,
   reply->org_plan_reltn[kount].data_status_cd = p.data_status_cd
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->org_plan_reltn,kount)
 SET reply->org_plan_reltn_qual = kount
END GO
