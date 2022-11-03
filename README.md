# godot_task_manager

可以导出CSV表的模块化缝合怪（？)
这是我的第一个开源项目，基于Godot4游戏引擎(beta4)
注意！**这并不是一个完整的程序**，存在一些功能缺失，可以按照自己的需求修改

# 演示图片

- 服务器未连接状态主页
![image](https://user-images.githubusercontent.com/22912744/199709608-b5622831-66d2-4003-aebb-894e7085bc06.png)
- 管理员管理模块
![image](https://user-images.githubusercontent.com/22912744/199709906-ee7b2745-2f16-45a2-864b-b8b1132d36e3.png)
- 操作员添加记录
![image](https://user-images.githubusercontent.com/22912744/199710086-846cc1f1-8eee-45b1-b31d-abeeec0754c1.png)
- 操作员修改项目
![image](https://user-images.githubusercontent.com/22912744/199710133-29051cb2-d8cd-4178-a19e-efbb2c58c52b.png)

# 目录

- 客户端程序：
./taskManager

- 服务端程序：
./taskManager_server

# 运行环境

Godot4beta4

# 简介

taskManager有两个用户等级，分别为Manager(管理员)，Operator(操作员)

Manager可以管理项目的内容，Operator可以对项目新增记录

服务器端的窗口可以注册账号，添加项目，对项目导出CSV表格
