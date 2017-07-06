<%--
  Created by IntelliJ IDEA.
  User: yhwang131
  Date: 2017-07-05
  Time: 오전 10:01
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="decorator" uri="http://www.opensymphony.com/sitemesh/decorator" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="security" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>포스트 리스트</title>
</head>
<body>
	<section class="background-gray-lightest">
		<div class="container">
			<div class="row">
				<div class="col-lg-8">
					<div class="breadcrumbs">
						<ul class="breadcrumb">
							<li><a href="/post">Blog</a></li>
							<li>List</li>
							<li id="listName">All</li>
						</ul>
					</div>
				</div>
				<div class="col-lg-4 pull-right">
					<form name="searchForm" method="post" onsubmit="return false;">
						<div class="input-group">
							<input type="text" class="form-control" placeholder="Search for..."/>
							<span class="input-group-btn">
								<button type="button" class="btn btn-default">Go!</button>
							</span>
						</div>
					</form>
				</div>
			</div>
		</div>
	</section>
	<section class="blog-post">
		<div class="container">
			<div class="col-lg-8">
				<div class="row">
					<div class="col-lg-10 col-md-10 col-sm-12 col-lg-offset-1 col-md-offset-1" v-for="(post, index) in postList" v-bind:key="post.post_cd">
						<div class="thumbnail">
							<div class="row date">
								<div class="col-md-6" v-html="post.category_name"></div>
								<div class="col-md-6 text-right">{{post.reg_dt|formatDate}}</div>
							</div>
							<div class="image-box" v-if="post.delegate_img != null && post.delegate_img != ''">
								<img src="" v-bind:style="'background: url(/post/images/' + post.delegate_img + ') no-repeat center;'">
							</div>
							<div class="caption">
								<h3 v-html="post.title"></h3>
								<p>{{get_stripped_content(post.content)}}</p>
								<security:authorize access="isAuthenticated()">
								<p class="text-right">
									<a href="javascript:void(0);" class="btn btn-sm btn-success" v-on:click="modify_post(post.post_cd)"><i class="fa fa-pencil-square-o" aria-hidden="true"> 수정</i></a>
									<a href="javascript:void(0);" class="btn btn-sm btn-danger" v-on:click="remove_post(post.post_cd, post.delegate_img, index, $event)"><i class="fa fa-trash-o" aria-hidden="true"> 삭제</i></a>
								</p>
								</security:authorize>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="col-lg-4">
				<h4 class="heading">Category</h4>
				<ul class="navigator">
					<c:forEach var="category" items="${categories}" varStatus="vs">
						<c:if test="${category.use_yn == true}">
							<li><a href="javascript:void(0);" data-target="${category.category_cd}"><c:out value="${category.category_name}"/></a></li>
						</c:if>
					</c:forEach>
				</ul>
			</div>
		</div>
	</section>
	<content tag="script">
	<script>
		var posts, param, isEnd = false

		function initSearchParam () {
			this.offset = 0
			this.rowsPerPage = 20
		}

		function getPostList (param, callback) {
			$.get('/api/postList', param).then(function (data) {
				if (data.length >= param.rowsPerPage) param.offset++;
				else isEnd = true
				return callback(data)
			})
		}

		/**
		 * 무한 스크롤 구현 시 사용
		 */
		function scrollHandler() {
			if ($(document).height() - 20 <= $(this).height() + $(this).scrollTop()) {
				$(this).off('scroll', scrollHandler)
				getPostList(param, function (data) {
					if (data) data.forEach(function (item) {
						posts.postList.push(item)
					})
					if (!isEnd) $(window).on('scroll', scrollHandler)
				})
			}
		}

		(function () {
			Vue.filter('formatDate', function (value) {
				if (value) return moment(value).format('MMMM DD YYYY, h:mm:ss a')
			})

			param = new initSearchParam()
			getPostList(param, function (data) {
				posts = new Vue({
					el: '.blog-post',
					data: {
						postList: data
					},
					methods: {
						get_stripped_content: function (content) {
							return content.replace(/<(?:.|\n)*?>/gm, '').trim()
						},
						modify_post: function (post_cd) {
							location.href = '/post/register/' + post_cd
						},
						remove_post: function (post_cd, delegate_img, index, e) {
							e.preventDefault()
							if (confirm(post_cd + ' : 포스트를 삭제하시겠습니까?')) {
								$.ajax({
									url: '/post/' + post_cd + '?' + $.param({delegate_img: delegate_img}),
									method: 'DELETE',
									dataType: 'json'
								}).then(function (result) {
									if (result.status) posts.postList.splice(index, 1)
									return false
								})
							}
							return false
						}
					}
				})

				if (!isEnd) $(window).on('scroll', scrollHandler)
			})

			$('form[name=searchForm]').on('submit', function (e) {
				e.preventDefault()
				param = new initSearchParam()
				param['searchText'] = $(this).find('input').val()
				getPostList(param, function (data) {
					console.log('data', data)
					posts.postList = data
					$('#listName').text('Search Result')
					if (!isEnd) $(window).on('scroll', scrollHandler)
				})
			})
		})()
	</script>
	</content>
</body>
</html>
