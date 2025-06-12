CREATE PROGRAM bb_upd_related_qc_reagents:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 related_reagent_list[*]
      2 id = f8
      2 related_reagent_detail_list[*]
        3 id = f8
        3 expected_result_list[*]
          4 id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].operationstatus)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectname)))
     SET lglbslsubeventsize = (lglbslsubeventsize+ size(trim(reply->status_data.subeventstatus[
       lglbslsubeventcnt].targetobjectvalue)))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt = (lglbslsubeventcnt+ 1)
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE nbb_save_noupdate = i2 WITH protect, constant(0)
 DECLARE nbb_save_new = i2 WITH protect, constant(1)
 DECLARE nbb_save_update = i2 WITH protect, constant(2)
 DECLARE nbb_save_delete = i2 WITH protect, constant(3)
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE nend_date = f8 WITH protect, constant(cnvtdatetime("31-DEC-2100 23:59:59.99"))
 DECLARE nscript_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 RECORD upd_related_reagents(
   1 rows[*]
     2 related_reagent_id = f8
     2 reagent_cd = f8
     2 related_reagent_name = c40
     2 active_ind = i2
     2 updt_cnt = i4
     2 prev_related_reagent_id = f8
     2 active_ind = i2
     2 prev_active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD ins_related_reagents(
   1 rows[*]
     2 related_reagent_id = f8
     2 reagent_cd = f8
     2 related_reagent_name = c40
     2 active_ind = i2
     2 updt_cnt = i4
     2 prev_related_reagent_id = f8
     2 active_ind = i2
     2 prev_active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD upd_related_reagent_detail(
   1 rows[*]
     2 related_reagent_detail_id = f8
     2 related_reagent_id = f8
     2 enhancement_cd = f8
     2 control_cd = f8
     2 phase_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 prev_related_reagent_detail_id = f8
     2 active_ind = i2
     2 prev_active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD ins_related_reagent_detail(
   1 rows[*]
     2 related_reagent_detail_id = f8
     2 related_reagent_id = f8
     2 enhancement_cd = f8
     2 control_cd = f8
     2 phase_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 prev_related_reagent_detail_id = f8
     2 active_ind = i2
     2 prev_active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD upd_expected_results(
   1 rows[*]
     2 expected_result_id = f8
     2 related_reagent_detail_id = f8
     2 nomenclature_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 prev_expected_result_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD ins_expected_results(
   1 rows[*]
     2 expected_result_id = f8
     2 related_reagent_detail_id = f8
     2 nomenclature_id = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 prev_expected_result_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD new_ids(
   1 rows[*]
     2 id = f8
 ) WITH protect
 RECORD nomen_ids(
   1 rows[*]
     2 id = f8
 ) WITH protect
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF ( NOT (updaterelated_reagent(0)))
  GO TO exit_script
 ENDIF
 IF ( NOT (updaterelated_reagent_detail(0)))
  GO TO exit_script
 ENDIF
 IF ( NOT (updateexpected_results(0)))
  GO TO exit_script
 ENDIF
 IF ( NOT (transfernewids(0)))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 DECLARE updaterelated_reagent() = f8
 SUBROUTINE updaterelated_reagent(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE nenteredreport = i2 WITH protect, noconstant(0)
   DECLARE updcnterrorcnt = i2 WITH protect, noconstant(0)
   SET i = 0
   SET j = 0
   SET nstat = alterlist(new_ids->rows,0)
   FOR (i = 1 TO value(size(request->related_reagent_list,5)))
     IF ((request->related_reagent_list[j].save_flag=nbb_save_new))
      SET j = (j+ 1)
      IF (j > size(new_ids->rows,5))
       SET nstat = alterlist(new_ids->rows,(j+ 10))
      ENDIF
      SET new_ids->rows[j].id = getnextseq(0)
     ENDIF
   ENDFOR
   SET nstat = alterlist(new_ids->rows,j)
   SET i = 0
   SET j = 0
   SELECT INTO "nl:"
    FROM bb_qc_rel_reagent bbqcrr,
     (dummyt d  WITH seq = value(size(request->related_reagent_list,5)))
    PLAN (d)
     JOIN (bbqcrr
     WHERE (bbqcrr.related_reagent_id=request->related_reagent_list[d.seq].related_reagent_id)
      AND (((request->related_reagent_list[d.seq].save_flag=nbb_save_update)) OR ((request->
     related_reagent_list[d.seq].save_flag=nbb_save_delete))) )
    DETAIL
     i = (i+ 1)
     IF (i > size(upd_related_reagents->rows,5))
      nstat = alterlist(upd_related_reagents->rows,(i+ 10))
     ENDIF
     upd_related_reagents->rows[i].related_reagent_id = request->related_reagent_list[d.seq].
     related_reagent_id, upd_related_reagents->rows[i].reagent_cd = request->related_reagent_list[d
     .seq].reagent_cd, upd_related_reagents->rows[i].related_reagent_name = request->
     related_reagent_list[d.seq].related_reagent_name,
     upd_related_reagents->rows[i].active_ind = request->related_reagent_list[d.seq].active_ind
     IF ((request->related_reagent_list[d.seq].updt_cnt != bbqcrr.updt_cnt))
      nstat = populate_subeventstatus("SELECT","F","bb_qc_rel_reagent",build("related reagent id=",
        request->related_reagent_list[d.seq].related_reagent_id,"with update count=",request->
        related_reagent_list[d.seq].updt_cnt," has been updated.")), updcnterrorcnt = (updcnterrorcnt
      + 1)
     ENDIF
    WITH nocounter, forupdate(bbqcrr)
   ;end select
   SET nstat = alterlist(upd_related_reagents->rows,i)
   SET nstat = alterlist(ins_related_reagents->rows,0)
   IF (error_message(1))
    CALL populate_subeventstatus("SELECT","F","bb_qc_rel_reagent","Error locking rows for update.")
    RETURN(0)
   ENDIF
   IF (updcnterrorcnt > 0)
    CALL populate_subeventstatus("SELECT","F","bb_qc_rel_reagent",build(updcnterrorcnt,
      " related reagent(s) have been updated."))
    RETURN(0)
   ENDIF
   SET nenteredreport = 0
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d  WITH seq = value(size(request->related_reagent_list,5)))
    PLAN (d
     WHERE (request->related_reagent_list[d.seq].save_flag=nbb_save_new))
    HEAD REPORT
     i = size(ins_related_reagents->rows,5)
    DETAIL
     i = (i+ 1)
     IF (i > size(ins_related_reagents->rows,5))
      nstat = alterlist(ins_related_reagents->rows,(i+ 10))
     ENDIF
     nenteredreport = 1, j = (j+ 1), ins_related_reagents->rows[i].related_reagent_id = new_ids->
     rows[j].id,
     request->related_reagent_list[d.seq].related_reagent_id = ins_related_reagents->rows[i].
     related_reagent_id, ins_related_reagents->rows[i].reagent_cd = request->related_reagent_list[d
     .seq].reagent_cd, ins_related_reagents->rows[i].related_reagent_name = request->
     related_reagent_list[d.seq].related_reagent_name,
     ins_related_reagents->rows[i].active_ind = request->related_reagent_list[d.seq].active_ind,
     ins_related_reagents->rows[i].prev_active_ind = request->related_reagent_list[d.seq].active_ind,
     ins_related_reagents->rows[i].beg_effective_dt_tm = cnvtdatetime(nscript_date),
     ins_related_reagents->rows[i].end_effective_dt_tm = cnvtdatetime(nend_date)
    WITH nocounter
   ;end select
   IF (nenteredreport=1)
    SET nstat = alterlist(ins_related_reagents->rows,i)
   ELSE
    SET nstat = alterlist(ins_related_reagents->rows,0)
   ENDIF
   IF (size(upd_related_reagents->rows,5) > 0)
    UPDATE  FROM bb_qc_rel_reagent bbqcrr,
      (dummyt d  WITH seq = value(size(upd_related_reagents->rows,5)))
     SET bbqcrr.reagent_cd = upd_related_reagents->rows[d.seq].reagent_cd, bbqcrr
      .related_reagent_name = upd_related_reagents->rows[d.seq].related_reagent_name, bbqcrr
      .related_reagent_name_key = cnvtupper(upd_related_reagents->rows[d.seq].related_reagent_name),
      bbqcrr.active_ind = upd_related_reagents->rows[d.seq].active_ind, bbqcrr.updt_applctx = reqinfo
      ->updt_applctx, bbqcrr.updt_cnt = (bbqcrr.updt_cnt+ 1),
      bbqcrr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbqcrr.updt_id = reqinfo->updt_id, bbqcrr
      .updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bbqcrr
      WHERE (bbqcrr.related_reagent_id=upd_related_reagents->rows[d.seq].related_reagent_id))
     WITH nocounter
    ;end update
    IF (error_message(1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (size(ins_related_reagents->rows,5) > 0)
    INSERT  FROM bb_qc_rel_reagent bbqcrr,
      (dummyt d  WITH seq = value(size(ins_related_reagents->rows,5)))
     SET bbqcrr.related_reagent_id = ins_related_reagents->rows[d.seq].related_reagent_id, bbqcrr
      .reagent_cd = ins_related_reagents->rows[d.seq].reagent_cd, bbqcrr.related_reagent_name =
      ins_related_reagents->rows[d.seq].related_reagent_name,
      bbqcrr.related_reagent_name_key = cnvtupper(ins_related_reagents->rows[d.seq].
       related_reagent_name), bbqcrr.active_ind = ins_related_reagents->rows[d.seq].active_ind,
      bbqcrr.updt_applctx = reqinfo->updt_applctx,
      bbqcrr.updt_cnt = 0, bbqcrr.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbqcrr.updt_id =
      reqinfo->updt_id,
      bbqcrr.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bbqcrr)
     WITH nocounter
    ;end insert
    IF (error_message(1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (error_message(1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE updaterelated_reagent_detail() = f8
 SUBROUTINE updaterelated_reagent_detail(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE i1 = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE updcnterrorcnt = i2 WITH protect, noconstant(0)
   SET i = 0
   SET i1 = 0
   SET j = 0
   SET nstat = alterlist(new_ids->rows,0)
   FOR (i = 1 TO value(size(request->related_reagent_list,5)))
     FOR (i1 = 1 TO value(size(request->related_reagent_list[i].related_reagent_detail_list,5)))
       IF ( NOT ((request->related_reagent_list[i].related_reagent_detail_list[i1].save_flag=
       nbb_save_noupdate)))
        SET j = (j+ 1)
        IF (j > size(new_ids->rows,5))
         SET nstat = alterlist(new_ids->rows,(j+ 10))
        ENDIF
        SET new_ids->rows[j].id = getnextseq(0)
       ENDIF
     ENDFOR
   ENDFOR
   SET nstat = alterlist(new_ids->rows,j)
   SET i = 0
   SET j = 0
   SELECT INTO "nl:"
    FROM bb_qc_rel_reagent_detail bbqcrrd,
     (dummyt d1  WITH seq = value(size(request->related_reagent_list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(request->related_reagent_list[d1.seq].related_reagent_detail_list,5)))
     JOIN (d2)
     JOIN (bbqcrrd
     WHERE (bbqcrrd.related_reagent_detail_id=request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].related_reagent_detail_id)
      AND (((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].save_flag=
     nbb_save_update)) OR ((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq]
     .save_flag=nbb_save_delete))) )
    DETAIL
     i = (i+ 1)
     IF (i > size(upd_related_reagent_detail->rows,5))
      nstat = alterlist(upd_related_reagent_detail->rows,(i+ 10)), nstat = alterlist(
       ins_related_reagent_detail->rows,(i+ 10))
     ENDIF
     upd_related_reagent_detail->rows[i].related_reagent_detail_id = request->related_reagent_list[d1
     .seq].related_reagent_detail_list[d2.seq].related_reagent_detail_id, j = (j+ 1),
     ins_related_reagent_detail->rows[i].related_reagent_detail_id = new_ids->rows[j].id,
     upd_related_reagent_detail->rows[i].related_reagent_id = request->related_reagent_list[d1.seq].
     related_reagent_id, ins_related_reagent_detail->rows[i].related_reagent_id = bbqcrrd
     .related_reagent_id, upd_related_reagent_detail->rows[i].enhancement_cd = request->
     related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].enhancement_cd,
     ins_related_reagent_detail->rows[i].enhancement_cd = bbqcrrd.enhancement_cd,
     upd_related_reagent_detail->rows[i].control_cd = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].control_cd, ins_related_reagent_detail->rows[i].control_cd
      = bbqcrrd.control_cd,
     upd_related_reagent_detail->rows[i].phase_cd = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].phase_cd, ins_related_reagent_detail->rows[i].phase_cd =
     bbqcrrd.phase_cd, upd_related_reagent_detail->rows[i].prev_related_reagent_detail_id = request->
     related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].related_reagent_detail_id,
     ins_related_reagent_detail->rows[i].prev_related_reagent_detail_id = request->
     related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].related_reagent_detail_id,
     upd_related_reagent_detail->rows[i].active_ind = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].active_ind, ins_related_reagent_detail->rows[i].active_ind
      = bbqcrrd.active_ind,
     upd_related_reagent_detail->rows[i].beg_effective_dt_tm = cnvtdatetime(nscript_date),
     ins_related_reagent_detail->rows[i].beg_effective_dt_tm = bbqcrrd.beg_effective_dt_tm,
     ins_related_reagent_detail->rows[i].end_effective_dt_tm = cnvtdatetime(nscript_date)
     IF ((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].save_flag=
     nbb_save_update))
      upd_related_reagent_detail->rows[i].end_effective_dt_tm = cnvtdatetime(nend_date)
     ELSE
      upd_related_reagent_detail->rows[i].end_effective_dt_tm = cnvtdatetime(nscript_date)
     ENDIF
     IF ((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].updt_cnt !=
     bbqcrrd.updt_cnt))
      nstat = populate_subeventstatus("SELECT","F","RELATED_REAGENT_DETAIL",build(
        "related reagent detail id=",request->related_reagent_list[d1.seq].
        related_reagent_detail_list[d2.seq].related_reagent_detail_id,"with update count=",request->
        related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].updt_cnt,
        " has been updated.")), updcnterrorcnt = (updcnterrorcnt+ 1)
     ENDIF
    WITH nocounter, forupdate(bbqcrrd)
   ;end select
   SET nstat = alterlist(upd_related_reagent_detail->rows,i)
   SET nstat = alterlist(ins_related_reagent_detail->rows,i)
   IF (error_message(1))
    CALL populate_subeventstatus("SELECT","F","RELATED_REAGENT_DETAIL",
     "Error locking rows for update.")
    RETURN(0)
   ENDIF
   IF (updcnterrorcnt > 0)
    CALL populate_subeventstatus("SELECT","F","RELATED_REAGENT_DETAIL",build(updcnterrorcnt,
      " reagent detail(s) have been updated."))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d1  WITH seq = value(size(request->related_reagent_list,5))),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(request->related_reagent_list[d1.seq].related_reagent_detail_list,5)))
     JOIN (d2
     WHERE (request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].save_flag=
     nbb_save_new))
    HEAD REPORT
     i = size(ins_related_reagent_detail->rows,5)
    DETAIL
     i = (i+ 1)
     IF (i > size(ins_related_reagent_detail->rows,5))
      nstat = alterlist(ins_related_reagent_detail->rows,(i+ 10))
     ENDIF
     j = (j+ 1), ins_related_reagent_detail->rows[i].related_reagent_detail_id = new_ids->rows[j].id,
     request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     related_reagent_detail_id = ins_related_reagent_detail->rows[i].related_reagent_detail_id,
     ins_related_reagent_detail->rows[i].related_reagent_id = request->related_reagent_list[d1.seq].
     related_reagent_id, ins_related_reagent_detail->rows[i].enhancement_cd = request->
     related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].enhancement_cd,
     ins_related_reagent_detail->rows[i].control_cd = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].control_cd,
     ins_related_reagent_detail->rows[i].phase_cd = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].phase_cd, ins_related_reagent_detail->rows[i].
     prev_related_reagent_detail_id = ins_related_reagent_detail->rows[i].related_reagent_detail_id,
     ins_related_reagent_detail->rows[i].active_ind = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].active_ind,
     ins_related_reagent_detail->rows[i].beg_effective_dt_tm = cnvtdatetime(nscript_date),
     ins_related_reagent_detail->rows[i].end_effective_dt_tm = cnvtdatetime(nend_date)
    WITH nocounter
   ;end select
   SET nstat = alterlist(ins_related_reagent_detail->rows,i)
   IF (size(upd_related_reagent_detail->rows,5) > 0)
    UPDATE  FROM bb_qc_rel_reagent_detail bbqcrrd,
      (dummyt d  WITH seq = value(size(upd_related_reagent_detail->rows,5)))
     SET bbqcrrd.related_reagent_id = upd_related_reagent_detail->rows[d.seq].related_reagent_id,
      bbqcrrd.enhancement_cd = upd_related_reagent_detail->rows[d.seq].enhancement_cd, bbqcrrd
      .control_cd = upd_related_reagent_detail->rows[d.seq].control_cd,
      bbqcrrd.phase_cd = upd_related_reagent_detail->rows[d.seq].phase_cd, bbqcrrd
      .prev_related_reagent_detail_id = upd_related_reagent_detail->rows[d.seq].
      prev_related_reagent_detail_id, bbqcrrd.active_ind = upd_related_reagent_detail->rows[d.seq].
      active_ind,
      bbqcrrd.beg_effective_dt_tm = cnvtdatetime(upd_related_reagent_detail->rows[d.seq].
       beg_effective_dt_tm), bbqcrrd.end_effective_dt_tm = cnvtdatetime(upd_related_reagent_detail->
       rows[d.seq].end_effective_dt_tm), bbqcrrd.updt_applctx = reqinfo->updt_applctx,
      bbqcrrd.updt_cnt = (bbqcrrd.updt_cnt+ 1), bbqcrrd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bbqcrrd.updt_id = reqinfo->updt_id,
      bbqcrrd.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bbqcrrd
      WHERE (bbqcrrd.related_reagent_detail_id=upd_related_reagent_detail->rows[d.seq].
      related_reagent_detail_id))
     WITH nocounter
    ;end update
    IF (error_message(1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (size(ins_related_reagent_detail->rows,5) > 0)
    INSERT  FROM bb_qc_rel_reagent_detail bbqcrrd,
      (dummyt d  WITH seq = value(size(ins_related_reagent_detail->rows,5)))
     SET bbqcrrd.related_reagent_detail_id = ins_related_reagent_detail->rows[d.seq].
      related_reagent_detail_id, bbqcrrd.enhancement_cd = ins_related_reagent_detail->rows[d.seq].
      enhancement_cd, bbqcrrd.related_reagent_id = ins_related_reagent_detail->rows[d.seq].
      related_reagent_id,
      bbqcrrd.control_cd = ins_related_reagent_detail->rows[d.seq].control_cd, bbqcrrd.phase_cd =
      ins_related_reagent_detail->rows[d.seq].phase_cd, bbqcrrd.prev_related_reagent_detail_id =
      ins_related_reagent_detail->rows[d.seq].prev_related_reagent_detail_id,
      bbqcrrd.active_ind = ins_related_reagent_detail->rows[d.seq].active_ind, bbqcrrd
      .beg_effective_dt_tm = cnvtdatetime(ins_related_reagent_detail->rows[d.seq].beg_effective_dt_tm
       ), bbqcrrd.end_effective_dt_tm = cnvtdatetime(ins_related_reagent_detail->rows[d.seq].
       end_effective_dt_tm),
      bbqcrrd.updt_applctx = reqinfo->updt_applctx, bbqcrrd.updt_cnt = 0, bbqcrrd.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      bbqcrrd.updt_id = reqinfo->updt_id, bbqcrrd.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bbqcrrd)
     WITH nocounter
    ;end insert
    IF (error_message(1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE updateexpected_results() = f8
 SUBROUTINE updateexpected_results(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE i1 = i4 WITH protect, noconstant(0)
   DECLARE i2 = i4 WITH protect, noconstant(0)
   DECLARE updcnterrorcnt = i2 WITH protect, noconstant(0)
   SET nstat = alterlist(new_ids->rows,0)
   FOR (i = 1 TO value(size(request->related_reagent_list,5)))
     FOR (i1 = 1 TO value(size(request->related_reagent_list[i].related_reagent_detail_list,5)))
       FOR (i2 = 1 TO value(size(request->related_reagent_list[i].related_reagent_detail_list[i1].
         expected_result_list,5)))
         IF ( NOT ((request->related_reagent_list[i].related_reagent_detail_list[i1].
         expected_result_list[i2].save_flag=nbb_save_noupdate)))
          SET j = (j+ 1)
          IF (j > size(new_ids->rows,5))
           SET nstat = alterlist(new_ids->rows,(j+ 10))
          ENDIF
          SET new_ids->rows[j].id = getnextseq(0)
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   SET nstat = alterlist(new_ids->rows,j)
   SET i = 0
   SET j = 0
   SELECT INTO "nl:"
    FROM bb_qc_expected_result_r bbqcer,
     (dummyt d1  WITH seq = value(size(request->related_reagent_list,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(request->related_reagent_list[d1.seq].related_reagent_detail_list,5)))
     JOIN (d2
     WHERE maxrec(d3,size(request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
       expected_result_list,5)))
     JOIN (d3
     WHERE (((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     expected_result_list[d3.seq].save_flag=nbb_save_update)) OR ((request->related_reagent_list[d1
     .seq].related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].save_flag=nbb_save_delete
     ))) )
     JOIN (bbqcer
     WHERE (bbqcer.expected_result_id=request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].expected_result_id))
    DETAIL
     i = (i+ 1)
     IF (i > size(upd_expected_results->rows,5))
      nstat = alterlist(upd_expected_results->rows,(i+ 10)), nstat = alterlist(ins_expected_results->
       rows,(i+ 10))
     ENDIF
     upd_expected_results->rows[i].expected_result_id = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].expected_result_id, j = (j+ 1),
     ins_expected_results->rows[i].expected_result_id = new_ids->rows[j].id,
     upd_expected_results->rows[i].related_reagent_detail_id = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].related_reagent_detail_id, ins_expected_results->rows[i].
     related_reagent_detail_id = bbqcer.related_reagent_detail_id, upd_expected_results->rows[i].
     nomenclature_id = request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     expected_result_list[d3.seq].nomenclature_id,
     ins_expected_results->rows[i].nomenclature_id = bbqcer.nomenclature_id, upd_expected_results->
     rows[i].prev_expected_result_id = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].expected_result_id,
     ins_expected_results->rows[i].prev_expected_result_id = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].expected_result_id,
     upd_expected_results->rows[i].active_ind = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].active_ind,
     ins_expected_results->rows[i].active_ind = bbqcer.active_ind, upd_expected_results->rows[i].
     beg_effective_dt_tm = cnvtdatetime(nscript_date),
     ins_expected_results->rows[i].beg_effective_dt_tm = bbqcer.beg_effective_dt_tm,
     ins_expected_results->rows[i].end_effective_dt_tm = cnvtdatetime(nscript_date)
     IF ((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     expected_result_list[d3.seq].save_flag=nbb_save_update))
      upd_expected_results->rows[i].end_effective_dt_tm = cnvtdatetime(nend_date)
     ELSE
      upd_expected_results->rows[i].end_effective_dt_tm = cnvtdatetime(nscript_date)
     ENDIF
     IF ((request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     expected_result_list[d3.seq].updt_cnt != bbqcer.updt_cnt))
      nstat = populate_subeventstatus("SELECT","F","expected_result",build("expected result id=",
        request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
        expected_result_list[d3.seq].expected_result_id," with update count=",request->
        related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].expected_result_list[d3.seq]
        .updt_cnt," has been updated.")), updcnterrorcnt = (updcnterrorcnt+ 1)
     ENDIF
    WITH nocounter, forupdate(bbqcer)
   ;end select
   SET nstat = alterlist(upd_expected_results->rows,i)
   SET nstat = alterlist(ins_expected_results->rows,i)
   IF (error_message(1))
    CALL populate_subeventstatus("SELECT","F","expected_result","Error locking rows for update.")
    RETURN(0)
   ENDIF
   IF (updcnterrorcnt > 0)
    CALL populate_subeventstatus("SELECT","F","expected_result",build(updcnterrorcnt,
      " expected result(s) have been updated."))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    d.seq
    FROM (dummyt d1  WITH seq = value(size(request->related_reagent_list,5))),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(request->related_reagent_list[d1.seq].related_reagent_detail_list,5)))
     JOIN (d2
     WHERE maxrec(d3,size(request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
       expected_result_list,5)))
     JOIN (d3
     WHERE (request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     expected_result_list[d3.seq].save_flag=nbb_save_new))
    HEAD REPORT
     i = size(ins_expected_results->rows,5)
    DETAIL
     i = (i+ 1)
     IF (i > size(ins_expected_results->rows,5))
      nstat = alterlist(ins_expected_results->rows,(i+ 10))
     ENDIF
     j = (j+ 1), ins_expected_results->rows[i].expected_result_id = new_ids->rows[j].id, request->
     related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].
     expected_result_id = new_ids->rows[j].id,
     ins_expected_results->rows[i].related_reagent_detail_id = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].related_reagent_detail_id, ins_expected_results->rows[i].
     nomenclature_id = request->related_reagent_list[d1.seq].related_reagent_detail_list[d2.seq].
     expected_result_list[d3.seq].nomenclature_id, ins_expected_results->rows[i].
     prev_expected_result_id = ins_expected_results->rows[i].expected_result_id,
     ins_expected_results->rows[i].active_ind = request->related_reagent_list[d1.seq].
     related_reagent_detail_list[d2.seq].expected_result_list[d3.seq].active_ind,
     ins_expected_results->rows[i].beg_effective_dt_tm = cnvtdatetime(nscript_date),
     ins_expected_results->rows[i].end_effective_dt_tm = cnvtdatetime(nend_date)
    WITH nocounter
   ;end select
   SET nstat = alterlist(ins_expected_results->rows,i)
   IF (size(upd_expected_results->rows,5) > 0)
    UPDATE  FROM bb_qc_expected_result_r bbqcer,
      (dummyt d  WITH seq = value(size(upd_expected_results->rows,5)))
     SET bbqcer.related_reagent_detail_id = upd_expected_results->rows[d.seq].
      related_reagent_detail_id, bbqcer.nomenclature_id = upd_expected_results->rows[d.seq].
      nomenclature_id, bbqcer.prev_expected_result_id = upd_expected_results->rows[d.seq].
      prev_expected_result_id,
      bbqcer.active_ind = upd_expected_results->rows[d.seq].active_ind, bbqcer.beg_effective_dt_tm =
      cnvtdatetime(upd_expected_results->rows[d.seq].beg_effective_dt_tm), bbqcer.end_effective_dt_tm
       = cnvtdatetime(upd_expected_results->rows[d.seq].end_effective_dt_tm),
      bbqcer.updt_applctx = reqinfo->updt_applctx, bbqcer.updt_cnt = (bbqcer.updt_cnt+ 1), bbqcer
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      bbqcer.updt_id = reqinfo->updt_id, bbqcer.updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bbqcer
      WHERE (bbqcer.expected_result_id=upd_expected_results->rows[d.seq].expected_result_id))
     WITH nocounter
    ;end update
    IF (error_message(1))
     RETURN(0)
    ENDIF
   ENDIF
   IF (size(ins_expected_results->rows,5) > 0)
    INSERT  FROM bb_qc_expected_result_r bbqcer,
      (dummyt d  WITH seq = value(size(ins_expected_results->rows,5)))
     SET bbqcer.expected_result_id = ins_expected_results->rows[d.seq].expected_result_id, bbqcer
      .related_reagent_detail_id = ins_expected_results->rows[d.seq].related_reagent_detail_id,
      bbqcer.nomenclature_id = ins_expected_results->rows[d.seq].nomenclature_id,
      bbqcer.prev_expected_result_id = ins_expected_results->rows[d.seq].prev_expected_result_id,
      bbqcer.active_ind = ins_expected_results->rows[d.seq].active_ind, bbqcer.beg_effective_dt_tm =
      cnvtdatetime(ins_expected_results->rows[d.seq].beg_effective_dt_tm),
      bbqcer.end_effective_dt_tm = cnvtdatetime(ins_expected_results->rows[d.seq].end_effective_dt_tm
       ), bbqcer.updt_applctx = reqinfo->updt_applctx, bbqcer.updt_cnt = 0,
      bbqcer.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbqcer.updt_id = reqinfo->updt_id, bbqcer
      .updt_task = reqinfo->updt_task
     PLAN (d)
      JOIN (bbqcer)
     WITH nocounter
    ;end insert
    IF (error_message(1))
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE getnextseq() = f8
 SUBROUTINE getnextseq(null)
   DECLARE dnextseq = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    temp_seq = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     dnextseq = temp_seq
    WITH nocounter
   ;end select
   RETURN(dnextseq)
 END ;Subroutine
 DECLARE transfernewids() = f8
 SUBROUTINE transfernewids(null)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   DECLARE k = i4 WITH protect, noconstant(0)
   DECLARE nstat = i2 WITH protect, noconstant(0)
   SET nstat = alterlist(reply->related_reagent_list,size(request->related_reagent_list,5))
   FOR (i = 1 TO size(request->related_reagent_list,5))
     SET reply->related_reagent_list[i].id = request->related_reagent_list[i].related_reagent_id
     SET nstat = alterlist(reply->related_reagent_list[i].related_reagent_detail_list,size(request->
       related_reagent_list[i].related_reagent_detail_list,5))
     FOR (j = 1 TO size(request->related_reagent_list[i].related_reagent_detail_list,5))
       SET reply->related_reagent_list[i].related_reagent_detail_list[j].id = request->
       related_reagent_list[i].related_reagent_detail_list[j].related_reagent_detail_id
       SET nstat = alterlist(reply->related_reagent_list[i].related_reagent_detail_list[j].
        expected_result_list,size(request->related_reagent_list[i].related_reagent_detail_list[j].
         expected_result_list,5))
       FOR (k = 1 TO size(request->related_reagent_list[i].related_reagent_detail_list[j].
        expected_result_list,5))
         SET reply->related_reagent_list[i].related_reagent_detail_list[j].expected_result_list[k].id
          = request->related_reagent_list[i].related_reagent_detail_list[j].expected_result_list[k].
         expected_result_id
       ENDFOR
     ENDFOR
   ENDFOR
   IF (error_message(1))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD ins_related_reagents
 FREE RECORD upd_related_reagents
 FREE RECORD ins_related_reagent_detail
 FREE RECORD upd_related_reagent_detail
 FREE RECORD ins_expected_results
 FREE RECORD upd_expected_results
 FREE RECORD new_ids
END GO
