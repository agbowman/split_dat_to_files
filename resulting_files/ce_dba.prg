CREATE PROGRAM ce:dba
 SELECT INTO mine
  c.*
  FROM clinical_event c
  WHERE (c.person_id= $1)
  WITH nocounter
 ;end select
END GO
