CREATE PROGRAM dd_rvrt_modfd_phrase_comps:dba
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
 DECLARE getcodevalue(cdfmean=vc) = null
 DECLARE deleteinvalidsystemgeneratedcomps(null) = null
 DECLARE updatemodifiedsmarttemplates(htmlcodevalue=f8,rtfcodevalue=f8) = null
 DECLARE convertincorrectsysgenindcomps(null) = null
 DECLARE deleteformtextlongblobrefrows(null) = null
 DECLARE htmlcodevalue = f8
 DECLARE rtfcodevalue = f8
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE htmlcdfmean = vc WITH protect
 DECLARE rtfcdfmean = vc WITH protect
 SET htmlcdfmean = "HTML"
 SET rtfcdfmean = "RTF"
 SET htmlcodevalue = getcodevalue(htmlcdfmean)
 SET rtfcodevalue = getcodevalue(rtfcdfmean)
 SET readme_data->status = "F"
 SET readme_data->message = concat("Error - Failed to update note phrase components:",error_msg)
 IF (checkdic("NOTE_PHRASE_DROP_LIST","T",0))
  SET readme_data->status = "S"
  SET readme_data->message = concat(
   "Success: note phrase components need not be updated due to presence of note_phrase_drop_list table.",
   error_msg)
  GO TO exit_script
 ELSE
  CALL deleteformtextlongblobrefrows(null)
  CALL deleteinvalidsystemgeneratedcomps(null)
  CALL updatemodifiedsmarttemplates(htmlcodevalue,rtfcodevalue)
  CALL convertincorrectsysgenindcomps(null)
 ENDIF
 SUBROUTINE deleteinvalidsystemgeneratedcomps(null)
   DELETE  FROM note_phrase_comp npc
    WHERE system_generated_ind=3
    WITH nocounter
   ;end delete
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error - Failed to delete note phrase components with an invalid sys_gen_ind:",error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updatemodifiedsmarttemplates(htmlcodevalue,rtfcodevalue)
   UPDATE  FROM note_phrase_comp nps
    SET nps.format_cd = rtfcodevalue
    WHERE nps.system_generated_ind=2
     AND nps.fkey_name IN ("CODE_VALUE", "CLINICAL_NOTE_TEMPLATE")
     AND nps.format_cd=htmlcodevalue
    WITH nocounter
   ;end update
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error - Failed to update note phrase component component type:",error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE convertincorrectsysgenindcomps(null)
   UPDATE  FROM note_phrase_comp nps
    SET nps.system_generated_ind = 0
    WHERE nps.system_generated_ind=2
    WITH nocounter
   ;end update
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - Failed to convert incorrect sys_gen_ind components:",
     error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteformtextlongblobrefrows(null)
   DECLARE index = i4
   FREE RECORD formtextcomp
   RECORD formtextcomp(
     1 qual[*]
       2 id = f8
   )
   SELECT INTO "nl:"
    FROM note_phrase_comp npc
    WHERE system_generated_ind=3
     AND fkey_name="LONG_BLOB_REFERENCE"
    HEAD REPORT
     count = 0
    DETAIL
     count = (count+ 1)
     IF (mod(count,50)=1)
      stat = alterlist(formtextcomp->qual,(count+ 49))
     ENDIF
     formtextcomp->qual[count].id = npc.note_phrase_comp_id
    FOOT REPORT
     stat = alterlist(formtextcomp->qual,count)
    WITH nocounter
   ;end select
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error - Failed to retrieve note_phrase_comps withy sys_gen_ind of 3:",error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
   DELETE  FROM long_blob_reference lbr
    WHERE lbr.parent_entity_name="NOTE_PHRASE_COMP"
     AND expand(index,1,size(formtextcomp->qual,5),lbr.parent_entity_id,formtextcomp->qual[index].id)
    WITH nocounter
   ;end delete
   SET err_code = error(error_msg,1)
   IF (err_code > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - Failed to delete orphaned long_blob_ref rows:",
     error_msg)
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getcodevalue(cdfmean)
   DECLARE codeval = f8
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value > 0
     AND cv.code_set=23
     AND cv.cdf_meaning=cdfmean
     AND cv.active_ind=1
    FOOT REPORT
     codeval = cv.code_value
    WITH nocounter
   ;end select
   SET err_code = error(error_msg,1)
   IF (((err_code > 0) OR (codeval=0)) )
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error - failed to get code values:",error_msg)
    GO TO exit_script
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Modified Note Phrase Components were updated."
 COMMIT
#exit_script
 FREE RECORD formtextcomp
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
