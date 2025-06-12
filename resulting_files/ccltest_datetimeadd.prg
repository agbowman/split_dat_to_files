CREATE PROGRAM ccltest_datetimeadd
 DECLARE dst_dttm_mar16 = dq8
 DECLARE dst_dttm_nov16 = dq8
 DECLARE dst_mar_dttm = dq8
 DECLARE dst_nov_dttm = dq8
 DECLARE tz_idx = i4 WITH constant(datetimezonebyname("UTC"))
 SET dst_mar_dttm = cnvtdatetime("8-Mar-2020 01:30:00")
 SET dst_mar_dttm2 = cnvtdatetime("8-Mar-2020 02:30:00")
 SET dst_nov_dttm = cnvtdatetime("03-Nov-2019 01:30:00")
 SET dst_nov_dttm2 = cnvtdatetime("03-Nov-2019 02:15:00")
 SET dst_nov_dttm3 = cnvtdatetime("03-Nov-2019 23:30:00")
 CALL echo("DateTimAadd() CCL v9.03.5 | v8.15.5 DST correction..")
 DECLARE testdate1 = dq8
 DECLARE testdate2 = dq8
 DECLARE days_diff = i4
 SET days_diff = 0
 SET testdate1 = cnvtdatetime("05-NOV-2019 23:30:00")
 CALL echo(build2("Begin date: ",format(testdate1,"@MEDIUMDATETIME")))
 FOR (dcnt = 1 TO 5)
   SET days_diff = (0 - dcnt)
   SET testdate2 = datetimeadd(testdate1,days_diff)
   CALL echo(build2("New date:   ",format(testdate2,"@MEDIUMDATETIME")," days_diff= ",format(
      days_diff,"###")))
 ENDFOR
 SET testdate1 = cnvtdatetime("02-NOV-2019 00:59:59")
 CALL echo(build2("Begin date: ",format(testdate1,"@MEDIUMDATETIME")))
 FOR (dcnt = 1 TO 5)
   SET days_diff = dcnt
   SET testdate2 = datetimeadd(testdate1,days_diff)
   CALL echo(build2("New date:   ",format(testdate2,"@MEDIUMDATETIME")," days_diff= ",format(
      days_diff,"###")))
 ENDFOR
 CALL echo("==================================================")
 CALL echo("datetimeadd() for Spring DST date..")
 SELECT INTO "noforms"
  dst_mar_dttm_format = format(dst_mar_dttm,";;q"), dst_mar_dttm_tzformat = datetimezoneformat(
   dst_mar_dttm,tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dtadd_1day_mode0 = format(
   datetimeadd(dst_mar_dttm,1,0),";;q"),
  dtadd_1day_mode1 = format(datetimeadd(dst_mar_dttm,1,1),";;q"), dtadd_1day_mode2 = format(
   datetimeadd(dst_mar_dttm,1,2),";;q"), dtadd_1day_tzmode0 = datetimezoneformat(datetimeadd(
    dst_mar_dttm,1,0),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef),
  dtadd_1day_tzmode1 = datetimezoneformat(datetimeadd(dst_mar_dttm,1,1),tz_idx,
   "dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dtadd_1day_tzmode2 = datetimezoneformat(datetimeadd(
    dst_mar_dttm,1,2),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dtadd_3hr_mode0 = format(
   datetimeadd(dst_mar_dttm,0.125,0),";;q"),
  dtadd_3hr_mode1 = format(datetimeadd(dst_mar_dttm,0.125,1),";;q"), dtadd_3hr_mode2 = format(
   datetimeadd(dst_mar_dttm,0.125,2),";;q"), dtadd_3hr_tzmode0 = datetimezoneformat(datetimeadd(
    dst_mar_dttm,0.125,0),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef),
  dtadd_3hr_tzmode1 = datetimezoneformat(datetimeadd(dst_mar_dttm,0.125,0),tz_idx,
   "dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dtadd_3hr_tzmode2 = datetimezoneformat(datetimeadd(
    dst_mar_dttm,0.125,0),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)
  FROM dual
  DETAIL
   col 0, "dst_mar_dttm  = ", col 20,
   dst_mar_dttm_format, col 50, dst_mar_dttm_tzformat,
   row + 1, col 0, "datetimeadd() 1 day ahead..",
   row + 1, col 0, "dtadd_1day_mode0= ",
   col 20, dtadd_1day_mode0, col 50,
   dtadd_1day_tzmode0, row + 1, col 0,
   "dtadd_1day_mode1= ", col 20, dtadd_1day_mode1,
   col 50, dtadd_1day_tzmode1, row + 1,
   col 0, "dtadd_1day_mode2= ", col 20,
   dtadd_1day_mode2, col 50, dtadd_1day_tzmode2,
   row + 1, col 0, "datetimeadd() 3 hours ahead..",
   row + 1, col 0, "dtadd_3hr_mode0= ",
   col 20, dtadd_3hr_mode0, col 50,
   dtadd_3hr_tzmode0, row + 1, col 0,
   "dtadd_3hr_mode1= ", col 20, dtadd_3hr_mode1,
   col 50, dtadd_3hr_tzmode1, row + 1,
   col 0, "dtadd_3hr_mode2= ", col 20,
   dtadd_3hr_mode2, col 50, dtadd_3hr_tzmode2,
   row + 1
  WITH nocounter, format, separator = " ",
   maxcol = 255
 ;end select
 CALL echo("datetimeadd() 1 day ahead for Fall DST date..")
 SELECT INTO "noforms"
  dst_nov_dttm_format = format(dst_nov_dttm,";;q"), dst_nov_dttm_tzformat = datetimezoneformat(
   dst_nov_dttm,tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dtadd_1day_mode0 = format(
   datetimeadd(dst_nov_dttm,1,0),";;q"),
  dtadd_1day_mode1 = format(datetimeadd(dst_nov_dttm,1,1),";;q"), dtadd_1day_mode2 = format(
   datetimeadd(dst_nov_dttm,1,2),";;q"), dtadd_1day_tzmode0 = datetimezoneformat(datetimeadd(
    dst_nov_dttm,1,0),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef),
  dtadd_1day_tzmode1 = datetimezoneformat(datetimeadd(dst_nov_dttm,1,1),tz_idx,
   "dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dtadd_1day_tzmode2 = datetimezoneformat(datetimeadd(
    dst_nov_dttm,1,2),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef), dst_nov_dttm2_format =
  format(dst_nov_dttm2,";;q"),
  dst_nov_dttm2_tzformat = datetimezoneformat(dst_nov_dttm2,tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",
   curtimezonedef), dtadd_3hr_mode0 = format(datetimeadd(dst_nov_dttm2,- (0.125),0),";;q"),
  dtadd_3hr_mode1 = format(datetimeadd(dst_nov_dttm2,- (0.125),1),";;q"),
  dtadd_3hr_mode2 = format(datetimeadd(dst_nov_dttm2,- (0.125),2),";;q"), dtadd_3hr_tzmode0 =
  datetimezoneformat(datetimeadd(dst_nov_dttm2,- (0.125),0),tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",
   curtimezonedef), dtadd_3hr_tzmode1 = datetimezoneformat(datetimeadd(dst_nov_dttm2,- (0.125),1),
   tz_idx,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef),
  dtadd_3hr_tzmode2 = datetimezoneformat(datetimeadd(dst_nov_dttm2,- (0.125),2),tz_idx,
   "dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)
  FROM dual
  DETAIL
   col 0, "dst_nov_dttm  = ", col 20,
   dst_nov_dttm_format, col 50, dst_nov_dttm_tzformat,
   row + 1, col 0, "datetimeadd() 1 day ahead..",
   row + 1, col 0, "dtadd_1day_mode0= ",
   col 20, dtadd_1day_mode0, col 50,
   dtadd_1day_tzmode0, row + 1, col 0,
   "dtadd_1day_mode1= ", col 20, dtadd_1day_mode1,
   col 50, dtadd_1day_tzmode1, row + 1,
   col 0, "dtadd_1day_mode2= ", col 20,
   dtadd_1day_mode2, col 50, dtadd_1day_tzmode2,
   row + 1, row + 1, col 0,
   "dst_nov_dttm2  = ", col 20, dst_nov_dttm2_format,
   col 50, dst_nov_dttm2_tzformat, row + 1,
   col 0, "datetimeadd() 3 hours back..", row + 1,
   col 0, "dtadd_3hr_mode0= ", col 20,
   dtadd_3hr_mode0, col 50, dtadd_3hr_tzmode0,
   row + 1, col 0, "dtadd_3hr_mode1= ",
   col 20, dtadd_3hr_mode1, col 50,
   dtadd_3hr_tzmode1, row + 1, col 0,
   "dtadd_3hr_mode2= ", col 20, dtadd_3hr_mode2,
   col 50, dtadd_3hr_tzmode2, row + 1
  WITH nocounter, format, separator = " ",
   maxcol = 255
 ;end select
END GO
