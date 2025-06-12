CREATE PROGRAM dcp_get_genview_announce:dba
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rhdc1 =
 "{\colortbl;\red0\green0\blue255;\red255\green255\blue255;\red255\green0\blue0;\red255\green255\blue0;"
 SET rhdc2 = "\red0\green128\blue0;\red0\green0\blue255}\deftab1134"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2buyb = "\plain \f0 \fs18 \b \ul \cf6 \cb4 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par"
 SET tcenter = "\qc "
 SET ljust = "\pard "
 SET rtab = "\tab"
 SET wr = " \plain \f0 \fs20 \cb2 "
 SET wrr = " \plain \f0 \fs18 \cf3 \cb2 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb2 "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET lidx = 0
 SET temp_disp1 = fillstring(200," ")
 SET temp_disp2 = fillstring(200," ")
 SET temp_disp3 = fillstring(200," ")
 SET temp_disp4 = fillstring(200," ")
 SET temp_disp5 = fillstring(200," ")
 SET temp_disp6 = fillstring(200," ")
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 SET header = "ANNOUNCEMENTS"
 SET footer = ""
 SET maxlines = 4
 SET annl[4] = fillstring(75," ")
 SET annl[1] = "This is a FirstNet Announcement"
 SET annl[2] = " \par "
 SET annl[3] = " \par "
 SET annl[4] = " \par "
#search_head
 SET pos = findstring("^",header)
 IF (pos > 0)
  SET stat = movestring("'",1,header,pos,1)
  GO TO search_head
 ENDIF
#search_foot
 SET pos = findstring("^",footer)
 IF (pos > 0)
  SET stat = movestring("'",1,footer,pos,1)
  GO TO search_foot
 ENDIF
 SET x = 1
#search_body
 IF (x > maxlines)
  GO TO move_along
 ENDIF
 SET pos = findstring("^",annl[x])
 IF (pos > 0)
  SET stat = movestring("'",1,annl[x],pos,1)
  GO TO search_body
 ENDIF
 SET x = (x+ 1)
 GO TO search_body
#move_along
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET drec->line_qual[lidx].disp_line = concat(rhead,rhdc1,rhdc2,rh2bu,"\cf1 \fs28 ",
  tcenter,trim(header)," ",reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET drec->line_qual[lidx].disp_line = concat(reol,wr,ljust," ")
 IF (maxlines > 0)
  SET stat = alterlist(drec->line_qual,(maxlines+ lidx))
  FOR (x = 1 TO maxlines)
   SET lidx = (lidx+ 1)
   IF (((x > 1
    AND substring(3,3,annl[(x - 1)])="par") OR (x=1)) )
    SET drec->line_qual[lidx].disp_line = concat(" ",trim(annl[x]))
   ELSE
    SET drec->line_qual[lidx].disp_line = trim(annl[x])
   ENDIF
  ENDFOR
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET drec->line_qual[lidx].disp_line = reol
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET drec->line_qual[lidx].disp_line = concat(wrr,tcenter,trim(footer),reol)
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
