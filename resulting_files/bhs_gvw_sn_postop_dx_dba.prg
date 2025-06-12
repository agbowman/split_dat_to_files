CREATE PROGRAM bhs_gvw_sn_postop_dx:dba
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE mf_postop_dx_same_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPOSTOPDIAGNOSISSAMEASPREOP"))
 DECLARE mf_postop_dx_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPOSTOPDIAGNOSIS"))
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
 DECLARE mf_per_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_surg_case_id = f8 WITH protect, noconstant(0.00)
 DECLARE ml_uknt = i4 WITH protect, noconstant(0)
 DECLARE ml_sknt = i4 WITH protect, noconstant(0)
 DECLARE mc_postop_dx_same = c3 WITH protect, noconstant("No")
 DECLARE ms_postop_dx = vc WITH protect, noconstant(" ")
 DECLARE ms_text_temp = vc WITH protect, noconstant(" ")
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
   perioperative_document pd,
   segment_header sh,
   input_form_reference ifr,
   clinical_event ce1,
   clinical_event ce2
  PLAN (sc
   WHERE sc.surg_case_id=mf_surg_case_id)
   JOIN (pd
   WHERE pd.surg_case_id=sc.surg_case_id)
   JOIN (sh
   WHERE sh.periop_doc_id=pd.periop_doc_id)
   JOIN (ifr
   WHERE ifr.input_form_cd=sh.input_form_cd
    AND ifr.input_form_version_nbr=sh.input_form_ver_nbr
    AND ifr.display IN (" General Case Data")
    AND ifr.active_ind=1)
   JOIN (ce1
   WHERE ce1.person_id=sc.person_id
    AND ce1.event_cd=ifr.event_cd
    AND ce1.event_end_dt_tm >= sc.create_dt_tm
    AND ce1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00")
    AND ce1.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd)
    AND ce1.encntr_id=sc.encntr_id)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.event_id != ce1.event_id
    AND ce2.event_cd IN (mf_postop_dx_same_cd, mf_postop_dx_cd)
    AND ce2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00")
    AND ce2.record_status_cd != mf_deleted_cd
    AND ce2.result_status_cd IN (mf_auth_cd, mf_modified_cd, mf_altered_cd))
  ORDER BY ifr.display, ce2.event_cd, ce2.event_end_dt_tm DESC
  HEAD REPORT
   ml_uknt = 0, ml_sknt = 0
  HEAD ifr.display
   null
  HEAD ce2.event_cd
   CASE (ce2.event_cd)
    OF mf_postop_dx_same_cd:
     mc_postop_dx_same = trim(ce2.result_val)
    OF mf_postop_dx_cd:
     ms_postop_dx = trim(ce2.result_val)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dummyt d1
  HEAD REPORT
   ms_text_temp = ms_rhead
   IF (mc_postop_dx_same="Yes")
    ms_text_temp = concat(ms_text_temp,ms_rh2r,"{Postop Dx same as Preop: ",mc_postop_dx_same,"}",
     ms_reol)
   ENDIF
   IF (ms_postop_dx > " ")
    ms_text_temp = concat(ms_text_temp,ms_rh2r,"{",ms_postop_dx,"}",
     ms_reol)
   ENDIF
   ms_text_temp = concat(ms_text_temp,ms_rtfeof)
  FOOT REPORT
   reply->text = ms_text_temp
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
