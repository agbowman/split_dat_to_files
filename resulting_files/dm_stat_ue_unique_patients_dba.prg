CREATE PROGRAM dm_stat_ue_unique_patients:dba
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
 DECLARE dsvm_error(msg=vc) = null
 DECLARE ms_snapshot_type = vc WITH protect, noconstant("")
 DECLARE ms_snapshot_type_daily = vc WITH protect, constant("UE_UNIQUE_PATIENTS.2")
 DECLARE ms_snapshot_type_monthly = vc WITH protect, constant("UE_UNIQUE_PATIENTS_MONTHLY.2")
 DECLARE ms_snapshot_type_quarterly = vc WITH protect, constant("UE_UNIQUE_PATIENTS_QUARTERLY.2")
 DECLARE ms_snapshot_type_yearly = vc WITH protect, constant("UE_UNIQUE_PATIENTS_YEARLY.2")
 DECLARE ms_snapshot_num = i4 WITH protect, noconstant(- (1))
 DECLARE ms_snapshot_num_daily = i4 WITH protect, constant(120)
 DECLARE ms_snapshot_num_monthly = i4 WITH protect, constant(121)
 DECLARE ms_snapshot_num_quarterly = i4 WITH protect, constant(122)
 DECLARE ms_snapshot_num_yearly = i4 WITH protect, constant(123)
 DECLARE ms_snapshot_namespace = vc WITH protect, noconstant("Daily")
 DECLARE ds_cnt = i4
 DECLARE stat_seq = i4
 DECLARE stat_seq2 = i4
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE ds_begin_snapshot = dq8 WITH noconstant(cnvtdatetime((curdate - 1),0))
 DECLARE ds_end_snapshot = dq8 WITH noconstant(cnvtdatetime((curdate - 1),235959))
 DECLARE ms_info_domain = vc WITH constant("DM_STAT_UNIQUE_PATIENTS")
 DECLARE ms_force_monthly = i2 WITH noconstant(0)
 DECLARE ms_force_quarterly = i2 WITH noconstant(0)
 DECLARE ms_force_yearly = i2 WITH noconstant(0)
 DECLARE writechunk("X") = null
 DECLARE break_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=ms_info_domain
   AND di.info_name IN ("FORCE_MONTHLY", "FORCE_QUARTERLY", "FORCE_YEARLY")
  DETAIL
   IF (di.info_name="FORCE_MONTHLY")
    ms_force_monthly = di.info_number
   ELSEIF (di.info_name="FORCE_QUARTERLY")
    ms_force_quarterly = di.info_number
   ELSEIF (di.info_name="FORCE_YEARLY")
    ms_force_yearly = di.info_number
   ENDIF
  WITH nocounter
 ;end select
 UPDATE  FROM dm_info
  SET info_number = 0
  WHERE info_domain=ms_info_domain
   AND info_name="FORCE_MONTHLY"
 ;end update
 UPDATE  FROM dm_info
  SET info_number = 0
  WHERE info_domain=ms_info_domain
   AND info_name="FORCE_QUARTERLY"
 ;end update
 UPDATE  FROM dm_info
  SET info_number = 0
  WHERE info_domain=ms_info_domain
   AND info_name="FORCE_YEARLY"
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "FORCE_MONTHLY", di.info_number = 0
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "FORCE_QUARTERLY", di.info_number = 0
   WITH nocounter
  ;end insert
  INSERT  FROM dm_info di
   SET di.info_domain = ms_info_domain, di.info_name = "FORCE_YEARLY", di.info_number = 0
   WITH nocounter
  ;end insert
  SET ms_force_monthly = 1
  SET ms_force_quarterly = 1
  SET ms_force_yearly = 1
 ENDIF
 COMMIT
 IF (error(error_msg,0) != 0)
  CALL esmerror(error_msg,esmreturn)
 ENDIF
 FOR (idx = 1 TO 4)
   SET break_ind = 0
   CALL initialize("X")
   IF (idx=1)
    SET ms_snapshot_type = ms_snapshot_type_daily
    SET ms_snapshot_num = 120
    SET ms_snapshot_namespace = "DAILY"
    SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
    SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
   ELSEIF (idx=2
    AND ((ms_force_monthly=1) OR (datetimefind(cnvtdatetime(curdate,0),"M","B","B")=cnvtdatetime(
    curdate,0))) )
    SET ms_snapshot_type = ms_snapshot_type_monthly
    SET ms_snapshot_num = 121
    SET ms_snapshot_namespace = "QUARTERLY"
    SET ds_begin_snapshot = datetimefind(cnvtlookbehind("1,M"),"M","B","B")
    SET ds_end_snapshot = datetimefind(cnvtlookbehind("1,M"),"M","E","E")
   ELSEIF (idx=3
    AND ((ms_force_quarterly=1) OR (datetimefind(cnvtdatetime(curdate,0),"Q","B","B")=cnvtdatetime(
    curdate,0))) )
    SET ms_snapshot_type = ms_snapshot_type_quarterly
    SET ms_snapshot_num = 122
    SET ms_snapshot_namespace = "QUARTERLY"
    SET ds_begin_snapshot = datetimefind(cnvtlookbehind("3,M"),"Q","B","B")
    SET ds_end_snapshot = datetimefind(cnvtlookbehind("3,M"),"Q","E","E")
   ELSEIF (idx=4
    AND ((ms_force_yearly=1) OR (datetimefind(cnvtdatetime(curdate,0),"Y","B","B")=cnvtdatetime(
    curdate,0))) )
    SET ms_snapshot_type = ms_snapshot_type_yearly
    SET ms_snapshot_num = 123
    SET ms_snapshot_namespace = "QUARTERLY"
    SET ds_begin_snapshot = datetimefind(cnvtlookbehind("1,Y"),"Y","B","B")
    SET ds_end_snapshot = datetimefind(cnvtlookbehind("1,Y"),"Y","E","E")
   ELSE
    SET break_ind = 1
   ENDIF
   IF (break_ind=0)
    SET ds_cnt = 1
    SET stat_seq = 0
    SELECT INTO "nl:"
     cnt = count(DISTINCT e.person_id)
     FROM encounter e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     HEAD REPORT
      IF (ds_cnt=1)
       qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
       stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
       dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
      ENDIF
      stat_seq = 0
     DETAIL
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS", dsr->qual[qualcnt].qual[ds_cnt].
      stat_number_val = cnt, dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1,
      dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq, ds_cnt = (ds_cnt+ 1), stat_seq = (stat_seq
      + 1)
     FOOT REPORT
      IF (stat_seq=0)
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS", dsr->qual[qualcnt].qual[ds_cnt]
       .stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = 0,
       ds_cnt = (ds_cnt+ 1)
      ELSE
       stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
      ENDIF
     WITH nocounter, nullreport
    ;end select
    CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS")
    CALL writechunk("X")
    SELECT INTO "nl:"
     e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
     cnt = count(DISTINCT e.person_id)
     FROM encounter e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     GROUP BY e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd
     HEAD REPORT
      IF (ds_cnt=1)
       qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
       stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
       dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
      ENDIF
      stat_seq = 0
     DETAIL
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_FAC_VEN", dsr->qual[qualcnt].qual[
      ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",uar_get_code_meaning
       (e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
       "||",e.loc_facility_cd,"||",uar_get_code_display(e.encntr_type_class_cd),"||",
       uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,"||",
       uar_get_code_display(e.encntr_type_cd),
       "||",uar_get_code_meaning(e.encntr_type_cd),"||",e.encntr_type_cd), dsr->qual[qualcnt].qual[
      ds_cnt].stat_number_val = cnt,
      dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
      stat_seq, ds_cnt = (ds_cnt+ 1),
      stat_seq = (stat_seq+ 1)
     FOOT REPORT
      IF (stat_seq=0)
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_FAC_VEN", dsr->qual[qualcnt].
       qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = 0,
       ds_cnt = (ds_cnt+ 1)
      ELSE
       stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
      ENDIF
     WITH nocounter, nullreport
    ;end select
    CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_FAC_VEN")
    CALL writechunk("X")
    SELECT INTO "nl:"
     e.loc_facility_cd, cnt = count(DISTINCT e.person_id)
     FROM encounter e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     GROUP BY e.loc_facility_cd
     HEAD REPORT
      IF (ds_cnt=1)
       qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
       stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
       dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
      ENDIF
      stat_seq = 0
     DETAIL
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_FAC", dsr->qual[qualcnt].qual[
      ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",uar_get_code_meaning
       (e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
       "||",e.loc_facility_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
      dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
      stat_seq, ds_cnt = (ds_cnt+ 1),
      stat_seq = (stat_seq+ 1)
     FOOT REPORT
      IF (stat_seq=0)
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_FAC", dsr->qual[qualcnt].qual[
       ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = 0,
       ds_cnt = (ds_cnt+ 1)
      ELSE
       stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
      ENDIF
     WITH nocounter, nullreport
    ;end select
    CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_FAC")
    CALL writechunk("X")
    SELECT INTO "nl:"
     e.encntr_type_class_cd, e.encntr_type_cd, cnt = count(DISTINCT e.person_id)
     FROM encounter e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     GROUP BY e.encntr_type_class_cd, e.encntr_type_cd
     HEAD REPORT
      IF (ds_cnt=1)
       qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
       stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
       dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
      ENDIF
      stat_seq = 0
     DETAIL
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_VEN", dsr->qual[qualcnt].qual[
      ds_cnt].stat_clob_val = build(uar_get_code_display(e.encntr_type_class_cd),"||",
       uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,
       "||",uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",
       e.encntr_type_cd), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
      dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
      stat_seq, ds_cnt = (ds_cnt+ 1),
      stat_seq = (stat_seq+ 1)
     FOOT REPORT
      IF (stat_seq=0)
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_VEN", dsr->qual[qualcnt].qual[
       ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = 0,
       ds_cnt = (ds_cnt+ 1)
      ELSE
       stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
      ENDIF
     WITH nocounter, nullreport
    ;end select
    CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_VEN")
    CALL writechunk("X")
    IF (((idx=1) OR (idx=2)) )
     SELECT INTO "nl:"
      epr.prsnl_person_id, cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       encntr_prsnl_reltn epr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND epr.encntr_id=e.encntr_id
       AND epr.active_ind=1
       AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY epr.prsnl_person_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER", dsr->qual[
       qualcnt].qual[ds_cnt].stat_clob_val = build(epr.prsnl_person_id), dsr->qual[qualcnt].qual[
       ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER", dsr->qual[
        qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq
         = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_ENCOUNTER")
     CALL writechunk("X")
     SELECT INTO "nl:"
      e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
      epr.encntr_prsnl_r_cd, epr.prsnl_person_id, cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       encntr_prsnl_reltn epr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND epr.encntr_id=e.encntr_id
       AND epr.active_ind=1
       AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
       epr.encntr_prsnl_r_cd, epr.prsnl_person_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_FAC_VEN", dsr
       ->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),
        "||",uar_get_code_meaning(e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
        "||",e.loc_facility_cd,"||",uar_get_code_display(e.encntr_type_class_cd),"||",
        uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,"||",
        uar_get_code_display(e.encntr_type_cd),
        "||",uar_get_code_meaning(e.encntr_type_cd),"||",e.encntr_type_cd,"||",
        uar_get_code_display(epr.encntr_prsnl_r_cd),"||",uar_get_code_meaning(epr.encntr_prsnl_r_cd),
        "||",epr.encntr_prsnl_r_cd,
        "||",epr.prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_FAC_VEN", dsr
        ->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
        stat_seq = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_FAC_VEN")
     CALL writechunk("X")
     SELECT INTO "nl:"
      e.loc_facility_cd, epr.encntr_prsnl_r_cd, epr.prsnl_person_id,
      cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       encntr_prsnl_reltn epr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND epr.encntr_id=e.encntr_id
       AND epr.active_ind=1
       AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY e.loc_facility_cd, epr.encntr_prsnl_r_cd, epr.prsnl_person_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_FAC", dsr->
       qual[qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",
        uar_get_code_meaning(e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
        "||",e.loc_facility_cd,"||",uar_get_code_display(epr.encntr_prsnl_r_cd),"||",
        uar_get_code_meaning(epr.encntr_prsnl_r_cd),"||",epr.encntr_prsnl_r_cd,"||",epr
        .prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_FAC", dsr->
        qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
        stat_seq = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_FAC")
     CALL writechunk("X")
     SELECT INTO "nl:"
      e.encntr_type_class_cd, e.encntr_type_cd, epr.encntr_prsnl_r_cd,
      epr.prsnl_person_id, cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       encntr_prsnl_reltn epr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND epr.encntr_id=e.encntr_id
       AND epr.active_ind=1
       AND epr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY e.encntr_type_class_cd, e.encntr_type_cd, epr.encntr_prsnl_r_cd,
       epr.prsnl_person_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_VEN", dsr->
       qual[qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.encntr_type_class_cd),
        "||",uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,
        "||",uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",
        e.encntr_type_cd,"||",uar_get_code_display(epr.encntr_prsnl_r_cd),"||",uar_get_code_meaning(
         epr.encntr_prsnl_r_cd),
        "||",epr.encntr_prsnl_r_cd,"||",epr.prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].
       stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_VEN", dsr->
        qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
        stat_seq = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_ENCOUNTER_VEN")
     CALL writechunk("X")
     SELECT INTO "nl:"
      ppr.person_prsnl_r_cd, ppr.prsnl_person_id, cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       person_prsnl_reltn ppr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND ppr.person_id=e.person_id
       AND ppr.active_ind=1
       AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY ppr.person_prsnl_r_cd, ppr.prsnl_person_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL", dsr->qual[
       qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(ppr.person_prsnl_r_cd),"||",
        uar_get_code_meaning(ppr.person_prsnl_r_cd),"||",ppr.person_prsnl_r_cd,
        "||",ppr.prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL", dsr->qual[
        qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq
         = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport, orahintcbo("INDEX(ppr XIE2PERSON_PRSNL_RELTN)")
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_PRSNL")
     CALL writechunk("X")
     SELECT INTO "nl:"
      e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
      ppr.person_prsnl_r_cd, ppr.prsnl_person_id, cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       person_prsnl_reltn ppr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND ppr.person_id=e.person_id
       AND ppr.active_ind=1
       AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
       ppr.person_prsnl_r_cd, ppr.prsnl_person_id
      HEAD REPORT
       stat_seq = 0, stat_seq2 = 0
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
      DETAIL
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL_FAC_VEN", dsr->
       qual[qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",
        uar_get_code_meaning(e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
        "||",e.loc_facility_cd,"||",uar_get_code_display(e.encntr_type_class_cd),"||",
        uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,"||",
        uar_get_code_display(e.encntr_type_cd),
        "||",uar_get_code_meaning(e.encntr_type_cd),"||",e.encntr_type_cd,"||",
        uar_get_code_display(ppr.person_prsnl_r_cd),"||",uar_get_code_meaning(ppr.person_prsnl_r_cd),
        "||",ppr.person_prsnl_r_cd,
        "||",ppr.prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1), stat_seq2 = (stat_seq2+ 1)
       IF (mod(stat_seq,50000)=0)
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq2),
        CALL writechunk("X")
       ENDIF
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL_FAC_VEN", dsr->
        qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
        stat_seq = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        IF (size(dsr->qual,5) > 0)
         stat = alterlist(dsr->qual[qualcnt].qual,stat_seq2)
        ENDIF
       ENDIF
      WITH nocounter, nullreport, orahintcbo("INDEX(ppr XIE2PERSON_PRSNL_RELTN)")
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_PRSNL_FAC_VEN")
     IF (size(dsr->qual,5) > 0)
      CALL writechunk("X")
     ENDIF
     SELECT INTO "nl:"
      e.loc_facility_cd, ppr.person_prsnl_r_cd, ppr.prsnl_person_id,
      cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       person_prsnl_reltn ppr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND ppr.person_id=e.person_id
       AND ppr.active_ind=1
       AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY e.loc_facility_cd, ppr.person_prsnl_r_cd, ppr.prsnl_person_id
      HEAD REPORT
       stat_seq = 0, stat_seq2 = 0
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
      DETAIL
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL_FAC", dsr->qual[
       qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",
        uar_get_code_meaning(e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
        "||",e.loc_facility_cd,"||",uar_get_code_display(ppr.person_prsnl_r_cd),"||",
        uar_get_code_meaning(ppr.person_prsnl_r_cd),"||",ppr.person_prsnl_r_cd,"||",ppr
        .prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1), stat_seq2 = (stat_seq2+ 1)
       IF (mod(stat_seq,50000)=0)
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq2),
        CALL writechunk("X")
       ENDIF
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL_FAC", dsr->qual[
        qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq
         = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        IF (size(dsr->qual,5) > 0)
         stat = alterlist(dsr->qual[qualcnt].qual,stat_seq2)
        ENDIF
       ENDIF
      WITH nocounter, nullreport, orahintcbo("INDEX(ppr XIE2PERSON_PRSNL_RELTN)")
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_PRSNL_FAC")
     IF (size(dsr->qual,5) > 0)
      CALL writechunk("X")
     ENDIF
     SELECT INTO "nl:"
      e.encntr_type_class_cd, e.encntr_type_cd, ppr.person_prsnl_r_cd,
      ppr.prsnl_person_id, cnt = count(DISTINCT e.person_id)
      FROM encounter e,
       person_prsnl_reltn ppr
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND ppr.person_id=e.person_id
       AND ppr.active_ind=1
       AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      GROUP BY e.encntr_type_class_cd, e.encntr_type_cd, ppr.person_prsnl_r_cd,
       ppr.prsnl_person_id
      HEAD REPORT
       stat_seq = 0, stat_seq2 = 0
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
      DETAIL
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL_VEN", dsr->qual[
       qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.encntr_type_class_cd),"||",
        uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,
        "||",uar_get_code_display(e.encntr_type_cd),"||",uar_get_code_meaning(e.encntr_type_cd),"||",
        e.encntr_type_cd,"||",uar_get_code_display(ppr.person_prsnl_r_cd),"||",uar_get_code_meaning(
         ppr.person_prsnl_r_cd),
        "||",ppr.person_prsnl_r_cd,"||",ppr.prsnl_person_id), dsr->qual[qualcnt].qual[ds_cnt].
       stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1), stat_seq2 = (stat_seq2+ 1)
       IF (mod(stat_seq,50000)=0)
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq2),
        CALL writechunk("X")
       ENDIF
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_PATIENTS_PROVIDER_PRSNL_VEN", dsr->qual[
        qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq
         = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        IF (size(dsr->qual,5) > 0)
         stat = alterlist(dsr->qual[qualcnt].qual,stat_seq2)
        ENDIF
       ENDIF
      WITH nocounter, nullreport, orahintcbo("INDEX(ppr XIE2PERSON_PRSNL_RELTN)")
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_PATIENTS_PROVIDER_PRSNL_VEN")
     IF (size(dsr->qual,5) > 0)
      CALL writechunk("X")
     ENDIF
    ENDIF
    IF (idx=1)
     SELECT INTO "nl:"
      e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
      cnt = count(e.encntr_id)
      FROM encounter e
      WHERE e.reg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
      GROUP BY e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_REGISTRATIONS_FAC_VEN", dsr->qual[qualcnt]
       .qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",
        uar_get_code_meaning(e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
        "||",e.loc_facility_cd,"||",uar_get_code_display(e.encntr_type_class_cd),"||",
        uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,"||",
        uar_get_code_display(e.encntr_type_cd),
        "||",uar_get_code_meaning(e.encntr_type_cd),"||",e.encntr_type_cd), dsr->qual[qualcnt].qual[
       ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "UNIQUE_REGISTRATIONS_FAC_VEN", dsr->qual[qualcnt
        ].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - UNIQUE_REGISTRATIONS_FAC_VEN")
     CALL writechunk("X")
     SELECT INTO "nl:"
      e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
      pl.person_id, cnt = count(e.encntr_id)
      FROM sch_appt sa,
       sch_event_patient sep,
       sch_resource sr,
       encounter e,
       prsnl pl
      WHERE sa.beg_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND sa.end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
       AND sa.state_meaning IN ("CONFIRMED", "CHECKED IN", "CHECKED OUT")
       AND sa.role_meaning != "PATIENT"
       AND (sep.sch_event_id=(sa.sch_event_id+ 0))
       AND sep.version_dt_tm >= cnvtdatetime(ds_begin_snapshot)
       AND ((sep.encntr_id+ 0) > 0)
       AND e.encntr_id=sep.encntr_id
       AND sa.resource_cd=sr.resource_cd
       AND pl.person_id=sr.person_id
      GROUP BY e.loc_facility_cd, e.encntr_type_class_cd, e.encntr_type_cd,
       pl.person_id
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime((curdate - 1),0),
        dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
       ENDIF
       stat_seq = 0
      DETAIL
       IF (mod(ds_cnt,10)=1)
        stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
       ENDIF
       dsr->qual[qualcnt].qual[ds_cnt].stat_name = "APPOINTMENTS_PROVIDER_RESOURCE_FAC_VEN", dsr->
       qual[qualcnt].qual[ds_cnt].stat_clob_val = build(uar_get_code_display(e.loc_facility_cd),"||",
        uar_get_code_meaning(e.loc_facility_cd),"||",uar_get_code_description(e.loc_facility_cd),
        "||",e.loc_facility_cd,"||",uar_get_code_display(e.encntr_type_class_cd),"||",
        uar_get_code_meaning(e.encntr_type_class_cd),"||",e.encntr_type_class_cd,"||",
        uar_get_code_display(e.encntr_type_cd),
        "||",uar_get_code_meaning(e.encntr_type_cd),"||",e.encntr_type_cd,"||",
        pl.person_id), dsr->qual[qualcnt].qual[ds_cnt].stat_number_val = cnt,
       dsr->qual[qualcnt].qual[ds_cnt].stat_type = 1, dsr->qual[qualcnt].qual[ds_cnt].stat_seq =
       stat_seq, ds_cnt = (ds_cnt+ 1),
       stat_seq = (stat_seq+ 1)
      FOOT REPORT
       IF (stat_seq=0)
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "APPOINTMENTS_PROVIDER_RESOURCE_FAC_VEN", dsr->
        qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", dsr->qual[qualcnt].qual[ds_cnt].
        stat_seq = 0,
        ds_cnt = (ds_cnt+ 1)
       ELSE
        stat = alterlist(dsr->qual[qualcnt].qual,stat_seq)
       ENDIF
      WITH nocounter, nullreport
     ;end select
     CALL dsvm_error("UE_UNIQUE_PATIENTS - APPOINTMENTS_PROVIDER_RESOURCE_FAC_VEN")
     CALL writechunk("X")
    ENDIF
    SET stat = alterlist(dsr->qual,1)
    SET dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
    SET dsr->qual[qualcnt].snapshot_type = ms_snapshot_type
    SET stat = alterlist(dsr->qual[1].qual,2)
    SET dsr->qual[1].qual[1].stat_name = "DATA_RANGE_START_DATE"
    SET dsr->qual[1].qual[1].stat_str_val = format(ds_begin_snapshot,"YYYYMMDDHHMMSS;;D")
    SET dsr->qual[1].qual[1].stat_seq = 0
    SET dsr->qual[1].qual[2].stat_name = "FILE_COUNT"
    SET dsr->qual[1].qual[2].stat_number_val = sequence
    SET dsr->qual[1].qual[2].stat_seq = 0
    CALL writechunk("X")
    FOR (filenum = 1 TO size(resend_files->qual,5))
      CALL updateresendtable(resend_files->qual[filenum].file_name,filenum,size(resend_files->qual,5)
       )
    ENDFOR
   ENDIF
 ENDFOR
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmexit)
  ENDIF
 END ;Subroutine
 SUBROUTINE writechunk("X")
   CALL writedsrtofile(ms_snapshot_num,ms_snapshot_namespace)
   SET ds_cnt = 1
   SET qualcnt = 0
   SET stat_seq2 = 0
   SET stat = initrec(dsr)
 END ;Subroutine
#exit_program
END GO
