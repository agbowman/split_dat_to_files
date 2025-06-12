CREATE PROGRAM bb_get_qc_group_activity:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE findnextdailyschedule(linterval=i4,ltime=i4,dtstartdttm=f8,nfirstschedule=i2) = f8
 SUBROUTINE findnextdailyschedule(linterval,ltime,dtstartdttm,nfirstschedule)
   DECLARE sinterval = c3 WITH protect, noconstant("")
   DECLARE smonth = c3 WITH protect, noconstant("")
   DECLARE nday = i2 WITH protect, noconstant(0)
   DECLARE lyear = i4 WITH protect, noconstant(0)
   DECLARE snewdttm = vc WITH protect, noconstant("")
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE stime = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ENDIF
   CALL echo(build("StartDtTm: ",format(dtstartdttm,";;Q")))
   SET stime = format(ltime,"HH:MM;;M")
   IF (nfirstschedule=1)
    SET smonth = format(dtstartdttm,"MMM;;D")
    SET nday = day(dtstartdttm)
    SET lyear = year(dtstartdttm)
    SET snewdttm = build(nday,"-",smonth,"-",lyear)
    SET snewdttm = concat(snewdttm," ",stime)
    SET dtnewdttm = cnvtdatetime(snewdttm)
    IF (dtnewdttm < dtstartdttm)
     SET dtnewdttm = cnvtlookahead("1D",dtnewdttm)
    ENDIF
   ELSE
    SET sinterval = build(linterval,"D")
    SET dtnewdttm = cnvtlookahead(sinterval,cnvtdatetime(cnvtdate(dtstartdttm),ltime))
   ENDIF
   CALL echo(build("NewDtTm: ",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 DECLARE findnextweeklyschedule(ldayofweekbit=i4,ltime=i4,dtstartdttm=f8,linterval=i4) = f8
 SUBROUTINE findnextweeklyschedule(ldayofweekbit,ltime,dtstartdttm,linterval)
   DECLARE nsunday = i2 WITH protect, constant(0)
   DECLARE nmonday = i2 WITH protect, constant(1)
   DECLARE ntuesday = i2 WITH protect, constant(2)
   DECLARE nwednesday = i2 WITH protect, constant(3)
   DECLARE nthursday = i2 WITH protect, constant(4)
   DECLARE nfriday = i2 WITH protect, constant(5)
   DECLARE nsaturday = i2 WITH protect, constant(6)
   DECLARE nbitmonday = i2 WITH protect, constant(1)
   DECLARE nbittuesday = i2 WITH protect, constant(2)
   DECLARE nbitwednesday = i2 WITH protect, constant(4)
   DECLARE nbitthursday = i2 WITH protect, constant(8)
   DECLARE nbitfriday = i2 WITH protect, constant(16)
   DECLARE nbitsaturday = i2 WITH protect, constant(32)
   DECLARE nbitsunday = i2 WITH protect, constant(64)
   DECLARE nweekday = i2 WITH protect, noconstant(0)
   DECLARE stime = vc WITH protect, noconstant("")
   DECLARE ndayincrement = i2 WITH protect, noconstant(0)
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE dtholddttm = f8 WITH protect, noconstant(0.0)
   DECLARE sholddttm = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ELSEIF (ldayofweekbit=0)
    CALL echo("lDayOfWeekBit = 0")
    RETURN(0.0)
   ENDIF
   SET nweekday = weekday(dtstartdttm)
   SET stime = format(ltime,"##:##")
   CALL echo(build("StartDtTm:",format(dtstartdttm,";;Q")))
   FOR (i = 0 TO 6)
     IF (band(ldayofweekbit,nbitsunday)=nbitsunday
      AND i=nsunday)
      SET ndayincrement = (nsunday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitmonday)=nbitmonday
      AND i=nmonday)
      SET ndayincrement = (nmonday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbittuesday)=nbittuesday
      AND i=ntuesday)
      SET ndayincrement = (ntuesday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitwednesday)=nbitwednesday
      AND i=nwednesday)
      SET ndayincrement = (nwednesday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitthursday)=nbitthursday
      AND i=nthursday)
      SET ndayincrement = (nthursday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitfriday)=nbitfriday
      AND i=nfriday)
      SET ndayincrement = (nfriday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
     IF (band(ldayofweekbit,nbitsaturday)=nbitsaturday
      AND i=nsaturday)
      SET ndayincrement = (nsaturday - nweekday)
      IF (ndayincrement > 0)
       SET dtholddttm = cnvtlookahead(build(ndayincrement,"D"),dtstartdttm)
      ELSE
       SET dtholddttm = cnvtlookahead(build((ndayincrement+ (7 * linterval)),"D"),dtstartdttm)
      ENDIF
      SET sholddttm = build(day(dtholddttm),"-",format(dtholddttm,"MMM;;D"),"-",year(dtholddttm))
      SET sholddttm = concat(sholddttm," ",stime)
      SET dtholddttm = cnvtdatetime(sholddttm)
      IF (dtholddttm > dtstartdttm
       AND ((dtholddttm < dtnewdttm) OR (dtnewdttm=0.0)) )
       SET dtnewdttm = dtholddttm
      ENDIF
     ENDIF
   ENDFOR
   CALL echo(build("NewDtTm:",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 DECLARE findnextmonthlyschedule1(linterval=i4,ndayofmonth=i2,ltime=i4,dtstartdttm=f8,nfirstschedule=
  i2) = f8
 SUBROUTINE findnextmonthlyschedule1(linterval,ndayofmonth,ltime,dtstartdttm,nfirstschedule)
   DECLARE sinterval = c3 WITH protect, noconstant("")
   DECLARE smonth = c3 WITH protect, noconstant("")
   DECLARE nday = i2 WITH protect, noconstant(0)
   DECLARE lyear = i4 WITH protect, noconstant(0)
   DECLARE snewdttm = vc WITH protect, noconstant("")
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE stime = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ELSEIF (ndayofmonth=0)
    CALL echo("nDayOfMonth = 0")
    RETURN(0.0)
   ENDIF
   SET sinterval = build(linterval,"M")
   SET stime = format(ltime,"##:##")
   CALL echo(build("StartDtTm:",format(dtstartdttm,";;Q")))
   IF (nfirstschedule=1)
    SET smonth = format(dtstartdttm,"MMM;;D")
    SET lyear = year(dtstartdttm)
    SET snewdttm = build(ndayofmonth,"-",smonth,"-",lyear)
    SET snewdttm = concat(snewdttm," ",stime)
    SET dtnewdttm = cnvtdatetime(snewdttm)
    IF (dtnewdttm > dtstartdttm)
     SET smonth = format(dtstartdttm,"MMM;;D")
     SET nday = ndayofmonth
     SET lyear = year(dtstartdttm)
    ELSE
     SET dtnewdttm = cnvtlookahead(sinterval,dtstartdttm)
     SET smonth = format(dtnewdttm,"MMM;;D")
     SET nday = ndayofmonth
     SET lyear = year(dtnewdttm)
    ENDIF
   ELSE
    SET dtnewdttm = cnvtlookahead(sinterval,dtstartdttm)
    SET smonth = format(dtnewdttm,"MMM;;D")
    SET nday = ndayofmonth
    SET lyear = year(dtnewdttm)
   ENDIF
   SET snewdttm = build(nday,"-",smonth,"-",lyear)
   SET snewdttm = concat(snewdttm," ",stime)
   SET dtnewdttm = cnvtdatetime(snewdttm)
   CALL echo(build("NewDtTm:",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 DECLARE findnextmonthlyschedule2(linterval=i4,nday=i2,ltime=i4,dtstartdttm=f8,lmonthinterval=i2) =
 f8
 SUBROUTINE findnextmonthlyschedule2(linterval,nday,ltime,dtstartdttm,lmonthinterval)
   DECLARE sinterval = c3 WITH protect, noconstant("")
   DECLARE smonth = c3 WITH protect, noconstant("")
   DECLARE nfirstday = i2 WITH protect, noconstant(0)
   DECLARE nholdday = i2 WITH protect, noconstant(0)
   DECLARE loffset = i4 WITH protect, noconstant(0)
   DECLARE sholddttm = vc WITH protect, noconstant("")
   DECLARE dtholddttm = f8 WITH protect, noconstant(0.0)
   DECLARE dtnewdttm = f8 WITH protect, noconstant(0.0)
   DECLARE stime = vc WITH protect, noconstant("")
   IF (linterval=0)
    CALL echo("lInterval = 0")
    RETURN(0.0)
   ELSEIF (ltime=0)
    CALL echo("lTime = 0")
    RETURN(0.0)
   ELSEIF (dtstartdttm=0.0)
    CALL echo("dtStartDtTm = 0")
    RETURN(0.0)
   ELSEIF (nday=0)
    CALL echo("nDay = 0")
    RETURN(0.0)
   ELSEIF (lmonthinterval=0)
    CALL echo("lMonthInterval = 0")
    RETURN(0.0)
   ENDIF
   SET nday = (nday - 1)
   CALL echo(build("StartDtTm:",format(dtstartdttm,";;Q")))
   SET sinterval = build(lmonthinterval,"M")
   SET stime = format(ltime,"##:##")
   SET ndatefound = 0
   WHILE (ndatefound=0)
     SET smonth = format(dtstartdttm,"MMM;;D")
     SET sholddttm = build("1-",smonth,"-",year(dtstartdttm))
     SET sholddttm = concat(sholddttm," ",stime)
     SET dtholddttm = cnvtdatetime(sholddttm)
     SET nfirstday = weekday(dtholddttm)
     IF (nday < 7)
      SET loffset = ((nfirstday - nday) * - (1))
      IF (loffset >= 0)
       SET loffset = (loffset+ 1)
      ELSE
       SET loffset = (8+ loffset)
      ENDIF
      SET nholdday = (loffset+ (7 * (linterval - 1)))
      IF (nholdday > 28)
       IF (smonth IN ("JAN", "MAR", "MAY", "JUL", "AUG",
       "OCT", "DEC"))
        IF (nholdday > 31)
         SET nholdday = (nholdday - 7)
        ENDIF
       ELSEIF (smonth IN ("APR", "JUN", "SEP", "NOV"))
        IF (nholdday > 30)
         SET nholdday = (nholdday - 7)
        ENDIF
       ELSEIF (smonth="FEB")
        IF (nholdday > 28)
         SET nholdday = (nholdday - 7)
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF (linterval < 5)
       SET nholdday = ((nfirstday+ linterval) - 1)
      ELSE
       IF (smonth IN ("JAN", "MAR", "MAY", "JUL", "AUG",
       "OCT", "DEC"))
        SET nholdday = 31
       ELSEIF (smonth IN ("APR", "JUN", "SEP", "NOV"))
        SET nholdday = 30
       ELSEIF (smonth="FEB")
        SET lyear = year(dtstartdttm)
        IF (mod(lyear,4)=0
         AND ((mod(lyear,100) != 0) OR (mod(lyear,400)=0)) )
         SET nholdday = 29
        ELSE
         SET nholdday = 28
        ENDIF
       ENDIF
      ENDIF
     ENDIF
     SET sholddttm = build(nholdday,"-",smonth,"-",year(dtstartdttm))
     SET sholddttm = concat(sholddttm," ",stime)
     SET dtholddttm = cnvtdatetime(sholddttm)
     IF (dtholddttm > dtstartdttm)
      SET dtnewdttm = dtholddttm
      SET ndatefound = 1
     ELSE
      SET dtstartdttm = cnvtlookahead(sinterval,dtholddttm)
     ENDIF
   ENDWHILE
   CALL echo(build("NewDtTm:",format(dtnewdttm,";;Q")))
   RETURN(dtnewdttm)
 END ;Subroutine
 RECORD group_activity(
   1 group_activity_list[*]
     2 group_id = f8
     2 scheduled_dt_tm = dq8
     2 group_activity_id = f8
     2 group_reagent_activity_list[*]
       3 reagent_activity_id = f8
       3 reagent_lot_id = f8
       3 lot_parent_entitiy_id = f8
       3 related_reagent_id = f8
       3 result_list[*]
         4 enhancement_activity_id = f8
         4 control_activity_id = f8
         4 phase_cd = f8
       3 current_ind = i2
 )
 DECLARE nreagent_activity = i2 WITH protect, constant(0)
 DECLARE ncontrol_activity = i2 WITH protect, constant(1)
 DECLARE nenhancement_activity = i2 WITH protect, constant(2)
 DECLARE scheduleqcgroupactivity(dgroupid=f8(value),nschedulenowind=i2(value),dbegdttm=f8(value),
  denddttm=f8(value)) = i2 WITH protect
 DECLARE getnextscheduledttm(dgroupid=f8(value),dtscheduledttm=f8(value),dsegmentid=f8(value),
  nfirstscheduleind=i2(value)) = f8 WITH protect
 DECLARE addqcgroupactivity(no_param=i2(value)) = i2 WITH protect
 DECLARE generateid(no_param=i2(value)) = f8 WITH protect
 DECLARE getqcreagentactivityinfo(no_param) = i2 WITH protect
 DECLARE addqcreagentactivity(no_param) = i2 WITH protect
 DECLARE lookupactivity(dgroupactivityid=f8(value),dreagentcd=f8(value),ncurrentind=i2(value)) = f8
 WITH protect
 DECLARE addqcresults(no_param) = i2 WITH protect
 SUBROUTINE getnextscheduledttm(dgroupid,dtscheduledttm,dsegmentid,nfirstscheduleind)
   DECLARE dtnextscheduledttm = f8 WITH protect, noconstant(0.0)
   DECLARE dttempdttm = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM bb_qc_schedule_segment mqss
    PLAN (mqss
     WHERE mqss.schedule_segment_id=dsegmentid)
    DETAIL
     CASE (mqss.segment_type_flag)
      OF ndaily:
       dttempdttm = findnextdailyschedule(mqss.component1_nbr,mqss.time_nbr,dtscheduledttm,
        nfirstscheduleind)
      OF nweekly:
       dttempdttm = findnextweeklyschedule(mqss.days_of_week_bit,mqss.time_nbr,dtscheduledttm,mqss
        .component1_nbr)
      OF nmonthly1:
       dttempdttm = findnextmonthlyschedule1(mqss.component2_nbr,mqss.component1_nbr,mqss.time_nbr,
        dtscheduledttm,nfirstscheduleind)
      OF nmonthly2:
       dttempdttm = findnextmonthlyschedule2(mqss.component1_nbr,mqss.component2_nbr,mqss.time_nbr,
        dtscheduledttm,mqss.component3_nbr)
     ENDCASE
     IF (((dtnextscheduledttm=0.0) OR (dtnextscheduledttm > dttempdttm)) )
      dtnextscheduledttm = dttempdttm
     ENDIF
    WITH nocounter
   ;end select
   RETURN(dtnextscheduledttm)
 END ;Subroutine
 SUBROUTINE scheduleqcgroupactivity(dgroupid,nschedulenowind,dtbegdttm,dtenddttm)
   DECLARE lactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE dtnextscheduledttm = f8 WITH protect, noconstant(0.0)
   DECLARE dtcurrentdttm = f8 WITH protect, noconstant(0.0)
   DECLARE lsegmentidx = i4 WITH protect, noconstant(0)
   DECLARE ndaily = i2 WITH protect, constant(1)
   DECLARE nweekly = i2 WITH protect, constant(2)
   DECLARE nmonthly1 = i2 WITH protect, constant(3)
   DECLARE nmonthly2 = i2 WITH protect, constant(4)
   RECORD schedule_segment(
     1 qual[*]
       2 schedule_segment_id = f8
   ) WITH protect
   SET lstatus = alterlist(group_activity->group_activity_list,0)
   SELECT INTO "nl:"
    FROM bb_qc_group bqg,
     bb_qc_schedule_segment bqss
    PLAN (bqg
     WHERE bqg.group_id=dgroupid)
     JOIN (bqss
     WHERE bqss.schedule_cd=bqg.schedule_cd)
    HEAD REPORT
     lsegmentcnt = 0
    DETAIL
     lsegmentcnt = (lsegmentcnt+ 1)
     IF (lsegmentcnt > size(schedule_segment->qual,5))
      lstatus = alterlist(schedule_segment->qual,(lsegmentcnt+ 5))
     ENDIF
     schedule_segment->qual[lsegmentcnt].schedule_segment_id = bqss.schedule_segment_id
    FOOT REPORT
     lstatus = alterlist(schedule_segment->qual,lsegmentcnt)
    WITH nocounter
   ;end select
   SET dtcurrentdttm = cnvtdatetime(curdate,curtime3)
   IF (((dtbegdttm=0.0) OR (dtenddttm=0.0)) )
    IF (nschedulenowind=1)
     SET lactivitycnt = (lactivitycnt+ 1)
     SET lstatus = alterlist(group_activity->group_activity_list,lactivitycnt)
     SET group_activity->group_activity_list[lactivitycnt].group_id = dgroupid
     SET group_activity->group_activity_list[lactivitycnt].scheduled_dt_tm = dtcurrentdttm
    ENDIF
    FOR (lsegmentidx = 1 TO size(schedule_segment->qual,5))
     SET dtnextscheduledttm = getnextscheduledttm(dgroupid,dtcurrentdttm,schedule_segment->qual[
      lsegmentidx].schedule_segment_id,1)
     IF (dtnextscheduledttm > 0.0)
      SET lactivitycnt = (lactivitycnt+ 1)
      SET lstatus = alterlist(group_activity->group_activity_list,lactivitycnt)
      SET group_activity->group_activity_list[lactivitycnt].group_id = dgroupid
      SET group_activity->group_activity_list[lactivitycnt].scheduled_dt_tm = dtnextscheduledttm
     ENDIF
    ENDFOR
   ELSE
    FOR (lsegmentidx = 1 TO size(schedule_segment->qual,5))
     SET dtnextscheduledttm = getnextscheduledttm(dgroupid,dtbegdttm,schedule_segment->qual[
      lsegmentidx].schedule_segment_id,1)
     WHILE (dtnextscheduledttm != 0.0
      AND ((dtnextscheduledttm < dtcurrentdttm) OR (dtnextscheduledttm < dtenddttm)) )
       SET lactivitycnt = (lactivitycnt+ 1)
       SET lstatus = alterlist(group_activity->group_activity_list,lactivitycnt)
       SET group_activity->group_activity_list[lactivitycnt].group_id = dgroupid
       SET group_activity->group_activity_list[lactivitycnt].scheduled_dt_tm = dtnextscheduledttm
       SET dtnextscheduledttm = getnextscheduledttm(dgroupid,dtnextscheduledttm,schedule_segment->
        qual[lsegmentidx].schedule_segment_id,0)
     ENDWHILE
    ENDFOR
   ENDIF
   IF (size(group_activity->group_activity_list,5)=0)
    RETURN(nsuccess)
   ENDIF
   IF (addqcgroupactivity(0)=nsuccess)
    IF (getqcreagentactivityinfo(0)=nsuccess)
     IF (addqcreagentactivity(0)=nsuccess)
      IF (addqcresults(0)=nsuccess)
       SET reqinfo->commit_ind = 1
       RETURN(nsuccess)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(nfail)
 END ;Subroutine
 SUBROUTINE addqcgroupactivity(no_param)
   DECLARE lgroupactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE dnewactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   DECLARE dgroupactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE ilotexpiredind = i2 WITH protect, noconstant(0)
   SET lgroupactivitycnt = size(group_activity->group_activity_list,5)
   FOR (i = 1 TO lgroupactivitycnt)
     SET dgroupactivityid = 0.0
     SELECT INTO "nl:"
      FROM bb_qc_group_activity ga
      WHERE (ga.group_id=group_activity->group_activity_list[i].group_id)
       AND ga.scheduled_dt_tm=cnvtdatetime(group_activity->group_activity_list[i].scheduled_dt_tm)
      DETAIL
       IF (dgroupactivityid=0.0)
        dgroupactivityid = ga.group_activity_id
       ENDIF
      WITH nocounter
     ;end select
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode != 0)
      RETURN(nfail)
     ENDIF
     IF (dgroupactivityid=0.0)
      SELECT INTO "nl:"
       FROM bb_qc_grp_reagent_lot grl,
        pcs_lot_information li
       PLAN (grl
        WHERE (grl.group_id=group_activity->group_activity_list[i].group_id)
         AND grl.beg_effective_dt_tm <= cnvtdatetime(group_activity->group_activity_list[i].
         scheduled_dt_tm)
         AND grl.end_effective_dt_tm > cnvtdatetime(group_activity->group_activity_list[i].
         scheduled_dt_tm)
         AND grl.active_ind=1)
        JOIN (li
        WHERE li.lot_information_id=grl.lot_information_id)
       HEAD REPORT
        ilotexpiredind = 0
       DETAIL
        IF ((li.expire_dt_tm < group_activity->group_activity_list[i].scheduled_dt_tm))
         ilotexpiredind = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (ilotexpiredind=0)
       SET dnewactivityid = generateid(0)
       IF (dnewactivityid > 0)
        INSERT  FROM bb_qc_group_activity ga
         SET ga.group_activity_id = dnewactivityid, ga.scheduled_dt_tm = cnvtdatetime(group_activity
           ->group_activity_list[i].scheduled_dt_tm), ga.group_id = group_activity->
          group_activity_list[i].group_id,
          ga.related_group_id = 0.0, ga.lock_prsnl_id = 0.0, ga.updt_cnt = 0,
          ga.updt_id = reqinfo->updt_id, ga.updt_dt_tm = cnvtdatetime(curdate,curtime3), ga.updt_task
           = reqinfo->updt_task,
          ga.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        SET lerrorcode = error(serrormsg,1)
        IF (lerrorcode != 0)
         RETURN(nfail)
        ENDIF
        SET group_activity->group_activity_list[i].group_activity_id = dnewactivityid
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(nsuccess)
 END ;Subroutine
 SUBROUTINE generateid(no_param)
   DECLARE did = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     did = next_seq_nbr
    WITH nocounter, format
   ;end select
   RETURN(did)
 END ;Subroutine
 SUBROUTINE getqcreagentactivityinfo(no_param)
   DECLARE lreagentactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE lgroupactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   SET lgroupactivitycnt = size(group_activity->group_activity_list,5)
   IF (lgroupactivitycnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(lgroupactivitycnt)),
      bb_qc_grp_reagent_lot grl,
      pcs_lot_information li,
      pcs_lot_definition ld
     PLAN (d1)
      JOIN (grl
      WHERE (grl.group_id=group_activity->group_activity_list[d1.seq].group_id)
       AND (group_activity->group_activity_list[d1.seq].group_id > 0.0)
       AND grl.beg_effective_dt_tm <= cnvtdatetime(group_activity->group_activity_list[d1.seq].
       scheduled_dt_tm)
       AND grl.end_effective_dt_tm > cnvtdatetime(group_activity->group_activity_list[d1.seq].
       scheduled_dt_tm)
       AND grl.active_ind=1)
      JOIN (li
      WHERE grl.lot_information_id=li.lot_information_id
       AND li.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND li.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      JOIN (ld
      WHERE ld.lot_definition_id=li.lot_definition_id
       AND ld.parent_entity_id > 0.0
       AND ld.parent_entity_name="CODE_VALUE")
     ORDER BY d1.seq
     HEAD d1.seq
      lreagentactivitycnt = 0
     DETAIL
      lreagentactivitycnt = (lreagentactivitycnt+ 1)
      IF (lreagentactivitycnt > size(group_activity->group_activity_list[d1.seq].
       group_reagent_activity_list,5))
       lstatus = alterlist(group_activity->group_activity_list[d1.seq].group_reagent_activity_list,(
        lreagentactivitycnt+ 10))
      ENDIF
      group_activity->group_activity_list[d1.seq].group_reagent_activity_list[lreagentactivitycnt].
      reagent_lot_id = grl.group_reagent_lot_id, group_activity->group_activity_list[d1.seq].
      group_reagent_activity_list[lreagentactivitycnt].lot_parent_entitiy_id = ld.parent_entity_id,
      group_activity->group_activity_list[d1.seq].group_reagent_activity_list[lreagentactivitycnt].
      related_reagent_id = grl.related_reagent_id,
      group_activity->group_activity_list[d1.seq].group_reagent_activity_list[lreagentactivitycnt].
      current_ind = grl.current_ind
     FOOT  d1.seq
      lstatus = alterlist(group_activity->group_activity_list[d1.seq].group_reagent_activity_list,
       lreagentactivitycnt)
     WITH nocounter
    ;end select
   ENDIF
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode != 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
 SUBROUTINE addqcreagentactivity(no_param)
   DECLARE lvisual_inspection_cs = i4 WITH protect, constant(325574)
   DECLARE lbb_qc_interpretations_cs = i4 WITH protect, constant(325575)
   DECLARE lgfroupactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lreagentactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE dnewactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE dpendinginspectioncd = f8 WITH protect, noconstant(0.0)
   DECLARE dpendinginterpcd = f8 WITH protect, noconstant(0.0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   SET lstatus = uar_get_meaning_by_codeset(lvisual_inspection_cs,"PENDING",1,dpendinginspectioncd)
   IF (dpendinginspectioncd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE","Could not find PENDING inspection code.")
    RETURN(nfail)
   ENDIF
   SET lstatus = uar_get_meaning_by_codeset(lbb_qc_interpretations_cs,"PENDING",1,dpendinginterpcd)
   IF (dpendinginterpcd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE",build("Could not find PENDING interpretation cd."))
    RETURN(nfail)
   ENDIF
   SET lgroupactivitycnt = size(group_activity->group_activity_list,5)
   IF (lgroupactivitycnt > 0)
    FOR (i = 1 TO lgroupactivitycnt)
      IF ((group_activity->group_activity_list[i].group_activity_id > 0.0))
       SET lreagentactivitycnt = size(group_activity->group_activity_list[i].
        group_reagent_activity_list,5)
       FOR (j = 1 TO lreagentactivitycnt)
         SET dnewactivityid = generateid(0)
         IF (dnewactivityid > 0)
          INSERT  FROM bb_qc_grp_reagent_activity gra
           SET gra.group_reagent_activity_id = dnewactivityid, gra.group_reagent_lot_id =
            group_activity->group_activity_list[i].group_reagent_activity_list[j].reagent_lot_id, gra
            .group_activity_id = group_activity->group_activity_list[i].group_activity_id,
            gra.activity_dt_tm = cnvtdatetime(curdate,curtime3), gra.visual_inspection_cd =
            dpendinginspectioncd, gra.interpretation_cd = dpendinginterpcd,
            gra.updt_cnt = 0, gra.updt_id = reqinfo->updt_id, gra.updt_dt_tm = cnvtdatetime(curdate,
             curtime3),
            gra.updt_task = reqinfo->updt_task, gra.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
         ENDIF
         SET group_activity->group_activity_list[i].group_reagent_activity_list[j].
         reagent_activity_id = dnewactivityid
         SET lerrorcode = error(serrormsg,1)
         IF (lerrorcode != 0)
          RETURN(nfail)
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   RETURN(nsuccess)
 END ;Subroutine
 SUBROUTINE lookupactivity(dgroupactivityid,dreagentcd,ncurrentind)
   DECLARE lgroupactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lreagentactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   SET lgroupactivitycnt = size(group_activity->group_activity_list,5)
   FOR (i = 1 TO lgroupactivitycnt)
     IF ((dgroupactivityid=group_activity->group_activity_list[i].group_activity_id))
      SET lreagentactivitycnt = size(group_activity->group_activity_list[i].
       group_reagent_activity_list,5)
      FOR (j = 1 TO lreagentactivitycnt)
        IF ((group_activity->group_activity_list[i].group_reagent_activity_list[j].
        lot_parent_entitiy_id=dreagentcd)
         AND (group_activity->group_activity_list[i].group_reagent_activity_list[j].current_ind=
        ncurrentind))
         RETURN(group_activity->group_activity_list[i].group_reagent_activity_list[j].
         reagent_activity_id)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE addqcresults(no_param)
   DECLARE lbb_qc_result_status_cs = i4 WITH protect, constant(325577)
   DECLARE lgroupactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lreagentactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE dphasecd = f8 WITH protect, noconstant(0.0)
   DECLARE dreagentactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE dcontrolactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE denhancementactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE lresultcnt = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   DECLARE nstatus = i2 WITH protect, noconstant(0)
   DECLARE dpendingresultcd = f8 WITH protect, noconstant(0.0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE dgroupactivityid = f8 WITH protect, noconstant(0.0)
   DECLARE dnewresultid = f8 WITH protect, noconstant(0.0)
   DECLARE ncurrentind = i2 WITH protect, noconstant(0.0)
   SET nstatus = uar_get_meaning_by_codeset(lbb_qc_result_status_cs,"PENDING",1,dpendingresultcd)
   IF (dpendingresultcd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE","Could not find PENDING in cs 325577.")
    RETURN(nfail)
   ENDIF
   SET lgroupactivitycnt = size(group_activity->group_activity_list,5)
   FOR (i = 1 TO lgroupactivitycnt)
     SET lreagentactivitycnt = size(group_activity->group_activity_list[i].
      group_reagent_activity_list,5)
     SET dgroupactivityid = group_activity->group_activity_list[i].group_activity_id
     FOR (j = 1 TO lreagentactivitycnt)
       SET ncurrentind = group_activity->group_activity_list[i].group_reagent_activity_list[j].
       current_ind
       SELECT INTO "nl:"
        FROM bb_qc_rel_reagent rr,
         bb_qc_rel_reagent_detail rrd
        PLAN (rr
         WHERE (rr.related_reagent_id=group_activity->group_activity_list[i].
         group_reagent_activity_list[j].related_reagent_id)
          AND (rr.reagent_cd=group_activity->group_activity_list[i].group_reagent_activity_list[j].
         lot_parent_entitiy_id)
          AND rr.reagent_cd > 0.0
          AND rr.active_ind=1)
         JOIN (rrd
         WHERE rrd.related_reagent_id=rr.related_reagent_id
          AND rrd.phase_cd > 0.0
          AND rrd.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
          AND rrd.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
          AND rrd.active_ind=1)
        ORDER BY rr.related_reagent_id
        HEAD REPORT
         lresultcnt = 0
        DETAIL
         IF (rrd.enhancement_cd > 0.0)
          denhancementactivityid = lookupactivity(dgroupactivityid,rrd.enhancement_cd,ncurrentind)
         ELSE
          denhancementactivityid = 0.0
         ENDIF
         IF (rrd.control_cd > 0.0)
          dcontrolactivityid = lookupactivity(dgroupactivityid,rrd.control_cd,ncurrentind)
         ELSE
          dcontrolactivityid = 0.0
         ENDIF
         dphasecd = rrd.phase_cd, lresultcnt = (lresultcnt+ 1)
         IF (lresultcnt > size(group_activity->group_activity_list[i].group_reagent_activity_list[j].
          result_list,5))
          lstatus = alterlist(group_activity->group_activity_list[i].group_reagent_activity_list[j].
           result_list,(lresultcnt+ 10))
         ENDIF
         group_activity->group_activity_list[i].group_reagent_activity_list[j].result_list[lresultcnt
         ].enhancement_activity_id = denhancementactivityid, group_activity->group_activity_list[i].
         group_reagent_activity_list[j].result_list[lresultcnt].control_activity_id =
         dcontrolactivityid, group_activity->group_activity_list[i].group_reagent_activity_list[j].
         result_list[lresultcnt].phase_cd = dphasecd
        FOOT REPORT
         lstatus = alterlist(group_activity->group_activity_list[i].group_reagent_activity_list[j].
          result_list,lresultcnt)
        WITH nocounter
       ;end select
       SET lerrorcode = error(serrormsg,1)
       IF (lerrorcode != 0)
        RETURN(nfail)
       ENDIF
       SET lresultcnt = size(group_activity->group_activity_list[i].group_reagent_activity_list[j].
        result_list,5)
       FOR (k = 1 TO lresultcnt)
         SET dreagentactivityid = group_activity->group_activity_list[i].group_reagent_activity_list[
         j].reagent_activity_id
         SET dphasecd = group_activity->group_activity_list[i].group_reagent_activity_list[j].
         result_list[k].phase_cd
         SET dcontrolactivityid = group_activity->group_activity_list[i].group_reagent_activity_list[
         j].result_list[k].control_activity_id
         SET denhancementactivityid = group_activity->group_activity_list[i].
         group_reagent_activity_list[j].result_list[k].enhancement_activity_id
         IF (dreagentactivityid > 0.0
          AND dphasecd > 0.0
          AND dcontrolactivityid > 0.0)
          SET dnewresultid = generateid(0)
          IF (dnewresultid > 0.0)
           INSERT  FROM bb_qc_result r
            SET r.qc_result_id = dnewresultid, r.group_reagent_activity_id = dreagentactivityid, r
             .control_activity_id = dcontrolactivityid,
             r.enhancement_activity_id = denhancementactivityid, r.phase_cd = dphasecd, r.status_cd
              = dpendingresultcd,
             r.action_prsnl_id = reqinfo->updt_id, r.action_dt_tm = cnvtdatetime(curdate,curtime3), r
             .updt_cnt = 0,
             r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task
              = reqinfo->updt_task,
             r.updt_applctx = reqinfo->updt_applctx
            WITH nocounter
           ;end insert
           SET lerrorcode = error(serrormsg,1)
           IF (lerrorcode != 0)
            RETURN(nfail)
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   RETURN(nsuccess)
 END ;Subroutine
 RECORD valid_activity(
   1 group_activity_list[*]
     2 group_activity_id = f8
 )
 RECORD reply(
   1 group_activity_list[*]
     2 group_activity_id = f8
     2 group_id = f8
     2 group_name = c40
     2 scheduled_dt_tm = dq8
     2 xref_group_id = f8
     2 xref_group_name = c40
     2 lock_prsnl_id = f8
     2 lock_dt_tm = dq8
     2 lock_prsnl_username = vc
     2 pending_ind = i2
     2 updt_cnt = i4
     2 group_reagent_activity_list[*]
       3 group_reagent_activity_id = f8
       3 group_reagent_lot_id = f8
       3 lot_information_id = f8
       3 lot_ident = c40
       3 reagent_cd = f8
       3 reagent_disp = c40
       3 manufacturer_cd = f8
       3 manufacturer_disp = c40
       3 expiration_dt_tm = dq8
       3 lot_status_cd = f8
       3 lot_status_disp = c40
       3 lot_status_mean = c12
       3 visual_inspection_cd = f8
       3 visual_inspection_disp = c40
       3 visual_inspection_mean = c12
       3 interpretation_cd = f8
       3 interpretation_disp = c40
       3 interpretation_mean = c12
       3 activity_dt_tm = dq8
       3 activity_prsnl_id = f8
       3 activity_prsnl_username = vc
       3 updt_cnt = i4
       3 result_list[*]
         4 qc_result_id = f8
         4 enhancement_activity_id = f8
         4 control_activity_id = f8
         4 phase_cd = f8
         4 phase_disp = c40
         4 result_id = f8
         4 result_string = c40
         4 result_dt_tm = dq8
         4 result_prsnl_id = f8
         4 result_prsnl_username = vc
         4 abnormal_ind = i2
         4 reason_cd = f8
         4 reason_disp = c40
         4 reason_mean = c12
         4 status_cd = f8
         4 status_disp = c40
         4 status_mean = c12
         4 comment_text_id = f8
         4 comment_text = vc
         4 updt_cnt = i4
         4 troubleshooting_list[*]
           5 result_troubleshooting_id = f8
           5 troubleshooting_id = f8
           5 troubleshooting_text_id = f8
           5 troubleshooting_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getqcvalidactivity(dgroupid=f8(value)) = i2 WITH private
 DECLARE getqcgroupactivity(dgroupid=f8(value)) = i2 WITH private
 DECLARE lstatus = i4 WITH noconstant(0), protect
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE lgroup_cnt = i4 WITH protect, constant(size(request->group_list,5))
 DECLARE lgroupidx = i4 WITH protect, noconstant(0)
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE lresult_status_cs = i4 WITH protect, constant(325577)
 DECLARE dpendingstatuscd = f8 WITH protect, noconstant(0.0)
#begin_script
 SET reply->status_data.status = "F"
 IF (lgroup_cnt > 0)
  SET lstatus = uar_get_meaning_by_codeset(lresult_status_cs,"PENDING",1,dpendingstatuscd)
  IF (dpendingstatuscd=0.0)
   CALL subevent_add("SELECT","F","CODE_VALUE","Could not find PENDING result status code.")
   GO TO exit_script
  ENDIF
  FOR (lgroupidx = 1 TO lgroup_cnt)
    SET lstatus = scheduleqcgroupactivity(request->group_list[lgroupidx].group_id,0,request->
     begin_dt_tm,request->end_dt_tm)
    IF (lstatus=nfail)
     CALL subevent_add("SUBROUTINE","F","ScheduleQCGroupActivity",serrormsg)
     GO TO exit_script
    ENDIF
    SET lstatus = getqcvalidactivity(request->group_list[lgroupidx].group_id)
    IF (lstatus=nfail)
     CALL subevent_add("SUBROUTINE","F","GetQCValidActivity",serrormsg)
     GO TO exit_script
    ENDIF
    SET lstatus = getqcgroupactivity(request->group_list[lgroupidx].group_id)
    IF (lstatus=nfail)
     CALL subevent_add("SUBROUTINE","F","GetQCGroupActivity",serrormsg)
     GO TO exit_script
    ENDIF
  ENDFOR
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SUBROUTINE getqcvalidactivity(dgroupid)
   DECLARE nvalidactivivtyind = i2 WITH protect, noconstant(0)
   DECLARE nactivitycnt = i4 WITH protect, noconstant(0)
   SET lstatus = alterlist(valid_activity->group_activity_list,0)
   SELECT INTO "nl:"
    FROM bb_qc_group_activity ga,
     bb_qc_grp_reagent_activity gra,
     bb_qc_result r
    PLAN (ga
     WHERE ga.group_id=dgroupid
      AND ((ga.scheduled_dt_tm < cnvtdatetime(curdate,curtime3)) OR (ga.scheduled_dt_tm BETWEEN
     cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->end_dt_tm))) )
     JOIN (gra
     WHERE gra.group_activity_id=ga.group_activity_id)
     JOIN (r
     WHERE outerjoin(gra.group_reagent_activity_id)=r.group_reagent_activity_id)
    ORDER BY ga.scheduled_dt_tm DESC, ga.group_activity_id
    HEAD ga.group_activity_id
     nvalidactivivtyind = 0
    DETAIL
     IF (nvalidactivivtyind=0)
      IF (ga.scheduled_dt_tm < cnvtdatetime(curdate,curtime3))
       IF (((r.status_cd=dpendingstatuscd) OR (ga.scheduled_dt_tm BETWEEN cnvtdatetime(request->
        begin_dt_tm) AND cnvtdatetime(request->end_dt_tm))) )
        nvalidactivivtyind = 1
       ENDIF
      ELSE
       nvalidactivivtyind = 1
      ENDIF
     ENDIF
    FOOT  ga.group_activity_id
     IF (nvalidactivivtyind=1)
      nactivitycnt = (nactivitycnt+ 1)
      IF (nactivitycnt > size(valid_activity->group_activity_list,5))
       lstatus = alterlist(valid_activity->group_activity_list,(nactivitycnt+ 10))
      ENDIF
      valid_activity->group_activity_list[nactivitycnt].group_activity_id = ga.group_activity_id
     ENDIF
    WITH nocounter
   ;end select
   SET lstatus = alterlist(valid_activity->group_activity_list,nactivitycnt)
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode != 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
 SUBROUTINE getqcgroupactivity(dgroupid)
   DECLARE dtcurrentdttm = f8 WITH protect, noconstant(0.0)
   DECLARE dpendingstatuscd = f8 WITH protect, noconstant(0.0)
   DECLARE lgroupactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE lreagentactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE lresultcnt = i4 WITH protect, noconstant(0)
   DECLARE ltrblcnt = i4 WITH protect, noconstant(0)
   DECLARE lresult_status_cs = i4 WITH protect, constant(325577)
   DECLARE linterp_status_cs = i4 WITH protect, constant(325575)
   DECLARE lvalidactivitycnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET lgroupactivitycnt = size(reply->group_activity_list,5)
   SET lstatus = uar_get_meaning_by_codeset(linterp_status_cs,"PENDING",1,dpendingstatuscd)
   IF (dpendingstatuscd=0.0)
    CALL subevent_add("SELECT","F","CODE_VALUE","Failed to find code value for result status")
    RETURN(nfail)
   ENDIF
   SET dtcurrentdttm = cnvtdatetime(curdate,curtime3)
   SET lvalidactivitycnt = size(valid_activity->group_activity_list,5)
   FOR (i = 1 TO lvalidactivitycnt)
     SELECT INTO "nl:"
      FROM bb_qc_group g,
       bb_qc_group_activity ga,
       bb_qc_group g2,
       prsnl p,
       bb_qc_grp_reagent_activity gra,
       bb_qc_grp_reagent_lot grl,
       bb_qc_rel_reagent rr,
       pcs_lot_information li,
       pcs_lot_definition ld,
       prsnl p2,
       bb_qc_result r,
       nomenclature n,
       prsnl p3,
       long_text lt1,
       bb_qc_result_troubleshooting_r rtr,
       bb_qc_troubleshooting rt,
       long_text lt2
      PLAN (g
       WHERE g.group_id=dgroupid)
       JOIN (ga
       WHERE (ga.group_activity_id=valid_activity->group_activity_list[i].group_activity_id))
       JOIN (g2
       WHERE outerjoin(ga.related_group_id)=g2.group_id)
       JOIN (p
       WHERE outerjoin(ga.lock_prsnl_id)=p.person_id)
       JOIN (gra
       WHERE gra.group_activity_id=ga.group_activity_id)
       JOIN (grl
       WHERE grl.prev_group_reagent_lot_id=gra.group_reagent_lot_id
        AND grl.beg_effective_dt_tm <= gra.activity_dt_tm
        AND grl.end_effective_dt_tm > gra.activity_dt_tm
        AND grl.active_ind=1)
       JOIN (rr
       WHERE rr.related_reagent_id=grl.related_reagent_id)
       JOIN (li
       WHERE li.lot_information_id=grl.lot_information_id)
       JOIN (ld
       WHERE ld.lot_definition_id=li.lot_definition_id)
       JOIN (p2
       WHERE outerjoin(gra.activity_prsnl_id)=p2.person_id)
       JOIN (r
       WHERE outerjoin(gra.group_reagent_activity_id)=r.group_reagent_activity_id)
       JOIN (n
       WHERE outerjoin(r.nomenclature_id)=n.nomenclature_id)
       JOIN (p3
       WHERE outerjoin(r.result_prsnl_id)=p3.person_id)
       JOIN (lt1
       WHERE outerjoin(r.comment_text_id)=lt1.long_text_id
        AND outerjoin(0.0) != lt1.long_text_id)
       JOIN (rtr
       WHERE outerjoin(r.qc_result_id)=rtr.qc_result_id)
       JOIN (rt
       WHERE outerjoin(rtr.troubleshooting_id)=rt.troubleshooting_id)
       JOIN (lt2
       WHERE outerjoin(rt.troubleshooting_text_id)=lt2.long_text_id
        AND outerjoin(0.0) != lt2.long_text_id)
      ORDER BY g.group_id, ga.scheduled_dt_tm DESC, ga.group_activity_id,
       grl.display_order_seq, gra.group_reagent_activity_id, r.qc_result_id
      HEAD ga.group_activity_id
       lgroupactivitycnt = (lgroupactivitycnt+ 1)
       IF (lgroupactivitycnt > size(reply->group_activity_list,5))
        lstatus = alterlist(reply->group_activity_list,(lgroupactivitycnt+ 10))
       ENDIF
       reply->group_activity_list[lgroupactivitycnt].group_activity_id = ga.group_activity_id, reply
       ->group_activity_list[lgroupactivitycnt].group_id = dgroupid, reply->group_activity_list[
       lgroupactivitycnt].group_name = g.group_name,
       reply->group_activity_list[lgroupactivitycnt].xref_group_id = ga.related_group_id, reply->
       group_activity_list[lgroupactivitycnt].xref_group_name = g2.group_name, reply->
       group_activity_list[lgroupactivitycnt].scheduled_dt_tm = ga.scheduled_dt_tm,
       reply->group_activity_list[lgroupactivitycnt].updt_cnt = ga.updt_cnt, reply->
       group_activity_list[lgroupactivitycnt].lock_dt_tm = ga.lock_dt_tm, reply->group_activity_list[
       lgroupactivitycnt].lock_prsnl_id = ga.lock_prsnl_id,
       reply->group_activity_list[lgroupactivitycnt].lock_prsnl_username = p.username
       IF (ga.scheduled_dt_tm < cnvtdatetime(curdate,curtime3)
        AND gra.interpretation_cd=dpendingstatuscd)
        reply->group_activity_list[lgroupactivitycnt].pending_ind = 1
       ELSE
        reply->group_activity_list[lgroupactivitycnt].pending_ind = 0
       ENDIF
       lreagentactivitycnt = 0
      HEAD gra.group_reagent_activity_id
       lreagentactivitycnt = (lreagentactivitycnt+ 1)
       IF (lreagentactivitycnt > size(reply->group_activity_list[lgroupactivitycnt].
        group_reagent_activity_list,5))
        lstatus = alterlist(reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list,
         (lreagentactivitycnt+ 10))
       ENDIF
       reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt]
       .activity_dt_tm = gra.activity_dt_tm, reply->group_activity_list[lgroupactivitycnt].
       group_reagent_activity_list[lreagentactivitycnt].activity_prsnl_id = gra.activity_prsnl_id,
       reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt]
       .activity_prsnl_username = p2.username,
       reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt]
       .expiration_dt_tm = li.expire_dt_tm, reply->group_activity_list[lgroupactivitycnt].
       group_reagent_activity_list[lreagentactivitycnt].group_reagent_activity_id = gra
       .group_reagent_activity_id, reply->group_activity_list[lgroupactivitycnt].
       group_reagent_activity_list[lreagentactivitycnt].group_reagent_lot_id = gra
       .group_reagent_lot_id,
       reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt]
       .interpretation_cd = gra.interpretation_cd, reply->group_activity_list[lgroupactivitycnt].
       group_reagent_activity_list[lreagentactivitycnt].lot_ident = li.lot_ident, reply->
       group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].
       lot_information_id = li.lot_information_id,
       reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt]
       .lot_status_cd = li.status_cd, reply->group_activity_list[lgroupactivitycnt].
       group_reagent_activity_list[lreagentactivitycnt].manufacturer_cd = ld.manufacturer_cd
       IF (ld.parent_entity_name="CODE_VALUE")
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].reagent_cd = ld.parent_entity_id
       ENDIF
       reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt]
       .updt_cnt = gra.updt_cnt, reply->group_activity_list[lgroupactivitycnt].
       group_reagent_activity_list[lreagentactivitycnt].visual_inspection_cd = gra
       .visual_inspection_cd, lresultcnt = 0
      HEAD r.qc_result_id
       IF (r.qc_result_id > 0)
        lresultcnt = (lresultcnt+ 1)
        IF (lresultcnt > size(reply->group_activity_list[lgroupactivitycnt].
         group_reagent_activity_list[lreagentactivitycnt].result_list,5))
         lstatus = alterlist(reply->group_activity_list[lgroupactivitycnt].
          group_reagent_activity_list[lreagentactivitycnt].result_list,(lresultcnt+ 10))
        ENDIF
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].qc_result_id = r.qc_result_id, reply->group_activity_list[
        lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
        enhancement_activity_id = r.enhancement_activity_id, reply->group_activity_list[
        lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
        control_activity_id = r.control_activity_id,
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].phase_cd = r.phase_cd, reply->group_activity_list[lgroupactivitycnt
        ].group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].result_id = r
        .nomenclature_id, reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[
        lreagentactivitycnt].result_list[lresultcnt].result_string = n.source_string,
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].result_string = n.mnemonic, reply->group_activity_list[
        lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
        result_dt_tm = r.result_dt_tm, reply->group_activity_list[lgroupactivitycnt].
        group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].result_prsnl_id = r
        .result_prsnl_id,
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].result_prsnl_username = p3.username, reply->group_activity_list[
        lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
        abnormal_ind = r.abnormal_ind, reply->group_activity_list[lgroupactivitycnt].
        group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].reason_cd = r
        .reason_cd,
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].status_cd = r.status_cd, reply->group_activity_list[
        lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
        comment_text_id = r.comment_text_id, reply->group_activity_list[lgroupactivitycnt].
        group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].comment_text = lt1
        .long_text,
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].updt_cnt = r.updt_cnt
       ENDIF
       ltrblcnt = 0
      DETAIL
       IF (rtr.result_troubleshooting_id > 0)
        ltrblcnt = (ltrblcnt+ 1)
        IF (ltrblcnt > size(reply->group_activity_list[lgroupactivitycnt].
         group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
         troubleshooting_list,5))
         lstatus = alterlist(reply->group_activity_list[lgroupactivitycnt].
          group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
          troubleshooting_list,(ltrblcnt+ 10))
        ENDIF
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].troubleshooting_list[ltrblcnt].result_troubleshooting_id = rtr
        .result_troubleshooting_id, reply->group_activity_list[lgroupactivitycnt].
        group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
        troubleshooting_list[ltrblcnt].troubleshooting_id = rt.troubleshooting_id, reply->
        group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt].
        result_list[lresultcnt].troubleshooting_list[ltrblcnt].troubleshooting_text_id = rt
        .troubleshooting_text_id,
        reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[lreagentactivitycnt
        ].result_list[lresultcnt].troubleshooting_list[ltrblcnt].troubleshooting_text = lt2.long_text
       ENDIF
      FOOT  r.qc_result_id
       IF (r.qc_result_id > 0)
        lstatus = alterlist(reply->group_activity_list[lgroupactivitycnt].
         group_reagent_activity_list[lreagentactivitycnt].result_list[lresultcnt].
         troubleshooting_list,ltrblcnt)
       ENDIF
      FOOT  gra.group_reagent_activity_id
       lstatus = alterlist(reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list[
        lreagentactivitycnt].result_list,lresultcnt)
      FOOT  ga.group_activity_id
       lstatus = alterlist(reply->group_activity_list[lgroupactivitycnt].group_reagent_activity_list,
        lreagentactivitycnt)
      FOOT REPORT
       lstatus = alterlist(reply->group_activity_list,lgroupactivitycnt)
      WITH nocounter
     ;end select
   ENDFOR
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode != 0)
    RETURN(nfail)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
END GO
