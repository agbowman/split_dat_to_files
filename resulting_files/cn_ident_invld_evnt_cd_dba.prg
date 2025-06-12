CREATE PROGRAM cn_ident_invld_evnt_cd:dba
 PROMPT
  "Start date in DD-MMM-YYYY format (defaults to 02-JAN-2004):                     " = "01-JAN-2004",
  "End date in DD-MMM-YYYY format   (defaults to current date):                    " = "CURDATE"
  WITH begindate, enddate
 DECLARE begindatetime = dq8 WITH noconstant(cnvtdatetime( $BEGINDATE))
 DECLARE enddatetime = dq8 WITH noconstant(cnvtdatetime( $ENDDATE))
 IF (( $ENDDATE="CURDATE"))
  SET enddatetime = cnvtdatetime(format(curdate,"DD-MMM-YYYY;;D"))
 ENDIF
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC")), protect
 DECLARE logfilename = vc WITH constant(build("cer_temp:cnlog",format(begindatetime,"yymmdd;;d"),"_",
   format(enddatetime,"yymmdd;;d"),".csv"))
 DECLARE sout = vc WITH public
 SELECT DISTINCT INTO value(logfilename)
  FROM clinical_event c,
   person p,
   note_type n,
   prsnl pr
  PLAN (n
   WHERE n.note_type_id != 0.0)
   JOIN (c
   WHERE c.event_cd=n.note_type_id
    AND c.performed_dt_tm > cnvtdatetime(begindatetime)
    AND c.performed_dt_tm < cnvtdatetime(enddatetime))
   JOIN (p
   WHERE p.person_id=c.person_id)
   JOIN (pr
   WHERE pr.person_id=c.performed_prsnl_id)
  HEAD REPORT
   sout = build("Clinical Event Id,Event Id,Event Code, Author Name,Patient Name,Current Note Type,"),
   sout = build(sout,
    "Note Type After Script Update,Document Status,Document Title,Service Date and Time"), row 0,
   col 0, sout
  DETAIL
   IF (c.event_class_cd=mdoc_cd)
    sout = build(c.clinical_event_id,",",c.event_id,",",n.event_cd,
     ",",'"',trim(pr.name_full_formatted),'"',",",
     '"',trim(p.name_full_formatted),'"',",",'"',
     uar_get_code_display(c.event_cd),'"',",",'"',uar_get_code_display(n.event_cd),
     '"',",",uar_get_code_display(c.result_status_cd),",",'"',
     trim(c.event_title_text),'"',",",format(c.event_end_dt_tm,"@SHORTDATETIME")), row + 1, col 0,
    sout
   ENDIF
  WITH nocounter, maxcol = 700, maxrow = 1
 ;end select
 CALL echo(build("   Total number of affected documents with an invalid Event Code: ",(curqual - 1)))
 CALL echo(build("   Output file name is: ",logfilename))
END GO
