CREATE PROGRAM bhs_ma_ext_upc_appt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "File Date:" = "CURDATE"
  WITH outdev, s_date
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs6004_future_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!11559"))
 DECLARE mf_cs6004_ordered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE mf_cs6000_lab_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE mf_cs6000_rad_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3082"))
 DECLARE mf_cs331_pcp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4593"))
 DECLARE mf_cs356_race1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"RACE1"))
 DECLARE mf_cs356_ethnicity1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,
   "ETHNICITY"))
 DECLARE mf_cs69_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17005"))
 DECLARE mf_cs69_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE mf_cs69_observation_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!73451"
   ))
 DECLARE mf_cs321_emergency_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!1005613"))
 DECLARE mf_cs321_inpatient_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!1005614"))
 DECLARE mf_cs93_immunizations_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,
   "IMMUNIZATIONS"))
 DECLARE mf_cs220_baysthighstadlt_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",220,
   "Baystate High St Adult Medicine"))
 DECLARE mf_cs320_docnbr_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6664"))
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE ms_file = vc WITH protect, noconstant("")
 DECLARE ms_file_arch = vc WITH protect, noconstant("")
 DECLARE mf_date = f8 WITH protect, noconstant(0.0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 IF (cnvtupper(trim( $2,3))="CURDATE*")
  SET mf_date = cnvtdatetime(concat(format(datetimeadd(cnvtdatetime(sysdate),cnvtint(substring(8,5,
        trim( $2,3)))),"DD-MMM-YYYY;;d")," 00:00:00"))
 ELSEIF (cnvtupper(trim( $2,3))="LASTWEEK")
  SET mf_date = cnvtdatetime(format(datetimefind(cnvtdatetime((curdate - 7),0),"W","B","B"),
    "DD-MMM-YYYY HH:MM:SS;;d"))
 ELSEIF (cnvtupper(trim( $2,3))="TODAY")
  SET mf_date = cnvtdatetime(curdate,0)
 ELSEIF (cnvtupper(trim( $2,3))="LASTMONTH")
  SET mf_date = cnvtdatetime(format(cnvtlookbehind("1,D",cnvtdatetime(format(cnvtdatetime(curdate,0),
       "01-MMM-YYYY;;d"))),"01-MMM-YYYY 00:00:00;;d"))
 ELSE
  SET mf_date = cnvtdatetime(concat(trim( $2,3)," 00:00:00"))
 ENDIF
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
     2 s_cmrn = vc
     2 s_appt_dt = vc
     2 f_appt_dt = dq8
     2 s_appt_provider_nbr = vc
     2 s_appt_provider = vc
     2 s_appt_provider_id = vc
     2 s_appt_type = vc
     2 s_appt_reason = vc
     2 s_appt_team = vc
     2 f_person_id = f8
     2 s_pat_fname = vc
     2 s_pat_lname = vc
     2 s_pat_full_name = vc
     2 s_pat_dob = vc
     2 s_prim_ins = vc
     2 s_pat_race = vc
     2 s_pat_ethnicity = vc
     2 s_pat_language = vc
     2 s_pcp = vc
     2 s_pcp_doc_nbr = vc
     2 s_most_recent_hshc_appt = vc
     2 s_booked_outside_pcp = vc
     2 l_num_days_from_last_clinic_visit = i4
     2 f_prev_visit = dq8
     2 l_rad_ord = i4
     2 radqual[*]
       3 f_order_id = f8
       3 s_order_mnemonic = vc
       3 s_order_dt = vc
       3 s_order_detail = vc
     2 l_lab_ord = i4
     2 labqual[*]
       3 f_order_id = f8
       3 s_order_mnemonic = vc
       3 s_order_dt = vc
       3 s_order_detail = vc
     2 l_pres_ord = i4
     2 presqual[*]
       3 f_order_id = f8
       3 s_order_mnemonic = vc
       3 s_order_dt = vc
       3 s_order_detail = vc
     2 l_ed_visits_three_months = i4
     2 l_inpt_obs_visit_three_months = i4
     2 l_phone_doc_count = i4
     2 s_ed_visits = vc
     2 s_inp_obs_visits = vc
     2 s_phone_doc_found = vc
     2 l_prob_cnt = i4
     2 prob_qual[*]
       3 f_prob_id = f8
       3 s_prob_code = vc
       3 s_prob_desc = vc
       3 s_prob_vocab = vc
     2 l_hcnt = i4
     2 hqual[*]
       3 s_expectation_name = vc
       3 s_due_date = vc
       3 s_last_satisfied = vc
     2 l_icnt = i4
     2 iqual[*]
       3 s_immun_name = vc
       3 s_admin_dt = vc
     2 l_ncnt = i4
     2 nqual[*]
       3 f_clin_event_id = f8
       3 s_note_type = vc
       3 s_fin = vc
       3 s_create_dt = vc
 ) WITH protect
 DECLARE ml_pipe_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_line_count = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_line = vc WITH protect, noconstant("")
 SET ms_file = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/in/ambulatory_future_appts_input_",trim(format(cnvtdatetime(mf_date),
    "YYYYMMDD;;q"),3),".csv")
 SET ms_file_arch = replace(ms_file,"appt_ext/in/","appt_ext/archive/")
 CALL echo(ms_file_arch)
 CALL echo(ms_file)
 IF (findfile(ms_file,4) != 1)
  CALL echo("Error. Encounter file not found.")
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 ms_file
 SELECT INTO "nl:"
  FROM rtl2t r
  HEAD REPORT
   m_rec->l_cnt = 0
  DETAIL
   IF (size(trim(r.line,3)) > 0)
    ml_line_count += 1
    IF (ml_line_count > 1)
     ms_tmp_line = trim(r.line,3), m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt),
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      IF (isnumeric(substring(1,(ml_pipe_loc - 1),ms_tmp_line)) > 0)
       m_rec->qual[m_rec->l_cnt].s_cmrn = trim(cnvtstring(cnvtreal(substring(1,(ml_pipe_loc - 1),
           ms_tmp_line)),20,0),3)
      ELSE
       m_rec->qual[m_rec->l_cnt].s_cmrn = substring(1,(ml_pipe_loc - 1),ms_tmp_line)
      ENDIF
      ms_tmp_line = trim(substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      m_rec->qual[m_rec->l_cnt].s_appt_dt = substring(1,(ml_pipe_loc - 1),ms_tmp_line), m_rec->qual[
      m_rec->l_cnt].f_appt_dt = cnvtdatetime(m_rec->qual[m_rec->l_cnt].s_appt_dt), ms_tmp_line = trim
      (substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      m_rec->qual[m_rec->l_cnt].s_appt_provider_id = substring(1,(ml_pipe_loc - 1),ms_tmp_line),
      ms_tmp_line = trim(substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      m_rec->qual[m_rec->l_cnt].s_appt_provider = substring(1,(ml_pipe_loc - 1),ms_tmp_line),
      ms_tmp_line = trim(substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      m_rec->qual[m_rec->l_cnt].s_appt_provider_nbr = substring(1,(ml_pipe_loc - 1),ms_tmp_line),
      ms_tmp_line = trim(substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      m_rec->qual[m_rec->l_cnt].s_appt_type = substring(1,(ml_pipe_loc - 1),ms_tmp_line), ms_tmp_line
       = trim(substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     ml_pipe_loc = findstring("|",ms_tmp_line)
     IF (ml_pipe_loc > 0)
      m_rec->qual[m_rec->l_cnt].s_appt_reason = substring(1,(ml_pipe_loc - 1),ms_tmp_line),
      ms_tmp_line = trim(substring((ml_pipe_loc+ 1),size(ms_tmp_line),ms_tmp_line),3)
     ENDIF
     m_rec->qual[m_rec->l_cnt].s_appt_team = trim(ms_tmp_line,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ms_dclcom = concat("mv ",ms_file," ",ms_file_arch)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SELECT INTO "nl:"
  FROM person_alias pa,
   person p
  PLAN (pa
   WHERE expand(ml_idx1,1,m_rec->l_cnt,pa.alias,m_rec->qual[ml_idx1].s_cmrn)
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
   JOIN (p
   WHERE p.person_id=pa.person_id
    AND p.active_ind=1)
  DETAIL
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pa.alias,m_rec->qual[ml_idx1].s_cmrn)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].f_person_id = pa.person_id, m_rec->qual[ml_idx2].s_pat_fname = trim(p
     .name_first,3), m_rec->qual[ml_idx2].s_pat_lname = trim(p.name_last,3),
    m_rec->qual[ml_idx2].s_pat_full_name = trim(p.name_full_formatted,3), m_rec->qual[ml_idx2].
    s_pat_dob = trim(format(p.birth_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[ml_idx2].s_pat_language =
    trim(uar_get_code_display(p.language_cd),3),
    m_rec->qual[ml_idx2].s_ed_visits = "No", m_rec->qual[ml_idx2].s_inp_obs_visits = "No"
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND o.order_status_cd=mf_cs6004_future_cd
    AND o.active_ind=1
    AND o.catalog_type_cd IN (mf_cs6000_lab_cd, mf_cs6000_rad_cd))
  ORDER BY o.person_id, o.order_id
  HEAD o.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
  HEAD o.order_id
   IF (ml_idx2 > 0)
    IF (o.catalog_type_cd=mf_cs6000_lab_cd)
     m_rec->qual[ml_idx2].l_lab_ord += 1, stat = alterlist(m_rec->qual[ml_idx2].labqual,m_rec->qual[
      ml_idx2].l_lab_ord), m_rec->qual[ml_idx2].labqual[m_rec->qual[ml_idx2].l_lab_ord].f_order_id =
     o.order_id,
     m_rec->qual[ml_idx2].labqual[m_rec->qual[ml_idx2].l_lab_ord].s_order_dt = trim(format(o
       .orig_order_dt_tm,"YYYY-MM-DD HH:mm:ss;;q"),3), m_rec->qual[ml_idx2].labqual[m_rec->qual[
     ml_idx2].l_lab_ord].s_order_mnemonic = trim(o.order_mnemonic,3), m_rec->qual[ml_idx2].labqual[
     m_rec->qual[ml_idx2].l_lab_ord].s_order_detail = replace(replace(replace(trim(o
         .clinical_display_line,3),char(13)," "),char(10)," "),"|","#")
    ELSEIF (o.catalog_type_cd=mf_cs6000_rad_cd)
     m_rec->qual[ml_idx2].l_rad_ord += 1, stat = alterlist(m_rec->qual[ml_idx2].radqual,m_rec->qual[
      ml_idx2].l_rad_ord), m_rec->qual[ml_idx2].radqual[m_rec->qual[ml_idx2].l_rad_ord].f_order_id =
     o.order_id,
     m_rec->qual[ml_idx2].radqual[m_rec->qual[ml_idx2].l_rad_ord].s_order_dt = trim(format(o
       .orig_order_dt_tm,"YYYY-MM-DD HH:mm:ss;;q"),3), m_rec->qual[ml_idx2].radqual[m_rec->qual[
     ml_idx2].l_rad_ord].s_order_mnemonic = trim(o.order_mnemonic,3), m_rec->qual[ml_idx2].radqual[
     m_rec->qual[ml_idx2].l_rad_ord].s_order_detail = replace(replace(replace(trim(o
         .clinical_display_line,3),char(13)," "),char(10)," "),"|","#")
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM problem p,
   nomenclature n
  PLAN (p
   WHERE expand(ml_idx1,1,m_rec->l_cnt,p.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
  ORDER BY p.person_id, p.problem_id
  HEAD p.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,p.person_id,m_rec->qual[ml_idx1].f_person_id)
  HEAD p.problem_id
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_prob_cnt += 1, stat = alterlist(m_rec->qual[ml_idx2].prob_qual,m_rec->
     qual[ml_idx2].l_prob_cnt), m_rec->qual[ml_idx2].prob_qual[m_rec->qual[ml_idx2].l_prob_cnt].
    f_prob_id = p.problem_id,
    m_rec->qual[ml_idx2].prob_qual[m_rec->qual[ml_idx2].l_prob_cnt].s_prob_code = trim(n
     .source_identifier,3), m_rec->qual[ml_idx2].prob_qual[m_rec->qual[ml_idx2].l_prob_cnt].
    s_prob_desc = trim(n.source_string,3), m_rec->qual[ml_idx2].prob_qual[m_rec->qual[ml_idx2].
    l_prob_cnt].s_prob_vocab = trim(uar_get_code_display(n.source_vocabulary_cd),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND o.order_status_cd=mf_cs6004_ordered_cd
    AND o.active_ind=1
    AND o.orig_ord_as_flag IN (1, 2))
  ORDER BY o.person_id, o.order_id
  HEAD o.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,o.person_id,m_rec->qual[ml_idx1].f_person_id)
  HEAD o.order_id
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_pres_ord += 1, stat = alterlist(m_rec->qual[ml_idx2].presqual,m_rec->qual[
     ml_idx2].l_pres_ord), m_rec->qual[ml_idx2].presqual[m_rec->qual[ml_idx2].l_pres_ord].f_order_id
     = o.order_id,
    m_rec->qual[ml_idx2].presqual[m_rec->qual[ml_idx2].l_pres_ord].s_order_dt = trim(format(o
      .orig_order_dt_tm,"YYYY-MM-DD HH:mm:ss;;q"),3), m_rec->qual[ml_idx2].presqual[m_rec->qual[
    ml_idx2].l_pres_ord].s_order_mnemonic = trim(o.order_mnemonic,3), m_rec->qual[ml_idx2].presqual[
    m_rec->qual[ml_idx2].l_pres_ord].s_order_detail = replace(replace(replace(trim(o
        .clinical_display_line,3),char(13)," "),char(10)," "),"|","#")
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   person p
  PLAN (ppr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND ppr.active_ind=1
    AND ppr.person_prsnl_r_cd=mf_cs331_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  ORDER BY ppr.person_id, ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_pcp = trim(p.name_full_formatted,3),ml_idx2 = locateval(ml_idx1,(ml_idx2+
     1),m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   person p,
   prsnl_alias pa
  PLAN (ppr
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND ppr.active_ind=1
    AND ppr.person_prsnl_r_cd=mf_cs331_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.prsnl_alias_type_cd=mf_cs320_docnbr_cd)
  ORDER BY ppr.person_id, ppr.beg_effective_dt_tm DESC
  HEAD ppr.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_pcp_doc_nbr = trim(pa.alias,3),ml_idx2 = locateval(ml_idx1,(ml_idx2+ 1),
     m_rec->l_cnt,ppr.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person_info pi
  PLAN (pi
   WHERE expand(ml_idx1,1,m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND pi.active_ind=1
    AND pi.info_sub_type_cd=mf_cs356_race1_cd)
  ORDER BY pi.person_id
  HEAD pi.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_pat_race = trim(uar_get_code_display(pi.value_cd),3),ml_idx2 = locateval(
     ml_idx1,(ml_idx2+ 1),m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person_info pi
  PLAN (pi
   WHERE expand(ml_idx1,1,m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND pi.active_ind=1
    AND pi.info_sub_type_cd=mf_cs356_ethnicity1_cd)
  ORDER BY pi.person_id
  HEAD pi.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
   WHILE (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_pat_ethnicity = trim(uar_get_code_display(pi.value_cd),3),ml_idx2 =
    locateval(ml_idx1,(ml_idx2+ 1),m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
   ENDWHILE
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_rec->l_cnt),
   bhs_demographics bd
  PLAN (d1)
   JOIN (bd
   WHERE (bd.person_id=m_rec->qual[d1.seq].f_person_id)
    AND bd.description IN ("race 1", "ethnicity 1", "language spoken"))
  DETAIL
   IF (bd.description="race 1")
    IF (size(trim(m_rec->qual[d1.seq].s_pat_race,3))=0)
     m_rec->qual[d1.seq].s_pat_race = trim(uar_get_code_display(bd.code_value),3)
    ENDIF
   ENDIF
   IF (bd.description="ethnicity 1")
    IF (size(trim(m_rec->qual[d1.seq].s_pat_ethnicity,3))=0)
     m_rec->qual[d1.seq].s_pat_ethnicity = trim(uar_get_code_display(bd.code_value),3)
    ENDIF
   ENDIF
   IF (bd.description="language spoken")
    IF (size(trim(m_rec->qual[d1.seq].s_pat_language,3))=0)
     m_rec->qual[d1.seq].s_pat_language = trim(uar_get_code_display(bd.code_value),3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE (e.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND e.active_ind=1
      AND e.loc_nurse_unit_cd=mf_cs220_baysthighstadlt_cd
      AND e.disch_dt_tm IS NOT null
      AND e.disch_dt_tm <= cnvtdatetime(m_rec->qual[ml_idx1].f_appt_dt))
    ORDER BY e.person_id, e.disch_dt_tm DESC
    HEAD e.person_id
     m_rec->qual[ml_idx1].f_prev_visit = cnvtdatetime(e.disch_dt_tm,0), m_rec->qual[ml_idx1].
     s_most_recent_hshc_appt = format(e.disch_dt_tm,"MM/DD/YYYY;;q")
    WITH nocounter
   ;end select
   IF ((m_rec->qual[ml_idx1].f_prev_visit > 0))
    SET m_rec->qual[ml_idx1].l_num_days_from_last_clinic_visit = ceil(datetimediff(cnvtdatetime(m_rec
       ->qual[ml_idx1].f_appt_dt),cnvtdatetime(m_rec->qual[ml_idx1].f_prev_visit)))
   ENDIF
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_plan_reltn epr,
     health_plan hp
    PLAN (e
     WHERE (e.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND e.active_ind=1
      AND e.disch_dt_tm IS NOT null)
     JOIN (epr
     WHERE epr.encntr_id=e.encntr_id
      AND epr.active_ind=1)
     JOIN (hp
     WHERE hp.health_plan_id=epr.health_plan_id)
    ORDER BY e.person_id, e.disch_dt_tm DESC, epr.priority_seq
    HEAD e.person_id
     m_rec->qual[ml_idx1].s_prim_ins = trim(hp.plan_name,3)
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE expand(ml_idx1,1,m_rec->l_cnt,e.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND e.active_ind=1
    AND e.disch_dt_tm > cnvtlookbehind("3,M",cnvtdatetime(sysdate))
    AND e.encntr_class_cd IN (mf_cs321_emergency_cd, mf_cs321_inpatient_cd))
  ORDER BY e.person_id, e.encntr_id
  HEAD e.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,e.person_id,m_rec->qual[ml_idx1].f_person_id)
  HEAD e.encntr_id
   IF (ml_idx2 > 0)
    IF (e.encntr_class_cd=mf_cs321_emergency_cd)
     m_rec->qual[ml_idx2].l_ed_visits_three_months += 1
    ELSEIF (e.encntr_class_cd=mf_cs321_inpatient_cd)
     m_rec->qual[ml_idx2].l_inpt_obs_visit_three_months += 1
    ENDIF
   ENDIF
  FOOT  e.person_id
   IF (ml_idx2 > 0)
    IF ((m_rec->qual[ml_idx2].l_ed_visits_three_months > 0))
     m_rec->qual[ml_idx2].s_ed_visits = "Yes"
    ENDIF
    IF ((m_rec->qual[ml_idx2].l_inpt_obs_visit_three_months > 0))
     m_rec->qual[ml_idx2].s_inp_obs_visits = "Yes"
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SELECT INTO "nl:"
    FROM hm_recommendation hr,
     hm_expect he,
     hm_expect_series hes,
     hm_expect_step hst
    PLAN (hr
     WHERE (hr.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND hr.status_flag != 7
      AND hr.expect_id != 0
      AND ((hr.due_dt_tm < sysdate) OR (hr.due_dt_tm = null)) )
     JOIN (he
     WHERE he.expect_id=hr.expect_id)
     JOIN (hes
     WHERE hes.expect_series_id=he.expect_series_id)
     JOIN (hst
     WHERE hst.expect_id=hr.expect_id
      AND hst.active_ind=1)
    ORDER BY he.expect_name, hr.last_satisfaction_dt_tm DESC
    HEAD he.expect_name
     m_rec->qual[ml_idx1].l_hcnt += 1, stat = alterlist(m_rec->qual[ml_idx1].hqual,m_rec->qual[
      ml_idx1].l_hcnt), m_rec->qual[ml_idx1].hqual[m_rec->qual[ml_idx1].l_hcnt].s_expectation_name =
     trim(he.expect_name,3),
     m_rec->qual[ml_idx1].hqual[m_rec->qual[ml_idx1].l_hcnt].s_due_date = format(hr.due_dt_tm,
      "MM/DD/YYYY;;q"), m_rec->qual[ml_idx1].hqual[m_rec->qual[ml_idx1].l_hcnt].s_last_satisfied =
     format(hr.last_satisfaction_dt_tm,"MM/DD/YYYY;;q")
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  FROM v500_event_set_explode vese,
   clinical_event ce
  PLAN (vese
   WHERE vese.event_set_cd=mf_cs93_immunizations_cd)
   JOIN (ce
   WHERE expand(ml_idx1,1,m_rec->l_cnt,ce.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND ce.event_cd=vese.event_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
    AND ce.event_title_text != "Date\Time Correction"
    AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
   mf_cs8_modified_cd))
  ORDER BY ce.person_id, ce.event_cd, ce.event_end_dt_tm,
   ce.clinical_event_id
  HEAD ce.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,ce.person_id,m_rec->qual[ml_idx1].f_person_id)
  HEAD ce.clinical_event_id
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_icnt += 1, stat = alterlist(m_rec->qual[ml_idx2].iqual,m_rec->qual[ml_idx2
     ].l_icnt), m_rec->qual[ml_idx2].iqual[m_rec->qual[ml_idx2].l_icnt].s_admin_dt = trim(format(ce
      .event_end_dt_tm,"MM/DD/YYYY;;q"),3),
    m_rec->qual[ml_idx2].iqual[m_rec->qual[ml_idx2].l_icnt].s_immun_name = trim(uar_get_code_display(
      ce.event_cd),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     code_value cv
    PLAN (ce
     WHERE (ce.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce.event_title_text != "Date\Time Correction"
      AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd)
      AND ce.performed_dt_tm > cnvtlookbehind("3,M"))
     JOIN (cv
     WHERE cv.code_value=ce.event_cd
      AND cv.code_set=72
      AND cv.active_ind=1
      AND cv.display_key="PHONEMSG")
    ORDER BY ce.person_id, ce.clinical_event_id
    HEAD ce.person_id
     null
    HEAD ce.clinical_event_id
     m_rec->qual[ml_idx1].l_phone_doc_count += 1
    WITH nocounter
   ;end select
   IF ((m_rec->qual[ml_idx1].l_phone_doc_count > 3))
    SET m_rec->qual[ml_idx1].s_phone_doc_found = "Y"
   ELSE
    SET m_rec->qual[ml_idx1].s_phone_doc_found = "N"
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce,
     code_value cv,
     encntr_alias ea
    PLAN (ce
     WHERE (ce.person_id=m_rec->qual[ml_idx1].f_person_id)
      AND ce.valid_until_dt_tm > cnvtdatetime(sysdate)
      AND ce.event_title_text != "Date\Time Correction"
      AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
     mf_cs8_modified_cd)
      AND ce.performed_dt_tm > cnvtlookbehind("3,M"))
     JOIN (cv
     WHERE cv.code_value=ce.event_cd
      AND cv.code_set=72
      AND cv.active_ind=1
      AND cv.display_key IN ("EDNOTES", "NONBHEMERGENCYROOMRECORDS", "INPATIENTDISCHARGESUMMARYNONBH",
     "INPATIENTHP", "DISCHARGETRANSFERNOTEHOSPITAL",
     "EMERGENCYMEDICINENOTE"))
     JOIN (ea
     WHERE ea.encntr_id=ce.encntr_id
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
    ORDER BY ce.person_id, ce.clinical_event_id
    HEAD ce.person_id
     null
    HEAD ce.clinical_event_id
     m_rec->qual[ml_idx1].l_ncnt += 1, stat = alterlist(m_rec->qual[ml_idx1].nqual,m_rec->qual[
      ml_idx1].l_ncnt), m_rec->qual[ml_idx1].nqual[m_rec->qual[ml_idx1].l_ncnt].f_clin_event_id = ce
     .clinical_event_id,
     m_rec->qual[ml_idx1].nqual[m_rec->qual[ml_idx1].l_ncnt].s_note_type = trim(cv.display,3), m_rec
     ->qual[ml_idx1].nqual[m_rec->qual[ml_idx1].l_ncnt].s_fin = trim(ea.alias,3), m_rec->qual[ml_idx1
     ].nqual[m_rec->qual[ml_idx1].l_ncnt].s_create_dt = format(ce.performed_dt_tm,"MM/DD/YYYY;;q")
    WITH nocounter
   ;end select
 ENDFOR
 SET frec->file_name = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/out/baystate_bh_amb_appt_patient_",trim(format(cnvtdatetime(mf_date),
    "MMDDYYYY;;q"),3),".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("cerner_person_id|","ptnt_corp_mrn|","ptnt_name|","ptnt_dob|",
  "ptnt_primary_ins|",
  "ptnt_race|","ptnt_ethnicity|","ptnt_lang_spkn|","ptnt_pcp|","appt_schd_prov|",
  "appt_visit_type|","appt_reason_for_visit|","most_rcnt_hshc_appt|",
  "num_days_appt_last_clinic_visit|","num_ed_visit_3_mon|",
  "num_hosp_visit_3_mon|","count_ptnt_phone_msgs|","ED_visit_3_month_flag|",
  "Hosp_visit_3_month_flag|","Ptnt_with_3_Phone_msgs_flag|",
  "PT_APPOINT_DT|","TEAM_NAME|","PCP_DR_NUM",char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
  SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
    m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].s_pat_full_name,3),
   "|",trim(m_rec->qual[ml_idx1].s_pat_dob,3),"|",trim(m_rec->qual[ml_idx1].s_prim_ins,3),"|",
   trim(m_rec->qual[ml_idx1].s_pat_race,3),"|",trim(m_rec->qual[ml_idx1].s_pat_ethnicity,3),"|",trim(
    m_rec->qual[ml_idx1].s_pat_language,3),
   "|",trim(m_rec->qual[ml_idx1].s_pcp,3),"|",trim(m_rec->qual[ml_idx1].s_appt_provider,3),"|",
   trim(m_rec->qual[ml_idx1].s_appt_type,3),"|",trim(m_rec->qual[ml_idx1].s_appt_reason,3),"|",trim(
    m_rec->qual[ml_idx1].s_most_recent_hshc_appt,3),
   "|",trim(cnvtstring(m_rec->qual[ml_idx1].l_num_days_from_last_clinic_visit,20,0),3),"|",trim(
    cnvtstring(m_rec->qual[ml_idx1].l_ed_visits_three_months,20,0),3),"|",
   trim(cnvtstring(m_rec->qual[ml_idx1].l_inpt_obs_visit_three_months,20,0),3),"|",trim(cnvtstring(
     m_rec->qual[ml_idx1].l_phone_doc_count,20,0),3),"|",trim(m_rec->qual[ml_idx1].s_ed_visits,3),
   "|",trim(m_rec->qual[ml_idx1].s_inp_obs_visits,3),"|",trim(m_rec->qual[ml_idx1].s_phone_doc_found,
    3),"|",
   trim(format(cnvtdatetime(m_rec->qual[ml_idx1].f_appt_dt),"yyyy-mm-dd HH:mm:ss;;q"),3),"|",trim(
    m_rec->qual[ml_idx1].s_appt_team,3),"|",trim(m_rec->qual[ml_idx1].s_pcp_doc_nbr,3),
   char(13),char(10))
  SET stat = cclio("WRITE",frec)
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 SET frec->file_name = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/out/baystate_bh_amb_appt_outstanding_orders_",trim(format(cnvtdatetime(mf_date
     ),"MMDDYYYY;;q"),3),".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("cerner_person_id|","ptnt_corp_mrn|","outstanding_order_name|",
  "outstanding_order_date_time|","oustanding_order_detail|",
  "outstanding_Order_Type",char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_lab_ord)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].labqual[ml_idx2].s_order_mnemonic,
      3),
     "|",trim(m_rec->qual[ml_idx1].labqual[ml_idx2].s_order_dt,3),"|",trim(m_rec->qual[ml_idx1].
      labqual[ml_idx2].s_order_detail,3),"|",
     "LAB",char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_rad_ord)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].radqual[ml_idx2].s_order_mnemonic,
      3),
     "|",trim(m_rec->qual[ml_idx1].radqual[ml_idx2].s_order_dt,3),"|",trim(m_rec->qual[ml_idx1].
      radqual[ml_idx2].s_order_detail,3),"|",
     "RAD",char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_pres_ord)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].presqual[ml_idx2].s_order_mnemonic,
      3),
     "|",trim(m_rec->qual[ml_idx1].presqual[ml_idx2].s_order_dt,3),"|",trim(m_rec->qual[ml_idx1].
      presqual[ml_idx2].s_order_detail,3),"|",
     "MED",char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 SET frec->file_name = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/out/baystate_bh_amb_appt_ptnt_hlth_maint_",trim(format(cnvtdatetime(mf_date),
    "MMDDYYYY;;q"),3),".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("cerner_person_id|","ptnt_corp_mrn|","Expectation_nm|","Last_Satisfy_Dt|",
  "Next_due_Dt",
  char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_hcnt)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].hqual[ml_idx2].s_expectation_name,
      3),
     "|",trim(m_rec->qual[ml_idx1].hqual[ml_idx2].s_last_satisfied,3),"|",trim(m_rec->qual[ml_idx1].
      hqual[ml_idx2].s_due_date,3),char(13),
     char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 SET frec->file_name = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/out/baystate_bh_amb_appt_ptnt_problems_",trim(format(cnvtdatetime(mf_date),
    "MMDDYYYY;;q"),3),".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("cerner_person_id|","ptnt_corp_mrn|","ptnt_problem_name|","prblm_code|",
  "problem_vocab",
  char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_prob_cnt)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].prob_qual[ml_idx2].s_prob_desc,3),
     "|",trim(m_rec->qual[ml_idx1].prob_qual[ml_idx2].s_prob_code,3),"|",trim(m_rec->qual[ml_idx1].
      prob_qual[ml_idx2].s_prob_vocab,3),char(13),
     char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 SET frec->file_name = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/out/baystate_bh_amb_appt_ptnt_immun_sch_",trim(format(cnvtdatetime(mf_date),
    "MMDDYYYY;;q"),3),".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("cerner_person_id|","ptnt_corp_mrn|","Immunization_nm|","Last_Admin_Dt",
  char(13),
  char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_icnt)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].iqual[ml_idx2].s_immun_name,3),
     "|",trim(m_rec->qual[ml_idx1].iqual[ml_idx2].s_admin_dt,3),char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
 SET frec->file_name = concat(trim(logical("bhscust"),3),
  "/analytics/appt_ext/out/baystate_bh_amb_appt_ptnt_notes_",trim(format(cnvtdatetime(mf_date),
    "MMDDYYYY;;q"),3),".dat")
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build("cerner_person_id|","ptnt_corp_mrn|","Note_Type|","Create Date|","FIN",
  char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_ncnt)
    SET frec->file_buf = concat(trim(cnvtstring(m_rec->qual[ml_idx1].f_person_id,20,0),3),"|",trim(
      m_rec->qual[ml_idx1].s_cmrn,3),"|",trim(m_rec->qual[ml_idx1].nqual[ml_idx2].s_note_type,3),
     "|",trim(m_rec->qual[ml_idx1].nqual[ml_idx2].s_create_dt,3),"|",trim(m_rec->qual[ml_idx1].nqual[
      ml_idx2].s_fin,3),char(13),
     char(10))
    SET stat = cclio("WRITE",frec)
   ENDFOR
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
