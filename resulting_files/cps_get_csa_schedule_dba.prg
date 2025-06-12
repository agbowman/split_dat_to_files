CREATE PROGRAM cps_get_csa_schedule:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 csa_schedule = c1
   1 code_value = f8
   1 cdf_meaning = c12
   1 qual[*]
     2 cki = vc
     2 csa_schedule = c1
     2 code_value = f8
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD data(
   1 qual[*]
     2 drug_id = vc
 )
 DECLARE v500_ind = i2
 DECLARE mltm_ind = i2
 DECLARE dmultumcd = f8 WITH protect, noconstant(0.0)
 DECLARE lcsacodeset = i4 WITH protect, constant(4200)
 DECLARE imatch = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE pos = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  d.owner
  FROM dba_tables d
  WHERE d.table_name="NDC_MAIN_MULTUM_DRUG_CODE"
   AND d.owner="V500"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET v500_ind = 0
 ELSE
  SET v500_ind = 1
 ENDIF
 SELECT INTO "nl:"
  d.owner
  FROM dba_tables d
  WHERE d.table_name="MLTM_NDC_MAIN_DRUG_CODE"
   AND d.owner="V500"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET mltm_ind = 0
 ELSE
  SET mltm_ind = 1
 ENDIF
 SET drug_id = fillstring(6," ")
 SET qual_size = size(request->qual,5)
 FOR (x = 1 TO qual_size)
   IF (trim(request->cki)=trim(request->qual[x].cki))
    SET imatch = 1
    SET x = (qual_size+ 1)
   ENDIF
 ENDFOR
 IF (imatch=0
  AND textlen(trim(request->cki)) > 0)
  SET qual_size = (qual_size+ 1)
  SET stat = alterlist(request->qual,qual_size)
  SET request->qual[qual_size].cki = request->cki
 ENDIF
 IF (qual_size <= 0)
  SET failed = input_error
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "INPUT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("Invalid cki : ",trim(request->
    cki))
  GO TO exit_script
 ENDIF
 SET stat = alterlist(data->qual,qual_size)
 FOR (x = 1 TO qual_size)
   SET pos = 0
   SET pos = findstring("!",request->qual[x].cki)
   IF (pos > 0)
    SET data->qual[x].drug_id = trim(substring((pos+ 1),textlen(request->qual[x].cki),request->qual[x
      ].cki))
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->qual,qual_size)
 SET drug_id = fillstring(6," ")
 SET pos = 0
 SET ierrcode = 0
 SET dmultumcd = uar_get_code_by("MEANING",73,"MULTUM")
 IF (mltm_ind=1)
  SELECT INTO "nl:"
   n.drug_identifier, n.csa_schedule, d.collation_seq,
   d.code_value, d.cdf_meaning
   FROM (v500.mltm_ndc_main_drug_code n),
    code_value_alias c,
    code_value d
   PLAN (n
    WHERE expand(idx,1,qual_size,n.drug_identifier,data->qual[idx].drug_id))
    JOIN (c
    WHERE c.contributor_source_cd=dmultumcd
     AND c.code_set=lcsacodeset)
    JOIN (d
    WHERE c.code_value=d.code_value
     AND n.csa_schedule=c.alias)
   ORDER BY n.drug_identifier, d.collation_seq, n.csa_schedule
   HEAD n.drug_identifier
    pos = locateval(num,1,qual_size,n.drug_identifier,data->qual[num].drug_id), reply->qual[pos].cki
     = request->qual[pos].cki, reply->qual[pos].csa_schedule = n.csa_schedule,
    reply->qual[pos].code_value = d.code_value, reply->qual[pos].cdf_meaning = d.cdf_meaning
    IF ((reply->qual[pos].cki=request->cki))
     reply->csa_schedule = n.csa_schedule, reply->code_value = d.code_value, reply->cdf_meaning = d
     .cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (v500_ind=1)
  SELECT INTO "nl:"
   n.drug_identifier, n.csa_schedule, d.collation_seq,
   d.code_value, d.cdf_meaning
   FROM (v500.ndc_main_multum_drug_code n),
    code_value_alias c,
    code_value d
   PLAN (n
    WHERE expand(idx,1,qual_size,n.drug_identifier,data->qual[idx].drug_id))
    JOIN (c
    WHERE c.contributor_source_cd=dmultumcd
     AND c.code_set=4200)
    JOIN (d
    WHERE c.code_value=d.code_value
     AND n.csa_schedule=c.alias)
   ORDER BY n.drug_identifier, d.collation_seq, n.csa_schedule
   HEAD n.drug_identifier
    pos = locateval(num,1,qual_size,n.drug_identifier,data->qual[num].drug_id), reply->qual[pos].cki
     = request->qual[pos].cki, reply->qual[pos].csa_schedule = n.csa_schedule,
    reply->qual[pos].code_value = d.code_value, reply->qual[pos].cdf_meaning = d.cdf_meaning
    IF ((reply->qual[pos].cki=request->cki))
     reply->csa_schedule = n.csa_schedule, reply->code_value = d.code_value, reply->cdf_meaning = d
     .cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   n.drug_id, n.csa_schedule, d.collation_seq,
   d.code_value, d.cdf_meaning
   FROM (v500_ref.ndc_main_multum_drug_code n),
    code_value_alias c,
    code_value d
   PLAN (n
    WHERE expand(idx,1,qual_size,n.drug_id,data->qual[idx].drug_id))
    JOIN (c
    WHERE c.contributor_source_cd=dmultumcd
     AND c.code_set=4200)
    JOIN (d
    WHERE c.code_value=d.code_value
     AND n.csa_schedule=c.alias)
   ORDER BY n.drug_identifier, d.collation_seq, n.csa_schedule
   HEAD n.drug_identifier
    pos = locateval(num,1,qual_size,n.drug_identifier,data->qual[num].drug_id), reply->qual[pos].cki
     = request->qual[pos].cki, reply->qual[pos].csa_schedule = n.csa_schedule,
    reply->qual[pos].code_value = d.code_value, reply->qual[pos].cdf_meaning = d.cdf_meaning
    IF ((reply->qual[pos].cki=request->cki))
     reply->csa_schedule = n.csa_schedule, reply->code_value = d.code_value, reply->cdf_meaning = d
     .cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  IF (v500_ind=1)
   SET reply->status_data.subeventstatus[1].targetobjectname = "V500.NDC_MAIN_MULTUM_DRUG_CODE"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectname = "V500_REF.NDC_MAIN_MULTUM_DRUG_CODE"
  ENDIF
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET script_version = "007 6/29/06 BP9613"
END GO
