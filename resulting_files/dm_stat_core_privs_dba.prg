CREATE PROGRAM dm_stat_core_privs:dba
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 RECORD resend_files(
   1 qual[*]
     2 file_name = vc
 )
 RECORD export_request(
   1 mnemonic = vc
   1 domain = vc
   1 node = vc
 )
 DECLARE prev_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
 DECLARE sequence = i4 WITH protect, noconstant(1)
 DECLARE writedsrtofile(snapshot_number=i4,namespace=vc) = null
 DECLARE initialize("X") = null
 DECLARE writelinetofile(line=vc,newline=i2) = null
 DECLARE updateresendtable(filename=vc,batchindex=i4,batchcnt=i4) = null
 DECLARE convertspecialchars("X") = null
 DECLARE export_dt = c8
 DECLARE export_tm = c8
 DECLARE filename = vc
 DECLARE export_err_msg = c255
 DECLARE dse_temp_vc_in = vc
 DECLARE dse_temp_vc_out = vc
 DECLARE strformat = vc WITH noconstant("")
 DECLARE url = vc
 SET urlquarterly = "http://www.cerner.com/Engineering/ClientData/DMSTATSQUARTERLY/1"
 SET urldaily = "http://www.cerner.com/Engineering/ClientData/DMSTATS/1"
 SET export_dt = format(curdate,"mmddyyyy;;d")
 SET export_tm = format(cnvtdatetime(curdate,curtime3),"hhmmss;3;M")
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
 SUBROUTINE writedsrtofile(snapshot_number,namespace)
   IF (size(dsr->qual[1].qual,5) > 0)
    SET filename = build("msa_",cnvtlower(export_request->node),"_",snapshot_number,"_",
     export_dt,"_",export_tm,"-",sequence,
     ".xml")
    SET frec->file_name = filename
    SET frec->file_buf = "w"
    SET stat = cclio("OPEN",frec)
    IF (stat=0)
     CALL esmerror("Unable to open file",esmexit)
    ENDIF
    CALL writelinetofile('<?xml version="1.0" encoding="iso-8859-15" ?>',1)
    IF (namespace="DAILY")
     SET url = urldaily
    ELSE
     SET url = urlquarterly
    ENDIF
    CALL writelinetofile(build("<DMSTATS xmlns=",'"',url,'"',">"),1)
    CALL writelinetofile("<DM_STATS>",1)
    FOR (export_itr = 1 TO size(dsr->qual[1].qual,5))
      IF ((((prev_dt_tm != dsr->qual[1].stat_snap_dt_tm)) OR (export_itr=1)) )
       IF (export_itr != 1)
        CALL writelinetofile("</VALUES>",1)
        CALL writelinetofile("</DM_STAT>",1)
       ENDIF
       CALL writelinetofile("<DM_STAT>",1)
       IF (isnumeric(format(dsr->qual[1].stat_snap_dt_tm,"YYYYMMDDHHMMSS;;D")))
        SET strformat = build("<Stat_Snap_Dt_Tm>",format(dsr->qual[1].stat_snap_dt_tm,
          "YYYYMMDDHHMMSS;;D"),"</Stat_Snap_Dt_Tm>")
       ELSE
        SET strformat = "<Stat_Snap_Dt_Tm/>"
       ENDIF
       CALL writelinetofile(strformat,1)
       IF (size(dsr->qual[1].snapshot_type,1))
        SET strformat = build("<Snapshot_Type>",dsr->qual[1].snapshot_type,"-",sequence,
         "</Snapshot_Type>")
       ELSE
        SET strformat = "<Snapshot_Type/>"
       ENDIF
       CALL writelinetofile(strformat,1)
       SET strformat = build("<Domain_Name>",export_request->domain,"</Domain_Name>")
       CALL writelinetofile(strformat,1)
       SET strformat = build("<Node_Name>",export_request->node,"</Node_Name>")
       CALL writelinetofile(strformat,1)
       IF (size(env_id,1))
        SET strformat = build("<Env_Id>",env_id,"</Env_Id>")
       ELSE
        SET strformat = "<Env_Id/>"
       ENDIF
       CALL writelinetofile(strformat,1)
       CALL writelinetofile("<VALUES>",1)
       SET prev_dt_tm = dsr->qual[1].stat_snap_dt_tm
      ENDIF
      CALL writelinetofile("<VALUE>",1)
      IF (size(trim(dsr->qual[1].qual[export_itr].stat_name),1))
       SET dse_temp_vc_in = trim(dsr->qual[1].qual[export_itr].stat_name)
       CALL convertspecialchars("X")
       SET strformat = build("<Stat_Name>",dse_temp_vc_out,"</Stat_Name>")
      ELSE
       SET strformat = "<Stat_Name/>"
      ENDIF
      CALL writelinetofile(strformat,1)
      IF (dsr->qual[1].qual[export_itr].stat_type
       AND (dsr->qual[1].qual[export_itr].stat_type != - (1)))
       SET strformat = build("<Stat_Type>",cnvtstring(dsr->qual[1].qual[export_itr].stat_type,1),
        "</Stat_Type>")
      ELSE
       SET strformat = "<Stat_Type/>"
      ENDIF
      CALL writelinetofile(strformat,1)
      IF (size(dsr->qual[1].qual[export_itr].stat_number_val,1)
       AND (dsr->qual[1].qual[export_itr].stat_number_val != - (100)))
       SET strformat = build("<Stat_Number_Val>",cnvtstring(dsr->qual[1].qual[export_itr].
         stat_number_val,20,2),"</Stat_Number_Val>")
      ELSE
       SET strformat = "<Stat_Number_Val/>"
      ENDIF
      CALL writelinetofile(strformat,1)
      IF (size(dsr->qual[1].qual[export_itr].stat_seq,1))
       SET strformat = build("<Stat_Seq>",cnvtstring(dsr->qual[1].qual[export_itr].stat_seq),
        "</Stat_Seq>")
      ELSE
       SET strformat = "<Stat_Seq/>"
      ENDIF
      CALL writelinetofile(strformat,1)
      IF (size(trim(dsr->qual[1].qual[export_itr].stat_str_val,1)))
       SET dse_temp_vc_in = trim(dsr->qual[1].qual[export_itr].stat_str_val)
       CALL convertspecialchars("X")
       SET strformat = build("<Stat_Str_Val>",dse_temp_vc_out,"</Stat_Str_Val>")
      ELSE
       SET strformat = "<Stat_Str_Val/>"
      ENDIF
      CALL writelinetofile(strformat,1)
      CALL writelinetofile("<Stat_Date_Val/>",1)
      IF (size(trim(dsr->qual[1].qual[export_itr].stat_clob_val,1)))
       SET dse_temp_vc_in = trim(dsr->qual[1].qual[export_itr].stat_clob_val)
       CALL convertspecialchars("X")
       SET strformat = build("<Stat_Clob_Val>",dse_temp_vc_out,"</Stat_Clob_Val>")
      ELSE
       SET strformat = "<Stat_Clob_Val/>"
      ENDIF
      CALL writelinetofile(strformat,1)
      CALL writelinetofile("</VALUE>",1)
    ENDFOR
    CALL writelinetofile("</VALUES>",1)
    CALL writelinetofile("</DM_STAT>",1)
    CALL writelinetofile("</DM_STATS>",1)
    CALL writelinetofile("</DMSTATS>",1)
    SET stat = cclio("CLOSE",frec)
    SET stat = alterlist(resend_files->qual,sequence)
    SET resend_files->qual[sequence].file_name = filename
    CALL echo(build("file: ",filename," created."))
    SET sequence = (sequence+ 1)
   ENDIF
 END ;Subroutine
 SUBROUTINE initialize("x")
   SET stat = initrec(frec)
   SET stat = initrec(resend_files)
   SET sequence = 1
 END ;Subroutine
 SUBROUTINE writelinetofile(line,newline)
   IF (newline=1)
    SET frec->file_buf = build(line,char(13),char(10))
   ENDIF
   SET stat = cclio("PUTS",frec)
   IF (stat=0)
    CALL esmerror("Unable to write to file",esmexit)
   ENDIF
 END ;Subroutine
 SUBROUTINE updateresendtable(filename,batchindex,batchcnt)
  INSERT  FROM dm_stat_resend_retry drr
   SET drr.dm_stat_resend_retry_id = seq(dm_clinical_seq,nextval), drr.file_name = cnvtupper(filename
     ), drr.resend_retry_cnt = - (1),
    drr.ccts_resend_retry_cnt = - (1), drr.batch_index_nbr = batchindex, drr.batch_size_nbr =
    batchcnt,
    drr.resend_retry_dt_tm = cnvtdatetime(curdate,curtime3), drr.updt_id = reqinfo->updt_id, drr
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    drr.updt_task = reqinfo->updt_task, drr.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (error(export_err_msg,0) != 0)
   ROLLBACK
   CALL esmerror(export_err_msg,esmexit)
  ELSE
   COMMIT
  ENDIF
 END ;Subroutine
 SUBROUTINE convertspecialchars("X")
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(0),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(1),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(2),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(3),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(4),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(5),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(6),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(7),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(8),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(9),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(11),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(12),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(14),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(15),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(16),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(17),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(18),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(19),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(20),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(21),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(22),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(23),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(24),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(25),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(26),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(27),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(28),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(29),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(30),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,char(31),"",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,"&","&amp;",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,"<","&lt;",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,">","&gt;",0)
   SET dse_temp_vc_in = replace(dse_temp_vc_in,'"',"&quot;",0)
   SET dse_temp_vc_out = trim(replace(dse_temp_vc_in,"'","&apos;",0))
 END ;Subroutine
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
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 DECLARE ms_snapshot_type = vc WITH protect, constant("CHUNK_CORE_PRIVS.2")
 DECLARE ms_snapshot_num = i4 WITH protect, constant(117)
 DECLARE ms_last_run_time = dq8
 DECLARE ms_this_run_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE ms_snapshot_time = dq8 WITH constant(cnvtdatetime((curdate - 1),0))
 DECLARE chunk_size = i4 WITH noconstant(150000)
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_CORE_PRIVS.2")
 DECLARE dsvm_error(msg=vc) = null
 DECLARE ds_cnt = i4
 DECLARE isfullrun = i4 WITH protect, noconstant(0)
 DECLARE min_id = f8 WITH protect, noconstant(0)
 DECLARE max_id = f8 WITH protect, noconstant(0)
 DECLARE mn_snapshot_id = f8 WITH protect, noconstant(0)
 DECLARE num_chunks = i4 WITH protect, noconstant(0)
 DECLARE targetnamespace = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name IN ("LAST_RUN_TIME", "LAST_FULL_RUN_TIME", "CHUNK_SIZE")
  HEAD REPORT
   isfullrun = 0
  DETAIL
   IF (di.info_name="LAST_FULL_RUN_TIME")
    IF (((datetimediff(cnvtdatetime(curdate,curtime3),di.info_date) >= 32) OR (day(cnvtdatetime(
      curdate,curtime3))=25)) )
     isfullrun = 1
    ENDIF
   ELSEIF (di.info_name="LAST_RUN_TIME")
    ms_last_run_time = di.info_date
   ELSEIF (di.info_name="CHUNK_SIZE")
    IF (di.info_number >= 10000)
     chunk_size = di.info_number
    ELSE
     CALL echo(build("WARNING: Chunk size too small ( < 10000 ), defaulting to base value of",
      chunk_size))
    ENDIF
   ENDIF
  FOOT REPORT
   IF (isfullrun=1)
    ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_RUN_TIME", di.info_date = cnvtdatetime(
     "01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "LAST_FULL_RUN_TIME", di.info_date =
    cnvtdatetime("01-JAN-1800 00:00:00")
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "CHUNK_SIZE", di.info_number = chunk_size
   WITH nocounter
  ;end insert
  DELETE  FROM dm_info di
   WHERE di.info_domain="DM_STAT_CORE_PRIVS"
  ;end delete
  COMMIT
  SET ms_last_run_time = cnvtdatetime("01-JAN-1800 00:00:00")
  SET isfullrun = 1
 ENDIF
 SET ds_cnt = 1
 SET min_id = 0
 SET max_id = 0
 SET qualcnt = 0
 SET stat_seq = 0
 SET stat = initrec(dsr)
 SELECT INTO "nl:"
  dvsm_min = min(p.privilege_id), dvsm_max = max(p.privilege_id)
  FROM priv_loc_reltn plr,
   privilege p
  PLAN (plr)
   JOIN (p
   WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
    AND p.updt_dt_tm > cnvtdatetime(ms_last_run_time)
    AND p.updt_dt_tm <= cnvtdatetime(ms_this_run_time)
    AND p.privilege_id > 0)
  DETAIL
   min_id = dvsm_min, max_id = dvsm_max, num_chunks = (((max_id - min_id)/ chunk_size)+ 1)
  WITH nocounter
 ;end select
 SET curmin = min_id
 SET curmax = (curmin+ chunk_size)
 FOR (itr = 1 TO num_chunks)
   SELECT INTO "nl:"
    position = plr.position_cd, privilege = p.privilege_cd, priv_value = p.priv_value_cd,
    exception_entity = trim(e.exception_entity_name), exception_value = trim(uar_get_code_display(e
      .exception_id))
    FROM priv_loc_reltn plr,
     privilege p,
     privilege_exception e,
     dummyt d
    PLAN (plr
     WHERE plr.position_cd > 0)
     JOIN (p
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
      AND p.updt_dt_tm > cnvtdatetime(ms_last_run_time)
      AND p.updt_dt_tm <= cnvtdatetime(ms_this_run_time)
      AND p.privilege_id > 0
      AND p.privilege_id >= curmin
      AND p.privilege_id < curmax)
     JOIN (d)
     JOIN (e
     WHERE e.privilege_id=p.privilege_id)
    HEAD REPORT
     IF (size(dsr->qual,5)=0)
      qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
       = ms_snapshot_time,
      dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
     ENDIF
    DETAIL
     IF (mod(ds_cnt,1000)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 999))
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "CHUNK_CORE_PRIVS", dsr->qual[qualcnt].qual[ds_cnt].
     stat_type = 0, dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = p.privilege_id,
     dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].
     stat_clob_val = build(position,"||",privilege,"||",priv_value,
      "||",exception_entity,"||",exception_value), ds_cnt = (ds_cnt+ 1),
     stat_seq = (stat_seq+ 1)
    WITH nocounter, outerjoin = d
   ;end select
   CALL dsvm_error("CHUNK_PREF_MAN - CHUNK_PREF_MAN")
   SET curmin = curmax
   SET curmax = (curmax+ chunk_size)
   IF (ds_cnt >= chunk_size)
    SET stat = alterlist(dsr->qual[1].qual,(ds_cnt - 1))
    IF (isfullrun=0)
     SET targetnamespace = "DAILY"
    ELSE
     SET targetnamespace = "QUARTERLY"
    ENDIF
    CALL writedsrtofile(ms_snapshot_num,targetnamespace)
    SET ds_cnt = 1
    SET qualcnt = 0
    SET stat = initrec(dsr)
   ENDIF
 ENDFOR
 CALL dsvm_error("CHUNK_CORE_PRIVS - CHUNK_CORE_PRIVS")
 IF (size(dsr->qual,5)=0)
  SET qualcnt = (qualcnt+ 1)
  SET stat = alterlist(dsr->qual,qualcnt)
  SET dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
  SET dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
 ENDIF
 SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 1))
 SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = "FILE_COUNT"
 SET dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = sequence
 SET ds_cnt = (ds_cnt+ 1)
 SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = "FULL_RUN_IND"
 IF (isfullrun=1)
  SET dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = 1
  SET targetnamespace = "QUARTERLY"
 ELSE
  SET dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = 0
  SET targetnamespace = "DAILY"
 ENDIF
 CALL writedsrtofile(ms_snapshot_num,targetnamespace)
 CALL dsvm_error("CHUNK_CORE_PRIVS - CHUNK_CORE_PRIVS")
 SET stat = initrec(dsr)
 FOR (filenum = 1 TO size(resend_files->qual,5))
   CALL updateresendtable(resend_files->qual[filenum].file_name,filenum,size(resend_files->qual,5))
 ENDFOR
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(ms_this_run_time)
  WHERE di.info_domain=ms_info_domain
   AND di.info_name="LAST_RUN_TIME"
  WITH nocounter
 ;end update
 IF (isfullrun=1)
  UPDATE  FROM dm_info di
   SET di.info_date = cnvtdatetime(ms_this_run_time)
   WHERE di.info_domain=ms_info_domain
    AND di.info_name="LAST_FULL_RUN_TIME"
   WITH nocounter
  ;end update
 ENDIF
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmreturn)
   GO TO exitscript
  ENDIF
 END ;Subroutine
 COMMIT
#exitscript
END GO
