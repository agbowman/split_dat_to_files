CREATE PROGRAM bhs_bed_mgmttest:dba
 PROMPT
  "Defaut Prompt for any error messages:" = "MINE",
  "Beginning Date:" = "BOM",
  "End Date:" = "EOM",
  "Select Facility" = 673936,
  "Select Nursing Unit or Any(*) for All :" = 0,
  "Type in email address or leave default for report preview:" = "Report_Preview"
  WITH outdev, bdate, edate,
  fname, nunit, email
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE obs = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"OBSERVATION")), protect
 DECLARE inpatient = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"INPATIENT")), protect
 DECLARE dischargepatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"DISCHARGEPATIENT")
  ), protect
 DECLARE rec_size = i4
 DECLARE i_disp = c10
 SET beg_date_qual = cnvtdatetime( $BDATE)
 SET end_date_qual = cnvtdatetime( $EDATE)
 IF (cnvtupper( $BDATE) IN ("BEGOFPREVMONTH", "BOM"))
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 28),0000),"M","B","B")
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 28),235959),"M","E","E")
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) > 31)
  CALL echo("Date range > 31")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is larger than 31 days.", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_prg
 ELSEIF (datetimediff(end_date_qual,beg_date_qual) < 0)
  CALL echo("Date range < 0")
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Your date range is incorrect", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08
  ;end select
  GO TO exit_prg
 ENDIF
 DECLARE any_loc_ind = c1 WITH constant(substring(1,1,reflect(parameter(5,0)))), public
 CALL echo(build("any_loc_ind:",any_loc_ind))
 IF (any_loc_ind="C")
  SET loc_where = build2(" ehx.loc_facility_cd + 0 = ", $FNAME)
 ELSEIF (( $5 > 0))
  SET loc_where = build2(" ehx.loc_nurse_unit_cd + 0 = ", $NUNIT)
 ELSE
  SET loc_where = build2(" ehx.loc_facility_cd + 0 = ", $FNAME)
 ENDIF
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 4
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "bhs_bed_mgmt"
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
 ENDIF
 CALL echo(build("LocWhere:",loc_where))
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 eid = c20
     2 pid = c20
     2 uname = vc
     2 pname = vc
     2 admit = vc
     2 actnum = vc
     2 dischord = vc
     2 dischpat = vc
     2 tat = c10
     2 tat_display = c10
     2 disch_dt_tm = dq8
 )
 SELECT INTO  $OUTDEV
  e.encntr_id, tat = datetimediff(e.disch_dt_tm,o.orig_order_dt_tm,4), unit = e.loc_nurse_unit_cd,
  unitd = uar_get_code_display(e.loc_nurse_unit_cd), loc = e.location_cd, locd = uar_get_code_display
  (e.location_cd),
  hxunit = ehx.loc_nurse_unit_cd, hxunitd = uar_get_code_display(ehx.loc_nurse_unit_cd), e
  .disch_dt_tm
  FROM encounter e,
   orders o,
   encntr_loc_hist ehx
  PLAN (e
   WHERE e.encntr_id=41969606.00)
   JOIN (ehx
   WHERE ehx.encntr_id=e.encntr_id)
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd=dischargepatient_var)
  ORDER BY ehx.encntr_id, 0
  WITH time = 600, format, separator = " "
 ;end select
END GO
