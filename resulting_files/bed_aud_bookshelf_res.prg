CREATE PROGRAM bed_aud_bookshelf_res
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 list[*]
     2 book_id = f8
     2 book_disp = vc
     2 res[*]
       3 res_code = f8
       3 res_disp = vc
       3 gen = vc
       3 pid = f8
       3 pdisp = vc
       3 srv_res_code = f8
       3 srv_res_disp = vc
     2 sec[*]
       3 book_id = f8
       3 book_disp = vc
       3 res[*]
         4 res_code = f8
         4 res_disp = vc
         4 gen = vc
         4 pid = f8
         4 pdisp = vc
         4 srv_res_code = f8
         4 srv_res_disp = vc
       3 thr[*]
         4 book_id = f8
         4 book_disp = vc
         4 res[*]
           5 res_code = f8
           5 res_disp = vc
           5 gen = vc
           5 pid = f8
           5 pdisp = vc
           5 srv_res_code = f8
           5 srv_res_disp = vc
 )
 FREE SET temp2
 RECORD temp2(
   1 child[*]
     2 book_id = f8
     2 book_disp = vc
     2 res[*]
       3 res_code = f8
       3 res_disp = vc
       3 gen = vc
       3 pid = f8
       3 pdisp = vc
       3 srv_res_code = f8
       3 srv_res_disp = vc
   1 chil_flex[*]
     2 book_id = f8
     2 book_disp = vc
 )
 SET level = 2
 SET levels = 3
 SET row_cnt = 0
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM sch_appt_book b,
   sch_book_list l2,
   sch_resource s
  PLAN (b
   WHERE b.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    l.appt_book_id
    FROM sch_book_list l
    WHERE l.child_appt_book_id=b.appt_book_id
     AND l.active_ind=1))))
   JOIN (l2
   WHERE l2.appt_book_id=b.appt_book_id
    AND l2.active_ind=1)
   JOIN (s
   WHERE s.resource_cd=outerjoin(l2.resource_cd)
    AND s.resource_cd > outerjoin(0)
    AND s.active_ind=outerjoin(1))
  ORDER BY b.mnemonic, l2.seq_nbr
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp->list,100)
  HEAD b.mnemonic
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp->list,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp->list[tot_cnt].book_id = b.appt_book_id, temp->list[tot_cnt].book_disp = b.mnemonic, scnt = 0,
   stot_cnt = 0, rcnt = 0, rtot_cnt = 0,
   stat = alterlist(temp->list[tot_cnt].res,100), stat = alterlist(temp->list[tot_cnt].sec,100)
  DETAIL
   CALL echo(build("mainbooks--",b.mnemonic))
   IF (l2.child_appt_book_id > 0)
    scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
    IF (scnt > 100)
     stat = alterlist(temp->list[tot_cnt].sec,(stot_cnt+ 100)), scnt = 1
    ENDIF
    temp->list[tot_cnt].sec[stot_cnt].book_id = l2.child_appt_book_id
   ENDIF
  FOOT  b.mnemonic
   stat = alterlist(temp->list[tot_cnt].res,rtot_cnt), stat = alterlist(temp->list[tot_cnt].sec,
    stot_cnt)
  FOOT REPORT
   stat = alterlist(temp->list,tot_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO tot_cnt)
   SET res_size = size(temp->list[x].res,5)
   SET sec_size = size(temp->list[x].sec,5)
   IF (sec_size > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(sec_size)),
      sch_appt_book b,
      sch_book_list l,
      sch_resource s
     PLAN (d)
      JOIN (b
      WHERE (b.appt_book_id=temp->list[x].sec[d.seq].book_id)
       AND b.active_ind=1)
      JOIN (l
      WHERE l.appt_book_id=b.appt_book_id
       AND l.active_ind=1)
      JOIN (s
      WHERE s.resource_cd=outerjoin(l.resource_cd)
       AND s.resource_cd > outerjoin(0)
       AND s.active_ind=outerjoin(1))
     ORDER BY d.seq, l.seq_nbr
     HEAD d.seq
      scnt = 0, stot_cnt = 0, rcnt = 0,
      rtot_cnt = 0, stat = alterlist(temp->list[x].sec[d.seq].res,100), stat = alterlist(temp->list[x
       ].sec[d.seq].thr,100),
      temp->list[x].sec[d.seq].book_disp = b.mnemonic
     DETAIL
      IF (l.child_appt_book_id > 0)
       scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
       IF (scnt > 100)
        stat = alterlist(temp->list[x].sec[d.seq].thr,(stot_cnt+ 100)), scnt = 1
       ENDIF
       temp->list[x].sec[d.seq].thr[stot_cnt].book_id = l.child_appt_book_id
      ENDIF
     FOOT  d.seq
      stat = alterlist(temp->list[x].sec[d.seq].res,rtot_cnt), stat = alterlist(temp->list[x].sec[d
       .seq].thr,stot_cnt)
     WITH nocounter
    ;end select
    FOR (y = 1 TO sec_size)
      SET res_size = size(temp->list[x].sec[y].res,5)
      SET thr_size = size(temp->list[x].sec[y].thr,5)
      IF (thr_size > 0)
       FOR (z = 1 TO thr_size)
         SET childbookid = temp->list[x].sec[y].thr[z].book_id
         SET eset_parse = build("b.appt_book_id IN (",childbookid,")")
         SET stat = alterlist(temp2->child,100)
         SET totcnt = 1
         SET lst = 1
         SET rtot_cnt = 1
         SET rcnt = 1
         SET res_ind = 0
         WHILE (res_ind=0)
           SET level = (level+ 1)
           CALL echo(build("level",level))
           SET res_ind = 1
           SELECT INTO "nl:"
            FROM sch_appt_book b,
             sch_book_list l,
             sch_resource s,
             prsnl p,
             code_value c
            PLAN (b
             WHERE parser(eset_parse)
              AND b.active_ind=1)
             JOIN (l
             WHERE l.appt_book_id=b.appt_book_id
              AND l.active_ind=1)
             JOIN (s
             WHERE s.resource_cd=outerjoin(l.resource_cd)
              AND s.resource_cd > outerjoin(0)
              AND s.active_ind=outerjoin(1))
             JOIN (c
             WHERE c.code_value=outerjoin(s.service_resource_cd)
              AND c.active_ind=outerjoin(1))
             JOIN (p
             WHERE p.person_id=outerjoin(s.person_id)
              AND p.active_ind=outerjoin(1))
            ORDER BY b.mnemonic, l.seq_nbr
            HEAD REPORT
             chcnt = 0, cht_cnt = 0, rtot_cnt = 0,
             rcnt = 0, stat = alterlist(temp2->child,100)
            HEAD b.mnemonic
             chcnt = (chcnt+ 1), cht_cnt = (cht_cnt+ 1)
             IF (chcnt > 100)
              stat = alterlist(temp2->child,(cht_cnt+ 100)), chcnt = 1
             ENDIF
             eset_parse = "b.appt_book_id IN (", comma_ind = 0, stat = alterlist(temp2->child[cht_cnt
              ].res,100),
             temp2->child[cht_cnt].book_disp = b.mnemonic,
             CALL echo(build("--",b.mnemonic)), res_ind = 0
            DETAIL
             IF (s.resource_cd > 0)
              res_ind = 1, rtot_cnt = (rtot_cnt+ 1), rcnt = (rcnt+ 1)
              IF (rtot_cnt > 100)
               stat = alterlist(temp2->child[cht_cnt].res,(rcnt+ 100)), rtot_cnt = 1
              ENDIF
              temp2->child[cht_cnt].res[rcnt].res_code = s.resource_cd, temp2->child[cht_cnt].res[
              rcnt].srv_res_code = s.service_resource_cd, temp2->child[cht_cnt].res[rcnt].res_disp =
              s.mnemonic,
              temp2->child[cht_cnt].res[rcnt].pid = s.person_id
              IF (s.res_type_flag=1)
               temp2->child[cht_cnt].res[rcnt].gen = "Yes"
              ELSE
               temp2->child[cht_cnt].res[rcnt].gen = "No"
              ENDIF
              IF (c.code_value > 0)
               temp2->child[cht_cnt].res[rcnt].srv_res_disp = c.display
              ELSEIF (p.person_id > 0)
               temp2->child[cht_cnt].res[rcnt].pdisp = p.name_full_formatted
              ENDIF
             ENDIF
             IF (l.child_appt_book_id > 0)
              res_ind = 0
              IF (comma_ind=0)
               eset_parse = build(eset_parse,l.child_appt_book_id), comma_ind = 1
              ELSE
               eset_parse = build(eset_parse,",",l.child_appt_book_id)
              ENDIF
             ENDIF
             eset_parse = build(eset_parse,")")
            FOOT  b.mnemonic
             stat = alterlist(temp2->child[cht_cnt].res,rcnt)
            FOOT REPORT
             stat = alterlist(temp2->child,cht_cnt)
            WITH nocounter
           ;end select
         ENDWHILE
         IF (level > levels)
          SET levels = level
         ENDIF
         SET level = 2
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL echo(build("levels-",levels))
 SET col_cnt = (levels+ 4)
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Main Bookshelf"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Secondary Bookshelf (If applicable)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 IF (levels > 3)
  FOR (i = 3 TO (levels - 1))
    SET reply->collist[i].header_text = build2("Bookshelf  ",cnvtstring(i))
    SET reply->collist[i].data_type = 1
    SET reply->collist[i].hide_ind = 0
  ENDFOR
 ENDIF
 SET reply->collist[levels].header_text = "Appointment Book"
 SET reply->collist[levels].data_type = 1
 SET reply->collist[levels].hide_ind = 0
 SET reply->collist[(col_cnt - 3)].header_text = "Generic?"
 SET reply->collist[(col_cnt - 3)].data_type = 1
 SET reply->collist[(col_cnt - 3)].hide_ind = 0
 SET reply->collist[(col_cnt - 2)].header_text = "Resource Display"
 SET reply->collist[(col_cnt - 2)].data_type = 1
 SET reply->collist[(col_cnt - 2)].hide_ind = 0
 SET reply->collist[(col_cnt - 1)].header_text = "Personnel (from Core)"
 SET reply->collist[(col_cnt - 1)].data_type = 1
 SET reply->collist[(col_cnt - 1)].hide_ind = 0
 SET reply->collist[col_cnt].header_text = "Service Resource (from Core)"
 SET reply->collist[col_cnt].data_type = 1
 SET reply->collist[col_cnt].hide_ind = 0
 SET row_cnt = 0
 SET tot_cnt = 0
 SET child_id = 0
 SELECT INTO "nl:"
  FROM sch_appt_book b,
   sch_book_list l2,
   sch_resource s
  PLAN (b
   WHERE b.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    l.appt_book_id
    FROM sch_book_list l
    WHERE l.child_appt_book_id=b.appt_book_id
     AND l.active_ind=1))))
   JOIN (l2
   WHERE l2.appt_book_id=b.appt_book_id
    AND l2.active_ind=1)
   JOIN (s
   WHERE s.resource_cd=outerjoin(l2.resource_cd)
    AND s.resource_cd > outerjoin(0)
    AND s.active_ind=outerjoin(1))
  ORDER BY b.mnemonic, l2.seq_nbr
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp->list,100)
  HEAD b.mnemonic
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp->list,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp->list[tot_cnt].book_id = b.appt_book_id, temp->list[tot_cnt].book_disp = b.mnemonic, scnt = 0,
   stot_cnt = 0, rcnt = 0, rtot_cnt = 0,
   stat = alterlist(temp->list[tot_cnt].res,100), stat = alterlist(temp->list[tot_cnt].sec,100)
  DETAIL
   CALL echo(build("mainbooks--",b.mnemonic))
   IF (s.resource_cd > 0)
    rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
    IF (rcnt > 100)
     stat = alterlist(temp->list[tot_cnt].res,(rtot_cnt+ 100)), rcnt = 1
    ENDIF
    temp->list[tot_cnt].res[rtot_cnt].res_code = s.resource_cd, temp->list[tot_cnt].res[rtot_cnt].
    srv_res_code = s.service_resource_cd, temp->list[tot_cnt].res[rtot_cnt].res_disp = s.mnemonic,
    temp->list[tot_cnt].res[rtot_cnt].pid = s.person_id
    IF (s.res_type_flag=1)
     temp->list[tot_cnt].res[rtot_cnt].gen = "Yes"
    ELSE
     temp->list[tot_cnt].res[rtot_cnt].gen = "No"
    ENDIF
   ELSEIF (l2.child_appt_book_id > 0)
    scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
    IF (scnt > 100)
     stat = alterlist(temp->list[tot_cnt].sec,(stot_cnt+ 100)), scnt = 1
    ENDIF
    temp->list[tot_cnt].sec[stot_cnt].book_id = l2.child_appt_book_id
   ENDIF
  FOOT  b.mnemonic
   stat = alterlist(temp->list[tot_cnt].res,rtot_cnt), stat = alterlist(temp->list[tot_cnt].sec,
    stot_cnt)
  FOOT REPORT
   stat = alterlist(temp->list,tot_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO tot_cnt)
   SET res_size = size(temp->list[x].res,5)
   IF (res_size > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(res_size)),
      prsnl p
     PLAN (d
      WHERE (temp->list[x].res[d.seq].pid > 0))
      JOIN (p
      WHERE (p.person_id=temp->list[x].res[d.seq].pid)
       AND p.active_ind=1)
     ORDER BY d.seq
     DETAIL
      temp->list[x].res[d.seq].pdisp = p.name_full_formatted
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(res_size)),
      code_value c
     PLAN (d
      WHERE (temp->list[x].res[d.seq].srv_res_code > 0))
      JOIN (c
      WHERE (c.code_value=temp->list[x].res[d.seq].srv_res_code)
       AND c.active_ind=1)
     ORDER BY d.seq
     DETAIL
      temp->list[x].res[d.seq].srv_res_disp = c.display
     WITH nocounter
    ;end select
    CALL echo(build("levels",levels))
    SET rsize = size(temp->list[x].res,5)
    SET stat = alterlist(reply->rowlist,(row_cnt+ rsize))
    FOR (a = 1 TO rsize)
      SET row_cnt = (row_cnt+ 1)
      SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
      SET reply->rowlist[row_cnt].celllist[1].string_value = temp->list[x].book_disp
      SET reply->rowlist[row_cnt].celllist[2].string_value = ""
      IF (levels > 3)
       FOR (i = 3 TO (levels - 1))
         SET reply->rowlist[row_cnt].celllist[i].string_value = ""
       ENDFOR
      ENDIF
      SET reply->rowlist[row_cnt].celllist[levels].string_value = temp->list[x].book_disp
      SET reply->rowlist[row_cnt].celllist[(col_cnt - 3)].string_value = temp->list[x].res[a].gen
      SET reply->rowlist[row_cnt].celllist[(col_cnt - 2)].string_value = temp->list[x].res[a].
      res_disp
      SET reply->rowlist[row_cnt].celllist[(col_cnt - 1)].string_value = temp->list[x].res[a].pdisp
      SET reply->rowlist[row_cnt].celllist[col_cnt].string_value = temp->list[x].res[a].srv_res_disp
    ENDFOR
   ENDIF
   SET sec_size = size(temp->list[x].sec,5)
   IF (sec_size > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(sec_size)),
      sch_appt_book b,
      sch_book_list l,
      sch_resource s
     PLAN (d)
      JOIN (b
      WHERE (b.appt_book_id=temp->list[x].sec[d.seq].book_id)
       AND b.active_ind=1)
      JOIN (l
      WHERE l.appt_book_id=b.appt_book_id
       AND l.active_ind=1)
      JOIN (s
      WHERE s.resource_cd=outerjoin(l.resource_cd)
       AND s.resource_cd > outerjoin(0)
       AND s.active_ind=outerjoin(1))
     ORDER BY d.seq, l.seq_nbr
     HEAD d.seq
      scnt = 0, stot_cnt = 0, rcnt = 0,
      rtot_cnt = 0, stat = alterlist(temp->list[x].sec[d.seq].res,100), stat = alterlist(temp->list[x
       ].sec[d.seq].thr,100),
      temp->list[x].sec[d.seq].book_disp = b.mnemonic
     DETAIL
      IF (s.resource_cd > 0)
       rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
       IF (rcnt > 100)
        stat = alterlist(temp->list[x].sec[d.seq].res,(rtot_cnt+ 100)), rcnt = 1
       ENDIF
       temp->list[x].sec[d.seq].res[rtot_cnt].res_code = s.resource_cd, temp->list[x].sec[d.seq].res[
       rtot_cnt].srv_res_code = s.service_resource_cd, temp->list[x].sec[d.seq].res[rtot_cnt].
       res_disp = s.mnemonic,
       temp->list[x].sec[d.seq].res[rtot_cnt].pid = s.person_id
       IF (s.res_type_flag=1)
        temp->list[x].sec[d.seq].res[rtot_cnt].gen = "Yes"
       ELSE
        temp->list[x].sec[d.seq].res[rtot_cnt].gen = "No"
       ENDIF
      ENDIF
      IF (l.child_appt_book_id > 0)
       scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
       IF (scnt > 100)
        stat = alterlist(temp->list[x].sec[d.seq].thr,(stot_cnt+ 100)), scnt = 1
       ENDIF
       temp->list[x].sec[d.seq].thr[stot_cnt].book_id = l.child_appt_book_id
      ENDIF
     FOOT  d.seq
      stat = alterlist(temp->list[x].sec[d.seq].res,rtot_cnt), stat = alterlist(temp->list[x].sec[d
       .seq].thr,stot_cnt)
     WITH nocounter
    ;end select
    FOR (y = 1 TO sec_size)
      SET res_size = size(temp->list[x].sec[y].res,5)
      IF (res_size > 0)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(res_size)),
         prsnl p
        PLAN (d
         WHERE (temp->list[x].sec[y].res[d.seq].pid > 0))
         JOIN (p
         WHERE (p.person_id=temp->list[x].res[d.seq].pid)
          AND p.active_ind=1)
        ORDER BY d.seq
        DETAIL
         temp->list[x].sec[y].res[d.seq].pdisp = p.name_full_formatted
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(res_size)),
         code_value c
        PLAN (d
         WHERE (temp->list[x].sec[y].res[d.seq].srv_res_code > 0))
         JOIN (c
         WHERE (c.code_value=temp->list[x].sec[y].res[d.seq].srv_res_code)
          AND c.active_ind=1)
        ORDER BY d.seq
        DETAIL
         temp->list[x].sec[y].res[d.seq].srv_res_disp = c.display
        WITH nocounter
       ;end select
       SET stat = alterlist(reply->rowlist,(row_cnt+ res_size))
       FOR (b = 1 TO res_size)
         SET row_cnt = (row_cnt+ 1)
         SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
         SET reply->rowlist[row_cnt].celllist[1].string_value = temp->list[x].book_disp
         SET reply->rowlist[row_cnt].celllist[2].string_value = ""
         IF (levels > 3)
          FOR (i = 3 TO (levels - 1))
            SET reply->rowlist[row_cnt].celllist[i].string_value = ""
          ENDFOR
         ENDIF
         SET reply->rowlist[row_cnt].celllist[levels].string_value = temp->list[x].sec[y].book_disp
         SET reply->rowlist[row_cnt].celllist[(col_cnt - 3)].string_value = temp->list[x].sec[y].res[
         b].gen
         SET reply->rowlist[row_cnt].celllist[(col_cnt - 2)].string_value = temp->list[x].sec[y].res[
         b].res_disp
         SET reply->rowlist[row_cnt].celllist[(col_cnt - 1)].string_value = temp->list[x].sec[y].res[
         b].pdisp
         SET reply->rowlist[row_cnt].celllist[col_cnt].string_value = temp->list[x].sec[y].res[b].
         srv_res_disp
       ENDFOR
      ENDIF
      SET thr_size = size(temp->list[x].sec[y].thr,5)
      IF (thr_size > 0)
       FOR (z = 1 TO thr_size)
         SET childbookid = temp->list[x].sec[y].thr[z].book_id
         SET eset_parse = build("b.appt_book_id IN (",childbookid,")")
         SET totcnt = 1
         SET lst = 1
         SET rtot_cnt = 1
         SET rcnt = 1
         SET res_ind = 0
         SET cv = 0
         WHILE (res_ind=0)
          SET res_ind = 1
          SELECT INTO "nl:"
           FROM sch_appt_book b,
            sch_book_list l,
            sch_resource s,
            prsnl p,
            code_value c
           PLAN (b
            WHERE parser(eset_parse)
             AND b.active_ind=1)
            JOIN (l
            WHERE l.appt_book_id=b.appt_book_id
             AND l.active_ind=1)
            JOIN (s
            WHERE s.resource_cd=outerjoin(l.resource_cd)
             AND s.resource_cd > outerjoin(0)
             AND s.active_ind=outerjoin(1))
            JOIN (c
            WHERE c.code_value=outerjoin(s.service_resource_cd)
             AND c.active_ind=outerjoin(1))
            JOIN (p
            WHERE p.person_id=outerjoin(s.person_id)
             AND p.active_ind=outerjoin(1))
           ORDER BY b.mnemonic, l.seq_nbr
           HEAD REPORT
            chcnt = 0, cht_cnt = 0, r_cnt = 0,
            rcont = 0, stat = alterlist(temp2->child,100), stat = alterlist(temp2->chil_flex,100)
           HEAD b.mnemonic
            cv = (cv+ 1),
            CALL echo(build("cv-",cv)),
            CALL echo(build("temp2->chil_flex[cv].book_disp",temp2->chil_flex[cv].book_disp)),
            chcnt = (chcnt+ 1), cht_cnt = (cht_cnt+ 1)
            IF (chcnt > 100)
             stat = alterlist(temp2->child,(cht_cnt+ 100)), stat = alterlist(temp2->chil_flex,(cv+
              100)), chcnt = 1
            ENDIF
            eset_parse = "b.appt_book_id IN (", comma_ind = 0, trcnt = 0,
            trt_cnt = 0, stat = alterlist(temp2->child[cht_cnt].res,100), temp2->child[cht_cnt].
            book_disp = b.mnemonic,
            temp2->chil_flex[cv].book_disp = b.mnemonic, res_ind = 0
           DETAIL
            IF (s.resource_cd > 0)
             res_ind = 1, r_cnt = (r_cnt+ 1), rcont = (rcont+ 1)
             IF (r_cnt > 100)
              stat = alterlist(temp2->child[cht_cnt].res,(rcont+ 100)), r_cnt = 1
             ENDIF
             temp2->child[cht_cnt].res[rcont].res_code = s.resource_cd, temp2->child[cht_cnt].res[
             rcont].srv_res_code = s.service_resource_cd, temp2->child[cht_cnt].res[rcont].res_disp
              = s.mnemonic,
             temp2->child[cht_cnt].res[rcont].pid = s.person_id
             IF (s.res_type_flag=1)
              temp2->child[cht_cnt].res[rcont].gen = "Yes"
             ELSE
              temp2->child[cht_cnt].res[rcont].gen = "No"
             ENDIF
             IF (c.code_value > 0)
              temp2->child[cht_cnt].res[rcont].srv_res_disp = c.display
             ELSEIF (p.person_id > 0)
              temp2->child[cht_cnt].res[rcont].pdisp = p.name_full_formatted
             ENDIF
            ENDIF
            IF (l.child_appt_book_id > 0)
             res_ind = 0
             IF (comma_ind=0)
              eset_parse = build(eset_parse,l.child_appt_book_id), comma_ind = 1
             ELSE
              eset_parse = build(eset_parse,",",l.child_appt_book_id)
             ENDIF
            ENDIF
            eset_parse = build(eset_parse,")")
           FOOT  b.mnemonic
            stat = alterlist(temp2->child[cht_cnt].res,rcont)
           FOOT REPORT
            stat = alterlist(temp2->child,cht_cnt), stat = alterlist(temp2->chil_flex,cv)
           WITH nocounter
          ;end select
         ENDWHILE
         SET c_size = size(temp2->child,5)
         FOR (d = 1 TO c_size)
           SET cres_size = size(temp2->child[d].res,5)
           SET stat = alterlist(reply->rowlist,(row_cnt+ cres_size))
           FOR (c = 1 TO cres_size)
             SET row_cnt = (row_cnt+ 1)
             SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
             SET reply->rowlist[row_cnt].celllist[1].string_value = temp->list[x].book_disp
             SET reply->rowlist[row_cnt].celllist[2].string_value = temp->list[x].sec[y].book_disp
             IF (levels > 3)
              CALL echo(build("cv",cv))
              FOR (i = 3 TO (cv+ 1))
                SET reply->rowlist[row_cnt].celllist[i].string_value = temp2->chil_flex[(i - 2)].
                book_disp
              ENDFOR
             ENDIF
             SET reply->rowlist[row_cnt].celllist[levels].string_value = temp2->child[d].book_disp
             SET reply->rowlist[row_cnt].celllist[(col_cnt - 3)].string_value = temp2->child[d].res[c
             ].gen
             SET reply->rowlist[row_cnt].celllist[(col_cnt - 2)].string_value = temp2->child[d].res[c
             ].res_disp
             SET reply->rowlist[row_cnt].celllist[(col_cnt - 1)].string_value = temp2->child[d].res[c
             ].pdisp
             SET reply->rowlist[row_cnt].celllist[col_cnt].string_value = temp2->child[d].res[c].
             srv_res_disp
           ENDFOR
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bookshelf_resource_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
