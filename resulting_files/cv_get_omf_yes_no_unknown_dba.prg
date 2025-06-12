CREATE PROGRAM cv_get_omf_yes_no_unknown:dba
 FREE SET reply
 RECORD reply(
   1 datacoll[*]
     2 description = vc
     2 currcv = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET v_cv_count = 0
 SET v_principle_type_cd = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE code_set=401
   AND cdf_meaning="ALPHA RESPON"
   AND active_ind=1
  DETAIL
   v_principle_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET v_source_vocab_cd = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE code_set=400
   AND cdf_meaning="PTCARE"
   AND active_ind=1
  DETAIL
   v_source_vocab_cd = cv.code_value
  WITH nocounter
 ;end select
 SET v_cv_count = 0
 SELECT INTO "nl:"
  n.nomenclature_id, n.source_string
  FROM nomenclature n
  WHERE n.principle_type_cd=v_principle_type_cd
   AND n.source_vocabulary_cd=v_source_vocab_cd
   AND cnvtupper(n.mnemonic) IN ("YES", "NO", "UNKNOWN")
   AND n.active_ind=1
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = concat(trim(n.source_identifier),"-",trim(n.source_string)),
   reply->datacoll[v_cv_count].currcv = cnvtstring(n.nomenclature_id)
  WITH nocounter
 ;end select
 FOR (i = 1 TO v_cv_count)
   CALL echo("***************************")
   CALL echo(build("Source Stirng[",i,"]-",reply->datacoll[i].description))
   CALL echo(build("Noemnclature_ID[",i,"]--",reply->datacoll[i].currcv))
 ENDFOR
 CALL echo("***************************")
 SET reply->status_data.status = "S"
END GO
