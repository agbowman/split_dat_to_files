CREATE PROGRAM bhs_quartly_diabetes_rpt:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 prac_cnt = i4
   1 prac_qual[*]
     2 loc_id = f8
     2 loc_name = vc
     2 pat_cnt = i4
     2 one_hba1c_cnt = i4
     2 two_hba1c_cnt = i4
     2 lp_cnt = i4
     2 neph_cnt = i4
     2 dial_retnal_cnt = i4
     2 foot_exam_cnt = i4
     2 asa_cnt = i4
     2 flu_vac_cnt = i4
     2 pnu_vac_cnt = i4
     2 hb_val_cnt = i4
     2 ldl_val_cnt = i4
     2 blood_pres_val_cnt = i4
     2 hb_flp_micro_combo_cnt = i4
     2 combo_val_cnt = i4
   1 l_combo_cnt = i4
   1 l_combo_qual[*]
     2 pid = f8
     2 h_ind = i2
     2 l_ind = i2
     2 n_ind = i2
   1 combo_cnt = i4
   1 combo_qual[*]
     2 pid = f8
     2 h_ind = i2
     2 l_ind = i2
     2 bp_ind = i2
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
 )
 DECLARE month = i2
 IF (validate(request->batch_selection))
  SET month = month(cnvtdatetime(request->ops_date))
  IF ((t_record->action_dt_tm <= 0))
   SET month = month(cnvtdatetime(curdate,curtime3))
  ENDIF
  IF (((month=1) OR (((month=4) OR (((month=7) OR (month=10)) )) )) )
   SET email_list =  $1
  ELSE
   GO TO exit_script
  ENDIF
 ELSE
  SET email_list = "anthony.jacobson@bhs.org"
 ENDIF
 DECLARE hemo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA1C"))
 DECLARE lipid_panel_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LIPIDPANEL"))
 DECLARE microalbumin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MICROALBUMIN"))
 DECLARE urine_prot_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROTEINURINERANDOM"))
 DECLARE urine_prot_24_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TOTALPROTEINURINE24HR"))
 DECLARE ldl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE sbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SYSTOLICBLOODPRESSURE"))
 DECLARE dbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DIASTOLICBLOODPRESSURE")
  )
 DECLARE pneu_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINE"))
 DECLARE flu_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINE"))
 DECLARE aspirin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ASPIRIN"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE t_line = vc
 DECLARE indx = i4
 SELECT INTO "nl:"
  FROM bhs_practice_location bpl
  PLAN (bpl
   WHERE bpl.location_description IN ("BMP Deerfield Adult Medicine",
   "BMP East Longmeadow Adult Medicine", "BMP Franklin Adult Medicine", "BMP Ludlow Adult Medicine",
   "BMP Northern Edge Adult Medicine",
   "BMP Pioneer Valley Family Medicine", "BMP Quabbin Adult Medicine",
   "BMP South Hadley Adult Medicine", "BMP West Side Adult Medicine", "BMP Wilbraham Adult Medicine",
   "Baystate Brightwood Health Center/Centro de Salud",
   "Baystate High Street Health Center Adult Medicine",
   "Baystate Mason Square Neighborhood Health Center"))
  DETAIL
   t_record->prac_cnt = (t_record->prac_cnt+ 1), stat = alterlist(t_record->prac_qual,t_record->
    prac_cnt), t_record->prac_qual[t_record->prac_cnt].loc_id = bpl.location_id,
   t_record->prac_qual[t_record->prac_cnt].loc_name = bpl.location_description
  WITH nocounter
 ;end select
 FOR (i = 1 TO t_record->prac_cnt)
   SELECT INTO "nl:"
    FROM bhs_physician_location bpl,
     bhs_problem_registry bpr
    PLAN (bpl
     WHERE (bpl.location_id=t_record->prac_qual[i].loc_id))
     JOIN (bpr
     WHERE bpr.pcp_id=bpl.person_id
      AND bpr.problem="DIABETES"
      AND bpr.active_ind=1)
    ORDER BY bpr.person_id
    HEAD bpr.person_id
     t_record->prac_qual[i].pat_cnt = (t_record->prac_qual[i].pat_cnt+ 1), t_record->pat_cnt = (
     t_record->pat_cnt+ 1)
     IF (mod(t_record->pat_cnt,5000)=1)
      stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 4999))
     ENDIF
     t_record->pat_qual[t_record->pat_cnt].pid = bpr.person_id
    FOOT REPORT
     stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
    WITH maxcol = 100
   ;end select
   SELECT INTO TABLE pat_temp_d
    pid = t_record->pat_qual[d.seq].pid
    FROM (dummyt d  WITH seq = t_record->pat_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd=hemo_cd
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365))
      AND ce.event_tag="Hemoglobin A1C")
    ORDER BY ce.person_id, ce.clinical_event_id
    HEAD ce.person_id
     count = 0, seven_ind = 0
    HEAD ce.clinical_event_id
     count = (count+ 1)
     IF (cnvtint(ce.result_val) < 7)
      seven_ind = 1
     ENDIF
    FOOT  ce.person_id
     IF (count >= 1)
      t_record->prac_qual[i].one_hba1c_cnt = (t_record->prac_qual[i].one_hba1c_cnt+ 1), t_record->
      l_combo_cnt = (t_record->l_combo_cnt+ 1), stat = alterlist(t_record->l_combo_qual,t_record->
       l_combo_cnt),
      t_record->l_combo_qual[t_record->l_combo_cnt].pid = ce.person_id, t_record->l_combo_qual[
      t_record->l_combo_cnt].h_ind = 1
     ENDIF
     IF (count >= 2)
      t_record->prac_qual[i].two_hba1c_cnt = (t_record->prac_qual[i].two_hba1c_cnt+ 1)
     ENDIF
     IF (seven_ind=1)
      t_record->prac_qual[i].hb_val_cnt = (t_record->prac_qual[i].hb_val_cnt+ 1), t_record->combo_cnt
       = (t_record->combo_cnt+ 1), stat = alterlist(t_record->combo_qual,t_record->combo_cnt),
      t_record->combo_qual[t_record->combo_cnt].pid = ce.person_id, t_record->combo_qual[t_record->
      combo_cnt].h_ind = 1
     ENDIF
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd=lipid_panel_cd
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
    ORDER BY ce.person_id
    HEAD ce.person_id
     t_record->prac_qual[i].lp_cnt = (t_record->prac_qual[i].lp_cnt+ 1), idx = locateval(indx,1,
      t_record->l_combo_cnt,ce.person_id,t_record->l_combo_qual[indx].pid)
     IF (idx=0)
      t_record->l_combo_cnt = (t_record->l_combo_cnt+ 1), stat = alterlist(t_record->l_combo_qual,
       t_record->l_combo_cnt), t_record->l_combo_qual[t_record->l_combo_cnt].pid = ce.person_id,
      t_record->l_combo_qual[t_record->l_combo_cnt].l_ind = 1
     ELSE
      t_record->l_combo_qual[idx].l_ind = 1
     ENDIF
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce,
     clinical_event ce1,
     clinical_event ce2
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=outerjoin(d.pid)
      AND ce.event_cd=outerjoin(microalbumin_cd)
      AND ce.event_end_dt_tm >= outerjoin(datetimeadd(cnvtdatetime(curdate,curtime3),- (365))))
     JOIN (ce1
     WHERE ce1.person_id=outerjoin(ce.person_id)
      AND ce1.event_cd=outerjoin(urine_prot_cd)
      AND ce1.event_end_dt_tm >= outerjoin(datetimeadd(cnvtdatetime(curdate,curtime3),- (365))))
     JOIN (ce2
     WHERE ce2.person_id=outerjoin(ce1.person_id)
      AND ce2.event_cd=outerjoin(urine_prot_24_cd)
      AND ce2.event_end_dt_tm >= outerjoin(datetimeadd(cnvtdatetime(curdate,curtime3),- (365))))
    ORDER BY d.pid
    HEAD d.pid
     IF (((nullind(ce.person_id)=0) OR (((nullind(ce1.person_id)=0) OR (nullind(ce2.person_id)=0))
     )) )
      t_record->prac_qual[i].neph_cnt = (t_record->prac_qual[i].neph_cnt+ 1), idx = locateval(indx,1,
       t_record->l_combo_cnt,ce.person_id,t_record->l_combo_qual[indx].pid)
      IF (idx=0)
       t_record->l_combo_cnt = (t_record->l_combo_cnt+ 1), stat = alterlist(t_record->l_combo_qual,
        t_record->l_combo_cnt), t_record->l_combo_qual[t_record->l_combo_cnt].pid = ce.person_id,
       t_record->l_combo_qual[t_record->l_combo_cnt].n_ind = 1
      ELSE
       t_record->l_combo_qual[idx].n_ind = 1
      ENDIF
     ENDIF
    WITH orahint(
      "index(CE XIE9CLINICAL_EVENT),index(CE1 XIE9CLINICAL_EVENT),index(CE2 XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d)
     JOIN (hem
     WHERE hem.person_id=d.pid
      AND hem.parent_entity_name="HM_EXPECT_STEP")
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.step_meaning="Diabetes Dilated Retinal Eye Exam")
    ORDER BY hem.person_id
    HEAD hem.person_id
     t_record->prac_qual[i].dial_retnal_cnt = (t_record->prac_qual[i].dial_retnal_cnt+ 1)
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d)
     JOIN (hem
     WHERE hem.person_id=d.pid
      AND hem.parent_entity_name="HM_EXPECT_STEP")
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.step_meaning="Diabetes Comprehensive Foot Exam")
    ORDER BY hem.person_id
    HEAD hem.person_id
     t_record->prac_qual[i].foot_exam_cnt = (t_record->prac_qual[i].foot_exam_cnt+ 1)
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     orders o
    PLAN (d)
     JOIN (o
     WHERE o.person_id=d.pid
      AND o.catalog_cd=aspirin_cd
      AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
     future_cd))
    HEAD o.person_id
     t_record->prac_qual[i].asa_cnt = (t_record->prac_qual[i].asa_cnt+ 1)
    WITH orahint("index(O XIE99ORDERS)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd=flu_vac_cd
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
    ORDER BY ce.person_id
    HEAD ce.person_id
     t_record->prac_qual[i].flu_vac_cnt = (t_record->prac_qual[i].flu_vac_cnt+ 1)
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd=pneu_vac_cd)
    ORDER BY ce.person_id
    HEAD ce.person_id
     t_record->prac_qual[i].pnu_vac_cnt = (t_record->prac_qual[i].pnu_vac_cnt+ 1)
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd=ldl_cd
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
    ORDER BY ce.person_id
    HEAD ce.person_id
     ldl_ind = 0
    DETAIL
     IF (cnvtint(ce.result_val) < 100)
      ldl_ind = 1
     ENDIF
    FOOT  ce.person_id
     IF (ldl_ind=1)
      t_record->prac_qual[i].ldl_val_cnt = (t_record->prac_qual[i].ldl_val_cnt+ 1), idx = locateval(
       indx,1,t_record->combo_cnt,ce.person_id,t_record->combo_qual[indx].pid)
      IF (idx=0)
       t_record->combo_cnt = (t_record->combo_cnt+ 1), stat = alterlist(t_record->combo_qual,t_record
        ->combo_cnt), t_record->combo_qual[t_record->combo_cnt].pid = ce.person_id,
       t_record->combo_qual[t_record->combo_cnt].l_ind = 1
      ELSE
       t_record->combo_qual[idx].l_ind = 1
      ENDIF
     ENDIF
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce,
     clinical_event ce1
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd=sbp_cd
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
     JOIN (ce1
     WHERE ce1.person_id=d.pid
      AND ce1.event_cd=dbp_cd
      AND ce1.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365))
      AND ce1.parent_event_id=ce.parent_event_id)
    ORDER BY ce.person_id, ce.parent_event_id
    HEAD ce.person_id
     bp_ind = 0
    DETAIL
     IF (cnvtint(ce.result_val) < 130
      AND cnvtint(ce1.result_val) < 80)
      bp_ind = 1
     ENDIF
    FOOT  ce.person_id
     IF (bp_ind=1)
      t_record->prac_qual[i].blood_pres_val_cnt = (t_record->prac_qual[i].blood_pres_val_cnt+ 1), idx
       = locateval(indx,1,t_record->combo_cnt,ce.person_id,t_record->combo_qual[indx].pid)
      IF (idx=0)
       t_record->combo_cnt = (t_record->combo_cnt+ 1), stat = alterlist(t_record->combo_qual,t_record
        ->combo_cnt), t_record->combo_qual[t_record->combo_cnt].pid = ce.person_id,
       t_record->combo_qual[t_record->combo_cnt].bp_ind = 1
      ELSE
       t_record->combo_qual[idx].bp_ind = 1
      ENDIF
     ENDIF
    WITH orahint("index(CE XIE9CLINICAL_EVENT),index(CE1 XIE9CLINICAL_EVENT)")
   ;end select
   FOR (q = 1 TO t_record->l_combo_cnt)
     IF ((t_record->l_combo_qual[q].l_ind=1)
      AND (t_record->l_combo_qual[q].h_ind=1)
      AND (t_record->l_combo_qual[q].n_ind=1))
      SET t_record->prac_qual[i].hb_flp_micro_combo_cnt = (t_record->prac_qual[i].
      hb_flp_micro_combo_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (r = 1 TO t_record->combo_cnt)
     IF ((t_record->combo_qual[r].l_ind=1)
      AND (t_record->combo_qual[r].h_ind=1)
      AND (t_record->combo_qual[r].bp_ind=1))
      SET t_record->prac_qual[i].combo_val_cnt = (t_record->prac_qual[i].combo_val_cnt+ 1)
     ENDIF
   ENDFOR
   SET t_record->l_combo_cnt = 0
   SET stat = alterlist(t_record->l_combo_qual,t_record->l_combo_cnt)
   SET t_record->combo_cnt = 0
   SET stat = alterlist(t_record->combo_qual,t_record->combo_cnt)
   SET t_record->pat_cnt = 0
   SET stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
 ENDFOR
 SELECT INTO "quarterly_diabetes_report.xls"
  loc_name = t_record->prac_qual[d.seq].loc_name
  FROM (dummyt d  WITH seq = t_record->prac_cnt)
  PLAN (d)
  ORDER BY loc_name
  HEAD REPORT
   t_line = concat("Quarterly BMP Diabetes Report ",format(cnvtdatetime(curdate,curtime),
     "MMM-YYYY;;Q")), col 0, t_line,
   row + 1, t_line = concat(char(9),char(9),"Percentage of Patients with:"), col 0,
   t_line, row + 1, t_line = concat("Practice",char(9),"Total Diabetic Patients",char(9),
    "1 HbA1c in Past 12 Months",
    char(9),"2 HbA1c in Past 12 Months",char(9),"Lipid Profile in Past 12 Months",char(9),
    "Nephropathy Screening in Past 12 Months",char(9),"Dialated Retinal Eye Exam in Past 12 Months",
    char(9),"Foot Exam in Past 12 Months",
    char(9),"On ASA",char(9),"Influenza Vaccine in Past 12 Months",char(9),
    "Pneumococcal Vaccine (any time)",char(9),"HbA1c < 7",char(9),"LDL < 100",
    char(9),"SBP < 130 and DBP < 80",char(9),"1 HbA1c + 1 LP + Microalbumin",char(9),
    "HbA1c < 7 + LDL < 100 + SBP < 130 + DBP < 80",char(9)),
   col 0, t_line, row + 1
  HEAD loc_name
   p1 = (100 * (cnvtreal(t_record->prac_qual[d.seq].one_hba1c_cnt)/ t_record->prac_qual[d.seq].
   pat_cnt)), p2 = (100 * (cnvtreal(t_record->prac_qual[d.seq].two_hba1c_cnt)/ t_record->prac_qual[d
   .seq].pat_cnt)), p3 = (100 * (cnvtreal(t_record->prac_qual[d.seq].lp_cnt)/ t_record->prac_qual[d
   .seq].pat_cnt)),
   p4 = (100 * (cnvtreal(t_record->prac_qual[d.seq].neph_cnt)/ t_record->prac_qual[d.seq].pat_cnt)),
   p5 = (100 * (cnvtreal(t_record->prac_qual[d.seq].dial_retnal_cnt)/ t_record->prac_qual[d.seq].
   pat_cnt)), p6 = (100 * (cnvtreal(t_record->prac_qual[d.seq].foot_exam_cnt)/ t_record->prac_qual[d
   .seq].pat_cnt)),
   p7 = (100 * (cnvtreal(t_record->prac_qual[d.seq].asa_cnt)/ t_record->prac_qual[d.seq].pat_cnt)),
   p8 = (100 * (cnvtreal(t_record->prac_qual[d.seq].flu_vac_cnt)/ t_record->prac_qual[d.seq].pat_cnt)
   ), p9 = (100 * (cnvtreal(t_record->prac_qual[d.seq].pnu_vac_cnt)/ t_record->prac_qual[d.seq].
   pat_cnt)),
   p10 = (100 * (cnvtreal(t_record->prac_qual[d.seq].hb_val_cnt)/ t_record->prac_qual[d.seq].pat_cnt)
   ), p11 = (100 * (cnvtreal(t_record->prac_qual[d.seq].ldl_val_cnt)/ t_record->prac_qual[d.seq].
   pat_cnt)), p12 = (100 * (cnvtreal(t_record->prac_qual[d.seq].blood_pres_val_cnt)/ t_record->
   prac_qual[d.seq].pat_cnt)),
   p13 = (100 * (cnvtreal(t_record->prac_qual[d.seq].hb_flp_micro_combo_cnt)/ t_record->prac_qual[d
   .seq].pat_cnt)), p14 = (100 * (cnvtreal(t_record->prac_qual[d.seq].combo_val_cnt)/ t_record->
   prac_qual[d.seq].pat_cnt)), t_line = concat(loc_name,char(9),trim(cnvtstring(t_record->prac_qual[d
      .seq].pat_cnt)),char(9),trim(cnvtstring(p1)),
    char(9),trim(cnvtstring(p2)),char(9),trim(cnvtstring(p3)),char(9),
    trim(cnvtstring(p4)),char(9),trim(cnvtstring(p5)),char(9),trim(cnvtstring(p6)),
    char(9),trim(cnvtstring(p7)),char(9),trim(cnvtstring(p8)),char(9),
    trim(cnvtstring(p9)),char(9),trim(cnvtstring(p10)),char(9),trim(cnvtstring(p11)),
    char(9),trim(cnvtstring(p12)),char(9),trim(cnvtstring(p13)),char(9),
    trim(cnvtstring(p14)),char(9)),
   col 0, t_line, row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("quarterly_diabetes_report.xls")=1)
  SET subject_line = "Quarterly BMP Diabetes Report"
  CALL emailfile("quarterly_diabetes_report.xls","quarterly_diabetes_report.xls",email_list,
   subject_line,1)
 ENDIF
 DROP TABLE pat_temp_d
 SET dclcom = "rm -f pat_temp_d*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
#exit_script
END GO
