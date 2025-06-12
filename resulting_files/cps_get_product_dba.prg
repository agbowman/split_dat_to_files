CREATE PROGRAM cps_get_product:dba
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
   1 synonym_list[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
     2 mnemonic_type_disp = vc
     2 mnemonic_type_mean = c12
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE v500_ind = i2
 DECLARE mltm_ver = i2
 SELECT INTO "nl:"
  d.owner
  FROM dba_tables d
  WHERE d.table_name="MULTUM_DRUG_NAME_MAP"
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
  WHERE d.table_name="MLTM_DRUG_NAME_MAP"
   AND d.owner="V500"
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET mltm_ver = 0
 ELSE
  SET mltm_ver = 1
 ENDIF
 SET reply->status_data.status = "F"
 SET knt = 0
 SET s_pos = 0
 SET len = 0
 SET drug_synonym_id = 0
 SET mybaseid = 0
 SET myfunctid = 0
 SET mydrugid = fillstring(6," ")
 SET code_set = 6011
 SET cdf_meaning = fillstring(12," ")
 IF ( NOT ((request->synonym_cki > " ")))
  SET failed = input_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INPUT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Field synonym_cki must not be blank"
  GO TO exit_script
 ENDIF
 SET s_pos = (findstring("!",request->synonym_cki)+ 1)
 IF (s_pos > 0)
  SET len = ((textlen(request->synonym_cki) - s_pos)+ 1)
  SET drug_synonym_id = cnvtint(substring(s_pos,len,request->synonym_cki))
 ELSE
  SET failed = input_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INPUT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid synonym_cki format"
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 IF (mltm_ver=1)
  SELECT INTO "nl:"
   FROM (v500.mltm_drug_name_map m)
   WHERE m.drug_synonym_id=drug_synonym_id
    AND m.function_id IN (16, 17, 26, 59, 60,
   61, 62)
   DETAIL
    myfunctid = m.function_id, mydrugid = m.drug_identifier
   WITH nocounter
  ;end select
 ELSEIF (v500_ind=1)
  SELECT INTO "nl:"
   FROM (v500.multum_drug_name_map m)
   WHERE m.drug_synonym_id=drug_synonym_id
    AND m.function_id IN (16, 17, 26, 59, 60,
   61, 62)
   DETAIL
    myfunctid = m.function_id, mydrugid = m.drug_identifier
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (v500_ref.multum_drug_name_map m)
   WHERE m.drug_synonym_id=drug_synonym_id
    AND m.function_id IN (16, 17, 26, 59, 60,
   61, 62)
   DETAIL
    myfunctid = m.function_id, mydrugid = m.drug_id
   WITH nocounter
  ;end select
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "MULTUM_DRUG_NAME_MAP"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSEIF (curqual < 1)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (myfunctid=60)
  SET ierrcode = 0
  IF (mltm_ver=1)
   SELECT INTO "nl:"
    FROM (v500.mltm_drug_name_derivation m)
    PLAN (m
     WHERE m.derived_drug_synonym_id=drug_synonym_id
      AND m.base_function_id=17)
    DETAIL
     mybaseid = m.base_drug_synonym_id
    WITH nocounter
   ;end select
  ELSEIF (v500_ind=1)
   SELECT INTO "nl:"
    FROM (v500.multum_drug_name_derivation m)
    PLAN (m
     WHERE m.derived_drug_synonym_id=drug_synonym_id
      AND m.base_function_id=17)
    DETAIL
     mybaseid = m.base_drug_synonym_id
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (v500_ref.multum_drug_name_derivation m)
    PLAN (m
     WHERE m.derived_drug_synonym_id=drug_synonym_id
      AND m.base_function_id=17)
    DETAIL
     mybaseid = m.base_drug_synonym_id
    WITH nocounter
   ;end select
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "MULTUM_DRUG_NAME_DERIVATION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ELSEIF (curqual < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "MULTUM_DRUG_NAME_DERIVATION"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid db data"
   GO TO exit_script
  ENDIF
 ELSE
  SET mybaseid = drug_synonym_id
 ENDIF
 IF (((myfunctid=17) OR (myfunctid=60)) )
  SET ierrcode = 0
  IF (mltm_ver=1)
   SELECT INTO "nl:"
    FROM (v500.mltm_drug_name_derivation m),
     (v500.mltm_drug_name d),
     order_catalog_synonym o
    PLAN (m
     WHERE m.base_drug_synonym_id=mybaseid)
     JOIN (d
     WHERE d.drug_synonym_id=m.derived_drug_synonym_id)
     JOIN (o
     WHERE o.cki=concat("MUL.ORD-SYN!",trim(cnvtstring(d.drug_synonym_id))))
    HEAD REPORT
     knt = 0, stat = alterlist(reply->synonym_list,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->synonym_list,(knt+ 9))
     ENDIF
     reply->synonym_list[knt].synonym_id = o.synonym_id, reply->synonym_list[knt].mnemonic = o
     .mnemonic, reply->synonym_list[knt].mnemonic_type_cd = o.mnemonic_type_cd,
     reply->synonym_list[knt].cki = o.cki
    FOOT REPORT
     stat = alterlist(reply->synonym_list,knt)
    WITH nocounter
   ;end select
  ELSEIF (v500_ind=1)
   SELECT INTO "nl:"
    FROM (v500.multum_drug_name_derivation m),
     (v500.multum_drug_name d),
     order_catalog_synonym o
    PLAN (m
     WHERE m.base_drug_synonym_id=mybaseid)
     JOIN (d
     WHERE d.drug_synonym_id=m.derived_drug_synonym_id)
     JOIN (o
     WHERE o.cki=concat("MUL.ORD-SYN!",trim(cnvtstring(d.drug_synonym_id))))
    HEAD REPORT
     knt = 0, stat = alterlist(reply->synonym_list,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->synonym_list,(knt+ 9))
     ENDIF
     reply->synonym_list[knt].synonym_id = o.synonym_id, reply->synonym_list[knt].mnemonic = o
     .mnemonic, reply->synonym_list[knt].mnemonic_type_cd = o.mnemonic_type_cd,
     reply->synonym_list[knt].cki = o.cki
    FOOT REPORT
     stat = alterlist(reply->synonym_list,knt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (v500_ref.multum_drug_name_derivation m),
     (v500_ref.multum_drug_name d),
     order_catalog_synonym o
    PLAN (m
     WHERE m.base_drug_synonym_id=mybaseid)
     JOIN (d
     WHERE d.drug_synonym_id=m.derived_drug_synonym_id)
     JOIN (o
     WHERE o.cki=concat("MUL.ORD-SYN!",trim(cnvtstring(d.drug_synonym_id))))
    HEAD REPORT
     knt = 0, stat = alterlist(reply->synonym_list,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->synonym_list,(knt+ 9))
     ENDIF
     reply->synonym_list[knt].synonym_id = o.synonym_id, reply->synonym_list[knt].mnemonic = o
     .mnemonic, reply->synonym_list[knt].mnemonic_type_cd = o.mnemonic_type_cd,
     reply->synonym_list[knt].cki = o.cki
    FOOT REPORT
     stat = alterlist(reply->synonym_list,knt)
    WITH nocounter
   ;end select
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_SYONYM_CATALOG"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (myfunctid != 16)
  SET ierrcode = 0
  IF (mltm_ver=1)
   SELECT INTO "nl:"
    FROM (v500.mltm_drug_name_map m)
    PLAN (m
     WHERE m.drug_identifier=mydrugid
      AND m.function_id=16)
    DETAIL
     mybaseid = m.drug_synonym_id
    WITH nocounter
   ;end select
  ELSEIF (v500_ind=1)
   SELECT INTO "nl:"
    FROM (v500.multum_drug_name_map m)
    PLAN (m
     WHERE m.drug_identifier=mydrugid
      AND m.function_id=16)
    DETAIL
     mybaseid = m.drug_synonym_id
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (v500_ref.multum_drug_name_map m)
    PLAN (m
     WHERE m.drug_id=mydrugid
      AND m.function_id=16)
    DETAIL
     mybaseid = m.drug_synonym_id
    WITH nocounter
   ;end select
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "MULTUM_DRUG_NAME_MAP"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = 0
 IF (mltm_ver=1)
  SELECT INTO "nl:"
   FROM (v500.mltm_drug_name_derivation m),
    (v500.mltm_drug_name d),
    order_catalog_synonym o
   PLAN (m
    WHERE m.base_drug_synonym_id=mybaseid)
    JOIN (d
    WHERE d.drug_synonym_id=m.derived_drug_synonym_id)
    JOIN (o
    WHERE o.cki=concat("MUL.ORD-SYN!",trim(cnvtstring(d.drug_synonym_id))))
   ORDER BY d.drug_name
   HEAD REPORT
    stat = alterlist(reply->synonym_list,(knt+ 10))
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->synonym_list,(knt+ 9))
    ENDIF
    reply->synonym_list[knt].synonym_id = o.synonym_id, reply->synonym_list[knt].mnemonic = o
    .mnemonic, reply->synonym_list[knt].mnemonic_type_cd = o.mnemonic_type_cd,
    reply->synonym_list[knt].cki = o.cki
   FOOT REPORT
    stat = alterlist(reply->synonym_list,knt)
   WITH nocounter
  ;end select
 ELSEIF (v500_ind=1)
  SELECT INTO "nl:"
   FROM (v500.multum_drug_name_derivation m),
    (v500.multum_drug_name d),
    order_catalog_synonym o
   PLAN (m
    WHERE m.base_drug_synonym_id=mybaseid)
    JOIN (d
    WHERE d.drug_synonym_id=m.derived_drug_synonym_id)
    JOIN (o
    WHERE o.cki=concat("MUL.ORD-SYN!",trim(cnvtstring(d.drug_synonym_id))))
   ORDER BY d.drug_name
   HEAD REPORT
    stat = alterlist(reply->synonym_list,(knt+ 10))
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->synonym_list,(knt+ 9))
    ENDIF
    reply->synonym_list[knt].synonym_id = o.synonym_id, reply->synonym_list[knt].mnemonic = o
    .mnemonic, reply->synonym_list[knt].mnemonic_type_cd = o.mnemonic_type_cd,
    reply->synonym_list[knt].cki = o.cki
   FOOT REPORT
    stat = alterlist(reply->synonym_list,knt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (v500_ref.multum_drug_name_derivation m),
    (v500_ref.multum_drug_name d),
    order_catalog_synonym o
   PLAN (m
    WHERE m.base_drug_synonym_id=mybaseid)
    JOIN (d
    WHERE d.drug_synonym_id=m.derived_drug_synonym_id)
    JOIN (o
    WHERE o.cki=concat("MUL.ORD-SYN!",trim(cnvtstring(d.drug_synonym_id))))
   ORDER BY d.drug_name
   HEAD REPORT
    stat = alterlist(reply->synonym_list,(knt+ 10))
   DETAIL
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->synonym_list,(knt+ 9))
    ENDIF
    reply->synonym_list[knt].synonym_id = o.synonym_id, reply->synonym_list[knt].mnemonic = o
    .mnemonic, reply->synonym_list[knt].mnemonic_type_cd = o.mnemonic_type_cd,
    reply->synonym_list[knt].cki = o.cki
   FOOT REPORT
    stat = alterlist(reply->synonym_list,knt)
   WITH nocounter
  ;end select
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_SYONYM_CATALOG"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=false)
  IF (size(reply->synonym_list,5) > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET script_version = "005 04/16/04 SB8972"
END GO
