CREATE PROGRAM cs_run_batch:dba
 SET b_user = "system"
 SET b_domain = "cert"
 SET b_pwd = "system"
 SET b_dblogin = "v500/v500"
 SET com = fillstring(132," ")
 SET b_date = format(curdate,"YYYYMMDD;;D")
 IF (cursys="AIX")
  SET run_line = concat("csbatch user:",b_user," pwd:",b_pwd," domain:",
   b_domain," dblogin:",b_dblogin," date:",b_date)
  SELECT INTO "cs_batch_com.ksh"
   d.seq
   FROM dummyt d
   WHERE d.seq > 0
   DETAIL
    col 0, "#!/usr/bin/ksh", row + 1,
    col 0, "alias csbatch='$cer_exe/cs_batch'", row + 1,
    col 0, run_line
   WITH maxcol = 132, format = variable, noformfeed,
    maxrow = 1, noheading, nocounter
  ;end select
  SET stat = 0
  SET com = "chmod a+rwx cs_batch_com.ksh"
  CALL dcl(com,size(trim(com)),stat)
  SET com = "./cs_batch_com.ksh"
  CALL dcl(com,size(trim(com)),stat)
  SET com = "rm cs_batch_com.ksh*"
  CALL dcl(com,size(trim(com)),stat)
 ELSE
  SET run_line = concat("$csbatch user:",b_user," pwd:",b_pwd," domain:",
   b_domain," dblogin:",b_dblogin," date:",b_date)
  SELECT INTO "cs_batch_com.tmp"
   d.seq
   FROM dummyt d
   WHERE d.seq > 0
   DETAIL
    col 0, "$csbatch :== $cer_exe:cs_batch.exe", row + 1,
    col 0, run_line
   WITH maxcol = 132, format = variable, noformfeed,
    maxrow = 1, noheading, nocounter
  ;end select
  SET stat = 0
  SET com = "@cs_batch_com.tmp"
  CALL dcl(com,size(trim(com)),stat)
  SET com = "del cs_batch_com.tmp;*"
  CALL dcl(com,size(trim(com)),stat)
 ENDIF
#9999_end
END GO
