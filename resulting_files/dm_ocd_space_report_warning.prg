CREATE PROGRAM dm_ocd_space_report_warning
 PAINT
 SET width = 132
 CALL clear(1,1)
 CALL text(2,35,"WARNING")
 IF ((spc_rpt->report_seq=0))
  CALL text(3,1,"No space summary report found for this environment. Without a space summary")
  CALL text(4,1,"report the following operations can be severly affected:")
  CALL text(5,1,"  - time estimates for readme steps will not be calculated")
  CALL text(6,1,"  - time estimates for schema installation will not be calculated")
  CALL text(7,1,"  - tablespace check for schema installation will not be accuarate")
  CALL text(8,1,"  - index sizing parameters (init and next) will be set to default (16k)")
  CALL text(9,1,"A recent space summary report (executed within the last 30 days) is")
  CALL text(10,1,"recommended before attempting to install an OCD.")
 ELSEIF ((spc_rpt->days_old > 30))
  CALL text(3,1,"Following is the latest space summary report found for this environment:")
  CALL text(4,5,concat("report_seq = ",trim(cnvtstring(spc_rpt->report_seq)),"  ","exectued on ",
    format(spc_rpt->begin_date,"DD-MMM-YYYY;;D")))
  CALL text(5,1,"Without a recent space summary report (executed within the last 30 days)")
  CALL text(6,1,"the following operations can be affected:")
  CALL text(7,1,"  - time estimates for readme steps may not be accurate")
  CALL text(8,1,"  - time estimates for schema installation may not be accurate")
  CALL text(9,1,"  - tablespace check for schema installation may not be accurate")
  CALL text(10,1,"  - index sizing parameters (init and next) may be too small")
 ENDIF
 CALL text(12,1,"You may continue the installation now or continue at a later time.")
 CALL text(13,1,"Enter 'C' to continue or 'Q' to continue later. (C or Q):")
 SET done = 0
 WHILE (done=0)
   CALL accept(13,60,"A;cu","Q")
   SET choice = curaccept
   IF (choice="Q")
    SET docd_reply->status = "Q"
    SET docd_reply->err_msg = "User has decided to continue installation at a later time"
    SET done = 1
   ELSE
    SET docd_reply->status = "C"
    SET docd_reply->err_msg = "User has decided to continue installation now"
    SET done = 1
   ENDIF
 ENDWHILE
END GO
