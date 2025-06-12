CREATE PROGRAM cs_master_menu:dba
 PAINT
 DECLARE reporttype = i2
 SET reporttype =  $1
 FREE SET diag_request
 RECORD diag_request(
   1 master_qual = i4
   1 master_list[*]
     2 master_event_id = f8
     2 order_id = f8
 )
 SUBROUTINE getbymaster(dummy)
   SET stat = alterlist(diag_request->master_list,1)
   CALL box(5,49,10,79)
   CALL text(6,54,"Enter Master Event ID")
   CALL line(7,49,31,xhor)
   CALL accept(8,59,"9999999999")
   SET diag_request->master_list[1].master_event_id = curaccept
   SELECT INTO "nl:"
    c.ext_m_event_id
    FROM charge_event c
    WHERE (c.ext_m_event_id=diag_request->master_list[1].master_event_id)
    DETAIL
     diag_request->master_qual = 1
    WITH nocounter
   ;end select
   CALL video(b)
   CALL text(19,30,"**PROCESSING**")
   CALL video(n)
 END ;Subroutine
 SUBROUTINE getbyaccession(dummy)
   SET accession = fillstring(18," ")
   CALL box(5,49,10,79)
   CALL text(6,54,"Enter Accession Number")
   CALL line(7,49,31,xhor)
   CALL accept(8,56,"P(18);CU")
   SET accession = build("*",curaccept,"*")
   CALL video(b)
   CALL text(19,30,"**PROCESSING**")
   CALL video(n)
   SET count = 0
   SELECT DISTINCT INTO "nl:"
    c.ext_m_event_id
    FROM charge_event c
    WHERE c.accession=patstring(accession)
    ORDER BY c.ext_m_event_id
    DETAIL
     count += 1, stat = alterlist(diag_request->master_list,count), diag_request->master_list[count].
     master_event_id = c.ext_m_event_id
    WITH nocounter
   ;end select
   SET diag_request->master_qual = count
 END ;Subroutine
 SUBROUTINE getbyorder(dummy)
   SET order_id = 0.0
   CALL box(5,49,10,79)
   CALL text(6,57,"Enter Order ID")
   CALL line(7,49,31,xhor)
   CALL accept(8,59,"9999999999")
   SET order_id = curaccept
   CALL video(b)
   CALL text(19,30,"**PROCESSING**")
   CALL video(n)
   SET count = 0
   SELECT DISTINCT INTO "nl:"
    c.ext_m_event_id
    FROM charge_event c
    WHERE c.order_id=order_id
    ORDER BY c.ext_m_event_id
    DETAIL
     count += 1, stat = alterlist(diag_request->master_list,count), diag_request->master_list[count].
     master_event_id = c.ext_m_event_id
    WITH nocounter
   ;end select
   SET diag_request->master_qual = count
 END ;Subroutine
 SUBROUTINE getbypersondate(dummy)
   FREE SET person_list
   RECORD person_list(
     1 num_people = i4
     1 people[*]
       2 person_id = f8
       2 person_name = c50
   )
   SET last_name = fillstring(20," ")
   SET first_name = fillstring(20," ")
   SET person_id = 0.0
   FOR (x = 5 TO 12)
     CALL clear(x,34,40)
   ENDFOR
   CALL box(5,35,14,75)
   CALL text(6,45,"Enter Person/Date Range")
   CALL line(7,35,41,xhor)
   CALL text(9,40,"Last Name")
   CALL text(10,40,"First Name")
   CALL text(11,40,"Begin Date")
   CALL text(12,40,"End Date")
   CALL accept(9,51,"P(20);CU")
   SET last_name = build(curaccept,"*")
   CALL accept(10,51,"P(20);CU")
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
    SET help = pos(11,10,10,60)
    SET help =
    SELECT INTO "nl:"
     person_id = cnvtstring(person_list->people[d.seq].person_id,17,2), name = person_list->people[d
     .seq].person_name
     FROM (dummyt d  WITH seq = value(person_list->num_people))
     WITH nocounter
    ;end select
    CALL accept(11,51,"XXXXXXXXXXXXXXXX;;CUF")
    SET person_id = person_list->people[curhelp].person_id
    SET help = off
    SELECT INTO "nl:"
     p.name_first_key, p.name_last_key
     FROM person p
     WHERE p.person_id=cnvtreal(person_id)
     DETAIL
      first_name = p.name_first_key, last_name = p.name_last_key
     WITH nocounter
    ;end select
    CALL video(r)
    CALL text(9,51,last_name)
    CALL text(10,51,first_name)
    CALL video(n)
    CALL text(17,19,"Press <Up Arrow> to reset to Default Value")
    SET now = datetimeadd(cnvtdatetime(curdate,curtime),- ((60/ 1440.0)))
    SET done = "F"
    WHILE (done="F")
     CALL accept(11,51,"NNDXXXDNNNNDNNDNN;CUS",format(now,"DD-MMM-YYYY HH:MM;;D"))
     IF (curscroll=0)
      SET done = "T"
      SET beg_date = curaccept
     ELSE
      CALL text(11,51,format(now,"DD-MMM-YYYY HH:MM;;D"))
     ENDIF
    ENDWHILE
    SET now = cnvtdatetime(curdate,curtime)
    SET done = "F"
    WHILE (done="F")
     CALL accept(12,51,"NNDXXXDNNNNDNNDNN;CUS",format(now,"DD-MMM-YYYY HH:MM;;D"))
     IF (curscroll=0)
      SET done = "T"
      SET end_date = curaccept
     ELSE
      CALL text(11,51,format(now,"DD-MMM-YYYY HH:MM;;D"))
     ENDIF
    ENDWHILE
    CALL clear(17,19,80)
    CALL video(b)
    CALL text(19,30,"**PROCESSING**")
    CALL video(n)
    SET count = 0
    SET diag_request->master_qual = 0
    SELECT DISTINCT INTO "nl:"
     c.ext_m_event_id
     FROM charge_event c,
      charge_event_act ca
     PLAN (c
      WHERE c.person_id=cnvtreal(person_id))
      JOIN (ca
      WHERE ca.charge_event_id=c.charge_event_id
       AND ca.service_dt_tm > cnvtdatetime(beg_date)
       AND ca.service_dt_tm < cnvtdatetime(end_date))
     ORDER BY c.ext_m_event_id
     DETAIL
      count += 1, stat = alterlist(diag_request->master_list,count), diag_request->master_list[count]
      .master_event_id = c.ext_m_event_id
     WITH nocounter
    ;end select
    SET diag_request->master_qual = count
    FREE SET now
    FREE SET done
    FREE SET count
   ELSE
    CALL text(17,20,"Sorry.  There were no matching names")
    CALL pause(3)
    SET diag_request->master_qual = - (1)
    CALL clear(24,1)
    CALL clear(1,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE getorderid(dummy)
   SET order_id = 0.0
   CALL box(5,49,10,79)
   CALL text(6,57,"Enter Order ID")
   CALL line(7,49,31,xhor)
   CALL accept(8,59,"9999999999")
   SET order_id = curaccept
   CALL video(b)
   CALL text(19,30,"**PROCESSING**")
   CALL video(n)
   SET count = 0
   SELECT DISTINCT INTO "nl:"
    c.ext_m_event_id
    FROM charge_event c
    WHERE c.order_id=order_id
    ORDER BY c.ext_m_event_id
    DETAIL
     count += 1, stat = alterlist(diag_request->master_list,count), diag_request->master_list[count].
     master_event_id = c.ext_m_event_id,
     diag_request->master_list[count].order_id = c.order_id
    WITH nocounter
   ;end select
   SET diag_request->master_qual = count
 END ;Subroutine
 DECLARE menuchoice = i2
 DECLARE menuquit = c1
 SET menuchoice = 0
 SET menuquit = "N"
 SET diag_request->master_qual = 0
 WHILE (menuquit="N")
   CALL clear(24,1)
   CALL clear(1,1)
   CALL box(3,1,23,80)
   IF (reporttype=1)
    CALL text(2,1,"AFC MASTER REPORT",w)
   ELSEIF (reporttype=2)
    CALL text(2,1,"SERVER DIAGNOSTICS REPORT",w)
   ENDIF
   CALL text(06,10," 1) Get Master with Master Event ID")
   CALL text(08,10," 2) Get Master with Accession Number")
   CALL text(10,10," 3) Get Master with Order ID")
   CALL text(12,10," 4) Get Master with Person/Date Range")
   CALL text(14,10," 5) Get Order with Order ID")
   CALL text(16,10," 6) ")
   CALL video(r)
   CALL text(16,14,"Previous Menu")
   CALL video(n)
   CALL text(24,2,"Select Option (1,2,3...)")
   CALL accept(24,36,"9;",6
    WHERE curaccept IN (1, 2, 3, 4, 5,
    6))
   SET menuchoice = curaccept
   CASE (menuchoice)
    OF 1:
     CALL getbymaster("INTEXT")
    OF 2:
     CALL getbyaccession("INTEXT")
    OF 3:
     CALL getbyorder("INTEXT")
    OF 4:
     CALL getbypersondate("INTEXT")
    OF 5:
     CALL getorderid("INTEXT")
    ELSE
     SET menuquit = "Y"
   ENDCASE
   IF (menuquit="N"
    AND menuchoice > 0
    AND menuchoice < 6
    AND (diag_request->master_qual > 0))
    IF (reporttype=1)
     EXECUTE afc_master_rpt
    ELSEIF (reporttype=2)
     EXECUTE cs_srv_diagnostics_rpt
    ENDIF
   ELSEIF ((diag_request->master_qual=0)
    AND menuchoice > 0
    AND menuchoice < 6)
    CALL text(19,15,"SORRY.  No charge event information found for that item")
    CALL pause(4)
    CALL clear(24,1)
    CALL clear(1,1)
   ENDIF
 ENDWHILE
 CALL clear(24,1)
 CALL clear(1,1)
END GO
