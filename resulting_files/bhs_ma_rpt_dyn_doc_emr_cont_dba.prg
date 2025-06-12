CREATE PROGRAM bhs_ma_rpt_dyn_doc_emr_cont:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT DISTINCT INTO  $OUTDEV
  dyn_doc_template = drt.title_txt, emr_display = drec.title_txt, emr_dsecription = drec
  .description_txt,
  emr_uuid = drec.ref_content_instance_ident
  FROM dd_ref_template drt,
   dd_ref_template_content_r drtcr,
   dd_ref_emr_content drec
  PLAN (drt
   WHERE drt.active_ind=1
    AND drt.dd_ref_template_id > 0)
   JOIN (drtcr
   WHERE drtcr.dd_ref_template_id=drt.dd_ref_template_id)
   JOIN (drec
   WHERE drec.dd_ref_emr_content_id=drtcr.dd_ref_emr_content_id
    AND drec.active_ind=1)
  ORDER BY drt.title_txt, drec.title_txt, drec.description_txt,
   drec.ref_content_instance_ident
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
