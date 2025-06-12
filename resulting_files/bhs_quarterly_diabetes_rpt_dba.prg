CREATE PROGRAM bhs_quarterly_diabetes_rpt:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 t_action_dt_tm = dq8
   1 prac_cnt = i4
   1 prac_qual[*]
     2 loc_id = f8
     2 loc_name = vc
     2 pat_cnt = i4
     2 one_hba1c_cnt = i4
     2 two_hba1c_cnt = i4
     2 ldl_cnt = i4
     2 neph_cnt = i4
     2 dial_retnal_cnt = i4
     2 foot_exam_cnt = i4
     2 asa_cnt = i4
     2 flu_vac_cnt = i4
     2 pnu_vac_cnt = i4
     2 hb_val_cnt = i4
     2 ldl_val_cnt = i4
     2 blood_pres_val_cnt = i4
     2 combo1_val_cnt = i4
     2 combo2_val_cnt = i4
   1 combo1_cnt = i4
   1 combo1_qual[*]
     2 pid = f8
     2 h_ind = i2
     2 l_ind = i2
     2 n_ind = i2
   1 combo2_cnt = i4
   1 combo2_qual[*]
     2 pid = f8
     2 h_ind = i2
     2 l_ind = i2
     2 bp_ind = i2
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 flu_ind = i2
     2 pnu_ind = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE month = i2
 DECLARE indx = i4
 IF (validate(request->batch_selection))
  SET t_record->t_action_dt_tm = cnvtdatetime(request->ops_date)
  SET month = month(cnvtdatetime(request->ops_date))
  IF ((t_record->t_action_dt_tm <= 0))
   SET month = month(cnvtdatetime(curdate,curtime3))
  ENDIF
  IF (((month=1) OR (((month=4) OR (((month=7) OR (month=10)) )) )) )
   SET email_list =  $1
  ELSE
   GO TO exit_script
  ENDIF
 ELSE
  SET email_list = "bob.kauffman@bhs.org"
 ENDIF
 DECLARE mf_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE hemo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CMONITORING"))
 DECLARE microalbumin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MICROALBUMIN"))
 DECLARE urine_prot_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROTEINURINERANDOM"))
 DECLARE urine_prot_24_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TOTALPROTEINURINE24HR"))
 DECLARE ldl1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE ldl2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCARDIAC"))
 DECLARE ldl3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIRECTLOWDENSITYLIPOPROTEIN"))
 DECLARE sbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SYSTOLICBLOODPRESSURE"))
 DECLARE dbp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DIASTOLICBLOODPRESSURE")
  )
 DECLARE aspirin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ASPIRIN"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE mf_pneu_vac_cd01 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL7VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd02 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL13VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd05 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL23VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd06 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCOLDTERM"))
 DECLARE mf_pneu_vac_cd11 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALCONJUGATEPCV7OLDTERM"))
 DECLARE mf_pneu_vac_cd12 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALPOLYPPV23OLDTERM"))
 DECLARE mf_pneu_vac_cd13 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINEOLDTERM"))
 DECLARE mf_pneu_vac_cd14 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOVAX23OLDTERM"))
 DECLARE mf_pneu_vac_cd15 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREVNARINJOLDTERM"))
 DECLARE mf_pneu_vac_cd16 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREVNAROLDTERM"))
 DECLARE mf_influ_h1n1_inact = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEH1N1INACTIVE"))
 DECLARE mf_influ_h1n1_live = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEH1N1LIVE"))
 DECLARE mf_influ_vacc_inact = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEINACTIVATED"))
 DECLARE mf_influ_vacc_triv = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINELIVETRIVALENT"))
 DECLARE mf_influ_vacc_old = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEOLDTERM"))
 DECLARE mf_influ_vac_cd01 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "AFLURIAOLDTERM"))
 DECLARE mf_influ_vac_cd02 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUARIXOLDTERM"))
 DECLARE mf_influ_vac_cd03 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLULAVALOLDTERM"))
 DECLARE mf_influ_vac_cd04 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUMISTOLDTERM"))
 DECLARE mf_influ_vac_cd05 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUVIRINOLDTERM"))
 DECLARE mf_influ_vac_cd06 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUVIRINPRESERVATIVEFREEOLDTERM"))
 DECLARE mf_influ_vac_cd07 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEOLDTERM"))
 DECLARE mf_influ_vac_cd08 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEOLDTERM"))
 DECLARE mf_influ_vac_cd09 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEPEDIOLDTERM"))
 DECLARE mf_influ_vac_cd10 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAINACTIVEIMOLDTERM"))
 DECLARE mf_influ_vac_cd11 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZALIVEINTRANASALOLDTERM"))
 DECLARE dclcom = vc WITH protect, noconstant("")
 DECLARE t_line = vc WITH protect, noconstant("")
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE ldl_gt_100_ind = i2 WITH protect, noconstant(0)
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
     IF (mod(t_record->pat_cnt,50)=1)
      stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 49))
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
      AND ce.clinsig_updt_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365))
      AND ce.view_level=1)
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD REPORT
     count = 0, seven_ind = 0, ce_id = 0
    HEAD ce.person_id
     count = 0, seven_ind = 0, ce_id = 0,
     count = (count+ 1)
     IF (cnvtint(ce.result_val) < 7)
      seven_ind = 1
     ENDIF
     ce_id = ce.clinical_event_id
    DETAIL
     IF (ce.clinical_event_id != ce_id)
      count = (count+ 1)
     ENDIF
    FOOT  ce.person_id
     t_record->prac_qual[i].one_hba1c_cnt = (t_record->prac_qual[i].one_hba1c_cnt+ 1)
     IF (count >= 2)
      t_record->prac_qual[i].two_hba1c_cnt = (t_record->prac_qual[i].two_hba1c_cnt+ 1), t_record->
      combo1_cnt = (t_record->combo1_cnt+ 1), stat = alterlist(t_record->combo1_qual,t_record->
       combo1_cnt),
      t_record->combo1_qual[t_record->combo1_cnt].pid = ce.person_id, t_record->combo1_qual[t_record
      ->combo1_cnt].h_ind = 1
     ENDIF
     IF (seven_ind=1)
      t_record->prac_qual[i].hb_val_cnt = (t_record->prac_qual[i].hb_val_cnt+ 1), t_record->
      combo2_cnt = (t_record->combo2_cnt+ 1), stat = alterlist(t_record->combo2_qual,t_record->
       combo2_cnt),
      t_record->combo2_qual[t_record->combo2_cnt].pid = ce.person_id, t_record->combo2_qual[t_record
      ->combo2_cnt].h_ind = 1
     ENDIF
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   CALL echo(build("t_record->prac_qual[i].two_hba1c_cnt:",t_record->prac_qual[1].two_hba1c_cnt))
   CALL echo(build(" t_record->prac_qual[i].one_hba1c_cnt:",t_record->prac_qual[1].one_hba1c_cnt))
   CALL echo(build("  t_record->prac_qual[i].hb_val_cnt:",t_record->prac_qual[1].hb_val_cnt))
   CALL echo(build("t_record->prac_qual[d.seq].pat_cnt:",t_record->prac_qual[1].pat_cnt))
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
       t_record->combo1_cnt,ce.person_id,t_record->combo1_qual[indx].pid)
      IF (idx=0)
       t_record->combo1_cnt = (t_record->combo1_cnt+ 1), stat = alterlist(t_record->combo1_qual,
        t_record->combo1_cnt), t_record->combo1_qual[t_record->combo1_cnt].pid = ce.person_id,
       t_record->combo1_qual[t_record->combo1_cnt].n_ind = 1
      ELSE
       t_record->combo1_qual[idx].n_ind = 1
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
      AND hes.expect_step_name="Diabetes Dilated Retinal Eye Exam")
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
      AND hem.parent_entity_name="HM_EXPECT_STEP"
      AND hem.active_ind=1
      AND hem.active_status_dt_tm > datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.expect_step_name="Diabetes Comprehensive Foot Exam")
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
      AND ce.event_cd IN (mf_influ_h1n1_inact, mf_influ_h1n1_live, mf_influ_vacc_inact,
     mf_influ_vacc_triv, mf_influ_vacc_old,
     mf_influ_vac_cd01, mf_influ_vac_cd02, mf_influ_vac_cd03, mf_influ_vac_cd04, mf_influ_vac_cd05,
     mf_influ_vac_cd06, mf_influ_vac_cd07, mf_influ_vac_cd08, mf_influ_vac_cd09, mf_influ_vac_cd10,
     mf_influ_vac_cd11)
      AND  NOT (ce.result_status_cd IN (mf_not_done_cd, mf_inerror_cd))
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
    ORDER BY ce.person_id
    HEAD ce.person_id
     t_record->prac_qual[i].flu_vac_cnt = (t_record->prac_qual[i].flu_vac_cnt+ 1), idx = locateval(
      indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].pid), t_record->pat_qual[idx].
     flu_ind = 1
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     hm_expect_mod hem,
     hm_expect_step hes
    PLAN (d)
     JOIN (hem
     WHERE hem.person_id=d.pid
      AND hem.parent_entity_name="HM_EXPECT_STEP"
      AND hem.updt_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
     JOIN (hes
     WHERE hes.expect_step_id=hem.parent_entity_id
      AND hes.expect_step_name="Influenza")
    ORDER BY hem.person_id
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].pid)
     IF ((t_record->pat_qual[idx].flu_ind=0))
      t_record->prac_qual[i].flu_vac_cnt = (t_record->prac_qual[i].flu_vac_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd IN (mf_pneu_vac_cd01, mf_pneu_vac_cd02, mf_pneu_vac_cd05, mf_pneu_vac_cd06,
     mf_pneu_vac_cd11,
     mf_pneu_vac_cd12, mf_pneu_vac_cd13, mf_pneu_vac_cd14, mf_pneu_vac_cd15, mf_pneu_vac_cd16)
      AND  NOT (ce.result_status_cd IN (mf_not_done_cd, mf_inerror_cd)))
    ORDER BY ce.person_id
    HEAD ce.person_id
     t_record->prac_qual[i].pnu_vac_cnt = (t_record->prac_qual[i].pnu_vac_cnt+ 1), idx = locateval(
      indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].pid), t_record->pat_qual[idx].
     pnu_ind = 1
    WITH orahint("index(CE XIE9CLINICAL_EVENT)")
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
      AND hes.expect_step_name="Pneumococcal")
    ORDER BY hem.person_id
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].pid)
     IF ((t_record->pat_qual[idx].pnu_ind=0))
      t_record->prac_qual[i].pnu_vac_cnt = (t_record->prac_qual[i].pnu_vac_cnt+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pat_temp_d d,
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE ce.person_id=d.pid
      AND ce.event_cd IN (ldl1_cd, ldl2_cd, ldl3_cd)
      AND ce.event_end_dt_tm >= datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
    ORDER BY ce.person_id
    HEAD ce.person_id
     ldl_gt_100_ind = 0
    DETAIL
     IF (cnvtint(ce.result_val) < 100)
      ldl_gt_100_ind = 1
     ENDIF
    FOOT  ce.person_id
     t_record->prac_qual[i].ldl_cnt = (t_record->prac_qual[i].ldl_cnt+ 1), idx = locateval(indx,1,
      t_record->combo1_cnt,ce.person_id,t_record->combo1_qual[indx].pid)
     IF (idx=0)
      t_record->combo1_cnt = (t_record->combo1_cnt+ 1), stat = alterlist(t_record->combo1_qual,
       t_record->combo1_cnt), t_record->combo1_qual[t_record->combo1_cnt].pid = ce.person_id,
      t_record->combo1_qual[t_record->combo1_cnt].l_ind = 1
     ELSE
      t_record->combo1_qual[idx].l_ind = 1
     ENDIF
     IF (ldl_gt_100_ind=1)
      t_record->prac_qual[i].ldl_val_cnt = (t_record->prac_qual[i].ldl_val_cnt+ 1), idx = locateval(
       indx,1,t_record->combo2_cnt,ce.person_id,t_record->combo2_qual[indx].pid)
      IF (idx=0)
       t_record->combo2_cnt = (t_record->combo2_cnt+ 1), stat = alterlist(t_record->combo2_qual,
        t_record->combo2_cnt), t_record->combo2_qual[t_record->combo2_cnt].pid = ce.person_id,
       t_record->combo2_qual[t_record->combo2_cnt].l_ind = 1
      ELSE
       t_record->combo2_qual[idx].l_ind = 1
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
       = locateval(indx,1,t_record->combo2_cnt,ce.person_id,t_record->combo2_qual[indx].pid)
      IF (idx=0)
       t_record->combo2_cnt = (t_record->combo2_cnt+ 1), stat = alterlist(t_record->combo2_qual,
        t_record->combo2_cnt), t_record->combo2_qual[t_record->combo2_cnt].pid = ce.person_id,
       t_record->combo2_qual[t_record->combo2_cnt].bp_ind = 1
      ELSE
       t_record->combo2_qual[idx].bp_ind = 1
      ENDIF
     ENDIF
    WITH orahint("index(CE XIE9CLINICAL_EVENT),index(CE1 XIE9CLINICAL_EVENT)")
   ;end select
   FOR (q = 1 TO t_record->combo1_cnt)
     IF ((t_record->combo1_qual[q].l_ind=1)
      AND (t_record->combo1_qual[q].h_ind=1)
      AND (t_record->combo1_qual[q].n_ind=1))
      SET t_record->prac_qual[i].combo1_val_cnt = (t_record->prac_qual[i].combo1_val_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (r = 1 TO t_record->combo2_cnt)
     IF ((t_record->combo2_qual[r].l_ind=1)
      AND (t_record->combo2_qual[r].h_ind=1)
      AND (t_record->combo2_qual[r].bp_ind=1))
      SET t_record->prac_qual[i].combo2_val_cnt = (t_record->prac_qual[i].combo2_val_cnt+ 1)
     ENDIF
   ENDFOR
   SET t_record->combo1_cnt = 0
   SET stat = alterlist(t_record->combo1_qual,t_record->combo1_cnt)
   SET t_record->combo2_cnt = 0
   SET stat = alterlist(t_record->combo2_qual,t_record->combo2_cnt)
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
   row + 1, t_line = concat(char(9),char(9),
    "Percentage of Diabetic Patients with the following in the past year:"), col 0,
   t_line, row + 1, t_line = concat("Practice",char(9),"Total Diabetic Patients",char(9),"1 HbA1c",
    char(9),"2 HbA1c",char(9),"LDL",char(9),
    "Nephropathy Screening",char(9),"Dialated Retinal Eye Exam",char(9),"Foot Exam",
    char(9),"Currently On ASA",char(9),"Influenza Vaccine in Past 12 Months",char(9),
    "Pneumococcal Vaccine (any time)",char(9),"HbA1c < 7",char(9),"LDL < 100",
    char(9),"SBP < 130 and DBP < 80",char(9),"2 HbA1c + 1 LDL + 1 Nephropathy Screening",char(9),
    "HbA1c < 7 + LDL < 100 + SBP < 130 + DBP < 80"),
   col 0, t_line, row + 1
  HEAD loc_name
   p1 = (100 * (cnvtreal(t_record->prac_qual[d.seq].one_hba1c_cnt)/ t_record->prac_qual[d.seq].
   pat_cnt)), p2 = (100 * (cnvtreal(t_record->prac_qual[d.seq].two_hba1c_cnt)/ t_record->prac_qual[d
   .seq].pat_cnt)), p3 = (100 * (cnvtreal(t_record->prac_qual[d.seq].ldl_cnt)/ t_record->prac_qual[d
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
   p13 = (100 * (cnvtreal(t_record->prac_qual[d.seq].combo1_val_cnt)/ t_record->prac_qual[d.seq].
   pat_cnt)), p14 = (100 * (cnvtreal(t_record->prac_qual[d.seq].combo2_val_cnt)/ t_record->prac_qual[
   d.seq].pat_cnt)), t_line = concat(loc_name,char(9),trim(cnvtstring(t_record->prac_qual[d.seq].
      pat_cnt)),char(9),trim(cnvtstring(p1)),
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
 SET reply->status_data[1].status = "S"
END GO
