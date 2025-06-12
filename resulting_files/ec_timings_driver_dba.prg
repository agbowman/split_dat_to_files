CREATE PROGRAM ec_timings_driver:dba
 PROMPT
  "Enter Output Directory                         : " = "",
  "Enter min lookback days                        : " = 5,
  "Enter max lookback days                        : " = 30,
  "Filter patients by location (1=ED, 2=Inpatient): " = 2,
  "Enter position_cd (ALL for all positions)      : " = "ALL",
  "Enter number of encounters to run              : " = 5
  WITH outdev, minlookbackdays, maxlookbackdays,
  locationfilter, positioncd, encntriter
 DECLARE soutput = vc WITH noconstant(" ")
 FREE RECORD driverrec
 RECORD driverrec(
   1 output_device = vc
   1 min_lookback_days = i2
   1 max_lookback_days = i2
   1 pt_location_filter = i2
   1 position_cd = f8
   1 encntr_iter = i2
 )
 RECORD recreply(
   1 patient[*]
     2 encntr_id = f8
 )
 FREE RECORD tabposreply
 RECORD tabposreply(
   1 qualcnt = i4
   1 qual[*]
     2 tab_name = vc
     2 poscnt = i4
     2 positions[*]
       3 position_cd = f8
       3 position = vc
       3 physiciancnt = i4
       3 usercnt = i4
     2 scriptcnt = i4
     2 scripts[*]
       3 script_name = vc
 )
 SET driverrec->output_device =  $OUTDEV
 SET driverrec->min_lookback_days = cnvtint( $MINLOOKBACKDAYS)
 SET driverrec->max_lookback_days = cnvtint( $MAXLOOKBACKDAYS)
 SET driverrec->pt_location_filter = cnvtint( $LOCATIONFILTER)
 IF (trim(cnvtupper( $POSITIONCD))="ALL")
  SET driverrec->position_cd = - (1.0)
 ELSE
  SET driverrec->position_cd = cnvtreal( $POSITIONCD)
 ENDIF
 SET driverrec->encntr_iter = cnvtint( $ENCNTRITER)
 EXECUTE ec_encntr_list driverrec->output_device, driverrec->min_lookback_days, driverrec->
 max_lookback_days,
 driverrec->pt_location_filter
 CALL echorecord(recreply)
 DECLARE encntrcnt = i2 WITH noconstant(0), protect
 IF ((driverrec->encntr_iter > size(recreply->patient,5)))
  SET driverrec->encntr_iter = size(recreply->patient,5)
 ENDIF
 IF ((driverrec->encntr_iter > 0))
  FOR (encntrcnt = 1 TO driverrec->encntr_iter)
    CALL echo("Getting Timings for Genviews.")
    SET trace = nocost
    SET message = noinformation
    SET trace = nocallecho
    EXECUTE ec_get_genview_timings driverrec->output_device, recreply->patient[encntrcnt].encntr_id,
    driverrec->position_cd
    SET trace = callecho
    IF ((driverrec->position_cd != 0.0))
     CALL echo("Getting Timings for Clinical Notes.")
     SET trace = nocallecho
     EXECUTE ec_get_clinnote_timings driverrec->output_device, recreply->patient[encntrcnt].encntr_id
     SET trace = callecho
     CALL echo("Getting Timings for Form Smart Templates.")
     SET trace = nocallecho
     SET trace = cost
     SET message = information
     SET trace = callecho
    ELSE
     GO TO exit_script
    ENDIF
  ENDFOR
  IF ((tabposreply->qualcnt > 0))
   SELECT INTO value(concat( $OUTDEV,"ec_tab_positions.csv"))
    FROM (dummyt d  WITH seq = tabposreply->qualcnt),
     dummyt d2
    PLAN (d
     WHERE (tabposreply->qual[d.seq].tab_name != "")
      AND maxrec(d2,tabposreply->qual[d.seq].poscnt))
     JOIN (d2)
    HEAD REPORT
     soutput = "Tab Name,Position Cd,Position,Physician Cnt,User Cnt", col 0, soutput
    DETAIL
     soutput = build('"',tabposreply->qual[d.seq].tab_name,'","',tabposreply->qual[d.seq].positions[
      d2.seq].position_cd,'","',
      tabposreply->qual[d.seq].positions[d2.seq].position,'","',tabposreply->qual[d.seq].positions[d2
      .seq].physiciancnt,'","',tabposreply->qual[d.seq].positions[d2.seq].usercnt,
      '"'), row + 1, soutput
    WITH pcformat('"',",",1), format = stream, nocounter,
     formfeed = none
   ;end select
   SELECT INTO value(concat( $OUTDEV,"ec_program_tabs.csv"))
    FROM (dummyt d  WITH seq = tabposreply->qualcnt),
     dummyt d2
    PLAN (d
     WHERE (tabposreply->qual[d.seq].tab_name != "")
      AND maxrec(d2,tabposreply->qual[d.seq].scriptcnt))
     JOIN (d2)
    HEAD REPORT
     soutput = "Tab Name,Program Name", col 0, soutput
    DETAIL
     soutput = build('"',tabposreply->qual[d.seq].tab_name,'","',tabposreply->qual[d.seq].scripts[d2
      .seq].script_name,'"'), row + 1, soutput
    WITH pcformat('"',",",1), format = stream, nocounter,
     formfeed = none
   ;end select
  ENDIF
 ELSE
  CALL echo("No encounters found")
 ENDIF
#exit_script
 CALL echorecord(driverrec)
END GO
