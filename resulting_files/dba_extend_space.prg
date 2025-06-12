CREATE PROGRAM dba_extend_space
 PAINT
 SUBROUTINE display_screen(x)
   CALL video(r)
   CALL box(1,1,22,80)
   CALL box(1,1,4,80)
   CALL clear(2,2,78)
   CALL text(02,25," ***  DBA  EXTEND  SPACE  *** ")
   CALL clear(3,2,78)
   CALL video(n)
   CALL text(06,05,"DATABASE: ")
   CALL text(06,25,trim(ext_space_req->database_name))
   CALL text(07,05,"Tablespace name: ")
   CALL text(08,05,"Disk name: ")
   CALL text(7,50,"File Size: ")
   IF (((cursys="VMS") OR (cursys="AXP")) )
    CALL text(07,73,"Bytes")
   ELSE
    CALL text(07,77,"M")
   ENDIF
   IF (((cursys="AIX") OR (cursys="UNIX")) )
    CALL text(06,50,"Partition Size: ")
    CALL text(06,69,"M")
    CALL text(9,05,"Volume Group: ")
    CALL text(9,35,"Link directory: ")
   ENDIF
 END ;Subroutine
 SUBROUTINE ask_continue(y)
   CALL clear(24,05,74)
   CALL text(24,05,"Continue(Y/N)?")
   CALL accept(24,20,"P;CU","N")
   SET ext_space_req->continue = curaccept
 END ;Subroutine
 SUBROUTINE ask_confirm(x)
   CALL clear(23,05,74)
   CALL clear(24,05,74)
   CALL text(23,05,"Please confirm the above information before continue.")
   CALL text(23,60,"continue(Y/N)?")
   CALL accept(23,75,"P;CU","N")
   SET ext_space_req->continue = curaccept
 END ;Subroutine
 SUBROUTINE display_tspace_info(x)
   SET x = 10
   WHILE (x < 22)
    CALL clear(x,2,77)
    SET x = (x+ 1)
   ENDWHILE
   SET cnt = 0
   SELECT INTO "nl:"
    f_name = trim(a.file_name), f_size = a.bytes
    FROM dba_data_files a
    WHERE a.tablespace_name=patstring(ext_space_req->tablespace)
    ORDER BY a.file_id
    HEAD REPORT
     CALL text(10,5,"  file(s):")
    DETAIL
     cnt = (cnt+ 1),
     CALL text((10+ cnt),7,concat(nullterm(cnvtstring(cnt)),". ",nullterm(f_name)," SIZE ",cnvtstring
      (f_size)))
    FOOT REPORT
     CALL text((11+ cnt),5,"New datafile:")
     IF (((cursys="VMX") OR (cursys="AXP")) )
      CALL text((12+ cnt),10,concat(nullterm(ext_space_req->new_file_name)," SIZE ",nullterm(
        cnvtstring(ext_space_req->new_file_size))))
     ELSE
      CALL text((12+ cnt),10,concat(nullterm(ext_space_req->new_file_name)," SIZE ",nullterm(
        cnvtstring(((ext_space_req->new_file_size * 1024) * 1024)))))
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
 END ;Subroutine
 RECORD ext_space_req(
   1 tablespace = c25
   1 disk = c15
   1 database_name = c5
   1 continue = c1
   1 space_available = i4
   1 new_file_name = c70
   1 new_file_size = i4
   1 volume_group = c10
   1 link_dir = c27
   1 pp_num = i4
 )
 SET ext_space_req->database_name = "     "
 SELECT INTO dummyt
  a.name
  FROM v$database a
  DETAIL
   ext_space_req->database_name = a.name
  WITH nocounter
 ;end select
 CALL clear(1,1)
 CALL display_screen(1)
#ts_name
 CALL clear(23,05,74)
 CALL clear(24,05,74)
 CALL text(23,05,"HELP: Press <SHIFT><F5> ")
 SET help =
 SELECT DISTINCT INTO "nl:"
  a.tablespace_name
  FROM dba_data_files a
  WITH nocounter
 ;end select
 CALL accept(07,25,"PPPPPPPPPPPPPPPPPPPPPPPPP;CUS")
 SET ext_space_req->tablespace = curaccept
 WHILE ((ext_space_req->tablespace="                             "))
   CALL text(23,05,"tablespace name required...")
   CALL pause(3)
   CALL accept(07,25,"PPPPPPPPPPPPPPPPPPPPPPPPP;CUS")
   SET ext_space_req->tablespace = curaccept
 ENDWHILE
 CALL clear(23,05,74)
 SET file_count = 0
 SET file_size = 0
 SELECT INTO "nl:"
  a.file_name, a.bytes
  FROM dba_data_files a
  WHERE a.tablespace_name=patstring(ext_space_req->tablespace)
  ORDER BY a.file_id
  HEAD REPORT
   file_count = 0
  DETAIL
   file_count = (file_count+ 1), file_size = a.bytes
  WITH nocounter, format = stream, noheading,
   formfeed = none, maxrow = 1
 ;end select
 IF (file_count=0)
  CALL text(23,05,"tablespace not found...")
  CALL ask_continue(1)
  IF ((ext_space_req->continue="Y"))
   GO TO ts_name
  ELSE
   GO TO endprogram
  ENDIF
 ELSE
  SET file_count = (file_count+ 1)
 ENDIF
#disk_name
 IF (((cursys="VMS") OR (cursys="AXP")) )
  CALL vms_process_disk(1)
 ELSE
  CALL unix_process_disk(1)
 ENDIF
 CALL display_tspace_info(1)
 CALL ask_confirm(1)
 IF ((ext_space_req->continue="Y"))
  IF (((cursys="AIX") OR (cursys="UNIX")) )
   CALL unix_create_raw_device(1)
   SET sql_string = concat("rdb alter tablespace ",trim(ext_space_req->tablespace)," add datafile ",
    "'",trim(ext_space_req->new_file_name),
    "' SIZE ",nullterm(cnvtstring(ext_space_req->new_file_size)),"M go")
  ELSE
   SET sql_string = concat("rdb alter tablespace ",trim(ext_space_req->tablespace)," add datafile ",
    "'",trim(ext_space_req->new_file_name),
    "' SIZE ",cnvtstring(ext_space_req->new_file_size)," go")
  ENDIF
  CALL parser(sql_string)
 ELSE
  GO TO endprogram
 ENDIF
 SUBROUTINE vms_process_disk(x)
   CALL clear(23,05,74)
   CALL clear(24,05,74)
   CALL accept(8,25,"PPPPPPPPPPPPPPP;CU")
   SET ext_space_req->disk = curaccept
   WHILE ((ext_space_req->disk="               "))
     CALL text(23,05,"disk name required...")
     CALL pause(1)
     CALL accept(08,25,"PPPPPPPPPPPPPPP;CU")
     SET ext_space_req->disk = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   SET ext_space_req->space_available = 0
   SET t_status = 0
   CALL uar_get_disk_space(nullterm(ext_space_req->disk),"B","F",ext_space_req->space_available,
    t_status)
   IF (t_status > 0)
    CALL text(23,05,concat("Error occurs with device ",trim(ext_space_req->disk)))
    CALL ask_continue(1)
    IF ((ext_space_req->continue="Y"))
     SET aaa = 1
     GO TO disk_name
    ELSE
     GO TO endprogram
    ENDIF
   ENDIF
   CALL clear(23,05,74)
   CALL clear(24,05,74)
   CALL accept(7,60,"9999999999",file_size)
   SET ext_space_req->new_file_size = curaccept
   WHILE ((ext_space_req->new_file_size=0))
     CALL text(23,05,"file size required...")
     CALL pause(1)
     CALL accept(07,60,"9999999999")
     SET ext_space_req->new_file_size = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   SET ext_space_req->new_file_name = concat(nullterm(ext_space_req->disk),":[V500.DB_",nullterm(
     ext_space_req->database_name),"]",nullterm(ext_space_req->tablespace),
    "_",format(file_count,"###;p0"),".DBS")
 END ;Subroutine
 SUBROUTINE unix_process_disk(x)
   SET pp_size = 0
   CALL clear(23,05,74)
   CALL clear(24,05,74)
   CALL accept(8,25,"PPPPPPPPPPPPPPP;CL")
   SET ext_space_req->disk = curaccept
   WHILE ((ext_space_req->disk="               "))
     CALL text(23,05,"disk name required...")
     CALL pause(1)
     CALL accept(08,25,"PPPPPPPPPPPPPPP;CL")
     SET ext_space_req->disk = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   CALL accept(9,19,"PPPPPPPPPP;CL")
   SET ext_space_req->volume_group = curaccept
   WHILE ((ext_space_req->volume_group="          "))
     CALL text(23,05,"volume group required...")
     CALL pause(1)
     CALL accept(9,19,"PPPPPPPPPP;CL")
     SET ext_space_req->volume_group = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   CALL accept(6,66,"99")
   SET pp_size = curaccept
   WHILE (pp_size=0)
     CALL text(23,05,"Partiton size required...")
     CALL pause(1)
     CALL accept(6,66,"99")
     SET pp_size = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   CALL accept(7,66,"9999999999",(file_size/ (1024 * 1024)))
   SET ext_space_req->new_file_size = curaccept
   WHILE (mod((ext_space_req->new_file_size+ 1),8) != 0)
     IF ((ext_space_req->new_file_size=0))
      CALL text(23,05,"file size required...")
     ELSE
      CALL text(23,05,"file size should be 1M less than the mutiple of the partition size")
     ENDIF
     CALL pause(1)
     CALL accept(07,66,"9999999999")
     SET ext_space_req->new_file_size = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   CALL accept(9,50,"PPPPPPPPPPPPPPPPPPPPPPPPPPP;CL")
   SET ext_space_req->link_dir = curaccept
   WHILE ((ext_space_req->link_dir="                           "))
     CALL text(23,05,"link directory  required...")
     CALL pause(1)
     CALL accept(9,50,"PPPPPPPPPP;CL")
     SET ext_space_req->link_dir = curaccept
   ENDWHILE
   CALL clear(23,05,74)
   SET unix_file_size = (ext_space_req->new_file_size+ 1)
   SET ext_space_req->pp_num = (unix_file_size/ pp_size)
   SET raw_device_name1 = trim(concat("/dev/r",trim(nullterm(cnvtlower(ext_space_req->database_name))
      ),"_",format(unix_file_size,"####;p0"),"_"))
   SET pos = 0
   SET max_seq = 0
   SET t_seq = 0
   SET t_len = (size(trim(raw_device_name1))+ 1)
   SELECT INTO "nl:"
    a.member
    FROM v$logfile a
    ORDER BY a.member
    DETAIL
     pos = findstring(nullterm(raw_device_name1),a.member)
     IF (pos > 0)
      t_seq = cnvtint(substring(t_len,3,a.member))
      IF (t_seq > max_seq)
       max_seq = t_seq
      ENDIF
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO "nl:"
    a.name
    FROM v$controlfile a
    ORDER BY a.name
    DETAIL
     pos = findstring(nullterm(raw_device_name1),a.name)
     IF (pos > 0)
      t_seq = cnvtint(substring(t_len,3,a.name))
      IF (t_seq > max_seq)
       max_seq = t_seq
      ENDIF
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO "nl:"
    a.file_name
    FROM dba_data_files a
    ORDER BY a.file_name
    DETAIL
     pos = findstring(nullterm(raw_device_name1),a.file_name)
     IF (pos > 0)
      t_seq = cnvtint(substring(t_len,3,a.file_name))
      IF (t_seq > max_seq)
       max_seq = t_seq
      ENDIF
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET ext_space_req->new_file_name = concat(nullterm(raw_device_name1),format((max_seq+ 1),"###;p0")
    )
 END ;Subroutine
 SUBROUTINE unix_create_raw_device(x)
   DECLARE returntext = vc
   DECLARE returnstat = i4
   DECLARE mwc_switch = vc
   IF (findfile("dba_extend_space_lqueryvg.log")=1)
    SET stat = remove("dba_extend_space_lqueryvg.log")
    CALL echo(build("Removing dba_extend_space_lqueryvg.log",stat))
   ENDIF
   SET cmd = concat("lqueryvg -p /dev/",ext_space_req->disk," -X > dba_extend_space_lqueryvg.log")
   CALL dcl(cmd,size(cmd),returnstat)
   FREE DEFINE rtl
   DEFINE rtl value("dba_extend_space_lqueryvg.log")
   SELECT INTO "nl:"
    r.*
    FROM rtlt r
    DETAIL
     returntext = trim(r.line)
    WITH nocounter, maxcol = 255
   ;end select
   IF (returntext="0")
    SET mwc_switch = "-w y "
   ELSE
    SET mwc_switch = "-w n "
   ENDIF
   SET t_len = size(nullterm(ext_space_req->new_file_name))
   SELECT INTO "/tmp/t_extend_space.ksh"
    *
    FROM dummyt
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "if [[ `whoami` != ",
     CALL print('"'),
     "root",
     CALL print('"'), " ]]",
     row + 1, col 0, "then",
     row + 1, col 0, "  echo ",
     CALL print('"'), "you must be root to execute this script",
     CALL print('"'),
     row + 1, col 0, "  echo ",
     CALL print('"'), "Exiting script...",
     CALL print('"'),
     row + 1, col 0, "  exit 1",
     row + 1, col 0, "fi",
     row + 1, col 0, "mklv -y ",
     CALL print("'"),
     CALL print(substring(7,(t_len - 6),nullterm(ext_space_req->new_file_name))),
     CALL print("' "),
     CALL print(mwc_switch), " -t ",
     CALL print("'"),
     "raw",
     CALL print("' "),
     CALL print(nullterm(ext_space_req->volume_group)),
     " ",
     CALL print(nullterm(cnvtstring(ext_space_req->pp_num))), " ",
     CALL print(ext_space_req->disk), row + 1, col 0,
     "chmod 600 ",
     CALL print(ext_space_req->new_file_name), row + 1,
     col 0, "chown oracle.dba ",
     CALL print(ext_space_req->new_file_name),
     row + 1, col 0, "ln -s ",
     CALL print(nullterm(ext_space_req->new_file_name)), " ",
     CALL print(nullterm(ext_space_req->link_dir)),
     "/",
     CALL print(nullterm(cnvtlower(ext_space_req->tablespace))), file_count"###;p0",
     row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET dcl_unix_string1 = "chmod 777 /tmp/t_extend_space.ksh"
   SET dcl_unix_len1 = size(dcl_unix_string1)
   SET dcl_unix_status1 = 0
   CALL dcl(dcl_unix_string1,dcl_unix_len1,dcl_unix_status1)
   SET dcl_unix_string2 = ". /tmp/t_extend_space.ksh"
   SET dcl_unix_len2 = size(dcl_unix_string2)
   SET dcl_unix_status2 = 0
   CALL dcl(dcl_unix_string2,dcl_unix_len2,dcl_unix_status2)
 END ;Subroutine
#endprogram
 CALL clear(23,05,74)
 CALL clear(24,05,74)
END GO
