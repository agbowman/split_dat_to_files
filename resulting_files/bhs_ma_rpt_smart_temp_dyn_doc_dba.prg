CREATE PROGRAM bhs_ma_rpt_smart_temp_dyn_doc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  dyn_doc_template = drt.title_txt, smart_template = cnt.template_name, cki = cv.cki
  FROM dd_ref_template drt,
   dd_ref_tmplt_cn_tmplt_r drtctr,
   clinical_note_template cnt,
   code_value cv
  PLAN (drt
   WHERE drt.active_ind=1
    AND drt.dd_ref_template_id > 0)
   JOIN (drtctr
   WHERE drtctr.dd_ref_template_id=drt.dd_ref_template_id)
   JOIN (cnt
   WHERE cnt.template_id=drtctr.clinical_note_template_id
    AND cnt.smart_template_ind > 0)
   JOIN (cv
   WHERE cv.cki=cnt.cki)
  ORDER BY drt.title_txt, cnt.template_name, cv.display
  WITH nocounter, heading, maxrow = 1,
   formfeed = none, format, separator = " "
 ;end select
#exit_script
END GO
