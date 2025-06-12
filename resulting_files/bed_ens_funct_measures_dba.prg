CREATE PROGRAM bed_ens_funct_measures:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD items_to_ens
 RECORD items_to_ens(
   1 svc_entities[*]
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 measures[*]
       3 measure_id = f8
       3 measure_exists = i2
 )
 DECLARE req_cnt = i4 WITH noconstant(0), protect
 DECLARE item_cnt = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE validate_svc_entity_and_type(dummyvar=i2) = null
 DECLARE update_items(dummyvar=i2) = null
 DECLARE insert_items(dummyvar=i2) = null
 SUBROUTINE validate_svc_entity_and_type(dummyvar)
   SET req_cnt = size(request->svc_entities,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = req_cnt),
     br_eligible_provider ep
    PLAN (d
     WHERE (request->svc_entities[d.seq].svc_entity_type=1))
     JOIN (ep
     WHERE (ep.br_eligible_provider_id=request->svc_entities[d.seq].svc_entity_id)
      AND ep.active_ind=1
      AND ep.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY ep.provider_id
    HEAD REPORT
     cnt = 0, stat = alterlist(items_to_ens->svc_entities,(item_cnt+ 10))
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > 10)
      cnt = 1, stat = alterlist(items_to_ens->svc_entities,(item_cnt+ 10))
     ENDIF
     item_cnt = (item_cnt+ 1), items_to_ens->svc_entities[item_cnt].parent_entity_id = request->
     svc_entities[d.seq].svc_entity_id, items_to_ens->svc_entities[item_cnt].parent_entity_name =
     "BR_ELIGIBLE_PROVIDER",
     meas_size = size(request->svc_entities[d.seq].measures,5), stat = alterlist(items_to_ens->
      svc_entities[item_cnt].measures,meas_size)
     FOR (x = 1 TO meas_size)
       items_to_ens->svc_entities[item_cnt].measures[x].measure_id = request->svc_entities[d.seq].
       measures[x].measure_id
     ENDFOR
    FOOT REPORT
     cnt = 0, stat = alterlist(items_to_ens->svc_entities,item_cnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("EPVALIDATIONERROR")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = req_cnt),
     br_ccn ccn
    PLAN (d
     WHERE (request->svc_entities[d.seq].svc_entity_type=2))
     JOIN (ccn
     WHERE (ccn.br_ccn_id=request->svc_entities[d.seq].svc_entity_id)
      AND ccn.active_ind=1
      AND ccn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY ccn.br_ccn_id
    HEAD REPORT
     cnt = 0, stat = alterlist(items_to_ens->svc_entities,(item_cnt+ 10))
    DETAIL
     cnt = (cnt+ 1)
     IF (cnt > 10)
      cnt = 1, stat = alterlist(items_to_ens->svc_entities,(item_cnt+ 10))
     ENDIF
     item_cnt = (item_cnt+ 1), items_to_ens->svc_entities[item_cnt].parent_entity_id = request->
     svc_entities[d.seq].svc_entity_id, items_to_ens->svc_entities[item_cnt].parent_entity_name =
     "BR_CCN",
     meas_size = size(request->svc_entities[d.seq].measures,5), stat = alterlist(items_to_ens->
      svc_entities[item_cnt].measures,meas_size)
     FOR (x = 1 TO meas_size)
       items_to_ens->svc_entities[item_cnt].measures[x].measure_id = request->svc_entities[d.seq].
       measures[x].measure_id
     ENDFOR
    FOOT REPORT
     cnt = 0, stat = alterlist(items_to_ens->svc_entities,item_cnt)
    WITH nocounter
   ;end select
   CALL bederrorcheck("CCNVALIDATIONERROR")
   IF (item_cnt != req_cnt)
    CALL bederror(
     "CCN's and eligible providers do not match br_ccn.br_ccn_id or br_eligible_provider.br_eligible_provider_id"
     )
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_items(dummyvar)
   SET req_cnt = size(request->svc_entities,5)
   UPDATE  FROM (dummyt d  WITH seq = req_cnt),
     br_svc_entity_report_reltn svc
    SET svc.active_ind = 0, svc.updt_dt_tm = cnvtdatetime(curdate,curtime3), svc.updt_id = reqinfo->
     updt_id,
     svc.updt_task = reqinfo->updt_task, svc.updt_cnt = (svc.updt_cnt+ 1), svc.updt_applctx = reqinfo
     ->updt_applctx
    PLAN (d)
     JOIN (svc
     WHERE (svc.parent_entity_id=items_to_ens->svc_entities[d.seq].parent_entity_id)
      AND (svc.parent_entity_name=items_to_ens->svc_entities[d.seq].parent_entity_name)
      AND svc.active_ind=1)
    WITH nocounter
   ;end update
   CALL bederrorcheck("MEASUREINACTIVATEERROR")
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = req_cnt),
     (dummyt d2  WITH seq = 1),
     br_svc_entity_report_reltn svc
    PLAN (d1
     WHERE size(items_to_ens->svc_entities[d1.seq].measures,5) > 0
      AND maxrec(d2,size(items_to_ens->svc_entities[d1.seq].measures,5)))
     JOIN (d2)
     JOIN (svc
     WHERE (svc.parent_entity_id=items_to_ens->svc_entities[d1.seq].parent_entity_id)
      AND (svc.parent_entity_name=items_to_ens->svc_entities[d1.seq].parent_entity_name)
      AND (svc.br_datamart_report_id=items_to_ens->svc_entities[d1.seq].measures[d2.seq].measure_id)
      AND svc.active_ind=0)
    DETAIL
     items_to_ens->svc_entities[d1.seq].measures[d2.seq].measure_exists = 1
    WITH nocounter
   ;end select
   CALL bederrorcheck("CHECKEXISTMEAS")
   UPDATE  FROM (dummyt d1  WITH seq = req_cnt),
     (dummyt d2  WITH seq = 1),
     br_svc_entity_report_reltn svc
    SET svc.active_ind = 1, svc.updt_dt_tm = cnvtdatetime(curdate,curtime3), svc.updt_id = reqinfo->
     updt_id,
     svc.updt_task = reqinfo->updt_task, svc.updt_cnt = (svc.updt_cnt+ 1), svc.updt_applctx = reqinfo
     ->updt_applctx
    PLAN (d1
     WHERE size(items_to_ens->svc_entities[d1.seq].measures,5) > 0
      AND maxrec(d2,size(items_to_ens->svc_entities[d1.seq].measures,5)))
     JOIN (d2)
     JOIN (svc
     WHERE (svc.parent_entity_id=items_to_ens->svc_entities[d1.seq].parent_entity_id)
      AND (svc.parent_entity_name=items_to_ens->svc_entities[d1.seq].parent_entity_name)
      AND (svc.br_datamart_report_id=items_to_ens->svc_entities[d1.seq].measures[d2.seq].measure_id)
      AND (items_to_ens->svc_entities[d1.seq].measures[d2.seq].measure_exists=1)
      AND svc.active_ind=0)
    WITH nocounter
   ;end update
   CALL bederrorcheck("MEASUREACTIVATEERROR")
 END ;Subroutine
 SUBROUTINE insert_items(dummyvar)
  FOR (k = 1 TO size(items_to_ens->svc_entities,5))
    FOR (i = 1 TO size(items_to_ens->svc_entities[k].measures,5))
      IF ((items_to_ens->svc_entities[k].measures[i].measure_exists=0))
       SET new_id = 0.0
       SELECT INTO "nl:"
        z = seq(bedrock_seq,nextval)
        FROM dual
        DETAIL
         new_id = cnvtreal(z)
        WITH nocounter
       ;end select
       INSERT  FROM br_svc_entity_report_reltn svc
        SET svc.br_svc_entity_report_reltn_id = new_id, svc.parent_entity_id = items_to_ens->
         svc_entities[k].parent_entity_id, svc.parent_entity_name = items_to_ens->svc_entities[k].
         parent_entity_name,
         svc.br_datamart_report_id = items_to_ens->svc_entities[k].measures[i].measure_id, svc
         .active_ind = 1, svc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         svc.updt_id = reqinfo->updt_id, svc.updt_task = reqinfo->updt_task, svc.updt_cnt = 0,
         svc.updt_applctx = reqinfo->updt_applctx, svc.orig_br_svc_entity_report_r_id = new_id, svc
         .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
         svc.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
        WITH nocounter
       ;end insert
      ENDIF
    ENDFOR
  ENDFOR
  CALL bederrorcheck("MEASUREINSERTERROR")
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 CALL validate_svc_entity_and_type(1)
 CALL update_items(1)
 CALL insert_items(1)
 CALL bederrorcheck("Descriptive error message not provided.")
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
