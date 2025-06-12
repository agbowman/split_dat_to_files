CREATE PROGRAM ct_get_pt_info_basic:dba
 RECORD reply(
   1 mrns[*]
     2 mrn = vc
     2 orgid = f8
     2 alias_pool_cd = f8
     2 alias_pool_disp = vc
     2 alias_pool_desc = vc
     2 alias_pool_mean = c12
   1 firstname = vc
   1 lastname = vc
   1 namefullformatted = vc
   1 birthdttm = dq8
   1 sex_cd = f8
   1 sex_disp = vc
   1 sex_desc = vc
   1 sex_mean = c12
   1 race_cd = f8
   1 race_disp = vc
   1 race_desc = vc
   1 race_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET new = 0
 SET x = 0
 SET mrn = 0.0
 SET cntm = 0
 SELECT INTO "NL:"
  code_value.code_value
  FROM code_value cv
  WHERE cv.code_set=4
   AND cv.cdf_meaning="MRN"
   AND cv.active_ind=1
  DETAIL
   mrn = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p.name_full_formatted, p.sex_cd, p.birth_dt_tm,
  p.name_last, p.name_first, p.race_cd,
  p_a.alias, o.organization_id, o.org_name
  FROM person p,
   dummyt d1,
   person_alias p_a
  PLAN (p
   WHERE (p.person_id=request->personid)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (d1)
   JOIN (p_a
   WHERE p.person_id=p_a.person_id
    AND p_a.person_alias_type_cd=mrn
    AND p_a.active_ind=1
    AND p_a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p_a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.person_id
  HEAD p.person_id
   reply->lastname = p.name_last, reply->firstname = p.name_first, reply->namefullformatted = p
   .name_full_formatted,
   reply->birthdttm = p.birth_dt_tm, reply->sex_cd = p.sex_cd, reply->race_cd = p.race_cd,
   cntm = 0
  DETAIL
   cntm = (cntm+ 1)
   IF (mod(cntm,10)=1)
    new = (cntm+ 10), stat = alterlist(reply->mrns,new)
   ENDIF
   reply->mrns[cntm].mrn = trim(cnvtalias(p_a.alias,p_a.alias_pool_cd)), reply->mrns[cntm].
   alias_pool_cd = p_a.alias_pool_cd
  FOOT  p.person_id
   stat = alterlist(reply->mrns,cntm)
  WITH outerjoin = d1, nocounter
 ;end select
 SET reply->status_data.status = "S"
 GO TO skipecho
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo("Reply->LastName =",0)
 CALL echo(reply->lastname,1)
 CALL echo("Reply->FirstName =",0)
 CALL echo(reply->firstname,1)
 CALL echo("Reply->NameFullFormatted =",0)
 CALL echo(reply->namefullformatted,1)
 CALL echo("Reply->BirthDtTm =",0)
 CALL echo(reply->birthdttm,1)
 CALL echo("Reply->sex_cd =",0)
 CALL echo(reply->sex_cd,1)
 CALL echo("Reply->race_cd =",0)
 CALL echo(reply->race_cd,1)
 SET last_mod = "001"
 SET mod_date = "Feb 22, 2018"
#skipecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
