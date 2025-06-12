CREATE PROGRAM cps_get_all_org_plan_reltn:dba
 RECORD reply(
   1 org_plan_reltn_qual = i4
   1 org_plan_reltn[*]
     2 org_plan_reltn_id = f8
     2 organization_id = f8
     2 health_plan_id = f8
     2 org_plan_reltn_cd = f8
     2 org_plan_reltn_disp = vc
     2 org_plan_reltn_mean = vc
     2 group_name = c200
     2 group_nbr = c100
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  p.*
  FROM org_plan_reltn p
  WHERE active_ind=1
  DETAIL
   count = (count+ 1)
   IF (mod(count,100)=1)
    stat = alterlist(reply->org_plan_reltn,(count+ 100))
   ENDIF
   reply->org_plan_reltn[count].org_plan_reltn_id = p.org_plan_reltn_id, reply->org_plan_reltn[count]
   .organization_id = p.organization_id, reply->org_plan_reltn[count].health_plan_id = p
   .health_plan_id,
   reply->org_plan_reltn[count].org_plan_reltn_cd = p.org_plan_reltn_cd, reply->org_plan_reltn[count]
   .group_name = p.group_name, reply->org_plan_reltn[count].group_nbr = p.group_nbr,
   reply->org_plan_reltn[count].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->org_plan_reltn[
   count].end_effective_dt_tm = p.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alterlist(reply->org_plan_reltn,count)
 SET reply->org_plan_reltn_qual = count
END GO
