CREATE PROGRAM act_get_code:dba
 RECORD reply(
   1 code_value = f8
   1 code_set = i4
   1 description = vc
   1 display = vc
   1 meaning = vc
   1 definition = vc
   1 collation_seq = i4
   1 alias[*]
     2 source = f8
     2 alias = vc
     2 meaning = vc
   1 extension[*]
     2 name = vc
     2 value = vc
   1 parent[*]
     2 code = f8
     2 code_set = i4
     2 description = vc
     2 display = vc
     2 meaning = vc
   1 child[*]
     2 code = f8
     2 code_set = i4
     2 description = vc
     2 display = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET code = 0
 IF ((request->code_value=0)
  AND (((request->code_set=0)) OR (size(trim(request->cdf_meaning))=0)) )
  GO TO exit_program
 ENDIF
 SET first_time = 0
 SELECT
  IF ((request->code_value > 0))
   PLAN (c
    WHERE (c.code_value=request->code_value))
  ELSE
   PLAN (c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->cdf_meaning)
     AND c.active_ind=1)
  ENDIF
  INTO "nl:"
  FROM code_value c
  DETAIL
   first_time = (first_time+ 1), code = c.code_value, reply->code_value = c.code_value,
   reply->code_set = c.code_set, reply->description = trim(c.description,3), reply->display = trim(c
    .display,3),
   reply->meaning = cnvtupper(trim(c.cdf_meaning,3)), reply->definition = trim(c.definition,3), reply
   ->collation_seq = c.collation_seq
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ENDIF
 IF (first_time > 1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NON_UNIQUE_MEANING"
  SET reply->code_value = 0
  SET reply->code_set = 0
  SET reply->description = ""
  SET reply->display = ""
  SET reply->meaning = ""
  SET reply->collation_seq = 0
  GO TO exit_program
 ENDIF
 IF ((request->alias_ind=1))
  SET i = 0
  SELECT INTO "nl:"
   FROM code_value_alias a
   PLAN (a
    WHERE a.code_value=code
     AND ((a.contributor_source_cd+ 0) > 0.0)
     AND trim(a.alias,3) > " ")
   DETAIL
    i = (i+ 1), stat = alterlist(reply->alias,i), reply->alias[i].source = a.contributor_source_cd,
    reply->alias[i].alias = trim(a.alias,3), reply->alias[i].meaning = cnvtupper(trim(a
      .alias_type_meaning,3))
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->extension_ind=1))
  SET i = 0
  SELECT INTO "nl:"
   FROM code_value_extension e
   PLAN (e
    WHERE e.code_value=code
     AND trim(e.field_name,3) > " "
     AND trim(e.field_value,3) > " ")
   DETAIL
    i = (i+ 1), stat = alterlist(reply->extension,i), reply->extension[i].name = cnvtupper(trim(e
      .field_name,3)),
    reply->extension[i].value = trim(e.field_value,3)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->parent_ind=1))
  SET i = 0
  SELECT INTO "nl:"
   FROM code_value_group g,
    code_value c
   PLAN (g
    WHERE g.child_code_value=code
     AND ((g.parent_code_value+ 0) > 0.0))
    JOIN (c
    WHERE c.code_value=g.parent_code_value
     AND trim(c.display,3) > " ")
   ORDER BY c.display_key
   DETAIL
    i = (i+ 1), stat = alterlist(reply->parent,i), reply->parent[i].code = c.code_value,
    reply->parent[i].code_set = c.code_set, reply->parent[i].description = trim(c.description,3),
    reply->parent[i].display = trim(c.display,3),
    reply->parent[i].meaning = cnvtupper(trim(c.cdf_meaning,3))
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->child_ind=1))
  SET i = 0
  SELECT INTO "nl:"
   FROM code_value_group g,
    code_value c
   PLAN (g
    WHERE g.parent_code_value=code
     AND ((g.child_code_value+ 0) > 0.0))
    JOIN (c
    WHERE c.code_value=g.child_code_value
     AND trim(c.display,3) > " ")
   ORDER BY c.display_key
   DETAIL
    i = (i+ 1), stat = alterlist(reply->child,i), reply->child[i].code = c.code_value,
    reply->child[i].code_set = c.code_set, reply->child[i].description = trim(c.description,3), reply
    ->child[i].display = trim(c.display,3),
    reply->child[i].meaning = cnvtupper(trim(c.cdf_meaning,3))
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_program
END GO
