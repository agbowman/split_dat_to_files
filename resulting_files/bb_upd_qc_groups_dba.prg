CREATE PROGRAM bb_upd_qc_groups:dba
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
 RECORD reply(
   1 group_list[*]
     2 group_key = i4
     2 group_id = f8
     2 updt_cnt = i4
     2 status = i4
     2 xref_list[*]
       3 group_xref_key = i4
       3 group_xref_id = f8
       3 status = i4
     2 reagent_lot_list[*]
       3 group_reagent_key = i4
       3 group_reagent_lot_id = f8
       3 updt_cnt = i4
       3 status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE nno_matches = i2 WITH protect, constant(2)
 DECLARE lupd_child = i4 WITH protect, constant(0)
 DECLARE lins_new = i4 WITH protect, constant(1)
 DECLARE lupd_existing = i4 WITH protect, constant(2)
 DECLARE ldelete = i4 WITH protect, constant(3)
 DECLARE dtbeg_date = f8 WITH protect, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 DECLARE dtend_date = f8 WITH protect, constant(cnvtdatetime("31-DEC-2100 23:59:59.99"))
 DECLARE lbb_qc_visual_inspection_cs = i4 WITH protect, constant(325574)
 DECLARE lbb_qc_interpretations_cs = i4 WITH protect, constant(325575)
 DECLARE lbb_qc_result_status_cs = i4 WITH protect, constant(325577)
 DECLARE lgroup_cnt = i4 WITH protect, constant(size(request->group_list,5))
 DECLARE lgroupidx = i4 WITH protect, noconstant(0)
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE lstatus = i4 WITH protect, noconstant(0)
 DECLARE lgrouperrorcnt = i4 WITH protect, noconstant(0)
 DECLARE insertnewgroup(lgroupidx=i4(value)) = i2 WITH private
 DECLARE updategroup(lgroupidx=i4(value)) = i2 WITH private
 DECLARE updategroupxrefs(lgroupidx=i4(value)) = i2 WITH private
 DECLARE updategroupreagentlots(lgroupidx=i4(value)) = i2 WITH private
 DECLARE cleanupfutureactivity(lgroupidx=i4(value)) = i2 WITH private
#begin_script
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET lstatus = alterlist(reply->group_list,lgroup_cnt)
 FOR (lgroupidx = 1 TO lgroup_cnt)
   SET reply->group_list[lgroupidx].status = nsuccess
   IF ((request->group_list[lgroupidx].save_flag=lins_new))
    SET reply->group_list[lgroupidx].updt_cnt = 0
    IF (insertnewgroup(lgroupidx)=nfail)
     SET reply->group_list[lgroupidx].status = nfail
     SET lgrouperrorcnt = (lgrouperrorcnt+ 1)
    ENDIF
   ELSEIF ((request->group_list[lgroupidx].save_flag=lupd_existing))
    IF (cleanupfutureactivity(lgroupidx)=nsuccess)
     IF (updategroup(lgroupidx)=nsuccess)
      SET reply->group_list[lgroupidx].updt_cnt = (request->group_list[lgroupidx].updt_cnt+ 1)
     ELSE
      SET reply->group_list[lgroupidx].updt_cnt = request->group_list[lgroupidx].updt_cnt
      SET reply->group_list[lgroupidx].status = nfail
      SET lgrouperrorcnt = (lgrouperrorcnt+ 1)
     ENDIF
    ENDIF
   ENDIF
   SET reply->group_list[lgroupidx].group_id = request->group_list[lgroupidx].group_id
   SET reply->group_list[lgroupidx].group_key = request->group_list[lgroupidx].group_key
   IF ((reply->group_list[lgroupidx].status=nsuccess))
    IF ((request->group_list[lgroupidx].updt_xrefs_ind=1))
     IF (updategroupxrefs(lgroupidx)=nfail)
      SET lgrouperrorcnt = (lgrouperrorcnt+ 1)
      SET reply->group_list[lgroupidx].status = nfail
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->group_list[lgroupidx].status=nsuccess))
    IF (updategroupreagentlots(lgroupidx)=nfail)
     SET lgrouperrorcnt = (lgrouperrorcnt+ 1)
     SET reply->group_list[lgroupidx].status = nfail
    ENDIF
   ENDIF
   IF ((reply->group_list[lgroupidx].status=nsuccess))
    IF (scheduleqcgroupactivity(request->group_list[lgroupidx].group_id,request->group_list[lgroupidx
     ].start_schedule_now_ind,0.0,0.0)=nfail)
     SET lgrouperrorcnt = (lgrouperrorcnt+ 1)
     SET reply->group_list[lgroupidx].status = nfail
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 IF (lgrouperrorcnt > 0)
  IF (lgroup_cnt > lgrouperrorcnt)
   SET reply->status_data.status = "P"
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
  CALL subevent_add("SELECT","F","BB_QC_GROUPS",build("Failed to update/insert (",lgrouperrorcnt,
    ") groups."))
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status != "F"))
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SUBROUTINE insertnewgroup(lgroupidx)
   DECLARE dnewgroupid = f8 WITH protect, noconstant(0.0)
   SET dnewgroupid = generateid(0)
   IF (dnewgroupid > 0)
    INSERT  FROM bb_qc_group g
     SET g.group_id = dnewgroupid, g.group_name = request->group_list[lgroupidx].group_name, g
      .group_name_key = cnvtalphanum(request->group_list[lgroupidx].group_name),
      g.group_desc = request->group_list[lgroupidx].group_desc, g.service_resource_cd = request->
      group_list[lgroupidx].service_resource_cd, g.active_ind = request->group_list[lgroupidx].
      active_ind,
      g.require_validation_ind = request->group_list[lgroupidx].require_validation_ind, g.schedule_cd
       = request->group_list[lgroupidx].schedule_cd, g.updt_cnt = 0,
      g.updt_id = reqinfo->updt_id, g.updt_dt_tm = cnvtdatetime(curdate,curtime3), g.updt_task =
      reqinfo->updt_task,
      g.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET lerrorcode = error(serrormsg,1)
    IF (lerrorcode=0)
     SET request->group_list[lgroupidx].group_id = dnewgroupid
     RETURN(nsuccess)
    ENDIF
   ENDIF
   RETURN(nfail)
 END ;Subroutine
 SUBROUTINE updategroup(lgroupidx)
   DECLARE nfoundind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM bb_qc_group g
    PLAN (g
     WHERE (g.group_id=request->group_list[lgroupidx].group_id)
      AND (g.updt_cnt=request->group_list[lgroupidx].updt_cnt))
    DETAIL
     nfoundind = 1
    WITH nocounter, forupdate(g)
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode=0)
    UPDATE  FROM bb_qc_group g
     SET g.group_name = request->group_list[lgroupidx].group_name, g.group_name_key = cnvtalphanum(
       request->group_list[lgroupidx].group_name), g.group_desc = request->group_list[lgroupidx].
      group_desc,
      g.service_resource_cd = request->group_list[lgroupidx].service_resource_cd, g.active_ind =
      request->group_list[lgroupidx].active_ind, g.require_validation_ind = request->group_list[
      lgroupidx].require_validation_ind,
      g.schedule_cd = request->group_list[lgroupidx].schedule_cd, g.updt_cnt = (request->group_list[
      lgroupidx].updt_cnt+ 1), g.updt_id = reqinfo->updt_id,
      g.updt_dt_tm = cnvtdatetime(curdate,curtime3), g.updt_task = reqinfo->updt_task, g.updt_applctx
       = reqinfo->updt_applctx
     PLAN (g
      WHERE (g.group_id=request->group_list[lgroupidx].group_id)
       AND (g.updt_cnt=request->group_list[lgroupidx].updt_cnt))
     WITH nocounter
    ;end update
   ENDIF
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode != 0)
    RETURN(nfail)
   ELSEIF (nfoundind=0)
    RETURN(nno_matches)
   ELSE
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
 SUBROUTINE updategroupxrefs(lgroupidx)
   DECLARE lxrefidx = i4 WITH protect, noconstant(0)
   DECLARE lxrefcnt = i4 WITH protect, noconstant(0)
   DECLARE dxrefid = f8 WITH protect, noconstant(0.0)
   DECLARE nreturnstatus = i2 WITH protect, noconstant(nsuccess)
   DELETE  FROM bb_qc_group_xref gr
    WHERE (gr.group_id=request->group_list[lgroupidx].group_id)
    WITH nocounter
   ;end delete
   SET lxrefcnt = size(request->group_list[lgroupidx].xref_list,5)
   SET lstatus = alterlist(reply->group_list[lgroupidx].xref_list,lxrefcnt)
   FOR (lxrefidx = 1 TO lxrefcnt)
     IF ((request->group_list[lgroupidx].xref_list[lxrefidx].group_xref_id > 0))
      SET dxrefid = request->group_list[lgroupidx].xref_list[lxrefidx].group_xref_id
     ELSE
      SET dxrefid = generateid(0)
     ENDIF
     IF (dxrefid > 0)
      INSERT  FROM bb_qc_group_xref gr
       SET gr.group_xref_id = dxrefid, gr.group_id = request->group_list[lgroupidx].group_id, gr
        .related_group_id = request->group_list[lgroupidx].xref_list[lxrefidx].xref_group_id,
        gr.updt_cnt = 0, gr.updt_id = reqinfo->updt_id, gr.updt_dt_tm = cnvtdatetime(curdate,curtime3
         ),
        gr.updt_task = reqinfo->updt_task, gr.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
     SET reply->group_list[lgroupidx].xref_list[lxrefidx].group_xref_key = request->group_list[
     lgroupidx].xref_list[lxrefidx].group_xref_key
     SET reply->group_list[lgroupidx].xref_list[lxrefidx].group_xref_id = dxrefid
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode != 0)
      SET reply->group_list[lgroupidx].xref_list[lxrefidx].status = nfail
      SET nreturnstatus = nfail
     ELSE
      SET reply->group_list[lgroupidx].xref_list[lxrefidx].status = nsuccess
     ENDIF
   ENDFOR
   RETURN(nreturnstatus)
 END ;Subroutine
 SUBROUTINE updategroupreagentlots(lgroupidx)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lupdateerrorcnt = i4 WITH protect, noconstant(0)
   DECLARE linsidx = i4 WITH protect, noconstant(0)
   DECLARE linscnt = i4 WITH protect, noconstant(0)
   DECLARE lupdidx = i4 WITH protect, noconstant(0)
   DECLARE lupdcnt = i4 WITH protect, noconstant(0)
   DECLARE lsuccesscnt = i4 WITH protect, noconstant(0)
   DECLARE lreagentidx = i4 WITH protect, noconstant(0)
   DECLARE dnewreagentlotid = f8 WITH protect, noconstant(0.0)
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE lnewinscnt = i4 WITH protect, noconstant(0)
   RECORD ins_grp_reagent_lot(
     1 rows[*]
       2 group_reagent_lot_id = f8
       2 prev_group_reagent_lot_id = f8
       2 active_ind = i2
       2 lot_information_id = f8
       2 related_reagent_id = f8
       2 display_order = i4
       2 current_ind = i2
       2 updt_cnt = i4
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
   ) WITH protect
   RECORD upd_grp_reagent_lot(
     1 rows[*]
       2 group_reagent_lot_id = f8
       2 prev_group_reagent_lot_id = f8
       2 active_ind = i2
       2 lot_information_id = f8
       2 related_reagent_id = f8
       2 display_order = i4
       2 current_ind = i2
       2 updt_cnt = i4
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
   ) WITH protect
   IF (size(request->group_list[lgroupidx].reagent_lot_list,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(request->group_list[lgroupidx].reagent_lot_list,5))),
      bb_qc_grp_reagent_lot grl
     PLAN (d1
      WHERE (request->group_list[lgroupidx].reagent_lot_list[d1.seq].save_flag=lupd_existing))
      JOIN (grl
      WHERE (grl.group_reagent_lot_id=request->group_list[lgroupidx].reagent_lot_list[d1.seq].
      group_reagent_lot_id)
       AND grl.group_reagent_lot_id=grl.prev_group_reagent_lot_id
       AND grl.active_ind=1
       AND grl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND grl.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND grl.group_reagent_lot_id > 0
       AND (grl.updt_cnt=request->group_list[lgroupidx].reagent_lot_list[d1.seq].updt_cnt))
     DETAIL
      i = (i+ 1)
      IF (i > size(upd_grp_reagent_lot->rows,5))
       lstatus = alterlist(upd_grp_reagent_lot->rows,(i+ 10)), lstatus = alterlist(
        ins_grp_reagent_lot->rows,(i+ 10))
      ENDIF
      upd_grp_reagent_lot->rows[i].group_reagent_lot_id = grl.group_reagent_lot_id,
      upd_grp_reagent_lot->rows[i].prev_group_reagent_lot_id = grl.group_reagent_lot_id,
      ins_grp_reagent_lot->rows[i].group_reagent_lot_id = 0.0,
      ins_grp_reagent_lot->rows[i].prev_group_reagent_lot_id = grl.group_reagent_lot_id,
      upd_grp_reagent_lot->rows[i].lot_information_id = request->group_list[lgroupidx].
      reagent_lot_list[d1.seq].lot_information_id, ins_grp_reagent_lot->rows[i].lot_information_id =
      grl.lot_information_id,
      upd_grp_reagent_lot->rows[i].active_ind = request->group_list[lgroupidx].reagent_lot_list[d1
      .seq].active_ind, ins_grp_reagent_lot->rows[i].active_ind = grl.active_ind, upd_grp_reagent_lot
      ->rows[i].related_reagent_id = request->group_list[lgroupidx].reagent_lot_list[d1.seq].
      related_reagent_id,
      ins_grp_reagent_lot->rows[i].related_reagent_id = grl.related_reagent_id, upd_grp_reagent_lot->
      rows[i].display_order = request->group_list[lgroupidx].reagent_lot_list[d1.seq].display_order,
      ins_grp_reagent_lot->rows[i].display_order = grl.display_order_seq,
      upd_grp_reagent_lot->rows[i].current_ind = request->group_list[lgroupidx].reagent_lot_list[d1
      .seq].current_ind, ins_grp_reagent_lot->rows[i].current_ind = request->group_list[lgroupidx].
      reagent_lot_list[d1.seq].current_ind, upd_grp_reagent_lot->rows[i].updt_cnt = grl.updt_cnt,
      ins_grp_reagent_lot->rows[i].display_order = grl.display_order_seq, ins_grp_reagent_lot->rows[i
      ].updt_cnt = grl.updt_cnt, upd_grp_reagent_lot->rows[i].beg_effective_dt_tm = cnvtdatetime(
       curdate,curtime3),
      ins_grp_reagent_lot->rows[i].beg_effective_dt_tm = grl.beg_effective_dt_tm, upd_grp_reagent_lot
      ->rows[i].end_effective_dt_tm = cnvtdatetime(dtend_date), ins_grp_reagent_lot->rows[i].
      end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
      IF ((request->group_list[lgroupidx].reagent_lot_list[d1.seq].updt_cnt != grl.updt_cnt))
       lupdateerrorcnt = (lupdateerrorcnt+ 1)
      ENDIF
     WITH nocounter, forupdate(grl)
    ;end select
   ENDIF
   SET lstatus = alterlist(upd_grp_reagent_lot->rows,i)
   SET lstatus = alterlist(ins_grp_reagent_lot->rows,i)
   SET lerrorcode = error(serrormsg,1)
   IF (((lerrorcode > 0) OR (lupdateerrorcnt > 0)) )
    CALL subevent_add("SELECT","F","BB_QC_GRP_REAGENT_LOT","Error locking rows for update.")
    RETURN(0)
   ENDIF
   IF (size(request->group_list[lgroupidx].reagent_lot_list,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(request->group_list[lgroupidx].reagent_lot_list,5)))
     PLAN (d1
      WHERE (request->group_list[lgroupidx].reagent_lot_list[d1.seq].save_flag=lins_new))
     HEAD REPORT
      i = size(ins_grp_reagent_lot->rows,5)
     DETAIL
      i = (i+ 1)
      IF (i > size(ins_grp_reagent_lot->rows,5))
       lstatus = alterlist(ins_grp_reagent_lot->rows,(i+ 10))
      ENDIF
      ins_grp_reagent_lot->rows[i].group_reagent_lot_id = 0.0, ins_grp_reagent_lot->rows[i].
      prev_group_reagent_lot_id = 0.0, ins_grp_reagent_lot->rows[i].active_ind = 1,
      ins_grp_reagent_lot->rows[i].lot_information_id = request->group_list[lgroupidx].
      reagent_lot_list[d1.seq].lot_information_id, ins_grp_reagent_lot->rows[i].related_reagent_id =
      request->group_list[lgroupidx].reagent_lot_list[d1.seq].related_reagent_id, ins_grp_reagent_lot
      ->rows[i].display_order = request->group_list[lgroupidx].reagent_lot_list[d1.seq].display_order,
      ins_grp_reagent_lot->rows[i].current_ind = request->group_list[lgroupidx].reagent_lot_list[d1
      .seq].current_ind, ins_grp_reagent_lot->rows[i].beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), ins_grp_reagent_lot->rows[i].end_effective_dt_tm = cnvtdatetime(dtend_date)
     WITH nocounter
    ;end select
    SET lstatus = alterlist(ins_grp_reagent_lot->rows,i)
   ENDIF
   SET lupdcnt = size(upd_grp_reagent_lot->rows,5)
   FOR (lupdidx = 1 TO lupdcnt)
     UPDATE  FROM bb_qc_grp_reagent_lot grl
      SET grl.active_ind = upd_grp_reagent_lot->rows[lupdidx].active_ind, grl.active_status_cd =
       IF ((ins_grp_reagent_lot->rows[linsidx].active_ind=1)) reqdata->active_status_cd
       ELSE reqdata->deleted_cd
       ENDIF
       , grl.lot_information_id = upd_grp_reagent_lot->rows[lupdidx].lot_information_id,
       grl.related_reagent_id = upd_grp_reagent_lot->rows[lupdidx].related_reagent_id, grl
       .display_order_seq = upd_grp_reagent_lot->rows[lupdidx].display_order, grl.current_ind =
       upd_grp_reagent_lot->rows[lupdidx].current_ind,
       grl.beg_effective_dt_tm = cnvtdatetime(upd_grp_reagent_lot->rows[lupdidx].beg_effective_dt_tm),
       grl.end_effective_dt_tm = cnvtdatetime(upd_grp_reagent_lot->rows[lupdidx].end_effective_dt_tm),
       grl.updt_cnt = (grl.updt_cnt+ 1),
       grl.updt_id = reqinfo->updt_id, grl.updt_dt_tm = cnvtdatetime(curdate,curtime3), grl.updt_task
        = reqinfo->updt_task,
       grl.updt_applctx = reqinfo->updt_applctx
      PLAN (grl
       WHERE (grl.group_reagent_lot_id=upd_grp_reagent_lot->rows[lupdidx].group_reagent_lot_id)
        AND grl.group_reagent_lot_id=grl.prev_group_reagent_lot_id)
      WITH nocounter
     ;end update
     SET lstatus = alterlist(reply->group_list[lgroupidx].reagent_lot_list,lupdidx)
     SET reply->group_list[lgroupidx].reagent_lot_list[lupdidx].group_reagent_lot_id =
     upd_grp_reagent_lot->rows[lupdidx].group_reagent_lot_id
     SET reply->group_list[lgroupidx].reagent_lot_list[lupdidx].group_reagent_key = request->
     group_list[lgroupidx].reagent_lot_list[lupdidx].group_reagent_key
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode=0)
      SET reply->group_list[lgroupidx].reagent_lot_list[lupdidx].status = nsuccess
      SET reply->group_list[lgroupidx].reagent_lot_list[lupdidx].updt_cnt = (upd_grp_reagent_lot->
      rows[lupdidx].updt_cnt+ 1)
      SET lsuccesscnt = (lsuccesscnt+ 1)
     ELSE
      SET reply->group_list[lgroupidx].reagent_lot_list[lupdidx].status = nfail
      SET reply->group_list[lgroupidx].reagent_lot_list[lupdidx].updt_cnt = upd_grp_reagent_lot->
      rows[lupdidx].updt_cnt
     ENDIF
   ENDFOR
   IF (lsuccesscnt=0
    AND lupdcnt > 0)
    CALL subevent_add("UPDATE","F","BB_QC_GRP_REAGENT_LOT","Failed to update group reagent lots.")
    RETURN(0)
   ELSEIF (lsuccesscnt < lupdcnt)
    CALL subevent_add("UPDATE","P","BB_QC_GRP_REAGENT_LOT",
     "Some of the group reagent lots were not updated.")
   ENDIF
   SET lsuccesscnt = 0
   SET linscnt = size(ins_grp_reagent_lot->rows,5)
   FOR (linsidx = 1 TO linscnt)
     SET dnewreagentlotid = generateid(0)
     IF (dnewreagentlotid > 0)
      INSERT  FROM bb_qc_grp_reagent_lot grl
       SET grl.group_reagent_lot_id = dnewreagentlotid, grl.prev_group_reagent_lot_id =
        IF ((ins_grp_reagent_lot->rows[linsidx].prev_group_reagent_lot_id=0)) dnewreagentlotid
        ELSE ins_grp_reagent_lot->rows[linsidx].prev_group_reagent_lot_id
        ENDIF
        , grl.group_id = reply->group_list[lgroupidx].group_id,
        grl.active_ind = ins_grp_reagent_lot->rows[linsidx].active_ind, grl.active_status_cd =
        IF ((ins_grp_reagent_lot->rows[linsidx].active_ind=1)) reqdata->active_status_cd
        ELSE reqdata->deleted_cd
        ENDIF
        , grl.lot_information_id = ins_grp_reagent_lot->rows[linsidx].lot_information_id,
        grl.related_reagent_id = ins_grp_reagent_lot->rows[linsidx].related_reagent_id, grl
        .display_order_seq = ins_grp_reagent_lot->rows[linsidx].display_order, grl.current_ind =
        ins_grp_reagent_lot->rows[linsidx].current_ind,
        grl.beg_effective_dt_tm = cnvtdatetime(ins_grp_reagent_lot->rows[linsidx].beg_effective_dt_tm
         ), grl.end_effective_dt_tm = cnvtdatetime(ins_grp_reagent_lot->rows[linsidx].
         end_effective_dt_tm), grl.updt_cnt = ins_grp_reagent_lot->rows[linsidx].updt_cnt,
        grl.updt_id = reqinfo->updt_id, grl.updt_dt_tm = cnvtdatetime(curdate,curtime3), grl
        .updt_task = reqinfo->updt_task,
        grl.updt_applctx = reqinfo->updt_applctx
       PLAN (grl)
       WITH nocounter
      ;end insert
     ENDIF
     IF ((ins_grp_reagent_lot->rows[linsidx].prev_group_reagent_lot_id=ins_grp_reagent_lot->rows[
     linsidx].group_reagent_lot_id))
      SET lnewinscnt = (lnewinscnt+ 1)
      SET lreagentidx = (lupdcnt+ lnewinscnt)
      SET lstatus = alterlist(reply->group_list[lgroupidx].reagent_lot_list,lreagentidx)
      SET reply->group_list[lgroupidx].reagent_lot_list[lreagentidx].group_reagent_lot_id =
      dnewreagentlotid
      SET reply->group_list[lgroupidx].reagent_lot_list[lreagentidx].group_reagent_key = request->
      group_list[lgroupidx].reagent_lot_list[lreagentidx].group_reagent_key
     ENDIF
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode=0
      AND dnewreagentlotid > 0)
      SET reply->group_list[lgroupidx].reagent_lot_list[lreagentidx].status = nsuccess
      SET lsuccesscnt = (lsuccesscnt+ 1)
     ELSE
      SET reply->group_list[lgroupidx].reagent_lot_list[lreagentidx].status = nfail
     ENDIF
     SET dnewregentlotid = 0
   ENDFOR
   IF (lsuccesscnt=0
    AND linscnt > 0)
    CALL subevent_add("UPDATE","F","BB_QC_GRP_REAGENT_LOT","Failed to insert group reagent lots.")
    RETURN(0)
   ELSEIF (lsuccesscnt < linscnt)
    CALL subevent_add("UPDATE","P","BB_QC_GRP_REAGENT_LOT",
     "Some of the group reagent lots were not inserted.")
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE cleanupfutureactivity(lgroupidx)
   DECLARE grp_cnt = i4 WITH protect, noconstant(0)
   DECLARE rgnt_cnt = i4 WITH protect, noconstant(0)
   DECLARE result_cnt = i4 WITH protect, noconstant(0)
   RECORD group_cleanup(
     1 group_activity_list[*]
       2 group_activity_id = f8
       2 max_reagent_count = i4
       2 reagent_activity_list[*]
         3 group_reagent_activity_id = f8
         3 max_result_count = i4
         3 result_list[*]
           4 result_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM bb_qc_group_activity bqga,
     bb_qc_grp_reagent_activity bqgra,
     bb_qc_result bqr
    PLAN (bqga
     WHERE (bqga.group_id=request->group_list[lgroupidx].group_id)
      AND bqga.scheduled_dt_tm > cnvtdatetime(curdate,curtime3)
      AND bqga.lock_prsnl_id=0)
     JOIN (bqgra
     WHERE bqgra.group_activity_id=bqga.group_activity_id)
     JOIN (bqr
     WHERE bqr.group_reagent_activity_id=outerjoin(bqgra.group_reagent_activity_id))
    ORDER BY bqga.group_activity_id, bqgra.group_reagent_activity_id, bqr.qc_result_id
    HEAD REPORT
     grp_cnt = 0, rgnt_cnt = 0, result_cnt = 0
    HEAD bqga.group_activity_id
     grp_cnt = (grp_cnt+ 1)
     IF (grp_cnt > size(group_cleanup->group_activity_list,5))
      lstatus = alterlist(group_cleanup->group_activity_list,(grp_cnt+ 10))
     ENDIF
     group_cleanup->group_activity_list[grp_cnt].group_activity_id = bqga.group_activity_id, rgnt_cnt
      = 0
    HEAD bqgra.group_reagent_activity_id
     rgnt_cnt = (rgnt_cnt+ 1)
     IF (rgnt_cnt > size(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list,5))
      lstatus = alterlist(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list,(rgnt_cnt
       + 10))
     ENDIF
     IF ((rgnt_cnt > group_cleanup->group_activity_list[grp_cnt].max_reagent_count))
      group_cleanup->group_activity_list[grp_cnt].max_reagent_count = rgnt_cnt
     ENDIF
     group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[rgnt_cnt].
     group_reagent_activity_id = bqgra.group_reagent_activity_id, result_cnt = 0
    HEAD bqr.qc_result_id
     IF (bqr.qc_result_id > 0)
      result_cnt = (result_cnt+ 1),
      CALL echo(result_cnt)
      IF (result_cnt > size(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[
       rgnt_cnt].result_list,5))
       CALL echo("resize"), lstatus = alterlist(group_cleanup->group_activity_list[grp_cnt].
        reagent_activity_list[rgnt_cnt].result_list,(result_cnt+ 10))
      ENDIF
      IF ((result_cnt > group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[rgnt_cnt].
      max_result_count))
       group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[rgnt_cnt].max_result_count
        = result_cnt
      ENDIF
      group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[rgnt_cnt].result_list[
      result_cnt].result_id = bqr.qc_result_id
     ENDIF
    FOOT  bqgra.group_reagent_activity_id
     lstatus = alterlist(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[rgnt_cnt].
      result_list,result_cnt)
    FOOT  bqga.group_activity_id
     lstatus = alterlist(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list,rgnt_cnt)
    FOOT REPORT
     lstatus = alterlist(group_cleanup->group_activity_list,grp_cnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode != 0)
    CALL subevent_add("SELECT","F","BB_QC_GROUP_ACTIVITY","Failure when selected future activity.")
    RETURN(nfail)
   ENDIF
   FOR (grp_cnt = 1 TO size(group_cleanup->group_activity_list,5))
    FOR (rgnt_cnt = 1 TO size(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list,5))
     FOR (result_cnt = 1 TO size(group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[
      rgnt_cnt].result_list,5))
      DELETE  FROM bb_qc_result_troubleshooting_r bqtr
       WHERE (bqtr.qc_result_id=group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[
       rgnt_cnt].result_list[result_cnt].result_id)
       WITH nocounter
      ;end delete
      DELETE  FROM bb_qc_result bqr
       WHERE (bqr.qc_result_id=group_cleanup->group_activity_list[grp_cnt].reagent_activity_list[
       rgnt_cnt].result_list[result_cnt].result_id)
       WITH nocounter
      ;end delete
     ENDFOR
     DELETE  FROM bb_qc_grp_reagent_activity bqgra
      WHERE (bqgra.group_reagent_activity_id=group_cleanup->group_activity_list[grp_cnt].
      reagent_activity_list[rgnt_cnt].group_reagent_activity_id)
      WITH nocounter
     ;end delete
    ENDFOR
    DELETE  FROM bb_qc_group_activity bqga
     WHERE (bqga.group_activity_id=group_cleanup->group_activity_list[grp_cnt].group_activity_id)
     WITH nocounter
    ;end delete
   ENDFOR
   FREE SET group_cleanup
   RETURN(nsuccess)
 END ;Subroutine
END GO
