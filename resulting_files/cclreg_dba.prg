CREATE PROGRAM cclreg:dba
 PROMPT
  "Enter output name: " = "MINE",
  "Summary only (Y/N): " = "Y"
 DECLARE fname = c25
 SET fname = build("cclreg",cnvtint(curtime3))
 CALL echo(fname)
 CASE (cursys)
  OF "AIX":
   SELECT INTO build(fname,".tmp")
    FROM dummyt
    DETAIL
     "cd node", row + 1, "tree",
     row + 1
    WITH nocounter
   ;end select
   SET cmd = concat("$cer_exe/lregview < $CCLUSERDIR/",build(fname,".tmp")," >> $CCLUSERDIR/",build(
     fname,".out"))
   CALL dcl(cmd,size(cmd),0)
  OF "AXP":
   SELECT INTO build(fname,".tmp")
    FROM dummyt
    DETAIL
     "$run cer_exe:lregview", row + 1, "cd node",
     row + 1, "tree", row + 1
    WITH nocounter
   ;end select
   SET cmd = concat("@ccluserdir:",build(fname,".tmp"),"/out=ccluserdir:",build(fname,".out"))
   CALL dcl(cmd,size(cmd),0)
 ENDCASE
 FREE DEFINE rtl
 DEFINE rtl build(fname,".out")
 SELECT INTO  $1
  r.line
  FROM rtlt r
  WHERE r.line IN ("   *\\*   *", "   * = *")
  HEAD REPORT
   buffer = fillstring(80," "), node_name = fillstring(12," "), domain_name = fillstring(20," "),
   server_num = 0, server_num2 = 0, flag = " ",
   mode = 0, num = 0, pos = 0,
   pos2 = 0, col 01, "Node",
   col 15, "Domain", col 35,
   "Server", col 50, "Property",
   row + 1
  DETAIL
   IF (r.line="   *\\Domain *")
    mode = 0
   ENDIF
   IF (r.line="   *\\Bus *"
    AND buffer != "   *\\Startup*")
    node_name = trim(buffer,2), node_name = cnvtupper(substring(2,12,node_name)), mode = 1
   ELSEIF (r.line="   *\\*")
    buffer = r.line
   ENDIF
   IF (mode > 0
    AND r.line IN ("   *\\1???  *", "   *\\2???  *", "   *\\3???  *", "   *\\4???  *",
   "   *\\5???  *",
   "   *\\6???  *", "   *\\7???  *", "   *\\8???  *", "   *\\9???  *"))
    server_num = cnvtint(substring(2,4,trim(r.line,2))), server_num2 = server_num
    WHILE (server_num2 >= 1024)
      server_num2 = mod(server_num2,1024)
    ENDWHILE
    mode = 2
   ENDIF
   IF (mode=2
    AND r.line IN ("   *ServerName =*", "   *ServerParams =*", "   *ServerPath =*",
   "   *NumInstances =*", "   *startup script =*",
   "   *loglevel =*", "   *killtime =*", "   *Paging File Limit =*"))
    IF (server_num >= 1024)
     IF (server_num=0)
      domain_name = " "
     ENDIF
     pos = findstring("ServerParams = ",r.line)
     IF (pos > 0)
      pos2 = findstring(" ",substring((pos+ 15),20,r.line)), domain_name = cnvtupper(substring((pos+
        15),pos2,r.line))
     ENDIF
     flag = " ", pos = findstring("loglevel = ",r.line)
     IF (pos > 0)
      num = cnvtint(substring((pos+ 11),1,r.line))
      IF (num > 0)
       flag = "*"
      ENDIF
     ENDIF
     IF (r.line IN ("*startup script = *test*", "*startup script = *debug*"))
      flag = "*"
     ENDIF
     IF (server_num2 > 0
      AND ((( $2 IN ("N", "n"))) OR (flag="\*")) )
      col 0, flag, col 1,
      node_name, col 15, domain_name,
      col 35, server_num"####;rp0", "(",
      server_num2"####;rp0", ")", col 50,
      CALL print(trim(substring(1,80,r.line),2)), row + 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, maxrow = 1, noformfeed
 ;end select
 FREE DEFINE rtl
 SET stat = remove(build(fname,".tmp"))
 SET stat = remove(build(fname,".out"))
END GO
