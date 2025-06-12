CREATE PROGRAM bhs_rpt_ponstaff_audit:dba
 SET logical ponstafflist "bhscust:ponstaff.txt"
 FREE DEFINE rtl
 DEFINE rtl "ponstafflist"
 FREE RECORD list
 RECORD list(
   1 qual[*]
     2 username = vc
     2 name = vc
     2 print = i2
     2 logins[*]
       3 logindate = vc
 )
 SELECT INTO "nl:"
  FROM rtlt t,
   prsnl pr
  PLAN (t)
   JOIN (pr
   WHERE pr.username=t.line)
  HEAD REPORT
   c = 0
  DETAIL
   c = (c+ 1), stat = alterlist(list->qual,c), list->qual[c].username = trim(t.line),
   list->qual[c].name = pr.name_full_formatted
  WITH nocounter
 ;end select
 SET listsize = size(list->qual,5)
 CALL echo(listsize)
 FOR (z = 1 TO listsize)
   SELECT DISTINCT INTO "nl:"
    start = format(a.start_dt_tm,"mm/dd/yyyy hh:mm;;d")
    FROM application_context a
    PLAN (a
     WHERE (a.username=list->qual[z].username)
      AND a.start_dt_tm BETWEEN cnvtdatetime((curdate - 1),200000) AND cnvtdatetime(curdate,060000)
      AND a.application_image IN ("powerchart", "POWERCHART"))
    ORDER BY start, 0
    HEAD REPORT
     c = 0
    DETAIL
     c = (c+ 1), stat = alterlist(list->qual[z].logins,c), list->qual[z].logins[c].logindate = format
     (a.start_dt_tm,"mm/dd/yyyy hh:mm;;d"),
     list->qual[z].print = 1,
     CALL echo(build("list->qual[z].logins[c].logindate:",list->qual[z].logins[c].logindate)),
     CALL echo(build("list->qual [z].print:",list->qual[z].print))
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "ponstaff_audit"
  FROM (dummyt d  WITH seq = value(size(list->qual,5)))
  PLAN (d
   WHERE (list->qual[d.seq].print=1))
  DETAIL
   col 1, list->qual[d.seq].username, col 10,
   list->qual[d.seq].name, row + 1
   FOR (v = 1 TO size(list->qual[d.seq].logins,5))
     col 10, list->qual[d.seq].logins[v].logindate, row + 1
   ENDFOR
  WITH nocounter
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile(concat("ponstaff_audit",".dat"),"ponstaff.txt",
  "naser.sanjar@bhs.org james.didonato@bhs.org","PON Staff Audit",0)
 SET logical ponstafflist2 "bhscust:bmpstaff.txt"
 FREE DEFINE rtl
 DEFINE rtl "ponstafflist2"
 FREE RECORD list
 RECORD list(
   1 qual[*]
     2 username = vc
     2 name = vc
     2 print = i2
     2 logins[*]
       3 logindate = vc
 )
 SELECT INTO "nl:"
  FROM rtlt t
  WHERE t.line > " "
  HEAD REPORT
   c = 0
  DETAIL
   c = (c+ 1), stat = alterlist(list->qual,c), list->qual[c].username = build("EN",t.line)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl pr,
   (dummyt d  WITH seq = value(size(list->qual,5)))
  PLAN (d)
   JOIN (pr
   WHERE (pr.username=list->qual[d.seq].username))
  DETAIL
   list->qual[d.seq].name = pr.name_full_formatted
  WITH nocounter
 ;end select
 SET listsize = size(list->qual,5)
 CALL echo(listsize)
 FOR (z = 1 TO listsize)
   SELECT DISTINCT INTO "nl:"
    start = format(a.start_dt_tm,"mm/dd/yyyy hh:mm;;d")
    FROM application_context a
    PLAN (a
     WHERE (a.username=list->qual[z].username)
      AND a.start_dt_tm BETWEEN cnvtdatetime((curdate - 1),220000) AND cnvtdatetime(curdate,060000)
      AND a.application_image IN ("powerchart", "POWERCHART"))
    ORDER BY start, 0
    HEAD REPORT
     c = 0
    DETAIL
     c = (c+ 1), stat = alterlist(list->qual[z].logins,c), list->qual[z].logins[c].logindate = format
     (a.start_dt_tm,"mm/dd/yyyy hh:mm;;d"),
     list->qual[z].print = 1,
     CALL echo(build("list->qual[z].logins[c].logindate:",list->qual[z].logins[c].logindate)),
     CALL echo(build("list->qual [z].print:",list->qual[z].print))
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "ponstaff_audit2"
  FROM (dummyt d  WITH seq = value(size(list->qual,5)))
  PLAN (d
   WHERE (list->qual[d.seq].print=1))
  DETAIL
   col 1, list->qual[d.seq].username, col 10,
   list->qual[d.seq].name, row + 1
   FOR (v = 1 TO size(list->qual[d.seq].logins,5))
     col 10, list->qual[d.seq].logins[v].logindate, row + 1
   ENDFOR
  WITH nocounter
 ;end select
 EXECUTE bhs_ma_email_file
 CALL emailfile(concat("ponstaff_audit2",".dat"),"bmpstaff2.txt",
  "naser.sanjar@bhs.org james.didonato@bhs.org","BMP employee audit",0)
END GO
