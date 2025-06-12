CREATE PROGRAM bhs_ords_verify_stat:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "begin date:" = "CURDATE",
  "End date:" = "CURDATE",
  "Orderable (*):" = ""
  WITH outdev, bdate, edate,
  orderable
 SET beg_date_qual = cnvtdatetime(build( $BDATE,"00:00:00"))
 SET end_date_qual = cnvtdatetime(build( $EDATE,"235959"))
 IF (datetimediff(end_date_qual,beg_date_qual) > 31)
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
  GO TO exit_program
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
  GO TO exit_program
 ENDIF
 SET txtlen = 0
 SET txtlen = textlen(trim( $ORDERABLE,3))
 CALL echo(format(cnvtdatetime(beg_date_qual),";;q"))
 CALL echo(format(cnvtdatetime(end_date_qual),";;q"))
 SELECT INTO  $OUTDEV
  o.order_id, oc_description = oc.description, o.ordered_as_mnemonic,
  r.updt_dt_tm, verifyreason =
  IF (r.auto_verify_fail_reason_cd > 0) uar_get_code_display(r.auto_verify_fail_reason_cd)
  ELSE "Verified"
  ENDIF
  FROM rx_auto_verify_audit r,
   orders o,
   order_catalog oc
  PLAN (r
   WHERE r.updt_dt_tm BETWEEN cnvtdatetime(beg_date_qual) AND cnvtdatetime(end_date_qual))
   JOIN (o
   WHERE ((o.order_id=r.order_id
    AND txtlen > 0
    AND cnvtupper(o.ordered_as_mnemonic)=value(cnvtupper( $ORDERABLE))) OR (o.order_id=r.order_id
    AND txtlen=0)) )
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
  ORDER BY verifyreason
  WITH format, seperator = " ", format(date,";;q")
 ;end select
#exit_program
END GO
