CREATE PROGRAM cv_run_script_utility:dba
 IF (validate(reply,"NotDefined") != "NotDefined")
  CALL cv_log_message("Reply is already defined!")
 ELSE
  RECORD reply(
    1 caserec[*]
      2 case_id = f8
      2 error_msg = vc
      2 status_cd = f8
      2 status_disp = vc
      2 status_mean = vc
      2 chart_dt_tm = dq8
      2 person_id = f8
      2 encntr_id = f8
      2 name_full_formatted = vc
      2 form_id = f8
      2 form_ref_id = f8
      2 fieldrec[*]
        3 field_name = vc
        3 field_val = vc
        3 error_msg = vc
        3 status_cd = f8
        3 status_disp = vc
        3 status_mean = vc
        3 translated_val = vc
        3 case_field_id = f8
        3 long_text_id = f8
        3 dev_idx = i2
        3 lesion_idx = i2
    1 files[*]
      2 filename = vc
      2 info_line[*]
        3 new_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE program_name = vc WITH public, noconstant(" ")
 SET program_name = cnvtupper(trim(request->script_name))
 EXECUTE value(program_name)
END GO
