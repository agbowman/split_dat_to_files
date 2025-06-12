CREATE PROGRAM ccl_prompt_put_file:dba
 DECLARE fileexist(filename=vc) = i2
 DECLARE deletefile(filename=vc) = null
 DECLARE insertfile(filename=vc) = null
 DECLARE block_size = i2 WITH constant(2000)
 IF (validate(reply,"N")="N")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE filename = vc
 DECLARE foldername = vc
 SET reply->status_data.status = "F"
 SET foldername = trim(request->folder_name)
 IF (foldername != "/")
  SET foldername = concat(foldername,"/")
 ENDIF
 CALL deletefile(foldername,request->file_name)
 IF ((request->active_ind=1))
  CALL insertfile(foldername,request->file_name)
 ENDIF
 COMMIT
 SUBROUTINE insertfile(folder,filename)
   DECLARE content = vc
   DECLARE blocks = i2
   DECLARE pchar = i4
   DECLARE len = i4
   DECLARE i = i2
   SET i2 = 0
   SET pchar = 1
   SET len = size(request->content,1)
   IF (len > 0)
    WHILE (pchar <= len)
      SET content = notrim(substring(pchar,block_size,request->content))
      SET pchar = (pchar+ block_size)
      INSERT  FROM ccl_prompt_file pf
       SET pf.folder_name = folder, pf.file_name = filename, pf.collation_seq = i,
        pf.content = notrim(content), pf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pf.updt_id =
        reqinfo->updt_id,
        pf.updt_task = reqinfo->updt_task, pf.updt_cnt = 0, pf.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET i = (i+ 1)
    ENDWHILE
   ENDIF
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE deletefile(folder,filename)
   SET folder = cnvtupper(folder)
   SET filename = cnvtupper(filename)
   DELETE  FROM ccl_prompt_file pf
    WHERE cnvtupper(pf.folder_name)=folder
     AND cnvtupper(pf.file_name)=filename
    WITH nocounter
   ;end delete
   COMMIT
 END ;Subroutine
 SUBROUTINE fileexist(folder,filename)
   DECLARE bexist = i2 WITH noconstant(0)
   SET folder = cnvtupper(folder)
   SET filename = cnvtupper(filename)
   SELECT INTO "nl:"
    count(*)
    FROM ccl_prompt_file
    WHERE cnvtupper(folder_name)=folder
     AND cnvtupper(file_name)=filename
    DETAIL
     bexist = 1
    WITH nocounter
   ;end select
   RETURN(bexist)
 END ;Subroutine
END GO
