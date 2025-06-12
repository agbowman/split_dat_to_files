CREATE PROGRAM dm_dba_files:dba
 FREE SET list_files
 RECORD list_files(
   1 files[*]
     2 file_name = c30
     2 tablespace_name = c30
     2 bytes = f8
     2 file_type = c5
     2 size_seq = f8
   1 file_count = i4
 )
 SET env_id = 545
 SET list_files->file_count = 0
 SELECT INTO "nl:"
  a.file_name, a.bytes, a.tablespace_name
  FROM dba_data_files a
  ORDER BY a.file_name
  DETAIL
   list_files->file_count = (list_files->file_count+ 1)
   IF (mod(list_files->file_count,10)=1)
    stat = alterlist(list_files->files,(list_files->file_count+ 9))
   ENDIF
   list_files->files[list_files->file_count].file_name = a.file_name, list_files->files[list_files->
   file_count].bytes = a.bytes, list_files->files[list_files->file_count].tablespace_name = a
   .tablespace_name
   IF (substring(1,1,a.tablespace_name)="D")
    list_files->files[list_files->file_count].file_type = "DATA"
   ELSEIF (substring(1,1,a.tablespace_name)="I")
    list_files->files[list_files->file_count].file_type = "INDEX"
   ENDIF
  WITH nocounter
 ;end select
 FOR (count = 1 TO list_files->file_count)
   INSERT  FROM dm_env_files def
    SET def.updt_applctx = 0, def.updt_dt_tm = cnvtdatetime(curdate,curtime3), def.updt_cnt = 0,
     def.updt_id = 0, def.updt_task = 0, def.file_type = list_files->files[count].file_type,
     def.file_size = list_files->files[count].bytes, def.size_sequence = 0, def.environment_id =
     env_id,
     def.tablespace_name = list_files->files[count].tablespace_name, def.file_name = list_files->
     files[count].file_name
    WITH nocounter
   ;end insert
 ENDFOR
END GO
