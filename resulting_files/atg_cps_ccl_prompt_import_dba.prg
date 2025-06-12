CREATE PROGRAM atg_cps_ccl_prompt_import:dba
 PROMPT
  "Enter definition filename (.dpb): " = " "
  WITH filename
 DECLARE ocd_log = vc WITH protect, noconstant("")
 DECLARE npos = i4 WITH protect, noconstant(0)
 DECLARE sfilename = vc WITH protect, noconstant("")
 DECLARE cdir_char = c1 WITH protect, noconstant(" ")
 DECLARE simportname = vc WITH protect, noconstant("")
 DECLARE sobjectname = vc WITH protect, noconstant("")
 DECLARE nobjectexist = i2 WITH protect, noconstant(0)
 DECLARE errormsg = vc WITH public
 CALL echo("***************************************************")
 SET sfilename = build( $FILENAME)
 SET npos = findstring(".",sfilename,1)
 IF (npos > 0)
  SET sobjectname = cnvtupper(substring(1,(npos - 1),sfilename))
 ELSE
  SET sobjectname = cnvtupper(sfilename)
  SET sfilename = build(sfilename,".dpb")
 ENDIF
 IF (cursys="AIX")
  SET cdir_char = "/"
 ELSE
  SET cdir_char = trim(" ")
 ENDIF
 SET ocd_log = logical("cer_install")
 SET simportname = concat(trim(ocd_log),cdir_char,cnvtlower(trim(sfilename)))
 IF (findfile(nullterm(simportname))=0)
  CALL echo("ERROR!  Import Failed!")
  CALL echo(build("File not found:",simportname))
  GO TO exit_script
 ELSE
  CALL echo(build("Found file:",simportname))
 ENDIF
 CALL echo("executing ccl_prompt_importform . .")
 EXECUTE ccl_prompt_importform nullterm(simportname)
 CALL echo("***************************************************")
 SELECT INTO "nl:"
  FROM ccl_prompt_programs cpp,
   ccl_prompt_definitions cpd,
   ccl_prompt_properties cprop
  PLAN (cpp
   WHERE cpp.program_name=sobjectname)
   JOIN (cpd
   WHERE cpd.program_name=cpp.program_name)
   JOIN (cprop
   WHERE cprop.prompt_id=cpd.prompt_id)
  ORDER BY cpp.program_name
  HEAD cpp.program_name
   IF (cnvtdate(cpd.updt_dt_tm)=curdate
    AND cnvtdate(cprop.updt_dt_tm)=curdate)
    nobjectexist = 1
   ENDIF
  WITH counter
 ;end select
 CALL echo("***************************************************")
 IF (((size(trim(errormsg)) > 0) OR (nobjectexist=0)) )
  CALL echo("ERROR!  Import Failed!")
  CALL echo(errormsg)
 ELSE
  CALL echo("Import Completed Successfully!")
 ENDIF
#exit_script
 CALL echo("***************************************************")
END GO
