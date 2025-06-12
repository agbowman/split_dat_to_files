CREATE PROGRAM bhs_rpt_sn_compass_delay_comm
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Area" = value(0.0),
  "From Case Start Date" = "SYSDATE",
  "To Case Start Date" = "SYSDATE"
  WITH outdev, f_surg_area, s_start_date,
  s_end_date
 DECLARE mf_active_rec = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_alt_modified = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_auth_res = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 DECLARE mf_sn_del_description = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SNDELDESCRIPTION")
  ), protect
 DECLARE delay_comment = vc WITH protect
 DECLARE surgical_area = vc WITH protect
 DECLARE primary_procdeure = vc WITH protect
 DECLARE scheduled_case_duration = vc WITH protect
 DECLARE case_add_on = vc WITH protect
 DECLARE tot_pat_in_rm_minutes = vc WITH protect
 DECLARE tot_surgery_minutes = vc WITH protect
 DECLARE out_of_room_time = vc WITH protect
 DECLARE in_room_time = vc WITH protect
 DECLARE surgery_stop_time = vc WITH protect
 DECLARE surgery_start_time = vc WITH protect
 DECLARE delay_reason = vc WITH protect
 DECLARE patient_type = vc WITH protect
 DECLARE operating_room = vc WITH protect
 DECLARE sched_start_time = vc WITH protect
 DECLARE surgery_start_date = vc WITH protect
 DECLARE primary_procedure = vc WITH protect
 DECLARE schedule_priority = vc WITH protect
 DECLARE or_case_number = vc WITH protect
 DECLARE surgical_specialty = vc WITH protect
 DECLARE primary_surgeon = vc WITH protect
 DECLARE case_start_day = vc WITH protect
 DECLARE ms_opr_var = vc WITH protect
 DECLARE ml_gnt = i4 WITH noconstant(0), protect
 DECLARE ms_lcheck = vc WITH protect
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_SURG_AREA),0)))
 RECORD grec1(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 IF (ms_lcheck="L")
  SET ms_opr_var = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_SURG_AREA),ml_gnt)))
    IF (ms_lcheck > " ")
     IF (mod(ml_gnt,5)=1)
      SET stat = alterlist(grec1->list,(ml_gnt+ 4))
     ENDIF
     SET grec1->list[ml_gnt].f_cv = cnvtint(parameter(parameter2( $F_SURG_AREA),ml_gnt))
     SET grec1->list[ml_gnt].s_disp = uar_get_code_display(parameter(parameter2( $F_SURG_AREA),ml_gnt
       ))
    ENDIF
  ENDWHILE
  SET ml_gnt -= 1
  SET stat = alterlist(grec1->list,ml_gnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET ml_gnt = 1
  SET grec1->list[1].f_cv =  $F_SURG_AREA
  IF ((grec1->list[1].f_cv=0.0))
   SET grec1->list[1].s_disp = "All facilites"
   SET ms_opr_var = "!="
  ELSE
   SET grec1->list[1].s_disp = uar_get_code_display(grec1->list[1].f_cv)
   SET ms_opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  primary_surgeon = substring(1,100,trim(ps.name_full_formatted)), surgical_specialty = substring(1,
   100,trim(pg.prsnl_group_name,3)), or_case_number = substring(1,100,sc.surg_case_nbr_formatted),
  schedule_priority = substring(1,100,uar_get_code_display(sc.sched_type_cd)), primary_procedure =
  substring(1,100,trim(uar_get_code_description(scp1.surg_proc_cd),3)), surgery_start_date =
  substring(1,100,format(sc.surg_start_dt_tm,"MM/DD/YYYY;;Q")),
  case_start_day = substring(1,100,trim(format(sc.surg_start_dt_tm,"WWWWWWWWW;;d"),3)),
  sched_start_time = substring(1,100,format(sc.sched_start_dt_tm,"hh:mm;;Q")), surgical_area =
  substring(1,100,trim(uar_get_code_display(sc.sched_surg_area_cd),3)),
  operating_room = substring(1,100,trim(uar_get_code_display(sc.sched_op_loc_cd),3)), patient_type =
  substring(1,100,trim(uar_get_code_display(enc.encntr_type_cd))), delay_reason = substring(1,100,
   trim(uar_get_code_display(sd.delay_reason_cd),3)),
  delay_comment = substring(1,100,trim(ce.result_val,3)), surgery_start_time = format(cclsql_utc_cnvt
   (omf_get_sn_time("CT-SURGSTART",sc.surg_case_id,sdr.stage_cd),1,126),"hh:mm;;Q"),
  surgery_stop_time = format(cclsql_utc_cnvt(omf_get_sn_time("CT-SURGSTOP",sc.surg_case_id,sdr
     .stage_cd),1,126),"hh:mm;;Q"),
  in_room_time = format(cclsql_utc_cnvt(omf_get_sn_time("CT-PATINRM",sc.surg_case_id,sdr.stage_cd),1,
    126),"hh:mm;;Q"), out_of_room_time = format(cclsql_utc_cnvt(omf_get_sn_time("CT-PATOUTRM",sc
     .surg_case_id,sdr.stage_cd),1,126),"hh:mm;;Q"), tot_surgery_minutes = sum(omf_get_sn_tim_dif(
    omf_get_sn_time("CT-SURGSTART",sc.surg_case_id,sdr.stage_cd),omf_get_sn_time("CT-SURGSTOP",sc
     .surg_case_id,sdr.stage_cd))),
  tot_pat_in_rm_minutes = sum(omf_get_sn_tim_dif(omf_get_sn_time("CT-PATINRM",sc.surg_case_id,sdr
     .stage_cd),omf_get_sn_time("CT-PATOUTRM",sc.surg_case_id,sdr.stage_cd))), case_add_on =
  IF (sc.add_on_ind=1) "Yes"
  ELSEIF (sc.add_on_ind=0) "No"
  ENDIF
  , scheduled_case_duration = sc.sched_dur
  FROM surgical_case sc,
   perioperative_document pd,
   surg_case_procedure scp1,
   surg_case_procedure scp2,
   sn_doc_ref sdr,
   encounter enc,
   surgical_delay sd,
   prsnl ps,
   prsnl_group pg,
   clinical_event ce
  PLAN (sc
   WHERE sc.surg_start_dt_tm BETWEEN cnvtdatetime( $S_START_DATE) AND cnvtdatetime( $S_END_DATE)
    AND operator(sc.surg_area_cd,ms_opr_var, $F_SURG_AREA))
   JOIN (pd
   WHERE pd.surg_case_id=sc.surg_case_id
    AND pd.rec_ver_id > 0
    AND pd.doc_term_reason_cd=0
    AND pd.doc_type_cd IN (
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=14258
     AND cdf_meaning="ORNURSE")))
   JOIN (scp1
   WHERE scp1.surg_case_id=sc.surg_case_id
    AND scp1.primary_proc_ind=1
    AND scp1.active_ind=1)
   JOIN (ps
   WHERE ps.person_id=scp1.primary_surgeon_id)
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(scp1.surg_specialty_id)) )
   JOIN (scp2
   WHERE scp2.surg_case_id=sc.surg_case_id
    AND scp2.sched_primary_ind=1
    AND ((scp2.active_ind=1
    AND scp2.sched_surg_proc_cd > 0) OR (scp2.active_ind=0
    AND scp2.sched_surg_proc_cd > 0
    AND scp2.surg_proc_cd > 0)) )
   JOIN (enc
   WHERE enc.encntr_id=sc.encntr_id)
   JOIN (sdr
   WHERE sdr.area_cd=sc.surg_area_cd
    AND sdr.doc_type_cd=pd.doc_type_cd)
   JOIN (sd
   WHERE (sd.surg_case_id= Outerjoin(sc.surg_case_id)) )
   JOIN (ce
   WHERE (ce.person_id= Outerjoin(sc.person_id))
    AND (ce.event_cd= Outerjoin(mf_sn_del_description))
    AND (ce.event_end_dt_tm>= Outerjoin(pd.create_dt_tm))
    AND (ce.event_end_dt_tm<= Outerjoin(cnvtdatetime(curdate,curtime)))
    AND (ce.valid_until_dt_tm>= Outerjoin(cnvtdatetime(curdate,curtime)))
    AND (ce.encntr_id= Outerjoin(sc.encntr_id))
    AND (((ce.result_status_cd= Outerjoin(mf_modified)) ) OR ((((ce.result_status_cd= Outerjoin(
   mf_alt_modified)) ) OR ((ce.result_status_cd= Outerjoin(mf_auth_res)) )) ))
    AND (ce.record_status_cd= Outerjoin(mf_active_rec))
    AND (ce.view_level= Outerjoin(1)) )
  GROUP BY ps.name_full_formatted, pg.prsnl_group_name, sc.surg_case_nbr_formatted,
   sc.sched_type_cd, sc.sched_start_dt_tm, format(cclsql_utc_cnvt(omf_get_sn_time("CT-PATINRM",sc
      .surg_case_id,sdr.stage_cd),1,126),"hh:mm;;Q"),
   format(cclsql_utc_cnvt(omf_get_sn_time("CT-PATOUTRM",sc.surg_case_id,sdr.stage_cd),1,126),
    "hh:mm;;Q"), sc.sched_op_loc_cd, enc.encntr_type_cd,
   sc.cancel_reason_cd, sd.delay_reason_cd, trim(pg.prsnl_group_name,3),
   format(cclsql_utc_cnvt(omf_get_sn_time("CT-SURGSTART",sc.surg_case_id,sdr.stage_cd),1,126),
    "hh:mm;;Q"), format(cclsql_utc_cnvt(omf_get_sn_time("CT-SURGSTOP",sc.surg_case_id,sdr.stage_cd),1,
     126),"hh:mm;;Q"), sc.add_on_ind,
   ce.result_val, sc.surg_case_id, sc.surg_start_dt_tm,
   sc.sched_dur, scp1.surg_proc_cd, sc.sched_surg_area_cd
  WITH ncounter, format, separator = " ",
   format(date,";;Q")
 ;end select
END GO
