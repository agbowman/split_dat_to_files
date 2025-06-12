CREATE PROGRAM bed_ens_clin_cat_ev_link:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 evidence_links[*]
     2 id = f8
     2 pathway_catalog_id = f8
     2 clin_cat_code_value = f8
     2 clin_sub_cat_code_value = f8
     2 evidence_link = vc
     2 evidence_type_mean = vc
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reqsize = size(request->evidence_links,5)
 IF (reqsize=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->evidence_links,reqsize)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = reqsize)
  PLAN (d)
  DETAIL
   temp->evidence_links[d.seq].clin_cat_code_value = request->evidence_links[d.seq].
   clin_cat_code_value, temp->evidence_links[d.seq].clin_sub_cat_code_value = request->
   evidence_links[d.seq].clin_sub_cat_code_value, temp->evidence_links[d.seq].evidence_link = request
   ->evidence_links[d.seq].evidence_link,
   temp->evidence_links[d.seq].evidence_type_mean = request->evidence_links[d.seq].evidence_type_mean,
   temp->evidence_links[d.seq].pathway_catalog_id = request->evidence_links[d.seq].pathway_catalog_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM pw_evidence_reltn per,
   (dummyt d  WITH seq = reqsize)
  PLAN (d)
   JOIN (per
   WHERE (per.pathway_catalog_id=temp->evidence_links[d.seq].pathway_catalog_id)
    AND per.pathway_comp_id=0
    AND (per.dcp_clin_cat_cd=temp->evidence_links[d.seq].clin_cat_code_value)
    AND (per.dcp_clin_sub_cat_cd=temp->evidence_links[d.seq].clin_sub_cat_code_value)
    AND per.type_mean IN ("URL", "ZYNX"))
  HEAD per.pw_evidence_reltn_id
   temp->evidence_links[d.seq].id = per.pw_evidence_reltn_id
  WITH nocounter
 ;end select
 DELETE  FROM pw_evidence_reltn per,
   (dummyt d  WITH seq = reqsize)
  SET per.seq = 1
  PLAN (d
   WHERE (temp->evidence_links[d.seq].evidence_type_mean="")
    AND (temp->evidence_links[d.seq].evidence_link="")
    AND (temp->evidence_links[d.seq].id > 0))
   JOIN (per
   WHERE (per.pw_evidence_reltn_id=temp->evidence_links[d.seq].id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error deleting from pw_evidence_reltn")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM pw_evidence_reltn per,
   (dummyt d  WITH seq = reqsize)
  SET per.type_mean = temp->evidence_links[d.seq].evidence_type_mean, per.evidence_locator = temp->
   evidence_links[d.seq].evidence_link, per.updt_id = reqinfo->updt_id,
   per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task = reqinfo->updt_task, per
   .updt_applctx = reqinfo->updt_applctx,
   per.updt_cnt = (per.updt_cnt+ 1)
  PLAN (d
   WHERE (temp->evidence_links[d.seq].evidence_type_mean > " ")
    AND (temp->evidence_links[d.seq].evidence_link > " ")
    AND (temp->evidence_links[d.seq].id > 0))
   JOIN (per
   WHERE (per.pw_evidence_reltn_id=temp->evidence_links[d.seq].id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error updating into pw_evidence_reltn")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 INSERT  FROM pw_evidence_reltn per,
   (dummyt d  WITH seq = reqsize)
  SET per.pw_evidence_reltn_id = seq(reference_seq,nextval), per.pathway_catalog_id = temp->
   evidence_links[d.seq].pathway_catalog_id, per.type_mean = temp->evidence_links[d.seq].
   evidence_type_mean,
   per.evidence_locator = temp->evidence_links[d.seq].evidence_link, per.dcp_clin_cat_cd = temp->
   evidence_links[d.seq].clin_cat_code_value, per.dcp_clin_sub_cat_cd = temp->evidence_links[d.seq].
   clin_sub_cat_code_value,
   per.updt_id = reqinfo->updt_id, per.updt_dt_tm = cnvtdatetime(curdate,curtime3), per.updt_task =
   reqinfo->updt_task,
   per.updt_applctx = reqinfo->updt_applctx, per.updt_cnt = 0
  PLAN (d
   WHERE (temp->evidence_links[d.seq].evidence_type_mean > " ")
    AND (temp->evidence_links[d.seq].evidence_link > " ")
    AND (temp->evidence_links[d.seq].id=0))
   JOIN (per)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error inserting into pw_evidence_reltn")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
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
