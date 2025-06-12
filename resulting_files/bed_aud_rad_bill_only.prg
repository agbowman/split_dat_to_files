CREATE PROGRAM bed_aud_rad_bill_only
 RECORD int_bi(
   1 bill_items[*]
     2 bill_item_id = f8
     2 task_assay_cd = f8
     2 task_assay_mnemonic = vc
 )
 FREE RECORD bill_cds
 RECORD bill_cds(
   1 qual[*]
     2 bill_sched = vc
     2 sched_cd = f8
     2 reply_col = i2
 )
 FREE RECORD price_scheds
 RECORD price_scheds(
   1 qual[*]
     2 price_sched = vc
     2 price_cd = f8
     2 reply_col = i2
 )
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
  )
 ENDIF
 DECLARE radiology_activity_cd = f8 WITH noconstant(0.00)
 SET cnt = 0
 SET int_cnt = 0
 SET reply_cnt = 0
 DECLARE cpt4 = i2 WITH noconstant(0)
 DECLARE cdm_sched = i2 WITH noconstant(0)
 DECLARE hcpcs = i2 WITH noconstant(0)
 DECLARE modifier = i2 WITH noconstant(0)
 DECLARE revenue = i2 WITH noconstant(0)
 DECLARE exam_rooms = vc
 SET stat = alterlist(reply->collist,1)
 SET reply->collist[1].header_text = "Bill-Only Items"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET default_result_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=289
    AND c.cdf_meaning="17")
  DETAIL
   default_result_type_cd = c.code_value
  WITH nocounter
 ;end select
 SET activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=106
    AND c.cdf_meaning="RADIOLOGY")
  DETAIL
   activity_type_cd = c.code_value
  WITH nocounter
 ;end select
 IF (((activity_type_cd=0.0) OR (default_result_type_cd=0.0)) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dta.mnemonic, dta.task_assay_cd, bi.bill_item_id
  FROM discrete_task_assay dta,
   dummyt d,
   profile_task_r ptr,
   bill_item bi
  PLAN (dta
   WHERE dta.default_result_type_cd=default_result_type_cd
    AND dta.active_ind=1
    AND dta.activity_type_cd=activity_type_cd)
   JOIN (d)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.active_ind=1)
   JOIN (bi
   WHERE bi.ext_child_reference_id=dta.task_assay_cd
    AND bi.ext_parent_reference_id=0)
  ORDER BY dta.mnemonic
  HEAD REPORT
   cnt = 0, stat = alterlist(int_bi->bill_items,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(int_bi->bill_items,(25+ cnt))
   ENDIF
   int_bi->bill_items[cnt].bill_item_id = bi.bill_item_id, int_bi->bill_items[cnt].task_assay_cd =
   dta.task_assay_cd, int_bi->bill_items[cnt].task_assay_mnemonic = dta.mnemonic
  FOOT REPORT
   stat = alterlist(int_bi->bill_items,cnt)
  WITH nocounter, noheading, outerjoin = d
 ;end select
 CALL echorecord(int_bi)
 CALL echo("***** Get Bill Code Headers")
 SELECT INTO "nl:"
  cv.display, cv.cdf_meaning, sched_id = cv.code_value
  FROM (dummyt d  WITH seq = value(size(int_bi->bill_items,5))),
   bill_item_modifier bim,
   code_value cv
  PLAN (d)
   JOIN (bim
   WHERE (bim.bill_item_id=int_bi->bill_items[d.seq].bill_item_id)
    AND bim.active_ind=1)
   JOIN (cv
   WHERE bim.key1_id=cv.code_value)
  GROUP BY cv.display, cv.cdf_meaning, cv.code_value
  ORDER BY cv.cdf_meaning
  HEAD REPORT
   cnt = 0, reply_cnt = size(reply->collist,5), stat = alterlist(reply->collist,(reply_cnt+ 5)),
   stat = alterlist(bill_cds->qual,5)
  DETAIL
   found_column = 0
   FOR (f = 1 TO reply_cnt)
     IF ((reply->collist[f].header_text=cv.display))
      found_column = f
     ENDIF
   ENDFOR
   IF (found_column=0)
    reply_cnt = (reply_cnt+ 1)
    IF (mod(reply_cnt,5)=0)
     stat = alterlist(reply->collist,(reply_cnt+ 5))
    ENDIF
    CALL echo("***** adding a heading"), reply->collist[reply_cnt].header_text = cv.display, reply->
    collist[reply_cnt].data_type = 1,
    reply->collist[reply_cnt].hide_ind = 0, found_column = reply_cnt
   ENDIF
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=0)
    stat = alterlist(bill_cds->qual,(5+ cnt))
   ENDIF
   bill_cds->qual[cnt].reply_col = found_column, bill_cds->qual[cnt].bill_sched = cv.display,
   bill_cds->qual[cnt].sched_cd = cv.code_value
   CASE (cv.cdf_meaning)
    OF "CDM_SCHED":
     cdm_sched = 1
    OF "CPT4":
     cpt4 = 1
    OF "HCPCS":
     hcpcs = 1
    OF "MODIFIER":
     modifier = 1
    OF "REVENUE":
     revenue = 1
   ENDCASE
  FOOT REPORT
   stat = alterlist(reply->collist,reply_cnt), stat = alterlist(bill_cds->qual,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply_cnt = size(reply->collist,5)
 IF (cdm_sched=0)
  SET reply_cnt = (reply_cnt+ 1)
  SET stat = alterlist(reply->collist,reply_cnt)
  SET reply->collist[reply_cnt].header_text = "Bill Code (CDM)"
  SET reply->collist[reply_cnt].data_type = 1
  SET reply->collist[reply_cnt].hide_ind = 0
 ENDIF
 IF (cpt4=0)
  SET reply_cnt = (reply_cnt+ 1)
  SET stat = alterlist(reply->collist,reply_cnt)
  SET reply->collist[reply_cnt].header_text = "CPT Codes"
  SET reply->collist[reply_cnt].data_type = 1
  SET reply->collist[reply_cnt].hide_ind = 0
 ENDIF
 IF (modifier=0)
  SET reply_cnt = (reply_cnt+ 1)
  SET stat = alterlist(reply->collist,reply_cnt)
  SET reply->collist[reply_cnt].header_text = "CPT Code Modifiers"
  SET reply->collist[reply_cnt].data_type = 1
  SET reply->collist[reply_cnt].hide_ind = 0
 ENDIF
 IF (revenue=0)
  SET reply_cnt = (reply_cnt+ 1)
  SET stat = alterlist(reply->collist,reply_cnt)
  SET reply->collist[reply_cnt].header_text = "Revenue Code"
  SET reply->collist[reply_cnt].data_type = 1
  SET reply->collist[reply_cnt].hide_ind = 0
 ENDIF
 IF (hcpcs=0)
  SET reply_cnt = (reply_cnt+ 1)
  SET stat = alterlist(reply->collist,reply_cnt)
  SET reply->collist[reply_cnt].header_text = "HCPCS"
  SET reply->collist[reply_cnt].data_type = 1
  SET reply->collist[reply_cnt].hide_ind = 0
 ENDIF
 CALL echo("***** getting price schedule headings")
 SELECT INTO "nl:"
  ps.price_sched_id, ps.price_sched_desc
  FROM (dummyt d  WITH seq = value(size(int_bi->bill_items,5))),
   price_sched_items psi,
   price_sched ps
  PLAN (d)
   JOIN (psi
   WHERE (psi.bill_item_id=int_bi->bill_items[d.seq].bill_item_id)
    AND psi.active_ind=1)
   JOIN (ps
   WHERE ps.price_sched_id=psi.price_sched_id
    AND ps.active_ind=1)
  GROUP BY ps.price_sched_id, ps.price_sched_desc
  HEAD REPORT
   cnt = 0, stat = alterlist(price_scheds->qual,5), reply_cnt = size(reply->collist,5),
   stat = alterlist(reply->collist,(reply_cnt+ 5))
  DETAIL
   found_column = 0
   FOR (f = 1 TO reply_cnt)
     IF ((reply->collist[f].header_text=ps.price_sched_desc))
      found_column = f
     ENDIF
   ENDFOR
   IF (found_column=0)
    reply_cnt = (reply_cnt+ 1)
    IF (mod(reply_cnt,5)=0)
     stat = alterlist(reply->collist,(reply_cnt+ 5))
    ENDIF
    CALL echo("***** adding a heading"), reply->collist[reply_cnt].header_text = ps.price_sched_desc,
    reply->collist[reply_cnt].data_type = 1,
    reply->collist[reply_cnt].hide_ind = 0, found_column = reply_cnt
   ENDIF
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=0)
    stat = alterlist(price_scheds->qual,(5+ cnt))
   ENDIF
   price_scheds->qual[cnt].price_sched = ps.price_sched_desc, price_scheds->qual[cnt].price_cd = ps
   .price_sched_id, price_scheds->qual[cnt].reply_col = found_column
  FOOT REPORT
   stat = alterlist(price_scheds->qual,cnt), stat = alterlist(reply->collist,reply_cnt)
  WITH nocounter
 ;end select
 SET reply_cnt = (reply_cnt+ 1)
 SET stat = alterlist(reply->collist,reply_cnt)
 SET reply->collist[reply_cnt].header_text = "Exam Rooms"
 SET reply->collist[reply_cnt].data_type = 1
 SET reply->collist[reply_cnt].hide_ind = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(int_bi->bill_items,5)))
  PLAN (d)
  HEAD REPORT
   stat = alterlist(reply->rowlist,size(int_bi->bill_items,5)), cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->rowlist[cnt].celllist,reply_cnt), reply->rowlist[cnt].
   celllist[1].string_value = int_bi->bill_items[cnt].task_assay_mnemonic
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(int_bi->bill_items,5))),
   bill_item_modifier bim,
   (dummyt d2  WITH seq = value(size(bill_cds->qual,5)))
  PLAN (d)
   JOIN (bim
   WHERE (bim.bill_item_id=int_bi->bill_items[d.seq].bill_item_id)
    AND bim.active_ind=1)
   JOIN (d2
   WHERE (bill_cds->qual[d2.seq].sched_cd=bim.key1_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), reply->rowlist[d.seq].celllist[bill_cds->qual[d2.seq].reply_col].string_value =
   bim.key6
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  ps.price_sched_id, ps.price_sched_desc
  FROM (dummyt d  WITH seq = value(size(int_bi->bill_items,5))),
   price_sched_items psi,
   (dummyt d2  WITH seq = value(size(price_scheds->qual,5)))
  PLAN (d)
   JOIN (psi
   WHERE (psi.bill_item_id=int_bi->bill_items[d.seq].bill_item_id)
    AND psi.active_ind=1)
   JOIN (d2
   WHERE (price_scheds->qual[d2.seq].price_cd=psi.price_sched_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   reply->rowlist[d.seq].celllist[price_scheds->qual[d2.seq].reply_col].string_value = cnvtstring(psi
    .price,12,2),
   CALL echo(reply->rowlist[d.seq].celllist[price_scheds->qual[d2.seq].reply_col].string_value)
  WITH nocounter, noheading
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(int_bi->bill_items,5))),
   filter_entity_reltn fer,
   code_value cv
  PLAN (d)
   JOIN (fer
   WHERE (fer.parent_entity_id=int_bi->bill_items[d.seq].task_assay_cd))
   JOIN (cv
   WHERE cv.code_value=fer.filter_entity1_id
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  HEAD d.seq
   cnt = (cnt+ 1), exam_rooms = "", int_cnt = 0
  DETAIL
   int_cnt = (int_cnt+ 1)
   IF (int_cnt=1)
    exam_rooms = cv.display
   ELSE
    exam_rooms = concat(exam_rooms,", ",cv.display)
   ENDIF
   CALL echo(exam_rooms)
  FOOT  d.seq
   reply->rowlist[cnt].celllist[reply_cnt].string_value = exam_rooms
  WITH nocounter, noheading
 ;end select
#exit_script
END GO
