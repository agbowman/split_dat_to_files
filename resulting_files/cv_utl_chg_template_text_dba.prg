CREATE PROGRAM cv_utl_chg_template_text:dba
 PROMPT
  "Output:(Mine)" = mine,
  "RTF File Name:" = "CV_TEMPLATE.rtf",
  "Long Blob Id:" = 2379369
 RECORD request(
   1 file_name = vc
   1 rtf_text = vc
   1 long_blob_id = f8
 )
 SET request->file_name =  $2
 SET request->long_blob_id =  $3
 FREE DEFINE rtl
 DEFINE rtl concat(request->file_name)
 SET header_row = fillstring(32000," ")
 SELECT INTO "nl:"
  log = r.line
  FROM rtlt r
  DETAIL
   request->rtf_text = build(request->rtf_text,log)
  WITH nocounter
 ;end select
 CALL echo(build("RTF TEXT is:",trim(request->rtf_text),":"))
 UPDATE  FROM long_blob lb
  SET lb.long_blob = request->rtf_text
  WHERE (lb.long_blob_id=request->long_blob_id)
  WITH nocounter
 ;end update
 CALL echo("Check the Long Blob using cv_utl_disp_template_Text <Lon_blob_id> go")
 CALL echo("If every thing looks good commit the results")
END GO
