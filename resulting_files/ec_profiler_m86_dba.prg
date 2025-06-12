CREATE PROGRAM ec_profiler_m86:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dopencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"OUTPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idx2 = i4 WITH noconstant(0)
 DECLARE dparcontrib = f8 WITH constant(uar_get_code_by("MEANING",13016,"ORD CAT"))
 DECLARE dbillcd = f8 WITH constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 FREE RECORD openctypes
 RECORD openctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=dopencclass)
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=71
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(openctypes->qual,(cnt+ 9))
   ENDIF
   openctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
  FOOT REPORT
   stat = alterlist(openctypes->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM order_action oa,
    orders o,
    encntr_loc_hist elh,
    bill_item b,
    bill_item_modifier bm,
    code_value cv,
    prsnl p
   PLAN (oa
    WHERE oa.action_sequence=1
     AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (o
    WHERE o.order_id=oa.order_id
     AND ((o.template_order_id+ 0)=0)
     AND o.orig_ord_as_flag=5)
    JOIN (elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(openctypes->qual,5),(elh.encntr_type_cd+ 0),openctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1
     AND oa.action_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
    JOIN (b
    WHERE b.ext_parent_reference_id=o.catalog_cd
     AND b.ext_parent_contributor_cd=dparcontrib)
    JOIN (bm
    WHERE bm.bill_item_id=outerjoin(b.bill_item_id)
     AND bm.bill_item_type_cd=outerjoin(dbillcd))
    JOIN (cv
    WHERE cv.code_value=outerjoin(bm.key1_id)
     AND cv.cdf_meaning=outerjoin("CPT4")
     AND cv.code_set=outerjoin(14002))
   ORDER BY elh.loc_facility_cd, p.position_cd
   HEAD elh.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd
   HEAD p.position_cd
    positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
    position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt
     ),
    reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
    facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, ordercnt = 0,
    chargecnt = 0
   DETAIL
    ordercnt = (ordercnt+ 1)
    IF (b.bill_item_id > 0.0)
     chargecnt = (chargecnt+ 1)
    ENDIF
   FOOT  p.position_cd
    reply->facilities[facilitycnt].positions[positioncnt].detail_cnt = 2, stat = alterlist(reply->
     facilities[facilitycnt].positions[positioncnt].details,2), reply->facilities[facilitycnt].
    positions[positioncnt].details[1].detail_name = "Orders",
    reply->facilities[facilitycnt].positions[positioncnt].details[1].detail_value_txt = trim(
     cnvtstring(ordercnt)), reply->facilities[facilitycnt].positions[positioncnt].details[2].
    detail_name = "Charges", reply->facilities[facilitycnt].positions[positioncnt].details[2].
    detail_value_txt = trim(cnvtstring(chargecnt))
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
