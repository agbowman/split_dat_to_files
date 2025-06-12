CREATE PROGRAM e:dba
 SELECT INTO mine
  e.*
  FROM encounter e
  WHERE (e.encntr_id= $1)
  WITH nocounter
 ;end select
END GO
