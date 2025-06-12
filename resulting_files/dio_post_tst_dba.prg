CREATE PROGRAM dio_post_tst:dba
 SELECT INTO dio_postscript_test
  x = 0
  FROM dummyt
  DETAIL
   "{pos/72/72}{lpi/6}{cpi/8}{FONT/31/3}*M:Z*{f/1/1}"
  WITH dio = 8, maxrow = 30, maxcol = 132
 ;end select
END GO
