CREATE PROGRAM cps_add_concept:dba
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 FREE SET cdvalue
 RECORD cdvalue(
   1 concept_source_cd = f8
   1 review_status_cd = f8
   1 active_status_cd = f8
 )
 DECLARE get_next_code(n) = f8
 SUBROUTINE get_next_code(next_code)
  SELECT INTO "nl:"
   nval = seq(concept_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    next_code = nval
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   RETURN(0)
  ELSE
   RETURN(next_code)
  ENDIF
 END ;Subroutine
 SET ncode = 0
 SET failed = false
 SELECT INTO "nl:"
  FROM code_value c1,
   code_value c2,
   code_value c3
  PLAN (c1
   WHERE c1.code_set=12100
    AND c1.cdf_meaning="CERNER")
   JOIN (c2
   WHERE c2.code_set=12101
    AND c2.cdf_meaning="REVIEWED")
   JOIN (c3
   WHERE c3.code_set=48
    AND c3.cdf_meaning="ACTIVE")
  DETAIL
   cdvalue->concept_source_cd = c1.code_value, cdvalue->review_status_cd = c2.code_value, cdvalue->
   active_status_cd = c3.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = select_error
  SET dhtable_name = "CODE_VALUE"
  SET serrmsg_error = "problem in reading code_value table"
  GO TO error_check
 ENDIF
 DECLARE concept_identifier = vc
 SET k = 1
 IF (trim(request->concept[k].concept_identifier) != " ")
  SET concept_identifier = trim(request->concept[k].concept_identifier,3)
 ELSE
  SET ncode = get_next_code(ncode)
  IF (ncode=0)
   SET failed = gen_nbr_error
   SET dhtable_name = "NONE"
   SET serrmsg_error = "problem in generating sequence number"
   GO TO error_check
  ENDIF
  SET concept_identifier = format(ncode,"########;rp0")
 ENDIF
 IF ((request->concept[k].concept_source_cd > 0))
  SET concept_sourcecd = request->concept[k].concept_source_cd
 ELSE
  SET concept_sourcecd = cdvalue->concept_source_cd
 ENDIF
 IF ((request->concept[k].review_status_cd > 0))
  SET review_statuscd = request->concept[k].review_status_cd
 ELSE
  SET review_statuscd = cdvalue->review_status_cd
 ENDIF
 SELECT INTO "nl:"
  FROM concept ct
  WHERE ct.concept_identifier=concept_identifier
   AND (ct.concept_source_cd=request->concept[k].concept_source_cd)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET failed = select_error
  SET dhtable_name = "CONCEPT"
  SET serrmsg_error = "problem in reading concept table"
  GO TO error_check
 ELSE
  DECLARE concept_mean = c12
  DECLARE concept_cki = vc
  SET concept_mean = uar_get_code_meaning(concept_sourcecd)
  SET concept_cki = build(concept_mean,"!",concept_identifier)
  INSERT  FROM concept con
   SET con.concept_identifier = trim(concept_identifier,3), con.concept_source_cd = concept_sourcecd,
    con.concept_name = trim(request->concept[k].concept_name,3),
    con.review_status_cd = review_statuscd, con.updt_cnt = 0, con.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    con.updt_id = reqinfo->updt_id, con.updt_task = reqinfo->updt_task, con.updt_applctx = reqinfo->
    updt_applctx,
    con.active_ind = true, con.active_status_cd = cdvalue->active_status_cd, con.active_status_dt_tm
     = cnvtdatetime(curdate,curtime3),
    con.active_status_prsnl_id = reqinfo->updt_id, con.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), con.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
    con.data_status_cd = request->concept[k].data_status_cd, con.data_status_dt_tm = cnvtdatetime(
     curdate,curtime3), con.data_status_prsnl_id = reqinfo->updt_id,
    con.cki = concept_cki
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = insert_error
   SET dhtable_name = "CONCEPT"
   SET serrmsg_error = "problem in inserting data into conept table"
   GO TO error_check
  ENDIF
  IF (validate(reply,"N") != "N")
   SET reply->concept[k].concept_identifier = concept_identifier
   SET reply->concept[k].concept_source_cd = concept_sourcecd
   SET reply->concept[k].concept_name = request->concept[k].concept_name
  ENDIF
 ENDIF
#error_check
 IF (failed=false)
  SET reqinfo->commit_ind = true
  EXECUTE cps_ens_commit
  IF (validate(reply,"N") != "N")
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  IF (validate(reply,"N") != "N")
   CASE (failed)
    OF select_error:
     SET reply->status_data.subeventstatus[1].operationname = "SELECT"
     SET reply->status_data.status = "Z"
    OF lock_error:
     SET reply->status_data.subeventstatus[1].operationname = "LOCK"
     SET reply->status_data.status = "Z"
    OF update_error:
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reqinfo->commit_ind = false
     SET reply->status_data.status = "Z"
    OF gen_nbr_error:
     SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NUM"
     SET reqinfo->commit_ind = false
     SET reply->status_data.status = "Z"
    ELSE
     SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
     SET reply->status_data.status = "Z"
   ENDCASE
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = dhtable_name
   SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg_error
   SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
   SET reply->status_data.subeventstatus[2].operationstatus = "S"
   SET reqinfo->commit_ind = false
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
