CREATE PROGRAM cdf:dba
 SELECT INTO mine
  a.*
  FROM common_data_foundation a
  PLAN (a
   WHERE (a.code_set= $1))
  WITH nocounter, format(date,";;q")
 ;end select
END GO
