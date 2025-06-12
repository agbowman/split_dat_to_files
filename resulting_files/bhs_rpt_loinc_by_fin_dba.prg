CREATE PROGRAM bhs_rpt_loinc_by_fin:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter FIN:" = ""
  WITH outdev, s_fin
 DECLARE ms_output = vc WITH protect, constant(trim( $OUTDEV))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ms_fin = vc WITH protect, constant(trim(cnvtupper( $S_FIN)))
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e
  PLAN (ea
   WHERE ea.encntr_alias_type_cd=mf_fin_cd
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.alias=ms_fin)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm > sysdate)
  HEAD ea.encntr_id
   mf_person_id = e.person_id
  WITH nocounter
 ;end select
 IF (mf_person_id=0.0)
  SELECT INTO value(ms_output)
   FROM dummyt d
   HEAD REPORT
    col 0, "No person_id found for FIN"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO value(ms_output)
  rh.updt_dt_tm"@SHORTDATETIME", p.name_full_formatted, ce.event_id,
  event = uar_get_code_display(ce.event_cd), contributor_system = uar_get_code_display(ce
   .contributor_system_cd), vocabulary = uar_get_code_display(n.source_vocabulary_cd),
  n.source_string, n.source_identifier, n.short_string,
  n.concept_cki, ce.accession_nbr
  FROM ref_cd_map_header rh,
   ref_cd_map_detail rd,
   person_alias pa,
   person p,
   clinical_event ce,
   nomenclature n
  PLAN (p
   WHERE p.person_id=mf_person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id)
   JOIN (rh
   WHERE rh.person_id=pa.person_id
    AND rh.updt_dt_tm > cnvtlookbehind("60,D",sysdate))
   JOIN (rd
   WHERE rd.ref_cd_map_header_id=rh.ref_cd_map_header_id)
   JOIN (n
   WHERE n.nomenclature_id=rd.nomenclature_id)
   JOIN (ce
   WHERE ce.event_id=rh.event_id)
  ORDER BY rh.updt_dt_tm DESC
  WITH nocounter, format, separator = " "
 ;end select
#exit_script
END GO
