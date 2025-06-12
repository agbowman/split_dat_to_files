CREATE PROGRAM ccl_prompt_chg_folder:dba
 PROMPT
  "old name " = "",
  "new name " = ""
  WITH oldname, newname
 DECLARE dirname = vc
 RECORD files(
   1 list[*]
     2 oldname = vc
     2 newname = vc
 )
 IF (( $OLDNAME != "/"))
  SET dirname = concat(cnvtupper( $OLDNAME),"/*")
  SET len = (size( $OLDNAME)+ 1)
  SET adj = 0
 ELSE
  SET dirname = "/*"
  SET len = (size( $OLDNAME)+ 1)
  SET adj = 1
 ENDIF
 SELECT INTO "nl:"
  folder_name
  FROM ccl_prompt_file pfolder
  WHERE cnvtupper(pfolder.folder_name)=patstring(dirname)
  ORDER BY pfolder.folder_name, pfolder.file_name
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), x = alterlist(files->list,count), files->list[count].oldname = cnvtupper(
    pfolder.folder_name),
   files->list[count].newname = concat( $NEWNAME,substring(len,(size(pfolder.folder_name) - len),
     pfolder.folder_name))
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(files->list,5))
   UPDATE  FROM ccl_prompt_file
    SET folder_name = files->list[i].newname
    WHERE (folder_name=files->list[i].oldname)
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
END GO
