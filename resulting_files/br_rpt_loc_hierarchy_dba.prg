CREATE PROGRAM br_rpt_loc_hierarchy:dba
 FREE RECORD temp
 RECORD temp(
   1 client = vc
   1 user = vc
   1 fcnt = i2
   1 flist[*]
     2 facility_name = vc
     2 f_location_cd = f8
     2 bcnt = i2
     2 blist[*]
       3 building_name = vc
       3 b_location_cd = f8
       3 ucnt = i2
       3 ulist[*]
         4 unit_name = vc
         4 u_location_cd = f8
         4 rcnt = i2
         4 rlist[*]
           5 room_name = vc
           5 r_location_cd = f8
           5 dcnt = i2
           5 dlist[*]
             6 bed_name = vc
             6 d_location_cd = f8
 )
 DECLARE facility = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="FACILITY")
  DETAIL
   facility = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_prsnl bp
  PLAN (bp
   WHERE (bp.br_prsnl_id=reqinfo->updt_id))
  DETAIL
   temp->user = bp.name_full_formatted
  WITH nocounter
 ;end select
 SET f_cnt = 0
 SELECT INTO "nl:"
  FROM location l,
   organization o
  PLAN (l
   WHERE l.location_type_cd=facility
    AND l.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.organization_id > 9999999
    AND o.active_ind=1)
  HEAD REPORT
   f_cnt = 0
  HEAD l.location_cd
   f_cnt = (f_cnt+ 1), stat = alterlist(temp->flist,f_cnt), temp->flist[f_cnt].facility_name = o
   .org_name,
   temp->flist[f_cnt].f_location_cd = l.location_cd
  WITH nocounter
 ;end select
 SET temp->fcnt = f_cnt
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(f_cnt)),
   location_group lg,
   location l,
   code_value cv
  PLAN (d)
   JOIN (lg
   WHERE (lg.parent_loc_cd=temp->flist[d.seq].f_location_cd)
    AND lg.active_ind=1
    AND lg.root_loc_cd=0)
   JOIN (l
   WHERE l.location_cd=lg.child_loc_cd
    AND l.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=l.location_cd)
  ORDER BY d.seq, lg.sequence
  HEAD lg.parent_loc_cd
   b_cnt = 0
  HEAD l.location_cd
   b_cnt = (b_cnt+ 1), temp->flist[d.seq].bcnt = b_cnt, stat = alterlist(temp->flist[d.seq].blist,
    b_cnt),
   temp->flist[d.seq].blist[b_cnt].b_location_cd = l.location_cd, temp->flist[d.seq].blist[b_cnt].
   building_name = cv.description
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->flist,5))
   FOR (y = 1 TO size(temp->flist[x].blist,5))
     SET u_cnt = 0
     SELECT INTO "nl:"
      FROM location_group lg,
       location l,
       code_value cv
      PLAN (lg
       WHERE (lg.parent_loc_cd=temp->flist[x].blist[y].b_location_cd)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
       JOIN (l
       WHERE l.location_cd=lg.child_loc_cd
        AND l.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=l.location_cd)
      ORDER BY lg.sequence
      HEAD REPORT
       u_cnt = 0
      HEAD l.location_cd
       u_cnt = (u_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist,u_cnt), temp->flist[x].
       blist[y].ulist[u_cnt].u_location_cd = l.location_cd,
       temp->flist[x].blist[y].ulist[u_cnt].unit_name = cv.description
      WITH nocounter
     ;end select
     SET temp->flist[x].blist[y].ucnt = u_cnt
     FOR (z = 1 TO u_cnt)
       SET r_cnt = 0
       SELECT INTO "nl:"
        FROM location_group lg,
         location l,
         code_value cv
        PLAN (lg
         WHERE (lg.parent_loc_cd=temp->flist[x].blist[y].ulist[z].u_location_cd)
          AND lg.active_ind=1
          AND lg.root_loc_cd=0)
         JOIN (l
         WHERE l.location_cd=lg.child_loc_cd
          AND l.active_ind=1)
         JOIN (cv
         WHERE cv.code_value=l.location_cd)
        ORDER BY lg.sequence
        HEAD REPORT
         r_cnt = 0
        HEAD l.location_cd
         r_cnt = (r_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist[z].rlist,r_cnt), temp->
         flist[x].blist[y].ulist[z].rlist[r_cnt].r_location_cd = l.location_cd,
         temp->flist[x].blist[y].ulist[z].rlist[r_cnt].room_name = cv.description
        WITH nocounter
       ;end select
       SET temp->flist[x].blist[y].ulist[z].rcnt = r_cnt
       FOR (i = 1 TO r_cnt)
         SET d_cnt = 0
         SELECT INTO "nl:"
          FROM location_group lg,
           location l,
           code_value cv
          PLAN (lg
           WHERE (lg.parent_loc_cd=temp->flist[x].blist[y].ulist[z].rlist[i].r_location_cd)
            AND lg.active_ind=1
            AND lg.root_loc_cd=0)
           JOIN (l
           WHERE l.location_cd=lg.child_loc_cd
            AND l.active_ind=1)
           JOIN (cv
           WHERE cv.code_value=l.location_cd)
          ORDER BY lg.sequence
          HEAD REPORT
           d_cnt = 0
          HEAD l.location_cd
           d_cnt = (d_cnt+ 1), stat = alterlist(temp->flist[x].blist[y].ulist[z].rlist[i].dlist,d_cnt
            ), temp->flist[x].blist[y].ulist[z].rlist[i].dlist[d_cnt].d_location_cd = l.location_cd,
           temp->flist[x].blist[y].ulist[z].rlist[i].dlist[d_cnt].bed_name = cv.description
          WITH nocounter
         ;end select
         SET temp->flist[x].blist[y].ulist[z].rlist[i].dcnt = d_cnt
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 SET xcol = 0
 SET ycol = 0
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
   CALL print(calcpos(xcol,ycol)), "{b}Report Name: {endb}Location Hierarchy Audit", row + 1,
   ycol = (ycol+ 20),
   CALL print(calcpos(xcol,ycol)), "{b}Facility",
   row + 1, ycol = (ycol+ 10), xcol = 65,
   CALL print(calcpos(xcol,ycol)), "{b}Building", row + 1,
   ycol = (ycol+ 10), xcol = 110,
   CALL print(calcpos(xcol,ycol)),
   "{b}Unit", row + 1, ycol = (ycol+ 10),
   xcol = 155,
   CALL print(calcpos(xcol,ycol)), "{b}Room",
   row + 1, ycol = (ycol+ 10), xcol = 200,
   CALL print(calcpos(xcol,ycol)), "{b}Bed", row + 1,
   ycol = (ycol+ 10), xcol = 20,
   CALL print(calcpos(xcol,ycol)),
   "___________________________________________________________________",
   "__________________________", row + 1,
   ycol = (ycol+ 10), "{cpi/15}", row + 1
  DETAIL
   FOR (x = 1 TO temp->fcnt)
     xcol = 20,
     CALL print(calcpos(xcol,ycol)), temp->flist[x].facility_name,
     row + 1, ycol = (ycol+ 10)
     IF (ycol > 700)
      BREAK
     ENDIF
     FOR (y = 1 TO temp->flist[x].bcnt)
       xcol = 65,
       CALL print(calcpos(xcol,ycol)), temp->flist[x].blist[y].building_name,
       row + 1, ycol = (ycol+ 10)
       IF (ycol > 700)
        BREAK
       ENDIF
       FOR (z = 1 TO temp->flist[x].blist[y].ucnt)
         xcol = 110,
         CALL print(calcpos(xcol,ycol)), temp->flist[x].blist[y].ulist[z].unit_name,
         row + 1, ycol = (ycol+ 10)
         IF (ycol > 700)
          BREAK
         ENDIF
         FOR (w = 1 TO temp->flist[x].blist[y].ulist[z].rcnt)
           xcol = 155,
           CALL print(calcpos(xcol,ycol)), temp->flist[x].blist[y].ulist[z].rlist[w].room_name,
           row + 1, ycol = (ycol+ 10)
           IF (ycol > 700)
            BREAK
           ENDIF
           FOR (u = 1 TO temp->flist[x].blist[y].ulist[z].rlist[w].dcnt)
             xcol = 200,
             CALL print(calcpos(xcol,ycol)), temp->flist[x].blist[y].ulist[z].rlist[w].dlist[u].
             bed_name,
             row + 1, ycol = (ycol+ 10)
             IF (ycol > 700)
              BREAK
             ENDIF
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
     IF ((x=temp->fcnt))
      ycol = (ycol+ 10), xcol = 240,
      CALL print(calcpos(xcol,ycol)),
      "{b}*** End of Report ***", row + 1
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
