CREATE PROGRAM bhs_get_phys_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE DEFINE rtl
 DEFINE rtl "ccluserdir:physician_list.dat"
 FREE RECORD list
 FREE RECORD list
 RECORD list(
   1 cnt = i4
   1 qual[*]
     2 line = vc
     2 name1 = vc
     2 name2 = vc
     2 name_full = vc
     2 personid = f8
     2 username = vc
     2 matchfound = i2
     2 line2 = vc
 )
 SELECT
  r.line
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   list->cnt = 0
  DETAIL
   list->cnt = (list->cnt+ 1), stat = alterlist(list->qual,list->cnt), list->qual[list->cnt].line =
   trim(r.line,3),
   x = 0, x = findstring(";",list->qual[list->cnt].line,1), list->qual[list->cnt].name1 = concat(trim
    (substring(1,(x - 1),list->qual[list->cnt].line),3),", ",trim(substring((x+ 1),100,list->qual[
      list->cnt].line),3)),
   list->qual[list->cnt].name2 = concat(trim(substring(1,(x - 1),list->qual[list->cnt].line),3)," , ",
    trim(substring((x+ 1),100,list->qual[list->cnt].line),3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(list->cnt)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (((p.name_full_formatted=list->qual[d.seq].name1)) OR ((p.name_full_formatted=list->qual[d
   .seq].name2))) )
  DETAIL
   list->qual[d.seq].matchfound = 1, list->qual[d.seq].personid = p.person_id, list->qual[d.seq].
   name_full = p.name_full_formatted,
   list->qual[d.seq].username = p.username, list->qual[d.seq].line2 = build(list->qual[d.seq].
    matchfound,"&",list->qual[d.seq].username,"&",list->qual[d.seq].personid,
    "&",list->qual[d.seq].name_full)
  WITH nocounter, format
 ;end select
 DECLARE lined = vc
 SELECT INTO "test_naser.dat"
  FROM (dummyt d  WITH seq = value(list->cnt))
  DETAIL
   lined = " "
   IF ((list->qual[d.seq].line2 > " "))
    lined = build(list->qual[d.seq].line,"&",list->qual[d.seq].line2)
   ELSE
    lined = trim(list->qual[d.seq].line,3)
   ENDIF
   col 00, lined, row + 1
  WITH nocounter, format
 ;end select
END GO
