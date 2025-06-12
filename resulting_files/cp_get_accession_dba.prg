CREATE PROGRAM cp_get_accession:dba
 RECORD reply(
   1 qual[1]
     2 name_full_formatted = vc
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 age = c12
     2 sex_cd = f8
     2 sex_disp = c40
     2 alias = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = vc
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = vc
     2 loc_room_cd = f8
     2 loc_room_disp = vc
     2 loc_bed_cd = f8
     2 loc_bed_disp = vc
     2 encntr_id = f8
     2 fin_nbr = vc
     2 med_service_cd = f8
     2 med_service_disp = vc
     2 reg_dt_tm = dq8
     2 order_id = f8
     2 order_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 accession_id = f8
     2 accession = vc
     2 org_name = vc
     2 result_status_cd = f8
     2 result_status_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET mrn_cd = 0.0
 SET person_type_cd = 0.0
 SET fin_nbr_cd = 0.0
 SET req_nbr = 0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_cd = code_value
 SET code_set = 302
 SET cdf_meaning = "PERSON"
 EXECUTE cpm_get_cd_for_cdf
 SET person_type_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET fin_nbr_cd = code_value
 SELECT DISTINCT INTO "nl:"
  age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p
     .birth_dt_tm,"hhmm;;m"))), ce.result_status_cd, ce.order_id
  FROM accession a,
   accession_order_r aor,
   orders o,
   clinical_event ce,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p,
   organization org,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (a
   WHERE (a.accession=request->accession))
   JOIN (aor
   WHERE a.accession_id=aor.accession_id)
   JOIN (o
   WHERE aor.order_id=o.order_id
    AND o.active_ind=1)
   JOIN (ce
   WHERE o.order_id=ce.order_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND e.encntr_id > 0)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1
    AND p.person_type_cd=person_type_cd
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.encntr_alias_type_cd=fin_nbr_cd
    AND ea1.active_ind=1
    AND ea1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mrn_cd
    AND ea2.active_ind=1
    AND ea2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (org
   WHERE org.organization_id=e.organization_id
    AND org.active_ind=1)
  ORDER BY ce.order_id, ce.result_status_cd
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > 1)
    stat = alter(reply->qual,count1)
   ENDIF
   reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].person_id = p
   .person_id, reply->qual[count1].birth_dt_tm = cnvtdatetime(p.birth_dt_tm),
   reply->qual[count1].age = age, reply->qual[count1].sex_cd = p.sex_cd, reply->qual[count1].alias =
   ea2.alias,
   reply->qual[count1].loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->qual[count1].loc_room_cd = e
   .loc_room_cd, reply->qual[count1].loc_bed_cd = e.loc_bed_cd,
   reply->qual[count1].encntr_id = e.encntr_id, reply->qual[count1].fin_nbr = ea1.alias, reply->qual[
   count1].med_service_cd = e.med_service_cd,
   reply->qual[count1].reg_dt_tm = cnvtdatetime(e.reg_dt_tm), reply->qual[count1].accession_id = a
   .accession_id, reply->qual[count1].order_id = o.order_id,
   reply->qual[count1].order_mnemonic = o.order_mnemonic, reply->qual[count1].orig_order_dt_tm =
   cnvtdatetime(o.orig_order_dt_tm), reply->qual[count1].order_status_cd = o.order_status_cd,
   reply->qual[count1].result_status_cd = ce.result_status_cd, reply->qual[count1].accession =
   request->accession, reply->qual[count1].org_name = org.org_name
  WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
   nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
