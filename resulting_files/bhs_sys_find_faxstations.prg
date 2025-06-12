CREATE PROGRAM bhs_sys_find_faxstations
 PROMPT
  "output" = "MINE",
  "File name" = "himfaxlist"
  WITH outdev, mode
 SET filepath = build("bhscust:", $2,".txt")
 CALL echo(build("Reading File:",filepath))
 IF (findfile(filepath) > 0)
  CALL echo("Found File")
 ELSE
  CALL echo("Did not find the file, will exit")
  GO TO exit_code
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 line = vc
     2 phyid = vc
     2 himname = vc
     2 himfax = vc
     2 matchind = i2
 )
 FREE RECORD temp2
 RECORD temp2(
   1 cnt = i4
   1 qual[*]
     2 cisid = vc
     2 cisname = vc
     2 cisfax = vc
     2 matchind = i2
 )
 FREE RECORD displayline
 RECORD displayline(
   1 cnt = i4
   1 qual[*]
     2 phyid = vc
     2 himname = vc
     2 himfax = vc
     2 cisid = vc
     2 cisname = vc
     2 cisfax = vc
     2 matchind = i2
 )
 DECLARE name = vc
 DECLARE fax = vc
 DECLARE id = vc
 FREE DEFINE rtl
 DEFINE rtl filepath
 SELECT INTO "nl:"
  FROM rtlt r
  HEAD REPORT
   cnt = 0, c1 = 0, c2 = 0,
   c3 = 0
  DETAIL
   name = " ", fax = " ", id = " ",
   c1 = 0, c2 = 0
   IF (trim(r.line,3) > " ")
    cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].line = trim(r.line,3),
    c1 = findstring("&",temp->qual[cnt].line,1,0), fax = trim(substring(1,(c1 - 1),temp->qual[cnt].
      line),3), temp->qual[cnt].himfax = trim(fax,3),
    c2 = findstring("&",temp->qual[cnt].line,(c1+ 1),1), name = trim(substring((c1+ 1),((c2 - 1) - (
      c1+ 1)),temp->qual[cnt].line),3), temp->qual[cnt].himname = trim(name,3),
    temp->qual[cnt].phyid = trim(substring((c2+ 1),60,temp->qual[cnt].line),3), temp->cnt = (temp->
    cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pr.name_full_formatted, pa.alias, rd.area_code,
  rd.exchange, rd.phone_suffix
  FROM prsnl pr,
   device_xref dx,
   remote_device rd,
   prsnl_alias pa,
   dummyt d
  PLAN (pr)
   JOIN (dx
   WHERE dx.parent_entity_name="PRSNL"
    AND dx.parent_entity_id=pr.person_id
    AND dx.usage_type_cd=2282)
   JOIN (rd
   WHERE rd.device_cd=dx.device_cd)
   JOIN (d)
   JOIN (pa
   WHERE pa.person_id=pr.person_id
    AND pa.prsnl_alias_type_cd=1086.00
    AND pa.active_ind=1)
  DETAIL
   temp2->cnt = (temp2->cnt+ 1), stat = alterlist(temp2->qual,temp2->cnt), temp2->qual[temp2->cnt].
   cisfax = build("(",rd.area_code,")",rd.exchange,"-",
    rd.phone_suffix),
   temp2->qual[temp2->cnt].cisid = pa.alias, temp2->qual[temp2->cnt].cisname = pr.name_full_formatted
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->cnt)
   FOR (y = 1 TO temp2->cnt)
     IF ((temp->qual[x].phyid=temp2->qual[y].cisid))
      SET temp->qual[x].matchind = 1
      SET temp2->qual[y].matchind = 1
      SET displayline->cnt = (displayline->cnt+ 1)
      SET stat = alterlist(displayline->qual,displayline->cnt)
      SET displayline->qual[displayline->cnt].phyid = temp->qual[x].phyid
      SET displayline->qual[displayline->cnt].himname = temp->qual[x].himname
      SET displayline->qual[displayline->cnt].himfax = temp->qual[x].himfax
      SET displayline->qual[displayline->cnt].cisid = temp2->qual[y].cisid
      SET displayline->qual[displayline->cnt].cisname = temp2->qual[y].cisname
      SET displayline->qual[displayline->cnt].cisfax = temp2->qual[y].cisfax
      SET displayline->qual[displayline->cnt].matchind = 1
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 CALL echorecord(temp)
 CALL echorecord(temp2)
 CALL echorecord(displayline)
 DECLARE line = vc
 SELECT INTO "cishimfaxlist.csv"
  FROM dummyt d
  HEAD REPORT
   line = " ", line = concat("HIM Phys ID",char(9),"HIM Phy Name",char(9),"HIM Fax",
    char(9),"CIS External ID",char(9),"CIS Phy Name",char(9),
    "CIS Fax"), col 0,
   line, row + 1
  DETAIL
   FOR (x = 1 TO displayline->cnt)
     line = " ", line = concat(displayline->qual[x].phyid,char(9),displayline->qual[x].himname,char(9
       ),displayline->qual[x].himfax,
      char(9),displayline->qual[x].cisid,char(9),displayline->qual[x].cisname,char(9),
      displayline->qual[x].cisfax), col 0,
     line, row + 1
   ENDFOR
   FOR (y = 1 TO temp->cnt)
     IF ((temp->qual[y].matchind=0))
      line = " ", line = concat(temp->qual[y].phyid,char(9),temp->qual[y].himname,char(9),temp->qual[
       y].himfax,
       char(9)," ",char(9)," ",char(9),
       " "), col 0,
      line, row + 1
     ENDIF
   ENDFOR
   FOR (z = 1 TO temp2->cnt)
     IF ((temp2->qual[z].matchind=0))
      line = " ", line = concat(" ",char(9)," ",char(9)," ",
       char(9),temp2->qual[z].cisid,char(9),temp2->qual[z].cisname,char(9),
       temp2->qual[z].cisfax), col 0,
      line, row + 1
     ENDIF
   ENDFOR
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
END GO
