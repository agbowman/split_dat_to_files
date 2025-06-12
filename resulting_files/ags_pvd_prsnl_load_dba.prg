CREATE PROGRAM ags_pvd_prsnl_load:dba
 PROMPT
  "TASK_ID (0.0) = " = 0.0
  WITH dtid
 SET ags_pvd_prsnl_load_mod = "002 09/11/06"
 CALL echo("<===== AGS_PVD_PRSNL_LOAD Begin =====>")
 CALL echo(build("MOD:",ags_pvd_prsnl_load_mod))
 DECLARE define_logging_sub = i2 WITH public, noconstant(false)
 FREE RECORD contribrec
 RECORD contribrec(
   1 qual_cnt = i4
   1 qual[*]
     2 sending_facility = vc
     2 contributor_system_cd = f8
     2 contributor_source_cd = f8
     2 prsnl_person_id = f8
     2 time_zone = vc
     2 time_zone_idx = i4
     2 provdir_link_alias_pool_cd = f8
     2 provdir_link_alias_type_cd = f8
     2 provdir_alias_pool_cd = f8
     2 provdir_alias_type_cd = f8
     2 ext_alias_pool_cd = f8
     2 ext_alias_type_cd = f8
     2 ssn_alias_pool_cd = f8
     2 ssn_alias_type_cd = f8
     2 dea_alias_pool_cd = f8
     2 dea_alias_type_cd = f8
     2 upin_alias_pool_cd = f8
     2 upin_alias_type_cd = f8
     2 ext_link_alias_pool_cd = f8
     2 ext_link_alias_type_cd = f8
     2 med_alias_pool_cd = f8
     2 med_alias_type_cd = f8
 )
 FREE RECORD holdrec
 RECORD holdrec(
   1 qual_cnt = i4
   1 qual[*]
     2 provdir_link_alias = vc
     2 primary_idx = i4
     2 stat_flag = i2
     2 prsnl_cnt = i4
     2 prsnl[*]
       3 ags_prsnl_data_id = f8
       3 contrib_sys_idx = i4
       3 person_id = f8
       3 provdir_alias = vc
       3 ext_alias = vc
       3 ssn_alias = vc
       3 dea_alias = vc
       3 upin_alias = vc
       3 med_alias = vc
       3 ext_link_alias = vc
       3 ext_org_alias = vc
       3 alt_alias1_idx = i4
       3 alt_alias1 = vc
       3 alt_alias1_type = vc
       3 alt_alias2_idx = i4
       3 alt_alias2 = vc
       3 alt_alias2_type = vc
       3 name_first = vc
       3 name_middle = vc
       3 name_last = vc
       3 name_full = vc
       3 name_degree = vc
       3 name_title = vc
       3 birth_dt_tm = dq8
       3 sex_cd = f8
       3 address_id = f8
       3 street_addr = vc
       3 street_addr2 = vc
       3 city = vc
       3 state = vc
       3 state_cd = f8
       3 county = vc
       3 county_cd = f8
       3 country = vc
       3 country_cd = f8
       3 zipcode = vc
       3 bus_phone_id = f8
       3 phone_business = vc
       3 fax_phone_id = f8
       3 phone_fax = vc
       3 specialty = vc
       3 specialty_desc = vc
       3 stat_flag = i2
       3 stat_msg = vc
 )
 FREE RECORD laststaterec
 RECORD laststaterec(
   1 qual_cnt = i4
   1 qual[*]
     2 found_ind = i2
     2 ags_prsnl_data_id = f8
     2 provdir_link_alias = vc
     2 provdir_alias = vc
     2 ssn_alias = vc
     2 ext_alias = vc
     2 dea_alias = vc
     2 upin_alias = vc
     2 ext_link_alias = vc
     2 med_alias = vc
     2 alt_alias1 = vc
     2 alt_alias1_type = vc
     2 alt_alias2 = vc
     2 alt_alias2_type = vc
     2 provdir_link_alias_change_ind = i2
     2 ssn_alias_change_ind = i2
     2 ext_alias_change_ind = i2
     2 dea_alias_change_ind = i2
     2 upin_alias_change_ind = i2
     2 ext_link_alias_change_ind = i2
     2 med_alias_change_ind = i2
     2 alt_alias1_change_ind = i2
     2 alt_alias2_change_ind = i2
     2 address_id = f8
     2 street_addr = vc
     2 street_addr2 = vc
     2 city = vc
     2 state = vc
     2 county = vc
     2 country = vc
     2 zipcode = vc
     2 address_change_ind = i2
     2 add_back_address_ind = i2
     2 bus_phone_id = f8
     2 phone_business = vc
     2 phone_change_ind = i2
     2 add_back_phone_ind = i2
     2 fax_phone_id = f8
     2 phone_fax = vc
     2 fax_change_ind = i2
     2 add_back_fax_ind = i2
 )
 FREE RECORD altaliasrec
 RECORD altaliasrec(
   1 qual_cnt = i4
   1 qual[*]
     2 contrib_sys_idx = i4
     2 esi_alias_type = vc
     2 alt_alias_pool_cd = f8
     2 alt_alias_type_cd = f8
 )
 FREE RECORD linkaliasrec
 RECORD linkaliasrec(
   1 qual_cnt = i4
   1 qual[*]
     2 provdir_link_alias = vc
 )
 FREE RECORD aliasrec
 RECORD aliasrec(
   1 qual_cnt = i4
   1 qual[*]
     2 action_flag = i2
     2 alt_alias_ind = i2
     2 esi_alias_type = vc
     2 alias = vc
     2 alias_pool_cd = f8
     2 prsnl_alias_type_cd = f8
   1 qual2_cnt = i4
   1 qual2[*]
     2 action_flag = i2
     2 alias = vc
     2 alias_pool_cd = f8
     2 person_alias_type_cd = f8
 )
 FREE RECORD prevplarec
 RECORD prevplarec(
   1 qual_cnt = i4
   1 qual[*]
     2 provdir_alias = vc
 )
 IF (validate(log,"!")="!")
  EXECUTE cclseclogin2
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  FREE RECORD email
  RECORD email(
    1 qual_knt = i4
    1 qual[*]
      2 address = vc
      2 send_flag = i2
  )
  RECORD log(
    1 qual_knt = i4
    1 qual[*]
      2 smsgtype = c12
      2 dmsg_dt_tm = dq8
      2 smsg = vc
  )
  SET define_logging_sub = true
  DECLARE gen_nbr_error = i2 WITH public, noconstant(3)
  DECLARE insert_error = i2 WITH public, noconstant(4)
  DECLARE update_error = i2 WITH public, noconstant(5)
  DECLARE delete_error = i2 WITH public, noconstant(6)
  DECLARE select_error = i2 WITH public, noconstant(7)
  DECLARE lock_error = i2 WITH public, noconstant(8)
  DECLARE input_error = i2 WITH public, noconstant(9)
  DECLARE exe_error = i2 WITH public, noconstant(10)
  DECLARE failed = i2 WITH public, noconstant(false)
  DECLARE table_name = c50 WITH public, noconstant(" ")
  DECLARE serrmsg = vc WITH public, noconstant(" ")
  DECLARE ierrcode = i2 WITH public, noconstant(0)
  DECLARE ilog_status = i2 WITH public, noconstant(0)
  DECLARE sstatus_email = vc WITH public, noconstant("")
  DECLARE sstatus_file_name = vc WITH public, constant(concat("ags_result_load_",format(cnvtdatetime(
      curdate,curtime3),"yyyymmddhhmm;;q"),".log"))
 ENDIF
 DECLARE dtaskid = f8 WITH public, constant(cnvtreal( $DTID))
 DECLARE staskid = vc WITH public, constant(trim(cnvtstring(dtaskid)))
 DECLARE einsert = i2 WITH public, constant(1)
 DECLARE eupdate = i2 WITH public, constant(2)
 DECLARE edelete = i2 WITH public, constant(3)
 DECLARE ecomplete = i2 WITH public, constant(0)
 DECLARE eerror = i2 WITH public, constant(1)
 DECLARE ehold = i2 WITH public, constant(2)
 DECLARE bmigrate = i2 WITH public, noconstant(0)
 DECLARE berror = i2 WITH public, noconstant(0)
 DECLARE bnewpa = i2 WITH public, noconstant(0)
 DECLARE bnewpla = i2 WITH public, noconstant(0)
 DECLARE baddalt = i2 WITH public, noconstant(0)
 DECLARE bprovdirfound = i2 WITH public, noconstant(0)
 DECLARE bprsnlmigcomplete = i2 WITH public, noconstant(0)
 DECLARE lidx = i4 WITH public, noconstant(0)
 DECLARE lidx2 = i4 WITH public, noconstant(0)
 DECLARE lidx3 = i4 WITH public, noconstant(0)
 DECLARE lnum = i4 WITH public, noconstant(0)
 DECLARE lpos = i4 WITH public, noconstant(0)
 DECLARE lcount = i4 WITH public, noconstant(0)
 DECLARE lavgsec = i4 WITH public, noconstant(0)
 DECLARE litcount = i4 WITH public, noconstant(0)
 DECLARE lrowcnt = i4 WITH public, noconstant(0)
 DECLARE ltaskcnt = i4 WITH public, noconstant(0)
 DECLARE laltidx = i4 WITH public, noconstant(0)
 DECLARE lbatchsize = i4 WITH public, noconstant(0)
 DECLARE lloopcnt = i4 WITH public, noconstant(0)
 DECLARE lexpandcnt = i4 WITH public, noconstant(200)
 DECLARE ldummytcnt = i4 WITH public, noconstant(0)
 DECLARE lstart = i4 WITH public, noconstant(0)
 DECLARE ldefaultbatchsize = i4 WITH public, constant(1000)
 DECLARE ljobcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE lcontribsysidx = i4 WITH public, noconstant(0)
 DECLARE lloglevel = i2 WITH public, noconstant(0)
 DECLARE lkillind = i2 WITH public, noconstant(0)
 DECLARE lmodeflag = i2 WITH public, noconstant(0)
 DECLARE lssnmultind = i2 WITH public, noconstant(0)
 DECLARE dprimarypid = f8 WITH public, noconstant(0.0)
 DECLARE dplapoolcd = f8 WITH public, noconstant(0.0)
 DECLARE dplatypecd = f8 WITH public, noconstant(0.0)
 DECLARE dagsjobid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchstartid = f8 WITH public, noconstant(0.0)
 DECLARE dbatchendid = f8 WITH public, noconstant(0.0)
 DECLARE dstatecd = f8 WITH public, noconstant(0.0)
 DECLARE dcountycd = f8 WITH public, noconstant(0.0)
 DECLARE dcountrycd = f8 WITH public, noconstant(0.0)
 DECLARE dprovdirlinkaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PRSNLLNKUUID"))
 DECLARE dprovdiraliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PRSNLUUID"))
 DECLARE dextaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLEXTALIAS"
   ))
 DECLARE dssnaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PRSNSSN"))
 DECLARE ddeaaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLDEA"))
 DECLARE dupinaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLUPIN"))
 DECLARE dlinkaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,
   "PSNLLNKALIAS"))
 DECLARE dmedaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLMEDICAID"
   ))
 DECLARE daltaliasfieldcd = f8 WITH public, constant(uar_get_code_by("MEANING",4001891,"PSNLALTALIAS"
   ))
 DECLARE dssnpersonaliastypecd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE ddefaultsrccd = f8 WITH public, constant(uar_get_code_by("MEANING",73,"DEFAULT"))
 DECLARE dpersonpersontypecd = f8 WITH public, constant(uar_get_code_by("MEANING",302,"PERSON"))
 DECLARE duserprsnltypecd = f8 WITH public, constant(uar_get_code_by("MEANING",309,"USER"))
 DECLARE dauthdatastatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dactiveactivestatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dinactiveactivestatuscd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE dworkaddtypecd = f8 WITH public, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 DECLARE dworkphonetypecd = f8 WITH public, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE dfaxphonetypecd = f8 WITH public, constant(uar_get_code_by("MEANING",43,"FAX BUS"))
 DECLARE dusphoneformatcd = f8 WITH public, constant(uar_get_code_by("MEANING",281,"US"))
 DECLARE dprsnlnametypecd = f8 WITH public, constant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE dcurrentnametypecd = f8 WITH public, constant(uar_get_code_by("MEANING",213,"CURRENT"))
 DECLARE dmalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE dfemalesexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE dunknownsexcd = f8 WITH public, constant(uar_get_code_by("MEANING",57,"UNKNOWN"))
 DECLARE ssendingfacility = vc WITH public, noconstant(" ")
 DECLARE sproviderlinkalias = vc WITH public, noconstant(" ")
 DECLARE sprovdiralias = vc WITH public, noconstant(" ")
 DECLARE sextalias = vc WITH public, noconstant(" ")
 DECLARE sssnalias = vc WITH public, noconstant(" ")
 DECLARE sgender = vc WITH public, noconstant(" ")
 DECLARE sstatusmsg = vc WITH public, noconstant(" ")
 DECLARE dtmax = dq8 WITH public, constant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 DECLARE dtcurrent = dq8 WITH public, constant(cnvtdatetime(curdate,curtime2))
 DECLARE dtitstart = dq8 WITH public, noconstant
 DECLARE dtitend = dq8 WITH public, noconstant
 DECLARE dtestcompletion = dq8 WITH public, noconstant
 IF (dprovdirlinkaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dProvdirLinkAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dProvdirLinkAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PRSNLLNKUUID invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dprovdiraliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dProvdirAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dProvdirAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PRSNLUUID invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dextaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dEXTAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dEXTAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PRSNEXTALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dssnaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dSSNAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dSSNAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PRSNSSN invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ddeaaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dDEAAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dDEAAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PSNLDEA invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dupinaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dUPINAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dUPINAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PSNLUPIN invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dlinkaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dLinkAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dLinkAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PSNLLNKALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dmedaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dMedAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dMedAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PSNLMEDICAID invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (daltaliasfieldcd < 1)
  SET failed = select_error
  SET table_name = "dAltAliasFieldCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dAltAliasFieldCd :: Select Error :: CODE_VALUE for CDF_MEANING PSNLALTALIAS invalid from CODE_SET 4001891"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dssnpersonaliastypecd < 1)
  SET failed = select_error
  SET table_name = "dSSNPersonAliasTypeCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dSSNPersonAliasTypeCd :: Select Error :: CODE_VALUE for CDF_MEANING SSN invalid from CODE_SET 4"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dworkaddtypecd < 1)
  SET failed = select_error
  SET table_name = "dWorkAddTypeCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dWorkAddTypeCd :: Select Error :: CODE_VALUE for CDF_MEANING BUSINESS invalid from CODE_SET 212"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dworkphonetypecd < 1)
  SET failed = select_error
  SET table_name = "dWorkPhoneTypeCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dWorkPhoneTypeCd :: Select Error :: CODE_VALUE for CDF_MEANING FAX BUS invalid from CODE_SET 43"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dfaxphonetypecd < 1)
  SET failed = select_error
  SET table_name = "dFaxPhoneTypeCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dFaxPhoneTypeCd :: Select Error :: CODE_VALUE for CDF_MEANING FAX BUS invalid from CODE_SET 43"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (dusphoneformatcd < 1)
  SET failed = select_error
  SET table_name = "dUSPhoneFormatCd"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg =
  "dUSPhoneFormatCd :: Select Error :: CODE_VALUE for CDF_MEANING US invalid from CODE_SET 281"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="AGS"
    AND d.info_name="PROVIDER_DIRECTORY")
  DETAIL
   bprovdirfound = true
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DM_INFO Check for PROVIDER_DIRECTORY :: ErrMsg :: ",
   trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT (bprovdirfound))
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "DM_INFO :: PROVIDER_DIRECTORY not installed!!"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="AGS"
    AND d.info_name="PRSNL_MIGRATION")
  DETAIL
   bprsnlmigcomplete = d.info_number
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("DM_INFO Check for PRSNL_MIGRATION :: ErrMsg :: ",trim(
    serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF ( NOT (bprsnlmigcomplete))
  SET failed = select_error
  SET table_name = "DM_INFO"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "DM_INFO :: PRSNL_MIGRATION is not Complete!!"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get AGS_TASK & AGS_JOB Info")
 CALL echo("***")
 CALL echo(build("dTaskId:",dtaskid))
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j,
   ags_task t2
  PLAN (t
   WHERE t.ags_task_id=dtaskid)
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
   JOIN (t2
   WHERE t2.ags_job_id=j.ags_job_id)
  ORDER BY j.ags_job_id, t2.ags_task_id
  HEAD j.ags_job_id
   dagsjobid = j.ags_job_id, ljobcontribsysidx = (contribrec->qual_cnt+ 1), contribrec->qual_cnt =
   ljobcontribsysidx,
   stat = alterlist(contribrec->qual,ljobcontribsysidx), contribrec->qual[ljobcontribsysidx].
   sending_facility = trim(j.sending_system)
  HEAD t2.ags_task_id
   ltaskcnt = (ltaskcnt+ 1)
   IF (t2.iteration_start_id > 0.0)
    dbatchstartid = t2.iteration_start_id
   ELSE
    dbatchstartid = t2.batch_start_id
   ENDIF
   dbatchendid = t2.batch_end_id
   IF (t2.batch_size > 0)
    lbatchsize = t2.batch_size
   ELSE
    lbatchsize = ldefaultbatchsize
   ENDIF
   lmodeflag = t2.mode_flag, lkillind = t2.kill_ind, lloglevel = t2.timers_flag
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (curqual < 1)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("INVALID TASK_ID :: ",staskid)
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (ltaskcnt > 1)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "PROVDIR_MIGRATION :: ONLY 1 TASK IS ALLOWED"
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lloglevel > 0)
  CALL turn_on_tracing(null)
 ELSE
  CALL turn_off_tracing(null)
 ENDIF
 CALL echo(build("bPrsnlMigComplete: ",bprsnlmigcomplete))
 CALL echo(build("dBatchStartId    : ",dbatchstartid))
 CALL echo(build("dBatchEndId      : ",dbatchendid))
 CALL echo(build("lModeFlag        : ",lmodeflag))
 CALL echo(build("lKillInd         : ",lkillind))
 CALL echo(build("lLogLevel        : ",lloglevel))
 IF (lexpandcnt > lbatchsize)
  SET lexpandcnt = lbatchsize
 ENDIF
 SELECT DISTINCT INTO "nl:"
  a.provdir_link_alias
  FROM ags_prsnl_data a
  WHERE a.ags_job_id=dagsjobid
   AND a.ags_prsnl_data_id >= dbatchstartid
   AND ((a.person_id+ 0)=0.0)
   AND trim(a.status) != "COMPLETE"
  HEAD REPORT
   lcount = 0
  DETAIL
   lcount = (lcount+ 1)
   IF (mod(lcount,lbatchsize)=1)
    linkaliasrec->qual_cnt = (lcount+ (lbatchsize - 1)), stat = alterlist(linkaliasrec->qual,
     linkaliasrec->qual_cnt)
   ENDIF
   linkaliasrec->qual[lcount].provdir_link_alias = a.provdir_link_alias
  FOOT REPORT
   FOR (lidx = (lcount+ 1) TO linkaliasrec->qual_cnt)
     linkaliasrec->qual[lidx].provdir_link_alias = linkaliasrec->qual[lcount].provdir_link_alias
   ENDFOR
   lloopcnt = ceil((cnvtreal(linkaliasrec->qual_cnt)/ lbatchsize)), ldummytcnt = ceil((cnvtreal(
     lbatchsize)/ lexpandcnt))
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_TASK"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"INVALID TASK_ID :: ",staskid
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (lloglevel > 1)
  CALL echo("/-------------------- LinkAliasRec Begin --------------------------------/")
  CALL echorecord(linkaliasrec)
  CALL echo("/--------------------- LinkAliasRec End ---------------------------------/")
 ENDIF
 CALL echo(build("lLoopCnt  : ",lloopcnt))
 CALL echo(build("lDUMMYTCnt: ",ldummytcnt))
 CALL echo(build("lBatchSize: ",lbatchsize))
 CALL echo(build("lExpandCnt: ",lexpandcnt))
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM code_cdf_ext cce
  WHERE cce.code_set=4
   AND cce.cdf_meaning="SSN"
   AND cce.field_name="MULTIPLE_IND"
  DETAIL
   lssnmultind = cnvtint(cce.field_value)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "CODE_CDF_EXT"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET SSN_MULT_IND :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo(build("lSSNMultInd  : ",lssnmultind))
 IF (dtaskid > 0)
  UPDATE  FROM ags_task t
   SET t.status = "PROCESSING", t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_start_dt_tm = t
    .status_dt_tm,
    t.batch_end_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00.00"), t.updt_dt_tm = cnvtdatetime(
     dtcurrent), t.updt_cnt = (t.updt_cnt+ 1)
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = update_error
   SET table_name = "AGS_TASK"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg)," TASK_ID :: ",staskid)
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ENDIF
 WHILE (lloopcnt > 0
  AND lkillind <= 0)
   IF (lstart=0)
    SET lstart = 1
   ELSE
    SET lstart = (lstart+ lbatchsize)
   ENDIF
   CALL echo(build("lLoopCnt: ",lloopcnt))
   CALL echo(build("lStart  : ",lstart))
   SET lloopcnt = (lloopcnt - 1)
   SET ditstartid = 0.0
   SET ditendid = 0.0
   SET lrowcnt = 0
   SET dtitstart = cnvtdatetime(curdate,curtime2)
   SET stat = initrec(holdrec)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ldummytcnt)),
     ags_prsnl_data a
    PLAN (d
     WHERE assign(lstart,evaluate(d.seq,1,lstart,(lstart+ lexpandcnt))))
     JOIN (a
     WHERE expand(lidx3,lstart,(lstart+ (lexpandcnt - 1)),a.provdir_link_alias,linkaliasrec->qual[
      lidx3].provdir_link_alias)
      AND a.ags_job_id=dagsjobid)
    ORDER BY a.ags_prsnl_data_id
    HEAD a.ags_prsnl_data_id
     berror = false, lrowcnt = (lrowcnt+ 1)
     IF (ditstartid <= 0.0)
      ditstartid = a.ags_prsnl_data_id
     ENDIF
     sproviderlinkalias = trim(a.provdir_link_alias)
     IF (size(sproviderlinkalias) > 0)
      lnum = 0, lpos = 0, lpos = locateval(lnum,1,holdrec->qual_cnt,sproviderlinkalias,holdrec->qual[
       lnum].provdir_link_alias)
      IF (lpos > 0)
       lidx = lpos
      ELSE
       lidx = (holdrec->qual_cnt+ 1), holdrec->qual_cnt = lidx, stat = alterlist(holdrec->qual,lidx),
       holdrec->qual[lidx].provdir_link_alias = sproviderlinkalias
      ENDIF
     ELSE
      lidx = (holdrec->qual_cnt+ 1), holdrec->qual_cnt = lidx, stat = alterlist(holdrec->qual,lidx),
      berror = true, sstatusmsg = concat(sstatusmsg,"[pla]am")
     ENDIF
     lidx2 = (holdrec->qual[lidx].prsnl_cnt+ 1), holdrec->qual[lidx].prsnl_cnt = lidx2, stat =
     alterlist(holdrec->qual[lidx].prsnl,lidx2),
     ditendid = a.ags_prsnl_data_id, holdrec->qual[lidx].prsnl[lidx2].ags_prsnl_data_id = a
     .ags_prsnl_data_id, holdrec->qual[lidx].prsnl[lidx2].person_id = a.person_id,
     ssendingfacility = trim(a.sending_facility,3)
     IF (size(ssendingfacility) > 0)
      lnum = 0, lpos = 0, lpos = locateval(lnum,1,contribrec->qual_cnt,ssendingfacility,contribrec->
       qual[lnum].sending_facility)
      IF (lpos <= 0)
       lcontribsysidx = (contribrec->qual_cnt+ 1), contribrec->qual_cnt = lcontribsysidx, stat =
       alterlist(contribrec->qual,lcontribsysidx),
       contribrec->qual[lcontribsysidx].sending_facility = ssendingfacility
      ELSE
       lcontribsysidx = lpos
      ENDIF
     ELSE
      lcontribsysidx = ljobcontribsysidx
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].contrib_sys_idx = lcontribsysidx
     IF ((holdrec->qual[lidx].prsnl[lidx2].contrib_sys_idx <= 0))
      berror = true, sstatusmsg = concat(sstatusmsg,"[c]m")
     ENDIF
     IF (a.primary_ind > 0)
      holdrec->qual[lidx].primary_idx = lidx2
     ENDIF
     sprovdiralias = trim(a.provdir_alias)
     IF (size(sprovdiralias) > 0)
      holdrec->qual[lidx].prsnl[lidx2].provdir_alias = sprovdiralias
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[pa]am")
     ENDIF
     sextalias = trim(a.ext_alias)
     IF (size(sextalias) > 0)
      holdrec->qual[lidx].prsnl[lidx2].ext_alias = trim(sextalias)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[x]am")
     ENDIF
     sssnalias = trim(a.ssn_alias)
     IF (size(sssnalias) > 0)
      holdrec->qual[lidx].prsnl[lidx2].ssn_alias = trim(sssnalias)
     ELSE
      sstatusmsg = concat(sstatusmsg,"[s]am")
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].alt_alias1 = trim(a.alt_alias1), holdrec->qual[lidx].prsnl[
     lidx2].alt_alias1_type = trim(a.alt_alias1_type)
     IF (size(holdrec->qual[lidx].prsnl[lidx2].alt_alias1) > 0)
      lnum = 0, lpos = 0, lpos = locateval(lnum,1,altaliasrec->qual_cnt,holdrec->qual[lidx].prsnl[
       lidx2].alt_alias1_type,altaliasrec->qual[lnum].esi_alias_type)
      IF (lpos <= 0)
       lidx3 = (altaliasrec->qual_cnt+ 1), altaliasrec->qual_cnt = lidx3, stat = alterlist(
        altaliasrec->qual,lidx3),
       altaliasrec->qual[lidx3].esi_alias_type = holdrec->qual[lidx].prsnl[lidx2].alt_alias1_type,
       altaliasrec->qual[lidx3].contrib_sys_idx = lcontribsysidx, holdrec->qual[lidx].prsnl[lidx2].
       alt_alias1_idx = lidx3
      ELSE
       holdrec->qual[lidx].prsnl[lidx2].alt_alias1_idx = lpos
      ENDIF
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].alt_alias2 = trim(a.alt_alias2), holdrec->qual[lidx].prsnl[
     lidx2].alt_alias2_type = trim(a.alt_alias2_type)
     IF (size(holdrec->qual[lidx].prsnl[lidx2].alt_alias2) > 0)
      lnum = 0, lpos = 0, lpos = locateval(lnum,1,altaliasrec->qual_cnt,holdrec->qual[lidx].prsnl[
       lidx2].alt_alias2_type,altaliasrec->qual[lnum].esi_alias_type)
      IF (lpos <= 0)
       lidx3 = (altaliasrec->qual_cnt+ 1), altaliasrec->qual_cnt = lidx3, stat = alterlist(
        altaliasrec->qual,lidx3),
       altaliasrec->qual[lidx3].esi_alias_type = holdrec->qual[lidx].prsnl[lidx2].alt_alias2_type,
       altaliasrec->qual[lidx3].contrib_sys_idx = lcontribsysidx, holdrec->qual[lidx].prsnl[lidx2].
       alt_alias2_idx = lidx3
      ELSE
       holdrec->qual[lidx].prsnl[lidx2].alt_alias2_idx = lpos
      ENDIF
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].dea_alias = trim(a.dea_alias), holdrec->qual[lidx].prsnl[lidx2]
     .upin_alias = trim(a.upin_alias), holdrec->qual[lidx].prsnl[lidx2].med_alias = trim(a.med_alias),
     holdrec->qual[lidx].prsnl[lidx2].ext_link_alias = trim(a.ext_link_alias), holdrec->qual[lidx].
     prsnl[lidx2].ext_org_alias = trim(a.ext_org_alias)
     IF (size(trim(a.name_first)) > 0)
      holdrec->qual[lidx].prsnl[lidx2].name_first = trim(a.name_first)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[f]m")
     ENDIF
     IF (size(trim(a.name_last)) > 0)
      holdrec->qual[lidx].prsnl[lidx2].name_last = trim(a.name_last)
     ELSE
      berror = true, sstatusmsg = concat(sstatusmsg,"[l]m")
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].name_middle = trim(a.name_middle), holdrec->qual[lidx].prsnl[
     lidx2].name_full = trim(a.name_full), holdrec->qual[lidx].prsnl[lidx2].name_degree = trim(a
      .name_degree),
     holdrec->qual[lidx].prsnl[lidx2].name_title = trim(a.name_title), holdrec->qual[lidx].prsnl[
     lidx2].birth_dt_tm = cnvtdate2(trim(a.birth_date,3),"YYYYMMDD"), sgender = trim(a.gender,3)
     IF (sgender="M")
      holdrec->qual[lidx].prsnl[lidx2].sex_cd = dmalesexcd
     ELSEIF (sgender="F")
      holdrec->qual[lidx].prsnl[lidx2].sex_cd = dfemalesexcd
     ELSE
      holdrec->qual[lidx].prsnl[lidx2].sex_cd = dunknownsexcd
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].address_id = a.address_id, holdrec->qual[lidx].prsnl[lidx2].
     street_addr = trim(a.street_addr), holdrec->qual[lidx].prsnl[lidx2].street_addr2 = trim(a
      .street_addr2),
     holdrec->qual[lidx].prsnl[lidx2].city = trim(a.city), holdrec->qual[lidx].prsnl[lidx2].state =
     trim(a.state), holdrec->qual[lidx].prsnl[lidx2].county = trim(a.county),
     holdrec->qual[lidx].prsnl[lidx2].country = trim(a.country), holdrec->qual[lidx].prsnl[lidx2].
     zipcode = trim(a.zipcode), dstatecd = uar_get_code_by("DISPLAYKEY",62,cnvtalphanum(cnvtupper(
        trim(a.state))))
     IF (dstatecd > 0.0)
      holdrec->qual[lidx].prsnl[lidx2].state_cd = dstatecd
     ENDIF
     dcountycd = uar_get_code_by("DISPLAYKEY",74,cnvtalphanum(cnvtupper(trim(a.county))))
     IF (dcountycd > 0.0)
      holdrec->qual[lidx].prsnl[lidx2].county_cd = dcountycd
     ENDIF
     dcountrycd = uar_get_code_by("DISPLAYKEY",15,cnvtalphanum(cnvtupper(trim(a.country))))
     IF (dcountrycd > 0.0)
      holdrec->qual[lidx].prsnl[lidx2].country_cd = dcountrycd
     ENDIF
     holdrec->qual[lidx].prsnl[lidx2].bus_phone_id = a.bus_phone_id, holdrec->qual[lidx].prsnl[lidx2]
     .fax_phone_id = a.fax_phone_id, holdrec->qual[lidx].prsnl[lidx2].phone_business = trim(a
      .phone_business),
     holdrec->qual[lidx].prsnl[lidx2].phone_fax = trim(a.phone_fax), holdrec->qual[lidx].prsnl[lidx2]
     .specialty = trim(a.specialty_code), holdrec->qual[lidx].prsnl[lidx2].specialty_desc = trim(a
      .specialty_desc)
     IF (berror)
      holdrec->qual[lidx].stat_flag = eerror, holdrec->qual[lidx].prsnl[lidx2].stat_flag = eerror,
      holdrec->qual[lidx].prsnl[lidx2].stat_msg = trim(sstatusmsg,3)
     ENDIF
    WITH nocouner
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_PRSNL_DATA"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_PRSNL_DATA :: ErrMsg :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   IF (lloglevel > 1)
    CALL echo("/---------------------- HoldRec Begin -----------------------------------/")
    CALL echorecord(holdrec)
    CALL echo("/----------------------- HoldRec End ------------------------------------/")
   ENDIF
   IF ((holdrec->qual_cnt > 0))
    CALL echo("***")
    CALL echo("***   CONTRIBUTOR_SYSTEM_CD Lookup")
    CALL echo("***")
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(contribrec->qual_cnt)),
      code_value_alias cva,
      contributor_system cs,
      esi_alias_trans eat
     PLAN (d
      WHERE (contribrec->qual[d.seq].contributor_source_cd <= 0.0))
      JOIN (cva
      WHERE cva.code_set=89
       AND cva.contributor_source_cd=ddefaultsrccd
       AND cva.alias=trim(contribrec->qual[d.seq].sending_facility))
      JOIN (cs
      WHERE cs.contributor_system_cd=cva.code_value
       AND cs.active_ind=1)
      JOIN (eat
      WHERE eat.contributor_system_cd=cs.contributor_system_cd
       AND eat.active_ind=1)
     ORDER BY cs.contributor_system_cd, eat.esi_alias_field_cd
     HEAD cs.contributor_system_cd
      contribrec->qual[d.seq].contributor_system_cd = cs.contributor_system_cd, contribrec->qual[d
      .seq].contributor_source_cd = cs.contributor_source_cd, contribrec->qual[d.seq].prsnl_person_id
       = cs.prsnl_person_id,
      contribrec->qual[d.seq].time_zone = cs.time_zone, contribrec->qual[d.seq].time_zone_idx =
      datetimezonebyname(contribrec->qual[d.seq].time_zone)
     HEAD eat.esi_alias_field_cd
      IF (eat.esi_alias_field_cd=dprovdirlinkaliasfieldcd)
       contribrec->qual[d.seq].provdir_link_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq
       ].provdir_link_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dprovdiraliasfieldcd)
       contribrec->qual[d.seq].provdir_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       provdir_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dextaliasfieldcd)
       contribrec->qual[d.seq].ext_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ext_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dssnaliasfieldcd)
       contribrec->qual[d.seq].ssn_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ssn_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=ddeaaliasfieldcd)
       contribrec->qual[d.seq].dea_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       dea_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dupinaliasfieldcd)
       contribrec->qual[d.seq].upin_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       upin_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dlinkaliasfieldcd)
       contribrec->qual[d.seq].ext_link_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       ext_link_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
      IF (eat.esi_alias_field_cd=dmedaliasfieldcd)
       contribrec->qual[d.seq].med_alias_pool_cd = eat.alias_pool_cd, contribrec->qual[d.seq].
       med_alias_type_cd = eat.alias_entity_alias_type_cd
      ENDIF
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "CODE_VALUE_ALIAS"
     SET ilog_status = 1
     SET log->qual_knt = (log->qual_knt+ 1)
     SET stat = alterlist(log->qual,log->qual_knt)
     SET log->qual[log->qual_knt].smsgtype = "ERROR"
     SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg))
     GO TO exit_script
    ENDIF
    FOR (lidx = 1 TO contribrec->qual_cnt)
      SET sstatusmsg = ""
      IF (lidx=1)
       SET dplapoolcd = contribrec->qual[lidx].provdir_link_alias_pool_cd
       SET dplatypecd = contribrec->qual[lidx].provdir_link_alias_type_cd
      ELSE
       IF ((dplapoolcd != contribrec->qual[lidx].provdir_link_alias_pool_cd))
        SET sstatusmsg = concat(trim(sstatusmsg),"[pla|p]d")
       ENDIF
       IF ((dplatypecd != contribrec->qual[lidx].provdir_link_alias_type_cd))
        SET sstatusmsg = concat(trim(sstatusmsg),"[pla|t]d")
       ENDIF
      ENDIF
      IF ((contribrec->qual[lidx].provdir_link_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[pla|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].provdir_link_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[pla|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].provdir_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[pa|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].provdir_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[pa|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].ext_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[x|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].ext_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[x|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].ssn_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[s|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].ssn_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[s|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].dea_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[dea|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].dea_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[dea|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].upin_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[u|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].upin_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[u|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].ext_link_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[x|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].ext_link_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[x|t]m")
      ENDIF
      IF ((contribrec->qual[lidx].med_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[med|p]m")
      ENDIF
      IF ((contribrec->qual[lidx].med_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[med|t]m")
      ENDIF
      IF (size(trim(sstatusmsg)) > 0)
       FOR (lidx2 = 1 TO holdrec->qual_cnt)
         FOR (lidx3 = 1 TO holdrec->qual[lidx2].prsnl_cnt)
           IF ((holdrec->qual[lidx2].prsnl[lidx3].contrib_sys_idx=lidx))
            SET holdrec->qual[lidx2].stat_flag = eerror
            SET holdrec->qual[lidx2].prsnl[lidx3].stat_flag = eerror
            SET holdrec->qual[lidx2].prsnl[lidx3].stat_msg = concat(trim(holdrec->qual[lidx2].prsnl[
              lidx3].stat_msg),trim(sstatusmsg))
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(altaliasrec->qual_cnt)),
      esi_alias_trans eat
     PLAN (d
      WHERE (altaliasrec->qual[d.seq].contrib_sys_idx > 0))
      JOIN (eat
      WHERE (eat.contributor_system_cd=contribrec->qual[altaliasrec->qual[d.seq].contrib_sys_idx].
      contributor_system_cd)
       AND (eat.esi_alias_type=altaliasrec->qual[d.seq].esi_alias_type)
       AND eat.alias_entity_name="PERSONNEL"
       AND eat.esi_alias_field_cd=daltaliasfieldcd
       AND eat.active_ind=1)
     ORDER BY eat.esi_alias_type
     HEAD eat.esi_alias_type
      altaliasrec->qual[d.seq].alt_alias_pool_cd = eat.alias_pool_cd, altaliasrec->qual[d.seq].
      alt_alias_type_cd = eat.alias_entity_alias_type_cd
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "GET ALT VALUES"
     SET ilog_status = 1
     SET log->qual_cnt = (log->qual_cnt+ 1)
     SET stat = alterlist(log->qual,log->qual_cnt)
     SET log->qual[log->qual_cnt].smsgtype = "ERROR"
     SET log->qual[log->qual_cnt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
     SET log->qual[log->qual_cnt].smsg = concat("GET ALT VALUES :: Select Error :: ",trim(serrmsg))
     SET serrmsg = log->qual[log->qual_cnt].smsg
     GO TO exit_script
    ENDIF
    FOR (lidx = 1 TO altaliasrec->qual_cnt)
      SET sstatusmsg = ""
      IF ((altaliasrec->qual[lidx].alt_alias_pool_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[alt|p]m")
      ENDIF
      IF ((altaliasrec->qual[lidx].alt_alias_type_cd <= 0.0))
       SET sstatusmsg = concat(trim(sstatusmsg),"[alt|t]m")
      ENDIF
      IF (size(trim(sstatusmsg)) > 0)
       FOR (lidx2 = 1 TO holdrec->qual_cnt)
         FOR (lidx3 = 1 TO holdrec->qual[lidx2].prsnl_cnt)
           IF ((((holdrec->qual[lidx2].prsnl[lidx3].alt_alias1_idx=lidx)) OR ((holdrec->qual[lidx2].
           prsnl[lidx3].alt_alias2_idx=lidx))) )
            SET holdrec->qual[lidx2].stat_flag = eerror
            SET holdrec->qual[lidx2].prsnl[lidx3].stat_flag = eerror
            SET holdrec->qual[lidx2].prsnl[lidx3].stat_msg = concat(trim(holdrec->qual[lidx2].prsnl[
              lidx3].stat_msg),trim(sstatusmsg))
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
    IF (lloglevel > 1)
     CALL echo("/--------------------- ContribRec Begin ---------------------------------/")
     CALL echorecord(contribrec)
     CALL echo("/---------------------- ContribRec End ----------------------------------/")
    ENDIF
    CALL echo("***")
    CALL echo("***   For each PROVDIR_LINK_ALIAS")
    CALL echo("***")
    FOR (lidx = 1 TO holdrec->qual_cnt)
      CALL echo(build("lIdx:",lidx))
      SET bnewpla = false
      SET dprimarypid = 0.0
      SET lpidx = holdrec->qual[lidx].primary_idx
      IF (lpidx <= 0)
       FOR (lidx2 = 1 TO holdrec->qual[lidx].prsnl_cnt)
        SET holdrec->qual[lidx].stat_flag = eerror
        SET holdrec->qual[lidx].prsnl[lidx2].stat_msg = concat(trim(holdrec->qual[lidx].prsnl[lidx2].
          stat_msg),"[pi]m")
       ENDFOR
      ENDIF
      IF ((holdrec->qual[lidx].stat_flag=ecomplete))
       CALL echo("***")
       CALL echo("***   Get PERSON_ID by PROVDIR_LINK_ALIAS")
       CALL echo("***")
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(holdrec->qual[lidx].prsnl_cnt)),
         prsnl_alias p
        PLAN (d
         WHERE size(holdrec->qual[lidx].provdir_link_alias) > 0)
         JOIN (p
         WHERE (p.alias=holdrec->qual[lidx].provdir_link_alias)
          AND (p.alias_pool_cd=contribrec->qual[holdrec->qual[lidx].prsnl[d.seq].contrib_sys_idx].
         provdir_link_alias_pool_cd)
          AND (p.prsnl_alias_type_cd=contribrec->qual[holdrec->qual[lidx].prsnl[d.seq].
         contrib_sys_idx].provdir_link_alias_type_cd)
          AND p.active_ind != 0)
        DETAIL
         IF (dprimarypid <= 0.0)
          dprimarypid = p.person_id
         ENDIF
        WITH nocounter, maxqual(p,1)
       ;end select
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = select_error
        SET table_name = "PRSNL_ALIAS"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat(
         "PRSNL_ALIAS PROVDIR_LINK_ALIAS :: Select Error :: ",trim(serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
       CALL echo(build("dPrimaryPID:",dprimarypid))
       IF (dprimarypid <= 0.0)
        CALL echo("***")
        CALL echo("***   Add new prsnl")
        CALL echo("***")
        SET bnewpla = true
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        SELECT INTO "nl:"
         y = seq(person_only_seq,nextval)
         FROM dual
         DETAIL
          holdrec->qual[lidx].prsnl[lpidx].person_id = cnvtreal(y)
         WITH format, nocounter
        ;end select
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = select_error
         SET table_name = "ADD NEW PRSNL"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("ADD NEW PRSNL :: Select Error :: ",trim(serrmsg)
          )
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        CALL echo("***")
        CALL echo("***   Insert Person")
        CALL echo("***")
        SET dprimarypid = holdrec->qual[lidx].prsnl[lpidx].person_id
        CALL echo(build("dPrimaryPID:",dprimarypid))
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        INSERT  FROM person p
         SET p.person_id = holdrec->qual[lidx].prsnl[lpidx].person_id, p.create_prsnl_id = contribrec
          ->qual[lcontribsysidx].prsnl_person_id, p.create_dt_tm = cnvtdatetime(dtcurrent),
          p.data_status_cd = dauthdatastatuscd, p.data_status_dt_tm = cnvtdatetime(dtcurrent), p
          .data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
          p.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, p
          .beg_effective_dt_tm = cnvtdatetime(dtcurrent), p.end_effective_dt_tm = cnvtdatetime(dtmax),
          p.person_type_cd = dpersonpersontypecd, p.name_last = holdrec->qual[lidx].prsnl[lpidx].
          name_last, p.name_first = holdrec->qual[lidx].prsnl[lpidx].name_first,
          p.name_middle = holdrec->qual[lidx].prsnl[lpidx].name_middle, p.name_last_key = cnvtupper(
           cnvtalphanum(holdrec->qual[lidx].prsnl[lpidx].name_last)), p.name_first_key = cnvtupper(
           cnvtalphanum(holdrec->qual[lidx].prsnl[lpidx].name_first)),
          p.name_middle_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lpidx].name_middle)),
          p.name_full_formatted = concat(holdrec->qual[lidx].prsnl[lpidx].name_last,", ",holdrec->
           qual[lidx].prsnl[lpidx].name_first," ",holdrec->qual[lidx].prsnl[lpidx].name_middle), p
          .birth_dt_tm = cnvtdatetime(holdrec->qual[lidx].prsnl[lpidx].birth_dt_tm),
          p.abs_birth_dt_tm = datetimezone(holdrec->qual[lidx].prsnl[lpidx].birth_dt_tm,contribrec->
           qual[lcontribsysidx].time_zone_idx,1), p.sex_cd = holdrec->qual[lidx].prsnl[lpidx].sex_cd,
          p.birth_tz = contribrec->qual[lcontribsysidx].time_zone_idx,
          p.active_ind = 1, p.active_status_cd = dactiveactivestatuscd, p.active_status_prsnl_id =
          contribrec->qual[lcontribsysidx].prsnl_person_id,
          p.active_status_dt_tm = cnvtdatetime(dtcurrent), p.updt_dt_tm = cnvtdatetime(dtcurrent), p
          .updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
          p.updt_task = 4249900, p.updt_cnt = 0, p.updt_applctx = 4249900
         WHERE (holdrec->qual[lidx].prsnl[lpidx].person_id > 0.0)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = insert_error
         SET table_name = "PERSON"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("INSERT PERSON :: Insert Error :: ",trim(serrmsg)
          )
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
        CALL echo("***")
        CALL echo("***   Insert PRSNL")
        CALL echo("***")
        SET ierrcode = error(serrmsg,1)
        SET ierrcode = 0
        INSERT  FROM prsnl p
         SET p.person_id = holdrec->qual[lidx].prsnl[lpidx].person_id, p.create_prsnl_id = contribrec
          ->qual[lcontribsysidx].prsnl_person_id, p.create_dt_tm = cnvtdatetime(dtcurrent),
          p.data_status_cd = dauthdatastatuscd, p.data_status_dt_tm = cnvtdatetime(dtcurrent), p
          .data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
          p.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, p
          .beg_effective_dt_tm = cnvtdatetime(dtcurrent), p.end_effective_dt_tm = cnvtdatetime(dtmax),
          p.prsnl_type_cd = duserprsnltypecd, p.name_last = holdrec->qual[lidx].prsnl[lpidx].
          name_last, p.name_first = holdrec->qual[lidx].prsnl[lpidx].name_first,
          p.name_last_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lpidx].name_last)), p
          .name_first_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lpidx].name_first)), p
          .name_full_formatted = concat(holdrec->qual[lidx].prsnl[lpidx].name_last,", ",holdrec->
           qual[lidx].prsnl[lpidx].name_first," ",holdrec->qual[lidx].prsnl[lpidx].name_middle),
          p.active_ind = 1, p.active_status_cd = dactiveactivestatuscd, p.active_status_prsnl_id =
          contribrec->qual[lcontribsysidx].prsnl_person_id,
          p.active_status_dt_tm = cnvtdatetime(dtcurrent), p.updt_dt_tm = cnvtdatetime(dtcurrent), p
          .updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
          p.updt_task = 4249900, p.updt_cnt = 0, p.updt_applctx = 4249900
         WHERE (holdrec->qual[lidx].prsnl[lpidx].person_id > 0.0)
         WITH nocounter
        ;end insert
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET failed = insert_error
         SET table_name = "PRSNL"
         SET ilog_status = 1
         SET log->qual_knt = (log->qual_knt+ 1)
         SET stat = alterlist(log->qual,log->qual_knt)
         SET log->qual[log->qual_knt].smsgtype = "ERROR"
         SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
         SET log->qual[log->qual_knt].smsg = concat("INSERT PRSNL :: Insert Error :: ",trim(serrmsg))
         SET serrmsg = log->qual[log->qual_knt].smsg
         GO TO exit_script
        ENDIF
       ENDIF
       SET stat = initrec(laststaterec)
       SET laststaterec->qual_cnt = holdrec->qual[lidx].prsnl_cnt
       SET stat = alterlist(laststaterec->qual,laststaterec->qual_cnt)
       CALL echo("***")
       CALL echo("***   Get Last State")
       CALL echo("***")
       SET ierrcode = error(serrmsg,1)
       SET ierrcode = 0
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(holdrec->qual[lidx].prsnl_cnt)),
         ags_prsnl_data a
        PLAN (d)
         JOIN (a
         WHERE (a.provdir_alias=holdrec->qual[lidx].prsnl[d.seq].provdir_alias)
          AND ((a.ags_prsnl_data_id+ 0) < holdrec->qual[lidx].prsnl[d.seq].ags_prsnl_data_id))
        ORDER BY d.seq, a.ags_prsnl_data_id DESC
        HEAD a.ags_prsnl_data_id
         IF ( NOT (laststaterec->qual[d.seq].found_ind))
          laststaterec->qual[d.seq].found_ind = 1, laststaterec->qual[d.seq].ags_prsnl_data_id = a
          .ags_prsnl_data_id, laststaterec->qual[d.seq].address_id = a.address_id,
          laststaterec->qual[d.seq].street_addr = trim(a.street_addr,3), laststaterec->qual[d.seq].
          street_addr2 = trim(a.street_addr2,3), laststaterec->qual[d.seq].city = trim(a.city,3),
          laststaterec->qual[d.seq].state = trim(a.state,3), laststaterec->qual[d.seq].county = trim(
           a.county,3), laststaterec->qual[d.seq].country = trim(a.country,3),
          laststaterec->qual[d.seq].zipcode = trim(a.zipcode,3), laststaterec->qual[d.seq].
          bus_phone_id = a.bus_phone_id, laststaterec->qual[d.seq].fax_phone_id = a.fax_phone_id,
          laststaterec->qual[d.seq].phone_business = a.phone_business, laststaterec->qual[d.seq].
          phone_fax = a.phone_fax, laststaterec->qual[d.seq].provdir_link_alias = a
          .provdir_link_alias,
          laststaterec->qual[d.seq].provdir_alias = a.provdir_alias, laststaterec->qual[d.seq].
          ssn_alias = a.ssn_alias, laststaterec->qual[d.seq].ext_alias = a.ext_alias,
          laststaterec->qual[d.seq].dea_alias = a.dea_alias, laststaterec->qual[d.seq].upin_alias = a
          .upin_alias, laststaterec->qual[d.seq].ext_link_alias = a.ext_link_alias,
          laststaterec->qual[d.seq].med_alias = a.med_alias, laststaterec->qual[d.seq].alt_alias1 = a
          .alt_alias1, laststaterec->qual[d.seq].alt_alias1_type = a.alt_alias1_type,
          laststaterec->qual[d.seq].alt_alias2 = a.alt_alias2, laststaterec->qual[d.seq].
          alt_alias2_type = a.alt_alias2_type
          IF ((laststaterec->qual[d.seq].provdir_link_alias != holdrec->qual[lidx].provdir_link_alias
          ))
           laststaterec->qual[d.seq].provdir_link_alias_change_ind = 1
          ENDIF
          IF ((laststaterec->qual[d.seq].ssn_alias != holdrec->qual[lidx].prsnl[d.seq].ssn_alias))
           laststaterec->qual[d.seq].ssn_alias_change_ind = 1
          ENDIF
          IF ((laststaterec->qual[d.seq].ext_alias != holdrec->qual[lidx].prsnl[d.seq].ext_alias))
           laststaterec->qual[d.seq].ext_alias_change_ind = 1
          ENDIF
          IF ((laststaterec->qual[d.seq].dea_alias != holdrec->qual[lidx].prsnl[d.seq].dea_alias))
           laststaterec->qual[d.seq].dea_alias_change_ind = 1
          ENDIF
          IF ((laststaterec->qual[d.seq].upin_alias != holdrec->qual[lidx].prsnl[d.seq].upin_alias))
           laststaterec->qual[d.seq].upin_alias_change_ind = 1
          ENDIF
          IF ((laststaterec->qual[d.seq].ext_link_alias != holdrec->qual[lidx].prsnl[d.seq].
          ext_link_alias))
           laststaterec->qual[d.seq].ext_link_alias_change_ind = 1
          ENDIF
          IF ((laststaterec->qual[d.seq].med_alias != holdrec->qual[lidx].prsnl[d.seq].med_alias))
           laststaterec->qual[d.seq].med_alias_change_ind = 1
          ENDIF
          IF ((((laststaterec->qual[d.seq].alt_alias1 != holdrec->qual[lidx].prsnl[d.seq].alt_alias1)
          ) OR ((laststaterec->qual[d.seq].alt_alias1_type != holdrec->qual[lidx].prsnl[d.seq].
          alt_alias1_type))) )
           laststaterec->qual[d.seq].alt_alias1_change_ind = 1
          ENDIF
          IF ((((laststaterec->qual[d.seq].alt_alias2 != holdrec->qual[lidx].prsnl[d.seq].alt_alias2)
          ) OR ((laststaterec->qual[d.seq].alt_alias2_type != holdrec->qual[lidx].prsnl[d.seq].
          alt_alias2_type))) )
           laststaterec->qual[d.seq].alt_alias2_change_ind = 1
          ENDIF
          IF ((((laststaterec->qual[d.seq].street_addr != holdrec->qual[lidx].prsnl[d.seq].
          street_addr)) OR ((((laststaterec->qual[d.seq].street_addr2 != holdrec->qual[lidx].prsnl[d
          .seq].street_addr2)) OR ((((laststaterec->qual[d.seq].city != holdrec->qual[lidx].prsnl[d
          .seq].city)) OR ((((laststaterec->qual[d.seq].state != holdrec->qual[lidx].prsnl[d.seq].
          state)) OR ((((laststaterec->qual[d.seq].county != holdrec->qual[lidx].prsnl[d.seq].county)
          ) OR ((((laststaterec->qual[d.seq].country != holdrec->qual[lidx].prsnl[d.seq].country))
           OR ((laststaterec->qual[d.seq].zipcode != holdrec->qual[lidx].prsnl[d.seq].zipcode))) ))
          )) )) )) )) )
           laststaterec->qual[d.seq].address_change_ind = 1
           IF (((size(laststaterec->qual[d.seq].city) <= 0) OR (size(laststaterec->qual[d.seq].state)
            <= 0)) )
            laststaterec->qual[d.seq].add_back_address_ind = 1
           ENDIF
          ENDIF
          IF ((laststaterec->qual[d.seq].phone_business != holdrec->qual[lidx].prsnl[d.seq].
          phone_business))
           laststaterec->qual[d.seq].phone_change_ind = 1
           IF (size(laststaterec->qual[d.seq].phone_business) <= 0)
            laststaterec->qual[d.seq].add_back_phone_ind = 1
           ENDIF
          ENDIF
          IF ((laststaterec->qual[d.seq].phone_fax != holdrec->qual[lidx].prsnl[d.seq].phone_fax))
           laststaterec->qual[d.seq].fax_change_ind = 1
           IF (size(laststaterec->qual[d.seq].phone_fax) <= 0)
            laststaterec->qual[d.seq].add_back_fax_ind = 1
           ENDIF
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = select_error
        SET table_name = "AGS_PRSNL_DATA"
        SET ilog_status = 1
        SET log->qual_knt = (log->qual_knt+ 1)
        SET stat = alterlist(log->qual,log->qual_knt)
        SET log->qual[log->qual_knt].smsgtype = "ERROR"
        SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
        SET log->qual[log->qual_knt].smsg = concat(
         "AGS_PRSNL_DATA Check for Last State :: Select Error :: ",trim(serrmsg))
        SET serrmsg = log->qual[log->qual_knt].smsg
        GO TO exit_script
       ENDIF
       IF (lloglevel > 1)
        CALL echo("/-------------------- LastStateRec Begin --------------------------------/")
        CALL echorecord(laststaterec)
        CALL echo("/--------------------- LastStateRec End ---------------------------------/")
       ENDIF
       CALL echo("***")
       CALL echo("***   For each PROVDIR_ALIAS")
       CALL echo("***")
       FOR (lidx2 = 1 TO holdrec->qual[lidx].prsnl_cnt)
         CALL echo(build("lIdx2:",lidx2))
         SET stat = initrec(aliasrec)
         IF (lidx2=lpidx)
          SET bprimaryprsnl = true
         ELSE
          SET bprimaryprsnl = false
         ENDIF
         SET lcontribsysidx = holdrec->qual[lidx].prsnl[lidx2].contrib_sys_idx
         SET holdrec->qual[lidx].prsnl[lidx2].person_id = dprimarypid
         IF ( NOT (laststaterec->qual[lidx2].found_ind))
          CALL echo(build("New PROVDIR_ALIAS:",holdrec->qual[lidx].prsnl[lidx2].provdir_alias))
          SET bnewpa = true
         ELSE
          SET bnewpa = false
          IF (laststaterec->qual[lidx2].provdir_link_alias_change_ind)
           IF ((holdrec->qual[lidx].stat_flag != eerror))
            SET holdrec->qual[lidx].stat_flag = ehold
           ENDIF
           IF (bnewpla)
            CALL echo("SPLIT")
            SET holdrec->qual[lidx].prsnl[lidx2].stat_flag = ehold
            SET holdrec->qual[lidx].prsnl[lidx2].stat_msg = concat("[]spl",trim(sstatusmsg,3))
           ELSE
            CALL echo("MOVE")
            SET holdrec->qual[lidx].prsnl[lidx2].stat_flag = ehold
            SET holdrec->qual[lidx].prsnl[lidx2].stat_msg = concat("[]mv",trim(sstatusmsg,3))
           ENDIF
          ENDIF
         ENDIF
         IF ((holdrec->qual[lidx].stat_flag != eerror)
          AND (holdrec->qual[lidx].prsnl[lidx2].stat_flag=ecomplete))
          IF (bnewpa)
           SET lidx3 = (aliasrec->qual_cnt+ 1)
           SET aliasrec->qual_cnt = lidx3
           SET stat = alterlist(aliasrec->qual,lidx3)
           SET aliasrec->qual[lidx3].action_flag = einsert
           SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].provdir_alias
           SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
           provdir_alias_pool_cd
           SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
           provdir_alias_type_cd
          ENDIF
          IF (bnewpla)
           IF (bprimaryprsnl)
            SET lidx3 = (aliasrec->qual_cnt+ 1)
            SET aliasrec->qual_cnt = (aliasrec->qual_cnt+ 1)
            SET stat = alterlist(aliasrec->qual,aliasrec->qual_cnt)
            SET aliasrec->qual[lidx3].action_flag = einsert
            SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].provdir_link_alias
            SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
            provdir_link_alias_pool_c
            SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
            provdir_link_alias_type_c
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].ext_alias_change_ind)) )
           IF (size(laststaterec->qual[lidx2].ext_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             ext_alias,holdrec->qual[lidx].prsnl[lnum].ext_alias)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].ext_alias
             SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
             ext_alias_pool_cd
             SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
             ext_alias_type_cd
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].ext_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             ext_alias,laststaterec->qual[lnum].ext_alias)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].ext_alias,holdrec->qual[lidx].prsnl[lnum].ext_alias)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].ext_alias
              SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
              ext_alias_pool_cd
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
              ext_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].dea_alias_change_ind)) )
           IF (size(laststaterec->qual[lidx2].dea_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             dea_alias,holdrec->qual[lidx].prsnl[lnum].dea_alias)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].dea_alias
             SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
             dea_alias_pool_cd
             SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
             dea_alias_type_cd
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].dea_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             dea_alias,laststaterec->qual[lnum].dea_alias)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].dea_alias,holdrec->qual[lidx].prsnl[lnum].dea_alias)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].dea_alias
              SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
              dea_alias_pool_cd
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
              dea_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].upin_alias_change_ind)) )
           IF (size(laststaterec->qual[lidx2].upin_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             upin_alias,holdrec->qual[lidx].prsnl[lnum].upin_alias)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].upin_alias
             SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
             upin_alias_pool_cd
             SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
             upin_alias_type_cd
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].upin_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             upin_alias,laststaterec->qual[lnum].upin_alias)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].upin_alias,holdrec->qual[lidx].prsnl[lnum].upin_alias)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].upin_alias
              SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
              upin_alias_pool_cd
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
              upin_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].ext_link_alias_change_ind)) )
           IF (size(laststaterec->qual[lidx2].ext_link_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             ext_link_alias,holdrec->qual[lidx].prsnl[lnum].ext_link_alias)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].ext_link_alias
             SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
             ext_link_alias_pool_cd
             SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
             ext_link_alias_type_cd
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].ext_link_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             ext_link_alias,laststaterec->qual[lnum].ext_link_alias)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].ext_link_alias,holdrec->qual[lidx].prsnl[lnum].ext_link_alias)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].ext_link_alias
              SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
              ext_link_alias_pool
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
              ext_link_alias_type
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].med_alias_change_ind)) )
           IF (size(laststaterec->qual[lidx2].med_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             med_alias,holdrec->qual[lidx].prsnl[lnum].med_alias)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].med_alias
             SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
             med_alias_pool_cd
             SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
             med_alias_type_cd
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].med_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             med_alias,laststaterec->qual[lnum].med_alias)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].med_alias,holdrec->qual[lidx].prsnl[lnum].med_alias)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].med_alias
              SET aliasrec->qual[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
              med_alias_pool_cd
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = contribrec->qual[lcontribsysidx].
              med_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].alt_alias1_change_ind)) )
           IF (size(laststaterec->qual[lidx2].alt_alias1) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             alt_alias1_type,holdrec->qual[lidx].prsnl[lnum].alt_alias1_type,
             laststaterec->qual[lidx2].alt_alias1,holdrec->qual[lidx].prsnl[lnum].alt_alias1)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alt_alias_ind = 1
             SET aliasrec->qual[lidx3].esi_alias_type = laststaterec->qual[lidx2].alt_alias1_type
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].alt_alias1
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].alt_alias1) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             alt_alias1_type,laststaterec->qual[lnum].alt_alias1_type,
             holdrec->qual[lidx].prsnl[lidx2].alt_alias1,laststaterec->qual[lnum].alt_alias1)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].alt_alias1_type,holdrec->qual[lidx].prsnl[lnum].alt_alias1_type,
              holdrec->qual[lidx].prsnl[lidx2].alt_alias1,holdrec->qual[lidx].prsnl[lnum].alt_alias1)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET laltidx = holdrec->qual[lidx].prsnl[lidx2].alt_alias1_idx
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alt_alias_ind = 1
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].alt_alias1
              SET aliasrec->qual[lidx3].alias_pool_cd = altaliasrec->qual[laltidx].alt_alias_pool_cd
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = altaliasrec->qual[laltidx].
              alt_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].alt_alias2_change_ind)) )
           IF (size(laststaterec->qual[lidx2].alt_alias2) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             alt_alias2_type,holdrec->qual[lidx].prsnl[lnum].alt_alias2_type,
             laststaterec->qual[lidx2].alt_alias2,holdrec->qual[lidx].prsnl[lnum].alt_alias2)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual_cnt+ 1)
             SET aliasrec->qual_cnt = lidx3
             SET stat = alterlist(aliasrec->qual,lidx3)
             SET aliasrec->qual[lidx3].action_flag = edelete
             SET aliasrec->qual[lidx3].alt_alias_ind = 1
             SET aliasrec->qual[lidx3].esi_alias_type = laststaterec->qual[lidx2].alt_alias2_type
             SET aliasrec->qual[lidx3].alias = laststaterec->qual[lidx2].alt_alias2
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].alt_alias2) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             alt_alias2_type,laststaterec->qual[lnum].alt_alias2_type,
             holdrec->qual[lidx].prsnl[lidx2].alt_alias2,laststaterec->qual[lnum].alt_alias2)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].alt_alias2_type,holdrec->qual[lidx].prsnl[lnum].alt_alias2_type,
              holdrec->qual[lidx].prsnl[lidx2].alt_alias2,holdrec->qual[lidx].prsnl[lnum].alt_alias2)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual_cnt+ 1)
              SET aliasrec->qual_cnt = lidx3
              SET stat = alterlist(aliasrec->qual,lidx3)
              SET laltidx = holdrec->qual[lidx].prsnl[lidx2].alt_alias2_idx
              SET aliasrec->qual[lidx3].action_flag = einsert
              SET aliasrec->qual[lidx3].alt_alias_ind = 1
              SET aliasrec->qual[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].alt_alias2
              SET aliasrec->qual[lidx3].alias_pool_cd = altaliasrec->qual[laltidx].alt_alias_pool_cd
              SET aliasrec->qual[lidx3].prsnl_alias_type_cd = altaliasrec->qual[laltidx].
              alt_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR ((laststaterec->qual[lidx2].ssn_alias_change_ind=1))) )
           IF (size(laststaterec->qual[lidx2].ssn_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,laststaterec->qual[lidx2].
             ssn_alias,holdrec->qual[lidx].prsnl[lnum].ssn_alias)
            IF (lpos <= 0)
             SET lidx3 = (aliasrec->qual2_cnt+ 1)
             SET aliasrec->qual2_cnt = lidx3
             SET stat = alterlist(aliasrec->qual2,lidx3)
             SET aliasrec->qual2[lidx3].action_flag = edelete
             SET aliasrec->qual2[lidx3].alias = laststaterec->qual[lidx2].ssn_alias
             SET aliasrec->qual2[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
             ssn_alias_pool_cd
             SET aliasrec->qual2[lidx3].person_alias_type_cd = contribrec->qual[lcontribsysidx].
             ssn_alias_type_cd
            ENDIF
           ENDIF
           IF (size(holdrec->qual[lidx].prsnl[lidx2].ssn_alias) > 0)
            SET lnum = 0
            SET lpos = 0
            SET lpos = locateval(lnum,1,laststaterec->qual_cnt,holdrec->qual[lidx].prsnl[lidx2].
             ssn_alias,laststaterec->qual[lnum].ssn_alias)
            IF (lpos <= 0)
             SET lnum = 0
             SET lpos = 0
             SET lpos = locateval(lnum,1,holdrec->qual[lidx].prsnl_cnt,holdrec->qual[lidx].prsnl[
              lidx2].ssn_alias,holdrec->qual[lidx].prsnl[lnum].ssn_alias)
             IF (lpos=lidx2)
              SET lidx3 = (aliasrec->qual2_cnt+ 1)
              SET aliasrec->qual2_cnt = lidx3
              SET stat = alterlist(aliasrec->qual2,lidx3)
              SET aliasrec->qual2[lidx3].action_flag = einsert
              SET aliasrec->qual2[lidx3].alias = holdrec->qual[lidx].prsnl[lidx2].ssn_alias
              SET aliasrec->qual2[lidx3].alias_pool_cd = contribrec->qual[lcontribsysidx].
              ssn_alias_pool_cd
              SET aliasrec->qual2[lidx3].person_alias_type_cd = contribrec->qual[lcontribsysidx].
              ssn_alias_type_cd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (lloglevel > 1)
           CALL echo("/---------------------- AliasRec Begin ----------------------------------/")
           CALL echorecord(aliasrec)
           CALL echo("/----------------------- AliasRec End -----------------------------------/")
          ENDIF
          IF ((aliasrec->qual_cnt > 0))
           CALL echo("***")
           CALL echo("***   Look up ALT_ALIAS Pool & Type")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           SELECT INTO "nl:"
            FROM (dummyt d  WITH seq = value(aliasrec->qual_cnt)),
             esi_alias_trans eat
            PLAN (d
             WHERE (aliasrec->qual[d.seq].action_flag=edelete)
              AND (aliasrec->qual[d.seq].alt_alias_ind=1))
             JOIN (eat
             WHERE (eat.contributor_system_cd=contribrec->qual[lcontribsysidx].contributor_system_cd)
              AND (eat.esi_alias_type=aliasrec->qual[d.seq].esi_alias_type)
              AND eat.alias_entity_name="PERSONNEL"
              AND eat.esi_alias_field_cd=daltaliasfieldcd
              AND eat.active_ind=1)
            ORDER BY eat.esi_alias_type
            HEAD eat.esi_alias_type
             aliasrec->qual[d.seq].alias_pool_cd = eat.alias_pool_cd, aliasrec->qual[d.seq].
             prsnl_alias_type_cd = eat.alias_entity_alias_type_cd
            WITH nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = select_error
            SET table_name = "GET ALT VALUES"
            SET ilog_status = 1
            SET log->qual_cnt = (log->qual_cnt+ 1)
            SET stat = alterlist(log->qual,log->qual_cnt)
            SET log->qual[log->qual_cnt].smsgtype = "ERROR"
            SET log->qual[log->qual_cnt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_cnt].smsg = concat("GET ALT VALUES :: Select Error :: ",trim(
              serrmsg))
            SET serrmsg = log->qual[log->qual_cnt].smsg
            GO TO exit_script
           ENDIF
           CALL echo("***")
           CALL echo("***   Insert prsnl aliases")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           INSERT  FROM prsnl_alias pa,
             (dummyt d  WITH seq = value(aliasrec->qual_cnt))
            SET pa.prsnl_alias_id = seq(prsnl_seq,nextval), pa.person_id = holdrec->qual[lidx].prsnl[
             lidx2].person_id, pa.alias = aliasrec->qual[d.seq].alias,
             pa.alias_pool_cd = aliasrec->qual[d.seq].alias_pool_cd, pa.prsnl_alias_type_cd =
             aliasrec->qual[d.seq].prsnl_alias_type_cd, pa.prsnl_alias_sub_type_cd = 0,
             pa.data_status_cd = dauthdatastatuscd, pa.data_status_dt_tm = cnvtdatetime(dtcurrent),
             pa.data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
             pa.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, pa
             .beg_effective_dt_tm = cnvtdatetime(dtcurrent), pa.end_effective_dt_tm = cnvtdatetime(
              dtmax),
             pa.check_digit = 0, pa.check_digit_method_cd = 0, pa.active_ind = 1,
             pa.active_status_cd = dactiveactivestatuscd, pa.active_status_prsnl_id = contribrec->
             qual[lcontribsysidx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dtcurrent),
             pa.updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, pa.updt_task = 4249900,
             pa.updt_cnt = 0, pa.updt_applctx = 4249900
            PLAN (d
             WHERE (aliasrec->qual[d.seq].action_flag=einsert)
              AND size(aliasrec->qual[d.seq].alias) > 0
              AND (aliasrec->qual[d.seq].alias_pool_cd > 0.0)
              AND (aliasrec->qual[d.seq].prsnl_alias_type_cd > 0.0))
             JOIN (pa)
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "PRSNL_ALIAS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("PRSNL_ALIAS :: Insert Error :: ",trim(serrmsg
              ))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           CALL echo("***")
           CALL echo("***   Inactivate prsnl aliases")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           UPDATE  FROM prsnl_alias pa,
             (dummyt d  WITH seq = value(aliasrec->qual_cnt))
            SET pa.end_effective_dt_tm = cnvtdatetime(dtcurrent), pa.active_status_cd =
             dinactiveactivestatuscd, pa.active_ind = 0,
             pa.updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, pa.updt_task = 4249900,
             pa.updt_cnt = 0, pa.updt_applctx = 4249900
            PLAN (d
             WHERE (aliasrec->qual[d.seq].action_flag=edelete)
              AND size(aliasrec->qual[d.seq].alias) > 0
              AND (aliasrec->qual[d.seq].alias_pool_cd > 0.0)
              AND (aliasrec->qual[d.seq].prsnl_alias_type_cd > 0.0))
             JOIN (pa
             WHERE (pa.person_id=holdrec->qual[lidx].prsnl[lidx2].person_id)
              AND (pa.alias=aliasrec->qual[d.seq].alias)
              AND (pa.alias_pool_cd=aliasrec->qual[d.seq].alias_pool_cd)
              AND (pa.prsnl_alias_type_cd=aliasrec->qual[d.seq].prsnl_alias_type_cd))
            WITH nocounter
           ;end update
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = delete_error
            SET table_name = "PRSNL_ALIAS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("PRSNL_ALIAS :: Delete Error :: ",trim(serrmsg
              ))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
          IF ((aliasrec->qual2_cnt > 0))
           CALL echo("***")
           CALL echo("***   Insert person aliases")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           INSERT  FROM person_alias pa,
             (dummyt d  WITH seq = value(aliasrec->qual2_cnt))
            SET pa.person_alias_id = seq(person_seq,nextval), pa.person_id = holdrec->qual[lidx].
             prsnl[lidx2].person_id, pa.alias = aliasrec->qual2[d.seq].alias,
             pa.alias_pool_cd = aliasrec->qual2[d.seq].alias_pool_cd, pa.person_alias_type_cd =
             aliasrec->qual2[d.seq].person_alias_type_cd, pa.person_alias_sub_type_cd = 0,
             pa.data_status_cd = dauthdatastatuscd, pa.data_status_dt_tm = cnvtdatetime(dtcurrent),
             pa.data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id,
             pa.contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, pa
             .beg_effective_dt_tm = cnvtdatetime(dtcurrent), pa.end_effective_dt_tm =
             IF ((aliasrec->qual2[d.seq].person_alias_type_cd != dssnpersonaliastypecd)) cnvtdatetime
              (dtmax)
             ELSEIF (((bprimaryprsnl) OR (lssnmultind > 0)) ) cnvtdatetime(dtmax)
             ELSE cnvtdatetime(dtcurrent)
             ENDIF
             ,
             pa.check_digit = 0, pa.check_digit_method_cd = 0, pa.active_ind =
             IF ((aliasrec->qual2[d.seq].person_alias_type_cd != dssnpersonaliastypecd)) 1
             ELSEIF (((bprimaryprsnl) OR (lssnmultind > 0)) ) 1
             ELSE 0
             ENDIF
             ,
             pa.active_status_cd = dactiveactivestatuscd, pa.active_status_prsnl_id = contribrec->
             qual[lcontribsysidx].prsnl_person_id, pa.active_status_dt_tm = cnvtdatetime(dtcurrent),
             pa.updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, pa.updt_task = 4249900,
             pa.updt_cnt = 0, pa.updt_applctx = 4249900
            PLAN (d
             WHERE (aliasrec->qual2[d.seq].action_flag=einsert)
              AND size(aliasrec->qual2[d.seq].alias) > 0
              AND (aliasrec->qual2[d.seq].alias_pool_cd > 0.0)
              AND (aliasrec->qual2[d.seq].person_alias_type_cd > 0.0))
             JOIN (pa)
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "PERSON_ALIAS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("PRSNL_ALIAS :: Insert Error :: ",trim(serrmsg
              ))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           CALL echo("***")
           CALL echo("***   Inactivate person aliases")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           UPDATE  FROM person_alias pa,
             (dummyt d  WITH seq = value(aliasrec->qual2_cnt))
            SET pa.end_effective_dt_tm =
             IF ((aliasrec->qual2[d.seq].person_alias_type_cd != dssnpersonaliastypecd)) cnvtdatetime
              (dtmax)
             ELSEIF (((bprimaryprsnl) OR (lssnmultind > 0)) ) cnvtdatetime(dtmax)
             ELSE cnvtdatetime(dtcurrent)
             ENDIF
             , pa.active_status_cd = dinactiveactivestatuscd, pa.active_ind =
             IF ((aliasrec->qual2[d.seq].person_alias_type_cd != dssnpersonaliastypecd)) 1
             ELSEIF (((bprimaryprsnl) OR (lssnmultind > 0)) ) 1
             ELSE 0
             ENDIF
             ,
             pa.updt_dt_tm = cnvtdatetime(dtcurrent), pa.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, pa.updt_task = 4249900,
             pa.updt_cnt = 0, pa.updt_applctx = 4249900
            PLAN (d
             WHERE (aliasrec->qual2[d.seq].action_flag=edelete)
              AND size(aliasrec->qual2[d.seq].alias) > 0
              AND (aliasrec->qual2[d.seq].alias_pool_cd > 0.0)
              AND (aliasrec->qual2[d.seq].person_alias_type_cd > 0.0))
             JOIN (pa
             WHERE (pa.person_id=holdrec->qual[lidx].prsnl[lidx2].person_id)
              AND (pa.alias=aliasrec->qual2[d.seq].alias)
              AND (pa.alias_pool_cd=aliasrec->qual2[d.seq].alias_pool_cd)
              AND (pa.person_alias_type_cd=aliasrec->qual2[d.seq].person_alias_type_cd))
            WITH nocounter
           ;end update
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = update_error
            SET table_name = "PERSON_ALIAS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("PERSON_ALIAS :: Delete Error :: ",trim(
              serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ENDIF
          IF (bprimaryprsnl)
           IF (bnewpla)
            CALL echo("***")
            CALL echo("***   Insert names")
            CALL echo("***")
            SET ierrcode = error(serrmsg,1)
            SET ierrcode = 0
            INSERT  FROM person_name n,
              (dummyt d  WITH seq = value(2))
             SET n.person_name_id = seq(person_seq,nextval), n.person_id = holdrec->qual[lidx].prsnl[
              lidx2].person_id, n.name_type_cd =
              IF (d.seq=1) dprsnlnametypecd
              ELSE dcurrentnametypecd
              ENDIF
              ,
              n.name_full = concat(holdrec->qual[lidx].prsnl[lidx2].name_last,", ",holdrec->qual[lidx
               ].prsnl[lidx2].name_first," ",holdrec->qual[lidx].prsnl[lidx2].name_middle), n
              .name_first = holdrec->qual[lidx].prsnl[lidx2].name_first, n.name_last = holdrec->qual[
              lidx].prsnl[lidx2].name_last,
              n.name_middle = holdrec->qual[lidx].prsnl[lidx2].name_middle, n.name_degree = holdrec->
              qual[lidx].prsnl[lidx2].name_degree, n.name_title = holdrec->qual[lidx].prsnl[lidx2].
              name_title,
              n.name_last_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lidx2].name_last)),
              n.name_first_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lidx2].name_first)),
              n.name_middle_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lidx2].name_middle
                )),
              n.name_type_seq = 0, n.data_status_cd = dauthdatastatuscd, n.data_status_dt_tm =
              cnvtdatetime(dtcurrent),
              n.data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id, n
              .contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, n
              .beg_effective_dt_tm = cnvtdatetime(dtcurrent),
              n.end_effective_dt_tm = cnvtdatetime(dtmax), n.active_ind = 1, n.active_status_cd =
              dactiveactivestatuscd,
              n.active_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id, n
              .active_status_dt_tm = cnvtdatetime(dtcurrent), n.updt_dt_tm = cnvtdatetime(dtcurrent),
              n.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, n.updt_task = 4249900, n
              .updt_cnt = 0,
              n.updt_applctx = 4249900
             PLAN (d)
              JOIN (n)
             WITH nocounter
            ;end insert
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = insert_error
             SET table_name = "PERSON_NAME"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("PERSON_NAME :: Insert Error :: ",trim(
               serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ELSE
            CALL echo("***")
            CALL echo("***   Update names")
            CALL echo("***")
            SET ierrcode = error(serrmsg,1)
            SET ierrcode = 0
            UPDATE  FROM person_name n
             SET n.name_full = concat(holdrec->qual[lidx].prsnl[lidx2].name_last,", ",holdrec->qual[
               lidx].prsnl[lidx2].name_first," ",holdrec->qual[lidx].prsnl[lidx2].name_middle), n
              .name_first = holdrec->qual[lidx].prsnl[lidx2].name_first, n.name_last = holdrec->qual[
              lidx].prsnl[lidx2].name_last,
              n.name_middle = holdrec->qual[lidx].prsnl[lidx2].name_middle, n.name_degree = holdrec->
              qual[lidx].prsnl[lidx2].name_degree, n.name_title = holdrec->qual[lidx].prsnl[lidx2].
              name_title,
              n.name_last_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lidx2].name_last)),
              n.name_first_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lidx2].name_first)),
              n.name_middle_key = cnvtupper(cnvtalphanum(holdrec->qual[lidx].prsnl[lidx2].name_middle
                )),
              n.name_type_seq = 0, n.updt_dt_tm = cnvtdatetime(dtcurrent), n.updt_id = contribrec->
              qual[lcontribsysidx].prsnl_person_id,
              n.updt_task = 4249900, n.updt_cnt = (n.updt_cnt+ 1), n.updt_applctx = 4249900
             WHERE (n.person_id=holdrec->qual[lidx].prsnl[lidx2].person_id)
              AND n.name_type_cd IN (dprsnlnametypecd, dcurrentnametypecd)
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = insert_error
             SET table_name = "PERSON_NAME"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("PERSON_NAME :: Update Error :: ",trim(
               serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].add_back_address_ind)) )
           CALL echo("***")
           CALL echo("***   Insert Address")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           SELECT INTO "nl:"
            y = seq(address_seq,nextval)
            FROM dual
            DETAIL
             holdrec->qual[lidx].prsnl[lidx2].address_id = cnvtreal(y)
            WITH format, nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = gen_nbr_error
            SET table_name = "GENERATE ADDRESS_ID"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("GENERATE ADDRESS_ID :: Generate Error :: ",
             trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           CALL echo(build("AddressId: ",holdrec->qual[lidx].prsnl[lidx2].address_id))
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           INSERT  FROM address a
            SET a.address_id = holdrec->qual[lidx].prsnl[lidx2].address_id, a.parent_entity_name =
             "PERSON", a.parent_entity_id = holdrec->qual[lidx].prsnl[lidx2].person_id,
             a.street_addr = holdrec->qual[lidx].prsnl[lidx2].street_addr, a.street_addr2 = holdrec->
             qual[lidx].prsnl[lidx2].street_addr2, a.city = holdrec->qual[lidx].prsnl[lidx2].city,
             a.state = holdrec->qual[lidx].prsnl[lidx2].state, a.state_cd = holdrec->qual[lidx].
             prsnl[lidx2].state_cd, a.county = holdrec->qual[lidx].prsnl[lidx2].county,
             a.county_cd = holdrec->qual[lidx].prsnl[lidx2].county_cd, a.country = holdrec->qual[lidx
             ].prsnl[lidx2].country, a.country_cd = holdrec->qual[lidx].prsnl[lidx2].country_cd,
             a.zipcode = holdrec->qual[lidx].prsnl[lidx2].zipcode, a.zipcode_key = holdrec->qual[lidx
             ].prsnl[lidx2].zipcode, a.address_type_cd = dworkaddtypecd,
             a.address_type_seq =
             IF (bprimaryprsnl) 0
             ELSE 99
             ENDIF
             , a.comment_txt = "Subscriber Address", a.beg_effective_dt_tm = cnvtdatetime(dtcurrent),
             a.end_effective_dt_tm = cnvtdatetime(dtmax), a.data_status_cd = dauthdatastatuscd, a
             .data_status_dt_tm = cnvtdatetime(dtcurrent),
             a.data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id, a
             .contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, a
             .active_ind = 1,
             a.active_status_cd = dactiveactivestatuscd, a.active_status_prsnl_id = contribrec->qual[
             lcontribsysidx].prsnl_person_id, a.active_status_dt_tm = cnvtdatetime(dtcurrent),
             a.updt_dt_tm = cnvtdatetime(dtcurrent), a.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, a.updt_task = 4249900,
             a.updt_cnt = 0, a.updt_applctx = 4249900
            WHERE (holdrec->qual[lidx].prsnl[lidx2].address_id > 0.0)
             AND size(holdrec->qual[lidx].prsnl[lidx2].city) > 0
             AND size(holdrec->qual[lidx].prsnl[lidx2].state) > 0
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "ADDRESS"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("ADDRESS :: Insert Error :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ELSE
           IF (size(holdrec->qual[lidx].prsnl[lidx2].city) > 0
            AND size(holdrec->qual[lidx].prsnl[lidx2].state) > 0)
            CALL echo("***")
            CALL echo("***   Update Address")
            CALL echo("***")
            SET holdrec->qual[lidx].prsnl[lidx2].address_id = laststaterec->qual[lidx2].address_id
            CALL echo(build("AddressId: ",holdrec->qual[lidx].prsnl[lidx2].address_id))
            SET ierrcode = error(serrmsg,1)
            SET ierrcode = 0
            UPDATE  FROM address a
             SET a.street_addr = holdrec->qual[lidx].prsnl[lidx2].street_addr, a.street_addr2 =
              holdrec->qual[lidx].prsnl[lidx2].street_addr2, a.city = holdrec->qual[lidx].prsnl[lidx2
              ].city,
              a.state = holdrec->qual[lidx].prsnl[lidx2].state, a.state_cd = holdrec->qual[lidx].
              prsnl[lidx2].state_cd, a.county = holdrec->qual[lidx].prsnl[lidx2].county,
              a.county_cd = holdrec->qual[lidx].prsnl[lidx2].county_cd, a.country = holdrec->qual[
              lidx].prsnl[lidx2].country, a.country_cd = holdrec->qual[lidx].prsnl[lidx2].country_cd,
              a.zipcode = holdrec->qual[lidx].prsnl[lidx2].zipcode, a.zipcode_key = holdrec->qual[
              lidx].prsnl[lidx2].zipcode, a.address_type_seq =
              IF (bprimaryprsnl) 0
              ELSE 99
              ENDIF
              ,
              a.updt_dt_tm = cnvtdatetime(dtcurrent), a.updt_id = contribrec->qual[lcontribsysidx].
              prsnl_person_id, a.updt_task = 4249900,
              a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = 4249900
             WHERE (holdrec->qual[lidx].prsnl[lidx2].address_id > 0.0)
              AND (a.address_id=holdrec->qual[lidx].prsnl[lidx2].address_id)
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "ADDRESS"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ADDRESS :: Update Error :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ELSEIF ((laststaterec->qual[lidx2].address_id > 0.0))
            CALL echo("***")
            CALL echo("***   Delete Address")
            CALL echo("***")
            CALL echo(build("AddressId: ",laststaterec->qual[lidx2].address_id))
            SET ierrcode = error(serrmsg,1)
            SET ierrcode = 0
            DELETE  FROM address a
             SET a.seq = 1
             WHERE (laststaterec->qual[lidx2].address_id > 0.0)
              AND (a.address_id=laststaterec->qual[lidx2].address_id)
             WITH nocounter
            ;end delete
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "ADDRESS"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("ADDRESS :: Update Error :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].add_back_phone_ind)) )
           CALL echo("***")
           CALL echo("***   Insert Phone")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           SELECT INTO "nl:"
            y = seq(phone_seq,nextval)
            FROM dual
            DETAIL
             holdrec->qual[lidx].prsnl[lidx2].bus_phone_id = cnvtreal(y)
            WITH format, nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = gen_nbr_error
            SET table_name = "GENERATE PHONE_ID"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("GENERATE PHONE_ID :: Generate Error :: ",trim
             (serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           CALL echo(build("PhoneId:",holdrec->qual[lidx].prsnl[lidx2].bus_phone_id))
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           INSERT  FROM phone p
            SET p.phone_id = holdrec->qual[lidx].prsnl[lidx2].bus_phone_id, p.parent_entity_name =
             "PERSON", p.parent_entity_id = holdrec->qual[lidx].prsnl[lidx2].person_id,
             p.phone_num = holdrec->qual[lidx].prsnl[lidx2].phone_business, p.phone_type_cd =
             dworkphonetypecd, p.phone_format_cd = dusphoneformatcd,
             p.phone_type_seq =
             IF (bprimaryprsnl) 0
             ELSE 99
             ENDIF
             , p.description = "Subscriber Business Phone", p.beg_effective_dt_tm = cnvtdatetime(
              dtcurrent),
             p.end_effective_dt_tm = cnvtdatetime(dtmax), p.data_status_cd = dauthdatastatuscd, p
             .data_status_dt_tm = cnvtdatetime(dtcurrent),
             p.data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id, p
             .contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, p
             .active_ind = 1,
             p.active_status_cd = dactiveactivestatuscd, p.active_status_prsnl_id = contribrec->qual[
             lcontribsysidx].prsnl_person_id, p.active_status_dt_tm = cnvtdatetime(dtcurrent),
             p.updt_dt_tm = cnvtdatetime(dtcurrent), p.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, p.updt_task = 4249900,
             p.updt_cnt = 0, p.updt_applctx = 4249900
            WHERE (holdrec->qual[lidx].prsnl[lidx2].bus_phone_id > 0.0)
             AND size(holdrec->qual[lidx].prsnl[lidx2].phone_business) > 0
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "PHONE"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("PHONE :: Insert Error :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ELSE
           IF (size(holdrec->qual[lidx].prsnl[lidx2].phone_business) > 0)
            CALL echo("***")
            CALL echo("***   Update Phone")
            CALL echo("***")
            SET holdrec->qual[lidx].prsnl[lidx2].bus_phone_id = laststaterec->qual[lidx2].
            bus_phone_id
            CALL echo(build("PhoneId:",holdrec->qual[lidx].prsnl[lidx2].bus_phone_id))
            SET ierrcode = error(serrmsg,1)
            SET ierrcode = 0
            UPDATE  FROM phone p
             SET p.phone_num = holdrec->qual[lidx].prsnl[lidx2].phone_business, p.phone_type_seq =
              IF (bprimaryprsnl) 0
              ELSE 99
              ENDIF
              , p.updt_dt_tm = cnvtdatetime(dtcurrent),
              p.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, p.updt_task = 4249900, p
              .updt_cnt = (p.updt_cnt+ 1),
              p.updt_applctx = 4249900
             WHERE (holdrec->qual[lidx].prsnl[lidx2].bus_phone_id > 0.0)
              AND (p.phone_id=holdrec->qual[lidx].prsnl[lidx2].bus_phone_id)
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = update_error
             SET table_name = "PHONE"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("PHONE :: Update Error :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ELSEIF ((laststaterec->qual[lidx2].bus_phone_id > 0.0))
            CALL echo("***")
            CALL echo("***   Delete Phone")
            CALL echo("***")
            CALL echo(build("PhoneId:",laststaterec->qual[lidx2].bus_phone_id))
            SET ierrcode = error(serrmsg,1)
            SET ierrcode = 0
            DELETE  FROM phone p
             SET p.seq = 1
             WHERE (laststaterec->qual[lidx2].bus_phone_id > 0.0)
              AND (p.phone_id=laststaterec->qual[lidx2].bus_phone_id)
             WITH nocounter
            ;end delete
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = delete_error
             SET table_name = "PHONE"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("PHONE :: Delete Error :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
          IF (((((bnewpla) OR (bnewpa)) ) OR (laststaterec->qual[lidx2].add_back_fax_ind)) )
           CALL echo("***")
           CALL echo("***   Insert Fax")
           CALL echo("***")
           SET ierrcode = error(serrmsg,1)
           SET ierrcode = 0
           SELECT INTO "nl:"
            y = seq(phone_seq,nextval)
            FROM dual
            DETAIL
             holdrec->qual[lidx].prsnl[lidx2].fax_phone_id = cnvtreal(y)
            WITH format, nocounter
           ;end select
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = gen_nbr_error
            SET table_name = "GENERATE PHONE_ID"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("GENERATE PHONE_ID :: Generate Error :: ",trim
             (serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
           CALL echo(build("PhoneId:",holdrec->qual[lidx].prsnl[lidx2].fax_phone_id))
           INSERT  FROM phone p
            SET p.phone_id = holdrec->qual[lidx].prsnl[lidx2].fax_phone_id, p.parent_entity_name =
             "PERSON", p.parent_entity_id = holdrec->qual[lidx].prsnl[lidx2].person_id,
             p.phone_num = holdrec->qual[lidx].prsnl[lidx2].phone_fax, p.phone_type_cd =
             dfaxphonetypecd, p.phone_format_cd = dusphoneformatcd,
             p.phone_type_seq =
             IF (bprimaryprsnl) 0
             ELSE 99
             ENDIF
             , p.description = "Subscriber Business Phone", p.beg_effective_dt_tm = cnvtdatetime(
              dtcurrent),
             p.end_effective_dt_tm = cnvtdatetime(dtmax), p.data_status_cd = dauthdatastatuscd, p
             .data_status_dt_tm = cnvtdatetime(dtcurrent),
             p.data_status_prsnl_id = contribrec->qual[lcontribsysidx].prsnl_person_id, p
             .contributor_system_cd = contribrec->qual[lcontribsysidx].contributor_system_cd, p
             .active_ind = 1,
             p.active_status_cd = dactiveactivestatuscd, p.active_status_prsnl_id = contribrec->qual[
             lcontribsysidx].prsnl_person_id, p.active_status_dt_tm = cnvtdatetime(dtcurrent),
             p.updt_dt_tm = cnvtdatetime(dtcurrent), p.updt_id = contribrec->qual[lcontribsysidx].
             prsnl_person_id, p.updt_task = 4249900,
             p.updt_cnt = 0, p.updt_applctx = 4249900
            WHERE (holdrec->qual[lidx].prsnl[lidx2].fax_phone_id > 0.0)
             AND size(holdrec->qual[lidx].prsnl[lidx2].phone_fax) > 0
            WITH nocounter
           ;end insert
           SET ierrcode = error(serrmsg,1)
           IF (ierrcode > 0)
            SET failed = insert_error
            SET table_name = "PHONE"
            SET ilog_status = 1
            SET log->qual_knt = (log->qual_knt+ 1)
            SET stat = alterlist(log->qual,log->qual_knt)
            SET log->qual[log->qual_knt].smsgtype = "ERROR"
            SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
            SET log->qual[log->qual_knt].smsg = concat("FAX :: Insert Error :: ",trim(serrmsg))
            SET serrmsg = log->qual[log->qual_knt].smsg
            GO TO exit_script
           ENDIF
          ELSE
           IF (size(holdrec->qual[lidx].prsnl[lidx2].phone_fax) > 0)
            CALL echo("***")
            CALL echo("***   Update Fax")
            CALL echo("***")
            SET holdrec->qual[lidx].prsnl[lidx2].fax_phone_id = laststaterec->qual[lidx2].
            fax_phone_id
            CALL echo(build("PhoneId:",holdrec->qual[lidx].prsnl[lidx2].fax_phone_id))
            UPDATE  FROM phone p
             SET p.phone_num = holdrec->qual[lidx].prsnl[lidx2].phone_fax, p.phone_type_seq =
              IF (bprimaryprsnl) 0
              ELSE 99
              ENDIF
              , p.updt_dt_tm = cnvtdatetime(dtcurrent),
              p.updt_id = contribrec->qual[lcontribsysidx].prsnl_person_id, p.updt_task = 4249900, p
              .updt_cnt = (p.updt_cnt+ 1),
              p.updt_applctx = 4249900
             WHERE (holdrec->qual[lidx].prsnl[lidx2].fax_phone_id > 0.0)
              AND (p.phone_id=holdrec->qual[lidx].prsnl[lidx2].fax_phone_id)
             WITH nocounter
            ;end update
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = updates_error
             SET table_name = "PHONE"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("FAX :: Update Error :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ELSEIF ((laststaterec->qual[lidx2].fax_phone_id > 0.0))
            CALL echo("***")
            CALL echo("***   Delete Fax")
            CALL echo("***")
            CALL echo(build("PhoneId:",laststaterec->qual[lidx2].fax_phone_id))
            DELETE  FROM phone p
             SET p.seq = 1
             WHERE (laststaterec->qual[lidx2].fax_phone_id > 0.0)
              AND (p.phone_id=laststaterec->qual[lidx2].fax_phone_id)
             WITH nocounter
            ;end delete
            SET ierrcode = error(serrmsg,1)
            IF (ierrcode > 0)
             SET failed = delete_error
             SET table_name = "PHONE"
             SET ilog_status = 1
             SET log->qual_knt = (log->qual_knt+ 1)
             SET stat = alterlist(log->qual,log->qual_knt)
             SET log->qual[log->qual_knt].smsgtype = "ERROR"
             SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
             SET log->qual[log->qual_knt].smsg = concat("FAX :: Delete Error :: ",trim(serrmsg))
             SET serrmsg = log->qual[log->qual_knt].smsg
             GO TO exit_script
            ENDIF
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF ((holdrec->qual[lidx].stat_flag=eerror))
       CALL echo(concat("*** Rollback PROVDIR_LINK_ALIAS:",holdrec->qual[lidx].provdir_link_alias))
       ROLLBACK
      ENDIF
      UPDATE  FROM (dummyt d  WITH seq = value(holdrec->qual[lidx].prsnl_cnt)),
        ags_prsnl_data a
       SET a.contributor_system_cd = contribrec->qual[holdrec->qual[lidx].prsnl[d.seq].
        contrib_sys_idx].contributor_system_cd, a.person_id = holdrec->qual[lidx].prsnl[d.seq].
        person_id, a.address_id = holdrec->qual[lidx].prsnl[d.seq].address_id,
        a.bus_phone_id = holdrec->qual[lidx].prsnl[d.seq].bus_phone_id, a.fax_phone_id = holdrec->
        qual[lidx].prsnl[d.seq].fax_phone_id, a.status =
        IF ((((holdrec->qual[lidx].stat_flag=eerror)) OR ((holdrec->qual[lidx].prsnl[d.seq].stat_flag
        =eerror))) ) "IN ERROR"
        ELSEIF ((holdrec->qual[lidx].prsnl[d.seq].stat_flag=ehold)) "HOLD"
        ELSE "COMPLETE"
        ENDIF
        ,
        a.stat_msg = trim(substring(1,40,holdrec->qual[lidx].prsnl[d.seq].stat_msg)), a.updt_dt_tm =
        cnvtdatetime(dtcurrent), a.updt_task = 4249900,
        a.updt_cnt = (a.updt_cnt+ 1), a.updt_applctx = 4249900
       PLAN (d)
        JOIN (a
        WHERE (a.ags_prsnl_data_id=holdrec->qual[lidx].prsnl[d.seq].ags_prsnl_data_id))
       WITH nocounter
      ;end update
      COMMIT
    ENDFOR
   ENDIF
   SET lavgsec = 0
   SET litcount = (litcount+ 1)
   SET dtitend = cnvtdatetime(curdate,curtime2)
   IF (lrowcnt > 0)
    SET lavgsec = (cnvtreal(lrowcnt)/ datetimediff(dtitend,dtitstart,5))
   ENDIF
   IF (lavgsec > 0)
    SET dtestcompletion = cnvtlookahead(concat(cnvtstring(ceil((cnvtreal(((dbatchendid - ditendid)+ 1
         ))/ lavgsec))),",S"),dtitend)
   ENDIF
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.iteration_start_id = ditstartid, t.iteration_end_id = ditendid, t.iteration_count =
     litcount,
     t.iteration_start_dt_tm = cnvtdatetime(dtitstart), t.iteration_end_dt_tm = cnvtdatetime(dtitend),
     t.iteration_average = lavgsec,
     t.est_completion_dt_tm = cnvtdatetime(dtestcompletion)
    WHERE t.ags_task_id=dtaskid
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK UPDATE ITERATION :: Update Error :: ",trim(
      serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM ags_task t
    WHERE t.ags_task_id=dtaskid
    DETAIL
     lkillind = t.kill_ind
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "GET KILL_IND"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("GET KILL_IND :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
    GO TO exit_script
   ENDIF
 ENDWHILE
 IF (dtaskid > 0)
  CALL echo("***")
  CALL echo("***   Update Task Status")
  CALL echo("***")
  UPDATE  FROM ags_task t
   SET t.status =
    IF (lkillind > 0) "WAITING"
    ELSE "COMPLETE"
    ENDIF
    , t.status_dt_tm = cnvtdatetime(dtcurrent), t.batch_end_dt_tm = cnvtdatetime(dtcurrent)
   WHERE t.ags_task_id=dtaskid
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "LOAD CE REQUEST"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("ErrMsg :: ",trim(serrmsg),"CurQual :: ",cnvtint(
     curqual))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  IF (lkillind=0)
   SET bjobcomplete = true
   SELECT INTO "nl:"
    FROM ags_task t
    WHERE t.ags_job_id=dagsjobid
     AND t.status != "COMPLETE"
    DETAIL
     bjobcomplete = false
    WITH nocounter
   ;end select
   IF (bjobcomplete)
    UPDATE  FROM ags_job j
     SET j.status = "COMPLETE", j.status_dt_tm = cnvtdatetime(dtcurrent)
     WHERE j.ags_job_id=dagsjobid
     WITH nocounter
    ;end update
   ENDIF
  ENDIF
 ENDIF
 IF (define_logging_sub=true)
  SUBROUTINE handle_logging(slog_file,semail,istatus)
    CALL echo("***")
    CALL echo(build("***   sLog_file :",slog_file))
    CALL echo(build("***   sEmail    :",semail))
    CALL echo(build("***   iStatus   :",istatus))
    CALL echo("***")
    FREE SET output_log
    SET logical output_log value(nullterm(concat("cer_log:",trim(cnvtlower(slog_file)))))
    SELECT INTO output_log
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      out_line = fillstring(254," "), sstatus = fillstring(25," ")
     DETAIL
      FOR (exe_idx = 1 TO log->qual_knt)
        out_line = trim(substring(1,254,concat(format(log->qual[exe_idx].smsgtype,"#######")," :: ",
           format(log->qual[exe_idx].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[
            exe_idx].smsg))))
        IF ((exe_idx=log->qual_knt))
         IF (istatus=0)
          sstatus = "SUCCESS"
         ELSEIF (istatus=1)
          sstatus = "FAILURE"
         ELSE
          sstatus = "SUCCESS - With Warnings"
         ENDIF
         out_line = trim(substring(1,254,concat(trim(out_line),"  *** ",trim(sstatus)," ***")))
        ENDIF
        col 0, out_line
        IF ((exe_idx != log->qual_knt))
         row + 1
        ENDIF
      ENDFOR
     WITH nocounter, nullreport, formfeed = none,
      format = crstream, append, maxcol = 255,
      maxrow = 1
    ;end select
    IF ((email->qual_knt > 0))
     DECLARE msgpriority = i4 WITH public, noconstant(5)
     DECLARE sendto = vc WITH public, noconstant(trim(semail))
     DECLARE sender = vc WITH public, noconstant("sf3151")
     DECLARE subject = vc WITH public, noconstant("")
     DECLARE msgclass = vc WITH public, noconstant("IPM.NOTE")
     DECLARE msgtext = vc WITH public, noconstant("")
     IF (istatus=0)
      SET subject = concat("SUCCESS - ",trim(slog_file))
      SET msgtext = concat("SUCCESS - ",trim(slog_file))
     ELSEIF (istatus=1)
      SET subject = concat("FAILURE - ",trim(slog_file))
      SET msgtext = concat("FAILURE - ",trim(slog_file))
     ELSE
      SET subject = concat("SUCCESS (with Warnings) - ",trim(slog_file))
      SET msgtext = concat("SUCCESS (with Warnings) - ",trim(slog_file))
     ENDIF
     FOR (eidx = 1 TO email->qual_knt)
       IF ((email->qual[eidx].send_flag=0))
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=1)
        AND istatus != 1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
       IF ((email->qual[eidx].send_flag=2)
        AND istatus=1)
        CALL uar_send_mail(nullterm(sendto),nullterm(subject),nullterm(msgtext),nullterm(sender),
         msgpriority,
         nullterm(msgclass))
       ENDIF
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 SUBROUTINE turn_on_tracing(null)
   SET trace = echorecord
   SET trace = rdbprogram
   SET trace = srvuint
   SET trace = cost
   SET trace = callecho
   SET message = information
   SET tracing_on = true
 END ;Subroutine
 SUBROUTINE turn_off_tracing(null)
   SET trace = noechorecord
   SET trace = nordbprogram
   SET trace = nosrvuint
   SET trace = nocost
   SET trace = nocallecho
   SET message = noinformation
   SET tracing_on = false
 END ;Subroutine
#exit_script
 IF (failed != false)
  ROLLBACK
  CALL echorecord(log)
  IF (dtaskid > 0)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM ags_task t
    SET t.status = "IN ERROR", t.status_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (t
     WHERE t.ags_task_id=dtaskid)
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "AGS_TASK"
    SET ilog_status = 1
    SET log->qual_knt = (log->qual_knt+ 1)
    SET stat = alterlist(log->qual,log->qual_knt)
    SET log->qual[log->qual_knt].smsgtype = "ERROR"
    SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
    SET log->qual[log->qual_knt].smsg = concat("AGS_TASK :: Select Error :: ",trim(serrmsg))
    SET serrmsg = log->qual[log->qual_knt].smsg
   ENDIF
   COMMIT
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "INPUT ERROR"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = "END >> AGS_PVD_PRSNL_LOAD"
 IF (define_logging_sub=true)
  CALL echorecord(reply)
  CALL handle_logging(sstatus_file_name,sstatus_email,ilog_status)
 ENDIF
 SET sversion = "002 09/11/06"
 CALL echo(concat("MOD:",ags_pvd_prsnl_load_mod))
 CALL echo("<===== AGS_PVD_PRSNL_LOAD End =====>")
END GO
