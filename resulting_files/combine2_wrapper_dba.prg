CREATE PROGRAM combine2_wrapper:dba
 SET trace = rdbdebug
 SET trace = rdbbind
 SET trace = echoprogall
 CALL echo("...")
 CALL echo("combine2_wrapper")
 CALL echo("...")
 DECLARE exe_stmt = vc
 SET exe_stmt = build2("execute dm_combine2 with replace('DM_TABLE_RELATIONSHIPS',",
  mock_table_relationships,",3), "," replace('DM_CMB_EXCEPTION',",mock_table_exception,
  ",3) go")
 CALL parser(exe_stmt)
 SET trace = nordbdebug
 SET trace = nordbbind
 SET trace = noechoprogall
END GO
