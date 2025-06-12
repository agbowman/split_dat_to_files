CREATE PROGRAM ccl_prompt_print_doc:dba
 PROMPT
  "Print to:" = "MINE",
  "Folder" = "/pddoc/group0",
  "Document"
  WITH outdev, folder, filename
 DECLARE initreport(_null) = null
 DECLARE termreport(_null) = null
 DECLARE printdoc(_null) = null
 DECLARE hrpt = i4
 DECLARE hfont = i4
 DECLARE rtf = vc WITH notrim
 DECLARE hrtf = i4
 RECORD filerequest(
   1 folder_name = c100
   1 file_name = c100
 )
 RECORD filereply(
   1 folder_name = c100
   1 file_name = c100
   1 content = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE reportrtl
 SET filerequest->folder_name = trim( $FOLDER)
 SET filerequest->file_name = trim( $FILENAME)
 EXECUTE ccl_prompt_get_file  WITH replace(request,filerequest), replace(reply,filereply)
 IF ((filereply->status_data.status="S")
  AND size(trim(filereply->content)) > 0)
  CALL printdoc(0)
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    col 0, "Prompt Dialog Update Documentation", row + 3,
    col 0,
    "Documentation is currently only available from the online documentation by pressing F1 key.",
    row + 1
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE initreport(_null)
   SET rptreport->m_pagewidth = 8.0
   SET rptreport->m_pageheight = 11.5
   SET rptreport->m_orientation = 0
   SET rptreport->m_marginleft = 0.0
   SET rptreport->m_marginright = 0.0
   SET rptreport->m_margintop = 0.0
   SET rptreport->m_marginbottom = 0.0
   SET hrpt = uar_rptcreatereport(rptreport,0,rpt_inches)
 END ;Subroutine
 SUBROUTINE termreport(_null)
   DECLARE sfilename = vc WITH noconstant(trim( $OUTDEV)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(hrpt,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value( $OUTDEV) WITH deleted
   ENDIF
   CALL uar_rptdestroyreport(hrpt)
 END ;Subroutine
 SUBROUTINE printdoc(_dummy)
   DECLARE nstatus = i4
   DECLARE nret = i2
   DECLARE top = f8 WITH noconstant(0.0)
   DECLARE left = f8 WITH noconstant(0.0)
   DECLARE w = f8 WITH noconstant(0.0)
   DECLARE h = f8 WITH noconstant(0.0)
   DECLARE x = f8 WITH noconstant(0.0)
   DECLARE y = f8 WITH noconstant(0.0)
   DECLARE hrtf = i4
   CALL initreport(0)
   SET st = uar_rptstartreport(hrpt)
   SET nstatus = 0
   SET nret = rpt_continue
   SET hrtf = uar_rptrtfloadstring(hrpt,filereply->content)
   WHILE (nret=rpt_continue)
     SET top = 1.0
     SET left = 1.0
     SET w = 6.5
     SET h = 9.5
     SET x = 0
     SET y = 0
     SET st = uar_rptstartpage(hrpt)
     SET nret = uar_rptrtfrender(hrtf,left,top,w,h,
      x,y,nstatus)
     SET st = uar_rptendpage(hrpt)
   ENDWHILE
   SET st = uar_rptrtffree(hrtf)
   CALL termreport(0)
 END ;Subroutine
END GO
