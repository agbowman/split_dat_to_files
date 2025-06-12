CREATE PROGRAM bed_ens_mos_cpy_sent_vv:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_sent
 RECORD temp_sent(
   1 facs[*]
     2 source_code_value = f8
     2 dest_code_value = f8
     2 sentences[*]
       3 sentence_id = f8
 )
 FREE SET deletes
 RECORD deletes(
   1 ids[*]
     2 id = f8
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET req_cnt = size(request->facilities,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET ordsent_cd = 0.0
 SET ordsent_cd = uar_get_code_by("MEANING",30620,"ORDERSENT")
 SET fcnt = 0
 SET stat = alterlist(temp_sent->facs,req_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   filter_entity_reltn f,
   order_sentence os,
   order_catalog_synonym ocs,
   order_catalog oc
  PLAN (d)
   JOIN (f
   WHERE f.parent_entity_name="ORDER_SENTENCE"
    AND f.filter_entity1_name="LOCATION"
    AND (f.filter_entity1_id=request->facilities[d.seq].source_code_value))
   JOIN (os
   WHERE os.order_sentence_id=f.parent_entity_id
    AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
   JOIN (ocs
   WHERE ocs.synonym_id=os.parent_entity_id
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ((oc.catalog_type_cd+ 0)=pharm_ct)
    AND ((oc.activity_type_cd+ 0)=pharm_at)
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   fcnt = 0
  HEAD d.seq
   fcnt = (fcnt+ 1), temp_sent->facs[fcnt].source_code_value = request->facilities[d.seq].
   source_code_value, temp_sent->facs[fcnt].dest_code_value = request->facilities[d.seq].
   dest_code_value,
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_sent->facs[fcnt].sentences,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_sent->facs[fcnt].sentences,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_sent->facs[fcnt].sentences[tot_cnt].sentence_id = os.order_sentence_id
  FOOT  d.seq
   stat = alterlist(temp_sent->facs[fcnt].sentences,tot_cnt)
  FOOT REPORT
   stat = alterlist(temp_sent->facs,fcnt)
  WITH nocounter
 ;end select
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(fcnt)),
   filter_entity_reltn f,
   ord_cat_sent_r ocsr,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (f
   WHERE f.parent_entity_name="ORDER_SENTENCE"
    AND f.filter_entity1_name="LOCATION"
    AND (f.filter_entity1_id=temp_sent->facs[d.seq].dest_code_value))
   JOIN (ocsr
   WHERE ocsr.order_sentence_id=f.parent_entity_id)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND ocs.catalog_type_cd=pharm_ct
    AND ocs.orderable_type_flag IN (0, 1)
    AND ocs.active_ind=1)
  HEAD REPORT
   dcnt = 0, alterlist_dcnt = 0, stat = alterlist(deletes->ids,100)
  DETAIL
   dcnt = (dcnt+ 1), alterlist_dcnt = (alterlist_dcnt+ 1)
   IF (alterlist_dcnt > 100)
    stat = alterlist(deletes->ids,(dcnt+ 100)), alterlist_dcnt = 1
   ENDIF
   deletes->ids[dcnt].id = f.filter_entity_reltn_id
  FOOT REPORT
   stat = alterlist(deletes->ids,dcnt)
  WITH nocounter
 ;end select
 IF (dcnt > 0)
  SET ierrcode = 0
  DELETE  FROM (dummyt d  WITH seq = value(dcnt)),
    filter_entity_reltn f
   SET f.seq = 1
   PLAN (d)
    JOIN (f
    WHERE (f.filter_entity_reltn_id=deletes->ids[d.seq].id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DELETE VV"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (x = 1 TO fcnt)
  SET sent_cnt = size(temp_sent->facs[x].sentences,5)
  IF (sent_cnt > 0)
   SET ierrcode = 0
   INSERT  FROM filter_entity_reltn f,
     (dummyt d  WITH seq = value(sent_cnt))
    SET f.filter_entity_reltn_id = seq(reference_seq,nextval), f.parent_entity_name =
     "ORDER_SENTENCE", f.parent_entity_id = temp_sent->facs[x].sentences[d.seq].sentence_id,
     f.filter_entity1_name = "LOCATION", f.filter_entity1_id = temp_sent->facs[x].dest_code_value, f
     .filter_entity2_name = null,
     f.filter_entity2_id = 0, f.filter_entity3_name = null, f.filter_entity3_id = 0,
     f.filter_entity4_name = null, f.filter_entity4_id = 0, f.filter_entity5_name = null,
     f.filter_entity5_id = 0, f.filter_type_cd = ordsent_cd, f.exclusion_filter_ind = null,
     f.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), f.end_effective_dt_tm = cnvtdatetime(
      "31-dec-2100 00:00:00.00"), f.updt_id = reqinfo->updt_id,
     f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_task = reqinfo->updt_task, f.updt_applctx
      = reqinfo->updt_applctx,
     f.updt_cnt = 0
    PLAN (d)
     JOIN (f)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat("INSERT VV ",cnvtstring(x))
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
