<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+
	request.getServerPort()+path+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<script type="text/javascript" >

	$(function () {

		$("#btnCreateActivity").click(function () {
			// 重置表单
			$("#formCreateActivity").get(0).reset();
			// 弹出模态窗口
			$("#createActivityModal").modal('show')
		})

		// 保存创建的市场活动
		$("#btnSaveActivity").click(function () {

			// 快速获取表单的数据?name=&value=(格式)
			var owner = $("#create-marketActivityOwner").val();
			var name = $("#create-marketActivityName").val();
			var startDate = $("#create-startTime").val();
			var endDate = $("#create-endTime").val();
			var cost = $("#create-cost").val();
			var description = $("#create-describe").val();

			// ajax请求
			$.ajax({
				url : 'workbench/activity/saveActivity.do',
				type : 'post',
				dataType : 'json',
				data : {
					owner : owner,
					name : name,
					startDate : startDate,
					endDate : endDate,
					cost : cost,
					description : description
				},
				success : function (data) {
					if (data.code == "1") {
						// success
						$("#createActivityModal").modal('hide');
						queryActivitiesAjax(1, $("#bs_pagination_div").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// fail
						alert(data.message)
					}
				},
				beforeSend : function () {
					var regExp = /^(([1-9]\d*)|0)$/;
					if (! regExp.test(cost)) {
						alert("The cost can only be a negative integer!")
						return false;
					}
					if (name == "" || owner == "") {
						alert("name or owner can not be null!")
						return false;
					}
					if (startDate != "" && endDate != "") {
						if (new Date(startDate) > new Date(endDate)) {
							alert("startDate > endDate!")
							return false;
						}
					}
				}
			})
		})

		$.fn.datetimepicker.dates['zh-CN'] = {
			days: ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"],
			daysShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六", "周日"],
			daysMin:  ["日", "一", "二", "三", "四", "五", "六", "日"],
			months: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
			monthsShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
			today: "今天",
			suffix: [],
			meridiem: ["上午", "下午"]
		};

		// 当容器加载完毕之后，对容器调用工具函数
		$(".mydate").datetimepicker({
			language : 'zh-CN', // 语言：简体中文
			format : 'yyyy-mm-dd', // 日期格式
			minView : 'month', // 可以选择的最小视图
			initialDate : new Date(), // 初始化显示的日期
			autoclose : true, // 选择完日期或时间之后，自动关闭日历
			todayBtn : true, // 设置显示”今天“按钮，点击之后自动选择当天日期
			clearBtn : true // 设置是否会显示”清空“按钮，默认是false
		})

		// 页面加载完成之后自动查询Activities
		queryActivitiesAjax(1, 10);

		// 用户单击”查询“按钮
		$("#btnQueryActivities").click(function () {
			queryActivitiesAjax(1, $("#bs_pagination_div").bs_pagination('getOption', 'rowsPerPage'));
		})

		// 全选按钮单击事件
		$("#chckAll").click(function() {

			$("#tBodyActivitiesList input[type = 'checkbox']").prop("checked", this.checked);
		})

		// 父子选择器
		$("#tBodyActivitiesList").on('click', "input[type = 'checkbox']", function() {
			// 如果列表中所有checkbox都选中，则”全选“按钮也选中
			isAllChecked();
		});

		// 单击”删除”按钮的事件
		$("#btnDeleteActivities").click(function() {
			// 获取要删除的市场活动的数量
			var checkedIds = $("#tBodyActivitiesList input[type='checkbox']:checked");
			// 前台判断是否至少有一个checkbox被选中
			if (checkedIds.size() == 0) {
				alert('At least choose an activity!')
				return;
			}

			if (window.confirm("Do you really want to delete the activities?")) {
				var ids = "";
				$.each(checkedIds, function() {
					ids += "id=" + this.value + "&"
				})
				// 截取字符串
				ids.substr(0, ids.length-1);
				// 发送ajax请求
				$.ajax({
					url : 'workbench/activity/deleteActivities.do',
					data : ids,
					dataType : 'json',
					type : 'post',
					success : function(data) {
						if (data.code == "1") {
							// 刷新市场活动列表
							queryActivitiesAjax(1, $("#bs_pagination_div").bs_pagination('getOption', 'rowsPerPage'));
						} else {
							// 失败
							alert(data.message);
						}
					}
				})
			}
		})

		// 单击”修改“按钮事件
		$("#btnUpdateActivity").click(function() {
			// 获取已勾选的checkbox
			var checkedIds = $("#tBodyActivitiesList input[type='checkbox']:checked");
			// 前台判断是否至少有一个checkbox被选中
			if (checkedIds.size() != 1) {
				alert('Only one activity can be ticked!');
				return;
			}
			$("#editActivityModal").modal('show');
			var id = checkedIds.val();
			// 只有一个市场活动checkbox被选中,获取那个被选中的市场活动的id,向后端查询该市场活动的其他全部信息
			$.ajax({
				url : 'workbench/activity/selectAnActivity.do',
				type : 'post',
				dataType : 'json',
				data : {
					id : id
				},
				success : function(data) {
					// 获取到activity的所有数据，在修改市场活动的模态窗口中进行展示
					$("#edit-id").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner);
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-describe").text(data.description);
				}
			})
		})

		// 用户单击”更新“按钮
		$("#btnUpdateActivity2").click(function() {
			// 获取输入框的数据
			var id = $("#tBodyActivitiesList input[type='checkbox']:checked").val();
			var owner = $("#edit-marketActivityOwner").val();
			var name = $("#edit-marketActivityName").val();
			var startDate = $("#edit-startTime").val();
			var endDate = $("#edit-endTime").val();
			var cost = $("#edit-cost").val();
			var description = $("#edit-describe").val();

			// 向后台发送请求
			$.ajax({
				url : 'workbench/activity/updateActivity.do',
				type : 'post',
				dataType : 'json',
				data : {
					id : id,
					owner : owner,
					name : name,
					startDate : startDate,
					endDate : endDate,
					cost : cost,
					description : description
				},
				success : function(data) {
					if (data.code == 1) {
						// 成功更新，关闭模态窗口，刷新列表
						$("#editActivityModal").modal('hide');
						queryActivitiesAjax(1, $("#bs_pagination_div").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						// 更新失败，模态窗口不会关闭，并弹出提示信息
						alert(data.message);
					}
				},
				beforeSend : function () {
					var regExp = /^(([1-9]\d*)|0)$/;
					if (! regExp.test(cost)) {
						alert("The cost can only be a negative integer!")
						return false;
					}
					// 带*号的内容不能为空
					if (owner == null && owner == "") {
						alert("owner and name can not be null!");
						return;
					}
					if (name == null && name == "") {
						alert("owner and name can not be null!");
						return;
					}
					if (startDate != "" && endDate != "") {
						if (new Date(startDate) > new Date(endDate)) {
							alert("startDate > endDate!")
							return false;
						}
					}
				}
			})
		})

		// 用户在”修改市场活动“的模态窗口中单击”关闭“按钮
		$("#btnCloseUpdateModal").click(function() {
			$("#editActivityModal").modal('hide');
		})

		// 单击“批量导出市场活动”按钮
		$("#exportActivityAllBtn").click(function() {
			// 向controller发起下载请求,查询市场活动
			window.location.href = "workbench/activity/activitiesDownload.do";
		})

		// 单击“部分导出市场活动”按钮
		$("#exportActivityXzBtn").click(function() {
			// 获取已勾选的checkbox
			var checkedIds = $("#tBodyActivitiesList input[type='checkbox']:checked");
			// 前台判断是否至少有一个checkbox被选中
			if (checkedIds.size() == 0) {
				alert('Select at least one checkbox!');
				return;
			}
			var ids = "";
			$.each(checkedIds, function() {
				ids += "id=" + this.value + "&"
			})
			ids.substr(0, ids.length-1);// 截取字符串
			// 发送同步请求
			window.location.href = "workbench/activity/partOfActivitiesDownload.do?" + ids + "";
		})
	});

	function isAllChecked() {
		if ($("#tBodyActivitiesList input[type = 'checkbox']").size() ==
				$("#tBodyActivitiesList input[type = 'checkbox']:checked").size()) {
			$("#chckAll").prop('checked', true);
		} else {
			$("#chckAll").prop('checked', false);
		}
	}

	function queryActivitiesAjax(pageNo, pageSize) {


		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var startDate = $("#query-startDate").val();
		var endDate = $("#query-endDate").val();

		// 页面加载完毕之后，发起ajax请求，查询所有符合条件的市场活动
		$.ajax({
			url : 'workbench/activity/queryActivitiesByConditionForPage.do',
			type : 'post',
			dataType : 'json',
			data : {
				name : name,
				owner : owner,
				startDate : startDate,
				endDate : endDate,
				pageNo : pageNo,
				pageSize : pageSize
			},
			success : function (data) {
				// 显示总的条数
				$("#totalRowsB").text(data.countsOfActivities);
				// 显示市场活动列表，字符串的拼接
				var htmlStr = "";
				$.each(data.activities, function (index, obj) {
					htmlStr += "<tr class=\"active\">";
					htmlStr += "<td><input type=\"checkbox\" value='" + obj.id + "'/></td>";
					htmlStr += "<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='detail.html';\">" + obj.name + "</a></td>";
					htmlStr += "<td>" + obj.owner + "</td>";
					htmlStr += "<td>" + obj.startDate + "</td>";
					htmlStr += "<td>" + obj.endDate + "</td>";
					htmlStr += "</tr>"
				})
				$("#tBodyActivitiesList").html(htmlStr);

				// 取消全选按钮
				$("#chckAll").prop("checked", false);

				var totalPages = 1;
				if (data.countsOfActivities % pageSize == 0) {
					totalPages = data.countsOfActivities / pageSize;
				} else {
					totalPages = parseInt(data.countsOfActivities / pageSize) + 1;
				}

				// 调用bs_pagination工具函数，显示翻页信息
				$("#bs_pagination_div").bs_pagination({
					currentPage : pageNo, // 当前页号，相当于pageNo
					rowsPerPage : pageSize, // 每页显示条数，相当于pageSize
					totalRows : data.countsOfActivities,  // 总条数
					totalPages : totalPages, // 总页数，必填参数
					visiblePageLinks: 5, // 最多可以显示的卡片数

					showGoToPage : true, // 是否显示“跳转到”部分，默认true==显示
					showRowsPerPage : true, // 是否显示“每页显示条数”部分，默认显示
					showRowsInfo : true, // 是否显示记录的信息，默认显示

					// 用户每次切换页号都会自动执行本函数
					// 每次返回切换页号之后的pagesize和pageNo
					onChangePage : function(event, pageObj) {
						queryActivitiesAjax(pageObj.currentPage, pageObj.rowsPerPage);
					}
				})
			}
		})
	}

</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" id="formCreateActivity">

						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
									<c:forEach items="${users}" var="u" >
										<option value="${u.id}">${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName" >
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-startTime" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label" >结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-endTime" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost" >
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="btnSaveActivity">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${users}" var="u" >
										<option value="${u.id}">${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" <%--value="发传单"--%>>
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label ">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-startTime" <%--value="2020-10-10"--%>>
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label ">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-endTime" <%--value="2020-10-20"--%>>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" <%--value="5,000"--%>>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" id="btnCloseUpdateModal">关闭</button>
					<button type="button" class="btn btn-primary" id="btnUpdateActivity2">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	<%--市场活动列表--%>
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="query-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="query-endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="btnQueryActivities">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="btnCreateActivity"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="btnUpdateActivity" <%--data-toggle="modal" data-target="#editActivityModal"--%>><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="btnDeleteActivities"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="chckAll"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="tBodyActivitiesList">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
						<c:forEach items="${activities}" var="act" >
							<tr class="active">
								<td><input type="checkbox" /></td>
								<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">${act.name}</a></td>
								<td>${act.owner}</td>
								<td>${act.startDate}</td>
								<td>${act.endDate}</td>
							</tr>
						</c:forEach>--%>
					</tbody>
				</table>
				<div id="bs_pagination_div" ></div>
			</div>
			
			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" >
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>