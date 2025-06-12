CREATE PROGRAM bhs_eks_check_med_rec_transfer
 SET pid = trigger_personid
 SET eid = trigger_encntrid
 SET retval = 0
 SET recon_type_flag = 0
 SELECT INTO "nl:"
  FROM order_compliance o
  PLAN (o
   WHERE o.encntr_id=eid)
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 CALL echo(build("no_home_meds_ind = ",o.no_home_meds_ind))
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM order_recon orc
   WHERE orc.encntr_id=eid
    AND orc.recon_type_flag=2
   DETAIL
    recon_type_flag = 2, retval = 0
   WITH nocounter
  ;end select
 ENDIF
END GO
