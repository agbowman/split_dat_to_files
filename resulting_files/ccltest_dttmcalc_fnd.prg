CREATE PROGRAM ccltest_dttmcalc_fnd
 CALL echo(build("Date Mode (",evaluate(curutc,1,"UTC","LOCAL"),")"," | DTTMCALC (",trace("DTTMCALC"),
   ")"))
 CALL echo("")
 CALL echo("Spring DST Event")
 CALL echo(concat("  Test Date Time Local: ",datetimezoneformat(cnvtdatetime("13-MAR-2016 01:50:00"),
    0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("    Test Date Time UTC: ",datetimezoneformat(cnvtdatetime("13-MAR-2016 01:50:00"),
    datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat(" Look Ahead Local Time: ",datetimezoneformat(cnvtlookahead("20, MIN",cnvtdatetime(
      "13-MAR-2016 01:50:00")),0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("   Look Ahead UTC Time: ",datetimezoneformat(cnvtlookahead("20, MIN",cnvtdatetime(
      "13-MAR-2016 01:50:00")),datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo("")
 CALL echo(concat("  Test Date Time Local: ",datetimezoneformat(cnvtdatetime("13-MAR-2016 03:10:00"),
    0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("    Test Date Time UTC: ",datetimezoneformat(cnvtdatetime("13-MAR-2016 03:10:00"),
    datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("Look Behind Local Time: ",datetimezoneformat(cnvtlookbehind("20, MIN",cnvtdatetime
     ("13-MAR-2016 03:10:00")),0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("  Look Behind UTC Time: ",datetimezoneformat(cnvtlookbehind("20, MIN",cnvtdatetime
     ("13-MAR-2016 03:10:00")),datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo("")
 CALL echo("FALL DST Event")
 CALL echo(concat("  Test Date Time Local: ",datetimezoneformat(cnvtdatetime("06-NOV-2016 00:50:00"),
    0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("    Test Date Time UTC: ",datetimezoneformat(cnvtdatetime("06-NOV-2016 00:50:00"),
    datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat(" Look Ahead Local Time: ",datetimezoneformat(cnvtlookahead("20, MIN",cnvtdatetime(
      "06-NOV-2016 00:50:00")),0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("   Look Ahead UTC Time: ",datetimezoneformat(cnvtlookahead("20, MIN",cnvtdatetime(
      "06-NOV-2016 00:50:00")),datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo("")
 CALL echo(concat("  Test Date Time Local: ",datetimezoneformat(cnvtdatetime("06-NOV-2016 01:10:00"),
    0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("    Test Date Time UTC: ",datetimezoneformat(cnvtdatetime("06-NOV-2016 01:10:00"),
    datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("Look Behind Local Time: ",datetimezoneformat(cnvtlookbehind("20, MIN",cnvtdatetime
     ("06-NOV-2016 01:10:00")),0,"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo(concat("  Look Behind UTC Time: ",datetimezoneformat(cnvtlookbehind("20, MIN",cnvtdatetime
     ("06-NOV-2016 01:10:00")),datetimezonebyname("UTC"),"dd-MMM-yyyy HH:mm:ss ZZZ",curtimezonedef)))
 CALL echo("")
END GO
