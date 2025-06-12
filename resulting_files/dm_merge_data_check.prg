CREATE PROGRAM dm_merge_data_check
 FREE SET dm_uniques
 RECORD dm_uniques(
   1 table_count = i4
   1 list[*]
     2 table_name = vc
     2 table_owner = vc
     2 data_model_section = vc
     2 ui_column_count = i4
     2 ui_index_found = i4
     2 ui_index_name = vc
 )
 CALL echo(
  "the following output contains the list of reference tables the do not have a unique index on")
 CALL echo("unique identifier columns")
 SELECT INTO "nl:"
  a.table_name, b.column_name, a.data_model_section,
  c.owner_name
  FROM dm_data_model_section c,
   dm_tables_doc a,
   dm_columns_doc b,
   dm_tables dt,
   dm_columns dc
  WHERE a.reference_ind=1
   AND b.unique_ident_ind=1
   AND c.data_model_section=a.data_model_section
   AND a.table_name=b.table_name
   AND dt.schema_date=cnvtdatetime( $1)
   AND dt.table_name=a.table_name
   AND dt.table_name=dc.table_name
   AND dt.schema_date=dc.schema_date
   AND dc.column_name=b.column_name
  ORDER BY a.table_name, b.column_name
  HEAD a.table_name
   dm_uniques->table_count = (dm_uniques->table_count+ 1)
   IF (mod(dm_uniques->table_count,10)=1)
    stat = alterlist(dm_uniques->list,(dm_uniques->table_count+ 9))
   ENDIF
   dm_uniques->list[dm_uniques->table_count].table_name = a.table_name, dm_uniques->list[dm_uniques->
   table_count].data_model_section = a.data_model_section, dm_uniques->list[dm_uniques->table_count].
   table_owner = c.owner_name
  DETAIL
   dm_uniques->list[dm_uniques->table_count].ui_column_count = (dm_uniques->list[dm_uniques->
   table_count].ui_column_count+ 1)
  WITH nocounter
 ;end select
 FREE SET dm_indexes
 RECORD dm_indexes(
   1 index_count = i4
   1 list[*]
     2 table_name = vc
     2 index_name = vc
     2 index_column_count = i4
 )
 SELECT INTO "nl:"
  a.table_name, a.index_name, y = count(*)
  FROM dm_index_columns b,
   dm_tables_doc c,
   dm_indexes a
  WHERE a.table_name=c.table_name
   AND b.table_name=a.table_name
   AND b.index_name=a.index_name
   AND b.schema_date=a.schema_date
   AND c.reference_ind=1
   AND a.schema_date=cnvtdatetime( $1)
   AND a.unique_ind=1
  GROUP BY a.table_name, a.index_name
  ORDER BY a.table_name, a.index_name
  DETAIL
   dm_indexes->index_count = (dm_indexes->index_count+ 1)
   IF (mod(dm_indexes->index_count,10)=1)
    stat = alterlist(dm_indexes->list,(dm_indexes->index_count+ 9))
   ENDIF
   dm_indexes->list[dm_indexes->index_count].table_name = a.table_name, dm_indexes->list[dm_indexes->
   index_count].index_name = a.index_name, dm_indexes->list[dm_indexes->index_count].
   index_column_count = y
  WITH nocounter
 ;end select
 FOR (i = 1 TO dm_uniques->table_count)
   FOR (j = 1 TO dm_indexes->index_count)
     IF ((dm_indexes->list[j].index_column_count=dm_uniques->list[i].ui_column_count)
      AND (dm_indexes->list[j].table_name=dm_uniques->list[i].table_name))
      SELECT INTO "nl:"
       y = count(*)
       FROM dm_index_columns b,
        dm_columns_doc c
       WHERE (b.table_name=dm_indexes->list[j].table_name)
        AND b.table_name=c.table_name
        AND b.column_name=c.column_name
        AND (b.index_name=dm_indexes->list[j].index_name)
        AND b.schema_date=cnvtdatetime( $1)
        AND c.unique_ident_ind=1
       DETAIL
        IF ((y=dm_indexes->list[j].index_column_count))
         dm_uniques->list[i].ui_index_found = 1, dm_uniques->list[i].ui_index_name = dm_indexes->
         list[j].index_name
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 ENDFOR
 SELECT
  *
  FROM dual
  DETAIL
   "table_name", col 40, "table_owner",
   col 80, "data_model_section", row + 1
   FOR (i = 1 TO dm_uniques->table_count)
     IF ((dm_uniques->list[i].ui_index_found=0))
      dm_uniques->list[i].table_name, col 40, dm_uniques->list[i].table_owner,
      col 80, dm_uniques->list[i].data_model_section, row + 1
     ENDIF
   ENDFOR
  WITH nocounter, maxcol = 255
 ;end select
 CALL echo("these reference tables do not have a unique identifier defined")
 SELECT
  a.table_name, a.data_model_section, c.owner_name
  FROM dm_tables_doc a,
   dm_data_model_section c,
   dm_tables d
  WHERE a.reference_ind=1
   AND a.table_name=d.table_name
   AND d.schema_date=cnvtdatetime( $1)
   AND a.data_model_section=c.data_model_section
   AND  NOT ( EXISTS (
  (SELECT
   "x"
   FROM dm_columns_doc b
   WHERE a.table_name=b.table_name
    AND b.unique_ident_ind=1)))
  ORDER BY a.data_model_section, a.table_name
 ;end select
 CALL echo("these code sets do not have dup indicators set")
 SELECT
  a.code_set, a.description, c.owner_name
  FROM dm_code_value_set a,
   dm_code_set b,
   dm_owner c
  WHERE a.code_set=b.code_set
   AND a.schema_date=cnvtdatetime( $1)
   AND b.owner_name=c.owner_email
   AND ((a.display_dup_ind=0
   AND a.display_key_dup_ind=0
   AND a.cdf_meaning_dup_ind=0
   AND a.active_ind_dup_ind=0) OR (a.display_dup_ind=1
   AND a.display_key_dup_ind=1
   AND a.cdf_meaning_dup_ind=1
   AND a.active_ind_dup_ind=1))
  ORDER BY c.owner_name, a.code_set
 ;end select
END GO
