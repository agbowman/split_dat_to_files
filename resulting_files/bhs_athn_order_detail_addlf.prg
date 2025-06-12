CREATE PROGRAM bhs_athn_order_detail_addlf
 DECLARE action_type_cd_activate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ACTIVATE"))
 DECLARE action_type_cd_collection = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COLLECTION")
  )
 DECLARE action_type_cd_modify = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"MODIFY"))
 DECLARE action_type_cd_order = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE action_type_cd_renew = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"RENEW"))
 DECLARE action_type_cd_resumerenew = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,
   "RESUMERENEW"))
 FREE RECORD out_rec
 RECORD out_rec(
   1 actual_dose = vc
   1 target_dose = vc
   1 proposal_status_disp = vc
   1 pathway_plan = vc
   1 dx_string = vc
   1 iv_set_synonym_id = vc
   1 iv_set_catalog_cd = vc
   1 iv_set_orderable_type_flag = vc
   1 reftask_id = vc
   1 original_order_communication_type_cd = vc
   1 original_order_communication_type_mean = vc
   1 original_order_communication_type_disp = vc
   1 iv_indicator = i2
   1 ingredient_display = vc
   1 reporting_priority_cd = vc
   1 reporting_priority_disp = vc
   1 reporting_priority_mean = vc
   1 collection_priority_cd = vc
   1 collection_priority_disp = vc
   1 collection_priority_mean = vc
 )
 IF (( $2 > 0))
  SELECT INTO "NL:"
   FROM order_ingredient o,
    order_action oa,
    orders os,
    long_text lt,
    pathway_catalog p,
    order_catalog_synonym ocs,
    task_activity t,
    order_radiology orr,
    order_laboratory ol
   PLAN (os
    WHERE os.order_id=cnvtreal( $2))
    JOIN (oa
    WHERE oa.order_id=os.order_id
     AND oa.action_type_cd IN (action_type_cd_activate, action_type_cd_collection,
    action_type_cd_modify, action_type_cd_order, action_type_cd_renew,
    action_type_cd_resumerenew))
    JOIN (o
    WHERE (o.order_id= Outerjoin(oa.order_id))
     AND (o.action_sequence= Outerjoin(oa.action_sequence)) )
    JOIN (lt
    WHERE (lt.long_text_id= Outerjoin(o.dose_calculator_long_text_id)) )
    JOIN (p
    WHERE (p.pathway_catalog_id= Outerjoin(os.pathway_catalog_id)) )
    JOIN (ocs
    WHERE (ocs.synonym_id= Outerjoin(os.iv_set_synonym_id))
     AND (ocs.synonym_id!= Outerjoin(0)) )
    JOIN (t
    WHERE (t.order_id= Outerjoin(os.order_id)) )
    JOIN (ol
    WHERE (ol.order_id= Outerjoin(os.order_id)) )
    JOIN (orr
    WHERE (orr.order_id= Outerjoin(os.order_id)) )
   HEAD REPORT
    targetdosex = findstring("<TargetDose",lt.long_text), targetdosey = findstring(">",lt.long_text,
     targetdosex), targetdosez = findstring("</TargetDose",lt.long_text),
    target_dose1 = substring((targetdosey+ 1),(targetdosez - (targetdosey+ 1)),lt.long_text),
    targetdoseunitx = findstring("<TargetDoseUnitDisp",lt.long_text), targetdoseunity = findstring(
     ">",lt.long_text,targetdoseunitx),
    targetdoseunitz = findstring("</TargetDoseUnitDisp",lt.long_text), target_dose_unit = substring((
     targetdoseunity+ 1),(targetdoseunitz - (targetdoseunity+ 1)),lt.long_text), actualdosex =
    findstring("<ActualFinalDose",lt.long_text),
    actualdosey = findstring(">",lt.long_text,actualdosex), actualdosez = findstring(
     "</ActualFinalDose",lt.long_text), actual_dose1 = substring((actualdosey+ 1),(actualdosez - (
     actualdosey+ 1)),lt.long_text),
    actualdoseunitx = findstring("<ActualFinalDoseUnitDisp",lt.long_text), actualdoseunity =
    findstring(">",lt.long_text,actualdoseunitx), actualdoseunitz = findstring(
     "</ActualFinalDoseUnitDisp",lt.long_text),
    actual_dose_unit = substring((actualdoseunity+ 1),(actualdoseunitz - (actualdoseunity+ 1)),lt
     .long_text)
    IF (target_dose1 != " ")
     out_rec->target_dose = build(target_dose1,"|",target_dose_unit)
    ENDIF
    IF (actual_dose1 != " ")
     out_rec->actual_dose = trim(build(actual_dose1,"|",actual_dose_unit),3)
    ENDIF
    out_rec->pathway_plan = p.description, out_rec->iv_set_synonym_id = cnvtstring(os
     .iv_set_synonym_id), out_rec->iv_set_catalog_cd = cnvtstring(ocs.catalog_cd),
    out_rec->iv_set_orderable_type_flag = cnvtstring(ocs.orderable_type_flag), out_rec->reftask_id =
    cnvtstring(t.reference_task_id), out_rec->original_order_communication_type_cd = cnvtstring(os
     .latest_communication_type_cd),
    out_rec->original_order_communication_type_disp = uar_get_code_display(os
     .latest_communication_type_cd), out_rec->original_order_communication_type_mean =
    uar_get_code_meaning(os.latest_communication_type_cd)
    IF (os.dcp_clin_cat_cd=10577)
     out_rec->iv_indicator = os.iv_ind, out_rec->ingredient_display = "1"
    ENDIF
    IF (os.dcp_clin_cat_cd=10576)
     out_rec->reporting_priority_cd = cnvtstring(ol.report_priority_cd), out_rec->
     reporting_priority_disp = uar_get_code_display(ol.report_priority_cd), out_rec->
     reporting_priority_mean = uar_get_code_meaning(ol.report_priority_cd),
     out_rec->collection_priority_cd = cnvtstring(ol.collection_priority_cd), out_rec->
     collection_priority_disp = uar_get_code_display(ol.collection_priority_cd), out_rec->
     collection_priority_mean = uar_get_code_meaning(ol.collection_priority_cd)
    ENDIF
    IF (os.dcp_clin_cat_cd=10573)
     out_rec->reporting_priority_cd = cnvtstring(orr.priority_cd), out_rec->reporting_priority_disp
      = uar_get_code_display(orr.priority_cd), out_rec->reporting_priority_mean =
     uar_get_code_meaning(orr.priority_cd)
    ENDIF
   WITH time = 20
  ;end select
  SELECT INTO "nl:"
   FROM order_proposal op
   PLAN (op
    WHERE (op.order_id= $2))
   HEAD REPORT
    out_rec->proposal_status_disp = uar_get_code_display(op.proposal_status_cd)
   WITH time = 5
  ;end select
  DECLARE dx_str = vc
  SELECT INTO "nl:"
   n.source_identifier, n.source_string, n.nomenclature_id,
   d.entity1_id, rank = trim(cnvtstring(d.rank_sequence))
   FROM dcp_entity_reltn d,
    diagnosis dx,
    nomenclature n
   PLAN (d
    WHERE d.entity1_id=cnvtreal( $2)
     AND d.entity_reltn_mean="ORDERS/DIAGN")
    JOIN (dx
    WHERE dx.diagnosis_id=d.entity2_id)
    JOIN (n
    WHERE n.nomenclature_id=dx.nomenclature_id)
   ORDER BY d.entity1_id
   HEAD d.entity1_id
    dx_str = " "
   DETAIL
    IF (d.entity2_id != 0)
     dx_str = concat(dx_str,trim(cnvtstring(d.entity2_id),3),"|",trim(n.source_identifier,3),"|",
      trim(d.entity2_display,3),"|",trim(rank),"||")
    ENDIF
   FOOT  d.entity1_id
    out_rec->dx_string = dx_str
   WITH nocounter, time = 20
  ;end select
 ENDIF
 SET _memory_reply_string = cnvtrectojson(out_rec)
END GO
