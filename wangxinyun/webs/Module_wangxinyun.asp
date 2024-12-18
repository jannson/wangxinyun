<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>网心云（KoolCenter版）</title>
<link rel="stylesheet" type="text/css" href="index_style.css"/>
<link rel="stylesheet" type="text/css" href="form_style.css"/>
<link rel="stylesheet" type="text/css" href="usp_style.css"/>
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/device-map/device-map.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

<style> 
.Bar_container {
	width:85%;
	height:20px;
	border:1px inset #999;
	margin:0 auto;
	margin-top:20px \9;
	background-color:#FFFFFF;
	z-index:100;
}
#proceeding_img_text {
	position:absolute;
	z-index:101;
	font-size:11px;
	color:#000000;
	line-height:21px;
	width: 83%;
}
#proceeding_img {
	height:21px;
	background:#C0D1D3 url(/res/proceding.gif);
}

input[type=button]:focus {
    outline: none;
}

/* Add these new styles */
#wx_third_step_content, #wx_third_step_content_not_run, #wx_third_step_content_is_initing, #wx_third_step_content_did_bind {
    display: none;
}

</style>
<script>
var noChange_status=0;
var _responseLen;
function init() {
	show_menu(menu_hook);
	set_skin();
	get_dbus_data();
	get_run_status();
	get_disks();
	
	// Add this new line
	setupDiskPathListener();
	
	// Hide both elements initially
	$("#wx_third_step_content").hide();
	$("#wx_third_step_content_not_run").hide();
	$("#wx_third_step_content_is_initing").hide();
	$("#wx_third_step_content_did_bind").hide();
	$("#wx_bottom").hide();
}

function set_skin(){
	var SKN = '<% nvram_get("sc_skin"); %>';
	if(SKN){
		$("#app").attr("skin", '<% nvram_get("sc_skin"); %>');
	}
}

var db_wangxin = {};
function get_disks(){
	require(['/require/modules/diskList.js'], function(diskList) {
		usbDevicesList = diskList.list();
		//console.log(usbDevicesList)
		var html = '';
		html += '<thead>'
		html += '<tr>'
		html += '<td colspan="8">磁盘列表</td>'
		html += '</tr>'
		html += '</thead>'	
		html += '<tr>'
		html += '<th style="width:auto">端口</th>'
		html += '<th style="width:auto">名称</th>'
		html += '<th style="width:auto">大小</th>'
		html += '<th style="width:auto">已用</th>'
		html += '<th style="width:auto">权限</th>'
		html += '<th style="width:auto">格式</th>'
		html += '<th style="width:auto">挂载点</th>'
		html += '<th style="width:auto">路径</th>'
		html += '</tr>'
		for (var i = 0; i < usbDevicesList.length; ++i){
			for (var j = 0; j < usbDevicesList[i].partition.length; ++j){
				//append options
				$("#wx_disk_path_selected").append("<option value='"  + "/mnt/" + usbDevicesList[i].partition[j].partName + "'>" + usbDevicesList[i].partition[j].partName + "</option>");
				//check for swap exist
				console.log("getdisk: "+ E("wx_disk_path_selected").value)
				if (typeof(db_wangxin["wangxinyun_feat_disk_path_selected"]) != "undefined" && db_wangxin["wangxinyun_feat_disk_path_selected"].length > 0) {
					//do nothing
				}else{
					console.log("db_wangxin[\"wangxinyun_feat_disk_path_selected\"] is undefined")
					update_wx_cache_path();
				}
				 
				disk_format = usbDevicesList[i].partition[j].format
				if(disk_format.indexOf("ext") != -1){
					db_wangxin["swap_check_partName_" + (parseInt(i)) + "_" + (parseInt(j))] = '/mnt/' + usbDevicesList[i].partition[j].partName || "";
				}
				//write table

				var totalsize = ((usbDevicesList[i].partition[j].size)/1000000).toFixed(2);
				var usedsize = ((usbDevicesList[i].partition[j].used)/1000000).toFixed(2);
				var usedpercent = (usedsize/totalsize*100).toFixed(2) + " %";
				var used = usedsize + " GB" + " (" + usedpercent + ")"
				html += '<tr>'
				html += '<td>' + usbDevicesList[i].usbPath + '</td>'
				html += '<td>' + usbDevicesList[i].deviceName + '</td>'
				html += '<td>' + totalsize + " GB" + '</td>'
				html += '<td>' + used + '</td>'
				html += '<td>' + usbDevicesList[i].partition[j].status + '</td>'
				html += '<td>' + disk_format + '</td>'
				html += '<td>' + usbDevicesList[i].partition[j].mountPoint + '</td>'
				html += '<td>' + '/tmp/mnt/' + usbDevicesList[i].partition[j].partName + '</td>'
				html += '</tr>'
			}
		}
		if (usbDevicesList.length > 0) {
			$("#disk_status").text("已连接");
		} else {
			$("#disk_status").text("未连接");
		}
		$('#disk_table').html(html);
	});
}

function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/wangxinyun",
		dataType: "json",
		async: false,
		success: function(data) {
			db_wangxin = data.result[0];
			console.log("db_wangxin: ",db_wangxin)
			conf_to_obj();
			
			// version_show();
		}
	});
}

function get_run_status() {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "wangxinyun_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache: false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			var result = JSON.parse(response.result)
			if (result){
				console.log(result)
				E("status").innerHTML = result.status == 1 ? "已运行" : "未运行"; 
				db_wangxin["jffs_size"] = result.jffs_size;
				if (result.jffs_size < 350 * 1024 ){
					$("#wx_run_warning").html("<span >【注意】您的JFFS空间不足350MB！请使用 <a style='color: #71cdff;' href='https://github.com/koolshare/rogsoft/tree/master/usb2jffs' target='_blank'>USB2JFFS工具</a>扩容再运行！</span> ");
					
				}else{
					$("#wx_run_warning").html(result.status == 1 ? "<span >运行中，请保持设备稳定在线！</span>" : "【注意】请先连接磁盘，再开始运行！");
				}
				$("#wangxinyun_version_show").html("插件版本: " + result.version);

				if (result.status == 1) {
					$("#wx_third_step_content").show();
					$("#wx_third_step_content_not_run").hide();
					$("#wx_third_step_content_is_initing").hide();
					$("#wx_third_step_content_did_bind").hide();
					

					if (result.phone && result.phone.trim() !== "none") {
						$("#wx_third_step_content_did_bind").show();
						$("#wx_bottom").show();
						$("#wx_third_step_content").hide();

						$("#wx_phone_label").html("已绑定账号：" + result.phone);
						$("#wx_sn_label").html("设备编号：" + result.sn);
						$("#wx_third_step_title").html("第三步 - 打开网心云，查看收益");
					}else{
						$("#wx_third_step_content_did_bind").hide();
						$("#wx_bottom").hide();
							if (result.sn && result.sn.trim() !== "") {
							$("#wx_sn").html("SN: " + result.sn); 
								if (result.qrcode && result.qrcode.trim() !== "") {
								
									$("#wx_qrcode").empty(); 
									new QRCode(document.getElementById("wx_qrcode"), {
										text: result.qrcode,
										width: 105,
										height: 105,
										correctLevel: QRCode.CorrectLevel.H,  // Highest error correction level
										colorDark: "#000000",
										colorLight: "#ffffff",
										margin: 4
									});
									
									$("#wx_bottom").hide();
								}
							}else{
								$("#wx_sn").html("");
								$("#wx_third_step_content").hide();
								$("#wx_third_step_content_is_initing").show();
							}

					}
				} else {
					$("#wx_third_step_content").hide();
					$("#wx_bottom").hide();

					$("#wx_third_step_content_not_run").show();
				}

			}
			setTimeout("get_run_status();", 10000);
		},
		error: function(response) {
			setTimeout("get_run_status();", 5000);
		}
	});
}

function conf_to_obj() {
	E("wangxinyun_enable").checked = db_wangxin["wangxinyun_enable"] == "1"; 
	if (typeof db_wangxin["wangxinyun_feat_disk_path_selected"] !== "undefined"){
		E("wx_disk_path_selected").value = db_wangxin["wangxinyun_feat_disk_path_selected"];
		E("wx_cache_path").textContent = db_wangxin["wangxinyun_feat_disk_path_selected"];
	}else{ 
		// update_wx_cache_path();
	}
 
}

function onSubmitCtrl() {
	showSSLoadingBar();
	if (db_wangxin["jffs_size"] < 350 * 1024 && E("wangxinyun_enable").checked == true){
		$("#loading_block3").html("<b>【注意】您的JFFS空间不足！请使用 <a style='color: #71cdff;' href='https://github.com/koolshare/rogsoft/tree/master/usb2jffs' target='_blank'>USB2JFFS工具</a>扩容后再运行！</b>")
		setTimeout("refreshpage();", 500);
		return false;
	}
	// collect basic data 
	db_wangxin["wangxinyun_enable"] = E("wangxinyun_enable").checked ? "1" : "0";
	db_wangxin["wangxinyun_feat_disk_path_selected"] = E("wx_disk_path_selected").value + "/wx_cache";
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "wangxinyun_config.sh", "params":[], "fields": db_wangxin};

	
    $("#loading_block3").html("<b>正在提交数据！</b>等待后台运行完毕，请不要刷新页面！")
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == id) {
				$("#loading_block3").html("<b>提交成功！</b>")
				setTimeout("refreshpage();", 500);
			} else {
				$("#loading_block3").html("<b>提交失败！</b>错误代码：" + response.result)
				return false;
			}
		}
	});
}

function menu_hook(title, tab) {
    tabtitle[tabtitle.length - 1] = new Array("", "网心云", "__INHERIT__");
    tablink[tablink.length - 1] = new Array("", "Module_wangxinyun.asp", "NULL");
}

function openShutManager(oSourceObj, oTargetObj, shutAble, oOpenTip, oShutTip) {
	var sourceObj = typeof oSourceObj == "string" ? document.getElementById(oSourceObj) : oSourceObj;
	var targetObj = typeof oTargetObj == "string" ? document.getElementById(oTargetObj) : oTargetObj;
	var openTip = oOpenTip || "";
	var shutTip = oShutTip || "";
	if (targetObj.style.display != "none") {
		if (shutAble) return;
		targetObj.style.display = "none";
		if (openTip && shutTip) {
			sourceObj.innerHTML = shutTip;
		}
	} else {
		targetObj.style.display = "block";
		if (openTip && shutTip) {
			sourceObj.innerHTML = openTip;
		}
	}
}

function showSSLoadingBar(seconds) {
	if (window.scrollTo)
		window.scrollTo(0, 0);

	winW_H();

	var blockmarginTop;
	var blockmarginLeft;
	if (window.innerWidth)
		winWidth = window.innerWidth;
	else if ((document.body) && (document.body.clientWidth))
		winWidth = document.body.clientWidth;

	if (window.innerHeight)
		winHeight = window.innerHeight;
	else if ((document.body) && (document.body.clientHeight))
		winHeight = document.body.clientHeight;

	if (document.documentElement && document.documentElement.clientHeight && document.documentElement.clientWidth) {
		winHeight = document.documentElement.clientHeight;
		winWidth = document.documentElement.clientWidth;
	}

	if (winWidth > 1050) {
		winPadding = (winWidth - 1050) / 2;
		winWidth = 1105;
		blockmarginLeft = (winWidth * 0.3) + winPadding - 150;
	} else if (winWidth <= 1050) {
		blockmarginLeft = (winWidth) * 0.3 + document.body.scrollLeft - 160;
	}

	if (winHeight > 660)
		winHeight = 660;

	blockmarginTop = winHeight * 0.5

	E("loadingBarBlock").style.marginTop = blockmarginTop + "px";
	E("loadingBarBlock").style.marginLeft = blockmarginLeft + "px";
	E("loadingBarBlock").style.width = 770 + "px";
	E("LoadingBar").style.width = winW + "px";
	E("LoadingBar").style.height = winH + "px";
	E("LoadingBar").style.visibility = "visible";
}

function version_show() {
	$.ajax({
		url: 'https://rogsoft.ddnsto.com/ddnsto/config.json.js',
		type: 'GET',
		dataType: 'jsonp',
		success: function(res) {
			if (typeof(res["version"]) != "undefined" && res["version"].length > 0) {
				if (res["version"] == db_wangxin["wangxinyun_version"]) {
					$("#wangxinyun_version_show").html("插件版本：" + res["version"]);
				} else if (res["version"] > db_wangxin["wangxinyun_version"]) {
					$("#wangxinyun_version_show").html("<font color=\"#66FF66\">有新版本：" + res.version + "</font>");
				}
			}
		}
	});
}

function reload_Soft_Center() {
	location.href = "/Module_Softcenter.asp";
}
function update_wx_cache_path(){
	var selectedPath = E("wx_disk_path_selected").value + "/wx_cache";
	$("#wx_cache_path").text(selectedPath);
}

function setupDiskPathListener() {
    $("#wx_disk_path_selected").on("change", function() {
		console.log("disk_path.onchange: " + $(this).val())
        update_wx_cache_path();
    });
}
</script>
</head>
<body id="app" skin="ASUSWRT" onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<div id="LoadingBar" class="popup_bar_bg">
		<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
			<tr>
				<td height="100">
					<div id="loading_block3" style="margin:10px auto;width:85%; font-size:12pt;">数据提交中，请稍候...</div>
				</td>
			</tr>
		</table>
	</div>
	<table class="content" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td width="17">&nbsp;</td>
			<td valign="top" width="202">
				<div id="mainMenu"></div>
				<div id="subMenu"></div>
			</td>
			<td valign="top">
				<div id="tabMenu" class="submenuBlock"></div>
				<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
					<tr>
						<td align="left" valign="top">
							<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle" style="border: 0px solid transparent;">
								<tr>
									<td bgcolor="#4D595D" colspan="3" valign="top" style="border-radius: 8px">
										<div>&nbsp;</div>
										<div class="formfonttitle">网心云（KoolCenter版）</div>
										<div style="float:right; width:15px; height:25px;margin-top:-20px">
											<img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onmouseover="this.src='/images/backprevclick.png'" onmouseout="this.src='/images/backprev.png'">
										</div>
										<div style="margin:30px 0 10px 5px;" class="splitLine"></div>
										 
										<div style="text-align: left; margin: 20px 0;">
											<img src="https://assets-cdn.wzhibo.net/wxy/koolcenter/banner.png" alt="网心云 Left Logo" style="height: auto;width: 764px;">
										</div>
										 
										
										<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
											<thead>
												<tr>
													<td colspan="2">第一步 - 连接磁盘并设置缓存路径</td>
												</tr>
											</thead>
										   
											<tr id="wangxinyun_status">
												<th>磁盘状态
													<div style="font-size: 10px; color: #888; margin-top: 3px;">请外接存储>50G 的的u盘或SSD固态硬盘</div>
												</th>
												<td><span id="disk_status">检测中...</span>
												</td>
											</tr>
											<tr>
												<th>缓存路径
													<div style="font-size: 10px; color: #888; margin-top: 3px;">请选择较大空间的存储地址，收益会更高！</div>
												</th>
												<td>
													<select name="wangxinyun_feat_disk_path_selected" id="wx_disk_path_selected" class="input_option"></option></select>
													<span id="wx_cache_path" style="margin-left: 10px;"> </span>
											   </td>
											</tr>
											
											</tbody><thead>
												<tr>
													<td colspan="2">第二步 - 运行设备（非常重要❗️❗️）</td>
												</tr>
											</thead>
											<tbody><tr id="switch_tr1">
												<th>
													启用
												</th>
												<td colspan="2">
													<div claddnsto="switch_field" style="display:table-cell;float: left;">
														<label for="wangxinyun_enable">
															<input id="wangxinyun_enable" class="switch" type="checkbox" style="display: none;">
															<div class="switch_container">
																<div class="switch_bar"></div>
																<div class="switch_circle transition_style">
																	<div></div>
																</div>
															</div>
														</label>
													</div>
													<div id="wx_run_warning" style="padding-top:5px;margin-left:10px;margin-top:0px;float: left;"> </div>
												</td>
											</tr>
											<tr>
												<th>运行状态</th>
												<td>
													<span id="status">检测中...</span> 
												</td>
											</tr>
											 
											
											<thead>
												<tr>
													<td id="wx_third_step_title" colspan="2">第三步 - 绑定账号，收益到账</td>
												</tr>
											</thead>
											<tr id="wx_third_step_content_not_run"> 
												<th  colspan="2" style=" padding: 15px;" > 
													<div style="display: flex; align-items: center;">
														<img src="/res/wx_warning.png" style="width: 30px; height: 30px; margin-right: 10px;">
														<label>请先点击【启用】 ，正常运行后才可绑定账号</label>
													</div>
												</th> 
											</tr>
											<tr id="wx_third_step_content_is_initing"> 
												<th  colspan="2" style="text-align: center; padding: 15px;">
													<div style="display: flex; align-items: center;"></div>
														<img src="/res/wx_loading.png" style="width: 30px; height: 30px; margin-right: 10px;">
														<label>设备初始化中，请稍等...</label>
													</div> 
												</th> 
											</tr>
											<tr id="wx_third_step_content_did_bind"> 
												<th colspan="2" style="text-align: center; padding: 15px;">
													<div style="display: flex; align-items: center;">
														<img id="wx_scan_guide" src="/res/wx_did_bind.png" style="max-width: 150px; height: auto;">
														<div style="text-align: left; margin-left: 20px;">
															<label id="wx_phone_label" style="display: block; margin-bottom: 10px;">已绑定账号：</label>
															<label id="wx_sn_label" style="display: block; margin-bottom: 10px;">设备编号：</label>
															<label id="wangxinyun_version_show" style="display: block;">插件版本：</label>
															
														</div>
													</div>
												</th>  
											</tr>
											 
											<tr id="wx_third_step_content"> 
												<th colspan="2" style="text-align: center; padding: 15px;">
													<div style="display: flex;  align-items: center;">
														<div style="display: flex; flex-direction: column;">
															<div id="ex_qrcode_back" style="width: 115px; height: 115px; background-color: white; position: relative;">
																<div id="wx_qrcode" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 105px; height: 105px;">
																</div>
															</div>
															<div id="wx_sn" style="text-align: left; margin-top: 5px; font-size: 10px;"></div>
														</div>
														<div style="display: flex; flex-direction: column;">
															<img id="wx_scan_guide" src="https://assets-cdn.wzhibo.net/wxy/koolcenter/handbook_bind.png" style="max-width: 115px; height: 115px; margin-left: 15px; margin-right: 10px;">
															<div style="text-align: center; margin-top: 5px;  font-size: 10px;">网心云APP首页</div>
														</div>
														<label style="display: block;">
															<span style="color: gold;">网心云APP首页</span>右上角点击绑定，<span style="color: gold;">扫描左侧二维码</span>即可绑定
															<div style="font-size: 10px; color: #888; margin-top: 3px; text-align: left;">*若您的手机没有网心云，可先用微信扫描左侧二维码进行下载</div>
														</label>
													</div>
												</th> 
											</tr>
										</tbody></table>
										<div id="wx_bottom" style="text-align: left; margin: 20px 0;">
											<a href="#" onclick="window.open('https://www.onethingcloud.com/?orginal=koolcenter', '_blank'); return false;">
												<img id="wx_bottom_img" src="https://assets-cdn.wzhibo.net/wxy/koolcenter/joinwx.png" style="height: auto; width: 764px;">
											</a>
										</div>
										
										<div id="warning" style="font-size:14px;margin:20px auto;"></div>
										<div class="apply_gen">
											<input class="button_gen" id="cmdBtn" onclick="onSubmitCtrl(this, ' Refresh ')" type="button" value="提交">
										</div>
									   
									</td>									
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
			<td width="10" align="center" valign="top"></td>
		</tr>
	</table>
	<div id="footer"></div>
</body>
</html>
