CREATE PROGRAM bhs_ppid_stats_byfacility:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 673936.00,
  "Nurse unit(s):" = value(*)
  WITH outdev, ms_start_dt, ms_end_dt,
  mf_facility_cd, mf_nurse_unit_cd
 DECLARE ms_start_dt_tm = vc WITH protect, constant(concat(trim( $MS_START_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $MS_END_DT)," 23:59:59"))
 DECLARE ms_status = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_parser = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 IF (((trim( $MS_START_DT)="") OR (trim( $MS_END_DT)="")) )
  SET ms_status = "ERROR"
  SET ms_error = "Begin Date and End Date are required."
  GO TO exit_script
 ELSEIF (cnvtdatetime(ms_start_dt_tm) > cnvtdatetime(ms_end_dt_tm))
  SET ms_status = "ERROR"
  SET ms_error = "Begin Date must be less than End Date."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt = (aunit->l_cnt+ 1), stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->
   l_cnt].s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 SET ms_data_type = reflect(parameter(5,0))
 IF (substring(1,1,ms_data_type)="L")
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = cnvtstring(parameter(5,ml_cnt),20)
   IF (ml_cnt=1)
    SET ms_parser = concat(" mae.nurse_unit_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_parser = concat(ms_parser,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_parser = concat(ms_parser,")")
 ELSEIF (substring(1,2,ms_data_type)="C1")
  SET ms_parser = parameter(5,1)
  IF (trim(ms_parser)=char(42))
   SELECT INTO "nl:"
    FROM code_value cv,
     location_group lg1,
     location_group lg2
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.active_ind=1
      AND cv.data_status_cd=25
      AND ((cv.cdf_meaning="NURSEUNIT") OR (((cv.cdf_meaning="AMBULATORY"
      AND ((expand(ml_cnt2,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt2].s_unit_display_key))
      OR (cv.display_key IN ("BFMCONCOLOGY"))) ) OR (cv.cdf_meaning="ANCILSURG"
      AND cv.display IN ("MLH OR/PACU", "MLH Same Day"))) )) )
     JOIN (lg1
     WHERE lg1.child_loc_cd=cv.code_value
      AND lg1.root_loc_cd=0)
     JOIN (lg2
     WHERE lg2.child_loc_cd=lg1.parent_loc_cd
      AND lg2.root_loc_cd=0
      AND (lg2.parent_loc_cd= $MF_FACILITY_CD))
    ORDER BY cv.display
    HEAD REPORT
     ms_parser = " mae.nurse_unit_cd in ( ", ml_cnt = 0
    DETAIL
     ml_cnt = (ml_cnt+ 1)
     IF (ml_cnt=1)
      ms_parser = concat(ms_parser,trim(cnvtstring(cv.code_value)))
     ELSE
      ms_parser = concat(ms_parser,", ",trim(cnvtstring(cv.code_value)))
     ENDIF
    FOOT REPORT
     ms_parser = concat(ms_parser," )")
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET ms_parser = cnvtstring(parameter(5,1),20)
  SET ms_parser = concat(" mae.nurse_unit_cd = ",trim(ms_parser))
 ENDIF
 CALL echo(build2("ms_parser = ",ms_parser))
 SELECT INTO value( $OUTDEV)
  unit = uar_get_code_display(mae.nurse_unit_cd), date = format(mae.beg_dt_tm,"mm/dd/yyyy hh:mm"),
  nurse = pr.name_full_formatted,
  patient = p.name_full_formatted, med = o.ordered_as_mnemonic, more_info = o.simplified_display_line,
  pos_med_scan = mae.positive_med_ident_ind, event = uar_get_code_display(mae.event_type_cd),
  pos_patient_scan = mae.positive_patient_ident_ind
  FROM med_admin_event mae,
   orders o,
   person p,
   prsnl pr
  PLAN (mae
   WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(ms_start_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND mae.event_type_cd > 0
    AND parser(ms_parser))
   JOIN (o
   WHERE o.order_id=mae.order_id
    AND o.active_ind=1)
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=mae.prsnl_id
    AND pr.active_ind=1)
  ORDER BY unit, o.person_id
  WITH format, separator = " "
 ;end select
 IF (curqual=0)
  SET ms_status = "ERROR"
  SET ms_error = build2(ms_error,"No Data orders found for this date range: ",ms_start_dt_tm," - ",
   ms_end_dt_tm)
  GO TO exit_script
 ENDIF
 IF (ms_status != "ERROR")
  SET ms_status = "SUCCESS"
 ENDIF
#exit_script
 IF (ms_status != "SUCCESS")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    col 0, "{PS/792 0 translate 90 rotate/}", "{F/1}{CPI/7}",
    CALL print(calcpos(10,10)), "Pharmacy PPID Audit By Unit Report - BHS_PPID_STATS_BYFACILITY",
    "{F/1}{CPI/10}",
    CALL print(calcpos(10,30)), ms_error
   WITH dio = postscript, maxrow = 300, maxcol = 300
  ;end select
 ENDIF
END GO
