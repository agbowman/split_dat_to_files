CREATE PROGRAM ams_pft_claim_rule_qual_audit:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Claim corsp_activity_id:" = 0,
  "Bill type:" = "",
  "Media sub type:" = ""
  WITH outdev, corsp_activity_id, bill_type,
  media_sub_type
 DECLARE dcl2(command_in=vc,fail_on_error=i2(value,0)) = i4
 DECLARE read_file(file_name=vc) = vc
 DECLARE dump_clean_xslt_files(media_sub_type=vc) = null
 DECLARE dump_clean_clm_data_xml_file(corsp_activity_id=f8) = null
 DECLARE write_custom_xslt_files(null) = null
 DECLARE xml_to_flat_rec(xml_in_name=vc,xml_out_name=vc,rec=vc(ref)) = null
 DECLARE exit_with_message(msg=vc) = null
 RECORD media_claim_rec(
   1 qual[*]
     2 item
       3 name = vc
       3 value = vc
 )
 RECORD debug_claim_rec(
   1 qual[*]
     2 item
       3 name = vc
       3 value = vc
 )
 RECORD out_rec(
   1 qual[*]
     2 field_name = vc
     2 field_value = vc
     2 dupe_idx = i4
     2 source = vc
     2 rule_id = f8
 )
 RECORD dupes(
   1 qual[*]
     2 item
       3 name = vc
       3 idx = i4
 )
 DECLARE xmlstr = vc WITH protect, noconstant(" ")
 DECLARE tmp = i4 WITH protect, noconstant(0)
 DECLARE name = vc WITH protect, noconstant("")
 DECLARE value = vc WITH protect, noconstant("")
 DECLARE field_cnt = i4 WITH protect, noconstant(0)
 DECLARE dupe_cnt = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE last_pos = i4 WITH protect, noconstant(0)
 DECLARE bill_type = vc WITH protect, constant(substring(1,1,cnvtlower( $BILL_TYPE)))
 DECLARE media_sub_type = vc WITH protect, constant(cnvtlower( $MEDIA_SUB_TYPE))
 DECLARE file_name_base = vc WITH protect, constant(concat(media_sub_type,trim(evaluate(bill_type,"r",
     "_reporting",""))))
 DECLARE timestamp = vc WITH protect, constant(format(cnvtdatetime(curdate,curtime3),
   "YYYYMMDDHHMMss;;d"))
 DECLARE timestamp_plus_5_mins = vc WITH protect, constant(format(cnvtdatetime(curdate,(curtime3+ ((
    100 * 60) * 5))),"YYYYMMDDHHMMSS;;d"))
 DECLARE dcl_error_file_name = vc WITH protect, constant("ams_pft_claim_rule_qual_audit.dclerr")
 DECLARE lock_file_name = vc WITH protect, constant("ams_pft_claim_rule_qual_audit.lock")
 DECLARE custom_pop_xslt_name = vc WITH protect, constant(concat("claimdatato",file_name_base,
   "_custompopulationtemplates.xslt"))
 DECLARE custom_pop_backup_xslt_name = vc WITH protect, constant(concat("claimdatato",file_name_base,
   "_custompopulationtemplates_backup.xslt"))
 DECLARE parent_xslt_name = vc WITH protect, constant(concat("claimdatato",file_name_base,".xslt"))
 DECLARE create_debug_xslt_name = vc WITH protect, constant(
  "createdebuggingcustompopulationtemplates.xslt")
 DECLARE to_flat_xslt_name = vc WITH protect, constant("xmltoflatattributes.xslt")
 DECLARE claim_data_xml_name = vc WITH protect, constant(build("clm_",cnvtint( $CORSP_ACTIVITY_ID),
   "_claimdata.xml"))
 DECLARE media_claim_xml_name = vc WITH protect, constant(build("clm_",cnvtint( $CORSP_ACTIVITY_ID),
   "_mediaclaim.xml"))
 DECLARE media_flat_xml_name = vc WITH protect, constant(build("clm_",cnvtint( $CORSP_ACTIVITY_ID),
   "_mediaflat.xml"))
 DECLARE media_claim_debug_xml_name = vc WITH protect, constant(build("clm_",cnvtint(
     $CORSP_ACTIVITY_ID),"_mediaclaim_debug.xml"))
 DECLARE media_flat_debug_xml_name = vc WITH protect, constant(build("clm_",cnvtint(
     $CORSP_ACTIVITY_ID),"_mediaflat_debug.xml"))
 IF (checkdic("AMS_DEFINE_TOOLKIT_COMMON","P",0)=2)
  EXECUTE ams_define_toolkit_common
  CALL updtdminfo("AMS_PFT_CLAIM_RULE_QUAL_AUDIT|RUN",cnvtreal(1))
 ENDIF
 IF (dcl2("xsltproc -version")=0)
  CALL exit_with_message(concat("Error: xsltproc not installed, contact PO"))
 ENDIF
 IF (( $CORSP_ACTIVITY_ID=0))
  CALL exit_with_message("corsp_activity required")
 ELSEIF (bill_type IN ("i", "p"))
  SELECT INTO "nl:"
   FROM prsnl pl,
    person p,
    encounter e,
    pft_encntr pe,
    benefit_order bo,
    bo_hp_reltn bhr,
    bill_reltn brn,
    bill_rec br,
    code_value cv
   PLAN (pl
    WHERE (pl.person_id=reqinfo->updt_id))
    JOIN (p
    WHERE p.logical_domain_id=pl.logical_domain_id)
    JOIN (e
    WHERE e.person_id=p.person_id)
    JOIN (pe
    WHERE pe.encntr_id=e.encntr_id)
    JOIN (bo
    WHERE bo.pft_encntr_id=pe.pft_encntr_id)
    JOIN (bhr
    WHERE bhr.benefit_order_id=bo.benefit_order_id)
    JOIN (brn
    WHERE brn.parent_entity_id=bhr.bo_hp_reltn_id
     AND brn.parent_entity_name="BO_HP_RELTN")
    JOIN (br
    WHERE br.corsp_activity_id=brn.corsp_activity_id
     AND (br.corsp_activity_id= $CORSP_ACTIVITY_ID))
    JOIN (cv
    WHERE cv.code_value=br.bill_type_cd
     AND cv.cdf_meaning IN ("HCFA_1450", "HCFA_1500"))
  ;end select
  IF (curqual=0)
   CALL exit_with_message("Invalid institutional or professional claim")
  ENDIF
 ELSEIF (bill_type="r")
  SELECT INTO "nl:"
   FROM prsnl pl,
    person p,
    encounter e,
    pft_encntr pe,
    bill_reltn brn,
    bill_rec br,
    code_value cv
   PLAN (pl
    WHERE (pl.person_id=reqinfo->updt_id))
    JOIN (p
    WHERE p.logical_domain_id=pl.logical_domain_id)
    JOIN (e
    WHERE e.person_id=p.person_id)
    JOIN (pe
    WHERE pe.encntr_id=e.encntr_id)
    JOIN (brn
    WHERE brn.parent_entity_id=pe.pft_encntr_id
     AND brn.parent_entity_name="PFT_ENCNTR")
    JOIN (br
    WHERE br.corsp_activity_id=brn.corsp_activity_id
     AND (br.corsp_activity_id= $CORSP_ACTIVITY_ID))
    JOIN (cv
    WHERE cv.code_value=br.bill_type_cd
     AND cv.cdf_meaning="RPT_CLAIM")
  ;end select
  IF (curqual=0)
   CALL exit_with_message("Invalid report claim")
  ENDIF
 ELSE
  CALL exit_with_message(concat("Unsupported claim type: '",bill_type,"'"))
 ENDIF
 SET stat = dcl2("cd $CCLUSERDIR")
 IF (findfile(lock_file_name)=1)
  IF (read_file(lock_file_name) > timestamp)
   CALL exit_with_message("This script is already being run on this node, try again soon")
  ENDIF
 ENDIF
 SET stat = dcl2(concat("echo '",timestamp_plus_5_mins,"' > '",lock_file_name,"'"))
 CALL dump_clean_xslt_files(media_sub_type)
 CALL write_custom_xslt_files(null)
 CALL dump_clean_clm_data_xml_file(cnvtreal( $CORSP_ACTIVITY_ID))
 SET stat = dcl2(concat("xsltproc '",parent_xslt_name,"' '",claim_data_xml_name,"' > '",
   media_claim_xml_name,"'"),1)
 CALL xml_to_flat_rec(media_claim_xml_name,media_flat_xml_name,media_claim_rec)
 SET stat = dcl2(concat("mv ",custom_pop_xslt_name," ",custom_pop_backup_xslt_name))
 SET stat = dcl2(concat("xsltproc '",create_debug_xslt_name,"' '",custom_pop_backup_xslt_name,"' > '",
   custom_pop_xslt_name,"'"),1)
 SET stat = dcl2(concat("xsltproc '",parent_xslt_name,"' '",claim_data_xml_name,"' > '",
   media_claim_debug_xml_name,"'"),1)
 CALL xml_to_flat_rec(media_claim_debug_xml_name,media_flat_debug_xml_name,debug_claim_rec)
 SET field_cnt = size(debug_claim_rec->qual,5)
 SET stat = alterlist(out_rec->qual,field_cnt)
 FOR (i = 1 TO field_cnt)
   SET name = debug_claim_rec->qual[i].item.name
   SET value = debug_claim_rec->qual[i].item.value
   SET out_rec->qual[i].field_name = name
   SET dupe_cnt = size(dupes->qual,5)
   SET pos = locateval(tmp,1,dupe_cnt,name,dupes->qual[tmp].item.name)
   IF (pos=0)
    SET pos = (dupe_cnt+ 1)
    SET stat = alterlist(dupes->qual,pos)
    SET dupes->qual[pos].item.name = name
    SET dupes->qual[pos].item.idx = 1
   ELSE
    SET dupes->qual[pos].item.idx = (dupes->qual[pos].item.idx+ 1)
   ENDIF
   SET out_rec->qual[i].dupe_idx = dupes->qual[pos].item.idx
   IF (substring(1,11,value)="$resultRule")
    SET out_rec->qual[i].rule_id = cnvtreal(cnvtalphanum(value,1))
    SELECT INTO "nl:"
     FROM pft_rule pr
     WHERE (pr.rule_id=out_rec->qual[i].rule_id)
     DETAIL
      out_rec->qual[i].source = concat(pr.rule_name)
     WITH nocounter
    ;end select
   ELSEIF (value="STANDARD")
    SET out_rec->qual[i].source = "(standard)"
   ELSE
    SET out_rec->qual[i].source = "(n/a)"
   ENDIF
   SET pos = locateval(tmp,last_pos,size(media_claim_rec->qual,5),name,media_claim_rec->qual[tmp].
    item.name)
   IF (pos > 0)
    SET out_rec->qual[i].field_value = media_claim_rec->qual[pos].item.value
    SET last_pos = pos
   ENDIF
 ENDFOR
 SET stat = dcl2(concat("rm ",lock_file_name))
 SET field_cnt = size(out_rec->qual,5)
 SELECT INTO value( $OUTDEV)
  idx = substring(1,4,build(out_rec->qual[d.seq].dupe_idx)), field = substring(1,100,out_rec->qual[d
   .seq].field_name), value = substring(1,100,out_rec->qual[d.seq].field_value),
  source = substring(1,100,out_rec->qual[d.seq].source), rule_id = evaluate(out_rec->qual[d.seq].
   rule_id,0,"",cnvtstring(out_rec->qual[d.seq].rule_id))
  FROM (dummyt d  WITH seq = value(field_cnt))
  WITH heading, format
 ;end select
 SUBROUTINE dcl2(command_in,fail_on_error)
   DECLARE dclerror = vc WITH protect, noconstant("")
   DECLARE status = i4 WITH protect, noconstant(0)
   DECLARE command = vc WITH protect, constant(concat(command_in,' 2>"',dcl_error_file_name,'"'))
   CALL dcl(command,size(command),status)
   CALL echo(build("dcl:",status,":",command))
   IF (status != 1
    AND fail_on_error=1)
    SET dclerror = read_file(dcl_error_file_name)
    SET stat = dcl2(concat("rm ",lock_file_name))
    CALL exit_with_message(concat("OS COMMAND ERROR: ",dclerror))
   ELSE
    RETURN(status)
   ENDIF
 END ;Subroutine
 SUBROUTINE read_file(file_name)
   DECLARE output = vc WITH protect, noconstant(" ")
   FREE DEFINE rtl2
   DEFINE rtl2 value(file_name)
   SELECT INTO "nl:"
    FROM rtl2t r
    DETAIL
     output = build(output,r.line)
    WITH nocounter
   ;end select
   RETURN(output)
 END ;Subroutine
 SUBROUTINE dump_clean_xslt_files(media_sub_type)
   DECLARE unduplicate_xslt(file_name_no_ext=vc) = null
   DECLARE file_name_base = vc WITH protect, constant(concat("claimdatato",media_sub_type))
   SET stat = dcl2("rm *.xslt")
   EXECUTE pft_clm_util_dump_xslt_files
   IF (substring(4,1,media_sub_type) != "r")
    SET stat = dcl2(concat(
      "sed -i 's/\(Reporting_\)\{0,1\}StandardPopulationTemplates.xslt/spt.xslt/g' ",file_name_base,
      "*.xslt"))
    SET stat = dcl2(concat(
      "sed -i 's/\(Reporting_\)\{0,1\}DefaultPopulationTemplates.xslt/dpt.xslt/g' ",file_name_base,
      "*.xslt"))
   ELSE
    SET stat = dcl2(concat("sed -i 's/StandardPopulationTemplates.xslt/spt.xslt/g' ",file_name_base,
      "*.xslt"))
    SET stat = dcl2(concat("sed -i 's/DefaultPopulationTemplates.xslt/dpt.xslt/g' ",file_name_base,
      "*.xslt"))
   ENDIF
   SET stat = dcl2("mv claimdatato837i4010_standardpop.xslt claimdatato837i4010_spt.xslt")
   SET stat = dcl2("mv claimdatato837i4010_defaultpop.xslt claimdatato837i4010_dpt.xslt")
   SET stat = dcl2(
    "mv claimdatato837i4010_standardform.xslt claimdatato837i4010_StandardFormattingTemplates.xslt")
   SET stat = dcl2("mv claimdatato837p4010_standardpop.xslt claimdatato837p4010_spt.xslt")
   SET stat = dcl2("mv claimdatato837p4010_defaultpop.xslt claimdatato837p4010_dpt.xslt")
   SET stat = dcl2(
    "mv claimdatato837p4010_standardform.xslt claimdatato837p4010_StandardFormattingTemplates.xslt")
   SET stat = dcl2(concat("sed -i 's/ClaimDataTo837/claimdatato837/g' claimdatato837*.xslt"))
   SET stat = dcl2(concat(
     "sed -i 's/CustomPopulationTemplates/custompopulationtemplates/g' claimdatato837*.xslt"))
   SET stat = dcl2(concat("sed -i 's/GlobalTemplates/globaltemplates/g' claimdatato837*.xslt"))
   SET stat = dcl2(concat("sed -i 's/_Reporting_/_reporting_/g' ",file_name_base,"*.xslt"))
   SET dxmeanings = concat(
    "concat((\/claimData\/context\/institutionalClaim\/preferences\/ICDPreferenceMode |",
    "\/claimData\/context\/professionalClaim\/preferences\/ICDPreferenceMode | ",
    "\/claimData\/context\/reportClaim\/preferences\/ICDPreferenceMode), ',', ",
    "concat(\/claimData\/context\/primaryICDDiagnosisMeaning,\/claimData\/context\/secondaryICDDiagnosisMeaning),',', 'ICD9')"
    )
   SET stat = dcl2(concat('sed -i "s/\$diagnosisMeanings/',dxmeanings,
     '/g" claimdatato837p5010_spt.xslt'))
   SET stat = dcl2(concat("sed -i 's/paramname/param name/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/paramname/param name/g' globaltemplates*")
   SET stat = dcl2(concat("sed -i 's/whentest/when test/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/whentest/when test/g' globaltemplates*")
   SET stat = dcl2(concat("sed -i 's/ofselect/of select/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/ofselect/of select/g' globaltemplates*")
   SET stat = dcl2(concat("sed -i 's/templatename/template name/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/templatename/template name/g' globaltemplates*")
   SET stat = dcl2(concat("sed -i 's/",char(34),"select=/",char(34)," select=/g' ",
     file_name_base,"*.xslt"))
   SET stat = dcl2(concat("sed -i 's/",char(34),"select=/",char(34)," select=/g' globaltemplates*"))
   SET stat = dcl2(concat("sed -i 's/variablename=/variable name=/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/variablename=/variable name=/g' globaltemplates*")
   SET stat = dcl2(concat("sed -i 's/indexand/index and/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/indexand/index and/g' globaltemplates*")
   SET stat = dcl2(concat("sed -i 's/iftest/if test/g' ",file_name_base,"*.xslt"))
   SET stat = dcl2("sed -i 's/iftest/if test/g' globaltemplates*")
   CALL unduplicate_xslt(concat(file_name_base))
   CALL unduplicate_xslt(concat(file_name_base,"_spt"))
   CALL unduplicate_xslt(concat(file_name_base,"_dpt"))
   CALL unduplicate_xslt(concat(file_name_base,"_custompopulationtemplates"))
   SUBROUTINE unduplicate_xslt(file_name_no_ext)
     SET stat = dcl2(concat("mv ",file_name_no_ext,".xslt ",file_name_no_ext,"_0.xslt"))
     SET stat = dcl2(concat("tr -d '\n' < ",file_name_no_ext,"_0.xslt > ",file_name_no_ext,".xslt"))
     SET stat = dcl2(concat("sed -i 's/<\/xsl:stylesheet>.*/<\/xsl:stylesheet>/g' ",file_name_no_ext,
       ".xslt"))
   END ;Subroutine
 END ;Subroutine
 SUBROUTINE dump_clean_clm_data_xml_file(corsp_activity_id)
   FREE RECORD grec
   RECORD grec(
     1 objarray[*]
       2 xml = gvc
   )
   DECLARE claim_data_xml_name = vc WITH protect, constant(build("clm_",cnvtint(corsp_activity_id),
     "_claimdata.xml"))
   DECLARE row_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    bloblen = blobgetlen(lb.long_blob)
    FROM br_long_blob_reltn blb,
     long_blob lb
    PLAN (blb
     WHERE blb.corsp_activity_id=corsp_activity_id
      AND blb.data_type_flag=1
      AND blb.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND blb.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND blb.active_ind=true)
     JOIN (lb
     WHERE lb.long_blob_id=blb.long_blob_id
      AND lb.parent_entity_name="PFT_PENDING_BILL"
      AND lb.active_ind=1)
    HEAD REPORT
     outbuf = " ", offset = 0, pos = 0
    DETAIL
     retlen = 1, stat = memrealloc(outbuf,1,build("C",bloblen)), retlen = blobget(outbuf,offset,lb
      .long_blob)
     WHILE (offset < bloblen)
       row_cnt = (row_cnt+ 1), searchable = substring(offset,500,outbuf), pos = findstring("><",
        searchable)
       IF (pos=0)
        pos = findstring(concat(char(32)),searchable)
       ENDIF
       IF (row_cnt != 2)
        stat = alterlist(grec->objarray,row_cnt), grec->objarray[row_cnt].xml = substring(offset,pos,
         outbuf)
       ENDIF
       IF (pos=0)
        pos = bloblen
       ENDIF
       offset = (offset+ pos)
     ENDWHILE
     row_cnt = (row_cnt+ 1), stat = alterlist(grec->objarray,row_cnt)
    WITH nocounter, rdbarrayfetch = 1
   ;end select
   SET stat = remove(claim_data_xml_name)
   FOR (idx = 1 TO row_cnt)
     SELECT INTO value(claim_data_xml_name)
      check(grec->objarray[idx].xml,char(13))
      FROM dummyt
      WITH append, noheading
     ;end select
   ENDFOR
 END ;Subroutine
 SUBROUTINE write_custom_xslt_files(null)
   DECLARE file_contents = vc WITH noconstant("")
   SET file_contents = concat('<?xml version="1.0" encoding="UTF-8"?>',
    '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">',
    '  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />',
    "  <!-- Duplicate existing rules -->",'  <xsl:template match="node()|@*">',
    "    <xsl:copy>",'      <xsl:apply-templates select="node()|@*" />',"    </xsl:copy>",
    "  </xsl:template>",'  <!-- Modify "regular" rules to output rule ID qualification  -->',
    '  <xsl:template match="/xsl:stylesheet/xsl:template/xsl:choose/xsl:when/xsl:value-of/@select">',
    '    <xsl:attribute name="select">',
    ^      <xsl:value-of select="concat('&quot;', ../../@test, '&quot;')" />^,"    </xsl:attribute>",
    "  </xsl:template>",
    '  <!-- Modify "list" rules to output rule ID qualification -->',
    ^  <xsl:template match="/xsl:stylesheet/xsl:template[substring(@name, 1, 7)='custom_']^,
    ^/xsl:variable/xsl:choose/xsl:when/xsl:call-template/xsl:with-param[@name='value1']/@select">^,
    '    <xsl:attribute name="select">',
    ^      <xsl:value-of select="concat('&quot;', ../../../@test, '&quot;')" />^,
    "    </xsl:attribute>","  </xsl:template>",
    '  <!-- Modify all $default values to output "STANDARD"  -->',
    ^  <xsl:template match="//xsl:value-of[@select='$default']/@select">^,
    '    <xsl:attribute name="select">',
    ^      <xsl:value-of select="'&quot;STANDARD&quot;'" />^,"    </xsl:attribute>",
    "  </xsl:template>","</xsl:stylesheet>")
   SELECT INTO value(create_debug_xslt_name)
    file_contents
    FROM dummyt
    WITH noheading
   ;end select
   SET file_contents = concat('<?xml version="1.0" encoding="UTF-8"?>',
    '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">',
    '  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />',
    '  <xsl:template match="/">',"    <xmlroot>",
    '      <xsl:element name="qual">','        <xsl:attribute name="type">',
    ^          <xsl:value-of select="'LIST'" />^,"        </xsl:attribute>",
    '        <xsl:attribute name="memberCount">',
    '          <xsl:value-of select="count(//@*)" />',"        </xsl:attribute>",
    '        <xsl:for-each select="//@*">','          <xsl:element name="item">',
    '            <xsl:attribute name="name">',
    '              <xsl:value-of select="name()" />',"            </xsl:attribute>",
    '            <xsl:attribute name="value">','              <xsl:value-of select="." />',
    "            </xsl:attribute>",
    "          </xsl:element>","        </xsl:for-each>","      </xsl:element>","    </xmlroot>",
    "  </xsl:template>",
    "</xsl:stylesheet>")
   SELECT INTO value(to_flat_xslt_name)
    file_contents
    FROM dummyt
    WITH noheading
   ;end select
 END ;Subroutine
 SUBROUTINE xml_to_flat_rec(xml_in_name,xml_out_name,rec)
   RECORD xmlroot(
     1 qual[*]
       2 item
         3 name = vc
         3 value = vc
   )
   SET stat = dcl2(concat("xsltproc '",to_flat_xslt_name,"' '",xml_in_name,"' > '",
     xml_out_name,"'"),1)
   SET xmlstr = read_file(xml_out_name)
   SET stat = cnvtxmltorec(xmlstr)
   SET stat = moverec(xmlroot->qual,rec->qual)
 END ;Subroutine
 SUBROUTINE exit_with_message(msg)
   IF (checkdic("AMS_DEFINE_TOOLKIT_COMMON","P",0)=2)
    CALL updtdminfo("AMS_PFT_CLAIM_RULE_QUAL_AUDIT|FAIL",cnvtreal(1))
   ENDIF
   SELECT INTO value( $OUTDEV)
    script_output = msg
    FROM dual
    WITH heading, format
   ;end select
   GO TO exit_script
 END ;Subroutine
#exit_script
 SET last_mod = "000 07/22/16 PG024427 Initial relase"
END GO
