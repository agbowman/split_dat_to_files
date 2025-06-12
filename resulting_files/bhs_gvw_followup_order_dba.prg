CREATE PROGRAM bhs_gvw_followup_order:dba
 DECLARE mf_followup_catcd = f8 WITH protect, constant(uar_get_code_by("DISPLAY",200,
   "Follow Up Appointment"))
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
 CALL echo(build2("request->visit[1].encntr_id: ",request->visit[1].encntr_id))
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND o.catalog_cd=mf_followup_catcd
    AND o.order_status_cd=mf_ordered)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="SPECINX"
    AND od.action_sequence IN (
   (SELECT
    max(od0.action_sequence)
    FROM order_detail od0
    WHERE od0.order_id=od.order_id
     AND od0.oe_field_id=od.oe_field_id)))
  ORDER BY o.orig_order_dt_tm DESC, o.order_id
  HEAD REPORT
   reply->text = ms_rhead
  HEAD o.orig_order_dt_tm
   null
  HEAD o.order_id
   reply->text = concat(reply->text,ms_wb,"{",trim(o.order_mnemonic,3),"} ",
    ms_reol,ms_wr,"{",trim(o.clinical_display_line,3),"} "), reply->text = concat(reply->text,ms_reol,
    ms_reol)
  FOOT REPORT
   reply->text = concat(reply->text,ms_rtfeof)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
