CREATE PROGRAM abn_get_existing_diags_for_cpt:dba
 RECORD reply(
   1 valid_diag_flg = i2
   1 beg_effective_dt = dq8
   1 list[*]
     2 icd9_nomen_id = f8
     2 icd9_source_identifier = vc
     2 display = c40
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
 SET count1 = 0
 SELECT INTO "nl:"
  n.nomenclature_id, n.source_string, a.valid_diag_flg
  FROM abn_rule a,
   nomenclature n,
   dummyt d1
  PLAN (a
   WHERE (a.fin_class_cd=request->fin_class_cd)
    AND (a.cpt_nomen_id=request->cpt_nomen_id)
    AND (a.encntr_type_cd=request->encntr_type_cd)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=a.icd9_nomen_id
    AND n.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->list,count1), reply->beg_effective_dt = a
   .beg_effective_dt_tm,
   reply->valid_diag_flg = a.valid_diag_flg
   IF (a.valid_diag_flg=2)
    reply->list[count1].icd9_nomen_id = 0, reply->list[count1].display = ""
   ELSE
    reply->list[count1].icd9_nomen_id = n.nomenclature_id, reply->list[count1].display = n
    .source_string, reply->list[count1].icd9_source_identifier = n.source_identifier
   ENDIF
  WITH nocounter, outerjoin(d1), dontcare = n
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
