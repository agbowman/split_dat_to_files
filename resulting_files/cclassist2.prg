CREATE PROGRAM cclassist2
 SET home = xscroll_home
 SET maxitem = 1000
 SET xscroll_cnt = 0
 SET xscroll_info[1000] = fillstring(55," ")
 SET xscroll_pick = 0
 SELECT INTO "NL:"
  tname = dica.table_name, field = concat(trim(dica.table_name),".",dicl.attr_name), ftype = concat(
   "=",dicl.type,cnvtstring(dicl.len,4))
  WHERE dica.table_name IN (g_table[1,1], g_table[2,1], g_table[3,1], g_table[1,2], g_table[2,2],
  g_table[3,2], g_table[1,3], g_table[2,3], g_table[3,3])
   AND dicl.structtype="F"
   AND btest(dicl.stat,11)=0
   AND btest(dicl.stat,10)=0
  HEAD tname
   IF (g_print_sort != 2
    AND xscroll_cnt=0)
    xscroll_cnt += 1, xscroll_info[xscroll_cnt] = concat(cnvtstring(xscroll_cnt,4)," ",trim(tname),
     ".*")
   ENDIF
  DETAIL
   IF (xscroll_cnt < maxitem)
    xscroll_cnt += 1, xscroll_info[xscroll_cnt] = concat(cnvtstring(xscroll_cnt,4)," ",field,ftype)
   ENDIF
  WITH nocounter
 ;end select
 SET g_num = 0
 WHILE (g_num < g_expr_max)
  SET g_num += 1
  IF ((g_expr_name[g_num] != " "))
   SET xscroll_cnt += 1
   SET xscroll_info[xscroll_cnt] = concat(cnvtstring(xscroll_cnt,4)," ",g_expr_name)
  ENDIF
 ENDWHILE
 SET g_num = 0
 SET xscroll_pick = 0
 SET maxcnt = xscroll_cnt
 SET xscroll_cnt = 0
 IF (g_width=80)
  SET srowoff = 03
  SET scoloff = 20
  SET numsrow = 07
  SET numscol = 55
 ELSE
  SET srowoff = 02
  SET scoloff = 75
  SET numsrow = 20
  SET numscol = 55
 ENDIF
 FOR (irow = (srowoff+ 1) TO (srowoff+ numsrow))
   CALL clear(irow,scoloff,(numscol+ 1))
 ENDFOR
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL text(24,1,"Select         F8=End   F9=Prev   F10=Next   F11=ERASE")
 IF (g_print_sort=1)
  SET xscroll_max = g_print_max
  CALL text(srowoff,(scoloff+ 8),"SCROLL PRINT FIELDS")
 ELSE
  SET xscroll_max = g_sort_max
  CALL text(srowoff,(scoloff+ 8),"SCROLL SORT FIELDS")
 ENDIF
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (xscroll_cnt < numsrow)
  SET xscroll_cnt += 1
  CALL scrolltext(xscroll_cnt,xscroll_info[xscroll_cnt])
 ENDWHILE
 SET xscroll_cnt = 1
 SET arow = 1
#xscroll_repeat
 SET xscroll_pick = 0
 SET last_g_num = 0
 WHILE (xscroll_pick=0)
   IF (g_num < xscroll_max)
    CALL video(u)
    IF (g_print_sort=1)
     IF (last_g_num > 0)
      IF (last_g_num > g_print_maxcol)
       CALL text(((11+ last_g_num) - g_print_maxcol),40,g_print[last_g_num])
      ELSE
       CALL text((11+ last_g_num),03,g_print[last_g_num])
      ENDIF
     ENDIF
     IF (((g_num+ 1) > g_print_maxcol))
      CALL text((((11+ g_num)+ 1) - g_print_maxcol),40,g_print[(g_num+ 1)],accept)
     ELSE
      CALL text(((11+ g_num)+ 1),03,g_print[(g_num+ 1)],accept)
     ENDIF
    ELSE
     IF (last_g_num > 0)
      CALL text((11+ last_g_num),03,g_sort[last_g_num])
     ENDIF
     CALL text(((11+ g_num)+ 1),03,g_sort[(g_num+ 1)],accept)
    ENDIF
    CALL video(n)
   ENDIF
   CALL accept(24,10,"999;S",0)
   IF (curscroll=0)
    IF (curaccept=0)
     SET xscroll_pick = xscroll_cnt
     GO TO xscroll_pick
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET xscroll_pick = cnvtint(curaccept)
     GO TO xscroll_pick
    ENDIF
   ELSEIF (curscroll=1)
    IF (xscroll_cnt < maxcnt)
     SET xscroll_cnt += 1
     IF (arow=numsrow)
      CALL scrolldown(arow,arow,xscroll_info[xscroll_cnt])
     ELSE
      SET arow += 1
      CALL scrolldown((arow - 1),arow,xscroll_info[xscroll_cnt])
     ENDIF
    ENDIF
   ELSEIF (curscroll=2)
    IF (xscroll_cnt > 1)
     SET xscroll_cnt -= 1
     IF (arow=1)
      CALL scrollup(arow,arow,xscroll_info[xscroll_cnt])
     ELSE
      SET arow -= 1
      CALL scrollup((arow+ 1),arow,xscroll_info[xscroll_cnt])
     ENDIF
    ENDIF
   ELSEIF (curscroll IN (3, 6))
    IF (numsrow < maxcnt)
     SET xscroll_cnt = ((xscroll_cnt+ numsrow) - 1)
     IF (((xscroll_cnt+ numsrow) > maxcnt))
      SET xscroll_cnt = (maxcnt - numsrow)
     ENDIF
     SET arow = 1
     WHILE (arow <= numsrow)
       SET xscroll_cnt += 1
       CALL scrolltext(arow,xscroll_info[xscroll_cnt])
       SET arow += 1
     ENDWHILE
     SET arow = 1
     SET xscroll_cnt = ((xscroll_cnt - numsrow)+ 1)
    ENDIF
   ELSEIF (curscroll IN (4, 5))
    SET xscroll_cnt = 1
    WHILE (xscroll_cnt <= numsrow)
     CALL scrolltext(xscroll_cnt,xscroll_info[xscroll_cnt])
     SET xscroll_cnt += 1
    ENDWHILE
    SET xscroll_cnt = 1
    SET arow = 1
   ELSEIF (curscroll=11)
    IF (g_num < xscroll_max)
     SET g_num += 1
     SET last_g_num = g_num
     CALL video(ru)
     IF (g_print_sort=1)
      SET g_print[g_num] = " "
      IF (g_num > g_print_maxcol)
       CALL text(((11+ g_num) - g_print_maxcol),40,g_print[g_num])
      ELSE
       CALL text((11+ g_num),03,g_print[g_num])
      ENDIF
     ELSE
      SET g_sort[g_num] = " "
      CALL text((11+ g_num),03,g_sort[g_num])
     ENDIF
     CALL video(n)
    ENDIF
   ELSEIF (curscroll=9)
    IF (g_num > 0)
     SET last_g_num = (g_num+ 1)
     SET g_num -= 1
    ENDIF
   ELSEIF (curscroll=10)
    IF (g_num < xscroll_max)
     SET g_num = minval((g_num+ 1),(xscroll_max - 1))
     SET last_g_num = g_num
    ENDIF
   ENDIF
 ENDWHILE
 GO TO xscroll_repeat
#xscroll_pick
 IF (g_num < xscroll_max)
  IF (g_print_sort=1)
   SET g_num += 1
   SET g_print[g_num] = substring(6,35,xscroll_info[xscroll_pick])
   CALL video(u)
   IF (g_num > g_print_maxcol)
    CALL text(((11+ g_num) - g_print_maxcol),40,g_print[g_num])
   ELSE
    CALL text((11+ g_num),03,g_print[g_num])
   ENDIF
   CALL video(n)
  ELSE
   SET g_num += 1
   SET g_sort[g_num] = substring(6,35,xscroll_info[xscroll_pick])
   CALL video(u)
   CALL text((11+ g_num),03,g_sort[g_num])
   CALL video(n)
  ENDIF
 ENDIF
 IF (g_num < xscroll_max)
  GO TO xscroll_repeat
 ENDIF
#xscroll_home
 CALL clear(24,1)
 SET xnum = 0
 WHILE ((xnum <= (numsrow+ 1)))
  CALL clear((srowoff+ xnum),scoloff,(numscol+ 2))
  SET xnum += 1
 ENDWHILE
END GO
