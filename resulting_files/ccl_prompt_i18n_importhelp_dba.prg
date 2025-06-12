CREATE PROGRAM ccl_prompt_i18n_importhelp:dba
 PROMPT
  "Path to RTF File:" = "",
  "Prompt Program Name:" = ""
  WITH rtf_filename, program_name
 DECLARE uar_fopen(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fopen",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fopen"
 DECLARE uar_fread(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "decc$shr", uar_axp = "decc$fread", image_aix = "libc.a(shr.o)",
 uar_aix = "fread"
 DECLARE uar_ferror(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$ferror",
 image_aix = "libc.a(shr.o)",
 uar_aix = "ferror"
 DECLARE uar_fclose(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fclose",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fclose"
 DECLARE insertfile(folder=vc,filename=vc,content=vc(ref)) = null
 DECLARE deletefile(folder=vc,filename=vc) = null
 DECLARE filerows(folder=vc,filename=vc) = i2
 DECLARE rtfhandle = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE errno = i4
 DECLARE rtfdata = vc
 DECLARE block_size = i2 WITH constant(2000)
 SET rtfhandle = uar_fopen( $RTF_FILENAME,"rb")
 SET stat = findstring(":", $RTF_FILENAME)
 IF (rtfhandle=0
  AND stat > 0)
  CASE (cursys)
   OF "AXP":
    SET dirsep = ""
   OF "AIX":
    SET dirsep = "/"
   OF "WIN":
    SET dirsep = "\"
  ENDCASE
  SET file_name = build(logical(substring(1,(stat - 1), $RTF_FILENAME)),dirsep,substring((stat+ 1),(
    size( $RTF_FILENAME,1) - stat), $RTF_FILENAME))
  SET rtfhandle = uar_fopen(nullterm(file_name),"rb")
 ENDIF
 IF (rtfhandle=0)
  GO TO exit_now
 ENDIF
 SET stat = 1
 DECLARE line = c16000
 WHILE (stat > 0)
   SET stat = uar_fread(line,1,16000,rtfhandle)
   SET errno = uar_ferror(rtfhandle)
   IF (errno > 0)
    GO TO exit_now
   ENDIF
   SET rtfdata = concat(rtfdata,substring(1,stat,line))
 ENDWHILE
 SET foldername = "/PDDOC/GROUP0/"
 IF (filerows(foldername, $PROGRAM_NAME) > 0)
  CALL deletefile(foldername, $PROGRAM_NAME)
 ENDIF
 CALL insertfile(foldername, $PROGRAM_NAME,rtfdata)
 SUBROUTINE insertfile(folder,filename,content)
   DECLARE blockstr = vc
   DECLARE blocks = i2
   DECLARE pchar = i4
   DECLARE len = i4
   DECLARE i = i2
   SET i2 = 0
   SET pchar = 1
   SET len = size(content,1)
   SET folder = cnvtupper(folder)
   SET filename = cnvtupper(filename)
   IF (len > 0)
    WHILE (pchar <= len)
      SET blockstr = notrim(substring(pchar,block_size,content))
      SET pchar = (pchar+ block_size)
      INSERT  FROM ccl_prompt_file pf
       SET pf.folder_name = folder, pf.file_name = filename, pf.collation_seq = i,
        pf.content = notrim(blockstr), pf.updt_dt_tm = cnvtdatetime(curdate,curtime3), pf.updt_id =
        reqinfo->updt_id,
        pf.updt_task = reqinfo->updt_task, pf.updt_cnt = 0, pf.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET i = (i+ 1)
    ENDWHILE
   ENDIF
   COMMIT
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
 SUBROUTINE filerows(folder,filename)
   DECLARE rowcount = i2 WITH noconstant(0)
   SET folder = cnvtupper(folder)
   SET filename = cnvtupper(filename)
   SELECT INTO "nl:"
    rtotal = count(*)
    FROM ccl_prompt_file pf
    WHERE cnvtupper(pf.folder_name)=folder
     AND cnvtupper(pf.file_name)=filename
    DETAIL
     rowcount = rtotal
    WITH nocounter
   ;end select
   RETURN(rowcount)
 END ;Subroutine
#exit_now
END GO
