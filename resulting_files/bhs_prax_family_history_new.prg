CREATE PROGRAM bhs_prax_family_history_new
 FREE RECORD shx_fhx
 RECORD shx_fhx(
   1 patientid = f8
   1 mrn = vc
   1 name = vc
   1 fm_info[*]
     2 description = vc
   1 relation[*]
     2 relation_id = f8
     2 relation = vc
     2 relative_name = vc
     2 relative_gender = vc
     2 relative_age = vc
     2 relative_dob = vc
     2 relative_deceased = vc
     2 relative_deceased_dttm = vc
     2 cause_of_death = vc
     2 age_at_death = vc
     2 condition[*]
       3 condition_name = vc
       3 pos_neg = vc
       3 onset_age = vc
       3 comment = c500
       3 comment_dt = vc
       3 lifecycle = vc
       3 severity = vc
       3 course = vc
       3 fhx_activity_id = f8
       3 fhx_group_activity_id = f8
       3 last_update = vc
       3 updated_by = vc
       3 last_review = vc
       3 last_review_by = vc
       3 sub_conditions[*]
         4 sub_conditions_group_id = f8
 )
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",4,"MRN"))
 DECLARE fhx = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",351,"FAMILYHIST"))
 DECLARE fam = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",351,"FAMILYMEMBER"))
 DECLARE mpersonid = f8 WITH protect, constant(request->person[1].person_id)
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE json = vc WITH protect, noconstant("")
 SELECT INTO "NL:"
  FROM person_alias p,
   person pe
  PLAN (pe
   WHERE pe.person_id=mpersonid
    AND pe.active_ind=1)
   JOIN (p
   WHERE p.person_id=pe.person_id
    AND p.person_alias_type_cd=mrn_cd
    AND p.active_ind=1)
  HEAD REPORT
   cnt = 0, shx_fhx->mrn = p.alias, shx_fhx->name = pe.name_full_formatted,
   shx_fhx->patientid = p.person_id
  WITH time = 30, format, separator = " "
 ;end select
 SELECT DISTINCT INTO "NL:"
  person_reltn = uar_get_code_display(pp.person_reltn_cd), p_relative_name =
  IF (((p.name_full_formatted=" ") OR (p.name_full_formatted=",")) ) concat(trim(p.name_last,3),", ",
    trim(p.name_first,3))
  ELSE p.name_full_formatted
  ENDIF
  FROM person p,
   person_person_reltn pp
  PLAN (pp
   WHERE pp.person_id=mpersonid
    AND pp.end_effective_dt_tm > sysdate
    AND pp.active_ind=1
    AND pp.person_id > 0
    AND pp.person_reltn_cd != 0
    AND pp.person_reltn_type_cd IN (115572500.00, 1153))
   JOIN (p
   WHERE p.person_id=pp.related_person_id)
  ORDER BY pp.internal_seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(shx_fhx->relation,cnt), shx_fhx->relation[cnt].relation =
   person_reltn,
   shx_fhx->relation[cnt].relation_id = pp.related_person_id
   IF (p.age_at_death != 0)
    shx_fhx->relation[cnt].age_at_death = cnvtstring(p.age_at_death)
   ENDIF
   shx_fhx->relation[cnt].cause_of_death = p.cause_of_death
   IF (p.birth_dt_tm != null)
    shx_fhx->relation[cnt].relative_age = cnvtage(p.birth_dt_tm)
   ENDIF
   shx_fhx->relation[cnt].relative_deceased = uar_get_code_display(p.deceased_cd), shx_fhx->relation[
   cnt].relative_deceased_dttm = format(p.deceased_dt_tm,"MM-DD-YY HH:MM;;D"), shx_fhx->relation[cnt]
   .relative_dob = format(p.birth_dt_tm,"MM-DD-YY;;D"),
   shx_fhx->relation[cnt].relative_gender = uar_get_code_display(p.sex_cd), shx_fhx->relation[cnt].
   relative_name = p_relative_name
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 SELECT INTO "NL:"
  relationid = shx_fhx->relation[d1.seq].relation_id, relation = substring(1,30,shx_fhx->relation[d1
   .seq].relation), n.source_string,
  l_long_text =
  IF (l.long_text=" ") ""
  ELSE trim(l.long_text,3)
  ENDIF
  , fl.comment_dt_tm, build(cnvtstring(f.onset_age),uar_get_code_display(f.onset_age_unit_cd)),
  uar_get_code_display(f.course_cd), format(f.beg_effective_dt_tm,"mm-dd-yy hh:mm;;d"),
  uar_get_code_display(f.life_cycle_status_cd),
  uar_get_code_display(f.severity_cd), f.fhx_value_flag, f.fhx_activity_id,
  f1.fhx_activity_id
  FROM (dummyt d1  WITH seq = value(size(shx_fhx->relation,5))),
   fhx_activity f,
   nomenclature n,
   prsnl pr,
   fhx_long_text_r fl,
   long_text l,
   fhx_activity_r fa,
   fhx_activity f1,
   nomenclature n1,
   dm_flags dm
  PLAN (d1)
   JOIN (f
   WHERE f.person_id=mpersonid
    AND (f.related_person_id=shx_fhx->relation[d1.seq].relation_id)
    AND f.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=f.nomenclature_id
    AND n.active_ind=1)
   JOIN (pr
   WHERE f.updt_id=pr.person_id)
   JOIN (fl
   WHERE fl.fhx_activity_group_id=outerjoin(f.fhx_activity_group_id))
   JOIN (l
   WHERE l.long_text_id=outerjoin(fl.long_text_id)
    AND l.active_ind=outerjoin(1))
   JOIN (fa
   WHERE fa.fhx_activity_s_id=outerjoin(f.fhx_activity_group_id))
   JOIN (f1
   WHERE f1.fhx_activity_id=outerjoin(fa.fhx_activity_t_id)
    AND f1.active_ind=outerjoin(1))
   JOIN (n1
   WHERE n1.nomenclature_id=outerjoin(f1.nomenclature_id)
    AND n1.active_ind=outerjoin(1)
    AND n1.end_effective_dt_tm > outerjoin(sysdate))
   JOIN (dm
   WHERE dm.table_name="FHX_ACTIVITY"
    AND dm.column_name="FHX_VALUE_FLAG"
    AND dm.flag_value=f.fhx_value_flag)
  ORDER BY relation, n.source_string, f1.fhx_activity_id
  HEAD relationid
   cnt = 0
  HEAD n.source_string
   cnt = (cnt+ 1), stat = alterlist(shx_fhx->relation[d1.seq].condition,cnt), shx_fhx->relation[d1
   .seq].condition[cnt].condition_name = n.source_string,
   shx_fhx->relation[d1.seq].condition[cnt].course = uar_get_code_display(f.course_cd), shx_fhx->
   relation[d1.seq].condition[cnt].fhx_activity_id = f.fhx_activity_id, shx_fhx->relation[d1.seq].
   condition[cnt].fhx_group_activity_id = f.fhx_activity_group_id,
   shx_fhx->relation[d1.seq].condition[cnt].last_update = format(f.updt_dt_tm,"mm-dd-yy hh:mm;;d"),
   shx_fhx->relation[d1.seq].condition[cnt].lifecycle = uar_get_code_display(f.life_cycle_status_cd),
   shx_fhx->relation[d1.seq].condition[cnt].onset_age = build(cnvtstring(f.onset_age),
    uar_get_code_display(f.onset_age_unit_cd)),
   shx_fhx->relation[d1.seq].condition[cnt].severity = uar_get_code_display(f.severity_cd), shx_fhx->
   relation[d1.seq].condition[cnt].updated_by = pr.name_full_formatted, shx_fhx->relation[d1.seq].
   condition[cnt].comment = l_long_text,
   shx_fhx->relation[d1.seq].condition[cnt].comment_dt = format(fl.comment_dt_tm,"mm-dd-yy hh:mm;;d"),
   shx_fhx->relation[d1.seq].condition[cnt].pos_neg = dm.description, scnt = 0
  HEAD f1.fhx_activity_id
   IF (f1.fhx_activity_id != 0)
    scnt = (scnt+ 1), stat = alterlist(shx_fhx->relation[d1.seq].condition[cnt].sub_conditions,scnt),
    shx_fhx->relation[d1.seq].condition[cnt].sub_conditions[scnt].sub_conditions_group_id = f1
    .fhx_activity_id
   ENDIF
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 DECLARE fcnt = i4
 SELECT INTO "nl:"
  dm.description
  FROM fhx_activity f,
   dm_flags dm
  PLAN (f
   WHERE f.person_id=mpersonid
    AND f.related_person_id=0
    AND f.active_ind=1)
   JOIN (dm
   WHERE dm.table_name="FHX_ACTIVITY"
    AND dm.column_name="FHX_VALUE_FLAG"
    AND dm.flag_value=f.fhx_value_flag)
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(shx_fhx->fm_info,fcnt), shx_fhx->fm_info[fcnt].description = dm
   .description
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 SELECT INTO "NL:"
  fa.fhx_activity_id, fa.prsnl_id
  FROM (dummyt d1  WITH seq = value(size(shx_fhx->relation,5))),
   (dummyt d2  WITH seq = 1),
   fhx_action fa,
   prsnl p
  PLAN (d1
   WHERE maxrec(d2,size(shx_fhx->relation[d1.seq].condition,5)))
   JOIN (d2)
   JOIN (fa
   WHERE (fa.fhx_activity_id=shx_fhx->relation[d1.seq].condition[d2.seq].fhx_activity_id)
    AND fa.action_type_mean="REVIEW")
   JOIN (p
   WHERE fa.prsnl_id=p.person_id)
  ORDER BY fa.fhx_activity_id, fa.action_dt_tm DESC
  HEAD fa.fhx_activity_id
   shx_fhx->relation[d1.seq].condition[d2.seq].last_review = format(fa.action_dt_tm,
    "mm-dd-yy hh:mm;;d"), shx_fhx->relation[d1.seq].condition[d2.seq].last_review_by = p
   .name_full_formatted
  WITH nocounter, separator = " ", format,
   time = 30
 ;end select
 SET json = cnvtrectojson(shx_fhx)
 CALL echo(json)
 SELECT INTO value(moutputdevice)
  json
  FROM dummyt d
  WITH format, separator = "", maxcol = 32000
 ;end select
 FREE RECORD shx_fhx
END GO
