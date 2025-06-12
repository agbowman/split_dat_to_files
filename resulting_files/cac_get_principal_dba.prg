CREATE PROGRAM cac_get_principal:dba
 RECORD ncodereply(
   1 successful_users[*]
     2 username = vc
     2 principal = vc
   1 failed_users[*]
     2 username = vc
 )
 DECLARE step_id = i4 WITH protect, constant(99999119)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 DECLARE successind = i2 WITH protect, noconstant(0)
 DECLARE successfulindex = i2 WITH protect, noconstant(0)
 DECLARE failedindex = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE numberofusers = i4 WITH protect, constant(size(ncoderequest->users,5))
 DECLARE batch_size = i4 WITH protect, constant(200)
 DECLARE numberofpasses = i4 WITH protect, constant(ceil((cnvtreal(numberofusers)/ cnvtreal(
    batch_size))))
 DECLARE currentpass = i4 WITH protect, noconstant(1)
 DECLARE startindex = i4 WITH protect, noconstant(0)
 DECLARE endindex = i4 WITH protect, noconstant(0)
 DECLARE expandindex = i4 WITH protect, noconstant(0)
 DECLARE currentuser = i4 WITH protect, noconstant(0)
 DECLARE locateindex = i4 WITH protect, noconstant(0)
 DECLARE userindex = i4 WITH protect, noconstant(0)
 DECLARE foundind = i2 WITH protect, noconstant(0)
 FOR (currentuser = 1 TO numberofusers)
   SET foundind = 0
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE cnvtupper(p.username)=cnvtupper(ncoderequest->users[currentuser].username)
    DETAIL
     CALL echo(build("Now processing username: ",p.username)), foundind = 1, hstep =
     uar_srvselectmessage(step_id),
     hrequest = uar_srvcreaterequest(hstep)
     IF ( NOT (hrequest))
      CALL echo(build("Could not create request for user ",p.username)), failedindex = (failedindex+
      1)
      IF (failedindex > size(ncodereply->failed_users,5))
       stat = alterlist(ncodereply->failed_users,(failedindex+ 10))
      ENDIF
      ncodereply->failed_users[failedindex].username = p.username
     ELSE
      stat = uar_srvsetdouble(hrequest,"person_id",p.person_id), hreply = uar_srvcreatereply(hstep),
      stat = uar_srvexecute(hstep,hrequest,hreply)
      IF (stat != 0)
       CALL echo(build("Could not execute oauth request for user ",p.username)), failedindex = (
       failedindex+ 1)
       IF (failedindex > size(ncodereply->failed_users,5))
        stat = alterlist(ncodereply->failed_users,(failedindex+ 10))
       ENDIF
       ncodereply->failed_users[failedindex].username = p.username
      ELSE
       hstatus = uar_srvgetstruct(hreply,"status"), successind = uar_srvgetshort(hstatus,
        "success_ind")
       IF (successind=1)
        CALL echo(build("Success for ",p.username)), successfulindex = (successfulindex+ 1)
        IF (successfulindex > size(ncodereply->successful_users,5))
         stat = alterlist(ncodereply->successful_users,(successfulindex+ 10))
        ENDIF
        CALL echo(build("Placing at ",successfulindex)), ncodereply->successful_users[successfulindex
        ].username = p.username, ncodereply->successful_users[successfulindex].principal =
        uar_srvgetstringptr(hreply,"xoauth_principal")
       ELSE
        CALL echo(build("Oauth request failed for user ",p.username)), failedindex = (failedindex+ 1)
        IF (failedindex > size(ncodereply->failed_users,5))
         stat = alterlist(ncodereply->failed_users,(failedindex+ 10))
        ENDIF
        ncodereply->failed_users[failedindex].username = p.username
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (foundind=0)
    CALL echo(build("No personnel found with username ",ncoderequest->users[currentuser].username))
    SET failedindex = (failedindex+ 1)
    IF (failedindex > size(ncodereply->failed_users,5))
     SET stat = alterlist(ncodereply->failed_users,(failedindex+ 10))
    ENDIF
    SET ncodereply->failed_users[failedindex].username = ncoderequest->users[currentuser].username
   ENDIF
 ENDFOR
 SET stat = alterlist(ncodereply->successful_users,successfulindex)
 SET stat = alterlist(ncodereply->failed_users,failedindex)
#cleanup
 CALL uar_srvdestroyinstance(hrequest)
 CALL uar_srvdestroyinstance(hreply)
 CALL uar_srvdestroymessage(hstep)
END GO
