CREATE PROGRAM cdi_get_cover_page_encounters:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 person_id = f8
      2 encounter_id = f8
      2 patient_name = vc
      2 mrn = c20
      2 fin = c20
      2 patient_type_cd = f8
      2 patient_type_disp = c40
      2 patient_type_mean = c12
      2 facility_cd = f8
      2 facility_disp = c40
      2 facility_mean = c12
      2 disch_date = dq8
      2 reg_date = dq8
      2 patient_location_cd = f8
      2 patient_location_disp = c40
      2 patient_location_mean = c12
      2 term_digit_format = vc
      2 organization_id = f8
      2 nhin = c20
      2 cmrn = c20
      2 visitid = vc
      2 person_aliases[*]
        3 alias_type_cd = f8
        3 alias = vc
      2 encounter_aliases[*]
        3 alias_type_cd = f8
        3 alias = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD tdo_request_struct
 RECORD tdo_request_struct(
   1 encntr_qual[*]
     2 encntr_id = f8
 )
 FREE RECORD tdo_reply_struct
 RECORD tdo_reply_struct(
   1 encntr_qual[*]
     2 encntr_id = f8
     2 term_digit_nbr = i4
     2 term_digit_format = vc
 )
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE fin_cd = f8 WITH public, noconstant(0.0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE failed_ind = i2 WITH public, noconstant(1)
 DECLARE list_count = i4 WITH public, noconstant(0)
 DECLARE visitid_cd = f8 WITH public, noconstant(0.0)
 DECLARE nhin_cd = f8 WITH public, noconstant(0.0)
 DECLARE cmrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE pa_cnt = i4 WITH public, noconstant(0)
 DECLARE ea_cnt = i4 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 SET stat = uar_get_meaning_by_codeset(319,"VISITID",1,visitid_cd)
 SET stat = uar_get_meaning_by_codeset(4,"NHIN",1,nhin_cd)
 SET stat = uar_get_meaning_by_codeset(4,"CMRN",1,cmrn_cd)
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias ea,
   person_alias pa
  PLAN (e
   WHERE parser(request->where_clause))
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.active_ind=outerjoin(1))
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(e.encntr_id)
    AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND ea.active_ind=outerjoin(1))
  ORDER BY e.encntr_id
  HEAD REPORT
   stat = alterlist(reply->qual,10), stat = alterlist(tdo_request_struct->encntr_qual,10)
  HEAD e.encntr_id
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count > 1)
    stat = alterlist(reply->qual,(count+ 9)), stat = alterlist(tdo_request_struct->encntr_qual,(count
     + 9))
   ENDIF
   reply->qual[count].person_id = p.person_id, reply->qual[count].encounter_id = e.encntr_id, reply->
   qual[count].patient_name = p.name_full_formatted,
   reply->qual[count].patient_type_cd = e.encntr_type_cd, reply->qual[count].facility_cd = e
   .loc_facility_cd, reply->qual[count].reg_date = cnvtdatetime(e.reg_dt_tm),
   reply->qual[count].disch_date = cnvtdatetime(e.disch_dt_tm), reply->qual[count].
   patient_location_cd = e.loc_nurse_unit_cd, reply->qual[count].organization_id = e.organization_id,
   tdo_request_struct->encntr_qual[count].encntr_id = e.encntr_id, reg_dt = format(reply->qual[count]
    .reg_date,";;Q"), disch_dt = format(reply->qual[count].disch_date,";;Q"),
   ea_cnt = 0, pa_cnt = 0, stat = alterlist(reply->qual[count].person_aliases,10),
   stat = alterlist(reply->qual[count].encounter_aliases,10)
  DETAIL
   IF (size(trim(ea.alias),1) > 0)
    IF (locateval(num,1,ea_cnt,ea.encntr_alias_type_cd,reply->qual[count].encounter_aliases[num].
     alias_type_cd) < 1)
     ea_cnt = (ea_cnt+ 1)
     IF (mod(ea_cnt,10)=1
      AND ea_cnt > 1)
      stat = alterlist(reply->qual[count].encounter_aliases,(ea_cnt+ 9))
     ENDIF
     reply->qual[count].encounter_aliases[ea_cnt].alias_type_cd = ea.encntr_alias_type_cd, reply->
     qual[count].encounter_aliases[ea_cnt].alias = cnvtalias(ea.alias,ea.alias_pool_cd)
    ENDIF
   ENDIF
   IF (size(trim(pa.alias),1) > 0)
    IF (locateval(num,1,pa_cnt,pa.person_alias_type_cd,reply->qual[count].person_aliases[num].
     alias_type_cd) < 1)
     pa_cnt = (pa_cnt+ 1)
     IF (mod(pa_cnt,10)=1
      AND pa_cnt > 1)
      stat = alterlist(reply->qual[count].person_aliases,(pa_cnt+ 9))
     ENDIF
     reply->qual[count].person_aliases[pa_cnt].alias_type_cd = pa.person_alias_type_cd, reply->qual[
     count].person_aliases[pa_cnt].alias = cnvtalias(pa.alias,pa.alias_pool_cd)
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=mrn_cd)
    reply->qual[count].mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
   IF (ea.encntr_alias_type_cd=fin_cd)
    reply->qual[count].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
   IF (pa.person_alias_type_cd=nhin_cd)
    reply->qual[count].nhin = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
   IF (pa.person_alias_type_cd=cmrn_cd)
    reply->qual[count].cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
   IF (ea.encntr_alias_type_cd=visitid_cd)
    reply->qual[count].visitid = cnvtalias(ea.alias,ea.alias_pool_cd)
   ENDIF
  FOOT  e.encntr_id
   stat = alterlist(reply->qual[count].person_aliases,pa_cnt), stat = alterlist(reply->qual[count].
    encounter_aliases,ea_cnt)
  FOOT REPORT
   stat = alterlist(reply->qual,count), stat = alterlist(tdo_request_struct->encntr_qual,count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed_ind = 1
  GO TO exit_program
 ELSE
  SET failed_ind = 0
 ENDIF
 EXECUTE him_get_terminal_digits
 FOR (x = 1 TO size(tdo_reply_struct->encntr_qual,5))
   SET reply->qual[x].term_digit_format = tdo_reply_struct->encntr_qual[x].term_digit_format
 ENDFOR
#exit_program
 FREE RECORD tdo_request_struct
 FREE RECORD tdo_reply_struct
 IF (failed_ind=1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "(VARIOUS)"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No rows returned"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
