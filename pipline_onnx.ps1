# Activate the first conda environment
conda activate dh1

# 切換到 data_utils 資料夾
Set-Location -Path ".\data_utils\"

# 使用 process.py 處理影片（請確認輸入的影片路徑正確）
python process.py ..\nc\nc.mp4 --asr hubert

# 移動 full_body_img 資料夾到 ..\nc\（假設 full_body_img 產生在目前目錄下）
Move-Item -Path ".\full_body_img" -Destination "..\nc\"

# 回到上一層目錄
Set-Location -Path ".."

# 執行 syncnet.py，並指定輸出和資料集目錄
python syncnet.py --save_dir ".\syncnet\" --dataset_dir ".\nc\" --asr hubert

# 執行 train.py，訓練模型並指定 checkpoint 路徑
python train.py --dataset_dir ".\nc\" --save_dir ".\checkpoint\" --asr hubert --use_syncnet --syncnet_checkpoint ".\syncnet_ckpt\39.pth"

# 執行 inference.py 進行推論，產生影片輸出
python inference.py --asr hubert --dataset ".\nc\" --audio_feat "1742225705918654799-248516037505133.mp3.npy" --save_path "nc.mp4" --checkpoint ".\checkpoint\195.pth"

# 使用 ffmpeg 將影片和音訊合併
ffmpeg -i "nc.mp4" -i "1742225705918654799-248516037505133.mp3" -c:v libx264 -c:a aac "nc_merge.mp4"

# 將 checkpoint 檔案複製到 nc 資料夾
Copy-Item -Path ".\checkpoint\195.pth" -Destination ".\nc\"

# 複製 nc 資料夾到 E:\livetalking-onnx\ultralight（若為資料夾，請加上 -Recurse）
Copy-Item -Path ".\nc" -Destination "E:\livetalking-onnx\ultralight" -Recurse

# 切換到目標資料夾
Set-Location -Path "E:\livetalking-onnx\ultralight"

# Activate the second conda environment
conda activate nerfstream

# 使用 genavatar.py 產生 avatar
python genavatar.py --dataset "nc/" --checkpoint ".\nc\195.pth"

# 重命名生成的 avatar 資料夾（此處使用 PowerShell 的 Rename-Item）
Rename-Item -Path ".\results\avatars\ultralight_avatar1" -NewName "nc"

# 移動重命名後的 avatar 資料夾到 ../data/avatars/nc
Move-Item -Path ".\results\avatars\nc" -Destination "..\data\avatars\nc" -Force

# 返回上一層目錄
Set-Location -Path ".."

# 啟動應用程式
python app.py --transport webrtc --model ultralight --avatar_id nc
