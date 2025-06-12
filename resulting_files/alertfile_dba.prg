CREATE PROGRAM alertfile:dba
 SET com = fillstring(250," ")
 IF (((cursys="VMS") OR (cursys="AXP")) )
  SELECT INTO "alertmon_delete_file.com"
   d.seq
   FROM (dummyt d  WITH seq = 1)
   HEAD REPORT
    col 0, '$ savemessage = f$environment("message")', row + 1,
    col 0, "$ set message /nofacitlity/noidentification/noseverity/notext", row + 1,
    command_line = concat("$ delete ",trim(curuser),"_alertmon.out;*"), col 0, command_line,
    row + 1, col 0, "$ set message 'savemessage'"
   WITH nocounter, noformfeed, maxrow = 1
  ;end select
  SET com = "@ccluserdir:alertmon_delete_file.com                            "
  CALL dcl(trim(com),size(trim(com)),0)
  SET com = "$ delete ccluserdir:alertmon_delete_file.com;                  "
  CALL dcl(trim(com),size(trim(com)),0)
 ENDIF
 FOR (i = 1 TO num)
   SET dir_name = fillstring(100," ")
   SET dir_name = dir_rec->qual[i].new_path
   SET com = fillstring(250," ")
   IF (cursys="AIX")
    IF (i=1)
     SET com = concat("ls -1 ",trim(dir_name),"/alert_*.log >","/tmp/",trim(curuser),
      "_alertmon.out")
    ELSE
     SET com = concat("ls -1 ",trim(dir_name),"/alert_*.log >>","/tmp/",trim(curuser),
      "_alertmon.out")
    ENDIF
    SET output_file = concat("/tmp/",trim(curuser),"_alertmon.out")
   ENDIF
   IF (((cursys="VMS") OR (cursys="AXP")) )
    SET com = concat("$dir/columns=1/noheading/notrailing ",trim(dir_name),"*alert.log/output=",trim(
      curuser),"_alertmon.out")
    SET output_file = concat(trim(curuser),"_alertmon.out;1")
    SET logical aaa output_file
   ENDIF
   CALL dcl(com,size(trim(com)),0)
   IF (i != 1)
    SET com = fillstring(250," ")
    IF (((cursys="VMS") OR (cursys="AXP")) )
     SET com = concat("$append  ",trim(curuser),"_alertmon.out;"," ",trim(curuser),
      "_alertmon.out;1")
     CALL dcl(com,size(trim(com)),0)
     SET com = fillstring(250," ")
     IF (i != 1)
      SET com = concat("$delete ",trim(curuser),"_alertmon.out;")
      CALL dcl(com,size(trim(com)),0)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET logical aaa value(output_file)
 FREE DEFINE rtl
 DEFINE rtl "aaa"
 SET noflines = 0
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  DETAIL
   noflines = (noflines+ 1)
  WITH nocounter
 ;end select
 SET cntr = 0
 SELECT INTO "nl:"
  new_line = r.line
  FROM rtlt r
  HEAD REPORT
   stat = alterlist(rec1->qual,10)
  DETAIL
   cntr = (cntr+ 1)
   IF (mod(cntr,10)=1
    AND cntr != 1)
    stat = alterlist(rec1->qual,(cntr+ 9))
   ENDIF
   rec1->qual[cntr].new_line = trim(new_line), rec1->qual[cntr].trace_file = fillstring(100," ")
  FOOT REPORT
   stat = alterlist(rec1->qual,cntr)
  WITH nocounter
 ;end select
 FOR (i = 1 TO cntr)
   FOR (j = 1 TO num)
     SET found = 0
     SET found = findstring(cnvtupper(dir_rec->qual[j].new_path),cnvtupper(rec1->qual[i].new_line),1)
     IF (found > 0)
      SET rec1->qual[i].trace_file = dir_rec->qual[j].new_path
     ENDIF
   ENDFOR
 ENDFOR
 SET nof_keys = 0
 SELECT INTO "nl:"
  d.*
  FROM dba_alertmon_paths d
  WHERE d.group_no=mgid
  HEAD REPORT
   nof_keys = 0
  DETAIL
   nof_keys = (nof_keys+ 1), stat = alterlist(service->qual,nof_keys), service->qual[nof_keys].key_no
    = d.key_no,
   service->qual[nof_keys].path = d.path
  WITH nocounter
 ;end select
 SET nof_slas = 0
 FOR (i = 1 TO nof_keys)
   SELECT INTO "nl:"
    d.*
    FROM dba_alertmon_pathservices d
    WHERE (d.key_no=service->qual[i].key_no)
    HEAD REPORT
     nof_slas = 0
    DETAIL
     nof_slas = (nof_slas+ 1), stat = alterlist(service->qual[i].qual,nof_slas), service->qual[i].
     qual[nof_slas].sla_no = d.sla_no
    WITH nocounter
   ;end select
   SET service->qual[i].nof_slas = nof_slas
   FOR (j = 1 TO nof_slas)
     SELECT INTO "nl:"
      d.*
      FROM dba_service_time d
      WHERE (d.sla_no=service->qual[i].qual[j].sla_no)
      DETAIL
       service->qual[i].qual[j].st_time = cnvtint(d.start_time), service->qual[i].qual[j].end_time =
       cnvtint(d.end_time), service->qual[i].qual[j].interval = d.interval,
       service->qual[i].qual[j].nof_types = 0
      WITH nocounter
     ;end select
     SET nof_types = 0
     FOR (k = 1 TO nof_slas)
       SELECT INTO "nl:"
        d.*
        FROM dba_service_type d
        WHERE (d.sla_no=service->qual[i].qual[j].sla_no)
        HEAD REPORT
         nof_types = 0
        DETAIL
         nof_types = (nof_types+ 1), stat = alterlist(service->qual[i].qual[j].qual,nof_types),
         service->qual[i].qual[j].qual[nof_types].address = d.address,
         service->qual[i].qual[j].qual[nof_types].type = d.type, service->qual[i].qual[j].qual[
         nof_types].cc_flag = d.cc_flag, service->qual[i].qual[j].nof_types = nof_types
        WITH nocounter
       ;end select
     ENDFOR
   ENDFOR
 ENDFOR
 IF (((cursys="VMS") OR (cursys="AXP")) )
  SET com = concat("$delete ",trim(curuser),"_alertmon.out;")
 ENDIF
 CALL dcl(trim(com),size(trim(com)),0)
 SET message = window
 CALL clear(1,1)
 SET message = nowindow
END GO
