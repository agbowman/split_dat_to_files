CREATE PROGRAM ccl_locale_test:dba
 PROMPT
  "Enter output device= " = "MINE",
  "Test mode (ALL)= " = "ALL"
  WITH outdev, testname
 RECORD day_of_the_week_rec(
   1 qual[*]
     2 name = c9
 )
 DECLARE smode = vc WITH constant(cnvtupper( $TESTNAME))
 CALL echo(build("LANG= ",trim(logical("LANG"))))
 CALL echo(build("CCL_LANG= ",trim(logical("CCL_LANG"))))
 CALL echo(build("MONTHABBREV2= ",curlocale("MONTHABBREV2")))
 CALL echo(build("MONTHFULL= ",curlocale("MONTHFULL")))
 CALL echo(build("CURUTC= ",curutc))
 CALL echo("=============================")
 DECLARE num1 = f8 WITH noconstant(25.789)
 DECLARE num2 = f8 WITH noconstant(469.99)
 DECLARE num3 = f8 WITH noconstant(123456.78)
 SET language_log = fillstring(5," ")
 SET language_log = cnvtupper(logical("CCL_LANG"))
 IF (language_log=" ")
  SET language_log = cnvtupper(logical("LANG"))
  IF (language_log IN (" ", "C"))
   SET language_log = "EN_US"
  ENDIF
 ENDIF
 IF (smode="ALL")
  CALL echo("Test currency symbol...")
  SELECT INTO "noforms"
   value1 = format(num1,"########.##;ri$"), value2 = format(num2,"########.##;ri$"), value3 = format(
    num3,"##########.##;ri$")
   FROM dummyt
  ;end select
  SET stat = alterlist(day_of_the_week_rec->qual,7)
  FOR (x = 1 TO 7)
    IF (x=1)
     SET day_of_the_week_rec->qual[x].name = "   Sunday"
    ELSEIF (x=2)
     SET day_of_the_week_rec->qual[x].name = "   Monday"
    ELSEIF (x=3)
     SET day_of_the_week_rec->qual[x].name = "  Tuesday"
    ELSEIF (x=4)
     SET day_of_the_week_rec->qual[x].name = "Wednesday"
    ELSEIF (x=5)
     SET day_of_the_week_rec->qual[x].name = " Thursday"
    ELSEIF (x=6)
     SET day_of_the_week_rec->qual[x].name = "   Friday"
    ELSEIF (x=7)
     SET day_of_the_week_rec->qual[x].name = " Saturday"
    ENDIF
  ENDFOR
  CALL echo("Test weekday names and abbreviations...")
  SELECT INTO "noforms"
   day_of_the_week = day_of_the_week_rec->qual[d.seq].name, longweekday = cnvtdatetime(cnvtdate((
     10309+ (d.seq * 100))),0)"wwwwwwwww;;d", shortweekday = cnvtdatetime(cnvtdate((10309+ (d.seq *
     100))),0)"www;;d"
   FROM (dummyt d  WITH seq = 7)
  ;end select
  CALL echo("Test month names and abbreviations...")
  SELECT INTO "noforms"
   longmonth = cnvtdatetime(cnvtdate((((d.seq * 10000)+ 100)+ 14)),0)"mmmmmmmmmmmm yyyy;;d", shortmon
    = cnvtdatetime(cnvtdate((((d.seq * 10000)+ 100)+ 14)),0)"mmm yyyy;;d", mediumdate4yr =
   cnvtdatetime(cnvtdate((((d.seq * 10000)+ 100)+ 14)),0)"@MEDIUMDATE4YR",
   mediumdate4yr2 = cnvtdatetime(cnvtdate((((d.seq * 10000)+ 100)+ 14)),0)"@MEDIUMDATE4YR2"
   FROM (dummyt d  WITH seq = 12)
  ;end select
  CALL echo("Test values for 'hour', 'day', 'week' and 'month'...")
  SELECT INTO "noforms"
   expr1 = cnvtage(cnvtdatetime(((curdate+ 1) - d.seq),(curtime - 120))), expr2 = cnvtage(
    cnvtdatetime((curdate - (30 * (d.seq** 3))),0))
   FROM (dummyt d  WITH seq = 3)
  ;end select
 ENDIF
 IF (((smode="DATES") OR (smode="ALL")) )
  DECLARE current_date = dq8
  SET current_date = cnvtdatetime(sysdate)
  SELECT INTO "noforms"
   short_date = format(current_date,"@SHORTDATE"), short_datetime = format(current_date,
    "@SHORTDATETIME"), short_date4yr = format(current_date,"@SHORTDATE4YR"),
   short_datetimenosec = format(current_date,"@SHORTDATETIMENOSEC"), medium_date = format(
    current_date,"@MEDIUMDATE"), medium_datetime = format(current_date,"@MEDIUMDATETIME"),
   medium_date4yr = format(current_date,"@MEDIUMDATE4YR"), medium_date4yr2 = format(current_date,
    "@MEDIUMDATE4YR2"), long_date = format(current_date,"@LONGDATE"),
   long_datetime = format(current_date,"@LONGDATETIME"), time_withseconds = format(current_date,
    "@TIMEWITHSECONDS"), datetime_condensed = format(current_date,"@DATETIMECONDENSED"),
   date_condensed = format(current_date,"@DATECONDENSED")
   FROM dummyt d
   HEAD REPORT
    "Date/time formats:", row + 2
   DETAIL
    col 0, "SHORTDATE= ", col 20,
    short_date, row + 1, col 0,
    "SHORTDATE4YR= ", col 20, short_date4yr,
    row + 1, col 0, "SHORTDATETIME= ",
    col 20, short_datetime, row + 1,
    col 0, "SHORTDATETIMENOSEC= ", col 20,
    short_datetimenosec, row + 1, col 0,
    "MEDIUMDATE= ", col 20, medium_date,
    row + 1, col 0, "MEDIUMDATETIME= ",
    col 20, medium_datetime, row + 1,
    col 0, "MEDIUMDATE4YR= ", col 20,
    medium_date4yr, row + 1, col 0,
    "MEDIUMDATE4YR2= ", col 20, medium_date4yr2,
    row + 1, col 0, "LONGDATE= ",
    col 20, long_date, row + 1,
    col 0, "LONGDATETIME= ", col 20,
    long_datetime, row + 1, col 0,
    "TIMEWITHSECONDS= ", col 20, time_withseconds,
    row + 1, col 0, "DATETIMECONDENSED= ",
    col 20, datetime_condensed, row + 1,
    col 0, "DATECONDENSED= ", col 20,
    date_condensed, row + 1
   WITH nocounter
  ;end select
  DECLARE monthstr = vc
  DECLARE monthname = vc
  DECLARE datestr = vc
  DECLARE utc_dt_tm = dq8
  DECLARE beginpos = i4
  DECLARE fillstr = vc
  DECLARE dtzformat = vc
  DECLARE timestr = vc WITH constant("060101")
  DECLARE timestrend = vc WITH constant("235959")
  DECLARE _separator_ = vc WITH constant(fillstring(50,"="))
  RECORD recdates(
    1 datejun = vc
    1 datejuin = vc
    1 datejuin2 = vc
    1 datejundttm = vc
    1 datejul = vc
    1 datejuil = vc
    1 datejuil2 = vc
    1 datejuldttm = vc
  )
  SET recdates->datejun = "15-Jun-2020"
  SET recdates->datejuin = "15-Jun-2020"
  SET recdates->datejuin2 = "2020Jun15"
  SET recdates->datejundttm = "2020Jun15 06:01:01.00"
  SET recdates->datejul = "15-Jul-2020"
  SET recdates->datejuil = "15-Jul-2020"
  SET recdates->datejuil2 = "2020Juil15"
  SET recdates->datejuldttm = "2020Jul15 23:59:59.00"
  IF (language_log="FR_FR")
   SET recdates->datejuin = "15-Juin-2020"
   SET recdates->datejuin2 = "2020Juin15"
   SET recdates->datejundttm = "2020Juin15 06:01:01.00"
   SET recdates->datejuil = "15-Juil-2020"
   SET recdates->datejuil2 = "2020Juil15"
   SET recdates->datejuldttm = "2020Juil15 23:59:59.00"
  ENDIF
  SET dtzformat = "DD-MMM-YYYY HH:mm:ss ZZZZZZ"
  CALL echorecord(recdates)
  CALL echo(">>>CnvtDateTime (2 dates display 15-June, 2 dates display 15-July)..")
  CALL echo(format(cnvtdatetime(recdates->datejun),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetime(recdates->datejuin),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetime(recdates->datejul),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetime(recdates->datejuil),"@LONGDATETIME"))
  CALL echo(">>>CnvtDateTimeUtc (2 dates display 15-June, 2 dates display 15-July)..")
  CALL echo(format(cnvtdatetimeutc(recdates->datejun),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetimeutc(recdates->datejuin),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetimeutc(recdates->datejul),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetimeutc(recdates->datejuil),"@LONGDATETIME"))
  CALL echo(">>>CnvtDateTimeUtc2..")
  SET utc_dt_tm = cnvtdatetimeutc2(recdates->datejun,"DD-MMM-YYYY",timestr,"HHMMSS",1,
   curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc2(recdates->datejuin,"DD-MMMM-YYYY",timestr,"HHMMSS",1,
   curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc2(recdates->datejuin2,"YYYYMMMMDD",timestr,"HHMMSS",1,
   curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc2(recdates->datejul,"DD-MMM-YYYY",timestrend,"HHMMSS",1,
   curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc2(recdates->datejuil,"DD-MMMM-YYYY",timestrend,"HHMMSS",1,
   curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc2(recdates->datejuil2,"YYYYMMMMDD",timestrend,"HHMMSS",1,
   curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  CALL echo(">>>CnvtDateTimeUtc3..")
  SET utc_dt_tm = cnvtdatetimeutc3(recdates->datejuin,"DD-MMMM-YYYY",1,curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc3(recdates->datejundttm,"YYYYMMMMDD HH:MM:SS.CC",1,curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc3(recdates->datejuil,"DD-MMMM-YYYY",1,curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  SET utc_dt_tm = cnvtdatetimeutc3(recdates->datejuldttm,"YYYYMMMMDD HH:MM:SS.CC",1,curtimezonedef)
  CALL echo(datetimezoneformat(utc_dt_tm,curtimezoneapp,dtzformat))
  CALL echo(">>>CnvtDateTimeRdb (2 dates display 15-June, 2 dates display 15-July)..")
  CALL echo(format(cnvtdatetimerdb(recdates->datejun,1),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetimerdb(recdates->datejuin,1),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetimerdb(recdates->datejul,1),"@LONGDATETIME"))
  CALL echo(format(cnvtdatetimerdb(recdates->datejuil,1),"@LONGDATETIME"))
  CALL echo(">>>CNVTDATE2 (2 dates display 15-June, 2 dates display 15-July)..")
  CALL echo(format(cnvtdate2(recdates->datejun,"DD-MMM-YYYY"),"@LONGDATETIME"))
  CALL echo(format(cnvtdate2(recdates->datejuin,"DD-MMMM-YYYY"),"@LONGDATETIME"))
  CALL echo(format(cnvtdate2(recdates->datejul,"DD-MMM-YYYY"),"@LONGDATETIME"))
  CALL echo(format(cnvtdate2(recdates->datejuil,"DD-MMMM-YYYY"),"@LONGDATETIME"))
  CALL echo(_separator_)
  SET beginpos = 1
  SET monthstr = curlocale("MONTHABBREV")
  CALL echo(">>>CnvtDateTime: test MonthAbbrev names...")
  FOR (x = 1 TO 12)
    SET monthname = trim(substring(beginpos,3,monthstr))
    SET datestr = build("15-",monthname,"-2020")
    CALL echo(build2(datestr," -> ",format(cnvtdatetime(datestr),"mm/dd/yyyy;;d"),", (UTC) -> ",
      format(cnvtdatetimeutc(datestr),"mm/dd/yyyy;;d")))
    SET beginpos += 4
  ENDFOR
  CALL echo(_separator_)
  SET beginpos = 1
  SET monthstr = curlocale("MONTHABBREV2")
  IF (textlen(monthstr) > 0)
   CALL echo(">>>CnvtDateTime: test MonthAbbrev2 names...")
   FOR (x = 1 TO 12)
     SET monthname = trim(substring(beginpos,4,monthstr))
     SET datestr = build("15-",monthname,"-2020")
     CALL echo(build2(datestr," -> ",format(cnvtdatetime(datestr),"mm/dd/yyyy;;d"),", (UTC) -> ",
       format(cnvtdatetimeutc(datestr),"mm/dd/yyyy;;d")))
     SET beginpos += 5
   ENDFOR
   CALL echo(_separator_)
  ELSE
   CALL echo("Skipping MONTHABBREV2 test (not populated)..")
  ENDIF
  SET beginpos = 1
  SET monthstr = curlocale("MONTHFULL")
  CALL echo(">>>CnvtDateTime: test MonthFull names...")
  FOR (x = 1 TO 12)
    SET monthname = trim(substring(beginpos,12,monthstr),3)
    SET datestr = build("27-",monthname,"-2020")
    CALL echo(build2(datestr," -> ",format(cnvtdatetime(datestr),"mm/dd/yyyy;;d"),", (UTC) -> ",
      format(cnvtdatetimeutc(datestr),"mm/dd/yyyy;;d")))
    SET beginpos += 13
  ENDFOR
  CALL echo(_separator_)
 ENDIF
END GO
