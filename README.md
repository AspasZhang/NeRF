📖 操作流程指南
下面是整个任务从数据采集到模型训练与渲染测试的详细流程说明，帮助你顺利复现并使用本项目。

🎥 1. 拍摄物体图像
选取一个静态物体，从各个角度拍摄至少 50~100 张清晰照片，尽量保证相机移动均匀且完整地环绕物体一圈。

🧮 2. 相机参数估计（使用 COLMAP）
进入图像存放目录，并执行以下命令提取相机参数：

bash
复制
编辑
colmap feature_extractor \
    --database_path ./colmap_output/database.db \
    --image_path ./images \
    --ImageReader.single_camera 1 \
    --ImageReader.camera_model OPENCV

colmap matcher \
    --database_path ./colmap_output/database.db

mkdir ./colmap_output/sparse

colmap mapper \
    --database_path ./colmap_output/database.db \
    --image_path ./images \
    --output_path ./colmap_output/sparse
接下来，将稀疏模型转换为 TensoRF 训练需要的 JSON 文件：

bash
复制
编辑
colmap model_converter \
    --input_path ./colmap_output/sparse/0 \
    --output_path ./colmap_output/sparse_text \
    --output_type TXT
最后，使用提供的脚本（如 colmap2nerf.py）将 TXT 格式转换为 transforms_train.json 和 transforms_test.json。

🧠 3. 模型训练（TensoRF）
请确保已安装所有依赖，按照 requirements.txt 配置好环境，然后执行训练：

bash
复制
编辑
python train.py --config configs/your_own_data.txt
训练过程可通过 TensorBoard 实时监控损失曲线与指标：

bash
复制
编辑
tensorboard --logdir ./output/your_exp_name
🖼 4. 新视角渲染与测试
训练完成后，使用渲染脚本生成新视角图片与测试图片：

bash
复制
编辑
python train.py --config configs/your_own_data.txt --render_only --render_test
也可将模型训练好的权重文件传入 --ckpt 来单独测试：

bash
复制
编辑
python train.py --ckpt output/your_exp_name/your_model.th --render_test
📊 5. 结果评价
渲染完毕后，在 output/your_exp_name/imgs_test_all/ 中查看测试渲染结果，计算测试 PSNR、MSE 等指标，并使用可视化工具查看损失曲线（如 TensorBoard 中的曲线），对模型效果与训练过程做出评估。

🎥 6. 视频生成（可选）
根据训练后的模型权重，在新轨迹下渲染得到连续帧，使用以下命令：

bash
复制
编辑
python train.py --ckpt output/your_exp_name/your_model.th --render_path
渲染后的帧保存在 imgs_path_all/ 中，然后用 FFmpeg 拼接成视频：

bash
复制
编辑
ffmpeg -framerate 30 -i imgs_path_all/frame_%05d.png -c:v libx264 -pix_fmt yuv420p output.mp4
🎯 注意事项：

确保每个步骤中路径对应正确，不同设备与平台需要调整相应路径。

若需复现模型训练曲线与过程日志，请提前启用 SummaryWriter 并设置 --progress_refresh_rate 来控制日志打印频率。

训练时间取决于硬件性能（推荐使用至少 8~12 GB 显存的 GPU），请耐心等待训练完成。
