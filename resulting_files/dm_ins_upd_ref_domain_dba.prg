CREATE PROGRAM dm_ins_upd_ref_domain:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SELECT
  IF (trim(request->old_ref_domain_name)=null)
   WHERE (request->ref_domain_name=a.ref_domain_name)
  ELSE
   WHERE (request->old_ref_domain_name=a.ref_domain_name)
  ENDIF
  INTO "nl:"
  a.ref_domain_name
  FROM dm_ref_domain a
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (trim(request->old_ref_domain_name)=null)
   UPDATE  FROM dm_ref_domain dm
    SET dm.ref_domain_name = trim(request->ref_domain_name), dm.table_name = trim(request->table_name
      ), dm.display_column = trim(request->display_column),
     dm.cki_column = trim(request->cki_column), dm.primary_key_column = trim(request->
      primary_key_column), dm.unique_ident_column = trim(request->unique_ident_column),
     dm.from_clause = trim(request->from_clause), dm.where_clause = trim(request->where_clause), dm
     .human_reqd_ind = request->human_reqd_ind,
     dm.source_from_clause = trim(request->source_from_clause), dm.display_header = trim(request->
      display_header), dm.active_column = trim(request->active_column),
     dm.order_by_column = trim(request->order_by_column), dm.translate_name = trim(request->
      translate_name), dm.code_set = request->code_set
    WHERE trim(request->ref_domain_name)=dm.ref_domain_name
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM dm_ref_domain dm
    SET dm.ref_domain_name = trim(request->ref_domain_name), dm.table_name = trim(request->table_name
      ), dm.display_column = trim(request->display_column),
     dm.cki_column = trim(request->cki_column), dm.primary_key_column = trim(request->
      primary_key_column), dm.unique_ident_column = trim(request->unique_ident_column),
     dm.from_clause = trim(request->from_clause), dm.where_clause = trim(request->where_clause), dm
     .human_reqd_ind = request->human_reqd_ind,
     dm.source_from_clause = trim(request->source_from_clause), dm.display_header = trim(request->
      display_header), dm.active_column = trim(request->active_column),
     dm.order_by_column = trim(request->order_by_column), dm.translate_name = trim(request->
      translate_name), dm.code_set = request->code_set
    WHERE trim(request->old_ref_domain_name)=dm.ref_domain_name
    WITH nocounter
   ;end update
  ENDIF
 ELSE
  INSERT  FROM dm_ref_domain dm
   SET dm.ref_domain_name = trim(request->ref_domain_name), dm.table_name = trim(request->table_name),
    dm.display_column = trim(request->display_column),
    dm.cki_column = trim(request->cki_column), dm.primary_key_column = trim(request->
     primary_key_column), dm.unique_ident_column = trim(request->unique_ident_column),
    dm.from_clause = trim(request->from_clause), dm.where_clause = trim(request->where_clause), dm
    .human_reqd_ind = request->human_reqd_ind,
    dm.source_from_clause = trim(request->source_from_clause), dm.display_header = trim(request->
     display_header), dm.active_column = trim(request->active_column),
    dm.order_by_column = trim(request->order_by_column), dm.translate_name = trim(request->
     translate_name), dm.code_set = request->code_set
   WITH nocounter
  ;end insert
 ENDIF
 IF (trim(request->ref_domain_name) != trim(request->old_ref_domain_name)
  AND trim(request->old_ref_domain_name) != null)
  IF (trim(request->old_ref_domain_name) != null)
   IF (trim(request->old_ref_domain_name) != trim(request->ref_domain_name))
    UPDATE  FROM dm_ref_domain_r b
     SET b.ref_domain_name = trim(request->ref_domain_name)
     WHERE b.ref_domain_name=trim(request->old_ref_domain_name)
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   a.ref_domain_name
   FROM dm_ref_domain_r a
   WHERE a.ref_domain_name=trim(request->ref_domain_name)
    AND a.group_name="ALL"
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_ref_domain_r r
    SET r.group_name = "ALL", r.ref_domain_name = cnvtupper(request->ref_domain_name)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
END GO
