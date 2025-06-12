CREATE PROGRAM apaudit
 PAINT
#prog_start
 CALL clear(1,1)
 CALL video(r)
 CALL text(2,24,"        Anatomic Pathology         ")
 CALL text(3,24,"           A u d i t s             ")
 CALL video(n)
 CALL box(1,1,23,80)
 CALL line(4,1,80,xhor)
 CALL line(1,22,4,xvert)
 CALL line(1,60,4,xvert)
 CALL video(u)
 CALL video(l)
 CALL text(6,3,"                                                                            ")
 CALL video(n)
 CALL text(8,5,"1   CYTOLOGY DIAGNOSTIC CATEGORIES   12  ALPHA RESPONSE                   ")
 CALL text(9,5,"2   FIXATIVES                                                             ")
 CALL text(10,5,"3   CYTO FOLLOW-UP TERM REASONS                                           ")
 CALL text(11,5,"4   REPORT HOLD REASONS                                                   ")
 CALL text(12,5,"5   HISTORY GROUPS                                                        ")
 CALL text(13,5,"6   SPECIMENS                                                             ")
 CALL text(14,5,"7   SPECIMEN ADEQUACY                                                     ")
 CALL text(15,5,"8   ALPHA RESPONSES                                                       ")
 CALL text(16,5,"9   GROUP TESTS                                                           ")
 CALL text(17,5,"10  PREFIXES                                                              ")
 CALL text(18,5,"11  ORDER CATALOG                                                         ")
 CALL video(ul)
 CALL text(19,3,"                                                                             ")
 CALL video(n)
 CALL text(20,5,"                                                                          ")
 CALL text(21,5,"                                      X   Exit                            ")
 CALL video(n)
 CALL video(r)
 CALL line(5,40,18,xvert)
 CALL box(5,2,22,79)
 CALL video(n)
 CALL text(24,6," Make selection")
 CALL accept(24,3,"pp;cu","1"
  WHERE curaccept IN ("1", "2", "3", "4", "5",
  "6", "7", "8", "9", "10",
  "11", "12", "x", "X"))
 IF (curaccept IN ("1"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_one
  GO TO prog_start
 ELSEIF (curaccept IN ("2"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_two
  GO TO prog_start
 ELSEIF (curaccept IN ("3"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_three
  GO TO prog_start
 ELSEIF (curaccept IN ("4"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_four
  GO TO prog_start
 ELSEIF (curaccept IN ("5"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_five
  GO TO prog_start
 ELSEIF (curaccept IN ("6"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_six
  GO TO prog_start
 ELSEIF (curaccept IN ("7"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_seven
  GO TO prog_start
 ELSEIF (curaccept IN ("8"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_eight
  GO TO prog_start
 ELSEIF (curaccept IN ("9"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_nine
  GO TO prog_start
 ELSEIF (curaccept IN ("10"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE db_ap_ten
  GO TO prog_start
 ELSEIF (curaccept IN ("11"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE aps_db_orc_audit
  GO TO prog_start
 ELSEIF (curaccept IN ("12"))
  CALL video(b)
  CALL text(24,3," processing requested audit... ")
  CALL video(n)
  EXECUTE ap_alpha_audit
  GO TO prog_start
 ENDIF
 CALL clear(1,1)
 CALL text(1,1,"thanks")
 CALL text(1,8,curuser)
 CALL text(3,0,"cerner corporation")
 CALL text(4,0,"")
END GO
