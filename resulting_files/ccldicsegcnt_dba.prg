CREATE PROGRAM ccldicsegcnt:dba
 PROMPT
  "Enter MINE/CRT/printer/file: " = "MINE"
 DECLARE cnt[9] = i4
 DECLARE name[9] = c12 WITH constant("DFILE","DRECTYPE","DTABLE","DTABLEATTR","DPROTECT",
  "DUAF","DTAM","DGEN","DCOMPILE")
 FOR (num = 1 TO 9)
   CALL echo("=======================================================")
   CALL echo(build("collecting for segment:",num," of 9"))
   CALL echo("=======================================================")
   SET cnt[num] = 0
   SELECT INTO nl
    FROM (dgeneric d  WITH access_code = value(num))
    DETAIL
     cnt[num] += 1
    WITH counter
   ;end select
 ENDFOR
 SET tot = 0
 SELECT INTO  $1
  FROM dummyt
  HEAD REPORT
   "CCLDICSEGCNT report showing count of each segment in dictionary", row + 1
  DETAIL
   FOR (num = 1 TO 9)
     tot += cnt[num]
   ENDFOR
   FOR (num = 1 TO 9)
     dper = ((cnvtreal(cnt[num])/ tot) * 100), num"#", ")",
     name[num], col 15, ":",
     cnt[num]";l", col 40, dper"##.#",
     "%", row + 1
   ENDFOR
   "=======================================================", row + 1, "  Total",
   col 15, ":", tot";l"
  WITH nocounter
 ;end select
END GO
