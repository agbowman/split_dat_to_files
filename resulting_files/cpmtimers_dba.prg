CREATE PROGRAM cpmtimers:dba
 PAINT
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,22,80)
 CALL line(3,1,80,xhoraz)
 CALL text(2,3,"Server Timer Reports")
 CALL video(n)
 CALL text(4,5,"1. Script Server: Execute Time")
 CALL text(5,5,"2. Script Server: Summary by Request ")
 CALL text(6,5,"3. Script Server: Summary by User ")
 CALL text(7,5,"4. Script Server: Detail log of executions ")
 CALL text(8,5,"5. Script Server: Script Error Report ")
 CALL text(9,5,"6. Application Server: Statistics")
 CALL text(10,5,"7. Application Server: Usage by Application/User")
 CALL text(11,5,"8. Application Server: Usage by Application")
 CALL text(12,5,"9. Application Server: Usage by User/Application")
 CALL text(13,5,"10. Access Reports ")
 CALL text(14,5,"11. All Server Performance by Server ")
 CALL text(15,5,"12. Monitors ")
 CALL text(17,10,"Select  (0 to Exit)")
 CALL accept(17,5,"99")
 CASE (curaccept)
  OF 0:
   GO TO end_program
  OF 1:
   EXECUTE crmtimer2
  OF 2:
   EXECUTE crmtimer3
  OF 3:
   EXECUTE crmtimer4
  OF 4:
   EXECUTE crmtimer5
  OF 5:
   EXECUTE scripterrors
  OF 6:
   EXECUTE apptimer
  OF 7:
   EXECUTE apptimer2
  OF 8:
   EXECUTE apptimer3
  OF 9:
   EXECUTE apptimer4
  OF 10:
   EXECUTE contextreports
  OF 11:
   EXECUTE steptimer2
  OF 12:
   EXECUTE monitors
 ENDCASE
 FREE DEFINE msgview
 FREE DEFINE crmtimer
 GO TO start
#end_program
END GO
