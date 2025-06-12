CREATE PROGRAM aps_orders_find_specimen:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "task_assay_cd" = 0.0,
  "status_cd" = 0.0
  WITH outdev, task_assay_cd, status_cd
 DECLARE taskcnt = i4 WITH protect, noconstant(0)
 DECLARE ordtaskcnt = i4 WITH protect, noconstant(0)
 DECLARE case_specimen_id = f8 WITH protect, noconstant(0.0)
 DECLARE task_catalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE accession_str = vc WITH protect, noconstant("")
 DECLARE assay = vc WITH protect, noconstant("")
 DECLARE task = vc WITH protect, noconstant("")
 DECLARE cancel_status_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,cancel_status_cd)
 SELECT INTO "nl:"
  FROM processing_task pt,
   ap_tag at,
   pathology_case pc,
   discrete_task_assay dta,
   orders o
  PLAN (pt
   WHERE pt.order_id=link_orderid)
   JOIN (o
   WHERE o.order_id=pt.order_id)
   JOIN (at
   WHERE at.tag_id=pt.case_specimen_tag_id)
   JOIN (pc
   WHERE pc.case_id=pt.case_id)
   JOIN (dta
   WHERE dta.task_assay_cd=pt.task_assay_cd)
  DETAIL
   case_specimen_id = pt.case_specimen_id, log_orderid = pt.order_id, log_taskassaycd = pt
   .task_assay_cd,
   task_catalog_cd = o.catalog_cd, accession_str = concat(trim(cnvtacc(pc.accession_nbr)),trim(at
     .tag_disp))
  WITH nocounter
 ;end select
 SET assay = uar_get_code_display(cnvtreal( $TASK_ASSAY_CD))
 SET task = uar_get_code_display(log_taskassaycd)
 SELECT INTO "nl:"
  FROM processing_task pt,
   processing_task pt2
  PLAN (pt
   WHERE pt.order_id=link_orderid)
   JOIN (pt2
   WHERE pt2.case_specimen_id=pt.case_specimen_id
    AND (pt2.task_assay_cd= $TASK_ASSAY_CD)
    AND pt2.status_cd IN ( $STATUS_CD))
  DETAIL
   taskcnt = (taskcnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pt2.order_id
  FROM processing_task pt,
   processing_task pt2
  PLAN (pt
   WHERE pt.order_id=link_orderid)
   JOIN (pt2
   WHERE pt2.case_specimen_id=pt.case_specimen_id
    AND pt2.task_assay_cd=log_taskassaycd
    AND pt2.order_id != link_orderid
    AND pt2.status_cd != cancel_status_cd)
  DETAIL
   ordtaskcnt = (ordtaskcnt+ 1)
  WITH nocounter
 ;end select
 DECLARE tmpordtaskcnt = i4 WITH protect, noconstant(ordtaskcnt)
 IF (ordtaskcnt=0)
  SET log_misc1 = build2(trim(cnvtstring(ordtaskcnt)),"|",trim(cnvtstring(case_specimen_id,19)),"|")
 ELSE
  IF (size(request->orderlist,5)=1)
   SET log_misc1 = build2(trim(cnvtstring(ordtaskcnt)),"|",trim(cnvtstring(case_specimen_id,19)),"|")
  ELSE
   RECORD temp_spec(
     1 orderlist[*]
       2 case_specimen_id = f8
   )
   SET stat = alterlist(temp_spec->orderlist,size(request->orderlist,5))
   SELECT INTO "nl:"
    p.case_specimen_id
    FROM processing_task p,
     (dummyt d1  WITH seq = size(request->orderlist,5))
    PLAN (d1)
     JOIN (p
     WHERE (p.order_id=request->orderlist[d1.seq].orderid))
    DETAIL
     temp_spec->orderlist[d1.seq].case_specimen_id = p.case_specimen_id
    WITH nocounter
   ;end select
   FOR (xx = event_repeat_index TO event_repeat_count)
     IF ((request->orderlist[xx].catalogcd=task_catalog_cd)
      AND (request->orderlist[xx].orderid != link_orderid)
      AND (temp_spec->orderlist[xx].case_specimen_id=case_specimen_id))
      SET tmpordtaskcnt = (tmpordtaskcnt - 1)
     ENDIF
   ENDFOR
   SET log_misc1 = build2(trim(cnvtstring(tmpordtaskcnt)),"|",trim(cnvtstring(case_specimen_id,19)),
    "|")
  ENDIF
 ENDIF
 IF (taskcnt > 0)
  SET retval = 100
  SET log_message = concat(assay," exists ",trim(cnvtstring(taskcnt))," time(s) on ",accession_str,
   ". ",task," exists ",trim(cnvtstring(tmpordtaskcnt))," other time(s).")
 ELSE
  SET retval = 0
  SET log_message = concat(assay," was not found on ",accession_str)
 ENDIF
 SET log_personid = trigger_personid
 SET log_encntrid = trigger_encntrid
END GO
