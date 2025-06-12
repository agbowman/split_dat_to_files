CREATE PROGRAM ec_execute_profiler:dba
 PROMPT
  "Output to File/Printer/MINE: " = "MINE"
  WITH outdev
 RECORD rpt(
   1 event_id = f8
   1 measurement_cnt = i2
   1 measurements[*]
     2 ec_measurement_id = i4
     2 program_name = vc
     2 days_of_week_bit = i2
     2 error_cnt = i2
     2 errors[*]
       3 error_code = f8
       3 error_msg = vc
 )
 RECORD dow_mask(
   1 none = i2
   1 sunday = i2
   1 monday = i2
   1 tuesday = i2
   1 wednesday = i2
   1 thursday = i2
   1 friday = i2
   1 saturday = i2
 )
 SET dow_mask->none = 0
 SET dow_mask->sunday = 1
 SET dow_mask->monday = 2
 SET dow_mask->tuesday = 4
 SET dow_mask->wednesday = 8
 SET dow_mask->thursday = 16
 SET dow_mask->friday = 32
 SET dow_mask->saturday = 64
 RECORD weekdays(
   1 na = i2
   1 sunday = i2
   1 monday = i2
   1 tuesday = i2
   1 wednesday = i2
   1 thursday = i2
   1 friday = i2
   1 saturday = i2
 )
 SET weekdays->na = - (1)
 SET weekdays->sunday = 0
 SET weekdays->monday = 1
 SET weekdays->tuesday = 2
 SET weekdays->wednesday = 3
 SET weekdays->thursday = 4
 SET weekdays->friday = 5
 SET weekdays->saturday = 6
 DECLARE tempint = i4 WITH noconstant(0), protect
 DECLARE tempstr = vc WITH noconstant(""), protect
 SELECT INTO "nl"
  FROM ec_measurement em
  PLAN (em
   WHERE em.active_ind=1)
  HEAD REPORT
   measurementcnt = 0
  DETAIL
   measurementcnt = (rpt->measurement_cnt+ 1), rpt->measurement_cnt = measurementcnt
   IF (mod(measurementcnt,20)=1)
    stat = alterlist(rpt->measurements,(measurementcnt+ 19))
   ENDIF
   rpt->measurements[measurementcnt].ec_measurement_id = em.ec_measurement_id, rpt->measurements[
   measurementcnt].program_name = em.program_name, rpt->measurements[measurementcnt].days_of_week_bit
    = em.days_of_week_bit
  FOOT REPORT
   stat = alterlist(rpt->measurements,measurementcnt)
  WITH nocounter
 ;end select
 CALL echo(build2("There are [",trim(cnvtstring(rpt->measurement_cnt)),
   "] active measurements in this environment."))
 SELECT INTO "nl"
  event_id = seq(ec_seq,nextval)
  FROM dual
  DETAIL
   rpt->event_id = event_id
  WITH nocounter
 ;end select
 INSERT  FROM ec_profiler_event epe
  SET epe.ec_profiler_event_id = rpt->event_id, epe.event_begin_dt_tm = cnvtdatetime(curdate,curtime3
    ), epe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end insert
 COMMIT
 FREE RECORD request
 RECORD request(
   1 start_dt_tm = dq8
   1 stop_dt_tm = dq8
 )
 SET request->start_dt_tm = cnvtdatetime((curdate - 1),0)
 SET request->stop_dt_tm = cnvtdatetime((curdate - 1),2359)
 DECLARE parsertext = vc WITH noconstant(""), protect
 DECLARE mi = i4 WITH noconstant(0), protect
 DECLARE dow_bit = i2 WITH noconstant(dow_mask->none), protect
 DECLARE yesterday = i2 WITH noconstant(weekday(request->start_dt_tm)), protect
 IF ((yesterday=weekdays->sunday))
  SET dow_bit = dow_mask->sunday
 ELSEIF ((yesterday=weekdays->monday))
  SET dow_bit = dow_mask->monday
 ELSEIF ((yesterday=weekdays->tuesday))
  SET dow_bit = dow_mask->tuesday
 ELSEIF ((yesterday=weekdays->wednesday))
  SET dow_bit = dow_mask->wednesday
 ELSEIF ((yesterday=weekdays->thursday))
  SET dow_bit = dow_mask->thursday
 ELSEIF ((yesterday=weekdays->friday))
  SET dow_bit = dow_mask->friday
 ELSEIF ((yesterday=weekdays->saturday))
  SET dow_bit = dow_mask->saturday
 ENDIF
 DECLARE errorcnt = i4 WITH noconstant(0), protect
 DECLARE errorcode = i4 WITH noconstant(1), protect
 DECLARE errormsg = vc WITH noconstant(fillstring(132," ")), protect
 FOR (mi = 1 TO rpt->measurement_cnt)
   IF (band(rpt->measurements[mi].days_of_week_bit,dow_bit) > 0)
    SELECT INTO "nl"
     FROM ec_profiler_result epr
     PLAN (epr
      WHERE (epr.ec_measurement_id=rpt->measurements[mi].ec_measurement_id)
       AND epr.result_dt_tm=cnvtdatetime(request->start_dt_tm))
     WITH nocounter
    ;end select
    IF (curqual=0)
     FREE RECORD reply
     RECORD reply(
       1 facility_cnt = i2
       1 facilities[*]
         2 facility_cd = f8
         2 position_cnt = i2
         2 positions[*]
           3 position_cd = f8
           3 capability_in_use_ind = i2
           3 detail_cnt = i2
           3 details[*]
             4 detail_name = vc
             4 detail_value_txt = vc
     )
     SET parsertext = build2(rpt->measurements[mi].program_name," go")
     CALL echo(parsertext)
     CALL parser(parsertext)
     IF (size(reply->facilities,5) > 0)
      IF (size(reply->facilities[1].positions,5) > 0)
       INSERT  FROM (dummyt d1  WITH seq = value(reply->facility_cnt)),
         (dummyt d2  WITH seq = 1),
         ec_profiler_result epr
        SET epr.ec_profiler_result_id = seq(ec_seq,nextval), epr.ec_profiler_event_id = rpt->event_id,
         epr.ec_measurement_id = rpt->measurements[mi].ec_measurement_id,
         epr.facility_cd = reply->facilities[d1.seq].facility_cd, epr.position_cd = reply->
         facilities[d1.seq].positions[d2.seq].position_cd, epr.capability_in_use_ind = reply->
         facilities[d1.seq].positions[d2.seq].capability_in_use_ind,
         epr.result_dt_tm = cnvtdatetime(request->start_dt_tm), epr.updt_dt_tm = cnvtdatetime(curdate,
          curtime3)
        PLAN (d1
         WHERE maxrec(d2,reply->facilities[d1.seq].position_cnt))
         JOIN (d2)
         JOIN (epr)
        WITH nocounter
       ;end insert
       INSERT  FROM (dummyt d1  WITH seq = value(reply->facility_cnt)),
         (dummyt d2  WITH seq = 1),
         (dummyt d3  WITH seq = 1),
         ec_profiler_result_detail eprd
        SET eprd.ec_profiler_result_id =
         (SELECT
          ec_profiler_result_id
          FROM ec_profiler_result
          WHERE (ec_profiler_event_id=rpt->event_id)
           AND (ec_measurement_id=rpt->measurements[mi].ec_measurement_id)
           AND (facility_cd=reply->facilities[d1.seq].facility_cd)
           AND (position_cd=reply->facilities[d1.seq].positions[d2.seq].position_cd)), eprd
         .ec_profiler_result_detail_id = cnvtreal(seq(ec_seq,nextval)), eprd.detail_name = reply->
         facilities[d1.seq].positions[d2.seq].details[d3.seq].detail_name,
         eprd.detail_value_txt = reply->facilities[d1.seq].positions[d2.seq].details[d3.seq].
         detail_value_txt, eprd.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        PLAN (d1
         WHERE maxrec(d2,reply->facilities[d1.seq].position_cnt))
         JOIN (d2
         WHERE maxrec(d3,reply->facilities[d1.seq].positions[d2.seq].detail_cnt))
         JOIN (d3)
         JOIN (eprd)
        WITH nocounter
       ;end insert
      ELSE
       CALL echo(build2(rpt->measurements[mi].program_name," failed to provide a position"))
      ENDIF
     ELSE
      CALL echo(build2(rpt->measurements[mi].program_name," failed to provide a facility"))
     ENDIF
     SET errorcnt = 0
     SET errorcode = 1
     SET errormsg = fillstring(132," ")
     SET errorcode = error(errormsg,1)
     WHILE (errorcode != 0)
       SET errorcnt = (rpt->measurements[mi].error_cnt+ 1)
       SET rpt->measurements[mi].error_cnt = errorcnt
       SET stat = alterlist(rpt->measurements[mi].errors,errorcnt)
       SET rpt->measurements[mi].errors[errorcnt].error_code = errorcode
       SET rpt->measurements[mi].errors[errorcnt].error_msg = errormsg
       CALL echo(build2("Error [",trim(cnvtstring(errorcode)),"] ",errormsg))
       SET errorcode = error(errormsg,1)
     ENDWHILE
     IF ((rpt->measurements[mi].error_cnt > 0))
      ROLLBACK
     ELSE
      COMMIT
     ENDIF
    ELSE
     CALL echo(build2("Measurement [",trim(cnvtstring(rpt->measurements[mi].ec_measurement_id)),
       "] already exists for ",format(cnvtdatetime(request->start_dt_tm),"@SHORTDATETIME")))
    ENDIF
   ELSE
    CALL echo(build2("Measurement [",trim(cnvtstring(rpt->measurements[mi].ec_measurement_id)),
      "] is not scheduled to run for ",format(cnvtdatetime(request->start_dt_tm),"@SHORTDATETIME")))
   ENDIF
 ENDFOR
 UPDATE  FROM ec_profiler_event epe
  SET epe.event_end_dt_tm = cnvtdatetime(curdate,curtime3), epe.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  WHERE (epe.ec_profiler_event_id=rpt->event_id)
  WITH nocounter
 ;end update
 COMMIT
 EXECUTE dm_stat_solution_usage
END GO
