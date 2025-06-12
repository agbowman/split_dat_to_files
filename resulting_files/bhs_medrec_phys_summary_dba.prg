CREATE PROGRAM bhs_medrec_phys_summary:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 phys_cnt = i4
   1 phys_qual[*]
     2 phys_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 nurse_dt_tm = dq8
     2 disch_ind = i2
     2 admit_dt_tm = dq8
     2 discharge_dt_tm = dq8
     2 facility = vc
     2 a_rule_cnt = i4
     2 a_dta_cnt = i4
     2 t_rule_cnt = i4
     2 t_dta_cnt = i4
     2 d_rule_cnt = i4
     2 d_dta_cnt = i4
     2 a_18_hr_ind = vc
     2 a_24_hr_ind = vc
     2 t_12_hr_ind = vc
     2 recon_dt_tm = dq8
     2 admit_recon_dt_tm = dq8
     2 trans_recon_dt_tm = dq8
     2 disch_recon_dt_tm = dq8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 SET email_list =  $1
 DECLARE admit_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICATIONRECONCILIATIONADMITFORM"))
 DECLARE transfer_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICATIONRECONCILIATIONTRANSFERFORM"))
 DECLARE discharge_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MEDICATIONRECONCILIATIONDISCHARGEFORM"))
 DECLARE home_med_recon_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW")
  )
 DECLARE discharged_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",261,"DISCHARGED"))
 DECLARE t_line = vc
 DECLARE dis = vc
 DECLARE department = vc
 DECLARE twentyfour_hour = vc
 DECLARE indx = i4
 SELECT INTO "nl:"
  FROM eks_module_audit ema,
   eks_module_audit_det emad,
   encounter e
  PLAN (ema
   WHERE ema.begin_dt_tm >= cnvtdatetime(datetimeadd(sysdate,- (16)))
    AND ema.end_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ema.module_name="BHS_SYN_MED_REC*"
    AND ema.conclude=2)
   JOIN (emad
   WHERE emad.module_audit_id=ema.rec_id
    AND ((emad.encntr_id+ 0) > 0)
    AND emad.order_id > 0)
   JOIN (e
   WHERE e.encntr_id=emad.encntr_id)
  ORDER BY emad.encntr_id, ema.updt_id, ema.rec_id,
   0
  HEAD ema.updt_id
   idx = locateval(indx,1,t_record->phys_cnt,ema.updt_id,t_record->phys_qual[indx].phys_id)
   IF (idx=0)
    t_record->phys_cnt = (t_record->phys_cnt+ 1)
    IF (mod(t_record->phys_cnt,1000)=1)
     stat = alterlist(t_record->phys_qual,(t_record->phys_cnt+ 999))
    ENDIF
    idx = t_record->phys_cnt, t_record->phys_qual[idx].phys_id = ema.updt_id, t_record->phys_qual[idx
    ].encntr_id = emad.encntr_id,
    t_record->phys_qual[idx].person_id = e.person_id
    IF (e.encntr_status_cd=discharged_cd)
     t_record->phys_qual[idx].disch_ind = 1
    ENDIF
    t_record->phys_qual[idx].admit_dt_tm = cnvtdatetime(e.arrive_dt_tm), t_record->phys_qual[idx].
    discharge_dt_tm = cnvtdatetime(e.disch_dt_tm), t_record->phys_qual[idx].facility =
    uar_get_code_display(e.loc_facility_cd)
   ELSE
    found = 0
    FOR (z = 1 TO t_record->phys_cnt)
      IF ((ema.updt_id=t_record->phys_qual[z].phys_id)
       AND (emad.encntr_id=t_record->phys_qual[z].encntr_id))
       found = 1
      ENDIF
    ENDFOR
    IF (found=0)
     t_record->phys_cnt = (t_record->phys_cnt+ 1)
     IF (mod(t_record->phys_cnt,1000)=1)
      stat = alterlist(t_record->phys_qual,(t_record->phys_cnt+ 999))
     ENDIF
     idx = t_record->phys_cnt, t_record->phys_qual[idx].phys_id = ema.updt_id, t_record->phys_qual[
     idx].encntr_id = emad.encntr_id,
     t_record->phys_qual[idx].person_id = e.person_id
     IF (e.encntr_status_cd=discharged_cd)
      t_record->phys_qual[idx].disch_ind = 1
     ENDIF
     t_record->phys_qual[idx].admit_dt_tm = cnvtdatetime(e.arrive_dt_tm), t_record->phys_qual[idx].
     discharge_dt_tm = cnvtdatetime(e.disch_dt_tm), t_record->phys_qual[idx].facility =
     uar_get_code_display(e.loc_facility_cd)
    ENDIF
   ENDIF
  HEAD ema.rec_id
   IF (ema.module_name="BHS_SYN_MED_REC_ADM*")
    t_record->phys_qual[idx].a_rule_cnt = (t_record->phys_qual[idx].a_rule_cnt+ 1)
   ENDIF
   IF (ema.module_name="BHS_SYN_MED_REC_TRANSFER*")
    t_record->phys_qual[idx].t_rule_cnt = (t_record->phys_qual[idx].t_rule_cnt+ 1)
   ENDIF
   IF (ema.module_name="BHS_SYN_MED_REC_DISCH*")
    t_record->phys_qual[idx].d_rule_cnt = (t_record->phys_qual[idx].d_rule_cnt+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->phys_qual,t_record->phys_cnt)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND ((ce.performed_prsnl_id+ 0)=t_record->phys_qual[d.seq].phys_id)
    AND ce.event_cd IN (admit_cd, transfer_cd, discharge_cd))
  ORDER BY ce.encntr_id, ce.event_id DESC
  HEAD ce.encntr_id
   null
  HEAD ce.event_id
   IF (ce.event_cd=admit_cd)
    t_record->phys_qual[d.seq].a_dta_cnt = (t_record->phys_qual[d.seq].a_dta_cnt+ 1), t_record->
    phys_qual[d.seq].admit_recon_dt_tm = ce.event_end_dt_tm
   ELSEIF (ce.event_cd=transfer_cd)
    t_record->phys_qual[d.seq].t_dta_cnt = (t_record->phys_qual[d.seq].t_dta_cnt+ 1), t_record->
    phys_qual[d.seq].trans_recon_dt_tm = ce.event_end_dt_tm
   ELSEIF (ce.event_cd=discharge_cd)
    t_record->phys_qual[d.seq].d_dta_cnt = (t_record->phys_qual[d.seq].d_dta_cnt+ 1), t_record->
    phys_qual[d.seq].disch_recon_dt_tm = ce.event_end_dt_tm
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   order_recon orn
  PLAN (d)
   JOIN (orn
   WHERE (orn.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND (orn.performed_prsnl_id=t_record->phys_qual[d.seq].phys_id)
    AND orn.recon_type_flag IN (1, 2, 3))
  ORDER BY orn.encntr_id, orn.updt_dt_tm DESC
  HEAD orn.encntr_id
   null
  DETAIL
   IF (orn.recon_type_flag=1)
    t_record->phys_qual[d.seq].a_dta_cnt = (t_record->phys_qual[d.seq].a_dta_cnt+ 1), t_record->
    phys_qual[d.seq].admit_recon_dt_tm = orn.updt_dt_tm
   ELSEIF (orn.recon_type_flag=2)
    t_record->phys_qual[d.seq].t_dta_cnt = (t_record->phys_qual[d.seq].t_dta_cnt+ 1), t_record->
    phys_qual[d.seq].trans_recon_dt_tm = orn.updt_dt_tm
   ELSEIF (orn.recon_type_flag=3)
    t_record->phys_qual[d.seq].d_dta_cnt = (t_record->phys_qual[d.seq].d_dta_cnt+ 1), t_record->
    phys_qual[d.seq].disch_recon_dt_tm = orn.updt_dt_tm
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND ce.event_cd=home_med_recon_cd)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC, 0
  DETAIL
   t_record->phys_qual[d.seq].nurse_dt_tm = ce.event_end_dt_tm
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND ce.event_cd=home_med_recon_cd)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC, 0
  DETAIL
   t_record->phys_qual[d.seq].nurse_dt_tm = ce.event_end_dt_tm
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  time1 = datetimediff(cnvtdatetime(t_record->phys_qual[d.seq].admit_dt_tm),cnvtdatetime(t_record->
    phys_qual[d.seq].nurse_dt_tm,3))
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND ((ce.performed_prsnl_id+ 0)=t_record->phys_qual[d.seq].phys_id)
    AND ce.event_cd=admit_cd)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm
  HEAD ce.encntr_id
   time = datetimediff(cnvtdatetime(t_record->phys_qual[d.seq].admit_recon_dt_tm),cnvtdatetime(
     t_record->phys_qual[d.seq].nurse_dt_tm),3)
   IF (time <= 18)
    t_record->phys_qual[d.seq].a_18_hr_ind = "Y"
   ELSE
    t_record->phys_qual[d.seq].a_18_hr_ind = "N"
   ENDIF
   IF (time <= 24)
    t_record->phys_qual[d.seq].a_24_hr_ind = "Y"
   ELSE
    t_record->phys_qual[d.seq].a_24_hr_ind = "N"
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   order_recon orn
  PLAN (d)
   JOIN (orn
   WHERE (orn.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND orn.recon_type_flag=1)
  ORDER BY orn.encntr_id, orn.updt_dt_tm
  HEAD orn.encntr_id
   time = datetimediff(cnvtdatetime(t_record->phys_qual[d.seq].admit_dt_tm),cnvtdatetime(t_record->
     phys_qual[d.seq].nurse_dt_tm),3)
   IF (time <= 18)
    t_record->phys_qual[d.seq].a_18_hr_ind = "Y"
   ELSE
    t_record->phys_qual[d.seq].a_18_hr_ind = "N"
   ENDIF
   IF (time <= 24)
    t_record->phys_qual[d.seq].a_24_hr_ind = "Y"
   ELSE
    t_record->phys_qual[d.seq].a_24_hr_ind = "N"
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  trans_chk_encntr2 = t_record->phys_qual[d.seq].encntr_id, trans_chk_dt_tm2 = t_record->phys_qual[d
  .seq].trans_recon_dt_tm
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   encntr_loc_hist elh
  PLAN (d
   WHERE (t_record->phys_qual[d.seq].trans_recon_dt_tm != 0))
   JOIN (elh
   WHERE (elh.encntr_id=t_record->phys_qual[d.seq].encntr_id)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(t_record->phys_qual[d.seq].trans_recon_dt_tm)
    AND elh.end_effective_dt_tm >= cnvtdatetime(t_record->phys_qual[d.seq].trans_recon_dt_tm))
  ORDER BY trans_chk_encntr2, trans_chk_dt_tm2 DESC
  HEAD trans_chk_encntr2
   null
  HEAD trans_chk_dt_tm2
   time1 = datetimediff(cnvtdatetime(t_record->phys_qual[d.seq].trans_recon_dt_tm),elh
    .beg_effective_dt_tm,3)
   IF (time1 <= 12)
    t_record->phys_qual[d.seq].t_12_hr_ind = "Y"
   ELSE
    t_record->phys_qual[d.seq].t_12_hr_ind = "N"
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "medrec_phys_sum.xls"
  phys_name = p1.name_full_formatted, pat_name = p2.name_full_formatted
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   person p1,
   person p2,
   prsnl p
  PLAN (d)
   JOIN (p1
   WHERE (p1.person_id=t_record->phys_qual[d.seq].phys_id)
    AND p1.active_ind=1)
   JOIN (p2
   WHERE (p2.person_id=t_record->phys_qual[d.seq].person_id)
    AND p1.active_ind=1)
   JOIN (p
   WHERE p.person_id=p1.person_id
    AND p.active_ind=1)
  ORDER BY phys_name, p.person_id, pat_name,
   p2.person_id
  HEAD REPORT
   t_line = "Medical Reconciliation Physician Summary Report", col 0, t_line,
   row + 1, t_line = concat(format(cnvtdatetime(datetimeadd(sysdate,- (16))),"DD-MMM-YYYY;;Q")," to ",
    format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;Q"),char(9)), col 0,
   t_line, row + 1, t_line = concat("Physician Name",char(9),"Department",char(9),"Facility",
    char(9),"Patient Name",char(9),"Discharged",char(9),
    "Admit Date Time",char(9),"Discharge Date Time",char(9),
    "Admit Signed Within 18 hours of Admission",
    char(9),"Admit Signed Within 24 hours of Admission",char(9),"Number of Admit Rule Firings",char(9
     ),
    "Number of Admit Form Signings",char(9),"Transfer Signed Within 12 hours of Transfer",char(9),
    "Number of Transer Rule Firings",
    char(9),"Number of Transer Form Signings",char(9),"Number of Discharge Rule Firings",char(9),
    "Number of Discharge Form Signings",char(9)),
   col 0, t_line, row + 1
  HEAD phys_name
   null
  DETAIL
   CASE (uar_get_code_display(p.position_cd))
    OF "BHS Anesthesiology MD":
     department = "Anesthesiology"
    OF "BHS Cardiology MD":
     department = "Internal Medicine"
    OF "BHS Cardiac Surgery MD":
     department = "Surgery"
    OF "BHS Critical Care MD":
     department = "Internal Medicine"
    OF "BHS ER Medicine MD":
     department = "Emergency Medicine"
    OF "BHS Infectious Disease MD":
     department = "Internal Medicine"
    OF "BHS GI MD":
     department = "Internal Medicine"
    OF "BHS Urology MD":
     department = "Surgery"
    OF "BHS Thoracic MD":
     department = "Surgery"
    OF "BHS Trauma MD":
     department = "Surgery"
    OF "BHS Resident":
     department = "Resident"
    OF "BHS Oncology MD":
     department = "Internal Medicine"
    OF "BHS Neonatal MD":
     department = "Pediatrics"
    OF "BHS Neurology MD":
     department = "Internal Medicine"
    OF "BHS OB/GYN MD":
     department = "Ob/Gyn"
    OF "BHS Orthopedics MD":
     department = "Surgery"
    OF "BHS General Pediatrics MD":
     department = "Pediatrics"
    OF "BHS Psychiatry MD":
     department = "Psychiatry"
    OF "BHS Physiatry MD":
     department = "Internal Medicine"
    OF "BHS Pulmonary MD":
     department = "Internal Medicine"
    OF "BHS Radiology MD":
     department = "Radiology"
    OF "BHS Renal MD":
     department = "Internal Medicine"
    OF "BHS General Surgery MD":
     department = "Surgery"
    OF "BHS Midwife":
     department = "Ob/Gyn"
    OF "BHS Associate Professional":
     department = "Associate Provider"
    OF "BHS Physician (General Medicine)":
     department = "Internal Medicine"
    OF "BHS Medical Student":
     department = "Medical Student"
    ELSE
     department = "Other"
   ENDCASE
   IF ((t_record->phys_qual[d.seq].disch_ind=1))
    dis = "YES"
   ELSE
    dis = "NO"
   ENDIF
   t_line = concat(trim(phys_name),char(9),trim(department),char(9),trim(t_record->phys_qual[d.seq].
     facility),
    char(9),trim(pat_name),char(9),dis,char(9),
    format(t_record->phys_qual[d.seq].admit_dt_tm,"MMM-DD-YYYY HH:MM;;q"),char(9),format(t_record->
     phys_qual[d.seq].discharge_dt_tm,"MMM-DD-YYYY HH:MM;;q"),char(9),t_record->phys_qual[d.seq].
    a_18_hr_ind,
    char(9),t_record->phys_qual[d.seq].a_24_hr_ind,char(9),trim(cnvtstring(t_record->phys_qual[d.seq]
      .a_rule_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].a_dta_cnt)),char(9),t_record->phys_qual[d.seq].
    t_12_hr_ind,char(9),trim(cnvtstring(t_record->phys_qual[d.seq].t_rule_cnt)),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].t_dta_cnt)),char(9),trim(cnvtstring(t_record->
      phys_qual[d.seq].d_rule_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].d_dta_cnt)),char(9)), col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("medrec_phys_sum.xls")=1)
  SET subject_line = concat("Medrec Physician Summary Report ",format(cnvtdatetime(datetimeadd(
      sysdate,- (16))),"DD-MMM-YYYY;;Q")," to ",format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY;;Q"
    ))
  CALL emailfile("medrec_phys_sum.xls","medrec_phys_sum.xls",email_list,subject_line,1)
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO
