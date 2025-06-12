CREATE PROGRAM bhs_eks_code_status_change:dba
 EXECUTE bhs_hlp_ccl
 DECLARE mf_encntr_id = f8 WITH protect, constant(trigger_encntrid)
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_molst_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "MOLSTLIFESUSTAININGTREATMENTORDERS"))
 DECLARE mf_comfort_measure_only_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "COMFORTMEASUREONLY"))
 DECLARE mf_limited_resuscitation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LIMITEDRESUSCITATION"))
 DECLARE mf_dnrnocprbutoktointubate_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRNOCPRBUTOKTOINTUBATE"))
 DECLARE mf_dnrdninocprnointubation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DNRDNINOCPRNOINTUBATION"))
 DECLARE mf_fullcodeconfirmed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLCODECONFIRMED"))
 DECLARE mf_fullcodepresumed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FULLCODEPRESUMED"))
 DECLARE mf_order_id = f8 WITH protect, noconstant(0)
 DECLARE mn_update_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_order_mnemonic = vc WITH protect, noconstant("")
 IF (validate(retval)=0)
  DECLARE retval = i4 WITH public, noconstant(0)
 ENDIF
 IF (validate(log_message)=0)
  DECLARE log_message = vc WITH public, noconstant("")
 ENDIF
 SELECT INTO "nl:"
  FROM orders o
  WHERE o.encntr_id=mf_encntr_id
   AND o.catalog_cd IN (mf_comfort_measure_only_cd, mf_dnrnocprbutoktointubate_cd,
  mf_dnrdninocprnointubation_cd, mf_fullcodeconfirmed_cd, mf_fullcodepresumed_cd,
  mf_limited_resuscitation_cd, mf_molst_cd)
   AND o.order_status_cd=mf_ordered_cd
  ORDER BY o.orig_order_dt_tm DESC
  HEAD o.encntr_id
   ms_order_mnemonic = cnvtupper(trim(o.order_mnemonic,3)), mf_order_id = o.order_id, log_message =
   build("Order Mnemonic: ",o.order_mnemonic)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET log_message = "There are no qualifying orders for this encounter."
  SET retval = 0
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_log b,
   bhs_log_detail bd
  PLAN (b
   WHERE b.object_name="BHS_EKS_CODE_STATUS_CHANGE"
    AND (b.updt_id=reqinfo->updt_id)
    AND b.updt_dt_tm BETWEEN cnvtdatetime((curdate - 60),curtime) AND cnvtdatetime(curdate,curtime)
    AND b.msg="000")
   JOIN (bd
   WHERE bd.bhs_log_id=b.bhs_log_id
    AND bd.parent_entity_name="ENCNTR_ID"
    AND bd.parent_entity_id=mf_encntr_id
    AND bd.description="MNEMONIC")
  ORDER BY bd.bhs_log_id, bd.detail_group, bd.detail_seq
  DETAIL
   IF (bd.msg != ms_order_mnemonic)
    mn_update_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM orders o
   WHERE o.encntr_id=mf_encntr_id
    AND o.catalog_cd IN (mf_comfort_measure_only_cd, mf_limited_resuscitation_cd,
   mf_dnrnocprbutoktointubate_cd, mf_dnrdninocprnointubation_cd, mf_fullcodeconfirmed_cd,
   mf_fullcodepresumed_cd, mf_molst_cd)
    AND o.order_id != mf_order_id
   ORDER BY o.orig_order_dt_tm DESC
   HEAD o.encntr_id
    IF (cnvtupper(trim(o.order_mnemonic,3)) != ms_order_mnemonic)
     retval = 100, log_message =
     "Code status changed prior to user ever openening the chart, returning true."
    ELSE
     retval = 0, log_message =
     "Code status has not changed prior to user opening the chart, returning false."
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET retval = 0
  ENDIF
  CALL bhs_sbr_log("start","",0,"",0.0,
   "","Begin Script","")
  CALL bhs_sbr_log("log","",1,"ENCNTR_ID",mf_encntr_id,
   "MNEMONIC",ms_order_mnemonic,"S")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "","000","S")
 ELSEIF (mn_update_ind=1)
  SET retval = 100
  SET log_message = "User has not received an alert for this order change, returning true."
  UPDATE  FROM bhs_log_detail bd
   SET bd.msg = ms_order_mnemonic, bd.updt_dt_tm = sysdate
   WHERE bd.parent_entity_id=mf_encntr_id
    AND (bd.updt_id=reqinfo->updt_id)
    AND bd.description="MNEMONIC"
    AND bd.updt_dt_tm BETWEEN cnvtdatetime((curdate - 60),curtime) AND cnvtdatetime(curdate,curtime)
   WITH nocounter
  ;end update
  COMMIT
 ELSE
  SET retval = 0
  SET log_message = "User has already received an alert for this order."
 ENDIF
#exit_program
END GO
