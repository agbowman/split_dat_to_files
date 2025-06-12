CREATE PROGRAM bbd_imp_dependency:dba
 SET max_list = size(requestin->list_0,5)
 SET x = 1
 SET cur_question_cd = 0.0
 SET cur_depend_cd = 0.0
 SET cur_module_cd = 0.0
 SET cur_process_cd = 0.0
 SET cur_response_cd = 0.0
#start_loop_dependency
 SET x = 1
 FOR (x = x TO size(requestin->list_0,5))
   SET code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=1661
     AND (c.cdf_meaning=requestin->list_0[x].question_mean)
     AND c.active_ind=1
    DETAIL
     code_value = c.code_value
    WITH nocounter
   ;end select
   SET cur_question_cd = code_value
   SET code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=1661
     AND (c.cdf_meaning=requestin->list_0[x].depend_quest_mean)
     AND c.active_ind=1
    DETAIL
     code_value = c.code_value
    WITH nocounter
   ;end select
   SET cur_depend_cd = code_value
   SET code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=1660
     AND (c.cdf_meaning=requestin->list_0[x].module_mean)
     AND c.active_ind=1
    DETAIL
     code_value = c.code_value
    WITH nocounter
   ;end select
   SET cur_module_cd = code_value
   SET code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=1662
     AND (c.cdf_meaning=requestin->list_0[x].process_mean)
     AND c.active_ind=1
    DETAIL
     code_value = c.code_value
    WITH nocounter
   ;end select
   SET cur_process_cd = code_value
   SET code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=cnvtint(requestin->list_0[x].response_code_set)
     AND (c.cdf_meaning=requestin->list_0[x].response_mean)
     AND c.active_ind=1
    DETAIL
     code_value = c.code_value
    WITH nocounter
   ;end select
   SET cur_response_cd = code_value
   IF (cur_question_cd > 0
    AND cur_depend_cd > 0
    AND cur_module_cd > 0
    AND cur_process_cd > 0
    AND cur_response_cd > 0)
    SELECT INTO "NL:"
     d.question_cd
     FROM dependency d
     WHERE d.question_cd=cur_question_cd
      AND d.depend_quest_cd=cur_depend_cd
      AND d.module_cd=cur_module_cd
      AND d.process_cd=cur_process_cd
      AND d.response_cd=cur_response_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     INSERT  FROM dependency d
      SET d.question_cd = cur_question_cd, d.depend_quest_cd = cur_depend_cd, d.module_cd =
       cur_module_cd,
       d.process_cd = cur_process_cd, d.response_cd = cur_response_cd, d.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       d.updt_id = 1, d.updt_task = 1, d.updt_cnt = 0,
       d.updt_applctx = 1
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
#exit_script
END GO
