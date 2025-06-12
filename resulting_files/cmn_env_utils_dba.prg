CREATE PROGRAM cmn_env_utils:dba
 DECLARE PUBLIC::cmngetcurrentusername(null) = vc WITH copy
 IF (checkfun("UT_CMN_ENV_UTILS_MAIN")=7)
  CALL ut_cmn_env_utils_main(null)
 ENDIF
 SUBROUTINE PUBLIC::cmngetcurrentusername(null)
   DECLARE theusername = c51 WITH protect
   DECLARE stat = i4 WITH protect
   SET stat = uar_secgetclientusername(theusername,51)
   IF (stat > 0)
    RETURN(trim(theusername))
   ENDIF
   SET stat = uar_secgetusername(theusername,51)
   RETURN(trim(theusername))
 END ;Subroutine
END GO
