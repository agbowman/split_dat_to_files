CREATE PROGRAM cps_get_nomenstring_sub:dba
 SET reply->s_cnt = 0
 SET kount = 0
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  WHERE  $1
   AND  $2
   AND  $3
   AND  $4
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alter(reply->s_qual,(kount+ 100))
   ENDIF
   reply->s_qual[kount].nomenclature_id = n.nomenclature_id, reply->s_qual[kount].principle_type_cd
    = n.principle_type_cd, reply->s_qual[kount].updt_cnt = n.updt_cnt,
   reply->s_qual[kount].updt_dt_tm = n.updt_dt_tm, reply->s_qual[kount].updt_id = n.updt_id, reply->
   s_qual[kount].updt_task = n.updt_task,
   reply->s_qual[kount].updt_applctx = n.updt_applctx, reply->s_qual[kount].active_ind = n.active_ind,
   reply->s_qual[kount].active_status_cd = n.active_status_cd,
   reply->s_qual[kount].active_status_dt_tm = n.active_status_dt_tm, reply->s_qual[kount].
   active_status_prsnl_id = n.active_status_prsnl_id, reply->s_qual[kount].beg_effective_dt_tm = n
   .beg_effective_dt_tm,
   reply->s_qual[kount].end_effective_dt_tm = n.end_effective_dt_tm, reply->s_qual[kount].
   contributor_system_cd = n.contributor_system_cd, reply->s_qual[kount].source_string = n
   .source_string,
   reply->s_qual[kount].source_identifier = n.source_identifier, reply->s_qual[kount].
   string_identifier = n.string_identifier, reply->s_qual[kount].string_status_cd = n
   .string_status_cd,
   reply->s_qual[kount].term_id = n.term_id, reply->s_qual[kount].language_cd = n.language_cd, reply
   ->s_qual[kount].source_vocabulary_cd = n.source_vocabulary_cd,
   reply->s_qual[kount].nom_ver_grp_id = n.nom_ver_grp_id, reply->s_qual[kount].data_status_cd = n
   .data_status_cd, reply->s_qual[kount].data_status_dt_tm = n.data_status_dt_tm,
   reply->s_qual[kount].data_status_prsnl_id = n.data_status_prsnl_id, reply->s_qual[kount].
   short_string = n.short_string, reply->s_qual[kount].mnemonic = n.mnemonic,
   reply->s_qual[kount].concept_identifier = n.concept_identifier, reply->s_qual[kount].
   concept_source_cd = n.concept_source_cd, reply->s_qual[kount].string_source_cd = n
   .string_source_cd,
   reply->s_qual[kount].vocab_axis_cd = n.vocab_axis_cd, reply->s_qual[kount].primary_vterm_ind = n
   .primary_vterm_ind
  WITH nocounter
 ;end select
 SET reply->s_cnt = kount
 SET stat = alter(reply->s_qual,kount)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->s_qual,5))),
    concept c
   PLAN (d
    WHERE (reply->s_qual[d.seq].concept_source_cd > 0.0)
     AND (reply->s_qual[d.seq].concept_identifier > ""))
    JOIN (c
    WHERE (reply->s_qual[d.seq].concept_source_cd=c.concept_source_cd)
     AND (reply->s_qual[d.seq].concept_identifier=c.concept_identifier))
   DETAIL
    reply->s_qual[d.seq].concept_name = c.concept_name
   WITH nocounter
  ;end select
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo("code count is",0)
 CALL echo(reply->s_cnt)
 CALL echo("source string",0)
 CALL echo(reply->s_qual[1].source_string)
 CALL echo("concept name:",0)
 CALL echo(reply->s_qual[1].concept_name)
 CALL echo("concept identifier:",0)
 CALL echo(reply->s_qual[1].concept_identifier)
 CALL echo("concept source cd:",0)
 CALL echo(cnvtstring(reply->s_qual[1].concept_source_cd))
 CALL echo("********************")
END GO
