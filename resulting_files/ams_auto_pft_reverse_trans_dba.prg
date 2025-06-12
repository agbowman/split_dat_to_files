CREATE PROGRAM ams_auto_pft_reverse_trans:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Directory" = "",
  "Pass Input File Name" = ""
  WITH outdev, directory, inputfile
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE cclseclogin
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD trans
 RECORD trans(
   1 qual[*]
     2 claim_nbr = vc
 )
 FREE RECORD data
 RECORD data(
   1 objarray[*]
     2 activity_id = f8
     2 amount = f8
     2 batch_type_flag = i2
 )
 FREE RECORD temp_request
 RECORD temp_request(
   1 inproc_batch_trans_id = f8
   1 batch_type_flag = i2
   1 script_name = vc
   1 suppress_transfer_reversal = i2
   1 objarray[1]
     2 activity_id = f8
     2 amount = f8
 )
 DECLARE payment_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",18649,"PAYMENT"))
 DECLARE reversal_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",18937,"REVERSAL"))
 DECLARE posted_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",20569,"POSTED"))
 DECLARE trans_reversal_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",25753,"REVERSAL"))
 SET path = value(logical( $DIRECTORY))
 SET infile =  $INPUTFILE
 SET file_path = build(path,":",infile)
 CALL echo(build(path,":",infile))
 CALL echo(file_path)
 DEFINE rtl2 value(file_path)
 SELECT INTO "nl:"
  FROM rtl2t r1
  PLAN (r1)
  HEAD REPORT
   stat = alterlist(trans->qual,100), cnt = 0
  HEAD r1.line
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 100)
    stat = alterlist(trans->qual,(cnt+ 9))
   ENDIF
   trans->qual[cnt].claim_nbr = piece(r1.line,",",1," ",0)
  FOOT REPORT
   stat = alterlist(trans->qual,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(trans->qual,5))),
   bill_rec b,
   bill_reltn br,
   bo_hp_reltn bh,
   health_plan hp,
   pft_trans_reltn p,
   batch_trans_file bf,
   trans_log t
  PLAN (d1)
   JOIN (b
   WHERE (b.bill_nbr_disp=trans->qual[d1.seq].claim_nbr)
    AND b.active_ind=1
    AND b.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (br
   WHERE b.corsp_activity_id=br.corsp_activity_id
    AND br.parent_entity_name="BO_HP_RELTN"
    AND br.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (bh
   WHERE bh.bo_hp_reltn_id=br.parent_entity_id
    AND bh.active_ind=1
    AND bh.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (hp
   WHERE bh.health_plan_id=hp.health_plan_id
    AND hp.plan_name_key="*ADNIC*"
    AND hp.active_ind=1
    AND hp.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.benefit_order_id=bh.bo_hp_reltn_id
    AND p.trans_type_cd=payment_cd
    AND p.parent_entity_name="BILL"
    AND p.active_ind=1
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (bf
   WHERE p.batch_trans_file_id=bf.batch_trans_file_id
    AND bf.error_status_cd=posted_cd
    AND bf.trans_type_cd=payment_cd
    AND bf.active_ind=1
    AND bf.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (t
   WHERE t.activity_id=p.activity_id
    AND t.trans_type_cd=payment_cd
    AND t.trans_reason_cd != reversal_cd
    AND t.active_ind=1
    AND t.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND  NOT (t.activity_id IN (
   (SELECT
    ttr.parent_activity_id
    FROM trans_trans_reltn ttr
    WHERE ttr.parent_activity_id=t.activity_id
     AND ttr.trans_reltn_reason_cd=trans_reversal_cd))))
  HEAD REPORT
   cnt = 0, stat = alterlist(data->objarray,100)
  HEAD t.activity_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 100)
    stat = alterlist(data->objarray,(cnt+ 9))
   ENDIF
   data->objarray[cnt].activity_id = t.activity_id, data->objarray[cnt].amount = p.amount, data->
   objarray[cnt].batch_type_flag = 514
  FOOT REPORT
   stat = alterlist(data->objarray,cnt)
  WITH nocounter
 ;end select
 SET recur_cnt = cnvtint(value(size(data->objarray,5)))
 FOR (i = 1 TO recur_cnt BY 1)
   SET temp_request->batch_type_flag = data->objarray[i].batch_type_flag
   SET temp_request->objarray[1].activity_id = data->objarray[i].activity_id
   SET temp_request->objarray[1].amount = data->objarray[i].amount
   EXECUTE pft_reverse_transaction  WITH replace(request,temp_request)
 ENDFOR
 CALL echorecord(trans)
 CALL echorecord(data)
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
