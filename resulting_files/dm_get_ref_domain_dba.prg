CREATE PROGRAM dm_get_ref_domain:dba
 RECORD reply(
   1 qual[*]
     2 ref_domain_name = vc
     2 table_name = vc
     2 display_column_name = vc
     2 cki_column = vc
     2 primary_key_column = vc
     2 unique_ident_column = vc
     2 from_clause = vc
     2 where_clause = vc
     2 human_required_ind = i2
     2 source_from_clause = vc
     2 display_header = vc
     2 active_column = vc
     2 order_by_column = vc
     2 translate_name = vc
     2 code_set = i4
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
   1 count = i2
 )
 SET reply->status_data.status = "F"
 SET reply->count = 0
 SET stat = alterlist(reply->qual,10)
 SELECT INTO "nl:"
  a.*
  FROM dm_ref_domain a
  ORDER BY a.code_set, a.ref_domain_name
  DETAIL
   reply->count = (reply->count+ 1)
   IF (mod(reply->count,10)=1)
    stat = alterlist(reply->qual,(reply->count+ 9))
   ENDIF
   reply->qual[reply->count].ref_domain_name = a.ref_domain_name, reply->qual[reply->count].
   table_name = a.table_name, reply->qual[reply->count].display_column_name = a.display_column,
   reply->qual[reply->count].cki_column = a.cki_column, reply->qual[reply->count].primary_key_column
    = a.primary_key_column, reply->qual[reply->count].unique_ident_column = a.unique_ident_column,
   reply->qual[reply->count].from_clause = a.from_clause, reply->qual[reply->count].where_clause = a
   .where_clause, reply->qual[reply->count].human_required_ind = a.human_reqd_ind,
   reply->qual[reply->count].source_from_clause = a.source_from_clause, reply->qual[reply->count].
   display_header = a.display_header, reply->qual[reply->count].active_column = a.active_column,
   reply->qual[reply->count].order_by_column = a.order_by_column, reply->qual[reply->count].
   translate_name = a.translate_name, reply->qual[reply->count].code_set = a.code_set
  WITH nocounter, check
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,reply->count)
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
