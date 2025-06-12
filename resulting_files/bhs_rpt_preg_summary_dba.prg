CREATE PROGRAM bhs_rpt_preg_summary:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 74922548
  SET request->person[1].person_id = 18756785
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 f_person_id = f8
   1 s_pat_name = vc
   1 s_pat_age = vc
   1 s_onset_dt_tm = vc
   1 s_gravida = vc
   1 s_parity = vc
   1 s_full_term = vc
   1 s_preterm = vc
   1 s_abortions = vc
   1 s_living = vc
   1 notes[*]
     2 s_type = vc
     2 s_subject = vc
     2 s_user = vc
     2 s_dt_tm = vc
   1 vis[*]
     2 s_name = vc
     2 s_value = vc
     2 s_user = vc
     2 s_dt_tm = vc
   1 soc[*]
     2 s_name = vc
     2 s_value = vc
     2 s_user = vc
     2 s_dt_tm = vc
   1 lab[*]
     2 s_name = vc
     2 s_result = vc
     2 s_dt_tm = vc
   1 edu[*]
     2 s_name = vc
     2 s_value = vc
     2 s_user = vc
     2 s_dt_tm = vc
 ) WITH protect
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_lab_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"LABORATORY"))
 DECLARE mf_date_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"DATE"))
 DECLARE mf_gravida_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GRAVIDA"))
 DECLARE mf_parity_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PARITY"))
 DECLARE mf_preterm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PREMATUREBIRTHS")
  )
 DECLARE mf_abortion_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ABORTION"))
 DECLARE mf_living_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LIVINGCHILDREN"))
 DECLARE mf_note1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GYNECOLOGYNOTEOFFICE"))
 DECLARE mf_note2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "EMERGENCYMEDICINENOTE"))
 DECLARE mf_note3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"OBSTETRICSNOTE"))
 DECLARE mf_note4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MATERNALFETALMEDICINENOTEOFFICE"))
 DECLARE mf_note5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEHOSPITAL"))
 DECLARE mf_note6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GYNECOLOGYONCOLOGYNOTEOFFICE"))
 DECLARE mf_note7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUTRITIONDIETARYNOTE"))
 DECLARE mf_note8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUTRITIONDIETARYOFFICENOTE"))
 DECLARE mf_note9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUTRITIONSERVICEOBSPROGRESSNOTE"))
 DECLARE mf_note10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "GENETICSNOTEOFFICE"))
 DECLARE mf_note11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REPRODUCTIVEMEDICINENOTEOFFICE"))
 DECLARE mf_note12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"OBSTETRICFORMS"))
 DECLARE mf_vis_assess1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYA"))
 DECLARE mf_vis_assess2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYA"))
 DECLARE mf_vis_assess3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYA"))
 DECLARE mf_vis_assess4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYAVIA"))
 DECLARE mf_vis_assess5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYA"))
 DECLARE mf_vis_assess6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "NUMBEROFFETUSES"))
 DECLARE mf_vis_assess7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYB"))
 DECLARE mf_vis_assess8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYB"))
 DECLARE mf_vis_assess9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYB"))
 DECLARE mf_vis_assess10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYBVIA"))
 DECLARE mf_vis_assess11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYB"))
 DECLARE mf_vis_assess12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYC"))
 DECLARE mf_vis_assess13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYC"))
 DECLARE mf_vis_assess14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYC"))
 DECLARE mf_vis_assess15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYCVIA"))
 DECLARE mf_vis_assess16_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYC"))
 DECLARE mf_vis_assess17_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYD"))
 DECLARE mf_vis_assess18_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYD"))
 DECLARE mf_vis_assess19_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYD"))
 DECLARE mf_vis_assess20_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYDVIA"))
 DECLARE mf_vis_assess21_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYD"))
 DECLARE mf_vis_assess22_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYE"))
 DECLARE mf_vis_assess23_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYE"))
 DECLARE mf_vis_assess24_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYE"))
 DECLARE mf_vis_assess25_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYEVIA"))
 DECLARE mf_vis_assess26_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYE"))
 DECLARE mf_vis_assess27_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYF"))
 DECLARE mf_vis_assess28_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYF"))
 DECLARE mf_vis_assess29_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYF"))
 DECLARE mf_vis_assess30_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYFVIA"))
 DECLARE mf_vis_assess31_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYF"))
 DECLARE mf_vis_assess32_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYG"))
 DECLARE mf_vis_assess33_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYG"))
 DECLARE mf_vis_assess34_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYG"))
 DECLARE mf_vis_assess35_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYGVIA"))
 DECLARE mf_vis_assess36_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYG"))
 DECLARE mf_vis_assess37_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALPRESENTATIONBABYH"))
 DECLARE mf_vis_assess38_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYH"))
 DECLARE mf_vis_assess39_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTSOUNDSBABYH"))
 DECLARE mf_vis_assess40_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALHEARTRATEBABYHVIA"))
 DECLARE mf_vis_assess41_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "FETALWEIGHTBABYH"))
 DECLARE mf_drug1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DRUGUSE"))
 DECLARE mf_drug2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TYPEOFDRUG"))
 DECLARE mf_drug3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DRUGROUTE"))
 DECLARE mf_drug4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DRUGAMTDAYPREPREGNANCY"))
 DECLARE mf_drug5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DRUGAMTDAYPREGNANCY"))
 DECLARE mf_drug6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DRUGYEARSOFUSE"))
 DECLARE mf_drug7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DRUGLASTUSE"))
 DECLARE mf_alc1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALCOHOLUSE"))
 DECLARE mf_alc2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALCOHOLTYPE"))
 DECLARE mf_alc3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ALCOHOLAMTDAYPREPREGNANCY"))
 DECLARE mf_alc4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ALCOHOLAMTDAYPREGNANCY"))
 DECLARE mf_alc5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALCOHOLYEARSOFUSE"))
 DECLARE mf_alc6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"ALCOHOLLASTUSE"))
 DECLARE mf_tob1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TOBACCOUSE"))
 DECLARE mf_tob2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TYPEOFTOBACCO"))
 DECLARE mf_tob3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TOBACCOAMTDAYPREPREGNANCY"))
 DECLARE mf_tob4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TOBACCOAMTDAYPREGNANCY"))
 DECLARE mf_tob5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TOBACCOLASTUSE"))
 DECLARE mf_tob6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"TOBACCOYEARSOFUSE"))
 DECLARE mf_edu1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTED1STTRIMESTERTOPICSTAUGHT"))
 DECLARE mf_edu2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTED1STTRIMESTERREINSTRUCTION"))
 DECLARE mf_edu3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTED2NDTRIMESTERTOPICSTAUGHT"))
 DECLARE mf_edu4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTED2NDTRIMESTERREINSTRUCTION"))
 DECLARE mf_edu5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTED3RDTRIMESTERTOPICSTAUGHT"))
 DECLARE mf_edu6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTED3RDTRIMESTERREINSTRUCTION"))
 DECLARE mf_edu7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTEDPLANSEDUCATIONREQUESTS"))
 DECLARE mf_edu8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTEDPLANSEDUCATIONCOMMENTS"))
 DECLARE mf_edu9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TUBALSTERILIZATIONCONSENTSIGNED"))
 DECLARE mf_edu10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HISTORYANDPHYSICALSENTTOHOSPITAL"))
 DECLARE ms_displays = vc WITH protect, noconstant("")
 DECLARE ms_reol = vc WITH protect, constant(" \par ")
 DECLARE ms_pard = vc WITH protect, constant(" \pard ")
 DECLARE ms_rtab = vc WITH protect, constant(" \tab ")
 DECLARE ms_wr = vc WITH protect, constant(" \f0 \fs14 \b0 \cb2 ")
 DECLARE ms_line = vc WITH protect, constant(fillstring(100,"_"))
 DECLARE ms_wb = vc WITH protect, constant(" \b \cb2 ")
 DECLARE ms_wbf36 = vc WITH protect, constant(" \plain \f0 \fs36 \b \cb2 ")
 DECLARE ms_wbf24 = vc WITH protect, constant(" \plain \f0 \fs24 \b \cb2 ")
 DECLARE ms_uf = vc WITH protect, constant(" }")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person[1].person_id)
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate)
  HEAD p.person_id
   m_rec->f_person_id = p.person_id, m_rec->s_pat_name = trim(p.name_full_formatted), m_rec->
   s_pat_age = trim(cnvtage(p.birth_dt_tm),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pregnancy_instance pi,
   problem pr
  PLAN (pi
   WHERE (pi.person_id=m_rec->f_person_id)
    AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
    AND pi.end_effective_dt_tm > cnvtlookbehind("1,H",sysdate))
   JOIN (pr
   WHERE pr.problem_id=pi.problem_id
    AND pr.active_ind=1)
  ORDER BY pi.person_id, pi.pregnancy_id DESC
  HEAD pi.person_id
   m_rec->s_onset_dt_tm = trim(format(pr.onset_dt_tm,"dd-mmm-yyyy hh:mm;;d"))
  WITH format(date,"mm/dd/yy;;d")
 ;end select
 SELECT INTO "nl:"
  ps_event_disp = trim(uar_get_code_display(ce.event_cd)), ps_end_dt_tm = trim(format(ce
    .event_end_dt_tm,"mm/dd/yy hh:mm;;d")), pn_sort =
  IF (ce.event_cd=mf_vis_assess1_cd) 1
  ELSEIF (ce.event_cd=mf_vis_assess2_cd) 2
  ELSEIF (ce.event_cd=mf_vis_assess3_cd) 3
  ELSEIF (ce.event_cd=mf_vis_assess4_cd) 4
  ELSEIF (ce.event_cd=mf_vis_assess5_cd) 5
  ELSEIF (ce.event_cd=mf_vis_assess6_cd) 6
  ELSEIF (ce.event_cd=mf_vis_assess7_cd) 7
  ELSEIF (ce.event_cd=mf_vis_assess8_cd) 8
  ELSEIF (ce.event_cd=mf_vis_assess9_cd) 9
  ELSEIF (ce.event_cd=mf_vis_assess10_cd) 10
  ELSEIF (ce.event_cd=mf_vis_assess11_cd) 11
  ELSEIF (ce.event_cd=mf_vis_assess12_cd) 12
  ELSEIF (ce.event_cd=mf_vis_assess13_cd) 13
  ELSEIF (ce.event_cd=mf_vis_assess14_cd) 14
  ELSEIF (ce.event_cd=mf_vis_assess15_cd) 15
  ELSEIF (ce.event_cd=mf_vis_assess16_cd) 16
  ELSEIF (ce.event_cd=mf_vis_assess17_cd) 17
  ELSEIF (ce.event_cd=mf_vis_assess18_cd) 18
  ELSEIF (ce.event_cd=mf_vis_assess19_cd) 19
  ELSEIF (ce.event_cd=mf_vis_assess20_cd) 20
  ELSEIF (ce.event_cd=mf_vis_assess21_cd) 21
  ELSEIF (ce.event_cd=mf_vis_assess22_cd) 22
  ELSEIF (ce.event_cd=mf_vis_assess23_cd) 23
  ELSEIF (ce.event_cd=mf_vis_assess24_cd) 24
  ELSEIF (ce.event_cd=mf_vis_assess25_cd) 25
  ELSEIF (ce.event_cd=mf_vis_assess26_cd) 26
  ELSEIF (ce.event_cd=mf_vis_assess27_cd) 27
  ELSEIF (ce.event_cd=mf_vis_assess28_cd) 28
  ELSEIF (ce.event_cd=mf_vis_assess29_cd) 29
  ELSEIF (ce.event_cd=mf_vis_assess30_cd) 30
  ELSEIF (ce.event_cd=mf_vis_assess31_cd) 31
  ELSEIF (ce.event_cd=mf_vis_assess32_cd) 32
  ELSEIF (ce.event_cd=mf_vis_assess33_cd) 33
  ELSEIF (ce.event_cd=mf_vis_assess34_cd) 34
  ELSEIF (ce.event_cd=mf_vis_assess35_cd) 35
  ELSEIF (ce.event_cd=mf_vis_assess36_cd) 36
  ELSEIF (ce.event_cd=mf_vis_assess37_cd) 37
  ELSEIF (ce.event_cd=mf_vis_assess38_cd) 38
  ELSEIF (ce.event_cd=mf_vis_assess39_cd) 39
  ELSEIF (ce.event_cd=mf_vis_assess40_cd) 40
  ELSEIF (ce.event_cd=mf_vis_assess41_cd) 41
  ELSEIF (ce.event_cd=mf_drug1_cd) 42
  ELSEIF (ce.event_cd=mf_drug2_cd) 43
  ELSEIF (ce.event_cd=mf_drug3_cd) 44
  ELSEIF (ce.event_cd=mf_drug4_cd) 45
  ELSEIF (ce.event_cd=mf_drug5_cd) 46
  ELSEIF (ce.event_cd=mf_drug6_cd) 47
  ELSEIF (ce.event_cd=mf_drug7_cd) 48
  ELSEIF (ce.event_cd=mf_alc1_cd) 49
  ELSEIF (ce.event_cd=mf_alc2_cd) 50
  ELSEIF (ce.event_cd=mf_alc3_cd) 51
  ELSEIF (ce.event_cd=mf_alc4_cd) 52
  ELSEIF (ce.event_cd=mf_alc5_cd) 53
  ELSEIF (ce.event_cd=mf_alc6_cd) 54
  ELSEIF (ce.event_cd=mf_tob1_cd) 55
  ELSEIF (ce.event_cd=mf_tob2_cd) 56
  ELSEIF (ce.event_cd=mf_tob3_cd) 57
  ELSEIF (ce.event_cd=mf_tob4_cd) 58
  ELSEIF (ce.event_cd=mf_tob5_cd) 59
  ELSEIF (ce.event_cd=mf_tob6_cd) 60
  ELSEIF (ce.event_cd=mf_edu1_cd) 61
  ELSEIF (ce.event_cd=mf_edu2_cd) 62
  ELSEIF (ce.event_cd=mf_edu3_cd) 63
  ELSEIF (ce.event_cd=mf_edu4_cd) 64
  ELSEIF (ce.event_cd=mf_edu5_cd) 65
  ELSEIF (ce.event_cd=mf_edu6_cd) 66
  ELSEIF (ce.event_cd=mf_edu7_cd) 67
  ELSEIF (ce.event_cd=mf_edu8_cd) 68
  ELSEIF (ce.event_cd=mf_edu9_cd) 69
  ELSEIF (ce.event_cd=mf_edu10_cd) 70
  ELSE 99
  ENDIF
  FROM clinical_event ce,
   prsnl pr
  PLAN (ce
   WHERE (ce.person_id=request->person[1].person_id)
    AND ((ce.event_cd IN (mf_gravida_cd, mf_parity_cd, mf_preterm_cd, mf_abortion_cd, mf_living_cd,
   mf_vis_assess1_cd, mf_vis_assess2_cd, mf_vis_assess3_cd, mf_vis_assess4_cd, mf_vis_assess5_cd,
   mf_vis_assess6_cd, mf_vis_assess7_cd, mf_vis_assess8_cd, mf_vis_assess9_cd, mf_vis_assess10_cd,
   mf_vis_assess11_cd, mf_vis_assess12_cd, mf_vis_assess13_cd, mf_vis_assess14_cd, mf_vis_assess15_cd,
   mf_vis_assess16_cd, mf_vis_assess17_cd, mf_vis_assess18_cd, mf_vis_assess19_cd, mf_vis_assess20_cd,
   mf_vis_assess21_cd, mf_vis_assess22_cd, mf_vis_assess23_cd, mf_vis_assess24_cd, mf_vis_assess25_cd,
   mf_vis_assess26_cd, mf_vis_assess27_cd, mf_vis_assess28_cd, mf_vis_assess29_cd, mf_vis_assess30_cd,
   mf_vis_assess31_cd, mf_vis_assess32_cd, mf_vis_assess33_cd, mf_vis_assess34_cd, mf_vis_assess35_cd,
   mf_vis_assess36_cd, mf_vis_assess37_cd, mf_vis_assess38_cd, mf_vis_assess39_cd, mf_vis_assess40_cd,
   mf_vis_assess41_cd, mf_drug1_cd, mf_drug2_cd, mf_drug3_cd, mf_drug4_cd,
   mf_drug5_cd, mf_drug6_cd, mf_drug7_cd, mf_alc1_cd, mf_alc2_cd,
   mf_alc3_cd, mf_alc4_cd, mf_alc5_cd, mf_alc6_cd, mf_tob1_cd,
   mf_tob2_cd, mf_tob3_cd, mf_tob4_cd, mf_tob5_cd, mf_tob6_cd,
   mf_edu1_cd, mf_edu2_cd, mf_edu3_cd, mf_edu4_cd, mf_edu5_cd,
   mf_edu6_cd, mf_edu7_cd, mf_edu8_cd, mf_edu9_cd, mf_edu10_cd)) OR (ce.event_cd IN (mf_note1_cd,
   mf_note2_cd, mf_note3_cd, mf_note4_cd, mf_note5_cd,
   mf_note6_cd, mf_note7_cd, mf_note8_cd, mf_note9_cd, mf_note10_cd,
   mf_note11_cd, mf_note12_cd)
    AND ce.view_level=1))
    AND ce.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce.clinsig_updt_dt_tm >= cnvtdatetime(m_rec->s_onset_dt_tm)
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=ce.performed_prsnl_id
    AND pr.active_ind=1)
  ORDER BY pn_sort, ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_size = 0
  HEAD ce.event_cd
   CALL echo(build2("event: ",uar_get_code_display(ce.event_cd)))
   IF (ce.event_class_cd=mf_date_cd)
    ms_tmp = trim(substring(3,16,ce.result_val)), ms_tmp = concat(substring(5,2,ms_tmp),"/",substring
     (7,2,ms_tmp),"/",substring(1,4,ms_tmp),
     " ",substring(9,2,ms_tmp),":",substring(11,2,ms_tmp))
   ELSE
    ms_tmp = trim(ce.result_val)
   ENDIF
   CASE (ce.event_cd)
    OF mf_gravida_cd:
     m_rec->s_gravida = ms_tmp
    OF mf_parity_cd:
     m_rec->s_parity = ms_tmp
    OF mf_preterm_cd:
     m_rec->s_preterm = ms_tmp
    OF mf_abortion_cd:
     m_rec->s_abortions = ms_tmp
    OF mf_living_cd:
     m_rec->s_living = ms_tmp
   ENDCASE
   IF (ce.event_cd IN (mf_vis_assess1_cd, mf_vis_assess2_cd, mf_vis_assess3_cd, mf_vis_assess4_cd,
   mf_vis_assess5_cd,
   mf_vis_assess6_cd, mf_vis_assess7_cd, mf_vis_assess8_cd, mf_vis_assess9_cd, mf_vis_assess10_cd,
   mf_vis_assess11_cd, mf_vis_assess12_cd, mf_vis_assess13_cd, mf_vis_assess14_cd, mf_vis_assess15_cd,
   mf_vis_assess16_cd, mf_vis_assess17_cd, mf_vis_assess18_cd, mf_vis_assess19_cd, mf_vis_assess20_cd,
   mf_vis_assess21_cd, mf_vis_assess22_cd, mf_vis_assess23_cd, mf_vis_assess24_cd, mf_vis_assess25_cd,
   mf_vis_assess26_cd, mf_vis_assess27_cd, mf_vis_assess28_cd, mf_vis_assess29_cd, mf_vis_assess30_cd,
   mf_vis_assess31_cd, mf_vis_assess32_cd, mf_vis_assess33_cd, mf_vis_assess34_cd, mf_vis_assess35_cd,
   mf_vis_assess36_cd, mf_vis_assess37_cd, mf_vis_assess38_cd, mf_vis_assess39_cd, mf_vis_assess40_cd,
   mf_vis_assess41_cd))
    pl_size = (size(m_rec->vis,5)+ 1), stat = alterlist(m_rec->vis,pl_size), m_rec->vis[pl_size].
    s_name = ps_event_disp,
    m_rec->vis[pl_size].s_value = ms_tmp, m_rec->vis[pl_size].s_user = trim(pr.name_full_formatted),
    m_rec->vis[pl_size].s_dt_tm = ps_end_dt_tm
   ELSEIF (ce.event_cd IN (mf_drug1_cd, mf_drug2_cd, mf_drug3_cd, mf_drug4_cd, mf_drug5_cd,
   mf_drug6_cd, mf_drug7_cd, mf_alc1_cd, mf_alc2_cd, mf_alc3_cd,
   mf_alc4_cd, mf_alc5_cd, mf_alc6_cd, mf_tob1_cd, mf_tob2_cd,
   mf_tob3_cd, mf_tob4_cd, mf_tob5_cd, mf_tob6_cd))
    pl_size = (size(m_rec->soc,5)+ 1), stat = alterlist(m_rec->soc,pl_size), m_rec->soc[pl_size].
    s_name = ps_event_disp,
    m_rec->soc[pl_size].s_value = ms_tmp, m_rec->soc[pl_size].s_user = trim(pr.name_full_formatted),
    m_rec->soc[pl_size].s_dt_tm = ps_end_dt_tm
   ELSEIF (ce.event_cd IN (mf_edu1_cd, mf_edu2_cd, mf_edu3_cd, mf_edu4_cd, mf_edu5_cd,
   mf_edu6_cd, mf_edu7_cd, mf_edu8_cd, mf_edu9_cd, mf_edu10_cd))
    pl_size = (size(m_rec->edu,5)+ 1), stat = alterlist(m_rec->edu,pl_size), m_rec->edu[pl_size].
    s_name = ps_event_disp,
    m_rec->edu[pl_size].s_value = ms_tmp, m_rec->edu[pl_size].s_user = trim(pr.name_full_formatted),
    m_rec->edu[pl_size].s_dt_tm = ps_end_dt_tm
   ENDIF
  DETAIL
   IF (ce.event_cd IN (mf_note1_cd, mf_note2_cd, mf_note3_cd, mf_note4_cd, mf_note5_cd,
   mf_note6_cd, mf_note7_cd, mf_note8_cd, mf_note9_cd, mf_note10_cd,
   mf_note11_cd, mf_note12_cd))
    pl_size = (size(m_rec->notes,5)+ 1), stat = alterlist(m_rec->notes,pl_size), m_rec->notes[pl_size
    ].s_type = ps_event_disp,
    m_rec->notes[pl_size].s_subject = trim(ce.event_title_text), m_rec->notes[pl_size].s_user = trim(
     pr.name_full_formatted), m_rec->notes[pl_size].s_dt_tm = ps_end_dt_tm
   ENDIF
  FOOT REPORT
   m_rec->s_full_term = trim(cnvtstring((cnvtint(m_rec->s_parity) - cnvtint(m_rec->s_preterm))))
  WITH nocounter
 ;end select
 SELECT
  ps_event_disp = trim(uar_get_code_display(ce.event_cd)), ps_end_dt_tm = trim(format(ce
    .event_end_dt_tm,"mm/dd/yy hh:mm;;d")), ps_result = trim(ce.result_val)
  FROM orders o,
   clinical_event ce
  PLAN (o
   WHERE (o.person_id=m_rec->f_person_id)
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_lab_type_cd
    AND o.orig_order_dt_tm >= cnvtdatetime(m_rec->s_onset_dt_tm))
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.order_id=o.order_id
    AND trim(ce.result_val) > " ")
  ORDER BY ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD ce.event_cd
   pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_rec->lab,5))
    stat = alterlist(m_rec->lab,(pl_cnt+ 10))
   ENDIF
   m_rec->lab[pl_cnt].s_name = ps_event_disp, m_rec->lab[pl_cnt].s_result = ps_result, m_rec->lab[
   pl_cnt].s_dt_tm = ps_end_dt_tm
  FOOT REPORT
   stat = alterlist(m_rec->lab,pl_cnt)
  WITH nocounter
 ;end select
 SET ms_displays = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET ms_tmp = concat("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}",
  "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134")
 SET ms_tmp = concat(ms_tmp,"\tx3500",ms_rtab,ms_wbf36," PRENATAL SUMMARY ",
  ms_wr,ms_reol,ms_pard)
 SET ms_tmp = concat(ms_tmp,"\tx100",ms_rtab,ms_wb,ms_line,
  ms_reol,ms_pard)
 SET ms_tmp = concat(ms_tmp,"\tx200\tx6000\tx11000",ms_rtab,ms_wb," Name: ",
  ms_wr," ",m_rec->s_pat_name,ms_rtab,ms_wb,
  " Age: ",ms_wr," ",m_rec->s_pat_age,ms_reol,
  ms_rtab,ms_wb," Gravida/Parity: ",ms_wr," G",
  m_rec->s_gravida,",P",m_rec->s_parity,"(",m_rec->s_full_term,
  ",",m_rec->s_preterm,",",m_rec->s_abortions,",",
  m_rec->s_living,")",ms_reol,ms_pard)
 IF (size(m_rec->notes,5) > 0)
  SET ms_tmp = concat(ms_tmp,"\tx100",ms_reol,ms_rtab,ms_wbf24,
   "\ul Pregnancy Related Documents \ul0",ms_wr,ms_reol,ms_pard)
  SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wb,"\ul Subject \ul0",
   ms_rtab,"\ul Note Type \ul0",ms_rtab,"\ul Auth \ul0",ms_rtab,
   "\ul Date \ul0",ms_reol,ms_pard)
  FOR (ml_cnt = 1 TO size(m_rec->notes,5))
    SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wr," ",
     m_rec->notes[ml_cnt].s_subject,ms_rtab,ms_wr," ",m_rec->notes[ml_cnt].s_type,
     ms_rtab,ms_wr," ",m_rec->notes[ml_cnt].s_user,ms_rtab,
     ms_wr," ",m_rec->notes[ml_cnt].s_dt_tm,ms_reol,ms_pard)
  ENDFOR
 ENDIF
 IF (size(m_rec->vis,5) > 0)
  SET ms_tmp = concat(ms_tmp,"\tx100",ms_reol,ms_rtab,ms_wbf24,
   "\ul Visit Assessment \ul0",ms_wr,ms_reol,ms_pard)
  SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wb,"\ul Name \ul0",
   ms_rtab,"\ul Value \ul0",ms_rtab,"\ul Charted By \ul0",ms_rtab,
   "\ul Date \ul0",ms_reol,ms_pard)
  FOR (ml_cnt = 1 TO size(m_rec->vis,5))
    SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wr," ",
     m_rec->vis[ml_cnt].s_name,ms_rtab,ms_wr," ",m_rec->vis[ml_cnt].s_value,
     ms_rtab,ms_wr," ",m_rec->vis[ml_cnt].s_user,ms_rtab,
     ms_wr," ",m_rec->vis[ml_cnt].s_dt_tm,ms_reol,ms_pard)
  ENDFOR
 ENDIF
 IF (size(m_rec->lab,5) > 0)
  SET ms_tmp = concat(ms_tmp,"\tx100",ms_reol,ms_rtab,ms_wbf24,
   "\ul Lab Results \ul0",ms_wr,ms_reol,ms_pard)
  SET ms_tmp = concat(ms_tmp,"\tx200\tx5000\tx9000",ms_rtab,ms_wb,"\ul Event \ul0",
   ms_rtab,"\ul Result \ul0",ms_rtab,"\ul Date \ul0",ms_reol,
   ms_pard)
  FOR (ml_cnt = 1 TO size(m_rec->lab,5))
    SET ms_tmp = concat(ms_tmp,"\tx200\tx5000\tx9000",ms_rtab,ms_wr," ",
     m_rec->lab[ml_cnt].s_name,ms_rtab,ms_wr," ",m_rec->lab[ml_cnt].s_result,
     ms_rtab,ms_wr," ",m_rec->lab[ml_cnt].s_dt_tm,ms_reol,
     ms_pard)
  ENDFOR
 ENDIF
 IF (size(m_rec->soc,5) > 0)
  SET ms_tmp = concat(ms_tmp,"\tx100",ms_reol,ms_rtab,ms_wbf24,
   "\ul Social History \ul0",ms_wr,ms_reol,ms_pard)
  SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wb,"\ul Name \ul0",
   ms_rtab,"\ul Value \ul0",ms_rtab,"\ul Charted By \ul0",ms_rtab,
   "\ul Date \ul0",ms_reol,ms_pard)
  FOR (ml_cnt = 1 TO size(m_rec->soc,5))
    SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wr," ",
     m_rec->soc[ml_cnt].s_name,ms_rtab,ms_wr," ",m_rec->soc[ml_cnt].s_value,
     ms_rtab,ms_wr," ",m_rec->soc[ml_cnt].s_user,ms_rtab,
     ms_wr," ",m_rec->soc[ml_cnt].s_dt_tm,ms_reol,ms_pard)
  ENDFOR
 ENDIF
 IF (size(m_rec->edu,5) > 0)
  SET ms_tmp = concat(ms_tmp,"\tx100",ms_reol,ms_rtab,ms_wbf24,
   "\ul Education \ul0",ms_wr,ms_reol,ms_pard)
  SET ms_tmp = concat(ms_tmp,"\tx200\tx4000\tx7000\tx9000",ms_rtab,ms_wb,"\ul Name \ul0",
   ms_rtab,"\ul Value \ul0",ms_rtab,"\ul (Charted by) \ul0",ms_rtab,
   "\ul (Date) \ul0",ms_reol,ms_pard)
  FOR (ml_cnt = 1 TO size(m_rec->edu,5))
   SET ms_tmp = concat(ms_tmp,"\tx200\tx4000",ms_rtab,ms_wr," ",
    m_rec->edu[ml_cnt].s_name,ms_rtab,ms_wr," ",m_rec->edu[ml_cnt].s_value,
    ms_reol,ms_pard)
   SET ms_tmp = concat(ms_tmp,"\tx7000\tx9000",ms_rtab,ms_wr," ",
    m_rec->edu[ml_cnt].s_user,ms_rtab,ms_wr," ",m_rec->edu[ml_cnt].s_dt_tm,
    ms_reol,ms_reol,ms_pard)
  ENDFOR
 ENDIF
 SET reply->text = build2(ms_tmp,"}")
 CALL echo(reply->text)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
