CREATE PROGRAM dm_get_col_doc:dba
 RECORD reply(
   1 qual[*]
     2 column_name = c30
     2 constant_value = vc
     2 exception_flg = i4
     2 merge_updateable_ind = i2
     2 parent_entity_col = c30
     2 root_entity_attr = c30
     2 root_entity_name = c30
     2 sequence_name = c30
     2 table_name = c30
     2 unique_ident_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.*
  FROM dm_tables_doc dtd,
   dm_columns_doc a,
   user_tab_columns b
  WHERE a.table_name=b.table_name
   AND a.column_name=b.column_name
   AND a.table_name=dtd.table_name
   AND ((dtd.reference_ind=1) OR (dtd.table_name IN ("ACCESSION", "PERSON", "PRSNL", "LONG_TEXT",
  "LONG_BLOB",
  "ADDRESS", "PHONE")))
  ORDER BY a.table_name
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].column_name = a.column_name, reply->qual[cnt].constant_value = a.constant_value,
   reply->qual[cnt].exception_flg = a.exception_flg,
   reply->qual[cnt].merge_updateable_ind = a.merge_updateable_ind, reply->qual[cnt].parent_entity_col
    = a.parent_entity_col, reply->qual[cnt].root_entity_attr = a.root_entity_attr,
   reply->qual[cnt].root_entity_name = a.root_entity_name, reply->qual[cnt].sequence_name = a
   .sequence_name, reply->qual[cnt].table_name = a.table_name,
   reply->qual[cnt].unique_ident_ind = a.unique_ident_ind
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
