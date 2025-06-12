CREATE PROGRAM dm_make_csv_coldoc:dba
 SET file1_str = "ccluserdir:dmrcoldoc.csv"
 SET logical file1 "ccluserdir:dmrcoldoc.csv"
 DECLARE type_ind = i2
 SET type_ind = 1
 IF (validate(i_type_ind,0)=0
  AND validate(i_type_ind,1)=1)
  SET type_ind = 1
 ELSE
  SET type_ind = i_type_ind
 ENDIF
 IF (type_ind=0)
  SELECT INTO file1
   d.table_name, d.column_name, d.sequence_name,
   d.code_set, d.unique_ident_ind, d.root_entity_name,
   d.root_entity_attr, d.parent_entity_col, d.exception_flg,
   d.constant_value
   FROM dm_columns_doc d,
    dm_tables_doc d1
   WHERE d.table_name=d1.table_name
    AND d1.reference_ind=1
   ORDER BY d.table_name, d.column_name
   WITH format = pcformat, check
  ;end select
 ELSE
  FREE RECORD rec_str
  RECORD rec_str(
    1 str = vc
  )
  DECLARE cnt = i4
  SELECT INTO file1
   d.*
   FROM dm_columns_doc d,
    dm_tables_doc d1
   WHERE d.table_name=d1.table_name
    AND d1.reference_ind=1
   ORDER BY d.table_name, d.column_name
   HEAD REPORT
    comma_str = ",", col 0, row 0,
    '"TABLE_NAME","COLUMN_NAME","SEQUENCE_NAME","ROOT_ENTITY_NAME","ROOT_ENTITY_ATTR"',
    ',"PARENT_ENTITY_COL","CONSTANT_VALUE","CODE_SET","UNIQUE_IDENT_IND","EXCEPTION_FLG"', cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,500)=1)
     IF (curenv=0)
      CALL echo(concat("Processing row ",build(cnt)),1,0)
     ENDIF
    ENDIF
    comma_str = " ", quote_str = '"', rec_str->str = "",
    CALL subr_out(d.table_name),
    CALL subr_out(d.column_name),
    CALL subr_out(d.sequence_name),
    CALL subr_out(d.root_entity_name),
    CALL subr_out(d.root_entity_attr),
    CALL subr_out(d.parent_entity_col),
    CALL subr_out(d.constant_value), quote_str = " ",
    CALL subr_out(build(d.code_set)),
    CALL subr_out(build(d.unique_ident_ind)),
    CALL subr_out(build(d.exception_flg)), row + 1,
    col 0, rec_str->str,
    SUBROUTINE subr_out(p_data)
     rec_str->str = concat(trim(rec_str->str),trim(comma_str),trim(quote_str),build(p_data),trim(
       quote_str)),comma_str = ","
    END ;Subroutine report
   WITH nocounter, check, format = variable,
    formfeed = none, maxcol = 30000, maxrow = 1
  ;end select
 ENDIF
 IF (findfile(file1_str))
  CALL echo(concat("File created: '",file1_str,"'"))
 ENDIF
END GO
