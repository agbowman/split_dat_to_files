CREATE PROGRAM ccldic_vms_unix_post:dba
 DECLARE buf1 = vc
 DECLARE stat1 = i4
 DECLARE stat2 = i4
 DROP TABLE dictmp1
 SELECT INTO TABLE dictmp1
  rec = fillstring(851," ")
  FROM dummyt
  WHERE 1=0
  WITH nocounter, format = binary
 ;end select
 DEFINE dictmp1 "ccldictmp.dat"
 SELECT INTO TABLE dictmp2
  ky1 = substring(1,40,r.rec), data = substring(41,810,r.rec)
  FROM dictmp1 r
  WHERE r.rec="H0000*"
  ORDER BY ky1
  WITH counter, organization = i
 ;end select
 FREE DEFINE dictmp1
 SET stat2 = 0
 IF (cursys="AIX")
  SET buf1 = "cp $CCLDIR/dummy.dat $CCLUSERDIR/dummy.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "rm dictmp1.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "rm ccldictmp.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "mv dictmp2.dat dic.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "mv dictmp2.idx dic.idx"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "$cer_exe/cclisamcheck dic"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  CALL echo("dic.dat and  dic.idx are in ccluserdir now")
 ELSEIF (cursys="WIN")
  DECLARE _ccldir = vc
  DECLARE _ccluserdir = vc
  SET _ccldir = trim(logical("CCLDIR"))
  SET _ccluserdir = trim(logical("CCLUSERDIR"))
  SET buf1 = concat("copy ",_ccldir,"\\dummy.dat ",_ccluserdir,"\\dummy.dat")
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "del dictmp1.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "del ccldictmp.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "ren dictmp2.dat dic.dat"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  SET buf1 = "ren dictmp2.idx dic.idx"
  SET stat1 = dcl(buf1,size(buf1),stat2)
  CALL echo("dic.dat and  dic.idx are in ccluserdir now")
 ELSEIF (cursys="AXP")
  CALL echo("ccldic_vms_unix_post - VMS platform not supported..")
 ENDIF
END GO
