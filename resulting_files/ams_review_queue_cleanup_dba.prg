CREATE PROGRAM ams_review_queue_cleanup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Review Queue:" = 0
  WITH outdev, rqueue
 DECLARE readcd = f8
 DECLARE unreadcd = f8
 DECLARE pendingcd = f8
 DECLARE queue_type = vc
 SELECT INTO "nl:"
  FROM pcs_hierarchy_queue_reltn pcqr
  WHERE (pcqr.queue_id= $RQUEUE)
  DETAIL
   queue_type = trim(uar_get_code_display(pcqr.review_type_cd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="READ"
   AND cv.code_set=29161
  DETAIL
   readcd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="UNREAD"
   AND cv.code_set=29161
  DETAIL
   unreadcd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.cdf_meaning="PENDING"
   AND cv.code_set=29161
  DETAIL
   pendingcd = cv.code_value
  WITH nocounter
 ;end select
 FREE RECORD review_items
 RECORD review_items(
   1 qual[*]
     2 review_id = f8
 )
 SET cnt = 0
 SET numdelete = 0.0
 SET loopcnt = 0
 SET ucnt = 50000.0
 IF (queue_type="One")
  SELECT INTO "nl:"
   FROM pcs_queue_assignment pqa,
    pcs_review_item pri,
    orders o
   PLAN (pqa
    WHERE pqa.review_status_cd=pendingcd
     AND (pqa.queue_id= $RQUEUE))
    JOIN (pri
    WHERE pqa.review_id=pri.review_id)
    JOIN (o
    WHERE o.order_id=pqa.order_id
     AND o.order_status_cd=2543.00)
   ORDER BY pqa.review_id
   HEAD pqa.review_id
    cnt = (cnt+ 1), stat = alterlist(review_items->qual,cnt), review_items->qual[cnt].review_id = pri
    .review_id
   WITH nocounter
  ;end select
 ELSEIF (queue_type="Read")
  SELECT INTO "nl:"
   FROM pcs_queue_assignment pqa,
    pcs_review_item pri,
    orders o
   PLAN (pqa
    WHERE pqa.review_status_cd IN (unreadcd, pendingcd)
     AND (pqa.queue_id= $RQUEUE)
     AND (pqa.pending_dt_tm < (sysdate - 20)))
    JOIN (pri
    WHERE pqa.review_id=pri.review_id
     AND (pri.pending_dt_tm < (sysdate - 20)))
    JOIN (o
    WHERE o.order_id=pqa.order_id
     AND o.order_status_cd=2543.00)
   ORDER BY pqa.review_id
   HEAD pqa.review_id
    cnt = (cnt+ 1), stat = alterlist(review_items->qual,cnt), review_items->qual[cnt].review_id = pri
    .review_id
   WITH nocounter
  ;end select
 ENDIF
 SET numdelete = size(review_items->qual,5)
 SET loopcnt = round((numdelete/ ucnt),0)
 CALL echo(build(">>> numDelete: ",numdelete))
 CALL echo(build(">>> loopCnt: ",loopcnt))
 IF (((numdelete/ ucnt) > loopcnt))
  SET loopcnt = (loopcnt+ 1)
  CALL echo(build(">>>Updated loopCnt: ",loopcnt))
 ENDIF
 SET uidxstart = 0
 SET uidxend = 0
 FOR (x = 1 TO loopcnt)
   SET uidxend = (uidxstart+ ucnt)
   UPDATE  FROM (dummyt d1  WITH seq = value(cnt)),
     pcs_review_item pri
    SET pri.review_status_cd = readcd, pri.updt_applctx = 0, pri.updt_task = 0,
     pri.updt_cnt = (pri.updt_cnt+ 1), pri.updt_id = 2, pri.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (d1
     WHERE d1.seq BETWEEN uidxstart AND uidxend)
     JOIN (pri
     WHERE (pri.review_id=review_items->qual[d1.seq].review_id))
    WITH nocounter
   ;end update
   UPDATE  FROM (dummyt d1  WITH seq = value(cnt)),
     pcs_queue_assignment pqa
    SET pqa.review_status_cd = readcd, pqa.updt_applctx = 0, pqa.updt_task = 0,
     pqa.updt_cnt = (pqa.updt_cnt+ 1), pqa.updt_id = 2, pqa.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    PLAN (d1
     WHERE d1.seq BETWEEN uidxstart AND uidxend)
     JOIN (pqa
     WHERE (pqa.review_id=review_items->qual[d1.seq].review_id))
    WITH nocounter
   ;end update
   CALL echo(">>> COMMIT <<<")
   SET uidxstart = uidxend
 ENDFOR
 COMMIT
 SELECT INTO  $1
  status = "Stuck Items are cleared successfully...!", queue_type = build(queue_type," Queue")
  FROM dummyt
  WITH format, seperator = ""
 ;end select
END GO
