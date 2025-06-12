CREATE PROGRAM bhs_gvw_pat_ed_title:dba
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
 DECLARE mf_enc_id = f8 WITH protect, noconstant(0.00)
 SET mf_enc_id = request->visit[1].encntr_id
 SELECT INTO "nl:"
  FROM pat_ed_document ped,
   pat_ed_doc_activity peda
  PLAN (ped
   WHERE ped.encntr_id=mf_enc_id)
   JOIN (peda
   WHERE peda.pat_ed_doc_id=ped.pat_ed_document_id)
  ORDER BY peda.instruction_name
  HEAD REPORT
   reply->text = ms_rhead
  HEAD peda.instruction_name
   reply->text = concat(reply->text," {",trim(peda.instruction_name,3),"}",ms_reol)
  FOOT REPORT
   reply->text = concat(reply->text,ms_rtfeof)
  WITH nullreport, nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
