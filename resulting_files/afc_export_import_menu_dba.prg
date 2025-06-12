CREATE PROGRAM afc_export_import_menu:dba
 PAINT
 IF ("Z"=validate(afc_export_import_menu_vrsn,"Z"))
  DECLARE afc_export_import_menu_vrsn = vc WITH noconstant("CHARGSRV-14227.004")
 ENDIF
 DECLARE exportfilename = vc WITH protect, noconstant("")
 DECLARE importfilename = vc WITH protect, noconstant("")
 SET filename = fillstring(80," ")
 SET loginattempts = 0
 EXECUTE cclseclogin
#loop
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,20,100)
 CALL text(2,4,"C H A R G E  S E R V I C E S  I M P O R T / E X P O R T")
 CALL text(4,4,"1)Export Bill Code and Price Information")
 CALL text(6,4,"2)Export Bill Item Information Only")
 CALL text(8,4,"3)Import Bill Code and Pricing Information")
 CALL text(10,4,"4)Export CDM Information")
 CALL text(12,4,"5)Import CDM Information")
 CALL text(14,4,"6)Update Bill Codes")
 CALL text(16,4,"7)Exit")
 CALL text(18,4,"Select ")
 CALL accept(18,12,"1;",7
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7))
 SET choice = curaccept
 IF (((choice=1) OR (choice=2)) )
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(4,4,"Enter the export filename (ccluserdir): ")
  CALL accept(4,44,"P(55);C")
  SET file = curaccept
  SET filename = concat("ccluserdir:",trim(file))
  CALL text(5,4,"Select activity type (<enter> for all or <shift f5> for help): ")
  SET help =
  SELECT
   code_value = cv.code_value"#################;l", cv.display
   FROM code_value cv
   WHERE cv.code_set=106
    AND cv.active_ind=1
   ORDER BY cv.display
   WITH nocounter
  ;end select
  CALL accept(5,67,"9(17);DSC",0)
  SET activitytype = cnvtreal(curaccept)
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(4,4,"Exporting bill item information...")
  EXECUTE afc_export_bill_items filename, activitytype, choice
  GO TO loop
 ELSEIF (choice=3)
  CALL clear(1,1)
  CALL video(i)
  CALL box(1,2,20,100)
  CALL text(2,4,"B I L L  I T E M  I M P O R T / E X P O R T")
  CALL text(5,4,"Username: ")
  CALL accept(5,14,"P(30);C")
  SET username = curaccept
  CALL text(6,4,"Domain: ")
  CALL accept(6,14,"P(30);C")
  SET domain = curaccept
  CALL text(7,4,"Password: ")
  CALL accept(7,14,"p(30);cue"," ")
  SET password = curaccept
  CALL text(8,4,"Database string username: ")
  CALL accept(8,30,"p(30);C")
  SET databasestringusername = curaccept
  CALL text(9,4,"Database string password: ")
  CALL accept(9,30,"p(30);cue"," ")
  SET databasestringpassword = curaccept
  SET databasestring = concat(trim(databasestringusername),"/",trim(databasestringpassword))
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(4,4,"Enter the import filename (ccluserdir): ")
  CALL accept(4,44,"P(55);C")
  SET filename = curaccept
  IF ((xxcclseclogin->loggedin=1))
   FOR (x = 4 TO 18)
     CALL clear(x,4,95)
   ENDFOR
   CALL text(4,4,"Importing bill item information...")
   IF (cursys="AIX")
    EXECUTE dm_dbimport concat("CCLUSERDIR:",trim(filename)), "afc_import_bill_items", 0
   ELSE
    SET com = fillstring(500," ")
    SET com = concat("dbimport ccluserdir:",trim(filename)," 1 100 0 oracle:",trim(databasestring),
     " afc_import_bill_items afc_import 4 ",
     trim(username),":",trim(domain),":",trim(password))
    SET com1 = fillstring(175," ")
    SET com1 = trim(com)
    SELECT INTO "afc_import.tmp"
     d.seq
     FROM dummyt d
     DETAIL
      col 0, "$dbimport:==$cer_exe:dbimport.exe", row + 1,
      col 0, com1
     WITH nocounter, maxcol = 200
    ;end select
    SET stat = 0
    SET com1 = "@afc_import.tmp"
    CALL dcl(com1,size(trim(com1)),stat)
    SET com2 = "del afc_import.tmp;*"
    CALL dcl(com2,size(trim(com2)),stat)
   ENDIF
  ENDIF
  CALL clear(4,4,95)
  CALL text(4,4,"Updating Bill Code Information...")
  SET schedule = 0
  EXECUTE afc_upt_bill_codes schedule
  GO TO loop
 ELSEIF (choice=4)
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(4,4,"Enter the export filename (ccluserdir): ")
  CALL accept(4,44,"P(55);C")
  SET file = curaccept
  SET exportfilename = concat("ccluserdir:",trim(file))
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(4,4,concat("Exporting CDM information to ",exportfilename,"... Please wait."))
  EXECUTE afc_export_charge_desc_master exportfilename
  CALL text(6,4,"Done.")
  GO TO loop
 ELSEIF (choice=5)
  CALL clear(1,1)
  CALL video(i)
  CALL box(1,2,20,100)
  CALL text(2,4,"C H A R G E  D E S C  M A S T E R  I M P O R T")
  CALL text(4,4,"Enter the import filename (ccluserdir): ")
  CALL accept(4,44,"P(55);C")
  SET filename = curaccept
  SET importfilename = concat("ccluserdir:",trim(filename))
  IF ((xxcclseclogin->loggedin=1))
   FOR (x = 4 TO 18)
     CALL clear(x,4,95)
   ENDFOR
   CALL text(4,4,concat("Importing charge desc master information from ",importfilename,
     "... Please wait."))
   EXECUTE dm_dbimport importfilename, "afc_import_charge_desc_master", 0
   CALL text(6,4,"Done.")
  ELSE
   CALL text(6,4,"Failed to login.")
   CALL pause(3)
  ENDIF
  GO TO loop
 ELSEIF (choice=6)
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(5,4,"Select bill code schedules (<enter> for all or <shift f5> for help): ")
  SET help =
  SELECT
   code_value = cv.code_value"#################;l", cv.display
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.active_ind=1
    AND cv.cdf_meaning IN ("CPT4", "HCPCS", "MODIFIER", "PROCCODE", "REVENUE")
   ORDER BY cv.display
   WITH nocounter
  ;end select
  CALL accept(5,75,"9(17);DSC",0)
  SET schedule = cnvtreal(curaccept)
  FOR (x = 4 TO 18)
    CALL clear(x,4,95)
  ENDFOR
  CALL text(4,4,"Updating Bill Code Information...")
  EXECUTE afc_upt_bill_codes schedule
  GO TO loop
 ELSEIF (choice=7)
  GO TO end_program
 ENDIF
#end_program
 CALL clear(1,1)
END GO
