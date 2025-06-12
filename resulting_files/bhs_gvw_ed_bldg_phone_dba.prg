CREATE PROGRAM bhs_gvw_ed_bldg_phone:dba
 DECLARE mf_business_add_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE mf_business_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
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
  FROM encounter e,
   phone p
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE (p.parent_entity_id= Outerjoin(e.loc_building_cd))
    AND (p.parent_entity_name= Outerjoin("LOCATION"))
    AND (p.phone_type_cd= Outerjoin(mf_business_phone_cd))
    AND (p.active_ind= Outerjoin(1))
    AND (p.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (p.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
  ORDER BY p.phone_type_seq
  HEAD REPORT
   IF (p.phone_id > 0.00)
    reply->text = concat(ms_rhead,trim(cnvtphone(p.phone_num,p.phone_format_cd),3),ms_reol,ms_rtfeof)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
