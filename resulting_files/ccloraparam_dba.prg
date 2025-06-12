CREATE PROGRAM ccloraparam:dba
 PROMPT
  "Enter output name : " = "MINE",
  "Parameter Name    : " = "*"
 SELECT INTO  $1
  name = substring(1,40,v.name), value = substring(1,40,v.value), v.isdefault,
  v.description
  FROM v$parameter v
  WHERE (v.name= $2)
  ORDER BY name
  WITH nocounter
 ;end select
END GO
