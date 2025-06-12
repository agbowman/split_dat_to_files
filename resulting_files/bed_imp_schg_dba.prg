CREATE PROGRAM bed_imp_schg:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE title_txt = vc
 IF (audit_mode=0)
  SET title_txt = "Scheduling Guideline Import"
 ELSE
  SET title_txt = "Scheduling Guideline Import Audit Mode"
 ENDIF
 SET logfilename = "CCLUSERDIR:bed_imp_schg.log"
 SELECT INTO value(logfilename)
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, title_txt, row + 2,
   col 2, "GUIDELINE", col 50,
   "STATUS", row + 1
  WITH nocounter
 ;end select
 DECLARE temp_status = vc
 SET reply->status_data.status = "F"
 SET req_cnt = 0
 SET req_cnt = size(requestin->list_0,5)
 SET add_cnt = 0
 SET update_cnt = 0
 SET error_cnt = 0
 SET active_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_code_value = c.code_value
  WITH nocounter
 ;end select
 SET cs15149_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=15149
    AND c.cdf_meaning="GUIDELINE")
  DETAIL
   cs15149_code_value = c.code_value
  WITH nocounter
 ;end select
 SET cs15589_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=15589
    AND c.cdf_meaning="GUIDELINE")
  DETAIL
   cs15589_code_value = c.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_cnt)
   SET skip_ind = 0
   SET error_ind = 0
   SET len = 0
   SET len = textlen(requestin->list_0[x].name)
   IF ((requestin->list_0[x].name IN ("", " ", null)))
    SET temp_status = "NOLOG"
    SET skip_ind = 1
   ELSEIF (len > 40)
    SET temp_status = "ERROR: Name field is > 40 characters."
    SET skip_ind = 1
   ENDIF
   IF ((requestin->list_0[x].text IN ("", " ", null)))
    SET temp_status = "ERROR: Text field not defined."
    SET skip_ind = 1
   ENDIF
   IF (skip_ind=0)
    SET updt_ind = 0
    SET long_text = 0.0
    SET template = 0.0
    SELECT INTO "nl:"
     FROM sch_template s
     PLAN (s
      WHERE cnvtupper(s.mnemonic)=trim(cnvtupper(requestin->list_0[x].name))
       AND s.text_type_cd=cs15149_code_value
       AND s.sub_text_cd=cs15589_code_value)
     DETAIL
      updt_ind = 1, long_text = s.text_id, template = s.template_id
     WITH nocounter
    ;end select
    IF (audit_mode=1)
     IF (updt_ind=1)
      SET temp_status = "Updated"
     ELSE
      SET temp_status = "Added"
     ENDIF
    ELSE
     IF (updt_ind=1)
      SET temp_status = "Updated"
      UPDATE  FROM sch_template s
       SET s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_applctx = reqinfo->updt_applctx, s
        .updt_id = reqinfo->updt_id,
        s.updt_cnt = (s.updt_cnt+ 1), s.updt_task = reqinfo->updt_task
       WHERE s.template_id=template
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET temp_status = "Error when updating sch_template table."
       SET error_ind = 1
      ENDIF
      IF (error_ind=0)
       UPDATE  FROM long_text_reference l
        SET l.long_text = requestin->list_0[x].text, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l
         .updt_applctx = reqinfo->updt_applctx,
         l.updt_id = reqinfo->updt_id, l.updt_cnt = (l.updt_cnt+ 1), l.updt_task = reqinfo->updt_task
        WHERE l.long_text_id=long_text
         AND l.long_text_id > 0
       ;end update
       IF (curqual=0)
        SET temp_status = "Error when updating long_text_reference table."
       ENDIF
      ENDIF
     ELSE
      SET temp_status = "Added"
      SET new_template = 0.0
      SELECT INTO "nl:"
       j = seq(sched_reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_template = cnvtreal(j)
       WITH format, counter
      ;end select
      IF (new_template=0)
       SET temp_status = "Error when retrieving next template_id."
       SET error_ind = 1
      ENDIF
      SET new_candidate = 0.0
      SELECT INTO "nl:"
       j = seq(sch_candidate_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_candidate = cnvtreal(j)
       WITH format, counter
      ;end select
      IF (new_candidate=0)
       SET temp_status = "Error when retrieving next candidate_id."
       SET error_ind = 1
      ENDIF
      SET new_long_text = 0.0
      SELECT INTO "nl:"
       j = seq(long_data_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_long_text = cnvtreal(j)
       WITH format, counter
      ;end select
      IF (new_long_text=0)
       SET temp_status = "Error when retrieving next long_text_id."
       SET error_ind = 1
      ENDIF
      IF (error_ind=0)
       INSERT  FROM sch_template s
        SET s.template_id = new_template, s.version_dt_tm = cnvtdatetime("31-DEC-2100"), s.mnemonic
          = trim(substring(1,40,requestin->list_0[x].name)),
         s.mnemonic_key = trim(cnvtupper(cnvtalphanum(substring(1,40,requestin->list_0[x].name)))), s
         .description = trim(substring(1,40,requestin->list_0[x].name)), s.text_type_cd =
         cs15149_code_value,
         s.text_type_meaning = "GUIDELINE", s.info_sch_text_id = 0, s.text_id = new_long_text,
         s.template_ind = 0, s.null_dt_tm = cnvtdatetime("31-DEC-2100"), s.beg_effective_dt_tm =
         cnvtdatetime(curdate,curtime3),
         s.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), s.active_ind = 1, s.active_status_cd =
         active_code_value,
         s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.active_status_prsnl_id = reqinfo->
         updt_id, s.updt_dt_tm = cnvtdatetime(curdate,curtime),
         s.updt_applctx = reqinfo->updt_applctx, s.updt_id = reqinfo->updt_id, s.updt_cnt = 0,
         s.updt_task = reqinfo->updt_task, s.candidate_id = new_candidate, s.sub_text_cd =
         cs15589_code_value,
         s.sub_text_meaning = "GUIDELINE", s.mnemonic_key_nls = null
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET temp_status = "Error when inserting into sch_template table."
        SET error_ind = 1
       ENDIF
      ENDIF
      IF (error_ind=0)
       INSERT  FROM long_text_reference l
        SET l.long_text_id = new_long_text, l.updt_dt_tm = cnvtdatetime(curdate,curtime), l
         .updt_applctx = reqinfo->updt_applctx,
         l.updt_id = reqinfo->updt_id, l.updt_cnt = 0, l.updt_task = reqinfo->updt_task,
         l.active_ind = 1, l.active_status_cd = active_code_value, l.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         l.active_status_prsnl_id = reqinfo->updt_id, l.parent_entity_name = "SCH_TEMPLATE", l
         .parent_entity_id = new_template,
         l.long_text = requestin->list_0[x].text
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET temp_status = "Error when inserting into long_text_reference table."
        SET error_ind = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (temp_status != "NOLOG")
    SELECT INTO value(logfilename)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col 2, requestin->list_0[x].name, col 50,
      temp_status, row + 1
     WITH nocounter, append
    ;end select
   ENDIF
   IF (temp_status="Added")
    SET add_cnt = (add_cnt+ 1)
   ELSEIF (temp_status="Updated")
    SET update_cnt = (update_cnt+ 1)
   ELSEIF (temp_status != "NOLOG")
    SET error_cnt = (error_cnt+ 1)
   ENDIF
 ENDFOR
 SELECT INTO value(logfilename)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row + 2, col 1, "Total Number of Guidelines Added:",
   add_cnt"####", row + 1, col 1,
   "Total Number of Guidelines Updated:", update_cnt"####", row + 1,
   col 1, "Total Number of Guidelines Not Added/Updated:", error_cnt"####",
   row + 2, curdate"dd-mmm-yyyy;;d", "-",
   curtime"hh:mm;;m", col + 1, title_txt,
   col + 1, "Finished"
  WITH nocounter, append
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET echo_txt = concat("==  LOG FILE CREATED IN ",logfilename)
 CALL echorecord(reply)
 CALL echo("==========================================================")
 CALL echo(echo_txt)
 CALL echo("==========================================================")
END GO
