CREATE PROGRAM bhs_athn_get_phys_handoff
 RECORD out_rec(
   1 patient = vc
   1 age = vc
   1 dob = vc
   1 mrn = vc
   1 fin = vc
   1 allergies = vc
   1 code_status = vc
   1 length_of_stay = vc
   1 illness_severity = vc
   1 patient_summary = vc
   1 actions[*]
     2 task_id = vc
     2 action = vc
     2 task_prsnl = vc
     2 task_dt_tm = vc
     2 task_status = vc
   1 situational_awareness[*]
     2 value = vc
     2 value_prsnl = vc
     2 value_dt_tm = vc
 )
 DECLARE condition_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,"CONDITION"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE patientsummary_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4003147,"PATIENTSUMMARY"))
 DECLARE finnbr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"))
 DECLARE cnt = i4
 DECLARE tz = i4
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE (e.encntr_id= $2))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.end_effective_dt_tm > sysdate
    AND pa.active_ind=1)
  HEAD REPORT
   out_rec->patient = p.name_full_formatted, out_rec->age = cnvtage(p.birth_dt_tm), out_rec->dob =
   format(p.birth_dt_tm,"mmm dd, yyyy;;q"),
   out_rec->length_of_stay = concat(trim(cnvtstring(floor(datetimediff(sysdate,e.reg_dt_tm)))),
    " Days"), out_rec->fin = ea.alias, out_rec->mrn = pa.alias
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   allergy a,
   nomenclature n
  PLAN (e
   WHERE (e.encntr_id= $2))
   JOIN (a
   WHERE a.person_id=e.person_id
    AND a.reaction_status_cd=active_cd
    AND a.cancel_reason_cd=0
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY n.source_string
  HEAD REPORT
   first_ind = 1
  DETAIL
   IF (first_ind=0)
    IF (a.substance_ftdesc > " ")
     out_rec->allergies = concat(trim(out_rec->allergies),char(44)," ",trim(a.substance_ftdesc))
    ELSE
     out_rec->allergies = concat(trim(out_rec->allergies),char(44)," ",trim(n.source_string))
    ENDIF
   ELSE
    first_ind = 0
    IF (a.substance_ftdesc > " ")
     out_rec->allergies = trim(a.substance_ftdesc)
    ELSE
     out_rec->allergies = trim(n.source_string)
    ENDIF
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id= $2)
    AND o.dcp_clin_cat_cd=condition_cd
    AND o.order_status_cd=ordered_cd)
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   out_rec->code_status = o.hna_order_mnemonic
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM pct_ipass pi
  PLAN (pi
   WHERE (pi.encntr_id= $2)
    AND pi.parent_entity_name="CODE_VALUE"
    AND pi.end_effective_dt_tm > sysdate
    AND pi.active_ind=1)
  HEAD REPORT
   out_rec->illness_severity = uar_get_code_display(pi.parent_entity_id)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM pct_ipass pi,
   task_activity ta,
   long_text lt,
   prsnl pr
  PLAN (pi
   WHERE (pi.encntr_id= $2)
    AND pi.parent_entity_name="TASK_ACTIVITY"
    AND pi.end_effective_dt_tm > sysdate
    AND pi.active_ind=1)
   JOIN (ta
   WHERE ta.task_id=pi.parent_entity_id)
   JOIN (lt
   WHERE lt.parent_entity_id=ta.task_id)
   JOIN (pr
   WHERE pr.person_id=ta.updt_id)
  ORDER BY ta.updt_dt_tm
  HEAD ta.task_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->actions,cnt), out_rec->actions[cnt].task_id = cnvtstring
   (ta.task_id),
   out_rec->actions[cnt].action = lt.long_text, out_rec->actions[cnt].task_prsnl = pr
   .name_full_formatted, out_rec->actions[cnt].task_dt_tm = datetimezoneformat(ta.updt_dt_tm,ta
    .task_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef),
   out_rec->actions[cnt].task_status = uar_get_code_display(ta.task_status_cd), tz = ta.task_tz
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM pct_ipass pi,
   sticky_note sn,
   prsnl pr
  PLAN (pi
   WHERE (pi.encntr_id= $2)
    AND pi.parent_entity_name="STICKY_NOTE"
    AND pi.end_effective_dt_tm > sysdate
    AND pi.active_ind=1)
   JOIN (sn
   WHERE sn.sticky_note_id=pi.parent_entity_id)
   JOIN (pr
   WHERE pr.person_id=pi.updt_id)
  ORDER BY sn.updt_dt_tm
  HEAD REPORT
   cnt = 0
  HEAD sn.sticky_note_id
   IF (pi.ipass_data_type_cd=patientsummary_cd)
    out_rec->patient_summary = sn.sticky_note_text
   ELSE
    cnt = (cnt+ 1), stat = alterlist(out_rec->situational_awareness,cnt), out_rec->
    situational_awareness[cnt].value = sn.sticky_note_text,
    out_rec->situational_awareness[cnt].value_prsnl = pr.name_full_formatted, out_rec->
    situational_awareness[cnt].value_dt_tm = datetimezoneformat(sn.updt_dt_tm,tz,
     "MM/dd/yyyy HH:mm:ss",curtimezonedef)
   ENDIF
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
