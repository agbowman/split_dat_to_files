CREATE PROGRAM bhs_eks_rad_wcontrast
 SET encntrid = trigger_encntrid
 SET retval = 0
 DECLARE rejected_14202 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14202,"REJECTED")), protect
 DECLARE onhold_14202 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14202,"ONHOLD")), protect
 DECLARE canceled_14202 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14202,"CANCELED")), protect
 DECLARE rad_order = vc
 DECLARE log_misc1 = vc
 IF (curnode IN ("cismock2", "cismock3"))
  SET logical radorders "/cerner/d_cisnew/bhs_custom/rad_contrast_orders.txt"
 ELSEIF (curnode="casEtest")
  SET logical radorders "/cerner/d_test/bhs_custom/rad_contrast_orders.txt"
 ELSEIF (curnode="casDtest")
  SET logical radorders "/cerner/d_build/bhs_custom/rad_contrast_orders.txt"
 ELSE
  SET logical radorders "bhscust:rad_contrast_orders.txt"
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl "radorders"
 IF (( $1="A"))
  SELECT INTO "nl:"
   FROM rtlt r,
    order_catalog oc,
    order_radiology ro
   PLAN (r)
    JOIN (oc
    WHERE oc.primary_mnemonic=r.line)
    JOIN (ro
    WHERE ro.encntr_id=encntrid
     AND ro.catalog_cd=oc.catalog_cd
     AND ro.start_dt_tm > cnvtlookbehind("48,H")
     AND  NOT (ro.report_status_cd IN (rejected_14202, onhold_14202, canceled_14202))
     AND  NOT ( EXISTS (
    (SELECT
     od.order_id
     FROM order_detail od
     WHERE od.order_id=ro.order_id
      AND od.oe_field_display_value IN ("No Contrast", "Oral Contrast Only", "Rectal Contrast")))))
   DETAIL
    retval = 100, rad_order = trim(oc.primary_mnemonic)
   FOOT REPORT
    log_misc1 = concat("You are attempting to order metformin in a patient",
     " who has completed a contrast enhanced radiographic",
     " study within the last 48 hours.  It is recommended",
     " that metformin should be avoided for at least 48 hours following",
     " the administration of intravenous contrast.",
     "If you have additional questions please contact the pharmacy."), log_message = build2( $1,"-",
     log_misc1)
   WITH nocounter
  ;end select
  CALL echo(build("retval:",retval))
  CALL echo(rad_order)
 ELSEIF (( $1="B"))
  SELECT INTO "nl:"
   FROM rtlt r,
    order_catalog oc,
    order_radiology ro
   PLAN (r)
    JOIN (oc
    WHERE oc.primary_mnemonic=r.line)
    JOIN (ro
    WHERE ro.encntr_id=encntrid
     AND ro.catalog_cd=oc.catalog_cd
     AND ro.start_dt_tm = null
     AND ro.request_dt_tm < cnvtlookahead("48,H")
     AND  NOT (ro.report_status_cd IN (rejected_14202, onhold_14202, canceled_14202))
     AND  NOT ( EXISTS (
    (SELECT
     od.order_id
     FROM order_detail od
     WHERE od.order_id=ro.order_id
      AND od.oe_field_display_value IN ("No Contrast", "Oral Contrast Only", "Rectal Contrast")))))
   DETAIL
    retval = 100, rad_order = trim(oc.primary_mnemonic), log_misc1 = concat(
     "You are attempting to order metformin in a patient who is schedule to undergo a contrast",
     " enhanced radiographic study ",rad_order,
     ". Because of the risk of contrast induced renal failure",
     " metformin should not be administered within 48 hours of administering intravenous contrast.",
     "If you have additional questions please contact the pharmacy."),
    log_message = build2( $1,encntrid)
   WITH nocounter
  ;end select
  CALL echo(build("retval:",retval))
  CALL echo(rad_order)
 ENDIF
END GO
