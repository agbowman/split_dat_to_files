CREATE PROGRAM dm_tspace_size_comp:dba
 FREE SET both_list
 RECORD both_list(
   1 tname[*]
     2 tspacename = c32
     2 dfile_size = f8
     2 efile_size = f8
     2 diff = f8
   1 tcount = i4
 )
 SET both_list->tcount = 0
 SET mbyte = (1024.0 * 1024.0)
 SELECT INTO "nl:"
  ddf.tablespace_name, z = sum((ddf.bytes/ (1024 * 1024)))
  FROM dba_data_files ddf
  WHERE ((ddf.tablespace_name="D_*") OR (ddf.tablespace_name="I_*"))
  GROUP BY ddf.tablespace_name
  DETAIL
   both_list->tcount = (both_list->tcount+ 1)
   IF (mod(both_list->tcount,10)=1)
    stat = alterlist(both_list->tname,(both_list->tcount+ 9))
   ENDIF
   both_list->tname[both_list->tcount].tspacename = ddf.tablespace_name, both_list->tname[both_list->
   tcount].dfile_size = z, both_list->tname[both_list->tcount].efile_size = 0,
   both_list->tname[both_list->tcount].diff = z
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  def.tablespace_name, def.file_size
  FROM dm_env_files def,
   (dummyt d  WITH seq = value(both_list->tcount))
  PLAN (d)
   JOIN (def
   WHERE (def.tablespace_name=both_list->tname[d.seq].tspacename)
    AND (def.environment_id= $1))
  ORDER BY def.tablespace_name
  HEAD def.tablespace_name
   tspace_size = 0.0
  DETAIL
   tspace_size = (tspace_size+ def.file_size)
  FOOT  def.tablespace_name
   both_list->tname[d.seq].efile_size = (tspace_size/ mbyte), both_list->tname[d.seq].diff = abs((
    both_list->tname[d.seq].efile_size - both_list->tname[d.seq].dfile_size))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  def.tablespace_name, b = sum((def.file_size/ (1024 * 1024)))
  FROM dm_env_files def
  WHERE  NOT (def.tablespace_name IN (
  (SELECT
   ddf.tablespace_name
   FROM dba_data_files ddf)))
   AND (def.environment_id= $1)
  GROUP BY def.tablespace_name
  DETAIL
   both_list->tcount = (both_list->tcount+ 1)
   IF (mod(both_list->tcount,10)=1)
    stat = alterlist(both_list->tname,(both_list->tcount+ 9))
   ENDIF
   both_list->tname[both_list->tcount].tspacename = def.tablespace_name, both_list->tname[both_list->
   tcount].efile_size = b, both_list->tname[both_list->tcount].dfile_size = 0,
   both_list->tname[both_list->tcount].diff = b
  WITH nocounter
 ;end select
 SELECT
  d.seq
  FROM (dummyt d  WITH seq = value(both_list->tcount))
  ORDER BY both_list->tname[d.seq].diff DESC
  HEAD REPORT
   z = 0, line_d = fillstring(120,"="),
   MACRO (col_heads)
    col 0, "Tablespace", col 50,
    "Actual", col 80, "Calculate",
    col 110, " Diff"
   ENDMACRO
   ,
   row 0,
   CALL center("***FILE SIZE REPORT***",0,120), col 0,
   "Report Date: ", curdate"MM/DD/YY;;D", col 100,
   "Report Time: ", curtime"HH:MM;;M", row + 1,
   line_d, row + 2
  HEAD PAGE
   col 0, "PAGE: ", col 7,
   curpage"###;L", row + 1, col_heads,
   row + 1, line_d, row + 1
  DETAIL
   z = both_list->tname[d.seq].diff, col 0, both_list->tname[d.seq].tspacename,
   col 43, both_list->tname[d.seq].dfile_size, col 73,
   both_list->tname[d.seq].efile_size, col 103, z,
   row + 1
  WITH maxrec = 500
 ;end select
END GO
