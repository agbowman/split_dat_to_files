CREATE PROGRAM bed_get_icd_synonyms:dba
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 code = vc
     2 new_synonyms[*]
       3 cmti = vc
       3 principle_type
         4 code_value = f8
         4 meaning = vc
         4 display = vc
       3 source_vocab
         4 code_value = f8
         4 meaning = vc
         4 display = vc
       3 term = vc
       3 code = vc
       3 source = vc
       3 contributor_system
         4 code_value = f8
         4 meaning = vc
         4 display = vc
     2 current_synonyms[*]
       3 nomenclature_id = f8
       3 principle_type
         4 code_value = f8
         4 meaning = vc
         4 display = vc
       3 source_vocab
         4 code_value = f8
         4 meaning = vc
         4 display = vc
       3 term = vc
       3 code = vc
       3 source = vc
       3 cmti = vc
       3 contributor_system
         4 code_value = f8
         4 meaning = vc
         4 display = vc
       3 cross_mapping_ind = i2
       3 begin_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET tcode
 RECORD tcode(
   1 codes[*]
     2 code = vc
     2 principle_code = f8
     2 principle_mean = vc
     2 principle_disp = vc
     2 source_vocab_code = f8
     2 source_vocab_mean = vc
     2 source_vocab_disp = vc
     2 synonyms[*]
       3 term = vc
       3 code = vc
       3 source = vc
 )
 SET reply->status_data.status = "F"
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 SET client_code = uar_get_code_by("MEANING",89,"CLIENT")
 SET req_cnt = 0
 SET req_cnt = size(request->codes,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->codes,req_cnt)
 SET stat = alterlist(tcode->codes,req_cnt)
 FOR (x = 1 TO req_cnt)
  SET reply->codes[x].code = request->codes[x].code
  SET tcode->codes[x].code = request->codes[x].code
 ENDFOR
 IF (client_code > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    nomenclature_load_ns ns,
    code_value pt,
    code_value sv,
    code_value va,
    code_value cs,
    code_value l
   PLAN (d)
    JOIN (ns
    WHERE (ns.source_identifier=reply->codes[d.seq].code)
     AND ns.source_vocabulary_mean="ICD9"
     AND ns.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ns.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ns.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     n2.cmti
     FROM nomenclature n2
     WHERE n2.cmti=ns.cmti))))
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
   ORDER BY d.seq, ns.cmti
   HEAD d.seq
    cnt = 0, tcnt = 0, stat = alterlist(reply->codes[d.seq].new_synonyms,100)
   DETAIL
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->codes[d.seq].new_synonyms,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->codes[d.seq].new_synonyms[tcnt].cmti = ns.cmti, reply->codes[d.seq].new_synonyms[tcnt].
    code = ns.source_identifier, reply->codes[d.seq].new_synonyms[tcnt].principle_type.code_value =
    pt.code_value,
    reply->codes[d.seq].new_synonyms[tcnt].principle_type.meaning = pt.cdf_meaning, reply->codes[d
    .seq].new_synonyms[tcnt].principle_type.display = pt.display, reply->codes[d.seq].new_synonyms[
    tcnt].source = cs.display,
    reply->codes[d.seq].new_synonyms[tcnt].source_vocab.code_value = sv.code_value, reply->codes[d
    .seq].new_synonyms[tcnt].source_vocab.meaning = sv.cdf_meaning, reply->codes[d.seq].new_synonyms[
    tcnt].source_vocab.display = sv.display,
    reply->codes[d.seq].new_synonyms[tcnt].term = ns.source_string, reply->codes[d.seq].new_synonyms[
    tcnt].contributor_system.code_value = cs.code_value, reply->codes[d.seq].new_synonyms[tcnt].
    contributor_system.meaning = cs.cdf_meaning,
    reply->codes[d.seq].new_synonyms[tcnt].contributor_system.display = cs.display
   FOOT  d.seq
    stat = alterlist(reply->codes[d.seq].new_synonyms,tcnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   nomenclature n,
   code_value pt,
   code_value sv
  PLAN (d)
   JOIN (n
   WHERE n.source_vocabulary_cd=icd_code
    AND (n.source_identifier=tcode->codes[d.seq].code)
    AND ((n.primary_vterm_ind+ 0)=1)
    AND ((n.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((n.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3))
    AND ((n.active_ind+ 0)=1))
   JOIN (pt
   WHERE pt.code_value=n.principle_type_cd
    AND pt.active_ind=1)
   JOIN (sv
   WHERE sv.code_value=n.source_vocabulary_cd
    AND sv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   tcode->codes[d.seq].principle_code = pt.code_value, tcode->codes[d.seq].principle_disp = pt
   .display, tcode->codes[d.seq].principle_mean = pt.cdf_meaning,
   tcode->codes[d.seq].source_vocab_code = sv.code_value, tcode->codes[d.seq].source_vocab_disp = sv
   .display, tcode->codes[d.seq].source_vocab_mean = sv.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   br_vocabulary v,
   nomenclature n
  PLAN (d)
   JOIN (v
   WHERE v.source_vocab_mean="ICD9"
    AND (v.source_identifier=tcode->codes[d.seq].code))
   JOIN (n
   WHERE n.source_vocabulary_cd=outerjoin(tcode->codes[d.seq].source_vocab_code)
    AND cnvtupper(n.source_identifier)=outerjoin(cnvtupper(v.source_identifier))
    AND cnvtupper(n.source_string)=outerjoin(cnvtupper(v.source_string))
    AND n.principle_type_cd=outerjoin(tcode->codes[d.seq].principle_code))
  ORDER BY d.seq, v.br_vocabulary_id
  HEAD d.seq
   cnt = 0, tcnt = size(reply->codes[d.seq].new_synonyms,5), stat = alterlist(reply->codes[d.seq].
    new_synonyms,(tcnt+ 100))
  HEAD v.br_vocabulary_id
   IF (n.nomenclature_id=0)
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->codes[d.seq].new_synonyms,(tcnt+ 100)), cnt = 1
    ENDIF
    reply->codes[d.seq].new_synonyms[tcnt].code = v.source_identifier, reply->codes[d.seq].
    new_synonyms[tcnt].principle_type.code_value = tcode->codes[d.seq].principle_code, reply->codes[d
    .seq].new_synonyms[tcnt].principle_type.meaning = tcode->codes[d.seq].principle_mean,
    reply->codes[d.seq].new_synonyms[tcnt].principle_type.display = tcode->codes[d.seq].
    principle_disp, reply->codes[d.seq].new_synonyms[tcnt].source = v.source_name, reply->codes[d.seq
    ].new_synonyms[tcnt].source_vocab.code_value = tcode->codes[d.seq].source_vocab_code,
    reply->codes[d.seq].new_synonyms[tcnt].source_vocab.meaning = tcode->codes[d.seq].
    source_vocab_mean, reply->codes[d.seq].new_synonyms[tcnt].source_vocab.display = tcode->codes[d
    .seq].source_vocab_disp, reply->codes[d.seq].new_synonyms[tcnt].term = v.source_string
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->codes[d.seq].new_synonyms,tcnt)
  WITH nocounter
 ;end select
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   nomenclature n,
   code_value pt,
   code_value sv,
   code_value cs
  PLAN (d)
   JOIN (n
   WHERE (n.source_identifier=reply->codes[d.seq].code)
    AND n.source_vocabulary_cd=icd_code
    AND n.primary_vterm_ind IN (0, null)
    AND n.active_ind=1)
   JOIN (pt
   WHERE pt.code_value=n.principle_type_cd
    AND pt.active_ind=1)
   JOIN (sv
   WHERE sv.code_value=n.source_vocabulary_cd
    AND sv.active_ind=1)
   JOIN (cs
   WHERE cs.code_value=n.contributor_system_cd
    AND cs.active_ind=1)
  ORDER BY d.seq, n.nomenclature_id
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->codes[d.seq].current_synonyms,100)
  HEAD n.nomenclature_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->codes[d.seq].current_synonyms,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->codes[d.seq].current_synonyms[tcnt].nomenclature_id = n.nomenclature_id, reply->codes[d.seq
   ].current_synonyms[tcnt].code = n.source_identifier, reply->codes[d.seq].current_synonyms[tcnt].
   principle_type.code_value = pt.code_value,
   reply->codes[d.seq].current_synonyms[tcnt].principle_type.meaning = pt.cdf_meaning, reply->codes[d
   .seq].current_synonyms[tcnt].principle_type.display = pt.display, reply->codes[d.seq].
   current_synonyms[tcnt].source_vocab.code_value = sv.code_value,
   reply->codes[d.seq].current_synonyms[tcnt].source_vocab.meaning = sv.cdf_meaning, reply->codes[d
   .seq].current_synonyms[tcnt].source_vocab.display = sv.display, reply->codes[d.seq].
   current_synonyms[tcnt].term = n.source_string,
   reply->codes[d.seq].current_synonyms[tcnt].cmti = n.cmti, reply->codes[d.seq].current_synonyms[
   tcnt].contributor_system.code_value = cs.code_value, reply->codes[d.seq].current_synonyms[tcnt].
   contributor_system.meaning = cs.cdf_meaning,
   reply->codes[d.seq].current_synonyms[tcnt].contributor_system.display = cs.display, reply->codes[d
   .seq].current_synonyms[tcnt].begin_effective_dt_tm = n.beg_effective_dt_tm, reply->codes[d.seq].
   current_synonyms[tcnt].end_effective_dt_tm = n.end_effective_dt_tm
  FOOT  d.seq
   stat = alterlist(reply->codes[d.seq].current_synonyms,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
