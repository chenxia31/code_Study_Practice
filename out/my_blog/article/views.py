from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse

# 导入数据模型ArticlePost
from .models import ArticlePost

# 视图函数
def article_list(request):
    # 取出所有博客文章
    articles = ArticlePost.objects.all()
    # 需要传递给模板（templates）的对象
    context = { 'articles': articles }
    # render函数：载入模板，并返回context对象
    return render(request, 'list.html', context)