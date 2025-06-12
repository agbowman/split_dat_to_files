CREATE PROGRAM cp_get_dd_sref_xml
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "CLIN_ID" = "",
  "VERSION" = "0"
  WITH outdev, clin_id, vrsn_nbr
 FREE RECORD sdoc_reply
 RECORD sdoc_reply(
   1 sdoc_blob = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE filterdoccomponentdetails(null) = null WITH protect
 SUBROUTINE (checkforexistingactivepathway(pathwayname=vc,pathwaytypecd=f8,logicaldomainid=f8) =f8
  WITH protect)
   CALL log_message("Begin CheckForExistingPathway()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE active_pathway_status = f8 WITH constant(uar_get_code_by("MEANING",4003198,"ACTIVE")),
   protect
   DECLARE existingpathwayid = f8 WITH noconstant(- (1)), protect
   SELECT INTO "NL:"
    FROM cp_pathway cp
    WHERE cp.logical_domain_id=logicaldomainid
     AND cnvtupper(cp.pathway_name)=cnvtupper(pathwayname)
     AND cp.pathway_status_cd=active_pathway_status
     AND cp.pathway_type_cd=pathwaytypecd
    DETAIL
     existingpathwayid = cp.cp_pathway_id
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build("ExistingPathwayId: ",existingpathwayid))
   ENDIF
   CALL log_message(build("Exit CheckForExistingPathway(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(existingpathwayid)
 END ;Subroutine
 SUBROUTINE (decodexmlspecialcharacters(identifier=vc) =vc WITH protect)
   CALL log_message("In decodeXmlSpecialCharacters()",log_level_debug)
   SET identifier = replace(identifier,"&gt;",">",0)
   SET identifier = replace(identifier,"&lt;","<",0)
   SET identifier = replace(identifier,"&#34;",'"',0)
   SET identifier = replace(identifier,"&#39;","'",0)
   RETURN(identifier)
   CALL log_message("Exit decodeXmlSpecialCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (encodeinternationalcharacters(stringtoencode=vc) =vc WITH protect)
   CALL log_message("In encodeInternationalCharacters()",log_level_debug)
   DECLARE encodedstring = vc WITH protect, noconstant(stringtoencode)
   SET encodedstring = replace(encodedstring,"","~#192;",0)
   SET encodedstring = replace(encodedstring,"","~#193;",0)
   SET encodedstring = replace(encodedstring,"","~#194;",0)
   SET encodedstring = replace(encodedstring,"","~#195;",0)
   SET encodedstring = replace(encodedstring,"","~#196;",0)
   SET encodedstring = replace(encodedstring,"","~#197;",0)
   SET encodedstring = replace(encodedstring,"","~#198;",0)
   SET encodedstring = replace(encodedstring,"","~#199;",0)
   SET encodedstring = replace(encodedstring,"","~#200;",0)
   SET encodedstring = replace(encodedstring,"","~#201;",0)
   SET encodedstring = replace(encodedstring,"","~#202;",0)
   SET encodedstring = replace(encodedstring,"","~#203;",0)
   SET encodedstring = replace(encodedstring,"","~#204;",0)
   SET encodedstring = replace(encodedstring,"","~#205;",0)
   SET encodedstring = replace(encodedstring,"","~#206;",0)
   SET encodedstring = replace(encodedstring,"","~#207;",0)
   SET encodedstring = replace(encodedstring,"","~#208;",0)
   SET encodedstring = replace(encodedstring,"","~#209;",0)
   SET encodedstring = replace(encodedstring,"","~#210;",0)
   SET encodedstring = replace(encodedstring,"","~#211;",0)
   SET encodedstring = replace(encodedstring,"","~#212;",0)
   SET encodedstring = replace(encodedstring,"","~#213;",0)
   SET encodedstring = replace(encodedstring,"","~#214;",0)
   SET encodedstring = replace(encodedstring,"","~#216;",0)
   SET encodedstring = replace(encodedstring,"","~#217;",0)
   SET encodedstring = replace(encodedstring,"","~#218;",0)
   SET encodedstring = replace(encodedstring,"","~#219;",0)
   SET encodedstring = replace(encodedstring,"","~#220;",0)
   SET encodedstring = replace(encodedstring,"","~#221;",0)
   SET encodedstring = replace(encodedstring,"","~#222;",0)
   SET encodedstring = replace(encodedstring,"","~#223;",0)
   SET encodedstring = replace(encodedstring,"","~#224;",0)
   SET encodedstring = replace(encodedstring,"","~#225;",0)
   SET encodedstring = replace(encodedstring,"","~#226;",0)
   SET encodedstring = replace(encodedstring,"","~#227;",0)
   SET encodedstring = replace(encodedstring,"","~#228;",0)
   SET encodedstring = replace(encodedstring,"","~#229;",0)
   SET encodedstring = replace(encodedstring,"","~#230;",0)
   SET encodedstring = replace(encodedstring,"","~#231;",0)
   SET encodedstring = replace(encodedstring,"","~#232;",0)
   SET encodedstring = replace(encodedstring,"","~#233;",0)
   SET encodedstring = replace(encodedstring,"","~#234;",0)
   SET encodedstring = replace(encodedstring,"","~#235;",0)
   SET encodedstring = replace(encodedstring,"","~#236;",0)
   SET encodedstring = replace(encodedstring,"","~#237;",0)
   SET encodedstring = replace(encodedstring,"","~#238;",0)
   SET encodedstring = replace(encodedstring,"","~#239;",0)
   SET encodedstring = replace(encodedstring,"","~#240;",0)
   SET encodedstring = replace(encodedstring,"","~#241;",0)
   SET encodedstring = replace(encodedstring,"","~#242;",0)
   SET encodedstring = replace(encodedstring,"","~#243;",0)
   SET encodedstring = replace(encodedstring,"","~#244;",0)
   SET encodedstring = replace(encodedstring,"","~#245;",0)
   SET encodedstring = replace(encodedstring,"","~#246;",0)
   SET encodedstring = replace(encodedstring,"","~#248;",0)
   SET encodedstring = replace(encodedstring,"","~#249;",0)
   SET encodedstring = replace(encodedstring,"","~#250;",0)
   SET encodedstring = replace(encodedstring,"","~#251;",0)
   SET encodedstring = replace(encodedstring,"","~#252;",0)
   SET encodedstring = replace(encodedstring,"","~#253;",0)
   SET encodedstring = replace(encodedstring,"","~#254;",0)
   SET encodedstring = replace(encodedstring,"","~#255;",0)
   SET encodedstring = replace(encodedstring,"","~#338;",0)
   SET encodedstring = replace(encodedstring,"","~#339;",0)
   SET encodedstring = replace(encodedstring,"","~#352;",0)
   SET encodedstring = replace(encodedstring,"","~#353;",0)
   SET encodedstring = replace(encodedstring,"","~#376;",0)
   SET encodedstring = replace(encodedstring,"","~#402;",0)
   SET encodedstring = replace(encodedstring,"","~#142;",0)
   SET encodedstring = replace(encodedstring,"","~#158;",0)
   SET encodedstring = replace(encodedstring,"","~#161;",0)
   SET encodedstring = replace(encodedstring,"","~#162;",0)
   SET encodedstring = replace(encodedstring,"","~#164;",0)
   SET encodedstring = replace(encodedstring,"","~#165;",0)
   SET encodedstring = replace(encodedstring,"","~#166;",0)
   SET encodedstring = replace(encodedstring,"","~#167;",0)
   SET encodedstring = replace(encodedstring,"","~#168;",0)
   SET encodedstring = replace(encodedstring,"","~#169;",0)
   SET encodedstring = replace(encodedstring,"","~#170;",0)
   SET encodedstring = replace(encodedstring,"","~#171;",0)
   SET encodedstring = replace(encodedstring,"","~#172;",0)
   SET encodedstring = replace(encodedstring,"","~#174;",0)
   SET encodedstring = replace(encodedstring,"","~#175;",0)
   SET encodedstring = replace(encodedstring,"","~#176;",0)
   SET encodedstring = replace(encodedstring,"","~#177;",0)
   SET encodedstring = replace(encodedstring,"","~#179;",0)
   SET encodedstring = replace(encodedstring,"","~#178;",0)
   SET encodedstring = replace(encodedstring,"","~#180;",0)
   SET encodedstring = replace(encodedstring,"","~#181;",0)
   SET encodedstring = replace(encodedstring,"","~#182;",0)
   SET encodedstring = replace(encodedstring,"","~#183;",0)
   SET encodedstring = replace(encodedstring,"","~#184;",0)
   SET encodedstring = replace(encodedstring,"","~#185;",0)
   SET encodedstring = replace(encodedstring,"","~#186;",0)
   SET encodedstring = replace(encodedstring,"","~#187;",0)
   SET encodedstring = replace(encodedstring,"","~#188;",0)
   SET encodedstring = replace(encodedstring,"","~#189;",0)
   SET encodedstring = replace(encodedstring,"","~#190;",0)
   SET encodedstring = replace(encodedstring,"","~#191;",0)
   SET encodedstring = replace(encodedstring,"","~#247;",0)
   SET encodedstring = replace(encodedstring,"","~#215;",0)
   SET encodedstring = replace(encodedstring,"","~#136;",0)
   SET encodedstring = replace(encodedstring,"","~#152;",0)
   SET encodedstring = replace(encodedstring,"","~#150;",0)
   SET encodedstring = replace(encodedstring,"","~#151;",0)
   SET encodedstring = replace(encodedstring,"","~#145;",0)
   SET encodedstring = replace(encodedstring,"","~#146;",0)
   SET encodedstring = replace(encodedstring,"","~#130;",0)
   SET encodedstring = replace(encodedstring,"","~#147;",0)
   SET encodedstring = replace(encodedstring,"","~#148;",0)
   SET encodedstring = replace(encodedstring,"","~#132;",0)
   SET encodedstring = replace(encodedstring,"","~#134;",0)
   SET encodedstring = replace(encodedstring,"","~#135;",0)
   SET encodedstring = replace(encodedstring,"","~#149;",0)
   SET encodedstring = replace(encodedstring,"","~#133;",0)
   SET encodedstring = replace(encodedstring,"","~#137;",0)
   SET encodedstring = replace(encodedstring,"","~#139;",0)
   SET encodedstring = replace(encodedstring,"","~#155;",0)
   SET encodedstring = replace(encodedstring,"","~#128;",0)
   SET encodedstring = replace(encodedstring,"","~#153;",0)
   SET encodedstring = replace(encodedstring,"","~#163;",0)
   RETURN(encodedstring)
   CALL log_message("Exit encodeInternationalCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (decodeinternationalcharacters(stringtodecode=vc) =vc WITH protect)
   CALL log_message("In decodeInternationalCharacters()",log_level_debug)
   DECLARE decodedstring = vc WITH protect, noconstant(stringtodecode)
   SET decodedstring = replace(decodedstring,"~#192;","",0)
   SET decodedstring = replace(decodedstring,"~#193;","",0)
   SET decodedstring = replace(decodedstring,"~#194;","",0)
   SET decodedstring = replace(decodedstring,"~#195;","",0)
   SET decodedstring = replace(decodedstring,"~#196;","",0)
   SET decodedstring = replace(decodedstring,"~#197;","",0)
   SET decodedstring = replace(decodedstring,"~#198;","",0)
   SET decodedstring = replace(decodedstring,"~#199;","",0)
   SET decodedstring = replace(decodedstring,"~#200;","",0)
   SET decodedstring = replace(decodedstring,"~#201;","",0)
   SET decodedstring = replace(decodedstring,"~#202;","",0)
   SET decodedstring = replace(decodedstring,"~#203;","",0)
   SET decodedstring = replace(decodedstring,"~#204;","",0)
   SET decodedstring = replace(decodedstring,"~#205;","",0)
   SET decodedstring = replace(decodedstring,"~#206;","",0)
   SET decodedstring = replace(decodedstring,"~#207;","",0)
   SET decodedstring = replace(decodedstring,"~#208;","",0)
   SET decodedstring = replace(decodedstring,"~#209;","",0)
   SET decodedstring = replace(decodedstring,"~#210;","",0)
   SET decodedstring = replace(decodedstring,"~#211;","",0)
   SET decodedstring = replace(decodedstring,"~#212;","",0)
   SET decodedstring = replace(decodedstring,"~#213;","",0)
   SET decodedstring = replace(decodedstring,"~#214;","",0)
   SET decodedstring = replace(decodedstring,"~#216;","",0)
   SET decodedstring = replace(decodedstring,"~#217;","",0)
   SET decodedstring = replace(decodedstring,"~#218;","",0)
   SET decodedstring = replace(decodedstring,"~#219;","",0)
   SET decodedstring = replace(decodedstring,"~#220;","",0)
   SET decodedstring = replace(decodedstring,"~#221;","",0)
   SET decodedstring = replace(decodedstring,"~#222;","",0)
   SET decodedstring = replace(decodedstring,"~#223;","",0)
   SET decodedstring = replace(decodedstring,"~#224;","",0)
   SET decodedstring = replace(decodedstring,"~#225;","",0)
   SET decodedstring = replace(decodedstring,"~#226;","",0)
   SET decodedstring = replace(decodedstring,"~#227;","",0)
   SET decodedstring = replace(decodedstring,"~#228;","",0)
   SET decodedstring = replace(decodedstring,"~#229;","",0)
   SET decodedstring = replace(decodedstring,"~#230;","",0)
   SET decodedstring = replace(decodedstring,"~#231;","",0)
   SET decodedstring = replace(decodedstring,"~#232;","",0)
   SET decodedstring = replace(decodedstring,"~#233;","",0)
   SET decodedstring = replace(decodedstring,"~#234;","",0)
   SET decodedstring = replace(decodedstring,"~#235;","",0)
   SET decodedstring = replace(decodedstring,"~#236;","",0)
   SET decodedstring = replace(decodedstring,"~#237;","",0)
   SET decodedstring = replace(decodedstring,"~#238;","",0)
   SET decodedstring = replace(decodedstring,"~#239;","",0)
   SET decodedstring = replace(decodedstring,"~#240;","",0)
   SET decodedstring = replace(decodedstring,"~#241;","",0)
   SET decodedstring = replace(decodedstring,"~#242;","",0)
   SET decodedstring = replace(decodedstring,"~#243;","",0)
   SET decodedstring = replace(decodedstring,"~#244;","",0)
   SET decodedstring = replace(decodedstring,"~#245;","",0)
   SET decodedstring = replace(decodedstring,"~#246;","",0)
   SET decodedstring = replace(decodedstring,"~#248;","",0)
   SET decodedstring = replace(decodedstring,"~#249;","",0)
   SET decodedstring = replace(decodedstring,"~#250;","",0)
   SET decodedstring = replace(decodedstring,"~#251;","",0)
   SET decodedstring = replace(decodedstring,"~#252;","",0)
   SET decodedstring = replace(decodedstring,"~#253;","",0)
   SET decodedstring = replace(decodedstring,"~#254;","",0)
   SET decodedstring = replace(decodedstring,"~#255;","",0)
   SET decodedstring = replace(decodedstring,"~#338;","",0)
   SET decodedstring = replace(decodedstring,"~#339;","",0)
   SET decodedstring = replace(decodedstring,"~#352;","",0)
   SET decodedstring = replace(decodedstring,"~#353;","",0)
   SET decodedstring = replace(decodedstring,"~#376;","",0)
   SET decodedstring = replace(decodedstring,"~#402;","",0)
   SET decodedstring = replace(decodedstring,"~#142;","",0)
   SET decodedstring = replace(decodedstring,"~#158;","",0)
   SET decodedstring = replace(decodedstring,"~#161;","",0)
   SET decodedstring = replace(decodedstring,"~#162;","",0)
   SET decodedstring = replace(decodedstring,"~#164;","",0)
   SET decodedstring = replace(decodedstring,"~#165;","",0)
   SET decodedstring = replace(decodedstring,"~#166;","",0)
   SET decodedstring = replace(decodedstring,"~#167;","",0)
   SET decodedstring = replace(decodedstring,"~#168;","",0)
   SET decodedstring = replace(decodedstring,"~#169;","",0)
   SET decodedstring = replace(decodedstring,"~#170;","",0)
   SET decodedstring = replace(decodedstring,"~#171;","",0)
   SET decodedstring = replace(decodedstring,"~#172;","",0)
   SET decodedstring = replace(decodedstring,"~#174;","",0)
   SET decodedstring = replace(decodedstring,"~#175;","",0)
   SET decodedstring = replace(decodedstring,"~#176;","",0)
   SET decodedstring = replace(decodedstring,"~#177;","",0)
   SET decodedstring = replace(decodedstring,"~#178;","",0)
   SET decodedstring = replace(decodedstring,"~#179;","",0)
   SET decodedstring = replace(decodedstring,"~#180;","",0)
   SET decodedstring = replace(decodedstring,"~#181;","",0)
   SET decodedstring = replace(decodedstring,"~#182;","",0)
   SET decodedstring = replace(decodedstring,"~#183;","",0)
   SET decodedstring = replace(decodedstring,"~#184;","",0)
   SET decodedstring = replace(decodedstring,"~#185;","",0)
   SET decodedstring = replace(decodedstring,"~#186;","",0)
   SET decodedstring = replace(decodedstring,"~#187;","",0)
   SET decodedstring = replace(decodedstring,"~#188;","",0)
   SET decodedstring = replace(decodedstring,"~#189;","",0)
   SET decodedstring = replace(decodedstring,"~#190;","",0)
   SET decodedstring = replace(decodedstring,"~#191;","",0)
   SET decodedstring = replace(decodedstring,"~#247;","",0)
   SET decodedstring = replace(decodedstring,"~#215;","",0)
   SET decodedstring = replace(decodedstring,"~#136;","",0)
   SET decodedstring = replace(decodedstring,"~#152;","",0)
   SET decodedstring = replace(decodedstring,"~#150;","",0)
   SET decodedstring = replace(decodedstring,"~#151;","",0)
   SET decodedstring = replace(decodedstring,"~#145;","",0)
   SET decodedstring = replace(decodedstring,"~#146;","",0)
   SET decodedstring = replace(decodedstring,"~#130;","",0)
   SET decodedstring = replace(decodedstring,"~#147;","",0)
   SET decodedstring = replace(decodedstring,"~#148;","",0)
   SET decodedstring = replace(decodedstring,"~#132;","",0)
   SET decodedstring = replace(decodedstring,"~#134;","",0)
   SET decodedstring = replace(decodedstring,"~#135;","",0)
   SET decodedstring = replace(decodedstring,"~#149;","",0)
   SET decodedstring = replace(decodedstring,"~#133;","",0)
   SET decodedstring = replace(decodedstring,"~#137;","",0)
   SET decodedstring = replace(decodedstring,"~#139;","",0)
   SET decodedstring = replace(decodedstring,"~#155;","",0)
   SET decodedstring = replace(decodedstring,"~#128;","",0)
   SET decodedstring = replace(decodedstring,"~#153;","",0)
   SET decodedstring = replace(decodedstring,"~#163;","",0)
   RETURN(decodedstring)
   CALL log_message("Exit decodeInternationalCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (checkforexistingconcept(conceptdisplay=vc) =f8 WITH protect)
   CALL log_message("Begin CheckForExistingConcept()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE conceptcodeset = i4 WITH constant(4003132), protect
   DECLARE conceptid = f8 WITH noconstant(- (1)), protect
   DECLARE displaykey = vc WITH noconstant(""), protect
   SET displaykey = trim(cnvtupper(cnvtalphanum(substring(1,40,conceptdisplay))))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=conceptcodeset
     AND cv.display_key=displaykey
     AND cv.active_ind=1
    DETAIL
     conceptid = cv.code_value
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build("ExistingConceptId: ",conceptid))
   ENDIF
   CALL log_message(build("Exit CheckForExistingConcept(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(conceptid)
 END ;Subroutine
 SUBROUTINE filterdoccomponentdetails(null)
   CALL log_message("In filterDocComponentDetails()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE node_cntr = i4 WITH noconstant(0), protect
   DECLARE node_size = i4 WITH noconstant(0), protect
   DECLARE act_node_size = i4 WITH noconstant(0), protect
   DECLARE act_node_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_det_indx = i4 WITH noconstant(0), protect
   DECLARE search_cntr = i4 WITH noconstant(0), protect
   DECLARE cur_comp_det_version_nbr = i4 WITH noconstant(0), protect
   DECLARE latest_doc_content_det_indx = i4 WITH noconstant(0), protect
   DECLARE latest_doc_events_det_indx = i4 WITH noconstant(0), protect
   DECLARE latest_doc_decor_det_indx = i4 WITH noconstant(0), protect
   DECLARE comp_det_doc_content_mean = vc WITH constant("DOCCONTENT"), protect
   DECLARE comp_det_doc_events_mean = vc WITH constant("DOCEVENTS"), protect
   DECLARE comp_det_term_dec_mean = vc WITH constant("DOCTERMDEC"), protect
   SET node_size = size(reply->node_list,5)
   SET act_node_size = size(reply->pathway_instance.pathway_actions.node_list,5)
   FOR (node_cntr = 1 TO node_size)
     SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].component_list,5),
      "GUIDEDTRMNT",reply->node_list[node_cntr].component_list[search_cntr].comp_type_cd_meaning)
     IF (doc_comp_indx=0)
      SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].component_list,5),
       "PATHWAY_DOC",reply->node_list[node_cntr].component_list[search_cntr].comp_type_cd_meaning)
     ENDIF
     IF (doc_comp_indx > 0)
      SET latest_doc_content_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
       comp_det_doc_content_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
       comp_detail_list[search_cntr].detail_reltn_cd_mean)
      IF (latest_doc_content_det_indx > 0)
       SET reply->node_list[node_cntr].current_assoc_doc_instance_ident = reply->node_list[node_cntr]
       .component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].entity_ident
       SET reply->node_list[node_cntr].current_assoc_doc_version_text = reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].version_text
       SET reply->node_list[node_cntr].current_assoc_doc_version_flag = reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].version_flag
       SET latest_doc_events_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
         component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
        comp_det_doc_events_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
        comp_detail_list[search_cntr].detail_reltn_cd_mean)
       IF (latest_doc_events_det_indx > 0)
        SET reply->node_list[node_cntr].current_assoc_doc_events_id = reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[latest_doc_events_det_indx].entity_id
       ENDIF
       SET latest_doc_decor_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
         component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
        comp_det_term_dec_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
        comp_detail_list[search_cntr].detail_reltn_cd_mean)
       IF (latest_doc_decor_det_indx > 0)
        SET reply->node_list[node_cntr].current_assoc_doc_decor_id = reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[latest_doc_decor_det_indx].entity_id
       ENDIF
       SET cur_comp_det_version_nbr = - (1)
       SET act_node_indx = locateval(search_cntr,1,act_node_size,reply->node_list[node_cntr].
        cp_node_id,reply->pathway_instance.pathway_actions.node_list[search_cntr].node_id)
       IF (act_node_indx > 0)
        IF (textlen(trim(reply->pathway_instance.pathway_actions.node_list[act_node_indx].
          last_saved_doc_instance_ident)) > 0)
         SET reply->node_list[node_cntr].last_saved_doc_instance_ident = reply->pathway_instance.
         pathway_actions.node_list[act_node_indx].last_saved_doc_instance_ident
         SET doc_comp_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
           component_list[doc_comp_indx].comp_detail_list,5),reply->pathway_instance.pathway_actions.
          node_list[act_node_indx].last_saved_doc_instance_ident,reply->node_list[node_cntr].
          component_list[doc_comp_indx].comp_detail_list[search_cntr].entity_ident)
         IF (doc_comp_det_indx > 0)
          SET cur_comp_det_version_nbr = reply->node_list[node_cntr].component_list[doc_comp_indx].
          comp_detail_list[doc_comp_det_indx].version_nbr
         ENDIF
        ENDIF
       ENDIF
       IF ((cur_comp_det_version_nbr > - (1)))
        CALL filtercomponentdetails(node_cntr,doc_comp_indx,build2("version_nbr = ",
          cur_comp_det_version_nbr))
       ELSE
        CALL filtercomponentdetails(node_cntr,doc_comp_indx,"default_ind = 1")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message(build("Exit filterDocComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (filtercomponentdetails(nodeindx=i4,compindx=i4,comparefield=vc) =null WITH protect)
   CALL log_message("In filterComponentDetails()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE det_cntr = i4 WITH noconstant(1), protect
   DECLARE det_size = i4 WITH noconstant(0), protect
   DECLARE to_keep = i4 WITH noconstant(0), protect
   DECLARE compare_eval = vc WITH noconstant(""), protect
   SET det_size = size(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,5)
   WHILE (det_cntr <= det_size)
     SET compare_eval = build("reply->node_list[",nodeindx,"]->component_list[",compindx,
      "]->comp_detail_list[",
      det_cntr,"].",comparefield)
     IF (validate(debug_ind,0)=1)
      CALL echo(build(" det_cntr -- > ",det_cntr))
      CALL echo(build(" det_size -- > ",det_size))
      CALL echo(build(" compare_eval -- > ",compare_eval))
      CALL echo(build(" parser(compare_eval) -- > ",parser(compare_eval)))
     ENDIF
     IF ((reply->node_list[nodeindx].component_list[compindx].comp_detail_list[det_cntr].
     detail_reltn_cd_mean="ORDEROPTS"))
      SET to_keep += 1
      SET det_cntr += 1
     ELSEIF ( NOT (parser(compare_eval)))
      SET stat = alterlist(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,(
       det_size - 1),to_keep)
      SET det_size = size(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,5)
     ELSE
      SET to_keep += 1
      SET det_cntr += 1
     ENDIF
   ENDWHILE
   CALL log_message(build("Exit filterComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(mp_common_output_imported)))
  EXECUTE mp_common_output
 ENDIF
 CALL log_message(build2("Begin program ",log_program_name),log_level_debug)
 DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
 DECLARE templateversion = i4 WITH protect, constant(cnvtint( $VRSN_NBR))
 DECLARE templateclinid = vc WITH protect, constant(encodeinternationalcharacters( $CLIN_ID))
 DECLARE datasize = i4 WITH protect, noconstant(0)
 DECLARE outbuf = vc WITH protect, noconstant(" ")
 DECLARE totlen = i4 WITH protect, noconstant(0)
 SET sdoc_reply->status_data.status = "F"
 SELECT INTO "nl:"
  bloblen = textlen(lbr.long_blob)
  FROM dd_sref_template dst,
   long_blob_reference lbr
  PLAN (dst
   WHERE dst.cln_ident=templateclinid
    AND dst.version_nbr=templateversion)
   JOIN (lbr
   WHERE lbr.long_blob_id=dst.xml_long_blob_ref_id)
  ORDER BY dst.revision_nbr DESC
  HEAD dst.version_nbr
   datasize = blobgetlen(lbr.long_blob), stat = memrealloc(outbuf,1,build("C",datasize)), totlen =
   blobget(outbuf,0,lbr.long_blob),
   sdoc_reply->sdoc_blob = notrim(decodeinternationalcharacters(outbuf))
  WITH nocounter
 ;end select
 SET sdoc_reply->status_data.status = "S"
 IF (validate(debug_ind,0))
  CALL echorecord(sdoc_reply)
 ENDIF
 CALL putjsonrecordtofile(sdoc_reply, $OUTDEV)
 FREE RECORD sdoc_reply
 CALL log_message(build("Exit Script ",log_program_name,", Elapsed time in seconds:",((curtime3 -
   begin_curtime3)/ 100.0)),log_level_debug)
END GO
