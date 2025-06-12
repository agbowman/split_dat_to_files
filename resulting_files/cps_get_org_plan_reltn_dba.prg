CREATE PROGRAM cps_get_org_plan_reltn:dba
 RECORD reply(
   1 org_plan_reltn_qual = i4
   1 org_plan_reltn[100]
     2 org_plan_reltn_id = f8
     2 health_plan_id = f8
     2 org_plan_reltn_cd = f8
     2 organization_id = f8
     2 group_nbr = c100
     2 group_name = c200
     2 policy_nbr = c100
     2 contract_code = c100
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 org_name = c100
     2 org_name_key = c100
     2 data_status_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cps_get_org_plan_reltn_sub parser(
  IF ((request->org_plan_reltn_id=0.0)) "0=0"
  ELSE "p.ORG_PLAN_RELTN_ID = request-> ORG_PLAN_RELTN_ID"
  ENDIF
  ), parser(
  IF ((request->health_plan_id=0.0)) "0=0"
  ELSE "p.health_plan_id = request->health_plan_id "
  ENDIF
  ), parser(
  IF ((request->organization_id=0.0)) "0=0"
  ELSE "p.ORGANIZATION_ID = request-> ORGANIZATION_ID "
  ENDIF
  )
END GO
