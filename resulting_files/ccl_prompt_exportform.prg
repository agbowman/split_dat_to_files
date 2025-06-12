CREATE PROGRAM ccl_prompt_exportform
 PROMPT
  "Output to File/Printer/MINE" = "",
  "Export Type" = 0,
  "Group ID:" = 0,
  "Program Name" = "*",
  "Export Directory:" = "CCLUSERDIR"
  WITH outdev, exporttype, grpid,
  formname, expdir
 DECLARE validateprogram(strobjname=vc,groupid=i2) = i2 WITH private
 DECLARE exportstoredprogram(strobjname=vc,groupno=i2) = null WITH private
 DECLARE exportdoc(strobjname=vc,groupid=i2) = null WITH public
 DECLARE exportdefinition(strobjname=vc,groupid=i2) = null WITH public
 DECLARE getexportname(strobjname=vc,groupid=i2) = vc WITH protect
 DECLARE writeerror(strformname) = null WITH private
 DECLARE exportform(strfilename=vc,strobjname=vc,groupid=i2) = null WITH private
 DECLARE writeconfirmation(strfilename=vc) = null WITH private
 DECLARE validateform(strobjname=vc,groupid=i2) = null WITH private
 DECLARE strtimestamp = vc WITH noconstant(""), protect
 DECLARE strpropfile = vc WITH noconstant('""'), protect
 DECLARE strdeffile = vc WITH noconstant('""'), protect
 DECLARE npromptcount = i2 WITH noconstant(0), protect
 DECLARE strfilename = vc WITH noconstant(""), protect
 RECORD helpdoc(
   1 line[*]
     2 text = vc
 )
 SET cr = char(13)
 SET nl = char(10)
 FREE DEFINE rtl2
 SET logical lgexport ""
 SET strtimestamp = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;q")
 SET strfilename = cnvtupper(trim( $FORMNAME))
 SET npromptcount = validateform(strfilename, $GRPID)
 IF (( $EXPORTTYPE=0))
  CALL exportform(strfilename, $GRPID)
  CALL writeconfirmation(strdeffile)
 ELSEIF (( $EXPORTTYPE=1))
  IF (validateprogram(strfilename, $GRPID) > 0)
   CALL exportstoredprogram(strfilename, $GRPID)
   CALL writeconfirmation(strfilename)
  ELSE
   CALL writeerror(strfilename)
  ENDIF
 ELSEIF (( $EXPORTTYPE=2))
  CALL exportdoconly( $FORMNAME)
  CALL writeconfirmation(strfilename)
 ELSE
  CALL writeerror(strfilename)
 ENDIF
 FREE DEFINE rtl2
 RETURN(0)
 SUBROUTINE validateprogram(strobjname,groupid)
   CALL echo(concat("ValidateProgram ",strobjname))
   DECLARE cnt = i2 WITH noconstant(0)
   SELECT INTO "NL:"
    count(*)
    FROM ccl_prompt_programs cpp
    WHERE cpp.program_name=strobjname
     AND cpp.group_no=groupid
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
    WITH nocounter
   ;end select
   RETURN(cnt)
 END ;Subroutine
 SUBROUTINE exportstoredprogram(strobjname,groupno)
   CALL echo("ExportStoredProgram")
   SET strpropfile = getexportname(strobjname,groupno)
   SET logical lgexport value(strpropfile)
   SELECT INTO lgexport
    cpp.*
    FROM ccl_prompt_programs cpp
    WHERE cpp.program_name=strobjname
     AND cpp.group_no=groupno
    HEAD REPORT
     col 0, "*", "SP",
     "0001", strtimestamp, row + 1
    DETAIL
     col 0, "P", cpp.program_name";;CU",
     cpp.group_no"##", cpp.control_class_id"###############", cpp.display,
     cpp.description, cpp.updt_dt_tm"dd-mmm-yyyy hh:mm:ss;;q", cpp.updt_id"###############",
     cpp.updt_task"###############", cpp.updt_cnt"###############", cpp.updt_applctx"###############",
     row + 1
    FOOT REPORT
     col 0, "#", row + 1
    WITH nocounter, maxcol = 3000
   ;end select
 END ;Subroutine
 SUBROUTINE getexportname(strobjname,groupid)
   CALL echo("GetExportName")
   IF (cursys="AXP")
    SET strname = concat(trim(logical( $EXPDIR)),"expdpl",cnvtlower(trim(strobjname)),trim(cnvtstring
      (groupid)),".dat")
   ELSE
    SET strname = concat(trim(logical( $EXPDIR)),"/expdpl",cnvtlower(trim(strobjname)),trim(
      cnvtstring(groupid)),".dat")
   ENDIF
   CALL echo(concat("Export file name = ",strname))
   RETURN(strname)
 END ;Subroutine
 SUBROUTINE writeerror(strformname)
   SELECT INTO  $OUTDEV
    *
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 1, "No prompts defined for form '", strformname,
     "'", row + 2, col 1,
     "No export file created.", row + 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE writeconfirmation(strfilename)
   SELECT INTO  $OUTDEV
    *
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 1, "Prompt Form '",  $FORMNAME,
     "' was succesfully exported to ", strpropfile, ".",
     row + 2
     IF (cnvtint( $EXPORTTYPE)=1)
      col 1, "Exported ", npromptcount"###",
      " prompts.", row + 1
     ENDIF
    WITH nocounter, maxcol = 600
   ;end select
 END ;Subroutine
 SUBROUTINE exportform(strobjname,groupid)
  CALL exportdefinition(strobjname,groupid)
  CALL exportdoc(strobjname,groupid)
 END ;Subroutine
 SUBROUTINE exportdoc(strobjname,groupid)
   DECLARE folder = vc
   SET folder = concat("/PDDOC/GROUP",trim(cnvtstring(groupid),3),"/",cnvtupper(strobjname))
   CALL exportdoconly(folder)
 END ;Subroutine
 SUBROUTINE exportdoconly(strpathname)
   DECLARE folder = vc
   DECLARE file = vc
   DECLARE nlast = i2
   DECLARE nlen = i2
   DECLARE l = i2
   DECLARE str = vc WITH notrim
   SET nlen = textlen(strpathname)
   SET nlast = findstring("/",strpathname,0,1)
   SET file = substring((nlast+ 1),(nlen - nlast),strpathname)
   SET folder = substring(1,nlast,strpathname)
   CALL exportpromptfile(folder,file)
   IF (cursys="AXP")
    SET strpropfile = concat(trim(logical( $EXPDIR)),"expdpl",cnvtlower(trim(file)),"doc.dat")
   ELSE
    SET strpropfile = concat(trim(logical( $EXPDIR)),"/expdpl",cnvtlower(trim(file)),"doc.dat")
   ENDIF
   SET logical lgexport value(strpropfile)
   CALL echo(concat("exporting to ",strpropfile))
   SELECT INTO lgexport
    FROM (dummyt  WITH seq = 1)
    HEAD REPORT
     col 0, "*", "PF",
     "0001", strtimestamp, strpathname,
     row + 1
    DETAIL
     ncount = size(helpdoc->line,5)
     FOR (l = 1 TO ncount)
       str = substring(1,1000,helpdoc->line[l].text), col 0, str,
       row + 1, str = substring(1001,2000,helpdoc->line[l].text), col 0,
       str, row + 1
     ENDFOR
    WITH nocounter, maxcol = 2000, check
   ;end select
 END ;Subroutine
 SUBROUTINE exportpromptfile(strfolder,strfile)
   DECLARE docline = vc
   CALL echo("reading ccl_prompt_file")
   SET x = alterlist(helpdoc->line,0)
   SELECT INTO "nl:"
    pf.*
    FROM ccl_prompt_file pf
    WHERE cnvtupper(pf.folder_name)=cnvtupper(strfolder)
     AND cnvtupper(pf.file_name)=cnvtupper(strfile)
    ORDER BY pf.collation_seq
    HEAD REPORT
     lineno = 0
    DETAIL
     lineno = (lineno+ 1), x = alterlist(helpdoc->line,lineno), docline = pf.content,
     helpdoc->line[lineno].text = substring(1,2000,trim(docline))
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE exportdefinition(strobjname,groupid)
   CALL echo(concat("ExportDefinition:",strobjname))
   DECLARE pv = c1000 WITH notrim
   SET strpropfile = getexportname(strobjname,groupid)
   SET logical lgexport value(strpropfile)
   CALL echo(concat("writting form to file ",strpropfile))
   SELECT INTO lgexport
    cpd.*, cpp.*
    FROM ccl_prompt_definitions cpd,
     ccl_prompt_properties cpp
    PLAN (cpd
     WHERE cpd.program_name=strobjname
      AND cpd.group_no=groupid)
     JOIN (cpp
     WHERE ((cpp.prompt_id=cpd.prompt_id) OR (cpp.prompt_id=0)) )
    ORDER BY cpd.position, cpd.prompt_id, cpp.component_name,
     cpp.property_name
    HEAD REPORT
     col 0, "*", "CF",
     "0001", strtimestamp, strobjname"##############################",
     groupid"#", row + 1
    HEAD cpd.prompt_id
     col 0, "+", cpd.program_name,
     cpd.prompt_name, cpd.group_no"#;P0", cpd.control"###;P0",
     cpd.position"###;P0", cpd.display, cpd.description,
     cpd.default_value, cpd.result_type_ind"#;P0", cpd.width"####;P0;",
     cpd.height"####;P0;", cpd.exclude_ind"#;P0", cpd.updt_dt_tm"dd-mmm-yyyy hh:mm:ss;;q",
     cpd.updt_id"###############;P0", cpd.updt_cnt"###############;P0", cpd.updt_applctx
     "###############;P0",
     cpd.updt_task"###############;P0", row + 1
    DETAIL
     pv = cpp.property_value, col 0, "-",
     cpp.component_name, cpp.property_name, pv,
     cpp.updt_dt_tm"dd-mmm-yyyy hh:mm:ss;;q", cpp.updt_id"###############;P0", cpp.updt_cnt
     "###############;P0",
     cpp.updt_applctx"###############;P0", cpp.updt_task"###############;P0", row + 1
    FOOT REPORT
     col 0, "#", row + 1
    WITH nocounter, format = fixed, maxcol = 2000
   ;end select
 END ;Subroutine
 SUBROUTINE validateform(strobjname,groupid)
   CALL echo("ValidateForm")
   DECLARE ncount = i2 WITH noconstant(0)
   SELECT INTO noform
    cpd.*
    FROM ccl_prompt_definitions cpd
    PLAN (cpd
     WHERE trim(cpd.program_name)=cnvtupper(strobjname)
      AND cpd.group_no=groupid)
    ORDER BY cpd.position, cpd.prompt_id
    DETAIL
     ncount = (ncount+ 1)
    WITH nocounter
   ;end select
   RETURN(ncount)
 END ;Subroutine
END GO
