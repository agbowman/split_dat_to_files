CREATE PROGRAM cclsqlarea3:dba
 PROMPT
  "Enter output name                (MINE)  : " = "MINE",
  "Summary or Detail (S/D) : " = "S"
 CASE (cnvtupper( $2))
  OF "S":
   SELECT
    kglhdpar = cnvtrawhex(a.kglhdpar), b.sql_text, count(*)
    FROM v$sql_shared_cursor a,
     v$sqltext b
    WHERE a.bind_mismatch="Y"
     AND b.address=a.kglhdpar
     AND b.piece=0
    GROUP BY a.kglhdpar, b.sql_text
    HAVING count(*) > 1
    ORDER BY 3
    WITH nocounter
   ;end select
  OF "D":
   SELECT
    kglhdpar = cnvtrawhex(a.kglhdpar), address = cnvtrawhex(a.address), b.sql_text,
    a.bind_mismatch, c.position, c.datatype,
    c.max_length, c.bind_name
    FROM v$sql_shared_cursor a,
     v$sqltext b,
     v$sql_bind_metadata c
    WHERE a.bind_mismatch="Y"
     AND b.address=a.kglhdpar
     AND b.piece=0
     AND a.address=c.address
    ORDER BY a.kglhdpar, a.address, c.position
    WITH nocounter
   ;end select
 ENDCASE
END GO
