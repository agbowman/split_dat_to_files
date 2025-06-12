CREATE PROGRAM cpm_audit_get_org_details:dba
 EXECUTE srvcore
 SUBROUTINE (querykey(key_str=vc,curs=i4(ref)) =vc)
   DECLARE str_max_length = i4 WITH noconstant(132)
   DECLARE buf2 = c132 WITH noconstant(fillstring(132," "))
   DECLARE ret = i4 WITH noconstant(0)
   SET ret = uar_srvquerykey(0,nullterm(key_str),buf2,str_max_length,curs)
   IF (ret=0)
    SET buf2 = ""
   ENDIF
   RETURN(buf2)
 END ;Subroutine
 SUBROUTINE (getkeystring(key_str=vc) =vc)
   DECLARE str_max_length = i4 WITH noconstant(132)
   DECLARE buf = c132 WITH noconstant(fillstring(132," "))
   DECLARE ret = i4 WITH noconstant(0)
   SET ret = uar_srvgetkeystring(0,nullterm(key_str),buf,str_max_length)
   IF (ret=0)
    SET buf = ""
   ENDIF
   RETURN(buf)
 END ;Subroutine
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 orgs[*]
      2 chart_access_org
        3 org_id = f8
        3 org_alias = vc
        3 org_alias_type = vc
        3 org_alias_type_cd = f8
        3 org_name = vc
        3 care_giver_id = f8
      2 care_giver
        3 org_id = f8
        3 org_alias = vc
        3 org_alias_type = vc
        3 org_alias_type_cd = f8
        3 org_name = vc
  )
 ENDIF
 DECLARE get_care_givers = i2 WITH constant(1)
 DECLARE dont_get_care_givers = i2 WITH constant(0)
 DECLARE org_alias_type_code_set = i4 WITH constant(334)
 DECLARE care_unit_alias_type_cd = f8 WITH noconstant(0.0)
 DECLARE care_giver_alias_type_cd = f8 WITH noconstant(0.0)
 DECLARE related_org_cnt = i4 WITH noconstant(0)
 DECLARE org_org_reltn_code_set = i4 WITH constant(369)
 DECLARE crgvr_to_crunt_cd = f8 WITH noconstant(0.0)
 DECLARE org_id = f8 WITH noconstant(0.0)
 DECLARE alias_key_path = vc WITH constant("/Config/System/Framework/Security/Auditing/")
 DECLARE care_unit_alias_type_key = vc WITH constant(cnvtupper(trim(getkeystring(build(alias_key_path,
      "/CareUnit/Alias")))))
 DECLARE care_giver_alias_type_key = vc WITH constant(cnvtupper(trim(getkeystring(build(
      alias_key_path,"/CareProvider/Alias")))))
 SET care_unit_alias_type_cd = uar_get_code_by("MEANING",org_alias_type_code_set,nullterm(
   care_unit_alias_type_key))
 SET care_giver_alias_type_cd = uar_get_code_by("MEANING",org_alias_type_code_set,nullterm(
   care_giver_alias_type_key))
 SET crgvr_to_crunt_cd = uar_get_code_by("MEANING",org_org_reltn_code_set,nullterm("CRGVRTOCRUNT"))
 DECLARE request_orgs_cnt = i4 WITH noconstant(0)
 DECLARE request_orgs_idx = i4 WITH noconstant(0)
 SET request_orgs_cnt = size(request->orgs,5)
 SET stat = alterlist(reply->orgs,request_orgs_cnt)
 FOR (request_orgs_idx = 1 TO request_orgs_cnt)
   SET reply->orgs[request_orgs_idx].chart_access_org.org_id = request->orgs[request_orgs_idx].org_id
   IF (care_unit_alias_type_cd > 0)
    SET reply->orgs[request_orgs_idx].chart_access_org.org_alias_type = care_unit_alias_type_key
    SET reply->orgs[request_orgs_idx].chart_access_org.org_alias_type_cd = care_unit_alias_type_cd
   ENDIF
   SET curalias org reply->orgs[request_orgs_idx].chart_access_org
   CALL getorgdetails(get_care_givers)
   IF ((reply->orgs[request_orgs_idx].chart_access_org.care_giver_id > 0))
    SET reply->orgs[request_orgs_idx].care_giver.org_id = reply->orgs[request_orgs_idx].
    chart_access_org.care_giver_id
    IF (care_giver_alias_type_cd > 0)
     SET reply->orgs[request_orgs_idx].care_giver.org_alias_type = care_giver_alias_type_key
     SET reply->orgs[request_orgs_idx].care_giver.org_alias_type_cd = care_giver_alias_type_cd
    ENDIF
    SET curalias org reply->orgs[request_orgs_idx].care_giver
    CALL getorgdetails(dont_get_care_givers)
   ENDIF
 ENDFOR
 SUBROUTINE (getorgdetails(getcaregiverind=i2) =null)
   DECLARE hmsg = i4 WITH noconstant(0)
   DECLARE hreq = i4 WITH noconstant(0)
   DECLARE hrep = i4 WITH noconstant(0)
   DECLARE organizations_req = i4 WITH noconstant(0)
   DECLARE fixed_string = vc WITH protect, noconstant("")
   SET hmsg = uar_srvselectmessage(3202520)
   SET hreq = uar_srvcreaterequest(hmsg)
   SET hrep = uar_srvcreatereply(hmsg)
   SET organizations_req = uar_srvadditem(hreq,"ids")
   CALL uar_srvsetdouble(organizations_req,"organization_id",org->org_id)
   DECLARE load_ind_struct = i4 WITH noconstant(0)
   SET load_ind_struct = uar_srvgetstruct(hreq,"load_indicators")
   CALL uar_srvsetshort(load_ind_struct,"organization_ind",1)
   IF ((org->org_alias_type_cd > 0))
    CALL uar_srvsetshort(load_ind_struct,"alias_ind",1)
   ELSE
    CALL uar_srvsetshort(load_ind_struct,"alias_ind",0)
   ENDIF
   CALL uar_srvsetshort(load_ind_struct,"org_org_r_ind",getcaregiverind)
   CALL uar_srvsetshort(load_ind_struct,"org_type_ind",0)
   CALL uar_srvsetshort(load_ind_struct,"address_ind",0)
   CALL uar_srvsetshort(load_ind_struct,"email_ind",0)
   CALL uar_srvsetshort(load_ind_struct,"phone_ind",0)
   DECLARE srvstat = i2 WITH noconstant(uar_srvexecute(hmsg,hreq,hrep))
   IF (srvstat != 0)
    GO TO stop
   ENDIF
   DECLARE org_rep_cnt = i4 WITH noconstant(0)
   SET org_rep_cnt = uar_srvgetitemcount(hrep,"organizations")
   IF (org_rep_cnt=1)
    DECLARE org_item = i4 WITH noconstant(0)
    SET org_item = uar_srvgetitem(hrep,"organizations",0)
    IF ((org->org_alias_type_cd > 0))
     DECLARE aliases_cnt = i4 WITH noconstant(0)
     SET aliases_cnt = uar_srvgetitemcount(org_item,"aliases")
     DECLARE aliases_index = i4 WITH noconstant(0)
     FOR (aliases_index = 1 TO aliases_cnt)
       DECLARE alias_item = i4 WITH noconstant(0)
       SET alias_item = uar_srvgetitem(org_item,"aliases",(aliases_index - 1))
       DECLARE alias_type_cd = f8 WITH noconstant(0.0)
       SET alias_type_cd = uar_srvgetdouble(alias_item,"alias_type_cd")
       IF ((alias_type_cd=org->org_alias_type_cd))
        SET fixed_string = fillstring(500,char(0))
        CALL uar_srvgetstring(alias_item,"alias",fixed_string,uar_srvgetstringlen(alias_item,"alias")
         )
        SET org->org_alias = trim(fixed_string)
       ENDIF
     ENDFOR
    ENDIF
    DECLARE org_item_details = i4 WITH noconstant(0)
    SET org_item_details = uar_srvgetitem(org_item,"details",0)
    SET fixed_string = fillstring(500,char(0))
    CALL uar_srvgetstring(org_item_details,"org_name",fixed_string,uar_srvgetstringlen(
      org_item_details,"org_name"))
    SET org->org_name = trim(fixed_string)
    SET related_org_cnt = uar_srvgetitemcount(org_item,"originating_organizations")
    IF (related_org_cnt > 0
     AND getcaregiverind=get_care_givers)
     DECLARE related_org_index = i4 WITH noconstant(0)
     FOR (related_org_index = 1 TO related_org_cnt)
       DECLARE related_org_item = i4 WITH noconstant(0)
       SET related_org_item = uar_srvgetitem(org_item,"originating_organizations",(related_org_index
         - 1))
       IF (uar_srvgetdouble(related_org_item,"org_org_reltn_cd")=crgvr_to_crunt_cd)
        SET org->care_giver_id = uar_srvgetdouble(related_org_item,"org_id")
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
#stop
END GO
