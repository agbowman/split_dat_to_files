CREATE PROGRAM bhs_surg_mp_case_wid_tst:dba
 SET trace = rdbbind
 SET trace = rdbdebug
 SET trace = echoinput
 SET trace = echoinput2
 SET dm2_debug_flag = 10
 EXECUTE bhs_surg_mp_case_wid 1069396.00
END GO
