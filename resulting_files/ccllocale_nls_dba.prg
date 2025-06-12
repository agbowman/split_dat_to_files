CREATE PROGRAM ccllocale_nls:dba
 PROMPT
  "Select nls keys (S) : " = "S",
  "Table Name (*) : " = "*"
 CASE (cnvtupper( $1))
  OF "S":
   SELECT
    a.table_name, l.attr_name, stat1 = cnvtint(l.stat),
    stat2 = cnvtint(bxor(l.stat,(2** 15)))
    FROM dtableattr a,
     dtableattrl l
    PLAN (a
     WHERE (a.table_name= $2))
     JOIN (l
     WHERE btest(l.stat,15)=1)
    WITH counter
   ;end select
  OF "U":
   IF (logical("CCLNLSUPDATE")="Y")
    UPDATE  FROM dtableattr a,
      dtableattrl l
     SET a.seq = 1, l.stat = bxor(l.stat,(2** 15))
     PLAN (a
      WHERE (a.table_name= $2))
      JOIN (l
      WHERE btest(l.stat,15)=1)
     WITH counter
    ;end update
   ENDIF
 ENDCASE
END GO
