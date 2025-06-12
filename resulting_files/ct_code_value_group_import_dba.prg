CREATE PROGRAM ct_code_value_group_import:dba
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE parent_set = i2 WITH protect, noconstant(0)
 DECLARE parent_cd = f8 WITH protect, noconstant(0.0)
 DECLARE child_set = i2 WITH protect, noconstant(0)
 DECLARE child_cd = f8 WITH protect, noconstant(0.0)
 SET reqinfo->updt_applctx = 1
 SET reqinfo->updt_task = 1
 SET reqinfo->commit_ind = 1
 SET cnt = size(requestin->list_0,5)
 CALL echo(concat("Rows Received:",cnvtstring(cnt)))
 SET x = 1
 FOR (x = x TO cnt)
   SET parent_set = 0
   SET parent_set = cnvtint(requestin->list_0[x].parent_code_set)
   SET parent_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=parent_set
     AND (cv.display=requestin->list_0[x].parent_display)
    DETAIL
     parent_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (parent_cd=0.0)
    GO TO end_prg
   ENDIF
   SET child_set = 0
   SET child_set = cnvtint(requestin->list_0[x].child_code_set)
   SET child_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=child_set
     AND (cv.display=requestin->list_0[x].child_display)
    DETAIL
     child_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (child_cd=0.0)
    GO TO end_prg
   ENDIF
   SELECT INTO "NL:"
    cvg.*
    FROM code_value_group cvg
    WHERE cvg.parent_code_value=parent_cd
     AND cvg.child_code_value=child_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    INSERT  FROM code_value_group
     SET parent_code_value = parent_cd, child_code_value = child_cd, updt_applctx = 0,
      updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 0, updt_cnt = 0,
      updt_task = 0, collation_seq = 0, code_set = child_set
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM code_value_group
     SET updt_applctx = 0, updt_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00"), updt_id = 0,
      updt_cnt = 0, updt_task = 0, collation_seq = 0,
      code_set = child_set
     WHERE parent_code_value=parent_cd
      AND child_code_value=child_cd
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
 COMMIT
#end_prg
END GO
