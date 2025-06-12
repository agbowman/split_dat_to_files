   row + 1, "CREATE PROGRAM ", p1,
   row + 1, " PAINT", row + 1,
   " SET MODIFY SYSTEM", row + 1, " FREE DEFINE ",
   t.file_name, row + 1, " DEFINE ",
   t.file_name, " WITH MODIFY", row + 1,
   "#REPEAT", row + 1, " SET LAST_SCREEN = 0",
   row + 1, " SET SCREEN_NO = 1", row + 1,
   "#SCREEN_01", row + 1, " CALL CLEAR(1,1)",
   row + 1, " CALL VIDEO(R)", row + 1,
   " CALL CLEAR(1,1,80)", row + 1, " CALL BOX(2,1,23,80)",
   row + 1, " CALL TEXT(01,2, ^CCLFORMS TABLE^,WIDE)", row + 1,
   " CALL TEXT(01,17, ^", p2, "^,WIDE)",
   row + 1, " CALL TEXT(01,32, 'SCREEN ',WIDE)", row + 1,
   " CALL TEXT(01,39, FORMAT(SCREEN_NO,'##;RP0'),WIDE)", row + 1, " CALL VIDEO(N)",
   row + 1, " SET CNT = 1", row + 1,
   " WHILE (CNT <= 20)", row + 1, "    CALL TEXT(CNT+2,2,CNVTSTRING(CNT,2,0,R))",
   row + 1, "    SET CNT = CNT+1", row + 1,
   " ENDWHILE", row + 1, " SET HOME = HOME_LABEL",
   row + 1, trow = 3, tcol = 1,
   comma = ",", accept[40] = fillstring(100," "), accept_num = 0,
   anum = 0, pnum = 0, xnum = 0,
   gnum = 0, last_label = 0, cur_label = 0,
   cur_table = 0
  HEAD a.table_name
   cur_table += 1, " RANGE OF X", cur_table"#",
   " IS ", a.table_name, row + 1
  DETAIL
   gnum += 1
   IF (trow > 21)
    row + 1, anum = 1
    WHILE (anum <= accept_num)
      xnum += 1, cur_label = (cnvtint(substring(8,2,accept[anum])) - 2)
      IF ((accept[anum] != "UPDT_*"))
       IF (cur_label != last_label)
        "#L", p_xlabel"###;RP0", "_",
        cur_label"##;RP0", row + 1, last_label = cur_label
       ENDIF
       " CALL ", accept[anum], row + 1,
       anum += 1, pnum += 1, "      SET P",
       pnum"###;L", " = CURACCEPT", row + 1
      ELSE
       "! UPDATE FIELD SUPPRESSED"
      ENDIF
    ENDWHILE
    last_label = 0, trow = 3, accept_num = 0,
    p_xlabel += 1, " GO TO HOME_LABEL ", row + 1,
    " SET SCREEN_NO = SCREEN_NO+1", row + 1, "#SCREEN_",
    p_xlabel"##;RP0", row + 1, " CALL CLEAR(1,1)",
    row + 1, " CALL VIDEO(R)", row + 1,
    " CALL CLEAR(1,1,80)", row + 1, " CALL BOX(2,1,23,80)",
    row + 1, " CALL TEXT(01,2, ^CCLFORMS TABLE^,WIDE)", row + 1,
    " CALL TEXT(01,17, ^", p2, "^,WIDE)",
    row + 1, " CALL TEXT(01,32, 'SCREEN ',WIDE)", row + 1,
    " CALL TEXT(01,39, FORMAT(SCREEN_NO,'##;RP0'),WIDE)", row + 1, " CALL VIDEO(N)",
    row + 1, " SET CNT = 1", row + 1,
    " WHILE (CNT <= 20)", row + 1, "    CALL TEXT(CNT+2,2,CNVTSTRING(CNT,2,0,R))",
    row + 1, "    SET CNT = CNT+1", row + 1,
    " ENDWHILE", row + 1
   ENDIF
   accept_num += 1, accept[accept_num] = fillstring(100," ")
   IF ((accept[accept_num] != "UPDT_*"))
    IF (l.type="C")
     " SET P", gnum"####;L", " = FILLSTRING(",
     l.len, ", ' ') ", row + 1,
     accept[accept_num] = build("ACCEPT(00,00, X",cur_table,".",l.attr_name,", P",
      gnum,")")
    ELSE
     " SET P", gnum"####;L", " = 0",
     row + 1, accept[accept_num] = build("ACCEPT(00,00, X",cur_table,".",l.attr_name,", P",
      gnum,")")
    ENDIF
    IF (tcol=1)
     pos = movestring(concat(cnvtstring(trow,2,0,"R"),",33"),1,accept[accept_num],8,5), " CALL TEXT(",
     trow"##;RP0",
     ",05, ", aname, tcol = 2
     IF (((l.len >= 10) OR (l.type="I"
      AND l.len >= 4)) )
      tcol = 1, trow += 1
     ENDIF
    ELSEIF (l.len >= 10)
     pos = movestring(concat(cnvtstring((trow+ 1),2,0,"R"),",33"),1,accept[accept_num],8,5), trow +=
     1, " CALL TEXT(",
     trow"##;RP0", ",05, ", aname,
     trow += 1, tcol = 1
    ELSE
     pos = movestring(concat(cnvtstring(trow,2,0,"R"),",68"),1,accept[accept_num],8,5), " CALL TEXT(",
     trow"##;RP0",
     ",43, ", aname, trow += 1,
     tcol = 1
    ENDIF
    row + 1
   ENDIF
  FOOT REPORT
   row + 1, anum = 1
   WHILE (anum <= accept_num)
     xnum += 1, cur_label = (cnvtint(substring(8,2,accept[anum])) - 2)
     IF (cur_label != last_label)
      "#L", p_xlabel"###;RP0", "_",
      cur_label"##;RP0", row + 1, last_label = cur_label
     ENDIF
     " CALL ", accept[anum], row + 1,
     anum += 1, pnum += 1, "      SET P",
     pnum"###;L", " = CURACCEPT", row + 1
   ENDWHILE
  WITH nocounter, maxcol = 110, maxrow = 10,
   format = variable, noformfeed
 ;end select
 CALL text(07,05,concat("QUAL1: ",cnvtstring(curqual)))
 SELECT INTO concat(trim(p1),".PRG")
  t.file_name, a.table_name, l.type,
  l.len, l.attr_name, a.table_name
  FROM dtableattr a,
   dtableattrl l,
   dtable t
  WHERE t.table_name=patstring(p2)
   AND l.structtype="F"
   AND t.table_name=a.table_name
   AND l.len < 100
  HEAD REPORT
   " SET LAST_SCREEN = SCREEN_NO", row + 1, "#HOME_LABEL",
   row + 1, " SET ACCEPT = NOCHANGE", row + 1,
   " CALL CLEAR(24,1)", row + 1, " SET CHANGE = 1",
   row + 1, " CALL TEXT(24,1,^Correct? (y/n)^)", row + 1,
   " CALL ACCEPT(24,18,^A;CU^)", row + 1, " IF (CURACCEPT = ^Y^)",
   row + 1, "   IF (LAST_SCREEN = 0) ", row + 1,
   "      GO TO (SCREEN_02, SCREEN_03, SCREEN_04, SCREEN_05) SCREEN_NO", row + 1, "   ENDIF",
   row + 1, " ELSE", row + 1,
   "      CALL TEXT(24,1,^Line Number         ^)", row + 1,
   "      CALL ACCEPT(24,20,^99^  WHERE CURACCEPT BETWEEN 1 AND 20)",
   row + 1, "      SET ACCEPT = NOCHANGE", row + 1,
   "      CASE (SCREEN_NO)", row + 1, xnum = 1
   WHILE (xnum <= p_xlabel)
     "   OF ", xnum, ":  GO TO (",
     row + 1, "             L", xnum"###;RP0",
     "_01,", "             L", xnum"###;RP0",
     "_02,", row + 1, "             L",
     xnum"###;RP0", "_03,", "             L",
     xnum"###;RP0", "_04,", row + 1,
     "             L", xnum"###;RP0", "_05,",
     "             L", xnum"###;RP0", "_06,",
     row + 1, "             L", xnum"###;RP0",
     "_07,", "             L", xnum"###;RP0",
     "_08,", row + 1, "             L",
     xnum"###;RP0", "_09,", "             L",
     xnum"###;RP0", "_10,", row + 1,
     "             L", xnum"###;RP0", "_11,",
     "             L", xnum"###;RP0", "_12,",
     row + 1, "             L", xnum"###;RP0",
     "_13,", "             L", xnum"###;RP0",
     "_14,", row + 1, "             L",
     xnum"###;RP0", "_15,", "             L",
     xnum"###;RP0", "_16,", row + 1,
     "             L", xnum"###;RP0", "_17,",
     "             L", xnum"###;RP0", "_18,",
     row + 1, "             L", xnum"###;RP0",
     "_19,", "             L", xnum"###;RP0",
     "_20) CURACCEPT", row + 1, xnum += 1
   ENDWHILE
   "      ENDCASE", row + 1, " ENDIF",
   row + 1, " INSERT   SET ", row + 1,
   num = 1, comma = " ", cur_table = 0
  HEAD a.table_name
   cur_table += 1
  DETAIL
   IF (l.attr_name != "UPDT_*")
    col + 1, comma, "X",
    cur_table"#", ".", l.attr_name,
    "= P", num"###;L", num += 1,
    row + 1, comma = ","
   ENDIF
  FOOT REPORT
   row + 1, col + 1, comma,
   "X", cur_table"#", ".",
   "UPDT_DT_TM = CNVTDATETIME(CURDATE, CURTIME3)", row + 1, col + 1,
   comma, "X", cur_table"#",
   ".", "UPDT_CNT = 0", row + 1,
   " WITH NOCOUNTER ", row + 1, " CALL CLEAR(24,1)",
   row + 1, " CALL TEXT(24,40,'INSERT ')", row + 1,
   " CALL TEXT(24,50,FORMAT(CURQUAL,'#'))", row + 1, " CALL TEXT(24,1,'COMMIT (Y/N)')",
   row + 1, " CALL ACCEPT(24,25,'A;CU','Y')", row + 1,
   " IF (CURACCEPT = ^Y^) COMMIT ELSE ROLLBACK ENDIF", row + 1,
   " CALL TEXT(24,1,'REPEAT PROGRAM (Y/N)')",
   row + 1, " CALL ACCEPT(24,25,'A;CU','Y')", row + 1,
   " IF (CURACCEPT = ^Y^) GO TO REPEAT ENDIF", row + 1, " CALL CLEAR(1,1)",
   row + 1, " SET ACCEPT = NOCHANGE", row + 1,
   "END GO", row + 1
