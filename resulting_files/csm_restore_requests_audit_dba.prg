CREATE PROGRAM csm_restore_requests_audit:dba
 PAINT
 CALL clear(1,1)
 CALL video(r)
 CALL text(2,24,"         Outreach Services         ")
 CALL text(3,24,"     S e c u r e    L o g i n      ")
 CALL video(n)
 CALL box(1,1,23,80)
 CALL line(4,1,80,xhor)
 CALL line(1,22,4,xvert)
 CALL line(1,60,4,xvert)
 IF (curenv=0)
  SET xloginck = validate(xxcclseclogin->loggedin,99)
  IF (xloginck != 1)
   SET trace = recpersist
   RECORD xxcclseclogin(
     1 loggedin = i4
   )
   SET trace = norecpersist
   SET valid = 0
   WHILE (valid=0)
     CALL clear(15,10,69)
     CALL clear(16,10,69)
     CALL clear(17,10,69)
     CALL clear(18,10,69)
     CALL clear(19,10,69)
     CALL clear(20,10,69)
     CALL clear(21,10,69)
     CALL clear(22,10,69)
     CALL text(15,25,"     UserName")
     CALL accept(15,40,"p(30);cu")
     SET p1 = curaccept
     CALL clear(15,40,39)
     CALL text(15,40,p1)
     CALL text(16,25,"       Domain")
     CALL accept(16,40,"p(30);cu")
     SET p2 = curaccept
     CALL clear(16,40,39)
     CALL text(16,40,p2)
     SET password = fillstring(30," ")
     CALL text(17,25,"     Password")
     CALL accept(17,40,"p(30);cue"," ")
     CALL clear(16,40,39)
     SET password = curaccept
     CALL text(17,40,". . . . . .")
     CALL video(b)
     CALL text(24,5,"communicating with database...")
     SET stat = uar_sec_login(nullterm(cnvtupper(p1)),nullterm(cnvtupper(p2)),nullterm(cnvtupper(
        password)))
     CALL video(n)
     CALL clear(24,5,74)
     IF (stat=0)
      CALL clear(20,20,59)
      CALL text(20,30,"SECURITY LOGIN SUCCESS")
      SET valid = 1
      SET xxcclseclogin->loggedin = 1 WITH persist
     ELSE
      CALL clear(20,20,59)
      CALL text(19,20,build("SECURITY LOGIN FAILURE WITH STATUS -->",stat,"<--"))
      SET valid = 0
     ENDIF
     CALL text(21,31,"Enter Y to continue")
     CALL accept(22,39,"p;cu","Y")
     IF (curaccept != "Y")
      SET valid = 1
     ENDIF
   ENDWHILE
   CALL clear(1,1)
  ELSE
   CALL text(16,23,"You are logged in.  Exit ccl to logout.")
   CALL pause(2)
  ENDIF
 ENDIF
 RECORD temp_rec(
   1 purge_date = dq8
 )
 RECORD temp_reply(
   1 num_restored = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 targetstatename = c15
 )
 SET mydate = curdate
 SET purge_date = fillstring(12," ")
 SET old_date_string = fillstring(12," ")
 SET old_date_string = format((curdate - 180),"MM/DD/YYYY;;D")
 SET old_date = cnvtdate(cnvtint(cnvtalphanum(old_date_string)))
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,6,80)
 CALL text(2,2,"CSM Request Restore Purged Records Program:")
 CALL text(4,2,"This Program is used to restore purged CSM Requests from the")
 CALL text(5,2,"CSM_REQUESTS_ARCHIVE table with a given Purge Date.")
 CALL text(8,1,"Please enter purged date(MM/DD/YYYY):")
 CALL accept(8,45,"NNDNNDNNNN;CS",format(mydate,"MM/DD/YYYY;;D"))
 IF (cnvtdate(cnvtint(cnvtalphanum(curaccept))) < old_date)
  CALL text(10,1,"Purged requests older than 180 days cannot be restored.")
  GO TO exit_script
 ENDIF
 SET purge_date = curaccept
 CALL text(10,1,concat("Restore from Purge Date (Y/N): ",purge_date))
 CALL accept(10,45,"P;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO exit_script
 ENDIF
 SET temp_rec->purge_date = cnvtdatetime(cnvtdate(cnvtint(cnvtalphanum(purge_date))),0)
 EXECUTE os_csm_restore_purged_requests  WITH replace(request,temp_rec), replace(reply,temp_reply)
 CALL clear(1,1)
 CALL box(1,1,6,80)
 CALL text(2,2,"CSM Request Restore Purged Records Program:")
 CALL text(4,2,"This Program is used to restore purged CSM Requests from the")
 CALL text(5,2,"CSM_REQUESTS_ARCHIVE table with a given Purge Date.")
 CALL text(7,2,concat("Number of CSM Requests Restored: ",cnvtstring(temp_reply->num_restored)))
 IF ((temp_reply->num_restored > 0))
  CALL text(9,2,"These requests will be purged next time the purge routine runs from OPS.")
 ENDIF
 GO TO exit_script
#exit_script
END GO
