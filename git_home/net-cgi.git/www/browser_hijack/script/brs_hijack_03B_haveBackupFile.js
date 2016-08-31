function initPage()
{
	//head text
	var head_tag = document.getElementsByTagName("h1");
	var head_text = document.createTextNode(bh_settings_restoration);
	head_tag[0].appendChild(head_text);
	
	//paragrah
	var paragraph = document.getElementsByTagName("p");
	//var paragraph_text = document.createTextNode(bh_browser_file);
	//paragraph[0].appendChild(paragraph_text);
	
	
	//buttons left
	var btns_div1 = document.getElementById("btnsContainer_div1");
	if( master == "admin" )
	btns_div1.onclick = function()
	{
		return goBack();
	}
	
	var btn = btns_div1.getElementsByTagName("div");
	var btn_text = document.createTextNode(bh_back_mark);
	btn[0].appendChild(btn_text);
	
	
	//buttons right
	var btns_div2 = document.getElementById("btnsContainer_div2");
	if( master == "admin" )
	btns_div2.onclick = function()
	{
		return retoreSettings();
	}
	
	btn = btns_div2.getElementsByTagName("div");
	btn_text = document.createTextNode(bh_next_mark);
	btn[0].appendChild(btn_text);
}

function goBack()
{
	if(top.dsl_enable_flag == "0")
		this.location.href = "BRS_02_genieHelp.html";
	else	
	{
		if(top.location.href.indexOf("BRS_index.htm") > -1)
			this.location.href = "BRS_ISP_country_help.html";
		else
			this.location.href = "DSL_WIZ_sel.htm";
	}	
	return true;
}

function retoreSettings()
{
	var forms = document.getElementsByTagName("form");
	var cf = forms[0];

	var file_upgrade = document.getElementById("file_upgrade");
	var filestr = file_upgrade.value;

	if(filestr.length == 0)
	{
		alert(bh_filename_null);
		return false;
	}
	var file_format = filestr.substr(filestr.lastIndexOf(".") + 1);
	if(file_format != "cfg")
	{
		alert(bh_not_correct_file+"cfg");
		return false;
	}

	if(confirm(bh_ask_for_restore))
	{
		cf.action="/restore.cgi?/BRS_03B_haveBackupFile_fileRestore.html";
		cf.submit();
	}
	else
		return false;
}

addLoadEvent(initPage);
