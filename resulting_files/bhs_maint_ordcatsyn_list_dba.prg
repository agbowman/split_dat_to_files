CREATE PROGRAM bhs_maint_ordcatsyn_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Program Options" = "VIEW",
  "File Name located in  \\bhsdata01\CISCORE_FTP\OrdCatSynImport\PROD" = "ordcatsynimport.csv",
  "List Name" = "Narcotic Orders",
  "Catalog_cd or Synonym_id" = 0,
  "Orders" = 0,
  "View Deletion History" = 0,
  "List Name" = "",
  "Delete Order" = 0
  WITH outdev, s_option, s_file_name,
  s_list_add, f_cat_syn, f_synonym_id,
  n_hist_ind, s_list_del, f_del_syn_id
 EXECUTE bhs_check_domain:dba
 RECORD m_data(
   1 existing_orders[*]
     2 f_synonym_id = f8
     2 f_catalog_cd = f8
     2 f_updt_id = f8
     2 f_updt_dt_tm = f8
     2 n_active_ind = i2
     2 s_list = vc
     2 s_list_key = vc
   1 new_orders[*]
     2 f_catalog_cd = f8
     2 f_synonym_id = f8
   1 del_orders[*]
     2 f_synonym_id = f8
 ) WITH protect
 DECLARE ms_option = vc WITH protect, constant(trim(cnvtupper( $S_OPTION),3))
 DECLARE ms_filenamein = vc WITH protect, constant(cnvtlower( $S_FILE_NAME))
 DECLARE ms_filenameout = vc WITH protect, constant(concat("bhsordlistimport",format(cnvtdatetime(
     sysdate),"mmddyyyy;;d"),"*"))
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant("CernerFTP")
 DECLARE ms_ftp_password = vc WITH protect, constant("gJeZD64")
 DECLARE ms_get_ftp_cmd = vc WITH protect, constant(concat("get ",ms_filenamein))
 DECLARE ms_put_ftp_cmd = vc WITH protect, constant(concat("mput ",ms_filenameout))
 DECLARE ms_rem_dir = vc WITH protect, noconstant("")
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mf_updt_dt_tm = f8 WITH protect, noconstant(0)
 IF (ms_option="IMPORT"
  AND textlen(trim( $S_FILE_NAME,3))=0)
  SET ms_error = "Missing .csv file name."
  GO TO exit_script
 ELSEIF (ms_option="ADD"
  AND ( $F_SYNONYM_ID=null))
  SET ms_error = "Select an order to be added."
  GO TO exit_script
 ELSEIF (ms_option="DELETE"
  AND ( $F_DEL_SYN_ID=null)
  AND ( $N_HIST_IND=0))
  SET ms_error = "Select an order to be deleted."
  GO TO exit_script
 ENDIF
 IF (ms_option="VIEW")
  SELECT INTO value( $OUTDEV)
   bol.*
   FROM bhs_ordcatsyn_list bol
   ORDER BY bol.list, bol.updt_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ms_option="ADD")
  SELECT INTO "nl:"
   FROM bhs_ordcatsyn_list bol
   PLAN (bol
    WHERE (bol.list= $S_LIST_ADD))
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1
    IF (ml_cnt > size(m_data->existing_orders,5))
     CALL alterlist(m_data->existing_orders,(ml_cnt+ 100))
    ENDIF
    m_data->existing_orders[ml_cnt].f_synonym_id = bol.synonym_id
   FOOT REPORT
    CALL alterlist(m_data->existing_orders,ml_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE ocs.synonym_id IN ( $F_SYNONYM_ID)
     AND  NOT (expand(ml_num,1,size(m_data->existing_orders,5),ocs.synonym_id,m_data->
     existing_orders[ml_num].f_synonym_id))
     AND ocs.active_ind=1)
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1
    IF (ml_cnt > size(m_data->new_orders,5))
     CALL alterlist(m_data->new_orders,(ml_cnt+ 100))
    ENDIF
    m_data->new_orders[ml_cnt].f_catalog_cd = ocs.catalog_cd, m_data->new_orders[ml_cnt].f_synonym_id
     = ocs.synonym_id
   FOOT REPORT
    CALL alterlist(m_data->new_orders,ml_cnt)
   WITH nocounter, expand = 1
  ;end select
  SET mf_updt_dt_tm = cnvtdatetime(sysdate)
  IF (size(m_data->new_orders,5) > 0)
   INSERT  FROM (dummyt d  WITH seq = size(m_data->new_orders,5)),
     bhs_ordcatsyn_list bol
    SET bol.active_ind = 1, bol.catalog_cd = m_data->new_orders[d.seq].f_catalog_cd, bol.synonym_id
      = m_data->new_orders[d.seq].f_synonym_id,
     bol.list =  $S_LIST_ADD, bol.list_key = replace(cnvtupper( $S_LIST_ADD)," ",""), bol.updt_dt_tm
      = cnvtdatetime(mf_updt_dt_tm),
     bol.updt_id = reqinfo->updt_id
    PLAN (d)
     JOIN (bol)
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
  SELECT INTO value( $OUTDEV)
   mod =
   IF (bol.updt_dt_tm=cnvtdatetime(mf_updt_dt_tm)
    AND (bol.updt_id=reqinfo->updt_id)) "*** Inserted Row ***"
   ELSEIF (size(m_data->new_orders,5)=0) "*** No Changes Made ***"
   ELSE ""
   ENDIF
   , bol.*
   FROM bhs_ordcatsyn_list bol
   ORDER BY bol.updt_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ms_option="DELETE"
  AND ( $N_HIST_IND=0))
  SELECT INTO "nl:"
   FROM bhs_ordcatsyn_list bol
   ORDER BY bol.list, bol.updt_dt_tm DESC
   HEAD REPORT
    ml_cnt = 0
   DETAIL
    ml_cnt += 1
    IF (ml_cnt > size(m_data->existing_orders,5))
     CALL alterlist(m_data->existing_orders,(ml_cnt+ 100))
    ENDIF
    m_data->existing_orders[ml_cnt].f_synonym_id = bol.synonym_id, m_data->existing_orders[ml_cnt].
    f_catalog_cd = bol.catalog_cd, m_data->existing_orders[ml_cnt].f_updt_id = bol.updt_id,
    m_data->existing_orders[ml_cnt].f_updt_dt_tm = bol.updt_dt_tm, m_data->existing_orders[ml_cnt].
    n_active_ind = bol.active_ind, m_data->existing_orders[ml_cnt].s_list = bol.list,
    m_data->existing_orders[ml_cnt].s_list_key = bol.list_key
   FOOT REPORT
    CALL alterlist(m_data->existing_orders,ml_cnt)
   WITH nocounter
  ;end select
  DELETE  FROM bhs_ordcatsyn_list
   WHERE (list= $S_LIST_DEL)
    AND synonym_id IN ( $F_DEL_SYN_ID)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET ms_error = "Error deleting orders."
   GO TO exit_script
  ENDIF
  COMMIT
  EXECUTE bhs_hlp_ccl
  CALL bhs_sbr_log("start","",0,"",0.0,
   "","Begin Script","")
  SET ms_item_list = reflect(parameter(9,0))
  IF (substring(1,1,ms_item_list)="L")
   SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
   FOR (i = 1 TO ml_cnt)
     CALL bhs_sbr_log("log","",1,"SYNONYM_ID",cnvtreal(parameter(9,i)),
      "LIST", $S_LIST_DEL,"S")
   ENDFOR
  ELSEIF (substring(1,1,ms_item_list)="F")
   CALL bhs_sbr_log("log","",1,"SYNONYM_ID",cnvtreal(parameter(9,0)),
    "LIST", $S_LIST_DEL,"S")
  ENDIF
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "","000","S")
  SELECT INTO value( $OUTDEV)
   mod =
   IF ((m_data->existing_orders[d.seq].s_list= $S_LIST_DEL)
    AND (m_data->existing_orders[d.seq].f_synonym_id IN ( $F_DEL_SYN_ID))) "*** Deleted Row ***"
   ELSE ""
   ENDIF
   , list = m_data->existing_orders[d.seq].s_list, list_key = m_data->existing_orders[d.seq].
   s_list_key,
   catalog_cd = m_data->existing_orders[d.seq].f_catalog_cd, synonym_id = m_data->existing_orders[d
   .seq].f_synonym_id, active_ind = m_data->existing_orders[d.seq].n_active_ind,
   updt_id = m_data->existing_orders[d.seq].f_updt_id, updt_dt_tm = m_data->existing_orders[d.seq].
   f_updt_dt_tm
   FROM (dummyt d  WITH seq = size(m_data->existing_orders,5))
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ms_option="DELETE"
  AND ( $N_HIST_IND=1))
  SELECT INTO value( $OUTDEV)
   list = bd.msg, ocs.mnemonic, ocs.catalog_cd,
   synonym_id = bd.parent_entity_id, p.username, bd.updt_id,
   deletion_dt_tm = format(bd.updt_dt_tm,"mm/dd/yyyy hh:mm:ss ;;d")
   FROM bhs_log b,
    bhs_log_detail bd,
    prsnl p,
    order_catalog_synonym ocs
   PLAN (b
    WHERE b.object_name="BHS_MAINT_ORDCATSYN_LIST"
     AND b.msg="000")
    JOIN (bd
    WHERE bd.bhs_log_id=b.bhs_log_id)
    JOIN (p
    WHERE p.person_id=bd.updt_id)
    JOIN (ocs
    WHERE ocs.synonym_id=bd.parent_entity_id)
   ORDER BY bd.updt_dt_tm DESC, bd.bhs_log_id
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (ms_option="IMPORT")
  IF (gl_bhs_prod_flag=0)
   SET ms_rem_dir = "/CISCORE/OrdCatSynImport/NONPROD"
  ELSE
   SET ms_rem_dir = "/CISCORE/OrdCatSynImport/PROD"
  ENDIF
  EXECUTE bhs_hlp_ftp
  SET stat = bhs_ftp_cmd(ms_get_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
   ms_rem_dir)
  IF (stat=0)
   SET ms_error = concat("Failed to retrieve .csv file from ",ms_rem_dir,
    ". Error logs sent to CisCore.")
   GO TO exit_script
  ENDIF
  EXECUTE kia_dm_dbimport concat(ms_loc_dir,"/",ms_filenamein), "bhs_rpt_import_order_list", 10000,
  0
  SET stat = bhs_ftp_cmd(ms_put_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
   ms_rem_dir)
  SELECT INTO value( $OUTDEV)
   mod =
   IF (datetimediff(sysdate,bol.updt_dt_tm,5) < 180
    AND (bol.updt_id=reqinfo->updt_id)) "*** Inserted Row ***"
   ENDIF
   , bol.*
   FROM bhs_ordcatsyn_list bol
   ORDER BY bol.updt_dt_tm DESC
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 IF (textlen(trim(ms_error,3)) != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg = ms_error, row + 1, "{f/1}{cpi/12}",
    CALL print(calcpos(22,18)), msg
   WITH dio = 08
  ;end select
 ENDIF
END GO
