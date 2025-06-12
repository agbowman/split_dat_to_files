CREATE PROGRAM aps_add_case_specimen:dba
 RECORD reply(
   1 order_catalog_cd = f8
   1 spec_qual[1]
     2 processing_task_id = f8
     2 case_specimen_id = f8
     2 spec_comments_long_text_id = f8
     2 task_comments_long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD req200423(
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 delete_flag = i2
 )
 RECORD rep200423(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD cont_upd_orders
 RECORD cont_upd_orders(
   1 new_accession_id = f8
   1 new_accession = vc
   1 qual[*]
     2 order_id = f8
 )
 FREE RECORD cont_upd_list
 RECORD cont_upd_list(
   1 qual[*]
     2 container_id = f8
     2 max_accession_size = i4
     2 barcode_accession = vc
     2 container_nbr = i4
 )
 DECLARE update_spec_container_accession(null) = i2
 EXECUTE accrtl
 SUBROUTINE update_spec_container_accession(null)
   DECLARE cont_upd_orders_cnt = i4 WITH protect, noconstant(0)
   DECLARE cont_to_updt_cnt = i4 WITH protect, noconstant(0)
   DECLARE lcontainernbr = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET cont_upd_orders_cnt = size(cont_upd_orders->qual,5)
   IF (cont_upd_orders_cnt > 0)
    SELECT INTO "nl:"
     FROM container_accession ca
     WHERE (ca.accession_id=cont_upd_orders->new_accession_id)
     ORDER BY ca.accession_container_nbr DESC
     HEAD ca.accession_id
      lcontainernbr = ca.accession_container_nbr
     WITH nocounter
    ;end select
    SELECT INTO "n1:"
     FROM (dummyt d  WITH seq = value(cont_upd_orders_cnt)),
      order_serv_res_container osrc,
      container c,
      collection_class cc
     PLAN (d)
      JOIN (osrc
      WHERE (cont_upd_orders->qual[d.seq].order_id > 0)
       AND (osrc.order_id=cont_upd_orders->qual[d.seq].order_id))
      JOIN (c
      WHERE osrc.container_id > 0
       AND osrc.container_id=c.container_id)
      JOIN (cc
      WHERE c.coll_class_cd=cc.coll_class_cd)
     ORDER BY osrc.container_id
     HEAD osrc.container_id
      cont_to_updt_cnt = (cont_to_updt_cnt+ 1), stat = alterlist(cont_upd_list->qual,cont_to_updt_cnt
       ), cont_upd_list->qual[cont_to_updt_cnt].container_id = osrc.container_id,
      lcontainernbr = (lcontainernbr+ 1), cont_upd_list->qual[cont_to_updt_cnt].container_nbr =
      lcontainernbr, cont_upd_list->qual[cont_to_updt_cnt].barcode_accession =
      uar_acctruncateunformatted(nullterm(cont_upd_orders->new_accession),0,cc.max_accession_size)
     WITH nocounter
    ;end select
    IF (cont_to_updt_cnt > 0)
     UPDATE  FROM container_accession ca,
       (dummyt d  WITH seq = value(cont_to_updt_cnt))
      SET ca.accession = cont_upd_orders->new_accession, ca.accession_id = cont_upd_orders->
       new_accession_id, ca.accession_container_nbr = cont_upd_list->qual[d.seq].container_nbr,
       ca.barcode_accession = cont_upd_list->qual[d.seq].barcode_accession, ca.updt_cnt = (ca
       .updt_cnt+ 1), ca.updt_applctx = reqinfo->updt_applctx,
       ca.updt_dt_tm = cnvtdatetime(curdate,curtime3), ca.updt_id = reqinfo->updt_id, ca.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (ca
       WHERE (ca.container_id=cont_upd_list->qual[d.seq].container_id))
      WITH nocounter
     ;end update
     IF (cont_to_updt_cnt=curqual)
      RETURN(1)
     ELSE
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET spec_task_assay_cd = 0.0
 SET order_status_cd = 0.0
 SET nbr_to_insert = cnvtint(size(request->spec_qual,5))
 SET nbr_ops_exceptions = 0
 SET cnt = 0
 SET x = 0
 SET order_icd9_cd = 0.0
 SET nomen_entity_inact_cnt = 0
 DECLARE naccnupdtordercnt = i4 WITH protect, noconstant(0)
 IF (nbr_to_insert > 1)
  SET stat = alter(reply->spec_qual,nbr_to_insert)
 ENDIF
 FOR (x = 1 TO nbr_to_insert)
   IF ((request->spec_qual[x].order_id=0.0))
    SET nbr_ops_exceptions = (nbr_ops_exceptions+ 1)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  d.seq, cs.case_id
  FROM case_specimen cs,
   (dummyt d  WITH seq = value(nbr_to_insert))
  PLAN (d)
   JOIN (cs
   WHERE (request->case_id=cs.case_id)
    AND (request->spec_qual[d.seq].specimen_tag_cd=cs.specimen_tag_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 IF (cnt != 0)
  CALL echo("dup ids")
  GO TO dup_ids
 ENDIF
 FOR (x = 1 TO nbr_to_insert)
  SELECT INTO "nl:"
   seq_nbr = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    reply->spec_qual[x].case_specimen_id = seq_nbr
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
 ENDFOR
 FOR (x = 1 TO nbr_to_insert)
  SELECT INTO "nl:"
   seq_nbr = seq(pathnet_seq,nextval)
   FROM dual
   DETAIL
    reply->spec_qual[x].processing_task_id = seq_nbr
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
 ENDFOR
 SET s_active_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  HEAD REPORT
   s_active_cd = 0.0
  DETAIL
   s_active_cd = cv.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO nbr_to_insert)
  IF (trim(request->spec_qual[x].special_comments) > " ")
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     reply->spec_qual[x].spec_comments_long_text_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
  ENDIF
  IF (trim(request->spec_qual[x].task_comments) > " ")
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     reply->spec_qual[x].task_comments_long_text_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
  ENDIF
 ENDFOR
 INSERT  FROM long_text lt,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET lt.long_text_id = reply->spec_qual[d.seq].spec_comments_long_text_id, lt.updt_cnt = 0, lt
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
   updt_applctx,
   lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "CASE_SPECIMEN", lt
   .parent_entity_id = reply->spec_qual[d.seq].case_specimen_id,
   lt.long_text = request->spec_qual[d.seq].special_comments
  PLAN (d
   WHERE (reply->spec_qual[d.seq].spec_comments_long_text_id > 0))
   JOIN (lt)
  WITH nocounter
 ;end insert
 INSERT  FROM case_specimen c,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET c.case_id = request->case_id, c.case_specimen_id = reply->spec_qual[d.seq].case_specimen_id, c
   .specimen_cd = request->spec_qual[d.seq].specimen_cd,
   c.nomenclature_id = 0.0, c.specimen_description =
   IF (textlen(request->spec_qual[d.seq].specimen_description) > 0) request->spec_qual[d.seq].
    specimen_description
   ELSE null
   ENDIF
   , c.spec_comments_long_text_id = reply->spec_qual[d.seq].spec_comments_long_text_id,
   c.specimen_tag_id = request->spec_qual[d.seq].specimen_tag_cd, c.collect_dt_tm = cnvtdatetime(
    request->spec_qual[d.seq].collect_dt_tm), c.received_dt_tm = cnvtdatetime(request->spec_qual[d
    .seq].received_dt_tm),
   c.received_id = reqinfo->updt_id, c.received_fixative_cd = request->spec_qual[d.seq].
   received_fixative_cd, c.inadequacy_reason_cd = request->spec_qual[d.seq].adequacy_reason_cd,
   c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo
   ->updt_task,
   c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
  PLAN (d)
   JOIN (c)
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_to_insert)
  GO TO cs_failed
 ENDIF
 INSERT  FROM ap_ops_exception aoe,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET aoe.parent_id = reply->spec_qual[d.seq].case_specimen_id, aoe.action_flag = 2, aoe.active_ind
    = 1,
   aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
   reqinfo->updt_task,
   aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
  PLAN (d
   WHERE (request->spec_qual[d.seq].order_id=0.0))
   JOIN (aoe
   WHERE (aoe.parent_id=reply->spec_qual[d.seq].case_specimen_id)
    AND aoe.action_flag=2)
  WITH nocounter, outerjoin = d, dontexist
 ;end insert
 IF (curqual != nbr_ops_exceptions)
  GO TO ops_failed
 ENDIF
 IF (curutc=1)
  INSERT  FROM ap_ops_exception_detail aoed,
    (dummyt d  WITH seq = value(nbr_to_insert))
   SET aoed.action_flag = 2, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
    aoed.parent_id = reply->spec_qual[d.seq].case_specimen_id, aoed.sequence = 1, aoed.updt_applctx
     = reqinfo->updt_applctx,
    aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
    updt_id,
    aoed.updt_task = reqinfo->updt_task
   PLAN (d
    WHERE (request->spec_qual[d.seq].order_id=0.0))
    JOIN (aoed
    WHERE (aoed.parent_id=reply->spec_qual[d.seq].case_specimen_id)
     AND aoed.action_flag=2)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_ops_exceptions)
   GO TO ops_det_failed
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pc.prefix_id, ap.order_catalog_cd, ptr.task_assay_cd
  FROM pathology_case pc,
   ap_prefix ap,
   profile_task_r ptr
  PLAN (pc
   WHERE (request->case_id=pc.case_id))
   JOIN (ap
   WHERE pc.prefix_id=ap.prefix_id)
   JOIN (ptr
   WHERE ap.order_catalog_cd=ptr.catalog_cd
    AND ptr.item_type_flag=0
    AND ptr.active_ind=1
    AND ptr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((ptr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ptr.end_effective_dt_tm=null
   )) )
  HEAD REPORT
   spec_task_assay_cd = 0.0
  DETAIL
   spec_task_assay_cd = ptr.task_assay_cd, reply->order_catalog_cd = ap.order_catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1305
   AND c.cdf_meaning="ORDERED"
  HEAD REPORT
   order_status_cd = 0.0
  DETAIL
   order_status_cd = c.code_value
  WITH nocounter
 ;end select
 INSERT  FROM long_text lt,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET lt.long_text_id = reply->spec_qual[d.seq].task_comments_long_text_id, lt.updt_cnt = 0, lt
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
   updt_applctx,
   lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
    curdate,curtime3),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "PROCESSING_TASK", lt
   .parent_entity_id = reply->spec_qual[d.seq].processing_task_id,
   lt.long_text = request->spec_qual[d.seq].task_comments
  PLAN (d
   WHERE (reply->spec_qual[d.seq].task_comments_long_text_id > 0))
   JOIN (lt)
 ;end insert
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(nbr_to_insert))
  DETAIL
   stat = alterlist(req200423->spec_qual,d.seq), req200423->spec_qual[d.seq].case_specimen_id = reply
   ->spec_qual[d.seq].case_specimen_id, req200423->spec_qual[d.seq].delete_flag = 0
  WITH nocounter
 ;end select
 EXECUTE aps_chk_case_synoptic_ws  WITH replace("REQUEST","REQ200423"), replace("REPLY","REP200423")
 IF ((rep200423->status_data.status="F"))
  EXECUTE goto synoptic_failed
 ENDIF
 INSERT  FROM processing_task pt,
   (dummyt d  WITH seq = value(nbr_to_insert))
  SET pt.processing_task_id = reply->spec_qual[d.seq].processing_task_id, pt.case_id = request->
   case_id, pt.case_specimen_id = reply->spec_qual[d.seq].case_specimen_id,
   pt.case_specimen_tag_id = request->spec_qual[d.seq].specimen_tag_cd, pt.order_id = request->
   spec_qual[d.seq].order_id, pt.create_inventory_flag = 4,
   pt.cassette_id = 0, pt.cassette_tag_id = 0, pt.slide_id = 0,
   pt.slide_tag_id = 0, pt.task_assay_cd = spec_task_assay_cd, pt.service_resource_cd = request->
   spec_qual[d.seq].service_resource_cd,
   pt.priority_cd = request->spec_qual[d.seq].priority_cd, pt.request_dt_tm = cnvtdatetime(curdate,
    curtime3), pt.request_prsnl_id = reqinfo->updt_id,
   pt.status_cd = order_status_cd, pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   pt.updt_dt_tm = cnvtdatetime(curdate,curtime3), pt.updt_id = reqinfo->updt_id, pt.updt_task =
   reqinfo->updt_task,
   pt.updt_cnt = 0, pt.updt_applctx = reqinfo->updt_applctx, pt.comments_long_text_id = reply->
   spec_qual[d.seq].task_comments_long_text_id
  PLAN (d)
   JOIN (pt)
  WITH nocounter
 ;end insert
 IF (curqual != nbr_to_insert)
  GO TO task_failed
 ENDIF
 IF ((request->transfer_logged_in_cont_accns=1))
  SELECT INTO "nl:"
   FROM pathology_case pc,
    accession a
   PLAN (pc
    WHERE (pc.case_id=request->case_id))
    JOIN (a
    WHERE a.accession=trim(pc.accession_nbr))
   DETAIL
    cont_upd_orders->new_accession_id = a.accession_id, cont_upd_orders->new_accession = a.accession
   WITH nocounter
  ;end select
  FOR (y = 1 TO nbr_to_insert)
    IF ((request->spec_qual[y].order_id > 0.0))
     SET naccnupdtordercnt = (naccnupdtordercnt+ 1)
     SET stat = alterlist(cont_upd_orders->qual,naccnupdtordercnt)
     SET cont_upd_orders->qual[naccnupdtordercnt].order_id = request->spec_qual[y].order_id
    ENDIF
  ENDFOR
  IF (update_spec_container_accession(null) != 1)
   GO TO cont_accn_updt_failed
  ENDIF
 ENDIF
 DELETE  FROM ap_login_order_list a,
   (dummyt d  WITH seq = value(cnvtint(size(request->spec_qual,5))))
  SET a.seq = 1
  PLAN (d)
   JOIN (a
   WHERE (request->spec_qual[d.seq].order_id > 0)
    AND (request->spec_qual[d.seq].order_id=a.order_id))
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=23549
   AND cv.cdf_meaning="ORDERICD9"
   AND cv.active_ind=1
  HEAD REPORT
   order_icd9_cd = 0.0
  DETAIL
   order_icd9_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM nomen_entity_reltn ner,
   (dummyt d  WITH seq = value(nbr_to_insert))
  PLAN (d
   WHERE (request->spec_qual[d.seq].order_id != 0.0))
   JOIN (ner
   WHERE ner.parent_entity_name="ORDERS"
    AND (ner.parent_entity_id=request->spec_qual[d.seq].order_id)
    AND ner.reltn_type_cd=order_icd9_cd)
  HEAD REPORT
   nomen_entity_inact_cnt = 0
  DETAIL
   nomen_entity_inact_cnt = (nomen_entity_inact_cnt+ 1)
   IF (mod(nomen_entity_inact_cnt,10)=1)
    stat = alterlist(request->nomen_entity_inact_qual,(nomen_entity_inact_cnt+ 9))
   ENDIF
   request->nomen_entity_inact_qual[nomen_entity_inact_cnt].nomen_entity_reltn_id = ner
   .nomen_entity_reltn_id
  FOOT REPORT
   stat = alterlist(request->nomen_entity_inact_qual,nomen_entity_inact_cnt)
  WITH nocounter
 ;end select
 IF (nomen_entity_inact_cnt > 0)
  EXECUTE dcp_inact_nomen_entity_reltn
 ENDIF
 GO TO exit_script
#dup_ids
 SET reply->status_data.subeventstatus[1].operationname = "DUP SPECIMEN ID"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
 SET failed = "T"
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#cs_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
 SET failed = "T"
 GO TO exit_script
#ops_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
 SET failed = "T"
 GO TO exit_script
#ops_det_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 SET failed = "T"
 GO TO exit_script
#task_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#synoptic_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_CASE_SYNOPTIC_WS"
 SET failed = "T"
#cont_accn_updt_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CONTAINER_ACCESSION"
 SET failed = "T"
#exit_script
 FREE RECORD req200423
 FREE RECORD rep200423
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
