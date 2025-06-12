CREATE PROGRAM bmdi_troubleshooting:dba
 SET message = noinformation
 SET trace = nocost
 SET trace = recpersist
 RECORD ccllogin(
   1 loggedin = i4
   1 username = c30
   1 domain = c30
   1 password = c30
 )
 SET valid = 0
 WHILE (valid=0)
   CALL clear(1,1)
   CALL text(1,1,"V500 UserName")
   CALL text(2,1,"V500 Domain")
   CALL text(3,1,"V500 Password")
   CALL accept(1,20,"p(30);cu")
   SET ccllogin->username = curaccept
   CALL accept(2,20,"p(30);cu")
   SET ccllogin->domain = curaccept
   SET ccllogin->password = fillstring(30," ")
   CALL accept(3,20,"p(30);cue"," ")
   SET ccllogin->password = curaccept
   SET xloginck = validate(xxcclseclogin->loggedin,99)
   IF (xloginck != 1)
    SET stat = uar_sec_login(nullterm(cnvtupper(ccllogin->username)),nullterm(cnvtupper(ccllogin->
       domain)),nullterm(cnvtupper(ccllogin->password)))
    RECORD xxcclseclogin(
      1 loggedin = i4
    )
    IF (stat=0)
     SET valid = 1
     SET xxcclseclogin->loggedin = 1 WITH persist
    ELSE
     CALL text(5,5,build("V500 SECURITY LOGIN FAILURE WITH STATUS =",stat))
     SET valid = 0
     CALL text(6,1,"Enter Y to continue")
     CALL accept(6,25,"p;cu","Y")
     IF (curaccept != "Y")
      SET valid = 1
     ENDIF
    ENDIF
   ELSE
    SET valid = 1
   ENDIF
 ENDWHILE
#main_menu
 CALL clear(1,1)
 CALL video(nw)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"BMDI TROUBLESHOOTING UTILITY")
 CALL box(4,9,22,72)
 CALL line(6,9,64,xhor)
 CALL text(5,11," MAIN MENU")
 CALL text(7,11," 1. View formatted results")
 CALL text(9,11," 2. View current patient associations")
 CALL text(11,11," 3. View patient association audit")
 CALL text(13,11," 4. View BMDI parameter build")
 CALL text(15,11," 5. View BMDI HL7 mapping")
 CALL text(17,11," 6. View performance")
 CALL text(19,11," 7. BMDI options")
 CALL text(21,11," 8. Anesthesia")
 CALL text(24,2,"Select an item number or 9 to exit:  ")
 CALL accept(24,40,"99",0
  WHERE curaccept >= 0
   AND curaccept <= 9)
 CASE (curaccept)
  OF 1:
   GO TO view_formatted_results
  OF 2:
   GO TO view_associated_patients
  OF 3:
   GO TO view_patient_association_audit
  OF 4:
   GO TO view_parameter_build
  OF 5:
   GO TO view_hl7_mapping
  OF 6:
   GO TO view_performance
  OF 7:
   GO TO bmdi_setup
  OF 8:
   GO TO anesthesia
  ELSE
   GO TO exit_script
 ENDCASE
 GO TO main_menu
#view_formatted_results
 EXECUTE bmdi_formatted_results
 GO TO main_menu
#view_associated_patients
 EXECUTE bmdi_patient_association_view
 GO TO main_menu
#view_patient_association_audit
 EXECUTE bmdi_patient_association_audit
 GO TO main_menu
#view_parameter_build
 EXECUTE bmdi_parameter_build
 GO TO main_menu
#view_hl7_mapping
 EXECUTE bmdi_hl7_mapping
 GO TO main_menu
#bmdi_setup
 EXECUTE bmdi_build
 GO TO main_menu
#anesthesia
 EXECUTE bmdi_anes
 GO TO main_menu
#view_performance
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,16,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI TROUBLESHOOTING UTILITY")
 CALL box(6,9,14,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11," VIEW PERFORMANCE")
 CALL text(9,11," 1. View interface performance")
 CALL text(11,11," 2. View server performance")
 CALL text(13,11," 3. Back to main menu")
 CALL text(18,2,"Select an item number:  ")
 CALL accept(18,25,"9",0
  WHERE curaccept > 0
   AND curaccept <= 3)
 CASE (curaccept)
  OF 1:
   EXECUTE bmdi_interface_performance
  OF 2:
   EXECUTE bmdi_server_performance
  ELSE
   GO TO main_menu
 ENDCASE
 GO TO main_menu
#exit_script
END GO
