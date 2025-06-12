CREATE PROGRAM ams_lab_ordr_dup_check:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Orderables" = 0,
  "Behind Action Value" = 0,
  "Ahead Action Value" = 0,
  "Exact Action Value" = 0,
  "Min_Ahead" = 0,
  "Min_Behind" = 0
  WITH outdev, laborders, behind_action,
  ahead_action, exact_action, min_ahead,
  min_behind
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(2,0))), private
 DECLARE count = i2
 IF (prompt_reflect="F8")
  SET count = 1
 ELSE
  SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
 ENDIF
 CALL echo("Prompt Reflect and Count")
 CALL echo(prompt_reflect)
 CALL echo(count)
 DECLARE i = i4 WITH protect
 DECLARE r_val = vc WITH protect
 IF (count > 0)
  SET rval = "("
  FOR (i = 1 TO count)
   IF (mod(i,100)=1
    AND i > 1)
    SET r_val = replace(r_val,",",")",2)
   ENDIF
   IF (substring(1,1,reflect(parameter(2,i)))="F")
    SET r_val = build(r_val,value(parameter(2,i)),",")
   ENDIF
  ENDFOR
 ENDIF
 FREE RECORD rc
 RECORD rc(
   1 qual[*]
     2 catalog_cd = f8
     2 behind_act = f8
     2 ahead_act = f8
     2 exact_act = f8
     2 min_ahead = f8
     2 min_behind = f8
 )
 SET stat = alterlist(rc->qual,count)
 FOR (i = 1 TO count)
   SET rc->qual[i].catalog_cd = cnvtreal(piece(r_val,",",i,"",1))
   SET rc->qual[i].ahead_act =  $4
   SET rc->qual[i].behind_act =  $3
   SET rc->qual[i].exact_act =  $5
   SET rc->qual[i].min_ahead =  $6
   SET rc->qual[i].min_behind =  $7
 ENDFOR
 DECLARE num = i4 WITH protect
 FREE RECORD request_data
 RECORD request_data(
   1 catalog_cd = f8
   1 dup_add_cnt = i4
   1 add_qual[*]
     2 dup_check_seq = i4
     2 exact_hit_action_cd = f8
     2 min_behind = i4
     2 min_behind_action_cd = f8
     2 min_ahead = i4
     2 min_ahead_action_cd = f8
     2 active_ind = i2
     2 outpat_flex_ind = i2
     2 outpat_min_behind = i4
     2 outpat_min_behind_action_cd = f8
     2 outpat_min_ahead = i4
     2 outpat_min_ahead_action_cd = f8
     2 outpat_exact_hit_action_cd = f8
   1 dup_upd_cnt = i4
   1 upd_qual[*]
     2 dup_check_seq = i4
     2 exact_hit_action_cd = f8
     2 min_behind = i4
     2 min_behind_action_cd = f8
     2 min_ahead = i4
     2 min_ahead_action_cd = f8
     2 active_ind = i2
     2 outpat_flex_ind = i2
     2 outpat_min_behind = i4
     2 outpat_min_behind_action_cd = f8
     2 outpat_min_ahead = i4
     2 outpat_min_ahead_action_cd = f8
     2 outpat_exact_hit_action_cd = f8
 )
 FOR (i = 1 TO size(rc->qual,5))
   SET cnt = 0
   SET stat = initrec(request_data)
   SELECT INTO "nl:"
    dc.*
    FROM dup_checking dc
    WHERE (dc.catalog_cd=rc->qual[i].catalog_cd)
     AND dc.dup_check_seq=1
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
    WITH nocounter
   ;end select
   IF (cnt > 0)
    SET stat = alterlist(request_data->upd_qual,cnt)
    SET request_data->dup_upd_cnt = 1
    SET request_data->catalog_cd = rc->qual[i].catalog_cd
    SET request_data->upd_qual[cnt].dup_check_seq = 1
    SET request_data->upd_qual[cnt].exact_hit_action_cd = rc->qual[i].exact_act
    SET request_data->upd_qual[cnt].min_ahead = rc->qual[i].min_ahead
    SET request_data->upd_qual[cnt].min_ahead_action_cd = rc->qual[i].ahead_act
    SET request_data->upd_qual[cnt].min_behind = rc->qual[i].min_behind
    SET request_data->upd_qual[cnt].min_behind_action_cd = rc->qual[i].behind_act
    SET request_data->upd_qual[cnt].active_ind = 1
    SET request_data->upd_qual[cnt].outpat_exact_hit_action_cd = 2520.00
    SET request_data->upd_qual[cnt].outpat_flex_ind = 0
    SET request_data->upd_qual[cnt].outpat_min_ahead = 0
    SET request_data->upd_qual[cnt].outpat_min_ahead_action_cd = 2520.00
    SET request_data->upd_qual[cnt].outpat_min_behind = 0
    SET request_data->upd_qual[cnt].outpat_min_behind_action_cd = 2520.00
   ELSE
    SET cnt = (cnt+ 1)
    SET stat = alterlist(request_data->add_qual,cnt)
    SET request_data->dup_add_cnt = 1
    SET request_data->catalog_cd = rc->qual[i].catalog_cd
    SET request_data->add_qual[cnt].dup_check_seq = 1
    SET request_data->add_qual[cnt].exact_hit_action_cd = rc->qual[i].exact_act
    SET request_data->add_qual[cnt].min_ahead = rc->qual[i].min_ahead
    SET request_data->add_qual[cnt].min_ahead_action_cd = rc->qual[i].ahead_act
    SET request_data->add_qual[cnt].min_behind = rc->qual[i].min_behind
    SET request_data->add_qual[cnt].min_behind_action_cd = rc->qual[i].behind_act
    SET request_data->add_qual[cnt].active_ind = 1
    SET request_data->add_qual[cnt].outpat_exact_hit_action_cd = 2520.00
    SET request_data->add_qual[cnt].outpat_flex_ind = 0
    SET request_data->add_qual[cnt].outpat_min_ahead = 0
    SET request_data->add_qual[cnt].outpat_min_ahead_action_cd = 2520.00
    SET request_data->add_qual[cnt].outpat_min_behind = 0
    SET request_data->add_qual[cnt].outpat_min_behind_action_cd = 2520.00
   ENDIF
   EXECUTE orm_upd_oc_dup_check  WITH replace(request,request_data)
 ENDFOR
 IF (curqual != 0)
  SELECT INTO  $OUTDEV
   stat = "Duplicate check's been added successfully"
   FROM dummyt d
  ;end select
 ENDIF
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "000  05/04/2016    RC032418       Initial Release "
END GO
