CREATE PROGRAM ccloraver:dba
 PROMPT
  "Enter output name : " = "MINE"
 SELECT INTO  $1
  ora_version = v.banner, ora_directory =
  IF (cursys="AXP") logical("ORA_ROOT")
  ELSE logical("ORACLE_HOME")
  ENDIF
  FROM v$version v
  WITH nocounter
 ;end select
END GO
