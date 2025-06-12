CREATE PROGRAM cdi_get_radiology_orders:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 order_name = vc
     2 collect_dt_tm = dq8
     2 collect_tz = i4
     2 receive_dt_tm = dq8
     2 receive_tz = i4
     2 request_dt_tm = dq8
     2 request_tz = i4
     2 ordering_phys = vc
     2 accession_id = f8
     2 accession = vc
     2 exam_reason = vc
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 exam_status_cd = f8
     2 accession_fmt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 EXECUTE accrtl
 DECLARE q_cnt = i4 WITH protect, noconstant(0)
 SET ord_action_type_codeset = 6003
 SET ord_action_type_order_cdf = "ORDER"
 DECLARE ord_action_type_order_cd = f8
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lordersize = i4 WITH protect, noconstant(0)
 SET ord_action_type_order_cd = uar_get_code_by("MEANING",ord_action_type_codeset,nullterm(
   ord_action_type_order_cdf))
 SET lordersize = size(request->order_lst,5)
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->encntr_id > 0))
   PLAN (orr)
    JOIN (o
    WHERE o.order_id=orr.order_id
     AND orr.request_dt_tm BETWEEN cnvtdatetime(request->request_dt_tm_begin) AND cnvtdatetime(
     request->request_dt_tm_end)
     AND (((o.encntr_id=request->encntr_id)) OR ((o.person_id=request->person_id)
     AND o.encntr_id=0)) )
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND oa.action_type_cd=ord_action_type_order_cd)
    JOIN (oa_pl
    WHERE outerjoin(oa.order_provider_id)=oa_pl.person_id)
    JOIN (p
    WHERE p.person_id=orr.person_id)
    JOIN (e
    WHERE outerjoin(orr.encntr_id)=e.encntr_id)
  ELSEIF ((request->person_id > 0))
   PLAN (orr)
    JOIN (o
    WHERE orr.order_id=o.order_id
     AND orr.request_dt_tm BETWEEN cnvtdatetime(request->request_dt_tm_begin) AND cnvtdatetime(
     request->request_dt_tm_end)
     AND (o.person_id=request->person_id))
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND oa.action_type_cd=ord_action_type_order_cd)
    JOIN (oa_pl
    WHERE outerjoin(oa.order_provider_id)=oa_pl.person_id)
    JOIN (p
    WHERE p.person_id=orr.person_id)
    JOIN (e
    WHERE outerjoin(orr.encntr_id)=e.encntr_id)
  ELSEIF (lordersize > 0)
   PLAN (orr
    WHERE expand(lidx,1,lordersize,orr.order_id,request->order_lst[lidx].order_id))
    JOIN (o
    WHERE orr.order_id=o.order_id)
    JOIN (oa
    WHERE outerjoin(o.order_id)=oa.order_id
     AND oa.action_type_cd=ord_action_type_order_cd)
    JOIN (oa_pl
    WHERE outerjoin(oa.order_provider_id)=oa_pl.person_id)
    JOIN (p
    WHERE p.person_id=orr.person_id)
    JOIN (e
    WHERE outerjoin(orr.encntr_id)=e.encntr_id)
  ELSE
  ENDIF
  INTO "n1"
  o.order_id, o.order_mnemonic, o.current_start_dt_tm,
  o.current_start_tz, o.orig_order_dt_tm, o.orig_order_tz,
  orr.request_dt_tm, orr.requested_tz, oa_pl.name_full_formatted,
  orr.accession_id, orr.accession, orr.reason_for_exam,
  p.person_id, p.name_full_formatted, e.encntr_id,
  orr.exam_status_cd
  FROM orders o,
   order_radiology orr,
   order_action oa,
   prsnl oa_pl,
   person p,
   encounter e
  ORDER BY orr.order_id DESC
  HEAD orr.order_id
   q_cnt = (q_cnt+ 1)
   IF (mod(q_cnt,5)=1)
    stat = alterlist(reply->qual,(q_cnt+ 4))
   ENDIF
   reply->qual_cnt = q_cnt, reply->qual[q_cnt].order_id = o.order_id, reply->qual[q_cnt].order_name
    = o.order_mnemonic,
   reply->qual[q_cnt].collect_dt_tm = o.current_start_dt_tm, reply->qual[q_cnt].collect_tz = o
   .current_start_tz, reply->qual[q_cnt].receive_dt_tm = o.orig_order_dt_tm,
   reply->qual[q_cnt].receive_tz = o.orig_order_tz, reply->qual[q_cnt].request_dt_tm = orr
   .request_dt_tm, reply->qual[q_cnt].request_tz = orr.requested_tz,
   reply->qual[q_cnt].ordering_phys = oa_pl.name_full_formatted, reply->qual[q_cnt].accession_id =
   orr.accession_id, reply->qual[q_cnt].accession = orr.accession,
   reply->qual[q_cnt].exam_reason = orr.reason_for_exam, reply->qual[q_cnt].person_id = p.person_id,
   reply->qual[q_cnt].person_name = p.name_full_formatted,
   reply->qual[q_cnt].encntr_id = e.encntr_id, reply->qual[q_cnt].exam_status_cd = orr.exam_status_cd,
   reply->qual[q_cnt].accession_fmt = uar_accformatunformatted(orr.accession,0)
  FOOT REPORT
   stat = alterlist(reply->qual,q_cnt)
  WITH nocounter
 ;end select
 IF (lordersize > 0)
  IF ((reply->qual_cnt != lordersize))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
END GO
