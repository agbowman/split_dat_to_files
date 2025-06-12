CREATE PROGRAM bhs_sys_onbase_format:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "File Name" = ""
  WITH outdev, prompt1
 SET myfile = build("ccluserdir:", $PROMPT1)
 SET outfile = build(myfile,"_v1")
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 line = vc
 )
 FREE DEFINE rtl
 DEFINE rtl myfile
 SELECT INTO  $1
  r.line
  FROM rtlt r
  PLAN (r
   WHERE r.line > " ")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].line = build(substring(1,9,r
     .line),"|",substring(10,8,r.line),"|",substring(18,9,r.line))
  WITH nocounter
 ;end select
 SELECT INTO value(outfile)
  temp->qual[d.seq].line
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d
   WHERE d.seq > 0)
  WITH nocounter, noheading
 ;end select
END GO
