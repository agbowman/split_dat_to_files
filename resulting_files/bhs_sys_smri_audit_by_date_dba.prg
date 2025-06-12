CREATE PROGRAM bhs_sys_smri_audit_by_date:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Beg Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat(trim( $S_BEG_DT)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat(trim( $S_END_DT)," 23:59:59"))
 DECLARE d = i4
 DECLARE m = i4
 DECLARE y = i4
 DECLARE mf_breastwell1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "BHBREASTWELLNESS"))
 DECLARE mf_breastwell2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "BAYSTATEBREASTWELL"))
 DECLARE mf_smri_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,"SMRI"))
 DECLARE mf_baystateradimaging_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",34,
   "BAYSTATERADIMAGING"))
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 qual[*]
     2 oid = f8
     2 eid = f8
     2 pid = f8
     2 raddate = dq8
     2 radday = i2
     2 radyear = i2
     2 radmonth = i2
     2 resdate = dq8
     2 updt_ind = i2
 )
 SELECT INTO "nl:"
  FROM order_radiology ord,
   encounter e,
   clinical_event ce
  PLAN (ord
   WHERE ord.updt_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ord.encntr_id
    AND e.med_service_cd IN (mf_breastwell1_cd, mf_breastwell2_cd, mf_smri_cd,
   mf_baystateradimaging_cd))
   JOIN (ce
   WHERE ce.order_id=ord.order_id
    AND ce.valid_until_dt_tm > cnvtdatetime(ms_end_dt_tm))
  ORDER BY ord.order_id, 0
  HEAD REPORT
   d = 0, m = 0, y = 0
  HEAD ord.order_id
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].eid = e
   .encntr_id,
   temp->qual[temp->cnt].oid = ord.order_id, temp->qual[temp->cnt].raddate = ord.request_dt_tm, temp
   ->qual[temp->cnt].radday = day(ord.request_dt_tm),
   temp->qual[temp->cnt].radmonth = month(ord.request_dt_tm), temp->qual[temp->cnt].radyear = year(
    ord.request_dt_tm), temp->qual[temp->cnt].resdate = ce.event_end_dt_tm
  FOOT  ord.order_id
   d = day(ce.event_end_dt_tm), m = month(ce.event_end_dt_tm), y = year(ce.event_end_dt_tm)
   IF ((((temp->qual[temp->cnt].radday != d)) OR ((((temp->qual[temp->cnt].radmonth != m)) OR ((temp
   ->qual[temp->cnt].radyear != y))) )) )
    temp->qual[temp->cnt].updt_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value("bhscust:smri_oid.txt")
  cnvtstring(temp->qual[d.seq].oid)
  FROM (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d
   WHERE (temp->qual[d.seq].updt_ind=1))
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d
   WHERE (temp->qual[d.seq].updt_ind=1))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO value( $OUTDEV)
   encntr_id = trim(cnvtstring(temp->qual[d.seq].eid)), order_id = trim(cnvtstring(temp->qual[d.seq].
     oid)), rad_date = trim(format(temp->qual[d.seq].raddate,"mm/dd/yy;;d")),
   result_date = trim(format(temp->qual[d.seq].resdate,"mm/dd/yy;;d"))
   FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
   PLAN (d
    WHERE (temp->qual[d.seq].updt_ind=1))
   WITH nocounter, format, maxrow = 1,
    separator = " ", skipreport = 1
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dual
   HEAD REPORT
    col 0, "No records found for update"
   WITH nocounter
  ;end select
 ENDIF
 EXECUTE bhs_sys_updt_smri_orders
END GO
