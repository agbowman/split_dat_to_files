CREATE PROGRAM bed_get_of_folder_hierarchy:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 l0[*]
      2 folder_id = f8
      2 folder_name = vc
      2 component_flag = i2
      2 view_ind = i2
      2 l1[*]
        3 sequence = i4
        3 list_type = i2
        3 child_id = f8
        3 child_name = vc
        3 component_flag = i2
        3 view_ind = i2
        3 l2[*]
          4 sequence = i4
          4 list_type = i2
          4 child_id = f8
          4 child_name = vc
          4 component_flag = i2
          4 view_ind = i2
          4 l3[*]
            5 sequence = i4
            5 list_type = i2
            5 child_id = f8
            5 child_name = vc
            5 component_flag = i2
            5 view_ind = i2
            5 l4[*]
              6 sequence = i4
              6 list_type = i2
              6 child_id = f8
              6 child_name = vc
              6 component_flag = i2
              6 view_ind = i2
              6 l5[*]
                7 sequence = i4
                7 list_type = i2
                7 child_id = f8
                7 child_name = vc
                7 component_flag = i2
                7 view_ind = i2
                7 l6[*]
                  8 sequence = i4
                  8 list_type = i2
                  8 child_id = f8
                  8 child_name = vc
                  8 component_flag = i2
                  8 view_ind = i2
                  8 l7[*]
                    9 sequence = i4
                    9 list_type = i2
                    9 child_id = f8
                    9 child_name = vc
                    9 component_flag = i2
                    9 view_ind = i2
                    9 l8[*]
                      10 sequence = i4
                      10 list_type = i2
                      10 child_id = f8
                      10 child_name = vc
                      10 component_flag = i2
                      10 view_ind = i2
                      10 l9[*]
                        11 sequence = i4
                        11 list_type = i2
                        11 child_id = f8
                        11 child_name = vc
                        11 component_flag = i2
                        11 view_ind = i2
                        11 l10[*]
                          12 sequence = i4
                          12 list_type = i2
                          12 child_id = f8
                          12 child_name = vc
                          12 component_flag = i2
                          12 view_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 l0[*]
     2 folder_id = f8
     2 folder_name = vc
     2 component_flag = i2
     2 view_ind = i2
     2 return_ind = i2
     2 l1[*]
       3 sequence = i4
       3 list_type = i2
       3 child_id = f8
       3 child_name = vc
       3 component_flag = i2
       3 view_ind = i2
       3 l2[*]
         4 sequence = i4
         4 list_type = i2
         4 child_id = f8
         4 child_name = vc
         4 component_flag = i2
         4 view_ind = i2
         4 l3[*]
           5 sequence = i4
           5 list_type = i2
           5 child_id = f8
           5 child_name = vc
           5 component_flag = i2
           5 view_ind = i2
           5 l4[*]
             6 sequence = i4
             6 list_type = i2
             6 child_id = f8
             6 child_name = vc
             6 component_flag = i2
             6 view_ind = i2
             6 l5[*]
               7 sequence = i4
               7 list_type = i2
               7 child_id = f8
               7 child_name = vc
               7 component_flag = i2
               7 view_ind = i2
               7 l6[*]
                 8 sequence = i4
                 8 list_type = i2
                 8 child_id = f8
                 8 child_name = vc
                 8 component_flag = i2
                 8 view_ind = i2
                 8 l7[*]
                   9 sequence = i4
                   9 list_type = i2
                   9 child_id = f8
                   9 child_name = vc
                   9 component_flag = i2
                   9 view_ind = i2
                   9 l8[*]
                     10 sequence = i4
                     10 list_type = i2
                     10 child_id = f8
                     10 child_name = vc
                     10 component_flag = i2
                     10 view_ind = i2
                     10 l9[*]
                       11 sequence = i4
                       11 list_type = i2
                       11 child_id = f8
                       11 child_name = vc
                       11 component_flag = i2
                       11 view_ind = i2
                       11 l10[*]
                         12 sequence = i4
                         12 list_type = i2
                         12 child_id = f8
                         12 child_name = vc
                         12 component_flag = i2
                         12 view_ind = i2
 )
 RECORD rlist(
   1 folder[*]
     2 id = f8
 )
 SET reply->status_data.status = "F"
 SET a = 0
 SET b = 0
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM alt_sel_list asl
  PLAN (asl
   WHERE asl.alt_sel_category_id > 0
    AND  NOT ( EXISTS (
   (SELECT
    l.alt_sel_category_id
    FROM alt_sel_list l
    WHERE l.child_alt_sel_cat_id=asl.alt_sel_category_id))))
  ORDER BY asl.alt_sel_category_id
  HEAD asl.alt_sel_category_id
   rcnt = (rcnt+ 1), stat = alterlist(rlist->folder,rcnt), rlist->folder[rcnt].id = asl
   .alt_sel_category_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(rlist->folder,5))
   SELECT INTO "nl:"
    FROM alt_sel_list l,
     alt_sel_cat c,
     alt_sel_cat c2
    PLAN (l
     WHERE (l.alt_sel_category_id=rlist->folder[x].id))
     JOIN (c
     WHERE c.alt_sel_category_id=l.alt_sel_category_id)
     JOIN (c2
     WHERE c2.alt_sel_category_id=l.child_alt_sel_cat_id)
    ORDER BY l.sequence
    HEAD l.alt_sel_category_id
     b = 0, a = (a+ 1), stat = alterlist(temp->l0,a),
     temp->l0[a].folder_id = l.alt_sel_category_id, temp->l0[a].folder_name = c.long_description,
     temp->l0[a].component_flag = c.source_component_flag
     IF (c.security_flag=2
      AND c.ahfs_ind IN (0, null)
      AND c.folder_flag IN (0, 1, null)
      AND c.adhoc_ind IN (0, null)
      AND c.source_component_flag IN (0, request->component_flag))
      temp->l0[a].view_ind = 1, temp->l0[a].return_ind = 1
     ENDIF
    DETAIL
     IF (l.list_type=1)
      b = (b+ 1), stat = alterlist(temp->l0[a].l1,b), temp->l0[a].l1[b].sequence = l.sequence,
      temp->l0[a].l1[b].list_type = l.list_type, temp->l0[a].l1[b].child_id = l.child_alt_sel_cat_id,
      temp->l0[a].l1[b].child_name = c2.long_description,
      temp->l0[a].l1[b].component_flag = c2.source_component_flag
      IF (c2.security_flag=2
       AND c2.ahfs_ind IN (0, null)
       AND c2.folder_flag IN (0, 1, null)
       AND c2.adhoc_ind IN (0, null)
       AND c2.source_component_flag IN (0, request->component_flag))
       temp->l0[a].l1[b].view_ind = 1, temp->l0[a].return_ind = 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO size(temp->l0,5))
   IF (size(temp->l0[x].l1,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1,5))),
      alt_sel_list l,
      alt_sel_cat c
     PLAN (d
      WHERE (temp->l0[x].l1[d.seq].list_type=1))
      JOIN (l
      WHERE (l.alt_sel_category_id=temp->l0[x].l1[d.seq].child_id)
       AND l.list_type=1)
      JOIN (c
      WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
     ORDER BY d.seq, l.sequence
     HEAD d.seq
      a = 0
     DETAIL
      a = (a+ 1), stat = alterlist(temp->l0[x].l1[d.seq].l2,a), temp->l0[x].l1[d.seq].l2[a].sequence
       = l.sequence,
      temp->l0[x].l1[d.seq].l2[a].list_type = l.list_type, temp->l0[x].l1[d.seq].l2[a].child_id = l
      .child_alt_sel_cat_id, temp->l0[x].l1[d.seq].l2[a].child_name = c.long_description,
      temp->l0[x].l1[d.seq].l2[a].component_flag = c.source_component_flag
      IF (c.security_flag=2
       AND c.ahfs_ind IN (0, null)
       AND c.folder_flag IN (0, 1, null)
       AND c.adhoc_ind IN (0, null)
       AND c.source_component_flag IN (0, request->component_flag))
       temp->l0[x].l1[d.seq].l2[a].view_ind = 1, temp->l0[x].return_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    FOR (y = 1 TO size(temp->l0[x].l1,5))
      IF (size(temp->l0[x].l1[y].l2,5) > 0)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2,5))),
         alt_sel_list l,
         alt_sel_cat c
        PLAN (d
         WHERE (temp->l0[x].l1[y].l2[d.seq].list_type=1))
         JOIN (l
         WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[d.seq].child_id)
          AND l.list_type=1)
         JOIN (c
         WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
        ORDER BY d.seq, l.sequence
        HEAD d.seq
         a = 0
        DETAIL
         a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[d.seq].l3,a), temp->l0[x].l1[y].l2[d.seq].
         l3[a].sequence = l.sequence,
         temp->l0[x].l1[y].l2[d.seq].l3[a].list_type = l.list_type, temp->l0[x].l1[y].l2[d.seq].l3[a]
         .child_id = l.child_alt_sel_cat_id, temp->l0[x].l1[y].l2[d.seq].l3[a].child_name = c
         .long_description,
         temp->l0[x].l1[y].l2[d.seq].l3[a].component_flag = c.source_component_flag
         IF (c.security_flag=2
          AND c.ahfs_ind IN (0, null)
          AND c.folder_flag IN (0, 1, null)
          AND c.adhoc_ind IN (0, null)
          AND c.source_component_flag IN (0, request->component_flag))
          temp->l0[x].l1[y].l2[d.seq].l3[a].view_ind = 1, temp->l0[x].return_ind = 1
         ENDIF
        WITH nocounter
       ;end select
       FOR (z = 1 TO size(temp->l0[x].l1[y].l2,5))
         IF (size(temp->l0[x].l1[y].l2[z].l3,5) > 0)
          SELECT INTO "nl:"
           FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3,5))),
            alt_sel_list l,
            alt_sel_cat c
           PLAN (d
            WHERE (temp->l0[x].l1[y].l2[z].l3[d.seq].list_type=1))
            JOIN (l
            WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[d.seq].child_id)
             AND l.list_type=1)
            JOIN (c
            WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
           ORDER BY d.seq, l.sequence
           HEAD d.seq
            a = 0
           DETAIL
            a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[d.seq].l4,a), temp->l0[x].l1[y].
            l2[z].l3[d.seq].l4[a].sequence = l.sequence,
            temp->l0[x].l1[y].l2[z].l3[d.seq].l4[a].list_type = l.list_type, temp->l0[x].l1[y].l2[z].
            l3[d.seq].l4[a].child_id = l.child_alt_sel_cat_id, temp->l0[x].l1[y].l2[z].l3[d.seq].l4[a
            ].child_name = c.long_description,
            temp->l0[x].l1[y].l2[z].l3[d.seq].l4[a].component_flag = c.source_component_flag
            IF (c.security_flag=2
             AND c.ahfs_ind IN (0, null)
             AND c.folder_flag IN (0, 1, null)
             AND c.adhoc_ind IN (0, null)
             AND c.source_component_flag IN (0, request->component_flag))
             temp->l0[x].l1[y].l2[z].l3[d.seq].l4[a].view_ind = 1, temp->l0[x].return_ind = 1
            ENDIF
           WITH nocounter
          ;end select
          FOR (q = 1 TO size(temp->l0[x].l1[y].l2[z].l3,5))
            IF (size(temp->l0[x].l1[y].l2[z].l3[q].l4,5) > 0)
             SELECT INTO "nl:"
              FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3[q].l4,5))),
               alt_sel_list l,
               alt_sel_cat c
              PLAN (d
               WHERE (temp->l0[x].l1[y].l2[z].l3[q].l4[d.seq].list_type=1))
               JOIN (l
               WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[q].l4[d.seq].child_id)
                AND l.list_type=1)
               JOIN (c
               WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
              ORDER BY d.seq, l.sequence
              HEAD d.seq
               a = 0
              DETAIL
               a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[q].l4[d.seq].l5,a), temp->l0[x
               ].l1[y].l2[z].l3[q].l4[d.seq].l5[a].sequence = l.sequence,
               temp->l0[x].l1[y].l2[z].l3[q].l4[d.seq].l5[a].list_type = l.list_type, temp->l0[x].l1[
               y].l2[z].l3[q].l4[d.seq].l5[a].child_id = l.child_alt_sel_cat_id, temp->l0[x].l1[y].
               l2[z].l3[q].l4[d.seq].l5[a].child_name = c.long_description,
               temp->l0[x].l1[y].l2[z].l3[q].l4[d.seq].l5[a].component_flag = c.source_component_flag
               IF (c.security_flag=2
                AND c.ahfs_ind IN (0, null)
                AND c.folder_flag IN (0, 1, null)
                AND c.adhoc_ind IN (0, null)
                AND c.source_component_flag IN (0, request->component_flag))
                temp->l0[x].l1[y].l2[z].l3[q].l4[d.seq].l5[a].view_ind = 1, temp->l0[x].return_ind =
                1
               ENDIF
              WITH nocounter
             ;end select
             FOR (r = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4,5))
               IF (size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5,5) > 0)
                SELECT INTO "nl:"
                 FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5,5))),
                  alt_sel_list l,
                  alt_sel_cat c
                 PLAN (d
                  WHERE (temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].list_type=1))
                  JOIN (l
                  WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].child_id
                  )
                   AND l.list_type=1)
                  JOIN (c
                  WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
                 ORDER BY d.seq, l.sequence
                 HEAD d.seq
                  a = 0
                 DETAIL
                  a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6,a),
                  temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6[a].sequence = l.sequence,
                  temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6[a].list_type = l.list_type, temp->
                  l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6[a].child_id = l.child_alt_sel_cat_id,
                  temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6[a].child_name = c.long_description,
                  temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6[a].component_flag = c
                  .source_component_flag
                  IF (c.security_flag=2
                   AND c.ahfs_ind IN (0, null)
                   AND c.folder_flag IN (0, 1, null)
                   AND c.adhoc_ind IN (0, null)
                   AND c.source_component_flag IN (0, request->component_flag))
                   temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[d.seq].l6[a].view_ind = 1, temp->l0[x].
                   return_ind = 1
                  ENDIF
                 WITH nocounter
                ;end select
                FOR (s = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5,5))
                  IF (size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6,5) > 0)
                   SELECT INTO "nl:"
                    FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].
                       l6,5))),
                     alt_sel_list l,
                     alt_sel_cat c
                    PLAN (d
                     WHERE (temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].list_type=1))
                     JOIN (l
                     WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq]
                     .child_id)
                      AND l.list_type=1)
                     JOIN (c
                     WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
                    ORDER BY d.seq, l.sequence
                    HEAD d.seq
                     a = 0
                    DETAIL
                     a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq]
                      .l7,a), temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].l7[a].sequence = l
                     .sequence,
                     temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].l7[a].list_type = l
                     .list_type, temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].l7[a].child_id
                      = l.child_alt_sel_cat_id, temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].
                     l7[a].child_name = c.long_description,
                     temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].l7[a].component_flag = c
                     .source_component_flag
                     IF (c.security_flag=2
                      AND c.ahfs_ind IN (0, null)
                      AND c.folder_flag IN (0, 1, null)
                      AND c.adhoc_ind IN (0, null)
                      AND c.source_component_flag IN (0, request->component_flag))
                      temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[d.seq].l7[a].view_ind = 1, temp->
                      l0[x].return_ind = 1
                     ENDIF
                    WITH nocounter
                   ;end select
                   FOR (t = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6,5))
                     IF (size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7,5) > 0)
                      SELECT INTO "nl:"
                       FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s
                          ].l6[t].l7,5))),
                        alt_sel_list l,
                        alt_sel_cat c
                       PLAN (d
                        WHERE (temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[d.seq].list_type=1)
                        )
                        JOIN (l
                        WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].
                        l7[d.seq].child_id)
                         AND l.list_type=1)
                        JOIN (c
                        WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
                       ORDER BY d.seq, l.sequence
                       HEAD d.seq
                        a = 0
                       DETAIL
                        a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].
                         l7[d.seq].l8,a), temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[d.seq].
                        l8[a].sequence = l.sequence,
                        temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[d.seq].l8[a].list_type = l
                        .list_type, temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[d.seq].l8[a].
                        child_id = l.child_alt_sel_cat_id, temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].
                        l6[t].l7[d.seq].l8[a].child_name = c.long_description,
                        temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[d.seq].l8[a].
                        component_flag = c.source_component_flag
                        IF (c.security_flag=2
                         AND c.ahfs_ind IN (0, null)
                         AND c.folder_flag IN (0, 1, null)
                         AND c.adhoc_ind IN (0, null)
                         AND c.source_component_flag IN (0, request->component_flag))
                         temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[d.seq].l8[a].view_ind = 1,
                         temp->l0[x].return_ind = 1
                        ENDIF
                       WITH nocounter
                      ;end select
                      FOR (u = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7,5))
                        IF (size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8,5) > 0)
                         SELECT INTO "nl:"
                          FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].
                             l5[s].l6[t].l7[u].l8,5))),
                           alt_sel_list l,
                           alt_sel_cat c
                          PLAN (d
                           WHERE (temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[d.seq].
                           list_type=1))
                           JOIN (l
                           WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[
                           t].l7[u].l8[d.seq].child_id)
                            AND l.list_type=1)
                           JOIN (c
                           WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
                          ORDER BY d.seq, l.sequence
                          HEAD d.seq
                           a = 0
                          DETAIL
                           a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[
                            t].l7[u].l8[d.seq].l9,a), temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t]
                           .l7[u].l8[d.seq].l9[a].sequence = l.sequence,
                           temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[d.seq].l9[a].
                           list_type = l.list_type, temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].
                           l7[u].l8[d.seq].l9[a].child_id = l.child_alt_sel_cat_id, temp->l0[x].l1[y]
                           .l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[d.seq].l9[a].child_name = c
                           .long_description,
                           temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[d.seq].l9[a].
                           component_flag = c.source_component_flag
                           IF (c.security_flag=2
                            AND c.ahfs_ind IN (0, null)
                            AND c.folder_flag IN (0, 1, null)
                            AND c.adhoc_ind IN (0, null)
                            AND c.source_component_flag IN (0, request->component_flag))
                            temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[d.seq].l9[a].
                            view_ind = 1, temp->l0[x].return_ind = 1
                           ENDIF
                          WITH nocounter
                         ;end select
                         FOR (v = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8,
                          5))
                           IF (size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9,5)
                            > 0)
                            SELECT INTO "nl:"
                             FROM (dummyt d  WITH seq = value(size(temp->l0[x].l1[y].l2[z].l3[q].l4[r
                                ].l5[s].l6[t].l7[u].l8[v].l9,5))),
                              alt_sel_list l,
                              alt_sel_cat c
                             PLAN (d
                              WHERE (temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[d
                              .seq].list_type=1))
                              JOIN (l
                              WHERE (l.alt_sel_category_id=temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].
                              l6[t].l7[u].l8[v].l9[d.seq].child_id)
                               AND l.list_type=1)
                              JOIN (c
                              WHERE c.alt_sel_category_id=l.child_alt_sel_cat_id)
                             ORDER BY d.seq, l.sequence
                             HEAD d.seq
                              a = 0
                             DETAIL
                              a = (a+ 1), stat = alterlist(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].
                               l6[t].l7[u].l8[v].l9[d.seq].l10,a), temp->l0[x].l1[y].l2[z].l3[q].l4[r
                              ].l5[s].l6[t].l7[u].l8[v].l9[d.seq].l10[a].sequence = l.sequence,
                              temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[d.seq].
                              l10[a].list_type = l.list_type, temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[
                              s].l6[t].l7[u].l8[v].l9[d.seq].l10[a].child_id = l.child_alt_sel_cat_id,
                              temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[d.seq].
                              l10[a].child_name = c.long_description,
                              temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[d.seq].
                              l10[a].component_flag = c.source_component_flag
                              IF (c.security_flag=2
                               AND c.ahfs_ind IN (0, null)
                               AND c.folder_flag IN (0, 1, null)
                               AND c.adhoc_ind IN (0, null)
                               AND c.source_component_flag IN (0, request->component_flag))
                               temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[d.seq].
                               l10[a].view_ind = 1, temp->l0[x].return_ind = 1
                              ENDIF
                             WITH nocounter
                            ;end select
                           ENDIF
                         ENDFOR
                        ENDIF
                      ENDFOR
                     ENDIF
                   ENDFOR
                  ENDIF
                ENDFOR
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET a = 0
 FOR (x = 1 TO size(temp->l0,5))
   IF ((temp->l0[x].return_ind=1))
    SET a = (a+ 1)
    SET stat = alterlist(reply->l0,a)
    SET reply->l0[a].folder_id = temp->l0[x].folder_id
    SET reply->l0[a].folder_name = temp->l0[x].folder_name
    SET reply->l0[a].component_flag = temp->l0[x].component_flag
    SET reply->l0[a].view_ind = temp->l0[x].view_ind
    FOR (y = 1 TO size(temp->l0[x].l1,5))
      SET stat = alterlist(reply->l0[a].l1,y)
      SET reply->l0[a].l1[y].sequence = temp->l0[x].l1[y].sequence
      SET reply->l0[a].l1[y].list_type = temp->l0[x].l1[y].list_type
      SET reply->l0[a].l1[y].child_id = temp->l0[x].l1[y].child_id
      SET reply->l0[a].l1[y].child_name = temp->l0[x].l1[y].child_name
      SET reply->l0[a].l1[y].component_flag = temp->l0[x].l1[y].component_flag
      SET reply->l0[a].l1[y].view_ind = temp->l0[x].l1[y].view_ind
      FOR (z = 1 TO size(temp->l0[x].l1[y].l2,5))
        SET stat = alterlist(reply->l0[a].l1[y].l2,z)
        SET reply->l0[a].l1[y].l2[z].sequence = temp->l0[x].l1[y].l2[z].sequence
        SET reply->l0[a].l1[y].l2[z].list_type = temp->l0[x].l1[y].l2[z].list_type
        SET reply->l0[a].l1[y].l2[z].child_id = temp->l0[x].l1[y].l2[z].child_id
        SET reply->l0[a].l1[y].l2[z].child_name = temp->l0[x].l1[y].l2[z].child_name
        SET reply->l0[a].l1[y].l2[z].component_flag = temp->l0[x].l1[y].l2[z].component_flag
        SET reply->l0[a].l1[y].l2[z].view_ind = temp->l0[x].l1[y].l2[z].view_ind
        FOR (q = 1 TO size(temp->l0[x].l1[y].l2[z].l3,5))
          SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3,q)
          SET reply->l0[a].l1[y].l2[z].l3[q].sequence = temp->l0[x].l1[y].l2[z].l3[q].sequence
          SET reply->l0[a].l1[y].l2[z].l3[q].list_type = temp->l0[x].l1[y].l2[z].l3[q].list_type
          SET reply->l0[a].l1[y].l2[z].l3[q].child_id = temp->l0[x].l1[y].l2[z].l3[q].child_id
          SET reply->l0[a].l1[y].l2[z].l3[q].child_name = temp->l0[x].l1[y].l2[z].l3[q].child_name
          SET reply->l0[a].l1[y].l2[z].l3[q].component_flag = temp->l0[x].l1[y].l2[z].l3[q].
          component_flag
          SET reply->l0[a].l1[y].l2[z].l3[q].view_ind = temp->l0[x].l1[y].l2[z].l3[q].view_ind
          FOR (r = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4,5))
            SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4,r)
            SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].sequence = temp->l0[x].l1[y].l2[z].l3[q].l4[r].
            sequence
            SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].list_type = temp->l0[x].l1[y].l2[z].l3[q].l4[r].
            list_type
            SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].child_id = temp->l0[x].l1[y].l2[z].l3[q].l4[r].
            child_id
            SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].child_name = temp->l0[x].l1[y].l2[z].l3[q].l4[r]
            .child_name
            SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].component_flag = temp->l0[x].l1[y].l2[z].l3[q].
            l4[r].component_flag
            SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].view_ind = temp->l0[x].l1[y].l2[z].l3[q].l4[r].
            view_ind
            FOR (s = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5,5))
              SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5,s)
              SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].sequence = temp->l0[x].l1[y].l2[z].l3[q]
              .l4[r].l5[s].sequence
              SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].list_type = temp->l0[x].l1[y].l2[z].l3[q
              ].l4[r].l5[s].list_type
              SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].child_id = temp->l0[x].l1[y].l2[z].l3[q]
              .l4[r].l5[s].child_id
              SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].child_name = temp->l0[x].l1[y].l2[z].l3[
              q].l4[r].l5[s].child_name
              SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].component_flag = temp->l0[x].l1[y].l2[z]
              .l3[q].l4[r].l5[s].component_flag
              SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].view_ind = temp->l0[x].l1[y].l2[z].l3[q]
              .l4[r].l5[s].view_ind
              FOR (t = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6,5))
                SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6,t)
                SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].sequence = temp->l0[x].l1[y].l2[
                z].l3[q].l4[r].l5[s].l6[t].sequence
                SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].list_type = temp->l0[x].l1[y].
                l2[z].l3[q].l4[r].l5[s].l6[t].list_type
                SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].child_id = temp->l0[x].l1[y].l2[
                z].l3[q].l4[r].l5[s].l6[t].child_id
                SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].child_name = temp->l0[x].l1[y].
                l2[z].l3[q].l4[r].l5[s].l6[t].child_name
                SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].component_flag = temp->l0[x].l1[
                y].l2[z].l3[q].l4[r].l5[s].l6[t].component_flag
                SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].view_ind = temp->l0[x].l1[y].l2[
                z].l3[q].l4[r].l5[s].l6[t].view_ind
                FOR (u = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7,5))
                  SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7,u)
                  SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].sequence = temp->l0[x].
                  l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].sequence
                  SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].list_type = temp->l0[x].
                  l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].list_type
                  SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].child_id = temp->l0[x].
                  l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].child_id
                  SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].child_name = temp->l0[x]
                  .l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].child_name
                  SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].component_flag = temp->
                  l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].component_flag
                  SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].view_ind = temp->l0[x].
                  l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].view_ind
                  FOR (v = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8,5))
                    SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8,v)
                    SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].sequence = temp
                    ->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].sequence
                    SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].list_type = temp
                    ->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].list_type
                    SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].child_id = temp
                    ->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].child_id
                    SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].child_name =
                    temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].child_name
                    SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].component_flag
                     = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].component_flag
                    SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].view_ind = temp
                    ->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].view_ind
                    FOR (w = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9,
                     5))
                      SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[
                       v].l9,w)
                      SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].sequence
                       = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].sequence
                      SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].
                      list_type = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].
                      list_type
                      SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].child_id
                       = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].child_id
                      SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].
                      child_name = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].
                      child_name
                      SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].
                      component_flag = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].
                      l9[w].component_flag
                      SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].view_ind
                       = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].view_ind
                      FOR (h = 1 TO size(temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].
                       l9[w].l10,5))
                        SET stat = alterlist(reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].
                         l8[v].l9[w].l10,h)
                        SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].l10[h]
                        .sequence = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w]
                        .l10[h].sequence
                        SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].l10[h]
                        .list_type = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w
                        ].l10[h].list_type
                        SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].l10[h]
                        .child_id = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w]
                        .l10[h].child_id
                        SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].l10[h]
                        .child_name = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[
                        w].l10[h].child_name
                        SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].l10[h]
                        .component_flag = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v]
                        .l9[w].l10[h].component_flag
                        SET reply->l0[a].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w].l10[h]
                        .view_ind = temp->l0[x].l1[y].l2[z].l3[q].l4[r].l5[s].l6[t].l7[u].l8[v].l9[w]
                        .l10[h].view_ind
                      ENDFOR
                    ENDFOR
                  ENDFOR
                ENDFOR
              ENDFOR
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (size(reply->l0,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
