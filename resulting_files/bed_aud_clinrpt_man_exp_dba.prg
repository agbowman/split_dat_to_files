CREATE PROGRAM bed_aud_clinrpt_man_exp:dba
 SET hi18n = 0
 SET stat = uar_i18nlocalizationinit(hi18n,curprog,"",curcclrev)
 IF ( NOT (validate(patient_nme)))
  DECLARE patient_nme = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.PATIENT_NME","Patient Name"))
 ENDIF
 IF ( NOT (validate(accessn)))
  DECLARE accessn = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.ACCESSN","Accession"))
 ENDIF
 IF ( NOT (validate(cumulatv)))
  DECLARE cumulatv = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.CUMULATV","Cumulative"))
 ENDIF
 IF ( NOT (validate(chart_frmt)))
  DECLARE chart_frmt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.CHART_FRMT","Chart Format"))
 ENDIF
 IF ( NOT (validate(nbr_of_copies)))
  DECLARE nbr_of_copies = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.NBR_OF_COPIES","Number of Copies"))
 ENDIF
 IF ( NOT (validate(output_dvc)))
  DECLARE output_dvc = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.OUTPUT_DVC","Output Device"))
 ENDIF
 IF ( NOT (validate(provdr)))
  DECLARE provdr = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.PROVDR","Provider"))
 ENDIF
 IF ( NOT (validate(provdr_rlshp)))
  DECLARE provdr_rlshp = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.PROVDR_RLSHP","Provider Relationship"))
 ENDIF
 IF ( NOT (validate(updt_dt)))
  DECLARE updt_dt = vc WITH protect, constant(uar_i18ngetmessage(hi18n,
    "BED_AUD_CLINRPT_MAN_EXP.UPDT_DT","Update Date/Time"))
 ENDIF
 IF ( NOT (validate(t_yes)))
  DECLARE t_yes = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_MAN_EXP.T_YES",
    "Yes"))
 ENDIF
 IF ( NOT (validate(t_no)))
  DECLARE t_no = vc WITH protect, constant(uar_i18ngetmessage(hi18n,"BED_AUD_CLINRPT_MAN_EXP.T_NO",
    "No"))
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
  )
 ENDIF
 FREE RECORD expedites
 RECORD expedites(
   1 expedite[*]
     2 patient_name = vc
     2 patient_id = f8
     2 accession = vc
     2 cumulative_ind = i2
     2 chart_format_name = vc
     2 chart_format_id = f8
     2 number_of_copies = i4
     2 output_device = vc
     2 provider_name = vc
     2 provider_relationship = vc
     2 provider_id = f8
     2 provider_role_cd = f8
     2 update_dt_tm = dq8
 )
 DECLARE exp_cnt = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "NL:"
  FROM expedite_manual em,
   chart_format cf,
   person p,
   prsnl pnl
  PLAN (em
   WHERE em.expedite_manual_id > 0
    AND em.chart_format_id > 0)
   JOIN (cf
   WHERE cf.chart_format_id=em.chart_format_id)
   JOIN (p
   WHERE p.person_id=em.person_id)
   JOIN (pnl
   WHERE pnl.person_id=em.provider_id)
  ORDER BY p.name_full_formatted
  DETAIL
   exp_cnt = (exp_cnt+ 1)
   IF (mod(exp_cnt,10)=1)
    stat = alterlist(expedites->expedite,(exp_cnt+ 9))
   ENDIF
   expedites->expedite[exp_cnt].patient_id = em.person_id, expedites->expedite[exp_cnt].
   chart_format_name = cf.chart_format_desc, expedites->expedite[exp_cnt].chart_format_id = em
   .chart_format_id,
   expedites->expedite[exp_cnt].accession = em.accession, expedites->expedite[exp_cnt].cumulative_ind
    = em.chart_content_flag, expedites->expedite[exp_cnt].number_of_copies = em.copies_nbr,
   expedites->expedite[exp_cnt].output_device = em.output_dest_name, expedites->expedite[exp_cnt].
   provider_id = em.provider_id, expedites->expedite[exp_cnt].provider_role_cd = em.provider_role_cd,
   expedites->expedite[exp_cnt].provider_relationship = uar_get_code_display(em.provider_role_cd),
   expedites->expedite[exp_cnt].patient_name = p.name_full_formatted, expedites->expedite[exp_cnt].
   provider_name = pnl.name_full_formatted,
   expedites->expedite[exp_cnt].update_dt_tm = em.updt_dt_tm
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,9)
 SET reply->collist[1].header_text = patient_nme
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = accessn
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = cumulatv
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = chart_frmt
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = nbr_of_copies
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = output_dvc
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = provdr
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = provdr_rlshp
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = updt_dt
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 IF (exp_cnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (m = 1 TO exp_cnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,9)
   IF ((expedites->expedite[m].patient_id > 0))
    SET reply->rowlist[row_nbr].celllist[1].string_value = build2(trim(expedites->expedite[m].
      patient_name),"(",trim(cnvtstringchk(expedites->expedite[m].patient_id)),")")
   ENDIF
   SET reply->rowlist[row_nbr].celllist[2].string_value = cnvtacc(expedites->expedite[m].accession)
   IF ((expedites->expedite[m].cumulative_ind=0))
    SET reply->rowlist[row_nbr].celllist[3].string_value = t_yes
   ELSEIF ((expedites->expedite[m].cumulative_ind=1))
    SET reply->rowlist[row_nbr].celllist[3].string_value = t_no
   ENDIF
   IF ((expedites->expedite[m].chart_format_id > 0))
    SET reply->rowlist[row_nbr].celllist[4].string_value = build2(trim(expedites->expedite[m].
      chart_format_name),"(",trim(cnvtstringchk(expedites->expedite[m].chart_format_id)),")")
   ENDIF
   SET reply->rowlist[row_nbr].celllist[5].string_value = cnvtstringchk(expedites->expedite[m].
    number_of_copies)
   SET reply->rowlist[row_nbr].celllist[6].string_value = expedites->expedite[m].output_device
   IF ((expedites->expedite[m].provider_id > 0))
    SET reply->rowlist[row_nbr].celllist[7].string_value = build2(trim(expedites->expedite[m].
      provider_name),"(",trim(cnvtstringchk(expedites->expedite[m].provider_id)),")")
   ENDIF
   SET reply->rowlist[row_nbr].celllist[8].string_value = expedites->expedite[m].
   provider_relationship
   SET reply->rowlist[row_nbr].celllist[9].string_value = datetimezoneformat(expedites->expedite[m].
    update_dt_tm,curtimezoneapp,"MM/dd/yyyy  hh:mm:ss",curtimezonedef)
 ENDFOR
#exit_script
END GO
