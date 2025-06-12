CREATE PROGRAM cclsql_test_all_timezones:dba
 PROMPT
  "Output Device [MINE]: " = "MINE",
  "Test Year [2019]: " = 2019
  WITH outdev, startyear
 DECLARE tzindex = i4 WITH public, noconstant(0)
 DECLARE timezonecount = i4 WITH public, constant(638)
 DECLARE v_year = i4 WITH public, noconstant(0)
 DECLARE itm = i4 WITH public, noconstant(0)
 DECLARE return_message1 = vc WITH protect
 DECLARE return_message2 = vc WITH protect
 DECLARE str = vc WITH protect
 DECLARE emsg = vc WITH protect
 RECORD function_test(
   1 function_rec[*]
     2 name = vc
     2 result = vc
 )
 SET v_year =  $STARTYEAR
 SET return_message1 = "ALL TESTS SUCCESSFUL"
 SET testdatestr1 = build(v_year,"-01-10 08:00:00")
 SET emsg = fillstring(130," ")
 FOR (tzindex = 0 TO timezonecount)
   SET ecode = 0
   SELECT INTO "nl:"
    name = sqlpassthru(build("cclsql_datetimezonebyindex(",tzindex,")"),32)
    FROM dual
    DETAIL
     strname = name
    WITH nocounter
   ;end select
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET itm += 1
    SET stat = alterlist(function_test->function_rec,itm)
    SET function_test->function_rec[itm].name = concat("cclsql_datetimezonebyindex failed on index ",
     build(tzindex))
    SET function_test->function_rec[itm].result = substring(1,128,emsg)
    GO TO checkoffset
   ENDIF
   SET tzindex += 1
 ENDFOR
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,itm)
 SET function_test->function_rec[itm].name = "cclsql_datetimezonebyindex"
 SET function_test->function_rec[itm].result = "Success"
#checkoffset
 FOR (tzindex = 0 TO timezonecount)
   SET ecode = 0
   SELECT INTO "nl:"
    offset = sqlpassthru(build("cclsql_getOffset(TO_DATE('",testdatestr1,
      "', 'YYYY-MM-DD HH:MI:SS'), ",tzindex,", 1)"),32)
    FROM dual
    DETAIL
     stroffset = offset
    WITH nocounter
   ;end select
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET itm += 1
    SET stat = alterlist(function_test->function_rec,itm)
    SET function_test->function_rec[itm].name = concat("cclsql_getOffset failed on index ",build(
      tzindex))
    SET function_test->function_rec[itm].result = substring(1,128,emsg)
    GO TO checktimechange
   ENDIF
   SET tzindex += 1
 ENDFOR
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,itm)
 SET function_test->function_rec[itm].name = "cclsql_getOffset"
 SET function_test->function_rec[itm].result = "Success"
#checktimechange
 FOR (tzindex = 0 TO timezonecount)
   SET ecode = 0
   SELECT INTO "nl:"
    startdst = sqlpassthru(build("to_char(cclsql_getTimeChange(",v_year,",",tzindex,
      ", 1, 1), 'DD-MON-YYYY HH24:MI:SS')"),32)
    FROM dual
    DETAIL
     strstarttime = startdst
    WITH nocounter
   ;end select
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET itm += 1
    SET stat = alterlist(function_test->function_rec,itm)
    SET function_test->function_rec[itm].name = concat("cclsql_getTimeChange failed on index ",build(
      tzindex))
    SET function_test->function_rec[itm].result = substring(1,128,emsg)
    GO TO checkcnvtdate
   ENDIF
   SET tzindex += 1
 ENDFOR
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,itm)
 SET function_test->function_rec[itm].name = "cclsql_getTimeChange"
 SET function_test->function_rec[itm].result = "Success"
#checkcnvtdate
 FOR (tzindex = 0 TO timezonecount)
   SET ecode = 0
   SELECT INTO "nl:"
    toutc_utcon = sqlpassthru(build("to_char(cclsql_cnvtdatetimeutc(TO_DATE('",testdatestr1,
      "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,", 1), 'YYYY-MM-DD HH24:MI:SS')"),32)
    FROM dual
    DETAIL
     strtoutcon = toutc_utcon
    WITH nocounter
   ;end select
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET itm += 1
    SET stat = alterlist(function_test->function_rec,itm)
    SET function_test->function_rec[itm].name = concat("cclsql_cnvtdatetimeutc failed on index ",
     build(tzindex))
    SET function_test->function_rec[itm].result = substring(1,128,emsg)
    GO TO checkutccnvt
   ENDIF
   SET tzindex += 1
 ENDFOR
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,itm)
 SET function_test->function_rec[itm].name = "cclsql_cnvtdatetimeutc"
 SET function_test->function_rec[itm].result = "Success"
#checkutccnvt
 FOR (tzindex = 0 TO timezonecount)
   SET ecode = 0
   SELECT INTO "nl:"
    st_utc_on1 = sqlpassthru(build("to_char(cclsql_utc_cnvt(TO_DATE('",testdatestr1,
      "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,"), 'YYYY-MM-DD HH24:MI:SS')"),32)
    FROM dual
    DETAIL
     strstutcon1 = st_utc_on1
    WITH nocounter
   ;end select
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET itm += 1
    SET stat = alterlist(function_test->function_rec,itm)
    SET function_test->function_rec[itm].name = concat("cclsql_utc_cnvt failed on index ",build(
      tzindex))
    SET function_test->function_rec[itm].result = substring(1,128,emsg)
    GO TO chechutccnvt2
   ENDIF
   SET tzindex += 1
 ENDFOR
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,itm)
 SET function_test->function_rec[itm].name = "cclsql_utc_cnvt"
 SET function_test->function_rec[itm].result = "Success"
#chechutccnvt2
 FOR (tzindex = 0 TO timezonecount)
   SET ecode = 0
   SELECT INTO "nl:"
    st_utc_on2 = sqlpassthru(build("cclsql_utc_cnvt2(TO_DATE('",testdatestr1,
      "', 'YYYY-MM-DD HH24:MI:SS'), 1, ",tzindex,")"),32)
    FROM dual
    DETAIL
     strstutcon2 = st_utc_on2
    WITH nocounter
   ;end select
   SET ecode = error(emsg,1)
   IF (ecode != 0)
    SET itm += 1
    SET stat = alterlist(function_test->function_rec,itm)
    SET function_test->function_rec[itm].name = concat("cclsql_utc_cnvt2 failed on index ",build(
      tzindex))
    SET function_test->function_rec[itm].result = substring(1,128,emsg)
    GO TO end_of_program
   ENDIF
   SET tzindex += 1
 ENDFOR
 SET itm += 1
 SET stat = alterlist(function_test->function_rec,itm)
 SET function_test->function_rec[itm].name = "cclsql_utc_cnvt2"
 SET function_test->function_rec[itm].result = "Success"
#end_of_program
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   str = "TEST RESULTS:", col 0, str,
   str = "--------------------------------------------------------------------", row + 1, str
   FOR (itm = 1 TO size(function_test->function_rec,5))
     str = function_test->function_rec[itm].name, row + 1, str,
     str = concat("  ",function_test->function_rec[itm].result), row + 1, str,
     str = "--------------------------------------------------------------------", row + 1, str
   ENDFOR
  WITH nocounter, append
 ;end select
END GO
