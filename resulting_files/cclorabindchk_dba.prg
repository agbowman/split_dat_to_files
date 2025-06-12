CREATE PROGRAM cclorabindchk:dba
 PROMPT
  "Output name : " = "MINE"
 SELECT DISTINCT INTO  $1
  datatype, max_length, x = fillstring(100," ")
  FROM v$sql_bind_metadata
  WITH nocounter, format = variable
 ;end select
 SELECT INTO  $1
  count(*), cnvtrawhex(a.kglhdpar), b.sql_text
  FROM v$sql_shared_cursor a,
   v$sqltext b
  WHERE a.bind_mismatch="Y"
   AND b.address=a.kglhdpar
   AND b.piece=0
  GROUP BY a.kglhdpar, b.sql_text
  HAVING count(*) >= 2
  ORDER BY 1
  WITH nocounter, append, format = variable
 ;end select
 SELECT INTO  $1
  cnvtrawhex(address), sql_text
  FROM v$sqltext
  WHERE piece=0
   AND address IN (
  (SELECT
   kglhdpar
   FROM v$sql_shared_cursor
   WHERE bind_mismatch="Y"))
  WITH nocounter, append, format = variable
 ;end select
 SELECT INTO  $1
  cnvtrawhex(address), cnvtrawhex(kglhdpar), bind_mismatch,
  sql_type_mismatch, unbound_cursor, misc_mismatch = concat(optimizer_mismatch,outline_mismatch,
   stats_row_mismatch,literal_mismatch,sec_depth_mismatch,
   explain_plan_cursor,buffered_dml_mismatch,pdml_env_mismatch,inst_drtld_mismatch,slave_qc_mismatch,
   typecheck_mismatch,auth_check_mismatch,describe_mismatch,language_mismatch,translation_mismatch,
   row_level_sec_mismatch,insuff_privs,insuff_privs_rem,remote_trans_mismatch,sql_redirect_mismatch,
   mv_query_gen_mismatch)
  FROM v$sql_shared_cursor
  WHERE bind_mismatch="Y"
  WITH nocounter, append, format = variable
 ;end select
END GO
