CREATE PROGRAM bhs_rpt_sn_case_times_prsnl:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgical Area" = 0,
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Enter Provider Last Name:" = "",
  "Select Provider(s):" = value(0.0),
  "Select Attendees" = 0
  WITH outdev, f_surgarea, s_starttime,
  s_endtime, s_prov_name_last, f_provider_id,
  f_attendee
 DECLARE f_role_code_4 = f8 WITH noconstant(0), protect
 DECLARE f_role_code_3 = f8 WITH noconstant(0), protect
 DECLARE f_role_code_2 = f8 WITH noconstant(0), protect
 DECLARE f_role_code_1 = f8 WITH noconstant(0), protect
 DECLARE mf_finnbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_snendorhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SNENDORHOLDMIN")),
 protect
 DECLARE mf_snstartorhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14003,"SNSTARTORHOLDMIN"
   )), protect
 DECLARE mf_snpacuout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - PACU Acuity Stop Time")), protect
 DECLARE mf_snpacuin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - PACU Acuity Start Time")), protect
 DECLARE mf_snorout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,"SN - Out OR (min)")),
 protect
 DECLARE mf_snorin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,"SN - In OR (min)")),
 protect
 DECLARE mf_snpreopout_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - Out Pre OP (min)")), protect
 DECLARE mf_snpreopin_cd = f8 WITH constant(uar_get_code_by("DESCRIPTION",14003,
   "SN - In Pre OP (min)")), protect
 DECLARE mf_pacuext_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUEXTENDEDRECOVERY")),
 protect
 DECLARE mf_pacuii_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUII")), protect
 DECLARE mf_pacui_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",10039,"PACUI")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE ml_loc1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc2 = i4 WITH protect, noconstant(0)
 FREE RECORD m_rec
 RECORD m_rec(
   1 prov[*]
     2 f_prov_id = f8
     2 s_prov_name = vc
 )
 FREE RECORD m_case_time
 RECORD m_case_time(
   1 l_cnt = i4
   1 s_attend_type1 = vc
   1 s_attend_type2 = vc
   1 s_attend_type3 = vc
   1 s_attend_type4 = vc
   1 list[*]
     2 f_sched_dttm = f8
     2 s_sched_day = vc
     2 s_sched_rm = vc
     2 s_fin = vc
     2 s_cancel_reason = vc
     2 s_actual_rm = vc
     2 s_sched_area = vc
     2 s_case_nm = vc
     2 s_acct_nm = vc
     2 f_surg_caseid = f8
     2 s_specialty = vc
     2 f_checkin_dttm = f8
     2 f_preopin_dttm = f8
     2 f_preopout_dttm = f8
     2 f_patinrm_dttm = f8
     2 f_procstart_dttm = f8
     2 f_procend_dttm = f8
     2 s_surgstart_day = vc
     2 f_surstart_dttm = f8
     2 f_surstop_dttm = f8
     2 f_patoutrm_dttm = f8
     2 f_orholdin_dttm = f8
     2 f_orholdout_dttm = f8
     2 f_pacu1in_dttm = f8
     2 f_pacu1out_dttm = f8
     2 f_pacu2in_dttm = f8
     2 f_pacu2out_dttm = f8
     2 f_pacu3in_dttm = f8
     2 f_pacu3out_dttm = f8
     2 s_cancel_ind = vc
     2 f_cancel_dttm = f8
     2 s_cancel_res = vc
     2 s_schproc_name = vc
     2 s_proc_name = vc
     2 s_proc_type = vc
     2 s_schsurgeon = vc
     2 s_procsurgeon = vc
     2 l_procdur_mins = i4
     2 f_proccode = f8
     2 s_schproc_type = vc
     2 s_attendee1 = vc
     2 s_attendee2 = vc
     2 s_attendee3 = vc
     2 s_attendee4 = vc
     2 s_encntr_type = vc
     2 s_sched_priority = vc
     2 m_sched_dur = i4
 ) WITH protect
 FREE RECORD grec1
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = vc
 )
 IF (( $F_PROVIDER_ID=0.0))
  SET ms_prov_parse = " 1=1"
 ELSE
  SELECT INTO "nl:"
   FROM prsnl pr
   WHERE (pr.person_id= $F_PROVIDER_ID)
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1,
    CALL alterlist(m_rec->prov,pl_cnt), m_rec->prov[pl_cnt].f_prov_id = pr.person_id,
    m_rec->prov[pl_cnt].s_prov_name = trim(pr.name_full_formatted,3)
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_case_time)
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_ATTENDEE),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var2 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_ATTENDEE),ml_gcnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gcnt+ 4))
     ENDIF
     SET grec1->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_ATTENDEE),ml_gcnt))
     SET grec1->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_ATTENDEE),
       ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec1->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gcnt = 1
  SET grec1->list[1].f_cv =  $F_ATTENDEE
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All DTAs"
   SET ms_opr_var2 = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var2 = "="
  ENDIF
 ENDIF
 CALL echorecord(grec1)
 IF (size(grec1->list,5) <= 4)
  FOR (x = 1 TO size(grec1->list,5))
    IF (x=1)
     SET f_role_code_1 = grec1->list[1].f_cv
     SET m_case_time->s_attend_type1 = trim(grec1->list[1].s_disp,3)
    ENDIF
    IF (x=2)
     SET f_role_code_2 = grec1->list[2].f_cv
     SET m_case_time->s_attend_type2 = trim(grec1->list[2].s_disp,3)
    ENDIF
    IF (x=3)
     SET f_role_code_3 = grec1->list[3].f_cv
     SET m_case_time->s_attend_type3 = trim(grec1->list[3].s_disp,3)
    ENDIF
    IF (x=4)
     SET f_role_code_4 = grec1->list[4].f_cv
     SET m_case_time->s_attend_type4 = trim(grec1->list[4].s_disp,3)
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM surgical_case s,
    encounter e,
    encntr_alias fin,
    surg_case_procedure scp,
    prsnl prn,
    prsnl prn2,
    encntr_alias ea,
    prsnl_group png,
    dummyt d1,
    case_times c1,
    dummyt d2,
    sn_acuity_level sa1,
    dummyt d3,
    case_attendance ca,
    prsnl atd,
    sn_charge_header sch
   PLAN (s
    WHERE (s.surg_case_nbr_locn_cd= $F_SURGAREA)
     AND s.sched_start_dt_tm BETWEEN cnvtdatetime(cnvtdate2( $S_STARTTIME,"mm/dd/yyyy"),0) AND
    cnvtdatetime(cnvtdate2( $S_ENDTIME,"mm/dd/yyyy"),235959))
    JOIN (e
    WHERE e.encntr_id=s.encntr_id)
    JOIN (fin
    WHERE fin.encntr_id=e.encntr_id
     AND fin.active_status_cd=mf_cs48_active
     AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.active_ind=1)
    JOIN (sch
    WHERE (sch.surg_case_id= Outerjoin(s.surg_case_id)) )
    JOIN (scp
    WHERE (scp.surg_case_id= Outerjoin(s.surg_case_id)) )
    JOIN (prn
    WHERE (prn.person_id= Outerjoin(scp.sched_primary_surgeon_id)) )
    JOIN (prn2
    WHERE (prn2.person_id= Outerjoin(scp.primary_surgeon_id)) )
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(s.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(mf_finnbr_cd))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.end_effective_dt_tm> Outerjoin(sysdate)) )
    JOIN (png
    WHERE (png.prsnl_group_id= Outerjoin(scp.surg_specialty_id)) )
    JOIN (d1)
    JOIN (c1
    WHERE c1.surg_case_id=s.surg_case_id
     AND c1.task_assay_cd IN (mf_snpreopin_cd, mf_snpreopout_cd, mf_snorin_cd, mf_snorout_cd,
    mf_snstartorhold_cd,
    mf_snendorhold_cd))
    JOIN (d2)
    JOIN (sa1
    WHERE sa1.surg_case_id=s.surg_case_id
     AND sa1.acuity_level_cd IN (mf_pacui_cd, mf_pacuii_cd, mf_pacuext_cd))
    JOIN (d3)
    JOIN (ca
    WHERE ca.surg_case_id=s.surg_case_id
     AND operator(ca.role_perf_cd,ms_opr_var2, $F_ATTENDEE))
    JOIN (atd
    WHERE atd.person_id=ca.case_attendee_id)
   ORDER BY scp.surg_case_proc_id, s.surg_case_nbr_formatted
   HEAD REPORT
    m_case_time->l_cnt = 0, pl_add_ind = 0
   HEAD scp.surg_case_proc_id
    IF (((( $F_PROVIDER_ID=0.0)) OR (((locateval(ml_loc1,1,size(m_rec->prov,5),prn.person_id,m_rec->
     prov[ml_loc1].f_prov_id) > 0) OR (locateval(ml_loc2,1,size(m_rec->prov,5),prn2.person_id,m_rec->
     prov[ml_loc2].f_prov_id) > 0)) )) )
     pl_add_ind = 1, m_case_time->l_cnt += 1, stat = alterlist(m_case_time->list,m_case_time->l_cnt),
     m_case_time->list[m_case_time->l_cnt].f_sched_dttm = s.sched_start_dt_tm, m_case_time->list[
     m_case_time->l_cnt].s_sched_day = evaluate(cnvtstring(s.sched_start_day),"0","SUNDAY","1",
      "MONDAY",
      "2","TUESDAY","3","WEDNESDAY","4",
      "THURSDAY","5","FRIDAY","6","SATURDAY",
      "-"), m_case_time->list[m_case_time->l_cnt].s_sched_rm = uar_get_code_display(s.sched_op_loc_cd
      ),
     m_case_time->list[m_case_time->l_cnt].s_actual_rm = uar_get_code_display(s.surg_op_loc_cd),
     m_case_time->list[m_case_time->l_cnt].s_sched_area = uar_get_code_display(s
      .surg_case_nbr_locn_cd), m_case_time->list[m_case_time->l_cnt].s_case_nm = s
     .surg_case_nbr_formatted,
     m_case_time->list[m_case_time->l_cnt].s_acct_nm = ea.alias, m_case_time->list[m_case_time->l_cnt
     ].f_checkin_dttm = s.checkin_dt_tm, m_case_time->list[m_case_time->l_cnt].s_surgstart_day =
     evaluate(cnvtstring(s.surg_start_day),"0","SUNDAY","1","MONDAY",
      "2","TUESDAY","3","WEDNESDAY","4",
      "THURSDAY","5","FRIDAY","6","SATURDAY",
      "-"),
     m_case_time->list[m_case_time->l_cnt].f_surstart_dttm = s.surg_start_dt_tm, m_case_time->list[
     m_case_time->l_cnt].f_surstop_dttm = s.surg_stop_dt_tm, m_case_time->list[m_case_time->l_cnt].
     f_cancel_dttm = s.cancel_dt_tm,
     m_case_time->list[m_case_time->l_cnt].s_cancel_res = uar_get_code_display(s.cancel_reason_cd),
     m_case_time->list[m_case_time->l_cnt].s_cancel_ind = evaluate(s.cancel_reason_cd,null,"-",0,
      "Cancelled"), m_case_time->list[m_case_time->l_cnt].f_procstart_dttm = scp.proc_start_dt_tm,
     m_case_time->list[m_case_time->l_cnt].f_procend_dttm = scp.proc_end_dt_tm, m_case_time->list[
     m_case_time->l_cnt].s_schproc_name = uar_get_code_description(scp.sched_surg_proc_cd),
     m_case_time->list[m_case_time->l_cnt].s_proc_name = uar_get_code_description(scp.surg_proc_cd),
     m_case_time->list[m_case_time->l_cnt].s_proc_type = evaluate(scp.primary_proc_ind,1,"PRIMARY",0,
      "SECONDARY"), m_case_time->list[m_case_time->l_cnt].s_schsurgeon = prn.name_full_formatted,
     m_case_time->list[m_case_time->l_cnt].s_procsurgeon = prn2.name_full_formatted,
     m_case_time->list[m_case_time->l_cnt].l_procdur_mins = scp.proc_dur_min, m_case_time->list[
     m_case_time->l_cnt].f_proccode = scp.sched_ud5_cd
     IF (png.prsnl_group_id=0)
      m_case_time->list[m_case_time->l_cnt].s_specialty = "                "
     ELSE
      m_case_time->list[m_case_time->l_cnt].s_specialty = png.prsnl_group_name
     ENDIF
     m_case_time->list[m_case_time->l_cnt].s_encntr_type = uar_get_code_display(e.encntr_type_cd),
     m_case_time->list[m_case_time->l_cnt].s_sched_priority = uar_get_code_display(sch.priority_cd),
     m_case_time->list[m_case_time->l_cnt].s_schproc_type = evaluate(scp.sched_primary_ind,1,
      "PRIMARY",0,"SECONDARY"),
     m_case_time->list[m_case_time->l_cnt].m_sched_dur = scp.sched_dur
    ENDIF
   DETAIL
    IF (pl_add_ind=1)
     CASE (c1.task_assay_cd)
      OF mf_snpreopin_cd:
       m_case_time->list[m_case_time->l_cnt].f_preopin_dttm = c1.case_time_dt_tm
      OF mf_snpreopout_cd:
       m_case_time->list[m_case_time->l_cnt].f_preopout_dttm = c1.case_time_dt_tm
      OF mf_snorin_cd:
       m_case_time->list[m_case_time->l_cnt].f_patinrm_dttm = c1.case_time_dt_tm
      OF mf_snorout_cd:
       m_case_time->list[m_case_time->l_cnt].f_patoutrm_dttm = c1.case_time_dt_tm
      OF mf_snstartorhold_cd:
       m_case_time->list[m_case_time->l_cnt].f_orholdin_dttm = c1.case_time_dt_tm
      OF mf_snendorhold_cd:
       m_case_time->list[m_case_time->l_cnt].f_orholdout_dttm = c1.case_time_dt_tm
     ENDCASE
     CASE (sa1.acuity_level_cd)
      OF mf_pacui_cd:
       m_case_time->list[m_case_time->l_cnt].f_pacu1in_dttm = sa1.acuity_start_dt_tm,m_case_time->
       list[m_case_time->l_cnt].f_pacu1out_dttm = sa1.acuity_stop_dt_tm
      OF mf_pacuii_cd:
       m_case_time->list[m_case_time->l_cnt].f_pacu2in_dttm = sa1.acuity_start_dt_tm,m_case_time->
       list[m_case_time->l_cnt].f_pacu2out_dttm = sa1.acuity_stop_dt_tm
      OF mf_pacuext_cd:
       m_case_time->list[m_case_time->l_cnt].f_pacu3in_dttm = sa1.acuity_start_dt_tm,m_case_time->
       list[m_case_time->l_cnt].f_pacu3out_dttm = sa1.acuity_stop_dt_tm
     ENDCASE
    ENDIF
    IF (ca.role_perf_cd=f_role_code_1)
     m_case_time->list[m_case_time->l_cnt].s_attendee1 = trim(atd.name_full_formatted,3)
    ELSEIF (ca.role_perf_cd=f_role_code_2)
     m_case_time->list[m_case_time->l_cnt].s_attendee2 = trim(atd.name_full_formatted,3)
    ELSEIF (ca.role_perf_cd=f_role_code_3)
     m_case_time->list[m_case_time->l_cnt].s_attendee3 = trim(atd.name_full_formatted,3)
    ELSEIF (ca.role_perf_cd=f_role_code_4)
     m_case_time->list[m_case_time->l_cnt].s_attendee4 = trim(atd.name_full_formatted,3)
    ENDIF
   FOOT  scp.surg_case_proc_id
    pl_add_ind = 0
   WITH nocounter, outerjoin = d1, outerjoin = d2,
    outerjoin = d3, time = 800
  ;end select
  CALL echorecord(m_case_time)
  SELECT INTO  $OUTDEV
   primary_surgeon = substring(1,100,"Primary_Surgeon"), head1 = substring(1,100,trim(replace(
      m_case_time->s_attend_type1," ","_"),3)), head2 = substring(1,100,trim(replace(m_case_time->
      s_attend_type2," ","_"),3)),
   head3 = substring(1,100,trim(replace(m_case_time->s_attend_type3," ","_"),3)), head4 = substring(1,
    100,trim(replace(m_case_time->s_attend_type4," ","_"),3)), surgical_specialty = substring(1,100,
    "Surgical_Specialty"),
   or_case_number = substring(1,30,"OR_case_Number"), cancelled_reason = substring(1,30,
    "Cancelled_status"), patient_type = substring(1,20,"Patient_Type"),
   schedule_priority = substring(1,30,"Schedule_Priority"), primary_procedure = substring(1,30,
    "Primary_Procedure"), procedure_type = substring(1,30,"Procedure_Type"),
   case_start_date = substring(1,30,"Case_Start_Date"), scheduled_start_time = substring(1,30,
    "Scheduled_Start_Time"), in_rm_time = substring(1,30,"In_Room_Time"),
   out_of_rm_time = substring(1,30,"Out_of_Room_Time"), surgery_start_time = substring(1,30,
    "Surgery_Start_Time"), surgery_stop_time = substring(1,30,"Surgery_Stop_Time"),
   operating_room = substring(1,30,"Operating_Room"), surgical_area = substring(1,30,"Surgical_Area"),
   case_start_day = substring(1,30,"Case_Start_Day"),
   scheduled_case_duration = substring(1,30,"Scheduled_Case_Duration"), tot_surgery_minutes =
   substring(1,30,"Tot_Surgery_Minutes"), tot_patient_in_rm_minutes = substring(1,30,
    "Tot_Patient_in_Rm_Minutes"),
   preop_total_minutes = substring(1,30,"Preop_Total_Minutes"), pacu_total_minute = substring(1,30,
    "PACU_Total_Minute")
   FROM dummyt d
   WITH nocounter, separator = " ", format,
    noheading
  ;end select
  SELECT INTO  $OUTDEV
   preform_proc_surgeon = substring(1,100,m_case_time->list[d.seq].s_procsurgeon), attendee1 =
   substring(1,100,m_case_time->list[d.seq].s_attendee1), attendee2 = substring(1,100,m_case_time->
    list[d.seq].s_attendee2),
   attendee3 = substring(1,100,m_case_time->list[d.seq].s_attendee3), attendee4 = substring(1,100,
    m_case_time->list[d.seq].s_attendee4), specialty = substring(1,100,m_case_time->list[d.seq].
    s_specialty),
   or_case_# = trim(substring(1,30,m_case_time->list[d.seq].s_case_nm),3), cancel_reas = trim(
    substring(1,30,m_case_time->list[d.seq].s_cancel_res),3), patient_type = substring(1,20,
    m_case_time->list[d.seq].s_encntr_type),
   schedule_priority = substring(1,30,m_case_time->list[d.seq].s_sched_priority), preform_proc_name
    = substring(1,30,m_case_time->list[d.seq].s_proc_name), preform_proc_type = substring(1,30,
    m_case_time->list[d.seq].s_proc_type),
   date_of_surgery = substring(1,30,trim(format(cnvtdatetime(m_case_time->list[d.seq].f_sched_dttm),
      "MM/DD/YYYY;;q"),3)), sched_start_dt = substring(1,30,format(m_case_time->list[d.seq].
     f_sched_dttm,"@SHORTDATETIME")), pat_inrm_dt = substring(1,30,format(m_case_time->list[d.seq].
     f_patinrm_dttm,"@SHORTDATETIME")),
   pat_outrm_dt = substring(1,30,format(m_case_time->list[d.seq].f_patoutrm_dttm,"@SHORTDATETIME")),
   surgery_start_dt = substring(1,30,format(m_case_time->list[d.seq].f_surstart_dttm,"@SHORTDATETIME"
     )), surgery_stop_dt = substring(1,30,format(m_case_time->list[d.seq].f_surstop_dttm,
     "@SHORTDATETIME")),
   actual_or_rm = substring(1,30,trim(substring(1,50,m_case_time->list[d.seq].s_actual_rm),3)),
   surgical_area = substring(1,30,trim(substring(1,100,m_case_time->list[d.seq].s_sched_area),3)),
   day_of_week = substring(1,30,trim(substring(1,20,m_case_time->list[d.seq].s_sched_day),3)),
   scheduled_duration = substring(1,30,cnvtstring(cnvtreal(m_case_time->list[d.seq].m_sched_dur))),
   surgery_tmins = substring(1,30,cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[d.seq].
       f_surstop_dttm),cnvtdatetime(m_case_time->list[d.seq].f_surstart_dttm),4))), orroom_tmins =
   substring(1,30,cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_patoutrm_dttm),
      cnvtdatetime(m_case_time->list[d.seq].f_patinrm_dttm),4))),
   preop_tmins = substring(1,30,cnvtstring(datetimediff(cnvtdatetime(m_case_time->list[d.seq].
       f_preopout_dttm),cnvtdatetime(m_case_time->list[d.seq].f_preopin_dttm),4))), pacu_tmins =
   substring(1,30,cnvtstring(((datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu1out_dttm),
      cnvtdatetime(m_case_time->list[d.seq].f_pacu1in_dttm),4)+ datetimediff(cnvtdatetime(m_case_time
       ->list[d.seq].f_pacu2out_dttm),cnvtdatetime(m_case_time->list[d.seq].f_pacu2in_dttm),4))+
     datetimediff(cnvtdatetime(m_case_time->list[d.seq].f_pacu3out_dttm),cnvtdatetime(m_case_time->
       list[d.seq].f_pacu3in_dttm),4))))
   FROM (dummyt d  WITH seq = m_case_time->l_cnt)
   ORDER BY surgical_area, date_of_surgery, sched_start_dt
   WITH nocounter, separator = " ", format,
    noheading, append
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "You can only select a MAXIMUM of 4 Attendee's",
    CALL print(calcpos(36,18)), msg1,
    row + 2
   WITH dio = 08
  ;end select
 ENDIF
#exit_script
END GO
