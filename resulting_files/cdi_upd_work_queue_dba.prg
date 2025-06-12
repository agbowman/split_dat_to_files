CREATE PROGRAM cdi_upd_work_queue:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 queue_qual[*]
      2 work_queue_cd = f8
      2 work_queue_id = f8
      2 action_flag = i2
      2 display = c40
      2 description = c60
      2 active_ind = i2
      2 code_value_qual[*]
        3 action_flag = i2
        3 code_set = i4
        3 code_value = f8
        3 collation_seq = i4
      2 prsnl_qual[*]
        3 action_flag = i2
        3 work_queue_prsnl_reltn_id = f8
        3 person_id = f8
        3 exception_ind = i2
      2 time_qual[*]
        3 action_flag = i2
        3 work_queue_time_id = f8
        3 open_days_bitmap = i4
        3 open_time = i4
        3 close_time = i4
      2 rule_qual[*]
        3 action_flag = i2
        3 work_queue_rule_id = f8
        3 criteria_qual[*]
          4 action_flag = i2
          4 work_queue_criteria_id = f8
          4 variable_cd = f8
          4 comparison_flag = i2
          4 value_cd = f8
          4 value_nbr = i4
          4 value_dt_tm = dq8
          4 value_txt = vc
          4 value_entity_id = f8
          4 value_entity_name = vc
      2 attr_cnfg_qual[*]
        3 action_flag = i2
        3 attr_code_value = f8
        3 req_ind = i2
        3 warn_ind = i2
        3 multi_select_enable_ind = i2
      2 default_authenticated_ind = i2
      2 pagination_ind = i2
      2 reg_action_keys_txt = vc
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 queue_qual[*]
      2 status = c1
      2 status_reason = vc
      2 work_queue_cd = f8
      2 work_queue_id = f8
      2 display = vc
    1 elapsed_time = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 RECORD cdi_seq_rec(
   1 qual[*]
     2 id = f8
 ) WITH protect
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lquecnt = i4 WITH protect, noconstant(0)
 DECLARE lqueidx = i4 WITH protect, noconstant(0)
 DECLARE lcvgcnt = i4 WITH protect, noconstant(0)
 DECLARE lcvgidx = i4 WITH protect, noconstant(0)
 DECLARE lprsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE lprsnlidx = i4 WITH protect, noconstant(0)
 DECLARE ltimecnt = i4 WITH protect, noconstant(0)
 DECLARE ltimeidx = i4 WITH protect, noconstant(0)
 DECLARE lcdiseqcnt = i4 WITH protect, noconstant(0)
 DECLARE lupdcnt = i4 WITH protect, noconstant(0)
 DECLARE lscnt = i4 WITH protect, noconstant(0)
 DECLARE lfcnt = i4 WITH protect, noconstant(0)
 DECLARE lconfigcnt = i4 WITH protect, noconstant(0)
 DECLARE lconfigidx = i4 WITH protect, noconstant(0)
 DECLARE lconfigupdcnt = i4 WITH protect, noconstant(0)
 DECLARE lrulecnt = i4 WITH protect, noconstant(0)
 DECLARE lcriteriacnt = i4 WITH protect, noconstant(0)
 DECLARE lruleidx = i4 WITH protect, noconstant(0)
 DECLARE lcriteriaidx = i4 WITH protect, noconstant(0)
 DECLARE curruleidx = f8 WITH protect, noconstant(0)
 DECLARE logicaldomainid = f8 WITH private, noconstant(0.0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dinactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE nact_none = i2 WITH protect, constant(0)
 DECLARE nact_add = i2 WITH protect, constant(1)
 DECLARE nact_upd = i2 WITH protect, constant(2)
 DECLARE nact_rmv = i2 WITH protect, constant(3)
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_UPD_WORK_QUEUE **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 SET lquecnt = size(request->queue_qual,5)
 IF (lquecnt <= 0)
  SET sscriptstatus = "F"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(reply->queue_qual,lquecnt)
 SET lcdiseqcnt = 0
 FOR (lqueidx = 1 TO lquecnt)
   SET lprsnlcnt = size(request->queue_qual[lqueidx].prsnl_qual,5)
   FOR (lprsnlidx = 1 TO lprsnlcnt)
     IF ((request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].action_flag=nact_add))
      SET lcdiseqcnt += 1
     ENDIF
   ENDFOR
   SET ltimecnt = size(request->queue_qual[lqueidx].time_qual,5)
   FOR (ltimeidx = 1 TO ltimecnt)
     IF ((request->queue_qual[lqueidx].time_qual[ltimeidx].action_flag=nact_add))
      SET lcdiseqcnt += 1
     ENDIF
   ENDFOR
   SET lrulecnt = size(request->queue_qual[lqueidx].rule_qual,5)
   FOR (lruleidx = 1 TO lrulecnt)
     IF ((request->queue_qual[lqueidx].rule_qual[lruleidx].action_flag=nact_add))
      SET lcriteriacnt = size(request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual,5)
      SET lcdiseqcnt = ((lcdiseqcnt+ lcriteriacnt)+ 1)
     ELSE
      SET lcriteriacnt = size(request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual,5)
      FOR (lcriteriaidx = 1 TO lcriteriacnt)
        IF ((request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].action_flag
        =nact_add))
         SET lcdiseqcnt += 1
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   SET lconfigcnt = size(request->queue_qual[lqueidx].attr_cnfg_qual,5)
   FOR (lconfigidx = 1 TO lconfigcnt)
     IF ((request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].action_flag=nact_add))
      SET lcdiseqcnt += 1
     ENDIF
   ENDFOR
 ENDFOR
 IF (lcdiseqcnt > 0)
  CALL echo(build("Retrieving CDI Sequences:",lcdiseqcnt))
  EXECUTE dm2_dar_get_bulk_seq "cdi_seq_rec->qual", lcdiseqcnt, "id",
  1, "cdi_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   SET sscriptstatus = "F"
   SET sscriptmsg = "ERROR ENCOUNTERED IN DM2_DAR_GET_BULK_SEQ (CDI_SEQ)"
   CALL echo("ERROR ENCOUNTERED IN DM2_DAR_GET_BULK_SEQ (CDI_SEQ)")
   GO TO exit_script
  ENDIF
 ENDIF
 SET lscnt = 0
 SET lfcnt = 0
 SET lcdiseqcnt = 0
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm > cnvtdatetime(sysdate)
  DETAIL
   logicaldomainid = p.logical_domain_id
  WITH nocounter
 ;end select
 FOR (lqueidx = 1 TO lquecnt)
   SET reply->queue_qual[lqueidx].status = "S"
   SET reply->queue_qual[lqueidx].status_reason = "SUCCESS"
   SET reply->queue_qual[lqueidx].work_queue_cd = request->queue_qual[lqueidx].work_queue_cd
   SET reply->queue_qual[lqueidx].work_queue_id = request->queue_qual[lqueidx].work_queue_id
   SET reply->queue_qual[lqueidx].display = request->queue_qual[lqueidx].display
   IF ((request->queue_qual[lqueidx].work_queue_cd > 0)
    AND (request->queue_qual[lqueidx].action_flag=nact_upd))
    SELECT INTO "NL:"
     c.updt_cnt
     FROM code_value c
     PLAN (c
      WHERE (c.code_value=request->queue_qual[lqueidx].work_queue_cd))
     ORDER BY c.code_value
     HEAD c.code_value
      lupdcnt = (c.updt_cnt+ 1)
     WITH counter, forupdate(c)
    ;end select
    IF (curqual=0)
     SET reply->queue_qual[lqueidx].status = "F"
     SET reply->queue_qual[lqueidx].status_reason = "FAILED TO LOCK CODE_VALUE"
    ELSE
     SET gm_u_code_value0619_req->allow_partial_ind = 0
     SET gm_u_code_value0619_req->force_updt_ind = 1
     SET gm_u_code_value0619_req->code_valuew = 1
     SET gm_u_code_value0619_req->code_setw = 1
     SET gm_u_code_value0619_req->cdf_meaningw = 0
     SET gm_u_code_value0619_req->displayw = 0
     SET gm_u_code_value0619_req->display_keyw = 0
     SET gm_u_code_value0619_req->descriptionw = 0
     SET gm_u_code_value0619_req->definitionw = 0
     SET gm_u_code_value0619_req->collation_seqw = 0
     SET gm_u_code_value0619_req->active_type_cdw = 0
     SET gm_u_code_value0619_req->active_indw = 0
     SET gm_u_code_value0619_req->active_dt_tmw = 0
     SET gm_u_code_value0619_req->inactive_dt_tmw = 0
     SET gm_u_code_value0619_req->updt_dt_tmw = 0
     SET gm_u_code_value0619_req->updt_idw = 0
     SET gm_u_code_value0619_req->updt_cntw = 0
     SET gm_u_code_value0619_req->updt_taskw = 0
     SET gm_u_code_value0619_req->updt_applctxw = 0
     SET gm_u_code_value0619_req->begin_effective_dt_tmw = 0
     SET gm_u_code_value0619_req->end_effective_dt_tmw = 0
     SET gm_u_code_value0619_req->data_status_cdw = 0
     SET gm_u_code_value0619_req->data_status_dt_tmw = 0
     SET gm_u_code_value0619_req->data_status_prsnl_idw = 0
     SET gm_u_code_value0619_req->active_status_prsnl_idw = 0
     SET gm_u_code_value0619_req->ckiw = 0
     SET gm_u_code_value0619_req->concept_ckiw = 0
     SET gm_u_code_value0619_req->code_valuef = 0
     SET gm_u_code_value0619_req->code_setf = 0
     SET gm_u_code_value0619_req->cdf_meaningf = 0
     SET gm_u_code_value0619_req->displayf = 1
     SET gm_u_code_value0619_req->descriptionf = 1
     SET gm_u_code_value0619_req->definitionf = 1
     SET gm_u_code_value0619_req->collation_seqf = 0
     SET gm_u_code_value0619_req->active_type_cdf = 1
     SET gm_u_code_value0619_req->active_indf = 1
     SET gm_u_code_value0619_req->active_dt_tmf = 1
     SET gm_u_code_value0619_req->inactive_dt_tmf = 1
     SET gm_u_code_value0619_req->updt_cntf = 1
     SET gm_u_code_value0619_req->begin_effective_dt_tmf = 0
     SET gm_u_code_value0619_req->end_effective_dt_tmf = 0
     SET gm_u_code_value0619_req->data_status_cdf = 0
     SET gm_u_code_value0619_req->data_status_dt_tmf = 0
     SET gm_u_code_value0619_req->data_status_prsnl_idf = 0
     SET gm_u_code_value0619_req->active_status_prsnl_idf = 0
     SET gm_u_code_value0619_req->ckif = 0
     SET gm_u_code_value0619_req->concept_ckif = 0
     SET dstat = gm_u_code_value0619_f8("code_value",request->queue_qual[lqueidx].work_queue_cd,1,0,1
      )
     SET dstat = gm_u_code_value0619_i4("code_set",4002600,1,0,1)
     SET dstat = gm_u_code_value0619_vc("display",trim(request->queue_qual[lqueidx].display),1,0,0)
     SET dstat = gm_u_code_value0619_vc("description",trim(request->queue_qual[lqueidx].description),
      1,0,0)
     SET dstat = gm_u_code_value0619_vc("definition",trim(request->queue_qual[lqueidx].description),1,
      0,0)
     SET dstat = gm_u_code_value0619_i2("active_ind",request->queue_qual[lqueidx].active_ind,1,0,0)
     SET dstat = gm_u_code_value0619_i4("updt_cnt",lupdcnt,1,0,0)
     IF ((request->queue_qual[lqueidx].active_ind=1))
      SET dstat = gm_u_code_value0619_f8("active_type_cd",dactive,1,0,0)
      SET dstat = gm_u_code_value0619_dq8("active_dt_tm",cnvtdatetime(sysdate),1,0,0)
      SET dstat = gm_u_code_value0619_dq8("inactive_dt_tm",null,1,1,0)
     ELSE
      SET dstat = gm_u_code_value0619_f8("active_type_cd",dinactive,1,0,0)
      SET dstat = gm_u_code_value0619_dq8("active_dt_tm",null,1,1,0)
      SET dstat = gm_u_code_value0619_dq8("inactive_dt_tm",cnvtdatetime(sysdate),1,0,0)
     ENDIF
     EXECUTE gm_u_code_value0619  WITH replace(request,gm_u_code_value0619_req), replace(reply,
      gm_u_code_value0619_rep)
     CALL echorecord(gm_u_code_value0619_req)
     CALL echorecord(gm_u_code_value0619_rep)
     IF ((gm_u_code_value0619_rep->curqual != 1))
      SET reply->queue_qual[lqueidx].status = "F"
      SET reply->queue_qual[lqueidx].status_reason = "UPDATE INTO CODE_VALUE FAILED"
     ENDIF
    ENDIF
   ENDIF
   IF ((request->queue_qual[lqueidx].work_queue_id > 0)
    AND (request->queue_qual[lqueidx].action_flag=nact_upd)
    AND (reply->queue_qual[lqueidx].status="S"))
    SELECT INTO "NL:"
     r.updt_cnt
     FROM cdi_work_queue wq
     PLAN (wq
      WHERE (wq.cdi_work_queue_id=request->queue_qual[lqueidx].work_queue_id))
     ORDER BY wq.cdi_work_queue_id
     HEAD wq.cdi_work_queue_id
      lupdcnt = (wq.updt_cnt+ 1)
     WITH counter, forupdate(wq)
    ;end select
    IF (curqual=0)
     SET reply->queue_qual[lqueidx].status = "F"
     SET reply->queue_qual[lqueidx].status_reason = "FAILED TO LOCK CDI_WORK_QUEUE"
    ELSE
     UPDATE  FROM cdi_work_queue wq
      SET wq.work_queue_name = request->queue_qual[lqueidx].display, wq.work_queue_description =
       request->queue_qual[lqueidx].description, wq.default_authenticated_ind = request->queue_qual[
       lqueidx].default_authenticated_ind,
       wq.pagination_ind = request->queue_qual[lqueidx].pagination_ind, wq.reg_action_keys_txt =
       request->queue_qual[lqueidx].reg_action_keys_txt, wq.updt_dt_tm = cnvtdatetime(sysdate),
       wq.updt_task = reqinfo->updt_task, wq.updt_id = reqinfo->updt_id, wq.updt_applctx = reqinfo->
       updt_applctx,
       wq.updt_cnt = lupdcnt
      WHERE (wq.cdi_work_queue_id=request->queue_qual[lqueidx].work_queue_id)
      WITH counter
     ;end update
     IF (curqual != 1)
      SET reply->queue_qual[lqueidx].status = "F"
      SET reply->queue_qual[lqueidx].status_reason = "UPDATE INTO CDI_WORK_QUEUE FAILED"
     ENDIF
    ENDIF
   ELSEIF ((request->queue_qual[lqueidx].work_queue_id=0)
    AND (reply->queue_qual[lqueidx].status="S"))
    SELECT INTO "NL:"
     FROM cdi_work_queue wq
     PLAN (wq
      WHERE (wq.work_queue_cd=reply->queue_qual[lqueidx].work_queue_cd))
     WITH counter
    ;end select
    IF (curqual=0)
     INSERT  FROM cdi_work_queue wq
      SET wq.work_queue_cd = reply->queue_qual[lqueidx].work_queue_cd, wq.cdi_work_queue_id = seq(
        cdi_seq,nextval), wq.work_queue_name = request->queue_qual[lqueidx].display,
       wq.work_queue_description = request->queue_qual[lqueidx].description, wq
       .default_authenticated_ind = request->queue_qual[lqueidx].default_authenticated_ind, wq
       .pagination_ind = request->queue_qual[lqueidx].pagination_ind,
       wq.reg_action_keys_txt = request->queue_qual[lqueidx].reg_action_keys_txt, wq.updt_dt_tm =
       cnvtdatetime(sysdate), wq.updt_task = reqinfo->updt_task,
       wq.updt_id = reqinfo->updt_id, wq.updt_applctx = reqinfo->updt_applctx, wq.updt_cnt = 0,
       wq.logical_domain_id = logicaldomainid
      WITH counter
     ;end insert
     IF (curqual != 1)
      SET reply->queue_qual[lqueidx].status = "F"
      SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_WORK_QUEUE FAILED"
     ELSE
      SELECT INTO "NL:"
       FROM cdi_work_queue wq
       PLAN (wq
        WHERE (wq.work_queue_cd=reply->queue_qual[lqueidx].work_queue_cd))
       DETAIL
        request->queue_qual[lqueidx].work_queue_id = wq.cdi_work_queue_id, reply->queue_qual[lqueidx]
        .work_queue_id = wq.cdi_work_queue_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lcvgcnt = size(request->queue_qual[lqueidx].code_value_qual,5)
    FOR (lcvgidx = 1 TO lcvgcnt)
      IF ((request->queue_qual[lqueidx].code_value_qual[lcvgidx].action_flag=nact_rmv))
       SELECT INTO "NL:"
        FROM code_value_group c
        PLAN (c
         WHERE (c.parent_code_value=request->queue_qual[lqueidx].work_queue_cd)
          AND (c.child_code_value=request->queue_qual[lqueidx].code_value_qual[lcvgidx].code_value)
          AND ((c.code_set+ 0)=request->queue_qual[lqueidx].code_value_qual[lcvgidx].code_set))
        WITH counter, forupdate(c)
       ;end select
       IF (curqual=0)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason =
        "FAILED TO LOCK CODE_VALUE_GROUP (CODE_VALUE_QUAL)"
        SET lcvgidx = lcvgcnt
       ELSE
        DELETE  FROM code_value_group c
         WHERE (c.parent_code_value=request->queue_qual[lqueidx].work_queue_cd)
          AND (c.child_code_value=request->queue_qual[lqueidx].code_value_qual[lcvgidx].code_value)
          AND ((c.code_set+ 0)=request->queue_qual[lqueidx].code_value_qual[lcvgidx].code_set)
         WITH counter
        ;end delete
        IF (curqual != 1)
         SET reply->queue_qual[lqueidx].status = "F"
         SET reply->queue_qual[lqueidx].status_reason =
         "DELETE INTO CODE_VALUE_GROUP FAILED (CODE_VALUE_QUAL)"
         SET lcvgidx = lcvgcnt
        ENDIF
       ENDIF
      ELSEIF ((request->queue_qual[lqueidx].code_value_qual[lcvgidx].action_flag=nact_add))
       INSERT  FROM code_value_group c
        SET c.parent_code_value = request->queue_qual[lqueidx].work_queue_cd, c.child_code_value =
         request->queue_qual[lqueidx].code_value_qual[lcvgidx].code_value, c.code_set = request->
         queue_qual[lqueidx].code_value_qual[lcvgidx].code_set,
         c.collation_seq = request->queue_qual[lqueidx].code_value_qual[lcvgidx].collation_seq, c
         .updt_dt_tm = cnvtdatetime(sysdate), c.updt_task = reqinfo->updt_task,
         c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
        WITH counter
       ;end insert
       IF (curqual != 1)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason =
        "INSERT INTO CODE_VALUE_GROUP FAILED (CODE_VALUE_QUAL)"
        SET lcvgidx = lcvgcnt
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lprsnlcnt = size(request->queue_qual[lqueidx].prsnl_qual,5)
    FOR (lprsnlidx = 1 TO lprsnlcnt)
      IF ((request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].action_flag=nact_rmv))
       SELECT INTO "NL:"
        FROM cdi_work_queue_prsnl_reltn pr
        PLAN (pr
         WHERE (pr.cdi_work_queue_prsnl_reltn_id=request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].
         work_queue_prsnl_reltn_id)
          AND ((pr.cdi_work_queue_id+ 0)=request->queue_qual[lqueidx].work_queue_id)
          AND ((pr.person_id+ 0)=request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].person_id))
        WITH counter, forupdate(pr)
       ;end select
       IF (curqual=0)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason = "FAILED TO LOCK CDI_WORK_QUEUE_PRSNL_RELTN"
        SET lprsnlidx = lprsnlcnt
       ELSE
        DELETE  FROM cdi_work_queue_prsnl_reltn pr
         WHERE (pr.cdi_work_queue_prsnl_reltn_id=request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].
         work_queue_prsnl_reltn_id)
          AND ((pr.cdi_work_queue_id+ 0)=request->queue_qual[lqueidx].work_queue_id)
          AND ((pr.person_id+ 0)=request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].person_id)
         WITH counter
        ;end delete
        IF (curqual != 1)
         SET reply->queue_qual[lqueidx].status = "F"
         SET reply->queue_qual[lqueidx].status_reason =
         "DELETE INTO CDI_WORK_QUEUE_PRSNL_RELTN FAILED"
         SET lprsnlidx = lprsnlcnt
        ENDIF
       ENDIF
      ELSEIF ((request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].action_flag=nact_add))
       SET lcdiseqcnt += 1
       INSERT  FROM cdi_work_queue_prsnl_reltn pr
        SET pr.cdi_work_queue_id = request->queue_qual[lqueidx].work_queue_id, pr
         .cdi_work_queue_prsnl_reltn_id = cdi_seq_rec->qual[lcdiseqcnt].id, pr.person_id = request->
         queue_qual[lqueidx].prsnl_qual[lprsnlidx].person_id,
         pr.exception_ind = request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].exception_ind, pr
         .updt_dt_tm = cnvtdatetime(sysdate), pr.updt_task = reqinfo->updt_task,
         pr.updt_id = reqinfo->updt_id, pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = 0
        WITH counter
       ;end insert
       IF (curqual != 1)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason =
        "INSERT INTO CDI_WORK_QUEUE_PRSNL_RELTN FAILED"
        SET lprsnlidx = lprsnlcnt
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET ltimecnt = size(request->queue_qual[lqueidx].time_qual,5)
    FOR (ltimeidx = 1 TO ltimecnt)
      IF ((request->queue_qual[lqueidx].time_qual[ltimeidx].action_flag=nact_rmv))
       SELECT INTO "NL:"
        FROM cdi_work_queue_time t
        PLAN (t
         WHERE (t.cdi_work_queue_time_id=request->queue_qual[lqueidx].time_qual[ltimeidx].
         work_queue_time_id))
        WITH counter, forupdate(t)
       ;end select
       IF (curqual=0)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason = "FAILED TO LOCK CDI_WORK_QUEUE_TIME"
        SET ltimeidx = ltimecnt
       ELSE
        DELETE  FROM cdi_work_queue_time t
         WHERE (t.cdi_work_queue_time_id=request->queue_qual[lqueidx].time_qual[ltimeidx].
         work_queue_time_id)
         WITH counter
        ;end delete
        IF (curqual != 1)
         SET reply->queue_qual[lqueidx].status = "F"
         SET reply->queue_qual[lqueidx].status_reason = "DELETE INTO CDI_WORK_QUEUE_TIME FAILED"
         SET ltimeidx = ltimecnt
        ENDIF
       ENDIF
      ELSEIF ((request->queue_qual[lqueidx].time_qual[ltimeidx].action_flag=nact_add))
       SET lcdiseqcnt += 1
       INSERT  FROM cdi_work_queue_time t
        SET t.cdi_work_queue_id = request->queue_qual[lqueidx].work_queue_id, t
         .cdi_work_queue_time_id = cdi_seq_rec->qual[lcdiseqcnt].id, t.open_days_bitmap = request->
         queue_qual[lqueidx].time_qual[ltimeidx].open_days_bitmap,
         t.open_time = request->queue_qual[lqueidx].time_qual[ltimeidx].open_time, t.close_time =
         request->queue_qual[lqueidx].time_qual[ltimeidx].close_time, t.updt_dt_tm = cnvtdatetime(
          sysdate),
         t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
         updt_applctx,
         t.updt_cnt = 0
        WITH counter
       ;end insert
       IF (curqual != 1)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_WORK_QUEUE_TIME FAILED"
        SET ltimeidx = ltimecnt
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lrulecnt = size(request->queue_qual[lqueidx].rule_qual,5)
    FOR (lruleidx = 1 TO lrulecnt)
      IF ((request->queue_qual[lqueidx].rule_qual[lruleidx].action_flag=nact_rmv))
       DELETE  FROM cdi_rule_criteria rc
        WHERE (rc.cdi_rule_id=request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id)
       ;end delete
       DELETE  FROM cdi_rule r
        WHERE (r.cdi_rule_id=request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id)
         AND (r.parent_entity_id=request->queue_qual[lqueidx].work_queue_id)
        WITH counter
       ;end delete
      ELSEIF ((request->queue_qual[lqueidx].rule_qual[lruleidx].action_flag=nact_add))
       SET lcdiseqcnt += 1
       INSERT  FROM cdi_rule r
        SET r.cdi_rule_id = cdi_seq_rec->qual[lcdiseqcnt].id, r.parent_entity_id = request->
         queue_qual[lqueidx].work_queue_id, r.parent_entity_name = "CDI_WORK_QUEUE",
         r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo
         ->updt_id,
         r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
       ;end insert
       SET curruleidx = cdi_seq_rec->qual[lcdiseqcnt].id
       SET lcriteriacnt = size(request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual,5)
       FOR (lcriteriaidx = 1 TO lcriteriacnt)
         SET lcdiseqcnt += 1
         INSERT  FROM cdi_rule_criteria rc
          SET rc.cdi_rule_criteria_id = cdi_seq_rec->qual[lcdiseqcnt].id, rc.cdi_rule_id = curruleidx,
           rc.parent_entity_id = request->queue_qual[lqueidx].work_queue_id,
           rc.parent_entity_name = "CDI_WORK_QUEUE", rc.variable_cd = request->queue_qual[lqueidx].
           rule_qual[lruleidx].criteria_qual[lcriteriaidx].variable_cd, rc.comparison_flag = request
           ->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].comparison_flag,
           rc.value_cd = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx]
           .value_cd, rc.value_nbr = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[
           lcriteriaidx].value_nbr, rc.value_dt_tm = cnvtdatetime(request->queue_qual[lqueidx].
            rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_dt_tm),
           rc.value_txt = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx
           ].value_txt, rc.value_entity_id = request->queue_qual[lqueidx].rule_qual[lruleidx].
           criteria_qual[lcriteriaidx].value_entity_id, rc.value_entity_name = request->queue_qual[
           lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_entity_name,
           rc.updt_dt_tm = cnvtdatetime(sysdate), rc.updt_task = reqinfo->updt_task, rc.updt_id =
           reqinfo->updt_id,
           rc.updt_applctx = reqinfo->updt_applctx, rc.updt_cnt = 0
         ;end insert
         IF (curqual != 1)
          SET reply->queue_qual[lqueidx].status = "F"
          SET reply->queue_qual[lqueidx].status_reason =
          "INSERT INTO CDI_WORK_QUEUE_RULE_CRITERIA FAILED"
          SET lcriteriaidx = lcriteriacnt
          SET lruleidx = lrulecnt
         ENDIF
       ENDFOR
       IF (curqual != 1)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_RULE FAILED"
        SET lruleidx = lrulecnt
       ENDIF
      ELSE
       SELECT INTO "NL:"
        FROM cdi_rule r
        PLAN (r
         WHERE (r.cdi_rule_id=request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id)
          AND (r.parent_entity_id=request->queue_qual[lqueidx].work_queue_id))
        WITH counter, forupdate(r)
       ;end select
       IF (curqual=0)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason = "FAILED TO LOCK CDI_WORK_QUEUE_RULE"
        SET lruleidx = lrulecnt
       ELSE
        SET lcriteriacnt = size(request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual,5)
        FOR (lcriteriaidx = 1 TO lcriteriacnt)
          IF ((request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
          action_flag=nact_rmv))
           SELECT INTO "NL:"
            FROM cdi_rule_criteria rc
            PLAN (rc
             WHERE (rc.cdi_rule_criteria_id=request->queue_qual[lqueidx].rule_qual[lruleidx].
             criteria_qual[lcriteriaidx].work_queue_criteria_id)
              AND (rc.cdi_rule_id=request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id
             )
              AND (rc.parent_entity_id=request->queue_qual[lqueidx].work_queue_id))
            WITH counter, forupdate(r)
           ;end select
           IF (curqual=0)
            SET reply->queue_qual[lqueidx].status = "F"
            SET reply->queue_qual[lqueidx].status_reason = "FAILED TO LOCK CDI_WORK_QUEUE_CRITERIA"
            SET lcriteriaidx = lcriteriacnt
            SET lruleidx = lrulecnt
           ELSE
            DELETE  FROM cdi_rule_criteria rc
             WHERE (rc.cdi_rule_criteria_id=request->queue_qual[lqueidx].rule_qual[lruleidx].
             criteria_qual[lcriteriaidx].work_queue_criteria_id)
              AND (rc.cdi_rule_id=request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id
             )
              AND (rc.parent_entity_id=request->queue_qual[lqueidx].work_queue_id)
             WITH counter
            ;end delete
            IF (curqual != 1)
             SET reply->queue_qual[lqueidx].status = "F"
             SET reply->queue_qual[lqueidx].status_reason = "DELETE INTO CDI_WORK_QUEUE_RULE FAILED"
             SET lcriteriaidx = lcriteriacnt
             SET lruleidx = lrulecnt
            ENDIF
           ENDIF
          ELSEIF ((request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
          action_flag=nact_add))
           SET lcdiseqcnt += 1
           INSERT  FROM cdi_rule_criteria rc
            SET rc.cdi_rule_criteria_id = cdi_seq_rec->qual[lcdiseqcnt].id, rc.cdi_rule_id = request
             ->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id, rc.parent_entity_id =
             request->queue_qual[lqueidx].work_queue_id,
             rc.parent_entity_name = "CDI_WORK_QUEUE", rc.variable_cd = request->queue_qual[lqueidx].
             rule_qual[lruleidx].criteria_qual[lcriteriaidx].variable_cd, rc.comparison_flag =
             request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
             comparison_flag,
             rc.value_cd = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[
             lcriteriaidx].value_cd, rc.value_nbr = request->queue_qual[lqueidx].rule_qual[lruleidx].
             criteria_qual[lcriteriaidx].value_nbr, rc.value_dt_tm = cnvtdatetime(request->
              queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_dt_tm),
             rc.value_txt = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[
             lcriteriaidx].value_txt, rc.value_entity_id = request->queue_qual[lqueidx].rule_qual[
             lruleidx].criteria_qual[lcriteriaidx].value_entity_id, rc.value_entity_name = request->
             queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_entity_name,
             rc.updt_dt_tm = cnvtdatetime(sysdate), rc.updt_task = reqinfo->updt_task, rc.updt_id =
             reqinfo->updt_id,
             rc.updt_applctx = reqinfo->updt_applctx, rc.updt_cnt = 0
           ;end insert
           IF (curqual != 1)
            SET reply->queue_qual[lqueidx].status = "F"
            SET reply->queue_qual[lqueidx].status_reason =
            "INSERT INTO CDI_WORK_QUEUE_RULE_CRITERIA FAILED"
            SET lcriteriaidx = lcriteriacnt
            SET lruleidx = lrulecnt
           ENDIF
          ELSEIF ((request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
          action_flag=nact_upd))
           UPDATE  FROM cdi_rule_criteria rc
            SET rc.cdi_rule_id = request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id,
             rc.parent_entity_id = request->queue_qual[lqueidx].work_queue_id, rc.parent_entity_name
              = "CDI_WORK_QUEUE",
             rc.variable_cd = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[
             lcriteriaidx].variable_cd, rc.comparison_flag = request->queue_qual[lqueidx].rule_qual[
             lruleidx].criteria_qual[lcriteriaidx].comparison_flag, rc.value_cd = request->
             queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_cd,
             rc.value_nbr = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[
             lcriteriaidx].value_nbr, rc.value_dt_tm = cnvtdatetime(request->queue_qual[lqueidx].
              rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_dt_tm), rc.value_txt = request->
             queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_txt,
             rc.value_entity_id = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[
             lcriteriaidx].value_entity_id, rc.value_entity_name = request->queue_qual[lqueidx].
             rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_entity_name, rc.updt_dt_tm =
             cnvtdatetime(sysdate),
             rc.updt_task = reqinfo->updt_task, rc.updt_id = reqinfo->updt_id, rc.updt_applctx =
             reqinfo->updt_applctx,
             rc.updt_cnt = 0
            WHERE (rc.cdi_rule_criteria_id=request->queue_qual[lqueidx].rule_qual[lruleidx].
            criteria_qual[lcriteriaidx].work_queue_criteria_id)
             AND (rc.cdi_rule_id=request->queue_qual[lqueidx].rule_qual[lruleidx].work_queue_rule_id)
             AND (rc.parent_entity_id=request->queue_qual[lqueidx].work_queue_id)
            WITH counter
           ;end update
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SELECT INTO "NL:"
     cnfg.updt_cnt
     FROM cdi_work_item_attrib_cnfg cnfg
     PLAN (cnfg
      WHERE (cnfg.cdi_work_queue_id=request->queue_qual[lqueidx].work_queue_id))
     HEAD cnfg.cdi_work_queue_id
      lconfigupdcnt = (cnfg.updt_cnt+ 1)
    ;end select
    SET lconfigcnt = size(request->queue_qual[lqueidx].attr_cnfg_qual,5)
    FOR (lconfigidx = 1 TO lconfigcnt)
      IF ((request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].action_flag=nact_rmv))
       DELETE  FROM cdi_work_item_attrib_cnfg cnfg
        WHERE (cnfg.cdi_work_queue_id=request->queue_qual[lqueidx].work_queue_id)
         AND (cnfg.attribute_cd=request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].
        attr_code_value)
       ;end delete
      ENDIF
    ENDFOR
    FOR (lconfigidx = 1 TO lconfigcnt)
      IF ((request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].action_flag=nact_add))
       SET lcdiseqcnt += 1
       INSERT  FROM cdi_work_item_attrib_cnfg cnfg
        SET cnfg.cdi_work_item_attrib_cnfg_id = cdi_seq_rec->qual[lcdiseqcnt].id, cnfg
         .cdi_work_queue_id = request->queue_qual[lqueidx].work_queue_id, cnfg.attribute_cd = request
         ->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].attr_code_value,
         cnfg.required_ind = request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].req_ind, cnfg
         .warn_ind = request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].warn_ind, cnfg
         .multi_select_enable_ind = request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].
         multi_select_enable_ind,
         cnfg.updt_dt_tm = cnvtdatetime(sysdate), cnfg.updt_task = reqinfo->updt_task, cnfg.updt_id
          = reqinfo->updt_id,
         cnfg.updt_applctx = reqinfo->updt_applctx, cnfg.updt_cnt = lconfigupdcnt
       ;end insert
       IF (curqual != 1)
        SET reply->queue_qual[lqueidx].status = "F"
        SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_WORK_ITEM_ATTRIB_CNFG FAILED"
        SET lconfigidx = lconfigcnt
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    CALL echo(build2("Commiting For Work Queue CD:",request->queue_qual[lqueidx].work_queue_cd))
    SET lscnt += 1
    COMMIT
   ELSE
    CALL echo(build2("Rolling Back Work Queue CD:",request->queue_qual[lqueidx].work_queue_cd))
    SET lfcnt += 1
    ROLLBACK
   ENDIF
 ENDFOR
 IF (lscnt=lquecnt)
  SET sscriptstatus = "S"
  SET sscriptmsg = "ALL QUEUES WERE SUCCESSFULLY UPDATED"
 ELSEIF (lfcnt=lquecnt)
  SET sscriptstatus = "F"
  SET sscriptmsg = "ALL QUEUES FAILED TO UPDATE"
 ELSE
  SET sscriptstatus = "P"
  SET sscriptmsg = "SOME QUEUES FAILED TO UPDATE, CHECK INDIVIDUAL STATUS"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_UPD_WORK_QUEUE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 FREE RECORD m_dm2_seq_stat
 FREE RECORD cdi_seq_rec
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 SET reply->elapsed_time = delapsedtime
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 10/20/2010")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_UPD_WORK_QUEUE **********")
 CALL echo(sline)
END GO
