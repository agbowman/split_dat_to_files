CREATE PROGRAM dcp_chg_dtawizard_dtainfo:dba
 SET modify = predeclare
 FREE RECORD internal
 RECORD internal(
   1 qual[*]
     2 ref_range_id = f8
 )
 FREE RECORD rules
 RECORD rules(
   1 qual[*]
     2 rule_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 dup_ind = i2
   1 table_ind = i2
   1 ref_range_ind = i2
   1 ref_rule_ind = i2
   1 alpha_rule_ind = i2
   1 alpha_ind = i2
   1 data_map_ind = i2
   1 event_cd = f8
   1 offset_min_ind = i2
   1 cve_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD version_request
 RECORD version_request(
   1 task_assay_cd = f8
 )
 FREE RECORD version_reply
 RECORD version_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET string_struct
 RECORD string_struct(
   1 err_msg = vc
 )
 DECLARE ref_range_cnt = i2 WITH protect, noconstant(0)
 DECLARE tmp_ref_range_cnt = i2 WITH protect, noconstant(0)
 DECLARE temp_event_cd = f8 WITH protect, noconstant(0.0)
 DECLARE temp_task_description = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE zero_row = i2 WITH protect, noconstant(0)
 DECLARE num_alphas = i2 WITH protect, noconstant(0)
 DECLARE num_rules = i4 WITH protect, noconstant(0)
 DECLARE version_fail = i2 WITH protect, noconstant(0)
 DECLARE human_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",226,"HUMAN"))
 DECLARE numeric_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE calculation_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"8"))
 DECLARE count_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"13"))
 DECLARE alpha_response_rule_id = f8 WITH protect, noconstant(0.0)
 DECLARE field_value = vc WITH protect, noconstant("")
 DECLARE alpha_ind = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE icount = i4 WITH protect, noconstant(0)
 DECLARE script_version = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
   CALL echo("*DEBUG MODE - ON - DCP_CHG_DTAWIZARD_DTAINFO*")
  ENDIF
 ENDIF
 DECLARE upd_offset_min() = null
 DECLARE update_categories(null) = null
 DECLARE delete_categories(null) = null
 DECLARE enone = i2 WITH protect, constant(0)
 DECLARE eadd = i2 WITH protect, constant(1)
 DECLARE emod = i2 WITH protect, constant(2)
 DECLARE edel = i2 WITH protect, constant(3)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE cataddseq = f8 WITH protect, noconstant(0.0)
 DECLARE category_idx = i4 WITH protect, noconstant(0)
 DECLARE category_cnt = i4 WITH protect, noconstant(0)
 DECLARE ref_idx = i4 WITH protect, noconstant(0)
 DECLARE ref_cnt = i4 WITH protect, noconstant(0)
 DECLARE alpha_idx = i4 WITH protect, noconstant(0)
 DECLARE alpha_cnt = i4 WITH protect, noconstant(0)
 SUBROUTINE delete_categories(null)
   SET ref_cnt = size(request->ref_range,5)
   FOR (ref_idx = 1 TO ref_cnt)
     CALL echo(build("Ref_idx: ",ref_idx," Ref_cnt: ",ref_cnt))
     SET category_cnt = size(request->ref_range[ref_idx].categories,5)
     FOR (category_idx = 1 TO category_cnt)
       CALL echo(build("Category_idx: ",category_idx," category_cnt: ",category_cnt))
       CALL del_category(category_idx)
       IF ((reply->status_data.status="F"))
        SET reqinfo->commit_ind = 0
        GO TO enddelcat
       ENDIF
     ENDFOR
   ENDFOR
#enddelcat
   IF ((reply->status_data.status != "F"))
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_category(upd_ref_idx=i4) =i2)
   SET ref_idx = upd_ref_idx
   CALL echo(build("Ref_idx: ",ref_idx))
   SET category_cnt = size(request->ref_range[ref_idx].categories,5)
   FOR (category_idx = 1 TO category_cnt)
     CALL echo(build("Category_idx: ",category_idx," category_cnt: ",category_cnt))
     IF ((request->ref_range[ref_idx].categories[category_idx].mod=eadd))
      CALL add_category(category_idx)
     ELSEIF ((((request->ref_range[ref_idx].categories[category_idx].mod=emod)) OR ((request->
     ref_range[ref_idx].categories[category_idx].mod=enone))) )
      CALL upd_category(category_idx)
     ELSEIF ((request->ref_range[ref_idx].categories[category_idx].mod=edel))
      SET stat = 0
     ELSE
      SET reply->status_data.status = "F"
     ENDIF
     IF ((reply->status_data.status="F"))
      SET reqinfo->commit_ind = 0
      GO TO endupdcatidx
     ENDIF
   ENDFOR
#endupdcatidx
   IF ((reply->status_data.status != "F"))
    SET reply->status_data.status = "S"
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 SUBROUTINE update_categories(null)
   SET ref_cnt = size(request->ref_range,5)
   FOR (upd_ref_idx = 1 TO ref_cnt)
    CALL echo(build("upd_ref_idx: ",upd_ref_idx," Ref_cnt: ",ref_cnt))
    IF (update_category(upd_ref_idx)=false)
     GO TO endupdcat
    ENDIF
   ENDFOR
#endupdcat
 END ;Subroutine
 SUBROUTINE (add_category(add_idx=i4) =null)
   CALL echo(build("Add_idx: ",add_idx))
   SET alpha_idx = 0
   SET alpha_cnt = 0
   SELECT INTO "nl:"
    cataddseqfromdual = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     cataddseq = cataddseqfromdual
    WITH nocounter
   ;end select
   INSERT  FROM alpha_responses_category arc
    SET alpha_responses_category_id = cataddseq, category_name = request->ref_range[ref_idx].
     categories[add_idx].category_name, display_seq = request->ref_range[ref_idx].categories[add_idx]
     .category_sequence,
     expand_flag = request->ref_range[ref_idx].categories[add_idx].expand_flag,
     reference_range_factor_id = request->ref_range[ref_idx].ref_id, updt_dt_tm = cnvtdatetime(
      sysdate),
     updt_cnt = 1
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO endadd
   ENDIF
   SET alpha_cnt = size(request->ref_range[ref_idx].alpha,5)
   FOR (alpha_idx = 1 TO alpha_cnt)
    CALL echo(build("alpha_idx: ",alpha_idx," alpha_cnt: ",alpha_cnt))
    IF ((request->ref_range[ref_idx].alpha[alpha_idx].placeholder_category_id=request->ref_range[
    ref_idx].categories[add_idx].placeholder_category_id))
     SET request->ref_range[ref_idx].alpha[alpha_idx].category_id = cataddseq
    ENDIF
   ENDFOR
#endadd
 END ;Subroutine
 SUBROUTINE (upd_category(upd_idx=i4) =null)
   CALL echo(build("Upd_idx: ",upd_idx))
   INSERT  FROM alpha_responses_category arc
    SET alpha_responses_category_id = request->ref_range[ref_idx].categories[upd_idx].category_id,
     category_name = request->ref_range[ref_idx].categories[upd_idx].category_name, display_seq =
     request->ref_range[ref_idx].categories[upd_idx].category_sequence,
     expand_flag = request->ref_range[ref_idx].categories[upd_idx].expand_flag,
     reference_range_factor_id = request->ref_range[ref_idx].ref_id, updt_dt_tm = cnvtdatetime(
      sysdate),
     updt_cnt = 1
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO endupd
   ENDIF
#endupd
 END ;Subroutine
 SUBROUTINE (del_category(del_idx=i4) =null)
   CALL echo(build("Del_idx: ",del_idx))
   SET alpha_idx = 0
   SET alpha_cnt = 0
   SET alpha_cnt = size(request->ref_range[ref_idx].alpha,5)
   IF ((request->ref_range[ref_idx].categories[del_idx].mod=edel))
    FOR (alpha_idx = 1 TO alpha_cnt)
      IF ((request->ref_range[ref_idx].alpha[alpha_idx].category_id=request->ref_range[ref_idx].
      categories[del_idx].category_id))
       SET reply->status_data.status = "F"
       GO TO enddel
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->ref_range[ref_idx].categories[del_idx].mod IN (edel, emod, enone)))
    DELETE  FROM alpha_responses_category
     WHERE (alpha_responses_category_id=request->ref_range[ref_idx].categories[del_idx].category_id)
    ;end delete
    IF (curqual=0)
     SET reply->status_data.status = "F"
     GO TO enddel
    ENDIF
   ENDIF
#enddel
 END ;Subroutine
 IF ((request->task_assay_cd=0))
  SET zero_row = 1
  SET reply->status_data.targetobjectvalue = "Attempted to use a task_assay_cd of zero."
  GO TO chg_failed
 ENDIF
 IF ((request->build_event_cd_ind=1))
  SET temp_task_description = substring(1,40,request->mnemonic)
  SET temp_event_cd = 0.0
  SET modify = nopredeclare
  EXECUTE tsk_post_event_code
  SET modify = predeclare
  SET request->event_cd = temp_event_cd
  SET reply->event_cd = temp_event_cd
 ENDIF
 IF (checkprg("DCP_ADD_DTA_VERSION"))
  SET request->task_assay_cd = request->task_assay_cd
  SET modify = nopredeclare
  EXECUTE dcp_add_dta_version  WITH replace("REPLY","VERSION_REPLY")
  SET modify = predeclare
  IF ((version_reply->status_data.status="F"))
   SET version_fail = 1
   SET reply->status_data.targetobjectvalue = build("Update aborted.  DTA Versioning failed:",
    version_reply->status_data.subeventstatus[1].targetobjectvalue)
   GO TO chg_failed
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value_extension cve
  WHERE (cve.code_value=request->task_assay_cd)
  DETAIL
   field_value = cve.field_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF ((request->witness_required_ind=1))
   INSERT  FROM code_value_extension cve
    SET cve.code_value = request->task_assay_cd, cve.field_name = "dta_witness_required_ind", cve
     .code_set = 14003,
     cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm = cnvtdatetime(sysdate), cve.field_type
      = 0,
     cve.field_value = "1", cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task
   ;end insert
   IF (curqual=0)
    SET reply->cve_ind = 1
    SET reply->status_data.targetobjectvalue = "Failed on insert to code_value_extension table."
    GO TO chg_failed
   ENDIF
  ENDIF
 ELSEIF (curqual=1)
  IF ((request->witness_required_ind=1))
   IF (((field_value="0") OR (field_value != "1")) )
    UPDATE  FROM code_value_extension cve
     SET cve.field_value = "1"
     WHERE (cve.code_value=request->task_assay_cd)
     WITH nocounter
    ;end update
   ENDIF
  ELSEIF ((request->witness_required_ind=0))
   IF (field_value="1")
    UPDATE  FROM code_value_extension cve
     SET cve.field_value = "0"
     WHERE (cve.code_value=request->task_assay_cd)
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM discrete_task_assay d
  WHERE (d.task_assay_cd=request->task_assay_cd)
  WITH forupdate(d)
 ;end select
 IF (curqual=0)
  SET zero_row = 1
  SET reply->status_data.targetobjectvalue =
  "Could not obtain a lock on the discrete_task_assay table."
  GO TO chg_failed
 ENDIF
 UPDATE  FROM discrete_task_assay d
  SET d.mnemonic = request->mnemonic, d.mnemonic_key_cap = trim(cnvtupper(request->mnemonic)), d
   .activity_type_cd = request->activity_type_cd,
   d.default_result_type_cd = request->default_result_type_cd, d.event_cd = request->event_cd, d
   .modifier_ind = request->modifier_ind,
   d.single_select_ind = request->single_select_ind, d.default_type_flag = request->default_type_flag,
   d.description = request->description,
   d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate), d.updt_id = reqinfo->updt_id,
   d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.code_set = request->
   code_set,
   d.concept_cki = request->concept_cki, d.io_flag = request->io_flag, d.template_script_cd =
   validate(request->template_script_cd,0.0)
  WHERE (d.task_assay_cd=request->task_assay_cd)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->table_ind = 1
  SET reply->status_data.targetobjectvalue = "Update failed on discrete_task_assay table."
  GO TO chg_failed
 ENDIF
 SET modify = nopredeclare
 EXECUTE gm_code_value0619_def "U"
 SUBROUTINE (gm_u_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_value":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->code_valuef = 1
     SET gm_u_code_value0619_req->qual[iqual].code_value = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->code_valuew = 1
     ENDIF
    OF "active_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->active_type_cdf = 1
     SET gm_u_code_value0619_req->qual[iqual].active_type_cd = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_type_cdw = 1
     ENDIF
    OF "data_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->data_status_cdf = 1
     SET gm_u_code_value0619_req->qual[iqual].data_status_cd = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_cdw = 1
     ENDIF
    OF "data_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->data_status_prsnl_idf = 1
     SET gm_u_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_prsnl_idw = 1
     ENDIF
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->active_status_prsnl_idf = 1
     SET gm_u_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_status_prsnl_idw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->active_indf = 2
     ELSE
      SET gm_u_code_value0619_req->active_indf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].active_ind = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_indw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "code_set":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->code_setf = 1
     SET gm_u_code_value0619_req->qual[iqual].code_set = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->code_setw = 1
     ENDIF
    OF "collation_seq":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->collation_seqf = 2
     ELSE
      SET gm_u_code_value0619_req->collation_seqf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].collation_seq = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->collation_seqw = 1
     ENDIF
    OF "updt_cnt":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->updt_cntf = 1
     SET gm_u_code_value0619_req->qual[iqual].updt_cnt = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->updt_cntw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->active_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->active_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->active_dt_tmw = 1
     ENDIF
    OF "inactive_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->inactive_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->inactive_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->inactive_dt_tmw = 1
     ENDIF
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->updt_dt_tmf = 1
     SET gm_u_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->updt_dt_tmw = 1
     ENDIF
    OF "begin_effective_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->begin_effective_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->begin_effective_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->begin_effective_dt_tmw = 1
     ENDIF
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->end_effective_dt_tmf = 1
     SET gm_u_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->end_effective_dt_tmw = 1
     ENDIF
    OF "data_status_dt_tm":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->data_status_dt_tmf = 2
     ELSE
      SET gm_u_code_value0619_req->data_status_dt_tmf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->data_status_dt_tmw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_u_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2,wq_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_u_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_u_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "cdf_meaning":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->cdf_meaningf = 2
     ELSE
      SET gm_u_code_value0619_req->cdf_meaningf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].cdf_meaning = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->cdf_meaningw = 1
     ENDIF
    OF "display":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->displayf = 2
     ELSE
      SET gm_u_code_value0619_req->displayf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].display = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->displayw = 1
     ENDIF
    OF "display_key":
     SET gm_u_code_value0619_req->qual[iqual].display_key = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->display_keyw = 1
     ENDIF
    OF "description":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->descriptionf = 2
     ELSE
      SET gm_u_code_value0619_req->descriptionf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].description = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->descriptionw = 1
     ENDIF
    OF "definition":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->definitionf = 2
     ELSE
      SET gm_u_code_value0619_req->definitionf = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].definition = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->definitionw = 1
     ENDIF
    OF "cki":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_u_code_value0619_req->ckif = 1
     SET gm_u_code_value0619_req->qual[iqual].cki = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->ckiw = 1
     ENDIF
    OF "concept_cki":
     IF (null_ind=1)
      SET gm_u_code_value0619_req->concept_ckif = 2
     ELSE
      SET gm_u_code_value0619_req->concept_ckif = 1
     ENDIF
     SET gm_u_code_value0619_req->qual[iqual].concept_cki = ival
     IF (wq_ind=1)
      SET gm_u_code_value0619_req->concept_ckiw = 1
     ENDIF
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET modify = predeclare
 SET stat = alterlist(gm_u_code_value0619_req->qual,1)
 SET gm_u_code_value0619_req->code_valuew = 1
 SET gm_u_code_value0619_req->force_updt_ind = 1
 SET gm_u_code_value0619_req->displayf = 1
 SET gm_u_code_value0619_req->descriptionf = 1
 SET gm_u_code_value0619_req->definitionf = 1
 SET gm_u_code_value0619_req->qual[1].code_value = request->task_assay_cd
 SET gm_u_code_value0619_req->qual[1].display = request->mnemonic
 SET gm_u_code_value0619_req->qual[1].description = request->description
 SET gm_u_code_value0619_req->qual[1].definition = request->description
 SET modify = nopredeclare
 EXECUTE gm_u_code_value0619  WITH replace("REQUEST",gm_u_code_value0619_req), replace("REPLY",
  gm_u_code_value0619_rep)
 SET modify = predeclare
 IF ((gm_u_code_value0619_rep->curqual=0)
  AND (gm_u_code_value0619_rep->status_data.status="F"))
  SET reply->table_ind = 1
  SET reply->status_data.targetobjectvalue = "Update failed on code_value table."
  GO TO chg_failed
 ENDIF
 FREE RECORD gm_u_code_value0619_req
 FREE RECORD gm_u_code_value0619_rep
 CALL upd_offset_min(null)
 SET ref_range_cnt = request->ref_range_cnt
 IF (ref_range_cnt=0)
  GO TO continue
 ENDIF
 IF (ref_range_cnt > 0)
  SELECT INTO "nl:"
   r.reference_range_factor_id
   FROM reference_range_factor r
   WHERE (r.task_assay_cd=request->task_assay_cd)
    AND r.active_ind=1
   HEAD REPORT
    tmp_ref_range_cnt = tmp_ref_range_cnt
   DETAIL
    tmp_ref_range_cnt += 1
    IF (tmp_ref_range_cnt > size(internal->qual,5))
     stat = alterlist(internal->qual,(tmp_ref_range_cnt+ 2))
    ENDIF
    internal->qual[tmp_ref_range_cnt].ref_range_id = r.reference_range_factor_id
   FOOT REPORT
    stat = alterlist(internal->qual,tmp_ref_range_cnt)
   WITH nocounter
  ;end select
  IF (tmp_ref_range_cnt > 0)
   CALL delete_categories(null)
   IF ((reply->status_data.status="F"))
    SET alpha_ind = 1
    SET reply_status_data->targetobjectvalue = "Error with category transaction."
    GO TO chg_failed
   ENDIF
   DECLARE num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM ref_range_factor_rule rrfr
    WHERE expand(num,1,tmp_ref_range_cnt,rrfr.reference_range_factor_id,internal->qual[num].
     ref_range_id)
     AND rrfr.active_ind=1
    HEAD REPORT
     num_rules = 0
    DETAIL
     num_rules += 1
     IF (num_rules > size(rules->qual,5))
      stat = alterlist(rules->qual,(num_rules+ 2))
     ENDIF
     rules->qual[num_rules].rule_id = rrfr.ref_range_factor_rule_id
    FOOT REPORT
     stat = alterlist(rules->qual,num_rules)
    WITH nocounter, forupdate(rrfr)
   ;end select
   IF (num_rules > 0)
    UPDATE  FROM alpha_response_rule arr
     SET arr.active_ind = 0
     WHERE expand(num,1,tmp_ref_range_cnt,arr.reference_range_factor_id,internal->qual[num].
      ref_range_id)
      AND arr.active_ind=1
     WITH nocounter
    ;end update
    IF (error(string_struct->err_msg,0) != 0)
     CALL echo(build("alpha rule update error: ",string_struct->err_msg))
    ENDIF
    UPDATE  FROM ref_range_factor_rule rrfr
     SET rrfr.active_ind = 0
     WHERE expand(num,1,tmp_ref_range_cnt,rrfr.reference_range_factor_id,internal->qual[num].
      ref_range_id)
      AND rrfr.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual != num_rules)
     SET zero_row = 1
     SET reply->status_data.targetobjectvalue = build(
      "Number of reference range factor rules to update (",num_rules,(") does not"+
      "equal number updated ("),curqual,").")
     GO TO chg_failed
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM alpha_responses a,
     (dummyt d  WITH seq = value(tmp_ref_range_cnt))
    PLAN (d)
     JOIN (a
     WHERE (a.reference_range_factor_id=internal->qual[d.seq].ref_range_id)
      AND a.active_ind=1)
    WITH nocounter, forupdate(a)
   ;end select
   SET num_alphas = curqual
   IF (num_alphas > 0)
    UPDATE  FROM alpha_responses a,
      (dummyt d  WITH seq = value(tmp_ref_range_cnt))
     SET a.seq = 1, a.active_ind = 0
     PLAN (d)
      JOIN (a
      WHERE (a.reference_range_factor_id=internal->qual[d.seq].ref_range_id)
       AND a.active_ind=1)
     WITH nocounter
    ;end update
    IF (curqual != num_alphas)
     SET zero_row = 1
     SET reply->status_data.targetobjectvalue = build("Number of alpha details to update (",
      num_alphas,") does not equal number updated (",curqual,").")
     GO TO chg_failed
    ENDIF
   ENDIF
   UPDATE  FROM reference_range_factor r,
     (dummyt d1  WITH seq = value(tmp_ref_range_cnt))
    SET r.seq = 1, r.active_ind = 0, r.end_effective_dt_tm = cnvtdatetime(sysdate),
     r.active_status_dt_tm = cnvtdatetime(sysdate), r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_cnt
      = (r.updt_cnt+ 1),
     r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_id = reqinfo->
     updt_id
    PLAN (d1)
     JOIN (r
     WHERE (r.reference_range_factor_id=internal->qual[d1.seq].ref_range_id)
      AND r.reference_range_factor_id > 0
      AND r.active_ind=1)
    WITH nocounter
   ;end update
   IF (curqual != value(tmp_ref_range_cnt))
    SET zero_row = 1
    SET reply->status_data.targetobjectvalue = build("Number of ref ranges to update (",
     tmp_ref_range_cnt,") does not equal number updated (",curqual,").")
    GO TO chg_failed
   ENDIF
  ENDIF
  FOR (x = 1 TO ref_range_cnt)
    SELECT INTO "nl:"
     nextseqnum = seq(reference_seq,nextval)"####################################;rp0"
     FROM dual
     DETAIL
      request->ref_range[x].ref_id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    IF ((request->ref_range[x].ref_id=0))
     SET zero_row = 1
     SET reply->status_data.targetobjectvalue =
     "Attempted to use a reference_range_factor_id of zero."
     GO TO chg_failed
    ENDIF
    INSERT  FROM reference_range_factor r
     SET r.reference_range_factor_id = request->ref_range[x].ref_id, r.ref_range_rule_ind = request->
      ref_range[x].rule_ind, r.service_resource_cd = request->ref_range[x].service_resource_cd,
      r.task_assay_cd = request->task_assay_cd, r.species_cd = human_cd, r.organism_cd = request->
      ref_range[x].organism_cd,
      r.unknown_age_ind = request->ref_range[x].unknown_age_ind, r.sex_cd = request->ref_range[x].
      sex_cd, r.age_from_units_cd = request->ref_range[x].age_from_units_cd,
      r.age_from_minutes = request->ref_range[x].age_from_minutes, r.age_to_units_cd = request->
      ref_range[x].age_to_units_cd, r.age_to_minutes = request->ref_range[x].age_to_minutes,
      r.specimen_type_cd = request->ref_range[x].specimen_type_cd, r.patient_condition_cd = request->
      ref_range[x].patient_condition_cd, r.def_result_ind = request->ref_range[x].def_result_ind,
      r.default_result = request->ref_range[x].default_result, r.units_cd = request->ref_range[x].
      units_cd, r.review_ind = request->ref_range[x].review_ind,
      r.review_low = request->ref_range[x].review_low, r.review_high = request->ref_range[x].
      review_high, r.feasible_ind = request->ref_range[x].feasible_ind,
      r.feasible_low = request->ref_range[x].feasible_low, r.feasible_high = request->ref_range[x].
      feasible_high, r.linear_ind = request->ref_range[x].linear_ind,
      r.linear_low = request->ref_range[x].linear_low, r.linear_high = request->ref_range[x].
      linear_high, r.normal_ind = request->ref_range[x].normal_ind,
      r.normal_low = request->ref_range[x].normal_low, r.normal_high = request->ref_range[x].
      normal_high, r.critical_ind = request->ref_range[x].critical_ind,
      r.critical_low = request->ref_range[x].critical_low, r.critical_high = request->ref_range[x].
      critical_high, r.dilute_ind = request->ref_range[x].dilute_ind,
      r.delta_check_type_cd = request->ref_range[x].delta_check_type_cd, r.delta_minutes = request->
      ref_range[x].delta_minutes, r.delta_value = request->ref_range[x].delta_value,
      r.delta_chk_flag = request->ref_range[x].delta_chk_flag, r.gestational_ind = request->
      ref_range[x].gestational_ind, r.precedence_sequence = request->ref_range[x].precedence_sequence,
      r.mins_back = request->ref_range[x].mins_back, r.active_ind = 1, r.active_status_cd = reqdata->
      active_status_cd,
      r.active_status_prsnl_id = reqinfo->updt_id, r.active_status_dt_tm = cnvtdatetime(sysdate), r
      .beg_effective_dt_tm = cnvtdatetime(sysdate),
      r.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), r.updt_dt_tm = cnvtdatetime(
       sysdate), r.updt_id = reqinfo->updt_id,
      r.updt_task = reqinfo->updt_task, r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx,
      r.sensitive_ind = validate(request->ref_range[x].sensitive_ind,0), r.sensitive_low = validate(
       request->ref_range[x].sensitive_low,0.0), r.sensitive_high = validate(request->ref_range[x].
       sensitive_high,0.0),
      r.alpha_response_ind = validate(request->ref_range[x].alpha_response_ind,0), r.encntr_type_cd
       = validate(request->ref_range[x].encntr_type_cd,0.0), r.code_set = validate(request->
       ref_range[x].code_set,0)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->ref_range_ind = 1
     SET reply->status_data.targetobjectvalue = "Insert failed on reference_range_factor table."
     GO TO chg_failed
    ENDIF
    CALL update_category(x)
    IF ((reply->status_data.status="F"))
     SET alpha_ind = 1
     SET reply_status_data->targetobjectvalue = "Error with category transaction."
     GO TO chg_failed
    ENDIF
    SET alpha_cnt = size(request->ref_range[x].alpha,5)
    IF ((request->ref_range[x].alpha_cnt > 0))
     INSERT  FROM alpha_responses a,
       (dummyt d  WITH seq = value(request->ref_range[x].alpha_cnt))
      SET a.reference_range_factor_id = request->ref_range[x].ref_id, a.sequence = request->
       ref_range[x].alpha[d.seq].sequence, a.nomenclature_id = request->ref_range[x].alpha[d.seq].
       nomenclature_id,
       a.use_units_ind = 0, a.result_process_cd = 0, a.default_ind = request->ref_range[x].alpha[d
       .seq].default_ind,
       a.reference_ind = 0, a.active_ind = 1, a.result_value = request->ref_range[x].alpha[d.seq].
       result_value,
       a.multi_alpha_sort_order = request->ref_range[x].alpha[d.seq].multi_alpha_sort_order, a
       .active_status_cd = reqdata->active_status_cd, a.active_status_prsnl_id = reqinfo->updt_id,
       a.active_status_dt_tm = cnvtdatetime(sysdate), a.beg_effective_dt_tm = cnvtdatetime(sysdate),
       a.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
       a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->
       updt_task,
       a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx, a.alpha_responses_category_id =
       request->ref_range[x].alpha[d.seq].category_id,
       a.concept_cki = request->ref_range[x].alpha[d.seq].concept_cki, a.truth_state_cd = request->
       ref_range[x].alpha[d.seq].truth_state_cd
      PLAN (d)
       JOIN (a)
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=0)
     SET reply->alpha_ind = 1
     SET reply->status_data.targetobjectvalue = "Insert failed on alpha_responses table."
     GO TO chg_failed
    ENDIF
    IF ((request->ref_range[x].rule_cnt > 0))
     CALL echo(build("rule_cnt1:",request->ref_range[x].rule_cnt))
     CALL echo(build("x:",x))
     FOR (y = 1 TO request->ref_range[x].rule_cnt)
       SELECT INTO "nl:"
        nextseqnum = seq(reference_seq,nextval)"####################################;rp0"
        FROM dual
        DETAIL
         request->ref_range[x].rule[y].rule_id = cnvtreal(nextseqnum)
        WITH nocounter
       ;end select
       CALL echo(build("y:",y))
       CALL echo(build("rule_id:",request->ref_range[x].rule[y].rule_id))
       CALL echo(build("ref_id:",request->ref_range[x].ref_id))
       INSERT  FROM ref_range_factor_rule rr
        SET rr.reference_range_factor_id = request->ref_range[x].ref_id, rr.active_ind = 1, rr
         .ref_range_factor_rule_id = request->ref_range[x].rule[y].rule_id,
         rr.feasible_limit_ind = request->ref_range[x].rule[y].feasible_ind, rr.feasible_low =
         request->ref_range[x].rule[y].feasible_low, rr.feasible_high = request->ref_range[x].rule[y]
         .feasible_high,
         rr.normal_limit_ind = request->ref_range[x].rule[y].normal_ind, rr.normal_low = request->
         ref_range[x].rule[y].normal_low, rr.normal_high = request->ref_range[x].rule[y].normal_high,
         rr.critical_limit_ind = request->ref_range[x].rule[y].critical_ind, rr.critical_low =
         request->ref_range[x].rule[y].critical_low, rr.critical_high = request->ref_range[x].rule[y]
         .critical_high,
         rr.from_gestation_days = request->ref_range[x].rule[y].gestation_from_age_in_days, rr
         .to_gestation_days = request->ref_range[x].rule[y].gestation_to_age_in_days, rr.from_weight
          = request->ref_range[x].rule[y].from_weight,
         rr.to_weight = request->ref_range[x].rule[y].to_weight, rr.from_weight_unit_cd = request->
         ref_range[x].rule[y].from_weight_unit_cd, rr.to_weight_unit_cd = request->ref_range[x].rule[
         y].to_weight_unit_cd,
         rr.from_height = request->ref_range[x].rule[y].from_height, rr.to_height = request->
         ref_range[x].rule[y].to_height, rr.from_height_unit_cd = request->ref_range[x].rule[y].
         from_height_unit_cd,
         rr.to_height_unit_cd = request->ref_range[x].rule[y].to_height_unit_cd, rr.location_cd =
         request->ref_range[x].rule[y].location_cd, rr.default_result_ind = request->ref_range[x].
         rule[y].def_result_ind,
         rr.default_result_value = request->ref_range[x].rule[y].default_result, rr
         .result_measurement_unit_cd = request->ref_range[x].rule[y].units_cd
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET reply->ref_rule_ind = 1
        SET reply->status_data.targetobjectvalue = "Failed on insert to ref_range_factor_rule table."
        GO TO chg_failed
       ENDIF
       IF ((request->ref_range[x].rule[y].alpha_rule_cnt > 0))
        CALL echo(build("rule_id:",request->ref_range[x].rule[y].rule_id))
        CALL echo(build("ref_id:",request->ref_range[x].ref_id))
        CALL echo(build("alpha_rule_cnt:",request->ref_range[x].rule[y].alpha_rule_cnt))
        FOR (icount = 1 TO request->ref_range[x].rule[y].alpha_rule_cnt)
          SELECT INTO "nl:"
           nextseqnum = seq(reference_seq,nextval)"####################################;rp0"
           FROM dual
           DETAIL
            alpha_response_rule_id = cnvtreal(nextseqnum)
           WITH nocounter
          ;end select
          CALL echo(build("alpha_response_rule_id:",alpha_response_rule_id))
          INSERT  FROM alpha_response_rule arr
           SET arr.nomenclature_id = request->ref_range[x].rule[y].alpha_rule[icount].nomenclature_id,
            arr.reference_range_factor_id = request->ref_range[x].ref_id, arr
            .ref_range_factor_rule_id = request->ref_range[x].rule[y].rule_id,
            arr.alpha_response_rule_id = alpha_response_rule_id, arr.active_ind = 1
           WITH nocounter
          ;end insert
          IF (curqual=0)
           SET reply->alpha_rule_ind = 1
           SET reply->status_data.targetobjectvalue =
           "Failed on insert to alpha_response_rule table."
           GO TO chg_failed
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
#continue
 SELECT INTO "nl:"
  FROM data_map dm
  WHERE (dm.task_assay_cd=request->task_assay_cd)
   AND dm.service_resource_cd IN (0, - (1))
  WITH nocounter, forupdate(dm)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM data_map n
   SET n.seq = 1, n.max_digits = request->max_digits, n.min_digits = request->min_digits,
    n.min_decimal_places = request->min_decimal_places, n.updt_dt_tm = cnvtdatetime(sysdate), n
    .updt_cnt = (n.updt_cnt+ 1),
    n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
    updt_applctx
   WHERE (n.task_assay_cd=request->task_assay_cd)
    AND n.service_resource_cd IN (0, - (1))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.targetobjectvalue = "Update failed on data_map table."
   SET reply->data_map_ind = 1
  ENDIF
 ELSEIF ((((request->default_result_type_cd=numeric_cd)) OR ((((request->default_result_type_cd=
 calculation_cd)) OR ((request->default_result_type_cd=count_cd))) )) )
  INSERT  FROM data_map n
   SET n.seq = 1, n.task_assay_cd = request->task_assay_cd, n.service_resource_cd = 0,
    n.data_map_type_flag = 0, n.active_ind = 1, n.active_status_cd = reqdata->active_status_cd,
    n.active_status_prsnl_id = reqinfo->updt_id, n.active_status_dt_tm = cnvtdatetime(sysdate), n
    .beg_effective_dt_tm = cnvtdatetime(sysdate),
    n.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), n.result_entry_format = 0, n
    .max_digits = request->max_digits,
    n.min_digits = request->min_digits, n.min_decimal_places = request->min_decimal_places, n
    .updt_dt_tm = cnvtdatetime(sysdate),
    n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_cnt = 0,
    n.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.targetobjectvalue = "Insert failed on data_map table."
   SET reply->data_map_ind = 1
   GO TO chg_failed
  ENDIF
 ENDIF
 SUBROUTINE upd_offset_min(null)
   DECLARE new_offset_min_id = f8 WITH noconstant(0.0), protect
   DECLARE cnt_offset = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dta_offset_min do
    WHERE (do.task_assay_cd=request->task_assay_cd)
     AND do.active_ind=1
    WITH nocounter, forupdate(do)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM dta_offset_min dom
     SET dom.active_ind = 0
     WHERE (dom.task_assay_cd=request->task_assay_cd)
      AND dom.active_ind=1
     WITH nocounter
    ;end update
   ENDIF
   FOR (cnt_offset = 1 TO request->offset_min_cnt)
     SELECT INTO "nl:"
      nextseqnum = seq(reference_seq,nextval)"################################;rp0"
      FROM dual
      DETAIL
       new_offset_min_id = cnvtreal(nextseqnum)
      WITH nocounter
     ;end select
     CALL echo(build("task_assay_cd:",request->task_assay_cd))
     CALL echo(build("offset_min_type_cd:",request->offset_mins[cnt_offset].offset_min_type_cd))
     CALL echo(build("offset_min_nbr:",request->offset_mins[cnt_offset].offset_min_nbr))
     INSERT  FROM dta_offset_min dom
      SET dom.dta_offset_min_id = new_offset_min_id, dom.task_assay_cd = request->task_assay_cd, dom
       .offset_min_type_cd = request->offset_mins[cnt_offset].offset_min_type_cd,
       dom.offset_min_nbr = request->offset_mins[cnt_offset].offset_min_nbr, dom.beg_effective_dt_tm
        = cnvtdatetime(sysdate), dom.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
       dom.active_ind = 1, dom.updt_cnt = 0, dom.updt_dt_tm = cnvtdatetime(sysdate),
       dom.updt_id = reqinfo->updt_id, dom.updt_task = reqinfo->updt_task, dom.updt_applctx = reqinfo
       ->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET reply->offset_min_ind = 1
      SET reply->status_data.targetobjectvalue = "Failed on insert into DTA_OFFSET_MIN table."
      CALL echo("Failed on insert into DTA_OFFSET_MIN table.")
      GO TO chg_failed
     ENDIF
     CALL echo(build("curqual: ",curqual))
   ENDFOR
 END ;Subroutine
#chg_failed
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_chg_dtawizard_dtainfo",error_msg)
  SET reqinfo->commit_ind = 0
 ELSEIF ((((reply->dup_ind=1)) OR ((((reply->table_ind=1)) OR ((((reply->ref_range_ind=1)) OR ((((
 reply->alpha_ind=1)) OR (((zero_row=1) OR ((((reply->data_map_ind=1)) OR (((version_fail=1) OR ((((
 reply->alpha_rule_ind=1)) OR ((((reply->ref_rule_ind=1)) OR ((reply->cve_ind=1))) )) )) )) )) )) ))
 )) )) )
  SET reply->status_data.targetobjectname = "DCP_DTAWIZARD"
  SET reply->status_data.operationname = "CHG"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echo(build("failure:",reply->status_data.targetobjectvalue))
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE RECORD version_request
 FREE RECORD version_reply
 SET script_version = "017 08/09/14"
 IF (debug_ind=1)
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echo(build("Script Version: ",script_version))
 ENDIF
 SET modify = nopredeclare
END GO
