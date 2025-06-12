CREATE PROGRAM dm_ocd_install_cv:dba
 SET fname = build("dm_ocd_install_cv_",cnvtstring(ocd_number),".dat")
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
 DECLARE doic_debug_flag = i2 WITH protect, noconstant(0)
 SET doic_debug_flag = validate(dm2_debug_flag,0)
 FREE RECORD doi_contrib_source
 RECORD doi_contrib_source(
   1 cv_cnt = i4
   1 cv_qual[*]
     2 code_value = f8
     2 display = vc
 )
 SET doi_contrib_source->cv_cnt = 0
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 cs[*]
       3 dup_rule_flag = i2
       3 code_value = f8
       3 cki = vc
       3 cdf_meaning = c12
       3 display = c40
       3 description = c60
       3 definition = c100
       3 collation_seq = i2
       3 active_ind = i2
       3 alias = vc
       3 contributor_source_display = vc
     2 knt = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM dm_afd_code_value cv
  WHERE cv.code_set=73
  ORDER BY cv.code_value, cv.updt_dt_tm DESC, cv.alpha_feature_nbr DESC
  HEAD cv.code_value
   doi_contrib_source->cv_cnt = (doi_contrib_source->cv_cnt+ 1)
   IF (mod(doi_contrib_source->cv_cnt,10)=1)
    stat = alterlist(doi_contrib_source->cv_qual,(doi_contrib_source->cv_cnt+ 9))
   ENDIF
   doi_contrib_source->cv_qual[doi_contrib_source->cv_cnt].code_value = cv.code_value,
   doi_contrib_source->cv_qual[doi_contrib_source->cv_cnt].display = cv.display
  FOOT REPORT
   stat = alterlist(doi_contrib_source->cv_qual,doi_contrib_source->cv_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_code_value dm,
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
   IF (doic_debug_flag > 0)
    CALL echo(build("Loading code value records for code set <",list->qual[cnt].code_set,">."))
    CALL trace(7)
   ENDIF
   SELECT INTO "nl:"
    dcv.code_set, dcv.cki, dcv.cdf_meaning,
    dcv.display, dcv.description, dcv.definition,
    dcv.collation_seq, dcv.active_ind
    FROM dm_afd_code_value dcv,
     dm_afd_code_value_alias a
    PLAN (dcv
     WHERE (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.alpha_feature_nbr=anumber)
     JOIN (a
     WHERE outerjoin(dcv.code_value)=a.code_value
      AND outerjoin(dcv.alpha_feature_nbr)=a.alpha_feature_nbr)
    HEAD dcv.code_set
     list->qual[cnt].code_set = dcv.code_set, kntt = 0, list->qual[cnt].knt = 0
    DETAIL
     kntt = (kntt+ 1), stat = alterlist(list->qual[cnt].cs,kntt), list->qual[cnt].cs[kntt].
     dup_rule_flag = 1,
     list->qual[cnt].cs[kntt].cki = dcv.cki, list->qual[cnt].cs[kntt].cdf_meaning = replace(dcv
      .cdf_meaning,'"',"'",0), list->qual[cnt].cs[kntt].display = replace(dcv.display,'"',"'",0),
     list->qual[cnt].cs[kntt].description = replace(dcv.description,'"',"'",0), list->qual[cnt].cs[
     kntt].definition = replace(dcv.definition,'"',"'",0), list->qual[cnt].cs[kntt].collation_seq =
     dcv.collation_seq,
     list->qual[cnt].cs[kntt].active_ind = dcv.active_ind, list->qual[cnt].cs[kntt].alias = a.alias,
     rpt_csc_cnt = 0
     IF ((list->qual[cnt].cs[kntt].alias > ""))
      rpt_csc_cnt = locateval(rpt_csc_cnt,1,doi_contrib_source->cv_cnt,a.contributor_source_cd,
       doi_contrib_source->cv_qual[rpt_csc_cnt].code_value)
      IF (rpt_csc_cnt > 0)
       list->qual[cnt].cs[kntt].contributor_source_display = doi_contrib_source->cv_qual[rpt_csc_cnt]
       .display
      ENDIF
     ENDIF
    FOOT REPORT
     list->qual[cnt].knt = kntt
    WITH nocounter
   ;end select
   IF (doic_debug_flag > 0)
    CALL echo(build("Added <",list->qual[cnt].knt,"> code value records for code set <",list->qual[
      cnt].code_set,">."))
    CALL trace(7)
   ENDIF
   SET i = 0
   FOR (i = 1 TO list->qual[cnt].knt)
     FREE SET dmrequest
     RECORD dmrequest(
       1 dup_rule_flag = i2
       1 code_set = f8
       1 code_value = f8
       1 cki = vc
       1 cdf_meaning = c12
       1 display = c40
       1 description = c60
       1 definition = c100
       1 collation_seq = i2
       1 active_ind = i2
       1 alias = vc
       1 contributor_source_display = vc
       1 contributor_source_cd = f8
     )
     SET dmrequest->dup_rule_flag = 1
     SET dmrequest->code_set = list->qual[cnt].code_set
     SET dmrequest->cki = list->qual[cnt].cs[i].cki
     SET dmrequest->cdf_meaning = list->qual[cnt].cs[i].cdf_meaning
     SET dmrequest->display = list->qual[cnt].cs[i].display
     SET dmrequest->description = list->qual[cnt].cs[i].description
     SET dmrequest->definition = list->qual[cnt].cs[i].definition
     SET dmrequest->collation_seq = list->qual[cnt].cs[i].collation_seq
     SET dmrequest->active_ind = list->qual[cnt].cs[i].active_ind
     SET dmrequest->alias = list->qual[cnt].cs[i].alias
     SET dmrequest->contributor_source_display = list->qual[cnt].cs[i].contributor_source_display
     SET dmrequest->contributor_source_cd = 0
     SET reqinfo->updt_id = 111
     SET reqinfo->updt_applctx = 111
     EXECUTE dm_insert_code_value
   ENDFOR
   SET stat = alterlist(list->qual[cnt].cs,0)
 ENDFOR
 COMMIT
#end_program
END GO
