CREATE PROGRAM bhs_rx_av_audit_by_orderable:dba
 PROMPT
  "* Output to MINE (mine): " = mine,
  "* Start Date, mmddyy (today): " = "curdate",
  "* Start Time, hhmm (0000): " = "0000",
  "* End Date, mmddyy (today): " = "curdate",
  "* End Time, hhmm (2359): " = "2359",
  "* Facility Name: " = "ALL",
  "Orderable Name: " = "ALL"
 SET modify = predeclare
 DECLARE startdt = vc WITH protect, noconstant("")
 DECLARE starttm = vc WITH protect, noconstant("")
 DECLARE enddt = vc WITH protect, noconstant("")
 DECLARE endtm = vc WITH protect, noconstant("")
 DECLARE facility = vc WITH protect, noconstant("")
 DECLARE orderablename = vc WITH protect, noconstant("")
 DECLARE dtotalordersav = f8 WITH protect, noconstant(0.0)
 DECLARE dtotalordersaps = f8 WITH protect, noconstant(0.0)
 DECLARE dtotalordersplaced = f8 WITH protect, noconstant(0.0)
 DECLARE davfailaps = f8 WITH protect, noconstant(0.0)
 DECLARE davfailalertcheck = f8 WITH protect, noconstant(0.0)
 DECLARE davfailpriv = f8 WITH protect, noconstant(0.0)
 DECLARE davfailinvaliddet = f8 WITH protect, noconstant(0.0)
 DECLARE davfailmissingdet = f8 WITH protect, noconstant(0.0)
 DECLARE dfacilitycd = f8 WITH protect, noconstant(0.0)
 DECLARE scriptstatus = c1 WITH protect, noconstant("F")
 DECLARE dtemppct = f8 WITH protect, noconstant(0.0)
 DECLARE stemppct = c3 WITH protect, noconstant(fillstring(3," "))
 DECLARE startdttm = f8 WITH protect, noconstant(0.0)
 DECLARE enddttm = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE msg = vc WITH protect, noconstant("")
 DECLARE cdashline = vc WITH protect, constant(fillstring(117,"-"))
 DECLARE csuccess = c1 WITH protect, constant("S")
 DECLARE cfail = c1 WITH protect, constant("F")
 DECLARE caps_success = i4 WITH protect, constant(2)
 DECLARE caps_fail = f8 WITH protect, noconstant(0.0)
 DECLARE cfail_ic = f8 WITH protect, noconstant(0.0)
 DECLARE cfail_disc = f8 WITH protect, noconstant(0.0)
 DECLARE cinvalid_det = f8 WITH protect, noconstant(0.0)
 DECLARE cdet_missing = f8 WITH protect, noconstant(0.0)
 DECLARE cav_priv = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(254710,"APS_FAILURE",1,caps_fail)
 SET stat = uar_get_meaning_by_codeset(254710,"FAIL_IC",1,cfail_ic)
 SET stat = uar_get_meaning_by_codeset(254710,"FAIL_DISCERN",1,cfail_disc)
 SET stat = uar_get_meaning_by_codeset(254710,"INVALID_DET",1,cinvalid_det)
 SET stat = uar_get_meaning_by_codeset(254710,"REQ_DET_MISS",1,cdet_missing)
 SET stat = uar_get_meaning_by_codeset(254710,"AV_PRIV_OFF",1,cav_priv)
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 ) WITH private
 DECLARE errcode = i4 WITH private, noconstant(0)
 DECLARE errcnt = i4 WITH private, noconstant(0)
 DECLARE errmsg = c132 WITH private, noconstant(fillstring(132," "))
 DECLARE scripterrormsg = c100 WITH protect, noconstant(fillstring(100," "))
 SET startdt =  $2
 SET starttm =  $3
 SET enddt =  $4
 SET endtm =  $5
 SET facility =  $6
 SET orderablename =  $7
 IF (trim(cnvtupper(startdt))="CURDATE")
  SET startdt = format(curdate,"mmddyy;;d")
 ELSEIF (((size(startdt) != 6) OR ( NOT (isnumeric(startdt)))) )
  SET scripterrormsg = "Start date must be in mmddyy format"
  GO TO exit_report
 ELSEIF (((cnvtint(substring(1,2,startdt)) > 12) OR (cnvtint(substring(1,2,startdt)) <= 0)) )
  SET scripterrormsg = "Start month must be 01 through 12"
  GO TO exit_report
 ELSEIF (((cnvtint(substring(3,2,startdt)) > 31) OR (cnvtint(substring(3,2,startdt)) <= 0)) )
  SET scripterrormsg = "Start day must be 01 through 31"
  GO TO exit_report
 ENDIF
 IF (((size(starttm) != 4) OR ( NOT (isnumeric(starttm)))) )
  SET scripterrormsg = "Start time must be in hhmm format"
  GO TO exit_report
 ELSEIF (cnvtint(substring(1,2,starttm)) > 23)
  SET scripterrormsg = "Start hour must be < 24"
  GO TO exit_report
 ELSEIF (cnvtint(substring(3,2,starttm)) > 59)
  SET scripterrormsg = "Start minute must be < 60"
  GO TO exit_report
 ENDIF
 IF (trim(cnvtupper(enddt))="CURDATE")
  SET enddt = format(curdate,"mmddyy;;d")
 ELSEIF (((size(enddt) != 6) OR ( NOT (isnumeric(enddt)))) )
  SET scripterrormsg = "End date must be in mmddyy format"
  GO TO exit_report
 ELSEIF (((cnvtint(substring(1,2,enddt)) > 12) OR (cnvtint(substring(1,2,enddt)) <= 0)) )
  SET scripterrormsg = "End month must be 01 through 12"
  GO TO exit_report
 ELSEIF (((cnvtint(substring(3,2,enddt)) > 31) OR (cnvtint(substring(3,2,enddt)) <= 0)) )
  SET scripterrormsg = "End day must be 01 through 31"
  GO TO exit_report
 ENDIF
 IF (((size(endtm) != 4) OR ( NOT (isnumeric(endtm)))) )
  SET scripterrormsg = "End time must be in hhmm format"
  GO TO exit_report
 ELSEIF (cnvtint(substring(1,2,endtm)) > 23)
  SET scripterrormsg = "End hour must be < 24"
  GO TO exit_report
 ELSEIF (cnvtint(substring(3,2,endtm)) > 59)
  SET scripterrormsg = "End minute must be < 60"
  GO TO exit_report
 ENDIF
 SET startdttm = cnvtdatetime(cnvtdate(startdt,"MMDDYY"),cnvtint(starttm))
 SET enddttm = cnvtdatetime(cnvtdate(enddt,"MMDDYY"),cnvtint(endtm))
 IF (facility != "ALL")
  SELECT INTO "NL:"
   cv.code_set, cv.code_value, cv.display
   FROM code_value cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
   DETAIL
    IF (((cv.display=patstring(cnvtupper(facility))) OR (cv.display_key=patstring(cnvtupper(facility)
     ))) )
     dfacilitycd = cv.code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT
  IF (trim(cnvtupper(orderablename)) != "ALL")
   FROM rx_auto_verify_audit ra,
    order_ingredient oi,
    order_catalog_synonym ocs,
    orders o,
    encounter ed
   PLAN (ra
    WHERE ra.updt_dt_tm >= cnvtdatetime(cnvtdate(startdt,"MMDDYY"),cnvtint(starttm))
     AND ra.updt_dt_tm <= cnvtdatetime(cnvtdate(enddt,"MMDDYY"),cnvtint(endtm)))
    JOIN (oi
    WHERE oi.order_id=ra.order_id
     AND oi.action_sequence=ra.action_sequence)
    JOIN (o
    WHERE o.order_id=oi.order_id
     AND o.orig_ord_as_flag=0)
    JOIN (ed
    WHERE ed.person_id=o.person_id
     AND ed.encntr_id=o.encntr_id
     AND ((facility="ALL") OR (facility != "ALL"
     AND dfacilitycd=ed.loc_facility_cd)) )
    JOIN (ocs
    WHERE ocs.mnemonic_key_cap=trim(cnvtupper(orderablename))
     AND ocs.catalog_cd=o.catalog_cd)
  ELSE
   FROM rx_auto_verify_audit ra,
    orders o,
    encounter ed
   PLAN (ra
    WHERE ra.updt_dt_tm >= cnvtdatetime(cnvtdate(startdt,"MMDDYY"),cnvtint(starttm))
     AND ra.updt_dt_tm <= cnvtdatetime(cnvtdate(enddt,"MMDDYY"),cnvtint(endtm)))
    JOIN (o
    WHERE o.order_id=ra.order_id
     AND o.orig_ord_as_flag=0)
    JOIN (ed
    WHERE ed.person_id=o.person_id
     AND ed.encntr_id=o.encntr_id
     AND ((facility="ALL") OR (facility != "ALL"
     AND dfacilitycd=ed.loc_facility_cd)) )
  ENDIF
  INTO  $1
  HEAD REPORT
   row 1, cdashline, row + 1,
   msg = "Auto-Verification Audit Summary Report",
   CALL center(msg,1,117)
   IF (facility="ALL")
    msg = "All Facilities"
   ELSE
    msg = uar_get_code_display(dfacilitycd)
   ENDIF
   row + 1,
   CALL center(msg,1,117), row + 1,
   col 0, cdashline, row + 1
  DETAIL
   dtotalordersplaced = (dtotalordersplaced+ 1)
   IF (ra.auto_verify_fail_reason_cd=0)
    dtotalordersav = (dtotalordersav+ 1)
   ELSE
    CASE (ra.auto_verify_fail_reason_cd)
     OF caps_fail:
      davfailaps = (davfailaps+ 1)
     OF cfail_ic:
      davfailalertcheck = (davfailalertcheck+ 1)
     OF cfail_disc:
      davfailalertcheck = (davfailalertcheck+ 1)
     OF cinvalid_det:
      davfailinvaliddet = (davfailinvaliddet+ 1)
     OF cdet_missing:
      davfailmissingdet = (davfailmissingdet+ 1)
     OF cav_priv:
      davfailpriv = (davfailpriv+ 1)
    ENDCASE
   ENDIF
  FOOT REPORT
   msg = concat("Date Range: ",format(startdttm,"@LONGDATETIME")," - ",format(enddttm,"@LONGDATETIME"
     )), row + 2, col 1,
   msg
   IF (trim(cnvtupper(orderablename)) != "ALL")
    msg = concat("Order Analysis for ",trim(cnvtupper(orderablename))), row + 2, col 1,
    msg
   ELSE
    msg = "Order Analysis", row + 2, col 1,
    msg
   ENDIF
   msg = build("1. Total Pharmacy Orders Auto-verified: ","  ",cnvtint(dtotalordersav)), row + 1, col
    1,
   msg, msg = build("2. Total Pharmacy Orders Placed for Verification: ","  ",cnvtint(
     dtotalordersplaced)), row + 1,
   col 1, msg, dtemppct = ((dtotalordersav/ dtotalordersplaced) * 100),
   stemppct = build(cnvtint(dtemppct),"%"), msg = concat(
    "3. Overall % of Pharmacy Orders Auto-verified: ",stemppct), row + 1,
   col 1, msg, msg = build("4. Total pharmacy orders failed due to product assignment:  ",cnvtint(
     davfailaps)),
   row + 2, col 1, msg,
   dtemppct = ((davfailaps/ dtotalordersplaced) * 100), stemppct = build(cnvtint(dtemppct),"%"), msg
    = concat("5. Percentage: ",stemppct),
   row + 1, col 8, msg,
   col 29,
   " (This number elevated would indicate orders that are failing auto-verification due to failure",
   row + 1,
   col 8, "of auto-product assignment.)", msg = build(
    "6. Total pharmacy orders failed due to clinical checking parameters: ","  ",cnvtint(
     davfailalertcheck)),
   row + 2, col 1, msg,
   dtemppct = ((davfailalertcheck/ dtotalordersplaced) * 100), stemppct = build(cnvtint(dtemppct),
    "%"), msg = concat("7. Percentage: ",stemppct),
   row + 1, col 8, msg,
   col 29, " (This number elevated would indicate that further evaluation of Multum customization or",
   row + 1,
   col 8, "ordering practices may need to be evaluated.)", msg = build(
    "8. Total pharmacy orders failed due to provider privileges: ","  ",cnvtint(davfailpriv)),
   row + 2, col 1, msg,
   dtemppct = ((davfailpriv/ dtotalordersplaced) * 100), stemppct = build(cnvtint(dtemppct),"%"),
   msg = concat("9. Percentage: ",stemppct),
   row + 1, col 8, msg,
   col 29,
   " (This number elevated would indicate that additional providers may need to be granted the", row
    + 1,
   col 8, "auto-verification privilege.)", msg = build(
    "10. Total pharmacy orders failed due to missing product details: ","  ",cnvtint(
     davfailinvaliddet)),
   row + 2, col 1, msg,
   dtemppct = ((davfailinvaliddet/ dtotalordersplaced) * 100), stemppct = build(cnvtint(dtemppct),
    "%"), msg = concat("11. Percentage: ",stemppct),
   row + 1, col 8, msg,
   col 31, " (This number elevated means that the order failed due to missing product", row + 1,
   col 8, "defaults for price schedule and dispense category.)", msg = build(
    "12. Total pharmacy orders failed due to format build errors: ","  ",cnvtint(davfailmissingdet)),
   row + 2, col 1, msg,
   dtemppct = ((davfailmissingdet/ dtotalordersplaced) * 100), stemppct = build(cnvtint(dtemppct),
    "%"), msg = concat("13. Percentage: ",stemppct),
   row + 1, col 8, msg,
   col 29, " (This would be errors due to incorrect or invalid format build.)"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET scripterrormsg = "No results found for this search criteria."
  GO TO exit_report
 ELSE
  SET scriptstatus = csuccess
  GO TO exit_report
 ENDIF
#exit_report
 WHILE (errcode != 0)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,(errcnt+ 4))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
   SET failuretype = cfail
 ENDWHILE
 IF (errcnt > 0)
  SET stat = alterlist(errors->err,errcnt)
 ENDIF
 IF (scriptstatus != csuccess)
  SELECT INTO  $1
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD REPORT
    row 1, cdashline, row + 1,
    msg = "Auto-Verification Audit Summary Report",
    CALL center(msg,1,117)
    IF (facility="ALL")
     msg = "All Facilities"
    ELSE
     msg = build(uar_get_code_display(dfacilitycd))
    ENDIF
    row + 1,
    CALL center(msg,1,117), row + 1,
    col 0, cdashline, row + 1,
    msg = concat("Date Range: ",format(startdttm,"@LONGDATETIME")," - ",format(enddttm,
      "@LONGDATETIME")), row + 2, col 1,
    msg
   DETAIL
    col 0, scripterrormsg, row + 1
   FOOT REPORT
    x = 0
   WITH nocounter
  ;end select
 ENDIF
 SET modify = nopredeclare
 SET mod_date = "June 26, 2003"
 SET last_mod = "000"
END GO
