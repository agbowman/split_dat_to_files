CREATE PROGRAM bbt_add_hist_product:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nproduct_count = i4 WITH noconstant(size(request->productlist,5))
 DECLARE nevent_count = i4 WITH noconstant(0)
 DECLARE nspecial_testing_count = i4 WITH noconstant(0)
 DECLARE nproduct_index = i4 WITH noconstant(0)
 DECLARE nevent_index = i4 WITH noconstant(0)
 DECLARE nspecial_testing_index = i4 WITH noconstant(0)
 DECLARE serrormsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE nerror_check = i2 WITH noconstant(error(serrormsg,1))
 DECLARE nproduct_cd_code_set = i4 WITH constant(1604)
 DECLARE nabo_cd_code_set = i4 WITH constant(1641)
 DECLARE nrh_cd_code_set = i4 WITH constant(1642)
 DECLARE nevent_type_cd_code_set = i4 WITH constant(1610)
 DECLARE nspecial_testing_cd_code_set = i4 WITH constant(1612)
 DECLARE prod_nbr_format_code_set = i4 WITH constant(319570)
 DECLARE nowner_inv_area_cd_code_set = i4 WITH constant(220)
 DECLARE sscript_name = c25 WITH constant("BBT_PRODUCT_HISTORY_UPLOAD")
 DECLARE dproduct_id = f8 WITH noconstant(0.0)
 DECLARE dproduct_event_id = f8 WITH noconstant(0.0)
 DECLARE dbbhist_special_testing_id = f8 WITH noconstant(0.0)
 DECLARE dperson_id = f8 WITH noconstant(0.0)
 DECLARE dlong_text_id = f8 WITH noconstant(0.0)
 DECLARE dproduct_note_id = f8 WITH noconstant(0.0)
 DECLARE dproduct_class_cd = f8 WITH noconstant(0.0)
 DECLARE dred_cell_ind = f8 WITH noconstant(0.0)
 DECLARE nabo_code_set_discrep = i2 WITH noconstant(0)
 DECLARE nrh_code_set_discrep = i2 WITH noconstant(0)
 DECLARE scdf_transfused = c12 WITH constant("7")
 DECLARE scdf_destroyed = c12 WITH constant("14")
 DECLARE scdf_shipped = c12 WITH constant("15")
 DECLARE scdf_isbt = c12 WITH constant("ISBT")
 DECLARE scdf_none = c12 WITH constant("NONE")
 DECLARE nowner_code_set_discrep = i2 WITH noconstant(0)
 DECLARE ninv_area_code_set_discrep = i2 WITH noconstant(0)
 DECLARE dpooled_product_id = f8 WITH noconstant(0.0)
 DECLARE dmodified_product_id = f8 WITH noconstant(0.0)
 DECLARE sflag_chars = c2 WITH noconstant(fillstring(2," "))
 DECLARE sdonor_xref_txt = c40 WITH noconstant(fillstring(40," "))
 DECLARE nupdate_donor_xref_txt_ind = i2 WITH noconstant(0)
 DECLARE updatedonorcrossref(null) = null
 IF ((request->contributor_system_cd <= 0.0))
  CALL errorhandler("F","CONTRIBUTOR_SYSTEM_CD validation",
   "Contributor system is blank.  Upload canceled, no product data applied.  Please resolve.")
  GO TO exit_script
 ENDIF
 FOR (nproduct_index = 1 TO nproduct_count)
   IF (size(trim(request->productlist[nproduct_index].cross_reference,3),1)=0)
    CALL errorhandler("F","CROSS_REFERENCE validation",concat(
      "Cross_reference is blank.  Upload canceled, no product upload data applied.  Please resolve ",
      "for product_nbr: ",request->productlist[nproduct_index].product_nbr,"."))
    GO TO exit_script
   ENDIF
   IF (size(trim(request->productlist[nproduct_index].product_nbr,3),1)=0)
    CALL errorhandler("F","PRODUCT_NBR validation",concat(
      "Product_number is blank.  Upload canceled, no product upload data applied.  Please resolve ",
      "for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
    GO TO exit_script
   ENDIF
   IF ((request->productlist[nproduct_index].product_nbr_format_cd > 0.0))
    SELECT INTO "nl:"
     cv.code_value, cv.code_set
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->productlist[nproduct_index].product_nbr_format_cd)
       AND cv.code_set=prod_nbr_format_code_set
       AND cv.active_ind=1)
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","PRODUCT_NBR_FORMAT_CD validation",concat(
        "Product number format is invalid.  Upload canceled, no product upload data applied.  Please resolve ",
        "for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Validate product_nbr_format_cd.",serrormsg)
     GO TO exit_script
    ENDIF
    SET sflag_chars = fillstring(2," ")
    IF (uar_get_code_meaning(request->productlist[nproduct_index].product_nbr_format_cd)=scdf_isbt)
     IF (size(trim(request->productlist[nproduct_index].flag_chars)) > 0)
      SET sflag_chars = request->productlist[nproduct_index].flag_chars
     ELSE
      SET sflag_chars = "00"
     ENDIF
    ENDIF
   ENDIF
   SET dproduct_class_cd = 0.0
   SET dred_cell_ind = 1
   SELECT INTO "nl:"
    cv.code_value, cv.code_set, pi.product_class_cd,
    pc.red_cell_product_ind
    FROM code_value cv,
     product_index pi,
     product_category pc
    PLAN (cv
     WHERE (cv.code_value=request->productlist[nproduct_index].product_cd)
      AND cv.code_set=nproduct_cd_code_set
      AND cv.active_ind=1)
     JOIN (pi
     WHERE pi.product_cd=cv.code_value)
     JOIN (pc
     WHERE pc.product_cat_cd=pi.product_cat_cd)
    DETAIL
     dproduct_class_cd = pi.product_class_cd, dred_cell_ind = pc.red_cell_product_ind
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual=0)
     CALL errorhandler("F","PRODUCT_CD validation",concat(
       "Product_type is blank.  Upload canceled, no product upload data applied.  Please resolve ",
       "for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","Validate product_cd.",serrormsg)
    GO TO exit_script
   ENDIF
   IF ((request->productlist[nproduct_index].cur_supplier_id <= 0.0))
    CALL errorhandler("F","CUR_SUPPLIER_ID validation",concat(
      "Product supplier is blank.  Upload canceled, no product upload data applied.  Please resolve ",
      "for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
    GO TO exit_script
   ENDIF
   IF ((((request->productlist[nproduct_index].expire_dt_tm=null)) OR ((request->productlist[
   nproduct_index].expire_dt_tm=0))) )
    CALL errorhandler("F","EXPIRE_DT_TM validation",concat(
      "Product expiration date and time is blank.  Upload canceled, no product upload data applied.",
      "  Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
      "."))
    GO TO exit_script
   ENDIF
   SET nabo_code_set_discrep = 1
   SET nrh_code_set_discrep = 1
   IF (dred_cell_ind=1)
    SELECT INTO "nl:"
     cv.code_value, cv.code_set
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_value IN (request->productlist[nproduct_index].abo_cd, request->productlist[
      nproduct_index].rh_cd)
       AND cv.code_set IN (nabo_cd_code_set, nrh_cd_code_set)
       AND cv.active_ind=1)
     DETAIL
      IF ((cv.code_value=request->productlist[nproduct_index].abo_cd))
       IF (cv.code_set=nabo_cd_code_set)
        nabo_code_set_discrep = 0
       ENDIF
      ENDIF
      IF ((cv.code_value=request->productlist[nproduct_index].rh_cd))
       IF (cv.code_set=nrh_cd_code_set)
        nrh_code_set_discrep = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","ABO_CD/RH_CD validation",concat(
        "ABO_cd or rh_cd not found on code_set 1641 or 1642.  Please resolve for ",
        "cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ELSEIF (nabo_code_set_discrep=1)
      CALL errorhandler("F","ABO_CD validation",concat(
        "ABO_CD not found in code_set 1641.  Please resolve for ","cross_reference: ",request->
        productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ELSEIF (nrh_code_set_discrep=1)
      CALL errorhandler("F","RH_CD validation",concat(
        "Rh_cd not found in code_set 1642.  Please resolve for ","cross_reference: ",request->
        productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Validate ABO/Rh.",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
   SET nevent_count = size(request->productlist[nproduct_index].eventlist,5)
   FOR (nevent_index = 1 TO nevent_count)
     SELECT INTO "nl:"
      cv.code_value, cv.code_set, cv.cdf_meaning
      FROM code_value cv
      PLAN (cv
       WHERE (cv.code_value=request->productlist[nproduct_index].eventlist[nevent_index].
       event_type_cd)
        AND cv.code_set=nevent_type_cd_code_set
        AND cv.cdf_meaning IN (scdf_transfused, scdf_destroyed, scdf_shipped)
        AND cv.active_ind=1)
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check=0)
      IF (curqual=0)
       CALL errorhandler("F","EVENT_TYPE_CD validation",concat(
         "Product event is blank.  Upload canceled, no product upload data applied.  ",
         "Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
         "."))
       GO TO exit_script
      ENDIF
     ELSE
      CALL errorhandler("F","Validate event_type_cd.",serrormsg)
      GO TO exit_script
     ENDIF
     IF ((((request->productlist[nproduct_index].eventlist[nevent_index].event_dt_tm=null)) OR ((
     request->productlist[nproduct_index].eventlist[nevent_index].event_dt_tm=0))) )
      CALL errorhandler("F","EVENT_DT_TM validation",concat(
        "Product event date and time is blank.  Upload canceled, no product upload data applied.",
        "  Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
        "."))
      GO TO exit_script
     ENDIF
     IF ((request->productlist[nproduct_index].eventlist[nevent_index].person_id > 0))
      SELECT INTO "nl:"
       p.person_id
       FROM person p
       PLAN (p
        WHERE (p.person_id=request->productlist[nproduct_index].eventlist[nevent_index].person_id))
       WITH nocounter
      ;end select
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","PERSON_ID cross validation",concat(
          "Person_ID does not exist on the Person table.","  Please resolve for cross_reference: ",
          request->productlist[nproduct_index].cross_reference,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","Validate person_id.",serrormsg)
       GO TO exit_script
      ENDIF
     ENDIF
     SET dperson_id = 0.0
     IF ((request->productlist[nproduct_index].eventlist[nevent_index].encntr_id > 0))
      SELECT INTO "nl:"
       e.encntr_id, e.person_id
       FROM encounter e
       PLAN (e
        WHERE (e.encntr_id=request->productlist[nproduct_index].eventlist[nevent_index].encntr_id)
         AND (request->productlist[nproduct_index].eventlist[nevent_index].person_id > 0.0)
         AND (e.person_id=request->productlist[nproduct_index].eventlist[nevent_index].person_id))
       DETAIL
        dperson_id = e.person_id
       WITH nocounter
      ;end select
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","ENCNTR_ID cross validation",concat(
          "Encntr_id does not exist on the Encounter table.","  Please resolve for cross_reference: ",
          request->productlist[nproduct_index].cross_reference,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","Validate encntr_id.",serrormsg)
       GO TO exit_script
      ENDIF
     ENDIF
   ENDFOR
   SET nspecial_testing_count = size(request->productlist[nproduct_index].specialtestinglist,5)
   FOR (nspecial_testing_index = 1 TO nspecial_testing_count)
     SELECT INTO "nl:"
      cv.code_value, cv.code_set
      FROM code_value cv
      PLAN (cv
       WHERE (cv.code_value=request->productlist[nproduct_index].specialtestinglist[
       nspecial_testing_index].special_testing_cd)
        AND cv.code_set=nspecial_testing_cd_code_set
        AND cv.active_ind=1)
      WITH nocounter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check=0)
      IF (curqual=0)
       CALL errorhandler("F","SPECIAL_TESTING_CD select",concat(
         "Special_testing_cd does not exist on the code value table or is not in code_set 1612.",
         "  Please resolve for cross_reference: ",request->productlist[nproduct_index].
         cross_reference,"."))
       GO TO exit_script
      ENDIF
     ELSE
      CALL errorhandler("F","Validate special_testing_cd.",serrormsg)
      GO TO exit_script
     ENDIF
   ENDFOR
   SET nowner_code_set_discrep = 1
   SET ninv_area_code_set_discrep = 1
   IF ((request->productlist[nproduct_index].owner_area_cd > 0)
    AND (request->productlist[nproduct_index].inv_area_cd > 0))
    SELECT INTO "nl:"
     cv.code_value, cv.code_set
     FROM code_value cv,
      location_group lg
     PLAN (cv
      WHERE cv.code_value IN (request->productlist[nproduct_index].owner_area_cd, request->
      productlist[nproduct_index].inv_area_cd)
       AND cv.code_set=nowner_inv_area_cd_code_set
       AND cv.active_ind=1)
      JOIN (lg
      WHERE (lg.parent_loc_cd=request->productlist[nproduct_index].owner_area_cd)
       AND (lg.child_loc_cd=request->productlist[nproduct_index].inv_area_cd))
     DETAIL
      IF ((cv.code_value=request->productlist[nproduct_index].owner_area_cd))
       IF (cv.code_set=nowner_inv_area_cd_code_set)
        nowner_code_set_discrep = 0
       ENDIF
      ENDIF
      IF ((cv.code_value=request->productlist[nproduct_index].inv_area_cd))
       IF (cv.code_set=nowner_inv_area_cd_code_set)
        ninv_area_code_set_discrep = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","OWNER_AREA_CD cross validation",concat(
        "Owner_area_cd or inv_area_cd not found on code_set 220.",
        "  Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
        "."))
      GO TO exit_script
     ELSEIF (nowner_code_set_discrep=1)
      CALL errorhandler("F","OWNER_AREA_CD cross validation",concat(
        "Owner_area_cd not found in code_set 220.","  Please resolve for cross_reference: ",request->
        productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ELSEIF (ninv_area_code_set_discrep=1)
      CALL errorhandler("F","INV_AREA_CD cross validation",concat(
        "Inv_area_cd not found in code_set 220.","  Please resolve for cross_reference: ",request->
        productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Validate owner/inv_area_cd.",serrormsg)
     GO TO exit_script
    ENDIF
   ELSEIF ((request->productlist[nproduct_index].owner_area_cd > 0)
    AND (request->productlist[nproduct_index].inv_area_cd <= 0))
    CALL errorhandler("F","INV_AREA_CD cross validation",concat(
      "Inventory area is blank.  Upload canceled, no product data applied.  Please resolve",
      " for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
    GO TO exit_script
   ELSEIF ((request->productlist[nproduct_index].inv_area_cd > 0)
    AND (request->productlist[nproduct_index].owner_area_cd <= 0))
    CALL errorhandler("F","OWNER_AREA_CD cross validation",concat(
      "Owner area is blank.  Upload canceled, no product data applied.  Please resolve",
      " for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    bp.product_id
    FROM bbhist_product bp
    PLAN (bp
     WHERE (bp.cross_reference=request->productlist[nproduct_index].cross_reference)
      AND (bp.contributor_system_cd=request->contributor_system_cd))
    DETAIL
     sdonor_xref_txt = bp.donor_xref_txt
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual > 0)
     IF (size(trim(request->productlist[nproduct_index].donor_xref_txt,3),1)=0)
      CALL errorhandler("F","Duplicate check select.",concat(
        "Cross-reference number is a duplicate for this contributor code.  Duplicate product.",
        "  Upload canceled, no product data applied.  Please resolve"," for cross_reference: ",
        request->productlist[nproduct_index].cross_reference,"."))
      GO TO exit_script
     ELSE
      IF (size(trim(sdonor_xref_txt,3),1)=0)
       SET nupdate_donor_xref_txt_ind = 1
      ELSE
       IF (trim(sdonor_xref_txt,3)=trim(request->productlist[nproduct_index].donor_xref_txt,3))
        CALL errorhandler("F","Duplicate check select.",concat(
          "Donor_XRef_TXT number is a duplicate for this contributor code.  Duplicate product.",
          "  Upload canceled, no product data applied.  Please resolve"," for donor_xref_txt: ",
          request->productlist[nproduct_index].donor_xref_txt,"."))
        GO TO exit_script
       ELSE
        CALL errorhandler("F","Duplicate check select.",concat(
          "Donor_XRef_TXT number doesn't match this contributor code. ",
          "  Upload canceled, no product data applied.  Please resolve"," for donor_xref_txt: ",
          request->productlist[nproduct_index].donor_xref_txt,"."))
        GO TO exit_script
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    CALL errorhandler("F","Duplicate checking.",serrormsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    bp.cross_reference, bp.product_nbr, bp.product_sub_nbr,
    bp.product_cd, bp.supplier_id, bp.supplier_prefix,
    bp.owner_area_cd, bp.inv_area_cd, bp.contributor_system_cd,
    bp.donor_xref_txt
    FROM bbhist_product bp
    PLAN (bp
     WHERE (bp.cross_reference=request->productlist[nproduct_index].cross_reference)
      AND bp.product_nbr=cnvtupper(request->productlist[nproduct_index].product_nbr)
      AND (bp.product_sub_nbr=request->productlist[nproduct_index].product_sub_nbr)
      AND (bp.product_cd=request->productlist[nproduct_index].product_cd)
      AND (bp.supplier_id=request->productlist[nproduct_index].cur_supplier_id)
      AND (bp.supplier_prefix=request->productlist[nproduct_index].supplier_prefix)
      AND (bp.owner_area_cd=request->productlist[nproduct_index].owner_area_cd)
      AND (bp.inv_area_cd=request->productlist[nproduct_index].inv_area_cd)
      AND (bp.contributor_system_cd=request->contributor_system_cd)
      AND (bp.donor_xref_txt=request->productlist[nproduct_index].donor_xref_txt))
    WITH nocounter
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual > 0)
     CALL errorhandler("F","Duplicate check.",concat(
       "Duplicate product.  Upload canceled, no product data applied.  Please resolve",
       " for cross_reference: ",request->productlist[nproduct_index].cross_reference,"."))
     GO TO exit_script
    ENDIF
   ELSE
    CALL errorhandler("F","Duplicate check",serrormsg)
    GO TO exit_script
   ENDIF
   IF (size(trim(request->productlist[nproduct_index].pooled_product_xref,3),1) > 0)
    SET dpooled_product_id = 0.0
    SELECT INTO "nl:"
     bp.cross_reference, bp.contributor_system_cd, bp.product_id
     FROM bbhist_product bp
     PLAN (bp
      WHERE (bp.cross_reference=request->productlist[nproduct_index].pooled_product_xref)
       AND (bp.contributor_system_cd=request->contributor_system_cd))
     DETAIL
      dpooled_product_id = bp.product_id
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","Pooled product validation",concat(
        "Pooled_product_xref does not match any uploaded parent product's cross_reference.",
        "  Please resolve for product_nbr: ",request->productlist[nproduct_index].product_nbr,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Pooled product check",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
   IF (size(trim(request->productlist[nproduct_index].modified_product_xref,3),1) > 0)
    SET dmodified_product_id = 0.0
    SELECT INTO "nl:"
     bp.cross_reference, bp.contributor_system_cd, bp.product_id
     FROM bbhist_product bp
     PLAN (bp
      WHERE (bp.cross_reference=request->productlist[nproduct_index].modified_product_xref)
       AND (bp.contributor_system_cd=request->contributor_system_cd))
     DETAIL
      dmodified_product_id = bp.product_id
     WITH nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","Modified_product_id validation",concat(
        "Modified_product_xref does not match any uploaded parent product's cross_reference.",
        "  Please resolve for product_nbr: ",request->productlist[nproduct_index].product_nbr,"."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Modified product check",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
   IF (nupdate_donor_xref_txt_ind=0)
    SELECT INTO "nl:"
     snbr = seq(blood_bank_seq,nextval)
     FROM dual
     DETAIL
      dproduct_id = snbr
     WITH format, nocounter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","Get unique product_id","Unable to retrieve unique product_id.")
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Get unique product_id",serrormsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM bbhist_product bp
     SET bp.product_id = dproduct_id, bp.product_nbr = cnvtupper(request->productlist[nproduct_index]
       .product_nbr), bp.product_sub_nbr = request->productlist[nproduct_index].product_sub_nbr,
      bp.alternate_nbr = cnvtupper(request->productlist[nproduct_index].alternate_nbr), bp.product_cd
       = request->productlist[nproduct_index].product_cd, bp.product_class_cd = dproduct_class_cd,
      bp.supplier_id = request->productlist[nproduct_index].cur_supplier_id, bp.supplier_prefix =
      request->productlist[nproduct_index].supplier_prefix, bp.abo_cd = request->productlist[
      nproduct_index].abo_cd,
      bp.rh_cd = request->productlist[nproduct_index].rh_cd, bp.expire_dt_tm = cnvtdatetime(request->
       productlist[nproduct_index].expire_dt_tm), bp.volume = request->productlist[nproduct_index].
      volume,
      bp.unit_meas_cd = request->productlist[nproduct_index].unit_meas_cd, bp.owner_area_cd = request
      ->productlist[nproduct_index].owner_area_cd, bp.inv_area_cd = request->productlist[
      nproduct_index].inv_area_cd,
      bp.pooled_product_id = dpooled_product_id, bp.modified_product_id = dmodified_product_id, bp
      .pooled_product_ind = request->productlist[nproduct_index].pooled_product_ind,
      bp.modified_product_ind = request->productlist[nproduct_index].modified_product_ind, bp
      .cross_reference = request->productlist[nproduct_index].cross_reference, bp
      .contributor_system_cd = request->contributor_system_cd,
      bp.upload_dt_tm = cnvtdatetime(sysdate), bp.active_ind = 1, bp.active_status_cd = reqdata->
      active_status_cd,
      bp.active_status_dt_tm =
      IF ((request->productlist[nproduct_index].product_status_dt_tm > 0)) cnvtdatetime(request->
        productlist[nproduct_index].product_status_dt_tm)
      ELSE cnvtdatetime(sysdate)
      ENDIF
      , bp.active_status_prsnl_id =
      IF ((request->productlist[nproduct_index].product_prsnl_id > 0)) request->productlist[
       nproduct_index].product_prsnl_id
      ELSE request->active_status_prsnl_id
      ENDIF
      , bp.updt_cnt = 0,
      bp.updt_dt_tm = cnvtdatetime(sysdate), bp.updt_id = reqinfo->updt_id, bp.updt_task = reqinfo->
      updt_task,
      bp.updt_applctx = reqinfo->updt_applctx, bp.flag_chars = sflag_chars, bp.product_nbr_format_cd
       = request->productlist[nproduct_index].product_nbr_format_cd,
      bp.donor_xref_txt = request->productlist[nproduct_index].donor_xref_txt
     WITH nocounter
    ;end insert
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","BBHIST_PRODUCT insert",concat("Insert into BBHIST_PRODUCT table failed.",
        "  Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
        "."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","BBHIST_PRODUCT insert",serrormsg)
     GO TO exit_script
    ENDIF
   ELSE
    CALL updatedonorcrossref(null)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
   FOR (nevent_index = 1 TO nevent_count)
     SELECT INTO "nl:"
      snbr = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       dproduct_event_id = snbr
      WITH format, counter
     ;end select
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check=0)
      IF (curqual=0)
       CALL errorhandler("F","Get unique product_event_id",
        "Unable to retrieve unique product_event_id.")
       GO TO exit_script
      ENDIF
     ELSE
      CALL errorhandler("F","Get unique product_event_id",serrormsg)
      GO TO exit_script
     ENDIF
     INSERT  FROM bbhist_product_event bpe
      SET bpe.product_event_id = dproduct_event_id, bpe.product_id = dproduct_id, bpe.person_id =
       request->productlist[nproduct_index].eventlist[nevent_index].person_id,
       bpe.encntr_id = request->productlist[nproduct_index].eventlist[nevent_index].encntr_id, bpe
       .event_type_cd = request->productlist[nproduct_index].eventlist[nevent_index].event_type_cd,
       bpe.event_dt_tm = cnvtdatetime(request->productlist[nproduct_index].eventlist[nevent_index].
        event_dt_tm),
       bpe.prsnl_id = request->productlist[nproduct_index].eventlist[nevent_index].prsnl_id, bpe
       .reason_cd = request->productlist[nproduct_index].eventlist[nevent_index].reason_cd, bpe
       .volume = request->productlist[nproduct_index].eventlist[nevent_index].volume,
       bpe.bag_returned_ind = request->productlist[nproduct_index].eventlist[nevent_index].
       bag_returned_ind, bpe.tag_returned_ind = request->productlist[nproduct_index].eventlist[
       nevent_index].tag_returned_ind, bpe.qty = request->productlist[nproduct_index].eventlist[
       nevent_index].qty,
       bpe.international_unit = request->productlist[nproduct_index].eventlist[nevent_index].
       international_unit, bpe.contributor_system_cd = request->contributor_system_cd, bpe.active_ind
        = 1,
       bpe.active_status_cd = reqdata->active_status_cd, bpe.active_status_dt_tm = cnvtdatetime(
        sysdate), bpe.active_status_prsnl_id = reqinfo->updt_id,
       bpe.updt_cnt = 0, bpe.updt_dt_tm = cnvtdatetime(sysdate), bpe.updt_id = reqinfo->updt_id,
       bpe.updt_task = reqinfo->updt_task, bpe.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check=0)
      IF (curqual=0)
       CALL errorhandler("F","BBHIST_PRODUCT_EVENT insert",concat(
         "Insert into BBHIST_PRODUCT_EVENT table failed.","  Please resolve for cross_reference: ",
         request->productlist[nproduct_index].cross_reference,"."))
       GO TO exit_script
      ENDIF
     ELSE
      CALL errorhandler("F","BBHIST_PRODUCT_EVENT insert",serrormsg)
      GO TO exit_script
     ENDIF
   ENDFOR
   IF (nspecial_testing_count != 0)
    FOR (nspecial_testing_index = 1 TO nspecial_testing_count)
      SELECT INTO "nl:"
       snbr = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        dbbhist_special_testing_id = snbr
       WITH format, counter
      ;end select
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","Get bbhist_special_testing_id",
         "Unable to retrieve unique bbhist_special_testing_id.")
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","Get bbhist_special_testing_id",serrormsg)
       GO TO exit_script
      ENDIF
      INSERT  FROM bbhist_special_testing bst
       SET bst.bbhist_special_testing_id = dbbhist_special_testing_id, bst.product_id = dproduct_id,
        bst.special_testing_cd = request->productlist[nproduct_index].specialtestinglist[
        nspecial_testing_index].special_testing_cd,
        bst.active_ind = 1, bst.active_status_cd = reqdata->active_status_cd, bst.active_status_dt_tm
         =
        IF ((request->productlist[nproduct_index].specialtestinglist[nspecial_testing_index].
        special_testing_dt_tm > 0)) cnvtdatetime(request->productlist[nproduct_index].
          specialtestinglist[nspecial_testing_index].special_testing_dt_tm)
        ELSE cnvtdatetime(sysdate)
        ENDIF
        ,
        bst.active_status_prsnl_id =
        IF ((request->productlist[nproduct_index].specialtestinglist[nspecial_testing_index].
        special_testing_prsnl_id > 0)) request->productlist[nproduct_index].specialtestinglist[
         nspecial_testing_index].special_testing_prsnl_id
        ELSE request->active_status_prsnl_id
        ENDIF
        , bst.updt_cnt = 0, bst.updt_dt_tm = cnvtdatetime(sysdate),
        bst.updt_id = reqinfo->updt_id, bst.updt_task = reqinfo->updt_task, bst.updt_applctx =
        reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET nerror_check = error(serrormsg,0)
      IF (nerror_check=0)
       IF (curqual=0)
        CALL errorhandler("F","BBHIST_SPECIAL_TESTING insert",concat(
          "Insert into BBHIST_SPECIAL_TESTING table failed.","  Please resolve for cross_reference: ",
          request->productlist[nproduct_index].cross_reference,"."))
        GO TO exit_script
       ENDIF
      ELSE
       CALL errorhandler("F","Insert:BBHIST_SPECIAL_TESTING",serrormsg)
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   IF (size(trim(request->productlist[nproduct_index].comment,3),1) > 0)
    SELECT INTO "nl:"
     snbr = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      dlong_text_id = snbr
     WITH format, counter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","Get unique long_text_id","Unable to retrieve unique long_text_id.")
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Get unique long_text_id",serrormsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM long_text lt
     SET lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm
       =
      IF ((request->productlist[nproduct_index].comment_status_dt_tm > 0)) cnvtdatetime(request->
        productlist[nproduct_index].comment_status_dt_tm)
      ELSE cnvtdatetime(sysdate)
      ENDIF
      ,
      lt.active_status_prsnl_id =
      IF ((request->productlist[nproduct_index].comment_prsnl_id > 0)) request->productlist[
       nproduct_index].comment_prsnl_id
      ELSE request->active_status_prsnl_id
      ENDIF
      , lt.long_text = request->productlist[nproduct_index].comment, lt.long_text_id = dlong_text_id,
      lt.parent_entity_id = dproduct_id, lt.parent_entity_name = "BBHIST_PRODUCT", lt.updt_applctx =
      reqinfo->updt_applctx,
      lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->updt_id,
      lt.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","LONG_TEXT insert",concat(
        "Insert of uploaded comment into LONG_TEXT table failed.",
        "  Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
        "."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","LONG_TEXT insert",serrormsg)
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     snbr = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      dproduct_note_id = snbr
     WITH format, counter
    ;end select
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","Get unique product_note_id","Unable to retrieve unique product_note_id."
       )
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","Get unique product_note_id",serrormsg)
     GO TO exit_script
    ENDIF
    INSERT  FROM product_note pn
     SET pn.active_ind = 1, pn.active_status_cd = reqdata->active_status_cd, pn.active_status_dt_tm
       =
      IF ((request->productlist[nproduct_index].comment_status_dt_tm > 0)) cnvtdatetime(request->
        productlist[nproduct_index].comment_status_dt_tm)
      ELSE cnvtdatetime(sysdate)
      ENDIF
      ,
      pn.active_status_prsnl_id =
      IF ((request->productlist[nproduct_index].comment_prsnl_id > 0)) request->productlist[
       nproduct_index].comment_prsnl_id
      ELSE request->active_status_prsnl_id
      ENDIF
      , pn.product_note_id = dproduct_note_id, pn.product_id = 0.0,
      pn.bbhist_product_id = dproduct_id, pn.long_text_id = dlong_text_id, pn.updt_applctx = reqinfo
      ->updt_applctx,
      pn.updt_cnt = 0, pn.updt_dt_tm = cnvtdatetime(sysdate), pn.updt_id = reqinfo->updt_id,
      pn.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET nerror_check = error(serrormsg,0)
    IF (nerror_check=0)
     IF (curqual=0)
      CALL errorhandler("F","PRODUCT_NOTE insert",concat("Insert into PRODUCT_NOTE table failed.",
        "  Please resolve for cross_reference: ",request->productlist[nproduct_index].cross_reference,
        "."))
      GO TO exit_script
     ENDIF
    ELSE
     CALL errorhandler("F","PRODUCT_NOTE insert",serrormsg)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = sscript_name
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE updatedonorcrossref(null)
   DECLARE dproduct_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM bbhist_product bp
    PLAN (bp
     WHERE (bp.cross_reference=request->productlist[nproduct_index].cross_reference)
      AND bp.product_nbr=cnvtupper(request->productlist[nproduct_index].product_nbr)
      AND (bp.product_sub_nbr=request->productlist[nproduct_index].product_sub_nbr)
      AND (bp.product_cd=request->productlist[nproduct_index].product_cd)
      AND (bp.supplier_id=request->productlist[nproduct_index].cur_supplier_id)
      AND (bp.supplier_prefix=request->productlist[nproduct_index].supplier_prefix)
      AND (bp.owner_area_cd=request->productlist[nproduct_index].owner_area_cd)
      AND (bp.inv_area_cd=request->productlist[nproduct_index].inv_area_cd)
      AND (bp.contributor_system_cd=request->contributor_system_cd))
    DETAIL
     dproduct_id = bp.product_id
    WITH nocounter, forupdate(bp)
   ;end select
   SET nerror_check = error(serrormsg,0)
   IF (nerror_check=0)
    IF (curqual > 0)
     UPDATE  FROM bbhist_product bp
      SET bp.donor_xref_txt = request->productlist[nproduct_index].donor_xref_txt
      WHERE bp.product_id=dproduct_id
      WITH nocounter
     ;end update
     SET nerror_check = error(serrormsg,0)
     IF (nerror_check=0)
      IF (curqual=0)
       CALL errorhandler("F","Update donor cross reference",
        "Upload canceled, no product data applied.  Please resolve.")
       GO TO exit_script
      ENDIF
     ELSE
      CALL errorhandler("F","Update donor cross reference",serrormsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    CALL errorhandler("F","Update donor cross reference",serrormsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
