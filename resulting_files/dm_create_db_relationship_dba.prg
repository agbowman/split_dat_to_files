CREATE PROGRAM dm_create_db_relationship:dba
 SET req_tbl = trim(request->tbl_name)
 SET req_owner = trim(request->owner)
 FREE SET request
 RECORD request(
   1 action_type = c3
   1 owner = c30
   1 table_name = c30
   1 relationship_name = c30
   1 relationship_description = c100
   1 relationship_seq_qual = i4
   1 relationship_seq[*]
     2 column_name = c30
     2 foreign_column_name = c30
     2 foreign_table_name = c30
     2 foreign_owner = c30
 )
 SET temp_table = fillstring(30," ")
 SET temp_col = fillstring(30," ")
 SET temp_name = fillstring(30," ")
 FREE SET relation
 RECORD relation(
   1 tbls[*]
     2 pcol = c30
     2 ctable = c30
     2 ccol = c30
 )
 SET request->action_type = "ADD"
 SET request->owner = req_owner
 SET request->table_name = req_tbl
 SET dm_count = 0
 SELECT INTO "nl:"
  dpc.child_table, dpc.child_col_name, dpc.parent_col_name
  FROM dm_parent_child dpc
  WHERE dpc.parent_table=req_tbl
  DETAIL
   dm_count = (dm_count+ 1), stat = alterlist(relation->tbls,dm_count), relation->tbls[dm_count].pcol
    = dpc.parent_col_name,
   relation->tbls[dm_count].ctable = dpc.child_table, relation->tbls[dm_count].ccol = dpc
   .child_col_name
  WITH nocounter
 ;end select
 SET temp_qual = 1
 SET x = 1
 FOR (x = 1 TO dm_count)
   SET temp_table = relation->tbls[x].ctable
   SET stat = alterlist(request->relationship_seq,temp_qual)
   SET temp_name = concat(trim(relation->tbls[x].ctable)," Default")
   SET request->relationship_name = trim(temp_name)
   SET request->relationship_description = concat(trim(req_tbl),concat(":",concat(trim(temp_table),
      " description")))
   SET request->relationship_seq[temp_qual].column_name = relation->tbls[x].pcol
   SET request->relationship_seq[temp_qual].foreign_table_name = relation->tbls[x].ctable
   SET request->relationship_seq[temp_qual].foreign_column_name = relation->tbls[x].ccol
   SET request->relationship_seq[temp_qual].foreign_owner = req_owner
   SET yme = 1
   FOR (yme = 1 TO (x - 1))
     IF ((relation->tbls[yme].ctable=temp_table))
      SET temp_qual = (temp_qual+ 1)
      SET stat = alterlist(request->relationship_seq,temp_qual)
      SET request->relationship_seq[temp_qual].column_name = relation->tbls[yme].pcol
      SET request->relationship_seq[temp_qual].foreign_table_name = relation->tbls[yme].ctable
      SET request->relationship_seq[temp_qual].foreign_column_name = relation->tbls[yme].ccol
      SET request->relationship_seq[temp_qual].foreign_owner = req_owner
     ENDIF
   ENDFOR
   FOR (yme = (x+ 1) TO dm_count)
     IF ((relation->tbls[yme].ctable=temp_table))
      SET temp_qual = (temp_qual+ 1)
      SET stat = alterlist(request->relationship_seq,temp_qual)
      SET request->relationship_seq[temp_qual].column_name = relation->tbls[yme].pcol
      SET request->relationship_seq[temp_qual].foreign_table_name = relation->tbls[yme].ctable
      SET request->relationship_seq[temp_qual].foreign_column_name = relation->tbls[yme].ccol
      SET request->relationship_seq[temp_qual].foreign_owner = req_owner
     ENDIF
   ENDFOR
   SET request->relationship_seq_qual = temp_qual
   EXECUTE assist_ens_relationship
 ENDFOR
 FREE SET relation
 RECORD relation(
   1 tbls[*]
     2 pcol = c30
     2 ptable = c30
     2 ccol = c30
 )
 SET dm_count = 0
 SELECT INTO "nl:"
  dpc.parent_table, dpc.parent_col_name, dpc.child_col_name
  FROM dm_parent_child dpc
  WHERE dpc.child_table=req_tbl
  ORDER BY dpc.parent_table
  DETAIL
   dm_count = (dm_count+ 1), stat = alterlist(relation->tbls,dm_count), relation->tbls[dm_count].pcol
    = dpc.parent_col_name,
   relation->tbls[dm_count].ptable = dpc.parent_table, relation->tbls[dm_count].ccol = dpc
   .child_col_name
  WITH nocounter
 ;end select
 SET temp_qual = 1
 SET x = 1
 FOR (x = 1 TO dm_count)
   SET temp_table = relation->tbls[x].ptable
   SET stat = alterlist(request->relationship_seq,temp_qual)
   SET temp_name = concat(trim(relation->tbls[x].ptable)," Default")
   SET request->relationship_name = trim(temp_name)
   SET request->relationship_description = concat(trim(req_tbl),concat(":",concat(trim(temp_table),
      " description")))
   SET request->relationship_seq[temp_qual].column_name = relation->tbls[x].ccol
   SET request->relationship_seq[temp_qual].foreign_table_name = relation->tbls[x].ptable
   SET request->relationship_seq[temp_qual].foreign_column_name = relation->tbls[x].pcol
   SET request->relationship_seq[temp_qual].foreign_owner = req_owner
   IF (dm_count > 1)
    FOR (yme = (x+ 1) TO dm_count)
      IF ((relation->tbls[yme].ptable=temp_table))
       SET x = (x+ 1)
       SET temp_qual = (temp_qual+ 1)
       SET stat = alterlist(request->relationship_seq,temp_qual)
       SET request->relationship_seq[temp_qual].column_name = relation->tbls[yme].ccol
       SET request->relationship_seq[temp_qual].foreign_table_name = relation->tbls[yme].ptable
       SET request->relationship_seq[temp_qual].foreign_column_name = relation->tbls[yme].pcol
       SET request->relationship_seq[temp_qual].foreign_owner = req_owner
      ENDIF
    ENDFOR
   ENDIF
   SET request->relationship_seq_qual = temp_qual
   RECORD reply(
     1 owner = c30
     1 table_name = c30
     1 relationship_name = c30
     1 relationship_description = c100
     1 relationship_seq_qual = i4
     1 relationship_seq[10]
       2 column_name = c30
       2 foreign_column_name = c30
       2 foreign_table_name = c30
       2 foreign_owner = c30
       2 success_ind = i4
     1 status_data
       2 status = c1
       2 subeventstatus[2]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   EXECUTE assist_ens_relationship
   COMMIT
 ENDFOR
 COMMIT
END GO
