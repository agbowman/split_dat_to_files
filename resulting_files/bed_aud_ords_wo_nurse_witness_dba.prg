CREATE PROGRAM bed_aud_ords_wo_nurse_witness:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 from_date = dq8
    1 to_date = dq8
    1 synonym_types[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 oqual[*]
     2 orderable = vc
     2 synonyms[*]
       3 synonym_name = vc
       3 synonym_type = vc
       3 update_date_time = vc
 )
 DECLARE pharmacy_cat_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   pharmacy_cat_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE primary_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning="PRIMARY"
    AND cv.active_ind=1)
  DETAIL
   primary_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE ocs_parse = vc
 SET ocs_parse = "ocs.active_ind = 1 and ocs.hide_flag in (0,null)"
 SET syn_type_cnt = size(request->synonym_types,5)
 IF (syn_type_cnt > 0)
  SET ocs_parse = build(ocs_parse," and ocs.mnemonic_type_cd in (")
  FOR (s = 1 TO syn_type_cnt)
    IF (s=1)
     SET ocs_parse = build(ocs_parse,request->synonym_types[s].code_value)
    ELSE
     SET ocs_parse = build(ocs_parse,", ",request->synonym_types[s].code_value)
    ENDIF
  ENDFOR
  SET ocs_parse = build(ocs_parse,")")
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "NL:"
   FROM order_catalog_synonym ocs,
    order_catalog oc,
    code_value cv,
    dummyt d,
    ocs_attr_xcptn oax
   PLAN (ocs
    WHERE ocs.catalog_type_cd=pharmacy_cat_cd
     AND ocs.witness_flag=0
     AND parser(ocs_parse))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
    JOIN (d)
    JOIN (oax
    WHERE oax.synonym_id=ocs.synonym_id)
   DETAIL
    IF ((((ocs.updt_dt_tm > request->from_date)) OR ((ocs.updt_dt_tm=request->from_date)))
     AND (((ocs.updt_dt_tm < request->to_date)) OR ((ocs.updt_dt_tm=request->to_date))) )
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
   WITH nocounter, outerjoin = d, dontexist
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET ocnt = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   code_value cv,
   dummyt d,
   ocs_attr_xcptn oax
  PLAN (oc
   WHERE ((oc.catalog_type_cd+ 0)=pharmacy_cat_cd)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.witness_flag=0
    AND parser(ocs_parse))
   JOIN (cv
   WHERE cv.code_value=ocs.mnemonic_type_cd
    AND cv.active_ind=1)
   JOIN (d)
   JOIN (oax
   WHERE oax.synonym_id=ocs.synonym_id)
  ORDER BY cnvtupper(oc.description), cnvtupper(ocs.mnemonic)
  HEAD oc.catalog_cd
   ocnt = (ocnt+ 1), stat = alterlist(temp->oqual,ocnt), temp->oqual[ocnt].orderable = oc.description,
   scnt = 1, stat = alterlist(temp->oqual[ocnt].synonyms,scnt)
  DETAIL
   IF ((((ocs.updt_dt_tm > request->from_date)) OR ((ocs.updt_dt_tm=request->from_date)))
    AND (((ocs.updt_dt_tm < request->to_date)) OR ((ocs.updt_dt_tm=request->to_date))) )
    IF (ocs.mnemonic_type_cd=primary_cd)
     temp->oqual[ocnt].synonyms[1].synonym_name = ocs.mnemonic, temp->oqual[ocnt].synonyms[1].
     synonym_type = cv.display, temp->oqual[ocnt].synonyms[1].update_date_time = format(ocs
      .updt_dt_tm,"MM/DD/YY HH:MM")
    ELSE
     scnt = (scnt+ 1), stat = alterlist(temp->oqual[ocnt].synonyms,scnt), temp->oqual[ocnt].synonyms[
     scnt].synonym_name = ocs.mnemonic,
     temp->oqual[ocnt].synonyms[scnt].synonym_type = cv.display, temp->oqual[ocnt].synonyms[scnt].
     update_date_time = format(ocs.updt_dt_tm,"MM/DD/YY HH:MM")
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Orderable Item Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Update Date and Time"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (o = 1 TO ocnt)
  SET scnt = size(temp->oqual[o].synonyms,5)
  FOR (s = 1 TO scnt)
    IF ((temp->oqual[o].synonyms[s].synonym_name > " "))
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->oqual[o].orderable
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->oqual[o].synonyms[s].synonym_name
     SET reply->rowlist[row_nbr].celllist[3].string_value = temp->oqual[o].synonyms[s].synonym_type
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->oqual[o].synonyms[s].
     update_date_time
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ords_wo_nurse_witness.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
