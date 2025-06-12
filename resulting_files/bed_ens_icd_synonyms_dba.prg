CREATE PROGRAM bed_ens_icd_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET treq
 RECORD treq(
   1 codes[*]
     2 action_flag = i2
     2 id = f8
     2 cmti = vc
     2 term = vc
     2 code = vc
     2 principle_type_code = f8
     2 cont_source_code = f8
     2 lang_code = f8
     2 source_vocab_code = f8
     2 vocab_axis_code = f8
     2 primary_vterm_ind = i2
     2 primary_cterm_ind = i2
     2 concept_cki = vc
     2 disallowed_ind = i2
     2 short_string = vc
     2 mnemonic = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET client_code = 0.0
 SET active_code = 0.0
 SET auth_code = 0.0
 SET client_code = uar_get_code_by("MEANING",89,"CLIENT")
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET auth_code = uar_get_code_by("MEANING",8,"AUTH")
 SET req_cnt = size(request->synonyms,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   nomenclature_load_ns ns,
   code_value pt,
   code_value sv,
   code_value va,
   code_value cs,
   code_value l
  PLAN (d
   WHERE (request->synonyms[d.seq].action_flag=1)
    AND (request->synonyms[d.seq].cmti > " "))
   JOIN (ns
   WHERE (ns.cmti=request->synonyms[d.seq].cmti))
   JOIN (pt
   WHERE pt.cdf_meaning=ns.principle_type_mean
    AND pt.code_set=401
    AND pt.active_ind=1)
   JOIN (sv
   WHERE sv.cdf_meaning=ns.source_vocabulary_mean
    AND sv.code_set=400
    AND sv.active_ind=1)
   JOIN (va
   WHERE va.cdf_meaning=ns.vocab_axis_mean
    AND va.code_set=15849
    AND va.active_ind=1)
   JOIN (cs
   WHERE cs.cdf_meaning=ns.contributor_system_mean
    AND cs.code_set=89
    AND cs.active_ind=1)
   JOIN (l
   WHERE l.cdf_meaning=ns.language_mean
    AND l.code_set=36
    AND l.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(treq->codes,100)
  HEAD d.seq
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(treq->codes,(tcnt+ 100)), cnt = 1
   ENDIF
   treq->codes[tcnt].action_flag = 1, treq->codes[tcnt].cmti = ns.cmti, treq->codes[tcnt].concept_cki
    = ns.concept_cki,
   treq->codes[tcnt].cont_source_code = cs.code_value, treq->codes[tcnt].disallowed_ind = ns
   .disallowed_ind, treq->codes[tcnt].lang_code = l.code_value,
   treq->codes[tcnt].mnemonic = ns.mnemonic, treq->codes[tcnt].primary_cterm_ind = ns
   .primary_cterm_ind, treq->codes[tcnt].primary_vterm_ind = ns.primary_vterm_ind,
   treq->codes[tcnt].principle_type_code = pt.code_value, treq->codes[tcnt].short_string = ns
   .short_string, treq->codes[tcnt].source_vocab_code = sv.code_value,
   treq->codes[tcnt].term = ns.source_string, treq->codes[tcnt].vocab_axis_code = va.code_value, treq
   ->codes[tcnt].code = ns.source_identifier,
   treq->codes[tcnt].beg_effective_dt_tm = ns.beg_effective_dt_tm, treq->codes[tcnt].
   end_effective_dt_tm = ns.end_effective_dt_tm
  FOOT REPORT
   stat = alterlist(treq->codes,tcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   nomenclature n
  PLAN (d
   WHERE (request->synonyms[d.seq].action_flag=1)
    AND (request->synonyms[d.seq].cmti IN (" ", "", null))
    AND (request->synonyms[d.seq].code_nomenclature_id > 0))
   JOIN (n
   WHERE (n.nomenclature_id=request->synonyms[d.seq].code_nomenclature_id))
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0, tcnt = size(treq->codes,5), stat = alterlist(treq->codes,(tcnt+ 100))
  HEAD d.seq
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(treq->codes,(tcnt+ 100)), cnt = 1
   ENDIF
   treq->codes[tcnt].action_flag = 1, treq->codes[tcnt].concept_cki = n.concept_cki, treq->codes[tcnt
   ].cont_source_code = client_code,
   treq->codes[tcnt].disallowed_ind = n.disallowed_ind, treq->codes[tcnt].lang_code = n.language_cd,
   treq->codes[tcnt].mnemonic = request->synonyms[d.seq].term,
   treq->codes[tcnt].principle_type_code = n.principle_type_cd, treq->codes[tcnt].short_string =
   request->synonyms[d.seq].term, treq->codes[tcnt].source_vocab_code = n.source_vocabulary_cd,
   treq->codes[tcnt].term = request->synonyms[d.seq].term, treq->codes[tcnt].vocab_axis_code = n
   .vocab_axis_cd, treq->codes[tcnt].code = request->synonyms[d.seq].code,
   treq->codes[tcnt].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), treq->codes[tcnt].
   end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
  FOOT REPORT
   stat = alterlist(treq->codes,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SET ierrcode = 0
  INSERT  FROM nomenclature n,
    (dummyt d  WITH seq = value(tcnt))
   SET n.active_ind = 1, n.active_status_cd = active_code, n.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    n.active_status_prsnl_id = reqinfo->updt_id, n.beg_effective_dt_tm = cnvtdatetime(treq->codes[d
     .seq].beg_effective_dt_tm), n.cmti = treq->codes[d.seq].cmti,
    n.concept_cki = treq->codes[d.seq].concept_cki, n.contributor_system_cd = treq->codes[d.seq].
    cont_source_code, n.data_status_cd = auth_code,
    n.data_status_dt_tm = cnvtdatetime(curdate,curtime3), n.data_status_prsnl_id = reqinfo->updt_id,
    n.disallowed_ind = treq->codes[d.seq].disallowed_ind,
    n.end_effective_dt_tm = cnvtdatetime(treq->codes[d.seq].end_effective_dt_tm), n.language_cd =
    treq->codes[d.seq].lang_code, n.nomenclature_id = seq(nomenclature_seq,nextval),
    n.primary_cterm_ind = treq->codes[d.seq].primary_cterm_ind, n.primary_vterm_ind = treq->codes[d
    .seq].primary_vterm_ind, n.principle_type_cd = treq->codes[d.seq].principle_type_code,
    n.source_string = treq->codes[d.seq].term, n.source_string_keycap = cnvtupper(treq->codes[d.seq].
     term), n.source_identifier = treq->codes[d.seq].code,
    n.source_identifier_keycap = cnvtupper(treq->codes[d.seq].code), n.source_vocabulary_cd = treq->
    codes[d.seq].source_vocab_code, n.vocab_axis_cd = treq->codes[d.seq].vocab_axis_code,
    n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id,
    n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (treq->codes[d.seq].action_flag=1))
    JOIN (n)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on insert")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM nomenclature n,
   (dummyt d  WITH seq = value(req_cnt))
  SET n.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100"), n.updt_cnt = (n.updt_cnt+ 1),
   n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo
   ->updt_task,
   n.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->synonyms[d.seq].action_flag=2)
    AND (request->synonyms[d.seq].restore_ind=1))
   JOIN (n
   WHERE (n.nomenclature_id=request->synonyms[d.seq].nomenclature_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on restore")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM nomenclature n,
   (dummyt d  WITH seq = value(req_cnt))
  SET n.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_cnt = (n.updt_cnt+ 1), n
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (request->synonyms[d.seq].action_flag=3))
   JOIN (n
   WHERE (n.nomenclature_id=request->synonyms[d.seq].nomenclature_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on delete")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
