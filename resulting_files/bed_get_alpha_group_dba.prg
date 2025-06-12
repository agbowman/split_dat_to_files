CREATE PROGRAM bed_get_alpha_group:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
     2 glist[*]
       3 group_id = f8
       3 description = c50
       3 nlist[*]
         4 nomenclature_id = f8
         4 source_string = c255
         4 short_string = c60
         4 mnemonic = c25
         4 sequence = i4
         4 default_ind = i2
         4 use_units_ind = i2
         4 reference_ind = i2
         4 result_process
           5 code_value = f8
           5 display = vc
           5 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_list = 0
 SET tot_slist = 0
 SET tot_group = 0
 SET tot_nomen = 0
 SET group_cnt = 0
 SET nomen_cnt = 0
 SET found_one = 0
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 SET slist_cnt = size(request->slist,5)
 SET glist_cnt = size(request->glist,5)
 SET tot_list = (slist_cnt+ glist_cnt)
 SET stat = alterlist(reply->slist,tot_list)
 FOR (x = 1 TO slist_cnt)
   SET tot_slist = (tot_slist+ 1)
   SET reply->slist[tot_slist].code_value = request->slist[x].code_value
   SELECT INTO "NL:"
    cv.cdf_meaning, cv.display
    FROM code_value cv
    WHERE (cv.code_value=request->slist[x].code_value)
    DETAIL
     reply->slist[tot_slist].cdf_meaning = cv.cdf_meaning, reply->slist[tot_slist].display = cv
     .display
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->slist[tot_slist].glist,20)
   SET tot_group = 0
   SET group_cnt = 0
   SELECT INTO "NL:"
    FROM br_alpha_group ag,
     br_alpha_group_components agc,
     nomenclature n,
     code_value cv
    PLAN (ag
     WHERE (ag.source_vocabulary_cd=request->slist[x].code_value)
      AND ((ag.active_ind=1) OR (ag.active_ind=0
      AND (request->load_inactive_ind=1))) )
     JOIN (agc
     WHERE agc.group_id=ag.group_id)
     JOIN (n
     WHERE agc.nomenclature_id=n.nomenclature_id)
     JOIN (cv
     WHERE cv.active_ind=outerjoin(1)
      AND cv.code_value > outerjoin(0)
      AND cv.code_value=outerjoin(agc.result_process_cd))
    ORDER BY ag.description, agc.sequence
    HEAD ag.group_id
     IF (tot_group > 0)
      stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,tot_nomen)
     ENDIF
     tot_group = (tot_group+ 1), group_cnt = (group_cnt+ 1)
     IF (group_cnt > 20)
      stat = alterlist(reply->slist[tot_slist].glist,(tot_group+ 20)), group_cnt = 0
     ENDIF
     reply->slist[tot_slist].glist[tot_group].group_id = ag.group_id, reply->slist[tot_slist].glist[
     tot_group].description = ag.description, tot_nomen = 0,
     nomen_cnt = 0, stat = alterlist(reply->slist[x].glist[tot_group].nlist,10)
    DETAIL
     tot_nomen = (tot_nomen+ 1), nomen_cnt = (nomen_cnt+ 1)
     IF (nomen_cnt > 10)
      stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,(tot_nomen+ 10)), nomen_cnt = 0
     ENDIF
     reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].nomenclature_id = agc.nomenclature_id,
     reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].sequence = agc.sequence, reply->slist[
     tot_slist].glist[tot_group].nlist[tot_nomen].source_string = n.source_string,
     reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].short_string = n.short_string, reply->
     slist[tot_slist].glist[tot_group].nlist[tot_nomen].mnemonic = n.mnemonic, reply->slist[tot_slist
     ].glist[tot_group].nlist[tot_nomen].default_ind = agc.default_ind,
     reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].use_units_ind = agc.use_units_ind,
     reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].reference_ind = agc.reference_ind,
     reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].result_process.code_value = agc
     .result_process_cd
     IF (agc.result_process_cd > 0)
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].result_process.display = cv.display,
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].result_process.description = cv
      .description
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,tot_nomen)
   SET stat = alterlist(reply->slist[tot_slist].glist,tot_group)
 ENDFOR
 SET tot_group = 0
 SET group_cnt = 0
 FOR (x = 1 TO glist_cnt)
   SET tot_group = 0
   SET group_cnt = 0
   SET tot_slist = (tot_slist+ 1)
   SET stat = alterlist(reply->slist[tot_slist].glist,20)
   SELECT INTO "NL:"
    FROM br_alpha_group ag,
     br_alpha_group_components agc,
     nomenclature n,
     code_value cs1902,
     code_value cv
    PLAN (ag
     WHERE (ag.group_id=request->glist[x].group_id)
      AND ((ag.active_ind=1) OR (ag.active_ind=0
      AND (request->load_inactive_ind=1))) )
     JOIN (cv
     WHERE ag.source_vocabulary_cd=cv.code_value)
     JOIN (agc
     WHERE agc.group_id=outerjoin(ag.group_id))
     JOIN (n
     WHERE n.nomenclature_id=outerjoin(agc.nomenclature_id))
     JOIN (cs1902
     WHERE cs1902.active_ind=outerjoin(1)
      AND cs1902.code_value > outerjoin(0)
      AND cs1902.code_value=outerjoin(agc.result_process_cd))
    ORDER BY ag.description, agc.sequence
    HEAD ag.group_id
     IF (tot_group > 0)
      stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,tot_nomen)
     ENDIF
     tot_group = (tot_group+ 1), group_cnt = (group_cnt+ 1)
     IF (group_cnt > 20)
      stat = alterlist(reply->slist[tot_slist].glist,(tot_group+ 20)), group_cnt = 0
     ENDIF
     reply->slist[tot_slist].code_value = ag.source_vocabulary_cd, reply->slist[tot_slist].
     cdf_meaning = cv.cdf_meaning, reply->slist[tot_slist].display = cv.display,
     reply->slist[tot_slist].glist[tot_group].group_id = ag.group_id, reply->slist[tot_slist].glist[
     tot_group].description = ag.description, tot_nomen = 0,
     nomen_cnt = 0, stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,10)
    DETAIL
     IF (agc.nomenclature_id > 0)
      tot_nomen = (tot_nomen+ 1), nomen_cnt = (nomen_cnt+ 1)
      IF (nomen_cnt > 10)
       stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,(tot_nomen+ 10)), nomen_cnt =
       0
      ENDIF
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].nomenclature_id = agc.nomenclature_id,
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].sequence = agc.sequence, reply->
      slist[tot_slist].glist[tot_group].nlist[tot_nomen].source_string = n.source_string,
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].short_string = n.short_string, reply
      ->slist[tot_slist].glist[tot_group].nlist[tot_nomen].mnemonic = n.mnemonic, reply->slist[
      tot_slist].glist[tot_group].nlist[tot_nomen].default_ind = agc.default_ind,
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].use_units_ind = agc.use_units_ind,
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].reference_ind = agc.reference_ind,
      reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].result_process.code_value = agc
      .result_process_cd
      IF (agc.result_process_cd > 0)
       reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].result_process.display = cs1902
       .display, reply->slist[tot_slist].glist[tot_group].nlist[tot_nomen].result_process.description
        = cs1902.description
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->slist[tot_slist].glist[tot_group].nlist,tot_nomen)
   SET stat = alterlist(reply->slist[tot_slist].glist,tot_group)
 ENDFOR
 SET stat = alterlist(reply->slist,tot_slist)
 IF (tot_slist=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (tot_slist > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
