CREATE PROGRAM cps_get_plans_and_carriers:dba
 RECORD reply(
   1 health_plan_qual = i4
   1 health_plan[100]
     2 baby_coverage_cd = f8
     2 baby_coverage_disp = vc
     2 baby_coverage_mean = vc
     2 beg_effective_dt_tm = dq8
     2 comb_baby_bill_cd = f8
     2 end_effective_dt_tm = dq8
     2 financial_class_cd = f8
     2 ft_entity_id = f8
     2 ft_entity_name = c32
     2 group_name = vc
     2 group_nbr = vc
     2 health_plan_id = f8
     2 carrier_plan_reltn_id = f8
     2 plan_class_cd = f8
     2 plan_desc = vc
     2 plan_name = vc
     2 plan_type_cd = f8
     2 data_status_cd = f8
     2 policy_nbr = vc
     2 federal_tax_id_nbr = vc
     2 org_ft_entity_id = f8
     2 org_ft_entity_name = c32
     2 organization_id = f8
     2 org_class_cd = f8
     2 org_name = vc
     2 org_status_cd = f8
     2 org_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET kount = 0
 SET num_types = size(request->org_type,5)
 SET reply->status_data.status = "F"
 SET carrier_cd_value = 0.0
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=370
   AND c.cdf_meaning="CARRIER"
  DETAIL
   carrier_cd_value = c.code_value
  WITH nocounter
 ;end select
 FOR (inx0 = 1 TO num_types)
   EXECUTE cps_get_plans_and_carriers_sub parser(
    IF ((request->health_plan_id=0.0)) "0=0"
    ELSE "p.health_plan_id = request->health_plan_id "
    ENDIF
    ), parser(
    IF (trim(request->plan_name)="") "0=0"
    ELSE "cnvtupper(p.plan_name) = patstring(cnvtupper(request->plan_name))"
    ENDIF
    )
 ENDFOR
 IF (kount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reply->health_plan_qual = kount
 SET stat = alter(reply->health_plan,kount)
 SET knt = 0
END GO
