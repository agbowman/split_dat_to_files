CREATE PROGRAM bhs_gvw_sn_implant:dba
 FREE RECORD m_surg
 RECORD m_surg(
   1 c_surg_case_nbr = c100
   1 ilst[*]
     2 c_implant_qty = c50
     2 c_implant_size = c50
     2 c_implant_site = c100
     2 c_implanted_by = c100
     2 c_implant_desc = c200
 ) WITH protect
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
 DECLARE ms_hi = vc WITH protect, constant("\pard\fi-2340\li2340 ")
 DECLARE ms_rtfeof = vc WITH protect, constant("}")
 DECLARE mf_enc_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_surg_case_id = f8 WITH protect, noconstant(0.00)
 DECLARE ms_imp_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_text_temp = vc WITH protect, noconstant(" ")
 DECLARE ml_iknt = i4 WITH protect, noconstant(0)
 SET mf_enc_id = request->visit[1].encntr_id
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mf_enc_id)
  HEAD REPORT
   mf_per_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc
  PLAN (sc
   WHERE sc.encntr_id=mf_enc_id)
  ORDER BY sc.surg_start_dt_tm DESC
  HEAD REPORT
   mf_surg_case_id = sc.surg_case_id
  WITH nocounter
 ;end select
 IF (mf_surg_case_id=0.00)
  SET reply->text = concat(ms_rhead,ms_rh2r,"{No Surgery Data Found}",ms_rtfeof)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sn_implant_log_st sil,
   prsnl pr,
   mm_omf_item_master m
  PLAN (sc
   WHERE sc.surg_case_id=mf_surg_case_id)
   JOIN (sil
   WHERE sil.surg_case_id=sc.surg_case_id)
   JOIN (pr
   WHERE pr.person_id=sil.implanted_by_id)
   JOIN (m
   WHERE (m.item_master_id= Outerjoin(sil.item_id))
    AND (m.item_master_id> Outerjoin(0.00)) )
  ORDER BY sil.display_seq
  HEAD REPORT
   m_surg->c_surg_case_nbr = trim(sc.surg_case_nbr_formatted), ml_iknt = 0
  HEAD sil.display_seq
   IF (m.item_master_id > 0.00)
    ms_imp_temp = trim(m.description)
   ELSE
    ms_imp_temp = trim(sil.free_text_item_desc)
   ENDIF
   ml_iknt += 1, i0 = alterlist(m_surg->ilst,ml_iknt), m_surg->ilst[ml_iknt].c_implant_desc = trim(
    ms_imp_temp),
   m_surg->ilst[ml_iknt].c_implant_site = trim(sil.implant_site), m_surg->ilst[ml_iknt].
   c_implanted_by = trim(pr.name_full_formatted), m_surg->ilst[ml_iknt].c_implant_qty = trim(sil
    .quantity)
   IF (sil.implant_size > " ")
    m_surg->ilst[ml_iknt].c_implant_size = concat(ms_wb,"{Size: }",ms_wr,"{",trim(sil.implant_size),
     "}")
   ENDIF
  WITH nocounter
 ;end select
 IF ( NOT (size(m_surg->ilst,5) > 0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = size(m_surg->ilst,5))
  HEAD REPORT
   ms_text_temp = ms_rhead, ms_text_temp = concat(ms_text_temp,ms_rh2r,"{",trim(m_surg->
     c_surg_case_nbr),"}",
    ms_reol)
  DETAIL
   ms_text_temp = concat(ms_text_temp,ms_wr,"{",trim(m_surg->ilst[d1.seq].c_implant_desc),", ",
    "{",trim(m_surg->ilst[d1.seq].c_implant_site),"}",ms_reol), ms_text_temp = concat(ms_text_temp,
    ms_wb,"{Implanted by: }",ms_wr,"{",
    trim(m_surg->ilst[d1.seq].c_implanted_by),"}",ms_rtab,ms_wb,"{Qty: }",
    ms_wr,"{",trim(m_surg->ilst[d1.seq].c_implant_qty),"}",ms_rtab,
    trim(m_surg->ilst[d1.seq].c_implant_size),"}",ms_reol)
  FOOT REPORT
   ms_text_temp = concat(ms_text_temp,ms_rtfeof), reply->text = ms_text_temp
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
