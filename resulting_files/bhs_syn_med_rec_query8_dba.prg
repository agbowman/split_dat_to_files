CREATE PROGRAM bhs_syn_med_rec_query8:dba
 DECLARE log_message = vc WITH noconstant(" ")
 SET retval = 0
 SELECT INTO "nl:"
  FROM order_compliance oc2
  WHERE oc2.encntr_id=trigger_encntrid
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
 SET log_message = build(log_message,"retval = ",retval)
 CALL echo(log_message)
END GO
