CREATE PROGRAM cclmaildemo
 PAINT
 SET mail_msubject = fillstring(30," ")
 SET mail_mfrom = fillstring(12," ")
 SET mail_mto = fillstring(12," ")
 SET mail_mtype = " "
 SET mail_mstat = " "
 SET mail_mcnt = 0
#mail_begin
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,5,"Demo CCL Mail Interface")
 CALL text(5,5,"Type (M/A/B)")
 CALL text(7,5,"From User")
 CALL text(9,5,"To User/Board")
 CALL text(11,5,"Subject")
 CALL text(13,5,"Correct (Y/N)")
 CASE (mail_mstat)
  OF "Y":
   CALL text(15,5,"Mail Message was sent")
  OF "N":
   CALL text(15,5,"Mail Message was not sent")
 ENDCASE
 SET help = fix('M"MAIL",A"ANSWER",B"BOARD"')
 SET mail_mtype = "M"
 CALL accept(5,25,"P;CU",mail_mtype
  WHERE curaccept IN ("M", "A", "B"))
 SET mail_mtype = curaccept
 SET help = off
 SET mail_mfrom = curuser
 CALL video(ur)
 CALL text(7,25,mail_mfrom)
 CALL video(n)
 CALL accept(9,25,"PPPPPPPPPPPP;CU"
  WHERE curaccept > " ")
 SET mail_mto = curaccept
 IF (mail_mtype="A")
  SET help =
  SELECT INTO "NL:"
   subject = _m.subject, board = _m.user_id, replies = _m.nbr_replies
   FROM ml05_1 _m
   WHERE _m.message_type="B"
    AND _m.user_id=mail_mto
    AND _m.qualifier=01
   WITH nocounter
  ;end select
  CALL accept(11,25,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CUF"
   WHERE curaccept > " ")
 ELSE
  CALL accept(11,25,"PPPPPPPPPPPPPPPPPPPPPPPPPPPPPP;CU"
   WHERE curaccept > " ")
 ENDIF
 SET mail_msubject = curaccept
 SET help = off
 CALL accept(13,25,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept != "Y")
  GO TO mail_begin
 ENDIF
 SET mail_alloc = 500
 SET mail_msg = fillstring(39000," ")
 FREE DEFINE rtl
 SET ml_temp_file = concat("MAILCCL",curuser,".DAT")
 CALL edit(ml_temp_file,"EDT")
 DEFINE rtl ml_temp_file
 SET mail_mcnt = 0
 SELECT INTO "NL:"
  rtlt.line
  FROM rtlt
  DETAIL
   IF (mail_mcnt < 500)
    mail_mcnt += 1, stat = movestring(rtlt.line,1,mail_msg,(1+ ((mail_mcnt - 1) * 78)),78)
   ENDIF
  WITH nocounter
 ;end select
 FREE DEFINE rtl
 CALL clear(1,1)
 CALL text(24,1,"SENDING MAIL MESSAGE...")
 EXECUTE cclmailsend mail_mto, mail_mfrom, mail_mtype,
 mail_mcnt, mail_msubject, mail_msg
 IF (curqual=0)
  SET mail_mstat = "N"
 ELSE
  SET mail_mstat = "Y"
 ENDIF
 GO TO mail_begin
END GO
