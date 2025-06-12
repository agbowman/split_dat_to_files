CREATE PROGRAM cpmprocess:dba
 PAINT
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"Process Servers Audits")
 CALL video(n)
 CALL text(5,5,"1. Process Server Errors ")
 CALL text(6,5,"2. Process Server Configuration ")
 CALL text(15,10,"Select  (0 to Exit)")
 CALL accept(15,5,"9")
 CASE (curaccept)
  OF 0:
   GO TO end_program
  OF 1:
   EXECUTE cpmprocess_audit
  OF 2:
   SELECT
    *
    FROM request_processing
    WHERE active_ind=1
    ORDER BY request_number
   ;end select
 ENDCASE
 GO TO start
#end_program
END GO
