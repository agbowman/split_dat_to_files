CREATE PROGRAM bhs_gvw_ed_dc_order_prov:dba
 DECLARE mf_discharge_ord = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"DISCHARGE"))
 DECLARE mf_dischargeexpired_ord = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DISCHARGEEXPIRED"))
 DECLARE mf_dischargepatientedorder_ord = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "DISCHARGEPATIENTEDORDER"))
 DECLARE mf_order_act = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE mf_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE ms_rhead = vc WITH protect, constant(
  "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}}\deftab750\plain \f0 \fs18 ")
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
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-1050\li1050 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE ms_text = vc
 SELECT INTO "nl:"
  FROM encounter e,
   orders o,
   order_action oa,
   prsnl pr
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd IN (mf_discharge_ord, mf_dischargeexpired_ord, mf_dischargepatientedorder_ord)
    AND o.order_status_cd=mf_ordered)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_order_act)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
  ORDER BY o.order_id DESC
  HEAD REPORT
   reply->text = concat(ms_rhead,"{",trim(pr.name_full_formatted),"}",ms_rtfeof)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
