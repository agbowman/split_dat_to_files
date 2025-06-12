CREATE PROGRAM dm_stat_setup_check:dba
 DECLARE dclcom = vc WITH noconstant("")
 DECLARE dclcom2 = vc WITH noconstant("")
 DECLARE dclcmd = vc WITH noconstant("")
 DECLARE dcllen = i4 WITH noconstant(0)
 DECLARE mystat = i4 WITH noconstant(0)
 DECLARE myrc = i4 WITH noconstant(0)
 DECLARE srvquota = i4 WITH constant(800000)
 DECLARE pos1 = i4 WITH noconstant(0)
 DECLARE pos2 = i4 WITH noconstant(0)
 DECLARE line = vc WITH noconstant("")
 DECLARE path = vc WITH noconstant("")
 DECLARE disk = vc WITH noconstant("")
 DECLARE directory = vc WITH noconstant("")
 DECLARE dir_file = vc WITH noconstant("")
 DECLARE world_prot = vc WITH noconstant("")
 DECLARE nodename = vc WITH constant(cnvtlower(curnode))
 DECLARE rtms_file = vc WITH noconstant("")
 DECLARE client_mnem = vc WITH noconstant("")
 DECLARE syst4log = vc WITH noconstant("")
 DECLARE msa_str = vc WITH noconstant("")
 DECLARE cli_str = vc WITH noconstant("")
 DECLARE millconfig_str = vc WITH noconstant("")
 DECLARE millconfig2_str = vc WITH noconstant("")
 DECLARE sysinfo_str = vc WITH noconstant("")
 DECLARE sysinfo2_str = vc WITH noconstant("")
 DECLARE runnmon_str = vc WITH noconstant("")
 DECLARE nmonfile_str = vc WITH noconstant("")
 DECLARE file_str = vc WITH noconstant("")
 DECLARE nmonfile = vc WITH noconstant("")
 DECLARE server66_pid = vc WITH noconstant("")
 DECLARE server54_pid = vc WITH noconstant("")
 DECLARE cmbinstance = vc WITH constant(logical("CMB_INSTANCE"))
 DECLARE t4version = vc WITH noconstant("")
 DECLARE nmonfile_tmp = vc WITH constant("nmonfile.tmp")
 DECLARE srv66pid_tmp = vc WITH constant("serv66pid.tmp")
 DECLARE srv54pid_tmp = vc WITH constant("serv54pid.tmp")
 DECLARE tempfile_tmp = vc WITH constant("tempfile.tmp")
 DECLARE file_date_string = vc WITH constant(format(cnvtdatetime((curdate - 1),0),"DDMMMYYYY;;D"))
 DECLARE checkfile(filename=vc) = vc
 FREE RECORD setup_info
 RECORD setup_info(
   1 msa_server_log = vc
   1 msa_client_log = vc
   1 vms_millconfig = vc
   1 vms_millconfig2 = vc
   1 vms_osconfig = vc
   1 vms_osconfig2 = vc
   1 vms_t4config32 = vc
   1 vms_t4config40 = vc
   1 aix_millconfig = vc
   1 aix_millconfig2 = vc
   1 aix_sysinfo = vc
   1 aix_sysinfo2 = vc
   1 aix_run_nmon = vc
   1 syst4_logical = vc
   1 t4sys_logical = vc
   1 t4data_logical = vc
   1 syst4_security = vc
   1 t4data_security = vc
   1 t4_out_file = vc
   1 t4_file_security = vc
   1 nmon_out_file = vc
   1 rtms_csv_file = vc
   1 timer_cerner = vc
   1 client_mnemonic = vc
   1 switch = vc
   1 on_off_switch = vc
   1 server66 = vc
   1 server54 = vc
 )
 FREE RECORD reference_docs
 RECORD reference_docs(
   1 msa = vc
   1 rtms = vc
   1 scp66 = vc
   1 scp54 = vc
   1 workinst = vc
 )
 SET reference_docs->msa =
 "https://wiki.ucern.com/display/public/reference/Configure+Millennium+Support+Assistant"
 SET reference_docs->rtms = build("http://wiki.ucern.com/display/public/reference/",
  "Configure+Core+Services+Response+Time+Measurement+System+Response+Time+Tracking")
 SET reference_docs->scp66 = "http://www.cerner.com/members/Filedownload.asp?LibraryID=4557"
 SET reference_docs->scp54 = "http://www.cerner.com/members/Filedownload.asp?LibraryID=4628"
 SET reference_docs->workinst =
 "http://wiki.ucern.com/display/public/reference/Configure+Database+Monitoring+Tools"
 IF (trim(logical("T4$Data"))="")
  SET t4version = "3.2"
 ELSE
  SET t4version = "4.0"
 ENDIF
 IF (cursys != "AXP"
  AND cursys != "AIX"
  AND cursys2 != "HPX")
  CALL clear(1,1)
  CALL echo("ERROR: This program is only designed to work in VMS, AIX, and HPUX systems!")
  GO TO exit_program
 ENDIF
 CALL checkmsa("x")
 CALL checkdmfiles("x")
 CALL checkt4nmon("x")
 CALL checkrtms("x")
 CALL checkdm_info("x")
 CALL checkquotas("x")
 CALL displayreport("x")
 GO TO exit_program
 SUBROUTINE checkmsa(z)
   SET setup_info->msa_server_log = "Fail"
   SET setup_info->msa_client_log = "Fail"
   IF (logical("MSA_SERVER") != null)
    SET setup_info->msa_server_log = "Success"
   ENDIF
   IF (logical("CLIENT_MNEMONIC") != null)
    SET setup_info->msa_client_log = "Success"
   ENDIF
 END ;Subroutine
 SUBROUTINE checkdmfiles(z)
   SET setup_info->vms_millconfig = "Fail"
   SET setup_info->vms_millconfig2 = "Fail"
   SET setup_info->vms_osconfig = "Fail"
   SET setup_info->vms_osconfig2 = "Fail"
   SET setup_info->aix_millconfig = "Fail"
   SET setup_info->aix_millconfig2 = "Fail"
   SET setup_info->aix_sysinfo = "Fail"
   SET setup_info->aix_sysinfo2 = "Fail"
   IF (cursys="AXP")
    IF (findfile("cer_proc:esm_gather_millconfig.com")=1)
     SET setup_info->vms_millconfig = "Success"
    ENDIF
    IF (findfile("cer_proc:esm_gather_millconfig2.com")=1)
     SET setup_info->vms_millconfig2 = "Success"
    ENDIF
    IF (findfile("cer_proc:esm_gather_osconfig.com")=1)
     SET setup_info->vms_osconfig = "Success"
    ENDIF
    IF (findfile("cer_proc:esm_gather_osconfig2.com")=1)
     SET setup_info->vms_osconfig2 = "Success"
    ENDIF
   ENDIF
   IF (cursys="AIX")
    SET setup_info->aix_millconfig = checkfile("cer_proc/esm_gather_millconfig.ksh")
    SET setup_info->aix_millconfig2 = checkfile("cer_proc/esm_gather_millconfig2.ksh")
    SET setup_info->aix_sysinfo = checkfile("cer_nmon/proc/esm_get_sysinfo.ksh")
    SET setup_info->aix_sysinfo2 = checkfile("cer_nmon/proc/esm_get_sysinfo2.ksh")
   ENDIF
 END ;Subroutine
 SUBROUTINE checkfile(filename)
   IF (findfile(filename)=1)
    SET dclcom = concat("ls -l $",filename," > ",tempfile_tmp)
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
    FREE DEFINE rtl2
    DEFINE rtl2 tempfile_tmp
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      file_str = substring(2,9,trim(a.line))
     WITH nocounter, maxrec = 1
    ;end select
    IF (file_str="r?xr?x???")
     RETURN("Success")
    ENDIF
   ELSE
    RETURN("Fail")
   ENDIF
 END ;Subroutine
 SUBROUTINE checkt4nmon(z)
   SET setup_info->t4sys_logical = "Fail"
   SET setup_info->syst4_logical = "Fail"
   SET setup_info->t4data_logical = "Fail"
   SET setup_info->t4_out_file = "Fail"
   SET setup_info->t4_file_security = "Fail"
   SET setup_info->vms_t4config32 = "Fail"
   SET setup_info->vms_t4config40 = "Fail"
   SET setup_info->syst4_security = "Fail"
   SET setup_info->aix_run_nmon = "Fail"
   SET setup_info->t4data_security = "Fail"
   IF (cursys="AXP")
    SET pos1 = findstring("[",logical("T4$SYS"),1)
    IF (pos1 > 0)
     SET setup_info->t4sys_logical = "Success"
     SET pos1 = findstring("[",logical("T4$DATA"),1)
     IF (pos1 > 0)
      SET setup_info->t4data_logical = "Success"
      SET pos2 = findstring("]",logical("T4$DATA"),1)
      SET path = substring(pos1,((pos2 - pos1)+ 1),logical("T4$DATA"))
      SET pos2 = findstring(":",logical("T4$DATA"),1)
      SET disk = substring(1,pos2,logical("T4$DATA"))
      IF (findstring(".",path,1,1) > 0)
       SET pos1 = findstring(".",path,1,1)
       SET pos2 = findstring("]",path,1,1)
       SET directory = substring(2,(pos1 - 2),path)
       SET dir_file = substring((pos1+ 1),((pos2 - pos1) - 1),path)
       SET dclcmd = concat("dir/prot ",trim(disk),"[",trim(directory),"]",
        trim(dir_file),".dir")
      ELSE
       SET pos1 = findstring("[",path,1,1)
       SET pos2 = findstring("]",path,1,1)
       SET dir_file = substring((pos1+ 1),((pos2 - pos1) - 1),path)
       SET dclcmd = concat("dir/prot ",trim(disk),"[000000]",trim(dir_file),".dir")
      ENDIF
      CALL dclsetlogical(concat("pipe ",dclcmd," | search sys$input ",trim(dir_file)),"DIR_PROT")
      SET pos1 = findstring(",",logical("DIR_PROT"),1,1)
      SET pos2 = findstring(")",logical("DIR_PROT"),1,1)
      SET world_prot = substring((pos1+ 1),((pos2 - pos1) - 1),logical("DIR_PROT"))
      IF (((findstring("R",world_prot,1) > 0) OR (findstring("E",world_prot,1) > 0)) )
       SET setup_info->t4data_security = "Success"
      ENDIF
     ENDIF
    ELSE
     SET pos1 = findstring("[",logical("SYS$T4"),1)
     IF (pos1 > 0)
      SET setup_info->syst4_logical = "Success"
      SET pos2 = findstring("]",logical("SYS$T4"),1)
      SET path = substring(pos1,((pos2 - pos1)+ 1),logical("SYS$T4"))
      SET pos2 = findstring(":",logical("SYS$T4"),1)
      SET disk = substring(1,pos2,logical("SYS$T4"))
      IF (findstring(".",path,1,1) > 0)
       SET pos1 = findstring(".",path,1,1)
       SET pos2 = findstring("]",path,1,1)
       SET directory = substring(2,(pos1 - 2),path)
       SET dir_file = substring((pos1+ 1),((pos2 - pos1) - 1),path)
       SET dclcmd = concat("dir/prot ",trim(disk),"[",trim(directory),"]",
        trim(dir_file),".dir")
      ELSE
       SET pos1 = findstring("[",path,1,1)
       SET pos2 = findstring("]",path,1,1)
       SET dir_file = substring((pos1+ 1),((pos2 - pos1) - 1),path)
       SET dclcmd = concat("dir/prot ",trim(disk),"[000000]",trim(dir_file),".dir")
      ENDIF
      CALL dclsetlogical(concat("pipe ",dclcmd," | search sys$input ",trim(dir_file)),"DIR_PROT")
      SET pos1 = findstring(",",logical("DIR_PROT"),1,1)
      SET pos2 = findstring(")",logical("DIR_PROT"),1,1)
      SET world_prot = substring((pos1+ 1),((pos2 - pos1) - 1),logical("DIR_PROT"))
      IF (findstring("R",world_prot,1) > 0)
       SET setup_info->syst4_security = "Success"
      ENDIF
     ENDIF
    ENDIF
    IF ((setup_info->t4data_logical="Success"))
     SET t4csv = concat("t4$data:t4_",trim(nodename),"_",format((curdate - 1),"DDMMMYYYY;;D"),
      "_%%%%_%%%%_comp.CSV")
    ELSE
     SET t4csv = concat("sys$t4:t4_",trim(nodename),"_",format((curdate - 1),"DDMMMYYYY;;D"),
      "_%%%%_%%%%.CSV")
    ENDIF
    CALL dclsetlogical(concat("dir/nohead/notrail ",trim(t4csv)),"T4FILE")
    SET logt4file = logical("T4FILE")
    IF (findfile(logt4file)=1)
     SET setup_info->t4_out_file = "Success"
    ENDIF
    CALL dclsetlogical(concat("pipe show security ",logt4file," | search sys$input Protection"),
     "PROTECTION")
    SET protection_str = logical("PROTECTION")
    SET cond1 = findstring("World: RWED",protection_str,1)
    SET cond2 = findstring("World: RWE",protection_str,1)
    SET cond3 = findstring("World: RE",protection_str,1)
    IF (((cond1 > 0) OR (((cond2 > 0) OR (cond3 > 0)) )) )
     SET setup_info->t4_file_security = "Success"
    ENDIF
    IF ((setup_info->t4sys_logical="Success"))
     IF (findfile("t4$sys:t4$config.com")=1)
      SET setup_info->vms_t4config40 = "Success"
     ENDIF
    ELSE
     IF (findfile("sys$t4:t4$config.com")=1)
      SET setup_info->vms_t4config32 = "Success"
     ENDIF
    ENDIF
   ENDIF
   IF (cursys2="AIX")
    SET nmonfile = build("nmon_",trim(nodename),"_",file_date_string,".out")
    SET setup_info->nmon_out_file = "Fail"
    SET dclcom = concat("ls -l $cer_nmon/data/",nmonfile," > ",nmonfile_tmp)
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
    FREE DEFINE rtl2
    DEFINE rtl2 nmonfile_tmp
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      nmonfile_str = substring(2,9,trim(a.line))
     WITH nocounter, maxrec = 1
    ;end select
    IF (nmonfile_str="r??r??r??")
     SET setup_info->nmon_out_file = "Success"
    ENDIF
    SET setup_info->aix_run_nmon = checkfile("cer_nmon/proc/esm_run_nmon.ksh")
   ENDIF
 END ;Subroutine
 SUBROUTINE checkrtms(z)
   SET setup_info->rtms_csv_file = "Fail"
   SET setup_info->timer_cerner = "Fail"
   SET reportdatestr = format(cnvtdatetime((curdate - 1),curtime2),"mmddyy;;D")
   IF (cursys="AXP")
    SET rtms_file = concat("cer_temp:sladiscrete",reportdatestr,"_",trim(nodename),"_00001",
     ".csv")
    IF (findfile(rtms_file)=1)
     SET setup_info->rtms_csv_file = "Success"
    ENDIF
    IF (findfile("cer_mgr:timer.cerner")=1)
     SET setup_info->timer_cerner = "Success"
    ENDIF
   ENDIF
   IF (cursys="AIX")
    SET rtms_file = concat("cer_temp/sladiscrete",reportdatestr,"_",trim(nodename),"_00001",
     ".csv")
    IF (findfile(rtms_file)=1)
     SET setup_info->rtms_csv_file = "Success"
    ENDIF
    IF (findfile("cer_mgr/timer.cerner")=1)
     SET setup_info->timer_cerner = "Success"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE checkdm_info(z)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="CLIENT MNEMONIC"
    DETAIL
     client_mnem = di.info_char
    WITH nocounter
   ;end select
   IF (((curqual=0) OR (client_mnem=null)) )
    SET setup_info->client_mnemonic = "Fail"
   ELSE
    SET setup_info->client_mnemonic = "Success"
   ENDIF
   SELECT INTO "nl:"
    FROM dm_info
    WHERE info_domain="DATA MANAGEMENT"
     AND info_name="DM_STAT_GATHER_OFF"
     AND info_char="Y"
   ;end select
   IF (curqual=0)
    SET setup_info->switch = "Success"
   ELSE
    SET setup_info->switch = "Fail"
   ENDIF
 END ;Subroutine
 SUBROUTINE checkquotas(z)
   SET setup_info->server66 = "Fail"
   SET setup_info->server54 = "Fail"
   IF (cursys="AXP")
    SET dclcom = concat('pipe show system/proc | search sys$input "_',trim(cmbinstance),' ",SRV0066',
     "/match=and/out = ",trim(srv66pid_tmp))
    SET len = size(trim(dclcom))
    SET status = 0
    CALL dcl(dclcom,len,status)
    SET dclcom2 = concat('pipe show system/proc | search sys$input "_',trim(cmbinstance),' ",SRV0054',
     "/match=and/out = ",trim(srv54pid_tmp))
    SET len2 = size(trim(dclcom2))
    SET status2 = 0
    CALL dcl(dclcom2,len2,status2)
    FREE DEFINE rtl2
    DEFINE rtl2 srv66pid_tmp
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      pos1 = findstring(" ",trim(a.line),1), server66_pid = substring(1,pos1,trim(a.line))
     WITH nocounter, maxrec = 1
    ;end select
    FREE DEFINE rtl2
    DEFINE rtl2 srv54pid_tmp
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      pos2 = findstring(" ",trim(a.line),1), server54_pid = substring(1,pos2,trim(a.line))
     WITH nocounter, maxrec = 1
    ;end select
    IF (server66_pid != "")
     CALL dclsetlogical(concat('write sys$output f$getjpi("',server66_pid,'","PGFLQUOTA")'),
      "SERVER66QUOTA")
     IF (cnvtint(logical("SERVER66QUOTA")) >= srvquota)
      SET setup_info->server66 = "Success"
     ENDIF
    ENDIF
    IF (server54_pid != "")
     CALL dclsetlogical(concat('write sys$output f$getjpi("',server54_pid,'","PGFLQUOTA")'),
      "SERVER54QUOTA")
     IF (cnvtint(logical("SERVER54QUOTA")) >= srvquota)
      SET setup_info->server54 = "Success"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dclsetlogical(cmd,cmdlog)
   SET dclcmd = concat("pipe ",trim(cmd)," | ","( read sys$input Line1 ; define/job/nolog ",trim(
     cmdlog),
    " &Line1 )")
   SET mystat = 0
   SET dcllen = size(trim(dclcmd))
   SET myrc = dcl(trim(dclcmd),dcllen,mystat)
   IF (mystat=0)
    CALL echo(build("ERROR: file missing or invalid command [",trim(dclcmd),"]"))
   ENDIF
 END ;Subroutine
 SUBROUTINE displayreport(z)
   SELECT
    *
    FROM dummyt
    HEAD REPORT
     col 0, "Database Monitoring Tools Setup Check", row + 1,
     col 0, "Date: ", curdate,
     " ", curtime, row + 1,
     col 0, "OS System: ", cursys2,
     row + 2, col 0, "PARAMETER",
     col 40, "STATUS", col 60,
     "REFERENCE DOCUMENT", row + 1
    DETAIL
     col 0, "MSA Configuration", row + 1,
     col 5, "MSA Server Logical", col 40,
     setup_info->msa_server_log
     IF ((setup_info->msa_server_log="Fail"))
      col 60, reference_docs->msa
     ENDIF
     row + 1, col 5, "MSA Client Mnemonic Logical",
     col 40, setup_info->msa_client_log
     IF ((setup_info->msa_client_log="Fail"))
      col 60, reference_docs->msa
     ENDIF
     row + 1, col 0, "DM Stats Files",
     row + 1
     IF (cursys="AXP")
      col 5, "esm_gather_millconfig.com", col 40,
      setup_info->vms_millconfig
      IF ((setup_info->vms_millconfig="Fail"))
       col 60, reference_docs->workinst
      ENDIF
      row + 1, col 5, "esm_gather_millconfig2.com",
      col 40, setup_info->vms_millconfig2
      IF ((setup_info->vms_millconfig2="Fail"))
       col 60, reference_docs->workinst
      ENDIF
      row + 1, col 5, "esm_gather_osconfig.com",
      col 40, setup_info->vms_osconfig
      IF ((setup_info->vms_osconfig="Fail"))
       col 60, reference_docs->workinst
      ENDIF
      row + 1, col 5, "esm_gather_osconfig2.com",
      col 40, setup_info->vms_osconfig2
      IF ((setup_info->vms_osconfig2="Fail"))
       col 60, reference_docs->workinst
      ENDIF
     ELSE
      col 5, "esm_gather_millconfig.ksh", col 40,
      setup_info->aix_millconfig
      IF ((setup_info->aix_millconfig="Fail"))
       col 60, reference_docs->workinst
      ENDIF
      row + 1, col 5, "esm_gather_millconfig2.ksh",
      col 40, setup_info->aix_millconfig2
      IF ((setup_info->aix_millconfig2="Fail"))
       col 60, reference_docs->workinst
      ENDIF
      IF (cursys2="AIX")
       row + 1, col 5, "esm_get_sysinfo.ksh",
       col 40, setup_info->aix_sysinfo
       IF ((setup_info->aix_sysinfo="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "esm_get_sysinfo2.ksh",
       col 40, setup_info->aix_sysinfo2
       IF ((setup_info->aix_sysinfo2="Fail"))
        col 60, reference_docs->workinst
       ENDIF
      ENDIF
      row + 1
     ENDIF
     IF (cursys="AXP")
      IF (t4version="3.2")
       col 0, "T4 version 3.2 Configuration", row + 1,
       col 5, "SYS$T4 logical Existence", col 40,
       setup_info->syst4_logical
       IF ((setup_info->syst4_logical="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "SYS$T4 Security",
       col 40, setup_info->syst4_security
       IF ((setup_info->syst4_security="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "CSV File Existence",
       col 40, setup_info->t4_out_file
       IF ((setup_info->t4_out_file="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "CSV File Security",
       col 40, setup_info->t4_file_security
       IF ((setup_info->t4_file_security="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "T4$CONFIG.COM Existence",
       col 40, setup_info->vms_t4config32
       IF ((setup_info->vms_t4config32="Fail"))
        col 60, reference_docs->workinst
       ENDIF
      ELSE
       row + 1, col 0, "T4 version 4.0 Configuration",
       row + 1, col 5, "T4$SYS logical Existence",
       col 40, setup_info->t4sys_logical
       IF ((setup_info->t4sys_logical="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "T4$DATA logical Existence",
       col 40, setup_info->t4data_logical
       IF ((setup_info->t4data_logical="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "T4$DATA Security",
       col 40, setup_info->t4data_security
       IF ((setup_info->t4data_security="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "CSV File Existence",
       col 40, setup_info->t4_out_file
       IF ((setup_info->t4_out_file="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "CSV File Security",
       col 40, setup_info->t4_file_security
       IF ((setup_info->t4_file_security="Fail"))
        col 60, reference_docs->workinst
       ENDIF
       row + 1, col 5, "T4$CONFIG.COM Existence",
       col 40, setup_info->vms_t4config40
       IF ((setup_info->vms_t4config40="Fail"))
        col 60, reference_docs->workinst
       ENDIF
      ENDIF
     ELSEIF (cursys2="AIX")
      col 0, "Nmon Configuration", row + 1,
      col 5, "Nmon Output File", col 40,
      setup_info->nmon_out_file
      IF ((setup_info->nmon_out_file="Fail"))
       col 60, reference_docs->workinst
      ENDIF
      row + 1, col 5, "esm_run_mnon.ksh",
      col 40, setup_info->aix_run_nmon
      IF ((setup_info->aix_run_nmon="Fail"))
       col 60, reference_docs->workinst
      ENDIF
     ENDIF
     row + 1, col 0, "RTMS Configuration",
     row + 1, col 5, "SLA csv file",
     col 40, setup_info->rtms_csv_file
     IF ((setup_info->rtms_csv_file="Fail"))
      col 60, reference_docs->rtms
     ENDIF
     row + 1, col 5, "TIMER.CERNER File",
     col 40, setup_info->timer_cerner
     IF ((setup_info->timer_cerner="Fail"))
      col 60, reference_docs->rtms
     ENDIF
     row + 1, col 0, "DM_INFO",
     row + 1, col 5, "Client Mnemonic",
     col 40, setup_info->client_mnemonic
     IF ((setup_info->client_mnemonic="Fail"))
      col 60, reference_docs->workinst
     ENDIF
     row + 1, col 5, "On/Off Switch",
     col 40, setup_info->switch
     IF ((setup_info->switch="Fail"))
      col 60, reference_docs->workinst
     ENDIF
     row + 1
     IF (cursys="AXP")
      col 0, "Server Quotas", row + 1,
      col 5, "Server 66", col 40,
      setup_info->server66
      IF ((setup_info->server66="Fail"))
       col 60, reference_docs->scp66
      ENDIF
      row + 1, col 5, "Server 54",
      col 40, setup_info->server54
      IF ((setup_info->server54="Fail"))
       col 60, reference_docs->scp54
      ENDIF
     ENDIF
    WITH nocounter, maxcol = 264
   ;end select
 END ;Subroutine
#exit_program
END GO
