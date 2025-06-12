CREATE PROGRAM cps_get_person_plan_reltn:dba
 RECORD reply(
   1 person_plan_reltn_qual = i4
   1 person_plan_reltn[*]
     2 person_plan_reltn_id = f8
     2 health_plan_id = f8
     2 plan_name = vc
     2 plan_name_key = vc
     2 person_id = f8
     2 person_plan_r_cd = f8
     2 person_org_reltn_id = f8
     2 organization_id = f8
     2 org_name = vc
     2 contributor_system_cd = f8
     2 priority_seq = i4
     2 member_nbr = c100
     2 signature_on_file_cd = f8
     2 balance_type_cd = f8
     2 deduct_amt = f8
     2 deduct_met_amt = f8
     2 deduct_met_dt_tm = dq8
     2 coverage_type_cd = f8
     2 max_out_pckt_amt = f8
     2 max_out_pckt_dt_tm = dq8
     2 fam_deduct_met_amt = f8
     2 fam_deduct_met_dt_tm = dq8
     2 plan_type_cd = f8
     2 plan_class_cd = f8
     2 insured_card_name = vc
     2 verify_status_cd = f8
     2 verify_dt_tm = dq8
     2 verify_prsnl_id = f8
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
 EXECUTE cps_get_person_plan_reltn_sub parser(
  IF ((request->person_plan_reltn_id=0.0)) "0=0"
  ELSE "p.PERSON_PLAN_RELTN_ID = request->PERSON_PLAN_RELTN_ID"
  ENDIF
  ), parser(
  IF ((request->person_id=0.0)) "0=0"
  ELSE "p.PERSON_ID = request->PERSON_ID "
  ENDIF
  ), parser(
  IF ((request->health_plan_id=0.0)) "0=0"
  ELSE "p.health_plan_id = request->health_plan_id "
  ENDIF
  ),
 parser(
  IF (trim(request->member_nbr)="") "0=0"
  ELSE "p.member_nbr = request->member_nbr "
  ENDIF
  ), parser(
  IF ((request->ignore_dates_ind=1)) "0=0"
  ELSE concat("p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
    "and p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  ENDIF
  ), parser(
  IF ((request->ignore_active_ind=1)) "0=0"
  ELSE "p.active_ind = 1 "
  ENDIF
  )
END GO
