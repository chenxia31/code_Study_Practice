import zmail
import schedule
import time
import re
new_mail=0 # 初始化
def mailRecevie():
    # recevie mail
    server = zmail.server('xuchenlong7962021@163.com', 'HLYEXQWHGZRDVGBO')
    mailbox_info = server.stat()
    latest_mail=server.get_mail(mailbox_info[0])
    # test for the key and value in the mail
    # for ky in latest_mail:
    #     print('------ky and value----')
    #     print(ky)
    #     print(latest_mail[ky])
    global new_mail
    if latest_mail == new_mail:
        pass
    else:
        new_mail=latest_mail
        mail_subject = new_mail['subject']
        mail_subject,mail_content = mailContentDeal(mail_subject,new_mail['content_text'])  # many /r/n
        mail_date = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        # 这里解析出来对应的邮件内容，之后转到notion中，需要设置对应的邮件格式
        sendToNotion(mail_subject[1],mail_content[0],mail_content[1],mail_subject[0],mail_date)

def mailContentDeal(mail_subject,mail_content):
    # 邮件格式例如主题为：公众号-title
    # 主要网址为 url \r\n summary
    # 日期便是目前创建的日期
    # deal with the mail_content to format text with the re or another
    mail_subject_new = re.split('-', mail_subject)
    mail_content_new=re.split('\r\n',mail_content[0])
    mail_content_new= [i for i in mail_content_new if i != '']
    # delete special chars in string
    return mail_subject_new,mail_content_new

def sendToNotion(mail_title,mail_content_url,mail_summary,mail_class,mail_date):
    '''
    mail_title: 标题，可以用邮件的标题来替代（在邮件的正文中）
    mail_content_url:需要存储的连接（在邮件的正文中）
    mail_date:发送邮件的日期（自带就有）
    mail_sumamry:个人感悟，其实是可以没有的
    mail_class:存储的类别，论文、文章或者公众号,这个可以在标题中设置
    '''
    import requests
    # notion基本参数
    token = 'secret_9n9DrX8HpPOjXL5yxESdFlFIBqCZrE3mcKO9URovSUI'
    databaseID='6680a43bed3c4cd5a0ec792deb790e61'

    headers = {
        'Notion-Version': '2021-05-13',
        'Authorization': 'Bearer ' + token,
    }
    body = {
        # 父级信息（即你要创建的页面的上一级页面）
        "parent": {
            # 父级页面类型，如果我们想在服药记录的数据库中增加一条记录，那么新纪录是什么类型呢？
            # 答对了！是页面类型，我们创建的是记录，它展开后是一条页面，所以输入 page_id
            "type": "database_id",
            # 注意，下面的 "page_id" 项仍需要根据你的创建项目类型变化
            # 所需要提供的 ID 就是父级页面的 ID，需要手动在链接中进行复制
            "database_id": databaseID
        },
        # 属性项，在这里决定新记录的属性是什么，这里我用服药记录举例
        "properties": {
            "类型": {"type": "select", "select": {"name": mail_class}},
            "总结": {"type": "rich_text", "rich_text":[{"text": {"content": mail_summary}}]},
            "日期": {"type": "date", "date": {"start": mail_date}},
            "链接": {"type": "url", "url":mail_content_url},
            "标题": { 'id':'title',"type": "title", "title": [{'type':'text','text':{'content':mail_title}}]}}}
    print(body)
    r=requests.request('POST',"https://api.notion.com/v1/pages",json=body,headers=headers)
    print(r.text)

# 保证函数可以持续进行
mailRecevie()
# schedule.every().minutes.do(mailRecevie)
# while 1:
#     schedule.run_pending()




