CREATE PROGRAM bhs_asy_vaccine_check:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_vacc_dt = vc
   1 l_vaccnt = i4
   1 vacc[*]
     2 f_event_cd = f8
   1 l_rvaccnt = i4
   1 recvacc[*]
     2 f_event_cd = f8
     2 s_vacc_dt_tm = vc
   1 l_scnt = i4
   1 syns[*]
     2 f_synonym_id = f8
     2 s_mnemonic = vc
   1 l_ocnt = i4
   1 ords[*]
     2 s_mnemonic = c100
 )
 DECLARE mf_immun_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_ordact_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
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
 DECLARE mn_polio_mode = i2 WITH protect, noconstant(0)
 DECLARE mn_hib_mode = i2 WITH protect, noconstant(0)
 DECLARE mn_hepb_mode = i2 WITH protect, noconstant(0)
 DECLARE mn_pneum_mode = i2 WITH protect, noconstant(0)
 DECLARE mn_tdap_mode = i2 WITH protect, noconstant(0)
 DECLARE ml_reqsz = i4 WITH protect, noconstant(size(request->orderlist,5))
 DECLARE mf_personid = f8 WITH protect, noconstant(0.00)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_cocnt = i4 WITH protect, noconstant(0)
 DECLARE ml_cvcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_scnt = i4 WITH protect, noconstant(0)
 DECLARE ml_rvaccnt = i4 WITH protect, noconstant(0)
 DECLARE ml_oloop = i4 WITH protect, noconstant(0)
 DECLARE ml_vloop = i4 WITH protect, noconstant(0)
 SET mf_personid = trigger_personid
 SET retval = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = ml_reqsz),
   order_catalog_synonym ocs,
   code_value cv
  PLAN (d1
   WHERE (request->orderlist[d1.seq].actiontypecd=mf_ordact_cd))
   JOIN (ocs
   WHERE (ocs.synonym_id=request->orderlist[d1.seq].synonym_code))
   JOIN (cv
   WHERE cv.code_value=ocs.catalog_cd
    AND cv.display_key IN ("POLIOVIRUSVACCINEINACTIVATED", "POLIOVIRUSVACCINEINACTIVATEDVACCINE",
   "HAEMOPHILUSBHEPATITISBVACCINE", "HEPATITISAHEPATITISBVACCINE", "HEPATITISAHEPATITISBVACCINE",
   "HEPATITISBADULTVACCINE", "HEPATITISBIMMUNEGLOBULINVACCINE", "HEPATITISBPEDIATRICVACCINE",
   "HEPATITISBVACCINE", "HEPATITISBVACCINEOBSOLETE",
   "PNEUMOCOCCAL13VALENTVACCINE", "TETANUSDIPHTHERIAPERTUSSISACELTDAP"))
  ORDER BY cv.display_key
  HEAD cv.display_key
   ml_scnt += 1, m_rec->l_scnt = ml_scnt, stat = alterlist(m_rec->syns,ml_scnt),
   m_rec->syns[ml_scnt].f_synonym_id = ocs.synonym_id, m_rec->syns[ml_scnt].s_mnemonic = ocs.mnemonic
   IF (cv.display_key IN ("POLIOVIRUSVACCINEINACTIVATED", "POLIOVIRUSVACCINEINACTIVATEDVACCINE"))
    mn_polio_mode = 1
   ENDIF
   IF (cv.display_key IN ("HAEMOPHILUSBHEPATITISBVACCINE"))
    mn_hib_mode = 1
   ENDIF
   IF (cv.display_key IN ("HEPATITISAHEPATITISBVACCINE", "HEPATITISAHEPATITISBVACCINE",
   "HEPATITISBADULTVACCINE", "HEPATITISBIMMUNEGLOBULINVACCINE", "HEPATITISBPEDIATRICVACCINE",
   "HEPATITISBVACCINE", "HEPATITISBVACCINEOBSOLETE"))
    mn_hepb_mode = 1
   ENDIF
   IF (cv.display_key IN ("PNEUMOCOCCAL13VALENTVACCINE"))
    mn_pneum_mode = 1
   ENDIF
   IF (cv.display_key IN ("TETANUSDIPHTHERIAPERTUSSISACELTDAP"))
    mn_pneum_mode = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = 0
  SET log_message = "No vaccine type selected."
  GO TO exit_script
 ENDIF
 SET m_rec->s_vacc_dt = format(cnvtdatetime((curdate - 30),0),"dd-mmm-yyyy hh:mm:ss;;d")
 SET m_rec->l_vaccnt = 0
 IF (mn_polio_mode=1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=72
     AND cv.display_key="POLIOVIRUSVACCINEINACTIVATED"
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   DETAIL
    m_rec->l_vaccnt += 1, stat = alterlist(m_rec->vacc,m_rec->l_vaccnt), m_rec->vacc[m_rec->l_vaccnt]
    .f_event_cd = cv.code_value
   WITH nocounter
  ;end select
  SET log_message = "Searching for Polio vaccines within the last 30 days."
 ENDIF
 IF (mn_hib_mode=1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=72
     AND cv.display_key IN ("HAEMOPHILUSBHEPATITISBVACCINE", "HIB")
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   DETAIL
    m_rec->l_vaccnt += 1, stat = alterlist(m_rec->vacc,m_rec->l_vaccnt), m_rec->vacc[m_rec->l_vaccnt]
    .f_event_cd = cv.code_value
   WITH nocounter
  ;end select
  SET log_message = "Searching for HIB vaccines within the last 30 days."
 ENDIF
 IF (mn_hepb_mode=1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=72
     AND cv.display_key IN ("HEPATITISAHEPATITISBVACCINE", "HEPATITISBADULTVACCINE",
    "HEPATITISBPEDIATRICVACCINE", "HEPATITISBVACCINENEWBORN", "HEPATITISBVACCINEOLDTERM")
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   DETAIL
    m_rec->l_vaccnt += 1, stat = alterlist(m_rec->vacc,m_rec->l_vaccnt), m_rec->vacc[m_rec->l_vaccnt]
    .f_event_cd = cv.code_value
   WITH nocounter
  ;end select
  SET log_message = "Searching for Hepatitis B vaccines within the last 30 days."
 ENDIF
 IF (mn_pneum_mode=1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=72
     AND cv.display_key IN ("PNEUMOCOCCAL13VALENTVACCINE")
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   DETAIL
    m_rec->l_vaccnt += 1, stat = alterlist(m_rec->vacc,m_rec->l_vaccnt), m_rec->vacc[m_rec->l_vaccnt]
    .f_event_cd = cv.code_value
   WITH nocounter
  ;end select
  SET log_message = "Searching for Pneumococcal vaccines within the last 30 days."
 ENDIF
 IF (mn_tdap_mode=1)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=72
     AND cv.display_key IN ("TDAPVACCINE", "TETANUSDIPHTHERIAPERTUSSISACELTDAP")
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   DETAIL
    m_rec->l_vaccnt += 1, stat = alterlist(m_rec->vacc,m_rec->l_vaccnt), m_rec->vacc[m_rec->l_vaccnt]
    .f_event_cd = cv.code_value
   WITH nocounter
  ;end select
  SET log_message = "Searching for TDAP vaccines within the last 30 days."
 ENDIF
 SELECT INTO "nl:"
  ce.event_cd
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.person_id=mf_personid
    AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    AND ce.event_class_cd=mf_immun_cd
    AND ce.result_status_cd IN (mf_active_cd, mf_modified_cd, mf_altered_cd, mf_auth_cd)
    AND expand(ml_num,1,m_rec->l_vaccnt,ce.event_cd,m_rec->vacc[ml_num].f_event_cd))
  DETAIL
   ml_rvaccnt += 1, m_rec->l_rvaccnt = ml_rvaccnt, stat = alterlist(m_rec->recvacc,ml_rvaccnt),
   m_rec->recvacc[ml_rvaccnt].f_event_cd = ce.event_cd, m_rec->recvacc[ml_rvaccnt].s_vacc_dt_tm =
   format(ce.event_end_dt_tm,"mm/dd/yyyy HH:mm;;D")
   IF (datetimediff(ce.event_end_dt_tm,cnvtdatetime(m_rec->s_vacc_dt)) > 0)
    retval = 100
   ENDIF
  WITH nocounter
 ;end select
 SET log_misc1 = ms_rhead
 SET log_misc1 = build2(log_misc1,ms_rh2b,
  "{Patient @PATIENT:{LogicTrue} has had a vaccine within the past 30 days that matches one of",
  " the vaccines being ordered.}",ms_reol,
  ms_reol,"{Vaccines Being Ordered: }",ms_reol)
 FOR (ml_oloop = 1 TO m_rec->l_scnt)
   SET log_misc1 = build2(log_misc1,ms_rh2r,"{   ",trim(m_rec->syns[ml_oloop].s_mnemonic,3),"}",
    ms_reol,ms_reol)
 ENDFOR
 SET log_misc1 = build2(log_misc1,ms_rh2b,"{Vaccines Administered: }",ms_reol)
 FOR (ml_vloop = 1 TO m_rec->l_rvaccnt)
   SET log_misc1 = build2(log_misc1,ms_rh2r,"{   ",trim(uar_get_code_display(m_rec->recvacc[ml_vloop]
      .f_event_cd),3)," given on ",
    trim(m_rec->recvacc[ml_vloop].s_vacc_dt_tm,3),"}",ms_reol)
 ENDFOR
 SET log_misc1 = build2(log_misc1,ms_rtfeof)
#exit_script
 CALL echo(log_message)
 CALL echo(build2("retval:",retval))
 CALL echorecord(m_rec)
END GO
