CREATE PROGRAM bhs_pt_friendly_summary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE notdone_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE")), protect
 DECLARE inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE pendingreview_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE")),
 protect
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"PENDING")), protect
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")), protect
 DECLARE incomplete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE")), protect
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE pharmacy_cattyp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),
 protect
 DECLARE allergy_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",12025,"CANCELED")), protect
 DECLARE physther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE occther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE speechther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE audiology_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE antepartum_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE neurodiag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE pulmlab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE scd_data_cd = f8 WITH public, constant(uar_get_code_by("MEANING",15752,"DATA"))
 DECLARE sensitive_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12033,"SENSITIVE"))
 DECLARE active_life_cycle_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12030,"ACTIVE")
  )
 DECLARE mf_void_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"VOIDEDWITHRESULTS"
   ))
 DECLARE mf_del_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DISCONTINUED"))
 DECLARE mf_disch_discont_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4038,
   "SYSTEMDCONDISCHARGE"))
 DECLARE mf_req_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,
   "REQUESTORDERS"))
 DECLARE mf_female_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE mf_male_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE pcp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE consultdoc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"CONSULTDOC"))
 DECLARE weight_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHTLBOZ"))
 DECLARE pulse_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"PULSERATE"))
 DECLARE systolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE diastolic_bp_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE mf_bmi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"BODYMASSINDEX"))
 DECLARE mf_fu_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FOLLOWUPAPPOINTMENT"))
 DECLARE mf_pat_care_op_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PATIENTCAREOP"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mf_rem_space = f8 WITH protect, noconstant(0.0)
 DECLARE mn_diab_ind = i2 WITH protect, noconstant(0)
 IF (reflect(parameter(2,0)) > " ")
  SET output_device = parameter(1,0)
  SET eid = cnvtreal(parameter(2,0))
 ELSE
  SET output_device = request->output_device
  SET eid = request->visit[1].encntr_id
 ENDIF
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 disch_date = dq8
     2 person_id = f8
     2 name_full_formatted = vc
     2 age = c12
     2 f_sex_cd = f8
     2 l_age_in_yrs = i4
     2 birth_dt_tm = vc
     2 pcpdoc_name = vc
     2 consult_doc[*]
       3 consult_name = vc
     2 immunization[*]
       3 n_type = i2
       3 name = vc
       3 given_date = vc
     2 measurements[*]
       3 wt_result = c15
       3 wt_dt_tm = c18
       3 pulse_result = c20
       3 pulse_dt_tm = c18
       3 systolic_result = c3
       3 diastolic_result = c3
       3 bp_dt_tm = c18
       3 bp_display = vc
       3 s_bmi = vc
       3 s_bmi_dt_tm = vc
     2 allergy[*]
       3 source_identifier = vc
       3 source_string = vc
       3 severity = vc
       3 type_source_string = vc
       3 allergy_dt_tm = vc
       3 diag_dt_tm = vc
       3 substance_type_disp = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
       3 reaction_display = vc
     2 diagnosis[*]
       3 source_identifier = vc
       3 source_string = vc
       3 diag_dt_tm = c16
       3 diag_type_desc = vc
       3 note = vc
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 source_vocabulary_desc = c60
       3 source_vocabulary_mean = c12
     2 problem[*]
       3 status = vc
       3 beg_effective_dt_tm = vc
       3 text = vc
       3 full_text = vc
     2 procedure_total = i4
     2 procedure[*]
       3 proc_name = vc
       3 proc_dt_tm = c20
       3 proc_provider = vc
     2 number_of_meds = i4
     2 meds[*]
       3 order_id = f8
       3 person_id = f8
       3 comments = vc
       3 mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_mnemonic = vc
       3 activity_type_disp = vc
       3 catalog_type_sort = i4
       3 catalog_type_disp = vc
       3 date = c20
       3 orig_order_dt_tm = c20
       3 order_status_cd = f8
       3 template_order_flag = f8
       3 order_status_disp = c20
       3 order_detail_display_line = vc
       3 display_line = vc
       3 long_text = vc
       3 freq = c30
       3 dose = c30
       3 doseunit = c30
       3 next_dose_dt_tm = c14
       3 order_comment_ind = i2
       3 order_person = vc
       3 order_doctor = vc
       3 need_rx_verify_ind = i2
       3 need_rx_verify_str = vc
       3 mso = i2
       3 ioi = i2
       3 volume = vc
       3 route = vc
       3 volume_unit = vc
       3 volume_dose = vc
       3 strength_dose = vc
       3 strength_unit = vc
       3 free_text = vc
     2 hm_cnt = i4
     2 hm[*]
       3 step_desc = vc
       3 last_satisfied_dt_tm = vc
       3 overdue_ind = i2
       3 s_mammo_due_dt_tm = vc
       3 n_mammo_overdue = i2
       3 s_cervical_due_dt_tm = vc
       3 n_cervical_overdue = i2
       3 s_colo_due_dt_tm = vc
       3 n_colo_overdue = i2
       3 s_diab_ret_due_dt_tm = vc
       3 n_diab_ret_overdue = i2
       3 s_diab_hba1c_result = vc
       3 s_diab_hba1c_due_dt_tm = vc
       3 s_diab_microalb_result = vc
       3 s_diab_microalb_due_dt_tm = vc
       3 s_ldl_result = vc
       3 s_ldl_due_dt_tm = vc
     2 pat_inst_cnt = i4
     2 pat_inst[*]
       3 text = vc
     2 req_ords[*]
       3 f_order_id = f8
       3 s_name = vc
       3 s_ord_desc = vc
     2 fu_ords[*]
       3 f_order_id = f8
       3 s_name = vc
       3 s_ord_desc = vc
 )
 CALL echo(consultdoc_cd)
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_prsnl_reltn ppr,
   prsnl pr,
   encntr_prsnl_reltn epr1,
   prsnl pr1
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ppr
   WHERE ppr.person_id=outerjoin(p.person_id)
    AND ppr.person_prsnl_r_cd=outerjoin(pcp_cd)
    AND ppr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pr
   WHERE pr.person_id=outerjoin(ppr.prsnl_person_id)
    AND pr.physician_ind=outerjoin(1))
   JOIN (epr1
   WHERE epr1.encntr_id=outerjoin(e.encntr_id)
    AND epr1.encntr_prsnl_r_cd=outerjoin(consultdoc_cd)
    AND epr1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(epr1.prsnl_person_id)
    AND pr1.physician_ind=outerjoin(1))
  HEAD REPORT
   stat = alterlist(dlrec->seq,1), dlrec->encntr_total = 1, dlrec->seq[1].encntr_id = eid,
   dlrec->seq[1].person_id = e.person_id, dlrec->seq[1].name_full_formatted = p.name_full_formatted,
   dlrec->seq[1].age = cnvtage(p.birth_dt_tm),
   dlrec->seq[1].l_age_in_yrs = cnvtint((datetimediff(sysdate,p.birth_dt_tm,1)/ 365)), dlrec->seq[1].
   f_sex_cd = p.sex_cd, dlrec->seq[1].birth_dt_tm = format(p.birth_dt_tm,"MM/DD/YYYY ;;q"),
   dlrec->seq[1].pcpdoc_name = pr.name_full_formatted, dlrec->seq[1].disch_date = e.disch_dt_tm,
   consultdoc_cnt = 0
  DETAIL
   consultdoc_cnt = (consultdoc_cnt+ 1), stat = alterlist(dlrec->seq[1].consult_doc,consultdoc_cnt),
   dlrec->seq[1].consult_doc[consultdoc_cnt].consult_name = pr1.name_full_formatted
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
     .substance_ftdesc))), substance_type_disp =
  IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
  ELSE "Other "
  ENDIF
  FROM allergy a,
   nomenclature n,
   nomenclature n2,
   encounter e,
   reaction r
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != allergy_canceled_cd)
   JOIN (n
   WHERE outerjoin(a.substance_nom_id)=n.nomenclature_id)
   JOIN (r
   WHERE r.allergy_id=outerjoin(a.allergy_id))
   JOIN (n2
   WHERE n2.nomenclature_id=outerjoin(r.reaction_nom_id))
  ORDER BY a.person_id, substance_type_disp, short_source_string
  HEAD a.person_id
   al = 0
  DETAIL
   al = (al+ 1)
   IF (mod(al,10)=1)
    stat = alterlist(dlrec->seq[1].allergy,(al+ 10))
   ENDIF
   dlrec->seq[1].allergy[al].source_string = short_source_string, dlrec->seq[1].allergy[al].
   substance_type_disp = substance_type_disp, dlrec->seq[1].allergy[al].type_source_string = concat(
    build(substance_type_disp,": ")," ",short_source_string),
   dlrec->seq[1].allergy[al].source_string = short_source_string, dlrec->seq[1].allergy[al].severity
    = uar_get_code_display(a.severity_cd), dlrec->seq[1].allergy[al].substance_type_disp =
   substance_type_disp,
   dlrec->seq[1].allergy[al].allergy_dt_tm = substring(1,14,format(a.updt_dt_tm,"@SHORTDATE;;Q"))
   IF (r.reaction_ftdesc > " ")
    dlrec->seq[1].allergy[al].reaction_display = trim(r.reaction_ftdesc)
   ELSE
    dlrec->seq[1].allergy[al].reaction_display = trim(n2.source_string)
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq[1].allergy,al)
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  p.problem_id, problem = build(p.problem_ftdesc,n.source_string)
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE (p.person_id=dlrec->seq[1].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
    AND p.classification_cd != sensitive_cd
    AND p.life_cycle_status_cd=active_life_cycle_cd)
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(p.nomenclature_id)
    AND n.source_vocabulary_cd=snmct_cd)
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD p.person_id
   cnt = 0, stat = alterlist(dlrec->seq[1].problem,10)
  DETAIL
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(dlrec->seq[1].problem,(cnt+ 10))
    ENDIF
    IF (p.nomenclature_id > 0)
     dlrec->seq[1].problem[cnt].text = n.source_string
    ELSE
     dlrec->seq[1].problem[cnt].text = p.problem_ftdesc
    ENDIF
    dlrec->seq[1].problem[cnt].status = uar_get_code_display(p.life_cycle_status_cd), dlrec->seq[1].
    problem[cnt].beg_effective_dt_tm = substring(1,14,format(p.beg_effective_dt_tm,"@SHORTDATE;;Q")),
    dlrec->seq[1].problem[cnt].full_text = build(dlrec->seq[1].problem[cnt].status,": ",dlrec->seq[1]
     .problem[cnt].text)
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq[1].problem,cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,p
     .proc_ftdesc))), pr.name_full_formatted
  FROM procedure p,
   nomenclature n,
   proc_prsnl_reltn ppr,
   prsnl pr
  PLAN (p
   WHERE p.encntr_id=eid
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE outerjoin(p.nomenclature_id)=n.nomenclature_id)
   JOIN (ppr
   WHERE outerjoin(p.procedure_id)=ppr.procedure_id)
   JOIN (pr
   WHERE outerjoin(ppr.prsnl_person_id)=pr.person_id)
  ORDER BY p.encntr_id, short_source_string
  HEAD p.encntr_id
   proc = 0
  DETAIL
   proc = (proc+ 1)
   IF (mod(proc,10)=1)
    stat = alterlist(dlrec->seq[1].procedure,(proc+ 10))
   ENDIF
   IF (n.nomenclature_id > 0.0)
    dlrec->seq[1].procedure[proc].proc_name = trim(n.source_string)
   ELSE
    dlrec->seq[1].procedure[proc].proc_name = trim(p.proc_ftdesc)
   ENDIF
   IF (p.proc_ft_dt_tm_ind=1)
    dlrec->seq[1].procedure[proc].proc_dt_tm = p.proc_ft_time_frame
   ELSE
    dlrec->seq[1].procedure[proc].proc_dt_tm = substring(1,14,format(p.proc_dt_tm,"@SHORTDATE;;Q"))
   ENDIF
   IF (pr.person_id > 0.00)
    dlrec->seq[1].procedure[proc].proc_provider = trim(pr.name_full_formatted)
   ELSEIF (ppr.proc_prsnl_ft_ind > 0)
    dlrec->seq[1].procedure[proc].proc_provider = trim(ppr.proc_ft_prsnl)
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq[1].procedure,proc)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   order_comment oc,
   long_text lt
  PLAN (o
   WHERE (o.person_id=dlrec->seq[1].person_id)
    AND o.catalog_type_cd=pharmacy_cattyp_cd
    AND o.order_status_cd IN (incomplete_cd, inprocess_cd, ordered_cd, pending_cd, pendingreview_cd)
    AND o.template_order_flag IN (0, 1)
    AND o.orig_ord_as_flag IN (1, 2, 3))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning IN ("FREQ", "FREETXTDOSE", "DOSE", "DOSEUNIT", "STRENGTHDOSE",
   "STRENGTHDOSEUNIT", "VOLUMEDOSE", "VOLUMEDOSEUNIT", "RXROUTE"))
   JOIN (oc
   WHERE oc.order_id=outerjoin(o.order_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(oc.long_text_id)
    AND ((lt.parent_entity_id+ 0)=outerjoin(oc.order_id))
    AND ((lt.active_ind+ 0)=outerjoin(1))
    AND trim(lt.parent_entity_name)=outerjoin("ORDER_COMMENT"))
  ORDER BY o.person_id, o.order_id, od.detail_sequence
  HEAD REPORT
   cnt = 0
  HEAD o.person_id
   cnt = 0, stat = alterlist(dlrec->seq[1].meds,10)
  HEAD o.order_id
   cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].meds,cnt),
   CALL echo(build2("med select cnt:",trim(build2(cnt),3))),
   dlrec->seq[1].meds[cnt].ordered_as_mnemonic = o.ordered_as_mnemonic
   IF (o.order_comment_ind=1)
    dlrec->seq[1].meds[cnt].comments = replace(trim(lt.long_text),
     "Refer to Reference Text for Black Box Warning"," ",0)
   ENDIF
  DETAIL
   IF (od.oe_field_meaning="FREQ")
    dlrec->seq[1].meds[cnt].freq = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="VOLUMEDOSE")
    dlrec->seq[1].meds[cnt].volume_dose = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="VOLUMEDOSEUNIT")
    dlrec->seq[1].meds[cnt].volume_unit = od.oe_field_display_value
   ELSEIF (od.oe_field_meaning="RXROUTE")
    dlrec->seq[1].meds[cnt].route = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="FREETXTDOSE")
    dlrec->seq[1].meds[cnt].free_text = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="DOSE")
    dlrec->seq[1].meds[cnt].dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSE")
    dlrec->seq[1].meds[cnt].strength_dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="DOSEUNIT")
    dlrec->seq[1].meds[cnt].doseunit = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="STRENGTHUNIT")
    dlrec->seq[1].meds[cnt].strength_unit = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_meaning="STRENGTHDOSEUNIT")
    dlrec->seq[1].meds[cnt].strength_unit = trim(od.oe_field_display_value)
   ENDIF
  FOOT  o.order_id
   IF ((dlrec->seq[1].meds[cnt].dose > " ")
    AND (dlrec->seq[1].meds[cnt].doseunit > " "))
    dlrec->seq[1].meds[cnt].dose = concat(trim(dlrec->seq[1].meds[cnt].dose)," ",trim(dlrec->seq[1].
      meds[cnt].doseunit))
   ENDIF
   IF ((dlrec->seq[1].meds[cnt].volume_dose > " "))
    dlrec->seq[1].meds[cnt].dose = concat(dlrec->seq[1].meds[cnt].volume_dose," ",dlrec->seq[1].meds[
     cnt].volume_unit)
   ELSEIF ((dlrec->seq[1].meds[cnt].strength_dose > " "))
    dlrec->seq[1].meds[cnt].dose = concat(dlrec->seq[1].meds[cnt].strength_dose," ",dlrec->seq[1].
     meds[cnt].strength_unit)
   ELSEIF ((dlrec->seq[1].meds[cnt].free_text > " "))
    dlrec->seq[1].meds[cnt].dose = dlrec->seq[1].meds[cnt].free_text
   ENDIF
  FOOT  o.hna_order_mnemonic
   col + 0
  FOOT  o.person_id
   IF (cnt > 0)
    dlrec->seq[1].number_of_meds = cnt, stat = alterlist(dlrec->seq[1].meds,cnt)
   ENDIF
  FOOT REPORT
   col + 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pn_type =
  IF (ce.event_cd IN (1596099, 807931)) 1
  ELSE 2
  ENDIF
  , ps_name = trim(uar_get_code_display(ce.event_cd))
  FROM clinical_event ce,
   ce_med_result cem
  PLAN (ce
   WHERE (ce.person_id=dlrec->seq[1].person_id)
    AND ((ce.event_cd IN (1596099.00, 807931.00, 221048434)
    AND ((ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(dlrec->seq[1].disch_date,- (365)))
    AND (dlrec->seq[1].disch_date > 0)) OR (ce.event_end_dt_tm >= cnvtdatetime((curdate - 365),
    curtime))) ) OR (ce.event_cd IN (1698425.00, 744306.00, 807922, 1698418, 807923,
   1595831, 807928, 48188459, 2441940, 807924,
   807925, 104487187, 104487188, 807926, 807927,
   729227, 1715503, 1715495, 1715483, 744082,
   807929, 807930, 1596048, 744088, 104487191,
   48188453, 48188454, 1943463, 104487185, 807932,
   807933, 807934, 807935, 1698422, 744176,
   107664960, 48188455, 1698423, 744181, 813819,
   807936, 1698424, 744229, 807937, 28622835,
   807938, 48188456, 48188457, 1698425, 744306,
   744307, 28622836, 1698427, 744346, 104487189,
   104487190, 104487186, 807939, 744407, 1698417,
   48188460, 48188458, 1596650, 807940, 48188457,
   221048434)
    AND ((ce.event_end_dt_tm >= cnvtdatetime(datetimeadd(dlrec->seq[1].disch_date,- (1825)))
    AND (dlrec->seq[1].disch_date > 0)) OR (ce.event_end_dt_tm >= cnvtdatetime((curdate - 1825),
    curtime))) ))
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.result_status_cd != inerror_cd)
   JOIN (cem
   WHERE cem.event_id=ce.event_id)
  ORDER BY pn_type, ps_name, cem.admin_start_dt_tm DESC
  HEAD REPORT
   immun_cnt = 0
  HEAD ce.event_cd
   immun_cnt = (immun_cnt+ 1), stat = alterlist(dlrec->seq[1].immunization,immun_cnt), dlrec->seq[1].
   immunization[immun_cnt].name = trim(uar_get_code_display(ce.event_cd),3),
   dlrec->seq[1].immunization[immun_cnt].given_date = format(cem.admin_start_dt_tm,"@SHORTDATE")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=dlrec->seq[1].encntr_id)
    AND o.active_ind=1
    AND o.dcp_clin_cat_cd=mf_req_order_cd
    AND  NOT (o.order_status_cd IN (mf_del_cd, mf_void_cd))
    AND  NOT (o.order_status_cd IN (mf_canceled_cd, mf_discont_cd)
    AND o.discontinue_type_cd != mf_disch_discont_cd))
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(dlrec->seq[1].req_ords,5))
    stat = alterlist(dlrec->seq[1].req_ords,(pl_cnt+ 10))
   ENDIF
   dlrec->seq[1].req_ords[pl_cnt].f_order_id = o.order_id, dlrec->seq[1].req_ords[pl_cnt].s_name =
   trim(uar_get_code_display(o.catalog_cd)), dlrec->seq[1].req_ords[pl_cnt].s_ord_desc = trim(o
    .order_detail_display_line)
  FOOT REPORT
   stat = alterlist(dlrec->seq[1].req_ords,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ps_oe_field = uar_get_code_display(od.oe_field_id)
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE (o.encntr_id=dlrec->seq[1].encntr_id)
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_pat_care_op_cd
    AND o.catalog_cd=mf_fu_order_cd)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="OTHER")
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   IF (ps_oe_field="Other Reason")
    pl_cnt = (pl_cnt+ 1)
    IF (pl_cnt > size(dlrec->seq[1].fu_ords,5))
     stat = alterlist(dlrec->seq[1].fu_ords,(pl_cnt+ 10))
    ENDIF
    dlrec->seq[1].fu_ords[pl_cnt].f_order_id = o.order_id, dlrec->seq[1].fu_ords[pl_cnt].s_name =
    trim(uar_get_code_display(o.catalog_cd)), dlrec->seq[1].fu_ords[pl_cnt].s_ord_desc = trim(od
     .oe_field_display_value)
   ENDIF
  FOOT REPORT
   stat = alterlist(dlrec->seq[1].fu_ords,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("get vitals")
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event c,
   ce_date_result cdr
  PLAN (c
   WHERE (c.encntr_id=dlrec->seq[1].encntr_id)
    AND ((c.event_cd+ 0) IN (weight_cd, systolic_bp_cd, diastolic_bp_cd, pulse_cd, mf_bmi_cd))
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
    AND c.event_tag > " ")
   JOIN (cdr
   WHERE outerjoin(c.event_id)=cdr.event_id
    AND c.valid_until_dt_tm=outerjoin(cnvtdatetime("31-dec-2100,00:00:00")))
  ORDER BY c.encntr_id, c.event_cd, cnvtdatetime(c.event_end_dt_tm) DESC
  HEAD REPORT
   cnt = 0
  HEAD c.encntr_id
   cnt = (cnt+ 1), stat = alterlist(dlrec->seq[1].measurements,cnt)
  HEAD c.event_cd
   CASE (c.event_cd)
    OF weight_cd:
     dlrec->seq[1].measurements[cnt].wt_result = concat(trim(c.result_val),uar_get_code_display(c
       .result_units_cd)),dlrec->seq[1].measurements[cnt].wt_dt_tm = substring(1,14,format(c
       .event_end_dt_tm,"@SHORTDATE"))
    OF pulse_cd:
     dlrec->seq[1].measurements[cnt].pulse_result = trim(c.result_val),dlrec->seq[1].measurements[cnt
     ].pulse_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
    OF systolic_bp_cd:
     dlrec->seq[1].measurements[cnt].systolic_result = trim(c.result_val)
    OF diastolic_bp_cd:
     dlrec->seq[1].measurements[cnt].diastolic_result = trim(c.result_val),dlrec->seq[1].
     measurements[cnt].bp_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
    OF mf_bmi_cd:
     dlrec->seq[1].measurements[cnt].s_bmi = trim(c.result_val),dlrec->seq[1].measurements[cnt].
     s_bmi_dt_tm = substring(1,14,format(c.event_end_dt_tm,"@SHORTDATE"))
   ENDCASE
   dlrec->seq[1].measurements[cnt].bp_display = concat(dlrec->seq[1].measurements[cnt].
    systolic_result,"/",dlrec->seq[1].measurements[cnt].diastolic_result)
  WITH nocounter
 ;end select
 CALL echo("get health maint info")
 FOR (pseq = 1 TO dlrec->encntr_total)
  EXECUTE bhs_sys_get_health_maint dlrec->seq[pseq].person_id, 1, 0
  IF (size(bhs_health_maint->person,5) > 0)
   SET dlrec->seq[pseq].hm_cnt = bhs_health_maint->person[pseq].pending_cnt
   SET stat = alterlist(dlrec->seq[pseq].hm,1)
   CALL echorecord(bhs_health_maint)
   CALL echo("get due date and overdue info")
   FOR (hseq = 1 TO dlrec->seq[pseq].hm_cnt)
    SET ms_tmp = cnvtupper(trim(bhs_health_maint->person[pseq].pending[hseq].step_desc,3))
    CASE (ms_tmp)
     OF "MAMMOGRAPHY":
      SET dlrec->seq[pseq].hm[1].s_mammo_due_dt_tm = format(bhs_health_maint->person[pseq].pending[
       hseq].last_satisfied_dt_tm,"@SHORTDATE;;Q")
      IF ((bhs_health_maint->person[pseq].pending[hseq].overdue_dt_tm < cnvtdatetime(curdate,curtime3
       )))
       SET dlrec->seq[pseq].hm[1].n_mammo_overdue = 1
      ENDIF
     OF "PAP SMEAR":
      SET dlrec->seq[pseq].hm[1].s_cervical_due_dt_tm = format(bhs_health_maint->person[pseq].
       pending[hseq].last_satisfied_dt_tm,"@SHORTDATE;;Q")
      IF ((bhs_health_maint->person[pseq].pending[hseq].overdue_dt_tm < cnvtdatetime(curdate,curtime3
       )))
       SET dlrec->seq[pseq].hm[1].n_cervical_overdue = 1
      ENDIF
     OF "COLORECTAL CANCER SCREENING":
      SET dlrec->seq[pseq].hm[1].s_colo_due_dt_tm = format(bhs_health_maint->person[pseq].pending[
       hseq].last_satisfied_dt_tm,"@SHORTDATE;;Q")
      IF ((bhs_health_maint->person[pseq].pending[hseq].overdue_dt_tm < cnvtdatetime(curdate,curtime3
       )))
       SET dlrec->seq[pseq].hm[1].n_colo_overdue = 1
      ENDIF
     OF "DIABETES DILATED RETINAL EYE EXAM":
      SET dlrec->seq[pseq].hm[1].s_diab_ret_due_dt_tm = format(bhs_health_maint->person[pseq].
       pending[hseq].last_satisfied_dt_tm,"@SHORTDATE;;Q")
      IF ((bhs_health_maint->person[pseq].pending[hseq].overdue_dt_tm < cnvtdatetime(curdate,curtime3
       )))
       SET dlrec->seq[pseq].hm[1].n_diab_ret_overdue = 1
      ENDIF
     OF "DIABETES HBA1C":
      SET dlrec->seq[pseq].hm[1].s_diab_hba1c_due_dt_tm = format(bhs_health_maint->person[pseq].
       pending[hseq].last_satisfied_dt_tm,"@SHORTDATE;;Q")
     OF "DIABETES MICROALBUMIN":
      SET dlrec->seq[pseq].hm[1].s_diab_microalb_due_dt_tm = format(bhs_health_maint->person[pseq].
       pending[hseq].last_satisfied_dt_tm,"@SHORTDATE;;Q")
     OF "LIPIDS LDL":
      SET dlrec->seq[pseq].hm[1].s_ldl_due_dt_tm = format(bhs_health_maint->person[pseq].pending[hseq
       ].last_satisfied_dt_tm,"@SHORTDATE;;Q")
    ENDCASE
   ENDFOR
   CALL echo("get satisfied results")
   FOR (hseq = 1 TO bhs_health_maint->person[pseq].satisfied_cnt)
    SET ms_tmp = cnvtupper(trim(bhs_health_maint->person[pseq].satisfied[hseq].step_desc,3))
    CASE (ms_tmp)
     OF "DIABETES HBA1C":
      SET dlrec->seq[pseq].hm[1].s_diab_hba1c_result = trim(bhs_health_maint->person[pseq].satisfied[
       hseq].reason_desc,3)
     OF "LIPIDS LDL":
      SET dlrec->seq[pseq].hm[1].s_ldl_result = trim(bhs_health_maint->person[pseq].satisfied[hseq].
       reason_desc,3)
     OF "DIABETES MICROALBUMIN":
      SET dlrec->seq[pseq].hm[1].s_diab_microalb_result = trim(bhs_health_maint->person[pseq].
       satisfied[hseq].reason_desc,3)
    ENDCASE
   ENDFOR
  ENDIF
 ENDFOR
 CALL echorecord(dlrec)
 SELECT INTO "NL:"
  FROM scd_story ss,
   scd_term st,
   scr_term_text stt,
   scd_term_data std,
   long_blob lb
  PLAN (ss
   WHERE (ss.encounter_id=dlrec->seq[1].encntr_id)
    AND ss.active_ind=1)
   JOIN (st
   WHERE ss.scd_story_id=st.scd_story_id
    AND st.scd_term_data_id > 0)
   JOIN (stt
   WHERE st.scr_term_id=stt.scr_term_id
    AND stt.definition="patient_instructions")
   JOIN (std
   WHERE st.scd_term_data_id=std.scd_term_data_id
    AND std.scd_term_data_type_cd=scd_data_cd)
   JOIN (lb
   WHERE std.fkey_id=lb.parent_entity_id
    AND lb.parent_entity_name="SCD_BLOB")
  HEAD REPORT
   pat_inst_cnt = 0, blob_in = fillstring(64000," "), blob_out1 = fillstring(64000," "),
   blob_out2 = fillstring(64000," "), blob_len = 0
  DETAIL
   pat_inst_cnt = (dlrec->seq[1].pat_inst_cnt+ 1), stat = alterlist(dlrec->seq[1].pat_inst,
    pat_inst_cnt), dlrec->seq[1].pat_inst_cnt = pat_inst_cnt,
   blob_in = fillstring(64000," "), blob_out1 = fillstring(64000," "), blob_out2 = fillstring(64000,
    " "),
   blob_len = 0, blob_in = lb.long_blob
   IF (lb.compression_cd=uar_get_code_by("MEANING",120,"OCFCOMP"))
    CALL uar_ocf_uncompress(blob_in,size(blob_in),blob_out1,size(blob_out1),blob_len)
   ELSE
    blob_out1 = blob_in
   ENDIF
   CALL uar_rtf2(blob_out1,size(blob_out1),blob_out2,size(blob_out2),0), dlrec->seq[1].pat_inst[
   pat_inst_cnt].text = trim(blob_out2)
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE headpage(ncalc=i2) = f8 WITH protect
 DECLARE headpageabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE patinfo(ncalc=i2) = f8 WITH protect
 DECLARE patinfoabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE active_conditions_head(ncalc=i2) = f8 WITH protect
 DECLARE active_conditions_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE active_conditions(ncalc=i2) = f8 WITH protect
 DECLARE active_conditionsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE allergies_head(ncalc=i2) = f8 WITH protect
 DECLARE allergies_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE allergies(ncalc=i2) = f8 WITH protect
 DECLARE allergiesabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE procedures_head(ncalc=i2) = f8 WITH protect
 DECLARE procedures_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE procedures(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE proceduresabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE medication_head(ncalc=i2) = f8 WITH protect
 DECLARE medication_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE medtitle(ncalc=i2) = f8 WITH protect
 DECLARE medtitleabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE medications(ncalc=i2) = f8 WITH protect
 DECLARE medicationsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE medinstructions(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE medinstructionsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE immun_head(ncalc=i2) = f8 WITH protect
 DECLARE immun_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE immun(ncalc=i2) = f8 WITH protect
 DECLARE immunabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE measurements_head(ncalc=i2) = f8 WITH protect
 DECLARE measurements_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE measurements(ncalc=i2) = f8 WITH protect
 DECLARE measurementsabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_head(ncalc=i2) = f8 WITH protect
 DECLARE hm_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_diab_ret_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_diab_ret_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_diab_hba1c_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_diab_hba1c_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_diab_micro_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_diab_micro_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_ldl_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_ldl_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_mammo_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_mammo_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_cervical_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_cervical_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE hm_colo_section(ncalc=i2) = f8 WITH protect
 DECLARE hm_colo_sectionabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE req_orders_head(ncalc=i2) = f8 WITH protect
 DECLARE req_orders_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE req_orders_det(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE req_orders_detabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE pat_inst_head(ncalc=i2) = f8 WITH protect
 DECLARE pat_inst_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE pat_inst(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE pat_instabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE next_appt_head(ncalc=i2) = f8 WITH protect
 DECLARE next_appt_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE followup_section(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE followup_sectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8
 WITH protect
 DECLARE _loadimages(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remprocedure = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontprocedures = i2 WITH noconstant(0), protect
 DECLARE _reminstructions = i4 WITH noconstant(1), protect
 DECLARE _bcontmedinstructions = i2 WITH noconstant(0), protect
 DECLARE _remreq_order = i4 WITH noconstant(1), protect
 DECLARE _bcontreq_orders_det = i2 WITH noconstant(0), protect
 DECLARE _rempatient_instructions = i4 WITH noconstant(1), protect
 DECLARE _bcontpat_inst = i2 WITH noconstant(0), protect
 DECLARE _remfu_order = i4 WITH noconstant(1), protect
 DECLARE _bcontfollowup_section = i2 WITH noconstant(0), protect
 DECLARE _times14bu0 = i4 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _pen13s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _himage1 = i4 WITH noconstant(0), protect
 SUBROUTINE _loadimages(dummy)
   SET _himage1 = uar_rptinitimagefromfile(_hreport,rpt_jpeg,"BHSCUST:bayst_health_logo.jpg")
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE headpage(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = headpageabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE headpageabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.880000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 2.313)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.333
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Health Summary",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Birth",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age",char(0)))
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.031
    SET rptsd->m_height = 0.281
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Primary Care Physician",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.813),(offsetx+ 7.250),(offsety+
     0.813))
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Printed on: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 6.813)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(curdate,char(0)))
    SET rptsd->m_y = (offsety+ 0.344)
    SET rptsd->m_x = (offsetx+ 5.938)
    SET rptsd->m_width = 1.479
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _rptstat = uar_rptimagedraw(_hreport,_himage1,(offsetx+ 0.000),(offsety+ 0.000),2.250,
     0.500,1)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE patinfo(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = patinfoabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE patinfoabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE __name = vc WITH noconstant(build2(dlrec->seq[1].name_full_formatted,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(dlrec->seq[1].birth_dt_tm,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(dlrec->seq[1].age,char(0))), protect
   DECLARE __pcp = vc WITH noconstant(build2(dlrec->seq[1].pcpdoc_name,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.188
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__pcp)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE active_conditions_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = active_conditions_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE active_conditions_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Active Conditions",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.349),(offsetx+ 7.250),(offsety+
     0.349))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE active_conditions(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = active_conditionsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE active_conditionsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __condition = vc WITH noconstant(build2(dlrec->seq[1].problem[x].text,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__condition)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE allergies_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergies_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergies_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reaction",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.385),(offsetx+ 7.250),(offsety+
     0.385))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE allergies(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergiesabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE allergiesabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE __allergy = vc WITH noconstant(build2(dlrec->seq[1].allergy[x].source_string,char(0))),
   protect
   DECLARE __reaction = vc WITH noconstant(build2(dlrec->seq[1].allergy[x].reaction_display,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.688
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__allergy)
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.063
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__reaction)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE procedures_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = procedures_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE procedures_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.400000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Procedures",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Procedure",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.365),(offsetx+ 7.250),(offsety+
     0.365))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 1.729
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Provider",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE procedures(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = proceduresabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE proceduresabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_procedure = f8 WITH noconstant(0.0), private
   DECLARE __procedure = vc WITH noconstant(build2(dlrec->seq[1].procedure[x].proc_name,char(0))),
   protect
   DECLARE __procedure_date = vc WITH noconstant(build2(dlrec->seq[1].procedure[x].proc_dt_tm,char(0)
     )), protect
   DECLARE __procedure_provider = vc WITH noconstant(build2(dlrec->seq[1].procedure[x].proc_provider,
     char(0))), protect
   IF (bcontinue=0)
    SET _remprocedure = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.021)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremprocedure = _remprocedure
   IF (_remprocedure > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remprocedure,((size(
        __procedure) - _remprocedure)+ 1),__procedure)))
    SET drawheight_procedure = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remprocedure = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remprocedure,((size(__procedure) -
       _remprocedure)+ 1),__procedure)))))
     SET _remprocedure = (_remprocedure+ rptsd->m_drawlength)
    ELSE
     SET _remprocedure = 0
    ENDIF
    SET growsum = (growsum+ _remprocedure)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.021)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 3.500
   SET rptsd->m_height = drawheight_procedure
   IF (ncalc=rpt_render
    AND _holdremprocedure > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremprocedure,((size(
        __procedure) - _holdremprocedure)+ 1),__procedure)))
   ELSE
    SET _remprocedure = _holdremprocedure
   ENDIF
   SET rptsd->m_flags = 8
   SET rptsd->m_y = (offsety+ 0.021)
   SET rptsd->m_x = (offsetx+ 3.500)
   SET rptsd->m_width = 1.438
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__procedure_date)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.250)
   SET rptsd->m_width = 1.979
   SET rptsd->m_height = 0.260
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__procedure_provider)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medication_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medication_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medication_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Active Medications",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.318),(offsetx+ 7.250),(offsety+
     0.318))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medtitle(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medtitleabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medtitleabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __medication = vc WITH noconstant(build2(dlrec->seq[1].meds[x].ordered_as_mnemonic,char(0)
     )), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.438
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14bu0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__medication)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medications(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medicationsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medicationsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __dose = vc WITH noconstant(build2(dlrec->seq[1].meds[x].dose,char(0))), protect
   DECLARE __freq = vc WITH noconstant(build2(dlrec->seq[1].meds[x].freq,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.688)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dose)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.188
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__freq)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Dose:",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 3.500)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Freq:",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE medinstructions(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = medinstructionsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE medinstructionsabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_instructions = f8 WITH noconstant(0.0), private
   DECLARE __instructions = vc WITH noconstant(build2(dlrec->seq[1].meds[x].comments,char(0))),
   protect
   IF (bcontinue=0)
    SET _reminstructions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.188)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdreminstructions = _reminstructions
   IF (_reminstructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_reminstructions,((size(
        __instructions) - _reminstructions)+ 1),__instructions)))
    SET drawheight_instructions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _reminstructions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_reminstructions,((size(__instructions) -
       _reminstructions)+ 1),__instructions)))))
     SET _reminstructions = (_reminstructions+ rptsd->m_drawlength)
    ELSE
     SET _reminstructions = 0
    ENDIF
    SET growsum = (growsum+ _reminstructions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.188)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.000
   SET rptsd->m_height = drawheight_instructions
   IF (ncalc=rpt_render
    AND _holdreminstructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdreminstructions,((
       size(__instructions) - _holdreminstructions)+ 1),__instructions)))
   ELSE
    SET _reminstructions = _holdreminstructions
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Instructions",char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE immun_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immun_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE immun_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.250
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Immunizations",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Immunization Date",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.349),(offsetx+ 7.250),(offsety+
     0.349))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE immun(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = immunabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE immunabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   DECLARE __immunization = vc WITH noconstant(build2(dlrec->seq[1].immunization[x].name,char(0))),
   protect
   DECLARE __immunization_date = vc WITH noconstant(build2(dlrec->seq[1].immunization[x].given_date,
     char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 3.979
    SET rptsd->m_height = 0.281
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunization)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.000
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__immunization_date)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE measurements_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = measurements_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE measurements_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.420000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Measurements",char(0)))
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Result",char(0)))
    SET rptsd->m_y = (offsety+ 0.146)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date of Last Result",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.365),(offsetx+ 7.250),(offsety+
     0.365))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE measurements(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = measurementsabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE measurementsabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.020000), private
   DECLARE __weight_result = vc WITH noconstant(build2(dlrec->seq[1].measurements[x].wt_result,char(0
      ))), protect
   DECLARE __heart_rate_result = vc WITH noconstant(build2(dlrec->seq[1].measurements[x].pulse_result,
     char(0))), protect
   DECLARE __bp_result = vc WITH noconstant(build2(dlrec->seq[1].measurements[1].bp_display,char(0))),
   protect
   DECLARE __weight_date = vc WITH noconstant(build2(dlrec->seq[1].measurements[x].wt_dt_tm,char(0))),
   protect
   DECLARE __heart_rate_date = vc WITH noconstant(build2(dlrec->seq[1].measurements[x].pulse_dt_tm,
     char(0))), protect
   DECLARE __bp_date = vc WITH noconstant(build2(dlrec->seq[1].measurements[x].bp_dt_tm,char(0))),
   protect
   DECLARE __bmi_result = vc WITH noconstant(build2(dlrec->seq[1].measurements[1].s_bmi,char(0))),
   protect
   DECLARE __bmi_date = vc WITH noconstant(build2(dlrec->seq[1].measurements[1].s_bmi_dt_tm,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Weight",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.260
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Heart Rate",char(0)))
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Pressure",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__weight_result)
    SET rptsd->m_y = (offsety+ 0.240)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__heart_rate_result)
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bp_result)
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.229
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__weight_date)
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__heart_rate_date)
    SET rptsd->m_y = (offsety+ 0.521)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bp_date)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("BMI",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bmi_result)
    SET rptsd->m_y = (offsety+ 0.771)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bmi_date)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Health Maintenance",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Last Performed",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 6.313)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Overdue",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.365),(offsetx+ 7.250),(offsety+
     0.365))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Last Result",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_diab_ret_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_diab_ret_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_diab_ret_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __ret_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_diab_ret_due_dt_tm,char(0))),
   protect
   DECLARE __ret_overdue = vc WITH noconstant(build2(
     IF ((dlrec->seq[1].hm[1].n_diab_ret_overdue=1)) "YES"
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diabetic Retinal Eye Exam",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ret_date)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ret_overdue)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_diab_hba1c_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_diab_hba1c_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_diab_hba1c_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __hba1c_res = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_diab_hba1c_result,char(0))),
   protect
   DECLARE __hba1c_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_diab_hba1c_due_dt_tm,char(0
      ))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diabetic HbA1c",char(0)))
    SET rptsd->m_flags = 8
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hba1c_res)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__hba1c_date)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_diab_micro_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_diab_micro_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_diab_micro_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __microalb_res = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_ldl_result,char(0))),
   protect
   DECLARE __microalb_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_ldl_due_dt_tm,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diabetes Microalbumin",char(0)))
    SET rptsd->m_flags = 8
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__microalb_res)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__microalb_date)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_ldl_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_ldl_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_ldl_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __ldl_res = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_ldl_result,char(0))), protect
   DECLARE __ldl_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_ldl_due_dt_tm,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("LDL",char(0)))
    SET rptsd->m_flags = 8
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ldl_res)
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__ldl_date)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_mammo_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_mammo_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_mammo_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __mammo_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_mammo_due_dt_tm,char(0))),
   protect
   DECLARE __mammo_overdue = vc WITH noconstant(build2(
     IF ((dlrec->seq[1].hm[1].n_mammo_overdue=1)) "YES"
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.250)
    SET rptsd->m_width = 1.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mammo_date)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mammo_overdue)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Mammogram",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_cervical_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_cervical_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_cervical_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __cervical_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_cervical_due_dt_tm,char(
      0))), protect
   DECLARE __cervical_overdue = vc WITH noconstant(build2(
     IF ((dlrec->seq[1].hm[1].n_cervical_overdue=1)) "YES"
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Cervical Cancer Screening",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cervical_date)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__cervical_overdue)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE hm_colo_section(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = hm_colo_sectionabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE hm_colo_sectionabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE __colo_date = vc WITH noconstant(build2(dlrec->seq[1].hm[1].s_colo_due_dt_tm,char(0))),
   protect
   DECLARE __colo_overdue = vc WITH noconstant(build2(
     IF ((dlrec->seq[1].hm[1].n_colo_overdue=1)) "YES"
     ENDIF
     ,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Colorectal Cancer Screening",char(0))
     )
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__colo_date)
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 6.250)
    SET rptsd->m_width = 1.177
    SET rptsd->m_height = 0.260
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__colo_overdue)
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE req_orders_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.260
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pending Orders",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.302),(offsetx+ 7.250),(offsety+
     0.302))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE req_orders_det(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = req_orders_detabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE req_orders_detabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_req_order = f8 WITH noconstant(0.0), private
   DECLARE __req_order = vc WITH noconstant(build2(dlrec->seq[1].req_ords[x].s_name,char(0))),
   protect
   IF (bcontinue=0)
    SET _remreq_order = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremreq_order = _remreq_order
   IF (_remreq_order > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remreq_order,((size(
        __req_order) - _remreq_order)+ 1),__req_order)))
    SET drawheight_req_order = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remreq_order = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remreq_order,((size(__req_order) -
       _remreq_order)+ 1),__req_order)))))
     SET _remreq_order = (_remreq_order+ rptsd->m_drawlength)
    ELSE
     SET _remreq_order = 0
    ENDIF
    SET growsum = (growsum+ _remreq_order)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_req_order
   IF (ncalc=rpt_render
    AND _holdremreq_order > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremreq_order,((size(
        __req_order) - _holdremreq_order)+ 1),__req_order)))
   ELSE
    SET _remreq_order = _holdremreq_order
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pat_inst_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pat_inst_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pat_inst_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.440000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.979
    SET rptsd->m_height = 0.302
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Instructions",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.365),(offsetx+ 7.250),(offsety+
     0.365))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE pat_inst(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pat_instabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE pat_instabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_patient_instructions = f8 WITH noconstant(0.0), private
   DECLARE __patient_instructions = vc WITH noconstant(build2(dlrec->seq[1].pat_inst[x].text,char(0))
    ), protect
   IF (bcontinue=0)
    SET _rempatient_instructions = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempatient_instructions = _rempatient_instructions
   IF (_rempatient_instructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempatient_instructions,(
       (size(__patient_instructions) - _rempatient_instructions)+ 1),__patient_instructions)))
    SET drawheight_patient_instructions = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempatient_instructions = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempatient_instructions,((size(
        __patient_instructions) - _rempatient_instructions)+ 1),__patient_instructions)))))
     SET _rempatient_instructions = (_rempatient_instructions+ rptsd->m_drawlength)
    ELSE
     SET _rempatient_instructions = 0
    ENDIF
    SET growsum = (growsum+ _rempatient_instructions)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_patient_instructions
   IF (ncalc=rpt_render
    AND _holdrempatient_instructions > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(
       _holdrempatient_instructions,((size(__patient_instructions) - _holdrempatient_instructions)+ 1
       ),__patient_instructions)))
   ELSE
    SET _rempatient_instructions = _holdrempatient_instructions
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE next_appt_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = next_appt_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE next_appt_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.750
    SET rptsd->m_height = 0.281
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Next Appointment:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 1.688),(offsety+ 0.318),(offsetx+ 7.251),(offsety+
     0.318))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE followup_section(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = followup_sectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE followup_sectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fu_order = f8 WITH noconstant(0.0), private
   DECLARE __fu_order = vc WITH noconstant(build2(concat(dlrec->seq[1].fu_ords[x].s_name,", ",dlrec->
      seq[1].fu_ords[x].s_ord_desc),char(0))), protect
   IF (bcontinue=0)
    SET _remfu_order = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times140)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfu_order = _remfu_order
   IF (_remfu_order > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfu_order,((size(
        __fu_order) - _remfu_order)+ 1),__fu_order)))
    SET drawheight_fu_order = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfu_order = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfu_order,((size(__fu_order) -
       _remfu_order)+ 1),__fu_order)))))
     SET _remfu_order = (_remfu_order+ rptsd->m_drawlength)
    ELSE
     SET _remfu_order = 0
    ENDIF
    SET growsum = (growsum+ _remfu_order)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.000)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.250)
   SET rptsd->m_width = 7.250
   SET rptsd->m_height = drawheight_fu_order
   IF (ncalc=rpt_render
    AND _holdremfu_order > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfu_order,((size(
        __fu_order) - _holdremfu_order)+ 1),__fu_order)))
   ELSE
    SET _remfu_order = _holdremfu_order
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "BHS_PT_FRIENDLY_SUMMARY"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _stat = _loadimages(0)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_on
   SET _times14bu0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET _pen13s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 DECLARE becont = i2
 DECLARE sub_head_page(beg_report=i2) = null
 DECLARE sub_foot_page(end_report=i2) = null
 SUBROUTINE sub_head_page(beg_report)
  SET d0 = headpage(rpt_render)
  SET d0 = patinfo(rpt_render)
 END ;Subroutine
 SUBROUTINE sub_foot_page(end_report)
   IF (end_report=0)
    SET d0 = pagebreak(0)
   ENDIF
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = sub_head_page(0)
 IF (((_yoffset+ active_conditions_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ENDIF
 SET d0 = active_conditions_head(rpt_render)
 FOR (x = 1 TO size(dlrec->seq[1].problem,5))
  IF (((_yoffset+ active_conditions(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = active_conditions_head(rpt_render)
  ENDIF
  SET d0 = active_conditions(rpt_render)
 ENDFOR
 IF (size(dlrec->seq[1].procedure,5) > 0)
  IF (((_yoffset+ procedures_head(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
  ENDIF
  SET d0 = procedures_head(rpt_render)
  FOR (x = 1 TO size(dlrec->seq[1].procedure,5))
   IF (((_yoffset+ procedures(rpt_calcheight,8.0,becont)) > 10.0))
    SET d0 = sub_foot_page(0)
    SET d0 = sub_head_page(0)
    SET d0 = procedures_head(rpt_render)
   ENDIF
   SET d0 = procedures(rpt_render,8.0,becont)
  ENDFOR
 ENDIF
 IF (((_yoffset+ allergies_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ENDIF
 SET d0 = allergies_head(rpt_render)
 FOR (x = 1 TO size(dlrec->seq[1].allergy,5))
  IF (((_yoffset+ allergies(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = allergies_head(rpt_render)
  ENDIF
  SET d0 = allergies(rpt_render)
 ENDFOR
 IF (size(dlrec->seq[1].meds,5) > 0)
  IF (((_yoffset+ medication_head(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
  ENDIF
  SET d0 = medication_head(rpt_render)
  FOR (x = 1 TO size(dlrec->seq[1].meds,5))
    IF (((_yoffset+ medications(rpt_calcheight)) > 10.0))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
     SET d0 = medication_head(rpt_render)
    ENDIF
    SET d0 = medtitle(rpt_render)
    SET d0 = medications(rpt_render)
  ENDFOR
 ENDIF
 IF (((_yoffset+ immun_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
 ENDIF
 SET d0 = immun_head(rpt_render)
 FOR (x = 1 TO size(dlrec->seq[1].immunization,5))
  IF (((_yoffset+ immun(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = immun_head(rpt_render)
  ENDIF
  SET d0 = immun(rpt_render)
 ENDFOR
 IF (((_yoffset+ measurements_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ENDIF
 SET d0 = measurements_head(rpt_render)
 FOR (x = 1 TO size(dlrec->seq[1].measurements,5))
  IF (((_yoffset+ measurements(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = measurements_head(rpt_render)
  ENDIF
  SET d0 = measurements(rpt_render)
 ENDFOR
 SELECT INTO "nl:"
  FROM bhs_nomen_list b,
   problem p
  PLAN (p
   WHERE (p.person_id=dlrec->seq[1].person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (b
   WHERE b.nomenclature_id=p.nomenclature_id
    AND b.active_ind=1
    AND b.nomen_list_key="HM_DIABETESSCREENING")
  HEAD p.person_id
   mn_diab_ind = 1
  WITH nocounter
 ;end select
 IF (((_yoffset+ hm_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ELSEIF ((((_yoffset+ hm_head(rpt_calcheight))+ 0.25) > 10))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ENDIF
 SET d0 = hm_head(rpt_render)
 IF (mn_diab_ind=1)
  IF (((_yoffset+ hm_diab_ret_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_diab_ret_section(rpt_render)
 ENDIF
 IF (mn_diab_ind=1)
  IF (((_yoffset+ hm_diab_hba1c_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_diab_hba1c_section(rpt_render)
 ENDIF
 IF (mn_diab_ind=1)
  IF (((_yoffset+ hm_diab_micro_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_diab_micro_section(rpt_render)
 ENDIF
 IF ((((((dlrec->seq[1].f_sex_cd=mf_male_cd)
  AND (dlrec->seq[1].l_age_in_yrs >= 35)) OR ((dlrec->seq[1].f_sex_cd=mf_female_cd)
  AND (dlrec->seq[1].l_age_in_yrs >= 45)))
  AND trim(dlrec->seq[1].hm[1].s_ldl_result) > " ") OR (trim(dlrec->seq[1].hm[1].s_ldl_result) > " "
 )) )
  IF (((_yoffset+ hm_ldl_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_ldl_section(rpt_render)
 ENDIF
 IF ((dlrec->seq[1].f_sex_cd=mf_female_cd)
  AND (dlrec->seq[1].l_age_in_yrs BETWEEN 40 AND 100))
  IF (((_yoffset+ hm_mammo_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_mammo_section(rpt_render)
 ENDIF
 IF ((dlrec->seq[1].f_sex_cd=mf_female_cd)
  AND (dlrec->seq[1].l_age_in_yrs BETWEEN 21 AND 65))
  IF (((_yoffset+ hm_cervical_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_cervical_section(rpt_render)
 ENDIF
 IF ((dlrec->seq[1].l_age_in_yrs BETWEEN 50 AND 85))
  IF (((_yoffset+ hm_colo_section(rpt_calcheight)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = hm_head(rpt_render)
  ENDIF
  SET d0 = hm_colo_section(rpt_render)
 ENDIF
 IF (size(dlrec->seq[1].req_ords,5) > 0)
  SET x = 1
  IF ((((_yoffset+ req_orders_head(rpt_calcheight))+ 0.25) > 10))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
  ENDIF
  SET d0 = req_orders_head(rpt_render)
  FOR (x = 1 TO size(dlrec->seq[1].req_ords,5))
    IF (((_yoffset+ 0.25) > 10))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
     SET d0 = req_orders_head(rpt_render)
    ENDIF
    SET mf_rem_space = (10 - _yoffset)
    SET d0 = req_orders_det(rpt_render,mf_rem_space,becont)
    WHILE (becont=1)
      SET d0 = sub_foot_page(0)
      SET d0 = sub_head_page(0)
      SET d0 = req_orders_head(rpt_render)
      SET d0 = req_orders_head(rpt_render)
    ENDWHILE
  ENDFOR
 ENDIF
 IF (((_yoffset+ pat_inst_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ENDIF
 SET d0 = pat_inst_head(rpt_render)
 FOR (x = 1 TO size(dlrec->seq[1].pat_inst,5))
  IF (((_yoffset+ pat_inst(rpt_calcheight,8.0,becont)) > 10.0))
   SET d0 = sub_foot_page(0)
   SET d0 = sub_head_page(0)
   SET d0 = pat_inst_head(rpt_render)
  ENDIF
  SET d0 = pat_inst(rpt_render,8.0,becont)
 ENDFOR
 IF (((_yoffset+ next_appt_head(rpt_calcheight)) > 10.0))
  SET d0 = sub_foot_page(0)
  SET d0 = sub_head_page(0)
 ENDIF
 SET d0 = next_appt_head(rpt_render)
 IF (size(dlrec->seq[1].fu_ords,5) > 0)
  FOR (x = 1 TO size(dlrec->seq[1].fu_ords,5))
    IF (((_yoffset+ 0.25) > 10))
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
    ENDIF
    SET mf_rem_space = (10 - _yoffset)
    SET d0 = followup_section(rpt_render,mf_rem_space,becont)
    WHILE (becont=1)
     SET d0 = sub_foot_page(0)
     SET d0 = sub_head_page(0)
    ENDWHILE
  ENDFOR
 ENDIF
 SET d0 = finalizereport(output_device)
 CALL echorecord(dlrec)
END GO
