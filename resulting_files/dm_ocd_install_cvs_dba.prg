CREATE PROGRAM dm_ocd_install_cvs:dba
 SET fname = build("dm_ocd_install_cvs_",cnvtstring(ocd_number),".dat")
 SELECT INTO value(fname)
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go"
  WITH nocounter, maxrow = 1, maxcol = 80,
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
 SET doic_def_ind = 0
 RANGE OF dacvs IS dm_afd_code_value_set
 IF (evaluate(validate(dacvs.definition_dup_ind,- (999999)),- (999999),0,1))
  SET doic_def_ind = 1
 ENDIF
 IF (doic_def_ind=0)
  CALL echo("Column DEFINITION_DUP_IND doesn't exist in table DM_AFD_CODE_VALUE_SET")
 ENDIF
 UPDATE  FROM dm_alpha_features_env a
  SET a.status = "RUNNING CODE SET REFRESH"
  WHERE a.alpha_feature_nbr=ocd_number
   AND a.status != "SUCCESS"
   AND a.environment_id=envid
 ;end update
 COMMIT
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 display = c40
     2 description = vc
     2 definition = vc
     2 table_name = c32
     2 cache_ind = i2
     2 add_access_ind = i2
     2 chg_access_ind = i2
     2 del_access_ind = i2
     2 inq_access_ind = i2
     2 domain_qualifier_ind = i2
     2 domain_code_set = i4
     2 add_code_value_ind = i2
     2 add_code_value_default = i4
     2 def_dup_rule_flag = i2
     2 cdf_meaning_dup_ind = i2
     2 display_key_dup_ind = i2
     2 active_ind_dup_ind = i2
     2 display_dup_ind = i2
     2 alias_dup_ind = i2
     2 definition_dup_ind = i2
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_code_value_set dm,
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
   IF (doic_def_ind=0)
    SELECT INTO "nl:"
     dcv.code_set, dcv.display, dcv.description,
     dcv.definition, dcv.table_name, dcv.cache_ind,
     dcv.add_access_ind, dcv.chg_access_ind, dcv.del_access_ind,
     dcv.inq_access_ind, dcv.domain_qualifier_ind, dcv.domain_code_set,
     dcv.def_dup_rule_flag, dcv.cdf_meaning_dup_ind, dcv.display_key_dup_ind,
     dcv.active_ind_dup_ind, dcv.display_dup_ind, dcv.alias_dup_ind
     FROM dm_afd_code_value_set dcv
     WHERE (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.alpha_feature_nbr=anumber
     DETAIL
      def1 = fillstring(85," "), def2 = fillstring(85," "), def3 = fillstring(85," "),
      list->qual[cnt].code_set = dcv.code_set, list->qual[cnt].display = replace(dcv.display,'"',"'",
       0), list->qual[cnt].description = replace(dcv.description,'"',"'",0),
      def1 = substring(1,85,dcv.definition), def2 = substring(86,85,dcv.definition), def3 = substring
      (171,85,dcv.definition),
      list->qual[cnt].definition = trim(concat(def1,def2,def3)), list->qual[cnt].table_name = replace
      (dcv.table_name,'"',"'",0), list->qual[cnt].cache_ind = dcv.cache_ind,
      list->qual[cnt].add_access_ind = dcv.add_access_ind, list->qual[cnt].chg_access_ind = dcv
      .chg_access_ind, list->qual[cnt].del_access_ind = dcv.del_access_ind,
      list->qual[cnt].inq_access_ind = dcv.inq_access_ind, list->qual[cnt].domain_qualifier_ind = dcv
      .domain_qualifier_ind, list->qual[cnt].domain_code_set = dcv.domain_code_set,
      list->qual[cnt].def_dup_rule_flag = dcv.def_dup_rule_flag, list->qual[cnt].cdf_meaning_dup_ind
       = dcv.cdf_meaning_dup_ind, list->qual[cnt].display_key_dup_ind = dcv.display_key_dup_ind,
      list->qual[cnt].active_ind_dup_ind = dcv.active_ind_dup_ind, list->qual[cnt].display_dup_ind =
      dcv.display_dup_ind, list->qual[cnt].alias_dup_ind = dcv.alias_dup_ind
     WITH nocounter, maxrow = 1
    ;end select
   ELSEIF (doic_def_ind=1)
    SELECT INTO "nl:"
     dcv.code_set, dcv.display, dcv.description,
     dcv.definition, dcv.table_name, dcv.cache_ind,
     dcv.add_access_ind, dcv.chg_access_ind, dcv.del_access_ind,
     dcv.inq_access_ind, dcv.domain_qualifier_ind, dcv.domain_code_set,
     dcv.def_dup_rule_flag, dcv.cdf_meaning_dup_ind, dcv.display_key_dup_ind,
     dcv.active_ind_dup_ind, dcv.display_dup_ind, dcv.alias_dup_ind,
     dcv.definition_dup_ind
     FROM dm_afd_code_value_set dcv
     WHERE (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.alpha_feature_nbr=anumber
     DETAIL
      def1 = fillstring(85," "), def2 = fillstring(85," "), def3 = fillstring(85," "),
      list->qual[cnt].code_set = dcv.code_set, list->qual[cnt].display = replace(dcv.display,'"',"'",
       0), list->qual[cnt].description = replace(dcv.description,'"',"'",0),
      def1 = substring(1,85,dcv.definition), def2 = substring(86,85,dcv.definition), def3 = substring
      (171,85,dcv.definition),
      list->qual[cnt].definition = trim(concat(def1,def2,def3)), list->qual[cnt].table_name = replace
      (dcv.table_name,'"',"'",0), list->qual[cnt].cache_ind = dcv.cache_ind,
      list->qual[cnt].add_access_ind = dcv.add_access_ind, list->qual[cnt].chg_access_ind = dcv
      .chg_access_ind, list->qual[cnt].del_access_ind = dcv.del_access_ind,
      list->qual[cnt].inq_access_ind = dcv.inq_access_ind, list->qual[cnt].domain_qualifier_ind = dcv
      .domain_qualifier_ind, list->qual[cnt].domain_code_set = dcv.domain_code_set,
      list->qual[cnt].def_dup_rule_flag = dcv.def_dup_rule_flag, list->qual[cnt].cdf_meaning_dup_ind
       = dcv.cdf_meaning_dup_ind, list->qual[cnt].display_key_dup_ind = dcv.display_key_dup_ind,
      list->qual[cnt].active_ind_dup_ind = dcv.active_ind_dup_ind, list->qual[cnt].display_dup_ind =
      dcv.display_dup_ind, list->qual[cnt].alias_dup_ind = dcv.alias_dup_ind,
      list->qual[cnt].definition_dup_ind = dcv.definition_dup_ind
     WITH nocounter, maxrow = 1
    ;end select
   ENDIF
   FREE SET dmrequest
   RECORD dmrequest(
     1 code_set = i4
     1 display = c40
     1 description = vc
     1 definition = vc
     1 table_name = c32
     1 cache_ind = i2
     1 add_access_ind = i2
     1 chg_access_ind = i2
     1 del_access_ind = i2
     1 inq_access_ind = i2
     1 domain_qualifier_ind = i2
     1 domain_code_set = i4
     1 add_code_value_ind = i2
     1 add_code_value_default = i4
     1 def_dup_rule_flag = i2
     1 cdf_meaning_dup_ind = i2
     1 display_key_dup_ind = i2
     1 active_ind_dup_ind = i2
     1 display_dup_ind = i2
     1 alias_dup_ind = i2
     1 definition_dup_ind = i2
   )
   SET dmrequest->code_set = list->qual[cnt].code_set
   SET dmrequest->display = list->qual[cnt].display
   SET dmrequest->description = list->qual[cnt].description
   SET dmrequest->definition = list->qual[cnt].definition
   SET dmrequest->table_name = list->qual[cnt].table_name
   SET dmrequest->cache_ind = list->qual[cnt].cache_ind
   SET dmrequest->add_access_ind = list->qual[cnt].add_access_ind
   SET dmrequest->chg_access_ind = list->qual[cnt].chg_access_ind
   SET dmrequest->del_access_ind = list->qual[cnt].del_access_ind
   SET dmrequest->inq_access_ind = list->qual[cnt].inq_access_ind
   SET dmrequest->domain_qualifier_ind = list->qual[cnt].domain_qualifier_ind
   SET dmrequest->domain_code_set = list->qual[cnt].domain_code_set
   SET dmrequest->def_dup_rule_flag = list->qual[cnt].def_dup_rule_flag
   SET dmrequest->cdf_meaning_dup_ind = list->qual[cnt].cdf_meaning_dup_ind
   SET dmrequest->display_key_dup_ind = list->qual[cnt].display_key_dup_ind
   SET dmrequest->active_ind_dup_ind = list->qual[cnt].active_ind_dup_ind
   SET dmrequest->display_dup_ind = list->qual[cnt].display_dup_ind
   SET dmrequest->alias_dup_ind = list->qual[cnt].alias_dup_ind
   SET dmrequest->definition_dup_ind = list->qual[cnt].definition_dup_ind
   SET reqinfo->updt_id = 111
   SET reqinfo->updt_applctx = 111
   EXECUTE dm_code_value_set
 ENDFOR
 COMMIT
 FREE RANGE dacvs
#end_program
END GO
