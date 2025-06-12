CREATE PROGRAM bhs_ma_daily_rad_orders
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start date:" = "SYSDATE",
  "End date:" = "SYSDATE"
  WITH outdev, bdate, edate
 EXECUTE bhs_sys_stand_subroutine
 DECLARE computer_tomography = f8 WITH protect, constant(633747.0)
 DECLARE mag_res_image = f8 WITH protect, constant(633750.0)
 DECLARE gen_diagnostic = f8 WITH protect, constant(633752.0)
 DECLARE carm_less = f8 WITH protect, constant(788204.0)
 DECLARE carm_greater = f8 WITH protect, constant(788206.0)
 DECLARE out_dev = vc WITH protect, noconstant("")
 DECLARE delcom = vc WITH protect, noconstant("")
 DECLARE len = i4 WITH protect, noconstant(0)
 DECLARE email_ind = i2 WITH protect, noconstant(0)
 DECLARE email_address = vc WITH protect, noconstant("")
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET out_dev = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MM_DD_YY_HHMM;;D"),".dat"))
  SET email_address = trim( $OUTDEV)
 ELSE
  SET email_ind = 0
  SET out_dev =  $1
 ENDIF
 SET beg_date_qual = cnvtdatetime( $BDATE)
 SET end_date_qual = cnvtdatetime( $EDATE)
 IF (( $BDATE="YESTERDAY")
  AND ( $BDATE="YESTERDAY"))
  CALL echo("OpsJob")
  SET beg_date_qual = cnvtdatetime((curdate - 1),0)
  SET end_date_qual = cnvtdatetime((curdate - 1),235959)
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
 IF (email_ind=0)
  CALL echo("Screen output")
  SELECT INTO value(out_dev)
   name = trim(p.name_full_formatted), mrn = ea.alias, acct = ea1.alias,
   orderable_name = trim(oc.description), date = format(o.orig_order_dt_tm,"MM-DD-YYYY HH:MM"),
   facility = uar_get_code_description(e.loc_facility_cd),
   status = uar_get_code_description(o.order_status_cd), o.order_id
   FROM orders o,
    order_catalog oc,
    person p,
    encounter e,
    encntr_alias ea,
    encntr_alias ea1
   PLAN (o
    WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
     AND o.orderable_type_flag IN (0, 1, 8, 10)
     AND ((o.order_status_cd+ 0)=2543.00)
     AND ((((o.catalog_cd+ 0) IN (carm_less, carm_greater))) OR (((o.activity_type_cd+ 0)=711)
     AND o.catalog_cd IN (
    (SELECT
     oc.catalog_cd
     FROM order_catalog oc
     WHERE ((oc.catalog_cd+ 0)=o.catalog_cd)
      AND oc.activity_type_cd=o.activity_type_cd
      AND oc.activity_subtype_cd IN (computer_tomography, mag_res_image, gen_diagnostic))))) )
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (ea
    WHERE ea.encntr_id=o.encntr_id
     AND ((ea.encntr_alias_type_cd+ 0)=1079.00))
    JOIN (ea1
    WHERE ea1.encntr_id=o.encntr_id
     AND ((ea1.encntr_alias_type_cd+ 0)=1077.00))
   WITH nocounter, format
  ;end select
 ELSE
  CALL echo("Email output")
  SELECT INTO value(out_dev)
   name = trim(p.name_full_formatted), mrn = ea.alias, acct = ea1.alias,
   orderable_name = trim(oc.description), date = format(o.orig_order_dt_tm,"MM-DD-YYYY HH:MM"),
   facility = uar_get_code_description(e.loc_facility_cd),
   status = uar_get_code_description(o.order_status_cd), o.order_id
   FROM orders o,
    order_catalog oc,
    person p,
    encounter e,
    encntr_alias ea,
    encntr_alias ea1
   PLAN (o
    WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual)
     AND o.orderable_type_flag IN (0, 1, 8, 10)
     AND ((o.order_status_cd+ 0)=2543.00)
     AND ((((o.catalog_cd+ 0) IN (788204, 788206))) OR (((o.activity_type_cd+ 0)=711)
     AND o.catalog_cd IN (
    (SELECT
     oc.catalog_cd
     FROM order_catalog oc
     WHERE ((oc.catalog_cd+ 0)=o.catalog_cd)
      AND oc.activity_type_cd=o.activity_type_cd
      AND oc.activity_subtype_cd IN (computer_tomography, mag_res_image, gen_diagnostic))))) )
    JOIN (oc
    WHERE oc.catalog_cd=o.catalog_cd)
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (ea
    WHERE ea.encntr_id=o.encntr_id
     AND ((ea.encntr_alias_type_cd+ 0)=1079.00))
    JOIN (ea1
    WHERE ea1.encntr_id=o.encntr_id
     AND ((ea1.encntr_alias_type_cd+ 0)=1077.00))
   WITH nocounter, format, pcformat('"',",")
  ;end select
  IF (curqual=0)
   SELECT INTO value(out_dev)
    FROM dummyt
    HEAD REPORT
     "No data found today"
   ;end select
  ENDIF
  CALL echo("Processing email")
  SET filename_in = out_dev
  SET filename_out = trim(concat("Daily_rad_ord_",format(cnvtdatetime(beg_date_qual),"MMDDYYYY;;D"),
    ".csv"))
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL echo(dclcom)
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out,email_address,concat(trim(curprog),
    " - Baystate Medical Center Charge Audit"),1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = out_dev, msg2 = "The file was emailed to:", msg3 = email_address,
    col 0, "{PS/792 0 translate 90 rotate/}", y_pos = 18,
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))),
    msg1, row + 2, msg2,
    row + 2, msg3
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
#exit_prg
END GO
