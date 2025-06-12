CREATE PROGRAM bed_get_sets_for_alias_build:dba
 FREE SET reply
 RECORD reply(
   1 code_sets[*]
     2 code_set = i4
     2 name = vc
     2 inbound_ind = i2
     2 outbound_ind = i2
     2 missing_aliases_ind = i2
     2 add_allowed_ind = i2
     2 change_allowed_ind = i2
     2 cdf_meaning_dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD hold_sets(
   1 code_sets[*]
     2 code_set = i4
     2 name = vc
     2 inbound_ind = i2
     2 outbound_ind = i2
     2 missing_aliases_ind = i2
     2 add_allowed_ind = i2
     2 change_allowed_ind = i2
     2 cdf_meaning_dup_ind = i2
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 IF ((request->alias_config_params_ind=0))
  SELECT DISTINCT INTO "NL:"
   b.codeset
   FROM br_contr_cs_r b,
    code_value_set cvs
   PLAN (b
    WHERE (b.contributor_system_cd=request->contributor_system_code_value))
    JOIN (cvs
    WHERE cvs.code_set=b.codeset)
   ORDER BY b.codeset
   DETAIL
    ccnt = (ccnt+ 1), stat = alterlist(hold_sets->code_sets,ccnt), hold_sets->code_sets[ccnt].
    code_set = b.codeset,
    hold_sets->code_sets[ccnt].name = cvs.display, hold_sets->code_sets[ccnt].add_allowed_ind = cvs
    .add_access_ind, hold_sets->code_sets[ccnt].change_allowed_ind = cvs.chg_access_ind,
    hold_sets->code_sets[ccnt].cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind
   WITH nocounter
  ;end select
  IF (ccnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     br_contr_cs_r bcs,
     br_contr_seg_r bseg,
     br_contr_type_r btype
    PLAN (d)
     JOIN (bcs
     WHERE (bcs.contributor_system_cd=request->contributor_system_code_value)
      AND (bcs.codeset=hold_sets->code_sets[d.seq].code_set))
     JOIN (bseg
     WHERE bseg.segment_name=bcs.segment_name)
     JOIN (btype
     WHERE btype.br_contr_type_r_id=bseg.br_contr_type_r_id
      AND (btype.contributor_system_cd=request->contributor_system_code_value))
    DETAIL
     IF (btype.in_out_flg IN (1, 3))
      hold_sets->code_sets[d.seq].inbound_ind = 1
     ENDIF
     IF (btype.in_out_flg IN (2, 3))
      hold_sets->code_sets[d.seq].outbound_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value cv,
     br_name_value bnv,
     code_value_outbound cvo,
     code_value_alias cva
    PLAN (d)
     JOIN (cv
     WHERE (cv.code_set=hold_sets->code_sets[d.seq].code_set))
     JOIN (bnv
     WHERE bnv.br_nv_key1=outerjoin("ALIAS_IGNORE_CV")
      AND cnvtreal(trim(bnv.br_name))=outerjoin(request->contributor_system_code_value)
      AND cnvtreal(trim(bnv.br_value))=outerjoin(cv.code_value))
     JOIN (cvo
     WHERE cvo.code_value=outerjoin(cv.code_value)
      AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
     JOIN (cva
     WHERE cva.code_value=outerjoin(cv.code_value)
      AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    DETAIL
     IF ((hold_sets->code_sets[d.seq].inbound_ind=1)
      AND cva.alias=" "
      AND cnvtreal(trim(bnv.br_value))=0)
      hold_sets->code_sets[d.seq].missing_aliases_ind = 1
     ENDIF
     IF ((hold_sets->code_sets[d.seq].outbound_ind=1)
      AND cvo.alias=" "
      AND cvo.code_value=0
      AND cnvtreal(trim(bnv.br_value))=0)
      hold_sets->code_sets[d.seq].missing_aliases_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->code_sets,ccnt)
   FOR (c = 1 TO ccnt)
     SET reply->code_sets[c].code_set = hold_sets->code_sets[c].code_set
     SET reply->code_sets[c].name = hold_sets->code_sets[c].name
     SET reply->code_sets[c].inbound_ind = hold_sets->code_sets[c].inbound_ind
     SET reply->code_sets[c].outbound_ind = hold_sets->code_sets[c].outbound_ind
     SET reply->code_sets[c].missing_aliases_ind = hold_sets->code_sets[c].missing_aliases_ind
     SET reply->code_sets[c].add_allowed_ind = hold_sets->code_sets[c].add_allowed_ind
     SET reply->code_sets[c].change_allowed_ind = hold_sets->code_sets[c].change_allowed_ind
     SET reply->code_sets[c].cdf_meaning_dup_ind = hold_sets->code_sets[c].cdf_meaning_dup_ind
   ENDFOR
  ENDIF
 ELSEIF ((request->alias_config_params_ind=1))
  SELECT DISTINCT INTO "NL:"
   b.codeset
   FROM br_seg_field_r b,
    code_value_set cvs
   PLAN (b)
    JOIN (cvs
    WHERE cvs.code_set=b.codeset)
   ORDER BY b.codeset
   DETAIL
    ccnt = (ccnt+ 1), stat = alterlist(reply->code_sets,ccnt), reply->code_sets[ccnt].code_set = b
    .codeset,
    reply->code_sets[ccnt].name = cvs.display, reply->code_sets[ccnt].add_allowed_ind = cvs
    .add_access_ind, reply->code_sets[ccnt].change_allowed_ind = cvs.chg_access_ind,
    reply->code_sets[ccnt].cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT
   cvs.code_set
   FROM code_value_set cvs
   DETAIL
    ccnt = (ccnt+ 1), stat = alterlist(reply->code_sets,ccnt), reply->code_sets[ccnt].code_set = cvs
    .code_set,
    reply->code_sets[ccnt].name = cvs.display, reply->code_sets[ccnt].add_allowed_ind = cvs
    .add_access_ind, reply->code_sets[ccnt].change_allowed_ind = cvs.chg_access_ind,
    reply->code_sets[ccnt].cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
