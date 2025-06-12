CREATE PROGRAM bed_get_os_rebuild_logging:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp_reply(
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
     2 order_sentence_id = f8
     2 comp_seq = f8
 )
 FREE RECORD temp_filter
 RECORD temp_filter(
   1 age_min_value = f8
   1 age_max_value = f8
   1 age_unit_cd_display = vc
   1 pma_min_value = f8
   1 pma_max_value = f8
   1 pma_unit_cd_display = vc
   1 weight_min_value = f8
   1 weight_max_value = f8
   1 weight_unit_cd_display = vc
 )
 DECLARE elementsadded = i2
 DECLARE finalstring = vc
 DECLARE tempstr = vc
 DECLARE type = vc
 DECLARE minvalue = f8
 DECLARE maxvalue = f8
 DECLARE display = vc
 DECLARE stringsection = vc
 DECLARE computefiltercriteria(type=vc,minvalue=f8,maxvalue=f8,display=vc,elementsadded=i2) = vc
 DECLARE computefilter(index=i4) = vc
 DECLARE max_column = i4 WITH protect, constant(10)
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->collist,max_column)
 SET reply->collist[1].header_text = "Orderable/Care Set/Order Folder"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Synonym"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Old Clinical Display Line"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "New Clinical Display Line"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Sentence Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Error"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Order Sentence Filter"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Order Sentence ID"
 SET reply->collist[8].data_type = 2
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Category"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Owner"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET row_nbr = 0
 SELECT INTO "NL:"
  FROM os_rbld_ord_sent os,
   ord_cat_sent_r ord,
   order_catalog oc,
   code_value cv,
   os_rbld_msg osm,
   order_sentence sent,
   order_sentence_filter osf,
   code_value cv_age,
   code_value cv_pma,
   code_value cv_weight
  PLAN (os
   WHERE os.os_rbld_ord_sent_id > 0
    AND ((os.committed_flag > 1) OR (os.committed_flag=1
    AND os.new_ord_sent_disp_line <= " ")) )
   JOIN (ord
   WHERE ord.order_sentence_id=os.order_sentence_id)
   JOIN (oc
   WHERE oc.catalog_cd=ord.catalog_cd)
   JOIN (cv
   WHERE cv.code_value=oc.catalog_cd)
   JOIN (sent
   WHERE sent.order_sentence_id=os.order_sentence_id)
   JOIN (osm
   WHERE osm.os_rbld_ord_sent_id=outerjoin(os.os_rbld_ord_sent_id)
    AND osm.severity_flag >= outerjoin(3))
   JOIN (osf
   WHERE osf.order_sentence_id=outerjoin(os.order_sentence_id))
   JOIN (cv_age
   WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
   JOIN (cv_pma
   WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
   JOIN (cv_weight
   WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
  ORDER BY cnvtupper(cv.display), cnvtupper(os.parent_synonym_text)
  HEAD os.os_rbld_ord_sent_id
   row_nbr = (row_nbr+ 1), msg_nbr = 0, stat = alterlist(temp_reply->rowlist,row_nbr),
   stat = alterlist(temp_reply->rowlist[row_nbr].celllist,max_column), temp_reply->rowlist[row_nbr].
   celllist[1].string_value = cv.display, temp_reply->rowlist[row_nbr].celllist[2].string_value = os
   .parent_synonym_text,
   temp_reply->rowlist[row_nbr].celllist[3].string_value = os.old_ord_sent_disp_line, temp_reply->
   rowlist[row_nbr].celllist[4].string_value = os.new_ord_sent_disp_line
   IF ((temp_reply->rowlist[row_nbr].celllist[4].string_value <= " "))
    temp_reply->rowlist[row_nbr].celllist[6].string_value = "Clinical display line would be empty"
   ENDIF
   IF (sent.usage_flag=1)
    temp_reply->rowlist[row_nbr].celllist[5].string_value = "Medication Administration"
   ELSEIF (sent.usage_flag=2)
    temp_reply->rowlist[row_nbr].celllist[5].string_value = "Prescription"
   ENDIF
   temp_reply->rowlist[row_nbr].order_sentence_id = os.os_rbld_ord_sent_id, temp_reply->rowlist[
   row_nbr].celllist[8].double_value = sent.order_sentence_id, temp_reply->rowlist[row_nbr].comp_seq
    = 0.0,
   temp_filter->age_min_value = osf.age_min_value, temp_filter->age_max_value = osf.age_max_value,
   temp_filter->age_unit_cd_display = cv_age.display,
   temp_filter->pma_min_value = osf.pma_min_value, temp_filter->pma_max_value = osf.pma_max_value,
   temp_filter->pma_unit_cd_display = cv_pma.display,
   temp_filter->weight_min_value = osf.weight_min_value, temp_filter->weight_max_value = osf
   .weight_max_value, temp_filter->weight_unit_cd_display = cv_weight.display,
   finalstring = computefilter(row_nbr), temp_reply->rowlist[row_nbr].celllist[7].string_value =
   finalstring
  HEAD osm.os_rbld_msg_id
   IF (osm.os_rbld_msg_id > 0)
    temp_reply->rowlist[row_nbr].celllist[6].string_value = osm.message_txt, temp_reply->rowlist[
    row_nbr].celllist[4].string_value = ""
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM os_rbld_ord_sent os,
   cs_component cs,
   order_catalog oc,
   code_value cv,
   os_rbld_msg osm,
   order_sentence sent,
   order_sentence_filter osf,
   code_value cv_age,
   code_value cv_pma,
   code_value cv_weight
  PLAN (os
   WHERE os.os_rbld_ord_sent_id > 0
    AND ((os.committed_flag > 1) OR (os.committed_flag=1
    AND os.new_ord_sent_disp_line <= " ")) )
   JOIN (cs
   WHERE cs.order_sentence_id=os.order_sentence_id)
   JOIN (oc
   WHERE oc.catalog_cd=cs.catalog_cd)
   JOIN (cv
   WHERE cv.code_value=oc.catalog_cd)
   JOIN (sent
   WHERE sent.order_sentence_id=os.order_sentence_id)
   JOIN (osm
   WHERE osm.os_rbld_ord_sent_id=outerjoin(os.os_rbld_ord_sent_id)
    AND osm.severity_flag >= outerjoin(3))
   JOIN (osf
   WHERE osf.order_sentence_id=outerjoin(os.order_sentence_id))
   JOIN (cv_age
   WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
   JOIN (cv_pma
   WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
   JOIN (cv_weight
   WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
  ORDER BY cnvtupper(cv.display), cnvtupper(os.parent_synonym_text)
  HEAD os.os_rbld_ord_sent_id
   row_nbr = (row_nbr+ 1), msg_nbr = 0, stat = alterlist(temp_reply->rowlist,row_nbr),
   stat = alterlist(temp_reply->rowlist[row_nbr].celllist,max_column), temp_reply->rowlist[row_nbr].
   celllist[1].string_value = cv.display, temp_reply->rowlist[row_nbr].celllist[2].string_value = os
   .parent_synonym_text,
   temp_reply->rowlist[row_nbr].celllist[3].string_value = os.old_ord_sent_disp_line, temp_reply->
   rowlist[row_nbr].celllist[4].string_value = os.new_ord_sent_disp_line
   IF ((temp_reply->rowlist[row_nbr].celllist[4].string_value <= " "))
    temp_reply->rowlist[row_nbr].celllist[6].string_value = "Clinical display line would be empty"
   ENDIF
   IF (sent.usage_flag=1)
    temp_reply->rowlist[row_nbr].celllist[5].string_value = "Medication Administration"
   ELSEIF (sent.usage_flag=2)
    temp_reply->rowlist[row_nbr].celllist[5].string_value = "Prescription"
   ENDIF
   temp_reply->rowlist[row_nbr].order_sentence_id = os.os_rbld_ord_sent_id, temp_reply->rowlist[
   row_nbr].celllist[8].double_value = sent.order_sentence_id, temp_reply->rowlist[row_nbr].comp_seq
    = cs.comp_seq,
   temp_filter->age_min_value = osf.age_min_value, temp_filter->age_max_value = osf.age_max_value,
   temp_filter->age_unit_cd_display = cv_age.display,
   temp_filter->pma_min_value = osf.pma_min_value, temp_filter->pma_max_value = osf.pma_max_value,
   temp_filter->pma_unit_cd_display = cv_pma.display,
   temp_filter->weight_min_value = osf.weight_min_value, temp_filter->weight_max_value = osf
   .weight_max_value, temp_filter->weight_unit_cd_display = cv_weight.display,
   finalstring = computefilter(row_nbr), temp_reply->rowlist[row_nbr].celllist[7].string_value =
   finalstring
  HEAD osm.os_rbld_msg_id
   IF (osm.os_rbld_msg_id > 0)
    temp_reply->rowlist[row_nbr].celllist[6].string_value = osm.message_txt, temp_reply->rowlist[
    row_nbr].celllist[4].string_value = ""
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM os_rbld_ord_sent os,
   alt_sel_list l,
   order_sentence sent,
   order_catalog_synonym ocs,
   alt_sel_cat lc,
   os_rbld_msg osm,
   order_sentence_filter osf,
   code_value cv_age,
   code_value cv_pma,
   code_value cv_weight,
   prsnl p
  PLAN (os
   WHERE os.os_rbld_ord_sent_id > 0
    AND ((os.committed_flag > 1) OR (os.committed_flag=1
    AND os.new_ord_sent_disp_line <= " ")) )
   JOIN (l
   WHERE l.order_sentence_id=os.order_sentence_id)
   JOIN (sent
   WHERE sent.order_sentence_id=l.order_sentence_id
    AND sent.parent_entity2_id > 0
    AND sent.parent_entity2_name="ALT_SEL_CAT")
   JOIN (ocs
   WHERE ocs.synonym_id=sent.parent_entity_id)
   JOIN (lc
   WHERE lc.alt_sel_category_id=l.alt_sel_category_id)
   JOIN (osm
   WHERE osm.os_rbld_ord_sent_id=outerjoin(os.os_rbld_ord_sent_id)
    AND osm.severity_flag >= outerjoin(3))
   JOIN (osf
   WHERE osf.order_sentence_id=outerjoin(os.order_sentence_id))
   JOIN (cv_age
   WHERE outerjoin(osf.age_unit_cd)=cv_age.code_value)
   JOIN (cv_pma
   WHERE outerjoin(osf.pma_unit_cd)=cv_pma.code_value)
   JOIN (cv_weight
   WHERE outerjoin(osf.weight_unit_cd)=cv_weight.code_value)
   JOIN (p
   WHERE p.person_id=lc.owner_id)
  ORDER BY os.os_rbld_ord_sent_id
  HEAD os.os_rbld_ord_sent_id
   row_nbr = (row_nbr+ 1), msg_nbr = 0, stat = alterlist(temp_reply->rowlist,row_nbr),
   stat = alterlist(temp_reply->rowlist[row_nbr].celllist,max_column), temp_reply->rowlist[row_nbr].
   celllist[1].string_value = lc.long_description, temp_reply->rowlist[row_nbr].celllist[2].
   string_value = os.parent_synonym_text,
   temp_reply->rowlist[row_nbr].celllist[3].string_value = os.old_ord_sent_disp_line, temp_reply->
   rowlist[row_nbr].celllist[4].string_value = os.new_ord_sent_disp_line
   IF ((temp_reply->rowlist[row_nbr].celllist[4].string_value <= " "))
    temp_reply->rowlist[row_nbr].celllist[6].string_value = "Clinical display line would be empty"
   ENDIF
   IF (sent.usage_flag=1)
    temp_reply->rowlist[row_nbr].celllist[5].string_value = "Medication Administration"
   ELSEIF (sent.usage_flag=2)
    temp_reply->rowlist[row_nbr].celllist[5].string_value = "Prescription"
   ENDIF
   temp_reply->rowlist[row_nbr].order_sentence_id = os.os_rbld_ord_sent_id, temp_reply->rowlist[
   row_nbr].celllist[8].double_value = sent.order_sentence_id, temp_reply->rowlist[row_nbr].celllist[
   9].string_value = lc.short_description,
   temp_reply->rowlist[row_nbr].celllist[10].string_value = p.name_full_formatted, temp_reply->
   rowlist[row_nbr].comp_seq = 0.0, temp_filter->age_min_value = osf.age_min_value,
   temp_filter->age_max_value = osf.age_max_value, temp_filter->age_unit_cd_display = cv_age.display,
   temp_filter->pma_min_value = osf.pma_min_value,
   temp_filter->pma_max_value = osf.pma_max_value, temp_filter->pma_unit_cd_display = cv_pma.display,
   temp_filter->weight_min_value = osf.weight_min_value,
   temp_filter->weight_max_value = osf.weight_max_value, temp_filter->weight_unit_cd_display =
   cv_weight.display, finalstring = computefilter(row_nbr),
   temp_reply->rowlist[row_nbr].celllist[7].string_value = finalstring
  HEAD osm.os_rbld_msg_id
   IF (osm.os_rbld_msg_id > 0)
    temp_reply->rowlist[row_nbr].celllist[6].string_value = osm.message_txt, temp_reply->rowlist[
    row_nbr].celllist[4].string_value = ""
   ENDIF
  WITH nocounter
 ;end select
 SET row_nbr = 0
 IF (size(temp_reply->rowlist,5) > 0)
  SELECT INTO "nl:"
   ordersentencedisp = temp_reply->rowlist[d.seq].celllist[1].string_value, synonymdisp = cnvtupper(
    temp_reply->rowlist[d.seq].celllist[2].string_value), ordersentenceid = temp_reply->rowlist[d.seq
   ].order_sentence_id,
   caresetsequence = temp_reply->rowlist[d.seq].comp_seq
   FROM (dummyt d  WITH seq = size(temp_reply->rowlist,5))
   PLAN (d)
   ORDER BY ordersentencedisp, synonymdisp, caresetsequence,
    ordersentenceid
   HEAD ordersentenceid
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,max_column),
    reply->rowlist[row_nbr].celllist[1].string_value = temp_reply->rowlist[d.seq].celllist[1].
    string_value, reply->rowlist[row_nbr].celllist[2].string_value = temp_reply->rowlist[d.seq].
    celllist[2].string_value, reply->rowlist[row_nbr].celllist[3].string_value = temp_reply->rowlist[
    d.seq].celllist[3].string_value,
    reply->rowlist[row_nbr].celllist[4].string_value = temp_reply->rowlist[d.seq].celllist[4].
    string_value, reply->rowlist[row_nbr].celllist[5].string_value = temp_reply->rowlist[d.seq].
    celllist[5].string_value, reply->rowlist[row_nbr].celllist[6].string_value = temp_reply->rowlist[
    d.seq].celllist[6].string_value,
    reply->rowlist[row_nbr].celllist[7].string_value = temp_reply->rowlist[d.seq].celllist[7].
    string_value, reply->rowlist[row_nbr].celllist[8].double_value = temp_reply->rowlist[d.seq].
    celllist[8].double_value, reply->rowlist[row_nbr].celllist[9].string_value = temp_reply->rowlist[
    d.seq].celllist[9].string_value,
    reply->rowlist[row_nbr].celllist[10].string_value = temp_reply->rowlist[d.seq].celllist[10].
    string_value
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 IF ((request->skip_volume_check_ind=0))
  IF (size(reply->rowlist,5) > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (size(reply->rowlist,5) > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE computefilter(index)
   SET finalstring = " "
   SET elementsadded = 0
   SET type = "AGE"
   SET minvalue = temp_filter->age_min_value
   SET maxvalue = temp_filter->age_max_value
   SET display = temp_filter->age_unit_cd_display
   SET tempstr = computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   IF (size(tempstr,1) > 0
    AND elementsadded > 0)
    SET finalstring = concat(finalstring," AND ")
   ENDIF
   SET finalstring = concat(finalstring," ",tempstr)
   IF (size(tempstr,1) > 0)
    SET elementsadded = (elementsadded+ 1)
   ENDIF
   SET type = "PMA"
   SET minvalue = temp_filter->pma_min_value
   SET maxvalue = temp_filter->pma_max_value
   SET display = temp_filter->pma_unit_cd_display
   SET tempstr = computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   IF (size(tempstr,1) > 0
    AND elementsadded > 0)
    SET finalstring = concat(finalstring," AND ")
   ENDIF
   SET finalstring = concat(finalstring," ",tempstr)
   IF (size(tempstr,1) > 0)
    SET elementsadded = (elementsadded+ 1)
   ENDIF
   SET type = "WEIGHT"
   SET minvalue = temp_filter->weight_min_value
   SET maxvalue = temp_filter->weight_max_value
   SET display = temp_filter->weight_unit_cd_display
   SET tempstr = computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   IF (size(tempstr,1) > 0
    AND elementsadded > 0)
    SET finalstring = concat(finalstring," AND ")
   ENDIF
   SET finalstring = concat(finalstring," ",tempstr)
   IF (size(tempstr,1) > 0)
    SET elementsadded = (elementsadded+ 1)
   ENDIF
   RETURN(finalstring)
 END ;Subroutine
 SUBROUTINE computefiltercriteria(type,minvalue,maxvalue,display,elementsadded)
   SET stringsection = concat(" ")
   SET firstelementinstring = 0
   IF (((display=null) OR (minvalue=0
    AND maxvalue=0)) )
    RETURN(stringsection)
   ENDIF
   IF (type="PMA")
    IF (elementsadded=0)
     SET stringsection = concat(" ",type,"  ",stringsection)
    ELSE
     SET stringsection = concat(type,"  ",stringsection)
    ENDIF
   ENDIF
   IF (elementsadded=0)
    SET firstelementinstring = 1
   ENDIF
   IF (minvalue > 0
    AND maxvalue=0)
    IF (firstelementinstring=1)
     SET stringsection = concat(stringsection," Greater than or equal to ",cnvtstring(minvalue))
    ELSE
     SET stringsection = concat(stringsection," greater than or equal to ",cnvtstring(minvalue))
    ENDIF
   ELSEIF (minvalue=0
    AND maxvalue > 0)
    IF (firstelementinstring=1)
     SET stringsection = concat(stringsection," Less than ",cnvtstring(maxvalue))
    ELSE
     SET stringsection = concat(stringsection," less than ",cnvtstring(maxvalue))
    ENDIF
   ELSE
    IF (firstelementinstring=1)
     SET stringsection = concat(stringsection," Between ")
    ELSE
     SET stringsection = concat(stringsection,"between ")
    ENDIF
    SET stringsection = concat(stringsection," ",cnvtstring(minvalue))
    SET stringsection = concat(stringsection," and ")
    SET stringsection = concat(stringsection," ",cnvtstring(maxvalue))
   ENDIF
   SET stringsection = concat(stringsection," ",display)
   RETURN(stringsection)
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build(concat("os_rebuild_logging.csv"))
 ENDIF
 CALL echorecord(reply)
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
