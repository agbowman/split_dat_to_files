CREATE PROGRAM dm_adhoc_dataset:dba
 DECLARE dmstatseq = f8
 SELECT INTO "nl:"
  se_id = seq(dm_clinical_seq,nextval)
  FROM dual
  DETAIL
   dmstatseq = se_id
  WITH nocounter
 ;end select
 DECLARE domain_name = vc WITH constant( $1)
 DECLARE initiative = vc WITH constant( $2)
 DECLARE package_number = vc WITH constant( $3)
 DECLARE description = vc WITH constant( $4)
 IF (size(initiative,3) > 75)
  CALL echo("Initiative must be less than 75 Characters")
  GO TO exit_program
 ENDIF
 SET reqdata->domain = domain_name
 SET dmstatsnapshot = build("DMADHOC_",initiative,"_",package_number)
 SET dmstatname = package_number
 SET dmclientmnemonic = logical("CLIENT_MNEMONIC")
 SET finalsnap = build("SOLCAP||",dmstatsnapshot)
 INSERT  FROM dm_stat_snaps ds
  SET ds.dm_stat_snap_id = dmstatseq, ds.stat_snap_dt_tm = cnvtdatetime((curdate - 1),0), ds
   .client_mnemonic = dmclientmnemonic,
   ds.domain_name = reqdata->domain, ds.node_name = curnode, ds.snapshot_type = finalsnap,
   ds.updt_dt_tm = cnvtdatetime(curdate,curtime3)
 ;end insert
 INSERT  FROM dm_stat_snaps_values dsv
  SET dsv.dm_stat_snap_id = dmstatseq, dsv.stat_name = dmstatname, dsv.stat_number_val = 1,
   dsv.stat_str_val = curuser, dsv.stat_date_dt_tm = cnvtdatetime(curdate,curtime3), dsv.stat_seq = 0,
   dsv.stat_clob_val = description, dsv.updt_dt_tm = cnvtdatetime(curdate,curtime3)
 ;end insert
 COMMIT
 EXECUTE dm_stat_export_solcap dmstatsnapshot, 999
#exit_program
END GO
