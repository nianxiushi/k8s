## 安装
```
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
(Get-Content 'webui-user.bat') -replace 'set COMMANDLINE_ARGS=', 'set COMMANDLINE_ARGS=--skip-torch-cuda-test --precision full --no-half' | Set-Content 'webui-user.bat'
webui-user.bat
```
## 插件
```
ControlNet：https://github.com/Mikubill/sd-webui-controlnet.git
QR code：https://github.com/antfu/qrcode-toolkit
```
## 模型
* v1-5-pruned-emaonly.safetensors 
```
# 正向描述
a young girl with brown eyes，wearing a white outfit， sitting outside cafe , side light, full body shot , by Vincent van Gogh
# 反向描述
worst quality, low quality, grayscale, monochrome, missing arms, extra legs, fused fingers, too many fingers, unclear eyes
```
