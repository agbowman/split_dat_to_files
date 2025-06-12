CREATE PROGRAM aa_mpage_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "HTML File:" = "ccluserdir:aa_mpage.html"
  WITH outdev, html_file
 FREE RECORD mpage_rec
 RECORD mpage_rec(
   1 html_file = vc
 )
 SET mpage_rec->html_file =  $HTML_FILE
 RECORD getrequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 RECORD getreply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET getrequest->module_dir = trim(mpage_rec->html_file,3)
 SET getrequest->module_name = ""
 SET getrequest->basblob = 1
 EXECUTE eks_get_source  WITH replace(request,getrequest), replace(reply,getreply)
 IF ((getreply->status_data.status="F"))
  SET getreply->data_blob = build2("<html><head><title>MPage Error</title></head>",
   '<body><div>HTML file "',mpage_rec->html_file,'" could not be found!</div>',char(10),
   char(13),"</body></html>")
 ENDIF
 SET _memory_reply_string = getreply->data_blob
#exit_script
 FREE RECORD mpage_rec
END GO
