新机器的安装步骤：
1.安装Nginx
	yum install nginx

2.安装rz/sz
	yum install lrzsz

3.在/data目录下创建cloudytrace目录，用于保存客户端上传的日志zip文件,并修改权限
	cd /data
	mkdir cloudytrace
	chown nobody:nobody /data

4.在/usr/local/nginx目录下面创建lualib目录，并上传upload.lua到lualib文件夹下
	cd /usr/local/nginx
	mkdir lualib

5.在/usr/local/nginx/conf目录下创建lua目录,并上传snUpload.lua到lua文件夹下
	cd /usr/local/nginx/conf
	mkdir lua

6.修改Nginx配置文件nginx.conf,根据Nginx版本选择不同参考文件

7.在/usr/local/nginx/html下面创建lua接口对应响应文件
	例如：uploadFiles.gif接口
	touch /usr/local/nginx/html/uploadFiles.gif

8.启动Nginx

-------------------------------------------------------------------
验证方式：
curl  -H 'snctAppKey:ccccccccccccccc' -H 'snctUploadTime:20170621093456123' -F "file=@all-river-sit.zip" "http://10.37.149.86/uploadFiles.gif"
注意：上传的zip文件大小不能大于5M，如果大于5M会报文件过大的错误

-------------------------------------------------------------------
停止 Nginx
	/usr/local/nginx/sbin/nginx -s stop

启动 Nginx
	/usr/local/nginx/sbin/nginx

重新加载Nginx配置(更改Nginx配置和修改lua脚本之后必须执行此操作)
	/usr/local/nginx/sbin/nginx -s reload

上传文件lua库地址：
	https://github.com/openresty/lua-resty-upload/tree/v0.10

参考资料：
	http://blog.csdn.net/freewebsys/article/details/49509123#
	http://blog.csdn.net/langeldep/article/details/9628819
--------------------------------------------------------------------
1.SDK端上传压缩文件命名
	时间戳（到ms） + "_" + deviceToken + "_" + 文件序号.zip
	例如：201706161047300_18108168-9929-4DF7-BA91-13AD4DFB5D8D_1.zip

2.上传文件接口
	a.域名访问
	SIT环境：http://10.37.149.86/uploadFiles.gif
	b.在Header中添加参数
	snctAppKey:xxxxxxxxxxxxxxxxxxxx
	snctUploadTime:当前时间，格式：20170619113254137
	c.在同一个小时内，SDK切记不要上传重名文件，否则有可能后者会覆盖前者。
	例如：xxxxxx.zip在12:00~12:59上传到服务器，如果请求都落在同一台Nginx上，测试后者会覆盖前者
--------------------------------------------------------------------
1.Nginx服务器上文件存放根路径
	/data

4.Nginx服务器上文件存放规则
	/data/时间戳（到小时）/appKey/上传文件名
	例如：
	/data/2017061609/appKey/201706160959300_deviceToken_1.zip
	/data/2017061609/appKey/201706160959300_deviceToken_2.zip
	/data/2017061610/appKey/201706161000300_deviceToken_3.zip
	/data/2017061610/appKey/201706161000300_deviceToken_4.zip
	
PS:要根据实际网络带宽去做连接数等相关参数调整
