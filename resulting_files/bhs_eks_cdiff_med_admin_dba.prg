CREATE PROGRAM bhs_eks_cdiff_med_admin:dba
 DECLARE mf_cs4001_bymouth = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4001,"BYMOUTH")), protect
 DECLARE mf_cs4001_rectally = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4001,"RECTALLY")),
 protect
 DECLARE mf_cs72_glycerin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"GLYCERIN")), protect
 DECLARE mf_cs72_sorbitol = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SORBITOL")), protect
 DECLARE mf_cs72_sodiumbiphosphate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SODIUMBIPHOSPHATE")), protect
 DECLARE mf_cs72_sodbiphosos = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "SODIUMBIPHOSPHATESODIUMPHOSPHATE")), protect
 DECLARE mf_cs72_senna = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SENNA")), protect
 DECLARE mf_cs72_pegelectrolytesolution = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PEGELECTROLYTESOLUTION")), protect
 DECLARE mf_cs72_polyethyleneglycol3350 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "POLYETHYLENEGLYCOL3350")), protect
 DECLARE mf_cs72_polycarbophil = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"POLYCARBOPHIL")),
 protect
 DECLARE mf_cs72_mineraloil = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MINERALOIL")),
 protect
 DECLARE mf_cs72_magnsulpotsodsul = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAGNESIUMSULFATEPOTASSCLSODIUMSULF")), protect
 DECLARE mf_cs72_magnsulfate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MAGNESIUMSULFATE")),
 protect
 DECLARE mf_cs72_magnhydroxideminoil = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAGNESIUMHYDROXIDEMINERALOIL")), protect
 DECLARE mf_cs72_magnesiumhydroxide = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "MAGNESIUMHYDROXIDE")), protect
 DECLARE mf_cs72_lactulose = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"LACTULOSE")), protect
 DECLARE mf_cs72_docusatesenna = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DOCUSATESENNA")),
 protect
 DECLARE mf_cs72_bisacodyl = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BISACODYL")), protect
 DECLARE mf_cs53_med = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MED")), protect
 DECLARE mf_cs29520_medadmin = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,"MEDADMIN")),
 protect
 DECLARE mf_cs4000040_administered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4000040,
   "ADMINISTERED")), protect
 SET retval = 0
 SELECT INTO "nl:"
  FROM med_admin_event mae,
   clinical_event ce,
   ce_med_result cmr,
   orders o
  PLAN (ce
   WHERE ce.encntr_id=trigger_encntrid
    AND ce.person_id=trigger_personid
    AND ce.event_class_cd=mf_cs53_med
    AND ce.entry_mode_cd=mf_cs29520_medadmin
    AND ce.event_cd IN (mf_cs72_bisacodyl, mf_cs72_docusatesenna, mf_cs72_glycerin, mf_cs72_sorbitol,
   mf_cs72_sodiumbiphosphate,
   mf_cs72_sodbiphosos, mf_cs72_senna, mf_cs72_pegelectrolytesolution, mf_cs72_polyethyleneglycol3350,
   mf_cs72_polycarbophil,
   mf_cs72_mineraloil, mf_cs72_magnsulpotsodsul, mf_cs72_magnesiumhydroxide, mf_cs72_lactulose,
   mf_cs72_magnsulfate,
   mf_cs72_magnhydroxideminoil))
   JOIN (mae
   WHERE mae.event_id=ce.event_id
    AND mae.event_type_cd=mf_cs4000040_administered)
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND cmr.admin_route_cd IN (mf_cs4001_bymouth, mf_cs4001_rectally)
    AND cmr.admin_end_dt_tm >= cnvtdatetime((curdate - 2),curtime3))
   JOIN (o
   WHERE o.order_id=mae.template_order_id)
  ORDER BY ce.encntr_id, cmr.admin_start_dt_tm DESC
  HEAD ce.encntr_id
   retval = 100, log_misc1 = concat(trim(o.ordered_as_mnemonic,3)," on ",format(cmr.admin_start_dt_tm,
     "mm/dd/yyyy hh:mm;;q"))
  WITH nocounter
 ;end select
END GO
