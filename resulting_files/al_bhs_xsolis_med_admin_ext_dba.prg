CREATE PROGRAM al_bhs_xsolis_med_admin_ext:dba
 DECLARE mf_start_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt = f8 WITH protect, noconstant(0.0)
 DECLARE mf_cs_180_bag_begin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!31642"
   ))
 IF (trim(cnvtupper( $1),3)="OPS")
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="BHS_XSOLIS_MED_ADMIN_EXT"
     AND di.info_name="START_DATE")
   DETAIL
    mf_start_dt = cnvtdatetime(di.info_date)
   WITH nocounter
  ;end select
  SET mf_stop_dt = cnvtdatetime(sysdate)
 ELSE
  IF (cnvtupper(trim( $2,3))="CURDATE*")
   SET mf_start_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
         5,trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
  ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
   SET mf_start_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
     "DD-MMM-YYYY HH:MM:SS;;d"))
  ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
   SET mf_start_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(
         curdate,0),"01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
  ELSE
   SET mf_start_dt = cnvtdatetime(trim( $2,3))
  ENDIF
  IF (cnvtupper(trim( $3,3))="CURDATE*")
   SET mf_stop_dt = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,
         5,trim( $3,3)))),"DD-MMM-YYYY;;d")," 23:59:59"))
  ELSEIF (cnvtupper(trim( $3,3))="LASTWEEK")
   SET mf_stop_dt = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","E","E"),
     "DD-MMM-YYYY HH:MM:SS;;d"))
  ELSEIF (cnvtupper(trim( $3,3))="LASTMONTH")
   SET mf_stop_dt = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,
         0),"01-MMM-YYYY;;d"))),"DD-MMM-YYYY 23:59:59;;d"))
  ELSE
   SET mf_stop_dt = cnvtdatetime(trim( $3,3))
  ENDIF
 ENDIF
 CALL echo(format(cnvtdatetime(mf_start_dt),";;q"))
 CALL echo(format(cnvtdatetime(mf_stop_dt),";;q"))
 EXECUTE bhs_check_domain
 EXECUTE bhs_hlp_ftp
 IF (mf_start_dt=0)
  CALL echo("Error: DM INFO start date not found")
  GO TO exit_script
 ENDIF
 DECLARE mf_cs53_immun_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!7991"))
 DECLARE mf_cs53_med_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2699"))
 DECLARE mf_cs53_txt_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2698"))
 DECLARE mf_cs24_child_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2661"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs220_bmc_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER"))
 DECLARE mf_cs220_bfmc_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE FRANKLIN MEDICAL CENTER"))
 DECLARE mf_cs220_bwh_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE WING HOSPITAL"))
 DECLARE mf_cs220_bmlh_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MARY LANE HOSPITAL"))
 DECLARE mf_cs220_bnh_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE NOBLE HOSPITAL"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs333_admitdoc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4023"))
 DECLARE mf_cs213_current_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4019"))
 DECLARE mf_cs320_docnbr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6664"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_event_cnt = i4 WITH protect, noconstant(0)
 DECLARE s_msg_dt_tm = vc WITH protect, noconstant("")
 DECLARE s_domain = vc WITH protect, noconstant("")
 DECLARE mf_cs73_adtegate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"ADTEGATE"))
 DECLARE mf_cs11000_ndc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3295"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_host = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_username = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_password = vc WITH protect, noconstant(" ")
 FREE RECORD m_out_alias
 RECORD m_out_alias(
   1 l_cs_cnt = i4
   1 qual[*]
     2 f_code_set = f8
     2 l_cv_cnt = i4
     2 qual[*]
       3 f_code_value = f8
       3 s_alias = vc
       3 f_contrib_sys_cd = f8
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_per_full_name = vc
     2 s_per_fname = vc
     2 s_per_mname = vc
     2 s_per_lname = vc
     2 s_per_dob = vc
     2 s_per_gender = vc
     2 s_fin = vc
     2 s_mrn = vc
     2 s_unit = vc
     2 s_fac = vc
     2 s_room = vc
     2 s_mrn_fac = vc
     2 s_cmrn = vc
     2 s_enc_type = vc
     2 s_med_service = vc
     2 s_enc_type_class = vc
     2 s_nurs_unit_alias = vc
     2 s_room_alias = vc
     2 s_admit_src = vc
     2 s_admit_phys_fname = vc
     2 s_admit_phys_lname = vc
     2 s_admit_phys_title = vc
     2 s_admit_phys_mname = vc
     2 s_admit_phys_alias = vc
     2 s_fin_class = vc
     2 s_disch_disposition = vc
     2 s_admit_dt = vc
     2 s_disch_dt = vc
     2 l_ocnt = i4
     2 oqual[*]
       3 f_order_id = f8
       3 f_catalog_cd = f8
       3 f_catalog_synonym_cd = f8
       3 s_order_mnemonic = vc
       3 s_catalog_type = vc
       3 l_ecnt = i4
       3 equal[*]
         4 f_event_id = f8
         4 f_parent_event_id = f8
         4 f_item_id = f8
         4 f_catalog_cd = f8
         4 s_catalog_disp = vc
         4 f_synonym_id = f8
         4 s_ndc = vc
         4 s_admin_route = vc
         4 s_admin_site = vc
         4 s_admin_dose = vc
         4 s_admin_unit = vc
         4 s_admin_form = vc
         4 s_admin_dt = vc
         4 s_result_status = vc
 )
 CALL loadoutalias("69, 71, 34, 220, 19, 2, 354",mf_cs73_adtegate_cd)
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_med_result cem,
   encounter e,
   encntr_alias ea1,
   encntr_alias ea2,
   person p,
   orders o,
   orders o2,
   order_catalog oc,
   order_ingredient oi,
   order_product op,
   med_identifier mi
  PLAN (ce
   WHERE ce.updt_dt_tm BETWEEN cnvtdatetime(mf_start_dt) AND cnvtdatetime(mf_stop_dt)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.view_level=1
    AND ce.event_class_cd IN (mf_cs53_immun_cd, mf_cs53_med_cd, mf_cs53_txt_cd)
    AND ce.event_reltn_cd=mf_cs24_child_cd
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd))
   JOIN (cem
   WHERE cem.event_id=ce.event_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.loc_facility_cd IN (mf_cs220_bmc_cd, mf_cs220_bfmc_cd, mf_cs220_bwh_cd, mf_cs220_bmlh_cd,
   mf_cs220_bnh_cd)
    AND e.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=e.encntr_id
    AND ea1.active_ind=1
    AND ea1.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea1.encntr_alias_type_cd=mf_cs319_fin_cd)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.active_ind=1
    AND ea2.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ea2.encntr_alias_type_cd=mf_cs319_mrn_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND o.order_id != 0
    AND o.active_ind=1)
   JOIN (o2
   WHERE o2.person_id=o.person_id
    AND o2.encntr_id=o.encntr_id
    AND o2.catalog_cd=o.catalog_cd
    AND o2.catalog_type_cd=o.catalog_type_cd
    AND o2.activity_type_cd=o.activity_type_cd
    AND ((o2.order_id=o.template_order_id) OR (o2.order_id=o.order_id
    AND o.template_order_id=0)) )
   JOIN (oc
   WHERE (oc.catalog_cd= Outerjoin(o.catalog_cd)) )
   JOIN (oi
   WHERE oi.order_id=o2.order_id
    AND oi.catalog_cd=ce.catalog_cd)
   JOIN (op
   WHERE op.order_id=oi.order_id
    AND op.action_sequence=oi.action_sequence
    AND op.ingred_sequence=oi.comp_sequence)
   JOIN (mi
   WHERE (mi.item_id= Outerjoin(op.item_id))
    AND (mi.active_ind= Outerjoin(1))
    AND (mi.med_identifier_type_cd= Outerjoin(mf_cs11000_ndc_cd)) )
  ORDER BY e.encntr_id, o2.order_id, cem.event_id,
   oi.action_sequence DESC
  HEAD e.encntr_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_encntr_id = e.encntr_id,
   m_rec->qual[m_rec->l_cnt].f_person_id = e.person_id, m_rec->qual[m_rec->l_cnt].s_per_full_name =
   trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_per_fname = trim(p.name_first,3),
   m_rec->qual[m_rec->l_cnt].s_per_mname = trim(p.name_middle,3), m_rec->qual[m_rec->l_cnt].
   s_per_lname = trim(p.name_last,3), m_rec->qual[m_rec->l_cnt].s_per_dob = format(p.birth_dt_tm,
    "YYYYMMDD;;d"),
   m_rec->qual[m_rec->l_cnt].s_per_gender = substring(1,1,trim(uar_get_code_display(p.sex_cd),3))
   IF (size(trim(m_rec->qual[m_rec->l_cnt].s_per_gender,3))=0)
    m_rec->qual[m_rec->l_cnt].s_per_gender = "U"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_fin = format(trim(ea1.alias,3),"##########;P0"), m_rec->qual[m_rec->
   l_cnt].s_mrn = format(trim(ea2.alias,3),"#######;P0"), m_rec->qual[m_rec->l_cnt].s_mrn_fac =
   substring(1,3,uar_get_code_display(ea2.alias_pool_cd)),
   m_rec->qual[m_rec->l_cnt].s_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), m_rec->qual[
   m_rec->l_cnt].s_fac = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->qual[m_rec->l_cnt].
   s_room = trim(uar_get_code_display(e.loc_room_cd),3),
   m_rec->qual[m_rec->l_cnt].s_enc_type = getalias(e.encntr_type_cd,mf_cs73_adtegate_cd), m_rec->
   qual[m_rec->l_cnt].s_enc_type_class = getalias(e.encntr_type_class_cd,mf_cs73_adtegate_cd), m_rec
   ->qual[m_rec->l_cnt].s_med_service = getalias(e.med_service_cd,mf_cs73_adtegate_cd),
   m_rec->qual[m_rec->l_cnt].s_nurs_unit_alias = getalias(e.loc_nurse_unit_cd,mf_cs73_adtegate_cd),
   m_rec->qual[m_rec->l_cnt].s_room_alias = getalias(e.loc_room_cd,mf_cs73_adtegate_cd)
   IF (size(trim(m_rec->qual[m_rec->l_cnt].s_room_alias,3))=0)
    m_rec->qual[m_rec->l_cnt].s_room_alias = trim(uar_get_code_display(e.loc_room_cd),3)
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_admit_src = getalias(e.admit_src_cd,mf_cs73_adtegate_cd), m_rec->qual[
   m_rec->l_cnt].s_fin_class = getalias(e.financial_class_cd,mf_cs73_adtegate_cd), m_rec->qual[m_rec
   ->l_cnt].s_disch_disposition = getalias(e.disch_disposition_cd,mf_cs73_adtegate_cd),
   m_rec->qual[m_rec->l_cnt].s_admit_dt = format(e.reg_dt_tm,"YYYYMMDDHHmmss;;q"), m_rec->qual[m_rec
   ->l_cnt].s_disch_dt = format(e.disch_dt_tm,"YYYYMMDDHHmmss;;q")
  HEAD o2.order_id
   m_rec->qual[m_rec->l_cnt].l_ocnt += 1, stat = alterlist(m_rec->qual[m_rec->l_cnt].oqual,m_rec->
    qual[m_rec->l_cnt].l_ocnt), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
   f_catalog_cd = o2.catalog_cd,
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].f_catalog_synonym_cd = o2
   .synonym_id, m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].f_order_id = o2
   .order_id, m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_catalog_type =
   uar_get_code_display(oc.catalog_type_cd),
   m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].s_order_mnemonic = trim(o2
    .order_mnemonic,3)
  HEAD cem.event_id
   IF (((cem.admin_dosage > 0) OR (cem.iv_event_cd=mf_cs_180_bag_begin_cd
    AND cem.initial_dosage > 0)) )
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].l_ecnt += 1, ml_event_cnt =
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].l_ecnt, stat = alterlist(m_rec
     ->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal,ml_event_cnt),
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].f_event_id
     = cem.event_id, m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[
    ml_event_cnt].f_parent_event_id = ce.parent_event_id, m_rec->qual[m_rec->l_cnt].oqual[m_rec->
    qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].f_catalog_cd = oi.catalog_cd,
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].
    s_catalog_disp = trim(uar_get_code_display(oi.catalog_cd),3), m_rec->qual[m_rec->l_cnt].oqual[
    m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].f_synonym_id = oi.synonym_id, m_rec->qual[
    m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].f_item_id = op.item_id,
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].s_ndc =
    trim(mi.value,3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[
    ml_event_cnt].s_admin_route = trim(uar_get_code_display(cem.admin_route_cd),3), m_rec->qual[m_rec
    ->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].s_admin_site = trim(
     uar_get_code_display(cem.admin_site_cd),3)
    IF (cem.admin_dosage > 0)
     m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].
     s_admin_dose = trim(format(cem.admin_dosage,"######.#####;T(1)"),3)
    ELSEIF (cem.iv_event_cd=mf_cs_180_bag_begin_cd
     AND cem.initial_dosage > 0)
     m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].
     s_admin_dose = trim(format(cem.initial_dosage,"######.#####;T(1)"),3)
    ENDIF
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].
    s_admin_unit = trim(uar_get_code_display(cem.dosage_unit_cd),3), m_rec->qual[m_rec->l_cnt].oqual[
    m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].s_admin_form = trim(uar_get_code_display(
      cem.medication_form_cd),3), m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].
    equal[ml_event_cnt].s_admin_dt = format(cnvtdatetime(ce.event_end_dt_tm),"YYYYMMDDHHMMSS;;q"),
    m_rec->qual[m_rec->l_cnt].oqual[m_rec->qual[m_rec->l_cnt].l_ocnt].equal[ml_event_cnt].
    s_result_status = trim(uar_get_code_display(ce.result_status_cd),3)
   ENDIF
  WITH nocounter
 ;end select
 IF ((m_rec->l_cnt=0))
  GO TO update_dminfo
 ENDIF
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE expand(ml_idx1,1,m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY pa.person_id, pa.beg_effective_dt_tm
  HEAD pa.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_cmrn = format(trim(pa.alias,3),"#######;P0"),ml_idx2 = locateval(ml_idx1,(
     ml_idx2+ 1),m_rec->l_cnt,pa.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ocnt)
     FOR (ml_idx3 = 1 TO m_rec->qual[ml_idx1].oqual[ml_idx2].l_ecnt)
       IF (size(trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_ndc,3))=0)
        IF ((m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].f_synonym_id > 0))
         SELECT INTO "nl:"
          FROM order_catalog_synonym ocs,
           med_identifier mi
          PLAN (ocs
           WHERE (ocs.synonym_id=m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].f_synonym_id)
            AND ocs.item_id > 0)
           JOIN (mi
           WHERE mi.item_id=ocs.item_id
            AND mi.active_ind=1
            AND mi.med_identifier_type_cd=mf_cs11000_ndc_cd)
          DETAIL
           m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].f_item_id = mi.item_id, m_rec->qual[
           ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_ndc = trim(mi.value,3)
          WITH nocounter
         ;end select
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   person p,
   person_name pn,
   prsnl_alias pa
  PLAN (epr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
    AND epr.encntr_prsnl_r_cd=mf_cs333_admitdoc_cd)
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
   JOIN (pn
   WHERE (pn.person_id= Outerjoin(p.person_id))
    AND (pn.active_ind= Outerjoin(1))
    AND (pn.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (pn.name_type_cd= Outerjoin(mf_cs213_current_cd)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p.person_id))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (pa.prsnl_alias_type_cd= Outerjoin(mf_cs320_docnbr_cd)) )
  ORDER BY epr.encntr_id, epr.beg_effective_dt_tm DESC, pn.name_type_seq
  HEAD epr.encntr_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   WHILE (ml_idx2 > 0)
     m_rec->qual[ml_idx2].s_admit_phys_alias = trim(pa.alias,3), m_rec->qual[ml_idx2].
     s_admit_phys_fname = trim(p.name_first_key,3), m_rec->qual[ml_idx2].s_admit_phys_lname = trim(p
      .name_last_key,3),
     m_rec->qual[ml_idx2].s_admit_phys_mname = trim(p.name_middle_key,3), m_rec->qual[ml_idx2].
     s_admit_phys_title = trim(pn.name_suffix,3), ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),m_rec->
      l_cnt,epr.encntr_id,m_rec->qual[ml_idx1].f_encntr_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SET s_msg_dt_tm = format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q")
 SET s_domain =
 IF (gl_bhs_prod_flag=1) "P"
 ELSE "T"
 ENDIF
 SET frec->file_name = concat("bhs_ma_med_admin_xsolis_",trim(format(cnvtdatetime(mf_start_dt),
    "MMDDYYYYHHmmss;;q"),3),"_",trim(format(cnvtdatetime(mf_stop_dt),"MMDDYYYYHHmmss;;q"),3),".txt")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ocnt)
     FOR (ml_idx3 = 1 TO m_rec->qual[ml_idx1].oqual[ml_idx2].l_ecnt)
       SET frec->file_buf = concat("MSH|^~\&|CERNER|",trim(substring(1,4,m_rec->qual[ml_idx1].s_fac),
         3),"|XSOLIS|XSOLIS","|",s_msg_dt_tm,
        "||RAS^O17","|",s_msg_dt_tm,trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3
          ].f_event_id,20,0),3),"|",
        s_domain,"|2.3",char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("PID|1","|",m_rec->qual[ml_idx1].s_cmrn,"|",m_rec->qual[ml_idx1].
        s_mrn,
        "^^^",m_rec->qual[ml_idx1].s_mrn_fac,"|","|",trim(m_rec->qual[ml_idx1].s_per_lname,3),
        "^",trim(m_rec->qual[ml_idx1].s_per_mname),"^",trim(m_rec->qual[ml_idx1].s_per_fname,3),"|",
        "|",m_rec->qual[ml_idx1].s_per_dob,"|",m_rec->qual[ml_idx1].s_per_gender,"|||||||||",
        "|",m_rec->qual[ml_idx1].s_fin,"||",char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("PV1|1","|",trim(m_rec->qual[ml_idx1].s_enc_type_class,3),"|",trim
        (m_rec->qual[ml_idx1].s_nurs_unit_alias,3),
        "^",trim(m_rec->qual[ml_idx1].s_room_alias,3),"|","|","|",
        "|","|","|","|",trim(m_rec->qual[ml_idx1].s_med_service,3),
        "|","|","|","|",trim(m_rec->qual[ml_idx1].s_admit_src,3),
        "|","|","|",trim(m_rec->qual[ml_idx1].s_admit_phys_alias,3),"^",
        trim(m_rec->qual[ml_idx1].s_admit_phys_lname,3),"^",trim(m_rec->qual[ml_idx1].
         s_admit_phys_fname,3),"^",trim(m_rec->qual[ml_idx1].s_admit_phys_mname,3),
        "^",trim(m_rec->qual[ml_idx1].s_admit_phys_title,3),"|",trim(m_rec->qual[ml_idx1].s_enc_type,
         3),"|",
        "|",trim(m_rec->qual[ml_idx1].s_fin_class,3),"|||||||||||||||","|",trim(m_rec->qual[ml_idx1].
         s_disch_disposition,3),
        "|||||||","|",trim(m_rec->qual[ml_idx1].s_admit_dt,3),"|",trim(m_rec->qual[ml_idx1].
         s_disch_dt,3),
        char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("RXA","|",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].
          equal[ml_idx3].f_parent_event_id,20,0),3),"|",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[
          ml_idx2].equal[ml_idx3].f_event_id,20,0),3),
        "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_dt,3),"|","|",trim(m_rec
         ->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_ndc,3),
        "^",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_catalog_disp,3),"^","NDC","^^",
        "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_dose,3),"|",trim(m_rec->
         qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_unit,3),"|",
        trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_form,3),"|","||||||||||","|",
        trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_result_status,3),
        "||||||",char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("RXR","|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].
         s_admin_route,3),"^",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_route,3
         ),
        "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_site,3),"^",trim(m_rec->
         qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_site,3),char(10))
       SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 IF (gl_bhs_prod_flag=1)
  SET ms_ftp_cmd = concat("put ",frec->file_name)
  SET ms_ftp_path = "ciscore/xsolis/p"
  SET ms_ftp_host = "transfer.baystatehealth.org"
  SET ms_ftp_username = "CernerFTP"
  SET ms_ftp_password = "gJeZD64"
  SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
   ms_ftp_path)
 ELSE
  SET ms_ftp_cmd = concat("put ",frec->file_name)
  SET ms_ftp_path = "ciscore/xsolis/t"
  SET ms_ftp_host = "transfer.baystatehealth.org"
  SET ms_ftp_username = "CernerFTP"
  SET ms_ftp_password = "gJeZD64"
  SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
   ms_ftp_path)
 ENDIF
 IF (findfile(trim(frec->file_name))=1)
  SET stat = remove(trim(frec->file_name))
  IF (stat=0)
   CALL echo("File could not be removed")
  ELSE
   CALL echo("File was removed")
  ENDIF
 ELSE
  CALL echo("File could not be removed. File does not exist or permission denied")
 ENDIF
 SET frec->file_name = concat("al_v2_adminreport.",trim(format(cnvtdatetime(sysdate),
    "YYYYMMDDHHmmss;;q"),3))
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ocnt)
     FOR (ml_idx3 = 1 TO m_rec->qual[ml_idx1].oqual[ml_idx2].l_ecnt)
       SET frec->file_buf = concat("MSH|^~\&|CERNER|",trim(substring(1,4,m_rec->qual[ml_idx1].s_fac),
         3),"|XSOLIS|XSOLIS","|",s_msg_dt_tm,
        "||RAS^O17","|",s_msg_dt_tm,trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3
          ].f_event_id,20,0),3),"|",
        s_domain,"|2.3",char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("PID|1","|",m_rec->qual[ml_idx1].s_cmrn,"|",m_rec->qual[ml_idx1].
        s_mrn,
        "^^^",m_rec->qual[ml_idx1].s_mrn_fac,"|","|",trim(m_rec->qual[ml_idx1].s_per_lname,3),
        "^",trim(m_rec->qual[ml_idx1].s_per_mname),"^",trim(m_rec->qual[ml_idx1].s_per_fname,3),"|",
        "|",m_rec->qual[ml_idx1].s_per_dob,"|",m_rec->qual[ml_idx1].s_per_gender,"|||||||||",
        "|",m_rec->qual[ml_idx1].s_fin,"||",char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("PV1|1","|",trim(m_rec->qual[ml_idx1].s_enc_type_class,3),"|",trim
        (m_rec->qual[ml_idx1].s_nurs_unit_alias,3),
        "^",trim(m_rec->qual[ml_idx1].s_room_alias,3),"|","|","|",
        "|","|","|","|",trim(m_rec->qual[ml_idx1].s_med_service,3),
        "|","|","|","|",trim(m_rec->qual[ml_idx1].s_admit_src,3),
        "|","|","|",trim(m_rec->qual[ml_idx1].s_admit_phys_alias,3),"^",
        trim(m_rec->qual[ml_idx1].s_admit_phys_lname,3),"^",trim(m_rec->qual[ml_idx1].
         s_admit_phys_fname,3),"^",trim(m_rec->qual[ml_idx1].s_admit_phys_mname,3),
        "^",trim(m_rec->qual[ml_idx1].s_admit_phys_title,3),"|",trim(m_rec->qual[ml_idx1].s_enc_type,
         3),"|",
        "|",trim(m_rec->qual[ml_idx1].s_fin_class,3),"|||||||||||||||","|",trim(m_rec->qual[ml_idx1].
         s_disch_disposition,3),
        "|||||||","|",trim(m_rec->qual[ml_idx1].s_admit_dt,3),"|",trim(m_rec->qual[ml_idx1].
         s_disch_dt,3),
        char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("RXA","|",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[ml_idx2].
          equal[ml_idx3].f_parent_event_id,20,0),3),"|",trim(cnvtstring(m_rec->qual[ml_idx1].oqual[
          ml_idx2].equal[ml_idx3].f_event_id,20,0),3),
        "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_dt,3),"|","|",trim(m_rec
         ->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_ndc,3),
        "^",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_catalog_disp,3),"^","NDC","^^",
        "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_dose,3),"|",trim(m_rec->
         qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_unit,3),"|",
        trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_form,3),"|","||||||||||","|",
        trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_result_status,3),
        "||||||",char(13))
       SET stat = cclio("WRITE",frec)
       SET frec->file_buf = concat("RXR","|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].
         s_admin_route,3),"^",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_route,3
         ),
        "|",trim(m_rec->qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_site,3),"^",trim(m_rec->
         qual[ml_idx1].oqual[ml_idx2].equal[ml_idx3].s_admin_site,3),char(10))
       SET stat = cclio("WRITE",frec)
     ENDFOR
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 GO TO exit_script
 IF (gl_bhs_prod_flag=1)
  SET ms_ftp_cmd = concat("put ",frec->file_name)
  SET ms_ftp_path = "CISPharmAdminPResults"
  SET ms_ftp_host = "transfer.baystatehealth.org"
  SET ms_ftp_username = "CernerFTP"
  SET ms_ftp_password = "gJeZD64"
  SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
   ms_ftp_path)
 ELSE
  SET ms_ftp_cmd = concat("put ",frec->file_name)
  SET ms_ftp_path = "CISPharmAdminTResults"
  SET ms_ftp_host = "transfer.baystatehealth.org"
  SET ms_ftp_username = "CernerFTP"
  SET ms_ftp_password = "gJeZD64"
  SET stat = bhs_ftp_cmd(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
   ms_ftp_path)
 ENDIF
 IF (findfile(trim(frec->file_name))=1)
  SET stat = remove(trim(frec->file_name))
  IF (stat=0)
   CALL echo("File could not be removed")
  ELSE
   CALL echo("File was removed")
  ENDIF
 ELSE
  CALL echo("File could not be removed. File does not exist or permission denied")
 ENDIF
#update_dminfo
 IF (trim(cnvtupper( $1),3)="OPS")
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(mf_stop_dt), di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm =
    cnvtdatetime(sysdate)
   WHERE di.info_domain="BHS_XSOLIS_MED_ADMIN_EXT"
    AND di.info_name="START_DATE"
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 GO TO exit_script
 SUBROUTINE (getalias(f_cv=f8,f_contrib_sys_cd=f8) =vc)
   DECLARE ml_cv_pos = i4 WITH noconstant(0)
   DECLARE ml_cs_pos = i4 WITH noconstant(0)
   DECLARE ml_ga_idx = i4 WITH noconstant(0)
   DECLARE mf_code_set = f8 WITH noconstant(0)
   DECLARE s_ret_val = vc WITH noconstant("")
   SET mf_code_set = uar_get_code_set(f_cv)
   IF (mf_code_set > 0)
    SET ml_cs_pos = locatevalsort(ml_ga_idx,1,m_out_alias->l_cs_cnt,mf_code_set,m_out_alias->qual[
     ml_ga_idx].f_code_set)
   ELSE
    RETURN(s_ret_val)
   ENDIF
   SET ml_cv_pos = locatevalsort(ml_ga_idx,1,m_out_alias->qual[ml_cs_pos].l_cv_cnt,f_cv,m_out_alias->
    qual[ml_cs_pos].qual[ml_ga_idx].f_code_value,
    f_contrib_sys_cd,m_out_alias->qual[ml_cs_pos].qual[ml_ga_idx].f_contrib_sys_cd)
   IF (ml_cv_pos > 0)
    SET s_ret_val = trim(m_out_alias->qual[ml_cs_pos].qual[ml_cv_pos].s_alias,3)
   ENDIF
   RETURN(s_ret_val)
 END ;Subroutine
 SUBROUTINE (loadoutalias(s_code_set=vc,f_contrib_sys_cd=f8) =i2)
   DECLARE l_ret_val = i2 WITH protect, noconstant(0)
   DECLARE l_cv_cnt = i4 WITH protect, noconstant(0)
   IF (f_contrib_sys_cd > 0.0)
    SELECT INTO "nl:"
     FROM code_value_outbound cvo
     WHERE parser(build("cvo.code_set in (",s_code_set,")"))
      AND cvo.contributor_source_cd=f_contrib_sys_cd
     ORDER BY cvo.code_set, cvo.code_value
     HEAD cvo.code_set
      m_out_alias->l_cs_cnt += 1, stat = alterlist(m_out_alias->qual,m_out_alias->l_cs_cnt),
      m_out_alias->qual[m_out_alias->l_cs_cnt].f_code_set = cvo.code_set,
      m_out_alias->qual[m_out_alias->l_cs_cnt].l_cv_cnt = 0
     DETAIL
      m_out_alias->qual[m_out_alias->l_cs_cnt].l_cv_cnt += 1, stat = alterlist(m_out_alias->qual[
       m_out_alias->l_cs_cnt].qual,m_out_alias->qual[m_out_alias->l_cs_cnt].l_cv_cnt), m_out_alias->
      qual[m_out_alias->l_cs_cnt].qual[m_out_alias->qual[m_out_alias->l_cs_cnt].l_cv_cnt].
      f_code_value = cvo.code_value,
      m_out_alias->qual[m_out_alias->l_cs_cnt].qual[m_out_alias->qual[m_out_alias->l_cs_cnt].l_cv_cnt
      ].s_alias = cvo.alias, m_out_alias->qual[m_out_alias->l_cs_cnt].qual[m_out_alias->qual[
      m_out_alias->l_cs_cnt].l_cv_cnt].f_contrib_sys_cd = cvo.contributor_source_cd
     WITH nocounter
    ;end select
    IF ((m_out_alias->l_cs_cnt > 0))
     SET l_ret_val = 1
    ENDIF
   ENDIF
   RETURN(l_ret_val)
 END ;Subroutine
#exit_script
END GO
