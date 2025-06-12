CREATE PROGRAM dmscclrtl_ipp_test:dba
 RECORD reply(
   1 status = c1
 )
 SET reply->status = "F"
 SELECT INTO request->printer_name
  DETAIL
   "abc"
  WITH print = "land"
 ;end select
 SELECT INTO request->printer_name
  DETAIL
   "dfg"
  WITH print = "port"
 ;end select
 SELECT INTO request->printer_name
  DETAIL
   ""
  WITH print = "legaltray"
 ;end select
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "simplex"
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "duplex"
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "pstumble", dio = 8
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "a4tray", duplex
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "lettertray", duplex
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH media = "ledger", duplex, dio
  = 8
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "tray1", duplex
 SET spool "CER_TEMP:print_test.dat" value(request->printer_name) WITH print = "tray2", duplex, dio
  = 8
 SET reply->status = "S"
END GO
