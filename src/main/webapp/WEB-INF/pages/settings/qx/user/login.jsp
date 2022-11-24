<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript">
		$(function () {

			// 按下回车事件，相当于单击”登录“按钮
			$(window).keydown(function (e) {
				if (e.keyCode == 13) {
					$("#btnLogin").click();
				}
			})

			$("#btnLogin").click(function () {
				var loginAct = $.trim($("#loginAct").val());
				var loginPwd = $.trim($("#loginPwd").val());
				var isRemPwd = $("#isRemPwd").prop("checked");

				// 进行表单验证
				if (loginAct == "" ) {
					$("#msg").text("用户名不能为空!");
					return;
				}
				if (loginPwd == "") {
					$("#msg").text("密码不能为空!");
					return;
				}

				$.ajax({
					url : 'settings/qx/user/login.do', // controller的url地址
					dataType : 'json', // 期望得到的数据类型
					type : 'post', // 请求方法
					data : { // 发送至controller的请求参数(去除空格)
						loginAct : loginAct,
						loginPwd : loginPwd,
						isRemPwd : isRemPwd
					},
					success : function (data) {
						// 返回数据进行处理，此处的data应该是userMessage
						if (data.code == "1") {
							// 登陆成功，进入下一个controller(不能直接访问/WEN-INF/目录下的资源)
							window.location.href = "workbench/toIndex.do"
						} else {
							// 登陆失败，在msg框框中提示用户
							$("#msg").text(data.message);
						}
					},
					beforeSend() {
						$("#msg").text("Loading...");
					}
				})
			})
		})
	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2019&nbsp;动力节点</span></div>
	</div>

	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" id="loginAct" type="text" value="${cookie.loginAct.value}" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" id="loginPwd" type="password" value="${cookie.loginPwd.value}" placeholder="密码">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${(not empty cookie.loginAct) and (not empty cookie.loginPwd)}">
								<input type="checkbox" id="isRemPwd" checked>
							</c:if>
							<c:if test="${(empty cookie.loginAct) and (empty cookie.loginPwd)}">
								<input type="checkbox" id="isRemPwd">
							</c:if>
							十天内免登录
						</label>
						&nbsp;&nbsp;
						<span id="msg" style="color:red"></span>
					</div>
					<button type="button" id="btnLogin" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>