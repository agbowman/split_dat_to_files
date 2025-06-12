CREATE PROGRAM ams_create_task_assay
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE catalog_desc = vc
 DECLARE task_assay = vc
 DECLARE resource = vc
 DECLARE result_type = vc
 FREE RECORD request_details
 RECORD request_details(
   1 qual[*]
     2 activity_type_cd = f8
     2 event_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 default_result_type_cd = f8
     2 bb_result_processing_cd = f8
     2 rad_section_type_cd = f8
     2 strt_assay_id = f8
     2 code_set = i4
     2 end_effective_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 concept_cki = vc
     2 sci_notation_ind = i2
   1 commit_at_once_ind = i2
 )
 FREE RECORD request_details1
 RECORD request_details1(
   1 catalog_cd = f8
   1 group_ind = i2
   1 reference_task_id = f8
   1 prompt_ind = i2
   1 qual[*]
     2 task_assay_cd = f8
     2 pending_ind = i2
     2 sequence = i4
     2 version_nbr = i4
     2 group_cd = f8
     2 repeat_ind = i2
     2 restrict_display_ind = i2
     2 post_prompt_ind = i2
     2 prompt_resource_cd = f8
     2 item_type_flag = i2
     2 dup_chk_min = i4
     2 dup_chk_action_cd = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 qual[1]
     2 mnemonic = c50
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 dup_ind = i2
     2 mnemonic = c50
 )
 FREE RECORD reply1
 RECORD reply1(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 task_assay_cd = f8
     2 catalog_cd = f8
 )
 FOR (i = 1 TO value(size(file_content->qual,5)))
   IF ((file_content->qual[i].long_desc != " "))
    SET stat = initrec(request_details)
    SET stat = initrec(request_details1)
    SET stat = alterlist(request_details->qual,1)
    SET stat = alterlist(request_details1->qual,1)
    SET request_details->qual[1].mnemonic = file_content->qual[i].assay_display
    SET request_details->qual[1].description = file_content->qual[i].long_desc
    SET request_details->qual[1].activity_type_cd = 692
    SET request_details->qual[1].event_cd = 0
    SET result_type = trim(file_content->qual[i].result_type)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=289
      AND cv.display=result_type
     DETAIL
      request_details->qual[1].default_result_type_cd = cv.code_value
     WITH nocounter
    ;end select
    SET request_details->qual[1].bb_result_processing_cd = 0
    SET request_details->qual[1].rad_section_type_cd = 0
    SET request_details->qual[1].strt_assay_id = 0
    SET request_details->qual[1].code_set = 0
    SET request_details->qual[1].sci_notation_ind = 0
    SET request_details->commit_at_once_ind = 0
    SET stat = tdbexecute(15000,15001,10032,"REC",request_details,
     "REC",reply)
    SET catalog_desc = trim(file_content->qual[i].catalog_display)
    SELECT
     oc.catalog_cd
     FROM order_catalog oc
     WHERE oc.primary_mnemonic=catalog_desc
     DETAIL
      request_details1->catalog_cd = oc.catalog_cd
     WITH nocounter
    ;end select
    SET task_assay = trim(file_content->qual[i].assay_display)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=14003
      AND cv.display=task_assay
     DETAIL
      request_details1->qual[1].task_assay_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (cnvtupper(file_content->qual[i].required)="YES")
     SET request_details1->qual[1].pending_ind = 1
    ELSE
     SET request_details1->qual[1].pending_ind = 0
    ENDIF
    IF (cnvtupper(file_content->qual[i].repeat_ind)="YES")
     SET request_details1->qual[1].repeat_ind = 1
    ELSE
     SET request_details1->qual[1].repeat_ind = 0
    ENDIF
    IF (trim(file_content->qual[i].prompt_ind)="Yes")
     SET request_details1->prompt_ind = 1
    ELSE
     SET request_details1->prompt_ind = 0
    ENDIF
    IF (trim(file_content->qual[i].post_prompt_ind)="Yes")
     SET request_details1->qual[1].post_prompt_ind = 1
    ELSE
     SET request_details1->qual[1].post_prompt_ind = 0
    ENDIF
    IF (trim(file_content->qual[i].restrict_display_ind)="Yes")
     SET request_details1->qual[1].restrict_display_ind = 1
    ELSE
     SET request_details1->qual[1].restrict_display_ind = 0
    ENDIF
    SET resource = trim(file_content->qual[i].resource)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=221
      AND cv.display=resource
     DETAIL
      IF (resource != " ")
       request_details1->qual[1].prompt_resource_cd = cv.code_value
      ELSE
       request_details1->qual[1].prompt_resource_cd = 0
      ENDIF
    ;end select
    SET stat = tdbexecute(15000,15001,10030,"REC",request_details1,
     "REC",reply1)
   ENDIF
 ENDFOR
#exit_script
 SET script_ver = " 000 09/15/15 AK032157  Initial Release "
END GO
