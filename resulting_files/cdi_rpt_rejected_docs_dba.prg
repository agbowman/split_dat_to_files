CREATE PROGRAM cdi_rpt_rejected_docs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Layout Program" = "cdi_rpt_rejected_docs_lyt",
  "Start Date" = "",
  "End Date" = "",
  "Doc UID" = "",
  "Contributor System" = ""
  WITH outdev, layout_program, startdate,
  enddate, referencenbr, contribsys
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE strexec = vc WITH noconstant("")
 DECLARE strlyt = vc WITH noconstant("cdi_rpt_rejected_docs_lyt")
 DECLARE strsta = vc WITH noconstant("")
 DECLARE strend = vc WITH noconstant("")
 DECLARE strref = vc WITH noconstant("")
 DECLARE strsys = vc WITH noconstant("")
 SET strsta =  $STARTDATE
 SET strend =  $ENDDATE
 SET strref =  $REFERENCENBR
 SET strsys =  $CONTRIBSYS
 IF (size(trim(strsta)) < 1)
  SET strsta = " "
 ENDIF
 IF (size(trim(strend)) < 1)
  SET strend = " "
 ENDIF
 IF (size(trim(strref)) < 1)
  SET strref = " "
 ENDIF
 IF (size(trim(strsys)) < 1)
  SET strsys = " "
 ENDIF
 IF (cnvtupper( $LAYOUT_PROGRAM) != "DEFAULT"
  AND size(trim( $LAYOUT_PROGRAM)) > 0)
  SET strlayoutprogram =  $LAYOUT_PROGRAM
 ENDIF
 SET strexec = build2("execute ",strlyt," '", $OUTDEV,"', '",
  strsta,"', '",strend,"', '",strref,
  "', '",strsys,"' go")
 CALL parser(strexec)
END GO
