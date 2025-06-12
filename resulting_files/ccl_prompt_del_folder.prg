CREATE PROGRAM ccl_prompt_del_folder
 PROMPT
  "folder name " = ""
  WITH foldername
 IF (( $FOLDERNAME != "/"))
  SET dirname = concat(cnvtupper( $FOLDERNAME),"/*")
  SET len = (size( $FOLDERNAME)+ 1)
  SET adj = 0
 ELSE
  SET dirname = "/*"
  SET len = (size( $FOLDERNAME)+ 1)
  SET adj = 1
 ENDIF
 CALL echo(concat("delete folder: ",dirname))
 DELETE  FROM ccl_prompt_file pfolder
  WHERE cnvtupper(pfolder.folder_name)=patstring(dirname)
  WITH nocounter
 ;end delete
 COMMIT
END GO
