CREATE PROGRAM cps_add_nomenclature:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET err_principle_type = 14
 SET err_contrib_sys = 15
 SET err_source_vocab = 16
 SET err_language = 17
 SET err_string_source = 18
 SET err_source_string = 19
 SET pure_dup = 20
 SET case_dup = 21
 SET failed = false
 SET table_name = fillstring(50," ")
 SET a_dup = false
 SET a_pure_dup = false
 SET continue = false
 FREE SET nomen_list
 RECORD nomen_list(
   1 srcstr = vc
   1 qual_knt = i4
   1 qual[*]
     2 id = f8
 )
 FREE SET reply
 RECORD reply(
   1 nomenclature_qual = i4
   1 nomenclature[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 principle_type_cd = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 status = i2
     2 dup_ind = i2
     2 status_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET start = 1
 SET stop = request->nomenclature_qual
 SET reply->nomenclature_qual = request->nomenclature_qual
 SET kount = 0
 SET tknt = 0
 FREE SET temp
 RECORD temp(
   1 count = i2
   1 qual[*]
     2 nomenclature_id = f8
 )
 SET table_name = "NOMENCLATURE"
 SET stat = alterlist(temp->qual,(request->nomenclature_qual+ 1))
 SET temp->count = request->nomenclature_qual
 CALL add_nomenclature(start,stop)
 GO TO check_error
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   OF err_principle_type:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Principle_type"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Code_Value provided"
   OF err_contrib_sys:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Contributor_sys"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Code_Value provided"
   OF err_source_vocab:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Source_vocab"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Code_Value provided"
   OF err_language:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Language"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Code_Value provided"
   OF err_string_source:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "String_source"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Code_Value provided"
   OF err_source_string:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Source_string"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Blank Source_String provided"
   OF pure_dup:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Pure_Duplicate"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "A Pure Duplicate"
   OF case_dup:
    IF (tknt=0)
     SET reply->status_data.status = "F"
    ELSEIF (tknt=kount)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "P"
    ENDIF
    SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Case_Duplicate"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "A Case Duplicate"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO exit_script
 SUBROUTINE add_nomenclature(first,last)
   SET active_status_cd = 0.0
   IF ((reqdata->active_status_cd < 1))
    SET code_value = 0.0
    SET code_set = 48
    SET cdf_meaning = "ACTIVE"
    EXECUTE cpm_get_cd_for_cdf
    SET active_status_cd = code_value
   ELSE
    SET active_status_cd = reqdata->active_status_cd
   ENDIF
   SET continue = true
   SET x = first
   WHILE (x <= last
    AND continue=true)
     SET process_item = true
     SET kount = (kount+ 1)
     IF (mod(kount,100)=1)
      SET stat = alterlist(reply->nomenclature,(kount+ 100))
     ENDIF
     SET reply->nomenclature[kount].nomenclature_id = 0.0
     SET reply->nomenclature[kount].source_vocabulary_cd = request->nomenclature[x].
     source_vocabulary_cd
     SET reply->nomenclature[kount].principle_type_cd = request->nomenclature[x].principle_type_cd
     SET reply->nomenclature[kount].source_identifier = request->nomenclature[x].source_identifier
     SET reply->nomenclature[kount].status = 0
     IF ((request->nomenclature[x].principle_type_cd < 1))
      SET failed = err_principle_type
      SET reply->nomenclature[kount].status_msg = "Invalid Principle_Type"
      SET process_item = false
     ELSEIF ((request->nomenclature[x].contributor_system_cd < 1))
      SET failed = err_contrib_sys
      SET reply->nomenclature[kount].status_msg = "Invalid Contributor_System"
      SET process_item = false
     ELSEIF ((request->nomenclature[x].source_vocabulary_cd < 1))
      SET failed = err_source_vocab
      SET reply->nomenclature[kount].status_msg = "Invalid Source_Vocabulary"
      SET process_item = false
     ELSEIF ((request->nomenclature[x].language_cd < 1))
      SET failed = err_language
      SET reply->nomenclature[kount].status_msg = "Invalid Language"
      SET process_item = false
     ELSEIF ( NOT ((request->nomenclature[x].source_string > " ")))
      SET failed = err_source_string
      SET reply->nomenclature[kount].status_msg = "Source_string should be greater than blank"
      SET process_item = false
     ENDIF
     IF (process_item=true)
      CALL chk_nomen_dup(request->nomenclature[x].source_vocabulary_cd,request->nomenclature[x].
       source_identifier,request->nomenclature[x].source_string,request->nomenclature[x].
       principle_type_cd)
      SET reply->nomenclature[kount].source_string = nomen_list->srcstr
      IF (a_pure_dup=false)
       IF (a_dup=true
        AND (request->nomenclature[x].add_case_dup=1))
        SET process_item = true
        SET reply->nomenclature[x].status_msg = "Case Duplicate and has been added"
        SET reply->nomenclature[x].dup_ind = 2
       ELSEIF (a_dup=true
        AND (request->nomenclature[x].add_case_dup=0))
        SET process_item = false
        SET reply->nomenclature[kount].status_msg = "Case Duplicate and is not added"
        SET reply->nomenclature[kount].dup_ind = 2
        SET failed = case_dup
       ELSE
        SET process_item = true
       ENDIF
       SET continue = true
      ELSE
       SET process_item = false
       SET reply->nomenclature[kount].dup_ind = 1
       SET reply->nomenclature[kount].status_msg = "Pure Duplicate. This item cannot be added"
       SET failed = pure_dup
      ENDIF
     ENDIF
     IF (process_item=true)
      SET next_code = 0.0
      EXECUTE cps_next_nom_seq
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       SET request->nomenclature[x].nomenclature_id = next_code
      ENDIF
      SET mnemonic_holder = fillstring(25," ")
      SET conceptid_holder = fillstring(18," ")
      SET stringid_holder = fillstring(18," ")
      SET mnemonic_holder = request->nomenclature[x].mnemonic
      SET conceptid_holder = request->nomenclature[x].concept_identifier
      SET stringid_holder = request->nomenclature[x].string_identifier
      INSERT  FROM nomenclature n
       SET n.nomenclature_id = next_code, n.principle_type_cd = request->nomenclature[x].
        principle_type_cd, n.contributor_system_cd = request->nomenclature[x].contributor_system_cd,
        n.source_string = trim(request->nomenclature[x].source_string), n.source_identifier = request
        ->nomenclature[x].source_identifier, n.string_identifier = request->nomenclature[x].
        string_identifier,
        n.term_id = request->nomenclature[x].term_id, n.language_cd = request->nomenclature[x].
        language_cd, n.source_vocabulary_cd = request->nomenclature[x].source_vocabulary_cd,
        n.nom_ver_grp_id =
        IF ((request->nomenclature[x].nom_ver_grp_id=0)) next_code
        ELSE request->nomenclature[x].nom_ver_grp_id
        ENDIF
        , n.data_status_cd = request->nomenclature[x].data_status_cd, n.data_status_dt_tm =
        IF ((request->nomenclature[x].data_status_dt_tm <= 0)) null
        ELSE cnvtdatetime(request->nomenclature[x].data_status_dt_tm)
        ENDIF
        ,
        n.data_status_prsnl_id = request->nomenclature[x].data_status_prsnl_id, n.short_string =
        request->nomenclature[x].short_string, n.mnemonic = mnemonic_holder,
        n.concept_identifier =
        IF ((request->nomenclature[x].concept_identifier > " ")) conceptid_holder
        ELSE null
        ENDIF
        , n.concept_source_cd = request->nomenclature[x].concept_source_cd, n.string_source_cd =
        request->nomenclature[x].string_source_cd,
        n.beg_effective_dt_tm =
        IF ((request->nomenclature[x].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
        ELSE cnvtdatetime(request->nomenclature[x].beg_effective_dt_tm)
        ENDIF
        , n.end_effective_dt_tm =
        IF ((request->nomenclature[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-dec-2100")
        ELSE cnvtdatetime(request->nomenclature[x].end_effective_dt_tm)
        ENDIF
        , n.active_ind =
        IF ((request->nomenclature[x].active_ind_ind=false)) true
        ELSE request->nomenclature[x].active_ind
        ENDIF
        ,
        n.active_status_cd =
        IF ((request->nomenclature[x].active_status_cd=0)) active_status_cd
        ELSE request->nomenclature[x].active_status_cd
        ENDIF
        , n.active_status_prsnl_id =
        IF ((request->nomenclature[x].active_status_prsnl_id=0)) reqinfo->updt_id
        ELSE request->nomenclature[x].active_status_prsnl_id
        ENDIF
        , n.active_status_dt_tm =
        IF ((request->nomenclature[x].active_status_dt_tm <= 0)) cnvtdatetime(curdate,curtime)
        ELSE cnvtdatetime(request->nomenclature[x].active_status_dt_tm)
        ENDIF
        ,
        n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,curtime), n.updt_id = reqinfo->updt_id,
        n.updt_applctx = reqinfo->updt_applctx, n.updt_task = reqinfo->updt_task, n.vocab_axis_cd =
        request->nomenclature[x].vocab_axis_cd,
        n.primary_vterm_ind = 0
       WITH nocounter
      ;end insert
      IF (curqual < 1)
       SET failed = insert_error
       SET reply->nomenclature[kount].status_msg = "Insert Failed"
       RETURN
      ELSE
       SET reply->nomenclature[kount].nomenclature_id = next_code
       SET reply->nomenclature[kount].status = 1
       SET reply->nomenclature[kount].dup_ind = - (1)
       SET tknt = (tknt+ 1)
       SET temp->qual[x].nomenclature_id = next_code
       COMMIT
      ENDIF
     ENDIF
     SET x = (x+ 1)
   ENDWHILE
   SET reply->nomenclature_qual = kount
   SET temp->count = tknt
   SET stat = alterlist(temp->qual,tknt)
   SET stat = alterlist(reply->nomenclature,kount)
 END ;Subroutine
#exit_script
 FOR (xx = 1 TO temp->count)
   EXECUTE cps_ens_normalized_index temp->qual[xx].nomenclature_id
 ENDFOR
 GO TO end_program
 SUBROUTINE chk_nomen_dup(tsrc_vocab_cd,tsrc_ident,tsrc_string,tprin_type_cd)
   SET cap_src_string = cnvtupper(tsrc_string)
   SET a_pure_dup = false
   SET a_dup = false
   SELECT
    IF (tsrc_ident > " ")
     PLAN (n
      WHERE n.source_vocabulary_cd=tsrc_vocab_cd
       AND n.source_identifier=tsrc_ident
       AND ((n.source_string=tsrc_string) OR (cnvtupper(n.source_string)=cap_src_string))
       AND n.principle_type_cd=tprin_type_cd)
    ELSE
     PLAN (n
      WHERE n.source_vocabulary_cd=tsrc_vocab_cd
       AND n.source_identifier <= " "
       AND ((n.source_string=tsrc_string) OR (cnvtupper(n.source_string)=cap_src_string))
       AND n.principle_type_cd=tprin_type_cd)
    ENDIF
    INTO "nl:"
    n.nomenclature_id, n.beg_effective_dt_tm
    FROM nomenclature n
    ORDER BY cnvtdatetime(n.beg_effective_dt_tm) DESC
    HEAD REPORT
     knt = 0, stat = alterlist(nomen_list->qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(nomen_list->qual,(knt+ 9))
     ENDIF
     nomen_list->qual[knt].id = n.nomenclature_id, a_dup = true, nomen_list->srcstr = n.source_string
     IF (n.source_string=tsrc_string)
      a_pure_dup = true
     ENDIF
    FOOT REPORT
     nomen_list->qual_knt = knt, stat = alterlist(nomen_list->qual,knt)
    WITH nocounter, orahint("index(n XAK6NOMENCLATURE) ")
   ;end select
 END ;Subroutine
#end_program
END GO
