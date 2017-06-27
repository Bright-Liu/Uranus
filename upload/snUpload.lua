--[[
外部依赖包，请放在这位置
--]]
package.path = '/usr/local/nginx/lualib/?.lua;'

--[[ 
全局的静态变量请放在这边
--]]
--APPKEY
local CTDSA_LOG_HEADER_APPKEY="snctAppKey"
--上传时间
local CTDSA_LOG_HEADER_UPLOADTIME="snctUploadTime"
--日志本地保存日志
local CTDSA_LOG_BASE_PATH="/data/cloudytrace/"
--处理状态码
local CTDSA_LOG_HAND_STATUS="OK"


--[[
   得到文件名
  @param #res nginx的请求体 
  @return nginx上传的文件名
--]]
function get_filename(res)
  local filename = ngx.re.match(res,'(.+)filename="(.+)"(.*)')
  if filename then
    return filename[2]
  end
end

--[[
   检测Header信息
  @param #hearders nginx的请求体 
  @return 检测结果，检测正确返回    CTDSA_LOG_HAND_STATUS
--]]
function check_header(hearders)
  local appKey = nil
  local uploadTime = nil
  if hearders ~= nil then
    appKey = hearders[CTDSA_LOG_HEADER_APPKEY]
    uploadTime = hearders[CTDSA_LOG_HEADER_UPLOADTIME]
  end
  local flag=CTDSA_LOG_HAND_STATUS;
  if appKey == nil then
    flag="appKey not exist!"
    return flag
  end

  if uploadTime == nil then
     flag="uploadTime not exist!"
     return flag
  end
  
  if(string.len(appKey) == 0 or string.len(uploadTime) == 0 ) then
    flag="appKey or uploadTime is blank,appKey:"..appKey..", uploadTime:"..uploadTime
    return flag
  end
  return flag
end


-- 创建文件夹
function mkdir_upload_folder(appKey)
  -- 检查上传文件的存放路径存不存在，不存在则创建,文件路径：CTDSA_LOG_BASE_PATH 服务器当前时间（到小时）/appKey
  local osfilepath = CTDSA_LOG_BASE_PATH..os.date("%Y%m%d%H").."/"..appKey
  local folder = io.open(osfilepath, "rb")
  if folder then
    folder:close()
  else
    local command = "mkdir -p "..osfilepath
    os.execute(command)
  end
  return osfilepath
end



-- 获取Header中信息
local hearders = ngx.req.get_headers()

local flag=check_header(hearders);
if(flag ~= CTDSA_LOG_HAND_STATUS) then
  ngx.say(flag)
  return ngx.exit(403)
end

local appKey = nil
local uploadTime = nil
if hearders ~= nil then
  appKey = hearders[CTDSA_LOG_HEADER_APPKEY]
  uploadTime = hearders[CTDSA_LOG_HEADER_UPLOADTIME]
end


local osfilepath=mkdir_upload_folder(appKey)

--引入upload模块
local upload = require "upload"
-- 开始处理下载文件
local chunk_size = 4096
local form = upload:new(chunk_size)
local file
local filelen=0

if form == nil then
  ngx.say("no files")
  return ngx.exit(403)
end

form:set_timeout(0) -- 1 sec
local filename
local i=0

while true do
    local typ, res, err = form:read()
    if not typ then
        ngx.say("failed to read: ", err)
        return
    end
    if typ == "header" then
        if res[1] ~= "Content-Type" then
            filename = get_filename(res[2])
            if filename then
                i=i+1
                filepath = osfilepath.."/"..filename
                file = io.open(filepath,"w+")
                if not file then
                    ngx.say("failed to open file ")
                    return
                end
            else
            end
        end
    elseif typ == "body" then
        if file then
            filelen= filelen + tonumber(string.len(res))    
            file:write(res)
        else
        end
    elseif typ == "part_end" then
        if file then
            file:flush()
            file:close()
            file = nil
            ngx.say("file upload success")
        end
    elseif typ == "eof" then
        break
    else
    end
end

if i==0 then
    ngx.say("please upload at least one file!")
    return
end