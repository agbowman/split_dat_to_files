CREATE PROGRAM bhs_gvw_curr_user_full_name:dba
 DECLARE mf_prsnlnametype = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
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
 SELECT INTO "nl:"
  FROM prsnl pr,
   person_name pn
  PLAN (pr
   WHERE (pr.person_id=reqinfo->updt_id))
   JOIN (pn
   WHERE pn.person_id=pr.person_id
    AND pn.name_type_cd=mf_prsnlnametype
    AND pn.active_ind=1
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   reply->text = concat(ms_rhead,"{",trim(pr.name_first,3)," ",trim(substring(1,1,pn.name_middle),3),
    " ",trim(pr.name_last,3),"}")
   IF (pn.name_suffix > " ")
    reply->text = concat(reply->text,"{, ",trim(pn.name_suffix,3),"}")
   ENDIF
   reply->text = concat(reply->text,ms_reol,ms_rtfeof)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
