CREATE PROGRAM ccltest_dst_dttm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE fillstr = vc WITH constant(fillstring(50,"="))
 CALL echo(build("CURCCLVER= ",curcclver))
 CALL echo(build("CURDOMAIN= ",curdomain,", CURNODE= ",curnode,", CURSYS2= ",
   cursys2))
 CALL echo(build("CURUTC= ",curutc,", CURUTCDIFF= ",curutcdiff))
 CALL echo(build("DTTMCALC= ",trace("DTTMCALC")))
 EXECUTE ccltest_datetimeadd
 CALL echo(fillstr)
 CALL echo("cnvtdatetimeutc() with cnvtlookahead for Fall DST date, using record DQ8 fields..")
 RECORD rec(
   1 f1 = dq8
   1 f2 = dq8
   1 f3 = dq8
 )
 DECLARE expire = dq8
 SET rec->f1 = cnvtdatetime("03-NOV-2019 00:30:00")
 SET rec->f2 = cnvtdatetime("03-NOV-2019 01:30:00")
 SET rec->f3 = cnvtdatetime("03-NOV-2019 02:30:00")
 CALL echorecord(rec)
 CALL echo(">>>test1")
 CALL echo(format(cnvtdatetimeutc(cnvtlookahead("20, MIN",rec->f1),1),";;Q"))
 SET expire = cnvtdatetime(format(cnvtlookahead("20, MIN",rec->f1),";;Q"))
 CALL echo(format(cnvtdatetimeutc(expire,1),";;Q"))
 CALL echo(">>>test2")
 CALL echo(format(cnvtdatetimeutc(cnvtlookahead("20, MIN"),1),";;Q"))
 SET expire = cnvtdatetime(format(cnvtlookahead("20, MIN"),";;Q"))
 CALL echo(format(cnvtdatetimeutc(expire,1),";;Q"))
 CALL echo(fillstr)
 DECLARE lookahead = dq8
 DECLARE lookaheadf = vc
 DECLARE lookaheadfutc = vc
 DECLARE diff = f8
 DECLARE diff2 = f8
 DECLARE x = i2
 SET dst_fall_dttm2 = cnvtdatetime("02-Nov-2019 23:30:00")
 SET dst_fall_dttm2_utc = cnvtdatetimeutc("02-Nov-2019 23:30:00")
 CALL echo("CnvtLookAhead and DateTimeDiff for Fall DST date..")
 CALL echo(build('Begin time from cnvtdatetime("02-Nov-2010 23:30:00")= ',format(dst_fall_dttm2,";;q"
    )))
 CALL echo(build('Begin time from cnvtdatetimeutc("02-Nov-2019 23:30:00")= ',format(
    dst_fall_dttm2_utc,";;q")))
 CALL echo("..CNVTLOOKAHEAD/DATETIMEDIFF..........CNVTLOOKAHEAD/DATETIMEDIFF/CNVTDATETIMEUTC..")
 FOR (x = 1 TO 8)
   SET unit = build('"',x,',H"')
   SET lookahead = cnvtlookahead(unit,dst_fall_dttm2)
   SET lookaheadf = format(lookahead,"DD-MMM-YYYY HH:MM:SS;;D")
   SET diff = datetimediff(lookahead,dst_fall_dttm2,3)
   SET unit = build('"',x,',H"')
   SET lookahead = cnvtlookahead(unit,dst_fall_dttm2_utc)
   SET lookaheadfutc = format(lookahead,"DD-MMM-YYYY HH:MM:SS;;D")
   SET diff2 = datetimediff(lookahead,dst_fall_dttm2_utc,3)
   CALL echo(concat(build(format(x,"##"),") ",lookaheadf,"__",diff),fillstring(5," "),build(
      lookaheadfutc,"__",diff2)))
 ENDFOR
 CALL echo(fillstr)
 EXECUTE ccltest_dttmcalc_fnd
 CALL echo(fillstr)
END GO
