CREATE PROGRAM ccl_prompt_get_folder
 PROMPT
  "folder :" = "*",
  "folder names?" = "folder"
  WITH foldername, rettype
 DECLARE dirname = vc
 RECORD files(
   1 folders[*]
     2 name = vc
 )
 IF (cnvtlower( $RETTYPE)="folder")
  CALL getfoldernames(cnvtupper( $FOLDERNAME))
 ELSE
  CALL getfilenames(cnvtupper( $FOLDERNAME))
 ENDIF
 RETURN
 SUBROUTINE getfoldernames(foldername)
   IF (foldername != "/")
    SET dirname = concat(foldername,"/*")
    SET len = (size(foldername)+ 1)
    SET adj = 0
   ELSE
    SET dirname = "/*"
    SET len = (size(foldername)+ 1)
    SET adj = 1
   ENDIF
   SELECT DISTINCT INTO "nl:"
    pfolder.folder_name
    FROM ccl_prompt_file pfolder
    WHERE cnvtupper(pfolder.folder_name)=patstring(dirname)
    ORDER BY pfolder.folder_name
    HEAD REPORT
     folders = 0
    HEAD pfolder.folder_name
     present = 0, name = substring((len - adj),((findstring("/",pfolder.folder_name,(len+ 1)) - len)
      + adj),pfolder.folder_name)
     FOR (i = 1 TO folders)
       IF ((files->folders[i].name=name))
        present = 1
       ENDIF
     ENDFOR
     IF (present=0)
      folders = (folders+ 1), x = alterlist(files->folders,folders), files->folders[folders].name =
      name
     ENDIF
    WITH nocounter
   ;end select
   CALL echorecord(files)
   SELECT INTO "NL:"
    folder_name = files->folders[d.seq].name
    FROM (dummyt d  WITH seq = value(size(files->folders,5)))
    HEAD REPORT
     delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
     stat = alterlist(reply->data,delta)
    DETAIL
     count = (count+ 1)
     IF (mod(count,delta)=1)
      stat = alterlist(reply->data,(count+ delta))
     ENDIF
     reply->data[count].buffer = concat(reportinfo(2),"$")
    FOOT REPORT
     stat = alterlist(reply->data,count)
    WITH maxrow = 1, reporthelp, check
   ;end select
 END ;Subroutine
 SUBROUTINE getfilenames(foldername)
  SET dirname = concat(foldername,"/")
  SELECT INTO "nl:"
   pfolder.file_name
   FROM ccl_prompt_file pfolder
   WHERE cnvtupper(pfolder.folder_name)=patstring(dirname)
   ORDER BY pfolder.folder_name, pfolder.file_name
   HEAD REPORT
    delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
    stat = alterlist(reply->data,delta)
   DETAIL
    count = (count+ 1)
    IF (mod(count,delta)=1)
     stat = alterlist(reply->data,(count+ delta))
    ENDIF
    reply->data[count].buffer = concat(reportinfo(2),"$")
   FOOT REPORT
    stat = alterlist(reply->data,count)
   WITH maxrow = 1, reporthelp, check
  ;end select
 END ;Subroutine
END GO
