CREATE PROGRAM dm_crt_sqns:dba
 SELECT INTO "DM_CREATE_SEQUENCES"
  d.*
  FROM dual d
  DETAIL
   'select into "DM_CREATE_SEQUENCES_OLD"', row + 1, "  us.*",
   row + 1, " from user_sequences us", row + 1,
   " detail", row + 1, '	    "rdb drop sequence ", us.sequence_name, " go", row+1	',
   row + 1, '   col 0, "RDB CREATE SEQUENCE ", us.sequence_name, ', row + 1,
   '          " INCREMENT BY ", us.increment_by, row+1,', row + 1, '          " start with " ',
   row + 1, '          us.last_number "############################.##",', row + 1,
   "          row+1,", row + 1, '          if (us.cycle_flag = "N" and',
   row + 1, "              us.max_value = 10000000000.00)", row + 1,
   '            " NOMAXVALUE ",', row + 1, "            row+1",
   row + 1, "          else", row + 1,
   '            " MAXVALUE ", ', row + 1,
   '            us.max_value "############################.##",',
   row + 1, "            row+1", row + 1,
   "          endif,", row + 1, "          if (us.min_value = NULL)",
   row + 1, '            " NOMINVALUE ", row+1', row + 1,
   "          else", row + 1, '            " MINVALUE " ',
   row + 1, '             us.min_value "############################.##",', row + 1,
   "             row+1", row + 1, "          endif,",
   row + 1, '          if (us.cycle_flag = "N")', row + 1,
   '             " NOCYCLE "', row + 1, "          else",
   row + 1, '             " CYCLE "', row + 1,
   "          endif,", row + 1, "          if (us.cache_size = 0)",
   row + 1, '             " NOCACHE "', row + 1,
   "          else", row + 1, '             " CACHE ", us.cache_size',
   row + 1, "          endif,", row + 1,
   '          if (us.order_flag = "N")', row + 1, '             " NOORDER "',
   row + 1, "          else", row + 1,
   '             " ORDER "', row + 1, "          endif,",
   row + 1, '          " GO "', row + 1,
   "          row + 1", row + 1, "with nocounter, maxcol = 300, noformat, noformfeed go",
   row + 1
  WITH nocounter, maxcol = 300, noformat,
   noformfeed
 ;end select
 SELECT INTO "DM_CREATE_SEQUENCES"
  us.*
  FROM user_sequences us
  DETAIL
   "rdb drop sequence ", us.sequence_name, " go",
   row + 1, col 0, "RDB CREATE SEQUENCE ",
   us.sequence_name, " INCREMENT BY ", us.increment_by,
   row + 1, " start with ", us.last_number"############################.##",
   row + 1
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
   noformfeed, append
 ;end select
END GO
