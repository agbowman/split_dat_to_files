CREATE PROGRAM dba_create_v500_40
 SET message = window
 SET env_id = request->environment_id
 SET dbname = request->database_name
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET target_os = request->target_os
 SET owner = fillstring(20," ")
 SET owner_name = fillstring(20," ")
 CALL text(23,05,"Creating directories...")
 CALL pause(3)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL vms_create_directory(1)
 ELSEIF (target_os="AIX")
  CALL aix_create_directory(1)
 ELSE
  SET failed = "T"
  SET error_message = "unknown os"
  GO TO exit_script
 ENDIF
 CALL clear(23,05,74)
 SUBROUTINE vms_create_directory(x)
   SET dbdisk = request->database_disk
   SET dbname = request->database_name
   SET dbstr = request->root_dir_name
   SET dbdir = request->rdb_directory
   SET archivedisk = request->archive_disk
   SET nodename = request->node
   SET logical ddd "sys$login"
   SET disk_cnt = 0
   SET row_cnt = 1
   SELECT INTO "nl:"
    dcnt = count(*)
    FROM dm_env_disk_farm d
    WHERE environment_id=env_id
    DETAIL
     disk_cnt = dcnt
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   IF (disk_cnt=0)
    SET failed = "T"
    SET exit_message = concat("ERROR: No disks found for the environment!  ",
     "Run Database Option 2 to assign disks to the environment.  Exit...")
    GO TO exit_script
   ENDIF
   SET filename = fillstring(25," ")
   SET filename = "sys$login:get_uic_com.com"
   SELECT INTO trim(filename)
    *
    FROM dummyt
    DETAIL
     col 0, "$ define/job/nolog var_uic 'F$USER()'", row + 1,
     col 0, "$ exit"
    WITH noheading, noformfeed, nocounter,
     maxcol = 132, maxrow = 1
   ;end select
   SET status = 0
   FREE SET dclcom
   SET dclcom = "@sys$login:get_uic_com.com"
   SET len = size(trim(dclcom))
   CALL dcl(dclcom,len,status)
   SET owner = logical("var_uic")
   SET owner_name = owner
   SELECT INTO concat("ddd:","dcl_41.com")
    dkname = trim(d.disk_name)
    FROM dm_env_disk_farm d
    WHERE environment_id=env_id
    HEAD REPORT
     col 0, "$ owner_name :=",
     CALL print(cnvtupper(owner_name)),
     row + 1
    DETAIL
     IF (trim(dkname) != trim(dbdisk))
      IF (row_cnt > 1)
       row + 1
      ENDIF
      row_cnt = (row_cnt+ 1), col 0, "$ CREATE/DIR ",
      CALL print(trim(dkname)), ":[",
      CALL print(cnvtupper(trim(dbstr))),
      ".DB_",
      CALL print(cnvtupper(trim(dbname))), "]",
      row + 1, col 0, "$ SET FILE /OWNER=",
      CALL print("'"), "owner_name ",
      CALL print(trim(dkname)),
      ":[",
      CALL print(cnvtupper(trim(dbstr))), "]DB_",
      CALL print(cnvtupper(trim(dbname))), ".DIR"
     ENDIF
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SELECT INTO concat("ddd:","dcl_41.com")
    *
    FROM dummyt
    DETAIL
     col 0, "$ CREATE/DIR ",
     CALL print(cnvtupper(trim(dbdisk))),
     ":[",
     CALL print(cnvtupper(trim(dbstr))), ".DB_",
     CALL print(cnvtupper(trim(dbname))), "]", row + 1,
     col 0, "$ SET FILE /OWNER=",
     CALL print("'"),
     "owner_name ",
     CALL print(cnvtupper(trim(dbdisk))), ":[",
     CALL print(cnvtupper(trim(dbstr))), "]DB_",
     CALL print(cnvtupper(trim(dbname))),
     ".DIR", row + 1, col 0,
     "$ CREATE/DIR ",
     CALL print(cnvtupper(trim(dbdisk))), ":[",
     CALL print(cnvtupper(trim(dbstr))), ".DB_",
     CALL print(cnvtupper(trim(dbname))),
     ".TRACE]", row + 1, col 0,
     "$ CREATE/DIR ",
     CALL print(cnvtupper(trim(archivedisk))), ":[",
     CALL print(cnvtupper(trim(dbstr))), ".DB_",
     CALL print(cnvtupper(trim(dbname))),
     ".ARC]"
     IF (trim(dbdisk) != trim(archivedisk))
      row + 1, col 0, "$ CREATE/DIR ",
      CALL print(cnvtupper(trim(archivedisk))), ":[",
      CALL print(cnvtupper(trim(dbstr))),
      ".DB_",
      CALL print(cnvtupper(trim(dbname))), ".TRACE]"
     ENDIF
    WITH nocounter, format = stream, append,
     noheading, formfeed = none, maxrow = 1
   ;end select
   SET dclstr40_1 = concat("@","ddd:","DCL_41.COM")
   SET len40_1 = size(dclstr40_1)
   SET status40_1 = 0
   CALL dcl(dclstr40_1,len40_1,status40_1)
 END ;Subroutine
 SUBROUTINE aix_create_directory(x)
   SET home_dir = logical("HOME")
   SET ora_mtpt = request->orasecmtpt
   SET cer_mtpt = request->cermtpt
   SET ora_link_dir = concat(ora_mtpt,"/oralink/",cnvtlower(dbname))
   SET ora_admin_dir = concat(ora_mtpt,"/oracle/admin/",cnvtlower(dbname))
   SELECT INTO concat("/tmp/",cnvtlower(dbname),"_crt_dir.ksh")
    *
    FROM dummyt
    DETAIL
     col 1, "#!/usr/bin/ksh", row + 1,
     col 1, "mkdir -p ",
     CALL print(ora_link_dir),
     row + 1, col 1, "mkdir -p ",
     CALL print(ora_admin_dir), "/arch", row + 1,
     col 1, "mkdir -p ",
     CALL print(ora_admin_dir),
     "/bdump/",
     CALL print(cnvtlower(dbname)), "1",
     row + 1, col 1, "mkdir -p ",
     CALL print(ora_admin_dir), "/cdump/",
     CALL print(cnvtlower(dbname)),
     "1", row + 1, col 1,
     "mkdir -p ",
     CALL print(ora_admin_dir), "/create",
     row + 1, col 1, "mkdir -p ",
     CALL print(ora_admin_dir), "/exp", row + 1,
     col 1, "mkdir -p ",
     CALL print(ora_admin_dir),
     "/pfile", row + 1, col 1,
     "mkdir -p ",
     CALL print(ora_admin_dir), "/udump/",
     CALL print(cnvtlower(dbname)), "1", row + 1,
     col 1, "chown -R oracle:dba ",
     CALL print(ora_admin_dir),
     row + 1, col 1, "mkdir -p ",
     CALL print(cer_mtpt), "/w_standard/",
     CALL print(cnvtlower(dbname)),
     "/dba", row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET dclstr40_2 = concat("chmod 744 ","/tmp/",cnvtlower(dbname),"_crt_dir.ksh")
   SET len40_2 = size(dclstr40_2)
   SET status40_2 = 0
   CALL dcl(dclstr40_2,len40_2,status40_2)
   SET dclstr40_1 = concat("/tmp/",cnvtlower(dbname),"_crt_dir.ksh")
   SET len40_1 = size(dclstr40_1)
   SET status40_1 = 0
   CALL dcl(dclstr40_1,len40_1,status40_1)
   SET dclstr40_3 = concat("cp /tmp/",cnvtlower(dbname),"_users_script.sql ",cer_mtpt,"/w_standard/",
    cnvtlower(dbname),"/dba/create_users.sql")
   SET len40_3 = size(dclstr40_3)
   SET status40_3 = 0
   CALL dcl(dclstr40_3,len40_3,status40_3)
   SET dclstr40_4 = concat("cp /tmp/",cnvtlower(dbname),"_users_script2.sql ",cer_mtpt,"/w_standard/",
    cnvtlower(dbname),"/dba/create_users2.sql")
   SET len40_4 = size(dclstr40_4)
   SET status40_4 = 0
   CALL dcl(dclstr40_4,len40_4,status40_4)
   SET dclstr40_5 = concat("cp /tmp/",cnvtlower(dbname),"_users_script3.sql ",cer_mtpt,"/w_standard/",
    cnvtlower(dbname),"/dba/create_users3.sql")
   SET len40_5 = size(dclstr40_5)
   SET status40_5 = 0
   CALL dcl(dclstr40_5,len40_5,status40_5)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status = "F"
  SET reply->error_message = exit_message
 ELSE
  SET reply->status = "S"
  SET reply->error_message = ""
 ENDIF
END GO
