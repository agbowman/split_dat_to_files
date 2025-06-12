CREATE PROGRAM ccl_dlg_ds_utility:dba
 PROMPT
  "function " = "OnError",
  "Parameter List " = " ",
  "Opt List       " = " ",
  "Opt Sub List   " = " ",
  "Opt param      " = " "
  WITH funct, paramlist, optlist,
  optsublist, optparam
 EXECUTE ccl_prompt_api_dataset "autoset"
 DECLARE getordcatalog(strprimary=vc) = i2
 DECLARE getencorderlist(nencid=f8) = i2
 DECLARE getenclist(npersonid=f8) = i2
 DECLARE getpersonlist(strmatchlastname=vc) = i2
 DECLARE geteventset(fencid=f8) = i2
 DECLARE getaddress(fprsnid=f8) = i2
 SET stat = setvalidation(0)
 SET stat = setstatus("S")
 CASE (cnvtlower( $FUNCT))
  OF "getpersonlist":
   SET stat = setvalidation(getpersonlist( $PARAMLIST))
  OF "getenclist":
   SET stat = setvalidation(getenclist(cnvtreal( $PARAMLIST)))
  OF "getencorderlist":
   SET stat = setvalidation(getencorderlist(cnvtreal( $PARAMLIST)))
  OF "getordcatalog":
   SET stat = setvalidation(getordcatalog( $PARAMLIST))
  OF "geteventset":
   SET stat = setvalidation(geteventset(cnvtreal( $PARAMLIST)))
  OF "getaddress":
   SET stat = setvalidation(getaddress(cnvtreal( $PARAMLIST)))
  ELSE
   SET stat = setstatus("F")
   SET stat = setmessageboxex(concat("'", $FUNCT,"'"),"CCL_DLG_DS_UTILITY:unrecognized function",
    _mb_error_)
 ENDCASE
 RETURN
 SUBROUTINE getaddress(fprsnid)
   SET prsn = 0
   SET actcode = 0
   SELECT
    e.person_id
    FROM encounter e
    WHERE e.encntr_id=fprsnid
    DETAIL
     prsn = e.person_id
    WITH nocounter
   ;end select
   IF (prsn != 0)
    SELECT
     cv.code_value
     FROM code_value cv
     WHERE code_set=48
      AND cdf_meaning="ACTIVE"
     DETAIL
      actcode = cv.code_value
     WITH nocoutner
    ;end select
    SELECT
     a.address_id, a_address_type_disp = uar_get_code_display(a.address_type_cd), a.contact_name,
     a.street_addr, a.street_addr2, a.street_addr3,
     a.street_addr4, a.city, a.state,
     a.zipcode, a.county, a_residence_disp = uar_get_code_display(a.residence_cd),
     a.beg_effective_dt_tm, a.end_effective_dt_tm, a.parent_entity_id
     FROM address a,
      person p
     WHERE a.parent_entity_id=prsn
      AND a.parent_entity_name="PERSON"
      AND a.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00")
      AND a.active_status_cd=actcode
     ORDER BY a.beg_effective_dt_tm
     HEAD REPORT
      stat = makedataset(100)
     DETAIL
      stat = writerecord(0)
     FOOT REPORT
      stat = showfieldno(1,false), stat = closedataset(0)
     WITH nocounter, reporthelp, maxrec = 100
    ;end select
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE geteventset(fencid)
  SELECT
   c.encntr_id, c_event_disp = uar_get_code_display(c.event_cd), c_task_assay_disp =
   uar_get_code_display(c.task_assay_cd),
   c_normalcy_disp = uar_get_code_display(c.normalcy_cd), c.result_val, c_result_units_disp =
   uar_get_code_display(c.result_units_cd),
   c_result_status_disp = uar_get_code_display(c.result_status_cd), c.normal_low, c.normal_high,
   c.critical_high, c.critical_low, c_result_time_units_disp = uar_get_code_display(c
    .result_time_units_cd)
   FROM clinical_event c
   WHERE c.encntr_id=cnvtreal(fencid)
   ORDER BY c_task_assay_disp, c_result_time_units_disp
   HEAD REPORT
    stat = makedataset(100)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH nocounter, reporthelp
  ;end select
  RETURN(1)
 END ;Subroutine
 SUBROUTINE getordcatalog(strprimary)
   DECLARE strkey = vc
   SET strkey = cnvtupper( $PARAMLIST)
   IF (( $PARAMLIST="*"))
    RETURN(1)
   ENDIF
   SELECT
    o.catalog_cd, oc.display_key, o_catalog_disp = uar_get_code_display(o.catalog_cd),
    o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o.primary_mnemonic, o
    .dept_display_name,
    o.description, bill_only =
    IF (o.bill_only_ind=1) "Bill Only"
    ELSE " "
    ENDIF
    , o_activity_type_disp = uar_get_code_display(o.activity_type_cd),
    o_activity_subtype_disp = uar_get_code_display(o.activity_subtype_cd), o_event_disp =
    uar_get_code_display(o.event_cd), o_resource_route_disp = uar_get_code_display(o
     .resource_route_cd)
    FROM code_value oc,
     order_catalog o
    PLAN (oc
     WHERE oc.code_set=200
      AND oc.display_key=patstring(strkey)
      AND oc.active_ind=1)
     JOIN (o
     WHERE o.catalog_cd=oc.code_value
      AND o.active_ind=1)
    ORDER BY o_activity_type_disp, o.primary_mnemonic, 0
    HEAD REPORT
     stat = makedataset(100)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp
   ;end select
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getencorderlist(nencid)
   DECLARE strmnemonic = vc
   IF (textlen(trim( $OPTSUBLIST)) > 0)
    SELECT
     o.order_id, o.encntr_id, o.activity_type_cd,
     o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o.catalog_cd, o_catalog_disp =
     uar_get_code_display(o.catalog_cd),
     o.clinical_display_line, o.contributor_system_cd, o_contributor_system_disp =
     uar_get_code_display(o.contributor_system_cd),
     o.dept_status_cd, o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o
     .order_detail_display_line,
     o.order_mnemonic, o.order_status_cd, o_order_status_disp = uar_get_code_display(o
      .order_status_cd),
     o.ordered_as_mnemonic, o.orig_order_dt_tm"@SHORTDATETIMENOSEC"
     FROM orders o
     WHERE o.encntr_id=nencid
      AND o.orig_order_dt_tm BETWEEN cnvtdatetime( $OPTSUBLIST) AND cnvtdatetime( $OPTPARAM)
     ORDER BY o.order_mnemonic, o_order_status_disp, o.orig_order_dt_tm,
      0
     HEAD REPORT
      stat = makedataset(100)
     DETAIL
      stat = writerecord(0)
     FOOT REPORT
      stat = closedataset(0)
     WITH nocounter, reporthelp
    ;end select
   ELSE
    SELECT
     o.order_id, o.encntr_id, o.activity_type_cd,
     o_activity_type_disp = uar_get_code_display(o.activity_type_cd), o.catalog_cd, o_catalog_disp =
     uar_get_code_display(o.catalog_cd),
     o.clinical_display_line, o.contributor_system_cd, o_contributor_system_disp =
     uar_get_code_display(o.contributor_system_cd),
     o.dept_status_cd, o_dept_status_disp = uar_get_code_display(o.dept_status_cd), o
     .order_detail_display_line,
     o.order_mnemonic, o.order_status_cd, o_order_status_disp = uar_get_code_display(o
      .order_status_cd),
     o.ordered_as_mnemonic, o.orig_order_dt_tm"@SHORTDATETIMENOSEC"
     FROM orders o
     WHERE o.encntr_id=nencid
     ORDER BY o.order_mnemonic, o_order_status_disp, o.orig_order_dt_tm,
      0
     HEAD REPORT
      stat = makedataset(100)
     DETAIL
      stat = writerecord(0)
     FOOT REPORT
      stat = closedataset(0)
     WITH nocounter, reporthelp
    ;end select
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getenclist(npersonid)
   IF (npersonid > 0.0)
    SELECT
     e.encntr_id, e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd),
     e_encntr_type_class_disp = uar_get_code_display(e.encntr_type_class_cd),
     e.beg_effective_dt_tm"@SHORTDATETIMENOSEC", e_end_effective_dt_tm =
     IF (cnvtdatetime(e.end_effective_dt_tm) < cnvtdatetime("31-DEC-2100 00:00:00")) format(e
       .end_effective_dt_tm,"@SHORTDATETIMENOSEC;;q")
     ELSE "..."
     ENDIF
     , e_accommodation_reason_disp = uar_get_code_display(e.accommodation_reason_cd),
     e_accommodation_disp = uar_get_code_display(e.accommodation_cd), e_admit_type_disp =
     uar_get_code_display(e.admit_type_cd), e_admit_src_disp = uar_get_code_display(e.admit_src_cd),
     e_contributor_system_disp = uar_get_code_display(e.contributor_system_cd), e_confid_level_disp
      = uar_get_code_display(e.confid_level_cd), e_diet_type_disp = uar_get_code_display(e
      .diet_type_cd),
     e_disch_disposition_disp = uar_get_code_display(e.disch_disposition_cd), e_disch_to_loctn_disp
      = uar_get_code_display(e.disch_to_loctn_cd), e.disch_dt_tm,
     e_encntr_class_disp = uar_get_code_display(e.encntr_class_cd), e_encntr_status_disp =
     uar_get_code_display(e.encntr_status_cd), e_financial_class_disp = uar_get_code_display(e
      .financial_class_cd),
     e_guarantor_type_disp = uar_get_code_display(e.guarantor_type_cd), e_isolation_disp =
     uar_get_code_display(e.isolation_cd), e_loc_bed_disp = uar_get_code_display(e.loc_bed_cd),
     e_loc_building_disp = uar_get_code_display(e.loc_building_cd), e_loc_facility_disp =
     uar_get_code_display(e.loc_facility_cd), e_loc_nurse_unit_disp = uar_get_code_display(e
      .loc_nurse_unit_cd),
     e_loc_room_disp = uar_get_code_display(e.loc_room_cd), e_loc_temp_disp = uar_get_code_display(e
      .loc_temp_cd), e_location_disp = uar_get_code_display(e.location_cd),
     e_med_service_disp = uar_get_code_display(e.med_service_cd), e.reason_for_visit, e_vip_disp =
     uar_get_code_display(e.vip_cd)
     FROM encounter e
     WHERE e.person_id=npersonid
      AND e.active_ind=1
     ORDER BY e.beg_effective_dt_tm, e_encntr_class_disp, 0
     HEAD REPORT
      stat = makedataset(100)
     DETAIL
      stat = writerecord(0)
     FOOT REPORT
      stat = closedataset(0)
     WITH nocounter, reporthelp
    ;end select
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE getpersonlist(strmatchlastname)
   DECLARE comma = i2
   DECLARE lastname = vc
   DECLARE firstname = vc
   DECLARE valid = i2 WITH noconstant(0)
   SET strmatchlastname = trim(cnvtupper(strmatchlastname))
   IF (textlen(strmatchlastname) > 0)
    SET comma = findstring(",",strmatchlastname)
    IF (comma > 0)
     SET lastname = trim(substring(1,(comma - 1),strmatchlastname),3)
     SET firstname = trim(substring((comma+ 1),(textlen(strmatchlastname) - comma),strmatchlastname),
      3)
    ELSE
     SET lastname = trim(strmatchlastname)
     SET firstname = "*"
    ENDIF
    SELECT
     p.person_id, p.name_full_formatted, p.birth_dt_tm,
     p_contributor_system_disp = uar_get_code_display(p.contributor_system_cd), p_vip_disp =
     uar_get_code_display(p.vip_cd), p_confid_level_disp = uar_get_code_display(p.confid_level_cd),
     p_nationality_disp = uar_get_code_display(p.nationality_cd), p_person_type_disp =
     uar_get_code_display(p.person_type_cd), p_race_disp = uar_get_code_display(p.race_cd),
     p_religion_disp = uar_get_code_display(p.religion_cd), p_sex_disp = uar_get_code_display(p
      .sex_cd), p_species_disp = uar_get_code_display(p.species_cd)
     FROM person p
     WHERE p.name_last_key=patstring(lastname)
      AND p.name_first_key=patstring(firstname)
      AND p.active_ind=1
     ORDER BY p.name_last, p.name_first, p.birth_dt_tm,
      0
     HEAD REPORT
      stat = makedataset(100)
     DETAIL
      stat = writerecord(0), valid = 1
     FOOT REPORT
      stat = closedataset(0)
     WITH nocounter, reporthelp, check
    ;end select
    IF (valid != 1)
     IF (cnvtupper( $OPTLIST)="Y")
      SET stat = setmessageboxex(concat('Could not find "',lastname,", ",firstname,
        '" recheck spelling.'),"Person Search",_mb_error_)
     ENDIF
    ENDIF
   ELSE
    SET stat = setmessageboxex("Can not execute GETPERSONLIST without last name","Person Search",
     _mb_error_)
   ENDIF
   RETURN(valid)
 END ;Subroutine
END GO
