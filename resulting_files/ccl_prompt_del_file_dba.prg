CREATE PROGRAM ccl_prompt_del_file:dba
 PROMPT
  "folder name " = "",
  "file name " = ""
  WITH foldername, filename
 IF (( $FOLDERNAME != "/"))
  SET dirname = concat( $FOLDERNAME,"/")
 ELSE
  SET dirname = "/"
 ENDIF
 CALL echo(concat("delete ", $FOLDERNAME))
 CALL echo(concat("=> ", $FILENAME))
 DELETE  FROM ccl_prompt_file pfolder
  WHERE cnvtupper(pfolder.folder_name)=cnvtupper(dirname)
   AND cnvtupper(pfolder.file_name)=cnvtupper( $FILENAME)
  WITH nocounter
 ;end delete
 COMMIT
END GO
