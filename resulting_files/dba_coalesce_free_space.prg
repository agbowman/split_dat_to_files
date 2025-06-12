CREATE PROGRAM dba_coalesce_free_space
 PAINT
 RECORD coalesce_space_req(
   1 database_name = c5
   1 continue = c1
   1 selection = i4
 )
 SET coalesce_space_req->database_name = "     "
 SELECT INTO dummyt
  a.name
  FROM v$database a
  DETAIL
   coalesce_space_req->database_name = a.name
  WITH nocounter
 ;end select
#start
 CALL clear(1,1)
 CALL display_screen(1)
 CALL text(08,05,"Coalesce free space for:")
 CALL text(09,07,"1.  Single Tablespace")
 CALL text(10,07,"2.  Whole Database")
 CALL text(12,07,"3.  View Free Space Coalesced Percentage")
 CALL text(12,60,"Your Selection: ")
 CALL accept(12,76,"9",0)
 SET coalesce_space_req->selection = curaccept
 CASE (coalesce_space_req->selection)
  OF 1:
   CALL coalesce_singlets(1)
  OF 2:
   CALL coalesce_wholedb(1)
  OF 3:
   CALL show_percent_coalesced(1)
  OF 0:
   GO TO endprogram
  ELSE
   CALL text(23,05,"Invalid selection. Continue(Y/N)?")
   CALL accept(23,40,"P;CU","N")
   SET coalesce_space_req->continue = curaccept
   IF ((coalesce_space_req->continue="Y"))
    GO TO start
   ELSE
    GO TO endprogram
   ENDIF
 ENDCASE
 GO TO start
 SUBROUTINE coalesce_singlets(x)
   CALL clear(24,05,74)
   SET t_tablespace = fillstring(30," ")
   SET ts_count = 0
   SET init_loop = 1
   CALL text(15,5,"Tablespace Name: ")
   WHILE (((ts_count=0) OR (init_loop=1)) )
     IF (init_loop=1)
      SET init_loop = 0
     ENDIF
     CALL clear(23,05,74)
     CALL text(23,05,"HELP: Press <SHIFT><F5> ")
     SET help =
     SELECT INTO "nl:"
      a.tablespace_name
      FROM dba_tablespaces a
      WITH nocounter
     ;end select
     CALL accept(15,25,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUS","                              ")
     SET t_tablespace = curaccept
     SELECT INTO "nl:"
      cnt = count(*)
      FROM dba_tablespaces
      WHERE tablespace_name=patstring(t_tablespace)
      DETAIL
       ts_count = cnt
      WITH nocounter, format = stream, noheading,
       formfeed = none, maxrow = 1
     ;end select
     IF (ts_count=0)
      IF (t_tablespace="                              ")
       CALL text(23,05,"tablespace name required...")
      ELSE
       CALL text(23,05,"tablespace not found...")
      ENDIF
     ENDIF
     CALL pause(2)
   ENDWHILE
   CALL exe_sql_statement(nullterm(t_tablespace))
 END ;Subroutine
 SUBROUTINE coalesce_wholedb(x)
   SET total_ts = 0
   SET ts_x = 0
   SET stat = memalloc(ts_array,5,"C30")
   SELECT INTO "nl:"
    a.tablespace_name
    FROM dba_free_space_coalesced a
    WHERE a.percent_blocks_coalesced != 100
    HEAD REPORT
     ts_array_size = 5, ts_array_cnt = 0, xx = initarray(ts_array,"                              ")
    DETAIL
     ts_array_cnt = (ts_array_cnt+ 1)
     IF (ts_array_cnt=ts_array_size)
      ts_array_size = (ts_array_size+ 5), stat = memrealloc(ts_array,ts_array_size,"C30")
     ENDIF
     ts_array[ts_array_cnt] = a.tablespace_name
    FOOT REPORT
     total_ts = ts_array_cnt
    WITH nocounter
   ;end select
   WHILE (ts_x < total_ts)
    SET ts_x = (ts_x+ 1)
    CALL exe_sql_statement(nullterm(ts_array[ts_x]))
   ENDWHILE
 END ;Subroutine
 SUBROUTINE exe_sql_statement(y)
   CALL clear(23,5,74)
   CALL text(23,5,concat("Process tablespace ",nullterm(y),"..."))
   CALL pause(1)
   SET sql_string = fillstring(200," ")
   SET sql_string = concat("rdb alter tablespace ",nullterm(y)," coalesce go")
   CALL parser(sql_string)
   CALL text(23,70,"Complete.")
   CALL pause(1)
 END ;Subroutine
 SUBROUTINE show_percent_coalesced(x)
   SELECT
    tablespace_name, percent_blocks_coalesced
    FROM dba_free_space_coalesced
    ORDER BY percent_blocks_coalesced
   ;end select
 END ;Subroutine
 SUBROUTINE display_screen(x)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,4,80)
   CALL clear(2,2,78)
   CALL text(02,22," ***  DBA  COALESCE FREE  SPACE  *** ")
   CALL clear(3,2,78)
   CALL video(n)
   CALL text(06,05,"DATABASE: ")
   CALL text(06,16,trim(coalesce_space_req->database_name))
 END ;Subroutine
#endprogram
 CALL clear(23,05,74)
 CALL clear(24,05,74)
END GO
