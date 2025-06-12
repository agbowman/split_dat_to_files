CREATE PROGRAM bed_ens_nomen:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 nomen_list[*]
      2 nomenclature_id = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD string_index(
   1 str = vc
   1 strlist[0]
     2 normalized_string = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 EXECUTE ccluarxrtl
 DECLARE uuid1 = c36
 DECLARE nomen_cnt = i4 WITH protect
 DECLARE active_code_value = f8 WITH protect
 DECLARE inactive_code_value = f8 WITH protect
 DECLARE auth_code_value = f8 WITH protect
 DECLARE snmct_code_value = f8 WITH protect
 DECLARE new_id = f8 WITH protect
 SET nomen_cnt = size(request->nomen_list,5)
 SET stat = alterlist(reply->nomen_list,nomen_cnt)
 SET active_code_value = 0.0
 SET inactive_code_value = 0.0
 SET auth_code_value = 0.0
 SET snmct_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the ACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the INACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
  DETAIL
   auth_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the AUTH code value from codeset 8.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.cdf_meaning="SNMCT"
   AND cv.active_ind=1
  DETAIL
   snmct_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the SNMCT code value from codeset 400.")
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO nomen_cnt)
   IF ((request->nomen_list[x].action_flag=1))
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(nomenclature_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET reply->nomen_list[x].nomenclature_id = new_id
    IF ((request->nomen_list[x].source_vocabulary_code_value=snmct_code_value))
     SET uuid1 = " "
     SET uuid1 = uar_createuuid(1)
    ENDIF
    INSERT  FROM nomenclature n
     SET n.nomenclature_id = new_id, n.principle_type_cd = request->nomen_list[x].
      principle_type_code_value, n.contributor_system_cd = request->nomen_list[x].
      contributor_system_code_value,
      n.language_cd = request->nomen_list[x].language_code_value, n.source_vocabulary_cd = request->
      nomen_list[x].source_vocabulary_code_value, n.source_string = request->nomen_list[x].
      source_string,
      n.source_identifier =
      IF ((request->nomen_list[x].source_vocabulary_code_value=snmct_code_value)) uuid1
      ELSE request->nomen_list[x].source_identifier
      ENDIF
      , n.short_string = request->nomen_list[x].short_string, n.mnemonic = request->nomen_list[x].
      mnemonic,
      n.source_identifier_keycap =
      IF ((request->nomen_list[x].source_vocabulary_code_value=snmct_code_value)) cnvtupper(uuid1)
      ELSE cnvtupper(request->nomen_list[x].source_identifier)
      ENDIF
      , n.concept_identifier =
      IF ((request->nomen_list[x].concept_identifier > "  ")) request->nomen_list[x].
       concept_identifier
      ELSE null
      ENDIF
      , n.vocab_axis_cd = request->nomen_list[x].vocab_axis_code_value,
      n.source_string_keycap = cnvtupper(request->nomen_list[x].source_string), n.concept_cki =
      request->nomen_list[x].concept_cki, n.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_cnt = 0,
      n.updt_applctx = reqinfo->updt_applctx, n.active_ind = 1, n.active_status_cd =
      active_code_value,
      n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n.active_status_prsnl_id = reqinfo->
      updt_id, n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.string_identifier = " ", n
      .string_status_cd = 0.0,
      n.term_id = 0.0, n.nom_ver_grp_id = new_id, n.data_status_cd = auth_code_value,
      n.data_status_prsnl_id = reqinfo->updt_id, n.data_status_dt_tm = cnvtdatetime(curdate,curtime),
      n.concept_source_cd = request->nomen_list[x].concept_source_code_value,
      n.string_source_cd = 0.0, n.primary_vterm_ind = 0.0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(request->nomen_list[x].source_string),
      " into the nomenclature table.")
     GO TO exit_script
    ENDIF
    SET buflen = 1000
    SET outstr = fillstring(1000," ")
    SET wcard = " "
    SET wcard2 = ""
    SET wcount = 0
    SET tempstr = fillstring(1000," ")
    SET tempstr = nullterm(request->nomen_list[x].source_string)
    SET next_code = 0.0
    CALL uar_normalize_string(nullterm(tempstr),outstr,nullterm(wcard2),buflen,wcount)
    SET string_index->str = trim(outstr,3)
    IF (wcount > 0)
     SET stat = alter(string_index->strlist,(wcount+ 1))
     FOR (i = 1 TO wcount)
       IF (i=1)
        SET string_index->strlist[i].normalized_string = fillstring(1000," ")
        SET string_index->strlist[i].normalized_string = string_index->str
        SET istr = fillstring(1000," ")
        SET istr = string_index->str
       ELSE
        SET string_index->strlist[i].normalized_string = fillstring(1000," ")
        SET ipos = findstring(wcard,istr)
        SET istr = substring((ipos+ 1),1000,trim(istr))
        SET string_index->strlist[i].normalized_string = trim(istr)
       ENDIF
     ENDFOR
    ENDIF
    FOR (i = 1 TO wcount)
      IF ( NOT ((string_index->strlist[i].normalized_string IN (" ", null))))
       SET the_string = fillstring(255," ")
       SET the_string = trim(string_index->strlist[i].normalized_string,3)
       EXECUTE cps_next_nom_seq
       INSERT  FROM normalized_string_index n
        SET n.normalized_string_id = next_code, n.language_cd = request->nomen_list[x].
         language_code_value, n.nomenclature_id = new_id,
         n.normalized_string = concat(the_string," "), n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
         updt_applctx,
         n.active_ind = 1, n.active_status_cd = active_code_value, n.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         n.active_status_prsnl_id = reqinfo->updt_id, n.beg_effective_dt_tm = cnvtdatetime(curdate,
          curtime3), n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to update ",trim(request->nomen_list[x].source_string),
         " on the normalized_string_index table.")
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->nomen_list[x].action_flag=2))
    SET reply->nomen_list[x].nomenclature_id = request->nomen_list[x].nomenclature_id
    UPDATE  FROM nomenclature n
     SET n.active_ind = 1, n.active_status_cd = active_code_value, n.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      n.active_status_prsnl_id = reqinfo->updt_id, n.principle_type_cd = request->nomen_list[x].
      principle_type_code_value, n.contributor_system_cd = request->nomen_list[x].
      contributor_system_code_value,
      n.language_cd = request->nomen_list[x].language_code_value, n.source_vocabulary_cd = request->
      nomen_list[x].source_vocabulary_code_value, n.source_string = request->nomen_list[x].
      source_string,
      n.short_string = request->nomen_list[x].short_string, n.mnemonic = request->nomen_list[x].
      mnemonic, n.source_string_keycap = cnvtupper(request->nomen_list[x].source_string),
      n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task =
      reqinfo->updt_task,
      n.updt_cnt = (n.updt_cnt+ 1), n.updt_applctx = reqinfo->updt_applctx
     WHERE (n.nomenclature_id=request->nomen_list[x].nomenclature_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",trim(request->nomen_list[x].source_string),
      " on the nomenclature table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->nomen_list[x].action_flag=3))
    SET reply->nomen_list[x].nomenclature_id = request->nomen_list[x].nomenclature_id
    UPDATE  FROM nomenclature n
     SET n.active_ind = 0, n.active_status_cd = inactive_code_value, n.active_status_dt_tm = null,
      n.active_status_prsnl_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n
      .updt_id = reqinfo->updt_id,
      n.updt_task = reqinfo->updt_task, n.updt_cnt = (n.updt_cnt+ 1), n.updt_applctx = reqinfo->
      updt_applctx
     WHERE (n.nomenclature_id=request->nomen_list[x].nomenclature_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to inactivate ",trim(request->nomen_list[x].source_string),
      " on the nomenclature table.")
     GO TO exit_script
    ENDIF
    UPDATE  FROM normalized_string_index nsi
     SET nsi.active_ind = 0, nsi.active_status_cd = inactive_code_value, nsi.active_status_dt_tm =
      null,
      nsi.active_status_prsnl_id = reqinfo->updt_id, nsi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      nsi.updt_id = reqinfo->updt_id,
      nsi.updt_task = reqinfo->updt_task, nsi.updt_cnt = (nsi.updt_cnt+ 1), nsi.updt_applctx =
      reqinfo->updt_applctx,
      nsi.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE (nsi.nomenclature_id=request->nomen_list[x].nomenclature_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to inactivate ",trim(request->nomen_list[x].source_string),
      " on the normalized_string_index table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_NOMEN","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
