CREATE PROGRAM bbt_get_product_orders:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 order_mnemonic = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = vc
     2 order_status_mean = c12
     2 updt_cnt = i4
     2 bb_processing_cd = f8
     2 bb_processing_disp = vc
     2 bb_processing_mean = c12
     2 bb_default_phases_cd = f8
     2 phase_grp_cd = f8
     2 phase_grp_disp = vc
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 activity_type = c12
     2 cell_cnt = i4
     2 cells[*]
       3 order_id = f8
       3 order_cell_id = f8
       3 cell_cd = f8
       3 cell_disp = vc
       3 cell_mean = c12
       3 product_id = f8
       3 bb_result_id = f8
       3 order_cell_updt_cnt = i4
     2 assays_cnt = i4
     2 assays[*]
       3 task_assay_cd = f8
       3 sequence = i4
       3 pending_ind = i2
       3 order_phase_id = f8
     2 order_dt_tm = dq8
     2 order_tech_id = f8
     2 order_tech_username = c50
     2 synonym_id = f8
     2 oe_format_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET cv_required_recs = 3
 DECLARE cv_cnt = i4
 SET activity_type_codeset = 106
 SET activity_type_bb_cdf = "BB"
 SET order_status_codeset = 6004
 SET order_status_canceled_cdf = "CANCELED"
 DECLARE order_status_canceled_cd = f8
 DECLARE bb_activity_cd = f8
 DECLARE q_cnt = i4
 DECLARE a_cnt = i4
 DECLARE oc_cnt = i4
 DECLARE code_set = i4 WITH noconstant(0)
 DECLARE cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE sscript_name = c22 WITH constant("BBT_GET_PRODUCT_ORDERS")
 DECLARE code_value = f8 WITH noconstant(0.0)
 DECLARE order_action_ordered_cd = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET cv_cnt = 0
 SET code_value = 0.0
 SET cdf_meaning = "ORDER"
 SET code_set = 6003
 EXECUTE cpm_get_cd_for_cdf
 IF (code_value > 0)
  SET order_action_ordered_cd = code_value
  SET cv_cnt += 1
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "get order action code_value"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_current_order_result"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "could not get order action code_value"
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = order_status_canceled_cdf
 SET code_set = order_status_codeset
 EXECUTE cpm_get_cd_for_cdf
 IF (code_value > 0)
  SET order_status_canceled_cd = code_value
  SET cv_cnt += 1
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "get cancel order status code_value"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_current_order_result"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "could not get order status cancel code_value"
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = activity_type_bb_cdf
 SET code_set = activity_type_codeset
 EXECUTE cpm_get_cd_for_cdf
 IF (code_value > 0)
  SET bb_activity_cd = code_value
  SET cv_cnt += 1
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "get bb activity type code_value"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_current_order_result"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "could not get bb activity code_value"
  GO TO exit_script
 ENDIF
 IF (cv_cnt != cv_required_recs)
  GO TO exit_script
 ENDIF
 SELECT
  IF (validate(request->retrieve_only_current_phase_ind,0)=1)
   PLAN (d_cat)
    JOIN (o
    WHERE (o.product_id=request->productid)
     AND o.product_id != 0
     AND ((o.activity_type_cd+ 0)=bb_activity_cd)
     AND (((request->cat_cnt=0)) OR ((request->cat_cnt > 0)
     AND ((o.catalog_cd+ 0)=request->catlist[d_cat.seq].catalog_cd)))
     AND o.active_ind=1)
    JOIN (sd
    WHERE sd.catalog_cd=o.catalog_cd
     AND sd.catalog_cd != 0
     AND sd.active_ind=1)
    JOIN (orl
    WHERE orl.catalog_cd=o.catalog_cd
     AND orl.catalog_cd != 0
     AND orl.primary_ind=1
     AND orl.active_ind=1)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=order_action_ordered_cd)
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
    JOIN (((d1
    WHERE d1.seq=1)
    JOIN (((op
    WHERE op.order_id=o.order_id
     AND op.active_ind=1)
    JOIN (pg
    WHERE pg.phase_group_cd=op.phase_grp_cd
     AND pg.active_ind=1)
    ) ORJOIN ((d2
    WHERE d2.seq=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=o.catalog_cd
     AND ptr.active_ind=1)
    )) ) ORJOIN ((d3
    WHERE d3.seq=1)
    JOIN (oc
    WHERE oc.order_id=o.order_id)
    JOIN (cv
    WHERE cv.code_value=oc.cell_cd
     AND cv.active_ind=1
     AND cv.code_value > 0
     AND cv.code_set=1603
     AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate))
    ))
  ELSE
   PLAN (d_cat)
    JOIN (o
    WHERE (o.product_id=request->productid)
     AND o.product_id != 0
     AND ((o.activity_type_cd+ 0)=bb_activity_cd)
     AND (((request->cat_cnt=0)) OR ((request->cat_cnt > 0)
     AND ((o.catalog_cd+ 0)=request->catlist[d_cat.seq].catalog_cd)))
     AND o.active_ind=1)
    JOIN (sd
    WHERE sd.catalog_cd=o.catalog_cd
     AND sd.catalog_cd != 0
     AND sd.active_ind=1)
    JOIN (orl
    WHERE orl.catalog_cd=o.catalog_cd
     AND orl.catalog_cd != 0
     AND orl.primary_ind=1
     AND orl.active_ind=1)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_type_cd=order_action_ordered_cd)
    JOIN (p
    WHERE p.person_id=oa.action_personnel_id)
    JOIN (((d1
    WHERE d1.seq=1)
    JOIN (((op
    WHERE op.order_id=o.order_id)
    JOIN (pg
    WHERE pg.phase_group_cd=op.phase_grp_cd
     AND pg.active_ind=1)
    ) ORJOIN ((d2
    WHERE d2.seq=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=o.catalog_cd
     AND ptr.active_ind=1)
    )) ) ORJOIN ((d3
    WHERE d3.seq=1)
    JOIN (oc
    WHERE oc.order_id=o.order_id)
    JOIN (cv
    WHERE cv.code_value=oc.cell_cd
     AND cv.active_ind=1
     AND cv.code_value > 0
     AND cv.code_set=1603
     AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
     AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate))
    ))
  ENDIF
  INTO "nl:"
  cat_seq =
  IF ((request->cat_cnt > 0)) request->catlist[d_cat.seq].sequence
  ELSE 0
  ENDIF
  , o.seq, o.order_id,
  sd.bb_processing_cd, orl.service_resource_cd, d1.seq,
  op.order_id, join_path = decode(pg.seq,"1",ptr.seq,"2","0"), pg.task_assay_cd,
  d2.seq, ptr.task_assay_cd, d3.seq,
  cell_yn = decode(oc.seq,"Y","N"), cv.display
  FROM (dummyt d_cat  WITH seq = value(request->cat_cnt)),
   orders o,
   service_directory sd,
   orc_resource_list orl,
   dummyt d1,
   bb_order_phase op,
   phase_group pg,
   dummyt d2,
   profile_task_r ptr,
   dummyt d3,
   bb_order_cell oc,
   code_value cv,
   order_action oa,
   prsnl p
  ORDER BY o.order_id
  HEAD REPORT
   stat = alterlist(reply->qual,2), q_cnt = 0, a_cnt = 0,
   oc_cnt = 0
  HEAD o.order_id
   IF (o.order_status_cd != order_status_canceled_cd)
    q_cnt += 1
    IF (mod(q_cnt,2)=1
     AND q_cnt != 1)
     stat = alterlist(reply->qual,(q_cnt+ 2))
    ENDIF
    reply->qual[q_cnt].activity_type = activity_type_bb_cdf, reply->qual[q_cnt].order_id = o.order_id,
    reply->qual[q_cnt].order_mnemonic = o.order_mnemonic,
    reply->qual[q_cnt].catalog_cd = o.catalog_cd, reply->qual[q_cnt].catalog_type_cd = o
    .catalog_type_cd, reply->qual[q_cnt].order_status_cd = o.order_status_cd,
    reply->qual[q_cnt].updt_cnt = o.updt_cnt, reply->qual[q_cnt].bb_processing_cd = sd
    .bb_processing_cd, reply->qual[q_cnt].bb_default_phases_cd = sd.bb_default_phases_cd,
    reply->qual[q_cnt].phase_grp_cd = op.phase_grp_cd, reply->qual[q_cnt].service_resource_cd = orl
    .service_resource_cd, reply->qual[q_cnt].order_dt_tm = oa.action_dt_tm,
    reply->qual[q_cnt].order_tech_id = oa.action_personnel_id, reply->qual[q_cnt].order_tech_username
     = p.username, reply->qual[q_cnt].synonym_id = o.synonym_id,
    reply->qual[q_cnt].oe_format_id = o.oe_format_id, oc_cnt = 0, a_cnt = 0
   ENDIF
  DETAIL
   IF (o.order_status_cd != order_status_canceled_cd)
    IF (cell_yn="Y")
     oc_cnt += 1, stat = alterlist(reply->qual[q_cnt].cells,oc_cnt), reply->qual[q_cnt].cell_cnt =
     oc_cnt,
     reply->qual[q_cnt].cells[oc_cnt].order_id = o.order_id, reply->qual[q_cnt].cells[oc_cnt].
     order_cell_id = oc.order_cell_id, reply->qual[q_cnt].cells[oc_cnt].cell_cd = oc.cell_cd,
     reply->qual[q_cnt].cells[oc_cnt].cell_disp = cv.display, reply->qual[q_cnt].cells[oc_cnt].
     cell_mean = cv.cdf_meaning, reply->qual[q_cnt].cells[oc_cnt].product_id = oc.product_id,
     reply->qual[q_cnt].cells[oc_cnt].bb_result_id = oc.bb_result_id, reply->qual[q_cnt].cells[oc_cnt
     ].order_cell_updt_cnt = oc.updt_cnt
    ENDIF
    IF (((join_path="1") OR (join_path="2")) )
     a_cnt += 1, stat = alterlist(reply->qual[q_cnt].assays,a_cnt), reply->qual[q_cnt].assays_cnt =
     a_cnt
     IF (join_path="2")
      reply->qual[q_cnt].assays[a_cnt].task_assay_cd = ptr.task_assay_cd, reply->qual[q_cnt].assays[
      a_cnt].order_phase_id = 0, reply->qual[q_cnt].assays[a_cnt].sequence = ptr.sequence,
      reply->qual[q_cnt].assays[a_cnt].pending_ind = ptr.pending_ind
     ENDIF
     IF (join_path="1")
      reply->qual[q_cnt].assays[a_cnt].task_assay_cd = pg.task_assay_cd, reply->qual[q_cnt].assays[
      a_cnt].order_phase_id = op.order_phase_id, reply->qual[q_cnt].assays[a_cnt].sequence = pg
      .sequence,
      reply->qual[q_cnt].assays[a_cnt].pending_ind = pg.required_ind
     ENDIF
    ENDIF
   ENDIF
  FOOT  o.order_id
   row + 0
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, orahintcbo("index(O XIF886ORDERS)")
 ;end select
#resize_reply
 IF (q_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET q_cnt = 1
 ENDIF
 SET stat = alterlist(reply->qual,q_cnt)
#exit_script
END GO
