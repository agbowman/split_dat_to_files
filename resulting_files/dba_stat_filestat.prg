CREATE PROGRAM dba_stat_filestat
 SELECT
  df.file_name, fs.phywrts, fs.phyrds,
  df.tablespace_name
  FROM dba_data_files df,
   v$filestat fs
  WHERE sqlpassthru("df.file_id = fs.file#")
  ORDER BY (fs.phyrds+ fs.phywrts) DESC
  HEAD REPORT
   col 10, "Disk I/O Statistics", row + 2,
   col 0, "Physical Reads", col 20,
   "Physical Writes", col 40, "Tablespace",
   col 65, "File Name", row + 1
  DETAIL
   col 0, fs.phyrds, col 21,
   fs.phywrts, col 40, df.tablespace_name,
   col 65, df.file_name, row + 1
  WITH maxcol = 512
 ;end select
END GO
