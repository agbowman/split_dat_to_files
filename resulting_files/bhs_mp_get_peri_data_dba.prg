CREATE PROGRAM bhs_mp_get_peri_data:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "MRN" = "",
  "First Name" = "",
  "Last Name" = "",
  "DOB" = "CURDATE",
  "Person ID" = 0,
  "Mother or Child PersonID?" = ""
  WITH outdev, s_mrn, s_name_first,
  s_name_last, s_dob, f_person_id,
  s_person_id_type
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_mother_person_id = f8
   1 s_mother_mrn = vc
   1 s_mother_name_last_key = vc
   1 s_mother_name_first_key = vc
   1 s_mother_name_last = vc
   1 s_mother_name_first = vc
   1 s_mother_dob = vc
   1 s_mother_obus_event_id = vc
   1 f_child_person_id = f8
   1 s_child_mrn = vc
   1 s_child_name_last_key = vc
   1 s_child_name_first_key = vc
   1 s_child_name_last = vc
   1 s_child_name_first = vc
   1 s_child_dob = vc
   1 s_child_pcp = vc
   1 s_child_feeding_plan = vc
   1 s_child_hc = vc
   1 s_child_erithro_ord = vc
   1 s_child_phyto_ord = vc
   1 mom_ords[*]
     2 s_source = vc
     2 f_order_id = f8
     2 s_order_mnemonic = vc
     2 s_display_line = vc
     2 s_status = vc
     2 s_order_dt_tm = vc
     2 s_done_dt_tm = vc
     2 s_freq = vc
   1 child_dta[*]
     2 s_detail = vc
     2 s_value = vc
 ) WITH protect
 DECLARE ms_name_last_key = vc WITH protect, constant(trim(cnvtupper( $S_NAME_LAST)))
 DECLARE ms_name_first_key = vc WITH protect, constant(trim(cnvtupper( $S_NAME_FIRST)))
 DECLARE ms_dob = vc WITH protect, constant(trim( $S_DOB))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE ms_person_id_type = vc WITH protect, constant(trim(cnvtupper( $S_PERSON_ID_TYPE)))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE mf_sex_f_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE mf_pharm_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE mf_incomplete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE mf_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE mf_feeding_plan_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FEEDINGPLANSNEWBORN"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE mf_ob_us_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"OBULTRASOUND"))
 DECLARE mf_head_circ_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEADCIRCUMFERENCE"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_erythro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ERYTHROMYCINOPHTHALMIC"))
 DECLARE mf_phyto_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PHYTONADIONE"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE ms_mrn = vc WITH protect, noconstant(trim( $S_MRN))
 WHILE (findstring("0",ms_mrn)=1)
   SET ms_mrn = substring(2,(textlen(ms_mrn) - 1),ms_mrn)
 ENDWHILE
 IF (ms_person_id_type="CHILD")
  SET m_rec->f_child_person_id = mf_person_id
  SET m_rec->s_mother_dob = ms_dob
  SET m_rec->s_mother_mrn = ms_mrn
  SET m_rec->s_mother_name_first_key = ms_name_first_key
  SET m_rec->s_mother_name_last_key = ms_name_last_key
 ELSEIF (ms_person_id_type="MOTHER")
  SET m_rec->f_mother_person_id = mf_person_id
  SET m_rec->s_child_dob = ms_dob
  SET m_rec->s_child_mrn = ms_mrn
  SET m_rec->s_child_name_first_key = ms_name_first_key
  SET m_rec->s_child_name_last_key = ms_name_last_key
 ENDIF
 CALL echo("select person")
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa
  PLAN (p
   WHERE ((p.name_last_key=ms_name_last_key) OR (ms_name_last_key <= " "))
    AND ((p.name_first_key=ms_name_first_key) OR (ms_name_first_key <= " "))
    AND p.birth_dt_tm BETWEEN cnvtdatetime(concat(ms_dob," 00:00:00")) AND cnvtdatetime(concat(ms_dob,
     " 23:59:59"))
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_mrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.alias=ms_mrn)
  DETAIL
   CALL echo("found matching person")
   IF (ms_person_id_type="MOTHER"
    AND p.sex_cd=mf_sex_f_cd)
    m_rec->f_child_person_id = p.person_id, m_rec->s_child_name_first = trim(p.name_first), m_rec->
    s_child_name_last = trim(p.name_last),
    m_rec->s_child_name_first_key = trim(p.name_first_key), m_rec->s_child_name_last_key = trim(p
     .name_last_key)
   ELSEIF (ms_person_id_type="CHILD")
    m_rec->f_mother_person_id = p.person_id, m_rec->s_mother_name_first = trim(p.name_first), m_rec->
    s_mother_name_last = trim(p.name_last),
    m_rec->s_mother_name_first_key = trim(p.name_first_key), m_rec->s_mother_name_last_key = trim(p
     .name_last_key)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get mrn/name/dob for person_id")
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa
  PLAN (p
   WHERE p.person_id=mf_person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_mrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
  HEAD p.person_id
   IF (ms_person_id_type="MOTHER")
    m_rec->s_mother_dob = trim(format(p.birth_dt_tm,"dd-mmm-yyyy;;d")), m_rec->s_mother_mrn = trim(pa
     .alias), m_rec->s_mother_name_first = trim(p.name_first),
    m_rec->s_mother_name_last = trim(p.name_last), m_rec->s_mother_name_first_key = trim(p
     .name_first_key), m_rec->s_mother_name_last_key = trim(p.name_last_key)
   ELSEIF (ms_person_id_type="CHILD")
    m_rec->s_child_dob = trim(format(p.birth_dt_tm,"dd-mmm-yyyy;;d")), m_rec->s_child_mrn = trim(pa
     .alias), m_rec->s_child_name_first = trim(p.name_first),
    m_rec->s_child_name_last = trim(p.name_last), m_rec->s_child_name_first_key = trim(p
     .name_first_key), m_rec->s_child_name_last_key = trim(p.name_last_key)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get active orders for mother")
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od,
   clinical_event ce,
   ce_med_result cmr,
   dummyt d
  PLAN (o
   WHERE (o.person_id=m_rec->f_mother_person_id)
    AND o.active_ind=1
    AND o.order_status_cd IN (mf_incomplete_cd, mf_ordered_cd, mf_pending_cd, mf_completed_cd)
    AND o.catalog_type_cd=mf_pharm_type_cd)
   JOIN (ce
   WHERE ce.order_id=o.order_id)
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id)
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id=mf_freq_cd
    AND od.action_sequence=1)
  ORDER BY o.orig_order_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD cmr.event_id
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->mom_ords,pl_cnt), m_rec->mom_ords[pl_cnt].s_source
    = "C",
   m_rec->mom_ords[pl_cnt].s_display_line = concat(trim(o.order_mnemonic)," ",o
    .order_detail_display_line), m_rec->mom_ords[pl_cnt].f_order_id = o.order_id, m_rec->mom_ords[
   pl_cnt].s_order_mnemonic = o.order_mnemonic,
   m_rec->mom_ords[pl_cnt].s_order_dt_tm = trim(format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
   m_rec->mom_ords[pl_cnt].s_status = uar_get_code_display(o.order_status_cd), m_rec->mom_ords[pl_cnt
   ].s_freq = trim(od.oe_field_display_value),
   m_rec->mom_ords[pl_cnt].s_done_dt_tm = trim(format(cmr.admin_start_dt_tm,"mm/dd/yy hh:mm;;d"))
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo("get mother's latest OB Ultrasound")
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=m_rec->f_mother_person_id)
    AND ce.event_cd=mf_ob_us_cd
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   m_rec->s_mother_obus_event_id = trim(cnvtstring(ce.event_id))
  WITH nocounter
 ;end select
 CALL echo("get baby's clinical events")
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.person_id=m_rec->f_child_person_id)
    AND ce.event_cd IN (mf_feeding_plan_cd, mf_head_circ_cd, mf_weight_cd, mf_height_cd)
    AND ce.valid_until_dt_tm > sysdate)
  ORDER BY ce.event_cd, ce.event_end_dt_tm
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.event_cd
   IF (ce.event_cd=mf_feeding_plan_cd)
    m_rec->s_child_feeding_plan = trim(ce.result_val)
   ELSE
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->child_dta,pl_cnt), m_rec->child_dta[pl_cnt].
    s_detail = trim(uar_get_code_display(ce.event_cd)),
    m_rec->child_dta[pl_cnt].s_value = trim(ce.result_val)
    IF (ce.result_units_cd > 0.0)
     m_rec->child_dta[pl_cnt].s_value = concat(m_rec->child_dta[pl_cnt].s_value," ",trim(
       uar_get_code_display(ce.result_units_cd)))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get baby orders")
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.person_id=m_rec->f_child_person_id)
    AND o.active_ind=1
    AND  NOT (o.order_status_cd IN (mf_canceled_cd, mf_deleted_cd))
    AND o.catalog_cd IN (mf_erythro_cd, mf_phyto_cd)
    AND o.catalog_type_cd=mf_pharm_type_cd)
  HEAD o.order_id
   IF (o.catalog_cd=mf_erythro_cd)
    m_rec->s_child_erithro_ord = trim(o.ordered_as_mnemonic)
   ELSEIF (o.catalog_cd=mf_phyto_cd)
    m_rec->s_child_phyto_ord = trim(o.ordered_as_mnemonic)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get baby's pcp")
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=m_rec->f_child_person_id)
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.person_prsnl_r_cd=mf_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY ppr.active_status_dt_tm DESC
  HEAD ppr.person_id
   m_rec->s_child_pcp = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
#exit_script
 SET _memory_reply_string = cnvtrectojson(m_rec)
 CALL echo(_memory_reply_string)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
