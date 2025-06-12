CREATE PROGRAM bhs_rpt_ppid_id:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "beg date" = "SYSDATE",
  "end date" = "SYSDATE",
  "unit" = 0
  WITH outdev, begdate, enddate,
  unit
 SELECT INTO  $OUTDEV
  pat.name_full_formatted, o.order_mnemonic, p.name_full_formatted,
  nurse_unit = uar_get_code_display(mad.nurse_unit_cd), position = uar_get_code_display(mad
   .position_cd), mad.verification_dt_tm
  FROM med_admin_event mad,
   orders o,
   prsnl p,
   person pat
  PLAN (mad
   WHERE (mad.nurse_unit_cd= $UNIT)
    AND ((mad.beg_dt_tm+ 0) BETWEEN cnvtdatetime( $BEGDATE) AND cnvtdatetime( $ENDDATE)))
   JOIN (o
   WHERE o.order_id=mad.order_id)
   JOIN (p
   WHERE p.person_id=mad.prsnl_id)
   JOIN (pat
   WHERE pat.person_id=o.person_id)
  WITH maxrec = 1000, format, separator = " ",
   time = 50
 ;end select
END GO
