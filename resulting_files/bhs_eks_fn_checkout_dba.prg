CREATE PROGRAM bhs_eks_fn_checkout:dba
 SET retval = 0
 SELECT INTO "nl:"
  FROM tracking_item t,
   tracking_checkin tc
  PLAN (t
   WHERE t.encntr_id=trigger_encntrid)
   JOIN (tc
   WHERE tc.tracking_id=t.tracking_id)
  DETAIL
   IF (tc.checkout_dt_tm <= sysdate)
    retval = 100
   ENDIF
  WITH nocounter
 ;end select
#exit_script
END GO
