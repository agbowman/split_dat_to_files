CREATE PROGRAM abn_get_cpt:dba
 RECORD reply(
   1 qual[*]
     2 source_string = vc
     2 nomenclature_id = f8
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
 SET source_vocabulary_cd = 0.0
 SET principle_type_cd = 0.0
 SET active_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(401,"PROCEDURE",1,principle_type_cd)
 SET stat = uar_get_meaning_by_codeset(400,"CPT4",1,source_vocabulary_cd)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_cd)
 IF (((principle_type_cd=0) OR (((source_vocabulary_cd=0) OR (active_cd=0)) )) )
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
  GO TO exit_script
 ENDIF
 SET counter = 0
 SELECT INTO "nl:"
  n.nomenclature_id, n.source_string
  FROM nomenclature n,
   abn_cross_reference a
  PLAN (n
   WHERE n.principle_type_cd=principle_type_cd
    AND n.source_vocabulary_cd=source_vocabulary_cd
    AND (n.source_identifier=request->cpt4)
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.active_ind=1)
   JOIN (a
   WHERE a.cpt_nomen_id=n.nomenclature_id
    AND a.active_status_cd=active_cd
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1)
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->qual,counter), reply->qual[counter].
   nomenclature_id = n.nomenclature_id,
   reply->qual[counter].source_string = n.source_string
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
