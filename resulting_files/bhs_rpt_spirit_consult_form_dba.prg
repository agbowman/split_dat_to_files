CREATE PROGRAM bhs_rpt_spirit_consult_form:dba
 PROMPT
  "send bad date message" = "MINE",
  "Output to File/Printer/MINE" = "MINE",
  "Begin date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Summary" = 0,
  "Output to Screen" = 0,
  "Send to email" = 1,
  "Enter email address" = "",
  "Enter Password" = "",
  "password" = "Baystate1"
  WITH bad_dates, outdev, s_beg_dt,
  s_end_dt, summary, n_chk_screen,
  n_chk_email, s_email, enterpassord,
  password
 SET out_of_range = 0
 DECLARE no_data = i4 WITH noconstant(0), protect
 IF (( $ENTERPASSORD !=  $PASSWORD))
  SELECT INTO  $BAD_DATES
   FROM dummyt
   HEAD REPORT
    msg1 = "Invalid Password", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $S_END_DT),cnvtdatetime( $S_BEG_DT)) > 35.0)
  SET out_of_range = 1
  SELECT INTO  $BAD_DATES
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Greater than 35 days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $S_END_DT),cnvtdatetime( $S_BEG_DT)) < 0.0)
  SET out_of_range = 1
  SELECT INTO  $BAD_DATES
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative days .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ENDIF
 DECLARE ms_output = vc WITH protect, constant( $OUTDEV)
 DECLARE mn_screen_out = i2 WITH protect, constant( $N_CHK_SCREEN)
 DECLARE mn_email_out = i2 WITH protect, constant( $N_CHK_EMAIL)
 DECLARE ms_email_to = vc WITH protect, constant(trim( $S_EMAIL))
 DECLARE ms_email_file = vc WITH protect, noconstant(concat("bhs_spirt_consult_form",trim(format(
     sysdate,"mmddyy_hhmm;;d")),".xls"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE msnurse_unit = vc WITH protect
 DECLARE mf_bmcinptpsych = f8 WITH protect
 DECLARE mf_baystatehealth = f8 WITH protect
 DECLARE mn_form_cnt = i4 WITH noconstant(0), protect
 DECLARE mn_enct_cnt = i4 WITH noconstant(0), protect
 DECLARE mn_found = i4 WITH noconstant(0), protect
 DECLARE name = vc WITH protect, noconstant("                            ")
 DECLARE mn_pat_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_name_w_id = vc WITH protect
 DECLARE mf_spirit_serv_consult = f8 WITH protect
 DECLARE mf_modified = f8 WITH constant(uar_get_code_by("DESCRIPTION",8,"Modified/Amended/Cor")),
 protect
 DECLARE mf_altered = f8 WITH constant(uar_get_code_by("DESCRIPTION",8,"Modified/Amended/Corrected")),
 protect
 DECLARE mf_auth_ver = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 DECLARE mf_primaryeventid = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID")),
 protect
 DECLARE mf_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_fin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_ed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_day_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_expiredobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")), protect
 DECLARE mf_expiredip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 DECLARE mf_expiredes = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 DECLARE mf_expireddaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE mf_dischobv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV")), protect
 DECLARE mf_dischip = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP")), protect
 DECLARE mf_disches = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHES")), protect
 DECLARE mf_dischdaystay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY")), protect
 DECLARE mf_spirit_serv_followupcomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSERVICESFOLLOWUPCOMMENTS")), protect
 DECLARE mf_add_religiousresources = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ADDITIONALRELIGIOUSRESOURCES")), protect
 DECLARE mf_add_contactrequest = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ADDITIONALCONTACTREQUEST")), protect
 DECLARE mf_fut_pastoralplan = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FUTUREPASTORALPLAN")
  ), protect
 DECLARE mf_spirt_serv_splancomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSERVICESPLANCOMMENTS")), protect
 DECLARE mf_visitsummaryspiritualservices = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "VISITSUMMARYSPIRITUALSERVICES")), protect
 DECLARE mf_sourcesofspiritualsupport = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SOURCESOFSPIRITUALSUPPORT")), protect
 DECLARE mf_spiritualsacramentalresources = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSACRAMENTALRESOURCES")), protect
 DECLARE mf_interventionspiritualservices = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERVENTIONSPIRITUALSERVICES")), protect
 DECLARE mf_spirit_serv_assessmentcomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSERVICESASSESSMENTCOMMENTS")), protect
 DECLARE mf_phonechurchtemplesynagogueother = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PHONEOFCHURCHTEMPLESYNAGOGUEOTHER")), protect
 DECLARE mf_namechurchtemplesynagogueoth = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "NAMEOFCHURCHTEMPLESYNAGOGUEOTH")), protect
 DECLARE mf_spiritualconcerns = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SPIRITUALCONCERNS")
  ), protect
 DECLARE mf_spirit_serv_referralcomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SPIRITUALSERVICESREFERRALCOMMENTS")), protect
 DECLARE mf_chaplainmetwith = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"CHAPLAINMETWITH")),
 protect
 DECLARE mf_reason_spirit_refer_consult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "REASONFORSPIRITUALREFERRALCONSULT")), protect
 DECLARE mf_referralsourcespirit_serv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "REFERRALSOURCESPIRITUALSERVICE")), protect
 DECLARE mf_staffpresentspirit_serv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "STAFFPRESENTSPIRITUALSERVICE")), protect
 DECLARE mf_familyotherspresentspiritserv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "FAMILYOTHERSPRESENTSPIRITUALSERVICE")), protect
 DECLARE mf_religiousaffiliation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSAFFILIATION")), protect
 DECLARE mf_totaltimespirit_serv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "TOTALTIMESPIRITUALSERVICE")), protect
 DECLARE mf_starttimespirit_serv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "STARTTIMESPIRITUALSERVICE")), protect
 RECORD spirit_con_forms(
   1 header_report_name = vc
   1 total_forms = i4
   1 chaplains[*]
     2 name = vc
     2 prsnlid = f8
     2 formcnt = i4
   1 person[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 encounter[*]
       3 f_encntr_id = f8
       3 f_encntr_type_cd = vc
       3 f_location_cd = f8
       3 s_location_cd = vc
       3 s_nurse_unit = vc
       3 s_mrn = vc
       3 s_acct = vc
       3 s_admit_date = vc
       3 d_admit_date = dq8
       3 forms[*]
         4 f_form_id = f8
         4 s_perform_prsnl = vc
         4 s_spirit_serv_followupcomments = vc
         4 s_add_religiousresources = vc
         4 s_add_contactrequest = vc
         4 s_fut_pastoralplan = vc
         4 s_spirt_serv_splancomments = vc
         4 s_visitsummaryspiritualservices = vc
         4 s_sourcesofspiritualsupport = vc
         4 s_spirit_sacra_resources = vc
         4 s_interventionspiritualservices = vc
         4 s_spirit_assessmentcomments = vc
         4 s_phone = vc
         4 s_namefacility = vc
         4 s_spiritualconcerns = vc
         4 s_spirit_serv_referralcomments = vc
         4 s_chaplainmetwith = vc
         4 s_reason_spirit_refer_consult = vc
         4 s_referralsourcespirit_serv = vc
         4 s_staffpresentspirit_serv = vc
         4 n_familyotherspresentspiritserv = vc
         4 s_religiousaffiliation = vc
         4 n_totaltimespirit_serv = vc
         4 s_starttimespirit_serv = vc
         4 s_form_date_time = vc
 )
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.display_key IN ("BMC", "BMCINPTPSYCH")
    AND cv.active_ind=1
    AND cv.cdf_meaning="FACILITY"
    AND cv.begin_effective_dt_tm <= sysdate
    AND cv.end_effective_dt_tm > sysdate
    AND cv.data_status_cd=mf_auth_cd)
  HEAD cv.display_key
   IF (cv.display_key="BMC")
    mf_baystatehealth = cv.code_value
   ELSEIF (cv.display_key="BMCINPTPSYCH")
    mf_bmcinptpsych = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dfr.dcp_forms_ref_id
  FROM dcp_forms_ref dfr
  PLAN (dfr
   WHERE dfr.definition="*Spiritual Service Consult*"
    AND dfr.active_ind=1)
  DETAIL
   mf_spirit_serv_consult = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ms_name_w_id = build2(trim(p.name_full_formatted,3),dfa.person_id)
  FROM dcp_forms_activity dfa,
   encntr_loc_hist elh,
   person p,
   prsnl pn,
   encntr_alias ea1,
   encntr_alias ea2,
   dcp_forms_activity_comp dfac,
   clinical_event ce,
   clinical_event ce1,
   clinical_event ce2,
   encounter e
  PLAN (dfa
   WHERE mf_spirit_serv_consult=dfa.dcp_forms_ref_id
    AND dfa.version_dt_tm BETWEEN cnvtdatetime( $S_BEG_DT) AND cnvtdatetime( $S_END_DT)
    AND dfa.form_status_cd IN (mf_modified, mf_altered, mf_auth_ver))
   JOIN (e
   WHERE dfa.encntr_id=e.encntr_id
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_obs_cd, mf_ed_cd, mf_day_cd, mf_expiredobv,
   mf_expiredip, mf_expiredes, mf_expireddaystay, mf_dischobv, mf_dischip,
   mf_disches, mf_dischdaystay)
    AND e.active_ind=1)
   JOIN (p
   WHERE e.person_id=p.person_id
    AND p.active_ind=1)
   JOIN (elh
   WHERE e.encntr_id=elh.encntr_id
    AND dfa.form_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm
    AND elh.loc_facility_cd IN (mf_baystatehealth, mf_bmcinptpsych))
   JOIN (ea1
   WHERE elh.encntr_id=ea1.encntr_id
    AND ea1.encntr_alias_type_cd=mf_mrn
    AND ea1.active_ind=1)
   JOIN (ea2
   WHERE ea1.encntr_id=ea2.encntr_id
    AND ea2.encntr_alias_type_cd=mf_fin
    AND ea2.active_ind=1)
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.component_cd=mf_primaryeventid
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id)
   JOIN (pn
   WHERE pn.person_id=ce.performed_prsnl_id
    AND pn.active_ind=1)
   JOIN (ce1
   WHERE ce.event_id=ce1.parent_event_id
    AND ce1.valid_until_dt_tm > sysdate)
   JOIN (ce2
   WHERE ce1.event_id=ce2.parent_event_id
    AND ce2.valid_until_dt_tm > sysdate
    AND ce2.view_level=1
    AND ce2.event_cd IN (mf_spirit_serv_followupcomments, mf_add_religiousresources,
   mf_add_contactrequest, mf_fut_pastoralplan, mf_spirt_serv_splancomments,
   mf_visitsummaryspiritualservices, mf_sourcesofspiritualsupport, mf_spiritualsacramentalresources,
   mf_interventionspiritualservices, mf_spirit_serv_assessmentcomments,
   mf_phonechurchtemplesynagogueother, mf_namechurchtemplesynagogueoth, mf_spiritualconcerns,
   mf_spirit_serv_referralcomments, mf_chaplainmetwith,
   mf_reason_spirit_refer_consult, mf_referralsourcespirit_serv, mf_staffpresentspirit_serv,
   mf_familyotherspresentspiritserv, mf_religiousaffiliation,
   mf_totaltimespirit_serv, mf_starttimespirit_serv))
  ORDER BY ms_name_w_id, dfa.encntr_id, dfa.dcp_forms_activity_id
  HEAD REPORT
   mn_pat_cnt = 0, stat = alterlist(spirit_con_forms->person,10)
  HEAD ms_name_w_id
   mn_pat_cnt += 1
   IF (mod(mn_pat_cnt,10)=1)
    stat = alterlist(spirit_con_forms->person,(mn_pat_cnt+ 9))
   ENDIF
   spirit_con_forms->person[mn_pat_cnt].s_pat_name = p.name_full_formatted, mn_enct_cnt = 0, stat =
   alterlist(spirit_con_forms->person[mn_pat_cnt].encounter,10)
  HEAD dfa.encntr_id
   mn_enct_cnt += 1
   IF (mod(mn_enct_cnt,10)=1)
    stat = alterlist(spirit_con_forms->person[mn_pat_cnt].encounter,(mn_enct_cnt+ 9))
   ENDIF
   spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].f_encntr_id = dfa.encntr_id,
   spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].f_encntr_type_cd =
   uar_get_code_display(e.encntr_type_cd), spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt
   ].s_mrn = ea1.alias,
   spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].s_acct = ea2.alias, spirit_con_forms->
   person[mn_pat_cnt].encounter[mn_enct_cnt].s_nurse_unit = uar_get_code_display(elh
    .loc_nurse_unit_cd), spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].s_admit_date =
   format(e.reg_dt_tm,"@SHORTDATETIME"),
   mn_form_cnt = 0, stat = alterlist(spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].
    forms,10)
  HEAD dfa.dcp_forms_activity_id
   mn_form_cnt += 1
   IF (mod(mn_form_cnt,10)=1)
    stat = alterlist(spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms,(mn_form_cnt+
     9))
   ENDIF
   spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].f_form_id = dfa
   .dcp_forms_activity_id, spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[
   mn_form_cnt].s_perform_prsnl = pn.name_full_formatted, spirit_con_forms->person[mn_pat_cnt].
   encounter[mn_enct_cnt].forms[mn_form_cnt].s_religiousaffiliation = ce.result_val,
   spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].s_form_date_time =
   format(ce.event_end_dt_tm,"@SHORTDATETIME")
   IF (size(spirit_con_forms->chaplains,5)=0)
    stat = alterlist(spirit_con_forms->chaplains,1), spirit_con_forms->chaplains[1].prsnlid = pn
    .person_id, spirit_con_forms->chaplains[1].name = trim(pn.name_full_formatted,3),
    spirit_con_forms->chaplains[1].formcnt = 1
   ELSEIF (size(spirit_con_forms->chaplains,5) > 0)
    FOR (x = 1 TO size(spirit_con_forms->chaplains,5))
      IF ((spirit_con_forms->chaplains[x].prsnlid=pn.person_id))
       spirit_con_forms->chaplains[x].formcnt += 1, mn_found = 1
      ENDIF
    ENDFOR
    IF (mn_found=0)
     stat = alterlist(spirit_con_forms->chaplains,(size(spirit_con_forms->chaplains,5)+ 1)),
     spirit_con_forms->chaplains[size(spirit_con_forms->chaplains,5)].prsnlid = pn.person_id,
     spirit_con_forms->chaplains[size(spirit_con_forms->chaplains,5)].name = trim(pn
      .name_full_formatted,3),
     spirit_con_forms->chaplains[size(spirit_con_forms->chaplains,5)].formcnt = 1
    ELSE
     mn_found = 0
    ENDIF
   ENDIF
  DETAIL
   IF (ce2.event_cd=mf_spirit_serv_followupcomments)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_spirit_serv_followupcomments = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_add_religiousresources)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_add_religiousresources = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_add_contactrequest)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_add_contactrequest = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_fut_pastoralplan)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].s_fut_pastoralplan
     = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_spirt_serv_splancomments)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_spirt_serv_splancomments = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_visitsummaryspiritualservices)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_visitsummaryspiritualservices = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_sourcesofspiritualsupport)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_sourcesofspiritualsupport = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_spiritualsacramentalresources)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_spirit_sacra_resources = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_interventionspiritualservices)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_interventionspiritualservices = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_spirit_serv_assessmentcomments)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_spirit_assessmentcomments = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_phonechurchtemplesynagogueother)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].s_phone = replace(
     replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_namechurchtemplesynagogueoth)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].s_namefacility =
    replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_spiritualconcerns)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_spiritualconcerns = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_spirit_serv_referralcomments)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_spirit_serv_referralcomments = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_chaplainmetwith)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].s_chaplainmetwith
     = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_reason_spirit_refer_consult)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_reason_spirit_refer_consult = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_referralsourcespirit_serv)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_referralsourcespirit_serv = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_staffpresentspirit_serv)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_staffpresentspirit_serv = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_familyotherspresentspiritserv)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    n_familyotherspresentspiritserv = ce2.result_val
   ELSEIF (ce2.event_cd=mf_religiousaffiliation)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_religiousaffiliation = replace(replace(ce2.result_val,char(10)," ",0),char(13)," ")
   ELSEIF (ce2.event_cd=mf_totaltimespirit_serv)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    n_totaltimespirit_serv = ce2.result_val
   ELSEIF (ce2.event_cd=mf_starttimespirit_serv)
    spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms[mn_form_cnt].
    s_starttimespirit_serv = format(cnvtdatetime(cnvtdate2(substring(3,8,ce2.result_val),"yyyymmdd"),
      cnvttime2(substring(11,6,ce2.result_val),"HHMMSS")),"mm/dd/yy hh:mm;;d")
   ENDIF
  FOOT  dfa.dcp_forms_activity_id
   null
  FOOT  dfa.encntr_id
   stat = alterlist(spirit_con_forms->person[mn_pat_cnt].encounter[mn_enct_cnt].forms,mn_form_cnt),
   spirit_con_forms->total_forms += mn_form_cnt, mn_form_cnt = 0
  FOOT  ms_name_w_id
   stat = alterlist(spirit_con_forms->person[mn_pat_cnt].encounter,mn_enct_cnt), mn_enct_cnt = 0
  FOOT REPORT
   stat = alterlist(spirit_con_forms->person,mn_pat_cnt), mn_pat_cnt = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET no_data = 1
  GO TO exit_prg
 ENDIF
 CALL echorecord(spirit_con_forms)
 IF (mn_screen_out=1)
  IF (( $SUMMARY=0))
   SELECT INTO  $BAD_DATES
    patient_name = trim(substring(1,400,spirit_con_forms->person[d1.seq].s_pat_name)), mrn =
    substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_mrn), acct# = substring(1,
     400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_acct),
    nurse_unit = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_nurse_unit),
    admit_date = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_admit_date),
    visiting_chaplain = substring(1,100,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3
     .seq].s_perform_prsnl),
    form_sign_date_time = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3
     .seq].s_form_date_time), date_time_of_visit = substring(1,400,spirit_con_forms->person[d1.seq].
     encounter[d2.seq].forms[d3.seq].s_starttimespirit_serv), duration_of_visit = substring(1,400,
     spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].n_totaltimespirit_serv),
    religion = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_religiousaffiliation), number_family_present = substring(1,400,spirit_con_forms->person[d1.seq
     ].encounter[d2.seq].forms[d3.seq].n_familyotherspresentspiritserv), number_staff_present =
    substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_staffpresentspirit_serv),
    referral_source = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq
     ].s_referralsourcespirit_serv), reason_for_referral = substring(1,400,spirit_con_forms->person[
     d1.seq].encounter[d2.seq].forms[d3.seq].s_reason_spirit_refer_consult), chaplain_met_with =
    substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_chaplainmetwith),
    referral_comments = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3
     .seq].s_spirit_serv_referralcomments), sources_of_support = substring(1,400,spirit_con_forms->
     person[d1.seq].encounter[d2.seq].forms[d3.seq].s_sourcesofspiritualsupport), spiritual_concerns
     = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_spiritualconcerns),
    name_of_church = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq]
     .s_namefacility), church_phone_# = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2
     .seq].forms[d3.seq].s_phone), assessment_comments = replace(replace(substring(1,400,
       spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].s_spirit_assessmentcomments),
      char(10)," ",0),char(13)," "),
    interventions = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_interventionspiritualservices), resources = substring(1,400,spirit_con_forms->person[d1.seq].
     encounter[d2.seq].forms[d3.seq].s_spirit_sacra_resources), visit_summary = substring(1,400,
     spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].s_visitsummaryspiritualservices
     ),
    plan_comments = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_spirt_serv_splancomments), follow_up_plan = substring(1,400,spirit_con_forms->person[d1.seq].
     encounter[d2.seq].forms[d3.seq].s_fut_pastoralplan), additional_requests = substring(1,400,
     spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].s_add_contactrequest),
    add_resources = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_add_religiousresources), follow_up_comments = substring(1,400,spirit_con_forms->person[d1.seq]
     .encounter[d2.seq].forms[d3.seq].s_spirit_serv_followupcomments), total_forms = spirit_con_forms
    ->total_forms
    FROM (dummyt d1  WITH seq = value(size(spirit_con_forms->person,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(spirit_con_forms->person[d1.seq].encounter,5)))
     JOIN (d2
     WHERE maxrec(d3,size(spirit_con_forms->person[d1.seq].encounter[d2.seq].forms,5)))
     JOIN (d3)
    WITH nocounter, separator = " ", format
   ;end select
  ELSE
   SELECT INTO  $BAD_DATES
    name = substring(1,50,spirit_con_forms->chaplains[d1.seq].name), form_count = spirit_con_forms->
    chaplains[d1.seq].formcnt"########;R"
    FROM (dummyt d1  WITH seq = size(spirit_con_forms->chaplains,5))
    PLAN (d1)
    WITH nocounter, separator = " ", format
   ;end select
   SELECT INTO  $BAD_DATES
    name = substring(1,50,"Total Forms:   "), form_count = spirit_con_forms->total_forms
    "##########;R"
    WITH nocounter, noheading, separator = " ",
     format, append
   ;end select
  ENDIF
 ENDIF
 IF (mn_email_out=1)
  IF (( $SUMMARY=0))
   SELECT INTO value(ms_email_file)
    patient_name = trim(substring(1,400,spirit_con_forms->person[d1.seq].s_pat_name),3), mrn =
    substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_mrn), acct# = substring(1,
     400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_acct),
    nurse_unit = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_nurse_unit),
    admit_date = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].s_admit_date),
    visiting_chaplain = substring(1,100,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3
     .seq].s_perform_prsnl),
    form_sign_date_time = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3
     .seq].s_form_date_time), date_time_of_visit = substring(1,400,spirit_con_forms->person[d1.seq].
     encounter[d2.seq].forms[d3.seq].s_starttimespirit_serv), duration_of_visit = substring(1,400,
     spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].n_totaltimespirit_serv),
    religion = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_religiousaffiliation), number_family_present = substring(1,400,spirit_con_forms->person[d1.seq
     ].encounter[d2.seq].forms[d3.seq].n_familyotherspresentspiritserv), number_staff_present =
    substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_staffpresentspirit_serv),
    referral_source = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq
     ].s_referralsourcespirit_serv), reason_for_referral = substring(1,400,spirit_con_forms->person[
     d1.seq].encounter[d2.seq].forms[d3.seq].s_reason_spirit_refer_consult), chaplain_met_with =
    substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_chaplainmetwith),
    referral_comments = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3
     .seq].s_spirit_serv_referralcomments), sources_of_support = substring(1,400,spirit_con_forms->
     person[d1.seq].encounter[d2.seq].forms[d3.seq].s_sourcesofspiritualsupport), spiritual_concerns
     = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_spiritualconcerns),
    name_of_church = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq]
     .s_namefacility), church_phone_# = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2
     .seq].forms[d3.seq].s_phone), assessment_comments = replace(substring(1,400,spirit_con_forms->
      person[d1.seq].encounter[d2.seq].forms[d3.seq].s_spirit_assessmentcomments),char(10)," ",0),
    interventions = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_interventionspiritualservices), resources = substring(1,400,spirit_con_forms->person[d1.seq].
     encounter[d2.seq].forms[d3.seq].s_spirit_sacra_resources), visit_summary = substring(1,400,
     spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].s_visitsummaryspiritualservices
     ),
    plan_comments = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_spirt_serv_splancomments), follow_up_plan = substring(1,400,spirit_con_forms->person[d1.seq].
     encounter[d2.seq].forms[d3.seq].s_fut_pastoralplan), additional_requests = substring(1,400,
     spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].s_add_contactrequest),
    add_resources = substring(1,400,spirit_con_forms->person[d1.seq].encounter[d2.seq].forms[d3.seq].
     s_add_religiousresources), follow_up_comments = substring(1,400,spirit_con_forms->person[d1.seq]
     .encounter[d2.seq].forms[d3.seq].s_spirit_serv_followupcomments)
    FROM (dummyt d1  WITH seq = value(size(spirit_con_forms->person,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(spirit_con_forms->person[d1.seq].encounter,5)))
     JOIN (d2
     WHERE maxrec(d3,size(spirit_con_forms->person[d1.seq].encounter[d2.seq].forms,5)))
     JOIN (d3)
    WITH nocounter, separator = "	", format
   ;end select
  ELSE
   SET ms_email_file = concat("chaplain_total_consult_form",trim(format(sysdate,"mmddyy_hhmm;;d")),
    ".csv")
   SELECT INTO value(ms_email_file)
    chaplain_name = substring(1,70,spirit_con_forms->chaplains[d1.seq].name), form_count =
    spirit_con_forms->chaplains[d1.seq].formcnt
    FROM (dummyt d1  WITH seq = size(spirit_con_forms->chaplains,5))
    PLAN (d1)
    WITH nocounter, format, append,
     pcformat('"',",")
   ;end select
   SELECT INTO value(ms_email_file)
    name = substring(1,70,"         Total Forms:      "), form_count = spirit_con_forms->total_forms
    WITH nocounter, noheading, format,
     append, pcformat('"',",")
   ;end select
  ENDIF
  CALL echo("sending email")
  EXECUTE bhs_sys_stand_subroutine
  CALL emailfile(ms_email_file,ms_email_file,ms_email_to,concat("Spiritual Consult Form - ",trim(
     format(sysdate,"mm-dd-yy hh:mm;;d"))),1)
  IF (mn_screen_out=0)
   SELECT INTO  $BAD_DATES
    HEAD REPORT
     col 0, "Emailed file ", ms_email_file,
     " to ", ms_email_to
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_prg
 IF (no_data=1)
  SELECT INTO  $BAD_DATES
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", y_pos = 18,
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))),
    "No data qualified of for date range"
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
 CALL echorecord(spirit_con_forms)
END GO
