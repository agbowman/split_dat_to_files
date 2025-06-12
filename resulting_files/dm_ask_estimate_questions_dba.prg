CREATE PROGRAM dm_ask_estimate_questions:dba
 PAINT
 CALL video(r)
 CALL clear(1,1)
 CALL video(w)
 CALL text(2,1,"DM Environment DB Sizing Questions",w)
 CALL box(3,1,23,132)
 SET dm_env_name = fillstring(20," ")
 SET dm_env_desc = fillstring(60," ")
 SET dm_env_name = cnvtupper( $1)
 SET dm_env_id = 0.0
 SET dm_schema_date = cnvtdatetime("31-DEC-1900")
 SELECT INTO "nl:"
  e.environment_id, e.description
  FROM dm_environment e
  WHERE e.environment_name=dm_env_name
  DETAIL
   dm_env_id = e.environment_id, dm_env_desc = e.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO end_program
 ELSE
  SELECT INTO "nl:"
   sv.schema_date
   FROM dm_schema_version sv,
    dm_environment e
   WHERE e.environment_name=dm_env_name
    AND sv.schema_version=e.schema_version
   DETAIL
    dm_schema_date = sv.schema_date
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO end_program
  ENDIF
 ENDIF
 CALL text(04,03,concat("Env Name: ",dm_env_name,"     Desc: ",dm_env_desc))
 FREE SET request
 RECORD request(
   1 question_number = i4
   1 environment_id = f8
   1 question_answer = i4
 )
 SET question_list[1] = fillstring(100," ")
 SET question_number[1] = 0
 SET kount = 0
 SELECT DISTINCT INTO "nl:"
  dq.question_number, dq.description
  FROM dm_question dq,
   dm_table_dependency tdp,
   dm_tables t,
   dm_tables_doc td,
   dm_function_dm_section_r f,
   dm_env_functions ef,
   dm_environment e
  WHERE e.environment_name=dm_env_name
   AND ef.environment_id=e.environment_id
   AND f.function_id=ef.function_id
   AND td.data_model_section=f.data_model_section
   AND t.table_name=td.table_name
   AND t.schema_date=cnvtdatetime(dm_schema_date)
   AND tdp.table_name=t.table_name
   AND tdp.dependency_flg=1
   AND dq.question_number=cnvtint(tdp.dependency)
  ORDER BY dq.question_number
  DETAIL
   kount = (kount+ 1), stat = memrealloc(question_list,kount,"c100"), stat = memrealloc(
    question_number,kount,"i4"),
   question_list[kount] = dq.description, question_number[kount] = dq.question_number
  WITH nocounter
 ;end select
 FOR (count = 1 TO kount)
   CALL text(6,10,concat("Question: ",cnvtstring(count)))
   CALL text(8,10,question_list[count])
   CALL text(10,10,"Answer:   ")
   CALL accept(10,20,"999999999")
   SET request->question_answer = curaccept
   SET request->question_number = question_number[count]
   SET request->environment_id = dm_env_id
   EXECUTE dm_answer_estimate_question
 ENDFOR
 COMMIT
END GO
