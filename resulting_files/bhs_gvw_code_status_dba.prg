CREATE PROGRAM bhs_gvw_code_status:dba
 DECLARE mf_codestatus_acttypecd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "CODESTATUS"))
 DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
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
  odl_ind = decode(odl.order_id,1,0)
  FROM orders o,
   dummyt dl,
   order_detail odl,
   oe_format_fields oefl
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.activity_type_cd=mf_codestatus_acttypecd
    AND o.order_status_cd=mf_ordered)
   JOIN (dl)
   JOIN (odl
   WHERE odl.order_id=o.order_id
    AND odl.oe_field_meaning="OTHER"
    AND odl.action_sequence IN (
   (SELECT
    max(odl0.action_sequence)
    FROM order_detail odl0
    WHERE odl0.order_id=odl.order_id
     AND odl0.oe_field_id=odl.oe_field_id)))
   JOIN (oefl
   WHERE oefl.oe_format_id=o.oe_format_id
    AND oefl.oe_field_id=odl.oe_field_id
    AND oefl.label_text="Limitations"
    AND oefl.action_type_cd=2534.00)
  ORDER BY o.orig_order_dt_tm DESC, o.order_id
  HEAD REPORT
   reply->text = ms_rhead
  HEAD o.orig_order_dt_tm
   null
  HEAD o.order_id
   ms_order_name = trim(o.order_mnemonic,3)
   IF (odl_ind=1)
    ms_order_details = trim(odl.oe_field_display_value,3), reply->text = concat(reply->text,ms_wr,"{",
     trim(ms_order_name,3),": } ",
     ms_wr,"{",trim(ms_order_details,3),"} ")
   ELSE
    reply->text = concat(reply->text,ms_wr,"{",trim(ms_order_name,3),"} ")
   ENDIF
  FOOT REPORT
   reply->text = concat(reply->text,ms_rtfeof)
  WITH outerjoin = dl, nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
