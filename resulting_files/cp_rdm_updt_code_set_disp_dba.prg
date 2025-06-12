CREATE PROGRAM cp_rdm_updt_code_set_disp:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script cp_rdm_updt_code_set_disp"
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE icomponenttypecodeset = i4 WITH protect, constant(4003130)
 DECLARE ipathwaytypecodeset = i4 WITH protect, constant(4003197)
 FREE RECORD cp_updt_list
 RECORD cp_updt_list(
   1 cnt = i4
   1 qual[*]
     2 code_set = f8
     2 cdf_meaning = vc
     2 old_display = vc
     2 display = vc
     2 display_key = vc
     2 active_ind = i2
 )
 SET cp_updt_list->cnt = 13
 SET stat = alterlist(cp_updt_list->qual,cp_updt_list->cnt)
 SET cp_updt_list->qual[1].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[1].cdf_meaning = "ALLERGY"
 SET cp_updt_list->qual[1].old_display = "Allergy"
 SET cp_updt_list->qual[1].display = "Allergies"
 SET cp_updt_list->qual[1].display_key = "ALLERGIES"
 SET cp_updt_list->qual[1].active_ind = 1
 SET cp_updt_list->qual[2].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[2].cdf_meaning = "DIAGRAM"
 SET cp_updt_list->qual[2].old_display = "Diagrams"
 SET cp_updt_list->qual[2].display = "Care Pathways Diagram"
 SET cp_updt_list->qual[2].display_key = "CAREPATHWAYSDIAGRAM"
 SET cp_updt_list->qual[2].active_ind = 0
 SET cp_updt_list->qual[3].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[3].cdf_meaning = "EXORDERS"
 SET cp_updt_list->qual[3].old_display = "Existing Orders"
 SET cp_updt_list->qual[3].display = "Order Profile"
 SET cp_updt_list->qual[3].display_key = "ORDERPROFILE"
 SET cp_updt_list->qual[3].active_ind = 1
 SET cp_updt_list->qual[4].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[4].cdf_meaning = "GOALS"
 SET cp_updt_list->qual[4].old_display = "Goals"
 SET cp_updt_list->qual[4].display = "Care Pathways Outcomes"
 SET cp_updt_list->qual[4].display_key = "CAREPATHWAYSOUTCOMES"
 SET cp_updt_list->qual[4].active_ind = 1
 SET cp_updt_list->qual[5].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[5].cdf_meaning = "LABS"
 SET cp_updt_list->qual[5].old_display = "Lab"
 SET cp_updt_list->qual[5].display = "Labs"
 SET cp_updt_list->qual[5].display_key = "LABS"
 SET cp_updt_list->qual[5].active_ind = 1
 SET cp_updt_list->qual[6].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[6].cdf_meaning = "LINKS"
 SET cp_updt_list->qual[6].old_display = "Links"
 SET cp_updt_list->qual[6].display = "Custom Links"
 SET cp_updt_list->qual[6].display_key = "CUSTOMLINKS"
 SET cp_updt_list->qual[6].active_ind = 1
 SET cp_updt_list->qual[7].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[7].cdf_meaning = "PATHWAY_DOC"
 SET cp_updt_list->qual[7].old_display = "Pathways Documentation"
 SET cp_updt_list->qual[7].display = "Treatment Assessment"
 SET cp_updt_list->qual[7].display_key = "TREATMENTASSESSMENT"
 SET cp_updt_list->qual[7].active_ind = 1
 SET cp_updt_list->qual[8].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[8].cdf_meaning = "PATHWAY_ORD"
 SET cp_updt_list->qual[8].old_display = "Recomendations"
 SET cp_updt_list->qual[8].display = "Recommendations"
 SET cp_updt_list->qual[8].display_key = "RECOMMENDATIONS"
 SET cp_updt_list->qual[8].active_ind = 1
 SET cp_updt_list->qual[9].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[9].cdf_meaning = "VITAL_MEAS"
 SET cp_updt_list->qual[9].old_display = "Vitals & Measurements"
 SET cp_updt_list->qual[9].display = "Vital Signs"
 SET cp_updt_list->qual[9].display_key = "VITALSIGNS"
 SET cp_updt_list->qual[9].active_ind = 1
 SET cp_updt_list->qual[10].code_set = ipathwaytypecodeset
 SET cp_updt_list->qual[10].cdf_meaning = "CPM"
 SET cp_updt_list->qual[10].old_display = "Care Process Model"
 SET cp_updt_list->qual[10].display = "Care Pathway"
 SET cp_updt_list->qual[10].display_key = "CAREPATHWAY"
 SET cp_updt_list->qual[10].active_ind = 1
 SET cp_updt_list->qual[11].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[11].cdf_meaning = "PATED"
 SET cp_updt_list->qual[11].old_display = "Patient Education"
 SET cp_updt_list->qual[11].display = "Care Pathways Patient Education"
 SET cp_updt_list->qual[11].display_key = "CAREPATHWAYSPATIENTEDUCATION"
 SET cp_updt_list->qual[11].active_ind = 1
 SET cp_updt_list->qual[12].code_set = icomponenttypecodeset
 SET cp_updt_list->qual[12].cdf_meaning = "CLIN_DOC"
 SET cp_updt_list->qual[12].old_display = "Clin_doc"
 SET cp_updt_list->qual[12].display = "Documents"
 SET cp_updt_list->qual[12].display_key = "DOCUMENTS"
 SET cp_updt_list->qual[12].active_ind = 1
 SET cp_updt_list->qual[13].code_set = ipathwaytypecodeset
 SET cp_updt_list->qual[13].cdf_meaning = "EMERGEVENT"
 SET cp_updt_list->qual[13].old_display = "Emergent Event"
 SET cp_updt_list->qual[13].display = "Emergent Event"
 SET cp_updt_list->qual[13].display_key = "EMERGENTEVENT"
 SET cp_updt_list->qual[13].active_ind = 0
 IF ((cp_updt_list->cnt > 0))
  UPDATE  FROM (dummyt d1  WITH seq = cp_updt_list->cnt),
    code_value cv
   SET cv.display = cp_updt_list->qual[d1.seq].display, cv.display_key = cp_updt_list->qual[d1.seq].
    display_key, cv.updt_id = reqinfo->updt_id,
    cv.updt_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_applctx = reqinfo->updt_applctx, cv
    .updt_task = reqinfo->updt_task,
    cv.updt_cnt = (cv.updt_cnt+ 1), cv.active_ind = cp_updt_list->qual[d1.seq].active_ind
   PLAN (d1)
    JOIN (cv
    WHERE (cv.code_set=cp_updt_list->qual[d1.seq].code_set)
     AND (cv.cdf_meaning=cp_updt_list->qual[d1.seq].cdf_meaning)
     AND (cv.display=cp_updt_list->qual[d1.seq].old_display))
   WITH nocounter
  ;end update
  SET err_code = error(err_msg,0)
  IF (err_code > 0)
   ROLLBACK
   CALL echo("Readme Failed: Failed to perform Care Pathways display updates.")
   SET readme_data->message = concat("Failed to perform Care Pathways display updates: ",err_msg)
   SET readme_data->status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET readme_data->message = "Successfully updated Care Pathways displays."
 SET readme_data->status = "S"
#exit_script
 FREE RECORD cp_updt_list
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
