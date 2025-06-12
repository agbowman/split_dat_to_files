CREATE PROGRAM bhs_eks_iv_po_conversion:dba
 SET retval = 0
 DECLARE rate_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"RATE")), protect
 DECLARE amountoftubefeeding_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "AMOUNTOFTUBEFEEDING")), protect
 DECLARE amountofadditive_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "AMOUNTOFADDITIVE")), protect
 DECLARE tubefeedingadditive_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGADDITIVE")), protect
 DECLARE tubefeedingadditivenf_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGADDITIVENF")), protect
 DECLARE tubefeedingbolus_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"TUBEFEEDINGBOLUS")
  ), protect
 DECLARE tubefeedingbolusnf_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGBOLUSNF")), protect
 DECLARE tubefeedingboluspedi_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGBOLUSPEDI")), protect
 DECLARE tubefeedingcontinuous_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGCONTINUOUS")), protect
 DECLARE tubefeedingcontinuousnf_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGCONTINUOUSNF")), protect
 DECLARE tubefeedingcontinuouspedi_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "TUBEFEEDINGCONTINUOUSPEDI")), protect
 DECLARE notdone_var = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE")), protect
 DECLARE in_error_var = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
 DECLARE inerrnomut_var = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
 DECLARE inerrnoview_var = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
 DECLARE inerror_var = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE med_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MED")), protect
 DECLARE oral_dose = f8 WITH noconstant(0.0), protect
 SET oral_dose = 0.0
 SELECT INTO "nl:"
  ce.catalog_cd, od.oe_field_display_value
  FROM clinical_event ce,
   order_detail od
  PLAN (ce
   WHERE ce.encntr_id=trigger_encntrid
    AND ce.catalog_cd IN (tubefeedingcontinuouspedi_var, tubefeedingcontinuousnf_var,
   tubefeedingcontinuous_var, tubefeedingboluspedi_var, tubefeedingbolusnf_var,
   tubefeedingbolus_var, tubefeedingadditivenf_var, tubefeedingadditive_var)
    AND cnvtupper(ce.event_tag) IN ("DONE")
    AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime3))
   JOIN (od
   WHERE od.order_id=ce.order_id
    AND od.oe_field_id IN (amountoftubefeeding_var, rate_var, amountofadditive_var))
  DETAIL
   oral_dose = (oral_dose+ cnvtreal(od.oe_field_display_value))
  WITH nocounter
 ;end select
 IF (oral_dose >= 1000)
  SET retval = 100
  SET log_message = "IV PO Alert Qualified on Tube Feedings"
 ELSE
  SET retval = 0
 ENDIF
 IF (retval=0)
  SELECT INTO "nl:"
   FROM clinical_event ce,
    order_detail od
   PLAN (ce
    WHERE ce.encntr_id=trigger_encntrid
     AND ce.event_class_cd=med_var
     AND ce.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime3)
     AND ce.valid_until_dt_tm > sysdate
     AND  NOT (ce.result_status_cd IN (notdone_var, in_error_var, inerror_var, inerrnomut_var,
    inerrnoview_var)))
    JOIN (od
    WHERE od.order_id=ce.order_id
     AND od.oe_field_meaning="RXROUTE"
     AND cnvtupper(od.oe_field_display_value) IN ("G TUBE", "J TUBE", "BY MOUTH", "NASOGASTRIC TUBE",
    "OROGASTRIC TUBE",
    "PEG", "CHEW", "SWISH AND SPIT", "SWISH AND SWALLOW", "SPRINKLE ON FOOD"))
   DETAIL
    retval = 100
   WITH nocounter
  ;end select
 ENDIF
 IF (retval=100)
  SET log_message = "IV PO Alert Qualified on Oral Med Admins."
 ENDIF
END GO
