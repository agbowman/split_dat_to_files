CREATE PROGRAM dodfr_get_pl_pat_demog:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 preferred_name = vc
     2 gender_cd = f8
     2 birthdate = dq8
     2 birth_prec_flag = i4
     2 alias_qual[*]
       3 person_alias_type_cd = f8
       3 alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD personinfotemp(
   1 person_count = i4
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 preferred_name = vc
     2 gender_cd = f8
     2 birthdate = dq8
     2 birth_prec_flag = i4
 )
 RECORD preferrednamestemp(
   1 count = i4
   1 qual[*]
     2 person_id = f8
     2 preferred_name = vc
 )
 RECORD personaliasestemp(
   1 count = i4
   1 qual[*]
     2 person_id = f8
     2 alias_count = i4
     2 alias_qual[*]
       3 person_alias_type_cd = f8
       3 alias = vc
 )
 DECLARE loadpersoninfo(null) = null
 DECLARE loadpreferrednames(null) = null
 DECLARE loadaliases(null) = null
 DECLARE populatereply(null) = null
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE num = i4 WITH constant(0)
 DECLARE start = i4 WITH constant(1)
 DECLARE index = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF (size(request->qual,5) > 0)
  CALL loadpersoninfo(null)
  IF ((personinfotemp->person_count > 0))
   CALL loadpreferrednames(null)
   CALL loadaliases(null)
   CALL populatereply(null)
  ENDIF
 ENDIF
 SUBROUTINE loadpersoninfo(null)
   DECLARE count = i2 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM person p,
     (dummyt d  WITH seq = size(request->qual,5))
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=request->qual[d.seq].person_id))
    DETAIL
     index = locateval(num,start,size(personinfotemp->qual,5),p.person_id,personinfotemp->qual[num].
      person_id)
     IF (index <= 0)
      count = (count+ 1)
      IF (count > size(personinfotemp->qual,5))
       stat = alterlist(personinfotemp->qual,(count+ 9))
      ENDIF
      personinfotemp->qual[count].person_id = p.person_id, personinfotemp->qual[count].
      name_full_formatted = p.name_full_formatted, personinfotemp->qual[count].gender_cd = p.sex_cd,
      personinfotemp->qual[count].birthdate = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),
       1), personinfotemp->qual[count].birth_prec_flag = p.birth_prec_flag, personinfotemp->
      person_count = (personinfotemp->person_count+ 1)
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(personinfotemp->qual,personinfotemp->person_count)
 END ;Subroutine
 SUBROUTINE loadpreferrednames(null)
   DECLARE count = i2 WITH public, noconstant(0)
   DECLARE preferred_name_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PREFERRED"))
   SELECT INTO "nl:"
    FROM person_name pn,
     (dummyt d  WITH seq = personinfotemp->person_count)
    PLAN (d)
     JOIN (pn
     WHERE (pn.person_id=personinfotemp->qual[d.seq].person_id)
      AND pn.name_type_cd=preferred_name_cd)
    DETAIL
     IF (pn.name_full)
      count = (count+ 1)
      IF (count > size(preferrednamestemp->qual,5))
       stat = alterlist(preferrednamestemp->qual,(count+ 9))
      ENDIF
      preferrednamestemp->qual[count].person_id = pn.person_id, preferrednamestemp->qual[count].
      preferred_name = pn.name_full
     ENDIF
    WITH nocounter
   ;end select
   SET preferrednamestemp->count = count
 END ;Subroutine
 SUBROUTINE loadaliases(null)
   SELECT INTO "nl:"
    FROM person_alias pa
    WHERE expand(num,1,personinfotemp->person_count,pa.person_id,personinfotemp->qual[num].person_id)
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    HEAD REPORT
     p_cnt = 0
    HEAD pa.person_id
     p_cnt = (p_cnt+ 1), a_cnt = 0
     IF (p_cnt > size(personaliasestemp->qual,5))
      stat = alterlist(personaliasestemp->qual,(p_cnt+ 9))
     ENDIF
     personaliasestemp->qual[p_cnt].person_id = pa.person_id
    DETAIL
     IF (pa.alias)
      a_cnt = (a_cnt+ 1)
      IF (a_cnt > size(personaliasestemp->qual[p_cnt].alias_qual,5))
       stat = alterlist(personaliasestemp->qual[p_cnt].alias_qual,(a_cnt+ 9))
      ENDIF
      personaliasestemp->qual[p_cnt].alias_qual[a_cnt].person_alias_type_cd = pa.person_alias_type_cd,
      personaliasestemp->qual[p_cnt].alias_qual[a_cnt].alias = pa.alias
     ENDIF
    FOOT  pa.person_id
     personaliasestemp->qual[p_cnt].alias_count = a_cnt
    FOOT REPORT
     personaliasestemp->count = p_cnt
   ;end select
 END ;Subroutine
 SUBROUTINE populatereply(null)
   DECLARE count = i4 WITH noconstant(0)
   DECLARE personsize = i4 WITH noconstant(0)
   DECLARE personid = f8 WITH noconstant(0)
   SET personsize = personinfotemp->person_count
   SET stat = alterlist(reply->qual,personsize)
   FOR (i = 1 TO personsize)
     SET personid = personinfotemp->qual[i].person_id
     SET reply->qual[i].person_id = personid
     SET reply->qual[i].name_full_formatted = personinfotemp->qual[i].name_full_formatted
     SET reply->qual[i].birthdate = personinfotemp->qual[i].birthdate
     SET reply->qual[i].birth_prec_flag = personinfotemp->qual[i].birth_prec_flag
     SET reply->qual[i].gender_cd = personinfotemp->qual[i].gender_cd
     SET index = locateval(num,start,preferrednamestemp->count,personid,preferrednamestemp->qual[num]
      .person_id)
     IF (index > 0)
      SET reply->qual[i].preferred_name = preferrednamestemp->qual[index].preferred_name
     ENDIF
     SET index = locateval(num,start,personaliasestemp->count,personid,personaliasestemp->qual[num].
      person_id)
     IF (index > 0)
      SET aliascount = personaliasestemp->qual[index].alias_count
      SET stat = alterlist(reply->qual[i].alias_qual,aliascount)
      FOR (a = 1 TO aliascount)
       SET reply->qual[i].alias_qual[a].alias = personaliasestemp->qual[index].alias_qual[a].alias
       SET reply->qual[i].alias_qual[a].person_alias_type_cd = personaliasestemp->qual[index].
       alias_qual[a].person_alias_type_cd
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SET reply->status_data.status = "Z"
 CALL echorecord(reply)
END GO
