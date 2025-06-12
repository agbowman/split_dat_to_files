CREATE PROGRAM ccl_prompt_add_folder:dba
 PROMPT
  "folder name " = "",
  "file name   " = ""
  WITH foldername, filename
 DECLARE fn = vc
 DECLARE nseq = i4
 IF (( $FOLDERNAME != "/"))
  SET fn = concat( $FOLDERNAME,"/", $FILENAME,"/")
 ELSE
  SET fn = concat( $FOLDERNAME, $FILENAME,"/")
 ENDIF
 INSERT  FROM ccl_prompt_file
  SET folder_name = fn, file_name = ".", updt_dt_tm = cnvtdatetime(curdate,curtime3),
   updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task, updt_cnt = 0,
   updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 COMMIT
END GO
