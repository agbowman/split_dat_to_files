CREATE PROGRAM bhs_surg_proc_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgical Area" = 0,
  "Procedure Name" = "*"
  WITH outdev, surg_unit, s_proc_name
 SELECT DISTINCT INTO  $OUTDEV
  surgical_area = uar_get_code_display(s.surg_area_cd), procdure_name = o.description, specialty = p
  .prsnl_group_name,
  case_level = uar_get_code_display(s.case_level_cd), wound_class = uar_get_code_display(s
   .wound_class_cd), anesthesia_type = uar_get_code_display(s.anesthesia_type_cd),
  setup_time = d.def_setup_dur, duration = d.def_procedure_dur, cleanup_time = d.def_cleanup_dur,
  ancillary_synonym = ocs.mnemonic, historical_average_dur = d.hist_procedure_dur, recent_average_dur
   = d.rec_procedure_dur,
  last_updated = d.updt_dt_tm"@SHORTDATETIME", procedure_id = ocs.synonym_id
  FROM surg_proc_detail s,
   surg_proc_duration d,
   order_catalog o,
   order_catalog_synonym ocs,
   prsnl_group p,
   dummyt dt
  PLAN (s
   WHERE (s.surg_area_cd= $SURG_UNIT))
   JOIN (d
   WHERE d.surg_proc_detail_id=s.surg_proc_detail_id
    AND d.prsnl_id=0)
   JOIN (o
   WHERE o.catalog_cd=s.catalog_cd
    AND (o.description= $S_PROC_NAME))
   JOIN (p
   WHERE p.prsnl_group_id=s.surg_specialty_id)
   JOIN (dt)
   JOIN (ocs
   WHERE ocs.catalog_cd=o.catalog_cd
    AND (ocs.mnemonic_type_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=6011
     AND cdf_meaning="ANCILLARY")))
  ORDER BY surgical_area, procdure_name, ancillary_synonym
  WITH outerjoin = dt, separator = " ", format
 ;end select
#exit_program
END GO
