CREATE PROGRAM bhs_eks_pim_chk_override
 SET retval = - (1)
 DECLARE override_ind = i2
 DECLARE permanent_override_cd = f8
 DECLARE drug_class = i4
 SET permanent_override_cd = uar_get_code_by("DISPLAYKEY",800,"PERMANENTLYDISABLEALERTALLPATIENTS")
 IF (permanent_override_cd <= 0.00)
  CALL echo("Permanent override reason not found")
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 EXECUTE bhs_pim_drug_lists
 FOR (x1 = 1 TO pim_drugs->drug_class_cnt)
   FOR (x2 = 1 TO pim_drugs->drug_classes[x1].drug_cnt)
     IF ((pim_drugs->drug_classes[x1].drugs[x2].catalog_cd=request->orderlist[event_repeat_index].
     catalog_code))
      SET drug_class = x1
     ENDIF
   ENDFOR
 ENDFOR
 IF (drug_class <= 0)
  CALL echo("Drug Class not found")
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 DECLARE provider_invalid_ind = i2
 SET provider_invalid_ind = - (1)
 SELECT INTO "nl:"
  bpr.group_role, bpr.active_ind
  FROM bhs_pim_provider bpr
  PLAN (bpr
   WHERE (bpr.prsnl_id=request->orderlist[event_repeat_index].physician))
  DETAIL
   IF (((bpr.active_ind=0) OR (bpr.group_role="C")) )
    provider_invalid_ind = 1, retval = 100
   ELSE
    provider_invalid_ind = 0, retval = 0
   ENDIF
  WITH nocounter
 ;end select
 IF ((provider_invalid_ind=- (1)))
  CALL echo("Provider not part of study")
  GO TO exit_script
 ELSEIF (provider_invalid_ind=1)
  CALL echo("Provider not active or in the intervention group")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ede.encntr_id, ede.override_reason_cd
  FROM (dummyt d  WITH seq = value(pim_drugs->drug_classes[drug_class].drug_cnt)),
   eks_dlg_event ede,
   order_action oa
  PLAN (d)
   JOIN (ede
   WHERE ede.dlg_name="BHS_EKM!BHS_SYN_PIM_INAPPR_DRUGS"
    AND (ede.trigger_entity_id=pim_drugs->drug_classes[drug_class].drugs[d.seq].catalog_cd))
   JOIN (oa
   WHERE ede.trigger_order_id=oa.order_id
    AND oa.action_sequence=1
    AND (oa.order_provider_id=request->orderlist[event_repeat_index].physician))
  DETAIL
   IF (((trigger_encntrid=ede.encntr_id) OR (ede.override_reason_cd=permanent_override_cd)) )
    override_ind = 1, retval = 100
   ENDIF
  WITH nocounter
 ;end select
 IF (override_ind=0)
  SELECT INTO "nl:"
   bpaa.encntr_id, bpaa.override_reason_cd
   FROM bhs_pim_alert_activity bpaa,
    bhs_pim_assoc_orders bpao
   PLAN (bpaa
    WHERE (bpaa.prsnl_id=request->orderlist[event_repeat_index].physician)
     AND bpaa.override_reason_cd != 0.00)
    JOIN (bpao
    WHERE bpaa.activity_id=bpao.activity_id
     AND bpao.order_type="DRUG_CLASS*"
     AND (trim(substring(12,89,bpao.order_type),3)=pim_drugs->drug_classes[drug_class].drug_class))
   DETAIL
    IF (((trigger_encntrid=bpaa.encntr_id) OR (bpaa.override_reason_cd=permanent_override_cd)) )
     override_ind = 1, retval = 100
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((retval=- (1)))
  SET retval = 0
 ENDIF
 SET log_message = build("Catalogcd:",request->orderlist[event_repeat_index].catalog_code)
#exit_script
END GO
