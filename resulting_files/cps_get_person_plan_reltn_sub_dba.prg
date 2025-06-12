CREATE PROGRAM cps_get_person_plan_reltn_sub:dba
 SET kount = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM person_plan_reltn p,
   organization o,
   health_plan h
  PLAN (p
   WHERE  $1
    AND  $2
    AND  $3
    AND  $4
    AND  $5
    AND  $6)
   JOIN (o
   WHERE o.organization_id=p.organization_id
    AND o.active_ind=1
    AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (h
   WHERE h.health_plan_id=p.health_plan_id
    AND h.active_ind=1
    AND h.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND h.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alterlist(reply->person_plan_reltn,(kount+ 100))
   ENDIF
   reply->person_plan_reltn[kount].person_plan_reltn_id = p.person_plan_reltn_id, reply->
   person_plan_reltn[kount].health_plan_id = p.health_plan_id, reply->person_plan_reltn[kount].
   plan_name = h.plan_name,
   reply->person_plan_reltn[kount].plan_name_key = h.plan_name_key, reply->person_plan_reltn[kount].
   person_id = p.person_id, reply->person_plan_reltn[kount].person_plan_r_cd = p.person_plan_r_cd,
   reply->person_plan_reltn[kount].person_org_reltn_id = p.person_org_reltn_id, reply->
   person_plan_reltn[kount].organization_id = p.organization_id, reply->person_plan_reltn[kount].
   org_name = o.org_name,
   reply->person_plan_reltn[kount].priority_seq = p.priority_seq, reply->person_plan_reltn[kount].
   member_nbr = p.member_nbr, reply->person_plan_reltn[kount].signature_on_file_cd = p
   .signature_on_file_cd,
   reply->person_plan_reltn[kount].balance_type_cd = p.balance_type_cd, reply->person_plan_reltn[
   kount].deduct_amt = p.deduct_amt, reply->person_plan_reltn[kount].deduct_met_amt = p
   .deduct_met_amt,
   reply->person_plan_reltn[kount].deduct_met_dt_tm = p.deduct_met_dt_tm, reply->person_plan_reltn[
   kount].coverage_type_cd = p.coverage_type_cd, reply->person_plan_reltn[kount].max_out_pckt_amt = p
   .max_out_pckt_amt,
   reply->person_plan_reltn[kount].max_out_pckt_dt_tm = p.max_out_pckt_dt_tm, reply->
   person_plan_reltn[kount].fam_deduct_met_amt = p.fam_deduct_met_amt, reply->person_plan_reltn[kount
   ].verify_status_cd = p.verify_status_cd,
   reply->person_plan_reltn[kount].verify_dt_tm = p.verify_dt_tm, reply->person_plan_reltn[kount].
   verify_prsnl_id = p.verify_prsnl_id, reply->person_plan_reltn[kount].beg_effective_dt_tm = p
   .beg_effective_dt_tm,
   reply->person_plan_reltn[kount].end_effective_dt_tm = p.end_effective_dt_tm, reply->
   person_plan_reltn[kount].contributor_system_cd = p.contributor_system_cd, reply->
   person_plan_reltn[kount].plan_type_cd = p.plan_type_cd,
   reply->person_plan_reltn[kount].plan_class_cd = p.plan_class_cd, reply->person_plan_reltn[kount].
   insured_card_name = p.insured_card_name,
   CALL echo(" PERSON_PLAN_RELTN_ID :",0),
   CALL echo(p.person_plan_reltn_id)
  WITH nocounter
 ;end select
 IF (kount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->person_plan_reltn,kount)
 SET reply->person_plan_reltn_qual = kount
 CALL echo("status:",0)
 CALL echo(reply->status_data.status)
 CALL echo("kount:",0)
 CALL echo(reply->person_plan_reltn_qual)
END GO
