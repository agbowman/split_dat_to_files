CREATE PROGRAM bhs_ma_fn_genv_ed_ptinfo
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\f0 \fs18 \cb2 "
 SET wb = "{\b\cb2"
 SET uf = " }"
 DECLARE displays = vc
 RECORD pt_info(
   1 patient_id = f8
   1 encounter_id = f8
   1 patient_name = vc
   1 patient_birth = dq8
 )
 SELECT DISTINCT INTO "nl:"
  e.person_id, e.encntr_id
  FROM encounter e
  WHERE (e.encntr_id=request->visit[1].encntr_id)
  DETAIL
   pt_info->patient_id = e.person_id, pt_info->encounter_id = e.encntr_id,
   CALL echorecord(pt_info)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  age = cnvtage(p.birth_dt_tm), p.person_id, p.name_full_formatted
  FROM person p
  WHERE (p.person_id=pt_info->patient_id)
  DETAIL
   pt_info->patient_name = p.name_full_formatted, pt_info->patient_birth = p.birth_dt_tm, pt_info->
   patient_id = p.person_id,
   CALL echorecord(pt_info)
  WITH nocounter, time = 30
 ;end select
 SET displays = "{\rtf1\ansi\ansicpg1252\deff0\deflang2057{\fonttbl{\f0\fswiss\fcharset0 Arial;}}"
 SET reply->text = build2(displays,"Name: ",pt_info->patient_name,reol,"DOB: ",
  pt_info->patient_birth,reply->text,"}}")
END GO
