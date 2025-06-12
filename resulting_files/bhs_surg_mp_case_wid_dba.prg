CREATE PROGRAM bhs_surg_mp_case_wid:dba
 PROMPT
  "Enter Person ID:" = ""
  WITH f_person_id
 FREE RECORD surg
 RECORD surg(
   1 cnt = i4
   1 qual[*]
     2 ms_name_full = vc
     2 mf_surg_case_id = f8
     2 ms_case_nbr = vc
     2 ms_pat_status = vc
     2 ms_diag = vc
     2 ms_or_dt = vc
     2 ms_or_duration = vc
     2 ms_lang = vc
     2 ms_sched_surg_area = vc
     2 s_public_comment = vc
     2 s_latex_allergy_response = vc
     2 proc[*]
       3 f_surg_case_proc_id = f8
       3 i_primary_ind = i2
       3 s_proc_text = vc
       3 s_prim_surgeon = vc
       3 s_assist_surgeon = vc
       3 s_anesthesia_type = vc
 ) WITH protect
 DECLARE mf_interplang_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "INTERPRETERLANGUAGE"))
 DECLARE mf_interpreq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "INTERPRETERREQUIRED"))
 DECLARE mf_latexallergy_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "SNLATEXALLERGY"))
 DECLARE ms_no_data_found = vc WITH protect, constant("No data found")
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sch_event_comm sec,
   long_text lt,
   person p,
   sch_event_detail sed,
   sch_event_detail sed2,
   sch_event_detail sed3,
   sch_event_detail sed4
  PLAN (sc
   WHERE sc.person_id=mf_person_id
    AND sc.active_ind=1
    AND sc.sched_start_dt_tm >= cnvtdatetime(sysdate)
    AND sc.cancel_dt_tm = null)
   JOIN (sec
   WHERE (sec.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sec.active_ind= Outerjoin(1))
    AND (sec.text_type_meaning= Outerjoin("COMMENT"))
    AND (sec.sub_text_meaning= Outerjoin("SURGPUBLIC"))
    AND (sec.version_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   JOIN (lt
   WHERE (lt.long_text_id= Outerjoin(sec.text_id))
    AND (lt.active_ind= Outerjoin(1)) )
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (sed
   WHERE (sed.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sed.oe_field_meaning= Outerjoin("SURGDIAGNOSIS"))
    AND (sed.version_dt_tm>= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed.active_ind= Outerjoin(1)) )
   JOIN (sed2
   WHERE (sed2.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sed2.version_dt_tm>= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed2.active_ind= Outerjoin(1))
    AND (sed2.oe_field_id= Outerjoin(mf_interplang_cd)) )
   JOIN (sed3
   WHERE (sed3.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sed3.version_dt_tm>= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed3.active_ind= Outerjoin(1))
    AND (sed3.oe_field_id= Outerjoin(mf_interpreq_cd)) )
   JOIN (sed4
   WHERE (sed4.sch_event_id= Outerjoin(sc.sch_event_id))
    AND (sed4.version_dt_tm>= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (sed4.active_ind= Outerjoin(1))
    AND (sed4.oe_field_id= Outerjoin(mf_latexallergy_cd)) )
  ORDER BY sc.sched_start_dt_tm, sc.surg_case_id
  HEAD REPORT
   surg->cnt = 0
  HEAD sc.surg_case_id
   surg->cnt += 1, stat = alterlist(surg->qual,surg->cnt), surg->qual[surg->cnt].ms_name_full = p
   .name_full_formatted,
   surg->qual[surg->cnt].mf_surg_case_id = sc.surg_case_id, surg->qual[surg->cnt].ms_case_nbr = sc
   .surg_case_nbr_formatted, surg->qual[surg->cnt].ms_sched_surg_area = uar_get_code_display(sc
    .sched_surg_area_cd)
   IF (sed3.oe_field_display_value="Yes")
    surg->qual[surg->cnt].ms_lang = concat("Yes: ",trim(sed2.oe_field_display_value,3))
   ELSE
    surg->qual[surg->cnt].ms_lang = ms_no_data_found
   ENDIF
   surg->qual[surg->cnt].ms_diag = evaluate(textlen(trim(sed.oe_field_display_value,3)),0,
    ms_no_data_found,trim(sed.oe_field_display_value,3))
   IF (sc.sched_pat_type_cd > 0.0)
    surg->qual[surg->cnt].ms_pat_status = trim(uar_get_code_display(sc.sched_pat_type_cd),3)
   ELSE
    surg->qual[surg->cnt].ms_pat_status = ms_no_data_found
   ENDIF
   surg->qual[surg->cnt].ms_or_dt = trim(format(sc.sched_start_dt_tm,"MM/DD/YY HH:MM;;q"),3), surg->
   qual[surg->cnt].ms_or_duration = trim(cnvtstring(sc.sched_dur))
   IF (size(trim(lt.long_text,3)) > 0
    AND trim(lt.long_text,3) != ":")
    surg->qual[surg->cnt].s_public_comment = concat(replace(trim(lt.long_text,3),char(013)," "))
   ELSE
    surg->qual[surg->cnt].s_public_comment = ms_no_data_found
   ENDIF
   IF (sed4.oe_field_display_value > " ")
    surg->qual[surg->cnt].s_latex_allergy_response = trim(sed4.oe_field_display_value,3)
   ENDIF
   CALL echo(sed4.oe_field_display_value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surg_case_procedure scp,
   order_catalog_synonym ocs,
   order_catalog oc,
   prsnl p,
   order_detail od
  PLAN (scp
   WHERE expand(ml_idx1,1,surg->cnt,scp.surg_case_id,surg->qual[ml_idx1].mf_surg_case_id)
    AND scp.active_ind=1)
   JOIN (ocs
   WHERE (ocs.synonym_id= Outerjoin(scp.synonym_id)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(ocs.catalog_cd)) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
   JOIN (od
   WHERE (od.order_id= Outerjoin(scp.order_id))
    AND (od.oe_field_meaning= Outerjoin("SURGEON4")) )
  ORDER BY scp.surg_case_id, scp.sched_primary_ind DESC, scp.surg_case_proc_id,
   oc.primary_mnemonic, od.action_sequence DESC
  HEAD REPORT
   ml_idx2 = 0
  HEAD scp.surg_case_id
   ml_idx2 = locateval(ml_idx1,1,surg->cnt,scp.surg_case_id,surg->qual[ml_idx1].mf_surg_case_id),
   CALL echo(ml_idx2), ml_proc_cnt = 0
  HEAD scp.surg_case_proc_id
   ml_proc_cnt += 1, stat = alterlist(surg->qual[ml_idx1].proc,ml_proc_cnt), surg->qual[ml_idx2].
   proc[ml_proc_cnt].f_surg_case_proc_id = scp.surg_case_proc_id,
   surg->qual[ml_idx2].proc[ml_proc_cnt].i_primary_ind = scp.sched_primary_ind, surg->qual[ml_idx2].
   proc[ml_proc_cnt].s_proc_text = concat(trim(oc.primary_mnemonic,3))
   IF (size(trim(scp.sched_modifier,3)) > 0)
    surg->qual[ml_idx2].proc[ml_proc_cnt].s_proc_text = concat(surg->qual[ml_idx2].proc[ml_proc_cnt].
     s_proc_text," Modifier: ",trim(scp.sched_modifier,3))
   ENDIF
   surg->qual[ml_idx2].proc[ml_proc_cnt].s_prim_surgeon = p.name_full_formatted, surg->qual[ml_idx2].
   proc[ml_proc_cnt].s_assist_surgeon = evaluate(textlen(trim(od.oe_field_display_value,3)),0,
    ms_no_data_found,trim(od.oe_field_display_value)), surg->qual[ml_idx2].proc[ml_proc_cnt].
   s_anesthesia_type = evaluate(textlen(trim(uar_get_code_display(scp.sched_anesth_type_cd),3)),0,
    ms_no_data_found,trim(uar_get_code_display(scp.sched_anesth_type_cd),3))
  WITH nocounter
 ;end select
 CALL echorecord(surg)
 SET _memory_reply_string = cnvtrectojson(surg)
#exit_program
 CALL echo(_memory_reply_string)
END GO
