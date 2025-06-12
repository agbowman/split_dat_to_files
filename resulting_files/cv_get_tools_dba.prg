CREATE PROGRAM cv_get_tools:dba
 IF (validate(cv_get_tools_vrsn,char(128))=char(128))
  DECLARE cv_get_tools_vrsn = vc WITH constant("109082.005"), private
 ENDIF
 IF (validate(reply,char(128))=char(128))
  RECORD reply(
    1 tools[*]
      2 tool_name = vc
      2 tool_comp = vc
      2 tool_task = i4
      2 tool_icon_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE m_hgti18n = i4 WITH noconstant(0)
 SET stat = uar_i18nlocalizationinit(m_hgti18n,curprog,"",curcclrev)
 SET stat = alterlist(reply->tools,2)
 SET reply->tools[1].tool_name = uar_i18ngetmessage(m_hgti18n,"tool_prefs","Preference")
 SET reply->tools[1].tool_comp = "cvprefs.dll"
 SET reply->tools[1].tool_task = 4101000
 SET reply->tools[2].tool_name = uar_i18ngetmessage(m_hgti18n,"tool_build","Build")
 SET reply->tools[2].tool_comp = "cvbuild.dll"
 SET reply->tools[2].tool_task = 4100900
 SET reply->status_data.status = "S"
END GO
