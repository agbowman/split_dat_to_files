CREATE PROGRAM cps_get_meds:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 person_org_sec_on = i2
   1 med_list_knt = i4
   1 med_list[*]
     2 order_id = f8
     2 encntr_id = f8
     2 organization_id = f8
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 cki = vc
     2 source_vocab_mean = vc
     2 source_identifier = vc
     2 description = vc
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 clinical_display_line = vc
     2 ordered_as_mnemonic = vc
     2 orig_ord_as_flag = i4
   1 adr_knt = i4
   1 adr[*]
     2 activity_data_reltn_id = f8
     2 person_id = f8
     2 activity_entity_name = vc
     2 activity_entity_id = f8
     2 activity_entity_inst_id = f8
     2 reltn_entity_name = vc
     2 reltn_entity_id = f8
     2 reltn_entity_all_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE ordered_cd = f8 WITH public, noconstant(0.0)
 DECLARE suspended_cd = f8 WITH public, noconstant(0.0)
 DECLARE disc_cd = f8 WITH public, noconstant(0.0)
 DECLARE completed_cd = f8 WITH public, noconstant(0.0)
 DECLARE voidedwrslt_cd = f8 WITH public, noconstant(0.0)
 DECLARE pending_cd = f8 WITH public, noconstant(0.0)
 DECLARE pharm_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE odschemaexists = i2 WITH public, noconstant(0)
 DECLARE knt = i4 WITH public, noconstant(0)
 DECLARE iadrschemaexist = i2 WITH public, constant(checkdic("ACTIVITY_DATA_RELTN","T",0))
 DECLARE idx = i4 WITH noconstant(0), public
 DECLARE i_pos = i4 WITH noconstant(0), public
 DECLARE dminfo_ok = i2 WITH private, noconstant(false)
 DECLARE iprescriptionorderid = i2 WITH public, noconstant(checkdic("ORDERS.PRESCRIPTION_ORDER_ID",
   "A",0))
 IF (iadrschemaexist < 1)
  GO TO skip_person_org_chk
 ENDIF
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  IF ((ccldminfo->sec_org_reltn=1)
   AND (ccldminfo->person_org_sec=1))
   SET reply->person_org_sec_on = true
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "PERSON_ORG_SEC")
     AND di.info_number=1)
   HEAD REPORT
    encntr_org_sec_on = 0, person_org_sec_on = 0
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_on = 1
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     person_org_sec_on = 1
    ENDIF
   FOOT REPORT
    IF (person_org_sec_on=1
     AND encntr_org_sec_on=1)
     reply->person_org_sec_on = true
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "DM_INFO"
   GO TO exit_script
  ENDIF
 ENDIF
#skip_person_org_chk
 CALL echo("checking to see if parent_order_id exists on Order Dispense")
 SELECT INTO "NL:"
  c.column_name
  FROM dba_tab_columns c
  WHERE c.table_name="ORDER_DISPENSE"
   AND c.column_name="PARENT_ORDER_ID"
   AND c.owner="V500"
  DETAIL
   odschemaexists = 1,
   CALL echo("Order Dispense Parent_order_id Schema Exists")
  WITH check
 ;end select
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ordered_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "SUSPENDED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,suspended_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "DISCONTINUED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,disc_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "COMPLETED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,completed_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "VOIDEDWRSLT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,voidedwrslt_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "PENDING"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pending_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pharm_type_cd)
 IF (stat != 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 FREE RECORD stat_list
 RECORD stat_list(
   1 qual_knt = i4
   1 qual[4]
     2 cd = f8
 )
 SET stat_list->qual_knt = 4
 SET stat_list->qual[1].cd = disc_cd
 SET stat_list->qual[2].cd = completed_cd
 SET stat_list->qual[3].cd = voidedwrslt_cd
 SET stat_list->qual[4].cd = pending_cd
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF (iprescriptionorderid != 0)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd=ordered_cd
     AND ((o.catalog_type_cd+ 0)=pharm_type_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11))
     AND o.prescription_order_id=0)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ELSEIF (odschemaexists=1)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd=ordered_cd
     AND ((o.catalog_type_cd+ 0)=pharm_type_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11, 13))
     AND  NOT ( EXISTS (
    (SELECT
     o2.person_id
     FROM order_dispense od2,
      orders o2
     WHERE o.order_id=od2.order_id
      AND od2.parent_order_id=o2.order_id
      AND o2.person_id=o.person_id))))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ELSE
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd=ordered_cd
     AND ((o.catalog_type_cd+ 0)=pharm_type_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11, 13)))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ENDIF
  INTO "nl:"
  o.order_id
  FROM orders o,
   encounter e,
   order_catalog oc,
   order_ingredient oi
  HEAD REPORT
   knt = 0, stat = alterlist(reply->med_list,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->med_list,(knt+ 9))
   ENDIF
   reply->med_list[knt].order_status_cd = o.order_status_cd, reply->med_list[knt].catalog_cd = oc
   .catalog_cd, reply->med_list[knt].source_vocab_mean = trim(substring(1,(findstring("!",oc.cki) - 1
     ),oc.cki)),
   reply->med_list[knt].source_identifier = trim(substring((findstring("!",oc.cki)+ 1),textlen(trim(
       oc.cki)),oc.cki)), reply->med_list[knt].cki = oc.cki, reply->med_list[knt].order_id = o
   .order_id,
   reply->med_list[knt].encntr_id = e.encntr_id, reply->med_list[knt].organization_id = e
   .organization_id, reply->med_list[knt].primary_mnemonic = o.ordered_as_mnemonic,
   reply->med_list[knt].clinical_display_line = o.clinical_display_line, reply->med_list[knt].
   hna_order_mnemonic = o.hna_order_mnemonic, reply->med_list[knt].order_mnemonic = o.order_mnemonic,
   reply->med_list[knt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->med_list[knt].
   orig_ord_as_flag = o.orig_ord_as_flag
  FOOT REPORT
   reply->med_list_knt = knt, stat = alterlist(reply->med_list,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ORDERED_ORDERS"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF (iprescriptionorderid != 0)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd=suspended_cd
     AND ((o.catalog_type_cd+ 0)=pharm_type_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11))
     AND o.prescription_order_id=0)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (((request->dc_intr_days_flag=2)
     AND o.orig_ord_as_flag IN (1, 2)
     AND ((oc.op_dc_interaction_days >= 0
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.op_dc_interaction_days)))
     OR (oc.op_dc_interaction_days < 0
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days)))) )
     OR ((((request->dc_intr_days_flag=2)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))) OR ((request->dc_intr_days_flag != 2)))
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days))))
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ELSEIF (odschemaexists=1)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd=suspended_cd
     AND ((o.catalog_type_cd+ 0)=pharm_type_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11, 13))
     AND  NOT ( EXISTS (
    (SELECT
     o2.person_id
     FROM order_dispense od2,
      orders o2
     WHERE o.order_id=od2.order_id
      AND od2.parent_order_id=o2.order_id
      AND o2.person_id=o.person_id))))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (((request->dc_intr_days_flag=2)
     AND o.orig_ord_as_flag IN (1, 2)
     AND ((oc.op_dc_interaction_days >= 0
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.op_dc_interaction_days)))
     OR (oc.op_dc_interaction_days < 0
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days)))) )
     OR ((((request->dc_intr_days_flag=2)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))) OR ((request->dc_intr_days_flag != 2)))
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days))))
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ELSE
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.order_status_cd=suspended_cd
     AND ((o.catalog_type_cd+ 0)=pharm_type_cd)
     AND o.template_order_flag IN (0, 1)
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11, 13)))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (((request->dc_intr_days_flag=2)
     AND o.orig_ord_as_flag IN (1, 2)
     AND ((oc.op_dc_interaction_days >= 0
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.op_dc_interaction_days)))
     OR (oc.op_dc_interaction_days < 0
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days)))) )
     OR ((((request->dc_intr_days_flag=2)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))) OR ((request->dc_intr_days_flag != 2)))
     AND (o.suspend_effective_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days))))
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ENDIF
  INTO "nl:"
  o.order_id
  FROM orders o,
   encounter e,
   order_catalog oc,
   order_ingredient oi
  HEAD REPORT
   knt = knt, stat = alterlist(reply->med_list,(knt+ 10))
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->med_list,(knt+ 9))
   ENDIF
   reply->med_list[knt].order_status_cd = o.order_status_cd, reply->med_list[knt].catalog_cd = oc
   .catalog_cd, reply->med_list[knt].source_vocab_mean = trim(substring(1,(findstring("!",oc.cki) - 1
     ),oc.cki)),
   reply->med_list[knt].source_identifier = trim(substring((findstring("!",oc.cki)+ 1),textlen(trim(
       oc.cki)),oc.cki)), reply->med_list[knt].cki = oc.cki, reply->med_list[knt].order_id = o
   .order_id,
   reply->med_list[knt].encntr_id = e.encntr_id, reply->med_list[knt].organization_id = e
   .organization_id, reply->med_list[knt].primary_mnemonic = o.ordered_as_mnemonic,
   reply->med_list[knt].clinical_display_line = o.clinical_display_line, reply->med_list[knt].
   hna_order_mnemonic = o.hna_order_mnemonic, reply->med_list[knt].order_mnemonic = o.order_mnemonic,
   reply->med_list[knt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->med_list[knt].
   orig_ord_as_flag = o.orig_ord_as_flag
  FOOT REPORT
   reply->med_list_knt = knt, stat = alterlist(reply->med_list,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "SUSPENDED_ORDERS"
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT
  IF (iprescriptionorderid != 0)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.catalog_type_cd=pharm_type_cd
     AND expand(idx,1,stat_list->qual_knt,(o.order_status_cd+ 0),stat_list->qual[idx].cd)
     AND ((o.template_order_flag+ 0) IN (0, 1))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11))
     AND o.prescription_order_id=0)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (((request->dc_intr_days_flag=2)
     AND o.orig_ord_as_flag IN (1, 2)
     AND ((oc.op_dc_interaction_days >= 0
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.op_dc_interaction_days)))
     OR (oc.op_dc_interaction_days < 0
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days)))) )
     OR ((((request->dc_intr_days_flag=2)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))) OR ((request->dc_intr_days_flag != 2)))
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days))))
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ELSEIF (odschemaexists=1)
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.catalog_type_cd=pharm_type_cd
     AND expand(idx,1,stat_list->qual_knt,(o.order_status_cd+ 0),stat_list->qual[idx].cd)
     AND ((o.template_order_flag+ 0) IN (0, 1))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11, 13))
     AND  NOT ( EXISTS (
    (SELECT
     o2.person_id
     FROM order_dispense od2,
      orders o2
     WHERE o.order_id=od2.order_id
      AND od2.parent_order_id=o2.order_id
      AND o2.person_id=o.person_id))))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (((request->dc_intr_days_flag=2)
     AND o.orig_ord_as_flag IN (1, 2)
     AND ((oc.op_dc_interaction_days >= 0
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.op_dc_interaction_days)))
     OR (oc.op_dc_interaction_days < 0
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days)))) )
     OR ((((request->dc_intr_days_flag=2)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))) OR ((request->dc_intr_days_flag != 2)))
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days))))
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ELSE
   PLAN (o
    WHERE (o.person_id=request->person_id)
     AND o.catalog_type_cd=pharm_type_cd
     AND expand(idx,1,stat_list->qual_knt,(o.order_status_cd+ 0),stat_list->qual[idx].cd)
     AND ((o.template_order_flag+ 0) IN (0, 1))
     AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 11, 13)))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND oi.action_sequence=o.last_ingred_action_sequence)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (((request->dc_intr_days_flag=2)
     AND o.orig_ord_as_flag IN (1, 2)
     AND ((oc.op_dc_interaction_days >= 0
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.op_dc_interaction_days)))
     OR (oc.op_dc_interaction_days < 0
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days)))) )
     OR ((((request->dc_intr_days_flag=2)
     AND  NOT (o.orig_ord_as_flag IN (1, 2))) OR ((request->dc_intr_days_flag != 2)))
     AND (o.projected_stop_dt_tm >= (cnvtdatetime(curdate,curtime3) - oc.dc_interaction_days))))
     AND ((oc.cki=patstring("MUL.ORD!*")) OR (((oc.cki=patstring("MUL.MMDC!*")) OR (oc.cki=patstring(
     "GDDB.ACG*"))) )) )
  ENDIF
  INTO "nl:"
  o.order_id
  FROM orders o,
   encounter e,
   order_catalog oc,
   order_ingredient oi
  HEAD REPORT
   knt = knt, stat = alterlist(reply->med_list,(knt+ 10))
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->med_list,(knt+ 9))
   ENDIF
   reply->med_list[knt].order_status_cd = o.order_status_cd, reply->med_list[knt].catalog_cd = oc
   .catalog_cd, reply->med_list[knt].source_vocab_mean = trim(substring(1,(findstring("!",oc.cki) - 1
     ),oc.cki)),
   reply->med_list[knt].source_identifier = trim(substring((findstring("!",oc.cki)+ 1),textlen(trim(
       oc.cki)),oc.cki)), reply->med_list[knt].cki = oc.cki, reply->med_list[knt].order_id = o
   .order_id,
   reply->med_list[knt].encntr_id = e.encntr_id, reply->med_list[knt].organization_id = e
   .organization_id, reply->med_list[knt].primary_mnemonic = o.ordered_as_mnemonic,
   reply->med_list[knt].clinical_display_line = o.clinical_display_line, reply->med_list[knt].
   hna_order_mnemonic = o.hna_order_mnemonic, reply->med_list[knt].order_mnemonic = o.order_mnemonic,
   reply->med_list[knt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->med_list[knt].
   orig_ord_as_flag = o.orig_ord_as_flag
  FOOT REPORT
   reply->med_list_knt = knt, stat = alterlist(reply->med_list,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "INACTIVE_ORDERS"
  GO TO exit_script
 ENDIF
 IF ((reply->person_org_sec_on=true))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM activity_data_reltn adr
   PLAN (adr
    WHERE expand(idx,1,reply->med_list_knt,adr.activity_entity_id,reply->med_list[idx].order_id)
     AND adr.activity_entity_name="ORDERS")
   HEAD REPORT
    knt = 0, stat = alterlist(reply->adr,10)
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->adr,(knt+ 9))
    ENDIF
    reply->adr[knt].activity_data_reltn_id = adr.activity_data_reltn_id, reply->adr[knt].person_id =
    request->person_id, reply->adr[knt].activity_entity_name = adr.activity_entity_name,
    reply->adr[knt].activity_entity_id = adr.activity_entity_id, reply->adr[knt].
    activity_entity_inst_id = adr.activity_entity_inst_id, reply->adr[knt].reltn_entity_name = adr
    .reltn_entity_name,
    reply->adr[knt].reltn_entity_id = adr.reltn_entity_id, reply->adr[knt].reltn_entity_all_ind = adr
    .reltn_entity_all_ind
   FOOT REPORT
    reply->adr_knt = knt, stat = alterlist(reply->adr,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "ACTIVITY_DATA_RELTN"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->med_list_knt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "MOD 030 JT018805 02/03/10"
END GO
