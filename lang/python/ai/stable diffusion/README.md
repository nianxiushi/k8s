## 安装
```
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
(Get-Content 'webui-user.bat') -replace 'set COMMANDLINE_ARGS=', 'set COMMANDLINE_ARGS=--skip-torch-cuda-test' | Set-Content 'webui-user.bat'
webui-user.bat
```