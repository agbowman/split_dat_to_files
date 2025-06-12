CREATE PROGRAM acm_chg_entity_updt_test:dba
 IF ((validate(run_acm_entity_updt,- (999))=- (999)))
  DECLARE run_acm_entity_updt = i2 WITH noconstant(1)
  DECLARE s_lacm_chg_entity_updt_status = i2 WITH noconstant(false)
  DECLARE s_entity_curprog = vc WITH protected, noconstant(curprog)
  RECORD acm_chg_entity_updt_request(
    1 call_echo_ind = i2
    1 curprog = vc
    1 entity_type_cnt = i4
    1 entity_type_qual[*]
      2 entity_type = vc
      2 entity_id_cnt = i4
      2 entity_id_qual[*]
        3 entity_id = f8
  )
  RECORD acm_chg_entity_updt_reply(
    1 entity_type_cnt = i4
    1 entity_type_qual[*]
      2 entity_type = vc
      2 entity_id_cnt = i4
      2 entity_id_qual[*]
        3 entity_id = f8
        3 status = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  RECORD entityprimarykeys(
    1 primarykeylistsize = i4
    1 primarykeycurrentsize = i4
    1 ids_qual[*]
      2 primary_key_id = f8
  )
 ELSEIF (run_acm_entity_updt=0)
  SET run_acm_entity_updt = 1
  SET stat = alterlist(acm_chg_entity_updt_request->entity_type_qual,0)
  SET acm_chg_entity_updt_request->entity_type_cnt = 0
  SET s_entity_curprog = curprog
 ENDIF
 DECLARE s_executeentityupdates(_null) = i2
 DECLARE s_getprimarylistsize(_null) = i4
 DECLARE s_clearall(_null) = i2
 DECLARE s_clearprimarykeys(_null) = i2
 DECLARE s_getdeclaringprog(_null) = vc
 SUBROUTINE (s_requestaddtoprimarykeyslist(dprimarykeyid=f8) =i2)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE s_getprimarylistsize(_null)
   RETURN(entityprimarykeys->primarykeylistsize)
 END ;Subroutine
 SUBROUTINE s_clearprimarykeys(_null)
   SET stat = alterlist(entityprimarykeys->ids_qual,0)
   SET entityprimarykeys->primarykeylistsize = 0
   SET entityprimarykeys->primarykeycurrentsize = 0
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (s_requestaddtolist(dentityid=f8,sentitytype=vc) =i2)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE s_executeentityupdates(_null)
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (s_getrequestlistsize(sentitytype=vc) =i4)
   SET sentitytype = cnvtupper(sentitytype)
   DECLARE s_idx = i4 WITH protect, noconstant(0)
   FOR (s_idx = 1 TO acm_chg_entity_updt_request->entity_type_cnt)
     IF ((sentitytype=acm_chg_entity_updt_request->entity_type_qual[s_idx].entity_type))
      RETURN(acm_chg_entity_updt_request->entity_type_qual[s_idx].entity_id_cnt)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE s_clearall(_null)
   FREE RECORD entityprimarykeys
   FREE RECORD acm_chg_entity_updt_request
   FREE RECORD acm_chg_entity_updt_reply
   SET s_lacm_chg_entity_updt_status = 0
   RETURN(true)
 END ;Subroutine
 SUBROUTINE s_getdeclaringprog(_null)
   RETURN(s_entity_curprog)
 END ;Subroutine
 CALL echo(build("Current Parent Program = ",s_getdeclaringprog(0)))
 CALL echo("*** Building list - s_requestaddtolist")
 CALL s_requestaddtolist(99999999.00,"PERSON")
 CALL s_requestaddtolist(992710.00,"PERSON")
 CALL s_requestaddtolist(992711.00,"PERSON")
 CALL s_requestaddtolist(992712.00,"PERSON")
 CALL s_requestaddtolist(992713.00,"PERSON")
 CALL s_requestaddtolist(992714.00,"PERSON")
 CALL s_requestaddtolist(992715.00,"PERSON")
 CALL s_requestaddtolist(992716.00,"PERSON")
 CALL s_requestaddtolist(992722.00,"PERSON")
 CALL s_requestaddtolist(992723.00,"PERSON")
 CALL s_requestaddtolist(992724.00,"PERSON")
 CALL s_requestaddtolist(992725.00,"PERSON")
 CALL s_requestaddtolist(992726.00,"PERSON")
 CALL s_requestaddtolist(992727.00,"PERSON")
 CALL s_requestaddtolist(992728.00,"PERSON")
 CALL s_requestaddtolist(992729.00,"PERSON")
 CALL s_requestaddtolist(992730.00,"PERSON")
 CALL s_requestaddtolist(992731.00,"PERSON")
 CALL s_requestaddtolist(992732.00,"PERSON")
 CALL s_requestaddtolist(992733.00,"PERSON")
 CALL s_requestaddtolist(992734.00,"PERSON")
 CALL s_requestaddtolist(992735.00,"PERSON")
 CALL s_requestaddtolist(992736.00,"PERSON")
 CALL s_requestaddtolist(992737.00,"PERSON")
 CALL s_requestaddtolist(992738.00,"PERSON")
 CALL s_requestaddtolist(992739.00,"PERSON")
 CALL s_requestaddtolist(992740.00,"PERSON")
 CALL s_requestaddtolist(992741.00,"PERSON")
 CALL s_requestaddtolist(992742.00,"PERSON")
 CALL s_requestaddtolist(992743.00,"PERSON")
 CALL s_requestaddtolist(992744.00,"PERSON")
 CALL s_requestaddtolist(992745.00,"PERSON")
 CALL s_requestaddtolist(992746.00,"PERSON")
 CALL s_requestaddtolist(992747.00,"PERSON")
 CALL s_requestaddtolist(992748.00,"PERSON")
 CALL s_requestaddtolist(992749.00,"PERSON")
 CALL s_requestaddtolist(992750.00,"PERSON")
 CALL s_requestaddtolist(992751.00,"PERSON")
 CALL s_requestaddtolist(992752.00,"PERSON")
 CALL s_requestaddtolist(992753.00,"PERSON")
 CALL s_requestaddtolist(992754.00,"PERSON")
 CALL s_requestaddtolist(992755.00,"PERSON")
 CALL s_requestaddtolist(992756.00,"PERSON")
 CALL s_requestaddtolist(992757.00,"PERSON")
 CALL s_requestaddtolist(992758.00,"PERSON")
 CALL s_requestaddtolist(992759.00,"PERSON")
 CALL s_requestaddtolist(992760.00,"PERSON")
 CALL s_requestaddtolist(992761.00,"PERSON")
 CALL s_requestaddtolist(992762.00,"PERSON")
 CALL s_requestaddtolist(992763.00,"PERSON")
 CALL s_requestaddtolist(992764.00,"PERSON")
 CALL s_requestaddtolist(992765.00,"PERSON")
 CALL s_requestaddtolist(992766.00,"PERSON")
 CALL s_requestaddtolist(992767.00,"PERSON")
 CALL s_requestaddtolist(992768.00,"PERSON")
 CALL s_requestaddtolist(992769.00,"PERSON")
 CALL s_requestaddtolist(99999999.00,"ORGANIZATION")
 CALL s_requestaddtolist(590530.00,"ORGANIZATION")
 CALL s_requestaddtolist(590273.00,"ORGANIZATION")
 CALL s_requestaddtolist(99999999.00,"ORGANIZATION")
 CALL s_requestaddtolist(99999999.00,"LOCATION")
 CALL s_requestaddtolist(992062.00,"LOCATION")
 CALL s_requestaddtolist(99999999.00,"LOCATION")
 CALL s_requestaddtolist(99999999.00,"PRSNL_GROUP")
 CALL s_requestaddtolist(644664.00,"PRSNL_GROUP")
 CALL s_requestaddtolist(99999999.00,"PRSNL_GROUP")
 CALL s_requestaddtolist(99999999.00,"PRSNL")
 CALL s_requestaddtolist(1090506.00,"PRSNL")
 CALL s_requestaddtolist(99999999.00,"PRSNL")
 CALL s_requestaddtolist(99999999.00,"SCH_RESOURCE")
 CALL s_requestaddtolist(1001118.00,"SCH_RESOURCE")
 CALL s_requestaddtolist(99999999.00,"SCH_RESOURCE")
 CALL echo("SHOWING REQUEST RECORD")
 CALL echorecord(acm_chg_entity_updt_request)
 CALL echo("*** Execute list - s_executeentityupdates")
 CALL s_executeentityupdates(0)
 CALL echo("SHOWING REPLY RECORD")
 CALL echorecord(acm_chg_entity_updt_reply)
 CALL echo("*** Build primary keys - s_requestaddtoprimarykeyslist")
 CALL s_requestaddtoprimarykeyslist(992760.00)
 CALL s_requestaddtoprimarykeyslist(992761.00)
 DECLARE tempreturn = i4 WITH protect, noconstant(0)
 SET tempreturn = s_getprimarylistsize(0)
 CALL echo(build("*** Get primary keys size - s_getprimarylistsize ",tempreturn))
 CALL echo("*** Clear primary keys - s_clearprimarykeys")
 CALL s_clearprimarykeys(0)
 SET tempreturn = s_getprimarylistsize(0)
 CALL echo(build("*** Get primary keys size - s_getprimarylistsize ",tempreturn))
 CALL echo("*** Clear all - s_clearall")
 CALL s_clearall(0)
 CALL s_getdeclaringprog(0)
 CALL echo("*** Get CURPROG - s_getdeclaringprog")
END GO
