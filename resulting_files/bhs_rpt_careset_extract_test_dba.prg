CREATE PROGRAM bhs_rpt_careset_extract_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Run type:" = "UPDATE",
  "Number of days to look back for updates:" = "0",
  'output (enter either: email address, "OpsJob", or leave blank for screen)' = "",
  "Synonym Report (Only works in opsJob or email mode):" = "0"
  WITH outdev, runtype, days,
  email, synrpt
 DECLARE count1 = i4
 DECLARE tline = vc
 DECLARE lookbackdays = i4
 DECLARE indx = i4
 DECLARE num = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE pcnt = i4 WITH protect
 DECLARE ecnt = i4 WITH protect
 DECLARE actual_size = i4 WITH protect
 DECLARE expand_total = i4 WITH protect
 DECLARE expand_start = i4 WITH noconstant(1), protect
 DECLARE expand_stop = i4 WITH noconstant(200), protect
 DECLARE primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE mock = f8 WITH protect, constant(uar_get_code_by("DISPLAY",220,"MOCK"))
 DECLARE label = f8 WITH protect, constant(uar_get_code_by("MEANING",6030,"LABEL"))
 DECLARE note = f8 WITH protect, constant(uar_get_code_by("MEANING",6030,"NOTE"))
 DECLARE orderable = f8 WITH protect, constant(uar_get_code_by("MEANING",6030,"ORDERABLE"))
 DECLARE dclcom = vc WITH noconstant(" ")
 RECORD careset(
   1 qual[*]
     2 catalog_cd = f8
     2 locations = vc
     2 hide = i4
 )
 DECLARE email_ind = i4
 DECLARE var_output = vc WITH noconstant(" ")
 DECLARE filename_in = vc WITH noconstant(" ")
 DECLARE filename_out = vc WITH noconstant(" ")
 SET email_ind = 4
 SET lookbackdays = cnvtint( $DAYS)
 IF (((findstring("@", $EMAIL) > 0) OR (cnvtupper( $EMAIL)="OPSJOB")) )
  IF (findstring("@", $EMAIL) > 0)
   SET email_ind = 1
  ENDIF
  SET var_output = concat(trim("ce"),format(cnvtdatetime(curdate,curtime3),"MMDDYYYY;;d"))
  SET filedelimiter1 = '"'
  SET filedelimiter2 = ","
 ELSE
  SET var_output =  $OUTDEV
  SET email_ind = 0
  SET filedelimiter1 = ""
  SET filedelimiter2 = ""
 ENDIF
 SET addrec = 0
 CALL echo("Find Order Sets")
 SELECT INTO "NL:"
  FROM order_catalog oc,
   cs_component cc,
   order_sentence os,
   order_catalog_synonym ocs,
   order_catalog_synonym ocs1,
   long_text lt,
   long_text lt2
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=3398257
    AND oc.orderable_type_flag=6
    AND oc.catalog_cd > 0)
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(cc.comp_id)
    AND ocs.active_ind=outerjoin(1))
   JOIN (ocs1
   WHERE ocs1.catalog_cd=outerjoin(ocs.catalog_cd)
    AND ocs1.mnemonic_type_cd=outerjoin(primary)
    AND ocs1.active_ind=outerjoin(1)
    AND ocs1.synonym_id != outerjoin(ocs.synonym_id))
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id)
    AND os.order_sentence_id > 0)
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(cc.long_text_id)
    AND lt.active_ind=outerjoin(1))
   JOIN (lt2
   WHERE lt2.long_text_id=outerjoin(os.ord_comment_long_text_id)
    AND lt2.active_ind=outerjoin(1))
  ORDER BY oc.catalog_cd
  HEAD REPORT
   stat = alterlist(careset->qual,100), count1 = 0
  HEAD oc.catalog_cd
   addrec = 0
  DETAIL
   IF (((( $RUNTYPE IN ("ALL"))) OR (( $RUNTYPE IN ("UPDATE"))
    AND ((cc.updt_dt_tm >= cnvtdatetime((curdate - lookbackdays),000000)) OR (((os.updt_dt_tm >=
   cnvtdatetime((curdate - lookbackdays),000000)) OR (((ocs.updt_dt_tm >= cnvtdatetime((curdate -
    lookbackdays),000000)) OR (((ocs1.updt_dt_tm >= cnvtdatetime((curdate - lookbackdays),000000))
    OR (((lt.updt_dt_tm >= cnvtdatetime((curdate - lookbackdays),000000)) OR (lt2.updt_dt_tm >=
   cnvtdatetime((curdate - lookbackdays),000000))) )) )) )) )) )) )
    addrec = 1
   ENDIF
  FOOT  oc.catalog_cd
   IF (addrec=1)
    count1 = (count1+ 1)
    IF (mod(count1,100)=1
     AND count1 != 1)
     stat = alterlist(careset->qual,(count1+ 99))
    ENDIF
    careset->qual[count1].catalog_cd = oc.catalog_cd
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(careset->qual,count1)
 CALL echorecord(careset)
 CALL echo(build("COUNT SIZE:",count1))
 SET actual_size = count1
 IF (mod(actual_size,200) != 0)
  SET expand_total = (actual_size+ (200 - mod(actual_size,200)))
  SET stat = alterlist(careset->qual,expand_total)
  FOR (idx = (actual_size+ 1) TO expand_total)
    SET careset->qual[idx].catalog_cd = careset->qual[actual_size].catalog_cd
  ENDFOR
 ELSE
  SET expand_total = actual_size
 ENDIF
 CALL echo("Locations")
 SET faccnt = 0
 SELECT INTO "NL:"
  ocs.catalog_cd, location = uar_get_code_display(ofr.facility_cd)
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr,
   (dummyt d  WITH seq = value((expand_total/ 200)))
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ 200)))
    AND assign(expand_stop,(expand_start+ 199)))
   JOIN (oc
   WHERE expand(num,expand_start,expand_stop,oc.catalog_cd,careset->qual[num].catalog_cd))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND ocs.mnemonic_type_cd=primary)
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id))
  ORDER BY ocs.catalog_cd, location
  HEAD ocs.catalog_cd
   idx = locateval(indx,1,actual_size,ocs.catalog_cd,careset->qual[indx].catalog_cd), faccnt = 0,
   careset->qual[idx].hide = ocs.hide_flag
  DETAIL
   CALL echo(ofr.facility_cd)
   IF (ofr.synonym_id > 0
    AND ofr.facility_cd != mock)
    faccnt = (faccnt+ 1)
    IF (ofr.facility_cd=0)
     careset->qual[idx].locations = "All"
    ELSE
     IF (faccnt=1)
      careset->qual[idx].locations = location
     ELSE
      careset->qual[idx].locations = concat(careset->qual[idx].locations,", ",location)
     ENDIF
    ENDIF
   ENDIF
  FOOT  oc.catalog_cd
   IF (faccnt=0)
    careset->qual[idx].locations = "MOCK"
   ENDIF
  WITH nocounter
 ;end select
 SET nstart = 1
 CALL echorecord(careset)
 SET stat = alterlist(careset->qual,actual_size)
 IF (textlen(trim( $EMAIL,3)) <= 0)
  CALL echo("MINE display")
  SELECT INTO value(var_output)
   carsetactiveind = oc.active_ind, caresethidden = careset->qual[d.seq].hide, cc.comp_seq,
   catalog_cd = oc.catalog_cd, activity_type = uar_get_code_display(oc.activity_type_cd),
   caresetupdtdttm = format(cc.updt_dt_tm,";;q"),
   desc = check(substring(1,200,trim(oc.primary_mnemonic,3))), orderablehiddenoutsideofcaresets = ocs
   .hide_flag, default_checked = cc.include_exclude_ind,
   required = cc.required_ind, comp_label = check(substring(1,40,trim(cc.comp_label,3))),
   comp_type_cd = check(substring(1,100,uar_get_code_display(cc.comp_type_cd))),
   cc.long_text_id, long_text = check(substring(1,500,lt.long_text)), orderable_synonym_id = ocs
   .synonym_id,
   mnemonic = check(substring(1,100,ocs.mnemonic)), mnemonicdisplay = substring(1,200,
    IF (ocs1.synonym_id > 0) concat(trim(ocs1.mnemonic,3),"(",trim(ocs.mnemonic,3),")")
    ELSE check(trim(ocs.mnemonic,3))
    ENDIF
    ), display_line = check(substring(1,200,trim(os.order_sentence_display_line,3))),
   comment = check(substring(1,500,lt2.long_text)), locations = check(substring(1,400,careset->qual[d
     .seq].locations)), updatedttime =
   IF (cc.comp_type_cd=label) format(cc.updt_dt_tm,";;q")
   ELSEIF (cc.comp_type_cd=note) format(lt.updt_dt_tm,";;q")
   ELSEIF (cc.comp_type_cd=orderable) format(greatest(os.updt_dt_tm,lt2.updt_dt_tm),";;q")
   ELSE "error"
   ENDIF
   ,
   cc.*, d = "@@@@@@", os.*
   FROM order_catalog oc,
    cs_component cc,
    order_sentence os,
    order_catalog_synonym ocs,
    order_catalog_synonym ocs1,
    long_text lt,
    long_text lt2,
    (dummyt d  WITH seq = size(careset->qual,5)),
    dummyt d2
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=careset->qual[d.seq].catalog_cd)
     AND oc.catalog_cd > 0)
    JOIN (cc
    WHERE cc.catalog_cd=oc.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=outerjoin(cc.comp_id)
     AND ocs.active_ind=outerjoin(1))
    JOIN (ocs1
    WHERE ocs1.catalog_cd=outerjoin(ocs.catalog_cd)
     AND ocs1.mnemonic_type_cd=outerjoin(primary)
     AND ocs1.active_ind=outerjoin(1)
     AND ocs1.synonym_id != outerjoin(ocs.synonym_id))
    JOIN (os
    WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(cc.long_text_id)
     AND lt.active_ind=outerjoin(1))
    JOIN (lt2
    WHERE lt2.long_text_id=outerjoin(os.ord_comment_long_text_id)
     AND lt2.active_ind=outerjoin(1))
    JOIN (d2
    WHERE ((ocs.mnemonic_type_cd > 0
     AND os.order_sentence_id > 0) OR (os.order_sentence_id=0
     AND cc.catalog_cd > 0)) )
   ORDER BY oc.primary_mnemonic, cc.comp_seq
   WITH format, check, pcformat(value(filedelimiter1),value(filedelimiter2))
  ;end select
 ELSE
  CALL echo("file")
  SELECT INTO concat(var_output,".csv")
   oc.primary_mnemonic, cc.comp_seq, comment1 = trim(substring(1,500,lt2.long_text),3),
   longtext1 = trim(substring(1,500,lt.long_text),3)
   FROM order_catalog oc,
    cs_component cc,
    order_sentence os,
    order_catalog_synonym ocs,
    order_catalog_synonym ocs1,
    long_text lt,
    long_text lt2,
    (dummyt d  WITH seq = actual_size)
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=careset->qual[d.seq].catalog_cd)
     AND oc.catalog_cd > 0)
    JOIN (cc
    WHERE cc.catalog_cd=oc.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=outerjoin(cc.comp_id)
     AND ocs.active_ind=outerjoin(1))
    JOIN (ocs1
    WHERE ocs1.catalog_cd=outerjoin(ocs.catalog_cd)
     AND ocs1.mnemonic_type_cd=outerjoin(primary)
     AND ocs1.active_ind=outerjoin(1)
     AND ocs1.synonym_id != outerjoin(ocs.synonym_id))
    JOIN (os
    WHERE os.order_sentence_id=outerjoin(cc.order_sentence_id))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(cc.long_text_id)
     AND lt.active_ind=outerjoin(1))
    JOIN (lt2
    WHERE lt2.long_text_id=outerjoin(os.ord_comment_long_text_id)
     AND lt2.active_ind=outerjoin(1))
   ORDER BY oc.primary_mnemonic, cc.comp_seq
   HEAD REPORT
    tline = build(char(34),"careSetHiddenInd",char(34),char(44),char(34),
     "comp_seq",char(34),char(44),char(34),"catalog_cd",
     char(34),char(44),char(34),"activity_type",char(34),
     char(44),char(34),"desc",char(34),char(44),
     char(34),"careSetUpdtDtTm",char(34),char(44),char(34),
     "orderableHiddenOutsideofCareSets",char(34),char(44),char(34),"Default_checked",
     char(34),char(44),char(34),"required",char(34),
     char(44),char(34),"comp_label",char(34),char(44),
     char(34),"comp_type_cd",char(34),char(44),char(34),
     "long_text_id",char(34),char(44),char(34),"long_text",
     char(34),char(44),char(34),"orderable_synonym_id",char(34),
     char(44),char(34),"mnemonic",char(34),char(44),
     char(34),"mnemonicDisplay",char(34),char(44),char(34),
     "display_line",char(34),char(44),char(34),"comment",
     char(34),char(44),char(34),"locations",char(34),
     char(44),char(34),"updateDtTime",char(34),char(44)), col 0, tline,
    row + 1
   HEAD oc.primary_mnemonic
    stat = 0
   HEAD cc.comp_seq
    stat = 0
   DETAIL
    tline = build(careset->qual[d.seq].hide,char(44),cc.comp_seq,char(44),oc.catalog_cd,
     char(44),char(34),uar_get_code_display(oc.activity_type_cd),char(34),char(44),
     char(34),check(trim(oc.primary_mnemonic,3)),char(34),char(44),char(34),
     format(cc.updt_dt_tm,";;q"),char(34),char(44),ocs.hide_flag,char(44),
     cc.include_exclude_ind,char(44),cc.required_ind,char(44),char(34),
     check(trim(replace(cc.comp_label,char(34),""),3)),char(34),char(44),char(34),check(trim(
       uar_get_code_display(cc.comp_type_cd),3)),
     char(34),char(44),cc.long_text_id,char(44),char(34),
     trim(check(replace(longtext1,char(34),"")),3),char(34),char(44),ocs.synonym_id,char(44),
     char(34),check(trim(ocs.mnemonic,3)),char(34),char(44),char(34),
     IF (ocs1.synonym_id > 0) concat(trim(ocs1.mnemonic,3),"(",trim(ocs.mnemonic,3),")")
     ELSE check(trim(ocs.mnemonic,3))
     ENDIF
     ,char(34),char(44),char(34),check(trim(replace(os.order_sentence_display_line,char(34),""),3)),
     char(34),char(44),char(34),trim(check(replace(comment1,char(34),"")),3),char(34),
     char(44),char(34),careset->qual[d.seq].locations,char(34),char(44),
     char(34),
     IF (cc.comp_type_cd=label) format(cc.updt_dt_tm,";;q")
     ELSEIF (cc.comp_type_cd=note) format(lt.updt_dt_tm,";;q")
     ELSEIF (cc.comp_type_cd=orderable) format(greatest(os.updt_dt_tm,lt2.updt_dt_tm),";;q")
     ELSE "error"
     ENDIF
     ,char(34),char(44)), col 0, tline,
    row + 1
   WITH maxcol = 32000, format = variable, formfeed = none,
    check
  ;end select
 ENDIF
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat("No data found"), msg2 = concat("try again"), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_program
 ENDIF
 IF (cnvtupper( $EMAIL)="OPSJOB")
  SET dclcom = concat("mv ",var_output,".csv careset.txt")
  CALL echo(dclcom)
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ","careset.txt",
   " 172.25.23.11 extracts extracts /u01/home/extracts/knowmgmt")
  SET status = 0
  SET len = size(trim(dclcom))
  CALL dcl(dclcom,len,status)
  CALL echo(build("status: ",status))
 ELSEIF (email_ind=1)
  SET filename_in = concat(trim(var_output),".csv")
  SET email_address = trim( $EMAIL)
  SET filename_out = concat(var_output,".csv")
  CALL echo("EMAIL FILE")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out,email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(filename_in," will be sent to -"), msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ENDIF
 IF (( $SYNRPT="1"))
  CALL echo("Create syn_extract report")
  SET var_output = concat(trim("syn"),format(cnvtdatetime(curdate,curtime3),"MMDD;;d"))
  SELECT INTO value(var_output)
   oc.catalog_cd, ocs.mnemonic, ocs.active_ind,
   mnemonic_type_cd = uar_get_code_display(ocs.mnemonic_type_cd), synonym_updt_dt_tm = format(ocs
    .updt_dt_tm,";;q")
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    (dummyt d  WITH seq = actual_size)
   PLAN (d)
    JOIN (oc
    WHERE (oc.catalog_cd=careset->qual[d.seq].catalog_cd)
     AND oc.catalog_cd > 0)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd)
   WITH format, check, pcformat(value(filedelimiter1),value(filedelimiter2))
  ;end select
  IF (cnvtupper( $EMAIL)="OPSJOB")
   SET dclcom = concat("mv ",var_output,".dat synonym.txt")
   CALL echo(dclcom)
   SET status = 0
   SET len = size(trim(dclcom))
   CALL dcl(dclcom,len,status)
   SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ","synonym.txt",
    " 172.25.23.11 extracts extracts /u01/home/extracts/knowmgmt")
   SET status = 0
   SET len = size(trim(dclcom))
   CALL dcl(dclcom,len,status)
   CALL echo(build("status: ",status))
  ELSEIF (email_ind=1)
   SET filename_in = trim(var_output)
   SET email_address = trim( $EMAIL)
   SET filename_out = concat(var_output,".csv")
   CALL emailfile(concat(filename_in,".dat"),filename_out,email_address,curprog,0)
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = concat(var_output,".csv will be sent to -"), msg2 = concat("   ", $EMAIL), col 0,
     "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
     "{F/1}{CPI/9}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1,
     row + 2, msg2
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
 ENDIF
#exit_program
END GO
