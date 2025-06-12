CREATE PROGRAM cps_get_nomen_item:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 parent_category_id = f8
     2 nomen_cnt = i4
     2 nomen[*]
       3 nomen_cat_list_id = f8
       3 nomenclature_id = f8
       3 effective_ind = i2
       3 list_sequence = i4
       3 source_string = vc
       3 source_vocabulary_cd = f8
       3 source_vocabulary_disp = c40
       3 principle_type_cd = f8
       3 principle_type_disp = c40
       3 concept_identifier = c18
       3 concept_source_cd = f8
       3 source_identifier = vc
       3 valid_flag_desc = c1
       3 sex_flag_desc = c1
       3 age_flag_desc = c1
       3 short_string = c1
       3 primary_vterm_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dvar = 0
 SET max_nomen_cnt = 0
 SET found_icd9 = false
 SET icd9_cd = 0.0
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 IF ((request->qual_cnt < 1))
  SET failed = input_error
  SET table_name = "REQUEST"
  SET serrmsg = "REQUEST->QUAL_CNT must be greater then 0"
  SET reply->qual_cnt = 0
  SET stat = alterlist(reply->qual,reply->qual_cnt)
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = "ICD9"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,icd9_cd)
 IF (stat > 0)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to find the code_value for ",trim(cdf_meaning)," on code_set ",trim(
    cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq, nl.list_sequence
  FROM (dummyt d  WITH seq = value(request->qual_cnt)),
   nomen_cat_list nl,
   nomenclature n
  PLAN (d
   WHERE d.seq > 0)
   JOIN (nl
   WHERE (nl.parent_category_id=request->qual[d.seq].category_id)
    AND nl.nomenclature_id > 0)
   JOIN (n
   WHERE n.nomenclature_id=nl.nomenclature_id
    AND n.active_ind=1)
  ORDER BY d.seq, nl.list_sequence
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD d.seq
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 10))
   ENDIF
   reply->qual[knt].parent_category_id = request->qual[d.seq].category_id, n_knt = 0, stat =
   alterlist(reply->qual[d.seq].nomen,10)
  DETAIL
   IF (nl.nomen_cat_list_id > 0)
    n_knt = (n_knt+ 1)
    IF (mod(n_knt,10)=1
     AND n_knt != 1)
     stat = alterlist(reply->qual[knt].nomen,(n_knt+ 9))
    ENDIF
    reply->qual[knt].nomen[n_knt].nomen_cat_list_id = nl.nomen_cat_list_id, reply->qual[knt].nomen[
    n_knt].nomenclature_id = n.nomenclature_id
    IF (n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     reply->qual[knt].nomen[n_knt].effective_ind = 1
    ELSE
     reply->qual[knt].nomen[n_knt].effective_ind = 0
    ENDIF
    reply->qual[knt].nomen[n_knt].list_sequence = nl.list_sequence, reply->qual[knt].nomen[n_knt].
    source_string = n.source_string, reply->qual[knt].nomen[n_knt].source_vocabulary_cd = n
    .source_vocabulary_cd,
    reply->qual[knt].nomen[n_knt].principle_type_cd = n.principle_type_cd, reply->qual[knt].nomen[
    n_knt].concept_identifier = n.concept_identifier, reply->qual[knt].nomen[n_knt].concept_source_cd
     = n.concept_source_cd,
    reply->qual[knt].nomen[n_knt].source_identifier = n.source_identifier, reply->qual[knt].nomen[
    n_knt].short_string = n.short_string, reply->qual[knt].nomen[n_knt].primary_vterm_ind = n
    .primary_vterm_ind
    IF (n.source_vocabulary_cd=icd9_cd)
     found_icd9 = true
    ENDIF
   ENDIF
  FOOT  d.seq
   reply->qual[knt].nomen_cnt = n_knt, stat = alterlist(reply->qual[knt].nomen,n_knt)
   IF (n_knt >= max_nomen_cnt)
    max_nomen_cnt = n_knt
   ENDIF
  FOOT REPORT
   reply->qual_cnt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "NOMEN_CAT_LIST"
  GO TO exit_script
 ENDIF
 IF (found_icd9=false)
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(reply->qual_cnt)),
   (dummyt d2  WITH seq = value(max_nomen_cnt)),
   icd9cm_extension e
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq].nomen_cnt)
    AND (reply->qual[d1.seq].nomen[d2.seq].source_vocabulary_cd=icd9_cd))
   JOIN (e
   WHERE (e.source_identifier=reply->qual[d1.seq].nomen[d2.seq].source_identifier)
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND e.active_ind=true)
  ORDER BY d1.seq, d2.seq
  HEAD d1.seq
   dvar = 0
  HEAD d2.seq
   reply->qual[d1.seq].nomen[d2.seq].valid_flag_desc = e.valid_flag_desc, reply->qual[d1.seq].nomen[
   d2.seq].age_flag_desc = e.age_flag_desc, reply->qual[d1.seq].nomen[d2.seq].sex_flag_desc = e
   .sex_flag_desc
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ICD9CM_EXTENSION"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSEIF ((reply->qual_cnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "004 02/05/01 SF3151"
END GO
