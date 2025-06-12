CREATE PROGRAM cv_imp_step_ref:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 FREE RECORD refs
 RECORD refs(
   1 ref[*]
     2 task_assay_cd = f8
     2 step_level_flag = i2
     2 doc_type_cd = f8
     2 doc_id_str = vc
     2 activity_subtype_cd = f8
     2 proc_status_cd = f8
     2 schedule_ind = i2
     2 step_type_cd = f8
     2 study_reltn_flag = i2
     2 ins_upd_flag = i2
     2 ins_upd_status = i2
     2 ins_upd_errnum = i4
     2 ins_upd_errmsg = vc
 )
 FREE SET xref
 RECORD xref(
   1 list[*]
     2 ref_idx = i4
   1 form[*]
     2 description = vc
     2 ref_cnt = i4
     2 ref[*]
       3 ref_idx = i4
     2 found_ind = i2
   1 clin[*]
     2 description = vc
     2 ref_cnt = i4
     2 ref[*]
       3 ref_idx = i4
     2 found_ind = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE list_cnt = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE list_idx = i4 WITH protect
 DECLARE list_pad = i4 WITH protect
 DECLARE ref_cnt = i4 WITH protect
 DECLARE ref_pad = i4 WITH protect
 DECLARE ref_idx = i4 WITH protect
 DECLARE form_cnt = i4 WITH protect
 DECLARE form_idx = i4 WITH protect
 DECLARE form_pad = i4 WITH protect
 DECLARE clin_cnt = i4 WITH protect
 DECLARE clin_idx = i4 WITH protect
 DECLARE clin_pad = i4 WITH protect
 DECLARE bad_cnt = i4 WITH protect
 DECLARE ins_cnt = i4 WITH protect
 DECLARE upd_cnt = i4 WITH protect
 DECLARE unch_cnt = i4 WITH protect
 DECLARE err_cnt = i4 WITH protect
 DECLARE doc_id = f8 WITH protect
 DECLARE failure = c1 WITH public, noconstant("T")
 DECLARE block_sz = i4 WITH protect, noconstant(20)
 DECLARE block_start = i4 WITH protect, noconstant(1)
 DECLARE c_doc_type_powerform = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "POWERFORM"))
 DECLARE c_doc_type_powernote = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "POWERNOTE"))
 DECLARE c_doc_type_clinicalnote = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,
   "CLINICALNOTE"))
 DECLARE c_doc_type_dicompdf = f8 WITH protect, constant(uar_get_code_by("MEANING",4000360,"DICOMPDF"
   ))
 DECLARE c_activity_type_cardiovascul = f8 WITH protect, constant(uar_get_code_by("MEANING",106,
   "CARDIOVASCUL"))
 DECLARE c_step_type_default = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,"DEFAULT")
  )
 DECLARE c_default_result_type_11 = f8 WITH protect, constant(uar_get_code_by("MEANING",289,"11"))
 IF (list_cnt=0)
  CALL cv_log_msg(cv_info,"Import is empty. Aborting import.")
  GO TO exit_script
 ENDIF
 SET list_pad = (list_cnt+ ((block_sz - 1) - mod((list_cnt - 1),block_sz)))
 SET stat = alterlist(requestin->list_0,list_pad)
 FOR (list_idx = (list_cnt+ 1) TO list_pad)
   SET requestin->list_0[list_idx].dta_mnemonic = requestin->list_0[list_cnt].dta_mnemonic
 ENDFOR
 SET stat = alterlist(xref->list,list_cnt)
 SELECT DISTINCT INTO "nl:"
  dta.task_assay_cd
  FROM discrete_task_assay dta,
   (dummyt d  WITH seq = value((list_pad/ block_sz)))
  PLAN (d
   WHERE assign(block_start,evaluate(d.seq,1,1,(block_start+ block_sz))))
   JOIN (dta
   WHERE expand(list_idx,block_start,((block_start+ block_sz) - 1),trim(dta.mnemonic),requestin->
    list_0[list_idx].dta_mnemonic)
    AND dta.activity_type_cd=c_activity_type_cardiovascul
    AND dta.default_result_type_cd=c_default_result_type_11)
  HEAD REPORT
   l_event_cd = 0.0, l_event_display_key = fillstring(40," ")
  DETAIL
   list_idx = locateval(list_idx,(1+ (block_sz * (d.seq - 1))),list_cnt,dta.mnemonic,requestin->
    list_0[list_idx].dta_mnemonic), ref_idx += 1, xref->list[list_idx].ref_idx = ref_idx
   IF (ref_idx > ref_pad)
    ref_pad += block_sz, stat = alterlist(refs->ref,ref_pad)
   ENDIF
   refs->ref[ref_idx].ins_upd_flag = 1, refs->ref[ref_idx].task_assay_cd = dta.task_assay_cd, refs->
   ref[ref_idx].step_level_flag = cnvtint(requestin->list_0[list_idx].step_level_flag),
   refs->ref[ref_idx].schedule_ind = cnvtint(requestin->list_0[list_idx].schedule_ind), refs->ref[
   ref_idx].study_reltn_flag = cnvtint(requestin->list_0[list_idx].study_reltn_flag), refs->ref[
   ref_idx].task_assay_cd = dta.task_assay_cd
   IF (textlen(trim(requestin->list_0[list_idx].doc_type_mean)) > 0)
    refs->ref[ref_idx].doc_type_cd = uar_get_code_by("MEANING",4000360,nullterm(trim(requestin->
       list_0[list_idx].doc_type_mean)))
    IF ((refs->ref[ref_idx].doc_type_cd <= 0.0))
     refs->ref[ref_idx].ins_upd_flag = 3,
     CALL cv_log_stat(cv_warning,"UAR","F",build("DOC_TYPE=",requestin->list_0[list_idx].
      doc_type_mean),build("DTA_MNEMONIC=",requestin->list_0[list_idx].dta_mnemonic))
    ENDIF
   ELSE
    refs->ref[ref_idx].ins_upd_flag = 3,
    CALL cv_log_stat(cv_warning,"CHECK","F","DOC_TYPE=",build("DTA_MNEMONIC=",requestin->list_0[
     list_idx].dta_mnemonic))
   ENDIF
   IF (textlen(trim(requestin->list_0[list_idx].step_type_mean)) > 0)
    refs->ref[ref_idx].step_type_cd = uar_get_code_by("MEANING",4001923,nullterm(trim(requestin->
       list_0[list_idx].step_type_mean)))
    IF ((refs->ref[ref_idx].step_type_cd <= 0.0))
     refs->ref[ref_idx].ins_upd_flag = 3,
     CALL cv_log_stat(cv_warning,"UAR","F",build("STEP_TYPE=",requestin->list_0[list_idx].
      step_type_mean),build("DTA_MNEMONIC=",requestin->list_0[list_idx].dta_mnemonic))
    ENDIF
   ELSE
    CALL cv_log_msg(cv_info,build("Setting step_type=DEFAULT for dta_mnemonic=",requestin->list_0[
     list_idx].dta_mnemonic)), refs->ref[ref_idx].step_type_cd = c_step_type_default
   ENDIF
   IF (textlen(trim(requestin->list_0[list_idx].proc_status_mean)) > 0)
    refs->ref[ref_idx].proc_status_cd = uar_get_code_by("MEANING",4000341,nullterm(trim(requestin->
       list_0[list_idx].proc_status_mean)))
    IF ((refs->ref[ref_idx].proc_status_cd <= 0.0))
     refs->ref[ref_idx].ins_upd_flag = 3,
     CALL cv_log_stat(cv_warning,"UAR","F",build("PROC_STATUS=",requestin->list_0[list_idx].
      proc_status_mean),build("DTA_MNEMONIC=",requestin->list_0[list_idx].dta_mnemonic))
    ENDIF
   ENDIF
   IF (textlen(trim(requestin->list_0[list_idx].activity_subtype_mean)) > 0)
    refs->ref[ref_idx].activity_subtype_cd = uar_get_code_by("MEANING",5801,nullterm(trim(requestin->
       list_0[list_idx].activity_subtype_mean)))
    IF ((refs->ref[ref_idx].activity_subtype_cd <= 0.0))
     refs->ref[ref_idx].ins_upd_flag = 3,
     CALL cv_log_stat(cv_warning,"UAR","F",build("ACT_SUBTYPE=",requestin->list_0[list_idx].
      activity_subtype_mean),build("DTA_MNEMONIC=",requestin->list_0[list_idx].dta_mnemonic))
    ENDIF
   ENDIF
   IF (textlen(trim(requestin->list_0[list_idx].doc_id_str)) > 0)
    CASE (refs->ref[ref_idx].doc_type_cd)
     OF c_doc_type_powerform:
      IF (cnvtreal(requestin->list_0[list_idx].doc_id_str) > 0.0)
       refs->ref[ref_idx].doc_id_str = requestin->list_0[list_idx].doc_id_str,
       CALL cv_log_msg(cv_info,build("Numeric import of dcp_forms_ref_id=",refs->ref[ref_idx].
        doc_id_str))
      ELSE
       refs->ref[ref_idx].ins_upd_flag = 0, form_idx = locateval(form_idx,1,form_cnt,requestin->
        list_0[list_idx].doc_id_str,xref->form[form_idx].description)
       IF (form_idx=0)
        form_cnt += 1
        IF (form_cnt > form_pad)
         form_pad += block_sz, stat = alterlist(xref->form,form_pad)
        ENDIF
        form_idx = form_cnt, xref->form[form_idx].description = trim(requestin->list_0[list_idx].
         doc_id_str)
       ENDIF
       xref->form[form_idx].ref_cnt += 1, stat = alterlist(xref->form[form_idx].ref,xref->form[
        form_idx].ref_cnt), xref->form[form_idx].ref[xref->form[form_idx].ref_cnt].ref_idx = ref_idx
      ENDIF
     OF c_doc_type_clinicalnote:
      IF (cnvtreal(requestin->list_0[list_idx].doc_id_str) > 0.0)
       refs->ref[ref_idx].doc_id_str = requestin->list_0[list_idx].doc_id_str,
       CALL cv_log_msg(cv_info,build("Numeric import of note_type_id=",refs->ref[ref_idx].doc_id_str)
       )
      ELSE
       refs->ref[ref_idx].ins_upd_flag = 0, clin_idx = locateval(clin_idx,1,clin_cnt,requestin->
        list_0[list_idx].doc_id_str,xref->clin[clin_idx].description)
       IF (clin_idx=0)
        clin_cnt += 1
        IF (clin_cnt > clin_pad)
         clin_pad += block_sz, stat = alterlist(xref->clin,clin_pad)
        ENDIF
        clin_idx = clin_cnt, xref->clin[clin_idx].description = requestin->list_0[list_idx].
        doc_id_str
       ENDIF
       xref->clin[clin_idx].ref_cnt += 1, stat = alterlist(xref->clin[clin_idx].ref,xref->clin[
        clin_idx].ref_cnt), xref->clin[clin_idx].ref[xref->clin[clin_idx].ref_cnt].ref_idx = ref_idx
      ENDIF
     OF c_doc_type_powernote:
      refs->ref[ref_idx].doc_id_str = requestin->list_0[list_idx].doc_id_str
     OF c_doc_type_dicompdf:
      refs->ref[ref_idx].doc_id_str = requestin->list_0[list_idx].doc_id_str
     ELSE
      CALL cv_log_msg(cv_audit,build2(requestin->list_0[list_idx].dta_mnemonic," has doc_id_str=",
       requestin->list_0[list_idx].doc_id_str," ignored for doc_type=",requestin->list_0[list_idx].
       doc_type_mean))
    ENDCASE
   ELSE
    IF ((refs->ref[ref_idx].doc_type_cd IN (c_doc_type_powerform, c_doc_type_powernote,
    c_doc_type_clinicalnote)))
     refs->ref[ref_idx].ins_upd_flag = 0,
     CALL cv_log_stat(cv_warning,"CHECK","F","DOC_ID_STR Empty",build("DTA_MNEMONIC=",requestin->
      list_0[list_idx].dta_mnemonic)),
     CALL cv_log_msg(cv_info,build("Missing doc_id_str for:",requestin->list_0[list_idx].dta_mnemonic
      ))
    ENDIF
   ENDIF
  FOOT REPORT
   ref_cnt = ref_idx
   FOR (ref_idx = (ref_cnt+ 1) TO ref_pad)
     refs->ref[ref_idx].task_assay_cd = refs->ref[ref_cnt].task_assay_cd
   ENDFOR
  WITH nocounter
 ;end select
 FOR (list_idx = 1 TO list_cnt)
   IF ((xref->list[list_idx].ref_idx=0))
    CALL cv_log_stat(cv_warning,"SELECT","F","DISCRETE_TASK_ASSAY",build("MNEMONIC=",requestin->
      list_0[list_idx].dta_mnemonic))
   ENDIF
 ENDFOR
 SET stat = alterlist(requestin->list_0,list_cnt)
 IF (ref_cnt=0)
  CALL cv_log_msg(cv_info,"Couldn't find DTA for any item. Aborting import.")
  GO TO exit_script
 ENDIF
 CALL cv_log_msg(cv_info,build("ref_cnt=",ref_cnt))
 CALL cv_log_msg(cv_info,build("form_cnt=",form_cnt))
 CALL cv_log_msg(cv_info,build("clin_cnt=",clin_cnt))
 IF (form_cnt > 0)
  FOR (form_idx = (form_cnt+ 1) TO form_pad)
    SET xref->form[form_idx].description = xref->form[form_cnt].description
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((form_pad/ block_sz))),
    dcp_forms_ref dfr
   PLAN (d
    WHERE assign(block_start,evaluate(d.seq,1,1,(block_start+ block_sz))))
    JOIN (dfr
    WHERE expand(form_idx,block_start,((block_start+ block_sz) - 1),dfr.description,xref->form[
     form_idx].description)
     AND dfr.active_ind=1)
   HEAD REPORT
    l_idx = 0
   DETAIL
    form_idx = locateval(form_idx,(1+ (block_sz * (d.seq - 1))),form_cnt,dfr.description,xref->form[
     form_idx].description), xref->form[form_idx].found_ind = 1
    FOR (l_idx = 1 TO xref->form[form_idx].ref_cnt)
      ref_idx = xref->form[form_idx].ref[l_idx].ref_idx
      IF ((refs->ref[ref_idx].ins_upd_flag=0))
       refs->ref[ref_idx].ins_upd_flag = 1
      ENDIF
      refs->ref[ref_idx].doc_id_str = cnvtstring(dfr.dcp_forms_ref_id)
    ENDFOR
   WITH nocounter
  ;end select
  SET stat = alterlist(xref->form,form_cnt)
 ENDIF
 SET form_idx = locateval(form_idx,1,form_cnt,0,xref->form[form_idx].found_ind)
 WHILE (form_idx > 0)
  CALL cv_log_stat(cv_warning,"SELECT","F","DCP_FORMS_REF",build("DESCRIPTION=",xref->form[form_idx].
    description))
  SET form_idx = locateval(form_idx,(form_idx+ 1),form_cnt,0,xref->form[form_idx].found_ind)
 ENDWHILE
 IF (clin_cnt > 0)
  FOR (clin_idx = (clin_cnt+ 1) TO clin_pad)
    SET xref->clin[clin_idx].description = xref->clin[clin_cnt].description
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((clin_pad/ block_sz))),
    note_type nt
   PLAN (d
    WHERE assign(block_start,evaluate(d.seq,1,1,(block_start+ block_sz))))
    JOIN (nt
    WHERE expand(clin_idx,block_start,((block_start+ block_sz) - 1),nt.note_type_description,xref->
     clin[clin_idx].description))
   HEAD REPORT
    l_idx = 0
   DETAIL
    clin_idx = locateval(clin_idx,(1+ (block_sz * (d.seq - 1))),clin_cnt,nt.note_type_description,
     xref->clin[clin_idx].description), xref->clin[clin_idx].found_ind = 1
    FOR (l_idx = 1 TO xref->clin[clin_idx].ref_cnt)
      ref_idx = xref->clin[clin_idx].ref[l_idx].ref_idx
      IF ((refs->ref[ref_idx].ins_upd_flag=0))
       refs->ref[ref_idx].ins_upd_flag = 1
      ENDIF
      refs->ref[ref_idx].doc_id_str = cnvtstring(nt.note_type_id)
    ENDFOR
   WITH nocounter
  ;end select
  SET stat = alterlist(xref->clin,clin_cnt)
 ENDIF
 SET clin_idx = locateval(clin_idx,1,clin_cnt,0,xref->clin[clin_idx].found_ind)
 WHILE (clin_idx > 0)
  CALL cv_log_stat(cv_warning,"SELECT","F","NOTE_TYPE",build("NOTE_TYPE_DESCRIPTION=",xref->clin[
    clin_idx].description))
  SET clin_idx = locateval(clin_idx,(clin_idx+ 1),clin_cnt,0,xref->clin[clin_idx].found_ind)
 ENDWHILE
 FOR (ref_idx = 1 TO ref_cnt)
   IF ((refs->ref[ref_idx].ins_upd_flag != 1))
    SET bad_cnt += 1
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((ref_pad/ block_sz))),
   cv_step_ref csr
  PLAN (d
   WHERE assign(block_start,evaluate(d.seq,1,1,(block_start+ block_sz))))
   JOIN (csr
   WHERE expand(ref_idx,block_start,((block_start+ block_sz) - 1),csr.task_assay_cd,refs->ref[ref_idx
    ].task_assay_cd))
  DETAIL
   ref_idx = locateval(ref_idx,(1+ (block_sz * (d.seq - 1))),ref_cnt,csr.task_assay_cd,refs->ref[
    ref_idx].task_assay_cd)
   IF ((refs->ref[ref_idx].ins_upd_flag=1))
    IF ((csr.step_level_flag=refs->ref[ref_idx].step_level_flag)
     AND (csr.doc_type_cd=refs->ref[ref_idx].doc_type_cd)
     AND (csr.doc_id_str=refs->ref[ref_idx].doc_id_str)
     AND (csr.activity_subtype_cd=refs->ref[ref_idx].activity_subtype_cd)
     AND (csr.proc_status_cd=refs->ref[ref_idx].proc_status_cd)
     AND (csr.schedule_ind=refs->ref[ref_idx].schedule_ind)
     AND (csr.step_type_cd=refs->ref[ref_idx].step_type_cd)
     AND (csr.study_reltn_flag=refs->ref[ref_idx].study_reltn_flag))
     refs->ref[ref_idx].ins_upd_flag = 0, unch_cnt += 1
    ELSE
     refs->ref[ref_idx].ins_upd_flag = 2, upd_cnt += 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ins_cnt = (((ref_cnt - unch_cnt) - upd_cnt) - bad_cnt)
 SET stat = alterlist(refs->ref,ref_cnt)
 IF (upd_cnt > 0)
  IF (validate(cv_imp_step_ref_allow_updates_ind,0)=1)
   UPDATE  FROM cv_step_ref csr,
     (dummyt d1  WITH seq = value(ref_cnt))
    SET csr.step_level_flag = refs->ref[d1.seq].step_level_flag, csr.doc_type_cd = refs->ref[d1.seq].
     doc_type_cd, csr.doc_id_str = refs->ref[d1.seq].doc_id_str,
     csr.activity_subtype_cd = refs->ref[d1.seq].activity_subtype_cd, csr.proc_status_cd = refs->ref[
     d1.seq].proc_status_cd, csr.schedule_ind = refs->ref[d1.seq].schedule_ind,
     csr.step_type_cd = refs->ref[d1.seq].step_type_cd, csr.study_reltn_flag = refs->ref[d1.seq].
     study_reltn_flag, csr.updt_applctx = reqinfo->updt_applctx,
     csr.updt_cnt = (csr.updt_cnt+ 1), csr.updt_dt_tm = cnvtdatetime(curdate,curtime), csr.updt_id =
     reqinfo->updt_id,
     csr.updt_task = reqinfo->updt_task
    PLAN (d1
     WHERE (refs->ref[d1.seq].ins_upd_flag=2))
     JOIN (csr
     WHERE (csr.task_assay_cd=refs->ref[d1.seq].task_assay_cd))
    WITH nocounter, status(refs->ref[d1.seq].ins_upd_status,refs->ref[d1.seq].ins_upd_errnum,refs->
     ref[d1.seq].ins_upd_errmsg)
   ;end update
  ELSE
   CALL cv_log_msg(cv_audit,"No updates because cv_imp_step_ref_allow_updates_ind != 1")
   CALL cv_log_msg(cv_audit,build2("Would have attempted ",cnvtstring(upd_cnt)," updates"))
   SET upd_cnt = 0
  ENDIF
 ELSE
  CALL cv_log_msg(cv_debug,"No items to update. Continuing.")
 ENDIF
 IF (ins_cnt > 0)
  INSERT  FROM cv_step_ref csr,
    (dummyt d1  WITH seq = value(ref_cnt))
   SET csr.task_assay_cd = refs->ref[d1.seq].task_assay_cd, csr.step_level_flag = refs->ref[d1.seq].
    step_level_flag, csr.doc_type_cd = refs->ref[d1.seq].doc_type_cd,
    csr.doc_id_str = refs->ref[d1.seq].doc_id_str, csr.activity_subtype_cd = refs->ref[d1.seq].
    activity_subtype_cd, csr.proc_status_cd = refs->ref[d1.seq].proc_status_cd,
    csr.schedule_ind = refs->ref[d1.seq].schedule_ind, csr.step_type_cd = refs->ref[d1.seq].
    step_type_cd, csr.study_reltn_flag = refs->ref[d1.seq].study_reltn_flag,
    csr.updt_applctx = reqinfo->updt_applctx, csr.updt_cnt = 0, csr.updt_dt_tm = cnvtdatetime(curdate,
     curtime),
    csr.updt_id = reqinfo->updt_id, csr.updt_task = reqinfo->updt_task
   PLAN (d1
    WHERE (refs->ref[d1.seq].ins_upd_flag=1))
    JOIN (csr)
   WITH nocounter, status(refs->ref[d1.seq].ins_upd_status,refs->ref[d1.seq].ins_upd_errnum,refs->
    ref[d1.seq].ins_upd_errmsg)
  ;end insert
 ELSE
  CALL cv_log_msg(cv_info,"No items to insert. Continuing.")
 ENDIF
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(requestin)
  CALL echorecord(xref)
  CALL echorecord(refs)
 ENDIF
 CALL cv_log_msg(cv_info,build("Number of DTAs not found: ",(list_cnt - ref_cnt)))
 CALL cv_log_msg(cv_info,build("Number of items with bad or missing data: ",bad_cnt))
 CALL cv_log_msg(cv_info,build("Number of unchanged items: ",unch_cnt))
 CALL cv_log_msg(cv_info,build("Number of inserts attempted: ",ins_cnt))
 CALL cv_log_msg(cv_info,build("Number of updates attempted: ",upd_cnt))
 CALL cv_log_msg(cv_info,"--------------------------------------------")
 FOR (ref_idx = 1 TO ref_cnt)
   IF ((refs->ref[ref_idx].ins_upd_flag=1)
    AND (refs->ref[ref_idx].ins_upd_status != 1))
    CALL cv_log_msg(cv_error,build("Insert failed on cv_step_ref where task_assay=",refs->ref[ref_idx
      ].task_assay_cd))
    CALL cv_log_msg(cv_error,build("Error: ",refs->ref[ref_idx].ins_upd_errmsg))
    SET err_cnt += 1
   ELSEIF ((refs->ref[ref_idx].ins_upd_flag=2)
    AND (refs->ref[ref_idx].ins_upd_status != 1)
    AND validate(cv_imp_step_ref_allow_updates_ind,0)=1)
    CALL cv_log_msg(cv_error,build("Update failed on cv_step_ref where task_assay=",refs->ref[ref_idx
      ].task_assay_cd))
    CALL cv_log_msg(cv_error,build("Error: ",refs->ref[ref_idx].ins_upd_errmsg))
    SET err_cnt += 1
   ENDIF
 ENDFOR
 IF (err_cnt > 0)
  GO TO exit_script
 ENDIF
 SET failure = "F"
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  CALL echorecord(refs)
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL cv_log_msg_post("MOD 003 11/09/11 FE2417")
END GO
