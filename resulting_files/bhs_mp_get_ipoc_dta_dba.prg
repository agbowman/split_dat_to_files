CREATE PROGRAM bhs_mp_get_ipoc_dta:dba
 PROMPT
  "Encounter ID" = 0
  WITH f_encntr_id
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_goal_stay_disp = vc
   1 s_goal_stay_val = vc
   1 s_goal_stay_dt_tm = vc
   1 s_goal_today_disp = vc
   1 s_goal_today_val = vc
   1 s_goal_today_dt_tm = vc
   1 s_ant_disch_dt_disp = vc
   1 s_ant_disch_dt_val = vc
   1 s_ant_disch_dt_dt_tm = vc
   1 s_plan_steps_disp = vc
   1 s_plan_steps_val = vc
   1 s_plan_steps_dt_tm = vc
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE mf_ipoc_form_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INTERDISCIPLINARYPLANOFCAREFORM"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_alt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_goal_stay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTFAMILYTEAMSGOALSFORSTAY"))
 DECLARE mf_goal_today_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PTFAMILYTEAMSGOALSFORTODAY"))
 DECLARE mf_ant_disch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ANTICIPATEDDISCHARGEDATE"))
 DECLARE mf_plan_steps_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PLANNEXTSTEPS"
   ))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_date = vc WITH protect, noconstant(" ")
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
    AND ce1.event_cd=mf_ipoc_form_cd
    AND ce1.valid_until_dt_tm > sysdate
    AND ce1.event_end_dt_tm < sysdate
    AND ce1.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd))
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm > sysdate)
   JOIN (ce3
   WHERE ce3.parent_event_id=ce2.event_id
    AND ce3.event_cd IN (mf_goal_stay_cd, mf_goal_today_cd, mf_ant_disch_cd, mf_plan_steps_cd)
    AND ce3.result_status_cd IN (mf_auth_cd, mf_alt_cd, mf_mod_cd)
    AND ce3.valid_until_dt_tm > sysdate)
  ORDER BY ce1.event_id DESC, ce3.event_cd, ce3.event_end_dt_tm DESC
  HEAD REPORT
   pl_flag = 0
  HEAD ce1.event_id
   pl_flag = (pl_flag+ 1)
  HEAD ce3.event_cd
   IF (pl_flag=1)
    CALL echo(build2("event_cd: ",trim(uar_get_code_display(ce3.event_cd))," ",trim(ce3.result_val)))
    IF (ce3.event_cd=mf_goal_stay_cd)
     m_rec->s_goal_stay_disp = trim(uar_get_code_display(ce3.event_cd)), m_rec->s_goal_stay_val =
     trim(ce3.result_val), m_rec->s_goal_stay_dt_tm = trim(format(ce3.event_end_dt_tm,
       "mm/dd/yy hh:mm;;d"))
    ELSEIF (ce3.event_cd=mf_goal_today_cd)
     m_rec->s_goal_today_disp = trim(uar_get_code_display(ce3.event_cd)), m_rec->s_goal_today_val =
     trim(ce3.result_val), m_rec->s_goal_today_dt_tm = trim(format(ce3.event_end_dt_tm,
       "mm/dd/yy hh:mm;;d"))
    ELSEIF (ce3.event_cd=mf_ant_disch_cd)
     m_rec->s_ant_disch_dt_disp = trim(uar_get_code_display(ce3.event_cd)), ms_date = concat(
      substring(7,2,ce3.result_val),"/",substring(9,2,ce3.result_val),"/",substring(3,4,ce3
       .result_val)), m_rec->s_ant_disch_dt_val = ms_date,
     m_rec->s_ant_disch_dt_dt_tm = trim(format(ce3.event_end_dt_tm,"mm/dd/yy hh:mm;;d"))
    ELSEIF (ce3.event_cd=mf_plan_steps_cd)
     m_rec->s_plan_steps_disp = trim(uar_get_code_display(ce3.event_cd)), m_rec->s_plan_steps_val =
     trim(ce3.result_val), m_rec->s_plan_steps_dt_tm = trim(format(ce3.event_end_dt_tm,
       "mm/dd/yy hh:mm;;d"))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 CALL echorecord(m_rec)
 SET _memory_reply_string = cnvtrectojson(m_rec)
 FREE RECORD m_rec
END GO
