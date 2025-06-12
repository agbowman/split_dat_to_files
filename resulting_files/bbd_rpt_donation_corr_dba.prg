CREATE PROGRAM bbd_rpt_donation_corr:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET line = fillstring(125,"_")
 SET first_line = fillstring(116,"-")
 SET corr_line = fillstring(125,"-")
 SET equal_line = fillstring(126,"=")
 SET location_display = fillstring(100," ")
 SET volume_display = fillstring(50," ")
 SET donor_id_alias_cd = 0.0
 SET corr_cnt = 0
 SET don_cnt = 0
 SET cur_don_cnt = 0
 SET cur_reas_cnt = 0
 SET hold_deferral_reason_id = 0
 SET cd_cnt = 0
 SET correction_cnt = 0
 SET corr_reas_cnt = 0
 SET last_donation = "Y"
 SET don_idx = 0
 SET curreas_idx = 0
 SET currreas_total = 0
 SET corrreas_idx = 0
 SET corrreas_total = 0
 SET print_header = "Y"
 SET corr_idx = 0
 SET corr_total = 0
 SET new_line = 0
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lperson_alias_type_code_set = i4 WITH protect, constant(4)
 DECLARE lproduct_correction_code_set = i4 WITH protect, constant(14115)
 DECLARE sdonor_id_mean = c12 WITH protect, constant("DONORID")
 DECLARE sdonor_results_mean = c12 WITH protect, constant("DNRRESULTS")
 DECLARE dresultcd = f8 WITH protect, noconstant(0.0)
 DECLARE cur_owner_area_disp = c40 WITH protect, noconstant("")
 DECLARE cur_inv_area_disp = c40 WITH protect, noconstant("")
 DECLARE bprinted = i2 WITH protect, noconstant(0)
 DECLARE baltprinted = i2 WITH protect, noconstant(0)
 DECLARE thera_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4548,"VOL_THERA"))
 DECLARE self_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",40,"SELF"))
 DECLARE self_disp = vc WITH protect, constant(uar_get_code_display(self_cd))
 DECLARE auto_mean = vc WITH protect, constant("AUTO")
 DECLARE dir_mean = vc WITH protect, constant("DIRECTED")
 FREE SET current
 RECORD current(
   1 system_dt_tm = dq8
 )
 FREE SET corr
 RECORD corr(
   1 donation[*]
     2 donor_number = vc
     2 donation_result_id = f8
     2 encntr_id = f8
     2 contact_id = f8
     2 person_id = f8
     2 procedure_cd = f8
     2 procedure_cd_disp = vc
     2 drawn_dt_tm = dq8
     2 start_dt_tm = dq8
     2 stop_dt_tm = dq8
     2 facility_cd = f8
     2 facility_cd_disp = c40
     2 building_cd = f8
     2 building_cd_disp = c40
     2 ambulatory_cd = f8
     2 ambulatory_cd_disp = c40
     2 room_cd = f8
     2 room_cd_disp = c40
     2 bed_cd = f8
     2 bed_cd_disp = c40
     2 phlebotomist_id = f8
     2 phlebotomist_name = vc
     2 venipuncture_site_cd = f8
     2 venipuncture_site_cd_disp = vc
     2 outcome_cd = f8
     2 outcome_cd_disp = vc
     2 bag_type_cd = f8
     2 bag_type_cd_disp = vc
     2 specimen_volume = vc
     2 spec_unit_of_meas_cd = f8
     2 spec_unit_of_meas_cd_disp = vc
     2 recipient_id = f8
     2 recipient_name = vc
     2 needed_dt_tm = dq8
     2 inventory_area_disp = vc
     2 owner_area_disp = vc
     2 lot_number = vc
     2 segment_number = vc
     2 donation_type_disp = vc
     2 donation_type_cd = f8
     2 disease_info = vc
     2 product_number = vc
     2 product_type_disp = vc
     2 expiration_dt_tm = dq8
     2 product_volume = vc
     2 defer_until_dt_tm = dq8
     2 donor_name = c24
     2 recipient_reltn_cd = f8
     2 recipient_reltn_disp = vc
     2 prod_unit_of_meas_cd = f8
     2 prod_unit_of_meas_cd_disp = vc
     2 procedure_mean = vc
     2 cur_reasons[*]
       3 reason_cd = f8
       3 reason_cd_disp = vc
       3 eligible_dt_tm = dq8
       3 occurred_dt_tm = dq8
       3 calc_elig_dt_tm = dq8
     2 corrections[*]
       3 correct_don_result_id = f8
       3 donation_result_id = f8
       3 contact_id = f8
       3 person_id = f8
       3 correction_reason_cd = f8
       3 correction_reason_cd_disp = vc
       3 correction_text_id = f8
       3 correction_text = vc
       3 corrected_dt_tm = dq8
       3 corrected_tech_id = vc
       3 drawn_dt_tm = dq8
       3 facility_cd = f8
       3 facility_cd_disp = c40
       3 building_cd = f8
       3 building_cd_disp = c40
       3 ambulatory_cd = f8
       3 ambulatory_cd_disp = c40
       3 room_cd = f8
       3 room_cd_disp = c40
       3 bed_cd = f8
       3 bed_cd_disp = c40
       3 procedure_cd = f8
       3 procedure_cd_disp = vc
       3 phlebotomist_id = f8
       3 phlebotomist_name = vc
       3 start_dt_tm = dq8
       3 stop_dt_tm = dq8
       3 venipuncture_site_cd = f8
       3 venipuncture_site_cd_disp = vc
       3 outcome_cd = f8
       3 outcome_cd_disp = vc
       3 bag_type_cd = f8
       3 bag_type_cd_disp = vc
       3 specimen_volume = vc
       3 spec_unit_of_meas_cd = f8
       3 spec_unit_of_meas_cd_disp = vc
       3 recipient_id = f8
       3 recipient_name = vc
       3 recipient_reltn_cd = f8
       3 recipient_reltn_disp = vc
       3 inventory_area_cd = f8
       3 owner_area_cd = f8
       3 facility_cd = f8
       3 facility_cd_disp = vc
       3 procedure_mean = vc
       3 needed_dt_tm = dq8
       3 corr_reasons[*]
         4 reason_cd = f8
         4 reason_cd_disp = vc
         4 eligible_dt_tm = dq8
         4 occurred_dt_tm = dq8
         4 calc_elig_dt_tm = dq8
         4 add_remove_ind = i2
     2 product_corrections[*]
       3 inventory_area_disp = vc
       3 owner_area_disp = vc
       3 lot_number = vc
       3 segment_number = vc
       3 donation_type_cd = f8
       3 donation_type_disp = vc
       3 disease_info = vc
       3 product_number = vc
       3 product_type_disp = vc
       3 expiration_dt_tm = dq8
       3 product_volume = vc
       3 correction_reason_cd_disp = vc
       3 corrected_dt_tm = dq8
       3 corrected_tech_id = vc
       3 prod_unit_of_meas_cd = f8
       3 prod_unit_of_meas_cd_disp = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FREE SET captions
 RECORD captions(
   1 inc_title = vc
   1 inc_time = vc
   1 inc_as_of_date = vc
   1 inc_blood_bank_owner = vc
   1 inc_inventory_area = vc
   1 inc_beg_dt_tm = vc
   1 inc_end_dt_tm = vc
   1 inc_report_id = vc
   1 inc_page = vc
   1 inc_printed = vc
   1 rpt_cerner_health_sys = vc
   1 current_donation = vc
   1 formatted_donor_number = vc
   1 formatted_procedure = vc
   1 formatted_drawn = vc
   1 formatted_start_time = vc
   1 formatted_stop_time = vc
   1 inventory_area = vc
   1 formatted_donation_loc = vc
   1 formatted_phlebotomist = vc
   1 formatted_venipuncture = vc
   1 formatted_outcome = vc
   1 formatted_bag_type = vc
   1 formatted_spec_volume = vc
   1 formatted_recipient = vc
   1 formatted_needed = vc
   1 formatted_reasons = vc
   1 formatted_eligible = vc
   1 donation = vc
   1 previous = vc
   1 note = vc
   1 corrected = vc
   1 tech_id = vc
   1 correction_reason = vc
   1 procedure = vc
   1 drawn = vc
   1 start_time = vc
   1 stop_time = vc
   1 phlebotomist = vc
   1 venipuncture_site = vc
   1 outcome = vc
   1 bag_type = vc
   1 specimen_volume = vc
   1 specimen_measure = vc
   1 recipient = vc
   1 needed = vc
   1 reason_added = vc
   1 reason_removed = vc
   1 reason_changed = vc
   1 end_of_report = vc
   1 facility = vc
   1 building = vc
   1 ambulatory = vc
   1 room = vc
   1 bed = vc
   1 scortype = vc
   1 disp_results = vc
   1 demographic = vc
   1 formatted_tech_disp = vc
   1 formatted_dt_tm = vc
   1 donor_name = vc
   1 owner_area = vc
   1 lot_number = vc
   1 segment_number = vc
   1 donation_type = vc
   1 disease_info = vc
   1 donation_dt_tm = vc
   1 product_number = vc
   1 product_type = vc
   1 product_volume = vc
   1 unit_of_measure = vc
   1 outcome_reasons = vc
   1 recipient_relationship = vc
   1 date_needed = vc
   1 expiration_dt_tm = vc
   1 recipient = vc
   1 defer_until = vc
   1 all = vc
   1 inc_donation_location = vc
   1 none = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner HNA Millenium")
 SET captions->inc_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "D O N A T I O N   C O R R E C T I O N S")
 SET captions->inc_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->inc_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->inc_beg_dt_tm = uar_i18ngetmessage(i18nhandle,"begin_dt_tm","Beginning Date/Time:")
 SET captions->inc_end_dt_tm = uar_i18ngetmessage(i18nhandle,"end_dt_tm","Ending Date/Time:")
 SET captions->current_donation = uar_i18ngetmessage(i18nhandle,"current_donation",
  "Current Donation:")
 SET captions->formatted_donor_number = uar_i18ngetmessage(i18nhandle,"formatted_donor_number",
  "Donor Number")
 SET captions->formatted_procedure = uar_i18ngetmessage(i18nhandle,"formatted_procedure",
  "Donation Procedure")
 SET captions->formatted_drawn = uar_i18ngetmessage(i18nhandle,"formatted_drawn","Drawn:")
 SET captions->formatted_start_time = uar_i18ngetmessage(i18nhandle,"formatted_start_time",
  "Start Time")
 SET captions->formatted_stop_time = uar_i18ngetmessage(i18nhandle,"formatted_stop_time","Stop Time")
 SET captions->formatted_donation_loc = uar_i18ngetmessage(i18nhandle,"formatted_donation_loc",
  "Donation Location")
 SET captions->formatted_phlebotomist = uar_i18ngetmessage(i18nhandle,"formatted_phlebotomist",
  "Phlebotomist")
 SET captions->formatted_venipuncture = uar_i18ngetmessage(i18nhandle,"formatted_venipuncture",
  "Venipuncture Site:")
 SET captions->formatted_outcome = uar_i18ngetmessage(i18nhandle,"formatted_outcome","Outcome")
 SET captions->formatted_bag_type = uar_i18ngetmessage(i18nhandle,"formatted_bag_type","Bag Type:")
 SET captions->formatted_spec_volume = uar_i18ngetmessage(i18nhandle,"formatted_spec_volume",
  "Specimen Volume:")
 SET captions->formatted_recipient = uar_i18ngetmessage(i18nhandle,"formatted_recipient","Recipient:"
  )
 SET captions->formatted_needed = uar_i18ngetmessage(i18nhandle,"formatted_needed","Needed:")
 SET captions->formatted_reasons = uar_i18ngetmessage(i18nhandle,"formatted_reasons","Reasons:")
 SET captions->formatted_eligible = uar_i18ngetmessage(i18nhandle,"formatted_eligible","Eligible:")
 SET captions->donation = uar_i18ngetmessage(i18nhandle,"donation","Donation")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected","Corrected")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->correction_reason = uar_i18ngetmessage(i18nhandle,"correction_reason",
  "Correction Reason")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Procedure")
 SET captions->drawn = uar_i18ngetmessage(i18nhandle,"drawn","Drawn")
 SET captions->start_time = uar_i18ngetmessage(i18nhandle,"start_time","Start Time")
 SET captions->stop_time = uar_i18ngetmessage(i18nhandle,"stop_time","Stop Time")
 SET captions->phlebotomist = uar_i18ngetmessage(i18nhandle,"phlebotomist","Phlebotomist")
 SET captions->venipuncture_site = uar_i18ngetmessage(i18nhandle,"venipuncture_site",
  "Venipuncture Site")
 SET captions->outcome = uar_i18ngetmessage(i18nhandle,"outcome","Outcome")
 SET captions->bag_type = uar_i18ngetmessage(i18nhandle,"bag_type","Bag Type")
 SET captions->specimen_volume = uar_i18ngetmessage(i18nhandle,"specimen_volume","Specimen Volume")
 SET captions->specimen_measure = uar_i18ngetmessage(i18nhandle,"specimen_measure","Specimen Measure"
  )
 SET captions->recipient = uar_i18ngetmessage(i18nhandle,"recipient","Recipient")
 SET captions->needed = uar_i18ngetmessage(i18nhandle,"needed","Needed")
 SET captions->reason_added = uar_i18ngetmessage(i18nhandle,"reason_added","Reason Added")
 SET captions->reason_removed = uar_i18ngetmessage(i18nhandle,"reason_removed","Reason Removed")
 SET captions->reason_changed = uar_i18ngetmessage(i18nhandle,"reason_changed","Reason Changed")
 SET captions->inc_report_id = uar_i18ngetmessage(i18nhandle,"rpt_id","BBD_RPT_DONATION_CORR")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->facility = uar_i18ngetmessage(i18nhandle,"facility","Facility")
 SET captions->building = uar_i18ngetmessage(i18nhandle,"building","Building")
 SET captions->ambulatory = uar_i18ngetmessage(i18nhandle,"ambulatory","Ambulatory")
 SET captions->room = uar_i18ngetmessage(i18nhandle,"room","Room")
 SET captions->bed = uar_i18ngetmessage(i18nhandle,"bed","Bed")
 SET captions->inc_blood_bank_owner = uar_i18ngetmessage(i18nhandle,"inc_blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inc_inventory_area = uar_i18ngetmessage(i18nhandle,"inc_inventory_area",
  "Inventory Area: ")
 SET captions->scortype = uar_i18ngetmessage(i18nhandle,"sCorType","Correction Type:  ")
 SET captions->disp_results = uar_i18ngetmessage(i18nhandle,"disp_results","Update Donation Result")
 SET captions->demographic = uar_i18ngetmessage(i18nhandle,"demographic","Demographic")
 SET captions->formatted_tech_disp = uar_i18ngetmessage(i18nhandle,"formatted_tech_disp","Tech")
 SET captions->formatted_dt_tm = uar_i18ngetmessage(i18nhandle,"formatted_dt_tm","Date/Time")
 SET captions->donor_name = uar_i18ngetmessage(i18nhandle,"donor_name","Donor Name")
 SET captions->owner_area = uar_i18ngetmessage(i18nhandle,"owner_area","Owner Area")
 SET captions->lot_number = uar_i18ngetmessage(i18nhandle,"lot_number","Lot Number")
 SET captions->segment_number = uar_i18ngetmessage(i18nhandle,"segment_number","Segment Number")
 SET captions->donation_type = uar_i18ngetmessage(i18nhandle,"donation_type","Donation Type")
 SET captions->disease_info = uar_i18ngetmessage(i18nhandle,"disease_info","Disease Information")
 SET captions->donation_dt_tm = uar_i18ngetmessage(i18nhandle,"donation_dt_tm","Donation Date/Time")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->product_volume = uar_i18ngetmessage(i18nhandle,"product_volume","Product Volume")
 SET captions->unit_of_measure = uar_i18ngetmessage(i18nhandle,"unit_of_measure","Unit of Measure")
 SET captions->outcome_reasons = uar_i18ngetmessage(i18nhandle,"outcome_reasons","Outcome Reasons")
 SET captions->recipient_relationship = uar_i18ngetmessage(i18nhandle,"recipient_relationship",
  "Recipient Relationship")
 SET captions->date_needed = uar_i18ngetmessage(i18nhandle,"date_needed","Date Needed")
 SET captions->expiration_dt_tm = uar_i18ngetmessage(i18nhandle,"expiration_dt_tm",
  "Expiration Date/Time")
 SET captions->recipient = uar_i18ngetmessage(i18nhandle,"recipient","Recipient Name")
 SET captions->defer_until = uar_i18ngetmessage(i18nhandle,"defer_until","Defer Until")
 SET captions->inc_donation_location = uar_i18ngetmessage(i18nhandle,"inc_donation_location",
  "Donation Location: ")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reply->status_data.status = "F"
 SET lstat = uar_get_meaning_by_codeset(lperson_alias_type_code_set,nullterm(sdonor_id_mean),1,
  donor_id_alias_cd)
 IF (donor_id_alias_cd=0.0)
  CALL subevent_add("bbd_rpt_donation_corr.prg","F","uar_get_meaning_by_codeset",
   "Unable to retrieve the code_value for the cdf_meaning DONORID in code_set 4.")
  GO TO exit_script
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(lproduct_correction_code_set,nullterm(sdonor_results_mean),1,
  dresultcd)
 IF (dresultcd=0.0)
  CALL subevent_add("bbd_rpt_donation_corr.prg","F","uar_get_meaning_by_codeset",
   "Unable to retrieve the code_value for the cdf_meaning DNRRESULTS in code_set 14115.")
  GO TO exit_script
 ENDIF
 IF (((thera_cd=0.0) OR (self_cd=0.0)) )
  CALL subevent_add("bbd_rpt_donation_corr.prg","F","uar_get_meaning_by_codeset",
   "Unable to retrieve the code_value for the cdf_meaning VOL_THERA in code_set 4548.")
  GO TO exit_script
 ENDIF
#script
 SELECT INTO "nl:"
  bcdr.correct_don_result_id, bcdr.person_id, bdr.donation_result_id,
  bdreas.deferral_reason_id, procedure_cd_disp = uar_get_code_display(bdr.procedure_cd),
  venipuncture_site_cd_disp = uar_get_code_display(bdr.venipuncture_site_cd),
  outcome_cd_disp = uar_get_code_display(bdr.outcome_cd), bag_type_cd_disp = uar_get_code_display(bdr
   .bag_type_cd), spec_unit_of_meas_cd_disp = uar_get_code_display(bdr.specimen_unit_meas_cd),
  cur_reason_cd_disp = uar_get_code_display(bdreas.reason_cd), loc_facility_cd_disp =
  uar_get_code_display(e.loc_facility_cd), loc_building_cd_disp = uar_get_code_display(e
   .loc_building_cd),
  loc_ambulatory_cd_disp = uar_get_code_display(e.loc_nurse_unit_cd), loc_room_cd_disp =
  uar_get_code_display(e.loc_room_cd), loc_bed_cd_disp = uar_get_code_display(e.loc_bed_cd),
  owner_disp = uar_get_code_display(prod.cur_owner_area_cd), inv_area_disp = uar_get_code_display(
   prod.cur_inv_area_cd), don_type_disp = uar_get_code_display(prod.donation_type_cd),
  disease_info = uar_get_code_display(prod.disease_cd), prod_type_disp = uar_get_code_display(prod
   .product_cd), spec_vol = trim(cnvtstring(bdr.specimen_volume)),
  cur_vol = trim(cnvtstring(bp.cur_volume)), relation_disp = uar_get_code_display(epr
   .related_person_reltn_cd), procedure_mean = uar_get_code_meaning(bdr.procedure_cd),
  prod_unit_of_meas_cd_disp = uar_get_code_display(prod.cur_unit_meas_cd), donor_alias_disp =
  cnvtalias(pa.alias,pa.alias_pool_cd)
  FROM bbd_correct_don_rslts bcdr,
   bbd_donation_results bdr,
   person_donor pd,
   person_alias pa,
   bbd_donor_contact bdc,
   encounter e,
   prsnl p,
   bbd_donor_eligibility bde,
   bbd_deferral_reason bdreas,
   encntr_person_reltn epr,
   person p2,
   person p3,
   bbd_don_product_r dp,
   product prod,
   blood_product bp
  PLAN (bcdr
   WHERE bcdr.active_ind=1
    AND bcdr.correction_type_cd=dresultcd
    AND bcdr.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   )
   JOIN (bdr
   WHERE bdr.donation_result_id=bcdr.donation_result_id
    AND bdr.active_ind=1)
   JOIN (pd
   WHERE pd.person_id=bcdr.person_id
    AND pd.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(bcdr.person_id)
    AND pa.person_alias_type_cd=outerjoin(donor_id_alias_cd)
    AND pa.active_ind=outerjoin(1))
   JOIN (epr
   WHERE epr.encntr_id=outerjoin(bdr.encntr_id)
    AND epr.active_ind=outerjoin(1)
    AND epr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (bdc
   WHERE bdc.encntr_id=outerjoin(bdr.encntr_id))
   JOIN (e
   WHERE e.encntr_id=bdr.encntr_id
    AND (((request->donation_location_cd > 0)
    AND (e.loc_facility_cd=request->donation_location_cd)) OR ((request->donation_location_cd=0))) )
   JOIN (p
   WHERE p.person_id=bdr.phleb_prsnl_id)
   JOIN (bde
   WHERE bde.encntr_id=bdr.encntr_id
    AND bde.active_ind=1)
   JOIN (bdreas
   WHERE bdreas.eligibility_id=outerjoin(bde.eligibility_id)
    AND bdreas.active_ind=outerjoin(1))
   JOIN (p2
   WHERE p2.person_id=outerjoin(epr.related_person_id))
   JOIN (p3
   WHERE p3.person_id=bdr.person_id)
   JOIN (dp
   WHERE dp.donation_results_id=outerjoin(bdr.donation_result_id))
   JOIN (prod
   WHERE prod.product_id=outerjoin(dp.product_id)
    AND (((request->cur_owner_area_cd > 0)
    AND (prod.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0)))
    AND (((request->cur_inv_area_cd > 0)
    AND (prod.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0))) )
   JOIN (bp
   WHERE bp.product_id=outerjoin(prod.product_id))
  ORDER BY p3.name_last_key, p3.name_first_key, bcdr.person_id,
   bdr.donation_result_id, bdreas.deferral_reason_id
  HEAD REPORT
   cur_don_cnt = 0
  HEAD bdr.donation_result_id
   cur_don_cnt = (cur_don_cnt+ 1), cur_reas_cnt = 0, stat = alterlist(corr->donation,cur_don_cnt),
   corr->donation[cur_don_cnt].donor_name = substring(1,24,trim(p3.name_full_formatted)), corr->
   donation[cur_don_cnt].donor_number =
   IF (pa.person_alias_id > 0) donor_alias_disp
   ELSE null
   ENDIF
   , corr->donation[cur_don_cnt].donation_result_id = bdr.donation_result_id,
   corr->donation[cur_don_cnt].encntr_id = bdr.encntr_id, corr->donation[cur_don_cnt].contact_id =
   bdr.contact_id, corr->donation[cur_don_cnt].person_id = bdr.person_id,
   corr->donation[cur_don_cnt].procedure_cd = bdr.procedure_cd, corr->donation[cur_don_cnt].
   procedure_cd_disp = procedure_cd_disp, corr->donation[cur_don_cnt].procedure_mean = procedure_mean,
   corr->donation[cur_don_cnt].drawn_dt_tm = bdr.drawn_dt_tm, corr->donation[cur_don_cnt].start_dt_tm
    = bdr.start_dt_tm, corr->donation[cur_don_cnt].stop_dt_tm = bdr.stop_dt_tm,
   corr->donation[cur_don_cnt].owner_area_disp = cur_owner_area_disp, corr->donation[cur_don_cnt].
   inventory_area_disp = cur_inv_area_disp, corr->donation[cur_don_cnt].facility_cd = e
   .loc_facility_cd,
   corr->donation[cur_don_cnt].facility_cd_disp = loc_facility_cd_disp, corr->donation[cur_don_cnt].
   building_cd = e.loc_building_cd, corr->donation[cur_don_cnt].building_cd_disp =
   loc_building_cd_disp,
   corr->donation[cur_don_cnt].ambulatory_cd = e.loc_nurse_unit_cd, corr->donation[cur_don_cnt].
   ambulatory_cd_disp = loc_ambulatory_cd_disp, corr->donation[cur_don_cnt].room_cd = e.loc_room_cd,
   corr->donation[cur_don_cnt].room_cd_disp = loc_room_cd_disp, corr->donation[cur_don_cnt].bed_cd =
   e.loc_bed_cd, corr->donation[cur_don_cnt].bed_cd_disp = loc_bed_cd_disp,
   corr->donation[cur_don_cnt].phlebotomist_id = bdr.phleb_prsnl_id, corr->donation[cur_don_cnt].
   phlebotomist_name = p.name_full_formatted, corr->donation[cur_don_cnt].venipuncture_site_cd = bdr
   .venipuncture_site_cd,
   corr->donation[cur_don_cnt].venipuncture_site_cd_disp = venipuncture_site_cd_disp, corr->donation[
   cur_don_cnt].outcome_cd = bdr.outcome_cd, corr->donation[cur_don_cnt].outcome_cd_disp =
   outcome_cd_disp,
   corr->donation[cur_don_cnt].bag_type_cd = bdr.bag_type_cd, corr->donation[cur_don_cnt].
   bag_type_cd_disp = bag_type_cd_disp, corr->donation[cur_don_cnt].specimen_volume = spec_vol,
   corr->donation[cur_don_cnt].spec_unit_of_meas_cd = bdr.specimen_unit_meas_cd, corr->donation[
   cur_don_cnt].spec_unit_of_meas_cd_disp = spec_unit_of_meas_cd_disp, corr->donation[cur_don_cnt].
   recipient_id = epr.related_person_id,
   corr->donation[cur_don_cnt].recipient_name = p2.name_full_formatted, corr->donation[cur_don_cnt].
   recipient_reltn_cd = epr.related_person_reltn_cd, corr->donation[cur_don_cnt].recipient_reltn_disp
    = relation_disp,
   corr->donation[cur_don_cnt].needed_dt_tm = bdc.needed_dt_tm, corr->donation[cur_don_cnt].
   owner_area_disp = owner_disp, corr->donation[cur_don_cnt].inventory_area_disp = inv_area_disp,
   corr->donation[cur_don_cnt].lot_number = bp.lot_nbr, corr->donation[cur_don_cnt].segment_number =
   bp.segment_nbr, corr->donation[cur_don_cnt].donation_type_cd = prod.donation_type_cd,
   corr->donation[cur_don_cnt].donation_type_disp = don_type_disp, corr->donation[cur_don_cnt].
   disease_info = disease_info, corr->donation[cur_don_cnt].product_number = prod.product_nbr,
   corr->donation[cur_don_cnt].product_type_disp = prod_type_disp, corr->donation[cur_don_cnt].
   expiration_dt_tm = prod.cur_expire_dt_tm, corr->donation[cur_don_cnt].product_volume = cur_vol,
   corr->donation[cur_don_cnt].defer_until_dt_tm = pd.defer_until_dt_tm, corr->donation[cur_don_cnt].
   prod_unit_of_meas_cd = prod.cur_unit_meas_cd, corr->donation[cur_don_cnt].
   prod_unit_of_meas_cd_disp = prod_unit_of_meas_cd_disp,
   corr->donation[cur_don_cnt].procedure_mean = procedure_mean
   IF (procedure_mean=auto_mean)
    corr->donation[cur_don_cnt].recipient_name = corr->donation[cur_don_cnt].donor_name, corr->
    donation[cur_don_cnt].recipient_reltn_cd = self_cd, corr->donation[cur_don_cnt].
    recipient_reltn_disp = self_disp
   ELSEIF (procedure_mean != dir_mean)
    corr->donation[cur_don_cnt].recipient_name = " ", corr->donation[cur_don_cnt].recipient_reltn_cd
     = 0.00, corr->donation[cur_don_cnt].recipient_reltn_disp = " "
   ENDIF
  HEAD bdreas.deferral_reason_id
   cur_reas_cnt = (cur_reas_cnt+ 1), stat = alterlist(corr->donation[cur_don_cnt].cur_reasons,
    cur_reas_cnt), corr->donation[cur_don_cnt].cur_reasons[cur_reas_cnt].reason_cd = bdreas.reason_cd,
   corr->donation[cur_don_cnt].cur_reasons[cur_reas_cnt].reason_cd_disp = cur_reason_cd_disp, corr->
   donation[cur_don_cnt].cur_reasons[cur_reas_cnt].eligible_dt_tm = bdreas.eligible_dt_tm, corr->
   donation[cur_don_cnt].cur_reasons[cur_reas_cnt].occurred_dt_tm = bdreas.occurred_dt_tm,
   corr->donation[cur_don_cnt].cur_reasons[cur_reas_cnt].calc_elig_dt_tm = bdreas.calc_elig_dt_tm
  WITH nocounter
 ;end select
 IF (size(corr->donation,5) > 0)
  SELECT INTO "nl:"
   owner_disp = uar_get_code_display(cp.cur_owner_area_cd), inv_area_disp = uar_get_code_display(cp
    .cur_inv_area_cd), don_type_disp = uar_get_code_display(cp.donation_type_cd),
   disease_info = uar_get_code_display(cp.disease_cd), prod_type_disp = uar_get_code_display(cp
    .product_cd), reason_disp = uar_get_code_display(cp.correction_reason_cd),
   volume = trim(cnvtstring(cp.volume)), prod_unit_of_meas_cd_disp = uar_get_code_display(cp
    .unit_meas_cd)
   FROM (dummyt d_cd  WITH seq = value(cur_don_cnt)),
    bbd_don_product_r dp,
    corrected_product cp,
    prsnl p
   PLAN (d_cd
    WHERE d_cd.seq > 0)
    JOIN (dp
    WHERE (dp.donation_results_id=corr->donation[d_cd.seq].donation_result_id))
    JOIN (cp
    WHERE cp.product_id=dp.product_id
     AND cp.updt_dt_tm >= cnvtdatetime(request->beg_dt_tm))
    JOIN (p
    WHERE p.person_id=cp.updt_id)
   ORDER BY dp.donation_results_id, cp.updt_dt_tm
   HEAD dp.donation_results_id
    pc_cnt = 0
   HEAD cp.updt_dt_tm
    pc_cnt = (pc_cnt+ 1), stat = alterlist(corr->donation[d_cd.seq].product_corrections,pc_cnt), corr
    ->donation[d_cd.seq].product_corrections[pc_cnt].owner_area_disp = owner_disp,
    corr->donation[d_cd.seq].product_corrections[pc_cnt].inventory_area_disp = inv_area_disp, corr->
    donation[d_cd.seq].product_corrections[pc_cnt].lot_number = cp.orig_lot_nbr, corr->donation[d_cd
    .seq].product_corrections[pc_cnt].segment_number = cp.segment_nbr,
    corr->donation[d_cd.seq].product_corrections[pc_cnt].donation_type_cd = cp.donation_type_cd, corr
    ->donation[d_cd.seq].product_corrections[pc_cnt].donation_type_disp = don_type_disp, corr->
    donation[d_cd.seq].product_corrections[pc_cnt].disease_info = disease_info,
    corr->donation[d_cd.seq].product_corrections[pc_cnt].product_number = cp.product_nbr, corr->
    donation[d_cd.seq].product_corrections[pc_cnt].product_type_disp = prod_type_disp, corr->
    donation[d_cd.seq].product_corrections[pc_cnt].expiration_dt_tm = cp.expire_dt_tm,
    corr->donation[d_cd.seq].product_corrections[pc_cnt].product_volume = volume, corr->donation[d_cd
    .seq].product_corrections[pc_cnt].correction_reason_cd_disp = reason_disp, corr->donation[d_cd
    .seq].product_corrections[pc_cnt].corrected_dt_tm = cp.updt_dt_tm,
    corr->donation[d_cd.seq].product_corrections[pc_cnt].corrected_tech_id = p.username, corr->
    donation[d_cd.seq].product_corrections[pc_cnt].prod_unit_of_meas_cd = cp.unit_meas_cd, corr->
    donation[d_cd.seq].product_corrections[pc_cnt].prod_unit_of_meas_cd_disp =
    prod_unit_of_meas_cd_disp
   WITH nocounter
  ;end select
  SELECT INTO cpm_cfn_info->file_name_path
   bcdr.person_id, bcdr.donation_result_id, bcdr.correct_don_result_id,
   bcdre.correct_def_reason_id, corr_reason_cd_disp = uar_get_code_display(bcdr.correction_reason_cd),
   procedure_cd_disp = uar_get_code_display(bcdr.procedure_type_cd),
   venipuncture_site_cd_disp = uar_get_code_display(bcdr.venipuncture_site_cd), outcome_cd_disp =
   uar_get_code_display(bcdr.outcome_cd), bag_type_cd_disp = uar_get_code_display(bcdr.bag_type_cd),
   spec_unit_of_meas_cd_disp = uar_get_code_display(bcdr.specimen_unit_meas_cd), cur_reason_cd_disp
    = uar_get_code_display(bcdre.reason_cd), hold_long_text_display = substring(1,4000,lt.long_text),
   facility_cd_disp = uar_get_code_display(bcdr.facility_cd), spec_vol = trim(cnvtstring(bcdr
     .specimen_volume)), cur_owner_area_disp =
   IF ((request->cur_owner_area_cd=0)) captions->all
   ELSE uar_get_code_display(request->cur_owner_area_cd)
   ENDIF
   ,
   cur_inv_area_disp =
   IF ((request->cur_inv_area_cd=0)) captions->all
   ELSE uar_get_code_display(request->cur_inv_area_cd)
   ENDIF
   , cur_don_loc_disp =
   IF ((request->donation_location_cd=0)) captions->all
   ELSE uar_get_code_display(request->donation_location_cd)
   ENDIF
   , relation_disp = uar_get_code_display(bcdr.recipient_reltn_cd),
   procedure_mean = uar_get_code_meaning(bcdr.procedure_type_cd)
   FROM (dummyt d_cd  WITH seq = value(cur_don_cnt)),
    bbd_correct_don_rslts bcdr,
    prsnl p,
    prsnl p2,
    (dummyt d_bcdr  WITH seq = 1),
    bbd_correct_def_reason bcdre,
    (dummyt d_lt  WITH seq = 1),
    long_text lt,
    (dummyt d_p3  WITH seq = 1),
    person p3,
    encntr_person_reltn epr
   PLAN (d_cd
    WHERE d_cd.seq > 0)
    JOIN (bcdr
    WHERE (bcdr.donation_result_id=corr->donation[d_cd.seq].donation_result_id)
     AND bcdr.active_ind=1
     AND bcdr.updt_dt_tm >= cnvtdatetime(request->beg_dt_tm))
    JOIN (p
    WHERE p.person_id=bcdr.phleb_prsnl_id)
    JOIN (p2
    WHERE p2.person_id=bcdr.updt_id)
    JOIN (d_p3
    WHERE d_p3.seq=1)
    JOIN (epr
    WHERE epr.encntr_person_reltn_id=outerjoin(bcdr.encntr_person_reltn_id))
    JOIN (p3
    WHERE p3.person_id=outerjoin(epr.related_person_id))
    JOIN (d_lt
    WHERE d_lt.seq=1)
    JOIN (((lt
    WHERE lt.long_text_id=bcdr.correction_text_id
     AND lt.parent_entity_id=bcdr.correct_don_result_id
     AND lt.parent_entity_name="BBD_CORRECT_DON_RSLTS"
     AND lt.active_ind=1)
    ) ORJOIN ((d_bcdr
    WHERE d_bcdr.seq=1)
    JOIN (bcdre
    WHERE bcdre.correct_don_result_id=bcdr.correct_don_result_id
     AND bcdre.active_ind=1)
    ))
   ORDER BY d_cd.seq, bcdr.person_id, bcdr.donation_result_id,
    bcdr.correct_don_result_id, bcdre.correct_def_reason_id
   HEAD REPORT
    cd_cnt = 0, don_cnt = 0
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
    curdate"@DATECONDENSED;;d", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,
     curprog,"",curcclrev),
    row 0
    IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
     inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
      "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
    ELSE
     col 1, sub_get_location_name
    ENDIF
    row + 1
    IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
     IF (sub_get_location_address1 != " ")
      col 1, sub_get_location_address1, row + 1
     ENDIF
     IF (sub_get_location_address2 != " ")
      col 1, sub_get_location_address2, row + 1
     ENDIF
     IF (sub_get_location_address3 != " ")
      col 1, sub_get_location_address3, row + 1
     ENDIF
     IF (sub_get_location_address4 != " ")
      col 1, sub_get_location_address4, row + 1
     ENDIF
     IF (sub_get_location_citystatezip != ",   ")
      col 1, sub_get_location_citystatezip, row + 1
     ENDIF
     IF (sub_get_location_country != " ")
      col 1, sub_get_location_country, row + 1
     ENDIF
    ENDIF
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, captions->inc_donation_location,
    col 20, cur_don_loc_disp, row + 2,
    col 1, captions->scortype, col 18,
    result_disp, row + 3, col 1,
    captions->demographic, col 27, captions->previous,
    col 54, captions->corrected, col 81,
    captions->formatted_dt_tm, col 97, captions->formatted_reasons,
    col 123, captions->formatted_tech_disp, row + 1,
    col 1, "------------------------", col 27,
    "-------------------------", col 54, "-------------------------",
    col 81, "--------------", col 97,
    "------------------------", col 123, "--------",
    row + 1
   HEAD bcdr.donation_result_id
    don_cnt = (don_cnt+ 1), cd_cnt = 0
   HEAD bcdr.correct_don_result_id
    corr_reas_cnt = 0, cd_cnt = (cd_cnt+ 1), stat = alterlist(corr->donation[don_cnt].corrections,
     cd_cnt),
    corr->donation[don_cnt].corrections[cd_cnt].correct_don_result_id = bcdr.correct_don_result_id,
    corr->donation[don_cnt].corrections[cd_cnt].donation_result_id = bcdr.donation_result_id, corr->
    donation[don_cnt].corrections[cd_cnt].correction_reason_cd_disp = corr_reason_cd_disp,
    corr->donation[don_cnt].corrections[cd_cnt].contact_id = bcdr.contact_id, corr->donation[don_cnt]
    .corrections[cd_cnt].person_id = bcdr.person_id, corr->donation[don_cnt].corrections[cd_cnt].
    correction_text_id = bcdr.correction_text_id,
    corr->donation[don_cnt].corrections[cd_cnt].corrected_dt_tm = bcdr.updt_dt_tm, corr->donation[
    don_cnt].corrections[cd_cnt].corrected_tech_id = p2.username, corr->donation[don_cnt].
    corrections[cd_cnt].correction_text = hold_long_text_display,
    corr->donation[don_cnt].corrections[cd_cnt].drawn_dt_tm = bcdr.drawn_dt_tm, corr->donation[
    don_cnt].corrections[cd_cnt].procedure_cd = bcdr.procedure_type_cd, corr->donation[don_cnt].
    corrections[cd_cnt].procedure_cd_disp = procedure_cd_disp,
    corr->donation[don_cnt].corrections[cd_cnt].phlebotomist_id = bcdr.phleb_prsnl_id, corr->
    donation[don_cnt].corrections[cd_cnt].phlebotomist_name = trim(p.name_full_formatted), corr->
    donation[don_cnt].corrections[cd_cnt].start_dt_tm = bcdr.start_dt_tm,
    corr->donation[don_cnt].corrections[cd_cnt].stop_dt_tm = bcdr.stop_dt_tm, corr->donation[don_cnt]
    .corrections[cd_cnt].venipuncture_site_cd = bcdr.venipuncture_site_cd, corr->donation[don_cnt].
    corrections[cd_cnt].venipuncture_site_cd_disp = venipuncture_site_cd_disp,
    corr->donation[don_cnt].corrections[cd_cnt].outcome_cd = bcdr.outcome_cd, corr->donation[don_cnt]
    .corrections[cd_cnt].outcome_cd_disp = outcome_cd_disp, corr->donation[don_cnt].corrections[
    cd_cnt].bag_type_cd = bcdr.bag_type_cd,
    corr->donation[don_cnt].corrections[cd_cnt].bag_type_cd_disp = bag_type_cd_disp, corr->donation[
    don_cnt].corrections[cd_cnt].specimen_volume = spec_vol, corr->donation[don_cnt].corrections[
    cd_cnt].spec_unit_of_meas_cd = bcdr.specimen_unit_meas_cd,
    corr->donation[don_cnt].corrections[cd_cnt].spec_unit_of_meas_cd_disp = spec_unit_of_meas_cd_disp,
    corr->donation[don_cnt].corrections[cd_cnt].recipient_id = p3.person_id, corr->donation[don_cnt].
    corrections[cd_cnt].recipient_name = p3.name_full_formatted,
    corr->donation[don_cnt].corrections[cd_cnt].recipient_reltn_cd = bcdr.recipient_reltn_cd, corr->
    donation[don_cnt].corrections[cd_cnt].recipient_reltn_disp = relation_disp, corr->donation[
    don_cnt].corrections[cd_cnt].needed_dt_tm = bcdr.needed_dt_tm,
    corr->donation[don_cnt].corrections[cd_cnt].inventory_area_cd = bcdr.inventory_area_cd, corr->
    donation[don_cnt].corrections[cd_cnt].owner_area_cd = bcdr.owner_area_cd, corr->donation[don_cnt]
    .corrections[cd_cnt].facility_cd = bcdr.facility_cd,
    corr->donation[don_cnt].corrections[cd_cnt].facility_cd_disp = facility_cd_disp, corr->donation[
    don_cnt].corrections[cd_cnt].procedure_mean = procedure_mean
    IF (procedure_mean=auto_mean)
     corr->donation[don_cnt].corrections[cd_cnt].recipient_name = corr->donation[don_cnt].donor_name,
     corr->donation[don_cnt].corrections[cd_cnt].recipient_reltn_cd = self_cd, corr->donation[don_cnt
     ].corrections[cd_cnt].recipient_reltn_disp = self_disp
    ENDIF
   HEAD bcdre.correct_def_reason_id
    IF (bcdre.reason_cd > 0)
     corr_reas_cnt = (corr_reas_cnt+ 1), stat = alterlist(corr->donation[don_cnt].corrections[cd_cnt]
      .corr_reasons,corr_reas_cnt), corr->donation[don_cnt].corrections[cd_cnt].corr_reasons[
     corr_reas_cnt].reason_cd = bcdre.reason_cd,
     corr->donation[don_cnt].corrections[cd_cnt].corr_reasons[corr_reas_cnt].reason_cd_disp =
     cur_reason_cd_disp, corr->donation[don_cnt].corrections[cd_cnt].corr_reasons[corr_reas_cnt].
     eligible_dt_tm = bcdre.eligible_dt_tm, corr->donation[don_cnt].corrections[cd_cnt].corr_reasons[
     corr_reas_cnt].occurred_dt_tm = bcdre.occurred_dt_tm,
     corr->donation[don_cnt].corrections[cd_cnt].corr_reasons[corr_reas_cnt].calc_elig_dt_tm = bcdre
     .calc_dt_tm, corr->donation[don_cnt].corrections[cd_cnt].corr_reasons[corr_reas_cnt].
     add_remove_ind = bcdre.add_remove_ind
    ENDIF
   DETAIL
    row + 0
   FOOT  bcdre.correct_def_reason_id
    row + 0
   FOOT  bcdr.correct_don_result_id
    row + 0
   FOOT  bcdr.donation_result_id
    alt_corr_idx = 0, alt_prod_idx = 0, corr_idx = 0,
    corr_total = cnvtint(size(corr->donation[d_cd.seq].corrections,5)), prod_idx = 0, prod_total =
    cnvtint(size(corr->donation[d_cd.seq].product_corrections,5)),
    reas_idx = 0, reas_total = 0, col 1,
    captions->donor_name, col 27, corr->donation[d_cd.seq].donor_name,
    row + 1, col 1, captions->formatted_donor_number
    IF ((corr->donation[d_cd.seq].donor_number=null))
     col 27, captions->none
    ELSE
     col 27, corr->donation[d_cd.seq].donor_number
    ENDIF
    row + 1, bprinted = 0, col 1,
    captions->formatted_procedure
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->formatted_procedure, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].procedure_cd > 0)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].procedure_cd_disp
       "####################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].procedure_cd > 0)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          procedure_cd_disp"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].procedure_cd_disp"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].procedure_cd_disp
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->formatted_donation_loc
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->formatted_donation_loc, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].facility_cd > 0)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].facility_cd_disp
       "####################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].facility_cd > 0)
          AND baltprinted=0
          AND (corr->donation[d_cd.seq].corrections[alt_corr_idx].facility_cd_disp != corr->donation[
         d_cd.seq].facility_cd_disp))
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          facility_cd_disp"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].facility_cd_disp"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].facility_cd_disp"####################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->owner_area
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->owner_area, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].owner_area_disp) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].owner_area_disp
       "####################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].owner_area_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          owner_area_disp"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].owner_area_disp"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->owner_area,
      col 27, corr->donation[d_cd.seq].owner_area_disp"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].owner_area_disp"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->inc_inventory_area
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->inc_inventory_area, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].inventory_area_disp) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].
       inventory_area_disp"####################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].inventory_area_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          inventory_area_disp"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].inventory_area_disp"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->inc_inventory_area,
      col 27, corr->donation[d_cd.seq].inventory_area_disp"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].inventory_area_disp"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->lot_number
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->lot_number, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].lot_number) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].lot_number
       "####################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].lot_number) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          lot_number"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].lot_number"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->lot_number,
      col 27, corr->donation[d_cd.seq].lot_number"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].lot_number"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->segment_number
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->segment_number, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].segment_number) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].segment_number
       "####################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].segment_number) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          segment_number"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].segment_number"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->segment_number,
      col 27, corr->donation[d_cd.seq].segment_number"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].segment_number"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->donation_type
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->donation_type, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].donation_type_disp) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].
       donation_type_disp"####################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].donation_type_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          donation_type_disp"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].donation_type_disp"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->donation_type,
      col 27, corr->donation[d_cd.seq].donation_type_disp"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].donation_type_disp"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->disease_info
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->disease_info, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].disease_info) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].disease_info
       "####################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (baltprinted=0
          AND ((size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].disease_info) > 0)
          OR ((corr->donation[d_cd.seq].product_corrections[alt_prod_idx].donation_type_cd > 0))) )
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          disease_info"####################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].disease_info"####################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF ((corr->donation[d_cd.seq].product_corrections[prod_idx].donation_type_cd > 0)
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bfounddisease = 0
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF ((corr->donation[d_cd.seq].product_corrections[alt_prod_idx].donation_type_cd > 0)
          AND size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].disease_info)=0)
          bfounddisease = 1
         ELSEIF (bfounddisease=0
          AND size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].disease_info) > 0)
          bprinted = 1, baltprinted = 1, bfounddisease = 1,
          col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].disease_info
          "####################", col 54,
          corr->donation[d_cd.seq].product_corrections[alt_prod_idx].disease_info
          "####################", col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].
          corrected_dt_tm"@SHORTDATE;;d",
          col 90, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm
          "@TIMENOSECONDS;;d", col 97,
          corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
          "#################", col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].
          corrected_tech_id"########"
          IF (row > 55)
           BREAK, new_line = 1
          ELSE
           row + 1
          ENDIF
         ENDIF
       ENDFOR
       IF (alt_prod_idx >= prod_total
        AND (corr->donation[d_cd.seq].donation_type_cd=thera_cd)
        AND bfounddisease=0)
        bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].disease_info
        "####################",
        col 54, corr->donation[d_cd.seq].disease_info"####################", col 81,
        corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
        corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d",
        col 97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
        "#################", col 123,
        corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
        IF (row > 55)
         BREAK, new_line = 1
        ELSE
         row + 1
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->disease_info,
      col 27, corr->donation[d_cd.seq].disease_info"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].disease_info"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->donation_dt_tm
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->donation_dt_tm, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].drawn_dt_tm != null)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].drawn_dt_tm
       "@SHORTDATE;;d",
       col 36, corr->donation[d_cd.seq].corrections[corr_idx].drawn_dt_tm"@TIMENOSECONDS;;d"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].drawn_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].drawn_dt_tm
          "@SHORTDATE;;d",
          col 63, corr->donation[d_cd.seq].corrections[alt_corr_idx].drawn_dt_tm"@TIMENOSECONDS;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].drawn_dt_tm"@SHORTDATE;;d", col 63,
        corr->donation[d_cd.seq].drawn_dt_tm"@TIMENOSECONDS;;d"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].drawn_dt_tm"@SHORTDATE;;d", col 36,
       corr->donation[d_cd.seq].drawn_dt_tm"@TIMENOSECONDS;;d"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->formatted_start_time
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->formatted_start_time, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].start_dt_tm != null)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].start_dt_tm
       "@TIMENOSECONDS;;d"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].start_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].start_dt_tm
          "@TIMENOSECONDS;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].start_dt_tm"@TIMENOSECONDS;;d"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].start_dt_tm"@TIMENOSECONDS;;d"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->formatted_stop_time
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->formatted_stop_time, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].stop_dt_tm != null)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].stop_dt_tm
       "@TIMENOSECONDS;;d"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].stop_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].stop_dt_tm
          "@TIMENOSECONDS;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].stop_dt_tm"@TIMENOSECONDS;;d"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].stop_dt_tm"@TIMENOSECONDS;;d"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->formatted_phlebotomist
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->formatted_phlebotomist, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].phlebotomist_id > 0)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].phlebotomist_name
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].phlebotomist_id > 0)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          phlebotomist_name"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].phlebotomist_name"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].phlebotomist_name"#########################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->venipuncture_site
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->venipuncture_site, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].venipuncture_site_cd > 0)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].venipuncture_site_cd_disp
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].venipuncture_site_cd > 0)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          venipuncture_site_cd_disp"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].venipuncture_site_cd_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].venipuncture_site_cd_disp"####################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->product_number
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->product_number, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].product_number) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].product_number
       "#########################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].product_number) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          product_number"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].product_number"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->product_number,
      col 27, corr->donation[d_cd.seq].product_number"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].product_number"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->product_type
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->product_type, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].product_type_disp) > 0
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].product_type_disp
       "#########################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].product_type_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          product_type_disp"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].product_type_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->product_type,
      col 27, corr->donation[d_cd.seq].product_type_disp"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].product_type_disp"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->expiration_dt_tm
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->expiration_dt_tm, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].product_corrections[prod_idx].expiration_dt_tm != null)
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].expiration_dt_tm
       "@SHORTDATE;;d",
       col 36, corr->donation[d_cd.seq].product_corrections[prod_idx].expiration_dt_tm
       "@TIMENOSECONDS;;d"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF ((corr->donation[d_cd.seq].product_corrections[alt_prod_idx].expiration_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          expiration_dt_tm"@SHORTDATE;;d",
          col 63, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].expiration_dt_tm
          "@TIMENOSECONDS;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].expiration_dt_tm"@SHORTDATE;;d", col 63,
        corr->donation[d_cd.seq].expiration_dt_tm"@TIMENOSECONDS;;d"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->expiration_dt_tm,
      col 27, corr->donation[d_cd.seq].expiration_dt_tm"@SHORTDATE;;d", col 36,
      corr->donation[d_cd.seq].expiration_dt_tm"@TIMENOSECONDS;;d", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].expiration_dt_tm"@SHORTDATE;;d", col 36,
      corr->donation[d_cd.seq].expiration_dt_tm"@TIMENOSECONDS;;d", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->product_volume
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->product_volume, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].product_volume) > 0
       AND  NOT ((corr->donation[d_cd.seq].product_corrections[prod_idx].product_volume="0"))
       AND (corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm <= request->
      end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].product_volume
       "#########################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].product_volume) > 0
          AND baltprinted=0
          AND  NOT ((corr->donation[d_cd.seq].product_corrections[alt_prod_idx].product_volume="0")))
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          product_volume"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].product_volume"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->product_volume,
      col 27, corr->donation[d_cd.seq].product_volume"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].product_volume"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->unit_of_measure
    FOR (prod_idx = 1 TO prod_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->unit_of_measure, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].product_corrections[prod_idx].prod_unit_of_meas_cd_disp) > 0)
       bprinted = 1, col 27, corr->donation[d_cd.seq].product_corrections[prod_idx].
       prod_unit_of_meas_cd_disp"#########################"
       FOR (alt_prod_idx = (prod_idx+ 1) TO prod_total)
         IF (size(corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          prod_unit_of_meas_cd_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].product_corrections[alt_prod_idx].
          prod_unit_of_meas_cd_disp"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].prod_unit_of_meas_cd_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@SHORTDATE;;d",
       col 90,
       corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col
        97, corr->donation[d_cd.seq].product_corrections[prod_idx].correction_reason_cd_disp
       "#################",
       col 123, corr->donation[d_cd.seq].product_corrections[prod_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (prod_idx >= prod_total
     AND bprinted=0)
     IF (row > 55)
      BREAK, col 1, captions->unit_of_measure,
      col 27, corr->donation[d_cd.seq].prod_unit_of_meas_cd_disp"####################", row + 1
     ELSE
      col 27, corr->donation[d_cd.seq].prod_unit_of_meas_cd_disp"####################", row + 1
     ENDIF
    ENDIF
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->specimen_volume
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->specimen_volume, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].corrections[corr_idx].specimen_volume) > 0
       AND  NOT ((corr->donation[d_cd.seq].corrections[corr_idx].specimen_volume="-1"))
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].specimen_volume
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF (size(corr->donation[d_cd.seq].corrections[alt_corr_idx].specimen_volume) > 0
          AND baltprinted=0
          AND  NOT ((corr->donation[d_cd.seq].corrections[alt_corr_idx].specimen_volume="-1")))
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].specimen_volume
          "#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].specimen_volume"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].specimen_volume"####################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->unit_of_measure
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->unit_of_measure, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].spec_unit_of_meas_cd > 0)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].spec_unit_of_meas_cd_disp
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].spec_unit_of_meas_cd > 0)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          spec_unit_of_meas_cd_disp"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].spec_unit_of_meas_cd_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].spec_unit_of_meas_cd_disp"####################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->bag_type
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->bag_type, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].corrections[corr_idx].bag_type_cd_disp) > 0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].bag_type_cd_disp
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF (size(corr->donation[d_cd.seq].corrections[alt_corr_idx].bag_type_cd_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          bag_type_cd_disp"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].bag_type_cd_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].bag_type_cd_disp"####################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->formatted_outcome
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->formatted_outcome, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].corrections[corr_idx].outcome_cd_disp) > 0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].outcome_cd_disp
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF (size(corr->donation[d_cd.seq].corrections[alt_corr_idx].outcome_cd_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].outcome_cd_disp
          "#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].outcome_cd_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].outcome_cd_disp"####################"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->outcome_reasons
    FOR (corr_idx = 1 TO corr_total)
      corrreas_total = cnvtint(size(corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons,5))
      FOR (corrreas_idx = 1 TO corrreas_total)
       IF (row > 55)
        BREAK, col 1, captions->outcome_reasons
       ENDIF
       ,
       IF ((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].reason_cd > 0)
        AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
        bprinted = 1
        IF ((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].add_remove_ind
        =0)
         AND (((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
        eligible_dt_tm != null)) OR ((((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[
        corrreas_idx].occurred_dt_tm != null)) OR ((corr->donation[d_cd.seq].corrections[corr_idx].
        corr_reasons[corrreas_idx].calc_elig_dt_tm != null))) )) )
         IF ((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
         eligible_dt_tm != null))
          col 2, captions->defer_until, col 27,
          corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].eligible_dt_tm
          "@SHORTDATE;;d", col 54, corr->donation[d_cd.seq].defer_until_dt_tm"@SHORTDATE;;d"
         ELSEIF ((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
         occurred_dt_tm != null))
          col 27, corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
          reason_cd_disp"###############", col 54,
          corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].occurred_dt_tm
          "@SHORTDATE;;d"
         ELSE
          col 27, corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
          reason_cd_disp"###############", col 54,
          corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].calc_elig_dt_tm
          "@SHORTDATE;;d"
         ENDIF
         col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col
         90,
         corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
         corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
         col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
         IF (row > 55)
          BREAK, new_line = 1
         ELSE
          row + 1
         ENDIF
        ELSE
         IF ((corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
         add_remove_ind=0))
          col 27, corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
          reason_cd_disp"###############"
         ELSE
          col 54, corr->donation[d_cd.seq].corrections[corr_idx].corr_reasons[corrreas_idx].
          reason_cd_disp"###############"
         ENDIF
         col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col
         90,
         corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
         corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
         col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
         IF (row > 55)
          BREAK, new_line = 1
         ELSE
          row + 1
         ENDIF
        ENDIF
       ENDIF
      ENDFOR
      IF (corr_idx=corr_total
       AND bprinted=0)
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->recipient
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->recipient, new_line = 0
      ENDIF
      IF (((size(corr->donation[d_cd.seq].corrections[corr_idx].recipient_name) > 0) OR ((corr->
      donation[d_cd.seq].corrections[corr_idx].procedure_mean=auto_mean)))
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       IF (size(corr->donation[d_cd.seq].corrections[corr_idx].recipient_name) > 0)
        bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].recipient_name
        "#########################"
       ELSEIF ((corr->donation[d_cd.seq].corrections[corr_idx].procedure_mean=auto_mean))
        bprinted = 1, col 27, corr->donation[d_cd.seq].donor_name"#########################"
       ENDIF
       IF (bprinted=1)
        FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
          IF (baltprinted=0)
           IF (size(corr->donation[d_cd.seq].corrections[alt_corr_idx].recipient_name) > 0)
            baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
            recipient_name"#########################"
           ELSEIF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].procedure_mean=auto_mean))
            baltprinted = 1, col 54, corr->donation[d_cd.seq].donor_name"#########################"
           ENDIF
          ENDIF
        ENDFOR
        IF (baltprinted=0)
         col 54, corr->donation[d_cd.seq].recipient_name"#########################"
        ENDIF
        col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
        corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
        corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
        col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
        IF (row > 55)
         BREAK, new_line = 1
        ELSE
         row + 1
        ENDIF
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].recipient_name"####################", row + 1
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->recipient_relationship
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->recipient_relationship, new_line = 0
      ENDIF
      IF (size(corr->donation[d_cd.seq].corrections[corr_idx].recipient_reltn_disp) > 0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].recipient_reltn_disp
       "#########################"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF (size(corr->donation[d_cd.seq].corrections[alt_corr_idx].recipient_reltn_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].
          recipient_reltn_disp"#########################"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].recipient_reltn_disp"#########################"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].recipient_reltn_disp
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ENDIF
    bprinted = 0, col 1, captions->date_needed
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->date_needed, new_line = 0
      ENDIF
      IF ((corr->donation[d_cd.seq].corrections[corr_idx].needed_dt_tm != null)
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donation[d_cd.seq].corrections[corr_idx].needed_dt_tm
       "@SHORTDATE;;d"
       FOR (alt_corr_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donation[d_cd.seq].corrections[alt_corr_idx].needed_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donation[d_cd.seq].corrections[alt_corr_idx].needed_dt_tm
          "@SHORTDATE;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donation[d_cd.seq].needed_dt_tm"@SHORTDATE;;d"
       ENDIF
       col 81, corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97,
       corr->donation[d_cd.seq].corrections[corr_idx].correction_reason_cd_disp"#################",
       col 123, corr->donation[d_cd.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx=corr_total
       AND bprinted=0
       AND (corr->donation[d_cd.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donation[d_cd.seq].needed_dt_tm"@SHORTDATE;;d"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (d_cd.seq < size(corr->donation,5))
     BREAK
    ENDIF
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 118, captions->inc_page, col 124,
    curpage"###", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, compress, nolandscape,
    outerjoin = d_lt, outerjoin = d_bcdr, outerjoin = d_p3,
    maxrow = 61
  ;end select
 ELSEIF (bnullrpt=1)
  SELECT INTO cpm_cfn_info->file_name_path
   cur_owner_area_disp =
   IF ((request->cur_owner_area_cd=0)) captions->all
   ELSE uar_get_code_display(request->cur_owner_area_cd)
   ENDIF
   , cur_inv_area_disp =
   IF ((request->cur_inv_area_cd=0)) captions->all
   ELSE uar_get_code_display(request->cur_inv_area_cd)
   ENDIF
   , cur_don_loc_disp =
   IF ((request->donation_location_cd=0)) captions->all
   ELSE uar_get_code_display(request->donation_location_cd)
   ENDIF
   FROM (dummyt d_cd  WITH seq = value(cur_don_cnt))
   PLAN (d_cd
    WHERE d_cd.seq > 0)
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
    curdate"@DATECONDENSED;;d", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,
     curprog,"",curcclrev),
    row 0
    IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
     inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
      "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
    ELSE
     col 1, sub_get_location_name
    ENDIF
    row + 1
    IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
     IF (sub_get_location_address1 != " ")
      col 1, sub_get_location_address1, row + 1
     ENDIF
     IF (sub_get_location_address2 != " ")
      col 1, sub_get_location_address2, row + 1
     ENDIF
     IF (sub_get_location_address3 != " ")
      col 1, sub_get_location_address3, row + 1
     ENDIF
     IF (sub_get_location_address4 != " ")
      col 1, sub_get_location_address4, row + 1
     ENDIF
     IF (sub_get_location_citystatezip != ",   ")
      col 1, sub_get_location_citystatezip, row + 1
     ENDIF
     IF (sub_get_location_country != " ")
      col 1, sub_get_location_country, row + 1
     ENDIF
    ENDIF
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, captions->inc_donation_location,
    col 20, cur_don_loc_disp, row + 2,
    col 1, captions->scortype, col 18,
    captions->donation_corrections, row + 3, col 1,
    captions->demographic, col 27, captions->previous,
    col 54, captions->corrected, col 81,
    captions->formatted_dt_tm, col 97, captions->formatted_reasons,
    col 123, captions->formatted_tech_disp, row + 1,
    col 1, "------------------------", col 27,
    "-------------------------", col 54, "-------------------------",
    col 81, "--------------", col 97,
    "------------------------", col 123, "--------",
    row + 1
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 118, captions->inc_page, col 124,
    curpage"###", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, compress, nolandscape,
    maxrow = 61, nullreport
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD captions
END GO
