CREATE PROGRAM bhs_eks_chk_rule_120808:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Time in seconds:" = 0,
  "EKSModule:" = "",
  "qualify per user (1 = yes; 0 = no):" = 0
  WITH outdev, time, eksmod,
  user
 DECLARE log_message = vc
 DECLARE msg1 = vc
 DECLARE msg2 = vc
 DECLARE msg3 = vc
 DECLARE actionfired = i4 WITH noconstant(0)
 SET eid = trigger_encntrid
 SET retval = 0
 SET lookback = cnvtlookbehind(build(cnvtstring( $TIME),",s"),cnvtdatetime(curdate,curtime3))
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 CALL echo(format(cnvtdatetime(lookback),";;q"))
 CALL echo(build("eid:",eid))
 SELECT INTO "NL:"
  e.rec_id
  FROM eks_module_audit e,
   eks_module_audit_det ed
  PLAN (e
   WHERE e.begin_dt_tm >= cnvtdatetime(lookback)
    AND cnvtupper(e.module_name) IN (value(cnvtupper(trim( $EKSMOD,3)))))
   JOIN (ed
   WHERE ed.module_audit_id=e.rec_id
    AND ed.encntr_id=eid)
  DETAIL
   CALL echo(build("e.action_return:",e.action_return))
   IF (findstring("100",e.action_return,1) > 0)
    actionfired = 1
   ENDIF
   CALL echo(build("actionFired:",actionfired))
  WITH nocounter, format
 ;end select
 CALL echo(reqinfo->updt_id)
 IF (curqual > 0
  AND actionfired=1)
  SET retval = 100
 ENDIF
 DECLARE hlog = i4 WITH protect, noconstant(0)
 DECLARE hstat = i4 WITH protect, noconstant(0)
 SET msg1 = build2("retval: ",cnvtstring(retval))
 SET msg2 = build2("lookBack in Sec: ",format(cnvtdatetime(lookback),";;q"))
 SET msg3 = build2("EKSModule:", $EKSMOD)
 SET msg4 =
 IF (retval=100) "Rule fired before"
 ELSE "Rule has not fired before"
 ENDIF
 SET log_message = concat("eid: ",cnvtstring(eid)," - ",msg1,"  ",
  char(13),msg2,"  ",char(13),msg3,
  "  ",char(13),msg4)
 CALL echo(log_message)
#exit_prog
END GO
