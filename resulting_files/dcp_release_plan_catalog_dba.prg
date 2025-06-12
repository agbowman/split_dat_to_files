CREATE PROGRAM dcp_release_plan_catalog:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD phases(
   1 list[*]
     2 pathway_catalog_id = f8
 )
 FREE RECORD pw_pt_reltn_copy
 RECORD pw_pt_reltn_copy(
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 minimum_enrollment_status_flag = i2
   1 ordering_policy_flag = i2
   1 pathway_catalog_id = f8
   1 prev_pw_pt_reltn_id = f8
   1 prot_master_id = f8
   1 pw_pt_reltn_id = f8
   1 require_override_reason_ind = i2
   1 sequence = i4
 )
 DECLARE cfailed = c1 WITH noconstant("F"), protect
 DECLARE cstatus = c1 WITH noconstant("S"), protect
 DECLARE subphaseind = i4 WITH noconstant(1), public
 DECLARE old_pathwaycatalogid = f8 WITH protect, noconstant(0.0)
 DECLARE description = vc WITH protect, noconstant
 DECLARE descriptionkey = vc WITH protect, noconstant
 DECLARE subphase = f8 WITH constant(uar_get_code_by("MEANING",16750,"SUBPHASE")), protect
 DECLARE cnt = i4 WITH noconstant(1), public
 DECLARE stat = i2 WITH protect, noconstant
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE inactivate_plan_row(id=f8) = c1
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT
  *
  FROM pathway_catalog pwc1,
   pathway_catalog pwc2
  PLAN (pwc1
   WHERE (pwc1.pathway_catalog_id=request->pathway_catalog_id))
   JOIN (pwc2
   WHERE pwc1.version_pw_cat_id=pwc2.version_pw_cat_id
    AND pwc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pwc2.active_ind=1)
  DETAIL
   old_pathwaycatalogid = pwc2.pathway_catalog_id, subphaseind = pwc2.sub_phase_ind
  WITH nocounter
 ;end select
 SELECT
  *
  FROM pathway_catalog pc
  WHERE (pc.pathway_catalog_id=request->pathway_catalog_id)
  DETAIL
   description = pc.display_description, descriptionkey = cnvtupper(trim(pc.display_description))
  WITH nocounter, forupdate(pc)
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_RELEASE_PLAN_CATALOG",build("Unable to lock for update ID=",
    request->pathway_catalog_id))
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway_catalog pc
  SET pc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_cnt = (pc.updt_cnt+ 1), pc
   .updt_id = reqinfo->updt_id,
   pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_dt_tm =
   cnvtdatetime(curdate,curtime)
  WHERE (pc.pathway_catalog_id=request->pathway_catalog_id)
  WITH nocounter
 ;end update
 IF (old_pathwaycatalogid > 0.0)
  DELETE  FROM pw_cat_flex pcf
   WHERE pcf.pathway_catalog_id=old_pathwaycatalogid
  ;end delete
 ENDIF
 UPDATE  FROM pw_cat_flex pcf
  SET pcf.display_description_key = descriptionkey, pcf.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pcf.updt_id = reqinfo->updt_id,
   pcf.updt_task = reqinfo->updt_task, pcf.updt_applctx = reqinfo->updt_applctx, pcf.updt_cnt = (
   request->updt_cnt+ 1)
  WHERE (pcf.pathway_catalog_id=request->pathway_catalog_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL report_failure("UPDATE","F","DCP_RELEASE_PLAN_CATALOG",build(
    "Failed to update pw_cat_flex, OLD_PathwayCatalogId=",old_pathwaycatalogid))
 ENDIF
 IF (old_pathwaycatalogid <= 0.0)
  GO TO exit_script
 ENDIF
 SET cnt = 1
 SET stat = alterlist(phases->list,1)
 SET phases->list[1].pathway_catalog_id = old_pathwaycatalogid
 SELECT
  *
  FROM pw_cat_reltn pcr,
   pathway_catalog pwc
  PLAN (pcr
   WHERE pcr.pw_cat_s_id=old_pathwaycatalogid
    AND pcr.type_mean="GROUP")
   JOIN (pwc
   WHERE pwc.pathway_catalog_id=pcr.pw_cat_t_id)
  HEAD REPORT
   cnt = 1
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(phases->list,5))
    stat = alterlist(phases->list,(cnt+ 10))
   ENDIF
   phases->list[cnt].pathway_catalog_id = pwc.pathway_catalog_id
  FOOT REPORT
   stat = alterlist(phases->list,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(phases)
 FOR (i = 1 TO cnt)
  SET cstatus = inactivate_plan_row(phases->list[i].pathway_catalog_id)
  IF (cstatus="F")
   CALL report_failure("UPDATE","F","DCP_RELEASE_PLAN_CATALOG",build(
     "Failed to inactivate old plan ID = ",phases->list[i].pathway_catalog_id))
   GO TO exit_script
  ENDIF
 ENDFOR
 IF (subphaseind=1)
  UPDATE  FROM pathway_comp pc
   SET pc.parent_entity_id = request->pathway_catalog_id
   WHERE pc.comp_type_cd=subphase
    AND pc.parent_entity_id=old_pathwaycatalogid
    AND pc.active_ind=1
   WITH nocounter
  ;end update
  UPDATE  FROM pw_cat_reltn pcr
   SET pcr.pw_cat_t_id = request->pathway_catalog_id
   WHERE pcr.type_mean="SUBPHASE"
    AND pcr.pw_cat_t_id=old_pathwaycatalogid
   WITH nocounter
  ;end update
 ENDIF
 UPDATE  FROM alt_sel_list asl
  SET asl.pathway_catalog_id = request->pathway_catalog_id, asl.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), asl.updt_id = reqinfo->updt_id,
   asl.updt_task = reqinfo->updt_task, asl.updt_applctx = reqinfo->updt_applctx, asl.updt_cnt = (
   request->updt_cnt+ 1)
  WHERE asl.pathway_catalog_id=old_pathwaycatalogid
 ;end update
 UPDATE  FROM pw_cat_synonym pcs
  SET pcs.pathway_catalog_id = request->pathway_catalog_id, pcs.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), pcs.updt_id = reqinfo->updt_id,
   pcs.updt_task = reqinfo->updt_task, pcs.updt_applctx = reqinfo->updt_applctx, pcs.updt_cnt = (pcs
   .updt_cnt+ 1)
  WHERE pcs.pathway_catalog_id=old_pathwaycatalogid
 ;end update
 UPDATE  FROM pw_cat_synonym pcs
  SET pcs.synonym_name = description, pcs.synonym_name_key = descriptionkey
  WHERE (pcs.pathway_catalog_id=request->pathway_catalog_id)
   AND pcs.primary_ind=1
 ;end update
 SELECT INTO "n1:"
  FROM pw_pt_reltn ppr
  WHERE ppr.pathway_catalog_id=old_pathwaycatalogid
   AND ppr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   AND ppr.active_ind=1
  DETAIL
   pw_pt_reltn_copy->active_ind = ppr.active_ind, pw_pt_reltn_copy->beg_effective_dt_tm = ppr
   .beg_effective_dt_tm, pw_pt_reltn_copy->end_effective_dt_tm = ppr.end_effective_dt_tm,
   pw_pt_reltn_copy->minimum_enrollment_status_flag = ppr.minimum_enrollment_status_flag,
   pw_pt_reltn_copy->ordering_policy_flag = ppr.ordering_policy_flag, pw_pt_reltn_copy->
   pathway_catalog_id = ppr.pathway_catalog_id,
   pw_pt_reltn_copy->prev_pw_pt_reltn_id = ppr.prev_pw_pt_reltn_id, pw_pt_reltn_copy->prot_master_id
    = ppr.prot_master_id, pw_pt_reltn_copy->pw_pt_reltn_id = ppr.pw_pt_reltn_id,
   pw_pt_reltn_copy->require_override_reason_ind = ppr.require_override_reason_ind, pw_pt_reltn_copy
   ->sequence = ppr.sequence
  WITH nocounter
 ;end select
 IF (curqual > 0)
  INSERT  FROM pw_pt_reltn ppr
   SET ppr.pw_pt_reltn_id = seq(reference_seq,nextval), ppr.prev_pw_pt_reltn_id = pw_pt_reltn_copy->
    pw_pt_reltn_id, ppr.prot_master_id = pw_pt_reltn_copy->prot_master_id,
    ppr.pathway_catalog_id = pw_pt_reltn_copy->pathway_catalog_id, ppr.end_effective_dt_tm =
    cnvtdatetime(curdate,curtime3), ppr.active_ind = pw_pt_reltn_copy->active_ind,
    ppr.beg_effective_dt_tm = cnvtdatetime(pw_pt_reltn_copy->beg_effective_dt_tm), ppr
    .minimum_enrollment_status_flag = pw_pt_reltn_copy->minimum_enrollment_status_flag, ppr
    .ordering_policy_flag = pw_pt_reltn_copy->ordering_policy_flag,
    ppr.require_override_reason_ind = pw_pt_reltn_copy->require_override_reason_ind, ppr.sequence =
    pw_pt_reltn_copy->sequence, ppr.updt_applctx = reqinfo->updt_applctx,
    ppr.updt_cnt = 0, ppr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ppr.updt_id = reqinfo->updt_id,
    ppr.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  UPDATE  FROM pw_pt_reltn ppr
   SET ppr.pathway_catalog_id = request->pathway_catalog_id, ppr.beg_effective_dt_tm = cnvtdatetime(
     curdate,curtime3), ppr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ppr.updt_id = reqinfo->updt_id, ppr.updt_task = reqinfo->updt_task, ppr.updt_applctx = reqinfo->
    updt_applctx,
    ppr.updt_cnt = (ppr.updt_cnt+ 1)
   WHERE (ppr.pw_pt_reltn_id=pw_pt_reltn_copy->pw_pt_reltn_id)
  ;end update
 ENDIF
 SUBROUTINE inactivate_plan_row(id)
   DECLARE substat = c1 WITH protect, noconstant("S")
   DECLARE version_id = f8 WITH protect, noconstant(0.0)
   DECLARE typemean = vc WITH protect, noconstant
   SET typemean = fillstring(12," ")
   SELECT INTO "nl:"
    pc.*
    FROM pathway_catalog pc
    WHERE pc.pathway_catalog_id=id
    HEAD REPORT
     typemean = pc.type_mean, version_id = pc.version_pw_cat_id
    WITH forupdate(pc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_RELEASE_PLAN_CATALOG",build(
      "Failed to get a lock on PATHWAY_CATALOG for PW_CAT_ID=",id))
    RETURN("F")
   ENDIF
   UPDATE  FROM pathway_catalog pc
    SET pc.active_ind = 0, pc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc
     .version_pw_cat_id =
     IF (version_id=0
      AND typemean != "PHASE") pc.pathway_catalog_id
     ELSE pc.version_pw_cat_id
     ENDIF
     ,
     pc.updt_dt_tm = cnvtdatetime(curdate,curtime3), pc.updt_id = reqinfo->updt_id, pc.updt_task =
     reqinfo->updt_task,
     pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc.updt_cnt+ 1)
    WHERE pc.pathway_catalog_id=id
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_RELEASE_PLAN_CATALOG",build(
      "Unable to increment version on PATHWAY_CATALOG.  PW_CAT_ID=",id))
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE count = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET count = size(reply->status_data.subeventstatus,5)
   IF (((count != 1) OR (count=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET count = (count+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(count))
   ENDIF
   SET reply->status_data.subeventstatus[count].operationname = trim(opname)
   SET reply->status_data.subeventstatus[count].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[count].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[count].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET mod_date = "November 28, 2011"
 SET last_mod = "004"
 FREE RECORD phases
 IF (cfailed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
