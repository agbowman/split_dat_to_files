CREATE PROGRAM dm_ques_ins:dba
 EXECUTE dm_dbimport "cer_install:dm_cb_questions.csv", "dm_cb_questions_load", 1000
END GO
