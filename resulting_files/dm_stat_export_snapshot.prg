CREATE PROGRAM dm_stat_export_snapshot
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 RECORD export_request(
   1 mnemonic = vc
   1 domain = vc
   1 node = vc
   1 export_from_dt = f8
   1 export_to_dt = f8
 )
 DECLARE export_dt = c8
 DECLARE export_tm = c8
 DECLARE filename = vc
 DECLARE url = vc
 DECLARE file_flag = i4 WITH noconstant(0)
 DECLARE strformat = vc WITH noconstant(" ")
 DECLARE whereclause = vc
 DECLARE existsclause = vc
 DECLARE export_snapshot_type = vc WITH constant( $1)
 DECLARE export_snapshot_number = i4 WITH constant( $2)
 SET export_dt = format(curdate,"mmddyyyy;;d")
 SET export_tm = format(cnvtdatetime(curdate,curtime3),"hhmmss;3;M")
 DECLARE createfile(snapshottype=vc,fname=vc) = null
 SET url = "http://www.cerner.com/Engineering/ClientData/DMSTATS/1"
 DECLARE export_err_msg = c255
 DECLARE dse_temp_vc_in = vc
 DECLARE dse_temp_vc_out = vc
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="CLIENT MNEMONIC"
  DETAIL
   export_request->mnemonic = di.info_char
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL esmerror("ERROR: Client mnemonic not set",esmexit)
 ENDIF
 SET export_request->export_from_dt = cnvtdatetime((curdate - 1),0)
 SET export_request->export_to_dt = cnvtdatetime((curdate - 1),235959)
 CALL echo(build("Start: ",export_request->export_from_dt))
 CALL echo(build("       (",format(export_request->export_from_dt,"dd-mmm-yyyy hh:mm:ss;;D"),")"))
 CALL echo(build("Stop:  ",export_request->export_to_dt))
 CALL echo(build("       (",format(export_request->export_to_dt,"dd-mmm-yyyy hh:mm:ss;;D"),")"))
 SET export_request->node = trim(curnode)
 SET export_request->domain = reqdata->domain
 DECLARE env_id = vc WITH noconstant("")
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_name="DM_ENV_ID"
  DETAIL
   env_id = cnvtstring(di.info_number,11,2)
  WITH nocounter
 ;end select
 SET whereclause = build("dm.info_name LIKE '",export_snapshot_type,".*' or dm.info_name = '",
  export_snapshot_type,"'")
 SET existsclause = build("dm1.info_name LIKE '",export_snapshot_type,".*' or dm1.info_name = '",
  export_snapshot_type,"'")
 SELECT INTO "nl:"
  dm.info_name
  FROM dm_info dm
  WHERE parser(whereclause)
   AND dm.info_domain="DM_STAT_EXPORT"
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM dm_info dm1
   WHERE info_domain="DM_STAT_EXPORT_EXCLUDE"
    AND parser(existsclause))))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL esmerror(build("ERROR: Invalid snapshot_type: ",export_snapshot_type),esmreturn)
 ELSE
  SET filename = build("msa_",cnvtlower(export_request->node),"_",export_snapshot_number,"_",
   export_dt,"_",export_tm,".xml")
  CALL createfile(export_snapshot_type,filename)
  IF (file_flag > 0)
   INSERT  FROM dm_stat_resend_retry drr
    SET drr.dm_stat_resend_retry_id = seq(dm_clinical_seq,nextval), drr.file_name = cnvtupper(
      filename), drr.resend_retry_cnt = - (1),
     drr.ccts_resend_retry_cnt = - (1), drr.resend_retry_dt_tm = cnvtdatetime(curdate,curtime3), drr
     .updt_id = reqinfo->updt_id,
     drr.updt_dt_tm = cnvtdatetime(curdate,curtime3), drr.updt_task = reqinfo->updt_task, drr
     .updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (error(export_err_msg,0) != 0)
    ROLLBACK
    CALL esmerror(export_err_msg,esmexit)
   ELSE
    COMMIT
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE createfile(snapshottype,fname)
   SET file_flag = 0
   SET whereclause = build("d.snapshot_type LIKE '",snapshottype,".*' or d.snapshot_type = '",
    snapshottype,"'")
   SELECT INTO "nl:"
    ret_cnt = count(*)
    FROM dm_stat_snaps d,
     dm_stat_snaps_values v
    PLAN (d
     WHERE parser(whereclause)
      AND d.stat_snap_dt_tm BETWEEN cnvtdatetime(export_request->export_from_dt) AND cnvtdatetime(
      export_request->export_to_dt)
      AND (d.node_name=export_request->node)
      AND (d.domain_name=export_request->domain))
     JOIN (v
     WHERE d.dm_stat_snap_id=v.dm_stat_snap_id)
    DETAIL
     file_flag = ret_cnt
    WITH nocounter
   ;end select
   IF (file_flag > 0)
    SELECT INTO value(fname)
     snapshot = d.dm_stat_snap_id, stat_name = v.stat_name
     FROM dm_stat_snaps d,
      dm_stat_snaps_values v
     PLAN (d
      WHERE parser(whereclause)
       AND d.stat_snap_dt_tm BETWEEN cnvtdatetime(export_request->export_from_dt) AND cnvtdatetime(
       export_request->export_to_dt)
       AND (d.node_name=export_request->node)
       AND (d.domain_name=export_request->domain))
      JOIN (v
      WHERE d.dm_stat_snap_id=v.dm_stat_snap_id)
     ORDER BY snapshot, stat_name
     HEAD REPORT
      MACRO (convert_special_chars)
       dse_temp_vc_in = replace(dse_temp_vc_in,char(0),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(1),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(2),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(3),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(4),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(5),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(6),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(7),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(8),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(9),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(11),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(12),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(14),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(15),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(16),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(17),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(18),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(19),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(20),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(21),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(22),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(23),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(24),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(25),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(26),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(27),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(28),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(29),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(30),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(31),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,"&","&amp;",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,"<","&lt;",0), dse_temp_vc_in = replace(dse_temp_vc_in,">","&gt;",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,'"',"&quot;",0), dse_temp_vc_out = trim(replace(
         dse_temp_vc_in,"'","&apos;",0))
      ENDMACRO
      , col 0, '<?xml version="1.0" encoding="iso-8859-15" ?>',
      row + 1, col 0, "<DMSTATS xmlns=",
      '"', url, '"',
      ">", row + 1, col 0,
      "<DM_STATS>", row + 1
     HEAD snapshot
      col 0, "<DM_STAT>", row + 1
      IF (isnumeric(format(d.stat_snap_dt_tm,"YYYYMMDDHHMMSS;;D")))
       strformat = build("<Stat_Snap_Dt_Tm>",format(d.stat_snap_dt_tm,"YYYYMMDDHHMMSS;;D"),
        "</Stat_Snap_Dt_Tm>"), col 0, strformat
      ELSE
       col 0, "<Stat_Snap_Dt_Tm/>"
      ENDIF
      row + 1
      IF (size(d.snapshot_type,1))
       strformat = build("<Snapshot_Type>",d.snapshot_type,"</Snapshot_Type>"), col 0, strformat
      ELSE
       col 0, "<Snapshot_Type/>"
      ENDIF
      row + 1
      IF (size(d.domain_name,1))
       strformat = build("<Domain_Name>",d.domain_name,"</Domain_Name>"), col 0, strformat
      ELSE
       col 0, "<Domain_Name/>"
      ENDIF
      row + 1
      IF (size(d.node_name,1))
       strformat = build("<Node_Name>",d.node_name,"</Node_Name>"), col 0, strformat
      ELSE
       col 0, "<Node_Name/>"
      ENDIF
      row + 1
      IF (size(env_id,1))
       strformat = build("<Env_Id>",env_id,"</Env_Id>"), col 0, strformat
      ELSE
       col 0, "<Env_Id/>"
      ENDIF
      row + 1, col 0, "<VALUES>",
      row + 1
     DETAIL
      col 0, "<VALUE>", row + 1
      IF (size(trim(v.stat_name),1))
       dse_temp_vc_in = trim(v.stat_name), convert_special_chars, col 0,
       "<Stat_Name>", dse_temp_vc_out, "</Stat_Name>"
      ELSE
       col 0, "<Stat_Name/>"
      ENDIF
      row + 1
      IF (v.stat_type)
       strformat = build("<Stat_Type>",cnvtstring(v.stat_type,1),"</Stat_Type>"), col 0, strformat
      ELSE
       col 0, "<Stat_Type/>"
      ENDIF
      row + 1
      IF (size(v.stat_number_val,1))
       strformat = build("<Stat_Number_Val>",cnvtstring(v.stat_number_val,20,2),"</Stat_Number_Val>"),
       col 0, strformat
      ELSE
       col 0, "<Stat_Number_Val/>"
      ENDIF
      row + 1
      IF (size(v.stat_seq,1))
       strformat = build("<Stat_Seq>",cnvtstring(v.stat_seq),"</Stat_Seq>"), col 0, strformat
      ELSE
       col 0, "<Stat_Seq/>"
      ENDIF
      row + 1
      IF (size(v.stat_str_val,1))
       dse_temp_vc_in = trim(v.stat_str_val), convert_special_chars, strformat = build(
        "<Stat_Str_Val>",dse_temp_vc_out,"</Stat_Str_Val>"),
       col 0, strformat
      ELSE
       col 0, "<Stat_Str_Val/>"
      ENDIF
      row + 1, col 0, "<Stat_Date_Val/>",
      row + 1
      IF (size(v.stat_clob_val,1))
       dse_temp_vc_in = trim(v.stat_clob_val), convert_special_chars, strformat = build(
        "<Stat_Clob_Val>",dse_temp_vc_out,"</Stat_Clob_Val>"),
       col 0, strformat
      ELSE
       col 0, "<Stat_Clob_Val/>"
      ENDIF
      row + 1, col 0, "</VALUE>",
      row + 1
     FOOT  snapshot
      col 0, "</VALUES>", row + 1,
      col 0, "</DM_STAT>", row + 1
     FOOT REPORT
      col 0, "</DM_STATS>", row + 1,
      col 0, "</DMSTATS>"
     WITH nocounter, noformfeed, maxrow = 1,
      maxcol = 32032, format = variable
    ;end select
    IF (error(export_err_msg,0) != 0)
     CALL esmerror(export_err_msg,esmreturn)
    ELSE
     CALL echo(build("file: ",fname," created."))
    ENDIF
   ENDIF
 END ;Subroutine
#exit_program
 FREE RECORD export_request
END GO
