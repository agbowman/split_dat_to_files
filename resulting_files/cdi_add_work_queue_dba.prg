CREATE PROGRAM cdi_add_work_queue:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 queue_qual[*]
      2 display = c40
      2 description = c60
      2 active_ind = i2
      2 code_value_qual[*]
        3 code_set = i4
        3 code_value = f8
        3 collation_seq = i4
      2 prsnl_qual[*]
        3 person_id = f8
        3 exception_ind = i2
      2 time_qual[*]
        3 open_days_bitmap = i4
        3 open_time = i4
        3 close_time = i4
      2 rule_qual[*]
        3 criteria_qual[*]
          4 variable_cd = f8
          4 comparison_flag = i2
          4 value_cd = f8
          4 value_nbr = i4
          4 value_dt_tm = dq8
          4 value_txt = vc
          4 value_entity_id = f8
          4 value_entity_name = vc
          4 value_entity_dbl_id = f8
      2 attr_cnfg_qual[*]
        3 attr_code_value = f8
        3 req_ind = i2
        3 warn_ind = i2
        3 multi_select_enable_ind = i2
      2 error_queue_ind = i2
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
 DECLARE lscnt = i4 WITH protect, noconstant(0)
 DECLARE lfcnt = i4 WITH protect, noconstant(0)
 DECLARE lconfigcnt = i4 WITH protect, noconstant(0)
 DECLARE lconfigidx = i4 WITH protect, noconstant(0)
 DECLARE lrulecnt = i4 WITH protect, noconstant(0)
 DECLARE lcriteriacnt = i4 WITH protect, noconstant(0)
 DECLARE lruleidx = i4 WITH protect, noconstant(0)
 DECLARE lcriteriaidx = i4 WITH protect, noconstant(0)
 DECLARE curruleid = f8 WITH protect, noconstant(0.0)
 DECLARE logicaldomainid = f8 WITH protect, noconstant(0.0)
 DECLARE logicaldomainname = vc WITH protect, noconstant("")
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dauth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dinactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_ADD_WORK_QUEUE **********")
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
 SET lcdiseqcnt = lquecnt
 FOR (lqueidx = 1 TO lquecnt)
   SET lprsnlcnt = size(request->queue_qual[lqueidx].prsnl_qual,5)
   SET ltimecnt = size(request->queue_qual[lqueidx].time_qual,5)
   SET lrulecnt = size(request->queue_qual[lqueidx].rule_qual,5)
   SET lcriteriacnt = 0
   FOR (lruleidx = 1 TO lrulecnt)
     SET lcriteriacnt += size(request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual,5)
   ENDFOR
   SET lconfigcnt = size(request->queue_qual[lqueidx].attr_cnfg_qual,5)
   SET lcdiseqcnt = (((((lcdiseqcnt+ lprsnlcnt)+ ltimecnt)+ lrulecnt)+ lcriteriacnt)+ lconfigcnt)
 ENDFOR
 CALL alterlist(cdi_seq_rec->qual,lcdiseqcnt)
 CALL echo("Retrieving CDI Sequences")
 EXECUTE dm2_dar_get_bulk_seq "cdi_seq_rec->qual", lcdiseqcnt, "id",
 1, "cdi_seq"
 IF ((m_dm2_seq_stat->n_status != 1))
  SET sscriptstatus = "F"
  SET sscriptmsg = "ERROR ENCOUNTERED IN DM2_DAR_GET_BULK_SEQ (CDI_SEQ)"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p,
   logical_domain ld
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ld
   WHERE ld.logical_domain_id=p.logical_domain_id)
  DETAIL
   logicaldomainid = p.logical_domain_id, logicaldomainname = ld.mnemonic_key
  WITH nocounter
 ;end select
 SET lscnt = 0
 SET lfcnt = 0
 SET lcdiseqcnt = 0
 FOR (lqueidx = 1 TO lquecnt)
   SET lcdiseqcnt += 1
   SET reply->queue_qual[lqueidx].status = "S"
   SET reply->queue_qual[lqueidx].status_reason = "SUCCESS"
   SET reply->queue_qual[lqueidx].display = request->queue_qual[lqueidx].display
   SET gm_i_code_value0619_req->allow_partial_ind = 0
   SET gm_i_code_value0619_req->code_seti = 1
   SET gm_i_code_value0619_req->cdf_meaningi = 1
   SET gm_i_code_value0619_req->displayi = 1
   SET gm_i_code_value0619_req->descriptioni = 1
   SET gm_i_code_value0619_req->definitioni = 1
   SET gm_i_code_value0619_req->collation_seqi = 0
   SET gm_i_code_value0619_req->active_type_cdi = 1
   SET gm_i_code_value0619_req->active_indi = 1
   SET gm_i_code_value0619_req->active_dt_tmi = 1
   SET gm_i_code_value0619_req->inactive_dt_tmi = 1
   SET gm_i_code_value0619_req->begin_effective_dt_tmi = 1
   SET gm_i_code_value0619_req->end_effective_dt_tmi = 1
   SET gm_i_code_value0619_req->data_status_cdi = 1
   SET gm_i_code_value0619_req->data_status_dt_tmi = 1
   SET gm_i_code_value0619_req->data_status_prsnl_idi = 1
   SET gm_i_code_value0619_req->active_status_prsnl_idi = 0
   SET gm_i_code_value0619_req->ckii = 0
   SET gm_i_code_value0619_req->concept_ckii = 0
   SET gm_i_code_value0619_req->collation_seqn = 0
   SET gm_i_code_value0619_req->begin_effective_dt_tmn = 0
   SET gm_i_code_value0619_req->data_status_dt_tmn = 0
   SET gm_i_code_value0619_req->concept_ckin = 0
   SET dstat = gm_i_code_value0619_i4("code_set",4002600,1,0)
   SET dstat = gm_i_code_value0619_vc("display",trim(request->queue_qual[lqueidx].display),1,0)
   SET dstat = gm_i_code_value0619_vc("display_key",trim(cnvtupper(cnvtalphanum(request->queue_qual[
       lqueidx].display))),1,0)
   SET dstat = gm_i_code_value0619_vc("description",trim(request->queue_qual[lqueidx].description),1,
    0)
   IF (textlen(trim(logicaldomainname)) > 0)
    SET dstat = gm_i_code_value0619_vc("definition",trim(logicaldomainname),1,0)
   ELSE
    SET dstat = gm_i_code_value0619_vc("definition",trim(request->queue_qual[lqueidx].description),1,
     0)
   ENDIF
   IF ((request->queue_qual[lqueidx].error_queue_ind=0))
    SET dstat = gm_i_code_value0619_vc("cdf_meaning","WORK_QUEUE",1,0)
   ELSE
    SET dstat = gm_i_code_value0619_vc("cdf_meaning","ERROR_QUEUE",1,0)
   ENDIF
   SET dstat = gm_i_code_value0619_i2("active_ind",request->queue_qual[lqueidx].active_ind,1,0)
   SET dstat = gm_i_code_value0619_dq8("begin_effective_dt_tm",cnvtdatetime(curdate,0),1,0)
   SET dstat = gm_i_code_value0619_dq8("end_effective_dt_tm",cnvtdatetime("31-DEC-2100 23:59:59"),1,0
    )
   SET dstat = gm_i_code_value0619_f8("data_status_cd",dauth,1,0)
   SET dstat = gm_i_code_value0619_dq8("data_status_dt_tm",cnvtdatetime(sysdate),1,0)
   SET dstat = gm_i_code_value0619_f8("data_status_prsnl_id",reqinfo->updt_id,1,0)
   IF ((request->queue_qual[lqueidx].active_ind=1))
    SET dstat = gm_i_code_value0619_f8("active_type_cd",dactive,1,0)
    SET dstat = gm_i_code_value0619_dq8("active_dt_tm",cnvtdatetime(sysdate),1,0)
    SET dstat = gm_i_code_value0619_dq8("inactive_dt_tm",null,1,1)
   ELSE
    SET dstat = gm_i_code_value0619_f8("active_type_cd",dinactive,1,0)
    SET dstat = gm_i_code_value0619_dq8("active_dt_tm",null,1,1)
    SET dstat = gm_i_code_value0619_dq8("inactive_dt_tm",cnvtdatetime(sysdate),1,0)
   ENDIF
   EXECUTE gm_i_code_value0619  WITH replace("REQUEST",gm_i_code_value0619_req), replace("REPLY",
    gm_i_code_value0619_rep)
   CALL echorecord(gm_i_code_value0619_req)
   CALL echorecord(gm_i_code_value0619_rep)
   IF ((((gm_i_code_value0619_rep->curqual != 1)) OR (size(gm_i_code_value0619_rep->qual,5) != 1)) )
    SET reply->queue_qual[lqueidx].status = "F"
    SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CODE_VALUE FAILED"
   ELSE
    SET reply->queue_qual[lqueidx].work_queue_cd = gm_i_code_value0619_rep->qual[1].code_value
    SET reply->queue_qual[lqueidx].work_queue_id = cdi_seq_rec->qual[lcdiseqcnt].id
    CALL echo(build("Now Processing Item #",lqueidx," With a Queue CD #",reply->queue_qual[lqueidx].
      work_queue_cd))
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    INSERT  FROM cdi_work_queue cwq
     SET cwq.work_queue_cd = reply->queue_qual[lqueidx].work_queue_cd, cwq.cdi_work_queue_id = reply
      ->queue_qual[lqueidx].work_queue_id, cwq.work_queue_name = request->queue_qual[lqueidx].display,
      cwq.work_queue_description = request->queue_qual[lqueidx].description, cwq
      .default_authenticated_ind = request->queue_qual[lqueidx].default_authenticated_ind, cwq
      .pagination_ind = request->queue_qual[lqueidx].pagination_ind,
      cwq.reg_action_keys_txt = request->queue_qual[lqueidx].reg_action_keys_txt, cwq.updt_dt_tm =
      cnvtdatetime(sysdate), cwq.updt_task = reqinfo->updt_task,
      cwq.updt_id = reqinfo->updt_id, cwq.updt_applctx = reqinfo->updt_applctx, cwq.updt_cnt = 0,
      cwq.logical_domain_id = logicaldomainid
     WITH counter
    ;end insert
    IF (curqual != 1)
     SET reply->queue_qual[lqueidx].status = "F"
     SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_WORK_QUEUE FAILED"
    ENDIF
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lcvgcnt = size(request->queue_qual[lqueidx].code_value_qual,5)
    FOR (lcvgidx = 1 TO lcvgcnt)
     INSERT  FROM code_value_group c
      SET c.parent_code_value = reply->queue_qual[lqueidx].work_queue_cd, c.child_code_value =
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
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lprsnlcnt = size(request->queue_qual[lqueidx].prsnl_qual,5)
    FOR (lprsnlidx = 1 TO lprsnlcnt)
      SET lcdiseqcnt += 1
      INSERT  FROM cdi_work_queue_prsnl_reltn pr
       SET pr.cdi_work_queue_id = reply->queue_qual[lqueidx].work_queue_id, pr
        .cdi_work_queue_prsnl_reltn_id = cdi_seq_rec->qual[lcdiseqcnt].id, pr.person_id = request->
        queue_qual[lqueidx].prsnl_qual[lprsnlidx].person_id,
        pr.exception_ind = request->queue_qual[lqueidx].prsnl_qual[lprsnlidx].exception_ind, pr
        .updt_dt_tm = cnvtdatetime(sysdate), pr.updt_task = reqinfo->updt_task,
        pr.updt_id = reqinfo->updt_id, pr.updt_applctx = reqinfo->updt_applctx, pr.updt_cnt = 0
       WITH counter
      ;end insert
      IF (curqual != 1)
       SET reply->queue_qual[lqueidx].status = "F"
       SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_WORK_QUEUE_PRSNL_RELTN FAILED"
       SET lprsnlidx = lprsnlcnt
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET ltimecnt = size(request->queue_qual[lqueidx].time_qual,5)
    FOR (ltimeidx = 1 TO ltimecnt)
      SET lcdiseqcnt += 1
      INSERT  FROM cdi_work_queue_time t
       SET t.cdi_work_queue_time_id = cdi_seq_rec->qual[lcdiseqcnt].id, t.cdi_work_queue_id = reply->
        queue_qual[lqueidx].work_queue_id, t.open_days_bitmap = request->queue_qual[lqueidx].
        time_qual[ltimeidx].open_days_bitmap,
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
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lrulecnt = size(request->queue_qual[lqueidx].rule_qual,5)
    FOR (lruleidx = 1 TO lrulecnt)
      SET lcdiseqcnt += 1
      INSERT  FROM cdi_rule r
       SET r.parent_entity_id = reply->queue_qual[lqueidx].work_queue_id, r.cdi_rule_id = cdi_seq_rec
        ->qual[lcdiseqcnt].id, r.parent_entity_name = "CDI_WORK_QUEUE",
        r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_task = reqinfo->updt_task, r.updt_id = reqinfo->
        updt_id,
        r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
      ;end insert
      SET curruleid = cdi_seq_rec->qual[lcdiseqcnt].id
      SET lcriteriacnt = size(request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual,5)
      FOR (lcriteriaidx = 1 TO lcriteriacnt)
        IF ((request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
        value_entity_name != "")
         AND (request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
        value_entity_dbl_id=0))
         SET sscriptstatus = "F"
         SET sscriptmsg = "REQUEST VALUE_ENTITY_NAME POPULATED WITHOUT VALUE_ENTITY_DBL_ID SET"
         GO TO exit_script
        ENDIF
        SET lcdiseqcnt += 1
        INSERT  FROM cdi_rule_criteria rc
         SET rc.parent_entity_id = reply->queue_qual[lqueidx].work_queue_id, rc.cdi_rule_criteria_id
           = cdi_seq_rec->qual[lcdiseqcnt].id, rc.cdi_rule_id = curruleid,
          rc.parent_entity_name = "CDI_WORK_QUEUE", rc.variable_cd = request->queue_qual[lqueidx].
          rule_qual[lruleidx].criteria_qual[lcriteriaidx].variable_cd, rc.comparison_flag = request->
          queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].comparison_flag,
          rc.value_cd = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].
          value_cd, rc.value_dt_tm = cnvtdatetime(request->queue_qual[lqueidx].rule_qual[lruleidx].
           criteria_qual[lcriteriaidx].value_dt_tm), rc.value_txt = request->queue_qual[lqueidx].
          rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_txt,
          rc.value_nbr = request->queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx]
          .value_nbr, rc.value_entity_id = request->queue_qual[lqueidx].rule_qual[lruleidx].
          criteria_qual[lcriteriaidx].value_entity_dbl_id, rc.value_entity_name = request->
          queue_qual[lqueidx].rule_qual[lruleidx].criteria_qual[lcriteriaidx].value_entity_name,
          rc.updt_dt_tm = cnvtdatetime(sysdate), rc.updt_task = reqinfo->updt_task, rc.updt_id =
          reqinfo->updt_id,
          rc.updt_applctx = reqinfo->updt_applctx, rc.updt_cnt = 0
        ;end insert
        IF (curqual != 1)
         SET reply->queue_qual[lqueidx].status = "F"
         SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_CRITERIA FAILED"
         SET lruleidx = lrulecnt
        ENDIF
      ENDFOR
      IF (curqual != 1)
       SET reply->queue_qual[lqueidx].status = "F"
       SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_RULE FAILED"
       SET lruleidx = lrulecnt
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    SET lconfigcnt = size(request->queue_qual[lqueidx].attr_cnfg_qual,5)
    FOR (lconfigidx = 1 TO lconfigcnt)
      SET lcdiseqcnt += 1
      INSERT  FROM cdi_work_item_attrib_cnfg cnfg
       SET cnfg.cdi_work_item_attrib_cnfg_id = cdi_seq_rec->qual[lcdiseqcnt].id, cnfg
        .cdi_work_queue_id = reply->queue_qual[lqueidx].work_queue_id, cnfg.attribute_cd = request->
        queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].attr_code_value,
        cnfg.required_ind = request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].req_ind, cnfg
        .warn_ind = request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].warn_ind, cnfg
        .multi_select_enable_ind = request->queue_qual[lqueidx].attr_cnfg_qual[lconfigidx].
        multi_select_enable_ind,
        cnfg.updt_dt_tm = cnvtdatetime(sysdate), cnfg.updt_task = reqinfo->updt_task, cnfg.updt_id =
        reqinfo->updt_id,
        cnfg.updt_applctx = reqinfo->updt_applctx, cnfg.updt_cnt = 0
      ;end insert
      IF (curqual != 1)
       SET reply->queue_qual[lqueidx].status = "F"
       SET reply->queue_qual[lqueidx].status_reason = "INSERT INTO CDI_WORK_ITEM_ATTRIB_CNFG FAILED"
       SET lconfigidx = lconfigcnt
      ENDIF
    ENDFOR
   ENDIF
   IF ((reply->queue_qual[lqueidx].status="S"))
    CALL echo(build2("Commiting For Work Queue CD:",reply->queue_qual[lqueidx].work_queue_cd))
    SET lscnt += 1
    COMMIT
   ELSE
    CALL echo(build2("Rolling Back Work Queue:",trim(reply->queue_qual[lqueidx].display)))
    SET lfcnt += 1
    ROLLBACK
   ENDIF
 ENDFOR
 IF (lscnt=lquecnt)
  SET sscriptstatus = "S"
  SET sscriptmsg = "ALL QUEUES WERE SUCCESSFULLY ADDED"
 ELSEIF (lfcnt=lquecnt)
  SET sscriptstatus = "F"
  SET sscriptmsg = "ALL QUEUES FAILED TO ADD"
 ELSE
  SET sscriptstatus = "P"
  SET sscriptmsg = "SOME QUEUES FAILED TO ADD, CHECK INDIVIDUAL STATUS"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "ADD"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_ADD_WORK_QUEUE"
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
 CALL echo("********** END CDI_ADD_WORK_QUEUE **********")
 CALL echo(sline)
END GO
