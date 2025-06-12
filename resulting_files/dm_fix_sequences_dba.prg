CREATE PROGRAM dm_fix_sequences:dba
 PAINT
 CALL text(2,1,"***** This program will create a script in the     *****")
 CALL text(3,1,"***** CCLUSERDIR (dm_fix_sequences.dat) that will  *****")
 CALL text(4,1,"***** drop and recreate all sequences, increasing  *****")
 CALL text(5,1,"***** the next value of each NO CYCLE sequence by  *****")
 CALL text(6,1,"***** the input value below.                       *****")
 SET inc_nbr = 0
#display
 CALL text(8,1,"Enter the value to increase the sequences:           ")
 CALL accept(8,45,"9(7)")
 SET inc_nbr = cnvtint(curaccept)
 SELECT INTO "DM_FIX_SEQUENCES"
  *
  FROM user_sequences us
  DETAIL
   "rdb drop sequence ", us.sequence_name, " go",
   row + 1, col 0, "RDB CREATE SEQUENCE ",
   us.sequence_name, " INCREMENT BY ", us.increment_by,
   row + 1, " start with "
   IF (us.cycle_flag="N")
    temp_last_nbr = (us.last_number+ inc_nbr)
   ELSE
    temp_last_nbr = us.last_number
   ENDIF
   temp_last_nbr"############################.##", row + 1
   IF (us.cycle_flag="N"
    AND us.max_value=10000000000.00)
    " NOMAXVALUE ", row + 1
   ELSE
    " MAXVALUE ", us.max_value"############################.##", row + 1
   ENDIF
   IF (us.min_value=null)
    " NOMINVALUE ", row + 1
   ELSE
    " MINVALUE ", us.min_value"############################.##", row + 1
   ENDIF
   IF (us.cycle_flag="N")
    " NOCYCLE "
   ELSE
    " CYCLE "
   ENDIF
   IF (us.cache_size=0)
    " NOCACHE "
   ELSE
    " CACHE ", us.cache_size
   ENDIF
   IF (us.order_flag="N")
    " NOORDER "
   ELSE
    " ORDER "
   ENDIF
   " GO ", row + 1
  WITH nocounter, maxcol = 300, noformat,
   noformfeed
 ;end select
#end_program
END GO
