function initPage()
{

	//button back
	var btns_div1 = document.getElementById("btnsContainer_div1");
	if( master == "admin" )
	btns_div1.onclick = function()
	{
		return goback();
	}
	
	var btn = btns_div1.getElementsByTagName("div");
	var btn_text = document.createTextNode(bh_back_mark);
	btn[0].appendChild(btn_text);
	
	
	//button next
	var btns_div2 = document.getElementById("btnsContainer_div2");
	if( master == "admin" )
	btns_div2.onclick = function()
	{
		return help_choose_mode();
	}
	
	btn = btns_div2.getElementsByTagName("div");
	btn_text = document.createTextNode(bh_next_mark);
	btn[0].appendChild(btn_text);
}

function help_choose_mode()
{
	//choose yes or no
	var choice_div = document.getElementById("choices_div");
	var choice_radio = choice_div.getElementsByTagName("input")
	
	if(choice_radio[0].checked)
		this.location.href = "BRS_ap_detect_01_ap_01.html";
	else if(choice_radio[1].checked)
		this.location.href = "BRS_ap_detect_01_03.html";
	else
	{
		alert("You must select the Yes or No radio button.");
		return false;
	}
		
}
function goback()
{
	this.location.href = "BRS_ap_detect_01_01.html";
}
addLoadEvent(initPage);