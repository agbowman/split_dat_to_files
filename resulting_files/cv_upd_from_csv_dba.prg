CREATE PROGRAM cv_upd_from_csv:dba
 CALL echorecord(request,"cer_temp:cv_csv_upd_req.dat")
 FREE RECORD cvrequestin
 RECORD cvrequestin(
   1 med[*]
     2 effectivedate = c10
     2 expirationdate = c10
     2 medid = i4
     2 timing = c1
     2 medcategory = vc
     2 medname = vc
   1 closure[*]
     2 effectivedate = c10
     2 expirationdate = c10
     2 closuredevid = i4
     2 closuredevname = vc
   1 icdev[*]
     2 effectivedate = c10
     2 expirationdate = c10
     2 icdeviceid = i4
     2 icdevname = vc
     2 canbeprimary = c1
     2 diamrequired = c1
     2 lenrequired = c1
   1 force_update = i2
 )
 FREE RECORD cvreply
 RECORD cvreply(
   1 med_status = c1
   1 closure_status = c1
   1 icdev_status = c1
   1 lines[*]
     2 errmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 DECLARE forcnt = i4 WITH protect
 DECLARE exec_icdev = i2 WITH protect
 DECLARE exec_med = i2 WITH protect
 DECLARE exec_close = i2 WITH protect
 DECLARE processmed_ret = i2 WITH protect
 DECLARE processclose_ret = i2 WITH protect
 DECLARE processicdev_ret = i2 WITH protect
 DECLARE accv3_dfr_admit = f8 WITH protect
 DECLARE accv3_dfr_labvisit = f8 WITH protect
 DECLARE accv3_dsid = f8 WITH protect
 DECLARE primnomen = f8 WITH protect
 DECLARE yesnomen = f8 WITH protect
 DECLARE yesdta = f8 WITH protect
 DECLARE primarydta = f8 WITH protect
 DECLARE count1 = i4 WITH protect
 DECLARE cs_dta = i4 WITH protect, constant(14003)
 DECLARE icdev_cdf = vc WITH protect, constant("AC03DEV")
 DECLARE kia_upd_audit = i2 WITH protect, constant(1)
 DECLARE dataset_name = c5 WITH protect, constant("ACC03")
 DECLARE xref_prefix = c11 WITH protect, constant("ACC03_MEDID")
 DECLARE cdf_prefix = c9 WITH protect, constant("AC03MEDID")
 DECLARE case_et = c4 WITH protect, constant("CASE")
 DECLARE admit_et = c5 WITH protect, constant("ADMIT")
 DECLARE alpha_ft = c12 WITH protect, constant("ALPHA")
 DECLARE med_ref_dta = c12 WITH protect, constant("AC03MEDADMIN")
 DECLARE field_type = c1 WITH protect, constant("A")
 DECLARE closure_dta = c11 WITH protect, constant("AC03CLSDVID")
 DECLARE endrange = vc WITH protect, noconstant(build(cdf_prefix,"999"))
 DECLARE begrange = vc WITH protect, noconstant(build(cdf_prefix,"000"))
 DECLARE prim_count = i4 WITH protect
 DECLARE diam_count = i4 WITH protect
 DECLARE len_count = i4 WITH protect
 DECLARE line_count = i4 WITH protect
 DECLARE cnt1 = i4 WITH protect
 DECLARE timingstr = vc WITH protect
 DECLARE aliaspoolmean = vc WITH protect
 DECLARE validationscript = vc WITH protect
 DECLARE ds_cnt = i4 WITH protect
 DECLARE casedatemean = vc WITH protect
 DECLARE datasetdisp = vc WITH protect
 DECLARE closuredta = f8 WITH protect
 DECLARE dtapref_flag = i4 WITH protect
 DECLARE clsdvsuc = f8 WITH protect
 DECLARE icdevdta = f8 WITH protect
 DECLARE clsdvxrefid = f8 WITH protect
 DECLARE icdevxrefid = f8 WITH protect
 DECLARE meddisp = vc WITH protect
 DECLARE meddescript = vc WITH protect
 DECLARE meddta = f8 WITH protect
 DECLARE errcnt = i4 WITH protect
 SET cvrequestin->force_update = request->force_update
 DECLARE parsemeds(null) = i2
 DECLARE parseclosuredevs(null) = i2
 DECLARE parseicdevs(null) = i2
 DECLARE processmeds(exec_med=i2) = i2
 DECLARE processclosuredevs(exec_close=i2) = i2
 DECLARE processicdevs(exec_icdev=i2) = i2
 DECLARE zerorowsfound(message=cv) = null
 DECLARE scriptfailure(message=cv) = null
 SELECT INTO "nl:"
  FROM dm_prefs dp,
   dcp_forms_ref dfr,
   cv_dataset cd
  PLAN (cd
   WHERE cd.dataset_internal_name=dataset_name
    AND cd.active_ind=1)
   JOIN (dp
   WHERE dp.pref_domain="CVNET"
    AND dp.pref_section="CV Dataset Form"
    AND dp.pref_name=patstring(concat(dataset_name,"*"))
    AND dp.parent_entity_name="DCP_FORMS_REF")
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dp.parent_entity_id
    AND dfr.active_ind=1)
  DETAIL
   IF (dp.pref_name="ACC03_ADMIT")
    accv3_dfr_admit = dfr.dcp_forms_ref_id
   ELSEIF (dp.pref_name="ACC03_LABVISIT")
    accv3_dfr_labvisit = dfr.dcp_forms_ref_id
   ENDIF
   accv3_dsid = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL scriptfailure("Can't find the ACCv3 form or dataset_id.")
 ENDIF
 SET yesdta = uar_get_code_by("MEANING",14003,"AC03CLSDVSUC")
 SET primarydta = uar_get_code_by("MEANING",14003,"AC03DEVPRIM")
 SELECT INTO "nl:"
  FROM nomenclature n,
   reference_range_factor rrf,
   alpha_responses ar
  PLAN (rrf
   WHERE rrf.task_assay_cd IN (yesdta, primarydta)
    AND rrf.active_ind=1
    AND rrf.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND rrf.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (ar
   WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id
    AND ar.active_ind=1
    AND ar.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ar.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (n
   WHERE n.nomenclature_id=ar.nomenclature_id
    AND n.source_string IN ("Yes", "Primary")
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   IF (rrf.task_assay_cd=yesdta
    AND n.source_string="Yes")
    yesnomen = n.nomenclature_id
   ELSEIF (rrf.task_assay_cd=primarydta
    AND n.source_string="Primary")
    primnomen = n.nomenclature_id
   ENDIF
  WITH nocounter
 ;end select
 SET exec_med = parsemeds(null)
 SET exec_close = parseclosuredevs(null)
 SET exec_icdev = parseicdevs(null)
 SET processmed_ret = processmeds(exec_med)
 IF (processmed_ret=1)
  SET cvreply->med_status = "S"
 ELSEIF (exec_med=0)
  SET cvreply->med_status = " "
 ELSE
  SET cvreply->med_status = "F"
 ENDIF
 SET processclose_ret = processclosuredevs(exec_close)
 IF (processclose_ret=1)
  SET cvreply->closure_status = "S"
 ELSEIF (exec_close=0)
  SET cvreply->closure_status = " "
 ELSE
  SET cvreply->closure_status = "F"
 ENDIF
 SET processicdev_ret = processicdevs(exec_icdev)
 IF (processicdev_ret=1)
  SET cvreply->icdev_status = "S"
 ELSEIF (exec_icdev=0)
  SET cvreply->icdev_status = " "
 ELSE
  SET cvreply->icdev_status = "F"
 ENDIF
 SUBROUTINE processicdevs(exec_icdev)
   FREE RECORD icdevs
   RECORD icdevs(
     1 reference_range_factor_id = f8
     1 icdev_dsr = f8
     1 icdev_dir = f8
     1 lesion_dir = f8
     1 dev_dta = f8
     1 devdiam_dta = f8
     1 devlen_dta = f8
     1 devprim_dta = f8
     1 qual[*]
       2 effectivedate = c10
       2 expirationdate = c10
       2 icdeviceid = i4
       2 icdevname = vc
       2 canbeprimary = c1
       2 diamrequired = c1
       2 lenrequired = c1
       2 newarresponse = i1
       2 nomenclature_id = f8
       2 arinsertsuccess = i1
       2 arinserterrnum = i4
       2 arinserterrmsg = vc
       2 responsename = vc
       2 newcvresponse = i1
       2 ymdeffectdt = c8
       2 ymdexpiredt = c8
       2 dtaresppvc = vc
     1 lines[1]
       2 diam_lines = i4
       2 len_lines = i4
       2 prim_lines = i4
       2 total_lines = i4
     1 pvc_values[*]
       2 pvcnbr = i4
       2 pvcval = vc
   )
   FREE RECORD getalphas
   RECORD getalphas(
     1 alpha[*]
       2 sequence = i4
       2 nomenclature_id = f8
       2 source_string = vc
       2 result_value = f8
   )
   FREE RECORD cpsimpnomenrequest
   RECORD cpsimpnomenrequest(
     1 list_0[*]
       2 principle_type_mean = vc
       2 contributor_system_mean = vc
       2 source_string = vc
       2 source_identifier = vc
       2 string_identifier = vc
       2 string_status_mean = vc
       2 term_identifier = vc
       2 term_source_mean = vc
       2 language_mean = vc
       2 data_status_mean = vc
       2 short_string = vc
       2 mnemonic = vc
       2 concept_identifier = vc
       2 concept_source_mean = vc
       2 string_source_mean = vc
       2 source_vocabulary_mean = vc
       2 beg_effective_dt_tm = vc
       2 version = vc
       2 vocab_axis_mean = vc
       2 primary_vterm_ind = vc
   )
   FREE RECORD cvaddfldresponserequest
   RECORD cvaddfldresponserequest(
     1 response_rec[*]
       2 field_type = c1
       2 response_internal_name = vc
       2 a1 = vc
       2 a2 = vc
       2 a3 = vc
       2 a4 = vc
       2 a5 = vc
       2 xref_id = f8
       2 transaction = i2
   )
   FREE RECORD cvimpxrefvalrequest
   RECORD cvimpxrefvalrequest(
     1 list_0[*]
       2 xref_internal_name = vc
       2 response_internal_name = vc
       2 child_xref_internal_name = vc
       2 child_response_internal_name = vc
       2 rltnship_flag = vc
       2 reqd_flag = vc
       2 offset_nbr = vc
   )
   DECLARE cur_list_size = i4 WITH protect
   DECLARE loop_cnt = i4 WITH protect
   DECLARE new_list_size = i4 WITH protect
   DECLARE stat = i4 WITH protect
   DECLARE nstart = i4 WITH protect
   DECLARE batch_size = i4 WITH protect, constant(20)
   DECLARE determineexistingicdevresponses(null) = i2
   DECLARE importnewicdevalpharesponses(null) = i2
   DECLARE updateicdevxrefs(null) = i2
   DECLARE inserticdevnamevalueprefs(null) = i2
   SUBROUTINE inserticdevnamevalueprefs(null)
     SELECT INTO "nl:"
      FROM dcp_input_ref dir,
       dcp_section_ref dsr,
       dcp_forms_def dfd,
       dcp_forms_ref dfr,
       name_value_prefs nvp
      PLAN (dfr
       WHERE dfr.dcp_forms_ref_id=accv3_dfr_labvisit
        AND dfr.active_ind=1
        AND dfr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dfr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        AND dfr.dcp_form_instance_id > 0)
       JOIN (dfd
       WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
        AND dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id
        AND dfd.active_ind=1)
       JOIN (dsr
       WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
        AND dsr.active_ind=1
        AND dsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dsr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (dir
       WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
        AND dir.dcp_section_ref_id=dsr.dcp_section_ref_id
        AND dir.active_ind=1
        AND dir.description="LESION"
        AND dir.input_type=1
        AND dir.module="CVFormCtrls")
       JOIN (nvp
       WHERE nvp.parent_entity_name="DCP_INPUT_REF"
        AND nvp.parent_entity_id=dir.dcp_input_ref_id
        AND nvp.pvc_name="popup_section"
        AND nvp.active_ind=1
        AND nvp.merge_name="DCP_SECTION_REF")
      DETAIL
       icdevs->lesion_dir = dir.dcp_input_ref_id, icdevs->icdev_dsr = nvp.merge_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL scriptfailure("Can't find 'popup_section' for Lesion. Can't continue.")
     ENDIF
     SELECT INTO "nl:"
      FROM dcp_input_ref dir,
       dcp_section_ref dsr
      PLAN (dsr
       WHERE (dsr.dcp_section_ref_id=icdevs->icdev_dsr)
        AND dsr.active_ind=1
        AND dsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dsr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (dir
       WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
        AND dir.dcp_section_ref_id=dsr.dcp_section_ref_id
        AND dir.active_ind=1
        AND dir.description="IC_DEV")
      DETAIL
       icdevs->icdev_dir = dir.dcp_input_ref_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL scriptfailure("Can't find IC Devices dcp_input_ref_id. Can't continue.")
     ENDIF
     SET icdevs->dev_dta = uar_get_code_by("MEANING",14003,"AC03DEV")
     IF ((icdevs->dev_dta < 1))
      CALL scriptfailure("There is no IC Device DTA. Can't continue.")
     ENDIF
     SET icdevs->devdiam_dta = uar_get_code_by("MEANING",14003,"AC03DEVDIAM")
     IF ((icdevs->devdiam_dta < 1))
      CALL scriptfailure("There is no IC Device Diameter DTA. Can't continue.")
     ENDIF
     SET icdevs->devlen_dta = uar_get_code_by("MEANING",14003,"AC03DEVLEN")
     IF ((icdevs->devlen_dta < 1))
      CALL scriptfailure("There is no IC Device Length DTA. Can't continue.")
     ENDIF
     SET icdevs->devprim_dta = uar_get_code_by("MEANING",14003,"AC03DEVPRIM")
     IF ((icdevs->devprim_dta < 1))
      CALL scriptfailure("There is no IC Device Primary DTA. Can't continue.")
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.pvc_name="in_popup_section"
       AND nvp.active_ind=1
       AND nvp.name_value_prefs_id > 0
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp
        .parent_entity_id = icdevs->icdev_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF", nvp.pvc_name = "in_popup_section", nvp.updt_cnt = 0,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_applctx = reqinfo->updt_applctx,
        nvp.updt_id = reqinfo->updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.sequence = 2
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.pvc_name="discrete_task_assay"
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND (nvp.merge_id=icdevs->dev_dta)
       AND nvp.active_ind=1
       AND nvp.name_value_prefs_id > 0
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.merge_id = icdevs->dev_dta, nvp.merge_name = "DISCRETE_TASK_ASSAY",
        nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = icdevs->icdev_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF",
        nvp.pvc_name = "discrete_task_assay", nvp.pvc_value = "0;40", nvp.updt_cnt = 0,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_applctx = reqinfo->updt_applctx,
        nvp.updt_id = reqinfo->updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.sequence = 3
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.pvc_name="discrete_task_assay"
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND (nvp.merge_id=icdevs->devdiam_dta)
       AND nvp.active_ind=1
       AND nvp.name_value_prefs_id > 0
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.merge_id = icdevs->devdiam_dta, nvp.merge_name =
        "DISCRETE_TASK_ASSAY",
        nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = icdevs->icdev_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF",
        nvp.pvc_name = "discrete_task_assay", nvp.pvc_value = "0;10", nvp.updt_cnt = 0,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_applctx = reqinfo->updt_applctx,
        nvp.updt_id = reqinfo->updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.sequence = 4
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.pvc_name="discrete_task_assay"
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND (nvp.merge_id=icdevs->devlen_dta)
       AND nvp.active_ind=1
       AND nvp.name_value_prefs_id > 0
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.merge_id = icdevs->devlen_dta, nvp.merge_name =
        "DISCRETE_TASK_ASSAY",
        nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = icdevs->icdev_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF",
        nvp.pvc_name = "discrete_task_assay", nvp.pvc_value = "0;10", nvp.updt_cnt = 0,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_applctx = reqinfo->updt_applctx,
        nvp.updt_id = reqinfo->updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.sequence = 5
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.pvc_name="discrete_task_assay"
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND (nvp.merge_id=icdevs->devprim_dta)
       AND nvp.active_ind=1
       AND nvp.name_value_prefs_id > 0
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.merge_id = icdevs->devprim_dta, nvp.merge_name =
        "DISCRETE_TASK_ASSAY",
        nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = icdevs->icdev_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF",
        nvp.pvc_name = "discrete_task_assay", nvp.pvc_value = "0;10", nvp.updt_cnt = 0,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_applctx = reqinfo->updt_applctx,
        nvp.updt_id = reqinfo->updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.sequence = 6
       WITH nocounter
      ;end insert
     ENDIF
     DECLARE dta_radio_nvp = f8 WITH noconstant(0.0)
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.active_ind=1
       AND ((nvp.parent_entity_id+ 0)=icdevs->icdev_dir)
       AND nvp.parent_entity_name="DCP_INPUT_REF"
       AND nvp.pvc_name="dta_radio"
      DETAIL
       dta_radio_nvp = nvp.name_value_prefs_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.merge_id = primnomen, nvp.merge_name = "NOMENCLATURE",
        nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = icdevs->icdev_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF",
        nvp.pvc_name = "dta_radio", nvp.pvc_value = "DTA:4", nvp.updt_cnt = 0,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_applctx = reqinfo->updt_applctx, nvp
        .updt_id = reqinfo->updt_id,
        nvp.updt_task = reqinfo->updt_task, nvp.sequence = 7
       WITH nocounter
      ;end insert
     ELSE
      UPDATE  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.merge_id = primnomen, nvp.merge_name = "NOMENCLATURE",
        nvp.parent_entity_id = icdevs->icdev_dir, nvp.parent_entity_name = "DCP_INPUT_REF", nvp
        .pvc_name = "dta_radio",
        nvp.pvc_value = "DTA:4", nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp.updt_dt_tm = cnvtdatetime(
         curdate,curtime),
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
        reqinfo->updt_task,
        nvp.sequence = 7
       WHERE nvp.name_value_prefs_id=dta_radio_nvp
       WITH nocounter
      ;end update
     ENDIF
     DELETE  FROM name_value_prefs nvp
      WHERE nvp.merge_name="NOMENCLATURE"
       AND nvp.pvc_name=trim("dta_response")
       AND nvp.pvc_value="DTA:1,ORDER:*"
       AND (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.parent_entity_name="DCP_INPUT_REF"
      WITH nocounter
     ;end delete
     CALL echorecord(icdevs,"cer_temp:icdevs_rec.dat")
     INSERT  FROM name_value_prefs nvp,
       (dummyt d  WITH seq = value(size(icdevs->qual,5)))
      SET nvp.active_ind = 1, nvp.merge_id = icdevs->qual[d.seq].nomenclature_id, nvp.merge_name =
       "NOMENCLATURE",
       nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp.parent_entity_id = icdevs->icdev_dir,
       nvp.parent_entity_name = "DCP_INPUT_REF",
       nvp.pvc_name = "dta_response", nvp.pvc_value = icdevs->qual[d.seq].dtaresppvc, nvp.sequence =
       (d.seq+ 7),
       nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_applctx = reqinfo
       ->updt_applctx,
       nvp.updt_id = reqinfo->updt_id, nvp.updt_task = reqinfo->updt_task
      PLAN (d
       WHERE (icdevs->qual[d.seq].nomenclature_id > 0))
       JOIN (nvp)
      WITH nocounter
     ;end insert
     DELETE  FROM name_value_prefs nvp
      WHERE (nvp.parent_entity_id=icdevs->icdev_dir)
       AND nvp.parent_entity_name="DCP_INPUT_REF"
       AND nvp.pvc_name=trim("dta_conditional")
       AND nvp.pvc_value="DTA:1,DTA:*"
      WITH nocounter
     ;end delete
     SET icdevs->lines.diam_lines = (((diam_count+ 1)/ 50)+ 1)
     SET icdevs->lines.len_lines = (((len_count+ 1)/ 50)+ 1)
     SET icdevs->lines.prim_lines = (((prim_count+ 1)/ 50)+ 1)
     SET icdevs->lines.total_lines = ((icdevs->lines.diam_lines+ icdevs->lines.len_lines)+ icdevs->
     lines.prim_lines)
     SET stat = alterlist(icdevs->pvc_values,icdevs->lines.total_lines)
     SET line_count = 0
     SET cnt1 = 0
     FOR (i = 1 TO size(icdevs->qual,5))
       IF ((icdevs->qual[i].diamrequired="Y"))
        SET cnt1 = (cnt1+ 1)
        IF (mod(cnt1,50)=1)
         SET line_count = (line_count+ 1)
         SET icdevs->pvc_values[line_count].pvcnbr = ((line_count+ size(icdevs->qual,5))+ 7)
         SET icdevs->pvc_values[line_count].pvcval = build("DTA:1,DTA:2,RESPONSE:",icdevs->qual[i].
          icdeviceid)
        ELSE
         SET icdevs->pvc_values[line_count].pvcval = build(icdevs->pvc_values[line_count].pvcval,",",
          icdevs->qual[i].icdeviceid)
        ENDIF
       ENDIF
     ENDFOR
     SET cnt1 = 0
     FOR (i = 1 TO size(icdevs->qual,5))
       IF ((icdevs->qual[i].lenrequired="Y"))
        SET cnt1 = (cnt1+ 1)
        IF (mod(cnt1,50)=1)
         SET line_count = (line_count+ 1)
         SET icdevs->pvc_values[line_count].pvcnbr = ((line_count+ value(size(icdevs->qual,5)))+ 7)
         SET icdevs->pvc_values[line_count].pvcval = build("DTA:1,DTA:3,RESPONSE:",icdevs->qual[i].
          icdeviceid)
        ELSE
         SET icdevs->pvc_values[line_count].pvcval = build(icdevs->pvc_values[line_count].pvcval,",",
          icdevs->qual[i].icdeviceid)
        ENDIF
       ENDIF
     ENDFOR
     SET cnt1 = 0
     FOR (i = 1 TO size(icdevs->qual,5))
       IF ((icdevs->qual[i].canbeprimary="Y"))
        SET cnt1 = (cnt1+ 1)
        IF (mod(cnt1,50)=1)
         SET line_count = (line_count+ 1)
         SET icdevs->pvc_values[line_count].pvcnbr = ((line_count+ size(icdevs->qual,5))+ 7)
         SET icdevs->pvc_values[line_count].pvcval = build("DTA:1,DTA:4,RESPONSE:",icdevs->qual[i].
          icdeviceid)
        ELSE
         SET icdevs->pvc_values[line_count].pvcval = build(icdevs->pvc_values[line_count].pvcval,",",
          icdevs->qual[i].icdeviceid)
        ENDIF
       ENDIF
     ENDFOR
     INSERT  FROM name_value_prefs nvp,
       (dummyt d  WITH seq = value(size(icdevs->pvc_values,5)))
      SET nvp.active_ind = 1, nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp
       .parent_entity_id = icdevs->icdev_dir,
       nvp.parent_entity_name = "DCP_INPUT_REF", nvp.pvc_name = "dta_conditional", nvp.pvc_value =
       icdevs->pvc_values[d.seq].pvcval,
       nvp.sequence = icdevs->pvc_values[d.seq].pvcnbr, nvp.updt_cnt = 0, nvp.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (icdevs->pvc_values[d.seq].pvcval != " "))
       JOIN (nvp)
      WITH nocounter
     ;end insert
     RETURN(1)
   END ;Subroutine
   SUBROUTINE determineexistingicdevresponses(null)
     SET stat = alterlist(icdevs->qual,size(cvrequestin->icdev,5))
     SET prim_count = 0
     SET diam_count = 0
     SET len_count = 0
     FOR (i = 1 TO size(cvrequestin->icdev,5))
       SET icdevs->qual[i].effectivedate = cvrequestin->icdev[i].effectivedate
       IF ((cvrequestin->icdev[i].expirationdate != null))
        SET icdevs->qual[i].expirationdate = cvrequestin->icdev[i].expirationdate
       ELSE
        SET icdevs->qual[i].expirationdate = format(cnvtdatetime("31-DEC-2100"),"MM/DD/YYYY;;D")
       ENDIF
       SET icdevs->qual[i].icdeviceid = cvrequestin->icdev[i].icdeviceid
       SET icdevs->qual[i].icdevname = cvrequestin->icdev[i].icdevname
       SET icdevs->qual[i].canbeprimary = cvrequestin->icdev[i].canbeprimary
       SET icdevs->qual[i].diamrequired = cvrequestin->icdev[i].diamrequired
       SET icdevs->qual[i].lenrequired = cvrequestin->icdev[i].lenrequired
       SET icdevs->qual[i].responsename = build("ACC03_DEV_",cnvtupper(cvrequestin->icdev[i].
         icdevname))
       SET icdevs->qual[i].ymdeffectdt = format(cnvtdate2(icdevs->qual[i].effectivedate,"MM/DD/YYYY"),
        "YYYYMMDD;;D")
       SET icdevs->qual[i].ymdexpiredt = format(cnvtdate2(icdevs->qual[i].expirationdate,"MM/DD/YYYY"
         ),"YYYYMMDD;;D")
       SET icdevs->qual[i].dtaresppvc = build("DTA:1,ORDER:",icdevs->qual[i].icdeviceid,",DATED:",
        icdevs->qual[i].ymdeffectdt,",",
        icdevs->qual[i].ymdexpiredt)
       IF ((cvrequestin->icdev[i].canbeprimary="Y"))
        SET prim_count = (prim_count+ 1)
       ENDIF
       IF ((cvrequestin->icdev[i].diamrequired="Y"))
        SET diam_count = (diam_count+ 1)
       ENDIF
       IF ((cvrequestin->icdev[i].lenrequired="Y"))
        SET len_count = (len_count+ 1)
       ENDIF
     ENDFOR
     SET icdevdta = uar_get_code_by("MEANING",cs_dta,nullterm(icdev_cdf))
     IF (icdevdta < 1)
      CALL scriptfailure(concat("IC Device DTA doesn't exist (",icdev_cdf,")"))
     ENDIF
     SELECT INTO "nl:"
      FROM reference_range_factor r
      WHERE r.task_assay_cd=icdevdta
       AND r.active_ind=1
       AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND r.reference_range_factor_id > 0
      DETAIL
       icdevs->reference_range_factor_id = r.reference_range_factor_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM alpha_responses ar,
       nomenclature n
      PLAN (ar
       WHERE (ar.reference_range_factor_id=icdevs->reference_range_factor_id)
        AND ar.reference_range_factor_id > 0
        AND ar.nomenclature_id > 0
        AND ar.active_ind=1
        AND ar.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ar.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.nomenclature_id > 0
        AND n.source_string != " "
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      ORDER BY ar.sequence
      HEAD REPORT
       count1 = 0, stat = alterlist(getalphas->alpha,10)
      DETAIL
       count1 = (count1+ 1)
       IF (mod(count1,10)=1
        AND count1 != 1)
        stat = alterlist(getalphas->alpha,(count1+ 9))
       ENDIF
       getalphas->alpha[count1].sequence = ar.sequence, getalphas->alpha[count1].nomenclature_id = ar
       .nomenclature_id, getalphas->alpha[count1].source_string = n.source_string,
       getalphas->alpha[count1].result_value = ar.result_value
      FOOT REPORT
       stat = alterlist(getalphas->alpha,count1)
      WITH nocounter
     ;end select
     IF (size(getalphas->alpha,5) > size(cvrequestin->icdev,5))
      CALL cv_log_message("Number of IC devices in system is greater than number in csv.")
      SET errcnt = (errcnt+ 1)
      SET stat = alterlist(cvreply->lines,errcnt)
      SET cvreply->lines[errcnt].errmsg =
      "Number of IC devices in system is greater than number in csv."
      IF ((cvrequestin->force_update=0))
       CALL cv_log_message("Since force_update=0, failing script with no changes to database.")
       SET errcnt = (errcnt+ 1)
       SET stat = alterlist(cvreply->lines,errcnt)
       SET cvreply->lines[errcnt].errmsg =
       "Since force_update=0, failing script with no changes to database."
       GO TO exit_script
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(getalphas->alpha,5))),
       (dummyt d2  WITH seq = value(size(icdevs->qual,5))),
       dummyt d3
      PLAN (d1
       WHERE (getalphas->alpha[d1.seq].nomenclature_id > 0.0))
       JOIN (d3)
       JOIN (d2
       WHERE (icdevs->qual[d2.seq].icdeviceid=cnvtint(getalphas->alpha[d1.seq].result_value))
        AND (icdevs->qual[d2.seq].icdevname=getalphas->alpha[d1.seq].source_string))
      DETAIL
       CALL cv_log_message("Existing response does not match incoming response."),
       CALL cv_log_message(build("Nomenclature_id:",getalphas->alpha[d1.seq].nomenclature_id)),
       CALL cv_log_message(build("Source_String:",getalphas->alpha[d1.seq].source_string))
      WITH nocounter, outerjoin = d3, dontexist
     ;end select
     RETURN(1)
   END ;Subroutine
   SUBROUTINE importnewicdevalpharesponses(null)
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(size(getalphas->alpha,5))),
       (dummyt d2  WITH seq = value(size(icdevs->qual,5))),
       dummyt d3
      PLAN (d2
       WHERE (icdevs->qual[d2.seq].icdevname != " "))
       JOIN (d3)
       JOIN (d1
       WHERE (getalphas->alpha[d1.seq].source_string=icdevs->qual[d2.seq].icdevname)
        AND (getalphas->alpha[d1.seq].result_value=cnvtreal(icdevs->qual[d2.seq].icdeviceid)))
      HEAD REPORT
       cnt1 = 0, stat = alterlist(cpsimpnomenrequest->list_0,10)
      DETAIL
       cnt1 = (cnt1+ 1)
       IF (mod(cnt1,10)=1
        AND cnt1 != 1)
        stat = alterlist(cpsimpnomenrequest->list_0,(cnt1+ 9))
       ENDIF
       cpsimpnomenrequest->list_0[cnt1].principle_type_mean = "ALPHA RESPONSE", cpsimpnomenrequest->
       list_0[cnt1].contributor_system_mean = "POWERCHART", cpsimpnomenrequest->list_0[cnt1].
       source_string = icdevs->qual[d2.seq].icdevname,
       cpsimpnomenrequest->list_0[cnt1].source_identifier = " ", cpsimpnomenrequest->list_0[cnt1].
       string_identifier = " ", cpsimpnomenrequest->list_0[cnt1].string_status_mean = " ",
       cpsimpnomenrequest->list_0[cnt1].term_identifier = "0", cpsimpnomenrequest->list_0[cnt1].
       term_source_mean = " ", cpsimpnomenrequest->list_0[cnt1].language_mean = "ENG",
       cpsimpnomenrequest->list_0[cnt1].data_status_mean = "AUTH", cpsimpnomenrequest->list_0[cnt1].
       short_string = icdevs->qual[d2.seq].icdevname, cpsimpnomenrequest->list_0[cnt1].mnemonic =
       substring(0,25,icdevs->qual[d2.seq].icdevname),
       cpsimpnomenrequest->list_0[cnt1].concept_identifier = " ", cpsimpnomenrequest->list_0[cnt1].
       concept_source_mean = " ", cpsimpnomenrequest->list_0[cnt1].string_source_mean = "CERNER",
       cpsimpnomenrequest->list_0[cnt1].source_vocabulary_mean = "PTCARE", cpsimpnomenrequest->
       list_0[cnt1].beg_effective_dt_tm = format(curdate,"DD-MMM-YYYY;;D"), cpsimpnomenrequest->
       list_0[cnt1].version = "2003.05",
       cpsimpnomenrequest->list_0[cnt1].vocab_axis_mean = " ", cpsimpnomenrequest->list_0[cnt1].
       primary_vterm_ind = "0", icdevs->qual[d2.seq].newarresponse = 1
      FOOT REPORT
       stat = alterlist(cpsimpnomenrequest->list_0,cnt1)
      WITH nocounter, outerjoin = d3, dontexist
     ;end select
     CALL echorecord(cpsimpnomenrequest)
     IF (size(cpsimpnomenrequest->list_0,5)=0)
      CALL cv_log_message("There are no new nomenclatures to import.")
     ELSE
      CALL cv_log_message("Entering cps_import_nomenclature.prg")
      EXECUTE cps_import_nomenclature  WITH replace("REQUESTIN","CPSIMPNOMENREQUEST")
      CALL cv_log_message("Leaving cps_import_nomenclature.prg")
     ENDIF
     SET cur_list_size = size(icdevs->qual,5)
     SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
     SET new_list_size = (loop_cnt * batch_size)
     SET stat = alterlist(icdevs->qual,new_list_size)
     SET nstart = 1
     FOR (idx = (cur_list_size+ 1) TO new_list_size)
      SET icdevs->qual[idx].icdevname = icdevs->qual[cur_list_size].icdevname
      SET icdevs->qual[idx].nomenclature_id = icdevs->qual[cur_list_size].nomenclature_id
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(loop_cnt)),
       nomenclature n
      PLAN (d1
       WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
       JOIN (n
       WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),n.source_string,icdevs->qual[idx].icdevname
        )
        AND n.source_string > " ")
      HEAD REPORT
       num1 = 0
      DETAIL
       index = locateval(num1,1,cur_list_size,n.source_string,icdevs->qual[num1].icdevname), icdevs->
       qual[index].nomenclature_id = n.nomenclature_id
      WITH nocounter
     ;end select
     SET stat = alterlist(icdevs->qual,cur_list_size)
     INSERT  FROM alpha_responses ar,
       (dummyt d  WITH seq = value(size(icdevs->qual,5)))
      SET ar.result_value = cnvtreal(icdevs->qual[d.seq].icdeviceid), ar.nomenclature_id = icdevs->
       qual[d.seq].nomenclature_id, ar.sequence = icdevs->qual[d.seq].icdeviceid,
       ar.reference_range_factor_id = icdevs->reference_range_factor_id, ar.updt_dt_tm = cnvtdatetime
       (curdate,curtime3), ar.updt_id = reqinfo->updt_id,
       ar.updt_task = reqinfo->updt_task, ar.updt_applctx = reqinfo->updt_applctx, ar.updt_cnt = 0,
       ar.active_ind = 1
      PLAN (d
       WHERE (icdevs->qual[d.seq].newarresponse=1))
       JOIN (ar)
      WITH nocounter, status(icdevs->qual[d.seq].arinsertsuccess,icdevs->qual[d.seq].arinserterrnum,
       icdevs->qual[d.seq].arinserterrmsg)
     ;end insert
     RETURN(1)
   END ;Subroutine
   SUBROUTINE updateicdevxrefs(null)
     SELECT INTO "nl:"
      FROM cv_xref cx
      WHERE cx.xref_internal_name="ACC03_DEV"
       AND cx.active_ind=1
      DETAIL
       icdevxrefid = cx.xref_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM cv_response cr,
       dummyt d1,
       (dummyt d2  WITH seq = value(size(icdevs->qual,5)))
      PLAN (cr
       WHERE cr.xref_id=icdevxrefid
        AND cr.active_ind=1
        AND cr.field_type="A"
        AND cr.a4=" "
        AND cr.a5=" ")
       JOIN (d1)
       JOIN (d2
       WHERE (icdevs->qual[d2.seq].responsename=cr.response_internal_name)
        AND (icdevs->qual[d2.seq].icdevname=cr.a1)
        AND cnvtstring(icdevs->qual[d2.seq].icdeviceid)=cr.a2
        AND (icdevs->qual[d2.seq].icdevname=cr.a3))
      DETAIL
       CALL cv_log_message("Existing response doesn't match incoming response."),
       CALL cv_log_message(build("Response_internal_name:",cr.response_internal_name)),
       CALL cv_log_message(build("Response_id:",cr.response_id))
      WITH nocounter, outerjoin = d1, dontexist
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d2  WITH seq = value(size(icdevs->qual,5)))
      WHERE (icdevs->qual[d2.seq].responsename > " ")
       AND  NOT ( EXISTS (
      (SELECT
       cr.response_internal_name
       FROM cv_response cr
       WHERE cr.xref_id=icdevxrefid
        AND cr.active_ind=1
        AND cr.field_type="A"
        AND cr.a4=" "
        AND cr.a5=" "
        AND (cr.response_internal_name=icdevs->qual[d2.seq].responsename)
        AND (cr.a1=icdevs->qual[d2.seq].icdevname)
        AND cr.a2=cnvtstring(icdevs->qual[d2.seq].icdeviceid)
        AND (cr.a3=icdevs->qual[d2.seq].icdevname))))
      HEAD REPORT
       cnt1 = 0, cnt2 = 0, stat = alterlist(cvaddfldresponserequest->response_rec,10),
       stat = alterlist(cvimpxrefvalrequest->list_0,10)
      DETAIL
       cnt1 = (cnt1+ 1), cnt2 = (cnt2+ 1)
       IF (mod(cnt1,10)=1
        AND cnt1 != 1)
        stat = alterlist(cvaddfldresponserequest->response_rec,(cnt1+ 9))
       ENDIF
       IF (mod(cnt2,10)=1
        AND cnt2 != 1)
        stat = alterlist(cvimpxrefvalrequest->list_0,(cnt2+ 9))
       ENDIF
       cvaddfldresponserequest->response_rec[cnt1].field_type = "A", cvaddfldresponserequest->
       response_rec[cnt1].response_internal_name = icdevs->qual[d2.seq].responsename,
       cvaddfldresponserequest->response_rec[cnt1].a1 = icdevs->qual[d2.seq].icdevname,
       cvaddfldresponserequest->response_rec[cnt1].a2 = cnvtstring(icdevs->qual[d2.seq].icdeviceid),
       cvaddfldresponserequest->response_rec[cnt1].a3 = icdevs->qual[d2.seq].icdevname,
       cvaddfldresponserequest->response_rec[cnt1].a4 = " ",
       cvaddfldresponserequest->response_rec[cnt1].a5 = " ", cvaddfldresponserequest->response_rec[
       cnt1].xref_id = icdevxrefid, cvaddfldresponserequest->response_rec[cnt1].transaction = 1,
       icdevs->qual[d2.seq].newcvresponse = 1, cvimpxrefvalrequest->list_0[cnt2].xref_internal_name
        = "ACC03_DEV", cvimpxrefvalrequest->list_0[cnt2].response_internal_name = icdevs->qual[d2.seq
       ].responsename,
       cvimpxrefvalrequest->list_0[cnt2].rltnship_flag = "30", cvimpxrefvalrequest->list_0[cnt2].
       reqd_flag = "20", cvimpxrefvalrequest->list_0[cnt2].offset_nbr = icdevs->qual[d2.seq].
       ymdeffectdt,
       cnt2 = (cnt2+ 1)
       IF (mod(cnt2,10)=1
        AND cnt2 != 1)
        stat = alterlist(cvimpxrefvalrequest->list_0,(cnt2+ 9))
       ENDIF
       cvimpxrefvalrequest->list_0[cnt2].xref_internal_name = "ACC03_DEV", cvimpxrefvalrequest->
       list_0[cnt2].response_internal_name = icdevs->qual[d2.seq].responsename, cvimpxrefvalrequest->
       list_0[cnt2].rltnship_flag = "31",
       cvimpxrefvalrequest->list_0[cnt2].reqd_flag = "20", cvimpxrefvalrequest->list_0[cnt2].
       offset_nbr = icdevs->qual[d2.seq].ymdexpiredt
       IF ((icdevs->qual[d2.seq].lenrequired="N"))
        cnt2 = (cnt2+ 1)
        IF (mod(cnt2,10)=1
         AND cnt2 != 1)
         stat = alterlist(cvimpxrefvalrequest->list_0,(cnt2+ 9))
        ENDIF
        cvimpxrefvalrequest->list_0[cnt2].xref_internal_name = "ACC03_DEV", cvimpxrefvalrequest->
        list_0[cnt2].response_internal_name = icdevs->qual[d2.seq].responsename, cvimpxrefvalrequest
        ->list_0[cnt2].child_xref_internal_name = "ACC03_DEVLEN",
        cvimpxrefvalrequest->list_0[cnt2].child_response_internal_name = " ", cvimpxrefvalrequest->
        list_0[cnt2].rltnship_flag = "50", cvimpxrefvalrequest->list_0[cnt2].reqd_flag = "20",
        cvimpxrefvalrequest->list_0[cnt2].offset_nbr = "0"
       ENDIF
       IF ((icdevs->qual[d2.seq].diamrequired="N"))
        cnt2 = (cnt2+ 1)
        IF (mod(cnt2,10)=1
         AND cnt2 != 1)
         stat = alterlist(cvimpxrefvalrequest->list_0,(cnt2+ 9))
        ENDIF
        cvimpxrefvalrequest->list_0[cnt2].xref_internal_name = "ACC03_DEV", cvimpxrefvalrequest->
        list_0[cnt2].response_internal_name = icdevs->qual[d2.seq].responsename, cvimpxrefvalrequest
        ->list_0[cnt2].child_xref_internal_name = "ACC03_DEVDIAM",
        cvimpxrefvalrequest->list_0[cnt2].child_response_internal_name = " ", cvimpxrefvalrequest->
        list_0[cnt2].rltnship_flag = "50", cvimpxrefvalrequest->list_0[cnt2].reqd_flag = "20",
        cvimpxrefvalrequest->list_0[cnt2].offset_nbr = "0"
       ENDIF
       IF ((icdevs->qual[d2.seq].canbeprimary="N"))
        cnt2 = (cnt2+ 1)
        IF (mod(cnt2,10)=1
         AND cnt2 != 1)
         stat = alterlist(cvimpxrefvalrequest->list_0,(cnt2+ 9))
        ENDIF
        cvimpxrefvalrequest->list_0[cnt2].xref_internal_name = "ACC03_DEV", cvimpxrefvalrequest->
        list_0[cnt2].response_internal_name = icdevs->qual[d2.seq].responsename, cvimpxrefvalrequest
        ->list_0[cnt2].child_xref_internal_name = "ACC03_DEVPRIM",
        cvimpxrefvalrequest->list_0[cnt2].child_response_internal_name = " ", cvimpxrefvalrequest->
        list_0[cnt2].rltnship_flag = "50", cvimpxrefvalrequest->list_0[cnt2].reqd_flag = "20",
        cvimpxrefvalrequest->list_0[cnt2].offset_nbr = "0"
       ENDIF
      FOOT REPORT
       stat = alterlist(cvaddfldresponserequest->response_rec,cnt1), stat = alterlist(
        cvimpxrefvalrequest->list_0,cnt2)
      WITH nocounter
     ;end select
     RECORD cvaddfldresponsereply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     RECORD cvimpxrefvalreply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     CALL echorecord(cvaddfldresponserequest)
     IF (size(cvaddfldresponserequest->response_rec,5)=0)
      CALL cv_log_message("There are no new XRef responses to add.")
     ELSE
      CALL cv_log_message("Entering cv_add_fld_response.prg")
      EXECUTE cv_add_fld_response  WITH replace("REQUEST","CVADDFLDRESPONSEREQUEST"), replace("REPLY",
       "CVADDFLDRESPONSEREPLY")
      CALL cv_log_message("Leaving cv_add_fld_response.prg")
      CALL echorecord(cvaddfldresponsereply)
     ENDIF
     IF (size(cvimpxrefvalrequest->list_0,5)=0)
      CALL cv_log_message("No Xref validation entries to import.")
     ELSE
      CALL cv_log_message("Entering cv_import_xref_validation.")
      EXECUTE cv_import_xref_validation  WITH replace("REQUESTIN","CVIMPXREFVALREQUEST"), replace(
       "REPLY","CVIMPXREFVALREPLY")
      CALL cv_log_message("Leaving cv_import_xref_validation.")
      CALL echorecord(cvimpxrefvalreply)
     ENDIF
     RETURN(1)
   END ;Subroutine
   IF (exec_icdev=1)
    CALL cv_log_message("Entering cv_upd_icdev_from_csv")
    CALL determineexistingicdevresponses(null)
    CALL importnewicdevalpharesponses(null)
    CALL updateicdevxrefs(null)
    CALL inserticdevnamevalueprefs(null)
    CALL cv_log_message("Leaving cv_upd_icdev_from_csv")
    RETURN(1)
   ELSE
    CALL cv_log_message("No IC devices to process!")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE processclosuredevs(exec_close)
   FREE RECORD getalphas
   RECORD getalphas(
     1 alpha[*]
       2 sequence = i4
       2 nomenclature_id = f8
       2 source_string = vc
       2 result_value = f8
   )
   FREE RECORD cpsimpnomenrequest
   RECORD cpsimpnomenrequest(
     1 list_0[*]
       2 principle_type_mean = vc
       2 contributor_system_mean = vc
       2 source_string = vc
       2 source_identifier = vc
       2 string_identifier = vc
       2 string_status_mean = vc
       2 term_identifier = vc
       2 term_source_mean = vc
       2 language_mean = vc
       2 data_status_mean = vc
       2 short_string = vc
       2 mnemonic = vc
       2 concept_identifier = vc
       2 concept_source_mean = vc
       2 string_source_mean = vc
       2 source_vocabulary_mean = vc
       2 beg_effective_dt_tm = vc
       2 version = vc
       2 vocab_axis_mean = vc
       2 primary_vterm_ind = vc
   )
   FREE RECORD cvaddfldresponserequest
   RECORD cvaddfldresponserequest(
     1 response_rec[*]
       2 field_type = c1
       2 response_internal_name = vc
       2 a1 = vc
       2 a2 = vc
       2 a3 = vc
       2 a4 = vc
       2 a5 = vc
       2 xref_id = f8
       2 transaction = i2
   )
   FREE RECORD cvimpxrefvalrequest
   RECORD cvimpxrefvalrequest(
     1 list_0[*]
       2 xref_internal_name = vc
       2 response_internal_name = vc
       2 child_xref_internal_name = vc
       2 child_response_internal_name = vc
       2 rltnship_flag = vc
       2 reqd_flag = vc
       2 offset_nbr = vc
   )
   FREE RECORD closuredevs
   RECORD closuredevs(
     1 reference_range_factor_id = f8
     1 closure_dir = f8
     1 qual[*]
       2 effectivedate = c10
       2 expirationdate = c10
       2 closuredevid = i4
       2 closuredevname = vc
       2 responsename = vc
       2 nomenclature_id = f8
       2 arinsertsuccess = i1
       2 arinserterrnum = i4
       2 arinserterrmsg = vc
       2 newarresponse = i1
       2 newcvresponse = i1
       2 ymdeffectdt = c8
       2 ymdexpiredt = c8
       2 pvc_value = vc
   )
   DECLARE cur_list_size = i4 WITH protect
   DECLARE loop_cnt = i4 WITH protect
   DECLARE new_list_size = i4 WITH protect
   DECLARE stat = i4 WITH protect
   DECLARE nstart = i4 WITH protect
   DECLARE batch_size = i4 WITH protect, constant(20)
   DECLARE determineexistingalpharesponses(null) = i2
   DECLARE importnewalpharesponses(null) = i2
   DECLARE updateclosurexrefs(null) = i2
   DECLARE insertclosurenamevalueprefs(null) = i2
   SUBROUTINE determineexistingalpharesponses(null)
     SET stat = alterlist(closuredevs->qual,value(size(cvrequestin->closure,5)))
     FOR (i = 1 TO value(size(cvrequestin->closure,5)))
       SET closuredevs->qual[i].effectivedate = cvrequestin->closure[i].effectivedate
       SET closuredevs->qual[i].closuredevid = cvrequestin->closure[i].closuredevid
       SET closuredevs->qual[i].closuredevname = cvrequestin->closure[i].closuredevname
       SET closuredevs->qual[i].responsename = build("ACC03_CLSDVID_",cvrequestin->closure[i].
        closuredevname)
       SET closuredevs->qual[i].ymdeffectdt = format(cnvtdate2(cvrequestin->closure[i].effectivedate,
         "MM/DD/YYYY"),"YYYYMMDD;;D")
       IF ((cvrequestin->closure[i].expirationdate != null))
        SET closuredevs->qual[i].ymdexpiredt = format(cnvtdate2(cvrequestin->closure[i].
          expirationdate,"MM/DD/YYYY"),"YYYYMMDD;;D")
        SET closuredevs->qual[i].expirationdate = cvrequestin->closure[i].expirationdate
       ELSE
        SET closuredevs->qual[i].ymdexpiredt = format(cnvtdatetime("31-DEC-2100"),"YYYYMMDD;;D")
        SET closuredevs->qual[i].expirationdate = format(cnvtdatetime("31-DEC-2100"),"MM/DD/YYYY;;D")
       ENDIF
       SET closuredevs->qual[i].pvc_value = build("DTA:1,ORDER:",closuredevs->qual[i].closuredevid,
        ",DATED:",closuredevs->qual[i].ymdeffectdt,",",
        closuredevs->qual[i].ymdexpiredt)
     ENDFOR
     SET closuredta = uar_get_code_by("MEANING",cs_dta,nullterm(closure_dta))
     IF (closuredta < 1)
      CALL scriptfailure("Closure Device ID DTA doesn't exist (AC03CLSDVID)")
     ENDIF
     SELECT INTO "nl:"
      FROM reference_range_factor r
      WHERE r.task_assay_cd=closuredta
       AND r.active_ind=1
       AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND r.reference_range_factor_id > 0
      DETAIL
       closuredevs->reference_range_factor_id = r.reference_range_factor_id
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM alpha_responses ar,
       nomenclature n
      PLAN (ar
       WHERE (ar.reference_range_factor_id=closuredevs->reference_range_factor_id)
        AND ar.reference_range_factor_id > 0
        AND ar.nomenclature_id > 0
        AND ar.active_ind=1
        AND ar.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ar.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (n
       WHERE n.nomenclature_id=ar.nomenclature_id
        AND n.nomenclature_id > 0
        AND n.source_string != " "
        AND n.active_ind=1
        AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
      ORDER BY ar.sequence
      HEAD REPORT
       count1 = 0, stat = alterlist(getalphas->alpha,10)
      DETAIL
       count1 = (count1+ 1)
       IF (mod(count1,10)=1
        AND count1 != 1)
        stat = alterlist(getalphas->alpha,(count1+ 9))
       ENDIF
       getalphas->alpha[count1].sequence = ar.sequence, getalphas->alpha[count1].nomenclature_id = ar
       .nomenclature_id, getalphas->alpha[count1].source_string = trim(n.source_string),
       getalphas->alpha[count1].result_value = ar.result_value
      FOOT REPORT
       stat = alterlist(getalphas->alpha,count1)
      WITH nocounter
     ;end select
     IF (size(getalphas->alpha,5) > size(cvrequestin->closure,5))
      CALL cv_log_message("Number of closure devices in system is greater than number in csv.")
      SET errcnt = (errcnt+ 1)
      SET stat = alterlist(cvreply->lines,errcnt)
      SET cvreply->lines[errcnt].errmsg =
      "Number of closure devices in system is greater than number in csv."
      IF ((cvrequestin->force_update=0))
       CALL cv_log_message("Since force_update=0, failing script with no changes to database.")
       SET errcnt = (errcnt+ 1)
       SET stat = alterlist(cvreply->lines,errcnt)
       SET cvreply->lines[errcnt].errmsg =
       "Since force_update=0, failing script with no changes to database."
       GO TO exit_script
      ENDIF
     ENDIF
     DECLARE skipitem = i2 WITH protect
     FOR (cnt = 1 TO size(getalphas->alpha,5))
      SET skipitem = 0
      IF ((getalphas->alpha[cnt].nomenclature_id > 0.0))
       FOR (cnt1 = 1 TO size(closuredevs->qual,5))
         IF (cnvtint(getalphas->alpha[cnt].result_value)=cnvtint(closuredevs->qual[cnt1].closuredevid
          )
          AND trim(getalphas->alpha[cnt].source_string,3)=trim(closuredevs->qual[cnt1].closuredevname,
          3))
          SET skipitem = 1
         ENDIF
       ENDFOR
       IF (skipitem != 1)
        CALL cv_log_message("Existing response does not match incoming response.")
        CALL cv_log_message(build("Nomenclature_id:",getalphas->alpha[cnt].nomenclature_id))
        CALL cv_log_message(build("Source_String:",nullterm(getalphas->alpha[cnt].source_string)))
        SET errcnt = (errcnt+ 3)
        SET stat = alterlist(cvreply->lines,errcnt)
        SET cvreply->lines[(errcnt - 2)].errmsg =
        "Existing response does not match incoming response."
        SET cvreply->lines[(errcnt - 1)].errmsg = build("Nomenclature_id:",getalphas->alpha[cnt].
         nomenclature_id)
        SET cvreply->lines[errcnt].errmsg = build("Source_String:",nullterm(getalphas->alpha[cnt].
          source_string))
       ENDIF
      ENDIF
     ENDFOR
     RETURN(1)
   END ;Subroutine
   SUBROUTINE importnewalpharesponses(null)
     SET cnt1 = 0
     FOR (forcnt = 1 TO size(closuredevs->qual,5))
       SET skipitem = 0
       FOR (forcnt2 = 1 TO size(getalphas->alpha,5))
         IF ((getalphas->alpha[forcnt2].source_string=closuredevs->qual[forcnt].closuredevname)
          AND (getalphas->alpha[forcnt2].result_value=closuredevs->qual[forcnt].closuredevid))
          SET skipitem = 1
         ENDIF
       ENDFOR
       IF (skipitem != 1)
        SET cnt1 = (cnt1+ 1)
        IF (mod(cnt1,10)=1)
         SET stat = alterlist(cpsimpnomenrequest->list_0,(cnt1+ 9))
        ENDIF
        SET cpsimpnomenrequest->list_0[cnt1].principle_type_mean = "ALPHA RESPON"
        SET cpsimpnomenrequest->list_0[cnt1].contributor_system_mean = "POWERCHART"
        SET cpsimpnomenrequest->list_0[cnt1].source_string = closuredevs->qual[forcnt].closuredevname
        SET cpsimpnomenrequest->list_0[cnt1].source_identifier = " "
        SET cpsimpnomenrequest->list_0[cnt1].string_identifier = " "
        SET cpsimpnomenrequest->list_0[cnt1].string_status_mean = " "
        SET cpsimpnomenrequest->list_0[cnt1].term_identifier = "0"
        SET cpsimpnomenrequest->list_0[cnt1].term_source_mean = " "
        SET cpsimpnomenrequest->list_0[cnt1].language_mean = "ENG"
        SET cpsimpnomenrequest->list_0[cnt1].data_status_mean = "AUTH"
        SET cpsimpnomenrequest->list_0[cnt1].short_string = closuredevs->qual[forcnt].closuredevname
        SET cpsimpnomenrequest->list_0[cnt1].mnemonic = substring(0,25,closuredevs->qual[forcnt].
         closuredevname)
        SET cpsimpnomenrequest->list_0[cnt1].concept_identifier = " "
        SET cpsimpnomenrequest->list_0[cnt1].concept_source_mean = " "
        SET cpsimpnomenrequest->list_0[cnt1].string_source_mean = "CERNER"
        SET cpsimpnomenrequest->list_0[cnt1].source_vocabulary_mean = "PTCARE"
        SET cpsimpnomenrequest->list_0[cnt1].beg_effective_dt_tm = format(cnvtdatetime(curdate,
          curtime3),"DD-MMM-YYYY;;D")
        SET cpsimpnomenrequest->list_0[cnt1].version = "2003.05"
        SET cpsimpnomenrequest->list_0[cnt1].vocab_axis_mean = " "
        SET cpsimpnomenrequest->list_0[cnt1].primary_vterm_ind = "0"
        SET closuredevs->qual[forcnt].newarresponse = 1
       ENDIF
     ENDFOR
     SET stat = alterlist(cpsimpnomenrequest->list_0,cnt1)
     IF (size(cpsimpnomenrequest->list_0,5)=0)
      CALL cv_log_message("No nomenclatures to import.")
      SET errcnt = (errcnt+ 1)
      SET stat = alterlist(cvreply->lines,errcnt)
      SET cvreply->lines[errcnt].errmsg = "No nomenclatures to import."
     ELSE
      CALL cv_log_message("Entering cps_import_nomenclature.prg!")
      CALL echorecord(cpsimpnomenrequest)
      EXECUTE cps_import_nomenclature  WITH replace("REQUESTIN","CPSIMPNOMENREQUEST")
      CALL cv_log_message("Leaving cps_import_nomenclature.prg!")
     ENDIF
     FREE RECORD cpsimpnomenrequest
     SET cur_list_size = size(closuredevs->qual,5)
     SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
     SET new_list_size = (loop_cnt * batch_size)
     SET stat = alterlist(closuredevs->qual,new_list_size)
     SET nstart = 1
     FOR (idx = (cur_list_size+ 1) TO new_list_size)
      SET closuredevs->qual[idx].closuredevname = closuredevs->qual[cur_list_size].closuredevname
      SET closuredevs->qual[idx].nomenclature_id = closuredevs->qual[cur_list_size].nomenclature_id
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(loop_cnt)),
       nomenclature n
      PLAN (d1
       WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
       JOIN (n
       WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),n.source_string,closuredevs->qual[idx].
        closuredevname)
        AND n.source_string > " ")
      HEAD REPORT
       num1 = 0
      DETAIL
       index = locateval(num1,1,cur_list_size,n.source_string,closuredevs->qual[num1].closuredevname),
       closuredevs->qual[index].nomenclature_id = n.nomenclature_id
      WITH nocounter
     ;end select
     SET stat = alterlist(closuredevs->qual,cur_list_size)
     INSERT  FROM alpha_responses ar,
       (dummyt d  WITH seq = value(size(closuredevs->qual,5)))
      SET ar.result_value = closuredevs->qual[d.seq].closuredevid, ar.nomenclature_id = closuredevs->
       qual[d.seq].nomenclature_id, ar.sequence = closuredevs->qual[d.seq].closuredevid,
       ar.reference_range_factor_id = closuredevs->reference_range_factor_id, ar.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), ar.updt_id = reqinfo->updt_id,
       ar.updt_task = reqinfo->updt_task, ar.updt_applctx = reqinfo->updt_applctx, ar.updt_cnt = 0,
       ar.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ar.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100"), ar.active_status_prsnl_id = reqinfo->updt_id,
       ar.result_process_cd = 0, ar.active_status_cd = reqdata->active_status_cd, ar
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       ar.active_ind = 1, ar.description = closuredevs->qual[d.seq].closuredevname
      PLAN (d
       WHERE (closuredevs->qual[d.seq].newarresponse=1))
       JOIN (ar)
      WITH nocounter, status(closuredevs->qual[d.seq].arinsertsuccess,closuredevs->qual[d.seq].
       arinserterrnum,closuredevs->qual[d.seq].arinserterrmsg)
     ;end insert
     CALL echorecord(closuredevs)
     RETURN(1)
   END ;Subroutine
   SUBROUTINE updateclosurexrefs(null)
     SELECT INTO "nl:"
      FROM cv_xref cx
      WHERE cx.xref_internal_name="ACC03_CLSDVID"
       AND cx.active_ind=1
       AND cx.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND cx.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      DETAIL
       clsdvxrefid = cx.xref_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL scriptfailure("No Closure Device in XREF table. Can't continue.")
     ENDIF
     SELECT INTO "nl:"
      FROM cv_response cr,
       dummyt d1,
       (dummyt d2  WITH seq = value(size(closuredevs->qual,5)))
      PLAN (cr
       WHERE cr.xref_id=clsdvxrefid
        AND cr.active_ind=1
        AND cr.field_type="A"
        AND cr.a4=" "
        AND cr.a5=" ")
       JOIN (d1)
       JOIN (d2
       WHERE (closuredevs->qual[d2.seq].responsename=cr.response_internal_name)
        AND trim(closuredevs->qual[d2.seq].closuredevname)=cr.a1
        AND cnvtstring(closuredevs->qual[d2.seq].closuredevid)=cr.a2
        AND trim(closuredevs->qual[d2.seq].closuredevname)=cr.a3)
      DETAIL
       CALL cv_log_message("Existing response doesn't match incoming response."),
       CALL cv_log_message(build("Response_internal_name:",cr.response_internal_name)),
       CALL cv_log_message(build("Response_id:",cr.response_id))
      WITH nocounter, outerjoin = d1, dontexist
     ;end select
     SELECT INTO "nl:"
      FROM cv_response cr,
       dummyt d1,
       (dummyt d2  WITH seq = value(size(closuredevs->qual,5)))
      PLAN (d2
       WHERE (closuredevs->qual[d2.seq].closuredevname != " "))
       JOIN (d1)
       JOIN (cr
       WHERE cr.xref_id=clsdvxrefid
        AND cr.active_ind=1
        AND cr.field_type="A"
        AND cr.a4=" "
        AND cr.a5=" "
        AND (cr.response_internal_name=closuredevs->qual[d2.seq].responsename)
        AND cr.a1=trim(closuredevs->qual[d2.seq].closuredevname)
        AND cr.a2=cnvtstring(closuredevs->qual[d2.seq].closuredevid)
        AND cr.a3=trim(closuredevs->qual[d2.seq].closuredevname))
      HEAD REPORT
       cnt1 = 0, stat = alterlist(cvaddfldresponserequest->response_rec,10), stat = alterlist(
        cvimpxrefvalrequest->list_0,20)
      DETAIL
       cnt1 = (cnt1+ 1)
       IF (mod(cnt1,10)=1
        AND cnt1 != 1)
        stat = alterlist(cvaddfldresponserequest->response_rec,(cnt1+ 9)), stat = alterlist(
         cvimpxrefvalrequest->list_0,((2 * cnt1)+ 18))
       ENDIF
       cvaddfldresponserequest->response_rec[cnt1].field_type = "A", cvaddfldresponserequest->
       response_rec[cnt1].response_internal_name = closuredevs->qual[d2.seq].responsename,
       cvaddfldresponserequest->response_rec[cnt1].a1 = trim(closuredevs->qual[d2.seq].closuredevname
        ),
       cvaddfldresponserequest->response_rec[cnt1].a2 = cnvtstring(closuredevs->qual[d2.seq].
        closuredevid), cvaddfldresponserequest->response_rec[cnt1].a3 = trim(closuredevs->qual[d2.seq
        ].closuredevname), cvaddfldresponserequest->response_rec[cnt1].a4 = " ",
       cvaddfldresponserequest->response_rec[cnt1].a5 = " ", cvaddfldresponserequest->response_rec[
       cnt1].xref_id = clsdvxrefid, cvaddfldresponserequest->response_rec[cnt1].transaction = 1,
       closuredevs->qual[d2.seq].newcvresponse = 1, cvimpxrefvalrequest->list_0[((cnt1 * 2) - 1)].
       xref_internal_name = "ACC03_CLSDVID", cvimpxrefvalrequest->list_0[((cnt1 * 2) - 1)].
       response_internal_name = closuredevs->qual[d2.seq].responsename,
       cvimpxrefvalrequest->list_0[((cnt1 * 2) - 1)].rltnship_flag = "30", cvimpxrefvalrequest->
       list_0[((cnt1 * 2) - 1)].reqd_flag = "20", cvimpxrefvalrequest->list_0[((cnt1 * 2) - 1)].
       offset_nbr = closuredevs->qual[d2.seq].ymdeffectdt,
       cvimpxrefvalrequest->list_0[(cnt1 * 2)].xref_internal_name = "ACC03_CLSDVID",
       cvimpxrefvalrequest->list_0[(cnt1 * 2)].response_internal_name = closuredevs->qual[d2.seq].
       responsename, cvimpxrefvalrequest->list_0[(cnt1 * 2)].rltnship_flag = "31",
       cvimpxrefvalrequest->list_0[(cnt1 * 2)].reqd_flag = "20", cvimpxrefvalrequest->list_0[(cnt1 *
       2)].offset_nbr = closuredevs->qual[d2.seq].ymdexpiredt
      FOOT REPORT
       stat = alterlist(cvaddfldresponserequest->response_rec,cnt1), stat = alterlist(
        cvimpxrefvalrequest->list_0,(2 * cnt1))
      WITH nocounter, outerjoin = d1, dontexist
     ;end select
     RECORD cvaddfldresponsereply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     RECORD cvimpxrefvalreply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     IF (size(cvaddfldresponserequest->response_rec,5)=0)
      CALL cv_log_message("Nothing to add to response table.")
     ELSE
      CALL cv_log_message("Entering cv_add_fld_response.prg!")
      CALL echorecord(cvaddfldresponserequest)
      EXECUTE cv_add_fld_response  WITH replace("REQUEST","CVADDFLDRESPONSEREQUEST"), replace("REPLY",
       "CVADDFLDRESPONSEREPLY")
      CALL echorecord(cvaddfldresponsereply)
      CALL cv_log_message("Leaving cv_add_fld_response.prg!")
     ENDIF
     IF (size(cvimpxrefvalrequest->list_0,5)=0)
      CALL cv_log_message("Nothing to add to validation table.")
     ELSE
      CALL cv_log_message("Entering cv_import_xref_validation.prg!")
      CALL echorecord(cvimpxrefvalrequest)
      EXECUTE cv_import_xref_validation  WITH replace("REQUESTIN","CVIMPXREFVALREQUEST"), replace(
       "REPLY","CVIMPXREFVALREPLY")
      CALL echorecord(cvimpxrefvalreply)
      CALL cv_log_message("Leaving cv_import_xref_validation.prg!")
     ENDIF
     FREE RECORD cvimpxrefvalrequest
     FREE RECORD cvaddfldresponserequest
     RETURN(1)
   END ;Subroutine
   SUBROUTINE insertclosurenamevalueprefs(null)
     SELECT INTO "nl:"
      FROM dcp_input_ref dir,
       dcp_section_ref dsr,
       dcp_forms_def dfd,
       dcp_forms_ref dfr
      PLAN (dfr
       WHERE dfr.active_ind=1
        AND dfr.dcp_form_instance_id > 0
        AND dfr.dcp_forms_ref_id=accv3_dfr_labvisit
        AND dfr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dfr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (dfd
       WHERE dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id
        AND dfd.active_ind=1
        AND dfd.dcp_forms_def_id > 0
        AND dfd.dcp_section_ref_id > 0
        AND dfd.dcp_form_instance_id=dfr.dcp_form_instance_id)
       JOIN (dsr
       WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
        AND dsr.active_ind=1
        AND dsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dsr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        AND dsr.dcp_section_ref_id > 0
        AND dsr.dcp_section_instance_id > 0)
       JOIN (dir
       WHERE dir.dcp_section_ref_id=dsr.dcp_section_ref_id
        AND dir.active_ind=1
        AND dir.dcp_section_instance_id=dsr.dcp_section_instance_id
        AND dir.description="CLOSURE_DEV"
        AND dir.dcp_input_ref_id > 0)
      DETAIL
       closuredevs->closure_dir = dir.dcp_input_ref_id
      WITH nocounter
     ;end select
     IF ((closuredevs->closure_dir=0))
      EXECUTE cv_log_message "No parent_entity_id found for ClosureDevs"
      RETURN
     ENDIF
     DELETE  FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=closuredevs->closure_dir)
       AND ((nvp.pvc_name=trim("dta_radio")) OR (nvp.pvc_name=trim("dta_response")))
      WITH nocounter
     ;end delete
     SET clsdvsuc = uar_get_code_by("MEANING",14003,"AC03CLSDVSUC")
     IF (clsdvsuc < 1)
      CALL scriptfailure("Closure Device Success DTA doesn't exist (AC03CLSDVSUC)")
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=closuredevs->closure_dir)
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND nvp.merge_id=closuredta
       AND pvc_name="discrete_task_assay"
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_name =
        "DCP_INPUT_REF", nvp.parent_entity_id = closuredevs->closure_dir,
        nvp.pvc_name = "discrete_task_assay", nvp.pvc_value = "0;50", nvp.merge_name =
        "DISCRETE_TASK_ASSAY",
        nvp.merge_id = closuredta, nvp.sequence = 1, nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND (nvp.parent_entity_id=closuredevs->closure_dir)
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND nvp.merge_id=clsdvsuc
       AND pvc_name="discrete_task_assay"
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_name =
        "DCP_INPUT_REF", nvp.parent_entity_id = closuredevs->closure_dir,
        nvp.pvc_name = "discrete_task_assay", nvp.pvc_value = "0;10", nvp.merge_name =
        "DISCRETE_TASK_ASSAY",
        nvp.merge_id = clsdvsuc, nvp.sequence = 2, nvp.active_ind = 1,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp
        .updt_task = reqinfo->updt_task,
        nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
     INSERT  FROM name_value_prefs nvp
      SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_name =
       "DCP_INPUT_REF", nvp.parent_entity_id = closuredevs->closure_dir,
       nvp.pvc_name = "dta_radio", nvp.pvc_value = "DTA:2", nvp.merge_name = "NOMENCLATURE",
       nvp.merge_id = yesnomen, nvp.sequence = 3, nvp.active_ind = 1,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
        = reqinfo->updt_task,
       nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
      WITH nocounter
     ;end insert
     INSERT  FROM name_value_prefs nvp,
       (dummyt d  WITH seq = value(size(closuredevs->qual,5)))
      SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_name =
       "DCP_INPUT_REF", nvp.parent_entity_id = closuredevs->closure_dir,
       nvp.pvc_name = "dta_response", nvp.pvc_value = closuredevs->qual[d.seq].pvc_value, nvp
       .merge_name = "NOMENCLATURE",
       nvp.merge_id = closuredevs->qual[d.seq].nomenclature_id, nvp.sequence = (3+ closuredevs->qual[
       d.seq].closuredevid), nvp.active_ind = 1,
       nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->updt_id, nvp.updt_task
        = reqinfo->updt_task,
       nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_cnt = 0
      PLAN (d)
       JOIN (nvp)
      WITH nocounter
     ;end insert
     RETURN(1)
   END ;Subroutine
   IF (exec_close=1)
    CALL cv_log_message("Entering cv_upd_closure_from_csv")
    CALL determineexistingalpharesponses(null)
    CALL importnewalpharesponses(null)
    CALL updateclosurexrefs(null)
    CALL insertclosurenamevalueprefs(null)
    CALL cv_log_message("Leaving cv_upd_closure_from_csv")
    RETURN(1)
   ELSE
    CALL cv_log_message("No closure devices to process!")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE processmeds(exec_med)
   FREE RECORD internalmed
   RECORD internalmed(
     1 admit_dir = f8
     1 disch_dir = f8
     1 qual[*]
       2 effectivedate = c10
       2 expirationdate = c10
       2 medid = i4
       2 timing = c1
       2 medcategory = vc
       2 medname = vc
       2 update_ind = i2
       2 cdf_name = vc
       2 xref_name = vc
       2 task_assay_cd = f8
       2 xref_id = f8
       2 pvc_value = vc
       2 admit_disch_id = f8
       2 regfldname = vc
       2 dtamnemonic = vc
       2 dtadescription = vc
       2 medorder = i4
       2 upd_xref_stat = i1
   )
   FREE RECORD cvimpdatasetrequest
   RECORD cvimpdatasetrequest(
     1 list_0[*]
       2 datasetname = vc
       2 internalfieldname_xref = vc
       2 internalfieldname_res = vc
       2 registryfieldname = vc
       2 registryfieldshortname = vc
       2 registryfieldcodename = vc
       2 cdf_meaning = c12
       2 cernsourcetablename = c30
       2 cernsourcefieldname = c30
       2 fieldtype = c1
       2 a1 = vc
       2 a2 = vc
       2 a3 = vc
       2 a4 = vc
       2 a5 = vc
       2 eventtype = vc
       2 subeventtype = vc
       2 grouptype = vc
       2 fieldtypemean = vc
       2 validationscript = vc
       2 aliaspoolmean = vc
       2 reqdflag = vc
       2 displayfldind = vc
       2 casedatemean = vc
       2 expiration_dt_tm = vc
       2 effective_dt_tm = vc
       2 audit_flag = vc
       2 element_nbr = vc
   )
   FREE RECORD cvimpxrefvalrequest
   RECORD cvimpxrefvalrequest(
     1 list_0[*]
       2 xref_internal_name = vc
       2 response_internal_name = vc
       2 child_xref_internal_name = vc
       2 child_response_internal_name = vc
       2 rltnship_flag = vc
       2 reqd_flag = vc
       2 offset_nbr = vc
   )
   DECLARE cur_list_size = i4 WITH protect
   DECLARE loop_cnt = i4 WITH protect
   DECLARE batch_size = i4 WITH protect, constant(20)
   DECLARE new_list_size = i4 WITH protect
   DECLARE stat = i4 WITH protect
   DECLARE nstart = i4 WITH protect
   DECLARE med_element_nbr = vc WITH protect, constant("352")
   DECLARE determineexistingmedications(null) = i2
   DECLARE medicationsdtaexists(null) = i2
   DECLARE medicationnamevalueprefs(null) = i2
   DECLARE medicationxrefexists(null) = i2
   DECLARE medicationxrefvalidations(null) = i2
   SUBROUTINE medicationxrefvalidations(null)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(size(internalmed->qual,5)))
      PLAN (d
       WHERE (internalmed->qual[d.seq].update_ind=0)
        AND (internalmed->qual[d.seq].timing="D"))
      HEAD REPORT
       stat = alterlist(cvimpxrefvalrequest->list_0,10), cnt_val = 0
      DETAIL
       cnt_val = (cnt_val+ 1)
       IF (mod(cnt_val,10)=1
        AND cnt_val != 1)
        stat = alterlist(cvimpxrefvalrequest->list_0,(cnt_val+ 9))
       ENDIF
       cvimpxrefvalrequest->list_0[cnt_val].xref_internal_name = "ACC03_MTDCSTAT",
       cvimpxrefvalrequest->list_0[cnt_val].response_internal_name = "ACC03_MTDCSTAT_DEAD",
       cvimpxrefvalrequest->list_0[cnt_val].child_xref_internal_name = internalmed->qual[d.seq].
       xref_name,
       cvimpxrefvalrequest->list_0[cnt_val].rltnship_flag = "50", cvimpxrefvalrequest->list_0[cnt_val
       ].reqd_flag = "20"
      FOOT REPORT
       stat = alterlist(cvimpxrefvalrequest->list_0,cnt_val)
      WITH nocounter
     ;end select
     RECORD cvimpxrefvalreply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     IF (size(cvimpxrefvalrequest->list_0,5)=0)
      CALL cv_log_message("Nothing to add to validation table.")
     ELSE
      CALL cv_log_message("Entering cv_import_xref_validation.prg!")
      CALL echorecord(cvimpxrefvalrequest)
      EXECUTE cv_import_xref_validation  WITH replace("REQUESTIN","CVIMPXREFVALREQUEST"), replace(
       "REPLY","CVIMPXREFVALREPLY")
      CALL echorecord(cvimpxrefvalreply)
      CALL cv_log_message("Leaving cv_import_xref_validation.prg!")
     ENDIF
     FREE RECORD cvimpxrefvalrequest
     FREE RECORD cvimpxrefvalreply
     RETURN(1)
   END ;Subroutine
   SUBROUTINE medicationxrefexists(null)
     SELECT INTO "nl:"
      cd.alias_pool_mean
      FROM cv_dataset cd
      WHERE cd.dataset_id=accv3_dsid
       AND cd.active_ind=1
      HEAD REPORT
       ds_cnt = 0
      DETAIL
       ds_cnt = (ds_cnt+ 1), aliaspoolmean = trim(cd.alias_pool_mean), validationscript = trim(cd
        .validation_script),
       casedatemean = trim(cd.case_date_mean), datasetdisp = trim(cd.display_name)
      WITH nocounter
     ;end select
     IF (ds_cnt > 1)
      CALL cv_log_message("More than one ACCv3 dataset found!")
      SET errcnt = (errcnt+ 1)
      SET stat = alterlist(cvreply->lines,errcnt)
      SET cvreply->lines[errcnt].errmsg = "More than one ACCv3 dataset found!"
      SET reply->status_data.status = "S"
      GO TO exit_script
     ENDIF
     SET cur_list_size = size(internalmed->qual,5)
     SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
     SET new_list_size = (loop_cnt * batch_size)
     SET stat = alterlist(internalmed->qual,new_list_size)
     SET nstart = 1
     FOR (idx = (cur_list_size+ 1) TO new_list_size)
      SET internalmed->qual[idx].xref_name = internalmed->qual[cur_list_size].xref_name
      SET internalmed->qual[idx].medname = internalmed->qual[cur_list_size].medname
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = value(loop_cnt)),
       cv_xref cx
      PLAN (d1
       WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
       JOIN (cx
       WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cx.xref_internal_name,internalmed->qual[idx
        ].xref_name))
      HEAD REPORT
       num1 = 0
      DETAIL
       index = locateval(num1,1,cur_list_size,cx.xref_internal_name,internalmed->qual[num1].xref_name
        ),
       CALL cv_log_message(build2(internalmed->qual[index].xref_name," already in CV_XREF"))
      FOOT REPORT
       stat = alterlist(internalmed->qual,cur_list_size)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      begrange = build(xref_prefix,"000"), endrange = build(xref_prefix,"999")
      FROM (dummyt d1  WITH seq = value(size(internalmed->qual,5)))
      WHERE (internalmed->qual[d1.seq].medname > " ")
       AND  NOT ( EXISTS (
      (SELECT
       cx.xref_internal_name
       FROM cv_xref cx
       WHERE cx.xref_internal_name >= begrange
        AND cx.xref_internal_name <= endrange
        AND (cx.xref_internal_name=internalmed->qual[d1.seq].xref_name))))
      HEAD REPORT
       count1 = 1, stat = alterlist(cvimpdatasetrequest->list_0,1), cvimpdatasetrequest->list_0[
       count1].datasetname = nullterm(dataset_name),
       cvimpdatasetrequest->list_0[count1].internalfieldname_xref = nullterm(datasetdisp),
       cvimpdatasetrequest->list_0[count1].validationscript = nullterm(validationscript),
       cvimpdatasetrequest->list_0[count1].aliaspoolmean = nullterm(aliaspoolmean),
       cvimpdatasetrequest->list_0[count1].casedatemean = nullterm(casedatemean)
      DETAIL
       IF (trim(internalmed->qual[d1.seq].expirationdate)="")
        internalmed->qual[d1.seq].expirationdate = "12/31/2100"
       ENDIF
       count1 = (count1+ 1), stat = alterlist(cvimpdatasetrequest->list_0,(count1+ 5)),
       cvimpdatasetrequest->list_0[count1].datasetname = nullterm(dataset_name),
       cvimpdatasetrequest->list_0[(count1+ 1)].datasetname = nullterm(dataset_name),
       cvimpdatasetrequest->list_0[(count1+ 2)].datasetname = nullterm(dataset_name),
       cvimpdatasetrequest->list_0[(count1+ 3)].datasetname = nullterm(dataset_name),
       cvimpdatasetrequest->list_0[(count1+ 4)].datasetname = nullterm(dataset_name),
       cvimpdatasetrequest->list_0[count1].internalfieldname_xref = internalmed->qual[d1.seq].
       xref_name, cvimpdatasetrequest->list_0[(count1+ 1)].internalfieldname_xref = internalmed->
       qual[d1.seq].xref_name,
       cvimpdatasetrequest->list_0[(count1+ 2)].internalfieldname_xref = internalmed->qual[d1.seq].
       xref_name, cvimpdatasetrequest->list_0[(count1+ 3)].internalfieldname_xref = internalmed->
       qual[d1.seq].xref_name, cvimpdatasetrequest->list_0[(count1+ 4)].internalfieldname_xref =
       internalmed->qual[d1.seq].xref_name,
       cvimpdatasetrequest->list_0[count1].registryfieldname = internalmed->qual[d1.seq].regfldname,
       cvimpdatasetrequest->list_0[(count1+ 1)].registryfieldname = internalmed->qual[d1.seq].
       regfldname, cvimpdatasetrequest->list_0[(count1+ 2)].registryfieldname = internalmed->qual[d1
       .seq].regfldname,
       cvimpdatasetrequest->list_0[(count1+ 3)].registryfieldname = internalmed->qual[d1.seq].
       regfldname, cvimpdatasetrequest->list_0[(count1+ 4)].registryfieldname = internalmed->qual[d1
       .seq].regfldname, cvimpdatasetrequest->list_0[count1].cdf_meaning = internalmed->qual[d1.seq].
       cdf_name,
       cvimpdatasetrequest->list_0[(count1+ 1)].cdf_meaning = internalmed->qual[d1.seq].cdf_name,
       cvimpdatasetrequest->list_0[(count1+ 2)].cdf_meaning = internalmed->qual[d1.seq].cdf_name,
       cvimpdatasetrequest->list_0[(count1+ 3)].cdf_meaning = internalmed->qual[d1.seq].cdf_name,
       cvimpdatasetrequest->list_0[(count1+ 4)].cdf_meaning = internalmed->qual[d1.seq].cdf_name,
       cvimpdatasetrequest->list_0[count1].fieldtype = nullterm(field_type), cvimpdatasetrequest->
       list_0[(count1+ 1)].fieldtype = nullterm(field_type),
       cvimpdatasetrequest->list_0[(count1+ 2)].fieldtype = nullterm(field_type), cvimpdatasetrequest
       ->list_0[(count1+ 3)].fieldtype = nullterm(field_type), cvimpdatasetrequest->list_0[(count1+ 4
       )].fieldtype = nullterm(field_type),
       cvimpdatasetrequest->list_0[count1].effective_dt_tm = internalmed->qual[d1.seq].effectivedate,
       cvimpdatasetrequest->list_0[(count1+ 1)].effective_dt_tm = internalmed->qual[d1.seq].
       effectivedate, cvimpdatasetrequest->list_0[(count1+ 2)].effective_dt_tm = internalmed->qual[d1
       .seq].effectivedate,
       cvimpdatasetrequest->list_0[(count1+ 3)].effective_dt_tm = internalmed->qual[d1.seq].
       effectivedate, cvimpdatasetrequest->list_0[(count1+ 4)].effective_dt_tm = internalmed->qual[d1
       .seq].effectivedate, cvimpdatasetrequest->list_0[count1].expiration_dt_tm = internalmed->qual[
       d1.seq].expirationdate,
       cvimpdatasetrequest->list_0[(count1+ 1)].expiration_dt_tm = internalmed->qual[d1.seq].
       expirationdate, cvimpdatasetrequest->list_0[(count1+ 2)].expiration_dt_tm = internalmed->qual[
       d1.seq].expirationdate, cvimpdatasetrequest->list_0[(count1+ 3)].expiration_dt_tm =
       internalmed->qual[d1.seq].expirationdate,
       cvimpdatasetrequest->list_0[(count1+ 4)].expiration_dt_tm = internalmed->qual[d1.seq].
       expirationdate, cvimpdatasetrequest->list_0[count1].element_nbr = nullterm(med_element_nbr),
       cvimpdatasetrequest->list_0[(count1+ 1)].element_nbr = nullterm(med_element_nbr),
       cvimpdatasetrequest->list_0[(count1+ 2)].element_nbr = nullterm(med_element_nbr),
       cvimpdatasetrequest->list_0[(count1+ 3)].element_nbr = nullterm(med_element_nbr),
       cvimpdatasetrequest->list_0[(count1+ 4)].element_nbr = nullterm(med_element_nbr),
       cvimpdatasetrequest->list_0[count1].internalfieldname_res = build(internalmed->qual[d1.seq].
        xref_name,"_<BLANK>"), cvimpdatasetrequest->list_0[count1].a1 = "<blank>",
       cvimpdatasetrequest->list_0[count1].a2 = "",
       cvimpdatasetrequest->list_0[count1].a3 = "<blank>", cvimpdatasetrequest->list_0[(count1+ 1)].
       internalfieldname_res = build(internalmed->qual[d1.seq].xref_name,"_YES"), cvimpdatasetrequest
       ->list_0[(count1+ 1)].a1 = "Yes",
       cvimpdatasetrequest->list_0[(count1+ 1)].a2 = "1", cvimpdatasetrequest->list_0[(count1+ 1)].a3
        = "Yes", cvimpdatasetrequest->list_0[(count1+ 2)].internalfieldname_res = build(internalmed->
        qual[d1.seq].xref_name,"_NO"),
       cvimpdatasetrequest->list_0[(count1+ 2)].a1 = "No", cvimpdatasetrequest->list_0[(count1+ 2)].
       a2 = "2", cvimpdatasetrequest->list_0[(count1+ 2)].a3 = "No",
       cvimpdatasetrequest->list_0[(count1+ 3)].internalfieldname_res = build(internalmed->qual[d1
        .seq].xref_name,"_BLINDED"), cvimpdatasetrequest->list_0[(count1+ 3)].a1 = "Blinded",
       cvimpdatasetrequest->list_0[(count1+ 3)].a2 = "4",
       cvimpdatasetrequest->list_0[(count1+ 3)].a3 = "Blinded", cvimpdatasetrequest->list_0[(count1+
       4)].internalfieldname_res = build(internalmed->qual[d1.seq].xref_name,"_CONTRAINDICATED"),
       cvimpdatasetrequest->list_0[(count1+ 4)].a1 = "Contraindicated",
       cvimpdatasetrequest->list_0[(count1+ 4)].a2 = "3", cvimpdatasetrequest->list_0[(count1+ 4)].a3
        = "Contraindicated", cvimpdatasetrequest->list_0[count1].eventtype = nullterm(case_et),
       cvimpdatasetrequest->list_0[(count1+ 1)].eventtype = nullterm(case_et), cvimpdatasetrequest->
       list_0[(count1+ 2)].eventtype = nullterm(case_et), cvimpdatasetrequest->list_0[(count1+ 3)].
       eventtype = nullterm(case_et),
       cvimpdatasetrequest->list_0[(count1+ 4)].eventtype = nullterm(case_et), cvimpdatasetrequest->
       list_0[count1].subeventtype = nullterm(admit_et), cvimpdatasetrequest->list_0[(count1+ 1)].
       subeventtype = nullterm(admit_et),
       cvimpdatasetrequest->list_0[(count1+ 2)].subeventtype = nullterm(admit_et),
       cvimpdatasetrequest->list_0[(count1+ 3)].subeventtype = nullterm(admit_et),
       cvimpdatasetrequest->list_0[(count1+ 4)].subeventtype = nullterm(admit_et),
       cvimpdatasetrequest->list_0[count1].fieldtypemean = nullterm(alpha_ft), cvimpdatasetrequest->
       list_0[(count1+ 1)].fieldtypemean = nullterm(alpha_ft), cvimpdatasetrequest->list_0[(count1+ 2
       )].fieldtypemean = nullterm(alpha_ft),
       cvimpdatasetrequest->list_0[(count1+ 3)].fieldtypemean = nullterm(alpha_ft),
       cvimpdatasetrequest->list_0[(count1+ 4)].fieldtypemean = nullterm(alpha_ft),
       cvimpdatasetrequest->list_0[count1].reqdflag = "10",
       cvimpdatasetrequest->list_0[(count1+ 1)].reqdflag = "10", cvimpdatasetrequest->list_0[(count1
       + 2)].reqdflag = "10", cvimpdatasetrequest->list_0[(count1+ 3)].reqdflag = "10",
       cvimpdatasetrequest->list_0[(count1+ 4)].reqdflag = "10", cvimpdatasetrequest->list_0[count1].
       displayfldind = "1", cvimpdatasetrequest->list_0[(count1+ 1)].displayfldind = "1",
       cvimpdatasetrequest->list_0[(count1+ 2)].displayfldind = "1", cvimpdatasetrequest->list_0[(
       count1+ 3)].displayfldind = "1", cvimpdatasetrequest->list_0[(count1+ 4)].displayfldind = "1",
       cvimpdatasetrequest->list_0[count1].audit_flag = "1", cvimpdatasetrequest->list_0[(count1+ 1)]
       .audit_flag = "1", cvimpdatasetrequest->list_0[(count1+ 2)].audit_flag = "1",
       cvimpdatasetrequest->list_0[(count1+ 3)].audit_flag = "1", cvimpdatasetrequest->list_0[(count1
       + 4)].audit_flag = "1", count1 = (count1+ 4)
      FOOT REPORT
       stat = alterlist(cvimpdatasetrequest->list_0,count1)
      WITH nocounter
     ;end select
     RECORD cvimpdatasetreply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     CALL echorecord(cvimpdatasetrequest,"datasetimport")
     CALL cv_log_message("Entering cv_import_dataset.prg")
     EXECUTE cv_import_dataset  WITH replace("REQUESTIN","CVIMPDATASETREQUEST"), replace("REPLY",
      "CVIMPDATASETREPLY")
     CALL cv_log_message("Leaving cv_import_dataset.prg")
     CALL echorecord(cvimpdatasetreply,"datasetreply")
     FREE RECORD cvimpdatasetrequest
     IF ((cvimpdatasetreply->status_data.status="F"))
      CALL scriptfailure(cvimpdatasetreply->status_data.subeventstatus[1].targetobjectvalue)
     ENDIF
     UPDATE  FROM cv_xref cx,
       (dummyt d  WITH seq = value(size(internalmed->qual,5)))
      SET cx.task_assay_cd = internalmed->qual[d.seq].task_assay_cd, cx.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), cx.updt_id = reqinfo->updt_id,
       cx.updt_task = reqinfo->updt_task, cx.updt_applctx = reqinfo->updt_applctx, cx.updt_cnt = (cx
       .updt_cnt+ 1)
      PLAN (d)
       JOIN (cx
       WHERE (cx.xref_internal_name=internalmed->qual[d.seq].xref_name))
      WITH nocounter, status(internalmed->qual[d.seq].upd_xref_stat)
     ;end update
     SELECT INTO "nl:"
      begrange_xref = build(xref_prefix,"000"), endrange_xref = build(xref_prefix,"999")
      FROM cv_xref cx,
       (dummyt d  WITH seq = value(size(internalmed->qual,5))),
       dummyt d1
      PLAN (cx
       WHERE cx.xref_internal_name >= begrange
        AND cx.xref_internal_name <= endrange)
       JOIN (d1)
       JOIN (d
       WHERE (cx.xref_internal_name=internalmed->qual[d.seq].xref_name)
        AND cx.reqd_flag=10
        AND (cx.task_assay_cd=internalmed->qual[d.seq].task_assay_cd)
        AND (cx.registry_field_name=internalmed->qual[d.seq].regfldname)
        AND cx.display_field_ind=1)
      DETAIL
       CALL cv_log_message(build("Doesn't match parameters - XREF_NAME:",cx.xref_internal_name,
        " XREF_ID",cx.xref_id)), errcnt = (errcnt+ 1), stat = alterlist(cvreply->lines,errcnt),
       cvreply->lines[errcnt].errmsg = build("Doesn't match parameters - XREF_NAME:",cx
        .xref_internal_name," XREF_ID",cx.xref_id)
      WITH nocounter, outerjoin = d1, dontexist
     ;end select
     RETURN(1)
   END ;Subroutine
   SUBROUTINE medicationnamevalueprefs(null)
     SELECT INTO "nl:"
      medcat = internalmed->qual[d.seq].medcategory, medname = internalmed->qual[d.seq].medname
      FROM (dummyt d  WITH seq = value(size(internalmed->qual,5)))
      WHERE (internalmed->qual[d.seq].timing="A")
      ORDER BY medcat, medname
      HEAD REPORT
       medorder = 0
      DETAIL
       internalmed->qual[d.seq].medorder = medorder, medorder = (medorder+ 1)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      medcat = internalmed->qual[d.seq].medcategory, medname = internalmed->qual[d.seq].medname
      FROM (dummyt d  WITH seq = value(size(internalmed->qual,5)))
      WHERE (internalmed->qual[d.seq].timing="D")
      ORDER BY medcat, medname
      HEAD REPORT
       medorder = 0
      DETAIL
       internalmed->qual[d.seq].medorder = medorder, medorder = (medorder+ 1)
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM dcp_input_ref dir,
       dcp_section_ref dsr,
       dcp_forms_def dfd,
       dcp_forms_ref dfr,
       (dummyt d  WITH seq = value(size(internalmed->qual,5)))
      PLAN (d)
       JOIN (dfr
       WHERE dfr.active_ind=1
        AND dfr.dcp_forms_ref_id=accv3_dfr_admit
        AND dfr.dcp_form_instance_id > 0
        AND dfr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dfr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
       JOIN (dfd
       WHERE dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id
        AND dfd.active_ind=1
        AND dfd.dcp_forms_def_id > 0
        AND dfd.dcp_section_ref_id > 0
        AND dfd.dcp_form_instance_id=dfr.dcp_form_instance_id)
       JOIN (dsr
       WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
        AND dsr.active_ind=1
        AND dsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dsr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
        AND dsr.dcp_section_ref_id > 0
        AND dsr.dcp_section_instance_id > 0)
       JOIN (dir
       WHERE dir.dcp_section_ref_id=dsr.dcp_section_ref_id
        AND dir.active_ind=1
        AND dir.dcp_section_instance_id=dsr.dcp_section_instance_id
        AND ((dir.description="ADMIT_MED"
        AND (internalmed->qual[d.seq].timing="A")) OR (dir.description="DISCH_MED"
        AND (internalmed->qual[d.seq].timing="D")))
        AND dir.dcp_input_ref_id > 0)
      DETAIL
       IF (dir.description="ADMIT_MED"
        AND (internalmed->qual[d.seq].timing="A"))
        internalmed->qual[d.seq].admit_disch_id = dir.dcp_input_ref_id, internalmed->admit_dir = dir
        .dcp_input_ref_id
       ELSEIF (dir.description="DISCH_MED"
        AND (internalmed->qual[d.seq].timing="D"))
        internalmed->qual[d.seq].admit_disch_id = dir.dcp_input_ref_id, internalmed->disch_dir = dir
        .dcp_input_ref_id
       ENDIF
       effdate = format(cnvtdate2(cnvtalphanum(internalmed->qual[d.seq].effectivedate),"MMDDYYYY"),
        "YYYYMMDD;;D")
       IF (trim(internalmed->qual[d.seq].expirationdate)="")
        expdate = format(cnvtdatetime("31-DEC-2100"),"YYYYMMDD;;D")
       ELSE
        expdate = format(cnvtdate2(cnvtalphanum(internalmed->qual[d.seq].expirationdate),"MMDDYYYY"),
         "YYYYMMDD;;D")
       ENDIF
       internalmed->qual[d.seq].pvc_value = build("0;DATED:",effdate,",",expdate)
      WITH nocounter
     ;end select
     DELETE  FROM name_value_prefs nvp
      WHERE nvp.parent_entity_name="DCP_INPUT_REF"
       AND nvp.pvc_name=trim("discrete_task_assay")
       AND nvp.merge_name="DISCRETE_TASK_ASSAY"
       AND (((nvp.parent_entity_id=internalmed->admit_dir)) OR ((nvp.parent_entity_id=internalmed->
      disch_dir)))
      WITH nocounter
     ;end delete
     INSERT  FROM name_value_prefs nvp,
       (dummyt d  WITH seq = value(size(internalmed->qual,5)))
      SET nvp.parent_entity_name = "DCP_INPUT_REF", nvp.parent_entity_id = internalmed->qual[d.seq].
       admit_disch_id, nvp.pvc_name = "discrete_task_assay",
       nvp.pvc_value = internalmed->qual[d.seq].pvc_value, nvp.merge_name = "DISCRETE_TASK_ASSAY",
       nvp.merge_id = internalmed->qual[d.seq].task_assay_cd,
       nvp.sequence = internalmed->qual[d.seq].medorder, nvp.updt_cnt = 0, nvp.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       nvp.updt_applctx = reqinfo->updt_applctx, nvp.updt_id = reqinfo->updt_id, nvp.updt_task =
       reqinfo->updt_task,
       nvp.active_ind = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval)
      PLAN (d)
       JOIN (nvp)
      WITH nocounter
     ;end insert
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.active_ind=1
       AND nvp.name_value_prefs_id != 0.0
       AND nvp.parent_entity_name="DCP_INPUT_REF"
       AND nvp.pvc_name="disable_column_select"
       AND (nvp.parent_entity_id=internalmed->admit_dir)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp
        .parent_entity_id = internalmed->admit_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF", nvp.pvc_name = "disable_column_select", nvp
        .updt_applctx = reqinfo->updt_applctx,
        nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
        updt_id,
        nvp.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
     SELECT INTO "nl:"
      FROM name_value_prefs nvp
      WHERE nvp.active_ind=1
       AND nvp.name_value_prefs_id != 0.0
       AND nvp.parent_entity_name="DCP_INPUT_REF"
       AND nvp.pvc_name="disable_column_select"
       AND (nvp.parent_entity_id=internalmed->disch_dir)
      WITH nocounter
     ;end select
     IF (curqual=0)
      INSERT  FROM name_value_prefs nvp
       SET nvp.active_ind = 1, nvp.name_value_prefs_id = seq(carenet_seq,nextval), nvp
        .parent_entity_id = internalmed->disch_dir,
        nvp.parent_entity_name = "DCP_INPUT_REF", nvp.pvc_name = "disable_column_select", nvp
        .updt_applctx = reqinfo->updt_applctx,
        nvp.updt_cnt = 0, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3), nvp.updt_id = reqinfo->
        updt_id,
        nvp.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
     RETURN(1)
   END ;Subroutine
   SUBROUTINE medicationsdtaexists(dummy)
     DECLARE sfilename = vc WITH protect
     DECLARE nqual_cnt = i4 WITH protect
     DECLARE nsuccess_ind = i2 WITH protect
     DECLARE nmsg_cnt = i4 WITH protect
     DECLARE nmsg_type_flag = i2 WITH protect
     DECLARE smsg_string = vc WITH protect
     DECLARE sopname = c25 WITH protect
     DECLARE sopstatus = c1 WITH protect
     DECLARE stargetobjname = c25 WITH protect
     DECLARE stargetobjvalue = vc WITH protect
     DECLARE sstatus = c1 WITH protect
     DECLARE happ = i4 WITH protect
     DECLARE htask = i4 WITH protect
     DECLARE hstep = i4 WITH protect
     DECLARE hreq = i4 WITH protect
     DECLARE tempdta = i4 WITH protect
     DECLARE hexptask = i4 WITH protect
     DECLARE hexpstep = i4 WITH protect
     DECLARE hexpreq = i4 WITH protect
     DECLARE hstdta = i4 WITH protect
     DECLARE hstexprep = i4 WITH protect
     DECLARE himptask = i4 WITH protect
     DECLARE himpstep = i4 WITH protect
     DECLARE hexpdtaobjlist = i4 WITH protect
     DECLARE hexpdtaobj = i4 WITH protect
     DECLARE hexprefrangefactlist = i4 WITH protect
     DECLARE hexprefrangefact = i4 WITH protect
     DECLARE himpreq = i4 WITH protect
     DECLARE hdtaobjlist = i4 WITH protect
     DECLARE hdtaobj = i4 WITH protect
     DECLARE sexpacttypedisp = vc WITH protect
     DECLARE sexpdefrestypekey = vc WITH protect
     DECLARE nexppagefrom = i4 WITH protect
     DECLARE hrefrangefact = i4 WITH protect
     DECLARE hrefrangefactlist = i4 WITH protect
     DECLARE sexpagefromunitdispkey = vc WITH protect
     DECLARE nexpageto = i4 WITH protect
     DECLARE sexpagetounitdispkey = vc WITH protect
     DECLARE sexpspeciesdisp = vc WITH protect
     DECLARE narcount = i4 WITH protect
     DECLARE applicationid = i4 WITH protect, constant(4170000)
     DECLARE imptaskid = i4 WITH protect, constant(4170002)
     DECLARE exptaskid = i4 WITH protect, constant(4170001)
     DECLARE impstepid = i4 WITH protect, constant(4170017)
     DECLARE expstepid = i4 WITH protect, constant(4170014)
     SET tempdta = uar_get_code_by("MEANING",cs_dta,nullterm(med_ref_dta))
     IF (tempdta <= 0.0)
      CALL zerorowsfound("No reference DTA for medications!")
     ENDIF
     SET stat = uar_crmbeginapp(applicationid,happ)
     IF (stat != 0)
      CALL cv_log_message("uar_CrmBeginApp failed")
      CALL scriptfailure("uar_CrmBeginApp failed")
      RETURN
     ENDIF
     SET stat = uar_crmbegintask(happ,exptaskid,hexptask)
     IF (stat != 0)
      CALL cv_log_message("uar_CrmBeginTask failed")
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure("uar_CrmBeginTask failed")
      RETURN
     ENDIF
     SET stat = uar_crmbeginreq(hexptask,"",expstepid,hexpstep)
     IF (stat != 0)
      CALL cv_log_message("uar_CrmBeginReq failed")
      IF (hexptask)
       CALL uar_crmendtask(hexptask)
       SET hexptask = 0
      ENDIF
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure("uar_CrmBeginReq failed")
      RETURN
     ENDIF
     SET hexpreq = uar_crmgetrequest(hexpstep)
     IF (hexpreq=0)
      CALL echo("Failed to get request for 4170014")
     ENDIF
     SET hstdta = uar_srvadditem(hexpreq,"task_assay_list")
     IF (hstdta=0)
      CALL echo("Function failed or list was full")
     ENDIF
     SET stat = uar_srvsetlong(hstdta,"task_assay_cd",tempdta)
     IF (stat=false)
      CALL echo(build("Failed to set task_assay_cd to :",tempdta))
     ENDIF
     SET stat = uar_crmperform(hexpstep)
     IF (stat != 0)
      CALL cv_log_message(build("uar_CrmPerform failed. Error Code:",stat))
      IF (hexpstep)
       CALL uar_crmendreq(hexpstep)
       SET hexpstep = 0
      ENDIF
      IF (hexptask)
       CALL uar_crmendtask(hexptask)
       SET hexptask = 0
      ENDIF
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure(build("uar_CrmPerform failed. Error Code:",stat))
      RETURN
     ENDIF
     SET hstexprep = uar_crmgetreply(hexpstep)
     IF (hstexprep=0)
      CALL cv_log_message("uar_CrmGetReply failed.")
      IF (hexpstep)
       CALL uar_crmendreq(hexpstep)
       SET hexpstep = 0
      ENDIF
      IF (hexptask)
       CALL uar_crmendtask(hexptask)
       SET hexptask = 0
      ENDIF
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure("uar_CrmGetReply failed")
      RETURN
     ENDIF
     SET hexpdtaobjlist = uar_srvgetitem(hstexprep,"dta_obj_list",0)
     IF (hexpdtaobjlist=0)
      CALL echo("Item not found in dta_obj_list")
     ENDIF
     SET hexpdtaobj = uar_srvgetstruct(hexpdtaobjlist,"dta_obj")
     IF (hexpdtaobj=0)
      CALL echo("Field not found in structure dta_obj")
     ENDIF
     SET sexpacttypedisp = uar_srvgetstringptr(hexpdtaobj,"activity_type_disp")
     IF (sexpacttypedisp <= " ")
      CALL echo("Activity type disp not found in dta_obj")
     ELSE
      CALL echo(build("Medication Activity Type Disp:",sexpacttypedisp))
     ENDIF
     SET sexpdefrestypekey = uar_srvgetstringptr(hexpdtaobj,"default_result_type_disp_key")
     SET hexprefrangefactlist = uar_srvgetitem(hexpdtaobj,"reference_range_factor_list",0)
     SET hexprefrangefact = uar_srvgetstruct(hexprefrangefactlist,"reference_range_factor")
     SET nexpagefrom = uar_srvgetlong(hexprefrangefact,"age_from")
     SET sexpagefromunitdispkey = uar_srvgetstringptr(hexprefrangefact,"age_from_units_disp_key")
     SET nexpageto = uar_srvgetlong(hexprefrangefact,"age_to")
     SET sexpagetounitdispkey = uar_srvgetstringptr(hexprefrangefact,"age_to_units_disp_key")
     SET sexpspeciesdisp = uar_srvgetstringptr(hexprefrangefact,"species_disp")
     SET stat = uar_crmbegintask(happ,imptaskid,himptask)
     IF (stat != 0)
      CALL cv_log_message("uar_CrmBeginTask failed")
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure("uar_CrmBeginTask failed")
      RETURN
     ENDIF
     SET stat = uar_crmbeginreq(himptask,"",impstepid,himpstep)
     IF (stat != 0)
      CALL cv_log_message("uar_CrmBeginReq failed")
      IF (himptask)
       CALL uar_crmendtask(htask)
       SET htask = 0
      ENDIF
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure("uar_CrmBeginReq failed")
      RETURN
     ENDIF
     SET himpreq = uar_crmgetrequest(himpstep)
     SET nimpmethodflag = uar_srvsetshort(himpreq,"import_method_flag",kia_upd_audit)
     FOR (forcount = 1 TO value(size(internalmed->qual,5)))
       IF ((internalmed->qual[forcount].update_ind=0))
        SET hdtaobjlist = uar_srvadditem(himpreq,"dta_obj_list")
        SET hdtaobj = uar_srvgetstruct(hdtaobjlist,"dta_obj")
        SET sacttypedisp = uar_srvsetstring(hdtaobj,"activity_type_disp",sexpacttypedisp)
        SET sdefrestypekey = uar_srvsetstring(hdtaobj,"default_result_type_disp_key",
         sexpdefrestypekey)
        SET hrefrangefactlist = uar_srvadditem(hdtaobj,"reference_range_factor_list")
        SET hrefrangefact = uar_srvgetstruct(hrefrangefactlist,"reference_range_factor")
        SET nagefrom = uar_srvsetlong(hrefrangefact,"age_from",nexpagefrom)
        SET sagefromunitdispkey = uar_srvsetstring(hrefrangefact,"age_from_units_disp_key",
         sexpagefromunitdispkey)
        SET nageto = uar_srvsetlong(hrefrangefact,"age_to",nexpageto)
        SET sagetounitdispkey = uar_srvsetstring(hrefrangefact,"age_to_units_disp_key",
         sexpagetounitdispkey)
        SET sspeciesdisp = uar_srvsetstring(hrefrangefact,"species_disp",sexpspeciesdisp)
        SET narcount = uar_srvgetitemcount(hrefrangefact,"alpha_response_list")
        FOR (forcnt2 = 1 TO narcount)
          SET hexpalpharesplist = uar_srvgetitem(hexprefrangefact,"alpha_response_list",(forcnt2 - 1)
           )
          SET hexpalpharesp = uar_srvgetstruct(hexpalpharesplist,"alpha_response")
          SET sexpsrcvocabmean = uar_srvgetstringptr(hexpalpharesp,"source_vocabulary_mean")
          SET sexpsrcstring = uar_srvgetstringptr(hexpalpharesp,"source_string")
          SET sexpmnemonic = uar_srvgetstringptr(hexpalpharesp,"mnemonic")
          SET sexpprintypemean = uar_srvgetstringptr(hexpalpharesp,"principle_type_mean")
          SET sexpresval = uar_srvgetstringptr(hexpalpharesp,"result_value")
          SET nexpseq = uar_srvgetshort(hexpalpharesp,"sequence")
          SET halpharesplist = uar_srvadditem(hrefrangefact,"alpha_response_list")
          SET halpharesp = uar_srvgetstruct(halpharesplist,"alpha_response")
          SET ssrcvocabmean = uar_srvsetstring(halpharesp,"source_vocabulary_mean",sexpsrcvocabmean)
          SET ssrcstring = uar_srvsetstring(halpharesp,"source_string",sexpsrcstring)
          SET smnemonic = uar_srvsetstring(halpharesp,"mnemonic",sexpmnemonic)
          SET sprintypemean = uar_srvsetstring(halpharesp,"principle_type_mean",sexpprintypemean)
          SET sresval = uar_srvsetstring(halpharesp,"result_value",sexpresval)
          SET nseq = uar_srvsetshort(halpharesp,"sequence",nexpseq)
        ENDFOR
        SET sdtamnemonic = uar_srvsetstring(hdtaobj,"dta_mnemonic",trim(substring(0,40,internalmed->
           qual[forcount].dtamnemonic)))
        SET sdtadescription = uar_srvsetstring(hdtaobj,"dta_description",trim(substring(0,60,
           internalmed->qual[forcount].dtadescription)))
        SET seventcddisp = uar_srvsetstring(hdtaobj,"event_code_disp",trim(substring(0,40,internalmed
           ->qual[forcount].dtamnemonic)))
        SET seventcdcki = uar_srvsetstring(hdtaobj,"event_code_cki",build("AC03MEDID",format(
           internalmed->qual[forcount].medid,"###;P0"),"EC"))
        SET sdtacki = uar_srvsetstring(hdtaobj,"dta_cki",build("AC03MEDID",format(internalmed->qual[
           forcount].medid,"###;P0"),"DTA"))
        SET sdtacdfmean = uar_srvsetstring(hdtaobj,"dta_cdf_meaning",trim(internalmed->qual[forcount]
          .cdf_name))
       ENDIF
     ENDFOR
     IF (hexpstep)
      CALL uar_crmendreq(hexpstep)
      SET hexpstep = 0
     ENDIF
     IF (hexptask)
      CALL uar_crmendtask(hexptask)
      SET hexptask = 0
     ENDIF
     SET ndtacount = uar_srvgetitemcount(himpreq,"dta_obj_list")
     IF (ndtacount=0)
      CALL cv_log_message("All DTAs have been previously imported.")
      SET errcnt = (errcnt+ 1)
      SET stat = alterlist(cvreply->lines,errcnt)
      SET cvreply->lines[errcnt].errmsg = "All DTAs have been previously imported."
     ENDIF
     SET stat = uar_crmperform(himpstep)
     IF (stat != 0)
      CALL cv_log_message(build("uar_CrmPerform failed. Error Code:",stat))
      IF (himpstep)
       CALL uar_crmendreq(himpstep)
       SET himpstep = 0
      ENDIF
      IF (himptask)
       CALL uar_crmendtask(himptask)
       SET himptask = 0
      ENDIF
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure(build("uar_CrmPerform failed. Error Code:",stat))
      RETURN
     ENDIF
     SET hstimprep = uar_crmgetreply(himpstep)
     IF (hstimprep <= 0)
      CALL cv_log_message("uar_CrmGetReply failed.")
      IF (himpstep)
       CALL uar_crmendreq(himpstep)
       SET himpstep = 0
      ENDIF
      IF (himptask)
       CALL uar_crmendtask(himptask)
       SET himptask = 0
      ENDIF
      IF (happ)
       CALL uar_crmendapp(happ)
       SET happ = 0
      ENDIF
      CALL scriptfailure("uar_CrmGetReply failed")
      RETURN
     ENDIF
     SET sfilename = uar_srvgetstringptr(hstimprep,"filename")
     CALL cv_log_message(concat("filename:",sfilename))
     SET nqual_cnt = uar_srvgetlong(hstimprep,"qual_cnt")
     CALL cv_log_message(concat("qual_cnt:",cnvtstring(nqual_cnt)))
     FOR (i = 0 TO (nqual_cnt - 1))
      SET hqual = uar_srvgetitem(hstimprep,"qual",i)
      IF (hqual)
       SET nsuccess_ind = uar_srvgetshort(hqual,"success_ind")
       CALL cv_log_message(concat("success_ind:",cnvtstring(nsuccess_ind)))
       SET nmsg_cnt = uar_srvgetlong(hqual,"msg_cnt")
       CALL cv_log_message(concat("msg_cnt:",cnvtstring(nmsg_cnt)))
       FOR (j = 0 TO (nmsg_cnt - 1))
        SET hmsg = uar_srvgetitem(hqual,"messages",j)
        IF (hmsg)
         SET nmsg_type_flag = uar_srvgetshort(hmsg,"msg_type_flag")
         CALL cv_log_message(concat("msg_type_flag:",cnvtstring(nmsg_type_flag)))
         SET smsg_string = uar_srvgetstringptr(hmsg,"msg_string")
         CALL cv_log_message(concat("msg_string:",smsg_string))
        ELSE
         CALL cv_log_message("No messages in reply")
        ENDIF
       ENDFOR
      ELSE
       CALL cv_log_message("No quals in reply")
      ENDIF
     ENDFOR
     SET hsb = uar_srvgetstruct(hstimprep,"status_data")
     IF (hsb)
      SET sstatus = uar_srvgetstringptr(hsb,"status")
      CALL cv_log_message(concat("status:",sstatus))
      SET hsubeventstatus = uar_srvgetitem(hsb,"subeventstatus",0)
      IF (hsubeventstatus)
       SET sopname = uar_srvgetstringptr(hsubeventstatus,"operationname")
       CALL cv_log_message(concat("opName:",sopname))
       SET sopstatus = uar_srvgetstringptr(hsubeventstatus,"operationstatus")
       CALL cv_log_message(concat("opStatus:",sopstatus))
       SET stargetobjname = uar_srvgetstringptr(hsubeventstatus,"targetobjectname")
       CALL cv_log_message(concat("targetObjName:",stargetobjname))
       SET stargetobjvalue = uar_srvgetstringptr(hsubeventstatus,"targetobjectvalue")
       CALL cv_log_message(concat("targetObjValue:",stargetobjvalue))
      ELSE
       CALL cv_log_message("No subeventstatus in reply")
      ENDIF
     ELSE
      CALL cv_log_message("No status_data in reply")
     ENDIF
     IF (himpstep)
      CALL uar_crmendreq(himpstep)
      SET himpstep = 0
     ENDIF
     IF (himptask)
      CALL uar_crmendtask(himptask)
      SET himptask = 0
     ENDIF
     IF (happ)
      CALL uar_crmendapp(happ)
      SET happ = 0
     ENDIF
     FOR (cnt1 = 1 TO size(internalmed->qual,5))
       SET meddta = uar_get_code_by("MEANING",cs_dta,internalmed->qual[cnt1].cdf_name)
       IF (meddta <= 0.0)
        SELECT INTO "nl:"
         FROM code_value cv
         WHERE cv.code_set=14003
          AND (cv.cdf_meaning=internalmed->qual[cnt1].cdf_name)
          AND cv.active_ind=1
         DETAIL
          meddta = cv.code_value
         WITH nocounter
        ;end select
       ENDIF
       IF (meddta <= 0.0)
        CALL cv_log_message(build2("Can't find Medications DTA with CDF meaning - ",internalmed->
          qual[cnt1].cdf_name))
        SET errcnt = (errcnt+ 1)
        SET stat = alterlist(cvreply->lines,errcnt)
        SET cvreply->lines[errcnt].errmsg = build2("Can't find Medications DTA with CDF meaning - ",
         internalmed->qual[cnt1].cdf_name)
       ELSE
        SET meddisp = uar_get_code_display(meddta)
        SET meddescript = uar_get_code_description(meddta)
        IF (((meddisp != trim(substring(0,40,internalmed->qual[cnt1].dtamnemonic))) OR (meddescript
         != trim(substring(0,60,internalmed->qual[cnt1].dtadescription)))) )
         CALL cv_log_message(build2("Doesn't match parameters - DTA:",meddta," CDF:",internalmed->
           qual[cnt1].cdf_name))
         SET errcnt = (errcnt+ 1)
         SET stat = alterlist(cvreply->lines,errcnt)
         SET cvreply->lines[errcnt].errmsg = build2("Doesn't match parameters - DTA:",meddta," CDF:",
          internalmed->qual[cnt1].cdf_name)
        ELSEIF ((internalmed->qual[cnt1].update_ind=0))
         SET internalmed->qual[cnt1].task_assay_cd = meddta
        ENDIF
       ENDIF
     ENDFOR
     RETURN(1)
   END ;Subroutine
   SUBROUTINE determineexistingmedications(null)
     DECLARE exitprogram = i1 WITH protect, noconstant(0)
     SELECT INTO "nl:"
      cdf_mean_nbr = cnvtint(substring(10,3,cv.cdf_meaning))
      FROM code_value cv
      WHERE cv.code_set=cs_dta
       AND cv.cdf_meaning=patstring(concat(cdf_prefix,"*"))
       AND cv.active_ind=1
      ORDER BY cv.cdf_meaning
      HEAD REPORT
       count = 0, stat = alterlist(internalmed->qual,value(size(cvrequestin->med,5)))
      HEAD cv.cdf_meaning
       IF (isnumeric(cnvtint(substring(10,3,cv.cdf_meaning)))=1)
        count = (count+ 1)
        FOR (i = 1 TO size(cvrequestin->med,5))
          IF ((cvrequestin->med[i].medid=cdf_mean_nbr))
           IF ((cvrequestin->med[i].timing="A"))
            timingstr = "Admit"
           ELSEIF ((cvrequestin->med[i].timing="D"))
            timingstr = "Disch"
           ELSE
            timingstr = " "
           ENDIF
           internalmed->qual[i].effectivedate = cvrequestin->med[i].effectivedate, internalmed->qual[
           i].expirationdate = cvrequestin->med[i].expirationdate, internalmed->qual[i].medid =
           cvrequestin->med[i].medid,
           internalmed->qual[i].timing = cvrequestin->med[i].timing, internalmed->qual[i].medcategory
            = cvrequestin->med[i].medcategory, internalmed->qual[i].medname = cvrequestin->med[i].
           medname,
           internalmed->qual[i].cdf_name = trim(cv.cdf_meaning), internalmed->qual[i].xref_name =
           build(xref_prefix,format(cvrequestin->med[i].medid,"###;P0")), internalmed->qual[i].
           regfldname = build2(timingstr," Medication ",cvrequestin->med[i].medname),
           internalmed->qual[i].dtamnemonic = build2("AC03 ",timingstr," ",cvrequestin->med[i].
            medname), internalmed->qual[i].dtadescription = build2(cvrequestin->med[i].medcategory,
            ":",cvrequestin->med[i].medname), internalmed->qual[i].medorder = 0,
           internalmed->qual[i].update_ind = 1, internalmed->qual[i].task_assay_cd = cv.code_value, i
            = size(cvrequestin->med,5)
          ENDIF
        ENDFOR
       ELSE
        CALL cv_log_message(build2("INVALID CDF_MEANING FOUND:",cv.cdf_meaning," DTA:",cv.code_value)
        )
       ENDIF
      FOOT REPORT
       IF (count > size(cvrequestin->med,5))
        CALL cv_log_message("More records in database than in csv."), errcnt = (errcnt+ 1), stat =
        alterlist(cvreply->lines,errcnt),
        cvreply->lines[errcnt].errmsg = "More records in database than in csv."
        IF ((cvrequestin->force_update=0))
         CALL cv_log_message("Exiting without changes to the database."), errcnt = (errcnt+ 1), stat
          = alterlist(cvreply->lines,errcnt),
         cvreply->lines[errcnt].errmsg = "Exiting without changes to the database.", exitprogram = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     IF (curqual=0)
      CALL cv_log_message("No medications records in database!")
      SET stat = alterlist(internalmed->qual,size(cvrequestin->med,5))
     ENDIF
     FOR (i = 1 TO size(internalmed->qual,5))
       IF ((internalmed->qual[i].update_ind != 1))
        IF ((cvrequestin->med[i].timing="A"))
         SET timingstr = "Admit"
        ELSEIF ((cvrequestin->med[i].timing="D"))
         SET timingstr = "Disch"
        ELSE
         SET timingstr = " "
        ENDIF
        SET internalmed->qual[i].effectivedate = cvrequestin->med[i].effectivedate
        SET internalmed->qual[i].expirationdate = cvrequestin->med[i].expirationdate
        SET internalmed->qual[i].medid = cvrequestin->med[i].medid
        SET internalmed->qual[i].timing = cvrequestin->med[i].timing
        SET internalmed->qual[i].medcategory = cvrequestin->med[i].medcategory
        SET internalmed->qual[i].medname = cvrequestin->med[i].medname
        SET internalmed->qual[i].cdf_name = build(cdf_prefix,format(cvrequestin->med[i].medid,
          "###;P0"))
        SET internalmed->qual[i].xref_name = build(xref_prefix,format(cvrequestin->med[i].medid,
          "###;P0"))
        SET internalmed->qual[i].regfldname = build2(timingstr," Medication ",cvrequestin->med[i].
         medname)
        SET internalmed->qual[i].dtamnemonic = build2("AC03 ",timingstr," ",cvrequestin->med[i].
         medname)
        SET internalmed->qual[i].dtadescription = build2(cvrequestin->med[i].medcategory,":",
         cvrequestin->med[i].medname)
        SET internalmed->qual[i].medorder = 0
        SET internalmed->qual[i].update_ind = 0
        SET internalmed->qual[i].task_assay_cd = 0.0
       ENDIF
     ENDFOR
     RETURN(exitprogram)
   END ;Subroutine
   DECLARE existingmeds_ret = i2 WITH protect
   IF (exec_med=1)
    CALL cv_log_message("Entering cv_upd_med_from_csv")
    SET existingmeds_ret = determineexistingmedications(null)
    IF (existingmeds_ret=1)
     RETURN(0)
    ENDIF
    CALL medicationsdtaexists(null)
    CALL medicationxrefexists(null)
    CALL medicationnamevalueprefs(null)
    CALL medicationxrefvalidations(null)
    CALL cv_log_message("Leaving cv_upd_med_from_csv")
    RETURN(1)
   ELSE
    CALL cv_log_message("No medications to process!")
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE parseicdevs(null)
   SET iclinesize = size(request->icdevline,5)
   IF (iclinesize > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(iclinesize))
     PLAN (d
      WHERE (request->icdevline[d.seq].linedata != " "))
     HEAD REPORT
      icdev_cnt = 0, stat = alterlist(cvrequestin->icdev,10)
     DETAIL
      icdev_cnt = (icdev_cnt+ 1)
      IF (mod(icdev_cnt,10)=1
       AND icdev_cnt != 1)
       stat = alterlist(cvrequestin->icdev,(icdev_cnt+ 9))
      ENDIF
      effdate_pos = findstring(",",request->icdevline[d.seq].linedata)
      IF (effdate_pos != 1)
       effdate = substring(1,(effdate_pos - 1),request->icdevline[d.seq].linedata)
       IF (findstring("/",effdate)=2)
        effdate = build("0",effdate)
       ENDIF
       IF (findstring("/",effdate,4,0)=5)
        effdate = build(substring(1,3,effdate),"0",substring(4,6,effdate))
       ENDIF
       cvrequestin->icdev[icdev_cnt].effectivedate = effdate
      ENDIF
      expdate_pos = findstring(",",request->icdevline[d.seq].linedata,(effdate_pos+ 1))
      IF ((expdate_pos != (effdate_pos+ 1)))
       expdate = substring((effdate_pos+ 1),((expdate_pos - effdate_pos) - 1),request->icdevline[d
        .seq].linedata)
       IF (findstring("/",expdate)=2)
        expdate = build("0",expdate)
       ENDIF
       IF (findstring("/",expdate,4,0)=5)
        expdate = build(substring(1,3,expdate),"0",substring(4,6,expdate))
       ENDIF
       cvrequestin->icdev[icdev_cnt].expirationdate = expdate
      ENDIF
      icdevid_pos = findstring(",",request->icdevline[d.seq].linedata,(expdate_pos+ 1))
      IF ((icdevid_pos != (expdate_pos+ 1)))
       icdevid_str = substring((expdate_pos+ 1),((icdevid_pos - expdate_pos) - 1),request->icdevline[
        d.seq].linedata), icdevid = cnvtint(icdevid_str), cvrequestin->icdev[icdev_cnt].icdeviceid =
       icdevid
      ENDIF
      icdevname_pos = findstring(",",request->icdevline[d.seq].linedata,(icdevid_pos+ 1))
      IF ((icdevname_pos != (icdevid_pos+ 1)))
       icdevname = trim(substring((icdevid_pos+ 1),((icdevname_pos - icdevid_pos) - 1),request->
         icdevline[d.seq].linedata),3)
       IF (substring(1,1,icdevname)='"'
        AND substring(size(icdevname),1,icdevname)='"')
        cvrequestin->icdev[icdev_cnt].icdevname = substring(2,(size(icdevname) - 2),icdevname)
       ELSE
        cvrequestin->icdev[icdev_cnt].icdevname = icdevname
       ENDIF
      ENDIF
      canbeprim_pos = findstring(",",request->icdevline[d.seq].linedata,(icdevname_pos+ 1))
      IF ((canbeprim_pos != (icdevname_pos+ 1)))
       canbeprim = cnvtalphanum(substring((icdevname_pos+ 1),((canbeprim_pos - icdevname_pos) - 1),
         request->icdevline[d.seq].linedata))
       IF (canbeprim != " ")
        cvrequestin->icdev[icdev_cnt].canbeprimary = canbeprim
       ENDIF
      ENDIF
      diamreq_pos = findstring(",",request->icdevline[d.seq].linedata,(canbeprim_pos+ 1))
      IF ((diamreq_pos != (canbeprim_pos+ 1)))
       diamreq = cnvtalphanum(substring((canbeprim_pos+ 1),((diamreq_pos - canbeprim_pos) - 1),
         request->icdevline[d.seq].linedata))
       IF (diamreq != " ")
        cvrequestin->icdev[icdev_cnt].diamrequired = diamreq
       ENDIF
      ENDIF
      lenreq_pos = findstring(",",request->icdevline[d.seq].linedata,(diamreq_pos+ 1))
      IF ((lenreq_pos != (diamreq_pos+ 1)))
       lenreq = cnvtalphanum(substring((diamreq_pos+ 1),((lenreq_pos - diamreq_pos) - 1),request->
         icdevline[d.seq].linedata))
       IF (lenreq != " ")
        cvrequestin->icdev[icdev_cnt].lenrequired = lenreq
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(cvrequestin->icdev,icdev_cnt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_log_message("No IC Devices found in request!")
     SET exec_icdev = 0
    ELSE
     SET exec_icdev = 1
    ENDIF
   ELSE
    CALL cv_log_message("No IC Devices found in request!")
    SET exec_icdev = 0
   ENDIF
   RETURN(exec_icdev)
 END ;Subroutine
 SUBROUTINE parsemeds(null)
   SET medlinesize = size(request->medicationsline,5)
   IF (medlinesize > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(medlinesize))
     PLAN (d
      WHERE (request->medicationsline[d.seq].linedata != " "))
     HEAD REPORT
      meds_cnt = 0, stat = alterlist(cvrequestin->med,10)
     DETAIL
      meds_cnt = (meds_cnt+ 1)
      IF (mod(meds_cnt,10)=1
       AND meds_cnt != 1)
       stat = alterlist(cvrequestin->med,(meds_cnt+ 9))
      ENDIF
      effdate_pos = findstring(",",request->medicationsline[d.seq].linedata)
      IF (effdate_pos != 1)
       effdate = substring(1,(effdate_pos - 1),request->medicationsline[d.seq].linedata)
       IF (findstring("/",effdate)=2)
        effdate = build("0",effdate)
       ENDIF
       IF (findstring("/",effdate,4,0)=5)
        effdate = build(substring(1,3,effdate),"0",substring(4,6,effdate))
       ENDIF
       cvrequestin->med[meds_cnt].effectivedate = effdate
      ENDIF
      expdate_pos = findstring(",",request->medicationsline[d.seq].linedata,(effdate_pos+ 1))
      IF ((expdate_pos != (effdate_pos+ 1)))
       expdate = substring((effdate_pos+ 1),((expdate_pos - effdate_pos) - 1),request->
        medicationsline[d.seq].linedata)
       IF (findstring("/",expdate)=2)
        expdate = build("0",expdate)
       ENDIF
       IF (findstring("/",expdate,4,0)=5)
        expdate = build(substring(1,3,expdate),"0",substring(4,6,expdate))
       ENDIF
       cvrequestin->med[meds_cnt].expirationdate = expdate
      ENDIF
      medid_pos = findstring(",",request->medicationsline[d.seq].linedata,(expdate_pos+ 1))
      IF ((medid_pos != (expdate_pos+ 1)))
       medid_str = substring((expdate_pos+ 1),((medid_pos - expdate_pos) - 1),request->
        medicationsline[d.seq].linedata), medid = cnvtint(medid_str)
       IF (medid != 0)
        cvrequestin->med[meds_cnt].medid = medid
       ENDIF
      ENDIF
      timing_pos = findstring(",",request->medicationsline[d.seq].linedata,(medid_pos+ 1))
      IF ((timing_pos != (medid_pos+ 1)))
       timing = cnvtalphanum(substring((medid_pos+ 1),((timing_pos - medid_pos) - 1),request->
         medicationsline[d.seq].linedata))
       IF (timing != "")
        cvrequestin->med[meds_cnt].timing = timing
       ENDIF
      ENDIF
      medcat_pos = findstring(",",request->medicationsline[d.seq].linedata,(timing_pos+ 1))
      IF ((medcat_pos != (timing_pos+ 1)))
       medcat = trim(substring((timing_pos+ 1),((medcat_pos - timing_pos) - 1),request->
         medicationsline[d.seq].linedata),3)
       IF (substring(1,1,medcat)='"'
        AND substring(size(medcat),1,medcat)='"')
        cvrequestin->med[meds_cnt].medcategory = substring(2,(size(medcat) - 2),medcat)
       ELSEIF (substring(1,1,medcat)='"'
        AND substring(size(medcat),1,medcat) != '"')
        cvrequestin->med[meds_cnt].medcategory = substring(2,(size(medcat) - 1),medcat)
       ELSEIF (substring(1,1,medcat) != '"'
        AND substring(size(medcat),1,medcat)='"')
        cvrequestin->med[meds_cnt].medcategory = substring(1,(size(medcat) - 2),medcat)
       ELSE
        cvrequestin->med[meds_cnt].medcategory = medcat
       ENDIF
      ENDIF
      medname_pos = textlen(request->medicationsline[d.seq].linedata), medname = trim(substring((
        medcat_pos+ 1),(medname_pos - medcat_pos),request->medicationsline[d.seq].linedata),3)
      IF (substring(1,1,medname)='"'
       AND substring(size(medname),1,medname)='"')
       cvrequestin->med[meds_cnt].medname = substring(2,(size(medname) - 2),medname)
      ELSEIF (substring(1,1,medname)='"'
       AND substring(size(medname),1,medname) != '"')
       cvrequestin->med[meds_cnt].medname = substring(2,(size(medname) - 1),medname)
      ELSEIF (substring(1,1,medname) != '"'
       AND substring(size(medname),1,medname)='"')
       cvrequestin->med[meds_cnt].medname = substring(1,(size(medname) - 2),medname)
      ELSE
       cvrequestin->med[meds_cnt].medname = medname
      ENDIF
     FOOT REPORT
      stat = alterlist(cvrequestin->med,meds_cnt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_log_message("No medications found in request!")
     SET exec_med = 0
    ELSE
     SET exec_med = 1
    ENDIF
   ELSE
    CALL cv_log_message("No medications found in request!")
    SET exec_med = 0
   ENDIF
   RETURN(exec_med)
 END ;Subroutine
 SUBROUTINE parseclosuredevs(null)
   SET closurelinesize = size(request->closuredevline,5)
   IF (closurelinesize > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(closurelinesize))
     PLAN (d
      WHERE (request->closuredevline[d.seq].linedata != " "))
     HEAD REPORT
      closedev_cnt = 0, stat = alterlist(cvrequestin->closure,10)
     DETAIL
      closedev_cnt = (closedev_cnt+ 1)
      IF (mod(closedev_cnt,10)=1
       AND closedev_cnt != 1)
       stat = alterlist(cvrequestin->closure,(closedev_cnt+ 9))
      ENDIF
      effdate_pos = findstring(",",request->closuredevline[d.seq].linedata)
      IF (effdate_pos != 1)
       effdate = substring(1,(effdate_pos - 1),request->closuredevline[d.seq].linedata)
       IF (findstring("/",effdate)=2)
        effdate = build("0",effdate)
       ENDIF
       IF (findstring("/",effdate,4,0)=5)
        effdate = build(substring(1,3,effdate),"0",substring(4,6,effdate))
       ENDIF
       cvrequestin->closure[closedev_cnt].effectivedate = effdate
      ENDIF
      expdate_pos = findstring(",",request->closuredevline[d.seq].linedata,(effdate_pos+ 1))
      IF ((expdate_pos != (effdate_pos+ 1)))
       expdate = substring((effdate_pos+ 1),((expdate_pos - effdate_pos) - 1),request->
        closuredevline[d.seq].linedata)
       IF (findstring("/",expdate)=2)
        expdate = build("0",expdate)
       ENDIF
       IF (findstring("/",expdate,4,0)=5)
        expdate = build(substring(1,3,expdate),"0",substring(4,6,expdate))
       ENDIF
       cvrequestin->closure[closedev_cnt].expirationdate = expdate
      ENDIF
      closedevid_pos = findstring(",",request->closuredevline[d.seq].linedata,(expdate_pos+ 1))
      IF ((closedevid_pos != (expdate_pos+ 1)))
       closedevid_str = substring((expdate_pos+ 1),((closedevid_pos - expdate_pos) - 1),request->
        closuredevline[d.seq].linedata), closedevid = cnvtint(closedevid_str)
       IF (closedevid != 0)
        cvrequestin->closure[closedev_cnt].closuredevid = closedevid
       ENDIF
      ENDIF
      closedevname_pos = textlen(request->closuredevline[d.seq].linedata), closedevname = trim(
       substring((closedevid_pos+ 2),((closedevname_pos - closedevid_pos) - 2),request->
        closuredevline[d.seq].linedata))
      IF (closedevname != " ")
       cvrequestin->closure[closedev_cnt].closuredevname = closedevname
      ENDIF
     FOOT REPORT
      stat = alterlist(cvrequestin->closure,closedev_cnt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_log_message("No closure devices found in request!")
     SET exec_close = 0
    ELSE
     SET exec_close = 1
    ENDIF
   ELSE
    CALL cv_log_message("No closure devices found in request!")
    SET exec_close = 0
   ENDIF
   RETURN(exec_close)
 END ;Subroutine
 SUBROUTINE scriptfailure(message)
   CALL cv_log_message(build("ScriptFailure:",message))
   SET errcnt = (errcnt+ 1)
   SET stat = alterlist(cvreply->lines,errcnt)
   SET cvreply->lines[errcnt].errmsg = nullterm(message)
   SET cvreply->status_data.status = "F"
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE zerorowsfound(message)
   CALL cv_log_message(build("ZeroRowsFound:",message))
   SET errcnt = (errcnt+ 1)
   SET stat = alterlist(cvreply->lines,errcnt)
   SET cvreply->lines[errcnt].errmsg = nullterm(message)
   SET cvreply->status_data.status = "Z"
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF ((cvreply->med_status != "F")
  AND (cvreply->closure_status != "F")
  AND (cvreply->icdev_status != "F")
  AND  NOT ((cvreply->status_data.status IN ("F", "Z"))))
  SET errcnt = (errcnt+ 1)
  SET stat = alterlist(cvreply->lines,errcnt)
  SET cvreply->lines[errcnt].errmsg = "Import was successful!"
  SET cvreply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET cvreply->status_data.status = "S"
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD reply
 RECORD reply(
   1 med_status = c1
   1 closure_status = c1
   1 icdev_status = c1
   1 lines[*]
     2 errmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->lines,errcnt)
 SET reply->med_status = cvreply->med_status
 SET reply->closure_status = cvreply->closure_status
 SET reply->icdev_status = cvreply->icdev_status
 SET reply->status_data.status = cvreply->status_data.status
 FOR (i = 0 TO errcnt)
   SET reply->lines[i].errmsg = cvreply->lines[i].errmsg
 ENDFOR
 CALL cv_log_message("Finished with import!")
 CALL echorecord(reply,"cer_temp:cv_from_csv_reply.dat")
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
 DECLARE cv_upd_from_csv = vc WITH private, constant("MOD 001 03/07/06 BM9013")
END GO
