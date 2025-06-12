CREATE PROGRAM bhs_mpage_future_func:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $1
  FROM dummyt d
  DETAIL
   row + 1, "<html xmlns='http://www.w3.org/1999/xhtml'>", row + 1,
   "<head>", row + 1, "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />",
   row + 1, "<title>Untitled Document</title>", row + 1,
   "<style type='text/css'>", row + 1, "<!--.style1 {font-size: 46px}-->",
   row + 1, "</style>", row + 1,
   "</head>", row + 1, "<body>",
   row + 1, "<h1 align='center' class='style1'>Future Functionality</h1>", row + 1,
   "</body>", row + 1, "</html>"
  WITH maxcol = 200
 ;end select
END GO
