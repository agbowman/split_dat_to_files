CREATE PROGRAM bhs_rpt_bmc_endo_type2_diab:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, d_start_date, d_end_date
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_mrn = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs319_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mf_cs89_adtegate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"ADTEGATE")), protect
 DECLARE mf_cs12031_confirmed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12031,"CONFIRMED")),
 protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs53_num = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2694")), protect
 DECLARE mf_cs72_pochba1c = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"POC  HBA1C")), protect
 DECLARE mf_cs72_hemoglobina1cdiagnostic = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CDIAGNOSTIC")), protect
 DECLARE mf_cs72_hemoglobina1cws = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA1CWS"
   )), protect
 DECLARE mf_cs72_hemoglobina1cwsl = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CWSL")), protect
 DECLARE mf_cs72_hemoglobintranscribedresult = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINTRANSCRIBEDRESULT")), protect
 DECLARE mf_cs72_hgba1cpointofcare = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HGBA1CPOINTOFCARE")), protect
 DECLARE mf_cs72_hgba1cwnrt = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"HGBA1CWNRT")),
 protect
 DECLARE mf_cs72_hemoglobina1cmonitoring = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CMONITORING")), protect
 DECLARE mf_cs72_pochga1cresults = f8 WITH constant(uar_get_code_by("DISPLAY",72,"POCHGA1CRESULTS")),
 protect
 DECLARE mf_cs220_baystateendocrine = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "*Baystate Endocrine")), protect
 DECLARE mf_cs220_longmeadowendo = f8 WITH constant(uar_get_code_by("DISPLAY",220,"*Longmeadow Endo")
  ), protect
 DECLARE mf_cs220_palmerendocrinology = f8 WITH constant(uar_get_code_by("DISPLAY",220,
   "*Palmer Endocrinology")), protect
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 RECORD pats(
   1 cntpat = i4
   1 patients[*]
     2 pat_name = vc
     2 person_id = f8
     2 dob = vc
     2 mrn = vc
     2 qual_result = i4
     2 result = vc
     2 regdate = vc
 )
 SELECT INTO "NL:"
  FROM encounter endo,
   diagnosis dx,
   nomenclature n,
   encntr_alias mrn,
   person p,
   dummyt d1
  PLAN (endo
   WHERE endo.loc_nurse_unit_cd IN (mf_cs220_baystateendocrine, mf_cs220_longmeadowendo,
   mf_cs220_palmerendocrinology)
    AND endo.disch_dt_tm=null
    AND endo.active_ind=1
    AND endo.active_status_cd=188
    AND endo.reg_dt_tm BETWEEN cnvtdatetime( $D_START_DATE) AND cnvtdatetime( $D_END_DATE))
   JOIN (dx
   WHERE dx.active_ind=1
    AND dx.person_id=endo.person_id
    AND dx.end_effective_dt_tm > sysdate
    AND dx.confirmation_status_cd=mf_cs12031_confirmed)
   JOIN (n
   WHERE n.active_ind=1
    AND n.source_identifier_keycap="E11.*"
    AND n.contributor_system_cd != mf_cs89_adtegate
    AND n.nomenclature_id=dx.nomenclature_id)
   JOIN (p
   WHERE p.person_id=endo.person_id
    AND p.active_status_cd=mf_cs48_active
    AND p.active_ind=1)
   JOIN (mrn
   WHERE mrn.encntr_id=endo.encntr_id
    AND mrn.active_ind=1
    AND mrn.end_effective_dt_tm > sysdate
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn)
   JOIN (d1
   WHERE datetimediff(endo.reg_dt_tm,p.birth_dt_tm,9) > 18.0)
  ORDER BY endo.person_id
  HEAD REPORT
   stat = alterlist(pats->patients,10)
  HEAD endo.person_id
   pats->cntpat += 1
   IF (mod(pats->cntpat,10)=1
    AND (pats->cntpat > 1))
    stat = alterlist(pats->patients,(pats->cntpat+ 9))
   ENDIF
   pats->patients[pats->cntpat].pat_name = trim(p.name_full_formatted,3), pats->patients[pats->cntpat
   ].mrn = trim(mrn.alias,3), pats->patients[pats->cntpat].person_id = endo.person_id,
   pats->patients[pats->cntpat].dob = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,
    "@SHORTDATE4YR"), pats->patients[pats->cntpat].regdate = format(endo.reg_dt_tm,"@SHORTDATE4YR")
  FOOT REPORT
   stat = alterlist(pats->patients,pats->cntpat)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM clinical_event ce
  PLAN (ce
   WHERE expand(ml_numres,1,size(pats->patients,5),ce.person_id,pats->patients[ml_numres].person_id)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime("01-JAN-2019 00:00:00") AND sysdate
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_class_cd=mf_cs53_num
    AND ce.view_level=1
    AND ce.result_status_cd IN (mf_cs8_modified_cd, mf_cs8_altered_cd, mf_cs8_auth_cd)
    AND ce.event_cd IN (mf_cs72_pochba1c, mf_cs72_hemoglobina1cdiagnostic, mf_cs72_hemoglobina1cws,
   mf_cs72_hemoglobina1cwsl, mf_cs72_hemoglobintranscribedresult,
   mf_cs72_hgba1cpointofcare, mf_cs72_hgba1cwnrt, mf_cs72_hemoglobina1cmonitoring,
   mf_cs72_pochga1cresults))
  ORDER BY ce.person_id, ce.event_end_dt_tm DESC
  HEAD ce.person_id
   ml_loc = 0, ml_loc = locateval(ml_numres,1,size(pats->patients,5),ce.person_id,pats->patients[
    ml_numres].person_id)
   IF (ml_loc > 0
    AND cnvtreal(ce.result_val) < 8
    AND cnvtreal(ce.result_val) > 0)
    pats->patients[ml_loc].qual_result = 1, pats->patients[ml_loc].result = trim(ce.result_val,3)
   ELSEIF (ml_loc > 0)
    pats->patients[ml_loc].result = trim(ce.result_val,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO  $OUTDEV
  patient_name = substring(1,30,pats->patients[d1.seq].pat_name), mrn = substring(1,30,pats->
   patients[d1.seq].mrn), dob = substring(1,30,pats->patients[d1.seq].dob)
  FROM (dummyt d1  WITH seq = size(pats->patients,5))
  PLAN (d1
   WHERE (pats->patients[d1.seq].qual_result=1))
  WITH nocounter, separator = " ", format
 ;end select
END GO
