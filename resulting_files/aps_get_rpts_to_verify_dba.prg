CREATE PROGRAM aps_get_rpts_to_verify:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 accession = c20
     2 report_id = f8
     2 event_id = f8
     2 status_cd = f8
     2 status_mean = c12
     2 status_prsnl_id = f8
     2 requesting_prsnl_id = f8
     2 proxy_id = f8
     2 edit_dt_tm = dq8
     2 prefix_cd = f8
     2 catalog_cd = f8
     2 order_id = f8
     2 case_id = f8
     2 last_task_assay_cd = f8
     2 service_resource_cd = f8
     2 cyto_primary_rpt_ind = i2
     2 section_cnt = i4
     2 signing_location_cd = f8
     2 section_qual[*]
       3 task_assay_cd = f8
       3 event_id = f8
       3 status_cd = f8
       3 perform_dt_tm = dq8
       3 dictating_prsnl_id = f8
       3 trans_prsnl_id = f8
     2 screener_qual[*]
       3 screener_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET report_ids[1000] = 0.0
 SET csigninproc_cd = 0.0
 SET signinproc_cd = 0.0
 SET performed_cd = 0.0
 SET transcribe_action_cd = 0.0
 SET perform_action_cd = 0.0
 SET cnt = 0
 SET rpt_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1305
   AND cv.cdf_meaning IN ("CSIGNINPROC", "SIGNINPROC", "PERFORMED")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "CSIGNINPROC":
     csigninproc_cd = cv.code_value
    OF "SIGNINPROC":
     signinproc_cd = cv.code_value
    OF "PERFORMED":
     performed_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=21
   AND cv.cdf_meaning IN ("TRANSCRIBE", "PERFORM")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "TRANSCRIBE":
     transcribe_action_cd = cv.code_value
    OF "PERFORM":
     perform_action_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ops.parent_id, cr.case_id
  FROM ap_ops_exception ops,
   case_report cr
  PLAN (ops
   WHERE ops.action_flag IN (1, - (1))
    AND ops.active_ind=0)
   JOIN (cr
   WHERE ops.parent_id=cr.report_id
    AND cr.status_cd IN (csigninproc_cd, signinproc_cd))
  HEAD REPORT
   rpt_cnt = 0
  DETAIL
   rpt_cnt = (rpt_cnt+ 1), report_ids[rpt_cnt] = ops.parent_id
  WITH nocounter
 ;end select
 IF (rpt_cnt > 0)
  SELECT INTO "nl:"
   ops.parent_id
   FROM ap_ops_exception ops,
    (dummyt d  WITH seq = value(rpt_cnt))
   PLAN (d)
    JOIN (ops
    WHERE ops.action_flag IN (1, - (1))
     AND ops.active_ind=0
     AND (ops.parent_id=report_ids[d.seq]))
   DETAIL
    report_ids[d.seq] = ops.parent_id
   WITH nocounter, forupdate(ops)
  ;end select
  IF (curqual != 0)
   UPDATE  FROM ap_ops_exception ops,
     (dummyt d  WITH seq = value(rpt_cnt))
    SET ops.active_ind = 1, ops.updt_cnt = (ops.updt_cnt+ 1), ops.updt_id = reqinfo->updt_id,
     ops.updt_task = reqinfo->updt_task, ops.updt_applctx = reqinfo->updt_applctx, ops.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (ops
     WHERE (ops.parent_id=report_ids[d.seq])
      AND ops.action_flag IN (1, - (1)))
    WITH nocounter
   ;end update
   IF (curqual != 0)
    IF ( NOT (validate(xxdebug)))
     COMMIT
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pc.case_id, ops.parent_id, rt.report_id,
  cyto_primary_rpt_ind = decode(crc.seq,1,0), rdt.task_assay_cd
  FROM ap_ops_exception ops,
   case_report cr,
   pathology_case pc,
   report_task rt,
   prefix_report_r prr,
   (dummyt d1  WITH seq = 1),
   cyto_report_control crc,
   (dummyt d2  WITH seq = 1),
   report_detail_task rdt,
   ce_event_prsnl cep
  PLAN (ops
   WHERE ops.action_flag IN (1, - (1))
    AND ops.active_ind=1)
   JOIN (cr
   WHERE ops.parent_id=cr.report_id
    AND cr.status_cd IN (csigninproc_cd, signinproc_cd))
   JOIN (pc
   WHERE cr.case_id=pc.case_id)
   JOIN (rt
   WHERE cr.report_id=rt.report_id)
   JOIN (prr
   WHERE cr.catalog_cd=prr.catalog_cd
    AND pc.prefix_id=prr.prefix_id)
   JOIN (d1
   WHERE 1=d1.seq)
   JOIN (crc
   WHERE cr.catalog_cd=crc.catalog_cd
    AND prr.primary_ind=1)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (rdt
   WHERE rt.report_id=rdt.report_id
    AND rdt.status_cd=performed_cd)
   JOIN (cep
   WHERE rdt.event_id=cep.event_id
    AND cep.action_type_cd IN (transcribe_action_cd, perform_action_cd)
    AND cep.valid_until_dt_tm > sysdate)
  ORDER BY ops.parent_id, rdt.task_assay_cd
  HEAD REPORT
   cnt = 0
  HEAD ops.parent_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   section = 0, reply->qual[cnt].person_id = pc.person_id, reply->qual[cnt].encntr_id = pc.encntr_id,
   reply->qual[cnt].accession = pc.accession_nbr, reply->qual[cnt].report_id = cr.report_id, reply->
   qual[cnt].event_id = cr.event_id,
   reply->qual[cnt].status_cd = cr.status_cd
   IF (cr.status_cd=csigninproc_cd)
    reply->qual[cnt].status_mean = "CSIGNINPROC"
   ELSE
    reply->qual[cnt].status_mean = "SIGNINPROC"
   ENDIF
   reply->qual[cnt].status_prsnl_id = cr.status_prsnl_id, reply->qual[cnt].requesting_prsnl_id = pc
   .requesting_physician_id, reply->qual[cnt].proxy_id = ops.flex1_id,
   reply->qual[cnt].edit_dt_tm = cnvtdatetime(cr.status_dt_tm), reply->qual[cnt].prefix_cd = pc
   .prefix_id, reply->qual[cnt].catalog_cd = cr.catalog_cd,
   reply->qual[cnt].order_id = rt.order_id, reply->qual[cnt].case_id = pc.case_id, reply->qual[cnt].
   last_task_assay_cd = rt.last_task_assay_cd,
   reply->qual[cnt].service_resource_cd = rt.service_resource_cd, reply->qual[cnt].
   cyto_primary_rpt_ind = cyto_primary_rpt_ind, reply->qual[cnt].signing_location_cd = cr
   .signing_location_cd
  HEAD rdt.task_assay_cd
   section = (section+ 1)
   IF (mod(section,5)=1)
    stat = alterlist(reply->qual[cnt].section_qual,(section+ 4))
   ENDIF
   reply->qual[cnt].section_qual[section].task_assay_cd = rdt.task_assay_cd, reply->qual[cnt].
   section_qual[section].event_id = rdt.event_id, reply->qual[cnt].section_qual[section].status_cd =
   rdt.status_cd
  DETAIL
   IF (cep.action_type_cd=transcribe_action_cd)
    reply->qual[cnt].section_qual[section].trans_prsnl_id = cep.action_prsnl_id
   ELSE
    reply->qual[cnt].section_qual[section].dictating_prsnl_id = cep.action_prsnl_id, reply->qual[cnt]
    .section_qual[section].perform_dt_tm = cnvtdatetime(cep.action_dt_tm)
   ENDIF
  FOOT  ops.parent_id
   stat = alterlist(reply->qual[cnt].section_qual,section), reply->qual[cnt].section_cnt = section
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH outerjoin = d1, dontcare = crc, outerjoin = d2,
   nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
  SET reply->status_data.status = "Z"
 ELSE
  SELECT INTO "nl:"
   cse.screener_id, cse.case_id, cse.sequence
   FROM cyto_screening_event cse,
    (dummyt d1  WITH seq = value(cnt))
   PLAN (d1
    WHERE (reply->qual[d1.seq].cyto_primary_rpt_ind=1))
    JOIN (cse
    WHERE (reply->qual[d1.seq].case_id=cse.case_id)
     AND cse.active_ind=1)
   ORDER BY cse.case_id, cse.sequence
   HEAD cse.case_id
    screener_cnt = 0
   DETAIL
    screener_cnt = (screener_cnt+ 1)
    IF (mod(screener_cnt,10)=1)
     stat = alterlist(reply->qual[d1.seq].screener_qual,(screener_cnt+ 9))
    ENDIF
    reply->qual[d1.seq].screener_qual[screener_cnt].screener_id = cse.screener_id
   FOOT  cse.case_id
    stat = alterlist(reply->qual[d1.seq].screener_qual,screener_cnt)
   WITH nocounter
  ;end select
  SET reply->status_data.status = "S"
 ENDIF
END GO
