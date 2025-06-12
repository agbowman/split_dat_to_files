CREATE PROGRAM ccloralogin:dba
 PROMPT
  "Rdbms Login : " = " "
 FREE DEFINE oraclesystem
 DEFINE oraclesystem trim( $1)
END GO
