CREATE PROGRAM dm_stat_error:dba
 RECORD err_text(
   1 err_dt_tm = dq8
   1 err_msg = vc
   1 err_file = vc
   1 err_cat = vc
   1 err_client_mnemonic = vc
 )
 DECLARE status_tmp = c100 WITH noconstant("")
 DECLARE dclcmd = vc
 DECLARE dir_name = vc
 DECLARE url = vc
 DECLARE dse_status = i4
 DECLARE temp1 = vc
 DECLARE dse_vc_in = vc
 DECLARE dse_vc_out = vc
 DECLARE dse_domain_name = vc
 SET dse_domain_name = reqdata->domain
 SET url = "http://www.cerner.com/Engineering/ClientData/DMSTATS/1"
 SET dir_name = "CCLUSERDIR"
 SET error_dt = format(curdate,"mmddyyyy;;d")
 SET error_tm = format(cnvtdatetime(curdate,curtime3),"hhmmss;3;M")
 SET err_text->err_dt_tm =  $1
 SET err_text->err_msg = trim( $2,3)
 SET err_text->err_cat =  $3
 SET err_text->err_file = build("msa_",cnvtlower(trim(curnode)),"_0_",error_dt,"_",
  error_tm,"_",rand(0),".xml")
 SELECT INTO "nl:"
  d.info_char
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="CLIENT MNEMONIC"
  DETAIL
   err_text->err_client_mnemonic = d.info_char
  WITH nocounter
 ;end select
 DECLARE node = vc
 DECLARE dss_id = f8
 SET node = trim(curnode)
 SET status_tmp = concat("status_",cnvtlower(node),".tmp")
 SET dss_id = 0
 SELECT INTO "nl:"
  FROM dm_stat_snaps ds
  WHERE ds.stat_snap_dt_tm=cnvtdatetimeutc(err_text->err_dt_tm)
   AND (ds.client_mnemonic=err_text->err_client_mnemonic)
   AND ds.domain_name=substring(1,20,dse_domain_name)
   AND ds.node_name=node
   AND ds.snapshot_type="DM_STAT_GATHER_ERRORS"
  DETAIL
   dss_id = ds.dm_stat_snap_id
  WITH nocounter
 ;end select
 IF (dss_id=0)
  SELECT INTO "nl:"
   y = seq(dm_clinical_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    dss_id = cnvtreal(y)
   WITH format, counter
  ;end select
  INSERT  FROM dm_stat_snaps ds
   SET ds.dm_stat_snap_id = dss_id, ds.stat_snap_dt_tm = cnvtdatetime(err_text->err_dt_tm), ds
    .client_mnemonic = err_text->err_client_mnemonic,
    ds.domain_name = substring(1,20,dse_domain_name), ds.node_name = node, ds.snapshot_type =
    "DM_STAT_GATHER_ERRORS",
    ds.updt_dt_tm = cnvtdatetime(curdate,curtime3), ds.updt_id = reqinfo->updt_id, ds.updt_task =
    reqinfo->updt_task,
    ds.updt_applctx = reqinfo->updt_applctx, ds.updt_cnt = 0
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 UPDATE  FROM dm_stat_snaps_values ssv
  SET ssv.stat_str_val = err_text->err_msg, ssv.stat_type = 2, ssv.stat_date_dt_tm = cnvtdatetime(
    err_text->err_dt_tm),
   ssv.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssv.updt_cnt = (ssv.updt_cnt+ 1), ssv.updt_id =
   reqinfo->updt_id,
   ssv.updt_task = reqinfo->updt_task, ssv.updt_applctx = reqinfo->updt_applctx
  WHERE ssv.dm_stat_snap_id=dss_id
   AND (ssv.stat_name=err_text->err_cat)
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_stat_snaps_values ssv
   SET ssv.dm_stat_snap_id = dss_id, ssv.stat_name = err_text->err_cat, ssv.stat_seq = 0,
    ssv.stat_str_val = err_text->err_msg, ssv.stat_type = 2, ssv.stat_date_dt_tm = cnvtdatetime(
     err_text->err_dt_tm),
    ssv.updt_dt_tm = cnvtdatetime(curdate,curtime3), ssv.updt_id = reqinfo->updt_id, ssv.updt_task =
    reqinfo->updt_task,
    ssv.updt_applctx = reqinfo->updt_applctx, ssv.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
 SELECT INTO value(err_text->err_file)
  HEAD REPORT
   MACRO (convert_special_chars)
    dse_vc_in = replace(dse_vc_in,"&","&amp;",0), dse_vc_in = replace(dse_vc_in,"<","&lt;",0),
    dse_vc_in = replace(dse_vc_in,">","&gt;",0),
    dse_vc_in = replace(dse_vc_in,'"',"&quot;",0), dse_vc_out = replace(dse_vc_in,"'","&apos;",0)
   ENDMACRO
  DETAIL
   col 0, '<?xml version="1.0" encoding="iso-8859-15" ?>', row + 1,
   col 0, "<DMSTATS xmlns=", '"',
   url, '"', ">",
   row + 1, col 0, "<DM_STATS>",
   row + 1, col 0, "<DM_STAT>",
   temp1 = concat("<Stat_Snap_Dt_Tm>",format(curdate,"YYYYMMDD;;D"),format(curtime,"HHMMSS;;M"),
    "</Stat_Snap_Dt_Tm>"), row + 1, col 0,
   temp1, row + 1, col 0,
   "<Snapshot_Type>DM_STAT_GATHER_ERRORS</Snapshot_Type>"
   IF (dse_domain_name > " ")
    temp1 = concat("<Domain_Name>",trim(dse_domain_name,3),"</Domain_Name>")
   ELSE
    temp1 = "<Domain_Name/>"
   ENDIF
   row + 1, col 0, temp1
   IF (node > " ")
    temp1 = concat("<Node_Name>",trim(node,3),"</Node_Name>")
   ELSE
    temp1 = "<Node_Name/>"
   ENDIF
   row + 1, col 0, temp1,
   row + 1, col 0, "<VALUES>",
   row + 1, col 0, "<VALUE>",
   temp1 = concat("<Stat_Name>",err_text->err_cat,"</Stat_Name>"), row + 1, col 0,
   temp1, row + 1, col 0,
   "<Stat_Seq>1</Stat_Seq>", dse_vc_in = err_text->err_msg, convert_special_chars
   IF (textlen(dse_vc_out) > 255)
    temp1 = concat("<Stat_Str_Val>",substring(1,255,dse_vc_out),"</Stat_Str_Val>")
   ELSE
    temp1 = concat("<Stat_Str_Val>",dse_vc_out,"</Stat_Str_Val>")
   ENDIF
   row + 1, col 0, temp1,
   row + 1, col 0, "<Stat_Type>2</Stat_Type>",
   row + 1, col 0, "<Stat_Number_Val/>",
   row + 1, col 0, "<Stat_Date_Val/>",
   row + 1, col 0, "<Stat_Clob_Val/>",
   row + 1, col 0, "</VALUE>",
   row + 1, col 0, "</VALUES>",
   row + 1, col 0, "</DM_STAT>",
   row + 1, col 0, "</DM_STATS>",
   row + 1, col 0, "</DMSTATS>"
  WITH nocounter, noformfeed, maxrow = 1,
   maxcol = 350
 ;end select
 INSERT  FROM dm_stat_resend_retry drr
  SET drr.dm_stat_resend_retry_id = seq(dm_clinical_seq,nextval), drr.file_name = cnvtupper(err_text
    ->err_file), drr.resend_retry_cnt = - (1),
   drr.ccts_resend_retry_cnt = - (1), drr.resend_retry_dt_tm = cnvtdatetime(curdate,curtime3), drr
   .updt_id = reqinfo->updt_id,
   drr.updt_dt_tm = cnvtdatetime(curdate,curtime3), drr.updt_task = reqinfo->updt_task, drr
   .updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 COMMIT
 FREE RECORD err_text
END GO
