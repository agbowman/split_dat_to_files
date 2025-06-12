CREATE PROGRAM bhs_rpt_st_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Search in:" = "forms"
  WITH outdev, s_search_type
 DECLARE ms_search_type = vc WITH protect, constant(trim(cnvtlower( $S_SEARCH_TYPE),3))
 IF (ms_search_type="notes")
  SELECT INTO value( $OUTDEV)
   type = substring(1,150,uar_get_code_display(sp.pattern_type_cd)), display = substring(1,150,sp
    .display), smart_template = substring(1,50,cv.display),
   cki = substring(1,50,cv.cki), term_display = substring(1,150,stt.display), definition = substring(
    1,150,cv.definition)
   FROM scr_term st,
    scr_term_definition std,
    scr_term_hier sth,
    scr_pattern sp,
    scr_term_text stt,
    code_value cv
   PLAN (st
    WHERE st.term_type_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE code_set=14413
      AND cdf_meaning IN ("DATA", "WHAT")))
     AND st.active_ind=1)
    JOIN (std
    WHERE std.scr_term_def_id=st.scr_term_def_id
     AND std.scr_term_def_type_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE code_set=14709
      AND cdf_meaning IN ("TEMPLATE")))
     AND  NOT (std.def_text IN (null, "", " ")))
    JOIN (stt
    WHERE stt.scr_term_id=st.scr_term_id)
    JOIN (sth
    WHERE sth.scr_term_id=st.scr_term_id)
    JOIN (sp
    WHERE sp.scr_pattern_id=sth.scr_pattern_id
     AND sp.active_ind=1)
    JOIN (cv
    WHERE cv.active_ind=1
     AND std.def_text=concat("CKI=",cv.cki))
   ORDER BY sp.display
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ELSEIF (ms_search_type="forms")
  SELECT INTO value( $OUTDEV)
   form_definition = substring(1,150,dfr.definition), form_description = substring(1,150,dfr
    .description), section_definition = substring(1,150,dsr.definition),
   section_description = substring(1,150,dsr.description), smart_template_ccl = substring(1,50,cv1
    .definition)
   FROM dcp_forms_ref dfr,
    dcp_forms_def dfd,
    dcp_section_ref dsr,
    dcp_input_ref dir,
    name_value_prefs nvp,
    code_value cv1
   PLAN (dfr
    WHERE dfr.active_ind=1
     AND dfr.definition != "zz*")
    JOIN (dfd
    WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
     AND dfd.active_ind=1)
    JOIN (dsr
    WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
     AND dsr.active_ind=1)
    JOIN (dir
    WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
     AND dir.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
     AND nvp.pvc_name="template_cd")
    JOIN (cv1
    WHERE cv1.code_value=nvp.merge_id
     AND cv1.code_set=16529)
   ORDER BY form_definition, section_description
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
#exit_script
END GO
