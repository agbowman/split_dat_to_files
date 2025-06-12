CREATE PROGRAM bed_get_alias_pool_type_cd:dba
 CALL echo("*****bed_get_alias_pool_type_cd.prg - 763952*****")
 CALL echo("*****bed_get_alias_pool_type_cd.prg - 786230*****")
 RECORD reply(
   1 alias_pool_cd = f8
   1 alias_type_cd
     2 value = f8
     2 display = vc
     2 meaning = vc
   1 alias_pool_cds[*]
     2 value = f8
     2 display = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 error_msg = vc
 )
 DECLARE errormsg = vc WITH noconstant(""), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE aliastypecd = f8 WITH constant(uar_get_code_by("MEANING",4,"HNAMPERSONID")), protect
 SUBROUTINE (getuserlogicaldomainid(null) =f8)
   DECLARE userlogicaldomainid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     userlogicaldomainid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(userlogicaldomainid)
 END ;Subroutine
 DECLARE userlogicaldomainid = f8 WITH protect, noconstant(0.0)
 SET userlogicaldomainid = getuserlogicaldomainid(null)
 IF ((request->load_alias_pool_by_type_ind=false))
  IF ((request->alias_pool_cd > 0.0))
   SELECT INTO "nl:"
    FROM alias_pool ap,
     alias_pool_type_reltn aptr,
     code_value cv
    PLAN (ap
     WHERE (ap.alias_pool_cd=request->alias_pool_cd)
      AND ap.logical_domain_id=userlogicaldomainid
      AND ap.active_ind=1)
     JOIN (aptr
     WHERE aptr.alias_pool_cd=ap.alias_pool_cd)
     JOIN (cv
     WHERE cv.code_value=aptr.alias_entity_alias_type_cd)
    DETAIL
     reply->alias_pool_cd = ap.alias_pool_cd, reply->alias_type_cd.value = aptr
     .alias_entity_alias_type_cd, reply->alias_type_cd.display = cv.display,
     reply->alias_type_cd.meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT DISTINCT INTO "nl:"
     FROM alias_pool ap,
      org_alias_pool_reltn oapr,
      code_value cv
     PLAN (ap
      WHERE (ap.alias_pool_cd=request->alias_pool_cd)
       AND ap.logical_domain_id=userlogicaldomainid
       AND ap.active_ind=1)
      JOIN (oapr
      WHERE oapr.alias_pool_cd=ap.alias_pool_cd
       AND oapr.alias_entity_alias_type_cd=aliastypecd
       AND oapr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=oapr.alias_entity_alias_type_cd)
     DETAIL
      reply->alias_pool_cd = ap.alias_pool_cd, reply->alias_type_cd.value = oapr
      .alias_entity_alias_type_cd, reply->alias_type_cd.display = cv.display,
      reply->alias_type_cd.meaning = cv.cdf_meaning
     WITH nocounter
    ;end select
   ENDIF
  ELSE
   SET errormsg = "Invalid alias pool code"
  ENDIF
 ELSE
  IF ((request->alias_pool_type_cd > 0.0))
   SELECT INTO "nl:"
    FROM alias_pool ap,
     alias_pool_type_reltn aptr,
     code_value cv
    PLAN (ap
     WHERE (ap.alias_pool_cd=request->alias_pool_cd)
      AND ap.logical_domain_id=userlogicaldomainid
      AND ap.active_ind=1)
     JOIN (aptr
     WHERE aptr.alias_pool_cd=ap.alias_pool_cd)
     JOIN (cv
     WHERE cv.code_value=ap.alias_pool_cd)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->alias_pool_cds,cnt), reply->alias_pool_cd = ap
     .alias_pool_cd,
     reply->alias_pool_cds[cnt].value = ap.alias_pool_cd, reply->alias_pool_cds[cnt].display = cv
     .display, reply->alias_pool_cds[cnt].meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    FROM alias_pool ap,
     org_alias_pool_reltn oapr,
     code_value cv
    PLAN (oapr
     WHERE (oapr.alias_entity_alias_type_cd=request->alias_pool_type_cd)
      AND oapr.active_ind=1)
     JOIN (ap
     WHERE ap.alias_pool_cd=oapr.alias_pool_cd
      AND ap.logical_domain_id=userlogicaldomainid
      AND ap.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=ap.alias_pool_cd)
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->alias_pool_cds,cnt), reply->alias_pool_cd = ap
     .alias_pool_cd,
     reply->alias_pool_cds[cnt].value = ap.alias_pool_cd, reply->alias_pool_cds[cnt].display = cv
     .display, reply->alias_pool_cds[cnt].meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
  ELSE
   SET errormsg = "Invalid alias pool type code"
  ENDIF
 ENDIF
 IF (textlen(trim(errormsg,3))=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(curprog," ERROR MSG:",errormsg)
 ENDIF
END GO
