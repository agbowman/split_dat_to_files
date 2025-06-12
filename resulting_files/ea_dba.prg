CREATE PROGRAM ea:dba
 SET fin_nbr = cnvtint( $1)
 SET fin_str = cnvtstring(fin_nbr)
 SELECT
  *
  FROM encntr_alias ea1,
   encounter e
  PLAN (ea1
   WHERE ea1.alias=fin_str)
   JOIN (e
   WHERE e.encntr_id=ea1.encntr_id)
  WITH nocounter
 ;end select
END GO
