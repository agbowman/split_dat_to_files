CREATE PROGRAM bhs_gvw_diet_order:dba
 DECLARE mf_diets_acttypecd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!13825"))
 DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_order_action = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\plain \f0 \fs18 ")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_reop = vc WITH protect, constant("\pard ")
 DECLARE ms_rh2r = vc WITH protect, constant("\pard\plain\f0\fs18 ")
 DECLARE ms_rh2b = vc WITH protect, constant("\pard\plain\f0\fs18\b ")
 DECLARE ms_rh2bu = vc WITH protect, constant("\pard\plain\f0\fs18\b\ul ")
 DECLARE ms_rh2u = vc WITH protect, constant("\pard\plain\f0\fs18\u ")
 DECLARE ms_rh2i = vc WITH protect, constant("\pard\plain\f0\fs18\i ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_rbopt = vc WITH protect, constant(
  "\pard \tx1200\tx1900\tx2650\tx3325\tx3800\tx4400\tx5050\tx5750\tx6500 ")
 DECLARE ms_wr = vc WITH protect, constant("\plain\f0\fs18 ")
 DECLARE ms_wb = vc WITH protect, constant("\plain\f0\fs18\b ")
 DECLARE ms_wu = vc WITH protect, constant("\plain\f0\fs18 \ul\b ")
 DECLARE ms_wbi = vc WITH protect, constant("\plain\f0\fs18\b\i ")
 DECLARE ms_ws = vc WITH protect, constant("\plain\f0\fs18\strike ")
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-2340\li2340 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE ms_order_name = vc WITH protect, noconstant(" ")
 DECLARE ms_order_details = vc WITH protect, noconstant(" ")
 CALL echo(build2("request->visit[1].encntr_id: ",request->visit[1].encntr_id))
 SELECT INTO "nl:"
  FROM orders o,
   dummyt d1,
   order_detail od,
   oe_format_fields oeff
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.activity_type_cd=mf_diets_acttypecd
    AND o.order_status_cd=mf_ordered)
   JOIN (d1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence IN (
   (SELECT
    max(od0.action_sequence)
    FROM order_detail od0
    WHERE od0.order_id=od.order_id
     AND od0.oe_field_id=od.oe_field_id)))
   JOIN (oeff
   WHERE oeff.oe_field_id=od.oe_field_id
    AND oeff.oe_format_id=o.oe_format_id
    AND oeff.action_type_cd=mf_order_action
    AND oeff.label_text IN ("Dietary Modifiers", "CHO Restriction", "Calorie Modified Diet",
   "Clear Liquid Diet", "Diabetic Diet-Adult",
   "Diabetic Diet-Pedi/Adol", "Pedi Eating Disorder", "Progress Diet", "Diabetic Diet-Pregnancy",
   "Allowable Food Items",
   "Other Food Item", "Calorie Restriction", "Potassium Restriction", "Protein Restriction",
   "Phosphorus Restriction",
   "Sodium Restriction", "Fluid Restriction", "Thickening Instructions", "NPO Exceptions"))
  ORDER BY o.orig_order_dt_tm DESC, o.order_id, oeff.label_text
  HEAD REPORT
   reply->text = ms_rhead, ms_order_name = " "
  HEAD o.orig_order_dt_tm
   null
  HEAD o.order_id
   ms_order_name = trim(o.order_mnemonic,3), ms_order_details = " "
  HEAD oeff.label_text
   IF (ms_order_details=" ")
    IF (oeff.clin_line_label > " ")
     ms_order_details = concat(trim(oeff.clin_line_label,3)," ",trim(od.oe_field_display_value,3))
    ELSE
     ms_order_details = trim(od.oe_field_display_value,3)
    ENDIF
   ELSE
    IF (oeff.clin_line_label > " ")
     ms_order_details = concat(ms_order_details,"; ",trim(oeff.clin_line_label,3)," ",trim(od
       .oe_field_display_value,3))
    ELSE
     ms_order_details = concat(ms_order_details,"; ",trim(od.oe_field_display_value,3))
    ENDIF
   ENDIF
   CALL echo(build2("od.oe_field_display_value: ",od.oe_field_display_value)),
   CALL echo(build2("ms_order_details: ",ms_order_details))
  FOOT  o.order_id
   reply->text = concat(reply->text,ms_wr,"{",ms_order_name,"}")
   IF (ms_order_details > " ")
    reply->text = concat(reply->text,ms_wr,"{: ",trim(ms_order_details,3),"} ")
   ENDIF
  FOOT REPORT
   reply->text = concat(reply->text,ms_rtfeof)
  WITH outerjoin = d1, nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echo(reply->text)
END GO
