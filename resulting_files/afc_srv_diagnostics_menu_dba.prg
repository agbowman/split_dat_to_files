CREATE PROGRAM afc_srv_diagnostics_menu:dba
 PAINT
 FREE SET diag_request
 RECORD diag_request(
   1 master_qual = i4
   1 master_list[*]
     2 master_event_id = f8
 )
 EXECUTE cclseclogin
 SUBROUTINE getbymaster(dummy)
   CALL echo("GetByMaster - Begin")
   SET stat = alterlist(diag_request->master_list,1)
   CALL box(5,40,10,70)
   CALL text(6,45,"Enter Master Event ID")
   CALL line(7,40,31,xhor)
   CALL accept(8,50,"9999999999")
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
   CALL text(17,30,"**PROCESSING**")
   CALL video(n)
   CALL echo("GetByMaster - End")
 END ;Subroutine
 SUBROUTINE getbyaccession(dummy)
   CALL echo("GetByAccession - Begin")
   SET accession = fillstring(18," ")
   CALL box(5,40,10,70)
   CALL text(6,45,"Enter Accession Number")
   CALL line(7,40,31,xhor)
   CALL accept(8,47,"P(18);c")
   SET accession = curaccept
   CALL video(b)
   CALL text(17,30,"**PROCESSING**")
   CALL video(n)
   SET count = 0
   SELECT DISTINCT INTO "nl:"
    c.ext_m_event_id
    FROM charge_event c
    WHERE c.accession=patstring(accession)
    DETAIL
     count = (count+ 1), stat = alterlist(diag_request->master_list,count), diag_request->
     master_list[count].master_event_id = c.ext_m_event_id
    WITH nocounter
   ;end select
   SET diag_request->master_qual = count
   CALL echo("GetByAccession - End")
 END ;Subroutine
 SUBROUTINE getbyorder(dummy)
   CALL echo("GetByOrder - Begin")
   SET order_id = 0
   CALL box(5,40,10,70)
   CALL text(6,48,"Enter Order ID")
   CALL line(7,40,31,xhor)
   CALL accept(8,50,"9999999999")
   SET order_id = curaccept
   CALL video(b)
   CALL text(17,30,"**PROCESSING**")
   CALL video(n)
   SET count = 0
   SELECT INTO "nl:"
    c.ext_m_event_id
    FROM charge_event c
    WHERE c.order_id=order_id
    DETAIL
     count = (count+ 1), stat = alterlist(diag_request->master_list,count), diag_request->
     master_list[count].master_event_id = c.ext_m_event_id
    WITH nocounter
   ;end select
   SET diag_request->master_qual = count
   CALL echo("GetByOrder - End")
 END ;Subroutine
 SUBROUTINE getbypersondate(dummy)
   CALL echo("GetByPersonDate - Begin")
   SET last_name = fillstring(20," ")
   SET first_name = fillstring(20," ")
   SET person_id = fillstring(17," ")
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
   SET help = pos(11,10,10,60)
   SET help =
   SELECT INTO "nl:"
    p.person_id"###############;L", p.name_full_formatted
    FROM person p
    WHERE p.name_last_key=patstring(last_name)
     AND p.name_first_key=patstring(first_name)
    ORDER BY p.name_last_key, p.name_first_key
    WITH nocounter
   ;end select
   CALL accept(11,51,"XXXXXXXXXXXXXXXX;;CUF")
   SET person_id = curaccept
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
   CALL accept(11,51,"NNDXXXDNNNNDNNDNN;CU",format(curdate,"DD-MMM-YYYY HH:MM;;D"))
   SET beg_date = curaccept
   CALL accept(12,51,"NNDXXXDNNNNDNNDNN;CU",format(curdate,"DD-MMM-YYYY HH:MM;;D"))
   SET end_date = curaccept
   CALL video(b)
   CALL text(17,30,"**PROCESSING**")
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
    DETAIL
     count = (count+ 1), stat = alterlist(diag_request->master_list,count), diag_request->
     master_list[count].master_event_id = c.ext_m_event_id
    WITH nocounter
   ;end select
   SET diag_request->master_qual = count
   CALL echo("GetByPersonDate - End")
 END ;Subroutine
 SUBROUTINE selectmenu(dummy)
   SET choice = 0
   SET go_back = "N"
   SET diag_request->master_qual = 0
   WHILE (go_back="N")
     FOR (num = 1 TO 15)
       CALL clear(num,1,80)
     ENDFOR
     CALL box(1,1,15,80)
     CALL line(4,1,80,xhor)
     CALL text(2,29,"AFC SERVER DIAGNOSTICS")
     CALL text(6,5,"1.  Master Event ID")
     CALL text(7,5,"2.  Accession Number")
     CALL text(8,5,"3.  Order ID")
     CALL text(9,5,"4.  Person/Date Range")
     CALL text(10,5,"5.  Previous Menu")
     CALL accept(12,15,"9")
     SET choice = curaccept
     CASE (choice)
      OF 1:
       CALL getbymaster("INTEXT")
      OF 2:
       CALL getbyaccession("INTEXT")
      OF 3:
       CALL getbyorder("INTEXT")
      OF 4:
       CALL getbypersondate("INTEXT")
      ELSE
       SET go_back = "Y"
     ENDCASE
     IF (go_back="N"
      AND choice > 0
      AND choice < 5
      AND (diag_request->master_qual > 0))
      IF (main_choice=1)
       EXECUTE afc_master
      ELSE
       EXECUTE afc_srv_diagnostics_rpt
      ENDIF
     ELSEIF ((diag_request->master_qual=0)
      AND choice > 0
      AND choice < 5)
      CALL video(b)
      CALL text(17,15,"SORRY***No charge event information found for that item")
      CALL video(n)
      CALL pause(5)
      CALL clear(17,1,80)
     ENDIF
   ENDWHILE
 END ;Subroutine
 SET main_choice = 0
 SET quit = "N"
 WHILE (quit="N")
   FOR (num = 1 TO 15)
     CALL clear(num,1,80)
   ENDFOR
   CALL box(1,1,15,80)
   CALL line(4,1,80,xhor)
   CALL text(2,29,"AFC SERVER DIAGNOSTICS")
   CALL text(6,5,"1.  Afc Master")
   CALL text(7,5,"2.  Server Diagnostics")
   CALL text(8,5,"3.  Quit")
   CALL accept(12,15,"9")
   SET main_choice = curaccept
   IF (main_choice > 0
    AND main_choice < 3)
    CALL selectmenu("INTEXT")
   ELSE
    SET quit = "Y"
   ENDIF
 ENDWHILE
 FOR (num = 1 TO 15)
   CALL clear(num,1,80)
 ENDFOR
 FREE SET diag_request
END GO
