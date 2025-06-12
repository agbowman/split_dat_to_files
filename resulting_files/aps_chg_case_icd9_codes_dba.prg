CREATE PROGRAM aps_chg_case_icd9_codes:dba
 RECORD reply(
   1 nomen_entity_qual[*]
     2 nomen_entity_reltn_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET thetable = " "
 SET i = 0
 SET person_id = 0.0
 SET encntr_id = 0.0
 SET nomen_entity_cnt = size(request->nomen_entity_qual,5)
 SET nomen_entity_inact_cnt = size(request->nomen_entity_inact_qual,5)
 SET accn_icd9_cd = uar_get_code_by("MEANING",23549,"ACCNICD9")
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET reltns_cnt = size(request->reltns,5)
 SET person_id = request->person_id
 SET encntr_id = request->encntr_id
 IF (nomen_entity_cnt > 0)
  FOR (i = 1 TO nomen_entity_cnt)
    SET request->nomen_entity_qual[i].parent_entity_name = "ACCESSION"
    SET request->nomen_entity_qual[i].parent_entity_id = request->case_id
    SET request->nomen_entity_qual[i].child_entity_name = "NOMENCLATURE"
    SET request->nomen_entity_qual[i].child_entity_id = request->nomen_entity_qual[i].nomenclature_id
    SET request->nomen_entity_qual[i].reltn_type_cd = accn_icd9_cd
    SET request->nomen_entity_qual[i].freetext_display = ""
    SET request->nomen_entity_qual[i].person_id = person_id
    SET request->nomen_entity_qual[i].encntr_id = encntr_id
  ENDFOR
  EXECUTE dcp_add_nomen_entity_reltn
  IF ((reply->status_data.status="F"))
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF (nomen_entity_inact_cnt > 0)
  EXECUTE dcp_inact_nomen_entity_reltn
  IF ((reply->status_data.status="F"))
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF (reltns_cnt > 0)
  EXECUTE dcp_upd_plan_nomen_reltn
  IF ((reply->status_data.status="F"))
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
 GO TO exit_script
#check_err
 IF (err="L")
  SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  SET reply->status_data.status = "C"
 ELSEIF (err="U")
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 ENDIF
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 IF (thetable="P")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
 ELSEIF (thetable="C")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_PROVIDER"
 ELSEIF (thetable="L")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 ENDIF
 ROLLBACK
 GO TO exit_script
#exit_script
END GO
