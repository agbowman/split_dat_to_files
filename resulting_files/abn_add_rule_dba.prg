CREATE PROGRAM abn_add_rule:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status = "S"
 SET updt_cnt = 0
 SET count1 = 0
 SET diags = size(request->qual,5)
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",code_cnt,active_cd)
 SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",code_cnt,inactive_cd)
 IF (((active_cd=0.0) OR (inactive_cd=0.0)) )
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE TABLE"
  GO TO exit_script
 ENDIF
 SELECT
  *
  FROM abn_rule a
  WHERE (a.fin_class_cd=request->fin_class_cd)
   AND (a.carrier_id=request->carrier_id)
   AND (a.encntr_type_cd=request->encntr_type_cd)
   AND (a.cpt_nomen_id=request->cpt_nomen_id)
   AND a.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM abn_rule a
   SET a.active_ind = 0, a.active_status_cd = inactive_cd, a.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    a.active_status_prsnl_id = reqinfo->updt_id, a.end_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), a.updt_cnt = (a.updt_cnt+ 1)
   WHERE (a.fin_class_cd=request->fin_class_cd)
    AND (a.carrier_id=request->carrier_id)
    AND (a.encntr_type_cd=request->encntr_type_cd)
    AND (a.cpt_nomen_id=request->cpt_nomen_id)
    AND a.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ABN_RULE TABLE"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (count1 = 1 TO diags)
  UPDATE  FROM abn_rule a
   SET a.active_ind = 1, a.active_status_cd = active_cd, a.beg_effective_dt_tm = cnvtdatetime(request
     ->beg_effective_dt),
    a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), a.updt_cnt = (a.updt_cnt+ 1), a
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    a.active_status_prsnl_id = reqinfo->updt_id, a.valid_diag_flg = request->valid_diag_flg
   WHERE (a.fin_class_cd=request->fin_class_cd)
    AND (a.carrier_id=request->carrier_id)
    AND (a.encntr_type_cd=request->encntr_type_cd)
    AND (a.cpt_nomen_id=request->cpt_nomen_id)
    AND (a.icd9_nomen_id=request->qual[count1].icd9_nomen_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET new_nbr = 0.0
   SELECT INTO "nl:"
    y = seq(abn_sequence,nextval)
    FROM dual
    DETAIL
     new_nbr = cnvtreal(y)
    WITH nocounter
   ;end select
   INSERT  FROM abn_rule a
    SET a.abn_rule_id = new_nbr, a.fin_class_cd = request->fin_class_cd, a.carrier_id = request->
     carrier_id,
     a.encntr_type_cd = request->encntr_type_cd, a.cpt_nomen_id = request->cpt_nomen_id, a
     .active_status_cd = active_cd,
     a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
     updt_id, a.icd9_nomen_id = request->qual[count1].icd9_nomen_id,
     a.valid_diag_flg = request->valid_diag_flg, a.beg_effective_dt_tm = cnvtdatetime(request->
      beg_effective_dt), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     a.active_ind = 1.0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
     a.updt_task = reqinfo->updt_task, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "ABN_RULE TABLE"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF ((reply->status="F"))
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
