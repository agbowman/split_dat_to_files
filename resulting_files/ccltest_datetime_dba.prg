CREATE PROGRAM ccltest_datetime:dba
 PROMPT
  "Enter function to test (<func> or ALL): " = "ALL"
  WITH func_test
 CALL echo(build("CURCCLVER= ",curcclver))
 CALL echo(build("CURDOMAIN= ",curdomain,", CURNODE= ",curnode,", CURSYS2= ",
   cursys2))
 CALL echo(build("CURUTC= ",curutc,", CURUTCDIFF= ",curutcdiff))
 CALL echo(build("DTTMCALC= ",trace("DTTMCALC")))
 SET trace = warning
 DECLARE func_name = vc
 DECLARE _separator = vc WITH constant(fillstring(50,"="))
 DECLARE errmsg = vc WITH noconstant(fillstring(255," "))
 DECLARE errcount = i2 WITH noconstant(0)
 DECLARE substat = i2 WITH noconstant(0)
 DECLARE test_dt_tm = dq8
 DECLARE currenttime = dq8 WITH protect
 SET func_name = trim(cnvtupper( $FUNC_TEST))
 SET test_dt_tm = cnvtdatetime(sysdate)
 SET currenttime = cnvtdatetime(sysdate)
 CALL echo(build2("Current time: ",datetimezoneformat(currenttime,0,"MM/dd/yyyy  hh:mm:ss ZZZ",
    curtimezonedef)))
 IF (((func_name="CNVTDATETIME") OR (func_name="ALL")) )
  CALL echo(">>>)CNVTDATETIME")
  SET substat = test_cnvtdatetime(test_dt_tm)
  CALL echo(_separator)
 ENDIF
 IF (((func_name="CNVTDATE") OR (func_name="ALL")) )
  CALL echo(">>>)CNVTDATE and CNVTDATE2")
  SET substat = test_cnvtdate_cnvtdate2(test_dt_tm)
 ENDIF
 IF (((func_name="DATETIMEZONEFORMAT") OR (func_name="ALL")) )
  CALL echo(">>>)DATETIMEZONEFORMAT")
  SET substat = test_datetimezoneformat(75)
  CALL echo(_separator)
 ENDIF
 IF (((func_name="DATETIMEADD") OR (func_name="ALL")) )
  SET substat = test_datetimeadd(test_dt_tm)
  CALL echo(_separator)
 ENDIF
 IF (((func_name="DATEBIRTHFORMAT") OR (func_name="ALL")) )
  SET substat = test_datebirthformat(0)
  SET substat = test_datebirthformat_8143(0)
  CALL echo(_separator)
 ENDIF
 IF (((func_name="DQ8_TYPE") OR (func_name="ALL")) )
  CALL echo(">>>)DQ8 type/subroutines test..")
  SET substat = test_date_types(test_dt_tm)
 ENDIF
 SET currenttime = cnvtdatetime(sysdate)
 CALL echo(build2("Current time: ",datetimezoneformat(currenttime,0,"MM/dd/yyyy  hh:mm:ss ZZZ",
    curtimezonedef)))
 SUBROUTINE (test_cnvtdatetime(test_dt_tm=dq8) =i2 WITH protect)
   CALL echo(">>>Conversion of invalid date test (CCL v9.02.4 | v8.14.4)..")
   SET trace = warning2
   CALL echo(cnvtdatetime("01-11-2018"))
   CALL echo(cnvtdatetime("12-15-2018"))
   SET trace = nowarning2
   CALL echo(">>>DQ8 test (CCL 8.14.3|9.02.3 NOV2018)...")
   CALL echo("CNVTDATETIME(<date>,<time>) check if date already a dq8 (based on UPMC_CR test)...")
   DECLARE run_date = dq8 WITH noconstant(curdate)
   CALL echo(build("run_date: ",format(run_date,"@MEDIUMDATETIME")))
   DECLARE run_date_cnvt = dq8
   SET run_date_cnvt = cnvtdatetime(run_date,0)
   CALL echo(build("run_date_cnvt after cnvtdatetime: ",format(run_date_cnvt,"@MEDIUMDATETIME")))
   IF (run_date_cnvt=0.0)
    CALL echo("ERROR! run_date_cnvt invalid after cnvtdatetime..")
   ENDIF
   CALL echo(_separator)
   CALL echo("CNVTDATETIME: DE HELP tests...")
   CALL echo(format(cnvtdatetime("07-OCT-1992"),";;q"))
   CALL echo("CNVTDATETIME with CNVTDATE()..")
   CALL echo(format(cnvtdatetime(cnvtdate(080196),0),";;q"))
   CALL echo(format(cnvtdatetime(cnvtdate(080196),235959),";;q"))
   CALL echo("Current date and time...")
   CALL echo(format(cnvtdatetime(sysdate),";;q"))
   CALL echo("Current date, max time...")
   CALL echo(format(cnvtdatetime(curdate,235959),";;q"))
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (test_cnvtdate_cnvtdate2(test_dt_tm=dq8) =i2 WITH protect)
   CALL echo("Test based on mp_amb_wklst_get_calendar..")
   DECLARE date_dq8 = dq8
   CALL echo(build("date_dq8: ",date_dq8,", type=",reflect(date_dq8,1)))
   CALL echo("Date: 10-NOV-2018")
   CALL echo(build("CNVTDATE2: ",cnvtdate2("10-NOV-2018","DD-MMM-YYYY")))
   SET date_dq8 = cnvtdate2("10-NOV-2018","DD-MMM-YYYY")
   CALL echo(build("date_dq8: ",date_dq8,", type=",reflect(date_dq8,1)))
   CALL echo(build("format of date_dq8: ",format(date_dq8,";;q")))
   IF (date_dq8=0.0)
    CALL echo("ERROR in test_cnvtdate_cnvtdate2()!  date_dq8 invalid.")
   ENDIF
   CALL echo(_separator)
 END ;Subroutine
 SUBROUTINE (test_datebirthformat(p1=i4) =i2 WITH protect)
   CALL echo(">>>DATEBIRTHFORMAT (DE HELP tests)...")
   SELECT INTO "noforms"
    p.person_id, p.birth_dt_tm"dd-MMM-yyyy HH:mm:ss", tz = p.birth_tz"###",
    birth_tz_disp = substring(1,20,datetimezonebyindex(p.birth_tz)), pf = format(p.birth_prec_flag,
     "##"), birth_pf_disp = evaluate(p.birth_prec_flag,0,"day          ",1,"date and time",
     2,"month        ",3,"year         "),
    birth_fmt = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,"dd-MMM-yyyy HH:mm:ss ZZZ"
     )
    FROM person p
    WHERE p.updt_dt_tm BETWEEN cnvtlookbehind("1,M") AND cnvtdatetime(sysdate)
     AND p.birth_dt_tm IS NOT null
     AND p.birth_tz IS NOT null
    WITH format, separator = " ", maxqual(p,10)
   ;end select
   SELECT INTO "noforms"
    p.person_id, p.birth_dt_tm"dd-MMM-yyyy HH:mm:ss", tz = p.birth_tz"###",
    pf = format(p.birth_prec_flag,"##"), birth_pf_disp = evaluate(p.birth_prec_flag,0,"day          ",
     1,"date and time",
     2,"month        ",3,"year         "), birth_fmt_mode0 = datebirthformat(p.birth_dt_tm,p.birth_tz,
     p.birth_prec_flag,"dd-MMM-yyyy HH:mm:ss ZZZ",0,
     0),
    birth_fmt_mode1 = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,
     "dd-MMM-yyyy HH:mm:ss ZZZ",1,
     0)
    FROM person p
    WHERE p.updt_dt_tm BETWEEN cnvtlookbehind("1,M") AND cnvtdatetime(sysdate)
     AND p.birth_dt_tm IS NOT null
     AND p.birth_tz IS NOT null
    WITH format, separator = " ", maxqual(p,10)
   ;end select
   IF (curqual > 0)
    RETURN(1)
   ELSE
    CALL echo("Warning!  No results for DATEBIRTHFORMAT query..")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (test_datebirthformat_8143(p1=i4) =i2 WITH protect)
   CALL echo(">>>DATEBIRTHFORMAT/DATETIMEZONEFORMAT/DATETIMEZONE functions..")
   CALL echo("...wrap validate function around the precision flag and if 0 convert to 1.")
   SELECT INTO "noforms"
    id = p.person_id"##########", tz = p.birth_tz"###", pf = p.birth_prec_flag"#",
    x1a = format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"@MEDIUMDATETIME"), x1b =
    cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)"@MEDIUMDATETIME", x2a =
    datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@MEDIUMDATETIME",0,18),
    x2b = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@MEDIUMDATETIME",curtimezonedef,18), x3a =
    format(datetimezoneutc(p.birth_dt_tm,p.birth_tz),"@MEDIUMDATETIME"), x3b = datetimezoneutc(p
     .birth_dt_tm,p.birth_tz)"@MEDIUMDATETIME",
    xraw = sqlpassthru("p.birth_dt_tm",22)
    FROM person p
    WHERE p.birth_dt_tm IS NOT null
     AND p.birth_tz=75
    WITH maxrec = 10
   ;end select
 END ;Subroutine
 SUBROUTINE (test_datetimezoneformat(tz=i4) =i2 WITH protect)
   CALL echo(">>>DATETIMEZONEFORMAT (CCL v9.02.4 | v8.14.4)")
   SET trace = utcdebug
   CALL echo(">>>MONTHABBREV=")
   CALL echo(curlocale("MONTHABBREV"))
   CALL echo(">>>MONTHABBREV2=")
   CALL echo(curlocale("MONTHABBREV2"))
   CALL echo(">>>MONTHFULL=")
   CALL echo(curlocale("MONTHFULL"))
   CALL echo("use uppercase M for month if minute used before month in format mask.")
   CALL echo(datetimezoneformat(cnvtdatetime(curdate,curtime),tz,"HHmm-mm/DD/YY"))
   CALL echo(datetimezoneformat(cnvtdatetime(curdate,curtime),tz,"HHmm-mm/DD/YY;;q"))
   CALL echo(datetimezoneformat(cnvtdatetime(curdate,curtime),tz,"HHmm-mmm/DD/YY"))
   CALL echo(datetimezoneformat(cnvtdatetime(curdate,curtime),tz,"HHmm-mmm/DD/YY;;q"))
   CALL echo(datetimezoneformat(cnvtdatetime(curdate,curtime),tz,"HHmm-mmmm/DD/YY"))
   CALL echo(datetimezoneformat(cnvtdatetime(curdate,curtime),tz,"HHmm-mmmm/DD/YY;;q"))
   SET trace = noutcdebug
   CALL echo(">>>DATETIMEZONEFORMAT (DE HELP tests/CCL v9.02.2 | v8.14.2, optional length param.")
   SET def_var = datetimezoneformat(cnvtdatetime("9-May-2018 13:30:45"),datetimezonebyname("UTC"),
    "dd-MMM-yyyy HH:mm:ss ZZZZZ",curtimezonedef)
   CALL echo(build("def_var= ",def_var,", type= ",reflect(def_var)))
   SET 30_var = datetimezoneformat(cnvtdatetime("9-May-2018 13:30:45"),datetimezonebyname("UTC"),
    "dd-MMM-yyyy HH:mm:ss ZZZZZ",curtimezonedef,30)
   CALL echo(build("30_var= ",30_var,", type= ",reflect(30_var)))
   SET 0_var1 = datetimezoneformat(cnvtdatetime("9-May-2018 13:30:45"),datetimezonebyname("UTC"),
    "dd-MMM-yyyy HH:mm:ss",curtimezonedef,0)
   CALL echo(build("0_var1= ",0_var1,", type= ",reflect(0_var1)))
   SET 0_var2 = datetimezoneformat(cnvtdatetime("9-May-2018 13:30:45"),datetimezonebyname("UTC"),
    "dd-MMM-yyyy HH:mm:ss ZZZZZ",curtimezonedef,0)
   CALL echo(build("0_var2= ",0_var2,", type= ",reflect(0_var2)))
   IF (((reflect(def_var) != "C128") OR (((reflect(30_var) != "C30") OR (reflect(0_var1) != "C20"))
   )) )
    CALL echo("ERROR in test_datetimezoneformat()!  Unexpected length.")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (test_datetimeadd(test_dt_tm=dq8) =i2 WITH protect)
   CALL echo(">>>DATETIMEADD (CCL v9.03.5 | v8.15.5) DTTMCALC/non-UTC..")
   DECLARE currenttime = dq8 WITH protect
   DECLARE currenttime2 = dq8 WITH protect
   DECLARE futuretime = dq8 WITH protect
   SET currenttime = cnvtdatetime(sysdate)
   CALL echo(build2("Current time:                   ",datetimezoneformat(currenttime,0,
      "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef)))
   SET futuretime = datetimeadd(currenttime,0.25)
   CALL echo(build2("After DateTimeAdd(0.25):        ",datetimezoneformat(futuretime,0,
      "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef)))
   SET currenttime2 = cnvtdatetime(sysdate)
   CALL echo(build2("Reset Current time:             ",datetimezoneformat(currenttime2,0,
      "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef)))
   IF (datetimediff(currenttime2,currenttime,4) > 1)
    CALL echo("ERROR in test_datetimeadd!  Current time reset incorrectly.")
   ENDIF
   CALL echo(fillstring(50,"="))
   CALL echo(">>>DATETIMEADD (CCL v9.02.4 | v8.14.4)..")
   CALL echo(">>>allow days greater then 24855 and less then 24855 with DTTMCALC trace.")
   CALL echo(build("DTTMCALC= ",trace("DTTMCALC")))
   SELECT INTO "noforms"
    seq = (24850+ d.seq), past = format(cnvtdatetime(datetimeadd(sysdate,- ((24850+ d.seq)))),";;q"),
    future = format(cnvtdatetime(datetimeadd(sysdate,(24850+ d.seq))),";;q")
    FROM (dummyt d  WITH seq = 10)
   ;end select
   SET trace = nodttmcalc
   CALL echo(build("DTTMCALC= ",trace("DTTMCALC")))
   SELECT INTO "noforms"
    seq = (24850+ d.seq), past = format(cnvtdatetime(datetimeadd(sysdate,- ((24850+ d.seq)))),";;q"),
    future = format(cnvtdatetime(datetimeadd(sysdate,(24850+ d.seq))),";;q")
    FROM (dummyt d  WITH seq = 10)
   ;end select
   SET trace = dttmcalc
   CALL echo(">>>DATETIMEADD (DE HELP tests).")
   SET start_dt_tm = cnvtdatetime("09-Mar-2014 03:00:00")
   SET end_dt_tm_add = datetimeadd(start_dt_tm,- (0.125),0)
   CALL echo(format(end_dt_tm_add,";;q"))
   SET end_dt_tm_add = datetimeadd(start_dt_tm,- (0.125),1)
   CALL echo(format(end_dt_tm_add,";;q"))
   SET end_dt_tm_add = datetimeadd(start_dt_tm,- (0.125),2)
   CALL echo(format(end_dt_tm_add,";;q"))
 END ;Subroutine
 SUBROUTINE (test_date_types(test_dt_tm=dq8) =i2 WITH protect)
   RECORD rec1(
     1 fld1_dq8 = dq8
     1 fld2_dm12 = dm12
     1 fld3_q8 = q8
   )
   DECLARE var1 = dq8 WITH noconstant(sysdate)
   DECLARE var2 = dm12 WITH noconstant(systimestamp)
   DECLARE var3 = q8 WITH noconstant(systimestamp)
   DECLARE varf8 = f8 WITH noconstant(12345.0)
   DECLARE var2f8 = f8 WITH protect, noconstant(123456789.0)
   DECLARE testf8 = f8 WITH constant(9999999999.0)
   CALL echo(build("testf8= ",testf8))
   SET rec1->fld1_dq8 = sysdate
   SET rec1->fld2_dm12 = systimestamp
   SET rec1->fld3_q8 = rec1->fld1_dq8
   CALL echorecord(rec1)
   CALL echo("Test sub1() with DQ8/Q8 type...")
   CALL sub1(rec1->fld1_dq8,rec1->fld3_q8)
   CALL sub1(var1,var3)
   CALL echo("Test sub2() with DM12 type...")
   CALL sub2(rec1->fld2_dm12)
   CALL echorecord(rec1)
   CALL sub2(var2)
   CALL echo(build("Before sub_f8, varf8= ",varf8,", var2f8= ",var2f8))
   CALL sub_f8(varf8,var2f8)
   CALL echo(build("After sub_f8, varf8= ",varf8,", var2f8= ",var2f8))
   SET var1 = 12345678.0
   CALL echo(build("Before sub_f8, var1= ",var1,", var2f8= ",var2f8))
   CALL sub_f8(var1,var2f8)
   CALL echo(build("After sub_f8, var1= ",var1,", var2f8= ",var2f8))
   SUBROUTINE (sub1(par1=dq8(ref),par2=dq8(value)) =null)
     SET par1 = cnvtdatetime((curdate+ 1),curtime3)
     SET par2 = cnvtdatetime((curdate+ 1),curtime3)
     CALL echo(build("sub1 dq8(ref)=",format(par1,";;q")))
     CALL echo(build("sub1 dq8(value)=",format(par2,";;q")))
   END ;Subroutine
   SUBROUTINE (sub2(par1=dm12(ref)) =null)
    SET par1 = systimestamp
    CALL echo(build("sub2 par1=",format(par1,"dd-mmm-yyyy hh:mm:ss.cccccc;;q")))
   END ;Subroutine
   SUBROUTINE (sub_f8(par1=f8(ref),par2=dq8(ref)) =null)
     CALL echo(build("sub_f8 par1=",par1," (pre)"))
     CALL echo(build("sub_f8 par2=",par2," (pre)"))
     SET par1 = testf8
     SET par2 = testf8
     CALL echo(build("sub_f8 par1=",par1," (post)"))
     CALL echo(build("sub_f8 par2=",par2," (post)"))
   END ;Subroutine
   CALL echo(_separator)
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    CALL echo("Error in DQ8/Q8/F8 test!")
   ENDIF
 END ;Subroutine
END GO
