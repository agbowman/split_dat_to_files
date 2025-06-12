CREATE PROGRAM dba_create_v500_db80:dba
 SET message = window
 IF ((dm_env_import_request->base_oracle_version="9"))
  DECLARE libclntsh_entry = vc
 ENDIF
 SET env_id = request->environment_id
 SET dbname = request->database_name
 SET target_os = request->target_os
 SET node = request->node
 SET nodename = node
 SET dbsid = concat(dbname,"1")
 SET t_env_name = fillstring(20," ")
 SET failed = "F"
 SET exit_message = fillstring(70," ")
 SET v500_uname = request->v500_username
 SET v500_pswd = request->v500_password
 SET ora_ver = request->oracleversion
 SET oracle_mtpt = request->orasecmtpt
 SET dbdir = request->rdb_directory
 SET char_set = fillstring(120," ")
 SET o9_libpath = concat('"',^'SRVPATH':/usr/lib:/lib:'ORACLE_HOME'/lib32"^)
 SELECT INTO "nl:"
  a.environment_name
  FROM dm_environment a
  WHERE a.environment_id=env_id
  DETAIL
   t_env_name = a.environment_name
  WITH nocounter, format = stream, noheading,
   formfeed = none, maxrow = 1
 ;end select
 CALL screen_0(1)
 CALL text(7,05,"Cerner Registry Updates:")
 CALL text(9,05,"\environment")
 CALL text(10,07,concat("\",nullterm(cnvtlower(t_env_name))))
 CALL text(11,09,"\node")
 CALL text(12,11,concat("\",nullterm(cnvtlower(node))))
 CALL text(13,13,concat("dbinstance = ",nullterm(cnvtlower(dbname)),"1"))
 CALL text(15,05,"\dbinstance")
 CALL text(16,07,concat("\",nullterm(cnvtlower(dbname)),"1"))
 CALL text(17,09,concat("database = ",nullterm(cnvtlower(dbname))))
 CALL text(9,36,"\database")
 CALL text(10,38,concat("\",nullterm(cnvtlower(dbname))))
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL text(11,40,concat("rdbms = ",nullterm(cnvtlower(ora_ver))))
 ELSE
  CALL text(11,40,concat("rdbms = ",nullterm(cnvtlower(ora_ver))))
 ENDIF
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL text(12,40,concat("rootpath = ",nullterm(cnvtlower(dbdir))))
 ELSE
  CALL text(12,40,concat("rootpath = ",nullterm(cnvtlower(oracle_mtpt)),"/oracle/admin/",nullterm(
     cnvtlower(dbname))))
 ENDIF
 CALL text(13,40,"\node")
 CALL text(14,42,concat("\",nullterm(node)))
 CALL text(15,44,"rdbms connect option = ")
 CALL text(16,44,concat("rdbms user name = ",nullterm(cnvtlower(v500_uname))))
 CALL text(17,44,concat("rdbms Password = ",nullterm(cnvtlower(v500_pswd))))
 CALL clear(23,05,74)
 CALL text(23,05,"Please confirm the above registry information.  Continue(Y/N)? ")
 CALL accept(23,69,"P;CUS","Y")
 IF (curaccept="N")
  SET failed = "T"
  SET exit_message = "Please re-execute dm_env_import with necessary changes. Exit..."
  GO TO exit_script
 ENDIF
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL screen_0(1)
  SET row_nbr = 7
  WHILE (row_nbr <= 14)
   CALL clear(row_nbr,03,77)
   SET row_nbr = (row_nbr+ 1)
  ENDWHILE
  CALL text(7,05,"Additional Cerner Registry Updates: ")
  CALL text(9,05,concat("\environment\",nullterm(cnvtlower(t_env_name)),
    "\definitions\vmsalpha\environment"))
  IF ((dm_env_import_request->character_set != "US7ASCII"))
   CALL text(10,8,concat("NLS_LANG = ",nullterm(concat("AMERICAN_AMERICA.",cnvtupper(
        dm_env_import_request->character_set)))))
  ENDIF
  IF ((dm_env_import_request->base_oracle_version="8"))
   SET ora_nls33 = logical("ora_nls33")
   CALL text(11,8,concat("ORA_NLS33 = ",nullterm(cnvtupper(ora_nls33))))
   CALL text(12,8,"CER_ORA_CLIENT = ORACLIENT64_<image_id$$>")
  ELSE
   SET ora_nls33 = logical("ora_nls33")
   CALL text(11,8,concat("ORA_NLS33 = ",nullterm(cnvtupper(ora_nls33))))
   CALL text(12,8,"CER_ORA_CLIENT = LIBCLNTSH")
   CALL text(13,8,concat("ORACLE_HOME = ",request->vms_oracle_home))
   SET libclntsh_entry = replace(request->vms_oracle_home,"]",".LIB32]libclntsh.so",2)
   CALL text(14,8,concat("LIBCLNTSH = ",libclntsh_entry))
  ENDIF
  CALL clear(23,05,74)
  CALL text(23,05,"Please confirm the above registry information.  Continue(Y/N)? ")
  CALL accept(23,69,"P;CUS","Y")
  IF (curaccept="N")
   SET failed = "T"
   SET exit_message = "Please re-execute dm_env_import with the necessary changes. Exit..."
   GO TO exit_script
  ENDIF
 ELSE
  IF ((dm_env_import_request->character_set != "US7ASCII"))
   SET ora_pri_mtpt = request->oraprimtpt
   SET oracle_ver = request->oracleversion
   SET ora_nls33 = build(ora_pri_mtpt,"/oracle/product/",oracle_ver,"/ocommon/nls/admin/data")
   SET row_nbr = 10
   WHILE (row_nbr <= 21)
    CALL clear(row_nbr,03,77)
    SET row_nbr = (row_nbr+ 1)
   ENDWHILE
   CALL text(7,05,"Cerner Registry Updates: ")
   CALL text(9,05,"\environment")
   CALL text(10,07,concat("\",nullterm(cnvtlower(t_env_name))))
   CALL text(11,09,"\definitions")
   CALL text(12,11,"\aixrs6000")
   CALL text(13,13,"\environment")
   CALL text(15,15,concat("NLS_LANG = ",nullterm(concat("AMERICAN_AMERICA.",cnvtupper(
        dm_env_import_request->character_set)))))
   CALL text(16,15,concat("ORA_NLS33 = ",nullterm(cnvtupper(ora_nls33))))
   CALL clear(23,05,74)
   CALL text(23,05,"Please confirm the above registry information.  Continue(Y/N)? ")
   CALL accept(23,69,"P;CUS","Y")
   IF (curaccept="N")
    SET failed = "T"
    SET exit_message = "Please re-execute dm_env_import with necessary changes. Exit..."
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 CALL clear(23,05,74)
 CALL text(23,05,"Generate script to update cerner registry...")
 CALL pause(3)
 IF (((target_os="VMS") OR (target_os="AXP")) )
  CALL vms_upd_registry(1)
 ELSE
  CALL aix_upd_registry(1)
 ENDIF
 CALL clear(23,05,74)
 SUBROUTINE vms_upd_registry(x)
  CASE (dm_env_import_request->base_oracle_version)
   OF "8":
    SET vur_filespec = concat("v500_crt_",dbname,"_81.com")
    SET logical ddd "sys$login"
   ELSE
    DECLARE vur_filespec = vc
    DECLARE ora_nls33 = vc
    SET vur_filespec = concat("upd_registry_",dbname,".com")
    SET logical ddd value(request->rdb_directory)
  ENDCASE
  SELECT INTO concat("ddd:",value(vur_filespec))
   FROM dummyt
   DETAIL
    col 0, "$ set noon", row + 1,
    col 0, "$ lreg -crek \environment\",
    CALL print(nullterm(cnvtlower(t_env_name))),
    "\node\",
    CALL print(nullterm(cnvtlower(node))), row + 1,
    col 0, "$ lreg -setp \environment\",
    CALL print(nullterm(cnvtlower(t_env_name))),
    "\node\",
    CALL print(nullterm(cnvtlower(node))), " DbInstance ",
    CALL print(nullterm(cnvtlower(dbname))), "1", row + 1,
    col 0, "$ lreg -crek \environment\",
    CALL print(nullterm(cnvtlower(t_env_name))),
    "\definitions\vmsalpha\environment", row + 1
    IF (nullterm(cnvtupper(dm_env_import_request->character_set)) != "US7ASCII")
     col 0, "$ lreg -setp \environment\",
     CALL print(nullterm(cnvtlower(t_env_name))),
     "\definitions\vmsalpha\environment NLS_LANG ",
     CALL print(nullterm(concat("AMERICAN_AMERICA.",cnvtupper(dm_env_import_request->character_set)))
     ), row + 1
    ENDIF
    CASE (dm_env_import_request->base_oracle_version)
     OF "8":
      ora_nls33 = logical("ora_nls33"),col 0,"$ lreg -setp \environment\",
      CALL print(nullterm(cnvtlower(t_env_name)))"\definitions\vmsalpha\environment ORA_NLS33 ",
      CALL print(nullterm(ora_nls33))row + 1,col 0,'$ @ora_install:ora_sym "RDBMS"',row + 1,col 0,
      "$ lreg -setp \environment\",
      CALL print(nullterm(cnvtlower(t_env_name)))
      "\definitions\vmsalpha\environment CER_ORA_CLIENT ORACLIENT64_'image_id$$'",row + 1
     ELSE
      ora_nls33 = logical("ora_nls33"),col 0,"$ lreg -setp \environment\",
      CALL print(nullterm(cnvtlower(t_env_name)))"\definitions\vmsalpha\environment ORA_NLS33 ",
      CALL print(nullterm(ora_nls33))row + 1,col 0,"$ lreg -setp \environment\",
      CALL print(nullterm(cnvtlower(t_env_name)))
      "\definitions\vmsalpha\environment CER_ORA_CLIENT LIBCLNTSH ",row + 1,libclntsh_entry = replace
      (request->vms_oracle_home,"]",".LIB32]libclntsh.so",2),col 0,"$ lreg -setp \environment\",
      CALL print(nullterm(cnvtlower(t_env_name)))"\definitions\vmsalpha\environment LIBCLNTSH ",
      CALL print(nullterm(libclntsh_entry))row + 1,col 0,"$ lreg -setp \environment\",
      CALL print(nullterm(cnvtlower(t_env_name)))"\definitions\vmsalpha\environment ORACLE_HOME ",
      CALL print(nullterm(request->vms_oracle_home))row + 1
    ENDCASE
    col 0, "$ lreg -crek \DbInstance\",
    CALL print(nullterm(dbname)),
    "1", row + 1, col 0,
    "$ lreg -setp \DbInstance\",
    CALL print(nullterm(dbname)), "1 database ",
    CALL print(nullterm(dbname)), row + 1, col 0,
    "$ lreg -crek \Database\",
    CALL print(nullterm(dbname)), "\node\",
    CALL print(nullterm(node)), row + 1, col 0,
    "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)), " Rdbms ",
    CALL print(nullterm(ora_ver)), row + 1, col 0,
    "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)), " RootPath ",
    CALL print(nullterm(dbdir)), row + 1, col 0,
    "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)), "\node\",
    CALL print(nullterm(node)), ' "Rdbms Connect Option" ', row + 1,
    col 0, "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)),
    "\node\",
    CALL print(nullterm(node)), ' "Rdbms User Name" ',
    CALL print(nullterm(v500_uname)), row + 1, col 0,
    "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)), "\node\",
    CALL print(nullterm(node)), ' "Rdbms Password" ',
    CALL print(nullterm(v500_pswd)),
    row + 1, col 0, "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)), " CurrentInstanceCount 1", row + 1,
    col 0, "$ lreg -setp \Database\",
    CALL print(nullterm(dbname)),
    " ProjectedInstanceCount 1"
    IF ((dm_env_import_request->base_oracle_version="8"))
     row + 1, col 0, "$ @dba_root:[admin]updatetns.com ",
     CALL print(trim(dbsid)), " ",
     CALL print(trim(nodename)),
     " ",
     CALL print(trim(dbname)), " - ",
     row + 1,
     CALL print(trim(dbdir)), row + 1,
     col 0, "$ cerner_boot := $cer_mgr_exe:start_cerner_500.exe", row + 1,
     col 0, "$ cerner_boot -env ",
     CALL print(nullterm(cnvtlower(t_env_name))),
     " -verbose"
    ENDIF
   WITH nocounter, format = stream, noheading,
    formfeed = none, maxrow = 1
  ;end select
 END ;Subroutine
 SUBROUTINE aix_upd_registry(x)
   SET ora_pri_mtpt = request->oraprimtpt
   SET oracle_ver = request->oracleversion
   SET ora_nls33 = build(ora_pri_mtpt,"/oracle/product/",oracle_ver,"/ocommon/nls/admin/data")
   SELECT INTO concat("/tmp/v500_crt_",dbname,"_81.ksh")
    FROM dummyt
    DETAIL
     col 0, "#!/usr/bin/ksh", row + 1,
     col 0, "lreg -crek \\environment\\",
     CALL print(nullterm(cnvtlower(t_env_name))),
     "\\node\\",
     CALL print(nullterm(cnvtlower(node))), row + 1,
     col 0, "lreg -setp \\environment\\",
     CALL print(nullterm(cnvtlower(t_env_name))),
     "\\node\\",
     CALL print(nullterm(cnvtlower(node))), " DbInstance ",
     CALL print(nullterm(cnvtlower(dbname))), "1", row + 1
     IF (nullterm(cnvtupper(dm_env_import_request->character_set)) != "US7ASCII")
      col 0, "lreg -crek \\environment\\",
      CALL print(nullterm(cnvtlower(t_env_name))),
      "\\definitions\\aixrs6000\\environment", row + 1, col 0,
      "lreg -setp \\environment\\",
      CALL print(nullterm(cnvtlower(t_env_name))), "\\definitions\\aixrs6000\\environment NLS_LANG ",
      CALL print(nullterm(concat("AMERICAN_AMERICA.",cnvtupper(dm_env_import_request->character_set))
       )), row + 1, col 0,
      "lreg -setp \\environment\\",
      CALL print(nullterm(cnvtlower(t_env_name))), "\\definitions\\aixrs6000\\environment ORA_NLS33 ",
      CALL print(nullterm(ora_nls33)), row + 1
     ENDIF
     col 0, "lreg -crek \\DbInstance\\",
     CALL print(nullterm(cnvtlower(dbname))),
     "1", row + 1, col 0,
     "lreg -setp \\DbInstance\\",
     CALL print(nullterm(cnvtlower(dbname))), "1 database ",
     CALL print(nullterm(cnvtlower(dbname))), row + 1, col 0,
     "lreg -crek \\Database\\",
     CALL print(nullterm(cnvtlower(dbname))), "\\node\\",
     CALL print(nullterm(cnvtlower(node))), row + 1, col 0,
     "lreg -setp \\Database\\",
     CALL print(nullterm(cnvtlower(dbname))), " Rdbms ",
     CALL print(nullterm(cnvtlower(ora_ver))), row + 1, col 0,
     "lreg -setp \\Database\\",
     CALL print(nullterm(cnvtlower(dbname))), " RootPath ",
     CALL print(nullterm(cnvtlower(oracle_mtpt))), "/oracle/admin/",
     CALL print(nullterm(cnvtlower(dbname))),
     row + 1, col 0, "lreg -setp \\Database\\",
     CALL print(nullterm(cnvtlower(dbname))), "\\node\\",
     CALL print(nullterm(cnvtlower(node))),
     ' "Rdbms Connect Option" ', row + 1, col 0,
     "lreg -setp \\Database\\",
     CALL print(nullterm(cnvtlower(dbname))), "\\node\\",
     CALL print(nullterm(cnvtlower(node))), ' "Rdbms User Name" ',
     CALL print(nullterm(cnvtlower(v500_uname))),
     row + 1, col 0, "lreg -setp \\Database\\",
     CALL print(nullterm(cnvtlower(dbname))), "\\node\\",
     CALL print(nullterm(cnvtlower(node))),
     ' "Rdbms Password" ',
     CALL print(nullterm(cnvtlower(v500_pswd))), row + 1
    WITH nocounter, format = stream, noheading,
     formfeed = none, maxrow = 1
   ;end select
   SET dclstr80_3 = concat("chmod 766 /tmp/v500_crt_",cnvtlower(dbname),"_81.ksh")
   SET len80_3 = size(dclstr80_3)
   SET status80_3 = 0
   CALL dcl(dclstr80_3,len80_3,status80_3)
   SET dclstr80_4 = concat("chown oracle /tmp/v500_crt_",cnvtlower(dbname),"_81.ksh")
   SET len80_4 = size(dclstr80_4)
   SET status80_4 = 0
   CALL dcl(dclstr80_4,len80_4,status80_4)
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
