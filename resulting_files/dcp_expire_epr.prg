CREATE PROGRAM dcp_expire_epr
 PAINT
 EXECUTE cclseclogin
 CALL video(n)
 SET width = 132
 DECLARE displayinstructions(null) = c1
 DECLARE checkruncleanup(null) = c1
 DECLARE promptdischargecriteria(null) = null
 DECLARE promptadmitcriteria(null) = null
 DECLARE promptbegeffectivecriteria(null) = null
 DECLARE promptinactiveenccriteria(null) = null
 DECLARE promptfinalverifycriteria(null) = c1
 DECLARE executeplan(null) = null
 DECLARE continue = c1 WITH noconstant(" "), private
 DECLARE runcleanup = c1 WITH noconstant(" ")
 DECLARE dischexceptioncd = f8 WITH noconstant(0.0)
 DECLARE dischdays = i4 WITH noconstant(0)
 DECLARE admitexceptioncd = f8 WITH noconstant(0.0)
 DECLARE admitdays = i4 WITH noconstant(0)
 DECLARE begeffexceptioncd = f8 WITH noconstant(0.0)
 DECLARE begeffdays = i4 WITH noconstant(0)
 DECLARE inactiveencexceptioncd = f8 WITH noconstant(0.0)
 DECLARE inactiveencdays = i4 WITH noconstant(0)
 SET continue = displayinstruction(null)
 CASE (continue)
  OF "C":
   SET runcleanup = checkruncleanup(null)
  OF "Q":
   GO TO exit_script
 ENDCASE
 CALL promptdischargecriteria(null)
 CALL promptadmitcriteria(null)
 CALL promptbegeffectivecriteria(null)
 CALL promptinactiveenccriteria(null)
 SET continue = promptfinalverifycriteria(null)
 CASE (continue)
  OF "C":
   CALL executeplan(null)
  OF "Q":
   GO TO exit_script
 ENDCASE
 SUBROUTINE displayinstruction(null)
   DECLARE colcnt = i4 WITH noconstant(10)
   DECLARE rowcnt = i4 WITH noconstant(4)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,26,"Instructions",wide)
   CALL text(rowcnt,colcnt,
    "This program will walk you through running the proper scripts to expire rows on the")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"ENCNTR_PRSNL_RELTN (EPR) table.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"It will perform the following tasks:")
   SET colcnt = 14
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "1) Give the user the option to run the script that will expire EPR rows that are no longer valid."
    )
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "2) Give the user the option to expire EPR rows so many days after discharged, admitted, begin ")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,
    " effective, and\or encounter inactive.  Make sure to have the number of days desired and a ")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,
    " CODE VALUE from code set 333 if you want a certain relationship type to be excluded.  ")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,
    " Each rule can have its own number of days and excluded relationship type.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"3) After all the criteria is set the user will verify before continuing."
    )
   CALL text(24,04,"Do you want to (C)ontinue or (Q)uit? ")
   CALL accept(24,41,"p(1);cu"," "
    WHERE curaccept IN ("C", "Q"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE checkruncleanup(null)
   DECLARE colcnt = i4 WITH noconstant(10)
   DECLARE rowcnt = i4 WITH noconstant(4)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,26,"Run Cleanup",wide)
   CALL text(rowcnt,colcnt,
    "The cleanup script will expire EPR rows if they meet any of the following criteria.")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,
    "It is suggested to run this script if it has not been run in the past month.")
   SET colcnt = 14
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"EPRs will be expired if they meet any of the following criteria:")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"1) prsnl_person_id = 0")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"2) encntr_prsnl_r_cd = 0")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"3) active_ind = 0")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,"4) end_effective_dt_tm < cnvtdatetime(curdate, curtime3)")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "5) Expire all rows that have a duplicate based on encntr_id, prsnl_person_id, and encntr_prsnl_r_cd."
    )
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,
    "It must also have a past or not specified (date of 12/31/2100) end_effective_dt_tm.  It does not"
    )
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,
    " expire the most recent of the duplicates based on encntr_prsnl_reltn_id.")
   CALL text(24,04,"Do you want to run the cleanup script (Y)/(N)? ")
   CALL accept(24,50,"p(1);cu","Y"
    WHERE curaccept IN ("Y", "N"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE promptdischargecriteria(null)
   DECLARE colcnt = i4 WITH noconstant(10)
   DECLARE rowcnt = i4 WITH noconstant(4)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,25,"Discharge Criteria",wide)
   CALL text(rowcnt,colcnt,
    "This rule will expire all EPRs that are tied to an encounter that have a disch_dt_tm")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"for a given number of days in the past.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "A single code value from code set 333 can also be used to exclude a relationship type.")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"A value of 0 (default) means no code values will be excluded.")
   CALL text(24,04,"Use discharge criteria (Y)/(N)? ")
   CALL accept(24,36,"p(1);cu","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text(24,42,"Days: ")
    CALL accept(24,48,"9(2);cu","30"
     WHERE cnvtint(curaccept) BETWEEN 1 AND 45)
    SET dischdays = cnvtint(curaccept)
    CALL text(24,55,"Code Value: ")
    CALL accept(24,67,"9(12);cu","0"
     WHERE ((uar_get_code_by("DISPLAY",333,trim(uar_get_code_display(cnvtreal(curaccept))))=cnvtreal(
      curaccept)) OR (cnvtint(curaccept)=0)) )
    SET dischexceptioncd = cnvtreal(curaccept)
   ENDIF
 END ;Subroutine
 SUBROUTINE promptadmitcriteria(null)
   DECLARE colcnt = i4 WITH noconstant(10)
   DECLARE rowcnt = i4 WITH noconstant(4)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,25,"Admit Criteria",wide)
   CALL text(rowcnt,colcnt,
    "This rule will expire all EPRs that are tied to an encounter that have a reg_dt_tm")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"for a given number of days in the past.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "A single code value from code set 333 can also be used to exclude a relationship type.")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"A value of 0 (default) means no code values will be excluded.")
   CALL text(24,04,"Use admit criteria (Y)/(N)? ")
   CALL accept(24,36,"p(1);cu","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text(24,42,"Days: ")
    CALL accept(24,48,"9(2);cu","30"
     WHERE cnvtint(curaccept) BETWEEN 1 AND 45)
    SET admitdays = cnvtint(curaccept)
    CALL text(24,55,"Code Value: ")
    CALL accept(24,67,"9(12);cu","0"
     WHERE ((uar_get_code_by("DISPLAY",333,trim(uar_get_code_display(cnvtreal(curaccept))))=cnvtreal(
      curaccept)) OR (cnvtint(curaccept)=0)) )
    SET admitexceptioncd = cnvtreal(curaccept)
   ENDIF
 END ;Subroutine
 SUBROUTINE promptbegeffectivecriteria(null)
   DECLARE colcnt = i4 WITH noconstant(10)
   DECLARE rowcnt = i4 WITH noconstant(4)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,20,"Begin Effective Criteria",wide)
   CALL text(rowcnt,colcnt,
    "This rule will expire all EPRs that have a beg_effective_dt_tm for a given number of days")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"in the past.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "A single code value from code set 333 can also be used to exclude a relationship type.")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"A value of 0 (default) means no code values will be excluded.")
   CALL text(24,04,"Use begin effective criteria (Y)/(N)? ")
   CALL accept(24,42,"p(1);cu","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text(24,48,"Days: ")
    CALL accept(24,54,"9(2);cu","30"
     WHERE cnvtint(curaccept) BETWEEN 1 AND 45)
    SET begeffdays = cnvtint(curaccept)
    CALL text(24,61,"Code Value: ")
    CALL accept(24,73,"9(12);cu","0"
     WHERE ((uar_get_code_by("DISPLAY",333,trim(uar_get_code_display(cnvtreal(curaccept))))=cnvtreal(
      curaccept)) OR (cnvtint(curaccept)=0)) )
    SET begeffexceptioncd = cnvtreal(curaccept)
   ENDIF
 END ;Subroutine
 SUBROUTINE promptinactiveenccriteria(null)
   DECLARE colcnt = i4 WITH noconstant(10)
   DECLARE rowcnt = i4 WITH noconstant(4)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,20,"Inactive Encounter Criteria",wide)
   CALL text(rowcnt,colcnt,
    "This rule will expire all EPRs that have an active_ind = 0 and an active_status_dt_tm ")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"for a given number of days in the past.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,colcnt,
    "A single code value from code set 333 can also be used to exclude a relationship type.")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,colcnt,"A value of 0 (default) means no code values will be excluded.")
   CALL text(24,04,"Use inactive encounter criteria (Y)/(N)? ")
   CALL accept(24,42,"p(1);cu","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    CALL text(24,48,"Days: ")
    CALL accept(24,54,"9(2);cu","30"
     WHERE cnvtint(curaccept) BETWEEN 1 AND 45)
    SET inactiveencdays = cnvtint(curaccept)
    CALL text(24,61,"Code Value: ")
    CALL accept(24,73,"9(12);cu","0"
     WHERE ((uar_get_code_by("DISPLAY",333,trim(uar_get_code_display(cnvtreal(curaccept))))=cnvtreal(
      curaccept)) OR (cnvtint(curaccept)=0)) )
    SET inactiveencexceptioncd = cnvtreal(curaccept)
   ENDIF
 END ;Subroutine
 SUBROUTINE promptfinalverifycriteria(null)
   DECLARE rowcnt = i4 WITH noconstant(3)
   CALL clear(1,1)
   CALL box(2,1,23,132)
   CALL text(1,24,"Verify Criteria",wide)
   CALL text(rowcnt,10,
    "Verify the following settings are correct. Once you choose to continue it will")
   SET rowcnt = (rowcnt+ 1)
   CALL text(rowcnt,10,"commit the data and may take several hours to finish.")
   SET rowcnt = (rowcnt+ 2)
   CALL text(rowcnt,10,build("Run the EPR cleanup script? "))
   CALL text(rowcnt,62,build(runcleanup))
   SET rowcnt = (rowcnt+ 2)
   IF (dischdays > 0)
    CALL text(rowcnt,10,"Discharge Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,build("Days after discharge: "))
    CALL text(rowcnt,62,build(dischdays))
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Relationship type exception display (Code Value): ")
    IF (dischexceptioncd > 0)
     CALL text(rowcnt,62,build(uar_get_code_display(dischexceptioncd)," (",cnvtint(dischexceptioncd),
       ")"))
    ELSE
     CALL text(rowcnt,62,"None (None)")
    ENDIF
    SET rowcnt = (rowcnt+ 2)
   ELSE
    CALL text(rowcnt,10,"Discharge Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Do not use discharge criteria.")
    SET rowcnt = (rowcnt+ 2)
   ENDIF
   IF (admitdays > 0)
    CALL text(rowcnt,10,"Admit Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,build("Days after discharge: "))
    CALL text(rowcnt,62,build(admitdays))
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Relationship type exception display (Code Value): ")
    IF (admitexceptioncd > 0)
     CALL text(rowcnt,62,build(uar_get_code_display(admitexceptioncd)," (",cnvtint(admitexceptioncd),
       ")"))
    ELSE
     CALL text(rowcnt,62,"None (None)")
    ENDIF
    SET rowcnt = (rowcnt+ 2)
   ELSE
    CALL text(rowcnt,10,"Admit Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Do not use admit criteria.")
    SET rowcnt = (rowcnt+ 2)
   ENDIF
   IF (begeffdays > 0)
    CALL text(rowcnt,10,"Begin effective Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,build("Days after discharge: "))
    CALL text(rowcnt,62,build(begeffdays))
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Relationship type exception display (Code Value): ")
    IF (begeffexceptioncd > 0)
     CALL text(rowcnt,62,build(uar_get_code_display(begeffexceptioncd)," (",cnvtint(begeffexceptioncd
        ),")"))
    ELSE
     CALL text(rowcnt,62,"None (None)")
    ENDIF
    SET rowcnt = (rowcnt+ 2)
   ELSE
    CALL text(rowcnt,10,"Begin Effective Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Do not use begin effective criteria.")
    SET rowcnt = (rowcnt+ 2)
   ENDIF
   IF (inactiveencdays > 0)
    CALL text(rowcnt,10,"Inactive Encounter Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,build("Days after inactive: "))
    CALL text(rowcnt,62,build(inactiveencdays))
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Relationship type exception display (Code Value): ")
    IF (inactiveencexceptioncd > 0)
     CALL text(rowcnt,62,build(uar_get_code_display(inactiveencexceptioncd)," (",cnvtint(
        inactiveencexceptioncd),")"))
    ELSE
     CALL text(rowcnt,62,"None (None)")
    ENDIF
    SET rowcnt = (rowcnt+ 2)
   ELSE
    CALL text(rowcnt,10,"Inactive Encounter Criteria")
    SET rowcnt = (rowcnt+ 1)
    CALL text(rowcnt,12,"Do not use inactive encounter criteria.")
    SET rowcnt = (rowcnt+ 2)
   ENDIF
   CALL text(24,04,"Do you want to (C)ontinue or (Q)uit? ")
   CALL accept(24,41,"p(1);cu"," "
    WHERE curaccept IN ("C", "Q"))
   RETURN(curaccept)
 END ;Subroutine
 SUBROUTINE executeplan(null)
  IF (runcleanup="Y")
   EXECUTE dcp_expire_epr_cleanup
  ENDIF
  EXECUTE dcp_expire_epr_aggressive dischdays, dischexceptioncd, admitdays,
  admitexceptioncd, begeffdays, begeffexceptioncd,
  inactiveencdays, inactiveencexceptioncd
 END ;Subroutine
#exit_script
END GO
