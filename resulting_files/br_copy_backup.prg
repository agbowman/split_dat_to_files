CREATE PROGRAM br_copy_backup
 PROMPT
  "Enter table you are copying data from: ",
  "Enter table you are copying data to: "
 DECLARE copy_table_data(from_tbl=vc,to_tbl=vc) = null
 CALL copy_table_data(cnvtupper( $1),cnvtupper( $2))
 SUBROUTINE copy_table_data(from_tbl,to_tbl)
   DECLARE err = i4
   DECLARE errmsg = vc
   SELECT INTO "nl:"
    FROM user_tables ut
    WHERE ((ut.table_name=cnvtupper(from_tbl)) OR (ut.table_name=cnvtupper(to_tbl)))
    WITH nocounter
   ;end select
   IF (curqual=2)
    DECLARE pk_col = vc
    DECLARE pk_where = vc
    SELECT INTO "nl:"
     FROM user_constraints uc,
      user_cons_columns ucc
     WHERE uc.table_name=cnvtupper(to_tbl)
      AND uc.constraint_type="P"
      AND ucc.table_name=uc.table_name
      AND ucc.constraint_name=uc.constraint_name
      AND ucc.position=1
     DETAIL
      pk_col = ucc.column_name
     WITH nocounter
    ;end select
    IF (curqual)
     SET pk_where = concat(pk_col," > 0")
    ELSE
     SET pk_where = " 1 = 1"
    ENDIF
    CALL parser(concat("delete from ",to_tbl))
    CALL parser(concat(" where ",pk_where))
    CALL parser(" go")
    CALL parser(concat("rdb insert into ",to_tbl))
    CALL parser(concat(" (select * from ",from_tbl))
    CALL parser(concat("  where ",pk_where,")"))
    CALL parser(" go")
    SET err = error(errmsg,1)
    IF (err=0)
     COMMIT
     CALL echo(concat("SUCCESS copy from ",from_tbl," to ",to_tbl," (",
       trim(cnvtstring(curqual))," rows)"))
    ELSE
     ROLLBACK
     CALL echo(concat("FAILURE copy data from ",from_tbl," to ",to_tbl))
     CALL echo(concat("  ERROR ",errmsg))
    ENDIF
   ELSE
    ROLLBACK
    CALL echo(concat("FAILURE tables not found: ",from_tbl," or ",to_tbl))
   ENDIF
 END ;Subroutine
END GO
