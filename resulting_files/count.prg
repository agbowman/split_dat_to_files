CREATE PROGRAM count
 SELECT
  a.table_name, a.row_cnt, b.table_name,
  b.row_cnt, diff = (b.row_cnt - a.row_cnt)
  FROM count1 a,
   count2 b
  WHERE a.table_name=b.table_name
  ORDER BY diff DESC
  HEAD REPORT
   col 0, "Table Name", col 35,
   "count before", col 55, "count after",
   col 70, "difference", row + 3
  DETAIL
   col 0, a.table_name, col 35,
   a.row_cnt, col 55, b.row_cnt,
   col 70, diff, row + 1
 ;end select
END GO
