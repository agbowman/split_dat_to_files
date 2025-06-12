CREATE PROGRAM bhs_format_file:dba
 DECLARE myfile = vc WITH protect, noconstant(build("bhscust:", $1))
 DECLARE mylogical = vc
 DECLARE head1 = vc
 DECLARE head2 = vc
 DECLARE head3 = vc
 SET pcp_name = concat("PCP Name: ",trim( $2))
 SET tab = "                 "
 CALL parser(concat('set logical mylogical "bhscust:', $1,'" go'))
 FREE DEFINE rtl
 DEFINE rtl "mylogical"
 FREE RECORD list
 RECORD list(
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 FREE RECORD list2
 RECORD list2(
   1 cnt = i2
   1 qual[*]
     2 line = vc
 )
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   list->cnt = 0
  DETAIL
   list->cnt = (list->cnt+ 1), stat = alterlist(list->qual,list->cnt), list->qual[list->cnt].line =
   trim(r.line,3)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("Found the file")
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   c = 1, l = 0, head1 = " ",
   head2 = " ", head3 = " ", head1 = concat(" \page "," ","\par {",pcp_name,"}"),
   head2 = list->qual[11].line, head3 = list->qual[12].line, stat = alterlist(list2->qual,15)
  DETAIL
   FOR (x = 1 TO 15)
     list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,x), list2->qual[x].line = list->qual[
     x].line,
     l = x
     IF (x=10)
      list2->qual[x].line = concat("\par"," {",pcp_name,"}")
     ENDIF
     IF (x=15)
      list2->qual[x].line = concat(list->qual[x].line," ","\par "), l = (l+ 1), list2->cnt = (list2->
      cnt+ 1),
      stat = alterlist(list2->qual,list2->cnt), list2->qual[list2->cnt].line = concat("\par"," ",
       "Page: ",cnvtstring(c)), l = (l+ 1),
      list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,list2->cnt), list2->qual[list2->cnt]
      .line = "\par"
     ENDIF
   ENDFOR
   FOR (x = 15 TO list->cnt)
     list->qual[x].line = replace(list->qual[x].line,tab,"\tab ",0)
     IF (l < 35)
      l = (l+ 1), list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,list2->cnt),
      list2->qual[list2->cnt].line = list->qual[x].line
     ENDIF
     IF (l > 34)
      c = (c+ 1), l = 0, l = (l+ 1),
      list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,list2->cnt), list2->qual[list2->cnt]
      .line = head1,
      l = (l+ 1), list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,list2->cnt),
      list2->qual[list2->cnt].line = head2, l = (l+ 1), list2->cnt = (list2->cnt+ 1),
      stat = alterlist(list2->qual,list2->cnt), list2->qual[list2->cnt].line = head3, l = (l+ 1),
      list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,list2->cnt), list2->qual[list2->cnt]
      .line = concat("\par"," ","Page: ",cnvtstring(c)),
      l = (l+ 1), list2->cnt = (list2->cnt+ 1), stat = alterlist(list2->qual,list2->cnt),
      list2->qual[list2->cnt].line = "\par"
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO value(myfile)
  FROM (dummyt d  WITH seq = value(list2->cnt))
  DETAIL
   col 0, list2->qual[d.seq].line, row + 1
  WITH nocounter, maxrow = 10000
 ;end select
 IF (curqual > 0)
  CALL echo(build("Format completed: ",myfile))
 ENDIF
 CALL echo("****End of Format script**")
END GO
