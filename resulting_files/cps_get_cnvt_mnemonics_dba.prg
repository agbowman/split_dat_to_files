CREATE PROGRAM cps_get_cnvt_mnemonics:dba
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
 RECORD reply(
   1 qual[*]
     2 valid_ind = i2
     2 order_id = f8
     2 single_ingred_ind = i2
     2 single_product_ind = i2
     2 synonym_id = f8
     2 mnemonic_type_cd = f8
     2 cki = vc
     2 tnf_ind = i2
     2 freetext_ind = i2
     2 alt_mnem_qual[*]
       3 mnemonic = vc
       3 synonym_id = f8
       3 mnemonic_type_cd = f8
       3 oe_format_id = f8
       3 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("000")
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE ingcnt = i2 WITH protect, noconstant(0)
 DECLARE primary_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE y_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE z_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE rx_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE m_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE n_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE c_mnemonic_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,primary_mnemonic_type_cd)
 IF (primary_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "GENERICPROD"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,y_mnemonic_type_cd)
 IF (y_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "TRADEPROD"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,z_mnemonic_type_cd)
 IF (z_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "RXMNEMONIC"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,rx_mnemonic_type_cd)
 IF (rx_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "GENERICTOP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,m_mnemonic_type_cd)
 IF (m_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "TRADETOP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,n_mnemonic_type_cd)
 IF (n_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "DISPDRUG"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,c_mnemonic_type_cd)
 IF (c_mnemonic_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->qual,size(request->qual,5))
 FOR (i = 1 TO size(request->qual,5))
   SET reply->qual[i].order_id = request->qual[i].order_id
   SET reply->qual[i].single_product_ind = 1
   SET reply->qual[i].valid_ind = 0
   SET reply->qual[i].single_ingred_ind = 1
 ENDFOR
 SELECT INTO "nl:"
  FROM order_product op
  WHERE expand(j,1,size(reply->qual,5),op.order_id,reply->qual[j].order_id)
   AND op.tnf_id > 0
  DETAIL
   pos = locateval(j,1,size(reply->qual,5),op.order_id,reply->qual[j].order_id), reply->qual[pos].
   tnf_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(request->qual,5)),
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ocs
   WHERE (ocs.synonym_id=request->qual[d.seq].synonym_id))
   JOIN (ocs2
   WHERE ((ocs.mnemonic_type_cd=value(rx_mnemonic_type_cd)
    AND (ocs2.catalog_cd=request->qual[d.seq].catalog_cd)
    AND ocs2.mnemonic_key_cap=cnvtupper(request->qual[d.seq].ordered_as_mnem)) OR (ocs
   .mnemonic_type_cd != value(rx_mnemonic_type_cd)
    AND (ocs2.synonym_id=request->qual[d.seq].synonym_id))) )
  ORDER BY d.seq, ocs.synonym_id
  HEAD d.seq
   unused_place_holder = 0
  HEAD ocs.synonym_id
   ingcnt = 0
  DETAIL
   ingcnt += 1
  FOOT  ocs.synonym_id
   IF (ingcnt <= 1)
    reply->qual[d.seq].valid_ind = 1, reply->qual[d.seq].synonym_id = ocs2.synonym_id, reply->qual[d
    .seq].mnemonic_type_cd = ocs2.mnemonic_type_cd,
    reply->qual[d.seq].cki = ocs2.cki
   ELSE
    reply->qual[d.seq].valid_ind = 0, reply->qual[d.seq].synonym_id = 0, reply->qual[d.seq].
    mnemonic_type_cd = 0,
    reply->qual[d.seq].cki = "", reply->qual[d.seq].single_ingred_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(request->qual,5)),
   order_catalog oc,
   mltm_combination_drug mcd
  PLAN (d
   WHERE d.seq > 0)
   JOIN (oc
   WHERE (oc.catalog_cd=request->qual[d.seq].catalog_cd))
   JOIN (mcd
   WHERE findstring("MUL.ORD!",oc.cki) > 0
    AND substring(9,6,oc.cki)=mcd.drug_identifier)
  DETAIL
   reply->qual[d.seq].valid_ind = 0, reply->qual[d.seq].synonym_id = 0, reply->qual[d.seq].
   mnemonic_type_cd = 0,
   reply->qual[d.seq].cki = "", reply->qual[d.seq].single_ingred_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_ingredient oi
  WHERE expand(i,1,size(reply->qual,5),oi.order_id,reply->qual[i].order_id)
  ORDER BY oi.order_id, oi.action_sequence
  HEAD oi.order_id
   order_cnt = 0
  HEAD oi.action_sequence
   order_cnt = 0
  DETAIL
   order_cnt += 1
  FOOT  oi.order_id
   pos = locateval(i,1,size(reply->qual,5),oi.order_id,reply->qual[i].order_id)
   IF ((reply->qual[pos].valid_ind=1)
    AND (reply->qual[pos].single_product_ind=1)
    AND order_cnt > 1)
    reply->qual[pos].single_product_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  op.order_id
  FROM order_product op
  WHERE expand(i,1,size(reply->qual,5),op.order_id,reply->qual[i].order_id)
  ORDER BY op.order_id, op.action_sequence
  HEAD op.order_id
   order_cnt = 0
  HEAD op.action_sequence
   order_cnt = 0
  DETAIL
   order_cnt += 1
  FOOT  op.order_id
   pos = locateval(i,1,size(reply->qual,5),op.order_id,reply->qual[i].order_id)
   IF ((reply->qual[pos].valid_ind=1)
    AND (reply->qual[pos].single_product_ind=1)
    AND order_cnt > 1)
    reply->qual[pos].single_product_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 IF ((request->disp_prod_only_level_meds_ind=1))
  IF ((request->treat_cdisp_as_product=1))
   SET mnem_type_cd_where_clause = build("ocs.mnemonic_type_cd in (",y_mnemonic_type_cd,",",
    n_mnemonic_type_cd,",",
    m_mnemonic_type_cd,",",z_mnemonic_type_cd,",",c_mnemonic_type_cd,
    ")")
  ELSE
   SET mnem_type_cd_where_clause = build("ocs.mnemonic_type_cd in (",y_mnemonic_type_cd,",",
    n_mnemonic_type_cd,",",
    m_mnemonic_type_cd,",",z_mnemonic_type_cd,")")
  ENDIF
 ELSE
  IF ((request->treat_cdisp_as_product=1))
   SET mnem_type_cd_where_clause = build("ocs.mnemonic_type_cd in (",primary_mnemonic_type_cd,",",
    y_mnemonic_type_cd,",",
    n_mnemonic_type_cd,",",m_mnemonic_type_cd,",",z_mnemonic_type_cd,
    ",",c_mnemonic_type_cd,")")
  ELSE
   SET mnem_type_cd_where_clause = build("ocs.mnemonic_type_cd in (",primary_mnemonic_type_cd,",",
    y_mnemonic_type_cd,",",
    n_mnemonic_type_cd,",",m_mnemonic_type_cd,",",z_mnemonic_type_cd,
    ")")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(request->qual,5)),
   order_catalog_synonym ocs
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ocs
   WHERE (ocs.catalog_cd=request->qual[d.seq].catalog_cd)
    AND parser(mnem_type_cd_where_clause)
    AND ocs.oe_format_id > 0
    AND ocs.active_ind=1
    AND ((ocs.hide_flag=0) OR (ocs.hide_flag=null)) )
  ORDER BY d.seq, ocs.mnemonic_key_cap
  HEAD d.seq
   stat = alterlist(reply->qual[d.seq].alt_mnem_qual,10), i = 0
   IF (ocs.orderable_type_flag=10)
    reply->qual[d.seq].freetext_ind = 1
   ENDIF
  DETAIL
   i += 1
   IF (mod(i,10)=1
    AND i != 1)
    stat = alterlist(reply->qual[d.seq].alt_mnem_qual,(i+ 9))
   ENDIF
   reply->qual[d.seq].alt_mnem_qual[i].cki = ocs.cki, reply->qual[d.seq].alt_mnem_qual[i].mnemonic =
   ocs.mnemonic, reply->qual[d.seq].alt_mnem_qual[i].mnemonic_type_cd = ocs.mnemonic_type_cd,
   reply->qual[d.seq].alt_mnem_qual[i].oe_format_id = ocs.oe_format_id, reply->qual[d.seq].
   alt_mnem_qual[i].synonym_id = ocs.synonym_id
  FOOT  d.seq
   stat = alterlist(reply->qual[d.seq].alt_mnem_qual,i)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SET last_mod = "010 04/10/18 12:01"
END GO
