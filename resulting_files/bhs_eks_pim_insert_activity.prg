CREATE PROGRAM bhs_eks_pim_insert_activity
 DECLARE newid = f8
 DECLARE drug_class = i4
 DECLARE drugclass = vc
 SET retval = 0
 SELECT INTO "nl:"
  nextid = seq(bhs_pim_alert_activity_seq,nextval)
  FROM dual
  DETAIL
   newid = nextid
  WITH nocounter
 ;end select
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
 IF (validate(pim_drugs->drug_class_cnt,0)=0)
  EXECUTE bhs_pim_drug_lists
 ENDIF
 SET drugclass = " "
 FOR (x1 = 1 TO pim_drugs->drug_class_cnt)
   FOR (x2 = 1 TO pim_drugs->drug_classes[x1].drug_cnt)
     IF (trim(drugclass,4) <= " "
      AND (pim_drugs->drug_classes[x1].drugs[x2].catalog_cd=request->orderlist[event_repeat_index].
     catalog_code))
      SET drugclass = build2("DRUG_CLASS:",pim_drugs->drug_classes[x1].drug_class)
     ENDIF
   ENDFOR
 ENDFOR
 INSERT  FROM bhs_pim_assoc_orders
  SET activity_id = newid, order_id = request->orderlist[event_repeat_index].catalog_code, order_type
    = drugclass,
   active_ind = 1
  WITH nocounter
 ;end insert
 INSERT  FROM bhs_pim_provider_override
  (activity_id, prsnl_id, override_desc,
  create_dt_tm, active_ind)
  VALUES(newid, reqinfo->updt_id, "trigger_prsnlid",
  sysdate, 1)
 ;end insert
 COMMIT
 SET retval = 100
END GO
