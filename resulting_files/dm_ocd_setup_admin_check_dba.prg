CREATE PROGRAM dm_ocd_setup_admin_check:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   di.info_name
   FROM dm_info di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="INHOUSE DOMAIN"
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET readme_data->status = "S"
   SET readme_data->message = "Auto-success for in-house domains."
   GO TO exit_script
  ENDIF
  FREE RECORD rchkadm
  RECORD rchkadm(
    1 qual[*]
      2 tname = vc
      2 exist_ind = i2
      2 col_cnt = i2
    1 tcnt = i4
  )
  SET rchkadm->tcnt = 0
  CALL addtbl("DM_OCD_PRODUCT_AREA")
  CALL addtbl("DM_README")
  CALL addtbl("DM_OCD_LOG")
  CALL addtbl("DM_ADM_PURGE_TEMPLATE")
  CALL addtbl("DM_ADM_PURGE_TOKEN")
  CALL addtbl("DM_ADM_PURGE_TABLE")
  CALL addtbl("DM_AFE_SHIP")
  CALL addtbl("DM_README_HIST_SHIP")
  SET link_str = fillstring(20," ")
  SELECT INTO "nl:"
   a.table_name
   FROM all_synonyms a
   WHERE a.table_name="DM_ENVIRONMENT"
   DETAIL
    link_str = cnvtlower(substring(1,(findstring(".",a.db_link) - 1),a.db_link))
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Could not find dm_environment synonym. ",
    "Make sure dm_cdba_synonym has been run for this environment")
   GO TO exit_script
  ENDIF
  SET tbl_link = build("user_tables@",link_str)
  CALL parser('select into "nl:"',1)
  CALL parser("    u.table_name",1)
  CALL parser(concat("from ",tbl_link," u, (dummyt d with seq = value(rChkAdm->tcnt))"),1)
  CALL parser("plan d",1)
  CALL parser("join u where u.table_name = rChkAdm->qual[d.seq]->tname",1)
  CALL parser("detail",1)
  CALL parser("    rChkAdm->qual[d.seq]->exist_ind = 1",1)
  CALL parser("with nocounter",1)
  CALL parser("go",1)
  SET tcnt = 0
  SELECT INTO "dm_ocd_setup_admin_check.log"
   d.seq
   FROM (dummyt d  WITH seq = value(rchkadm->tcnt))
   PLAN (d
    WHERE (rchkadm->qual[d.seq].exist_ind=0))
   HEAD REPORT
    row + 1, col 1, "ELEMENTS MISSING FROM ADMIN DATABASE",
    row + 1
   DETAIL
    row + 1, col 1, "TABLE: ",
    rchkadm->qual[d.seq].tname
   FOOT REPORT
    row + 2, col 1,
    "PLEASE MAKE SURE YOU HAVE RUN DM_OCD_SETUP_ADMIN AS INSTRUCTED IN SPECIAL INSTRUCTIONS ",
    row + 1, col 1, "FOR INSTALLATION TOOLS OCD."
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("One or more elements missing from admin database. ",
    "Make sure you have run dm_ocd_setup_admin as directed in special instructions ",
    "for Installation Tools OCD.  See dm_ocd_setup_admin_check.log for details.")
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "Admin database is set up correctly for OCD installations."
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for non-Oracle databases."
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 SUBROUTINE addtbl(tbl_name)
   SET rchkadm->tcnt = (rchkadm->tcnt+ 1)
   SET stat = alterlist(rchkadm->qual,rchkadm->tcnt)
   SET rchkadm->qual[rchkadm->tcnt].tname = tbl_name
   SET rchkadm->qual[rchkadm->tcnt].exist_ind = 0
 END ;Subroutine
END GO
