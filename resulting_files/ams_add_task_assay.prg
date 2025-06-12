CREATE PROGRAM ams_add_task_assay
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Audit/Commit" = "",
  "File Name:" = ""
  WITH outdev, auditcommit, filename
 DECLARE catalog_desc = vc
 DECLARE task_assay = vc
 DECLARE resource = vc
 FREE RECORD request_details
 RECORD request_details(
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
 FOR (i = 1 TO value(size(file_content->qual,5)))
   IF ((file_content->qual[i].long_desc=" "))
    SET stat = initrec(request_details)
    SET stat = alterlist(request_details->qual,1)
    SET catalog_desc = trim(file_content->qual[i].catalog_display)
    SELECT
     oc.catalog_cd
     FROM order_catalog oc
     WHERE oc.primary_mnemonic=catalog_desc
     DETAIL
      request_details->catalog_cd = oc.catalog_cd
     WITH nocounter
    ;end select
    SET task_assay = trim(file_content->qual[i].assay_display)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=14003
      AND cv.display=task_assay
     DETAIL
      request_details->qual[1].task_assay_cd = cv.code_value
     WITH nocounter
    ;end select
    IF (cnvtupper(file_content->qual[i].required)="YES")
     SET request_details->qual[1].pending_ind = 1
    ELSE
     SET request_details->qual[1].pending_ind = 0
    ENDIF
    IF (cnvtupper(file_content->qual[i].repeat_ind)="YES")
     SET request_details->qual[1].repeat_ind = 1
    ELSE
     SET request_details->qual[1].repeat_ind = 0
    ENDIF
    IF (trim(file_content->qual[i].prompt_ind)="Yes")
     SET request_details->prompt_ind = 1
    ELSE
     SET request_details->prompt_ind = 0
    ENDIF
    IF (trim(file_content->qual[i].post_prompt_ind)="Yes")
     SET request_details->qual[1].post_prompt_ind = 1
    ELSE
     SET request_details->qual[1].post_prompt_ind = 0
    ENDIF
    IF (trim(file_content->qual[i].restrict_display_ind)="Yes")
     SET request_details->qual[1].restrict_display_ind = 1
    ELSE
     SET request_details->qual[1].restrict_display_ind = 0
    ENDIF
    SET resource = trim(file_content->qual[i].resource)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=221
      AND cv.display=resource
     DETAIL
      IF (resource != " ")
       request_details->qual[1].prompt_resource_cd = cv.code_value
      ELSE
       request_details->qual[1].prompt_resource_cd = 0
      ENDIF
     WITH nocounter
    ;end select
    SET stat = tdbexecute(15000,15001,10030,"REC",request_details,
     "REC",reply)
   ELSE
    EXECUTE ams_create_task_assay:group01
   ENDIF
 ENDFOR
#exit_script
 SET script_ver = " 000 09/15/15 AK032157  Initial Release "
END GO
