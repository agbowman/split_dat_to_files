CREATE PROGRAM ccl_prompt_batchimport
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE readbatchlisting(dummy=i2) = null
 DECLARE readfromlisting(dummy=i2) = null
 DECLARE importform(strimport=vc) = null
 DECLARE validateinstallation(tblname=vc) = i2
 DECLARE readmanifest(batchfilename=vc) = null
 DECLARE batchfilename = vc
 DECLARE strdir = vc WITH constant("CER_INSTALL"), protect
 DECLARE strname = vc WITH protect
 DECLARE strimport = vc WITH protect
 DECLARE ln = i2 WITH protect
 DECLARE nproctype = i2 WITH protect
 DECLARE errorcount = i2 WITH public, noconstant(0)
 DECLARE revinstall = i1 WITH public, noconstant(0)
 DECLARE errorflag = i1 WITH public, noconstant(0)
 DECLARE errormsg = vc WITH public
 RECORD batchfile(
   1 lines[*]
     2 line = vc
 )
 FREE RECORD install_list
 RECORD install_list(
   1 qual[*]
     2 importfile = vc
 )
 SET readme_data->status = "F"
 SET errorcount = 0
 IF (validateinstallation("CCL_PROMPT_DEFINITIONS") != 1)
  SET readme_data->status = "S"
  SET readme_data->message = "Discern Prompt Library not installed.  Import not ran."
  EXECUTE dm_readme_status
  RETURN
 ENDIF
 CALL readbatchlisting(0)
 CALL importfromlisting(0)
 IF (errorcount > 0)
  SET readme_data->message = substring(1,255,concat("completed with ",trim(cnvtstring(errorcount)),
    " errors: ",trim(readme_data->message)))
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message = "import completed with no errors."
  SET readme_data->status = "S"
 ENDIF
 EXECUTE dm_readme_status
 RETURN
 SUBROUTINE readbatchlisting(dummy)
  DECLARE batchfilename = vc WITH private
  IF ((readme_data->data_file > " "))
   SET batchfilename = readme_data->data_file
   SET revinstall = 1
   CALL readmanifest(batchfilename)
  ELSE
   IF ((readme_data->ocd > 0))
    SET batchfilename = concat("dpl_import_pck",trim(cnvtstring(readme_data->ocd)),".txt")
    CALL readmanifest(batchfilename)
   ELSEIF ((readme_data->ocd < 0))
    SELECT INTO "nl:"
     dor.ocd
     FROM dm_ocd_readme dor,
      dm_install_plan dip
     WHERE dip.install_plan_id=abs(readme_data->ocd)
      AND dip.package_number=dor.ocd
      AND (dor.readme_id=readme_data->readme_id)
     ORDER BY dor.ocd
     HEAD REPORT
      stat = alterlist(install_list->qual,100), pkg_cnt = 0
     DETAIL
      pkg_cnt = (pkg_cnt+ 1)
      IF (mod(pkg_cnt,100)=1
       AND pkg_cnt != 1)
       stat = alterlist(install_list->qual,(pkg_cnt+ 99))
      ENDIF
      batchfilename = concat("dpl_import_pck",trim(cnvtstring(dor.ocd)),".txt"), install_list->qual[
      pkg_cnt].importfile = batchfilename
     FOOT REPORT
      stat = alterlist(install_list->qual,pkg_cnt)
     WITH nocounter
    ;end select
    FOR (r = 1 TO size(install_list_qual,5))
      CALL readmanifest(batchfilename)
    ENDFOR
   ELSE
    SET readme_data->message = "Package Number is not filled out.  Readme will Fail"
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE readmanifest(batchfilename)
   IF (cursys="AXP")
    SET strname = concat(trim(logical(strdir)),cnvtlower(trim(batchfilename)))
   ELSE
    SET strname = concat(trim(logical(strdir)),"/",cnvtlower(trim(batchfilename)))
   ENDIF
   SET logical infile strname
   CALL echo(concat("batch import from ",strname))
   IF (findfile("inFile")=0)
    CALL echo(concat("File '",strname,"' not found. Batch import aborted."))
    IF (revinstall)
     SET readme_data->message = concat("File '",strname,"' not found. Batch import aborted.")
    ELSE
     SET readme_data->message = concat("No form batch list found for this package.")
    ENDIF
    RETURN
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 "inFile"
   SELECT INTO "nl:"
    f.*
    FROM rtl2t f
    HEAD REPORT
     ln = 0
    DETAIL
     ln = (ln+ 1), stat = alterlist(batchfile->lines,ln), batchfile->lines[ln].line = f.line
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE importfromlisting(dummy)
   SET ln = size(batchfile->lines[ln],5)
   FOR (batchno = 1 TO ln)
     IF (trim(batchfile->lines[batchno].line) > " ")
      IF (substring(1,1,batchfile->lines[batchno].line) != ";")
       IF (substring(1,1,batchfile->lines[batchno].line)="#")
        IF (cnvtupper(substring(2,10,batchfile->lines[batchno].line))="DATASOURCE")
         SET nproctype = 1
        ELSEIF (cnvtupper(substring(2,5,batchfile->lines[batchno].line))="FORMS")
         SET nproctype = 2
        ELSEIF (cnvtupper(substring(2,5,batchfile->lines[batchno].line))="FILE")
         SET nproctype = 3
        ELSEIF (cnvtupper(substring(2,3,batchfile->lines[batchno].line))="END")
         RETURN
        ENDIF
       ELSE
        SET strimport = trim(substring(1,128,batchfile->lines[batchno].line))
        CALL importform(strimport)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   FREE DEFINE rtl2
 END ;Subroutine
 SUBROUTINE importform(strimport)
  IF (cursys="AXP")
   SET strimportname = concat(trim(logical(strdir)),cnvtlower(trim(strimport)))
  ELSE
   SET strimportname = concat(trim(logical(strdir)),"/",cnvtlower(trim(strimport)))
  ENDIF
  IF (findfile(strimportname)=0)
   SET errorcount = (errorcount+ 1)
   CALL echo(concat("file not found, ",strimportname))
   SET readme_data->message = concat(trim(readme_data->message),"File '",strimportname,
    "' not found. ")
  ELSE
   SET errorflag = 0
   EXECUTE ccl_prompt_importform nullterm(strimportname)
   IF (errorflag != 0)
    SET errorcount = (errorcount+ 1)
    SET readme_data->message = substring(1,255,concat(readme_data->message,errormsg," "))
    CALL echo(concat("error importing : ",strimportname))
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE validateinstallation(tblname)
   SET tablevalid = 0
   SELECT INTO "nl:"
    t.owner, t.table_name
    FROM dba_tables t
    WHERE t.owner="V500"
     AND t.table_name=tblname
    DETAIL
     tablevalid = 1
    WITH nocounter
   ;end select
   RETURN(tablevalid)
 END ;Subroutine
END GO
