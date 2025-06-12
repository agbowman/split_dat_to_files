CREATE PROGRAM cclseclogin2:dba
 PROMPT
  "Security Username : " = "test",
  "Security Domain   : " = "test",
  "Security Password : " = "test"
 SET val = validate(xxcclseclogin->loggedin,99)
 IF (val=99)
  RECORD xxcclseclogin(
    1 loggedin = i4
  ) WITH persist
 ENDIF
 SET stat = uar_sec_login(nullterm( $1),nullterm( $2),nullterm( $3))
 IF (((stat=0) OR (stat=15)) )
  IF (validate(reqinfo)=0)
   RECORD reqinfo(
     1 reqinfo
       2 updt_app = i4
       2 updt_task = i4
       2 updt_req = i4
       2 updt_id = f8
       2 updt_applctx = i4
       2 position_cd = f8
       2 commit_ind = i2
       2 perform_cnt = i4
       2 client_node_name = c100
       2 domain_network_id = f8
   ) WITH persist
  ENDIF
  SELECT INTO nl
   FROM prsnl p
   WHERE p.username=cnvtupper( $1)
   DETAIL
    reqinfo->updt_id = p.person_id
   WITH nocounter
  ;end select
  SET xxcclseclogin->loggedin = 1
  CALL echo(build("UAR_SEC_LOGIN Valid =",stat))
 ELSE
  SET xxcclseclogin->loggedin = 0
  CALL echo(build("UAR_SEC_LOGIN Invalid =",stat))
 ENDIF
END GO
