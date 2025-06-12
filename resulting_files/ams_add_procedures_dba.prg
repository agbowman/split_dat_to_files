CREATE PROGRAM ams_add_procedures:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 CALL echo("Entering ams add procedure")
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 object_name = vc
     2 user_name = vc
     2 compiled_dt_tm = vc
     2 source_name = vc
 )
 DECLARE catalog_desc = vc
 DECLARE surg_area = vc
 DECLARE specialty = vc
 DECLARE case_level = vc
 DECLARE wound_class = vc
 DECLARE anesthesia_type = vc
 FOR (i = 1 TO value(size(file_content->qual,5)))
   FREE RECORD request_details
   RECORD request_details(
     1 surg_proc_detail[*]
       2 transaction = i2
       2 exists_ind = i2
       2 surg_area_cd = f8
       2 catalog_cd = f8
       2 surg_proc_detail_id = f8
       2 temp_surg_proc_detail_id = f8
       2 surg_specialty_id = f8
       2 wound_class_cd = f8
       2 case_level_cd = f8
       2 spec_req_ind = i4
       2 frozen_section_req_ind = i4
       2 anesthesia_type_cd = f8
       2 blood_product_req_ind = i4
       2 implant_ind = i4
       2 xray_ind = i4
       2 xray_tech_ind = i4
       2 proc_cnt = f8
       2 ud1_cd = f8
       2 ud2_cd = f8
       2 ud3_cd = f8
       2 ud4_cd = f8
       2 ud5_cd = f8
     1 surg_proc_durs[*]
       2 transaction = i2
       2 exists_ind = i2
       2 prsnl_id = f8
       2 surg_proc_detail_id = f8
       2 temp_surg_proc_detail_id = f8
       2 def_setup_dur = f8
       2 def_cleanup_dur = f8
       2 def_pre_incision_dur = f8
       2 def_post_closure_dur = f8
       2 def_procedure_dur = f8
   )
   SET stat = alterlist(request_details->surg_proc_detail,1)
   SET stat = alterlist(request_details->surg_proc_durs,1)
   SET catalog_desc = trim(file_content->qual[i].catalog_description)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=200
     AND cv.display=catalog_desc
    DETAIL
     request_details->surg_proc_detail[1].catalog_cd = cv.code_value
   ;end select
   SET surg_area = trim(file_content->qual[i].surgical_area)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=221
     AND cv.display=surg_area
    DETAIL
     request_details->surg_proc_detail[1].surg_area_cd = cv.code_value
   ;end select
   SET specialty = trim(file_content->qual[i].specialty)
   SELECT
    p.prsnl_group_id
    FROM code_value cv,
     prsnl_group p
    PLAN (cv
     WHERE cv.code_set=357
      AND cv.display=specialty)
     JOIN (p
     WHERE p.prsnl_group_type_cd=cv.code_value
      AND p.prsnl_group_type_cd != 0.0)
    DETAIL
     request_details->surg_proc_detail[1].surg_specialty_id = p.prsnl_group_id
   ;end select
   SET case_level = trim(file_content->qual[i].case_level)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=10036
     AND cv.display=case_level
    DETAIL
     request_details->surg_proc_detail[1].case_level_cd = cv.code_value
   ;end select
   SET wound_class = trim(file_content->qual[i].wound_class)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=10038
     AND cv.display=wound_class
    DETAIL
     request_details->surg_proc_detail[1].wound_class_cd = cv.code_value
   ;end select
   SET anesthesia_type = trim(file_content->qual[i].anesthesia_type)
   SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=10050
     AND cv.display=anesthesia_type
    DETAIL
     request_details->surg_proc_detail[1].anesthesia_type_cd = cv.code_value
   ;end select
   SET request_details->surg_proc_detail[1].proc_cnt = cnvtreal(trim(file_content->qual[i].
     procedure_count))
   SET request_details->surg_proc_durs[1].def_setup_dur = cnvtreal(trim(file_content->qual[i].
     setup_time))
   SET request_details->surg_proc_durs[1].def_pre_incision_dur = cnvtreal(trim(file_content->qual[i].
     pre_incision_time))
   SET request_details->surg_proc_durs[1].def_procedure_dur = cnvtreal(trim(file_content->qual[i].
     procedure_duration))
   SET request_details->surg_proc_durs[1].def_post_closure_dur = cnvtreal(trim(file_content->qual[i].
     post_closure_time))
   SET request_details->surg_proc_durs[1].def_cleanup_dur = cnvtreal(trim(file_content->qual[i].
     cleanup_time))
   SET request_details->surg_proc_durs[1].transaction = 1
   SET request_details->surg_proc_detail[1].transaction = 1
   SET request_details->surg_proc_detail[1].surg_proc_detail_id = - (1)
   SET request_details->surg_proc_durs[1].surg_proc_detail_id = - (1)
   IF (cnvtupper(file_content->qual[i].specimen_required)="YES")
    SET request_details->surg_proc_detail[1].spec_req_ind = 1
   ELSE
    SET request_details->surg_proc_detail[1].spec_req_ind = 0
   ENDIF
   IF (cnvtupper(file_content->qual[i].frozen_section)="YES")
    SET request_details->surg_proc_detail[1].frozen_section_req_ind = 1
   ELSE
    SET request_details->surg_proc_detail[1].frozen_section_req_ind = 0
   ENDIF
   IF (cnvtupper(file_content->qual[i].blood_products)="YES")
    SET request_details->surg_proc_detail[1].blood_product_req_ind = 1
   ELSE
    SET request_details->surg_proc_detail[1].blood_product_req_ind = 0
   ENDIF
   IF (cnvtupper(file_content->qual[i].implants)="YES")
    SET request_details->surg_proc_detail[1].implant_ind = 1
   ELSE
    SET request_details->surg_proc_detail[1].implant_ind = 0
   ENDIF
   IF (cnvtupper(file_content->qual[i].xrays)="YES")
    SET request_details->surg_proc_detail[1].xray_ind = 1
   ELSE
    SET request_details->surg_proc_detail[1].xray_ind = 0
   ENDIF
   IF (cnvtupper(file_content->qual[i].xray_technician)="YES")
    SET request_details->surg_proc_detail[1].xray_tech_ind = 1
   ELSE
    SET request_details->surg_proc_detail[1].xray_tech_ind = 0
   ENDIF
   CALL echo("Recored structure details request_details:")
   CALL echorecord(request_details)
   CALL echo("SIZE OF request->surg_proc_detail :")
   CALL echo(size(request_details->surg_proc_detail,5))
   CALL echo("Starting execution")
   EXECUTE sn_save_proc_dtls  WITH replace("REQUEST",request_details)
   CALL echo("Ending execution")
 ENDFOR
#exit_script
 SET script_ver = " 000 09/15/15 AK032157  Initial Release "
END GO
