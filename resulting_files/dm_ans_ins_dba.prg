CREATE PROGRAM dm_ans_ins:dba
 EXECUTE dm_dbimport "cer_install:dm_cb_answers.csv", "dm_cb_answers_load", 1000
END GO
