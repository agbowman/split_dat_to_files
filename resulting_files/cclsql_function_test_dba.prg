CREATE PROGRAM cclsql_function_test:dba
 PROMPT
  "Output Device [MINE]: " = "MINE",
  "Timezone Index [75]: " = 75,
  "Test Year [2015]: " = 2015
  WITH outdev, starttz, startyear
 DECLARE tzname = vc WITH protect
 DECLARE tzindex = i4 WITH public, noconstant(0)
 DECLARE v_year = i4 WITH public, noconstant(0)
 DECLARE itm = i4 WITH public, noconstant(0)
 DECLARE ccltz = i4 WITH public, noconstant(0)
 DECLARE ccltzname = vc WITH protect
 DECLARE dstdurstr = vc WITH protect
 DECLARE stdurstr = vc WITH protect
 DECLARE testdatestr1 = vc WITH protect
 DECLARE testdatestr2 = vc WITH protect
 DECLARE toutc_utcon_str = vc WITH protect
 DECLARE toutc_utcoff_str = vc WITH protect
 DECLARE tolocal_utcon_str = vc WITH protect
 DECLARE tolocal_utcoff_str = vc WITH protect
 DECLARE utc_always_utcon_str = vc WITH protect
 DECLARE utc_always_utcoff_str = vc WITH protect
 DECLARE local_always_utcon_str = vc WITH protect
 DECLARE local_always_utcoff_str = vc WITH protect
 DECLARE str = vc WITH protect
 DECLARE local_dst_utc_on_str = vc WITH protect
 DECLARE local_dst_utc_off_str = vc WITH protect
 DECLARE local_st_utc_on_str = vc WITH protect
 DECLARE local_st_utc_off_str = vc WITH protect
 DECLARE dtl_count = i4 WITH protect
 DECLARE leapstart = vc WITH protect
 DECLARE dststart = dq8 WITH protect
 DECLARE strdst_start = vc WITH protect
 DECLARE dstend = dq8 WITH protect
 DECLARE strdst_end = vc WITH protect
 DECLARE calcdatetime = dq8 WITH protect
 DECLARE calcenddatetime = dq8 WITH protect
 DECLARE sqldate = vc WITH protect
 DECLARE ccldate = vc WITH protect
 DECLARE ccllocal = dq8 WITH protect
 DECLARE dt_cnt = i4 WITH public, noconstant(0)
 DECLARE idx = i4 WITH protect
 DECLARE diffidx = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE diffind = i2 WITH protect
 DECLARE tz_diff = i4 WITH protect
 DECLARE tz_idx_offset = i4 WITH protect
 DECLARE q1_offset = vc WITH protect
 DECLARE q2_offset = vc WITH protect
 DECLARE q3_offset = vc WITH protect
 DECLARE q4_offset = vc WITH protect
 DECLARE funcnamestr = vc WITH protect
 DECLARE funcdescstr = vc WITH protect
 DECLARE q1str = vc WITH protect
 DECLARE q2str = vc WITH protect
 DECLARE q3str = vc WITH protect
 DECLARE q4str = vc WITH protect
 RECORD function_test(
   1 function_rec[*]
     2 name = vc
     2 desc = vc
     2 input = vc
     2 output = vc
 )
 RECORD temp_tz(
   1 date_rec[*]
     2 test_opt = vc
     2 tz = i4
     2 tzname = vc
     2 tz_dst = vc
     2 tz_st = vc
     2 test_calc_dt_tm = dq8
     2 test_calc_dt_str = vc
     2 sql_dt_tm = dq8
     2 sql_local_dt_str = vc
     2 ccl_dt_tm = dq8
     2 ccl_local_dt_str = vc
 )
 RECORD diff(
   1 tz[*]
     2 index = i4
     2 name = vc
     2 diff[*]
       3 tstart
         4 utc = vc
         4 ccllocal = vc
         4 sqllocal = vc
       3 tend
         4 utc = vc
         4 ccllocal = vc
         4 sqllocal = vc
 )
 SET tzindex =  $STARTTZ
 SET v_year =  $STARTYEAR
 SET q1str = build(v_year,"-03-01 08:00:00")
 SET q2str = build(v_year,"-06-01 08:00:00")
 SET q3str = build(v_year,"-09-01 08:00:00")
 SET q4str = build(v_year,"-12-01 08:00:00")
 SELECT INTO "nl:"
  tz = curtimezonesys, name = sqlpassthru(build("cclsql_datetimezonebyindex(",curtimezonesys,")"),32)
  FROM dual
  DETAIL
   ccltz = tz, ccltzname = name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  name = sqlpassthru(build("cclsql_datetimezonebyindex(",tzindex,")"),32)
  FROM dual
  DETAIL
   tzname = name
  WITH nocounter
 ;end select
 SET funcnamestr = "**** cclsql_datetimezonebyindex ****"
 SET funcdescrstr = "     Returns a time zone name for entered time zone index."
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,1)
 SET function_test->function_rec[itm].name = funcnamestr
 SET function_test->function_rec[itm].desc = funcdescrstr
 SET function_test->function_rec[itm].input = build("cclsql_datetimezonebyindex(",tzindex,")")
 SET function_test->function_rec[itm].output = tzname
 SELECT INTO "nl:"
  q1offset = sqlpassthru(build("cclsql_getOffset(TO_DATE('",q1str,"', 'YYYY-MM-DD HH:MI:SS'), ",
    tzindex,", 1)"),32), q2offset = sqlpassthru(build("cclsql_getOffset(TO_DATE('",q2str,
    "', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)"),32), q3offset = sqlpassthru(build(
    "cclsql_getOffset(TO_DATE('",q3str,"', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)"),32),
  q4offset = sqlpassthru(build("cclsql_getOffset(TO_DATE('",q4str,"', 'YYYY-MM-DD HH:MI:SS'), ",
    tzindex,", 1)"),32)
  FROM dual
  DETAIL
   q1_offset = build((cnvtint(q1offset)/ 3600)," hours from UTC."), q2_offset = build((cnvtint(
     q2offset)/ 3600)," hours from UTC."), q3_offset = build((cnvtint(q3offset)/ 3600),
    " hours from UTC."),
   q4_offset = build((cnvtint(q4offset)/ 3600)," hours from UTC.")
  WITH nocounter
 ;end select
 SET stat = alterlist(function_test->function_rec,value((size(function_test->function_rec,5)+ 4)))
 SET funcnamestr = " **** cclsql_getOffset ****"
 SET funcdescrstr = build("     Shows the calculated offset (in hours) from UTC time for ",build(
   tzname))
 SET itm += 1
 SET function_test->function_rec[itm].name = funcnamestr
 SET function_test->function_rec[itm].desc = build(funcdescrstr,":  Q1")
 SET function_test->function_rec[itm].input = build("cclsql_getOffset(TO_DATE('",q1str,
  "', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = q1_offset
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = "     Q2"
 SET function_test->function_rec[itm].input = build("cclsql_getOffset(TO_DATE('",q2str,
  "', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = q2_offset
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = "     Q3"
 SET function_test->function_rec[itm].input = build("cclsql_getOffset(TO_DATE('",q3str,
  "', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = q3_offset
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = "     Q4"
 SET function_test->function_rec[itm].input = build("cclsql_getOffset(TO_DATE('",q4str,
  "', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = q4_offset
 SELECT INTO "nl:"
  startdst = sqlpassthru(build("to_char(cclsql_getTimeChange(",v_year,",",tzindex,
    ", 1, 1), 'DD-MON-YYYY HH24:MI:SS')"),32), enddst = sqlpassthru(build(
    "to_char(cclsql_getTimeChange(",v_year,",",tzindex,", 1, 2), 'DD-MON-YYYY HH24:MI:SS')"),32),
  startst = sqlpassthru(build("to_char(cclsql_getTimeChange(",v_year,",",tzindex,
    ", 2, 1), 'DD-MON-YYYY HH24:MI:SS')"),32),
  endst = sqlpassthru(build("to_char(cclsql_getTimeChange(",v_year,",",tzindex,
    ", 2, 2), 'DD-MON-YYYY HH24:MI:SS')"),32)
  FROM dual
  DETAIL
   strdst_start = startdst, strdst_end = enddst
   IF (((startdst=null) OR (enddst=null)) )
    dstdurstr = build2("DST not observed for ",build(tzname)," in ",build(v_year),"."), stdurstr =
    dstdurstr
   ELSE
    dstdurstr = build2("DST for ",build(v_year),":  ",build(startdst)," - ",
     build(enddst)), stdurstr = build2("ST for ",build(v_year),":  ",build(startst)," - ",
     build(endst))
   ENDIF
  WITH nocounter
 ;end select
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,value((size(function_test->function_rec,5)+ 2)))
 SET funcnamestr = " **** cclsql_getTimeChange ****"
 SET function_test->function_rec[itm].name = funcnamestr
 SET function_test->function_rec[itm].desc = build2(
  "     Returns Start and End Date/Time of Daylight Savings Time (DST) in ",build(v_year)," for ",
  build(tzname)," ")
 SET function_test->function_rec[itm].input = build("cclsql_getTimeChange(",v_year,",",tzindex,
  ", 1, 1) AND cclsql_getTimeChange(",
  v_year,",",tzindex,", 1, 2)")
 SET function_test->function_rec[itm].output = dstdurstr
 SET itm += 1
 SET function_test->function_rec[itm].input = build("cclsql_getTimeChange(",v_year,",",tzindex,
  ", 2, 1) AND cclsql_getTimeChange(",
  v_year,",",tzindex,", 2, 2)")
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2(
  "     Returns Start and End Date/Time of Standard Time (ST) in ",build(v_year)," for ",build(tzname
   )," ")
 SET function_test->function_rec[itm].output = stdurstr
 SET testdatestr1 = build(v_year,"-01-10 08:00:00")
 SET testdatestr2 = build(v_year,"-05-10 08:00:00")
 SELECT INTO "nl:"
  toutc_utcon = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,", 1), 'YYYY-MM-DD HH24:MI:SS')"),32), toutc_utcoff =
  sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,", 0), 'YYYY-MM-DD HH24:MI:SS')"),32), tolocal_utcon
   = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 2, ",tzindex,", 1), 'YYYY-MM-DD HH24:MI:SS')"),32),
  tolocal_utcoff = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 2, ",tzindex,", 0), 'YYYY-MM-DD HH24:MI:SS')"),32),
  utc_always_utcon = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 3, ",tzindex,", 1), 'YYYY-MM-DD HH24:MI:SS')"),32),
  utc_always_utcoff = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 3, ",tzindex,", 0), 'YYYY-MM-DD HH24:MI:SS')"),32),
  local_always_utcon = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 4, ",tzindex,", 1), 'YYYY-MM-DD HH24:MI:SS')"),32),
  local_always_utcoff = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 4, ",tzindex,", 0), 'YYYY-MM-DD HH24:MI:SS')"),32)
  FROM dual
  DETAIL
   toutc_utcon_str = toutc_utcon, toutc_utcoff_str = toutc_utcoff, tolocal_utcon_str = tolocal_utcon,
   tolocal_utcoff_str = tolocal_utcoff, utc_always_utcon_str = utc_always_utcon,
   utc_always_utcoff_str = utc_always_utcoff,
   local_always_utcon_str = local_always_utcon, local_always_utcoff_str = local_always_utcoff
  WITH nocounter
 ;end select
 SET stat = alterlist(function_test->function_rec,value((size(function_test->function_rec,5)+ 8)))
 SET itm += 1
 SET funcnamestr = " **** cclsql_cnvtdatetimeutc ****"
 SET function_test->function_rec[itm].name = funcnamestr
 SET function_test->function_rec[itm].desc =
 "     Converts datetime expression to UTC since UTC is on."
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = toutc_utcon_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = "     No conversion since UTC is off."
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,", 0)")
 SET function_test->function_rec[itm].output = toutc_utcoff_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc =
 "     Converts datetime expression to Local since UTC is on."
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 2, ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = tolocal_utcon_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = "      No conversion since UTC is off."
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 2, ",tzindex,", 0)")
 SET function_test->function_rec[itm].output = tolocal_utcoff_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = "     Converts to UTC, regardless of UTC mode (UTC On)."
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 3, ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = utc_always_utcon_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc =
 "     Converts to UTC, regardless of UTC mode (UTC Off)."
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 3, ",tzindex,", 0)")
 SET function_test->function_rec[itm].output = utc_always_utcoff_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc =
 "     Converts to Local, regardless of UTC mode (UTC On)"
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 4, ",tzindex,", 1)")
 SET function_test->function_rec[itm].output = local_always_utcon_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc =
 "     Converts to Local, regardless of UTC mode (UTC Off)"
 SET function_test->function_rec[itm].input = build("cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 4, ",tzindex,", 0)")
 SET function_test->function_rec[itm].output = local_always_utcoff_str
 SELECT INTO "nl:"
  st_utc_on = sqlpassthru(build("to_char(cclsql_utc_cnvt(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,"), 'YYYY-MM-DD HH24:MI:SS')"),32), st_utc_off =
  sqlpassthru(build("to_char(cclsql_utc_cnvt(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,"), 'YYYY-MM-DD HH24:MI:SS')"),32), dst_utc_on =
  sqlpassthru(build("to_char(cclsql_utc_cnvt(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,"), 'YYYY-MM-DD HH24:MI:SS')"),32),
  dst_utc_off = sqlpassthru(build("to_char(cclsql_utc_cnvt(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,"), 'YYYY-MM-DD HH24:MI:SS')"),32)
  FROM dual
  DETAIL
   local_dst_utc_on_str = dst_utc_on, local_dst_utc_off_str = dst_utc_off, local_st_utc_on_str =
   st_utc_on,
   local_st_utc_off_str = st_utc_off
  WITH nocounter
 ;end select
 SET stat = alterlist(function_test->function_rec,value((size(function_test->function_rec,5)+ 4)))
 SET funcnamestr = " **** cclsql_utc_cnvt ****"
 SET itm += 1
 SET function_test->function_rec[itm].name = funcnamestr
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," DST (UTC on).")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_dst_utc_on_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," DST (UTC off.")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_dst_utc_off_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," ST (UTC on.")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_st_utc_on_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," ST (UTC off.")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_st_utc_off_str
 SELECT INTO "nl:"
  st_utc_on = sqlpassthru(build("cclsql_utc_cnvt2(TO_DATE('",testdatestr1,
    "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")"),32), st_utc_off = sqlpassthru(build(
    "cclsql_utc_cnvt2(TO_DATE('",testdatestr1,"', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,")"),32),
  dst_utc_on = sqlpassthru(build("cclsql_utc_cnvt2(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")"),32),
  dst_utc_off = sqlpassthru(build("cclsql_utc_cnvt2(TO_DATE('",testdatestr2,
    "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,")"),32)
  FROM dual
  DETAIL
   local_dst_utc_on_str = dst_utc_on, local_dst_utc_off_str = dst_utc_off, local_st_utc_on_str =
   st_utc_on,
   local_st_utc_off_str = st_utc_off
  WITH nocounter
 ;end select
 SET stat = alterlist(function_test->function_rec,value((size(function_test->function_rec,5)+ 4)))
 SET funcnamestr = " **** cclsql_utc_cnvt2 ****"
 SET itm += 1
 SET function_test->function_rec[itm].name = funcnamestr
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," DST (UTC on)")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt2(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_dst_utc_on_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," DST (UTC off)")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt2(TO_DATE('",testdatestr2,
  "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_dst_utc_off_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," ST (UTC on)")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt2(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_st_utc_on_str
 SET itm += 1
 SET function_test->function_rec[itm].name = ""
 SET function_test->function_rec[itm].desc = build2("     Converts datetime from UTC to ",build(
   tzname)," ST (UTC off)")
 SET function_test->function_rec[itm].input = build("cclsql_utc_cnvt2(TO_DATE('",testdatestr1,
  "', 'YYYY-MM-DD HH24:MI:SS'), 0, ",tzindex,")")
 SET function_test->function_rec[itm].output = local_st_utc_off_str
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   str = "TEST INPUTS:", col 0, str,
   str = "-------------", row + 1, col 0,
   str, str = concat("Year:  ",build(v_year)), row + 1,
   str, str = concat("Test timezone:  ",build(tzname)," (Index: ",build(tzindex),")"), row + 1,
   str, str = "Function Test Results:", row + 1,
   str, str = "--------------------------------------------------------------------", row + 1,
   str
   FOR (itm = 1 TO size(function_test->function_rec,5))
     str = function_test->function_rec[itm].name, row + 1, str,
     str = function_test->function_rec[itm].desc, row + 1, str,
     str = " ", row + 1, str,
     str = concat("     Input:  ",function_test->function_rec[itm].input), row + 1, str,
     str = concat("     Output:  ",function_test->function_rec[itm].output), row + 1, str,
     str = "--------------------------------------------------------------------", row + 1, str
   ENDFOR
  WITH nocounter, append
 ;end select
END GO
