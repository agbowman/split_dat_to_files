CREATE PROGRAM dm_upd_ccl_rec_len:dba
 UPDATE  FROM dfile d
  SET d.max_reclen = 55000
  WHERE d.file_name="V500"
   AND d.max_reclen != 55000
 ;end update
END GO
