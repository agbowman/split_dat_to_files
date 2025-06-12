CREATE PROGRAM aps_get_snomed_code:dba
 RECORD reply(
   1 qual[*]
     2 nomenclature_id = f8
     2 description = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SET y = 0
 SET vocabcnt = size(request->source_vocab_qual,5)
 SET source_where = fillstring(500," ")
 DECLARE internal_source_vocab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,
   "APINTERNAL"))
 DECLARE ap_alpha_source_vocab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,
   "ANATOMIC PAT"))
 DECLARE is_ap_alpha = i2
 IF (vocabcnt > 0)
  FOR (x = 1 TO vocabcnt)
   IF ((request->source_vocab_qual[x].source_vocabulary_cd=0))
    IF (internal_source_vocab_cd > 0)
     SET request->source_vocab_qual[x].source_vocabulary_cd = internal_source_vocab_cd
    ELSE
     SET request->source_vocab_qual[x].source_vocabulary_cd = - (1)
    ENDIF
   ENDIF
   IF (x=1)
    SET source_where = build("nc.source_vocabulary_cd in (",request->source_vocab_qual[x].
     source_vocabulary_cd)
   ELSE
    SET source_where = build(trim(source_where),",",request->source_vocab_qual[x].
     source_vocabulary_cd)
   ENDIF
  ENDFOR
  SET source_where = concat(trim(source_where),")")
 ELSE
  SET source_where = "0 = 0"
 ENDIF
 SET is_ap_alpha = 0
 IF (vocabcnt=1)
  IF ((request->source_vocab_qual[1].source_vocabulary_cd=ap_alpha_source_vocab_cd))
   SET is_ap_alpha = 1
  ENDIF
 ENDIF
 IF (is_ap_alpha=1)
  SET source_where = build2("nc.source_string_keycap = '",cnvtupper(trim(request->snomed_code)),
   "' and ",trim(source_where))
 ELSE
  SET source_where = build2("nc.source_identifier_keycap = '",cnvtupper(trim(request->snomed_code)),
   "' and ",trim(source_where))
 ENDIF
 SELECT INTO "nl:"
  nc.nomenclature_id, nc.source_string, nc.active_ind
  FROM nomenclature nc
  PLAN (nc
   WHERE parser(source_where))
  HEAD REPORT
   stat = alterlist(reply->qual,10), x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alterlist(reply->qual,(x+ 9))
   ENDIF
   reply->qual[x].nomenclature_id = nc.nomenclature_id, reply->qual[x].description = trim(nc
    .source_string), reply->qual[x].active_ind = nc.active_ind,
   reply->qual[x].beg_effective_dt_tm = cnvtdatetime(nc.beg_effective_dt_tm), reply->qual[x].
   end_effective_dt_tm = cnvtdatetime(nc.end_effective_dt_tm), reply->qual[x].source_vocabulary_cd =
   nc.source_vocabulary_cd
   IF (is_ap_alpha=1)
    reply->qual[x].source_identifier = trim(nc.source_string)
   ELSE
    reply->qual[x].source_identifier = trim(nc.source_identifier)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,x)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
