CREATE PROGRAM bbt_get_prod_ord_hist:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 order_status_mean = c12
     2 orig_order_dt_tm = dq8
     2 bb_processing_cd = f8
     2 bb_processing_disp = vc
     2 bb_processing_mean = c12
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 cells[*]
       3 cell_cd = f8
       3 cell_disp = vc
       3 cell_mean = c12
       3 product_id = f8
       3 bb_result_id = f8
       3 order_cell_id = f8
     2 assays[*]
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 sequence = i4
       3 reltn_active_ind = i2
       3 bb_result_processing_cd = f8
       3 bb_result_processing_disp = vc
       3 bb_result_processing_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE q_cnt = i4
 DECLARE a_cnt = i4
 DECLARE oc_cnt = i4
 DECLARE max_a_cnt = i4
 DECLARE max_oc_cnt = i4
 SET reply->status_data.status = "F"
 DECLARE activity_parser = vc WITH protect, noconstant("")
 DECLARE bbd_lab_section_cd = f8 WITH protect, noconstant(0.0)
 DECLARE bbdprod_lab_section_cd = f8 WITH protect, noconstant(0.0)
 SET cancel_cd = 0.0
 SET bbt_lab_section_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "BB"
 SET stat = uar_get_meaning_by_codeset(106,cdf_meaning,1,bbt_lab_section_cd)
 IF (stat=1)
  GO TO resize_reply
 ENDIF
 SET cdf_meaning = "CANCELED"
 SET stat = uar_get_meaning_by_codeset(6004,cdf_meaning,1,cancel_cd)
 IF (stat=1)
  GO TO resize_reply
 ENDIF
 SET cdf_meaning = "BBDONOR"
 SET stat = uar_get_meaning_by_codeset(106,cdf_meaning,1,bbd_lab_section_cd)
 IF (stat=1)
  GO TO resize_reply
 ENDIF
 SET cdf_meaning = "BBDONORPROD"
 SET stat = uar_get_meaning_by_codeset(106,cdf_meaning,1,bbdprod_lab_section_cd)
 IF (stat=1)
  GO TO resize_reply
 ENDIF
 IF ((request->activity_type_flag=0))
  SET activity_parser = build("(o.activity_type_cd =",bbt_lab_section_cd,")")
 ELSEIF ((request->activity_type_flag=1))
  SET activity_parser = build("(o.activity_type_cd =",bbd_lab_section_cd," or o.activity_type_cd =",
   bbdprod_lab_section_cd,")")
 ELSE
  SET activity_parser = build("(o.activity_type_cd =",bbt_lab_section_cd," or o.activity_type_cd =",
   bbd_lab_section_cd," or o.activity_type_cd =",
   bbdprod_lab_section_cd,")")
 ENDIF
 SELECT INTO "nl:"
  o.seq, o.order_id, o.order_status_cd,
  o.activity_type_cd, o.orig_order_dt_tm, d1.seq,
  sd.bb_processing_cd, d2.seq, orl.service_resource_cd,
  op.order_id, d3.seq, join_path = decode(pg.seq,"1",ptr.seq,"2","0"),
  pg.task_assay_cd, dta.task_assay_cd, dta.bb_result_processing_cd,
  d5.seq, ptr.task_assay_cd, ptr.active_ind,
  dta2.task_assay_cd, dta2.bb_result_processing_cd, d6.seq,
  cell_yn = decode(oc.seq,"Y","N")
  FROM orders o,
   dummyt d1,
   service_directory sd,
   dummyt d2,
   orc_resource_list orl,
   dummyt d3,
   bb_order_phase op,
   phase_group pg,
   dummyt d5,
   profile_task_r ptr,
   dummyt d6,
   bb_order_cell oc,
   discrete_task_assay dta,
   discrete_task_assay dta2
  PLAN (o
   WHERE (o.product_id=request->productid)
    AND o.order_status_cd != cancel_cd
    AND parser(activity_parser))
   JOIN (((d1
   WHERE d1.seq=1)
   JOIN (sd
   WHERE sd.catalog_cd=o.catalog_cd)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (orl
   WHERE orl.catalog_cd=o.catalog_cd
    AND orl.active_ind=1
    AND orl.primary_ind=1)
   JOIN (((d3
   WHERE d3.seq=1)
   JOIN (op
   WHERE op.order_id=o.order_id)
   JOIN (pg
   WHERE op.order_id > 0
    AND pg.phase_group_cd=op.phase_grp_cd
    AND pg.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=pg.task_assay_cd)
   ) ORJOIN ((d5
   WHERE d5.seq=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=o.catalog_cd)
   JOIN (dta2
   WHERE dta2.task_assay_cd=ptr.task_assay_cd)
   )) ) ORJOIN ((d6
   WHERE d6.seq=1)
   JOIN (oc
   WHERE oc.order_id=o.order_id)
   ))
  ORDER BY o.order_id
  HEAD REPORT
   q_cnt = 0, a_cnt = 0, oc_cnt = 0,
   max_a_cnt = 0, max_oc_cnt = 0
  HEAD o.order_id
   q_cnt += 1, stat = alterlist(reply->qual,q_cnt), reply->qual[q_cnt].order_id = o.order_id,
   reply->qual[q_cnt].orig_order_dt_tm = o.orig_order_dt_tm, reply->qual[q_cnt].order_mnemonic = o
   .order_mnemonic, reply->qual[q_cnt].order_status_cd = o.order_status_cd,
   reply->qual[q_cnt].bb_processing_cd = sd.bb_processing_cd, reply->qual[q_cnt].service_resource_cd
    = orl.service_resource_cd, oc_cnt = 0,
   a_cnt = 0
  DETAIL
   IF (cell_yn="Y")
    oc_cnt += 1, stat = alterlist(reply->qual[q_cnt].cells,oc_cnt)
    IF (oc_cnt > max_oc_cnt)
     max_oc_cnt = oc_cnt
    ENDIF
    reply->qual[q_cnt].cells[oc_cnt].cell_cd = oc.cell_cd, reply->qual[q_cnt].cells[oc_cnt].
    product_id = oc.product_id, reply->qual[q_cnt].cells[oc_cnt].bb_result_id = oc.bb_result_id,
    reply->qual[q_cnt].cells[oc_cnt].order_cell_id = oc.order_cell_id
   ENDIF
   IF (((join_path="1") OR (join_path="2")) )
    a_cnt += 1, stat = alterlist(reply->qual[q_cnt].assays,a_cnt)
    IF (a_cnt > max_a_cnt)
     max_a_cnt = a_cnt
    ENDIF
    IF (join_path="2")
     reply->qual[q_cnt].assays[a_cnt].task_assay_cd = ptr.task_assay_cd, reply->qual[q_cnt].assays[
     a_cnt].sequence = ptr.sequence, reply->qual[q_cnt].assays[a_cnt].bb_result_processing_cd = dta2
     .bb_result_processing_cd,
     reply->qual[q_cnt].assays[a_cnt].reltn_active_ind = ptr.active_ind
    ENDIF
    IF (join_path="1")
     reply->qual[q_cnt].assays[a_cnt].task_assay_cd = pg.task_assay_cd, reply->qual[q_cnt].assays[
     a_cnt].sequence = pg.sequence, reply->qual[q_cnt].assays[a_cnt].bb_result_processing_cd = dta
     .bb_result_processing_cd,
     reply->qual[q_cnt].assays[a_cnt].reltn_active_ind = 2
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d5, outerjoin = d6,
   maxqual(rc,1)
 ;end select
#resize_reply
 IF (q_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET q_cnt = 1
 ENDIF
END GO
