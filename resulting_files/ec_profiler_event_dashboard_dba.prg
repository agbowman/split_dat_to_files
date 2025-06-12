CREATE PROGRAM ec_profiler_event_dashboard:dba
 PAINT
 SET width = 132
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE startdttm = dq8 WITH noconstant(0)
 DECLARE finishdttm = dq8 WITH noconstant(0)
 DECLARE stemp = vc WITH noconstant("")
 DECLARE deventid = f8 WITH noconstant(0.0)
 DECLARE idaysback = i4 WITH noconstant(0)
 DECLARE sparser = vc WITH noconstant("")
 DECLARE scrlf = vc WITH constant(char(10))
 DECLARE stab = vc WITH constant(char(9))
 DECLARE geteventid(dummy=null) = null
 DECLARE getdaysback(dummy=null) = null
 FREE RECORD measurements
 RECORD measurements(
   1 qual[*]
     2 name = vc
 )
 SET stat = alterlist(measurements->qual,67)
 SET measurements->qual[1].name = "Emergency Medicine / EMR (FirstNet)"
 SET measurements->qual[2].name = "Enhanced view framework within FirstNet (2007)"
 SET measurements->qual[3].name = "Genview within FirstNet"
 SET measurements->qual[4].name = ""
 SET measurements->qual[5].name = ""
 SET measurements->qual[6].name = "FirstNet Utilization"
 SET measurements->qual[7].name = "Tracking events (ED)"
 SET measurements->qual[8].name = "CPOE within the ED"
 SET measurements->qual[9].name = ""
 SET measurements->qual[10].name = ""
 SET measurements->qual[11].name = "Orders placed within the ED"
 SET measurements->qual[12].name = ""
 SET measurements->qual[13].name = ""
 SET measurements->qual[14].name = ""
 SET measurements->qual[15].name = ""
 SET measurements->qual[16].name = "Unified orders within FirstNet (2007)"
 SET measurements->qual[17].name = "Allergies documented within the ED"
 SET measurements->qual[18].name = "Interactive view documentation within the ED"
 SET measurements->qual[19].name = "PowerForms documentation within the ED"
 SET measurements->qual[20].name = "PowerNote ED"
 SET measurements->qual[21].name = "PowerNote ED Content (*2G)"
 SET measurements->qual[22].name = "MAR Summary within FirstNet"
 SET measurements->qual[23].name = "eMAR within the ED"
 SET measurements->qual[24].name = "Document home medications within the ED (via Med Profile)"
 SET measurements->qual[25].name =
 "Document home medications within the ED (via 2007 Medication List)"
 SET measurements->qual[26].name = ""
 SET measurements->qual[27].name = "Depart process within the ED"
 SET measurements->qual[28].name = ""
 SET measurements->qual[29].name = ""
 SET measurements->qual[30].name = ""
 SET measurements->qual[31].name = "Enhanced view framework within PowerChart (2007)"
 SET measurements->qual[32].name = "Genview within PowerChart"
 SET measurements->qual[33].name = "Inpatient Admits"
 SET measurements->qual[34].name = ""
 SET measurements->qual[35].name = ""
 SET measurements->qual[36].name = ""
 SET measurements->qual[37].name = "Orders placed within Inpatient population"
 SET measurements->qual[38].name = ""
 SET measurements->qual[39].name = ""
 SET measurements->qual[40].name = "Unified orders within PowerChart (2007)"
 SET measurements->qual[41].name = "Allergies documented within Inpatient population"
 SET measurements->qual[42].name = ""
 SET measurements->qual[43].name = "PowerForms documentation within IP population"
 SET measurements->qual[44].name = "PowerNote (*2G)"
 SET measurements->qual[45].name = "MAR Summary within IP population"
 SET measurements->qual[46].name = "eMAR within IP population"
 SET measurements->qual[47].name = "Document home medications within IP population (via Med Profile)"
 SET measurements->qual[48].name = ""
 SET measurements->qual[49].name = "Hospital-Wide Discharge"
 SET measurements->qual[50].name = ""
 SET measurements->qual[51].name = ""
 SET measurements->qual[52].name = ""
 SET measurements->qual[53].name = "Multi-patient Task List"
 SET measurements->qual[54].name = ""
 SET measurements->qual[55].name = ""
 SET measurements->qual[56].name = "Shift Assignment vs Staff Assignment Tab"
 SET measurements->qual[57].name = "Staff/Shift Assignment"
 SET measurements->qual[58].name = "Alerts on IP population"
 SET measurements->qual[59].name = "IV Drips/Titratables Charting (from Interactive View?)"
 SET measurements->qual[60].name = ""
 SET measurements->qual[61].name = ""
 SET measurements->qual[62].name = ""
 SET measurements->qual[63].name = ""
 SET measurements->qual[64].name = ""
 SET measurements->qual[65].name = ""
 SET measurements->qual[66].name = "Number of diagnosis entered by position"
 SET measurements->qual[67].name =
 "Allergies documented within Inpatient population: Freetext vs Codified"
#menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,11,132)
 CALL text(2,1,"Exp Center Profiler Dashboard",w)
 CALL text(5,20," 1)  Measurement Timers")
 CALL text(6,20," 2)  Result Viewer")
 CALL text(7,20," 3)  Exit")
 CALL text(24,2,"Select Option (1,2,3...):")
 CALL accept(24,28,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   GO TO timers
  OF 2:
   GO TO results
  OF 3:
   GO TO quit
  ELSE
   GO TO quit
 ENDCASE
#timers
 CALL geteventid(null)
 IF (deventid > 0.0)
  SELECT INTO "MINE"
   FROM ec_profiler_event e,
    ec_profiler_result r,
    ec_measurement m
   PLAN (e
    WHERE e.ec_profiler_event_id=deventid)
    JOIN (r
    WHERE r.ec_profiler_event_id=e.ec_profiler_event_id)
    JOIN (m
    WHERE m.ec_measurement_id=r.ec_measurement_id)
   ORDER BY r.ec_measurement_id, r.updt_dt_tm
   HEAD REPORT
    col 0, "Measurement Number", col 20,
    "Capability in Use", col 40, "Start Time",
    col 60, "Finish Time", col 80,
    "Time Elapsed", startdttm = cnvtdatetime(e.event_begin_dt_tm)
   HEAD r.ec_measurement_id
    finishdttm = cnvtdatetime(r.updt_dt_tm), row + 1, stemp = trim(cnvtstring(m.measurement_nbr),3),
    col 0, stemp, stemp = trim(cnvtstring(r.capability_in_use_ind),3),
    col 20, stemp, stemp = format(startdttm,"@SHORTDATETIME"),
    col 40, stemp, stemp = format(finishdttm,"@SHORTDATETIME"),
    col 60, stemp, stemp = format(datetimediff(startdttm,finishdttm),"HH:MM:SS;;Z"),
    col 80, stemp, startdttm = cnvtdatetime(r.updt_dt_tm)
   WITH nocounter
  ;end select
  GO TO menu
 ENDIF
#results
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,11,132)
 CALL text(2,1,"Get Profiler Results",w)
 CALL text(5,20," 1)  By Event Id")
 CALL text(6,20," 2)  By Number of Days Back")
 CALL text(7,20," 3)  Exit")
 CALL text(24,2,"Select Option (1,2,3...):")
 CALL accept(24,28,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(24,1)
 CASE (curaccept)
  OF 1:
   CALL geteventid(null)
   SET sparser = "e.ec_profiler_event_id = dEventId"
  OF 2:
   CALL getdaysback(null)
   SET sparser = "e.event_begin_dt_tm >= cnvtdatetime(curdate-iDaysBack, 000000)"
  OF 3:
   GO TO menu
  ELSE
   GO TO quit
 ENDCASE
 IF (sparser > "")
  SELECT INTO value("ec_profiler_event_dashboard.csv")
   FROM ec_profiler_event e,
    ec_profiler_result r,
    ec_profiler_result_detail d,
    ec_measurement m
   PLAN (e
    WHERE parser(sparser))
    JOIN (r
    WHERE r.ec_profiler_event_id=e.ec_profiler_event_id)
    JOIN (m
    WHERE m.ec_measurement_id=r.ec_measurement_id)
    JOIN (d
    WHERE d.ec_profiler_result_id=outerjoin(r.ec_profiler_result_id))
   ORDER BY e.event_begin_dt_tm, r.ec_measurement_id, r.facility_cd,
    r.position_cd, r.ec_profiler_result_id
   HEAD REPORT
    stemp = "Event Date,Measurement Number,Facility,Position,Capability In Use", row + 1, stemp
   HEAD r.ec_profiler_result_id
    stemp = build(trim(format(cnvtdatetime(e.event_begin_dt_tm),"@SHORTDATE"),3)), stemp = build(
     stemp,",",measurements->qual[m.measurement_nbr].name)
    IF (((r.facility_cd > 0.0) OR (r.position_cd > 0.0)) )
     stemp = build(stemp,",",trim(uar_get_code_display(r.facility_cd),3)), stemp = build(stemp,",",
      trim(uar_get_code_display(r.position_cd),3))
    ELSE
     stemp = build(stemp,",","Global Capability,")
    ENDIF
    stemp = build(stemp,",",r.capability_in_use_ind), row + 1, stemp
    IF (textlen(trim(d.detail_value_txt,3)) > 0)
     IF (d.detail_value_txt > "")
      stemp = ",,,Detail Name,Detail Value", row + 1, stemp
     ENDIF
    ENDIF
   DETAIL
    IF (textlen(trim(d.detail_value_txt,3)) > 0)
     IF (d.detail_value_txt > "")
      stemp = build(",,,",trim(d.detail_name,3),",",trim(replace(d.detail_value_txt,",",";"),3)), row
       + 1, stemp
     ENDIF
    ENDIF
   FOOT  r.ec_profiler_result_id
    IF (textlen(trim(d.detail_value_txt,3)) > 0)
     row + 1
    ENDIF
   WITH nocounter, pcformat('"',",",1), format = stream,
    maxcol = 10000, formfeed = none
  ;end select
 ENDIF
 GO TO menu
 SUBROUTINE geteventid(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(1,1,5,132)
   CALL text(2,4,"Event Id: ")
   CALL text(4,4,"Choose the profiler event id <HELP> is available")
   SET accept = nochange
   SET help =
   SELECT INTO "NL:"
    event_id = e.ec_profiler_event_id, event_date = e.event_begin_dt_tm
    FROM ec_profiler_event e
    WHERE e.ec_profiler_event_id > 0.0
    ORDER BY e.event_begin_dt_tm DESC
    WITH nocounter
   ;end select
   CALL accept(2,15,"9(11);d")
   SET help = off
   SET deventid = cnvtreal(curaccept)
 END ;Subroutine
 SUBROUTINE getdaysback(dummy)
   CALL video(n)
   CALL clear(1,1)
   CALL box(1,1,5,132)
   CALL text(2,4,"Days Back: ")
   CALL text(4,4,"Choose how many days back from the current date to get data from")
   SET accept = nochange
   CALL accept(2,15,"9(11);d")
   SET idaysback = cnvtint(curaccept)
 END ;Subroutine
#quit
END GO
