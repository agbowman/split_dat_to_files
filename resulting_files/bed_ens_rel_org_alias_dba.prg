CREATE PROGRAM bed_ens_rel_org_alias:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET pval
 RECORD pval(
   1 pvallist[*]
     2 oldpval = i4
     2 newpval = i4
 )
 FREE SET vval
 RECORD vval(
   1 vvallist[*]
     2 oldvval = i4
     2 newvval = i4
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE tcnt = i4
 DECLARE ncnt = i4
 DECLARE tempseq = f8
 DECLARE foundval = vc
 SET new_patient_seq = 0
 SET new_visit_seq = 0
 SELECT INTO "NL:"
  pat_seq = max(b.patient_seq), visit_seq = max(b.visit_seq)
  FROM br_org_alias_group b
  DETAIL
   new_patient_seq = pat_seq, new_visit_seq = visit_seq
  WITH nocounter
 ;end select
 SET tcnt = size(request->rel_list,5)
 FOR (ii = 1 TO tcnt)
   SET ncnt = size(pval->pvallist,5)
   IF (ncnt=0)
    SET ncnt = 1
    SET stat = alterlist(pval->pvallist,ncnt)
    SET pval->pvallist[ncnt].oldpval = request->rel_list[ii].patient_seq
    SET new_patient_seq = (new_patient_seq+ 1)
    SET pval->pvallist[ncnt].newpval = new_patient_seq
    SET request->rel_list[ii].patient_seq = pval->pvallist[ncnt].newpval
   ELSE
    SET foundval = "N"
    FOR (jj = 1 TO ncnt)
      IF ((pval->pvallist[jj].oldpval=request->rel_list[ii].patient_seq))
       SET foundval = "Y"
       SET request->rel_list[ii].patient_seq = pval->pvallist[jj].newpval
      ENDIF
    ENDFOR
    IF (foundval="N")
     SET ncnt = (ncnt+ 1)
     SET stat = alterlist(pval->pvallist,ncnt)
     SET pval->pvallist[ncnt].oldpval = request->rel_list[ii].patient_seq
     SET new_patient_seq = (new_patient_seq+ 1)
     SET pval->pvallist[ncnt].newpval = new_patient_seq
     SET request->rel_list[ii].patient_seq = pval->pvallist[ncnt].newpval
    ENDIF
   ENDIF
   SET ncnt = size(vval->vvallist,5)
   IF (ncnt=0)
    SET ncnt = 1
    SET stat = alterlist(vval->vvallist,ncnt)
    SET vval->vvallist[ncnt].oldvval = request->rel_list[ii].visit_seq
    SET new_visit_seq = (new_visit_seq+ 1)
    SET vval->vvallist[ncnt].newvval = new_visit_seq
    SET request->rel_list[ii].visit_seq = vval->vvallist[ncnt].newvval
   ELSE
    SET foundval = "N"
    FOR (jj = 1 TO ncnt)
      IF ((vval->vvallist[jj].oldvval=request->rel_list[ii].visit_seq))
       SET foundval = "Y"
       SET request->rel_list[ii].visit_seq = vval->vvallist[jj].newvval
      ENDIF
    ENDFOR
    IF (foundval="N")
     SET ncnt = (ncnt+ 1)
     SET stat = alterlist(vval->vvallist,ncnt)
     SET vval->vvallist[ncnt].oldvval = request->rel_list[ii].visit_seq
     SET new_visit_seq = (new_visit_seq+ 1)
     SET vval->vvallist[ncnt].newvval = new_visit_seq
     SET request->rel_list[ii].visit_seq = vval->vvallist[ncnt].newvval
    ENDIF
   ENDIF
 ENDFOR
 CALL echorecord(request)
 SET error_flag = "N"
 SET rel_cnt = size(request->rel_list,5)
 FOR (x = 1 TO rel_cnt)
  IF ((((request->rel_list[x].parent_org_id=0)) OR ((request->rel_list[x].organization_id=0))) )
   SET error_flag = "Y"
   SET error_msg = concat("The parent_org_id and organization_id must be greater than zero.")
   GO TO exit_script
  ENDIF
  IF ((request->rel_list[x].action_flag=1))
   INSERT  FROM br_org_alias_group b
    SET b.parent_org_id = request->rel_list[x].parent_org_id, b.organization_id = request->rel_list[x
     ].organization_id, b.patient_seq = request->rel_list[x].patient_seq,
     b.visit_seq = request->rel_list[x].visit_seq, b.phys_seq = request->rel_list[x].phys_seq, b
     .prsnl_seq = request->rel_list[x].prsnl_seq,
     b.process_flag = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 1, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert parent_org = ",cnvtstring(request->rel_list[x].
      parent_org_id)," with org_id = ",cnvtstring(request->rel_list[x].organization_id),
     " into br_org_alias_group table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->rel_list[x].action_flag=2))
   UPDATE  FROM br_org_alias_group b
    SET b.patient_seq = request->rel_list[x].patient_seq, b.visit_seq = request->rel_list[x].
     visit_seq, b.phys_seq = request->rel_list[x].phys_seq,
     b.prsnl_seq = request->rel_list[x].prsnl_seq, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
     updt_applctx
    WHERE (b.parent_org_id=request->rel_list[x].parent_org_id)
     AND (b.organization_id=request->rel_list[x].organization_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update parent_org = ",cnvtstring(request->rel_list[x].
      parent_org_id)," with org_id = ",cnvtstring(request->rel_list[x].organization_id),
     " into br_org_alias_group table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->rel_list[x].action_flag=3))
   DELETE  FROM br_org_alias_group b
    WHERE (b.parent_org_id=request->rel_list[x].parent_org_id)
     AND (b.organization_id=request->rel_list[x].organization_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to delete parent_org = ",cnvtstring(request->rel_list[x].
      parent_org_id)," with org_id = ",cnvtstring(request->rel_list[x].organization_id),
     " into br_org_alias_group table.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_ORG_ALIAS","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
