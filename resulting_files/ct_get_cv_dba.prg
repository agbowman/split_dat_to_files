CREATE PROGRAM ct_get_cv:dba
 CALL echo("START -- CT GET CV FUNCTION")
 SET trace = error
 SET stat = uar_get_meaning_by_codeset(cset,cmean,1,cval)
 CALL echo("END -- CT GET CV FUNCTION")
END GO
