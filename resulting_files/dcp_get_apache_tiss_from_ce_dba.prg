CREATE PROGRAM dcp_get_apache_tiss_from_ce:dba
 DECLARE ce_tiss_max = i2 WITH constant(95)
 DECLARE found_tiss_none = i2 WITH noconstant(0)
 DECLARE found_real_tiss = i2 WITH noconstant(0)
 RECORD tiss_list(
   1 list[ce_tiss_max]
     2 code_value = f8
     2 tiss_name = vc
     2 tiss_num = i4
     2 ce_cd = f8
     2 acttx_ind = i2
 )
 RECORD ce_tiss_event(
   1 list[*]
     2 code_value = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 tiss_cd = f8
     2 tiss_cdf = vc
     2 acttx_ind = i2
     2 tiss_none_ind = i2
 )
 DECLARE tce_meaning_code(p1,p2) = f8
 DECLARE tiss_cnt = i4 WITH noconstant(0)
 DECLARE parserstring = vc
 DECLARE found_act = i4 WITH noconstant(0)
 DECLARE found_nonact = i4 WITH noconstant(0)
 DECLARE ce_tiss_cnt = i4 WITH noconstant(0)
 DECLARE inerror_cd = f8 WITH noconstant(0.0)
 DECLARE tce_num = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE rat_id = f8 WITH noconstant(0.0)
 DECLARE tce_cc_day = i4 WITH noconstant(0)
 DECLARE prev_acttx_today_ind = i2 WITH noconstant(- (1))
 DECLARE new_acttx_today_ind = i2 WITH noconstant(- (1))
 DECLARE prev_paline_today_ind = i2 WITH noconstant(- (1))
 DECLARE new_paline_today_ind = i2 WITH noconstant(- (1))
 DECLARE prev_vent_today_ind = i2 WITH noconstant(- (1))
 DECLARE new_vent_today_ind = i2 WITH noconstant(- (1))
 DECLARE found_none = i2 WITH noconstant(- (1))
 DECLARE none_code_value = f8 WITH noconstant(0.0)
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM load_tiss_items_to_arrays TO load_tiss_items_to_arrays_exit
 CALL echo(build("parameters->Accept_TISS_ActTx_IF_ind=",parameters->accept_tiss_acttx_if_ind))
 CALL echo(build("parameters->Accept_TISS_NonActTx_IF_ind=",parameters->accept_tiss_nonacttx_if_ind))
 IF ((((parameters->accept_tiss_acttx_if_ind=1)) OR ((parameters->accept_tiss_nonacttx_if_ind=1))) )
  EXECUTE FROM check_for_none TO check_for_none_exit
  EXECUTE FROM delete_tiss_items TO delete_tiss_items_exit
  EXECUTE FROM load_tiss_items TO load_tiss_items_exit
  CALL echo(build("CE_TISS_CNT=",ce_tiss_cnt))
  IF (ce_tiss_cnt > 0)
   EXECUTE FROM get_cc_day TO get_cc_day_exit
   EXECUTE FROM write_ce_tiss_to_rat TO write_ce_tiss_to_rat_exit
   IF (found_none=1)
    EXECUTE FROM inactivate_tiss_none TO inactivate_tiss_none_exit
   ENDIF
   EXECUTE FROM change_rad_flags_as_needed TO change_rad_flags_as_needed_exit
  ENDIF
 ENDIF
 GO TO 9999_exit_program
 SUBROUTINE tce_meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET inerror_cd = tce_meaning_code(8,"INERROR")
#1099_initialize_exit
#load_tiss_items_to_arrays
 CALL echo("loading all tiss items to arrays")
 SELECT INTO "nl:"
  FROM code_value cv1
  WHERE cv1.code_set=29747
   AND cv1.active_ind=1
  ORDER BY cv1.collation_seq
  HEAD REPORT
   tiss_cnt = 0
  DETAIL
   act_flag = "Z", tiss_cnt = (tiss_cnt+ 1), act_flag = substring(1,1,cv1.definition)
   IF (cv1.collation_seq=0)
    none_code_value = cv1.code_value, tiss_list->list[95].code_value = cv1.code_value, tiss_list->
    list[95].tiss_name = cv1.cdf_meaning,
    tiss_list->list[95].tiss_num = cv1.collation_seq, tiss_list->list[95].ce_cd = 0.0
   ELSE
    tiss_list->list[cv1.collation_seq].code_value = cv1.code_value, tiss_list->list[cv1.collation_seq
    ].tiss_name = cv1.cdf_meaning, tiss_list->list[cv1.collation_seq].tiss_num = cv1.collation_seq,
    tiss_list->list[cv1.collation_seq].ce_cd = 0.0
   ENDIF
   IF (act_flag="Y")
    tiss_list->list[cv1.collation_seq].acttx_ind = 1
   ELSE
    tiss_list->list[cv1.collation_seq].acttx_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 IF ((parameters->accept_tiss_acttx_if_ind=1))
  SET tiss_list->list[1].ce_cd = uar_get_code_by_cki("CKI.EC!8133")
  SET tiss_list->list[2].ce_cd = uar_get_code_by_cki("CKI.EC!8134")
  SET tiss_list->list[3].ce_cd = uar_get_code_by_cki("CKI.EC!8135")
  SET tiss_list->list[4].ce_cd = uar_get_code_by_cki("CKI.EC!8136")
  SET tiss_list->list[5].ce_cd = uar_get_code_by_cki("CKI.EC!8137")
  SET tiss_list->list[6].ce_cd = uar_get_code_by_cki("CKI.EC!8138")
  SET tiss_list->list[7].ce_cd = uar_get_code_by_cki("CKI.EC!8139")
  SET tiss_list->list[8].ce_cd = uar_get_code_by_cki("CKI.EC!8140")
  SET tiss_list->list[9].ce_cd = uar_get_code_by_cki("CKI.EC!8141")
  SET tiss_list->list[10].ce_cd = uar_get_code_by_cki("CKI.EC!8142")
  SET tiss_list->list[11].ce_cd = uar_get_code_by_cki("CKI.EC!8143")
  SET tiss_list->list[12].ce_cd = uar_get_code_by_cki("CKI.EC!8144")
  SET tiss_list->list[13].ce_cd = uar_get_code_by_cki("CKI.EC!8145")
  SET tiss_list->list[14].ce_cd = uar_get_code_by_cki("CKI.EC!8146")
  SET tiss_list->list[15].ce_cd = uar_get_code_by_cki("CKI.EC!8147")
  SET tiss_list->list[16].ce_cd = uar_get_code_by_cki("CKI.EC!8148")
  SET tiss_list->list[17].ce_cd = uar_get_code_by_cki("CKI.EC!8149")
  SET tiss_list->list[18].ce_cd = uar_get_code_by_cki("CKI.EC!8150")
  SET tiss_list->list[19].ce_cd = uar_get_code_by_cki("CKI.EC!8151")
  SET tiss_list->list[20].ce_cd = uar_get_code_by_cki("CKI.EC!8152")
  SET tiss_list->list[21].ce_cd = uar_get_code_by_cki("CKI.EC!8153")
  SET tiss_list->list[22].ce_cd = uar_get_code_by_cki("CKI.EC!8154")
  SET tiss_list->list[23].ce_cd = uar_get_code_by_cki("CKI.EC!8155")
  SET tiss_list->list[24].ce_cd = uar_get_code_by_cki("CKI.EC!8156")
  SET tiss_list->list[25].ce_cd = uar_get_code_by_cki("CKI.EC!8157")
  SET tiss_list->list[26].ce_cd = uar_get_code_by_cki("CKI.EC!8158")
  SET tiss_list->list[27].ce_cd = uar_get_code_by_cki("CKI.EC!8159")
  SET tiss_list->list[28].ce_cd = uar_get_code_by_cki("CKI.EC!8160")
  SET tiss_list->list[29].ce_cd = uar_get_code_by_cki("CKI.EC!8161")
  SET tiss_list->list[30].ce_cd = uar_get_code_by_cki("CKI.EC!8162")
  SET tiss_list->list[31].ce_cd = uar_get_code_by_cki("CKI.EC!8163")
  SET tiss_list->list[32].ce_cd = uar_get_code_by_cki("CKI.EC!8164")
  SET tiss_list->list[33].ce_cd = uar_get_code_by_cki("CKI.EC!8165")
  SET tiss_list->list[92].ce_cd = uar_get_code_by_cki("CKI.EC!8223")
  SET tiss_list->list[93].ce_cd = uar_get_code_by_cki("CKI.EC!8224")
  SET tiss_list->list[94].ce_cd = uar_get_code_by_cki("CKI.EC!8225")
  SET tiss_list->list[95].ce_cd = uar_get_code_by_cki("CKI.EC!9399")
 ENDIF
 IF ((parameters->accept_tiss_nonacttx_if_ind=1))
  SET tiss_list->list[34].ce_cd = uar_get_code_by_cki("CKI.EC!8166")
  SET tiss_list->list[35].ce_cd = uar_get_code_by_cki("CKI.EC!8167")
  SET tiss_list->list[36].ce_cd = uar_get_code_by_cki("CKI.EC!8168")
  SET tiss_list->list[37].ce_cd = uar_get_code_by_cki("CKI.EC!8169")
  SET tiss_list->list[38].ce_cd = uar_get_code_by_cki("CKI.EC!8170")
  SET tiss_list->list[39].ce_cd = uar_get_code_by_cki("CKI.EC!8171")
  SET tiss_list->list[40].ce_cd = uar_get_code_by_cki("CKI.EC!8172")
  SET tiss_list->list[41].ce_cd = uar_get_code_by_cki("CKI.EC!8173")
  SET tiss_list->list[42].ce_cd = uar_get_code_by_cki("CKI.EC!8174")
  SET tiss_list->list[43].ce_cd = uar_get_code_by_cki("CKI.EC!8175")
  SET tiss_list->list[44].ce_cd = uar_get_code_by_cki("CKI.EC!8176")
  SET tiss_list->list[45].ce_cd = uar_get_code_by_cki("CKI.EC!8177")
  SET tiss_list->list[46].ce_cd = uar_get_code_by_cki("CKI.EC!8178")
  SET tiss_list->list[47].ce_cd = uar_get_code_by_cki("CKI.EC!8179")
  SET tiss_list->list[48].ce_cd = uar_get_code_by_cki("CKI.EC!8180")
  SET tiss_list->list[49].ce_cd = uar_get_code_by_cki("CKI.EC!8181")
  SET tiss_list->list[50].ce_cd = uar_get_code_by_cki("CKI.EC!8182")
  SET tiss_list->list[51].ce_cd = uar_get_code_by_cki("CKI.EC!8183")
  SET tiss_list->list[52].ce_cd = uar_get_code_by_cki("CKI.EC!8184")
  SET tiss_list->list[53].ce_cd = uar_get_code_by_cki("CKI.EC!8185")
  SET tiss_list->list[54].ce_cd = uar_get_code_by_cki("CKI.EC!8186")
  SET tiss_list->list[55].ce_cd = uar_get_code_by_cki("CKI.EC!8187")
  SET tiss_list->list[56].ce_cd = uar_get_code_by_cki("CKI.EC!8188")
  SET tiss_list->list[57].ce_cd = uar_get_code_by_cki("CKI.EC!8189")
  SET tiss_list->list[58].ce_cd = uar_get_code_by_cki("CKI.EC!8190")
  SET tiss_list->list[59].ce_cd = uar_get_code_by_cki("CKI.EC!8191")
  SET tiss_list->list[60].ce_cd = uar_get_code_by_cki("CKI.EC!8192")
  SET tiss_list->list[61].ce_cd = uar_get_code_by_cki("CKI.EC!8193")
  SET tiss_list->list[62].ce_cd = uar_get_code_by_cki("CKI.EC!8194")
  SET tiss_list->list[63].ce_cd = uar_get_code_by_cki("CKI.EC!8195")
  SET tiss_list->list[64].ce_cd = uar_get_code_by_cki("CKI.EC!8196")
  SET tiss_list->list[65].ce_cd = uar_get_code_by_cki("CKI.EC!8197")
  SET tiss_list->list[66].ce_cd = uar_get_code_by_cki("CKI.EC!8198")
  SET tiss_list->list[67].ce_cd = uar_get_code_by_cki("CKI.EC!8199")
  SET tiss_list->list[68].ce_cd = uar_get_code_by_cki("CKI.EC!8200")
  SET tiss_list->list[69].ce_cd = uar_get_code_by_cki("CKI.EC!8201")
  SET tiss_list->list[70].ce_cd = uar_get_code_by_cki("CKI.EC!8202")
  SET tiss_list->list[71].ce_cd = uar_get_code_by_cki("CKI.EC!8203")
  SET tiss_list->list[72].ce_cd = uar_get_code_by_cki("CKI.EC!8204")
  SET tiss_list->list[73].ce_cd = uar_get_code_by_cki("CKI.EC!8205")
  SET tiss_list->list[74].ce_cd = uar_get_code_by_cki("CKI.EC!8206")
  SET tiss_list->list[75].ce_cd = uar_get_code_by_cki("CKI.EC!8207")
  SET tiss_list->list[76].ce_cd = uar_get_code_by_cki("CKI.EC!8208")
  SET tiss_list->list[77].ce_cd = uar_get_code_by_cki("CKI.EC!8209")
  SET tiss_list->list[78].ce_cd = uar_get_code_by_cki("CKI.EC!8210")
  SET tiss_list->list[79].ce_cd = uar_get_code_by_cki("CKI.EC!8211")
  SET tiss_list->list[80].ce_cd = uar_get_code_by_cki("CKI.EC!8212")
  SET tiss_list->list[81].ce_cd = uar_get_code_by_cki("CKI.EC!8213")
  SET tiss_list->list[82].ce_cd = uar_get_code_by_cki("CKI.EC!8214")
  SET tiss_list->list[83].ce_cd = uar_get_code_by_cki("CKI.EC!8215")
  SET tiss_list->list[84].ce_cd = uar_get_code_by_cki("CKI.EC!8216")
  SET tiss_list->list[85].ce_cd = uar_get_code_by_cki("CKI.EC!8217")
  SET tiss_list->list[86].ce_cd = uar_get_code_by_cki("CKI.EC!8218")
  SET tiss_list->list[87].ce_cd = uar_get_code_by_cki("CKI.EC!8219")
  SET tiss_list->list[88].ce_cd = uar_get_code_by_cki("CKI.EC!5734")
  SET tiss_list->list[89].ce_cd = uar_get_code_by_cki("CKI.EC!8220")
  SET tiss_list->list[90].ce_cd = uar_get_code_by_cki("CKI.EC!8221")
  SET tiss_list->list[91].ce_cd = uar_get_code_by_cki("CKI.EC!8222")
  SET tiss_list->list[95].ce_cd = uar_get_code_by_cki("CKI.EC!9399")
 ENDIF
#load_tiss_items_to_arrays_exit
#check_for_none
 SET found_none = 0
 SELECT INTO "nl:"
  FROM risk_adj_tiss rat
  WHERE (rat.risk_adjustment_id=parameters->risk_adjustment_id)
   AND rat.tiss_cd=none_code_value
   AND rat.tiss_beg_dt_tm <= cnvtdatetime(parameters->end_day_dt_tm)
   AND rat.tiss_end_dt_tm >= cnvtdatetime(parameters->beg_day_dt_tm)
   AND rat.tiss_ce_id=0
   AND rat.active_ind=1
  DETAIL
   found_none = 1,
   CALL echo("Found TISS_NONE")
  WITH nocounter
 ;end select
#check_for_none_exit
#inactivate_tiss_none
 CALL echo("DELETING TISS_NONE")
 UPDATE  FROM risk_adj_tiss rat
  SET rat.active_ind = 0, rat.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rat.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   rat.updt_task = reqinfo->updt_task, rat.updt_applctx = reqinfo->updt_applctx, rat.updt_id =
   reqinfo->updt_id,
   rat.updt_cnt = (rat.updt_cnt+ 1)
  WHERE (rat.risk_adjustment_id=parameters->risk_adjustment_id)
   AND rat.tiss_cd=none_code_value
   AND rat.tiss_beg_dt_tm <= cnvtdatetime(parameters->end_day_dt_tm)
   AND rat.tiss_end_dt_tm >= cnvtdatetime(parameters->beg_day_dt_tm)
   AND rat.active_ind=1
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL echo("UNABLE TO INACTIVATE TISS_NONE")
 ENDIF
#inactivate_tiss_none_exit
#delete_tiss_items
 CALL echo("delete tiss items")
 SET parserstring = fillstring(5000," ")
 SET parserstring = build("rat.tiss_cd in (")
 SET got1 = 0
 FOR (del_x = 1 TO ce_tiss_max)
  IF ((tiss_list->list[del_x].acttx_ind=1)
   AND (parameters->accept_tiss_acttx_if_ind=1))
   IF (got1=1)
    SET parserstring = build(parserstring,",")
   ENDIF
   SET parserstring = build(parserstring,format(tiss_list->list[del_x].code_value,"############.##"))
   SET got1 = 1
  ENDIF
  IF ((tiss_list->list[del_x].acttx_ind=0)
   AND (parameters->accept_tiss_nonacttx_if_ind=1))
   IF (got1=1)
    SET parserstring = build(parserstring,",")
   ENDIF
   SET parserstring = build(parserstring,format(tiss_list->list[del_x].code_value,"############.##"))
   SET got1 = 1
  ENDIF
 ENDFOR
 SET parserstring = build(parserstring,")")
 UPDATE  FROM risk_adj_tiss rat
  SET rat.active_ind = 0, rat.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rat.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   rat.updt_task = reqinfo->updt_task, rat.updt_applctx = reqinfo->updt_applctx, rat.updt_id =
   reqinfo->updt_id,
   rat.updt_cnt = (rat.updt_cnt+ 1)
  WHERE (rat.risk_adjustment_id=parameters->risk_adjustment_id)
   AND rat.tiss_beg_dt_tm <= cnvtdatetime(parameters->end_day_dt_tm)
   AND rat.tiss_end_dt_tm >= cnvtdatetime(parameters->beg_day_dt_tm)
   AND rat.active_ind=1
   AND rat.tiss_ce_id > 0
   AND parser(parserstring)
  WITH nocounter
 ;end update
#delete_tiss_items_exit
#load_tiss_items
 CALL echo("loading tiss items for patient")
 CALL echo(build("parameters->person_id=",parameters->person_id))
 CALL echo(build("inerror_cd=",inerror_cd))
 CALL echo(build("CE_TISS_MAX=",ce_tiss_max))
 CALL echo(build("tiss_list->list[95].ce_cd=",tiss_list->list[95].ce_cd))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ce_tiss_max),
   clinical_event ce
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=parameters->person_id)
    AND (ce.event_cd=tiss_list->list[d.seq].ce_cd)
    AND ce.event_cd > 0
    AND ((ce.event_start_dt_tm = null
    AND ce.event_end_dt_tm >= cnvtdatetime(parameters->beg_day_dt_tm)
    AND ce.event_end_dt_tm <= cnvtdatetime(parameters->end_day_dt_tm)) OR (ce.event_start_dt_tm
   IS NOT null
    AND ce.event_start_dt_tm <= cnvtdatetime(parameters->end_day_dt_tm)
    AND ce.event_end_dt_tm >= cnvtdatetime(parameters->beg_day_dt_tm)))
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.result_status_cd != inerror_cd)
  HEAD REPORT
   ce_tiss_cnt = 0
  DETAIL
   CALL echo("GOT IN DETAIL...YEAH"), ce_tiss_cnt = (ce_tiss_cnt+ 1)
   IF (mod(ce_tiss_cnt,10)=1)
    stat = alterlist(ce_tiss_event->list,(ce_tiss_cnt+ 9))
   ENDIF
   ce_tiss_event->list[ce_tiss_cnt].code_value = ce.event_cd
   IF (ce.event_start_dt_tm = null)
    ce_tiss_event->list[ce_tiss_cnt].beg_dt_tm = ce.event_end_dt_tm
   ELSE
    ce_tiss_event->list[ce_tiss_cnt].beg_dt_tm = ce.event_start_dt_tm
   ENDIF
   ce_tiss_event->list[ce_tiss_cnt].end_dt_tm = ce.event_end_dt_tm, ce_tiss_event->list[ce_tiss_cnt].
   tiss_cd = tiss_list->list[d.seq].code_value, ce_tiss_event->list[ce_tiss_cnt].tiss_cdf = tiss_list
   ->list[d.seq].tiss_name,
   CALL echo(build("patient CDF code =",ce_tiss_event->list[ce_tiss_cnt].tiss_cdf)), ce_tiss_event->
   list[ce_tiss_cnt].acttx_ind = tiss_list->list[d.seq].acttx_ind
   IF ((ce_tiss_event->list[ce_tiss_cnt].tiss_cd=none_code_value))
    ce_tiss_event->list[ce_tiss_cnt].tiss_none_ind = 1, found_tiss_none = 1
   ELSE
    ce_tiss_event->list[ce_tiss_cnt].tiss_none_ind = 0, found_real_tiss = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(ce_tiss_event->list,ce_tiss_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(ce_tiss_event)
#load_tiss_items_exit
#get_cc_day
 SET temp_dt1 = format(parameters->beg_day_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
 SET temp_dt2 = format(parameters->end_day_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  WHERE (rad.risk_adjustment_id=parameters->risk_adjustment_id)
   AND rad.cc_beg_dt_tm=cnvtdatetime(parameters->beg_day_dt_tm)
   AND rad.cc_end_dt_tm=cnvtdatetime(parameters->end_day_dt_tm)
   AND rad.active_ind=1
  DETAIL
   tce_cc_day = rad.cc_day, prev_acttx_today_ind = rad.activetx_ind, prev_paline_today_ind = rad
   .pa_line_today_ind,
   prev_vent_today_ind = rad.vent_today_ind
  WITH nocounter
 ;end select
#get_cc_day_exit
#write_ce_tiss_to_rat
 SET array_size = size(ce_tiss_event->list,5)
 IF (array_size > 0)
  FOR (write_x = 1 TO array_size)
    IF (found_real_tiss=1
     AND found_tiss_none=1
     AND (ce_tiss_event->list[write_x].tiss_none_ind=1))
     CALL echo("SKIPPING TISS-NONE INSERT DUE TO REAL TISS ITEMS FOUND")
    ELSE
     CALL echo("INSERTING TISS")
     SET temp_dt1 = format(ce_tiss_event->list[write_x].beg_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
     CALL echo(build("beg_dt_tm=",temp_dt1))
     SET rat_id = 0.0
     SELECT INTO "nl:"
      n = seq(carenet_seq,nextval)
      FROM dual
      DETAIL
       rat_id = cnvtreal(n)
      WITH format, nocounter
     ;end select
     IF (rat_id=0.0)
      CALL echo("get_new_rat_id error")
      SET failed_ind = "Y"
      SET failed_text = "Error reading from carenet sequence."
     ENDIF
     INSERT  FROM risk_adj_tiss rat
      SET rat.risk_adj_tiss_id = rat_id, rat.risk_adjustment_id = parameters->risk_adjustment_id, rat
       .tiss_beg_dt_tm = cnvtdatetime(ce_tiss_event->list[write_x].beg_dt_tm),
       rat.tiss_end_dt_tm = cnvtdatetime(ce_tiss_event->list[write_x].end_dt_tm), rat.tiss_cd =
       ce_tiss_event->list[write_x].tiss_cd, rat.tiss_ce_id = ce_tiss_event->list[write_x].code_value,
       rat.active_ind = 1, rat.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rat
       .active_status_prsnl_id = reqinfo->updt_id,
       rat.active_status_cd = reqdata->active_status_cd, rat.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), rat.updt_task = reqinfo->updt_task,
       rat.updt_applctx = reqinfo->updt_applctx, rat.updt_id = reqinfo->updt_id, rat.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed_ind = "Y"
      SET failed_text = "Unable to write new ra_tiss rows."
      SET tissx = write_x
      GO TO 9999_exit_program
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
#write_ce_tiss_to_rat_exit
#change_rad_flags_as_needed
 SET array_size = size(ce_tiss_event->list,5)
 IF ((parameters->accept_tiss_acttx_if_ind=1))
  SET new_acttx_today_ind = 0
  SET new_vent_today_ind = 0
  IF (array_size > 0)
   FOR (change_x = 1 TO array_size)
    IF ((ce_tiss_event->list[change_x].acttx_ind=1))
     SET new_acttx_today_ind = 1
     CALL echo("got an ACT_TX")
    ENDIF
    IF ((ce_tiss_event->list[change_x].tiss_cdf IN ("PEEP", "CONTVENT", "ASREP", "PRESSSUP",
    "CPAP+PRES",
    "BIPAP")))
     SET new_vent_today_ind = 1
     CALL echo("GOT A VENT")
    ENDIF
   ENDFOR
  ENDIF
 ELSE
  CALL echo("no actives")
  SET new_acttx_today_ind = prev_acttx_today_ind
  SET new_vent_today_ind = prev_vent_today_ind
 ENDIF
 IF ((parameters->accept_tiss_nonacttx_if_ind=1))
  SET new_paline_today_ind = 0
  IF (array_size > 0)
   FOR (change_x = 1 TO array_size)
     IF ((ce_tiss_event->list[change_x].tiss_cdf="PA_LINE"))
      CALL echo("GOT A PA_LINE")
      SET new_paline_today_ind = 1
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  CALL echo("no pa_line")
  SET new_paline_today_ind = prev_paline_today_ind
 ENDIF
 IF (((new_acttx_today_ind != prev_acttx_today_ind) OR (((new_paline_today_ind !=
 prev_paline_today_ind) OR (new_vent_today_ind != prev_vent_today_ind)) )) )
  SET parameters->found_item = 1
  UPDATE  FROM risk_adjustment_day rad
   SET rad.activetx_ind = new_acttx_today_ind, rad.pa_line_today_ind = new_paline_today_ind, rad
    .vent_today_ind = new_vent_today_ind,
    rad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), rad.updt_task = reqinfo->updt_task,
    rad.updt_applctx = reqinfo->updt_applctx, rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad
    .updt_cnt+ 1)
   WHERE (rad.risk_adjustment_id=parameters->risk_adjustment_id)
    AND rad.cc_day=tce_cc_day
    AND rad.active_ind=1
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed_ind = "Y"
   SET failed_text = "Error updating risk_adjustment_day row with TISS info."
   CALL echo("FAILED TO UPDATE ANY RECORDS")
  ENDIF
 ELSE
  SET parameters->found_item = 0
  CALL echo("no need to update")
 ENDIF
#change_rad_flags_as_needed_exit
#9999_exit_program
 SET reqinfo->commit_ind = 1
 CALL echorecord(ce_tiss_event)
END GO
