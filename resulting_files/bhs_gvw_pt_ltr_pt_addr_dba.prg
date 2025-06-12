CREATE PROGRAM bhs_gvw_pt_ltr_pt_addr:dba
 DECLARE mf_home_add_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
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
 DECLARE ms_street_addr = vc
 DECLARE ms_city_state_zip = vc
 SELECT INTO "nl:"
  FROM person p,
   address a
  PLAN (p
   WHERE (p.person_id=request->person[1].person_id))
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.address_type_cd=mf_home_add_cd
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
  ORDER BY a.address_type_seq
  HEAD REPORT
   ms_street_addr = concat("{",trim(a.street_addr),"}")
   IF (a.street_addr2 > " ")
    ms_street_addr = concat(ms_street_addr,ms_reol,"{",trim(a.street_addr2),"}")
   ENDIF
   IF (a.street_addr3 > " ")
    ms_street_addr = concat(ms_street_addr,ms_reol,"{",trim(a.street_addr3),"}")
   ENDIF
   IF (a.street_addr4 > " ")
    ms_street_addr = concat(ms_street_addr,ms_reol,"{",trim(a.street_addr4),"}")
   ENDIF
   ms_city_state_zip = concat(trim(a.city),", ",trim(evaluate(a.state_cd,0.0,a.state,
      uar_get_code_display(a.state_cd)))," ",trim(a.zipcode)), reply->text = concat(ms_rhead,trim(
     ms_street_addr),ms_reol,"{",trim(ms_city_state_zip),
    "}",ms_reol,ms_rtfeof)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
