CREATE PROGRAM bhs_sn_trackcore_out:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "",
  "End Date:" = "CURDATE",
  "Area:" = ""
  WITH outdev, ms_beg_dt, ms_end_dt,
  ms_surg_area
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_line = vc WITH protect, noconstant("")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_parse_str = vc WITH protect, noconstant(" 1=1 ")
 DECLARE ml_output_size = i4 WITH protect, noconstant(0)
 DECLARE ml_send_file = i4 WITH protect, noconstant(0)
 DECLARE ms_filename_minus_dir = vc WITH protect, constant(build("sn_trackcore_out",trim(cnvtstring(
     rand(0),20),3),"_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),".dat"))
 DECLARE ms_filename = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_sn_trackcore_out/",ms_filename_minus_dir))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_ancillary_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6011,"ANCILLARY"))
 DECLARE mf_other_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,"OTHER"))
 DECLARE mf_orgdoc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "ORGANIZATIONDOCTOR"))
 DECLARE mf_externid_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "EXTERNALIDENTIFIER"))
 DECLARE mf_addr_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE mf_phone_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE ms_ftp_path = vc WITH protect, noconstant("")
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_itm_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_pidx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_pidx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_snpdprep1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SNPDPREP1"))
 DECLARE mf_snpdprepexpdate1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPEXPDATE1"))
 DECLARE mf_snpdpreplotnumber1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPLOTNUMBER1"))
 DECLARE mf_snpdprepstart1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPSTART1"))
 DECLARE mf_snpdprepstop1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPSTOP1"))
 DECLARE mf_snpdprep2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SNPDPREP2"))
 DECLARE mf_snpdprepexpdate2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPEXPDATE2"))
 DECLARE mf_snpdpreplotnumber2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPLOTNUMBER2"))
 DECLARE mf_snpdprepstart2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPSTART2"))
 DECLARE mf_snpdprepstop2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPSTOP2"))
 DECLARE mf_snpdprep3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SNPDPREP3"))
 DECLARE mf_snpdprepexpdate3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPEXPDATE3"))
 DECLARE mf_snpdpreplotnumber3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPLOTNUMBER3"))
 DECLARE mf_snpdprepstart3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPSTART3"))
 DECLARE mf_snpdprepstop3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPSTOP3"))
 DECLARE mf_snpdpreprequired_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPREPREQUIRED"))
 DECLARE mf_snpdoutofstoragedatetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDOUTOFSTORAGEDATETIME"))
 DECLARE mf_snpdexplantreason_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDEXPLANTREASON"))
 DECLARE mf_snpdoutofstoragebyprovider_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDOUTOFSTORAGEBYPROVIDER"))
 DECLARE mf_snpdptc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SNPDPTC"))
 DECLARE mf_snpdimplantexplantdatetime_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDIMPLANTEXPLANTDATETIME"))
 DECLARE mf_snpdprocedure_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SNPDPROCEDURE"))
 DECLARE mf_snpdtype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"SNPDTYPE"))
 DECLARE ms_cr_str = vc WITH protect, constant(char(13))
 DECLARE ms_bm_str = vc WITH protect, constant(char(11))
 DECLARE ms_eom_str = vc WITH protect, constant(concat(char(28),char(13)))
 DECLARE mf_record_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_result_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_result_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_result_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_result_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 FREE RECORD scase
 RECORD scase(
   1 cnt = i4
   1 list[*]
     2 f_enctr_id = f8
     2 f_person_id = f8
     2 f_surg_case_id = f8
     2 s_person_name_first = vc
     2 s_person_name_last = vc
     2 s_person_name_middle = vc
     2 s_home_phone = vc
     2 s_addr1 = vc
     2 s_addr2 = vc
     2 s_city = vc
     2 s_state = vc
     2 s_zip = vc
     2 s_country = vc
     2 s_cmrn = vc
     2 s_fin = vc
     2 s_gender = vc
     2 s_dob = vc
     2 s_surg_case_nbr = vc
     2 s_facility = vc
     2 s_fac_msh4 = vc
     2 s_fac_msh8 = vc
     2 s_location = vc
     2 s_trans_name = vc
     2 f_prim_surgeon_id = f8
     2 s_prim_surg_other_alias = vc
     2 s_prim_surg_first_name = vc
     2 s_prim_surg_last_name = vc
     2 s_prim_surg_mid_name = vc
     2 s_surg_start_dt_tm = vc
     2 s_surg_stop_dt_tm = vc
     2 s_surg_or = vc
     2 s_msh = vc
     2 s_pid = vc
     2 s_paa = vc
     2 s_pvs = vc
     2 s_cas = vc
     2 l_bio_ind = i4
     2 s_fin_msg = vc
     2 itm[*]
       3 f_periop_doc_id = f8
       3 f_implant_log_st_id = f8
       3 s_trackcore_id = vc
       3 s_item_action = vc
       3 s_quantity = vc
       3 s_item_description = vc
       3 s_lot_number = vc
       3 s_serial_number = vc
       3 s_exp_date = vc
       3 s_procedure_code = vc
       3 f_documenter_person_id = f8
       3 s_documenter_alias = vc
       3 s_documenter_name_full = vc
       3 s_temp_check = vc
       3 s_intact = vc
       3 s_manufacturer = vc
       3 s_implant_site = vc
       3 s_implant_explant_dt_tm = vc
       3 s_prep_requirement = vc
       3 s_out_of_storage_dt = vc
       3 s_out_of_storage_alias = vc
       3 s_out_of_storage_per_name = vc
       3 s_waste_action_reason = vc
       3 s_1_prep_start_dt_tm = vc
       3 s_1_prep_stop_dt_tm = vc
       3 s_1_prep_exp_dt_tm = vc
       3 s_1_prep_lot_nbr = vc
       3 s_1_prep_res_val = vc
       3 s_2_prep_start_dt_tm = vc
       3 s_2_prep_stop_dt_tm = vc
       3 s_2_prep_exp_dt_tm = vc
       3 s_2_prep_lot_nbr = vc
       3 s_2_prep_res_val = vc
       3 s_3_prep_start_dt_tm = vc
       3 s_3_prep_stop_dt_tm = vc
       3 s_3_prep_exp_dt_tm = vc
       3 s_3_prep_lot_nbr = vc
       3 s_3_prep_res_val = vc
       3 s_proc_name = vc
       3 s_mat1 = vc
       3 s_mat2 = vc
       3 s_mat3 = vc
       3 s_itm = vc
       3 l_bio_itm = i4
     2 proc[*]
       3 f_surg_case_proc_id = f8
       3 f_proc_cat_cd = f8
       3 s_proc_description = vc
       3 s_proc_description_short = vc
       3 s_ancillary_cd = vc
       3 f_surgeon_id = f8
       3 s_surgeon_alias = vc
       3 s_surgeon_name = vc
       3 s_aip = vc
     2 attend[*]
       3 f_person_id = f8
       3 s_attend_alias = vc
       3 s_in_time1 = vc
       3 s_in_time2 = vc
       3 s_out_time1 = vc
       3 s_out_time2 = vc
       3 s_role = vc
       3 s_name_full = vc
       3 s_ais = vc
 )
 SET ms_data_type = reflect(parameter(4,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_parse_str = parameter(4,1)
  IF (size(trim(ms_parse_str)) > 0)
   IF (trim(ms_parse_str)=char(42))
    SET ms_parse_str = " 1=1 "
   ELSE
    SET ms_parse_str = concat(" sc.sched_surg_area_cd = ",trim(ms_parse_str))
   ENDIF
  ELSE
   GO TO exit_program
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = parameter(4,ml_cnt)
   IF (ml_cnt=1)
    SET ms_parse_str = concat(" sc.sched_surg_area_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_parse_str = concat(ms_parse_str,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_parse_str = concat(ms_parse_str,")")
 ENDIF
 CALL echo(ms_parse_str)
 IF (ms_outdev="OPS")
  SET ml_ops_ind = 1
  SET ms_outdev = ms_filename
  SET mf_beg_dt_tm = cnvtdatetime((curdate - 1),0)
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_BEG_DT,"mm/dd/yyyy"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DT,"mm/dd/yyyy"),235959)
 ENDIF
 CALL echo("HERE")
 SELECT INTO "nl:"
  FROM surgical_case sc,
   sn_implant_log_st sils,
   perioperative_document pd,
   person p1,
   prsnl_alias pa1,
   prsnl prl1,
   person p2,
   address a2,
   phone ph2,
   person_alias pa,
   encntr_alias ea,
   clinical_event ce,
   ce_date_result cdr,
   ce_event_prsnl cep,
   prsnl prl2,
   prsnl_alias pa4,
   mm_omf_item_master mmoim,
   person p3,
   prsnl_alias pa3
  PLAN (sc
   WHERE sc.cancel_dt_tm = null
    AND sc.encntr_id != 0)
   JOIN (sils
   WHERE sils.surg_case_id=sc.surg_case_id)
   JOIN (pd
   WHERE pd.surg_case_id=sils.surg_case_id
    AND pd.periop_doc_id=sils.periop_doc_id
    AND pd.create_dt_tm IS NOT null
    AND pd.rec_ver_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
   JOIN (mmoim
   WHERE (mmoim.item_master_id= Outerjoin(sils.item_id)) )
   JOIN (ce
   WHERE ce.encntr_id=sc.encntr_id
    AND ce.person_id=sc.person_id
    AND ce.event_cd IN (mf_snpdprep1_cd, mf_snpdprepexpdate1_cd, mf_snpdpreplotnumber1_cd,
   mf_snpdprepstart1_cd, mf_snpdprepstop1_cd,
   mf_snpdprep2_cd, mf_snpdprepexpdate2_cd, mf_snpdpreplotnumber2_cd, mf_snpdprepstart2_cd,
   mf_snpdprepstop2_cd,
   mf_snpdprep3_cd, mf_snpdprepexpdate3_cd, mf_snpdpreplotnumber3_cd, mf_snpdprepstart3_cd,
   mf_snpdprepstop3_cd,
   mf_snpdptc_cd, mf_snpdimplantexplantdatetime_cd, mf_snpdprocedure_cd, mf_snpdpreprequired_cd,
   mf_snpdoutofstoragedatetime_cd,
   mf_snpdexplantreason_cd, mf_snpdoutofstoragebyprovider_cd, mf_snpdtype_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.record_status_cd=mf_record_active_cd
    AND ce.result_status_cd IN (mf_result_active_cd, mf_result_auth_cd, mf_result_altered_cd,
   mf_result_modified_cd)
    AND ce.reference_nbr >= cnvtstring(sils.periop_doc_id,10,2,r)
    AND ce.reference_nbr < cnvtstring((sils.periop_doc_id+ 1),10,2,r)
    AND substring(1,(findstring("SN",ce.reference_nbr) - 1),ce.reference_nbr)=cnvtstring(sils
    .periop_doc_id,10,2,r)
    AND trim(cnvtstring(ce.collating_seq))=trim(cnvtstring(sils.display_seq)))
   JOIN (cdr
   WHERE (cdr.event_id= Outerjoin(ce.event_id)) )
   JOIN (cep
   WHERE (cep.event_id= Outerjoin(ce.event_id))
    AND (cep.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
    AND (cep.action_type_cd= Outerjoin(94)) )
   JOIN (prl2
   WHERE (prl2.person_id= Outerjoin(cep.action_prsnl_id)) )
   JOIN (pa4
   WHERE (pa4.person_id= Outerjoin(prl2.person_id))
    AND (pa4.active_ind= Outerjoin(1))
    AND (pa4.prsnl_alias_type_cd= Outerjoin(mf_externid_cd))
    AND (pa4.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (p1
   WHERE (p1.person_id= Outerjoin(sils.updt_id)) )
   JOIN (pa1
   WHERE (pa1.person_id= Outerjoin(p1.person_id))
    AND (pa1.active_ind= Outerjoin(1))
    AND (pa1.prsnl_alias_type_cd= Outerjoin(mf_externid_cd))
    AND (pa1.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (prl1
   WHERE (prl1.person_id= Outerjoin(p1.person_id)) )
   JOIN (p2
   WHERE p2.person_id=sc.person_id)
   JOIN (a2
   WHERE (a2.parent_entity_id= Outerjoin(p2.person_id))
    AND (a2.parent_entity_name= Outerjoin("PERSON"))
    AND (a2.active_ind= Outerjoin(1))
    AND (a2.address_type_cd= Outerjoin(mf_addr_home_cd))
    AND (a2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    AND (a2.address_type_seq= Outerjoin(1)) )
   JOIN (ph2
   WHERE (ph2.parent_entity_id= Outerjoin(p2.person_id))
    AND (ph2.parent_entity_name= Outerjoin("PERSON"))
    AND (ph2.active_ind= Outerjoin(1))
    AND (ph2.phone_type_seq= Outerjoin(1))
    AND (ph2.phone_type_cd= Outerjoin(mf_phone_home_cd))
    AND (ph2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(p2.person_id))
    AND (pa.person_alias_type_cd= Outerjoin(mf_cmrn_cd))
    AND (pa.active_ind= Outerjoin(1))
    AND (pa.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(sc.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   JOIN (p3
   WHERE p3.person_id=sc.surgeon_prsnl_id)
   JOIN (pa3
   WHERE (pa3.person_id= Outerjoin(p3.person_id))
    AND (pa3.active_ind= Outerjoin(1))
    AND (pa3.prsnl_alias_type_cd= Outerjoin(mf_orgdoc_cd))
    AND (pa3.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
  ORDER BY sc.surg_case_id, sils.implant_log_st_id
  HEAD REPORT
   scase->cnt = 0
  HEAD sc.surg_case_id
   scase->cnt += 1, stat = alterlist(scase->list,scase->cnt), scase->list[scase->cnt].f_enctr_id = sc
   .encntr_id,
   scase->list[scase->cnt].f_person_id = sc.person_id, scase->list[scase->cnt].s_person_name_first =
   trim(p2.name_first_key,3), scase->list[scase->cnt].s_person_name_last = trim(p2.name_last_key,3),
   scase->list[scase->cnt].s_person_name_middle = trim(p2.name_middle_key,3), scase->list[scase->cnt]
   .s_dob = format(p2.birth_dt_tm,"yyyymmdd"), scase->list[scase->cnt].s_gender = substring(1,1,
    uar_get_code_display(p2.sex_cd)),
   scase->list[scase->cnt].s_home_phone = trim(ph2.phone_num,3), scase->list[scase->cnt].s_addr1 =
   trim(a2.street_addr,3), scase->list[scase->cnt].s_addr2 = trim(a2.street_addr2,3),
   scase->list[scase->cnt].s_city = trim(a2.city,3), scase->list[scase->cnt].s_state = trim(a2.state,
    3), scase->list[scase->cnt].s_zip = trim(a2.zipcode,3),
   scase->list[scase->cnt].s_country = uar_get_code_display(a2.country_cd), scase->list[scase->cnt].
   s_cmrn = trim(pa.alias,3), scase->list[scase->cnt].s_fin = trim(ea.alias,3),
   scase->list[scase->cnt].f_prim_surgeon_id = sc.surgeon_prsnl_id, scase->list[scase->cnt].
   s_prim_surg_other_alias = trim(pa3.alias,3), scase->list[scase->cnt].s_prim_surg_first_name = trim
   (p3.name_first_key,3),
   scase->list[scase->cnt].s_prim_surg_last_name = trim(p3.name_last_key,3), scase->list[scase->cnt].
   s_prim_surg_mid_name = trim(p3.name_middle_key,3), scase->list[scase->cnt].s_surg_case_nbr = trim(
    sc.surg_case_nbr_formatted,3),
   scase->list[scase->cnt].f_surg_case_id = sc.surg_case_id, scase->list[scase->cnt].
   s_surg_start_dt_tm = format(sc.surg_start_dt_tm,"YYYYMMDDHHMMSS;;q"), scase->list[scase->cnt].
   s_surg_stop_dt_tm = format(sc.surg_stop_dt_tm,"YYYYMMDDHHMMSS;;q"),
   scase->list[scase->cnt].s_surg_or = uar_get_code_display(sc.surg_op_loc_cd), scase->list[scase->
   cnt].s_facility = trim(uar_get_code_display(sc.inst_cd),3), scase->list[scase->cnt].s_location =
   trim(uar_get_code_display(sc.surg_area_cd),3)
   IF (substring(1,4,sc.surg_case_nbr_formatted)="BOSC")
    scase->list[scase->cnt].s_fac_msh4 = "baystateosc3766F2E0", scase->list[scase->cnt].s_fac_msh8 =
    "baystateosc376994B0"
   ELSEIF ((scase->list[scase->cnt].s_facility="BMC"))
    scase->list[scase->cnt].s_fac_msh4 = "baystate14926F84", scase->list[scase->cnt].s_fac_msh8 =
    "baystate149CDCFF"
   ELSEIF ((scase->list[scase->cnt].s_facility="FMC"))
    scase->list[scase->cnt].s_fac_msh4 = "BAYSTATEFRANKLIN", scase->list[scase->cnt].s_fac_msh8 =
    "baystatefranklin01301"
   ELSEIF ((scase->list[scase->cnt].s_facility="ML Hospital"))
    scase->list[scase->cnt].s_fac_msh4 = "BAYSTATEML", scase->list[scase->cnt].s_fac_msh8 =
    "baystateml01082"
   ELSEIF ((scase->list[scase->cnt].s_facility="BWH"))
    scase->list[scase->cnt].s_fac_msh4 = "BWH", scase->list[scase->cnt].s_fac_msh8 = "BWHSS"
   ELSE
    scase->list[scase->cnt].s_fac_msh4 = scase->list[scase->cnt].s_facility, scase->list[scase->cnt].
    s_fac_msh8 = scase->list[scase->cnt].s_location
   ENDIF
   scase->list[scase->cnt].s_trans_name = concat(trim(cnvtstring(scase->list[scase->cnt].f_person_id,
      20),3),"_",trim(cnvtstring(scase->list[scase->cnt].f_enctr_id,20),3),"_",format(cnvtdatetime(
      sysdate),"YYYYMMDDHHMMSS;;q")), scase->list[scase->cnt].s_msh = build("MSH","|","^~\&","|","|",
    scase->list[scase->cnt].s_fac_msh4,"|","TrackCore","|","|",
    trim(format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;q"),3),"|",scase->list[scase->cnt].s_fac_msh8,
    "|","CER^CAS",
    "|",scase->list[scase->cnt].s_trans_name,"|","P","|",
    "4.1"), scase->list[scase->cnt].s_pid = build("PID","|",scase->list[scase->cnt].s_cmrn,"|",scase
    ->list[scase->cnt].s_person_name_last,
    "|",scase->list[scase->cnt].s_person_name_first,"|",scase->list[scase->cnt].s_person_name_middle,
    "|",
    scase->list[scase->cnt].s_dob,"|",scase->list[scase->cnt].s_gender,"|",scase->list[scase->cnt].
    s_home_phone,
    "|","|",scase->list[scase->cnt].s_fin),
   scase->list[scase->cnt].s_paa = build("PAA","|",scase->list[scase->cnt].s_addr1,"|",scase->list[
    scase->cnt].s_addr2,
    "|",scase->list[scase->cnt].s_city,"|",scase->list[scase->cnt].s_state,"|",
    scase->list[scase->cnt].s_zip,"|",scase->list[scase->cnt].s_country,"|","HOME"), scase->list[
   scase->cnt].s_cas = build("CAS","|","F","|",scase->list[scase->cnt].s_surg_case_nbr,
    "|",scase->list[scase->cnt].s_fin,"|",scase->list[scase->cnt].s_surg_start_dt_tm,"|",
    scase->list[scase->cnt].s_surg_stop_dt_tm,"|",scase->list[scase->cnt].s_surg_or), scase->list[
   scase->cnt].s_pvs = build("PVS","|",scase->list[scase->cnt].s_prim_surg_other_alias,"|",scase->
    list[scase->cnt].s_prim_surg_last_name,
    "|",scase->list[scase->cnt].s_prim_surg_first_name,"|",scase->list[scase->cnt].
    s_prim_surg_mid_name),
   ml_itm_cnt = 0
  HEAD sils.implant_log_st_id
   ml_itm_cnt += 1, stat = alterlist(scase->list[scase->cnt].itm,ml_itm_cnt), scase->list[scase->cnt]
   .itm[ml_itm_cnt].f_implant_log_st_id = sils.implant_log_st_id,
   scase->list[scase->cnt].itm[ml_itm_cnt].f_periop_doc_id = pd.periop_doc_id, scase->list[scase->cnt
   ].itm[ml_itm_cnt].s_intact = sils.model_number, scase->list[scase->cnt].itm[ml_itm_cnt].
   s_temp_check = sils.other_identifier,
   scase->list[scase->cnt].itm[ml_itm_cnt].s_manufacturer = sils.manufacturer, scase->list[scase->cnt
   ].itm[ml_itm_cnt].s_implant_site = sils.implant_site, scase->list[scase->cnt].itm[ml_itm_cnt].
   s_exp_date = format(sils.exp_date,"YYYYMMDD"),
   scase->list[scase->cnt].itm[ml_itm_cnt].s_item_action = sils.ecri_device_code, scase->list[scase->
   cnt].itm[ml_itm_cnt].s_quantity = cnvtstring(sils.quantity), scase->list[scase->cnt].itm[
   ml_itm_cnt].s_lot_number = sils.lot_number,
   scase->list[scase->cnt].itm[ml_itm_cnt].s_serial_number = sils.serial_number, scase->list[scase->
   cnt].itm[ml_itm_cnt].f_documenter_person_id = sils.updt_id
   IF (size(trim(pa1.alias,3))=0)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_documenter_alias = trim(prl1.username,3)
   ELSE
    scase->list[scase->cnt].itm[ml_itm_cnt].s_documenter_alias = trim(pa1.alias,3)
   ENDIF
   scase->list[scase->cnt].itm[ml_itm_cnt].s_documenter_name_full = p1.name_full_formatted, scase->
   list[scase->cnt].itm[ml_itm_cnt].s_item_description = mmoim.description
  DETAIL
   IF (ce.event_cd=mf_snpdprepstart1_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_start_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprepstop1_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_stop_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprepexpdate1_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_exp_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDD;;q")
   ELSEIF (ce.event_cd=mf_snpdpreplotnumber1_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_lot_nbr = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdprep1_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_res_val = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdprepstart2_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_start_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprepstop2_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_stop_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprepexpdate2_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_exp_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDD;;q")
   ELSEIF (ce.event_cd=mf_snpdpreplotnumber2_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_lot_nbr = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdprep2_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_res_val = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdprepstart3_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_start_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprepstop3_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_stop_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprepexpdate3_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_exp_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDD;;q")
   ELSEIF (ce.event_cd=mf_snpdpreplotnumber3_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_lot_nbr = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdprep3_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_res_val = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdptc_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_trackcore_id = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdimplantexplantdatetime_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_implant_explant_dt_tm = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdprocedure_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_proc_name = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdpreprequired_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_prep_requirement = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdoutofstoragedatetime_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_out_of_storage_dt = format(cdr.result_dt_tm,
     "YYYYMMDDHHMMSS;;q")
   ELSEIF (ce.event_cd=mf_snpdexplantreason_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_waste_action_reason = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_snpdtype_cd)
    IF (trim(ce.result_val,3)="Biological")
     scase->list[scase->cnt].itm[ml_itm_cnt].l_bio_itm = 1, scase->list[scase->cnt].l_bio_ind = 1
    ENDIF
   ELSEIF (ce.event_cd=mf_snpdoutofstoragebyprovider_cd)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_out_of_storage_per_name = prl2.name_full_formatted
    IF (size(trim(pa4.alias,3))=0)
     scase->list[scase->cnt].itm[ml_itm_cnt].s_out_of_storage_alias = trim(prl2.username,3)
    ELSE
     scase->list[scase->cnt].itm[ml_itm_cnt].s_out_of_storage_alias = trim(pa4.alias,3)
    ENDIF
   ENDIF
  FOOT  sils.implant_log_st_id
   IF (size(trim(scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_res_val,3)) > 0)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_mat1 = build("MAT","|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_trackcore_id,"|",scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_res_val,
     "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_lot_nbr,"|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_1_prep_exp_dt_tm,"|",
     scase->list[scase->cnt].itm[ml_itm_cnt].s_1_prep_start_dt_tm,"|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_1_prep_stop_dt_tm)
   ENDIF
   IF (size(trim(scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_res_val,3)) > 0)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_mat2 = build("MAT","|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_trackcore_id,"|",scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_res_val,
     "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_lot_nbr,"|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_2_prep_exp_dt_tm,"|",
     scase->list[scase->cnt].itm[ml_itm_cnt].s_2_prep_start_dt_tm,"|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_2_prep_stop_dt_tm)
   ENDIF
   IF (size(trim(scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_res_val,3)) > 0)
    scase->list[scase->cnt].itm[ml_itm_cnt].s_mat3 = build("MAT","|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_trackcore_id,"|",scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_res_val,
     "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_lot_nbr,"|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_3_prep_exp_dt_tm,"|",
     scase->list[scase->cnt].itm[ml_itm_cnt].s_3_prep_start_dt_tm,"|",scase->list[scase->cnt].itm[
     ml_itm_cnt].s_3_prep_stop_dt_tm)
   ENDIF
   scase->list[scase->cnt].itm[ml_itm_cnt].s_itm = build("ITM","|","<<procedure_code>>","|",scase->
    list[scase->cnt].itm[ml_itm_cnt].s_trackcore_id,
    "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_item_action,"|",scase->list[scase->cnt].itm[
    ml_itm_cnt].s_quantity,"|",
    scase->list[scase->cnt].itm[ml_itm_cnt].s_item_description,"|",scase->list[scase->cnt].itm[
    ml_itm_cnt].s_lot_number,"|",scase->list[scase->cnt].itm[ml_itm_cnt].s_serial_number,
    "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_implant_explant_dt_tm,"|",scase->list[scase->cnt].
    itm[ml_itm_cnt].s_exp_date,"|",
    scase->list[scase->cnt].itm[ml_itm_cnt].s_documenter_alias,"|",scase->list[scase->cnt].itm[
    ml_itm_cnt].s_documenter_name_full,"|",scase->list[scase->cnt].itm[ml_itm_cnt].s_intact,
    "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_temp_check,"|","|",scase->list[scase->cnt].itm[
    ml_itm_cnt].s_prep_requirement,
    "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_out_of_storage_dt,"|",scase->list[scase->cnt].itm[
    ml_itm_cnt].s_out_of_storage_alias,"|",
    scase->list[scase->cnt].itm[ml_itm_cnt].s_out_of_storage_per_name,"|",scase->list[scase->cnt].
    itm[ml_itm_cnt].s_waste_action_reason,"|",scase->list[scase->cnt].itm[ml_itm_cnt].s_implant_site,
    "|",scase->list[scase->cnt].itm[ml_itm_cnt].s_manufacturer,"|","|","|",
    "|","|","|")
  WITH nocounter
 ;end select
 IF ((scase->cnt > 0))
  SELECT INTO "nl:"
   FROM surg_case_procedure scp,
    order_catalog_synonym ocs,
    order_catalog_synonym ocs2,
    order_catalog oc,
    prsnl p,
    prsnl_alias pa,
    prsnl_alias pa2
   PLAN (scp
    WHERE expand(ml_idx,1,scase->cnt,scp.surg_case_id,scase->list[ml_idx].f_surg_case_id)
     AND scp.active_ind=1
     AND scp.primary_surgeon_id != 0.0)
    JOIN (ocs
    WHERE (ocs.synonym_id= Outerjoin(scp.synonym_id)) )
    JOIN (oc
    WHERE (oc.catalog_cd= Outerjoin(ocs.catalog_cd)) )
    JOIN (ocs2
    WHERE (ocs2.catalog_cd= Outerjoin(ocs.catalog_cd))
     AND (ocs2.mnemonic_type_cd= Outerjoin(mf_ancillary_cd))
     AND (ocs2.active_ind= Outerjoin(1)) )
    JOIN (p
    WHERE (p.person_id= Outerjoin(scp.primary_surgeon_id)) )
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.prsnl_alias_type_cd= Outerjoin(mf_orgdoc_cd))
     AND (pa.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
    JOIN (pa2
    WHERE (pa2.person_id= Outerjoin(p.person_id))
     AND (pa2.active_ind= Outerjoin(1))
     AND (pa2.prsnl_alias_type_cd= Outerjoin(mf_externid_cd))
     AND (pa2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   ORDER BY scp.surg_case_id, scp.surg_case_proc_id, ocs2.mnemonic
   HEAD REPORT
    ml_idx2 = 0
   HEAD scp.surg_case_id
    ml_idx2 = locateval(ml_idx,1,scase->cnt,scp.surg_case_id,scase->list[ml_idx].f_surg_case_id),
    CALL echo(ml_idx2), ml_cnt = 0
   HEAD scp.surg_case_proc_id
    ml_pidx2 = 0, ml_cnt += 1, stat = alterlist(scase->list[ml_idx2].proc,ml_cnt),
    scase->list[ml_idx2].proc[ml_cnt].f_surg_case_proc_id = scp.surg_case_proc_id, scase->list[
    ml_idx2].proc[ml_cnt].s_proc_description = trim(oc.primary_mnemonic,3), scase->list[ml_idx2].
    proc[ml_cnt].s_proc_description_short = trim(uar_get_code_display(oc.catalog_cd),3),
    scase->list[ml_idx2].proc[ml_cnt].f_proc_cat_cd = ocs.catalog_cd
    IF (isnumeric(substring(1,8,trim(ocs2.mnemonic,3))) > 0)
     scase->list[ml_idx2].proc[ml_cnt].s_ancillary_cd = substring(1,8,trim(ocs2.mnemonic,3))
    ENDIF
    scase->list[ml_idx2].proc[ml_cnt].f_surgeon_id = scp.primary_surgeon_id
    IF (size(trim(pa.alias,3))=0)
     scase->list[ml_idx2].proc[ml_cnt].s_surgeon_alias = trim(pa2.alias,3)
    ELSE
     scase->list[ml_idx2].proc[ml_cnt].s_surgeon_alias = trim(pa.alias,3)
    ENDIF
    scase->list[ml_idx2].proc[ml_cnt].s_surgeon_name = trim(p.name_full_formatted,3)
   FOOT  scp.surg_case_proc_id
    FOR (ml_pidx2 = 1 TO size(scase->list[ml_idx2].itm,5))
      IF ((scase->list[ml_idx2].proc[ml_cnt].s_proc_description_short=scase->list[ml_idx2].itm[
      ml_pidx2].s_proc_name))
       scase->list[ml_idx2].itm[ml_pidx2].s_itm = replace(scase->list[ml_idx2].itm[ml_pidx2].s_itm,
        "<<procedure_code>>",scase->list[ml_idx2].proc[ml_cnt].s_ancillary_cd)
      ENDIF
    ENDFOR
    scase->list[ml_idx2].proc[ml_cnt].s_aip = build("AIP","|",scase->list[ml_idx2].proc[ml_cnt].
     s_ancillary_cd,"|",scase->list[ml_idx2].proc[ml_cnt].s_proc_description,
     "|",scase->list[ml_idx2].proc[ml_cnt].s_surgeon_alias,"|",scase->list[ml_idx2].proc[ml_cnt].
     s_surgeon_name)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM case_attendance ca,
    prsnl p,
    prsnl_alias pa,
    prsnl_alias pa2
   PLAN (ca
    WHERE expand(ml_idx,1,scase->cnt,ca.surg_case_id,scase->list[ml_idx].f_surg_case_id)
     AND ca.active_ind=1
     AND ca.in_dt_tm IS NOT null)
    JOIN (p
    WHERE p.person_id=ca.case_attendee_id)
    JOIN (pa
    WHERE (pa.person_id= Outerjoin(p.person_id))
     AND (pa.active_ind= Outerjoin(1))
     AND (pa.prsnl_alias_type_cd= Outerjoin(mf_orgdoc_cd))
     AND (pa.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
    JOIN (pa2
    WHERE (pa2.person_id= Outerjoin(p.person_id))
     AND (pa2.active_ind= Outerjoin(1))
     AND (pa2.prsnl_alias_type_cd= Outerjoin(mf_externid_cd))
     AND (pa2.end_effective_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))) )
   ORDER BY ca.surg_case_id, ca.case_attendance_id
   HEAD REPORT
    ml_idx2 = 0
   HEAD ca.surg_case_id
    ml_idx2 = locateval(ml_idx,1,scase->cnt,ca.surg_case_id,scase->list[ml_idx].f_surg_case_id),
    ml_cnt = 0
   HEAD ca.case_attendance_id
    ml_cnt += 1, stat = alterlist(scase->list[ml_idx2].attend,ml_cnt), scase->list[ml_idx2].attend[
    ml_cnt].f_person_id = p.person_id,
    scase->list[ml_idx2].attend[ml_cnt].s_name_full = trim(p.name_full_formatted,3), scase->list[
    ml_idx2].attend[ml_cnt].s_role = trim(uar_get_code_display(ca.role_perf_cd),3)
    IF ((scase->list[ml_idx2].attend[ml_cnt].s_role="Circulator"))
     scase->list[ml_idx2].attend[ml_cnt].s_role = "RN Circulator"
    ENDIF
    IF (size(trim(pa.alias,3)) > 0)
     scase->list[ml_idx2].attend[ml_cnt].s_attend_alias = format(trim(pa.alias,3),"#####;P0")
    ELSE
     IF (substring(1,2,trim(p.username,3)) IN ("SN", "EN", "CN"))
      scase->list[ml_idx2].attend[ml_cnt].s_attend_alias = trim(p.username,3)
     ELSEIF (substring(1,3,trim(p.username,3)) IN ("NA-"))
      scase->list[ml_idx2].attend[ml_cnt].s_attend_alias = substring(4,7,trim(p.username,3))
     ELSEIF (size(trim(pa2.alias,3)) > 0)
      scase->list[ml_idx2].attend[ml_cnt].s_attend_alias = trim(pa2.alias)
     ELSE
      scase->list[ml_idx2].attend[ml_cnt].s_attend_alias = "UNKWN"
     ENDIF
    ENDIF
   DETAIL
    IF (size(trim(scase->list[ml_idx2].attend[ml_cnt].s_in_time1,3)) > 0)
     scase->list[ml_idx2].attend[ml_cnt].s_in_time2 = format(ca.in_dt_tm,"YYYYMMDDHHMMSS;;q"), scase
     ->list[ml_idx2].attend[ml_cnt].s_out_time2 = format(ca.out_dt_tm,"YYYYMMDDHHMMSS;;q")
    ELSE
     scase->list[ml_idx2].attend[ml_cnt].s_in_time1 = format(ca.in_dt_tm,"YYYYMMDDHHMMSS;;q"), scase
     ->list[ml_idx2].attend[ml_cnt].s_out_time1 = format(ca.out_dt_tm,"YYYYMMDDHHMMSS;;q")
    ENDIF
   FOOT  ca.case_attendance_id
    scase->list[ml_idx2].attend[ml_cnt].s_ais = build("AIS","|",scase->list[ml_idx2].attend[ml_cnt].
     s_attend_alias,"|",scase->list[ml_idx2].attend[ml_cnt].s_name_full,
     "|",scase->list[ml_idx2].attend[ml_cnt].s_role,"|",scase->list[ml_idx2].attend[ml_cnt].
     s_in_time1,"|",
     scase->list[ml_idx2].attend[ml_cnt].s_out_time1,"|",scase->list[ml_idx2].attend[ml_cnt].
     s_in_time2,"|",scase->list[ml_idx2].attend[ml_cnt].s_out_time2,
     "|","|")
   WITH nocounter
  ;end select
 ENDIF
 IF ((scase->cnt > 0))
  FOR (ml_cnt = 1 TO scase->cnt)
    IF ((scase->list[ml_cnt].l_bio_ind=1))
     SET ml_send_file = 1
     SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_msh,ms_cr_str,scase->list[
      ml_cnt].s_pid,ms_cr_str,scase->list[ml_cnt].s_paa,
      ms_cr_str,scase->list[ml_cnt].s_pvs,ms_cr_str,scase->list[ml_cnt].s_cas)
     IF (size(scase->list[ml_cnt].proc,5) > 0)
      FOR (ml_idx = 1 TO size(scase->list[ml_cnt].proc,5))
        SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str,scase->
         list[ml_cnt].proc[ml_idx].s_aip)
      ENDFOR
     ENDIF
     IF (size(scase->list[ml_cnt].itm,5) > 0)
      FOR (ml_idx = 1 TO size(scase->list[ml_cnt].itm,5))
        IF ((scase->list[ml_cnt].itm[ml_idx].l_bio_itm=1))
         SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str,scase->
          list[ml_cnt].itm[ml_idx].s_itm)
         IF (size(scase->list[ml_cnt].itm[ml_idx].s_mat1) > 0)
          SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str,scase->
           list[ml_cnt].itm[ml_idx].s_mat1)
         ENDIF
         IF (size(scase->list[ml_cnt].itm[ml_idx].s_mat2) > 0)
          SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str,scase->
           list[ml_cnt].itm[ml_idx].s_mat2)
         ENDIF
         IF (size(scase->list[ml_cnt].itm[ml_idx].s_mat3) > 0)
          SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str,scase->
           list[ml_cnt].itm[ml_idx].s_mat3)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (size(scase->list[ml_cnt].attend,5) > 0)
      FOR (ml_idx = 1 TO size(scase->list[ml_cnt].attend,5))
        SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str,scase->
         list[ml_cnt].attend[ml_idx].s_ais)
      ENDFOR
     ENDIF
     SET scase->list[ml_cnt].s_fin_msg = concat(scase->list[ml_cnt].s_fin_msg,ms_cr_str)
     SET ml_output_size = (size(scase->list[ml_cnt].s_fin_msg)+ 1)
     SELECT INTO value(ms_filename)
      FROM (dummyt d  WITH seq = 1)
      DETAIL
       CALL print(scase->list[ml_cnt].s_fin_msg)
      WITH nocounter, maxcol = value(ml_output_size), format,
       append, noheading
     ;end select
    ENDIF
  ENDFOR
  IF (ml_send_file=1)
   SET ms_dclcom = concat("cp ",ms_filename," ",trim(logical("BHSCUST"),3),"/surginet/trackcore/",
    ms_filename_minus_dir)
   CALL echo(ms_dclcom)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ENDIF
 ENDIF
 CALL echorecord(scase)
#exit_program
END GO
