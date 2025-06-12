CREATE PROGRAM bed_ext_br_of_depts:dba
 SELECT INTO "CER_INSTALL:br_of_depts.csv"
  FROM br_of_depts b
  ORDER BY b.of_dept_name
  HEAD REPORT
   "of_dept_name"
  DETAIL
   name = concat('"',trim(b.of_dept_name),'"'), row + 1, name
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
