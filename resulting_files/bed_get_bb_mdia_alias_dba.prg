CREATE PROGRAM bed_get_bb_mdia_alias:dba
 FREE SET reply
 RECORD reply(
   1 models[*]
     2 code_value = f8
     2 aborh[*]
       3 code_value = f8
       3 mean = vc
       3 display = vc
       3 description = vc
       3 ignore_ind = i2
       3 alias[*]
         4 alias = vc
       3 proposed_alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET rcnt = size(request->models,5)
 SET stat = alterlist(reply->models,rcnt)
 FOR (x = 1 TO rcnt)
   SET reply->models[x].code_value = request->models[x].code_value
 ENDFOR
 FREE SET aborh
 RECORD aborh(
   1 qual[*]
     2 code_value = f8
     2 mean = vc
     2 display = vc
     2 description = vc
 )
 SET acnt = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=1640
    AND c.active_ind=1)
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(aborh->qual,acnt), aborh->qual[acnt].code_value = c.code_value,
   aborh->qual[acnt].mean = c.cdf_meaning, aborh->qual[acnt].display = c.display, aborh->qual[acnt].
   description = c.description
  WITH nocounter
 ;end select
 IF (acnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO rcnt)
   SET stat = alterlist(reply->models[x].aborh,acnt)
   FOR (y = 1 TO acnt)
     SET reply->models[x].aborh[y].code_value = aborh->qual[y].code_value
     SET reply->models[x].aborh[y].mean = aborh->qual[y].mean
     SET reply->models[x].aborh[y].display = aborh->qual[y].display
     SET reply->models[x].aborh[y].description = aborh->qual[y].description
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     code_value_alias c
    PLAN (d)
     JOIN (c
     WHERE (c.code_value=reply->models[x].aborh[d.seq].code_value)
      AND (c.contributor_source_cd=reply->models[x].code_value))
    ORDER BY d.seq
    HEAD d.seq
     scnt = 0
    DETAIL
     scnt = (scnt+ 1), stat = alterlist(reply->models[x].aborh[d.seq].alias,scnt), reply->models[x].
     aborh[d.seq].alias[scnt].alias = c.alias
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     br_bb_model m,
     br_bb_model_alias a
    PLAN (d)
     JOIN (m
     WHERE (m.model_cd=reply->models[x].code_value))
     JOIN (a
     WHERE a.br_bb_model_id=m.br_bb_model_id
      AND (a.aborh_cd=reply->models[x].aborh[d.seq].code_value))
    ORDER BY d.seq
    HEAD d.seq
     IF (size(reply->models[x].aborh[d.seq].alias,5)=0)
      reply->models[x].aborh[d.seq].proposed_alias = a.br_bb_model_alias
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     br_name_value b
    PLAN (d)
     JOIN (b
     WHERE b.br_nv_key1="BB_ALIAS_IGNORE"
      AND b.br_name=cnvtstring(reply->models[x].code_value)
      AND b.br_value=cnvtstring(reply->models[x].aborh[d.seq].code_value))
    ORDER BY d.seq
    HEAD d.seq
     reply->models[x].aborh[d.seq].ignore_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
