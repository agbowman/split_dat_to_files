CREATE PROGRAM dba_create_v500_db:dba
 SET message = window
 FREE SET request
 RECORD request(
   1 environment_id = i4
   1 database_name = vc
   1 database_disk = vc
   1 root_dir_name = vc
   1 target_os = vc
   1 archive_disk = vc
   1 volume_group = vc
   1 rdb_directory = vc
   1 arc_directory = vc
   1 node = vc
   1 v500_username = vc
   1 v500_password = vc
   1 orasecmtpt = vc
   1 oraprimtpt = vc
   1 oracleversion = vc
   1 cermtpt = vc
   1 partitionsize = i4
   1 vms_ora_root = vc
   1 vms_oracle_home = vc
   1 rdbms_ver = vc
   1 oracle_home = vc
   1 cer_install = vc
 )
 FREE SET reply
 RECORD reply(
   1 status = c1
   1 error_message = vc
 )
 SET reply->status = "F"
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET current_sys = fillstring(3," ")
 CALL screen_0(1)
 SET env_name = fillstring(20," ")
 SET env_name =  $1
#enter_env_name
 SET t_curqual = 0
 CALL text(6,5,"ENVIRONMENT NAME: ")
 CALL text(6,24,env_name)
 CALL fetch_admin(1)
 SET t_curqual = curqual
 IF (t_curqual=0)
  CALL text(23,05,"Can't find that environment name in ADMIN.")
  CALL text(23,50,"Continue(Y/N)?")
  CALL accept(23,65,"X;CU","N")
 ELSE
  CALL text(7,5,concat("DATABASE NAME: ",trim(request->database_name)))
  CALL text(8,5,concat("OPERATING SYSTEM: ",trim(request->target_os)))
 ENDIF
 IF (t_curqual != 1)
  SET continue = cnvtupper(curaccept)
  IF (continue="Y")
   CALL clear(7,50,28)
   CALL clear(8,50,28)
   CALL clear(23,02,78)
   CALL clear(24,02,78)
   SET env_name = fillstring(20," ")
   CALL text(10,05,"Enter environment name:")
   CALL accept(10,30,"P(20);CU")
   SET env_name = curaccept
   CALL clear(10,05,70)
   GO TO enter_env_name
  ELSE
   SET failed = "T"
   SET exit_message = "Exit..."
   GO TO exit_script
  ENDIF
 ENDIF
 CALL line(9,2,78)
 IF (cursys="AXP")
  SET current_sys = "VMS"
 ELSE
  SET current_sys = cursys
 ENDIF
 IF ((current_sys != request->target_os))
  SET failed = "T"
  SET exit_message = "Database target os doen't match current os.  Exit..."
  GO TO exit_script
 ENDIF
#get_rdbms_ver
 DECLARE string = vc WITH public, noconstant(" ")
 IF ((((request->target_os="VMS")) OR ((request->target_os="AXP"))) )
  SET request->rdbms_ver = dm_env_import_request->target_rdbms_version
 ENDIF
 IF ((((request->target_os="VMS")) OR ((request->target_os="AXP"))) )
  SET t_node = fillstring(40," ")
  SET t_status = 0
  CALL uar_get_nodename(t_node,t_status)
  SET request->node = trim(t_node)
  SET request->vms_ora_root = logical("ora_root")
  SET request->vms_oracle_home = logical("ORACLE_HOME")
  IF ((request->vms_ora_root <= " "))
   CALL text(10,5,"Please specify ORACLE ROOT.  Press return to accept default.")
   CALL accept(11,05,"P(40);CUS","RDBMS_ORA:[A_ORACLE.ORACLEV817.]")
   SET request->vms_ora_root = nullterm(curaccept)
   CALL clear(10,5,70)
   CALL clear(11,5,70)
  ENDIF
  SELECT INTO concat("sys$login:","run_orauser",".com")
   *
   FROM dummyt
   DETAIL
    col 0, "$! Run Orauser", row + 1,
    col 0, "$ set noon"
    IF ((dm_env_import_request->base_oracle_version="8"))
     string = concat("$@",value(trim(request->vms_ora_root)),"[util]orauser.com")
    ELSE
     string = concat("$@",value(trim(request->vms_oracle_home)),"orauser.com")
    ENDIF
    row + 1, col 0, string,
    row + 1, col 0, "$ exit"
   WITH noformfeed, maxcol = 80, maxrow = 1,
    nocounter
  ;end select
  SET dclcom3 = "@SYS$LOGIN:run_orauser.com"
  SET len3 = size(dclcom3)
  SET status = 0
  CALL dcl(dclcom3,len3,status)
  CALL pause(2)
  CALL clear(10,2,70)
  CALL clear(11,2,70)
  CALL text(10,5,"Please confirm ORACLE ROOT location below:")
  CALL text(11,05,request->vms_ora_root)
  CALL text(24,05,"Correct Y/N? ")
  CALL accept(24,19,"P;CU"," "
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="N")
   SET failed = "T"
   SET exit_message = "Incorrect value for ORA_ROOT.  Execute correct ORAUSER.COM"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->target_os="AIX"))
  SET aix_node = nullterm(logical("HOST"))
  IF (aix_node=null)
   SET dcl_str = "echo `hostname` > /tmp/tmp_nodename.out"
   SET dcl_len = size(dcl_str)
   SET dcl_sta = 0
   CALL dcl(dcl_str,dcl_len,dcl_sta)
   FREE DEFINE rtl
   DEFINE rtl "/tmp/tmp_nodename.out"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     aix_node = nullterm(r.line)
    WITH nocounter
   ;end select
   FREE DEFINE rtl
  ENDIF
  SET request->node = trim(aix_node)
  SET current_env = logical("environment")
  SET current_home = logical("HOME")
 ELSE
  SET failed = "T"
  SET exit_message = "Unknown target operating system.  Exit..."
  GO TO exit_script
 ENDIF
 IF (cursys != "AXP")
  SET request->oracle_home = logical("ORACLE_HOME")
 ENDIF
 SET request->cer_install = logical("cer_install")
 CALL screen_0(1)
 EXECUTE dba_create_v500_00
 CALL check_reply_status(1)
 IF (cursys="AXP"
  AND (dm_env_import_request->base_oracle_version != "8"))
  EXECUTE dba_create_v500_40
  CALL check_reply_status(1)
 ENDIF
 CALL screen_0(1)
 EXECUTE dba_create_v500_80
 CALL check_reply_status(1)
 EXECUTE dba_create_v500_70
 CALL check_reply_status(1)
 IF ((((request->target_os="AIX")) OR ((dm_env_import_request->base_oracle_version="8"))) )
  EXECUTE dba_create_v500_40
  CALL check_reply_status(1)
 ENDIF
 EXECUTE dba_create_v500_30
 CALL check_reply_status(1)
 EXECUTE dba_create_v500_10
 CALL check_reply_status(1)
 EXECUTE dba_create_v500_20
 CALL check_reply_status(1)
 EXECUTE dba_create_v500_60
 CALL check_reply_status(1)
 IF ((request->target_os="AIX"))
  EXECUTE dba_create_v500_90
  CALL check_reply_status(1)
 ENDIF
 EXECUTE dba_create_v500_50
 CALL check_reply_status(1)
 SUBROUTINE check_reply_status(x)
   IF ((reply->status="F"))
    SET failed = "T"
    SET exit_message = reply->error_message
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE fetch_admin(x)
   SET t_env_id = 0
   SET t_name = fillstring(80," ")
   SET t_disk = fillstring(80," ")
   SET t_dir_name = fillstring(80," ")
   SET t_target_os = fillstring(80," ")
   SET t_archive_disk = fillstring(80," ")
   SET t_volume_group = fillstring(80," ")
   SET t_partition_size = 0
   SET t_connect_string = fillstring(60," ")
   SET t_cerner_mtpt = fillstring(60," ")
   SET t_ora_pri_mtpt = fillstring(60," ")
   SET t_ora_sec_mtpt = fillstring(60," ")
   SET t_oracle_version = fillstring(15," ")
   SET t_pos1 = 0
   SET t_pos2 = 0
   SET t_len = 0
   SELECT INTO "nl:"
    a.environment_id, a.database_name, a.database_disk,
    a.root_dir_name, a.target_operating_system, a.database_archive_disk,
    a.volume_group, a.data_file_partition_size, a.v500_connect_string,
    a.cerner_fs_mtpt, a.ora_pri_fs_mtpt, a.ora_sec_fs_mtpt,
    a.oracle_version
    FROM dm_environment a
    WHERE a.environment_name=env_name
    DETAIL
     t_env_id = a.environment_id, t_name = cnvtupper(a.database_name), t_disk = cnvtupper(a
      .database_disk),
     t_dir_name = cnvtupper(a.root_dir_name), t_target_os = cnvtupper(a.target_operating_system),
     t_archive_disk = cnvtupper(a.database_archive_disk),
     t_volume_group = cnvtupper(a.volume_group), t_partition_size = a.data_file_partition_size,
     t_connect_string = a.v500_connect_string,
     t_cerner_mtpt = a.cerner_fs_mtpt, t_ora_pri_mtpt = a.ora_pri_fs_mtpt, t_ora_sec_mtpt = a
     .ora_sec_fs_mtpt,
     t_oracle_version = a.oracle_version
    WITH nocounter
   ;end select
   SET request->database_name = trim(t_name)
   SET request->database_disk = trim(t_disk)
   SET request->root_dir_name = trim(t_dir_name)
   SET request->environment_id = t_env_id
   SET request->target_os = trim(t_target_os)
   SET request->archive_disk = trim(t_archive_disk)
   SET request->volume_group = trim(t_volume_group)
   SET request->partitionsize = ((t_partition_size * 1024) * 1024)
   SET request->oracleversion = trim(t_oracle_version)
   SET t_pos1 = findstring("/",t_connect_string)
   SET t_pos2 = findstring("@",t_connect_string)
   SET t_len = size(nullterm(t_connect_string))
   SET request->v500_username = substring(1,(t_pos1 - 1),t_connect_string)
   IF (t_pos2=0)
    SET request->v500_password = substring((t_pos1+ 1),(t_len - t_pos1),t_connect_string)
   ELSE
    SET request->v500_password = substring((t_pos1+ 1),((t_pos2 - t_pos1) - 1),t_connect_string)
   ENDIF
   IF ((((request->target_os="VMS")) OR ((request->target_os="AXP"))) )
    SET request->rdb_directory = trim(concat(trim(t_disk),":[",trim(t_dir_name),".DB_",trim(t_name),
      "]"))
    SET request->arc_directory = trim(concat(trim(t_archive_disk),":[",trim(t_dir_name),".DB_",trim(
       t_name),
      ".ARC]"))
   ENDIF
   IF ((request->target_os="AIX"))
    SET request->orasecmtpt = trim(t_ora_sec_mtpt)
    SET request->cermtpt = trim(t_cerner_mtpt)
    SET request->oraprimtpt = trim(t_ora_pri_mtpt)
   ENDIF
 END ;Subroutine
 SUBROUTINE screen_0(x)
   SET width = 80
   CALL video(r)
   CALL clear(1,1)
   CALL box(1,1,22,80)
   CALL box(1,1,4,80)
   CALL clear(2,2,78)
   CALL text(2,14,"*****   HNA MILLENNIUM   CREATE DATABASE   *****")
   CALL clear(3,2,78)
   CALL video(n)
 END ;Subroutine
#exit_script
 CALL clear(23,1,79)
 CALL clear(24,1,79)
 IF (failed="T")
  CALL text(23,5,exit_message)
  CALL pause(2)
 ELSE
  IF ((((request->target_os="VMS")) OR ((request->target_os="AXP"))) )
   CALL text(23,5,concat("Please execute V500_CREATE_",request->database_name,".COM",
     " in SYS$LOGIN to create database."))
  ELSEIF ((request->target_os="AIX"))
   CALL text(23,5,concat("Please execute v500_create_",cnvtlower(request->database_name),".ksh",
     " in /tmp to create database."))
  ELSE
   CALL text(23,5,"Unknow OS.  Exit...")
  ENDIF
  CALL text(24,5,"Press return to exit...")
  CALL accept(24,30,"X;CU"," ")
 ENDIF
#final_exit
END GO
