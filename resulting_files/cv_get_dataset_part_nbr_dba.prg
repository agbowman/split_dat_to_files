CREATE PROGRAM cv_get_dataset_part_nbr:dba
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
 DECLARE cs_alias_pool = i4 WITH protect, constant(263)
 DECLARE cs_prsnl_group_type = i4 WITH protect, constant(19189)
 DECLARE csd_contributor_cvnet = vc WITH protect, constant("CVNET")
 DECLARE csm_alias_pool_accfa = vc WITH protect, constant("CVNET_ACC_FA")
 DECLARE csm_alias_pool_stsfa = vc WITH protect, constant("CVNET_STS_PA")
 DECLARE prsnlgrp_delimstr = vc WITH protect, constant("___")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 alias = vc
      2 source_id = f8
      2 display = vc
      2 alias_type_nbr = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE failure = c1 WITH protect, noconstant("T")
 DECLARE dataset_size = i4 WITH protect, constant(size(cv_omf_rec->dataset,5))
 IF (dataset_size <= 0)
  GO TO exit_script
 ENDIF
 DECLARE count1 = i4 WITH protect
 DECLARE aliascount = i4 WITH protect
 DECLARE aliascount1 = i4 WITH protect
 DECLARE aliascount2 = i4 WITH protect
 DECLARE aliascount3 = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE atleastonesuccess = c1 WITH protect, noconstant("F")
 DECLARE cv_alias_type_org = i4 WITH protect, constant(1)
 DECLARE cv_alias_type_person = i4 WITH protect, constant(2)
 DECLARE cv_alias_type_prsnl_group = i4 WITH protect, constant(3)
 FOR (i = 1 TO dataset_size)
   SET cv_omf_rec->dataset[i].participant_nbr = "<DEF PARTNBR>"
   CALL echo(build("Participant Prsnl Id",cv_omf_rec->dataset[i].participant_prsnl_id))
   CALL echo(build("Participant Org Id",cv_omf_rec->dataset[i].organization_id))
 ENDFOR
 IF (validate(cv_omf_rec->form_type_cd,0.0) > 0.0)
  SELECT
   IF (dataset_size=1)
    WHERE dp.pref_domain="CVNET"
     AND dp.pref_section="ENABLE_RLTN_*"
     AND dp.pref_name="ACC03"
     AND dp.parent_entity_name="ORGANIZATION"
     AND (dp.parent_entity_id=cv_omf_rec->dataset[1].organization_id)
   ELSE
   ENDIF
   INTO "nl:"
   FROM dm_prefs dp
   WHERE dp.pref_domain="CVNET"
    AND dp.pref_section="ENABLE_RLTN_*"
    AND dp.pref_name="ACC03"
    AND dp.parent_entity_name="ORGANIZATION"
    AND expand(idx,1,dataset_size,dp.parent_entity_id,cv_omf_rec->dataset[idx].organization_id)
   DETAIL
    IF (dataset_size=1)
     num = 1
    ELSE
     num = locateval(idx,1,dataset_size,dp.parent_entity_id,cv_omf_rec->dataset[idx].organization_id)
    ENDIF
    cv_omf_rec->dataset[num].participant_nbr = dp.pref_str
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message(build("ERROR: ACC participant verification failed for org_id=",cv_omf_rec->
     dataset[1].organization_id))
  ENDIF
  SET failure = "F"
  GO TO exit_script
 ENDIF
 DECLARE valid_alias_pool_ind = i2 WITH protect
 SELECT
  IF (dataset_size=1)
   WHERE (cd.dataset_id=cv_omf_rec->dataset[1].dataset_id)
  ELSE
  ENDIF
  INTO "nl:"
  FROM cv_dataset cd
  WHERE expand(idx,1,dataset_size,cd.dataset_id,cv_omf_rec->dataset[idx].dataset_id)
  DETAIL
   IF (dataset_size=1)
    num = 1
   ELSE
    num = locateval(idx,1,dataset_size,cd.dataset_id,cv_omf_rec->dataset[idx].dataset_id)
   ENDIF
   cv_omf_rec->dataset[num].alias_pool_mean = cd.alias_pool_mean
  WITH nocounter
 ;end select
 FOR (i = 1 TO dataset_size)
  SET cv_omf_rec->dataset[i].alias_pool_cd = uar_get_code_by("MEANING",cs_alias_pool,cv_omf_rec->
   dataset[i].alias_pool_mean)
  IF ((cv_omf_rec->dataset[i].alias_pool_cd != - (1.0)))
   SET valid_alias_pool_ind = 1
  ELSE
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=cs_alias_pool
     AND (cv.cdf_meaning=cv_omf_rec->dataset[i].alias_pool_mean)
     AND cv.active_ind=1
    DETAIL
     cv_omf_rec->dataset[i].alias_pool_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ((cv_omf_rec->dataset[i].alias_pool_cd <= 0.0))
    CALL cv_log_message(build("Could not find Code Value on CodeSet ",cs_alias_pool,
      " for the CDF Meaning ",cv_omf_rec->dataset[i].alias_pool_mean))
   ELSE
    SET valid_alias_pool_ind = 1
   ENDIF
  ENDIF
 ENDFOR
 IF (valid_alias_pool_ind != 1)
  GO TO prsnl_alias_proc
 ENDIF
 CALL echo(build("The Alias Pool Code is ",cv_omf_rec->dataset[1].alias_pool_cd))
 SELECT
  IF (dataset_size=1)
   WHERE (pa.person_id=cv_omf_rec->dataset[1].participant_prsnl_id)
    AND (pa.alias_pool_cd=cv_omf_rec->dataset[1].alias_pool_cd)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND pa.person_id != 0.0
    AND pa.alias_pool_cd != 0.0
  ELSE
  ENDIF
  INTO "nl:"
  FROM prsnl_alias pa
  PLAN (pa
   WHERE expand(idx,1,dataset_size,pa.person_id,cv_omf_rec->dataset[idx].participant_prsnl_id,
    pa.alias_pool_cd,cv_omf_rec->dataset[idx].alias_pool_cd)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND pa.person_id != 0.0
    AND pa.alias_pool_cd != 0.0)
  DETAIL
   IF (dataset_size=1)
    num = 1
   ELSE
    num = locateval(idx,1,dataset_size,pa.person_id,cv_omf_rec->dataset[idx].participant_prsnl_id,
     pa.alias_pool_cd,cv_omf_rec->dataset[idx].alias_pool_cd)
   ENDIF
   cv_omf_rec->dataset[num].participant_nbr = pa.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No records in Prsnl Alias Pool")
 ELSE
  SET failure = "F"
  GO TO exit_script
 ENDIF
#prsnl_alias_proc
 DECLARE prsnl_group_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   cs_prsnl_group_type,nullterm(csm_alias_pool_stsfa)))
 IF (prsnl_group_class_cd > 0.0)
  SELECT
   IF (dataset_size=1)
    PLAN (pgr
     WHERE (pgr.person_id=cv_omf_rec->dataset[1].participant_prsnl_id)
      AND pgr.active_ind=1)
     JOIN (p
     WHERE p.prsnl_group_class_cd=prsnl_group_class_cd
      AND p.prsnl_group_id=pgr.prsnl_group_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
   ELSE
   ENDIF
   INTO "nl:"
   p.prsnl_group_id
   FROM prsnl_group p,
    prsnl_group_reltn pgr
   PLAN (pgr
    WHERE expand(idx,1,dataset_size,pgr.person_id,cv_omf_rec->dataset[idx].participant_prsnl_id)
     AND pgr.active_ind=1)
    JOIN (p
    WHERE p.prsnl_group_class_cd=prsnl_group_class_cd
     AND p.prsnl_group_id=pgr.prsnl_group_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    IF (dataset_size=1)
     num = 1
    ELSE
     num = locateval(idx,1,dataset_size,pgr.person_id,cv_omf_rec->dataset[idx].participant_prsnl_id)
    ENDIF
    cv_omf_rec->dataset[num].participant_nbr = p.prsnl_group_name, cv_omf_rec->dataset[num].
    participant_nbr = substring((findstring(prsnlgrp_delimstr,p.prsnl_group_desc)+ 3),100,p
     .prsnl_group_desc)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL cv_log_message("No records in Prsnl Grp Alias Pool")
  ELSE
   SET failure = "F"
   GO TO exit_script
  ENDIF
 ELSE
  CALL cv_log_message("No Prsnl Grp Alias Pool found")
 ENDIF
 SELECT
  IF (dataset_size=1
   AND (cv_omf_rec->dataset[1].organization_id != 0.0))
   WHERE (oa.organization_id=cv_omf_rec->dataset[1].organization_id)
    AND (oa.alias_pool_cd=cv_omf_rec->dataset[1].alias_pool_cd)
    AND oa.active_ind=1
  ELSE
  ENDIF
  INTO "nl:"
  FROM organization_alias oa
  WHERE expand(idx,1,dataset_size,oa.organization_id,cv_omf_rec->dataset[idx].organization_id,
   oa.alias_pool_cd,cv_omf_rec->dataset[idx].alias_pool_cd)
   AND oa.active_ind=1
   AND oa.organization_id != 0.0
  DETAIL
   IF (dataset_size=1)
    num = 1
   ELSE
    num = locateval(idx,1,dataset_size,oa.organization_id,cv_omf_rec->dataset[idx].organization_id,
     oa.alias_pool_cd,cv_omf_rec->dataset[idx].alias_pool_cd)
   ENDIF
   cv_omf_rec->dataset[num].participant_nbr = oa.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message(build("No records in Org Alias Pool for Org ID::",cv_omf_rec->dataset[1].
    organization_id))
 ELSE
  SET failure = "F"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failure="F")
  CALL cv_log_message("Participant Nbr Found!!")
  SET reply->status_data.status = "S"
 ELSE
  CALL cv_log_message(build("Participant Nbr not found"))
 ENDIF
 FOR (i = 1 TO dataset_size)
   CALL cv_log_message(build("DataSet::",i,"::PartNbr::",cv_omf_rec->dataset[i].participant_nbr))
 ENDFOR
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
 DECLARE cv_get_dataset_part_nbr_vrsn = vc WITH private, constant("MOD 006 05/05/06 BM9013")
END GO
