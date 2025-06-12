CREATE PROGRAM bhs_dt_clin_sum:dba
 PROMPT
  "Printer" = "mine",
  "Unit_cd" = 0,
  "Report_cd" = 0
  WITH prompt1, unit_cd, report_cd
 SET report_code = 17280799.00
 SET date_class = uar_get_code_by("displaykey",53,"DATE")
 SET fin_type = uar_get_code_by("displaykey",319,"FINNBR")
 SET mrn_type = uar_get_code_by("displaykey",319,"MRN")
 RECORD act_pat(
   1 qual[*]
     2 eid = f8
     2 reg_dt_tm = vc
     2 pid = f8
     2 unit = c20
     2 room = c20
     2 bed = c10
     2 visit_reason = vc
 )
 RECORD pat(
   1 qual[*]
     2 pid = f8
     2 eid = f8
     2 name = vc
     2 religion = c30
     2 language = c30
     2 att_doc = c30
     2 pcp_doc = c30
     2 teaching_doc = c30
     2 visit_reason = vc
     2 diagnosis = vc
     2 allergy = vc
     2 birth_dt = dq8
     2 mrn = c20
     2 cmrn = c20
     2 admit_dt = dq8
     2 fin = c20
     2 unit_room_bed = vc
     2 sec[*]
       3 sec_disp = vc
       3 sec_event_id = f8
       3 grpr[*]
         4 grpr_disp = vc
         4 grpr_date = dq8
         4 event[*]
           5 event_disp = vc
           5 event_cnt = i2
           5 max_lookback_hrs = i2
           5 max_result_qty = i2
           5 result[*]
             6 event_result = vc
             6 begin_dt_time = dq8
             6 end_dt_tm = dq8
             6 result_age = i2
     2 ntnord[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 mdtrnord[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 diet[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 resp[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 monitor[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 lab_rad_ekg[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 cprocedure[*]
       3 order_mnemonic = vc
       3 clinical_display = vc
       3 com_ind = i2
       3 comment = vc
     2 problems[*]
       3 problem_line = vc
 )
 DECLARE att_cd = f8
 DECLARE pcp_cd = f8
 DECLARE teaching_cd = f8
 SET teaching_cd = uar_get_code_by("displaykey",333,"TEACHINGCOVERAGE")
 SET pcp_cd = uar_get_code_by("displaykey",333,"PRIMARYCAREPHYSICIAN")
 SET att_cd = uar_get_code_by("displaykey",333,"ATTENDINGPHYSICIAN")
 DECLARE chiefcomplaint_cd = f8
 SET chiefcomplaint_cd = uar_get_code_by("DISPLAYKEY",72,"CHIEFCOMPLAINT")
 DECLARE pid = f8
 DECLARE eid = f8
 DECLARE iv_type_cd = f8
 DECLARE med_type_cd = f8
 DECLARE num_type_cd = f8
 DECLARE not_done_cd = f8
 DECLARE voided_cd = f8
 DECLARE begin_bag_cd = f8
 DECLARE site_chg_cd = f8
 DECLARE rate_chg_cd = f8
 DECLARE pain_rspns_cd = f8
 DECLARE med_reason_cd = f8
 DECLARE result_cmnt_cd = f8
 DECLARE compress_cd = f8
 DECLARE scope_clause = vc
 DECLARE date_clause = vc
 DECLARE max_num_sched_admins = i4
 DECLARE max_num_prn_admins = i4
 DECLARE max_num_cont_admins = i4
 DECLARE max_num_sched_actions = i4
 DECLARE max_num_prn_actions = i4
 DECLARE max_num_cont_actions = i4
 DECLARE schedordercnt = i4
 DECLARE assignscopeclause(null) = null
 DECLARE assigndateclause(null) = null
 DECLARE getqualifyingorders(null) = null
 DECLARE getscheduledmeds1(null) = null
 DECLARE getscheduledmeds2(null) = null
 DECLARE getvoidedindforscheduled(null) = null
 DECLARE getprnmeds(null) = null
 DECLARE getcontinuousmeds(null) = null
 DECLARE getvitalsigns(null) = null
 DECLARE getcomments(null) = null
 DECLARE getschedvsprnfield(null) = null
 DECLARE expanddetails(null) = null
 DECLARE checkforerror(qual_num=i4,op_name=vc,force_exit=i2) = null
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(18309,"IV",1,iv_type_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MED",1,med_type_cd)
 SET stat = uar_get_meaning_by_codeset(53,"NUM",1,num_type_cd)
 SET stat = uar_get_meaning_by_codeset(8,"NOT DONE",1,not_done_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,voided_cd)
 SET stat = uar_get_meaning_by_codeset(180,"BEGIN",1,begin_bag_cd)
 SET stat = uar_get_meaning_by_codeset(180,"RATECHG",1,rate_chg_cd)
 SET stat = uar_get_meaning_by_codeset(180,"SITECHG",1,site_chg_cd)
 SET stat = uar_get_meaning_by_codeset(14,"RES COMMENT",1,result_cmnt_cd)
 SET stat = uar_get_meaning_by_codeset(14,"RESPONSETO",1,pain_rspns_cd)
 SET stat = uar_get_meaning_by_codeset(14,"REASONFOR",1,med_reason_cd)
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,compress_cd)
 SET pain_intensity = 680246
 SET pulse_rate = 680299
 SET systolic_pressure = 723257
 SET diastolic_pressure = 723267
 SET code_value = 0
 SET pharmacy = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy = code_value
 DECLARE date = cv
 DECLARE os_can_cd = f8
 DECLARE os_dis_cd = f8
 DECLARE os_com_cd = f8
 DECLARE os_del_cd = f8
 DECLARE os_fut_cd = f8
 DECLARE os_inp_cd = f8
 DECLARE os_inc_cd = f8
 DECLARE os_med_cd = f8
 DECLARE os_ord_cd = f8
 DECLARE os_pen_cd = f8
 DECLARE os_per_cd = f8
 DECLARE os_sus_cd = f8
 DECLARE os_tra_cd = f8
 DECLARE os_uns_cd = f8
 DECLARE os_voi_cd = f8
 SET kram = uar_get_meaning_by_codeset(6004,"CANCELED",1,os_can_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"DISCONTINUED",1,os_dis_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"COMPLETED",1,os_com_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"DELETED",1,os_del_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"FUTURE",1,os_fut_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"INPROCESS",1,os_inp_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"INCOMPLETE",1,os_inc_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"MEDSTUDENT",1,os_med_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"ORDERED",1,os_ord_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"PENDING",1,os_pen_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"PENDING REV",1,os_per_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"SUSPENDED",1,os_sus_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"TRANS/CANCEL",1,os_tra_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"UNSCHEDULED",1,os_uns_cd)
 SET kram = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,os_voi_cd)
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE notdone_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE callmd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CALLMD"))
 DECLARE rntorn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RNTORN"))
 DECLARE dietary_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"DIETARY"))
 DECLARE respther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"RESP THER"))
 DECLARE woundcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"WOUNDCARE"))
 DECLARE orthopedictreatments_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ORTHOPEDICTREATMENTS"))
 DECLARE orthosupply_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ORTHOSUPPLY"))
 DECLARE asmttxmonitoring_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ASMTTXMONITORING"))
 DECLARE intakeandoutput_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "INTAKEANDOUTPUT"))
 DECLARE anatomicpathology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "ANATOMICPATHOLOGY"))
 DECLARE bloodbank_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANK"))
 DECLARE bloodbankmlh_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"BLOODBANKMLH"))
 DECLARE cardiactxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "CARDIACTXPROCEDURES"))
 DECLARE ecg_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"ECG"))
 DECLARE pointofcare_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"POINTOFCARE"))
 DECLARE radiology_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY"))
 DECLARE generallab_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"GENERALLAB"))
 DECLARE micro_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"MICRO"))
 DECLARE physther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE occther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE speechther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE audiology_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE antepartum_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE neurodiag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE pulmlab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE noninvasivecardiologytxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   106,"NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE mdtornconsults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNCONSULTS"))
 DECLARE consults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTS"))
 DECLARE hyperbaricoxygentx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "HYPERBARICOXYGENTX"))
 DECLARE mdtorntxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNTXPROCEDURES"))
 DECLARE allergy_cancelled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE snmct_cd = f8 WITH public, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE tempstring = vc
 DECLARE comment_string = vc
 SELECT INTO "nl:"
  unit = uar_get_code_display(ed.loc_nurse_unit_cd), room = uar_get_code_display(ed.loc_room_cd), bed
   = uar_get_code_display(ed.loc_bed_cd)
  FROM encntr_domain ed,
   encounter e
  PLAN (ed
   WHERE ed.encntr_id=20896902.00
    AND ed.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ed.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id)
  ORDER BY unit, room, bed
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1, stat = alterlist(act_pat->qual,cnt), act_pat->qual[cnt].eid = ed.encntr_id,
   act_pat->qual[cnt].unit = unit, act_pat->qual[cnt].room = room, act_pat->qual[cnt].bed = bed,
   act_pat->qual[cnt].reg_dt_tm = format(e.reg_dt_tm,"mm/dd/yy hh:mm:ss;;q"), act_pat->qual[cnt].pid
    = e.person_id, act_pat->qual[cnt].visit_reason = trim(e.reason_for_visit)
  WITH nocounter
 ;end select
 SET pat_cnt = size(act_pat->qual,5)
 SELECT INTO "nl:"
  unit = act_pat->qual[d.seq].unit, room = act_pat->qual[d.seq].room, bed = act_pat->qual[d.seq].bed,
  result_age = datetimediff(cnvtdatetime(sysdate),ce.event_end_dt_tm,3), visit_reason = trim(act_pat
   ->qual[d.seq].visit_reason)
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   clinical_event ce,
   bhs_grpr_dta_event_r dta,
   bhs_sect_grpr_r grpr,
   bhs_rept_sect_r sec
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=act_pat->qual[d.seq].eid)
    AND (ce.person_id=act_pat->qual[d.seq].pid)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1)
   JOIN (dta
   WHERE dta.event_cd=ce.event_cd
    AND dta.active_ind=1)
   JOIN (grpr
   WHERE grpr.grouper_cd=dta.grouper_cd
    AND grpr.active_ind=1)
   JOIN (sec
   WHERE sec.section_cd=grpr.section_cd
    AND sec.report_cd=report_code
    AND sec.active_ind=1)
  ORDER BY ce.encntr_id, sec.section_seq, grpr.grouper_seq,
   dta.task_assay_seq, ce.event_cd, ce.valid_from_dt_tm DESC
  HEAD REPORT
   cnt = 0, cnt2 = 0, cnt3 = 0,
   cnt4 = 0, cnt5 = 0
  HEAD ce.encntr_id
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt += 1, stat = alterlist(pat->qual,cnt), pat->qual[cnt].pid = ce.person_id,
    pat->qual[cnt].eid = ce.encntr_id, pat->qual[cnt].unit_room_bed = build(unit,"/",room,"-",bed),
    pat->qual[cnt].visit_reason = visit_reason
   ENDIF
   cnt2 = 0
  HEAD sec.section_seq
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt2 += 1, stat = alterlist(pat->qual[cnt].sec,cnt2), pat->qual[cnt].sec[cnt2].sec_disp =
    uar_get_code_display(sec.section_cd)
   ENDIF
   cnt3 = 0
  HEAD grpr.grouper_seq
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt3 += 1, stat = alterlist(pat->qual[cnt].sec[cnt2].grpr,cnt3), pat->qual[cnt].sec[cnt2].grpr[
    cnt3].grpr_disp = uar_get_code_display(grpr.grouper_cd),
    pat->qual[cnt].sec[cnt2].grpr[cnt3].grpr_date = ce.event_end_dt_tm
   ENDIF
   cnt4 = 0
  HEAD ce.event_cd
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt4 += 1, stat = alterlist(pat->qual[cnt].sec[cnt2].grpr[cnt3].event,cnt4), pat->qual[cnt].sec[
    cnt2].grpr[cnt3].event[cnt4].event_disp = dta.event_display,
    pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].max_lookback_hrs = dta.max_lookback_hours, pat->
    qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].max_result_qty = dta.max_result_qty
   ENDIF
   cnt5 = 0
  DETAIL
   IF (((dta.max_lookback_hours=0) OR (result_age <= dta.max_lookback_hours)) )
    cnt5 += 1, stat = alterlist(pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result,cnt5), pat->
    qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].event_cnt = cnt5
    IF (ce.event_class_cd=date_class)
     result = build(substring(7,2,ce.result_val),"/",substring(9,2,ce.result_val),"/",substring(3,4,
       ce.result_val)), pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].event_result =
     result
    ELSE
     pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].event_result = concat(ce.result_val
      )
    ENDIF
    pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].begin_dt_time = ce.valid_from_dt_tm,
    pat->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].end_dt_tm = ce.event_end_dt_tm, pat
    ->qual[cnt].sec[cnt2].grpr[cnt3].event[cnt4].result[cnt5].result_age = datetimediff(cnvtdatetime(
      sysdate),ce.event_end_dt_tm,3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  name = trim(p.name_full_formatted), alias = trim(ea.alias)
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   person p,
   encntr_alias ea
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=pat->qual[d.seq].pid))
   JOIN (ea
   WHERE (ea.encntr_id=pat->qual[d.seq].eid)
    AND ea.encntr_alias_type_cd IN (fin_type, mrn_type))
  DETAIL
   pat->qual[d.seq].name = name, pat->qual[d.seq].religion = substring(1,30,uar_get_code_display(p
     .religion_cd)), pat->qual[d.seq].language = substring(1,30,uar_get_code_display(p.language_cd))
   IF (ea.encntr_alias_type_cd=fin_type)
    pat->qual[d.seq].fin = alias
   ELSEIF (ea.encntr_alias_type_cd=mrn_type)
    pat->qual[d.seq].mrn = alias
   ENDIF
   pat->qual[d.seq].birth_dt = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pat_cnt)),
   encntr_prsnl_reltn epr,
   prsnl p
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=pat->qual[d.seq].eid)
    AND epr.expiration_ind=0)
   JOIN (p
   WHERE epr.prsnl_person_id=p.person_id)
  DETAIL
   IF (epr.encntr_prsnl_r_cd=att_cd)
    pat->qual[d.seq].att_doc = substring(1,20,p.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=pcp_cd)
    pat->qual[d.seq].pcp_doc = substring(1,20,p.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=teaching_cd)
    pat->qual[d.seq].teaching_doc = substring(1,20,p.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   diagnosis d,
   nomenclature n
  PLAN (d1)
   JOIN (d
   WHERE (d.encntr_id=pat->qual[d1.seq].eid)
    AND d.active_ind=1)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(d.nomenclature_id)) )
  ORDER BY d.encntr_id, d.diag_dt_tm DESC, d.nomenclature_id
  HEAD d.encntr_id
   cnt = 0
  DETAIL
   IF (n.nomenclature_id > 0)
    pat->qual[d1.seq].diagnosis = n.source_string
   ELSE
    pat->qual[d1.seq].diagnosis = d.diag_ftdesc
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("I am in chief complaint")
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   clinical_event c
  PLAN (d1)
   JOIN (c
   WHERE (c.person_id=pat->qual[d1.seq].pid)
    AND c.event_cd=chiefcomplaint_cd
    AND (pat->qual[d1.seq].eid=(c.encntr_id+ 0))
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-dec-2100,00:00:00")
    AND  NOT (c.result_status_cd IN (inerror_cd, notdone_cd))
    AND c.event_tag > " ")
  ORDER BY c.encntr_id, c.event_end_dt_tm DESC
  HEAD c.encntr_id
   IF (trim(pat->qual[d1.seq].diagnosis) > "")
    pat->qual[d1.seq].diagnosis = trim(c.result_val)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   orders o,
   order_comment oc,
   long_text lt
  PLAN (d1)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[d1.seq].eid)
    AND o.order_status_cd IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd)
    AND o.template_order_flag IN (0, 1)
    AND o.activity_type_cd IN (callmd_cd, rntorn_cd, dietary_cd, respther_cd, woundcare_cd,
   orthopedictreatments_cd, orthosupply_cd, asmttxmonitoring_cd, intakeandoutput_cd,
   anatomicpathology_cd,
   bloodbank_cd, bloodbankmlh_cd, cardiactxprocedures_cd, ecg_cd, generallab_cd,
   micro_cd, pointofcare_cd, radiology_cd))
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
    AND (lt.active_ind= Outerjoin(1))
    AND (lt.parent_entity_name= Outerjoin("ORDER_COMMENT")) )
  ORDER BY o.encntr_id, o.activity_type_cd
  HEAD o.encntr_id
   cnt1 = 0, cnt2 = 0, cnt3 = 0,
   cnt4 = 0, cnt5 = 0, cnt6 = 0,
   cnt7 = 0, cnt8 = 0, cnt9 = 0,
   cnt10 = 0
  DETAIL
   IF (o.activity_type_cd=rntorn_cd)
    cnt1 += 1
    IF (mod(cnt1,10)=1)
     stat = alterlist(pat->qual[d1.seq].ntnord,(cnt1+ 9))
    ENDIF
    pat->qual[d1.seq].ntnord[cnt1].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].ntnord[cnt1].
    clinical_display = o.clinical_display_line, pat->qual[d1.seq].ntnord[cnt1].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].ntnord[cnt1].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd=callmd_cd)
    cnt2 += 1
    IF (mod(cnt2,10)=1)
     stat = alterlist(pat->qual[d1.seq].mdtrnord,(cnt2+ 9))
    ENDIF
    pat->qual[d1.seq].mdtrnord[cnt2].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].mdtrnord[
    cnt2].clinical_display = o.clinical_display_line, pat->qual[d1.seq].mdtrnord[cnt2].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].mdtrnord[cnt2].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd=dietary_cd)
    cnt3 += 1
    IF (mod(cnt3,10)=1)
     stat = alterlist(pat->qual[d1.seq].diet,(cnt3+ 9))
    ENDIF
    pat->qual[d1.seq].diet[cnt3].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].diet[cnt3].
    clinical_display = o.clinical_display_line, pat->qual[d1.seq].diet[cnt3].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].diet[cnt3].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd=respther_cd)
    cnt4 += 1
    IF (mod(cnt4,10)=1)
     stat = alterlist(pat->qual[d1.seq].resp,(cnt4+ 9))
    ENDIF
    pat->qual[d1.seq].resp[cnt4].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].resp[cnt4].
    clinical_display = o.clinical_display_line, pat->qual[d1.seq].resp[cnt4].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].resp[cnt4].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd IN (woundcare_cd, orthopedictreatments_cd, orthosupply_cd,
   asmttxmonitoring_cd, intakeandoutput_cd))
    cnt5 += 1
    IF (mod(cnt5,10)=1)
     stat = alterlist(pat->qual[d1.seq].monitor,(cnt5+ 9))
    ENDIF
    pat->qual[d1.seq].monitor[cnt5].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].monitor[cnt5
    ].clinical_display = o.clinical_display_line, pat->qual[d1.seq].monitor[cnt5].com_ind = o
    .order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].monitor[cnt5].comment = lt.long_text
    ENDIF
   ELSEIF (o.activity_type_cd IN (anatomicpathology_cd, bloodbank_cd, bloodbankmlh_cd,
   cardiactxprocedures_cd, ecg_cd,
   generallab_cd, micro_cd, pointofcare_cd, radiology_cd))
    cnt6 += 1
    IF (mod(cnt6,10)=1)
     stat = alterlist(pat->qual[d1.seq].lab_rad_ekg,(cnt6+ 9))
    ENDIF
    pat->qual[d1.seq].lab_rad_ekg[cnt6].order_mnemonic = o.order_mnemonic, pat->qual[d1.seq].
    lab_rad_ekg[cnt6].clinical_display = o.clinical_display_line, pat->qual[d1.seq].lab_rad_ekg[cnt6]
    .com_ind = o.order_comment_ind
    IF (o.order_comment_ind=1)
     pat->qual[d1.seq].lab_rad_ekg[cnt6].comment = lt.long_text
    ENDIF
   ENDIF
  FOOT  o.encntr_id
   stat = alterlist(pat->qual[d1.seq].ntnord,cnt1), stat = alterlist(pat->qual[d1.seq].mdtrnord,cnt2),
   stat = alterlist(pat->qual[d1.seq].diet,cnt3),
   stat = alterlist(pat->qual[d1.seq].resp,cnt4), stat = alterlist(pat->qual[d1.seq].monitor,cnt5),
   stat = alterlist(pat->qual[d1.seq].lab_rad_ekg,cnt6)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   orders o,
   order_comment oc,
   long_text lt
  PLAN (d1)
   JOIN (o
   WHERE (o.encntr_id=pat->qual[d1.seq].eid)
    AND o.order_status_cd IN (os_inc_cd, os_inp_cd, os_ord_cd, os_pen_cd, os_per_cd)
    AND o.template_order_flag IN (0, 1)
    AND ((o.catalog_type_cd IN (physther_cd, occther_cd, speechther_cd, audiology_cd, antepartum_cd,
   neurodiag_cd, pulmlab_cd)) OR (o.activity_type_cd IN (noninvasivecardiologytxprocedures_cd,
   hyperbaricoxygentx_cd, mdtornconsults_cd, consults_cd, mdtorntxprocedures_cd))) )
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id)) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
    AND (lt.active_ind= Outerjoin(1))
    AND (lt.parent_entity_name= Outerjoin("ORDER_COMMENT")) )
  ORDER BY o.encntr_id, o.activity_type_cd
  HEAD o.encntr_id
   cnt = 0
  DETAIL
   cnt += 1, stat = alterlist(pat->qual[d1.seq].cprocedure,cnt), pat->qual[d1.seq].cprocedure[cnt].
   order_mnemonic = o.order_mnemonic,
   pat->qual[d1.seq].cprocedure[cnt].clinical_display = o.clinical_display_line, pat->qual[d1.seq].
   cprocedure[cnt].com_ind = o.order_comment_ind
   IF (o.order_comment_ind=1)
    pat->qual[d1.seq].cprocedure[cnt].comment = lt.long_text
   ENDIF
  WITH conounter
 ;end select
 FOR (x = 1 TO pat_cnt)
   SELECT DISTINCT INTO "nl:"
    short_source_string = concat(trim(substring(1,40,n.source_string)),trim(substring(1,40,a
       .substance_ftdesc))), substance_type_disp =
    IF (uar_get_code_display(a.substance_type_cd) > " ") uar_get_code_display(a.substance_type_cd)
    ELSE "Other "
    ENDIF
    FROM allergy a,
     nomenclature n
    PLAN (a
     WHERE (a.person_id=pat->qual[x].pid)
      AND a.active_ind=1
      AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((a.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (a.end_effective_dt_tm=null))
      AND a.reaction_status_cd != allergy_cancelled_cd)
     JOIN (n
     WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
    ORDER BY a.person_id, substance_type_disp, short_source_string
    DETAIL
     pat->qual[x].allergy = concat(build(substance_type_disp,": ")," ",short_source_string)
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl"
  FROM (dummyt d1  WITH seq = value(pat_cnt)),
   problem p,
   nomenclature n
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=pat->qual[d1.seq].pid)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((p.end_effective_dt_tm >= cnvtdatetime(sysdate)) OR (p.end_effective_dt_tm=null)) )
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(p.nomenclature_id))
    AND n.source_vocabulary_cd=snmct_cd)
  ORDER BY p.person_id, cnvtdatetime(p.onset_dt_tm) DESC
  HEAD p.person_id
   cnt = 0
  DETAIL
   IF (((n.source_string > " ") OR (p.problem_ftdesc > " ")) )
    cnt += 1, stat = alterlist(pat->qual[d1.seq].problems,cnt)
    IF (p.nomenclature_id > 0)
     pat->qual[d1.seq].problems[cnt].problem_line = n.source_string
    ELSE
     pat->qual[d1.seq].problems[cnt].problem_line = p.problem_ftdesc
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO pat_cnt)
   SET personid = pat->qual[x].pid
   SET encntrid = pat->qual[x].eid
   FREE RECORD scheduled_orders
   RECORD scheduled_orders(
     1 qual[*]
       2 order_id = f8
       2 true_parent = i2
       2 order_detail = vc
       2 order_name = vc
       2 comment = vc
       2 print_ind = i2
       2 child_ord[*]
         3 order_id = f8
         3 start_dt = dq8
         3 order_mnemonic = vc
   )
   FREE RECORD scheduled_orders_disp
   RECORD scheduled_orders_disp(
     1 scheduled_orders[*]
       2 template_order_id = f8
       2 comment = vc
       2 orig_order_dt_tm = dq8
       2 mnemonic = vc
       2 ordered_as_mnemonic = vc
       2 hna_mnemonic = vc
       2 voided_ind = i2
       2 core_actions[*]
         3 order_id = f8
         3 action_seq = i4
         3 action = c40
         3 action_dt_tm = dq8
         3 clinical_display_line = vc
         3 detail_value = f8
         3 detail_assigned = i2
       2 admins[*]
         3 order_id = f8
         3 parent_event_id = f8
         3 event_id = f8
         3 verified_dt_tm = dq8
         3 verified_prsnl_id = f8
         3 valid_from_dt_tm = dq8
         3 event_title_text = vc
         3 event_end_dt_tm = dq8
         3 result_status_meaning = c12
         3 result_status_display = c40
         3 from_ccr = i2
         3 not_given_reason = vc
         3 admin_start_dt_tm = dq8
         3 dosage_value = f8
         3 dosage_unit = c40
         3 site = c40
         3 admin_by_id = f8
         3 route = c40
         3 vital_signs[*]
           4 event_id = f8
           4 vital_sign = c40
           4 value = vc
           4 unit = c40
           4 normalcy_cd = f8
   )
   FREE RECORD prn_orders
   RECORD prn_orders(
     1 qual[*]
       2 order_id = f8
       2 true_parent = i2
       2 order_detail = vc
       2 order_name = vc
       2 comment = vc
       2 child_ord[*]
         3 order_id = f8
         3 start_dt = dq8
         3 order_mnemonic = vc
   )
   FREE RECORD prn_orders_disp
   RECORD prn_orders_disp(
     1 prn_orders[*]
       2 order_id = f8
       2 comment = vc
       2 orig_order_dt_tm = dq8
       2 mnemonic = vc
       2 ordered_as_mnemonic = vc
       2 hna_mnemonic = vc
       2 voided_ind = i2
       2 core_actions[*]
         3 order_id = f8
         3 action_seq = i4
         3 action = c40
         3 action_dt_tm = dq8
         3 clinical_display_line = vc
         3 detail_value = f8
         3 detail_assigned = i2
       2 admins[*]
         3 order_id = f8
         3 parent_event_id = f8
         3 event_id = f8
         3 verified_dt_tm = dq8
         3 verified_prsnl_id = f8
         3 valid_from_dt_tm = dq8
         3 event_title_text = vc
         3 event_end_dt_tm = dq8
         3 result_status_meaning = c12
         3 result_status_display = c40
         3 from_ccr = i2
         3 not_given_reason = vc
         3 admin_start_dt_tm = dq8
         3 dosage_value = f8
         3 dosage_unit = c40
         3 site = c40
         3 admin_by_id = f8
         3 route = c40
         3 vital_signs[*]
           4 event_id = f8
           4 vital_sign = c40
           4 value = vc
           4 unit = c40
           4 normalcy_cd = f8
   )
   FREE RECORD continuous_orders
   RECORD continuous_orders(
     1 qual[*]
       2 order_id = f8
       2 true_parent = i2
       2 order_detail = vc
       2 order_name = vc
       2 comment = vc
       2 child_ord[*]
         3 order_id = f8
         3 start_dt = dq8
         3 order_mnemonic = vc
   )
   FREE RECORD continuous_orders_disp
   RECORD continuous_orders_disp(
     1 continuous_orders[*]
       2 order_id = f8
       2 comment = vc
       2 orig_order_dt_tm = dq8
       2 mnemonic = vc
       2 ordered_as_mnemonic = vc
       2 hna_mnemonic = vc
       2 voided_ind = i2
       2 core_actions[*]
         3 action_seq = i4
         3 action_dt_tm = dq8
         3 action = c40
         3 clinical_display_line = vc
       2 admins[*]
         3 parent_event_id = f8
         3 event_id = f8
         3 verified_dt_tm = dq8
         3 verified_prsnl_id = f8
         3 valid_from_dt_tm = dq8
         3 event_title_text = vc
         3 event_end_dt_tm = dq8
         3 result_status_meaning = c12
         3 result_status_display = c40
         3 from_ccr = i2
         3 not_given_reason = vc
         3 iv_event_meaning = c12
         3 iv_event_display = c40
         3 admin_start_dt_tm = dq8
         3 init_dosage = f8
         3 dosage_unit = c40
         3 initial_volume = f8
         3 infusion_rate = f8
         3 infusion_unit = c40
         3 site = c40
         3 admin_by_id = f8
         3 route = c40
         3 comments[*]
           4 comment_type = c40
           4 text = vc
           4 commenter_id = f8
           4 note_dt_tm = dq8
           4 format = c12
   )
   CALL echo("SCHEDULED_ORDERS")
   SELECT INTO "nl:"
    FROM orders o
    WHERE o.person_id=personid
     AND o.encntr_id=encntrid
     AND o.catalog_type_cd=pharmacy
     AND ((o.order_status_cd+ 0)=os_ord_cd)
     AND o.discontinue_ind=0
     AND o.rx_mask > 0
     AND trim(o.dept_misc_line) > ""
     AND o.prn_ind=0
     AND o.med_order_type_cd != iv_type_cd
     AND o.template_order_id=0
    ORDER BY o.order_id
    HEAD REPORT
     sordercnt = 0
    DETAIL
     sordercnt += 1
     IF (mod(sordercnt,10)=1)
      stat = alterlist(scheduled_orders->qual,(sordercnt+ 9))
     ENDIF
     scheduled_orders->qual[sordercnt].order_id = o.order_id, scheduled_orders->qual[sordercnt].
     true_parent = 1, scheduled_orders->qual[sordercnt].order_name = o.ordered_as_mnemonic,
     scheduled_orders->qual[sordercnt].order_detail = trim(o.clinical_display_line)
    FOOT REPORT
     stat = alterlist(scheduled_orders->qual,sordercnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM orders o
    WHERE o.person_id=personid
     AND o.encntr_id=encntrid
     AND o.catalog_type_cd=pharmacy
     AND ((o.order_status_cd+ 0)=os_ord_cd)
     AND o.discontinue_ind=0
     AND o.rx_mask > 0
     AND trim(o.dept_misc_line) > ""
     AND o.prn_ind=1
     AND o.med_order_type_cd != iv_type_cd
     AND o.template_order_id=0
    ORDER BY o.order_id
    HEAD REPORT
     pordercnt = 0
    DETAIL
     pordercnt += 1
     IF (mod(pordercnt,10)=1)
      stat = alterlist(prn_orders->qual,(pordercnt+ 9))
     ENDIF
     prn_orders->qual[pordercnt].order_id = o.order_id, prn_orders->qual[pordercnt].order_name = o
     .ordered_as_mnemonic, prn_orders->qual[pordercnt].order_detail = o.clinical_display_line
    FOOT REPORT
     stat = alterlist(prn_orders->qual,pordercnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM orders o
    WHERE o.person_id=personid
     AND o.encntr_id=encntrid
     AND o.catalog_type_cd=pharmacy
     AND ((o.order_status_cd+ 0)=os_ord_cd)
     AND o.discontinue_ind=0
     AND o.rx_mask > 0
     AND trim(o.dept_misc_line) > ""
     AND o.prn_ind=0
     AND o.med_order_type_cd=iv_type_cd
     AND o.template_order_id=0
    ORDER BY o.order_id
    HEAD REPORT
     cordercnt = 0
    DETAIL
     cordercnt += 1
     IF (mod(cordercnt,10)=1)
      stat = alterlist(continuous_orders->qual,(cordercnt+ 9))
     ENDIF
     continuous_orders->qual[cordercnt].order_id = o.order_id, continuous_orders->qual[cordercnt].
     order_name = o.ordered_as_mnemonic, continuous_orders->qual[cordercnt].order_detail = o
     .clinical_display_line
    FOOT REPORT
     stat = alterlist(continuous_orders->qual,cordercnt)
    WITH nocounter
   ;end select
   SET sch_med_cnt = size(scheduled_orders->qual,0)
   IF (sch_med_cnt > 0)
    SELECT DISTINCT INTO "nl:"
     check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
      "csr"), template_order_id = scheduled_orders->qual[d1.seq].order_id
     FROM orders o,
      order_action oa,
      clinical_event ce,
      ce_med_result cmr,
      ce_coded_result ccr,
      ce_string_result csr,
      (dummyt d1  WITH seq = value(size(scheduled_orders->qual,5))),
      dummyt d2,
      dummyt d3,
      dummyt d4
     PLAN (d1)
      JOIN (o
      WHERE (o.template_order_id=scheduled_orders->qual[d1.seq].order_id)
       AND (scheduled_orders->qual[d1.seq].true_parent=1))
      JOIN (oa
      WHERE oa.order_id=o.template_order_id
       AND oa.core_ind=1)
      JOIN (ce
      WHERE ce.order_id=o.order_id
       AND ce.person_id=personid
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ce.event_class_cd=med_type_cd
       AND ce.publish_flag=1)
      JOIN (d2)
      JOIN (((cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d3)
      JOIN (((ccr
      WHERE ccr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d4)
      JOIN (csr
      WHERE csr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      )) ))
     ORDER BY template_order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC
     HEAD REPORT
      actioncnt = 0, admincnt = 0
     HEAD template_order_id
      schedordercnt += 1
      IF (mod(schedordercnt,10)=1)
       stat = alterlist(scheduled_orders_disp->scheduled_orders,(schedordercnt+ 15))
      ENDIF
      scheduled_orders_disp->scheduled_orders[schedordercnt].template_order_id = template_order_id,
      scheduled_orders_disp->scheduled_orders[schedordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
      scheduled_orders_disp->scheduled_orders[schedordercnt].mnemonic = o.order_mnemonic,
      scheduled_orders_disp->scheduled_orders[schedordercnt].ordered_as_mnemonic = o
      .ordered_as_mnemonic, scheduled_orders_disp->scheduled_orders[schedordercnt].hna_mnemonic = o
      .hna_order_mnemonic
     HEAD oa.action_sequence
      actioncnt += 1
      IF (mod(actioncnt,5)=1)
       stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions,(
        actioncnt+ 4))
      ENDIF
      scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].order_id = oa
      .order_id, scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].
      action_seq = oa.action_sequence, scheduled_orders_disp->scheduled_orders[schedordercnt].
      core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
      scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions[actioncnt].action =
      uar_get_code_display(oa.action_type_cd), scheduled_orders_disp->scheduled_orders[schedordercnt]
      .core_actions[actioncnt].clinical_display_line = oa.clinical_display_line
     DETAIL
      IF (actioncnt=1)
       admincnt += 1
       IF (mod(admincnt,10)=1)
        stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].admins,(admincnt+ 9))
       ENDIF
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].order_id = o.order_id,
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].parent_event_id = ce
       .parent_event_id, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
       event_id = ce.event_id,
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].verified_dt_tm = ce
       .verified_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
       verified_prsnl_id = ce.verified_prsnl_id, scheduled_orders_disp->scheduled_orders[
       schedordercnt].admins[admincnt].valid_from_dt_tm = ce.valid_from_dt_tm,
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].event_title_text = ce
       .event_title_text, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].
       event_end_dt_tm = ce.event_end_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].
       admins[admincnt].result_status_meaning = uar_get_code_meaning(ce.result_status_cd),
       scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].result_status_display
        = uar_get_code_display(ce.result_status_cd), scheduled_orders_disp->scheduled_orders[
       schedordercnt].admins[admincnt].admin_by_id = ce.performed_prsnl_id
       IF (check="cmr")
        scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].admin_start_dt_tm =
        cmr.admin_start_dt_tm, scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt
        ].dosage_unit = uar_get_code_display(cmr.dosage_unit_cd), scheduled_orders_disp->
        scheduled_orders[schedordercnt].admins[admincnt].dosage_value = cmr.admin_dosage,
        scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].site =
        uar_get_code_display(cmr.admin_site_cd), scheduled_orders_disp->scheduled_orders[
        schedordercnt].admins[admincnt].route = uar_get_code_display(cmr.admin_route_cd)
       ELSEIF (check="ccr")
        scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].not_given_reason =
        uar_get_code_display(ccr.result_cd), scheduled_orders_disp->scheduled_orders[schedordercnt].
        admins[admincnt].from_ccr = 1
       ELSE
        IF ((scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].from_ccr != 1))
         scheduled_orders_disp->scheduled_orders[schedordercnt].admins[admincnt].not_given_reason =
         csr.string_result_text
        ENDIF
       ENDIF
      ENDIF
     FOOT  template_order_id
      stat = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].admins,admincnt), stat
       = alterlist(scheduled_orders_disp->scheduled_orders[schedordercnt].core_actions,actioncnt),
      max_num_sched_admins = maxval(max_num_sched_admins,admincnt),
      max_num_sched_actions = maxval(max_num_sched_actions,actioncnt), admincnt = 0, actioncnt = 0
     FOOT REPORT
      stat = alterlist(scheduled_orders_disp->scheduled_orders,schedordercnt), do_nothing = 0
     WITH nocounter
    ;end select
   ENDIF
   SET prn_med_cnt = size(prn_orders->qual,5)
   IF (prn_med_cnt > 0)
    SELECT DISTINCT INTO "nl:"
     check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
      "csr")
     FROM orders o,
      order_action oa,
      clinical_event ce,
      ce_med_result cmr,
      ce_coded_result ccr,
      ce_string_result csr,
      (dummyt d1  WITH seq = value(size(prn_orders->qual,5))),
      dummyt d2,
      dummyt d3,
      dummyt d4
     PLAN (d1)
      JOIN (o
      WHERE (o.order_id=prn_orders->qual[d1.seq].order_id))
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.core_ind=1)
      JOIN (ce
      WHERE ce.order_id=oa.order_id
       AND ce.person_id=personid
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ce.event_class_cd=med_type_cd
       AND ce.publish_flag=1)
      JOIN (d2)
      JOIN (((cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d3)
      JOIN (((ccr
      WHERE ccr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d4)
      JOIN (csr
      WHERE csr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      )) ))
     ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      ce.event_id
     HEAD REPORT
      ordercnt = 0, actioncnt = 0, admincnt = 0
     HEAD o.order_id
      ordercnt += 1
      IF (mod(ordercnt,10)=1)
       stat = alterlist(prn_orders_disp->prn_orders,(ordercnt+ 9))
      ENDIF
      prn_orders_disp->prn_orders[ordercnt].order_id = o.order_id, prn_orders_disp->prn_orders[
      ordercnt].orig_order_dt_tm = o.orig_order_dt_tm, prn_orders_disp->prn_orders[ordercnt].mnemonic
       = o.order_mnemonic,
      prn_orders_disp->prn_orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
      prn_orders_disp->prn_orders[ordercnt].hna_mnemonic = o.hna_order_mnemonic
      IF (o.order_status_cd=voided_cd)
       prn_orders_disp->prn_orders[ordercnt].voided_ind = 1
      ENDIF
     HEAD oa.action_sequence
      actioncnt += 1
      IF (mod(actioncnt,5)=1)
       stat = alterlist(prn_orders_disp->prn_orders[ordercnt].core_actions,(actioncnt+ 4))
      ENDIF
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].order_id = oa.order_id,
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action_seq = oa.action_sequence,
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action_dt_tm = oa.action_dt_tm,
      prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].action = uar_get_code_display(oa
       .action_type_cd), prn_orders_disp->prn_orders[ordercnt].core_actions[actioncnt].
      clinical_display_line = oa.clinical_display_line
     DETAIL
      IF (actioncnt=1)
       admincnt += 1
       IF (mod(admincnt,10)=1)
        stat = alterlist(prn_orders_disp->prn_orders[ordercnt].admins,(admincnt+ 9))
       ENDIF
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].order_id = o.order_id, prn_orders_disp
       ->prn_orders[ordercnt].admins[admincnt].parent_event_id = ce.parent_event_id, prn_orders_disp
       ->prn_orders[ordercnt].admins[admincnt].event_id = ce.event_id,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].verified_dt_tm = ce.verified_dt_tm,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].verified_prsnl_id = ce
       .verified_prsnl_id, prn_orders_disp->prn_orders[ordercnt].admins[admincnt].valid_from_dt_tm =
       ce.valid_from_dt_tm,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].event_title_text = ce.event_title_text,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].event_end_dt_tm = ce.event_end_dt_tm,
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].result_status_meaning =
       uar_get_code_meaning(ce.result_status_cd),
       prn_orders_disp->prn_orders[ordercnt].admins[admincnt].result_status_display =
       uar_get_code_display(ce.result_status_cd), prn_orders_disp->prn_orders[ordercnt].admins[
       admincnt].admin_by_id = ce.performed_prsnl_id
       IF (check="cmr")
        prn_orders_disp->prn_orders[ordercnt].admins[admincnt].admin_start_dt_tm = cmr
        .admin_start_dt_tm, prn_orders_disp->prn_orders[ordercnt].admins[admincnt].dosage_unit =
        uar_get_code_display(cmr.dosage_unit_cd), prn_orders_disp->prn_orders[ordercnt].admins[
        admincnt].dosage_value = cmr.admin_dosage,
        prn_orders_disp->prn_orders[ordercnt].admins[admincnt].site = uar_get_code_display(cmr
         .admin_site_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt].route =
        uar_get_code_display(cmr.admin_route_cd)
       ELSEIF (check="ccr")
        prn_orders_disp->prn_orders[ordercnt].admins[admincnt].not_given_reason =
        uar_get_code_display(ccr.result_cd), prn_orders_disp->prn_orders[ordercnt].admins[admincnt].
        from_ccr = 1
       ELSE
        IF ((prn_orders_disp->prn_orders[ordercnt].admins[admincnt].from_ccr != 1))
         prn_orders_disp->prn_orders[ordercnt].admins[admincnt].not_given_reason = csr
         .string_result_text
        ENDIF
       ENDIF
      ENDIF
     FOOT  oa.action_sequence
      do_nothing = 0
     FOOT  o.order_id
      stat = alterlist(prn_orders_disp->prn_orders[ordercnt].core_actions,actioncnt), stat =
      alterlist(prn_orders_disp->prn_orders[ordercnt].admins,admincnt), max_num_prn_actions = maxval(
       max_num_prn_actions,actioncnt),
      max_num_prn_admins = maxval(max_num_prn_admins,admincnt), actioncnt = 0, admincnt = 0
     FOOT REPORT
      stat = alterlist(prn_orders_disp->prn_orders,ordercnt)
     WITH nocounter
    ;end select
   ENDIF
   SET cont_med_cnt = size(continuous_orders->qual,5)
   IF (cont_med_cnt > 0)
    SELECT DISTINCT INTO "nl:"
     check = decode(cmr.seq,"cmr",ccr.seq,"ccr",csr.seq,
      "csr")
     FROM orders o,
      order_action oa,
      clinical_event ce,
      ce_med_result cmr,
      ce_coded_result ccr,
      ce_string_result csr,
      (dummyt d1  WITH seq = value(size(continuous_orders->qual,5))),
      dummyt d2,
      dummyt d3,
      dummyt d4
     PLAN (d1)
      JOIN (o
      WHERE (o.order_id=continuous_orders->qual[d1.seq].order_id))
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.core_ind=1)
      JOIN (ce
      WHERE ce.order_id=oa.order_id
       AND ce.person_id=personid
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ce.event_class_cd=med_type_cd
       AND ce.publish_flag=1)
      JOIN (d2)
      JOIN (((cmr
      WHERE cmr.event_id=ce.event_id
       AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND cmr.iv_event_cd IN (begin_bag_cd, site_chg_cd, rate_chg_cd))
      ) ORJOIN ((d3)
      JOIN (((ccr
      WHERE ccr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND ccr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      ) ORJOIN ((d4)
      JOIN (csr
      WHERE csr.event_id=ce.event_id
       AND ce.result_status_cd=not_done_cd
       AND csr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      )) ))
     ORDER BY o.order_id DESC, oa.action_sequence DESC, ce.event_end_dt_tm DESC,
      ce.event_id
     HEAD REPORT
      ordercnt = 0, actioncnt = 0, admincnt = 0
     HEAD o.order_id
      ordercnt += 1
      IF (mod(ordercnt,10)=1)
       stat = alterlist(continuous_orders_disp->continuous_orders,(ordercnt+ 9))
      ENDIF
      continuous_orders_disp->continuous_orders[ordercnt].order_id = o.order_id,
      continuous_orders_disp->continuous_orders[ordercnt].orig_order_dt_tm = o.orig_order_dt_tm,
      continuous_orders_disp->continuous_orders[ordercnt].mnemonic = o.order_mnemonic,
      continuous_orders_disp->continuous_orders[ordercnt].ordered_as_mnemonic = o.ordered_as_mnemonic,
      continuous_orders_disp->continuous_orders[ordercnt].hna_mnemonic = o.hna_order_mnemonic
      IF (o.order_status_cd=voided_cd)
       continuous_orders_disp->continuous_orders[ordercnt].voided_ind = 1
      ENDIF
     HEAD oa.action_sequence
      actioncnt += 1
      IF (mod(actioncnt,5)=1)
       stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].core_actions,(actioncnt+
        4))
      ENDIF
      continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].action_seq = oa
      .action_sequence, continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].
      action_dt_tm = oa.action_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].
      core_actions[actioncnt].action = uar_get_code_display(oa.action_type_cd),
      continuous_orders_disp->continuous_orders[ordercnt].core_actions[actioncnt].
      clinical_display_line = oa.clinical_display_line
     DETAIL
      IF (actioncnt=1)
       admincnt += 1
       IF (mod(admincnt,10)=1)
        stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].admins,(admincnt+ 9))
       ENDIF
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].parent_event_id = ce
       .parent_event_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       event_id = ce.event_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       verified_dt_tm = ce.verified_dt_tm,
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].verified_prsnl_id = ce
       .verified_prsnl_id, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       valid_from_dt_tm = ce.valid_from_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].
       admins[admincnt].event_title_text = ce.event_title_text,
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].event_end_dt_tm = ce
       .event_end_dt_tm, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
       result_status_meaning = uar_get_code_meaning(ce.result_status_cd), continuous_orders_disp->
       continuous_orders[ordercnt].admins[admincnt].result_status_display = uar_get_code_display(ce
        .result_status_cd),
       continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].admin_by_id = ce
       .performed_prsnl_id
       IF (check="cmr")
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].iv_event_meaning =
        uar_get_code_meaning(cmr.iv_event_cd), continuous_orders_disp->continuous_orders[ordercnt].
        admins[admincnt].iv_event_display = uar_get_code_display(cmr.iv_event_cd),
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].admin_start_dt_tm = cmr
        .admin_start_dt_tm,
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].init_dosage = cmr
        .initial_dosage, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
        dosage_unit = uar_get_code_display(cmr.dosage_unit_cd), continuous_orders_disp->
        continuous_orders[ordercnt].admins[admincnt].initial_volume = cmr.initial_volume,
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].infusion_rate = cmr
        .infusion_rate, continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].
        infusion_unit = uar_get_code_display(cmr.infusion_unit_cd), continuous_orders_disp->
        continuous_orders[ordercnt].admins[admincnt].site = uar_get_code_display(cmr.admin_site_cd),
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].route =
        uar_get_code_display(cmr.admin_route_cd)
       ELSEIF (check="ccr")
        continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].not_given_reason =
        uar_get_code_display(ccr.result_cd), continuous_orders_disp->continuous_orders[ordercnt].
        admins[admincnt].from_ccr = 1
       ELSE
        IF ((continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].from_ccr != 1))
         continuous_orders_disp->continuous_orders[ordercnt].admins[admincnt].not_given_reason = csr
         .string_result_text
        ENDIF
       ENDIF
      ENDIF
     FOOT  oa.action_sequence
      do_nothing = 0
     FOOT  o.order_id
      stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].core_actions,actioncnt),
      stat = alterlist(continuous_orders_disp->continuous_orders[ordercnt].admins,admincnt),
      max_num_cont_admins = maxval(max_num_cont_admins,admincnt),
      max_num_cont_actions = maxval(max_num_cont_actions,actioncnt), actioncnt = 0, admincnt = 0
     FOOT REPORT
      stat = alterlist(continuous_orders_disp->continuous_orders,ordercnt)
     WITH nocounter
    ;end select
   ENDIF
   FOR (xx = 1 TO size(scheduled_orders->qual,5))
    SELECT INTO "nl:"
     FROM orders o,
      order_comment oc,
      long_text lt
     PLAN (o
      WHERE (o.template_order_id=scheduled_orders->qual[xx].order_id)
       AND o.template_order_id > 0
       AND o.current_start_dt_tm > cnvtdatetime(sysdate))
      JOIN (oc
      WHERE (oc.order_id= Outerjoin(o.order_id)) )
      JOIN (lt
      WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
       AND (lt.active_ind= Outerjoin(1))
       AND (lt.parent_entity_name= Outerjoin("ORDER_COMMENT")) )
     ORDER BY o.current_start_dt_tm
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1, stat = alterlist(scheduled_orders->qual[xx].child_ord,cnt), scheduled_orders->qual[xx
      ].child_ord[cnt].order_id = o.order_id,
      scheduled_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, scheduled_orders->
      qual[xx].child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
      IF (o.order_comment_ind=1)
       scheduled_orders->qual[xx].comment = lt.long_text
      ENDIF
     WITH nocounter
    ;end select
    FOR (s = 1 TO size(scheduled_orders_disp->scheduled_orders,5))
      IF ((scheduled_orders_disp->scheduled_orders[s].template_order_id=scheduled_orders->qual[xx].
      order_id))
       SET scheduled_orders_disp->scheduled_orders[s].comment = scheduled_orders->qual[xx].comment
      ENDIF
    ENDFOR
   ENDFOR
   FOR (xx = 1 TO size(prn_orders->qual,5))
    SELECT INTO "nl:"
     FROM orders o,
      order_comment oc,
      long_text lt
     PLAN (o
      WHERE (o.template_order_id=prn_orders->qual[xx].order_id)
       AND o.template_order_id > 0
       AND o.current_start_dt_tm > cnvtdatetime(sysdate))
      JOIN (oc
      WHERE (oc.order_id= Outerjoin(o.order_id)) )
      JOIN (lt
      WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
       AND (lt.active_ind= Outerjoin(1))
       AND (lt.parent_entity_name= Outerjoin("ORDER_COMMENT")) )
     ORDER BY o.current_start_dt_tm
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1, stat = alterlist(prn_orders->qual[xx].child_ord,cnt), prn_orders->qual[xx].child_ord[
      cnt].order_id = o.order_id,
      prn_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, prn_orders->qual[xx].
      child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
      IF (o.order_comment_ind=1)
       prn_orders->qual[xx].comment = lt.long_text
      ENDIF
     WITH nocounter
    ;end select
    FOR (p = 1 TO size(prn_orders_disp->prn_orders,5))
      IF ((prn_orders_disp->prn_orders[p].order_id=prn_orders->qual[xx].order_id))
       SET prn_orders_disp->prn_orders[p].comment = prn_orders->qual[xx].comment
      ENDIF
    ENDFOR
   ENDFOR
   FOR (xx = 1 TO size(continuous_orders->qual,5))
    SELECT INTO "nl:"
     FROM orders o,
      order_comment oc,
      long_text lt
     PLAN (o
      WHERE (o.template_order_id=continuous_orders->qual[xx].order_id)
       AND o.template_order_id > 0
       AND o.current_start_dt_tm > cnvtdatetime(sysdate))
      JOIN (oc
      WHERE (oc.order_id= Outerjoin(o.order_id)) )
      JOIN (lt
      WHERE (lt.long_text_id= Outerjoin(oc.long_text_id))
       AND (lt.active_ind= Outerjoin(1))
       AND (lt.parent_entity_name= Outerjoin("ORDER_COMMENT")) )
     ORDER BY o.current_start_dt_tm
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1, stat = alterlist(continuous_orders->qual[xx].child_ord,cnt), continuous_orders->qual[
      xx].child_ord[cnt].order_id = o.order_id,
      continuous_orders->qual[xx].child_ord[cnt].start_dt = o.current_start_dt_tm, continuous_orders
      ->qual[xx].child_ord[cnt].order_mnemonic = trim(o.order_mnemonic)
      IF (o.order_comment_ind=1)
       continuous_orders->qual[xx].comment = lt.long_text
      ENDIF
     WITH nocounter
    ;end select
    FOR (c = 1 TO size(continuous_orders_disp->continuous_orders,5))
      IF ((continuous_orders_disp->continuous_orders[c].order_id=continuous_orders->qual[xx].order_id
      ))
       SET continuous_orders_disp->continuous_orders[c].comment = continuous_orders->qual[xx].comment
      ENDIF
    ENDFOR
   ENDFOR
   SELECT INTO  $1
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     l_nbr = 0, event_len = 0, date_len = 0,
     pat_cnt = 0, pat_cnt = size(pat->qual,5), line = fillstring(120,"="),
     line2 = fillstring(120,"*"), xcol = 0, ycol = 0,
     temp1 = fillstring(500,""), temp2 = fillstring(500,""), sord_cnt = 0,
     pord_cnt = 0, cord_cnt = 0, breakflag = 1,
     xcolvar = 0, wrapcol = 0,
     MACRO (rowplusone)
      ycol += 10, row + 1
      IF (ycol > 710)
       BREAK
      ENDIF
     ENDMACRO
     ,
     MACRO (rowplusone2)
      ycol += 10, row + 1
     ENDMACRO
     ,
     MACRO (line_wrap)
      limit = 0, maxlen = wrapcol, cr = char(10)
      WHILE (tempstring > " "
       AND limit < 1000)
        ii = 0, limit += 1, pos = 0
        WHILE (pos=0)
         ii += 1,
         IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", cr))
          pos = (maxlen - ii)
         ELSEIF (ii=maxlen)
          pos = maxlen
         ENDIF
        ENDWHILE
        printstring = substring(1,pos,tempstring),
        CALL print(calcpos(xcol,ycol)), printstring
        IF (limit=1)
         maxlen -= 5
        ENDIF
        IF (breakflag=1)
         rowplusone
        ELSE
         rowplusone2
        ENDIF
        tempstring = substring((pos+ 1),9999,tempstring)
      ENDWHILE
     ENDMACRO
    HEAD PAGE
     "{cpi/10}{f/12}", row + 1, "{pos/240/30}{b}Baystate Health System",
     row + 1, "{pos/220/45}{b}Downtime Clinical Summary Report", row + 1,
     "{cpi/14}", row + 1, xcol = 30,
     ycol = 60,
     CALL print(calcpos(xcol,ycol)), "Run Time:",
     curtime, row + 1, xcol = 5,
     ycol += 10,
     CALL print(calcpos(xcol,ycol)), line,
     row + 1, xcol = 30, ycol += 10,
     CALL print(calcpos(xcol,ycol)), "Location: ", pat->qual[x].unit_room_bed,
     row + 1, xcol = 150,
     CALL print(calcpos(xcol,ycol)),
     "Name: ", pat->qual[x].name, row + 1,
     xcol = 350,
     CALL print(calcpos(xcol,ycol)), "Acc Nbr: ",
     pat->qual[x].fin, row + 1, xcol = 500,
     temp1 = concat("Page :",cnvtstring(curpage)),
     CALL print(calcpos(xcol,ycol)), temp1,
     row + 1, xcol = 30, ycol += 10,
     CALL print(calcpos(xcol,ycol)), "Att. MD: ", pat->qual[x].att_doc,
     row + 1, xcol = 200,
     CALL print(calcpos(xcol,ycol)),
     "PCP MD: ", pat->qual[x].pcp_doc, row + 1,
     xcol = 350,
     CALL print(calcpos(xcol,ycol)), "MR Nbr: ",
     pat->qual[x].mrn, row + 1, ycol += 10,
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), "Teaching Cov.: ",
     pat->qual[x].teaching_doc, row + 1, xcol = 200,
     CALL print(calcpos(xcol,ycol)), "Language: ", pat->qual[x].language,
     row + 1, xcol = 350,
     CALL print(calcpos(xcol,ycol)),
     "Religion: ", pat->qual[x].religion, row + 1,
     xcol = 30, ycol += 10, visit = substring(1,100,pat->qual[x].visit_reason),
     CALL print(calcpos(xcol,ycol)), "Reason for Visit: ", visit,
     row + 1, ycol += 10, xcol = 30,
     diag = substring(1,100,pat->qual[x].diagnosis),
     CALL print(calcpos(xcol,ycol)), "Diagnosis: ",
     diag, row + 1, ycol += 10,
     breakflag = 0, xcol = 30, allergy = substring(1,100,concat("Allergy: ",pat->qual[x].allergy)),
     CALL print(calcpos(xcol,ycol)), allergy, row + 1,
     ycol += 10, xcol = 30,
     CALL print(calcpos(xcol,ycol)),
     "Problems: ", row + 1, xcol = 50
     FOR (prob = 1 TO size(pat->qual[x].problems,5))
       problem = build(pat->qual[x].problems[prob].problem_line,"."),
       CALL print(calcpos(xcol,ycol)), problem,
       row + 1, ycol += 10
     ENDFOR
     xcol = 5, ycol += 10,
     CALL print(calcpos(xcol,ycol)),
     line, row + 1, xcol = 30,
     ycol = 160
    DETAIL
     breakflag = 1
     FOR (y = 1 TO 2)
       l_nbr = y
       IF (ycol > 740)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       temp1 = build(cnvtstring(y),"-",pat->qual[x].sec[y].sec_disp,":"),
       CALL print(calcpos(xcol,ycol)), "{b}",
       temp1, row + 1, ycol += 8
       FOR (z = 1 TO size(pat->qual[x].sec[y].grpr,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         grpr_date = format(pat->qual[x].sec[y].grpr[z].grpr_date,"mm/dd/yy hh:mm;;q"), xcol = 40,
         CALL print(calcpos(xcol,ycol)),
         grpr_date, row + 1, date_len = textlen(grpr_date)
         FOR (zz = 1 TO size(pat->qual[x].sec[y].grpr[z].event,5))
           IF (ycol > 740)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           temp1 = fillstring(500,""), xcol = 115, temp1 = pat->qual[x].sec[y].grpr[z].event[zz].
           event_disp
           IF ((pat->qual[x].sec[y].grpr[z].event[zz].max_result_qty > 0))
            IF ((pat->qual[x].sec[y].grpr[z].event[zz].event_cnt > pat->qual[x].sec[y].grpr[z].event[
            zz].max_result_qty))
             pat->qual[x].sec[y].grpr[z].event[zz].event_cnt = pat->qual[x].sec[y].grpr[z].event[zz].
             max_result_qty
            ENDIF
            FOR (yy = 1 TO pat->qual[x].sec[y].grpr[z].event[zz].event_cnt)
              IF (ycol > 740)
               xcol = 100, ycol += 10,
               CALL print(calcpos(xcol,ycol)),
               "**  Continue on Next Page **", row + 1, BREAK
              ENDIF
              IF (yy > 1
               AND trim(temp1)=trim(pat->qual[x].sec[y].grpr[z].event[(zz - 1)].event_disp))
               ycol2 = ycol, date2 = format(pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
                end_dt_tm,"mm/dd/yy hh:mm;;q"), date = substring(1,8,date2),
               time = substring(10,5,date2),
               CALL print(calcpos(xcol,ycol)), date,
               row + 1, ycol += 8,
               CALL print(calcpos(xcol,ycol)),
               time, row + 1, ycol += 8,
               temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
               event_result,
               CALL print(calcpos(xcol,ycol)),
               temp2, row + 1, xcol += 50,
               ycol = ycol2
              ELSE
               temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
               event_result, temp1 = concat(build(temp1),": ",build(temp2)),
               CALL print(calcpos(xcol,ycol)), temp1, row + 1,
               temp1 = fillstring(500,"")
              ENDIF
              ycol += 8
            ENDFOR
           ENDIF
         ENDFOR
         xcol = 30
       ENDFOR
       xcol = 30, ycol += 5
     ENDFOR
     IF (ycol > 710)
      xcol = 100, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "**  Continue on Next Page **", row + 1, BREAK
     ENDIF
     xcol = 30, ycol += 5, breakflag = 1,
     xcolvar = 30, wrapcol = 122, l_nbr += 1
     IF (((size(pat->qual[x].ntnord,5) > 0) OR (size(pat->qual[x].mdtrnord,5) > 0)) )
      title = build(l_nbr,"-","{b}Nurse Communication Orders:"),
      CALL print(calcpos(xcol,ycol)), title,
      row + 1, ycol += 10
      FOR (n1 = 1 TO size(pat->qual[x].ntnord,5))
        tempstring = concat("{b}",pat->qual[x].ntnord[n1].order_mnemonic,"{endb} ",pat->qual[x].
         ntnord[n1].clinical_display), line_wrap
        IF ((pat->qual[x].ntnord[n1].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].ntnord[n1].comment),
         line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
      FOR (n2 = 1 TO size(pat->qual[x].mdtrnord,5))
        tempstring = concat("{b}",pat->qual[x].mdtrnord[n2].order_mnemonic,"{endb} ",pat->qual[x].
         mdtrnord[n2].clinical_display), line_wrap
        IF ((pat->qual[x].mdtrnord[n2].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].mdtrnord[n2].comment
          ), line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
     ENDIF
     IF (size(pat->qual[x].diet,5) > 0)
      l_nbr += 1, title = build(l_nbr,"-","{b}Diet Orders:"),
      CALL print(calcpos(xcol,ycol)),
      title, row + 1, ycol += 10
      FOR (d1 = 1 TO size(pat->qual[x].diet,5))
        tempstring = concat("{b}",pat->qual[x].diet[d1].order_mnemonic,"{endb} ",pat->qual[x].diet[d1
         ].clinical_display), line_wrap, xcol = 30
        IF ((pat->qual[x].diet[d1].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].diet[d1].comment),
         line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
     ENDIF
     IF (size(pat->qual[x].resp,5) > 0)
      l_nbr += 1, title = build(l_nbr,"-","{b}Respiratory Therapy Orders:"),
      CALL print(calcpos(xcol,ycol)),
      title, row + 1, ycol += 10
      FOR (r1 = 1 TO size(pat->qual[x].resp,5))
        tempstring = concat("{b}",pat->qual[x].resp[r1].order_mnemonic,"{endb} ",pat->qual[x].resp[r1
         ].clinical_display), line_wrap
        IF ((pat->qual[x].resp[r1].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].resp[r1].comment),
         line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
     ENDIF
     IF (size(pat->qual[x].monitor,5) > 0)
      l_nbr += 1, title = build(l_nbr,"-","{b}Assess/Monitor/Treat:"),
      CALL print(calcpos(xcol,ycol)),
      title, row + 1, ycol += 10
      FOR (m1 = 1 TO size(pat->qual[x].monitor,5))
        tempstring = concat("{b}",pat->qual[x].monitor[m1].order_mnemonic,"{endb} ",pat->qual[x].
         monitor[m1].clinical_display), line_wrap
        IF ((pat->qual[x].monitor[m1].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].monitor[m1].comment),
         line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
     ENDIF
     IF (ycol > 710)
      xcol = 100, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "**  Continue on Next Page **", row + 1, BREAK
     ENDIF
     IF (size(scheduled_orders_disp->scheduled_orders,5) > 0)
      xcol = 30, ycol += 5, l_nbr += 1,
      title = build(l_nbr,"-","{b}Scheduled Meds :"),
      CALL print(calcpos(xcol,ycol)), title,
      row + 1, ycol += 8
      FOR (z1 = 1 TO size(scheduled_orders_disp->scheduled_orders,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 30, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",scheduled_orders_disp
         ->scheduled_orders[z1].ordered_as_mnemonic),
        comment_string = build(scheduled_orders_disp->scheduled_orders[z1].comment)
        FOR (z2 = 1 TO size(scheduled_orders_disp->scheduled_orders[z1].core_actions,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         ,
         IF (trim(scheduled_orders_disp->scheduled_orders[z1].core_actions[z2].action)="Order")
          CALL print(calcpos(50,ycol)), line1, row + 1,
          ycol += 8, tempstring = concat("Order Detail :",scheduled_orders_disp->scheduled_orders[z1]
           .core_actions[z2].clinical_display_line), xcol = 50,
          wrapcol = 122, line_wrap
          IF (comment_string > "")
           tempstring = concat("Comment: ",comment_string), xcol = 50, line_wrap
          ENDIF
         ENDIF
        ENDFOR
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        CALL print(calcpos(50,ycol)), "{b}Last Dose", row + 1,
        xcol += 250,
        CALL print(calcpos(300,ycol)), "{b}Next Dose ",
        row + 1, ycol += 8, xcol = 50
        FOR (z3 = 1 TO 1)
          IF (ycol > 740)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
          med_date = scheduled_orders_disp->scheduled_orders[z1].admins[z3].event_end_dt_tm,
          med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
          dose = format(scheduled_orders_disp->scheduled_orders[z1].admins[z3].dosage_value,
           "#######.##;l"), event1 = build(med_date_disp,"/",dose,scheduled_orders_disp->
           scheduled_orders[z1].admins[z3].dosage_unit)
          FOR (zz1 = 1 TO size(scheduled_orders->qual,5))
            IF ((scheduled_orders_disp->scheduled_orders[z1].template_order_id=scheduled_orders->
            qual[zz1].order_id))
             event2 = fillstring(40,""), event2 = format(scheduled_orders->qual[zz1].child_ord[1].
              start_dt,"mm/dd/yy hh:mm;;q")
            ENDIF
          ENDFOR
          CALL print(calcpos(50,ycol)), event1, row + 1,
          CALL print(calcpos(300,ycol)), event2, row + 1,
          ycol += 8
        ENDFOR
        ycol += 8
      ENDFOR
     ENDIF
     IF (ycol > 740)
      xcol = 100, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "**  Continue on Next Page **", row + 1, BREAK
     ENDIF
     FOR (sch = 1 TO size(scheduled_orders->qual,5))
       IF (ycol > 740)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       xcol = 50
       IF (size(scheduled_orders->qual[sch].child_ord,5)=0)
        tempstring = concat("{b}",scheduled_orders->qual[sch].order_name,"{endb}",":",
         scheduled_orders->qual[sch].order_detail), wrapcol = 122, line_wrap,
        comment_string = build(scheduled_orders->qual[sch].comment)
        IF (comment_string > "")
         tempstring = concat("Comment: ",comment_string), line_wrap
        ENDIF
       ENDIF
     ENDFOR
     IF (ycol > 710)
      xcol = 100, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "**  Continue on Next Page **", row + 1, BREAK
     ENDIF
     IF (size(prn_orders_disp->prn_orders,5) > 0)
      xcol = 30, ycol += 5, l_nbr += 1,
      title = build(l_nbr,"-","{b}PRN Meds :"),
      CALL print(calcpos(xcol,ycol)), title,
      row + 1, ycol += 8
      FOR (z1 = 1 TO size(prn_orders_disp->prn_orders,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 30, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",prn_orders_disp->
         prn_orders[z1].ordered_as_mnemonic),
        comment_string = build(prn_orders_disp->prn_orders[z1].comment)
        FOR (z2 = 1 TO size(prn_orders_disp->prn_orders[z1].core_actions,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         ,
         IF (trim(prn_orders_disp->prn_orders[z1].core_actions[z2].action)="Order")
          xcol = 50,
          CALL print(calcpos(50,ycol)), line1,
          row + 1, ycol += 8, tempstring = concat("Order Detail :",prn_orders_disp->prn_orders[z1].
           core_actions[z2].clinical_display_line),
          wrapcol = 122, line_wrap
          IF (comment_string > "")
           tempstring = concat("Comment: ",comment_string), line_wrap
          ENDIF
         ENDIF
        ENDFOR
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        CALL print(calcpos(50,ycol)), "{b}Admin Date/Time", row + 1,
        xcol += 250,
        CALL print(calcpos(300,ycol)), "{b}Admin Detail",
        row + 1, ycol += 8, xcol = 50
        FOR (z3 = 1 TO 1)
          IF (ycol > 740)
           xcol = 100, ycol += 10,
           CALL print(calcpos(xcol,ycol)),
           "**  Continue on Next Page **", row + 1, BREAK
          ENDIF
          med_date = prn_orders_disp->prn_orders[z1].admins[z3].event_end_dt_tm, med_date_disp =
          format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
          dose = format(prn_orders_disp->prn_orders[z1].admins[z3].dosage_value,"#######.##;l"),
          event = build(dose,prn_orders_disp->prn_orders[z1].admins[z3].dosage_unit,",",
           prn_orders_disp->prn_orders[z1].admins[z3].route),
          CALL print(calcpos(50,ycol)),
          med_date_disp, row + 1,
          CALL print(calcpos(300,ycol)),
          event, row + 1, ycol += 8
        ENDFOR
        ycol += 8
      ENDFOR
     ENDIF
     FOR (prn = 1 TO size(prn_orders->qual,5))
       IF (ycol > 740)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       xcol = 50
       IF (size(prn_orders->qual[prn].child_ord,5)=0)
        tempstring = concat("{b}",prn_orders->qual[prn].order_name,"{endb}",":",prn_orders->qual[prn]
         .order_detail), wrapcol = 122, line_wrap,
        comment_string = build(prn_orders->qual[prn].comment)
        IF (comment_string > "")
         tempstring = concat("Comment: ",comment_string), line_wrap
        ENDIF
       ENDIF
     ENDFOR
     IF (ycol > 710)
      xcol = 100, ycol += 10,
      CALL print(calcpos(xcol,ycol)),
      "**  Continue on Next Page **", row + 1, BREAK
     ENDIF
     IF (size(continuous_orders_disp->continuous_orders,5) > 0)
      xcol = 30, ycol += 5, l_nbr += 1,
      title = build(l_nbr,"-","{b}IV Meds :"),
      CALL print(calcpos(xcol,ycol)), title,
      row + 1, ycol += 8
      FOR (z1 = 1 TO size(continuous_orders_disp->continuous_orders,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        xcol = 30, line1 = fillstring(100,""), line1 = concat("{b}Medication: ",
         continuous_orders_disp->continuous_orders[z1].ordered_as_mnemonic),
        comment_string = build(continuous_orders_disp->continuous_orders[z1].comment)
        FOR (z2 = 1 TO size(continuous_orders_disp->continuous_orders[z1].core_actions,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         ,
         IF (trim(continuous_orders_disp->continuous_orders[z1].core_actions[z2].action)="Order")
          CALL print(calcpos(50,ycol)), line1, row + 1,
          ycol += 8, xcol = 50, tempstring = concat("Order Detail :",continuous_orders_disp->
           continuous_orders[z1].core_actions[z2].clinical_display_line),
          wrapcol = 122, line_wrap
          IF (comment_string > "")
           tempstring = concat("Comment: ",comment_string), line_wrap
          ENDIF
         ENDIF
        ENDFOR
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        CALL print(calcpos(50,ycol)), "{b}Admin Date/Time", row + 1,
        xcol += 250,
        CALL print(calcpos(300,ycol)), "{b}Admin Detail",
        row + 1, ycol += 8, xcol = 50
        FOR (z3 = 1 TO 1)
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         ,
         IF (trim(continuous_orders_disp->continuous_orders[z1].admins[z3].event_title_text)=
         "IVPARENT")
          med_date = continuous_orders_disp->continuous_orders[z1].admins[z3].admin_start_dt_tm,
          med_date_disp = format(med_date,"mm/dd/yyyy hh:mm;;Q"), dose = fillstring(30,""),
          dose = format(continuous_orders_disp->continuous_orders[z1].admins[z3].initial_volume,
           "#######.##;l"), dose_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3]
           .dosage_unit), rate = format(continuous_orders_disp->continuous_orders[z1].admins[z3].
           infusion_rate,"#######.##;l"),
          rate_unit = trim(continuous_orders_disp->continuous_orders[z1].admins[z3].infusion_unit),
          event = build(dose,dose_unit,";",rate,",",
           rate_unit),
          CALL print(calcpos(50,ycol)),
          med_date_disp, row + 1,
          CALL print(calcpos(300,ycol)),
          event, row + 1, ycol += 8
         ENDIF
        ENDFOR
        ycol += 8
      ENDFOR
     ENDIF
     FOR (con = 1 TO size(continuous_orders->qual,5))
       IF (ycol > 740)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       xcol = 50
       IF (size(continuous_orders->qual[con].child_ord,5)=0)
        tempstring = concat("{b}",continuous_orders->qual[con].order_name,"{endb}",":",
         continuous_orders->qual[con].order_detail), wrapcol = 122, line_wrap,
        comment_string = build(continuous_orders->qual[con].comment)
        IF (comment_string > "")
         tempstring = concat("Comment: ",comment_string), line_wrap
        ENDIF
       ENDIF
     ENDFOR
     xcol = 30
     IF (size(pat->qual[x].lab_rad_ekg,5) > 0)
      IF (ycol > 740)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      l_nbr += 1, title = build(l_nbr,"-","{b}Lab / Rad / EKG Orders:"),
      CALL print(calcpos(xcol,ycol)),
      title, row + 1, ycol += 10
      FOR (d1 = 1 TO size(pat->qual[x].lab_rad_ekg,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        tempstring = concat("{b}",pat->qual[x].lab_rad_ekg[d1].order_mnemonic,"{endb} ",pat->qual[x].
         lab_rad_ekg[d1].clinical_display), line_wrap
        IF ((pat->qual[x].diet[d1].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].lab_rad_ekg[d1].
          comment), line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
     ENDIF
     xcol = 30
     IF (size(pat->qual[x].cprocedure,5) > 0)
      IF (ycol > 740)
       xcol = 100, ycol += 10,
       CALL print(calcpos(xcol,ycol)),
       "**  Continue on Next Page **", row + 1, BREAK
      ENDIF
      l_nbr += 1, title = build(l_nbr,"-","{b}Consults / Procedures Orders:"),
      CALL print(calcpos(xcol,ycol)),
      title, row + 1, ycol += 10
      FOR (d1 = 1 TO size(pat->qual[x].cprocedure,5))
        IF (ycol > 740)
         xcol = 100, ycol += 10,
         CALL print(calcpos(xcol,ycol)),
         "**  Continue on Next Page **", row + 1, BREAK
        ENDIF
        tempstring = concat("{b}",pat->qual[x].cprocedure[d1].order_mnemonic,"{endb} ",pat->qual[x].
         cprocedure[d1].clinical_display), line_wrap
        IF ((pat->qual[x].cprocedure[d1].com_ind=1))
         xcol = 40, tempstring = concat("{b}","Comment: ","{endb} ",pat->qual[x].cprocedure[d1].
          comment), line_wrap,
         xcol = 30
        ENDIF
      ENDFOR
     ENDIF
     FOR (y = 3 TO size(pat->qual[x].sec,5))
       IF (ycol > 740)
        xcol = 100, ycol += 10,
        CALL print(calcpos(xcol,ycol)),
        "**  Continue on Next Page **", row + 1, BREAK
       ENDIF
       l_nbr += 1, temp1 = build(l_nbr,"-",pat->qual[x].sec[y].sec_disp,":"),
       CALL print(calcpos(xcol,ycol)),
       "{b}", temp1, row + 1,
       ycol += 8
       FOR (z = 1 TO size(pat->qual[x].sec[y].grpr,5))
         IF (ycol > 740)
          xcol = 100, ycol += 10,
          CALL print(calcpos(xcol,ycol)),
          "**  Continue on Next Page **", row + 1, BREAK
         ENDIF
         grpr_date = format(pat->qual[x].sec[y].grpr[z].grpr_date,"mm/dd/yy hh:mm;;q"), xcol = 40,
         CALL print(calcpos(xcol,ycol)),
         grpr_date, row + 1, date_len = textlen(grpr_date)
         FOR (zz = 1 TO size(pat->qual[x].sec[y].grpr[z].event,5))
           IF (ycol > 740)
            xcol = 100, ycol += 10,
            CALL print(calcpos(xcol,ycol)),
            "**  Continue on Next Page **", row + 1, BREAK
           ENDIF
           temp1 = fillstring(500,""), xcol = 115, temp1 = pat->qual[x].sec[y].grpr[z].event[zz].
           event_disp
           IF ((pat->qual[x].sec[y].grpr[z].event[zz].max_result_qty > 0))
            IF ((pat->qual[x].sec[y].grpr[z].event[zz].event_cnt > pat->qual[x].sec[y].grpr[z].event[
            zz].max_result_qty))
             pat->qual[x].sec[y].grpr[z].event[zz].event_cnt = pat->qual[x].sec[y].grpr[z].event[zz].
             max_result_qty
            ENDIF
            FOR (yy = 1 TO pat->qual[x].sec[y].grpr[z].event[zz].event_cnt)
              IF (ycol > 740)
               xcol = 100, ycol += 10,
               CALL print(calcpos(xcol,ycol)),
               "**  Continue on Next Page **", row + 1, BREAK
              ENDIF
              IF (yy > 1
               AND trim(temp1)=trim(pat->qual[x].sec[y].grpr[z].event[(zz - 1)].event_disp))
               ycol2 = ycol, date2 = format(pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
                end_dt_tm,"mm/dd/yy hh:mm;;q"), date = substring(1,8,date2),
               time = substring(10,5,date2),
               CALL print(calcpos(xcol,ycol)), date,
               row + 1, ycol += 8,
               CALL print(calcpos(xcol,ycol)),
               time, row + 1, ycol += 8,
               temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
               event_result,
               CALL print(calcpos(xcol,ycol)),
               temp2, row + 1, xcol += 50,
               ycol = ycol2
              ELSE
               temp2 = fillstring(500,""), temp2 = pat->qual[x].sec[y].grpr[z].event[zz].result[yy].
               event_result, temp1 = concat(build(temp1),": ",build(temp2)),
               CALL print(calcpos(xcol,ycol)), temp1, row + 1,
               temp1 = fillstring(500,"")
              ENDIF
              ycol += 8
            ENDFOR
           ENDIF
         ENDFOR
         xcol = 30
       ENDFOR
       xcol = 30, ycol += 5
     ENDFOR
    FOOT REPORT
     xcol = 100, ycol += 10, temp1 = concat("***** ","End of Report For ",pat->qual[x].name," *****"),
     CALL print(calcpos(xcol,ycol)), temp1, row + 1
    WITH nocounter, maxrow = 800, maxcol = 800,
     dio = postscript, nullreport
   ;end select
   SET pid = 0
   SET fid = 0
 ENDFOR
 CALL echorecord(pat)
END GO
