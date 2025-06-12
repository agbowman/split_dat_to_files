CREATE PROGRAM bhs_sys_updt_clinevent:dba
 FREE DEFINE rtl
 DEFINE rtl "bhscust:smri_oid.txt"
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
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
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   clinical_event ce,
   order_radiology ord
  PLAN (d)
   JOIN (ce
   WHERE (ce.order_id=temp->qual[d.seq].oid)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (ord
   WHERE ord.order_id=ce.order_id)
  DETAIL
   temp->qual[d.seq].redate = ce.event_end_dt_tm, temp->qual[d.seq].raddate = ord.request_dt_tm
  WITH nocounter
 ;end select
 UPDATE  FROM order_radiology ord,
   (dummyt d  WITH seq = value(temp->cnt))
  SET ord.complete_dt_tm = cnvtdatetime(temp->qual[d.seq].raddate), ord.updt_cnt = (ord.updt_cnt+ 1),
   ord.updt_id = 9999,
   ord.updt_dt_tm = sysdate
  PLAN (d)
   JOIN (ord
   WHERE (ord.order_id=temp->qual[d.seq].oid))
  WITH nocounter
 ;end update
 COMMIT
 CALL echorecord(temp)
END GO
