CREATE PROGRAM bhs_rad_order_status:dba
 PROMPT
  "CATALOGTYPE:" = ""
  WITH catalogtype
 DECLARE mf_catcode_value = f8 WITH protect, constant(uar_get_code_by("DISPLAYkey",6000,"RADIOLOGY"))
 DECLARE mf_remove_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14281,"RADREMOVED"))
 DECLARE mf_discontinue_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,
   "DISCONTINUED"))
 DECLARE mf_suspend_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"SUSPENDED"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"CANCELED"))
 DECLARE mf_orderstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_orderid = f8 WITH protect, noconstant(0.0)
 DECLARE ms_catalogtype = vc WITH protect, noconstant(" ")
 SET mf_orderid = trigger_orderid
 SET ms_catalogtype = cnvtupper(uar_get_code_description(mf_catcode_value))
 IF (( $CATALOGTYPE=ms_catalogtype))
  SELECT INTO "nl:"
   o.order_status_cd, o.dept_status_cd
   FROM orders o
   WHERE o.order_id=mf_orderid
    AND o.order_status_cd IN (mf_canceled_cd, mf_suspend_cd, mf_discontinue_cd)
    AND o.dept_status_cd != mf_remove_cd
   DETAIL
    orderstatuscd = o.order_status_cd
  ;end select
  SET ml_flag = 1 WITH nocounter
  IF (ml_flag=0)
   SET retval = 0
   SET msg = concat("bhs_rad_order_status.prg logic failed")
  ENDIF
  IF (ml_flag >= 1)
   SET retval = 100
   SET msg = "end of bhs_rad_order_status logic"
  ENDIF
 ENDIF
END GO
