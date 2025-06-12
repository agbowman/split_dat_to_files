CREATE PROGRAM bed_add_location_alias:dba
 PAINT
 SET width = 132
 SET q = 0
 DECLARE cs_cd = f8
 DECLARE cs_name = vc
 DECLARE cs_row = i2
 FREE SET source
 RECORD source(
   1 cnt = i2
   1 qual[*]
     2 cd = f8
     2 name = vc
     2 num = i2
 )
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=73
    AND cv.active_ind=1)
  ORDER BY cv.display
  HEAD REPORT
   source->cnt = 0
  DETAIL
   source->cnt = (source->cnt+ 1), stat = alterlist(source->qual,source->cnt), source->qual[source->
   cnt].cd = cv.code_value,
   source->qual[source->cnt].name = cv.display, source->qual[source->cnt].num = source->cnt
  WITH nocounter
 ;end select
#menu
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,131)
 CALL video(n)
 CALL text(2,3,"Location Alias Main Menu")
 CALL text(4,3,"Add Location Aliases")
 CALL text(5,3,"Review Location Aliases")
 CALL text(6,3,"Commit Location Alias Additions to Database")
 CALL text(22,3,"Add/Review/Commit/Exit  (A/R/C/E): ")
 CALL accept(22,38,"p;cu","E")
 SET option_choice = curaccept
 CASE (curaccept)
  OF "A":
   GO TO c_contributor_source
  OF "R":
   GO TO r_contributor_source
  OF "C":
   GO TO database_commit
  OF "E":
   GO TO exit_program
  ELSE
   GO TO menu
 ENDCASE
#c_contributor_source
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,131)
 CALL video(n)
 CALL text(2,3,"Contributor Source List")
 CALL text(3,15,"(Use Arrows to Scroll through List - Enter Row Number")
 CALL text(4,61,'Select "0" to Return to Main Menu)')
 CALL text(6,3,"Row")
 CALL text(6,14,"Contributor Source")
 SET q = (q+ 1)
 SET hold_num = q
 SET w = (q+ 14)
 IF ((w > source->cnt))
  SET w = source->cnt
 ENDIF
 SET z = 6
 FOR (x = q TO w)
   SET z = (z+ 1)
   CALL text(z,3,cnvtstring(source->qual[x].num))
   CALL text(z,14,source->qual[x].name)
 ENDFOR
 CALL text(22,3,"Select Contributor Source: ")
 CALL accept(22,30,"999999999;s",0)
 SET get_more = 0
 SET get_prev = 0
 SET id_found = 0
 CASE (curscroll)
  OF 0:
   SET cs_row = curaccept
   SET id_found = 1
  OF 1:
   SET get_more = 1
  OF 2:
   SET get_prev = 1
  ELSE
   SET q = (q - 1)
   GO TO c_contributor_source
 ENDCASE
 IF (get_prev=1)
  IF (((hold_num - 14) < 1))
   SET q = 0
  ELSE
   SET q = (hold_num - 16)
  ENDIF
  GO TO c_contributor_source
 ENDIF
 IF (get_more=1)
  IF (((hold_num+ 14) >= source->cnt))
   SET q = (q - 1)
  ELSE
   SET q = (hold_num+ 14)
  ENDIF
  GO TO c_contributor_source
 ENDIF
 IF (id_found=1)
  IF (cs_row=0)
   GO TO menu
  ELSE
   FOR (x = 1 TO source->cnt)
     IF (x=cs_row)
      SET cs_name = source->qual[x].name
      SET cs_cd = source->qual[x].cd
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET q = 0
#c_add_location_aliases
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=222
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1)
  DETAIL
   facility_cd = cv.code_value
  WITH nocounter
 ;end select
 FREE SET loc
 RECORD loc(
   1 facility[*]
     2 cd = f8
     2 display = vc
     2 type = vc
     2 building[*]
       3 cd = f8
       3 display = vc
       3 type = vc
       3 unit[*]
         4 cd = f8
         4 display = vc
         4 type = vc
         4 room[*]
           5 cd = f8
           5 display = vc
           5 type = vc
           5 bed[*]
             6 cd = f8
             6 display = vc
             6 type = vc
 )
 SET fcnt = 0
 SET bcnt = 0
 SET ucnt = 0
 SET rcnt = 0
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM location_group lg,
   code_value cv1,
   code_value cv2
  PLAN (lg
   WHERE lg.location_group_type_cd=facility_cd
    AND lg.active_ind=1
    AND lg.root_loc_cd=0)
   JOIN (cv1
   WHERE cv1.code_value=lg.parent_loc_cd)
   JOIN (cv2
   WHERE cv2.code_value=lg.child_loc_cd)
  ORDER BY lg.parent_loc_cd, lg.sequence
  HEAD lg.parent_loc_cd
   bcnt = 0, fcnt = (fcnt+ 1), stat = alterlist(loc->facility,fcnt),
   loc->facility[fcnt].cd = lg.parent_loc_cd, loc->facility[fcnt].display = cv1.display, loc->
   facility[fcnt].type = cv1.cdf_meaning
  DETAIL
   bcnt = (bcnt+ 1), stat = alterlist(loc->facility[fcnt].building,bcnt), loc->facility[fcnt].
   building[bcnt].cd = lg.child_loc_cd,
   loc->facility[fcnt].building[bcnt].display = cv2.display, loc->facility[fcnt].building[bcnt].type
    = cv2.cdf_meaning
  WITH nocounter
 ;end select
 FOR (w = 1 TO fcnt)
  SET bcnt = size(loc->facility[w].building,5)
  IF (bcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(bcnt)),
     location_group lg,
     code_value cv
    PLAN (d)
     JOIN (lg
     WHERE (lg.parent_loc_cd=loc->facility[w].building[d.seq].cd)
      AND lg.active_ind=1
      AND lg.root_loc_cd=0)
     JOIN (cv
     WHERE cv.code_value=lg.child_loc_cd)
    ORDER BY d.seq, lg.sequence
    HEAD d.seq
     ucnt = 0
    DETAIL
     ucnt = (ucnt+ 1), stat = alterlist(loc->facility[w].building[d.seq].unit,ucnt), loc->facility[w]
     .building[d.seq].unit[ucnt].cd = lg.child_loc_cd,
     loc->facility[w].building[d.seq].unit[ucnt].display = cv.display, loc->facility[w].building[d
     .seq].unit[ucnt].type = cv.cdf_meaning
    WITH nocounter
   ;end select
   FOR (x = 1 TO bcnt)
    SET ucnt = size(loc->facility[w].building[x].unit,5)
    IF (ucnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(ucnt)),
       location_group lg,
       code_value cv
      PLAN (d)
       JOIN (lg
       WHERE (lg.parent_loc_cd=loc->facility[w].building[x].unit[d.seq].cd)
        AND lg.active_ind=1
        AND lg.root_loc_cd=0)
       JOIN (cv
       WHERE cv.code_value=lg.child_loc_cd)
      ORDER BY d.seq, lg.sequence
      HEAD d.seq
       rcnt = 0
      DETAIL
       rcnt = (rcnt+ 1), stat = alterlist(loc->facility[w].building[x].unit[d.seq].room,rcnt), loc->
       facility[w].building[x].unit[d.seq].room[rcnt].cd = lg.child_loc_cd,
       loc->facility[w].building[x].unit[d.seq].room[rcnt].display = cv.display, loc->facility[w].
       building[x].unit[d.seq].room[rcnt].type = cv.cdf_meaning
      WITH nocounter
     ;end select
     FOR (y = 1 TO ucnt)
      SET rcnt = size(loc->facility[w].building[x].unit[y].room,5)
      IF (rcnt > 0)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(rcnt)),
         location_group lg,
         code_value cv
        PLAN (d)
         JOIN (lg
         WHERE (lg.parent_loc_cd=loc->facility[w].building[x].unit[y].room[d.seq].cd)
          AND lg.active_ind=1
          AND lg.root_loc_cd=0)
         JOIN (cv
         WHERE cv.code_value=lg.child_loc_cd)
        ORDER BY d.seq, lg.sequence
        HEAD d.seq
         dcnt = 0
        DETAIL
         dcnt = (dcnt+ 1), stat = alterlist(loc->facility[w].building[x].unit[y].room[d.seq].bed,dcnt
          ), loc->facility[w].building[x].unit[y].room[d.seq].bed[dcnt].cd = lg.child_loc_cd,
         loc->facility[w].building[x].unit[y].room[d.seq].bed[dcnt].display = cv.display, loc->
         facility[w].building[x].unit[y].room[d.seq].bed[dcnt].type = cv.cdf_meaning
        WITH nocounter
       ;end select
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 FREE SET outbound
 RECORD outbound(
   1 qual[*]
     2 cd = f8
     2 loc = vc
     2 alias = vc
     2 type = vc
     2 add_ind = i2
 )
 FREE SET inbound
 RECORD inbound(
   1 qual[*]
     2 cd = f8
     2 loc = vc
     2 alias = vc
     2 type = vc
     2 add_ind = i2
 )
 SET ocnt = 0
 SET icnt = 0
 SET fcnt = size(loc->facility,5)
 FOR (a = 1 TO fcnt)
   SET ocnt = (ocnt+ 1)
   SET stat = alterlist(outbound->qual,ocnt)
   SET outbound->qual[ocnt].cd = loc->facility[a].cd
   SET outbound->qual[ocnt].loc = concat(trim(loc->facility[a].display),"(",trim(cnvtstring(loc->
      facility[a].cd)),")")
   SET outbound->qual[ocnt].alias = loc->facility[a].display
   SET outbound->qual[ocnt].type = loc->facility[a].type
   SET outbound->qual[ocnt].add_ind = 1
   SET icnt = (icnt+ 1)
   SET stat = alterlist(inbound->qual,icnt)
   SET inbound->qual[icnt].cd = loc->facility[a].cd
   SET inbound->qual[icnt].loc = concat(trim(loc->facility[a].display),"(",trim(cnvtstring(loc->
      facility[a].cd)),")")
   SET inbound->qual[icnt].alias = loc->facility[a].display
   SET inbound->qual[icnt].type = loc->facility[a].type
   SET inbound->qual[icnt].add_ind = 1
   SET bcnt = size(loc->facility[a].building,5)
   FOR (b = 1 TO bcnt)
     SET ocnt = (ocnt+ 1)
     SET stat = alterlist(outbound->qual,ocnt)
     SET outbound->qual[ocnt].cd = loc->facility[a].building[b].cd
     SET outbound->qual[ocnt].loc = concat(loc->facility[a].building[b].display,"(",trim(cnvtstring(
        loc->facility[a].building[b].cd)),")")
     SET outbound->qual[ocnt].alias = loc->facility[a].building[b].display
     SET outbound->qual[ocnt].type = loc->facility[a].building[b].type
     SET outbound->qual[ocnt].add_ind = 1
     SET icnt = (icnt+ 1)
     SET stat = alterlist(inbound->qual,icnt)
     SET inbound->qual[icnt].cd = loc->facility[a].building[b].cd
     SET inbound->qual[icnt].loc = concat(loc->facility[a].building[b].display,"(",trim(cnvtstring(
        loc->facility[a].building[b].cd)),")")
     SET inbound->qual[icnt].alias = concat(trim(loc->facility[a].display),"^~",trim(loc->facility[a]
       .building[b].display))
     SET inbound->qual[icnt].type = loc->facility[a].building[b].type
     SET inbound->qual[icnt].add_ind = 1
     SET ucnt = size(loc->facility[a].building[b].unit,5)
     FOR (c = 1 TO ucnt)
       SET ocnt = (ocnt+ 1)
       SET stat = alterlist(outbound->qual,ocnt)
       SET outbound->qual[ocnt].cd = loc->facility[a].building[b].unit[c].cd
       SET outbound->qual[ocnt].loc = concat(loc->facility[a].building[b].unit[c].display,"(",trim(
         cnvtstring(loc->facility[a].building[b].unit[c].cd)),")")
       SET outbound->qual[ocnt].alias = loc->facility[a].building[b].unit[c].display
       SET outbound->qual[ocnt].type = loc->facility[a].building[b].unit[c].type
       SET outbound->qual[ocnt].add_ind = 1
       SET icnt = (icnt+ 1)
       SET stat = alterlist(inbound->qual,icnt)
       SET inbound->qual[icnt].cd = loc->facility[a].building[b].unit[c].cd
       SET inbound->qual[icnt].loc = concat(loc->facility[a].building[b].unit[c].display,"(",trim(
         cnvtstring(loc->facility[a].building[b].unit[c].cd)),")")
       SET inbound->qual[icnt].alias = concat(trim(loc->facility[a].display),"^~",trim(loc->facility[
         a].building[b].display),"^~",trim(loc->facility[a].building[b].unit[c].display))
       SET inbound->qual[icnt].type = loc->facility[a].building[b].unit[c].type
       SET inbound->qual[icnt].add_ind = 1
       SET rcnt = size(loc->facility[a].building[b].unit[c].room,5)
       FOR (d = 1 TO rcnt)
         SET ocnt = (ocnt+ 1)
         SET stat = alterlist(outbound->qual,ocnt)
         SET outbound->qual[ocnt].cd = loc->facility[a].building[b].unit[c].room[d].cd
         SET outbound->qual[ocnt].loc = concat(loc->facility[a].building[b].unit[c].room[d].display,
          "(",trim(cnvtstring(loc->facility[a].building[b].unit[c].room[d].cd)),")")
         SET outbound->qual[ocnt].alias = loc->facility[a].building[b].unit[c].room[d].display
         SET outbound->qual[ocnt].type = loc->facility[a].building[b].unit[c].room[d].type
         SET outbound->qual[ocnt].add_ind = 1
         SET icnt = (icnt+ 1)
         SET stat = alterlist(inbound->qual,icnt)
         SET inbound->qual[icnt].cd = loc->facility[a].building[b].unit[c].room[d].cd
         SET inbound->qual[icnt].loc = concat(loc->facility[a].building[b].unit[c].room[d].display,
          "(",trim(cnvtstring(loc->facility[a].building[b].unit[c].room[d].cd)),")")
         SET inbound->qual[icnt].alias = concat(trim(loc->facility[a].display),"^~",trim(loc->
           facility[a].building[b].display),"^~",trim(loc->facility[a].building[b].unit[c].display),
          "^~",trim(loc->facility[a].building[b].unit[c].room[d].display))
         SET inbound->qual[icnt].type = loc->facility[a].building[b].unit[c].room[d].type
         SET inbound->qual[icnt].add_ind = 1
         SET dcnt = size(loc->facility[a].building[b].unit[c].room[d].bed,5)
         FOR (e = 1 TO dcnt)
           SET ocnt = (ocnt+ 1)
           SET stat = alterlist(outbound->qual,ocnt)
           SET outbound->qual[ocnt].cd = loc->facility[a].building[b].unit[c].room[d].bed[e].cd
           SET outbound->qual[ocnt].loc = concat(loc->facility[a].building[b].unit[c].room[d].bed[e].
            display,"(",trim(cnvtstring(loc->facility[a].building[b].unit[c].room[d].bed[e].cd)),")")
           SET outbound->qual[ocnt].alias = loc->facility[a].building[b].unit[c].room[d].bed[e].
           display
           SET outbound->qual[ocnt].type = loc->facility[a].building[b].unit[c].room[d].bed[e].type
           SET outbound->qual[ocnt].add_ind = 1
           SET icnt = (icnt+ 1)
           SET stat = alterlist(inbound->qual,icnt)
           SET inbound->qual[icnt].cd = loc->facility[a].building[b].unit[c].room[d].bed[e].cd
           SET inbound->qual[icnt].loc = concat(loc->facility[a].building[b].unit[c].room[d].bed[e].
            display,"(",trim(cnvtstring(loc->facility[a].building[b].unit[c].room[d].bed[e].cd)),")")
           SET inbound->qual[icnt].alias = concat(trim(loc->facility[a].display),"^~",trim(loc->
             facility[a].building[b].display),"^~",trim(loc->facility[a].building[b].unit[c].display),
            "^~",trim(loc->facility[a].building[b].unit[c].room[d].display),"^~",trim(loc->facility[a
             ].building[b].unit[c].room[d].bed[e].display))
           SET inbound->qual[icnt].type = loc->facility[a].building[b].unit[c].room[d].bed[e].type
           SET inbound->qual[icnt].add_ind = 1
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 IF (ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ocnt)),
    code_value_outbound c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=outbound->qual[d.seq].cd)
     AND c.contributor_source_cd=cs_cd)
   ORDER BY d.seq
   HEAD d.seq
    outbound->qual[d.seq].add_ind = 0
   WITH nocounter
  ;end select
  INSERT  FROM code_value_outbound c,
    (dummyt d  WITH seq = value(ocnt))
   SET c.seq = 1, c.code_value = outbound->qual[d.seq].cd, c.contributor_source_cd = cs_cd,
    c.alias_type_meaning = outbound->qual[d.seq].type, c.code_set = 220, c.alias = outbound->qual[d
    .seq].alias,
    c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id,
    c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (outbound->qual[d.seq].add_ind=1))
    JOIN (c)
   WITH nocounter
  ;end insert
 ENDIF
 IF (icnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(icnt)),
    code_value_alias c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=inbound->qual[d.seq].cd)
     AND c.contributor_source_cd=cs_cd)
   ORDER BY d.seq
   HEAD d.seq
    inbound->qual[d.seq].add_ind = 0
   WITH nocounter
  ;end select
  INSERT  FROM code_value_alias c,
    (dummyt d  WITH seq = value(icnt))
   SET c.seq = 1, c.code_value = inbound->qual[d.seq].cd, c.contributor_source_cd = cs_cd,
    c.alias_type_meaning = inbound->qual[d.seq].type, c.code_set = 220, c.alias = inbound->qual[d.seq
    ].alias,
    c.primary_ind = null, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
    c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (inbound->qual[d.seq].add_ind=1))
    JOIN (c)
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "ccluserdir:location_alias.log"
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   add_line = fillstring(20," ")
  DETAIL
   col 1, "Location Alias Update Log", row + 1,
   col 1, curdate, " ",
   curtime, row + 2, col 1,
   "Contributor Source: ", cs_name, row + 2,
   col 1, "Location", col 35,
   "Alias Type", col 47, "Alias",
   col 110, "Status", row + 1
   FOR (x = 1 TO ocnt)
     col 1, outbound->qual[x].loc, col 35,
     "Outbound", col 47, outbound->qual[x].alias
     IF ((outbound->qual[x].add_ind=1))
      add_line = "Added"
     ELSE
      add_line = "Already Defined"
     ENDIF
     col 110, add_line, row + 1,
     col 1, inbound->qual[x].loc, col 35,
     "Inbound", col 47, inbound->qual[x].alias
     IF ((inbound->qual[x].add_ind=1))
      add_line = "Added"
     ELSE
      add_line = "Already Defined"
     ENDIF
     col 110, add_line, row + 1
   ENDFOR
  WITH nocounter
 ;end select
 GO TO menu
#r_contributor_source
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,131)
 CALL video(n)
 CALL text(2,3,"Contributor Source List")
 CALL text(3,15,"(Use Arrows to Scroll through List - Enter Row Number")
 CALL text(4,61,'Select "0" to Return to Main Menu)')
 CALL text(6,3,"Row")
 CALL text(6,14,"Contributor Source")
 SET q = (q+ 1)
 SET hold_num = q
 SET w = (q+ 14)
 IF ((w > source->cnt))
  SET w = source->cnt
 ENDIF
 SET z = 6
 FOR (x = q TO w)
   SET z = (z+ 1)
   CALL text(z,3,cnvtstring(source->qual[x].num))
   CALL text(z,14,source->qual[x].name)
 ENDFOR
 CALL text(22,3,"Select Contributor Source: ")
 CALL accept(22,30,"999999999;s",0)
 SET get_more = 0
 SET get_prev = 0
 SET id_found = 0
 CASE (curscroll)
  OF 0:
   SET cs_row = curaccept
   SET id_found = 1
  OF 1:
   SET get_more = 1
  OF 2:
   SET get_prev = 1
  ELSE
   SET q = (q - 1)
   GO TO r_contributor_source
 ENDCASE
 IF (get_prev=1)
  IF (((hold_num - 14) < 1))
   SET q = 0
  ELSE
   SET q = (hold_num - 16)
  ENDIF
  GO TO r_contributor_source
 ENDIF
 IF (get_more=1)
  IF (((hold_num+ 14) >= source->cnt))
   SET q = (q - 1)
  ELSE
   SET q = (hold_num+ 14)
  ENDIF
  GO TO r_contributor_source
 ENDIF
 IF (id_found=1)
  IF (cs_row=0)
   GO TO menu
  ELSE
   FOR (x = 1 TO source->cnt)
     IF (x=cs_row)
      SET cs_name = source->qual[x].name
      SET cs_cd = source->qual[x].cd
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET q = 0
#r_review_loc_alias
 FREE SET cds
 RECORD cds(
   1 qual[*]
     2 cd = f8
 )
 SET ccnt = 0
 SELECT INTO "nl:"
  FROM code_value_alias cva
  PLAN (cva
   WHERE cva.contributor_source_cd=cs_cd
    AND cva.code_set=220)
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(cds->qual,ccnt), cds->qual[ccnt].cd = cva.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_outbound cvo
  PLAN (cvo
   WHERE cvo.contributor_source_cd=cs_cd
    AND cvo.code_set=220)
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(cds->qual,ccnt), cds->qual[ccnt].cd = cvo.code_value
  WITH nocounter
 ;end select
 FREE SET rev
 RECORD rev(
   1 qual[*]
     2 loc = vc
     2 inalias = vc
     2 outalias = vc
 )
 SET rcnt = 0
 IF (ccnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    code_value cv,
    code_value_alias cva,
    code_value_outbound cvo
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=cds->qual[d.seq].cd))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value))
    JOIN (cvo
    WHERE cvo.code_value=outerjoin(cv.code_value))
   ORDER BY cv.code_value
   HEAD cv.code_value
    rcnt = (rcnt+ 1), stat = alterlist(rev->qual,rcnt), rev->qual[rcnt].loc = concat(trim(cv.display),
     "(",trim(cnvtstring(cv.code_value)),")"),
    rev->qual[rcnt].inalias = cva.alias, rev->qual[rcnt].outalias = cvo.alias
   WITH nocounter
  ;end select
 ENDIF
#r_list_loc_alias
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,23,131)
 CALL video(n)
 CALL text(2,3,"Location Aliases")
 CALL text(3,15,"(Use Arrows keys to Scroll through Location Aliases)")
 CALL text(5,3,"LOCATION")
 CALL text(5,40,"INBOUND ALIAS")
 CALL text(5,100,"OUTBOUND ALIAS")
 SET q = (q+ 1)
 SET hold_num = q
 SET w = (q+ 14)
 IF (w > rcnt)
  SET w = rcnt
 ENDIF
 SET z = 5
 FOR (x = q TO w)
   SET z = (z+ 1)
   CALL text(z,3,rev->qual[x].loc)
   CALL text(z,40,rev->qual[x].inalias)
   CALL text(z,100,rev->qual[x].outalias)
 ENDFOR
 CALL text(22,3,"Press RETURN to Exit: ")
 CALL accept(22,25,"9;s",0)
 SET get_more = 0
 SET get_prev = 0
 CASE (curscroll)
  OF 0:
   SET q = 0
   GO TO menu
  OF 1:
   SET get_more = 1
  OF 2:
   SET get_prev = 1
  ELSE
   SET q = (q - 1)
   GO TO r_list_loc_alias
 ENDCASE
 IF (get_prev=1)
  IF (((hold_num - 14) < 1))
   SET q = 0
  ELSE
   SET q = (hold_num - 16)
  ENDIF
  GO TO r_list_loc_alias
 ENDIF
 IF (get_more=1)
  IF (((hold_num+ 14) >= rev->cnt))
   SET q = (q - 1)
  ELSE
   SET q = (hold_num+ 14)
  ENDIF
  GO TO r_list_loc_alias
 ENDIF
#database_commit
 COMMIT
 GO TO menu
#exit_program
 CALL clear(1,1)
END GO
