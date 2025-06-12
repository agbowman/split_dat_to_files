CREATE PROGRAM bed_ens_vvl_auto_poc:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_syn
 RECORD temp_syn(
   1 syns[*]
     2 syn_id = f8
     2 item_id = f8
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET rx_code_value = 0.0
 SET rx_code_value = uar_get_code_by("MEANING",6011,"RXMNEMONIC")
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym os,
   synonym_item_r s
  PLAN (oc
   WHERE oc.catalog_type_cd=pharm_ct
    AND oc.activity_type_cd=pharm_at
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (os
   WHERE os.catalog_cd=oc.catalog_cd
    AND os.catalog_type_cd=pharm_ct
    AND os.activity_type_cd=pharm_at
    AND ((os.mnemonic_type_cd+ 0)=rx_code_value)
    AND os.active_ind=1
    AND os.item_id > 0)
   JOIN (s
   WHERE s.synonym_id=outerjoin(os.synonym_id)
    AND s.item_id=outerjoin(os.item_id))
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_syn->syns,100)
  DETAIL
   IF (s.synonym_id=0)
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(temp_syn->syns,(tot_cnt+ 100)), cnt = 1
    ENDIF
    temp_syn->syns[tot_cnt].syn_id = os.synonym_id, temp_syn->syns[tot_cnt].item_id = os.item_id
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_syn->syns,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM synonym_item_r s,
   (dummyt d  WITH seq = value(tot_cnt))
  SET s.synonym_id = temp_syn->syns[d.seq].syn_id, s.item_id = temp_syn->syns[d.seq].item_id, s
   .updt_applctx = reqinfo->updt_applctx,
   s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(curdate,curtime), s.updt_id = reqinfo->updt_id,
   s.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (s)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
