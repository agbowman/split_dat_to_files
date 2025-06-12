CREATE PROGRAM bhs_gvw_st_g_code:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 dta[*]
     2 f_event_cd = f8
     2 s_event_disp = vc
     2 s_result = vc
     2 s_result_dt_tm = vc
     2 l_sort = i4
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_alt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE sp_ther_vis_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPEECHTHERAPYVISITPLANOFCAREFORM"))
 DECLARE sp_ther_out_reha_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPEECHTHERAPYOUTPATIENTREHABFORM"))
 DECLARE mf_st_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "REHABILITATIONCHARGEGUIDEFORM"))
 DECLARE mf_st_cd1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SLPPRIMARYLIMITATIONCURRENTSTATUS"))
 DECLARE mf_st_cd2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SWALLOWCURRENTSTATUSG8996"))
 DECLARE mf_st_cd3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MOTORSPEECHCURRENTSTATUSG8999"))
 DECLARE mf_st_cd4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPOKENLANGCOMPREHENSIONCURRENTG9159"))
 DECLARE mf_st_cd5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPOKENLANGEXPRESSIONCURRENTG9162"))
 DECLARE mf_st_cd6 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ATTENTIONCURRENTSTATUSG9165"))
 DECLARE mf_st_cd7 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEMORYCURRENTSTATUSG9168"))
 DECLARE mf_st_cd8 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VOICECURRENTSTATUSG9171"))
 DECLARE mf_st_cd9 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERSLPCURRENTSTATUSG9174"))
 DECLARE mf_st_cd10 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SLPCURRENTSELECTIONMETHOD"))
 DECLARE mf_st_cd11 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SLPPRIMARYLIMITATIONGOALSTATUS"))
 DECLARE mf_st_cd12 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SWALLOWGOALSTATUSG8997"))
 DECLARE mf_st_cd13 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MOTORSPEECHGOALSTATUSG9186"))
 DECLARE mf_st_cd14 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPOKENLANGCOMPREHENSIONGOALG9160"))
 DECLARE mf_st_cd15 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SPOKENLANGUAGEEXPRESSIONGOALG9163"))
 DECLARE mf_st_cd16 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ATTENTIONGOALSTATUSG9166"))
 DECLARE mf_st_cd17 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MEMORYGOALSTATUSG9169"))
 DECLARE mf_st_cd18 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "VOICEGOALSTATUSG9172"))
 DECLARE mf_st_cd19 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERSLPGOALSTATUSG9175"))
 DECLARE mf_st_cd20 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SLPGOALSELECTIONMETHOD"))
 DECLARE ms_out = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce1,
   clinical_event ce2,
   clinical_event ce3
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1)
   JOIN (ce1
   WHERE ce1.encntr_id=e.encntr_id
    AND ce1.person_id=e.person_id
    AND ce1.event_cd IN (mf_st_form_cd, sp_ther_vis_form_cd, sp_ther_out_reha_form_cd)
    AND ce1.valid_until_dt_tm > sysdate
    AND ce1.event_end_dt_tm < sysdate
    AND ce1.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd)
    AND ce1.valid_until_dt_tm > sysdate)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm > sysdate)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd IN (mf_st_cd1, mf_st_cd2, mf_st_cd3, mf_st_cd4, mf_st_cd5,
   mf_st_cd6, mf_st_cd7, mf_st_cd8, mf_st_cd9, mf_st_cd10,
   mf_st_cd11, mf_st_cd12, mf_st_cd13, mf_st_cd14, mf_st_cd15,
   mf_st_cd16, mf_st_cd17, mf_st_cd18, mf_st_cd19, mf_st_cd20)
    AND ce3.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd)
    AND ce3.valid_until_dt_tm > sysdate)
  ORDER BY ce1.event_id DESC, ce3.event_cd, ce3.event_end_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0, pl_flag = 0
  HEAD ce1.event_id
   pl_flag = (pl_flag+ 1)
  HEAD ce3.event_cd
   IF (pl_flag=1)
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->dta,pl_cnt), m_rec->dta[pl_cnt].f_event_cd = ce3
    .event_cd,
    m_rec->dta[pl_cnt].s_event_disp = substring(1,50,trim(uar_get_code_display(ce3.event_cd))), m_rec
    ->dta[pl_cnt].s_result = substring(1,50,trim(ce3.result_val)), m_rec->dta[pl_cnt].s_result_dt_tm
     = trim(format(ce3.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
    CASE (ce3.event_cd)
     OF mf_st_cd1:
      m_rec->dta[pl_cnt].l_sort = 1
     OF mf_st_cd2:
      m_rec->dta[pl_cnt].l_sort = 2
     OF mf_st_cd3:
      m_rec->dta[pl_cnt].l_sort = 3
     OF mf_st_cd4:
      m_rec->dta[pl_cnt].l_sort = 4
     OF mf_st_cd5:
      m_rec->dta[pl_cnt].l_sort = 5
     OF mf_st_cd6:
      m_rec->dta[pl_cnt].l_sort = 6
     OF mf_st_cd7:
      m_rec->dta[pl_cnt].l_sort = 7
     OF mf_st_cd8:
      m_rec->dta[pl_cnt].l_sort = 8
     OF mf_st_cd9:
      m_rec->dta[pl_cnt].l_sort = 9
     OF mf_st_cd10:
      m_rec->dta[pl_cnt].l_sort = 10
     OF mf_st_cd11:
      m_rec->dta[pl_cnt].l_sort = 11
     OF mf_st_cd12:
      m_rec->dta[pl_cnt].l_sort = 12
     OF mf_st_cd13:
      m_rec->dta[pl_cnt].l_sort = 13
     OF mf_st_cd14:
      m_rec->dta[pl_cnt].l_sort = 14
     OF mf_st_cd15:
      m_rec->dta[pl_cnt].l_sort = 15
     OF mf_st_cd16:
      m_rec->dta[pl_cnt].l_sort = 16
     OF mf_st_cd17:
      m_rec->dta[pl_cnt].l_sort = 17
     OF mf_st_cd18:
      m_rec->dta[pl_cnt].l_sort = 18
     OF mf_st_cd19:
      m_rec->dta[pl_cnt].l_sort = 19
     OF mf_st_cd20:
      m_rec->dta[pl_cnt].l_sort = 20
    ENDCASE
   ENDIF
  WITH nocounter
 ;end select
 SET ms_out = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 IF (size(m_rec->dta,5) > 0)
  SELECT INTO "nl:"
   pl_sort = m_rec->dta[d.seq].l_sort
   FROM (dummyt d  WITH seq = value(size(m_rec->dta,5)))
   PLAN (d)
   ORDER BY pl_sort
   DETAIL
    ms_out = concat(ms_out,"\trowd","\clbrdrb\brdrdot\clbrdrr\brdrdot\cellx5000",
     "\clbrdrb\brdrdot\cellx10300","\clbrdrb\brdrdot\cellx11700",
     "\fs18\b ",m_rec->dta[d.seq].s_event_disp," \b0\intbl\cell\"," ",m_rec->dta[d.seq].s_result,
     " \intbl\cell\"," ",m_rec->dta[d.seq].s_result_dt_tm," \intbl\cell\row")
   WITH nocounter
  ;end select
  SET reply->text = build2(ms_out,"}")
 ELSE
  SET reply->text = build2(ms_out,"No previous powerforms found}")
 ENDIF
 FREE RECORD m_rec
 SET last_mod = "001 07/11/2017 SR 412161809 Modified the script to display the Genviews"
END GO
