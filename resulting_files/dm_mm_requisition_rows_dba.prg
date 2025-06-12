CREATE PROGRAM dm_mm_requisition_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE days_to_keep = i4 WITH noconstant(- (1))
 DECLARE rowcount = i4 WITH noconstant(0)
 DECLARE reqcount = i4 WITH noconstant(0)
 DECLARE distcount = i4 WITH noconstant(0)
 DECLARE tempcount = i4 WITH noconstant(0)
 DECLARE valcount = i4 WITH noconstant(0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF (cnvtupper(request->tokens[tok_ndx].token_str)="DAYSTOKEEP")
    SET days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (days_to_keep < 730)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 730 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(days_to_keep),3))," days or did not enter any value.")
 ELSE
  FREE SET xreqs
  RECORD xreqs(
    1 qual[*]
      2 requisition_id = f8
      2 purge_flag = i2
      2 dist_qual[*]
        3 distribution_id = f8
  )
  SET reply->table_name = "REQUISITION"
  SET reply->rows_between_commit = 100
  SELECT INTO "nl:"
   r.requisition_id
   FROM requisition r,
    line_item l
   PLAN (r
    WHERE r.requisition_id > 0
     AND r.updt_dt_tm < cnvtdatetime((curdate - days_to_keep),curtime3))
    JOIN (l
    WHERE l.requisition_id=r.requisition_id)
   ORDER BY r.requisition_id
   HEAD REPORT
    reqcount = 0
   HEAD r.requisition_id
    valcount = 0
   DETAIL
    IF (l.purchase_order_id > 0)
     valcount = (valcount+ 1)
    ENDIF
   FOOT  r.requisition_id
    IF (valcount=0)
     IF (reqcount < value(request->max_rows))
      reqcount = (reqcount+ 1)
      IF (mod(reqcount,10)=1)
       stat = alterlist(xreqs->qual,(reqcount+ 9))
      ENDIF
      xreqs->qual[reqcount].requisition_id = r.requisition_id, xreqs->qual[reqcount].purge_flag = 1
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(xreqs->qual,reqcount)
   WITH nocounter
  ;end select
  IF (value(size(xreqs->qual,5))=0)
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   r.distribution_id
   FROM (dummyt d  WITH seq = value(size(xreqs->qual,5))),
    dist_req_r r
   PLAN (d)
    JOIN (r
    WHERE (r.requisition_id=xreqs->qual[d.seq].requisition_id))
   ORDER BY r.requisition_id, r.distribution_id
   HEAD r.requisition_id
    distcount = 0
   HEAD r.distribution_id
    distcount = (distcount+ 1)
    IF (mod(distcount,10)=1)
     stat = alterlist(xreqs->qual[d.seq].dist_qual,(distcount+ 9))
    ENDIF
    xreqs->qual[d.seq].dist_qual[distcount].distribution_id = r.distribution_id
   FOOT  r.requisition_id
    stat = alterlist(xreqs->qual[d.seq].dist_qual,distcount)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   r.requisition_id
   FROM (dummyt d  WITH seq = value(size(xreqs->qual,5))),
    (dummyt d1  WITH seq = 1),
    dist_req_r r
   PLAN (d
    WHERE maxrec(d1,size(xreqs->qual[d.seq].dist_qual,5)))
    JOIN (d1)
    JOIN (r
    WHERE (r.distribution_id=xreqs->qual[d.seq].dist_qual[d1.seq].distribution_id))
   ORDER BY r.distribution_id, r.requisition_id
   HEAD r.distribution_id
    reqcount = 0
   HEAD r.requisition_id
    reqcount = (reqcount+ 1)
    IF (reqcount > 1)
     xreqs->qual[d.seq].purge_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SET rowcount = 0
  SELECT INTO "nl:"
   r.rowid
   FROM (dummyt d  WITH seq = value(size(xreqs->qual,5))),
    requisition r
   PLAN (d
    WHERE (xreqs->qual[d.seq].purge_flag=1))
    JOIN (r
    WHERE (r.requisition_id=xreqs->qual[d.seq].requisition_id))
   HEAD REPORT
    rowcount = 0
   DETAIL
    rowcount = (rowcount+ 1)
    IF (mod(rowcount,10)=1)
     stat = alterlist(reply->rows,(rowcount+ 9))
    ENDIF
    reply->rows[rowcount].row_id = r.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,rowcount)
   WITH nocounter
  ;end select
  CALL echo(build("Size of reqs to be purged:",value(size(reply->rows,5))))
  FREE SET xtransids
  RECORD xtransids(
    1 qual[*]
      2 transaction_id = f8
  )
  SELECT INTO "nl:"
   t.transaction_id
   FROM (dummyt d  WITH seq = value(size(xreqs->qual,5))),
    (dummyt d1  WITH seq = 1),
    mm_trans_header t
   PLAN (d
    WHERE maxrec(d1,size(xreqs->qual[d.seq].dist_qual,5))
     AND (xreqs->qual[d.seq].purge_flag=1))
    JOIN (d1)
    JOIN (t
    WHERE (t.distribution_id=xreqs->qual[d.seq].dist_qual[d1.seq].distribution_id)
     AND t.transaction_id > 0)
   ORDER BY t.transaction_id
   HEAD REPORT
    distcount = 0
   HEAD t.transaction_id
    distcount = (distcount+ 1)
    IF (mod(distcount,10)=1)
     stat = alterlist(xtransids->qual,(distcount+ 9))
    ENDIF
    xtransids->qual[distcount].transaction_id = t.transaction_id
   FOOT REPORT
    stat = alterlist(xtransids->qual,distcount)
   WITH nocounter
  ;end select
  IF ((request->purge_flag != 3))
   IF (value(size(xtransids->qual,5)) > 0)
    SET totalcnt = 0
    SET batchcnt = 0
    SET offsetcnt = 0
    SET totalcnt = size(xtransids->qual,5)
    SET batchcnt = 100
    WHILE (totalcnt > 0)
      IF (totalcnt >= batchcnt)
       SET totalcnt = (totalcnt - batchcnt)
      ELSE
       SET batchcnt = totalcnt
       SET totalcnt = 0
      ENDIF
      DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
        mm_trans_error_log e
       SET e.seq = 1
       PLAN (d)
        JOIN (e
        WHERE (e.transaction_id=xtransids->qual[(d.seq+ offsetcnt)].transaction_id))
       WITH nocounter
      ;end delete
      DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
        mm_trans_gl g
       SET g.seq = 1
       PLAN (d)
        JOIN (g
        WHERE (g.transaction_id=xtransids->qual[(d.seq+ offsetcnt)].transaction_id))
       WITH nocounter
      ;end delete
      DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
        mm_trans_line l
       SET l.seq = 1
       PLAN (d)
        JOIN (l
        WHERE (l.transaction_id=xtransids->qual[(d.seq+ offsetcnt)].transaction_id))
       WITH nocounter
      ;end delete
      DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
        mm_trans_header h
       SET h.seq = 1
       PLAN (d)
        JOIN (h
        WHERE (h.transaction_id=xtransids->qual[(d.seq+ offsetcnt)].transaction_id))
       WITH nocounter
      ;end delete
      SET offsetcnt = (offsetcnt+ batchcnt)
      COMMIT
    ENDWHILE
   ENDIF
   FREE SET xtemp
   RECORD xtemp(
     1 qual[*]
       2 distribution_id = f8
       2 line_id_qual[*]
         3 dist_line_detail_id = f8
   )
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(xreqs->qual,5))),
     (dummyt d1  WITH seq = 1),
     dist_line_detail dld
    PLAN (d
     WHERE maxrec(d1,size(xreqs->qual[d.seq].dist_qual,5))
      AND (xreqs->qual[d.seq].purge_flag=1))
     JOIN (d1)
     JOIN (dld
     WHERE (dld.distribution_id=xreqs->qual[d.seq].dist_qual[d1.seq].distribution_id)
      AND dld.distribution_id > 0)
    HEAD REPORT
     distcount = 0
    HEAD dld.distribution_id
     tempcnt = 0, distcount = (distcount+ 1)
     IF (mod(distcount,10)=1)
      stat = alterlist(xtemp->qual,(distcount+ 9))
     ENDIF
     xtemp->qual[distcount].distribution_id = dld.distribution_id
    HEAD dld.dist_line_detail_id
     tempcnt = (tempcnt+ 1)
     IF (mod(tempcnt,10)=1)
      stat = alterlist(xtemp->qual[distcount].line_id_qual,(tempcnt+ 9))
     ENDIF
     xtemp->qual[distcount].line_id_qual[tempcnt].dist_line_detail_id = dld.dist_line_detail_id
    FOOT  dld.distribution_id
     stat = alterlist(xtemp->qual[distcount].line_id_qual,tempcnt)
    FOOT REPORT
     stat = alterlist(xtemp->qual,distcount)
    WITH nocounter
   ;end select
   IF (value(size(xtemp->qual,5)) > 0)
    SET totalcnt = 0
    SET batchcnt = 0
    SET offsetcnt = 0
    SET totalcnt = size(xtemp->qual,5)
    SET batchcnt = 100
    WHILE (totalcnt > 0)
      IF (totalcnt >= batchcnt)
       SET totalcnt = (totalcnt - batchcnt)
      ELSE
       SET batchcnt = totalcnt
       SET totalcnt = 0
      ENDIF
      DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
        (dummyt d1  WITH seq = 1),
        line_item_quantity liq
       SET liq.seq = 1
       PLAN (d
        WHERE maxrec(d1,size(xtemp->qual[d.seq].line_id_qual,5)))
        JOIN (d1)
        JOIN (liq
        WHERE (liq.parent_entity_id=xtemp->qual[(d.seq+ offsetcnt)].line_id_qual[d1.seq].
        dist_line_detail_id)
         AND liq.parent_entity_id > 0)
       WITH nocounter
      ;end delete
      SET offsetcnt = (offsetcnt+ batchcnt)
      COMMIT
    ENDWHILE
   ENDIF
   SET totalcnt = 0
   SET batchcnt = 0
   SET offsetcnt = 0
   SET totalcnt = size(xreqs->qual,5)
   SET batchcnt = 100
   WHILE (totalcnt > 0)
     IF (totalcnt >= batchcnt)
      SET totalcnt = (totalcnt - batchcnt)
     ELSE
      SET batchcnt = totalcnt
      SET totalcnt = 0
     ENDIF
     DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
       (dummyt d1  WITH seq = 1),
       dist_line_detail s
      SET s.seq = 1
      PLAN (d
       WHERE maxrec(d1,size(xreqs->qual[(d.seq+ offsetcnt)].dist_qual,5))
        AND (xreqs->qual[(d.seq+ offsetcnt)].purge_flag=1))
       JOIN (d1)
       JOIN (s
       WHERE (s.distribution_id=xreqs->qual[(d.seq+ offsetcnt)].dist_qual[d1.seq].distribution_id)
        AND s.distribution_id > 0)
      WITH nocounter
     ;end delete
     DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
       (dummyt d1  WITH seq = 1),
       dist_line_item_r s
      SET s.seq = 1
      PLAN (d
       WHERE maxrec(d1,size(xreqs->qual[(d.seq+ offsetcnt)].dist_qual,5))
        AND (xreqs->qual[(d.seq+ offsetcnt)].purge_flag=1))
       JOIN (d1)
       JOIN (s
       WHERE (s.distribution_id=xreqs->qual[(d.seq+ offsetcnt)].dist_qual[d1.seq].distribution_id)
        AND s.distribution_id > 0)
      WITH nocounter
     ;end delete
     DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
       (dummyt d1  WITH seq = 1),
       dist_req_r r
      SET r.seq = 1
      PLAN (d
       WHERE maxrec(d1,size(xreqs->qual[(d.seq+ offsetcnt)].dist_qual,5))
        AND (xreqs->qual[(d.seq+ offsetcnt)].purge_flag=1))
       JOIN (d1)
       JOIN (r
       WHERE (r.distribution_id=xreqs->qual[(d.seq+ offsetcnt)].dist_qual[d1.seq].distribution_id)
        AND r.distribution_id > 0)
      WITH nocounter
     ;end delete
     DELETE  FROM (dummyt d  WITH seq = value(batchcnt)),
       (dummyt d1  WITH seq = 1),
       distribution s
      SET s.seq = 1
      PLAN (d
       WHERE maxrec(d1,size(xreqs->qual[(d.seq+ offsetcnt)].dist_qual,5))
        AND (xreqs->qual[(d.seq+ offsetcnt)].purge_flag=1))
       JOIN (d1)
       JOIN (s
       WHERE (s.distribution_id=xreqs->qual[(d.seq+ offsetcnt)].dist_qual[d1.seq].distribution_id)
        AND s.distribution_id > 0)
      WITH nocounter
     ;end delete
     SET offsetcnt = (offsetcnt+ batchcnt)
     COMMIT
   ENDWHILE
  ENDIF
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = v_errmsg2
  ENDIF
 ENDIF
 GO TO exit_script
#exit_script
END GO
