CREATE PROGRAM cern_dcp_rpt_census:dba
 SET height_cd = 0
 SET weight_cd = 0
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 ind = i4
     2 person_id = f8
     2 encntr_id = f8
     2 name = vc
     2 unit = c14
     2 room = c8
     2 bed = c4
     2 room_bed = vc
     2 height = vc
     2 weight = vc
     2 cnt = i2
     2 qual[*]
       3 allergy = vc
     2 allergy_line = vc
     2 ln_cnt = i2
     2 ln_qual[*]
       3 line = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE canceled_cd = f8 WITH noconstant(0.0)
 DECLARE census_type_cd = f8 WITH noconstant(0.0)
 DECLARE inerror_cd = f8 WITH noconstant(0.0)
 SET canceled_cd = uar_get_code_by("MEANING",12025,"CANCELED")
 SET census_type_cd = uar_get_code_by("MEANING",339,"CENSUS")
 SET inerror_cd = uar_get_code_by("MEANING",8,"INERROR")
 SET name = fillstring(100," ")
 SELECT INTO "nl:"
  name = cnvtupper(p.name_full_formatted)
  FROM encntr_domain ed,
   person p
  PLAN (ed
   WHERE ed.encntr_domain_type_cd=census_type_cd
    AND ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ed.person_id)
  ORDER BY name
  HEAD REPORT
   temp->cnt = 0, stat = alterlist(temp->qual,50)
  HEAD p.person_id
   temp->cnt = (temp->cnt+ 1)
   IF (mod(temp->cnt,50)=1
    AND (temp->cnt != 1))
    stat = alterlist(temp->qual,(temp->cnt+ 50))
   ENDIF
   temp->qual[temp->cnt].ind = 0, temp->qual[temp->cnt].person_id = ed.person_id, temp->qual[temp->
   cnt].encntr_id = ed.encntr_id,
   temp->qual[temp->cnt].name = p.name_full_formatted, temp->qual[temp->cnt].unit =
   uar_get_code_display(ed.loc_nurse_unit_cd), temp->qual[temp->cnt].room = uar_get_code_display(ed
    .loc_room_cd),
   temp->qual[temp->cnt].bed = uar_get_code_display(ed.loc_bed_cd), temp->qual[temp->cnt].room_bed =
   concat(trim(temp->qual[temp->cnt].room),"/",trim(temp->qual[temp->cnt].bed))
  FOOT REPORT
   stat = alterlist(temp->qual,temp->cnt)
  WITH nocounter
 ;end select
 SET allergy = fillstring(255," ")
 SELECT INTO "nl:"
  allergy = cnvtupper(nullcheck(n.source_string,a.substance_ftdesc,
    IF (n.source_string > " ") 0
    ELSE 1
    ENDIF
    ))
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   allergy a,
   (dummyt d1  WITH seq = 1),
   nomenclature n
  PLAN (d)
   JOIN (a
   WHERE (a.person_id=temp->qual[d.seq].person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY a.person_id, allergy
  HEAD REPORT
   cnt = 0
  HEAD a.person_id
   cnt = 0, temp->qual[d.seq].ind = 1
  DETAIL
   IF (((n.source_string > " ") OR (a.substance_ftdesc > " ")) )
    cnt = (cnt+ 1), temp->qual[d.seq].cnt = cnt, stat = alterlist(temp->qual[d.seq].qual,cnt),
    temp->qual[d.seq].qual[cnt].allergy = a.substance_ftdesc
    IF (n.source_string > " ")
     temp->qual[d.seq].qual[cnt].allergy = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = n
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   clinical_event c
  PLAN (d)
   JOIN (c
   WHERE (c.person_id=temp->qual[d.seq].person_id)
    AND c.event_cd IN (height_cd, weight_cd, 22420, 22635)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != inerror_cd)
  ORDER BY c.person_id, c.event_cd, cnvtdatetime(c.event_end_dt_tm)
  HEAD REPORT
   cnt = 0
  HEAD c.person_id
   cnt = 0, temp->qual[d.seq].ind = 1
  DETAIL
   IF (c.event_cd=height_cd)
    temp->qual[d.seq].height = c.event_tag
   ELSEIF (c.event_cd=weight_cd)
    temp->qual[d.seq].weight = c.event_tag
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->cnt)
   FOR (y = 1 TO temp->qual[x].cnt)
     IF (y=1)
      SET temp->qual[x].allergy_line = temp->qual[x].qual[y].allergy
     ELSE
      SET temp->qual[x].allergy_line = concat(trim(temp->qual[x].allergy_line),", ",trim(temp->qual[x
        ].qual[y].allergy))
     ENDIF
   ENDFOR
   SET pt->line_cnt = 0
   SET max_length = 70
   EXECUTE dcp_parse_text value(temp->qual[x].allergy_line), value(max_length)
   SET stat = alterlist(temp->qual[x].ln_qual,pt->line_cnt)
   SET temp->qual[x].ln_cnt = pt->line_cnt
   FOR (z = 1 TO pt->line_cnt)
     SET temp->qual[x].ln_qual[z].line = pt->lns[z].line
   ENDFOR
 ENDFOR
 SELECT INTO request->output_device
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", row + 1, "{f/13}{cpi/11}",
   row + 1, "{pos/220/40}Daily Listing of Patient Medical Information for Census Date: ", curdate,
   row + 1, "{cpi/14}", row + 1,
   "{pos/30/60}{u}Name", row + 1, "{pos/190/60}{u}Unit",
   row + 1, "{pos/270/60}{u}Room/Bed", row + 1,
   "{pos/340/60}{u}Height (in)", row + 1, "{pos/400/60}{u}Weight (kg)",
   row + 1, "{pos/460/60}{u}Allergies", row + 1,
   "{f/8}", row + 1, ycol = 72
  DETAIL
   FOR (x = 1 TO temp->cnt)
     IF ((temp->qual[x].ind=1))
      scol = (ycol+ (temp->qual[x].ln_cnt * 10))
      IF (scol > 500)
       BREAK
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), temp->qual[x].name,
      row + 1, xcol = 190,
      CALL print(calcpos(xcol,ycol)),
      temp->qual[x].unit, row + 1, xcol = 270,
      CALL print(calcpos(xcol,ycol)), temp->qual[x].room_bed, row + 1,
      xcol = 340,
      CALL print(calcpos(xcol,ycol)), temp->qual[x].height,
      row + 1, xcol = 400,
      CALL print(calcpos(xcol,ycol)),
      temp->qual[x].weight, row + 1, xcol = 460
      FOR (y = 1 TO temp->qual[x].ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->qual[x].ln_qual[y].line, row + 1,
        ycol = (ycol+ 10)
      ENDFOR
      ycol = (ycol+ 7)
      IF (ycol > 500)
       BREAK
      ENDIF
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/60/550}{b}Page ", curpage"##", row + 1,
   "{pos/335/550}{b}Print Date/Time: ", curdate, " ",
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 256,
   maxrow = 256
 ;end select
 SET script_version = "*** 05/06/03 MOD 003 BM7822 ***"
END GO
