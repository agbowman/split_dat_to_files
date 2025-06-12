CREATE PROGRAM cv_utl_sql_func_declare:dba
 SELECT INTO "cclsource:cv_omf_functions.inc"
  *
  FROM omf_function o
  DETAIL
   "declare ", o.function_name, "()=",
   o.return_dtype, "go", row + 1
  WITH nocounter, format = variable, noformfeed,
   maxrow = 1
 ;end select
END GO
