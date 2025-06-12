CREATE PROGRAM bhs_rpt_sch_apt_add_ons:dba
 PROMPT
  "Output to MINE" = "MINE",
  "Start Date:" = "SYSDATE",
  "End Date:" = "SYSDATE",
  "Resource Group:" = value(636699.00),
  "Schedule State:" = value(4536.00,4537.00,4538.00,4543.00,4541.00,
   4544.00),
  "Recipients:  (Leave blank to display to screen)" = ""
  WITH outdev, s_start_date, s_end_date,
  f_res_grp, f_sch_state_cd, s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE SET m_rec
 RECORD m_rec(
   1 l_temp_size = i4
   1 l_qual_cnt = i4
   1 l_log_cnt = i4
   1 s_temp_string = vc
   1 log_qual[*]
     2 f_sch_appt_id = f8
   1 qual[*]
     2 f_beg_dt_tm = f8
     2 f_end_dt_tm = f8
     2 f_sch_appt_id = f8
     2 f_sch_event_id = f8
     2 f_schedule_id = f8
     2 f_sch_state_cd = f8
     2 l_sort_field = i4
     2 l_duration = i4
     2 l_detail_cnt = i4
     2 l_pat_cnt = i4
     2 s_resource_mnem = vc
     2 s_sch_state_disp = vc
     2 s_fin_nbr = vc
     2 s_comment = vc
     2 s_appt_synonym_free = vc
     2 detail_qual[*]
       3 f_oe_field_value = f8
       3 f_oe_field_dt_tm_value = f8
       3 l_oe_field_id = i4
       3 n_field_type_flag = i2
       3 s_oe_field_meaning = vc
       3 s_description = vc
       3 s_oe_field_display_value = vc
     2 pat_qual[*]
       3 f_beg_dt_tm = f8
       3 f_end_dt_tm = f8
       3 f_person_id = f8
       3 l_appt_cnt = i4
       3 s_name = vc
       3 s_mrn = vc
       3 s_home_phone = vc
       3 s_addr1 = vc
       3 s_city = vc
       3 s_state = vc
       3 s_zip = vc
       3 s_birth_formatted = vc
       3 s_sex = vc
       3 appt_qual[*]
         4 f_beg_dt_tm = f8
         4 f_end_dt_tm = f8
         4 l_duration = i4
         4 s_sch_state_disp = vc
         4 s_appt_synonym_free = vc
         4 s_primary_resource_mnem = vc
 ) WITH protect
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_pa_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_address_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE ms_curdate_tm = vc WITH protect, constant(format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
 DECLARE mf_begin_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_START_DATE))
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(cnvtdatetime( $S_END_DATE))
 DECLARE ml_beg_day_num = i4 WITH protect, noconstant(cnvtdate2(format(cnvtdatetime(mf_begin_dt_tm),
    "MMDDYYYY;;D"),"MMDDYYYY"))
 DECLARE ml_detail_offset = i4 WITH protect, noconstant(13)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_appt_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_max_pat_qual = i4 WITH protect, noconstant(0)
 DECLARE ml_last_sort_field = i4 WITH protect, noconstant(0)
 DECLARE ml_foot_sort_field = i4 WITH protect, noconstant(0)
 DECLARE mn_cont_ind = i2 WITH protect, noconstant(1)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_output = vc WITH protect, noconstant( $OUTDEV)
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_recipients = vc WITH protect, noconstant( $S_RECIPIENTS)
 DECLARE ms_date_range = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE mc120_print_line = c120 WITH protect, noconstant(fillstring(120," "))
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_SCH_APT_ADD_ONS*"
    AND cnvtupper(di.info_char)=cnvtupper( $S_RECIPIENTS)
   ORDER BY di.info_name
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    IF (ml_cnt=0)
     ms_recipients = trim(di.info_name,3), ml_cnt = 1
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (cnvtdatetime( $S_START_DATE) > cnvtdatetime( $S_END_DATE))
  SET ms_error = "Start date cannot be greater than end date."
  GO TO exit_script
 ENDIF
 SET ms_date_range = build2(format(mf_begin_dt_tm,"MM/DD/YY HH:MM;;D")," to ",format(mf_end_dt_tm,
   "MM/DD/YY HH:MM;;D"))
 IF (((mn_ops=1) OR (findstring("@", $S_RECIPIENTS) > 0)) )
  SET ms_output = concat(trim(cnvtlower(curprog),3),"_",format(sysdate,"MMDDYYYYHHMMSS;;D"),".pdf")
  SET ms_subject = build2("Add-On Roster Report - ",ms_date_range)
 ENDIF
 IF (mn_ops=1)
  SELECT INTO "nl:"
   FROM bhs_log b,
    bhs_log_detail bd,
    bhs_log_detail bd2,
    sch_appt sa,
    sch_resource sr,
    sch_res_list srl
   PLAN (b
    WHERE b.object_name="BHS_RPT_SCH_APT_ADD_ONS"
     AND b.updt_dt_tm BETWEEN (sysdate - 14) AND sysdate
     AND b.msg="000"
     AND b.parameters=cnvtupper(trim( $S_RECIPIENTS,3)))
    JOIN (bd
    WHERE bd.bhs_log_id=b.bhs_log_id
     AND bd.parent_entity_name="SCH_APPT_ID")
    JOIN (bd2
    WHERE bd2.bhs_log_id=b.bhs_log_id
     AND bd2.parent_entity_name="SCH_STATE_CD"
     AND bd2.detail_group=bd.detail_group)
    JOIN (sa
    WHERE sa.sch_appt_id=bd.parent_entity_id
     AND sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
     AND ((sa.role_meaning=null) OR (sa.role_meaning != "PATIENT"))
     AND sa.sch_state_cd=bd2.parent_entity_id
     AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sa.active_ind=1)
    JOIN (sr
    WHERE sr.person_id=sa.person_id
     AND sr.resource_cd=sa.resource_cd
     AND sr.active_ind=1
     AND sr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (srl
    WHERE srl.resource_cd=sr.resource_cd
     AND srl.active_ind=1
     AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (srl.res_group_id= $F_RES_GRP))
   ORDER BY bd.bhs_log_id, bd.detail_group, bd.detail_seq
   HEAD REPORT
    ml_cnt = 0
   HEAD sa.sch_appt_id
    ml_cnt += 1
    IF (ml_cnt > size(m_rec->log_qual,5))
     CALL alterlist(m_rec->log_qual,(ml_cnt+ 50))
    ENDIF
    m_rec->log_qual[ml_cnt].f_sch_appt_id = sa.sch_appt_id
   FOOT REPORT
    m_rec->l_log_cnt = ml_cnt,
    CALL alterlist(m_rec->log_qual,ml_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_resource sr,
   sch_res_list srl,
   sch_event se,
   sch_event_patient sep,
   person p,
   encntr_alias ea,
   encntr_alias ea2,
   location l,
   org_alias_pool_reltn oapr,
   person_alias pa,
   phone ph,
   address ad,
   sch_event_comm sec,
   long_text ltx
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(mf_begin_dt_tm) AND cnvtdatetime(mf_end_dt_tm)
    AND ((sa.role_meaning=null) OR (sa.role_meaning != "PATIENT"))
    AND (sa.sch_state_cd= $F_SCH_STATE_CD)
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.active_ind=1
    AND  NOT (expand(ml_idx,1,m_rec->l_log_cnt,sa.sch_appt_id,m_rec->log_qual[ml_idx].f_sch_appt_id))
   )
   JOIN (sr
   WHERE sr.person_id=sa.person_id
    AND sr.resource_cd=sa.resource_cd
    AND sr.active_ind=1
    AND sr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (srl
   WHERE srl.resource_cd=sr.resource_cd
    AND srl.active_ind=1
    AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND (srl.res_group_id= $F_RES_GRP))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (sep
   WHERE sep.sch_event_id=se.sch_event_id
    AND sep.active_ind=1
    AND sep.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (p
   WHERE p.person_id=sep.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(sep.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_ea_mrn_cd))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(sep.encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_ea_fin_cd))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (l
   WHERE l.location_cd=sa.appt_location_cd)
   JOIN (oapr
   WHERE (oapr.organization_id= Outerjoin(l.organization_id))
    AND (oapr.alias_entity_name= Outerjoin("PERSON_ALIAS"))
    AND (oapr.alias_entity_alias_type_cd= Outerjoin(mf_pa_mrn_cd)) )
   JOIN (pa
   WHERE (pa.person_alias_id= Outerjoin(p.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(mf_pa_mrn_cd))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ph
   WHERE (ph.parent_entity_id= Outerjoin(p.person_id))
    AND (ph.parent_entity_name= Outerjoin("PERSON"))
    AND (ph.active_ind= Outerjoin(1))
    AND (ph.phone_type_seq= Outerjoin(1))
    AND (ph.phone_type_cd= Outerjoin(mf_phone_home_cd))
    AND (ph.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ad
   WHERE (ad.parent_entity_id= Outerjoin(p.person_id))
    AND (ad.parent_entity_name= Outerjoin("PERSON"))
    AND (ad.active_ind= Outerjoin(1))
    AND (ad.address_type_seq= Outerjoin(1))
    AND (ad.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (ad.address_type_cd= Outerjoin(mf_address_home_cd)) )
   JOIN (sec
   WHERE (sec.sch_event_id= Outerjoin(se.sch_event_id))
    AND (sec.active_ind= Outerjoin(1))
    AND (sec.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ltx
   WHERE (ltx.long_text_id= Outerjoin(sec.text_id)) )
  ORDER BY sa.beg_dt_tm, sr.mnemonic, cnvtdatetime(sa.beg_dt_tm),
   sa.sch_appt_id, p.person_id
  HEAD REPORT
   ml_cnt = 0, l_pat_qual_cnt = 0
  HEAD sa.sch_appt_id
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 50))
   ENDIF
   m_rec->qual[ml_cnt].f_beg_dt_tm = sa.beg_dt_tm, m_rec->qual[ml_cnt].f_end_dt_tm = sa.end_dt_tm,
   m_rec->qual[ml_cnt].f_sch_appt_id = sa.sch_appt_id,
   m_rec->qual[ml_cnt].f_sch_event_id = se.sch_event_id, m_rec->qual[ml_cnt].f_schedule_id = sa
   .schedule_id, m_rec->qual[ml_cnt].l_sort_field = cnvtdate2(format(sa.beg_dt_tm,"MMDDYYYY;;D"),
    "MMDDYYYY"),
   m_rec->qual[ml_cnt].l_duration = sa.duration, m_rec->qual[ml_cnt].l_pat_cnt = 0, m_rec->qual[
   ml_cnt].l_detail_cnt = 0,
   m_rec->qual[ml_cnt].s_sch_state_disp = uar_get_code_display(sa.sch_state_cd), m_rec->qual[ml_cnt].
   f_sch_state_cd = sa.sch_state_cd, m_rec->qual[ml_cnt].s_resource_mnem = trim(sr.mnemonic),
   m_rec->qual[ml_cnt].s_appt_synonym_free = se.appt_synonym_free, m_rec->qual[ml_cnt].s_fin_nbr =
   trim(ea2.alias,3), m_rec->qual[ml_cnt].s_comment = trim(ltx.long_text,3)
  HEAD p.person_id
   m_rec->qual[ml_cnt].l_pat_cnt += 1,
   CALL alterlist(m_rec->qual[ml_cnt].pat_qual,m_rec->qual[ml_cnt].l_pat_cnt), m_rec->qual[ml_cnt].
   pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].f_person_id = sep.person_id,
   m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_name = p.name_full_formatted, m_rec
   ->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_birth_formatted = format(p.birth_dt_tm,
    "MM/DD/YYYY;;D"), m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_sex =
   uar_get_code_display(p.sex_cd)
   IF (ea.encntr_id > 0)
    m_rec->qual[ml_cnt].pat_qual[m_rec->qual[m_rec->qual].l_pat_cnt].s_mrn = trim(ea.alias,3)
   ELSEIF (pa.person_alias_id > 0
    AND pa.alias_pool_cd=oapr.alias_pool_cd
    AND ((pa.alias_pool_cd != 0) OR (pa.alias_pool_cd IS NOT null)) )
    m_rec->qual[ml_cnt].pat_qual[m_rec->qual[m_rec->qual].l_pat_cnt].s_mrn = trim(pa.alias,3)
   ENDIF
   m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].f_beg_dt_tm = cnvtdatetime(sa
    .beg_dt_tm,000000), m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].f_end_dt_tm =
   cnvtdatetime(sa.end_dt_tm,235959), m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].
   l_appt_cnt = 0,
   m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_home_phone = ph.phone_num, m_rec->
   qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_addr1 = ad.street_addr, m_rec->qual[ml_cnt]
   .pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_city = ad.city,
   m_rec->qual[ml_cnt].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_state = ad.state, m_rec->qual[ml_cnt
   ].pat_qual[m_rec->qual[ml_cnt].l_pat_cnt].s_zip = ad.zipcode
  FOOT  sa.sch_appt_id
   IF ((m_rec->qual[ml_cnt].l_pat_cnt > ml_max_pat_qual))
    ml_max_pat_qual = m_rec->qual[ml_cnt].l_pat_cnt
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_qual_cnt = ml_cnt
  WITH nocounter, expand = 1
 ;end select
 IF (mn_ops=1)
  EXECUTE bhs_hlp_ccl
  CALL bhs_sbr_log("start",cnvtupper(trim( $S_RECIPIENTS,3)),0,"",0.0,
   "","Begin Script","")
  FOR (ml_cnt = 1 TO m_rec->l_qual_cnt)
   CALL bhs_sbr_log("log","",ml_cnt,"SCH_APPT_ID",m_rec->qual[ml_cnt].f_sch_appt_id,
    "OPS_GROUP",cnvtupper(trim( $S_RECIPIENTS,3)),"S")
   CALL bhs_sbr_log("log","",ml_cnt,"SCH_STATE_CD",m_rec->qual[ml_cnt].f_sch_state_cd,
    "OPS_GROUP",cnvtupper(trim( $S_RECIPIENTS,3)),"S")
  ENDFOR
  CALL bhs_sbr_log("stop",cnvtupper(trim( $S_RECIPIENTS,3)),0,"",0.0,
   "","000","S")
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(m_rec->l_qual_cnt)),
   sch_event se,
   sch_event_detail ed,
   order_entry_fields oef,
   oe_format_fields off
  PLAN (d)
   JOIN (se
   WHERE (se.sch_event_id=m_rec->qual[d.seq].f_sch_event_id)
    AND se.active_ind=1
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ed
   WHERE ed.sch_event_id=se.sch_event_id
    AND ed.sch_action_id=0
    AND ed.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ed.active_ind=1)
   JOIN (oef
   WHERE oef.oe_field_id=ed.oe_field_id
    AND oef.oe_field_id IN (12683.00, 611657594.00, 663838.00))
   JOIN (off
   WHERE off.oe_field_id=oef.oe_field_id
    AND off.oe_format_id=se.oe_format_id)
  HEAD d.seq
   m_rec->qual[d.seq].l_detail_cnt = 0
  DETAIL
   m_rec->qual[d.seq].l_detail_cnt += 1,
   CALL alterlist(m_rec->qual[d.seq].detail_qual,m_rec->qual[d.seq].l_detail_cnt), m_rec->qual[d.seq]
   .detail_qual[m_rec->qual[d.seq].l_detail_cnt].f_oe_field_dt_tm_value = ed.oe_field_dt_tm_value,
   m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].f_oe_field_value = ed
   .oe_field_value, m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].l_oe_field_id =
   ed.oe_field_id, m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].n_field_type_flag
    = oef.field_type_flag,
   m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].s_oe_field_display_value = ed
   .oe_field_display_value, m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].
   s_description = concat(trim(off.label_text),":"), m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq
   ].l_detail_cnt].s_oe_field_meaning = ed.oe_field_meaning
  FOOT  d.seq
   IF (size(trim(m_rec->qual[d.seq].s_comment,3)) > 0)
    m_rec->qual[d.seq].l_detail_cnt += 1,
    CALL alterlist(m_rec->qual[d.seq].detail_qual,m_rec->qual[d.seq].l_detail_cnt), m_rec->qual[d.seq
    ].detail_qual[m_rec->qual[d.seq].l_detail_cnt].n_field_type_flag = 0,
    m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].s_description = "Comment: ",
    m_rec->qual[d.seq].detail_qual[m_rec->qual[d.seq].l_detail_cnt].s_oe_field_display_value = m_rec
    ->qual[d.seq].s_comment
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.sch_appt_id, e.appt_synonym_free, sch_state_disp = uar_get_code_display(a.sch_state_cd),
  d1.seq, ed.disp_value, d.seq,
  d2.seq
  FROM sch_appt a,
   sch_event e,
   dummyt d1,
   sch_event_disp ed,
   (dummyt d  WITH seq = value(m_rec->l_qual_cnt)),
   (dummyt d2  WITH seq = value(ml_max_pat_qual))
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= m_rec->qual[d.seq].l_pat_cnt))
   JOIN (a
   WHERE a.beg_dt_tm < cnvtdatetime(m_rec->qual[d.seq].pat_qual[d2.seq].f_end_dt_tm)
    AND a.end_dt_tm > cnvtdatetime(m_rec->qual[d.seq].pat_qual[d2.seq].f_beg_dt_tm)
    AND (a.person_id=m_rec->qual[d.seq].pat_qual[d2.seq].f_person_id)
    AND (((a.sch_event_id != m_rec->qual[d.seq].f_sch_event_id)) OR ((a.schedule_id != m_rec->qual[d
   .seq].f_schedule_id)))
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND (a.sch_state_cd= $F_SCH_STATE_CD)
    AND a.active_ind=1)
   JOIN (e
   WHERE e.sch_event_id=a.sch_event_id
    AND e.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (ed
   WHERE ed.sch_event_id=a.sch_event_id
    AND ((ed.schedule_id=0) OR (ed.schedule_id=a.schedule_id))
    AND ((ed.sch_appt_id=0) OR (ed.sch_appt_id=a.sch_appt_id))
    AND ed.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ed.disp_field_id=5
    AND ed.active_ind=1)
  ORDER BY d.seq, d2.seq, cnvtdatetime(a.beg_dt_tm),
   a.sch_appt_id
  HEAD d.seq
   dummy_value = 0
  HEAD d2.seq
   m_rec->qual[d.seq].pat_qual[d2.seq].l_appt_cnt = 0
  DETAIL
   m_rec->qual[d.seq].pat_qual[d2.seq].l_appt_cnt += 1, ml_appt_cnt = m_rec->qual[d.seq].pat_qual[d2
   .seq].l_appt_cnt,
   CALL alterlist(m_rec->qual[d.seq].pat_qual[d2.seq].appt_qual,ml_appt_cnt),
   m_rec->qual[d.seq].pat_qual[d2.seq].appt_qual[ml_appt_cnt].f_beg_dt_tm = a.beg_dt_tm, m_rec->qual[
   d.seq].pat_qual[d2.seq].appt_qual[ml_appt_cnt].f_end_dt_tm = a.end_dt_tm, m_rec->qual[d.seq].
   pat_qual[d2.seq].appt_qual[ml_appt_cnt].s_sch_state_disp = sch_state_disp,
   m_rec->qual[d.seq].pat_qual[d2.seq].appt_qual[ml_appt_cnt].s_appt_synonym_free = e
   .appt_synonym_free, m_rec->qual[d.seq].pat_qual[d2.seq].appt_qual[ml_appt_cnt].l_duration = a
   .duration, m_rec->qual[d.seq].pat_qual[d2.seq].appt_qual[ml_appt_cnt].s_primary_resource_mnem = ed
   .disp_display
  WITH nocounter, outerjoin = d1, maxcol = 2000,
   dontcare = ed
 ;end select
 SELECT INTO value(ms_output)
  d.seq
  FROM dummyt d
  HEAD REPORT
   ml_last_sort_field = ml_beg_day_num
  HEAD PAGE
   row + 1, col + 0, "{F/4}{CPI/14}{LPI/6}",
   row + 1, "{POS/72/28}{B}Report Date/Time: ", ms_curdate_tm,
   "{ENDB}", row + 1, "{POS/540/28}{B}Page: ",
   curpage";l;i", "{ENDB}", row + 1,
   "{F/4}{CPI/9}{LPI/5}", "{POS/185/55}{B}S C H E D U L I N G   M A N A G E M E N T", row + 1,
   "{POS/150/70}{B}Resource Appointment Summary (with all Appointments)", row + 1,
   "{F/4}{CPI/11}{LPI/6}",
   row + 1, "{POS/72/100}{B}Date: {ENDB}", ml_last_sort_field"@SHORTDATE",
   row + 1, "{POS/72/126}{B}Time", "{POS/110/126}{B}Dur",
   "{POS/154/126}{B}Appointment Type", "{POS/330/126}{B}State", "{POS/380/126}{B}Physician",
   "{POS/480/126}{B}Resource", row + 1, "{POS/72/127}{B}{REPEAT/61/_/}",
   row + 1, "{ENDB}", mn_cont_ind = 1,
   y_pos = 140
  DETAIL
   FOR (i = 1 TO m_rec->l_qual_cnt)
     WHILE ((ml_last_sort_field < m_rec->qual[i].l_sort_field))
       ml_foot_sort_field = ml_last_sort_field, ml_last_sort_field += 1, BREAK
     ENDWHILE
     ml_foot_sort_field = ml_last_sort_field, row + 1, "{F/4}{CPI/12}{LPI/6}"
     IF (y_pos > 668)
      mn_cont_ind = 0, BREAK
     ENDIF
     y_pos += 13,
     CALL print(calcpos(72,y_pos)), m_rec->qual[i].f_beg_dt_tm"@TIMENOSECONDS",
     CALL print(calcpos(110,y_pos)), m_rec->qual[i].l_duration"####",
     CALL print(calcpos(154,y_pos)),
     m_rec->qual[i].s_appt_synonym_free,
     CALL print(calcpos(330,y_pos)), m_rec->qual[i].s_sch_state_disp
     FOR (j = 1 TO m_rec->qual[i].l_detail_cnt)
       IF ((m_rec->qual[i].detail_qual[j].s_oe_field_meaning="SCHORDPHYS"))
        CALL print(calcpos(380,y_pos)), m_rec->qual[i].detail_qual[j].s_oe_field_display_value
        "#####################;;t", j = (m_rec->qual[i].l_detail_cnt+ 1)
       ENDIF
     ENDFOR
     CALL print(calcpos(480,y_pos)), m_rec->qual[i].s_resource_mnem, row + 1
     FOR (j = 1 TO m_rec->qual[i].l_pat_cnt)
       IF (y_pos > 681)
        mn_cont_ind = 0, BREAK
       ENDIF
       y_pos += 13, col 0, "{F/4}{CPI/12}{LPI/6}",
       CALL print(calcpos(72,y_pos)), "{B}", "Person: ",
       "{ENDB}",
       CALL print(calcpos(112,y_pos)), m_rec->qual[i].pat_qual[j].s_name,
       CALL print(calcpos(420,y_pos)), "{B}", "FIN: ",
       "{ENDB}",
       CALL print(calcpos(450,y_pos)), m_rec->qual[i].s_fin_nbr,
       row + 1
       IF (y_pos > 681)
        mn_cont_ind = 0, BREAK
       ENDIF
       y_pos += 13, col 0, "{F/4}{CPI/12}{LPI/6}",
       CALL print(calcpos(72,y_pos)), "{B}", "Home Phone: ",
       "{ENDB}",
       CALL print(calcpos(138,y_pos)), m_rec->qual[i].pat_qual[j].s_home_phone,
       row + 1, col + 0,
       CALL print(calcpos(216,y_pos)),
       "{B}", "MRN:", "{ENDB}",
       CALL print(calcpos(250,y_pos)), m_rec->qual[i].pat_qual[j].s_mrn, row + 1,
       col + 0,
       CALL print(calcpos(355,y_pos)), "{B}",
       "DOB:", "{ENDB}",
       CALL print(calcpos(384,y_pos)),
       m_rec->qual[i].pat_qual[j].s_birth_formatted, row + 1, col + 0,
       CALL print(calcpos(432,y_pos)), "{B}", "Gender:",
       "{ENDB}",
       CALL print(calcpos(473,y_pos)), m_rec->qual[i].pat_qual[j].s_sex,
       row + 1, y_pos += 13,
       CALL print(calcpos(72,y_pos)),
       "{B}", "Home Address: ", "{ENDB}",
       CALL print(calcpos(145,y_pos)), m_rec->qual[i].pat_qual[j].s_addr1, ", ",
       m_rec->qual[i].pat_qual[j].s_city, " ", m_rec->qual[i].pat_qual[j].s_state,
       ", ", m_rec->qual[i].pat_qual[j].s_zip
       IF ((m_rec->qual[i].pat_qual[j].l_appt_cnt > 0))
        IF (y_pos > 694)
         mn_cont_ind = 0, BREAK
        ENDIF
        y_pos += 13, row + 1, "{F/6}",
        CALL print(calcpos(154,y_pos)), "{B}Date",
        CALL print(calcpos(212,y_pos)),
        "{B}Time",
        CALL print(calcpos(250,y_pos)), "{B}Dur",
        CALL print(calcpos(288,y_pos)), "{B}Appointment Type",
        CALL print(calcpos(416,y_pos)),
        "{B}State",
        CALL print(calcpos(486,y_pos)), "{B}Resource",
        row + 1, "{ENDB}"
        FOR (k = 1 TO m_rec->qual[i].pat_qual[j].l_appt_cnt)
          IF (y_pos > 707)
           mn_cont_ind = 0, BREAK
          ENDIF
          y_pos += 13, col 0, "{F/6}",
          CALL print(calcpos(154,y_pos)), m_rec->qual[i].pat_qual[j].appt_qual[k].f_beg_dt_tm
          "@SHORTDATE",
          CALL print(calcpos(212,y_pos)),
          m_rec->qual[i].pat_qual[j].appt_qual[k].f_beg_dt_tm"@TIMENOSECONDS",
          CALL print(calcpos(250,y_pos)), m_rec->qual[i].pat_qual[j].appt_qual[k].l_duration"####",
          CALL print(calcpos(288,y_pos)), m_rec->qual[i].pat_qual[j].appt_qual[k].s_appt_synonym_free,
          CALL print(calcpos(416,y_pos)),
          m_rec->qual[i].pat_qual[j].appt_qual[k].s_sch_state_disp,
          CALL print(calcpos(486,y_pos)), m_rec->qual[i].pat_qual[j].appt_qual[k].
          s_primary_resource_mnem,
          row + 1
        ENDFOR
       ENDIF
     ENDFOR
     FOR (j = 1 TO m_rec->qual[i].l_detail_cnt)
       IF ((m_rec->qual[i].detail_qual[j].l_oe_field_id != 663838.00))
        m_rec->s_temp_string = concat("{B}",m_rec->qual[i].detail_qual[j].s_description,"{ENDB}")
        CASE (m_rec->qual[i].detail_qual[j].n_field_type_flag)
         OF 0:
          IF ((m_rec->qual[i].detail_qual[j].s_description IN ("Diagnosis:", "Procedure:")))
           m_rec->s_temp_string = concat(m_rec->s_temp_string,"  {B}",trim(m_rec->qual[i].
             detail_qual[j].s_oe_field_display_value),"{ENDB}")
          ELSE
           m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",m_rec->qual[i].detail_qual[j].
            s_oe_field_display_value)
          ENDIF
         OF 1:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",format(m_rec->qual[i].detail_qual[j
            ].f_oe_field_value,";l;i"))
         OF 2:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",format(m_rec->qual[i].detail_qual[j
            ].f_oe_field_value,";l;f"))
         OF 3:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",format(m_rec->qual[i].detail_qual[j
            ].f_oe_field_dt_tm_value,"@SHORTDATE"))
         OF 4:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",format(m_rec->qual[i].detail_qual[j
            ].f_oe_field_dt_tm_value,"@TIMENOSECONDS"))
         OF 5:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",format(m_rec->qual[i].detail_qual[j
            ].f_oe_field_dt_tm_value,"@SHORTDATETIME"))
         OF 6:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",m_rec->qual[i].detail_qual[j].
           s_oe_field_display_value)
         OF 7:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",evaluate(m_rec->qual[i].
            detail_qual[j].f_oe_field_value,1.0,"Yes","No"))
         OF 8:
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",m_rec->qual[i].detail_qual[j].
           s_oe_field_display_value)
         ELSE
          m_rec->s_temp_string = concat(m_rec->s_temp_string,"  ",m_rec->qual[i].detail_qual[j].
           s_oe_field_display_value)
        ENDCASE
        row + 1
        IF (y_pos > 707)
         mn_cont_ind = 0, BREAK
        ENDIF
        m_rec->l_temp_size = size(m_rec->s_temp_string), y_pos += ml_detail_offset,
        "{F/4}{CPI/15}{LPI/6}",
        mc120_print_line = substring(1,120,m_rec->s_temp_string),
        CALL print(calcpos(90,y_pos)), mc120_print_line
        IF ((m_rec->l_temp_size > 120))
         x_pos = 18
         IF (y_pos > 707)
          mn_cont_ind = 0, BREAK
         ENDIF
         y_pos += ml_detail_offset, mc120_print_line = substring(121,120,m_rec->s_temp_string),
         CALL print(calcpos((90+ x_pos),y_pos)),
         mc120_print_line
         IF ((m_rec->l_temp_size > 240))
          IF (y_pos > 707)
           mn_cont_ind = 0, BREAK
          ENDIF
          y_pos += ml_detail_offset, mc120_print_line = substring(241,120,m_rec->s_temp_string),
          CALL print(calcpos((90+ x_pos),y_pos)),
          mc120_print_line
         ENDIF
        ENDIF
        row + 1
       ENDIF
     ENDFOR
     y_pos += 13
   ENDFOR
  FOOT PAGE
   row + 1, col 0, "{F/4}{CPI/12}{LPI/6}"
   IF (mn_cont_ind)
    CALL print(calcpos(174,756)), "*** End of new appointments ", ms_date_range,
    " ***"
   ELSE
    CALL print(calcpos(252,756)), "*** To be continued ***"
   ENDIF
  WITH nocounter, maxcol = 2000, maxrow = 2000,
   dio = pdf
 ;end select
 IF (((mn_ops=1) OR (findstring("@", $S_RECIPIENTS) > 0)) )
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_output,ms_output,ms_recipients,ms_subject,1)
  SET ms_dclcom = "rm -f bhs_rpt_sch_apt_add_ons*"
  SET stat = 0
  SET stat = dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSEIF (findstring("@", $S_RECIPIENTS) > 0
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = ms_error, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)), msg1
   WITH dio = 08
  ;end select
 ENDIF
END GO
