CREATE PROGRAM ed:dba
 SELECT INTO mine
  ed.*
  FROM encntr_domain ed
  WHERE (ed.encntr_id= $1)
  WITH nocounter
 ;end select
END GO
