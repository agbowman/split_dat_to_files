   "CREATE PROGRAM ", g_full_program, row + 1,
   col 5, "PAINT", row + 1,
   col 10, "TEXT(1,20, 'CCL PROGRAM  ", g_full_program,
   "'),", row + 1, col 10,
   "BOX(2,1,10,80),", row + 1, col 10,
   "TEXT(4,5,'Printer/File'),", row + 1, col 10,
   "ACCEPT(4,20,'PPPPPPPPPPPP;CU','MINE')", row + 1
   IF (g_views)
    col 5, "SET VIEWS CHECK", row + 1
   ENDIF
   col 5, "SELECT INTO $1", row + 1
  DETAIL
   num = 1
   WHILE (num <= g_print_max)
    IF ((g_print[num] != " "))
     IF (findstring(".",g_print[num])=0)
      num2 = 1
      WHILE (num2 <= g_expr_max)
       IF ((g_expr_name[num2]=g_print[num]))
        col 10, delim, g_expr_name[num2],
        " = ", g_expr[num2]
       ENDIF
       ,num2 += 1
      ENDWHILE
     ELSE
      col 10, delim, g_print[num]
     ENDIF
     delim = ",", row + 1
    ENDIF
    ,num += 1
   ENDWHILE
   IF (delim=" ")
    col 10, delim, "ITEM = 'NO PRINT ITEMS'",
    row + 1
   ENDIF
   col 10, "FROM  ", delim = " ",
   num = 1
   WHILE (num <= 3)
     num2 = 1
     WHILE (num2 <= 3)
      IF ((g_table[num,num2] != " "))
       delim, g_table[num,num2], delim = ","
      ENDIF
      ,num2 += 1
     ENDWHILE
     num += 1
   ENDWHILE
   row + 1, num = 1
   WHILE (num <= g_qual_cnt)
    IF ((g_qual_from[num] != " "))
     IF (num=1)
      col 10, "WHERE  ", row + 1
     ENDIF
     col 15, g_qual_lpar[num], g_qual_from[num],
     g_qual_op[num], g_qual_to[num], g_qual_rpar[num],
     g_qual_con[num], row + 1
    ENDIF
    ,num += 1
   ENDWHILE
   row + 1, delim = " "
   IF ((g_sort[1] != " "))
    col 10, "ORDER BY  ", row + 1
   ENDIF
   num = 1
   WHILE (num <= g_sort_max)
    IF ((g_sort[num] != " "))
     col 15, delim, g_sort[num],
     row + 1, delim = ","
    ENDIF
    ,num += 1
   ENDWHILE
  FOOT REPORT
   CASE (g_format)
    OF "D":
     col 10,"WITH NOHEADING, FORMAT, CHECK, COUNTER, FORMAT=PCFORMAT ",row + 1
    OF "L":
     col 10,"WITH NOHEADING, FORMAT, CHECK, COUNTER, FORMAT=PCFORMAT ",row + 1
    OF "N":
     col 10,"WITH FORMAT, SEPARATOR = ' ', CHECK, COUNTER",row + 1
   ENDCASE
   IF (g_views)
    col 5, "SET VIEWS NOCHECK", row + 1
   ENDIF
   "END GO"
