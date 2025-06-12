CREATE PROGRAM al_bhs_rpt_aco_measure:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility:" = 0,
  "Nurse Unit:" = 0
  WITH outdev, mf_facility, mf_nurs_unit
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_inprocess_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE mf_med_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE mf_activity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ACTIVITY"))
 DECLARE mf_ptactivitytype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PTACTIVITYTYPE"))
 DECLARE mf_bedrest_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",103445,"BEDREST"))
 DECLARE mf_bedrestwithbrp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",103445,
   "BEDRESTWITHBRP"))
 DECLARE mf_bradenscore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BRADENSCORE")
  )
 DECLARE mf_camscore_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CAMSCORE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_restraintsmedsurg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSMEDSURG"))
 DECLARE mf_otevaltreat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"OTEVALTREAT"
   ))
 DECLARE mf_ptevaltreat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PTEVALTREAT"
   ))
 DECLARE mf_ottreatment_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"OTTREATMENT"
   ))
 DECLARE mf_pttreatment_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PTTREATMENT"
   ))
 DECLARE mf_restraintsviolent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSVIOLENTSELFDESTRUCTIVE"))
 DECLARE mf_restraintspsych_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "RESTRAINTSPSYCH"))
 DECLARE mf_cathetersing_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERSINGLELUMENINDWELLINGURINARY"))
 DECLARE mf_cathetercoude_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERCOUDE"))
 DECLARE mf_catheterexternalurinary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETEREXTERNALURINARY"))
 DECLARE mf_catheterfoleythreeway_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERFOLEYTHREEWAY"))
 DECLARE mf_cathetertexas_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERTEXAS"))
 DECLARE mf_catheterfoley_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CATHETERFOLEY"))
 DECLARE mf_hisoffalls_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYOFFALLSINLAST6MONTHS"))
 DECLARE mf_advdir_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ADVANCEDIRECTIVE")
  )
 DECLARE mf_yes_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14769,"YES"))
 DECLARE mf_yesof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14769,"YESONFILE"))
 DECLARE mf_yesnof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14769,"YESNOTONFILE"))
 DECLARE mf_inerror1_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN ERROR"))
 DECLARE mf_inerror2_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE mf_inerror3_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE mf_inerror4_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mf_inprogress_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
 DECLARE mf_unauth_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"UNAUTH"))
 DECLARE mf_notdone_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_cancelled_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"CANCELLED"))
 DECLARE mf_inlab_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN LAB"))
 DECLARE mf_rejected_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"REJECTED"))
 DECLARE mf_unknown_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"UNKNOWN"))
 DECLARE mf_placeholder_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE mi_advdir_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_med_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cam_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD pinfo
 RECORD pinfo(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_person_fname = vc
     2 s_person_lname = vc
     2 s_person_name = vc
     2 s_person_dob = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_encntr_type = vc
     2 s_room = vc
     2 s_nurs_unit = vc
     2 s_age = vc
     2 s_admit_dt_tm = vc
     2 f_length_of_stay = f8
     2 s_hist_of_dimentia = vc
     2 s_bedrest = vc
     2 s_braden_score = vc
     2 s_cam_score = vc
     2 s_cam_result = vc
     2 s_cam_score2 = vc
     2 s_cam_result2 = vc
     2 s_pt_ord = vc
     2 s_ot_ord = vc
     2 s_res_ord = vc
     2 s_cath_ord = vc
     2 s_hist_fall = vc
     2 s_adv_dir = vc
     2 l_dcnt = i4
     2 diag[*]
       3 f_diag_id = f8
       3 s_nomen_string = vc
       3 s_source_identifier = vc
     2 l_pcnt = i4
     2 prob[*]
       3 f_prob_id = f8
       3 s_nomen_string = vc
       3 s_source_identifier = vc
     2 l_mcnt = i4
     2 meds[*]
       3 f_order_id = f8
       3 f_catalog_cd = f8
       3 s_mnemonic = vc
     2 l_rmcnt = i4
     2 rmeds[*]
       3 f_order_id = f8
       3 f_catalog_cd = f8
       3 s_mnemonic = vc
 ) WITH protect
 FREE RECORD med
 RECORD med(
   1 l_cnt = i4
   1 qual[*]
     2 f_catalog_cd = f8
     2 s_catalog_disp = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (e
   WHERE e.reg_dt_tm IS NOT null
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_observation_cd)
    AND e.disch_dt_tm = null
    AND e.active_ind=1
    AND (e.loc_facility_cd= $MF_FACILITY)
    AND (e.loc_nurse_unit_cd= $MF_NURS_UNIT))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.birth_dt_tm < cnvtlookbehind("65,Y"))
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_ea_mrn_cd)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_ea_fin_cd)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
  HEAD REPORT
   pinfo->l_cnt = 0
  DETAIL
   pinfo->l_cnt = (pinfo->l_cnt+ 1), stat = alterlist(pinfo->qual,pinfo->l_cnt), pinfo->qual[pinfo->
   l_cnt].f_person_id = p.person_id,
   pinfo->qual[pinfo->l_cnt].f_encntr_id = e.encntr_id, pinfo->qual[pinfo->l_cnt].s_person_dob =
   format(p.birth_dt_tm,"MM/DD/YYYY;;q"), pinfo->qual[pinfo->l_cnt].s_person_fname = trim(p
    .name_first_key,3),
   pinfo->qual[pinfo->l_cnt].s_person_lname = trim(p.name_last_key,3), pinfo->qual[pinfo->l_cnt].
   s_person_name = trim(p.name_full_formatted,3), pinfo->qual[pinfo->l_cnt].s_fin = trim(ea2.alias,3),
   pinfo->qual[pinfo->l_cnt].s_mrn = trim(ea1.alias,3), pinfo->qual[pinfo->l_cnt].s_encntr_type =
   trim(uar_get_code_display(e.encntr_type_cd),3), pinfo->qual[pinfo->l_cnt].s_age = substring(1,(
    findstring(" ",trim(cnvtage(p.birth_dt_tm),3))+ 1),trim(cnvtage(p.birth_dt_tm),3)),
   pinfo->qual[pinfo->l_cnt].s_admit_dt_tm = format(e.reg_dt_tm,"MM/DD/YYYY;;q"), pinfo->qual[pinfo->
   l_cnt].f_length_of_stay = floor(datetimediff(sysdate,e.reg_dt_tm)), pinfo->qual[pinfo->l_cnt].
   s_room = uar_get_code_display(e.loc_room_cd),
   pinfo->qual[pinfo->l_cnt].s_nurs_unit = uar_get_code_display(e.loc_nurse_unit_cd), pinfo->qual[
   pinfo->l_cnt].s_hist_of_dimentia = "N", pinfo->qual[pinfo->l_cnt].s_pt_ord = "N",
   pinfo->qual[pinfo->l_cnt].s_ot_ord = "N", pinfo->qual[pinfo->l_cnt].s_res_ord = "N", pinfo->qual[
   pinfo->l_cnt].s_cam_score = "N",
   pinfo->qual[pinfo->l_cnt].s_bedrest = "N", pinfo->qual[pinfo->l_cnt].s_braden_score = "0", pinfo->
   qual[pinfo->l_cnt].s_cam_result = "0",
   pinfo->qual[pinfo->l_cnt].s_cath_ord = "N", pinfo->qual[pinfo->l_cnt].s_hist_fall = "N"
  WITH nocounter
 ;end select
 IF ((pinfo->l_cnt > 0))
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.primary_mnemonic IN ("amiTRIPTYLINE", "Acetaminophen/Butalbital/Caffeine",
    "Atropine / Diphenoxylate", "Baclofen", "Benztropine",
    "Carisoprodol", "Chlordiazepoxide", "Chlordiazepoxide-Methscopolamine", "Clozapine",
    "Cyclobenzaprine",
    "Dantrolene", "Desipramine", "Diazepam", "DiphenhydrAMINE", "Famotidine",
    "Haloperidol", "HydrOXYzine", "Imipramine", "Ketorolac", "Nortriptyline",
    "Orphenadrine", "PROCHLORperazine", "Promethazine", "Promethazine 1.25 mg/Codeine 2 mg/mL",
    "Quetiapine",
    "Scopolamine", "Tizanidine", "Trifluoperazine", "Trihexyphenidyl"))
   ORDER BY oc.catalog_cd
   HEAD REPORT
    med->l_cnt = 0
   HEAD oc.catalog_cd
    med->l_cnt = (med->l_cnt+ 1), stat = alterlist(med->qual,med->l_cnt), med->qual[med->l_cnt].
    f_catalog_cd = oc.catalog_cd,
    med->qual[med->l_cnt].s_catalog_disp = oc.primary_mnemonic
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE expand(ml_idx1,1,pinfo->l_cnt,d.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
     AND d.active_ind=1
     AND d.end_effective_dt_tm > sysdate)
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id
     AND cnvtupper(n.source_string)="*DEMENTIA*")
   ORDER BY d.encntr_id
   HEAD d.encntr_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,d.encntr_id,pinfo->qual[ml_idx1].
     f_encntr_id)
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].s_hist_of_dimentia = "Y"
    ENDIF
   DETAIL
    pinfo->qual[ml_idx2].l_dcnt = (pinfo->qual[ml_idx2].l_dcnt+ 1), stat = alterlist(pinfo->qual[
     ml_idx2].diag,pinfo->qual[ml_idx2].l_dcnt), pinfo->qual[ml_idx2].diag[pinfo->qual[ml_idx2].
    l_dcnt].f_diag_id = d.diagnosis_id,
    pinfo->qual[ml_idx2].diag[pinfo->qual[ml_idx2].l_dcnt].s_nomen_string = n.source_string, pinfo->
    qual[ml_idx2].diag[pinfo->qual[ml_idx2].l_dcnt].s_source_identifier = n.source_identifier
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM problem p,
    nomenclature n
   PLAN (p
    WHERE expand(ml_idx1,1,pinfo->l_cnt,p.person_id,pinfo->qual[ml_idx1].f_person_id)
     AND p.active_ind=1
     AND p.end_effective_dt_tm > sysdate)
    JOIN (n
    WHERE n.nomenclature_id=p.nomenclature_id
     AND cnvtupper(n.source_string)="*DEMENTIA*")
   ORDER BY p.person_id
   HEAD p.person_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,p.person_id,pinfo->qual[ml_idx1].
     f_person_id)
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].s_hist_of_dimentia = "Y"
    ENDIF
   DETAIL
    pinfo->qual[ml_idx2].l_pcnt = (pinfo->qual[ml_idx2].l_pcnt+ 1), stat = alterlist(pinfo->qual[
     ml_idx2].prob,pinfo->qual[ml_idx2].l_pcnt), pinfo->qual[ml_idx2].prob[pinfo->qual[ml_idx2].
    l_pcnt].f_prob_id = p.problem_id,
    pinfo->qual[ml_idx2].prob[pinfo->qual[ml_idx2].l_pcnt].s_nomen_string = n.source_string, pinfo->
    qual[ml_idx2].prob[pinfo->qual[ml_idx2].l_pcnt].s_source_identifier = n.source_identifier
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM orders o
   WHERE expand(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
    AND o.order_status_cd IN (mf_inprocess_cd, mf_ordered_cd)
    AND o.catalog_type_cd=mf_pharmacy_cd
    AND o.orig_ord_as_flag=0
    AND o.active_ind=1
    AND o.template_order_flag IN (0, 1)
    AND o.med_order_type_cd=mf_med_cd
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].
     f_encntr_id)
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].l_mcnt = 0
    ENDIF
   DETAIL
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].l_mcnt = (pinfo->qual[ml_idx2].l_mcnt+ 1), stat = alterlist(pinfo->qual[
      ml_idx2].meds,pinfo->qual[ml_idx2].l_mcnt), pinfo->qual[ml_idx2].meds[pinfo->qual[ml_idx2].
     l_mcnt].f_catalog_cd = o.catalog_cd,
     pinfo->qual[ml_idx2].meds[pinfo->qual[ml_idx2].l_mcnt].f_order_id = o.order_id, pinfo->qual[
     ml_idx2].meds[pinfo->qual[ml_idx2].l_mcnt].s_mnemonic = trim(o.order_mnemonic)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM orders o
   WHERE expand(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
    AND expand(ml_med_idx,1,med->l_cnt,o.catalog_cd,med->qual[ml_med_idx].f_catalog_cd)
    AND o.order_status_cd IN (mf_inprocess_cd, mf_ordered_cd)
    AND o.orig_ord_as_flag=0
    AND o.active_ind=1
    AND o.template_order_id=0
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].
     f_encntr_id)
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].l_rmcnt = 0
    ENDIF
   DETAIL
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].l_rmcnt = (pinfo->qual[ml_idx2].l_rmcnt+ 1), stat = alterlist(pinfo->qual[
      ml_idx2].rmeds,pinfo->qual[ml_idx2].l_rmcnt), pinfo->qual[ml_idx2].rmeds[pinfo->qual[ml_idx2].
     l_rmcnt].f_catalog_cd = o.catalog_cd,
     pinfo->qual[ml_idx2].rmeds[pinfo->qual[ml_idx2].l_rmcnt].f_order_id = o.order_id, pinfo->qual[
     ml_idx2].rmeds[pinfo->qual[ml_idx2].l_rmcnt].s_mnemonic = trim(o.order_mnemonic)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM orders o,
    order_detail od
   PLAN (o
    WHERE expand(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
     AND o.catalog_cd=mf_activity_cd
     AND o.order_status_cd IN (mf_inprocess_cd, mf_ordered_cd)
     AND o.orig_ord_as_flag=0
     AND o.active_ind=1
     AND o.template_order_id=0)
    JOIN (od
    WHERE od.order_id=o.order_id
     AND od.oe_field_id=mf_ptactivitytype_cd)
   ORDER BY o.encntr_id, o.orig_order_dt_tm DESC, od.action_sequence DESC
   HEAD o.encntr_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].
     f_encntr_id)
    IF (ml_idx2 > 0)
     IF (od.oe_field_value IN (mf_bedrest_cd, mf_bedrestwithbrp_cd))
      pinfo->qual[ml_idx2].s_bedrest = "Y"
     ELSE
      pinfo->qual[ml_idx2].s_bedrest = "N"
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE expand(ml_idx1,1,pinfo->l_cnt,ce.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
    AND ce.event_cd IN (mf_bradenscore_cd, mf_hisoffalls_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
   ORDER BY ce.encntr_id, ce.event_cd, ce.clinical_event_id DESC
   HEAD ce.encntr_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,ce.encntr_id,pinfo->qual[ml_idx1].
     f_encntr_id)
   HEAD ce.event_cd
    IF (ml_idx2 > 0)
     IF (ce.event_cd=mf_bradenscore_cd)
      pinfo->qual[ml_idx2].s_braden_score = trim(ce.result_val,3)
     ENDIF
     IF (ce.event_cd=mf_hisoffalls_cd)
      pinfo->qual[ml_idx2].s_hist_fall = substring(1,1,trim(ce.result_val,3))
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE expand(ml_idx1,1,pinfo->l_cnt,ce.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
    AND ce.event_cd=mf_camscore_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd)
   ORDER BY ce.encntr_id, ce.clinical_event_id DESC
   HEAD ce.encntr_id
    ml_cam_cnt = 0, ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,ce.encntr_id,pinfo->qual[
     ml_idx1].f_encntr_id)
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].s_cam_result = trim(ce.result_val,3)
     IF (cnvtint(trim(ce.result_val,3)) >= 3)
      pinfo->qual[ml_idx2].s_cam_score = "Y"
     ELSE
      pinfo->qual[ml_idx2].s_cam_score = "N"
     ENDIF
    ENDIF
   DETAIL
    ml_cam_cnt = (ml_cam_cnt+ 1)
    IF (ml_cam_cnt=2
     AND ml_idx2 > 0)
     pinfo->qual[ml_idx2].s_cam_result2 = trim(ce.result_val,3)
     IF (cnvtint(trim(ce.result_val,3)) >= 3)
      pinfo->qual[ml_idx2].s_cam_score2 = "Y"
     ELSE
      pinfo->qual[ml_idx2].s_cam_score2 = "N"
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   FROM orders o
   WHERE expand(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].f_encntr_id)
    AND o.order_status_cd IN (mf_inprocess_cd, mf_ordered_cd)
    AND o.catalog_cd IN (mf_restraintsmedsurg_cd, mf_otevaltreat_cd, mf_ptevaltreat_cd,
   mf_ottreatment_cd, mf_pttreatment_cd,
   mf_restraintsviolent_cd, mf_restraintspsych_cd, mf_cathetersing_cd, mf_cathetercoude_cd,
   mf_catheterexternalurinary_cd,
   mf_catheterfoleythreeway_cd, mf_cathetertexas_cd, mf_catheterfoley_cd)
    AND o.orig_ord_as_flag=0
    AND o.active_ind=1
   ORDER BY o.encntr_id
   HEAD o.encntr_id
    ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,pinfo->l_cnt,o.encntr_id,pinfo->qual[ml_idx1].
     f_encntr_id)
    IF (ml_idx2 > 0)
     pinfo->qual[ml_idx2].s_pt_ord = "N", pinfo->qual[ml_idx2].s_ot_ord = "N", pinfo->qual[ml_idx2].
     s_res_ord = "N",
     pinfo->qual[ml_idx2].s_cath_ord = "N"
    ENDIF
   DETAIL
    IF (ml_idx2 > 0)
     IF (o.catalog_cd IN (mf_restraintsmedsurg_cd, mf_restraintsviolent_cd, mf_restraintspsych_cd))
      pinfo->qual[ml_idx2].s_res_ord = "Y"
     ENDIF
     IF (o.catalog_cd IN (mf_otevaltreat_cd, mf_ottreatment_cd))
      pinfo->qual[ml_idx2].s_ot_ord = "Y"
     ENDIF
     IF (o.catalog_cd IN (mf_ptevaltreat_cd, mf_pttreatment_cd))
      pinfo->qual[ml_idx2].s_pt_ord = "Y"
     ENDIF
     IF (o.catalog_cd IN (mf_cathetersing_cd, mf_cathetercoude_cd, mf_catheterexternalurinary_cd,
     mf_catheterfoleythreeway_cd, mf_cathetertexas_cd,
     mf_catheterfoley_cd))
      pinfo->qual[ml_idx2].s_cath_ord = "Y"
      IF (o.catalog_cd IN (mf_cathetersing_cd))
       pinfo->qual[ml_idx2].s_cath_ord = concat(pinfo->qual[ml_idx2].s_cath_ord,"-S")
      ENDIF
      IF (o.catalog_cd IN (mf_cathetercoude_cd))
       pinfo->qual[ml_idx2].s_cath_ord = concat(pinfo->qual[ml_idx2].s_cath_ord,"-C")
      ENDIF
      IF (o.catalog_cd IN (mf_catheterexternalurinary_cd, mf_cathetertexas_cd))
       pinfo->qual[ml_idx2].s_cath_ord = concat(pinfo->qual[ml_idx2].s_cath_ord,"-T")
      ENDIF
      IF (o.catalog_cd IN (mf_catheterfoleythreeway_cd, mf_catheterfoley_cd))
       pinfo->qual[ml_idx2].s_cath_ord = concat(pinfo->qual[ml_idx2].s_cath_ord,"-F")
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  FOR (ml_idx1 = 1 TO pinfo->l_cnt)
    SET mi_advdir_ind = 0
    SELECT INTO "nl:"
     FROM clinical_event ce
     WHERE (ce.person_id=pinfo->qual[ml_idx1].f_person_id)
      AND ce.event_cd=mf_advdir_cd
      AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd,
     mf_inerror4_cd, mf_inprogress_cd,
     mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
     mf_unknown_cd))
      AND ce.event_class_cd != mf_placeholder_cd
      AND ce.view_level=1
      AND ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     ORDER BY ce.valid_from_dt_tm DESC
     HEAD ce.person_id
      IF (cnvtupper(ce.result_val)="Y*")
       mi_advdir_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (mi_advdir_ind=0)
     SELECT INTO "nl:"
      FROM person_patient p
      WHERE (p.person_id=pinfo->qual[ml_idx1].f_person_id)
       AND p.living_will_cd IN (mf_yes_cd, mf_yesof_cd, mf_yesnof_cd)
       AND p.active_ind=1
      DETAIL
       IF (p.living_will_cd > 0)
        mi_advdir_ind = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    SET pinfo->qual[ml_idx1].s_adv_dir = evaluate(mi_advdir_ind,1,"Y","N")
  ENDFOR
 ENDIF
 IF ((pinfo->l_cnt > 0))
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,pinfo->qual[d.seq].s_person_name)), mrn = trim(substring(1,100,
     pinfo->qual[d.seq].s_mrn)), age = trim(substring(1,100,pinfo->qual[d.seq].s_age)),
   room = trim(substring(1,100,pinfo->qual[d.seq].s_room)), admit_status = trim(substring(1,1,pinfo->
     qual[d.seq].s_encntr_type)), los = trim(substring(1,10,cnvtstring(pinfo->qual[d.seq].
      f_length_of_stay))),
   hist_of_dementia = trim(substring(1,10,pinfo->qual[d.seq].s_hist_of_dimentia)), cam1 = trim(
    substring(1,10,pinfo->qual[d.seq].s_cam_score)), cam2 = trim(substring(1,10,pinfo->qual[d.seq].
     s_cam_score2)),
   no_of_meds = trim(substring(1,10,cnvtstring(pinfo->qual[d.seq].l_mcnt))), pims = evaluate(pinfo->
    qual[d.seq].l_rmcnt,0,"N","Y"), no_of_pims = trim(substring(1,10,cnvtstring(pinfo->qual[d.seq].
      l_rmcnt))),
   hist_of_falls = trim(substring(1,10,pinfo->qual[d.seq].s_hist_fall)), pt = trim(substring(1,10,
     pinfo->qual[d.seq].s_pt_ord)), ot = trim(substring(1,10,pinfo->qual[d.seq].s_ot_ord)),
   res = trim(substring(1,10,pinfo->qual[d.seq].s_res_ord)), cath = trim(substring(1,10,pinfo->qual[d
     .seq].s_cath_ord))
   FROM (dummyt d  WITH seq = pinfo->l_cnt)
   PLAN (d
    WHERE d.seq > 0)
   ORDER BY patient_name, room
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No patients qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
 CALL echorecord(pinfo)
#exit_program
END GO
