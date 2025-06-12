CREATE PROGRAM cclassist3
 SET srowoff = 12
 SET scoloff = 25
 SET numsrow = scroll_cnt
 SET numscol = scroll_len
 SET maxcnt = scroll_cnt
 SET scroll_cnt = 1
 CALL text(24,1,"Select ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL text(srowoff,(scoloff+ 5),scroll_title)
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (scroll_cnt <= numsrow)
  CALL scrolltext(scroll_cnt,scroll_info[scroll_cnt])
  SET scroll_cnt += 1
 ENDWHILE
 SET scroll_cnt = 1
 SET arow = 1
#repeat
 SET scroll_pick = 0
 WHILE (scroll_pick=0)
  CALL accept(24,10,"999;S",0)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     SET scroll_pick = scroll_cnt
     GO TO scroll_done
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET scroll_pick = cnvtint(curaccept)
     GO TO scroll_done
    ENDIF
   OF 1:
    IF (scroll_cnt < maxcnt)
     SET scroll_cnt += 1
     IF (arow=numsrow)
      CALL scrolldown(arow,arow,scroll_info[scroll_cnt])
     ELSE
      SET arow += 1
      CALL scrolldown((arow - 1),arow,scroll_info[scroll_cnt])
     ENDIF
    ENDIF
   OF 2:
    IF (scroll_cnt > 1)
     SET scroll_cnt -= 1
     IF (arow=1)
      CALL scrollup(arow,arow,scroll_info[scroll_cnt])
     ELSE
      SET arow -= 1
      CALL scrollup((arow+ 1),arow,scroll_info[scroll_cnt])
     ENDIF
    ENDIF
  ENDCASE
 ENDWHILE
 GO TO repeat
#scroll_done
 SET scroll_cnt = maxcnt
END GO
