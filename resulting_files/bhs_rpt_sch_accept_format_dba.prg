CREATE PROGRAM bhs_rpt_sch_accept_format:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date:" = "CURDATE",
  "Resource Group:" = 0,
  "Resource:" = ""
  WITH outdev, ms_start_date, ms_end_date,
  mf_res_grp, mf_resource
 DECLARE mf_begin_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_START_DATE,
    "DD-MMM-YYYY"),0))
 DECLARE mf_end_dt_tm = f8 WITH protect, constant(cnvtdatetime(cnvtdate2( $MS_END_DATE,"DD-MMM-YYYY"),
   235959))
 DECLARE ms_cur_date_tm = vc WITH protect, constant(format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
 DECLARE mf_ea_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"MRN"))
 DECLARE mf_ea_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_pa_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE mf_address_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_creatinine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CREATININE"))
 DECLARE mf_creat_blood_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",72,
   "Creatinine-Blood"))
 DECLARE mf_gfrafricanamerican_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRAFRICANAMERICAN"))
 DECLARE mf_gfrnonafricanamerican_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ESTIMATEDGFRNONAFRICANAMERICAN"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED"))
 DECLARE mf_cs355_userdefined_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!13752"))
 DECLARE mf_cs100068_primary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",100068,
   "PRIMARY"))
 DECLARE mf_cs356_phonepriority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "PHONEPRIORITY"))
 DECLARE mf_cs356_cellpriority_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "CELLPRIORITY"))
 DECLARE mf_cs43_cell_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2510010055"))
 DECLARE max_patient_qual = i4 WITH protect, noconstant(0)
 DECLARE beg_day_num = i4 WITH public, noconstant(0)
 DECLARE end_day_num = i4 WITH public, noconstant(0)
 DECLARE print_line120 = c120 WITH public, noconstant(fillstring(120," "))
 DECLARE t_detail_offset = i4 WITH public, noconstant(13)
 SET beg_day_num = cnvtdate2(format(cnvtdatetime(mf_begin_dt_tm),"MMDDYYYY;;DATE"),"MMDDYYYY")
 SET end_day_num = cnvtdate2(format(cnvtdatetime(mf_end_dt_tm),"MMDDYYYY;;DATE"),"MMDDYYYY")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE SET t_rec
 RECORD t_rec(
   1 temp_string = vc
   1 temp_size = i4
   1 qual_cnt = i4
   1 qual[*]
     2 resource_cd = f8
     2 resource_mnem = vc
     2 sort_field = i4
     2 sch_appt_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 sch_state_disp = vc
     2 sch_event_id = f8
     2 schedule_id = f8
     2 appt_synonym_free = vc
     2 duration = i4
     2 fin_nbr = vc
     2 comment = vc
     2 detail_qual_cnt = i4
     2 detail_qual[*]
       3 oe_field_id = i4
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_meaning = vc
       3 oe_field_value = f8
       3 oe_field_meaning_id = f8
       3 description = vc
       3 description2 = vc
       3 accept_size = i4
       3 field_type_flag = i2
     2 patient_qual_cnt = i4
     2 patient_qual[*]
       3 person_id = f8
       3 name = vc
       3 mrn = vc
       3 home_phone = vc
       3 addr1 = vc
       3 city = vc
       3 state = vc
       3 zip = vc
       3 birth_dt_tm = dq8
       3 birth_tz = i4
       3 birth_formatted = vc
       3 sex = vc
       3 beg_dt_tm = dq8
       3 end_dt_tm = dq8
       3 diab_q = vc
       3 hypertension_q = vc
       3 kidney_q = vc
       3 allergy_q = vc
       3 creat_ind = i2
       3 creat_result = vc
       3 gfr_aa_result = vc
       3 gfr_na_result = vc
       3 appt_qual_cnt = i4
       3 appt_qual[*]
         4 sch_event_id = f8
         4 sch_appt_id = f8
         4 f_encntr_id = f8
         4 beg_dt_tm = dq8
         4 end_dt_tm = dq8
         4 sch_state_disp = vc
         4 appt_synonym_free = vc
         4 duration = i4
         4 primary_resource_mnem = vc
         4 s_ins_pri = vc
         4 s_ins_sec = vc
 )
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_parse_str = vc WITH protect, noconstant(" 1=1 ")
 SET ms_data_type = reflect(parameter(5,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_parse_str = parameter(5,1)
  IF (size(trim(ms_parse_str)) > 0)
   IF (trim(ms_parse_str)=char(42))
    SET ms_parse_str = " 1=1 "
   ELSE
    SET ms_parse_str = concat(" sr.resource_cd-0 = ",trim(ms_parse_str))
   ENDIF
  ELSE
   GO TO exit_program
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = parameter(5,ml_cnt)
   IF (ml_cnt=1)
    SET ms_parse_str = concat(" sr.resource_cd-0 in (",trim(ms_tmp_str))
   ELSE
    SET ms_parse_str = concat(ms_parse_str,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_parse_str = concat(ms_parse_str,")")
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
    AND ((sa.role_meaning = null) OR (sa.role_meaning != "PATIENT"))
    AND sa.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "FINALIZED", "NOSHOW",
   "PENDING", "STANDBY", "SCHEDULED")
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND sa.active_ind=1)
   JOIN (sr
   WHERE sr.person_id=sa.person_id
    AND sr.resource_cd=sa.resource_cd
    AND sr.active_ind=1
    AND sr.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND parser(ms_parse_str))
   JOIN (srl
   WHERE srl.resource_cd=sr.resource_cd
    AND srl.active_ind=1
    AND srl.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND (srl.res_group_id= $MF_RES_GRP))
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
  ORDER BY cnvtdate2(format(sa.beg_dt_tm,"MMDDYYYY;;D"),"MMDDYYYY"), sr.mnemonic, cnvtdatetime(sa
    .beg_dt_tm),
   sa.sch_appt_id, p.person_id, ph.phone_type_seq
  HEAD REPORT
   t_rec->qual_cnt = 0
  HEAD sa.sch_appt_id
   t_rec->qual_cnt += 1, stat = alterlist(t_rec->qual,t_rec->qual_cnt), t_rec->qual[t_rec->qual_cnt].
   sch_appt_id = sa.sch_appt_id,
   t_rec->qual[t_rec->qual_cnt].resource_cd = sr.resource_cd, t_rec->qual[t_rec->qual_cnt].
   resource_mnem = trim(sr.mnemonic), t_rec->qual[t_rec->qual_cnt].sort_field = cnvtdate2(format(sa
     .beg_dt_tm,"MMDDYYYY;;D"),"MMDDYYYY"),
   t_rec->qual[t_rec->qual_cnt].beg_dt_tm = sa.beg_dt_tm, t_rec->qual[t_rec->qual_cnt].end_dt_tm = sa
   .end_dt_tm, t_rec->qual[t_rec->qual_cnt].sch_state_disp = uar_get_code_display(sa.sch_state_cd),
   t_rec->qual[t_rec->qual_cnt].sch_event_id = se.sch_event_id, t_rec->qual[t_rec->qual_cnt].
   schedule_id = sa.schedule_id, t_rec->qual[t_rec->qual_cnt].appt_synonym_free = se
   .appt_synonym_free,
   t_rec->qual[t_rec->qual_cnt].duration = sa.duration, t_rec->qual[t_rec->qual_cnt].fin_nbr = trim(
    ea2.alias,3), t_rec->qual[t_rec->qual_cnt].patient_qual_cnt = 0,
   t_rec->qual[t_rec->qual_cnt].detail_qual_cnt = 0, t_rec->qual[t_rec->qual_cnt].comment = trim(ltx
    .long_text,3)
  HEAD p.person_id
   t_rec->qual[t_rec->qual_cnt].patient_qual_cnt += 1, stat = alterlist(t_rec->qual[t_rec->qual_cnt].
    patient_qual,t_rec->qual[t_rec->qual_cnt].patient_qual_cnt), t_rec->qual[t_rec->qual_cnt].
   patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].person_id = sep.person_id,
   t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].name = p
   .name_full_formatted, t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].
   patient_qual_cnt].birth_dt_tm = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1), t_rec->
   qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].birth_formatted
    = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YYYY;;D"),
   t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].sex =
   uar_get_code_display(p.sex_cd)
   IF (ea.encntr_id > 0)
    t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual].patient_qual_cnt].mrn = trim(
     ea.alias,3)
   ELSEIF (pa.person_alias_id > 0
    AND pa.alias_pool_cd=oapr.alias_pool_cd
    AND ((pa.alias_pool_cd != 0) OR (pa.alias_pool_cd IS NOT null)) )
    t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual].patient_qual_cnt].mrn = trim(
     pa.alias,3)
   ENDIF
   t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].
   home_phone = ph.phone_num, t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].
   patient_qual_cnt].beg_dt_tm = cnvtdatetime(concat(format(sa.beg_dt_tm,"DD-MMM-YYYY;;DATE"),
     " 00:00:00.00")), t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].
   patient_qual_cnt].end_dt_tm = cnvtdatetime(concat(format(sa.end_dt_tm,"DD-MMM-YYYY;;DATE"),
     " 23:59:00.00")),
   t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].
   appt_qual_cnt = 0, t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].
   patient_qual_cnt].addr1 = ad.street_addr, t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[
   t_rec->qual_cnt].patient_qual_cnt].city = ad.city,
   t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt].state =
   ad.state, t_rec->qual[t_rec->qual_cnt].patient_qual[t_rec->qual[t_rec->qual_cnt].patient_qual_cnt]
   .zip = ad.zipcode
  FOOT  sa.sch_appt_id
   IF ((t_rec->qual[t_rec->qual_cnt].patient_qual_cnt > max_patient_qual))
    max_patient_qual = t_rec->qual[t_rec->qual_cnt].patient_qual_cnt
   ENDIF
  WITH nocounter
 ;end select
 FOR (ml_idx1 = 1 TO size(t_rec->qual,5))
   FOR (ml_idx2 = 1 TO size(t_rec->qual[ml_idx1].patient_qual,5))
    SELECT INTO "nl:"
     FROM person_info pi
     PLAN (pi
      WHERE (pi.person_id=t_rec->qual[ml_idx1].patient_qual[ml_idx2].person_id)
       AND pi.active_ind=1
       AND pi.info_type_cd=mf_cs355_userdefined_cd
       AND pi.info_sub_type_cd=mf_cs356_phonepriority_cd
       AND pi.value_cd=mf_cs100068_primary_cd)
     WITH nocounter
    ;end select
    IF (((curqual < 1) OR (size(trim(t_rec->qual[ml_idx1].patient_qual[ml_idx2].home_phone,3))=0)) )
     SELECT INTO "nl:"
      FROM phone p
      PLAN (p
       WHERE (p.parent_entity_id=t_rec->qual[ml_idx1].patient_qual[ml_idx2].person_id)
        AND p.active_ind=1
        AND p.parent_entity_name="PERSON"
        AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND p.phone_type_cd=mf_cs43_cell_cd)
      ORDER BY p.parent_entity_id, p.phone_type_seq
      HEAD p.parent_entity_id
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].home_phone = trim(p.phone_num,3)
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM sch_event se,
   sch_event_detail ed,
   order_entry_fields oef,
   oe_format_fields off,
   (dummyt d  WITH seq = value(t_rec->qual_cnt))
  PLAN (d)
   JOIN (se
   WHERE (se.sch_event_id=t_rec->qual[d.seq].sch_event_id)
    AND se.active_ind=1
    AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (ed
   WHERE ed.sch_event_id=se.sch_event_id
    AND ed.sch_action_id=0
    AND ed.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND ed.active_ind=1)
   JOIN (oef
   WHERE oef.oe_field_id=ed.oe_field_id)
   JOIN (off
   WHERE off.oe_field_id=oef.oe_field_id
    AND off.oe_format_id=se.oe_format_id)
  HEAD d.seq
   t_rec->qual[d.seq].detail_qual_cnt = 0
  DETAIL
   t_rec->qual[d.seq].detail_qual_cnt += 1, stat = alterlist(t_rec->qual[d.seq].detail_qual,t_rec->
    qual[d.seq].detail_qual_cnt), t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].
   oe_field_id = ed.oe_field_id,
   t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].oe_field_display_value = ed
   .oe_field_display_value, t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].
   oe_field_dt_tm_value = ed.oe_field_dt_tm_value, t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].
   detail_qual_cnt].oe_field_meaning = ed.oe_field_meaning,
   t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].oe_field_value = ed
   .oe_field_value, t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].
   oe_field_meaning_id = ed.oe_field_meaning_id, t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].
   detail_qual_cnt].description = concat(trim(oef.description),":"),
   t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].description2 = concat(trim(off
     .label_text),":"), t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].
   accept_size = oef.accept_size, t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].
   field_type_flag = oef.field_type_flag
  FOOT  d.seq
   IF (size(trim(t_rec->qual[d.seq].comment,3)) > 0)
    t_rec->qual[d.seq].detail_qual_cnt += 1, stat = alterlist(t_rec->qual[d.seq].detail_qual,t_rec->
     qual[d.seq].detail_qual_cnt), t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt]
    .description2 = "Comment: ",
    t_rec->qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].field_type_flag = 0, t_rec->
    qual[d.seq].detail_qual[t_rec->qual[d.seq].detail_qual_cnt].oe_field_display_value = t_rec->qual[
    d.seq].comment
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
   (dummyt d  WITH seq = value(t_rec->qual_cnt)),
   (dummyt d2  WITH seq = value(max_patient_qual))
  PLAN (d)
   JOIN (d2
   WHERE (d2.seq <= t_rec->qual[d.seq].patient_qual_cnt))
   JOIN (a
   WHERE cnvtdatetime(t_rec->qual[d.seq].patient_qual[d2.seq].end_dt_tm) > a.beg_dt_tm
    AND cnvtdatetime(t_rec->qual[d.seq].patient_qual[d2.seq].beg_dt_tm) < a.end_dt_tm
    AND (t_rec->qual[d.seq].patient_qual[d2.seq].person_id=a.person_id)
    AND (((t_rec->qual[d.seq].sch_event_id != a.sch_event_id)) OR ((t_rec->qual[d.seq].schedule_id
    != a.schedule_id)))
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND a.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "FINALIZED", "NOSHOW",
   "PENDING", "STANDBY", "SCHEDULED")
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
   t_rec->qual[d.seq].patient_qual[d2.seq].appt_qual_cnt = 0
  DETAIL
   t_rec->qual[d.seq].patient_qual[d2.seq].appt_qual_cnt += 1, t_appt = t_rec->qual[d.seq].
   patient_qual[d2.seq].appt_qual_cnt, stat = alterlist(t_rec->qual[d.seq].patient_qual[d2.seq].
    appt_qual,t_appt),
   t_rec->qual[d.seq].patient_qual[d2.seq].appt_qual[t_appt].sch_event_id = a.sch_event_id, t_rec->
   qual[d.seq].patient_qual[d2.seq].appt_qual[t_appt].sch_appt_id = a.sch_appt_id, t_rec->qual[d.seq]
   .patient_qual[d2.seq].appt_qual[t_appt].f_encntr_id = a.encntr_id,
   t_rec->qual[d.seq].patient_qual[d2.seq].appt_qual[t_appt].beg_dt_tm = a.beg_dt_tm, t_rec->qual[d
   .seq].patient_qual[d2.seq].appt_qual[t_appt].end_dt_tm = a.end_dt_tm, t_rec->qual[d.seq].
   patient_qual[d2.seq].appt_qual[t_appt].sch_state_disp = sch_state_disp,
   t_rec->qual[d.seq].patient_qual[d2.seq].appt_qual[t_appt].appt_synonym_free = e.appt_synonym_free,
   t_rec->qual[d.seq].patient_qual[d2.seq].appt_qual[t_appt].duration = a.duration, t_rec->qual[d.seq
   ].patient_qual[d2.seq].appt_qual[t_appt].primary_resource_mnem = ed.disp_display
  WITH nocounter, outerjoin = d1, maxcol = 2000,
   dontcare = ed
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(t_rec->qual_cnt)),
   dummyt d2,
   dummyt d3,
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (d1
   WHERE maxrec(d2,t_rec->qual[d1.seq].patient_qual_cnt))
   JOIN (d2
   WHERE maxrec(d3,t_rec->qual[d1.seq].patient_qual[d2.seq].appt_qual_cnt))
   JOIN (d3)
   JOIN (epr
   WHERE (epr.encntr_id=t_rec->qual[d1.seq].patient_qual[d2.seq].appt_qual[d3.seq].f_encntr_id)
    AND epr.active_ind=1
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.active_ind=1)
  ORDER BY d1.seq, d2.seq, d3.seq,
   epr.priority_seq
  DETAIL
   IF (epr.priority_seq=1)
    t_rec->qual[d1.seq].patient_qual[d2.seq].appt_qual[d3.seq].s_ins_pri = trim(hp.plan_name,3)
   ELSEIF (epr.priority_seq=2)
    t_rec->qual[d1.seq].patient_qual[d2.seq].appt_qual[d3.seq].s_ins_sec = trim(hp.plan_name,3)
   ENDIF
  WITH nocounter
 ;end select
 FOR (ml_idx1 = 1 TO t_rec->qual_cnt)
  FOR (ml_idx2 = 1 TO t_rec->qual[ml_idx1].patient_qual_cnt)
    SET t_rec->qual[ml_idx1].patient_qual[ml_idx2].diab_q = "No"
    SET t_rec->qual[ml_idx1].patient_qual[ml_idx2].hypertension_q = "No"
    SET t_rec->qual[ml_idx1].patient_qual[ml_idx2].kidney_q = "No"
    SET t_rec->qual[ml_idx1].patient_qual[ml_idx2].allergy_q = "No"
    SELECT INTO "nl:"
     FROM problem p,
      bhs_nomen_list bnl
     PLAN (p
      WHERE (p.person_id=t_rec->qual[ml_idx1].patient_qual[ml_idx2].person_id)
       AND p.active_ind=1
       AND p.end_effective_dt_tm > sysdate)
      JOIN (bnl
      WHERE bnl.nomenclature_id=p.nomenclature_id
       AND bnl.nomen_list_key IN ("RAD_DIABETES", "RAD_KIDNEY_DISEASE", "RAD_HYPERTENSION")
       AND bnl.active_ind=1)
     ORDER BY bnl.nomen_list_key
     HEAD bnl.nomen_list_key
      IF (bnl.nomen_list_key="RAD_HYPERTENSION")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].hypertension_q = "Yes"
      ELSEIF (bnl.nomen_list_key="RAD_DIABETES")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].diab_q = "Yes"
      ELSEIF (bnl.nomen_list_key="RAD_KIDNEY_DISEASE")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].kidney_q = "Yes"
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM diagnosis d,
      bhs_nomen_list bnl
     PLAN (d
      WHERE (d.person_id=t_rec->qual[ml_idx1].patient_qual[ml_idx2].person_id)
       AND d.active_ind=1
       AND d.end_effective_dt_tm > sysdate)
      JOIN (bnl
      WHERE bnl.nomenclature_id=d.nomenclature_id
       AND bnl.nomen_list_key IN ("RAD_DIABETES", "RAD_KIDNEY_DISEASE", "RAD_HYPERTENSION")
       AND bnl.active_ind=1)
     ORDER BY bnl.nomen_list_key
     HEAD bnl.nomen_list_key
      IF (bnl.nomen_list_key="RAD_HYPERTENSION")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].hypertension_q = "Yes"
      ELSEIF (bnl.nomen_list_key="RAD_DIABETES")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].diab_q = "Yes"
      ELSEIF (bnl.nomen_list_key="RAD_KIDNEY_DISEASE")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].kidney_q = "Yes"
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM allergy a,
      bhs_nomen_list bnl
     PLAN (a
      WHERE (a.person_id=t_rec->qual[ml_idx1].patient_qual[ml_idx2].person_id)
       AND a.active_ind=1
       AND a.end_effective_dt_tm > sysdate)
      JOIN (bnl
      WHERE bnl.nomen_list_key IN ("RAD_ALLERGY_CT", "RAD_ALLERGY_MRI")
       AND bnl.nomenclature_id=a.substance_nom_id
       AND bnl.active_ind=1)
     DETAIL
      IF (substring(1,2,trim(cnvtupper(t_rec->qual[ml_idx1].appt_synonym_free),3))="CT"
       AND bnl.nomen_list_key="RAD_ALLERGY_CT")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].allergy_q = "Yes"
      ENDIF
      IF (substring(1,3,trim(cnvtupper(t_rec->qual[ml_idx1].appt_synonym_free),3)) IN ("MRI", "MRA")
       AND bnl.nomen_list_key="RAD_ALLERGY_MRI")
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].allergy_q = "Yes"
      ENDIF
     WITH nocounter
    ;end select
    SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
    SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
    "Does patient have any problem and/or diagnosis indicative of diabetes ? "
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].oe_field_display_value
     = t_rec->qual[ml_idx1].patient_qual[ml_idx2].diab_q
    SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
    SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
    "Does patient have any problem and/or diagnosis indicative of hypertension ? "
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].oe_field_display_value
     = t_rec->qual[ml_idx1].patient_qual[ml_idx2].hypertension_q
    SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
    SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
    "Does patient have any problem and/or diagnosis indicative of kidney disease ? "
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
    SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].oe_field_display_value
     = t_rec->qual[ml_idx1].patient_qual[ml_idx2].kidney_q
    IF (((substring(1,2,trim(cnvtupper(t_rec->qual[ml_idx1].appt_synonym_free),3)) IN ("CT")) OR (
    substring(1,3,trim(cnvtupper(t_rec->qual[ml_idx1].appt_synonym_free),3)) IN ("MRI", "MRA"))) )
     SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
     SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
     "Does patient have an allergy to one of the following : Contrast Dye, contrast media (gadolinium-based),"
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].
     oe_field_display_value = ""
     SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
     SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
     "    contrast media (iron oxide-based), contrast media (perfluorocarbon-based)? "
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].
     oe_field_display_value = t_rec->qual[ml_idx1].patient_qual[ml_idx2].allergy_q
    ENDIF
    SELECT INTO "nl:"
     FROM orders o,
      clinical_event ce,
      dummyt d1
     PLAN (o
      WHERE (o.person_id=t_rec->qual[ml_idx1].patient_qual[ml_idx2].person_id)
       AND o.catalog_cd=mf_creatinine_cd
       AND o.orig_order_dt_tm >= cnvtdatetime((curdate - 30),curtime3)
       AND o.order_status_cd=mf_completed_cd)
      JOIN (d1)
      JOIN (ce
      WHERE ce.order_id=o.order_id
       AND ce.event_cd IN (mf_creat_blood_cd, mf_gfrafricanamerican_cd, mf_gfrnonafricanamerican_cd)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     ORDER BY o.order_id
     HEAD o.order_id
      t_rec->qual[ml_idx1].patient_qual[ml_idx2].creat_ind = 1
     DETAIL
      IF (ce.event_cd=mf_creat_blood_cd)
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].creat_result = concat(trim(ce.result_val,3),
        " - Result Date: ",format(ce.valid_from_dt_tm,";;q"))
      ENDIF
      IF (ce.event_cd=mf_gfrafricanamerican_cd)
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].gfr_aa_result = concat(trim(ce.result_val,3),
        " - Result Date: ",format(ce.valid_from_dt_tm,";;q"))
      ENDIF
      IF (ce.event_cd=mf_gfrnonafricanamerican_cd)
       t_rec->qual[ml_idx1].patient_qual[ml_idx2].gfr_na_result = concat(trim(ce.result_val,3),
        " - Result Date: ",format(ce.valid_from_dt_tm,";;q"))
      ENDIF
     WITH nocounter, outerjoin = d1
    ;end select
    IF ((t_rec->qual[ml_idx1].patient_qual[ml_idx2].creat_ind=1))
     SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
     SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
     "Creatinine Blood:         "
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].
     oe_field_display_value = t_rec->qual[ml_idx1].patient_qual[ml_idx2].creat_result
     SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
     SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
     "GFR African American:     "
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].
     oe_field_display_value = t_rec->qual[ml_idx1].patient_qual[ml_idx2].gfr_aa_result
     SET t_rec->qual[ml_idx1].detail_qual_cnt += 1
     SET stat = alterlist(t_rec->qual[ml_idx1].detail_qual,t_rec->qual[ml_idx1].detail_qual_cnt)
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].description2 =
     "GFR Non African American: "
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0
     SET t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].
     oe_field_display_value = t_rec->qual[ml_idx1].patient_qual[ml_idx2].gfr_na_result
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM sch_event se,
    sch_event_action sea,
    sch_event_comm sec,
    long_text lt
   PLAN (se
    WHERE (se.sch_event_id=t_rec->qual[ml_idx1].sch_event_id)
     AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND se.active_ind=1)
    JOIN (sea
    WHERE sea.sch_event_id=se.sch_event_id
     AND sea.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sea.active_ind=1)
    JOIN (sec
    WHERE sec.sch_event_id=se.sch_event_id
     AND sec.sch_action_id=sea.sch_action_id
     AND sec.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND sec.active_ind=1
     AND sec.text_type_meaning="ACTION")
    JOIN (lt
    WHERE lt.long_text_id=sec.text_id)
   ORDER BY sea.sch_action_id
   HEAD sea.sch_action_id
    IF (substring(1,1,trim(lt.long_text,3)) != "[")
     t_rec->qual[ml_idx1].detail_qual_cnt += 1, stat = alterlist(t_rec->qual[ml_idx1].detail_qual,
      t_rec->qual[ml_idx1].detail_qual_cnt), t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].
     detail_qual_cnt].description2 = "Action Comment: ",
     t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].field_type_flag = 0,
     t_rec->qual[ml_idx1].detail_qual[t_rec->qual[ml_idx1].detail_qual_cnt].oe_field_display_value =
     trim(lt.long_text,3)
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 SELECT INTO  $1
  d.seq
  FROM dummyt d
  HEAD REPORT
   t_last_sort_field = beg_day_num, t_last_foot_field = beg_day_num
  HEAD PAGE
   row + 1, col + 0, "{F/4}{CPI/14}{LPI/6}",
   row + 1, "{POS/72/28}{B}Print Date/Time: ", ms_cur_date_tm,
   "{ENDB}", row + 1, "{POS/540/28}{B}Page: ",
   curpage";l;i", "{ENDB}", row + 1,
   "{F/4}{CPI/9}{LPI/5}", "{POS/185/55}{B}S C H E D U L I N G   M A N A G E M E N T", row + 1,
   "{POS/126/70}{B}Resource Daily Appointment Summary (with all Appointments)", row + 1,
   "{F/4}{CPI/11}{LPI/6}",
   row + 1, "{POS/72/100}{B}Date: {ENDB}", t_last_sort_field"@SHORTDATE",
   row + 1, "{POS/72/126}{B}Time", "{POS/110/126}{B}Dur",
   "{POS/154/126}{B}Appointment Type", "{POS/330/126}{B}State", "{POS/380/126}{B}Physician",
   "{POS/480/126}{B}Resource", row + 1, "{POS/72/127}{B}{REPEAT/83/_/}",
   row + 1, "{ENDB}", t_cont_ind = 1,
   y_pos = 140
  DETAIL
   FOR (i = 1 TO t_rec->qual_cnt)
     WHILE ((t_last_sort_field < t_rec->qual[i].sort_field))
       t_foot_sort_field = t_last_sort_field, t_last_sort_field += 1, BREAK
     ENDWHILE
     t_foot_sort_field = t_last_sort_field, row + 1, "{F/4}{CPI/12}{LPI/6}"
     IF (y_pos > 668)
      t_cont_ind = 0, BREAK
     ENDIF
     y_pos += 13,
     CALL print(calcpos(72,y_pos)), t_rec->qual[i].beg_dt_tm"@TIMENOSECONDS",
     CALL print(calcpos(110,y_pos)), t_rec->qual[i].duration"####",
     CALL print(calcpos(154,y_pos)),
     t_rec->qual[i].appt_synonym_free,
     CALL print(calcpos(330,y_pos)), t_rec->qual[i].sch_state_disp
     FOR (j = 1 TO t_rec->qual[i].detail_qual_cnt)
       IF ((t_rec->qual[i].detail_qual[j].oe_field_meaning="REFERPHYS"))
        CALL print(calcpos(380,y_pos)), t_rec->qual[i].detail_qual[j].oe_field_display_value
        "##############################;;t", j = (t_rec->qual[i].detail_qual_cnt+ 1)
       ENDIF
     ENDFOR
     CALL print(calcpos(480,y_pos)), t_rec->qual[i].resource_mnem, row + 1
     FOR (j = 1 TO t_rec->qual[i].patient_qual_cnt)
       IF (y_pos > 681)
        t_cont_ind = 0, BREAK
       ENDIF
       y_pos += 13, col 0, "{F/4}{CPI/12}{LPI/6}",
       CALL print(calcpos(72,y_pos)), "{B}", "Person: ",
       "{ENDB}",
       CALL print(calcpos(112,y_pos)), t_rec->qual[i].patient_qual[j].name,
       CALL print(calcpos(420,y_pos)), "{B}", "FIN: ",
       "{ENDB}",
       CALL print(calcpos(450,y_pos)), t_rec->qual[i].fin_nbr,
       row + 1
       IF (y_pos > 681)
        t_cont_ind = 0, BREAK
       ENDIF
       y_pos += 13, col 0, "{F/4}{CPI/12}{LPI/6}",
       CALL print(calcpos(72,y_pos)), "{B}", "Primary Phone: ",
       "{ENDB}",
       CALL print(calcpos(144,y_pos)), t_rec->qual[i].patient_qual[j].home_phone,
       row + 1, col + 0,
       CALL print(calcpos(216,y_pos)),
       "{B}", "MRN:", "{ENDB}",
       CALL print(calcpos(250,y_pos)), t_rec->qual[i].patient_qual[j].mrn, row + 1,
       col + 0,
       CALL print(calcpos(355,y_pos)), "{B}",
       "DOB:", "{ENDB}",
       CALL print(calcpos(384,y_pos)),
       t_rec->qual[i].patient_qual[j].birth_formatted, row + 1, col + 0,
       CALL print(calcpos(432,y_pos)), "{B}", "Gender:",
       "{ENDB}",
       CALL print(calcpos(473,y_pos)), t_rec->qual[i].patient_qual[j].sex,
       row + 1, y_pos += 13,
       CALL print(calcpos(72,y_pos)),
       "{B}", "Home Address: ", "{ENDB}",
       CALL print(calcpos(145,y_pos)), t_rec->qual[i].patient_qual[j].addr1, ", ",
       t_rec->qual[i].patient_qual[j].city, " ", t_rec->qual[i].patient_qual[j].state,
       ", ", t_rec->qual[i].patient_qual[j].zip
       IF ((t_rec->qual[i].patient_qual[j].appt_qual_cnt > 0))
        IF (y_pos > 694)
         t_cont_ind = 0, BREAK
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
        FOR (k = 1 TO t_rec->qual[i].patient_qual[j].appt_qual_cnt)
          IF (y_pos > 707)
           t_cont_ind = 0, BREAK
          ENDIF
          y_pos += 13, col 0, "{F/6}",
          CALL print(calcpos(154,y_pos)), t_rec->qual[i].patient_qual[j].appt_qual[k].beg_dt_tm
          "@SHORTDATE",
          CALL print(calcpos(212,y_pos)),
          t_rec->qual[i].patient_qual[j].appt_qual[k].beg_dt_tm"@TIMENOSECONDS",
          CALL print(calcpos(250,y_pos)), t_rec->qual[i].patient_qual[j].appt_qual[k].duration"####",
          CALL print(calcpos(288,y_pos)), t_rec->qual[i].patient_qual[j].appt_qual[k].
          appt_synonym_free,
          CALL print(calcpos(416,y_pos)),
          t_rec->qual[i].patient_qual[j].appt_qual[k].sch_state_disp,
          CALL print(calcpos(486,y_pos)), t_rec->qual[i].patient_qual[j].appt_qual[k].
          primary_resource_mnem,
          row + 1
          IF (textlen(trim(t_rec->qual[i].patient_qual[j].appt_qual[k].s_ins_pri,3)) > 0)
           y_pos += 13,
           CALL print(calcpos(154,y_pos)), "{B}Primary Ins: {ENDB}",
           t_rec->qual[i].patient_qual[j].appt_qual[k].s_ins_pri
           IF (textlen(trim(t_rec->qual[i].patient_qual[j].appt_qual[k].s_ins_sec,3)) > 0)
            CALL print(calcpos(365,y_pos)), "{B}Secondary Ins: {ENDB}", t_rec->qual[i].patient_qual[j
            ].appt_qual[k].s_ins_sec
           ENDIF
           row + 1
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
     FOR (j = 1 TO t_rec->qual[i].detail_qual_cnt)
       IF (1)
        t_rec->temp_string = concat("{B}",t_rec->qual[i].detail_qual[j].description2,"{ENDB}")
        CASE (t_rec->qual[i].detail_qual[j].field_type_flag)
         OF 0:
          IF ((t_rec->qual[i].detail_qual[j].description2 IN ("Diagnosis:", "Procedure:")))
           t_rec->temp_string = concat(t_rec->temp_string,"  {B}",trim(t_rec->qual[i].detail_qual[j].
             oe_field_display_value),"{ENDB}")
          ELSE
           t_rec->temp_string = concat(t_rec->temp_string,"  ",t_rec->qual[i].detail_qual[j].
            oe_field_display_value)
          ENDIF
         OF 1:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",format(t_rec->qual[i].detail_qual[j].
            oe_field_value,";l;i"))
         OF 2:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",format(t_rec->qual[i].detail_qual[j].
            oe_field_value,";l;f"))
         OF 3:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",format(t_rec->qual[i].detail_qual[j].
            oe_field_dt_tm_value,"@SHORTDATE"))
         OF 4:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",format(t_rec->qual[i].detail_qual[j].
            oe_field_dt_tm_value,"@TIMENOSECONDS"))
         OF 5:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",format(t_rec->qual[i].detail_qual[j].
            oe_field_dt_tm_value,"@SHORTDATETIME"))
         OF 6:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",t_rec->qual[i].detail_qual[j].
           oe_field_display_value)
         OF 7:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",evaluate(t_rec->qual[i].detail_qual[j].
            oe_field_value,1.0,"Yes","No"))
         OF 8:
          t_rec->temp_string = concat(t_rec->temp_string,"  ",t_rec->qual[i].detail_qual[j].
           oe_field_display_value)
         ELSE
          t_rec->temp_string = concat(t_rec->temp_string,"  ",t_rec->qual[i].detail_qual[j].
           oe_field_display_value)
        ENDCASE
        row + 1
        IF (y_pos > 707)
         t_cont_ind = 0, BREAK
        ENDIF
        t_rec->temp_size = size(t_rec->temp_string), y_pos += t_detail_offset, "{F/4}{CPI/15}{LPI/6}",
        print_line120 = substring(1,120,t_rec->temp_string),
        CALL print(calcpos(90,y_pos)), print_line120
        IF ((t_rec->temp_size > 120))
         x_pos = 18
         IF (y_pos > 707)
          t_cont_ind = 0, BREAK
         ENDIF
         y_pos += t_detail_offset, print_line120 = substring(121,120,t_rec->temp_string),
         CALL print(calcpos((90+ x_pos),y_pos)),
         print_line120
         IF ((t_rec->temp_size > 240))
          IF (y_pos > 707)
           t_cont_ind = 0, BREAK
          ENDIF
          y_pos += t_detail_offset, print_line120 = substring(241,120,t_rec->temp_string),
          CALL print(calcpos((90+ x_pos),y_pos)),
          print_line120
         ENDIF
        ENDIF
        row + 1
       ENDIF
     ENDFOR
     y_pos += 13
   ENDFOR
  FOOT PAGE
   row + 1, col 0, "{F/4}{CPI/12}{LPI/6}"
   IF (t_cont_ind)
    CALL print(calcpos(216,756)), "*** End of ", t_foot_sort_field"@SHORTDATE",
    " appointments ***"
   ELSE
    CALL print(calcpos(252,756)), "*** To be continued ***"
   ENDIF
  WITH nocounter, dio = postscript, formfeed = post,
   maxcol = 2000, maxrow = 2000
 ;end select
 CALL echorecord(t_rec)
#exit_script
END GO
