CREATE PROGRAM ec_profiler_audit:dba
 PAINT
#start
 CALL clear(1,1)
 CALL video(l)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"CUP Audit")
 CALL text(5,5,"1. View by Event")
 CALL text(6,5,"2. View by Measurement Nbr")
 CALL text(20,10,"Select (0 to Exit)")
 CALL accept(20,5,"9")
 SET mainview = curaccept
 CASE (mainview)
  OF 0:
   GO TO end_program
  OF 1:
   CALL clear(1,1)
   CALL box(1,1,22,80)
   CALL line(3,1,80,xhor)
   CALL text(2,3,"CUP Audit (View by Event)")
   FREE RECORD events
   RECORD events(
     1 event_cnt = i2
     1 events[*]
       2 ec_profiler_event_id = f8
   )
   SELECT INTO "nl"
    FROM ec_profiler_event epe
    ORDER BY cnvtdatetime(epe.event_begin_dt_tm) DESC
    DETAIL
     IF ((events->event_cnt < 9))
      eventcnt = (events->event_cnt+ 1), events->event_cnt = eventcnt, stat = alterlist(events->
       events,eventcnt),
      events->events[eventcnt].ec_profiler_event_id = epe.ec_profiler_event_id, rowtoprint = (4+
      eventcnt),
      CALL text(rowtoprint,5,build2(trim(cnvtstring(eventcnt)),". ",format(epe.event_begin_dt_tm,
        "MM/DD/YYYY hh:mm:ss;;Q")," | ",format(epe.event_end_dt_tm,"MM/DD/YYYY hh:mm:ss;;Q"),
       " | ",trim(cnvtstring(epe.ec_profiler_event_id))))
     ENDIF
    WITH nocounter
   ;end select
   CALL text(20,10,"Select (0 to Go Back)")
   CALL accept(20,5,"9")
   IF (curaccept=0)
    GO TO start
   ENDIF
   SELECT INTO "MINE"
    em.measurement_nbr, epr.facility_cd, facility = uar_get_code_display(epr.facility_cd),
    epr.position_cd, position = uar_get_code_display(epr.position_cd), result =
    IF (epr.capability_in_use_ind=1) "Yes"
    ELSE "No"
    ENDIF
    ,
    name = substring(1,30,eprd.detail_name), val = substring(1,30,eprd.detail_value_txt)
    FROM ec_profiler_result epr,
     ec_measurement em,
     dummyt d,
     ec_profiler_result_detail eprd
    PLAN (epr
     WHERE (epr.ec_profiler_event_id=events->events[curaccept].ec_profiler_event_id))
     JOIN (em
     WHERE em.ec_measurement_id=epr.ec_measurement_id)
     JOIN (d)
     JOIN (eprd
     WHERE eprd.ec_profiler_result_id=epr.ec_profiler_result_id)
    ORDER BY em.measurement_nbr, facility, position
    WITH outerjoin = d, nocounter
   ;end select
  OF 2:
   CALL clear(1,1)
   CALL box(1,1,22,80)
   CALL line(3,1,80,xhor)
   CALL text(2,3,"CUP Audit (View by Measurement Nbr)")
   CALL text(20,10,"Enter Measurement Nbr (0 to Go Back)")
   CALL accept(20,5,"9(3)")
   IF (curaccept=0)
    GO TO start
   ENDIF
   SELECT INTO "MINE"
    event = epe.ec_profiler_event_id, em.measurement_nbr, epr.facility_cd,
    facility = uar_get_code_display(epr.facility_cd), epr.position_cd, position =
    uar_get_code_display(epr.position_cd),
    result =
    IF (epr.capability_in_use_ind=1) "Yes"
    ELSE "No"
    ENDIF
    , name = substring(1,30,eprd.detail_name), val = substring(1,30,eprd.detail_value_txt)
    FROM ec_measurement em,
     ec_profiler_result epr,
     ec_profiler_event epe,
     dummyt d,
     ec_profiler_result_detail eprd
    PLAN (em
     WHERE em.measurement_nbr=curaccept)
     JOIN (epr
     WHERE epr.ec_measurement_id=em.ec_measurement_id)
     JOIN (epe
     WHERE epe.ec_profiler_event_id=epr.ec_profiler_event_id)
     JOIN (d)
     JOIN (eprd
     WHERE eprd.ec_profiler_result_id=epr.ec_profiler_result_id)
    ORDER BY cnvtdatetime(epe.event_begin_dt_tm) DESC
    WITH outerjoin = d, nocounter
   ;end select
 ENDCASE
 GO TO start
#end_program
END GO
