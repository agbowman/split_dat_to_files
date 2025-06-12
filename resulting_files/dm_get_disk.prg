CREATE PROGRAM dm_get_disk
 PAINT
 SET width = 132
#init
 DECLARE file_name = c50
 DECLARE disk = c20
 DECLARE data_file = c50
 DECLARE disk_name = c30
 DECLARE size = c14
 DECLARE new_size = f8
 DECLARE path = c100
 DECLARE path1 = c100
 DECLARE flag = i4
 DECLARE dgd_env_id = f8
 DECLARE dgd_ocd_reply(dgd_ocd_status,dgd_ocd_msg) = null
 DECLARE dgd_dbname = c6
 IF (validate(fs_proc->env[1].id,0) > 0)
  SET dgd_env_id = fs_proc->env[1].id
 ELSE
  SELECT INTO "nl:"
   d.info_number
   FROM dm_info d
   WHERE d.info_domain="DATA MANAGEMENT"
    AND d.info_name="DM_ENV_ID"
   DETAIL
    dgd_env_id = d.info_number
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(fs_proc->env[1].db_name," ") != " ")
  SET dgd_dbname = fs_proc->env[1].db_name
 ELSE
  SELECT INTO "nl:"
   de.database_name
   FROM dm_environment de
   WHERE de.environment_id=dgd_env_id
   DETAIL
    dgd_dbname = de.database_name
   WITH nocounter
  ;end select
 ENDIF
#prog_description
 CALL text(1,1,"A new tablespace needs to be created or at least one tablespace needs more space.")
 CALL text(3,1,"This program below will help you to choose disks to assign to the datafiles for")
 CALL text(4,1,"the extra tablespace, and allow you to increase the datafile size as needed.")
 CALL text(5,1,"If dm_tablespace_mapping tool is just used to map custom tablespace name to")
 CALL text(6,1,"Cerner recomended new tablespace name, please choose option R to recheck for")
 CALL text(7,1,"inadequate tablespace again.")
 CALL text(9,1,"Enter <C>ontinue, <Q>uit, <R>echeck: ")
 CALL accept(9,80,"P;CU","C"
  WHERE curaccept IN ("Q", "C", "R"))
 IF (curaccept="Q")
  CALL dgd_ocd_reply("F","Exiting dm_get_disk before running the program")
  GO TO end_program
 ELSEIF (curaccept="R")
  CALL dgd_ocd_reply("R","Recheck for inadequate tablespace due to tspace mapping.")
  GO TO end_program
 ENDIF
#data_file
 CALL clear(1,1)
 CALL text(1,1,"1, Please select a datafile to assign disk: (shift F5 for help)")
 CALL clear(4,1)
 SET help = pos(3,1,10,130)
 SET help =
 SELECT INTO "nl:"
  file_name = substring(1,50,d.file_name), d.tablespace_name, disk = substring(1,20,d.disk_name),
  d.file_size
  FROM dm_env_files d
  WHERE d.environment_id=dgd_env_id
   AND d.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  d.file_name
  FROM dm_env_files d
  WHERE d.environment_id=dgd_env_id
   AND d.file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end select
 SET validate = 1
 CALL accept(2,1,"P(50);CUS")
 SET data_file = fillstring(50," ")
 SET data_file = curaccept
 SET validate = off
#get_file_size
 SET size = fillstring(14," ")
 SELECT INTO "nl:"
  d.file_size
  FROM dm_env_files d
  WHERE d.environment_id=dgd_env_id
   AND d.file_type IN ("DATA", "INDEX")
   AND d.file_name=data_file
  DETAIL
   size = cnvtstring(d.file_size)
  WITH nocounter
 ;end select
 CALL text(4,1,concat("The data file ",trim(data_file),"'s file size is ",trim(size)))
 CALL text(5,1,concat("2, Would you like to increase the size for data file ",trim(data_file),"?"))
 CALL accept(5,80,"P;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  CALL text(6,4,concat("Enter the new file size for ",trim(data_file),": "))
  CALL accept(6,60,"P(14);CS",size)
  SET new_size = 0.0
  SET new_size = cnvtreal(curaccept)
  IF (new_size < cnvtreal(size))
   CALL text(7,1,"The size of the file can not be reduced, Please enter a new file size again.")
   GO TO get_file_size
  ENDIF
 ELSE
  SET new_size = cnvtreal(size)
 ENDIF
#disk
 CALL clear(7,1,120)
 CALL text(8,1,"3, Please choose a disk to assign to the selected data file: ")
 SET help = off
 SET help = pos(10,30,10,80)
 SET help =
 SELECT INTO "nl:"
  dm.disk_name, dm.free_bytes, dm.volume_group
  FROM dm_disk_farm dm
  WITH nocounter
 ;end select
 CALL accept(8,60,"P(30);CUSF")
 SET disk_name = fillstring(30," ")
 SET disk_name = curaccept
 CALL text(9,1,concat("The disk ",trim(disk_name)," is assigned to data file ",trim(data_file)))
#correct_yn
 CALL text(12,1,"Correct (Y/N)?")
 CALL accept(12,18,"P;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  CALL clear(12,1)
  CALL text(12,1,"Line #? ")
  CALL accept(12,10,"XX",1
   WHERE curaccept BETWEEN 0 AND 3)
  IF (curaccept=0)
   GO TO correct_yn
  ENDIF
  GO TO (data_file, get_file_size, disk)curaccept
 ENDIF
 UPDATE  FROM dm_env_files d
  SET d.disk_name = disk_name, d.file_size = new_size, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  WHERE d.environment_id=dgd_env_id
   AND d.file_name=data_file
   AND file_type IN ("DATA", "INDEX")
  WITH nocounter
 ;end update
 COMMIT
#find_dir
 IF (cursys != "AIX")
  SET path1 = concat(trim(disk_name),":[v500]db_",trim(dgd_dbname),".dir")
  SET path = concat(trim(disk_name),":[v500.db_",trim(dgd_dbname),"]")
  SET flag = findfile(path1)
  SET option = 0
  IF (flag=0)
   CALL text(13,1,concat("The directory ",trim(path)," does not exist, "))
   CALL text(14,1,
    "Enter one of the options:  <1>Choose another disk; <2>Create the directory; <3>Quit the program."
    )
   CALL accept(14,100,"9",3
    WHERE curaccept BETWEEN 1 AND 3)
   SET option = curaccept
   IF (option=1)
    CALL clear(1,1)
    GO TO data_file
   ELSEIF (option=3)
    CALL dgd_ocd_reply("F","User failed to create diertory needed.")
    GO TO end_program
   ENDIF
   CALL text(15,1,"Please use the command below to create a new directory in a seperate session.")
   CALL text(16,1,concat("$create/dir ",trim(path),"/own = d_<owner>/prot = (g:rwe, w:rwe)"))
   CALL text(17,1,"Is the directory available? (Y/N)")
   CALL accept(17,80,"P;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL clear(14,1)
    GO TO find_dir
   ELSEIF (curaccept="N")
    CALL text(18,1,"Would you like to <C>ontinue to create directory or <Q>uit from the program?")
    CALL accept(18,80,"P;CU","Q"
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="C")
     CALL clear(14,1)
     GO TO find_dir
    ELSEIF (curaccept="Q")
     CALL dgd_ocd_reply("F","User failed to create diertory needed.")
     GO TO end_program
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#next
 SELECT INTO "nl:"
  d.file_name
  FROM dm_env_files d
  WHERE d.environment_id=dgd_env_id
   AND d.file_type IN ("DATA", "INDEX")
   AND d.disk_name=null
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL text(19,1,build(curqual," datafile(s) do not have disk(s) assigned."))
  CALL text(20,1,"Assign disks to all datafiles before continue process.")
  CALL text(21,1,"Would you like to (C)ontinue updating other data files or (Q)uit the program? ")
  CALL accept(21,100,"P;CU","C"
   WHERE curaccept IN ("C", "Q"))
  IF (curaccept="C")
   GO TO data_file
  ELSEIF (curaccept="Q")
   CALL dgd_ocd_reply("F","Exiting dm_get_disk.  Not all datafiles have disks assigned.")
   GO TO end_program
  ENDIF
 ELSEIF (curqual=0)
  CALL text(19,1,"All the datafiles have been assigned with disks.  Please choose an option below:")
  CALL text(20,1,"<1>Modify the datafiles <2>Continue the installation <3> Exit the program ")
  CALL accept(20,100,"9",2
   WHERE curaccept BETWEEN 1 AND 3)
  IF (curaccept=1)
   GO TO data_file
  ELSEIF (curaccept=3)
   CALL dgd_ocd_reply("F","Exiting dm_get_disk before run DDL to create tspace")
   GO TO end_program
  ENDIF
 ENDIF
 CALL clear(1,1)
 IF (cursys != "AIX")
  CALL text(22,1,"Executing DDL file to create tablespace and datafiles needed, Please wait.....")
  EXECUTE dm_ddl_gen2 value(dgd_env_id), value("DDL_GEN_OUTPUT"), value("VMS")
  CALL compile("DDL_GEN_OUTPUT.DAT","DDL_GEN_OUTPUT_ERROR.DAT")
  CALL dgd_ocd_reply("S","Run DDL successfully")
  CALL clear(24,1)
 ELSE
  CALL text(1,1,
   "Make sure you are in the environment the target database is resides in, check with command below:"
   )
  CALL text(2,5,"#newgrp -d_<env>                                   (cert, prod, test etc.)")
  CALL text(3,5,"Environment <env> set.                             (Message returned by system)")
  CALL text(5,1,
   "Run mkv500env_tspace.ksh from $dba/admin to create the script that builds raw logical volumes")
  CALL text(6,1,
   "and tablespaces in sql, and execute it as necessary.  <env> is the environment of the database")
  CALL text(7,1,
   "you are building, cert, prod etc. This version requires the registry to be properly configured")
  CALL text(8,5,"for the environment and database.")
  CALL text(9,5,"#cd $dba/admin")
  CALL text(10,5,"./mkv500env_tspace.ksh <env>                      (cert, prod, test etc.)")
  CALL text(12,1,"When choose to run manually, execute the following as user root: ")
  CALL text(13,5,"/tmp/mkv500env_mklv")
  CALL text(14,5,"su - oracle -c /tmp/mkv500env_ddl")
  CALL text(23,1,"Please complete all the steps above, then enter <C> to continue.")
  CALL accept(23,80,"P;CU","C"
   WHERE curaccept IN ("C"))
  IF (curaccept="C")
   CALL dgd_ocd_reply("S","Run .ksh successfully")
   GO TO end_program
  ENDIF
 ENDIF
 SUBROUTINE dgd_ocd_reply(dgd_ocd_status,dgd_ocd_msg)
   IF (validate(dgd_reply->status,"2") != "2")
    SET dgd_reply->status = dgd_ocd_status
    SET dgd_reply->err_msg = dgd_ocd_msg
   ENDIF
 END ;Subroutine
#end_program
END GO
