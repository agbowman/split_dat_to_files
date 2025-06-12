CREATE PROGRAM bhs_rpt_ed_pulse:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = "BMC",
  "n_debug_ind" = 0
  WITH outdev, s_facility, n_debug_ind
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 EXECUTE bhs_sys_stand_subroutine
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_pat_cnt = i4
   1 pat[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_encntr_alias = vc
     2 s_name_full_formated = vc
     2 s_loc_nurse_unit_disp = vc
     2 f_loc_nurse_unit_cd = f8
     2 f_loc_room_cd = f8
     2 s_loc_room_disp = vc
     2 f_loc_bed_cd = f8
     2 s_loc_bed_disp = vc
     2 s_acuity_level = vc
     2 n_waiting_room_ind = i2
 ) WITH protect
 FREE RECORD m_data
 RECORD m_data(
   1 s_msg = vc
   1 s_facility = vc
   1 s_timestamp = vc
   1 l_acuity_trauma = i4
   1 l_acuity1 = i4
   1 l_acuity2 = i4
   1 l_acuity3 = i4
   1 l_acuity4 = i4
   1 l_acuity_not_set = i4
   1 l_waiting_room = i4
   1 l_total_patients = i4
 ) WITH protect
 DECLARE ms_facility = vc WITH protect, constant(cnvtupper(trim( $S_FACILITY)))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_esw_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sbr_echo(ps_msg=vc) = null
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Begin Script","")
 CASE (ms_facility)
  OF "BMLH":
   SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BMLHEDTRACKINGGROUP")
  OF "BFMC":
   SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BFMCEDTRACKINGGROUP")
  OF "BMC":
   SET mf_facility_cd = uar_get_code_by("DISPLAYKEY",16370,"BMCEDHOFTRACKINGGROUP")
  ELSE
   SET m_data->s_msg = build("Facility value is incorrect: ",ms_facility)
   GO TO exit_script
 ENDCASE
 CALL sbr_echo(build("selected facility: ",ms_facility,"facility_cd: ",mf_facility_cd))
 IF (mf_facility_cd <= 0)
  CALL bhs_sbr_log("log","",0,"",0.0,
   concat("Invalid Facility Param",ms_facility),"Only BMLH, BFMC, BMC accepted","F")
  GO TO exit_script
 ELSE
  SET m_data->s_facility = ms_facility
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.display_key="ESW"
   AND cv.cdf_meaning="AMBULATORY"
  DETAIL
   mf_esw_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM tracking_checkin t,
   track_reference tr,
   tracking_locator tl,
   tracking_item ti,
   encounter e,
   encntr_alias ea,
   person p
  PLAN (t
   WHERE t.tracking_group_cd=mf_facility_cd
    AND t.checkout_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
    AND t.parent_entity_name != "TRACKING_PREARRIVAL")
   JOIN (tr
   WHERE tr.tracking_ref_id=outerjoin(t.acuity_level_id))
   JOIN (tl
   WHERE tl.tracking_id=outerjoin(t.tracking_id))
   JOIN (ti
   WHERE ti.tracking_id=outerjoin(t.tracking_id))
   JOIN (e
   WHERE e.encntr_id=outerjoin(ti.encntr_id))
   JOIN (p
   WHERE p.person_id=outerjoin(e.person_id)
    AND p.active_ind=outerjoin(1))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.active_ind=outerjoin(1)
    AND ea.end_effective_dt_tm > outerjoin(sysdate)
    AND ea.encntr_alias_type_cd=outerjoin(mf_fin_cd))
  ORDER BY t.tracking_checkin_id, tl.tracking_locator_id DESC
  HEAD REPORT
   m_rec->l_pat_cnt = 0
  HEAD t.tracking_checkin_id
   m_rec->l_pat_cnt = (m_rec->l_pat_cnt+ 1)
   IF (mod(m_rec->l_pat_cnt,100)=1)
    CALL alterlist(m_rec->pat,(m_rec->l_pat_cnt+ 99))
   ENDIF
   m_rec->pat[m_rec->l_pat_cnt].f_person_id = p.person_id, m_rec->pat[m_rec->l_pat_cnt].
   s_name_full_formated = p.name_full_formatted, m_rec->pat[m_rec->l_pat_cnt].f_encntr_id = ea
   .encntr_id,
   m_rec->pat[m_rec->l_pat_cnt].s_encntr_alias = ea.alias, m_rec->pat[m_rec->l_pat_cnt].
   s_loc_nurse_unit_disp = uar_get_code_display(tl.loc_nurse_unit_cd), m_rec->pat[m_rec->l_pat_cnt].
   f_loc_nurse_unit_cd = tl.loc_nurse_unit_cd,
   m_rec->pat[m_rec->l_pat_cnt].s_loc_room_disp = uar_get_code_display(tl.loc_room_cd), m_rec->pat[
   m_rec->l_pat_cnt].f_loc_room_cd = tl.loc_room_cd, m_rec->pat[m_rec->l_pat_cnt].s_loc_bed_disp =
   build(uar_get_code_display(tl.loc_bed_cd)),
   m_rec->pat[m_rec->l_pat_cnt].f_loc_bed_cd = tl.loc_bed_cd, m_rec->pat[m_rec->l_pat_cnt].
   s_acuity_level = tr.display_key
   CASE (m_rec->pat[m_rec->l_pat_cnt].s_acuity_level)
    OF "T":
     m_data->l_acuity_trauma = (m_data->l_acuity_trauma+ 1)
    OF "1":
     m_data->l_acuity1 = (m_data->l_acuity1+ 1)
    OF "2":
     m_data->l_acuity2 = (m_data->l_acuity2+ 1)
    OF "3":
     m_data->l_acuity3 = (m_data->l_acuity3+ 1)
    OF "4":
     m_data->l_acuity4 = (m_data->l_acuity4+ 1)
    ELSE
     m_data->l_acuity_not_set = (m_data->l_acuity_not_set+ 1)
   ENDCASE
   IF (mf_esw_cd=tl.loc_nurse_unit_cd)
    m_rec->pat[m_rec->l_pat_cnt].n_waiting_room_ind = 1, m_data->l_waiting_room = (m_data->
    l_waiting_room+ 1)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->pat,m_rec->l_pat_cnt), m_data->l_total_patients = m_rec->l_pat_cnt, m_data->
   s_timestamp = format(sysdate,"mm-dd-yyyy hh:mm;;d")
  WITH nocounter, separator = " "
 ;end select
 SUBROUTINE sbr_echo(ps_msg)
   IF (( $N_DEBUG_IND=1))
    CALL echo(build("***** ",ps_msg))
    RETURN(ps_msg)
   ENDIF
 END ;Subroutine
#exit_script
 SET reply->status_data[1].status = "S"
 SET _memory_reply_string = cnvtrectojson(m_data,2,1)
 CALL sbr_echo(_memory_reply_string)
 IF (( $N_DEBUG_IND=1))
  CALL echorecord(m_data)
  CALL echorecord(m_rec)
 ENDIF
 CALL bhs_sbr_log("stop","",0,"",0.0,
  concat("ED Pulse"),"",reply->status_data[1].status)
 FREE RECORD m_data
 FREE RECORD m_rec
END GO
