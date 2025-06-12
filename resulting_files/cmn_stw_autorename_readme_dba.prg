CREATE PROGRAM cmn_stw_autorename_readme:dba
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
 SET readme_data->message = "Readme Failed: Starting cmn_stw_autorename_readme script"
 FREE RECORD request
 RECORD request(
   1 cd_value_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 ) WITH protect
 FREE RECORD cecv_reply
 RECORD cecv_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD update_cnt_request
 RECORD update_cnt_request(
   1 qual[*]
     2 template_id = f8
     2 template_name = vc
     2 template_active_ind = i2
     2 owner_type_flag = i2
     2 prsnl_id = f8
     2 cki = vc
 ) WITH protect
 FREE RECORD inactive_codevalue_request
 RECORD inactive_codevalue_request(
   1 cd_value_list[*]
     2 code_value = f8
     2 cki = vc
     2 new_disp_key = vc
     2 conflict_ind = i2
 ) WITH protect
 FREE RECORD delete_template
 RECORD delete_template(
   1 template_id_list[*]
     2 template_id = f8
 ) WITH protect
 FREE RECORD ddt_request
 RECORD ddt_request(
   1 template_id = f8
 ) WITH protect
 FREE RECORD ddt_reply
 RECORD ddt_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD update_reply
 RECORD update_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE cv_cdf_meaning = vc WITH protect, constant("CLINNOTETEMP")
 DECLARE cv_definition = vc WITH protect, constant(trim("smart_template_wizard__driver_"))
 DECLARE cv_description = vc WITH protect, constant("VISIT")
 DECLARE action_type_flag_update = i2 WITH protect, constant(2)
 DECLARE code_set_16529 = i4 WITH protect, constant(16529)
 DECLARE cv_active_ind = i2 WITH protect, constant(1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errorcode = i4 WITH protect, noconstant(0)
 DECLARE PUBLIC::main(null) = null WITH protect
 DECLARE PUBLIC::updatecodevalue(null) = null WITH protect
 DECLARE PUBLIC::updateclinicalnotetemplate(null) = null WITH protect
 DECLARE PUBLIC::inactivatecodevalue(null) = null WITH protect
 DECLARE PUBLIC::deletetemplate(null) = null WITH protect
 SUBROUTINE PUBLIC::updatecodevalue(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(request->cd_value_list,10)
   SELECT INTO "nl:"
    FROM br_datamart_category bc,
     code_value cv
    WHERE  EXISTS (
    (SELECT
     nt.template_id
     FROM clinical_note_template nt
     WHERE nt.cki=cv.cki))
     AND bc.layout_flag=2
     AND ((bc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)) OR (bc.beg_effective_dt_tm =
    null))
     AND ((bc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (bc.end_effective_dt_tm =
    null))
     AND cv.code_set=code_set_16529
     AND cv.cdf_meaning=cv_cdf_meaning
     AND cv.display != bc.category_name
     AND bc.category_mean=cnvtupper(substring(31,69,cv.definition))
     AND cv.active_ind=1
     AND cnvtlower(cv.definition)=patstring("smart_template_wizard__driver_*")
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM code_value cv2
     WHERE cv2.code_set=code_set_16529
      AND cv2.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,bc.category_name)))))))
    DETAIL
     idx = (idx+ 1)
     IF (mod(idx,10)=1
      AND idx > 10)
      stat = alterlist(request->cd_value_list,(idx+ 9))
     ENDIF
     request->cd_value_list[idx].cki = cv.cki, request->cd_value_list[idx].code_value = cv.code_value,
     request->cd_value_list[idx].definition = trim(concat(cv_definition,bc.category_mean)),
     request->cd_value_list[idx].display = trim(substring(1,40,bc.category_name)), request->
     cd_value_list[idx].display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,bc.category_name)))),
     request->cd_value_list[idx].cdf_meaning = cv_cdf_meaning,
     request->cd_value_list[idx].code_set = code_set_16529, request->cd_value_list[idx].description
      = cv_description, request->cd_value_list[idx].active_ind = cv_active_ind,
     request->cd_value_list[idx].action_type_flag = action_type_flag_update
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error identifying smart templates in updateCodeValue: ",errmsg
     )
    GO TO exit_script
   ENDIF
   SET stat = alterlist(request->cd_value_list,idx)
   IF (size(request->cd_value_list,5)=0)
    RETURN
   ENDIF
   SET trace = recpersist
   EXECUTE core_ens_cd_value  WITH replace("REPLY",cecv_reply)
   SET trace = norecpersist
   IF ((cecv_reply->status_data.status="F"))
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = "Error updating display in code_value table"
    CALL echorecord(cecv_reply)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::updateclinicalnotetemplate(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE template_active_ind = i2 WITH protect, constant(1)
   DECLARE owner_type_flag = i2 WITH protect, constant(0)
   DECLARE prsnl_id = f8 WITH protect, constant(reqinfo->updt_id)
   DECLARE temp_cnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   IF (size(request->cd_value_list,5)=0)
    RETURN
   ENDIF
   SET stat = alterlist(update_cnt_request->qual,10)
   SELECT INTO "nl:"
    FROM clinical_note_template cn
    WHERE expand(cnt,1,size(request->cd_value_list,5),cn.smart_template_cd,request->cd_value_list[cnt
     ].code_value)
     AND cn.smart_template_ind=1
     AND cn.template_active_ind=1
    DETAIL
     pos = locateval(pos,1,size(request->cd_value_list,5),cn.smart_template_cd,request->
      cd_value_list[pos].code_value), idx = (idx+ 1)
     IF (mod(idx,10)=1
      AND idx > 10)
      stat = alterlist(update_cnt_request->qual,(idx+ 9))
     ENDIF
     update_cnt_request->qual[idx].template_id = cn.template_id, update_cnt_request->qual[idx].
     template_name = request->cd_value_list[pos].display, update_cnt_request->qual[idx].
     template_active_ind = template_active_ind,
     update_cnt_request->qual[idx].owner_type_flag = owner_type_flag, update_cnt_request->qual[idx].
     prsnl_id = prsnl_id, update_cnt_request->qual[idx].cki = request->cd_value_list[pos].cki
    WITH nocounter, expand = 0
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error identifying clinical_note_template rows in updateClinicalNoteTemplate: ",errmsg)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(update_cnt_request->qual,idx)
   IF (size(update_cnt_request->qual,5)=0)
    RETURN
   ENDIF
   EXECUTE dcp_chg_clinical_nt  WITH replace("REQUEST",update_cnt_request), replace("REPLY",
    update_reply)
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error updating clinical_note_template in updateClinicalNoteTemplate: ",errmsg)
    GO TO exit_script
   ENDIF
   IF ((update_reply->status_data.status="F"))
    ROLLBACK
    CALL echorecord(update_cnt_request)
    CALL echorecord(update_reply)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed on update into clinical_note_template"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::inactivatecodevalue(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE active_ind_inactive = i2 WITH protect, constant(0)
   UPDATE  FROM code_value cv
    SET cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv.updt_cnt =
     (cv.updt_cnt+ 1),
     cv.display = trim(substring(31,40,cv.definition)), cv.display_key = trim(cnvtupper(cnvtalphanum(
        substring(31,40,cv.definition))))
    WHERE cv.code_set=code_set_16529
     AND cv.active_ind=active_ind_inactive
     AND cv.cdf_meaning=cv_cdf_meaning
     AND cnvtlower(cv.definition)=patstring("smart_template_wizard__driver_*")
     AND cv.display_key != trim(cnvtupper(cnvtalphanum(substring(31,40,cv.definition))))
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM code_value cv2
     WHERE cv2.code_set=code_set_16529
      AND cv2.display_key=trim(cnvtupper(cnvtalphanum(substring(31,40,cv.definition)))))))
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error updating CODE_VALUE rows with inactive DISPLAY_KEY pattern: ",errmsg)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(inactive_codevalue_request->cd_value_list,10)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE  NOT ( EXISTS (
    (SELECT
     bc.br_datamart_category_id
     FROM br_datamart_category bc
     WHERE bc.category_mean=cnvtupper(substring(31,69,cv.definition))
      AND bc.layout_flag=2)))
     AND cv.code_set=code_set_16529
     AND cv.cdf_meaning=cv_cdf_meaning
     AND cnvtlower(cv.definition)=patstring("smart_template_wizard__driver_*")
     AND cv.active_ind=cv_active_ind
    DETAIL
     idx = (idx+ 1)
     IF (mod(idx,10)=1
      AND idx > 10)
      stat = alterlist(inactive_codevalue_request->cd_value_list,(idx+ 9))
     ENDIF
     inactive_codevalue_request->cd_value_list[idx].code_value = cv.code_value,
     inactive_codevalue_request->cd_value_list[idx].cki = cv.cki, inactive_codevalue_request->
     cd_value_list[idx].new_disp_key = trim(cnvtupper(cnvtalphanum(substring(31,40,cv.definition))))
    WITH nocounter
   ;end select
   IF (error(errmsg,0) > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error identifying smart templates in inactivateCodeValue: ",
     errmsg)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(inactive_codevalue_request->cd_value_list,idx)
   SET idx = 0
   IF (size(inactive_codevalue_request->cd_value_list,5)=0)
    RETURN
   ENDIF
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=code_set_16529
     AND expand(idx,1,size(inactive_codevalue_request->cd_value_list,5),cv.display_key,
     inactive_codevalue_request->cd_value_list[idx].new_disp_key)
    DETAIL
     idx = locateval(idx,1,size(inactive_codevalue_request->cd_value_list,5),cv.display_key,
      inactive_codevalue_request->cd_value_list[idx].new_disp_key), inactive_codevalue_request->
     cd_value_list[idx].conflict_ind = 1
    WITH nocounter, expand = 0
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Querying for conflicting rows: ",errmsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.active_ind = active_ind_inactive, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv
     .updt_id = reqinfo->updt_id,
     cv.updt_cnt = (cv.updt_cnt+ 1), cv.inactive_dt_tm = cnvtdatetime(curdate,curtime3), cv.display
      = trim(substring(31,40,cv.definition)),
     cv.display_key = trim(cnvtupper(cnvtalphanum(substring(31,40,cv.definition))))
    WHERE expand(idx,1,size(inactive_codevalue_request->cd_value_list,5),cv.code_value,
     inactive_codevalue_request->cd_value_list[idx].code_value,
     0,inactive_codevalue_request->cd_value_list[idx].conflict_ind)
    WITH nocounter, expand = 0
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Error inactivating code_value rows: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::deletetemplate(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE ddt_template_id = f8 WITH protect, noconstant(0.0)
   IF (size(inactive_codevalue_request->cd_value_list,5)=0)
    RETURN
   ENDIF
   SET stat = alterlist(delete_template->template_id_list,10)
   SELECT INTO "nl:"
    FROM clinical_note_template nt
    WHERE expand(idx,1,size(inactive_codevalue_request->cd_value_list,5),nt.smart_template_cd,
     inactive_codevalue_request->cd_value_list[idx].code_value)
     AND nt.smart_template_ind=1
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1
      AND cnt > 10)
      stat = alterlist(delete_template->template_id_list,(cnt+ 9))
     ENDIF
     delete_template->template_id_list[cnt].template_id = nt.template_id
    WITH nocounter, expand = 0
   ;end select
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "Error identifying clinical_note_template rows in deleteTemplate: ",errmsg)
    GO TO exit_script
   ENDIF
   SET stat = alterlist(delete_template->template_id_list,cnt)
   SET idx = 0
   FOR (idx = 1 TO size(delete_template->template_id_list,5))
     SET ddt_request->template_id = delete_template->template_id_list[idx].template_id
     EXECUTE dcp_del_template  WITH replace("REQUEST",ddt_request), replace("REPLY",ddt_reply)
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat(
       "Error deleting clinical_note_template rows in deleteTemplate: ",errmsg)
      GO TO exit_script
     ENDIF
     IF ((ddt_reply->status_data.status="F"))
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = "Failed on delete from clinical_note_template"
      CALL echorecord(ddt_reply)
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE PUBLIC::main(null)
   CALL inactivatecodevalue(null)
   CALL deletetemplate(null)
   COMMIT
   CALL updatecodevalue(null)
   CALL updateclinicalnotetemplate(null)
 END ;Subroutine
 CALL main(null)
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required updates"
 COMMIT
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(request)
  CALL echorecord(cecv_reply)
  CALL echorecord(update_cnt_request)
  CALL echorecord(inactive_codevalue_request)
  CALL echorecord(delete_template)
 ENDIF
 CALL echorecord(readme_data)
 FREE RECORD request
 FREE RECORD cecv_reply
 FREE RECORD update_cnt_request
 FREE RECORD inactive_codevalue_request
 FREE RECORD delete_template
 EXECUTE dm_readme_status
END GO
