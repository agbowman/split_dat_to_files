CREATE PROGRAM bhs_eks_rad_find_wet_read:dba
 DECLARE mf_addtext_action_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30460,"ADDTEXT"))
 DECLARE mf_rad_order_id = f8 WITH protect, noconstant(0.00)
 SET retval = - (1)
 SET log_message = concat("Script failed.")
 SELECT INTO "nl:"
  FROM rad_init_read rir
  PLAN (rir
   WHERE rir.order_id=link_orderid
    AND rir.activity_cd=mf_addtext_action_cd)
  HEAD REPORT
   retval = 100, log_message = "Wet read found for completed exam."
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 0
  SET log_message = "No wet read found for completed exam."
  GO TO exit_script
 ENDIF
#exit_script
END GO
