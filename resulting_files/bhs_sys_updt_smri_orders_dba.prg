CREATE PROGRAM bhs_sys_updt_smri_orders:dba
 IF (findfile("bhscust:smri_oid.txt")=1)
  SET msg = "found the file"
 ELSE
  GO TO end_script
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl "bhscust:smri_oid.txt"
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 oid = f8
     2 redate = f8
     2 raddate = f8
 )
 SELECT INTO "nl:"
  FROM rtlt r
  PLAN (r
   WHERE r.line > " ")
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].oid =
   cnvtreal(r.line)
  WITH nocounter
 ;end select
 IF ((temp->cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp->cnt)),
    clinical_event ce,
    order_radiology ord,
    orders o
   PLAN (d
    WHERE d.seq > 0)
    JOIN (ce
    WHERE (ce.order_id=temp->qual[d.seq].oid)
     AND ce.view_level=1
     AND ce.valid_until_dt_tm > sysdate)
    JOIN (ord
    WHERE ord.order_id=ce.order_id)
    JOIN (o
    WHERE o.order_id=ord.order_id)
   DETAIL
    temp->qual[d.seq].redate = ce.event_end_dt_tm
    IF (ord.request_dt_tm > sysdate)
     temp->qual[d.seq].raddate = o.orig_order_dt_tm
    ELSE
     temp->qual[d.seq].raddate = ord.request_dt_tm
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM clinical_event ce,
     (dummyt d  WITH seq = value(temp->cnt))
    SET ce.event_end_dt_tm = cnvtdatetime(temp->qual[d.seq].raddate), ce.updt_cnt = (ce.updt_cnt+ 1),
     ce.updt_id = 9999,
     ce.updt_dt_tm = sysdate
    PLAN (d)
     JOIN (ce
     WHERE (ce.order_id=temp->qual[d.seq].oid))
    WITH nocounter
   ;end update
   UPDATE  FROM order_radiology ord,
     (dummyt d  WITH seq = value(temp->cnt))
    SET ord.request_dt_tm = cnvtdatetime(temp->qual[d.seq].raddate), ord.complete_dt_tm =
     cnvtdatetime(temp->qual[d.seq].raddate), ord.start_dt_tm = cnvtdatetime(temp->qual[d.seq].
      raddate),
     ord.updt_id = 9999, ord.updt_dt_tm = sysdate, ord.updt_cnt = (ord.updt_cnt+ 1)
    PLAN (d)
     JOIN (ord
     WHERE (ord.order_id=temp->qual[d.seq].oid))
   ;end update
   COMMIT
  ENDIF
  CALL echorecord(temp)
 ENDIF
#end_script
END GO
