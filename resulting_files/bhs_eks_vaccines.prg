CREATE PROGRAM bhs_eks_vaccines
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beginning Date:" = "CURDATE",
  "Ending Date:" = "CURDATE",
  "Type of Vaccine" = "3",
  "Facility" = 0,
  "Nurse Unit" = 0,
  "Totals" = "YES"
  WITH prompt1, prompt2, prompt3,
  prompt4, prompt5, prompt7,
  prompt6
 DECLARE place_flu_cd = f8
 DECLARE place_pneum_cd = f8
 DECLARE flu_vaccine_cd = f8
 DECLARE flu_vaccine_live_cd = f8
 DECLARE pneum_23vaccine_cd = f8
 DECLARE pneum_7vaccine_cd = f8
 DECLARE pneum_vaccine_cd = f8
 DECLARE order_action_cd = f8
 DECLARE fin_nbr_cd = f8
 SET place_flu_cd = uar_get_code_by("DISPLAY",200,"Place Influenza Vaccine Order")
 SET place_pneum_cd = uar_get_code_by("DISPLAY",200,"Place Pneumococcal Vaccine Order")
 SET flu_vaccine_cd = uar_get_code_by("DISPLAY",200,"Influenza Virus Vaccine")
 SET flu_vaccine_live_cd = uar_get_code_by("DISPLAY",200,"influenza virus vaccine, live, trivalent")
 SET pneum_23vaccine_cd = uar_get_code_by("DISPLAY",200,"Pneumococcal 23-Valent Vaccine")
 SET pneum_7vaccine_cd = uar_get_code_by("DISPLAY",200,"pneumococcal 7-valent vaccine")
 SET pneum_vaccine_cd = uar_get_code_by("DISPLAY",200,"Pneumococcal Vaccine")
 SET order_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET fin_nbr_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE cnt = i4
 SET cnt = 0
 FREE RECORD vaccine
 RECORD vaccine(
   1 list[*]
     2 eks_order_id = f8
     2 eks_orig_order_dt_tm = dq8
     2 eks_catalog_cd = f8
     2 eks_task_status_cd = f8
     2 eks_task_updt_prsnl = vc
     2 new_order_id = f8
     2 new_orig_order_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_facility_cd = f8
     2 patient_name = vc
     2 acct_num = vc
     2 new_ordered_as_mnemonic = vc
     2 new_clinical_display_line = vc
     2 new_charted_dt_tm = dq8
     2 new_chart_person = vc
     2 prsnl_id = f8
     2 prsnl_name = vc
 )
 SELECT INTO "nl:"
  FROM order_action oa,
   orders o,
   orders o2,
   task_activity ta,
   prsnl p,
   dummyt d,
   clinical_event ce,
   prsnl pr
  PLAN (oa
   WHERE oa.action_type_cd=order_action_cd
    AND oa.action_dt_tm BETWEEN cnvtdatetime(cnvtdate( $2),0) AND cnvtdatetime(cnvtdate( $3),235959))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND ((( $4="1")
    AND o.catalog_cd=place_flu_cd) OR (((( $4="2")
    AND o.catalog_cd=place_pneum_cd) OR (( $4="3")
    AND o.catalog_cd IN (place_flu_cd, place_pneum_cd))) ))
    AND  EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE e.encntr_id=o.encntr_id
     AND (e.loc_facility_cd= $PROMPT5)
     AND (e.loc_nurse_unit_cd= $PROMPT7))))
   JOIN (ta
   WHERE ta.order_id=outerjoin(o.order_id))
   JOIN (p
   WHERE p.person_id=outerjoin(ta.updt_id))
   JOIN (d)
   JOIN (o2
   WHERE o2.encntr_id=o.encntr_id
    AND o2.order_id != o.order_id
    AND ((o.catalog_cd=place_flu_cd
    AND o2.catalog_cd IN (flu_vaccine_cd, flu_vaccine_live_cd)) OR (o.catalog_cd=place_pneum_cd
    AND o2.catalog_cd IN (pneum_23vaccine_cd, pneum_7vaccine_cd, pneum_vaccine_cd))) )
   JOIN (ce
   WHERE ce.order_id=outerjoin(o2.order_id)
    AND ce.view_level=outerjoin(1)
    AND ce.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pr
   WHERE pr.person_id=outerjoin(ce.verified_prsnl_id))
  ORDER BY o.order_id
  HEAD o.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,100)=1)
    stat = alterlist(vaccine->list,(cnt+ 99))
   ENDIF
   vaccine->list[cnt].eks_order_id = o.order_id, vaccine->list[cnt].eks_orig_order_dt_tm = o
   .orig_order_dt_tm, vaccine->list[cnt].eks_catalog_cd = o.catalog_cd,
   vaccine->list[cnt].new_order_id = o2.order_id, vaccine->list[cnt].new_orig_order_dt_tm = o2
   .orig_order_dt_tm, vaccine->list[cnt].encntr_id = o.encntr_id,
   vaccine->list[cnt].person_id = o.person_id, vaccine->list[cnt].new_ordered_as_mnemonic = o2
   .ordered_as_mnemonic, vaccine->list[cnt].new_clinical_display_line = o2.clinical_display_line,
   vaccine->list[cnt].eks_task_status_cd = ta.task_status_cd, vaccine->list[cnt].eks_task_updt_prsnl
    = p.name_full_formatted, vaccine->list[cnt].new_charted_dt_tm = ce.event_end_dt_tm,
   vaccine->list[cnt].new_chart_person = pr.name_full_formatted
  FOOT REPORT
   IF (cnt > 0)
    stat = alterlist(vaccine->list,cnt)
   ELSE
    stat = alterlist(vaccine->list,1)
   ENDIF
  WITH outerjoin = d, nullreport
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(vaccine->list,5))),
   person p,
   order_action oa,
   prsnl pr,
   encounter e,
   encntr_alias ea,
   dummyt d2
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=vaccine->list[d.seq].person_id))
   JOIN (e
   WHERE (e.encntr_id=vaccine->list[d.seq].encntr_id))
   JOIN (ea
   WHERE ea.encntr_alias_type_cd=fin_nbr_cd
    AND ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ea.beg_effective_dt_tm AND ea.end_effective_dt_tm)
   JOIN (d2)
   JOIN (oa
   WHERE (oa.order_id=vaccine->list[d.seq].new_order_id)
    AND oa.action_type_cd=order_action_cd)
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
  DETAIL
   vaccine->list[d.seq].loc_nurse_unit_cd = e.loc_nurse_unit_cd, vaccine->list[d.seq].loc_facility_cd
    = e.loc_facility_cd, vaccine->list[d.seq].loc_room_cd = e.loc_room_cd,
   vaccine->list[d.seq].loc_bed_cd = e.loc_bed_cd, vaccine->list[d.seq].patient_name = p
   .name_full_formatted, vaccine->list[d.seq].prsnl_id = pr.person_id,
   vaccine->list[d.seq].prsnl_name = pr.name_full_formatted, vaccine->list[d.seq].acct_num = trim(ea
    .alias)
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO  $1
  care_set = vaccine->list[d.seq].eks_catalog_cd
  FROM (dummyt d  WITH seq = value(size(vaccine->list,5)))
  ORDER BY care_set
  HEAD PAGE
   col 1, curprog, col 50,
   "Baystate Health System", row + 1, col 50,
   "Vaccination Audit Report", row + 1
   IF (( $4="1"))
    col 50, "Influenza only"
   ELSEIF (( $4="2"))
    col 50, "Pneumococcal only"
   ELSEIF (( $4="3"))
    col 50, "Both Influenza and Pneumococcal"
   ENDIF
   row + 1, beg_date_disp = format(cnvtdate( $2),"MM/DD/YYYY;;D"), end_date_disp = format(cnvtdate(
      $3),"MM/DD/YYYY;;D"),
   col 50, "Date Range: ", beg_date_disp,
   " to ", end_date_disp, row + 2,
   col 1, "Acct", col 12,
   "Patient", col 45, "EKS Dt",
   col 57, "EKS Task Sts", col 70,
   "Location", col 92, "Admin Dt.",
   col 103, "Admin Prsnl", row + 1,
   col 12, "Vaccine Order Detail", col 110,
   "Order Prsnl", row + 2
  HEAD care_set
   cs_count = 0, cs_ordered_count = 0, cs_admin_count = 0,
   care_set_disp = uar_get_code_display(care_set), col 1, care_set_disp,
   row + 1
  DETAIL
   IF ((vaccine->list[d.seq].eks_order_id > 0))
    cs_count = (cs_count+ 1)
   ENDIF
   IF ((vaccine->list[d.seq].new_order_id > 0))
    cs_ordered_count = (cs_ordered_count+ 1)
   ENDIF
   IF ((vaccine->list[d.seq].new_charted_dt_tm > 0))
    cs_admin_count = (cs_admin_count+ 1)
   ENDIF
   col 1, vaccine->list[d.seq].acct_num, name_disp = substring(1,30,vaccine->list[d.seq].patient_name
    ),
   col 12, name_disp, eks_date_disp = format(vaccine->list[d.seq].eks_orig_order_dt_tm,
    "MM/DD/YYYY;;D"),
   col 45, eks_date_disp, eks_task_status_disp = substring(1,10,uar_get_code_display(vaccine->list[d
     .seq].eks_task_status_cd)),
   col 57, eks_task_status_disp, loc_disp = fillstring(20," "),
   loc_disp = concat(trim(uar_get_code_display(vaccine->list[d.seq].loc_nurse_unit_cd)),"/",trim(
     uar_get_code_display(vaccine->list[d.seq].loc_room_cd)),"/",trim(uar_get_code_display(vaccine->
      list[d.seq].loc_bed_cd))), col 70, loc_disp,
   new_chart_dt_tm_disp = format(vaccine->list[d.seq].new_charted_dt_tm,"MM/DD/YYYY;;D"), col 92,
   new_chart_dt_tm_disp,
   new_chart_person_name = substring(1,20,vaccine->list[d.seq].new_chart_person), col 103,
   new_chart_person_name,
   row + 1
   IF ((vaccine->list[d.seq].new_order_id > 0))
    new_order_disp = substring(1,95,concat(vaccine->list[d.seq].new_ordered_as_mnemonic," ",vaccine->
      list[d.seq].new_clinical_display_line)), col 12, new_order_disp,
    order_prsnl_disp = substring(1,20,vaccine->list[d.seq].prsnl_name), col 110, order_prsnl_disp,
    row + 1
   ENDIF
  FOOT  care_set
   IF (( $PROMPT6="YES"))
    care_set_disp = uar_get_code_display(care_set), percentage = 0.00, percentage = ((
    cs_ordered_count * 100.00)/ cs_count),
    col 1, "Totals: ", col 30,
    "EKS Orders Entered: ", col 60, cs_count,
    row + 1, col 30, "Medications Ordered: ",
    col 60, cs_ordered_count, col 80,
    percentage"###.##%", row + 1, percentage = ((cs_admin_count * 100.00)/ cs_count),
    col 30, "Medications Administered: ", col 60,
    cs_admin_count, col 80, percentage"###.##%",
    row + 2
   ENDIF
 ;end select
END GO
