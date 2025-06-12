CREATE PROGRAM dm_env_maint:dba
 DECLARE dclcom = vc WITH protect, noconstant(" ")
 DECLARE dem_parent = vc WITH public, noconstant(" ")
 DECLARE dem_extent_management = vc WITH public, noconstant(" ")
 DECLARE dem_rdbms_version = vc WITH public, noconstant(" ")
 DECLARE menu_func = c1 WITH public, noconstant(" ")
 DECLARE osver = vc WITH protect, constant(validate(cursys2,"AIX"))
 CALL echo(build("OS:",cursys))
 EXECUTE FROM init_variables TO init_variables_end
 SET dem_parent = "DM_ENV_MAINT"
 IF (validate(dm_env_import_request->master_environment_name," ") != " ")
  SET dem_parent = "DM_ENV_IMPORT"
  SET dem_env_name = trim(dm_env_import_request->target_environment_name)
  EXECUTE FROM get_env TO get_env_end
  SET dem_env_desc = substring(1,35,dm_env_import_request->target_environment_description)
  SET dem_env_id = dm_env_import_request->target_environment_id
  SET dem_target_op_sys = cursys
  SET dem_extent_management = dm_env_import_request->target_extent_management
  SET dem_rdbms_version = dm_env_import_request->target_rdbms_version
  GO TO process_screen3
  GO TO end_program
 ENDIF
#menu
 SET message = window
#init_variables
 SET stat = 0
 SET s_nodename = fillstring(12," ")
 SET width = 80
 SET dem_env_id = 0.0
 SET dem_blank_line = fillstring(79," ")
 SET dem_env_name = fillstring(20," ")
 SET dem_env_desc = fillstring(60," ")
 SET dem_db_name = fillstring(6," ")
 SET dem_month_cnt = 0.0
 SET dem_tot_db_size = 0
 SET dem_schema_version = 0.0
 SET dem_schema_date = cnvtdatetime(curdate,curtime3)
 SET dem_schema_datex = fillstring(11," ")
 SET dem_schema_datetime = fillstring(17," ")
 SET dem_from_schema_version = 0.0
 SET dem_from_schema_date = cnvtdatetime(curdate,curtime3)
 SET dem_from_schema_datex = fillstring(11," ")
 SET dem_root_dir_name = fillstring(80," ")
 SET dem_vol_group = fillstring(80," ")
 SET dem_target_op_sys = fillstring(3," ")
 SET dem_db_disk = fillstring(30," ")
 SET dem_v500_connect_str = fillstring(30," ")
 SET dem_v500ref_connect_str = fillstring(30," ")
 SET dem_db_arch_disk = fillstring(30," ")
 SET dem_file_part_size = 0
 SET dem_adm_db_link_name = fillstring(32," ")
 SET dem_cntrl_file_cnt = 0
 SET dem_redo_log_grps = 0
 SET dem_redo_log_mbrs = 0
 SET dem_db_ver_desc = fillstring(62," ")
 SET dem_cerner_fs_mtpt = fillstring(60," ")
 SET dem_ora_pri_fs_mtpt = fillstring(60," ")
 SET dem_ora_sec_fs_mtpt = fillstring(60," ")
 SET dem_oracle_version = fillstring(15," ")
 SET dem_max_file_size = 0.0
 SET dem_ver_id = 0
 SET dem_db_version = 0
 SET sizing_mode = 0
 SET dem_envset_string = fillstring(20," ")
 SET cur_oracle_root_path = fillstring(57," ")
 SET cur_target_op_sys = fillstring(3," ")
 SET cur_oracle_version = fillstring(15," ")
#init_variables_end
 EXECUTE FROM display_screen1 TO display_screen1_exit
 CALL text(24,02,"Select (A)dd,(M)odify,(I)nquire, (D)B_version tool (Q)uit: ")
 CALL accept(24,61,"P;CU","Q")
 IF (curaccept="Q")
  GO TO end_program
 ELSEIF (curaccept="D")
  EXECUTE menu_db_ver
  GO TO menu
 ENDIF
 SET menu_func = " "
 SET menu_func = curaccept
 IF (cursys != "AIX")
  SET cur_target_op_sys = "VMS"
  SET cur_oracle_root_path = logical("ORA_ROOT")
  SET dclcom = "@CER_INSTALL:DM_GET_ORACLE_VERSION.COM"
 ELSE
  SET cur_target_op_sys = "AIX"
  SET cur_oracle_root_path = logical("ORACLE_HOME")
  SET def_cerner_fs_mtpt = "/cerner"
  SET def_ora_pri_fs_mtpt = substring(1,(findstring("/",cur_oracle_root_path,2) - 1),
   cur_oracle_root_path)
  SET def_ora_sec_fs_mtpt = concat(substring(1,(size(trim(def_ora_pri_fs_mtpt)) - 1),
    def_ora_pri_fs_mtpt),"2")
  SET dclcom = ". $cer_install/dm_get_oracle_version.ksh"
 ENDIF
 SET dem_target_op_sys = cur_target_op_sys
 SET found_oracle_version = 1
 IF (menu_func="A")
  CALL text(24,01,dem_blank_line)
  CALL text(24,02,"Attempting to read oracle version from system...")
  CALL text(24,01," ")
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  IF (cursys != "AIX")
   SET cur_oracle_version = logical("VERSION")
   SET found_oracle_version = 1
  ELSE
   FREE SET version
   SET version = nullterm(logical("VERSION"))
   FREE DEFINE rtl
   DEFINE rtl "/tmp/dm_get_oracle_version.out"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     version = nullterm(r.line)
    WITH nocounter
   ;end select
   FREE DEFINE rtl
   SET cur_oracle_version = trim(version)
   SET found_oracle_version = 1
  ENDIF
  IF (cur_oracle_version > " ")
   CALL text(24,01,dem_blank_line)
   SET tempstr = fillstring(75," ")
   SET tempstr = concat("Add new environment on ",trim(cur_target_op_sys)," using oracle version ",
    trim(cur_oracle_version)," ? (Y/N)")
   CALL text(24,02,tempstr)
   CALL accept(24,75,"P;CU")
   IF (curaccept != "Y")
    CALL video(r)
    CALL box(10,10,16,70)
    CALL video(n)
    CALL clear(11,11,59)
    CALL clear(12,11,59)
    CALL clear(13,11,59)
    CALL clear(14,11,59)
    CALL clear(15,11,59)
    CALL text(12,12,"You can only add new environments for the current")
    CALL text(13,12,build("operating system (",cur_target_op_sys,") using the oracle version"))
    CALL text(14,12,build("found in the registry (",cur_oracle_version,")."))
    CALL accept(14,55,"P;CU","")
    GO TO menu
   ENDIF
  ELSE
   CALL text(23,01,dem_blank_line)
   CALL text(23,02,"Unable to find oracle version from system!")
   CALL text(24,01,dem_blank_line)
   CALL text(24,02,"Hit enter to continue adding new environment")
   CALL accept(24,60,"P;CU","")
   SET found_oracle_version = 0
   EXECUTE FROM display_screen1 TO display_screen1_exit
  ENDIF
 ENDIF
#accept
#accept_env_name
 CALL text(24,01,dem_blank_line)
 IF (menu_func="A")
  CALL text(24,02,"Enter new environment name. Examples: PROD, CERT, TRAIN, etc.  (REQUIRED)")
 ELSE
  CALL text(24,02,"HELP: Press <SHIFT><F5> ")
 ENDIF
 IF (menu_func="I")
  SET help =
  SELECT INTO "NL:"
   e.environment_name, e.description
   FROM dm_environment e
   WITH nocounter
  ;end select
 ELSEIF (menu_func="M")
  SET help =
  SELECT INTO "NL:"
   e.environment_name, e.description
   FROM dm_environment e
   WHERE e.target_operating_system=cur_target_op_sys
   WITH nocounter
  ;end select
 ENDIF
 CALL accept(04,13,"P(20);CUS")
 IF (curscroll=2)
  GO TO menu
 ELSEIF (curscroll != 0)
  GO TO accept_env_name
 ENDIF
 IF (curaccept="")
  GO TO accept_env_name
 ENDIF
 SET dem_env_name = curaccept
 CALL text(24,01,dem_blank_line)
#get_env
 IF (menu_func="A")
  SELECT INTO "nl:"
   e.*
   FROM dm_environment e
   WHERE e.environment_name=dem_env_name
   WITH nocounter
  ;end select
  IF (curqual=1)
   CALL text(24,01,dem_blank_line)
   CALL text(24,02,build("Environment '",dem_env_name,"' already exists! Modify it? (Y/N)"))
   CALL accept(24,70,"A;CU","N")
   IF (curaccept="Y")
    SET menu_func = "M"
   ELSE
    GO TO accept_env_name
   ENDIF
  ENDIF
 ENDIF
 IF (((menu_func="M") OR (menu_func="I")) )
  SELECT INTO "nl:"
   e.*
   FROM dm_environment e
   WHERE e.environment_name=dem_env_name
   DETAIL
    dem_env_id = e.environment_id, dem_env_desc = e.description, dem_db_name = e.database_name,
    dem_tot_db_size = e.total_database_size, dem_schema_version = e.schema_version,
    dem_from_schema_version = e.from_schema_version,
    dem_root_dir_name = e.root_dir_name, dem_v500_connect_str = e.v500_connect_string,
    dem_v500ref_connect_str = e.v500ref_connect_string,
    dem_vol_group = e.volume_group, dem_target_op_sys = e.target_operating_system, dem_db_disk = e
    .database_disk,
    dem_db_arch_disk = e.database_archive_disk, dem_file_part_size = e.data_file_partition_size,
    dem_adm_db_link_name = e.admin_dbase_link_name,
    dem_cntrl_file_cnt = e.control_file_count, dem_redo_log_grps = e.redo_log_groups,
    dem_redo_log_mbrs = e.redo_log_members,
    dem_max_file_size = e.max_file_size, dem_cerner_fs_mtpt = e.cerner_fs_mtpt, dem_ora_pri_fs_mtpt
     = e.ora_pri_fs_mtpt,
    dem_ora_sec_fs_mtpt = e.ora_sec_fs_mtpt, dem_oracle_version = e.oracle_version, dem_db_version =
    e.db_version,
    dem_month_cnt = e.month_cnt, dem_envset_string = e.envset_string
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO accept_env_name
  ENDIF
  SELECT INTO "nl:"
   e.schema_version"##.###", e.schema_date
   FROM dm_schema_version e
   WHERE e.schema_version=dem_schema_version
   DETAIL
    dem_schema_date = e.schema_date, dem_schema_datex = format(dem_schema_date,"DD-MMM-YYYY;3;d"),
    dem_schema_datetime = format(dem_schema_date,"DD-MMM-YYYY HH:MM;3;d")
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   sdv.*
   FROM dm_size_db_version sdv
   WHERE sdv.db_version=dem_db_version
   DETAIL
    dem_db_ver_desc = sdv.description
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   e.schema_version"##.###", e.schema_date
   FROM dm_schema_version e
   WHERE e.schema_version=dem_from_schema_version
   DETAIL
    dem_from_schema_date = e.schema_date, dem_from_schema_datex = format(dem_from_schema_date,
     "DD-MMM-YYYY;3;d")
   WITH nocounter
  ;end select
  EXECUTE FROM display_data1 TO display_data1_exit
 ENDIF
#get_env_end
 IF (menu_func="I")
  GO TO continue
 ENDIF
#accept_env_desc
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Examples: PRODUCTION, CERTIFICATION, TRAINING, etc. (REQUIRED)")
 CALL accept(05,16,"P(60);CUS",dem_env_desc)
 IF (curscroll=2)
  GO TO accept_env_name
 ELSEIF (curscroll != 0)
  GO TO accept_env_desc
 ENDIF
 IF (curaccept="")
  GO TO accept_env_desc
 ENDIF
 SET dem_env_desc = curaccept
 CALL text(24,01,dem_blank_line)
#accept_from_schema_version
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL accept(06,23,"N(7);S",format(dem_from_schema_version,"##.###;L;F"))
 IF (curscroll=2)
  GO TO accept_env_desc
 ELSEIF (curscroll != 0)
  GO TO accept_from_schema_version
 ENDIF
 IF (cnvtreal(curaccept) < 0.0)
  GO TO accept_from_schema_version
 ENDIF
 SET dem_from_schema_version = cnvtreal(curaccept)
 CALL text(06,23,cnvtstring(dem_from_schema_version,7,3,l),accept)
 IF (dem_from_schema_version=0)
  CALL text(06,40,"        ")
 ELSE
  CALL text(06,40,format(dem_from_schema_date,"MM/DD/YYYY;3;d"))
 ENDIF
 CALL text(24,01,dem_blank_line)
#accept_schema_version
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL accept(07,23,"N(7);S",format(dem_schema_version,"####.##;L;F"))
 IF (curscroll=2)
  GO TO accept_from_schema_version
 ELSEIF (curscroll != 0)
  GO TO accept_schema_version
 ENDIF
 SET dem_schema_version = cnvtreal(curaccept)
 CALL text(07,23,cnvtstring(dem_schema_version,7,3,l),accept)
 CALL text(07,40,format(dem_schema_date,"MM/DD/YYYY;3;d"))
 CALL text(24,01,dem_blank_line)
#accept_v500_connect_str
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter V500 Connect String. ")
 CALL accept(08,07,"P(30);CUS",dem_v500_connect_str)
 IF (curscroll=2)
  GO TO accept_schema_version
 ELSEIF (curscroll != 0)
  GO TO accept_v500_connect_str
 ENDIF
 SET dem_v500_connect_str = curaccept
 CALL text(24,01,dem_blank_line)
#accept_v500ref_connect_str
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter V500 Reference Connect String. ")
 CALL accept(08,48,"P(30);CUS",dem_v500ref_connect_str)
 IF (curscroll=2)
  GO TO accept_v500_connect_str
 ELSEIF (curscroll != 0)
  GO TO accept_v500ref_connect_str
 ENDIF
 SET dem_v500ref_connect_str = curaccept
 CALL text(24,01,dem_blank_line)
#accept_db_name
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Examples: V500, V500_REF, etc.  (REQUIRED)")
 CALL accept(09,18,"P(6);CUS",dem_db_name)
 IF (curscroll=2)
  GO TO accept_v500ref_connect_str
 ELSEIF (curscroll != 0)
  GO TO accept_db_name
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_db_name
 ENDIF
 SET dem_db_name = curaccept
 CALL text(24,01,dem_blank_line)
#accept_db_version
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter database version. HELP: Press <SHIFT><F5>   (REQUIRED)")
 SET help =
 SELECT INTO "nl:"
  dsd.db_version";l", dsd.description
  FROM dm_size_db_version dsd
  WITH nocounter
 ;end select
 CALL accept(09,53,"9(6);S",dem_db_version)
 IF (curscroll=2)
  GO TO accept_db_name
 ELSEIF (curscroll != 0)
  GO TO accept_db_version
 ENDIF
 IF (curaccept <= 0)
  GO TO accept_db_version
 ENDIF
 SET dem_db_version = cnvtint(curaccept)
 SELECT INTO "nl:"
  sdv.*
  FROM dm_size_db_version sdv
  WHERE sdv.db_version=dem_db_version
  DETAIL
   dem_db_ver_desc = sdv.description
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET dem_db_ver_desc = fillstring(62," ")
 ENDIF
 CALL text(09,53,cnvtstring(dem_db_version,6,0,r),accept)
 CALL text(10,18,substring(1,61,dem_db_ver_desc))
 CALL text(24,01,dem_blank_line)
#accept_oracle_version
 IF (found_oracle_version=1)
  IF (menu_func="A")
   CALL text(11,19,cur_oracle_version)
  ELSE
   CALL text(11,19,dem_oracle_version)
  ENDIF
 ELSEIF (menu_func="A")
  SET help = off
  CALL text(24,01,dem_blank_line)
  IF (dem_target_op_sys != "AIX")
   CALL text(24,02,"Enter Oracle Version. (REQUIRED) e.g. oraclev73 or oraclev732")
   IF (menu_func="A")
    CALL accept(11,19,"AAAAAAAP(8);CS","oraclev")
   ELSE
    CALL accept(11,19,"AAAAAAAP(8);CS",dem_oracle_version)
   ENDIF
  ELSE
   CALL text(24,02,"Enter Oracle Version. (REQUIRED) e.g. 7.0 or 7.3 or 7.3.2")
   CALL accept(11,19,"N(15);CS",dem_oracle_version)
  ENDIF
  IF (curscroll=2)
   GO TO accept_db_version
  ELSEIF (curscroll != 0)
   GO TO accept_oracle_version
  ENDIF
  IF (dem_target_op_sys != "AIX")
   IF (((curaccept="oraclev") OR (curaccept="ORACLEV")) )
    GO TO accept_oracle_version
   ENDIF
   IF (curaccept != "oraclev*")
    GO TO accept_oracle_version
   ENDIF
  ELSE
   IF (curaccept != "*.*"
    AND curaccept != "*.*.*")
    GO TO accept_oracle_version
   ENDIF
  ENDIF
  IF (((curaccept="") OR (curaccept <= " ")) )
   GO TO accept_oracle_version
  ENDIF
  SET dem_oracle_version = curaccept
  SET cur_oracle_version = dem_oracle_version
  CALL text(24,01,dem_blank_line)
 ENDIF
#accept_target_op_sys
 IF (menu_func="A")
  CALL text(11,53,cur_target_op_sys)
 ELSE
  CALL text(11,53,dem_target_op_sys)
 ENDIF
#accept_total_database_size
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Total Database Size. (Enter 0 to set Number of Months)")
 CALL accept(12,21,"9(7);S",cnvtint(dem_tot_db_size))
 IF (curscroll=2)
  IF (found_oracle_version=0)
   GO TO accept_oracle_version
  ELSE
   GO TO accept_db_version
  ENDIF
 ELSEIF (curscroll != 0)
  GO TO accept_total_database_size
 ENDIF
 IF (curaccept <= 0)
  GO TO accept_month_cnt
 ENDIF
 SET dem_tot_db_size = cnvtint(curaccept)
 CALL text(12,21,cnvtstring(dem_tot_db_size,7,0,r),accept)
 CALL text(24,01,dem_blank_line)
 CALL text(12,59,cnvtstring(0,7,0,r),accept)
 SET sizing_mode = 1
 GO TO accept_max_file_size
#accept_month_cnt
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Number of Months. (Enter 0 to set Database Size)")
 CALL accept(12,59,"9(7);S",cnvtint(dem_month_cnt))
 IF (curscroll=2)
  GO TO accept_total_database_size
 ELSEIF (curscroll != 0)
  GO TO accept_month_cnt
 ENDIF
 IF (curaccept <= 0)
  GO TO accept_total_database_size
 ENDIF
 SET dem_month_cnt = cnvtint(curaccept)
 CALL text(12,59,cnvtstring(dem_month_cnt,7,0,r),accept)
 CALL text(24,01,dem_blank_line)
 SET sizing_mode = 2
#accept_max_file_size
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter the maximum file size in megabytes (REQUIRED)")
 CALL accept(13,21,"9(7);S",cnvtint(dem_max_file_size))
 IF (curscroll=2)
  IF (sizing_mode=1)
   GO TO accept_total_database_size
  ELSE
   GO TO accept_month_cnt
  ENDIF
 ELSEIF (curscroll != 0)
  GO TO accept_max_file_size
 ENDIF
 IF (curaccept <= 0)
  GO TO accept_max_file_size
 ENDIF
 SET dem_max_file_size = curaccept
 CALL text(13,21,cnvtstring(dem_max_file_size,7,0,r),accept)
 CALL text(24,01,dem_blank_line)
#accept_data_file_partition_size
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Data File Partition Size.  (REQUIRED)")
 CALL accept(13,59,"9(7);S",cnvtint(dem_file_part_size))
 IF (curscroll=2)
  GO TO accept_max_file_size
 ELSEIF (curscroll != 0)
  GO TO accept_data_file_partition_size
 ENDIF
 IF (curaccept <= 0)
  GO TO accept_data_file_partition_size
 ENDIF
 SET dem_file_part_size = cnvtint(curaccept)
 IF (menu_func="A"
  AND cur_target_op_sys != "AIX")
  GO TO part_size_ok
 ELSEIF (dem_target_op_sys != "AIX")
  GO TO part_size_ok
 ENDIF
 SET part_size_isok = 1
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Checking Tablespace sizes...")
 SELECT INTO "nl:"
  dsd.file_size
  FROM dm_size_db_ts dsd
  WHERE dsd.db_version=dem_db_version
  DETAIL
   IF (mod(dsd.file_size,((dem_file_part_size * 1024) * 1024)) != 0)
    part_size_isok = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (part_size_isok=0)
  GO TO prompt_part_size
 ENDIF
 CALL text(24,02,"Checking Tablespace sizes...OK")
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Checking Control File sizes...")
 SELECT INTO "nl:"
  dsd.file_size
  FROM dm_size_db_cntl_files dsd
  WHERE dsd.db_version=dem_db_version
  DETAIL
   IF (mod(dsd.file_size,((dem_file_part_size * 1024) * 1024)) != 0)
    part_size_isok = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (part_size_isok=0)
  GO TO prompt_part_size
 ENDIF
 CALL text(24,02,"Checking Control File sizes...OK")
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Checking Redo Log sizes...")
 SELECT INTO "nl:"
  dsd.file_size
  FROM dm_size_db_redo_logs dsd
  WHERE dsd.db_version=dem_db_version
  DETAIL
   IF (mod(dsd.log_size,((dem_file_part_size * 1024) * 1024)) != 0)
    part_size_isok = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (part_size_isok=0)
  GO TO prompt_part_size
 ENDIF
 CALL text(24,02,"Checking Redo Log sizes...OK")
 GO TO part_size_ok
#prompt_part_size
 CALL video(r)
 CALL box(10,10,16,75)
 CALL video(n)
 CALL clear(11,11,64)
 CALL clear(12,11,64)
 CALL clear(13,11,64)
 CALL clear(14,11,64)
 CALL clear(15,11,64)
 CALL text(12,12,"Partition size does not match file sizes for this db version:")
 CALL text(13,12,build("'",substring(1,60,dem_db_ver_desc),"'"))
 CALL text(14,12,"Choose another db version or enter correct partition size.")
 CALL accept(14,73,"P;CU","")
 EXECUTE FROM display_screen1 TO display_screen1_exit
 EXECUTE FROM display_data1 TO display_data1_exit
 CALL text(04,13,"                    ")
 CALL text(04,13,dem_env_name,accept)
 GO TO accept_data_file_partition_size
#part_size_ok
 CALL text(12,59,cnvtstring(dem_file_part_size,7,0,r),accept)
 CALL text(24,01,dem_blank_line)
#accept_adm_db_link_name
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Admin Database Link Name. (OPTIONAL)")
 CALL accept(14,18,"P(30);CUS",dem_adm_db_link_name)
 IF (curscroll=2)
  GO TO accept_data_file_partition_size
 ELSEIF (curscroll != 0)
  GO TO accept_adm_db_link_name
 ENDIF
 SET dem_adm_db_link_name = curaccept
 CALL text(24,01,dem_blank_line)
 IF (dem_target_op_sys="AIX")
  GO TO accept_aix_specific
 ENDIF
#accept_vms_specific
 CALL text(16,03,"Database Disk: ")
 CALL text(17,03,"DB Archive Disk: ")
 CALL text(18,03,"Root Dir Name: ")
#accept_database_disk
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Database Disk.  (REQUIRED VMS)")
 CALL accept(16,18,"P(30);CUS",dem_db_disk)
 IF (curscroll=2)
  GO TO accept_adm_db_link_name
 ELSEIF (curscroll != 0)
  GO TO accept_database_disk
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_database_disk
 ENDIF
 SET dem_db_disk = curaccept
 CALL text(24,01,dem_blank_line)
#accept_database_archive_disk
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Database Archive Disk.  (REQUIRED VMS)")
 CALL accept(17,20,"P(30);CUS",dem_db_arch_disk)
 IF (curscroll=2)
  GO TO accept_database_disk
 ELSEIF (curscroll != 0)
  GO TO accept_database_archive_disk
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_database_archive_disk
 ENDIF
 SET dem_db_arch_disk = curaccept
 CALL text(24,01,dem_blank_line)
#accept_root_dir_name
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Root Directory Name.  (REQUIRED VMS)")
 CALL accept(18,18,"P(60);CUS",dem_root_dir_name)
 IF (curscroll=2)
  GO TO accept_database_archive_disk
 ELSEIF (curscroll != 0)
  GO TO accept_root_dir_name
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_root_dir_name
 ENDIF
 SET dem_root_dir_name = curaccept
 CALL text(24,01,dem_blank_line)
 IF (dem_target_op_sys != "AIX")
  GO TO skip_aix_specific
 ENDIF
#accept_aix_specific
 CALL text(17,03,"Cerner Mt Pt: ")
 CALL text(18,03,"ORA Soft Mt Pt: ")
 CALL text(19,03,"ORA Link Mt Pt: ")
 CALL text(20,03,"ENVSET String: ")
#accept_cerner_fs_mtpt
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Cerner Mount Point. (REQUIRED)")
 IF (menu_func="A")
  CALL accept(17,17,"P(60);CS",def_cerner_fs_mtpt)
 ELSE
  CALL accept(17,17,"P(60);CS",dem_cerner_fs_mtpt)
 ENDIF
 IF (curscroll=2)
  GO TO accept_adm_db_link_name
 ELSEIF (curscroll != 0)
  GO TO accept_cerner_fs_mtpt
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_cerner_fs_mtpt
 ENDIF
 SET dem_cerner_fs_mtpt = curaccept
 CALL text(24,01,dem_blank_line)
#accept_ora_pri_fs_mtpt
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter oracle software mount point. (REQUIRED)")
 IF (menu_func="A")
  CALL accept(18,19,"P(60);CS",def_ora_pri_fs_mtpt)
 ELSE
  CALL accept(18,19,"P(60);CS",dem_ora_pri_fs_mtpt)
 ENDIF
 IF (curscroll=2)
  GO TO accept_cerner_fs_mtpt
 ELSEIF (curscroll != 0)
  GO TO accept_pri_fs_mtpt
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_ora_pri_fs_mtpt
 ENDIF
 SET dem_ora_pri_fs_mtpt = curaccept
 CALL text(24,01,dem_blank_line)
#accept_ora_sec_fs_mtpt
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Oracle link point. (REQUIRED)")
 IF (menu_func="A")
  CALL accept(19,19,"P(60);CS",def_ora_sec_fs_mtpt)
 ELSE
  CALL accept(19,19,"P(60);CS",dem_ora_sec_fs_mtpt)
 ENDIF
 IF (curscroll=2)
  GO TO accept_ora_pri_fs_mtpt
 ELSEIF (curscroll != 0)
  GO TO accept_ora_sec_fs_mtpt
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_ora_sec_fs_mtpt
 ENDIF
 SET dem_ora_sec_fs_mtpt = curaccept
 CALL text(24,01,dem_blank_line)
#accept_envset_string
 SET help = off
 CALL text(24,01,dem_blank_line)
 CALL text(24,02,"Enter Environment Set String (REQUIRED)")
 CALL accept(20,18,"P(20);CS",dem_envset_string)
 IF (curscroll=2)
  GO TO accept_ora_sec_fs_mtpt
 ELSEIF (curscroll != 0)
  GO TO accept_envset_string
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_envset_string
 ENDIF
 SET dem_envset_string = curaccept
 CALL text(24,01,dem_blank_line)
#skip_aix_specific
#continue
 IF (menu_func="A")
  EXECUTE FROM add_environment TO add_environment_exit
 ELSEIF (menu_func="M")
  EXECUTE FROM modify_environment TO modify_environment_exit
 ENDIF
 CALL text(24,02,"Select (C)ontinue,(P)roduct List,(D)atabase Maintenance")
 CALL accept(24,59,"P;CU","C"
  WHERE curaccept IN ("C", "P", "D"))
 IF (curaccept="P")
  GO TO process_screen2
 ELSEIF (curaccept="D")
  GO TO process_screen3
 ENDIF
#return_from_screens
 GO TO menu
#modify_environment
 UPDATE  FROM dm_environment e
  SET e.environment_name = dem_env_name, e.description = dem_env_desc, e.database_name = dem_db_name,
   e.total_database_size = dem_tot_db_size, e.schema_version = dem_schema_version, e
   .from_schema_version = dem_from_schema_version,
   e.root_dir_name = dem_root_dir_name, e.v500_connect_string = dem_v500_connect_str, e
   .v500ref_connect_string = dem_v500ref_connect_str,
   e.volume_group = dem_vol_group, e.database_disk = dem_db_disk, e.database_archive_disk =
   dem_db_arch_disk,
   e.data_file_partition_size = dem_file_part_size, e.admin_dbase_link_name = dem_adm_db_link_name, e
   .control_file_count = dem_cntrl_file_cnt,
   e.redo_log_groups = dem_redo_log_grps, e.redo_log_members = dem_redo_log_mbrs, e.max_file_size =
   dem_max_file_size,
   e.cerner_fs_mtpt = dem_cerner_fs_mtpt, e.ora_pri_fs_mtpt = dem_ora_pri_fs_mtpt, e.ora_sec_fs_mtpt
    = dem_ora_sec_fs_mtpt,
   e.db_version = dem_db_version, e.month_cnt = dem_month_cnt, e.envset_string = dem_envset_string,
   e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_cnt = 0, e.updt_id = 0,
   e.updt_task = 0
  WHERE e.environment_name=dem_env_name
  WITH nocounter
 ;end update
 IF (curqual=1)
  COMMIT
  CALL text(24,01,dem_blank_line)
  CALL text(24,02,"*** Modification Complete ***")
  CALL accept(24,79,"X"," ")
  CALL text(24,01,dem_blank_line)
 ELSE
  CALL text(24,01,dem_blank_line)
  CALL text(24,02,"*** Modification NOT Successfull ***")
  CALL accept(24,78,"X"," ")
  CALL text(24,01,dem_blank_line)
  GO TO end_program
 ENDIF
#modify_environment_exit
#add_environment
 SELECT INTO "nl:"
  y = seq(dm_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   dem_env_id = cnvtreal(y)
  WITH format, counter
 ;end select
 IF (curqual=0)
  CALL text(24,01,dem_blank_line)
  CALL text(24,02,"*** Could NOT Assign Next Sequence from DM_SEQ ***")
  CALL accept(24,78,"X"," ")
  CALL text(24,01,dem_blank_line)
  GO TO end_program
 ENDIF
 INSERT  FROM dm_environment e
  SET e.environment_id = dem_env_id, e.environment_name = dem_env_name, e.description = dem_env_desc,
   e.database_name = dem_db_name, e.total_database_size = dem_tot_db_size, e.schema_version =
   dem_schema_version,
   e.from_schema_version = dem_from_schema_version, e.v500_connect_string = dem_v500_connect_str, e
   .v500ref_connect_string = dem_v500ref_connect_str,
   e.root_dir_name = dem_root_dir_name, e.volume_group = dem_vol_group, e.target_operating_system =
   cur_target_op_sys,
   e.database_disk = dem_db_disk, e.database_archive_disk = dem_db_arch_disk, e
   .data_file_partition_size = dem_file_part_size,
   e.admin_dbase_link_name = dem_adm_db_link_name, e.control_file_count = dem_cntrl_file_cnt, e
   .redo_log_groups = dem_redo_log_grps,
   e.redo_log_members = dem_redo_log_mbrs, e.max_file_size = dem_max_file_size, e.cerner_fs_mtpt =
   dem_cerner_fs_mtpt,
   e.ora_pri_fs_mtpt = dem_ora_pri_fs_mtpt, e.ora_sec_fs_mtpt = dem_ora_sec_fs_mtpt, e.oracle_version
    = cur_oracle_version,
   e.db_version = dem_db_version, e.month_cnt = dem_month_cnt, e.envset_string = dem_envset_string,
   e.updt_applctx = 0, e.updt_applctx = 0, e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   e.updt_cnt = 0, e.updt_id = 0, e.updt_task = 0
  WITH nocounter
 ;end insert
 IF (curqual=1)
  COMMIT
  CALL text(24,01,dem_blank_line)
  CALL text(24,02,"*** Add Complete ***")
  CALL text(04,43,cnvtstring(dem_env_id))
  CALL accept(24,78,"X"," ")
  CALL text(24,01,dem_blank_line)
 ELSE
  CALL text(24,01,dem_blank_line)
  CALL text(24,02,"*** Add NOT Successfull ***")
  CALL accept(24,79,"X"," ")
  CALL text(24,01,dem_blank_line)
  GO TO end_program
 ENDIF
#add_environment_exit
#display_screen1
 CALL video(n)
 CALL video(r)
 CALL clear(1,1)
 CALL box(3,1,23,79)
 CALL text(2,1,"DM Environment Maintenance",w)
 CALL video(n)
 CALL text(04,03,"Env Name:                       Env ID:              ")
 CALL text(05,03,"Description:                                         ")
 CALL text(06,03,"Schema From Version:            Date:                 ")
 CALL text(07,03,"Schema To Version  :            Date:                 ")
 CALL text(08,03,"Con:                                Ref Con:         ")
 CALL text(09,03,"Database Name:                  Database Version:    ")
 CALL text(10,03,"Database Desc:                                       ")
 CALL text(11,03,"Oracle Version:                 Operating System:    ")
 CALL text(12,03,"Total DB Size(M):               OR  Number of Months: ")
 CALL text(13,03,"Max File Size(M):               File Partition Size(M):  ")
 CALL text(14,03,"Admin Con:                                       ")
 CALL text(15,03,"Cntl File Cnt:         Redo Log Grps:         Redo Log Members:         ")
#display_screen1_exit
#display_data1
 CALL text(04,43,cnvtstring(dem_env_id),accept)
 CALL text(05,16,dem_env_desc,accept)
 CALL text(06,23,cnvtstring(dem_from_schema_version,7,3,l),accept)
 IF (dem_from_schema_version=0)
  CALL text(06,35,"          ")
 ELSE
  CALL text(06,40,format(dem_from_schema_date,"MM/DD/YYYY;3;d"))
 ENDIF
 CALL text(07,23,cnvtstring(dem_schema_version,7,3,l),accept)
 CALL text(07,40,format(dem_schema_date,"MM/DD/YYYY;3;d"))
 CALL text(08,07,substring(1,30,dem_v500_connect_str),accept)
 CALL text(08,48,substring(1,30,dem_v500ref_connect_str),accept)
 CALL text(09,53,cnvtstring(dem_db_version,6,0,r),accept)
 CALL text(10,18,substring(1,61,dem_db_ver_desc))
 CALL text(09,18,dem_db_name,accept)
 IF (menu_func="A")
  CALL text(11,19,cur_oracle_version)
 ELSE
  CALL text(11,19,dem_oracle_version)
 ENDIF
 CALL text(11,53,dem_target_op_sys)
 CALL text(12,21,cnvtstring(dem_tot_db_size,7,0,r),accept)
 CALL text(13,59,cnvtstring(dem_file_part_size,7,0,r),accept)
 CALL text(13,21,cnvtstring(dem_max_file_size,7,0,r),accept)
 CALL text(12,59,cnvtstring(dem_month_cnt,10,2,r),accept)
 CALL text(14,18,dem_adm_db_link_name,accept)
 CALL text(15,18,cnvtstring(dem_cntrl_file_cnt,5,0,r))
 CALL text(15,41,cnvtstring(dem_redo_log_grps,5,0,r))
 CALL text(15,67,cnvtstring(dem_redo_log_mbrs,5,0,r))
 IF (dem_target_op_sys != "AIX")
  CALL text(16,03,"Database Disk:                                       ")
  CALL text(16,18,dem_db_disk,accept)
  CALL text(17,03,"DB Archive Disk:                                     ")
  CALL text(17,20,dem_db_arch_disk,accept)
 ELSE
  CALL text(17,03,"Cerner Mt Pt:                                  ")
  CALL text(17,17,substring(1,60,dem_cerner_fs_mtpt),accept)
  CALL text(18,03,"ORA Soft Mt Pt:                           ")
  CALL text(18,19,substring(1,60,dem_ora_pri_fs_mtpt),accept)
  CALL text(19,03,"ORA Link Mt Pt:                                ")
  CALL text(19,19,substring(1,60,dem_ora_sec_fs_mtpt),accept)
  CALL text(20,03,"ENVSET String:                                 ")
  CALL text(20,18,substring(1,20,dem_envset_string),accept)
 ENDIF
#display_data1_exit
#process_screen2
 SET top_displayed = 0
 SET number_per_column = 18
 SET number_per_screen = (number_per_column * 2)
 SET top_row = 4
 SET width = 80
 FREE SET function_list
 RECORD function_list(
   1 function_name[*]
     2 fname = c255
     2 fid = i4
     2 installed = c1
   1 function_count = i4
 )
 SET stat = alterlist(function_list->function_name,10)
 SET function_list->function_count = 0
 SELECT INTO "nl:"
  dm.function_id, dm.description
  FROM dm_product_functions dm
  WHERE dm.function_id > 0
  ORDER BY dm.description
  DETAIL
   function_list->function_count = (function_list->function_count+ 1)
   IF (mod(function_list->function_count,10)=1
    AND (function_list->function_count != 1))
    stat = alterlist(function_list->function_name,(function_list->function_count+ 9))
   ENDIF
   function_list->function_name[function_list->function_count].fname = dm.description, function_list
   ->function_name[function_list->function_count].fid = dm.function_id, function_list->function_name[
   function_list->function_count].installed = "N"
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  def.function_id
  FROM dm_env_functions def
  WHERE def.environment_id=dem_env_id
  DETAIL
   cnt = 0, found = 0
   WHILE ((cnt < function_list->function_count)
    AND found=0)
    cnt = (cnt+ 1),
    IF ((def.function_id=function_list->function_name[cnt].fid))
     function_list->function_name[cnt].installed = "Y", found = 1
    ENDIF
   ENDWHILE
  WITH nocounter
 ;end select
#accept_screen_function
 CALL video(r)
 CALL clear(1,1)
 CALL box(2,1,23,79)
 CALL text(1,1,"DM Environment Maintenance",w)
 CALL video(n)
 SET tempstring = fillstring(75," ")
 SET tempstring = concat("Env Name: ",trim(dem_env_name)," Desc: ",substring(1,35,dem_env_desc))
 CALL text(03,03,tempstring)
 SET function_str = fillstring(38," ")
 CALL clear(24,1)
 SET finish = 0
 SET cnt = 0
 SET header_str = fillstring(33," ")
 SET header_str = "Ln Product/Function     Installed"
 CALL text(top_row,2,header_str)
 CALL text(top_row,41,header_str)
 WHILE (finish=0
  AND cnt < number_per_screen
  AND (cnt < function_list->function_count))
   SET cnt = (cnt+ 1)
   SET function_str = concat(substring(1,30,concat(cnvtstring((cnt+ top_displayed),2)," ",
      function_list->function_name[(cnt+ top_displayed)].fname))," ",function_list->function_name[(
    cnt+ top_displayed)].installed)
   IF (cnt > number_per_column)
    CALL text(((top_row+ cnt) - number_per_column),41,function_str)
   ELSE
    CALL text((top_row+ cnt),2,function_str)
   ENDIF
 ENDWHILE
 SET screen_function = " "
 SET tempstr2 = fillstring(60," ")
 IF ((number_per_screen >= function_list->function_count))
  SET tempstr2 = "allOn/alloFf/Change/Quit (O/F/C/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,44,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "Q"))
 ELSEIF (top_displayed > 0
  AND ((top_displayed+ number_per_screen) < function_list->function_count))
  SET tempstr2 = "allOn/alloFf/Change/Previous/Next/Quit (O/F/C/P/N/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,64,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "P", "N",
   "Q"))
 ELSEIF (((top_displayed+ number_per_screen) < function_list->function_count))
  SET tempstr2 = "allOn/alloFf/Change/Next/Quit (O/F/C/N/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,53,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "N", "Q"))
 ELSE
  SET tempstr2 = "allOn/alloFf/Change/Previous/Quit (O/F/C/P/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,57,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "P", "Q"))
 ENDIF
 SET screen_function = curaccept
 CASE (curaccept)
  OF "O":
   FOR (cnt = 1 TO function_list->function_count)
     SET function_list->function_name[cnt].installed = "Y"
   ENDFOR
  OF "F":
   FOR (cnt = 1 TO function_list->function_count)
     SET function_list->function_name[cnt].installed = "N"
   ENDFOR
  OF "C":
   CALL box(12,20,14,58)
   CALL text(13,21,"Enter the line number to change")
   CALL accept(13,54,"99;cs","0"
    WHERE cnvtint(curaccept) >= 0
     AND (cnvtint(curaccept) <= function_list->function_count))
   IF ((function_list->function_name[cnvtint(curaccept)].installed="N"))
    SET function_list->function_name[cnvtint(curaccept)].installed = "Y"
   ELSE
    SET function_list->function_name[cnvtint(curaccept)].installed = "N"
   ENDIF
  OF "P":
   SET top_displayed = (top_displayed - number_per_screen)
   IF (top_displayed < 0)
    SET top_displayed = 0
   ENDIF
   GO TO accept_screen_function
  OF "N":
   SET top_displayed = (top_displayed+ number_per_screen)
   IF ((top_displayed > (function_list->function_count - number_per_screen)))
    SET top_displayed = (function_list->function_count - number_per_screen)
   ENDIF
   GO TO accept_screen_function
  ELSE
   GO TO 9999_end
 ENDCASE
 FOR (counter = 1 TO function_list->function_count)
   IF ((function_list->function_name[counter].installed="Y"))
    SELECT INTO "nl:"
     fd.required_function_id
     FROM dm_function_dependencies fd
     WHERE (fd.function_id=function_list->function_name[counter].fid)
     DETAIL
      FOR (counter2 = 1 TO function_list->function_count)
        IF ((function_list->function_name[counter2].fid=fd.required_function_id))
         function_list->function_name[counter2].installed = "Y"
        ENDIF
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 DELETE  FROM dm_env_functions def
  WHERE def.environment_id=dem_env_id
  WITH nocounter
 ;end delete
 FOR (cnt = 1 TO function_list->function_count)
   IF ((function_list->function_name[cnt].installed="Y"))
    INSERT  FROM dm_env_functions def
     SET def.function_id = function_list->function_name[cnt].fid, def.environment_id = dem_env_id,
      def.dependency_ind = 1
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 COMMIT
 CALL clear(24,1)
 GO TO accept_screen_function
#9999_end
 CALL clear(24,1)
#process_screen2_exit
 GO TO return_from_screens
#process_screen3
#dm_menu
 SET message = window
 SET parser_buf = fillstring(132," ")
 EXECUTE FROM menu_screen TO menu_screen_exit
#menu_accept
 CALL text(24,02,"Select Menu Item Number (1-33) or Zero (0) to Quit: ")
 CALL accept(24,54,"99;S",0
  WHERE cnvtint(curaccept) BETWEEN 0 AND 33)
 SET dem_option_selected = cnvtint(curaccept)
 IF (dem_option_selected=0)
  GO TO end_program
 ENDIF
 CALL clear(24,1)
 SET dem_blank_line = fillstring(78," ")
#dboptions
 IF (cursys="AIX")
  SET dclcom = "umask 002"
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
 ENDIF
 CASE (dem_option_selected)
  OF 1:
   IF (cursys != "AIX")
    CALL text(05,41,"<EXECUTING>")
    CALL pause(2)
    SET dclcom = "@dba_root:[admin]pop_dm_sdf.com"
    SET len = size(trim(dclcom))
    SET status = 0
    SET width = 132
    CALL clear(1,1)
    CALL dcl(dclcom,len,status)
    SET validate = off
    EXECUTE FROM menu_screen TO menu_screen_exit
    CALL video(br)
    CALL text(05,41,"<COMPLETED>")
   ELSE
    IF (osver="HPX")
     SET dclcom = "chmod 755 $cer_install/dm2_pop_dm_disk_farm_hpx.ksh"
    ELSE
     SET dclcom = "chmod 755 $dba/admin/mkv500env_disk.ksh"
    ENDIF
    CALL text(05,41,"<EXECUTING>")
    CALL pause(2)
    SET len = size(trim(dclcom))
    SET status = 0
    SET width = 132
    CALL dcl(dclcom,len,status)
    CALL clear(1,1)
    IF (osver="HPX")
     SET dclcom = "$cer_install/dm2_pop_dm_disk_farm_hpx.ksh"
    ELSE
     SET dclcom = "$dba/admin/mkv500env_disk.ksh"
    ENDIF
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
    SET validate = off
    DELETE  FROM dm_disk_farm ddf
     WHERE ((ddf.volume_group = null) OR (ddf.volume_group <= " "))
     WITH nocounter
    ;end delete
    COMMIT
    EXECUTE FROM menu_screen TO menu_screen_exit
    CALL video(br)
    CALL text(05,41,"<COMPLETED")
   ENDIF
  OF 2:
   EXECUTE FROM process_screen4 TO process_screen4_exit
   IF (dem_parent="DM_ENV_MAINT")
    CALL video(br)
    EXECUTE FROM menu_screen TO menu_screen_exit
   ENDIF
  OF 3:
   IF (dem_parent="DM_ENV_IMPORT")
    EXECUTE dba_assign_db_disks value(nullterm(dem_env_name))
    EXECUTE FROM menu_screen TO menu_screen_exit
   ELSE
    CALL video(br)
    CALL text(07,34,"*")
    CALL video(n)
    CALL text(07,35,
     "<Please execute this option through DM_ENV_IMPORT to gather required information>.        ")
   ENDIF
  OF 4:
   IF (dem_parent="DM_ENV_IMPORT")
    EXECUTE dba_create_v500_db value(dem_env_name)
   ELSE
    CALL video(br)
    CALL text(08,34,"*")
    CALL video(n)
    CALL text(08,35,
     "<Please execute this option through DM_ENV_IMPORT to gather required information>.        ")
   ENDIF
  OF 6:
   EXECUTE FROM sizing_screen TO sizing_screen_exit
   EXECUTE FROM menu_screen TO menu_screen_exit
  OF 7:
   CALL text(11,41,"<EXECUTING>")
   SET parser_buf = concat('RDB ASIS(" begin DBA_SPREAD_FILES.DBA_SPREAD_FILES(',trim(cnvtstring(
      dem_env_id,7,0,r)),'); end;") go')
   CALL parser(parser_buf,1)
   CALL video(br)
   CALL text(11,41,"<COMPLETED>")
  OF 8:
   CALL text(12,41,"<EXECUTING>")
   EXECUTE dm_ddl_gen value(dem_env_id), value("DDL_GEN_OUTPUT"), value(dem_target_op_sys)
   CALL video(br)
   CALL text(12,41,"<COMPLETED>")
  OF 9:
   CALL text(13,41,"<EXECUTING>  ")
   CALL compile("DDL_GEN_OUTPUT.DAT","DDL_GEN_OUTOUT.LOG")
   CALL video(br)
   CALL text(13,41,"<COMPLETED>")
  OF 10:
   CALL text(14,41,"<EXECUTING>")
   EXECUTE dm_schema_comp value("C"), value(dem_env_name), value(dem_schema_datex)
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(14,41,"<COMPLETED>")
  OF 11:
   CALL text(15,41,"<EXECUTING>")
   EXECUTE dm_schema_comp2 value(dem_env_name), value(dem_schema_datex)
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(15,41,"<COMPLETED>")
  OF 12:
   CALL text(16,41,"<EXECUTING>")
   EXECUTE dm_drop_unused_tables value(dem_env_name), value(dem_schema_datex)
   CALL video(br)
   CALL text(16,41,"<COMPLETED>")
  OF 13:
   CALL text(17,41,"<EXECUTING>")
   CALL compile("DROP_UNUSED_TABLES_OUTPUT.dat","DROP_UNUSED_TABLES_OUTPUT.log")
   CALL video(br)
   CALL text(17,41,"<COMPLETED>")
  OF 14:
   CALL text(18,41,"<EXECUTING>")
   CALL video(r)
   CALL clear(1,1)
   EXECUTE dm_afd_check_rev value(dem_env_id)
   SET validate = off
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(18,41,"<COMPLETED>")
  OF 15:
   CALL text(19,41,"<EXECUTING>")
   EXECUTE dm_ddl_gen2 value(dem_env_id), value("DDL_GEN_OUTPUT"), value(dem_target_op_sys)
   CALL video(br)
   CALL text(19,41,"<COMPLETED>")
  OF 18:
   CALL text(05,110,"<EXECUTING>")
   EXECUTE dm_check_tspace value(dem_env_name), value(dem_schema_datex)
   CALL video(br)
   CALL text(05,110,"<COMPLETED>")
  OF 20:
   CALL text(07,110,"<EXECUTING>")
   EXECUTE dm_check_unused_tspace
   CALL video(br)
   CALL text(07,110,"<COMPLETED>")
  OF 21:
   CALL text(08,110,"<EXECUTING>")
   CALL compile("DROP_tspace.dat","DROP_tspace.log")
   IF (cursys != "AIX")
    SET dclcom = "@ccluserdir:drop_tspace_file.com "
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
   ELSE
    SET dclcom = "chmod 755 $CCLUSERDIR/drop_tspace_file.ksh"
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
    SET dclcom = "$CCLUSERDIR/drop_tspace_file.ksh"
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
   ENDIF
   CALL video(br)
   CALL text(08,110,"<COMPLETED     ")
  OF 22:
   CALL text(09,110,"<EXECUTING>")
   EXECUTE dm_schema_refresh value("SCHEMA_REFRESH_OUTPUT"), value(dem_schema_datex), value(0)
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(09,110,"<COMPLETED>")
  OF 23:
   CALL text(10,110,"<EXECUTING>")
   CALL compile("SCHEMA_REFRESH_OUTPUT1.dat","SCHEMA_REFRESH_OUTPUT1.log")
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(10,110,"<COMPLETED>")
  OF 24:
   CALL text(11,110,"<EXECUTING>")
   CALL compile("SCHEMA_REFRESH_OUTPUT2.dat","SCHEMA_REFRESH_OUTPUT2.log")
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(11,110,"<COMPLETED>")
  OF 25:
   CALL text(12,110,"<EXECUTING>")
   EXECUTE dm_fix_schema value("fix_schema"), value(dem_schema_datex), value(dem_env_id)
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(12,110,"<COMPLETED>")
  OF 26:
   EXECUTE dm_fix_schema_process
  OF 28:
   CALL text(15,110,"<EXECUTING>")
   SET width = 80
   CALL clear(1,1)
   EXECUTE dm_table_list
   SET validate = off
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(15,110,"<COMPLETED>")
  OF 29:
   CALL text(16,110,"<EXECUTING>")
   CALL video(r)
   DELETE  FROM dm_pkt_setup_proc_log d
    WHERE d.environment_id=dem_env_id
    WITH nocounter
   ;end delete
   COMMIT
   EXECUTE dm_create_com_files value(dem_env_id), value(1), value(1),
   value(2), value(2)
   SET validate = off
   CALL video(br)
   CALL text(16,110,"<COMPLETED>")
  OF 30:
   CALL text(17,110,"<EXECUTING>")
   CALL video(r)
   EXECUTE dm_create_com_files value(dem_env_id), value(2), value(1),
   value(2), value(2)
   SET validate = off
   CALL video(br)
   CALL text(17,110,"<COMPLETED>")
  OF 31:
   CALL text(18,110,"<EXECUTING>")
   CALL video(r)
   CALL clear(1,1)
   EXECUTE dm_readme_report value(dem_env_id), 1
   SET validate = off
   EXECUTE FROM menu_screen TO menu_screen_exit
   CALL video(br)
   CALL text(18,110,"<COMPLETED>")
  OF 32:
   CALL text(19,110,"<EXECUTING>")
   CALL video(r)
   EXECUTE dm_create_com_files value(dem_env_id), value(1), value(2),
   value(2), value(2)
   SET validate = off
   CALL video(br)
   CALL text(19,110,"<COMPLETED>")
  OF 33:
   CALL text(20,110,"<EXECUTING>")
   CALL video(r)
   EXECUTE dm_create_com_files value(dem_env_id), value(2), value(2),
   value(2), value(2)
   SET validate = off
   CALL video(br)
   CALL text(20,110,"<COMPLETED>")
  ELSE
   CALL video(b)
   CALL text(24,02,"That is not a valid selection!")
   CALL accept(24,75,"P;CUS"," ")
   CALL video(n)
   GO TO dm_menu
 ENDCASE
#dboptions_exit
 CALL video(n)
 CALL accept(24,75,"P;CUS"," ")
 GO TO dm_menu
#process_screen3_exit
 IF (dem_parent="DM_ENV_IMPORT")
  GO TO process_screen3
 ENDIF
#menu_screen
 SET width = 132
 CALL clear(1,1)
 CALL box(2,1,23,132)
 CALL text(1,1,"DM Environment Maintenance")
 CALL video(n)
 SET tempstring = fillstring(75," ")
 SET tempstring = concat("Env Name: ",trim(dem_env_name)," Desc: ",substring(1,35,dem_env_desc))
 CALL text(03,03,tempstring)
 CALL text(04,03,"DM Database Maintenance")
 CALL text(05,03," 1 Capture Disk Farm    ")
 CALL text(06,03," 2 Select Env Disk Farm ")
 CALL text(07,03," 3 Assign Database Disks")
 CALL text(08,03," 4 Create Database      ")
 CALL text(09,03," 5                      ")
 CALL text(10,03," 6 Calculate Database Size ")
 CALL text(11,03," 7 Spread Files         ")
 CALL text(12,03," 8 DDL Generation (New Database)")
 CALL text(13,03," 9 Execute DDL Gen script ")
 CALL text(14,03,"10 Schema Comparison    ")
 CALL text(15,03,"11 Schema Comparison 2  ")
 CALL text(16,03,"12 Drop Unused Tables Gen")
 CALL text(17,03,"13 Run Drop Unused Tables")
 CALL text(18,03,"14 Compare AFD and Upgrade Rev Numbers ")
 CALL text(19,03,"15 DDL Generation 2 (Refresh)")
 CALL text(20,03,"16                      ")
 CALL text(21,03,"17                      ")
 CALL text(05,63,"18 Run Check TSpace Program ")
 CALL text(06,63,"19                      ")
 CALL text(07,63,"20 Unused TSpace Generation ")
 CALL text(08,63,"21 Run Unused Tspace script ")
 CALL text(09,63,"22 Schema Refresh Generation ")
 CALL text(10,63,"23 Run Sequence Refresh script ")
 CALL text(11,63,"24 Run Schema Refresh script ")
 CALL text(12,63,"25 Fix Schema Generation ")
 CALL text(13,63,"26 Fix Schema Processing ")
 CALL text(14,63,"27                       ")
 CALL text(15,63,"28 Dm Table List Query ")
 CALL text(16,63,"29 Create before inst/refr README files")
 CALL text(17,63,"30 Create after inst/refr README files")
 CALL text(18,63,"31 View README Report ")
 CALL text(19,63,"32 Restart before inst/refr README files")
 CALL text(20,63,"33 Restart after inst/refr README files")
 CALL text(21,63,"34                      ")
#menu_screen_exit
#sizing_screen
#start_sizing
 SET client_name = fillstring(50," ")
 SET client_profile = fillstring(90," ")
 SET client_mnemonic = fillstring(15," ")
 SET target_size = 0.0
 SET target_months = 0.0
 SET ans = 0.0
 SET answer = "Y"
 CALL video(r)
 CALL clear(1,1)
 CALL box(2,1,23,132)
 CALL text(1,1,"DM Environment Maintenance",w)
 CALL video(n)
 SET line1 = concat("ENVIRONMENT: ",trim(dem_env_name),"     ENV ID:",trim(cnvtstring(dem_env_id)))
 CALL text(3,3,line1)
 SET line2 = concat("OPERATING SYS: ",trim(dem_target_op_sys))
 CALL text(5,3,line2)
 SET line3 = concat("SCHEMA DATE: ",trim(dem_schema_datetime))
 CALL text(7,3,line3)
 SET help =
 SELECT INTO "nl:"
  dc.client_name
 ;end select
 CALL text(9,3,"CLIENT:")
 CALL text(12,3,"CHOOSE ONE (USE ARROW KEYS)")
 CALL line(11,30,2,horizontal)
 CALL line(13,30,2,horizontal)
 CALL line(11,30,3,xvertical)
 CALL text(11,33,"TARGET SIZE:")
 CALL text(11,56,"MB")
 CALL text(13,33,"TARGET MONTHS:")
 CALL text(22,3,"PRESS M TO GO BACK TO MENU OR ENTER TO CONTINUE")
 CALL accept(22,52,"P;CUS"," ")
 IF (curaccept="M")
  GO TO dm_menu
 ENDIF
#accept_client
 CALL clear(22,3,129)
 CALL text(22,3,"CHOOSE CLIENT PROFILE FROM LIST")
 SET help =
 SELECT INTO "nl:"
  client = dc.client_mnemonic, size_mb = (dc.total_bytes/ (1024 * 1024)), dc.products
  FROM dm_client_size dc
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  dc.client_mnemonic
  FROM dm_client_size
  WHERE dc.client_mnemonic=curaccept
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(9,11,"P(15);CUF",client_mnemonic)
 SET client_mnemonic = curaccept
 SELECT INTO "nl:"
  FROM dm_client_size dc
  WHERE dc.client_mnemonic=client_mnemonic
  DETAIL
   client_profile = concat(trim(dc.client_name),". ",trim(cnvtstring((dc.total_bytes/ (1024 * 1024)))
     )," MB. ",trim(dc.products)), client_name = dc.client_name
  WITH nocounter
 ;end select
 CALL text(9,27,client_profile)
 SET help = off
 SET validate = off
 IF (sizing_mode=2)
  GO TO accept_months
 ENDIF
#accept_size
 CALL clear(13,48,10)
 CALL clear(22,3,129)
 CALL text(22,3,"ENTER TARGET DATABASE SIZE (in MB)")
 CALL accept(11,46,"P(9);CUS",cnvtstring(dem_tot_db_size))
 IF (curscroll=2)
  GO TO accept_client
 ELSEIF (curscroll=1)
  GO TO accept_months
 ELSEIF (curscroll > 2)
  GO TO accept_size
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_size
 ENDIF
 SET target_size = cnvtreal(curaccept)
 SET sizing_mode = 1
 GO TO verify_sizing
#accept_months
 CALL clear(11,46,10)
 CALL clear(22,3,129)
 CALL text(22,3,"ENTER TARGET NUMBER OF MONTHS")
 CALL accept(13,48,"P(7);CUS",cnvtstring(dem_month_cnt))
 IF (curscroll=2)
  GO TO accept_size
 ELSEIF (((curscroll=1) OR (curscroll > 2)) )
  GO TO accept_months
 ENDIF
 IF (((curaccept="") OR (curaccept <= " ")) )
  GO TO accept_months
 ENDIF
 SET target_months = cnvtreal(curaccept)
 SET sizing_mode = 2
#verify_sizing
 CALL clear(22,3,129)
 CALL text(22,3,"Correct ? (Y=Yes N=No M=Menu)")
 CALL accept(22,38,"A;CU",answer
  WHERE curaccept IN ("Y", "N", "M"))
 SET answer = curaccept
 IF (answer="Y")
  CALL clear(22,3,129)
  CALL text(22,3,"<EXECUTING>")
  IF (sizing_mode=1)
   UPDATE  FROM dm_environment e
    SET e.total_database_size = target_size
    WHERE e.environment_id=dem_env_id
    WITH nocounter
   ;end update
  ELSE
   UPDATE  FROM dm_environment e
    SET e.month_cnt = target_months
    WHERE e.environment_id=dem_env_id
    WITH nocounter
   ;end update
  ENDIF
  EXECUTE dm_calculate_sizing2 value(dem_env_id), value(dem_schema_datex), value(dem_target_op_sys),
  value(client_name), value(sizing_mode)
  CALL clear(15,3,129)
  IF (sizing_mode=1)
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE e.environment_id=dem_env_id
    DETAIL
     ans = e.month_cnt
    WITH nocounter
   ;end select
   CALL text(15,3,concat("This database will last ",trim(cnvtstring(ans))," months."))
  ELSE
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE e.environment_id=dem_env_id
    DETAIL
     ans = e.total_database_size
    WITH nocounter
   ;end select
   CALL text(15,3,concat("This database will need ",trim(cnvtstring(ans))," MB."))
  ENDIF
  CALL video(br)
  CALL text(22,3,"<COMPLETED>")
  CALL video(n)
  CALL text(22,16,"Recalculate ? (Y/N)")
  CALL accept(22,38,"A;CU","N")
  CALL video(n)
  IF (curaccept="Y")
   GO TO start_sizing
  ENDIF
  GO TO dm_menu
 ELSEIF (answer="M")
  CALL video(n)
  GO TO dm_menu
 ELSEIF (answer="N")
  CALL video(n)
  GO TO start_sizing
 ELSE
  GO TO verify_sizing
 ENDIF
#sizing_screen_exit
 GO TO return_from_screens
#process_screen4
 SET message = window
 SET width = 80
 CALL video(r)
 CALL clear(1,1)
 CALL box(2,1,23,79)
 CALL text(1,1,"DM Environment Maintenance",w)
 CALL video(n)
 SET tempstring = fillstring(75," ")
 SET tempstring = concat("Env Name: ",trim(dem_env_name)," Desc: ",substring(1,35,dem_env_desc))
 CALL text(03,03,tempstring)
 FREE SET list1
 RECORD list1(
   1 disk_cnt = i4
   1 disk_farm[*]
     2 disk_name = c30
     2 free_bytes = f8
     2 perf_factor = f8
     2 env_disk_ind = c1
     2 spread_ind = c1
     2 volume_group = c80
     2 new_disk_name = c30
 )
 SET stat = alterlist(list1->disk_farm,10)
 SET list1->disk_cnt = 0
 SELECT INTO "nl:"
  edf.disk_name, edf.spread_flg
  FROM dm_env_disk_farm edf
  WHERE edf.environment_id=dem_env_id
  ORDER BY edf.disk_name, edf.spread_flg DESC
  DETAIL
   list1->disk_cnt = (list1->disk_cnt+ 1)
   IF (mod(list1->disk_cnt,10)=1
    AND (list1->disk_cnt != 1))
    stat = alterlist(list1->disk_farm,(list1->disk_cnt+ 9))
   ENDIF
   list1->disk_farm[list1->disk_cnt].disk_name = edf.disk_name, list1->disk_farm[list1->disk_cnt].
   new_disk_name = edf.disk_name, list1->disk_farm[list1->disk_cnt].free_bytes = 0,
   list1->disk_farm[list1->disk_cnt].perf_factor = 0, list1->disk_farm[list1->disk_cnt].env_disk_ind
    = "Y"
   IF (edf.spread_flg=1)
    list1->disk_farm[list1->disk_cnt].spread_ind = "Y"
   ELSE
    list1->disk_farm[list1->disk_cnt].spread_ind = "N"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  df.disk_name, df.free_bytes, df.perf_factor,
  df.volume_group
  FROM dm_disk_farm df
  ORDER BY df.free_bytes DESC, df.disk_name
  DETAIL
   disk_found = 0
   FOR (x = 1 TO list1->disk_cnt)
     IF ((list1->disk_farm[x].disk_name=df.disk_name))
      disk_found = x, x = list1->disk_cnt
     ENDIF
   ENDFOR
   IF (disk_found=0)
    list1->disk_cnt = (list1->disk_cnt+ 1)
    IF (mod(list1->disk_cnt,10)=1
     AND (list1->disk_cnt != 1))
     stat = alterlist(list1->disk_farm,(list1->disk_cnt+ 9))
    ENDIF
    list1->disk_farm[list1->disk_cnt].disk_name = df.disk_name, list1->disk_farm[list1->disk_cnt].
    volume_group = df.volume_group, list1->disk_farm[list1->disk_cnt].new_disk_name = df.disk_name
    IF (df.free_bytes=null)
     list1->disk_farm[list1->disk_cnt].free_bytes = 0
    ELSE
     list1->disk_farm[list1->disk_cnt].free_bytes = df.free_bytes
    ENDIF
    IF (df.perf_factor=null)
     list1->disk_farm[list1->disk_cnt].perf_factor = 0
    ELSE
     list1->disk_farm[list1->disk_cnt].perf_factor = df.perf_factor
    ENDIF
    list1->disk_farm[list1->disk_cnt].env_disk_ind = "N", list1->disk_farm[list1->disk_cnt].
    spread_ind = "N"
   ELSE
    list1->disk_farm[disk_found].volume_group = df.volume_group
    IF (df.free_bytes=null)
     list1->disk_farm[disk_found].free_bytes = 0
    ELSE
     list1->disk_farm[disk_found].free_bytes = df.free_bytes
    ENDIF
    IF (df.perf_factor=null)
     list1->disk_farm[disk_found].perf_factor = 0
    ELSE
     list1->disk_farm[disk_found].perf_factor = df.perf_factor
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET top_displayed = 0
 SET number_per_column = 18
 SET number_per_screen = number_per_column
 SET top_row = 4
 SET bottom_row = 21
#accept_screen4_function
 SET disk_str = fillstring(76," ")
 CALL clear(24,1)
 SET finish = 0
 SET cnt = 0
 SET tempstr = fillstring(75," ")
 CASE (cursys)
  OF "AIX":
   SET tempstr = "Line Env Spd Disk Name                  Volume Group            Free Mb  PF"
  OF "AXP":
   SET tempstr = "Line Env Spd Disk Name                                          Free Mb  PF"
 ENDCASE
 CALL text(top_row,2,tempstr)
 WHILE (finish=0
  AND cnt < number_per_screen
  AND (cnt < list1->disk_cnt))
   SET cnt = (cnt+ 1)
   SET v_free_bytes = (list1->disk_farm[(cnt+ top_displayed)].free_bytes/ (1024 * 1024))
   SET v_new_disk_name = substring(1,26,list1->disk_farm[(cnt+ top_displayed)].new_disk_name)
   SET disk_str = substring(1,75,concat(cnvtstring((cnt+ top_displayed),3,0,r),"   ",list1->
     disk_farm[(cnt+ top_displayed)].env_disk_ind,"   ",list1->disk_farm[(cnt+ top_displayed)].
     spread_ind,
     "  ",v_new_disk_name," ",substring(1,23,list1->disk_farm[(cnt+ top_displayed)].volume_group)," ",
     cnvtstring(v_free_bytes,8,2,l),"  ",cnvtstring(list1->disk_farm[(cnt+ top_displayed)].
      perf_factor,1,0,l)))
   CALL text((top_row+ cnt),2,disk_str)
 ENDWHILE
 FOR (x1 = ((top_row+ cnt)+ 1) TO 22)
   CALL text(x1,2,"                                                                            ")
 ENDFOR
 SET screen_function = " "
 SET tempstr2 = fillstring(60," ")
 IF ((number_per_screen >= list1->disk_cnt))
  SET tempstr2 = "allOn/alloFf/Change/Quit (O/F/C/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,36,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "Q"))
 ELSEIF (top_displayed > 0
  AND ((top_displayed+ number_per_screen) < list1->disk_cnt))
  SET tempstr2 = "allOn/alloFf/Change/Previous/Next/Quit (O/F/C/P/N/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,54,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "P", "N",
   "Q"))
 ELSEIF (((top_displayed+ number_per_screen) < list1->disk_cnt))
  SET tempstr2 = "allOn/alloFf/Change/Next/Quit (O/F/C/N/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,43,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "N", "Q"))
 ELSE
  SET tempstr2 = "allOn/alloFf/Change/Previous/Quit (O/F/C/P/Q)?"
  CALL text(24,1,tempstr2)
  CALL accept(24,47,"p;cus","Q"
   WHERE curaccept IN ("O", "F", "C", "P", "Q"))
 ENDIF
 SET screen_function = curaccept
 CASE (curaccept)
  OF "O":
   FOR (cnt = 1 TO list1->disk_cnt)
    SET list1->disk_farm[cnt].env_disk_ind = "Y"
    SET list1->disk_farm[cnt].spread_ind = "Y"
   ENDFOR
  OF "F":
   FOR (cnt = 1 TO list1->disk_cnt)
    SET list1->disk_farm[cnt].env_disk_ind = "N"
    SET list1->disk_farm[cnt].spread_ind = "N"
   ENDFOR
  OF "C":
   CALL box(11,20,16,70)
   CALL text(12,21,"Enter the line number to change                  ")
   CALL text(13,21,"                                                 ")
   CALL text(14,21,"                                                 ")
   CALL text(15,21,"                                                 ")
   CALL accept(12,54,"999;cs","0"
    WHERE cnvtint(curaccept) >= 0
     AND (cnvtint(curaccept) <= list1->disk_cnt))
   SET line_accept = cnvtint(curaccept)
   SET line_disk_name = substring(1,25,list1->disk_farm[line_accept].new_disk_name)
   IF (dem_target_op_sys != "AIX")
    CALL text(13,23,"Disk Name:  ")
    CALL accept(13,35,"P(25);C",line_disk_name)
    IF (curaccept != substring(1,25,list1->disk_farm[line_accept].disk_name))
     SET line_disk_name = curaccept
     SET list1->disk_farm[line_accept].new_disk_name = curaccept
    ENDIF
   ENDIF
   CALL text(14,23,"Include in Environment: ")
   CALL text(15,23,"Use in Spread Files:    ")
   CALL accept(14,50,"A;CU",list1->disk_farm[line_accept].env_disk_ind
    WHERE curaccept IN ("Y", "N"))
   SET list1->disk_farm[line_accept].env_disk_ind = curaccept
   IF ((list1->disk_farm[line_accept].env_disk_ind="Y"))
    CALL accept(15,50,"A;CU",list1->disk_farm[line_accept].spread_ind
     WHERE curaccept IN ("Y", "N"))
    SET list1->disk_farm[line_accept].spread_ind = curaccept
   ELSE
    SET list1->disk_farm[line_accept].spread_ind = "N"
   ENDIF
  OF "P":
   SET top_displayed = (top_displayed - number_per_screen)
   IF (top_displayed < 0)
    SET top_displayed = 0
   ENDIF
  OF "N":
   SET top_displayed = (top_displayed+ number_per_screen)
   IF ((top_displayed > (list1->disk_cnt - number_per_screen)))
    SET top_displayed = (list1->disk_cnt - number_per_screen)
   ENDIF
  OF "Q":
   EXECUTE FROM update_screen4 TO update_screen4_exit
   GO TO dm_menu
 ENDCASE
 GO TO accept_screen4_function
#update_screen4
 FREE SET list2
 RECORD list2(
   1 val_cnt = i4
   1 disk_values[*]
     2 environment_id = f8
     2 spread_flg = i4
 )
 DELETE  FROM dm_env_disk_farm edf
  WHERE edf.environment_id=dem_env_id
  WITH nocounter
 ;end delete
 FOR (cnt = 1 TO list1->disk_cnt)
  IF ((list1->disk_farm[cnt].disk_name != list1->disk_farm[cnt].new_disk_name))
   SET list2->val_cnt = 0
   SET stat = alterlist(list2->disk_values,10)
   SELECT INTO "nl:"
    a.environment_id, a.spread_flg
    FROM dm_env_disk_farm a
    WHERE (a.disk_name=list1->disk_farm[cnt].disk_name)
    DETAIL
     list2->val_cnt = (list2->val_cnt+ 1)
     IF (mod(list2->val_cnt,10)=1
      AND (list2->val_cnt != 1))
      stat = alterlist(list2->disk_values,(list2->val_cnt+ 9))
     ENDIF
     list2->disk_values[list2->val_cnt].environment_id = a.environment_id, list2->disk_values[list2->
     val_cnt].spread_flg = a.spread_flg
    WITH nocounter
   ;end select
   DELETE  FROM dm_env_disk_farm
    WHERE (disk_name=list1->disk_farm[cnt].disk_name)
   ;end delete
   UPDATE  FROM dm_disk_farm ddf
    SET ddf.disk_name = list1->disk_farm[cnt].new_disk_name
    WHERE (ddf.disk_name=list1->disk_farm[cnt].disk_name)
   ;end update
   FOR (ecnt = 1 TO list2->val_cnt)
     INSERT  FROM dm_env_disk_farm edf
      SET edf.disk_name = list1->disk_farm[cnt].new_disk_name, edf.environment_id = list2->
       disk_values[ecnt].environment_id, edf.spread_flg = list2->disk_values[ecnt].spread_flg,
       edf.updt_applctx = 0, edf.updt_dt_tm = cnvtdatetime(curdate,curtime3), edf.updt_cnt = 0,
       edf.updt_id = 0, edf.updt_task = 0
      WITH nocounter
     ;end insert
   ENDFOR
  ENDIF
  IF ((list1->disk_farm[cnt].env_disk_ind="Y"))
   INSERT  FROM dm_env_disk_farm edf
    SET edf.environment_id = dem_env_id, edf.disk_name = list1->disk_farm[cnt].new_disk_name, edf
     .spread_flg =
     IF ((list1->disk_farm[cnt].spread_ind="Y")) 1
     ELSE 0
     ENDIF
     ,
     edf.updt_applctx = 0, edf.updt_dt_tm = cnvtdatetime(curdate,curtime3), edf.updt_cnt = 0,
     edf.updt_id = 0, edf.updt_task = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDFOR
 COMMIT
#update_screen4_exit
#9999_end_screen4
 CALL clear(24,1)
#process_screen4_exit
 GO TO return_from_screens
#end_program
 CALL video(n)
 CALL clear(1,1)
END GO
