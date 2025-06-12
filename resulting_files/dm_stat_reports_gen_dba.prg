CREATE PROGRAM dm_stat_reports_gen:dba
 DECLARE findcomma(x=vc(ref),n=i4) = i4
 DECLARE findchar(x=vc(ref),n=i4,c=vc) = i4
 DECLARE findnextchar(x=vc(ref),c=vc,dmt_position=i4) = i4
 DECLARE findcharworker(x=vc,n=i4,c=vc,dmt_position=i4) = i4
 DECLARE ntharg(x=vc(ref),n=i4,c=vc) = vc
 DECLARE nextarg(x=vc(ref),c=vc) = vc
 DECLARE proflog(x=vc) = null
 SET startpos = 0
 SET endpos = 0
 SUBROUTINE findcomma(x,n)
   RETURN(findchar(x,n,","))
 END ;Subroutine
 SUBROUTINE findnextchar(x,c,dmt_position)
   RETURN(findcharworker(x,1,c,dmt_position))
 END ;Subroutine
 SUBROUTINE findchar(x,n,c)
   RETURN(findcharworker(x,n,c,0))
 END ;Subroutine
 SUBROUTINE findcharworker(x,n,c,dmt_position)
   SET retpos = 1
   SET found = 0
   WHILE (retpos != 0
    AND found != n)
     SET retpos = findstring(c,x,(dmt_position+ 1))
     SET dmt_position = retpos
     IF (dmt_position)
      SET found = (found+ 1)
     ENDIF
   ENDWHILE
   RETURN(dmt_position)
 END ;Subroutine
 SUBROUTINE nextarg(x,c)
   SET str = fillstring(132," ")
   SET len = size(x)
   SET startpos = endpos
   SET startpos = findnextchar(x,c,startpos)
   IF (startpos=0)
    RETURN(trim(str))
   ELSE
    SET endpos = findnextchar(x,c,startpos)
    IF (endpos=0)
     SET endpos = len
    ELSE
     SET endpos = (endpos - 1)
    ENDIF
    SET startpos = (startpos+ 1)
    IF (startpos > endpos)
     RETURN(trim(str))
    ELSE
     RETURN(substring(startpos,((endpos - startpos)+ 1),x))
    ENDIF
   ENDIF
   RETURN(trim(str))
 END ;Subroutine
 SUBROUTINE ntharg(x,n,c)
   SET str = fillstring(132," ")
   SET len = size(x)
   SET startpos = 0
   SET endpos = 0
   IF (len < 1)
    RETURN(trim(str))
   ENDIF
   IF (n < 1)
    RETURN(trim(str))
   ELSE
    IF (n=1)
     SET startpos = 1
    ELSE
     SET startpos = findchar(x,(n - 1),c)
     IF (startpos=len)
      RETURN(trim(str))
     ELSEIF (startpos=0)
      SET startpos = 1
     ELSE
      SET startpos = (startpos+ 1)
     ENDIF
    ENDIF
    SET endpos = findnextchar(x,c,(startpos - 1))
    IF (endpos=1)
     RETURN(trim(str))
    ELSEIF (endpos=0)
     SET endpos = len
    ELSE
     SET endpos = (endpos - 1)
    ENDIF
    SET str = substring(startpos,((endpos - startpos)+ 1),x)
   ENDIF
   RETURN(trim(str))
 END ;Subroutine
 SUBROUTINE proflog(x)
   CALL echo(concat(format(cnvtdatetime(curdate,curtime3),";;Q")," ",curprog,": ",x))
 END ;Subroutine
 RECORD report_data(
   1 title = vc
   1 column[*]
     2 rname = vc
     2 tcname = vc
     2 pos = i2
 )
 DECLARE col_cnt = i2
 RECORD datalinestruct(
   1 timer = vc
   1 application = vc
   1 subtimer = vc
   1 min = f8
   1 max = f8
   1 count = i4
   1 sumsq = f8
   1 total = f8
   1 stddev = f8
   1 avg = f8
   1 trgtval = f8
   1 hit = i4
   1 miss = i4
 )
 RECORD reportdata(
   1 rptsection[2]
     2 grpmain[*]
       3 grpitem = vc
       3 grpdata[*]
         4 dtlitem = vc
         4 count = i4
         4 sumsq = f8
         4 total = f8
         4 min = f8
         4 max = f8
         4 stddev = f8
         4 avg = f8
         4 trgtval = f8
         4 hit = i4
         4 miss = i4
 )
 DECLARE snap_date = vc
 DECLARE dsrg_str = vc
 DECLARE order_val = vc
 DECLARE dm_disp = vc
 DECLARE counter = i2
 DECLARE dsrg_fini = i2
 DECLARE dsrg_tempstr = vc
 DECLARE dsrg_fname = vc
 DECLARE dsrg_title2 = vc
 DECLARE whereclause = vc
 SET counter = 0
 DECLARE creatertmscsv(x=vc) = null
 DECLARE displayrtmsreport(x=vc) = null
 DECLARE parsertmsdata(timer=vc,datastring=vc) = null
 DECLARE displayitem(itemtext=vc) = null
 DECLARE datastructureflip(x=vc) = null
 DECLARE loadreportdata(x=vc) = null
 DECLARE path = vc
 DECLARE defaultresponsetime = f8 WITH noconstant(0.0)
 IF (validate(timerepository_def,999)=999)
  DECLARE timerepository_def = i2 WITH persist
  SET timerepository_def = 1
  DECLARE uar_timer_getconfigdouble(p1=vc(ref),p2=f8(ref),p3=i4(value)) = i4 WITH image_axp =
  "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
  "TIMER_GetConfigDouble",
  persist
 ENDIF
 SET path = "timers/sla/DefaultResponseTime"
 IF (uar_timer_getconfigdouble(nullterm(path),defaultresponsetime,0)=0)
  SET defaultresponsetime = 3.0
 ENDIF
 DECLARE fieldcounter = i4 WITH noconstant(0)
 DECLARE bucket = f8 WITH noconstant(0.0)
 DECLARE bucketcount = i4 WITH noconstant(0)
 DECLARE timerdisplay = vc
 SET timerdisplay = fillstring(100," ")
 DECLARE datedisp = vc
 DECLARE countdisp = vc
 DECLARE totaldisp = vc
 DECLARE mindisp = vc
 DECLARE maxdisp = vc
 DECLARE stddevdisp = vc
 DECLARE avgdisp = vc
 DECLARE trgtvaldisp = vc
 DECLARE hitdisp = vc
 DECLARE missdisp = vc
 SET datedisp = fillstring(100," ")
 SET countdisp = fillstring(100," ")
 SET totaldisp = fillstring(100," ")
 SET mindisp = fillstring(100," ")
 SET maxdisp = fillstring(100," ")
 SET stddevdisp = fillstring(100," ")
 SET avgdisp = fillstring(100," ")
 SET trgtvaldisp = fillstring(100," ")
 SET hitdisp = fillstring(100," ")
 SET missdisp = fillstring(100," ")
 SUBROUTINE loadreportdata(x)
   SELECT INTO "nl:"
    FROM dm_stat_snaps ds,
     dm_stat_snaps_values dv
    PLAN (ds
     WHERE ds.snapshot_type="SLA_AGGREGATE_HOURLY*"
      AND ds.stat_snap_dt_tm BETWEEN cnvtdatetimeutc(dsr_reports->begin_dt_tm,1) AND cnvtdatetimeutc(
      dsr_reports->end_dt_tm,1))
     JOIN (dv
     WHERE ds.dm_stat_snap_id=dv.dm_stat_snap_id)
    ORDER BY ds.stat_snap_dt_tm
    HEAD REPORT
     grpcntr = 0, rowcntr = 0
    HEAD ds.stat_snap_dt_tm
     dtstring = format(cnvtdatetime(ds.stat_snap_dt_tm),"DD-MMM-YYYY HH:MM:SS;;Q")
     IF ((dsr_reports->report_type="SLA_AGGREGATE_HOURLY1"))
      dtstring = substring(1,11,dtstring)
     ENDIF
     dtidx = 0, dtfound = 0, i = 1
     WHILE (i <= size(reportdata->rptsection[1].grpmain,5)
      AND dtfound != 1)
       IF ((reportdata->rptsection[1].grpmain[i].grpitem=dtstring))
        dtidx = i, dtfound = 1
       ELSE
        i = (i+ 1)
       ENDIF
     ENDWHILE
     IF (dtfound=0)
      grpcntr = (grpcntr+ 1), stat = alterlist(reportdata->rptsection[1].grpmain,grpcntr), reportdata
      ->rptsection[1].grpmain[grpcntr].grpitem = dtstring,
      dtidx = grpcntr
     ENDIF
     IF (dtfound=0)
      datacntr = 0
     ENDIF
    DETAIL
     IF (dv.stat_clob_val="")
      rtmsstring = trim(dv.stat_str_val)
     ELSE
      rtmsstring = trim(dv.stat_clob_val)
     ENDIF
     CALL parsertmsdata(dv.stat_name,rtmsstring), tempapp = datalinestruct->application, tempsubtimer
      = datalinestruct->subtimer,
     temptimer = datalinestruct->timer
     IF (tempapp != "")
      IF (tempsubtimer != "")
       timerdisplay = concat(tempapp,"-",temptimer,"-",tempsubtimer)
      ELSE
       timerdisplay = concat(tempapp,"-",temptimer)
      ENDIF
     ELSE
      IF (tempsubtimer != "")
       timerdisplay = concat(temptimer,"-",tempsubtimer)
      ELSE
       timerdisplay = temptimer
      ENDIF
     ENDIF
     tmridx = 0, tmrfound = 0, j = 1
     WHILE (j <= size(reportdata->rptsection[1].grpmain[dtidx].grpdata,5)
      AND tmrfound != 1)
       IF ((reportdata->rptsection[1].grpmain[dtidx].grpdata[j].dtlitem=timerdisplay))
        tmridx = j, tmrfound = 1
       ELSE
        j = (j+ 1)
       ENDIF
     ENDWHILE
     IF (tmrfound=0)
      datacntr = (datacntr+ 1), stat = alterlist(reportdata->rptsection[1].grpmain[dtidx].grpdata,
       datacntr), reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].dtlitem = timerdisplay,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].count = datalinestruct->count,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].sumsq = datalinestruct->sumsq,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].total = datalinestruct->total,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].min = datalinestruct->min,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].max = datalinestruct->max,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].stddev = datalinestruct->stddev,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].avg = datalinestruct->avg,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].trgtval = datalinestruct->trgtval,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].hit = datalinestruct->hit,
      reportdata->rptsection[1].grpmain[dtidx].grpdata[datacntr].miss = datalinestruct->miss, tmridx
       = datacntr
     ELSE
      reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].count = (reportdata->rptsection[1].
      grpmain[dtidx].grpdata[tmridx].count+ datalinestruct->count), reportdata->rptsection[1].
      grpmain[dtidx].grpdata[tmridx].sumsq = (reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx
      ].sumsq+ datalinestruct->sumsq), reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].total
       = (reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].total+ datalinestruct->total),
      reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].min = least(reportdata->rptsection[1].
       grpmain[dtidx].grpdata[tmridx].min,datalinestruct->min), reportdata->rptsection[1].grpmain[
      dtidx].grpdata[tmridx].max = greatest(reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].
       max,datalinestruct->max), newtotal = reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].
      total,
      newsumsq = reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].sumsq, newcount =
      reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].count, reportdata->rptsection[1].
      grpmain[dtidx].grpdata[tmridx].stddev = (abs(((cnvtreal(newsumsq) - ((cnvtreal(newtotal)** 2)/
       cnvtreal(newcount)))/ (cnvtreal(newcount) - 1)))** 0.5),
      reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].avg = cnvtreal((newtotal/ newcount)),
      reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].hit = (reportdata->rptsection[1].
      grpmain[dtidx].grpdata[tmridx].hit+ datalinestruct->hit), reportdata->rptsection[1].grpmain[
      dtidx].grpdata[tmridx].miss = (reportdata->rptsection[1].grpmain[dtidx].grpdata[tmridx].miss+
      datalinestruct->miss)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE datastructureflip(x)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(reportdata->rptsection[1].grpmain,5)))
    HEAD REPORT
     grpcntr = 0, insdatacntr = 0
    DETAIL
     FOR (dtidx = 1 TO size(reportdata->rptsection[1].grpmain[d.seq].grpdata,5))
       timerdisplay = reportdata->rptsection[1].grpmain[d.seq].grpdata[dtidx].dtlitem, tmridx = 0,
       tmrfound = 0,
       i = 1
       WHILE (i <= size(reportdata->rptsection[2].grpmain,5)
        AND tmrfound != 1)
         IF ((reportdata->rptsection[2].grpmain[i].grpitem=timerdisplay))
          tmridx = i, tmrfound = 1
         ELSE
          i = (i+ 1)
         ENDIF
       ENDWHILE
       IF (tmrfound=0)
        grpcntr = (grpcntr+ 1), stat = alterlist(reportdata->rptsection[2].grpmain,grpcntr),
        reportdata->rptsection[2].grpmain[grpcntr].grpitem = timerdisplay,
        tmridx = grpcntr
       ENDIF
       insdatacntr = (size(reportdata->rptsection[2].grpmain[tmridx].grpdata,5)+ 1), stat = alterlist
       (reportdata->rptsection[2].grpmain[tmridx].grpdata,insdatacntr), reportdata->rptsection[2].
       grpmain[tmridx].grpdata[insdatacntr].dtlitem = reportdata->rptsection[1].grpmain[d.seq].
       grpitem,
       reportdata->rptsection[2].grpmain[tmridx].grpdata[insdatacntr].count = reportdata->rptsection[
       1].grpmain[d.seq].grpdata[dtidx].count, reportdata->rptsection[2].grpmain[tmridx].grpdata[
       insdatacntr].min = reportdata->rptsection[1].grpmain[d.seq].grpdata[dtidx].min, reportdata->
       rptsection[2].grpmain[tmridx].grpdata[insdatacntr].max = reportdata->rptsection[1].grpmain[d
       .seq].grpdata[dtidx].max,
       reportdata->rptsection[2].grpmain[tmridx].grpdata[insdatacntr].stddev = reportdata->
       rptsection[1].grpmain[d.seq].grpdata[dtidx].stddev, reportdata->rptsection[2].grpmain[tmridx].
       grpdata[insdatacntr].total = reportdata->rptsection[1].grpmain[d.seq].grpdata[dtidx].total,
       reportdata->rptsection[2].grpmain[tmridx].grpdata[insdatacntr].avg = reportdata->rptsection[1]
       .grpmain[d.seq].grpdata[dtidx].avg,
       reportdata->rptsection[2].grpmain[tmridx].grpdata[insdatacntr].trgtval = reportdata->
       rptsection[1].grpmain[d.seq].grpdata[dtidx].trgtval, reportdata->rptsection[2].grpmain[tmridx]
       .grpdata[insdatacntr].hit = reportdata->rptsection[1].grpmain[d.seq].grpdata[dtidx].hit,
       reportdata->rptsection[2].grpmain[tmridx].grpdata[insdatacntr].miss = reportdata->rptsection[1
       ].grpmain[d.seq].grpdata[dtidx].miss
     ENDFOR
    WITH nocounter
   ;end select
 END ;Subroutine
 DECLARE testrownum = i4 WITH noconstant(0)
 SET testrownum = 0
 SUBROUTINE displayitem(itemtext)
  SET testrownum = (testrownum+ 1)
  CALL text(testrownum,0,itemtext)
 END ;Subroutine
 DECLARE noapp_subtimer = i2 WITH noconstant(0)
 DECLARE sumsq = f8 WITH noconstant(0.0)
 DECLARE totaltime = f8 WITH noconstant(0.0)
 DECLARE bucketstring = vc
 DECLARE application_pos = i4 WITH noconstant(0)
 DECLARE subtimer_pos = i4 WITH noconstant(0)
 DECLARE min_pos = i4 WITH noconstant(0)
 DECLARE max_pos = i4 WITH noconstant(0)
 DECLARE count_pos = i4 WITH noconstant(0)
 DECLARE total_pos = i4 WITH noconstant(0)
 DECLARE sumsq_pos = i4 WITH noconstant(0)
 DECLARE targettime = f8 WITH noconstant(0.0)
 SUBROUTINE parsertmsdata(timer,datastring)
   SET noapp_subtimer = 0
   IF (trim(ntharg(datastring,1,","),3)="Min")
    SET noapp_subtimer = 1
   ENDIF
   IF (noapp_subtimer=1)
    SET application_pos = 0
    SET subtimer_pos = 0
    SET min_pos = 2
    SET max_pos = 4
    SET count_pos = 6
    SET total_pos = 8
    SET sumsq_pos = 10
   ELSE
    SET application_pos = 1
    SET subtimer_pos = 2
    SET min_pos = 4
    SET max_pos = 6
    SET count_pos = 8
    SET total_pos = 10
    SET sumsq_pos = 12
   ENDIF
   SET datalinestruct->timer = timer
   SET datalinestruct->application = ntharg(datastring,application_pos,",")
   SET datalinestruct->subtimer = ntharg(datastring,subtimer_pos,",")
   SET datalinestruct->min = cnvtreal(ntharg(datastring,min_pos,","))
   SET datalinestruct->max = cnvtreal(ntharg(datastring,max_pos,","))
   SET datalinestruct->count = cnvtint(ntharg(datastring,count_pos,","))
   SET datalinestruct->sumsq = cnvtreal(ntharg(datastring,sumsq_pos,","))
   SET datalinestruct->total = cnvtreal(ntharg(datastring,total_pos,","))
   SET datalinestruct->stddev = (abs(((cnvtreal(datalinestruct->sumsq) - ((cnvtreal(datalinestruct->
     total)** 2)/ cnvtreal(datalinestruct->count)))/ (cnvtreal(datalinestruct->count) - 1)))** 0.5)
   SET datalinestruct->avg = (cnvtreal(datalinestruct->total)/ cnvtreal(datalinestruct->count))
   SET path = build("timers/sla/",timer,"/TargetMeanTime")
   IF (uar_timer_getconfigdouble(nullterm(path),targettime,0)=0)
    SET targettime = defaultresponsetime
   ENDIF
   SET datalinestruct->trgtval = targettime
   SET datalinestruct->hit = 0
   SET datalinestruct->miss = 0
   SET fieldcounter = 13
   SET bucketstring = ntharg(datastring,fieldcounter,",")
   WHILE (findstring(".",bucketstring,1,1) > 0)
     SET bucket = cnvtreal(bucketstring)
     SET fieldcounter = (fieldcounter+ 1)
     SET bucketcount = cnvtint(ntharg(datastring,fieldcounter,","))
     IF ((bucket <= datalinestruct->trgtval))
      SET datalinestruct->hit = (datalinestruct->hit+ bucketcount)
     ELSE
      SET datalinestruct->miss = (datalinestruct->miss+ bucketcount)
     ENDIF
     SET fieldcounter = (fieldcounter+ 1)
     SET bucketstring = ntharg(datastring,fieldcounter,",")
   ENDWHILE
 END ;Subroutine
 SUBROUTINE displayrtmsreport(x)
   SELECT
    grpitem = reportdata->rptsection[1].grpmain[d.seq].grpitem
    FROM (dummyt d  WITH seq = value(size(reportdata->rptsection[1].grpmain,5)))
    HEAD REPORT
     cnt = 0, col 0, report_data->title,
     row + 1
     IF ((dsr_reports->create_csv=1))
      dsrg_title2 = concat("(External text (csv) file ",trim(dsrg_fname,3)," created in CCLUSERDIR)"),
      col 0, dsrg_title2,
      row + 1
     ENDIF
     col 0, "Begin Date: ", dsr_reports->begin_dt_tm,
     row + 1, col 0, "End Date:   ",
     dsr_reports->end_dt_tm, row + 2
    DETAIL
     dateportion = substring(1,11,grpitem), timeportion = substring(13,5,grpitem)
     IF ((dsr_reports->report_type="SLA_AGGREGATE_HOURLY1"))
      col 0, "Date: ", grpitem
     ELSE
      col 0, "Date: ", dateportion,
      row + 1, col 0, "Time: ",
      timeportion
     ENDIF
     row + 2, col 3, "Timer Description",
     col 85, "Count", col 93,
     "Min", col 100, "Max",
     col 107, "StdDev", col 115,
     "Avg", col 122, "TrgtVal",
     col 131, "Hit", col 138,
     "Miss", row + 1, grpdatasize = size(reportdata->rptsection[1].grpmain[d.seq].grpdata,5)
     FOR (grpdatacntr = 1 TO grpdatasize)
       timerdisp = substring(1,80,reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].
        dtlitem), countdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr
        ].count,7,2), mindisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[
        grpdatacntr].min,6,2),
       maxdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].max,6,2),
       stddevdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].stddev,7,
        2), avgdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].avg,6,
        2),
       trgtvaldisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].trgtval,
        8,2), hitdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].hit,
        6,2), missdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[grpdatacntr].
        miss,6,2),
       col 3, timerdisp, col 85,
       countdisp, col 93, mindisp,
       col 100, maxdisp, col 107,
       stddevdisp, col 115, avgdisp,
       col 122, trgtvaldisp, col 131,
       hitdisp, col 138, missdisp,
       row + 1
     ENDFOR
     row + 2
    FOOT REPORT
     linefill = fillstring(490,"="), col 0, linefill,
     row + 2
     FOR (grpmaincntr = 1 TO size(reportdata->rptsection[2].grpmain,5))
       timerdisp = substring(1,80,reportdata->rptsection[2].grpmain[grpmaincntr].grpitem), col 0,
       "Timer Description: ",
       timerdisp, row + 2
       IF ((dsr_reports->report_type="SLA_AGGREGATE_HOURLY1"))
        col 3, "Date"
       ELSE
        col 3, "Date/Time"
       ENDIF
       col 25, "Count", col 33,
       "Min", col 40, "Max",
       col 47, "StdDev", col 55,
       "Avg", col 62, "TrgtVal",
       col 71, "Hit", col 78,
       "Miss", row + 1, grpdatasize = size(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata,5)
       FOR (grpdatacntr = 1 TO grpdatasize)
         datedisp = reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[grpdatacntr].dtlitem,
         countdisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[grpdatacntr].
          count,7,2), mindisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[
          grpdatacntr].min,6,2),
         maxdisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[grpdatacntr].max,
          6,2), stddevdisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[
          grpdatacntr].stddev,7,2), avgdisp = cnvtstring(reportdata->rptsection[2].grpmain[
          grpmaincntr].grpdata[grpdatacntr].avg,6,2),
         trgtvaldisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[grpdatacntr]
          .trgtval,8,2), hitdisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr].grpdata[
          grpdatacntr].hit,6,2), missdisp = cnvtstring(reportdata->rptsection[2].grpmain[grpmaincntr]
          .grpdata[grpdatacntr].miss,6,2),
         col 3, datedisp, col 25,
         countdisp, col 33, mindisp,
         col 40, maxdisp, col 47,
         stddevdisp, col 55, avgdisp,
         col 62, trgtvaldisp, col 71,
         hitdisp, col 78, missdisp,
         row + 1
       ENDFOR
       row + 2
     ENDFOR
    WITH nocounter, formfeed = none, nullreport,
     maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE creatertmscsv(x)
  DECLARE drsg_line = vc
  SELECT INTO value(dsrg_fname)
   FROM (dummyt d  WITH seq = value(size(reportdata->rptsection[1].grpmain,5)))
   HEAD REPORT
    col 0, report_data->title, row + 1,
    col 0, "Begin Date: ", dsr_reports->begin_dt_tm,
    row + 1, col 0, "End Date:   ",
    dsr_reports->end_dt_tm, row + 2, drsg_line = ""
   DETAIL
    csvgrpitem = reportdata->rptsection[1].grpmain[d.seq].grpitem, drsg_line = build(
     '"Date/Time","Timer Description","Count","Min","Max","StdDev","Avg","TrgtVal","Hit","Miss"'),
    col 0,
    drsg_line, row + 1, csvgrpdatasize = size(reportdata->rptsection[1].grpmain[d.seq].grpdata,5),
    csvgrpdatacntr = 1
    FOR (csvgrpdatacntr = 1 TO csvgrpdatasize)
      timerdisp = substring(1,80,reportdata->rptsection[1].grpmain[d.seq].grpdata[csvgrpdatacntr].
       dtlitem), countdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[
       csvgrpdatacntr].count,7,2), mindisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].
       grpdata[csvgrpdatacntr].min,6,2),
      maxdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[csvgrpdatacntr].max,6,2),
      stddevdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[csvgrpdatacntr].stddev,
       7,2), avgdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[csvgrpdatacntr].
       avg,6,2),
      trgtvaldisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[csvgrpdatacntr].
       trgtval,8,2), hitdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].grpdata[
       csvgrpdatacntr].hit,6,2), missdisp = cnvtstring(reportdata->rptsection[1].grpmain[d.seq].
       grpdata[csvgrpdatacntr].miss,6,2),
      drsg_line = build('"',csvgrpitem,'","',timerdisp,'","',
       countdisp,'","',mindisp,'","',maxdisp,
       '","',stddevdisp), drsg_line = build(drsg_line,'","',avgdisp,'","',trgtvaldisp,
       '","',hitdisp,'","',missdisp,'"'), col 0,
      drsg_line, row + 1
    ENDFOR
   WITH nocounter, formfeed = none, maxcol = 500,
    maxrow = 1, format = variable
  ;end select
 END ;Subroutine
 SET counter = 0
 IF ((dsr_reports->create_csv=1))
  WHILE (dsrg_fini=0)
    SET dsrg_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
       cnvtdatetime(curdate,000000)) * 864000)))
    SET dsrg_fname = cnvtlower(build("dm_stat_report_",dsrg_tempstr,".csv"))
    IF (findfile(dsrg_fname)=0)
     SET dsrg_fini = 1
    ENDIF
  ENDWHILE
 ENDIF
 IF ((dsr_reports->sort_by="stat_snap_dt_tm"))
  SET order_val = build("ds.",dsr_reports->sort_by)
 ELSE
  SET order_val = build("dv.",dsr_reports->sort_by)
 ENDIF
 CASE (dsr_reports->report_type)
  OF "ESM_OSSTAT_DTL":
   SET report_data->title = "Node Utilization Detail"
   SET col_cnt = 3
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Metric"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Node"
   SET report_data->column[2].tcname = "NODE_NAME"
   SET report_data->column[2].pos = 52
   SET report_data->column[3].rname = "Count"
   SET report_data->column[3].tcname = "STAT_VALUE"
   SET report_data->column[3].pos = 65
  OF "ESM_OSSTAT_SMRY":
   SET report_data->title = "Node Utilization Summary"
   SET col_cnt = 3
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Metric"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Node"
   SET report_data->column[2].tcname = "NODE_NAME"
   SET report_data->column[2].pos = 52
   SET report_data->column[3].rname = "Count"
   SET report_data->column[3].tcname = "STAT_VALUE"
   SET report_data->column[3].pos = 65
  OF "ESM_MSGLOG_SMRY":
   SET report_data->title = "Message Log Summary"
   SET col_cnt = 3
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Message Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Node"
   SET report_data->column[2].tcname = "NODE_NAME"
   SET report_data->column[2].pos = 52
   SET report_data->column[3].rname = "Count"
   SET report_data->column[3].tcname = "STAT_VALUE"
   SET report_data->column[3].pos = 65
  OF "ESM_MSGLOG_DTL":
   SET report_data->title = "Message Log Detail"
   SET col_cnt = 3
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Message Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Node"
   SET report_data->column[2].tcname = "NODE_NAME"
   SET report_data->column[2].pos = 52
   SET report_data->column[3].rname = "Count"
   SET report_data->column[3].tcname = "STAT_VALUE"
   SET report_data->column[3].pos = 65
  OF "Application Volumes":
   SET report_data->title = "Application Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "APP_VOLUMES - PHYSICIAN LOG INS":
   SET report_data->title = "Application Volumes - Physician logins"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "APP_VOLUMES - NON-PHYSICIAN LOG INS":
   SET report_data->title = "Application Volumes - Non-Physician logins"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "APP_VOLUMES - PHYSICIAN DISTINCT USERS":
   SET report_data->title = "Application Volumes - Physician Distinct Users"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "APP_VOLUMES - NON-PHYS DISTINCT USERS":
   SET report_data->title = "Application Volumes - Non-Physician Distinct Users"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "APP_VOLUMES - PHYSICIAN MINUTES":
   SET report_data->title = "Application Volumes - Physician Minutes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "APP_VOLUMES - NON-PHYSICIAN MINUTES":
   SET report_data->title = "Application Volumes - Non-Physician Minutes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Application Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES":
   SET report_data->title = "Order Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Order Action"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - PYXIS":
   SET report_data->title = "Order Volumes - Pyxis"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - IV BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - IV By Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - NON-IV BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - Non-IV By Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - PRN BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - PRN By Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - NON-PRN BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - Non-PRN By Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES -PHYSICIAN BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - Physician By Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - NON-PHYS BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - Non-Physician BY Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES -BILL ONLY BY CATALOG TYPE":
   SET report_data->title = "Order Volumes - Bill Only By Catalog Type"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - NON-BILL ONLY BY CATALOG":
   SET report_data->title = "Order Volumes - Non-Bill Only By Catalog"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - BY CATALOG BY ACTION":
   SET report_data->title = "Order Volumes - By Catalog By Action"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ORDER_VOLUMES - BY CATALOG BY CARE SET":
   SET report_data->title = "Order Volumes - By Catalog By Care Set"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Catalog Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "OPENED_CHART_VOLUMES":
   SET report_data->title = "Chart Open Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Chart Opens"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "Personnel Volumes":
   SET report_data->title = "Personnel Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-ACTIVE PHYSICIAN WITH SIGNON":
   SET report_data->title = "Personnel - Active Physician With Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-ACTIVE PHYSICIAN WITH NOSIGNON":
   SET report_data->title = "Personnel - Active Physician With No Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-ACTIVE OTHER WITH SIGNON":
   SET report_data->title = "Personnel - Active Other With Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-ACTIVE OTHER WITH NOSIGNON":
   SET report_data->title = "Personnel - Active Other With No Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-INACTIVE PHYSICIAN WITH SIGNON":
   SET report_data->title = "Personnel - Inactive Physician With Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-INACTIVE PHYS WITH NOSIGNON":
   SET report_data->title = "Personnel - Inactive Physician With No Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-INACTIVE OTHER WITH SIGNON":
   SET report_data->title = "Personnel - Inactive Other With Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PERSONNEL-INACTIVE OTHER WITH NOSIGNON":
   SET report_data->title = "Personnel - Inactive Other With No Signon"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Personnel Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "Radiology Volumes":
   SET report_data->title = "Radiology Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Action"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "RADIOLOGY_VOLUMES - ORDERS":
   SET report_data->title = "Radiology Volumes - Orders"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Action"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "RADIOLOGY_VOLUMES - ORDERS BY RPT STATUS":
   SET report_data->title = "Radiology Volumes - Orders By Report Status"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Report Status"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "RADIOLOGY_VOLUMES -ORDERS BY EXAM STATUS":
   SET report_data->title = "Radiology Volumes - Orders By Exam Status"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Exam Status"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "SCHEDULING VOLUMES":
   SET report_data->title = "Scheduling Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Action"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ESM_MILLCONFIG":
   SET report_data->title = "Millennium Configuration"
   SET col_cnt = 3
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Parameter"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Node"
   SET report_data->column[2].tcname = "NODE_NAME"
   SET report_data->column[2].pos = 52
   SET report_data->column[3].rname = "Value"
   SET report_data->column[3].tcname = "STAT_VALUE"
   SET report_data->column[3].pos = 65
  OF "ESM_OSCONFIG":
   SET report_data->title = "OS Configuration"
   SET col_cnt = 3
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Parameter"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Node"
   SET report_data->column[2].tcname = "NODE_NAME"
   SET report_data->column[2].pos = 52
   SET report_data->column[3].rname = "Value"
   SET report_data->column[3].tcname = "STAT_VALUE"
   SET report_data->column[3].pos = 65
  OF "ESI Interface Volumes":
   SET report_data->title = "Inbound Interface Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Source/Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PM VOLUMES":
   SET report_data->title = "PM Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "Pathnet Volumes":
   SET report_data->title = "Pathnet Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PATHNET_VOLUMES - ACCESSIONS":
   SET report_data->title = "Pathnet Volumes - Accessions"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PATHNET_VOLUMES - GEN LAB CONTAINERS":
   SET report_data->title = "Pathnet Volumes - Gen Lab Containers"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Event Type"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PATHNET_VOLUMES - GEN LAB LISTS":
   SET report_data->title = "Pathnet Volumes - Gen Lab Lists"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "PATHNET_VOLUMES - RESULTS":
   SET report_data->title = "Pathnet Volumes - Results"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Result Event/Activity Type/CareSet Flag"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ESO Outbound Interface Volumes":
   SET report_data->title = "Outbound Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ESO COM Srv Transactions Sent":
   SET report_data->title = "Outbound Transaction Send"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ESO COM Srv Transactions Ignored":
   SET report_data->title = "Outbound Transaction Ignored"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "FIRSTNET VOLUMES":
   SET report_data->title = "FirstNet Volumes"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ESM_RRD_METRICS_DTL":
   SET report_data->title = "RRD Volumes Detail"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "ESM_RRD_METRICS_SMRY":
   SET report_data->title = "RRD Volumes Summary"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Transaction"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Count"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "DM_STAT_GATHER_ERRORS":
   SET report_data->title = "DM Stats Errors"
   SET col_cnt = 2
   SET stat = alterlist(report_data->column,col_cnt)
   SET report_data->column[1].rname = "Script Name"
   SET report_data->column[1].tcname = "STAT_NAME"
   SET report_data->column[1].pos = 22
   SET report_data->column[2].rname = "Error Message"
   SET report_data->column[2].tcname = "STAT_VALUE"
   SET report_data->column[2].pos = 65
  OF "SLA_AGGREGATE_HOURLY1":
   CALL loadreportdata(0)
   CALL datastructureflip(0)
   IF ((dsr_reports->create_csv=1))
    CALL creatertmscsv(0)
   ENDIF
   CALL displayrtmsreport(0)
  OF "SLA_AGGREGATE_HOURLY2":
   CALL loadreportdata(0)
   CALL datastructureflip(0)
   IF ((dsr_reports->create_csv=1))
    CALL creatertmscsv(0)
   ENDIF
   CALL displayrtmsreport(0)
  ELSE
   SET dsr_reports->stat_error_flag = 1
   SET dsr_reports->stat_error_message = "Invalid Report Type"
   GO TO exit_program
 ENDCASE
 IF ((dsr_reports->report_type != "SLA_AGGREGATE_HOURLY1")
  AND (dsr_reports->report_type != "SLA_AGGREGATE_HOURLY2"))
  IF ((dsr_reports->create_csv=1))
   DECLARE dsrg_line = vc
   SET whereclause = build("ds.snapshot_type LIKE '",dsr_reports->report_type,"*'")
   SELECT INTO value(dsrg_fname)
    FROM dm_stat_snaps ds,
     dm_stat_snaps_values dv,
     dummyt d
    PLAN (d)
     JOIN (ds
     WHERE parser(whereclause)
      AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_reports->begin_dt_tm) AND cnvtdatetime(
      dsr_reports->end_dt_tm))
     JOIN (dv
     WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id)
    ORDER BY parser(order_val)
    HEAD REPORT
     col 0, report_data->title, row + 1,
     col 0, "Begin Date: ", dsr_reports->begin_dt_tm,
     row + 1, col 0, "End Date:   ",
     dsr_reports->end_dt_tm, row + 1, dsrg_line = build('"DATE/TIME",')
     FOR (cnt = 1 TO col_cnt)
      dsrg_line = build(dsrg_line,'"',cnvtupper(report_data->column[cnt].rname)),
      IF (cnt=col_cnt)
       dsrg_line = build(dsrg_line,'"')
      ELSE
       dsrg_line = build(dsrg_line,'",')
      ENDIF
     ENDFOR
     col 0, dsrg_line, row + 1
    DETAIL
     snap_date = format(ds.stat_snap_dt_tm,"dd-mmm-yyyy hh:mm"), dsrg_line = build('"',snap_date,'",'
      )
     FOR (cnt = 1 TO col_cnt)
       dsrg_line = build(dsrg_line,'"')
       IF ( NOT ((report_data->column[cnt].tcname IN ("STAT_NAME", "STAT_VALUE"))))
        dsrg_line = build(dsrg_line,ds.node_name)
       ELSEIF ((report_data->column[cnt].tcname="STAT_NAME"))
        IF ((dsr_reports->report_type="ESM_MSGLOG_SMRY"))
         CASE (dv.stat_name)
          OF "MSG_ERROR_CNT":
           dsrg_line = build(dsrg_line,"Error")
          OF "MSG_WARN_CNT":
           dsrg_line = build(dsrg_line,"Warning")
          OF "MSG_AUDIT_CNT":
           dsrg_line = build(dsrg_line,"Audit")
          OF "MSG_INFO_CNT":
           dsrg_line = build(dsrg_line,"Informational")
          OF "MSG_DEBUG_CNT":
           dsrg_line = build(dsrg_line,"Debug")
          OF "MSG_TOTAL_CNT":
           dsrg_line = build(dsrg_line,"Total")
         ENDCASE
        ELSE
         dsrg_line = build(dsrg_line,dv.stat_name)
        ENDIF
       ELSE
        IF ((dsr_reports->report_type="ESM_MILLCONFIG"))
         dsrg_line = build(dsrg_line,dv.stat_str_val)
        ELSEIF ((dsr_reports->report_type="ESM_OSCONFIG"))
         IF (dv.stat_type=1)
          dm_disp = cnvtstring(dv.stat_number_val), dsrg_line = build(dsrg_line,dm_disp)
         ELSE
          dsrg_line = build(dsrg_line,dv.stat_str_val)
         ENDIF
        ELSEIF ((dsr_reports->report_type="DM_STAT_GATHER_ERRORS"))
         dsrg_line = build(dsrg_line,dv.stat_str_val)
        ELSE
         dsrg_line = build(dsrg_line,dv.stat_number_val)
        ENDIF
       ENDIF
       IF (cnt=col_cnt)
        dsrg_line = build(dsrg_line,'"')
       ELSE
        dsrg_line = build(dsrg_line,'",')
       ENDIF
     ENDFOR
     col 0, dsrg_line, row + 1
    WITH nocounter, formfeed = none, maxcol = 500,
     maxrow = 1, format = variable
   ;end select
  ENDIF
  SET whereclause = build("ds.snapshot_type LIKE '",dsr_reports->report_type,"*'")
  SELECT
   ds.snapshot_type, ds.domain_name, ds.stat_snap_dt_tm,
   dv.stat_name, dv.stat_number_val, ds.node_name
   FROM dm_stat_snaps ds,
    dm_stat_snaps_values dv,
    dummyt d
   PLAN (d)
    JOIN (ds
    WHERE parser(whereclause)
     AND ds.stat_snap_dt_tm BETWEEN cnvtdatetime(dsr_reports->begin_dt_tm) AND cnvtdatetime(
     dsr_reports->end_dt_tm))
    JOIN (dv
    WHERE dv.dm_stat_snap_id=ds.dm_stat_snap_id)
   ORDER BY parser(order_val)
   HEAD REPORT
    cnt = 0, col 0, report_data->title,
    row + 1
    IF ((dsr_reports->create_csv=1))
     dsrg_title2 = concat("(External text (csv) file ",trim(dsrg_fname,3)," created in CCLUSERDIR)"),
     col 0, dsrg_title2,
     row + 1
    ENDIF
    col 0, "Begin Date: ", dsr_reports->begin_dt_tm,
    row + 1, col 0, "End Date:   ",
    dsr_reports->end_dt_tm, row + 2, col 0,
    "Date/Time"
    FOR (cnt = 1 TO col_cnt)
     col report_data->column[cnt].pos,report_data->column[cnt].rname
    ENDFOR
    row + 1
   DETAIL
    counter = 1, snap_date = format(ds.stat_snap_dt_tm,"dd-mmm-yyyy hh:mm"), col 0,
    snap_date
    FOR (cnt = 1 TO col_cnt)
      IF ((report_data->column[cnt].tcname="NODE_NAME"))
       col report_data->column[cnt].pos, ds.node_name
      ELSEIF ((report_data->column[cnt].tcname="STAT_NAME"))
       IF ((dsr_reports->report_type="ESM_MSGLOG_SMRY"))
        CASE (dv.stat_name)
         OF "MSG_ERROR_CNT":
          col report_data->column[cnt].pos,"Error"
         OF "MSG_WARN_CNT":
          col report_data->column[cnt].pos,"Warning"
         OF "MSG_AUDIT_CNT":
          col report_data->column[cnt].pos,"Audit"
         OF "MSG_INFO_CNT":
          col report_data->column[cnt].pos,"Informational"
         OF "MSG_DEBUG_CNT":
          col report_data->column[cnt].pos,"Debug"
         OF "MSG_TOTAL_CNT":
          col report_data->column[cnt].pos,"Total"
        ENDCASE
       ELSE
        dsrg_str = ""
        IF (cnt < col_cnt)
         dsrg_str = substring(1,((report_data->column[(cnt+ 1)].pos - report_data->column[cnt].pos)
           - 1),dv.stat_name)
        ELSE
         dsrg_str = dv.stat_name
        ENDIF
        col report_data->column[cnt].pos, dsrg_str
       ENDIF
      ELSEIF ((report_data->column[cnt].tcname="STAT_VALUE"))
       IF ((dsr_reports->report_type="ESM_MILLCONFIG"))
        col report_data->column[cnt].pos, dv.stat_str_val
       ELSEIF ((dsr_reports->report_type="DM_STAT_GATHER_ERRORS"))
        col report_data->column[cnt].pos, dv.stat_str_val
       ELSEIF ((dsr_reports->report_type="ESM_OSCONFIG"))
        IF (dv.stat_type=1)
         dm_disp = cnvtstring(dv.stat_number_val), col report_data->column[cnt].pos, dm_disp
        ELSE
         col report_data->column[cnt].pos, dv.stat_str_val
        ENDIF
       ELSE
        col report_data->column[cnt].pos, dv.stat_number_val
       ENDIF
      ELSE
       dsr_reports->stat_error_flag = 1, dsr_reports->stat_error_message =
       "Column name in record report_data is invalid.",
       CALL cancel(1)
      ENDIF
    ENDFOR
    row + 1
   FOOT REPORT
    IF (counter=0)
     row + 2, col 22, "****NO RECORDS FOUND****"
    ELSE
     row + 1, col 22, "****END OF REPORT****"
    ENDIF
   WITH nocounter, formfeed = none, nullreport,
    maxcol = 500
  ;end select
  IF ((dsr_reports->stat_error_flag=0))
   IF (error(dsr_reports->stat_error_message,1))
    SET dsr_reports->stat_error_flag = 1
   ENDIF
  ENDIF
 ENDIF
#exit_program
 FREE RECORD report_data
 FREE RECORD datalinestruct
 FREE RECORD reportdata
END GO
