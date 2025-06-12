CREATE PROGRAM ctp_pha_form_ndc_cls
 CREATE CLASS mtch_ctp_file_output FROM ext_ctp_file_output
 init
 SUBROUTINE (_::addheader(txt=vc) =null)
   CALL PRIVATE::increment(PRIVATE::by_column)
   IF (size(private::grid->row,5)=0)
    SET stat = alterlist(private::grid->row,1)
   ENDIF
   SET stat = alterlist(private::grid->row[PRIVATE::current_row].col,PRIVATE::current_column)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = cnvtupper(trim(txt,
     3))
   SET PRIVATE::max_columns = PRIVATE::current_column
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS ext_ctp_file_output FROM ctp_file_output
 init
 SUBROUTINE (_::addreal(real=f8,option=i2(value,0),direction=i2(value,0)) =null)
   DECLARE formatted = vc WITH protect, noconstant(" ")
   IF (real > 0)
    CASE (option)
     OF 0:
     OF 1:
      SET formatted = trim(format(real,"############.#####;T(1)"),3)
     OF 2:
      SET formatted = trim(format(real,"############.#####;T(2)"),3)
     OF 3:
      SET formatted = cnvtstring(real,19,2)
     ELSE
      SET formatted = trim(format(real,"############.#####;T(1)"),3)
    ENDCASE
   ELSE
    SET formatted = " "
   ENDIF
   CALL PRIVATE::increment(direction)
   SET private::grid->row[PRIVATE::current_row].col[PRIVATE::current_column].txt = formatted
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_updt_username
 init
 RECORD PRIVATE::prsnl(
   1 list[*]
     2 person_id = f8
 )
 RECORD PRIVATE::username(
   1 list[*]
     2 person_id = f8
     2 username = vc
 )
 DECLARE PRIVATE::batch_size = i4 WITH noconstant(10000)
 DECLARE PRIVATE::cnt = i4 WITH noconstant(0)
 SUBROUTINE (_::initialize(batch_size=i4(value,0)) =null)
  IF (batch_size > 0)
   SET PRIVATE::batch_size = batch_size
  ENDIF
  SET stat = alterlist(private::prsnl->list,PRIVATE::batch_size)
 END ;Subroutine
 DECLARE _::resize(null) = null
 SUBROUTINE _::resize(null)
   SET stat = alterlist(private::prsnl->list,PRIVATE::cnt)
 END ;Subroutine
 SUBROUTINE (_::addprsnlidtolist(id=f8) =null)
   SET PRIVATE::cnt += 1
   IF ((PRIVATE::cnt > size(private::prsnl->list,5)))
    SET stat = alterlist(private::prsnl->list,(size(private::prsnl->list,5)+ PRIVATE::batch_size))
   ENDIF
   SET private::prsnl->list[PRIVATE::cnt].person_id = id
 END ;Subroutine
 DECLARE _::getusernames(null) = null
 SUBROUTINE _::getusernames(null)
  DECLARE idx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE expand(idx,1,size(private::prsnl->list,5),p.person_id,private::prsnl->list[idx].person_id))
   ORDER BY p.person_id
   HEAD REPORT
    cnt = 0
   HEAD p.person_id
    cnt += 1
    IF (mod(cnt,10000)=1)
     stat = alterlist(private::username->list,(cnt+ 9999))
    ENDIF
    private::username->list[cnt].person_id = p.person_id, private::username->list[cnt].username = p
    .username
   FOOT REPORT
    stat = alterlist(private::username->list,cnt)
   WITH nocounter, expand = 2
  ;end select
 END ;Subroutine
 SUBROUTINE (_::formatusername(person_id=f8(value,0.0),dt_tm=vc(value,0.0)) =vc)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE username = vc WITH protect, noconstant(" ")
   SET pos = locatevalsort(idx,1,size(private::username->list,5),person_id,private::username->list[
    idx].person_id)
   IF (pos > 0)
    SET username = private::username->list[pos].username
   ENDIF
   IF (size(trim(username)) > 0)
    RETURN(username)
   ELSEIF (dt_tm <= 0.0)
    RETURN(" ")
   ELSE
    RETURN(concat("(N/A) - ID: ",cnvtstring(person_id,17,0)))
   ENDIF
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_dosage_form FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getdosageform = null WITH protect, class(pha_get_generic)
   SET pha::getdosageform.request->code_set = 4002
   IF ( NOT (PHA::getdosageform.perform(0)))
    SET PRIVATE::err_msg = PHA::getdosageform.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getdosageform.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (pha::getdosageform.reply->qual[idx].activeind)
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getdosageform.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getdosageform.reply->qual[idx].display
     ENDIF
   ENDFOR
   SET stat = alterlist(_::data->list,cnt)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_facilities FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getfacilities = null WITH protect, class(pha_get_generic)
   SET pha::getfacilities.request->code_set = 220
   SET pha::getfacilities.request->meaning = "FACILITY"
   IF ( NOT (PHA::getfacilities.perform(0)))
    SET PRIVATE::err_msg = PHA::getfacilities.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getfacilities.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
    SET _::data->list[idx].id = pha::getfacilities.reply->qual[idx].code_value
    SET _::data->list[idx].display = pha::getfacilities.reply->qual[idx].display
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_formulary FROM edcw_get_data_cls
 init
 RECORD _::facility(
   1 list[*]
     2 id = f8
     2 display = vc
 )
 RECORD _::data(
   1 list[*]
     2 pharmacy_type_cd = f8
     2 pharmacy_type = vc
     2 item_id = f8
     2 label_desc = vc
     2 active_ind = i2
     2 mnemonic = vc
     2 drug_formulation_code = vc
     2 drug_formulation = vc
     2 oc_desc = vc
     2 oc_cki = vc
     2 given_strength = vc
     2 legal_status_cd = f8
     2 form_cd = f8
     2 route_cd = f8
     2 medication_ind = i2
     2 intermittent_ind = i2
     2 continuous_ind = i2
     2 default_format = i2
     2 strength = f8
     2 strength_unit_cd = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 disp_cat_cd = f8
     2 divisible_ind = i2
     2 facilities = vc
     2 ndc[*]
       3 ndc_code = vc
       3 description = vc
       3 brand_name = vc
       3 active_ind = i2
       3 sequence = i4
       3 manf_item_id = f8
       3 manufacturer_cd = f8
       3 awp = f8
       3 pkg_size = f8
       3 base_pkg_size_cd = f8
       3 pkg_size_unit_cd = f8
       3 outer_pkg_size = f8
       3 outer_pkg_unit_cd = f8
       3 inner[*]
         4 inner_ndc_code = vc
         4 active_ind = i2
       3 unit_dose_ind = i2
       3 brand_ind = i2
       3 updt_id = f8
       3 updt_dttm = dq8
 )
 DECLARE _::active_ind = i2 WITH protect, noconstant(- (1))
 DECLARE _::ndc_active_ind = i2 WITH protect, noconstant(- (1))
 DECLARE _::pharmacy_type = f8 WITH protect, noconstant(0)
 DECLARE _::item_id = f8 WITH protect, noconstant(0)
 DECLARE _::client_suffix = vc WITH protect, noconstant(" ")
 DECLARE _::get_facilities = i2 WITH protect, noconstant(0)
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE 4050_awp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8940"))
   DECLARE 11000_brand_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3303"))
   DECLARE 11000_desc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3290"))
   DECLARE 11000_inner_ndc_cd = f8 WITH protect, constant(uar_get_code_by_cki(
     "CKI.CODEVALUE!4104840776"))
   DECLARE 11000_ndc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3295"))
   DECLARE 11000_short_desc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3293"))
   DECLARE product = i2 WITH protect, constant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE PHA::getformulary = null WITH protect, class(pha_formulary_query)
   SET pha::getformulary.request->qry_identifiers = 1
   SET pha::getformulary.request->qry_medproducts = 1
   SET pha::getformulary.request->qry_oe_defaults = 1
   SET pha::getformulary.request->qry_dispense = 1
   SET pha::getformulary.request->qry_order_catalog = 1
   IF (_::get_facilities)
    SET pha::getformulary.request->facility_limit = 1
    SET pha::getformulary.request->facility_sort = 1
    SET pha::getformulary.request->qry_facilities = 1
   ENDIF
   SET stat = alterlist(pha::getformulary.request->ident_type,5)
   SET pha::getformulary.request->ident_type[1].code_value = 11000_desc_cd
   SET pha::getformulary.request->ident_type[2].code_value = 11000_ndc_cd
   SET pha::getformulary.request->ident_type[3].code_value = 11000_inner_ndc_cd
   SET pha::getformulary.request->ident_type[4].code_value = 11000_brand_cd
   SET pha::getformulary.request->ident_type[5].code_value = 11000_short_desc_cd
   SET stat = alterlist(pha::getformulary.request->med_type,1)
   SET pha::getformulary.request->med_type[1].flag = product
   SET stat = alterlist(pha::getformulary.request->facility,size(_::facility->list,5))
   FOR (idx = 1 TO size(_::facility->list,5))
     SET pha::getformulary.request->facility[idx].code_value = _::facility->list[idx].id
   ENDFOR
   IF ((_::pharmacy_type > 0))
    SET stat = alterlist(pha::getformulary.request->pharmacy_type,1)
    SET pha::getformulary.request->pharmacy_type[1].code_value = _::pharmacy_type
   ENDIF
   IF ((_::item_id > 0))
    SET stat = alterlist(pha::getformulary.request->item,1)
    SET pha::getformulary.request->item[1].id = _::item_id
   ENDIF
   SET pha::getformulary.request->item_active_ind = _::active_ind
   SET pha::getformulary.request->ndc_active_ind = _::ndc_active_ind
   SET pha::getformulary.request->ndc_primary_ind = - (1)
   SET pha::getformulary.request->ident_search_str = _::client_suffix
   SET pha::getformulary.request->ident_search_type = 11000_desc_cd
   IF ( NOT (PHA::getformulary.perform(0)))
    SET PRIVATE::err_msg = PHA::getformulary.geterror(0)
    RETURN(0)
   ENDIF
   SET curalias ref pha::getformulary.reply->qual[idx]
   SET curalias ref_ident pha::getformulary.reply->qual[idx].ident[ident_idx]
   SET curalias ref_ndc pha::getformulary.reply->qual[idx].ndc[ndc_idx]
   SET curalias ref_ndc_ident pha::getformulary.reply->qual[idx].ndc[ndc_idx].ident[ident_idx]
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE ndc_idx = i4 WITH protect, noconstant(0)
   DECLARE ident_idx = i4 WITH protect, noconstant(0)
   DECLARE ident_cnt = i4 WITH protect, noconstant(0)
   DECLARE cost_idx = i4 WITH protect, noconstant(0)
   DECLARE cost_cnt = i4 WITH protect, noconstant(0)
   DECLARE facil_idx = i4 WITH protect, noconstant(0)
   DECLARE facil_cnt = i4 WITH protect, noconstant(0)
   DECLARE facil_str = vc WITH protect, noconstant(" ")
   DECLARE inner_cnt = i4 WITH protect, noconstant(0)
   DECLARE type_cd = f8 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getformulary.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     SET _::data->list[idx].pharmacy_type_cd = ref->pharmacy_type_cd
     SET _::data->list[idx].pharmacy_type = uar_get_code_display(ref->pharmacy_type_cd)
     SET _::data->list[idx].item_id = ref->item_id
     SET _::data->list[idx].label_desc = ref->label_desc
     SET _::data->list[idx].active_ind = ref->active_ind
     SET _::data->list[idx].drug_formulation_code = ref->drug_formulation_code
     SET _::data->list[idx].drug_formulation = ref->drug_formulation
     SET _::data->list[idx].oc_desc = ref->oc_desc
     SET _::data->list[idx].oc_cki = ref->oc_cki
     SET _::data->list[idx].legal_status_cd = ref->legal_status_cd
     SET _::data->list[idx].given_strength = ref->ref_dose
     SET _::data->list[idx].form_cd = ref->form_cd
     SET _::data->list[idx].route_cd = ref->route_cd
     SET _::data->list[idx].strength = ref->str
     SET _::data->list[idx].strength_unit_cd = ref->str_unit_cd
     SET _::data->list[idx].volume = ref->vol
     SET _::data->list[idx].volume_unit_cd = ref->vol_unit_cd
     SET _::data->list[idx].medication_ind = ref->medication
     SET _::data->list[idx].intermittent_ind = ref->intermittent
     SET _::data->list[idx].continuous_ind = ref->continuous
     SET _::data->list[idx].default_format = ref->def_format
     SET _::data->list[idx].disp_cat_cd = ref->disp_category_cd
     SET _::data->list[idx].divisible_ind = ref->divisible
     SET ident_cnt = size(ref->ident,5)
     FOR (ident_idx = 1 TO ident_cnt)
       IF ((ref_ident->ident_type_cd=11000_short_desc_cd))
        SET _::data->list[idx].mnemonic = ref_ident->value
       ENDIF
     ENDFOR
     SET stat = alterlist(_::data->list[idx].ndc,size(ref->ndc,5))
     FOR (ndc_idx = 1 TO size(_::data->list[idx].ndc,5))
       SET _::data->list[idx].ndc[ndc_idx].ndc_code = ref_ndc->ndc_code
       SET _::data->list[idx].ndc[ndc_idx].sequence = ref_ndc->sequence
       SET _::data->list[idx].ndc[ndc_idx].active_ind = ref_ndc->active_ind
       SET _::data->list[idx].ndc[ndc_idx].manf_item_id = ref_ndc->manf_item_id
       SET _::data->list[idx].ndc[ndc_idx].manufacturer_cd = ref_ndc->manufacturer_cd
       SET _::data->list[idx].ndc[ndc_idx].pkg_size = ref_ndc->pkg_size
       SET _::data->list[idx].ndc[ndc_idx].pkg_size_unit_cd = ref_ndc->pkg_unit_cd
       SET _::data->list[idx].ndc[ndc_idx].base_pkg_size_cd = ref_ndc->base_pkg_unit_cd
       SET _::data->list[idx].ndc[ndc_idx].outer_pkg_size = ref_ndc->outer_pkg_size
       SET _::data->list[idx].ndc[ndc_idx].outer_pkg_unit_cd = ref_ndc->outer_pkg_unit_cd
       SET _::data->list[idx].ndc[ndc_idx].unit_dose_ind = ref_ndc->unit_dose_ind
       SET _::data->list[idx].ndc[ndc_idx].brand_ind = ref_ndc->brand_ind
       SET _::data->list[idx].ndc[ndc_idx].updt_id = ref_ndc->mfoi_updt_id
       SET _::data->list[idx].ndc[ndc_idx].updt_dttm = ref_ndc->mfoi_updt_dttm
       SET ident_cnt = size(ref_ndc->ident,5)
       SET stat = alterlist(_::data->list[idx].ndc[ndc_idx].inner,ident_cnt)
       SET inner_cnt = 0
       FOR (ident_idx = 1 TO ident_cnt)
        SET type_cd = ref_ndc_ident->ident_type_cd
        CASE (type_cd)
         OF 11000_inner_ndc_cd:
          SET inner_cnt += 1
          SET _::data->list[idx].ndc[ndc_idx].inner[inner_cnt].inner_ndc_code = ref_ndc_ident->value
          SET _::data->list[idx].ndc[ndc_idx].inner[inner_cnt].active_ind = ref_ndc_ident->active_ind
         OF 11000_desc_cd:
          IF (ref_ndc_ident->primary_ind)
           SET _::data->list[idx].ndc[ndc_idx].description = ref_ndc_ident->value
          ENDIF
         OF 11000_brand_cd:
          IF (ref_ndc_ident->primary_ind)
           SET _::data->list[idx].ndc[ndc_idx].brand_name = ref_ndc_ident->value
          ENDIF
        ENDCASE
       ENDFOR
       SET stat = alterlist(_::data->list[idx].ndc[ndc_idx].inner,inner_cnt)
       SET cost_cnt = size(ref_ndc->cost,5)
       FOR (cost_idx = 1 TO cost_cnt)
         IF ((ref_ndc->cost[cost_idx].type_cd=4050_awp_cd))
          SET _::data->list[idx].ndc[ndc_idx].awp = ref_ndc->cost[cost_idx].value
         ENDIF
       ENDFOR
       IF (_::get_facilities)
        SET facil_str = " "
        IF (ref->all_facil_ind)
         SET facil_str = "All Facilities"
        ELSE
         SET facil_cnt = size(ref->fac,5)
         FOR (facil_idx = 1 TO facil_cnt)
           IF (facil_idx=1)
            SET facil_str = uar_get_code_display(ref->fac[facil_idx].facility_cd)
           ELSE
            SET facil_str = concat(facil_str,";",uar_get_code_display(ref->fac[facil_idx].facility_cd
              ))
           ENDIF
         ENDFOR
        ENDIF
        SET _::data->list[idx].facilities = facil_str
       ENDIF
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_legal_status FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getlegalstatus = null WITH protect, class(pha_get_generic)
   SET pha::getlegalstatus.request->code_set = 4200
   IF ( NOT (PHA::getlegalstatus.perform(0)))
    SET PRIVATE::err_msg = PHA::getlegalstatus.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getlegalstatus.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (pha::getlegalstatus.reply->qual[idx].activeind)
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getlegalstatus.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getlegalstatus.reply->qual[idx].display
     ENDIF
   ENDFOR
   SET stat = alterlist(_::data->list,cnt)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_manufacturer FROM edcw_get_data_cls
 init
 DECLARE _::get_all = i1 WITH protect, noconstant(0)
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getmanufacturer = null WITH protect, class(pha_get_generic)
   SET pha::getmanufacturer.request->code_set = 221
   SET pha::getmanufacturer.request->meaning = "MM_MANUF"
   IF ( NOT (PHA::getmanufacturer.perform(0)))
    SET PRIVATE::err_msg = PHA::getmanufacturer.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getmanufacturer.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (((pha::getmanufacturer.reply->qual[idx].activeind) OR (_::get_all)) )
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getmanufacturer.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getmanufacturer.reply->qual[idx].display
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_mltm_ndc_data FROM edcw_get_data_cls
 init
 RECORD _::request(
   1 list[*]
     2 ndc_code = vc
   1 qry_brand_name = i2
   1 qry_manufacturer = i2
   1 qry_cost = i2
   1 qry_orange_book = i2
   1 qry_strength = i2
   1 qry_route = i2
   1 qry_form = i2
   1 qry_uom = i2
   1 qry_legal_status = i2
   1 qry_nomenclature = i2
 )
 RECORD _::ndc_map(
   1 list[*]
     2 outer_code = vc
     2 inner_code = vc
     2 inner_code_format = vc
 )
 RECORD _::data(
   1 list[*]
     2 ndc_code = vc
     2 ndc_code_format = vc
     2 inner_ndc_code = vc
     2 inner_ndc_code_format = vc
     2 generic_name = vc
     2 generic_name_key = vc
     2 generic_name_cki = vc
     2 drug_synonym_id = f8
     2 rx_mnemonic_synonym = vc
     2 synonym_cki = vc
     2 brand_name_cki = vc
     2 generic_formulation_code = i4
     2 gfc_cki = vc
     2 gfc_nomen_id = f8
     2 gcr_cki = vc
     2 gcr_nomen_id = f8
     2 mmdc_cki = vc
     2 mmdc_string = vc
     2 dnum = vc
     2 brand_code = i4
     2 brand_name = vc
     2 source_id = f8
     2 manufacturer = vc
     2 divide_by_outer = f8
     2 divide_by_inner = f8
     2 awp_current_price = f8
     2 awp_current_unit_price = f8
     2 ful_current_price = f8
     2 ful_current_unit_price = f8
     2 orange_book_id = f8
     2 orange_book_code = vc
     2 strength_code = i4
     2 strength = vc
     2 route_code = i4
     2 route = vc
     2 route_cd = f8
     2 form_code = i4
     2 form = vc
     2 form_cd = f8
     2 outer_package_size = f8
     2 inner_package_size = f8
     2 uom_id = f8
     2 unit_of_measure = vc
     2 uom_cd = f8
     2 dea_class_code = vc
     2 legal_status_cd = f8
     2 otc_status = vc
     2 brand_ind = i2
     2 unit_dose_ind = i2
     2 deactivate_indicator = vc
     2 obsolete_dt_tm = dq8
     2 j_code = vc
     2 tclass[*]
       3 code = f8
       3 string = vc
 )
 DECLARE PRIVATE::mltm_table = i2 WITH protect, noconstant(0)
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   SET PRIVATE::mltm_table = PRIVATE::qry_mltm_tables(0)
   CALL PRIVATE::qry_inner_ndc(PRIVATE::mltm_table)
   CALL PRIVATE::qry_mltm_ndcs(PRIVATE::mltm_table)
   IF (_::request->qry_brand_name)
    CALL PRIVATE::qry_brand_name(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_manufacturer)
    CALL PRIVATE::qry_manufacturer(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_cost)
    CALL PRIVATE::qry_cost(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_orange_book)
    CALL PRIVATE::qry_orange_book(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_strength)
    CALL PRIVATE::qry_strength(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_route)
    CALL PRIVATE::qry_route(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_form)
    CALL PRIVATE::qry_form(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_uom)
    CALL PRIVATE::qry_uom(PRIVATE::mltm_table)
   ENDIF
   IF (_::request->qry_legal_status)
    CALL PRIVATE::qry_legal_status(0)
   ENDIF
   IF (_::request->qry_nomenclature)
    CALL PRIVATE::qry_nomenclature(PRIVATE::mltm_table)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE PRIVATE::qry_mltm_tables(null) = i2
 SUBROUTINE PRIVATE::qry_mltm_tables(null)
   DECLARE tbl_ind = i2 WITH protect, noconstant(0)
   DECLARE ndc_tbl_exists = i2 WITH protect, noconstant(0)
   DECLARE mltm_tbl_exists = i2 WITH protect, noconstant(0)
   SET ndc_tbl_exists = checkdic("NDC_CORE_DESCRIPTION","T",0)
   SET mltm_tbl_exists = checkdic("MLTM_NDC_CORE_DESCRIPTION","T",0)
   IF (ndc_tbl_exists)
    SET tbl_ind = 1
   ENDIF
   IF (mltm_tbl_exists)
    SET tbl_ind = 2
   ENDIF
   RETURN(tbl_ind)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_inner_ndc(mltm_tbl=i2) =i2)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.ndc_outer_inner_map oim),
      (v500_ref.ndc_inner_core_desc icd)
    ELSEIF (mltm_tbl=1)
     FROM (v500.ndc_outer_inner_map oim),
      (v500.ndc_inner_core_desc icd)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_ndc_outer_inner_map oim),
      (v500.mltm_ndc_inner_core_desc icd)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (icd
     WHERE expand(idx,1,size(_::request->list,5),icd.inner_ndc_code,_::request->list[idx].ndc_code))
     JOIN (oim
     WHERE icd.inner_ndc_code=oim.inner_ndc_code)
    ORDER BY oim.outer_ndc_code
    HEAD REPORT
     cnt = 0
    HEAD oim.outer_ndc_code
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(_::ndc_map->list,(cnt+ 9999))
     ENDIF
     _::ndc_map->list[cnt].outer_code = oim.outer_ndc_code, _::ndc_map->list[cnt].inner_code = icd
     .inner_ndc_code, _::ndc_map->list[cnt].inner_code_format = icd.ndc_formatted,
     pos = locatevalsort(idx,1,size(_::request->list,5),icd.inner_ndc_code,_::request->list[idx].
      ndc_code)
     IF (pos > 0)
      _::request->list[pos].ndc_code = oim.outer_ndc_code
     ENDIF
    FOOT REPORT
     stat = alterlist(_::ndc_map->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_mltm_ndcs(mltm_tbl=i2) =i2)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE mdm_col_parser = vc WITH protect, noconstant("mdm.drug_id")
   DECLARE mmdc_col_parser = vc WITH protect, noconstant("mmdc.drug_id")
   DECLARE mcx_col_parser = vc WITH protect, noconstant("mcx.drug_id")
   IF (mltm_tbl != 0)
    SET mdm_col_parser = "mdm.drug_identifier"
    SET mmdc_col_parser = "mmdc.drug_identifier"
    SET mcx_col_parser = "mcx.drug_identifier"
   ENDIF
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.ndc_core_description ndc),
      (v500_ref.ndc_main_multum_drug_code mmdc),
      (v500_ref.multum_mmdc_name_map mmm),
      (v500_ref.multum_drug_name mds),
      (v500_ref.multum_drug_name_map mdm),
      (v500_ref.multum_category_drug_xref mcx),
      (v500_ref.multum_drug_categories mdc)
    ELSEIF (mltm_tbl=1)
     FROM (v500.ndc_core_description ndc),
      (v500.ndc_main_multum_drug_code mmdc),
      (v500.multum_mmdc_name_map mmm),
      (v500.multum_drug_name mds),
      (v500.multum_drug_name_map mdm),
      (v500.multum_category_drug_xref mcx),
      (v500.multum_drug_categories mdc)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_ndc_core_description ndc),
      (v500.mltm_ndc_main_drug_code mmdc),
      (v500.mltm_mmdc_name_map mmm),
      (v500.mltm_drug_name mds),
      (v500.mltm_drug_name_map mdm),
      (v500.mltm_category_drug_xref mcx),
      (v500.mltm_drug_categories mdc)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (ndc
     WHERE expand(idx,1,size(_::request->list,5),ndc.ndc_code,_::request->list[idx].ndc_code))
     JOIN (mmdc
     WHERE mmdc.main_multum_drug_code=ndc.main_multum_drug_code)
     JOIN (mmm
     WHERE mmm.main_multum_drug_code=mmdc.main_multum_drug_code
      AND mmm.function_id IN (16, 59))
     JOIN (mds
     WHERE mds.drug_synonym_id=mmm.drug_synonym_id)
     JOIN (mdm
     WHERE mdm.drug_synonym_id=mds.drug_synonym_id)
     JOIN (mcx
     WHERE parser(mdm_col_parser)=parser(mcx_col_parser))
     JOIN (mdc
     WHERE mcx.multum_category_id=mdc.multum_category_id)
    ORDER BY ndc.ndc_code, mmdc.main_multum_drug_code, mmm.function_id,
     mmm.drug_synonym_id
    HEAD REPORT
     cnt = 0, stat = alterlist(_::data->list,size(_::request->list,5))
    HEAD ndc.ndc_code
     cnt += 1, _::data->list[cnt].ndc_code = ndc.ndc_code, _::data->list[cnt].ndc_code_format = ndc
     .ndc_formatted,
     _::data->list[cnt].unit_dose_ind = evaluate(ndc.unit_dose_code,"U",1,0), _::data->list[cnt].
     otc_status = ndc.otc_status, _::data->list[cnt].outer_package_size = ndc.outer_package_size,
     _::data->list[cnt].inner_package_size = ndc.inner_package_size, _::data->list[cnt].
     obsolete_dt_tm = ndc.obsolete_date, _::data->list[cnt].brand_ind = evaluate(ndc.gbo,"N",1,0),
     _::data->list[cnt].brand_code = ndc.brand_code, _::data->list[cnt].source_id = ndc.source_id,
     _::data->list[cnt].orange_book_id = ndc.orange_book_id,
     _::data->list[cnt].uom_id = cnvtreal(ndc.inner_package_desc_code), pos = locatevalsort(idx,1,
      size(_::ndc_map->list,5),ndc.ndc_code,_::ndc_map->list[idx].outer_code)
     IF (pos > 0)
      _::data->list[cnt].inner_ndc_code = _::ndc_map->list[pos].inner_code, _::data->list[cnt].
      inner_ndc_code_format = _::ndc_map->list[pos].inner_code_format
     ENDIF
     IF (ndc.outer_package_size > 0)
      _::data->list[cnt].divide_by_outer = ndc.outer_package_size
     ELSE
      _::data->list[cnt].divide_by_outer = 1
     ENDIF
     IF (ndc.inner_package_size > 0)
      _::data->list[cnt].divide_by_inner = ndc.inner_package_size
     ELSE
      _::data->list[cnt].divide_by_inner = 1
     ENDIF
    HEAD mmdc.main_multum_drug_code
     _::data->list[cnt].generic_formulation_code = mmdc.main_multum_drug_code, _::data->list[cnt].
     gcr_cki = concat("MUL.ORD!",trim(parser(mmdc_col_parser))), _::data->list[cnt].gfc_cki = concat(
      "MUL.FRMLTN!",trim(cnvtstring(mmdc.main_multum_drug_code))),
     _::data->list[cnt].mmdc_cki = concat("MUL.MMDC!",trim(cnvtstring(mmdc.main_multum_drug_code))),
     _::data->list[cnt].form_code = mmdc.dose_form_code, _::data->list[cnt].route_code = mmdc
     .principal_route_code,
     _::data->list[cnt].strength_code = mmdc.product_strength_code, _::data->list[cnt].mmdc_string =
     cnvtstring(mmdc.main_multum_drug_code), _::data->list[cnt].dnum = parser(mmdc_col_parser),
     _::data->list[cnt].j_code = mmdc.j_code
     IF (mmdc.csa_schedule="0"
      AND ndc.otc_status="T")
      _::data->list[cnt].dea_class_code = "6"
     ELSE
      _::data->list[cnt].dea_class_code = mmdc.csa_schedule
     ENDIF
    HEAD mmm.drug_synonym_id
     _::data->list[cnt].deactivate_indicator = mds.is_obsolete, _::data->list[cnt].drug_synonym_id =
     mmm.drug_synonym_id
     CASE (mmm.function_id)
      OF 16:
       _::data->list[cnt].generic_name = mds.drug_name,_::data->list[cnt].generic_name_key =
       cnvtupper(trim(mds.drug_name,3)),_::data->list[cnt].generic_name_cki = concat("MUL.ORD-SYN!",
        trim(cnvtstring(mmm.drug_synonym_id)))
      OF 59:
       _::data->list[cnt].rx_mnemonic_synonym = mds.drug_name,_::data->list[cnt].synonym_cki = concat
       ("MUL.ORD-SYN!",trim(cnvtstring(mmm.drug_synonym_id)))
      OF 17:
       _::data->list[cnt].brand_name_cki = concat("MUL.ORD-SYN!",trim(cnvtstring(mmm.drug_synonym_id)
         ))
     ENDCASE
     class_cnt = 0
    DETAIL
     class_cnt += 1
     IF (mod(class_cnt,5)=1)
      stat = alterlist(_::data->list[cnt].tclass,(class_cnt+ 4))
     ENDIF
     _::data->list[cnt].tclass[class_cnt].code = mdc.multum_category_id, _::data->list[cnt].tclass[
     class_cnt].string = mdc.category_name
    FOOT  mmm.drug_synonym_id
     stat = alterlist(_::data->list[cnt].tclass,class_cnt)
    FOOT REPORT
     stat = alterlist(_::data->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_brand_name(mltm_tbl=i2) =i2)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD brand(
     1 list[*]
       2 brand_code = i4
       2 brand_name = vc
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.ndc_brand_name nbn)
    ELSEIF (mltm_tbl=1)
     FROM (v500.ndc_brand_name nbn)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_ndc_brand_name nbn)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (nbn
     WHERE expand(idx,1,size(_::data->list,5),nbn.brand_code,_::data->list[idx].brand_code))
    ORDER BY nbn.brand_code
    HEAD REPORT
     cnt = 0
    HEAD nbn.brand_code
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(brand->list,(cnt+ 9999))
     ENDIF
     brand->list[cnt].brand_code = nbn.brand_code, brand->list[cnt].brand_name = nbn
     .brand_description
    FOOT REPORT
     stat = alterlist(brand->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(brand->list,5),_::data->list[cnt].brand_code,brand->list[idx].
     brand_code)
    IF (pos > 0)
     SET _::data->list[cnt].brand_name = brand->list[pos].brand_name
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_manufacturer(mltm_tbl=i2) =i2)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD manuf(
     1 list[*]
       2 source_id = f8
       2 source_desc = vc
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.ndc_source ns)
    ELSEIF (mltm_tbl=1)
     FROM (v500.ndc_source ns)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_ndc_source ns)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (ns
     WHERE expand(idx,1,size(_::data->list,5),ns.source_id,_::data->list[idx].source_id))
    ORDER BY ns.source_id
    HEAD REPORT
     cnt = 0
    HEAD ns.source_id
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(manuf->list,(cnt+ 9999))
     ENDIF
     manuf->list[cnt].source_id = ns.source_id, manuf->list[cnt].source_desc = ns.source_desc
    FOOT REPORT
     stat = alterlist(manuf->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(manuf->list,5),_::data->list[cnt].source_id,manuf->list[idx].
     source_id)
    IF (pos > 0)
     SET _::data->list[cnt].manufacturer = manuf->list[pos].source_desc
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_cost(mltm_tbl=i2) =i2)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD cost(
     1 list[*]
       2 ndc_code = vc
       2 awp_price = f8
       2 ful_price = f8
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.ndc_cost nc)
    ELSEIF (mltm_tbl=1)
     FROM (v500.ndc_cost nc)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_ndc_cost nc)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (nc
     WHERE expand(idx,1,size(_::data->list,5),nc.ndc_code,_::data->list[idx].ndc_code)
      AND nc.cost > 0)
    ORDER BY nc.ndc_code
    HEAD REPORT
     cnt = 0
    HEAD nc.ndc_code
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(cost->list,(cnt+ 9999))
     ENDIF
     cost->list[cnt].ndc_code = nc.ndc_code
     IF (nc.inventory_type="A")
      cost->list[cnt].awp_price = nc.cost
     ELSEIF (nc.inventory_type="F")
      cost->list[cnt].awp_price = nc.cost
     ENDIF
    FOOT REPORT
     stat = alterlist(cost->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(cost->list,5),_::data->list[cnt].ndc_code,cost->list[idx].
     ndc_code)
    IF (pos > 0)
     SET divide_by_inner = _::data->list[cnt].divide_by_inner
     SET divide_by_outer = _::data->list[cnt].divide_by_outer
     SET _::data->list[cnt].awp_current_price = cost->list[pos].awp_price
     SET _::data->list[cnt].awp_current_unit_price = ((cost->list[pos].awp_price/ divide_by_inner)/
     divide_by_outer)
     SET _::data->list[cnt].ful_current_price = cost->list[pos].ful_price
     SET _::data->list[cnt].ful_current_unit_price = ((cost->list[pos].ful_price/ divide_by_inner)/
     divide_by_outer)
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_orange_book(mltm_tbl=i2) =i2)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD orange(
     1 list[*]
       2 orange_book_id = f8
       2 orange_book_code = vc
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.ndc_orange_book nob)
    ELSEIF (mltm_tbl=1)
     FROM (v500.ndc_orange_book nob)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_ndc_orange_book nob)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (nob
     WHERE expand(idx,1,size(_::data->list,5),nob.orange_book_id,_::data->list[idx].orange_book_id))
    ORDER BY nob.orange_book_id
    HEAD REPORT
     cnt = 0
    HEAD nob.orange_book_id
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(orange->list,(cnt+ 9999))
     ENDIF
     orange->list[cnt].orange_book_id = nob.orange_book_id, orange->list[cnt].orange_book_code = nob
     .orange_book_desc_ab
    FOOT REPORT
     stat = alterlist(orange->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(orange->list,5),_::data->list[cnt].orange_book_id,orange->
     list[idx].orange_book_id)
    IF (pos > 0)
     SET _::data->list[cnt].orange_book_code = orange->list[pos].orange_book_code
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_strength(mltm_tbl=i2) =i2)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD strength(
     1 list[*]
       2 strength_code = i4
       2 strength = vc
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.multum_product_strength mps)
    ELSEIF (mltm_tbl=1)
     FROM (v500.multum_product_strength mps)
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_product_strength mps)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (mps
     WHERE expand(idx,1,size(_::data->list,5),mps.product_strength_code,_::data->list[idx].
      strength_code))
    ORDER BY mps.product_strength_code
    HEAD REPORT
     cnt = 0
    HEAD mps.product_strength_code
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(strength->list,(cnt+ 9999))
     ENDIF
     strength->list[cnt].strength_code = mps.product_strength_code, strength->list[cnt].strength =
     mps.product_strength_description
    FOOT REPORT
     stat = alterlist(strength->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(strength->list,5),_::data->list[cnt].strength_code,strength->
     list[idx].strength_code)
    IF (pos > 0)
     SET _::data->list[cnt].strength = strength->list[pos].strength
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_route(mltm_tbl=i2) =i2)
   DECLARE 73_multum_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!36701"))
   DECLARE route_cs = i4 WITH protect, constant(4001)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD route(
     1 list[*]
       2 route_code = i4
       2 route = vc
       2 route_cd = f8
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.multum_product_route mpr),
      code_value_alias cva,
      code_value cv
    ELSEIF (mltm_tbl=1)
     FROM (v500.multum_product_route mpr),
      code_value_alias cva,
      code_value cv
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_product_route mpr),
      code_value_alias cva,
      code_value cv
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (mpr
     WHERE expand(idx,1,size(_::data->list,5),mpr.route_code,_::data->list[idx].route_code))
     JOIN (cva
     WHERE cva.alias=trim(mpr.route_abbr,3)
      AND cva.contributor_source_cd=73_multum_cd)
     JOIN (cv
     WHERE cv.code_value=cva.code_value
      AND cv.code_set=cva.code_set
      AND cv.code_set=route_cs
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    ORDER BY mpr.route_code
    HEAD REPORT
     cnt = 0
    HEAD mpr.route_code
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(route->list,(cnt+ 9999))
     ENDIF
     route->list[cnt].route_code = mpr.route_code, route->list[cnt].route = mpr.route_abbr, route->
     list[cnt].route_cd = cv.code_value
    FOOT REPORT
     stat = alterlist(route->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(route->list,5),_::data->list[cnt].route_code,route->list[idx].
     route_code)
    IF (pos > 0)
     SET _::data->list[cnt].route = route->list[pos].route
     SET _::data->list[cnt].route_cd = route->list[pos].route_cd
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_form(mltm_tbl=i2) =i2)
   DECLARE 73_multum_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!36701"))
   DECLARE form_cs = i4 WITH protect, constant(4002)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD form(
     1 list[*]
       2 form_code = i4
       2 form = vc
       2 form_cd = f8
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.multum_dose_form mdf),
      code_value_alias cva,
      code_value cv
    ELSEIF (mltm_tbl=1)
     FROM (v500.multum_dose_form mdf),
      code_value_alias cva,
      code_value cv
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_dose_form mdf),
      code_value_alias cva,
      code_value cv
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (mdf
     WHERE expand(idx,1,size(_::data->list,5),mdf.dose_form_code,_::data->list[idx].form_code))
     JOIN (cva
     WHERE cva.alias=trim(mdf.dose_form_abbr,3)
      AND cva.contributor_source_cd=73_multum_cd)
     JOIN (cv
     WHERE cv.code_value=cva.code_value
      AND cv.code_set=cva.code_set
      AND cv.code_set=form_cs
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY mdf.dose_form_code
    HEAD REPORT
     cnt = 0
    HEAD mdf.dose_form_code
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(form->list,(cnt+ 9999))
     ENDIF
     form->list[cnt].form_code = mdf.dose_form_code, form->list[cnt].form = mdf.dose_form_abbr, form
     ->list[cnt].form_cd = cv.code_value
    FOOT REPORT
     stat = alterlist(form->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(form->list,5),_::data->list[cnt].form_code,form->list[idx].
     form_code)
    IF (pos > 0)
     SET _::data->list[cnt].form = form->list[pos].form
     SET _::data->list[cnt].form_cd = form->list[pos].form_cd
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_uom(mltm_tbl=i2) =i2)
   DECLARE 54_ea_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2724"))
   DECLARE 54_ml_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3780"))
   DECLARE 54_gm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6123"))
   DECLARE 73_multum_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!36701"))
   DECLARE uom_cs = i4 WITH protect, constant(54)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD uom(
     1 list[*]
       2 uom_id = f8
       2 unit_of_measure = vc
       2 uom_cd = f8
   )
   SELECT
    IF (mltm_tbl=0)
     FROM (v500_ref.multum_units mu),
      code_value_alias cva,
      code_value cv
    ELSEIF (mltm_tbl=1)
     FROM (v500.multum_units mu),
      code_value_alias cva,
      code_value cv
    ELSEIF (mltm_tbl=2)
     FROM (v500.mltm_units mu),
      code_value_alias cva,
      code_value cv
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (mu
     WHERE expand(idx,1,size(_::data->list,5),mu.unit_id,_::data->list[idx].uom_id))
     JOIN (cva
     WHERE cva.alias=trim(cnvtstring(mu.unit_id),3)
      AND cva.contributor_source_cd=73_multum_cd)
     JOIN (cv
     WHERE cv.code_value=cva.code_value
      AND cv.code_set=cva.code_set
      AND cv.code_set=uom_cs
      AND cv.code_value IN (54_ea_cd, 54_gm_cd, 54_ml_cd)
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY mu.unit_id
    HEAD REPORT
     cnt = 0
    HEAD mu.unit_id
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(uom->list,(cnt+ 9999))
     ENDIF
     uom->list[cnt].uom_id = mu.unit_id, uom->list[cnt].unit_of_measure = mu.unit_abbr, uom->list[cnt
     ].uom_cd = cv.code_value
    FOOT REPORT
     stat = alterlist(uom->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(uom->list,5),_::data->list[cnt].uom_id,uom->list[idx].uom_id)
    IF (pos > 0)
     SET _::data->list[cnt].unit_of_measure = uom->list[pos].unit_of_measure
     SET _::data->list[cnt].uom_cd = uom->list[pos].uom_cd
    ELSE
     SET _::data->list[cnt].unit_of_measure = "EA"
     SET _::data->list[cnt].uom_cd = 54_ea_cd
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 DECLARE PRIVATE::qry_legal_status(null) = i2
 SUBROUTINE PRIVATE::qry_legal_status(null)
   DECLARE 73_multum_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!36701"))
   DECLARE legal_status_cs = i4 WITH protect, constant(4200)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD legal_status(
     1 list[*]
       2 dea_class_code = vc
       2 code_value = f8
   )
   SELECT INTO "nl:"
    FROM code_value_alias cva,
     code_value cv
    PLAN (cva
     WHERE expand(idx,1,size(_::data->list,5),cva.alias,_::data->list[idx].dea_class_code)
      AND cva.contributor_source_cd=73_multum_cd)
     JOIN (cv
     WHERE cv.code_value=cva.code_value
      AND cv.code_set=cva.code_set
      AND cv.code_set=legal_status_cs
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
      AND cv.end_effective_dt_tm > cnvtdatetime(sysdate))
    ORDER BY cva.alias
    HEAD REPORT
     cnt = 0
    HEAD cva.alias
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(legal_status->list,(cnt+ 9999))
     ENDIF
     legal_status->list[cnt].dea_class_code = cva.alias, legal_status->list[cnt].code_value = cv
     .code_value
    FOOT REPORT
     stat = alterlist(legal_status->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(legal_status->list,5),_::data->list[cnt].dea_class_code,
     legal_status->list[idx].dea_class_code)
    IF (pos > 0)
     SET _::data->list[cnt].legal_status_cd = legal_status->list[pos].code_value
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (PRIVATE::qry_nomenclature(mltm_tbl=i2) =i2)
   DECLARE 400_muldrug_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!22970"))
   DECLARE 400_mulmmdc_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!43584"))
   DECLARE 401_genform_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2972"))
   DECLARE 401_genname_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2973"))
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   RECORD nomen(
     1 list[*]
       2 mmdc_string = vc
       2 generic_name = vc
       2 dnum = vc
       2 drug_synonym_id = f8
       2 nomenclature_id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE expand(idx,1,size(_::data->list,5),n.source_identifier,_::data->list[idx].mmdc_string)
     AND n.source_vocabulary_cd=400_mulmmdc_cd
     AND n.principle_type_cd=401_genform_cd
     AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
    ORDER BY n.source_identifier, nomenclature_id
    HEAD REPORT
     cnt = 0
    HEAD n.source_identifier
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(nomen->list,(cnt+ 9999))
     ENDIF
     nomen->list[cnt].mmdc_string = n.source_identifier, nomen->list[cnt].nomenclature_id = n
     .nomenclature_id
    FOOT REPORT
     stat = alterlist(nomen->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(nomen->list,5),_::data->list[cnt].mmdc_string,nomen->list[idx]
     .mmdc_string)
    IF (pos > 0)
     SET _::data->list[cnt].gfc_nomen_id = nomen->list[pos].nomenclature_id
    ENDIF
   ENDFOR
   SET stat = initrec(nomen)
   SELECT INTO "nl:"
    FROM mltm_dmd_name_map dmd,
     nomenclature n
    PLAN (dmd
     WHERE expand(idx,1,size(_::data->list,5),dmd.drug_synonym_id,_::data->list[idx].drug_synonym_id)
      AND dmd.drug_synonym_id > 0)
     JOIN (n
     WHERE n.source_string_keycap=cnvtupper(trim(dmd.dmd_name,3))
      AND n.source_vocabulary_cd=400_muldrug_cd
      AND n.principle_type_cd=401_genname_cd
      AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND n.primary_vterm_ind=1)
    ORDER BY dmd.drug_synonym_id
    HEAD REPORT
     cnt = 0
    HEAD dmd.drug_synonym_id
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(nomen->list,(cnt+ 9999))
     ENDIF
     nomen->list[cnt].drug_synonym_id = dmd.drug_synonym_id, nomen->list[cnt].nomenclature_id = n
     .nomenclature_id
    FOOT REPORT
     stat = alterlist(nomen->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
    SET pos = locatevalsort(idx,1,size(nomen->list,5),_::data->list[cnt].drug_synonym_id,nomen->list[
     idx].drug_synonym_id)
    IF (pos > 0)
     SET _::data->list[cnt].gcr_nomen_id = nomen->list[pos].nomenclature_id
    ENDIF
   ENDFOR
   SET stat = initrec(nomen)
   SELECT
    IF (mltm_tbl=0)
     FROM nomenclature n,
      (v500_ref.multum_concept_name_map mc)
    ELSEIF (mltm_tbl=1)
     FROM nomenclature n,
      (v500.multum_concept_name_map mc)
    ELSEIF (mltm_tbl=2)
     FROM nomenclature n,
      (v500.mltm_concept_name_map mc)
    ELSE
    ENDIF
    INTO "nl:"
    PLAN (mc
     WHERE expand(idx,1,size(_::data->list,5),mc.drug_synonym_id,_::data->list[idx].drug_synonym_id)
      AND mc.drug_synonym_id > 0
      AND mc.concept_cki > " "
      AND mc.source_disp > " ")
     JOIN (n
     WHERE n.source_string_keycap=cnvtupper(trim(mc.concept_drug_name,3))
      AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND n.primary_vterm_ind=1
      AND mc.concept_cki=n.concept_cki
      AND n.source_vocabulary_cd=400_muldrug_cd
      AND n.principle_type_cd=401_genname_cd)
    ORDER BY mc.drug_synonym_id
    HEAD REPORT
     cnt = 0
    HEAD mc.drug_synonym_id
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(nomen->list,(cnt+ 9999))
     ENDIF
     nomen->list[cnt].drug_synonym_id = mc.drug_synonym_id, nomen->list[cnt].nomenclature_id = n
     .nomenclature_id
    FOOT REPORT
     stat = alterlist(nomen->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
     IF ((_::data->list[cnt].gcr_nomen_id=0))
      SET pos = locatevalsort(idx,1,size(nomen->list,5),_::data->list[cnt].drug_synonym_id,nomen->
       list[idx].drug_synonym_id)
      IF (pos > 0)
       SET _::data->list[cnt].gcr_nomen_id = nomen->list[pos].nomenclature_id
      ENDIF
     ENDIF
   ENDFOR
   SET stat = initrec(nomen)
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE expand(idx,1,size(_::data->list,5),n.source_string_keycap,_::data->list[idx].
     generic_name_key,
     n.concept_identifier,_::data->list[idx].dnum)
     AND n.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND n.source_vocabulary_cd=400_muldrug_cd
     AND n.principle_type_cd=401_genname_cd
    ORDER BY n.source_string_keycap, n.concept_identifier
    HEAD REPORT
     cnt = 0
    HEAD n.source_string_keycap
     null
    HEAD n.concept_identifier
     cnt += 1
     IF (mod(cnt,10000)=1)
      stat = alterlist(nomen->list,(cnt+ 9999))
     ENDIF
     nomen->list[cnt].generic_name = n.source_string_keycap, nomen->list[cnt].dnum = n
     .concept_identifier, nomen->list[cnt].nomenclature_id = n.nomenclature_id
    FOOT REPORT
     stat = alterlist(nomen->list,cnt)
    WITH nocounter, expand = 2
   ;end select
   FOR (cnt = 1 TO size(_::data->list,5))
     IF ((_::data->list[cnt].gcr_nomen_id=0))
      SET pos = locatevalsort(idx,1,size(nomen->list,5),_::data->list[cnt].generic_name_key,nomen->
       list[idx].generic_name,
       _::data->list[cnt].dnum,nomen->list[idx].dnum)
      IF (pos > 0)
       SET _::data->list[cnt].gcr_nomen_id = nomen->list[pos].nomenclature_id
      ENDIF
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_orderables FROM edcw_get_data_cls
 init
 RECORD _::data(
   1 list[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 description = vc
     2 oe_format_id = f8
     2 cki = vc
     2 consent_form_ind = i2
     2 active_ind = i2
     2 requisition_format_cd = f8
     2 requisition_routing_cd = f8
     2 inst_restriction_ind = i2
     2 schedule_ind = i2
     2 print_req_ind = i2
     2 orderable_type_flag = i2
     2 complete_upon_order_ind = i2
     2 quick_chart_ind = i2
     2 comment_template_flag = i2
     2 prep_info_flag = i2
     2 dc_display_days = i4
     2 dc_interaction_days = i4
     2 op_dc_display_days = i4
     2 op_dc_interaction_days = i4
     2 updt_cnt = i4
 )
 DECLARE _::get_details = i2 WITH protect, noconstant(0)
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE 6000_pharm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3079"))
   DECLARE std0_ordtype = i4 WITH protect, constant(0)
   DECLARE std1_ordtype = i4 WITH protect, constant(1)
   DECLARE freetxt_ordtype = i4 WITH protect, constant(10)
   DECLARE cmpd_ordtype = i4 WITH protect, constant(13)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    primary_mnemonic = cnvtupper(oc.primary_mnemonic)
    FROM order_catalog oc
    WHERE oc.catalog_type_cd=6000_pharm_cd
     AND oc.active_ind=1
     AND oc.orderable_type_flag IN (std0_ordtype, std1_ordtype, freetxt_ordtype, cmpd_ordtype)
    ORDER BY primary_mnemonic
    HEAD REPORT
     cnt = 0
    HEAD primary_mnemonic
     cnt += 1
     IF (mod(cnt,5000)=1)
      stat = alterlist(_::data->list,(cnt+ 4999))
     ENDIF
     _::data->list[cnt].catalog_cd = oc.catalog_cd, _::data->list[cnt].primary_mnemonic = oc
     .primary_mnemonic, _::data->list[cnt].description = oc.description
     IF (_::get_details)
      _::data->list[cnt].oe_format_id = oc.oe_format_id, _::data->list[cnt].cki = oc.cki, _::data->
      list[cnt].consent_form_ind = oc.consent_form_format_cd,
      _::data->list[cnt].active_ind = oc.active_ind, _::data->list[cnt].requisition_format_cd = oc
      .requisition_format_cd, _::data->list[cnt].requisition_routing_cd = oc.requisition_routing_cd,
      _::data->list[cnt].inst_restriction_ind = oc.inst_restriction_ind, _::data->list[cnt].
      schedule_ind = oc.schedule_ind, _::data->list[cnt].print_req_ind = oc.print_req_ind,
      _::data->list[cnt].orderable_type_flag = oc.orderable_type_flag, _::data->list[cnt].
      complete_upon_order_ind = oc.complete_upon_order_ind, _::data->list[cnt].quick_chart_ind = oc
      .quick_chart_ind,
      _::data->list[cnt].comment_template_flag = oc.comment_template_flag, _::data->list[cnt].
      prep_info_flag = oc.prep_info_flag, _::data->list[cnt].dc_display_days = oc.dc_display_days,
      _::data->list[cnt].dc_interaction_days = oc.dc_interaction_days, _::data->list[cnt].
      op_dc_display_days = oc.op_dc_display_days, _::data->list[cnt].op_dc_interaction_days = oc
      .op_dc_interaction_days,
      _::data->list[cnt].updt_cnt = oc.updt_cnt
     ENDIF
    FOOT REPORT
     stat = alterlist(_::data->list,cnt)
    WITH nocounter
   ;end select
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_org_security_facilities FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE GET::prsnlorgs = null WITH protect, class(him_get_prsnl_orgs)
   SET get::prsnlorgs.request->userid = curuser
   SET get::prsnlorgs.request->prsnl_id = reqinfo->updt_id
   IF ( NOT (GET::prsnlorgs.perform(0)))
    SET PRIVATE::err_msg = GET::prsnlorgs.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE GET::facilbyorgs = null WITH protect, class(rx_get_facilities_by_org)
   DECLARE list_size = i4 WITH protect, noconstant(0)
   SET get::facilbyorgs.request->inc_outpt_fac_ind = 1
   SET list_size = size(get::prsnlorgs.reply->qual,5)
   SET stat = alterlist(get::facilbyorgs.request->organization_list,list_size)
   FOR (idx = 1 TO list_size)
     SET get::facilbyorgs.request->organization_list[idx].organization_id = get::prsnlorgs.reply->
     qual[idx].organization_id
   ENDFOR
   IF ( NOT (GET::facilbyorgs.perform(0)))
    SET PRIVATE::err_msg = GET::prsnlorgs.geterror(0)
    RETURN(0)
   ENDIF
   SET stat = alterlist(_::data->list,size(get::facilbyorgs.reply->facility_list,5))
   FOR (idx = 1 TO size(_::data->list,5))
    SET _::data->list[idx].id = get::facilbyorgs.reply->facility_list[idx].facility_cd
    SET _::data->list[idx].display = get::facilbyorgs.reply->facility_list[idx].display
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_pharmacy_type FROM edcw_get_data_cls
 init
 DECLARE _::get_all = i1 WITH protect, noconstant(0)
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getpharmacytype = null WITH protect, class(pha_get_generic)
   SET pha::getpharmacytype.request->code_set = 4500
   IF ( NOT (PHA::getpharmacytype.perform(0)))
    SET PRIVATE::err_msg = PHA::getpharmacytype.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getpharmacytype.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (((pha::getpharmacytype.reply->qual[idx].activeind) OR (_::get_all)) )
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getpharmacytype.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getpharmacytype.reply->qual[idx].display
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_quantity_units FROM edcw_get_data_cls
 init
 DECLARE _::get_all = i2 WITH noconstant(0)
 DECLARE _::base_units = i2 WITH noconstant(0)
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getquantityunits = null WITH protect, class(pha_get_pharmunit)
   SET pha::getquantityunits.request->pharm_ind = 1
   IF ( NOT (PHA::getquantityunits.perform(0)))
    SET PRIVATE::err_msg = PHA::getquantityunits.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE quantity = i4 WITH protect, constant(2)
   DECLARE 54_gm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!6123"))
   DECLARE 54_ea_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2724"))
   DECLARE 54_ml_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3780"))
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getquantityunits.reply->qual,5))
   IF (_::get_all)
    FOR (idx = 1 TO size(_::data->list,5))
     SET _::data->list[idx].id = pha::getquantityunits.reply->qual[idx].code_value
     SET _::data->list[idx].display = pha::getquantityunits.reply->qual[idx].display
    ENDFOR
   ELSEIF (_::base_units)
    FOR (idx = 1 TO size(_::data->list,5))
      IF (btest(pha::getquantityunits.reply->qual[idx].pharm_unit,quantity)=1
       AND pha::getquantityunits.reply->qual[idx].activeind
       AND (pha::getquantityunits.reply->qual[idx].code_value IN (54_gm_cd, 54_ea_cd, 54_ml_cd)))
       SET cnt += 1
       SET _::data->list[cnt].id = pha::getquantityunits.reply->qual[idx].code_value
       SET _::data->list[cnt].display = pha::getquantityunits.reply->qual[idx].display
      ENDIF
    ENDFOR
    SET stat = alterlist(_::data->list,cnt)
   ELSE
    FOR (idx = 1 TO size(_::data->list,5))
      IF (btest(pha::getquantityunits.reply->qual[idx].pharm_unit,quantity)=1
       AND pha::getquantityunits.reply->qual[idx].activeind)
       SET cnt += 1
       SET _::data->list[cnt].id = pha::getquantityunits.reply->qual[idx].code_value
       SET _::data->list[cnt].display = pha::getquantityunits.reply->qual[idx].display
      ENDIF
    ENDFOR
    SET stat = alterlist(_::data->list,cnt)
   ENDIF
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_route FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getroute = null WITH protect, class(pha_get_generic)
   SET pha::getroute.request->code_set = 4001
   IF ( NOT (PHA::getroute.perform(0)))
    SET PRIVATE::err_msg = PHA::getroute.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getroute.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (pha::getroute.reply->qual[idx].activeind)
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getroute.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getroute.reply->qual[idx].display
     ENDIF
   ENDFOR
   SET stat = alterlist(_::data->list,cnt)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_strength_units FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getstrengthunits = null WITH protect, class(pha_get_pharmunit)
   SET pha::getstrengthunits.request->pharm_ind = 1
   IF ( NOT (PHA::getstrengthunits.perform(0)))
    SET PRIVATE::err_msg = PHA::getstrengthunits.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE strength = i4 WITH protect, constant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getstrengthunits.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (btest(pha::getstrengthunits.reply->qual[idx].pharm_unit,strength)=1
      AND pha::getstrengthunits.reply->qual[idx].activeind)
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getstrengthunits.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getstrengthunits.reply->qual[idx].display
     ENDIF
   ENDFOR
   SET stat = alterlist(_::data->list,cnt)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS get_volume_units FROM edcw_get_data_cls
 init
 DECLARE _::get(null) = i2
 SUBROUTINE _::get(null)
   DECLARE PHA::getvolumeunits = null WITH protect, class(pha_get_pharmunit)
   SET pha::getvolumeunits.request->pharm_ind = 1
   IF ( NOT (PHA::getvolumeunits.perform(0)))
    SET PRIVATE::err_msg = PHA::getvolumeunits.geterror(0)
    RETURN(0)
   ENDIF
   DECLARE volume = i4 WITH protect, constant(1)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET stat = alterlist(_::data->list,size(pha::getvolumeunits.reply->qual,5))
   FOR (idx = 1 TO size(_::data->list,5))
     IF (btest(pha::getvolumeunits.reply->qual[idx].pharm_unit,volume)=1
      AND pha::getvolumeunits.reply->qual[idx].activeind)
      SET cnt += 1
      SET _::data->list[cnt].id = pha::getvolumeunits.reply->qual[idx].code_value
      SET _::data->list[cnt].display = pha::getvolumeunits.reply->qual[idx].display
     ENDIF
   ENDFOR
   SET stat = alterlist(_::data->list,cnt)
   RETURN(1)
 END ;Subroutine
 END; class scope:init
 WITH copy = 1
 CREATE CLASS pha_bld_manuf FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 manuf_name = c35
 )
 RECORD _::reply(
   1 manufacturer_cd = f8
   1 new_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("pha_bld_manuf"))
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(true)
 END; class scope:init
 WITH copy = 1
END GO
