CREATE PROGRAM bhs_cr_process_dist_xr:dba
 RECORD reply(
   1 qual[1]
     2 chart_request_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD prov
 RECORD prov(
   1 prov_no = vc
 )
 FREE RECORD parser_rec
 RECORD parser_rec(
   1 qual[*]
     2 statement = vc
 )
 FREE RECORD cp_encntr
 RECORD cp_encntr(
   1 encntr_list[*]
     2 encntr_id = f8
     2 person_id = f8
 )
 FREE RECORD distinct_cp_encntr
 RECORD distinct_cp_encntr(
   1 encntr_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 latest_clinsig_updt_dt_tm = dq8
 )
 FREE RECORD provider_reltn_rec
 RECORD provider_reltn_rec(
   1 qual[*]
     2 encntr_id = f8
 )
 FREE RECORD distinct_prov_reltn_rec
 RECORD distinct_prov_reltn_rec(
   1 qual[*]
     2 encntr_id = f8
 )
 FREE RECORD acthold
 RECORD acthold(
   1 acthold_cd = vc
 )
 FREE RECORD ordstat
 RECORD ordstat(
   1 ordstat_cd = vc
 )
 FREE RECORD dist_providers
 RECORD dist_providers(
   1 qual[*]
     2 provider_id = f8
     2 provider_types[*]
       3 provider_type = f8
 )
 FREE RECORD law_providers
 RECORD law_providers(
   1 qual[*]
     2 provider_id = f8
     2 provider_types[*]
       3 provider_type = f8
 )
 FREE RECORD cs333_parser
 RECORD cs333_parser(
   1 statement_cdfv = vc
   1 statement_clfv = vc
 )
 FREE RECORD cs331_parser
 RECORD cs331_parser(
   1 statement_cdfv = vc
   1 statement_clfv = vc
 )
 FREE RECORD filter_rec
 RECORD filter_rec(
   1 type_flag[6]
     2 qual[*]
       3 parent_entity_id = f8
 )
 FREE RECORD mbo_flat_rec
 RECORD mbo_flat_rec(
   1 qual[*]
     2 event_id = f8
     2 chart_date = dq8
     2 lookback_dt_tm = dq8
     2 non_ce_begin_dt_tm = dq8
 )
 FREE RECORD reltns
 RECORD reltns(
   1 cnt = i4
   1 idents[*]
     2 id = vc
     2 prsnl_cnt = i4
     2 prsnl[*]
       3 prsnl_id = f8
       3 reltn_cnt = i4
       3 reltns[*]
         4 reltn_type_cd = f8
 )
 FREE RECORD xencntr_list
 RECORD xencntr_list(
   1 person_list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 create_dt_tm = dq8
     2 selected_cnt = i4
     2 latest_clinsig_updt_dt_tm = dq8
     2 encntr_list[*]
       3 encntr_id = f8
       3 use_flag = i2
       3 dont_use_flag = i2
       3 ce_use_flag = i2
 )
 DECLARE ms_batch_selection = vc WITH protect, noconstant(trim( $1,3))
 DECLARE del_stat_cd = f8 WITH noconstant(0.0)
 SET trace = error
 SET trace = errorclear
 SET trace = errorclearcom
 SET error_msg = fillstring(255," ")
 SET msg_size = 0
 SET error_check = error(error_msg,1)
 SET reply->status_data.status = "F"
 SET message_log = fillstring(200," ")
 SET dist_date = cnvtdatetime(sysdate)
 DECLARE format_timezone = vc WITH constant("dd-MMM-yyyy HH:mm:ss ZZZ")
 DECLARE utc_timezone = i4 WITH constant(266)
 DECLARE initial_pool_cnt = i4 WITH noconstant(0)
 DECLARE is_logical_domain_enabled = i4 WITH noconstant(0)
 DECLARE logical_domain_parser = vc WITH noconstant("1=1")
 SET dist_descr = fillstring(100," ")
 SET days_till_chart = 0
 SET loc_type_cnt = 0
 SET size_providers = 0
 SET size_relationships = 0
 SET p_index = 0
 SET provider_include_flag = 99
 SET provider_reltn_cnt = 0
 SET distinct_prov_reltn_cnt = 0
 SET parser_person_cnt = 0
 SET size_personlist = 0
 SET size_encntrlist = 0
 SET size_orderlist = 0
 SET all_flag = fillstring(3," ")
 SET prov_no_cnt = 0
 SET x = 0
 SET y = 0
 DECLARE idx = i4 WITH noconstant(0)
 SET distr_id = 0.0
 SET scope = 0
 SET template_id = 0.0
 SET run_type_cd = 0.0
 SET run_type_mean = fillstring(12," ")
 SET pending_flag = 0
 SET mcis_ind = 0
 SET sort_seq = 99
 SET sort_seq_cd = 0.0
 SET def_chart = 0
 SET file_storage_cd = 0.0
 SET file_storage_location = fillstring(100," ")
 SET ftp_location = fillstring(100," ")
 SET cross_encntr_law_id = 0.0
 SET cnt = 0
 SET cnt1 = 0
 SET cnt2 = 0
 SET cs_cnt = 0
 DECLARE admit_doc = f8
 SET consult_doc_ind = 0
 SET cc_consult_ind = 0
 SET order_doc_ind = 0
 SET order_doc_flag = 0
 SET prov_already_in_list = 0
 DECLARE consult_doc_cd = f8 WITH noconstant(0.0)
 DECLARE order_doc_cd = f8 WITH noconstant(0.0)
 DECLARE mrn_code = f8 WITH noconstant(0.0)
 SET req_cnt = 0
 SET prov_cnt = 0
 DECLARE batch_selection = vc WITH noconstant("")
 SET batch_selection = ms_batch_selection
 SET output_dist = fillstring(100," ")
 SET output_device_cd = 0.0
 SET output_dest_cd = 0.0
 DECLARE join_fields = vc WITH noconstant("")
 DECLARE join_tables = vc WITH noconstant("")
 DECLARE select_fields1 = vc WITH noconstant("")
 DECLARE select_fields2 = vc WITH noconstant("")
 DECLARE cs_where_clause = vc WITH noconstant("1=1")
 DECLARE cs_where_clause2 = vc WITH noconstant("1=1")
 DECLARE cs_cross_encntr_clause = vc WITH noconstant("")
 SET dischg_cutoff = 0
 DECLARE dischg = vc
 SET code_mean = fillstring(350," ")
 SET cutoff_code_mean = fillstring(200," ")
 SET loc_code = 0.0
 SET reader_group = fillstring(15," ")
 SET delete_old_distr = 0
 SET j = 0
 SET k = 0
 DECLARE i = i4 WITH noconstant(0), private
 DECLARE splitcum_cutoffpage_ind = i2 WITH noconstant(0)
 DECLARE repl_cutoffdays_ind = i2 WITH noconstant(0)
 DECLARE donotuse_encntr_ind = i2
 SET cutoff_pages = 0
 SET cutoff_days = 0
 SET cutoff_and_or_ind = 0
 DECLARE final_cd = f8 WITH noconstant(0.0)
 DECLARE cumulative_cd = f8 WITH noconstant(0.0)
 DECLARE addend_cd = f8 WITH noconstant(0.0)
 DECLARE cumadd_cd = f8 WITH noconstant(0.0)
 DECLARE splitcum_cd = f8 WITH noconstant(0.0)
 DECLARE replacement_cd = f8 WITH noconstant(0.0)
 DECLARE cutoff_cd = f8 WITH noconstant(0.0)
 SET string_len = 0
 SET pat_distr = 0
 SET count3 = 0
 SET count_nouse = 0
 SET acthold_cnt = 0
 SET ordstat_cnt = 0
 DECLARE ordstat2 = vc WITH noconstant("")
 SET default_output_dest_cd = 0.0
 SET default_output_device_cd = 0.0
 SET drt_criteria = 0
 SET cp_encntr_cnt = 0
 SET distinct_cp_encntr_cnt = 0
 SET last_dist_run_dt_tm = cnvtdatetime("01-jan-1800")
 SET ooooo_ind = 0
 DECLARE auth_cd = f8 WITH noconstant(0.0)
 DECLARE unauth_cd = f8 WITH noconstant(0.0)
 DECLARE mod_cd = f8 WITH noconstant(0.0)
 DECLARE super_cd = f8 WITH noconstant(0.0)
 DECLARE inlab_cd = f8 WITH noconstant(0.0)
 DECLARE inprog_cd = f8 WITH noconstant(0.0)
 DECLARE trans_cd = f8 WITH noconstant(0.0)
 DECLARE altered_cd = f8 WITH noconstant(0.0)
 DECLARE ctrans_cd = f8 WITH noconstant(0.0)
 DECLARE radclass_cd = f8 WITH noconstant(0.0)
 SET beg_time = cnvtdatetime(sysdate)
 SET exec_time = 0.0
 SET dischg_cutoff_days = 0
 SET person_level_cnt = 0
 SET encntr_level_cnt = 0
 SET order_level_cnt = 0
 SET et_included = 0
 SET cl_included = 0
 SET lc_included = 0
 SET ms_included = 0
 SET cs_included = 0
 SET exclude_cnt = 0
 DECLARE absolutelookback_cnt = i2 WITH noconstant(0)
 DECLARE admit_date_option_flag = i2 WITH noconstant(0)
 DECLARE initial_distribution_run = i2 WITH noconstant(0)
 DECLARE lookback_option_date = i2 WITH constant(0)
 DECLARE lookback_option_previous_dist_run = i2 WITH constant(1)
 DECLARE lookback_option_admit_date = i2 WITH constant(2)
 DECLARE lookback_option_days = i2 WITH constant(3)
 SET begin_dt_tm = cnvtdatetime("01-jan-1800")
 SET lookback_dt_tm = cnvtdatetime("01-jan-1800")
 SET neverqualifiedlookback_dt_tm = cnvtdatetime("01-jan-1800")
 SET temp_date = cnvtdatetime("01-jan-1800")
 SET initial_lookback_dt_tm = cnvtdatetime("01-jan-1800")
 SET first_qual_lookback_dt_tm = cnvtdatetime("01-jan-1800")
 SET absolute_lookback_dt_tm = cnvtdatetime("01-jan-1800")
 DECLARE initial_lookback_ind = i2 WITH noconstant(lookback_option_date)
 DECLARE first_qual_lookback_ind = i2 WITH noconstant(lookback_option_date)
 DECLARE absolute_lookback_ind = i2 WITH noconstant(lookback_option_date)
 DECLARE initial_lookback_days = i4 WITH noconstant(0)
 DECLARE first_qual_lookback_days = i4 WITH noconstant(0)
 DECLARE absolute_lookback_days = i4 WITH noconstant(0)
 SET latest_clinsig_updt_dt_tm = cnvtdatetime(dist_date)
 SET consult_encntr_ind = 0
 SET consult_order_ind = 0
 SET dist_type = 0
 DECLARE found = i2 WITH noconstant(0)
 DECLARE last_encntr_id = f8 WITH noconstant(0.0)
 DECLARE plan_statement = vc
 DECLARE ncopytoauthorind = i2 WITH noconstant(0)
 DECLARE ncopytoreviewerind = i2 WITH noconstant(0)
 DECLARE sactiontypesparser = vc WITH noconstant("")
 DECLARE dsigncd = f8 WITH noconstant(0.0)
 DECLARE dcosigncd = f8 WITH noconstant(0.0)
 DECLARE dreviewcd = f8 WITH noconstant(0.0)
 DECLARE comp_cd = f8 WITH noconstant(0.0)
 DECLARE pen_cd = f8 WITH noconstant(0.0)
 DECLARE req_cd = f8 WITH noconstant(0.0)
 DECLARE dbusinesscd = f8 WITH noconstant(0.0)
 DECLARE dist_flag = i2
 DECLARE max_seq_nbr = i4
 DECLARE chart_route_id = f8
 DECLARE exp_ind = i2 WITH noconstant(0)
 DECLARE exp_prov_parser = vc WITH noconstant("1=1")
 DECLARE exclude_exp_prov_ind = i2 WITH constant(1)
 DECLARE pdfonly_cd = f8 WITH constant(uar_get_code_by("MEANING",22549,"PDF")), protect
 DECLARE printandtxt_cd = f8 WITH constant(uar_get_code_by("MEANING",22549,"PRINTANDTXT")), protect
 DECLARE txtonly_cd = f8 WITH constant(uar_get_code_by("MEANING",22549,"TXT")), protect
 DECLARE txtoutputcontenttype_cd = f8 WITH constant(uar_get_code_by("MEANING",4002390,"PLAINTEXT")),
 protect
 DECLARE big_bind_cnt = i4 WITH constant(200)
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE published_as_of_mode_type = i2 WITH constant(4), protect
 DECLARE op_mask_id = f8
 DECLARE sending_org_id = f8 WITH noconstant(0)
 DECLARE sender_email = vc WITH noconstant("")
 DECLARE intsecemail_cd = f8 WITH constant(uar_get_code_by("MEANING",43,"INTSECEMAIL")), protect
 DECLARE organization_entity = vc WITH protect, constant("ORGANIZATION")
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,consult_doc_cd)
 SET stat = uar_get_meaning_by_codeset(333,"ORDERDOC",1,order_doc_cd)
 SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",1,admit_doc)
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_code)
 SET stat = uar_get_meaning_by_codeset(21,"SIGN",1,dsigncd)
 SET stat = uar_get_meaning_by_codeset(21,"COSIGN",1,dcosigncd)
 SET stat = uar_get_meaning_by_codeset(21,"REVIEW",1,dreviewcd)
 SET stat = uar_get_meaning_by_codeset(103,"COMPLETED",1,comp_cd)
 SET stat = uar_get_meaning_by_codeset(103,"PENDING",1,pen_cd)
 SET stat = uar_get_meaning_by_codeset(103,"REQUESTED",1,req_cd)
 SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",1,dbusinesscd)
 DECLARE activate_cd = f8 WITH noconstant(0.0)
 DECLARE modify_cd = f8 WITH noconstant(0.0)
 DECLARE order_cd = f8 WITH noconstant(0.0)
 DECLARE renew_cd = f8 WITH noconstant(0.0)
 DECLARE resume_cd = f8 WITH noconstant(0.0)
 DECLARE stud_activate_cd = f8 WITH noconstant(0.0)
 DECLARE canceled_cd = f8 WITH noconstant(0.0)
 DECLARE deleted_cd = f8 WITH noconstant(0.0)
 DECLARE discontinued_cd = f8 WITH noconstant(0.0)
 DECLARE completed_cd = f8 WITH noconstant(0.0)
 DECLARE voided_with_result_cd = f8 WITH noconstant(0.0)
 DECLARE unscheduled_cd = f8 WITH noconstant(0.0)
 DECLARE transfer_canceled_cd = f8 WITH noconstant(0.0)
 DECLARE consult_encntr_cd = f8 WITH noconstant(0.0)
 DECLARE consult_order_cd = f8 WITH noconstant(0.0)
 DECLARE cc_provider_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(6003,"ACTIVATE",1,activate_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"MODIFY",1,modify_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,order_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RENEW",1,renew_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"RESUME",1,resume_cd)
 SET stat = uar_get_meaning_by_codeset(6003,"STUDACTIVATE",1,stud_activate_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"FINAL",1,final_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"ADDENDUM",1,addend_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"CUM ADDENDUM",1,cumadd_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"SPLIT CUM",1,splitcum_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"CUTOFF",1,cutoff_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"REPLACEMENT",1,replacement_cd)
 SET stat = uar_get_meaning_by_codeset(22550,"CUMULATIVE",1,cumulative_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,altered_cd)
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
 SET stat = uar_get_meaning_by_codeset(8,"C_TRANSCRIBE",1,ctrans_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"CANCELED",1,canceled_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"DELETED",1,deleted_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"DISCONTINUED",1,discontinued_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"COMPLETED",1,completed_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"VOIDEDWRSLT",1,voided_with_result_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"UNSCHEDULED",1,unscheduled_cd)
 SET stat = uar_get_meaning_by_codeset(6004,"TRANS/CANCEL",1,transfer_canceled_cd)
 SET stat = uar_get_meaning_by_codeset(53,"RAD",1,radclass_cd)
 SET stat = uar_get_meaning_by_codeset(22333,"CONSENCNTR",1,consult_encntr_cd)
 SET stat = uar_get_meaning_by_codeset(22333,"CONSORDER",1,consult_order_cd)
 SET stat = uar_get_meaning_by_codeset(22333,"CCPROVIDER",1,cc_provider_cd)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,del_stat_cd)
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE multitenancy = i2 WITH noconstant(0)
 DECLARE prov_routing_flag = i2 WITH noconstant(0)
 DECLARE charting_operations_id = f8 WITH noconstant(0.0)
 DECLARE prov_routing_clause = vc WITH noconstant("1=1")
 DECLARE prov_routing_auth_review_clause = vc WITH noconstant("1=1")
 DECLARE prov_routing_consult_clause = vc WITH noconstant("1=1")
 DECLARE oe_field_meaning_clause = vc WITH noconstant("1=1")
 DECLARE oe_field_meaning_id_ccprovider = i4 WITH constant(3589)
 DECLARE oe_field_meaning_id_consultdoc = i4 WITH constant(2)
 DECLARE max_order_count = i4 WITH noconstant(0)
 DECLARE mdoc_class_cd = f8
 DECLARE doc_class_cd = f8
 DECLARE grp_class_cd = f8
 DECLARE proc_class_cd = f8
 DECLARE placeholder_class_cd = f8
 DECLARE micro_class_cd = f8
 DECLARE dpowerchartcd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART")), protect
 SET stat = uar_get_meaning_by_codeset(53,"MDOC",1,mdoc_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,doc_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"GRP",1,grp_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"PROCEDURE",1,proc_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,placeholder_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MBO",1,micro_class_cd)
 DECLARE nextseq = f8 WITH noconstant(0.0)
 DECLARE distinct_cnt = i4 WITH noconstant(0)
 DECLARE file_mask = vc WITH noconstant("")
 DECLARE content_type_ap = vc WITH constant("AP")
 DECLARE content_type_aphist = vc WITH constant("AP_HISTORY")
 DECLARE content_type_cardio = vc WITH constant("CARDIOVASC")
 DECLARE content_type_doc = vc WITH constant("CLIN_DOC")
 DECLARE content_type_immun = vc WITH constant("IMMUNIZATION")
 DECLARE content_type_micro = vc WITH constant("MICRO")
 DECLARE content_type_rad = vc WITH constant("RADIOLOGY")
 DECLARE content_type_hla_typing = vc WITH constant("HLATYPING")
 DECLARE content_type_haplotype = vc WITH constant("HLAHAPLOTYPE")
 DECLARE content_type_bb_xm = vc WITH constant("BB_XM")
 DECLARE content_type_bb_transfuse = vc WITH constant("BB_TRANSFUSE")
 DECLARE buildcontribsysclause(null) = vc
 DECLARE buildcontribsysclausece2(null) = vc
 DECLARE buildresultclause(null) = vc
 DECLARE buildresultclauseforradiology(null) = vc
 DECLARE buildmicroresultclass(null) = vc
 DECLARE update_dist_exec_table(null) = null
 DECLARE dhomecd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(212,nullterm("HOME"),1,dhomecd)
 IF (checkdic("CR_DESTINATION_XREF","T",0) < 2)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "checkdic()"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CR_DESTINATION_XREF"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "CR_DESTINATION_XREF table not accessible"
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 SET batch_selection = ms_batch_selection
 SET test_ind = 0
 SELECT INTO "nl:"
  d.info_number
  FROM dm_info d
  WHERE d.info_domain="CLINICAL REPORTING XR"
   AND d.info_name="Enable Logical Domain XR Dist"
  HEAD REPORT
   is_logical_domain_enabled = d.info_number
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ld.logical_domain_id
  FROM logical_domain ld
  WHERE ld.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET multitenancy = 1
 ENDIF
 SELECT INTO "nl:"
  co.param
  FROM charting_operations co
  WHERE cnvtupper(cnvtalphanum(ms_batch_selection))=co.batch_name_key
   AND co.active_ind=1
  ORDER BY co.param_type_flag
  HEAD REPORT
   charting_operations_id = co.charting_operations_id, logical_domain_id = co.logical_domain_id
  DETAIL
   CASE (co.param_type_flag)
    OF 1:
     scope = cnvtint(co.param)
    OF 2:
     distr_id = cnvtreal(co.param)
    OF 3:
     run_type_cd = cnvtreal(co.param)
    OF 4:
     template_id = cnvtreal(co.param)
    OF 5:
     run_type_mean = co.param
    OF 7:
     pending_flag = cnvtint(co.param)
    OF 8:
     mcis_ind = cnvtint(co.param)
    OF 9:
     drt_criteria = cnvtint(co.param)
    OF 10:
     default_output_dest_cd = cnvtreal(co.param)
    OF 14:
     file_storage_cd = cnvtreal(co.param)
    OF 15:
     sort_seq_cd = cnvtreal(co.param)
    OF 16:
     def_chart = cnvtint(co.param)
    OF 17:
     file_storage_location = co.param
    OF 18:
     cross_encntr_law_id = cnvtreal(co.param)
    OF 19:
     order_doc_flag = cnvtint(co.param)
    OF 20:
     prov_routing_flag = cnvtint(co.param)
    OF 21:
     chart_route_id = cnvtreal(co.param)
    OF 22:
     exp_ind = cnvtint(co.param)
    OF 23:
     op_mask_id = cnvtreal(co.param)
    OF 24:
     ftp_location = co.param
    OF 25:
     sending_org_id = cnvtreal(co.param)
   ENDCASE
   IF (exp_ind=exclude_exp_prov_ind)
    exp_prov_parser = "epr.expiration_ind = 0"
   ELSE
    exp_prov_parser = "1=1"
   ENDIF
   IF (co.param_type_flag=6
    AND co.param > "0"
    AND trim(co.param) != "Author"
    AND trim(co.param) != "Reviewer")
    prov_no_cnt += 1
    IF (co.param="ALL")
     all_flag = "ALL", prov->prov_no = "all_flag = 'ALL'", consult_doc_ind = 1,
     order_doc_ind = 1, consult_encntr_ind = 1, consult_order_ind = 1,
     cc_consult_ind = 1
     IF (scope=6)
      ncopytoauthorind = 1, ncopytoreviewerind = 1
     ENDIF
    ELSEIF (prov_no_cnt > 1)
     prov->prov_no = build(prov->prov_no,",",co.param)
    ELSE
     prov->prov_no = concat("cpr2.chart_prsnl_r_type_cd IN (",co.param)
    ENDIF
    IF (cnvtreal(co.param)=consult_doc_cd)
     consult_doc_ind = 1
    ENDIF
    IF (cnvtreal(co.param)=order_doc_cd)
     order_doc_ind = 1
    ENDIF
   ELSEIF (co.param_type_flag=6
    AND co.param="Author")
    ncopytoauthorind = 1
   ELSEIF (co.param_type_flag=6
    AND co.param="Reviewer")
    ncopytoreviewerind = 1
   ENDIF
   IF (co.param_type_flag=12
    AND co.param > "0.0")
    acthold_cnt += 1
    IF (acthold_cnt > 1)
     acthold->acthold_cd = build(acthold->acthold_cd,",",co.param)
    ELSE
     acthold->acthold_cd = concat("o.activity_type_cd+0 IN (",co.param)
    ENDIF
   ENDIF
   IF (co.param_type_flag=13
    AND co.param > "0.0")
    ordstat_cnt += 1
    IF (ordstat_cnt > 1)
     ordstat->ordstat_cd = build(ordstat->ordstat_cd,",",co.param)
    ELSE
     ordstat->ordstat_cd = concat("o.order_status_cd NOT IN (",co.param)
    ENDIF
   ENDIF
   IF (co.param_type_flag=6
    AND cnvtreal(co.param)=consult_encntr_cd)
    consult_encntr_ind = 1, prov->prov_no = build(prov->prov_no,",",consult_doc_cd)
   ENDIF
   IF (co.param_type_flag=6
    AND cnvtreal(co.param)=consult_order_cd)
    consult_order_ind = 1, prov->prov_no = build(prov->prov_no,",",consult_doc_cd)
   ENDIF
   IF (co.param_type_flag=6
    AND cnvtreal(co.param)=cc_provider_cd)
    cc_consult_ind = 1, prov->prov_no = build(prov->prov_no,",",cc_provider_cd)
   ENDIF
  FOOT REPORT
   ordstat2 = build("o.order_status_cd NOT IN (",value(canceled_cd),",",value(deleted_cd),",",
    value(discontinued_cd),",",value(voided_with_result_cd),",",value(unscheduled_cd),
    ",",value(transfer_canceled_cd),")")
   IF (all_flag != "ALL"
    AND prov_no_cnt >= 1)
    prov->prov_no = concat(trim(prov->prov_no),")")
   ELSEIF (prov_no_cnt=0
    AND scope != 6)
    prov->prov_no = build("cpr2.chart_prsnl_r_type_cd = ",admit_doc)
   ELSEIF (prov_no_cnt=0
    AND scope=6)
    prov->prov_no = "1=0"
   ENDIF
   IF (acthold_cnt > 0)
    acthold->acthold_cd = concat(trim(acthold->acthold_cd),")")
   ENDIF
   IF (ordstat_cnt > 0)
    ordstat->ordstat_cd = concat(trim(ordstat->ordstat_cd),")")
   ENDIF
   IF (prov_routing_flag > 0)
    prov_routing_clause = " (select cop.prsnl_id from charting_operations_prsnl cop "
    IF (prov_routing_flag=3
     AND  NOT (multitenancy=1
     AND is_logical_domain_enabled=0))
     prov_routing_clause = concat(prov_routing_clause,
" where cop.charting_operations_id = charting_operations_id or    	 (cop.charting_operations_id = 0 and pr.logical_domain_i\
d = logical_domain_id))\
")
    ELSEIF (prov_routing_flag < 3)
     prov_routing_clause = concat(prov_routing_clause,
      " where cop.charting_operations_id = charting_operations_id)")
    ENDIF
    IF (prov_routing_flag=1)
     prov_routing_auth_review_clause = concat("cep.action_prsnl_id+0 in ",prov_routing_clause),
     prov_routing_consult_clause = concat("od.oe_field_value in ",prov_routing_clause),
     prov_routing_clause = concat("cpr2.prsnl_person_id in ",prov_routing_clause)
    ELSEIF (((prov_routing_flag=2) OR (prov_routing_flag=3)) )
     prov_routing_auth_review_clause = concat("cep.action_prsnl_id+0 not in ",prov_routing_clause),
     prov_routing_consult_clause = concat("od.oe_field_value not in ",prov_routing_clause),
     prov_routing_clause = concat(" cpr2.prsnl_person_id not in ",prov_routing_clause)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ERROR! - This Operation has not been built correctly in the operations portion of the distribution tool, Exiting Job."
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 IF (sending_org_id > 0)
  SELECT INTO "nl:"
   p.phone_num
   FROM phone p
   PLAN (p
    WHERE p.parent_entity_id=sending_org_id
     AND p.parent_entity_name=organization_entity
     AND p.phone_type_cd=intsecemail_cd
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    sender_email = p.phone_num
   WITH nocounter
  ;end select
 ENDIF
 IF (op_mask_id > 0)
  SELECT INTO "nl:"
   cm.cr_mask_text
   FROM cr_mask cm
   WHERE cm.cr_mask_id=op_mask_id
   DETAIL
    file_mask = cm.cr_mask_text
   WITH nocounter
  ;end select
 ENDIF
 SET request_type = 4
 IF (mcis_ind=1)
  SET request_type = 2
 ENDIF
 SET message_log = "**************************************************"
 CALL update_log(trim(message_log))
 SET message_log = concat("Begin Batch Job -- ",trim(batch_selection)," (test_ind = ",trim(cnvtstring
   (0)),")")
 CALL update_log(trim(message_log))
 SET message_log = concat("Begin Ops_Date = ",datetimezoneformat(sysdate,curtimezoneapp,
   format_timezone))
 CALL update_log(trim(message_log))
 SET message_log = concat("Actual Start Date = ",datetimezoneformat(beg_time,curtimezoneapp,
   format_timezone))
 CALL update_log(trim(message_log))
 IF (drt_criteria=0
  AND trim(cnvtupper(substring(1,5,output_dist)))="OOOOO")
  SET ooooo_ind = 1
  SET message_log =
  "This job is using order doctor routing by placing OOOOO in output_dist of ops job template."
  CALL update_log(trim(message_log))
 ENDIF
 IF (default_output_dest_cd > 0.0)
  SELECT INTO "nl:"
   rdt.output_format_cd
   FROM output_dest od,
    remote_device rd,
    remote_device_type rdt
   PLAN (od
    WHERE od.output_dest_cd=default_output_dest_cd)
    JOIN (rd
    WHERE rd.device_cd=od.device_cd)
    JOIN (rdt
    WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
   DETAIL
    default_output_device_cd = rdt.output_format_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (scope != 4
  AND drt_criteria IN (3, 4))
  SET drt_criteria = 0
  SET message_log = build(
   "WARNING! - Distribution routing selection is not allowed for selected scope",
   " -- default printer used.")
  CALL update_log(trim(message_log))
 ENDIF
 IF (((scope IN (1, 5)
  AND run_type_cd != cumulative_cd) OR (scope=6
  AND  NOT (run_type_cd IN (cumulative_cd, final_cd, cumadd_cd)))) )
  SET run_type_cd = cumulative_cd
  SET message_log = "WARNING! - Invalid run-type with scope selection (adjusting to Cumulative)."
  CALL update_log(trim(message_log))
 ENDIF
 SELECT INTO "nl:"
  cdfv.distribution_id
  FROM chart_dist_filter_value cdfv,
   chart_dist_filter cdf
  PLAN (cdf
   WHERE cdf.distribution_id=distr_id
    AND cdf.type_flag=2)
   JOIN (cdfv
   WHERE cdfv.distribution_id=cdf.distribution_id
    AND cdfv.type_flag=2)
  ORDER BY cdf.type_flag, cdfv.parent_entity_id, cdfv.reltn_type_cd
  HEAD REPORT
   provider_cnt = 0
  HEAD cdf.type_flag
   IF (cdf.type_flag=2)
    IF (cdf.included_flag=1)
     provider_include_flag = 1
    ELSEIF (cdf.included_flag=0)
     provider_include_flag = 0
    ENDIF
   ENDIF
  HEAD cdfv.parent_entity_id
   provider_cnt += 1
   IF (mod(provider_cnt,10)=1)
    stat = alterlist(dist_providers->qual,(provider_cnt+ 9))
   ENDIF
   dist_providers->qual[provider_cnt].provider_id = cdfv.parent_entity_id, relationship_cnt = 0
  DETAIL
   relationship_cnt += 1
   IF (mod(relationship_cnt,10)=1)
    stat = alterlist(dist_providers->qual[provider_cnt].provider_types,(relationship_cnt+ 9))
   ENDIF
   dist_providers->qual[provider_cnt].provider_types[relationship_cnt].provider_type = cdfv
   .reltn_type_cd
  FOOT  cdfv.parent_entity_id
   stat = alterlist(dist_providers->qual[provider_cnt].provider_types,relationship_cnt)
  FOOT  cdf.type_flag
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(dist_providers->qual,provider_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set IN (333, 331)
   AND cv.active_ind=1
  HEAD REPORT
   cs333_cnt = 0, cs331_cnt = 0
  DETAIL
   IF (cv.code_set=333)
    cs333_cnt += 1
    IF (cs333_cnt=1)
     cs333_parser->statement_cdfv = build("cdfv.reltn_type_cd in (",cv.code_value), cs333_parser->
     statement_clfv = build("clfv.reltn_type_cd in (",cv.code_value)
    ELSE
     cs333_parser->statement_cdfv = build(cs333_parser->statement_cdfv,",",cv.code_value),
     cs333_parser->statement_clfv = build(cs333_parser->statement_clfv,",",cv.code_value)
    ENDIF
   ELSEIF (cv.code_set=331)
    cs331_cnt += 1
    IF (cs331_cnt=1)
     cs331_parser->statement_cdfv = build("cdfv.reltn_type_cd in (",cv.code_value), cs331_parser->
     statement_clfv = build("clfv.reltn_type_cd in (",cv.code_value)
    ELSE
     cs331_parser->statement_cdfv = build(cs331_parser->statement_cdfv,",",cv.code_value),
     cs331_parser->statement_clfv = build(cs331_parser->statement_clfv,",",cv.code_value)
    ENDIF
   ENDIF
  FOOT REPORT
   IF (cs333_cnt > 0)
    cs333_parser->statement_cdfv = build(cs333_parser->statement_cdfv,")"), cs333_parser->
    statement_clfv = build(cs333_parser->statement_clfv,")")
   ENDIF
   IF (cs331_cnt > 0)
    cs331_parser->statement_cdfv = build(cs331_parser->statement_cdfv,")"), cs331_parser->
    statement_clfv = build(cs331_parser->statement_clfv,")")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cdfv.reltn_type_cd
  FROM chart_dist_filter_value cdfv
  WHERE cdfv.distribution_id=distr_id
   AND cdfv.type_flag=2
  HEAD REPORT
   person_level_cnt = 0, encntr_level_cnt = 0, order_level_cnt = 0
  DETAIL
   IF (parser(cs331_parser->statement_cdfv))
    person_level_cnt += 1
   ENDIF
   IF (parser(cs333_parser->statement_cdfv))
    encntr_level_cnt += 1
   ENDIF
   IF (cdfv.reltn_type_cd IN (order_doc_cd, consult_doc_cd))
    order_level_cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  cd.distribution_id, cd.days_till_chart, cd.reader_group,
  cdf.type_flag, cdf.included_flag, cdfv.parent_entity_id,
  loc_type_meaning =
  IF (cdf.type_flag=3) uar_get_code_meaning(cdfv.parent_entity_id)
  ELSE " "
  ENDIF
  FROM chart_distribution cd,
   chart_dist_filter cdf,
   chart_dist_filter_value cdfv
  PLAN (cd
   WHERE cd.distribution_id=distr_id)
   JOIN (cdf
   WHERE cd.distribution_id=cdf.distribution_id)
   JOIN (cdfv
   WHERE cdf.distribution_id=cdfv.distribution_id
    AND cdf.type_flag=cdfv.type_flag)
  ORDER BY cdf.type_flag
  HEAD REPORT
   dist_descr = trim(cd.dist_descr), days_till_chart = cd.days_till_chart, initial_lookback_ind = cd
   .max_lookback_ind,
   initial_lookback_days = cd.max_lookback_days, initial_lookback_dt_tm = cd.max_lookback_dt_tm,
   first_qual_lookback_ind = cd.print_lookback_ind,
   first_qual_lookback_days = cd.first_qualification_days, first_qual_lookback_dt_tm = cd
   .first_qualification_dt_tm, absolute_lookback_ind = cd.absolute_lookback_ind,
   absolute_lookback_days = cd.absolute_qualification_days, absolute_lookback_dt_tm = cd
   .absolute_qualification_dt_tm, dist_type = cd.dist_type,
   loc_type_cnt = 0, reader_group = trim(cd.reader_group)
   IF (is_logical_domain_enabled=1)
    logical_domain_parser = build("org.logical_domain_id = ",cd.logical_domain_id)
   ENDIF
   IF (trim(run_type_mean) IN ("REPLACEMENT", "CUTOFF"))
    cutoff_pages = cd.cutoff_pages, cutoff_days = cd.cutoff_days, cutoff_and_or_ind = cd
    .cutoff_and_or_ind
   ENDIF
   join_tables = "encounter e", select_fields1 = build("e.encntr_id,e.person_id,",
    "e.loc_facility_cd,e.loc_building_cd,e.loc_nurse_unit_cd,","e.loc_room_cd,e.loc_bed_cd"),
   select_fields2 = build(",e.organization_id,e.create_dt_tm,e.encntr_type_cd")
   IF (run_type_mean IN ("FINAL", "ADDENDUM", "CUM ADDENDUM"))
    dischg_cutoff_days = cd.days_till_chart, dischg = build(
     "datetimediff(cnvtdatetime(dist_date),e.disch_dt_tm) >= dischg_cutoff_days")
   ELSEIF (cd.dist_type=1)
    dischg = "e.disch_dt_tm = null"
   ELSEIF (cd.dist_type=2)
    dischg = "e.disch_dt_tm != null"
   ELSE
    dischg = "0=0"
   ENDIF
   et_cnt = 0, cl_cnt = 0, ms_cnt = 0,
   cs_cnt = 0
  HEAD cdf.type_flag
   IF (cdf.type_flag=0)
    et_included = cdf.included_flag
   ELSEIF (cdf.type_flag=1)
    cl_included = cdf.included_flag
   ELSEIF (cdf.type_flag=3)
    lc_included = cdf.included_flag
   ELSEIF (cdf.type_flag=4)
    ms_included = cdf.included_flag
   ELSEIF (cdf.type_flag=5)
    cs_included = cdf.included_flag
   ENDIF
  DETAIL
   IF (cdfv.type_flag=0)
    et_cnt += 1
    IF (mod(et_cnt,10)=1)
     stat = alterlist(filter_rec->type_flag[1].qual,(et_cnt+ 9))
    ENDIF
    filter_rec->type_flag[1].qual[et_cnt].parent_entity_id = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=1)
    cl_cnt += 1
    IF (mod(cl_cnt,10)=1)
     stat = alterlist(filter_rec->type_flag[2].qual,(cl_cnt+ 9))
    ENDIF
    filter_rec->type_flag[2].qual[cl_cnt].parent_entity_id = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=3)
    loc_type_cnt += 1
   ELSEIF (cdfv.type_flag=4)
    ms_cnt += 1
    IF (mod(ms_cnt,10)=1)
     stat = alterlist(filter_rec->type_flag[5].qual,(ms_cnt+ 9))
    ENDIF
    filter_rec->type_flag[5].qual[ms_cnt].parent_entity_id = cdfv.parent_entity_id
   ELSEIF (cdfv.type_flag=5)
    cs_cnt += 1
    IF (mod(cs_cnt,10)=1)
     stat = alterlist(filter_rec->type_flag[6].qual,(cs_cnt+ 9))
    ENDIF
    filter_rec->type_flag[6].qual[cs_cnt].parent_entity_id = cdfv.parent_entity_id
   ENDIF
  FOOT  cdf.type_flag
   IF (cdf.type_flag=0)
    stat = alterlist(filter_rec->type_flag[1].qual,et_cnt)
   ELSEIF (cdf.type_flag=1)
    stat = alterlist(filter_rec->type_flag[2].qual,cl_cnt)
   ELSEIF (cdf.type_flag=4)
    stat = alterlist(filter_rec->type_flag[5].qual,ms_cnt)
   ELSEIF (cdf.type_flag=5)
    stat = alterlist(filter_rec->type_flag[6].qual,cs_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ERROR! - Distribution information is not set up correctly via distribution tool, Exiting Job."
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 IF (trim(run_type_mean)="FINAL")
  SET code_mean = "c.cdf_meaning = 'FINAL'"
 ELSEIF (trim(run_type_mean)="ADDENDUM")
  IF (trim(reader_group)="")
   SET code_mean = "c.cdf_meaning IN ('FINAL','ADDENDUM','CUM ADDENDUM')"
  ELSE
   SET code_mean =
   "c.cdf_meaning IN ('FINAL','ADDENDUM','CUM ADDENDUM','CUMULATIVE','PERIODIC','REPLACEMENT','CUTOFF')"
  ENDIF
 ELSEIF (trim(run_type_mean)="INTERIM-ANY")
  SET code_mean = concat("c.cdf_meaning IN ('INTERIM-ANY','PERIODIC','CUMULATIVE',",
   "'SPLIT CUM','INTERIM-CUM','REPLACEMENT','CUTOFF','FINAL','ADDENDUM','CUM ADDENDUM')")
 ELSEIF (trim(run_type_mean)="PERIODIC")
  SET code_mean = "c.cdf_meaning = 'PERIODIC'"
 ELSEIF (trim(run_type_mean)="CUMULATIVE")
  SET code_mean = "c.cdf_meaning = 'CUMULATIVE'"
 ELSEIF (trim(run_type_mean)="CUM ADDENDUM")
  SET code_mean = "c.cdf_meaning IN ('FINAL','ADDENDUM','CUM ADDENDUM')"
 ELSEIF (trim(run_type_mean)="SPLIT CUM")
  SET code_mean = "c.cdf_meaning IN ('CUMULATIVE','SPLIT CUM','REPLACEMENT','CUTOFF','PERIODIC')"
  SET cutoff_code_mean = "c.cdf_meaning IN ('CUMULATIVE','REPLACEMENT','CUTOFF','PERIODIC')"
 ELSEIF (trim(run_type_mean)="INTERIM-CUM")
  SET code_mean =
  "c.cdf_meaning IN ('CUMULATIVE','SPLIT CUM','INTERIM-ANY','PERIODIC','INTERIM-CUM')"
  SET cutoff_code_mean = "c.cdf_meaning IN ('CUMULATIVE','SPLIT CUM','PERIODIC')"
 ELSEIF (trim(run_type_mean)="REPLACEMENT")
  SET code_mean = "c.cdf_meaning IN ('SPLIT CUM','REPLACEMENT')"
 ELSEIF (trim(run_type_mean)="CUTOFF")
  SET code_mean = "c.cdf_meaning IN ('SPLIT CUM','CUTOFF')"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ERROR! - Incorrect run type has been defined in the operations portion of the distribution tool, Exiting Job."
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  c.code_value, c.active_ind
  FROM code_value c
  WHERE c.code_value=run_type_cd
   AND c.active_ind=1
   AND c.code_set=22550
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ERROR! - Invalid run type was set in the operations portion of the distribution tool, Exiting Job."
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=22550
   AND c.active_ind=1
   AND parser(trim(code_mean))
  HEAD REPORT
   code_cnt = 0, code_mean = "cr.dist_run_type_cd+0 IN ("
  DETAIL
   code_cnt += 1
   IF (code_cnt > 1)
    code_mean = build(code_mean,",",c.code_value)
   ELSE
    code_mean = build(code_mean,c.code_value)
   ENDIF
  FOOT REPORT
   code_mean = build(code_mean,")")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ERROR! - Invalid run type was set in the operations portion of the distribution tool, Exiting Job."
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 IF (trim(run_type_mean) IN ("SPLIT CUM", "INTERIM-CUM"))
  SELECT INTO "NL:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=22550
    AND c.active_ind=1
    AND parser(trim(cutoff_code_mean))
   HEAD REPORT
    code_cnt = 0, cutoff_code_mean = "cr.dist_run_type_cd IN ("
   DETAIL
    code_cnt += 1
    IF (code_cnt > 1)
     cutoff_code_mean = build(cutoff_code_mean,",",c.code_value)
    ELSE
     cutoff_code_mean = build(cutoff_code_mean,c.code_value)
    ENDIF
   FOOT REPORT
    cutoff_code_mean = build(cutoff_code_mean,")")
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "ERROR! - Invalid run type was set in the operations portion of the distribution tool, Exiting Job."
   SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
   CALL update_log(trim(message_log))
   GO TO exit_script
  ENDIF
 ENDIF
 CALL update_log("* * OPERATIONS PARAMETERS * * ")
 CALL update_log(concat("  -  SCOPE               = ",cnvtstring(scope)))
 CALL update_log(concat("  -  DISTRIBUTION_ID     = ",cnvtstring(distr_id)," -- ",dist_descr))
 CALL update_log(concat("  -  RUN_TYPE            = ",trim(run_type_mean)))
 CALL update_log(concat("  -  TEMPLATE_ID         = ",cnvtstring(template_id)))
 CALL update_log(concat("  -  PENDING FLAG        = ",cnvtstring(pending_flag)))
 CALL update_log(concat("  -  ROUTING CRITERIA    = ",cnvtstring(drt_criteria)))
 CALL update_log(concat("  -  DEFAULT PRINTER     = ",cnvtstring(default_output_dest_cd)))
 CALL update_log(concat("  -  SORT SEQUENCE       = ",cnvtstring(sort_seq_cd)," -- ",
   uar_get_code_display(sort_seq_cd)))
 CALL update_log(concat("  -  CROSS-ENCNTR LAW_ID = ",cnvtstring(cross_encntr_law_id)))
 CALL update_log("* * END OPERATIONS PARAMETERS * *")
 SET chart_req_qual = fillstring(100," ")
 IF (trim(reader_group) > " ")
  SET chart_req_qual = "reader_group = TRIM(cr.reader_group)"
  SET message_log = concat("CR_REPORT_REQUEST qual by Reader Group = ",reader_group)
  CALL update_log(trim(message_log))
 ELSE
  SET chart_req_qual = "distr_id = cr.distribution_id+0"
  SET message_log = concat("CR_REPORT_REQUEST qual by Dist_Id = ",cnvtstring(distr_id))
  CALL update_log(trim(message_log))
 ENDIF
 SELECT INTO "nl:"
  value1 = max(cde.dist_run_dt_tm)
  FROM cr_dist_exec cde
  WHERE cde.distribution_id=distr_id
   AND cde.dist_run_type_cd=run_type_cd
  HEAD REPORT
   IF (run_type_cd IN (final_cd, addend_cd, cumadd_cd)
    AND days_till_chart > 0)
    last_dist_run_dt_tm = cnvtdatetime(datetimeadd(value1,(days_till_chart * - (1))))
   ELSE
    last_dist_run_dt_tm = cnvtdatetime(value1)
   ENDIF
  WITH nocounter
 ;end select
 IF (last_dist_run_dt_tm <= 0)
  SELECT INTO "nl:"
   value1 = max(cr.dist_run_dt_tm)
   FROM cr_report_request cr
   WHERE cr.distribution_id=distr_id
    AND cr.dist_run_type_cd=run_type_cd
   HEAD REPORT
    IF (run_type_cd IN (final_cd, addend_cd, cumadd_cd)
     AND days_till_chart > 0)
     last_dist_run_dt_tm = cnvtdatetime(datetimeadd(value1,(days_till_chart * - (1))))
    ELSE
     last_dist_run_dt_tm = cnvtdatetime(value1)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (last_dist_run_dt_tm <= 0)
  SET initial_distribution_run = 1
  IF (initial_lookback_ind=lookback_option_date)
   SET last_dist_run_dt_tm = initial_lookback_dt_tm
  ELSE
   SET initial_lookback_dt_tm = cnvtdatetime(datetimeadd(cnvtdatetime(dist_date),(
     initial_lookback_days * - (1))))
   SET last_dist_run_dt_tm = initial_lookback_dt_tm
  ENDIF
  SET message_log = "* INITIAL DISTRIBUTION RUN (FIRST EXECUTION WITH THIS RUN-TYPE) *"
  CALL update_log(trim(message_log))
 ENDIF
 SET message_log = concat("LAST DISTRIBUTION RUN date/time = ",datetimezoneformat(last_dist_run_dt_tm,
   curtimezoneapp,format_timezone))
 CALL update_log(trim(message_log))
 SET order_change_cnt = 0
 SET size_d = 0
 SET cp_encntr_cnt = 0
 IF (cs_cnt > 0.0)
  SET cs_where_clause = buildcontribsysclause(null)
  SET cs_where_clause2 = buildcontribsysclausece2(null)
 ENDIF
 EXECUTE bhs_dist_read_hne_file
 SET cp_encntr_cnt = size(cp_encntr->encntr_list,5)
 IF (cp_encntr_cnt > 0)
  CALL echo(build("Encounter count before dup logic: ",cp_encntr_cnt))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cp_encntr_cnt))
   ORDER BY cp_encntr->encntr_list[d.seq].encntr_id
   HEAD REPORT
    distinct_cp_encntr_cnt = 0
   DETAIL
    IF ((cp_encntr->encntr_list[d.seq].encntr_id != last_encntr_id))
     distinct_cp_encntr_cnt += 1
     IF (mod(distinct_cp_encntr_cnt,100)=1)
      stat = alterlist(distinct_cp_encntr->encntr_list,(distinct_cp_encntr_cnt+ 99))
     ENDIF
     distinct_cp_encntr->encntr_list[distinct_cp_encntr_cnt].encntr_id = cp_encntr->encntr_list[d.seq
     ].encntr_id, distinct_cp_encntr->encntr_list[distinct_cp_encntr_cnt].person_id = cp_encntr->
     encntr_list[d.seq].person_id
    ENDIF
    last_encntr_id = cp_encntr->encntr_list[d.seq].encntr_id
   FOOT REPORT
    stat = alterlist(distinct_cp_encntr->encntr_list,distinct_cp_encntr_cnt)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD cp_encntr
 IF (distinct_cp_encntr_cnt=0)
  SET message_log = "INFO! - No Encounters Qualified - Exiting Job."
  CALL update_log(trim(message_log))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET message_log = concat("Total Encounter Count = ",cnvtstring(distinct_cp_encntr_cnt))
  CALL update_log(trim(message_log))
 ENDIF
 SET provider_reltn_cnt = 0
 FREE RECORD provider_reltn_rec
 DELETE  FROM chart_exclude exc
  SET exc.seq = 1
  WHERE exc.distribution_id=distr_id
  WITH nocounter
 ;end delete
 SET exclude_cnt = 0
 IF (provider_include_flag=0)
  IF (provider_reltn_cnt > 0)
   SET exclude_cnt = distinct_prov_reltn_cnt
   INSERT  FROM chart_exclude exc,
     (dummyt d  WITH seq = value(distinct_prov_reltn_cnt))
    SET exc.seq = 1, exc.distribution_id = distr_id, exc.encntr_id = distinct_prov_reltn_rec->qual[d
     .seq].encntr_id
    PLAN (d)
     JOIN (exc)
    WITH nocounter
   ;end insert
   CALL echo(build("# of Encounters inserted into chart_exclude = ",curqual))
  ENDIF
 ENDIF
 SET size_providers = size(dist_providers->qual,5)
 IF (size_providers > 0
  AND distinct_prov_reltn_cnt=0
  AND provider_include_flag=1)
  SET message_log =
  "INFO! - No Encounters Qualified for Provider Relationships Chosen - Exiting Job."
  CALL update_log(trim(message_log))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET provider_reltn_cnt = size(distinct_prov_reltn_rec->qual,5)
 SET cp_encntr_cnt = size(distinct_cp_encntr->encntr_list,5)
 SET message_log = concat("Encounter count = ",trim(cnvtstring(cp_encntr_cnt)),
  " before encounter criteria select")
 CALL update_log(trim(message_log))
 SET idx = 0
 SET idxstart = 1
 SET join_tables = "encounter e"
 IF (provider_include_flag=1)
  SET plan_statement = concat(
   "PLAN e WHERE expand(idx, idxStart, distinct_prov_reltn_cnt,e.encntr_id, distinct_prov_reltn_rec->qual[idx]->encntr_id)",
   " AND ",trim(dischg))
 ELSEIF (provider_include_flag=0)
  IF (exclude_cnt > 0)
   SET join_tables = build(join_tables,","," encounter e2")
  ENDIF
  SET plan_statement = concat(
   "PLAN e WHERE expand(idx, idxStart, distinct_cp_encntr_cnt,e.encntr_id,distinct_cp_encntr->encntr_list[idx]->encntr_id)",
   " AND ",trim(dischg))
 ELSEIF ( NOT (provider_include_flag IN (0, 1)))
  SET plan_statement = concat(
   "PLAN e WHERE expand(idx, idxStart, distinct_cp_encntr_cnt,e.encntr_id,distinct_cp_encntr->encntr_list[idx]->encntr_id)",
   " AND ",trim(dischg))
 ENDIF
 IF (exclude_cnt > 0
  AND provider_include_flag=0)
  SET message_log = concat("# of Encounters Excluded with Providers = ",cnvtstring(exclude_cnt))
  CALL update_log(trim(message_log))
 ELSEIF (exclude_cnt=0
  AND provider_include_flag=0)
  SET message_log = "# of Encounters Excluded with Providers = 0."
  CALL update_log(trim(message_log))
 ENDIF
 DELETE  FROM chart_temp ct
  SET ct.seq = 1
  WHERE ct.distribution_id=distr_id
  WITH nocounter
 ;end delete
 CALL echo("YOYOYO")
 CALL echorecord(distinct_cp_encntr)
 FREE RECORD temp_encntr
 RECORD temp_encntr(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 create_dt_tm = dq8
     2 encntr_type_cd = f8
     2 organization_id = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
 )
 SET idx = 0
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = 'SELECT DISTINCT INTO "nl:"'
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = trim(select_fields1)
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = trim(select_fields2)
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = concat(" FROM ",trim(join_tables))
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = trim(plan_statement)
 SET dist_flag = 0
 CALL build_encntr_parser(dist_flag)
 IF (provider_include_flag=0
  AND exclude_cnt > 0)
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "JOIN e2 where e2.encntr_id = e.encntr_id AND NOT EXISTS"
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "(SELECT exc.encntr_id FROM"
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "chart_exclude exc WHERE e2.encntr_id = exc.encntr_id"
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "and exc.distribution_id = distr_id)"
 ENDIF
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " ORDER e.encntr_id"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " HEAD REPORT"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " encntr_cnt = 0"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " DETAIL"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " encntr_cnt = encntr_cnt + 1"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " IF (MOD(encntr_cnt, 100) = 1)"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " stat = alterlist(temp_encntr->qual, encntr_cnt + 99)"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " ENDIF"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " temp_encntr->qual[encntr_cnt]->encntr_id = e.encntr_id"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " temp_encntr->qual[encntr_cnt]->person_id = e.person_id"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement =
 " temp_encntr->qual[encntr_cnt]->create_dt_tm = cnvtdatetime(e.create_dt_tm)"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement =
 " temp_encntr->qual[encntr_cnt]->encntr_type_cd = e.encntr_type_cd"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement =
 " temp_encntr->qual[encntr_cnt]->organization_id = e.organization_id"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement =
 " temp_encntr->qual[encntr_cnt]->loc_facility_cd = e.loc_facility_cd"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement =
 " temp_encntr->qual[encntr_cnt]->loc_building_cd = e.loc_building_cd"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement =
 " temp_encntr->qual[encntr_cnt]->loc_nurse_unit_cd = e.loc_nurse_unit_cd"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " temp_encntr->qual[encntr_cnt]->loc_room_cd = e.loc_room_cd"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " temp_encntr->qual[encntr_cnt]->loc_bed_cd = e.loc_bed_cd"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " FOOT REPORT"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = " stat = ALTERLIST(temp_encntr->qual, encntr_cnt)"
 SET idx += 1
 SET stat = alterlist(parser_rec->qual,idx)
 SET parser_rec->qual[idx].statement = "WITH nocounter, EXPAND = 1 go"
 FOR (x = 1 TO idx)
  CALL echo(parser_rec->qual[x].statement)
  CALL parser(parser_rec->qual[x].statement)
 ENDFOR
 SET size_temp_encntr = 0
 SET size_temp_encntr = size(temp_encntr->qual,5)
 IF (size_temp_encntr > 0)
  INSERT  FROM chart_temp ct,
    (dummyt d2  WITH seq = value(size_temp_encntr))
   SET ct.seq = 1, ct.encntr_id = temp_encntr->qual[d2.seq].encntr_id, ct.person_id = temp_encntr->
    qual[d2.seq].person_id,
    ct.create_dt_tm = cnvtdatetime(temp_encntr->qual[d2.seq].create_dt_tm), ct.encntr_type_cd =
    temp_encntr->qual[d2.seq].encntr_type_cd, ct.loc_facility_cd = temp_encntr->qual[d2.seq].
    loc_facility_cd,
    ct.loc_building_cd = temp_encntr->qual[d2.seq].loc_building_cd, ct.loc_nurse_unit_cd =
    temp_encntr->qual[d2.seq].loc_nurse_unit_cd, ct.loc_room_cd = temp_encntr->qual[d2.seq].
    loc_room_cd,
    ct.loc_bed_cd = temp_encntr->qual[d2.seq].loc_bed_cd, ct.organization_id = temp_encntr->qual[d2
    .seq].organization_id, ct.distribution_id = distr_id
   PLAN (d2)
    JOIN (ct)
   WITH nocounter
  ;end insert
 ENDIF
 SET pat_distr = size_temp_encntr
 SET message_log = concat("Encounter count = ",trim(cnvtstring(pat_distr)),
  " after encounter criteria select")
 CALL update_log(trim(message_log))
 SET stat = initrec(distinct_cp_encntr)
 SET stat = alterlist(distinct_cp_encntr->encntr_list,size_temp_encntr)
 FOR (x = 1 TO size_temp_encntr)
  SET distinct_cp_encntr->encntr_list[x].person_id = temp_encntr->qual[x].person_id
  SET distinct_cp_encntr->encntr_list[x].encntr_id = temp_encntr->qual[x].encntr_id
 ENDFOR
 SET distinct_cnt = size(distinct_cp_encntr->encntr_list,5)
 IF (test_ind >= 100)
  CALL echorecord(distinct_cp_encntr)
 ENDIF
 FREE RECORD temp_encntr
 IF (pat_distr > 0)
  IF (initial_distribution_run=1)
   SET neverqualifiedlookback_dt_tm = initial_lookback_dt_tm
  ELSEIF (first_qual_lookback_ind=lookback_option_days)
   SET neverqualifiedlookback_dt_tm = cnvtdatetime(datetimeadd(cnvtdatetime(dist_date),(
     first_qual_lookback_days * - (1))))
  ELSEIF (first_qual_lookback_ind=lookback_option_previous_dist_run)
   IF (trim(run_type_mean)="FINAL")
    SET neverqualifiedlookback_dt_tm = cnvtdatetime("01-jan-1800")
   ELSE
    SET neverqualifiedlookback_dt_tm = cnvtlookbehind("1,H",cnvtdatetime(last_dist_run_dt_tm))
   ENDIF
  ELSEIF (first_qual_lookback_ind=lookback_option_admit_date)
   SET admit_date_option_flag = 1
  ELSE
   SET neverqualifiedlookback_dt_tm = first_qual_lookback_dt_tm
  ENDIF
  IF (admit_date_option_flag=1
   AND initial_distribution_run=0)
   SET message_log = concat(
    "LOOKBACK for encounters that have never qualified before using encounters create (admit) date.")
  ELSE
   SET message_log = concat(
    "LOOKBACK for encounters that have never qualified before using start date/time = ",
    datetimezoneformat(neverqualifiedlookback_dt_tm,curtimezoneapp,format_timezone))
  ENDIF
  CALL update_log(trim(message_log))
  SET count2 = 0
  SET repl_cutoff_exists = 0
  FREE RECORD initial_pool
  RECORD initial_pool(
    1 qual[*]
      2 temp_encntr = f8
      2 person_id = f8
      2 begin_dt_tm = dq8
      2 lookback_dt_tm = dq8
      2 temp_dontuse = i2
      2 non_ce_begin_dt_tm = dq8
  )
  IF (scope IN (2, 4))
   SELECT INTO "NL:"
    cd.encntr_id, previouslyqualified = decode(cr.seq,1,cd.seq,0,99), cr.encntr_id
    FROM cr_report_request cr,
     (dummyt d1  WITH seq = 1),
     chart_temp cd
    PLAN (cd
     WHERE cd.distribution_id=distr_id)
     JOIN (d1)
     JOIN (cr
     WHERE parser(trim(chart_req_qual))
      AND parser(trim(code_mean))
      AND cd.encntr_id=cr.encntr_id
      AND ((cr.scope_flag+ 0) IN (2, 4))
      AND cr.request_type_flag=4)
    ORDER BY cd.encntr_id, cnvtdatetime(cr.end_dt_tm) DESC
    HEAD REPORT
     count2 = 1, stat = alterlist(initial_pool->qual,10), non_ce_begin_dt_tm = cnvtdatetime(
      "01-jan-1800")
    HEAD cd.encntr_id
     splitcum_cutoffpage_ind = 0, repl_cutoffdays_ind = 0, donotuse_encntr_ind = 0,
     repl_cutoff_exists = 0, non_ce_begin_dt_tm = cnvtdatetime("01-jan-1800")
     IF (mod(count2,10)=1
      AND count2 != 1)
      stat = alterlist(initial_pool->qual,(count2+ 10))
     ENDIF
     IF (admit_date_option_flag=1)
      neverqualifiedlookback_dt_tm = cd.create_dt_tm
     ENDIF
     IF (previouslyqualified=0
      AND  NOT (trim(run_type_mean) IN ("ADDENDUM", "CUM ADDENDUM", "CUTOFF", "REPLACEMENT")))
      initial_pool->qual[count2].temp_encntr = cd.encntr_id, initial_pool->qual[count2].person_id =
      cd.person_id, initial_pool->qual[count2].temp_dontuse = 0,
      initial_pool->qual[count2].lookback_dt_tm = neverqualifiedlookback_dt_tm
      IF (trim(run_type_mean) IN ("INTERIM-ANY", "PERIODIC"))
       initial_pool->qual[count2].begin_dt_tm = neverqualifiedlookback_dt_tm, initial_pool->qual[
       count2].non_ce_begin_dt_tm = neverqualifiedlookback_dt_tm
      ELSE
       initial_pool->qual[count2].begin_dt_tm = cnvtdatetime("01-jan-1800"), initial_pool->qual[
       count2].non_ce_begin_dt_tm = cnvtdatetime("01-jan-1800")
      ENDIF
      count2 += 1
     ENDIF
     IF (previouslyqualified=1
      AND  NOT (trim(run_type_mean) IN ("FINAL", "REPLACEMENT", "CUTOFF")))
      initial_pool->qual[count2].temp_encntr = cd.encntr_id, initial_pool->qual[count2].person_id =
      cd.person_id, initial_pool->qual[count2].temp_dontuse = 0,
      initial_pool->qual[count2].lookback_dt_tm = cr.end_dt_tm
      IF ( NOT (trim(run_type_mean) IN ("CUMULATIVE", "CUM ADDENDUM", "SPLIT CUM", "INTERIM-CUM")))
       initial_pool->qual[count2].begin_dt_tm = cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm)),
       initial_pool->qual[count2].non_ce_begin_dt_tm =
       IF (cr.non_ce_end_dt_tm != null) cnvtlookahead("1,S",cnvtdatetime(cr.non_ce_end_dt_tm))
       ELSE cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm))
       ENDIF
      ELSE
       initial_pool->qual[count2].begin_dt_tm = cnvtdatetime("01-jan-1800"), initial_pool->qual[
       count2].non_ce_begin_dt_tm = cnvtdatetime("01-jan-1800")
      ENDIF
      count2 += 1
     ENDIF
    DETAIL
     IF (mod(count2,10)=1
      AND count2 != 1)
      stat = alterlist(initial_pool->qual,(count2+ 10))
     ENDIF
     IF (previouslyqualified=1
      AND trim(run_type_mean) IN ("CUTOFF", "REPLACEMENT")
      AND donotuse_encntr_ind=0)
      IF (splitcum_cutoffpage_ind=0
       AND cr.dist_run_type_cd=splitcum_cd
       AND cr.total_pages_nbr > cutoff_pages)
       splitcum_cutoffpage_ind = 1
      ENDIF
      IF (cr.dist_run_type_cd IN (replacement_cd, cutoff_cd))
       repl_cutoff_exists = 1
      ENDIF
      IF (repl_cutoffdays_ind=0
       AND cr.dist_run_type_cd=replacement_cd
       AND trim(run_type_mean)="REPLACEMENT"
       AND repl_cutoff_exists=1
       AND datetimecmp(cnvtdatetime(dist_date),cr.dist_run_dt_tm) > cutoff_days)
       repl_cutoffdays_ind = 1, begin_dt_tm = cnvtdatetime("01-JAN-1800"), non_ce_begin_dt_tm =
       cnvtdatetime("01-JAN-1800"),
       lookback_dt_tm = cr.end_dt_tm, donotuse_encntr_ind = 1
      ELSEIF (repl_cutoffdays_ind=0
       AND cr.dist_run_type_cd=cutoff_cd
       AND trim(run_type_mean)="CUTOFF"
       AND repl_cutoff_exists=1
       AND datetimecmp(cnvtdatetime(dist_date),cr.dist_run_dt_tm) > cutoff_days)
       repl_cutoffdays_ind = 1, begin_dt_tm = cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm)),
       non_ce_begin_dt_tm =
       IF (cr.non_ce_end_dt_tm != null) cnvtlookahead("1,S",cnvtdatetime(cr.non_ce_end_dt_tm))
       ELSE cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm))
       ENDIF
       ,
       lookback_dt_tm = cr.end_dt_tm, donotuse_encntr_ind = 1
      ELSEIF (repl_cutoff_exists=1
       AND splitcum_cutoffpage_ind=0
       AND repl_cutoffdays_ind=0)
       donotuse_encntr_ind = 1
      ELSEIF (repl_cutoff_exists=1
       AND ((splitcum_cutoffpage_ind=1) OR (repl_cutoffdays_ind=1)) )
       IF (trim(run_type_mean)="CUTOFF")
        lookback_dt_tm = cr.end_dt_tm, begin_dt_tm = cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm)),
        non_ce_begin_dt_tm =
        IF (cr.non_ce_end_dt_tm != null) cnvtlookahead("1,S",cnvtdatetime(cr.non_ce_end_dt_tm))
        ELSE cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm))
        ENDIF
       ELSE
        begin_dt_tm = cnvtdatetime("01-JAN-1800"), non_ce_begin_dt_tm = cnvtdatetime("01-JAN-1800"),
        lookback_dt_tm = cr.end_dt_tm
       ENDIF
       donotuse_encntr_ind = 1
      ENDIF
     ENDIF
    FOOT  cd.encntr_id
     IF (trim(run_type_mean) IN ("CUTOFF", "REPLACEMENT"))
      IF (repl_cutoff_exists=0
       AND datetimecmp(cnvtdatetime(dist_date),cd.create_dt_tm) > cutoff_days)
       repl_cutoffdays_ind = 1, begin_dt_tm = cnvtdatetime("01-jan-1800"), non_ce_begin_dt_tm =
       cnvtdatetime("01-JAN-1800"),
       lookback_dt_tm = neverqualifiedlookback_dt_tm
      ENDIF
      IF (((cutoff_and_or_ind=1
       AND splitcum_cutoffpage_ind=1
       AND repl_cutoffdays_ind=1) OR (cutoff_and_or_ind=2
       AND ((splitcum_cutoffpage_ind=1) OR (repl_cutoffdays_ind=1)) )) )
       IF (mod(count2,10)=1
        AND count2 != 1)
        stat = alterlist(initial_pool->qual,(count2+ 10))
       ENDIF
       initial_pool->qual[count2].temp_encntr = cd.encntr_id, initial_pool->qual[count2].person_id =
       cd.person_id, initial_pool->qual[count2].lookback_dt_tm = lookback_dt_tm,
       initial_pool->qual[count2].begin_dt_tm = begin_dt_tm, initial_pool->qual[count2].
       non_ce_begin_dt_tm = non_ce_begin_dt_tm, initial_pool->qual[count2].temp_dontuse = 0,
       count2 += 1
      ENDIF
     ENDIF
     IF (test_ind > 0
      AND (initial_pool->qual[(count2 - 1)].temp_encntr=cd.encntr_id))
      IF (count2=2)
       CALL echo("Encounter/Accession Qualification"),
       CALL echo(concat("run_type_mean = ",run_type_mean)),
       CALL echo(concat("code_mean = ",code_mean)),
       CALL echo(concat("chart_req_qual = ",chart_req_qual))
      ENDIF
      CALL echo(concat("ENCOUNTER ID: ",cnvtstring(initial_pool->qual[(count2 - 1)].temp_encntr))),
      CALL echo(concat("PreviouslyQualified ",cnvtstring(previouslyqualified))), temp_date =
      initial_pool->qual[(count2 - 1)].lookback_dt_tm,
      CALL echo(concat("CE LookBack: ",datetimezoneformat(temp_date,curtimezoneapp,format_timezone))),
      temp_date = initial_pool->qual[(count2 - 1)].begin_dt_tm,
      CALL echo(concat("CE Print Start Date/Time: ",datetimezoneformat(temp_date,curtimezoneapp,
        format_timezone))),
      temp_date = initial_pool->qual[(count2 - 1)].non_ce_begin_dt_tm,
      CALL echo(concat("Non-CE LookBack: ",datetimezoneformat(temp_date,curtimezoneapp,
        format_timezone)))
     ENDIF
    FOOT REPORT
     count2 -= 1, stat = alterlist(initial_pool->qual,count2)
    WITH nocounter, outerjoin = d1
   ;end select
   IF (trim(run_type_mean) IN ("SPLIT CUM", "INTERIM-CUM"))
    SELECT INTO "NL:"
     cr.encntr_id, cr.dist_run_dt_tm, cr.encntr_id
     FROM cr_report_request cr,
      (dummyt d1  WITH seq = value(count2))
     PLAN (d1)
      JOIN (cr
      WHERE (cr.encntr_id=initial_pool->qual[d1.seq].temp_encntr)
       AND parser(trim(chart_req_qual))
       AND ((cr.request_type_flag=4) OR (cr.request_type_flag=5))
       AND parser(trim(cutoff_code_mean)))
     ORDER BY cr.encntr_id, cnvtdatetime(cr.end_dt_tm) DESC
     HEAD cr.encntr_id
      initial_pool->qual[d1.seq].begin_dt_tm = cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm)),
      initial_pool->qual[d1.seq].non_ce_begin_dt_tm =
      IF (cr.non_ce_end_dt_tm != null) cnvtlookahead("1,S",cnvtdatetime(cr.non_ce_end_dt_tm))
      ELSE cnvtlookahead("1,S",cnvtdatetime(cr.end_dt_tm))
      ENDIF
     DETAIL
      row + 0
     WITH nocounter
    ;end select
   ENDIF
  ELSEIF (scope IN (1, 5))
   SELECT INTO "nl:"
    cd.encntr_id, previouslyqualified = decode(cr.seq,1,cd.seq,0,99), cr.encntr_id
    FROM cr_report_request cr,
     (dummyt d1  WITH seq = 1),
     chart_temp cd
    PLAN (cd
     WHERE cd.distribution_id=distr_id)
     JOIN (d1)
     JOIN (cr
     WHERE parser(trim(chart_req_qual))
      AND parser(trim(code_mean))
      AND cd.person_id=cr.person_id
      AND ((cr.scope_flag+ 0) IN (1, 5))
      AND cr.request_type_flag=4)
    ORDER BY cd.person_id, cnvtdatetime(cr.end_dt_tm) DESC
    HEAD REPORT
     CALL echo("Person/Xencounter Qualification"),
     CALL echo(concat("run_type_mean = ",run_type_mean)),
     CALL echo(concat("code_mean = ",code_mean)),
     CALL echo(concat("chart_req_qual = ",chart_req_qual)), count2 = 0, temp_lookback_dt_tm =
     cnvtdatetime("01-Jan-1800")
    HEAD cd.person_id
     CALL echo(concat("PERSON ID: ",cnvtstring(cd.person_id)))
     IF (admit_date_option_flag=1)
      neverqualifiedlookback_dt_tm = cd.create_dt_tm
     ENDIF
     IF (previouslyqualified=1)
      temp_lookback_dt_tm = cr.end_dt_tm
     ELSE
      temp_lookback_dt_tm = neverqualifiedlookback_dt_tm
     ENDIF
    DETAIL
     count2 += 1
     IF (mod(count2,10)=1)
      stat = alterlist(initial_pool->qual,(count2+ 9))
     ENDIF
     initial_pool->qual[count2].temp_encntr = cd.encntr_id, initial_pool->qual[count2].person_id = cd
     .person_id, initial_pool->qual[count2].temp_dontuse = 0,
     initial_pool->qual[count2].lookback_dt_tm = temp_lookback_dt_tm, initial_pool->qual[count2].
     begin_dt_tm = cnvtdatetime("01-Jan-1800"), initial_pool->qual[count2].non_ce_begin_dt_tm =
     cnvtdatetime("01-Jan-1800")
     IF (test_ind > 10)
      CALL echo(concat("ENCOUNTER ID: ",cnvtstring(initial_pool->qual[count2].temp_encntr))),
      CALL echo(concat("PreviouslyQualified ",cnvtstring(previouslyqualified))), temp_date =
      initial_pool->qual[count2].lookback_dt_tm,
      CALL echo(concat("CE LookBack: ",datetimezoneformat(temp_date,curtimezoneapp,format_timezone))),
      temp_date = initial_pool->qual[count2].begin_dt_tm,
      CALL echo(concat("CE Print Start Date/Time: ",datetimezoneformat(temp_date,curtimezoneapp,
        format_timezone))),
      temp_date = initial_pool->qual[count2].non_ce_begin_dt_tm,
      CALL echo(concat("Non-CE Print Start Date/Time: ",datetimezoneformat(temp_date,curtimezoneapp,
        format_timezone)))
     ENDIF
    FOOT REPORT
     stat = alterlist(initial_pool->qual,count2)
    WITH nocounter, outerjoin = d1
   ;end select
  ELSEIF (scope=6)
   SELECT INTO "NL:"
    cd.encntr_id, previouslyqualified = 0, cr.encntr_id
    FROM cr_report_request cr,
     (dummyt d1  WITH seq = 1),
     chart_temp cd
    PLAN (cd
     WHERE cd.distribution_id=distr_id)
     JOIN (d1)
     JOIN (cr
     WHERE parser(trim(chart_req_qual))
      AND parser(trim(code_mean))
      AND cd.encntr_id=cr.encntr_id
      AND ((cr.scope_flag+ 0)=6)
      AND cr.request_type_flag=4)
    ORDER BY cd.encntr_id, cnvtdatetime(cr.end_dt_tm) DESC
    HEAD REPORT
     count2 = 1, stat = alterlist(initial_pool->qual,10)
    HEAD cd.encntr_id
     IF (mod(count2,10)=1
      AND count2 != 1)
      stat = alterlist(initial_pool->qual,(count2+ 10))
     ENDIF
     IF (previouslyqualified=1
      AND trim(run_type_mean) != "FINAL")
      initial_pool->qual[count2].temp_encntr = cd.encntr_id, initial_pool->qual[count2].person_id =
      cd.person_id, initial_pool->qual[count2].temp_dontuse = 0,
      initial_pool->qual[count2].lookback_dt_tm = cr.end_dt_tm, initial_pool->qual[count2].
      begin_dt_tm = cnvtdatetime("01-jan-1800"), initial_pool->qual[count2].non_ce_begin_dt_tm =
      cnvtdatetime("01-jan-1800"),
      count2 += 1
     ENDIF
    DETAIL
     IF (mod(count2,10)=1
      AND count2 != 1)
      stat = alterlist(initial_pool->qual,(count2+ 10))
     ENDIF
     IF (admit_date_option_flag=1)
      neverqualifiedlookback_dt_tm = cd.create_dt_tm
     ENDIF
     IF (previouslyqualified=0
      AND trim(run_type_mean) != "CUM ADDENDUM")
      initial_pool->qual[count2].temp_encntr = cd.encntr_id, initial_pool->qual[count2].person_id =
      cd.person_id, initial_pool->qual[count2].temp_dontuse = 0,
      initial_pool->qual[count2].lookback_dt_tm = neverqualifiedlookback_dt_tm, initial_pool->qual[
      count2].begin_dt_tm = cnvtdatetime("01-jan-1800"), initial_pool->qual[count2].
      non_ce_begin_dt_tm = cnvtdatetime("01-jan-1800"),
      count2 += 1
     ENDIF
    FOOT  cd.encntr_id
     IF (test_ind > 10
      AND (initial_pool->qual[(count2 - 1)].temp_encntr=cd.encntr_id))
      IF (count2=2)
       CALL echo("Document Qualification"),
       CALL echo(concat("run_type_mean = ",run_type_mean)),
       CALL echo(concat("code_mean = ",code_mean)),
       CALL echo(concat("chart_req_qual = ",chart_req_qual))
      ENDIF
      CALL echo(concat("ENCOUNTER ID: ",cnvtstring(initial_pool->qual[(count2 - 1)].temp_encntr))),
      CALL echo(concat("PreviouslyQualified ",cnvtstring(previouslyqualified))), temp_date =
      initial_pool->qual[(count2 - 1)].lookback_dt_tm,
      CALL echo(concat("CE LookBack: ",datetimezoneformat(temp_date,curtimezoneapp,format_timezone))),
      temp_date = initial_pool->qual[(count2 - 1)].begin_dt_tm,
      CALL echo(concat("CE Print Start Date/Time: ",datetimezoneformat(temp_date,curtimezoneapp,
        format_timezone))),
      temp_date = initial_pool->qual[(count2 - 1)].non_ce_begin_dt_tm,
      CALL echo(concat("Non-CE Print Start Date/Time: ",datetimezoneformat(temp_date,curtimezoneapp,
        format_timezone)))
     ENDIF
    FOOT REPORT
     count2 -= 1, stat = alterlist(initial_pool->qual,count2)
    WITH nocounter, outerjoin = d1
   ;end select
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "ERROR! - Invalid Distribution scope, Exiting Job."
   SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
   CALL update_log(trim(message_log))
   GO TO exit_script
  ENDIF
  SET count_1 = 0
  SET count_1 = size(initial_pool->qual,5)
  SET message_log = concat("Finished qualify against cr_report_request table -- Encounter Count = ",
   cnvtstring(count_1))
  CALL update_log(trim(message_log))
 ELSE
  SET message_log = "INFO! - No encounters met demographic criteria, Exiting Job."
  CALL update_log(trim(message_log))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (size(initial_pool->qual,5)=0)
  SET message_log = "INFO! - No encounters met cr_report_request select, Exiting Job."
  CALL update_log(trim(message_log))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (absolute_lookback_ind=lookback_option_days)
  SET absolute_lookback_dt_tm = cnvtdatetime(datetimeadd(cnvtdatetime(dist_date),(
    absolute_lookback_days * - (1))))
 ENDIF
 SET message_log = concat(
  "Absolute qualification start date (will not go further back than this date): ",datetimezoneformat(
   absolute_lookback_dt_tm,curtimezoneapp,format_timezone))
 CALL update_log(trim(message_log))
 FOR (i = 1 TO size(initial_pool->qual,5))
   IF ((initial_pool->qual[i].lookback_dt_tm < absolute_lookback_dt_tm))
    IF (test_ind > 10)
     CALL echo(concat("Absolute qualification enforced for encounter ",trim(cnvtstring(initial_pool->
         qual[i].temp_encntr))))
     CALL echo(concat("CE Look back start dt/tm changed from: ",datetimezoneformat(initial_pool->
        qual[i].lookback_dt_tm,curtimezoneapp,format_timezone)," to: ",datetimezoneformat(
        absolute_lookback_dt_tm,curtimezoneapp,format_timezone)))
    ENDIF
    SET initial_pool->qual[i].lookback_dt_tm = absolute_lookback_dt_tm
    SET absolutelookback_cnt += 1
   ENDIF
 ENDFOR
 SET message_log = concat("Absolute look back qualification enforced for ",trim(cnvtstring(
    absolutelookback_cnt))," encounters.")
 CALL update_log(trim(message_log))
 IF (acthold_cnt > 0
  AND scope != 6)
  SELECT INTO "nl:"
   dr.seq, o.encntr_id, o.activity_type_cd,
   o.order_status_cd
   FROM (dummyt dr  WITH seq = value(count2)),
    orders o
   PLAN (dr)
    JOIN (o
    WHERE (o.encntr_id=initial_pool->qual[dr.seq].temp_encntr))
   ORDER BY dr.seq
   HEAD REPORT
    count_nouse = 0
   DETAIL
    IF (o.status_dt_tm > cnvtdatetime(dist_date))
     IF ( NOT (o.order_status_cd IN (deleted_cd, discontinued_cd, canceled_cd, unscheduled_cd,
     voided_with_result_cd,
     transfer_canceled_cd)))
      stat = alterlist(initial_pool->qual,(count2+ 1)), initial_pool->qual[dr.seq].temp_dontuse = 1,
      count_nouse += 1
     ENDIF
    ELSE
     IF (parser(acthold->acthold_cd)
      AND parser(ordstat->ordstat_cd)
      AND parser(ordstat2))
      stat = alterlist(initial_pool->qual,(count2+ 1)), initial_pool->qual[dr.seq].temp_dontuse = 1,
      count_nouse += 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET hold_cnt = 0
  SET hold_cnt = minval(count2,count_nouse)
  SET message_log = concat("Activity/Order Status Hold used to hold ",cnvtstring(hold_cnt),
   " encounters.")
  CALL update_log(trim(message_log))
 ENDIF
 SET initial_pool_cnt = size(initial_pool->qual,5)
 UPDATE  FROM chart_temp ct,
   (dummyt d2  WITH seq = value(initial_pool_cnt))
  SET ct.lookback_dt_tm = cnvtdatetime((curdate - 1000),0), ct.begin_dt_tm = cnvtdatetime(
    initial_pool->qual[d2.seq].begin_dt_tm), ct.non_ce_begin_dt_tm = cnvtdatetime(initial_pool->qual[
    d2.seq].non_ce_begin_dt_tm),
   ct.dont_use_ind = initial_pool->qual[d2.seq].temp_dontuse
  PLAN (d2
   WHERE (initial_pool->qual[d2.seq].temp_encntr > 0))
   JOIN (ct
   WHERE ct.distribution_id=distr_id
    AND (ct.encntr_id=initial_pool->qual[d2.seq].temp_encntr))
  WITH nocounter
 ;end update
 IF (test_ind >= 99)
  SELECT
   *
   FROM chart_temp
   WHERE distribution_id=distr_id
   WITH format(date,";;q")
  ;end select
 ENDIF
 SET count_use = 0
 SET count_use = count2
 SET count_use = maxval(0,(count2 - count_nouse))
 SET message_log = concat("Encounters after Activity/Order Status Hold = ",cnvtstring(count_use))
 CALL update_log(trim(message_log))
 DECLARE template_id = f8 WITH constant(template_id)
 DECLARE template_publish_dt_tm = q8 WITH constant(dist_date)
 FREE RECORD activity_rec
 RECORD activity_rec(
   1 activity[*]
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 catalog_cd = f8
     2 event_cds[*]
       3 event_cd = f8
     2 content_type_mean = vc
 )
 FREE RECORD temp_activity_rec
 RECORD temp_activity_rec(
   1 activity[*]
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 catalog_cd = f8
     2 content_type_mean = vc
 )
 FREE RECORD temp_request
 RECORD temp_request(
   1 cr_report_templates[*]
     2 report_template_id = f8
     2 report_template_publish_dt_tm = dq8
   1 cr_report_sections[*]
     2 report_section_id = f8
   1 cr_report_static_regions[*]
     2 report_static_region_id = f8
 )
 DECLARE activitycnt = i4 WITH noconstant(0)
 SET stat = alterlist(temp_request->cr_report_templates,1)
 SET temp_request->cr_report_templates[1].report_template_id = template_id
 SET temp_request->cr_report_templates[1].report_template_publish_dt_tm = cnvtdatetime(
  template_publish_dt_tm)
 FREE RECORD temp_reply
 RECORD temp_reply(
   1 template_version
     2 item[*]
       3 version_id = f8
       3 xml_detail = vc
   1 section_version
     2 item[*]
       3 version_id = f8
       3 xml_detail = vc
   1 static_region_version
     2 item[*]
       3 version_id = f8
       3 xml_detail = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lnumofsects = i4 WITH noconstant(0)
 DECLARE procedure_node = c11 WITH constant("procedure")
 DECLARE section_node = c9 WITH constant("section")
 DECLARE code_attr = c6 WITH constant("code")
 DECLARE type_attr = c6 WITH constant("type")
 DECLARE uid_attr = vc WITH constant("uid")
 DECLARE content_type_attr = vc WITH constant("content-type")
 DECLARE lproccnt = i4 WITH noconstant(0)
 DECLARE contenttype = vc WITH noconstant("")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp_request->cr_report_templates,5)),
   cr_template_publish cpt,
   cr_template_snapshot cts,
   cr_report_section crs
  PLAN (d)
   JOIN (cpt
   WHERE (cpt.template_id=temp_request->cr_report_templates[d.seq].report_template_id)
    AND cpt.beg_effective_dt_tm <= cnvtdatetime(temp_request->cr_report_templates[d.seq].
    report_template_publish_dt_tm)
    AND cpt.end_effective_dt_tm > cnvtdatetime(temp_request->cr_report_templates[d.seq].
    report_template_publish_dt_tm))
   JOIN (cts
   WHERE cts.template_id=cpt.template_id
    AND cts.beg_effective_dt_tm <= cpt.publish_dt_tm
    AND cts.end_effective_dt_tm > cpt.publish_dt_tm
    AND cts.section_id > 0)
   JOIN (crs
   WHERE crs.section_id=cts.section_id
    AND crs.beg_effective_dt_tm <= cpt.publish_dt_tm
    AND crs.end_effective_dt_tm > cpt.publish_dt_tm
    AND crs.active_ind > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(temp_request->cr_report_sections[cnt],(cnt+ 9))
   ENDIF
   temp_request->cr_report_sections[cnt].report_section_id = crs.report_section_id
  FOOT REPORT
   stat = alterlist(temp_request->cr_report_sections,cnt)
  WITH nocounter
 ;end select
 SET temp_request->cr_report_templates[1].report_template_id = 0
 SET stat = alterlist(temp_request->cr_report_templates,0)
 EXECUTE cr_get_report_long_text  WITH replace(request,temp_request), replace(reply,temp_reply)
 SET lnumofsects = size(temp_reply->section_version.item,5)
 DECLARE uar_xml_closefile(filehandle=i4(ref)) = null
 DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
 DECLARE uar_xml_getchildcount(nodehandle=i4(ref)) = i4
 DECLARE uar_xml_getchildnode(nodehandle=i4(ref),nodeno=i4(ref),childnode=i4(ref)) = i4
 DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
 DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
 DECLARE uar_xml_getattrbypos(nodehandle=i4(ref),ndx=i4(ref),attributehandle=i4(ref)) = i4
 DECLARE uar_xml_getattrname(attributehandle=i4(ref)) = vc
 DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
 DECLARE uar_xml_getattrcount(nodehandle=i4(ref)) = i4
 DECLARE hfile = i4 WITH private
 DECLARE hroot = i4 WITH private
 DECLARE srpt = vc WITH notrim
 FOR (x = 1 TO lnumofsects)
   SET stat = 0
   SET stat = uar_xml_parsestring(nullterm(temp_reply->section_version.item[x].xml_detail),hfile)
   IF (stat=1)
    IF (uar_xml_getroot(hfile,hroot)=1)
     CALL importnode(hroot)
    ENDIF
   ELSE
    SET srpt = concat("File [",temp_reply->section_version.item[x].version_id,
     "] not found, Error Code = ",cnvtstring(stat))
   ENDIF
   CALL uar_xml_closefile(hfile)
 ENDFOR
 SET stat = alterlist(temp_activity_rec->activity,lproccnt)
 SUBROUTINE importnode(hparent)
   DECLARE hattr = i4 WITH private
   DECLARE hchild = i4 WITH private
   DECLARE nodecount = i4 WITH private
   DECLARE attrcount = i4 WITH private
   DECLARE sattname = vc WITH private
   DECLARE sattvalue = vc WITH private
   DECLARE snodename = vc WITH private
   DECLARE chnode = i4 WITH private
   IF (hparent=0)
    RETURN
   ENDIF
   SET nodecount = uar_xml_getchildcount(hparent)
   SET attrcount = uar_xml_getattrcount(hparent)
   SET snodename = trim(uar_xml_getnodename(hparent))
   IF (attrcount > 0
    AND snodename=section_node)
    SET contenttype = ""
    FOR (at = 0 TO (attrcount - 1))
     SET stat = uar_xml_getattrbypos(hparent,at,hattr)
     IF (stat=1)
      SET sattname = trim(uar_xml_getattrname(hattr))
      IF (sattname=content_type_attr)
       SET contenttype = trim(uar_xml_getattrvalue(hattr))
       SET at = attrcount
      ENDIF
     ENDIF
    ENDFOR
   ELSEIF (attrcount > 0
    AND snodename=procedure_node)
    SET lproccnt += 1
    IF (mod(lproccnt,10)=1)
     SET stat = alterlist(temp_activity_rec->activity[lproccnt],(lproccnt+ 9))
    ENDIF
    SET temp_activity_rec->activity[lproccnt].content_type_mean = contenttype
    FOR (at = 0 TO (attrcount - 1))
     SET stat = uar_xml_getattrbypos(hparent,at,hattr)
     IF (stat=1)
      SET sattname = trim(uar_xml_getattrname(hattr))
      SET sattvalue = trim(uar_xml_getattrvalue(hattr))
      CASE (sattname)
       OF type_attr:
        IF (sattvalue="event-set")
         SET temp_activity_rec->activity[lproccnt].procedure_type_flag = 0
        ELSEIF (sattvalue="orderable")
         SET temp_activity_rec->activity[lproccnt].procedure_type_flag = 1
        ELSEIF (sattvalue="ap-report-component")
         SET temp_activity_rec->activity[lproccnt].procedure_type_flag = 2
        ELSE
         SET temp_activity_rec->activity[lproccnt].procedure_type_flag = - (1)
        ENDIF
       OF uid_attr:
        SET temp_activity_rec->activity[lproccnt].event_set_name = replace_escaped_xml(sattvalue)
       OF code_attr:
        SET temp_activity_rec->activity[lproccnt].catalog_cd = cnvtreal(sattvalue)
      ENDCASE
     ENDIF
    ENDFOR
   ENDIF
   IF (nodecount > 0)
    FOR (chnode = 0 TO (nodecount - 1))
     SET stat = uar_xml_getchildnode(hparent,chnode,hchild)
     IF (stat=1)
      CALL importnode(hchild)
     ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (replace_escaped_xml(xmlstring=vc) =vc)
   DECLARE __tmpstring = vc WITH protect
   SET __tmpstring = nullterm(xmlstring)
   SET __tmpstring = replace(__tmpstring,"&apos;",char(39),0)
   SET __tmpstring = replace(__tmpstring,"&quot;",char(34),0)
   SET __tmpstring = replace(__tmpstring,"&gt;",">",0)
   SET __tmpstring = replace(__tmpstring,"&lt;","<",0)
   SET __tmpstring = replace(__tmpstring,"&amp;","&",0)
   RETURN(nullterm(__tmpstring))
 END ;Subroutine
 IF (size(temp_activity_rec->activity,5) > 0)
  SELECT DISTINCT INTO "nl:"
   content_type = temp_activity_rec->activity[d.seq].content_type_mean, esc.event_set_cd, ese
   .event_cd
   FROM (dummyt d  WITH seq = size(temp_activity_rec->activity,5)),
    v500_event_set_code esc,
    v500_event_set_explode ese
   PLAN (d
    WHERE (temp_activity_rec->activity[d.seq].procedure_type_flag=0))
    JOIN (esc
    WHERE (esc.event_set_name=temp_activity_rec->activity[d.seq].event_set_name))
    JOIN (ese
    WHERE ese.event_set_cd=esc.event_set_cd)
   ORDER BY content_type, ese.event_set_cd, ese.event_cd
   HEAD REPORT
    activitycnt = 0, codecnt = 0
   HEAD content_type
    do_nothing = 0
   HEAD ese.event_set_cd
    IF (ese.event_set_cd > 0)
     activitycnt += 1
     IF (mod(activitycnt,10)=1)
      stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
     ENDIF
     activity_rec->activity[activitycnt].procedure_type_flag = 0, activity_rec->activity[activitycnt]
     .event_set_name = esc.event_set_name, activity_rec->activity[activitycnt].content_type_mean =
     temp_activity_rec->activity[d.seq].content_type_mean
    ENDIF
   DETAIL
    codecnt += 1
    IF (mod(codecnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
    ENDIF
    activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
   FOOT  ese.event_set_cd
    IF (ese.event_set_cd > 0)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   content_type = temp_activity_rec->activity[d.seq].content_type_mean, cver.parent_cd, cver.event_cd
   FROM (dummyt d  WITH seq = size(temp_activity_rec->activity,5)),
    code_value_event_r cver
   PLAN (d
    WHERE (temp_activity_rec->activity[d.seq].procedure_type_flag=2)
     AND (temp_activity_rec->activity[d.seq].content_type_mean="AP"))
    JOIN (cver
    WHERE (cver.parent_cd=temp_activity_rec->activity[d.seq].catalog_cd)
     AND cver.parent_cd > 0)
   ORDER BY cver.parent_cd, cver.event_cd
   HEAD cver.parent_cd
    activitycnt += 1
    IF (mod(activitycnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
    ENDIF
    activity_rec->activity[activitycnt].procedure_type_flag = 0, activity_rec->activity[activitycnt].
    catalog_cd = cver.parent_cd, activity_rec->activity[activitycnt].content_type_mean =
    temp_activity_rec->activity[d.seq].content_type_mean
   DETAIL
    stat = alterlist(activity_rec->activity[activitycnt].event_cds,1), activity_rec->activity[
    activitycnt].event_cds[1].event_cd = cver.event_cd
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "nl:"
   content_type = temp_activity_rec->activity[d.seq].content_type_mean, cver.parent_cd, cver.event_cd
   FROM (dummyt d  WITH seq = size(temp_activity_rec->activity,5)),
    profile_task_r ptr,
    code_value_event_r cver
   PLAN (d
    WHERE (temp_activity_rec->activity[d.seq].procedure_type_flag=1))
    JOIN (ptr
    WHERE (ptr.catalog_cd=temp_activity_rec->activity[d.seq].catalog_cd)
     AND ptr.catalog_cd > 0)
    JOIN (cver
    WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
     AND cver.parent_cd > 0)
   ORDER BY content_type, cver.parent_cd, cver.event_cd
   HEAD REPORT
    codecnt = 0
   HEAD content_type
    do_nothing = 0
   HEAD cver.parent_cd
    IF (cver.parent_cd > 0)
     activitycnt += 1
     IF (mod(activitycnt,10)=1)
      stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
     ENDIF
     activity_rec->activity[activitycnt].procedure_type_flag = 1, activity_rec->activity[activitycnt]
     .catalog_cd = ptr.catalog_cd, activity_rec->activity[activitycnt].content_type_mean =
     temp_activity_rec->activity[d.seq].content_type_mean
    ENDIF
   DETAIL
    codecnt += 1
    IF (mod(codecnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
    ENDIF
    activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
   FOOT  cver.parent_cd
    IF (cver.parent_cd > 0)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(activity_rec->activity,activitycnt)
 ENDIF
 FREE RECORD activity_temp
 RECORD activity_temp(
   1 qual[*]
     2 procedure_type_flag = i2
     2 catalog_cd = f8
     2 event_cd = f8
     2 content_type_mean = vc
 )
 DECLARE total_activity_cnt = i4 WITH noconstant(0)
 DECLARE activity_cnt = i4 WITH noconstant(0)
 DECLARE has_micro_section = i2 WITH noconstant(0)
 DECLARE has_rad_section = i2 WITH noconstant(0)
 DECLARE has_cardio_section = i2 WITH noconstant(0)
 FOR (i = 1 TO size(activity_rec->activity,5))
   SET total_activity_cnt += size(activity_rec->activity[i].event_cds,5)
   SET stat = alterlist(activity_temp->qual,total_activity_cnt)
   FOR (j = 1 TO size(activity_rec->activity[i].event_cds,5))
     IF ((activity_rec->activity[i].content_type_mean != content_type_immun))
      SET activity_cnt += 1
      SET activity_temp->qual[activity_cnt].content_type_mean = activity_rec->activity[i].
      content_type_mean
      IF ((activity_temp->qual[activity_cnt].content_type_mean=content_type_micro))
       SET has_micro_section = 1
      ENDIF
      IF ((activity_temp->qual[activity_cnt].content_type_mean=content_type_rad))
       SET has_rad_section = 1
      ENDIF
      IF ((activity_temp->qual[activity_cnt].content_type_mean=content_type_cardio))
       SET has_cardio_section = 1
      ENDIF
      SET activity_temp->qual[activity_cnt].procedure_type_flag = activity_rec->activity[i].
      procedure_type_flag
      SET activity_temp->qual[activity_cnt].catalog_cd = activity_rec->activity[i].catalog_cd
      SET activity_temp->qual[activity_cnt].event_cd = activity_rec->activity[i].event_cds[j].
      event_cd
     ENDIF
   ENDFOR
 ENDFOR
 INSERT  FROM chart_activity_temp cat,
   (dummyt d2  WITH seq = value(activity_cnt))
  SET cat.seq = 1, cat.distribution_id = distr_id, cat.catalog_cd = activity_temp->qual[d2.seq].
   catalog_cd,
   cat.event_cd = activity_temp->qual[d2.seq].event_cd, cat.procedure_type_flag = activity_temp->
   qual[d2.seq].procedure_type_flag, cat.content_type_mean = activity_temp->qual[d2.seq].
   content_type_mean,
   cat.updt_cnt = 0, cat.updt_dt_tm = cnvtdatetime(sysdate), cat.updt_id = reqinfo->updt_id,
   cat.updt_applctx = reqinfo->updt_applctx, cat.updt_task = reqinfo->updt_task
  PLAN (d2)
   JOIN (cat)
  WITH nocounter
 ;end insert
 FREE RECORD activity_temp
 SET message_log = concat("Total event codes in the report template = ",cnvtstring(activity_cnt))
 CALL update_log(trim(message_log))
 IF (test_ind >= 99)
  SELECT
   *
   FROM chart_activity_temp
   WHERE distribution_id=distr_id
   WITH nocounter, format(date,";;q")
  ;end select
 ENDIF
 SET count3 = 0
 SET counter1 = 0
 SET multi_flag = 0
 SET linked_flag = 0
 SET use_flag = 0
 SET extra_cnt = 0
 SET idxvar = 0
 SET holder = 0
 SET idx1 = 0
 FREE SET chart_rec
 RECORD chart_rec(
   1 qual[*]
     2 encntr_id = f8
     2 person_id = f8
     2 chart_date = dq8
     2 chart_order = f8
     2 chart_acc = c20
     2 accession_list[*]
       3 accession_nbr = c20
     2 event_id = f8
     2 linked_event_id = f8
     2 dont_use = i2
     2 count = i2
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 patient_loc_date = dq8
     2 orders[*]
       3 order_id = f8
     2 non_ce_begin_dt_tm = dq8
     2 dms_service_ident = vc
 )
 DECLARE ce_doc = vc
 DECLARE ce_rad_doc = vc
 DECLARE ce_accession = vc
 DECLARE ce_encntr = vc
 DECLARE ce_pending = vc
 DECLARE ce_rad_pending = vc
 DECLARE ce_event_class = vc
 DECLARE ce_rad_clause = vc
 DECLARE ce_rad_clause2 = vc
 DECLARE ce_doc_clause = vc
 DECLARE ce_accession_clause = vc
 DECLARE ce_encntr_clause = vc
 DECLARE format_check_clause = vc
 DECLARE format_check_encntr = vc
 DECLARE format_clause = vc
 DECLARE final_ce_clause = vc
 DECLARE ce_micro_pending = vc
 DECLARE ce_micro_clause = vc
 DECLARE ce_micro_accession = vc
 DECLARE ce_cardio_clause = vc
 DECLARE ce_cardio_pending = vc
 SET ce_doc = concat("ce.encntr_id = ct.encntr_id AND"," ce.person_id = ct.person_id AND",
  " (ce.clinsig_updt_dt_tm > ct.lookback_dt_tm) and",
  " ce.valid_until_dt_tm >= cnvtdatetime('31-DEC-2100') AND ce.publish_flag > 0 AND",
  " ce.record_status_cd != del_stat_cd")
 SET ce_rad_doc = concat("ce2.encntr_id = ct.encntr_id AND",
  " (ce2.clinsig_updt_dt_tm > ct.lookback_dt_tm) AND",
  " ce2.valid_until_dt_tm >= cnvtdatetime('31-DEC-2100') AND ce2.publish_flag > 0 AND",
  " ce2.record_status_cd != del_stat_cd")
 SET ce_accession = concat(trim(ce_doc)," and trim(ce.accession_nbr) > ",'"'," ",'"')
 SET ce_encntr = concat(" ce.encntr_id = ct.encntr_id AND"," ce.person_id = ct.person_id AND ",
  " (ce.clinsig_updt_dt_tm > ct.lookback_dt_tm) AND",
  " ce.valid_until_dt_tm >= cnvtdatetime('31-DEC-2100') AND ce.publish_flag > 0 AND",
  " ce.record_status_cd != del_stat_cd")
 IF (scope=6)
  SET ce_event_class = " AND ce.event_class_cd = doc_class_cd "
 ELSE
  SET ce_event_class = " AND ce.event_class_cd != placeholder_class_cd "
 ENDIF
 SET ce_pending = buildresultclause(null)
 SET ce_rad_pending = buildresultclauseforradiology(null)
 SET ce_micro_pending = buildmicroresultclause(null)
 SET ce_cardio_pending = " and ce.result_status_cd in(auth_cd, mod_cd, altered_cd)"
 IF (scope=4)
  SET ce_cardio_clause = concat(trim(ce_accession)," ",trim(ce_cardio_pending),
   " and ce.event_class_cd = proc_class_cd ",
   " and ce.view_level =1 and ce.publish_flag = 1 AND ct.dont_use_ind = 0")
  SET ce_micro_clause = concat(trim(ce_accession)," ",trim(ce_micro_pending),
   " AND ct.dont_use_ind = 0")
  SET ce_rad_clause = concat(trim(ce_accession)," ",trim(ce_pending)," ",
   " and ce.event_class_cd = radclass_cd AND ct.dont_use_ind = 0")
 ELSE
  SET ce_cardio_clause = concat(trim(ce_doc)," ",trim(ce_cardio_pending),
   " and ce.event_class_cd = proc_class_cd ",
   " and ce.view_level=1 and ce.publish_flag=1 AND ct.dont_use_ind = 0")
  SET ce_micro_clause = concat(trim(ce_doc)," ",trim(ce_micro_pending)," AND ct.dont_use_ind = 0")
  SET ce_rad_clause = concat(trim(ce_doc)," ",trim(ce_pending)," ",
   " and ce.event_class_cd = radclass_cd AND ct.dont_use_ind = 0")
 ENDIF
 SET ce_doc_clause = concat(trim(ce_doc)," ",trim(ce_event_class),trim(ce_pending),
  " AND ct.dont_use_ind = 0")
 SET ce_accession_clause = concat(trim(ce_accession)," ",trim(ce_event_class),trim(ce_pending),
  " AND ct.dont_use_ind = 0")
 SET ce_rad_clause2 = concat(trim(ce_rad_doc)," ",trim(ce_rad_pending)," AND ct.dont_use_ind = 0")
 SET ce_encntr_clause = concat(trim(ce_encntr)," ",trim(ce_pending)," ",trim(ce_event_class))
 SET format_clause = concat("cat.distribution_id = ct.distribution_id AND ",
  " cat.event_cd = ce.event_cd AND cat.procedure_type_flag = 0 and cat.event_cd > 0.0 ")
 SET format_check_clause = concat(" and",
  " ((cat.content_type_mean = CONTENT_TYPE_BB_XM and ce.view_level>=0 and ce.publish_flag=1) OR",
  " (cat.content_type_mean = CONTENT_TYPE_AP and pending_flag=0 and ce.view_level=1 and ce.publish_flag=1) OR",
  " (cat.content_type_mean = CONTENT_TYPE_AP and pending_flag>0 and ce.view_level=1 and ce.publish_flag>0) OR",
  " (cat.content_type_mean in (CONTENT_TYPE_HLA_TYPING, CONTENT_TYPE_HAPLOTYPE) and ce.view_level=1 and ce.publish_flag=1) OR",
  " (cat.content_type_mean = CONTENT_TYPE_DOC and ce.event_class_cd in (doc_class_cd, mdoc_class_cd) ",
  " and ce.view_level>=0 and ce.publish_flag=1) OR",
  " (cat.content_type_mean not in (CONTENT_TYPE_BB_XM,CONTENT_TYPE_AP,CONTENT_TYPE_APHIST,CONTENT_TYPE_DOC,",
  " CONTENT_TYPE_HLA_TYPING,CONTENT_TYPE_HAPLOTYPE,CONTENT_TYPE_MICRO,CONTENT_TYPE_RAD,CONTENT_TYPE_CARDIO,CONTENT_TYPE_IMMUN)",
  " and ce.view_level>0 and ce.publish_flag=1)")
 SET format_check_encntr = concat(format_check_clause,")")
 SET final_ce_clause = concat(trim(format_clause)," ",trim(format_check_encntr),
  " AND ct.dont_use_ind = 0")
 CALL echo(final_ce_clause)
 IF (scope=6)
  CALL echo(build("doc-level: join ce where ",ce_doc_clause))
  IF (test_ind > 10)
   CALL echo(build("doc-level contrib system: ",cs_where_clause))
  ENDIF
  SELECT DISTINCT INTO "NL:"
   FROM chart_temp ct,
    clinical_event ce,
    clinical_event ce2
   PLAN (ct
    WHERE ct.distribution_id=distr_id)
    JOIN (ce
    WHERE parser(ce_doc_clause)
     AND ce.event_cd IN (
    (SELECT
     cat.event_cd
     FROM chart_activity_temp cat
     WHERE cat.distribution_id=distr_id
      AND cat.procedure_type_flag=0
      AND cat.event_cd > 0.0
      AND cat.content_type_mean=content_type_doc))
     AND parser(cs_where_clause))
    JOIN (ce2
    WHERE ce2.event_id=ce.parent_event_id
     AND ce2.event_class_cd IN (mdoc_class_cd, doc_class_cd, grp_class_cd, proc_class_cd)
     AND ce2.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100"))
   ORDER BY ce2.event_id, ce.clinsig_updt_dt_tm DESC
   HEAD REPORT
    count3 = 0
   HEAD ce2.event_id
    IF (ce2.event_class_cd IN (mdoc_class_cd, doc_class_cd)
     AND ce2.view_level=1)
     count3 += 1
     IF (count3 > size(chart_rec->qual,5))
      stat = alterlist(chart_rec->qual,(count3+ 9))
     ENDIF
     chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
     .person_id, chart_rec->qual[count3].chart_date = cnvtdatetime(ct.begin_dt_tm),
     chart_rec->qual[count3].chart_acc = " ", chart_rec->qual[count3].chart_order = 0, chart_rec->
     qual[count3].event_id = ce2.event_id,
     chart_rec->qual[count3].linked_event_id = 0, chart_rec->qual[count3].dont_use = 0, stat =
     alterlist(chart_rec->qual[count3].orders,0),
     idx = 0, encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->
      encntr_list[idx].encntr_id)
     IF (encntrindex > 0)
      IF (ce2.clinsig_updt_dt_tm >= ce.clinsig_updt_dt_tm
       AND (ce2.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
      latest_clinsig_updt_dt_tm))
       distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce2
       .clinsig_updt_dt_tm
      ELSEIF ((ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
      latest_clinsig_updt_dt_tm))
       distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
      ENDIF
     ENDIF
     chart_rec->qual[count3].non_ce_begin_dt_tm = cnvtdatetime(ct.non_ce_begin_dt_tm)
    ENDIF
   DETAIL
    IF (ce2.event_class_cd IN (grp_class_cd, proc_class_cd)
     AND ce.view_level=1)
     count3 += 1
     IF (count3 > size(chart_rec->qual,5))
      stat = alterlist(chart_rec->qual,(count3+ 9))
     ENDIF
     chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
     .person_id, chart_rec->qual[count3].chart_date = cnvtdatetime(ct.begin_dt_tm),
     chart_rec->qual[count3].chart_acc = " ", chart_rec->qual[count3].chart_order = 0, chart_rec->
     qual[count3].event_id = ce.event_id,
     chart_rec->qual[count3].linked_event_id = 0, chart_rec->qual[count3].dont_use = 0, stat =
     alterlist(chart_rec->qual[count3].orders,0),
     idx = 0, encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->
      encntr_list[idx].encntr_id)
     IF (encntrindex > 0)
      IF ((ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
      latest_clinsig_updt_dt_tm))
       distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
      ENDIF
     ENDIF
     chart_rec->qual[count3].non_ce_begin_dt_tm = cnvtdatetime(ct.non_ce_begin_dt_tm)
    ENDIF
   FOOT REPORT
    stat = alterlist(chart_rec->qual,count3)
   WITH counter, orahintcbo("LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT)")
  ;end select
 ELSEIF (scope=4)
  IF (has_micro_section)
   CALL validatemicrobiologyevents(0)
   SET message_log = concat("Number of request after select for micro on clinical_event table = ",
    cnvtstring(count3))
   CALL update_log(trim(message_log))
  ENDIF
  DECLARE format_check_clause_2 = vc
  SET format_check_clause_2 = concat("cat.content_type_mean not in ",
   "(CONTENT_TYPE_APHIST,CONTENT_TYPE_HLA_TYPING,CONTENT_TYPE_HAPLOTYPE,",
   "CONTENT_TYPE_MICRO, CONTENT_TYPE_RAD, CONTENT_TYPE_CARDIO, CONTENT_TYPE_IMMUN)",
   " AND ((cat.content_type_mean = CONTENT_TYPE_BB_XM and ce.view_level>=0 and ce.publish_flag=1) OR",
   " (cat.content_type_mean = CONTENT_TYPE_AP and pending_flag = 0 and ce.view_level=1 and ce.publish_flag=1) OR",
   " (cat.content_type_mean = CONTENT_TYPE_AP and pending_flag > 0 and ce.view_level=1 and ce.publish_flag>0) OR",
   " (cat.content_type_mean not in (CONTENT_TYPE_BB_XM, CONTENT_TYPE_AP) and ce.view_level>0 and ce.publish_flag=1))"
   )
  CALL echo(format_check_clause_2)
  IF (test_ind > 10)
   CALL echo(build("accession scope contrib system: ",cs_where_clause))
  ENDIF
  SELECT DISTINCT INTO "NL:"
   FROM chart_temp ct,
    clinical_event ce,
    chart_activity_temp cat
   PLAN (ct
    WHERE ct.distribution_id=distr_id)
    JOIN (ce
    WHERE parser(ce_accession_clause)
     AND parser(cs_where_clause))
    JOIN (cat
    WHERE cat.distribution_id=ct.distribution_id
     AND cat.event_cd=ce.event_cd
     AND cat.event_cd > 0.0
     AND cat.procedure_type_flag=0
     AND parser(format_check_clause_2))
   ORDER BY ce.accession_nbr, ce.event_id, ce.order_id,
    0
   HEAD REPORT
    do_nothing = 0
   HEAD ce.accession_nbr
    count3 += 1
    IF (count3 > size(chart_rec->qual,5))
     stat = alterlist(chart_rec->qual,(count3+ 9))
    ENDIF
    chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
    .person_id, chart_rec->qual[count3].chart_date = cnvtdatetime(ct.begin_dt_tm),
    chart_rec->qual[count3].non_ce_begin_dt_tm = cnvtdatetime(ct.non_ce_begin_dt_tm), chart_rec->
    qual[count3].chart_acc = ce.accession_nbr, chart_rec->qual[count3].event_id = ce.event_id,
    chart_rec->qual[count3].linked_event_id = 0, chart_rec->qual[count3].dont_use = 0
   HEAD ce.order_id
    IF (ce.order_id > 0)
     idx = 0, accnindex = locateval(idx,1,size(chart_rec->qual,5),ce.accession_nbr,chart_rec->qual[
      idx].chart_acc), idx = 0
     IF (locateval(idx,1,size(chart_rec->qual[accnindex].orders,5),ce.order_id,chart_rec->qual[
      accnindex].orders[idx].order_id)=0
      AND accnindex > 0)
      order_cnt = (size(chart_rec->qual[accnindex].orders,5)+ 1), chart_rec->qual[accnindex].
      chart_order = ce.order_id, stat = alterlist(chart_rec->qual[accnindex].orders,order_cnt),
      chart_rec->qual[accnindex].orders[order_cnt].order_id = ce.order_id
     ENDIF
    ENDIF
   DETAIL
    idx = 0, encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->
     encntr_list[idx].encntr_id)
    IF (encntrindex > 0)
     IF ((ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
     latest_clinsig_updt_dt_tm))
      distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(chart_rec->qual,count3)
   WITH counter, orahintcbo("LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT)")
  ;end select
  SET message_log = concat("Number of request after select on clinical_event table = ",cnvtstring(
    count3))
  CALL update_log(trim(message_log))
  IF (has_rad_section)
   CALL validateradiologyevents(0)
   SET message_log = concat(
    "Number of request after select for radiology events on clinical_event table = ",cnvtstring(
     count3))
   CALL update_log(trim(message_log))
  ENDIF
  IF (has_cardio_section)
   CALL validatecardiologyevents(0)
   SET message_log = concat(
    "Number of request after select for cardio events on clinical_event table = ",cnvtstring(count3))
   CALL update_log(trim(message_log))
  ENDIF
 ELSE
  IF (has_micro_section)
   CALL validatemicrobiologyevents(0)
  ENDIF
  IF (test_ind > 10)
   CALL echo(build("Person-Encounter-CrossEncounter scope contrib system: ",cs_where_clause))
  ENDIF
  SELECT INTO "NL:"
   FROM chart_temp ct,
    clinical_event ce,
    chart_activity_temp cat
   PLAN (ct
    WHERE ct.distribution_id=distr_id)
    JOIN (ce
    WHERE parser(trim(ce_encntr_clause))
     AND parser(cs_where_clause))
    JOIN (cat
    WHERE parser(final_ce_clause))
   ORDER BY ce.encntr_id, ce.clinsig_updt_dt_tm DESC
   HEAD REPORT
    do_nothing = 0
   HEAD ce.encntr_id
    count3 += 1
    IF (count3 > size(chart_rec->qual,5))
     stat = alterlist(chart_rec->qual,(count3+ 9))
    ENDIF
    chart_rec->qual[count3].encntr_id = ct.encntr_id, chart_rec->qual[count3].person_id = ct
    .person_id, chart_rec->qual[count3].chart_date = cnvtdatetime(ct.begin_dt_tm),
    chart_rec->qual[count3].non_ce_begin_dt_tm = cnvtdatetime(ct.non_ce_begin_dt_tm), chart_rec->
    qual[count3].chart_acc = " ", chart_rec->qual[count3].chart_order = 0,
    chart_rec->qual[count3].event_id = 0.0, chart_rec->qual[count3].linked_event_id = 0, chart_rec->
    qual[count3].dont_use = 0
   DETAIL
    idx = 0, encntrindex = 0, encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,
     distinct_cp_encntr->encntr_list[idx].encntr_id)
    IF (encntrindex > 0)
     IF ((ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
     latest_clinsig_updt_dt_tm))
      distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
     ENDIF
    ENDIF
   FOOT REPORT
    stat = alterlist(chart_rec->qual,count3)
   WITH counter, orahintcbo("LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT)")
  ;end select
  IF (has_rad_section)
   CALL validateradiologyevents(0)
  ENDIF
  IF (has_cardio_section)
   CALL validatecardiologyevents(0)
  ENDIF
 ENDIF
 SUBROUTINE (validateradiologyevents(checkxencntr=i2) =null)
   CALL echo(build("radiology join ce: ",ce_rad_clause))
   IF (test_ind > 10)
    CALL echo(build("validate RAD contrib system: ",cs_where_clause2))
   ENDIF
   SELECT DISTINCT INTO "NL:"
    FROM chart_temp ct,
     clinical_event ce,
     ce_linked_result clr,
     clinical_event ce2
    PLAN (ct
     WHERE ct.distribution_id=distr_id)
     JOIN (ce
     WHERE parser(ce_rad_clause)
      AND ce.event_cd IN (
     (SELECT
      cat.event_cd
      FROM chart_activity_temp cat
      WHERE cat.distribution_id=distr_id
       AND cat.event_cd > 0.0
       AND cat.procedure_type_flag=0
       AND cat.content_type_mean=content_type_rad)))
     JOIN (clr
     WHERE clr.event_id=ce.event_id
      AND clr.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100"))
     JOIN (ce2
     WHERE ce2.parent_event_id=clr.linked_event_id
      AND parser(ce_rad_clause2)
      AND parser(cs_where_clause2))
    ORDER BY clr.linked_event_id, ce.order_id, ce2.event_id,
     0
    HEAD REPORT
     do_nothing = 0
    HEAD clr.linked_event_id
     IF (scope=4)
      idx = 0, linkedeventindex = locateval(idx,1,size(chart_rec->qual,5),clr.linked_event_id,
       chart_rec->qual[idx].linked_event_id), idx = 0,
      accnindex = locateval(idx,1,size(chart_rec->qual,5),ce.accession_nbr,chart_rec->qual[idx].
       chart_acc)
     ENDIF
     idx = 0
     IF (checkxencntr=0
      AND ((scope IN (1, 2, 5)
      AND locateval(idx,1,size(chart_rec->qual,5),ce.encntr_id,chart_rec->qual[idx].encntr_id)=0) OR
     (scope=4
      AND linkedeventindex=0
      AND accnindex=0)) )
      count3 += 1
      IF (count3 > size(chart_rec->qual,5))
       stat = alterlist(chart_rec->qual,(count3+ 9))
      ENDIF
      chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
      .person_id, chart_rec->qual[count3].chart_date = ct.begin_dt_tm,
      chart_rec->qual[count3].chart_acc = ce.accession_nbr, chart_rec->qual[count3].event_id = ce
      .event_id, chart_rec->qual[count3].linked_event_id = clr.linked_event_id,
      chart_rec->qual[count3].dont_use = 0, chart_rec->qual[count3].non_ce_begin_dt_tm = ct
      .non_ce_begin_dt_tm
     ENDIF
     IF (scope=4
      AND accnindex > 0
      AND (chart_rec->qual[accnindex].event_id=ce.event_id)
      AND (chart_rec->qual[accnindex].linked_event_id=0))
      chart_rec->qual[accnindex].linked_event_id = clr.linked_event_id
     ENDIF
    HEAD ce.order_id
     IF (ce.order_id > 0
      AND scope=4)
      idx = 0, linkedeventindex = locateval(idx,1,size(chart_rec->qual,5),clr.linked_event_id,
       chart_rec->qual[idx].linked_event_id), idx = 0,
      accnindex = locateval(idx,1,size(chart_rec->qual,5),ce.accession_nbr,chart_rec->qual[idx].
       chart_acc), crindex = 0
      IF (linkedeventindex > 0)
       crindex = linkedeventindex
      ELSEIF (linkedeventindex=0
       AND accnindex > 0)
       crindex = accnindex
      ELSEIF (linkedeventindex=accnindex
       AND accnindex > 0)
       crindex = accnindex
      ELSE
       count3 += 1
       IF (count3 > size(chart_rec->qual,5))
        stat = alterlist(chart_rec->qual,(count3+ 9))
       ENDIF
       chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
       .person_id, chart_rec->qual[count3].chart_date = ct.begin_dt_tm,
       chart_rec->qual[count3].chart_acc = ce.accession_nbr, chart_rec->qual[count3].event_id = ce
       .event_id, chart_rec->qual[count3].linked_event_id = clr.linked_event_id,
       chart_rec->qual[count3].dont_use = 0, chart_rec->qual[count3].non_ce_begin_dt_tm = ct
       .non_ce_begin_dt_tm, crindex = count3
      ENDIF
      idx = 0
      IF (crindex > 0
       AND locateval(idx,1,size(chart_rec->qual[crindex].orders,5),ce.order_id,chart_rec->qual[
       crindex].orders[idx].order_id)=0)
       chart_rec->qual[crindex].chart_order = ce.order_id, order_cnt = (size(chart_rec->qual[crindex]
        .orders,5)+ 1), stat = alterlist(chart_rec->qual[crindex].orders,order_cnt),
       chart_rec->qual[crindex].orders[order_cnt].order_id = ce.order_id
      ENDIF
     ENDIF
    DETAIL
     idx = 0
     IF (checkxencntr=0)
      encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->encntr_list[idx
       ].encntr_id)
      IF (encntrindex > 0
       AND (ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
      latest_clinsig_updt_dt_tm))
       distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
      ENDIF
     ELSE
      pidx = 0, personindex = locatevalsort(pidx,1,size(xencntr_list->person_list,5),ce.person_id,
       xencntr_list->person_list[pidx].person_id)
      IF ((ce.clinsig_updt_dt_tm > xencntr_list->person_list[personindex].latest_clinsig_updt_dt_tm))
       xencntr_list->person_list[personindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
      ENDIF
      pencntrnum = size(xencntr_list->person_list[personindex].encntr_list,5), eidx = 0, encntrindex
       = locateval(eidx,1,pencntrnum,ce.encntr_id,xencntr_list->person_list[personindex].encntr_list[
       eidx].encntr_id),
      xencntr_list->person_list[personindex].encntr_list[encntrindex].ce_use_flag = 1
     ENDIF
    FOOT REPORT
     IF (checkxencntr=0)
      stat = alterlist(chart_rec->qual,count3)
     ENDIF
    WITH nocounter, orahintcbo(
      "LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT) INDEX(CE2 XIE1CLINICAL_EVENT)")
   ;end select
 END ;Subroutine
 SUBROUTINE (validatecardiologyevents(checkxencntr=i2) =null)
   CALL echo(build("ce_cardio_clause:  ",ce_cardio_clause))
   IF (test_ind > 10)
    CALL echo(build("validate CARDIO contrib system: ",cs_where_clause))
   ENDIF
   SELECT INTO "NL:"
    FROM chart_temp ct,
     clinical_event ce,
     clinical_event ce2
    PLAN (ct
     WHERE ct.distribution_id=distr_id)
     JOIN (ce
     WHERE parser(ce_cardio_clause)
      AND ce.event_cd IN (
     (SELECT
      cat.event_cd
      FROM chart_activity_temp cat
      WHERE cat.distribution_id=distr_id
       AND cat.procedure_type_flag=0
       AND cat.event_cd > 0.0
       AND cat.content_type_mean=content_type_cardio)))
     JOIN (ce2
     WHERE ce2.parent_event_id=ce.event_id
      AND ce2.event_class_cd=doc_class_cd
      AND ce2.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
      AND ce2.publish_flag=1
      AND ce2.result_status_cd IN (auth_cd, mod_cd, super_cd, altered_cd)
      AND ce2.record_status_cd != del_stat_cd
      AND parser(cs_where_clause2))
    ORDER BY ce.accession_nbr, ce.event_id, ce.order_id,
     0
    HEAD REPORT
     do_nothing = 0
    HEAD ce.accession_nbr
     idx = 0, accnindex = locateval(idx,1,size(chart_rec->qual,5),ce.accession_nbr,chart_rec->qual[
      idx].chart_acc), idx = 0
     IF (checkxencntr=0
      AND ((scope IN (1, 2, 5)
      AND locateval(idx,1,size(chart_rec->qual,5),ce.encntr_id,chart_rec->qual[idx].encntr_id)=0) OR
     (scope=4
      AND accnindex=0)) )
      count3 += 1
      IF (count3 > size(chart_rec->qual,5))
       stat = alterlist(chart_rec->qual,(count3+ 9))
      ENDIF
      chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
      .person_id, chart_rec->qual[count3].chart_date = ct.begin_dt_tm,
      chart_rec->qual[count3].chart_acc = ce.accession_nbr, chart_rec->qual[count3].event_id = ce
      .event_id, chart_rec->qual[count3].linked_event_id = 0,
      chart_rec->qual[count3].dont_use = 0, chart_rec->qual[count3].non_ce_begin_dt_tm = ct
      .non_ce_begin_dt_tm
     ENDIF
    HEAD ce.order_id
     IF (ce.order_id > 0
      AND scope=4)
      idx = 0, accnindex = locateval(idx,1,size(chart_rec->qual,5),ce.accession_nbr,chart_rec->qual[
       idx].chart_acc), idx = 0
      IF (locateval(idx,1,size(chart_rec->qual[accnindex].orders,5),ce.order_id,chart_rec->qual[
       accnindex].orders[idx].order_id)=0
       AND accnindex > 0)
       order_cnt = (size(chart_rec->qual[accnindex].orders,5)+ 1), chart_rec->qual[accnindex].
       chart_order = ce.order_id, stat = alterlist(chart_rec->qual[accnindex].orders,order_cnt),
       chart_rec->qual[accnindex].orders[order_cnt].order_id = ce.order_id
      ENDIF
     ENDIF
    DETAIL
     idx = 0
     IF (checkxencntr=0)
      encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->encntr_list[idx
       ].encntr_id)
      IF (encntrindex > 0
       AND (ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
      latest_clinsig_updt_dt_tm))
       distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
      ENDIF
     ELSE
      pidx = 0, personindex = locatevalsort(pidx,1,size(xencntr_list->person_list,5),ce.person_id,
       xencntr_list->person_list[pidx].person_id)
      IF ((ce.clinsig_updt_dt_tm > xencntr_list->person_list[personindex].latest_clinsig_updt_dt_tm))
       xencntr_list->person_list[personindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
      ENDIF
      pencntrnum = size(xencntr_list->person_list[personindex].encntr_list,5), eidx = 0, encntrindex
       = locateval(eidx,1,pencntrnum,ce.encntr_id,xencntr_list->person_list[personindex].encntr_list[
       eidx].encntr_id),
      xencntr_list->person_list[personindex].encntr_list[encntrindex].ce_use_flag = 1
     ENDIF
    FOOT REPORT
     IF (checkxencntr=0)
      stat = alterlist(chart_rec->qual,count3)
     ENDIF
    WITH nocounter, orahintcbo(
      "LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT) INDEX(CE2 XIE1CLINICAL_EVENT)")
   ;end select
 END ;Subroutine
 SUBROUTINE (validatemicrobiologyevents(checkxencntr=i2) =null)
   SET count3 = 0
   DECLARE tempeventcnt = i2 WITH noconstant(0)
   DECLARE tempencntrcnt = i2 WITH noconstant(0)
   DECLARE locval = i2 WITH noconstant(0)
   CALL echo(build("checkXEncntr: ",checkxencntr))
   CALL echo(ce_micro_clause)
   SELECT INTO "NL:"
    FROM chart_temp ct,
     clinical_event ce
    PLAN (ct
     WHERE ct.distribution_id=distr_id)
     JOIN (ce
     WHERE parser(ce_micro_clause)
      AND ce.event_cd IN (
     (SELECT
      cat.event_cd
      FROM chart_activity_temp cat
      WHERE cat.distribution_id=distr_id
       AND cat.procedure_type_flag=0
       AND cat.event_cd > 0.0
       AND cat.content_type_mean=content_type_micro)))
    ORDER BY ce.encntr_id, 0
    HEAD REPORT
     do_nothing = 0
    DETAIL
     idx = 0
     IF (locateval(idx,1,tempeventcnt,ce.event_id,mbo_flat_rec->qual[idx].event_id)=0)
      tempeventcnt += 1
      IF (mod(tempeventcnt,5)=1)
       stat = alterlist(mbo_flat_rec->qual,(tempeventcnt+ 4))
      ENDIF
      mbo_flat_rec->qual[tempeventcnt].event_id = ce.event_id, mbo_flat_rec->qual[tempeventcnt].
      chart_date = ct.begin_dt_tm, mbo_flat_rec->qual[tempeventcnt].lookback_dt_tm = ct
      .lookback_dt_tm,
      mbo_flat_rec->qual[tempeventcnt].non_ce_begin_dt_tm = ct.non_ce_begin_dt_tm
     ENDIF
    FOOT REPORT
     stat = alterlist(mbo_flat_rec->qual,tempeventcnt)
    WITH nocounter, orahintcbo("LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT)")
   ;end select
   IF (test_ind > 10)
    CALL echorecord(mbo_flat_rec)
   ENDIF
   IF (test_ind > 10)
    CALL echo(build("Child rows and accession contrib system - MICRO: ",cs_where_clause))
   ENDIF
   IF (scope=4)
    FREE RECORD tmp_orders
    RECORD tmp_orders(
      1 qual[*]
        2 order_id = f8
    )
    IF (tempeventcnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = value(tempeventcnt)),
       clinical_event ce
      PLAN (d)
       JOIN (ce
       WHERE (ce.parent_event_id=mbo_flat_rec->qual[d.seq].event_id)
        AND ce.clinsig_updt_dt_tm > cnvtdatetime(mbo_flat_rec->qual[d.seq].lookback_dt_tm)
        AND ((ce.event_class_cd=micro_class_cd
        AND ce.publish_flag > 0) OR (ce.event_class_cd=doc_class_cd
        AND ce.publish_flag >= 0
        AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")))
        AND parser(cs_where_clause))
      ORDER BY ce.accession_nbr, ce.order_id
      HEAD ce.accession_nbr
       mic_invalid_doc_rows = 0, mic_valid_doc_rows = 0, mic_valid_mbo_rows = 0,
       count3 += 1
       IF (mod(count3,bind_cnt)=1)
        stat = alterlist(chart_rec->qual,(count3+ (bind_cnt - 1)))
       ENDIF
       tmp_orders_cnt = 0, stat = initrec(tmp_orders)
      DETAIL
       IF (ce.publish_flag=0
        AND ce.event_class_cd=doc_class_cd)
        mic_invalid_doc_rows += 1
       ELSEIF (ce.publish_flag > 0
        AND ce.event_class_cd=doc_class_cd)
        mic_valid_doc_rows += 1
       ELSE
        mic_valid_mbo_rows += 1
       ENDIF
       idx = 0
       IF (locateval(idx,1,size(tmp_orders->qual,5),ce.order_id,tmp_orders->qual[idx].order_id)=0)
        tmp_orders_cnt += 1, stat = alterlist(tmp_orders->qual,tmp_orders_cnt), tmp_orders->qual[
        tmp_orders_cnt].order_id = ce.order_id
       ENDIF
       idx = 0, encntrindex = locateval(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->
        encntr_list[idx].encntr_id)
       IF (encntrindex > 0)
        IF ((ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
        latest_clinsig_updt_dt_tm))
         distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce
         .clinsig_updt_dt_tm
        ENDIF
       ENDIF
      FOOT  ce.accession_nbr
       IF (((mic_valid_mbo_rows > mic_invalid_doc_rows) OR (mic_valid_doc_rows > 0)) )
        chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
        .person_id, chart_rec->qual[count3].chart_date = cnvtdatetime(mbo_flat_rec->qual[d.seq].
         chart_date),
        chart_rec->qual[count3].chart_acc = ce.accession_nbr, chart_rec->qual[count3].event_id = ce
        .event_id, chart_rec->qual[count3].dont_use = 0,
        chart_rec->qual[count3].non_ce_begin_dt_tm = cnvtdatetime(mbo_flat_rec->qual[d.seq].
         non_ce_begin_dt_tm)
        FOR (orderindex = 1 TO size(tmp_orders->qual,5))
          order_cnt = (size(chart_rec->qual[count3].orders,5)+ 1), stat = alterlist(chart_rec->qual[
           count3].orders,order_cnt), chart_rec->qual[count3].chart_order = ce.order_id,
          chart_rec->qual[count3].orders[order_cnt].order_id = tmp_orders->qual[orderindex].order_id
          IF (test_ind > 10)
           CALL echo(build("order_id added to orders struct = ",tmp_orders->qual[orderindex].order_id
            ))
          ENDIF
        ENDFOR
       ENDIF
      FOOT REPORT
       stat = alterlist(chart_rec->qual,count3)
      WITH counter
     ;end select
    ENDIF
   ELSE
    IF (tempeventcnt > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = value(tempeventcnt)),
       clinical_event ce
      PLAN (d)
       JOIN (ce
       WHERE (ce.parent_event_id=mbo_flat_rec->qual[d.seq].event_id)
        AND ce.clinsig_updt_dt_tm > cnvtdatetime(mbo_flat_rec->qual[d.seq].lookback_dt_tm)
        AND ((ce.event_class_cd=micro_class_cd
        AND ce.publish_flag > 0) OR (ce.event_class_cd=doc_class_cd
        AND ce.publish_flag >= 0
        AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")))
        AND parser(cs_where_clause))
      ORDER BY ce.person_id, ce.encntr_id
      HEAD ce.person_id
       mic_invalid_doc_rows = 0, mic_valid_doc_rows = 0, mic_valid_mbo_rows = 0
      HEAD ce.encntr_id
       IF (scope=2)
        mic_invalid_doc_rows = 0, mic_valid_doc_rows = 0, mic_valid_mbo_rows = 0
       ENDIF
       IF (checkxencntr=1)
        pidx = 0, personindex = locatevalsort(pidx,1,size(xencntr_list->person_list,5),ce.person_id,
         xencntr_list->person_list[pidx].person_id), pencntrnum = size(xencntr_list->person_list[
         personindex].encntr_list,5),
        eidx = 0, encntrindex = locateval(eidx,1,pencntrnum,ce.encntr_id,xencntr_list->person_list[
         personindex].encntr_list[eidx].encntr_id), xencntr_list->person_list[personindex].
        encntr_list[encntrindex].ce_use_flag = 1
       ENDIF
      DETAIL
       IF (ce.publish_flag=0
        AND ce.event_class_cd=doc_class_cd)
        mic_invalid_doc_rows += 1
       ELSEIF (ce.publish_flag > 0
        AND ce.event_class_cd=doc_class_cd)
        mic_valid_doc_rows += 1
       ELSE
        mic_valid_mbo_rows += 1
       ENDIF
       idx = 0
       IF (checkxencntr=0)
        encntrindex = locatevalsort(idx,1,distinct_cnt,ce.encntr_id,distinct_cp_encntr->encntr_list[
         idx].encntr_id)
        IF (encntrindex > 0
         AND (ce.clinsig_updt_dt_tm > distinct_cp_encntr->encntr_list[encntrindex].
        latest_clinsig_updt_dt_tm))
         distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm = ce
         .clinsig_updt_dt_tm
        ENDIF
       ELSE
        IF ((ce.clinsig_updt_dt_tm > xencntr_list->person_list[personindex].latest_clinsig_updt_dt_tm
        ))
         xencntr_list->person_list[personindex].latest_clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
        ENDIF
       ENDIF
      FOOT  ce.encntr_id
       IF (checkxencntr=0
        AND ((mic_valid_mbo_rows > mic_invalid_doc_rows) OR (mic_valid_doc_rows > 0)) )
        count3 += 1
        IF (mod(count3,bind_cnt)=1)
         stat = alterlist(chart_rec->qual,(count3+ (bind_cnt - 1)))
        ENDIF
        chart_rec->qual[count3].encntr_id = ce.encntr_id, chart_rec->qual[count3].person_id = ce
        .person_id, chart_rec->qual[count3].chart_date = cnvtdatetime(mbo_flat_rec->qual[d.seq].
         chart_date),
        chart_rec->qual[count3].chart_acc = " ", chart_rec->qual[count3].chart_order = 0, chart_rec->
        qual[count3].event_id = 0.0,
        chart_rec->qual[count3].linked_event_id = 0, chart_rec->qual[count3].dont_use = 0, chart_rec
        ->qual[count3].non_ce_begin_dt_tm = cnvtdatetime(mbo_flat_rec->qual[d.seq].non_ce_begin_dt_tm
         )
       ENDIF
      FOOT REPORT
       IF (checkxencntr=0)
        stat = alterlist(chart_rec->qual,count3)
       ENDIF
      WITH counter
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 IF (test_ind > 10)
  CALL echorecord(chart_rec)
 ENDIF
 SET message_log = concat("Number of requests after select on clinical_event table = ",cnvtstring(
   count3))
 CALL update_log(trim(message_log))
 IF (count3 > 0)
  SET chartreccnt = size(chart_rec->qual,5)
  IF (((trim(cnvtupper(substring(1,6,output_dist)))="CLIENT") OR (drt_criteria=1)) )
   IF (trim(cnvtupper(substring(1,6,output_dist)))="CLIENT")
    SET string_len = (size(output_dist,1) - 6)
    SET output_dest_cd = cnvtreal(trim(substring(7,string_len,output_dist)))
    SELECT INTO "nl:"
     rdt.output_format_cd
     FROM output_dest od,
      remote_device rd,
      remote_device_type rdt
     PLAN (od
      WHERE od.output_dest_cd=output_dest_cd)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd)
      JOIN (rdt
      WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
     DETAIL
      output_device_cd = rdt.output_format_cd
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    xref.device_cd, cd.encntr_id
    FROM (dummyt d  WITH seq = value(chartreccnt)),
     chart_temp cd,
     cr_destination_xref xref,
     output_dest od,
     remote_device rd,
     remote_device_type rdt
    PLAN (d)
     JOIN (cd
     WHERE (cd.encntr_id=chart_rec->qual[d.seq].encntr_id)
      AND cd.distribution_id=distr_id)
     JOIN (xref
     WHERE (xref.parent_entity_name= Outerjoin("ORGANIZATION"))
      AND (xref.parent_entity_id= Outerjoin(cd.organization_id)) )
     JOIN (od
     WHERE od.device_cd=xref.device_cd)
     JOIN (rd
     WHERE (rd.device_cd= Outerjoin(od.device_cd)) )
     JOIN (rdt
     WHERE (rdt.remote_dev_type_id= Outerjoin(rd.remote_dev_type_id)) )
    ORDER BY cd.encntr_id
    DETAIL
     IF (((od.output_dest_cd > 0.0) OR (size(trim(xref.dms_service_identifier)) > 0)) )
      chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
      output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(xref
       .dms_service_identifier)
     ELSE
      chart_rec->qual[d.seq].output_dest_cd = output_dest_cd, chart_rec->qual[d.seq].output_device_cd
       = output_device_cd
     ENDIF
    WITH nocounter
   ;end select
   FOR (x = 1 TO chartreccnt)
     IF (drt_criteria=1
      AND (chart_rec->qual[x].output_dest_cd=0.0)
      AND size(trim(chart_rec->qual[x].dms_service_ident))=0)
      SET chart_rec->qual[x].output_dest_cd = default_output_dest_cd
      SET chart_rec->qual[x].output_device_cd = default_output_device_cd
     ENDIF
   ENDFOR
  ENDIF
  SET chartreccnt = size(chart_rec->qual,5)
  SET loc_lvl = 0
  IF (scope IN (1, 2, 4, 5, 6))
   IF (((trim(output_dist)="") OR (drt_criteria=2)) )
    SELECT INTO "nl:"
     xref.device_cd, cd.encntr_id
     FROM (dummyt d  WITH seq = value(chartreccnt)),
      chart_temp cd,
      dummyt d1,
      cr_destination_xref xref,
      output_dest od,
      dummyt d2,
      remote_device rd,
      remote_device_type rdt
     PLAN (d)
      JOIN (cd
      WHERE (cd.encntr_id=chart_rec->qual[d.seq].encntr_id)
       AND cd.distribution_id=distr_id)
      JOIN (d1)
      JOIN (xref
      WHERE xref.parent_entity_name="LOCATION"
       AND xref.parent_entity_id IN (cd.loc_facility_cd, cd.loc_building_cd, cd.loc_nurse_unit_cd, cd
      .loc_room_cd, cd.loc_bed_cd))
      JOIN (od
      WHERE od.device_cd=xref.device_cd)
      JOIN (d2)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd)
      JOIN (rdt
      WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
     ORDER BY cd.encntr_id
     HEAD cd.encntr_id
      loc_lvl = 9
     DETAIL
      CASE (xref.parent_entity_id)
       OF cd.loc_facility_cd:
        IF (5 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 5
        ENDIF
       OF cd.loc_building_cd:
        IF (4 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 4
        ENDIF
       OF cd.loc_nurse_unit_cd:
        IF (3 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 3
        ENDIF
       OF cd.loc_room_cd:
        IF (2 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 2
        ENDIF
       OF cd.loc_bed_cd:
        IF (1 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 1
        ENDIF
      ENDCASE
     WITH nocounter, outerjoin = d2, outerjoin = d1
    ;end select
    FOR (x = 1 TO chartreccnt)
      IF (drt_criteria=2
       AND (chart_rec->qual[x].output_dest_cd=0.0)
       AND size(trim(chart_rec->qual[x].dms_service_ident))=0)
       SET chart_rec->qual[x].output_dest_cd = default_output_dest_cd
       SET chart_rec->qual[x].output_device_cd = default_output_device_cd
      ENDIF
    ENDFOR
   ELSE
    IF (trim(cnvtupper(substring(1,5,output_dist)))="OOOOO")
     SET string_len = (size(output_dist,1) - 5)
     SET output_dest_cd = cnvtreal(trim(substring(6,string_len,output_dist)))
    ELSE
     SET output_dest_cd = cnvtreal(output_dist)
    ENDIF
    SELECT INTO "nl:"
     rdt.output_format_cd
     FROM output_dest od,
      remote_device rd,
      remote_device_type rdt
     PLAN (od
      WHERE od.output_dest_cd=output_dest_cd)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd)
      JOIN (rdt
      WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
     DETAIL
      output_device_cd = rdt.output_format_cd
     WITH nocounter
    ;end select
   ENDIF
   IF (drt_criteria=3
    AND scope != 6)
    SELECT INTO "nl:"
     oa.order_locn_cd
     FROM (dummyt d  WITH seq = value(chartreccnt)),
      order_action oa,
      cr_destination_xref xref,
      output_dest od,
      dummyt d2,
      remote_device rd,
      remote_device_type rdt
     PLAN (d)
      JOIN (oa
      WHERE (oa.order_id=chart_rec->qual[d.seq].chart_order))
      JOIN (xref
      WHERE xref.parent_entity_name="LOCATION"
       AND xref.parent_entity_id=oa.order_locn_cd)
      JOIN (od
      WHERE od.device_cd=xref.device_cd)
      JOIN (d2)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd)
      JOIN (rdt
      WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
     DETAIL
      chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
      output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(xref
       .dms_service_identifier)
     WITH nocounter, outerjoin = d2
    ;end select
    FOR (x = 1 TO chartreccnt)
      IF ((chart_rec->qual[x].output_dest_cd=0.0)
       AND size(trim(chart_rec->qual[x].dms_service_ident))=0)
       SET chart_rec->qual[x].output_dest_cd = default_output_dest_cd
       SET chart_rec->qual[x].output_device_cd = default_output_device_cd
      ENDIF
    ENDFOR
   ELSEIF (drt_criteria=4
    AND scope != 6)
    SELECT INTO "nl:"
     oa.order_id, oa.action_dt_tm, ce.event_start_dt_tm
     FROM (dummyt d  WITH seq = value(chartreccnt)),
      clinical_event ce,
      order_action oa
     PLAN (d)
      JOIN (ce
      WHERE (ce.encntr_id=chart_rec->qual[d.seq].encntr_id)
       AND (ce.accession_nbr=chart_rec->qual[d.seq].chart_acc)
       AND (ce.person_id=chart_rec->qual[d.seq].person_id))
      JOIN (oa
      WHERE (oa.order_id= Outerjoin(ce.order_id))
       AND (oa.action_type_cd= Outerjoin(order_cd)) )
     ORDER BY ce.accession_nbr, oa.action_dt_tm
     DETAIL
      IF (oa.order_id > 0)
       chart_rec->qual[d.seq].patient_loc_date = oa.action_dt_tm
      ELSE
       chart_rec->qual[d.seq].patient_loc_date = ce.event_start_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     elh.loc_facility_cd, elh.loc_building_cd, elh.loc_nurse_unit_cd,
     elh.loc_room_cd, elh.loc_bed_cd
     FROM (dummyt d  WITH seq = value(chartreccnt)),
      encntr_loc_hist elh,
      dummyt d1,
      cr_destination_xref xref,
      output_dest od,
      dummyt d2,
      remote_device rd,
      remote_device_type rdt
     PLAN (d)
      JOIN (elh
      WHERE (elh.encntr_id=chart_rec->qual[d.seq].encntr_id)
       AND elh.active_ind=1
       AND cnvtdatetime(chart_rec->qual[d.seq].patient_loc_date) BETWEEN elh.beg_effective_dt_tm AND
      elh.end_effective_dt_tm)
      JOIN (d1)
      JOIN (xref
      WHERE xref.parent_entity_name="LOCATION"
       AND xref.parent_entity_id IN (elh.loc_facility_cd, elh.loc_building_cd, elh.loc_nurse_unit_cd,
      elh.loc_room_cd, elh.loc_bed_cd))
      JOIN (od
      WHERE od.device_cd=xref.device_cd)
      JOIN (d2)
      JOIN (rd
      WHERE rd.device_cd=od.device_cd)
      JOIN (rdt
      WHERE rdt.remote_dev_type_id=rd.remote_dev_type_id)
     ORDER BY d.seq
     HEAD d.seq
      loc_lvl = 9
     DETAIL
      encntr_id = chart_rec->qual[d.seq].encntr_id, accession_nbr = chart_rec->qual[d.seq].chart_acc
      CASE (xref.parent_entity_id)
       OF elh.loc_facility_cd:
        IF (5 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 5
        ENDIF
       OF elh.loc_building_cd:
        IF (4 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 4
        ENDIF
       OF elh.loc_nurse_unit_cd:
        IF (3 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 3
        ENDIF
       OF elh.loc_room_cd:
        IF (2 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 2
        ENDIF
       OF elh.loc_bed_cd:
        IF (1 <= loc_lvl)
         chart_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, chart_rec->qual[d.seq].
         output_device_cd = rdt.output_format_cd, chart_rec->qual[d.seq].dms_service_ident = trim(
          xref.dms_service_identifier),
         loc_lvl = 1
        ENDIF
      ENDCASE
     WITH nocounter, outerjoin = d2, outerjoin = d1
    ;end select
    FOR (x = 1 TO chartreccnt)
      IF ((chart_rec->qual[x].output_dest_cd=0.0)
       AND size(trim(chart_rec->qual[x].dms_service_ident))=0)
       SET chart_rec->qual[x].output_dest_cd = default_output_dest_cd
       SET chart_rec->qual[x].output_device_cd = default_output_device_cd
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SET cdf_meaning1 = uar_get_code_meaning(sort_seq_cd)
  SET sort_seq = cnvtint(cdf_meaning1)
  SET req_cnt = 0
  SET prov_cnt = 0
  FREE SET temp_request
  RECORD temp_request(
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = c20
      2 event_id = f8
      2 linked_event_id = f8
      2 date_range_ind = i2
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 output_dest_cd = f8
      2 output_device_cd = f8
      2 nurse_unit_cv = f8
      2 org = vc
      2 display = c40
      2 mrnt = c9
      2 name = vc
      2 room = c40
      2 bed = c40
      2 mrn = c30
      2 fac = c40
      2 orders[*]
        3 order_id = f8
      2 prov[*]
        3 person_id = f8
        3 r_cd = f8
        3 copy_ind = i2
        3 prov_name = vc
      2 non_ce_begin_dt_tm = dq8
      2 dms_service_ident = vc
  )
  IF (exp_ind=exclude_exp_prov_ind)
   SET exp_prov_parser = "cpr2.expiration_ind = 0"
  ELSE
   SET exp_prov_parser = "1=1"
  ENDIF
  SELECT INTO "nl:"
   cd.encntr_id, cd.person_id, cd.loc_room_cd,
   cd.loc_bed_cd, cd.loc_facility_cd, cd.person_id,
   cd.encntr_type_cd, cpr2.prsnl_person_id, cpr2.chart_prsnl_r_type_cd,
   cv.collation_seq, scope_order2 =
   IF (scope IN (1, 2, 5)) cnvtstring(chart_rec->qual[d4.seq].encntr_id)
   ELSEIF (scope=4) chart_rec->qual[d4.seq].chart_acc
   ELSEIF (scope=6) cnvtstring(chart_rec->qual[d4.seq].event_id)
   ENDIF
   , pr.name_last_key,
   pr.name_first_key, pr.person_id, o.org_name,
   ea.alias, pe.name_last_key, pe.name_first_key,
   mrnt = decode(ea.seq,build(substring(199,2,format(cnvtalphanum(ea.alias),";p0")),substring(197,2,
      format(cnvtalphanum(ea.alias),";p0")),substring(195,2,format(cnvtalphanum(ea.alias),";p0"))),
    " "), mrn3 = decode(ea.seq,build(substring(198,3,format(cnvtalphanum(ea.alias),";p0")),substring(
      195,3,format(cnvtalphanum(ea.alias),";p0")))," "), mrn4 = decode(ea.seq,build(substring(197,4,
      format(cnvtalphanum(ea.alias),";p0")),substring(193,4,format(cnvtalphanum(ea.alias),";p0"))),
    " "),
   mrn = substring(1,30,format(cnvtalphanum(ea.alias),"##############################"))
   FROM (dummyt d4  WITH seq = value(count3)),
    chart_prsnl_reltn2 cpr2,
    chart_temp cd,
    code_value cv,
    person pe,
    organization o,
    encntr_alias ea,
    dummyt d7,
    dummyt d5,
    prsnl pr,
    dummyt d6
   PLAN (d4
    WHERE (chart_rec->qual[d4.seq].dont_use=0))
    JOIN (cd
    WHERE cd.distribution_id=distr_id
     AND (cd.encntr_id=chart_rec->qual[d4.seq].encntr_id))
    JOIN (d7)
    JOIN (ea
    WHERE cd.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=mrn_code
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(dist_date)
     AND ea.end_effective_dt_tm > cnvtdatetime(dist_date))
    JOIN (d5)
    JOIN (pe
    WHERE pe.person_id=cd.person_id)
    JOIN (o
    WHERE o.organization_id=cd.organization_id)
    JOIN (cv
    WHERE cv.code_value=cd.loc_nurse_unit_cd)
    JOIN (d6)
    JOIN (cpr2
    WHERE cpr2.encntr_id=cd.encntr_id
     AND cpr2.person_id=cd.person_id
     AND parser(prov->prov_no)
     AND parser(prov_routing_clause)
     AND cpr2.r_beg_effective_dt_tm <= cnvtdatetime(dist_date)
     AND cpr2.r_end_effective_dt_tm >= cnvtdatetime(dist_date)
     AND parser(exp_prov_parser))
    JOIN (pr
    WHERE pr.active_ind=1
     AND pr.person_id=cpr2.prsnl_person_id)
   ORDER BY scope_order2, cpr2.prsnl_person_id, cpr2.chart_prsnl_r_type_cd
   HEAD REPORT
    req_cnt = 0
   HEAD scope_order2
    prov_cnt = 0, req_cnt += 1
    IF (mod(req_cnt,10)=1)
     stat = alterlist(temp_request->qual,(req_cnt+ 9))
    ENDIF
    temp_request->qual[req_cnt].person_id = cd.person_id, temp_request->qual[req_cnt].encntr_id = cd
    .encntr_id, temp_request->qual[req_cnt].order_id = chart_rec->qual[d4.seq].chart_order,
    temp_request->qual[req_cnt].accession_nbr = chart_rec->qual[d4.seq].chart_acc, temp_request->
    qual[req_cnt].event_id = chart_rec->qual[d4.seq].event_id, temp_request->qual[req_cnt].
    linked_event_id = chart_rec->qual[d4.seq].linked_event_id
    IF ((chart_rec->qual[d4.seq].chart_date >= cnvtdatetime("01-jan-1800")))
     temp_request->qual[req_cnt].date_range_ind = 1, temp_request->qual[req_cnt].begin_dt_tm =
     cnvtdatetime(chart_rec->qual[d4.seq].chart_date), temp_request->qual[req_cnt].non_ce_begin_dt_tm
      = cnvtdatetime(chart_rec->qual[d4.seq].non_ce_begin_dt_tm)
    ELSE
     temp_request->qual[req_cnt].date_range_ind = 0, temp_request->qual[req_cnt].begin_dt_tm =
     cnvtdatetime("01-jan-1800"), temp_request->qual[req_cnt].non_ce_begin_dt_tm = cnvtdatetime(
      "01-jan-1800")
    ENDIF
    IF (((trim(output_dist)="") OR (((trim(cnvtupper(substring(1,6,output_dist)))="CLIENT") OR (
    drt_criteria > 0)) )) )
     IF (drt_criteria=5)
      temp_request->qual[req_cnt].output_dest_cd = cnvtreal(output_dist), temp_request->qual[req_cnt]
      .output_device_cd = output_device_cd
     ELSE
      temp_request->qual[req_cnt].output_dest_cd = chart_rec->qual[d4.seq].output_dest_cd,
      temp_request->qual[req_cnt].output_device_cd = chart_rec->qual[d4.seq].output_device_cd,
      temp_request->qual[req_cnt].dms_service_ident = chart_rec->qual[d4.seq].dms_service_ident
     ENDIF
    ELSE
     IF (prov_no_cnt=1
      AND order_doc_ind=1
      AND scope=4
      AND trim(cnvtupper(substring(1,5,output_dist)))="OOOOO")
      string_len = (size(output_dist,1) - 5), temp_request->qual[req_cnt].output_dest_cd = cnvtreal(
       trim(substring(6,string_len,output_dist)))
     ELSE
      temp_request->qual[req_cnt].output_dest_cd = cnvtreal(output_dist)
     ENDIF
     temp_request->qual[req_cnt].output_device_cd = output_device_cd
    ENDIF
    temp_request->qual[req_cnt].nurse_unit_cv = cnvtreal(cv.collation_seq), temp_request->qual[
    req_cnt].display = cnvtupper(uar_get_code_display(cd.encntr_type_cd)), temp_request->qual[req_cnt
    ].org = cnvtupper(o.org_name)
    IF (sort_seq IN (10, 13, 17))
     temp_request->qual[req_cnt].mrnt = mrn3
    ELSEIF (sort_seq IN (11, 14, 16))
     temp_request->qual[req_cnt].mrnt = mrn4
    ELSE
     temp_request->qual[req_cnt].mrnt = mrnt
    ENDIF
    temp_request->qual[req_cnt].name = concat(trim(pe.name_last_key),", ",trim(pe.name_first_key)),
    temp_request->qual[req_cnt].room = cnvtupper(uar_get_code_display(cd.loc_room_cd)), temp_request
    ->qual[req_cnt].bed = cnvtupper(uar_get_code_display(cd.loc_bed_cd)),
    temp_request->qual[req_cnt].mrn = mrn, temp_request->qual[req_cnt].fac = cnvtupper(
     uar_get_code_display(cd.loc_facility_cd)), idx = 0
    IF (scope=4)
     accnindex = locateval(idx,1,size(chart_rec->qual,5),scope_order2,chart_rec->qual[idx].chart_acc),
     order_cnt = 0, stat = alterlist(temp_request->qual[req_cnt].orders,size(chart_rec->qual[
       accnindex].orders,5))
     FOR (x = 1 TO size(chart_rec->qual[accnindex].orders,5))
       temp_request->qual[req_cnt].orders[x].order_id = chart_rec->qual[accnindex].orders[x].order_id
     ENDFOR
    ENDIF
   HEAD cpr2.prsnl_person_id
    IF (cpr2.prsnl_person_id > 0.0
     AND cpr2.chart_prsnl_r_type_cd > 0.0)
     IF (((scope IN (1, 2, 5)
      AND order_doc_ind=1
      AND cpr2.chart_prsnl_r_type_cd=order_doc_cd) OR (((scope IN (1, 2, 5)
      AND consult_encntr_ind=1
      AND cpr2.chart_prsnl_r_type_cd=consult_doc_cd) OR (((consult_encntr_ind=1
      AND cpr2.chart_prsnl_r_type_cd=consult_doc_cd) OR (cpr2.chart_prsnl_r_type_cd != order_doc_cd
      AND cpr2.chart_prsnl_r_type_cd != consult_doc_cd)) )) )) )
      prov_cnt += 1
      IF (mod(prov_cnt,10)=1)
       stat = alterlist(temp_request->qual[req_cnt].prov,(prov_cnt+ 9))
      ENDIF
      temp_request->qual[req_cnt].prov[prov_cnt].person_id = cpr2.prsnl_person_id, temp_request->
      qual[req_cnt].prov[prov_cnt].r_cd = cpr2.chart_prsnl_r_type_cd, temp_request->qual[req_cnt].
      prov[prov_cnt].copy_ind = 1,
      temp_request->qual[req_cnt].prov[prov_cnt].prov_name = concat(trim(pr.name_last_key),", ",trim(
        pr.name_first_key))
     ENDIF
    ENDIF
   DETAIL
    CALL addrelationship(
    IF (scope=1) cnvtstring(chart_rec->qual[d4.seq].person_id)
    ELSEIF (scope IN (2, 5)) cnvtstring(chart_rec->qual[d4.seq].encntr_id)
    ELSEIF (scope=4) chart_rec->qual[d4.seq].chart_acc
    ELSEIF (scope=6) cnvtstring(chart_rec->qual[d4.seq].event_id)
    ENDIF
    ,cpr2.prsnl_person_id,cpr2.chart_prsnl_r_type_cd)
   FOOT  scope_order2
    stat = alterlist(temp_request->qual[req_cnt].prov,prov_cnt)
    IF (scope=4
     AND size(temp_request->qual[req_cnt].orders,5) > max_order_count)
     max_order_count = size(temp_request->qual[req_cnt].orders,5)
    ENDIF
   FOOT REPORT
    stat = alterlist(temp_request->qual,req_cnt)
   WITH nocounter, outerjoin = d6, outerjoin = d5,
    outerjoin = d7, dontcare = ea
  ;end select
  SET stat = initrec(chart_rec)
  SET cnt1 = 0
  IF (scope=4
   AND ((consult_order_ind=1) OR (cc_consult_ind=1))
   AND max_order_count > 0)
   SET oe_field_meaning_clause = build("od.oe_field_meaning_id = ",oe_field_meaning_id_consultdoc)
   IF (cc_consult_ind=1)
    IF (consult_order_ind=1)
     SET oe_field_meaning_clause = build(oe_field_meaning_clause," or od.oe_field_meaning_id = ",
      oe_field_meaning_id_ccprovider)
    ELSE
     SET oe_field_meaning_clause = build("od.oe_field_meaning_id = ",oe_field_meaning_id_ccprovider)
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    od.order_id, od.detail_sequence, pr.name_last_key,
    pr.name_first_key, pr.person_id, od.oe_field_id
    FROM (dummyt d7  WITH seq = value(req_cnt)),
     (dummyt d8  WITH seq = 1),
     prsnl pr,
     order_detail od,
     (
     (
     (SELECT
      od.order_id, od.oe_field_id, od.oe_field_meaning_id,
      action_sequence = max(od.action_sequence)
      FROM order_detail od
      WHERE (od.order_id=temp_request->qual[d7.seq].orders[d8.seq].order_id)
       AND od.order_id > 0
       AND parser(oe_field_meaning_clause)
      GROUP BY od.order_id, od.oe_field_id, od.oe_field_meaning_id
      WITH sqltype("f8","f8","f8","i4"), orahintcbo("INDEX(od XIE2ORDER_DETAIL)")))
     od2)
    PLAN (d7
     WHERE maxrec(d8,size(temp_request->qual[d7.seq].orders,5)))
     JOIN (d8)
     JOIN (od
     WHERE (od.order_id=temp_request->qual[d7.seq].orders[d8.seq].order_id)
      AND od.order_id > 0
      AND parser(oe_field_meaning_clause)
      AND parser(prov_routing_consult_clause))
     JOIN (pr
     WHERE pr.active_ind=1
      AND pr.person_id=od.oe_field_value)
     JOIN (od2
     WHERE od2.order_id=od.order_id
      AND od2.oe_field_meaning_id=od.oe_field_meaning_id
      AND od2.oe_field_id=od.oe_field_id
      AND od2.action_sequence=od.action_sequence)
    ORDER BY d7.seq, od.order_id, od.action_sequence DESC,
     od.detail_sequence
    HEAD d7.seq
     cnt1 = 0, prov_cnt = size(temp_request->qual[d7.seq].prov,5)
    DETAIL
     IF (od.oe_field_value > 0)
      cnt1 += 1, stat = alterlist(temp_request->qual[d7.seq].prov,(cnt1+ prov_cnt)), temp_request->
      qual[d7.seq].prov[(cnt1+ prov_cnt)].person_id = od.oe_field_value,
      temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].copy_ind = 1, temp_request->qual[d7.seq].
      prov[(cnt1+ prov_cnt)].prov_name = concat(trim(pr.name_last_key),", ",trim(pr.name_first_key))
      IF (od.oe_field_meaning_id=oe_field_meaning_id_consultdoc)
       CALL addrelationship(temp_request->qual[d7.seq].accession_nbr,od.oe_field_value,consult_doc_cd
       ), temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].r_cd = consult_doc_cd
      ELSE
       CALL addrelationship(temp_request->qual[d7.seq].accession_nbr,od.oe_field_value,cc_provider_cd
       )
      ENDIF
     ENDIF
    WITH nocounter, orahintcbo("INDEX(od XIE2ORDER_DETAIL)")
   ;end select
   CALL echorecord(temp_request)
  ENDIF
  IF (scope=4
   AND order_doc_ind=1
   AND max_order_count > 0)
   SELECT DISTINCT INTO "nl:"
    oa.order_id, od.output_dest_cd, dx.device_cd,
    rd.device_cd, rdt.remote_dev_type_id, p.name_last_key,
    p.name_first_key, check = decode(dx.device_cd,1,0)
    FROM (dummyt d7  WITH seq = value(req_cnt)),
     (dummyt d8  WITH seq = 1),
     order_action oa,
     charting_operations_prsnl cop,
     cr_destination_xref dx,
     output_dest od,
     remote_device rd,
     remote_device_type rdt,
     prsnl p
    PLAN (d7
     WHERE maxrec(d8,size(temp_request->qual[d7.seq].orders,5)))
     JOIN (d8)
     JOIN (oa
     WHERE (oa.order_id=temp_request->qual[d7.seq].orders[d8.seq].order_id)
      AND oa.action_type_cd IN (order_cd, activate_cd, modify_cd, renew_cd, resume_cd,
     stud_activate_cd)
      AND oa.action_rejected_ind=0
      AND oa.order_provider_id > 0)
     JOIN (cop
     WHERE (cop.prsnl_id= Outerjoin(oa.order_provider_id))
      AND (cop.charting_operations_id= Outerjoin(charting_operations_id)) )
     JOIN (p
     WHERE p.active_ind=1
      AND (p.person_id= Outerjoin(oa.order_provider_id)) )
     JOIN (dx
     WHERE (dx.parent_entity_id= Outerjoin(oa.order_provider_id))
      AND (dx.parent_entity_name= Outerjoin("PRSNL")) )
     JOIN (od
     WHERE (od.device_cd= Outerjoin(dx.device_cd)) )
     JOIN (rd
     WHERE (rd.device_cd= Outerjoin(od.device_cd)) )
     JOIN (rdt
     WHERE (rdt.remote_dev_type_id= Outerjoin(rd.remote_dev_type_id)) )
    ORDER BY d7.seq, oa.order_id, oa.action_sequence DESC
    HEAD d7.seq
     cnt1 = 0, prov_cnt = size(temp_request->qual[d7.seq].prov,5)
     IF (prov_no_cnt=1
      AND ooooo_ind=1
      AND check=1)
      temp_request->qual[d7.seq].output_dest_cd = od.output_dest_cd, temp_request->qual[d7.seq].
      output_device_cd = rdt.output_format_cd, temp_request->qual[d7.seq].dms_service_ident = trim(dx
       .dms_service_identifier)
     ENDIF
    HEAD oa.order_id
     IF (((order_doc_flag=1) OR (order_doc_flag=2)) )
      IF (((((prov_routing_flag=2) OR (prov_routing_flag=3))
       AND oa.order_provider_id != cop.prsnl_id) OR (((prov_routing_flag=1
       AND oa.order_provider_id=cop.prsnl_id) OR (prov_routing_flag=0)) )) )
       cnt1 += 1, stat = alterlist(temp_request->qual[d7.seq].prov,(cnt1+ prov_cnt)), temp_request->
       qual[d7.seq].prov[(cnt1+ prov_cnt)].person_id = oa.order_provider_id,
       temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].r_cd = order_doc_cd, temp_request->qual[d7
       .seq].prov[(cnt1+ prov_cnt)].copy_ind = 1, temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].
       prov_name = concat(trim(p.name_last_key),", ",trim(p.name_first_key)),
       CALL addrelationship(temp_request->qual[d7.seq].accession_nbr,oa.order_provider_id,
       order_doc_cd)
      ENDIF
     ENDIF
    DETAIL
     IF (order_doc_flag=3)
      IF (((((prov_routing_flag=2) OR (prov_routing_flag=3))
       AND oa.order_provider_id != cop.prsnl_id) OR (((prov_routing_flag=1
       AND oa.order_provider_id=cop.prsnl_id) OR (prov_routing_flag=0)) )) )
       cnt1 += 1, stat = alterlist(temp_request->qual[d7.seq].prov,(cnt1+ prov_cnt)), temp_request->
       qual[d7.seq].prov[(cnt1+ prov_cnt)].person_id = oa.order_provider_id,
       temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].r_cd = order_doc_cd, temp_request->qual[d7
       .seq].prov[(cnt1+ prov_cnt)].copy_ind = 1, temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].
       prov_name = concat(trim(p.name_last_key),", ",trim(p.name_first_key)),
       CALL addrelationship(temp_request->qual[d7.seq].accession_nbr,oa.order_provider_id,
       order_doc_cd)
      ENDIF
     ENDIF
    FOOT  oa.order_id
     IF (((order_doc_flag=0) OR (order_doc_flag=2)) )
      IF (((((prov_routing_flag=2) OR (prov_routing_flag=3))
       AND oa.order_provider_id != cop.prsnl_id) OR (((prov_routing_flag=1
       AND oa.order_provider_id=cop.prsnl_id) OR (prov_routing_flag=0)) )) )
       cnt1 += 1, stat = alterlist(temp_request->qual[d7.seq].prov,(cnt1+ prov_cnt)), temp_request->
       qual[d7.seq].prov[(cnt1+ prov_cnt)].person_id = oa.order_provider_id,
       temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].r_cd = order_doc_cd, temp_request->qual[d7
       .seq].prov[(cnt1+ prov_cnt)].copy_ind = 1, temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].
       prov_name = concat(trim(p.name_last_key),", ",trim(p.name_first_key)),
       CALL addrelationship(temp_request->qual[d7.seq].accession_nbr,oa.order_provider_id,
       order_doc_cd)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL echorecord(temp_request)
  ENDIF
  IF (scope=6
   AND ((ncopytoauthorind=1) OR (ncopytoreviewerind=1)) )
   IF (ncopytoauthorind=1
    AND ncopytoreviewerind=1)
    SET sactiontypesparser = build("cep.action_type_cd in (",dsigncd,",",dcosigncd,",",
     dreviewcd,")")
   ELSEIF (ncopytoauthorind=1)
    SET sactiontypesparser = build("cep.action_type_cd in (",dsigncd,",",dcosigncd,")")
   ELSEIF (ncopytoreviewerind=1)
    SET sactiontypesparser = build("cep.action_type_cd in (",dreviewcd,")")
   ENDIF
   SET sactiontypesparser = build(sactiontypesparser," and cep.action_status_cd in (",comp_cd,",",
    pen_cd,
    ",",req_cd,")")
   SELECT INTO "nl:"
    od.output_dest_cd, dx.device_cd, rd.device_cd,
    rdt.remote_dev_type_id, pr.name_last_key, pr.name_first_key,
    check = decode(dx.device_cd,1,0)
    FROM (dummyt d7  WITH seq = value(req_cnt)),
     ce_event_prsnl cep,
     cr_destination_xref dx,
     output_dest od,
     remote_device rd,
     remote_device_type rdt,
     prsnl pr
    PLAN (d7)
     JOIN (cep
     WHERE (cep.event_id=temp_request->qual[d7.seq].event_id)
      AND cep.event_id > 0
      AND cep.valid_until_dt_tm >= cnvtdatetime("31-DEC-2100")
      AND parser(sactiontypesparser)
      AND parser(prov_routing_auth_review_clause))
     JOIN (pr
     WHERE pr.active_ind=1
      AND (pr.person_id= Outerjoin(cep.action_prsnl_id)) )
     JOIN (dx
     WHERE (dx.parent_entity_id= Outerjoin(cep.action_prsnl_id))
      AND (dx.parent_entity_name= Outerjoin("PRSNL")) )
     JOIN (od
     WHERE (od.device_cd= Outerjoin(dx.device_cd)) )
     JOIN (rd
     WHERE (rd.device_cd= Outerjoin(od.device_cd)) )
     JOIN (rdt
     WHERE (rdt.remote_dev_type_id= Outerjoin(rd.remote_dev_type_id)) )
    ORDER BY d7.seq, cep.event_id, cep.action_type_cd,
     0
    HEAD d7.seq
     cnt1 = 0, prov_cnt = size(temp_request->qual[d7.seq].prov,5)
     IF (prov_no_cnt=1
      AND ooooo_ind=1
      AND check=1)
      temp_request->qual[d7.seq].output_dest_cd = od.output_dest_cd, temp_request->qual[d7.seq].
      output_device_cd = rdt.output_format_cd, temp_request->qual[d7.seq].dms_service_ident = trim(dx
       .dms_service_identifier)
     ENDIF
    DETAIL
     cnt1 += 1, stat = alterlist(temp_request->qual[d7.seq].prov,(cnt1+ prov_cnt)), temp_request->
     qual[d7.seq].prov[(cnt1+ prov_cnt)].person_id = cep.action_prsnl_id,
     temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].r_cd = 0.0, temp_request->qual[d7.seq].prov[(
     cnt1+ prov_cnt)].copy_ind = 1, temp_request->qual[d7.seq].prov[(cnt1+ prov_cnt)].prov_name =
     concat(trim(pr.name_last_key),", ",trim(pr.name_first_key)),
     CALL addrelationship(cnvtstring(temp_request->qual[d7.seq].event_id),cep.action_prsnl_id,0.0)
    WITH nocounter
   ;end select
  ENDIF
  IF (prov_no_cnt > 0)
   FOR (i = 1 TO req_cnt)
     SET request_prov_cnt = size(temp_request->qual[i].prov,5)
     SET j = 2
     WHILE (j <= request_prov_cnt)
      FOR (k = 1 TO j)
        IF (k < j
         AND (temp_request->qual[i].prov[k].person_id=temp_request->qual[i].prov[j].person_id)
         AND (temp_request->qual[i].prov[k].copy_ind=1))
         SET temp_request->qual[i].prov[j].copy_ind = 0
         SET k = (j+ 1)
        ENDIF
      ENDFOR
      SET j += 1
     ENDWHILE
   ENDFOR
  ENDIF
  IF (def_chart=1)
   FOR (i = 1 TO req_cnt)
     IF (size(temp_request->qual[i].prov,5)=0)
      SET stat = alterlist(temp_request->qual[i].prov,1)
      SET temp_request->qual[i].prov[1].person_id = 0.0
      SET temp_request->qual[i].prov[1].r_cd = 0.0
      SET temp_request->qual[i].prov[1].copy_ind = 1
      SET temp_request->qual[i].prov[1].prov_name = "  "
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SET message_log = "INFO! - No patients with clinical_event rows, Exiting Job."
  CALL update_log(trim(message_log))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET req_cnt = 0
 SET req_cnt = size(temp_request->qual,5)
 CALL echo(build("req_cnt = ",req_cnt))
 IF (req_cnt > 0)
  SET new_cnt = 0
  FREE RECORD prelim_rec
  RECORD prelim_rec(
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = c20
      2 event_id = f8
      2 date_range_ind = i2
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 output_dest_cd = f8
      2 output_device_cd = f8
      2 prsnl_person_id = f8
      2 prsnl_person_r_cd = f8
      2 nurse_unit_cv = f8
      2 org = vc
      2 display = c40
      2 mrnt = c9
      2 name = vc
      2 room = c40
      2 bed = c40
      2 mrn = c30
      2 fac = c40
      2 prov_name = vc
      2 zipcode = c25
      2 prsnl_reltn_id = f8
      2 seq_nbr = i4
      2 patient_zipcode = c25
      2 non_ce_begin_dt_tm = dq8
      2 dms_service_ident = vc
  )
  SET new_cnt = 0
  FOR (i = 1 TO req_cnt)
    FOR (j = 1 TO size(temp_request->qual[i].prov,5))
      IF ((temp_request->qual[i].prov[j].copy_ind=1))
       SET new_cnt += 1
       IF (mod(new_cnt,10)=1)
        SET stat = alterlist(prelim_rec->qual,(new_cnt+ 9))
       ENDIF
       SET prelim_rec->qual[new_cnt].person_id = temp_request->qual[i].person_id
       SET prelim_rec->qual[new_cnt].encntr_id = temp_request->qual[i].encntr_id
       SET prelim_rec->qual[new_cnt].order_id = temp_request->qual[i].order_id
       SET prelim_rec->qual[new_cnt].accession_nbr = temp_request->qual[i].accession_nbr
       SET prelim_rec->qual[new_cnt].event_id = temp_request->qual[i].event_id
       SET prelim_rec->qual[new_cnt].date_range_ind = temp_request->qual[i].date_range_ind
       SET prelim_rec->qual[new_cnt].begin_dt_tm = temp_request->qual[i].begin_dt_tm
       SET prelim_rec->qual[new_cnt].end_dt_tm = temp_request->qual[i].end_dt_tm
       SET prelim_rec->qual[new_cnt].output_dest_cd = temp_request->qual[i].output_dest_cd
       SET prelim_rec->qual[new_cnt].output_device_cd = temp_request->qual[i].output_device_cd
       SET prelim_rec->qual[new_cnt].dms_service_ident = temp_request->qual[i].dms_service_ident
       SET prelim_rec->qual[new_cnt].nurse_unit_cv = temp_request->qual[i].nurse_unit_cv
       SET prelim_rec->qual[new_cnt].org = temp_request->qual[i].org
       SET prelim_rec->qual[new_cnt].display = temp_request->qual[i].display
       SET prelim_rec->qual[new_cnt].mrnt = temp_request->qual[i].mrnt
       SET prelim_rec->qual[new_cnt].name = temp_request->qual[i].name
       SET prelim_rec->qual[new_cnt].room = temp_request->qual[i].room
       SET prelim_rec->qual[new_cnt].bed = temp_request->qual[i].bed
       SET prelim_rec->qual[new_cnt].mrn = temp_request->qual[i].mrn
       SET prelim_rec->qual[new_cnt].fac = temp_request->qual[i].fac
       SET prelim_rec->qual[new_cnt].output_dest_cd = temp_request->qual[i].output_dest_cd
       SET prelim_rec->qual[new_cnt].output_device_cd = temp_request->qual[i].output_device_cd
       SET prelim_rec->qual[new_cnt].dms_service_ident = temp_request->qual[i].dms_service_ident
       SET prelim_rec->qual[new_cnt].prsnl_person_id = temp_request->qual[i].prov[j].person_id
       IF (ismultirelational(
        IF (scope=1) cnvtstring(prelim_rec->qual[new_cnt].person_id)
        ELSEIF (scope IN (2, 5)) cnvtstring(prelim_rec->qual[new_cnt].encntr_id)
        ELSEIF (scope=4) prelim_rec->qual[new_cnt].accession_nbr
        ELSEIF (scope=6) cnvtstring(prelim_rec->qual[new_cnt].event_id)
        ENDIF
        ,temp_request->qual[i].prov[j].person_id))
        SET prelim_rec->qual[new_cnt].prsnl_person_r_cd = 0
       ELSE
        SET prelim_rec->qual[new_cnt].prsnl_person_r_cd = temp_request->qual[i].prov[j].r_cd
       ENDIF
       SET prelim_rec->qual[new_cnt].prov_name = trim(temp_request->qual[i].prov[j].prov_name)
       SET prelim_rec->qual[new_cnt].non_ce_begin_dt_tm = temp_request->qual[i].non_ce_begin_dt_tm
      ENDIF
    ENDFOR
  ENDFOR
  IF (new_cnt=0)
   SET message_log = "INFO! - No providers to print copies for, Exiting Job."
   CALL update_log(trim(message_log))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 ELSE
  SET message_log = "INFO! - No providers to print copies for, Exiting Job."
  CALL update_log(trim(message_log))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(prelim_rec->qual,new_cnt)
 FREE RECORD temp_request
 FREE SET prelim_rec1
 RECORD prelim_rec1(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = c20
     2 event_id = f8
     2 date_range_ind = i2
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 output_dest_cd = f8
     2 output_device_cd = f8
     2 prsnl_person_id = f8
     2 prsnl_person_r_cd = f8
     2 nurse_unit_cv = f8
     2 org = vc
     2 display = c40
     2 mrnt = c9
     2 name = vc
     2 room = c40
     2 bed = c40
     2 mrn = c30
     2 fac = c40
     2 prov_name = vc
     2 zipcode = c25
     2 prsnl_reltn_id = f8
     2 seq_nbr = i4
     2 patient_zipcode = c25
     2 location_cd = f8
     2 non_ce_begin_dt_tm = dq8
     2 dms_service_ident = vc
 )
 RECORD temp_request(
   1 qual[*]
     2 prsnl_person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = c20
   1 route_type_flag = i2
 )
 FREE SET temp_reply
 RECORD temp_reply(
   1 qual[*]
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = c20
     2 prsnl_id = f8
     2 prsnl_reltn[*]
       3 prsnl_reltn_id = f8
       3 organization_id = f8
       3 output_dest_cd = f8
       3 output_device_cd = f8
       3 output_dest_name = vc
       3 device_name = vc
       3 location_cd = f8
       3 dms_service_ident = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (drt_criteria=5)
  SELECT DISTINCT INTO "NL:"
   FROM (dummyt d  WITH seq = value(new_cnt)),
    cr_destination_xref dx,
    output_dest od,
    remote_device rd,
    remote_device_type rdt
   PLAN (d)
    JOIN (dx
    WHERE (dx.parent_entity_id=prelim_rec->qual[d.seq].prsnl_person_id)
     AND dx.parent_entity_name="PRSNL")
    JOIN (od
    WHERE od.device_cd=dx.device_cd)
    JOIN (rd
    WHERE (rd.device_cd= Outerjoin(od.device_cd)) )
    JOIN (rdt
    WHERE (rdt.remote_dev_type_id= Outerjoin(rd.remote_dev_type_id)) )
   ORDER BY d.seq
   DETAIL
    IF (((od.output_dest_cd > 0) OR (size(trim(dx.dms_service_identifier)) > 0)) )
     prelim_rec->qual[d.seq].output_dest_cd = od.output_dest_cd, prelim_rec->qual[d.seq].
     output_device_cd = rdt.output_format_cd, prelim_rec->qual[d.seq].dms_service_ident = trim(dx
      .dms_service_identifier)
    ENDIF
   WITH nocounter
  ;end select
  IF (scope IN (2, 4))
   SET stat = alterlist(temp_request->qual,new_cnt)
   FOR (i = 1 TO new_cnt)
     SET temp_request->qual[i].prsnl_person_id = prelim_rec->qual[i].prsnl_person_id
     SET temp_request->qual[i].encntr_id = prelim_rec->qual[i].encntr_id
     IF (scope=4)
      SET temp_request->qual[i].accession_nbr = prelim_rec->qual[i].accession_nbr
      SET temp_request->qual[i].order_id = prelim_rec->qual[i].order_id
     ENDIF
   ENDFOR
   SET temp_request->route_type_flag = drt_criteria
   EXECUTE cp_get_chart_prsnl_dest  WITH replace(request,temp_request), replace(reply,temp_reply)
   IF ((temp_reply->status_data.status="Z"))
    SET message_log = "INFO! - No provider has chart destination defined. "
    CALL update_log(trim(message_log))
   ELSEIF ((temp_reply->status_data.status="P"))
    SET message_log = "INFO! - Not all organizations have an output device associated. "
    CALL update_log(trim(message_log))
   ELSEIF ((temp_reply->status_data.status="F"))
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to execute cp_get_chart_prsnl_dest, Exiting Job."
    SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
    CALL update_log(trim(message_log))
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET x = 0
 FOR (i = 1 TO size(prelim_rec->qual,5))
   SET x += 1
   IF (x > size(prelim_rec1->qual,5))
    SET stat = alterlist(prelim_rec1->qual,(x+ 20))
   ENDIF
   SET prelim_rec1->qual[x].person_id = prelim_rec->qual[i].person_id
   SET prelim_rec1->qual[x].encntr_id = prelim_rec->qual[i].encntr_id
   SET prelim_rec1->qual[x].order_id = prelim_rec->qual[i].order_id
   SET prelim_rec1->qual[x].accession_nbr = trim(prelim_rec->qual[i].accession_nbr)
   SET prelim_rec1->qual[x].event_id = prelim_rec->qual[i].event_id
   SET prelim_rec1->qual[x].date_range_ind = prelim_rec->qual[i].date_range_ind
   SET prelim_rec1->qual[x].begin_dt_tm = cnvtdatetime(prelim_rec->qual[i].begin_dt_tm)
   SET prelim_rec1->qual[x].end_dt_tm = cnvtdatetime(prelim_rec->qual[i].end_dt_tm)
   SET prelim_rec1->qual[x].output_dest_cd = prelim_rec->qual[i].output_dest_cd
   SET prelim_rec1->qual[x].output_device_cd = prelim_rec->qual[i].output_device_cd
   SET prelim_rec1->qual[x].nurse_unit_cv = prelim_rec->qual[i].nurse_unit_cv
   SET prelim_rec1->qual[x].org = prelim_rec->qual[i].org
   SET prelim_rec1->qual[x].display = prelim_rec->qual[i].display
   SET prelim_rec1->qual[x].mrnt = prelim_rec->qual[i].mrnt
   SET prelim_rec1->qual[x].name = prelim_rec->qual[i].name
   SET prelim_rec1->qual[x].room = prelim_rec->qual[i].room
   SET prelim_rec1->qual[x].bed = prelim_rec->qual[i].bed
   SET prelim_rec1->qual[x].mrn = prelim_rec->qual[i].mrn
   SET prelim_rec1->qual[x].fac = prelim_rec->qual[i].fac
   SET prelim_rec1->qual[x].prsnl_person_id = prelim_rec->qual[i].prsnl_person_id
   SET prelim_rec1->qual[x].prsnl_person_r_cd = prelim_rec->qual[i].prsnl_person_r_cd
   SET prelim_rec1->qual[x].prov_name = trim(prelim_rec->qual[i].prov_name)
   SET prelim_rec1->qual[x].dms_service_ident = trim(prelim_rec->qual[i].dms_service_ident)
   SET prelim_rec1->qual[x].non_ce_begin_dt_tm = cnvtdatetime(prelim_rec->qual[i].non_ce_begin_dt_tm)
   FOR (j = 1 TO size(temp_reply->qual,5))
     IF ((((temp_reply->qual[j].prsnl_id=prelim_rec->qual[i].prsnl_person_id)
      AND (temp_reply->qual[j].encntr_id=prelim_rec->qual[i].encntr_id)
      AND (temp_reply->qual[j].order_id=0)) OR ((temp_reply->qual[j].prsnl_id=prelim_rec->qual[i].
     prsnl_person_id)
      AND (temp_reply->qual[j].accession_nbr=prelim_rec->qual[i].accession_nbr)
      AND (temp_reply->qual[j].order_id=prelim_rec->qual[i].order_id)
      AND (temp_reply->qual[j].order_id > 0))) )
      FOR (k = 1 TO size(temp_reply->qual[j].prsnl_reltn,5))
        IF (k > 1)
         SET x += 1
         IF (x > size(prelim_rec1->qual,5))
          SET stat = alterlist(prelim_rec1->qual,(x+ 20))
         ENDIF
         SET prelim_rec1->qual[x].person_id = prelim_rec->qual[i].person_id
         SET prelim_rec1->qual[x].encntr_id = prelim_rec->qual[i].encntr_id
         SET prelim_rec1->qual[x].order_id = prelim_rec->qual[i].order_id
         SET prelim_rec1->qual[x].accession_nbr = trim(prelim_rec->qual[i].accession_nbr)
         SET prelim_rec1->qual[x].event_id = prelim_rec->qual[i].event_id
         SET prelim_rec1->qual[x].date_range_ind = prelim_rec->qual[i].date_range_ind
         SET prelim_rec1->qual[x].begin_dt_tm = cnvtdatetime(prelim_rec->qual[i].begin_dt_tm)
         SET prelim_rec1->qual[x].end_dt_tm = cnvtdatetime(prelim_rec->qual[i].end_dt_tm)
         SET prelim_rec1->qual[x].output_dest_cd = prelim_rec->qual[i].output_dest_cd
         SET prelim_rec1->qual[x].output_device_cd = prelim_rec->qual[i].output_device_cd
         SET prelim_rec1->qual[x].nurse_unit_cv = prelim_rec->qual[i].nurse_unit_cv
         SET prelim_rec1->qual[x].org = prelim_rec->qual[i].org
         SET prelim_rec1->qual[x].display = prelim_rec->qual[i].display
         SET prelim_rec1->qual[x].mrnt = prelim_rec->qual[i].mrnt
         SET prelim_rec1->qual[x].name = prelim_rec->qual[i].name
         SET prelim_rec1->qual[x].room = prelim_rec->qual[i].room
         SET prelim_rec1->qual[x].bed = prelim_rec->qual[i].bed
         SET prelim_rec1->qual[x].mrn = prelim_rec->qual[i].mrn
         SET prelim_rec1->qual[x].fac = prelim_rec->qual[i].fac
         SET prelim_rec1->qual[x].prsnl_person_id = prelim_rec->qual[i].prsnl_person_id
         SET prelim_rec1->qual[x].prsnl_person_r_cd = prelim_rec->qual[i].prsnl_person_r_cd
         SET prelim_rec1->qual[x].prov_name = trim(prelim_rec->qual[i].prov_name)
         SET prelim_rec1->qual[x].dms_service_ident = trim(prelim_rec->qual[i].dms_service_ident)
         SET prelim_rec1->qual[x].non_ce_begin_dt_tm = cnvtdatetime(prelim_rec->qual[i].
          non_ce_begin_dt_tm)
        ENDIF
        SET prelim_rec1->qual[x].prsnl_reltn_id = temp_reply->qual[j].prsnl_reltn[k].prsnl_reltn_id
        IF ((((temp_reply->qual[j].prsnl_reltn[k].output_dest_cd > 0)) OR (size(trim(temp_reply->
          qual[j].prsnl_reltn[k].dms_service_ident)) > 0)) )
         SET prelim_rec1->qual[x].output_dest_cd = temp_reply->qual[j].prsnl_reltn[k].output_dest_cd
         SET prelim_rec1->qual[x].output_device_cd = temp_reply->qual[j].prsnl_reltn[k].
         output_device_cd
         SET prelim_rec1->qual[x].dms_service_ident = trim(temp_reply->qual[j].prsnl_reltn[k].
          dms_service_ident)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = alterlist(prelim_rec1->qual,x)
 SET nbr_to_add = 0
 SET nbr_to_add = size(prelim_rec1->qual,5)
 CALL echo(build("nbr_to_add = ",nbr_to_add))
 IF (nbr_to_add=0)
  SET reply->status_data.status = "Z"
  SET message_log = "INFO! - No encounters qualified, Exiting Job."
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 SET req_cnt = cnvtint(nbr_to_add)
 IF (scope=5
  AND cross_encntr_law_id > 0.0)
  DELETE  FROM chart_temp ct
   WHERE ct.distribution_id=distr_id
   WITH nocounter
  ;end delete
  DECLARE ce_xencntr = vc
  DECLARE ce_xencntr_clause = vc
  DECLARE final_ce_xclause = vc
  DECLARE format_check_xencntr = vc
  FREE RECORD encntr_reltn_rec
  RECORD encntr_reltn_rec(
    1 qual[*]
      2 encntr_id = f8
  )
  FREE RECORD person_reltn_rec
  RECORD person_reltn_rec(
    1 qual[*]
      2 encntr_id = f8
  )
  FREE RECORD order_reltn_rec
  RECORD order_reltn_rec(
    1 qual[*]
      2 encntr_id = f8
  )
  SET message_log = "INFO! - Using Cross-Encounter Scope."
  CALL update_log(trim(message_log))
  SELECT DISTINCT INTO "nl:"
   dpersonid = prelim_rec1->qual[d.seq].person_id, dencntrid = prelim_rec1->qual[d.seq].encntr_id
   FROM encounter e,
    (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=prelim_rec1->qual[d.seq].encntr_id))
   ORDER BY dpersonid, e.create_dt_tm, dencntrid
   HEAD REPORT
    person_cnt = 0, encntr_cnt = 0, head_encntr = 0
   HEAD dpersonid
    person_cnt += 1
    IF (person_cnt > size(xencntr_list->person_list,5))
     stat = alterlist(xencntr_list->person_list,(person_cnt+ 9))
    ENDIF
    xencntr_list->person_list[person_cnt].person_id = dpersonid, xencntr_list->person_list[person_cnt
    ].encntr_id = dencntrid, xencntr_list->person_list[person_cnt].create_dt_tm = e.create_dt_tm,
    encntr_cnt = 1, stat = alterlist(xencntr_list->person_list[person_cnt].encntr_list,encntr_cnt),
    xencntr_list->person_list[person_cnt].encntr_list[encntr_cnt].encntr_id = dencntrid,
    xencntr_list->person_list[person_cnt].encntr_list[encntr_cnt].use_flag = 1, xencntr_list->
    person_list[person_cnt].encntr_list[encntr_cnt].dont_use_flag = 0, xencntr_list->person_list[
    person_cnt].encntr_list[encntr_cnt].ce_use_flag = 1,
    xencntr_list->person_list[person_cnt].selected_cnt += 1, head_encntr = 1
   HEAD dencntrid
    IF (head_encntr=1)
     head_encntr = 0
    ELSE
     encntr_cnt += 1, stat = alterlist(xencntr_list->person_list[person_cnt].encntr_list,encntr_cnt),
     xencntr_list->person_list[person_cnt].encntr_list[encntr_cnt].encntr_id = dencntrid,
     xencntr_list->person_list[person_cnt].encntr_list[encntr_cnt].use_flag = 1, xencntr_list->
     person_list[person_cnt].encntr_list[encntr_cnt].dont_use_flag = 0, xencntr_list->person_list[
     person_cnt].encntr_list[encntr_cnt].ce_use_flag = 1,
     xencntr_list->person_list[person_cnt].selected_cnt += 1
    ENDIF
   FOOT REPORT
    stat = alterlist(xencntr_list->person_list,person_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "ERROR! - No selected encounters, Exiting Job."
   SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
   CALL update_log(trim(message_log))
   GO TO exit_script
  ENDIF
  SET pat_cnt = 0
  SET pat_cnt = size(xencntr_list->person_list,5)
  CALL echo("after first entries into xencntr_list")
  IF (test_ind > 10)
   CALL echorecord(xencntr_list)
  ENDIF
  SET law_descr = fillstring(100," ")
  SET lookback_days = 0
  SET lookback_type_ind = 0
  SET law_prov_include = 99
  SELECT INTO "nl:"
   clfv.law_id
   FROM chart_law_filter_value clfv,
    chart_law_filter clf
   PLAN (clf
    WHERE clf.law_id=cross_encntr_law_id
     AND clf.type_flag=2)
    JOIN (clfv
    WHERE clfv.law_id=clf.law_id
     AND clfv.type_flag=2)
   ORDER BY clf.type_flag, clfv.parent_entity_id, clfv.reltn_type_cd
   HEAD REPORT
    provider_cnt = 0
   HEAD clf.type_flag
    IF (clf.type_flag=2)
     IF (clf.included_flag=1)
      law_prov_include = 1
     ELSEIF (clf.included_flag=0)
      law_prov_include = 0
     ENDIF
    ENDIF
   HEAD clfv.parent_entity_id
    provider_cnt += 1
    IF (provider_cnt > size(law_providers->qual,5))
     stat = alterlist(law_providers->qual,(provider_cnt+ 9))
    ENDIF
    law_providers->qual[provider_cnt].provider_id = clfv.parent_entity_id, relationship_cnt = 0
   DETAIL
    relationship_cnt += 1
    IF (relationship_cnt > size(law_providers->qual[provider_cnt].provider_types,5))
     stat = alterlist(law_providers->qual[provider_cnt].provider_types,(relationship_cnt+ 9))
    ENDIF
    law_providers->qual[provider_cnt].provider_types[relationship_cnt].provider_type = clfv
    .reltn_type_cd
   FOOT REPORT
    stat = alterlist(law_providers->qual,provider_cnt), stat = alterlist(law_providers->qual[
     provider_cnt].provider_types,relationship_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   clfv.reltn_type_cd
   FROM chart_law_filter_value clfv
   WHERE clfv.law_id=cross_encntr_law_id
   HEAD REPORT
    person_level_cnt = 0, encntr_level_cnt = 0, order_level_cnt = 0
   DETAIL
    IF (parser(cs331_parser->statement_clfv))
     person_level_cnt += 1
    ENDIF
    IF (parser(cs333_parser->statement_clfv))
     encntr_level_cnt += 1
    ENDIF
    IF (clfv.reltn_type_cd IN (order_doc_cd, consult_doc_cd))
     order_level_cnt += 1
    ENDIF
   WITH nocounter
  ;end select
  FREE RECORD parser_rec
  RECORD parser_rec(
    1 qual[*]
      2 statement = vc
  )
  SET cnt1 = 0
  SET cnt = 0
  SET cnt2 = 0
  SET et_included = 0
  SET cl_included = 0
  SET lc_included = 0
  SET ms_included = 0
  SET cs_included = 0
  FREE RECORD filter_rec
  RECORD filter_rec(
    1 type_flag[6]
      2 qual[*]
        3 parent_entity_id = f8
  )
  SELECT INTO "NL:"
   cl.law_id, cl.lookback_days, cl.lookback_type_ind,
   clf.type_flag, clf.included_flag, clfv.parent_entity_id,
   loc_type_meaning =
   IF (clf.type_flag=3) uar_get_code_meaning(clfv.parent_entity_id)
   ELSE " "
   ENDIF
   FROM chart_law cl,
    chart_law_filter clf,
    chart_law_filter_value clfv
   PLAN (cl
    WHERE cl.law_id=cross_encntr_law_id)
    JOIN (clf
    WHERE cl.law_id=clf.law_id)
    JOIN (clfv
    WHERE clf.law_id=clfv.law_id
     AND clf.type_flag=clfv.type_flag)
   ORDER BY clf.type_flag
   HEAD REPORT
    loc_type_cnt = 0, law_descr = trim(cl.law_descr), lookback_days = cl.lookback_days,
    lookback_type_ind = cl.lookback_type_ind, et_cnt = 0, cl_cnt = 0,
    ms_cnt = 0, cs_cnt = 0
   HEAD clf.type_flag
    IF (clf.type_flag=0)
     et_included = clf.included_flag
    ELSEIF (clf.type_flag=1)
     cl_included = clf.included_flag
    ELSEIF (clf.type_flag=2)
     do_nothing = 0
    ELSEIF (clf.type_flag=3)
     lc_included = clf.included_flag
    ELSEIF (clf.type_flag=4)
     ms_included = clf.included_flag
    ELSEIF (clf.type_flag=5)
     cs_included = clf.included_flag
    ENDIF
   DETAIL
    IF (clfv.type_flag=0)
     et_cnt += 1
     IF (et_cnt > size(filter_rec->type_flag[1].qual,5))
      stat = alterlist(filter_rec->type_flag[1].qual,(et_cnt+ 9))
     ENDIF
     filter_rec->type_flag[1].qual[et_cnt].parent_entity_id = clfv.parent_entity_id
    ELSEIF (clfv.type_flag=1)
     cl_cnt += 1
     IF (cl_cnt > size(filter_rec->type_flag[2].qual,5))
      stat = alterlist(filter_rec->type_flag[2].qual,(cl_cnt+ 9))
     ENDIF
     filter_rec->type_flag[2].qual[cl_cnt].parent_entity_id = clfv.parent_entity_id
    ELSEIF (clfv.type_flag=3)
     loc_type_cnt += 1
    ELSEIF (clfv.type_flag=4)
     ms_cnt += 1
     IF (ms_cnt > size(filter_rec->type_flag[5].qual,5))
      stat = alterlist(filter_rec->type_flag[5].qual,(ms_cnt+ 9))
     ENDIF
     filter_rec->type_flag[5].qual[ms_cnt].parent_entity_id = clfv.parent_entity_id
    ELSEIF (clfv.type_flag=5)
     cs_cnt += 1
     IF (cs_cnt > size(filter_rec->type_flag[6].qual,5))
      stat = alterlist(filter_rec->type_flag[6].qual,(cs_cnt+ 9))
     ENDIF
     filter_rec->type_flag[6].qual[cs_cnt].parent_entity_id = clfv.parent_entity_id
    ENDIF
   FOOT  clf.type_flag
    IF (clf.type_flag=0)
     stat = alterlist(filter_rec->type_flag[1].qual,et_cnt)
    ELSEIF (clf.type_flag=1)
     stat = alterlist(filter_rec->type_flag[2].qual,cl_cnt)
    ELSEIF (clf.type_flag=4)
     stat = alterlist(filter_rec->type_flag[5].qual,ms_cnt)
    ELSEIF (clf.type_flag=5)
     stat = alterlist(filter_rec->type_flag[6].qual,cs_cnt)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "ERROR! - Cross-encounter law information is not being set up correctly via distribution tool, Exiting Job."
   SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
   CALL update_log(trim(message_log))
   GO TO exit_script
  ENDIF
  SET ce_lookback_date = cnvtdatetime("01-jan-1800")
  SET pat_count = 0
  SET pat_count = size(xencntr_list->person_list,5)
  SET x_count = 0
  IF (lookback_type_ind=2)
   IF (lookback_days > 0)
    SET ce_lookback_date = cnvtdatetime(datetimeadd(cnvtdatetime(dist_date),(lookback_days * - (1))))
   ENDIF
   CALL update_log("Using Clinical Activity Lookback for Law")
  ELSE
   CALL update_log("Using Discharge Lookback for Law")
  ENDIF
  SET contrib_system_size = size(filter_rec->type_flag[6].qual,5)
  SET encntr_criteria = 0
  IF (((size(filter_rec->type_flag[1].qual,5) > 0) OR (((size(filter_rec->type_flag[2].qual,5) > 0)
   OR (((size(filter_rec->type_flag[4].qual,5) > 0) OR (size(filter_rec->type_flag[5].qual,5) > 0))
  )) )) )
   SET encntr_criteria = 1
  ENDIF
  IF (contrib_system_size > 0)
   IF (cs_included=1)
    SET cs_cross_encntr_clause =
"ce.contributor_system_cd IN (select clfv.parent_entity_id      from chart_law_filter_value clfv      where clfv.law_id = c\
ross_encntr_law_id      and clfv.type_flag = 5)\
"
   ELSEIF (cs_included=0)
    SET cs_cross_encntr_clause =
"ce.contributor_system_cd NOT IN (select clfv.parent_entity_id      from chart_law_filter_value clfv      where clfv.law_id\
 = cross_encntr_law_id      and clfv.type_flag = 5)\
"
   ENDIF
   SELECT INTO "NL:"
    FROM clinical_event ce,
     (dummyt d  WITH seq = size(xencntr_list->person_list,5))
    PLAN (d)
     JOIN (ce
     WHERE (ce.person_id=xencntr_list->person_list[d.seq].person_id)
      AND parser(cs_cross_encntr_clause)
      AND ce.clinsig_updt_dt_tm >= cnvtdatetime(ce_lookback_date)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-dec-2100"))
    ORDER BY d.seq, ce.encntr_id
    HEAD d.seq
     encntr_count = 0, encntrnbrselected = xencntr_list->person_list[d.seq].selected_cnt, encntrtotal
      = 0
    HEAD ce.encntr_id
     eidx = 0, encntridx = locateval(eidx,1,encntrnbrselected,ce.encntr_id,xencntr_list->person_list[
      d.seq].encntr_list[eidx].encntr_id)
     IF (encntridx=0)
      encntr_count += 1, encntrtotal = (encntr_count+ encntrnbrselected), stat = alterlist(
       xencntr_list->person_list[d.seq].encntr_list,encntrtotal),
      xencntr_list->person_list[d.seq].encntr_list[encntrtotal].encntr_id = ce.encntr_id,
      xencntr_list->person_list[d.seq].encntr_list[encntrtotal].use_flag =
      IF (encntr_criteria=0) 1
      ELSE 0
      ENDIF
      , xencntr_list->person_list[d.seq].encntr_list[encntrtotal].dont_use_flag =
      IF (encntr_criteria=0) 0
      ELSE 1
      ENDIF
      ,
      xencntr_list->person_list[d.seq].encntr_list[encntrtotal].ce_use_flag = 1
     ENDIF
    DETAIL
     donothing = 0
    WITH nocounter
   ;end select
  ENDIF
  SET new_cnt = 0
  SET new_cnt = size(prelim_rec1->qual,5)
  SET idx = 0
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " SELECT INTO 'nl:' "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  e.encntr_id "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " FROM encounter e, (dummyt d with seq = value(pat_cnt)) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " PLAN d "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "JOIN e WHERE e.person_id+0 > 0 and e.encntr_id > 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  " and e.person_id = xencntr_list->person_list[d.seq]->person_id "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " AND (e.disch_dt_tm = null "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  IF (lookback_type_ind=2)
   SET parser_rec->qual[idx].statement = " OR 0=0) "
  ELSEIF (lookback_type_ind=1
   AND lookback_days > 0)
   SET parser_rec->qual[idx].statement =
   " OR datetimediff(cnvtdatetime(xencntr_list->person_list[d.seq]->create_dt_tm),e.disch_dt_tm) <= lookback_days) "
  ELSEIF (lookback_type_ind=1
   AND lookback_days < 1)
   SET parser_rec->qual[idx].statement = " OR e.disch_dt_tm != null) "
  ENDIF
  SET dist_flag = 1
  CALL build_encntr_parser(dist_flag)
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " ORDER e.person_id, e.encntr_id "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " HEAD REPORT "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  encntr_cnt = 1 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  y = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  match_ind = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  selected_cnt = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " HEAD e.person_id "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  encntr_cnt = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "  selected_cnt = xencntr_list->person_list[d.seq]->selected_cnt "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " HEAD e.encntr_id "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  match_ind = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "  for (y = 1 to size(xencntr_list->person_list[d.seq]->encntr_list, 5)) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "  if (e.encntr_id = xencntr_list->person_list[d.seq]->encntr_list[y]->encntr_id) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "   match_ind = 1 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  if (contrib_system_size > 0) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "   xencntr_list->person_list[d.seq]->encntr_list[y]->dont_use_flag = 0"
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "   xencntr_list->person_list[d.seq]->encntr_list[y]->use_flag = 1"
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  endif "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  endif "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  endfor "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  if(match_ind = 0 and contrib_system_size = 0) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "    encntr_cnt = encntr_cnt + 1 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "    encntr_cnt2 = encntr_cnt + selected_cnt "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "    stat = alterlist(xencntr_list->person_list[d.seq]->encntr_list, encntr_cnt2) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "    xencntr_list->person_list[d.seq].encntr_list[encntr_cnt2].encntr_id = e.encntr_id "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "    xencntr_list->person_list[d.seq]->encntr_list[encntr_cnt2]->use_flag = 1 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "    xencntr_list->person_list[d.seq]->encntr_list[encntr_cnt2]->dont_use_flag = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "    if(lookback_type_ind = 2) "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "      xencntr_list->person_list[d.seq]->encntr_list[encntr_cnt2]->ce_use_flag = 0 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "    else "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement =
  "      xencntr_list->person_list[d.seq]->encntr_list[encntr_cnt2]->ce_use_flag = 1 "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "   endif "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = "  endif "
  SET idx += 1
  SET stat = alterlist(parser_rec->qual,idx)
  SET parser_rec->qual[idx].statement = " WITH nocounter GO "
  FOR (x = 1 TO idx)
    CALL echo(parser_rec->qual[x].statement)
  ENDFOR
  FOR (x = 1 TO idx)
    CALL parser(parser_rec->qual[x].statement)
  ENDFOR
  SET size_providers = 0
  SET size_providers = size(law_providers->qual,5)
  SET pat_count = 0
  SET x_count = 0
  IF (exp_ind=exclude_exp_prov_ind)
   SET exp_prov_parser = "epr.expiration_ind = 0"
  ELSE
   SET exp_prov_parser = "1=1"
  ENDIF
  IF (size_providers > 0)
   SET pat_count = size(xencntr_list->person_list,5)
   SET encntr_r_cnt = 0
   SET person_r_cnt = 0
   SET order_r_cnt = 0
   IF (person_level_cnt > 0)
    FOR (x = 1 TO pat_count)
     SET x_count = size(xencntr_list->person_list[x].encntr_list,5)
     SELECT DISTINCT INTO "nl:"
      e.encntr_id
      FROM person_prsnl_reltn ppr,
       encounter e,
       chart_law_filter_value clfv
      PLAN (clfv
       WHERE clfv.law_id=cross_encntr_law_id
        AND clfv.type_flag=2)
       JOIN (ppr
       WHERE (ppr.person_id=xencntr_list->person_list[x].person_id)
        AND ppr.active_ind=1
        AND ppr.beg_effective_dt_tm <= cnvtdatetime(dist_date)
        AND ppr.end_effective_dt_tm >= cnvtdatetime(dist_date)
        AND ppr.prsnl_person_id=clfv.parent_entity_id
        AND ppr.person_prsnl_r_cd=clfv.reltn_type_cd)
       JOIN (e
       WHERE e.person_id=ppr.person_id)
      ORDER BY e.encntr_id
      HEAD REPORT
       do_nothing = 0
      DETAIL
       person_r_cnt += 1
       IF (person_r_cnt > size(person_reltn_rec->qual,5))
        stat = alterlist(person_reltn_rec->qual,(person_r_cnt+ 9))
       ENDIF
       person_reltn_rec->qual[person_r_cnt].encntr_id = e.encntr_id
      FOOT REPORT
       stat = alterlist(person_reltn_rec->qual,person_r_cnt)
      WITH nocounter
     ;end select
    ENDFOR
   ELSE
    SET message_log = "No Person-level Providers selected for Law."
    CALL update_log(trim(message_log))
   ENDIF
   IF (encntr_level_cnt > 0)
    FOR (x = 1 TO pat_count)
     SET x_count = size(xencntr_list->person_list[x].encntr_list,5)
     SELECT DISTINCT INTO "nl:"
      epr.encntr_id
      FROM encntr_prsnl_reltn epr,
       chart_law_filter_value clfv,
       (dummyt d2  WITH seq = value(x_count))
      PLAN (d2)
       JOIN (clfv
       WHERE clfv.law_id=cross_encntr_law_id
        AND clfv.type_flag=2)
       JOIN (epr
       WHERE (epr.encntr_id=xencntr_list->person_list[x].encntr_list[d2.seq].encntr_id)
        AND epr.active_ind=1
        AND epr.beg_effective_dt_tm <= cnvtdatetime(dist_date)
        AND epr.end_effective_dt_tm >= cnvtdatetime(dist_date)
        AND parser(exp_prov_parser)
        AND epr.prsnl_person_id=clfv.parent_entity_id
        AND epr.encntr_prsnl_r_cd=clfv.reltn_type_cd)
      ORDER BY epr.encntr_id
      HEAD REPORT
       do_nothing = 0
      DETAIL
       encntr_r_cnt += 1
       IF (encntr_r_cnt > size(encntr_reltn_rec->qual,5))
        stat = alterlist(encntr_reltn_rec->qual,encntr_r_cnt)
       ENDIF
       encntr_reltn_rec->qual[encntr_r_cnt].encntr_id = epr.encntr_id
      WITH nocounter
     ;end select
    ENDFOR
   ELSE
    SET message_log = "No Encounter-level Providers selected for Law."
    CALL update_log(trim(message_log))
   ENDIF
   IF (order_level_cnt > 0)
    FOR (x = 1 TO pat_count)
     SET x_count = size(xencntr_list->person_list[x].encntr_list,5)
     SELECT DISTINCT INTO "nl:"
      opr.encntr_id
      FROM order_prsnl_reltn opr,
       chart_law_filter_value clfv,
       (dummyt d3  WITH seq = value(x_count))
      PLAN (d3)
       JOIN (clfv
       WHERE clfv.law_id=cross_encntr_law_id
        AND clfv.type_flag=2)
       JOIN (opr
       WHERE (opr.encntr_id=xencntr_list->person_list[x].encntr_list[d3.seq].encntr_id)
        AND opr.prsnl_person_id=clfv.parent_entity_id
        AND opr.chart_prsnl_r_type_cd=clfv.reltn_type_cd)
      ORDER BY opr.encntr_id
      HEAD REPORT
       do_nothing = 0
      DETAIL
       order_r_cnt += 1, stat = alterlist(order_reltn_rec->qual,order_r_cnt), order_reltn_rec->qual[
       order_r_cnt].encntr_id = opr.encntr_id
      WITH nocounter
     ;end select
    ENDFOR
   ELSE
    SET message_log = "No Order-level Providers selected for Law."
    CALL update_log(trim(message_log))
   ENDIF
  ENDIF
  IF (size_providers > 0)
   SET size_personlist = size(person_reltn_rec->qual,5)
   SET size_encntrlist = size(encntr_reltn_rec->qual,5)
   SET size_orderlist = size(order_reltn_rec->qual,5)
   SET size_xencntr = 0
   SET size_xencntr = size(xencntr_list->person_list,5)
   FOR (x = 1 TO size_xencntr)
     SET size_encntr = 0
     SET size_encntr = size(xencntr_list->person_list[x].encntr_list,5)
     FOR (y = (xencntr_list->person_list[x].selected_cnt+ 1) TO size_encntr)
      SET match_found = 0
      IF (law_prov_include=1)
       FOR (z = 1 TO size_personlist)
         IF ((xencntr_list->person_list[x].encntr_list[y].encntr_id=person_reltn_rec->qual[z].
         encntr_id))
          SET xencntr_list->person_list[x].encntr_list[y].use_flag = 1
          SET xencntr_list->person_list[x].encntr_list[y].dont_use_flag = 0
          SET match_found = 1
         ENDIF
       ENDFOR
       FOR (z = 1 TO size_encntrlist)
         IF ((xencntr_list->person_list[x].encntr_list[y].encntr_id=encntr_reltn_rec->qual[z].
         encntr_id))
          SET xencntr_list->person_list[x].encntr_list[y].use_flag = 1
          SET xencntr_list->person_list[x].encntr_list[y].dont_use_flag = 0
          SET match_found = 1
         ENDIF
       ENDFOR
       FOR (z = 1 TO size_orderlist)
         IF ((xencntr_list->person_list[x].encntr_list[y].encntr_id=order_reltn_rec->qual[z].
         encntr_id))
          SET xencntr_list->person_list[x].encntr_list[y].use_flag = 1
          SET xencntr_list->person_list[x].encntr_list[y].dont_use_flag = 0
          SET match_found = 1
         ENDIF
       ENDFOR
       IF (match_found != 1)
        SET xencntr_list->person_list[x].encntr_list[y].use_flag = 0
       ENDIF
      ELSEIF (law_prov_include=0)
       FOR (z = 1 TO size_personlist)
         IF ((xencntr_list->person_list[x].encntr_list[y].encntr_id=person_reltn_rec->qual[z].
         encntr_id))
          SET xencntr_list->person_list[x].encntr_list[y].dont_use_flag = 1
         ENDIF
       ENDFOR
       FOR (z = 1 TO size_encntrlist)
         IF ((xencntr_list->person_list[x].encntr_list[y].encntr_id=encntr_reltn_rec->qual[z].
         encntr_id))
          SET xencntr_list->person_list[x].encntr_list[y].dont_use_flag = 1
         ENDIF
       ENDFOR
       FOR (z = 1 TO size_orderlist)
         IF ((xencntr_list->person_list[x].encntr_list[y].encntr_id=order_reltn_rec->qual[z].
         encntr_id))
          SET xencntr_list->person_list[x].encntr_list[y].dont_use_flag = 1
         ENDIF
       ENDFOR
      ELSEIF (law_prov_include=99)
       SET do_nothing = 0
      ENDIF
     ENDFOR
   ENDFOR
  ELSE
   SET message_log = "No providers used with law."
   CALL update_log(trim(message_log))
  ENDIF
  CALL echo("after demographics on law into xencntr_list")
  IF (test_ind > 10)
   CALL echorecord(xencntr_list)
  ENDIF
  CALL update_log(build("CE_LOOKBACK = ",datetimezoneformat(ce_lookback_date,curtimezoneapp,
     format_timezone)))
  SET person_cnt = 0
  SET encntr_cnt = 0
  SET max_encntr = 1
  SET person_cnt = size(xencntr_list->person_list,5)
  INSERT  FROM chart_temp ct,
    (dummyt d1  WITH seq = value(person_cnt)),
    (dummyt d2  WITH seq = 1)
   SET ct.seq = 1, ct.person_id = xencntr_list->person_list[d1.seq].person_id, ct.encntr_id =
    xencntr_list->person_list[d1.seq].encntr_list[d2.seq].encntr_id,
    ct.use_ind = xencntr_list->person_list[d1.seq].encntr_list[d2.seq].use_flag, ct.dont_use_ind =
    xencntr_list->person_list[d1.seq].encntr_list[d2.seq].dont_use_flag, ct.lookback_dt_tm =
    cnvtdatetime(ce_lookback_date),
    ct.distribution_id = distr_id
   PLAN (d1
    WHERE maxrec(d2,size(xencntr_list->person_list[d1.seq].encntr_list,5)))
    JOIN (d2)
    JOIN (ct)
   WITH nocounter
  ;end insert
  CALL update_log(build("Total encounters with cross-encounter law = ",curqual))
  SET ce_xencntr = concat(" ce.encntr_id = ct.encntr_id and "," ce.person_id = ct.person_id and ",
   " ce.clinsig_updt_dt_tm >= cnvtdatetime(ce_lookback_date) and ",
   " ce.valid_until_dt_tm >= cnvtdatetime('31-dec-2100') and ",
   " ct.use_ind = 1 and ct.dont_use_ind = 0 and ",
   " ce.event_class_cd != placeholder_class_cd and "," ce.record_status_cd != del_stat_cd ")
  SET ce_xencntr_clause = concat(trim(ce_xencntr)," ",trim(ce_pending))
  CALL echo(build("ce_xencntr_clause => ",ce_xencntr_clause))
  DECLARE format_clause_xencntr = vc
  SET format_clause_xencntr = concat("cat.distribution_id = ct.distribution_id AND ",
   " cat.event_cd = ce.event_cd AND cat.procedure_type_flag = 0 AND cat.event_cd > 0.0")
  SET format_check_xencntr = concat(format_check_clause,")")
  SET final_ce_xclause = concat(trim(format_clause_xencntr)," ",trim(format_check_xencntr))
  CALL echo(build("final_ce_Xclause => ",final_ce_xclause))
  FREE RECORD chart_temp_xencntr
  RECORD chart_temp_xencntr(
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 latest_clinsig_updt_dt_tm = dq8
  )
  SELECT INTO "nl:"
   FROM chart_temp ct,
    clinical_event ce,
    chart_activity_temp cat
   PLAN (ct
    WHERE ct.distribution_id=distr_id)
    JOIN (ce
    WHERE parser(ce_xencntr_clause))
    JOIN (cat
    WHERE parser(final_ce_xclause))
   ORDER BY ce.encntr_id, ce.clinsig_updt_dt_tm DESC
   HEAD REPORT
    lcount = 0
   HEAD ce.encntr_id
    lcount += 1
    IF (mod(lcount,10)=1)
     stat = alterlist(chart_temp_xencntr->qual,(lcount+ 9))
    ENDIF
    chart_temp_xencntr->qual[lcount].person_id = ct.person_id, chart_temp_xencntr->qual[lcount].
    encntr_id = ct.encntr_id, chart_temp_xencntr->qual[lcount].latest_clinsig_updt_dt_tm = ce
    .clinsig_updt_dt_tm
   FOOT REPORT
    stat = alterlist(chart_temp_xencntr->qual,lcount)
   WITH nocounter, orahintcbo("LEADING(CT,CAT) INDEX(CE XIE24CLINICAL_EVENT)")
  ;end select
  IF (test_ind > 10)
   CALL echorecord(chart_temp_xencntr)
  ENDIF
  SET xencntr_cnt = size(chart_temp_xencntr->qual,5)
  SELECT INTO "nl:"
   person_id = chart_temp_xencntr->qual[d.seq].person_id, encntr_id = chart_temp_xencntr->qual[d.seq]
   .encntr_id, clinsig_updt_dt_tm = chart_temp_xencntr->qual[d.seq].latest_clinsig_updt_dt_tm
   FROM (dummyt d  WITH seq = value(xencntr_cnt))
   PLAN (d)
   ORDER BY person_id, clinsig_updt_dt_tm DESC
   HEAD REPORT
    personnbr = size(xencntr_list->person_list,5)
   HEAD person_id
    pidx = 0, personidx = locatevalsort(pidx,1,personnbr,person_id,xencntr_list->person_list[pidx].
     person_id), xencntr_list->person_list[personidx].latest_clinsig_updt_dt_tm = clinsig_updt_dt_tm,
    encntrnbr = size(xencntr_list->person_list[personidx].encntr_list,5)
   DETAIL
    eidx = 0, encntridx = locateval(eidx,1,encntrnbr,encntr_id,xencntr_list->person_list[personidx].
     encntr_list[eidx].encntr_id), xencntr_list->person_list[personidx].encntr_list[encntridx].
    ce_use_flag = 1
   FOOT REPORT
    donothing = 0
   WITH nocounter
  ;end select
  SET cs_where_clause = "1=1"
  SET cs_where_clause2 = "1=1"
  IF (has_micro_section)
   SET stat = initrec(mbo_flat_rec)
   CALL validatemicrobiologyevents(1)
  ENDIF
  IF (has_rad_section)
   CALL validateradiologyevents(1)
  ENDIF
  IF (has_cardio_section)
   CALL validatecardiologyevents(1)
  ENDIF
  CALL echo("after populating the latest clinsig update date/time into xencntr_list")
  IF (test_ind > 10)
   CALL echorecord(xencntr_list)
  ENDIF
  FREE RECORD chart_temp_xencntr
 ELSEIF (scope=5
  AND cross_encntr_law_id=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ERROR! - Using Cross-encounter with no law, Exiting Job."
  SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
  CALL update_log(trim(message_log))
  GO TO exit_script
 ELSEIF (scope=1)
  SET message_log = "Person-level scope"
  CALL update_log(trim(message_log))
 ENDIF
 SET req_cnt = 0
 SET req_cnt = size(prelim_rec1->qual,5)
 IF (req_cnt > 0)
  FREE RECORD final_rec
  RECORD final_rec(
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_nbr = c20
      2 event_id = f8
      2 date_range_ind = i2
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 output_dest_cd = f8
      2 output_device_cd = f8
      2 prsnl_person_id = f8
      2 prsnl_person_r_cd = f8
      2 nurse_unit_cv = f8
      2 org = vc
      2 display = c40
      2 mrnt = c9
      2 name = vc
      2 room = c40
      2 bed = c40
      2 mrn = c30
      2 fac = c40
      2 prov_name = vc
      2 zipcode = c25
      2 prsnl_reltn_id = f8
      2 seq_nbr = i4
      2 patient_zipcode = c25
      2 location_cd = f8
      2 seq_grp_id = f8
      2 xr_dist_seq = i4
      2 non_ce_begin_dt_tm = dq8
      2 dms_service_ident = vc
  )
  SET idx = 0
  SET idxstart = 1
  SET nrecordsize = size(prelim_rec1->qual,5)
  SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ big_bind_cnt)) * big_bind_cnt)
  SET stat = alterlist(prelim_rec1->qual,noptimizedtotal)
  FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
    SET prelim_rec1->qual[i].encntr_id = prelim_rec1->qual[nrecordsize].encntr_id
  ENDFOR
  SELECT DISTINCT INTO "nl:"
   combination =
   IF (scope IN (1, 5)) build(prelim_rec1->qual[d.seq].person_id,prelim_rec1->qual[d.seq].
     output_dest_cd,prelim_rec1->qual[d.seq].prsnl_person_id,prelim_rec1->qual[d.seq].prsnl_reltn_id,
     trim(prelim_rec1->qual[d.seq].dms_service_ident))
   ELSEIF (scope=2) build(prelim_rec1->qual[d.seq].encntr_id,prelim_rec1->qual[d.seq].output_dest_cd,
     prelim_rec1->qual[d.seq].prsnl_person_id,prelim_rec1->qual[d.seq].prsnl_reltn_id,trim(
      prelim_rec1->qual[d.seq].dms_service_ident))
   ELSEIF (scope=4) build(prelim_rec1->qual[d.seq].accession_nbr,prelim_rec1->qual[d.seq].
     output_dest_cd,prelim_rec1->qual[d.seq].prsnl_person_id,prelim_rec1->qual[d.seq].prsnl_reltn_id,
     trim(prelim_rec1->qual[d.seq].dms_service_ident))
   ELSEIF (scope=6) build(prelim_rec1->qual[d.seq].event_id,prelim_rec1->qual[d.seq].output_dest_cd,
     prelim_rec1->qual[d.seq].prsnl_person_id,prelim_rec1->qual[d.seq].prsnl_reltn_id,trim(
      prelim_rec1->qual[d.seq].dms_service_ident))
   ENDIF
   FROM (dummyt d  WITH seq = value(req_cnt))
   PLAN (d)
   ORDER BY combination
   HEAD REPORT
    r_cnt = 0, xencntrpersonnbr = size(xencntr_list->person_list,5)
   HEAD combination
    r_cnt += 1
    IF (r_cnt > size(final_rec->qual,5))
     stat = alterlist(final_rec->qual,(r_cnt+ 9))
    ENDIF
    final_rec->qual[r_cnt].person_id = prelim_rec1->qual[d.seq].person_id, final_rec->qual[r_cnt].
    encntr_id = prelim_rec1->qual[d.seq].encntr_id, final_rec->qual[r_cnt].order_id = prelim_rec1->
    qual[d.seq].order_id,
    final_rec->qual[r_cnt].accession_nbr =
    IF (scope=4) prelim_rec1->qual[d.seq].accession_nbr
    ELSE " "
    ENDIF
    , final_rec->qual[r_cnt].event_id = prelim_rec1->qual[d.seq].event_id, final_rec->qual[r_cnt].
    date_range_ind = prelim_rec1->qual[d.seq].date_range_ind,
    final_rec->qual[r_cnt].begin_dt_tm = prelim_rec1->qual[d.seq].begin_dt_tm, final_rec->qual[r_cnt]
    .output_dest_cd = prelim_rec1->qual[d.seq].output_dest_cd, final_rec->qual[r_cnt].
    output_device_cd = prelim_rec1->qual[d.seq].output_device_cd,
    final_rec->qual[r_cnt].prsnl_person_id = prelim_rec1->qual[d.seq].prsnl_person_id, final_rec->
    qual[r_cnt].prsnl_person_r_cd = prelim_rec1->qual[d.seq].prsnl_person_r_cd, final_rec->qual[r_cnt
    ].nurse_unit_cv = prelim_rec1->qual[d.seq].nurse_unit_cv,
    final_rec->qual[r_cnt].org = prelim_rec1->qual[d.seq].org, final_rec->qual[r_cnt].display =
    prelim_rec1->qual[d.seq].display, final_rec->qual[r_cnt].mrnt = prelim_rec1->qual[d.seq].mrnt,
    final_rec->qual[r_cnt].name = prelim_rec1->qual[d.seq].name, final_rec->qual[r_cnt].room =
    prelim_rec1->qual[d.seq].room, final_rec->qual[r_cnt].bed = prelim_rec1->qual[d.seq].bed,
    final_rec->qual[r_cnt].mrn = prelim_rec1->qual[d.seq].mrn, final_rec->qual[r_cnt].fac =
    prelim_rec1->qual[d.seq].fac, final_rec->qual[r_cnt].prov_name = prelim_rec1->qual[d.seq].
    prov_name,
    final_rec->qual[r_cnt].prsnl_reltn_id = prelim_rec1->qual[d.seq].prsnl_reltn_id, final_rec->qual[
    r_cnt].dms_service_ident = trim(prelim_rec1->qual[d.seq].dms_service_ident), final_rec->qual[
    r_cnt].non_ce_begin_dt_tm = prelim_rec1->qual[d.seq].non_ce_begin_dt_tm,
    latest_clinsig_updt_dt_tm = cnvtdatetime("01-jan-1800")
    IF (scope=1)
     idx = 0, personindex = locateval(idx,1,distinct_cnt,final_rec->qual[r_cnt].person_id,
      distinct_cp_encntr->encntr_list[idx].person_id), latest_clinsig_updt_dt_tm = distinct_cp_encntr
     ->encntr_list[personindex].latest_clinsig_updt_dt_tm
     WHILE (personindex > 0)
       startindex = (personindex+ 1), personindex = locateval(idx,startindex,distinct_cnt,final_rec->
        qual[r_cnt].person_id,distinct_cp_encntr->encntr_list[idx].person_id)
       IF (personindex > 0
        AND (distinct_cp_encntr->encntr_list[personindex].latest_clinsig_updt_dt_tm >
       latest_clinsig_updt_dt_tm))
        latest_clinsig_updt_dt_tm = distinct_cp_encntr->encntr_list[personindex].
        latest_clinsig_updt_dt_tm
       ENDIF
     ENDWHILE
     final_rec->qual[r_cnt].end_dt_tm = latest_clinsig_updt_dt_tm
    ELSEIF (scope=5)
     idx = 0, personidx = locateval(idx,1,xencntrpersonnbr,final_rec->qual[r_cnt].person_id,
      xencntr_list->person_list[idx].person_id), final_rec->qual[r_cnt].end_dt_tm = xencntr_list->
     person_list[personidx].latest_clinsig_updt_dt_tm
    ELSE
     idx = 0, encntrindex = locateval(idx,1,distinct_cnt,final_rec->qual[r_cnt].encntr_id,
      distinct_cp_encntr->encntr_list[idx].encntr_id), final_rec->qual[r_cnt].end_dt_tm =
     distinct_cp_encntr->encntr_list[encntrindex].latest_clinsig_updt_dt_tm
    ENDIF
   FOOT  combination
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(final_rec->qual,r_cnt)
   WITH nocounter
  ;end select
  FREE RECORD prelim_rec1
 ELSE
  SET reply->status_data.status = "Z"
  SET message_log = "INFO! - Req_cnt = 0, Exiting Job."
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 SET nbr_to_add = 0
 SET nbr_to_add = size(final_rec->qual,5)
 SET sel_count = 0
 IF (req_cnt > 0)
  IF (sort_seq=18)
   SET rec_cnt = size(final_rec->qual,5)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(rec_cnt)),
     address a
    PLAN (d1)
     JOIN (a
     WHERE (a.parent_entity_id=final_rec->qual[d1.seq].prsnl_person_id)
      AND a.address_type_cd=dbusinesscd
      AND a.parent_entity_name IN ("PRSNL", "PERSON"))
    ORDER BY d1.seq, a.address_type_seq
    HEAD REPORT
     do_nothing = 0
    HEAD d1.seq
     cnt = 1
    DETAIL
     IF (cnt=1
      AND size(trim(a.zipcode,3)) > 0)
      final_rec->qual[d1.seq].zipcode = a.zipcode
     ENDIF
     cnt += 1
    FOOT  d1.seq
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH nocounter
   ;end select
  ENDIF
  IF (sort_seq=19)
   SET rec_cnt = size(final_rec->qual,5)
   SELECT INTO "nl:"
    FROM chart_sequence_group csg,
     chart_seq_group_reltn csgr,
     (dummyt d1  WITH seq = value(rec_cnt))
    PLAN (csg
     WHERE csg.chart_route_id=chart_route_id)
     JOIN (csgr
     WHERE csgr.sequence_group_id=csg.sequence_group_id)
     JOIN (d1
     WHERE (csgr.prsnl_id=final_rec->qual[d1.seq].prsnl_person_id)
      AND (final_rec->qual[d1.seq].prsnl_person_id > 0))
    ORDER BY csg.sequence_nbr, csgr.sequence_nbr
    HEAD REPORT
     x = 0
    HEAD csg.sequence_nbr
     donothing = 0
    HEAD csgr.sequence_nbr
     x += 1
    DETAIL
     final_rec->qual[d1.seq].seq_nbr = x, final_rec->qual[d1.seq].seq_grp_id = csg.sequence_group_id
    FOOT  csgr.sequence_nbr
     donothing = 0
    FOOT  csg.sequence_nbr
     donothing = 0
    FOOT REPORT
     max_seq_nbr = x
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(rec_cnt)),
     prsnl p
    PLAN (d1
     WHERE (final_rec->qual[d1.seq].seq_nbr=0))
     JOIN (p
     WHERE (p.person_id=final_rec->qual[d1.seq].prsnl_person_id))
    ORDER BY p.name_last_key, p.name_first_key
    HEAD REPORT
     prsnl_seq_cnt = 0
    DETAIL
     prsnl_seq_cnt += 1, final_rec->qual[d1.seq].seq_nbr = (max_seq_nbr+ prsnl_seq_cnt)
    WITH nocounter
   ;end select
  ENDIF
  IF (sort_seq=22)
   SET rec_cnt = size(final_rec->qual,5)
   IF (rec_cnt > 0)
    SELECT INTO "nl:"
     address_type = uar_get_code_meaning(a.address_type_cd), a.zipcode
     FROM (dummyt d1  WITH seq = value(rec_cnt)),
      address a
     PLAN (d1)
      JOIN (a
      WHERE (a.parent_entity_id=final_rec->qual[d1.seq].person_id)
       AND a.parent_entity_name="PERSON"
       AND a.address_type_cd=dhomecd
       AND a.zipcode != null
       AND a.active_ind=1
       AND a.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
     ORDER BY d1.seq, a.address_type_seq
     HEAD d1.seq
      IF (size(trim(a.zipcode,3)) > 0)
       final_rec->qual[d1.seq].patient_zipcode = trim(a.zipcode,3)
      ENDIF
     DETAIL
      donothing = 0
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  IF (sort_seq=23)
   FREE RECORD temp_request
   RECORD temp_request(
     1 qual[*]
       2 prsnl_person_id = f8
       2 encntr_id = f8
       2 order_id = f8
       2 accession_nbr = c20
     1 route_type_flag = i2
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 qual[*]
       2 encntr_id = f8
       2 order_id = f8
       2 accession_nbr = c20
       2 prsnl_id = f8
       2 prsnl_reltn[*]
         3 prsnl_reltn_id = f8
         3 organization_id = f8
         3 output_dest_cd = f8
         3 output_device_cd = f8
         3 output_dest_name = vc
         3 device_name = vc
         3 location_cd = f8
         3 dms_service_ident = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   IF (scope IN (2, 4))
    SET stat = alterlist(temp_request->qual,value(size(final_rec->qual,5)))
    FOR (i = 1 TO size(final_rec->qual,5))
      SET temp_request->qual[i].prsnl_person_id = final_rec->qual[i].prsnl_person_id
      SET temp_request->qual[i].encntr_id = final_rec->qual[i].encntr_id
      IF (scope=4)
       SET temp_request->qual[i].accession_nbr = final_rec->qual[i].accession_nbr
       SET temp_request->qual[i].order_id = final_rec->qual[i].order_id
      ENDIF
    ENDFOR
    SET temp_request->route_type_flag = drt_criteria
    EXECUTE cp_get_chart_prsnl_dest  WITH replace(request,temp_request), replace(reply,temp_reply)
    IF ((temp_reply->status_data.status="Z"))
     SET message_log = "INFO! - No provider has chart destination defined. "
     CALL update_log(trim(message_log))
    ELSEIF ((temp_reply->status_data.status="F"))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Failed to execute cp_get_chart_prsnl_dest to finde location sequence, Exiting Job."
     SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
     CALL update_log(trim(message_log))
     GO TO exit_script
    ENDIF
   ENDIF
   SET x = size(final_rec->qual,5)
   SET y = x
   FOR (i = 1 TO size(temp_reply->qual,5))
     FOR (j = 1 TO x)
       IF ((((final_rec->qual[j].prsnl_person_id=temp_reply->qual[i].prsnl_id)
        AND (final_rec->qual[j].encntr_id=temp_reply->qual[i].encntr_id)
        AND (final_rec->qual[j].order_id=0)) OR ((final_rec->qual[j].prsnl_person_id=temp_reply->
       qual[i].prsnl_id)
        AND (final_rec->qual[j].accession_nbr=temp_reply->qual[i].accession_nbr)
        AND (final_rec->qual[j].order_id=temp_reply->qual[i].order_id)
        AND (final_rec->qual[j].order_id > 0))) )
        FOR (k = 1 TO size(temp_reply->qual[i].prsnl_reltn,5))
          IF ((temp_reply->qual[i].prsnl_reltn[k].organization_id < 1))
           IF (k=1)
            SET final_rec->qual[j].location_cd = temp_reply->qual[i].prsnl_reltn[k].location_cd
           ELSE
            SET y += 1
            IF (y > size(final_rec->qual,5))
             SET stat = alterlist(final_rec->qual,(y+ 5))
            ENDIF
            SET final_rec->qual[y].person_id = final_rec->qual[j].person_id
            SET final_rec->qual[y].encntr_id = final_rec->qual[j].encntr_id
            SET final_rec->qual[y].order_id = final_rec->qual[j].order_id
            SET final_rec->qual[y].accession_nbr = final_rec->qual[j].accession_nbr
            SET final_rec->qual[y].event_id = final_rec->qual[j].event_id
            SET final_rec->qual[y].date_range_ind = final_rec->qual[j].date_range_ind
            SET final_rec->qual[y].begin_dt_tm = final_rec->qual[j].begin_dt_tm
            SET final_rec->qual[y].end_dt_tm = final_rec->qual[j].end_dt_tm
            SET final_rec->qual[y].output_dest_cd = final_rec->qual[j].output_dest_cd
            SET final_rec->qual[y].output_device_cd = final_rec->qual[j].output_device_cd
            SET final_rec->qual[y].prsnl_person_id = final_rec->qual[j].prsnl_person_id
            SET final_rec->qual[y].prsnl_person_r_cd = final_rec->qual[j].prsnl_person_r_cd
            SET final_rec->qual[y].nurse_unit_cv = final_rec->qual[j].nurse_unit_cv
            SET final_rec->qual[y].org = final_rec->qual[j].org
            SET final_rec->qual[y].display = final_rec->qual[j].display
            SET final_rec->qual[y].mrnt = final_rec->qual[j].mrnt
            SET final_rec->qual[y].name = final_rec->qual[j].name
            SET final_rec->qual[y].room = final_rec->qual[j].room
            SET final_rec->qual[y].bed = final_rec->qual[j].bed
            SET final_rec->qual[y].mrn = final_rec->qual[j].mrn
            SET final_rec->qual[y].fac = final_rec->qual[j].fac
            SET final_rec->qual[y].prov_name = final_rec->qual[j].prov_name
            SET final_rec->qual[y].zipcode = final_rec->qual[j].zipcode
            SET final_rec->qual[y].prsnl_reltn_id = final_rec->qual[j].prsnl_reltn_id
            SET final_rec->qual[y].seq_nbr = final_rec->qual[j].seq_nbr
            SET final_rec->qual[y].patient_zipcode = final_rec->qual[j].patient_zipcode
            SET final_rec->qual[y].location_cd = final_rec->qual[j].location_cd
            SET final_rec->qual[y].seq_grp_id = final_rec->qual[j].seq_grp_id
            SET final_rec->qual[y].non_ce_begin_dt_tm = final_rec->qual[j].non_ce_begin_dt_tm
            SET final_rec->qual[y].dms_service_ident = trim(final_rec->qual[j].dms_service_ident)
            SET final_rec->qual[y].location_cd = temp_reply->qual[i].prsnl_reltn[k].location_cd
           ENDIF
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(final_rec->qual,y)
   FREE RECORD temp_location_seq
   RECORD temp_location_seq(
     1 qual[*]
       2 location_cd = f8
       2 seq_nbr = i4
       2 seq_grp_id = f8
   )
   SELECT INTO "nl:"
    FROM chart_sequence_group csg,
     chart_seq_group_reltn csgr
    PLAN (csg
     WHERE csg.chart_route_id=chart_route_id)
     JOIN (csgr
     WHERE csgr.sequence_group_id=csg.sequence_group_id)
    ORDER BY csg.sequence_nbr, csgr.sequence_nbr
    HEAD REPORT
     x = 0, lcount = 0
    HEAD csg.sequence_nbr
     donothing = 0
    HEAD csgr.sequence_nbr
     x += 1
    DETAIL
     lcount += 1
     IF (lcount > size(temp_location_seq->qual,5))
      stat = alterlist(temp_location_seq->qual,(lcount+ 10))
     ENDIF
     temp_location_seq->qual[lcount].location_cd = csgr.location_cd, temp_location_seq->qual[lcount].
     seq_grp_id = csgr.sequence_group_id, temp_location_seq->qual[lcount].seq_nbr = x
    FOOT  csgr.sequence_nbr
     donothing = 0
    FOOT  csg.sequence_nbr
     donothing = 0
    FOOT REPORT
     max_seq_nbr = x, stat = alterlist(temp_location_seq->qual,lcount)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(final_rec->qual,5))),
     (dummyt d2  WITH seq = value(size(temp_location_seq->qual,5)))
    PLAN (d1)
     JOIN (d2
     WHERE (final_rec->qual[d1.seq].location_cd=temp_location_seq->qual[d2.seq].location_cd))
    DETAIL
     final_rec->qual[d1.seq].seq_nbr = temp_location_seq->qual[d2.seq].seq_nbr, final_rec->qual[d1
     .seq].seq_grp_id = temp_location_seq->qual[d2.seq].seq_grp_id
    WITH nocounter
   ;end select
   FREE RECORD temp_request2
   RECORD temp_request2(
     1 locations[1]
       2 location_cd = f8
     1 skip_org_security_ind = i2
   )
   FREE RECORD temp_reply2
   RECORD temp_reply2(
     1 facilities[*]
       2 facility_cd = f8
       2 facility_disp = c40
       2 facility_desc = c60
       2 buildings[*]
         3 building_cd = f8
         3 building_disp = c40
         3 building_desc = c60
         3 units[*]
           4 unit_cd = f8
           4 unit_disp = c40
           4 unit_desc = c60
           4 rooms[*]
             5 room_cd = f8
             5 room_disp = c40
             5 room_desc = c60
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FOR (i = 1 TO size(final_rec->qual,5))
    IF ((final_rec->qual[i].seq_nbr=0)
     AND (final_rec->qual[i].location_cd > 0))
     SET temp_request2->locations[1].location_cd = final_rec->qual[i].location_cd
     SET temp_request2->skip_org_security_ind = 1
     EXECUTE dcp_get_loc_parent_hierarchy  WITH replace(request,temp_request2), replace(reply,
      temp_reply2)
     IF ((temp_reply->status_data.status="Z"))
      SET message_log = "INFO! - dcp_get_loc_parent_hierarchy did not return any parents. "
      CALL update_log(trim(message_log))
     ELSEIF ((temp_reply->status_data.status="F"))
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Failed to execute dcp_get_loc_parent_hierarchy, Exiting Job."
      SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
      CALL update_log(trim(message_log))
      GO TO exit_script
     ENDIF
     IF (size(temp_reply2->facilities[1].buildings[1].units[1].rooms,5) > 0)
      SET found = compare_location(temp_reply2->facilities[1].buildings[1].units[1].rooms[1].room_cd,
       i)
     ENDIF
     IF (size(temp_reply2->facilities[1].buildings[1].units,5) > 0
      AND found=0)
      SET found = compare_location(temp_reply2->facilities[1].buildings[1].units[1].unit_cd,i)
     ENDIF
     IF (size(temp_reply2->facilities[1].buildings,5) > 0
      AND found=0)
      SET found = compare_location(temp_reply2->facilities[1].buildings[1].building_cd,i)
     ENDIF
     IF (size(temp_reply2->facilities,5) > 0
      AND found=0)
      SET found = compare_location(temp_reply2->facilities[1].facility_cd,i)
     ENDIF
     IF (found=0)
      SET final_rec->qual[i].seq_nbr = (max_seq_nbr+ 1)
      SET final_rec->qual[i].location_cd = 0
      SET final_rec->qual[i].seq_grp_id = 0
     ENDIF
    ENDIF
    SET found = 0
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(final_rec->qual,5)))
    WHERE (final_rec->qual[d.seq].seq_nbr=0)
    DETAIL
     final_rec->qual[d.seq].seq_nbr = (max_seq_nbr+ 1), final_rec->qual[d.seq].location_cd = 0,
     final_rec->qual[d.seq].seq_grp_id = 0
    WITH nocounter
   ;end select
   SUBROUTINE (compare_location(location_cd=f8,count=i4) =i2)
     SET found_location = 0
     FOR (j = 1 TO size(temp_location_seq->qual,5))
       IF ((temp_location_seq->qual[j].location_cd=location_cd))
        SET final_rec->qual[count].seq_nbr = temp_location_seq->qual[j].seq_nbr
        SET final_rec->qual[count].location_cd = temp_location_seq->qual[j].location_cd
        SET final_rec->qual[count].seq_grp_id = temp_location_seq->qual[j].seq_grp_id
        SET found_location = 1
        SET j = (size(temp_location_seq->qual,5)+ 1)
       ENDIF
     ENDFOR
     RETURN(found_location)
   END ;Subroutine
   FREE RECORD temp_reply
   FREE RECORD temp_request
   FREE RECORD temp_reply2
   FREE RECORD temp_request2
   FREE RECORD temp_location_sequence
   SET nbr_to_add = size(final_rec->qual,5)
  ENDIF
  FREE RECORD sort_param
  RECORD sort_param(
    1 qual[5]
      2 name = vc
  )
  SET sort_param->qual[1].name = "0"
  SET sort_param->qual[2].name = "0"
  SET sort_param->qual[3].name = "0"
  SET sort_param->qual[4].name = "0"
  SET sort_param->qual[5].name = "0"
  IF (sort_seq=0)
   SET sort_param->qual[1].name = "prov_name"
   SET sort_param->qual[2].name = "name"
   SET sort_param->qual[3].name = "encntr_id"
  ELSEIF (sort_seq=1)
   SET sort_param->qual[1].name = "prsnl_person_id"
   SET sort_param->qual[2].name = "name"
   SET sort_param->qual[3].name = "encntr_id"
  ELSEIF (sort_seq IN (2, 13, 14))
   SET sort_param->qual[1].name = "fac"
   SET sort_param->qual[2].name = "mrnt"
   SET sort_param->qual[3].name = "encntr_id"
  ELSEIF (sort_seq=3)
   SET sort_param->qual[1].name = "nurse_unit_cv"
   SET sort_param->qual[2].name = "room"
   SET sort_param->qual[3].name = "bed"
   SET sort_param->qual[4].name = "mrn"
   SET sort_param->qual[5].name = "encntr_id"
  ELSEIF (sort_seq=4)
   SET sort_param->qual[1].name = "name"
   SET sort_param->qual[2].name = "encntr_id"
  ELSEIF (sort_seq=5)
   SET sort_param->qual[1].name = "display"
   SET sort_param->qual[2].name = "name"
   SET sort_param->qual[3].name = "encntr_id"
  ELSEIF (sort_seq IN (6, 10, 11))
   SET sort_param->qual[1].name = "display"
   SET sort_param->qual[2].name = "mrnt"
   SET sort_param->qual[3].name = "encntr_id"
  ELSEIF (sort_seq=7
   AND scope=4)
   SET sort_param->qual[1].name = "accession_nbr"
   SET sort_param->qual[2].name = "prsnl_person_id"
   SET sort_param->qual[3].name = "prsnl_person_r_cd"
  ELSEIF (sort_seq=7
   AND scope IN (1, 2, 5, 6))
   SET sort_param->qual[1].name = "encntr_id"
   SET sort_param->qual[2].name = "prsnl_person_id"
   SET sort_param->qual[3].name = "prsnl_person_r_cd"
  ELSEIF (sort_seq=8)
   SET sort_param->qual[1].name = "org"
   SET sort_param->qual[2].name = "prov_name"
   SET sort_param->qual[3].name = "name"
   SET sort_param->qual[4].name = "encntr_id"
  ELSEIF (sort_seq=9)
   SET sort_param->qual[1].name = "nurse_unit_cv"
   SET sort_param->qual[2].name = "prov_name"
   SET sort_param->qual[3].name = "name"
   SET sort_param->qual[4].name = "encntr_id"
  ELSEIF (sort_seq IN (16, 17))
   SET sort_param->qual[1].name = "mrnt"
   SET sort_param->qual[2].name = "encntr_id"
  ELSEIF (sort_seq=18)
   SET sort_param->qual[1].name = "zip_code"
   SET sort_param->qual[2].name = "prov_name"
   SET sort_param->qual[3].name = "name"
  ELSEIF (sort_seq=19)
   SET sort_param->qual[1].name = "seq_nbr"
   SET sort_param->qual[2].name = "name"
  ELSEIF (sort_seq=22)
   SET sort_param->qual[1].name = "patient_zipcode"
  ELSEIF (sort_seq=23)
   SET sort_param->qual[1].name = "seq_nbr"
   SET sort_param->qual[2].name = "prov_name"
   SET sort_param->qual[3].name = "name"
  ENDIF
  SELECT INTO "nl:"
   person_id = final_rec->qual[d1.seq].person_id, encntr_id = final_rec->qual[d1.seq].encntr_id,
   accession_nbr =
   IF ((final_rec->qual[d1.seq].accession_nbr > " ")) final_rec->qual[d1.seq].accession_nbr
   ELSE null
   ENDIF
   ,
   nurse_unit_cv = final_rec->qual[d1.seq].nurse_unit_cv, org = substring(1,100,final_rec->qual[d1
    .seq].org), display = final_rec->qual[d1.seq].display,
   mrnt = final_rec->qual[d1.seq].mrnt, name = substring(1,202,final_rec->qual[d1.seq].name), room =
   final_rec->qual[d1.seq].room,
   bed = final_rec->qual[d1.seq].bed, mrn = final_rec->qual[d1.seq].mrn, fac = final_rec->qual[d1.seq
   ].fac,
   prsnl_person_id = final_rec->qual[d1.seq].prsnl_person_id, prsnl_person_r_cd = final_rec->qual[d1
   .seq].prsnl_person_r_cd, prov_name = substring(1,202,final_rec->qual[d1.seq].prov_name),
   zip_code = final_rec->qual[d1.seq].zipcode, seq_nbr = final_rec->qual[d1.seq].seq_nbr,
   patient_zipcode = final_rec->qual[d1.seq].patient_zipcode
   FROM (dummyt d1  WITH seq = value(nbr_to_add))
   ORDER BY parser(sort_param->qual[1].name), parser(sort_param->qual[2].name), parser(sort_param->
     qual[3].name),
    parser(sort_param->qual[4].name), parser(sort_param->qual[5].name)
   HEAD REPORT
    req_cnt = 0
   DETAIL
    req_cnt += 1, final_rec->qual[d1.seq].xr_dist_seq = req_cnt
   FOOT REPORT
    do_nothing = 0
   WITH nocounter
  ;end select
  DECLARE xr_file_mask = vc WITH noconstant(file_mask)
  IF (size(trim(file_mask,3)) > 0)
   CALL echo(concat("Original mask ",xr_file_mask))
   SET xr_file_mask = replace(xr_file_mask,"<AdmitDate>","<registration-dt>",0)
   SET xr_file_mask = replace(xr_file_mask,"<DischargeDate>","<discharge-dt>",0)
   SET xr_file_mask = replace(xr_file_mask,"<SocialSecurityNumber>","<patient-ssn>",0)
   SET xr_file_mask = replace(xr_file_mask,"<FacilityDisp>","<facility-display>",0)
   SET xr_file_mask = replace(xr_file_mask,"<BuildingDisp>","<building-display>",0)
   SET xr_file_mask = replace(xr_file_mask,"<VisitID>","<visit-id>",0)
   SET xr_file_mask = replace(xr_file_mask,"<FinancialNumber>","<financial-number>",0)
   SET xr_file_mask = replace(xr_file_mask,"<PatientName>","<patient-name>",0)
   SET xr_file_mask = replace(xr_file_mask,"<Sex>","<patient-sex>",0)
   SET xr_file_mask = replace(xr_file_mask,"<Birthdate>","<patient-birth-dt>",0)
   SET xr_file_mask = replace(xr_file_mask,"<DocServiceDate>","<doc-service-dt>",0)
   SET xr_file_mask = replace(xr_file_mask,"<DocumentType>","<document-type>",0)
   SET xr_file_mask = replace(xr_file_mask,"<MedicalRecordNumber>","<mrn>",0)
   SET xr_file_mask = replace(xr_file_mask,"<CommunityMedicalRecordNumber>","<patient-cmrn>",0)
   SET xr_file_mask = replace(xr_file_mask,"<AccessionNumber>","<accession-number>",0)
   SET xr_file_mask = replace(xr_file_mask,"<ChartProvider>","<receiving-provider>",0)
   SET xr_file_mask = replace(xr_file_mask,"<DistributionName>","<distribution-name>",0)
   CALL echo(concat("Finished XR mask ",xr_file_mask))
  ENDIF
  FREE RECORD report_request
  RECORD report_request(
    1 requests[*]
      2 request_type_flag = i2
      2 scope_flag = i2
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 person_id = f8
      2 encntr_id = f8
      2 xencntr_ids[*]
        3 encntr_id = f8
      2 event_ids[*]
        3 event_id = f8
      2 accession_nbr = c20
      2 order_id = f8
      2 request_prsnl_id = f8
      2 provider_prsnl_id = f8
      2 provider_reltn_cd = f8
      2 template_id = f8
      2 distribution_id = f8
      2 dist_run_type_cd = f8
      2 dist_run_dt_tm = dq8
      2 dist_seq = i4
      2 reader_group = c15
      2 route_id = f8
      2 route_stop_id = f8
      2 output_dest_cd = f8
      2 trigger_name = c100
      2 eso_trigger_id = f8
      2 eso_trigger_type = c15
      2 result_status_flag = i2
      2 use_posting_date_flag = i2
      2 user_role_profile = vc
      2 section_ids[*]
        3 section_id = f8
      2 sequence_nbr = i4
      2 dms_service_ident = vc
      2 copies_nbr = i4
      2 fax_distribute_dt_tm = dq8
      2 adhoc_fax_number = vc
      2 output_content_type = vc
      2 template_version_mode_flag = i2
      2 template_version_dt_tm = dq8
      2 prsnl_reltn_id = f8
      2 output_content_type_cd = f8
      2 file_mask = vc
      2 file_name = vc
      2 output_destinations[*]
        3 output_dest_cd = f8
        3 dms_service_ident = vc
        3 dms_fax_distribute_dt_tm = dq8
        3 dms_adhoc_fax_number = vc
        3 copies_nbr = i4
      2 non_ce_begin_dt_tm = dq8
      2 non_ce_end_dt_tm = dq8
      2 contact_info = vc
      2 custodial_org_id = f8
      2 sender_email = vc
      2 external_content_ident = vc
      2 external_content_name = vc
      2 prsnl_role_profile_uid = vc
    1 test_ind = i2
    1 requesting_locale = c5
    1 print_ind = i2
  )
  FREE RECORD report_reply
  RECORD report_reply(
    1 requests[*]
      2 report_request_id = f8
      2 request_xml = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(nbr_to_add))
   HEAD REPORT
    req_cnt = 0, encntr_cnt = 0, xencntr_cnt = 0,
    xencntr_cnt = size(xencntr_list->person_list,5)
   DETAIL
    req_cnt += 1
    IF (req_cnt > size(report_request->requests,5))
     stat = alterlist(report_request->requests,(req_cnt+ 9))
    ENDIF
    report_request->requests[req_cnt].scope_flag = scope, report_request->requests[req_cnt].person_id
     = final_rec->qual[d1.seq].person_id, report_request->requests[req_cnt].encntr_id = final_rec->
    qual[d1.seq].encntr_id,
    report_request->requests[req_cnt].order_id = final_rec->qual[d1.seq].order_id, report_request->
    requests[req_cnt].accession_nbr =
    IF (scope=4) final_rec->qual[d1.seq].accession_nbr
    ELSE " "
    ENDIF
    , report_request->requests[req_cnt].template_id = template_id,
    report_request->requests[req_cnt].template_version_mode_flag = published_as_of_mode_type,
    report_request->requests[req_cnt].template_version_dt_tm = cnvtdatetime(dist_date),
    report_request->requests[req_cnt].request_type_flag = 4,
    report_request->requests[req_cnt].begin_dt_tm = cnvtdatetime(final_rec->qual[d1.seq].begin_dt_tm),
    report_request->requests[req_cnt].end_dt_tm = cnvtdatetime(final_rec->qual[d1.seq].end_dt_tm),
    report_request->requests[req_cnt].non_ce_begin_dt_tm = cnvtdatetime(final_rec->qual[d1.seq].
     non_ce_begin_dt_tm),
    report_request->requests[req_cnt].non_ce_end_dt_tm = cnvtdatetime(dist_date), report_request->
    requests[req_cnt].result_status_flag =
    IF (pending_flag=0) 3
    ELSE 2
    ENDIF
    , report_request->requests[req_cnt].use_posting_date_flag = 1,
    report_request->requests[req_cnt].distribution_id = distr_id, report_request->requests[req_cnt].
    dist_run_type_cd = run_type_cd, report_request->requests[req_cnt].dist_run_dt_tm = cnvtdatetime(
     dist_date),
    report_request->requests[req_cnt].reader_group = trim(reader_group), report_request->requests[
    req_cnt].provider_prsnl_id = final_rec->qual[d1.seq].prsnl_person_id, report_request->requests[
    req_cnt].provider_reltn_cd = final_rec->qual[d1.seq].prsnl_person_r_cd,
    report_request->requests[req_cnt].dist_seq = final_rec->qual[d1.seq].xr_dist_seq, report_request
    ->requests[req_cnt].request_prsnl_id = 0
    IF (file_storage_cd != pdfonly_cd
     AND file_storage_cd != txtonly_cd)
     report_request->requests[req_cnt].output_dest_cd = final_rec->qual[d1.seq].output_dest_cd,
     report_request->requests[req_cnt].dms_service_ident = trim(final_rec->qual[d1.seq].
      dms_service_ident)
    ENDIF
    IF (size(trim(final_rec->qual[d1.seq].dms_service_ident)) > 0
     AND findstring("@OUTPUT_DEST@SECURE_EMAIL",trim(final_rec->qual[d1.seq].dms_service_ident)) > 0)
     report_request->requests[req_cnt].custodial_org_id = sending_org_id, report_request->requests[
     req_cnt].sender_email = sender_email
    ENDIF
    report_request->requests[req_cnt].prsnl_reltn_id = final_rec->qual[d1.seq].prsnl_reltn_id,
    report_request->requests[req_cnt].route_id = chart_route_id, report_request->requests[req_cnt].
    route_stop_id = final_rec->qual[d1.seq].seq_grp_id,
    report_request->requests[req_cnt].file_mask = xr_file_mask
    IF (scope=6)
     stat = alterlist(report_request->requests[req_cnt].event_ids,1), report_request->requests[
     req_cnt].event_ids[1].event_id = final_rec->qual[d1.seq].event_id
    ENDIF
    IF (scope=5)
     encntr_cnt = 0
     FOR (x = 1 TO xencntr_cnt)
       IF ((xencntr_list->person_list[x].person_id=final_rec->qual[d1.seq].person_id))
        size1 = 0, size1 = size(xencntr_list->person_list[x].encntr_list,5), sel_count = xencntr_list
        ->person_list[x].selected_cnt
        FOR (y = 1 TO size1)
          IF ((xencntr_list->person_list[x].encntr_list[y].use_flag=1)
           AND (xencntr_list->person_list[x].encntr_list[y].dont_use_flag=0)
           AND (((xencntr_list->person_list[x].encntr_list[y].ce_use_flag=1)) OR (y <= sel_count)) )
           encntr_cnt += 1, stat = alterlist(report_request->requests[req_cnt].xencntr_ids,encntr_cnt
            ), report_request->requests[req_cnt].xencntr_ids[encntr_cnt].encntr_id = xencntr_list->
           person_list[x].encntr_list[y].encntr_id
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
    ENDIF
    IF (((size(trim(file_storage_location,3)) > 0) OR (size(trim(ftp_location,3)) > 0)) )
     output_cnt = 0, report_request->requests[req_cnt].output_dest_cd = 0, report_request->requests[
     req_cnt].dms_service_ident = ""
     IF (file_storage_cd != pdfonly_cd
      AND file_storage_cd != txtonly_cd)
      output_cnt += 1, stat = alterlist(report_request->requests[req_cnt].output_destinations,
       output_cnt), report_request->requests[req_cnt].output_destinations[output_cnt].output_dest_cd
       = final_rec->qual[d1.seq].output_dest_cd,
      report_request->requests[req_cnt].output_destinations[output_cnt].dms_service_ident = trim(
       final_rec->qual[d1.seq].dms_service_ident)
     ENDIF
     IF (size(trim(file_storage_location,3)) > 0)
      output_cnt += 1, stat = alterlist(report_request->requests[req_cnt].output_destinations,
       output_cnt), report_request->requests[req_cnt].output_destinations[output_cnt].
      dms_service_ident = concat(trim(file_storage_location),"@SMB")
     ENDIF
     IF (size(trim(ftp_location,3)) > 0)
      output_cnt += 1, stat = alterlist(report_request->requests[req_cnt].output_destinations,
       output_cnt), report_request->requests[req_cnt].output_destinations[output_cnt].
      dms_service_ident = concat(trim(ftp_location),"@FTP")
     ENDIF
    ENDIF
    IF (((file_storage_cd=txtonly_cd) OR (file_storage_cd=printandtxt_cd)) )
     report_request->requests[req_cnt].output_content_type_cd = txtoutputcontenttype_cd
    ENDIF
   FOOT REPORT
    stat = alterlist(report_request->requests,req_cnt)
   WITH nocounter
  ;end select
  FREE RECORD final_rec
  IF (((file_storage_cd=pdfonly_cd) OR (file_storage_cd=txtonly_cd))
   AND size(trim(file_storage_location,3))=0
   AND size(trim(ftp_location,3))=0)
   SET report_request->print_ind = 0
  ELSE
   SET report_request->print_ind = 1
  ENDIF
  IF (test_ind > 10)
   CALL echorecord(report_request)
  ENDIF
  SET req_cnt = 0
  SET req_cnt = size(report_request->requests,5)
  IF (req_cnt > 0)
   CALL echo(build("TOTAL # OF CHARTS = ",req_cnt))
   SET message_log = concat("Preparing to write ",trim(cnvtstring(req_cnt))," report_request rows.")
   CALL update_log(trim(message_log))
   SET error_chk = error(error_msg,0)
   IF (error_chk=0)
    IF (test_ind < 9)
     EXECUTE cr_srv_upd_report_requests  WITH replace(request,report_request), replace(reply,
      report_reply)
     IF ((report_reply->status_data.status != "F"))
      SET message_log = concat("Finished writing ",trim(cnvtstring(req_cnt))," report_request rows.")
      CALL update_log(trim(message_log))
     ELSE
      SET report_reply->status_data.status = "F"
      SET report_reply->status_data.subeventstatus[1].operationname = "cr_process_dist_xr"
      SET report_reply->status_data.subeventstatus[1].operationstatus = "F"
      SET report_reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
      SET report_reply->status_data.subeventstatus[1].targetobjectvalue =
      "ERROR! - CCL errors occurred in cr_upd_report_request!  Exiting Job."
      SET message_log = report_reply->status_data.subeventstatus[1].targetobjectvalue
      CALL update_log(trim(message_log))
      GO TO exit_script
     ENDIF
    ELSE
     CALL update_log("CR_UPD_REPORT_REQUEST NOT EXECUTED FOR TEST_IND >= 9")
     SET reply->status_data.status = "Z"
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "cp_process_dist"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "ERROR! - CCL errors, report_requests not produced! Exiting Job."
    SET message_log = reply->status_data.subeventstatus[1].targetobjectvalue
    CALL update_log(trim(message_log))
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
   SET message_log = "INFO! - No Encounters with Clinical_Event Activity, Exiting Job."
   CALL update_log(trim(message_log))
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
  SET message_log = "INFO! - No Charts to Print, Exiting Job."
  CALL update_log(trim(message_log))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE update_dist_exec_table(null)
  UPDATE  FROM cr_dist_exec cde
   SET cde.dist_run_dt_tm = cnvtdatetime(dist_date), cde.updt_applctx = reqinfo->updt_applctx, cde
    .updt_cnt = (cde.updt_cnt+ 1),
    cde.updt_dt_tm = cnvtdatetime(sysdate), cde.updt_id = reqinfo->updt_id, cde.updt_task = reqinfo->
    updt_task
   WHERE cde.distribution_id=distr_id
    AND cde.dist_run_type_cd=run_type_cd
   WITH nocounter
  ;end update
  IF (curqual=0)
   SELECT INTO "nl:"
    seq1 = seq(chart_seq,nextval)
    FROM dual
    DETAIL
     nextseq = seq1
    WITH nocounter
   ;end select
   INSERT  FROM cr_dist_exec cde
    SET cde.cr_dist_exec_id = nextseq, cde.distribution_id = distr_id, cde.dist_run_type_cd =
     run_type_cd,
     cde.dist_run_dt_tm = cnvtdatetime(dist_date), cde.updt_applctx = reqinfo->updt_applctx, cde
     .updt_cnt = 0,
     cde.updt_dt_tm = cnvtdatetime(sysdate), cde.updt_id = reqinfo->updt_id, cde.updt_task = reqinfo
     ->updt_task
    WITH nocounter
   ;end insert
  ENDIF
 END ;Subroutine
 SUBROUTINE build_encntr_parser(dist_law_flag)
   SET z = 0
   SET size_et = size(filter_rec->type_flag[1].qual,5)
   SET size_cl = size(filter_rec->type_flag[2].qual,5)
   SET size_lc = size(filter_rec->type_flag[4].qual,5)
   SET size_ms = size(filter_rec->type_flag[5].qual,5)
   DECLARE table_string = vc WITH constant(
    IF (dist_law_flag=0) " chart_dist_filter_value cfv"
    ELSE " chart_law_filter_value cfv"
    ENDIF
    ), protect
   IF (size_et > 0)
    SET idx += 1
    SET stat = alterlist(parser_rec->qual,idx)
    SET parser_rec->qual[idx].statement = concat(" and ",
     IF (et_included) "EXISTS ("
     ELSE "NOT EXISTS ("
     ENDIF
     ," select cfv.parent_entity_id from ",table_string,
     " where cfv.parent_entity_id = e.encntr_type_cd and cfv.type_flag = 0 ",
     IF (dist_law_flag=0) " and cfv.distribution_id = distr_id)"
     ELSE " and cfv.law_id = cross_encntr_law_id)"
     ENDIF
     )
   ENDIF
   IF (size_cl > 0)
    SET idx += 1
    SET stat = alterlist(parser_rec->qual,idx)
    SET parser_rec->qual[idx].statement = concat(" and ",
     IF (cl_included) "EXISTS ("
     ELSE "NOT EXISTS ("
     ENDIF
     ," select cfv.parent_entity_id from ",table_string,
     " where cfv.parent_entity_id = e.organization_id and cfv.type_flag = 1 ",
     IF (dist_law_flag=0) " and cfv.distribution_id = distr_id)"
     ELSE " and cfv.law_id = cross_encntr_law_id)"
     ENDIF
     )
   ENDIF
   IF (size_ms > 0)
    SET idx += 1
    SET stat = alterlist(parser_rec->qual,idx)
    SET parser_rec->qual[idx].statement = concat(" and ",
     IF (ms_included) "EXISTS ("
     ELSE "NOT EXISTS ("
     ENDIF
     ," select cfv.parent_entity_id from ",table_string,
     " where cfv.parent_entity_id = e.med_service_cd and cfv.type_flag = 4 ",
     IF (dist_law_flag=0) " and cfv.distribution_id = distr_id)"
     ELSE " and cfv.law_id = cross_encntr_law_id)"
     ENDIF
     )
   ENDIF
   IF (loc_type_cnt > 0)
    CALL build_loc_qualifier(dist_flag)
   ENDIF
 END ;Subroutine
 SUBROUTINE build_loc_qualifier(dist_law_flag)
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   IF (lc_included=1)
    SET parser_rec->qual[idx].statement = " AND EXISTS ("
   ELSE
    SET parser_rec->qual[idx].statement = " AND NOT EXISTS ("
   ENDIF
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   IF (dist_law_flag=0)
    SET parser_rec->qual[idx].statement =
    "select cfv.parent_entity_id from chart_dist_filter_value cfv "
    SET idx += 1
    SET stat = alterlist(parser_rec->qual,idx)
    SET parser_rec->qual[idx].statement =
    "where cfv.distribution_id = distr_id and cfv.type_flag = 3 and ("
   ELSE
    SET parser_rec->qual[idx].statement =
    "select cfv.parent_entity_id from chart_law_filter_value cfv "
    SET idx += 1
    SET stat = alterlist(parser_rec->qual,idx)
    SET parser_rec->qual[idx].statement =
    "where cfv.law_id = cross_encntr_law_id and cfv.type_flag = 3 and ("
   ENDIF
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   SET parser_rec->qual[idx].statement = "e.loc_facility_cd = cfv.parent_entity_id or "
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   SET parser_rec->qual[idx].statement = "e.loc_building_cd = cfv.parent_entity_id or "
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   SET parser_rec->qual[idx].statement = "e.loc_nurse_unit_cd = cfv.parent_entity_id or "
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   SET parser_rec->qual[idx].statement = "e.loc_room_cd = cfv.parent_entity_id or "
   SET idx += 1
   SET stat = alterlist(parser_rec->qual,idx)
   SET parser_rec->qual[idx].statement = "e.loc_bed_cd = cfv.parent_entity_id)) "
 END ;Subroutine
 SUBROUTINE update_log(str)
   CALL echo(str)
   SELECT INTO "nl:"
    seq1 = seq(chart_dist_log_seq,nextval)
    FROM dual
    DETAIL
     nextseq = seq1
    WITH nocounter
   ;end select
   UPDATE  FROM chart_dist_log cdl
    SET cdl.log_dt_tm = cnvtdatetime(sysdate), cdl.batch_selection = batch_selection, cdl
     .distribution_id = distr_id,
     cdl.dist_run_type_cd = run_type_cd, cdl.dist_run_dt_tm = cnvtdatetime(dist_date), cdl
     .message_text = str,
     cdl.updt_cnt = 0, cdl.updt_dt_tm = cnvtdatetime(sysdate), cdl.updt_id = reqinfo->updt_id,
     cdl.updt_applctx = reqinfo->updt_applctx, cdl.updt_task = reqinfo->updt_task
    WHERE cdl.chart_log_num=nextseq
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM chart_dist_log cdl
     SET cdl.chart_log_num = nextseq, cdl.log_dt_tm = cnvtdatetime(sysdate), cdl.batch_selection =
      batch_selection,
      cdl.distribution_id = distr_id, cdl.dist_run_type_cd = run_type_cd, cdl.dist_run_dt_tm =
      cnvtdatetime(dist_date),
      cdl.message_text = str, cdl.updt_cnt = 0, cdl.updt_dt_tm = cnvtdatetime(sysdate),
      cdl.updt_id = reqinfo->updt_id, cdl.updt_applctx = reqinfo->updt_applctx, cdl.updt_task =
      reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
 END ;Subroutine
#exit_script
 CALL echo("Exit script: cr_process_dist_xr")
 UPDATE  FROM dm_info
  SET info_number = (info_number+ 1), updt_cnt = (updt_cnt+ 1), updt_applctx = 0,
   updt_task = 0, updt_dt_tm = cnvtdatetime(sysdate), updt_id = 0
  WHERE info_domain=trim(ms_batch_selection)
   AND info_char="CLINICAL_REPORTING"
  WITH nocounter
 ;end update
 DELETE  FROM dm_info
  WHERE info_domain=trim(ms_batch_selection)
   AND info_char="CLINICAL_REPORTING"
   AND info_number > 1
  WITH nocounter
 ;end delete
 DECLARE dist_date_str = vc
 IF (curutc)
  SET dist_date_str = datetimezoneformat(dist_date,utc_timezone,format_timezone)
 ELSE
  SET dist_date_str = format(dist_date,";;q")
 ENDIF
 INSERT  FROM dm_info dm
  SET dm.info_name = trim(dist_date_str), dm.info_domain = trim(ms_batch_selection), dm.info_date =
   cnvtdatetime(sysdate),
   dm.info_char = "CLINICAL_REPORTING", dm.info_number = 0, dm.updt_cnt = 0,
   dm.updt_applctx = 0, dm.updt_task = 0, dm.updt_dt_tm = cnvtdatetime(sysdate),
   dm.updt_id = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET message_log = concat("Error writing to DM_INFO dist_date =  ",trim(dist_date_str),
   " ch_ops_journal will fail.")
  CALL update_log(trim(message_log))
 ENDIF
 DELETE  FROM chart_temp ct
  SET ct.seq = 1
  WHERE ct.distribution_id=distr_id
  WITH nocounter
 ;end delete
 DELETE  FROM chart_activity_temp cat
  SET cat.seq = 1
  WHERE cat.distribution_id=distr_id
  WITH nocounter
 ;end delete
 SET error_chk = error(error_msg,0)
 IF ((reply->status_data.status != "F")
  AND error_chk=0)
  IF (0 < 9)
   CALL update_dist_exec_table(null)
  ENDIF
 ENDIF
 SET end_time = cnvtdatetime(sysdate)
 SET message_log = concat("Finished Batch Job -- ",trim(batch_selection)," - ",datetimezoneformat(
   end_time,curtimezoneapp,format_timezone))
 CALL update_log(trim(message_log))
 SET exec_time = datetimediff(cnvtdatetime(end_time),cnvtdatetime(beg_time))
 SET exec_time = ((exec_time * 24) * 60)
 SET message_log = concat("Total Execution Time = ",cnvtstring(exec_time)," MINUTES")
 CALL update_log(trim(message_log))
 FREE RECORD report_request
 FREE RECORD report_reply
 FREE RECORD send_request
 FREE RECORD send_reply
 SUBROUTINE (addrelationship(identifier_id=vc(val),personnel_id=f8(val),reltn_type_cd=f8(val)) =null)
   SET identidx = 0
   SET prsnlidx = 0
   SET reltnidx = 0
   SET idx = 0
   IF (validate(debug_ind,0))
    CALL echo(build("identifier_id: ",identifier_id))
    CALL echo(build("personnel_id: ",personnel_id))
    CALL echo(build("reltn_type_cd: ",reltn_type_cd))
   ENDIF
   SET identidx = locateval(idx,1,reltns->cnt,identifier_id,reltns->idents[idx].id)
   IF (identidx <= 0)
    SET reltns->cnt += 1
    SET identidx = reltns->cnt
    SET stat = alterlist(reltns->idents,identidx)
    SET reltns->idents[identidx].id = identifier_id
   ENDIF
   SET prsnlidx = locateval(idx,1,reltns->idents[identidx].prsnl_cnt,personnel_id,reltns->idents[
    identidx].prsnl[idx].prsnl_id)
   IF (prsnlidx <= 0)
    SET reltns->idents[identidx].prsnl_cnt += 1
    SET prsnlidx = reltns->idents[identidx].prsnl_cnt
    SET stat = alterlist(reltns->idents[identidx].prsnl,prsnlidx)
    SET reltns->idents[identidx].prsnl[prsnlidx].prsnl_id = personnel_id
   ENDIF
   SET reltnidx = locateval(idx,1,reltns->idents[identidx].prsnl[prsnlidx].reltn_cnt,reltn_type_cd,
    reltns->idents[identidx].prsnl[prsnlidx].reltns[idx].reltn_type_cd)
   IF (reltnidx <= 0)
    SET reltns->idents[identidx].prsnl[prsnlidx].reltn_cnt += 1
    SET reltnidx = reltns->idents[identidx].prsnl[prsnlidx].reltn_cnt
    SET stat = alterlist(reltns->idents[identidx].prsnl[prsnlidx].reltns,reltnidx)
    SET reltns->idents[identidx].prsnl[prsnlidx].reltns[reltnidx].reltn_type_cd = reltn_type_cd
   ENDIF
 END ;Subroutine
 SUBROUTINE (ismultirelational(identifier_id=vc(val),personnel_id=f8(val)) =i2)
   DECLARE identidx = i4 WITH noconstant(0), protect
   DECLARE prsnlidx = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   IF ((reltns->cnt > 0))
    SET identidx = locateval(idx,1,reltns->cnt,identifier_id,reltns->idents[idx].id)
    IF (identidx > 0)
     IF ((reltns->idents[identidx].prsnl_cnt > 0))
      SET prsnlidx = locateval(idx,1,reltns->idents[identidx].prsnl_cnt,personnel_id,reltns->idents[
       identidx].prsnl[idx].prsnl_id)
      IF (prsnlidx > 0)
       IF ((reltns->idents[identidx].prsnl[prsnlidx].reltn_cnt > 1))
        RETURN(1)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE buildresultclause(null)
  IF (pending_flag=0)
   SET result_clause = concat(" and ce.result_status_cd in(auth_cd, mod_cd, super_cd, altered_cd)",
    " and ce.event_class_cd != micro_class_cd")
  ELSE
   SET result_clause = concat(" and ce.result_status_cd in(auth_cd,mod_cd,super_cd, altered_cd,",
    "inlab_cd,inprog_cd,trans_cd,ctrans_cd,unauth_cd) and ce.event_class_cd != micro_class_cd")
  ENDIF
  RETURN(result_clause)
 END ;Subroutine
 SUBROUTINE buildresultclauseforradiology(null)
  IF (pending_flag=0)
   SET result_clause = " and ce2.result_status_cd in(auth_cd, mod_cd, super_cd, altered_cd)"
  ELSE
   SET result_clause = concat(" and ce2.result_status_cd in(auth_cd,mod_cd,super_cd, altered_cd,",
    "inlab_cd,inprog_cd,trans_cd,ctrans_cd,unauth_cd)")
  ENDIF
  RETURN(result_clause)
 END ;Subroutine
 SUBROUTINE buildmicroresultclause(null)
   DECLARE mic_pending_clause = vc WITH noconstant(""), private
   DECLARE fsi_micro_clause = vc WITH noconstant(""), private
   DECLARE mill_micro_clause = vc WITH noconstant(""), private
   IF (pending_flag=0)
    SET mic_pending_clause = "ce.result_status_cd in(auth_cd, mod_cd, super_cd, altered_cd)"
   ELSE
    SET mic_pending_clause =
    "ce.result_status_cd in(auth_cd,mod_cd,super_cd,altered_cd,inlab_cd,inprog_cd,trans_cd,ctrans_cd,unauth_cd)"
   ENDIF
   SET fsi_micro_clause = concat(mic_pending_clause," and ce.contributor_system_cd != dPowerchartCd")
   SET mill_micro_clause = concat(
    "ce.result_status_cd in (auth_cd,mod_cd,super_cd,altered_cd,inlab_cd,inprog_cd,trans_cd,ctrans_cd,unauth_cd) ",
    " and ce.contributor_system_cd = dPowerchartCd")
   SET micro_result_clause = concat(" and ce.event_class_cd = micro_class_cd and ((",fsi_micro_clause,
    ") OR (",mill_micro_clause,"))")
   RETURN(micro_result_clause)
 END ;Subroutine
 SUBROUTINE buildcontribsysclause(null)
   DECLARE build_cs_where_clause = vc WITH noconstant("1=1")
   IF (cs_included=1)
    SET build_cs_where_clause =
"ce.contributor_system_cd IN (select cfv.parent_entity_id      from chart_dist_filter_value cfv      where cfv.distribution\
_id = distr_id      and cfv.type_flag = 5)\
"
   ELSEIF (cs_included=0)
    SET build_cs_where_clause =
"ce.contributor_system_cd NOT IN (select cfv.parent_entity_id      from chart_dist_filter_value cfv      where cfv.distribu\
tion_id = distr_id      and cfv.type_flag = 5)\
"
   ENDIF
   RETURN(build_cs_where_clause)
 END ;Subroutine
 SUBROUTINE buildcontribsysclausece2(null)
   DECLARE build_cs_where_clause = vc WITH noconstant("1=1")
   IF (cs_included=1)
    SET build_cs_where_clause =
"ce2.contributor_system_cd IN (select cfv.parent_entity_id      from chart_dist_filter_value cfv      where cfv.distributio\
n_id = distr_id      and cfv.type_flag = 5)\
"
   ELSEIF (cs_included=0)
    SET build_cs_where_clause =
"ce2.contributor_system_cd NOT IN (select cfv.parent_entity_id      from chart_dist_filter_value cfv      where cfv.distrib\
ution_id = distr_id      and cfv.type_flag = 5)\
"
   ENDIF
   RETURN(build_cs_where_clause)
 END ;Subroutine
#exit_main
END GO
