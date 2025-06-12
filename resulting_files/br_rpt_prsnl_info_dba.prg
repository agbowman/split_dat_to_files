CREATE PROGRAM br_rpt_prsnl_info:dba
 FREE RECORD temp
 RECORD temp(
   1 client = vc
   1 user = vc
   1 cnt = i2
   1 qual[*]
     2 name = vc
     2 position = vc
     2 username = vc
 )
 SET xcol = 0
 SET ycol = 0
 SELECT INTO "nl:"
  FROM br_prsnl bp
  PLAN (bp
   WHERE (bp.br_prsnl_id=reqinfo->updt_id))
  DETAIL
   temp->user = bp.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p,
   code_value cv
  PLAN (p
   WHERE p.person_id > 9999999
    AND p.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=p.position_cd)
  ORDER BY cnvtupper(p.name_full_formatted)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].name = notrim(p
    .name_full_formatted),
   temp->qual[cnt].username = p.username, temp->qual[cnt].position = cv.display
  FOOT REPORT
   temp->cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO  $1
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   xcol = 220, ycol = 25, "{cpi/10}",
   row + 1,
   CALL print(calcpos(xcol,ycol)), "{b}Bedrock Summary Report",
   row + 1, ycol = (ycol+ 10), "{cpi/15}",
   row + 1, xcol = 235,
   CALL print(calcpos(xcol,ycol)),
   "Does not contain START data", row + 1
  HEAD PAGE
   "{cpi/12}", row + 1, xcol = 20
   IF (curpage=1)
    ycol = 57
   ELSE
    ycol = 25
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{b}Report Name: {endb}Personnel Position Audit", row + 1,
   xcol = 20, ycol = (ycol+ 25),
   CALL print(calcpos(xcol,ycol)),
   "{u}{b}Name", row + 1, xcol = 250,
   CALL print(calcpos(xcol,ycol)), "{u}{b}Username", row + 1,
   xcol = 335,
   CALL print(calcpos(xcol,ycol)), "{u}{b}Position",
   row + 1, "{cpi/15}", row + 1,
   ycol = (ycol+ 10)
  DETAIL
   FOR (x = 1 TO temp->cnt)
     xcol = 20,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].name,
     row + 1, xcol = 250,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].username, row + 1, xcol = 335,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].position, row + 1,
     ycol = (ycol+ 10)
     IF ((x=temp->cnt))
      ycol = (ycol+ 10), xcol = 240,
      CALL print(calcpos(xcol,ycol)),
      "{b}*** End of Report ***", row + 1
     ENDIF
     IF (ycol > 700
      AND (x != temp->cnt))
      BREAK
     ENDIF
   ENDFOR
  FOOT PAGE
   xcol = 20, ycol = 735,
   CALL print(calcpos(xcol,ycol)),
   "Page: ", curpage"##", row + 1,
   ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)), "Date/Time: ",
   curdate, " ", curtime,
   row + 1, ycol = (ycol+ 10),
   CALL print(calcpos(xcol,ycol)),
   "Printed By: ", temp->user, row + 1,
   ycol = (ycol+ 10)
  WITH nocounter, dio = 08, maxrow = 800,
   maxcol = 800
 ;end select
END GO
