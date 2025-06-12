CREATE PROGRAM ct_stratum_susp_a_c_func:dba
 CALL echo("pre create of record S")
 RECORD stratum_susp_a_c_func_s(
   1 curdatetime = dq8
   1 susp_id = f8
   1 prot_stratum_susp_id = f8
   1 stratum_id = f8
   1 reason_cd = f8
   1 comment_txt = vc
   1 susp_effective_dt_tm = dq8
   1 susp_end_dt_tm = dq8
   1 updt_cnt = i4
 )
 CALL echo("pre initialization of variables")
 SET false = 0
 SET true = 1
 SET stratum_susp_a_c_func_doupdate = false
 SET stratum_susp_a_c_func_suspid = 0.0
 SET stratum_susp_a_c_func_protstratumsuspid = 0.0
 SET reply->statusfunc = "F"
 SET stratum_susp_a_c_func_s_id = 0.0
 SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
 suspstatus = "F"
 SET stratum_susp_a_c_func_doupdate = false
 IF ((request->ss[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
 prot_stratum_susp_id=0.0))
  CALL echo("this is a new suspension so get a number for both prot_stratum_susp_id and susp_id")
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    stratum_susp_a_c_func_protstratumsuspid = cnvtreal(num)
   WITH format, counter
  ;end select
  SET stratum_susp_a_c_func_doupdate = true
  SET stratum_susp_a_c_func_suspid = stratum_susp_a_c_func_protstratumsuspid
  SET stratum_susp_a_c_func_s->curdatetime = cnvtdatetime(curdate,curtime3)
  SET stratum_susp_a_c_func_s_id = request->ss[stratum_susp_a_c_func_ssindex].stratum_id
 ELSE
  CALL echo(build("locking the prot_stratum_susp row for update"))
  SELECT INTO "nl:"
   susp.*
   FROM prot_stratum_susp susp
   WHERE (susp.prot_stratum_susp_id=request->ss[stratum_susp_a_c_func_ssindex].susps[
   stratum_susp_a_c_func_suspsindex].prot_stratum_susp_id)
   DETAIL
    stratum_susp_a_c_func_s->curdatetime = cnvtdatetime(curdate,curtime3), stratum_susp_a_c_func_s_id
     = susp.stratum_id, stratum_susp_a_c_func_suspid = susp.susp_id,
    stratum_susp_a_c_func_s->reason_cd = susp.reason_cd, stratum_susp_a_c_func_s->comment_txt = susp
    .comment_txt, stratum_susp_a_c_func_s->susp_effective_dt_tm = susp.susp_effective_dt_tm,
    stratum_susp_a_c_func_s->susp_end_dt_tm = susp.susp_end_dt_tm, stratum_susp_a_c_func_s->updt_cnt
     = susp.updt_cnt
   WITH nocounter, forupdate(susp)
  ;end select
  IF (curqual=1)
   CALL echo(build("successfully locked stratum suspension row to update ; curqual = ",curqual))
   IF ((stratum_susp_a_c_func_s->updt_cnt != request->ss[stratum_susp_a_c_func_ssindex].susps[
   stratum_susp_a_c_func_suspsindex].updt_cnt))
    SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
    suspstatus = "C"
   ELSE
    SET stratum_susp_a_c_func_doupdate = false
    IF ((request->ss[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].reason_cd
     != stratum_susp_a_c_func_s->reason_cd))
     SET stratum_susp_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
    comment_txt != stratum_susp_a_c_func_s->comment_txt))
     SET stratum_susp_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
    susp_effective_dt_tm != stratum_susp_a_c_func_s->susp_effective_dt_tm))
     SET stratum_susp_a_c_func_doupdate = true
    ENDIF
    IF ((request->ss[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
    susp_end_dt_tm != stratum_susp_a_c_func_s->susp_end_dt_tm))
     SET stratum_susp_a_c_func_doupdate = true
    ENDIF
    IF (stratum_susp_a_c_func_doupdate=true)
     CALL echo("the stratum suspension data passed in IS different from what exist in the data base "
      )
     SET stratum_susp_a_c_func_doupdate = false
     UPDATE  FROM prot_stratum_susp susp
      SET susp.end_effective_dt_tm = cnvtdatetime(stratum_susp_a_c_func_s->curdatetime), susp
       .updt_cnt = (susp.updt_cnt+ 1), susp.updt_applctx = reqinfo->updt_applctx,
       susp.updt_task = reqinfo->updt_task, susp.updt_id = reqinfo->updt_id, susp.updt_dt_tm =
       cnvtdatetime(curdate,curtime3)
      WHERE (susp.prot_stratum_susp_id=request->ss[stratum_susp_a_c_func_ssindex].susps[
      stratum_susp_a_c_func_suspsindex].prot_stratum_susp_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
      suspstatus = "F"
      SET stratum_susp_a_c_func_doupdate = false
     ELSE
      CALL echo("get number for the prot_stratum_susp_id")
      SELECT INTO "nl:"
       num = seq(protocol_def_seq,nextval)"########################;rpO"
       FROM dual
       DETAIL
        stratum_susp_a_c_func_protstratumsuspid = cnvtreal(num)
       WITH format, counter
      ;end select
      SET stratum_susp_a_c_func_doupdate = true
     ENDIF
    ELSE
     CALL echo(
      "the stratum suspension data passed in IS *NOT* different from what exist in the data base ")
     SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
     suspstatus = "S"
    ENDIF
   ENDIF
  ELSE
   CALL echo("failed to lock stratum row for update")
   SET stratum_susp_a_c_func_doupdate = false
   SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
   suspstatus = "L"
  ENDIF
 ENDIF
 IF (stratum_susp_a_c_func_doupdate=true)
  CALL echo("STRATUM_SUSP_A_C_FUNC_DoUpdate = TRUE")
  INSERT  FROM prot_stratum_susp susp
   SET susp.susp_id = stratum_susp_a_c_func_suspid, susp.prot_stratum_susp_id =
    stratum_susp_a_c_func_protstratumsuspid, susp.stratum_id = stratum_susp_a_c_func_s_id,
    susp.reason_cd = request->ss[stratum_susp_a_c_func_ssindex].susps[
    stratum_susp_a_c_func_suspsindex].reason_cd, susp.comment_txt = request->ss[
    stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].comment_txt, susp
    .susp_effective_dt_tm = cnvtdatetime(request->ss[stratum_susp_a_c_func_ssindex].susps[
     stratum_susp_a_c_func_suspsindex].susp_effective_dt_tm),
    susp.susp_end_dt_tm = cnvtdatetime(request->ss[stratum_susp_a_c_func_ssindex].susps[
     stratum_susp_a_c_func_suspsindex].susp_end_dt_tm), susp.beg_effective_dt_tm = cnvtdatetime(
     stratum_susp_a_c_func_s->curdatetime), susp.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"),
    susp.updt_cnt = 0, susp.updt_applctx = reqinfo->updt_applctx, susp.updt_task = reqinfo->updt_task,
    susp.updt_id = reqinfo->updt_id, susp.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
  IF (curqual=1)
   CALL echo("successfully inserted row into stratum suspension table")
   SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
   suspstatus = "S"
  ELSE
   CALL echo("failed to insert row into stratum suspension table")
   SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
   suspstatus = "F"
  ENDIF
 ELSE
  SET reply->a_c_results[stratum_susp_a_c_func_ssindex].susps[stratum_susp_a_c_func_suspsindex].
  suspstatus = "S"
 ENDIF
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
