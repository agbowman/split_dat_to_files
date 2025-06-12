CREATE PROGRAM aps_chk_ccprovider_update_reqd:dba
 RECORD reply(
   1 update_cc_provider_for_rpt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE order_action_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_action_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",6003,"MODIFY")
  )
 DECLARE renew_action_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",6003,"RENEW"))
 DECLARE report_order_id = f8 WITH protect, noconstant(0)
 DECLARE cat_type_cd = f8 WITH protect, noconstant(0)
 DECLARE oe_fmt_id = f8 WITH protect, noconstant(0)
 DECLARE consult_doc_exist_on_rpt = i2 WITH protect, noconstant(0)
 DECLARE cc_provider_exist_on_rpt = i2 WITH protect, noconstant(0)
 DECLARE has_cc_provider_in_format = i2 WITH protect, noconstant(0)
 IF (((order_action_type_cd=0) OR (((modify_action_type_cd=0) OR (renew_action_type_cd=0)) )) )
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  rt.report_id, rt.order_id
  FROM report_task rt,
   orders o
  PLAN (rt
   WHERE (rt.report_id=request->report_id))
   JOIN (o
   WHERE rt.order_id=o.order_id)
  DETAIL
   report_order_id = rt.order_id, cat_type_cd = o.catalog_type_cd, oe_fmt_id = o.oe_format_id
  WITH nocounter
 ;end select
 IF (report_order_id=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_TASK"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  oef.oe_field_id, oef.oe_field_meaning_id, oefm.oe_field_meaning,
  oeff_action_type_disp = uar_get_code_display(oeff.action_type_cd), oef.catalog_type_cd
  FROM oe_field_meaning oefm,
   order_entry_fields oef,
   oe_format_fields oeff
  PLAN (oefm
   WHERE oefm.oe_field_meaning="CCPROVIDER")
   JOIN (oef
   WHERE oef.oe_field_meaning_id=oefm.oe_field_meaning_id
    AND oef.catalog_type_cd IN (0, cat_type_cd))
   JOIN (oeff
   WHERE oeff.oe_format_id=oe_fmt_id
    AND oeff.action_type_cd=order_action_type_cd
    AND oeff.oe_field_id=oef.oe_field_id)
  DETAIL
   IF (oef.oe_field_id > 0)
    has_cc_provider_in_format = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (has_cc_provider_in_format=1)
  SELECT INTO "NL:"
   od.oe_field_id, od.action_sequence
   FROM order_action oa,
    order_detail od
   PLAN (oa
    WHERE oa.order_id=report_order_id
     AND ((oa.action_type_cd=order_action_type_cd) OR (((oa.action_type_cd=modify_action_type_cd) OR
    (oa.action_type_cd=renew_action_type_cd)) ))
     AND oa.action_rejected_ind=0)
    JOIN (od
    WHERE od.order_id=oa.order_id
     AND od.action_sequence=oa.action_sequence
     AND ((od.oe_field_meaning="CONSULTDOC") OR (od.oe_field_meaning="CCPROVIDER")) )
   ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
   HEAD od.order_id
    consult_doc_exist_on_rpt = 0, cc_provider_exist_on_rpt = 0
   HEAD od.oe_field_id
    IF (od.oe_field_meaning="CONSULTDOC")
     consult_doc_exist_on_rpt = 1
    ELSEIF (od.oe_field_meaning="CCPROVIDER")
     cc_provider_exist_on_rpt = 1
    ENDIF
   FOOT  od.order_id
    IF (consult_doc_exist_on_rpt=1
     AND cc_provider_exist_on_rpt=0)
     reply->update_cc_provider_for_rpt = 1
    ELSE
     reply->update_cc_provider_for_rpt = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
