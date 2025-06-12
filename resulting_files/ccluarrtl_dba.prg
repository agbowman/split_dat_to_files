CREATE PROGRAM ccluarrtl:dba
 SET trace = callecho
 SET bccluarcustexists = checkdic("CCLUARRTL_CUST","P",0)
 IF (bccluarcustexists=2)
  EXECUTE ccluarrtl_cust:dba
 ENDIF
 IF (validate(cursysbit,32)=32)
  EXECUTE ccluarrtl32:dba
  GO TO exit_script
 ENDIF
 CALL echo("ccluarrtl: declare common uar definitions.")
 DECLARE uar_get_code(p1=f8,p2=vc,p3=vc,p4=vc) = i4 WITH persist, check
 DECLARE uar_get_code_by(p1=vc,p2=i4,p3=vc) = f8 WITH persist, check
 DECLARE uar_get_code_by_cki(p1=vc) = f8 WITH persist, check
 DECLARE uar_get_code_by_description(p1=i4,p2=vc) = f8 WITH persist, check
 DECLARE uar_get_code_by_display(p1=i4,p2=vc) = f8 WITH persist, check
 DECLARE uar_get_code_by_displaykey(p1=i4,p2=vc) = f8 WITH persist, check
 DECLARE uar_get_code_by_display_ex2(p1=i4,p2=vc,p3=f8,p4=i4,p5=i4) = i4 WITH persist, check
 DECLARE uar_get_code_cki(p1=f8) = c63 WITH persist, check
 DECLARE uar_get_code_description(p1=f8) = c60 WITH persist, check
 DECLARE uar_get_code_display(p1=f8) = c40 WITH persist, check
 DECLARE uar_get_code_list_by_conceptcki(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
  p6=f8) = i4 WITH persist, check
 DECLARE uar_get_code_list_by_descr(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
  p6=f8) = i4 WITH persist, check
 DECLARE uar_get_code_list_by_dispkey(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
  p6=f8) = i4 WITH persist, check
 DECLARE uar_get_code_list_by_display(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
  p6=f8) = i4 WITH persist, check
 DECLARE uar_get_code_list_by_meaning(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
  p6=f8) = i4 WITH persist, check
 DECLARE uar_get_code_meaning(p1=f8) = c12 WITH persist, check
 DECLARE uar_get_code_value(p1=i4,p2=vc) = f8 WITH persist, check
 DECLARE uar_get_collation_seq(p1=f8) = i4 WITH persist, check
 DECLARE uar_get_conceptcki(p1=f8) = vc WITH persist, check
 DECLARE uar_get_definition(p1=f8) = c100 WITH persist, check
 DECLARE uar_get_displaykey(p1=f8) = c40 WITH persist, check
 DECLARE uar_get_meaning_by_codeset(p1=i4,p2=vc,p3=i4,p4=f8) = i4 WITH persist, check
 DECLARE uar_get_default_ref_task(p1=f8,p2=f8) = f8 WITH persist, check
 DECLARE uar_get_ref_task_by_ctf(p1=i4(value)) = f8 WITH persist, check
 DECLARE uar_ref_task_in_cache(p1=f8) = i2 WITH persist, check
 DECLARE uar_rtf(p1=vc,p2=i4,p3=vc(ref),p4=i4,p5=i4,
  p6=i4(ref,0)) = i4 WITH persist, check
 DECLARE uar_rtf2(p1=vc,p2=h(ref),p3=vc(ref),p4=h(ref),p5=h(ref),
  p6=i4(ref,0)) = i4 WITH persist, check
 DECLARE uar_syscreatehandle(p1=h(ref),p2=h(ref)) = null WITH persist
 DECLARE uar_sysdestroyhandle(p1=h(ref)) = null WITH persist
 DECLARE uar_sysevent(p1=h(ref),p4=i4(ref),p3=vc(ref),p4=vc(ref)) = null WITH persist
 DECLARE uar_syseventnc(p1=h(ref),p4=i4(ref),p3=vc(ref),p4=vc(ref)) = null WITH persist
 DECLARE uar_syssetlevel(p1=h(ref),p2=i4(ref)) = null WITH persist
 DECLARE uar_sysgetlevel(p1=h(ref),p2=i4(ref)) = null WITH persist
 DECLARE uar_eparser(p1=vc,p2=i4,p3=vc,p4=i4) = i4 WITH persist, check
 DECLARE uar_fmt_accession(p1=vc,p2=i4) = c25 WITH persist, check
 DECLARE uar_fmt_result(p1=h(ref),p2=h(ref),p3=h(ref),p4=h(ref),p5=f8(ref)) = c50 WITH persist, check
 DECLARE uar_get_tdb(p1=i4,p2=vc(ref),p3=vc(ref)) = i4 WITH persist
 DECLARE uar_get_tdbname(p1=i4) = c41 WITH persist, check
 DECLARE uar_ocf_compress(blobin=vc(ref),inlen=h(value),blobout=vc(ref),outlen=h(value),retlen=h(ref)
  ) = i4 WITH persist, check
 DECLARE uar_ocf_uncompress(blobin=vc(ref),inlen=h(value),blobout=vc(ref),outlen=h(value),retlen=h(
   ref)) = i4 WITH persist, check
 DECLARE uar_ocf_compare(compressedin=vc(ref),compressedlen=h(value),expandedin=vc(ref),expandedlen=h
  (value)) = i4 WITH persist, check
 DECLARE uar_rtf3(p1=vc(ref),p2=h(ref),p3=vc(ref),p4=h(ref),p5=h(ref)) = i4 WITH persist, check
 DECLARE uar_xml_readfile(source=vc,filehandle=h(ref)) = i4 WITH persist
 DECLARE uar_xml_closefile(filehandle=h(ref)) = null WITH persist
 DECLARE uar_xml_geterrormsg(errorcode=i4(ref)) = vc WITH persist
 DECLARE uar_xml_listtree(filehandle=h(ref)) = vc WITH persist
 DECLARE uar_xml_getroot(filehandle=h(ref),nodehandle=h(ref)) = i4 WITH persist
 DECLARE uar_xml_findchildnode(nodehandle=h(ref),nodename=vc,childhandle=h(ref)) = i4 WITH persist
 DECLARE uar_xml_getchildcount(nodehandle=h(ref)) = i4 WITH persist
 DECLARE uar_xml_getchildnode(nodehandle=h(ref),nodeno=i4(ref),childnode=h(ref)) = i4 WITH persist
 DECLARE uar_xml_getparentnode(nodehandle=h(ref),parentnode=h(ref)) = i4 WITH persist
 DECLARE uar_xml_getnodename(nodehandle=h(ref)) = vc WITH persist
 DECLARE uar_xml_getnodecontent(nodehandle=h(ref)) = vc WITH persist
 DECLARE uar_xml_getattrbyname(nodehandle=h(ref),attrname=vc,attributehandle=h(ref)) = i4 WITH
 persist
 DECLARE uar_xml_getattrbypos(nodehandle=h(ref),ndx=i4(ref),attributehandle=h(ref)) = i4 WITH persist
 DECLARE uar_xml_getattrname(attributehandle=h(ref)) = vc WITH persist
 DECLARE uar_xml_getattrvalue(attributehandle=h(ref)) = vc WITH persist
 DECLARE uar_xml_getattributevalue(nodehandle=h(ref),attrname=vc) = vc WITH persist
 DECLARE uar_xml_getattrcount(nodehandle=h(ref)) = i4 WITH persist
 DECLARE uar_xml_parsestring(xmlstring=vc,filehandle=h(ref)) = i4 WITH persist
 SET bfileiortlexists = checkdic("UAR_FILEIORTL","P",0)
 IF (bfileiortlexists=2)
  EXECUTE uar_fileiortl:dba
 ENDIF
 SET bi18nrtlexists = checkdic("UAR_I18NRTL","P",0)
 IF (bi18nrtlexists=2)
  EXECUTE uar_i18nrtl:dba
 ENDIF
#exit_script
 SET trace = nocallecho
END GO
