CREATE PROGRAM bed_aud_mltm_content:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 multum_orders[*]
     2 primary_synonym[*]
       3 description = vc
       3 type = vc
       3 mnemonic = vc
       3 hide_ind = i2
       3 rx_mask = i2
       3 cki = vc
     2 synonyms[*]
       3 description = vc
       3 type = vc
       3 mnemonic = vc
       3 hide_ind = i2
       3 rx_mask = i2
       3 cki = vc
     2 catalog_cki = vc
     2 skip_ind = i2
 )
 DECLARE getrxmaskstring(rx_mask=i2) = vc
 DECLARE findskippedorders(ord_count=i4) = null
 DECLARE high_volume_count = i4 WITH protect, noconstant(0)
 DECLARE ord_count = i4 WITH protect, noconstant(0)
 DECLARE syn_count = i4 WITH protect, noconstant(0)
 DECLARE temp_ord_count = i4 WITH protect, noconstant(0)
 DECLARE temp_syn_count = i4 WITH protect, noconstant(0)
 DECLARE rep_count = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m
  PLAN (m
   WHERE  NOT ( EXISTS (
   (SELECT
    ocs.cki
    FROM order_catalog_synonym ocs
    WHERE ocs.cki=m.synonym_cki
     AND ((trim(ocs.concept_cki)=m.synonym_concept_cki
     AND ocs.concept_cki > " ") OR (trim(ocs.concept_cki) IN ("", " ", null)
     AND m.synonym_concept_cki IN ("", " ", null)))
     AND ocs.cki > " "))))
  ORDER BY trim(cnvtupper(m.description)), m.catalog_cki, m.mnemonic_type,
   m.mnemonic
  HEAD REPORT
   stat = alterlist(temp_reply->multum_orders,10)
  HEAD m.catalog_cki
   ord_count = (ord_count+ 1), temp_ord_count = (temp_ord_count+ 1)
   IF (temp_ord_count > 10)
    temp_ord_count = 1, stat = alterlist(temp_reply->multum_orders,(ord_count+ 10))
   ENDIF
   temp_reply->multum_orders[ord_count].catalog_cki = m.catalog_cki, syn_count = 0, temp_syn_count =
   0,
   stat = alterlist(temp_reply->multum_orders[ord_count].synonyms,10)
  DETAIL
   IF (m.primary_ind=1)
    stat = alterlist(temp_reply->multum_orders[ord_count].primary_synonym,1), temp_reply->
    multum_orders[ord_count].primary_synonym[1].description = m.description, temp_reply->
    multum_orders[ord_count].primary_synonym[1].type = m.mnemonic_type,
    temp_reply->multum_orders[ord_count].primary_synonym[1].mnemonic = m.mnemonic, temp_reply->
    multum_orders[ord_count].primary_synonym[1].hide_ind = m.hide_ind, temp_reply->multum_orders[
    ord_count].primary_synonym[1].rx_mask = m.rx_mask_nbr,
    temp_reply->multum_orders[ord_count].primary_synonym[1].cki = m.synonym_cki
   ELSE
    syn_count = (syn_count+ 1), temp_syn_count = (temp_syn_count+ 1)
    IF (temp_syn_count > 10)
     temp_syn_count = 0, stat = alterlist(temp_reply->multum_orders[ord_count].synonyms,(syn_count+
      10))
    ENDIF
    temp_reply->multum_orders[ord_count].synonyms[syn_count].description = m.description, temp_reply
    ->multum_orders[ord_count].synonyms[syn_count].type = m.mnemonic_type, temp_reply->multum_orders[
    ord_count].synonyms[syn_count].mnemonic = m.mnemonic,
    temp_reply->multum_orders[ord_count].synonyms[syn_count].hide_ind = m.hide_ind, temp_reply->
    multum_orders[ord_count].synonyms[syn_count].rx_mask = m.rx_mask_nbr, temp_reply->multum_orders[
    ord_count].synonyms[syn_count].cki = m.synonym_cki
   ENDIF
  FOOT  m.catalog_cki
   high_volume_count = (high_volume_count+ syn_count), stat = alterlist(temp_reply->multum_orders[
    ord_count].synonyms,syn_count)
  FOOT REPORT
   stat = alterlist(temp_reply->multum_orders,ord_count)
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_count > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_count > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 CALL findskippedorders(ord_count)
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Orderable Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Synonym"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Hide"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Rx Mask"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "CNUM"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 FOR (x = 1 TO ord_count)
   IF ((temp_reply->multum_orders[x].skip_ind=0))
    IF (size(temp_reply->multum_orders[x].primary_synonym,5)=1)
     SET rep_count = (rep_count+ 1)
     SET stat = alterlist(reply->rowlist,rep_count)
     SET stat = alterlist(reply->rowlist[rep_count].celllist,6)
     SET reply->rowlist[rep_count].celllist[1].string_value = temp_reply->multum_orders[x].
     primary_synonym[1].description
     SET reply->rowlist[rep_count].celllist[2].string_value = temp_reply->multum_orders[x].
     primary_synonym[1].type
     SET reply->rowlist[rep_count].celllist[3].string_value = temp_reply->multum_orders[x].
     primary_synonym[1].mnemonic
     IF ((temp_reply->multum_orders[x].primary_synonym[1].hide_ind=1))
      SET reply->rowlist[rep_count].celllist[4].string_value = "X"
     ENDIF
     SET reply->rowlist[rep_count].celllist[5].string_value = build2("",getrxmaskstring(temp_reply->
       multum_orders[x].primary_synonym[1].rx_mask))
     SET reply->rowlist[rep_count].celllist[6].string_value = temp_reply->multum_orders[x].
     primary_synonym[1].cki
    ENDIF
    SET syn_count = size(temp_reply->multum_orders[x].synonyms,5)
    SET stat = alterlist(reply->rowlist,(rep_count+ syn_count))
    FOR (y = 1 TO syn_count)
      SET rep_count = (rep_count+ 1)
      SET stat = alterlist(reply->rowlist[rep_count].celllist,6)
      SET reply->rowlist[rep_count].celllist[1].string_value = temp_reply->multum_orders[x].synonyms[
      y].description
      SET reply->rowlist[rep_count].celllist[2].string_value = temp_reply->multum_orders[x].synonyms[
      y].type
      SET reply->rowlist[rep_count].celllist[3].string_value = temp_reply->multum_orders[x].synonyms[
      y].mnemonic
      IF ((temp_reply->multum_orders[x].synonyms[y].hide_ind=1))
       SET reply->rowlist[rep_count].celllist[4].string_value = "X"
      ENDIF
      SET reply->rowlist[rep_count].celllist[5].string_value = getrxmaskstring(temp_reply->
       multum_orders[x].synonyms[y].rx_mask)
      SET reply->rowlist[rep_count].celllist[6].string_value = temp_reply->multum_orders[x].synonyms[
      y].cki
    ENDFOR
   ENDIF
 ENDFOR
 SUBROUTINE getrxmaskstring(rx_mask)
   DECLARE rx_mask_string = vc WITH protect, noconstant(" ")
   IF (band(rx_mask,1) > 0)
    SET rx_mask_string = build(rx_mask_string,"Diluent")
   ENDIF
   IF (band(rx_mask,2) > 0)
    IF (rx_mask_string > " ")
     SET rx_mask_string = build(rx_mask_string,", Additive")
    ELSE
     SET rx_mask_string = build(rx_mask_string,"Additive")
    ENDIF
   ENDIF
   IF (band(rx_mask,4) > 0)
    IF (rx_mask_string > " ")
     SET rx_mask_string = build(rx_mask_string,", Med")
    ELSE
     SET rx_mask_string = build(rx_mask_string,"Med")
    ENDIF
   ENDIF
   IF (band(rx_mask,8) > 0)
    IF (rx_mask_string > " ")
     SET rx_mask_string = build(rx_mask_string,", TPN")
    ELSE
     SET rx_mask_string = build(rx_mask_string,"TPN")
    ENDIF
   ENDIF
   IF (band(rx_mask,16) > 0)
    IF (rx_mask_string > " ")
     SET rx_mask_string = build(rx_mask_string,", Sliding Scale")
    ELSE
     SET rx_mask_string = build(rx_mask_string,"Sliding Scale")
    ENDIF
   ENDIF
   IF (band(rx_mask,32) > 0)
    IF (rx_mask_string > " ")
     SET rx_mask_string = build(rx_mask_string,", Tapering Dose")
    ELSE
     SET rx_mask_string = build(rx_mask_string,"Tapering Dose")
    ENDIF
   ENDIF
   IF (band(rx_mask,64) > 0)
    IF (rx_mask_string > " ")
     SET rx_mask_string = build(rx_mask_string,", PCA Pump")
    ELSE
     SET rx_mask_string = build(rx_mask_string,"PCA Pump")
    ENDIF
   ENDIF
   RETURN(rx_mask_string)
 END ;Subroutine
 SUBROUTINE findskippedorders(ord_count)
   FOR (i = 1 TO ord_count)
     IF (size(temp_reply->multum_orders[i].primary_synonym,5)=0)
      SELECT INTO "nl:"
       FROM order_catalog oc,
        code_value cv
       PLAN (oc
        WHERE (oc.cki=temp_reply->multum_orders[i].catalog_cki)
         AND oc.active_ind=1)
        JOIN (cv
        WHERE cv.code_value=oc.catalog_cd
         AND cv.code_set=200
         AND cv.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET temp_reply->multum_orders[i].skip_ind = 1
      ELSEIF (curqual > 1)
       SELECT INTO "nl:"
        FROM mltm_order_catalog_load m,
         order_catalog oc
        PLAN (m
         WHERE (m.catalog_cki=temp_reply->multum_orders[i].catalog_cki)
          AND cnvtupper(m.mnemonic_type)="PRIMARY")
         JOIN (oc
         WHERE oc.cki=m.catalog_cki
          AND oc.primary_mnemonic=m.mnemonic
          AND oc.active_ind=1)
        WITH nocounter
       ;end select
       IF (((curqual=0) OR (curqual > 1)) )
        SET temp_reply->multum_orders[i].skip_ind = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("new_multum_content_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
