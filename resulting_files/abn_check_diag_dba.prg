CREATE PROGRAM abn_check_diag:dba
 RECORD reply(
   1 qual[*]
     2 nomenclature_id = f8
     2 source_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET principle_type_cd = 0.0
 SET source_vocabulary_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(401,"PROCEDURE",code_cnt,principle_type_cd)
 SET stat = uar_get_meaning_by_codeset(400,"CPT4",code_cnt,source_vocabulary_cd)
 IF (((principle_type_cd=0) OR (source_vocabulary_cd=0)) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  GO TO exit_script
 ENDIF
 SET counter = 0
 SELECT DISTINCT INTO "nl:"
  a.abn_rule_id, n.nomenclature_id, n.source_string
  FROM nomenclature n,
   abn_rule a
  PLAN (n
   WHERE n.principle_type_cd=principle_type_cd
    AND n.source_vocabulary_cd=source_vocabulary_cd
    AND (n.source_identifier=request->cpt_cd)
    AND n.active_ind=1
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   JOIN (a
   WHERE (a.fin_class_cd=request->fin_cd)
    AND (a.encntr_type_cd=request->encntr_type_cd)
    AND a.cpt_nomen_id=n.nomenclature_id
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1)
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->qual,counter), reply->qual[counter].
   nomenclature_id = n.nomenclature_id,
   reply->qual[counter].source_string = n.source_string,
   CALL echo(build("Nomenclature ID:  ",n.nomenclature_id))
  WITH nocounter
 ;end select
#exit_script
END GO
