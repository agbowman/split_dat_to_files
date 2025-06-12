CREATE PROGRAM bhs_athn_get_ipass_pl_pats
 RECORD out_rec(
   1 pat_list_name = vc
   1 patients[*]
     2 encntr_id = vc
     2 person_id = vc
     2 name = vc
     2 mrn = vc
     2 fin = vc
     2 age = vc
     2 sex = vc
     2 illness_severity = vc
     2 action_cnt = vc
     2 unit = vc
     2 room = vc
     2 bed = vc
     2 resuscitation_status = vc
     2 resuscitation_details = vc
     2 resuscitation_order_cnt = vc
     2 resuscitation_order_dt_tm = vc
     2 patient_summary[*]
       3 summary = vc
       3 summary_prsnl = vc
       3 summary_dt_tm = vc
     2 documentation = vc
     2 doc_status = vc
     2 doc_dt_tm = vc
 )
 DECLARE finnbr_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"INPROCESS"))
 DECLARE onhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"ONHOLD"))
 DECLARE opened_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"OPENED"))
 DECLARE overdue_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"OVERDUE"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",79,"PENDING"))
 DECLARE condition_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,"CONDITION"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE patientsummary_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4003147,"PATIENTSUMMARY"))
 DECLARE progressnotehospital_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEHOSPITAL"))
 DECLARE cnt = i4
 DECLARE a_cnt = i4
 DECLARE r_cnt = i4
 DECLARE s_cnt = i4
 DECLARE tz = i4
 SELECT INTO "nl:"
  FROM dcp_patient_list dpl,
   dcp_pl_custom_entry dpce,
   encounter e,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (dpl
   WHERE (dpl.patient_list_id= $2))
   JOIN (dpce
   WHERE dpce.patient_list_id=dpl.patient_list_id)
   JOIN (e
   WHERE e.encntr_id=dpce.encntr_id)
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
  ORDER BY p.name_full_formatted, e.encntr_id
  HEAD REPORT
   out_rec->pat_list_name = dpl.name
  HEAD e.encntr_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->patients,cnt), out_rec->patients[cnt].encntr_id =
   cnvtstring(e.encntr_id),
   out_rec->patients[cnt].person_id = cnvtstring(e.person_id), out_rec->patients[cnt].name = p
   .name_full_formatted, out_rec->patients[cnt].mrn = pa.alias,
   out_rec->patients[cnt].fin = ea.alias, out_rec->patients[cnt].age = cnvtage(p.birth_dt_tm),
   out_rec->patients[cnt].sex = cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))),
   out_rec->patients[cnt].unit = uar_get_code_display(e.loc_nurse_unit_cd), out_rec->patients[cnt].
   room = uar_get_code_display(e.loc_room_cd), out_rec->patients[cnt].bed = uar_get_code_display(e
    .loc_bed_cd)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->patients,5)),
   pct_ipass pi
  PLAN (d)
   JOIN (pi
   WHERE pi.encntr_id=cnvtreal(out_rec->patients[d.seq].encntr_id)
    AND pi.parent_entity_name="CODE_VALUE"
    AND pi.end_effective_dt_tm > sysdate
    AND pi.active_ind=1)
  HEAD d.seq
   out_rec->patients[d.seq].illness_severity = uar_get_code_display(pi.parent_entity_id)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->patients,5)),
   pct_ipass pi,
   task_activity ta,
   long_text lt,
   prsnl pr
  PLAN (d)
   JOIN (pi
   WHERE pi.encntr_id=cnvtreal(out_rec->patients[d.seq].encntr_id)
    AND pi.parent_entity_name="TASK_ACTIVITY"
    AND pi.end_effective_dt_tm > sysdate
    AND pi.active_ind=1)
   JOIN (ta
   WHERE ta.task_id=pi.parent_entity_id
    AND ta.task_status_cd IN (inprocess_cd, onhold_cd, opened_cd, overdue_cd, pending_cd))
   JOIN (lt
   WHERE lt.parent_entity_id=ta.task_id)
   JOIN (pr
   WHERE pr.person_id=ta.updt_id)
  ORDER BY ta.encntr_id, ta.task_id
  HEAD ta.encntr_id
   a_cnt = 0
  HEAD ta.task_id
   a_cnt = (a_cnt+ 1)
  FOOT  ta.encntr_id
   out_rec->patients[d.seq].action_cnt = cnvtstring(a_cnt), tz = ta.task_tz
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->patients,5)),
   orders o
  PLAN (d)
   JOIN (o
   WHERE o.encntr_id=cnvtreal(out_rec->patients[d.seq].encntr_id)
    AND o.dcp_clin_cat_cd=condition_cd
    AND o.order_status_cd=ordered_cd)
  ORDER BY o.encntr_id, o.orig_order_dt_tm
  HEAD o.encntr_id
   out_rec->patients[d.seq].resuscitation_status = concat(trim(o.hna_order_mnemonic)," (",trim(o
     .ordered_as_mnemonic),")"), out_rec->patients[d.seq].resuscitation_details = o
   .order_detail_display_line, out_rec->patients[d.seq].resuscitation_order_dt_tm =
   datetimezoneformat(o.orig_order_dt_tm,o.orig_order_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef),
   r_cnt = 0
  DETAIL
   r_cnt = (r_cnt+ 1)
  FOOT  o.encntr_id
   out_rec->patients[d.seq].resuscitation_order_cnt = cnvtstring(r_cnt)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->patients,5)),
   pct_ipass pi,
   sticky_note sn,
   prsnl pr
  PLAN (d)
   JOIN (pi
   WHERE pi.encntr_id=cnvtreal(out_rec->patients[d.seq].encntr_id)
    AND pi.parent_entity_name="STICKY_NOTE"
    AND pi.ipass_data_type_cd=patientsummary_cd
    AND pi.active_ind=1)
   JOIN (sn
   WHERE sn.sticky_note_id=pi.parent_entity_id)
   JOIN (pr
   WHERE pr.person_id=pi.updt_id)
  ORDER BY pi.encntr_id, sn.updt_dt_tm
  HEAD pi.encntr_id
   s_cnt = 0
  HEAD sn.sticky_note_id
   s_cnt = (s_cnt+ 1), stat = alterlist(out_rec->patients[d.seq].patient_summary,s_cnt), out_rec->
   patients[d.seq].patient_summary[s_cnt].summary = sn.sticky_note_text,
   out_rec->patients[d.seq].patient_summary[s_cnt].summary_prsnl = pr.name_full_formatted, out_rec->
   patients[d.seq].patient_summary[s_cnt].summary_dt_tm = datetimezoneformat(sn.updt_dt_tm,tz,
    "MM/dd/yyyy HH:mm:ss",curtimezonedef)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->patients,5)),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE ce.encntr_id=cnvtreal(out_rec->patients[d.seq].encntr_id)
    AND ce.event_cd=progressnotehospital_cd
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1)
  ORDER BY ce.encntr_id, ce.event_end_dt_tm DESC
  HEAD ce.encntr_id
   out_rec->patients[d.seq].documentation = uar_get_code_display(ce.event_cd), out_rec->patients[d
   .seq].doc_status = uar_get_code_display(ce.result_status_cd), out_rec->patients[d.seq].doc_dt_tm
    = datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
