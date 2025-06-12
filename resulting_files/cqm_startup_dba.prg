CREATE PROGRAM cqm_startup:dba
 SET modify maxvarlen 100000000
 DECLARE cqm_rtllevel = vc
 SET cqm_rtllevel = cnvtupper(logical("CQM_RTLLEVEL"))
 CALL echo("05-May-2000")
 CALL echo(build("cqm_rtllevel:",cqm_rtllevel))
 IF (cqm_rtllevel="COST")
  SET trace = cost
 ENDIF
 IF (cqm_rtllevel="TEST")
  SET message = information
  SET trace = echoprog
  SET trace = callecho
  SET trace = cost
 ENDIF
 IF (cqm_rtllevel="DEBUG")
  SET message = information
  SET trace = callecho
  SET trace = rdbdebug
  SET trace = rdbbind
  SET trace = rdbprogram
  SET trace = rdbbindcons
  SET trace = echorecord
  SET trace = echoprog
  SET trace = cost
 ENDIF
 IF (cqm_rtllevel="SERVER")
  SET message = information
  SET trace = callecho
  SET trace = rdbdebug
  SET trace = rdbbind
  SET trace = echoprog
  SET trace = cost
  CALL trace(8)
 ENDIF
 TRANSLATE  cqm_get_queueid  WITH loadpersist
 TRANSLATE  cqm_get_triggerid  WITH loadpersist
 TRANSLATE  cqm_get_contributoralias  WITH loadpersist
 TRANSLATE  cqm_get_contributorid  WITH loadpersist
 TRANSLATE  cqm_get_listenerid  WITH loadpersist
 TRANSLATE  cqm_get_listconfiglistname  WITH loadpersist
 TRANSLATE  cqm_get_listaliaspriority  WITH loadpersist
 TRANSLATE  cqm_get_quecontribrefnum  WITH loadpersist
 TRANSLATE  cqm_get_queprocstatprior  WITH loadpersist
 TRANSLATE  cqm_get_quecontribrefnumidx  WITH loadpersist
 TRANSLATE  cqm_get_registryid  WITH loadpersist
 TRANSLATE  cqm_get_reglistapp  WITH loadpersist
 TRANSLATE  cqm_get_reglistid  WITH loadpersist
 TRANSLATE  cqm_get_reglisttype  WITH loadpersist
 TRANSLATE  cqm_upd_queue  WITH loadpersist
 TRANSLATE  cqm_upd_trigger  WITH loadpersist
 TRANSLATE  cqm_ins_trigger  WITH loadpersist
 TRANSLATE  cqm_insert_queue  WITH loadpersist
END GO
