CREATE PROGRAM chep:dba
 PROMPT
  "PERSON_ID  " = 0
 SELECT
  *
  FROM charge_event
  WHERE (person_id= $1)
  ORDER BY updt_dt_tm DESC
 ;end select
END GO
