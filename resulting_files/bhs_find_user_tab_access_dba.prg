CREATE PROGRAM bhs_find_user_tab_access:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter User's Last Name" = "",
  "Select User's Full Name or Any(*)" = 0,
  "Search Start Time" = "SYSDATE",
  "Search End Time" = "SYSDATE",
  "Type of Chart Access" = value(670612.00,659.00,660.00)
  WITH outdev, name, person_name,
  beg_dt_tm, end_dt_tm, chart_access_type
 IF (datetimediff(cnvtdatetime( $END_DT_TM),cnvtdatetime( $BEG_DT_TM)) >= 7.5)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 7 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(cnvtdatetime( $END_DT_TM),cnvtdatetime( $BEG_DT_TM)) < 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is Negative  .", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{f/1}{cpi/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 SELECT INTO  $OUTDEV
  users_name = pr.name_full_formatted, login_name = pr.username, ppa.prsnl_id,
  ppa.computer_name, patient_name = per.name_full_formatted, patient_id = ppa.person_id,
  access_date_time = format(ppa.ppa_first_dt_tm,";;q"), access_type = uar_get_code_display(ppa
   .ppa_type_cd), tab_accessed = ppa.view_caption,
  p_ppr_disp = uar_get_code_display(ppa.ppr_cd), ppa.updt_applctx
  FROM person_prsnl_activity ppa,
   prsnl pr,
   person per
  PLAN (ppa
   WHERE ((ppa.prsnl_id+ 0)= $PERSON_NAME)
    AND ppa.ppa_first_dt_tm BETWEEN cnvtdatetime( $BEG_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND (ppa.ppa_type_cd= $CHART_ACCESS_TYPE))
   JOIN (pr
   WHERE pr.person_id=ppa.prsnl_id)
   JOIN (per
   WHERE per.person_id=ppa.person_id)
  ORDER BY pr.name_full_formatted, ppa.prsnl_id, per.name_full_formatted,
   patient_id
  WITH nocounter, separator = " ", format,
   maxrec = 1000, time = 120
 ;end select
 IF (curqual <= 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "No Data.", msg2 = "For this selection", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{f/1}{cpi/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
#exit_prg
END GO
