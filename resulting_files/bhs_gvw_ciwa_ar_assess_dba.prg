CREATE PROGRAM bhs_gvw_ciwa_ar_assess:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF (validate(request)=0)
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
  SET request->person[1].person_id = 23416105.0
  SET request->visit[1].encntr_id = 102606289.0
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 cnt = i4
   1 list[*]
     2 s_score_dt_tm = vc
     2 s_score_result = vc
 )
 DECLARE mf_person_id = f8 WITH protect, noconstant(request->person[1].person_id)
 DECLARE ms_rhead = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_encntr_id = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_alt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_ciwaar_score_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"CIWAARSCORE"
   ))
 DECLARE ms_rh2r = vc WITH protect, constant(notrim("\PLAIN \F0 \FS18 \CB2 \PARD\SL0 "))
 DECLARE ms_rh2b = vc WITH protect, constant(notrim("\PLAIN \F0 \FS18 \B \CB2 \PARD\SL0 "))
 DECLARE ms_rh2bu = vc WITH protect, constant(notrim("\PLAIN \F0 \FS18 \B \UL \CB2 \PARD\SL0 "))
 DECLARE ms_rh2u = vc WITH protect, constant(notrim("\PLAIN \F0 \FS18 \U \CB2 \PARD\SL0 "))
 DECLARE ms_rh2i = vc WITH protect, constant(notrim("\PLAIN \F0 \FS18 \I \CB2 \PARD\SL0 "))
 DECLARE ms_reol = vc WITH protect, constant(notrim("\PAR "))
 DECLARE ms_rtab = vc WITH protect, constant(notrim("\TAB "))
 DECLARE ms_wr = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 "))
 DECLARE ms_wb = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 \B \CB2 "))
 DECLARE ms_wu = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 \UL \CB "))
 DECLARE ms_wi = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 \I \CB2 "))
 DECLARE ms_wbi = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 \B \I \CB2 "))
 DECLARE ms_wiu = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 \I \UL \CB2 "))
 DECLARE ms_wbiu = vc WITH protect, constant(notrim(" \PLAIN \F0 \FS18 \B \UL \I \CB2 "))
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 SET ms_rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern\fprq1\fcharset0 r_ansi;}}"
 SET ms_rhead = concat(ms_rhead,"{\colortbl;\red0\green0\blue0;\red0\green0\blue255;")
 SET ms_rhead = concat(ms_rhead,"\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;"
  )
 SET ms_rhead = concat(ms_rhead,
  "\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;")
 SET ms_rhead = concat(ms_rhead,"\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;")
 SET ms_rhead = concat(ms_rhead,"\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;"
  )
 SET ms_rhead = concat(ms_rhead,"\red128\green128\blue128;\red192\green192\blue192;}")
 IF (mf_encntr_id > 0.0
  AND mf_person_id=0.0)
  SELECT INTO "nl:"
   FROM encounter e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1
   HEAD REPORT
    mf_person_id = e.person_id
   WITH nocounter
  ;end select
 ELSEIF (mf_encntr_id=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   clinical_event ce
  PLAN (e
   WHERE e.encntr_id=mf_encntr_id
    AND e.active_ind=1)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.event_cd=mf_ciwaar_score_cd
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm < sysdate
    AND ce.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  DETAIL
   m_rec->cnt = (m_rec->cnt+ 1), stat = alterlist(m_rec->list,m_rec->cnt), m_rec->list[m_rec->cnt].
   s_score_dt_tm = trim(format(ce.event_end_dt_tm,"dd-mmm-yyyy hh:mm;;d")),
   m_rec->list[m_rec->cnt].s_score_result = trim(ce.result_val)
  WITH nocounter
 ;end select
 SET reply->text = concat(ms_rhead,ms_rh2bu,"CIWA-AR Withdrawal Score",ms_rtab,"Date/Time",
  ms_reol)
 FOR (ml_cnt = 1 TO m_rec->cnt)
   SET reply->text = concat(reply->text,ms_rh2r,ms_rtab,m_rec->list[ml_cnt].s_score_result,ms_rtab,
    ms_rtab,ms_rtab,m_rec->list[ml_cnt].s_score_dt_tm,ms_reol)
 ENDFOR
 SET reply->text = concat(reply->text,ms_rtfeof)
#exit_script
 FREE RECORD m_rec
END GO
