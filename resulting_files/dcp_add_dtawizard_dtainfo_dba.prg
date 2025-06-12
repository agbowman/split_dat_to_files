CREATE PROGRAM dcp_add_dtawizard_dtainfo:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dup_ind = i2
    1 codeset_ind = i2
    1 table_ind = i2
    1 ref_range_ind = i2
    1 rule_ind = i2
    1 alpha_rule_ind = i2
    1 alpha_ind = i2
    1 data_map_ind = i2
    1 task_assay_cd = f8
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
 ENDIF
 DECLARE task_assay_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dup_ind = i2 WITH protect, noconstant(0)
 DECLARE codeset_ind = i2 WITH protect, noconstant(0)
 DECLARE alpha_ind = i2 WITH protect, noconstant(0)
 DECLARE data_map_ind = i2 WITH protect, noconstant(0)
 DECLARE alpha_cnt = i4 WITH protect, noconstant(0)
 DECLARE ref_range_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_task_description = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE temp_event_cd = f8 WITH protect, noconstant(0.0)
 DECLARE zero_row = i2 WITH protect, noconstant(0)
 DECLARE human_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",226,"HUMAN"))
 DECLARE numeric_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE calculation_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"8"))
 DECLARE count_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"13"))
 DECLARE alpha_response_rule_id = f8 WITH protect, noconstant(0.0)
 DECLARE new_offset_min_id = f8 WITH protect, noconstant(0.0), protect
 DECLARE cnt_offset_min = i4 WITH protect, noconstant(0), protect
 DECLARE script_version = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind)=1)
  IF ((request->debug_ind=1))
   SET debug_ind = 1
   CALL echo("*DEBUG MODE - ON - DCP_ADD_DTAWIZARD_DTAINFO*")
  ENDIF
 ENDIF
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
 SELECT INTO "nl:"
  d.mnemonic
  FROM discrete_task_assay d
  WHERE (d.mnemonic=request->mnemonic)
   AND (d.activity_type_cd=request->activity_type_cd)
  DETAIL
   dup_ind += 1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->dup_ind = 1
  SET reply->status_data.targetobjectvalue = "Duplicate DTA mnemonic found."
  GO TO add_failed
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)"################################;rp0"
  FROM dual
  DETAIL
   task_assay_cd = cnvtreal(nextseqnum)
  WITH nocounter
 ;end select
 IF (task_assay_cd=0)
  SET zero_row = 1
  SET reply->status_data.targetobjectvalue = "Task assay code generated was zero."
  GO TO add_failed
 ENDIF
 IF ((request->build_event_cd_ind=1))
  SET temp_task_description = substring(1,40,request->mnemonic)
  SET temp_event_cd = 0
  SET modify = nopredeclare
  EXECUTE tsk_post_event_code
  SET modify = predeclare
  SET request->event_cd = temp_event_cd
  SET reply->event_cd = temp_event_cd
 ENDIF
 SET modify = nopredeclare
 EXECUTE gm_code_value0619_def "I"
 SUBROUTINE (gm_i_code_value0619_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_type_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].active_type_cd = ival
     SET gm_i_code_value0619_req->active_type_cdi = 1
    OF "data_status_cd":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].data_status_cd = ival
     SET gm_i_code_value0619_req->data_status_cdi = 1
    OF "data_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].data_status_prsnl_id = ival
     SET gm_i_code_value0619_req->data_status_prsnl_idi = 1
    OF "active_status_prsnl_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].active_status_prsnl_id = ival
     SET gm_i_code_value0619_req->active_status_prsnl_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_i2(icol_name=vc,ival=i2,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_ind":
     SET gm_i_code_value0619_req->qual[iqual].active_ind = ival
     SET gm_i_code_value0619_req->active_indi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_i4(icol_name=vc,ival=i4,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
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
     SET gm_i_code_value0619_req->qual[iqual].code_set = ival
     SET gm_i_code_value0619_req->code_seti = 1
    OF "collation_seq":
     SET gm_i_code_value0619_req->qual[iqual].collation_seq = ival
     SET gm_i_code_value0619_req->collation_seqi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_dq8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "active_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].active_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->active_dt_tmi = 1
    OF "inactive_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].inactive_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->inactive_dt_tmi = 1
    OF "updt_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].updt_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->updt_dt_tmi = 1
    OF "begin_effective_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].begin_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
    OF "end_effective_dt_tm":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].end_effective_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
    OF "data_status_dt_tm":
     SET gm_i_code_value0619_req->qual[iqual].data_status_dt_tm = cnvtdatetime(ival)
     SET gm_i_code_value0619_req->data_status_dt_tmi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (gm_i_code_value0619_vc(icol_name=vc,ival=vc,iqual=i4,null_ind=i2) =i2)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_code_value0619_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_code_value0619_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "cdf_meaning":
     SET gm_i_code_value0619_req->qual[iqual].cdf_meaning = ival
     SET gm_i_code_value0619_req->cdf_meaningi = 1
    OF "display":
     SET gm_i_code_value0619_req->qual[iqual].display = ival
     SET gm_i_code_value0619_req->displayi = 1
    OF "description":
     SET gm_i_code_value0619_req->qual[iqual].description = ival
     SET gm_i_code_value0619_req->descriptioni = 1
    OF "definition":
     SET gm_i_code_value0619_req->qual[iqual].definition = ival
     SET gm_i_code_value0619_req->definitioni = 1
    OF "cki":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_code_value0619_req->qual[iqual].cki = ival
     SET gm_i_code_value0619_req->ckii = 1
    OF "concept_cki":
     SET gm_i_code_value0619_req->qual[iqual].concept_cki = ival
     SET gm_i_code_value0619_req->concept_ckii = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SET modify = predeclare
 SET gm_i_code_value0619_req->code_seti = 1
 SET gm_i_code_value0619_req->displayi = 1
 SET gm_i_code_value0619_req->descriptioni = 1
 SET gm_i_code_value0619_req->definitioni = 1
 SET gm_i_code_value0619_req->active_indi = 1
 SET gm_i_code_value0619_req->active_type_cdi = 1
 SET gm_i_code_value0619_req->active_dt_tmi = 1
 SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
 SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
 SET gm_i_code_value0619_req->active_status_prsnl_idi = 1
 SET gm_i_code_value0619_req->data_status_cdi = 1
 SET stat = alterlist(gm_i_code_value0619_req->qual,1)
 SET gm_i_code_value0619_req->qual[1].code_set = 14003
 SET gm_i_code_value0619_req->qual[1].display = request->mnemonic
 SET gm_i_code_value0619_req->qual[1].description = request->description
 SET gm_i_code_value0619_req->qual[1].definition = request->description
 SET gm_i_code_value0619_req->qual[1].active_ind = 1
 SET gm_i_code_value0619_req->qual[1].active_type_cd = reqdata->active_status_cd
 SET gm_i_code_value0619_req->qual[1].active_dt_tm = cnvtdatetime(sysdate)
 SET gm_i_code_value0619_req->qual[1].begin_effective_dt_tm = cnvtdatetime(sysdate)
 SET gm_i_code_value0619_req->qual[1].end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
 SET gm_i_code_value0619_req->qual[1].active_status_prsnl_id = reqinfo->updt_id
 SET gm_i_code_value0619_req->qual[1].data_status_cd = reqdata->data_status_cd
 SET modify = nopredeclare
 EXECUTE gm_i_code_value0619  WITH replace("REQUEST",gm_i_code_value0619_req), replace("REPLY",
  gm_i_code_value0619_rep)
 SET modify = predeclare
 IF ((gm_i_code_value0619_rep->curqual=0)
  AND (gm_i_code_value0619_rep->status_data.status="F"))
  SET reply->codeset_ind = 1
  SET reply->status_data.targetobjectvalue = "insert failed on code_value table."
  GO TO add_failed
 ENDIF
 SET task_assay_cd = gm_i_code_value0619_rep->qual[1].code_value
 FREE RECORD gm_i_code_value0619_req
 FREE RECORD gm_i_code_value0619_rep
 INSERT  FROM discrete_task_assay d
  SET d.task_assay_cd = task_assay_cd, d.mnemonic = request->mnemonic, d.mnemonic_key_cap = trim(
    cnvtupper(request->mnemonic)),
   d.activity_type_cd = request->activity_type_cd, d.default_result_type_cd = request->
   default_result_type_cd, d.bb_result_processing_cd = 0,
   d.rad_section_type_cd = 0, d.event_cd = request->event_cd, d.description = request->description,
   d.code_set = request->code_set, d.strt_assay_id = 0, d.history_activity_type_cd = 0,
   d.hla_loci_cd = 0, d.active_ind = 1, d.active_status_dt_tm = cnvtdatetime(sysdate),
   d.active_status_prsnl_id = reqinfo->updt_id, d.active_status_cd = reqdata->active_status_cd, d
   .beg_effective_dt_tm = cnvtdatetime(sysdate),
   d.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), d.updt_dt_tm = cnvtdatetime(
    sysdate), d.updt_id = reqinfo->updt_id,
   d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0,
   d.modifier_ind = request->modifier_ind, d.single_select_ind = request->single_select_ind, d
   .default_type_flag = request->default_type_flag,
   d.concept_cki = request->concept_cki, d.io_flag = request->io_flag, d.template_script_cd =
   validate(request->template_script_cd,0.0)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->table_ind = 1
  SET reply->status_data.targetobjectvalue = "Failed on insert to discrete_task_assay table."
  CALL echo(build("Failed-table_ind: ",reply_table_ind))
  GO TO add_failed
 ENDIF
 CALL echo(build("curqual: ",curqual))
 FOR (cnt_offset_min = 1 TO request->offset_min_cnt)
   SELECT INTO "nl:"
    nextseqnum = seq(reference_seq,nextval)"################################;rp0"
    FROM dual
    DETAIL
     new_offset_min_id = cnvtreal(nextseqnum)
    WITH nocounter
   ;end select
   INSERT  FROM dta_offset_min dom
    SET dom.dta_offset_min_id = new_offset_min_id, dom.task_assay_cd = task_assay_cd, dom
     .offset_min_type_cd = request->offset_mins[cnt_offset_min].offset_min_type_cd,
     dom.offset_min_nbr = request->offset_mins[cnt_offset_min].offset_min_nbr, dom
     .beg_effective_dt_tm = cnvtdatetime(sysdate), dom.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"),
     dom.active_ind = 1, dom.updt_cnt = 0, dom.updt_dt_tm = cnvtdatetime(sysdate),
     dom.updt_id = reqinfo->updt_id, dom.updt_task = reqinfo->updt_task, dom.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->offset_min_ind = 1
    SET reply->status_data.targetobjectvalue = "Failed on insert to dta_offset_min table."
    GO TO add_failed
   ENDIF
   CALL echo(build("curqual: ",curqual))
 ENDFOR
 SET ref_range_cnt = request->ref_range_cnt
 IF (ref_range_cnt=0)
  GO TO continue
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
    SET reply->status_data.targetobjectvalue = "Tried to set ref range id to zero."
    GO TO add_failed
   ENDIF
   INSERT  FROM reference_range_factor r
    SET r.reference_range_factor_id = request->ref_range[x].ref_id, r.service_resource_cd = 0, r
     .task_assay_cd = task_assay_cd,
     r.species_cd = human_cd, r.organism_cd = 0, r.unknown_age_ind = 0,
     r.sex_cd = request->ref_range[x].sex_cd, r.age_from_units_cd = request->ref_range[x].
     age_from_units_cd, r.age_from_minutes = request->ref_range[x].age_from_minutes,
     r.age_to_units_cd = request->ref_range[x].age_to_units_cd, r.age_to_minutes = request->
     ref_range[x].age_to_minutes, r.specimen_type_cd = 0,
     r.patient_condition_cd = 0, r.def_result_ind = request->ref_range[x].def_result_ind, r
     .default_result = request->ref_range[x].default_result,
     r.units_cd = request->ref_range[x].units_cd, r.review_ind = request->ref_range[x].review_ind, r
     .review_low = request->ref_range[x].review_low,
     r.review_high = request->ref_range[x].review_high, r.feasible_ind = request->ref_range[x].
     feasible_ind, r.feasible_low = request->ref_range[x].feasible_low,
     r.feasible_high = request->ref_range[x].feasible_high, r.linear_ind = request->ref_range[x].
     linear_ind, r.linear_low = request->ref_range[x].linear_low,
     r.linear_high = request->ref_range[x].linear_high, r.normal_ind = request->ref_range[x].
     normal_ind, r.normal_low = request->ref_range[x].normal_low,
     r.normal_high = request->ref_range[x].normal_high, r.critical_ind = request->ref_range[x].
     critical_ind, r.critical_low = request->ref_range[x].critical_low,
     r.critical_high = request->ref_range[x].critical_high, r.ref_range_rule_ind = request->
     ref_range[x].rule_ind, r.dilute_ind = 0,
     r.delta_check_type_cd = 0, r.delta_minutes = 0, r.delta_value = 0,
     r.delta_chk_flag = 0, r.gestational_ind = request->ref_range[x].gestational_ind, r
     .precedence_sequence = 0,
     r.mins_back = request->ref_range[x].mins_back, r.active_ind = 1, r.active_status_cd = reqdata->
     active_status_cd,
     r.active_status_prsnl_id = reqinfo->updt_id, r.active_status_dt_tm = cnvtdatetime(sysdate), r
     .beg_effective_dt_tm = cnvtdatetime(sysdate),
     r.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), r.updt_dt_tm = cnvtdatetime(
      sysdate), r.updt_id = reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_cnt = 0, r.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->ref_range_ind = 1
    SET reply->status_data.targetobjectvalue = "Failed on insert to reference_range_factor table."
    GO TO add_failed
   ENDIF
   CALL update_category(x)
   IF ((reply->status_data.status="F"))
    SET reply->alpha_ind = 1
    SET reply->status_data.targetobjectvalue = "Error in category transaction"
    GO TO add_failed
   ENDIF
   IF ((request->ref_range[x].alpha_cnt > 0))
    INSERT  FROM alpha_responses a,
      (dummyt d  WITH seq = value(request->ref_range[x].alpha_cnt))
     SET a.reference_range_factor_id = request->ref_range[x].ref_id, a.sequence = request->ref_range[
      x].alpha[d.seq].sequence, a.nomenclature_id = request->ref_range[x].alpha[d.seq].
      nomenclature_id,
      a.use_units_ind = 0, a.result_process_cd = 0, a.default_ind = request->ref_range[x].alpha[d.seq
      ].default_ind,
      a.reference_ind = 0, a.active_ind = 1, a.result_value = request->ref_range[x].alpha[d.seq].
      result_value,
      a.multi_alpha_sort_order = request->ref_range[x].alpha[d.seq].multi_alpha_sort_order, a
      .active_status_cd = reqdata->active_status_cd, a.active_status_prsnl_id = reqinfo->updt_id,
      a.active_status_dt_tm = cnvtdatetime(sysdate), a.beg_effective_dt_tm = cnvtdatetime(sysdate), a
      .end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"),
      a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->
      updt_task,
      a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx, a.alpha_responses_category_id = request
      ->ref_range[x].alpha[d.seq].category_id,
      a.concept_cki = request->ref_range[x].alpha[d.seq].concept_cki, a.truth_state_cd = request->
      ref_range[x].alpha[d.seq].truth_state_cd
     PLAN (d)
      JOIN (a)
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=0)
    SET reply->alpha_ind = 1
    SET reply->status_data.targetobjectvalue = "Failed on insert to alpha_details table."
    GO TO add_failed
   ENDIF
   IF ((request->ref_range[x].rule_cnt > 0))
    FOR (y = 1 TO request->ref_range[x].rule_cnt)
      SELECT INTO "nl:"
       nextseqnum = seq(reference_seq,nextval)"####################################;rp0"
       FROM dual
       DETAIL
        request->ref_range[x].rule[y].rule_id = cnvtreal(nextseqnum)
       WITH nocounter
      ;end select
      INSERT  FROM ref_range_factor_rule rr
       SET rr.reference_range_factor_id = request->ref_range[x].ref_id, rr.ref_range_factor_rule_id
         = request->ref_range[x].rule[y].rule_id, rr.active_ind = 1,
        rr.feasible_limit_ind = request->ref_range[x].rule[y].feasible_ind, rr.feasible_low = request
        ->ref_range[x].rule[y].feasible_low, rr.feasible_high = request->ref_range[x].rule[y].
        feasible_high,
        rr.normal_limit_ind = request->ref_range[x].rule[y].normal_ind, rr.normal_low = request->
        ref_range[x].rule[y].normal_low, rr.normal_high = request->ref_range[x].rule[y].normal_high,
        rr.critical_limit_ind = request->ref_range[x].rule[y].critical_ind, rr.critical_low = request
        ->ref_range[x].rule[y].critical_low, rr.critical_high = request->ref_range[x].rule[y].
        critical_high,
        rr.from_gestation_days = request->ref_range[x].rule[y].gestation_from_age_in_days, rr
        .to_gestation_days = request->ref_range[x].rule[y].gestation_to_age_in_days, rr.from_weight
         = request->ref_range[x].rule[y].from_weight,
        rr.to_weight = request->ref_range[x].rule[y].to_weight, rr.from_weight_unit_cd = request->
        ref_range[x].rule[y].from_weight_unit_cd, rr.to_weight_unit_cd = request->ref_range[x].rule[y
        ].to_weight_unit_cd,
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
       SET reply->rule_ind = 1
       SET reply->status_data.targetobjectvalue = "Failed on insert to ref_range_factor_rule table."
       GO TO add_failed
      ENDIF
      IF ((request->ref_range[x].rule[y].alpha_rule_cnt > 0))
       FOR (i = 1 TO request->ref_range[x].rule[y].alpha_rule_cnt)
         SET alpha_response_rule_id = 0.0
         SELECT INTO "nl:"
          nextseqnum = seq(reference_seq,nextval)"####################################;rp0"
          FROM dual
          DETAIL
           alpha_response_rule_id = cnvtreal(nextseqnum)
          WITH nocounter
         ;end select
         IF (alpha_response_rule_id=0)
          SET reply->alpha_rule_ind = 1
          SET reply->status_data.targetobjectvalue =
          "Failed on insert to alpha_responses_rule table."
          GO TO add_failed
         ENDIF
         INSERT  FROM alpha_response_rule ar
          SET ar.nomenclature_id = request->ref_range[x].rule[y].alpha_rule[i].nomenclature_id, ar
           .reference_range_factor_id = request->ref_range[x].ref_id, ar.ref_range_factor_rule_id =
           request->ref_range[x].rule[y].rule_id,
           ar.alpha_response_rule_id = alpha_response_rule_id, ar.active_ind = 1
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET reply->alpha_rule_ind = 1
          SET reply->status_data.targetobjectvalue =
          "Failed on insert to alpha_responses_rule table."
          GO TO add_failed
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF ((request->witness_required_ind=1))
  INSERT  FROM code_value_extension cve
   SET cve.code_value = task_assay_cd, cve.field_name = "dta_witness_required_ind", cve.code_set =
    14003,
    cve.updt_applctx = reqinfo->updt_applctx, cve.updt_dt_tm = cnvtdatetime(sysdate), cve.field_type
     = 0,
    cve.field_value = "1", cve.updt_cnt = 0, cve.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->cve_ind = 1
   SET reply->status_data.targetobjectvalue = "Failed on insert to code_value_extension table."
   GO TO add_failed
  ENDIF
 ENDIF
#continue
 IF ((((request->default_result_type_cd=numeric_cd)) OR ((((request->default_result_type_cd=
 calculation_cd)) OR ((request->default_result_type_cd=count_cd))) )) )
  INSERT  FROM data_map n
   SET n.seq = 1, n.task_assay_cd = task_assay_cd, n.service_resource_cd = 0,
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
   SET reply->data_map_ind = 1
   SET reply->status_data.targetobjectvalue = "Failed on insert to data_map table."
   GO TO add_failed
  ENDIF
 ENDIF
#add_failed
 SET error_code = error(error_msg,1)
 IF (error_code != 0)
  CALL echo(build("ERROR: ",error_msg))
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus("ERROR","F","dcp_add_dtawizard_dtainfo",error_msg)
  SET reqinfo->commit_ind = 0
 ELSEIF ((((reply->dup_ind=1)) OR ((((reply->codeset_ind=1)) OR ((((reply->table_ind=1)) OR ((((reply
 ->ref_range_ind=1)) OR ((((reply->alpha_ind=1)) OR (((zero_row=1) OR ((((reply->data_map_ind=1)) OR
 ((((reply->alpha_rule_ind=1)) OR ((((reply->rule_ind=1)) OR ((((reply->offset_min_ind=1)) OR ((reply
 ->cve_ind=1))) )) )) )) )) )) )) )) )) )) )
  SET reply->status_data.targetobjectname = "DCP_DTAWIZARD"
  SET reply->status_data.operationname = "ADD"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->task_assay_cd = task_assay_cd
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "009 06/21/11"
 IF (debug_ind=1)
  CALL echorecord(request)
  CALL echorecord(reply)
  CALL echo(build("Script Version: ",script_version))
 ENDIF
 SET modify = nopredeclare
END GO
