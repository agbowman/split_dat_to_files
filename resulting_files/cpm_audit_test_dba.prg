CREATE PROGRAM cpm_audit_test:dba
 PAINT
 EXECUTE cclseclogin
 DECLARE bxmaintop = i2 WITH constant(3)
 DECLARE bxmainbot = i2 WITH constant(23)
 DECLARE bxmainlft = i2 WITH constant(1)
 DECLARE bxmainrgt = i2 WITH constant(80)
 DECLARE msglft = i2 WITH constant(30)
 DECLARE msgrgt = i2 WITH constant(79)
 DECLARE hmsg = i4 WITH noconstant(0)
 DECLARE hreq = i4 WITH noconstant(0)
 DECLARE hrep = i4 WITH noconstant(0)
 DECLARE hevent = i4 WITH noconstant(0)
 DECLARE hpart = i4 WITH noconstant(0)
 DECLARE srvstat = i2 WITH noconstant(0)
 DECLARE errorstr = vc WITH noconstant("")
 DECLARE personid = f8 WITH noconstant(0.0)
 DECLARE personname = vc WITH noconstant("")
 DECLARE encntrid = f8 WITH noconstant(0.0)
 DECLARE prsnlid = f8 WITH noconstant(0.0)
 DECLARE rolecd = f8 WITH noconstant(0.0)
 DECLARE auditsource = vc WITH noconstant("")
 DECLARE auditsourcetype = i4 WITH noconstant(0)
 DECLARE context = vc WITH noconstant("")
 DECLARE parttype = vc WITH noconstant("")
 DECLARE partidtype = vc WITH noconstant("")
 DECLARE partid = f8 WITH noconstant(0.0)
 DECLARE partname = vc WITH noconstant("")
 SUBROUTINE clearmessagearea(void)
   FOR (x = (bxmaintop+ 1) TO (bxmainbot - 1))
     CALL clear(x,msglft,((msgrgt - msglft)+ 1))
   ENDFOR
 END ;Subroutine
 SUBROUTINE messagebox(title,string,pause)
   CALL clearmessagearea(0)
   SET sizetitle = size(trim(title),1)
   SET sizestring = size(trim(string),1)
   IF (sizetitle > sizestring)
    SET boxsize = (sizetitle+ 4)
   ELSE
    SET boxsize = (sizestring+ 4)
   ENDIF
   SET boxleft = (msglft+ (((msgrgt - msglft) - boxsize)/ 2))
   SET boxright = (boxleft+ boxsize)
   SET titleleft = (boxleft+ ((boxsize - sizetitle)/ 2))
   SET stringleft = (boxleft+ ((boxsize - sizestring)/ 2))
   SET formatstr = build("P(",sizestring,");CU")
   CALL clearmessagearea(0)
   CALL box(5,boxleft,11,boxright)
   CALL text(6,titleleft,trim(title))
   CALL line(7,boxleft,(boxsize+ 1),xhor)
   IF (pause=1)
    CALL text(12,(boxleft+ 1),"Press Return")
    CALL accept(9,stringleft,formatstr,trim(string))
   ELSE
    CALL text(9,stringleft,trim(string))
   ENDIF
 END ;Subroutine
 SUBROUTINE getpatient(void)
   RECORD person_list(
     1 num_people = i4
     1 people[*]
       2 person_id = f8
       2 person_name = c50
   )
   SET last_name = fillstring(20," ")
   SET first_name = fillstring(20," ")
   SET person_id = 0
   CALL clearmessagearea(0)
   CALL box(5,msglft,13,msgrgt)
   CALL text(6,(msglft+ 2),"GetPatient")
   CALL text(8,(msglft+ 2),"Last Name")
   CALL text(9,(msglft+ 2),"First Name")
   CALL accept(8,(msglft+ 16),"P(20);CU")
   SET last_name = build(curaccept,"*")
   CALL accept(9,(msglft+ 16),"P(20);CU")
   SET first_name = build(curaccept,"*")
   SET person_list->num_people = 0
   SELECT INTO "nl:"
    p.person_id, p.name_full_formatted
    FROM person p
    WHERE p.name_last_key=patstring(last_name)
     AND p.name_first_key=patstring(first_name)
    ORDER BY p.name_last_key, p.name_first_key
    DETAIL
     person_list->num_people += 1, stat = alterlist(person_list->people,person_list->num_people),
     person_list->people[person_list->num_people].person_id = p.person_id,
     person_list->people[person_list->num_people].person_name = p.name_full_formatted
    WITH nocounter
   ;end select
   IF ((person_list->num_people > 0))
    SET help = pos(10,(msglft+ 5),13,((msgrgt - msglft) - 5))
    SET help =
    SELECT INTO "nl:"
     person_id = cnvtstring(person_list->people[d.seq].person_id), name = person_list->people[d.seq].
     person_name
     FROM (dummyt d  WITH seq = value(person_list->num_people))
     WITH nocounter
    ;end select
    CALL accept(11,51,"XXXXXXXXXXXXXXXX;;CUF")
    SET personid = person_list->people[curhelp].person_id
    SET personname = person_list->people[curhelp].person_name
    SET encntrid = 0
    SELECT INTO "nl:"
     e.encntr_id
     FROM encounter e
     WHERE e.person_id=personid
      AND e.active_ind=1
     DETAIL
      encntrid = e.encntr_id
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE sendrequest(a)
   SET hmsg = uar_srvselectmessage(6400)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hrep = uar_srvcreatereply(hmsg)
   SET srvstat = uar_srvsetulong(hreq,"audit_version",1)
   SET srvstat = uar_srvsetdate(hreq,"event_dt_tm",cnvtdatetime(sysdate))
   SET srvstat = uar_srvsetshort(hreq,"outcome_ind",1)
   SET srvstat = uar_srvsetstring(hreq,"user_name",curuser)
   SET srvstat = uar_srvsetdouble(hreq,"prsnl_id",prsnlid)
   SET srvstat = uar_srvsetdouble(hreq,"role_cd",rolecd)
   SET srvstat = uar_srvsetstring(hreq,"enterprise_site",nullterm("HNAM"))
   SET srvstat = uar_srvsetstring(hreq,"audit_source",auditsource)
   SET srvstat = uar_srvsetulong(hreq,"audit_source_type",auditsourcetype)
   SET srvstat = uar_srvsetulong(hreq,"network_acc_type",1)
   SET srvstat = uar_srvsetstring(hreq,"network_acc_id",nullterm("PCName"))
   SET srvstat = uar_srvsetasis(hreq,"context",context,size(context))
   SET hevent = uar_srvadditem(hreq,"event_list")
   SET srvstat = uar_srvsetstring(hevent,"event_name",nullterm("Test Name"))
   SET srvstat = uar_srvsetstring(hevent,"event_type",nullterm("Test Type"))
   SET hpart = uar_srvadditem(hevent,"participants")
   SET srvstat = uar_srvsetstring(hpart,"participant_type",nullterm(parttype))
   SET srvstat = uar_srvsetstring(hpart,"participant_role_cd",nullterm("Test Role Cd"))
   SET srvstat = uar_srvsetstring(hpart,"participant_id_type",nullterm(partidtype))
   SET srvstat = uar_srvsetdouble(hpart,"participant_id",partid)
   SET srvstat = uar_srvsetstring(hpart,"participant_name",nullterm(partname))
   SET srvstat = uar_srvsetstring(hpart,"data_life_cycle",nullterm("Test Data Life Cycle"))
   SET srvstat = uar_srvexecute(hmsg,hreq,hrep)
   IF (srvstat=0)
    CALL messagebox("SrvExecute","Success",1)
   ELSE
    SET errorstr = build("Status:",srvstat)
    CALL messagebox("SrvExecute",errorstr,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sendpatient(fillname)
   CALL getpatient(0)
   SET parttype = "Person"
   SET partidtype = "Patient"
   SET partid = personid
   IF (fillname=1)
    SET partname = personname
   ENDIF
   CALL sendrequest(0)
 END ;Subroutine
 SUBROUTINE sendencounter(b)
   CALL getpatient(0)
   SET parttype = "Encounter"
   SET partidtype = "Encounter"
   SET partid = encntrid
   CALL sendrequest(0)
 END ;Subroutine
 SUBROUTINE sendcodevalue(b)
   SET parttype = "Test Code"
   SET partidtype = "Test Code"
   CALL clearmessagearea(0)
   CALL box(5,msglft,13,msgrgt)
   CALL text(6,(msglft+ 2),"Test Code Value")
   CALL text(8,(msglft+ 2),"Code Value")
   CALL accept(8,(msglft+ 14),"9999999999")
   SET partid = curaccept
   CALL sendrequest(0)
 END ;Subroutine
 SUBROUTINE senddomain(b)
   CALL clearmessagearea(0)
   CALL box(5,msglft,13,msgrgt)
   CALL text(6,(msglft+ 2),"Domain Specific")
   CALL text(8,(msglft+ 2),"Participant Type")
   CALL text(9,(msglft+ 2),"Participant Id Type")
   CALL text(10,(msglft+ 2),"Participant Id")
   CALL text(11,(msglft+ 2),"Participant Name")
   CALL accept(8,(msglft+ 24),"P(20);CU")
   SET parttype = curaccept
   CALL accept(9,(msglft+ 24),"P(20);CU")
   SET partidtype = curaccept
   CALL accept(10,(msglft+ 24),"9999999999")
   SET partid = curaccept
   CALL accept(11,(msglft+ 24),"P(20);CU")
   SET partname = curaccept
   CALL sendrequest(0)
 END ;Subroutine
 SUBROUTINE initialize(c)
   SELECT INTO "nl:"
    p.person_id, p.position_cd
    FROM prsnl p
    WHERE p.username=curuser
    DETAIL
     prsnlid = p.person_id, rolecd = p.position_cd
    WITH nocounter
   ;end select
   SET auditsource = curnode
   SET auditsourcetype = 5000
   SET context = "9999999|5000|5050|6022|61|"
 END ;Subroutine
 SUBROUTINE sendoverflow(d)
   SET hmsg = uar_srvselectmessage(6400)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hrep = uar_srvcreatereply(hmsg)
   SET srvstat = uar_srvsetulong(hreq,"audit_version",1)
   SET srvstat = uar_srvsetdate(hreq,"event_dt_tm",cnvtdatetime(sysdate))
   SET srvstat = uar_srvsetshort(hreq,"outcome_ind",1)
   SET srvstat = uar_srvsetstring(hreq,"user_name",curuser)
   SET srvstat = uar_srvsetdouble(hreq,"prsnl_id",prsnlid)
   SET srvstat = uar_srvsetdouble(hreq,"role_cd",rolecd)
   SET srvstat = uar_srvsetstring(hreq,"enterprise_site",nullterm("HNAM"))
   SET srvstat = uar_srvsetstring(hreq,"audit_source",auditsource)
   SET srvstat = uar_srvsetulong(hreq,"audit_source_type",auditsourcetype)
   SET srvstat = uar_srvsetulong(hreq,"network_acc_type",1)
   SET srvstat = uar_srvsetstring(hreq,"network_acc_id",nullterm("PCName"))
   SET srvstat = uar_srvsetasis(hreq,"context",context,size(context))
   SET hevent = uar_srvadditem(hreq,"event_list")
   SET event_name = fillstring(70,"*")
   SET event_type = fillstring(80,"*")
   SET srvstat = uar_srvsetstring(hevent,"event_name",nullterm(event_name))
   SET srvstat = uar_srvsetstring(hevent,"event_type",nullterm(event_type))
   SET hpart = uar_srvadditem(hevent,"participants")
   SET participant_type = fillstring(75,"*")
   SET participant_role = fillstring(85,"*")
   SET participant_id_type = fillstring(90,"*")
   SET participant_name = fillstring(260,"*")
   SET data_life_cycle = fillstring(95,"*")
   SET srvstat = uar_srvsetstring(hpart,"participant_type",nullterm(participant_type))
   SET srvstat = uar_srvsetstring(hpart,"participant_role_cd",nullterm(participant_role))
   SET srvstat = uar_srvsetstring(hpart,"participant_id_type",nullterm(participant_id_type))
   SET srvstat = uar_srvsetdouble(hpart,"participant_id",1234.0)
   SET srvstat = uar_srvsetstring(hpart,"participant_name",nullterm(participant_name))
   SET srvstat = uar_srvsetstring(hpart,"data_life_cycle",nullterm(data_life_cycle))
   SET hpart = uar_srvadditem(hevent,"participants")
   SET srvstat = uar_srvsetstring(hpart,"participant_id_type",nullterm("OVERFLOWTEST"))
   SET srvstat = uar_srvsetdouble(hpart,"participant_id",1234.0)
   SET srvstat = uar_srvexecute(hmsg,hreq,hrep)
   IF (srvstat=0)
    CALL messagebox("SrvExecute","Success",1)
   ELSE
    SET errorstr = build("Status:",srvstat)
    CALL messagebox("SrvExecute - 1",errorstr,1)
   ENDIF
 END ;Subroutine
 CALL initialize(0)
 DECLARE menuchoice = i2 WITH noconstant(0)
 DECLARE menuquit = c1 WITH noconstant("N")
 WHILE (menuquit="N")
   CALL box(bxmaintop,bxmainlft,bxmainbot,bxmainrgt)
   CALL text(2,1,"CPM Audit Test",w)
   CALL text((bxmaintop+ 3),5," 1) Patient")
   CALL text((bxmaintop+ 4),5," 2) Patient with Name")
   CALL text((bxmaintop+ 5),5," 3) Encounter")
   CALL text((bxmaintop+ 6),5," 4) Code Value")
   CALL text((bxmaintop+ 7),5," 5) Domain Specific")
   CALL text((bxmaintop+ 8),5," 6) Overflow")
   CALL text((bxmaintop+ 9),5," 7) ")
   CALL video(r)
   CALL text((bxmaintop+ 9),9,"Exit")
   CALL video(n)
   CALL text((bxmainbot+ 1),2,"Select Option (1,2,3,4,5...)")
   CALL accept((bxmainbot+ 1),36,"99;",7
    WHERE curaccept IN (1, 2, 3, 4, 5,
    6, 7))
   SET menuchoice = curaccept
   CASE (menuchoice)
    OF 1:
     CALL sendpatient(0)
    OF 2:
     CALL sendpatient(1)
    OF 3:
     CALL sendencounter(0)
    OF 4:
     CALL sendcodevalue(0)
    OF 5:
     CALL senddomain(0)
    OF 6:
     CALL sendoverflow(0)
    ELSE
     SET menuquit = "Y"
   ENDCASE
   CALL clear(24,1)
   CALL clear(1,1)
 ENDWHILE
 CALL clear(24,1)
 CALL clear(1,1)
END GO
