CREATE PROGRAM br_rpt_serv_res_info:dba
 FREE RECORD temp
 RECORD temp(
   1 client = vc
   1 user = vc
   1 i_cnt = i2
   1 ilist[*]
     2 inst_cd = f8
     2 inst_name = vc
     2 d_cnt = i2
     2 dlist[*]
       3 dept_cd = f8
       3 dept_name = vc
       3 s_cnt = i2
       3 slist[*]
         4 sect_cd = f8
         4 sect_name = vc
         4 ss_cnt = i2
         4 sslist[*]
           5 subsect_cd = f8
           5 subsect_name = vc
           5 r_cnt = i2
           5 rlist[*]
             6 res_cd = f8
             6 res_name = vc
 )
 DECLARE institution = f8 WITH public, noconstant(0.0)
 DECLARE instrument = f8 WITH public, noconstant(0.0)
 DECLARE bench = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTITUTION")
  DETAIL
   institution = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="BENCH")
  DETAIL
   bench = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=223
    AND cv.cdf_meaning="INSTRUMENT")
  DETAIL
   instrument = cv.code_value
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
 SELECT DISTINCT INTO "nl:"
  FROM service_resource sr,
   code_value cv
  PLAN (sr
   WHERE sr.organization_id > 9999999
    AND sr.service_resource_type_cd=institution
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.service_resource_cd)
  HEAD REPORT
   i_cnt = 0
  HEAD sr.service_resource_cd
   i_cnt = (i_cnt+ 1), temp->i_cnt = i_cnt, stat = alterlist(temp->ilist,i_cnt),
   temp->ilist[i_cnt].inst_cd = sr.service_resource_cd, temp->ilist[i_cnt].inst_name = concat(trim(cv
     .description),"/",trim(cv.display))
  WITH nocounter
 ;end select
 FOR (y = 1 TO temp->i_cnt)
   SET d_cnt = 0
   SELECT INTO "nl:"
    FROM resource_group rg,
     code_value cv
    PLAN (rg
     WHERE (rg.parent_service_resource_cd=temp->ilist[y].inst_cd)
      AND rg.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=rg.child_service_resource_cd)
    ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd
    HEAD REPORT
     d_cnt = 0
    HEAD rg.child_service_resource_cd
     d_cnt = (d_cnt+ 1), temp->ilist[y].d_cnt = d_cnt, stat = alterlist(temp->ilist[y].dlist,d_cnt),
     temp->ilist[y].dlist[d_cnt].dept_cd = rg.child_service_resource_cd, temp->ilist[y].dlist[d_cnt].
     dept_name = concat(trim(cv.description),"/",trim(cv.display))
    WITH nocounter
   ;end select
   FOR (z = 1 TO temp->ilist[y].d_cnt)
     SET s_cnt = 0
     SELECT INTO "nl:"
      FROM resource_group rg,
       code_value cv
      PLAN (rg
       WHERE (rg.parent_service_resource_cd=temp->ilist[y].dlist[z].dept_cd)
        AND rg.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=rg.child_service_resource_cd)
      ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd
      HEAD REPORT
       s_cnt = 0
      HEAD rg.child_service_resource_cd
       s_cnt = (s_cnt+ 1), temp->ilist[y].dlist[z].s_cnt = s_cnt, stat = alterlist(temp->ilist[y].
        dlist[z].slist,s_cnt),
       temp->ilist[y].dlist[z].slist[s_cnt].sect_cd = rg.child_service_resource_cd, temp->ilist[y].
       dlist[z].slist[s_cnt].sect_name = concat(trim(cv.description),"/",trim(cv.display))
      WITH nocounter
     ;end select
     FOR (w = 1 TO temp->ilist[y].dlist[z].s_cnt)
       SET ss_cnt = 0
       SELECT INTO "nl:"
        FROM resource_group rg,
         code_value cv
        PLAN (rg
         WHERE (rg.parent_service_resource_cd=temp->ilist[y].dlist[z].slist[w].sect_cd)
          AND rg.active_ind=1)
         JOIN (cv
         WHERE cv.code_value=rg.child_service_resource_cd)
        ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd
        HEAD REPORT
         ss_cnt = 0
        HEAD rg.child_service_resource_cd
         ss_cnt = (ss_cnt+ 1), temp->ilist[y].dlist[z].slist[w].ss_cnt = ss_cnt, stat = alterlist(
          temp->ilist[y].dlist[z].slist[w].sslist,ss_cnt),
         temp->ilist[y].dlist[z].slist[w].sslist[ss_cnt].subsect_cd = rg.child_service_resource_cd,
         temp->ilist[y].dlist[z].slist[w].sslist[ss_cnt].subsect_name = concat(trim(cv.description),
          "/",trim(cv.display))
        WITH nocounter
       ;end select
       FOR (v = 1 TO temp->ilist[y].dlist[z].slist[w].ss_cnt)
        SET r_cnt = 0
        SELECT INTO "nl:"
         FROM resource_group rg,
          service_resource sr,
          code_value cv
         PLAN (rg
          WHERE (rg.parent_service_resource_cd=temp->ilist[y].dlist[z].slist[w].sslist[v].subsect_cd)
           AND rg.active_ind=1)
          JOIN (sr
          WHERE sr.service_resource_cd=rg.child_service_resource_cd
           AND sr.active_ind=1)
          JOIN (cv
          WHERE cv.code_value=rg.child_service_resource_cd)
         ORDER BY rg.parent_service_resource_cd, rg.child_service_resource_cd
         HEAD REPORT
          r_cnt = 0
         HEAD rg.child_service_resource_cd
          r_cnt = (r_cnt+ 1), temp->ilist[y].dlist[z].slist[w].sslist[v].r_cnt = r_cnt, stat =
          alterlist(temp->ilist[y].dlist[z].slist[w].sslist[v].rlist,r_cnt),
          temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].res_cd = rg
          .child_service_resource_cd, temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].
          res_name = concat(trim(cv.description),"/",trim(cv.display))
          IF (sr.service_resource_type_cd=bench)
           temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].res_name = concat(trim(temp->
             ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].res_name)," (BENCH)")
          ELSEIF (sr.service_resource_type_cd=instrument)
           temp->ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].res_name = concat(trim(temp->
             ilist[y].dlist[z].slist[w].sslist[v].rlist[r_cnt].res_name)," (INSTRUMENT)")
          ENDIF
         WITH nocounter
        ;end select
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
   CALL print(calcpos(xcol,ycol)), "{b}Report Name: {endb}Service Resource Audit", row + 1,
   ycol = (ycol+ 20),
   CALL print(calcpos(xcol,ycol)), "{b}Institution",
   row + 1, ycol = (ycol+ 10), xcol = 65,
   CALL print(calcpos(xcol,ycol)), "{b}Department", row + 1,
   ycol = (ycol+ 10), xcol = 110,
   CALL print(calcpos(xcol,ycol)),
   "{b}Section", row + 1, ycol = (ycol+ 10),
   xcol = 155,
   CALL print(calcpos(xcol,ycol)), "{b}SubSection",
   row + 1, ycol = (ycol+ 10), xcol = 200,
   CALL print(calcpos(xcol,ycol)), "{b}Bench/Instrument", row + 1,
   ycol = (ycol+ 10), xcol = 20,
   CALL print(calcpos(xcol,ycol)),
   "___________________________________________________________________",
   "__________________________", row + 1,
   ycol = (ycol+ 10), "{cpi/15}", row + 1
  DETAIL
   FOR (y = 1 TO temp->i_cnt)
     xcol = 20,
     CALL print(calcpos(xcol,ycol)), temp->ilist[y].inst_name,
     row + 1, ycol = (ycol+ 10)
     IF (ycol > 700)
      BREAK
     ENDIF
     FOR (z = 1 TO temp->ilist[y].d_cnt)
       xcol = 65,
       CALL print(calcpos(xcol,ycol)), temp->ilist[y].dlist[z].dept_name,
       row + 1, ycol = (ycol+ 10)
       IF (ycol > 700)
        BREAK
       ENDIF
       FOR (w = 1 TO temp->ilist[y].dlist[z].s_cnt)
         xcol = 110,
         CALL print(calcpos(xcol,ycol)), temp->ilist[y].dlist[z].slist[w].sect_name,
         row + 1, ycol = (ycol+ 10)
         IF (ycol > 700)
          BREAK
         ENDIF
         FOR (u = 1 TO temp->ilist[y].dlist[z].slist[w].ss_cnt)
           xcol = 155,
           CALL print(calcpos(xcol,ycol)), temp->ilist[y].dlist[z].slist[w].sslist[u].subsect_name,
           row + 1, ycol = (ycol+ 10)
           IF (ycol > 700)
            BREAK
           ENDIF
           FOR (v = 1 TO temp->ilist[y].dlist[z].slist[w].sslist[u].r_cnt)
             xcol = 200,
             CALL print(calcpos(xcol,ycol)), temp->ilist[y].dlist[z].slist[w].sslist[u].rlist[v].
             res_name,
             row + 1, ycol = (ycol+ 10)
             IF (ycol > 700)
              BREAK
             ENDIF
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
     IF ((y=temp->i_cnt))
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
