CREATE PROGRAM cvsa:dba
 SELECT INTO mine
  c.*
  FROM code_value c
  WHERE (c.code_set= $1)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND c.end_effective_dt_tm >= cnvtdatetime(sysdate)
  WITH nocounter
 ;end select
END GO
