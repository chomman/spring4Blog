<%--
  Created by IntelliJ IDEA.
  User: yhwang131
  Date: 2016-10-11
  Time: 오후 2:57
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html>
<head>
	<title>포스트 등록</title>
</head>
<body>
	<form:form cssClass="ui form" action="/post/register" method="post" commandName="postVO" autocomplete="off">
		<h4 class="ui dividing header">Post Register</h4>
		<div class="fields">
			<div class="three wide field">
				<label for="category_cd">Category</label>
				<form:select path="category_cd" class="ui dropdown" required="true">
					<c:forEach var="item" items="${categoryList}">
						<form:option value="${item.category_cd}"><c:if test="${item.depth > 1}">└ </c:if><c:out value="${item.category_name}"/></form:option>
					</c:forEach>
				</form:select>
			</div>
			<div class="thirteen wide field">
				<label for="title">Title</label>
				<form:input type="text" path="title" maxlength="100" placeholder="포스트 제목" required="true"/>
				<form:errors path="title" cssClass="ui pointing red basic label"></form:errors>
			</div>
		</div>
		<div class="field">
			<label for="content">Content</label>
			<form:textarea path="content"></form:textarea>
		</div>
		<div class="fields">
			<div class="two wide field">
				<div class="ui checkbox">
					<form:checkbox path="use_yn" tabindex="0" class="hidden"/>
					<label>Show</label>
				</div>
			</div>
			<div class="four wide field">
				<div class="ui checkbox">
					<form:checkbox path="comment_yn" tabindex="0" class="hidden"/>
					<label>Allow Comments</label>
				</div>
			</div>
			<div class="ten wide field">
				<div class="ui right floated compact positive labeled icon button" title="등록">
					<i class="checkmark icon"></i>Register
				</div>
				<div class="ui right floated compact negative labeled icon button" title="취소">
					<i class="remove icon"></i>Cancel
				</div>
			</div>
		</div>
	</form:form>
	<content tag="script">
	<script>
		$('.ui.checkbox').checkbox();
	</script>
	</content>
</body>
</html>
