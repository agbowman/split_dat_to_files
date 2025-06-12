CREATE PROGRAM bed_ens_ocrec_orderables:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ord_cat_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=13016
   AND cv.cdf_meaning="ORD CAT"
   AND cv.active_ind=1
  DETAIL
   ord_cat_value = cv.code_value
  WITH nocounter
 ;end select
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 DECLARE concept_cki = vc
 SET cnt = size(request->orderables,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET new_ind = 0
 SET catalog_type_cd = 0.0
 SET activity_type_cd = 0.0
 SELECT INTO "nl:"
  FROM order_catalog o
  PLAN (o
   WHERE (o.catalog_cd=request->orderables[1].catalog_code_value))
  DETAIL
   catalog_type_cd = o.catalog_type_cd, activity_type_cd = o.activity_type_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value br,
   dummyt d
  PLAN (br
   WHERE br.br_nv_key1="NEW_PHASE_X_MATCH")
   JOIN (d
   WHERE cnvtint(br.br_name)=catalog_type_cd
    AND cnvtint(br.br_value)=activity_type_cd)
  DETAIL
   new_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   SET concept_cki = " "
   SET bedrock_cd = 0.0
   IF ((request->orderables[x].concept_cki.ind=1)
    AND (request->orderables[x].concept_cki.value IN ("", " ")))
    SET match_found = 0
    IF (new_ind=0)
     SELECT INTO "nl:"
      FROM order_catalog o
      PLAN (o
       WHERE (o.catalog_cd=request->orderables[x].catalog_code_value))
      DETAIL
       concept_cki = o.concept_cki
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM br_auto_order_catalog b
      PLAN (b
       WHERE b.concept_cki=concept_cki)
      DETAIL
       bedrock_cd = b.catalog_cd
      WITH nocounter, skipbedrock = 1
     ;end select
     SELECT INTO "nl:"
      FROM br_oc_work b
      PLAN (b
       WHERE b.match_orderable_cd IN (bedrock_cd, request->orderables[x].catalog_code_value))
      DETAIL
       match_found = 1
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM br_name_value b
      PLAN (b
       WHERE b.br_nv_key1="PHASE_X_MATCH"
        AND b.br_name != cnvtstring(request->orderables[x].legacy_id)
        AND b.br_value=cnvtstring(request->orderables[x].catalog_code_value))
      DETAIL
       match_found = 1
      WITH nocounter
     ;end select
     DELETE  FROM br_name_value br
      WHERE br.br_nv_key1="PHASE_X_MATCH"
       AND br.br_value=cnvtstring(request->orderables[x].catalog_code_value)
       AND br.br_name=cnvtstring(request->orderables[x].legacy_id)
      WITH nocounter
     ;end delete
    ENDIF
    IF (match_found=1)
     SET request->orderables[x].concept_cki.ind = 0
    ENDIF
   ENDIF
 ENDFOR
 SET ierrcode = 0
 UPDATE  FROM order_catalog o,
   (dummyt d  WITH seq = value(cnt))
  SET o.catalog_type_cd =
   IF ((request->orderables[d.seq].catalog_type.ind=1)) request->orderables[d.seq].catalog_type.
    code_value
   ELSE o.catalog_type_cd
   ENDIF
   , o.activity_type_cd =
   IF ((request->orderables[d.seq].activity_type.ind=1)) request->orderables[d.seq].activity_type.
    code_value
   ELSE o.activity_type_cd
   ENDIF
   , o.activity_subtype_cd =
   IF ((request->orderables[d.seq].activity_subtype.ind=1)) request->orderables[d.seq].
    activity_subtype.code_value
   ELSE o.activity_subtype_cd
   ENDIF
   ,
   o.concept_cki =
   IF ((request->orderables[d.seq].concept_cki.ind=1)) request->orderables[d.seq].concept_cki.value
   ELSE o.concept_cki
   ENDIF
   , o.updt_id = reqinfo->updt_id, o.updt_dt_tm = cnvtdatetime(curdate,curtime),
   o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o.updt_cnt
   + 1)
  PLAN (d)
   JOIN (o
   WHERE (o.catalog_cd=request->orderables[d.seq].catalog_code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
 UPDATE  FROM bill_item bi,
   (dummyt d  WITH seq = value(cnt))
  SET bi.ext_owner_cd = request->orderables[d.seq].activity_type.code_value, bi.updt_id = reqinfo->
   updt_id, bi.updt_dt_tm = cnvtdatetime(curdate,curtime),
   bi.updt_task = reqinfo->updt_task, bi.updt_applctx = reqinfo->updt_applctx, bi.updt_cnt = (bi
   .updt_cnt+ 1)
  PLAN (d
   WHERE (request->orderables[d.seq].activity_type.ind=1))
   JOIN (bi
   WHERE (bi.ext_parent_reference_id=request->orderables[d.seq].catalog_code_value)
    AND bi.active_ind=1
    AND bi.parent_qual_cd=1.0
    AND bi.ext_parent_contributor_cd=ord_cat_value
    AND bi.ext_child_reference_id=0.0)
  WITH nocounter
 ;end update
 SET ierrcode = 0
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(cnt))
  SET c.concept_cki =
   IF ((request->orderables[d.seq].concept_cki.ind=1)) request->orderables[d.seq].concept_cki.value
   ELSE c.concept_cki
   ENDIF
   , c.updt_id = reqinfo->updt_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt
   + 1)
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->orderables[d.seq].catalog_code_value))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  SET reply->error_msg = serrmsg
  GO TO exit_script
 ENDIF
 IF (new_ind=1)
  FOR (x = 1 TO cnt)
    IF ((request->orderables[x].concept_cki.ind=1)
     AND (request->orderables[x].concept_cki.value > " "))
     INSERT  FROM br_name_value br
      SET br.br_name_value_id = seq(bedrock_seq,nextval), br.br_nv_key1 = "PHASE_X_MATCH", br.br_name
        = cnvtstring(request->orderables[x].legacy_id),
       br.br_value = cnvtstring(request->orderables[x].catalog_code_value), br.updt_cnt = 0, br
       .updt_dt_tm = cnvtdatetime(curdate,curtime),
       br.updt_id = reqinfo->updt_id, br.updt_task = reqinfo->updt_task, br.updt_applctx = reqinfo->
       updt_applctx
      PLAN (br)
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
