CREATE PROGRAM ctp_dcm_code_value_alias_cls:dba
 RECORD EDCWRTL::filter(
   1 list[*]
     2 id = i1
     2 item[*]
       3 txt_value = vc
       3 id_value = f8
     2 inverse_ind = i2
 ) WITH protect, persistscript
 CREATE CLASS ctp_get_code_sets
 init
 CALL echo("+++ ctp_get_code_sets instantiated")
 RECORD _::filter(
   1 list[*]
     2 id = i1
     2 item[*]
       3 txt_value = vc
       3 id_value = f8
       3 int_value = i4
 ) WITH protect
 SUBROUTINE (_::get(filter=i4) =i2)
   DECLARE success = i2 WITH noconstant(0), protect
   DECLARE setclause = vc WITH noconstant("1 = 1"), protect
   DECLARE cidx = i4 WITH noconstant(0), protect
   DECLARE cnt = i4 WITH noconstant(size(global::codevaluealias->list,5)), protect
   DECLARE numcodesets = i4 WITH noconstant(size(filters->list[filter].item,5)), protect
   IF (validate(GLOBAL::codevaluealias))
    IF (size(filters->list[filter].item,5) > 0)
     SET setclause = concat("expand(cidx,1,size(filters->list[filter].item,5),cvs.code_set,",
      "cnvtint(filters->list[filter].item[cidx].txt_value))")
    ENDIF
    SELECT INTO "nl:"
     FROM code_value_set cvs
     PLAN (cvs
      WHERE cvs.code_set > 0
       AND parser(setclause))
     HEAD REPORT
      success = true
     DETAIL
      cnt += 1
      IF (cnt > size(global::codevaluealias->list,5))
       stat = alterlist(global::codevaluealias->list,(cnt+ 100))
      ENDIF
      global::codevaluealias->list[cnt].code_set = cvs.code_set, global::codevaluealias->list[cnt].
      display = cvs.display, global::codevaluealias->list[cnt].description = cvs.description,
      global::codevaluealias->list[cnt].cdf_meaning_dup_ind = cvs.cdf_meaning_dup_ind, global::
      codevaluealias->list[cnt].display_dup_ind = cvs.display_dup_ind, global::codevaluealias->list[
      cnt].display_key_dup_ind = cvs.display_key_dup_ind,
      global::codevaluealias->list[cnt].active_ind_dup_ind = cvs.active_ind_dup_ind, global::
      codevaluealias->list[cnt].definition_dup_ind = cvs.definition_dup_ind, global::codevaluealias->
      list[cnt].alias_dup_ind = cvs.alias_dup_ind,
      global::codevaluealias->list[cnt].add_access_ind = cvs.add_access_ind, global::codevaluealias->
      list[cnt].del_access_ind = cvs.del_access_ind, global::codevaluealias->list[cnt].chg_access_ind
       = cvs.chg_access_ind,
      global::codevaluealias->list[cnt].inq_access_ind = cvs.inq_access_ind, global::codevaluealias->
      list[cnt].cache_ind = cvs.cache_ind, global::codevaluealias->list[cnt].extension_ind = cvs
      .extension_ind,
      global::codevaluealias->list[cnt].definition = cvs.definition, global::codevaluealias->list[cnt
      ].display_key = cvs.display_key, global::codevaluealias->list[cnt].def_dup_rule_flag = cvs
      .def_dup_rule_flag
     FOOT REPORT
      stat = alterlist(global::codevaluealias->list,cnt)
     WITH nocounter, expand = 2
    ;end select
   ENDIF
   RETURN(success)
 END ;Subroutine
 END; class scope:init
 final
 CALL echo("--- ctp_get_code_sets out of scope")
 END; class scope:final
 WITH copy = 1
 CREATE CLASS core_ens_inbnd_alias FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 inbnd_alias_list[*]
     2 action_type_flag = i2
     2 alias = vc
     2 old_alias = vc
     2 alias_type_meaning = vc
     2 code_set = i4
     2 code_value = f8
     2 contributor_source_cd = f8
     2 old_contributor_source_cd = f8
     2 primary_ind = i2
     2 old_alias_type_meaning = vc
 )
 RECORD _::reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE _status = i2 WITH protect, noconstant(0)
   SET _status = PRIVATE::performwrapper(0)
   IF (_status
    AND (_::reply->qual[1].status=0))
    SET PRIVATE::err_msg = concat(PRIVATE::object_name," ",_::reply->qual[1].error_msg)
    SET _status = 0
   ENDIF
   RETURN(_status)
 END ;Subroutine
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("core_ens_inbnd_alias"))
 DECLARE PRIVATE::free_reply = i2 WITH constant(1)
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
 CREATE CLASS core_ens_outbnd_alias FROM ctp_ip_script_ccl
 init
 RECORD _::request(
   1 outbnd_alias_list[*]
     2 alias = vc
     2 alias_type_meaning = vc
     2 old_alias_type_meaning = vc
     2 action_type_flag = i4
     2 contributor_source_cd = f8
     2 old_contributor_source_cd = f8
     2 code_set = f8
     2 code_value = f8
 )
 RECORD _::reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE _::perform(null) = i2
 SUBROUTINE _::perform(null)
   DECLARE _status = i2 WITH protect, noconstant(0)
   SET _status = PRIVATE::performwrapper(0)
   IF (_status
    AND (_::reply->qual[1].status=0))
    SET PRIVATE::err_msg = concat(PRIVATE::object_name," ",_::reply->qual[1].error_msg)
    SET _status = 0
   ENDIF
   RETURN(_status)
 END ;Subroutine
 DECLARE PRIVATE::object_name = vc WITH constant(cnvtupper("core_ens_outbnd_alias"))
 DECLARE PRIVATE::free_reply = i2 WITH constant(1)
 DECLARE PRIVATE::commit_ind_check = i2 WITH constant(1)
 END; class scope:init
 WITH copy = 1
END GO
