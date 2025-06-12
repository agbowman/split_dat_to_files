CREATE PROGRAM cps_get_health_plan:dba
 RECORD reply(
   1 health_plan_qual = i4
   1 health_plan[100]
     2 health_plan_id = f8
     2 plan_type_cd = f8
     2 plan_name = c200
     2 plan_desc = c200
     2 financial_class_cd = f8
     2 ft_entity_name = c200
     2 ft_entity_id = f8
     2 baby_coverage_cd = f8
     2 comb_baby_bill_cd = f8
     2 plan_class_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE cps_get_health_plan_sub parser(
  IF ((request->health_plan_id=0.0)) "0=0"
  ELSE "p.health_plan_id=request->health_plan_id "
  ENDIF
  ), parser(
  IF ((((request->plan_name=null)) OR ((request->plan_name=""))) ) "0=0"
  ELSE "cnvtupper(p.plan_name)=patstring(cnvtupper(request->plan_name))"
  ENDIF
  )
END GO
