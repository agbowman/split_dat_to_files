CREATE PROGRAM dm_ocd_install_cse:dba
 SET fname = build("dm_ocd_install_cse_",cnvtstring(ocd_number),".dat")
 SELECT INTO value(fname)
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go"
  WITH nocounter, maxrow = 1, maxcol = 512,
   format = variable, formfeed = none
 ;end select
 SET envid = 0.0
 SET anumber = ocd_number
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   envid = d.environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Name")
  GO TO end_program
 ENDIF
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 cs[*]
       3 field_name = c32
       3 field_seq = i4
       3 field_type = i2
       3 field_len = i4
       3 field_prompt = c50
       3 field_default = c50
       3 field_help = c100
     2 knt = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_code_set_extension dm,
   dm_alpha_features_env da
  WHERE dm.alpha_feature_nbr=anumber
   AND dm.alpha_feature_nbr=da.alpha_feature_nbr
   AND da.status != "SUCCESS"
   AND da.environment_id=envid
  ORDER BY dm.code_set
  DETAIL
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].code_set = dm.code_set
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   SELECT INTO "nl:"
    dcv.code_set, dcv.field_name, dcv.field_seq,
    dcv.field_type, dcv.field_len, dcv.field_prompt,
    dcv.field_default, dcv.field_help
    FROM dm_afd_code_set_extension dcv
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND dcv.alpha_feature_nbr=anumber
    HEAD dcv.code_set
     list->qual[cnt].code_set = dcv.code_set, list->qual[cnt].knt = 0, kntt = 0
    DETAIL
     kntt = (kntt+ 1), stat = alterlist(list->qual[cnt].cs,kntt), list->qual[cnt].cs[kntt].field_name
      = replace(dcv.field_name,'"',"'",0),
     list->qual[cnt].cs[kntt].field_default = replace(dcv.field_default,'"',"'",0), list->qual[cnt].
     cs[kntt].field_prompt = replace(dcv.field_prompt,'"',"'",0), list->qual[cnt].cs[kntt].field_help
      = replace(dcv.field_help,'"',"'",0),
     list->qual[cnt].cs[kntt].field_seq = dcv.field_seq, list->qual[cnt].cs[kntt].field_type = dcv
     .field_type, list->qual[cnt].cs[kntt].field_len = dcv.field_len
    FOOT REPORT
     list->qual[cnt].knt = kntt
    WITH nocounter
   ;end select
   SET i = 0
   FOR (i = 1 TO list->qual[cnt].knt)
     FREE SET dmrequest
     RECORD dmrequest(
       1 field_name = c32
       1 code_set = f8
       1 field_seq = i4
       1 field_type = i2
       1 field_len = i4
       1 field_prompt = c50
       1 field_default = c50
       1 field_help = c100
     )
     SET dmrequest->code_set = list->qual[cnt].code_set
     SET dmrequest->field_name = list->qual[cnt].cs[i].field_name
     SET dmrequest->field_default = list->qual[cnt].cs[i].field_default
     SET dmrequest->field_prompt = list->qual[cnt].cs[i].field_prompt
     SET dmrequest->field_help = list->qual[cnt].cs[i].field_help
     SET dmrequest->field_seq = list->qual[cnt].cs[i].field_seq
     SET dmrequest->field_type = list->qual[cnt].cs[i].field_type
     SET dmrequest->field_len = list->qual[cnt].cs[i].field_len
     SET reqinfo->updt_id = 111
     SET reqinfo->updt_applctx = 111
     EXECUTE dm_code_set_extension
   ENDFOR
 ENDFOR
 COMMIT
#end_program
END GO
