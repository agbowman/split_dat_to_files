CREATE PROGRAM bhs_eks_pim_rule_logic
 IF (validate(log_misc1,"A")="A"
  AND validate(log_misc1,"Z")="Z")
  DECLARE retval = i4
  DECLARE log_misc1 = vc
  DECLARE log_message = vc
 ENDIF
 SET retval = - (1)
 DECLARE tmp_retval = i4
 DECLARE tmp_message = vc
 DECLARE newid = f8
 DECLARE drug_class = i4
 DECLARE drugclass = vc
 DECLARE maxdose = f8
 DECLARE override_ind = i2
 DECLARE provider_invalid_ind = i2
 DECLARE mf_quetiapine_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"QUETIAPINE"))
 DECLARE mf_lorazepam_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LORAZEPAM"))
 DECLARE mf_lorazepam2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM100MGIND5W1000ML"))
 DECLARE mf_lorazepam3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM100MGINNACL091000ML"))
 DECLARE mf_lorazepam4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM100MGINNACL09100MLPEDI"))
 DECLARE mf_lorazepam5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM25MGIND5W250ML"))
 DECLARE mf_lorazepam6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM25MGINNACL09250ML"))
 DECLARE mf_lorazepam7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM2MGINNACL0920MLPEDIST"))
 DECLARE mf_lorazepam8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM50MGIND5W500ML"))
 DECLARE mf_lorazepam9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM50MGINNACL09500ML"))
 DECLARE mf_lorazepam10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "LORAZEPAM50MGINNACL0950MLPEDIS"))
#is_drug_valid
 EXECUTE bhs_pim_drug_lists
 SET tmp_retval = - (1)
 SET drug_class = 0
 SET drugclass = " "
 SET order_dose = 0.00
 FOR (x1 = 1 TO pim_drugs->drug_class_cnt)
   FOR (x2 = 1 TO pim_drugs->drug_classes[x1].drug_cnt)
     IF (trim(drugclass,4) <= " "
      AND (pim_drugs->drug_classes[x1].drugs[x2].catalog_cd=request->orderlist[event_repeat_index].
     catalog_code))
      SET drug_class = x1
      SET drugclass = build2("DRUG_CLASS:",pim_drugs->drug_classes[x1].drug_class)
      SET log_misc1 = pim_drugs->drug_classes[x1].message_text
     ENDIF
   ENDFOR
 ENDFOR
 IF (substring(1,10,drugclass) != "DRUG_CLASS")
  SET tmp_message = build2(trim(tmp_message,3)," Drug class not found.  Drug not part of study.")
  GO TO exit_script
 ELSE
  SET tmp_message = build2(trim(tmp_message,3)," Drug class equals ",trim(replace(drugclass,
     "DRUG_CLASS:","",1),3),".")
  SET tmp_message = build2(trim(tmp_message,3)," Alert message is '",replace(log_misc1,char(9)," ",0),
   ".")
 ENDIF
#get_new_alert_activity_id
 SET tmp_retval = - (1)
 SET newid = 0.00
 SELECT INTO "nl:"
  nextid = seq(bhs_pim_alert_activity_seq,nextval)
  FROM dual
  DETAIL
   newid = nextid
  WITH nocounter
 ;end select
 IF (newid <= 0.00)
  SET tmp_message = build2(trim(tmp_message,3)," Failed to get new BHS_PIM_ALERT_ACTIVITY_SEQ value."
   )
  GO TO exit_script
 ELSE
  SET tmp_message = build2(trim(tmp_message,3)," New BHS_PIM_ALERT_ACTIVITY_SEQ value is ",trim(
    build2(newid),3),".")
 ENDIF
#insert_new_alert_activity_row
 SET tmp_message = build2(trim(tmp_message,3)," row insert: ",trim(build2(newid),3),",",trim(build2(
    request->orderlist[event_repeat_index].physician),3),
  ",",trim(build2(trigger_encntrid),3),",",trim(build2(request->orderlist[event_repeat_index].orderid
    ),3),",",
  trim(build2(request->orderlist[event_repeat_index].catalog_code),3),",",".")
 SET tmp_retval = - (1)
 INSERT  FROM bhs_pim_alert_activity
  (activity_id, prsnl_id, encntr_id,
  eks_dig_event_id, order_id, override_reason_cd,
  events_found_ind, assoc_orders_ind, create_dt_tm,
  active_ind)
  VALUES(newid, request->orderlist[event_repeat_index].physician, trigger_encntrid,
  0.00, request->orderlist[event_repeat_index].orderid, 0.00,
  0, 0, sysdate,
  1)
 ;end insert
 COMMIT
 SELECT INTO "nl:"
  FROM bhs_pim_alert_activity
  WHERE activity_id=newid
  DETAIL
   tmp_retval = 100
  WITH nocounter
 ;end select
 IF (tmp_retval != 100)
  SET tmp_message = build2(trim(tmp_message,3)," Insert into BHS_PIM_ALERT_ACTIVITY failed.")
  GO TO exit_script
 ELSE
  SET tmp_message = build2(trim(tmp_message,3)," Insert into BHS_PIM_ALERT_ACTIVITY successful.")
 ENDIF
#insert_new_assoc_orders_row
 SET tmp_retval = - (1)
 INSERT  FROM bhs_pim_assoc_orders
  SET activity_id = newid, order_id = request->orderlist[event_repeat_index].catalog_code, order_type
    = drugclass,
   active_ind = 1
  WITH nocounter
 ;end insert
 COMMIT
 SELECT INTO "nl:"
  FROM bhs_pim_assoc_orders
  WHERE activity_id=newid
  DETAIL
   tmp_retval = 100
  WITH nocounter
 ;end select
 IF (tmp_retval != 100)
  SET tmp_message = build2(trim(tmp_message,3)," Insert into BHS_PIM_ASSOC_ORDERS failed.")
  GO TO exit_script
 ELSE
  SET tmp_message = build2(trim(tmp_message,3)," Insert into BHS_PIM_ASSOC_ORDERS successful.")
 ENDIF
#check_provider_override
 SET tmp_retval = - (1)
 SELECT INTO "nl:"
  FROM bhs_pim_alert_activity bpaa,
   bhs_pim_assoc_orders bpao
  WHERE bpaa.encntr_id=trigger_encntrid
   AND (bpaa.prsnl_id=request->orderlist[event_repeat_index].physician)
   AND bpaa.override_reason_cd > 0.0
   AND bpao.activity_id=bpaa.activity_id
   AND (bpao.order_id=request->orderlist[event_repeat_index].catalog_code)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET tmp_message = build2(trim(tmp_message,3),
   " Provider override for medication for this encounter found.")
  UPDATE  FROM bhs_pim_alert_activity bpaa
   SET bpaa.override_reason_cd = - (2)
   WHERE bpaa.activity_id=newid
  ;end update
  COMMIT
  GO TO exit_script
 ENDIF
 IF ((request->orderlist[event_repeat_index].catalog_code=mf_quetiapine_cd))
  SELECT INTO "nl:"
   FROM bhs_pim_alert_activity bpaa,
    bhs_pim_assoc_orders bpao
   WHERE bpaa.encntr_id=trigger_encntrid
    AND (bpaa.prsnl_id=request->orderlist[event_repeat_index].physician)
    AND bpaa.create_dt_tm > cnvtdatetime(curdate,(curtime - 30))
    AND bpaa.override_reason_cd=0.0
    AND bpao.activity_id=bpaa.activity_id
    AND trim(bpao.order_type) IN ("DRUG_CLASS:Long-acting benzodiazepines",
   "DRUG_CLASS:Short-acting benzodiazepines")
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET tmp_message = build2(trim(tmp_message,3)," Provider cancelled benzo order within 30min")
   UPDATE  FROM bhs_pim_alert_activity bpaa
    SET bpaa.override_reason_cd = - (3)
    WHERE bpaa.activity_id=newid
   ;end update
   COMMIT
   GO TO exit_script
  ENDIF
 ELSEIF ((request->orderlist[event_repeat_index].catalog_code IN (mf_lorazepam_cd, mf_lorazepam2_cd,
 mf_lorazepam3_cd, mf_lorazepam4_cd, mf_lorazepam5_cd,
 mf_lorazepam6_cd, mf_lorazepam7_cd, mf_lorazepam8_cd, mf_lorazepam9_cd, mf_lorazepam10_cd)))
  SELECT INTO "nl:"
   FROM bhs_pim_alert_activity bpaa,
    bhs_pim_assoc_orders bpao
   WHERE bpaa.encntr_id=trigger_encntrid
    AND (bpaa.prsnl_id=request->orderlist[event_repeat_index].physician)
    AND bpaa.create_dt_tm > cnvtdatetime(curdate,(curtime - 30))
    AND bpaa.override_reason_cd=0.0
    AND bpao.activity_id=bpaa.activity_id
    AND trim(bpao.order_type)="DRUG_CLASS:Long-acting benzodiazepines"
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SET tmp_message = build2(trim(tmp_message,3),
    " Provider cancelled long acting benzo order within 30min")
   UPDATE  FROM bhs_pim_alert_activity bpaa
    SET bpaa.override_reason_cd = - (4)
    WHERE bpaa.activity_id=newid
   ;end update
   COMMIT
   GO TO exit_script
  ENDIF
 ENDIF
 SET tmp_retval = 100
#exit_script
 SET retval = tmp_retval
 SET log_message = build2(trim(tmp_message,3)," Exiting Script")
 CALL echo(log_message)
 CALL echo(" ")
 CALL echo(log_misc1)
END GO
