CREATE PROGRAM aps_get_alias_info:dba
 RECORD reply(
   1 organization_id = f8
   1 organization = vc
   1 qual[*]
     2 alias_meaning = c12
     2 alias = vc
     2 alias_formatted = c100
     2 alias_type_cd = f8
     2 alias_pool_cd = f8
     2 alias_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET err_cnt = 0
 DECLARE dssn = f8 WITH protect, noconstant(0.0)
 SET dssn = uar_get_code_by("MEANING",4,"SSN")
 DECLARE d4mrn = f8 WITH protect, noconstant(0.0)
 SET d4mrn = uar_get_code_by("MEANING",4,"MRN")
 DECLARE dshin = f8 WITH protect, noconstant(0.0)
 SET dshin = uar_get_code_by("MEANING",4,"SHIN")
 DECLARE dfinnbr = f8 WITH protect, noconstant(0.0)
 SET dfinnbr = uar_get_code_by("MEANING",319,"FIN NBR")
 DECLARE d319mrn = f8 WITH protect, noconstant(0.0)
 SET d319mrn = uar_get_code_by("MEANING",319,"MRN")
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE nqualsize = i2 WITH protect, noconstant(0)
 DECLARE sdescription = vc WITH protect, noconstant("")
 DECLARE smnem_on_or_off = vc WITH protect, noconstant("")
 DECLARE shealthcardvercd = vc WITH protect, noconstant("")
 IF ((request->organization_id > 0.0))
  SELECT INTO "nl:"
   o.org_name
   FROM organization o
   PLAN (o
    WHERE (o.organization_id=request->organization_id))
   DETAIL
    reply->organization = o.org_name, reply->organization_id = o.organization_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt = (err_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,err_cnt)
   SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "ORGANIZATION"
  ENDIF
 ELSEIF ((request->org_encounter_id > 0.0))
  SELECT INTO "nl:"
   e.encntr_id, o.organization_id, o.org_name
   FROM encounter e,
    organization o
   PLAN (e
    WHERE (e.encntr_id=request->org_encounter_id))
    JOIN (o
    WHERE o.organization_id=e.organization_id)
   DETAIL
    reply->organization_id = o.organization_id, reply->organization = o.org_name
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt = (err_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,err_cnt)
   SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "ORGANIZATION"
  ENDIF
 ENDIF
 IF ((request->person_id > 0.0))
  SELECT
   IF ((request->include_all_ind=1))
    PLAN (pa
     WHERE (pa.person_id=request->person_id)
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ELSE
    PLAN (pa
     WHERE (pa.person_id=request->person_id)
      AND pa.person_alias_type_cd IN (dssn, d4mrn, dshin)
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ENDIF
   INTO "nl:"
   pa.alias, alias_formatted = cnvtalias(pa.alias,pa.alias_pool_cd)
   FROM person_alias pa
   DETAIL
    IF ((((request->encounter_id=0)) OR (((pa.person_alias_type_cd != d4mrn) OR ((request->
    include_all_ind=1))) )) )
     cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].alias = pa.alias,
     reply->qual[cnt].alias_meaning = uar_get_code_meaning(pa.person_alias_type_cd), reply->qual[cnt]
     .alias_formatted = alias_formatted, reply->qual[cnt].alias_type_cd = pa.person_alias_type_cd,
     reply->qual[cnt].alias_pool_cd = pa.alias_pool_cd
     IF (pa.person_alias_type_cd=dshin)
      shealthcardvercd = pa.health_card_ver_code
     ENDIF
     reply->qual[cnt].alias_type_flag = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt = (err_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,err_cnt)
   SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "PERSON ALIAS"
  ENDIF
  SET nqualsize = size(reply->qual,5)
  FOR (ncount = 1 TO nqualsize)
    IF ((reply->qual[ncount].alias_type_cd=dshin))
     SELECT INTO "nl:"
      cve.field_value
      FROM code_value_extension cve
      WHERE cve.code_value=dshin
       AND cve.field_name="USEMNEM"
      DETAIL
       smnem_on_or_off = trim(cve.field_value)
      WITH nocounter
     ;end select
     IF (smnem_on_or_off="1")
      SELECT INTO "nl:"
       cve.field_value
       FROM code_value_extension cve
       WHERE (cve.code_value=reply->qual[ncount].alias_pool_cd)
        AND cve.field_name="MNEMONIC"
       DETAIL
        reply->qual[ncount].alias_formatted = concat(trim(cve.field_value)," ",trim(reply->qual[
          ncount].alias_formatted))
       WITH nocounter
      ;end select
     ELSE
      SET sdescription = uar_get_code_description(reply->qual[ncount].alias_pool_cd)
      SET reply->qual[ncount].alias_formatted = concat(trim(sdescription)," ",trim(reply->qual[ncount
        ].alias_formatted))
     ENDIF
     IF (trim(shealthcardvercd) != "")
      SET reply->qual[ncount].alias_formatted = concat(trim(reply->qual[ncount].alias_formatted)," (",
       trim(shealthcardvercd),")")
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->encounter_id > 0.0))
  SELECT INTO "nl:"
   ea.alias, alias_formatted = cnvtalias(ea.alias,ea.alias_pool_cd)
   FROM encntr_alias ea
   PLAN (ea
    WHERE (ea.encntr_id=request->encounter_id)
     AND (((request->include_all_ind=1)) OR (ea.encntr_alias_type_cd IN (dfinnbr, d319mrn)))
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].alias = ea.alias,
    reply->qual[cnt].alias_meaning = uar_get_code_meaning(ea.encntr_alias_type_cd), reply->qual[cnt].
    alias_formatted = alias_formatted, reply->qual[cnt].alias_type_cd = ea.encntr_alias_type_cd,
    reply->qual[cnt].alias_pool_cd = ea.alias_pool_cd, reply->qual[cnt].alias_type_flag = 2
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt = (err_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,err_cnt)
   SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "ENCNTR ALIAS"
  ENDIF
 ENDIF
 IF ((request->include_all_ind=1)
  AND (request->prsnl_id > 0.0))
  SELECT INTO "nl:"
   pa.alias, alias_formatted = cnvtalias(pa.alias,pa.alias_pool_cd)
   FROM prsnl_alias pa
   PLAN (pa
    WHERE (pa.person_id=request->prsnl_id)
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].alias = pa.alias,
    reply->qual[cnt].alias_meaning = uar_get_code_meaning(pa.prsnl_alias_type_cd), reply->qual[cnt].
    alias_formatted = alias_formatted, reply->qual[cnt].alias_type_cd = pa.prsnl_alias_type_cd,
    reply->qual[cnt].alias_pool_cd = pa.alias_pool_cd, reply->qual[cnt].alias_type_flag = 3
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt = (err_cnt+ 1)
   SET stat = alter(reply->status_data.subeventstatus,err_cnt)
   SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "PRSNL ALIAS"
  ENDIF
 ENDIF
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
